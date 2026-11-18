# M08: Disk Storage Manager

> **Level:** MEDIUM | **Estimated time:** 25-35 hours | **K8s Bonus:** +10%

---

## Description

Intelligent storage manager: real-time space monitoring, automatic cleanup (temporary files, cache, old logs), per-user/directory quota system, threshold alerting and prediction of when disk will be full.

---

## Learning Objectives

- Filesystem management (`df`, `du`, `find`, `quota`)
- Cleanup and maintenance automation
- Prediction and trend analysis
- Retention policy implementation
- Alerting and notifications

---

## Functional Requirements

### Mandatory (for passing grade)

1. **Space monitoring**
   - Status per partition (used/free/percentage)
   - Top consuming directories
   - Usage trend (daily/weekly growth)

2. **Automatic cleanup**
   - Temporary files (`/tmp`, `/var/tmp`)
   - Application cache (browser, package manager)
   - Old logs (based on retention policy)
   - Trash/Recycle bin

3. **Problematic file detection**
   - Large files (above threshold)
   - Duplicate files
   - Old unaccessed files

4. **Alerting**
   - Notification when usage exceeds threshold
   - Notification on abnormal growth rate
   - Email/desktop notifications

5. **Reporting**
   - Daily/weekly report
   - Usage history
   - CSV export

### Optional (for full marks)

6. **Quotas management** - Set and monitor quotas
7. **Predictive alerts** - Prediction of when disk will be full
8. **Deduplication** - Replace duplicates with hard links
9. **Compression** - Compress old files
10. **Web dashboard** - Browser visualisation

---

## CLI Interface

```text
./diskman.sh <command> [options]

Commands:
  status                Display current disk status
  analyze [path]        Analyse directory usage
  cleanup [profile]     Run cleanup (dry-run default)
  duplicates [path]     Find duplicate files
  large [path]          Find large files
  old [path]            Find old files
  report [period]       Generate usage report
  alert                 Check and send alerts
  daemon                Start continuous monitoring
  quota                 Quota management

Options:
  -t, --threshold PCT   Alert threshold (default: 80%)
  -s, --size SIZE       Minimum size for large files (default: 100M)
  -d, --days N          Days for old files (default: 90)
  -p, --profile PROF    Cleanup profile: minimal|standard|aggressive
  -f, --force           Execute cleanup (not just dry-run)
  -o, --output FILE     Save report
  -q, --quiet           Minimal output
  --no-color            No colours

Examples:
  ./diskman.sh status
  ./diskman.sh analyze /home --size 50M
  ./diskman.sh cleanup standard --force
  ./diskman.sh duplicates /home/user -o dupes.txt
  ./diskman.sh daemon --threshold 85
```

---

## Output Examples

Synthetic illustrations. Actual deletion plans must be generated from configured owned scopes and explicit exclusions; application state cannot be inferred from file age.

### Status Dashboard

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                    DISK STORAGE MANAGER                                      ║
║                    Host: server01 | Date: 2025-01-20                        ║
╚══════════════════════════════════════════════════════════════════════════════╝

PARTITION STATUS
═══════════════════════════════════════════════════════════════════════════════

/dev/sda1 mounted on /
┌──────────────────────────────────────────────────────────────────────────────┐
│ [████████████████████████████████████░░░░░░░░░░░░░░] 72% used               │
│ Used: 144 GB / 200 GB    Free: 56 GB    Inodes: 45% used                   │
│ Growth: +2.3 GB/week     Full in: ~24 weeks                                 │
└──────────────────────────────────────────────────────────────────────────────┘

/dev/sda2 mounted on /home
┌──────────────────────────────────────────────────────────────────────────────┐
│ [█████████████████████████████████████████████████░] 89% used  ⚠️ WARNING   │
│ Used: 445 GB / 500 GB    Free: 55 GB    Inodes: 23% used                   │
│ Growth: +8.1 GB/week     Full in: ~7 weeks  ⚠️                              │
└──────────────────────────────────────────────────────────────────────────────┘

/dev/sdb1 mounted on /data
┌──────────────────────────────────────────────────────────────────────────────┐
│ [█████████████████████████████████████████████████████████░░] 95% used 🔴   │
│ Used: 950 GB / 1 TB      Free: 50 GB     Inodes: 12% used                  │
│ Growth: +15 GB/week      Full in: ~3 weeks 🔴 CRITICAL                      │
└──────────────────────────────────────────────────────────────────────────────┘

