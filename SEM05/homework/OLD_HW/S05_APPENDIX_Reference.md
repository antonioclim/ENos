# S05_APPENDIX - Seminar 5 Reference (Redistributed)

> **Operating Systems** | ASE Bucharest - CSIE  
> Supplementary material - Advanced Scripting

---

## ASCII Diagrams

### Structure of a Professional Script

```
┌──────────────────────────────────────────────────────────────────────┐
│                  ANATOMY OF A PROFESSIONAL BASH SCRIPT               │
├──────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  #!/bin/bash                           ← SHEBANG (mandatory)        │
│  #                                                                   │
│  # Script: name.sh                     ← HEADER                      │
│  # Description: What it does           │ Documentation              │
│  # Author: Name                        │                             │
│  # Version: 1.0.0                      │                             │
│  # Date: 2025-01-10                    │                             │
│  #                                     ◄─────────────────────────────┤
│                                                                      │
│  set -euo pipefail                     ← SAFETY OPTIONS             │
│  IFS=$'\n\t'                           │ Prevents common errors      │
│                                        ◄─────────────────────────────┤
│                                                                      │
│  # === CONSTANTS ===                   ← CONSTANTS                   │
│  readonly VERSION="1.0.0"              │ Cannot be modified          │
│  readonly SCRIPT_DIR=$(...)            │                             │
│                                        ◄─────────────────────────────┤
│                                                                      │
│  # === GLOBALS ===                     ← GLOBAL VARIABLES            │
│  VERBOSE=false                         │ With default values         │
│  OUTPUT=""                             │                             │
│                                        ◄─────────────────────────────┤
│                                                                      │
│  # === FUNCTIONS ===                   ← FUNCTIONS                   │
│  usage() { ... }                       │ Helper functions            │
│  log() { ... }                         │ (defined before             │
│  die() { ... }                         │ usage)                      │
│  cleanup() { ... }                     │                             │
│  parse_args() { ... }                  │                             │
│  validate() { ... }                    │                             │
│  process() { ... }                     │                             │
│                                        ◄─────────────────────────────┤
│                                                                      │
│  # === TRAPS ===                       ← ERROR HANDLING              │
│  trap cleanup EXIT                     │ Automatic cleanup           │
│  trap 'die "Interrupted"' INT TERM     │ Handle signals              │
│                                        ◄─────────────────────────────┤
│                                                                      │
│  # === MAIN ===                        ← ENTRY POINT                 │
│  main() {                              │                             │
│      parse_args "$@"                   │ 1. Parse arguments          │
│      validate                          │ 2. Validation               │
│      process                           │ 3. Main logic               │
│  }                                     │                             │
│                                        │                             │
│  main "$@"                             ← INVOKE MAIN                 │
│                                                                      │
└──────────────────────────────────────────────────────────────────────┘
```

### Signal Handling and Trap

