# Monitor Project - Detailed Implementation

## Contents

1. [General Overview](#1-general-overview)
2. [Modular Architecture](#2-modular-architecture)
3. [Core Module - monitor_core.sh](#3-core-module---monitor_coresh)
4. [Utilities Module - monitor_utils.sh](#4-utilities-module---monitor_utilssh)
5. [Configuration Module - monitor_config.sh](#5-configuration-module---monitor_configsh)
6. [Main Script - monitor.sh](#6-main-script---monitorsh)
7. [Execution Flow](#7-execution-flow)
8. [Advanced Monitoring Techniques](#8-advanced-monitoring-techniques)
9. [Implementation Exercises](#9-implementation-exercises)

---

## 1. General Overview

### 1.1 Project Purpose

The **Monitor** project represents a complete system resource monitoring solution, built entirely in Bash. The system offers capabilities for:

- **CPU Monitoring**: per-core and aggregated utilisation, load average, consuming processes
- **Memory Monitoring**: used/available RAM, swap, cache, buffers
- **Disk Monitoring**: space used, I/O operations, latency
- **Process Monitoring**: top consumers, zombie processes, thread count
- **Alerting**: configurable threshold system with notifications
- **Reporting**: output in multiple formats (text, JSON, CSV)

### 1.2 File Structure

```
projects/monitor/
├── monitor.sh              # Main script (~800 lines)
├── lib/
│   ├── monitor_core.sh     # Monitoring functions (~600 lines)
│   ├── monitor_utils.sh    # Common utilities (~400 lines)
│   └── monitor_config.sh   # Configuration management (~300 lines)
└── config/
    └── monitor.conf        # Default configuration
```

### 1.3 Design Principles

The implementation follows fundamental software engineering principles:

**Separation of Concerns**
Each module has a clearly defined responsibility. `monitor_core.sh` manages metric collection exclusively, `monitor_utils.sh` offers auxiliary functions, and `monitor_config.sh` handles configuration.

**Modularity and Reusability**
Functions are designed to be reused in different contexts. For example, `format_bytes()` from utilities is used for both memory and disk space display.

**Fail-Safe Design**
The system gracefully handles error situations, providing default values and continuing execution even when certain data sources are unavailable.

---

## 2. Modular Architecture

### 2.1 Dependency Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                        monitor.sh                                │
│                    (Main Script)                                 │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────────┐  │
│  │   main()    │──│ parse_args()│──│ run_monitoring_cycle() │  │
│  └─────────────┘  └─────────────┘  └─────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
              │                │                    │
              ▼                ▼                    ▼
┌─────────────────┐  ┌─────────────────┐  ┌─────────────────────┐
│ monitor_config  │  │  monitor_utils  │  │    monitor_core     │
│     .sh         │  │      .sh        │  │        .sh          │
├─────────────────┤  ├─────────────────┤  ├─────────────────────┤
│ load_config()   │  │ log_message()   │  │ get_cpu_usage()     │
│ validate_conf() │  │ format_bytes()  │  │ get_memory_info()   │
│ get_threshold() │  │ is_numeric()    │  │ get_disk_usage()    │
│ set_default()   │  │ send_alert()    │  │ get_process_info()  │
└─────────────────┘  └─────────────────┘  └─────────────────────┘
```

### 2.2 Loading Order

Modules must be loaded in a specific order due to dependencies:

```bash
# 1. Utilities - no dependencies
source "${LIB_DIR}/monitor_utils.sh"

# 2. Configuration - depends on utilities for logging
source "${LIB_DIR}/monitor_config.sh"

# 3. Core - depends on utilities and configuration
source "${LIB_DIR}/monitor_core.sh"
```

### 2.3 Inter-Module Communication

Modules communicate through:

1. **Global Variables** - for configuration and state
2. **Exported Functions** - for specific operations
3. **Exit Codes** - for error signalling
4. **Stdout/Stderr** - for output and diagnostics

---

## 3. Core Module - monitor_core.sh

### 3.1 The get_cpu_usage() Function

This function calculates CPU utilisation using `/proc/stat`:

```bash
get_cpu_usage() {
    local cpu_line prev_idle prev_total
    local idle total diff_idle diff_total usage
    
    # First reading - initial state
    cpu_line=$(grep '^cpu ' /proc/stat)
    read -r _ user nice system idle iowait irq softirq steal _ <<< "$cpu_line"
    
    prev_idle=$((idle + iowait))
    prev_total=$((user + nice + system + idle + iowait + irq + softirq + steal))
    
    # Wait to measure the difference
    sleep "${CPU_SAMPLE_INTERVAL:-1}"
    
    # Second reading
    cpu_line=$(grep '^cpu ' /proc/stat)
    read -r _ user nice system idle iowait irq softirq steal _ <<< "$cpu_line"
    
    idle=$((idle + iowait))
    total=$((user + nice + system + idle + iowait + irq + softirq + steal))
    
    # Calculate the differences
    diff_idle=$((idle - prev_idle))
    diff_total=$((total - prev_total))
    
    # Calculate the utilisation percentage
    if [[ $diff_total -gt 0 ]]; then
        usage=$(awk "BEGIN {printf \"%.1f\", (1 - $diff_idle / $diff_total) * 100}")
    else
        usage="0.0"
    fi
    
    echo "$usage"
}
```

**Detailed Explanation:**

The `/proc/stat` file contains aggregated CPU statistics. The `cpu` line shows total time spent in different states:

| Field | Description |
|-------|-------------|
| user | Time in user mode |
| nice | Time in user mode with reduced priority |
| system | Time in kernel mode |
| idle | Inactive time |
| iowait | Time waiting for I/O |
| irq | Time servicing hardware interrupts |
| softirq | Time servicing software interrupts |
| steal | Time "stolen" by hypervisor (in VM) |

Calculation formula:
```
CPU% = (1 - (idle_diff / total_diff)) × 100
```

### 3.2 The get_memory_info() Function

```bash
get_memory_info() {
    local format="${1:-human}"
    local mem_total mem_available mem_used mem_free
    local buffers cached swap_total swap_used
    
    # Read information from /proc/meminfo
    while IFS=': ' read -r key value _; do
        case "$key" in
            MemTotal)     mem_total=$value ;;
            MemAvailable) mem_available=$value ;;
            MemFree)      mem_free=$value ;;
            Buffers)      buffers=$value ;;
            Cached)       cached=$value ;;
            SwapTotal)    swap_total=$value ;;
            SwapFree)     swap_free=$value ;;
        esac
    done < /proc/meminfo
    
    # Calculate used memory
    # MemUsed = MemTotal - MemAvailable (modern method)
    mem_used=$((mem_total - mem_available))
    
    # Calculate used swap
    swap_used=$((swap_total - swap_free))
    
    # Calculate percentages
    local mem_percent swap_percent
    if [[ $mem_total -gt 0 ]]; then
        mem_percent=$(awk "BEGIN {printf \"%.1f\", $mem_used / $mem_total * 100}")
    else
        mem_percent="0.0"
    fi
    
    if [[ $swap_total -gt 0 ]]; then
        swap_percent=$(awk "BEGIN {printf \"%.1f\", $swap_used / $swap_total * 100}")
    else
        swap_percent="0.0"
    fi
    
    # Format the output
    case "$format" in
        json)
            cat <<-EOF
			{
			    "total_kb": $mem_total,
			    "used_kb": $mem_used,
			    "available_kb": $mem_available,
			    "free_kb": $mem_free,
			    "buffers_kb": $buffers,
			    "cached_kb": $cached,
			    "percent_used": $mem_percent,
			    "swap_total_kb": $swap_total,
			    "swap_used_kb": $swap_used,
			    "swap_percent": $swap_percent
			}
			EOF
            ;;
        csv)
            echo "$mem_total,$mem_used,$mem_available,$mem_percent,$swap_total,$swap_used,$swap_percent"
            ;;
        *)  # human readable
            echo "Memory: $(format_bytes $((mem_used * 1024))) / $(format_bytes $((mem_total * 1024))) (${mem_percent}%)"
            echo "Swap:   $(format_bytes $((swap_used * 1024))) / $(format_bytes $((swap_total * 1024))) (${swap_percent}%)"
            ;;
    esac
}
```

**Key Concepts:**

1. **MemAvailable vs MemFree**: `MemAvailable` (introduced in kernel 3.14) indicates memory available for new applications, including cache that can be freed. It is more relevant than `MemFree`.

2. **Buffers and Cached**: The Linux kernel uses "free" memory for I/O cache. This can be freed when needed.

3. **Swap**: Virtual memory on disk, used when physical RAM is insufficient.

### 3.3 The get_disk_usage() Function

```bash
get_disk_usage() {
    local mount_point="${1:-/}"
    local format="${2:-human}"
    local output
    
    # Verify that mount point exists
    if [[ ! -d "$mount_point" ]]; then
        log_error "Non-existent mount point: $mount_point"
        return 1
    fi
    
    # Use df for filesystem statistics
    # -P = POSIX format (single line per filesystem)
    # -B1 = 1-byte blocks for precision
    output=$(df -PB1 "$mount_point" 2>/dev/null | tail -1)
    
    if [[ -z "$output" ]]; then
        log_error "Cannot obtain information for: $mount_point"
        return 1
    fi
    
    local filesystem size used available percent mount
    read -r filesystem size used available percent mount <<< "$output"
    
    # Remove % from percent
    percent="${percent%\%}"
    
    # Also obtain I/O statistics if available
    local device io_stats=""
    device=$(findmnt -n -o SOURCE "$mount_point" 2>/dev/null)
    
    if [[ -n "$device" ]]; then
        # Extract only device name (without /dev/)
        local dev_name="${device##*/}"
        
        # Read statistics from /sys/block or /proc/diskstats
        if [[ -f "/sys/block/${dev_name}/stat" ]]; then
            local reads writes
            read -r reads _ _ _ writes _ <<< "$(cat /sys/block/${dev_name}/stat)"
            io_stats="reads=$reads,writes=$writes"
        fi
    fi
    
    case "$format" in
        json)
            cat <<-EOF
			{
			    "mount_point": "$mount_point",
			    "filesystem": "$filesystem",
			    "size_bytes": $size,
			    "used_bytes": $used,
			    "available_bytes": $available,
			    "percent_used": $percent,
			    "io_stats": "$io_stats"
			}
			EOF
            ;;
        csv)
            echo "$mount_point,$filesystem,$size,$used,$available,$percent"
            ;;
        *)
            echo "Disk [$mount_point]: $(format_bytes "$used") / $(format_bytes "$size") (${percent}%)"
            echo "  Available: $(format_bytes "$available")"
            [[ -n "$io_stats" ]] && echo "  I/O: $io_stats"
            ;;
    esac
}
```

### 3.4 The get_process_info() Function

```bash
get_process_info() {
    local limit="${1:-10}"
    local sort_by="${2:-cpu}"
    local format="${3:-human}"
    
    local ps_output sort_field
    
    # Determine the sort field
    case "$sort_by" in
        cpu)    sort_field="-%cpu" ;;
        memory) sort_field="-%mem" ;;
        pid)    sort_field="pid" ;;
        time)   sort_field="-time" ;;
        *)      sort_field="-%cpu" ;;
    esac
    
    # Collect process information
    # Use ps with custom format
    ps_output=$(ps ax --no-headers \
        -o pid,user,%cpu,%mem,vsz,rss,stat,start,time,comm \
        --sort="$sort_field" 2>/dev/null | head -n "$limit")
    
    # Also check for zombie processes
    local zombie_count
    zombie_count=$(ps ax -o stat | grep -c '^Z' 2>/dev/null || echo "0")
    
    # Count total processes and threads
    local proc_count thread_count
    proc_count=$(ps ax --no-headers | wc -l)
    thread_count=$(ps axH --no-headers 2>/dev/null | wc -l || echo "N/A")
    
    case "$format" in
        json)
            echo "{"
            echo "  \"total_processes\": $proc_count,"
            echo "  \"total_threads\": $thread_count,"
            echo "  \"zombie_processes\": $zombie_count,"
            echo "  \"top_processes\": ["
            
            local first=true
            while IFS= read -r line; do
                [[ -z "$line" ]] && continue
                read -r pid user cpu mem vsz rss stat start time comm <<< "$line"
                
                $first || echo ","
                first=false
                
                printf '    {"pid": %d, "user": "%s", "cpu": %s, "mem": %s, "command": "%s"}' \
                    "$pid" "$user" "$cpu" "$mem" "$comm"
            done <<< "$ps_output"
            
            echo ""
            echo "  ]"
            echo "}"
            ;;
            
        csv)
            echo "pid,user,cpu,mem,vsz,rss,stat,start,time,command"
            while IFS= read -r line; do
                [[ -z "$line" ]] && continue
                read -r pid user cpu mem vsz rss stat start time comm <<< "$line"
                echo "$pid,$user,$cpu,$mem,$vsz,$rss,$stat,$start,$time,$comm"
            done <<< "$ps_output"
            ;;
            
        *)
            echo "=== Processes (Top $limit by $sort_by) ==="
            echo "Total: $proc_count processes, $thread_count threads, $zombie_count zombie"
            echo ""
            printf "%-7s %-10s %6s %6s %10s %10s %s\n" \
                "PID" "USER" "CPU%" "MEM%" "VSZ" "RSS" "COMMAND"
            echo "--------------------------------------------------------------"
            
            while IFS= read -r line; do
                [[ -z "$line" ]] && continue
                read -r pid user cpu mem vsz rss stat start time comm <<< "$line"
                printf "%-7d %-10s %6s %6s %10s %10s %s\n" \
                    "$pid" "$user" "$cpu" "$mem" \
                    "$(format_bytes $((vsz * 1024)))" \
                    "$(format_bytes $((rss * 1024)))" \
                    "$comm"
            done <<< "$ps_output"
            ;;
    esac
}
```

### 3.5 The check_thresholds() Function

```bash
check_thresholds() {
    local metric="$1"
    local value="$2"
    local warning_level critical_level
    
    # Obtain thresholds from configuration
    warning_level=$(get_config "${metric}_warning" "80")
    critical_level=$(get_config "${metric}_critical" "95")
    
    # Convert value to integer for comparison
    local int_value
    int_value=$(printf "%.0f" "$value" 2>/dev/null || echo "0")
    
    # Check levels
    if [[ $int_value -ge $critical_level ]]; then
        send_alert "CRITICAL" "$metric" "$value" "$critical_level"
        return 2
    elif [[ $int_value -ge $warning_level ]]; then
        send_alert "WARNING" "$metric" "$value" "$warning_level"
        return 1
    fi
    
    return 0
}

