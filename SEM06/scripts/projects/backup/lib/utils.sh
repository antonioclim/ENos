#!/bin/bash
#==============================================================================
# utils.sh - Utility functions for backup operations
#==============================================================================
# DESCRIPTION:
#   Functions for archiving, compression, rotation and backup verification.
#
# AUTHOR: ASE Bucharest - CSIE | Operating Systems
# VERSION: 1.0.0
#==============================================================================

readonly UTILS_VERSION="1.0.0"

#------------------------------------------------------------------------------
# COMPRESSION AND ARCHIVING
#------------------------------------------------------------------------------

# Determine extension based on compression type
get_archive_extension() {
    local compression="${1:-gz}"
    
    case "$compression" in
        gz|gzip)    echo ".tar.gz" ;;
        bz2|bzip2)  echo ".tar.bz2" ;;
        xz)         echo ".tar.xz" ;;
        zstd)       echo ".tar.zst" ;;
        none|tar)   echo ".tar" ;;
        *)          echo ".tar.gz" ;;
    esac
}

# Determine tar option for compression
get_tar_compress_option() {
    local compression="${1:-gz}"
    
    case "$compression" in
        gz|gzip)    echo "-z" ;;
        bz2|bzip2)  echo "-j" ;;
        xz)         echo "-J" ;;
        zstd)       echo "--zstd" ;;
        none|tar)   echo "" ;;
        *)          echo "-z" ;;
    esac
}

# Create an archive
# Usage: create_archive SOURCE DESTINATION [COMPRESSION] [EXCLUDE_FILE]
create_archive() {
    local source="$1"
    local destination="$2"
    local compression="${3:-gz}"
    local exclude_file="${4:-}"
    
    local compress_opt
    compress_opt=$(get_tar_compress_option "$compression")
    
    local source_dir source_name
    source_dir=$(dirname "$source")
    source_name=$(basename "$source")
    
    # Build tar command
    local tar_cmd=(tar)
    
    # Add compression if specified
    if [[ -n "$compress_opt" ]]; then
        tar_cmd+=("$compress_opt")
    fi
    
    # Add exclude file if exists
    if [[ -n "$exclude_file" ]] && [[ -f "$exclude_file" ]]; then
        tar_cmd+=(--exclude-from="$exclude_file")
    fi
    
    # Add standard options
    tar_cmd+=(
        --create
        --file="$destination"
        --directory="$source_dir"
        "$source_name"
    )
    
    log_debug "Executing: ${tar_cmd[*]}"
    
    if "${tar_cmd[@]}" 2>&1 | while read -r line; do log_debug "tar: $line"; done; then
        return 0
    else
        return 1
    fi
}

# Extract an archive
# Usage: extract_archive ARCHIVE DESTINATION
extract_archive() {
    local archive="$1"
    local destination="$2"
    
    [[ -f "$archive" ]] || { log_error "Archive does not exist: $archive"; return 1; }
    
    mkdir -p "$destination" || { log_error "Cannot create: $destination"; return 1; }
    
    local extension="${archive##*.}"
    local tar_opts=()
    
    # Auto-detect compression
    case "$archive" in
        *.tar.gz|*.tgz)   tar_opts+=("-z") ;;
        *.tar.bz2|*.tbz2) tar_opts+=("-j") ;;
        *.tar.xz|*.txz)   tar_opts+=("-J") ;;
        *.tar.zst)        tar_opts+=(--zstd) ;;
    esac
    
    tar "${tar_opts[@]}" -xf "$archive" -C "$destination" || return 1
    
    log_info "Archive extracted to: $destination"
    return 0
}

# List archive contents
list_archive_contents() {
    local archive="$1"
    
    [[ -f "$archive" ]] || { log_error "Archive does not exist: $archive"; return 1; }
    
    local tar_opts=()
    
    case "$archive" in
        *.tar.gz|*.tgz)   tar_opts+=("-z") ;;
        *.tar.bz2|*.tbz2) tar_opts+=("-j") ;;
        *.tar.xz|*.txz)   tar_opts+=("-J") ;;
        *.tar.zst)        tar_opts+=(--zstd) ;;
    esac
    
    tar "${tar_opts[@]}" -tvf "$archive"
}

#------------------------------------------------------------------------------
# BACKUP ROTATION
#------------------------------------------------------------------------------

# Get list of backups sorted by date (oldest first)
# Usage: get_sorted_backups DIRECTORY PATTERN
get_sorted_backups() {
    local directory="$1"
    local pattern="${2:-backup_*.tar*}"
    
    find "$directory" -maxdepth 1 -type f -name "$pattern" -printf '%T+ %p\n' 2>/dev/null | \
        sort | cut -d' ' -f2-
}

