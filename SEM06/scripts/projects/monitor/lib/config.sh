#!/bin/bash
#==============================================================================
# config.sh - Configuration management for System Monitor
#==============================================================================
# DESCRIPTION:
#   Functions for loading, validating and managing configuration.
#   Supports configuration files, environment variables and CLI arguments.
#
# PRIORITY ORDER (from lowest to highest):
#   1. Hardcoded default values
#   2. Configuration file (/etc/sysmonitor.conf or $CONFIG_FILE)
#   3. Environment variables
#   4. Command line arguments
#
# AUTHOR: ASE Bucharest - CSIE | Operating Systems
# VERSION: 1.0.0
#==============================================================================

readonly CONFIG_VERSION="1.0.0"
# Capture explicitly exported values before defaults/file loading.
declare -gA MONITOR_ENV_OVERRIDES=()
for _key in THRESHOLD_CPU THRESHOLD_MEM THRESHOLD_DISK THRESHOLD_SWAP THRESHOLD_LOAD_MULT MONITOR_INTERVAL LOG_FILE LOG_LEVEL LOG_MAX_SIZE LOG_ROTATE_COUNT LOG_USE_COLORS NOTIFY_EMAIL NOTIFY_SLACK_WEBHOOK NOTIFY_ON_RECOVERY DRY_RUN VERBOSE DAEMON_MODE OUTPUT_FORMAT LOCK_FILE LOG_DIR RUN_DIR; do
    if [[ "$(declare -p "$_key" 2>/dev/null || true)" == "declare -x "* ]]; then
        MONITOR_ENV_OVERRIDES["$_key"]="${!_key}"
    fi
done
unset _key


#------------------------------------------------------------------------------
# DEFAULT VALUES
#------------------------------------------------------------------------------

# Alert thresholds (percentages)
declare -g THRESHOLD_CPU="${THRESHOLD_CPU:-80}"
declare -g THRESHOLD_MEM="${THRESHOLD_MEM:-90}"
declare -g THRESHOLD_DISK="${THRESHOLD_DISK:-85}"
declare -g THRESHOLD_SWAP="${THRESHOLD_SWAP:-50}"
declare -g THRESHOLD_LOAD_MULT="${THRESHOLD_LOAD_MULT:-2}"

# Monitoring interval (seconds)
declare -g MONITOR_INTERVAL="${MONITOR_INTERVAL:-60}"

# Logging configuration
declare -g LOG_FILE="${LOG_FILE:-}"
declare -g LOG_LEVEL="${LOG_LEVEL:-INFO}"
declare -g LOG_MAX_SIZE="${LOG_MAX_SIZE:-10485760}"  # 10MB
declare -g LOG_ROTATE_COUNT="${LOG_ROTATE_COUNT:-5}"

# Notification configuration
declare -g NOTIFY_EMAIL="${NOTIFY_EMAIL:-}"
declare -g NOTIFY_SLACK_WEBHOOK="${NOTIFY_SLACK_WEBHOOK:-}"
declare -g NOTIFY_ON_RECOVERY="${NOTIFY_ON_RECOVERY:-true}"

# Options
declare -g DRY_RUN="${DRY_RUN:-false}"
declare -g VERBOSE="${VERBOSE:-false}"
declare -g DAEMON_MODE="${DAEMON_MODE:-false}"
declare -g OUTPUT_FORMAT="${OUTPUT_FORMAT:-text}"  # text, json, csv

# Exclusions (mount points to ignore)
declare -ga DISK_EXCLUDE_MOUNTS=()

# Lock file
declare -g LOCK_FILE="${LOCK_FILE:-}"

#------------------------------------------------------------------------------
# PATH CONFIGURATION
#------------------------------------------------------------------------------

