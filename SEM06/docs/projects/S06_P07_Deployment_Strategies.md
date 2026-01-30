# S06_07: Deployment Strategies in Detail

## Introduction

Deployment represents the critical moment when developed code crosses the boundary between the development environment and production, becoming accessible to end users. The choice of deployment strategy directly influences service availability, user experience during the update and recovery capability in case of problems.

This chapter comparatively analyses the main deployment strategies, highlighting trade-offs, optimal usage scenarios and implementation details in the context of CAPSTONE projects.

---

## Taxonomy of Deployment Strategies

### Classification by Impact and Risk

```
                        DEPLOYMENT RISK
                              │
         LOW ◄────────────────┼────────────────► HIGH
                              │
    ┌─────────────────────────┼─────────────────────────┐
    │                         │                         │
    │   CANARY               │        ROLLING          │
    │   ────────              │        ──────────       │
    │   • Minimal risk       │        • Moderate risk  │
    │   • Rapid feedback     │        • Zero downtime  │
    │   • Instant rollback   │        • Gradual        │
    │                         │                         │
    │─────────────────────────┼─────────────────────────│
    │                         │                         │
    │   BLUE-GREEN           │       BIG BANG          │
    │   ────────────          │       ──────────        │
    │   • Controlled risk    │        • Maximum risk   │
    │   • Atomic switch      │        • Simple         │
    │   • Double resources   │        • Downtime       │
    │                         │                         │
    └─────────────────────────┴─────────────────────────┘
              LOW                        HIGH
                    INFRASTRUCTURE COMPLEXITY
```

---

## Rolling Deployment Strategy

### Concept

Rolling deployment updates application instances gradually, replacing the old version with the new one at a time (or batch at a time). During deployment, both versions coexist in production.

### Flow Diagram

```
Time ─────────────────────────────────────────────────────►

Instance 1: [████ V1 ████][░░ Update ░░][████ V2 ████████]
Instance 2: [████████ V1 ████████][░░ Update ░░][████ V2 ██]
Instance 3: [████████████ V1 ████████████][░░ Update ░░][V2]
Instance 4: [████████████████ V1 ████████████████][░░░░░░░░]

Load Balancer: ═══════════════════════════════════════════
              Directs traffic only to healthy instances
```

### Deployer Implementation

