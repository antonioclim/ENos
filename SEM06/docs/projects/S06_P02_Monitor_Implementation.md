# Monitor Project - Detailed Implementation

## Executable contracts

The repository entry point is `SEM06/scripts/projects/monitor/monitor.sh`, with `lib/core.sh`, `lib/utils.sh` and `lib/config.sh`. From `SEM06`, use `bash scripts/projects/monitor/monitor.sh --help`, or `bash scripts/projects/monitor/monitor.sh -o json` for one sample. `-d` requests a foreground loop suitable for a supervisor; it does not fork itself. The longer examples below form a separate teaching implementation: extract each named module before combining it. Its optional metric-selection flags are not flags of the repository executable.

The examples require Bash 4.4 or later, Python 3, Linux procfs/sysfs and GNU utilities. Counter readings are sequential observations, not an atomic snapshot. Missing or inconsistent input is **UNAVAILABLE**, never a fabricated zero. `idle + iowait` is this lesson's explicitly defined idle-like quantity; Linux iowait accounting has limitations and may decrease. Guest counters are already included in user/nice and must not be added again.

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
    local first second label user nice system idle iowait irq softirq steal rest
    local total0 idle0 total1 idle1 dt di value
    local interval="${CPU_SAMPLE_INTERVAL:-1}"
    [[ $interval =~ ^[0-9]+([.][0-9]+)?$ ]] || return 2
    first=$(head -n 1 -- "${CPU_STAT_PATH:-/proc/stat}") || return 2
    read -r label user nice system idle iowait irq softirq steal rest <<< "$first"
    [[ $label == cpu ]] || return 2
    for value in "$user" "$nice" "$system" "$idle" "$iowait" "$irq" "$softirq" "$steal"; do
        [[ $value =~ ^[0-9]+$ ]] || return 2
    done
    idle0=$((idle + iowait))
    total0=$((user + nice + system + idle + iowait + irq + softirq + steal))
    sleep "$interval" || return 2
    second=$(head -n 1 -- "${CPU_STAT_SECOND_PATH:-${CPU_STAT_PATH:-/proc/stat}}") || return 2
    read -r label user nice system idle iowait irq softirq steal rest <<< "$second"
    [[ $label == cpu ]] || return 2
    for value in "$user" "$nice" "$system" "$idle" "$iowait" "$irq" "$softirq" "$steal"; do
        [[ $value =~ ^[0-9]+$ ]] || return 2
    done
    idle1=$((idle + iowait))
    total1=$((user + nice + system + idle + iowait + irq + softirq + steal))
    dt=$((total1 - total0)); di=$((idle1 - idle0))
    ((dt > 0 && di >= 0 && di <= dt)) || return 2
    LC_ALL=C awk -v total="$dt" -v idle="$di" 'BEGIN {printf "%.1f\n", 100*(total-idle)/total}'
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

Save the following shared collector module as `lib/monitor_data.py`. It serialises JSON/CSV with standard encoders, preserves unavailable sensor readings as `null` and validates counters before arithmetic. The Bash wrappers retain the shell API while avoiding hand-built JSON from filenames, hostnames or process commands.