send_alert() {
    local level="$1"
    local metric="$2"
    local value="$3"
    local threshold="$4"
    local timestamp
    
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    # Log the alert
    log_message "$level" "[$metric] Value: $value exceeds threshold: $threshold"
    
    # Execute alert hook if defined
    local alert_command
    alert_command=$(get_config "alert_command" "")
    
    if [[ -n "$alert_command" ]]; then
        # Export variables for external script
        export ALERT_LEVEL="$level"
        export ALERT_METRIC="$metric"
        export ALERT_VALUE="$value"
        export ALERT_THRESHOLD="$threshold"
        export ALERT_TIMESTAMP="$timestamp"
        
        # Execute the command
        eval "$alert_command" 2>/dev/null || \
            log_warning "Alert command failed: $alert_command"
    fi
    
    # Write to alert file
    local alert_file
    alert_file=$(get_config "alert_file" "/var/log/monitor_alerts.log")
    
    if [[ -w "$(dirname "$alert_file")" ]]; then
        printf "%s [%s] %s: %s (threshold: %s)\n" \
            "$timestamp" "$level" "$metric" "$value" "$threshold" \
            >> "$alert_file"
    fi
}
```

---

## 4. Utilities Module - monitor_utils.sh

### 4.1 Logging Functions

```bash
# Log levels with ANSI colour codes
declare -A LOG_LEVELS=(
    [DEBUG]=0
    [INFO]=1
    [WARNING]=2
    [ERROR]=3
    [CRITICAL]=4
)