# Rotate backups keeping only last N
# Usage: rotate_backups DIRECTORY COUNT [PATTERN]
rotate_backups() {
    local directory="$1"
    local keep_count="$2"
    local pattern="${3:-backup_*.tar*}"
    
    log_info "Rotating backups in $directory (keeping last $keep_count)"
    
    # Get sorted list (oldest first)
    local backups=()
    while IFS= read -r backup; do
        [[ -n "$backup" ]] && backups+=("$backup")
    done < <(get_sorted_backups "$directory" "$pattern")
    
    local total=${#backups[@]}
    log_debug "Total backups found: $total"
    
    if [[ $total -le $keep_count ]]; then
        log_info "Backup count ($total) <= limit ($keep_count), nothing to delete"
        return 0
    fi
    
    local to_delete=$((total - keep_count))
    local deleted=0
    
    for ((i=0; i<to_delete; i++)); do
        local backup="${backups[$i]}"
        log_info "Deleting old backup: $(basename "$backup")"
        
        if rm -f "$backup"; then
            ((deleted++))
        else
            log_error "Cannot delete: $backup"
        fi
    done
    
    log_info "Rotation complete: $deleted backups deleted"
    return 0
}

# Rotation based on age (days)
# Usage: rotate_by_age DIRECTORY DAYS [PATTERN]
rotate_by_age() {
    local directory="$1"
    local max_age_days="$2"
    local pattern="${3:-backup_*.tar*}"
    
    log_info "Deleting backups older than $max_age_days days from $directory"
    
    local deleted=0
    
    while IFS= read -r backup; do
        if [[ -n "$backup" ]]; then
            log_info "Deleting old backup: $(basename "$backup")"
            rm -f "$backup" && ((deleted++))
        fi
    done < <(find "$directory" -maxdepth 1 -type f -name "$pattern" -mtime +"$max_age_days" 2>/dev/null)
    
    log_info "Deleted $deleted old backups"
    return 0
}

#------------------------------------------------------------------------------
# BACKUP POLICIES (daily/weekly/monthly)
#------------------------------------------------------------------------------

# Determine backup type for current day
get_backup_type_for_today() {
    local day_of_month=$(date +%d)
    local day_of_week=$(date +%u)  # 1=Monday, 7=Sunday
    
    # First day of month = monthly
    if [[ "$day_of_month" == "01" ]]; then
        echo "monthly"
    # Sunday = weekly
    elif [[ "$day_of_week" == "7" ]]; then
        echo "weekly"
    # Otherwise = daily
    else
        echo "daily"
    fi
}

# Get backup name based on type
get_backup_name_for_type() {
    local type="$1"
    local prefix="${2:-backup}"
    
    case "$type" in
        daily)
            echo "${prefix}_daily_$(date +%Y%m%d)"
            ;;
        weekly)
            echo "${prefix}_weekly_$(date +%Y)-W$(date +%V)"
            ;;
        monthly)
            echo "${prefix}_monthly_$(date +%Y%m)"
            ;;
        *)
            echo "${prefix}_$(date +%Y%m%d_%H%M%S)"
            ;;
    esac
}

# Get retention for a backup type
get_retention_for_type() {
    local type="$1"
    local daily="${2:-7}"
    local weekly="${3:-4}"
    local monthly="${4:-12}"
    
    case "$type" in
        daily)   echo "$daily" ;;
        weekly)  echo "$weekly" ;;
        monthly) echo "$monthly" ;;
        *)       echo "$daily" ;;
    esac
}

#------------------------------------------------------------------------------
# VERIFICATION AND INTEGRITY
#------------------------------------------------------------------------------

# Verify archive integrity
verify_backup_integrity() {
    local archive="$1"
    
    log_info "Verifying integrity: $(basename "$archive")"
    
    [[ -f "$archive" ]] || { log_error "File does not exist: $archive"; return 1; }
    
    local tar_opts=()
    
    case "$archive" in
        *.tar.gz|*.tgz)   tar_opts+=("-z") ;;
        *.tar.bz2|*.tbz2) tar_opts+=("-j") ;;
        *.tar.xz|*.txz)   tar_opts+=("-J") ;;
        *.tar.zst)        tar_opts+=(--zstd) ;;
    esac
    
    # Test integrity
    if tar "${tar_opts[@]}" -tf "$archive" &>/dev/null; then
        log_info "✓ Archive is valid"
        return 0
    else
        log_error "✗ Archive is corrupted or invalid"
        return 1
    fi
}

# Calculate checksum for a file
calculate_checksum() {
    local file="$1"
    local algorithm="${2:-sha256}"
    
    case "$algorithm" in
        md5)
            md5sum "$file" | awk '{print $1}'
            ;;
        sha1)
            sha1sum "$file" | awk '{print $1}'
            ;;
        sha256)
            sha256sum "$file" | awk '{print $1}'
            ;;
        *)
            sha256sum "$file" | awk '{print $1}'
            ;;
    esac
}

