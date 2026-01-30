#!/usr/bin/env bash
# ==============================================================================
# DEPLOYER - Core Library
# ==============================================================================
# Fundamental functions: logging, error handling, locks, hooks, utilities
# Part of the CAPSTONE project for Operating Systems
# ==============================================================================

# Strict mode
set -o errexit
set -o nounset
set -o pipefail

# ==============================================================================
# CONSTANTS AND COLOURS
# ==============================================================================

# Version
readonly DEPLOYER_VERSION="1.0.0"
readonly DEPLOYER_NAME="SysDeployer"

# ANSI colours
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly MAGENTA='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly WHITE='\033[1;37m'
readonly GRAY='\033[0;90m'
readonly NC='\033[0m' # No Colour

# Status symbols
readonly SYMBOL_SUCCESS="✓"
readonly SYMBOL_FAILURE="✗"
readonly SYMBOL_WARNING="⚠"
readonly SYMBOL_INFO="ℹ"
readonly SYMBOL_DEPLOY="🚀"
readonly SYMBOL_ROLLBACK="↩"

# Logging levels
readonly LOG_LEVEL_DEBUG=0
readonly LOG_LEVEL_INFO=1
readonly LOG_LEVEL_WARN=2
readonly LOG_LEVEL_ERROR=3
readonly LOG_LEVEL_FATAL=4

# Deployment states
readonly STATE_PENDING="pending"
readonly STATE_RUNNING="running"
readonly STATE_SUCCESS="success"
readonly STATE_FAILED="failed"
readonly STATE_ROLLED_BACK="rolled_back"

# ==============================================================================
# GLOBAL VARIABLES
# ==============================================================================

# Logging - can be overridden by config
CURRENT_LOG_LEVEL=${CURRENT_LOG_LEVEL:-$LOG_LEVEL_INFO}
LOG_FILE=${LOG_FILE:-""}
LOG_TO_FILE=${LOG_TO_FILE:-false}
USE_COLORS=${USE_COLORS:-true}
VERBOSE=${VERBOSE:-false}
QUIET=${QUIET:-false}

# Lock management
LOCK_FILE=${LOCK_FILE:-""}
LOCK_ACQUIRED=${LOCK_ACQUIRED:-false}
LOCK_PID_FILE=${LOCK_PID_FILE:-""}

# Deployment state
DEPLOYMENT_ID=${DEPLOYMENT_ID:-""}
DEPLOYMENT_STATE=${DEPLOYMENT_STATE:-$STATE_PENDING}
DEPLOYMENT_START_TIME=${DEPLOYMENT_START_TIME:-0}

# Statistics
DEPLOY_SERVICES_TOTAL=0
DEPLOY_SERVICES_SUCCESS=0
DEPLOY_SERVICES_FAILED=0
DEPLOY_HOOKS_RUN=0

# Cleanup tracking
declare -a CLEANUP_COMMANDS=()
declare -a TEMP_FILES=()
declare -a DEPLOYED_SERVICES=()

# ==============================================================================
# LOGGING SYSTEM
# ==============================================================================

# Get current timestamp
# Return: ISO 8601 timestamp
get_timestamp() {
    date '+%Y-%m-%d %H:%M:%S'
}

# Get short timestamp for files
# Return: compact format timestamp
get_short_timestamp() {
    date '+%Y%m%d_%H%M%S'
}

# Convert log level to string
# Args: $1 = numeric level
# Return: string representation of level
log_level_to_string() {
    local level=$1
    case $level in
        $LOG_LEVEL_DEBUG) echo "DEBUG" ;;
        $LOG_LEVEL_INFO)  echo "INFO"  ;;
        $LOG_LEVEL_WARN)  echo "WARN"  ;;
        $LOG_LEVEL_ERROR) echo "ERROR" ;;
        $LOG_LEVEL_FATAL) echo "FATAL" ;;
        *)                echo "UNKNOWN" ;;
    esac
}