declare -A LOG_COLORS=(
    [DEBUG]="\e[36m"      # Cyan
    [INFO]="\e[32m"       # Green
    [WARNING]="\e[33m"    # Yellow
    [ERROR]="\e[31m"      # Red
    [CRITICAL]="\e[1;31m" # Bold red
)

RESET_COLOR="\e[0m"

log_message() {
    local level="${1:-INFO}"
    local message="$2"
    local timestamp
    
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    # Check minimum logging level
    local min_level current_level
    min_level="${LOG_LEVELS[${LOG_LEVEL:-INFO}]}"
    current_level="${LOG_LEVELS[$level]}"
    
    [[ $current_level -lt $min_level ]] && return 0
    
    # Format the message
    local formatted_message="[$timestamp] [$level] $message"
    
    # Write to log file if defined
    if [[ -n "$LOG_FILE" && -w "$(dirname "$LOG_FILE")" ]]; then
        echo "$formatted_message" >> "$LOG_FILE"
    fi
    
    # Display to terminal with colours (if TTY)
    if [[ -t 2 ]]; then
        printf "%b%s%b\n" "${LOG_COLORS[$level]}" "$formatted_message" "$RESET_COLOR" >&2
    else
        echo "$formatted_message" >&2
    fi
}

# Wrapper functions for convenience
log_debug()    { log_message "DEBUG" "$*"; }
log_info()     { log_message "INFO" "$*"; }
log_warning()  { log_message "WARNING" "$*"; }
log_error()    { log_message "ERROR" "$*"; }
log_critical() { log_message "CRITICAL" "$*"; }
```

### 4.2 Formatting Functions

```bash
format_bytes() {
    local bytes="${1:-0}"
    local precision="${2:-2}"
    
    # Validate input
    if ! [[ "$bytes" =~ ^[0-9]+$ ]]; then
        echo "0 B"
        return
    fi
    
    local units=("B" "KiB" "MiB" "GiB" "TiB" "PiB")
    local unit_index=0
    local value="$bytes"
    
    # Use bc for calculation precision
    while [[ $(echo "$value >= 1024" | bc -l) -eq 1 ]] && [[ $unit_index -lt 5 ]]; do
        value=$(echo "scale=10; $value / 1024" | bc -l)
        ((unit_index++))
    done
    
    # Format the result
    printf "%.*f %s" "$precision" "$value" "${units[$unit_index]}"
}

format_duration() {
    local seconds="${1:-0}"
    
    if [[ $seconds -lt 60 ]]; then
        echo "${seconds}s"
    elif [[ $seconds -lt 3600 ]]; then
        printf "%dm %ds" $((seconds / 60)) $((seconds % 60))
    elif [[ $seconds -lt 86400 ]]; then
        printf "%dh %dm" $((seconds / 3600)) $(((seconds % 3600) / 60))
    else
        printf "%dd %dh" $((seconds / 86400)) $(((seconds % 86400) / 3600))
    fi
}