```python
#!/usr/bin/env python3
"""Collectors for the chapter's extracted monitor_data.py teaching module.

Linux procfs/sysfs are inputs, not guarantees of a coherent system snapshot.
Fixture paths permit deterministic tests; unreadable/invalid input is unavailable.
"""
import csv
import io
import json
import math
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
import time


def emit(data, form='json', fields=None):
    if form == 'json': print(json.dumps(data, ensure_ascii=False, allow_nan=False))
    elif form == 'percent': print(data['percent_used'])
    elif form == 'raw':
        print(' '.join(f'{k}={v}' for k, v in data.items() if isinstance(v, (int, float))))
    elif form == 'csv':
        writer = csv.writer(sys.stdout, lineterminator='\n')
        rows = data if isinstance(data, list) else [data]
        for row in rows: writer.writerow([row.get(k, '') for k in (fields or row.keys())])
    elif form in ('human', 'text'):
        print(json.dumps(data, ensure_ascii=False, indent=2, allow_nan=False))
    else: raise ValueError('Unknown output format')


def memory():
    data = {}
    for line in Path(os.environ.get('PROC_MEMINFO', '/proc/meminfo')).read_text().splitlines():
        parts = line.replace(':', ' ').split()
        if len(parts) >= 2 and re.fullmatch(r'[0-9]+', parts[1]): data[parts[0]] = int(parts[1])
    required = ('MemTotal', 'MemAvailable', 'MemFree', 'Buffers', 'Cached', 'SwapTotal', 'SwapFree')
    if not all(k in data for k in required): raise ValueError('Required memory fields unavailable')
    total, available, swap, swap_free = (data[k] for k in ('MemTotal', 'MemAvailable', 'SwapTotal', 'SwapFree'))
    if total <= 0 or not 0 <= available <= total or not 0 <= swap_free <= swap:
        raise ValueError('Inconsistent memory counters')
    used = total - available
    return dict(total_kb=total, used_kb=used, available_kb=available, free_kb=data['MemFree'],
                buffers_kb=data['Buffers'], cached_kb=data['Cached'], percent_used=round(100*used/total, 1),
                swap_total_kb=swap, swap_used_kb=swap-swap_free,
                swap_percent=round(100*(swap-swap_free)/swap, 1) if swap else 0.0)


def disk(path):
    if not Path(path).is_dir(): raise ValueError('Directory unavailable')
    st = os.statvfs(path)
    size, used, available = (st.f_blocks*st.f_frsize,
                            (st.f_blocks-st.f_bfree)*st.f_frsize, st.f_bavail*st.f_frsize)
    denominator = used + available  # The df-style user-available denominator.
    return dict(mount_point=path, size_bytes=size, used_bytes=used, available_bytes=available,
                percent_used=math.ceil(100*used/denominator) if denominator else 0,
                io_stats=None)


def processes(limit, order):
    if not re.fullmatch(r'[1-9][0-9]{0,4}', limit): raise ValueError('Positive process limit required')
    key = {'cpu': '-pcpu', 'memory': '-pmem', 'pid': 'pid', 'time': '-time'}.get(order)
    if key is None: raise ValueError('Unknown process sort')
    output = subprocess.run(['ps', '-ax', '--no-headers', '-o',
        'pid,user,pcpu,pmem,vsz,rss,stat,start,time,comm', '--sort='+key],
        check=True, capture_output=True, text=True).stdout
    rows = []
    for line in output.splitlines():
        p = line.split(None, 9)
        if len(p) != 10: raise ValueError('Malformed ps record')
        rows.append(dict(pid=int(p[0]), user=p[1], cpu=float(p[2]), mem=float(p[3]),
                         vsz_kb=int(p[4]), rss_kb=int(p[5]), stat=p[6], start=p[7],
                         time=p[8], command=p[9]))
    threads = subprocess.run(['ps', '-axH', '--no-headers', '-o', 'pid'],
                             check=True, capture_output=True, text=True).stdout
    return dict(total_processes=len(rows), total_threads=len(threads.splitlines()),
                zombie_processes=sum(r['stat'].startswith('Z') for r in rows),
                top_processes=rows[:int(limit)])


def cpu_snapshot(path):
    result = {}
    for line in Path(path).read_text().splitlines():
        parts = line.split()
        if parts and re.fullmatch(r'cpu[0-9]+', parts[0]):
            if len(parts) < 9 or not all(re.fullmatch(r'[0-9]+', v) for v in parts[1:9]):
                raise ValueError('Invalid CPU counters')
            values = list(map(int, parts[1:9]))
            result[parts[0]] = (sum(values), values[3] + values[4])
    return result


def per_cpu():
    interval = float(os.environ.get('CPU_SAMPLE_INTERVAL', '1'))
    if not math.isfinite(interval) or not 0 <= interval <= 60: raise ValueError('Invalid sample interval')
    path = os.environ.get('CPU_STAT_PATH', '/proc/stat')
    before = cpu_snapshot(path); time.sleep(interval)
    after = cpu_snapshot(os.environ.get('CPU_STAT_SECOND_PATH', path))
    result = []
    for name, (total, idle) in sorted(after.items(), key=lambda p: int(p[0][3:])):
        usage = None
        if name in before:
            dt, di = total-before[name][0], idle-before[name][1]
            if dt > 0 and 0 <= di <= dt: usage = round(100*(dt-di)/dt, 1)
        result.append(dict(core=int(name[3:]), usage=usage,
                           status='OK' if usage is not None else 'UNAVAILABLE'))
    return dict(cpu_count=len(result), per_cpu=result)


def load():
    proc = Path(os.environ.get('PROC_ROOT', '/proc'))
    p = (proc/'loadavg').read_text().split(); running, total = map(int, p[3].split('/'))
    lines = {x.split()[0]: x.split()[1:] for x in (proc/'stat').read_text().splitlines()}
    return dict(load_average=dict(zip(('1min', '5min', '15min'), map(float, p[:3]))),
                processes=dict(running=running, total=total),
                context_switches=int(lines['ctxt'][0]), interrupts=int(lines['intr'][0]))


def io_stats(device):
    root = Path(os.environ.get('SYS_BLOCK', '/sys/block'))
    if device and not re.fullmatch(r'[A-Za-z0-9._-]+', device): raise ValueError('Invalid block device name')
    directories = [root/device] if device else sorted(p for p in root.iterdir() if not p.name.startswith('loop'))
    rows = []
    for path in directories:
        parts = (path/'stat').read_text().split()
        if len(parts) < 11: raise ValueError('At least eleven block counters required')
        values = list(map(int, parts[:11]))  # Discard/flush fields do not enter weighted_time.
        if any(v < 0 for v in values): raise ValueError('Negative block counter')
        rows.append(dict(device=path.name, reads=values[0], writes=values[4],
                         read_bytes=values[2]*512, write_bytes=values[6]*512,
                         io_time_ms=values[9], weighted_io_time_ms=values[10]))
    return dict(io_stats=rows)


def network(interface):
    rows = []
    for line in Path(os.environ.get('PROC_NET_DEV', '/proc/net/dev')).read_text().splitlines():
        if ':' not in line: continue
        name, values = line.rsplit(':', 1); name = name.strip()
        if interface and name != interface: continue
        values = list(map(int, values.split()))
        if len(values) < 16 or any(v < 0 for v in values): raise ValueError('Invalid network counters')
        rows.append(dict(interface=name, rx_bytes=values[0], rx_packets=values[1],
                         rx_errors=values[2], rx_dropped=values[3], tx_bytes=values[8],
                         tx_packets=values[9], tx_errors=values[10], tx_dropped=values[11]))
    return dict(network_stats=rows)


def temperatures():
    root = Path(os.environ.get('SYS_ROOT', '/sys'))
    rows = []
    for path in sorted((root/'class/thermal').glob('thermal_zone*')):
        try: rows.append(dict(zone=(path/'type').read_text().strip(), temp_celsius=int((path/'temp').read_text())/1000))
        except (OSError, ValueError): rows.append(dict(zone=path.name, temp_celsius=None, status='UNAVAILABLE'))
    for path in sorted((root/'class/hwmon').glob('hwmon*')):
        for source in sorted(path.glob('temp*_input')):
            try:
                label = source.with_name(source.name.replace('_input', '_label'))
                name = (path/'name').read_text().strip()+'/'+(label.read_text().strip() if label.exists() else source.stem)
                rows.append(dict(zone=name, temp_celsius=int(source.read_text())/1000))
            except (OSError, ValueError): rows.append(dict(zone=source.name, temp_celsius=None, status='UNAVAILABLE'))
    return dict(temperatures=rows)


def main():
    action, form, *args = sys.argv[1:]
    if action == 'memory': data = memory()
    elif action == 'disk': data = disk(args[0])
    elif action == 'processes': data = processes(*args)
    elif action == 'per_cpu': data = per_cpu()
    elif action == 'load': data = load()
    elif action == 'io': data = io_stats(args[0] if args else '')
    elif action == 'network': data = network(args[0] if args else '')
    elif action == 'temperature': data = temperatures()
    else: raise ValueError('Unknown collector')
    emit(data, form)


if __name__ == '__main__':
    try: main()
    except (OSError, ValueError, KeyError, IndexError, subprocess.CalledProcessError) as error:
        print('Collector unavailable: '+str(error), file=sys.stderr)
        raise SystemExit(2)
```

