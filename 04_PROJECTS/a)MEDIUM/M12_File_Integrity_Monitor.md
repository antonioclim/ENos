# M12: File Integrity Monitor

> **Level:** MEDIUM | **Estimated time:** 25-35 hours | **K8s Bonus:** +10%

---

## Description

Critical file integrity monitoring system: hash-based change detection, real-time alerting, an audit trail with explicit event-loss and reconciliation limits and compliance reports. Similar to AIDE or Tripwire, but implemented in Bash.

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

```text
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
  ├─ Hash changed:     a1b2c3d4... → e5f607a8...
  ├─ Modified:         2025-01-18 14:30:22
  ├─ Size:             2,456 → 2,512 bytes (+56)
  └─ Permissions:      unchanged (644)
  
  /etc/ssh/sshd_config
  ├─ Hash changed:     a9b8c7d6... → a3b4c5d6...
  ├─ Modified:         2025-01-19 09:15:00
  ├─ Size:             3,312 → 3,298 bytes (-14)
  └─ Permissions:      unchanged (600)
  
  /usr/bin/sudo
  ├─ Hash changed:     a1b2c3d4... → e5f607a8...
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
           Hash: a1b2c3d4 → e5f607a8
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
CREATE TABLE IF NOT EXISTS files (
    id INTEGER PRIMARY KEY,
    path TEXT UNIQUE NOT NULL,
    hash TEXT NOT NULL,
    algorithm TEXT NOT NULL, -- every stored digest has an explicit algorithm
    size INTEGER,
    mtime INTEGER,
    permissions TEXT,
    uid INTEGER,
    gid INTEGER,
    type TEXT,  -- file, directory, symlink
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS changes (
    id INTEGER PRIMARY KEY,
    path TEXT NOT NULL,
    change_type TEXT,  -- modified, added, deleted, permission
    old_hash TEXT,
    new_hash TEXT,
    old_value TEXT,
    new_value TEXT,
    detected_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_files_path ON files(path);
CREATE INDEX IF NOT EXISTS idx_changes_path ON changes(path);
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
compute_hash() (
    set -o pipefail
    local file="$1"
    local algorithm="${2:-sha256}"
    
    case "$algorithm" in
        md5)    md5sum < "$file" | cut -d' ' -f1 ;;
        sha1)   sha1sum < "$file" | cut -d' ' -f1 ;;
        sha256) sha256sum < "$file" | cut -d' ' -f1 ;;
        sha512) sha512sum < "$file" | cut -d' ' -f1 ;;
        *)      echo "Unknown algorithm: $algorithm" >&2; return 1 ;;
    esac
)

# Parallel calculation for performance
compute_hashes_parallel() {
    local dir="$1"
    local algorithm="${2:-sha256}"
    
    find "$dir" -type f -print0 | \
        xargs -0 -P 4 -I {} "${algorithm}sum" {} 2>/dev/null
}
```

The executable [baseline reference](../reference/fim_reference.py) is a Bash-callable
Python/SQLite helper. It uses parameterised SQL, an explicit v1 schema, staged
transactional publication, persistent locking and per-baseline algorithm metadata.
Its config is literal JSON: `{"roots":["/owned/fixture"],"exclude":[],"algorithm":"sha256"}`.
Regular files are monitored; symlinks are not followed, each hard-link pathname is
recorded and directories are scope containers. Database/lock files are excluded
from their own scan. An unreadable root or changing file makes the operation
unavailable, rather than producing a successful partial baseline. Snapshot
consistency against hostile concurrent mutation is outside this teaching helper.
The earlier SQL diagram is explanatory; the helper's executable schema is canonical
for this reference. Migration of another schema must be explicit.

### Creating baseline

```bash
: "${FIM_HELPER:?Path to 04_PROJECTS/reference/fim_reference.py}"
create_baseline() {
    local config="$1" operation="${2:-create}"
    # Explicit update replaces only configured roots; other roots are retained.
    [[ $operation == create || $operation == update ]] || return 2
    python3 "$FIM_HELPER" "$operation" "$BASELINE_DB" "$config"
}
```

### Integrity verification

```bash
check_integrity() {
    # JSON output is format-aware; 0 unchanged, 1 changed, 2 unavailable/error.
    # Includes hash, size, mtime, permissions, UID/GID, additions and deletions.
    python3 "$FIM_HELPER" check "$BASELINE_DB"
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
    
    # inotify-tools with %0 NUL formatting and --no-newline is required.
    # Event flags are sets; moves and replacements trigger a full reconciliation.
    set -o pipefail
    inotifywait -m -r -e modify,create,delete,attrib,moved_from,moved_to,delete_self,move_self \
        --format '%T%0%w%f%0%e%0' --timefmt '%Y-%m-%dT%H:%M:%S%z' --no-newline \
        -- "${dirs[@]}" |
    while IFS= read -r -d '' timestamp && IFS= read -r -d '' path && IFS= read -r -d '' events; do
        if is_excluded "$path"; then continue; fi
        log_event "$timestamp" "$path" "$events"
        case ",$events," in
            *,MODIFY,*|*,CREATE,*|*,DELETE,*|*,ATTRIB,*|*,MOVED_FROM,*|*,MOVED_TO,*|*,DELETE_SELF,*|*,MOVE_SELF,*)
                local result=0
                check_integrity || result=$?
                case "$result" in 0) :;; 1) alert "Integrity changes detected; inspect structured report";; *) echo "Reconciliation unavailable" >&2; return 2;; esac
                ;;
        esac
    done
}
```

---

Queue overflow, watch-count limits, startup races and recursive directory creation
can lose events. Periodic full verification is required; an inotify loop alone
cannot certify a complete history. Validate installed inotify-tools capabilities
before starting; unsupported formatting must fail rather than fall back to
whitespace parsing.

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
