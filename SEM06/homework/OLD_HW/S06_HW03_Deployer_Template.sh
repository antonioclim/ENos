#!/usr/bin/env bash
#
# S06_HW03_Deployer_Template.sh - Template for deployment assignment
#
# INSTRUCTIONS:
# 1. Complete functions marked with TODO
# 2. Do not modify function signatures
# 3. Run tests with: ./test_hw03.sh
#
# Author: [Your name]
# Group: [Your group]
# Date: [Date]
#
# NEW material for Curricular Redistribution
# Operating Systems | ASE Bucharest - CSIE
#

set -euo pipefail

# === CONFIGURATION ===
readonly SCRIPT_NAME=$(basename "$0")
readonly VERSION="1.0"
readonly DEFAULT_DEPLOY_DIR="${DEPLOY_DIR:-/var/www/app}"
readonly DEFAULT_BACKUP_DIR="${BACKUP_DIR:-/var/backups/deploys}"
readonly DEFAULT_RELEASES_KEEP=5

# === LOGGING ===
log() {
    local level="${1:-INFO}"
    shift
    printf '[%s] [%-5s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$level" "$*"
}

die() {
    log "FATAL" "$*" >&2
    exit 1
}

# === USAGE ===
usage() {
    cat << EOF
Usage: $SCRIPT_NAME <command> [options]

Commands:
    deploy      Deploy a new version
    rollback    Revert to previous version
    list        List available versions
    status      Display current status
    cleanup     Delete old versions

Deploy options:
    -s, --source DIR     Source directory (required)
    -d, --dest DIR       Destination directory (default: $DEFAULT_DEPLOY_DIR)
    -t, --tag TAG        Tag/version for release
    --pre-hook SCRIPT    Script to execute before deploy
    --post-hook SCRIPT   Script to execute after deploy
    --no-backup          Don't backup before deploy

Rollback options:
    -r, --release ID     Release ID for rollback
    -n, --steps N        Number of versions for rollback (default: 1)

Cleanup options:
    -k, --keep N         Number of versions to keep (default: $DEFAULT_RELEASES_KEEP)

Examples:
    $SCRIPT_NAME deploy -s ./dist -t v1.2.3
    $SCRIPT_NAME rollback -n 1
    $SCRIPT_NAME list
    $SCRIPT_NAME cleanup -k 3

Exit codes:
    0 - Success
    1 - General error
    2 - Argument validation error
    3 - Deploy error
    4 - Rollback error

EOF
    exit "${1:-0}"
}

# === HELPER FUNCTIONS ===

# Generate unique release ID
# TODO: Implement this function
# Hint: Use timestamp + tag
generate_release_id() {
    local tag="${1:-}"
    # TODO: Return a unique ID, e.g.: 20250127_153045_v1.2.3
    echo "TODO"
}

# Verify source directory is valid
# TODO: Implement this function
validate_source() {
    local source="$1"
    # TODO: Verify source exists and contains files
    return 0
}

# Create directory structure for releases
# TODO: Implement this function
setup_release_structure() {
    local deploy_dir="$1"
    # TODO: Create:
    # - $deploy_dir/releases/
    # - $deploy_dir/shared/
    # - Symlink: $deploy_dir/current -> releases/latest
    return 0
}

# === CORE FUNCTIONS ===

# Deploy function
# TODO: Implement main deploy logic
do_deploy() {
    local source=""
    local dest="$DEFAULT_DEPLOY_DIR"
    local tag=""
    local pre_hook=""
    local post_hook=""
    local no_backup=false

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -s|--source) source="$2"; shift 2 ;;
            -d|--dest) dest="$2"; shift 2 ;;
            -t|--tag) tag="$2"; shift 2 ;;
            --pre-hook) pre_hook="$2"; shift 2 ;;
            --post-hook) post_hook="$2"; shift 2 ;;
            --no-backup) no_backup=true; shift ;;
            *) die "Unknown option: $1" ;;
        esac
    done

    # Validate
    [[ -n "$source" ]] || die "Source directory required (-s)"
    validate_source "$source" || die "Invalid source: $source"

    local release_id
    release_id=$(generate_release_id "$tag")
    local release_dir="$dest/releases/$release_id"

    log "INFO" "Starting deploy: $release_id"
    log "INFO" "Source: $source"
    log "INFO" "Destination: $release_dir"

    # TODO: Implement deploy steps:
    # 1. Setup release structure (if doesn't exist)
    # 2. Backup current (if not --no-backup)
    # 3. Execute pre-hook (if exists)
    # 4. Copy files to release_dir
    # 5. Update "current" symlink
    # 6. Execute post-hook (if exists)
    # 7. Health check

    log "INFO" "Deploy completed: $release_id"
}

