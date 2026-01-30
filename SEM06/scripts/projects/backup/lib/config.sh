#!/bin/bash
#==============================================================================
# config.sh - Configuration management for Backup System
#==============================================================================
# DESCRIPTION:
#   Functions for loading, validating and managing backup configuration.
#
# AUTHOR: ASE Bucharest - CSIE | Operating Systems
# VERSION: 1.0.0
#==============================================================================

readonly CONFIG_VERSION="1.0.0"

#------------------------------------------------------------------------------
# DEFAULT VALUES
#------------------------------------------------------------------------------

# Backup sources (array)
declare -ga BACKUP_SOURCES=()

# Destination
declare -g BACKUP_DEST="${BACKUP_DEST:-./backups}"

# Compression: gz, bz2, xz, zstd, none
declare -g COMPRESSION="${COMPRESSION:-gz}"

# Retention (number of backups kept)
declare -g RETENTION_DAILY="${RETENTION_DAILY:-7}"
declare -g RETENTION_WEEKLY="${RETENTION_WEEKLY:-4}"
declare -g RETENTION_MONTHLY="${RETENTION_MONTHLY:-12}"

# Forced backup type (otherwise auto-detect)
declare -g BACKUP_TYPE="${BACKUP_TYPE:-auto}"

# Exclusions (patterns)
declare -ga EXCLUDE_PATTERNS=()

# Notifications
declare -g NOTIFY_EMAIL="${NOTIFY_EMAIL:-}"
declare -g NOTIFY_ON_SUCCESS="${NOTIFY_ON_SUCCESS:-false}"
declare -g NOTIFY_ON_ERROR="${NOTIFY_ON_ERROR:-true}"

# Verifications
declare -g VERIFY_BACKUP="${VERIFY_BACKUP:-true}"
declare -g SAVE_CHECKSUM="${SAVE_CHECKSUM:-true}"
declare -g CHECKSUM_ALGORITHM="${CHECKSUM_ALGORITHM:-sha256}"

# Logging
declare -g LOG_FILE="${LOG_FILE:-}"
declare -g LOG_LEVEL="${LOG_LEVEL:-INFO}"

# Options
declare -g DRY_RUN="${DRY_RUN:-false}"
declare -g VERBOSE="${VERBOSE:-false}"

# Lock
declare -g LOCK_FILE="${LOCK_FILE:-}"

# Prefix for backup name
declare -g BACKUP_PREFIX="${BACKUP_PREFIX:-backup}"

#------------------------------------------------------------------------------
# SETUP PATHS
#------------------------------------------------------------------------------

_setup_backup_paths() {
    if [[ -z "${SCRIPT_DIR:-}" ]]; then
        SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[1]:-$0}")" && pwd)"
    fi
    
    readonly PROJECT_DIR="${SCRIPT_DIR}"
    readonly LIB_DIR="${PROJECT_DIR}/lib"
    readonly ETC_DIR="${PROJECT_DIR}/etc"
    readonly VAR_DIR="${PROJECT_DIR}/var"
    readonly LOG_DIR="${VAR_DIR}/log"
    readonly RUN_DIR="${VAR_DIR}/run"
    
    readonly DEFAULT_CONFIG_FILE="${ETC_DIR}/backup.conf"
    
    [[ -z "$LOCK_FILE" ]] && LOCK_FILE="${RUN_DIR}/backup.pid"
    [[ -z "$LOG_FILE" ]] && LOG_FILE="${LOG_DIR}/backup.log"
}

#------------------------------------------------------------------------------
# CONFIGURATION LOADING
#------------------------------------------------------------------------------

load_config_file() {
    local config_file="${1:-$DEFAULT_CONFIG_FILE}"
    
    [[ -f "$config_file" ]] || { log_debug "Config does not exist: $config_file"; return 0; }
    [[ -r "$config_file" ]] || { log_warn "Cannot read config: $config_file"; return 1; }
    
    log_info "Loading configuration from: $config_file"
    
    while IFS= read -r line || [[ -n "$line" ]]; do
        # Skip comments and empty lines
        [[ "$line" =~ ^[[:space:]]*# ]] && continue
        [[ -z "${line// /}" ]] && continue
        
        # Clean whitespace
        line="${line#"${line%%[![:space:]]*}"}"
        line="${line%"${line##*[![:space:]]}"}"
        
        # Parse KEY=VALUE
        if [[ "$line" =~ ^([A-Za-z_][A-Za-z0-9_]*)=(.*)$ ]]; then
            local key="${BASH_REMATCH[1]}"
            local value="${BASH_REMATCH[2]}"
            
            # Remove quotes
            value="${value#\"}"
            value="${value%\"}"
            value="${value#\'}"
            value="${value%\'}"
            
            # Special handling for arrays
            case "$key" in
                BACKUP_SOURCES)
                    IFS=' ' read -ra BACKUP_SOURCES <<< "$value"
                    ;;
                EXCLUDE_PATTERNS)
                    IFS=' ' read -ra EXCLUDE_PATTERNS <<< "$value"
                    ;;
                *)
                    export "$key=$value"
                    ;;
            esac
            
            log_debug "Config: $key = $value"
        fi
    done < "$config_file"
    
    return 0
}