# Get colour for log level
# Args: $1 = numeric level
# Return: ANSI colour code
log_level_color() {
    local level=$1
    case $level in
        $LOG_LEVEL_DEBUG) echo "$GRAY"   ;;
        $LOG_LEVEL_INFO)  echo "$GREEN"  ;;
        $LOG_LEVEL_WARN)  echo "$YELLOW" ;;
        $LOG_LEVEL_ERROR) echo "$RED"    ;;
        $LOG_LEVEL_FATAL) echo "$RED"    ;;
        *)                echo "$NC"     ;;
    esac
}

# Main logging function
# Args: $1 = level, $2 = message, $3... = optional arguments
_log() {
    local level=$1
    shift
    local message="$*"
    
    # Check if level should be displayed
    [[ $level -lt $CURRENT_LOG_LEVEL ]] && return 0
    
    # Skip if quiet mode (except ERROR and FATAL)
    if [[ "$QUIET" == "true" && $level -lt $LOG_LEVEL_ERROR ]]; then
        return 0
    fi
    
    local timestamp
    timestamp=$(get_timestamp)
    local level_str
    level_str=$(log_level_to_string "$level")
    
    # Format for file (without colours)
    local file_line="[$timestamp] [$level_str] $message"
    
    # Format for terminal
    local term_line
    if [[ "$USE_COLORS" == "true" ]]; then
        local color
        color=$(log_level_color "$level")
        term_line="${GRAY}[$timestamp]${NC} ${color}[$level_str]${NC} $message"
    else
        term_line="$file_line"
    fi
    
    # Output to terminal
    if [[ $level -ge $LOG_LEVEL_ERROR ]]; then
        echo -e "$term_line" >&2
    else
        echo -e "$term_line"
    fi
    
    # Output to file
    if [[ "$LOG_TO_FILE" == "true" && -n "$LOG_FILE" ]]; then
        echo "$file_line" >> "$LOG_FILE" 2>/dev/null || true
    fi
}

# Convenience functions for logging
log_debug() { _log $LOG_LEVEL_DEBUG "$@"; }
log_info()  { _log $LOG_LEVEL_INFO  "$@"; }
log_warn()  { _log $LOG_LEVEL_WARN  "$@"; }
log_error() { _log $LOG_LEVEL_ERROR "$@"; }
log_fatal() { _log $LOG_LEVEL_FATAL "$@"; }

# Log with deployment context
log_deploy() {
    local message="$*"
    if [[ -n "$DEPLOYMENT_ID" ]]; then
        log_info "${SYMBOL_DEPLOY} [$DEPLOYMENT_ID] $message"
    else
        log_info "${SYMBOL_DEPLOY} $message"
    fi
}

# Log for rollback
log_rollback() {
    local message="$*"
    log_warn "${SYMBOL_ROLLBACK} $message"
}

# Visual separator in log
log_separator() {
    local char=${1:-"="}
    local width=${2:-60}
    local line
    line=$(printf "%${width}s" | tr ' ' "$char")
    echo -e "${GRAY}${line}${NC}"
}

# Header for section
log_header() {
    local title="$1"
    local width=${2:-60}
    echo ""
    log_separator "=" "$width"
    echo -e "${CYAN}${title}${NC}"
    log_separator "=" "$width"
}

# Sub-header for subsection
log_subheader() {
    local title="$1"
    echo ""
    echo -e "${BLUE}>>> ${title}${NC}"
    log_separator "-" 40
}

# ==============================================================================
# ERROR HANDLING
# ==============================================================================

# Terminate execution with error message
# Args: $1 = message, $2 = exit code (optional, default 1)
die() {
    local message="$1"
    local exit_code=${2:-1}
    
    log_fatal "$message"
    
    # Cleanup before exit
    cleanup_on_exit
    
    exit "$exit_code"
}

