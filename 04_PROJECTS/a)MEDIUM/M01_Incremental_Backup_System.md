# M01: Incremental Backup System

> **Level:** MEDIUM | **Estimated time:** 25-35 hours | **K8s Bonus:** +10%

---

## Description

Complete incremental backup system with support for compression, optional encryption, automatic rotation and selective restore. The project implements incremental backup strategies using timestamps or rsync-style checksums, with integrated scheduling and completion notifications.

The system must efficiently manage storage space through deduplication and provide a clear interface for backup and restore operations, including for individual files from old archives.

---

## Learning Objectives

- Incremental backup algorithms (timestamp vs checksum)
- Compression and archiving (tar, gzip, bzip2, xz)
- Symmetric encryption with GPG/OpenSSL
- Backup rotation and retention
- Integration with cron/systemd for scheduling
- Integrity verification with checksums

---

## Functional Requirements

### Mandatory (for passing grade)

1. **Incremental backup**
   - Identify files modified since last backup
   - Method based on mtime or checksum
   - Efficient storage of differences only

2. **Full backup**
   - Periodic snapshot (configurable: daily, weekly)
   - Complete archiving of source
   - Base for subsequent incremental backups

3. **Compression**
   - Support for gzip, bzip2, xz
   - Configurable compression level
   - Size estimation before backup

4. **Automatic rotation**
   - Keep N backups (configurable)
   - Automatic deletion of oldest
   - Policies: daily, weekly, monthly retention

5. **Restore**
   - Complete restore from any point
   - Selective restore (individual files/directories)
   - Restore to alternative location

6. **Scheduling**
   - Automatic cron job generation
   - Support for systemd timers
   - Check and list existing schedule

7. **Logging**
   - Detailed journal for each operation
   - Statistics: files processed, sizes, duration
   - Log rotation

8. **Integrity verification**
   - Checksum for each archive
   - Verification on restore
   - Corruption report if any

### Optional (for full marks)

9. **Encryption** - GPG or OpenSSL for sensitive backups
10. **Remote backup** - SCP/SFTP/rsync transfer to remote destination
11. **Notifications** - Email or webhook on success/failure
12. **Deduplication** - Hard links for identical files between backups
13. **Exclusions** - Patterns to ignore (*.tmp, .cache, etc.)
14. **Bandwidth limiting** - For remote backup
15. **Dry-run** - Simulation without performing actual backup

---

## CLI Interface

```bash
./backup.sh <command> [options]

Commands:
  full                    Full backup (snapshot)
  incremental             Incremental backup (changes only)
  restore <backup_id>     Restore from specified backup
  list                    List available backups
  verify <backup_id>      Verify backup integrity
  prune                   Clean backups according to policy
  schedule [on|off|show]  Manage scheduling
  status                  System status and statistics

General options:
  -s, --source DIR        Source directory (required for backup)
  -d, --dest DIR          Backup destination directory
  -c, --config FILE       Configuration file (default: ~/.backup.conf)
  -n, --name NAME         Backup set name
  -v, --verbose           Detailed output
  -q, --quiet             Errors only
  --dry-run               Simulation without actual action

Backup options:
  -z, --compress ALG      Algorithm: none|gzip|bzip2|xz (default: gzip)
  -l, --level N           Compression level 1-9 (default: 6)
  -e, --encrypt           Enable GPG encryption
  -x, --exclude PATTERN   Exclude files (can be repeated)
  --exclude-from FILE     File with exclusion patterns

Restore options:
  -o, --output DIR        Restore destination directory
  -f, --file PATH         Restore only specific file/directory
  --overwrite             Overwrite existing files

Rotation options:
  --keep-daily N          Keep N daily backups
  --keep-weekly N         Keep N weekly backups
  --keep-monthly N        Keep N monthly backups

Examples:
  ./backup.sh full -s /home/user -d /backup -n user_home
  ./backup.sh incremental -s /etc -d /backup/etc --encrypt
  ./backup.sh list
  ./backup.sh restore backup_20250120_153000 -o /tmp/restore
  ./backup.sh restore backup_20250120_153000 -f etc/nginx/nginx.conf
  ./backup.sh verify backup_20250120_153000
  ./backup.sh prune --keep-daily 7 --keep-weekly 4
  ./backup.sh schedule on --cron "0 3 * * *"
```