The following wrapper exports `MONITOR_DATA_PATH` when an extracted fixture module is used. `raw` returns numeric `key=value` fields; `percent` returns exactly one numeric percentage; `json`, `csv` and `human` are distinct formats.


```bash
_monitor_data() {
    python3 "${MONITOR_DATA_PATH:-${LIB_DIR:?Set LIB_DIR}/monitor_data.py}" "$@"
}
get_memory_info() { _monitor_data memory "${1:-human}"; }
```

**Key Concepts:**

1. **MemAvailable vs MemFree**: `MemAvailable` (introduced in kernel 3.14) indicates memory available for new applications, including cache that can be freed. It is more relevant than `MemFree`.

2. **Buffers and Cached**: The Linux kernel uses "free" memory for I/O cache. This can be freed when needed.

3. **Swap**: Virtual memory on disk, used when physical RAM is insufficient.

### 3.3 The get_disk_usage() Function

```bash
get_disk_usage() { _monitor_data disk "${2:-human}" "${1:-/}"; }
```

### 3.4 The get_process_info() Function

```bash
get_process_info() { _monitor_data processes "${3:-human}" "${1:-10}" "${2:-cpu}"; }
```

### 3.5 The check_thresholds() Function

```bash
metric_status() {
    local metric=$1 value=$2
    python3 - "$value" "$(get_config "${metric}_warning" 80)" "$(get_config "${metric}_critical" 95)" <<'PY'
import math,sys
try:
    value,warning,critical=map(float,sys.argv[1:])
    if not all(map(math.isfinite,(value,warning,critical))) or not 0<=value<=100 or not 0<=warning<critical<=100:
        raise ValueError()
    print('CRITICAL' if value>=critical else 'WARNING' if value>=warning else 'OK')
except ValueError:
    print('UNAVAILABLE')
    raise SystemExit(3)
PY
}
check_thresholds() {
    local metric=$1 value=$2 status
    status=$(metric_status "$metric" "$value") || return 3
    case $status in
        OK) return 0;;
        WARNING) send_alert WARNING "$metric" "$value" "$(get_config "${metric}_warning" 80)" || return 3; return 1;;
        CRITICAL) send_alert CRITICAL "$metric" "$value" "$(get_config "${metric}_critical" 95)" || return 3; return 2;;
    esac
}
send_alert() {
    local level=$1 metric=$2 value=$3 threshold=$4 timestamp alert_program alert_file
    timestamp=$(date -Iseconds) || return 1
    log_message "$level" "[$metric] Value $value, threshold $threshold" || return 1
    alert_program=$(get_config alert_command '')
    if [[ -n $alert_program ]]; then
        # One executable path, not shell source; arguments are separate strings.
        ALERT_LEVEL=$level ALERT_METRIC=$metric ALERT_VALUE=$value ALERT_THRESHOLD=$threshold \
            ALERT_TIMESTAMP=$timestamp "$alert_program" || return 1
    fi
    alert_file=$(get_config alert_file '')
    if [[ -n $alert_file ]]; then
        printf '%s [%s] %s: %s (threshold: %s)\n' "$timestamp" "$level" "$metric" "$value" "$threshold" >> "$alert_file" || return 1
    fi
    return 0
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
    [[ -v LOG_LEVELS[${LOG_LEVEL:-INFO}] && -v LOG_LEVELS[$level] ]] || return 2
    min_level="${LOG_LEVELS[${LOG_LEVEL:-INFO}]}"
    current_level="${LOG_LEVELS[$level]}"
    
    [[ $current_level -lt $min_level ]] && return 0
    
    # Format the message
    local formatted_message="[$timestamp] [$level] $message"
    
    # Write to log file if defined
    if [[ -n "${LOG_FILE:-}" ]]; then
        printf '%s\n' "$formatted_message" >> "$LOG_FILE" || return 1
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
    python3 - "${1:-0}" "${2:-2}" <<'PY'
import sys
from decimal import Decimal
try:
    raw,precision=sys.argv[1:]; precision=int(precision)
    if not raw.isdigit() or not 0<=precision<=8: raise ValueError()
    value=Decimal(raw); units=('B','KiB','MiB','GiB','TiB','PiB'); unit=0
    while value>=1024 and unit<len(units)-1: value/=1024; unit+=1
    print(f'{value:.{precision}f} {units[unit]}',end='')
except ValueError: raise SystemExit(2)
PY
}
format_duration() {
    local seconds=${1:-0}
    [[ $seconds =~ ^[0-9]{1,12}$ ]] || return 2
    seconds=$((10#$seconds))
    if ((seconds < 60)); then printf '%ss' "$seconds"
    elif ((seconds < 3600)); then printf '%dm %ds' "$((seconds/60))" "$((seconds%60))"
    elif ((seconds < 86400)); then printf '%dh %dm' "$((seconds/3600))" "$((seconds%3600/60))"
    else printf '%dd %dh' "$((seconds/86400))" "$((seconds%86400/3600))"; fi
}
format_percentage() {
    python3 - "$1" "${2:-1}" "${3:-20}" <<'PY'
import math,sys
try:
    value=float(sys.argv[1]); decimals=int(sys.argv[2]); width=int(sys.argv[3])
    if not math.isfinite(value) or not 0<=value<=100 or not 0<=decimals<=8 or not 1<=width<=200: raise ValueError()
    filled=int(value*width/100+0.5)
    print('['+'█'*filled+'░'*(width-filled)+f'] {value:.{decimals}f}%',end='')
except ValueError: raise SystemExit(2)
PY
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
    
    if [[ -v _CACHE[$key] ]] && [[ ${_CACHE_EXPIRY[$key]:-0} -gt $now ]]; then
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
    
    set_defaults
    CONFIG_FILE=""
    if [[ -n $config_file && ! -r $config_file ]]; then return 2; fi
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
    parse_config_file "$CONFIG_FILE" || return 2
    
    # Validate configuration
    validate_config || return 1
    
    CONFIG_LOADED=true
    return 0
}

parse_config_file() {
    local file="$1"
    local line_num=0
    
    while IFS= read -r line || [[ -n "$line" ]]; do
        line_num=$((line_num + 1))
        
        # Ignore empty lines and comments
        [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue
        
        # Remove leading/trailing whitespace
        line="${line#"${line%%[![:space:]]*}"}"
        line="${line%"${line##*[![:space:]]}"}"
        
        # Check key=value format
        if [[ "$line" =~ ^([a-zA-Z_][a-zA-Z0-9_]*)=(.*)$ ]]; then
            local key="${BASH_REMATCH[1]}"
            local value="${BASH_REMATCH[2]}"
            
            # Literal data: optional matching outer quotes; no expansion or inline comments.
            if [[ $value == \"* || $value == \'* ]]; then
                local quote=${value:0:1}
                [[ ${#value} -ge 2 && ${value: -1} == "$quote" ]] || return 2
                value=${value:1:${#value}-2}
            fi
            [[ -v CONFIG[$key] ]] || { log_error "Unknown config key: $key"; return 2; }
            CONFIG["$key"]="$value"
            log_debug "Config: $key = $value"
        else
            log_error "Invalid config line $line_num"
            return 2
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
                    errors=$((errors + 1))
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
            errors=$((errors + 1))
        fi
    done
    
    # Validate monitoring interval
    local interval="${CONFIG[monitor_interval]:-5}"
    if ! is_positive_integer "$interval"; then
        log_error "Invalid monitor_interval: $interval"
        errors=$((errors + 1))
    fi
    
    # Validation is read-only. Open/create log destinations only after the plan is accepted.
    
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
    CONFIG[alert_file]=""
    
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
declare -g SINGLE_RUN=true
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
  -d, --daemon            Run a foreground continuous loop
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
  $SCRIPT_NAME                    # One sample, human format
  $SCRIPT_NAME -1 -f json         # Single run, JSON output
  $SCRIPT_NAME --cpu --memory     # Only CPU and memory
  $SCRIPT_NAME -d -i 60           # Daemon with 60 second interval

EOF
}

parse_arguments() {
    local metrics_specified=false
    
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -c|--config|-f|--format|-i|--interval|--cpu-warning|--cpu-critical|--mem-warning|--mem-critical)
                [[ $# -ge 2 && -n $2 ]] || { log_error "Missing value for $1"; return 2; };;
        esac
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
                SINGLE_RUN=false
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
    local cpu=null memory=null processes=null disks='[]' value status mount row rc=0 alert_rc
    local -a mounts=()
    if $MONITOR_CPU; then
        if value=$(get_cpu_usage); then
            if status=$(metric_status cpu "$value"); then :; else status=UNAVAILABLE; fi
            cpu=$(python3 -c 'import json,sys; print(json.dumps({"value":float(sys.argv[1]),"unit":"%","status":sys.argv[2]}))' "$value" "$status") || return 2
            if check_thresholds cpu "$value"; then :; else alert_rc=$?; ((alert_rc <= 2)) || rc=1; fi
        else rc=1; fi
    fi
    if $MONITOR_MEMORY; then
        if memory=$(get_memory_info json); then
            value=$(python3 -c 'import json,sys; print(json.loads(sys.argv[1])["percent_used"])' "$memory") || return 2
            if check_thresholds memory "$value"; then :; else alert_rc=$?; ((alert_rc <= 2)) || rc=1; fi
        else memory=null; rc=1; fi
    fi
    if $MONITOR_DISK; then
        IFS=',' read -ra mounts <<< "$(get_config disk_mounts /)"
        for mount in "${mounts[@]}"; do
            if row=$(get_disk_usage "$mount" json); then
                value=$(python3 -c 'import json,sys; print(json.loads(sys.argv[1])["percent_used"])' "$row") || return 2
                if check_thresholds disk "$value"; then :; else alert_rc=$?; ((alert_rc <= 2)) || rc=1; fi
            else row=null; rc=1; fi
            disks=$(python3 -c 'import json,sys; a=json.loads(sys.argv[1]); a.append({"mount":sys.argv[2],"reading":json.loads(sys.argv[3])}); print(json.dumps(a))' "$disks" "$mount" "$row") || return 2
        done
    fi
    if $MONITOR_PROCESSES; then
        if processes=$(get_process_info "$(get_config top_processes 10)" "$(get_config process_sort cpu)" json); then :
        else processes=null; rc=1; fi
    fi
    python3 - "$OUTPUT_FORMAT" "$(get_hostname)" "$cpu" "$memory" "$disks" "$processes" <<'PY'
import csv,datetime,json,sys
form,host,*values=sys.argv[1:]
metrics=dict(zip(('cpu','memory','disks','processes'),map(json.loads,values)))
timestamp=datetime.datetime.now(datetime.timezone.utc).isoformat()
document={'timestamp':timestamp,'hostname':host,'metrics':metrics}
if form=='json': print(json.dumps(document,ensure_ascii=False,allow_nan=False))
elif form=='csv':
    w=csv.writer(sys.stdout,lineterminator='\n')
    for name,value in metrics.items(): w.writerow((timestamp,host,name,json.dumps(value,ensure_ascii=False)))
else: print(json.dumps(document,ensure_ascii=False,indent=2,allow_nan=False))
PY
    local format_rc=$?
    ((format_rc == 0)) || return "$format_rc"
    return "$rc"
}

# A standalone metric formatter. Aggregate output is built once above, never by commas interleaved with diagnostics.
output_metric() {
    local name=$1 value=$2 unit=${3:-} status
    if status=$(metric_status "$name" "$value"); then :; else status=UNAVAILABLE; fi
    python3 - "$name" "$value" "$unit" "$status" <<'PY'
import json,sys
name,value,unit,status=sys.argv[1:]
print(json.dumps({name:{'value':None if status=='UNAVAILABLE' else float(value),'unit':unit,'status':status}}))
PY
}
```

