# S06_00_README - Previous Assignments Archive (Redistributed)

> **Operating Systems** | ASE Bucharest - CSIE
> Examples from previous years for reference

---

## IMPORTANT NOTE

These examples are for **reference and inspiration**. 
**DO NOT copy directly** - adapt and personalise!

---

## Contents

1. [HW01 - Simple Monitor](#hw01---simple-monitor)
2. [HW02 - Basic Backup](#hw02---basic-backup)
3. [HW03 - Log Analyser](#hw03---log-analyser)
4. [HW04 - File Organiser](#hw04---file-organiser)

---

## HW01 - Simple Monitor

**Year:** 2023-2024
**Original requirement:** Create a script that monitors CPU and memory

### Student Solution (Grade: 8/10)

```bash
#!/bin/bash
# monitor_simple.sh - Student solution
# Requirement: Monitor CPU and memory with alert

THRESHOLD_CPU=80
THRESHOLD_MEM=85

# Function for CPU
get_cpu() {
    top -bn1 | grep "Cpu(s)" | awk '{print $2}'
}

# Function for memory
get_mem() {
    free | awk '/Mem:/ {printf "%.0f", $3/$2 * 100}'
}

# Checks
cpu=$(get_cpu)
mem=$(get_mem)

echo "CPU: ${cpu}%"
echo "Memory: ${mem}%"

# Simple alerts
if (( ${cpu%.*} > THRESHOLD_CPU )); then
    echo "ALERT: CPU above threshold!"
fi

if (( mem > THRESHOLD_MEM )); then
    echo "ALERT: Memory above threshold!"
fi
```

### Instructor Feedback

**Strengths:**
- Separate functions for each metric
- Configurable thresholds
- Clear output

**To improve:**
- Missing `set -euo pipefail`
- CPU parsing may fail on other distributions
- Should have logging to file
- Missing input validation
- Exit codes not customised

### Improved Version

```bash
#!/usr/bin/env bash
# monitor_improved.sh - Corrected version
set -euo pipefail

readonly SCRIPT_NAME=$(basename "$0")
readonly LOG_FILE="/var/log/${SCRIPT_NAME%.sh}.log"
readonly THRESHOLD_CPU="${THRESHOLD_CPU:-80}"
readonly THRESHOLD_MEM="${THRESHOLD_MEM:-85}"

log() {
    printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*" | tee -a "$LOG_FILE"
}

get_cpu() {
    # More solid method using /proc/stat
    local cpu_line
    cpu_line=$(head -1 /proc/stat)
    
    local user nice system idle
    read -r _ user nice system idle _ <<< "$cpu_line"
    
    local total=$((user + nice + system + idle))
    local active=$((user + nice + system))
    
    echo $((active * 100 / total))
}

get_mem() {
    awk '/MemTotal:/ {total=$2} /MemAvailable:/ {avail=$2} 
         END {printf "%.0f", (1 - avail/total) * 100}' /proc/meminfo
}

main() {
    local cpu mem alerts=0
    
    cpu=$(get_cpu)
    mem=$(get_mem)
    
    log "CPU: ${cpu}% | Memory: ${mem}%"
    
    if ((cpu > THRESHOLD_CPU)); then
        log "ALERT: CPU ${cpu}% > ${THRESHOLD_CPU}%"
        ((alerts++))
    fi
    
    if ((mem > THRESHOLD_MEM)); then
        log "ALERT: Memory ${mem}% > ${THRESHOLD_MEM}%"
        ((alerts++))
    fi
    
    exit $alerts
}

main "$@"
```

---

## HW02 - Basic Backup

**Year:** 2023-2024
**Original requirement:** Backup script with compression and rotation

### Student Solution (Grade: 7/10)

```bash
#!/bin/bash
# backup.sh - Simple backup

SOURCE=$1
DEST="/backup"
DATE=$(date +%Y%m%d)

# Create backup
tar czf "$DEST/backup_$DATE.tar.gz" "$SOURCE"

# Delete old backups
find "$DEST" -name "*.tar.gz" -mtime +7 -delete

echo "Backup complete!"
```

### Instructor Feedback

**Strengths:**

Three things matter here: simple and functional, uses date in filename and automatic rotation.


**To improve:**
- Doesn't validate input
- Doesn't check if source exists
- No error handling
- Doesn't check available space
- Hardcoded destination

### Improved Version

```bash
#!/usr/bin/env bash
# backup_improved.sh - Corrected version
set -euo pipefail

readonly SCRIPT_NAME=$(basename "$0")

usage() {
    cat << EOF
Usage: $SCRIPT_NAME [OPTIONS] <source>

Options:
    -d, --dest DIR      Destination directory (default: /backup)
    -r, --retention N   Retention days (default: 7)
    -c, --compress ALG  Compression algorithm: gz, bz2, xz (default: gz)
    -h, --help          Display this message
EOF
    exit "${1:-0}"
}

log() { printf '[%s] %s\n' "$(date '+%H:%M:%S')" "$*"; }
die() { log "ERROR: $*" >&2; exit 1; }

# Defaults
DEST="/backup"
RETENTION=7
COMPRESS="gz"

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -d|--dest) DEST="$2"; shift 2 ;;
        -r|--retention) RETENTION="$2"; shift 2 ;;
        -c|--compress) COMPRESS="$2"; shift 2 ;;
        -h|--help) usage ;;
        -*) die "Unknown option: $1" ;;
        *) break ;;
    esac
done

SOURCE="${1:?Specify source directory}"

# Validations
[[ -d "$SOURCE" ]] || die "Source doesn't exist: $SOURCE"
[[ -d "$DEST" ]] || mkdir -p "$DEST"

# Space verification
source_size=$(du -s "$SOURCE" | awk '{print $1}')
dest_avail=$(df "$DEST" | awk 'NR==2 {print $4}')
((dest_avail > source_size * 2)) || die "Insufficient space in $DEST"

# Select compression extension
case "$COMPRESS" in
    gz)  TAR_OPT="z"; EXT="tar.gz" ;;
    bz2) TAR_OPT="j"; EXT="tar.bz2" ;;
    xz)  TAR_OPT="J"; EXT="tar.xz" ;;
    *)   die "Unknown compression: $COMPRESS" ;;
esac

# Create backup
BACKUP_FILE="$DEST/backup_$(date +%Y%m%d_%H%M%S).$EXT"
log "Creating backup: $BACKUP_FILE"

if tar c${TAR_OPT}f "$BACKUP_FILE" -C "$(dirname "$SOURCE")" "$(basename "$SOURCE")"; then
    log "Backup created: $(du -h "$BACKUP_FILE" | cut -f1)"
else
    die "Backup failed"
fi

# Rotation
deleted=$(find "$DEST" -name "backup_*.$EXT" -mtime +"$RETENTION" -delete -print | wc -l)
log "Deleted $deleted old backups"

log "Backup complete!"
```

---

## HW03 - Log Analyser

**Year:** 2022-2023
**Original requirement:** Analyse log files and generate report

### Student Solution (Grade: 9/10)

```bash
#!/usr/bin/env bash
# log_analyzer.sh - Log analyser
set -euo pipefail

LOG_FILE="${1:?Specify log file}"

[[ -f "$LOG_FILE" ]] || { echo "File doesn't exist: $LOG_FILE"; exit 1; }

echo "=== Analysis: $LOG_FILE ==="
echo ""

# Total lines
total=$(wc -l < "$LOG_FILE")
echo "Total entries: $total"
echo ""

# Errors
echo "=== ERRORS ==="
errors=$(grep -ci "error\|fail\|critical" "$LOG_FILE" || true)
echo "Errors found: $errors"

if ((errors > 0)); then
    echo "Top 5 errors:"
    grep -i "error\|fail\|critical" "$LOG_FILE" | 
        awk '{print $NF}' | 
        sort | uniq -c | sort -rn | head -5
fi
echo ""

# Warnings
echo "=== WARNINGS ==="
warnings=$(grep -ci "warn" "$LOG_FILE" || true)
echo "Warnings found: $warnings"
echo ""

# Top IPs (if web log)
echo "=== TOP IPs ==="
grep -oE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' "$LOG_FILE" 2>/dev/null |
    sort | uniq -c | sort -rn | head -10 || echo "No IPs found"
echo ""

# Distribution by hour
echo "=== HOURLY DISTRIBUTION ==="
grep -oE '[0-9]{2}:[0-9]{2}:[0-9]{2}' "$LOG_FILE" 2>/dev/null |
    cut -d: -f1 | sort | uniq -c | sort -k2n || echo "No timestamps found"

echo ""
echo "=== Analysis complete ==="
```

### Instructor Feedback

**Strengths:**
- Clear structure
- Multiple useful analyses
- Handling for when patterns not found
- `set -euo pipefail`

**To improve:**

Three things matter here: could generate html/json output, missing ascii graphs and could be parameterisable (which patterns to search).


---

## HW04 - File Organiser

**Year:** 2022-2023  
**Original requirement:** Organise files by extension/date

### Student Solution (Grade: 6/10)

```bash
#!/bin/bash
# organize.sh - File organiser

DIR=$1

for file in "$DIR"/*; do
    ext="${file##*.}"
    mkdir -p "$DIR/$ext"
    mv "$file" "$DIR/$ext/"
done

echo "Done!"
```

### Instructor Feedback

**Major Problems:**
1. Also moves directories (should have `-f` check)
2. Doesn't handle files without extension
3. Doesn't handle name conflicts
4. Also moves hidden files
5. No dry-run mode
6. Minimal feedback

### Improved Version

```bash
#!/usr/bin/env bash
# organize_improved.sh - Improved file organiser
set -euo pipefail

usage() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS] <directory>

Options:
    -m, --mode MODE     Organisation mode: ext|date|size (default: ext)
    -n, --dry-run       Simulation, doesn't move files
    -v, --verbose       Detailed output
    -h, --help          Display this message
    
Examples:
    $(basename "$0") ~/Downloads
    $(basename "$0") -m date -n ~/Pictures
EOF
    exit "${1:-0}"
}

log() { echo "[$(date '+%H:%M:%S')] $*"; }
verbose() { [[ "$VERBOSE" == true ]] && log "$*" || true; }

# Defaults
MODE="ext"
DRY_RUN=false
VERBOSE=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        -m|--mode) MODE="$2"; shift 2 ;;
        -n|--dry-run) DRY_RUN=true; shift ;;
        -v|--verbose) VERBOSE=true; shift ;;
        -h|--help) usage ;;
        -*) echo "Unknown option: $1" >&2; usage 1 ;;
        *) break ;;
    esac
done

DIR="${1:?Specify directory}"
[[ -d "$DIR" ]] || { echo "Directory doesn't exist: $DIR"; exit 1; }

# Functions for determining category
get_ext_category() {
    local file="$1"
    local ext="${file##*.}"
    
    # Files without extension
    [[ "$ext" == "$file" ]] && echo "no_extension" && return
    
    # Lowercase
    ext="${ext,,}"
    
    case "$ext" in
        jpg|jpeg|png|gif|bmp|svg|webp) echo "images" ;;
        mp3|wav|flac|ogg|m4a) echo "audio" ;;
        mp4|avi|mkv|mov|wmv) echo "video" ;;
        pdf|doc|docx|xls|xlsx|ppt|pptx|odt) echo "documents" ;;
        zip|tar|gz|rar|7z) echo "archives" ;;
        sh|py|js|c|cpp|java|go|rs) echo "code" ;;
        *) echo "other_$ext" ;;
    esac
}

get_date_category() {
    local file="$1"
    stat -c %y "$file" | cut -d' ' -f1 | tr -d '-'
}

get_size_category() {
    local file="$1"
    local size
    size=$(stat -c %s "$file")
    
    if ((size < 1024)); then
        echo "tiny_under_1K"
    elif ((size < 1048576)); then
        echo "small_under_1M"
    elif ((size < 104857600)); then
        echo "medium_under_100M"
    else
        echo "large_over_100M"
    fi
}

# Processing
moved=0
skipped=0

shopt -s nullglob  # Don't expand glob to literal if no match
for file in "$DIR"/*; do
    # Skip directories
    [[ -f "$file" ]] || continue
    
    # Skip hidden files
    [[ "$(basename "$file")" == .* ]] && continue
    
    # Determine category
    case "$MODE" in
        ext) category=$(get_ext_category "$file") ;;
        date) category=$(get_date_category "$file") ;;
        size) category=$(get_size_category "$file") ;;
        *) echo "Unknown mode: $MODE"; exit 1 ;;
    esac
    
    dest_dir="$DIR/$category"
    dest_file="$dest_dir/$(basename "$file")"
    
    # Conflict handling
    if [[ -e "$dest_file" ]]; then
        base="${dest_file%.*}"
        ext="${dest_file##*.}"
        counter=1
        while [[ -e "${base}_${counter}.${ext}" ]]; do
            ((counter++))
        done
        dest_file="${base}_${counter}.${ext}"
    fi
    
    verbose "  $file -> $dest_file"
    
    if [[ "$DRY_RUN" == false ]]; then
        mkdir -p "$dest_dir"
        mv "$file" "$dest_file"
        ((moved++))
    else
        ((moved++))  # Count for dry-run
    fi
done

log "Organisation complete: $moved files processed"
[[ "$DRY_RUN" == true ]] && log "(DRY-RUN - nothing was moved)"
```

---

## Lessons Learned from Common Mistakes

### 1. Quoting and Word Splitting
```bash
# WRONG
for file in $(ls *.txt); do ...

# CORRECT
for file in *.txt; do
    [[ -e "$file" ]] || continue
    ...
done
```

### 2. Unvalidated Variables
```bash
# WRONG
rm -rf $DIR/*

# CORRECT
[[ -n "$DIR" && -d "$DIR" ]] || exit 1
rm -rf "${DIR:?}"/*
```

### 3. Missing Error Handling
```bash
# WRONG
tar czf backup.tar.gz /data
echo "Done!"

# CORRECT
if ! tar czf backup.tar.gz /data 2>/dev/null; then
    echo "Backup FAILED!" >&2
    exit 1
fi
echo "Backup complete"
```

### 4. Hardcoded Paths
```bash
# WRONG
LOG_FILE="/home/student/logs/app.log"

# CORRECT
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
LOG_FILE="${LOG_DIR:-$SCRIPT_DIR/logs}/app.log"
```

### 5. Ignoring Exit Codes
```bash
# WRONG
command
echo "Continuing..."

# CORRECT
if ! command; then
    echo "Command failed" >&2
    exit 1
fi
```

---

*Previous Assignments Archive | Operating Systems | ASE Bucharest - CSIE*

---

*By Revolvix for OPERATING SYSTEMS class | restricted licence 2017-2030*
