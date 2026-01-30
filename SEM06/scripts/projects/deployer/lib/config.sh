#!/usr/bin/env bash
# ==============================================================================
# DEPLOYER - Config Library
# ==============================================================================
# Configuration parsing, CLI arguments, validation
# Part of the CAPSTONE project for Operating Systems
# ==============================================================================

# Guard against double loading
[[ -n "${_DEPLOYER_CONFIG_LOADED:-}" ]] && return 0
readonly _DEPLOYER_CONFIG_LOADED=1

# ==============================================================================
# DEFAULT VALUES
# ==============================================================================

# Directories
DEFAULT_DEPLOY_ROOT="/opt/deploy"
DEFAULT_BACKUP_DIR="/var/backup/deploy"
DEFAULT_LOG_DIR="/var/log/deployer"
DEFAULT_RUN_DIR="/var/run/deployer"

# Deployment settings
DEFAULT_ENVIRONMENT="production"
DEFAULT_STRATEGY="rolling"  # rolling, blue-green, canary
DEFAULT_ROLLBACK_ON_FAILURE=true
DEFAULT_HEALTH_CHECK_ENABLED=true
DEFAULT_HEALTH_CHECK_RETRIES=3
DEFAULT_HEALTH_CHECK_INTERVAL=5
DEFAULT_HEALTH_CHECK_TIMEOUT=30

# Service defaults
DEFAULT_SERVICE_RESTART_DELAY=5
DEFAULT_SERVICE_STOP_TIMEOUT=30
DEFAULT_SERVICE_START_TIMEOUT=60

# Docker defaults
DEFAULT_DOCKER_REGISTRY=""
DEFAULT_DOCKER_PULL_TIMEOUT=300
DEFAULT_CONTAINER_STOP_TIMEOUT=30

# Notification
DEFAULT_NOTIFY_ON_SUCCESS=false
DEFAULT_NOTIFY_ON_FAILURE=true
DEFAULT_NOTIFY_EMAIL=""
DEFAULT_SLACK_WEBHOOK=""

# ==============================================================================
# CONFIGURATION VARIABLES
# ==============================================================================

# Set from configuration file or CLI
DEPLOY_ROOT=${DEPLOY_ROOT:-$DEFAULT_DEPLOY_ROOT}
BACKUP_DIR=${BACKUP_DIR:-$DEFAULT_BACKUP_DIR}
LOG_DIR=${LOG_DIR:-$DEFAULT_LOG_DIR}
RUN_DIR=${RUN_DIR:-$DEFAULT_RUN_DIR}

ENVIRONMENT=${ENVIRONMENT:-$DEFAULT_ENVIRONMENT}
STRATEGY=${STRATEGY:-$DEFAULT_STRATEGY}
ROLLBACK_ON_FAILURE=${ROLLBACK_ON_FAILURE:-$DEFAULT_ROLLBACK_ON_FAILURE}

HEALTH_CHECK_ENABLED=${HEALTH_CHECK_ENABLED:-$DEFAULT_HEALTH_CHECK_ENABLED}
HEALTH_CHECK_RETRIES=${HEALTH_CHECK_RETRIES:-$DEFAULT_HEALTH_CHECK_RETRIES}
HEALTH_CHECK_INTERVAL=${HEALTH_CHECK_INTERVAL:-$DEFAULT_HEALTH_CHECK_INTERVAL}
HEALTH_CHECK_TIMEOUT=${HEALTH_CHECK_TIMEOUT:-$DEFAULT_HEALTH_CHECK_TIMEOUT}

SERVICE_RESTART_DELAY=${SERVICE_RESTART_DELAY:-$DEFAULT_SERVICE_RESTART_DELAY}
SERVICE_STOP_TIMEOUT=${SERVICE_STOP_TIMEOUT:-$DEFAULT_SERVICE_STOP_TIMEOUT}
SERVICE_START_TIMEOUT=${SERVICE_START_TIMEOUT:-$DEFAULT_SERVICE_START_TIMEOUT}

DOCKER_REGISTRY=${DOCKER_REGISTRY:-$DEFAULT_DOCKER_REGISTRY}
DOCKER_PULL_TIMEOUT=${DOCKER_PULL_TIMEOUT:-$DEFAULT_DOCKER_PULL_TIMEOUT}
CONTAINER_STOP_TIMEOUT=${CONTAINER_STOP_TIMEOUT:-$DEFAULT_CONTAINER_STOP_TIMEOUT}