#------------------------------------------------------------------------------
# ARGUMENT PARSING
#------------------------------------------------------------------------------

parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -c|--config)
                CONFIG_FILE="$2"
                shift 2
                ;;
            -s|--source)
                BACKUP_SOURCES+=("$2")
                shift 2
                ;;
            -d|--dest|--destination)
                BACKUP_DEST="$2"
                shift 2
                ;;
            -t|--type)
                BACKUP_TYPE="$2"
                shift 2
                ;;
            --compression)
                COMPRESSION="$2"
                shift 2
                ;;
            --retention-daily)
                RETENTION_DAILY="$2"
                shift 2
                ;;
            --retention-weekly)
                RETENTION_WEEKLY="$2"
                shift 2
                ;;
            --retention-monthly)
                RETENTION_MONTHLY="$2"
                shift 2
                ;;
            -x|--exclude)
                EXCLUDE_PATTERNS+=("$2")
                shift 2
                ;;
            --prefix)
                BACKUP_PREFIX="$2"
                shift 2
                ;;
            -e|--email)
                NOTIFY_EMAIL="$2"
                shift 2
                ;;
            --no-verify)
                VERIFY_BACKUP="false"
                shift
                ;;
            --no-checksum)
                SAVE_CHECKSUM="false"
                shift
                ;;
            -l|--log-file)
                LOG_FILE="$2"
                shift 2
                ;;
            --log-level)
                LOG_LEVEL="$2"
                shift 2
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
                # Positional argument - treat as source
                BACKUP_SOURCES+=("$1")
                shift
                ;;
        esac
    done
}

#------------------------------------------------------------------------------
# VALIDATION
#------------------------------------------------------------------------------

validate_config() {
    local errors=0
    
    # Check sources
    if [[ ${#BACKUP_SOURCES[@]} -eq 0 ]]; then
        log_error "No backup source specified"
        ((errors++))
    else
        for source in "${BACKUP_SOURCES[@]}"; do
            if [[ ! -e "$source" ]]; then
                log_error "Source does not exist: $source"
                ((errors++))
            fi
        done
    fi
    
    # Check/create destination
    if [[ -z "$BACKUP_DEST" ]]; then
        log_error "Backup destination not specified"
        ((errors++))
    else
        if [[ ! -d "$BACKUP_DEST" ]]; then
            if ! mkdir -p "$BACKUP_DEST" 2>/dev/null; then
                log_error "Cannot create destination directory: $BACKUP_DEST"
                ((errors++))
            else
                log_info "Destination directory created: $BACKUP_DEST"
            fi
        fi
    fi
    
    # Check compression
    case "$COMPRESSION" in
        gz|gzip|bz2|bzip2|xz|zstd|none|tar)
            ;;
        *)
            log_error "Invalid compression type: $COMPRESSION"
            ((errors++))
            ;;
    esac
    
    # Check retention
    for var in RETENTION_DAILY RETENTION_WEEKLY RETENTION_MONTHLY; do
        local value="${!var}"
        if ! is_integer "$value" || [[ $value -lt 0 ]]; then
            log_error "Invalid retention value for $var: $value"
            ((errors++))
        fi
    done
    
    # Check backup type
    case "$BACKUP_TYPE" in
        auto|daily|weekly|monthly|full)
            ;;
        *)
            log_error "Invalid backup type: $BACKUP_TYPE"
            ((errors++))
            ;;
    esac
    
    # Create necessary directories
    for dir in "$LOG_DIR" "$RUN_DIR"; do
        if [[ ! -d "$dir" ]]; then
            mkdir -p "$dir" 2>/dev/null || {
                log_warn "Cannot create directory: $dir"
            }
        fi
    done
    
    return $errors
}

#------------------------------------------------------------------------------
# DISPLAY
#------------------------------------------------------------------------------

