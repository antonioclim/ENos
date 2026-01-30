# S03_APPENDIX - Seminar 3 References (Redistributed)

> **Operating Systems** | Bucharest UES - CSIE  
> Supplementary material

---

## Supplementary ASCII Diagrams

### Linux Permission System - Detailed

```
┌──────────────────────────────────────────────────────────────────────┐
│                    PERMISSION ANATOMY                                │
├──────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  ls -l output:                                                       │
│  -rwxr-xr-- 1 john developers 4096 Jan 10 12:00 script.sh           │
│  │└┬┘└┬┘└┬┘ │  │    │          │    │              │                │
│  │ │  │  │  │  │    │          │    │              └─ Filename      │
│  │ │  │  │  │  │    │          │    └─ Modification date            │
│  │ │  │  │  │  │    │          └─ Size (bytes)                      │
│  │ │  │  │  │  │    └─ Owner group                                  │
│  │ │  │  │  │  └─ Owner user                                        │
│  │ │  │  │  └─ Number of hard links                                 │
│  │ │  │  └─ Others permissions: r-- (read only)                     │
│  │ │  └─ Group permissions: r-x (read + execute)                    │
│  │ └─ Owner permissions: rwx (full)                                 │
│  └─ Type: - file, d directory, l symlink, c char, b block          │
│                                                                      │
├──────────────────────────────────────────────────────────────────────┤
│                      OCTAL CALCULATION                               │
├──────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  r = 4 (read)     ┌────┬────┬────┐                                  │
│  w = 2 (write)    │ r  │ w  │ x  │                                  │
│  x = 1 (execute)  │ 4  │ 2  │ 1  │                                  │
│                   └────┴────┴────┘                                  │
│                                                                      │
│  Examples:                                                           │
│  rwx = 4+2+1 = 7    ┌───────────────────────────────────┐           │
│  rw- = 4+2+0 = 6    │  755 = rwxr-xr-x                  │           │
│  r-x = 4+0+1 = 5    │  644 = rw-r--r--                  │           │
│  r-- = 4+0+0 = 4    │  700 = rwx------                  │           │
│  --x = 0+0+1 = 1    │  600 = rw-------                  │           │
│  --- = 0+0+0 = 0    │  777 = rwxrwxrwx (AVOID!)         │           │
│                     └───────────────────────────────────┘           │
│                                                                      │
└──────────────────────────────────────────────────────────────────────┘
```

### Special Permissions

```
┌──────────────────────────────────────────────────────────────────────┐
│                    SPECIAL PERMISSIONS                               │
├──────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  ┌─────────────────────────────────────────────────────────────┐    │
│  │  SUID (Set User ID) - Bit 4xxx                              │    │
│  │                                                              │    │
│  │  -rwsr-xr-x  (s instead of x for owner)                     │    │
│  │                                                              │    │
│  │  • Process runs with UID of the file owner                  │    │
│  │  • Used for: passwd, ping, sudo                             │    │
│  │                                                              │    │
│  │  Example:                                                    │    │
│  │  $ ls -l /usr/bin/passwd                                    │    │
│  │  -rwsr-xr-x 1 root root ... /usr/bin/passwd                 │    │
│  │        ^                                                     │    │
│  │  Any user can change password (requires writing to          │    │
│  │  /etc/shadow which is owned by root)                        │    │
│  │                                                              │    │
│  │  chmod u+s file    or    chmod 4755 file                    │    │
│  └─────────────────────────────────────────────────────────────┘    │
│                                                                      │
│  ┌─────────────────────────────────────────────────────────────┐    │
│  │  SGID (Set Group ID) - Bit 2xxx                             │    │
│  │                                                              │    │
│  │  On files: -rwxr-sr-x (s instead of x for group)            │    │
│  │  On directories: drwxr-sr-x                                 │    │
│  │                                                              │    │
│  │  On files:                                                   │    │
│  │  • Process runs with GID of the file's group                │    │
│  │                                                              │    │
│  │  On directories (more common):                               │    │
│  │  • New files inherit the directory's group                  │    │
│  │  • Useful for shared project directories                    │    │
│  │                                                              │    │
│  │  Example:                                                    │    │
│  │  $ mkdir /shared/project                                    │    │
│  │  $ chgrp developers /shared/project                         │    │
│  │  $ chmod g+s /shared/project                                │    │
│  │  $ chmod 2775 /shared/project                               │    │
│  │  # Now all new files belong to the "developers" group       │    │
│  └─────────────────────────────────────────────────────────────┘    │
│                                                                      │
│  ┌─────────────────────────────────────────────────────────────┐    │
│  │  Sticky Bit - Bit 1xxx                                      │    │
│  │                                                              │    │
│  │  drwxrwxrwt (t instead of x for others)                     │    │
│  │                                                              │    │
│  │  • Only the file owner can delete/rename                    │    │
│  │  • Used on public directories (/tmp)                        │    │
│  │                                                              │    │
│  │  $ ls -ld /tmp                                              │    │
│  │  drwxrwxrwt 15 root root ... /tmp                           │    │
│  │          ^                                                   │    │
│  │  Everyone can create files, but each can only delete their  │    │
│  │  own                                                         │    │
│  │                                                              │    │
│  │  chmod +t directory    or    chmod 1777 directory           │    │
│  └─────────────────────────────────────────────────────────────┘    │
│                                                                      │
└──────────────────────────────────────────────────────────────────────┘
```

