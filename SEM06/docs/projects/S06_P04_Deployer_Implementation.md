# Deployer Project - Detailed Implementation

## Contents

1. [General Overview](#1-general-overview)
2. [System Architecture](#2-system-architecture)
3. [Deployment Strategies](#3-deployment-strategies)
4. [Core Module - deployer_core.sh](#4-core-module---deployer_coresh)
5. [Health Checks System](#5-health-checks-system)
6. [Hooks System](#6-hooks-system)
7. [Rollback and Recovery](#7-rollback-and-recovery)
8. [Manifest-based Deployment](#8-manifest-based-deployment)
9. [Implementation Exercises](#9-implementation-exercises)

---

## 1. General Overview

### 1.1 Project Purpose

The **Deployer** project implements an automated deployment system for applications, offering:

- **Multiple Strategies**: rolling, blue-green, canary deployment
- **Health Checks**: application state verification (HTTP, TCP, process, command)
- **Automatic Rollback**: revert to previous version in case of failure
- **Hooks System**: pre_deploy, post_deploy, on_rollback, on_failure
- **Manifest Deployment**: YAML file-based deployment
- **Service Management**: integration with systemd, Docker

### 1.2 File Structure

```
projects/deployer/
├── deployer.sh              # Main script (~1000 lines)
├── lib/
│   ├── deployer_core.sh     # Deployment functions (~800 lines)
│   ├── deployer_utils.sh    # Common utilities (~400 lines)
│   └── deployer_config.sh   # Configuration management (~300 lines)
└── config/
    └── deployer.conf        # Default configuration
```

### 1.3 Fundamental Concepts

**Deployment** = The process of installing and configuring a new application version

**Release** = A specific application version prepared for deployment

**Rollback** = Reverting to a previous functional version

**Health Check** = Verification that the application works correctly

---

## 2. System Architecture

### 2.1 Component Diagram

```
┌─────────────────────────────────────────────────────────────────────────┐
│                        deployer.sh (Main)                               │
├─────────────────────────────────────────────────────────────────────────┤
│  main() ─┬─ parse_arguments()                                           │
│          ├─ load_config()                                               │
│          ├─ validate_manifest()                                         │
│          └─ execute_deployment()                                        │
│                    │                                                     │
│         ┌─────────┴───────────┬────────────────┬──────────────┐        │
│         ▼                     ▼                ▼              ▼        │
│   deploy_rolling()    deploy_blue_green()  deploy_canary()  rollback() │
└─────────────────────────────────────────────────────────────────────────┘
                │                    │              │
                ▼                    ▼              ▼
┌──────────────────────────────────────────────────────────────────────────┐
│                         deployer_core.sh                                  │
├──────────────────────────────────────────────────────────────────────────┤
│  prepare_release()      activate_release()      health_check()           │
│  upload_files()         switch_symlink()        check_http()             │
│  run_hooks()            restart_service()       check_tcp()              │
│  create_rollback_point()  cleanup_old_releases()  check_process()        │
└──────────────────────────────────────────────────────────────────────────┘
                │                    │              │
                ▼                    ▼              ▼
┌──────────────────────────────────────────────────────────────────────────┐
│                         deployer_utils.sh                                 │
├──────────────────────────────────────────────────────────────────────────┤
│  log_message()          format_timestamp()       send_notification()     │
│  log_deployment()       generate_release_id()    parse_yaml()            │
│  create_lockfile()      archive_release()        validate_url()          │
└──────────────────────────────────────────────────────────────────────────┘
```

### 2.2 Deployment Directory Structure

```
/var/www/myapp/                     # Application root
├── releases/                       # All versions
│   ├── 20240115_143022/           # Release 1
│   │   ├── app/
│   │   ├── config/
│   │   └── .release_meta
│   ├── 20240116_093045/           # Release 2
│   └── 20240117_110530/           # Release 3 (current)
├── shared/                         # Files shared between releases
│   ├── config/                    # Permanent configurations
│   ├── uploads/                   # User uploaded files
│   └── logs/                      # Application logs
├── current -> releases/20240117_110530/  # Symlink to active version
└── .deploy_state/                  # Deployment state
    ├── last_deploy.json           # Last deployment info
    ├── rollback_point             # Version for rollback
    └── deploy.lock                # Lock for concurrency
```

### 2.3 Deployment Lifecycle

```
┌────────────────────────────────────────────────────────────────────────┐
│                     DEPLOYMENT LIFECYCLE                                │
│                                                                        │
│   ┌─────────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐            │
│   │ PREPARE │───▶│ UPLOAD  │───▶│  BUILD  │───▶│ VERIFY  │            │
│   └─────────┘    └─────────┘    └─────────┘    └─────────┘            │
│        │                                              │                │
│        │         ┌────────────────────────────────────┘                │
│        │         │                                                     │
│        │         ▼                                                     │
│        │    ┌─────────┐    ┌─────────┐    ┌─────────┐                 │
│        │    │ ACTIVATE│───▶│ HEALTH  │───▶│ CLEANUP │                 │
│        │    └─────────┘    │  CHECK  │    └─────────┘                 │
│        │         │         └─────────┘         │                       │
│        │         │              │              │                       │
│        │         │         FAIL │              │                       │
│        │         │              ▼              │                       │
│        │         │        ┌─────────┐          │                       │
│        │         │        │ROLLBACK │          │                       │
│        │         │        └─────────┘          │                       │
│        │         │              │              │                       │
│        └─────────┴──────────────┴──────────────┘                       │
│                           │                                            │
│                           ▼                                            │
│                     ┌─────────┐                                        │
│                     │ COMPLETE│                                        │
│                     └─────────┘                                        │
│                                                                        │
└────────────────────────────────────────────────────────────────────────┘
```

---

## 3. Deployment Strategies

### 3.1 Rolling Deployment

```
┌─────────────────────────────────────────────────────────────────────────┐
│                     ROLLING DEPLOYMENT                                   │
│                                                                          │
│   Initial State:                                                        │
│   [Instance 1: v1.0] [Instance 2: v1.0] [Instance 3: v1.0]             │
│   ─────────────────────────────────────────────────────────             │
│   100% v1.0                                                             │
│                                                                          │
│   Step 1: Update Instance 1                                             │
│   [Instance 1: v2.0] [Instance 2: v1.0] [Instance 3: v1.0]             │
│   ─────────────────────────────────────────────────────────             │
│   33% v2.0, 67% v1.0                                                    │
│                                                                          │
│   Step 2: Update Instance 2                                             │
│   [Instance 1: v2.0] [Instance 2: v2.0] [Instance 3: v1.0]             │
│   ─────────────────────────────────────────────────────────             │
│   67% v2.0, 33% v1.0                                                    │
│                                                                          │
│   Step 3: Update Instance 3                                             │
│   [Instance 1: v2.0] [Instance 2: v2.0] [Instance 3: v2.0]             │
│   ─────────────────────────────────────────────────────────             │
│   100% v2.0                                                             │
│                                                                          │
│   Advantages:              Disadvantages:                               │
│   + Zero downtime          - Mixed versions temporarily                 │
│   + Gradual rollback       - Higher complexity                          │
│   + Production testing     - Requires backward compatibility            │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

### 3.2 Blue-Green Deployment

```
┌─────────────────────────────────────────────────────────────────────────┐
│                    BLUE-GREEN DEPLOYMENT                                 │
│                                                                          │
│   Initial State:                                                        │
│                                                                          │
│   ┌─────────────────┐         ┌─────────────────┐                       │
│   │   BLUE (v1.0)   │◀═══════▶│  Load Balancer  │◀═══▶ Users           │
│   │     ACTIVE      │         └─────────────────┘                       │
│   └─────────────────┘                 ╳                                 │
│                                       ║                                 │
│   ┌─────────────────┐                 ║                                 │
│   │  GREEN (idle)   │─ ─ ─ ─ ─ ─ ─ ─ ─                                  │
│   │    STANDBY      │                                                   │
│   └─────────────────┘                                                   │
│                                                                          │
│   After Deploy:                                                         │
│                                                                          │
│   ┌─────────────────┐                 ╳                                 │
│   │   BLUE (v1.0)   │─ ─ ─ ─ ─ ─ ─ ─ ─                                  │
│   │    STANDBY      │                                                   │
│   └─────────────────┘                 ║                                 │
│                                       ║                                 │
│   ┌─────────────────┐         ┌─────────────────┐                       │
│   │  GREEN (v2.0)   │◀═══════▶│  Load Balancer  │◀═══▶ Users           │
│   │     ACTIVE      │         └─────────────────┘                       │
│   └─────────────────┘                                                   │
│                                                                          │
│   Advantages:              Disadvantages:                               │
│   + Instant rollback       - Resource duplication                       │
│   + Zero downtime          - Higher cost                                │
│   + Testing before         - Complex DB synchronisation                 │
│     switch                                                              │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

### 3.3 Canary Deployment

```
┌─────────────────────────────────────────────────────────────────────────┐
│                      CANARY DEPLOYMENT                                   │
│                                                                          │
│   Initial State: 100% traffic → v1.0                                    │
│                                                                          │
│   ┌─────────────────────────────────────────────────────┐               │
│   │                 Production (v1.0)                   │               │
│   │  █████████████████████████████████████████████████  │ 100%         │
│   └─────────────────────────────────────────────────────┘               │
│                                                                          │
│   Step 1: Deploy canary (5% traffic)                                    │
│                                                                          │
│   ┌─────────────────────────────────────────────────────┐               │
│   │            Production (v1.0)                        │               │
│   │  ███████████████████████████████████████████████    │ 95%          │
│   └─────────────────────────────────────────────────────┘               │
│   ┌────┐                                                                │
│   │v2.0│ Canary                                           5%            │
│   └────┘                                                                │
│                                                                          │
│   Step 2: Monitor metrics (errors, latency, etc.)                       │
│   ┌──────────────────────────────────────────────────────────────┐      │
│   │  Errors: ✓ OK    Latency: ✓ OK    CPU: ✓ OK    Memory: ✓ OK  │      │
│   └──────────────────────────────────────────────────────────────┘      │
│                                                                          │
│   Step 3: Gradual increase (25% → 50% → 100%)                           │
│                                                                          │
│   ┌──────────────────────────────────────────┐                          │
│   │         Production (v1.0)                │ 50%                      │
│   └──────────────────────────────────────────┘                          │
│   ┌──────────────────────────────────────────┐                          │
│   │         Canary (v2.0)                    │ 50%                      │
│   └──────────────────────────────────────────┘                          │
│                                                                          │
│   Step 4: Finalisation (100% v2.0)                                      │
│                                                                          │
│   ┌─────────────────────────────────────────────────────┐               │
│   │                 Production (v2.0)                   │               │
│   │  █████████████████████████████████████████████████  │ 100%         │
│   └─────────────────────────────────────────────────────┘               │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## 4. Core Module - deployer_core.sh

### 4.1 The prepare_release() Function

```bash
prepare_release() {
    local source_path="$1"
    local app_root="$2"
    
    # Generate unique ID for release
    local release_id
    release_id=$(generate_release_id)
    
    local release_dir="${app_root}/releases/${release_id}"
    
    log_info "Preparing release: $release_id"
    
    # Create release directory
    mkdir -p "$release_dir" || {
        log_error "Cannot create release directory: $release_dir"
        return 1
    }
    
    # Copy or extract files
    if [[ -d "$source_path" ]]; then
        # Source = directory
        log_info "Copying files from: $source_path"
        rsync -av --progress "$source_path/" "$release_dir/" || {
            log_error "Error copying files"
            rm -rf "$release_dir"
            return 1
        }
    elif [[ -f "$source_path" ]]; then
        # Source = archive
        log_info "Extracting archive: $source_path"
        
        case "$source_path" in
            *.tar.gz|*.tgz)
                tar -xzf "$source_path" -C "$release_dir" || return 1
                ;;
            *.tar.bz2)
                tar -xjf "$source_path" -C "$release_dir" || return 1
                ;;
            *.zip)
                unzip -q "$source_path" -d "$release_dir" || return 1
                ;;
            *)
                log_error "Unknown archive format: $source_path"
                return 1
                ;;
        esac
    else
        log_error "Source does not exist: $source_path"
        return 1
    fi
    
    # Create symlinks to shared directories
    setup_shared_links "$release_dir" "$app_root"
    
    # Generate release metadata
    create_release_metadata "$release_dir" "$release_id" "$source_path"
    
    # Set permissions
    local app_user app_group
    app_user=$(get_config "app_user" "www-data")
    app_group=$(get_config "app_group" "www-data")
    
    chown -R "${app_user}:${app_group}" "$release_dir" 2>/dev/null || \
        log_warning "Cannot change owner for release"
    
    echo "$release_id"
    return 0
}

generate_release_id() {
    date '+%Y%m%d_%H%M%S'
}

setup_shared_links() {
    local release_dir="$1"
    local app_root="$2"
    local shared_dir="${app_root}/shared"
    
    # List of shared directories and files
    local -a shared_dirs
    IFS=',' read -ra shared_dirs <<< "$(get_config 'shared_dirs' 'logs,uploads,cache')"
    
    local -a shared_files
    IFS=',' read -ra shared_files <<< "$(get_config 'shared_files' '')"
    
    # Create symlinks for shared directories
    for dir in "${shared_dirs[@]}"; do
        [[ -z "$dir" ]] && continue
        
        local target="${shared_dir}/${dir}"
        local link="${release_dir}/${dir}"
        
        # Create shared directory if it doesn't exist
        mkdir -p "$target"
        
        # Delete directory from release if it exists
        [[ -d "$link" ]] && rm -rf "$link"
        
        # Create symlink
        ln -sf "$target" "$link"
        log_debug "Symlink: $link -> $target"
    done
    
    # Symlinks for files
    for file in "${shared_files[@]}"; do
        [[ -z "$file" ]] && continue
        
        local target="${shared_dir}/${file}"
        local link="${release_dir}/${file}"
        
        if [[ -f "$target" ]]; then
            mkdir -p "$(dirname "$link")"
            ln -sf "$target" "$link"
        fi
    done
}

create_release_metadata() {
    local release_dir="$1"
    local release_id="$2"
    local source="$3"
    
    local meta_file="${release_dir}/.release_meta"
    
    cat > "$meta_file" <<EOF
{
    "release_id": "$release_id",
    "timestamp": "$(date -Iseconds)",
    "source": "$source",
    "deployed_by": "$(whoami)",
    "hostname": "$(hostname -f 2>/dev/null || hostname)",
    "git_commit": "$(get_git_commit "$source" 2>/dev/null || echo "N/A")",
    "git_branch": "$(get_git_branch "$source" 2>/dev/null || echo "N/A")"
}
EOF
}

get_git_commit() {
    local dir="$1"
    [[ -d "${dir}/.git" ]] && git -C "$dir" rev-parse --short HEAD
}

get_git_branch() {
    local dir="$1"
    [[ -d "${dir}/.git" ]] && git -C "$dir" rev-parse --abbrev-ref HEAD
}
```

### 4.2 The activate_release() Function

```bash
activate_release() {
    local release_id="$1"
    local app_root="$2"
    
    local release_dir="${app_root}/releases/${release_id}"
    local current_link="${app_root}/current"
    
    # Verify that release exists
    if [[ ! -d "$release_dir" ]]; then
        log_error "Release does not exist: $release_id"
        return 1
    fi
    
    log_info "Activating release: $release_id"
    
    # Save current release for rollback
    if [[ -L "$current_link" ]]; then
        local previous_release
        previous_release=$(readlink -f "$current_link")
        
        echo "$(basename "$previous_release")" > "${app_root}/.deploy_state/rollback_point"
        log_info "Rollback point saved: $(basename "$previous_release")"
    fi
    
    # Execute pre_activate hook
    run_hook "pre_activate" "$release_dir" || {
        log_error "Pre-activate hook failed!"
        return 1
    }
    
    # Perform atomic switch using temporary symlink
    local temp_link="${current_link}.new"
    
    # Create temporary symlink
    ln -sf "$release_dir" "$temp_link" || {
        log_error "Cannot create temporary symlink"
        return 1
    }
    
    # Atomic rename (this is the critical operation)
    mv -Tf "$temp_link" "$current_link" || {
        log_error "Cannot activate release (atomic switch failed)"
        rm -f "$temp_link"
        return 1
    }
    
    log_info "Symlink updated: current -> $release_id"
    
    # Execute post_activate hook
    run_hook "post_activate" "$release_dir"
    
    # Reload/restart service if needed
    local restart_service
    restart_service=$(get_config "restart_service" "")
    
    if [[ -n "$restart_service" ]]; then
        restart_application_service "$restart_service"
    fi
    
    # Update deployment state
    update_deploy_state "$app_root" "$release_id" "deployed"
    
    return 0
}

restart_application_service() {
    local service="$1"
    local method
    method=$(get_config "service_manager" "systemd")
    
    log_info "Restart service: $service (via $method)"
    
    case "$method" in
        systemd)
            systemctl restart "$service" || {
                log_warning "Systemd restart failed, trying reload"
                systemctl reload "$service" || return 1
            }
            ;;
        docker)
            local container
            container=$(get_config "docker_container" "$service")
            docker restart "$container" || return 1
            ;;
        supervisor)
            supervisorctl restart "$service" || return 1
            ;;
        script)
            local restart_script
            restart_script=$(get_config "restart_script" "")
            [[ -x "$restart_script" ]] && "$restart_script" || return 1
            ;;
        signal)
            local pid_file signal
            pid_file=$(get_config "pid_file" "")
            signal=$(get_config "reload_signal" "HUP")
            
            if [[ -f "$pid_file" ]]; then
                kill -"$signal" "$(cat "$pid_file")" || return 1
            fi
            ;;
        *)
            log_warning "Unknown restart method: $method"
            return 0
            ;;
    esac
    
    log_info "Service restarted successfully"
    return 0
}
```

### 4.3 Deployment Strategies Implementation

```bash
deploy_rolling() {
    local source_path="$1"
    local app_root="$2"
    local -a instances=("${@:3}")
    
    local total="${#instances[@]}"
    local batch_size
    batch_size=$(get_config "rolling_batch_size" "1")
    
    log_info "Rolling deployment: $total instances, batch size: $batch_size"
    
    local deployed=0
    local failed=0
    
    for ((i=0; i<total; i+=batch_size)); do
        local batch=("${instances[@]:i:batch_size}")
        
        log_info "Processing batch $((i/batch_size + 1)): ${batch[*]}"
        
        for instance in "${batch[@]}"; do
            log_info "Deploy on instance: $instance"
            
            # Deploy on this instance
            if deploy_to_instance "$source_path" "$instance"; then
                ((deployed++))
                
                # Health check
                if ! health_check_instance "$instance"; then
                    log_error "Health check failed for: $instance"
                    
                    # Rollback on this instance
                    rollback_instance "$instance"
                    ((failed++))
                    
                    # Check if we should stop
                    local max_failures
                    max_failures=$(get_config "max_rolling_failures" "1")
                    
                    if [[ $failed -ge $max_failures ]]; then
                        log_error "Too many failures ($failed), stopping deployment"
                        return 1
                    fi
                fi
            else
                log_error "Deploy failed on: $instance"
                ((failed++))
            fi
        done
        
        # Pause between batches
        local batch_delay
        batch_delay=$(get_config "rolling_batch_delay" "5")
        
        if [[ $i + $batch_size -lt $total ]]; then
            log_info "Waiting $batch_delay seconds before next batch..."
            sleep "$batch_delay"
        fi
    done
    
    log_info "Rolling deployment complete: $deployed success, $failed failures"
    
    [[ $failed -eq 0 ]]
}

