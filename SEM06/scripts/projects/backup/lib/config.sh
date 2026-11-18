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
declare -g INCREMENTAL="${INCREMENTAL:-false}"

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
    : "${SCRIPT_DIR:=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
    : "${PROJECT_DIR:=$SCRIPT_DIR}" "${LIB_DIR:=$SCRIPT_DIR/lib}"
    : "${ETC_DIR:=$SCRIPT_DIR/etc}" "${VAR_DIR:=$SCRIPT_DIR/var}"
    : "${LOG_DIR:=$VAR_DIR/log}" "${RUN_DIR:=$VAR_DIR/run}"
    : "${DEFAULT_CONFIG_FILE:=$ETC_DIR/backup.conf}"
    : "${LOCK_FILE:=$RUN_DIR/backup.lock}" "${LOG_FILE:=$LOG_DIR/backup.log}"
    return 0
}

#------------------------------------------------------------------------------
# CONFIGURATION LOADING
#------------------------------------------------------------------------------

load_config_file() {
    local config_file="${1:-$DEFAULT_CONFIG_FILE}" parsed key value
    [[ -r "$config_file" ]] || { log_error "Cannot read config: $config_file"; return 1; }
    parsed=$(mktemp) || return 1
    if ! python3 "${LIB_DIR}/../../config_data.py" "$config_file" BACKUP_SOURCES[] EXCLUDE_PATTERNS[] BACKUP_DEST BACKUP_PREFIX COMPRESSION COMPRESSION_LEVEL RETENTION_DAILY RETENTION_WEEKLY RETENTION_MONTHLY BACKUP_TYPE INCREMENTAL VERIFY_BACKUP SAVE_CHECKSUM CHECKSUM_ALGORITHM VERIFY_ARCHIVE_LISTING PRE_BACKUP_SCRIPT POST_BACKUP_SCRIPT SCRIPT_TIMEOUT LOG_LEVEL LOG_FILE LOG_DIR LOG_RETENTION_DAYS USE_COLORS NOTIFY_EMAIL EMAIL_RECIPIENTS NOTIFY_ON_ERROR_ONLY NOTIFY_ON_SUCCESS NOTIFY_ON_ERROR EMAIL_SUBJECT_SUCCESS EMAIL_SUBJECT_ERROR DRY_RUN VERBOSE PRESERVE_PERMISSIONS FOLLOW_SYMLINKS MAX_FILE_SIZE NICE_LEVEL IONICE_CLASS BACKUP_TIMEOUT LOCK_FILE LOCK_TIMEOUT TIMESTAMP_FORMAT WEEKLY_DAY MONTHLY_DAY > "$parsed"; then
        rm -f -- "$parsed"
        return 1
    fi
    while IFS= read -r -d '' key && IFS= read -r -d '' value; do
        case "$key" in
            BACKUP_SOURCES__RESET) BACKUP_SOURCES=() ;;
            EXCLUDE_PATTERNS__RESET) EXCLUDE_PATTERNS=() ;;
            BACKUP_SOURCES) BACKUP_SOURCES+=("$value") ;;
            EXCLUDE_PATTERNS) EXCLUDE_PATTERNS+=("$value") ;;
            *) printf -v "$key" '%s' "$value" ;;
        esac
    done < "$parsed"
    rm -f -- "$parsed"
    return 0
}

#------------------------------------------------------------------------------
# ARGUMENT PARSING
#------------------------------------------------------------------------------

parse_args() {
    local cli_sources=false
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -c|--config|-s|--source|-d|--dest|--destination|-t|--type|--compression|--retention-daily|--retention-weekly|--retention-monthly|-x|--exclude|--prefix|-e|--email|-l|--log-file|--log-level|--restore|--restore-dir|--verify-archive)
                [[ $# -ge 2 && -n "$2" ]] || { log_error "Missing value for $1"; return 1; } ;;
        esac
        case "$1" in
            -c|--config)
                CONFIG_FILE="$2"
                shift 2
                ;;
            -s|--source)
                if ! "$cli_sources"; then BACKUP_SOURCES=(); cli_sources=true; fi
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
                NOTIFY_EMAIL=true
                EMAIL_RECIPIENTS="$2"
                shift 2
                ;;
            --list) MODE=list; shift ;;
            --restore) MODE=restore; RESTORE_ARCHIVE="$2"; shift 2 ;;
            --restore-dir) RESTORE_DEST="$2"; shift 2 ;;
            --verify-archive) MODE=verify; VERIFY_ARCHIVE="$2"; shift 2 ;;
            --incremental) INCREMENTAL=true; shift ;;
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
                # Positional sources override the file source list on first use.
                if ! "$cli_sources"; then BACKUP_SOURCES=(); cli_sources=true; fi
                BACKUP_SOURCES+=("$1")
                shift
                ;;
        esac
    done
    BACKUP_SOURCES+=("$@")
    return 0
}

