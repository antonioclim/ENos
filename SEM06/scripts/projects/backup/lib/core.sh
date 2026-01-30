#!/bin/bash
#==============================================================================
# core.sh - Fundamental function library for Backup System
#==============================================================================
# DESCRIPTION:
#   Core functions for logging, error handling, lock management.
#   This library is similar to the one in monitor, but adapted for
#   backup operations (more detailed logging, progress tracking).
#
# AUTHOR: ASE Bucharest - CSIE | Operating Systems
# VERSION: 1.0.0
#==============================================================================

readonly CORE_VERSION="1.0.0"

#------------------------------------------------------------------------------
# COLOURS AND FORMATTING
#------------------------------------------------------------------------------
readonly COLOR_RESET='\033[0m'
readonly COLOR_RED='\033[0;31m'
readonly COLOR_GREEN='\033[0;32m'
readonly COLOR_YELLOW='\033[0;33m'
readonly COLOR_BLUE='\033[0;34m'
readonly COLOR_CYAN='\033[0;36m'
readonly COLOR_BOLD='\033[1m'

#------------------------------------------------------------------------------
# LOGGING CONFIGURATION
#------------------------------------------------------------------------------
LOG_LEVEL="${LOG_LEVEL:-INFO}"
LOG_FILE="${LOG_FILE:-}"
LOG_TO_STDOUT="${LOG_TO_STDOUT:-true}"
LOG_USE_COLORS="${LOG_USE_COLORS:-true}"
LOG_TIMESTAMP_FORMAT="${LOG_TIMESTAMP_FORMAT:-%Y-%m-%d %H:%M:%S}"

# Statistics for final report
declare -g BACKUP_START_TIME=0
declare -g BACKUP_FILES_COUNT=0
declare -g BACKUP_TOTAL_SIZE=0
declare -g BACKUP_ERRORS=0

#------------------------------------------------------------------------------
# LOGGING FUNCTIONS
#------------------------------------------------------------------------------

_get_timestamp() {
    date "+${LOG_TIMESTAMP_FORMAT}"
}

_log_level_to_int() {
    case "$1" in
        DEBUG) echo 0 ;;
        INFO)  echo 1 ;;
        WARN)  echo 2 ;;
        ERROR) echo 3 ;;
        FATAL) echo 4 ;;
        *)     echo 1 ;;
    esac
}

_get_level_color() {
    case "$1" in
        DEBUG) echo "$COLOR_CYAN" ;;
        INFO)  echo "$COLOR_GREEN" ;;
        WARN)  echo "$COLOR_YELLOW" ;;
        ERROR) echo "$COLOR_RED" ;;
        FATAL) echo "${COLOR_BOLD}${COLOR_RED}" ;;
        *)     echo "$COLOR_RESET" ;;
    esac
}

_should_log() {
    local msg_level="$1"
    local msg_int=$(_log_level_to_int "$msg_level")
    local current_int=$(_log_level_to_int "$LOG_LEVEL")
    [[ $msg_int -ge $current_int ]]
}

log() {
    local level="${1:-INFO}"
    shift
    local message="$*"
    
    _should_log "$level" || return 0
    
    local timestamp=$(_get_timestamp)
    local formatted_msg
    
    if [[ "$LOG_USE_COLORS" == "true" ]] && [[ -t 1 ]]; then
        local color=$(_get_level_color "$level")
        formatted_msg="${color}[${timestamp}] [${level}]${COLOR_RESET} ${message}"
    else
        formatted_msg="[${timestamp}] [${level}] ${message}"
    fi
    
    if [[ "$LOG_TO_STDOUT" == "true" ]]; then
        if [[ "$level" == "ERROR" ]] || [[ "$level" == "FATAL" ]]; then
            echo -e "$formatted_msg" >&2
        else
            echo -e "$formatted_msg"
        fi
    fi
    
    if [[ -n "$LOG_FILE" ]]; then
        echo "[${timestamp}] [${level}] ${message}" >> "$LOG_FILE"
    fi
}