NOTIFY_ON_SUCCESS=${NOTIFY_ON_SUCCESS:-$DEFAULT_NOTIFY_ON_SUCCESS}
NOTIFY_ON_FAILURE=${NOTIFY_ON_FAILURE:-$DEFAULT_NOTIFY_ON_FAILURE}
NOTIFY_EMAIL=${NOTIFY_EMAIL:-$DEFAULT_NOTIFY_EMAIL}
SLACK_WEBHOOK=${SLACK_WEBHOOK:-$DEFAULT_SLACK_WEBHOOK}

# Deployment targets (array)
declare -a SERVICES=()
declare -a CONTAINERS=()
declare -a MANIFESTS=()

# Flags
DRY_RUN=false
FORCE=false
NO_BACKUP=false
SKIP_HEALTH_CHECK=false
PARALLEL=false

# Action (deploy, rollback, status, list)
ACTION="deploy"

# ==============================================================================
# CONFIGURATION FILE LOADING
# ==============================================================================

# Configuration file locations (in order of priority)
CONFIG_LOCATIONS=(
    "./etc/deployer.conf"
    "$HOME/.config/deployer/deployer.conf"
    "/etc/deployer.conf"
    "/etc/deployer/deployer.conf"
)

# Load configuration file
# Args: $1 = file path (optional)
load_config_file() {
    local config_file=""
    
    # If explicitly specified
    if [[ -n "${1:-}" ]]; then
        config_file="$1"
        if [[ ! -f "$config_file" ]]; then
            log_error "Config file not found: $config_file"
            return 1
        fi
    else
        # Search in standard locations
        for loc in "${CONFIG_LOCATIONS[@]}"; do
            if [[ -f "$loc" ]]; then
                config_file="$loc"
                break
            fi
        done
    fi
    
    if [[ -z "$config_file" ]]; then
        log_debug "No config file found, using defaults"
        return 0
    fi
    
    log_info "Loading config: $config_file"
    
    # Parse the file
    while IFS='=' read -r key value || [[ -n "$key" ]]; do
        # Skip comments and empty lines
        [[ "$key" =~ ^[[:space:]]*# ]] && continue
        [[ -z "$key" ]] && continue
        
        # Clean whitespace
        key=$(echo "$key" | tr -d ' ')
        value=$(echo "$value" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        
        # Remove quotes
        value=${value%\"}
        value=${value#\"}
        value=${value%\'}
        value=${value#\'}
        
        # Set variable
        case "$key" in
            DEPLOY_ROOT|BACKUP_DIR|LOG_DIR|RUN_DIR|\
            ENVIRONMENT|STRATEGY|\
            ROLLBACK_ON_FAILURE|HEALTH_CHECK_ENABLED|\
            HEALTH_CHECK_RETRIES|HEALTH_CHECK_INTERVAL|HEALTH_CHECK_TIMEOUT|\
            SERVICE_RESTART_DELAY|SERVICE_STOP_TIMEOUT|SERVICE_START_TIMEOUT|\
            DOCKER_REGISTRY|DOCKER_PULL_TIMEOUT|CONTAINER_STOP_TIMEOUT|\
            NOTIFY_ON_SUCCESS|NOTIFY_ON_FAILURE|NOTIFY_EMAIL|SLACK_WEBHOOK|\
            LOG_LEVEL|LOG_FILE|HOOKS_DIR)
                declare -g "$key=$value"
                log_debug "  $key=$value"
                ;;
            SERVICES)
                # Parse array
                IFS=',' read -ra SERVICES <<< "$value"
                log_debug "  SERVICES=${SERVICES[*]}"
                ;;
            CONTAINERS)
                IFS=',' read -ra CONTAINERS <<< "$value"
                log_debug "  CONTAINERS=${CONTAINERS[*]}"
                ;;
            *)
                log_debug "  Unknown config key: $key"
                ;;
        esac
    done < "$config_file"
    
    return 0
}

# ==============================================================================
# CLI ARGUMENT PARSING
# ==============================================================================

# Display help
show_help() {
    cat << EOF
${CYAN}${DEPLOYER_NAME}${NC} v${DEPLOYER_VERSION} - Service Deployment System

${YELLOW}USAGE:${NC}
    $(basename "$0") [OPTIONS] ACTION [TARGETS...]

${YELLOW}ACTIONS:${NC}
    deploy              Deploy services (default)
    rollback            Rollback to previous version
    status              Show deployment status
    list                List available services/containers
    health              Run health checks only

${YELLOW}TARGETS:${NC}
    Service names, container names, or manifest files.
    If no targets specified, uses configuration file.

${YELLOW}OPTIONS:${NC}
    General:
      -h, --help                Show this help
      -V, --version             Show version
      -v, --verbose             Verbose output
      -q, --quiet               Quiet mode (errors only)
      --debug                   Debug mode (very verbose)
      
    Configuration:
      -c, --config FILE         Use specific config file
      -e, --env ENV             Environment (default: production)
      --deploy-root DIR         Deployment root directory
      --backup-dir DIR          Backup directory
      
    Deployment:
      -s, --service NAME        Add service to deploy (repeatable)
      -C, --container NAME      Add container to deploy (repeatable)
      -m, --manifest FILE       Use manifest file (repeatable)
      --strategy TYPE           Deployment strategy (rolling|blue-green|canary)
      
    Safety:
      --dry-run                 Simulate without making changes
      -f, --force               Force deployment (skip confirmations)
      --no-backup               Skip backup before deployment
      --no-rollback             Don't rollback on failure
      --skip-health-check       Skip health checks
      
    Health Checks:
      --health-retries N        Health check retries (default: 3)
      --health-interval N       Seconds between retries (default: 5)
      --health-timeout N        Health check timeout (default: 30)
      
    Docker:
      --registry URL            Docker registry URL
      --pull                    Pull latest images before deploy
      --no-pull                 Don't pull images
      
    Notifications:
      --notify-email EMAIL      Email for notifications
      --slack-webhook URL       Slack webhook URL
      --notify-success          Notify on success
      --no-notify               Disable all notifications
      
    Output:
      --output FORMAT           Output format (text|json)
      --log-file FILE           Log to file

${YELLOW}EXAMPLES:${NC}
    # Deploy all configured services
    $(basename "$0") deploy
    
    # Deploy specific service
    $(basename "$0") deploy -s myapp -s nginx
    
    # Deploy from manifest
    $(basename "$0") deploy -m /path/to/manifest.yaml
    
    # Deploy container
    $(basename "$0") deploy -C web-app --pull
    
    # Dry run deployment
    $(basename "$0") deploy --dry-run -v
    
    # Rollback last deployment
    $(basename "$0") rollback
    
    # Check health of services
    $(basename "$0") health -s myapp -s nginx
    
    # Production deployment with notifications
    $(basename "$0") deploy -e production --notify-email admin@example.com

${YELLOW}CONFIGURATION FILE:${NC}
    Searched in order:
      1. ./etc/deployer.conf
      2. ~/.config/deployer/deployer.conf
      3. /etc/deployer.conf
      4. /etc/deployer/deployer.conf

${YELLOW}EXIT CODES:${NC}
    0   Success
    1   Configuration error
    2   Deployment failed (partial)
    3   Fatal error (dependencies, permissions)
    4   Health check failed
    5   Rollback failed

For more information, see: README.md
EOF
}

# Display version
show_version() {
    echo "${DEPLOYER_NAME} v${DEPLOYER_VERSION}"
    echo "Bash ${BASH_VERSION}"
    echo ""
    echo "Environment: $(get_hostname)"
    echo "Docker: $(docker --version 2>/dev/null || echo 'not available')"
    echo "Systemd: $(systemctl --version 2>/dev/null | head -1 || echo 'not available')"
}

# Parse CLI arguments
# Args: $@ = command line arguments
parse_args() {
    # Reset arrays
    SERVICES=()
    CONTAINERS=()
    MANIFESTS=()
    
    while [[ $# -gt 0 ]]; do
        case "$1" in
            # Actions
            deploy|rollback|status|list|health)
                ACTION="$1"
                shift
                ;;
                
            # Help and version
            -h|--help)
                show_help
                exit 0
                ;;
            -V|--version)
                show_version
                exit 0
                ;;
                
            # Verbosity
            -v|--verbose)
                VERBOSE=true
                CURRENT_LOG_LEVEL=$LOG_LEVEL_DEBUG
                shift
                ;;
            -q|--quiet)
                QUIET=true
                CURRENT_LOG_LEVEL=$LOG_LEVEL_ERROR
                shift
                ;;
            --debug)
                VERBOSE=true
                CURRENT_LOG_LEVEL=$LOG_LEVEL_DEBUG
                set -x
                shift
                ;;
                
            # Configuration
            -c|--config)
                if [[ -z "${2:-}" ]]; then
                    die "Option $1 requires a file argument"
                fi
                load_config_file "$2"
                shift 2
                ;;
            -e|--env|--environment)
                ENVIRONMENT="${2:-}"
                [[ -z "$ENVIRONMENT" ]] && die "Option $1 requires an argument"
                shift 2
                ;;
            --deploy-root)
                DEPLOY_ROOT="${2:-}"
                [[ -z "$DEPLOY_ROOT" ]] && die "Option $1 requires a directory"
                shift 2
                ;;
            --backup-dir)
                BACKUP_DIR="${2:-}"
                [[ -z "$BACKUP_DIR" ]] && die "Option $1 requires a directory"
                shift 2
                ;;
                
            # Targets
            -s|--service)
                [[ -z "${2:-}" ]] && die "Option $1 requires a service name"
                SERVICES+=("$2")
                shift 2
                ;;
            -C|--container)
                [[ -z "${2:-}" ]] && die "Option $1 requires a container name"
                CONTAINERS+=("$2")
                shift 2
                ;;
            -m|--manifest)
                [[ -z "${2:-}" ]] && die "Option $1 requires a manifest file"
                MANIFESTS+=("$2")
                shift 2
                ;;
                
            # Strategy
            --strategy)
                STRATEGY="${2:-}"
                [[ -z "$STRATEGY" ]] && die "Option $1 requires a strategy type"
                shift 2
                ;;
                
            # Safety flags
            --dry-run)
                DRY_RUN=true
                shift
                ;;
            -f|--force)
                FORCE=true
                shift
                ;;
            --no-backup)
                NO_BACKUP=true
                shift
                ;;
            --no-rollback)
                ROLLBACK_ON_FAILURE=false
                shift
                ;;
            --skip-health-check)
                SKIP_HEALTH_CHECK=true
                HEALTH_CHECK_ENABLED=false
                shift
                ;;
                
            # Health check options
            --health-retries)
                HEALTH_CHECK_RETRIES="${2:-}"
                [[ -z "$HEALTH_CHECK_RETRIES" ]] && die "Option $1 requires a number"
                shift 2
                ;;
            --health-interval)
                HEALTH_CHECK_INTERVAL="${2:-}"
                [[ -z "$HEALTH_CHECK_INTERVAL" ]] && die "Option $1 requires a number"
                shift 2
                ;;
            --health-timeout)
                HEALTH_CHECK_TIMEOUT="${2:-}"
                [[ -z "$HEALTH_CHECK_TIMEOUT" ]] && die "Option $1 requires a number"
                shift 2
                ;;
                
            # Docker options
            --registry)
                DOCKER_REGISTRY="${2:-}"
                [[ -z "$DOCKER_REGISTRY" ]] && die "Option $1 requires a URL"
                shift 2
                ;;
            --pull)
                DOCKER_PULL=true
                shift
                ;;
            --no-pull)
                DOCKER_PULL=false
                shift
                ;;
                
            # Notifications
            --notify-email)
                NOTIFY_EMAIL="${2:-}"
                [[ -z "$NOTIFY_EMAIL" ]] && die "Option $1 requires an email"
                shift 2
                ;;
            --slack-webhook)
                SLACK_WEBHOOK="${2:-}"
                [[ -z "$SLACK_WEBHOOK" ]] && die "Option $1 requires a URL"
                shift 2
                ;;
            --notify-success)
                NOTIFY_ON_SUCCESS=true
                shift
                ;;
            --no-notify)
                NOTIFY_ON_SUCCESS=false
                NOTIFY_ON_FAILURE=false
                shift
                ;;
                
            # Output
            --output)
                OUTPUT_FORMAT="${2:-}"
                [[ -z "$OUTPUT_FORMAT" ]] && die "Option $1 requires format (text|json)"
                shift 2
                ;;
            --log-file)
                LOG_FILE="${2:-}"
                LOG_TO_FILE=true
                [[ -z "$LOG_FILE" ]] && die "Option $1 requires a file path"
                shift 2
                ;;
                
            # Parallel execution
            --parallel)
                PARALLEL=true
                shift
                ;;
                
            # Unknown option
            -*)
                die "Unknown option: $1. Use --help for usage."
                ;;
                
            # Positional arguments (treated as targets)
            *)
                # Detect target type
                if [[ -f "$1" ]]; then
                    MANIFESTS+=("$1")
                elif [[ "$1" =~ \.ya?ml$ ]]; then
                    MANIFESTS+=("$1")
                elif [[ "$1" =~ : ]]; then
                    # Looks like image:tag
                    CONTAINERS+=("$1")
                else
                    SERVICES+=("$1")
                fi
                shift
                ;;
        esac
    done
}