format_percentage() {
    local value="$1"
    local decimals="${2:-1}"
    local bar_width="${3:-20}"
    
    # Calculate number of characters for bar
    local filled
    filled=$(printf "%.0f" "$(echo "$value * $bar_width / 100" | bc -l)")
    local empty=$((bar_width - filled))
    
    # Build the visual bar
    local bar=""
    bar+=$(printf '%*s' "$filled" '' | tr ' ' '█')
    bar+=$(printf '%*s' "$empty" '' | tr ' ' '░')
    
    # Choose colour based on value
    local color
    if (( $(echo "$value >= 90" | bc -l) )); then
        color="\e[31m"  # Red
    elif (( $(echo "$value >= 70" | bc -l) )); then
        color="\e[33m"  # Yellow
    else
        color="\e[32m"  # Green
    fi
    
    printf "%b[%s]%b %.*f%%" "$color" "$bar" "$RESET_COLOR" "$decimals" "$value"
}
```

### 4.3 Validation Functions

```bash
is_numeric() {
    local value="$1"
    [[ "$value" =~ ^-?[0-9]+\.?[0-9]*$ ]]
}

is_integer() {
    local value="$1"
    [[ "$value" =~ ^-?[0-9]+$ ]]
}

is_positive_integer() {
    local value="$1"
    [[ "$value" =~ ^[0-9]+$ ]] && [[ "$value" -gt 0 ]]
}

validate_percentage() {
    local value="$1"
    is_numeric "$value" && \
        (( $(echo "$value >= 0 && $value <= 100" | bc -l) ))
}

validate_path() {
    local path="$1"
    local type="${2:-any}"  # file, dir, any
    
    case "$type" in
        file) [[ -f "$path" ]] ;;
        dir)  [[ -d "$path" ]] ;;
        *)    [[ -e "$path" ]] ;;
    esac
}
```

### 4.4 Helper Functions

```bash
# Generate unique timestamp
generate_timestamp() {
    date '+%Y%m%d_%H%M%S'
}

# Check if running as root
is_root() {
    [[ $EUID -eq 0 ]]
}

# Obtain system information
get_hostname() {
    hostname -s 2>/dev/null || cat /etc/hostname 2>/dev/null || echo "unknown"
}

get_kernel_version() {
    uname -r
}

get_uptime_seconds() {
    cut -d' ' -f1 /proc/uptime | cut -d'.' -f1
}

# Associative arrays for cache
declare -A _CACHE
declare -A _CACHE_EXPIRY

cache_set() {
    local key="$1"
    local value="$2"
    local ttl="${3:-60}"  # Time-to-live in seconds
    
    _CACHE["$key"]="$value"
    _CACHE_EXPIRY["$key"]=$(($(date +%s) + ttl))
}

cache_get() {
    local key="$1"
    local now
    
    now=$(date +%s)
    
    if [[ -n "${_CACHE[$key]}" ]] && [[ ${_CACHE_EXPIRY[$key]} -gt $now ]]; then
        echo "${_CACHE[$key]}"
        return 0
    fi
    
    return 1
}

cache_invalidate() {
    local key="$1"
    unset "_CACHE[$key]"
    unset "_CACHE_EXPIRY[$key]"
}
```

---

## 5. Configuration Module - monitor_config.sh

### 5.1 Configuration Loading

```bash
# Global variables for configuration
declare -A CONFIG
declare CONFIG_FILE=""
declare CONFIG_LOADED=false

load_config() {
    local config_file="${1:-}"
    
    # Search for configuration file in priority order
    local search_paths=(
        "$config_file"
        "${HOME}/.config/monitor/monitor.conf"
        "${HOME}/.monitor.conf"
        "/etc/monitor/monitor.conf"
        "${SCRIPT_DIR}/config/monitor.conf"
    )
    
    for path in "${search_paths[@]}"; do
        [[ -z "$path" ]] && continue
        
        if [[ -f "$path" && -r "$path" ]]; then
            CONFIG_FILE="$path"
            break
        fi
    done
    
    if [[ -z "$CONFIG_FILE" ]]; then
        log_warning "No configuration file found, using default values"
        set_defaults
        CONFIG_LOADED=true
        return 0
    fi
    
    log_info "Loading configuration from: $CONFIG_FILE"
    
    # Parse configuration file
    parse_config_file "$CONFIG_FILE"
    
    # Validate configuration
    validate_config || return 1
    
    CONFIG_LOADED=true
    return 0
}