deploy_blue_green() {
    local source_path="$1"
    local app_root="$2"
    
    local blue_dir="${app_root}/blue"
    local green_dir="${app_root}/green"
    local active_link="${app_root}/active"
    
    # Determine which is active and which is standby
    local active standby
    if [[ -L "$active_link" ]]; then
        active=$(readlink -f "$active_link")
        if [[ "$active" == "$blue_dir" ]]; then
            standby="$green_dir"
        else
            standby="$blue_dir"
        fi
    else
        # First installation
        active=""
        standby="$blue_dir"
    fi
    
    log_info "Blue-Green deployment"
    log_info "  Active: ${active:-none}"
    log_info "  Standby (target): $standby"
    
    # Prepare new release in standby
    log_info "Preparing release in standby environment..."
    
    # Clean standby
    rm -rf "${standby:?}/"*
    
    # Copy new release
    if [[ -d "$source_path" ]]; then
        rsync -av "$source_path/" "$standby/"
    else
        tar -xzf "$source_path" -C "$standby/"
    fi
    
    # Setup shared links
    setup_shared_links "$standby" "$app_root"
    
    # Execute hooks and build
    run_hook "pre_deploy" "$standby"
    
    # Health check on standby (before switch)
    log_info "Verifying health check on standby..."
    
    local standby_port
    standby_port=$(get_config "standby_port" "8081")
    
    # Temporarily start application on standby for test
    start_standby_instance "$standby" "$standby_port"
    
    if ! health_check "http://localhost:${standby_port}" "30"; then
        log_error "Health check failed on standby!"
        stop_standby_instance "$standby"
        return 1
    fi
    
    stop_standby_instance "$standby"
    log_info "Health check OK on standby"
    
    # The actual switch
    log_info "Performing blue-green switch..."
    
    # Atomic symlink switch
    local temp_link="${active_link}.new"
    ln -sf "$standby" "$temp_link"
    mv -Tf "$temp_link" "$active_link"
    
    # Reload load balancer or reverse proxy
    reload_load_balancer
    
    # Health check post-switch
    if ! health_check "$(get_config 'app_url' 'http://localhost')" "60"; then
        log_error "Health check post-switch failed! Rollback..."
        
        # Quick rollback
        ln -sf "$active" "$temp_link"
        mv -Tf "$temp_link" "$active_link"
        reload_load_balancer
        
        return 1
    fi
    
    run_hook "post_deploy" "$standby"
    
    log_info "Blue-Green deployment complete!"
    log_info "New active: $standby"
    
    return 0
}

