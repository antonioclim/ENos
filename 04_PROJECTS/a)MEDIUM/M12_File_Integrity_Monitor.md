# M12: File Integrity Monitor

> **Level:** MEDIUM | **Estimated time:** 25-35 hours | **K8s Bonus:** +10%

---

## Description

Critical file integrity monitoring system: hash-based change detection, real-time alerting, complete audit trail and compliance reports. Similar to AIDE or Tripwire, but implemented in Bash.

---

## Learning Objectives

- Cryptographic hash functions (MD5, SHA-256)
- Filesystem event monitoring (inotify)
- Baseline management and comparison
- Audit logging and compliance
- Alerting and notifications

---

## Functional Requirements

### Mandatory (for passing grade)

1. **Baseline management**
   - Create baseline (hash + metadata for files)
   - Selective baseline update
   - Secure baseline storage

2. **Integrity verification**
   - Current hash vs baseline comparison
   - Detection: modification, addition, deletion
   - Permission and ownership verification

3. **Real-time monitoring**
   - Watch mode with inotify
   - Immediate alert on modification
   - Pattern exclusion (logs, temp)

4. **Reporting**
   - Detailed difference report
   - Audit trail with timestamp
   - Export for compliance

5. **Flexible configuration**
   - Directories/files to monitor
   - Exclusions (glob patterns)
   - Selectable hash algorithm

### Optional (for full marks)

6. **Scheduled verification** - Cron integration with reports
7. **Rollback capability** - Restore from backup on modification
8. **Extended attributes** - ACL, SELinux context verification
9. **Database backend** - SQLite for history
10. **Web dashboard** - Status and history visualisation

---

## CLI Interface

```bash
./fim.sh <command> [options]

Commands:
  init                  Initialise configuration and empty baseline
  baseline              Create/update baseline
  check                 Verify integrity against baseline
  watch                 Real-time monitoring (inotify)
  report [period]       Generate modification report
  history [file]        Display modification history
  restore <file>        Restore file from backup (if available)
  status                System status and last check

Options:
  -c, --config FILE     Configuration file
  -d, --dir DIR         Directory to monitor (can be repeated)
  -e, --exclude PATT    Pattern to exclude (can be repeated)
  -a, --algorithm ALG   Hash algorithm: md5|sha1|sha256|sha512
  -o, --output FILE     Save report
  -f, --format FMT      Format: text|json|html
  -q, --quiet           Errors and warnings only
  -v, --verbose         Detailed output
  --deep                Include extended attributes

Examples:
  ./fim.sh init
  ./fim.sh baseline -d /etc -d /usr/bin --exclude "*.log"
  ./fim.sh check
  ./fim.sh watch -d /etc/ssh
  ./fim.sh report --format html -o report.html
```

---

## Output Examples

### Baseline Creation

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                    FILE INTEGRITY MONITOR - BASELINE                         ║
║                    Creating baseline...                                      ║
╚══════════════════════════════════════════════════════════════════════════════╝

Scanning directories...
  [1/3] /etc ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 100%
  [2/3] /usr/bin ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 100%
  [3/3] /usr/sbin ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 100%

BASELINE SUMMARY
═══════════════════════════════════════════════════════════════════════════════
  Total files:          4,521
  Total directories:    342
  Total size:           1.2 GB
  Hash algorithm:       SHA-256
  
  By directory:
    /etc                1,234 files (45 MB)
    /usr/bin            2,456 files (890 MB)
    /usr/sbin             831 files (265 MB)
  
  Excluded:
    *.log               23 files
    *.tmp               5 files
    /etc/mtab           1 file

Baseline saved: /var/lib/fim/baseline.db
Backup created: /var/lib/fim/baseline.db.20250120

✓ Baseline created successfully
  Next: Run './fim.sh check' to verify integrity