log_debug() { log DEBUG "$@"; }
log_info()  { log INFO "$@"; }
log_warn()  { log WARN "$@"; }
log_error() { log ERROR "$@"; ((BACKUP_ERRORS++)); }
log_fatal() { log FATAL "$@"; ((BACKUP_ERRORS++)); }

#------------------------------------------------------------------------------
# PROGRESS FUNCTIONS
#------------------------------------------------------------------------------

# Display progress bar
# Usage: show_progress current total [width]
show_progress() {
    local current="$1"
    local total="$2"
    local width="${3:-50}"
    
    if [[ $total -eq 0 ]]; then
        return
    fi
    
    local percent=$((current * 100 / total))
    local filled=$((percent * width / 100))
    local empty=$((width - filled))
    
    # Build bar
    local bar=""
    for ((i=0; i<filled; i++)); do bar+="█"; done
    for ((i=0; i<empty; i++)); do bar+="░"; done
    
    # Display (with carriage return to overwrite)
    printf "\r[%s] %3d%% (%d/%d)" "$bar" "$percent" "$current" "$total"
    
    # Newline at end
    if [[ $current -eq $total ]]; then
        echo ""
    fi
}

# Display spinner for long operations
# Usage: start_spinner "message" & SPINNER_PID=$!; ...; stop_spinner $SPINNER_PID
start_spinner() {
    local message="${1:-Processing...}"
    local spinstr='|/-\'
    
    while true; do
        for ((i=0; i<${#spinstr}; i++)); do
            printf "\r[%c] %s" "${spinstr:$i:1}" "$message"
            sleep 0.1
        done
    done
}

stop_spinner() {
    local pid="$1"
    kill "$pid" 2>/dev/null
    wait "$pid" 2>/dev/null
    printf "\r%*s\r" 80 ""  # Clear line
}

#------------------------------------------------------------------------------
# ERROR HANDLING
#------------------------------------------------------------------------------

die() {
    local message="${1:-Unknown error}"
    local exit_code="${2:-1}"
    
    log_fatal "$message"
    
    if declare -f cleanup &>/dev/null; then
        cleanup
    fi
    
    exit "$exit_code"
}

check_error() {
    local exit_code=$?
    local message="${1:-Previous command failed}"
    
    if [[ $exit_code -ne 0 ]]; then
        log_error "$message (exit code: $exit_code)"
        return $exit_code
    fi
    return 0
}

# Execute with retry
# Usage: run_with_retry 3 5 "command" arg1 arg2
run_with_retry() {
    local max_attempts="$1"
    local delay="$2"
    shift 2
    
    local attempt=1
    while [[ $attempt -le $max_attempts ]]; do
        if "$@"; then
            return 0
        fi
        
        log_warn "Attempt $attempt/$max_attempts failed. Waiting ${delay}s..."
        sleep "$delay"
        ((attempt++))
    done
    
    log_error "All $max_attempts attempts failed"
    return 1
}

#------------------------------------------------------------------------------
# VALIDATION
#------------------------------------------------------------------------------

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
}

require_file() {
    local file="$1"
    local description="${2:-File}"
    
    [[ -f "$file" ]] || die "$description does not exist: $file"
    [[ -r "$file" ]] || die "$description cannot be read: $file"
}

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
}

require_space() {
    local path="$1"
    local required_mb="$2"
    
    local available_mb
    available_mb=$(df -m "$path" 2>/dev/null | awk 'NR==2 {print $4}')
    
    if [[ -z "$available_mb" ]]; then
        log_warn "Cannot check available space for: $path"
        return 0
    fi
    
    if [[ $available_mb -lt $required_mb ]]; then
        die "Insufficient space in $path: ${available_mb}MB available, ${required_mb}MB required"
    fi
    
    log_debug "Available space in $path: ${available_mb}MB"
}

is_integer() {
    [[ "$1" =~ ^-?[0-9]+$ ]]
}

in_range() {
    local value="$1" min="$2" max="$3"
    is_integer "$value" && [[ $value -ge $min ]] && [[ $value -le $max ]]
}

#------------------------------------------------------------------------------
# LOCK FILES
#------------------------------------------------------------------------------

acquire_lock() {
    local lock_file="$1"
    
    if [[ -f "$lock_file" ]]; then
        local existing_pid
        existing_pid=$(cat "$lock_file" 2>/dev/null)
        
        if [[ -n "$existing_pid" ]] && kill -0 "$existing_pid" 2>/dev/null; then
            log_error "Backup already running (PID: $existing_pid)"
            return 1
        fi
        
        log_warn "Stale lock file found, removing it"
        rm -f "$lock_file"
    fi
    
    mkdir -p "$(dirname "$lock_file")" 2>/dev/null
    echo $$ > "$lock_file" || die "Cannot create lock file: $lock_file"
    
    log_debug "Lock acquired: $lock_file"
    return 0
}

release_lock() {
    local lock_file="$1"
    
    if [[ -f "$lock_file" ]]; then
        local stored_pid
        stored_pid=$(cat "$lock_file" 2>/dev/null)
        
        if [[ "$stored_pid" == "$$" ]]; then
            rm -f "$lock_file"
            log_debug "Lock released: $lock_file"
        fi
    fi
}

#------------------------------------------------------------------------------
# UTILITIES
#------------------------------------------------------------------------------

format_bytes() {
    local bytes="$1"
    local units=("B" "KB" "MB" "GB" "TB")
    local unit=0
    local size=$bytes
    
    while [[ $(echo "$size >= 1024" | bc -l 2>/dev/null || echo 0) -eq 1 ]] && [[ $unit -lt 4 ]]; do
        size=$(echo "scale=2; $size / 1024" | bc -l 2>/dev/null || echo "$size")
        ((unit++))
    done
    
    printf "%.2f %s" "$size" "${units[$unit]}"
}

format_duration() {
    local seconds="$1"
    local hours=$((seconds / 3600))
    local minutes=$(((seconds % 3600) / 60))
    local secs=$((seconds % 60))
    
    if [[ $hours -gt 0 ]]; then
        printf "%dh %02dm %02ds" "$hours" "$minutes" "$secs"
    elif [[ $minutes -gt 0 ]]; then
        printf "%dm %02ds" "$minutes" "$secs"
    else
        printf "%ds" "$secs"
    fi
}

log_separator() {
    local char="${1:--}"
    local length="${2:-60}"
    printf '%*s\n' "$length" '' | tr ' ' "$char"
}

log_header() {
    local title="$1"
    log_separator "="
    log_info "$title"
    log_separator "="
}

# Generate unique name for backup
generate_backup_name() {
    local type="${1:-full}"
    local format="${2:-%Y%m%d_%H%M%S}"
    
    echo "backup_${type}_$(date "+$format")"
}

# Verify archive integrity
verify_archive() {
    local archive="$1"
    local type="${archive##*.}"
    
    case "$type" in
        gz|tgz)
            gzip -t "$archive" 2>/dev/null
            ;;
        bz2)
            bzip2 -t "$archive" 2>/dev/null
            ;;
        xz)
            xz -t "$archive" 2>/dev/null
            ;;
        tar)
            tar -tf "$archive" &>/dev/null
            ;;
        *)
            log_warn "Unknown archive type for verification: $type"
            return 0
            ;;
    esac
}

#------------------------------------------------------------------------------
# TRAP HANDLERS
#------------------------------------------------------------------------------

setup_traps() {
    trap 'cleanup' EXIT
    trap 'log_warn "Interrupted (SIGINT)"; exit 130' INT
    trap 'log_warn "Terminated (SIGTERM)"; exit 143' TERM
}

#------------------------------------------------------------------------------
# INITIALISATION
#------------------------------------------------------------------------------

log_debug "core.sh v${CORE_VERSION} loaded (backup)"
