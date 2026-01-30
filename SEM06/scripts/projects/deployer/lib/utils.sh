#!/usr/bin/env bash
# ==============================================================================
# DEPLOYER - Utils Library
# ==============================================================================
# Functions for deployment: services, containers, health checks, rollback
# Part of the CAPSTONE project for Operating Systems
# ==============================================================================

# Guard against double loading
[[ -n "${_DEPLOYER_UTILS_LOADED:-}" ]] && return 0
readonly _DEPLOYER_UTILS_LOADED=1

# ==============================================================================
# SERVICE MANAGEMENT - SYSTEMD
# ==============================================================================

# Check if a systemd service exists
# Args: $1 = service name
service_exists() {
    local service=$1
    systemctl list-unit-files "${service}.service" &>/dev/null
}

# Get status of a systemd service
# Args: $1 = service name
# Return: active, inactive, failed, not-found
get_service_status() {
    local service=$1
    
    if ! has_systemd; then
        echo "no-systemd"
        return 1
    fi
    
    if ! service_exists "$service"; then
        echo "not-found"
        return 1
    fi
    
    systemctl is-active "$service" 2>/dev/null || echo "unknown"
}

# Start systemd service
# Args: $1 = service name
start_service() {
    local service=$1
    log_info "Starting service: $service"
    
    if ! has_systemd; then
        log_error "Systemd not available"
        return 1
    fi
    
    if systemctl start "$service" 2>&1; then
        log_info "Service started: $service"
        return 0
    else
        log_error "Failed to start service: $service"
        return 1
    fi
}

# Stop systemd service
# Args: $1 = service name
stop_service() {
    local service=$1
    log_info "Stopping service: $service"
    
    if ! has_systemd; then
        log_error "Systemd not available"
        return 1
    fi
    
    if systemctl stop "$service" 2>&1; then
        log_info "Service stopped: $service"
        return 0
    else
        log_error "Failed to stop service: $service"
        return 1
    fi
}

# Restart systemd service
# Args: $1 = service name
restart_service() {
    local service=$1
    log_info "Restarting service: $service"
    
    if ! has_systemd; then
        log_error "Systemd not available"
        return 1
    fi
    
    if systemctl restart "$service" 2>&1; then
        log_info "Service restarted: $service"
        return 0
    else
        log_error "Failed to restart service: $service"
        return 1
    fi
}

# Reload service configuration
# Args: $1 = service name
reload_service() {
    local service=$1
    log_info "Reloading service: $service"
    
    if systemctl reload "$service" 2>&1; then
        log_info "Service reloaded: $service"
        return 0
    else
        log_warn "Reload not supported, restarting: $service"
        restart_service "$service"
    fi
}

# Enable service at boot
# Args: $1 = service name
enable_service() {
    local service=$1
    log_info "Enabling service: $service"
    systemctl enable "$service" 2>&1
}

# Disable service at boot
# Args: $1 = service name
disable_service() {
    local service=$1
    log_info "Disabling service: $service"
    systemctl disable "$service" 2>&1
}

# ==============================================================================
# CONTAINER MANAGEMENT - DOCKER
# ==============================================================================

# Check if Docker is available
docker_available() {
    command_exists docker && docker info &>/dev/null
}

# Check if a container exists
# Args: $1 = container name
container_exists() {
    local container=$1
    docker ps -a --format '{{.Names}}' 2>/dev/null | grep -q "^${container}$"
}

# Check if a container is running
# Args: $1 = container name
container_running() {
    local container=$1
    docker ps --format '{{.Names}}' 2>/dev/null | grep -q "^${container}$"
}

# Get container status
# Args: $1 = container name
# Return: running, stopped, not-found
get_container_status() {
    local container=$1
    
    if ! docker_available; then
        echo "no-docker"
        return 1
    fi
    
    if container_running "$container"; then
        echo "running"
    elif container_exists "$container"; then
        echo "stopped"
    else
        echo "not-found"
    fi
}

# Start container
# Args: $1 = container name
start_container() {
    local container=$1
    log_info "Starting container: $container"
    
    if ! container_exists "$container"; then
        log_error "Container not found: $container"
        return 1
    fi
    
    if container_running "$container"; then
        log_info "Container already running: $container"
        return 0
    fi
    
    if docker start "$container" &>/dev/null; then
        log_info "Container started: $container"
        return 0
    else
        log_error "Failed to start container: $container"
        return 1
    fi
}