```bash
#!/bin/bash
#===============================================================================
# rolling_deploy.sh - Rolling Deployment Implementation
#===============================================================================

source "$(dirname "$0")/../lib/deployer_core.sh"
source "$(dirname "$0")/../lib/deployer_utils.sh"

#-------------------------------------------------------------------------------
# Configuration
#-------------------------------------------------------------------------------
declare -g BATCH_SIZE=1
declare -g MAX_UNAVAILABLE=1
declare -g HEALTH_CHECK_RETRIES=3
declare -g HEALTH_CHECK_INTERVAL=10
declare -g DRAIN_TIMEOUT=30

#-------------------------------------------------------------------------------
# Rolling Deployment Core
#-------------------------------------------------------------------------------
deploy_rolling() {
    local release_path="$1"
    local -a instances=("${@:2}")
    
    local total_instances=${#instances[@]}
    local successful=0
    local failed=0
    
    log_info "Starting rolling deployment to $total_instances instances"
    log_info "Batch size: $BATCH_SIZE, Max unavailable: $MAX_UNAVAILABLE"
    
    # Process in batches
    local batch_num=0
    for ((i=0; i<total_instances; i+=BATCH_SIZE)); do
        ((batch_num++))
        local batch_end=$((i + BATCH_SIZE - 1))
        [[ $batch_end -ge $total_instances ]] && batch_end=$((total_instances - 1))
        
        log_info "Processing batch $batch_num: instances $((i+1)) to $((batch_end+1))"
        
        # Process instances in batch
        local batch_success=0
        for ((j=i; j<=batch_end; j++)); do
            local instance="${instances[$j]}"
            
            if deploy_to_instance "$instance" "$release_path"; then
                ((successful++))
                ((batch_success++))
                log_info "Instance $instance updated successfully ($successful/$total_instances)"
            else
                ((failed++))
                log_error "Instance $instance failed to update"
                
                # Verify failure threshold
                if [[ $failed -gt $MAX_UNAVAILABLE ]]; then
                    log_fatal "Too many failures ($failed > $MAX_UNAVAILABLE). Aborting deployment."
                    return 1
                fi
            fi
        done
        
        # Wait for stabilisation before next batch
        if [[ $i + $BATCH_SIZE -lt $total_instances ]]; then
            log_info "Waiting for stabilisation before next batch..."
            sleep "$HEALTH_CHECK_INTERVAL"
        fi
    done
    
    # Final summary
    log_info "Rolling deployment completed: $successful successful, $failed failed"
    
    [[ $failed -eq 0 ]] && return 0 || return 1
}

#-------------------------------------------------------------------------------
# Per-instance Deployment
#-------------------------------------------------------------------------------
deploy_to_instance() {
    local instance="$1"
    local release_path="$2"
    
    log_debug "Deploying to instance: $instance"
    
    # Step 1: Drain - remove instance from load balancer
    log_debug "Draining instance from load balancer..."
    if ! drain_instance "$instance"; then
        log_error "Failed to drain instance $instance"
        return 1
    fi
    
    # Step 2: Wait for in-flight requests to complete
    log_debug "Waiting for in-flight requests..."
    wait_for_drain "$instance" "$DRAIN_TIMEOUT"
    
    # Step 3: Stop application
    log_debug "Stopping application..."
    if ! stop_application "$instance"; then
        log_warn "Failed to stop gracefully, forcing..."
        force_stop_application "$instance"
    fi
    
    # Step 4: Deploy new version
    log_debug "Deploying new release..."
    if ! sync_release "$instance" "$release_path"; then
        log_error "Failed to sync release to $instance"
        # Rollback to previous version
        restore_previous_version "$instance"
        enable_instance "$instance"
        return 1
    fi
    
    # Step 5: Start application
    log_debug "Starting application..."
    if ! start_application "$instance"; then
        log_error "Failed to start application on $instance"
        restore_previous_version "$instance"
        enable_instance "$instance"
        return 1
    fi
    
    # Step 6: Health check
    log_debug "Performing health checks..."
    if ! wait_for_healthy "$instance" "$HEALTH_CHECK_RETRIES" "$HEALTH_CHECK_INTERVAL"; then
        log_error "Health check failed for $instance"
        restore_previous_version "$instance"
        start_application "$instance"
        enable_instance "$instance"
        return 1
    fi
    
    # Step 7: Re-enable in load balancer
    log_debug "Re-enabling instance in load balancer..."
    if ! enable_instance "$instance"; then
        log_error "Failed to re-enable $instance"
        return 1
    fi
    
    log_info "Instance $instance successfully updated"
    return 0
}

#-------------------------------------------------------------------------------
# Load Balancer Helper Functions
#-------------------------------------------------------------------------------
drain_instance() {
    local instance="$1"
    
    # Example for HAProxy via socket
    if [[ -S "/var/run/haproxy/admin.sock" ]]; then
        echo "set server backend/$instance state drain" | \
            socat stdio /var/run/haproxy/admin.sock
        return $?
    fi
    
    # Example for nginx upstream
    if [[ -f "/etc/nginx/conf.d/upstream.conf" ]]; then
        sed -i "s/server ${instance}/server ${instance} down/" \
            /etc/nginx/conf.d/upstream.conf
        nginx -s reload
        return $?
    fi
    
    log_warn "No load balancer detected, skipping drain"
    return 0
}

enable_instance() {
    local instance="$1"
    
    if [[ -S "/var/run/haproxy/admin.sock" ]]; then
        echo "set server backend/$instance state ready" | \
            socat stdio /var/run/haproxy/admin.sock
        return $?
    fi
    
    if [[ -f "/etc/nginx/conf.d/upstream.conf" ]]; then
        sed -i "s/server ${instance} down/server ${instance}/" \
            /etc/nginx/conf.d/upstream.conf
        nginx -s reload
        return $?
    fi
    
    return 0
}

wait_for_drain() {
    local instance="$1"
    local timeout="$2"
    
    local elapsed=0
    while [[ $elapsed -lt $timeout ]]; do
        local connections
        connections=$(get_active_connections "$instance")
        
        if [[ $connections -eq 0 ]]; then
            log_debug "Instance $instance fully drained"
            return 0
        fi
        
        log_debug "Waiting for $connections connections to close..."
        sleep 2
        ((elapsed += 2))
    done
    
    log_warn "Drain timeout reached, proceeding anyway"
    return 0
}

#-------------------------------------------------------------------------------
# Sync and Application Control
#-------------------------------------------------------------------------------
sync_release() {
    local instance="$1"
    local release_path="$2"
    
    # For local deploy
    if [[ "$instance" == "localhost" || "$instance" == "127.0.0.1" ]]; then
        cp -r "$release_path"/* "$DEPLOY_PATH/"
        return $?
    fi
    
    # For remote deploy via rsync
    rsync -avz --delete \
        --exclude='.git' \
        --exclude='*.log' \
        --exclude='tmp/*' \
        "$release_path/" \
        "${DEPLOY_USER}@${instance}:${DEPLOY_PATH}/"
    
    return $?
}

stop_application() {
    local instance="$1"
    
    run_on_instance "$instance" "systemctl stop ${APP_SERVICE}"
}

start_application() {
    local instance="$1"
    
    run_on_instance "$instance" "systemctl start ${APP_SERVICE}"
}

force_stop_application() {
    local instance="$1"
    
    run_on_instance "$instance" "systemctl kill -s KILL ${APP_SERVICE}"
}

run_on_instance() {
    local instance="$1"
    shift
    local command="$*"
    
    if [[ "$instance" == "localhost" || "$instance" == "127.0.0.1" ]]; then
        eval "$command"
    else
        ssh "${DEPLOY_USER}@${instance}" "$command"
    fi
}
```