TOP SPACE CONSUMERS (/home)
═══════════════════════════════════════════════════════════════════════════════
  1.  125 GB   /home/user1/Videos
  2.   89 GB   /home/user2/Downloads
  3.   67 GB   /home/user1/.cache
  4.   45 GB   /home/user3/Documents
  5.   34 GB   /home/user2/.local/share

CLEANUP RECOMMENDATIONS
═══════════════════════════════════════════════════════════════════════════════
  🗑️  Potential savings: 45.2 GB

  Category                Size      Files    Command
  ─────────────────────────────────────────────────────────────────────────────
  Package cache          12.3 GB    4,521    diskman.sh cleanup apt
  Logs > 30 days          8.7 GB      234    diskman.sh cleanup logs
  Trash                   6.2 GB    1,892    diskman.sh cleanup trash
  Browser cache           5.4 GB   12,456    diskman.sh cleanup browser
  Temp files              4.1 GB    3,211    diskman.sh cleanup temp
  Duplicate files         8.5 GB      156    diskman.sh duplicates --link

ALERTS
═══════════════════════════════════════════════════════════════════════════════
  🔴 /data at 95% - CRITICAL: Immediate action required
  ⚠️  /home at 89% - WARNING: Cleanup recommended
  ⚠️  /home will be full in 7 weeks at current growth rate
```

### Cleanup Report

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                    CLEANUP REPORT - Standard Profile                         ║
║                    Date: 2025-01-20 16:00:00                                ║
╚══════════════════════════════════════════════════════════════════════════════╝

DRY RUN MODE - No files were deleted
Run with --force to execute cleanup

CLEANUP SUMMARY
═══════════════════════════════════════════════════════════════════════════════

Category              Files      Size        Status
─────────────────────────────────────────────────────────────────────────────
Temp files             3,211     4.1 GB      [WILL DELETE]
  /tmp/*                 892     1.2 GB
  /var/tmp/*             456     0.8 GB
  ~/.cache/tmp/*       1,863     2.1 GB

Log files > 30d          234     8.7 GB      [WILL DELETE]
  /var/log/*.gz          123     5.2 GB
  /var/log/journal/*      89     2.8 GB
  Application logs        22     0.7 GB

Package cache          4,521    12.3 GB      [WILL DELETE]
  apt cache            2,345     8.1 GB
  pip cache            1,234     3.2 GB
  npm cache              942     1.0 GB

Trash                  1,892     6.2 GB      [WILL DELETE]
  ~/.local/share/Trash 1,892     6.2 GB

─────────────────────────────────────────────────────────────────────────────
TOTAL                  9,858    31.3 GB

⚠️  The following will NOT be cleaned (excluded):
  - Files modified in last 24 hours
  - System logs for current month
  - Application state files

To execute: ./diskman.sh cleanup standard --force
```

---

## Configuration File

```yaml
# /etc/diskman.conf
general:
  check_interval: 3600    # Seconds
  log_file: /var/log/diskman.log

thresholds:
  warning: 80
  critical: 90
  growth_alert: 10        # GB/week

alerts:
  email:
    enabled: true
    to: admin@example.com
  desktop:
    enabled: true

cleanup_profiles:
  minimal:
    - temp_files: 7d
    - trash: 30d
    
  standard:
    - temp_files: 1d
    - trash: 7d
    - logs: 30d
    - apt_cache: all
    - pip_cache: all
    
  aggressive:
    - temp_files: 0d
    - trash: 0d
    - logs: 7d
    - all_caches: all
    - thumbnails: all

paths:
  temp:
    - /tmp
    - /var/tmp
    - ~/.cache/tmp
  logs:
    - /var/log
  cache:
    apt: /var/cache/apt/archives
    pip: ~/.cache/pip
    npm: ~/.npm/_cacache
```

---

## Project Structure

```
M08_Disk_Storage_Manager/
├── README.md
├── Makefile
├── src/
│   ├── diskman.sh               # Main script
│   └── lib/
│       ├── analyze.sh           # Usage analysis
│       ├── cleanup.sh           # Cleanup functions
│       ├── duplicates.sh        # Duplicate detection
│       ├── alerts.sh            # Alerting system
│       ├── predict.sh           # Usage prediction
│       ├── quota.sh             # Quota management
│       └── report.sh            # Report generation
├── etc/
│   ├── diskman.conf
│   └── profiles/
│       ├── minimal.conf
│       ├── standard.conf
│       └── aggressive.conf
├── tests/
│   ├── test_analyze.sh
│   ├── test_cleanup.sh
│   └── test_data/
└── docs/
    ├── INSTALL.md
    └── PROFILES.md
```