# Stop container
# Args: $1 = container name, $2 = timeout (optional)
stop_container() {
    local container=$1
    local timeout=${2:-30}
    
    log_info "Stopping container: $container (timeout: ${timeout}s)"
    
    if ! container_running "$container"; then
        log_info "Container already stopped: $container"
        return 0
    fi
    
    if docker stop -t "$timeout" "$container" &>/dev/null; then
        log_info "Container stopped: $container"
        return 0
    else
        log_error "Failed to stop container: $container"
        return 1
    fi
}

# Restart container
# Args: $1 = container name
restart_container() {
    local container=$1
    log_info "Restarting container: $container"
    
    if docker restart "$container" &>/dev/null; then
        log_info "Container restarted: $container"
        return 0
    else
        log_error "Failed to restart container: $container"
        return 1
    fi
}

# Delete container
# Args: $1 = container name, $2 = force (optional)
remove_container() {
    local container=$1
    local force=${2:-false}
    
    log_info "Removing container: $container"
    
    if ! container_exists "$container"; then
        log_info "Container not found: $container"
        return 0
    fi
    
    local opts=""
    [[ "$force" == "true" ]] && opts="-f"
    
    if docker rm $opts "$container" &>/dev/null; then
        log_info "Container removed: $container"
        return 0
    else
        log_error "Failed to remove container: $container"
        return 1
    fi
}

# Run new container
# Args: $1 = container name, $2 = image, $3... = docker run options
run_container() {
    local container=$1
    local image=$2
    shift 2
    local opts=("$@")
    
    log_info "Running container: $container from image: $image"
    
    # Stop and delete if exists
    if container_exists "$container"; then
        stop_container "$container" 10
        remove_container "$container"
    fi
    
    if docker run -d --name "$container" "${opts[@]}" "$image" &>/dev/null; then
        log_info "Container started: $container"
        return 0
    else
        log_error "Failed to run container: $container"
        return 1
    fi
}

# Pull Docker image
# Args: $1 = image name
pull_image() {
    local image=$1
    log_info "Pulling image: $image"
    
    if docker pull "$image" 2>&1 | while read -r line; do
        log_debug "  $line"
    done; then
        log_info "Image pulled: $image"
        return 0
    else
        log_error "Failed to pull image: $image"
        return 1
    fi
}

# Get image version (tag)
# Args: $1 = container name
get_container_image_version() {
    local container=$1
    docker inspect --format='{{.Config.Image}}' "$container" 2>/dev/null | \
        sed 's/.*://' || echo "unknown"
}

# ==============================================================================
# HEALTH CHECKS
# ==============================================================================

# HTTP health check
# Args: $1 = URL, $2 = expected status (optional, default 200), $3 = timeout (optional)
health_check_http() {
    local url=$1
    local expected_status=${2:-200}
    local timeout=${3:-10}
    
    log_debug "HTTP health check: $url (expecting $expected_status)"
    
    local status
    status=$(curl -s -o /dev/null -w "%{http_code}" --max-time "$timeout" "$url" 2>/dev/null || echo "000")
    
    if [[ "$status" == "$expected_status" ]]; then
        log_debug "Health check passed: $url (status: $status)"
        return 0
    else
        log_warn "Health check failed: $url (status: $status, expected: $expected_status)"
        return 1
    fi
}

# TCP port health check
# Args: $1 = host, $2 = port, $3 = timeout (optional)
health_check_tcp() {
    local host=$1
    local port=$2
    local timeout=${3:-5}
    
    log_debug "TCP health check: $host:$port"
    
    if timeout "$timeout" bash -c "echo >/dev/tcp/$host/$port" 2>/dev/null; then
        log_debug "Health check passed: $host:$port"
        return 0
    else
        log_warn "Health check failed: $host:$port"
        return 1
    fi
}

# Process health check
# Args: $1 = process name or PID
health_check_process() {
    local process=$1
    
    log_debug "Process health check: $process"
    
    if [[ "$process" =~ ^[0-9]+$ ]]; then
        # It's a PID
        if kill -0 "$process" 2>/dev/null; then
            log_debug "Process alive: PID $process"
            return 0
        fi
    else
        # It's a process name
        if pgrep -x "$process" &>/dev/null; then
            log_debug "Process running: $process"
            return 0
        fi
    fi
    
    log_warn "Process not found: $process"
    return 1
}