### CRON - Execution Flow

```
┌──────────────────────────────────────────────────────────────────────┐
│                       CRON SYSTEM                                    │
├──────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  ┌─────────────────────────────────────────────────────────────┐    │
│  │                    CRON DAEMON                               │    │
│  │                    (crond/cron)                              │    │
│  │              Runs continuously in background                 │    │
│  └─────────────────────────────────────────────────────────────┘    │
│                              │                                       │
│              Every minute it checks:                                │
│                              │                                       │
│         ┌────────────────────┼────────────────────┐                 │
│         ▼                    ▼                    ▼                  │
│  ┌─────────────┐    ┌──────────────┐    ┌──────────────────┐       │
│  │ User        │    │ System       │    │ Cron Directories │       │
│  │ Crontabs    │    │ Crontab      │    │ /etc/cron.*     │       │
│  │             │    │              │    │                  │       │
│  │ /var/spool/ │    │ /etc/crontab │    │ cron.hourly/    │       │
│  │ cron/       │    │              │    │ cron.daily/     │       │
│  │ crontabs/   │    │ Include user │    │ cron.weekly/    │       │
│  │             │    │ field        │    │ cron.monthly/   │       │
│  └─────────────┘    └──────────────┘    └──────────────────┘       │
│                                                                      │
│  Crontab format:                                                     │
│  ┌─────────────────────────────────────────────────────────────┐    │
│  │  ┌─────────── minute (0-59)                                 │    │
│  │  │ ┌─────────── hour (0-23)                                 │    │
│  │  │ │ ┌─────────── day of month (1-31)                       │    │
│  │  │ │ │ ┌─────────── month (1-12)                            │    │
│  │  │ │ │ │ ┌─────────── day of week (0-7, 0,7=Sunday)         │    │
│  │  │ │ │ │ │                                                   │    │
│  │  │ │ │ │ │                                                   │    │
│  │  * * * * * command                                          │    │
│  └─────────────────────────────────────────────────────────────┘    │
│                                                                      │
│  Visual examples:                                                    │
│                                                                      │
│  */5 * * * *     Every 5 minutes                                    │
│  ──────────────────────────────────────────────────────►           │
│  │    │    │    │    │    │    │    │    │    │    │    │          │
│  0    5   10   15   20   25   30   35   40   45   50   55          │
│                                                                      │
│  0 3 * * *       Daily at 03:00                                     │
│  ──────────────────────────────────────────────────────►           │
│  │                        ▲                             │          │
│  00:00                 03:00                         23:59         │
│                                                                      │
│  0 9 * * 1-5     Monday-Friday at 09:00                             │
│        M    Tu   W    Th   F    Sa   Su                             │
│        ▲    ▲    ▲    ▲    ▲                                       │
│       09:00                                                         │
│                                                                      │
└──────────────────────────────────────────────────────────────────────┘
```

---

## Fully Solved Exercises

### Exercise 1: Shared Project Directory Configuration

**Requirement:** Configure a team directory with correct permissions.

