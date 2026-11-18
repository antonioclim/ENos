#!/bin/bash
#==============================================================================
# core.sh - Fundamental function library for System Monitor
#==============================================================================
# DESCRIPTION:
#   Core functions for logging, error handling, and validation.
#   This module represents the architectural foundation of the application.
#
# USAGE:
#   source "${SCRIPT_DIR}/lib/core.sh"
#
# AUTHOR: ASE Bucharest - CSIE | Operating Systems
# VERSION: 1.0.0
#==============================================================================

#------------------------------------------------------------------------------
# GLOBAL CONSTANTS
#------------------------------------------------------------------------------
readonly CORE_VERSION="1.0.0"
readonly LOG_LEVELS=(DEBUG INFO WARN ERROR FATAL)

# ANSI colour codes (for terminal output)
readonly COLOR_RESET='\033[0m'
readonly COLOR_RED='\033[0;31m'
readonly COLOR_GREEN='\033[0;32m'
readonly COLOR_YELLOW='\033[0;33m'
readonly COLOR_BLUE='\033[0;34m'
readonly COLOR_MAGENTA='\033[0;35m'
readonly COLOR_CYAN='\033[0;36m'
readonly COLOR_BOLD='\033[1m'

#------------------------------------------------------------------------------
# CONFIGURATION VARIABLES (can be overridden)
#------------------------------------------------------------------------------
LOG_LEVEL="${LOG_LEVEL:-INFO}"
LOG_FILE="${LOG_FILE:-}"
LOG_TO_STDOUT="${LOG_TO_STDOUT:-true}"
LOG_TIMESTAMP_FORMAT="${LOG_TIMESTAMP_FORMAT:-%Y-%m-%d %H:%M:%S}"
LOG_USE_COLORS="${LOG_USE_COLORS:-true}"

#------------------------------------------------------------------------------
# LOGGING FUNCTIONS
#------------------------------------------------------------------------------

# Get formatted current timestamp
_get_timestamp() {
    date "+${LOG_TIMESTAMP_FORMAT}"
}

# Convert log level to numeric index for comparison
_log_level_to_int() {
    local level="$1"
    case "$level" in
        DEBUG) echo 0 ;;
        INFO)  echo 1 ;;
        WARN)  echo 2 ;;
        ERROR) echo 3 ;;
        FATAL) echo 4 ;;
        *)     echo 1 ;;  # Default INFO
    esac
}

# Get colour for a log level
_get_level_color() {
    local level="$1"
    case "$level" in
        DEBUG) echo "$COLOR_CYAN" ;;
        INFO)  echo "$COLOR_GREEN" ;;
        WARN)  echo "$COLOR_YELLOW" ;;
        ERROR) echo "$COLOR_RED" ;;
        FATAL) echo "${COLOR_BOLD}${COLOR_RED}" ;;
        *)     echo "$COLOR_RESET" ;;
    esac
}

# Check if a message should be logged based on level
_should_log() {
    local msg_level="$1"
    local current_level="${LOG_LEVEL:-INFO}"
    
    local msg_int=$(_log_level_to_int "$msg_level")
    local current_int=$(_log_level_to_int "$current_level")
    
    [[ $msg_int -ge $current_int ]]
}

# Main logging function
# Usage: log LEVEL "message"
log() {
    local level="${1:-INFO}"
    shift
    local message="$*"
    
    # Check if should be logged
    _should_log "$level" || return 0
    
    local timestamp=$(_get_timestamp)
    local formatted_msg
    
    # Format with or without colours
    if [[ "$LOG_USE_COLORS" == "true" ]] && [[ -t 1 ]]; then
        local color=$(_get_level_color "$level")
        formatted_msg="${color}[${timestamp}] [${level}]${COLOR_RESET} ${message}"
    else
        formatted_msg="[${timestamp}] [${level}] ${message}"
    fi
    
    # Output to stdout if enabled
    if [[ "$LOG_TO_STDOUT" == "true" ]]; then
        if [[ "$level" == "ERROR" ]] || [[ "$level" == "FATAL" ]]; then
            echo -e "$formatted_msg" >&2
        else
            echo -e "$formatted_msg" >&2
        fi
    fi
    
    # Output to file if configured
    if [[ -n "$LOG_FILE" && -d "$(dirname "$LOG_FILE")" ]]; then
        # No colours in file
        local file_msg="[${timestamp}] [${level}] ${message}"
        printf '%s\n' "$file_msg" >> "$LOG_FILE"
    fi
    return 0
}