# Command health check
# Args: $1... = command to execute
health_check_command() {
    local cmd=("$@")
    
    log_debug "Command health check: ${cmd[*]}"
    
    if "${cmd[@]}" &>/dev/null; then
        log_debug "Command check passed"
        return 0
    else
        log_warn "Command check failed: ${cmd[*]}"
        return 1
    fi
}

# Health check with retry
# Args: $1 = check type (http|tcp|process|command), $2 = retries, $3 = interval, $4... = args
health_check_with_retry() {
    local check_type=$1
    local retries=$2
    local interval=$3
    shift 3
    local args=("$@")
    
    local attempt=1
    while [[ $attempt -le $retries ]]; do
        log_debug "Health check attempt $attempt/$retries"
        
        case $check_type in
            http)    health_check_http "${args[@]}" && return 0 ;;
            tcp)     health_check_tcp "${args[@]}" && return 0 ;;
            process) health_check_process "${args[@]}" && return 0 ;;
            command) health_check_command "${args[@]}" && return 0 ;;
            *)
                log_error "Unknown health check type: $check_type"
                return 1
                ;;
        esac
        
        if [[ $attempt -lt $retries ]]; then
            log_debug "Waiting ${interval}s before retry..."
            sleep "$interval"
        fi
        
        ((attempt++))
    done
    
    log_error "Health check failed after $retries attempts"
    return 1
}

# ==============================================================================
# FILE DEPLOYMENT
# ==============================================================================

# Deploy file with backup
# Args: $1 = source, $2 = destination, $3 = backup dir (optional)
deploy_file() {
    local source=$1
    local dest=$2
    local backup_dir=${3:-""}
    
    log_info "Deploying file: $source -> $dest"
    
    # Check source
    if [[ ! -f "$source" ]]; then
        log_error "Source file not found: $source"
        return 1
    fi
    
    # Create backup if destination exists
    if [[ -f "$dest" && -n "$backup_dir" ]]; then
        local backup_file="$backup_dir/$(basename "$dest").$(get_short_timestamp)"
        mkdir -p "$backup_dir"
        cp -p "$dest" "$backup_file"
        log_debug "Backup created: $backup_file"
    fi
    
    # Create destination directory if it doesn't exist
    local dest_dir
    dest_dir=$(dirname "$dest")
    if [[ ! -d "$dest_dir" ]]; then
        mkdir -p "$dest_dir"
        log_debug "Created directory: $dest_dir"
    fi
    
    # Copy file
    if cp -p "$source" "$dest"; then
        log_info "File deployed: $dest"
        return 0
    else
        log_error "Failed to deploy file: $dest"
        return 1
    fi
}

# Deploy directory with backup
# Args: $1 = source dir, $2 = destination dir, $3 = backup dir (optional)
deploy_directory() {
    local source=$1
    local dest=$2
    local backup_dir=${3:-""}
    
    log_info "Deploying directory: $source -> $dest"
    
    # Check source
    if [[ ! -d "$source" ]]; then
        log_error "Source directory not found: $source"
        return 1
    fi
    
    # Create backup if destination exists
    if [[ -d "$dest" && -n "$backup_dir" ]]; then
        local backup_name="$(basename "$dest")_$(get_short_timestamp)"
        mkdir -p "$backup_dir"
        cp -rp "$dest" "$backup_dir/$backup_name"
        log_debug "Backup created: $backup_dir/$backup_name"
    fi
    
    # Create parent directory if it doesn't exist
    local dest_parent
    dest_parent=$(dirname "$dest")
    mkdir -p "$dest_parent"
    
    # Copy directory
    if cp -rp "$source" "$dest"; then
        log_info "Directory deployed: $dest"
        return 0
    else
        log_error "Failed to deploy directory: $dest"
        return 1
    fi
}