parse_config_file() {
    local file="$1"
    local line_num=0
    
    while IFS= read -r line || [[ -n "$line" ]]; do
        ((line_num++))
        
        # Ignore empty lines and comments
        [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue
        
        # Remove leading/trailing whitespace
        line="${line#"${line%%[![:space:]]*}"}"
        line="${line%"${line##*[![:space:]]}"}"
        
        # Check key=value format
        if [[ "$line" =~ ^([a-zA-Z_][a-zA-Z0-9_]*)=(.*)$ ]]; then
            local key="${BASH_REMATCH[1]}"
            local value="${BASH_REMATCH[2]}"
            
            # Remove quotes if present
            value="${value#[\"\']}"
            value="${value%[\"\']}"
            
            # Expand environment variables
            value=$(eval echo "$value" 2>/dev/null) || value="${BASH_REMATCH[2]}"
            
            CONFIG["$key"]="$value"
            log_debug "Config: $key = $value"
        else
            log_warning "Line $line_num ignored (invalid format): $line"
        fi
    done < "$file"
}
```

### 5.2 Configuration Validation

```bash
validate_config() {
    local errors=0
    
    # Validate thresholds
    for metric in cpu memory disk swap; do
        for level in warning critical; do
            local key="${metric}_${level}"
            local value="${CONFIG[$key]:-}"
            
            if [[ -n "$value" ]]; then
                if ! validate_percentage "$value"; then
                    log_error "Invalid value for $key: $value (must be 0-100)"
                    ((errors++))
                fi
            fi
        done
    done
    
    # Validate that warning < critical
    for metric in cpu memory disk swap; do
        local warning="${CONFIG[${metric}_warning]:-80}"
        local critical="${CONFIG[${metric}_critical]:-95}"
        
        if (( $(echo "$warning >= $critical" | bc -l) )); then
            log_error "For $metric: warning ($warning) >= critical ($critical)"
            ((errors++))
        fi
    done
    
    # Validate monitoring interval
    local interval="${CONFIG[monitor_interval]:-5}"
    if ! is_positive_integer "$interval"; then
        log_error "Invalid monitor_interval: $interval"
        ((errors++))
    fi
    
    # Validate paths
    local log_dir="${CONFIG[log_dir]:-/var/log/monitor}"
    if [[ ! -d "$log_dir" ]]; then
        mkdir -p "$log_dir" 2>/dev/null || {
            log_warning "Cannot create log directory: $log_dir"
        }
    fi
    
    return $((errors > 0 ? 1 : 0))
}
```

### 5.3 Configuration Access

```bash
get_config() {
    local key="$1"
    local default="${2:-}"
    
    if [[ -n "${CONFIG[$key]+isset}" ]]; then
        echo "${CONFIG[$key]}"
    else
        echo "$default"
    fi
}

set_config() {
    local key="$1"
    local value="$2"
    
    CONFIG["$key"]="$value"
    log_debug "Config updated: $key = $value"
}

set_defaults() {
    # CPU thresholds
    CONFIG[cpu_warning]=80
    CONFIG[cpu_critical]=95
    
    # Memory thresholds
    CONFIG[memory_warning]=80
    CONFIG[memory_critical]=95
    
    # Disk thresholds
    CONFIG[disk_warning]=80
    CONFIG[disk_critical]=95
    
    # Swap thresholds
    CONFIG[swap_warning]=50
    CONFIG[swap_critical]=80
    
    # General settings
    CONFIG[monitor_interval]=5
    CONFIG[output_format]="human"
    CONFIG[log_level]="INFO"
    CONFIG[log_dir]="/var/log/monitor"
    CONFIG[enable_alerts]=true
    CONFIG[alert_command]=""
    
    # Process settings
    CONFIG[top_processes]=10
    CONFIG[process_sort]="cpu"
    
    # Mount points for disk monitoring
    CONFIG[disk_mounts]="/"
    
    log_debug "Default values have been set"
}

# Export configuration in human-readable format
dump_config() {
    echo "=== Current Configuration ==="
    echo "Config file: ${CONFIG_FILE:-none}"
    echo ""
    
    for key in $(echo "${!CONFIG[@]}" | tr ' ' '\n' | sort); do
        printf "%-25s = %s\n" "$key" "${CONFIG[$key]}"
    done
}
```

---

## 6. Main Script - monitor.sh

### 6.1 Initialisation and Bootstrap

```bash
#!/usr/bin/env bash
#
# monitor.sh - System Resource Monitor
# CAPSTONE Project - Operating Systems
#

set -o errexit   # Exit on error
set -o nounset   # Exit on undefined variable
set -o pipefail  # Pipeline returns last non-zero status

# Determine script directory
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"
readonly VERSION="1.0.0"

# Standard directories
readonly LIB_DIR="${SCRIPT_DIR}/lib"
readonly CONFIG_DIR="${SCRIPT_DIR}/config"

# Verify module existence
for module in monitor_utils monitor_config monitor_core; do
    module_path="${LIB_DIR}/${module}.sh"
    if [[ ! -f "$module_path" ]]; then
        echo "ERROR: Module missing: $module_path" >&2
        exit 1
    fi
done

# Load modules in correct order
source "${LIB_DIR}/monitor_utils.sh"
source "${LIB_DIR}/monitor_config.sh"
source "${LIB_DIR}/monitor_core.sh"
```

### 6.2 Argument Parsing

```bash
# Variables for arguments
declare -g OUTPUT_FORMAT="human"
declare -g DAEMON_MODE=false
declare -g SINGLE_RUN=false
declare -g CUSTOM_CONFIG=""
declare -g VERBOSE=false
declare -g MONITOR_CPU=true
declare -g MONITOR_MEMORY=true
declare -g MONITOR_DISK=true
declare -g MONITOR_PROCESSES=true

show_help() {
    cat <<EOF
Usage: $SCRIPT_NAME [OPTIONS]

System Resource Monitor - Monitors system resources

Options:
  -h, --help              Display this message
  -V, --version           Display version
  -c, --config FILE       Use specific configuration file
  -f, --format FORMAT     Output format: human, json, csv (default: human)
  -1, --once              Run once and exit
  -d, --daemon            Run in daemon mode (background)
  -v, --verbose           Display detailed information
  -i, --interval SEC      Interval between measurements (default: 5)
  
Metric selection (all by default):
  --cpu                   Monitor only CPU
  --memory                Monitor only memory
  --disk                  Monitor only disk
  --processes             Monitor only processes
  --all                   Monitor all (default)
  
Threshold override:
  --cpu-warning N         Set CPU warning at N%
  --cpu-critical N        Set CPU critical at N%
  --mem-warning N         Set memory warning at N%
  --mem-critical N        Set memory critical at N%

Examples:
  $SCRIPT_NAME                    # Continuous monitoring, human format
  $SCRIPT_NAME -1 -f json         # Single run, JSON output
  $SCRIPT_NAME --cpu --memory     # Only CPU and memory
  $SCRIPT_NAME -d -i 60           # Daemon with 60 second interval

EOF
}

parse_arguments() {
    local metrics_specified=false
    
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                show_help
                exit 0
                ;;
            -V|--version)
                echo "$SCRIPT_NAME version $VERSION"
                exit 0
                ;;
            -c|--config)
                CUSTOM_CONFIG="$2"
                shift 2
                ;;
            -f|--format)
                OUTPUT_FORMAT="$2"
                shift 2
                ;;
            -1|--once)
                SINGLE_RUN=true
                shift
                ;;
            -d|--daemon)
                DAEMON_MODE=true
                shift
                ;;
            -v|--verbose)
                VERBOSE=true
                LOG_LEVEL="DEBUG"
                shift
                ;;
            -i|--interval)
                CONFIG[monitor_interval]="$2"
                shift 2
                ;;
            --cpu)
                if ! $metrics_specified; then
                    MONITOR_MEMORY=false
                    MONITOR_DISK=false
                    MONITOR_PROCESSES=false
                    metrics_specified=true
                fi
                MONITOR_CPU=true
                shift
                ;;
            --memory)
                if ! $metrics_specified; then
                    MONITOR_CPU=false
                    MONITOR_DISK=false
                    MONITOR_PROCESSES=false
                    metrics_specified=true
                fi
                MONITOR_MEMORY=true
                shift
                ;;
            --disk)
                if ! $metrics_specified; then
                    MONITOR_CPU=false
                    MONITOR_MEMORY=false
                    MONITOR_PROCESSES=false
                    metrics_specified=true
                fi
                MONITOR_DISK=true
                shift
                ;;
            --processes)
                if ! $metrics_specified; then
                    MONITOR_CPU=false
                    MONITOR_MEMORY=false
                    MONITOR_DISK=false
                    metrics_specified=true
                fi
                MONITOR_PROCESSES=true
                shift
                ;;
            --all)
                MONITOR_CPU=true
                MONITOR_MEMORY=true
                MONITOR_DISK=true
                MONITOR_PROCESSES=true
                shift
                ;;
            --cpu-warning)
                CONFIG[cpu_warning]="$2"
                shift 2
                ;;
            --cpu-critical)
                CONFIG[cpu_critical]="$2"
                shift 2
                ;;
            --mem-warning)
                CONFIG[memory_warning]="$2"
                shift 2
                ;;
            --mem-critical)
                CONFIG[memory_critical]="$2"
                shift 2
                ;;
            -*)
                log_error "Unknown option: $1"
                show_help
                exit 1
                ;;
            *)
                log_error "Unexpected argument: $1"
                show_help
                exit 1
                ;;
        esac
    done
}
```

### 6.3 Main Monitoring Cycle

```bash
run_monitoring_cycle() {
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    case "$OUTPUT_FORMAT" in
        json)
            echo "{"
            echo "  \"timestamp\": \"$timestamp\","
            echo "  \"hostname\": \"$(get_hostname)\","
            echo "  \"metrics\": {"
            ;;
        csv)
            # CSV header on first run
            if [[ "${FIRST_RUN:-true}" == "true" ]]; then
                echo "timestamp,metric,value,unit,status"
                FIRST_RUN=false
            fi
            ;;
        *)
            echo ""
            echo "╔════════════════════════════════════════════════════════════════╗"
            printf "║  System Monitor - %-42s  ║\n" "$timestamp"
            printf "║  Host: %-52s  ║\n" "$(get_hostname)"
            echo "╚════════════════════════════════════════════════════════════════╝"
            ;;
    esac
    
    local first_metric=true
    
    # CPU Monitoring
    if $MONITOR_CPU; then
        local cpu_usage
        cpu_usage=$(get_cpu_usage)
        
        $first_metric || [[ "$OUTPUT_FORMAT" == "json" ]] && echo ","
        first_metric=false
        
        output_metric "cpu" "$cpu_usage" "%"
        check_thresholds "cpu" "$cpu_usage"
    fi
    
    # Memory Monitoring
    if $MONITOR_MEMORY; then
        local mem_info
        mem_info=$(get_memory_info "raw")
        
        # Parse values
        local mem_percent
        mem_percent=$(echo "$mem_info" | grep -oP 'percent=\K[0-9.]+')
        
        [[ "$OUTPUT_FORMAT" == "json" ]] && ! $first_metric && echo ","
        first_metric=false
        
        output_metric "memory" "$mem_percent" "%"
        check_thresholds "memory" "$mem_percent"
        
        # Display details in verbose mode
        if $VERBOSE; then
            get_memory_info "$OUTPUT_FORMAT"
        fi
    fi
    
    # Disk Monitoring
    if $MONITOR_DISK; then
        local mounts
        IFS=',' read -ra mounts <<< "$(get_config 'disk_mounts' '/')"
        
        for mount in "${mounts[@]}"; do
            local disk_percent
            disk_percent=$(get_disk_usage "$mount" "percent")
            
            [[ "$OUTPUT_FORMAT" == "json" ]] && ! $first_metric && echo ","
            first_metric=false
            
            output_metric "disk_${mount//\//_}" "$disk_percent" "%"
            check_thresholds "disk" "$disk_percent"
        done
    fi
    
    # Process Monitoring
    if $MONITOR_PROCESSES; then
        if $VERBOSE || [[ "$OUTPUT_FORMAT" == "json" ]]; then
            [[ "$OUTPUT_FORMAT" == "json" ]] && ! $first_metric && echo ","
            
            local limit
            limit=$(get_config "top_processes" "10")
            local sort_by
            sort_by=$(get_config "process_sort" "cpu")
            
            get_process_info "$limit" "$sort_by" "$OUTPUT_FORMAT"
        fi
    fi
    
    # Close JSON output
    if [[ "$OUTPUT_FORMAT" == "json" ]]; then
        echo ""
        echo "  }"
        echo "}"
    fi
}