# Rollback function
# TODO: Implement rollback logic
do_rollback() {
    local release=""
    local steps=1

    while [[ $# -gt 0 ]]; do
        case $1 in
            -r|--release) release="$2"; shift 2 ;;
            -n|--steps) steps="$2"; shift 2 ;;
            *) die "Unknown option: $1" ;;
        esac
    done

    log "INFO" "Starting rollback..."

    # TODO: Implement rollback:
    # 1. Find previous release
    # 2. Verify it exists
    # 3. Update "current" symlink
    # 4. Optional: Health check

    log "INFO" "Rollback completed"
}

# List releases
# TODO: Implement version listing
do_list() {
    local deploy_dir="${1:-$DEFAULT_DEPLOY_DIR}"

    log "INFO" "Available releases in $deploy_dir:"

    # TODO: List releases in chronological order
    # Mark current release with [CURRENT]

    echo "TODO: List releases"
}

# Show status
# TODO: Implement status display
do_status() {
    local deploy_dir="${1:-$DEFAULT_DEPLOY_DIR}"

    log "INFO" "Deployment status:"

    # TODO: Display:
    # - Current release
    # - Last deploy date
    # - Number of available releases
    # - Space used

    echo "TODO: Show status"
}

# Cleanup old releases
# TODO: Implement old version cleanup
do_cleanup() {
    local keep=$DEFAULT_RELEASES_KEEP
    local deploy_dir="$DEFAULT_DEPLOY_DIR"

    while [[ $# -gt 0 ]]; do
        case $1 in
            -k|--keep) keep="$2"; shift 2 ;;
            -d|--dest) deploy_dir="$2"; shift 2 ;;
            *) die "Unknown option: $1" ;;
        esac
    done

    log "INFO" "Cleaning up, keeping $keep releases..."

    # TODO: Implement cleanup:
    # 1. Find all releases
    # 2. Sort by date
    # 3. Keep last $keep
    # 4. Delete rest (don't delete "current"!)

    log "INFO" "Cleanup completed"
}

# === HEALTH CHECK ===

# Verify application works after deploy
# TODO: Implement health check
health_check() {
    local url="${1:-http://localhost:8080/health}"
    local timeout="${2:-30}"
    local retries="${3:-5}"

    log "INFO" "Running health check: $url"

    # TODO: Implement:
    # - Verify URL responds with 200
    # - Retry with exponential backoff
    # - Return 0 for success, 1 for failure

    return 0
}

# === HOOKS ===

# Execute a hook script
run_hook() {
    local hook="$1"
    local stage="$2"

    [[ -n "$hook" ]] || return 0

    if [[ -x "$hook" ]]; then
        log "INFO" "Running $stage hook: $hook"
        if ! "$hook"; then
            log "ERROR" "$stage hook failed"
            return 1
        fi
    else
        log "WARN" "Hook not executable: $hook"
        return 1
    fi
}

# === MAIN ===
main() {
    [[ $# -ge 1 ]] || usage 1

    local command="$1"
    shift

    case "$command" in
        deploy)   do_deploy "$@" ;;
        rollback) do_rollback "$@" ;;
        list)     do_list "$@" ;;
        status)   do_status "$@" ;;
        cleanup)  do_cleanup "$@" ;;
        -h|--help) usage ;;
        -v|--version) echo "$SCRIPT_NAME version $VERSION"; exit 0 ;;
        *) die "Unknown command: $command" ;;
    esac
}

main "$@"

# *By Revolvix for OPERATING SYSTEMS class | restricted licence 2017-2030*