---

## Implementation Hints

### Disk space analysis

```bash
get_partition_usage() {
    df -h --output=source,target,size,used,avail,pcent | tail -n +2
}

get_top_directories() {
    local path="${1:-.}"
    local count="${2:-10}"
    
    du -h --max-depth=1 "$path" 2>/dev/null | sort -rh | head -n "$count"
}

get_large_files() {
    local path="${1:-.}"
    local min_size="${2:-100M}"
    
    find "$path" -type f -size "+${min_size}" -exec ls -lh {} \; 2>/dev/null | \
        awk '{print $5, $9}' | sort -rh
}
```

### Cleanup functions

```bash
# Preview and execution consume the same NUL-delimited candidate plan.
# Caller supplies owned/quiescent roots and explicit state-file exclusions.
# Global recent-file/current-month/state exclusions win over every profile,
# including 'aggressive'; no implicit override is allowed by these helpers.
cleanup_scope() (
    local directory="$1" days="$2" dry_run="$3" kind="$4" plan file cutoff month_start
    [[ $days =~ ^[0-9]+$ && ( $dry_run == true || $dry_run == false ) ]] || return 2
    [[ -d "$directory" && ! -L "$directory" && "$directory" != / ]] || return 2
    [[ -r ${STATE_EXCLUDE_FILE:-} ]] || { echo "State-file exclusion list required" >&2; return 2; }
    cutoff=$(( $(date +%s) - days*86400 ))
    month_start=$(date -d "$(date +%Y-%m)-01 00:00:00" +%s) || return 1
    plan=$(mktemp) || return 1
    trap 'rm -f -- "$plan"' EXIT
    local -a excludes=()
    while IFS= read -r pattern; do [[ -z "$pattern" ]] || excludes+=(! -path "$pattern"); done < "$STATE_EXCLUDE_FILE"
    # GNU find compares exact timestamps; no +N day-rounding ambiguity.
    local -a predicates=(-type f -uid "$UID" ! -newermt "@$cutoff" ! -newermt '24 hours ago')
    if [[ $kind == logs ]]; then predicates+=(-name '*.gz' ! -newermt "@$month_start"); fi
    find "$directory" -xdev "${predicates[@]}" "${excludes[@]}" -print0 > "$plan" || return 1
    while IFS= read -r -d '' file; do
        if [[ $dry_run == true ]]; then printf 'Would delete: %q\n' "$file"
        else rm -- "$file" || return 1
        fi
    done < "$plan"
)

cleanup_temp() {
    local days="${1:-1}" dry_run="${2:-true}" directory
    [[ ${#TEMP_DIRS[@]} -gt 0 ]] || return 2
    for directory in "${TEMP_DIRS[@]}"; do cleanup_scope "$directory" "$days" "$dry_run" temp || return 1; done
}

cleanup_logs() {
    local days="${1:-30}" dry_run="${2:-true}" directory
    [[ ${#LOG_DIRS[@]} -gt 0 ]] || return 2
    for directory in "${LOG_DIRS[@]}"; do cleanup_scope "$directory" "$days" "$dry_run" logs || return 1; done
    printf 'Journald vacuum is a separate explicit action; not performed by this file plan.\n'
}

cleanup_package_cache() {
    local dry_run="${1:-true}"
    printf 'Action plan: apt-get clean; pip cache purge (configured current user).\n'
    [[ $dry_run == false ]] || return 0
    # Explicit action selection; no privilege escalation is hidden in this helper.
    [[ ${ALLOW_PACKAGE_CACHE_ACTIONS:-false} == true ]] || return 2
    apt-get clean || return 1
    if command -v pip >/dev/null; then pip cache purge || return 1; fi
}
```

### Finding duplicates

