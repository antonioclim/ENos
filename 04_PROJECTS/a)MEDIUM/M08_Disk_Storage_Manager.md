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

```bash
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
cleanup_temp() {
    local days="${1:-1}"
    local dry_run="${2:-true}"
    
    local temp_dirs=(/tmp /var/tmp "$HOME/.cache/tmp")
    
    for dir in "${temp_dirs[@]}"; do
        [[ -d "$dir" ]] || continue
        
        if [[ "$dry_run" == "true" ]]; then
            find "$dir" -type f -atime "+$days" -exec ls -lh {} \;
        else
            find "$dir" -type f -atime "+$days" -delete
        fi
    done
}

cleanup_logs() {
    local days="${1:-30}"
    local dry_run="${2:-true}"
    
    # Compressed logs
    if [[ "$dry_run" == "true" ]]; then
        find /var/log -name "*.gz" -mtime "+$days" -ls
    else
        find /var/log -name "*.gz" -mtime "+$days" -delete
    fi
    
    # Journald (keep last N days)
    if [[ "$dry_run" != "true" ]]; then
        sudo journalctl --vacuum-time="${days}d"
    fi
}

cleanup_package_cache() {
    local dry_run="${1:-true}"
    
    if [[ "$dry_run" == "true" ]]; then
        echo "APT cache: $(du -sh /var/cache/apt/archives 2>/dev/null | cut -f1)"
    else
        sudo apt-get clean
    fi
    
    # pip cache
    if command -v pip &>/dev/null; then
        if [[ "$dry_run" != "true" ]]; then
            pip cache purge
        fi
    fi
}
```

### Finding duplicates

```bash
find_duplicates() {
    local path="${1:-.}"
    local min_size="${2:-1M}"
    
    # Group files by size, then verify hash
    find "$path" -type f -size "+$min_size" -printf "%s %p\n" 2>/dev/null | \
        sort -n | \
        awk '{
            if ($1 == prev_size) {
                print prev_path
                print $2
            }
            prev_size = $1
            prev_path = $2
        }' | \
        xargs -I {} md5sum {} 2>/dev/null | \
        sort | \
        awk '{
            if ($1 == prev_hash) {
                print prev_path
                print $2
                dupes++
            }
            prev_hash = $1
            prev_path = $2
        }'
}

# Replace duplicates with hard links
deduplicate() {
    local file1="$1"
    local file2="$2"
    
    # Verify they are on the same filesystem
    local dev1 dev2
    dev1=$(stat -c '%d' "$file1")
    dev2=$(stat -c '%d' "$file2")
    
    if [[ "$dev1" != "$dev2" ]]; then
        echo "Files on different filesystems, cannot hard link"
        return 1
    fi
    
    # Create hard link
    rm "$file2"
    ln "$file1" "$file2"
}
```

### Usage prediction

```bash
predict_full_date() {
    local partition="$1"
    local db="$DISKMAN_DB"
    
    # Get data from last 30 days
    local data
    data=$(sqlite3 "$db" "
        SELECT date, used_bytes 
        FROM disk_usage 
        WHERE partition='$partition' 
        AND date > date('now', '-30 days')
        ORDER BY date
    ")
    
    # Calculate growth rate (simplified: linear regression)
    # In practice, use a Python script for more accurate calculation
    
    local growth_per_day
    growth_per_day=$(echo "$data" | awk -F'|' '
        NR==1 {first=$2; first_day=NR}
        END {
            diff = $2 - first
            days = NR - first_day
            if (days > 0) print diff / days
        }
    ')
    
    local free_bytes
    free_bytes=$(df --output=avail "$partition" | tail -1)
    
    local days_until_full
    days_until_full=$(echo "scale=0; $free_bytes / $growth_per_day" | bc)
    
    echo "$days_until_full"
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