# Save checksum to a companion file
save_checksum() {
    local archive="$1"
    local algorithm="${2:-sha256}"
    
    local checksum_file="${archive}.${algorithm}"
    local checksum
    checksum=$(calculate_checksum "$archive" "$algorithm")
    
    echo "$checksum  $(basename "$archive")" > "$checksum_file"
    log_debug "Checksum saved: $checksum_file"
}

# Verify checksum
verify_checksum() {
    local archive="$1"
    local algorithm="${2:-sha256}"
    
    local checksum_file="${archive}.${algorithm}"
    
    if [[ ! -f "$checksum_file" ]]; then
        log_warn "Missing checksum file: $checksum_file"
        return 1
    fi
    
    local expected_checksum
    expected_checksum=$(awk '{print $1}' "$checksum_file")
    
    local actual_checksum
    actual_checksum=$(calculate_checksum "$archive" "$algorithm")
    
    if [[ "$expected_checksum" == "$actual_checksum" ]]; then
        log_info "✓ Checksum valid"
        return 0
    else
        log_error "✗ Invalid checksum!"
        log_error "  Expected: $expected_checksum"
        log_error "  Actual:   $actual_checksum"
        return 1
    fi
}

#------------------------------------------------------------------------------
# STATISTICS AND REPORTING
#------------------------------------------------------------------------------

# Get file size in bytes
get_file_size() {
    local file="$1"
    stat -c%s "$file" 2>/dev/null || ls -l "$file" | awk '{print $5}'
}

# Get directory size in bytes
get_dir_size() {
    local dir="$1"
    du -sb "$dir" 2>/dev/null | awk '{print $1}'
}

# Count files in a directory
count_files() {
    local dir="$1"
    local pattern="${2:-*}"
    
    find "$dir" -type f -name "$pattern" 2>/dev/null | wc -l
}

# Generate report for a backup
generate_backup_report() {
    local archive="$1"
    local source="$2"
    local duration="$3"
    
    local archive_size source_size compression_ratio
    archive_size=$(get_file_size "$archive")
    source_size=$(get_dir_size "$source" 2>/dev/null || echo 0)
    
    if [[ $source_size -gt 0 ]] && [[ $archive_size -gt 0 ]]; then
        compression_ratio=$(echo "scale=2; $source_size / $archive_size" | bc -l 2>/dev/null || echo "N/A")
    else
        compression_ratio="N/A"
    fi
    
    cat << EOF

=== BACKUP REPORT ===
Archive:           $(basename "$archive")
Source:            $source
Source size:       $(format_bytes "$source_size")
Archive size:      $(format_bytes "$archive_size")
Compression ratio: ${compression_ratio}:1
Duration:          $(format_duration "$duration")
Timestamp:         $(date '+%Y-%m-%d %H:%M:%S')
=====================
EOF
}

#------------------------------------------------------------------------------
# HELPER FUNCTIONS
#------------------------------------------------------------------------------

# Check if a path is in exclude list
is_excluded() {
    local path="$1"
    shift
    local excludes=("$@")
    
    for exclude in "${excludes[@]}"; do
        case "$path" in
            $exclude|$exclude/*) return 0 ;;
        esac
    done
    return 1
}

# Create temporary exclude file
create_exclude_file() {
    local temp_file
    temp_file=$(mktemp)
    
    # Add patterns received as arguments
    for pattern in "$@"; do
        echo "$pattern" >> "$temp_file"
    done
    
    echo "$temp_file"
}

# Get available space in MB
get_available_space_mb() {
    local path="${1:-/}"
    df -m "$path" 2>/dev/null | awk 'NR==2 {print $4}'
}

# Estimate backup size
estimate_backup_size() {
    local source="$1"
    
    local size_bytes
    size_bytes=$(du -sb "$source" 2>/dev/null | awk '{print $1}')
    
    # Estimate 60% for gzip compression
    local estimated=$((size_bytes * 60 / 100))
    
    echo "$estimated"
}

#------------------------------------------------------------------------------
# INITIALISATION
#------------------------------------------------------------------------------

# Check dependencies
_check_backup_dependencies() {
    local required=(tar gzip find)
    local optional=(bzip2 xz zstd md5sum sha256sum bc)
    local missing=()
    
    for cmd in "${required[@]}"; do
        command -v "$cmd" &>/dev/null || missing+=("$cmd")
    done
    
    if [[ ${#missing[@]} -gt 0 ]]; then
        log_error "Missing required commands: ${missing[*]}"
        return 1
    fi
    
    for cmd in "${optional[@]}"; do
        if ! command -v "$cmd" &>/dev/null; then
            log_debug "Missing optional command: $cmd"
        fi
    done
    
    return 0
}

_check_backup_dependencies

log_debug "utils.sh v${UTILS_VERSION} loaded (backup)"