```bash
find_duplicates() {
    local path="${1:-.}" min_size="${2:-1048576}"  # Explicit bytes, not find size syntax.
    python3 - "$path" "$min_size" <<'PYDUP'
import collections, filecmp, hashlib, json, os, sys
from pathlib import Path
minimum=int(sys.argv[2]); assert minimum>=0
sizes=collections.defaultdict(list); seen=set()
for directory, _, names in os.walk(sys.argv[1], followlinks=False):
    for name in names:
        path=Path(directory)/name
        if path.is_symlink() or not path.is_file(): continue
        st=path.stat(); identity=(st.st_dev,st.st_ino)
        if identity in seen or st.st_size<minimum: continue
        seen.add(identity); sizes[st.st_size].append(path)
for size, paths in sizes.items():
    if len(paths)<2: continue
    hashes=collections.defaultdict(list)
    for path in paths:
        with path.open('rb') as stream: digest=hashlib.file_digest(stream,'sha256').hexdigest()
        hashes[digest].append(path)
    for digest, group in hashes.items():
        while group:
            first,*rest=group
            identical=[path for path in rest if filecmp.cmp(first,path,shallow=False)]
            if identical: print(json.dumps({'sha256':digest,'size_bytes':size,'paths':[str(first),*map(str,identical)]}))
            group=[path for path in rest if path not in identical]
PYDUP
}

# Only in a quiescent, explicitly approved scope: a hard link shares future writes
# and inode metadata. Different ownership/modes/ACLs/timestamps require a policy decision.
deduplicate() (
    local file1="$1" file2="$2" stage
    [[ -f "$file1" && -f "$file2" && ! -L "$file1" && ! -L "$file2" ]] || return 2
    [[ ! "$file1" -ef "$file2" ]] || return 2
    [[ $(stat -c '%d:%u:%g:%a:%y' -- "$file1") == "$(stat -c '%d:%u:%g:%a:%y' -- "$file2")" ]] || return 2
    cmp -s -- "$file1" "$file2" || return 1
    # Extended attributes (including POSIX ACLs) must match too.
    python3 - "$file1" "$file2" <<'PYMETA'
import os, sys
def attrs(path): return {name:os.getxattr(path,name) for name in os.listxattr(path)}
raise SystemExit(0 if attrs(sys.argv[1])==attrs(sys.argv[2]) else 1)
PYMETA
    [[ $? -eq 0 ]] || return 2
    stage=$(mktemp -d "$(dirname -- "$file2")/.dedup.XXXXXX") || return 1
    trap 'rm -rf -- "$stage"' EXIT
    ln -- "$file1" "$stage/replacement" || return 1
    cmp -s -- "$file1" "$file2" || return 1
    mv -Tf -- "$stage/replacement" "$file2" || return 1
)
```

### Usage prediction

```bash
predict_full_date() {
    local partition="$1" free_bytes
    free_bytes=$(df -B1 --output=avail -- "$partition" | awk 'NR==2 {print $1}') || return 1
    [[ $free_bytes =~ ^[0-9]+$ ]] || return 1
    python3 - "$DISKMAN_DB" "$partition" "$free_bytes" <<'PYPREDICT'
import datetime as dt, math, sqlite3, sys
with sqlite3.connect(sys.argv[1]) as db:
    rows=db.execute("SELECT date,used_bytes FROM disk_usage WHERE partition=? AND date>date('now','-30 days') ORDER BY date",(sys.argv[2],)).fetchall()
if len(rows)<2: raise SystemExit("Unavailable: fewer than two samples")
first,last=rows[0],rows[-1]
days=(dt.datetime.fromisoformat(last[0])-dt.datetime.fromisoformat(first[0])).total_seconds()/86400
if days<=0: raise SystemExit("Unavailable: no elapsed time")
growth=(last[1]-first[1])/days
if not math.isfinite(growth) or growth<=0: raise SystemExit("No finite positive-growth forecast")
print(f"{int(sys.argv[3])/growth:.2f} days (endpoint slope, constant-growth assumption)")
PYPREDICT
}
```

---

## Specific Evaluation Criteria

| Criterion | Weight | Description |
|-----------|--------|-------------|
| Space monitoring | 15% | Correct status, top consumers |
| Functional cleanup | 25% | Temp, logs, cache - with dry-run |
| Problem detection | 15% | Large files, duplicates, old files |
| Alerting | 15% | Threshold, email/desktop |
| Prediction | 10% | Trend, full date estimation |
| Extra features | 10% | Quotas, dedup, compression |
| Code quality + tests | 5% | ShellCheck, tests |
| Documentation | 5% | README, profiles doc |

---

## Resources

- `man df`, `man du`, `man find`
- `man quota`, `man edquota`
- Seminar 2-3 - find commands, text processing

---

*MEDIUM Project | Operating Systems | ASE-CSIE*
