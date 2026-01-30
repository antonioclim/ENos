# Backup Project - Detailed Implementation

## Contents

1. [General Overview](#1-general-overview)
2. [System Architecture](#2-system-architecture)
3. [Core Module - backup_core.sh](#3-core-module---backup_coresh)
4. [Utilities Module - backup_utils.sh](#4-utilities-module---backup_utilssh)
5. [Configuration Module - backup_config.sh](#5-configuration-module---backup_configsh)
6. [Main Script - backup.sh](#6-main-script---backupsh)
7. [Backup Strategies](#7-backup-strategies)
8. [Verification and Restoration](#8-verification-and-restoration)
9. [Implementation Exercises](#9-implementation-exercises)

---

## 1. General Overview

### 1.1 Project Purpose

The **Backup** project implements a complete backup and restoration system, offering:

- **Full Backup**: Complete archiving of specified sources
- **Incremental Backup**: Only files modified since the last backup
- **Multiple Compression**: Support for gzip, bzip2, xz, zstd
- **Integrity Verification**: Checksums MD5, SHA1, SHA256
- **Automatic Rotation**: Retention policies (daily, weekly, monthly)
- **Selective Restoration**: Complete or partial extraction
- **Pattern Exclusions**: Glob and regex support for exclusions

### 1.2 File Structure

```
projects/backup/
├── backup.sh               # Main script (~900 lines)
├── lib/
│   ├── backup_core.sh      # Backup/restore functions (~700 lines)
│   ├── backup_utils.sh     # Common utilities (~500 lines)
│   └── backup_config.sh    # Configuration management (~400 lines)
└── config/
    └── backup.conf         # Default configuration
```

### 1.3 Data Flow

```
┌──────────────────────────────────────────────────────────────────────────┐
│                           BACKUP WORKFLOW                                 │
│                                                                          │
│  ┌─────────┐     ┌─────────────┐     ┌────────────┐     ┌─────────────┐  │
│  │ Sources │────▶│ Exclusions  │────▶│ Archiving  │────▶│ Compression │  │
│  │ /home   │     │  *.log      │     │ tar -cvf   │     │ gzip/xz     │  │
│  │ /etc    │     │  node_mod*  │     │            │     │             │  │
│  └─────────┘     └─────────────┘     └────────────┘     └─────────────┘  │
│                                                                │         │
│                                                                ▼         │
│  ┌─────────────┐     ┌─────────────┐     ┌────────────┐  ┌──────────┐   │
│  │ Metadata    │◀────│ Checksum    │◀────│ Manifest   │◀─│ Archive  │   │
│  │ .meta file  │     │ SHA256      │     │ file list  │  │ .tar.gz  │   │
│  └─────────────┘     └─────────────┘     └────────────┘  └──────────┘   │
│                                                                          │
└──────────────────────────────────────────────────────────────────────────┘
```

---

## 2. System Architecture

### 2.1 Component Diagram

```
┌─────────────────────────────────────────────────────────────────────────┐
│                           backup.sh (Main)                               │
├─────────────────────────────────────────────────────────────────────────┤
│  main() ─┬─ parse_arguments()                                           │
│          ├─ load_config()                                               │
│          ├─ validate_sources()                                          │
│          └─ execute_action()                                            │
│                  │                                                       │
│         ┌───────┴────────┬─────────────────┬──────────────────┐         │
│         ▼                ▼                 ▼                  ▼         │
│    do_backup()     do_restore()     do_verify()        do_list()       │
└─────────────────────────────────────────────────────────────────────────┘
              │                │                │
              ▼                ▼                ▼
┌──────────────────────────────────────────────────────────────────────────┐
│                         backup_core.sh                                    │
├──────────────────────────────────────────────────────────────────────────┤
│  create_archive()          extract_archive()         verify_archive()    │
│  create_incremental()      extract_selective()       verify_checksum()   │
│  compress_archive()        list_archive()            generate_checksum() │
│  apply_rotation()          find_latest_backup()      compare_checksums() │
└──────────────────────────────────────────────────────────────────────────┘
              │                │                │
              ▼                ▼                ▼
┌──────────────────────────────────────────────────────────────────────────┐
│                         backup_utils.sh                                   │
├──────────────────────────────────────────────────────────────────────────┤
│  log_message()       format_bytes()         get_timestamp()              │
│  log_progress()      format_duration()      is_incremental_mode()        │
│  create_lockfile()   human_readable_size()  get_compression_ext()        │
│  remove_lockfile()   calculate_size()       estimate_compression()       │
└──────────────────────────────────────────────────────────────────────────┘
```

### 2.2 Archive Naming Conventions

The system uses a consistent convention for archive names:

```
<prefix>_<type>_<timestamp>.<ext>

Examples:
  backup_full_20240115_143022.tar.gz      # Full backup
  backup_incr_20240115_143022.tar.gz      # Incremental backup
  backup_full_20240115_143022.tar.gz.sha256   # Checksum
  backup_full_20240115_143022.meta        # Metadata
  backup_full_20240115_143022.manifest    # File list
```

### 2.3 Backup Directory Structure

```
/var/backups/mybackup/
├── daily/                    # Daily backups
│   ├── backup_full_20240115_020000.tar.gz
│   ├── backup_incr_20240116_020000.tar.gz
│   └── ...
├── weekly/                   # Weekly backups
│   ├── backup_full_20240108_030000.tar.gz
│   └── ...
├── monthly/                  # Monthly backups
│   ├── backup_full_20240101_040000.tar.gz
│   └── ...
├── latest -> daily/backup_full_20240115_020000.tar.gz  # Symlink
└── .state/                   # State for incremental
    ├── snapshot.snar         # GNU tar snapshot
    └── last_backup.timestamp # Last backup timestamp
```

---

## 3. Core Module - backup_core.sh

### 3.1 The create_archive() Function

This is the main function for creating backups:

```bash
create_archive() {
    local backup_type="${1:-full}"
    local destination="${2:-}"
    local -a sources=("${@:3}")
    
    # Initial validations
    if [[ ${#sources[@]} -eq 0 ]]; then
        log_error "No sources specified for backup"
        return 1
    fi
    
    if [[ -z "$destination" ]]; then
        destination=$(get_config "backup_destination" "/var/backups")
    fi
    
    # Create destination directory if it doesn't exist
    mkdir -p "$destination" || {
        log_error "Cannot create directory: $destination"
        return 1
    }
    
    # Generate archive name
    local timestamp prefix archive_name
    timestamp=$(date '+%Y%m%d_%H%M%S')
    prefix=$(get_config "backup_prefix" "backup")
    
    case "$backup_type" in
        full)        archive_name="${prefix}_full_${timestamp}" ;;
        incremental) archive_name="${prefix}_incr_${timestamp}" ;;
        *)           archive_name="${prefix}_${backup_type}_${timestamp}" ;;
    esac
    
    # Determine extension based on compression
    local compression extension
    compression=$(get_config "compression" "gzip")
    extension=$(get_compression_extension "$compression")
    
    local archive_path="${destination}/${archive_name}.tar${extension}"
    
    log_info "Starting $backup_type backup: $archive_path"
    log_info "Sources: ${sources[*]}"
    
    # Build tar command
    local -a tar_cmd=(tar)
    
    # Basic options
    tar_cmd+=(--create)
    tar_cmd+=(--file="$archive_path")
    
    # Preserve permissions and metadata
    tar_cmd+=(--preserve-permissions)
    tar_cmd+=(--same-owner)
    tar_cmd+=(--atime-preserve=system)
    
    # Verbose if active
    if [[ "$(get_config 'verbose' 'false')" == "true" ]]; then
        tar_cmd+=(--verbose)
    fi
    
    # Add compression
    case "$compression" in
        gzip)  tar_cmd+=(--gzip) ;;
        bzip2) tar_cmd+=(--bzip2) ;;
        xz)    tar_cmd+=(--xz) ;;
        zstd)  tar_cmd+=(--zstd) ;;
        none)  ;; # No compression
    esac
    
    # Add exclusions
    local exclude_file
    exclude_file=$(create_exclude_file)
    if [[ -n "$exclude_file" ]]; then
        tar_cmd+=(--exclude-from="$exclude_file")
    fi
    
    # For incremental backup, use snapshot
    if [[ "$backup_type" == "incremental" ]]; then
        local snapshot_file="${destination}/.state/snapshot.snar"
        mkdir -p "$(dirname "$snapshot_file")"
        tar_cmd+=(--listed-incremental="$snapshot_file")
    fi
    
    # Add sources (with handle for spaces in path)
    for src in "${sources[@]}"; do
        if [[ -e "$src" ]]; then
            tar_cmd+=("$src")
        else
            log_warning "Source does not exist: $src"
        fi
    done
    
    # Execute backup with progress tracking
    local start_time end_time duration
    start_time=$(date +%s)
    
    log_info "Command: ${tar_cmd[*]}"
    
    if "${tar_cmd[@]}" 2>&1 | while IFS= read -r line; do
        log_debug "$line"
    done; then
        end_time=$(date +%s)
        duration=$((end_time - start_time))
        
        log_info "Backup completed in $(format_duration $duration)"
        
        # Generate metadata and checksum
        generate_metadata "$archive_path" "$backup_type" "${sources[@]}"
        generate_checksum "$archive_path"
        
        # Create symlink to latest
        create_latest_symlink "$archive_path"
        
        # Apply rotation if configured
        if [[ "$(get_config 'rotation_enabled' 'false')" == "true" ]]; then
            apply_rotation "$destination"
        fi
        
        # Cleanup
        [[ -n "$exclude_file" ]] && rm -f "$exclude_file"
        
        # Display statistics
        local archive_size
        archive_size=$(stat -c %s "$archive_path" 2>/dev/null || echo "0")
        log_info "Archive size: $(format_bytes $archive_size)"
        
        echo "$archive_path"
        return 0
    else
        log_error "Backup failed!"
        [[ -n "$exclude_file" ]] && rm -f "$exclude_file"
        
        # Delete partial archive
        [[ -f "$archive_path" ]] && rm -f "$archive_path"
        
        return 1
    fi
}
```

### 3.2 The create_exclude_file() Function

Generates a temporary file with exclusion patterns:

```bash
create_exclude_file() {
    local exclude_patterns exclude_file
    
    # Get patterns from configuration
    exclude_patterns=$(get_config "exclude_patterns" "")
    
    if [[ -z "$exclude_patterns" ]]; then
        return 0
    fi
    
    # Create temporary file
    exclude_file=$(mktemp)
    
    # Standard patterns
    cat > "$exclude_file" <<'EOF'
# Temporary files
*.tmp
*.temp
*.swp
*~

# Caches
.cache
__pycache__
*.pyc
node_modules

# Logs (optional)
*.log

# System files
/proc
/sys
/dev
/run
/tmp
/var/tmp
EOF
    
    # Add patterns from configuration
    echo "$exclude_patterns" | tr ',' '\n' >> "$exclude_file"
    
    # Add from external file if it exists
    local external_exclude
    external_exclude=$(get_config "exclude_file" "")
    
    if [[ -f "$external_exclude" ]]; then
        cat "$external_exclude" >> "$exclude_file"
    fi
    
    echo "$exclude_file"
}
```

### 3.3 The apply_rotation() Function

Implements the grandfather-father-son rotation policy:

```bash
apply_rotation() {
    local backup_dir="$1"
    
    local daily_keep weekly_keep monthly_keep
    daily_keep=$(get_config "rotation_daily" "7")
    weekly_keep=$(get_config "rotation_weekly" "4")
    monthly_keep=$(get_config "rotation_monthly" "12")
    
    log_info "Applying rotation: daily=$daily_keep, weekly=$weekly_keep, monthly=$monthly_keep"
    
    # Create rotation directories if they don't exist
    mkdir -p "${backup_dir}/daily"
    mkdir -p "${backup_dir}/weekly"
    mkdir -p "${backup_dir}/monthly"
    
    local today day_of_week day_of_month
    today=$(date '+%Y%m%d')
    day_of_week=$(date '+%u')  # 1=Monday, 7=Sunday
    day_of_month=$(date '+%d')
    
    # Process each backup in main directory
    for archive in "$backup_dir"/*.tar*; do
        [[ ! -f "$archive" ]] && continue
        
        local archive_name archive_date
        archive_name=$(basename "$archive")
        
        # Extract date from archive name (format: prefix_type_YYYYMMDD_HHMMSS)
        if [[ "$archive_name" =~ _([0-9]{8})_ ]]; then
            archive_date="${BASH_REMATCH[1]}"
        else
            continue
        fi
        
        # Calculate age in days
        local age_days
        age_days=$(( ($(date -d "$today" +%s) - $(date -d "$archive_date" +%s)) / 86400 ))
        
        # Classify the backup
        if [[ $age_days -eq 0 ]]; then
            # Today's backup - stays in daily
            mv_if_needed "$archive" "${backup_dir}/daily/"
            
        elif [[ $age_days -lt $daily_keep ]]; then
            # In daily window
            mv_if_needed "$archive" "${backup_dir}/daily/"
            
        elif [[ $age_days -lt $((weekly_keep * 7)) ]]; then
            # Candidate for weekly (keep only Sunday's)
            local archive_day_of_week
            archive_day_of_week=$(date -d "$archive_date" '+%u')
            
            if [[ "$archive_day_of_week" == "7" ]]; then
                mv_if_needed "$archive" "${backup_dir}/weekly/"
            else
                log_info "Deleting old daily backup: $archive_name"
                rm_with_related "$archive"
            fi
            
        elif [[ $age_days -lt $((monthly_keep * 30)) ]]; then
            # Candidate for monthly (keep first of month)
            local archive_day_of_month
            archive_day_of_month=$(date -d "$archive_date" '+%d')
            
            if [[ "$archive_day_of_month" == "01" ]]; then
                mv_if_needed "$archive" "${backup_dir}/monthly/"
            else
                log_info "Deleting old weekly backup: $archive_name"
                rm_with_related "$archive"
            fi
            
        else
            # Too old - delete
            log_info "Deleting old monthly backup: $archive_name"
            rm_with_related "$archive"
        fi
    done
    
    # Clean up in each rotation directory
    cleanup_rotation_dir "${backup_dir}/daily" "$daily_keep"
    cleanup_rotation_dir "${backup_dir}/weekly" "$weekly_keep"
    cleanup_rotation_dir "${backup_dir}/monthly" "$monthly_keep"
}

# Helper function for moving
mv_if_needed() {
    local src="$1"
    local dest_dir="$2"
    
    [[ ! -f "$src" ]] && return 0
    
    local dest="${dest_dir}/$(basename "$src")"
    
    if [[ "$src" != "$dest" ]]; then
        mv "$src" "$dest_dir/"
        
        # Also move associated files (.sha256, .meta, .manifest)
        local base="${src%.*.*}"  # Remove .tar.gz
        [[ -f "${base}.sha256" ]] && mv "${base}.sha256" "$dest_dir/"
        [[ -f "${base}.meta" ]] && mv "${base}.meta" "$dest_dir/"
        [[ -f "${base}.manifest" ]] && mv "${base}.manifest" "$dest_dir/"
    fi
}

# Delete archive and associated files
rm_with_related() {
    local archive="$1"
    
    rm -f "$archive"
    
    local base="${archive%.*.*}"
    rm -f "${base}.sha256"
    rm -f "${base}.meta"
    rm -f "${base}.manifest"
}

# Clean directory keeping only the last N archives
cleanup_rotation_dir() {
    local dir="$1"
    local keep="$2"
    
    [[ ! -d "$dir" ]] && return 0
    
    # Count archives
    local count
    count=$(find "$dir" -maxdepth 1 -name "*.tar*" -type f | wc -l)
    
    if [[ $count -gt $keep ]]; then
        local to_delete=$((count - keep))
        
        # Delete the oldest (sorted by date)
        find "$dir" -maxdepth 1 -name "*.tar*" -type f -printf '%T@ %p\n' | \
            sort -n | head -n "$to_delete" | cut -d' ' -f2- | \
            while IFS= read -r archive; do
                log_info "Rotation: deleting $archive"
                rm_with_related "$archive"
            done
    fi
}
```

### 3.4 The extract_archive() Function

Restores a backup completely or selectively:

```bash
extract_archive() {
    local archive="$1"
    local destination="${2:-.}"
    local -a files=("${@:3}")  # Specific files for selective extraction
    
    # Validations
    if [[ ! -f "$archive" ]]; then
        log_error "Archive does not exist: $archive"
        return 1
    fi
    
    # Verify integrity if checksum exists
    local checksum_file="${archive}.sha256"
    if [[ -f "$checksum_file" ]]; then
        log_info "Verifying integrity before restoration..."
        if ! verify_checksum "$archive"; then
            log_error "Integrity verification failed!"
            log_error "Archive may be corrupted. Use --force to continue."
            
            if [[ "$(get_config 'force' 'false')" != "true" ]]; then
                return 1
            fi
            log_warning "Forced continuation - beware of possible corruption!"
        fi
    fi
    
    # Create destination directory
    mkdir -p "$destination" || {
        log_error "Cannot create directory: $destination"
        return 1
    }
    
    # Detect compression type from extension
    local compression=""
    case "$archive" in
        *.tar.gz|*.tgz)   compression="--gzip" ;;
        *.tar.bz2|*.tbz2) compression="--bzip2" ;;
        *.tar.xz|*.txz)   compression="--xz" ;;
        *.tar.zst)        compression="--zstd" ;;
        *.tar)            compression="" ;;
    esac
    
    # Build tar command
    local -a tar_cmd=(tar)
    tar_cmd+=(--extract)
    tar_cmd+=(--file="$archive")
    tar_cmd+=(--directory="$destination")
    
    # Preserve permissions
    tar_cmd+=(--preserve-permissions)
    
    # Options for owner (requires root)
    if [[ $EUID -eq 0 ]]; then
        tar_cmd+=(--same-owner)
    else
        tar_cmd+=(--no-same-owner)
    fi
    
    # Compression
    [[ -n "$compression" ]] && tar_cmd+=("$compression")
    
    # Verbose
    if [[ "$(get_config 'verbose' 'false')" == "true" ]]; then
        tar_cmd+=(--verbose)
    fi
    
    # Specific files for selective extraction
    if [[ ${#files[@]} -gt 0 ]]; then
        log_info "Selective extraction: ${files[*]}"
        for f in "${files[@]}"; do
            # Remove leading slash for tar
            tar_cmd+=("${f#/}")
        done
    fi
    
    log_info "Restoring from: $archive"
    log_info "To: $destination"
    
    local start_time end_time
    start_time=$(date +%s)
    
    if "${tar_cmd[@]}" 2>&1 | while IFS= read -r line; do
        log_debug "$line"
    done; then
        end_time=$(date +%s)
        log_info "Restoration completed in $((end_time - start_time)) seconds"
        return 0
    else
        log_error "Restoration failed!"
        return 1
    fi
}

# Incremental restoration - requires all backups in order
restore_incremental() {
    local backup_dir="$1"
    local destination="$2"
    local target_date="${3:-}"  # Restore to a specific moment
    
    log_info "Incremental restoration from: $backup_dir"
    
    # Find the most recent full backup
    local full_backup
    full_backup=$(find "$backup_dir" -name "*_full_*.tar*" -type f | sort -r | head -1)
    
    if [[ -z "$full_backup" ]]; then
        log_error "No full backup found!"
        return 1
    fi
    
    log_info "Full backup: $(basename "$full_backup")"
    
    # Restore the full backup
    extract_archive "$full_backup" "$destination" || return 1
    
    # Find and apply incremental backups
    local full_timestamp
    if [[ "$full_backup" =~ _([0-9]{8}_[0-9]{6})\. ]]; then
        full_timestamp="${BASH_REMATCH[1]}"
    fi
    
    # Sort incrementals chronologically
    local -a incremental_backups
    while IFS= read -r -d '' incr; do
        if [[ "$incr" =~ _([0-9]{8}_[0-9]{6})\. ]]; then
            local incr_timestamp="${BASH_REMATCH[1]}"
            
            # Verify if newer than full
            if [[ "$incr_timestamp" > "$full_timestamp" ]]; then
                # Check target_date if specified
                if [[ -z "$target_date" ]] || [[ "$incr_timestamp" < "$target_date" ]]; then
                    incremental_backups+=("$incr")
                fi
            fi
        fi
    done < <(find "$backup_dir" -name "*_incr_*.tar*" -type f -print0 | sort -z)
    
    log_info "Found ${#incremental_backups[@]} incremental backups"
    
    # Apply incrementals in order
    for incr in "${incremental_backups[@]}"; do
        log_info "Applying incremental: $(basename "$incr")"
        extract_archive "$incr" "$destination" || {
            log_error "Error applying incremental backup!"
            return 1
        }
    done
    
    log_info "Incremental restoration completed"
    return 0
}
```

### 3.5 Verification Functions

```bash
generate_checksum() {
    local file="$1"
    local algorithm="${2:-sha256}"
    
    [[ ! -f "$file" ]] && return 1
    
    local checksum_file="${file}.${algorithm}"
    local checksum_cmd
    
    case "$algorithm" in
        md5)    checksum_cmd="md5sum" ;;
        sha1)   checksum_cmd="sha1sum" ;;
        sha256) checksum_cmd="sha256sum" ;;
        sha512) checksum_cmd="sha512sum" ;;
        *)
            log_error "Unknown algorithm: $algorithm"
            return 1
            ;;
    esac
    
    log_info "Generating $algorithm checksum for $(basename "$file")"
    
    if $checksum_cmd "$file" > "$checksum_file"; then
        log_info "Checksum saved: $checksum_file"
        return 0
    else
        log_error "Error generating checksum!"
        return 1
    fi
}

verify_checksum() {
    local file="$1"
    local algorithm="${2:-}"
    
    [[ ! -f "$file" ]] && {
        log_error "File does not exist: $file"
        return 1
    }
    
    # Auto-detect checksum type
    local checksum_file=""
    for algo in sha256 sha1 md5; do
        if [[ -f "${file}.${algo}" ]]; then
            checksum_file="${file}.${algo}"
            algorithm="$algo"
            break
        fi
    done
    
    if [[ -z "$checksum_file" ]]; then
        log_warning "No checksum file found for: $file"
        return 0  # Not an error - just no checksum
    fi
    
    local checksum_cmd
    case "$algorithm" in
        md5)    checksum_cmd="md5sum" ;;
        sha1)   checksum_cmd="sha1sum" ;;
        sha256) checksum_cmd="sha256sum" ;;
        sha512) checksum_cmd="sha512sum" ;;
    esac
    
    log_info "Verifying $algorithm: $(basename "$file")"
    
    # Change to file directory for correct verification
    local dir file_name
    dir=$(dirname "$file")
    file_name=$(basename "$file")
    
    if (cd "$dir" && $checksum_cmd --check --status "$(basename "$checksum_file")" 2>/dev/null); then
        log_info "✓ Integrity verification OK"
        return 0
    else
        log_error "✗ Integrity verification FAILED!"
        return 1
    fi
}

# Verify archive - test that it can be extracted
verify_archive() {
    local archive="$1"
    
    [[ ! -f "$archive" ]] && {
        log_error "Archive does not exist: $archive"
        return 1
    }
    
    log_info "Verifying archive: $archive"
    
    # Detect compression
    local compression=""
    case "$archive" in
        *.tar.gz|*.tgz)   compression="--gzip" ;;
        *.tar.bz2|*.tbz2) compression="--bzip2" ;;
        *.tar.xz|*.txz)   compression="--xz" ;;
        *.tar.zst)        compression="--zstd" ;;
    esac
    
    # Test with tar
    local -a tar_cmd=(tar --test-label --file="$archive")
    [[ -n "$compression" ]] && tar_cmd+=("$compression")
    
    if "${tar_cmd[@]}" 2>/dev/null; then
        log_info "✓ Archive is valid"
        
        # Also verify checksum if it exists
        verify_checksum "$archive"
        
        return 0
    else
        log_error "✗ Archive is corrupted or invalid!"
        return 1
    fi
}

# Generate manifest (file list)
generate_manifest() {
    local archive="$1"
    local manifest_file="${archive%.*.*}.manifest"
    
    [[ ! -f "$archive" ]] && return 1
    
    log_info "Generating manifest for $(basename "$archive")"
    
    # Detect compression
    local compression=""
    case "$archive" in
        *.tar.gz|*.tgz)   compression="--gzip" ;;
        *.tar.bz2|*.tbz2) compression="--bzip2" ;;
        *.tar.xz|*.txz)   compression="--xz" ;;
        *.tar.zst)        compression="--zstd" ;;
    esac
    
    local -a tar_cmd=(tar --list --verbose --file="$archive")
    [[ -n "$compression" ]] && tar_cmd+=("$compression")
    
    if "${tar_cmd[@]}" > "$manifest_file" 2>/dev/null; then
        local file_count
        file_count=$(wc -l < "$manifest_file")
        log_info "Manifest generated: $file_count files"
        return 0
    else
        log_error "Error generating manifest!"
        return 1
    fi
}
```

---

## 4. Utilities Module - backup_utils.sh

### 4.1 Progress and Logging Functions

```bash
# Variables for progress tracking
declare -g PROGRESS_PID=""
declare -g PROGRESS_ACTIVE=false

# Display progress spinner
show_progress() {
    local message="${1:-Working...}"
    local spin='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    local i=0
    
    PROGRESS_ACTIVE=true
    
    while $PROGRESS_ACTIVE; do
        printf "\r  %s %s" "${spin:i++%${#spin}:1}" "$message"
        sleep 0.1
    done
    
    printf "\r%*s\r" $((${#message} + 4)) ""
}

# Start progress in background
start_progress() {
    local message="$1"
    
    show_progress "$message" &
    PROGRESS_PID=$!
}

# Stop progress
stop_progress() {
    if [[ -n "$PROGRESS_PID" ]]; then
        PROGRESS_ACTIVE=false
        kill "$PROGRESS_PID" 2>/dev/null
        wait "$PROGRESS_PID" 2>/dev/null
        PROGRESS_PID=""
        printf "\r%*s\r" 60 ""
    fi
}

# Progress bar for known operations
show_progress_bar() {
    local current="$1"
    local total="$2"
    local width="${3:-50}"
    local prefix="${4:-Progress}"
    
    local percent=$((current * 100 / total))
    local filled=$((current * width / total))
    local empty=$((width - filled))
    
    local bar=""
    bar+=$(printf '%*s' "$filled" '' | tr ' ' '█')
    bar+=$(printf '%*s' "$empty" '' | tr ' ' '░')
    
    printf "\r%s: [%s] %3d%% (%d/%d)" \
        "$prefix" "$bar" "$percent" "$current" "$total"
    
    if [[ $current -eq $total ]]; then
        echo ""
    fi
}

# Log with timestamp and level
log_message() {
    local level="${1:-INFO}"
    local message="$2"
    local timestamp
    
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    local color=""
    case "$level" in
        DEBUG)    color="\e[36m" ;;
        INFO)     color="\e[32m" ;;
        WARNING)  color="\e[33m" ;;
        ERROR)    color="\e[31m" ;;
        CRITICAL) color="\e[1;31m" ;;
    esac
    
    local log_line="[$timestamp] [$level] $message"
    
    # Write to log file
    if [[ -n "${LOG_FILE:-}" ]]; then
        echo "$log_line" >> "$LOG_FILE"
    fi
    
    # Display to terminal
    if [[ -t 2 ]]; then
        printf "%b%s\e[0m\n" "$color" "$log_line" >&2
    else
        echo "$log_line" >&2
    fi
}
```

### 4.2 Formatting and Calculation Functions

```bash
# Format bytes to human readable
format_bytes() {
    local bytes="${1:-0}"
    local precision="${2:-2}"
    
    if ! [[ "$bytes" =~ ^[0-9]+$ ]]; then
        echo "0 B"
        return
    fi
    
    if [[ $bytes -lt 1024 ]]; then
        echo "${bytes} B"
    elif [[ $bytes -lt $((1024 * 1024)) ]]; then
        printf "%.${precision}f KiB" "$(echo "scale=10; $bytes / 1024" | bc)"
    elif [[ $bytes -lt $((1024 * 1024 * 1024)) ]]; then
        printf "%.${precision}f MiB" "$(echo "scale=10; $bytes / 1024 / 1024" | bc)"
    elif [[ $bytes -lt $((1024 * 1024 * 1024 * 1024)) ]]; then
        printf "%.${precision}f GiB" "$(echo "scale=10; $bytes / 1024 / 1024 / 1024" | bc)"
    else
        printf "%.${precision}f TiB" "$(echo "scale=10; $bytes / 1024 / 1024 / 1024 / 1024" | bc)"
    fi
}

# Format duration
format_duration() {
    local seconds="${1:-0}"
    
    if [[ $seconds -lt 60 ]]; then
        echo "${seconds}s"
    elif [[ $seconds -lt 3600 ]]; then
        printf "%dm %ds" $((seconds / 60)) $((seconds % 60))
    else
        printf "%dh %dm %ds" $((seconds / 3600)) $(((seconds % 3600) / 60)) $((seconds % 60))
    fi
}

# Calculate total source size
calculate_source_size() {
    local -a sources=("$@")
    local total_size=0
    
    for src in "${sources[@]}"; do
        if [[ -e "$src" ]]; then
            local size
            size=$(du -sb "$src" 2>/dev/null | cut -f1)
            total_size=$((total_size + size))
        fi
    done
    
    echo "$total_size"
}

# Estimate compression ratio
estimate_compression_ratio() {
    local compression="${1:-gzip}"
    
    # Typical compression ratios (approximate)
    case "$compression" in
        none)  echo "1.0" ;;
        gzip)  echo "0.4" ;;  # ~60% reduction
        bzip2) echo "0.35" ;; # ~65% reduction
        xz)    echo "0.30" ;; # ~70% reduction
        zstd)  echo "0.35" ;; # ~65% reduction
    esac
}

# Get extension based on compression
get_compression_extension() {
    local compression="${1:-gzip}"
    
    case "$compression" in
        none)  echo "" ;;
        gzip)  echo ".gz" ;;
        bzip2) echo ".bz2" ;;
        xz)    echo ".xz" ;;
        zstd)  echo ".zst" ;;
        *)     echo ".gz" ;;
    esac
}
```

### 4.3 Lock and Concurrency Functions

```bash
# Variables for lock
declare -g LOCK_FILE=""
declare -g LOCK_FD=""

create_lockfile() {
    local lock_name="${1:-backup}"
    LOCK_FILE="/var/lock/${lock_name}.lock"
    
    # Try to obtain the lock
    exec {LOCK_FD}>"$LOCK_FILE"
    
    if flock -n "$LOCK_FD"; then
        # We obtained the lock
        echo $$ > "$LOCK_FILE"
        log_debug "Lock obtained: $LOCK_FILE"
        return 0
    else
        # Someone else has the lock
        local other_pid
        other_pid=$(cat "$LOCK_FILE" 2>/dev/null || echo "unknown")
        log_error "Another instance is running (PID: $other_pid)"
        return 1
    fi
}

remove_lockfile() {
    if [[ -n "$LOCK_FD" ]]; then
        flock -u "$LOCK_FD" 2>/dev/null
        exec {LOCK_FD}>&-
    fi
    
    [[ -f "$LOCK_FILE" ]] && rm -f "$LOCK_FILE"
    log_debug "Lock released"
}

# Cleanup handler for signals
setup_cleanup_handler() {
    trap 'cleanup_on_exit' EXIT
    trap 'cleanup_on_signal SIGINT' SIGINT
    trap 'cleanup_on_signal SIGTERM' SIGTERM
}

cleanup_on_exit() {
    local exit_code=$?
    
    stop_progress
    remove_lockfile
    
    # Delete temporary files
    if [[ -n "${TEMP_DIR:-}" && -d "$TEMP_DIR" ]]; then
        rm -rf "$TEMP_DIR"
    fi
    
    exit $exit_code
}

cleanup_on_signal() {
    local signal="$1"
    log_warning "Received signal $signal, stopping..."
    exit 130
}
```

---

## 5. Configuration Module - backup_config.sh

### 5.1 Configuration Structure

```bash
# Global variables for configuration
declare -A CONFIG
declare -g CONFIG_FILE=""

# Default values
set_defaults() {
    # Destination and prefix
    CONFIG[backup_destination]="/var/backups"
    CONFIG[backup_prefix]="backup"
    
    # Compression
    CONFIG[compression]="gzip"
    CONFIG[compression_level]="6"
    
    # Rotation
    CONFIG[rotation_enabled]="true"
    CONFIG[rotation_daily]="7"
    CONFIG[rotation_weekly]="4"
    CONFIG[rotation_monthly]="12"
    
    # Verification
    CONFIG[checksum_algorithm]="sha256"
    CONFIG[verify_after_backup]="true"
    
    # Exclusions
    CONFIG[exclude_patterns]="*.tmp,*.log,*.cache,node_modules,__pycache__"
    
    # Logging
    CONFIG[log_level]="INFO"
    CONFIG[log_file]="/var/log/backup.log"
    
    # Options
    CONFIG[verbose]="false"
    CONFIG[dry_run]="false"
    CONFIG[force]="false"
    
    # Hooks
    CONFIG[pre_backup_hook]=""
    CONFIG[post_backup_hook]=""
    CONFIG[on_error_hook]=""
}
```

### 5.2 Loading and Parsing

```bash
load_config() {
    local config_file="${1:-}"
    
    # Set default values first
    set_defaults
    
    # Search for configuration file
    local search_paths=(
        "$config_file"
        "${HOME}/.config/backup/backup.conf"
        "${HOME}/.backup.conf"
        "/etc/backup/backup.conf"
        "${SCRIPT_DIR}/config/backup.conf"
    )
    
    for path in "${search_paths[@]}"; do
        [[ -z "$path" ]] && continue
        
        if [[ -f "$path" && -r "$path" ]]; then
            CONFIG_FILE="$path"
            log_info "Loading configuration: $CONFIG_FILE"
            break
        fi
    done
    
    # Parse file if it exists
    if [[ -n "$CONFIG_FILE" ]]; then
        parse_config_file "$CONFIG_FILE"
    else
        log_warning "No configuration file found, using default values"
    fi
    
    # Validate configuration
    validate_config
}

parse_config_file() {
    local file="$1"
    local line_num=0
    local current_section=""
    
    while IFS= read -r line || [[ -n "$line" ]]; do
        ((line_num++))
        
        # Remove whitespace
        line="${line#"${line%%[![:space:]]*}"}"
        line="${line%"${line##*[![:space:]]}"}"
        
        # Ignore empty lines and comments
        [[ -z "$line" || "$line" =~ ^[#\;] ]] && continue
        
        # Detect sections [section]
        if [[ "$line" =~ ^\[([^\]]+)\]$ ]]; then
            current_section="${BASH_REMATCH[1]}"
            continue
        fi
        
        # Parse key=value
        if [[ "$line" =~ ^([a-zA-Z_][a-zA-Z0-9_]*)=(.*)$ ]]; then
            local key="${BASH_REMATCH[1]}"
            local value="${BASH_REMATCH[2]}"
            
            # Add section prefix if exists
            if [[ -n "$current_section" ]]; then
                key="${current_section}_${key}"
            fi
            
            # Remove quotes
            value="${value#[\"\']}"
            value="${value%[\"\']}"
            
            # Expand variables
            value=$(eval echo "$value" 2>/dev/null) || value="${BASH_REMATCH[2]}"
            
            CONFIG["$key"]="$value"
            log_debug "Config: $key = $value"
        else
            log_warning "Line $line_num: invalid format: $line"
        fi
    done < "$file"
}

validate_config() {
    local errors=0
    
    # Validate compression
    local compression="${CONFIG[compression]}"
    case "$compression" in
        none|gzip|bzip2|xz|zstd) ;;
        *)
            log_error "Invalid compression: $compression"
            ((errors++))
            ;;
    esac
    
    # Validate compression level
    local level="${CONFIG[compression_level]}"
    if ! [[ "$level" =~ ^[0-9]$ ]]; then
        log_error "Invalid compression level: $level (must be 0-9)"
        ((errors++))
    fi
    
    # Validate checksum algorithm
    local algorithm="${CONFIG[checksum_algorithm]}"
    case "$algorithm" in
        md5|sha1|sha256|sha512) ;;
        *)
            log_error "Invalid checksum algorithm: $algorithm"
            ((errors++))
            ;;
    esac
    
    # Validate rotation
    for key in rotation_daily rotation_weekly rotation_monthly; do
        local val="${CONFIG[$key]}"
        if ! [[ "$val" =~ ^[0-9]+$ ]]; then
            log_error "Invalid $key: $val"
            ((errors++))
        fi
    done
    
    return $((errors > 0 ? 1 : 0))
}

# Configuration access
get_config() {
    local key="$1"
    local default="${2:-}"
    
    if [[ -n "${CONFIG[$key]+isset}" ]]; then
        echo "${CONFIG[$key]}"
    else
        echo "$default"
    fi
}

set_config() {
    local key="$1"
    local value="$2"
    CONFIG["$key"]="$value"
}
```

---

## 6. Main Script - backup.sh

### 6.1 General Structure

```bash
#!/usr/bin/env bash
#
# backup.sh - Enterprise Backup Solution
# CAPSTONE Project - Operating Systems
#

set -o errexit
set -o nounset
set -o pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"
readonly VERSION="1.0.0"

readonly LIB_DIR="${SCRIPT_DIR}/lib"
readonly CONFIG_DIR="${SCRIPT_DIR}/config"

# Load modules
source "${LIB_DIR}/backup_utils.sh"
source "${LIB_DIR}/backup_config.sh"
source "${LIB_DIR}/backup_core.sh"

# Setup cleanup
setup_cleanup_handler
```

### 6.2 Argument Parsing

```bash
# Variables for arguments
declare -g ACTION=""
declare -a SOURCES=()
declare -g DESTINATION=""
declare -g BACKUP_TYPE="full"
declare -g ARCHIVE_PATH=""
declare -g RESTORE_PATH=""
declare -a RESTORE_FILES=()

show_help() {
    cat <<EOF
Usage: $SCRIPT_NAME <action> [options] [sources...]

Actions:
  backup       Create a new backup
  restore      Restore from a backup
  verify       Verify backup integrity
  list         List existing backups
  rotate       Manually apply rotation policy

General options:
  -h, --help                Display this message
  -V, --version             Display version
  -c, --config FILE         Use specific configuration file
  -v, --verbose             Verbose mode
  -n, --dry-run             Simulation without changes
  -f, --force               Force operation

Backup options:
  -d, --destination DIR     Destination directory for backup
  -t, --type TYPE           Backup type: full, incremental (default: full)
  -z, --compression ALG     Compression: none, gzip, bzip2, xz, zstd
  -e, --exclude PATTERN     Exclusion pattern (can be repeated)
  --no-checksum             Don't generate checksum
  --no-verify               Don't verify after backup

Restore options:
  -a, --archive FILE        Archive to restore
  -o, --output DIR          Restoration directory (default: .)
  --files FILE [FILE...]    Specific files to restore

List options:
  --format FORMAT           Format: human, json, csv (default: human)
  --latest                  Show only the most recent backup

Examples:
  $SCRIPT_NAME backup -d /backups /home /etc
  $SCRIPT_NAME backup -t incremental -d /backups /home
  $SCRIPT_NAME restore -a /backups/backup_full_20240115.tar.gz -o /tmp/restore
  $SCRIPT_NAME restore -a backup.tar.gz --files home/user/docs
  $SCRIPT_NAME verify -a /backups/backup_full_20240115.tar.gz
  $SCRIPT_NAME list -d /backups --format json

EOF
}

parse_arguments() {
    [[ $# -eq 0 ]] && { show_help; exit 0; }
    
    # First argument is the action
    ACTION="$1"
    shift
    
    case "$ACTION" in
        backup|restore|verify|list|rotate|help)
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        -V|--version)
            echo "$SCRIPT_NAME version $VERSION"
            exit 0
            ;;
        *)
            log_error "Unknown action: $ACTION"
            show_help
            exit 1
            ;;
    esac
    
    # Parse remaining arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                show_help
                exit 0
                ;;
            -c|--config)
                CONFIG_FILE="$2"
                shift 2
                ;;
            -d|--destination)
                DESTINATION="$2"
                shift 2
                ;;
            -t|--type)
                BACKUP_TYPE="$2"
                shift 2
                ;;
            -z|--compression)
                set_config "compression" "$2"
                shift 2
                ;;
            -e|--exclude)
                local current
                current=$(get_config "exclude_patterns" "")
                set_config "exclude_patterns" "${current:+$current,}$2"
                shift 2
                ;;
            -a|--archive)
                ARCHIVE_PATH="$2"
                shift 2
                ;;
            -o|--output)
                RESTORE_PATH="$2"
                shift 2
                ;;
            -v|--verbose)
                set_config "verbose" "true"
                LOG_LEVEL="DEBUG"
                shift
                ;;
            -n|--dry-run)
                set_config "dry_run" "true"
                shift
                ;;
            -f|--force)
                set_config "force" "true"
                shift
                ;;
            --no-checksum)
                set_config "generate_checksum" "false"
                shift
                ;;
            --no-verify)
                set_config "verify_after_backup" "false"
                shift
                ;;
            --files)
                shift
                while [[ $# -gt 0 && ! "$1" =~ ^- ]]; do
                    RESTORE_FILES+=("$1")
                    shift
                done
                ;;
            --format)
                set_config "output_format" "$2"
                shift 2
                ;;
            --latest)
                set_config "show_latest_only" "true"
                shift
                ;;
            -*)
                log_error "Unknown option: $1"
                exit 1
                ;;
            *)
                # Positional arguments are sources for backup
                SOURCES+=("$1")
                shift
                ;;
        esac
    done
}
```

### 6.3 Action Execution

```bash
execute_action() {
    case "$ACTION" in
        backup)
            do_backup
            ;;
        restore)
            do_restore
            ;;
        verify)
            do_verify
            ;;
        list)
            do_list
            ;;
        rotate)
            do_rotate
            ;;
        help)
            show_help
            ;;
    esac
}

do_backup() {
    # Validations
    if [[ ${#SOURCES[@]} -eq 0 ]]; then
        # Try to get sources from configuration
        local config_sources
        config_sources=$(get_config "backup_sources" "")
        
        if [[ -n "$config_sources" ]]; then
            IFS=',' read -ra SOURCES <<< "$config_sources"
        else
            log_error "No sources specified for backup!"
            exit 1
        fi
    fi
    
    # Verify sources exist
    for src in "${SOURCES[@]}"; do
        if [[ ! -e "$src" ]]; then
            log_error "Source does not exist: $src"
            exit 1
        fi
    done
    
    # Destination
    if [[ -z "$DESTINATION" ]]; then
        DESTINATION=$(get_config "backup_destination" "/var/backups")
    fi
    
    # Obtain lock
    create_lockfile "backup" || exit 1
    
    # Execute pre-hook
    local pre_hook
    pre_hook=$(get_config "pre_backup_hook" "")
    if [[ -n "$pre_hook" && -x "$pre_hook" ]]; then
        log_info "Executing pre-backup hook: $pre_hook"
        "$pre_hook" || {
            log_error "Pre-backup hook failed!"
            exit 1
        }
    fi
    
    # Dry run?
    if [[ "$(get_config 'dry_run' 'false')" == "true" ]]; then
        log_info "[DRY RUN] Would create backup:"
        log_info "  Type: $BACKUP_TYPE"
        log_info "  Sources: ${SOURCES[*]}"
        log_info "  Destination: $DESTINATION"
        log_info "  Compression: $(get_config 'compression' 'gzip')"
        exit 0
    fi
    
    # Create the backup
    local result
    result=$(create_archive "$BACKUP_TYPE" "$DESTINATION" "${SOURCES[@]}")
    local exit_code=$?
    
    if [[ $exit_code -eq 0 ]]; then
        # Execute post-hook
        local post_hook
        post_hook=$(get_config "post_backup_hook" "")
        if [[ -n "$post_hook" && -x "$post_hook" ]]; then
            export BACKUP_FILE="$result"
            log_info "Executing post-backup hook: $post_hook"
            "$post_hook" || log_warning "Post-backup hook failed"
        fi
        
        log_info "Backup created successfully: $result"
    else
        # Execute error hook
        local error_hook
        error_hook=$(get_config "on_error_hook" "")
        if [[ -n "$error_hook" && -x "$error_hook" ]]; then
            log_info "Executing error hook: $error_hook"
            "$error_hook" || true
        fi
        
        log_error "Backup failed!"
        exit 1
    fi
}

do_restore() {
    if [[ -z "$ARCHIVE_PATH" ]]; then
        log_error "Archive must be specified with -a/--archive"
        exit 1
    fi
    
    if [[ ! -f "$ARCHIVE_PATH" ]]; then
        log_error "Archive does not exist: $ARCHIVE_PATH"
        exit 1
    fi
    
    [[ -z "$RESTORE_PATH" ]] && RESTORE_PATH="."
    
    log_info "Restoring from: $ARCHIVE_PATH"
    log_info "To: $RESTORE_PATH"
    
    if [[ ${#RESTORE_FILES[@]} -gt 0 ]]; then
        log_info "Selected files: ${RESTORE_FILES[*]}"
        extract_archive "$ARCHIVE_PATH" "$RESTORE_PATH" "${RESTORE_FILES[@]}"
    else
        extract_archive "$ARCHIVE_PATH" "$RESTORE_PATH"
    fi
}

do_verify() {
    if [[ -z "$ARCHIVE_PATH" ]]; then
        log_error "Archive must be specified with -a/--archive"
        exit 1
    fi
    
    verify_archive "$ARCHIVE_PATH"
}

do_list() {
    local backup_dir
    backup_dir="${DESTINATION:-$(get_config 'backup_destination' '/var/backups')}"
    
    if [[ ! -d "$backup_dir" ]]; then
        log_error "Directory does not exist: $backup_dir"
        exit 1
    fi
    
    local format
    format=$(get_config "output_format" "human")
    
    list_backups "$backup_dir" "$format"
}

list_backups() {
    local dir="$1"
    local format="${2:-human}"
    
    case "$format" in
        json)
            echo "{"
            echo "  \"backups\": ["
            local first=true
            ;;
        csv)
            echo "filename,type,date,size,compression"
            ;;
        *)
            echo "╔════════════════════════════════════════════════════════════════╗"
            echo "║                    Available Backups                            ║"
            echo "╠════════════════════════════════════════════════════════════════╣"
            ;;
    esac
    
    # Search for backups in all subdirectories
    find "$dir" -name "*.tar*" -type f | sort -r | while IFS= read -r archive; do
        local name type date_str size compression
        
        name=$(basename "$archive")
        size=$(stat -c %s "$archive" 2>/dev/null || echo "0")
        
        # Extract type and date from name
        if [[ "$name" =~ _([a-z]+)_([0-9]{8}_[0-9]{6})\. ]]; then
            type="${BASH_REMATCH[1]}"
            date_str="${BASH_REMATCH[2]}"
        else
            type="unknown"
            date_str="unknown"
        fi
        
        # Detect compression
        case "$name" in
            *.gz)  compression="gzip" ;;
            *.bz2) compression="bzip2" ;;
            *.xz)  compression="xz" ;;
            *.zst) compression="zstd" ;;
            *)     compression="none" ;;
        esac
        
        case "$format" in
            json)
                $first || echo ","
                first=false
                printf '    {"name": "%s", "type": "%s", "date": "%s", "size": %d, "compression": "%s"}' \
                    "$name" "$type" "$date_str" "$size" "$compression"
                ;;
            csv)
                echo "$name,$type,$date_str,$size,$compression"
                ;;
            *)
                printf "║ %-60s ║\n" "$name"
                printf "║   Type: %-10s Size: %-15s Compression: %-10s ║\n" \
                    "$type" "$(format_bytes $size)" "$compression"
                ;;
        esac
    done
    
    case "$format" in
        json)
            echo ""
            echo "  ]"
            echo "}"
            ;;
        human)
            echo "╚════════════════════════════════════════════════════════════════╝"
            ;;
    esac
}

do_rotate() {
    local backup_dir
    backup_dir="${DESTINATION:-$(get_config 'backup_destination' '/var/backups')}"
    
    log_info "Applying manual rotation in: $backup_dir"
    apply_rotation "$backup_dir"
}
```

### 6.4 The Main Function

```bash
main() {
    # Parse arguments
    parse_arguments "$@"
    
    # Load configuration
    load_config "${CONFIG_FILE:-}"
    
    # Set log file
    LOG_FILE=$(get_config "log_file" "/var/log/backup.log")
    
    # Execute action
    execute_action
}

# Run main
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
```

---

## 7. Backup Strategies

### 7.1 Full vs Incremental Backup

```
┌─────────────────────────────────────────────────────────────────────────┐
│                     FULL BACKUP                                          │
│                                                                          │
│   [Complete Sources] ────────────────────────────▶ [Complete Archive]   │
│                                                                          │
│   Advantages:                    Disadvantages:                          │
│   + Simple restoration           - Long time                             │
│   + Single file                  - Large space                           │
│   + Independent                  - High bandwidth                        │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────┐
│                   INCREMENTAL BACKUP                                     │
│                                                                          │
│   Monday:    [FULL] ─────────────────────────────▶ [Full Backup]        │
│   Tuesday:   [Changes Mon→Tue] ──────────────────▶ [Incr1]             │
│   Wednesday: [Changes Tue→Wed] ──────────────────▶ [Incr2]             │
│   ...                                                                    │
│                                                                          │
│   Restore: [Full] + [Incr1] + [Incr2] + ... = [Current State]          │
│                                                                          │
│   Advantages:                    Disadvantages:                          │
│   + Fast                         - Complex restoration                   │
│   + Reduced space                - Depends on chain                      │
│   + Bandwidth efficient          - Corruption risk                       │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

### 7.2 The 3-2-1 Strategy

```
┌─────────────────────────────────────────────────────────────────────────┐
│                      THE 3-2-1 RULE                                      │
│                                                                          │
│   3 ─ Three copies of data                                              │
│       ┌──────────┐  ┌──────────┐  ┌──────────┐                          │
│       │ Original │  │ Backup 1 │  │ Backup 2 │                          │
│       └──────────┘  └──────────┘  └──────────┘                          │
│                                                                          │
│   2 ─ On two different types of media                                   │
│       ┌──────────┐  ┌──────────┐                                        │
│       │   SSD    │  │   HDD    │  or NAS, Cloud, Tape                   │
│       └──────────┘  └──────────┘                                        │
│                                                                          │
│   1 ─ One in an off-site location                                       │
│       ┌──────────────────────────────────────┐                          │
│       │  Cloud Storage / Remote Server       │                          │
│       └──────────────────────────────────────┘                          │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

### 7.3 Compression Algorithm Comparison

| Algorithm | Compression Speed | Compression Ratio | CPU Usage | Decompression |
|-----------|-------------------|-------------------|-----------|---------------|
| none      | N/A               | 1:1               | 0%        | N/A           |
| gzip      | Fast              | ~60%              | Medium    | Fast          |
| bzip2     | Medium            | ~65%              | High      | Medium        |
| xz        | Slow              | ~70%              | V. High   | Fast          |
| zstd      | V. Fast           | ~65%              | Medium    | V. Fast       |

---

## 8. Verification and Restoration

### 8.1 Multi-Level Verification

```bash
# Level 1: Archive structure verification
verify_structure() {
    local archive="$1"
    
    tar --test-label -f "$archive" 2>/dev/null
}

# Level 2: Checksum verification
verify_integrity() {
    local archive="$1"
    
    verify_checksum "$archive"
}

# Level 3: Content verification (extract and compare)
verify_content() {
    local archive="$1"
    local original_dir="$2"
    
    local temp_dir
    temp_dir=$(mktemp -d)
    
    # Extract to temporary directory
    extract_archive "$archive" "$temp_dir"
    
    # Compare with original
    diff -rq "$original_dir" "$temp_dir" > /dev/null 2>&1
    local result=$?
    
    rm -rf "$temp_dir"
    return $result
}
```

### 8.2 Point-in-Time Restoration

```bash
restore_to_point_in_time() {
    local backup_dir="$1"
    local destination="$2"
    local target_datetime="$3"  # Format: YYYYMMDD_HHMMSS
    
    log_info "Restoring to point: $target_datetime"
    
    # Find the last full backup before target
    local full_backup=""
    while IFS= read -r backup; do
        if [[ "$backup" =~ _([0-9]{8}_[0-9]{6})\. ]]; then
            local backup_time="${BASH_REMATCH[1]}"
            if [[ "$backup_time" < "$target_datetime" || "$backup_time" == "$target_datetime" ]]; then
                full_backup="$backup"
                break
            fi
        fi
    done < <(find "$backup_dir" -name "*_full_*.tar*" | sort -r)
    
    if [[ -z "$full_backup" ]]; then
        log_error "No full backup found before $target_datetime"
        return 1
    fi
    
    # Restore full backup
    log_info "Restoring full: $(basename "$full_backup")"
    extract_archive "$full_backup" "$destination"
    
    # Apply incrementals up to target
    while IFS= read -r incr_backup; do
        if [[ "$incr_backup" =~ _([0-9]{8}_[0-9]{6})\. ]]; then
            local incr_time="${BASH_REMATCH[1]}"
            
            # Verify it's between full and target
            if [[ "$incr_time" > "${full_backup##*_full_}" ]] && \
               [[ "$incr_time" < "$target_datetime" || "$incr_time" == "$target_datetime" ]]; then
                log_info "Applying incremental: $(basename "$incr_backup")"
                extract_archive "$incr_backup" "$destination"
            fi
        fi
    done < <(find "$backup_dir" -name "*_incr_*.tar*" | sort)
    
    log_info "Restoration completed to point $target_datetime"
}
```

---

## 9. Implementation Exercises

### Exercise 1: Encrypted Backup

```bash
# Implement backup with GPG/OpenSSL encryption
create_encrypted_backup() {
    local archive="$1"
    local passphrase="${2:-}"
    
    # TODO: Implement:
    # 1. Create normal backup
    # 2. Encrypt with openssl or gpg
    # 3. Generate checksum for encrypted file
    # 4. Implement restoration with decryption
    :
}
```

### Exercise 2: Remote Backup

```bash
# Implement backup to remote server via SSH/rsync
remote_backup() {
    local sources=("$@")
    local remote_host="backup-server.example.com"
    local remote_path="/backups"
    
    # TODO: Implement:
    # 1. Create local archive
    # 2. Transfer with rsync --progress
    # 3. Verify transfer (remote checksum)
    # 4. Cleanup local archive (optional)
    :
}
```

### Exercise 3: Notifications

```bash
# Implement notification system
send_notification() {
    local type="$1"      # success, warning, error
    local message="$2"
    local method="$3"    # email, slack, telegram
    
    # TODO: Implement:
    # 1. Format message based on type
    # 2. Send via specified method
    # 3. Log notification
    :
}
```

### Exercise 4: Backup Scheduling

```bash
# Generate crontab configuration
generate_cron_config() {
    local backup_script="$1"
    local schedule_type="${2:-daily}"  # daily, weekly, monthly
    
    # TODO: Implement:
    # 1. Generate correct crontab line
    # 2. Set environment variables
    # 3. Redirect output to log
    # 4. Support for each schedule type
    :
}
```

### Exercise 5: Dashboard and Reporting

```bash
# Generate HTML report for backups
generate_report() {
    local backup_dir="$1"
    local output_file="$2"
    
    # TODO: Implement:
    # 1. Collect statistics (backup count, sizes, successes/failures)
    # 2. Generate graphs (using ASCII or SVG)
    # 3. Export HTML with inline CSS
    # 4. Timeline of recent backups
    :
}
```

---

## Conclusions

The Backup project demonstrates the implementation of an enterprise-grade backup system using Bash. Key points:

1. **Flexibility** - support for multiple backup types and compression
2. **Integrity** - multi-level verification with checksums
3. **Automation** - automatic rotation and hooks for integration
4. **Stability** - error handling and reliable restoration
5. **Extensibility** - modular architecture for future extensions

The system can be extended for:
- Cloud backup (S3, Azure Blob, GCS) — and related to that, block-level deduplication
- End-to-end encryption
- Web interface for management
- Integration with alerting systems
