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
    # If SCRIPT_DIR is not set, detect it
    if [[ -z "${SCRIPT_DIR:-}" ]]; then
        SCRIPT_DIR=$(_detect_script_dir)
        readonly SCRIPT_DIR
    fi
    
    # Derived paths
    readonly PROJECT_DIR="${SCRIPT_DIR}"
    readonly LIB_DIR="${PROJECT_DIR}/lib"
    readonly ETC_DIR="${PROJECT_DIR}/etc"
    readonly VAR_DIR="${PROJECT_DIR}/var"
    readonly LOG_DIR="${VAR_DIR}/log"
    readonly RUN_DIR="${VAR_DIR}/run"
    
    # Default configuration file
    readonly DEFAULT_CONFIG_FILE="${ETC_DIR}/monitor.conf"
    
    # Default lock file
    if [[ -z "$LOCK_FILE" ]]; then
        LOCK_FILE="${RUN_DIR}/monitor.pid"
    fi
    
    # Default log file
    if [[ -z "$LOG_FILE" ]]; then
        LOG_FILE="${LOG_DIR}/monitor.log"
    fi
}

#------------------------------------------------------------------------------
# CONFIGURATION LOADING FUNCTIONS
#------------------------------------------------------------------------------

# Load configuration from a file
# File format: KEY=value (shell-style)
load_config_file() {
    local config_file="${1:-$DEFAULT_CONFIG_FILE}"
    
    if [[ ! -f "$config_file" ]]; then
        log_debug "Configuration file does not exist: $config_file"
        return 0
    fi
    
    if [[ ! -r "$config_file" ]]; then
        log_warn "Cannot read configuration file: $config_file"
        return 1
    fi
    
    log_info "Loading configuration from: $config_file"
    
    # Read line by line, ignore comments and empty lines
    while IFS= read -r line || [[ -n "$line" ]]; do
        # Skip comments and empty lines
        [[ "$line" =~ ^[[:space:]]*# ]] && continue
        [[ -z "${line// /}" ]] && continue
        
        # Clean whitespace
        line="${line#"${line%%[![:space:]]*}"}"
        line="${line%"${line##*[![:space:]]}"}"
        
        # Extract KEY=VALUE
        if [[ "$line" =~ ^([A-Za-z_][A-Za-z0-9_]*)=(.*)$ ]]; then
            local key="${BASH_REMATCH[1]}"
            local value="${BASH_REMATCH[2]}"
            
            # Remove quotes
            value="${value#\"}"
            value="${value%\"}"
            value="${value#\'}"
            value="${value%\'}"
            
            # Set variable
            export "$key=$value"
            log_debug "Config: $key = $value"
        fi
    done < "$config_file"
    
    return 0
}

# Parse command line arguments
# Usage: parse_args "$@"
parse_args() {
    while [[ $# -gt 0 ]]; do
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
            ((errors++))
        fi
    done
    
    # Validate interval
    if ! is_integer "$MONITOR_INTERVAL" || [[ $MONITOR_INTERVAL -lt 1 ]]; then
        log_error "Invalid monitoring interval: $MONITOR_INTERVAL (must be >= 1)"
        ((errors++))
    fi
    
    # Validate log level
    case "$LOG_LEVEL" in
        DEBUG|INFO|WARN|ERROR|FATAL) ;;
        *)
            log_error "Invalid logging level: $LOG_LEVEL"
            ((errors++))
            ;;
    esac
    
    # Validate output format
    case "$OUTPUT_FORMAT" in
        text|json|csv) ;;
        *)
            log_error "Invalid output format: $OUTPUT_FORMAT (must be: text, json, csv)"
            ((errors++))
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
                ((errors++))
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
  Slack:      ${NOTIFY_SLACK_WEBHOOK:+<set>}${NOTIFY_SLACK_WEBHOOK:-<not set>}
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
    "slack_webhook": "${NOTIFY_SLACK_WEBHOOK:+true}${NOTIFY_SLACK_WEBHOOK:-false}",
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
    # 1. Setup paths
    _setup_paths
    
    # 2. Load default configuration file
    if [[ -f "$DEFAULT_CONFIG_FILE" ]]; then
        load_config_file "$DEFAULT_CONFIG_FILE"
    fi
    
    # 3. Parse arguments (can override config file)
    parse_args "$@"
    
    # 4. Load specified configuration file
    if [[ -n "${CONFIG_FILE:-}" ]] && [[ "$CONFIG_FILE" != "$DEFAULT_CONFIG_FILE" ]]; then
        load_config_file "$CONFIG_FILE"
    fi
    
    # 5. Validate final configuration
    if ! validate_config; then
        log_error "Invalid configuration"
        return 1
    fi
    
    # 6. Verbose settings
    if [[ "$VERBOSE" == "true" ]]; then
        LOG_LEVEL="DEBUG"
        show_config
    fi
    
    log_debug "Configuration initialised successfully"
    return 0
}

log_debug "config.sh v${CONFIG_VERSION} loaded"