### Strengths and Weaknesses

| Strengths | Weaknesses |
|-----------|------------|
| Zero downtime | Mixed versions in production |
| Partial rollback possible | Slower deployment |
| Efficient resources | Complexity in tracking |
| Progressive validation | Requires backward compatibility |

---

## Blue-Green Deployment Strategy

### Concept

Blue-Green maintains two identical production environments (Blue and Green). At any given moment, one serves live traffic (e.g., Blue) whilst the other (Green) is inactive or used for preparing the new version. Deployment consists of the atomic switch of traffic.

### Flow Diagram

```
                    BEFORE DEPLOYMENT
    ┌─────────────────────────────────────────────────────┐
    │                                                     │
    │    ┌─────────────┐         ┌─────────────┐         │
    │    │   BLUE      │         │   GREEN     │         │
    │    │   (V1)      │         │   (V1)      │         │
    │    │  [ACTIVE]   │         │  [STANDBY]  │         │
    │    └──────┬──────┘         └─────────────┘         │
    │           │                                         │
    │           │ 100% Traffic                           │
    │           ▼                                         │
    │    ┌─────────────┐                                 │
    │    │    USERS    │                                 │
    │    └─────────────┘                                 │
    └─────────────────────────────────────────────────────┘

                    PREPARING DEPLOYMENT
    ┌─────────────────────────────────────────────────────┐
    │                                                     │
    │    ┌─────────────┐         ┌─────────────┐         │
    │    │   BLUE      │         │   GREEN     │         │
    │    │   (V1)      │         │   (V2)      │         │
    │    │  [ACTIVE]   │    ◄──  │  [TESTING]  │         │
    │    └──────┬──────┘  smoke  └─────────────┘         │
    │           │         tests                          │
    │           │ 100% Traffic                           │
    │           ▼                                         │
    │    ┌─────────────┐                                 │
    │    │    USERS    │                                 │
    │    └─────────────┘                                 │
    └─────────────────────────────────────────────────────┘

                    AFTER SWITCH
    ┌─────────────────────────────────────────────────────┐
    │                                                     │
    │    ┌─────────────┐         ┌─────────────┐         │
    │    │   BLUE      │         │   GREEN     │         │
    │    │   (V1)      │         │   (V2)      │         │
    │    │  [STANDBY]  │         │  [ACTIVE]   │         │
    │    └─────────────┘         └──────┬──────┘         │
    │                                    │               │
    │                        100% Traffic│               │
    │                                    ▼               │
    │                           ┌─────────────┐          │
    │                           │    USERS    │          │
    │                           └─────────────┘          │
    └─────────────────────────────────────────────────────┘
```

### Deployer Implementation