output_metric() {
    local name="$1"
    local value="$2"
    local unit="${3:-}"
    
    local status="OK"
    local warning critical
    warning=$(get_config "${name}_warning" "80")
    critical=$(get_config "${name}_critical" "95")
    
    local int_value
    int_value=$(printf "%.0f" "$value" 2>/dev/null || echo "0")
    
    if [[ $int_value -ge $critical ]]; then
        status="CRITICAL"
    elif [[ $int_value -ge $warning ]]; then
        status="WARNING"
    fi
    
    case "$OUTPUT_FORMAT" in
        json)
            printf '    "%s": {"value": %s, "unit": "%s", "status": "%s"}' \
                "$name" "$value" "$unit" "$status"
            ;;
        csv)
            printf "%s,%s,%s,%s,%s\n" \
                "$(date '+%Y-%m-%d %H:%M:%S')" "$name" "$value" "$unit" "$status"
            ;;
        *)
            local label
            label=$(echo "$name" | tr '_' ' ' | sed 's/\b\(.\)/\u\1/g')
            printf "  %-20s: " "$label"
            format_percentage "$value"
            [[ "$status" != "OK" ]] && printf " [%s]" "$status"
            echo ""
            ;;
    esac
}
```

### 6.4 Main Function and Cleanup

```bash
# Control variables
declare -g RUNNING=true
declare -g PID_FILE="/var/run/monitor.pid"

cleanup() {
    log_info "Stopping monitor..."
    RUNNING=false
    
    # Delete PID file if it exists
    [[ -f "$PID_FILE" ]] && rm -f "$PID_FILE"
    
    log_info "Monitor stopped"
    exit 0
}

# Install signal handlers
trap cleanup SIGINT SIGTERM SIGHUP

daemonize() {
    # Check if already running
    if [[ -f "$PID_FILE" ]]; then
        local old_pid
        old_pid=$(cat "$PID_FILE")
        
        if kill -0 "$old_pid" 2>/dev/null; then
            log_error "Monitor already running with PID $old_pid"
            exit 1
        else
            log_warning "Old PID file found, deleting it"
            rm -f "$PID_FILE"
        fi
    fi
    
    # Fork to background
    log_info "Starting in daemon mode..."
    
    # Redirect output
    exec >> "${LOG_FILE:-/dev/null}" 2>&1
    
    # Write PID
    echo $$ > "$PID_FILE"
    
    log_info "Daemon started with PID $$"
}

main() {
    # Parse arguments
    parse_arguments "$@"
    
    # Load configuration
    load_config "$CUSTOM_CONFIG" || {
        log_error "Error loading configuration"
        exit 1
    }
    
    # Daemon mode
    if $DAEMON_MODE; then
        daemonize
    fi
    
    # Single run mode
    if $SINGLE_RUN; then
        run_monitoring_cycle
        exit 0
    fi
    
    # Main monitoring cycle
    local interval
    interval=$(get_config "monitor_interval" "5")
    
    log_info "Starting monitoring (interval: ${interval}s)"
    
    while $RUNNING; do
        run_monitoring_cycle
        sleep "$interval"
    done
}