# Sync directory using rsync
# Args: $1 = source, $2 = destination, $3 = exclude file (optional)
sync_directory() {
    local source=$1
    local dest=$2
    local exclude_file=${3:-""}
    
    log_info "Syncing: $source -> $dest"
    
    if ! command_exists rsync; then
        log_warn "rsync not available, using cp"
        deploy_directory "$source" "$dest"
        return $?
    fi
    
    local opts=("-av" "--delete")
    
    if [[ -n "$exclude_file" && -f "$exclude_file" ]]; then
        opts+=("--exclude-from=$exclude_file")
    fi
    
    if rsync "${opts[@]}" "$source/" "$dest/"; then
        log_info "Sync completed: $dest"
        return 0
    else
        log_error "Sync failed: $dest"
        return 1
    fi
}

# ==============================================================================
# PERMISSION MANAGEMENT
# ==============================================================================

# Set owner and group
# Args: $1 = path, $2 = owner:group
set_ownership() {
    local path=$1
    local owner=$2
    
    log_debug "Setting ownership: $path -> $owner"
    chown -R "$owner" "$path"
}

# Set permissions
# Args: $1 = path, $2 = mode
set_permissions() {
    local path=$1
    local mode=$2
    
    log_debug "Setting permissions: $path -> $mode"
    chmod -R "$mode" "$path"
}

# Set executable permissions
# Args: $1 = directory
set_executable_permissions() {
    local dir=$1
    
    log_debug "Setting executable permissions in: $dir"
    find "$dir" -type f \( -name "*.sh" -o -name "*.py" -o -name "*.pl" \) \
        -exec chmod +x {} \;
}

# ==============================================================================
# VERSION MANAGEMENT
# ==============================================================================

# Save current version
# Args: $1 = service name, $2 = version, $3 = version file
save_version() {
    local service=$1
    local version=$2
    local version_file=$3
    
    log_debug "Saving version: $service=$version to $version_file"
    
    mkdir -p "$(dirname "$version_file")"
    echo "$service=$version" >> "$version_file"
}

# Get previous version
# Args: $1 = service name, $2 = version file
get_previous_version() {
    local service=$1
    local version_file=$2
    
    if [[ ! -f "$version_file" ]]; then
        echo ""
        return 1
    fi
    
    grep "^${service}=" "$version_file" | tail -2 | head -1 | cut -d= -f2
}

# Get current version
# Args: $1 = service name, $2 = version file
get_current_version() {
    local service=$1
    local version_file=$2
    
    if [[ ! -f "$version_file" ]]; then
        echo ""
        return 1
    fi
    
    grep "^${service}=" "$version_file" | tail -1 | cut -d= -f2
}

# ==============================================================================
# ROLLBACK SUPPORT
# ==============================================================================

# Structure for rollback backup
declare -A ROLLBACK_DATA

# Register data for rollback
# Args: $1 = key, $2 = value
register_rollback() {
    local key=$1
    local value=$2
    
    ROLLBACK_DATA["$key"]=$value
    log_debug "Registered rollback: $key"
}

# Get rollback data
# Args: $1 = key
get_rollback_data() {
    local key=$1
    echo "${ROLLBACK_DATA[$key]:-}"
}

# Restore file from backup
# Args: $1 = backup file, $2 = destination
restore_file() {
    local backup=$1
    local dest=$2
    
    log_rollback "Restoring file: $backup -> $dest"
    
    if [[ ! -f "$backup" ]]; then
        log_error "Backup file not found: $backup"
        return 1
    fi
    
    if cp -p "$backup" "$dest"; then
        log_info "File restored: $dest"
        return 0
    else
        log_error "Failed to restore file: $dest"
        return 1
    fi
}

# Restore directory from backup
# Args: $1 = backup dir, $2 = destination
restore_directory() {
    local backup=$1
    local dest=$2
    
    log_rollback "Restoring directory: $backup -> $dest"
    
    if [[ ! -d "$backup" ]]; then
        log_error "Backup directory not found: $backup"
        return 1
    fi
    
    # Delete current destination
    rm -rf "$dest"
    
    # Restore from backup
    if cp -rp "$backup" "$dest"; then
        log_info "Directory restored: $dest"
        return 0
    else
        log_error "Failed to restore directory: $dest"
        return 1
    fi
}

# ==============================================================================
# DEPLOYMENT MANIFEST
# ==============================================================================