```bash
#!/bin/bash
#===============================================================================
# blue_green_deploy.sh - Blue-Green Deployment Implementation
#===============================================================================

source "$(dirname "$0")/../lib/deployer_core.sh"
source "$(dirname "$0")/../lib/deployer_utils.sh"

#-------------------------------------------------------------------------------
# Configuration
#-------------------------------------------------------------------------------
declare -g BLUE_ENV="blue"
declare -g GREEN_ENV="green"
declare -g ACTIVE_ENV_FILE="/var/run/deployer/active_env"
declare -g SMOKE_TEST_TIMEOUT=60
declare -g WARMUP_REQUESTS=100

#-------------------------------------------------------------------------------
# Determine active/inactive environment
#-------------------------------------------------------------------------------
get_active_env() {
    if [[ -f "$ACTIVE_ENV_FILE" ]]; then
        cat "$ACTIVE_ENV_FILE"
    else
        echo "$BLUE_ENV"  # Default to blue
    fi
}

get_inactive_env() {
    local active
    active=$(get_active_env)
    
    if [[ "$active" == "$BLUE_ENV" ]]; then
        echo "$GREEN_ENV"
    else
        echo "$BLUE_ENV"
    fi
}

set_active_env() {
    local env="$1"
    echo "$env" > "$ACTIVE_ENV_FILE"
}

get_env_path() {
    local env="$1"
    echo "${DEPLOY_BASE_PATH}/${env}"
}

get_env_port() {
    local env="$1"
    
    case "$env" in
        blue)  echo "8001" ;;
        green) echo "8002" ;;
    esac
}

#-------------------------------------------------------------------------------
# Blue-Green Deployment Core
#-------------------------------------------------------------------------------
deploy_blue_green() {
    local release_path="$1"
    
    local active_env
    local target_env
    local target_path
    local target_port
    
    active_env=$(get_active_env)
    target_env=$(get_inactive_env)
    target_path=$(get_env_path "$target_env")
    target_port=$(get_env_port "$target_env")
    
    log_info "═══════════════════════════════════════════════════════════"
    log_info "  BLUE-GREEN DEPLOYMENT"
    log_info "═══════════════════════════════════════════════════════════"
    log_info "  Active environment:  $active_env"
    log_info "  Target environment:  $target_env"
    log_info "  Target path:         $target_path"
    log_info "  Target port:         $target_port"
    log_info "═══════════════════════════════════════════════════════════"
    
    # Step 1: Prepare target environment
    log_info "[1/6] Preparing target environment..."
    prepare_environment "$target_env" "$target_path" || {
        log_error "Failed to prepare environment"
        return 1
    }
    
    # Step 2: Deploy to target environment
    log_info "[2/6] Deploying release to $target_env..."
    deploy_release "$release_path" "$target_path" || {
        log_error "Failed to deploy release"
        return 1
    }
    
    # Step 3: Start application in target
    log_info "[3/6] Starting application in $target_env..."
    start_environment "$target_env" || {
        log_error "Failed to start $target_env environment"
        return 1
    }
    
    # Step 4: Smoke tests
    log_info "[4/6] Running smoke tests..."
    if ! run_smoke_tests "localhost:${target_port}"; then
        log_error "Smoke tests failed!"
        stop_environment "$target_env"
        return 1
    fi
    
    # Step 5: Warmup (optional)
    log_info "[5/6] Warming up application..."
    warmup_application "localhost:${target_port}" "$WARMUP_REQUESTS"
    
    # Step 6: Switch traffic
    log_info "[6/6] Switching traffic to $target_env..."
    if ! switch_traffic "$target_env"; then
        log_error "Failed to switch traffic!"
        # Rollback
        stop_environment "$target_env"
        return 1
    fi
    
    # Update state
    set_active_env "$target_env"
    
    # Stop old environment (optional - can be kept for rapid rollback)
    log_info "Stopping old environment ($active_env)..."
    stop_environment "$active_env"
    
    log_info "═══════════════════════════════════════════════════════════"
    log_info "  DEPLOYMENT SUCCESSFUL"
    log_info "  New active environment: $target_env"
    log_info "═══════════════════════════════════════════════════════════"
    
    return 0
}

#-------------------------------------------------------------------------------
# Environment Management
#-------------------------------------------------------------------------------
prepare_environment() {
    local env="$1"
    local path="$2"
    
    # Cleanup previous version
    if [[ -d "$path" ]]; then
        log_debug "Cleaning up previous deployment in $path"
        rm -rf "${path:?}/"*
    fi
    
    mkdir -p "$path"/{releases,shared,current}
    
    return 0
}

deploy_release() {
    local source="$1"
    local target="$2"
    
    log_debug "Copying release from $source to $target/releases/current"
    cp -r "$source"/* "$target/releases/current/" || return 1
    
    # Symlink to current
    rm -f "$target/current"
    ln -sfn "$target/releases/current" "$target/current"
    
    return 0
}

start_environment() {
    local env="$1"
    local service_name="app-${env}"
    
    systemctl start "$service_name" || return 1
    
    # Wait until application is ready
    local retries=30
    while [[ $retries -gt 0 ]]; do
        if systemctl is-active --quiet "$service_name"; then
            return 0
        fi
        sleep 1
        ((retries--))
    done
    
    return 1
}

stop_environment() {
    local env="$1"
    local service_name="app-${env}"
    
    systemctl stop "$service_name" 2>/dev/null || true
}

#-------------------------------------------------------------------------------
# Testing
#-------------------------------------------------------------------------------
run_smoke_tests() {
    local endpoint="$1"
    local start_time=$SECONDS
    
    log_debug "Running smoke tests against $endpoint"
    
    # Test 1: Health endpoint
    if ! curl -sf "http://${endpoint}/health" > /dev/null; then
        log_error "Health check failed"
        return 1
    fi
    log_debug "  ✓ Health check passed"
    
    # Test 2: Basic functionality
    if ! curl -sf "http://${endpoint}/api/status" > /dev/null; then
        log_error "API status check failed"
        return 1
    fi
    log_debug "  ✓ API status check passed"
    
    # Test 3: Database connectivity (via app)
    local db_status
    db_status=$(curl -sf "http://${endpoint}/api/db/ping" 2>/dev/null || echo "error")
    if [[ "$db_status" != *"ok"* ]]; then
        log_error "Database connectivity check failed"
        return 1
    fi
    log_debug "  ✓ Database connectivity check passed"
    
    local duration=$((SECONDS - start_time))
    log_info "All smoke tests passed in ${duration}s"
    
    return 0
}

warmup_application() {
    local endpoint="$1"
    local requests="$2"
    
    log_debug "Sending $requests warmup requests to $endpoint"
    
    for ((i=1; i<=requests; i++)); do
        curl -sf "http://${endpoint}/" > /dev/null 2>&1 || true
        
        if (( i % 20 == 0 )); then
            log_debug "  Warmup progress: $i/$requests"
        fi
    done
    
    log_debug "Warmup completed"
}

#-------------------------------------------------------------------------------
# Traffic Switching
#-------------------------------------------------------------------------------
switch_traffic() {
    local target_env="$1"
    local target_port
    target_port=$(get_env_port "$target_env")
    
    # Method 1: Nginx upstream
    if [[ -f "/etc/nginx/conf.d/app-upstream.conf" ]]; then
        cat > "/etc/nginx/conf.d/app-upstream.conf" <<EOF
upstream app_backend {
    server 127.0.0.1:${target_port};
}
EOF
        nginx -t && nginx -s reload
        return $?
    fi
    
    # Method 2: HAProxy
    if [[ -S "/var/run/haproxy/admin.sock" ]]; then
        local old_env
        old_env=$(get_active_env)
        
        # Disable old, enable new
        echo "set server app_backend/${old_env} state maint" | \
            socat stdio /var/run/haproxy/admin.sock
        echo "set server app_backend/${target_env} state ready" | \
            socat stdio /var/run/haproxy/admin.sock
        return $?
    fi
    
    # Method 3: Symlink switch
    local live_path="${DEPLOY_BASE_PATH}/live"
    local target_path
    target_path=$(get_env_path "$target_env")
    
    rm -f "$live_path"
    ln -sfn "$target_path/current" "$live_path"
    
    return 0
}

#-------------------------------------------------------------------------------
# Rollback
#-------------------------------------------------------------------------------
rollback_blue_green() {
    local current_active
    local previous_env
    
    current_active=$(get_active_env)
    previous_env=$(get_inactive_env)
    
    log_warn "Initiating rollback from $current_active to $previous_env"
    
    # Verify that previous environment exists and is functional
    if ! is_environment_healthy "$previous_env"; then
        log_error "Previous environment $previous_env is not healthy!"
        return 1
    fi
    
    # Start previous environment if stopped
    start_environment "$previous_env"
    
    # Switch traffic
    switch_traffic "$previous_env" || {
        log_error "Failed to switch traffic during rollback"
        return 1
    }
    
    # Update state
    set_active_env "$previous_env"
    
    # Stop failed environment
    stop_environment "$current_active"
    
    log_info "Rollback completed. Active environment: $previous_env"
    return 0
}

is_environment_healthy() {
    local env="$1"
    local port
    port=$(get_env_port "$env")
    
    curl -sf "http://localhost:${port}/health" > /dev/null 2>&1
}
```

