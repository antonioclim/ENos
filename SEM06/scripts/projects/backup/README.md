# SysBackup - Professional Backup System

## Description

SysBackup is a complete backup system written in Bash, demonstrating advanced
scripting concepts for automating backup operations with support for multiple sources,
configurable compression, automatic rotation and integrity verification.

The project is part of the teaching materials for the Operating Systems course
(ASE Bucharest, CSIE) and illustrates professional shell script development techniques.

## Features

### Core Functionality
- **Multi-source backup**: support for multiple directories and files
- **Flexible compression**: gzip, bzip2, xz, zstd (with auto-detection of availability) — and related to this, **Backup policies**: daily, weekly, monthly with configurable retention
- **Integrity verification**: MD5/SHA1/SHA256 checksum for validation
- **Automatic rotation**: by number or age, with differentiated policy support

### Technical Features
- **Modular architecture**: core/utils/config separation
- **Solid error handling**: validation, retry, automatic cleanup
- **Complete logging**: multi-level with colour output and file
- **Lock files**: prevention of concurrent executions
- **Daemon mode**: scheduled execution with configurable interval

### Advanced Options
- **Exclude patterns**: glob pattern support for exclusions
- **Dry run**: backup simulation without modifications
- **Notifications**: email on success/error
- **Restore**: archive extraction and listing
- **Statistics**: detailed post-backup reporting

## Project Structure

```
backup/
├── backup.sh           # Main script (entry point)
├── bin/
│   └── sysbackup       # Wrapper for system installation
├── etc/
│   └── backup.conf     # Configuration file
├── lib/
│   ├── core.sh         # Fundamental functions (logging, errors, locks)
│   ├── utils.sh        # Backup functions (archiving, rotation, verification)
│   └── config.sh       # Configuration and CLI parsing
├── tests/
│   └── test_backup.sh  # Unit and integration test suite
└── var/
    ├── log/            # Log files
    └── run/            # PID and lock files
```

## Installation

### Requirements
- Bash 4.0+ (automatically verified)
- Standard utilities: tar, gzip, find, date
- Optional: bzip2, xz, zstd (for alternative compression)
- Optional: md5sum/sha1sum/sha256sum (for integrity verification)

### Quick Installation

```bash
# Clone/copy to desired location
cp -r backup/ /opt/sysbackup/

# Configure permissions
chmod +x /opt/sysbackup/backup.sh
chmod +x /opt/sysbackup/bin/sysbackup

# Symbolic link for global access
sudo ln -s /opt/sysbackup/bin/sysbackup /usr/local/bin/sysbackup

# Copy configuration
sudo cp /opt/sysbackup/etc/backup.conf /etc/sysbackup.conf
```

## Usage

### Basic Commands

```bash
# Simple backup (uses default configuration)
./backup.sh

# Backup specific source
./backup.sh -s /home/user/documents

# Backup multiple sources
./backup.sh -s /home/user/documents -s /etc -s /var/www

# Specify destination
./backup.sh -s /home/user -d /mnt/backup

# Specify compression type
./backup.sh -s /home/user -d /mnt/backup --compression xz
```

### Backup Policies

```bash
# Daily backup (default)
./backup.sh -t daily

# Weekly backup (kept longer)
./backup.sh -t weekly

# Monthly backup (long-term archiving)
./backup.sh -t monthly

# Auto-detect type based on current day
./backup.sh -t auto
# Sunday → weekly, First day of month → monthly, Otherwise → daily
```

### Retention Options

```bash
# Keep last 7 daily backups
./backup.sh --retention-daily 7

# Complete retention configuration
./backup.sh --retention-daily 7 --retention-weekly 4 --retention-monthly 12

# Rotation by age (days)
./backup.sh --rotate-by-age --max-age 30
```

### Exclusions

```bash
# Exclude patterns
./backup.sh -s /home/user -x "*.log" -x "*.tmp" -x "cache/"

# Exclude from file
./backup.sh -s /home/user --exclude-file /etc/backup-exclude.txt
```

### Verification and Restore

```bash
# Backup with integrity verification
./backup.sh --verify

# Save checksum
./backup.sh --checksum --checksum-algo sha256

# List archive contents
./backup.sh --list /mnt/backup/backup_daily_20250120_120000.tar.gz

# Complete restore
./backup.sh --restore /mnt/backup/backup_daily_20250120_120000.tar.gz -d /tmp/restore

# Restore specific files
./backup.sh --restore /mnt/backup/backup.tar.gz -d /tmp/restore --files "etc/passwd etc/group"
```