deploy_canary() {
    local source_path="$1"
    local app_root="$2"
    
    log_info "Canary deployment"
    
    # Canary configuration
    local canary_percent_start canary_percent_end canary_step canary_interval
    canary_percent_start=$(get_config "canary_initial_percent" "5")
    canary_percent_end=$(get_config "canary_final_percent" "100")
    canary_step=$(get_config "canary_step_percent" "10")
    canary_interval=$(get_config "canary_step_interval" "60")
    
    # Prepare canary release
    local release_id
    release_id=$(prepare_release "$source_path" "$app_root")
    
    if [[ -z "$release_id" ]]; then
        log_error "Release preparation failed"
        return 1
    fi
    
    local release_dir="${app_root}/releases/${release_id}"
    
    # Start canary instance
    log_info "Starting canary instance..."
    start_canary_instance "$release_dir"
    
    # Configure initial traffic
    set_canary_weight "$canary_percent_start"
    
    log_info "Canary deployment started with ${canary_percent_start}% traffic"
    
    local current_percent=$canary_percent_start
    
    while [[ $current_percent -lt $canary_percent_end ]]; do
        log_info "Canary at ${current_percent}%, monitoring..."
        
        # Monitor for canary_interval seconds
        if ! monitor_canary "$canary_interval"; then
            log_error "Anomalies detected in canary! Rollback..."
            
            set_canary_weight 0
            stop_canary_instance
            cleanup_failed_release "$release_dir"
            
            return 1
        fi
        
        # Increase percentage
        current_percent=$((current_percent + canary_step))
        if [[ $current_percent -gt $canary_percent_end ]]; then
            current_percent=$canary_percent_end
        fi
        
        log_info "Increasing canary to ${current_percent}%"
        set_canary_weight "$current_percent"
    done
    
    # Finalisation - canary becomes production
    log_info "Canary promoted to production"
    
    promote_canary_to_production "$release_id" "$app_root"
    
    run_hook "post_deploy" "$release_dir"
    
    log_info "Canary deployment complete!"
    return 0
}