# Parse simple YAML manifest (key: value)
# Args: $1 = manifest file
# Output: MANIFEST_* variables
parse_manifest() {
    local manifest=$1
    
    if [[ ! -f "$manifest" ]]; then
        log_error "Manifest not found: $manifest"
        return 1
    fi
    
    log_debug "Parsing manifest: $manifest"
    
    while IFS=': ' read -r key value || [[ -n "$key" ]]; do
        # Skip comments and empty lines
        [[ "$key" =~ ^#.*$ || -z "$key" ]] && continue
        
        # Clean whitespace
        key=$(echo "$key" | tr -d ' ')
        value=$(echo "$value" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        
        # Export as variable
        local var_name="MANIFEST_${key^^}"
        var_name=${var_name//-/_}
        declare -g "$var_name=$value"
        log_debug "  $var_name=$value"
    done < "$manifest"
    
    return 0
}

# Validate manifest
# Args: $1 = manifest file
validate_manifest() {
    local manifest=$1
    local required=("name" "version" "type")
    
    parse_manifest "$manifest" || return 1
    
    for field in "${required[@]}"; do
        local var_name="MANIFEST_${field^^}"
        if [[ -z "${!var_name:-}" ]]; then
            log_error "Missing required field in manifest: $field"
            return 1
        fi
    done
    
    log_debug "Manifest valid: $manifest"
    return 0
}

# ==============================================================================
# ENVIRONMENT VARIABLES
# ==============================================================================

# Load variables from .env file
# Args: $1 = env file
load_env_file() {
    local env_file=$1
    
    if [[ ! -f "$env_file" ]]; then
        log_warn "Env file not found: $env_file"
        return 1
    fi
    
    log_debug "Loading env file: $env_file"
    
    while IFS='=' read -r key value || [[ -n "$key" ]]; do
        # Skip comments and empty lines
        [[ "$key" =~ ^#.*$ || -z "$key" ]] && continue
        
        # Clean quotes
        value=${value%\"}
        value=${value#\"}
        value=${value%\'}
        value=${value#\'}
        
        export "$key=$value"
        log_debug "  Exported: $key"
    done < "$env_file"
    
    return 0
}

# Substitute variables in template
# Args: $1 = template file, $2 = output file
substitute_env_vars() {
    local template=$1
    local output=$2
    
    log_debug "Substituting env vars: $template -> $output"
    
    if [[ ! -f "$template" ]]; then
        log_error "Template not found: $template"
        return 1
    fi
    
    # Use envsubst if available
    if command_exists envsubst; then
        envsubst < "$template" > "$output"
    else
        # Manual fallback
        local content
        content=$(cat "$template")
        
        while [[ "$content" =~ \$\{([A-Za-z_][A-Za-z0-9_]*)\} ]]; do
            local var="${BASH_REMATCH[1]}"
            local value="${!var:-}"
            content=${content//\$\{$var\}/$value}
        done
        
        echo "$content" > "$output"
    fi
    
    log_debug "Template processed: $output"
    return 0
}

# ==============================================================================
# NETWORK UTILITIES
# ==============================================================================

# Wait until port is available
# Args: $1 = host, $2 = port, $3 = timeout (optional), $4 = interval (optional)
wait_for_port() {
    local host=$1
    local port=$2
    local timeout=${3:-60}
    local interval=${4:-2}
    
    log_info "Waiting for $host:$port (timeout: ${timeout}s)"
    
    local elapsed=0
    while [[ $elapsed -lt $timeout ]]; do
        if health_check_tcp "$host" "$port" 2; then
            log_info "Port available: $host:$port"
            return 0
        fi
        
        sleep "$interval"
        elapsed=$((elapsed + interval))
    done
    
    log_error "Timeout waiting for port: $host:$port"
    return 1
}

# Wait until URL responds
# Args: $1 = URL, $2 = timeout (optional), $3 = interval (optional)
wait_for_url() {
    local url=$1
    local timeout=${2:-60}
    local interval=${3:-2}
    
    log_info "Waiting for $url (timeout: ${timeout}s)"
    
    local elapsed=0
    while [[ $elapsed -lt $timeout ]]; do
        if health_check_http "$url" 200 5; then
            log_info "URL available: $url"
            return 0
        fi
        
        sleep "$interval"
        elapsed=$((elapsed + interval))
    done
    
    log_error "Timeout waiting for URL: $url"
    return 1
}

# Check if port is free
# Args: $1 = port
is_port_free() {
    local port=$1
    ! ss -tuln 2>/dev/null | grep -q ":${port}\b"
}

# Find free port in range
# Args: $1 = start, $2 = end
find_free_port() {
    local start=$1
    local end=$2
    
    for port in $(seq "$start" "$end"); do
        if is_port_free "$port"; then
            echo "$port"
            return 0
        fi
    done
    
    return 1
}

# ==============================================================================
# PROCESS MANAGEMENT
# ==============================================================================

# Start process in background
# Args: $1 = pid file, $2... = command
start_daemon() {
    local pid_file=$1
    shift
    local cmd=("$@")
    
    log_info "Starting daemon: ${cmd[*]}"
    
    # Create directory for PID file
    mkdir -p "$(dirname "$pid_file")"
    
    # Start in background
    nohup "${cmd[@]}" &>/dev/null &
    local pid=$!
    
    echo "$pid" > "$pid_file"
    log_info "Daemon started with PID: $pid"
    
    # Check if it started
    sleep 1
    if kill -0 "$pid" 2>/dev/null; then
        return 0
    else
        log_error "Daemon failed to start"
        rm -f "$pid_file"
        return 1
    fi
}

# Stop process from PID file
# Args: $1 = pid file, $2 = timeout (optional)
stop_daemon() {
    local pid_file=$1
    local timeout=${2:-30}
    
    if [[ ! -f "$pid_file" ]]; then
        log_warn "PID file not found: $pid_file"
        return 0
    fi
    
    local pid
    pid=$(cat "$pid_file")
    
    if ! kill -0 "$pid" 2>/dev/null; then
        log_warn "Process not running: $pid"
        rm -f "$pid_file"
        return 0
    fi
    
    log_info "Stopping daemon PID: $pid"
    
    # SIGTERM
    kill "$pid" 2>/dev/null
    
    # Wait for it to stop
    local elapsed=0
    while kill -0 "$pid" 2>/dev/null && [[ $elapsed -lt $timeout ]]; do
        sleep 1
        ((elapsed++))
    done
    
    # SIGKILL if still running
    if kill -0 "$pid" 2>/dev/null; then
        log_warn "Force killing daemon: $pid"
        kill -9 "$pid" 2>/dev/null
    fi
    
    rm -f "$pid_file"
    log_info "Daemon stopped"
    return 0
}

# ==============================================================================
# REPORTING
# ==============================================================================

# Generate deployment report
generate_deployment_report() {
    local output_format=${1:-"text"}
    
    local duration
    duration=$(get_deployment_duration)
    
    case $output_format in
        text)
            echo ""
            log_separator "="
            echo -e "${CYAN}DEPLOYMENT REPORT${NC}"
            log_separator "="
            echo "Deployment ID: $DEPLOYMENT_ID"
            echo "Status:        $DEPLOYMENT_STATE"
            echo "Duration:      $(format_duration "$duration")"
            echo "Services:      $DEPLOY_SERVICES_SUCCESS/$DEPLOY_SERVICES_TOTAL succeeded"
            if [[ $DEPLOY_SERVICES_FAILED -gt 0 ]]; then
                echo "Failed:        $DEPLOY_SERVICES_FAILED"
            fi
            echo "Hooks run:     $DEPLOY_HOOKS_RUN"
            log_separator "="
            
            if [[ ${#DEPLOYED_SERVICES[@]} -gt 0 ]]; then
                echo ""
                echo "Deployed Services:"
                for service_info in "${DEPLOYED_SERVICES[@]}"; do
                    IFS=':' read -r name version path <<< "$service_info"
                    echo "  - $name (v$version)"
                done
            fi
            ;;
            
        json)
            cat <<EOF
{
  "deployment_id": "$DEPLOYMENT_ID",
  "status": "$DEPLOYMENT_STATE",
  "duration_seconds": $duration,
  "services_total": $DEPLOY_SERVICES_TOTAL,
  "services_success": $DEPLOY_SERVICES_SUCCESS,
  "services_failed": $DEPLOY_SERVICES_FAILED,
  "hooks_run": $DEPLOY_HOOKS_RUN
}
EOF
            ;;
    esac
}