```
┌──────────────────────────────────────────────────────────────────────┐
│                        SIGNAL HANDLING                               │
├──────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  ┌─────────────┐     ┌─────────────┐     ┌─────────────────────┐    │
│  │   SIGNAL    │────►│    TRAP     │────►│      HANDLER        │    │
│  └─────────────┘     └─────────────┘     └─────────────────────┘    │
│                                                                      │
│  COMMON SIGNALS:                                                     │
│  ┌────────┬───────────────────────────────────────────────────────┐ │
│  │ SIGINT │ Ctrl+C - Interactive interruption                     │ │
│  │ (2)    │ trap 'echo "Interrupted"; exit 130' INT               │ │
│  ├────────┼───────────────────────────────────────────────────────┤ │
│  │ SIGTERM│ Default kill - Graceful termination                   │ │
│  │ (15)   │ trap cleanup TERM                                     │ │
│  ├────────┼───────────────────────────────────────────────────────┤ │
│  │ SIGKILL│ Kill -9 - CANNOT BE CAUGHT                            │ │
│  │ (9)    │ No trap exists for SIGKILL                            │ │
│  ├────────┼───────────────────────────────────────────────────────┤ │
│  │ SIGHUP │ Terminal closed                                       │ │
│  │ (1)    │ trap 'reload_config' HUP                              │ │
│  ├────────┼───────────────────────────────────────────────────────┤ │
│  │ EXIT   │ Pseudo-signal - On script exit                        │ │
│  │        │ trap cleanup EXIT  (executes ALWAYS)                  │ │
│  ├────────┼───────────────────────────────────────────────────────┤ │
│  │ ERR    │ Pseudo-signal - On error (with set -e)                │ │
│  │        │ trap 'error_handler $LINENO' ERR                      │ │
│  ├────────┼───────────────────────────────────────────────────────┤ │
│  │ DEBUG  │ Pseudo-signal - On every command                      │ │
│  │        │ trap 'echo "Line $LINENO: $BASH_COMMAND"' DEBUG       │ │
│  └────────┴───────────────────────────────────────────────────────┘ │
│                                                                      │
│  COMPLETE PATTERN:                                                   │
│  ┌────────────────────────────────────────────────────────────────┐ │
│  │  cleanup() {                                                   │ │
│  │      local exit_code=$?                                        │ │
│  │      echo "Cleanup: removing temp files..."                    │ │
│  │      rm -rf "$TEMP_DIR"                                        │ │
│  │      exit $exit_code  # Preserve original exit code            │ │
│  │  }                                                             │ │
│  │                                                                │ │
│  │  trap cleanup EXIT          # Cleanup on any exit              │ │
│  │  trap 'exit 130' INT        # Ctrl+C                           │ │
│  │  trap 'exit 143' TERM       # kill                             │ │
│  └────────────────────────────────────────────────────────────────┘ │
│                                                                      │
└──────────────────────────────────────────────────────────────────────┘
```

### Arrays in Bash

```
┌──────────────────────────────────────────────────────────────────────┐
│                        BASH ARRAYS                                   │
├──────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  INDEXED ARRAYS (numeric):                                           │
│  ┌────────────────────────────────────────────────────────────────┐ │
│  │  arr=(apple banana cherry)                                     │ │
│  │        │      │       │                                        │ │
│  │        ▼      ▼       ▼                                        │ │
│  │      [0]    [1]     [2]                                        │ │
│  │                                                                │ │
│  │  ${arr[0]}     → "apple"        First element                  │ │
│  │  ${arr[-1]}    → "cherry"       Last (Bash 4.3+)               │ │
│  │  ${arr[@]}     → all elements (as list)                        │ │
│  │  ${#arr[@]}    → 3              Length                         │ │
│  │  ${!arr[@]}    → 0 1 2          Indices                        │ │
│  │  ${arr[@]:1:2} → banana cherry  Slice                          │ │
│  └────────────────────────────────────────────────────────────────┘ │
│                                                                      │
│  ASSOCIATIVE ARRAYS (hash/dict):                                     │
│  ┌────────────────────────────────────────────────────────────────┐ │
│  │  declare -A config                    # MANDATORY!             │ │
│  │                                                                │ │
│  │  config[host]="localhost"             ┌─────────┬────────────┐ │ │
│  │  config[port]="8080"                  │   KEY   │   VALUE    │ │ │
│  │  config[debug]="true"                 ├─────────┼────────────┤ │ │
│  │                                       │ "host"  │"localhost" │ │ │
│  │  ${config[host]}  → "localhost"       │ "port"  │  "8080"    │ │ │
│  │  ${!config[@]}    → host port debug   │ "debug" │  "true"    │ │ │
│  │  ${config[@]}     → all values        └─────────┴────────────┘ │ │
│  │  ${#config[@]}    → 3                                          │ │
│  └────────────────────────────────────────────────────────────────┘ │
│                                                                      │
│  ARRAY OPERATIONS:                                                   │
│  ┌────────────────────────────────────────────────────────────────┐ │
│  │                                                                │ │
│  │  ADDING:                                                       │ │
│  │  arr+=(date)              # Append                             │ │
│  │  arr[${#arr[@]}]="date"   # Explicit append                    │ │
│  │  arr[10]="fig"            # At specific index (sparse)         │ │
│  │                                                                │ │
│  │  DELETING:                                                     │ │
│  │  unset arr[1]             # Delete element (becomes sparse)    │ │
│  │  arr=("${arr[@]:0:1}" "${arr[@]:2}")  # Delete and compact    │ │
│  │  unset arr                # Delete entire array                │ │
│  │                                                                │ │
│  │  ITERATING:                                                    │ │
│  │  for item in "${arr[@]}"; do echo "$item"; done                │ │
│  │  for i in "${!arr[@]}"; do echo "[$i]=${arr[$i]}"; done        │ │
│  │                                                                │ │
│  └────────────────────────────────────────────────────────────────┘ │
│                                                                      │
└──────────────────────────────────────────────────────────────────────┘
```