monitor_canary() {
    local duration="${1:-60}"
    local check_interval="${2:-10}"
    local error_threshold
    error_threshold=$(get_config "canary_error_threshold" "5")
    
    local start_time end_time errors=0
    start_time=$(date +%s)
    end_time=$((start_time + duration))
    
    while [[ $(date +%s) -lt $end_time ]]; do
        # Collect metrics
        local error_rate latency_p99
        
        error_rate=$(get_canary_error_rate)
        latency_p99=$(get_canary_latency)
        
        log_debug "Canary metrics: errors=${error_rate}%, latency_p99=${latency_p99}ms"
        
        # Verify thresholds
        if (( $(echo "$error_rate > $error_threshold" | bc -l) )); then
            log_warning "High error rate: ${error_rate}%"
            ((errors++))
        fi
        
        local latency_threshold
        latency_threshold=$(get_config "canary_latency_threshold" "500")
        
        if [[ $latency_p99 -gt $latency_threshold ]]; then
            log_warning "High latency: ${latency_p99}ms"
            ((errors++))
        fi
        
        # If we have consecutive errors, abort
        if [[ $errors -ge 3 ]]; then
            log_error "Too many consecutive errors in canary"
            return 1
        fi
        
        sleep "$check_interval"
    done
    
    return 0
}
```

---

## 5. Health Checks System

### 5.1 Health Checks Implementation

```bash
health_check() {
    local target="$1"
    local timeout="${2:-30}"
    local method="${3:-auto}"
    
    log_info "Health check: $target (timeout: ${timeout}s)"
    
    # Auto-detect method
    if [[ "$method" == "auto" ]]; then
        case "$target" in
            http://*|https://*)  method="http" ;;
            tcp://*)             method="tcp" ;;
            pid://*)             method="process" ;;
            cmd://*)             method="command" ;;
            *)                   method="http" ;;
        esac
    fi
    
    local start_time elapsed result=1
    start_time=$(date +%s)
    
    while [[ $(($(date +%s) - start_time)) -lt $timeout ]]; do
        case "$method" in
            http)
                check_http "$target" && result=0 && break
                ;;
            tcp)
                check_tcp "$target" && result=0 && break
                ;;
            process)
                check_process "$target" && result=0 && break
                ;;
            command)
                check_command "$target" && result=0 && break
                ;;
        esac
        
        elapsed=$(($(date +%s) - start_time))
        log_debug "Health check attempt failed, elapsed: ${elapsed}s"
        
        sleep 2
    done
    
    if [[ $result -eq 0 ]]; then
        log_info "Health check OK (${elapsed}s)"
    else
        log_error "Health check FAILED (timeout: ${timeout}s)"
    fi
    
    return $result
}