# Detect script directory
_detect_script_dir() {
    local script_path="${BASH_SOURCE[1]:-$0}"
    local script_dir
    
    # Resolve symlinks
    while [[ -L "$script_path" ]]; do
        script_dir=$(cd -P "$(dirname "$script_path")" && pwd)
        script_path=$(readlink "$script_path")
        [[ "$script_path" != /* ]] && script_path="$script_dir/$script_path"
    done
    
    script_dir=$(cd -P "$(dirname "$script_path")" && pwd)
    echo "$script_dir"
}

# Set paths based on script location
_setup_paths() {
    : "${SCRIPT_DIR:=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
    : "${PROJECT_DIR:=$SCRIPT_DIR}" "${LIB_DIR:=$SCRIPT_DIR/lib}"
    : "${ETC_DIR:=$SCRIPT_DIR/etc}" "${VAR_DIR:=$SCRIPT_DIR/var}"
    : "${LOG_DIR:=$VAR_DIR/log}" "${RUN_DIR:=$VAR_DIR/run}"
    : "${DEFAULT_CONFIG_FILE:=$ETC_DIR/monitor.conf}"
    : "${LOCK_FILE:=$RUN_DIR/monitor.lock}" "${LOG_FILE:=$LOG_DIR/monitor.log}"
    return 0
}

#------------------------------------------------------------------------------
# CONFIGURATION LOADING FUNCTIONS
#------------------------------------------------------------------------------

# Load configuration from a file
# File format: KEY=value (shell-style)
load_config_file() {
    local config_file="${1:-$DEFAULT_CONFIG_FILE}" parsed key value
    [[ -r "$config_file" ]] || { log_error "Cannot read config: $config_file"; return 1; }
    parsed=$(mktemp) || return 1
    if ! python3 "$(dirname "${BASH_SOURCE[0]}")/../../config_data.py" "$config_file" THRESHOLD_CPU THRESHOLD_MEM THRESHOLD_DISK THRESHOLD_SWAP THRESHOLD_LOAD_MULT MONITOR_INTERVAL LOG_FILE LOG_LEVEL LOG_MAX_SIZE LOG_ROTATE_COUNT LOG_USE_COLORS NOTIFY_EMAIL NOTIFY_SLACK_WEBHOOK NOTIFY_ON_RECOVERY DRY_RUN VERBOSE DAEMON_MODE OUTPUT_FORMAT LOCK_FILE LOG_DIR RUN_DIR DISK_EXCLUDE_MOUNTS[] > "$parsed"; then
        rm -f -- "$parsed"; return 1
    fi
    while IFS= read -r -d '' key && IFS= read -r -d '' value; do
        case "$key" in
            DISK_EXCLUDE_MOUNTS__RESET) DISK_EXCLUDE_MOUNTS=() ;;
            DISK_EXCLUDE_MOUNTS) DISK_EXCLUDE_MOUNTS+=("$value") ;;
            *) printf -v "$key" '%s' "$value" ;;
        esac
    done < "$parsed"
    rm -f -- "$parsed"
    return 0
}

# Parse command line arguments
# Usage: parse_args "$@"
parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -c|--config|--cpu-threshold|--mem-threshold|--disk-threshold|-i|--interval|-l|--log-file|--log-level|-e|--email|-o|--output|--exclude-mount)
                [[ $# -ge 2 && -n "$2" ]] || { log_error "Missing value for $1"; return 1; } ;;
        esac
        case "$1" in
            -c|--config)
                CONFIG_FILE="$2"
                shift 2
                ;;
            --cpu-threshold)
                THRESHOLD_CPU="$2"
                shift 2
                ;;
            --mem-threshold)
                THRESHOLD_MEM="$2"
                shift 2
                ;;
            --disk-threshold)
                THRESHOLD_DISK="$2"
                shift 2
                ;;
            -i|--interval)
                MONITOR_INTERVAL="$2"
                shift 2
                ;;
            -l|--log-file)
                LOG_FILE="$2"
                shift 2
                ;;
            --log-level)
                LOG_LEVEL="$2"
                shift 2
                ;;
            -e|--email)
                NOTIFY_EMAIL="$2"
                shift 2
                ;;
            -d|--daemon)
                DAEMON_MODE="true"
                shift
                ;;
            -n|--dry-run)
                DRY_RUN="true"
                shift
                ;;
            -v|--verbose)
                VERBOSE="true"
                LOG_LEVEL="DEBUG"
                shift
                ;;
            -o|--output)
                OUTPUT_FORMAT="$2"
                shift 2
                ;;
            --exclude-mount)
                DISK_EXCLUDE_MOUNTS+=("$2")
                shift 2
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            --version)
                show_version
                exit 0
                ;;
            --)
                shift
                break
                ;;
            -*)
                log_error "Unknown option: $1"
                show_help
                exit 1
                ;;
            *)
                # Positional argument
                shift
                ;;
        esac
    done
}

#------------------------------------------------------------------------------
# CONFIGURATION VALIDATION
#------------------------------------------------------------------------------

# Validate all configuration settings
validate_config() {
    local errors=0
    
    # Validate thresholds
    for threshold_var in THRESHOLD_CPU THRESHOLD_MEM THRESHOLD_DISK THRESHOLD_SWAP; do
        local value="${!threshold_var}"
        if ! is_integer "$value" || ! in_range "$value" 0 100; then
            log_error "Invalid value for $threshold_var: $value (must be 0-100)"
            errors=$((errors + 1))
        fi
    done
    
    # Validate interval
    if ! is_integer "$MONITOR_INTERVAL" || [[ $MONITOR_INTERVAL -lt 1 ]]; then
        log_error "Invalid monitoring interval: $MONITOR_INTERVAL (must be >= 1)"
        errors=$((errors + 1))
    fi
    
    if ! is_integer "$THRESHOLD_LOAD_MULT" || (( THRESHOLD_LOAD_MULT < 1 )); then
        log_error "Invalid load multiplier"; errors=$((errors + 1))
    fi
    # Validate log level
    case "$LOG_LEVEL" in
        DEBUG|INFO|WARN|ERROR|FATAL) ;;
        *)
            log_error "Invalid logging level: $LOG_LEVEL"
            errors=$((errors + 1))
            ;;
    esac
    
    # Validate output format
    case "$OUTPUT_FORMAT" in
        text|json|csv) ;;
        *)
            log_error "Invalid output format: $OUTPUT_FORMAT (must be: text, json, csv)"
            errors=$((errors + 1))
            ;;
    esac
    
    # Validate email (if set)
    if [[ -n "$NOTIFY_EMAIL" ]] && ! [[ "$NOTIFY_EMAIL" =~ ^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$ ]]; then
        log_warn "Possibly invalid email format: $NOTIFY_EMAIL"
    fi
    
    # Create necessary directories
    for dir in "$LOG_DIR" "$RUN_DIR"; do
        if [[ ! -d "$dir" ]]; then
            mkdir -p "$dir" 2>/dev/null || {
                log_error "Cannot create directory: $dir"
                errors=$((errors + 1))
            }
        fi
    done
    
    return $errors
}

#------------------------------------------------------------------------------
# CONFIGURATION DISPLAY
#------------------------------------------------------------------------------

# Display current configuration
show_config() {
    cat << EOF
=== CURRENT CONFIGURATION ===

THRESHOLDS:
  CPU:        ${THRESHOLD_CPU}%
  Memory:     ${THRESHOLD_MEM}%
  Disk:       ${THRESHOLD_DISK}%
  Swap:       ${THRESHOLD_SWAP}%
  Load Mult:  ${THRESHOLD_LOAD_MULT}x

MONITORING:
  Interval:   ${MONITOR_INTERVAL}s
  Daemon:     ${DAEMON_MODE}
  Dry-run:    ${DRY_RUN}
  Output:     ${OUTPUT_FORMAT}

LOGGING:
  File:       ${LOG_FILE:-<stdout>}
  Level:      ${LOG_LEVEL}
  Max size:   ${LOG_MAX_SIZE} bytes
  Rotations:  ${LOG_ROTATE_COUNT}

NOTIFICATIONS:
  Email:      ${NOTIFY_EMAIL:-<not set>}
  Slack:      $(if [[ -n "$NOTIFY_SLACK_WEBHOOK" ]]; then printf '<set>'; else printf '<not set>'; fi)
  Recovery:   ${NOTIFY_ON_RECOVERY}

PATHS:
  Script:     ${SCRIPT_DIR:-<not detected>}
  Config:     ${CONFIG_FILE:-$DEFAULT_CONFIG_FILE}
  Lock:       ${LOCK_FILE}

DISK EXCLUSIONS:
  ${DISK_EXCLUDE_MOUNTS[*]:-<none>}

===========================
EOF
}

# Display help
show_help() {
    cat << EOF
System Monitor - System resource monitoring

USAGE:
    $(basename "$0") [options]

OPTIONS:
    -c, --config FILE       Configuration file
    --cpu-threshold N       CPU alert threshold (default: ${THRESHOLD_CPU}%)
    --mem-threshold N       Memory alert threshold (default: ${THRESHOLD_MEM}%)
    --disk-threshold N      Disk alert threshold (default: ${THRESHOLD_DISK}%)
    -i, --interval N        Monitoring interval in seconds (default: ${MONITOR_INTERVAL})
    -l, --log-file FILE     Log file
    --log-level LEVEL       Logging level: DEBUG, INFO, WARN, ERROR (default: ${LOG_LEVEL})
    -e, --email ADDRESS     Email address for notifications
    -d, --daemon            Run in daemon mode
    -n, --dry-run           Display only, don't send notifications
    -v, --verbose           Detailed output (enables DEBUG)
    -o, --output FORMAT     Output format: text, json, csv (default: ${OUTPUT_FORMAT})
    --exclude-mount PATH    Exclude mount point from monitoring
    -h, --help              Display this message
    --version               Display version

CONFIGURATION FILE:
    Format is KEY=VALUE, one setting per line.
    Locations checked: ./etc/monitor.conf, /etc/sysmonitor.conf
    
EXAMPLES:
    # Single-shot monitoring
    $(basename "$0")
    
    # Daemon with email notifications
    $(basename "$0") -d -e admin@example.com
    
    # Custom thresholds
    $(basename "$0") --cpu-threshold 90 --disk-threshold 95
    
    # JSON output
    $(basename "$0") -o json

ENVIRONMENT VARIABLES:
    THRESHOLD_CPU, THRESHOLD_MEM, THRESHOLD_DISK
    MONITOR_INTERVAL, LOG_FILE, LOG_LEVEL
    NOTIFY_EMAIL, NOTIFY_SLACK_WEBHOOK

EXIT CODES:
    0 - Success, all resources OK
    1 - Configuration error
    2 - At least one active alert
    3 - Fatal error

AUTHOR: ASE Bucharest - CSIE | Operating Systems
EOF
}

# Display version
show_version() {
    echo "System Monitor v1.0.0"
    echo "Core library: v${CORE_VERSION:-unknown}"
    echo "Utils library: v${UTILS_VERSION:-unknown}"
    echo "Config library: v${CONFIG_VERSION}"
}

#------------------------------------------------------------------------------
# EXPORT CONFIGURATION (for JSON)
#------------------------------------------------------------------------------

# Export configuration in JSON format
export_config_json() {
    cat << EOF
{
  "thresholds": {
    "cpu": ${THRESHOLD_CPU},
    "memory": ${THRESHOLD_MEM},
    "disk": ${THRESHOLD_DISK},
    "swap": ${THRESHOLD_SWAP},
    "load_multiplier": ${THRESHOLD_LOAD_MULT}
  },
  "monitoring": {
    "interval": ${MONITOR_INTERVAL},
    "daemon_mode": ${DAEMON_MODE},
    "dry_run": ${DRY_RUN},
    "output_format": "${OUTPUT_FORMAT}"
  },
  "logging": {
    "file": "${LOG_FILE}",
    "level": "${LOG_LEVEL}",
    "max_size": ${LOG_MAX_SIZE},
    "rotate_count": ${LOG_ROTATE_COUNT}
  },
  "notifications": {
    "email": "${NOTIFY_EMAIL}",
    "slack_webhook": $(if [[ -n "$NOTIFY_SLACK_WEBHOOK" ]]; then printf true; else printf false; fi),
    "notify_on_recovery": ${NOTIFY_ON_RECOVERY}
  }
}
EOF
}

#------------------------------------------------------------------------------
# INITIALISATION
#------------------------------------------------------------------------------

# Complete initialisation function
# Usage: init_config "$@"
init_config() {
    _setup_paths
    local args=("$@") i key
    for i in "${args[@]}"; do
        case "$i" in -h|--help) show_help; exit 0;; --version) show_version; exit 0;; esac
    done
    for ((i=0; i<${#args[@]}; i++)); do
        if [[ "${args[i]}" == -c || "${args[i]}" == --config ]]; then
            ((i + 1 < ${#args[@]})) || { log_error "Missing configuration path"; return 1; }
            CONFIG_FILE="${args[i+1]}"
        fi
    done
    if [[ -n "${CONFIG_FILE:-}" ]]; then
        load_config_file "$CONFIG_FILE" || return 1
    elif [[ -f "$DEFAULT_CONFIG_FILE" ]]; then
        load_config_file "$DEFAULT_CONFIG_FILE" || return 1
    elif [[ -f /etc/sysmonitor.conf ]]; then
        load_config_file /etc/sysmonitor.conf || return 1
    fi
    for key in "${!MONITOR_ENV_OVERRIDES[@]}"; do
        printf -v "$key" '%s' "${MONITOR_ENV_OVERRIDES[$key]}"
    done
    parse_args "${args[@]}" || return 1
    validate_config || return 1
    [[ "$VERBOSE" != true ]] || show_config >&2
    return 0
}

log_debug "config.sh v${CONFIG_VERSION} loaded"