### Execution Modes

```bash
# Dry run - simulation without actions
./backup.sh -s /home/user -d /mnt/backup --dry-run

# Verbose mode
./backup.sh -v

# Debug mode (very detailed)
./backup.sh --debug

# Silent mode (errors only)
./backup.sh -q

# Daemon mode (periodic execution)
./backup.sh --daemon --interval 3600
```

### Output Formats

```bash
# Text output (default)
./backup.sh --output text

# JSON output (for parsing)
./backup.sh --output json

# CSV output (for reports)
./backup.sh --output csv
```

## Configuration

### Configuration File

Locations searched (in order):
1. `./etc/backup.conf` (relative to script)
2. `~/.config/sysbackup/backup.conf`
3. `/etc/sysbackup.conf`

### Configuration Options

```bash
# ===== SOURCES AND DESTINATION =====
BACKUP_SOURCES=("/home/user" "/etc" "/var/www")
BACKUP_DEST="/mnt/backup"
BACKUP_PREFIX="myserver"

# ===== COMPRESSION =====
# Options: gz, bz2, xz, zstd, none
COMPRESSION="gz"
# Compression level: 1-9 (where applicable)
COMPRESSION_LEVEL=6

# ===== RETENTION POLICIES =====
RETENTION_DAILY=7
RETENTION_WEEKLY=4
RETENTION_MONTHLY=12

# ===== EXCLUSIONS =====
EXCLUDE_PATTERNS=(
    "*.log"
    "*.tmp"
    "*.swp"
    "*~"
    ".cache/"
    "node_modules/"
    "__pycache__/"
)

# ===== VERIFICATION =====
VERIFY_BACKUP=true
SAVE_CHECKSUM=true
CHECKSUM_ALGORITHM="sha256"

# ===== NOTIFICATIONS =====
NOTIFY_EMAIL="admin@example.com"
NOTIFY_ON_SUCCESS=false
NOTIFY_ON_ERROR=true

# ===== LOGGING =====
LOG_LEVEL="INFO"
LOG_FILE="/var/log/sysbackup/backup.log"

# ===== ADVANCED =====
NICE_LEVEL=19
IONICE_CLASS=3
MAX_PARALLEL_JOBS=2
```

## System Integration

### Cron Job

```bash
# Edit crontab
crontab -e

# Daily backup at 2:00 AM
0 2 * * * /opt/sysbackup/backup.sh -q >> /var/log/sysbackup/cron.log 2>&1

# Weekly backup Sunday at 3:00 AM
0 3 * * 0 /opt/sysbackup/backup.sh -t weekly -q

# Monthly backup on first day of month
0 4 1 * * /opt/sysbackup/backup.sh -t monthly -q
```

### Systemd Timer

```ini
# /etc/systemd/system/sysbackup.service
[Unit]
Description=System Backup Service
After=network.target

[Service]
Type=oneshot
ExecStart=/opt/sysbackup/backup.sh -q
User=root
Nice=19
IOSchedulingClass=idle

[Install]
WantedBy=multi-user.target
```

```ini
# /etc/systemd/system/sysbackup.timer
[Unit]
Description=Daily System Backup Timer

[Timer]
OnCalendar=*-*-* 02:00:00
Persistent=true
RandomizedDelaySec=300

[Install]
WantedBy=timers.target
```

```bash
# Enable timer
sudo systemctl enable --now sysbackup.timer

# Check status
sudo systemctl list-timers sysbackup*
```

### Systemd Service (Daemon Mode)

```ini
# /etc/systemd/system/sysbackup-daemon.service
[Unit]
Description=System Backup Daemon
After=network.target

[Service]
Type=simple
ExecStart=/opt/sysbackup/backup.sh --daemon --interval 86400
Restart=on-failure
User=root

[Install]
WantedBy=multi-user.target
```

## Exit Codes

| Code | Meaning |
|------|---------|
| 0    | Success - backup completed without errors |
| 1    | Configuration error (invalid source, inaccessible destination) |
| 2    | Error during backup (archiving partially failed) |
| 3    | Fatal error (missing dependencies, permissions) |
| 4    | Verification error (checksum mismatch) |
| 5    | Active lock (another instance running) |

## Advanced Examples

### Wrapper Script for Multiple Servers

