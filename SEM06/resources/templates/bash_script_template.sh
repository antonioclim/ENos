#!/usr/bin/env bash
#
# script_name.sh - Short script description
#
# Author: [Your name]
# Date: [Date]
# Version: 1.0.0
#
# Description:
#   [More detailed description of what the script does]
#
# Usage:
#   ./script_name.sh [options] <arguments>
#
# Dependencies:
#   - bash 4.0+
#   - [other dependencies]
#

# === STRICT MODE ===
set -euo pipefail
IFS=$'\n\t'

# === CONSTANTS ===
readonly SCRIPT_NAME="$(basename "$0")"
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_VERSION="1.0.0"

# === CONFIGURATION ===
readonly LOG_FILE="${LOG_FILE:-/var/log/${SCRIPT_NAME%.sh}.log}"
CONFIG_FILE="${CONFIG_FILE:-${SCRIPT_DIR}/config/${SCRIPT_NAME%.sh}.conf}"
TEMP_BASE="${TEMP_DIR:-${TMPDIR:-/tmp}}"
TEMP_DIR=""
TEMP_OWNED=false
LOG_ENABLED=false

# === COLOURS (optional) ===
if [[ -t 1 ]]; then
    readonly RED='\033[0;31m'
    readonly GREEN='\033[0;32m'
    readonly YELLOW='\033[0;33m'
    readonly BLUE='\033[0;34m'
    readonly NC='\033[0m' # No Colour
else
    readonly RED=''
    readonly GREEN=''
    readonly YELLOW=''
    readonly BLUE=''
    readonly NC=''
fi

# === LOGGING ===
log() {
    local level="${1:-INFO}"
    shift
    local message="$*"
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    # Colours per level
    local color=""
    case "$level" in
        DEBUG) color="$BLUE" ;;
        INFO)  color="$GREEN" ;;
        WARN)  color="$YELLOW" ;;
        ERROR|FATAL) color="$RED" ;;
    esac
    
    # Output to stdout and log file
    printf "${color}[%s] [%-5s] %s${NC}\n" "$timestamp" "$level" "$message"
    if [[ "$LOG_ENABLED" == true ]]; then
        printf "[%s] [%-5s] %s\n" "$timestamp" "$level" "$message" >> "$LOG_FILE" || return 1
    fi
}

debug() { [[ "${DEBUG:-false}" == "true" ]] && log "DEBUG" "$@" || true; }
info()  { log "INFO" "$@"; }
warn()  { log "WARN" "$@" >&2; }
error() { log "ERROR" "$@" >&2; }
fatal() { log "FATAL" "$@" >&2; exit 1; }

# === CLEANUP ===
cleanup() {
    local exit_code=$?
    
    debug "Cleanup started (exit code: $exit_code)"
    
    # Cleanup temp files
    if [[ "$TEMP_OWNED" == true && -n "$TEMP_DIR" && -d "$TEMP_DIR" ]]; then
        rm -rf "$TEMP_DIR"
        debug "Removed temp directory: $TEMP_DIR"
    fi
    
    # Release locks if any
    # rm -f "$LOCK_FILE" 2>/dev/null || true
    
    debug "Cleanup completed"
    exit $exit_code
}

trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

# === UTILITY FUNCTIONS ===
require_root() {
    if [[ $EUID -ne 0 ]]; then
        fatal "This script must be run as root"
    fi
}

require_command() {
    local cmd="$1"
    if ! command -v "$cmd" &>/dev/null; then
        fatal "Required command not found: $cmd"
    fi
}

confirm() {
    local prompt="${1:-Are you sure?}"
    local default="${2:-n}"
    
    local yn
    read -r -p "$prompt [y/N] " yn
    yn="${yn:-$default}"
    
    [[ "$yn" =~ ^[Yy]$ ]]
}

# === CONFIGURATION ===
load_config() {
    if [[ -f "$CONFIG_FILE" ]]; then
        # This template intentionally loads a trusted local Bash configuration.
        # Do not source untrusted data; use a literal parser for that case.
        # shellcheck source=/dev/null
        source "$CONFIG_FILE"
        debug "Config loaded from $CONFIG_FILE"
    else
        debug "No config file found at $CONFIG_FILE, using defaults"
    fi
}