---

## Complete Solved Exercises

### Exercise 1: Modular Logging System

```bash
#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════════
# logging.sh — Reusable Logging Module
# ═══════════════════════════════════════════════════════════════════════════════
# Operating Systems | ASE Bucharest - CSIE
#
# USAGE (as module):
#   source logging.sh
#   log_init "app.log" "DEBUG"
#   log_info "Application started"
#   log_error "Connection failed"
#
# FEATURES:
#   - Log levels: DEBUG, INFO, WARN, ERROR
#   - Coloured output for terminal
#   - Timestamps and source file:line
#   - Rotation by size
# ═══════════════════════════════════════════════════════════════════════════════

# === CONFIGURATION ===
declare -A LOG_LEVELS=([DEBUG]=0 [INFO]=1 [WARN]=2 [ERROR]=3)
declare -A LOG_COLOURS=([DEBUG]='\033[0;36m' [INFO]='\033[0;32m' [WARN]='\033[1;33m' [ERROR]='\033[0;31m')
readonly LOG_NC='\033[0m'

# Global state (set by log_init)
_LOG_FILE=""
_LOG_LEVEL="INFO"
_LOG_MAX_SIZE=$((10 * 1024 * 1024))  # 10MB default

# === INITIALISATION ===
log_init() {
    local file="${1:-/dev/null}"
    local level="${2:-INFO}"
    local max_size="${3:-$((10 * 1024 * 1024))}"
    
    _LOG_FILE="$file"
    _LOG_LEVEL="${level^^}"
    _LOG_MAX_SIZE="$max_size"
    
    # Create directory if it doesn't exist
    [[ -n "$_LOG_FILE" && "$_LOG_FILE" != "/dev/null" ]] && mkdir -p "$(dirname "$_LOG_FILE")"
    
    log_debug "Logger initialised: file=$_LOG_FILE, level=$_LOG_LEVEL"
}

# === INTERNAL FUNCTION ===
_log() {
    local level="$1"
    local message="$2"
    local level_num="${LOG_LEVELS[$level]:-1}"
    local current_level_num="${LOG_LEVELS[$_LOG_LEVEL]:-1}"
    
    # Level check
    (( level_num < current_level_num )) && return 0
    
    # Rotation
    _log_rotate
    
    # Formatting
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local caller="${BASH_SOURCE[2]:-unknown}:${BASH_LINENO[1]:-0}"
    local formatted="[$timestamp] [$level] [$caller] $message"
    
    # Write to file
    [[ -n "$_LOG_FILE" && "$_LOG_FILE" != "/dev/null" ]] && echo "$formatted" >> "$_LOG_FILE"
    
    # Display on terminal (with colours if TTY)
    if [[ -t 2 ]]; then
        echo -e "${LOG_COLOURS[$level]}${formatted}${LOG_NC}" >&2
    else
        echo "$formatted" >&2
    fi
}

# Public functions
log_debug() { _log "DEBUG" "$*"; }
log_info()  { _log "INFO"  "$*"; }
log_warn()  { _log "WARN"  "$*"; }
log_error() { _log "ERROR" "$*"; }

# === ROTATION ===
_log_rotate() {
    [[ -z "$_LOG_FILE" || "$_LOG_FILE" == "/dev/null" ]] && return
    [[ ! -f "$_LOG_FILE" ]] && return
    
    local size=$(stat -f%z "$_LOG_FILE" 2>/dev/null || stat -c%s "$_LOG_FILE" 2>/dev/null || echo 0)
    
    if (( size > _LOG_MAX_SIZE )); then
        local backup="${_LOG_FILE}.$(date +%Y%m%d_%H%M%S).bak"
        mv "$_LOG_FILE" "$backup"
        log_info "Log rotated to: $backup"
        
        # Keep only last 5 backups
        ls -t "${_LOG_FILE}".*.bak 2>/dev/null | tail -n +6 | xargs -r rm
    fi
}

# === EXPORT FOR USE AS MODULE ===
# If sourced, exports functions. If executed, does nothing.
[[ "${BASH_SOURCE[0]}" == "${0}" ]] && echo "This file should be sourced, not executed."
```

