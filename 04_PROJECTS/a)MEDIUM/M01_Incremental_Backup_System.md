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

```text
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

These are synthetic illustrations, not measured runs or acceptance evidence.

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

### Chain contract for the implementation hints

The helpers below are scaffolding, not a completed backup application. The mtime
list is an observation of changed regular files, not a complete incremental format:
it cannot by itself represent deletion, rename, metadata changes or a consistent
snapshot of a changing source. Use one root-relative member namespace (`.`).

For a GNU tar implementation, create the full base and every delta with
`--listed-incremental=SNAPSHOT`. Copy the current snapshot to an owned staged file,
create and verify the archive, write its checksum and a manifest containing the
parent ID, source root, compression, snapshot version and archive name, then
publish the archive and advance the snapshot only after all steps succeed. Hold
an exclusive `flock` on one persistent inode throughout; never unlink that lock.
A changed source/exclusion set starts a new full chain. A filesystem snapshot is
needed if the application requires a point-in-time image of concurrently changing data.

The executable [manifest reference](../reference/backup_manifest.py) supplies
`plan_retention` and `verified_restore_chain` for its documented v1 JSON manifest.
It selects daily/weekly/monthly points and protects their entire ancestor closure,
rejects malformed/cyclic/outside-root parents and verifies hashes and member paths
for the complete chain before emitting any extraction path. A missing verifier is
an error, never an unchecked restore. Adapt the format explicitly if the assignment
contract chooses another storage interface; do not silently mix manifests.

```bash
# Set this to the repository reference, or vendor the module with your implementation.
: "${M01_MANIFEST_HELPER:?Set the path to 04_PROJECTS/reference/backup_manifest.py}"
plan_retention() { python3 "$M01_MANIFEST_HELPER" retention "$@"; }
verified_restore_chain() { python3 "$M01_MANIFEST_HELPER" chain "$@"; }
```

See the executable [SEM06 Backup reference](../../SEM06/scripts/projects/backup/)
and its mutation regressions for full chains, staged snapshot updates and
complete-chain retention. Its CLI/layout is distinct from this assignment;
it does not settle the pending assessment-interface decision.

### Detecting modified files (incremental)

```bash
#!/bin/bash
set -euo pipefail

find_modified_files() {
    local source_dir="$1"
    local reference_file="$2"  # Timestamp file from last backup
    local exclude_file="${3:-}"
    
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
    
    (cd -- "$source_dir" && find . "${find_args[@]}" -print0)
}