### Strengths and Weaknesses

| Strengths | Weaknesses |
|-----------|------------|
| Instant rollback | Resource doubling |
| Zero downtime | Infrastructure cost |
| Isolated testing | Complex data synchronisation |
| Atomic switch | Doesn't detect gradual problems |

---

## Canary Deployment Strategy

### Concept

Canary deployment exposes the new version to only a small subset of users initially (e.g., 5%), intensively monitoring for errors. If metrics are acceptable, the percentage increases gradually to 100%.

### Flow Diagram

```
    Phase 1: 5% traffic            Phase 2: 25% traffic
    ┌────────────────────┐      ┌────────────────────┐
    │ V1 ████████████95% │      │ V1 ██████████ 75%  │
    │ V2 █           5%  │  ──► │ V2 ████      25%  │
    └────────────────────┘      └────────────────────┘
              │                           │
              ▼                           ▼
         Monitoring                  Monitoring
         • Error rate                • Error rate
         • Latency                   • Latency
         • Business metrics          • Business metrics
              │                           │
         OK? ─┴─ NO ──► Rollback         OK?
              │                           │
             YES                         YES
              │                           │
              ▼                           ▼
    
    Phase 3: 50% traffic           Phase 4: 100% traffic
    ┌────────────────────┐      ┌────────────────────┐
    │ V1 ██████    50%   │      │ V2 ████████████100%│
    │ V2 ██████    50%   │  ──► │                    │
    └────────────────────┘      └────────────────────┘
```

