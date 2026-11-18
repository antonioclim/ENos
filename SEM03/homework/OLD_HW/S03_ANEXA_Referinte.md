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
│  │  • File owner, directory owner or privilege may remove entries                    │    │
│  │  • Used on public directories (/tmp)                        │    │
│  │                                                              │    │
│  │  $ ls -ld /tmp                                              │    │
│  │  drwxrwxrwt 15 root root ... /tmp                           │    │
│  │          ^                                                   │    │
│  │  Sticky adds an ownership check to directory write/search.    │    │
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

This is an administrator-only deployment scenario for a disposable VM, not a
learner-workspace setup. Group/ownership operations need authorised accounts.
Directory traversal and inherited ACLs must be tested for each role. SUID on Linux
interpreter scripts is ignored; use mode inspection without privileged execution.

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

# Step 6: Set directory and regular-file modes separately
sudo find /projects/webapp -type d -exec chmod 770 {} +
sudo find /projects/webapp -type f -exec chmod 660 {} +

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
umask 007  # Set before creation; SGID alone does not grant group write.
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
# backup_tool.sh: complete short/long parser and owned local backup example.
set -euo pipefail
VERSION=1.0.1
VERBOSE=false; DRY_RUN=false; COMPRESS=false
OUTPUT_DIR=./backup; RETENTION_DAYS=7; SOURCE=""
usage() { echo "Usage: $0 [-h|-V] [-v] [-n|--dry-run] [-c|--compress] [-o DIR] [-r DAYS] SOURCE"; }
error() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }
log() { if "$VERBOSE"; then printf '[INFO] %s\n' "$*" >&2; fi; return 0; }
parse_args() {
    while (($#)); do
        case $1 in
            -h|--help) usage; exit 0 ;;
            -V|--version) echo "$VERSION"; exit 0 ;;
            -v|--verbose) VERBOSE=true; shift ;;
            -n|--dry-run) DRY_RUN=true; shift ;;
            -c|--compress) COMPRESS=true; shift ;;
            -o|--output) [[ $# -ge 2 && -n $2 ]] || error 'Missing output'; OUTPUT_DIR=$2; shift 2 ;;
            --output=*) OUTPUT_DIR=${1#*=}; shift ;;
            -r|--retention) [[ $# -ge 2 && -n $2 ]] || error 'Missing retention'; RETENTION_DAYS=$2; shift 2 ;;
            --retention=*) RETENTION_DAYS=${1#*=}; shift ;;
            --) shift; break ;;
            -*) error "Unknown option: $1" ;;
            *) break ;;
        esac
    done
    [[ $# == 1 && -e $1 && -n $OUTPUT_DIR ]] || error 'One existing source and nonempty output are required'
    [[ $RETENTION_DAYS =~ ^[0-9]{1,4}$ ]] || error 'Retention must be 0–9999 whole days'
    RETENTION_DAYS=$((10#$RETENTION_DAYS))
    SOURCE=$(realpath -e -- "$1")
    OUTPUT_DIR=$(realpath -m -- "$OUTPUT_DIR")
    [[ $SOURCE != / && $OUTPUT_DIR != / ]] || error 'Root paths are not permitted'
    case "$OUTPUT_DIR/" in "$SOURCE/"*) error 'Destination must be outside source';; esac
    if [[ -e $OUTPUT_DIR ]]; then
        [[ -d $OUTPUT_DIR && -O $OUTPUT_DIR && ! -L $OUTPUT_DIR && -f $OUTPUT_DIR/.enos-backup-root && ! -L $OUTPUT_DIR/.enos-backup-root ]] || error 'Existing output is not this tool-owned backup root'
    fi
    return 0
}
do_backup() {
    if "$DRY_RUN"; then
        printf '[DRY RUN] Would create a %s backup of %q under %q\n' "$COMPRESS" "$SOURCE" "$OUTPUT_DIR"
        printf '[DRY RUN] Would retain incomplete/unmarked items and remove completed owned backups aged at least %d complete days after success\n' "$((RETENTION_DAYS+1))"
        return 0
    fi
    if [[ ! -e $OUTPUT_DIR ]]; then
        mkdir -- "$OUTPUT_DIR" || error 'Cannot create output root (parent must exist)'
        : > "$OUTPUT_DIR/.enos-backup-root"
    fi
    [[ ! -L $OUTPUT_DIR/.lock ]] || error 'Invalid lock path'
    exec 9>"$OUTPUT_DIR/.lock"
    flock -n 9 || error 'Another backup holds the lock'
    local dest item list
    dest=$(mktemp -d "$OUTPUT_DIR/backup_XXXXXXXX")
    if "$COMPRESS"; then
        tar -czf "$dest/content.tar.gz" -C "$(dirname -- "$SOURCE")" -- "$(basename -- "$SOURCE")" || error "Archive failed; incomplete evidence: $dest"
        tar -tzf "$dest/content.tar.gz" > /dev/null || error 'Archive verification failed'
    else
        cp -a -- "$SOURCE" "$dest/content" || error "Copy failed; incomplete evidence: $dest"
    fi
    : > "$dest/.enos-complete-v1"
    touch -- "$dest"
    log "Created $dest"
    # This teaching contract uses GNU find's complete-day buckets: +N means >=N+1.
    list=$(mktemp "$OUTPUT_DIR/.retention.XXXXXX")
    trap 'rm -f -- "$list"' RETURN
    find "$OUTPUT_DIR" -mindepth 1 -maxdepth 1 -type d -name 'backup_*' -mtime +"$RETENTION_DAYS" -print0 > "$list" || error 'Retention traversal failed'
    while IFS= read -r -d '' item; do
        [[ $item != "$dest" && -O $item && ! -L $item && -f $item/.enos-complete-v1 && ! -L $item/.enos-complete-v1 ]] || continue
        rm -rf -- "$item" || error "Retention failed: $item"
        log "Removed completed backup $item"
    done < "$list"
    rm -f -- "$list"
    trap - RETURN
    printf 'Backup complete: %s\n' "$dest"
}
parse_args "$@"
do_backup
```

The output root is dedicated to this example; existing unmarked directories are
rejected. A dry-run creates nothing, including no lock or log. Complete compressed
and uncompressed backups have the same uniquely named container and completion
marker; retention considers only those owned containers after a successful backup.
Failures retain their incomplete container for diagnosis and skip retention. No
restoration/service/account operation is performed. The example assumes a private
local destination with no concurrent hostile path replacement.



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
LOCK_FILE="/var/log/backup/daily_backup.lock"
set -euo pipefail
failed=0

# Private administrator-owned state; flock acquisition is atomic.
exec 9>"$LOCK_FILE"
flock -n 9 || { echo 'Another backup holds the lock' >&2; exit 2; }
# Never unlink a live descriptor lock file.

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
    log "Documents: ERROR"; failed=1
fi

# Backup 2: System configurations
log "Backup configurations..."
if /usr/local/bin/backup_tool -c -o /backup/config /etc 2>> "$LOG_FILE"; then
    log "Configurations: OK"
else
    log "Configurations: ERROR"; failed=1
fi

# Backup 3: Database example, with an explicitly configured local client.
# No mail recipient or notification service is selected by this worksheet.
DB_DIR=/backup/db
mkdir -p -- "$DB_DIR"
PARTIAL=$(mktemp "$DB_DIR/.mysql-partial.XXXXXX")
trap 'rm -f -- "$PARTIAL"' EXIT
if mysqldump --all-databases 2>> "$LOG_FILE" | gzip > "$PARTIAL"; then
    if gzip -t -- "$PARTIAL"; then
        mv -- "$PARTIAL" "$DB_DIR/mysql_$(date +%Y%m%d_%H%M%S)_${PARTIAL##*.}.sql.gz"
        log 'MySQL: archive created; a restore test is separate'
    else
        log 'MySQL: ERROR archive validation'; failed=1
    fi
else
    log 'MySQL: ERROR dump/compression'; failed=1
fi
if ((failed)); then log 'Backup incomplete; retention skipped'; exit 1; fi
# Rotate only owned completed backup logs after success; deployment policy may differ.
find /var/log/backup -maxdepth 1 -type f -name 'backup_*.log' -mtime +30 -delete
log 'Backup commands completed'
# An approved local notification channel may be configured separately.
SCRIPT

sudo chmod +x /usr/local/bin/daily_backup.sh

# Step 4: Add to crontab
# Daily backup at 3:00 AM
echo "0 3 * * * root /usr/local/bin/daily_backup.sh" | sudo tee /etc/cron.d/daily_backup

# Step 5: Verify
# /etc/cron.d entries are separate from root's per-user crontab.
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

---

*By Revolvix for OPERATING SYSTEMS class | restricted licence 2017-2030*