# Shorthand functions for different levels
log_debug() { log DEBUG "$@"; }
log_info()  { log INFO "$@"; }
log_warn()  { log WARN "$@"; }
log_error() { log ERROR "$@"; }
log_fatal() { log FATAL "$@"; }

#------------------------------------------------------------------------------
# ERROR HANDLING FUNCTIONS
#------------------------------------------------------------------------------

# Terminate script with error message
# Usage: die "error message" [exit_code]
die() {
    local message="${1:-Unknown error}"
    local exit_code="${2:-1}"
    
    log_fatal "$message"
    
    # Cleanup before exit (if function exists)
    if declare -f cleanup &>/dev/null; then
        cleanup
    fi
    
    exit "$exit_code"
}

# Check return code of last command
# Usage: check_error "message if fails"
check_error() {
    local exit_code=$?
    local message="${1:-Previous command failed}"
    
    if [[ $exit_code -ne 0 ]]; then
        die "$message (exit code: $exit_code)"
    fi
}

# Execute a command with logging and error checking
# Usage: run_cmd "description" command args...
run_cmd() {
    local description="$1"
    shift
    
    log_debug "Executing: $description"
    log_debug "Command: $*"
    
    if "$@"; then
        log_debug "Success: $description"
        return 0
    else
        local exit_code=$?
        log_error "Failure: $description (exit code: $exit_code)"
        return $exit_code
    fi
}

#------------------------------------------------------------------------------
# VALIDATION FUNCTIONS
#------------------------------------------------------------------------------