### Deployer Implementation

```bash
#!/bin/bash
#===============================================================================
# canary_deploy.sh - Canary Deployment Implementation
#===============================================================================

source "$(dirname "$0")/../lib/deployer_core.sh"
source "$(dirname "$0")/../lib/deployer_utils.sh"

#-------------------------------------------------------------------------------
# Configuration
#-------------------------------------------------------------------------------
declare -ga CANARY_STAGES=(5 25 50 75 100)
declare -g STAGE_DURATION=300  # 5 minutes per stage
declare -g ERROR_THRESHOLD=1.0  # 1% error rate
declare -g LATENCY_THRESHOLD=500  # 500ms p99
declare -g METRICS_ENDPOINT="http://localhost:9090"
declare -g AUTO_PROMOTE=true

#-------------------------------------------------------------------------------
# Canary Deployment Core
#-------------------------------------------------------------------------------
deploy_canary() {
    local release_path="$1"
    
    log_info "═══════════════════════════════════════════════════════════"
    log_info "  CANARY DEPLOYMENT"
    log_info "═══════════════════════════════════════════════════════════"
    log_info "  Stages: ${CANARY_STAGES[*]}%"
    log_info "  Stage duration: ${STAGE_DURATION}s"
    log_info "  Error threshold: ${ERROR_THRESHOLD}%"
    log_info "  Latency threshold: ${LATENCY_THRESHOLD}ms"
    log_info "═══════════════════════════════════════════════════════════"
    
    # Step 1: Deploy canary instances
    log_info "[1/3] Deploying canary instances..."
    if ! deploy_canary_instances "$release_path"; then
        log_error "Failed to deploy canary instances"
        return 1
    fi
    
    # Step 2: Progression through stages
    log_info "[2/3] Starting canary progression..."
    for percentage in "${CANARY_STAGES[@]}"; do
        log_info "────────────────────────────────────────────────"
        log_info "  STAGE: ${percentage}% traffic to canary"
        log_info "────────────────────────────────────────────────"
        
        # Adjust traffic split
        if ! set_canary_weight "$percentage"; then
            log_error "Failed to set canary weight to $percentage%"
            rollback_canary
            return 1
        fi
        
        # Monitor stage
        if ! monitor_canary_stage "$percentage" "$STAGE_DURATION"; then
            log_error "Canary failed at ${percentage}% stage"
            rollback_canary
            return 1
        fi
        
        log_info "Stage ${percentage}% completed successfully"
        
        # At 100%, exit loop
        [[ "$percentage" -eq 100 ]] && break
        
        # Pause between stages (for auto-promote)
        if [[ "$AUTO_PROMOTE" == "true" ]]; then
            log_info "Auto-promoting to next stage..."
        else
            log_info "Waiting for manual promotion..."
            wait_for_promotion || {
                log_warn "Promotion cancelled, initiating rollback"
                rollback_canary
                return 1
            }
        fi
    done
    
    # Step 3: Finalisation
    log_info "[3/3] Finalising deployment..."
    finalize_canary_deployment || {
        log_error "Failed to finalise deployment"
        return 1
    }
    
    log_info "═══════════════════════════════════════════════════════════"
    log_info "  CANARY DEPLOYMENT SUCCESSFUL"
    log_info "═══════════════════════════════════════════════════════════"
    
    return 0
}

#-------------------------------------------------------------------------------
# Canary Instance Management
#-------------------------------------------------------------------------------
deploy_canary_instances() {
    local release_path="$1"
    local canary_path="${DEPLOY_BASE_PATH}/canary"
    
    # Cleanup previous canary
    rm -rf "$canary_path"
    mkdir -p "$canary_path"
    
    # Copy release
    cp -r "$release_path"/* "$canary_path/"
    
    # Start canary instances
    for i in $(seq 1 "$CANARY_INSTANCE_COUNT"); do
        local service="app-canary-${i}"
        
        systemctl start "$service" || {
            log_error "Failed to start $service"
            return 1
        }
    done
    
    # Wait for healthy
    sleep 10
    
    return 0
}

#-------------------------------------------------------------------------------
# Traffic Management
#-------------------------------------------------------------------------------
set_canary_weight() {
    local percentage="$1"
    local stable_weight=$((100 - percentage))
    
    log_debug "Setting traffic: stable=${stable_weight}%, canary=${percentage}%"
    
    # Nginx upstream with weighted round-robin
    if [[ -f "/etc/nginx/conf.d/app-upstream.conf" ]]; then
        cat > "/etc/nginx/conf.d/app-upstream.conf" <<EOF
upstream app_backend {
    # Stable instances
    server 127.0.0.1:8001 weight=${stable_weight};
    
    # Canary instances
    server 127.0.0.1:8002 weight=${percentage};
}
EOF
        nginx -t && nginx -s reload
        return $?
    fi
    
    # Istio VirtualService (for Kubernetes)
    if command -v kubectl &>/dev/null; then
        kubectl apply -f - <<EOF
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: app-vs
spec:
  http:
  - route:
    - destination:
        host: app-stable
      weight: ${stable_weight}
    - destination:
        host: app-canary
      weight: ${percentage}
EOF
        return $?
    fi
    
    return 0
}

#-------------------------------------------------------------------------------
# Monitoring and Analysis
#-------------------------------------------------------------------------------
monitor_canary_stage() {
    local percentage="$1"
    local duration="$2"
    local check_interval=30
    local elapsed=0
    
    while [[ $elapsed -lt $duration ]]; do
        # Collect metrics
        local canary_error_rate
        local canary_latency
        local stable_error_rate
        local stable_latency
        
        canary_error_rate=$(get_error_rate "canary")
        canary_latency=$(get_p99_latency "canary")
        stable_error_rate=$(get_error_rate "stable")
        stable_latency=$(get_p99_latency "stable")
        
        log_debug "Metrics at ${elapsed}s:"
        log_debug "  Canary - Error: ${canary_error_rate}%, Latency: ${canary_latency}ms"
        log_debug "  Stable - Error: ${stable_error_rate}%, Latency: ${stable_latency}ms"
        
        # Compare with thresholds
        if ! check_canary_health "$canary_error_rate" "$canary_latency" \
                                  "$stable_error_rate" "$stable_latency"; then
            log_error "Canary health check failed!"
            return 1
        fi
        
        sleep "$check_interval"
        ((elapsed += check_interval))
        
        # Progress indicator
        local progress=$((elapsed * 100 / duration))
        echo -ne "\r  Stage progress: ${progress}% (${elapsed}s/${duration}s)"
    done
    
    echo ""
    return 0
}

get_error_rate() {
    local version="$1"
    
    # Query Prometheus
    local query="sum(rate(http_requests_total{status=~'5..',version='${version}'}[5m])) / sum(rate(http_requests_total{version='${version}'}[5m])) * 100"
    
    local result
    result=$(curl -s "${METRICS_ENDPOINT}/api/v1/query" \
        --data-urlencode "query=$query" \
        | jq -r '.data.result[0].value[1] // "0"')
    
    echo "${result:-0}"
}

get_p99_latency() {
    local version="$1"
    
    local query="histogram_quantile(0.99, sum(rate(http_request_duration_seconds_bucket{version='${version}'}[5m])) by (le)) * 1000"
    
    local result
    result=$(curl -s "${METRICS_ENDPOINT}/api/v1/query" \
        --data-urlencode "query=$query" \
        | jq -r '.data.result[0].value[1] // "0"')
    
    echo "${result:-0}"
}

check_canary_health() {
    local canary_error="$1"
    local canary_latency="$2"
    local stable_error="$3"
    local stable_latency="$4"
    
    # Check absolute thresholds
    if (( $(echo "$canary_error > $ERROR_THRESHOLD" | bc -l) )); then
        log_error "Canary error rate ${canary_error}% exceeds threshold ${ERROR_THRESHOLD}%"
        return 1
    fi
    
    if (( $(echo "$canary_latency > $LATENCY_THRESHOLD" | bc -l) )); then
        log_error "Canary latency ${canary_latency}ms exceeds threshold ${LATENCY_THRESHOLD}ms"
        return 1
    fi
    
    # Check relative (canary vs stable)
    local error_ratio
    error_ratio=$(echo "scale=2; $canary_error / ($stable_error + 0.001)" | bc -l)
    
    if (( $(echo "$error_ratio > 2.0" | bc -l) )); then
        log_error "Canary error rate is ${error_ratio}x higher than stable"
        return 1
    fi
    
    return 0
}

#-------------------------------------------------------------------------------
# Rollback and Finalisation
#-------------------------------------------------------------------------------
rollback_canary() {
    log_warn "Initiating canary rollback..."
    
    # Redirect all traffic to stable
    set_canary_weight 0
    
    # Stop canary instances
    for i in $(seq 1 "$CANARY_INSTANCE_COUNT"); do
        systemctl stop "app-canary-${i}" 2>/dev/null || true
    done
    
    # Cleanup
    rm -rf "${DEPLOY_BASE_PATH}/canary"
    
    log_info "Canary rollback completed"
}

finalize_canary_deployment() {
    log_info "Promoting canary to stable..."
    
    # Copy canary to stable
    local stable_path="${DEPLOY_BASE_PATH}/stable"
    local canary_path="${DEPLOY_BASE_PATH}/canary"
    
    # Backup current stable
    if [[ -d "$stable_path" ]]; then
        mv "$stable_path" "${stable_path}.backup.$(date +%s)"
    fi
    
    # Promote canary
    mv "$canary_path" "$stable_path"
    
    # Restart stable instances with new version
    for i in $(seq 1 "$STABLE_INSTANCE_COUNT"); do
        systemctl restart "app-stable-${i}"
    done
    
    # Redirect all traffic to stable
    set_canary_weight 0
    
    # Stop canary-specific instances
    for i in $(seq 1 "$CANARY_INSTANCE_COUNT"); do
        systemctl stop "app-canary-${i}" 2>/dev/null || true
    done
    
    return 0
}
```