# === HELP ===
usage() {
    cat << EOF
Usage: $SCRIPT_NAME [OPTIONS] <argument>

Short script description.

Options:
    -c, --config FILE   Configuration file (default: $CONFIG_FILE)
    -v, --verbose       Verbose mode (debug output)
    -n, --dry-run       Simulation, no real changes
    -f, --force         Force operation
    -h, --help          Display this message
    -V, --version       Display version

Arguments:
    argument            Required argument description

Environment variables:
    LOG_FILE            Log file location
    DEBUG               Enable debug mode (true/false)

Examples:
    $SCRIPT_NAME input.txt
    $SCRIPT_NAME -v --config custom.conf data/
    $SCRIPT_NAME --dry-run --force /path/to/dir

Exit codes:
    0   Success
    1   General error
    2   Configuration error
    3   Runtime error
EOF
    exit "${1:-0}"
}

version() {
    echo "$SCRIPT_NAME version $SCRIPT_VERSION"
    exit 0
}

# === ARGUMENT PARSING ===
parse_args() {
    # Defaults
    CONFIG_FILE_ARG=""
    VERBOSE=${VERBOSE:-false}
    DRY_RUN=${DRY_RUN:-false}
    FORCE=${FORCE:-false}
    POSITIONAL_ARGS=()
    
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -c|--config)
                [[ $# -ge 2 && -n "$2" ]] || { echo "Missing config path" >&2; exit 2; }
                CONFIG_FILE_ARG="$2"
                shift 2
                ;;
            -v|--verbose)
                VERBOSE=true
                DEBUG=true
                shift
                ;;
            -n|--dry-run)
                DRY_RUN=true
                shift
                ;;
            -f|--force)
                FORCE=true
                shift
                ;;
            -h|--help)
                usage
                ;;
            -V|--version)
                version
                ;;
            --)
                shift
                POSITIONAL_ARGS+=("$@")
                break
                ;;
            -*)
                error "Unknown option: $1"
                usage 1
                ;;
            *)
                POSITIONAL_ARGS+=("$1")
                shift
                ;;
        esac
    done
    
    # Override config file if specified
    [[ -n "$CONFIG_FILE_ARG" ]] && CONFIG_FILE="$CONFIG_FILE_ARG"
    
    # Restore positional arguments
    set -- "${POSITIONAL_ARGS[@]}"
    
    # Validate required arguments
    if [[ ${#POSITIONAL_ARGS[@]} -lt 1 ]]; then
        error "Missing required argument"
        usage 1
    fi
    
    # Store for later use
    ARG="${POSITIONAL_ARGS[0]}"
}

# === VALIDATION ===
validate() {
    debug "Validating inputs..."
    
    # Example validations
    # [[ -f "$ARG" ]] || fatal "File not found: $ARG"
    # [[ -d "$DIR" ]] || fatal "Directory not found: $DIR"
    # [[ "$NUM" =~ ^[0-9]+$ ]] || fatal "Invalid number: $NUM"
    
    debug "Validation passed"
}

# === MAIN LOGIC ===
do_work() {
    info "Starting main operation..."
    
    if [[ "$DRY_RUN" == true ]]; then
        info "[DRY-RUN] Would process: $ARG"
        return 0
    fi
    
    # TODO: Implement main logic
    
    warn "Template only: main logic is not implemented (TODO)"
    return 3
}

# === MAIN ===
main() {
    # Handle help/version before configuration, logging or temporary directories.
    for item in "$@"; do
        case "$item" in -h|--help) usage;; -V|--version) version;; esac
    done
    # Select the trusted file first, then apply CLI overrides after loading it.
    local -a original_args=("$@")
    while [[ $# -gt 0 ]]; do
        if [[ "$1" == -c || "$1" == --config ]]; then
            [[ $# -ge 2 && -n "$2" ]] || { echo "Missing config path" >&2; return 2; }
            CONFIG_FILE=$2
            shift 2
        else
            shift
        fi
    done
    load_config
    parse_args "${original_args[@]}"
    if [[ "$DRY_RUN" != true ]]; then
        TEMP_DIR=$(mktemp -d "$TEMP_BASE/${SCRIPT_NAME%.sh}.XXXXXX") || return 3
        TEMP_OWNED=true
        : >> "$LOG_FILE" || { echo "Cannot open log: $LOG_FILE" >&2; return 3; }
        LOG_ENABLED=true
    fi

    # Validate inputs
    validate
    
    # Execute main logic
    do_work
}

# Run main only if script is executed (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