show_config() {
    cat << EOF
=== BACKUP CONFIGURATION ===

SOURCES:
$(printf '  - %s\n' "${BACKUP_SOURCES[@]:-<none>}")

DESTINATION:
  Path:        $BACKUP_DEST
  Prefix:      $BACKUP_PREFIX
  Compression: $COMPRESSION

BACKUP TYPE:
  Type:        $BACKUP_TYPE

RETENTION:
  Daily:       $RETENTION_DAILY
  Weekly:      $RETENTION_WEEKLY
  Monthly:     $RETENTION_MONTHLY

EXCLUSIONS:
$(printf '  - %s\n' "${EXCLUDE_PATTERNS[@]:-<none>}")

VERIFICATIONS:
  Verification: $VERIFY_BACKUP
  Checksum:     $SAVE_CHECKSUM ($CHECKSUM_ALGORITHM)

NOTIFICATIONS:
  Email:        ${NOTIFY_EMAIL:-<not set>}
  On success:   $NOTIFY_ON_SUCCESS
  On error:     $NOTIFY_ON_ERROR

OPTIONS:
  Dry-run:      $DRY_RUN
  Verbose:      $VERBOSE
  Log level:    $LOG_LEVEL
  Log file:     ${LOG_FILE:-<stdout>}

============================
EOF
}

show_help() {
    cat << EOF
Backup System - Enterprise backup system

USAGE:
    $(basename "$0") [options] [sources...]

MAIN OPTIONS:
    -s, --source PATH       Add backup source (can be repeated)
    -d, --dest PATH         Destination directory for backups
    -t, --type TYPE         Backup type: auto, daily, weekly, monthly, full
    --compression TYPE      Compression: gz, bz2, xz, zstd, none (default: gz)

RETENTION:
    --retention-daily N     Keep N daily backups (default: 7)
    --retention-weekly N    Keep N weekly backups (default: 4)
    --retention-monthly N   Keep N monthly backups (default: 12)

EXCLUSIONS:
    -x, --exclude PATTERN   Exclude pattern from backup (can be repeated)
    --prefix NAME           Prefix for backup name (default: backup)

VERIFICATIONS:
    --no-verify             Don't verify backup integrity
    --no-checksum           Don't save checksum file

NOTIFICATIONS:
    -e, --email ADDRESS     Email address for notifications

LOGGING:
    -l, --log-file FILE     Log file
    --log-level LEVEL       Level: DEBUG, INFO, WARN, ERROR

GENERAL:
    -c, --config FILE       Configuration file
    -n, --dry-run           Simulation, don't actually execute
    -v, --verbose           Detailed output
    -h, --help              Display this message
    --version               Display version

EXAMPLES:
    # Simple backup
    $(basename "$0") -s /home -d /backup
    
    # Backup with exclusions
    $(basename "$0") -s /home -d /backup -x '*.tmp' -x 'cache'
    
    # Backup with notifications
    $(basename "$0") -s /var/www -d /backup -e admin@example.com
    
    # Dry-run for testing
    $(basename "$0") -s /data -d /backup -n -v

BACKUP TYPES:
    auto      - Auto-detect: monthly on 1st, weekly on Sunday, otherwise daily
    daily     - Daily backup, short retention
    weekly    - Weekly backup
    monthly   - Monthly backup, long retention
    full      - Full backup without rotation

CONFIGURATION FILE:
    Format: KEY=VALUE, one parameter per line.
    Default location: ./etc/backup.conf

EXIT CODES:
    0 - Success
    1 - Configuration error
    2 - Backup error
    3 - Verification error

AUTHOR: ASE Bucharest - CSIE | Operating Systems
EOF
}

show_version() {
    echo "Backup System v1.0.0"
    echo "Core: v${CORE_VERSION:-unknown}"
    echo "Utils: v${UTILS_VERSION:-unknown}"
    echo "Config: v${CONFIG_VERSION}"
}

#------------------------------------------------------------------------------
# INITIALISATION
#------------------------------------------------------------------------------

init_config() {
    _setup_backup_paths
    
    # Load default config if exists
    [[ -f "$DEFAULT_CONFIG_FILE" ]] && load_config_file "$DEFAULT_CONFIG_FILE"
    
    # Parse arguments
    parse_args "$@"
    
    # Load custom config if specified
    if [[ -n "${CONFIG_FILE:-}" ]] && [[ "$CONFIG_FILE" != "$DEFAULT_CONFIG_FILE" ]]; then
        load_config_file "$CONFIG_FILE"
    fi
    
    # Validate
    if ! validate_config; then
        return 1
    fi
    
    # Verbose settings
    if [[ "$VERBOSE" == "true" ]]; then
        show_config
    fi
    
    log_debug "Configuration initialised successfully"
    return 0
}

log_debug "config.sh v${CONFIG_VERSION} loaded (backup)"