### Strengths and Weaknesses

| Strengths | Weaknesses |
|-----------|------------|
| Minimal risk | Setup complexity |
| Real user feedback | Requires advanced monitoring |
| Subtle problem detection | Slower deployment |
| Instant partial rollback | A/B testing side effects |

---

## Synthetic Comparison

### Comparative Table

| Criterion | Rolling | Blue-Green | Canary |
|-----------|---------|------------|--------|
| **Downtime** | Zero | Zero | Zero |
| **Additional resources** | Minimal | 2x | ~10-20% |
| **Complexity** | Medium | Medium | High |
| **Deployment time** | Medium | Fast | Long |
| **Rollback speed** | Medium | Instant | Gradual |
| **Risk** | Moderate | Low | Very low |
| **Simultaneous versions** | Yes | No (momentarily) | Yes |
| **Requires advanced LB** | No | No | Yes |
| **Pre-live testing** | Partial | Complete | Partial |

### Decision Tree

```
                    START
                      │
                      ▼
              ┌───────────────┐
              │ Do you have   │
              │   advanced    │
              │  monitoring?  │
              └───────┬───────┘
                      │
           NO ◄───────┴───────► YES
            │                    │
            ▼                    ▼
    ┌───────────────┐    ┌───────────────┐
    │ Can you double│    │ High traffic  │
    │  resources?   │    │   (>1M/day)?  │
    └───────┬───────┘    └───────┬───────┘
            │                    │
     YES ◄──┴──► NO      YES ◄──┴──► NO
      │          │         │          │
      ▼          ▼         ▼          ▼
  BLUE-GREEN  ROLLING   CANARY    ROLLING
```