check_http() {
    local url="$1"
    local expected_code="${2:-200}"
    local timeout="${3:-5}"
    
    # Remove http:// prefix for logging
    local display_url="${url#http://}"
    display_url="${display_url#https://}"
    
    log_debug "HTTP check: $display_url"
    
    local response_code
    response_code=$(curl -s -o /dev/null -w "%{http_code}" \
        --connect-timeout "$timeout" \
        --max-time "$((timeout * 2))" \
        "$url" 2>/dev/null)
    
    log_debug "HTTP response: $response_code (expected: $expected_code)"
    
    # Verify response code
    if [[ "$response_code" == "$expected_code" ]]; then
        return 0
    fi
    
    # Also accept other success codes
    case "$response_code" in
        200|201|202|204|301|302)
            return 0
            ;;
    esac
    
    return 1
}

check_tcp() {
    local target="$1"
    local timeout="${2:-5}"
    
    # Parse target: tcp://host:port or just host:port
    target="${target#tcp://}"
    
    local host port
    host="${target%:*}"
    port="${target#*:}"
    
    log_debug "TCP check: $host:$port"
    
    # Use nc or /dev/tcp
    if command -v nc &>/dev/null; then
        nc -z -w "$timeout" "$host" "$port" 2>/dev/null
    else
        # Fallback to /dev/tcp (bash built-in)
        timeout "$timeout" bash -c "echo >/dev/tcp/$host/$port" 2>/dev/null
    fi
}

check_process() {
    local target="$1"
    
    # Parse target: pid://1234 or pid://name:nginx
    target="${target#pid://}"
    
    if [[ "$target" =~ ^[0-9]+$ ]]; then
        # Numeric PID
        log_debug "Process check: PID $target"
        kill -0 "$target" 2>/dev/null
    else
        # Process name
        local process_name="${target#name:}"
        log_debug "Process check: name=$process_name"
        pgrep -x "$process_name" >/dev/null 2>&1
    fi
}

check_command() {
    local target="$1"
    local timeout="${2:-10}"
    
    # Parse target: cmd://command args
    local command="${target#cmd://}"
    
    log_debug "Command check: $command"
    
    timeout "$timeout" bash -c "$command" >/dev/null 2>&1
}

# Complex health check with retry and logging
advanced_health_check() {
    local -a checks=("$@")
    local all_passed=true
    
    log_info "Executing ${#checks[@]} health check(s)"
    
    for check in "${checks[@]}"; do
        # Format: type:target:timeout
        IFS=':' read -r type target check_timeout <<< "$check"
        
        check_timeout="${check_timeout:-30}"
        
        case "$type" in
            http)
                if check_http "$target" 200 "$check_timeout"; then
                    log_info "  ✓ HTTP $target"
                else
                    log_error "  ✗ HTTP $target"
                    all_passed=false
                fi
                ;;
            tcp)
                if check_tcp "$target" "$check_timeout"; then
                    log_info "  ✓ TCP $target"
                else
                    log_error "  ✗ TCP $target"
                    all_passed=false
                fi
                ;;
            process)
                if check_process "pid://$target"; then
                    log_info "  ✓ Process $target"
                else
                    log_error "  ✗ Process $target"
                    all_passed=false
                fi
                ;;
            command)
                if check_command "cmd://$target" "$check_timeout"; then
                    log_info "  ✓ Command: $target"
                else
                    log_error "  ✗ Command: $target"
                    all_passed=false
                fi
                ;;
        esac
    done
    
    $all_passed
}
```

---

## 6. Hooks System

### 6.1 Hooks Implementation

```bash
# Variable for tracking hooks
declare -A HOOK_RESULTS

run_hook() {
    local hook_name="$1"
    local release_dir="$2"
    shift 2
    local -a hook_args=("$@")
    
    log_debug "Searching hook: $hook_name"
    
    # Search for hook in multiple locations
    local -a hook_locations=(
        "${release_dir}/deploy/hooks/${hook_name}"
        "${release_dir}/deploy/hooks/${hook_name}.sh"
        "${release_dir}/.deploy/${hook_name}"
        "$(get_config "${hook_name}_hook" "")"
    )
    
    local hook_script=""
    for location in "${hook_locations[@]}"; do
        [[ -z "$location" ]] && continue
        
        if [[ -f "$location" && -x "$location" ]]; then
            hook_script="$location"
            break
        fi
    done
    
    if [[ -z "$hook_script" ]]; then
        log_debug "Hook '$hook_name' not found"
        return 0
    fi
    
    log_info "Executing hook: $hook_name"
    log_debug "  Script: $hook_script"
    
    # Prepare environment for hook
    export DEPLOY_HOOK_NAME="$hook_name"
    export DEPLOY_RELEASE_DIR="$release_dir"
    export DEPLOY_APP_ROOT="$(dirname "$(dirname "$release_dir")")"
    export DEPLOY_TIMESTAMP="$(date -Iseconds)"
    export DEPLOY_RELEASE_ID="$(basename "$release_dir")"
    
    # Execute hook with timeout
    local hook_timeout
    hook_timeout=$(get_config "hook_timeout" "300")
    
    local start_time exit_code output
    start_time=$(date +%s)
    
    output=$(timeout "$hook_timeout" "$hook_script" "${hook_args[@]}" 2>&1)
    exit_code=$?
    
    local duration=$(($(date +%s) - start_time))
    
    # Save result
    HOOK_RESULTS["$hook_name"]="$exit_code"
    
    if [[ $exit_code -eq 0 ]]; then
        log_info "Hook '$hook_name' completed in ${duration}s"
        log_debug "Output: $output"
        return 0
    elif [[ $exit_code -eq 124 ]]; then
        log_error "Hook '$hook_name' timeout after ${hook_timeout}s"
        return 1
    else
        log_error "Hook '$hook_name' failed (exit code: $exit_code)"
        log_error "Output: $output"
        return 1
    fi
}