---

## Output Examples

### Full Backup

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                         BACKUP SYSTEM v1.0                                   ║
║                         Full Backup Started                                  ║
╚══════════════════════════════════════════════════════════════════════════════╝

Configuration:
  Source:      /home/student/projects
  Destination: /backup/projects
  Backup name: projects_full
  Compression: gzip (level 6)
  Encryption:  disabled

Scanning source directory...
  Files found:     2,456
  Directories:     128
  Total size:      1.2 GB
  Excluded:        45 files (matching *.tmp, .cache/*)

Creating archive...
  [████████████████████████████████████████████████████████████] 100%

BACKUP SUMMARY
═══════════════════════════════════════════════════════════════════════════════
  Backup ID:       backup_20250120_153000_full
  Archive:         projects_full_20250120_153000.tar.gz
  Original size:   1.2 GB
  Compressed:      342 MB (compression ratio: 72%)
  Files backed up: 2,411
  Duration:        2m 34s
  Checksum:        sha256:a1b2c3d4e5f6...

  Location: /backup/projects/backup_20250120_153000_full/

✓ Backup completed successfully
  Next incremental will use this as base
```

### Incremental Backup

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                         INCREMENTAL BACKUP                                   ║
║                         Base: backup_20250120_153000_full                    ║
╚══════════════════════════════════════════════════════════════════════════════╝

Comparing with base backup...
  Files scanned:   2,456
  Modified:        45
  New:             12
  Deleted:         3
  Unchanged:       2,396

Creating incremental archive...
  [████████████████████████████████████████████████████████████] 100%

BACKUP SUMMARY
═══════════════════════════════════════════════════════════════════════════════
  Backup ID:       backup_20250121_030000_incr
  Type:            Incremental
  Base backup:     backup_20250120_153000_full
  Changes:         57 files (45 modified, 12 new)
  Archive size:    8.2 MB
  Duration:        12s

✓ Incremental backup completed
```

### Backup Listing

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                         AVAILABLE BACKUPS                                    ║
║                         Set: projects                                        ║
╚══════════════════════════════════════════════════════════════════════════════╝

ID                              Type    Date                 Size      Status
─────────────────────────────────────────────────────────────────────────────────
backup_20250120_153000_full     FULL    2025-01-20 15:30    342 MB    ✓ verified
backup_20250121_030000_incr     INCR    2025-01-21 03:00    8.2 MB    ✓ verified
backup_20250122_030000_incr     INCR    2025-01-22 03:00    5.1 MB    ✓ verified
backup_20250123_030000_incr     INCR    2025-01-23 03:00    12 MB     ✓ verified
backup_20250124_030000_incr     INCR    2025-01-24 03:00    3.4 MB    ⚠ not verified
backup_20250125_153000_full     FULL    2025-01-25 15:30    356 MB    ✓ verified

Total: 6 backups (2 full, 4 incremental)
Storage used: 726.7 MB
Retention policy: 7 daily, 4 weekly, 3 monthly

Commands:
  Restore latest: ./backup.sh restore backup_20250125_153000_full
  Verify all:     ./backup.sh verify --all
```

### Selective Restore

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                         SELECTIVE RESTORE                                    ║
║                         From: backup_20250120_153000_full                    ║
╚══════════════════════════════════════════════════════════════════════════════╝

Searching for: etc/nginx/nginx.conf

Found in archive:
  Path:     etc/nginx/nginx.conf
  Size:     2.3 KB
  Modified: 2025-01-20 14:25:00
  Mode:     644

Extracting to: /tmp/restore/etc/nginx/nginx.conf
  [████████████████████████████████████████████████████████████] 100%

✓ File restored successfully
  Location: /tmp/restore/etc/nginx/nginx.conf
  Checksum verified: ✓
```

---

## Configuration File

```bash
# ~/.backup.conf - Backup System Configuration

# === General Settings ===
BACKUP_NAME="my_backup"
SOURCE_DIR="/home/user"
DEST_DIR="/backup"
LOG_FILE="/var/log/backup.log"

# === Compression ===
COMPRESSION="gzip"      # none, gzip, bzip2, xz
COMPRESSION_LEVEL=6     # 1-9

# === Encryption (optional) ===
ENCRYPTION_ENABLED=false
GPG_RECIPIENT="user@example.com"

# === Exclusions ===
EXCLUDE_PATTERNS=(
    "*.tmp"
    "*.swp"
    ".cache/*"
    "node_modules/*"
    ".git/objects/*"
    "*.log"
)

# === Rotation ===
KEEP_DAILY=7
KEEP_WEEKLY=4
KEEP_MONTHLY=3

# === Scheduling ===
SCHEDULE_FULL="0 3 * * 0"           # Sunday at 3:00
SCHEDULE_INCREMENTAL="0 3 * * 1-6"  # Monday-Saturday at 3:00

# === Notifications ===
NOTIFY_EMAIL=""
NOTIFY_ON_SUCCESS=false
NOTIFY_ON_FAILURE=true

# === Remote (optional) ===
REMOTE_ENABLED=false
REMOTE_HOST=""
REMOTE_PATH=""
REMOTE_USER=""
BANDWIDTH_LIMIT=""  # KB/s, empty = unlimited
```

---

## Project Structure

```
M01_Incremental_Backup_System/
├── README.md
├── Makefile
├── src/
│   ├── backup.sh                # Main script
│   └── lib/
│       ├── config.sh            # Configuration parsing
│       ├── archive.sh           # Tar archive creation
│       ├── compress.sh          # Compression functions
│       ├── encrypt.sh           # GPG encryption
│       ├── incremental.sh       # Incremental backup logic
│       ├── restore.sh           # Restore functions
│       ├── rotate.sh            # Rotation and cleanup
│       ├── schedule.sh          # Cron integration
│       ├── verify.sh            # Integrity verification
│       └── notify.sh            # Notifications
├── etc/
│   ├── backup.conf.example
│   └── excludes.default
├── tests/
│   ├── test_archive.sh
│   ├── test_incremental.sh
│   ├── test_restore.sh
│   └── fixtures/
│       └── sample_data/
└── docs/
    ├── INSTALL.md
    └── RETENTION.md
```

---

## Implementation Hints

### Detecting modified files (incremental)

```bash
#!/bin/bash
set -euo pipefail

find_modified_files() {
    local source_dir="$1"
    local reference_file="$2"  # Timestamp file from last backup
    local exclude_file="$3"
    
    local find_args=(-type f)
    
    # Add exclusions
    if [[ -f "$exclude_file" ]]; then
        while IFS= read -r pattern; do
            [[ -z "$pattern" || "$pattern" == \#* ]] && continue
            find_args+=(-not -path "*/$pattern")
        done < "$exclude_file"
    fi
    
    # Find files newer than reference
    if [[ -f "$reference_file" ]]; then
        find_args+=(-newer "$reference_file")
    fi
    
    find "$source_dir" "${find_args[@]}" 2>/dev/null
}