```bash
#!/usr/bin/env bash
# multi-backup.sh - Centralised backup for multiple servers

SERVERS=("web1" "web2" "db1")
BACKUP_ROOT="/mnt/central-backup"

for server in "${SERVERS[@]}"; do
    echo "=== Backup $server ==="
    ./backup.sh \
        -s "/srv/$server" \
        -d "$BACKUP_ROOT/$server" \
        --prefix "$server" \
        --compression xz \
        --verify \
        --checksum \
        -q
    
    if [[ $? -ne 0 ]]; then
        echo "ERROR: Backup $server failed!"
    fi
done
```

### Backup with Slack Notification

```bash
#!/usr/bin/env bash
# backup-notify.sh

WEBHOOK_URL="https://hooks.slack.com/services/XXX/YYY/ZZZ"

./backup.sh "$@"
EXIT_CODE=$?

if [[ $EXIT_CODE -eq 0 ]]; then
    MESSAGE=":white_check_mark: Backup completed successfully"
else
    MESSAGE=":x: Backup failed with code $EXIT_CODE"
fi

curl -s -X POST -H 'Content-type: application/json' \
    --data "{\"text\":\"$MESSAGE\"}" \
    "$WEBHOOK_URL"

exit $EXIT_CODE
```

### Simulated Incremental Backup

```bash
#!/usr/bin/env bash
# incremental-backup.sh - Backup only recently modified files

DAYS_AGO=${1:-1}
SOURCE="/home/user"
DEST="/mnt/backup/incremental"

# Find modified files
TEMP_LIST=$(mktemp)
find "$SOURCE" -type f -mtime -"$DAYS_AGO" > "$TEMP_LIST"

if [[ -s "$TEMP_LIST" ]]; then
    tar -czf "$DEST/incremental_$(date +%Y%m%d).tar.gz" \
        -T "$TEMP_LIST" \
        --transform "s|^$SOURCE|.|"
    echo "Incremental backup: $(wc -l < "$TEMP_LIST") files"
else
    echo "No files modified in the last $DAYS_AGO days"
fi

rm -f "$TEMP_LIST"
```

## Testing

```bash
# Run all tests
./tests/test_backup.sh

# Run specific tests
./tests/test_backup.sh --filter "test_archive"

# Verbose mode
./tests/test_backup.sh -v

# Output results
# ==========================================
# TEST RESULTS
# ==========================================
# Total: 45
# Passed: 43
# Failed: 2
# Skipped: 0
# Success Rate: 95.56%
# ==========================================
```

## Troubleshooting

### Common Problems

**Error: "tar: Cannot open: Permission denied"**
```bash
# Check destination permissions
ls -la /mnt/backup/
# Run with sudo or adjust permissions
sudo ./backup.sh
```

**Error: "Lock file exists"**
```bash
# Check active process
cat /var/run/sysbackup/backup.pid
ps aux | grep backup
# If no process exists, delete lock
rm -f /var/run/sysbackup/backup.lock
```

**Backup too slow**
```bash
# Reduce compression level
./backup.sh --compression gz  # faster than xz
# Or use parallel compression
./backup.sh --compression zstd  # fast and efficient
```

**Insufficient space**
```bash
# Check available space
df -h /mnt/backup/
# Force rotation before backup
./backup.sh --force-rotate --retention-daily 3
```

## Code Architecture

### Execution Flow

```
backup.sh
    │
    ├─→ Load lib/core.sh (logging, errors, locks)
    ├─→ Load lib/utils.sh (archive, rotate, verify)
    ├─→ Load lib/config.sh (parse config, CLI)
    │
    ├─→ init_config() → load_config_file() → parse_args() → validate_config()
    │
    ├─→ acquire_lock()
    │
    ├─→ [For each source]
    │       ├─→ create_exclude_file()
    │       ├─→ create_archive()
    │       ├─→ verify_backup_integrity() (optional)
    │       └─→ calculate_checksum() (optional)
    │
    ├─→ rotate_backups() / rotate_by_age()
    │
    ├─→ generate_backup_report()
    │
    ├─→ send_notification() (optional)
    │
    └─→ release_lock() → cleanup() → exit
```

### Design Principles

1. **Separation of responsibilities**: Each module has a clear purpose
2. **Fail-safe defaults**: Safe behaviour in absence of configuration
3. **Verbose errors**: Descriptive error messages with suggestions
4. **Idempotent operations**: Repeated runs do not cause problems
5. **Graceful degradation**: Works without optional components

## Licence

Educational project - Operating Systems, ASE Bucharest CSIE.
Free use for teaching and personal purposes.

## Author

Teaching material created for the Operating Systems course.
Seminars 11-12: CAPSTONE Bash Projects.