```

### Integrity Check

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                    FILE INTEGRITY CHECK                                      ║
║                    Baseline: 2025-01-15 03:00:00                            ║
║                    Check time: 2025-01-20 17:30:00                          ║
╚══════════════════════════════════════════════════════════════════════════════╝

Checking 4,521 files...
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 100%

INTEGRITY STATUS: ⚠️ CHANGES DETECTED
═══════════════════════════════════════════════════════════════════════════════

🔴 MODIFIED FILES (3)
───────────────────────────────────────────────────────────────────────────────

  /etc/passwd
  ├─ Hash changed:     a1b2c3d4... → e5f6g7h8...
  ├─ Modified:         2025-01-18 14:30:22
  ├─ Size:             2,456 → 2,512 bytes (+56)
  └─ Permissions:      unchanged (644)
  
  /etc/ssh/sshd_config
  ├─ Hash changed:     x9y8z7w6... → m3n4o5p6...
  ├─ Modified:         2025-01-19 09:15:00
  ├─ Size:             3,312 → 3,298 bytes (-14)
  └─ Permissions:      unchanged (600)
  
  /usr/bin/sudo
  ├─ Hash changed:     q1r2s3t4... → u5v6w7x8...
  ├─ Modified:         2025-01-17 02:30:00 (apt update)
  ├─ Size:             232,416 → 234,512 bytes
  └─ Permissions:      unchanged (4755)

🟡 NEW FILES (2)
───────────────────────────────────────────────────────────────────────────────

  /etc/cron.d/backup-job
  ├─ Created:          2025-01-16 10:00:00
  ├─ Size:             156 bytes
  ├─ Permissions:      644
  └─ Owner:            root:root
  
  /usr/local/bin/custom-script.sh
  ├─ Created:          2025-01-19 16:45:00
  ├─ Size:             2,048 bytes
  ├─ Permissions:      755
  └─ Owner:            admin:admin

🔵 DELETED FILES (1)
───────────────────────────────────────────────────────────────────────────────

  /etc/cron.d/old-backup (was in baseline, now missing)

⚪ PERMISSION CHANGES (1)
───────────────────────────────────────────────────────────────────────────────

  /etc/shadow
  └─ Permissions:      640 → 600 (more restrictive ✓)

═══════════════════════════════════════════════════════════════════════════════
SUMMARY
───────────────────────────────────────────────────────────────────────────────
  Files checked:       4,521
  Modified:            3 ⚠️
  New:                 2
  Deleted:             1
  Permission changes:  1
  Unchanged:           4,514 ✓

  Critical findings:   1 (sudo binary changed - verify if apt update)
  
Time: 12.3 seconds
Report saved: /var/log/fim/check_20250120_173000.log
```

### Watch Mode

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                    FILE INTEGRITY MONITOR - WATCH MODE                       ║
║                    Monitoring: /etc, /usr/bin                               ║
║                    Press Ctrl+C to stop                                      ║
╚══════════════════════════════════════════════════════════════════════════════╝

[17:45:00] Starting inotify watches on 342 directories...
[17:45:01] Watch mode active. Waiting for events...

[17:45:23] 📝 MODIFY  /etc/hosts
           Hash: a1b2c3d4 → e5f6g7h8
           Action: Logged, notification sent

[17:46:05] ➕ CREATE  /etc/cron.d/new-job
           Size: 234 bytes, Owner: root
           Action: Logged

[17:48:12] 🔒 ATTRIB  /etc/shadow
           Permissions changed: 640 → 600
           Action: Logged

[17:52:30] ❌ DELETE  /tmp/test.conf
           Action: Ignored (excluded path)

───────────────────────────────────────────────────────────────────────────────
Events today: 12 (4 logged, 8 excluded)
Last event: 17:52:30
```

---

## Baseline Format (SQLite)

```sql
-- Schema for baseline
CREATE TABLE files (
    id INTEGER PRIMARY KEY,
    path TEXT UNIQUE NOT NULL,
    hash TEXT NOT NULL,
    size INTEGER,
    mtime INTEGER,
    permissions TEXT,
    uid INTEGER,
    gid INTEGER,
    type TEXT,  -- file, directory, symlink
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE changes (
    id INTEGER PRIMARY KEY,
    path TEXT NOT NULL,
    change_type TEXT,  -- modified, added, deleted, permission
    old_hash TEXT,
    new_hash TEXT,
    old_value TEXT,
    new_value TEXT,
    detected_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_files_path ON files(path);
CREATE INDEX idx_changes_path ON changes(path);
```

---

## Project Structure

```
M12_File_Integrity_Monitor/
├── README.md
├── Makefile
├── src/
│   ├── fim.sh                   # Main script
│   └── lib/
│       ├── baseline.sh          # Create/update baseline
│       ├── check.sh             # Integrity verification
│       ├── watch.sh             # inotify monitoring
│       ├── hash.sh              # Hash functions
│       ├── report.sh            # Report generation
│       ├── notify.sh            # Notifications
│       └── db.sh                # SQLite operations
├── etc/
│   ├── fim.conf                 # Configuration
│   └── excludes.conf            # Excluded patterns
├── tests/
│   ├── test_hash.sh
│   ├── test_baseline.sh
│   └── test_files/
└── docs/
    ├── INSTALL.md
    └── COMPLIANCE.md
```

---

## Implementation Hints

### File hash calculation

```bash
compute_hash() {
    local file="$1"
    local algorithm="${2:-sha256}"
    
    case "$algorithm" in
        md5)    md5sum "$file" | cut -d' ' -f1 ;;
        sha1)   sha1sum "$file" | cut -d' ' -f1 ;;
        sha256) sha256sum "$file" | cut -d' ' -f1 ;;
        sha512) sha512sum "$file" | cut -d' ' -f1 ;;
        *)      echo "Unknown algorithm: $algorithm" >&2; return 1 ;;
    esac
}