# Run main only if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
```

---

## 7. Execution Flow

### 7.1 Flow Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                          START                                   │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                    Load modules                                  │
│    monitor_utils.sh → monitor_config.sh → monitor_core.sh       │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                  Parse CLI arguments                             │
│         --format, --once, --daemon, --cpu, etc.                  │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                  Load configuration                              │
│        ~/.config/monitor/monitor.conf or default                 │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
                    ┌─────────────────┐
                    │  Daemon mode?   │
                    └─────────────────┘
                      │           │
                  Yes │           │ No
                      ▼           │
         ┌────────────────────┐   │
         │    daemonize()     │   │
         │  Fork background   │   │
         │  Write PID file    │   │
         └────────────────────┘   │
                      │           │
                      └─────┬─────┘
                            │
                            ▼
                    ┌─────────────────┐
                    │  Single run?    │
                    └─────────────────┘
                      │           │
                  Yes │           │ No
                      ▼           │
    ┌───────────────────────────┐ │
    │ run_monitoring_cycle()    │ │
    │        exit 0             │ │
    └───────────────────────────┘ │
                                  │
                                  ▼
              ┌────────────────────────────────┐
              │      MONITORING LOOP           │
              │ ┌────────────────────────────┐ │
              │ │ run_monitoring_cycle()     │ │
              │ │  ├─ get_cpu_usage()        │ │
              │ │  ├─ get_memory_info()      │ │
              │ │  ├─ get_disk_usage()       │ │
              │ │  ├─ get_process_info()     │ │
              │ │  └─ check_thresholds()     │ │
              │ └────────────────────────────┘ │
              │              │                 │
              │              ▼                 │
              │    sleep $interval            │
              │              │                 │
              │   ┌──────────┴──────────┐     │
              │   │   RUNNING=true?     │     │
              │   └──────────┬──────────┘     │
              │          Yes │                 │
              │              └─────────────────┤
              │                                │
              └────────────────────────────────┘
                               │
                          No   │
                               ▼
                    ┌─────────────────┐
                    │    cleanup()    │
                    │    exit 0       │
                    └─────────────────┘
```

### 7.2 Call Sequence (for one cycle)

```
main()
├── parse_arguments()
├── load_config()
│   ├── parse_config_file()
│   └── validate_config()
└── monitoring loop
    └── run_monitoring_cycle()
        ├── get_cpu_usage()
        │   ├── read /proc/stat
        │   ├── sleep 1
        │   ├── read /proc/stat again
        │   └── calculate difference
        ├── get_memory_info()
        │   └── parse /proc/meminfo
        ├── get_disk_usage()
        │   ├── df command
        │   └── read /sys/block/*/stat
        ├── get_process_info()
        │   └── ps command
        ├── check_thresholds()
        │   └── send_alert() [if needed]
        └── output_metric()
            └── format_percentage()
```

---

## 8. Advanced Monitoring Techniques

### 8.1 Per-CPU Core Monitoring

```bash
get_per_cpu_usage() {
    local -A prev_stats curr_stats
    local cpu_count cpu_id
    
    # Count CPUs
    cpu_count=$(grep -c '^processor' /proc/cpuinfo)
    
    # First reading
    while IFS= read -r line; do
        if [[ "$line" =~ ^cpu([0-9]+) ]]; then
            cpu_id="${BASH_REMATCH[1]}"
            read -r _ user nice system idle iowait irq softirq steal _ <<< "$line"
            prev_stats["${cpu_id}_idle"]=$((idle + iowait))
            prev_stats["${cpu_id}_total"]=$((user + nice + system + idle + iowait + irq + softirq + steal))
        fi
    done < /proc/stat
    
    sleep "${CPU_SAMPLE_INTERVAL:-1}"
    
    # Second reading and calculation
    echo "{"
    echo "  \"cpu_count\": $cpu_count,"
    echo "  \"per_cpu\": ["
    
    local first=true
    while IFS= read -r line; do
        if [[ "$line" =~ ^cpu([0-9]+) ]]; then
            cpu_id="${BASH_REMATCH[1]}"
            read -r _ user nice system idle iowait irq softirq steal _ <<< "$line"
            
            local curr_idle=$((idle + iowait))
            local curr_total=$((user + nice + system + idle + iowait + irq + softirq + steal))
            
            local diff_idle=$((curr_idle - prev_stats["${cpu_id}_idle"]))
            local diff_total=$((curr_total - prev_stats["${cpu_id}_total"]))
            
            local usage
            if [[ $diff_total -gt 0 ]]; then
                usage=$(awk "BEGIN {printf \"%.1f\", (1 - $diff_idle / $diff_total) * 100}")
            else
                usage="0.0"
            fi
            
            $first || echo ","
            first=false
            printf '    {"core": %d, "usage": %s}' "$cpu_id" "$usage"
        fi
    done < /proc/stat
    
    echo ""
    echo "  ]"
    echo "}"
}
```

### 8.2 Load Average and Context Switches Monitoring

```bash
get_system_load() {
    local load_1 load_5 load_15 running_procs total_procs
    
    # Load average from /proc/loadavg
    read -r load_1 load_5 load_15 procs _ < /proc/loadavg
    
    # Parse running/total processes
    IFS='/' read -r running_procs total_procs <<< "$procs"
    
    # Context switches from /proc/stat
    local context_switches
    context_switches=$(grep '^ctxt' /proc/stat | awk '{print $2}')
    
    # Interrupts
    local interrupts
    interrupts=$(grep '^intr' /proc/stat | awk '{print $2}')
    
    cat <<EOF
{
    "load_average": {
        "1min": $load_1,
        "5min": $load_5,
        "15min": $load_15
    },
    "processes": {
        "running": $running_procs,
        "total": $total_procs
    },
    "context_switches": $context_switches,
    "interrupts": $interrupts
}
EOF
}
```

### 8.3 I/O and Network Monitoring