# Check if a command exists in PATH
# Usage: require_cmd "git" "jq" "curl"
require_cmd() {
    local missing=()
    
    for cmd in "$@"; do
        if ! command -v "$cmd" &>/dev/null; then
            missing+=("$cmd")
        fi
    done
    
    if [[ ${#missing[@]} -gt 0 ]]; then
        die "Missing commands: ${missing[*]}. Install them and try again."
    fi
    
    log_debug "All required commands are available: $*"
}

# Check if a file exists and is readable
# Usage: require_file "/path/to/file"
require_file() {
    local file="$1"
    local description="${2:-File}"
    
    if [[ ! -f "$file" ]]; then
        die "$description does not exist: $file"
    fi
    
    if [[ ! -r "$file" ]]; then
        die "$description cannot be read: $file"
    fi
    
    log_debug "$description valid: $file"
}

# Check if a directory exists
# Usage: require_dir "/path/to/dir" [create_if_missing]
require_dir() {
    local dir="$1"
    local create="${2:-false}"
    local description="${3:-Directory}"
    
    if [[ ! -d "$dir" ]]; then
        if [[ "$create" == "true" ]]; then
            mkdir -p "$dir" || die "Cannot create directory: $dir"
            log_info "Directory created: $dir"
        else
            die "$description does not exist: $dir"
        fi
    fi
    
    log_debug "$description valid: $dir"
}

# Check if a variable is set and non-empty
# Usage: require_var "VAR_NAME" "$VAR_VALUE"
require_var() {
    local var_name="$1"
    local var_value="$2"
    
    if [[ -z "$var_value" ]]; then
        die "Variable $var_name is not set or is empty"
    fi
    
    log_debug "Variable valid: $var_name"
}

# Check if a value is an integer
# Usage: is_integer "$value"
is_integer() {
    local value="$1"
    [[ "$value" =~ ^-?[0-9]+$ ]]
}

# Check if a value is within range
# Usage: in_range "$value" $min $max
in_range() {
    local value="$1"
    local min="$2"
    local max="$3"
    
    is_integer "$value" || return 1
    [[ $value -ge $min ]] && [[ $value -le $max ]]
}

#------------------------------------------------------------------------------
# LOCK FILE FUNCTIONS (preventing concurrent executions)
#------------------------------------------------------------------------------

# Acquire an exclusive lock
# Usage: acquire_lock "/path/to/lockfile"
acquire_lock() {
    local lock_file="$1" wait_seconds="${2:-0}"
    command -v flock >/dev/null || { log_error "flock is required"; return 1; }
    mkdir -p -- "$(dirname "$lock_file")" || return 1
    exec {MONITOR_LOCK_FD}>"$lock_file" || return 1
    if ! flock -w "$wait_seconds" "$MONITOR_LOCK_FD"; then
        exec {MONITOR_LOCK_FD}>&-
        unset MONITOR_LOCK_FD
        return 1
    fi
    printf '%s\n' "$$" >&"$MONITOR_LOCK_FD"
    return 0
}

# Release a lock
# Usage: release_lock "/path/to/lockfile"
release_lock() {
    if [[ -n "${MONITOR_LOCK_FD:-}" ]]; then
        flock -u "$MONITOR_LOCK_FD" || return 1
        exec {MONITOR_LOCK_FD}>&-
        unset MONITOR_LOCK_FD
    fi
    # Keep the inode: unlinking would permit another independent lock.
    return 0
}

#------------------------------------------------------------------------------
# TRAP HANDLING FUNCTIONS
#------------------------------------------------------------------------------

# Default handler for termination signals
_default_trap_handler() {
    local signal="$1"
    log_warn "Signal received: $signal"
    
    # Call cleanup if it exists
    if declare -f cleanup &>/dev/null; then
        cleanup
    fi
    
    exit 130  # 128 + 2 (SIGINT)
}

# Configure standard trap handlers
# Usage: setup_traps [cleanup_function_name]
setup_traps() {
    local cleanup_func="${1:-cleanup}"
    
    trap "_default_trap_handler INT" INT
    trap "_default_trap_handler TERM" TERM
    trap "_default_trap_handler HUP" HUP
    
    # EXIT trap - final cleanup
    if declare -f "$cleanup_func" &>/dev/null; then
        trap "$cleanup_func" EXIT
    fi
    
    log_debug "Trap handlers configured"
}

#------------------------------------------------------------------------------
# UTILITY FUNCTIONS
#------------------------------------------------------------------------------

# Display a visual separator in log
log_separator() {
    local char="${1:--}"
    local length="${2:-60}"
    local line
    line=$(printf '%*s' "$length" '' | tr ' ' "$char")
    log_info "$line"
}

# Display header for a section
log_header() {
    local title="$1"
    log_separator "="
    log_info "$title"
    log_separator "="
}

# Format bytes in human-readable format
format_bytes() {
    local bytes="$1"
    local units=("B" "KB" "MB" "GB" "TB")
    local unit=0
    
    # Convert to float for calculation
    local size=$bytes
    
    while [[ $(echo "$size >= 1024" | bc -l 2>/dev/null || echo 0) -eq 1 ]] && [[ $unit -lt 4 ]]; do
        size=$(echo "scale=2; $size / 1024" | bc -l)
        unit=$((unit + 1))
    done
    
    printf "%.2f %s" "$size" "${units[$unit]}"
}

# Format seconds in human-readable format
format_duration() {
    local seconds="$1"
    local days=$((seconds / 86400))
    local hours=$(((seconds % 86400) / 3600))
    local minutes=$(((seconds % 3600) / 60))
    local secs=$((seconds % 60))
    
    if [[ $days -gt 0 ]]; then
        printf "%dd %02d:%02d:%02d" "$days" "$hours" "$minutes" "$secs"
    elif [[ $hours -gt 0 ]]; then
        printf "%02d:%02d:%02d" "$hours" "$minutes" "$secs"
    else
        printf "%02d:%02d" "$minutes" "$secs"
    fi
}

#------------------------------------------------------------------------------
# INITIALISATION
#------------------------------------------------------------------------------

# Loading message for debugging
log_debug "core.sh v${CORE_VERSION} loaded"