# Parallel calculation for performance
compute_hashes_parallel() {
    local dir="$1"
    local algorithm="${2:-sha256}"
    
    find "$dir" -type f -print0 | \
        xargs -0 -P 4 -I {} "${algorithm}sum" {} 2>/dev/null
}
```

### Creating baseline

```bash
create_baseline() {
    local config="$1"
    local db="$BASELINE_DB"
    
    # Initialise DB
    sqlite3 "$db" < "$SCHEMA_FILE"
    
    # For each configured directory
    while IFS= read -r dir; do
        find "$dir" -type f | while read -r file; do
            # Skip excluded
            if is_excluded "$file"; then
                continue
            fi
            
            local hash size mtime perms uid gid
            hash=$(compute_hash "$file")
            size=$(stat -c %s "$file")
            mtime=$(stat -c %Y "$file")
            perms=$(stat -c %a "$file")
            uid=$(stat -c %u "$file")
            gid=$(stat -c %g "$file")
            
            sqlite3 "$db" "INSERT INTO files (path, hash, size, mtime, permissions, uid, gid, type) 
                          VALUES ('$file', '$hash', $size, $mtime, '$perms', $uid, $gid, 'file');"
        done
    done < <(get_monitored_dirs "$config")
}
```

### Integrity verification

```bash
check_integrity() {
    local db="$BASELINE_DB"
    local changes=0
    
    # Check files from baseline
    sqlite3 "$db" "SELECT path, hash, size, permissions FROM files" | \
    while IFS='|' read -r path old_hash old_size old_perms; do
        if [[ ! -e "$path" ]]; then
            report_change "deleted" "$path"
            ((changes++))
            continue
        fi
        
        local new_hash new_size new_perms
        new_hash=$(compute_hash "$path")
        new_size=$(stat -c %s "$path")
        new_perms=$(stat -c %a "$path")
        
        if [[ "$new_hash" != "$old_hash" ]]; then
            report_change "modified" "$path" "$old_hash" "$new_hash"
            ((changes++))
        fi
        
        if [[ "$new_perms" != "$old_perms" ]]; then
            report_change "permission" "$path" "$old_perms" "$new_perms"
            ((changes++))
        fi
    done
    
    # Check for new files
    find_new_files "$db"
    
    return $((changes > 0 ? 1 : 0))
}
```

### Monitoring with inotify

```bash
watch_directories() {
    local dirs=("$@")
    
    # Check if inotifywait is available
    command -v inotifywait &>/dev/null || {
        echo "Error: inotify-tools not installed"
        echo "Install with: apt install inotify-tools"
        return 1
    }
    
    # Build directory list
    local watch_args=()
    for dir in "${dirs[@]}"; do
        watch_args+=(-r "$dir")
    done
    
    # Monitoring
    inotifywait -m -e modify,create,delete,attrib \
        --format '%T %w%f %e' --timefmt '%Y-%m-%d %H:%M:%S' \
        "${watch_args[@]}" 2>/dev/null | \
    while read -r timestamp path event; do
        # Skip excluded
        if is_excluded "$path"; then
            log_debug "Excluded: $path"
            continue
        fi
        
        log_event "$timestamp" "$path" "$event"
        
        case "$event" in
            MODIFY)
                local old_hash new_hash
                old_hash=$(get_baseline_hash "$path")
                new_hash=$(compute_hash "$path")
                if [[ "$old_hash" != "$new_hash" ]]; then
                    alert "File modified: $path"
                fi
                ;;
            CREATE)
                alert "New file: $path"
                ;;
            DELETE)
                alert "File deleted: $path"
                ;;
            ATTRIB)
                alert "Attributes changed: $path"
                ;;
        esac
    done
}
```

---

## Specific Evaluation Criteria

| Criterion | Weight | Description |
|-----------|--------|-------------|
| Baseline management | 20% | Creation, storage, update |
| Integrity verification | 25% | Hash compare, detect all types |
| Watch mode | 15% | Functional inotify |
| Reporting | 15% | Clear format, details, export |
| Configuration | 10% | Dirs, excludes, algorithm |
| Alerting | 5% | Notifications on modification |
| Code quality + tests | 5% | ShellCheck, tests |
| Documentation | 5% | README, compliance info |

---

## Resources

- `man inotifywait` - Filesystem monitoring
- `man sha256sum` - Hash functions
- AIDE documentation (for inspiration)
- CIS Benchmarks - File integrity requirements

---

*MEDIUM Project | Operating Systems | ASE-CSIE*