# Check result of last command
# Args: $1 = error message, $2 = exit code (optional)
check_error() {
    local exit_code=$?
    local message=${1:-"An error occurred"}
    local custom_exit=${2:-$exit_code}
    
    if [[ $exit_code -ne 0 ]]; then
        die "$message (exit code: $exit_code)" "$custom_exit"
    fi
}

# Execute command with retry
# Args: $1 = max retries, $2 = delay, $3... = command
run_with_retry() {
    local max_retries=$1
    local delay=$2
    shift 2
    local cmd=("$@")
    
    local attempt=1
    while [[ $attempt -le $max_retries ]]; do
        log_debug "Attempt $attempt/$max_retries: ${cmd[*]}"
        
        if "${cmd[@]}"; then
            return 0
        fi
        
        if [[ $attempt -lt $max_retries ]]; then
            log_warn "Command failed, retrying in ${delay}s..."
            sleep "$delay"
        fi
        
        ((attempt++))
    done
    
    log_error "Command failed after $max_retries attempts: ${cmd[*]}"
    return 1
}

# Execute command with timeout
# Args: $1 = timeout seconds, $2... = command
run_with_timeout() {
    local timeout_sec=$1
    shift
    local cmd=("$@")
    
    if command -v timeout &>/dev/null; then
        timeout "$timeout_sec" "${cmd[@]}"
    else
        # Fallback without timeout
        log_warn "timeout command not available, running without limit"
        "${cmd[@]}"
    fi
}

# ==============================================================================
# VALIDATION FUNCTIONS
# ==============================================================================

# Check if a command exists
# Args: $1 = command name
# Return: 0 if exists, 1 otherwise
command_exists() {
    command -v "$1" &>/dev/null
}

# Require command - die if not found
# Args: $1 = command name, $2 = optional message
require_cmd() {
    local cmd=$1
    local msg=${2:-"Required command not found: $cmd"}
    
    if ! command_exists "$cmd"; then
        die "$msg" 3
    fi
}

# Check if file exists
# Args: $1 = path
require_file() {
    local file=$1
    local msg=${2:-"Required file not found: $file"}
    
    if [[ ! -f "$file" ]]; then
        die "$msg" 3
    fi
}

# Check if directory exists
# Args: $1 = path
require_dir() {
    local dir=$1
    local msg=${2:-"Required directory not found: $dir"}
    
    if [[ ! -d "$dir" ]]; then
        die "$msg" 3
    fi
}

# Check if path is writable
# Args: $1 = path
require_writable() {
    local path=$1
    local msg=${2:-"Path not writable: $path"}
    
    if [[ ! -w "$path" ]]; then
        die "$msg" 3
    fi
}

# Check if string is integer
# Args: $1 = string
is_integer() {
    [[ "$1" =~ ^-?[0-9]+$ ]]
}

# Check if string is positive
# Args: $1 = string
is_positive_integer() {
    [[ "$1" =~ ^[0-9]+$ && "$1" -gt 0 ]]
}

# Check valid port
# Args: $1 = port
is_valid_port() {
    local port=$1
    is_integer "$port" && [[ $port -ge 1 && $port -le 65535 ]]
}