```bash
# Scenario: The "developers" team needs to work on a shared project

# Step 1: Create the group (if it doesn't exist)
sudo groupadd developers

# Step 2: Add users to the group
sudo usermod -aG developers alice
sudo usermod -aG developers bob
sudo usermod -aG developers charlie

# Step 3: Verify group members
grep developers /etc/group
# developers:x:1001:alice,bob,charlie

# Step 4: Create the directory structure
sudo mkdir -p /projects/webapp/{src,docs,tests,config}

# Step 5: Set ownership
sudo chown -R root:developers /projects/webapp

# Step 6: Set base permissions (owner=rwx, group=rwx, others=---)
sudo chmod -R 770 /projects/webapp

# Step 7: Set SGID on directories (new files inherit the group)
sudo find /projects/webapp -type d -exec chmod g+s {} \;

# Step 8: Verify the result
ls -la /projects/webapp/
# drwxrws--- 6 root developers 4096 Jan 10 12:00 .
# drwxrws--- 2 root developers 4096 Jan 10 12:00 config
# drwxrws--- 2 root developers 4096 Jan 10 12:00 docs
# drwxrws--- 2 root developers 4096 Jan 10 12:00 src
# drwxrws--- 2 root developers 4096 Jan 10 12:00 tests

# Step 9: Test as alice
su - alice
cd /projects/webapp/src
touch test_file.py
ls -l test_file.py
# -rw-rw---- 1 alice developers 0 Jan 10 12:01 test_file.py
# Note: the group is "developers" due to SGID!

# Step 10: Set umask for group
echo "umask 007" >> ~/.bashrc
# New files will be 770/660 (not accessible by others)
```

### Exercise 2: Complete Argument Parsing Script

**Requirement:** Create a professional script with support for short and long options.

```bash
#!/bin/bash
#
# Script: backup_tool.sh
# Description: Backup tool with complete options
#

set -euo pipefail

# === CONSTANTS ===
readonly VERSION="1.0.0"
readonly SCRIPT_NAME=$(basename "$0")

# === DEFAULT VARIABLES ===
VERBOSE=false
DRY_RUN=false
COMPRESS=false
OUTPUT_DIR="./backup"
RETENTION_DAYS=7
SOURCE=""

# === FUNCTIONS ===
usage() {
    cat << EOF
$SCRIPT_NAME v$VERSION - Backup tool

USAGE:
    $SCRIPT_NAME [options] <source>

OPTIONS:
    -h, --help              Display this message
    -V, --version           Display version
    -v, --verbose           Verbose mode
    -n, --dry-run           Simulation (does not execute)
    -c, --compress          Compress the backup (tar.gz)
    -o, --output DIR        Output directory (default: ./backup)
    -r, --retention DAYS    Keep backups for DAYS days (default: 7)

EXAMPLES:
    $SCRIPT_NAME /home/user/documents
    $SCRIPT_NAME -v -c -o /backup /var/www
    $SCRIPT_NAME --dry-run --retention 30 /data

EOF
    exit 0
}

version() {
    echo "$SCRIPT_NAME version $VERSION"
    exit 0
}

log() {
    if $VERBOSE; then
        echo "[$(date '+%H:%M:%S')] $*"
    fi
}

error() {
    echo "ERROR: $*" >&2
    exit 1
}

# === ARGUMENT PARSING ===
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                usage
                ;;
            -V|--version)
                version
                ;;
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            -n|--dry-run)
                DRY_RUN=true
                shift
                ;;
            -c|--compress)
                COMPRESS=true
                shift
                ;;
            -o|--output)
                [[ -z "${2:-}" ]] && error "Option -o requires an argument"
                OUTPUT_DIR="$2"
                shift 2
                ;;
            --output=*)
                OUTPUT_DIR="${1#*=}"
                shift
                ;;
            -r|--retention)
                [[ -z "${2:-}" ]] && error "Option -r requires an argument"
                RETENTION_DAYS="$2"
                shift 2
                ;;
            --retention=*)
                RETENTION_DAYS="${1#*=}"
                shift
                ;;
            --)
                shift
                SOURCE="${1:-}"
                break
                ;;
            -*)
                error "Unknown option: $1"
                ;;
            *)
                SOURCE="$1"
                shift
                ;;
        esac
    done

    # Validation
    [[ -z "$SOURCE" ]] && error "Missing source for backup"
    [[ ! -e "$SOURCE" ]] && error "Source does not exist: $SOURCE"
    [[ ! "$RETENTION_DAYS" =~ ^[0-9]+$ ]] && error "Retention must be a number"
}

# === MAIN LOGIC ===
do_backup() {
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local backup_name="backup_$(basename "$SOURCE")_$timestamp"
    
    mkdir -p "$OUTPUT_DIR"
    
    log "Source: $SOURCE"
    log "Output: $OUTPUT_DIR"
    log "Compression: $COMPRESS"
    
    if $DRY_RUN; then
        echo "[DRY RUN] Would create backup: $OUTPUT_DIR/$backup_name"
        return 0
    fi
    
    if $COMPRESS; then
        tar czf "$OUTPUT_DIR/${backup_name}.tar.gz" -C "$(dirname "$SOURCE")" "$(basename "$SOURCE")"
        log "Created: $OUTPUT_DIR/${backup_name}.tar.gz"
    else
        cp -r "$SOURCE" "$OUTPUT_DIR/$backup_name"
        log "Created: $OUTPUT_DIR/$backup_name"
    fi
    
    # Old cleanup
    log "Deleting backups older than $RETENTION_DAYS days..."
    find "$OUTPUT_DIR" -name "backup_*" -mtime +$RETENTION_DAYS -delete 2>/dev/null || true
    
    echo "Backup complete!"
}

# === MAIN ===
main() {
    parse_args "$@"
    do_backup
}

main "$@"
```

