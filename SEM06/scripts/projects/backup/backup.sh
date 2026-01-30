#!/bin/bash
# =============================================================================
# ENTERPRISE BACKUP SYSTEM - Main Script
# =============================================================================
# Professional backup system with modular architecture
#
# Features:
#   - Incremental and full backup
#   - Multiple compression (gzip, bzip2, xz, zstd)
#   - Flexible retention policies
#   - Integrity verification with checksum
#   - Automatic rotation
#   - Complete logging
#   - Email notifications
#
# Author: Educational Kit OS - ASE Bucharest CSIE
# Version: 1.0.0
# =============================================================================

set -euo pipefail

# =============================================================================
# GLOBAL CONFIGURATION
# =============================================================================

readonly SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_VERSION="1.0.0"

# Directories relative to script
readonly LIB_DIR="${SCRIPT_DIR}/lib"
readonly ETC_DIR="${SCRIPT_DIR}/etc"
readonly VAR_DIR="${SCRIPT_DIR}/var"

# Configuration files
readonly DEFAULT_CONFIG="${ETC_DIR}/backup.conf"

# =============================================================================
# MODULE LOADING
# =============================================================================

# Verify and load modules in order
load_modules() {
    local modules=("core" "utils" "config")
    local module
    
    for module in "${modules[@]}"; do
        local module_file="${LIB_DIR}/${module}.sh"
        
        if [[ ! -f "$module_file" ]]; then
            echo "[FATAL] Missing module: ${module_file}" >&2
            exit 1
        fi
        
        # shellcheck source=/dev/null
        source "$module_file"
    done
}

# Load modules
load_modules

# =============================================================================
# MAIN BACKUP FUNCTIONS
# =============================================================================

# -----------------------------------------------------------------------------
# Prepare environment for backup
# -----------------------------------------------------------------------------
prepare_backup_environment() {
    log_info "Preparing backup environment..."
    
    # Create necessary directories
    local dirs=("$BACKUP_DEST" "$LOG_DIR" "${VAR_DIR}/log" "${VAR_DIR}/run")
    local dir
    
    for dir in "${dirs[@]}"; do
        if [[ ! -d "$dir" ]]; then
            if ! mkdir -p "$dir" 2>/dev/null; then
                log_warn "Cannot create directory: $dir (continuing without)"
            else
                log_debug "Directory created: $dir"
            fi
        fi
    done
    
    # Check available space
    local available_mb
    available_mb=$(get_available_space_mb "$BACKUP_DEST" 2>/dev/null || echo "0")
    
    if [[ "$available_mb" -lt 100 ]]; then
        log_warn "Low space in destination: ${available_mb}MB available"
    else
        log_debug "Available space in destination: ${available_mb}MB"
    fi
    
    return 0
}

# -----------------------------------------------------------------------------
# Execute pre-backup script
# -----------------------------------------------------------------------------
run_pre_backup_script() {
    if [[ -z "${PRE_BACKUP_SCRIPT:-}" ]]; then
        return 0
    fi
    
    if [[ ! -x "$PRE_BACKUP_SCRIPT" ]]; then
        log_warn "Pre-backup script is not executable: $PRE_BACKUP_SCRIPT"
        return 0
    fi
    
    log_info "Executing pre-backup script: $PRE_BACKUP_SCRIPT"
    
    local timeout="${SCRIPT_TIMEOUT:-300}"
    
    if timeout "$timeout" "$PRE_BACKUP_SCRIPT"; then
        log_info "Pre-backup script executed successfully"
        return 0
    else
        local exit_code=$?
        log_error "Pre-backup script failed with code: $exit_code"
        return "$exit_code"
    fi
}

# -----------------------------------------------------------------------------
# Execute post-backup script
# -----------------------------------------------------------------------------
run_post_backup_script() {
    local archive_path="${1:-}"
    
    if [[ -z "${POST_BACKUP_SCRIPT:-}" ]]; then
        return 0
    fi
    
    if [[ ! -x "$POST_BACKUP_SCRIPT" ]]; then
        log_warn "Post-backup script is not executable: $POST_BACKUP_SCRIPT"
        return 0
    fi
    
    log_info "Executing post-backup script: $POST_BACKUP_SCRIPT"
    
    local timeout="${SCRIPT_TIMEOUT:-300}"
    
    if timeout "$timeout" "$POST_BACKUP_SCRIPT" "$archive_path"; then
        log_info "Post-backup script executed successfully"
        return 0
    else
        local exit_code=$?
        log_warn "Post-backup script failed with code: $exit_code"
        return 0  # Don't stop process for post-backup errors
    fi
}