# Standard hooks for deployment
run_deploy_hooks_sequence() {
    local release_dir="$1"
    local phase="${2:-full}"  # full, pre_only, post_only
    
    local hooks_failed=0
    
    # Pre-deployment hooks
    if [[ "$phase" == "full" || "$phase" == "pre_only" ]]; then
        local -a pre_hooks=(
            "pre_deploy"
            "check_dependencies"
            "pre_build"
        )
        
        for hook in "${pre_hooks[@]}"; do
            if ! run_hook "$hook" "$release_dir"; then
                log_error "Pre-deployment hook failed: $hook"
                ((hooks_failed++))
                
                # Abort if critical hook fails
                if [[ "$hook" == "pre_deploy" ]]; then
                    return 1
                fi
            fi
        done
    fi
    
    # Build hooks
    if [[ "$phase" == "full" ]]; then
        run_hook "build" "$release_dir" || {
            log_error "Build failed!"
            return 1
        }
    fi
    
    # Post-deployment hooks
    if [[ "$phase" == "full" || "$phase" == "post_only" ]]; then
        local -a post_hooks=(
            "post_deploy"
            "post_activate"
            "notify"
        )
        
        for hook in "${post_hooks[@]}"; do
            run_hook "$hook" "$release_dir" || {
                log_warning "Post-deployment hook failed: $hook"
                ((hooks_failed++))
            }
        done
    fi
    
    [[ $hooks_failed -eq 0 ]]
}
```

### 6.2 Hook Script Examples

```bash
# hooks/pre_deploy.sh - Checks before deployment
#!/usr/bin/env bash
set -e

echo "=== Pre-Deploy Hook ==="
echo "Release: $DEPLOY_RELEASE_ID"
echo "Directory: $DEPLOY_RELEASE_DIR"

# Verify we have all required files
required_files=("index.php" "config/app.php" "composer.json")

for file in "${required_files[@]}"; do
    if [[ ! -f "${DEPLOY_RELEASE_DIR}/${file}" ]]; then
        echo "ERROR: Missing file: $file"
        exit 1
    fi
done

# Verify permissions
echo "Checking permissions..."
chmod -R 755 "${DEPLOY_RELEASE_DIR}"
chmod -R 777 "${DEPLOY_RELEASE_DIR}/storage" 2>/dev/null || true
chmod -R 777 "${DEPLOY_RELEASE_DIR}/cache" 2>/dev/null || true

echo "Pre-deploy OK"
exit 0
```

```bash
# hooks/build.sh - Build and dependency installation
#!/usr/bin/env bash
set -e

cd "$DEPLOY_RELEASE_DIR"

echo "=== Build Hook ==="

# Composer for PHP
if [[ -f "composer.json" ]]; then
    echo "Installing Composer dependencies..."
    composer install --no-dev --optimize-autoloader --no-interaction
fi

# NPM for JavaScript
if [[ -f "package.json" ]]; then
    echo "Installing NPM dependencies..."
    npm ci --production
    
    if [[ -f "webpack.config.js" ]]; then
        echo "Building assets..."
        npm run build
    fi
fi

# Python
if [[ -f "requirements.txt" ]]; then
    echo "Installing Python dependencies..."
    pip install -r requirements.txt --quiet
fi

echo "Build completed"
exit 0
```

```bash
# hooks/post_deploy.sh - Actions after deployment
#!/usr/bin/env bash
set -e

cd "$DEPLOY_RELEASE_DIR"

echo "=== Post-Deploy Hook ==="

# Database migrations
if [[ -f "artisan" ]]; then
    echo "Running Laravel migrations..."
    php artisan migrate --force
    php artisan config:cache
    php artisan route:cache
    php artisan view:cache
fi