### 6.4 Main Function and Cleanup

```bash
# The loop remains in the foreground. A supervisor owns backgrounding/restarts.
declare -g RUNNING=true MONITOR_LOCK_FD=''
cleanup() {
    local rc=$?
    if [[ -n $MONITOR_LOCK_FD ]]; then exec {MONITOR_LOCK_FD}>&-; fi
    return "$rc"
}
daemonize() {
    : "${MONITOR_LOCK_DIR:?Set an existing owned lock directory for continuous mode}"
    [[ -d $MONITOR_LOCK_DIR ]] || return 2
    exec {MONITOR_LOCK_FD}>>"$MONITOR_LOCK_DIR/monitor.lock" || return 1
    flock -n "$MONITOR_LOCK_FD" || { exec {MONITOR_LOCK_FD}>&-; MONITOR_LOCK_FD=''; return 1; }
    # Never unlink a flock pathname: later contenders must open the same inode.
}
main() {
    local -a arguments=("$@")
    local i config='' interval
    for ((i=0; i<${#arguments[@]}; i++)); do
        if [[ ${arguments[i]} == -c || ${arguments[i]} == --config ]]; then
            ((i+1 < ${#arguments[@]})) || return 2
            config=${arguments[i+1]}
        fi
    done
    load_config "$config" || return 2
    OUTPUT_FORMAT=$(get_config output_format human)
    parse_arguments "${arguments[@]}" || return 2  # CLI overrides file/defaults.
    case $OUTPUT_FORMAT in human|text|json|csv) :;; *) return 2;; esac
    validate_config || return 2
    trap cleanup EXIT
    trap 'exit 130' INT
    trap 'exit 143' TERM
    trap 'exit 129' HUP
    if $DAEMON_MODE; then daemonize || return 1; fi
    if $SINGLE_RUN; then run_monitoring_cycle; return $?; fi
    interval=$(get_config monitor_interval 5)
    while $RUNNING; do
        if run_monitoring_cycle; then :; else log_warning 'Some metrics unavailable'; fi
        sleep "$interval" || return 1
    done
}
if [[ ${BASH_SOURCE[0]} == "$0" ]]; then main "$@"; fi
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
get_per_cpu_usage() { _monitor_data per_cpu json; }
```

### 8.2 Load Average and Context Switches Monitoring

```bash
get_system_load() { _monitor_data load json; }
```

### 8.3 I/O and Network Monitoring

```bash
get_io_stats() { _monitor_data io json "${1:-}"; }
get_network_stats() { _monitor_data network json "${1:-}"; }
```

### 8.4 Temperature and Sensor Monitoring

```bash
get_temperature_info() { _monitor_data temperature json; }
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

### Technical reference for the corrected examples

The counter fields and iowait limitations follow the [Linux kernel procfs documentation](https://docs.kernel.org/filesystems/proc.html).