```bash
get_io_stats() {
    local device="${1:-}"
    
    # If not specified, use all block devices
    if [[ -z "$device" ]]; then
        local devices
        devices=$(lsblk -d -n -o NAME | grep -v '^loop')
    else
        devices="$device"
    fi
    
    echo "{"
    echo "  \"io_stats\": ["
    
    local first=true
    for dev in $devices; do
        [[ ! -f "/sys/block/$dev/stat" ]] && continue
        
        read -r reads read_merges read_sectors read_time \
             writes write_merges write_sectors write_time \
             io_in_progress io_time weighted_time \
             < "/sys/block/$dev/stat"
        
        $first || echo ","
        first=false
        
        cat <<EOF
    {
        "device": "$dev",
        "reads": $reads,
        "writes": $writes,
        "read_bytes": $((read_sectors * 512)),
        "write_bytes": $((write_sectors * 512)),
        "io_time_ms": $io_time,
        "weighted_io_time_ms": $weighted_time
    }
EOF
    done
    
    echo ""
    echo "  ]"
    echo "}"
}

get_network_stats() {
    local interface="${1:-}"
    
    echo "{"
    echo "  \"network_stats\": ["
    
    local first=true
    while IFS=': ' read -r iface stats; do
        [[ "$iface" == "Inter-"* || "$iface" == "face" ]] && continue
        [[ -n "$interface" && "$iface" != "$interface" ]] && continue
        
        # Parse statistics
        read -r rx_bytes rx_packets rx_errs rx_drop rx_fifo rx_frame rx_compressed rx_multicast \
             tx_bytes tx_packets tx_errs tx_drop tx_fifo tx_colls tx_carrier tx_compressed \
             <<< "$stats"
        
        $first || echo ","
        first=false
        
        cat <<EOF
    {
        "interface": "$iface",
        "rx_bytes": $rx_bytes,
        "rx_packets": $rx_packets,
        "rx_errors": $rx_errs,
        "rx_dropped": $rx_drop,
        "tx_bytes": $tx_bytes,
        "tx_packets": $tx_packets,
        "tx_errors": $tx_errs,
        "tx_dropped": $tx_drop
    }
EOF
    done < /proc/net/dev
    
    echo ""
    echo "  ]"
    echo "}"
}
```

### 8.4 Temperature and Sensor Monitoring

```bash
get_temperature_info() {
    local temps=()
    
    # Search in /sys/class/thermal
    for zone in /sys/class/thermal/thermal_zone*/; do
        [[ ! -d "$zone" ]] && continue
        
        local type temp
        type=$(cat "${zone}type" 2>/dev/null || echo "unknown")
        temp=$(cat "${zone}temp" 2>/dev/null || echo "0")
        
        # Temperature is in milli-degrees Celsius
        local temp_c
        temp_c=$(awk "BEGIN {printf \"%.1f\", $temp / 1000}")
        
        temps+=("{\"zone\": \"$type\", \"temp_celsius\": $temp_c}")
    done
    
    # Also search in hwmon if it exists
    for hwmon in /sys/class/hwmon/hwmon*/; do
        [[ ! -d "$hwmon" ]] && continue
        
        local name
        name=$(cat "${hwmon}name" 2>/dev/null || echo "unknown")
        
        for temp_input in "${hwmon}"temp*_input; do
            [[ ! -f "$temp_input" ]] && continue
            
            local label temp
            local base="${temp_input%_input}"
            
            label=$(cat "${base}_label" 2>/dev/null || echo "${base##*/}")
            temp=$(cat "$temp_input" 2>/dev/null || echo "0")
            
            local temp_c
            temp_c=$(awk "BEGIN {printf \"%.1f\", $temp / 1000}")
            
            temps+=("{\"zone\": \"${name}/${label}\", \"temp_celsius\": $temp_c}")
        done
    done
    
    echo "{"
    echo "  \"temperatures\": ["
    local first=true
    for t in "${temps[@]}"; do
        $first || echo ","
        first=false
        echo "    $t"
    done
    echo ""
    echo "  ]"
    echo "}"
}
```

---

## 9. Implementation Exercises

### Exercise 1: Adding a New Metric

**Objective**: Add monitoring for file descriptors.

```bash
# Implement this function in monitor_core.sh
get_file_descriptors() {
    # TODO: Implement collection of:
    # - Total open FDs in the system
    # - FDs per process (top 5)
    # - System limit (/proc/sys/fs/file-max)
    # - Percentage used
    
    # Hint: /proc/sys/fs/file-nr contains:
    # allocated  free  maximum
    :
}
```

### Exercise 2: Prometheus Export

**Objective**: Add export in Prometheus format.

```bash
# Prometheus format example:
# cpu_usage_percent{host="server1"} 45.2
# memory_used_bytes{host="server1"} 4294967296

output_prometheus() {
    local hostname
    hostname=$(get_hostname)
    
    # TODO: Implement metric generation in Prometheus format
    # for all monitored resources
    :
}
```

### Exercise 3: Email Alerting

**Objective**: Implement sending alerts via email.

```bash
# Required configuration in monitor.conf:
# alert_email_enabled=true
# alert_email_to=admin@example.com
# alert_email_from=monitor@example.com
# alert_smtp_server=localhost

send_email_alert() {
    local level="$1"
    local metric="$2"
    local value="$3"
    local threshold="$4"
    
    # TODO: Implement email sending
    # using sendmail, mailx, or curl with SMTP API
    :
}
```

### Exercise 4: History and Trending

**Objective**: Implement history saving and trend detection.

```bash
# Save metrics to rotating CSV file
save_metric_history() {
    local metric="$1"
    local value="$2"
    local history_file="${DATA_DIR}/${metric}_history.csv"
    local max_records=1440  # 24 hours at 1 minute interval
    
    # TODO: Implement:
    # 1. Save timestamp + value
    # 2. Automatic rotation when exceeds max_records
    # 3. Trend calculation function (growing/stable/declining)
    :
}

calculate_trend() {
    local metric="$1"
    local window="${2:-10}"  # Last N measurements
    
    # TODO: Calculate whether metric is rising/falling/stable
    # Return: "rising", "falling", "stable"
    :
}
```

### Exercise 5: Terminal Dashboard

**Objective**: Implement an interactive dashboard in the terminal.

```bash
# Use tput for terminal control
draw_dashboard() {
    # Clear screen
    tput clear
    
    # TODO: Implement dashboard with:
    # - Header with hostname and timestamp
    # - Progress bars for CPU, memory, disk
    # - Top processes list
    # - Automatic refresh (without flicker)
    # - 'q' key to quit
    
    # Hint: tput cup Y X for cursor positioning
    :
}
```

---

## Conclusions

The Monitor project demonstrates the implementation of a complex monitoring system using exclusively Bash and standard Linux utilities. Key points are:

1. **Modular architecture** - clear separation of responsibilities
2. **Efficient parsing** - use of virtual files from /proc and /sys
3. **Output flexibility** - support for multiple formats
4. **Stability** - error handling and default values
5. **Extensibility** - easy to add new metrics

This project can be extended for:
- Integration with monitoring systems (Prometheus, Grafana)
- Advanced alerting (PagerDuty, Slack)
- Clustering and data aggregation from multiple hosts
- Machine learning for anomaly detection