---

## Practical Exercises

### Exercise 1: Feature Flags Implementation

Extend canary deployment with feature flags:

```bash
# Requirements:
# - Toggle features per user/segment
# - Integration with canary deployment
# - Dashboard for flag management
```

### Exercise 2: Multi-Region Deployment

Implement cross-region deployment:

```bash
# Requirements:
# - Deploy to multiple regions sequentially
# - Health checks per region
# - Selective rollback per region
```

### Exercise 3: GitOps Pipeline

Create a complete GitOps pipeline:

```bash
# Requirements:
# - Trigger deployment on push
# - Strategy selection based on branch
# - Automated integration tests
```

### Exercise 4: Chaos Engineering Integration

Integrate chaos testing into deployment:

```bash
# Requirements:
# - Failure injection in canary stage
# - Resilience verification
# - Auto-rollback on failure
```

### Exercise 5: Deployment Metrics Dashboard

Create a metrics visualisation system:

```bash
# Requirements:
# - Deployment metrics collection
# - Terminal visualisation
# - Export for Grafana/Prometheus
```

---

## Additional Resources

### Advanced Patterns

1. **Shadow Deployment**: Duplicated traffic to new version without serving responses
2. **A/B Testing**: Deployment based on experiments and business metrics
3. **Dark Launching**: Hidden features activated selectively
4. **Ramped Deployment**: Linear traffic increase (vs. discrete stages)

### Best Practices

1. **Complete automation**: No manual steps in deployment
2. **Monitoring before deploy**: Setup alerting before any change
3. **Tested rollback**: Verify that rollback works before deployment
4. **Communication**: Notify the team about planned deployments
5. **Post-mortems**: Analyse every failed deployment