# Clear cache
if [[ -d "cache" ]]; then
    echo "Clearing cache..."
    rm -rf cache/*
fi

# Notify external services
if [[ -n "$SLACK_WEBHOOK" ]]; then
    curl -s -X POST "$SLACK_WEBHOOK" \
        -H "Content-Type: application/json" \
        -d "{\"text\": \"Deployment complete: $DEPLOY_RELEASE_ID\"}"
fi

echo "Post-deploy completed"
exit 0
```

---

## 7. Rollback and Recovery

### 7.1 Rollback Implementation

```bash
rollback() {
    local app_root="$1"
    local target="${2:-}"  # Specific Release ID or empty for last
    
    log_info "Initiating rollback..."
    
    local current_link="${app_root}/current"
    local state_dir="${app_root}/.deploy_state"
    
    # Determine release for rollback
    local rollback_release
    
    if [[ -n "$target" ]]; then
        # Specific target
        rollback_release="$target"
        
        if [[ ! -d "${app_root}/releases/${rollback_release}" ]]; then
            log_error "Rollback release does not exist: $rollback_release"
            return 1
        fi
    else
        # Use saved rollback point
        if [[ -f "${state_dir}/rollback_point" ]]; then
            rollback_release=$(cat "${state_dir}/rollback_point")
        else
            # Find second-to-last release
            rollback_release=$(ls -1 "${app_root}/releases" | sort -r | sed -n '2p')
        fi
    fi
    
    if [[ -z "$rollback_release" ]]; then
        log_error "No release available for rollback!"
        return 1
    fi
    
    local rollback_dir="${app_root}/releases/${rollback_release}"
    
    if [[ ! -d "$rollback_dir" ]]; then
        log_error "Rollback directory does not exist: $rollback_dir"
        return 1
    fi
    
    log_info "Rolling back to: $rollback_release"
    
    # Execute pre_rollback hook
    run_hook "pre_rollback" "$rollback_dir" || {
        log_warning "Pre-rollback hook failed, continuing..."
    }
    
    # Save current release (for a possible roll-forward)
    local current_release
    if [[ -L "$current_link" ]]; then
        current_release=$(basename "$(readlink -f "$current_link")")
        echo "$current_release" > "${state_dir}/pre_rollback_release"
    fi
    
    # Perform the switch
    local temp_link="${current_link}.rollback"
    ln -sf "$rollback_dir" "$temp_link"
    mv -Tf "$temp_link" "$current_link"
    
    log_info "Symlink updated for rollback"
    
    # Restart service
    local restart_service
    restart_service=$(get_config "restart_service" "")
    
    if [[ -n "$restart_service" ]]; then
        restart_application_service "$restart_service" || {
            log_error "Service restart failed after rollback!"
        }
    fi
    
    # Health check post-rollback
    local app_url
    app_url=$(get_config "app_url" "http://localhost")
    
    if ! health_check "$app_url" "60"; then
        log_critical "Health check failed after rollback!"
        log_critical "Manual intervention required!"
        
        run_hook "on_failure" "$rollback_dir"
        
        return 1
    fi
    
    # Execute post_rollback hook
    run_hook "post_rollback" "$rollback_dir"
    run_hook "on_rollback" "$rollback_dir" "$current_release" "$rollback_release"
    
    # Update state
    update_deploy_state "$app_root" "$rollback_release" "rolled_back"
    
    log_info "Rollback complete to: $rollback_release"
    
    return 0
}

# Automatic rollback on failure
auto_rollback_on_failure() {
    local app_root="$1"
    local failed_release="$2"
    
    log_warning "Auto-rollback activated for: $failed_release"
    
    # Check if auto-rollback is enabled
    if [[ "$(get_config 'auto_rollback' 'true')" != "true" ]]; then
        log_info "Auto-rollback disabled, ignoring"
        return 0
    fi
    
    # Execute rollback
    if rollback "$app_root"; then
        log_info "Auto-rollback successful"
        
        # Notification
        send_notification "warning" "Auto-rollback executed for $failed_release"
        
        return 0
    else
        log_critical "Auto-rollback FAILED!"
        
        send_notification "critical" "Auto-rollback failed! Intervention required!"
        
        return 1
    fi
}

# Cleanup failed release
cleanup_failed_release() {
    local release_dir="$1"
    local keep_for_debug="${2:-false}"
    
    if [[ "$keep_for_debug" == "true" ]]; then
        local failed_dir="${release_dir}.failed"
        mv "$release_dir" "$failed_dir"
        log_info "Failed release saved for debug: $failed_dir"
    else
        rm -rf "$release_dir"
        log_info "Failed release deleted: $release_dir"
    fi
}
```

### 7.2 Cleanup and Maintenance

```bash
cleanup_old_releases() {
    local app_root="$1"
    local keep="${2:-5}"
    
    local releases_dir="${app_root}/releases"
    
    [[ ! -d "$releases_dir" ]] && return 0
    
    log_info "Cleanup: keeping last $keep releases"
    
    # Get current release
    local current_release=""
    if [[ -L "${app_root}/current" ]]; then
        current_release=$(basename "$(readlink -f "${app_root}/current")")
    fi
    
    # List and sort releases (oldest first)
    local -a all_releases
    mapfile -t all_releases < <(ls -1 "$releases_dir" | sort)
    
    local total="${#all_releases[@]}"
    
    if [[ $total -le $keep ]]; then
        log_info "Only $total releases, nothing to delete"
        return 0
    fi
    
    local to_delete=$((total - keep))
    local deleted=0
    
    for release in "${all_releases[@]}"; do
        [[ $deleted -ge $to_delete ]] && break
        
        # Don't delete current release
        if [[ "$release" == "$current_release" ]]; then
            log_debug "Keeping current release: $release"
            continue
        fi
        
        # Don't delete if marked as protected
        if [[ -f "${releases_dir}/${release}/.protected" ]]; then
            log_debug "Keeping protected release: $release"
            continue
        fi
        
        log_info "Deleting old release: $release"
        rm -rf "${releases_dir:?}/${release}"
        ((deleted++))
    done
    
    log_info "Cleanup complete: $deleted releases deleted"
}

# Verify and repair state
verify_deployment_state() {
    local app_root="$1"
    
    local issues=0
    
    # Verify current symlink
    if [[ ! -L "${app_root}/current" ]]; then
        log_error "Symlink 'current' missing!"
        ((issues++))
    elif [[ ! -d "$(readlink -f "${app_root}/current")" ]]; then
        log_error "Symlink 'current' points to non-existent directory!"
        ((issues++))
    fi
    
    # Verify releases directory
    if [[ ! -d "${app_root}/releases" ]]; then
        log_error "Directory 'releases' missing!"
        ((issues++))
    fi
    
    # Verify shared directory
    if [[ ! -d "${app_root}/shared" ]]; then
        log_warning "Directory 'shared' missing"
        mkdir -p "${app_root}/shared"
    fi
    
    # Verify permissions
    local app_user
    app_user=$(get_config "app_user" "www-data")
    
    if ! stat -c %U "${app_root}/current" 2>/dev/null | grep -q "$app_user"; then
        log_warning "Incorrect permissions for current directory"
    fi
    
    echo "$issues"
}
```

---

## 8. Manifest-based Deployment

### 8.1 YAML Manifest Structure

```yaml
# deploy.yml - Deployment manifest
name: my-application
version: "1.2.3"

# Code source
source:
  type: git
  url: git@github.com:org/repo.git
  branch: main
  # or for archive:
  # type: archive
  # url: https://releases.example.com/app-1.2.3.tar.gz

# Deployment configuration
deployment:
  strategy: rolling  # rolling, blue-green, canary
  app_root: /var/www/myapp
  keep_releases: 5
  
  # For rolling
  rolling:
    batch_size: 1
    batch_delay: 10
    
  # For canary
  canary:
    initial_percent: 5
    step_percent: 10
    step_interval: 60

# Health checks
health_checks:

- `type: http`
- `type: tcp`
- `type: command`


# Hooks
hooks:
  pre_deploy:
    - chmod -R 755 $RELEASE_DIR
    - composer install --no-dev
  build:
    - npm ci
    - npm run build
  post_deploy:
    - php artisan migrate --force
    - php artisan config:cache

# Services
service:
  manager: systemd
  name: myapp
  reload_command: "systemctl reload nginx"

# Notifications
notifications:
  slack:
    webhook: ${SLACK_WEBHOOK}
    channel: "#deployments"
  email:
    recipients:
      - devops@example.com

# Environment
environment:
  APP_ENV: production
  LOG_LEVEL: warning
```

### 8.2 Manifest Parser and Executor

```bash
parse_manifest() {
    local manifest_file="$1"
    
    if [[ ! -f "$manifest_file" ]]; then
        log_error "Manifest does not exist: $manifest_file"
        return 1
    fi
    
    log_info "Parsing manifest: $manifest_file"
    
    # Verify we have YAML parser
    local yaml_parser=""
    if command -v yq &>/dev/null; then
        yaml_parser="yq"
    elif command -v python3 &>/dev/null; then
        yaml_parser="python"
    else
        log_error "No YAML parser found (yq or python)"
        return 1
    fi
    
    # Extract configuration into variables
    case "$yaml_parser" in
        yq)
            MANIFEST_NAME=$(yq -r '.name // "app"' "$manifest_file")
            MANIFEST_VERSION=$(yq -r '.version // "0.0.0"' "$manifest_file")
            MANIFEST_STRATEGY=$(yq -r '.deployment.strategy // "rolling"' "$manifest_file")
            MANIFEST_APP_ROOT=$(yq -r '.deployment.app_root // "/var/www/app"' "$manifest_file")
            MANIFEST_KEEP_RELEASES=$(yq -r '.deployment.keep_releases // 5' "$manifest_file")
            
            # Source
            MANIFEST_SOURCE_TYPE=$(yq -r '.source.type // "git"' "$manifest_file")
            MANIFEST_SOURCE_URL=$(yq -r '.source.url // ""' "$manifest_file")
            MANIFEST_SOURCE_BRANCH=$(yq -r '.source.branch // "main"' "$manifest_file")
            
            # Health checks (array)
            MANIFEST_HEALTH_CHECKS=$(yq -r '.health_checks | length' "$manifest_file")
            ;;
            
        python)
            eval "$(python3 - "$manifest_file" <<'PYTHON'
import sys
import yaml

with open(sys.argv[1]) as f:
    m = yaml.safe_load(f)

print(f"MANIFEST_NAME='{m.get('name', 'app')}'")
print(f"MANIFEST_VERSION='{m.get('version', '0.0.0')}'")
print(f"MANIFEST_STRATEGY='{m.get('deployment', {}).get('strategy', 'rolling')}'")
print(f"MANIFEST_APP_ROOT='{m.get('deployment', {}).get('app_root', '/var/www/app')}'")
print(f"MANIFEST_KEEP_RELEASES={m.get('deployment', {}).get('keep_releases', 5)}")
print(f"MANIFEST_SOURCE_TYPE='{m.get('source', {}).get('type', 'git')}'")
print(f"MANIFEST_SOURCE_URL='{m.get('source', {}).get('url', '')}'")
print(f"MANIFEST_SOURCE_BRANCH='{m.get('source', {}).get('branch', 'main')}'")
PYTHON
            )"
            ;;
    esac
    
    log_info "Manifest parsed:"
    log_info "  Name: $MANIFEST_NAME"
    log_info "  Version: $MANIFEST_VERSION"
    log_info "  Strategy: $MANIFEST_STRATEGY"
    log_info "  App Root: $MANIFEST_APP_ROOT"
    
    return 0
}

execute_manifest_deployment() {
    local manifest_file="$1"
    
    # Parse manifest
    parse_manifest "$manifest_file" || return 1
    
    # Obtain source
    local source_path
    source_path=$(fetch_source) || return 1
    
    # Execute deployment based on strategy
    case "$MANIFEST_STRATEGY" in
        rolling)
            deploy_rolling "$source_path" "$MANIFEST_APP_ROOT"
            ;;
        blue-green)
            deploy_blue_green "$source_path" "$MANIFEST_APP_ROOT"
            ;;
        canary)
            deploy_canary "$source_path" "$MANIFEST_APP_ROOT"
            ;;
        *)
            log_error "Unknown strategy: $MANIFEST_STRATEGY"
            return 1
            ;;
    esac
    
    local result=$?
    
    # Cleanup temporary source
    [[ -d "$source_path" && "$source_path" == /tmp/* ]] && rm -rf "$source_path"
    
    return $result
}

fetch_source() {
    local temp_dir
    temp_dir=$(mktemp -d)
    
    case "$MANIFEST_SOURCE_TYPE" in
        git)
            log_info "Cloning Git repository..."
            git clone --depth 1 --branch "$MANIFEST_SOURCE_BRANCH" \
                "$MANIFEST_SOURCE_URL" "$temp_dir" || {
                log_error "Git clone failed"
                rm -rf "$temp_dir"
                return 1
            }
            ;;
            
        archive)
            log_info "Downloading archive..."
            local archive_file="${temp_dir}/source.tar.gz"
            
            curl -sL "$MANIFEST_SOURCE_URL" -o "$archive_file" || {
                log_error "Archive download failed"
                rm -rf "$temp_dir"
                return 1
            }
            
            tar -xzf "$archive_file" -C "$temp_dir"
            rm "$archive_file"
            ;;
            
        local)
            log_info "Copying from local path..."
            cp -r "$MANIFEST_SOURCE_URL"/* "$temp_dir/"
            ;;
            
        *)
            log_error "Unknown source type: $MANIFEST_SOURCE_TYPE"
            rm -rf "$temp_dir"
            return 1
            ;;
    esac
    
    echo "$temp_dir"
}
```

---

## 9. Implementation Exercises

### Exercise 1: Docker Deployment

```bash
# Implement deployment for Docker containers
deploy_docker_container() {
    local image="$1"
    local container_name="$2"
    local port_mapping="$3"
    
    # TODO: Implement:
    # 1. Pull new image
    # 2. Stop old container
    # 3. Rename for rollback
    # 4. Start new container
    # 5. Health check
    # 6. Cleanup old container if OK
    :
}
```

### Exercise 2: Multi-Environment

```bash
# Implement support for multiple environments
deploy_to_environment() {
    local env="$1"  # dev, staging, production
    local source="$2"
    
    # TODO: Implement:
    # 1. Load environment-specific config
    # 2. Validate source compatibility
    # 3. Deployment with specific settings
    # 4. Differentiated notifications
    :
}
```

### Exercise 3: A/B Testing Deployment

```bash
# Implement deployment for A/B testing
deploy_ab_test() {
    local variant_a="$1"
    local variant_b="$2"
    local traffic_split="$3"  # e.g.: "50:50"
    
    # TODO: Implement:
    # 1. Deploy both variants
    # 2. Configure load balancer for split
    # 3. Monitor metrics per variant
    # 4. Dashboard for comparison
    :
}
```

### Exercise 4: GitOps Integration

```bash
# Implement deployment trigger from Git webhook
handle_git_webhook() {
    local payload="$1"
    
    # TODO: Implement:
    # 1. Parse payload (GitHub/GitLab)
    # 2. Verify branch/tag
    # 3. Trigger automatic deployment
    # 4. Update status in Git
    :
}
```

### Exercise 5: Deployment Metrics

```bash
# Implement metrics collection and reporting
collect_deployment_metrics() {
    local release_id="$1"
    
    # TODO: Implement:
    # 1. Deployment duration
    # 2. Number of errors in first 5 minutes
    # 3. Average latency post-deploy
    # 4. Export to Prometheus/Grafana
    :
}
```

---

## Conclusions

The Deployer project demonstrates the implementation of a complete automated deployment system. Key points:

1. **Multiple Strategies** - support for different deployment scenarios
2. **Safety** - health checks and automatic rollback
3. **Flexibility** - hooks for customisation
4. **Automation** - manifest-based deployment
5. **Observability** - logging and metrics

The system can be extended for:
- Kubernetes integration
- Complete CI/CD pipelines
- Multi-cloud deployment
- Advanced canary analysis with ML
- GitOps and Infrastructure as Code