# Alternative: using rsync dry-run
find_modified_rsync() {
    local source_dir="$1"
    local last_backup="$2"
    
    # Human-readable comparison only; do not parse this as a filename list.
    rsync -avn --itemize-changes -- "$source_dir/" "$last_backup/"
}
```

### Creating archive with compression

```bash
create_archive() (
    set -euo pipefail
    local source_dir="$1" archive_path="$2" compression="${3:-gzip}"
    local level="${4:-6}" file_list="${5:-}"
    local -a compressor
    local extension
    [[ $level =~ ^[1-9]$ ]] || return 2
    case "$compression" in
        gzip) compressor=(gzip "-$level"); extension=.tar.gz ;;
        bzip2) compressor=(bzip2 "-$level"); extension=.tar.bz2 ;;
        xz) compressor=(xz "-$level"); extension=.tar.xz ;;
        none) compressor=(cat); extension=.tar ;;
        *) echo "Unsupported compression" >&2; return 2 ;;
    esac
    source_dir=$(realpath -- "$source_dir") || return 1
    local final="${archive_path}${extension}" stage
    [[ ! -e "$final" && ! -e "$final.sha256" ]] || return 1
    stage=$(mktemp "${final}.partial.XXXXXX") || return 1
    trap 'rm -f -- "$stage" "$stage.sha256"' EXIT
    local -a args=(-C "$source_dir" --create --file=-)
    if [[ -n "$file_list" ]]; then
        [[ -r "$file_list" ]] || return 1
        args+=(--null --verbatim-files-from --files-from="$file_list")
    else
        args+=(.)
    fi
    tar "${args[@]}" | "${compressor[@]}" > "$stage" || return 1
    tar -tf "$stage" >/dev/null || return 1
    # Metadata publication is guarded; callers also hold a backup-set lock.
    local digest
    digest=$(sha256sum < "$stage") || return 1
    digest=${digest%% *}
    printf '%s  %s\n' "$digest" "${final##*/}" > "$stage.sha256"
    mv -- "$stage.sha256" "$final.sha256" || return 1
    mv -- "$stage" "$final" || { rm -f -- "$final.sha256"; return 1; }
    printf '%s\n' "$final"
)
```

### Rotation policy

```bash
apply_retention_policy() {
    local backup_dir="$1" keep_daily="${2:-7}" keep_weekly="${3:-4}" keep_monthly="${4:-3}"
    [[ $keep_daily =~ ^[0-9]+$ && $keep_weekly =~ ^[0-9]+$ && $keep_monthly =~ ^[0-9]+$ ]] || return 2
    # The reference graph planner outputs a NUL-delimited deletion plan only
    # after validating every manifest and retaining the transitive parent closure.
    # The active incremental tip and every required ancestor are always protected.
    local plan
    plan=$(mktemp) || return 1
    if ! plan_retention "$backup_dir" "$keep_daily" "$keep_weekly" "$keep_monthly" > "$plan"; then
        rm -f -- "$plan"; return 1
    fi
    local candidate
    while IFS= read -r -d '' candidate; do
        [[ $candidate =~ ^backup_[0-9]{8}_[0-9]{6}(_[A-Za-z0-9]+)?$ ]] || { rm -f -- "$plan"; return 1; }
        [[ -d "$backup_dir/$candidate" && ! -L "$backup_dir/$candidate" ]] || { rm -f -- "$plan"; return 1; }
    done < "$plan"
    # Apply the validated plan under the same exclusive backup-set lock.
    while IFS= read -r -d '' candidate; do
        rm -rf -- "$backup_dir/$candidate" || { rm -f -- "$plan"; return 1; }
    done < "$plan"
    rm -f -- "$plan"
}
```

### Restore from archive

```bash
restore_backup() {
    local backup_id="$1" output_dir="$2" specific_file="${3:-}"
    [[ $backup_id =~ ^backup_[0-9]{8}_[0-9]{6}(_[A-Za-z0-9]+)?$ ]] || return 2
    [[ ! -e "$output_dir" ]] || { echo "Restore requires a fresh destination" >&2; return 1; }
    # The reference manifest parser resolves and validates a cycle-free chain,
    # oldest full base first, including every checksum, algorithm and root convention.
    local chain
    chain=$(mktemp) || return 1
    if ! verified_restore_chain "$BACKUP_DIR" "$backup_id" > "$chain"; then
        rm -f -- "$chain"; return 1
    fi
    local stage archive
    stage=$(mktemp -d "${output_dir}.partial.XXXXXX") || { rm -f -- "$chain"; return 1; }
    while IFS= read -r -d '' archive; do
        # GNU listed-incremental metadata carries deletions as well as additions.
        if ! tar --extract --listed-incremental=/dev/null --file="$archive" --directory="$stage"; then
            rm -rf -- "$stage"; rm -f -- "$chain"; return 1
        fi
    done < "$chain"
    rm -f -- "$chain"
    if [[ -n "$specific_file" ]]; then
        # First materialise historical state, then select; never extract one delta alone.
        case "$specific_file" in /*|../*|*/../*|*/..) rm -rf -- "$stage"; return 2;; esac
        [[ -e "$stage/$specific_file" ]] || { rm -rf -- "$stage"; return 1; }
        mkdir -p -- "$output_dir/$(dirname -- "$specific_file")" || { rm -rf -- "$stage"; return 1; }
        cp -a -- "$stage/$specific_file" "$output_dir/$specific_file" || { rm -rf -- "$stage"; return 1; }
        rm -rf -- "$stage"
    else
        mv -- "$stage" "$output_dir" || { rm -rf -- "$stage"; return 1; }
    fi
    printf 'Restored to: %s\n' "$output_dir"
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