# ==============================================================================
# VALIDATION
# ==============================================================================

# Validate configuration
validate_config() {
    local errors=0
    
    log_debug "Validating configuration..."
    
    # Validate environment
    case "$ENVIRONMENT" in
        development|staging|production|testing)
            log_debug "  Environment: $ENVIRONMENT"
            ;;
        *)
            log_warn "Unknown environment: $ENVIRONMENT (using as-is)"
            ;;
    esac
    
    # Validate strategy
    case "$STRATEGY" in
        rolling|blue-green|canary|in-place)
            log_debug "  Strategy: $STRATEGY"
            ;;
        *)
            log_error "Invalid deployment strategy: $STRATEGY"
            ((errors++))
            ;;
    esac
    
    # Validate directories (with automatic creation in non-dry-run mode)
    for dir_var in DEPLOY_ROOT BACKUP_DIR LOG_DIR RUN_DIR; do
        local dir="${!dir_var}"
        if [[ ! -d "$dir" ]]; then
            if [[ "$DRY_RUN" != "true" ]]; then
                mkdir -p "$dir" 2>/dev/null || {
                    log_error "Cannot create directory: $dir"
                    ((errors++))
                }
            else
                log_debug "  Would create: $dir"
            fi
        fi
    done
    
    # Validate numeric values
    if ! is_positive_integer "$HEALTH_CHECK_RETRIES"; then
        log_error "Invalid health check retries: $HEALTH_CHECK_RETRIES"
        ((errors++))
    fi
    
    if ! is_positive_integer "$HEALTH_CHECK_INTERVAL"; then
        log_error "Invalid health check interval: $HEALTH_CHECK_INTERVAL"
        ((errors++))
    fi
    
    if ! is_positive_integer "$HEALTH_CHECK_TIMEOUT"; then
        log_error "Invalid health check timeout: $HEALTH_CHECK_TIMEOUT"
        ((errors++))
    fi
    
    # Validate manifest files
    for manifest in "${MANIFESTS[@]}"; do
        if [[ ! -f "$manifest" ]]; then
            log_error "Manifest file not found: $manifest"
            ((errors++))
        fi
    done
    
    # Validate Docker if needed
    if [[ ${#CONTAINERS[@]} -gt 0 ]]; then
        if ! docker_available; then
            log_error "Docker is required but not available"
            ((errors++))
        fi
    fi
    
    # Validate log file
    if [[ "$LOG_TO_FILE" == "true" && -n "$LOG_FILE" ]]; then
        local log_dir
        log_dir=$(dirname "$LOG_FILE")
        if [[ ! -d "$log_dir" ]]; then
            mkdir -p "$log_dir" 2>/dev/null || {
                log_warn "Cannot create log directory: $log_dir"
                LOG_TO_FILE=false
            }
        fi
    fi
    
    # Check that we have something to deploy
    if [[ ${#SERVICES[@]} -eq 0 && ${#CONTAINERS[@]} -eq 0 && ${#MANIFESTS[@]} -eq 0 ]]; then
        if [[ "$ACTION" == "deploy" || "$ACTION" == "rollback" || "$ACTION" == "health" ]]; then
            log_warn "No deployment targets specified"
        fi
    fi
    
    if [[ $errors -gt 0 ]]; then
        log_error "Configuration validation failed with $errors error(s)"
        return 1
    fi
    
    log_debug "Configuration valid"
    return 0
}

# ==============================================================================
# CONFIGURATION DISPLAY
# ==============================================================================

# Display current configuration
show_config() {
    log_header "Current Configuration"
    
    echo "Environment:     $ENVIRONMENT"
    echo "Strategy:        $STRATEGY"
    echo "Deploy Root:     $DEPLOY_ROOT"
    echo "Backup Dir:      $BACKUP_DIR"
    echo ""
    echo "Health Checks:"
    echo "  Enabled:       $HEALTH_CHECK_ENABLED"
    echo "  Retries:       $HEALTH_CHECK_RETRIES"
    echo "  Interval:      ${HEALTH_CHECK_INTERVAL}s"
    echo "  Timeout:       ${HEALTH_CHECK_TIMEOUT}s"
    echo ""
    echo "Safety:"
    echo "  Dry Run:       $DRY_RUN"
    echo "  Force:         $FORCE"
    echo "  No Backup:     $NO_BACKUP"
    echo "  Rollback:      $ROLLBACK_ON_FAILURE"
    echo ""
    echo "Targets:"
    echo "  Services:      ${SERVICES[*]:-none}"
    echo "  Containers:    ${CONTAINERS[*]:-none}"
    echo "  Manifests:     ${MANIFESTS[*]:-none}"
    echo ""
}

# Export configuration as JSON
export_config_json() {
    cat << EOF
{
  "environment": "$ENVIRONMENT",
  "strategy": "$STRATEGY",
  "deploy_root": "$DEPLOY_ROOT",
  "backup_dir": "$BACKUP_DIR",
  "health_check": {
    "enabled": $HEALTH_CHECK_ENABLED,
    "retries": $HEALTH_CHECK_RETRIES,
    "interval": $HEALTH_CHECK_INTERVAL,
    "timeout": $HEALTH_CHECK_TIMEOUT
  },
  "dry_run": $DRY_RUN,
  "force": $FORCE,
  "no_backup": $NO_BACKUP,
  "rollback_on_failure": $ROLLBACK_ON_FAILURE,
  "services": $(printf '%s\n' "${SERVICES[@]:-}" | jq -R . | jq -s .),
  "containers": $(printf '%s\n' "${CONTAINERS[@]:-}" | jq -R . | jq -s .),
  "manifests": $(printf '%s\n' "${MANIFESTS[@]:-}" | jq -R . | jq -s .)
}
EOF
}

# ==============================================================================
# INITIALISATION
# ==============================================================================

# Complete configuration initialisation
# Args: $@ = CLI arguments
init_config() {
    # Load default configuration from file (if exists)
    load_config_file || true
    
    # Parse CLI arguments (override file)
    parse_args "$@"
    
    # Set log level from configuration
    case "${LOG_LEVEL:-INFO}" in
        DEBUG) CURRENT_LOG_LEVEL=$LOG_LEVEL_DEBUG ;;
        INFO)  CURRENT_LOG_LEVEL=$LOG_LEVEL_INFO ;;
        WARN)  CURRENT_LOG_LEVEL=$LOG_LEVEL_WARN ;;
        ERROR) CURRENT_LOG_LEVEL=$LOG_LEVEL_ERROR ;;
    esac
    
    # Set hooks dir
    if [[ -z "$HOOKS_DIR" ]]; then
        HOOKS_DIR="$(dirname "${BASH_SOURCE[0]}")/../hooks"
    fi
    
    # Set lock file
    LOCK_FILE="$RUN_DIR/deployer.lock"
    
    # Set log file if not specified
    if [[ "$LOG_TO_FILE" == "true" && -z "$LOG_FILE" ]]; then
        LOG_FILE="$LOG_DIR/deployer.log"
    fi
    
    # Validation
    if ! validate_config; then
        return 1
    fi
    
    # Display configuration in verbose mode
    if [[ "$VERBOSE" == "true" ]]; then
        show_config
    fi
    
    return 0
}
