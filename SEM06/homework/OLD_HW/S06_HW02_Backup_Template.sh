#!/usr/bin/env bash
#
# S06_HW02_Backup_Template.sh - Template for backup assignment
#
# INSTRUCTIONS:
# 1. Complete functions marked with TODO
# 2. Do not modify function signatures
# 3. Run tests with: ./test_hw02.sh
#
# Author: [Your name]
# Group: [Your group]
# Date: [Date]
#

set -euo pipefail

# === CONFIGURATION ===
readonly SCRIPT_NAME=$(basename "$0")
readonly VERSION="1.0"
readonly DEFAULT_BACKUP_DIR="${BACKUP_DIR:-/tmp/backups}"
readonly DEFAULT_RETENTION=7

# === HELPER FUNCTIONS ===
log() {
    local level="${1:-INFO}"
    shift
    printf '[%s] [%-5s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$level" "$*"
}

die() {
    log "FATAL" "$*" >&2
    exit 1
}

usage() {
    cat << EOF
Usage: $SCRIPT_NAME <command> [options]

Commands:
    create      Create a new backup
    list        List existing backups
    restore     Restore a backup
    rotate      Delete old backups

Create options:
    -s, --source DIR    Source directory (required)
    -d, --dest DIR      Destination directory (default: $DEFAULT_BACKUP_DIR)
    -t, --type TYPE     Type: full|incremental (default: full)
    -c, --compress ALG  Compression: gz|bz2|xz (default: gz)

Restore options:
    -b, --backup ID     Backup ID
    -d, --dest DIR      Restore location

Rotate options:
    -r, --retention N   Retention days (default: $DEFAULT_RETENTION)

Examples:
    $SCRIPT_NAME create -s /var/www -t full
    $SCRIPT_NAME list
    $SCRIPT_NAME restore -b backup_20240115_143022 -d /tmp/restore
    $SCRIPT_NAME rotate -r 7
EOF
    exit 0
}

# === TODO: IMPLEMENT THESE FUNCTIONS ===

# Function: create_backup
# Description: Create a backup archive from specified source
# Input: 
#   $1 = source_dir (source directory)
#   $2 = dest_dir (destination directory)
#   $3 = type (full or incremental)
#   $4 = compress (gz, bz2, or xz)
# Output: Path to created backup file
# Return: 0 if success, 1 if error
create_backup() {
    local source_dir="$1"
    local dest_dir="$2"
    local type="$3"
    local compress="$4"
    
    # TODO: Implement
    # Suggested steps:
    # 1. Validate that source_dir exists
    # 2. Create dest_dir if it doesn't exist
    # 3. Generate filename: backup_YYYYMMDD_HHMMSS.tar.{gz|bz2|xz}
    # 4. Select tar option for compression (z, j, J)
    # 5. If type=incremental, use --newer-mtime with last backup date
    # 6. Execute tar to create archive
    # 7. Verify archive was created
    # 8. Display size and return path
    
    log "INFO" "create_backup: NOT IMPLEMENTED"
    return 1
}

# Function: list_backups
# Description: List all backups in specified directory
# Input: $1 = backup_dir
# Output: List of backups (name, date, size)
list_backups() {
    local backup_dir="$1"
    
    # TODO: Implement
    # Suggested steps:
    # 1. Verify backup_dir exists
    # 2. Find all backup_*.tar.* files
    # 3. For each, display: name, modification date, size
    # 4. Use tabular format
    
    log "INFO" "list_backups: NOT IMPLEMENTED"
}

# Function: restore_backup
# Description: Restore a backup to specified location
# Input:
#   $1 = backup_file (path to backup file)
#   $2 = dest_dir (restore directory)
# Return: 0 if success, 1 if error
restore_backup() {
    local backup_file="$1"
    local dest_dir="$2"
    
    # TODO: Implement
    # Suggested steps:
    # 1. Verify backup_file exists
    # 2. Create dest_dir if it doesn't exist
    # 3. Detect compression type from extension
    # 4. Extract archive to dest_dir
    # 5. Verify integrity (optional: checksum)
    
    log "INFO" "restore_backup: NOT IMPLEMENTED"
    return 1
}

# Function: rotate_backups
# Description: Delete backups older than N days
# Input:
#   $1 = backup_dir
#   $2 = retention_days
# Output: Number of deleted files
rotate_backups() {
    local backup_dir="$1"
    local retention_days="$2"
    
    # TODO: Implement
    # Suggested steps:
    # 1. Find backup_*.tar.* files older than retention_days
    # 2. Display what will be deleted
    # 3. Delete files
    # 4. Return number of deleted files
    
    log "INFO" "rotate_backups: NOT IMPLEMENTED"
    echo "0"
}

# Function: calculate_checksum
# Description: Calculate and save file checksum
# Input: $1 = file_path
# Output: MD5 or SHA256 checksum
calculate_checksum() {
    local file="$1"
    
    # TODO: Implement
    # Use md5sum or sha256sum
    
    echo "NOT_IMPLEMENTED"
}

# Function: verify_checksum
# Description: Verify backup integrity
# Input: $1 = backup_file
# Return: 0 if valid, 1 if invalid
verify_checksum() {
    local backup_file="$1"
    
    # TODO: Implement
    # Compare current checksum with saved one
    
    return 1
}

# === MAIN ===
main() {
    [[ $# -lt 1 ]] && usage
    
    local command="$1"
    shift
    
    # Defaults
    local source_dir=""
    local dest_dir="$DEFAULT_BACKUP_DIR"
    local backup_type="full"
    local compress="gz"
    local backup_id=""
    local retention="$DEFAULT_RETENTION"
    
    # Parse subcommand options
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -s|--source) source_dir="$2"; shift 2 ;;
            -d|--dest) dest_dir="$2"; shift 2 ;;
            -t|--type) backup_type="$2"; shift 2 ;;
            -c|--compress) compress="$2"; shift 2 ;;
            -b|--backup) backup_id="$2"; shift 2 ;;
            -r|--retention) retention="$2"; shift 2 ;;
            -h|--help) usage ;;
            *) die "Unknown option: $1" ;;
        esac
    done
    
    case "$command" in
        create)
            [[ -z "$source_dir" ]] && die "Specify source directory with -s"
            create_backup "$source_dir" "$dest_dir" "$backup_type" "$compress"
            ;;
        list)
            list_backups "$dest_dir"
            ;;
        restore)
            [[ -z "$backup_id" ]] && die "Specify backup with -b"
            local backup_file="$DEFAULT_BACKUP_DIR/$backup_id"
            [[ ! -f "$backup_file" ]] && backup_file=$(find "$DEFAULT_BACKUP_DIR" -name "${backup_id}*" | head -1)
            restore_backup "$backup_file" "$dest_dir"
            ;;
        rotate)
            rotate_backups "$dest_dir" "$retention"
            ;;
        *)
            die "Unknown command: $command"
            ;;
    esac
}

main "$@"

# *By Revolvix for OPERATING SYSTEMS class | restricted licence 2017-2030*