### Exercise 2: System Monitor with Alerts

```bash
#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════════
# monitor.sh — System Monitor with Alerts
# ═══════════════════════════════════════════════════════════════════════════════
# Operating Systems | ASE Bucharest - CSIE
#
# USAGE:
#   ./monitor.sh                    # Continuous monitoring
#   ./monitor.sh -1                 # Single run
#   ./monitor.sh -i 10              # Check every 10 seconds
#   ./monitor.sh -f json            # JSON output
#   ./monitor.sh -c 90 -m 85        # Custom thresholds
#
# FEATURES:
#   - CPU, Memory, Disk monitoring
#   - Configurable thresholds
#   - Multiple output formats (text, JSON, CSV)
#   - External alert command
# ═══════════════════════════════════════════════════════════════════════════════

set -euo pipefail

# === DEFAULTS ===
INTERVAL=5
THRESHOLD_CPU=80
THRESHOLD_MEM=80
THRESHOLD_DISK=90
OUTPUT_FORMAT="text"
ALERT_CMD=""
LOG_FILE=""

# === USAGE ===
usage() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS]

Options:
    -i, --interval SEC     Check interval (default: 5)
    -c, --cpu PCT          CPU threshold (default: 80)
    -m, --memory PCT       Memory threshold (default: 80)
    -d, --disk PCT         Disk threshold (default: 90)
    -f, --format FORMAT    Output format: text|json|csv (default: text)
    -a, --alert CMD        Command to run on alert
    -l, --log FILE         Log to file
    -1, --once             Run only once
    -h, --help             Show this help

Examples:
    $(basename "$0") -i 10 -c 90 -f json
    $(basename "$0") -a "notify-send 'Alert!'"
EOF
}

# === HELPER FUNCTIONS ===
log() {
    local msg="[$(date '+%H:%M:%S')] $*"
    [[ -n "$LOG_FILE" ]] && echo "$msg" >> "$LOG_FILE"
}

send_alert() {
    local message="$1"
    [[ -z "$ALERT_CMD" ]] && return
    eval "$ALERT_CMD \"$message\"" || true
}

# === MONITORING FUNCTIONS ===
get_cpu_usage() {
    # Average over last seconds
    local idle=$(top -bn2 -d0.5 | grep "Cpu(s)" | tail -1 | awk -F',' '{print $4}' | awk '{print $1}')
    echo "scale=0; 100 - $idle" | bc
}

get_memory_usage() {
    free | awk '/Mem:/ { printf "%.0f", $3/$2 * 100 }'
}

get_disk_usage() {
    df -h / | awk 'NR==2 { gsub(/%/,""); print $5 }'
}

get_load_average() {
    cat /proc/loadavg | awk '{ print $1 }'
}

get_process_count() {
    ps aux | wc -l
}

# === OUTPUT FORMATTERS ===
output_text() {
    local cpu=$1 mem=$2 disk=$3 load=$4 procs=$5
    
    echo "=== Monitor Report $(date '+%Y-%m-%d %H:%M:%S') ==="
    printf "CPU Usage:     %3d%% %s\n" "$cpu" "$( (( cpu > THRESHOLD_CPU )) && echo '[ALERT]' || echo '[OK]')"
    printf "Memory Usage:  %3d%% %s\n" "$mem" "$( (( mem > THRESHOLD_MEM )) && echo '[ALERT]' || echo '[OK]')"
    printf "Disk Usage:    %3d%% %s\n" "$disk" "$( (( disk > THRESHOLD_DISK )) && echo '[ALERT]' || echo '[OK]')"
    printf "Load Average:  %s\n" "$load"
    printf "Processes:     %s\n" "$procs"
    echo ""
}

output_json() {
    local cpu=$1 mem=$2 disk=$3 load=$4 procs=$5
    local timestamp=$(date -Iseconds)
    
    cat << EOF
{
    "timestamp": "$timestamp",
    "metrics": {
        "cpu": { "value": $cpu, "threshold": $THRESHOLD_CPU, "alert": $(( cpu > THRESHOLD_CPU ? 1 : 0 )) },
        "memory": { "value": $mem, "threshold": $THRESHOLD_MEM, "alert": $(( mem > THRESHOLD_MEM ? 1 : 0 )) },
        "disk": { "value": $disk, "threshold": $THRESHOLD_DISK, "alert": $(( disk > THRESHOLD_DISK ? 1 : 0 )) },
        "load": $load,
        "processes": $procs
    }
}
EOF
}

output_csv() {
    local cpu=$1 mem=$2 disk=$3 load=$4 procs=$5
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    # Header on first run
    [[ ! -f "$LOG_FILE" ]] && echo "timestamp,cpu,memory,disk,load,processes"
    echo "$timestamp,$cpu,$mem,$disk,$load,$procs"
}

# === CHECK ===
check_alerts() {
    local cpu=$1 mem=$2 disk=$3
    local alerts=()
    
    (( cpu > THRESHOLD_CPU )) && alerts+=("CPU at ${cpu}% (threshold: ${THRESHOLD_CPU}%)")
    (( mem > THRESHOLD_MEM )) && alerts+=("Memory at ${mem}% (threshold: ${THRESHOLD_MEM}%)")
    (( disk > THRESHOLD_DISK )) && alerts+=("Disk at ${disk}% (threshold: ${THRESHOLD_DISK}%)")
    
    if [[ ${#alerts[@]} -gt 0 ]]; then
        local message="ALERT on $(hostname) at $(date):\n"
        for alert in "${alerts[@]}"; do
            message+="- $alert\n"
        done
        log "ALERTS: ${alerts[*]}"
        send_alert "$(echo -e "$message")"
        return 1
    fi
    return 0
}

# === MAIN LOOP ===
monitor_once() {
    local cpu=$(get_cpu_usage)
    local mem=$(get_memory_usage)
    local disk=$(get_disk_usage)
    local load=$(get_load_average)
    local procs=$(get_process_count)
    
    case $OUTPUT_FORMAT in
        json) output_json "$cpu" "$mem" "$disk" "$load" "$procs" ;;
        csv)  output_csv "$cpu" "$mem" "$disk" "$load" "$procs" ;;
        *)    output_text "$cpu" "$mem" "$disk" "$load" "$procs" ;;
    esac
    
    check_alerts "$cpu" "$mem" "$disk" || true
}

# === ARGUMENT PARSING ===
ONCE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help) usage; exit 0 ;;
        -i|--interval) INTERVAL="$2"; shift 2 ;;
        -c|--cpu) THRESHOLD_CPU="$2"; shift 2 ;;
        -m|--memory) THRESHOLD_MEM="$2"; shift 2 ;;
        -d|--disk) THRESHOLD_DISK="$2"; shift 2 ;;
        -f|--format) OUTPUT_FORMAT="$2"; shift 2 ;;
        -a|--alert) ALERT_CMD="$2"; shift 2 ;;
        -l|--log) LOG_FILE="$2"; shift 2 ;;
        -1|--once) ONCE=true; shift ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
done

# === RUN ===
if $ONCE; then
    monitor_once
else
    log "Starting monitor (interval: ${INTERVAL}s)"
    while true; do
        monitor_once
        sleep "$INTERVAL"
    done
fi
```

---

## Quick Reference

### Standard Exit Codes

| Code | Meaning |
|------|---------|
| 0 | Success |
| 1 | General error |
| 2 | Incorrect usage |
| 126 | Command not executable |
| 127 | Command not found |
| 128+N | Fatal signal N |
| 130 | Ctrl+C (SIGINT) |
| 143 | SIGTERM |

### Test Operators

```bash
# Files
-e    exists
-f    regular file
-d    directory
-s    size > 0
-r    readable
-w    writable
-x    executable

# Strings
-z    empty
-n    non-empty
=     equal
!=    not equal

# Numbers
-eq   equal
-ne   not equal
-lt   less than
-gt   greater than
```

---
*Supplementary material for Operating Systems course | ASE Bucharest - CSIE*

---

*By Revolvix for OPERATING SYSTEMS class | restricted licence 2017-2030*