# -----------------------------------------------------------------------------
# Create the actual backup
# -----------------------------------------------------------------------------
perform_backup() {
    local backup_type="${1:-daily}"
    local sources=("${BACKUP_SOURCES[@]}")
    
    # Generate backup name
    local backup_name
    backup_name=$(get_backup_name_for_type "$backup_type")
    
    local archive_path="${BACKUP_DEST}/${backup_name}"
    
    log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    log_info "Initiating ${backup_type^^} backup"
    log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    log_info "Sources: ${sources[*]}"
    log_info "Destination: $archive_path"
    log_info "Compression: ${COMPRESSION:-gzip}"
    
    # Check that sources exist
    local valid_sources=()
    local source
    
    for source in "${sources[@]}"; do
        if [[ -e "$source" ]]; then
            valid_sources+=("$source")
            log_debug "Valid source: $source"
        else
            log_warn "Non-existent source (ignored): $source"
        fi
    done
    
    if [[ ${#valid_sources[@]} -eq 0 ]]; then
        log_error "No valid sources for backup!"
        return 1
    fi
    
    # Create temporary exclude file
    local exclude_file
    exclude_file=$(mktemp)
    trap "rm -f '$exclude_file'" RETURN
    
    create_exclude_file "$exclude_file"
    
    # Dry-run mode
    if [[ "${DRY_RUN:-false}" == "true" ]]; then
        log_info "[DRY-RUN] Would create archive: $archive_path"
        log_info "[DRY-RUN] Sources: ${valid_sources[*]}"
        return 0
    fi
    
    # Estimate size
    local estimated_size
    estimated_size=$(estimate_backup_size "${valid_sources[@]}" 2>/dev/null || echo "unknown")
    log_info "Estimated size: $estimated_size"
    
    # Create archive
    log_info "Creating archive..."
    local start_time
    start_time=$(date +%s)
    
    if ! create_archive "$archive_path" "$exclude_file" "${valid_sources[@]}"; then
        log_error "Error creating archive!"
        return 1
    fi
    
    local end_time
    end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    # Archive statistics
    if [[ -f "$archive_path" ]]; then
        local archive_size
        archive_size=$(get_file_size "$archive_path")
        
        log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        log_info "Backup created successfully!"
        log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        log_info "Archive: $archive_path"
        log_info "Size: $archive_size"
        log_info "Duration: ${duration}s"
        
        # Save in global variables for report
        BACKUP_ARCHIVE_PATH="$archive_path"
        BACKUP_ARCHIVE_SIZE="$archive_size"
        BACKUP_DURATION="$duration"
    else
        log_error "Archive was not created!"
        return 1
    fi
    
    return 0
}

# -----------------------------------------------------------------------------
# Verify created backup
# -----------------------------------------------------------------------------
verify_created_backup() {
    local archive_path="${BACKUP_ARCHIVE_PATH:-}"
    
    if [[ -z "$archive_path" || ! -f "$archive_path" ]]; then
        log_warn "No archive to verify"
        return 0
    fi
    
    if [[ "${VERIFY_BACKUP:-true}" != "true" ]]; then
        log_debug "Backup verification is disabled"
        return 0
    fi
    
    log_info "Verifying backup integrity..."
    
    # Verify archive
    if [[ "${VERIFY_ARCHIVE_LISTING:-true}" == "true" ]]; then
        if verify_backup_integrity "$archive_path"; then
            log_info "✓ Archive is valid"
        else
            log_error "✗ Archive is corrupted!"
            return 1
        fi
    fi
    
    # Save checksum
    if [[ "${SAVE_CHECKSUM:-true}" == "true" ]]; then
        local checksum_file="${archive_path}.${CHECKSUM_ALGORITHM:-sha256}"
        
        if save_checksum "$archive_path" "$checksum_file"; then
            log_info "✓ Checksum saved: $checksum_file"
        else
            log_warn "Could not save checksum"
        fi
    fi
    
    return 0
}

# -----------------------------------------------------------------------------
# Apply retention policy
# -----------------------------------------------------------------------------
apply_retention_policy() {
    local backup_type="${1:-daily}"
    
    log_info "Applying retention policy for: $backup_type"
    
    local retention
    retention=$(get_retention_for_type "$backup_type")
    
    log_debug "Retention for $backup_type: $retention backups"
    
    # Number-based rotation
    local rotated
    rotated=$(rotate_backups "$BACKUP_DEST" "$retention" "${BACKUP_PREFIX:-backup}_${backup_type}")
    
    if [[ "$rotated" -gt 0 ]]; then
        log_info "Old backups deleted: $rotated"
    else
        log_debug "No backups to delete"
    fi
    
    return 0
}

# -----------------------------------------------------------------------------
# Generate final report
# -----------------------------------------------------------------------------
generate_final_report() {
    local status="${1:-SUCCESS}"
    local error_msg="${2:-}"
    
    log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    log_info "              BACKUP REPORT"
    log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    log_info "Status: $status"
    log_info "Date: $(date '+%Y-%m-%d %H:%M:%S')"
    log_info "Host: $(hostname)"
    
    if [[ -n "${BACKUP_ARCHIVE_PATH:-}" ]]; then
        log_info "Archive: $BACKUP_ARCHIVE_PATH"
        log_info "Size: ${BACKUP_ARCHIVE_SIZE:-unknown}"
        log_info "Duration: ${BACKUP_DURATION:-0}s"
    fi
    
    if [[ -n "$error_msg" ]]; then
        log_info "Error: $error_msg"
    fi
    
    log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # Send email notification if configured
    if [[ "${NOTIFY_EMAIL:-false}" == "true" ]]; then
        send_notification "$status" "$error_msg"
    fi
}

# -----------------------------------------------------------------------------
# Send notification
# -----------------------------------------------------------------------------
send_notification() {
    local status="${1:-SUCCESS}"
    local error_msg="${2:-}"
    
    # Check whether to send notification
    if [[ "$status" == "SUCCESS" && "${NOTIFY_ON_SUCCESS:-false}" != "true" ]]; then
        if [[ "${NOTIFY_ON_ERROR_ONLY:-true}" == "true" ]]; then
            log_debug "Success notification disabled"
            return 0
        fi
    fi
    
    local subject
    if [[ "$status" == "SUCCESS" ]]; then
        subject="${EMAIL_SUBJECT_SUCCESS:-[BACKUP] Success: $(hostname)}"
    else
        subject="${EMAIL_SUBJECT_ERROR:-[BACKUP] ERROR: $(hostname)}"
    fi
    
    local body="Backup Report
================
Status: $status
Date: $(date '+%Y-%m-%d %H:%M:%S')
Host: $(hostname)
Archive: ${BACKUP_ARCHIVE_PATH:-N/A}
Size: ${BACKUP_ARCHIVE_SIZE:-N/A}
Duration: ${BACKUP_DURATION:-0}s
${error_msg:+Error: $error_msg}"
    
    local recipients="${EMAIL_RECIPIENTS:-root}"
    
    if command -v mail &>/dev/null; then
        echo "$body" | mail -s "$subject" "$recipients" 2>/dev/null && \
            log_info "Email notification sent" || \
            log_warn "Error sending email notification"
    else
        log_debug "Command 'mail' is not available"
    fi
}

# -----------------------------------------------------------------------------
# List existing backups
# -----------------------------------------------------------------------------
list_backups() {
    log_info "Existing backups in: $BACKUP_DEST"
    log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    if [[ ! -d "$BACKUP_DEST" ]]; then
        log_warn "Backup directory does not exist"
        return 0
    fi
    
    local count=0
    local total_size=0
    
    while IFS= read -r archive; do
        if [[ -n "$archive" ]]; then
            local size
            size=$(stat -c%s "$archive" 2>/dev/null || echo "0")
            local human_size
            human_size=$(numfmt --to=iec-i --suffix=B "$size" 2>/dev/null || echo "${size}B")
            local date
            date=$(stat -c%y "$archive" 2>/dev/null | cut -d' ' -f1,2 | cut -d'.' -f1)
            
            printf "  %-50s %10s  %s\n" "$(basename "$archive")" "$human_size" "$date"
            
            ((count++))
            total_size=$((total_size + size))
        fi
    done < <(find "$BACKUP_DEST" -maxdepth 1 -name "*.tar*" -type f 2>/dev/null | sort)
    
    log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    local total_human
    total_human=$(numfmt --to=iec-i --suffix=B "$total_size" 2>/dev/null || echo "${total_size}B")
    log_info "Total: $count backups, $total_human"
}

# -----------------------------------------------------------------------------
# Restore a backup
# -----------------------------------------------------------------------------
restore_backup() {
    local archive="${1:-}"
    local dest="${2:-.}"
    
    if [[ -z "$archive" ]]; then
        log_error "Archive to restore must be specified"
        return 1
    fi
    
    # Resolve archive path
    if [[ ! -f "$archive" ]]; then
        local full_path="${BACKUP_DEST}/${archive}"
        if [[ -f "$full_path" ]]; then
            archive="$full_path"
        else
            log_error "Archive does not exist: $archive"
            return 1
        fi
    fi
    
    # Verify checksum if exists
    local checksum_file="${archive}.${CHECKSUM_ALGORITHM:-sha256}"
    if [[ -f "$checksum_file" ]]; then
        log_info "Verifying checksum..."
        if verify_checksum "$archive" "$checksum_file"; then
            log_info "✓ Checksum valid"
        else
            log_error "✗ Invalid checksum! Archive may be corrupted."
            return 1
        fi
    fi
    
    log_info "Restoring backup: $archive"
    log_info "Destination: $dest"
    
    if [[ "${DRY_RUN:-false}" == "true" ]]; then
        log_info "[DRY-RUN] Would extract to: $dest"
        log_info "[DRY-RUN] Archive contents:"
        list_archive_contents "$archive" | head -20
        return 0
    fi
    
    # Create destination directory if it doesn't exist
    mkdir -p "$dest"
    
    # Extract archive
    if extract_archive "$archive" "$dest"; then
        log_info "✓ Backup restored successfully to: $dest"
        return 0
    else
        log_error "Error restoring backup!"
        return 1
    fi
}

# =============================================================================
# MAIN FUNCTION
# =============================================================================

main() {
    # Global variables for report
    BACKUP_ARCHIVE_PATH=""
    BACKUP_ARCHIVE_SIZE=""
    BACKUP_DURATION=""
    
    # Initialise configuration
    init_config "$@"
    
    # Configure logging
    setup_logging
    
    # Process special modes
    case "${MODE:-backup}" in
        list)
            list_backups
            exit 0
            ;;
        restore)
            restore_backup "${RESTORE_ARCHIVE:-}" "${RESTORE_DEST:-.}"
            exit $?
            ;;
        verify)
            if [[ -n "${VERIFY_ARCHIVE:-}" ]]; then
                if verify_backup_integrity "$VERIFY_ARCHIVE"; then
                    log_info "✓ Archive is valid"
                    exit 0
                else
                    log_error "✗ Archive is corrupted"
                    exit 1
                fi
            else
                log_error "Archive to verify must be specified (--verify-archive)"
                exit 1
            fi
            ;;
    esac
    
    # Normal backup mode
    local exit_code=0
    local error_msg=""
    
    log_info "═══════════════════════════════════════════════════════════════"
    log_info "     ENTERPRISE BACKUP SYSTEM v${SCRIPT_VERSION}"
    log_info "═══════════════════════════════════════════════════════════════"
    log_info "Starting backup: $(date '+%Y-%m-%d %H:%M:%S')"
    log_info "Host: $(hostname)"
    
    # Acquire lock
    if ! acquire_lock "${LOCK_FILE:-/var/run/backup.lock}" "${LOCK_TIMEOUT:-60}"; then
        log_error "Cannot acquire lock. Another backup running?"
        exit 1
    fi
    
    # Cleanup on exit
    trap 'release_lock "${LOCK_FILE:-/var/run/backup.lock}"; generate_final_report "${exit_code:-1}" "$error_msg"' EXIT
    
    # Prepare environment
    if ! prepare_backup_environment; then
        error_msg="Error preparing environment"
        exit_code=1
        exit "$exit_code"
    fi
    
    # Execute pre-backup script
    if ! run_pre_backup_script; then
        error_msg="Pre-backup script failed"
        exit_code=1
        exit "$exit_code"
    fi
    
    # Determine backup type
    local backup_type
    backup_type=$(get_backup_type_for_today)
    log_info "Determined backup type: $backup_type"
    
    # Override with manually specified type
    if [[ -n "${BACKUP_TYPE:-}" ]]; then
        backup_type="$BACKUP_TYPE"
        log_info "Backup type override: $backup_type"
    fi
    
    # Execute backup
    if ! perform_backup "$backup_type"; then
        error_msg="Error creating backup"
        exit_code=2
        exit "$exit_code"
    fi
    
    # Verify backup
    if ! verify_created_backup; then
        error_msg="Backup verification failed"
        exit_code=3
        exit "$exit_code"
    fi
    
    # Apply retention
    apply_retention_policy "$backup_type"
    
    # Execute post-backup script
    run_post_backup_script "${BACKUP_ARCHIVE_PATH:-}"
    
    log_info "═══════════════════════════════════════════════════════════════"
    log_info "     BACKUP COMPLETED SUCCESSFULLY"
    log_info "═══════════════════════════════════════════════════════════════"
    
    exit_code=0
    exit "$exit_code"
}

# =============================================================================
# ENTRY POINT
# =============================================================================

# Run only if not sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi

# =============================================================================
# EXIT CODES:
# 0 = Success
# 1 = Configuration/environment error
# 2 = Error creating backup
# 3 = Verification error
# 4 = Critical error
# =============================================================================