# Alternative: using rsync dry-run
find_modified_rsync() {
    local source_dir="$1"
    local last_backup="$2"
    
    rsync -avn --itemize-changes "$source_dir/" "$last_backup/" 2>/dev/null | \
        grep "^>f" | awk '{print $2}'
}
```

### Creating archive with compression

```bash
create_archive() {
    local source_dir="$1"
    local archive_path="$2"
    local compression="${3:-gzip}"
    local level="${4:-6}"
    local file_list="$5"  # Optional: file list for incremental
    
    local tar_args=(--create --file=-)
    local compress_cmd
    local extension
    
    # Configure compression
    case "$compression" in
        gzip)  compress_cmd="gzip -${level}"; extension=".tar.gz" ;;
        bzip2) compress_cmd="bzip2 -${level}"; extension=".tar.bz2" ;;
        xz)    compress_cmd="xz -${level}"; extension=".tar.xz" ;;
        none)  compress_cmd="cat"; extension=".tar" ;;
        *)     echo "Unknown algorithm: $compression" >&2; return 1 ;;
    esac
    
    # Add file list or directory
    if [[ -n "$file_list" && -f "$file_list" ]]; then
        tar_args+=(--files-from="$file_list")
    else
        tar_args+=(-C "$(dirname "$source_dir")" "$(basename "$source_dir")")
    fi
    
    # Create archive
    tar "${tar_args[@]}" | $compress_cmd > "${archive_path}${extension}"
    
    # Generate checksum
    sha256sum "${archive_path}${extension}" > "${archive_path}${extension}.sha256"
    
    echo "${archive_path}${extension}"
}
```

### Rotation policy

```bash
apply_retention_policy() {
    local backup_dir="$1"
    local keep_daily="${2:-7}"
    local keep_weekly="${3:-4}"
    local keep_monthly="${4:-3}"
    
    local -a to_keep=()
    local -a all_backups=()
    
    # List all backups sorted descending
    mapfile -t all_backups < <(
        find "$backup_dir" -maxdepth 1 -type d -name "backup_*" | sort -r
    )
    
    local daily_count=0 weekly_count=0 monthly_count=0
    local last_week="" last_month=""
    
    for backup in "${all_backups[@]}"; do
        # Extract date from name: backup_YYYYMMDD_HHMMSS
        local date_part
        date_part=$(basename "$backup" | grep -oP '\d{8}')
        local week month
        week=$(date -d "$date_part" +%Y-%W)
        month=$(date -d "$date_part" +%Y-%m)
        
        local keep=false
        
        # Keep dailies
        if ((daily_count < keep_daily)); then
            keep=true
            ((daily_count++))
        fi
        
        # Keep weeklies (one per week)
        if [[ "$week" != "$last_week" ]] && ((weekly_count < keep_weekly)); then
            keep=true
            ((weekly_count++))
            last_week="$week"
        fi
        
        # Keep monthlies (one per month)
        if [[ "$month" != "$last_month" ]] && ((monthly_count < keep_monthly)); then
            keep=true
            ((monthly_count++))
            last_month="$month"
        fi
        
        if $keep; then
            to_keep+=("$backup")
        else
            echo "Deleting old backup: $backup"
            rm -rf "$backup"
        fi
    done
    
    echo "Kept ${#to_keep[@]} backups"
}
```

### Restore from archive

```bash
restore_backup() {
    local backup_id="$1"
    local output_dir="$2"
    local specific_file="${3:-}"
    
    local backup_path="$BACKUP_DIR/$backup_id"
    local archive
    archive=$(find "$backup_path" -name "*.tar.*" | head -1)
    
    [[ -f "$archive" ]] || { echo "Archive not found"; return 1; }
    
    # Verify integrity
    if [[ -f "${archive}.sha256" ]]; then
        echo "Verifying checksum..."
        sha256sum -c "${archive}.sha256" || {
            echo "Checksum verification failed!"
            return 1
        }
    fi
    
    # Determine decompression command
    local decompress_cmd
    case "$archive" in
        *.tar.gz)  decompress_cmd="gzip -d" ;;
        *.tar.bz2) decompress_cmd="bzip2 -d" ;;
        *.tar.xz)  decompress_cmd="xz -d" ;;
        *.tar)     decompress_cmd="cat" ;;
    esac
    
    mkdir -p "$output_dir"
    
    if [[ -n "$specific_file" ]]; then
        # Selective restore
        $decompress_cmd < "$archive" | tar -xf - -C "$output_dir" "$specific_file"
    else
        # Complete restore
        $decompress_cmd < "$archive" | tar -xf - -C "$output_dir"
    fi
    
    echo "Restored to: $output_dir"
}
```

---

## Specific Evaluation Criteria

| Criterion | Weight | Description |
|-----------|--------|-------------|
| Incremental backup | 20% | Correct change detection, efficiency |
| Full backup | 10% | Correct archiving, functional snapshot |
| Compression | 10% | Multiple algorithms, configurable level |
| Rotation | 15% | Daily/weekly/monthly policies |
| Restore | 15% | Complete and selective, verification |
| Scheduling | 10% | Functional cron/systemd |
| Integrity verification | 5% | Checksums, validation |
| Logging | 5% | Complete journal, statistics |
| Code quality + tests | 5% | ShellCheck, modularity |
| Documentation | 5% | Complete README, examples |

---

## Resources

- `man tar`, `man gzip`, `man rsync`
- `man crontab`, `man systemd.timer`
- Seminar 3-4 - Archiving, compression
- Seminar 5 - Scheduling, automation

---

*MEDIUM Project | Operating Systems | ASE-CSIE*