#------------------------------------------------------------------------------
# VALIDATION
#------------------------------------------------------------------------------

validate_config() {
    local errors=0
    
    # Check sources
    if [[ "${MODE:-backup}" != backup ]]; then
        return 0
    fi
    if [[ ${#BACKUP_SOURCES[@]} -eq 0 ]]; then
        log_error "No backup source specified"
        errors=$((errors + 1))
    else
        for source in "${BACKUP_SOURCES[@]}"; do
            if [[ ! -e "$source" ]]; then
                log_error "Source does not exist: $source"
                errors=$((errors + 1))
            fi
        done
    fi
    
    # Validation is read-only; creation is performed after dry-run handling.
    if [[ -z "$BACKUP_DEST" ]]; then
        log_error "Backup destination not specified"
        errors=$((errors + 1))
    fi
    [[ "$BACKUP_PREFIX" =~ ^[A-Za-z0-9_.-]+$ ]] || { log_error "Invalid backup prefix"; errors=$((errors + 1)); }
    case "$CHECKSUM_ALGORITHM" in md5|sha1|sha256) ;; *) log_error "Unsupported checksum algorithm"; errors=$((errors + 1));; esac
    case "$INCREMENTAL" in true|false) ;; *) log_error "INCREMENTAL must be true or false"; errors=$((errors + 1));; esac
    # Check compression
    case "$COMPRESSION" in
        gz|gzip|bz2|bzip2|xz|zstd|none|tar)
            ;;
        *)
            log_error "Invalid compression type: $COMPRESSION"
            errors=$((errors + 1))
            ;;
    esac
    
    # Check retention
    for var in RETENTION_DAILY RETENTION_WEEKLY RETENTION_MONTHLY; do
        local value="${!var}"
        if ! is_integer "$value" || [[ $value -lt 0 ]]; then
            log_error "Invalid retention value for $var: $value"
            errors=$((errors + 1))
        fi
    done
    
    local source_real dest_real
    dest_real=$(realpath -m -- "$BACKUP_DEST") || return 1
    for source in "${BACKUP_SOURCES[@]}"; do
        source_real=$(realpath -e -- "$source") || return 1
        if [[ "$source_real" == / || "$dest_real" == "$source_real" || "$dest_real" == "$source_real/"* ]]; then
            log_error "Backup destination must be outside every source; root source is not supported"
            errors=$((errors + 1))
        fi
    done

    # Check backup type
    case "$BACKUP_TYPE" in
        auto|daily|weekly|monthly|full)
            ;;
        *)
            log_error "Invalid backup type: $BACKUP_TYPE"
            errors=$((errors + 1))
            ;;
    esac
    
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
    --incremental           GNU tar incremental chain (first run creates its full base)
    --list                  List stored archives
    --restore ARCHIVE       Restore an archive or its complete incremental chain
    --restore-dir PATH      Empty destination for a chain restore
    --verify-archive FILE   Check archive structure
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
    Literal KEY=VALUE settings; no shell expansion or execution.
    Arrays use quoted (...) elements. CLI settings override the file.
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
    local args=("$@") i
    # Help and version do not load or write any configuration.
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
    fi
    parse_args "${args[@]}" || return 1
    validate_config || return 1
    if [[ "$DRY_RUN" == true ]]; then LOG_FILE=""; fi
    if [[ "$VERBOSE" == true ]]; then show_config >&2; fi
    return 0
}

log_debug "config.sh v${CONFIG_VERSION} loaded (backup)"