# Check valid URL (basic)
# Args: $1 = URL
is_valid_url() {
    local url=$1
    [[ "$url" =~ ^https?:// ]]
}

# ==============================================================================
# LOCK MANAGEMENT
# ==============================================================================

# Create lock file
# Args: $1 = lock file path
# Return: 0 if lock acquired, 1 otherwise
acquire_lock() {
    local lock_file=${1:-$LOCK_FILE}
    
    if [[ -z "$lock_file" ]]; then
        log_warn "No lock file specified, skipping lock"
        return 0
    fi
    
    # Create directory if it doesn't exist
    local lock_dir
    lock_dir=$(dirname "$lock_file")
    mkdir -p "$lock_dir" 2>/dev/null || true
    
    # Check existing lock
    if [[ -f "$lock_file" ]]; then
        local old_pid
        old_pid=$(cat "$lock_file" 2>/dev/null || echo "")
        
        if [[ -n "$old_pid" ]] && kill -0 "$old_pid" 2>/dev/null; then
            log_error "Another deployment is running (PID: $old_pid)"
            return 1
        else
            log_warn "Removing stale lock file"
            rm -f "$lock_file"
        fi
    fi
    
    # Create lock
    echo $$ > "$lock_file"
    LOCK_FILE="$lock_file"
    LOCK_ACQUIRED=true
    
    log_debug "Lock acquired: $lock_file (PID: $$)"
    return 0
}

# Release lock file
release_lock() {
    if [[ "$LOCK_ACQUIRED" == "true" && -n "$LOCK_FILE" ]]; then
        rm -f "$LOCK_FILE"
        LOCK_ACQUIRED=false
        log_debug "Lock released: $LOCK_FILE"
    fi
}

# ==============================================================================
# CLEANUP MANAGEMENT
# ==============================================================================

# Register cleanup command
# Args: $1 = command to execute at cleanup
register_cleanup() {
    CLEANUP_COMMANDS+=("$1")
}

# Register temporary file for cleanup
# Args: $1 = file path
register_temp_file() {
    TEMP_FILES+=("$1")
}

# Create tracked temporary file
# Args: $1 = prefix (optional)
# Return: path to file
make_temp_file() {
    local prefix=${1:-"deployer"}
    local temp_file
    temp_file=$(mktemp "/tmp/${prefix}.XXXXXX")
    register_temp_file "$temp_file"
    echo "$temp_file"
}

# Create tracked temporary directory
# Args: $1 = prefix (optional)
# Return: path to directory
make_temp_dir() {
    local prefix=${1:-"deployer"}
    local temp_dir
    temp_dir=$(mktemp -d "/tmp/${prefix}.XXXXXX")
    register_temp_file "$temp_dir"
    echo "$temp_dir"
}

# Cleanup on exit
cleanup_on_exit() {
    log_debug "Running cleanup..."
    
    # Run cleanup commands in reverse order
    local i
    for ((i=${#CLEANUP_COMMANDS[@]}-1; i>=0; i--)); do
        local cmd="${CLEANUP_COMMANDS[$i]}"
        log_debug "Cleanup: $cmd"
        eval "$cmd" 2>/dev/null || true
    done
    
    # Delete temporary files
    for temp_file in "${TEMP_FILES[@]}"; do
        if [[ -e "$temp_file" ]]; then
            rm -rf "$temp_file" 2>/dev/null || true
            log_debug "Removed temp: $temp_file"
        fi
    done
    
    # Release lock
    release_lock
}

# Setup trap handlers
setup_traps() {
    trap cleanup_on_exit EXIT
    trap 'die "Interrupted by user" 130' INT
    trap 'die "Terminated" 143' TERM
}

# ==============================================================================
# DEPLOYMENT ID MANAGEMENT
# ==============================================================================

# Generate unique ID for deployment
# Return: deployment ID
generate_deployment_id() {
    local timestamp
    timestamp=$(date '+%Y%m%d%H%M%S')
    local random_suffix
    random_suffix=$(head -c 4 /dev/urandom | xxd -p 2>/dev/null || echo "$$")
    echo "deploy_${timestamp}_${random_suffix}"
}

# Set current deployment ID
# Args: $1 = deployment ID (optional, generated if missing)
set_deployment_id() {
    DEPLOYMENT_ID=${1:-$(generate_deployment_id)}
    DEPLOYMENT_START_TIME=$(date +%s)
    DEPLOYMENT_STATE=$STATE_RUNNING
    log_debug "Deployment ID: $DEPLOYMENT_ID"
}

# Get deployment duration
# Return: duration in seconds
get_deployment_duration() {
    local now
    now=$(date +%s)
    echo $((now - DEPLOYMENT_START_TIME))
}

# ==============================================================================
# HOOK SYSTEM
# ==============================================================================

# Directory with hooks
HOOKS_DIR=${HOOKS_DIR:-""}

# Run hook if it exists
# Args: $1 = hook name, $2... = arguments for hook
run_hook() {
    local hook_name=$1
    shift
    local hook_args=("$@")
    
    if [[ -z "$HOOKS_DIR" ]]; then
        log_debug "No hooks directory configured, skipping hook: $hook_name"
        return 0
    fi
    
    local hook_file="$HOOKS_DIR/$hook_name"
    
    # Check if hook exists
    if [[ ! -f "$hook_file" ]]; then
        log_debug "Hook not found: $hook_name"
        return 0
    fi
    
    # Check if executable
    if [[ ! -x "$hook_file" ]]; then
        log_warn "Hook not executable: $hook_name"
        return 0
    fi
    
    log_info "Running hook: $hook_name"
    ((DEPLOY_HOOKS_RUN++))
    
    # Export context variables
    export DEPLOYMENT_ID
    export DEPLOYMENT_STATE
    export DEPLOY_SERVICES_TOTAL
    export DEPLOY_SERVICES_SUCCESS
    export DEPLOY_SERVICES_FAILED
    
    # Run the hook
    if "$hook_file" "${hook_args[@]}"; then
        log_debug "Hook completed: $hook_name"
        return 0
    else
        log_error "Hook failed: $hook_name"
        return 1
    fi
}

# Standard hooks available
# pre-deploy      - before any deployment
# post-deploy     - after complete deployment
# pre-service     - before deploy service (arg: service_name)
# post-service    - after deploy service (args: service_name, status)
# pre-rollback    - before rollback
# post-rollback   - after rollback
# health-check    - custom health check

# ==============================================================================
# UTILITY FUNCTIONS
# ==============================================================================

# Format bytes in human-readable format
# Args: $1 = bytes
format_bytes() {
    local bytes=$1
    
    if [[ $bytes -lt 1024 ]]; then
        echo "${bytes}B"
    elif [[ $bytes -lt 1048576 ]]; then
        echo "$((bytes / 1024))KB"
    elif [[ $bytes -lt 1073741824 ]]; then
        echo "$((bytes / 1048576))MB"
    else
        echo "$((bytes / 1073741824))GB"
    fi
}

# Format duration in human-readable format
# Args: $1 = seconds
format_duration() {
    local seconds=$1
    
    if [[ $seconds -lt 60 ]]; then
        echo "${seconds}s"
    elif [[ $seconds -lt 3600 ]]; then
        printf "%dm %ds" $((seconds / 60)) $((seconds % 60))
    else
        printf "%dh %dm %ds" $((seconds / 3600)) $(((seconds % 3600) / 60)) $((seconds % 60))
    fi
}

# Get file size
# Args: $1 = path
get_file_size() {
    local file=$1
    if [[ -f "$file" ]]; then
        stat -c%s "$file" 2>/dev/null || stat -f%z "$file" 2>/dev/null || echo 0
    else
        echo 0
    fi
}

# Get file hash
# Args: $1 = path, $2 = algorithm (md5|sha1|sha256)
get_file_hash() {
    local file=$1
    local algo=${2:-md5}
    
    if [[ ! -f "$file" ]]; then
        echo ""
        return 1
    fi
    
    case $algo in
        md5)
            md5sum "$file" 2>/dev/null | cut -d' ' -f1 || md5 -q "$file" 2>/dev/null
            ;;
        sha1)
            sha1sum "$file" 2>/dev/null | cut -d' ' -f1 || shasum "$file" 2>/dev/null | cut -d' ' -f1
            ;;
        sha256)
            sha256sum "$file" 2>/dev/null | cut -d' ' -f1 || shasum -a 256 "$file" 2>/dev/null | cut -d' ' -f1
            ;;
        *)
            log_error "Unknown hash algorithm: $algo"
            return 1
            ;;
    esac
}

# Compare semantic versions
# Args: $1 = version1, $2 = version2
# Return: 0 if v1=v2, 1 if v1>v2, 2 if v1<v2
compare_versions() {
    local v1=$1
    local v2=$2
    
    if [[ "$v1" == "$v2" ]]; then
        return 0
    fi
    
    local IFS='.'
    local i
    local -a ver1=($v1)
    local -a ver2=($v2)
    
    # Pad with zero
    for ((i=${#ver1[@]}; i<${#ver2[@]}; i++)); do
        ver1[i]=0
    done
    for ((i=${#ver2[@]}; i<${#ver1[@]}; i++)); do
        ver2[i]=0
    done
    
    for ((i=0; i<${#ver1[@]}; i++)); do
        if ((10#${ver1[i]} > 10#${ver2[i]})); then
            return 1
        elif ((10#${ver1[i]} < 10#${ver2[i]})); then
            return 2
        fi
    done
    
    return 0
}

# Simple progress bar
# Args: $1 = current, $2 = total, $3 = width (optional)
show_progress_bar() {
    local current=$1
    local total=$2
    local width=${3:-40}
    
    local percent=$((current * 100 / total))
    local filled=$((current * width / total))
    local empty=$((width - filled))
    
    local bar=""
    for ((i=0; i<filled; i++)); do bar+="█"; done
    for ((i=0; i<empty; i++)); do bar+="░"; done
    
    printf "\r${CYAN}[%s]${NC} %3d%% (%d/%d)" "$bar" "$percent" "$current" "$total"
}

# End progress bar
end_progress_bar() {
    echo ""
}

# Confirm action with user
# Args: $1 = message, $2 = default (y/n)
# Return: 0 for yes, 1 for no
confirm() {
    local message=$1
    local default=${2:-"n"}
    
    local prompt
    if [[ "$default" == "y" ]]; then
        prompt="[Y/n]"
    else
        prompt="[y/N]"
    fi
    
    read -r -p "$message $prompt " response
    
    if [[ -z "$response" ]]; then
        response=$default
    fi
    
    [[ "$response" =~ ^[Yy]$ ]]
}

# ==============================================================================
# SERVICE TRACKING
# ==============================================================================

# Register deployed service
# Args: $1 = service name, $2 = version, $3 = path
register_deployed_service() {
    local service=$1
    local version=${2:-"unknown"}
    local path=${3:-""}
    
    DEPLOYED_SERVICES+=("$service:$version:$path")
    ((DEPLOY_SERVICES_SUCCESS++))
}

# Get list of deployed services
get_deployed_services() {
    printf '%s\n' "${DEPLOYED_SERVICES[@]}"
}

# ==============================================================================
# ENVIRONMENT UTILITIES
# ==============================================================================

# Check if running in Docker
is_docker() {
    [[ -f /.dockerenv ]] || grep -q docker /proc/1/cgroup 2>/dev/null
}

# Check if running as root
is_root() {
    [[ $EUID -eq 0 ]]
}

# Check if systemd is available
has_systemd() {
    command_exists systemctl && [[ -d /run/systemd/system ]]
}

# Get hostname
get_hostname() {
    hostname 2>/dev/null || cat /etc/hostname 2>/dev/null || echo "localhost"
}

# Get primary IP
get_primary_ip() {
    hostname -I 2>/dev/null | awk '{print $1}' || \
    ip route get 1 2>/dev/null | awk '{print $(NF-2);exit}' || \
    echo "127.0.0.1"
}

# ==============================================================================
# EXPORT
# ==============================================================================

# Export functions for sub-shells
export -f log_debug log_info log_warn log_error log_fatal
export -f die check_error run_with_retry run_with_timeout
export -f command_exists require_cmd require_file require_dir
export -f acquire_lock release_lock
export -f run_hook
export -f format_bytes format_duration
export -f is_docker is_root has_systemd