### Exercise 3: Complete Cron Job with Logging

**Requirement:** Configure an automated backup system with cron.

```bash
# Step 1: Create the backup script (from previous exercise)
sudo cp backup_tool.sh /usr/local/bin/backup_tool
sudo chmod +x /usr/local/bin/backup_tool

# Step 2: Create the log directory
sudo mkdir -p /var/log/backup
sudo chmod 755 /var/log/backup

# Step 3: Create wrapper script with complete logging
sudo tee /usr/local/bin/daily_backup.sh << 'SCRIPT'
#!/bin/bash
#
# daily_backup.sh - Wrapper for daily backup with logging
#

LOG_FILE="/var/log/backup/backup_$(date +%Y%m%d).log"
LOCK_FILE="/tmp/daily_backup.lock"

# Prevent simultaneous executions
if [ -f "$LOCK_FILE" ]; then
    echo "$(date): Backup already running" >> "$LOG_FILE"
    exit 1
fi

# Create lock
echo $$ > "$LOCK_FILE"
trap "rm -f $LOCK_FILE" EXIT

# Logging function
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $*" >> "$LOG_FILE"
}

# Start
log "=== Start daily backup ==="

# Backup 1: User documents
log "Backup documents..."
if /usr/local/bin/backup_tool -c -o /backup/docs /home 2>> "$LOG_FILE"; then
    log "Documents: OK"
else
    log "Documents: ERROR"
fi

# Backup 2: System configurations
log "Backup configurations..."
if /usr/local/bin/backup_tool -c -o /backup/config /etc 2>> "$LOG_FILE"; then
    log "Configurations: OK"
else
    log "Configurations: ERROR"
fi

# Backup 3: Databases (example)
log "Backup MySQL..."
if mysqldump --all-databases | gzip > "/backup/db/mysql_$(date +%Y%m%d).sql.gz" 2>> "$LOG_FILE"; then
    log "MySQL: OK"
else
    log "MySQL: ERROR (or not installed)"
fi

# Cleanup old logs (keep 30 days)
find /var/log/backup -name "backup_*.log" -mtime +30 -delete

log "=== Backup complete ==="

# Send email if there were errors
if grep -q "ERROR" "$LOG_FILE"; then
    mail -s "Backup Warning $(date +%Y-%m-%d)" Issues: Open an issue in GitHub < "$LOG_FILE"
fi
SCRIPT

sudo chmod +x /usr/local/bin/daily_backup.sh

# Step 4: Add to crontab
# Daily backup at 3:00 AM
echo "0 3 * * * root /usr/local/bin/daily_backup.sh" | sudo tee /etc/cron.d/daily_backup

# Step 5: Verify
sudo crontab -l -u root
cat /etc/cron.d/daily_backup
```

---

## Quick References

### Common Permissions

| Octal | Symbolic | Usage |
|-------|----------|-------|
| 755 | rwxr-xr-x | Executables, public directories |
| 644 | rw-r--r-- | Normal files |
| 700 | rwx------ | Private directories |
| 600 | rw------- | Private files |
| 775 | rwxrwxr-x | Group directories |
| 664 | rw-rw-r-- | Group files |
| 777 | rwxrwxrwx | AVOID! Insecure |

### CRON Special Characters

| Character | Meaning |
|-----------|---------|
| * | Any value |
| , | List (1,3,5) |
| - | Range (1-5) |
| / | Step (*/5) |
| @reboot | At boot |
| @daily | Daily 00:00 |
| @weekly | Sunday 00:00 |
| @monthly | First day 00:00 |

---
*Supplementary material for the Operating Systems course | Bucharest UES - CSIE*
-e 

---

*By Revolvix for OPERATING SYSTEMS class | restricted licence 2017-2030*
