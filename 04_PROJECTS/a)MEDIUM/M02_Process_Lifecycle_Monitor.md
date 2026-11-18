# M02: Process Lifecycle Monitor

> **Level:** MEDIUM | **Estimated time:** 25-35 hours | **K8s Bonus:** +10%

---

## Description

Advanced tool for monitoring process lifecycle: observed tracking with explicitly stated sampling and event-source limits, real-time resource monitoring (CPU, memory, I/O), process hierarchy visualisation and alerting on anomalies or critical events.

The system provides both interactive terminal monitoring (dashboard) and daemon mode for continuous logging and automatic alerting when monitored processes exceed thresholds or stop unexpectedly.

---

## Learning Objectives

- The /proc filesystem and process information
- Signals and process lifecycle
- Resource monitoring (CPU, memory, I/O)
- Process tree visualisation (ppid, children)
- Real-time alerting and notifications
- Terminal dashboard with ncurses/ANSI

---

## Functional Requirements

**Evidence contract:** polling observes presence at sampling instants; it can miss
short-lived processes, exec transitions and PID reuse. Attached arbitrary processes
have `exit_cause=unknown` after disappearance. Exit status/signals require a supervised
child (`wait`) or a documented event backend. Identify processes by boot ID, PID and
`/proc/PID/stat` start time. The choice of assessed supervised/event-backed guarantees
remains an author decision; the requirements below retain that open scope and must
not be graded as complete crash detection from polling alone.

### Mandatory (for passing grade)

1. **Specific process monitoring**
   - By exact PID
   - By process name (pgrep style)
   - By regex pattern in command line
   - Multiple simultaneous monitoring

2. **Resource tracking**
   - CPU usage (% and total time)
   - Memory (RSS, VSZ, shared)
   - I/O (bytes read/written)
   - Open file descriptors
   - Thread count

3. **Process hierarchy**
   - Tree display (parent → children)
   - Fork/exec tracking
   - Resource aggregation per tree

4. **Event detection**
   - New process start
   - Stop/exit (with exit code)
   - Crash (SIGSEGV, SIGABRT, etc.)
   - Restart (same name, new PID)

5. **Alerting**
   - On CPU/memory threshold exceeded
   - On events (crash, stop)
   - Desktop/email/webhook notification

6. **History**
   - Event log with timestamp
   - Periodic metrics (sampling)
   - Export for analysis

7. **Terminal dashboard**
   - Real-time visualisation
   - Configurable refresh
   - ASCII graphs for trend

### Optional (for full marks)

8. **Auto-restart** - Automatic restart of critical processes on crash
9. **Profiling** - Usage pattern analysis over time
10. **Prometheus export** - Metrics in Prometheus format
11. **Correlation** - Grouping related processes (services)
12. **Resource limits** - Alerting based on cgroups
13. **Web dashboard** - Simple HTTP interface

---

## CLI Interface

```text
./procmon.sh <command> [options]

Commands:
  watch <target>          Interactive monitoring
  daemon <target>         Run as daemon (background)
  status [target]         Quick process status
  tree [pid]              Display process tree
  history [target]        Event history
  alerts                  Manage alerts
  stop                    Stop the daemon

Target (specification modes):
  1234                    Exact PID
  nginx                   Process name
  "python.*server"        Regex pattern
  @service:mysql          All processes of a service

Monitoring options:
  -i, --interval SEC      Refresh interval (default: 2)
  -d, --duration MIN      Monitoring duration (default: infinite)
  -c, --children          Include child processes
  -r, --recursive         Monitor new subprocesses too

Alerting options:
  --cpu-alert N           Alert when CPU > N%
  --mem-alert N           Alert when memory > N MB
  --fd-alert N            Alert when FD count > N
  --on-exit CMD           Command on process termination
  --on-crash CMD          Command on crash
  --auto-restart          Automatic restart on crash

Output options:
  -l, --log FILE          Save log
  -o, --output FORMAT     Format: text|json|csv
  -q, --quiet             No terminal output
  -v, --verbose           Detailed output

Examples:
  ./procmon.sh watch nginx
  ./procmon.sh watch 1234 -i 1 --cpu-alert 80
  ./procmon.sh daemon mysql --auto-restart --on-crash "notify.sh"
  ./procmon.sh tree 1
  ./procmon.sh status "python.*"
  ./procmon.sh history nginx --since "1 hour ago"
```

---

## Output Examples

Synthetic illustrations. Crash/restart causes require the named event backend; these are not polling results.

### Monitoring Dashboard

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                    PROCESS LIFECYCLE MONITOR                                 ║
║                    Target: nginx (master + workers)                          ║
╚══════════════════════════════════════════════════════════════════════════════╝

MONITORED PROCESSES (4)
═══════════════════════════════════════════════════════════════════════════════

PID     PPID    USER     STATE   CPU%   MEM(MB)   I/O(KB/s)   FDs   CMD
─────────────────────────────────────────────────────────────────────────────────
1234    1       root     S       0.1    12.3      0/0         15    nginx: master
1235    1234    www-data S       2.3    45.6      125/45      128   nginx: worker
1236    1234    www-data S       1.8    44.2      118/42      125   nginx: worker
1237    1234    www-data S       2.1    46.1      132/48      130   nginx: worker

TOTALS:  CPU: 6.3%  |  Memory: 148.2 MB  |  I/O: 375/135 KB/s  |  FDs: 398

RESOURCE HISTORY (last 5 min)
═══════════════════════════════════════════════════════════════════════════════

CPU %:
  10│                    ▄▄                                        
   5│  ▄▄    ▄▄▄▄▄▄▄▄▄▄████▄▄▄▄▄▄▄▄▄▄    ▄▄▄▄                    
   0│▄████▄▄██████████████████████████▄▄██████▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄
    └──────────────────────────────────────────────────────────────
     -5m                    -2.5m                    now

Memory MB:
 150│████████████████████████████████████████████████████████████████
 100│                                                                
  50│                                                                
    └──────────────────────────────────────────────────────────────

EVENTS (last hour)
═══════════════════════════════════════════════════════════════════════════════
  17:45:23  ✓ Worker 1237 started (PID: 1237)
  17:45:23  ✓ Worker 1236 started (PID: 1236)
  17:45:23  ✓ Worker 1235 started (PID: 1235)
  17:45:22  ✓ Master process started (PID: 1234)
  17:30:00  ⚠ Config reload triggered
  17:15:45  ✗ Worker crashed (PID: 1238, SIGSEGV) - auto-restarted

ALERTS
═══════════════════════════════════════════════════════════════════════════════
  ⚠ Active: 0  |  Triggered today: 3  |  Last: 17:15:45 (worker crash)

───────────────────────────────────────────────────────────────────────────────
Refresh: 2s | Uptime: 4h 32m | Press 'q' to quit, 'h' for help
```

### Process Tree

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                    PROCESS TREE                                              ║
║                    Root: PID 1234 (nginx)                                    ║
╚══════════════════════════════════════════════════════════════════════════════╝

nginx (1234) [root] S 0.1% CPU, 12.3 MB
├── nginx: worker (1235) [www-data] S 2.3% CPU, 45.6 MB
│   └── (128 file descriptors)
├── nginx: worker (1236) [www-data] S 1.8% CPU, 44.2 MB
│   └── (125 file descriptors)
├── nginx: worker (1237) [www-data] S 2.1% CPU, 46.1 MB
│   └── (130 file descriptors)
└── nginx: cache manager (1238) [www-data] S 0.0% CPU, 8.4 MB
    └── (12 file descriptors)

TREE SUMMARY
═══════════════════════════════════════════════════════════════════════════════
  Total processes:  5
  Total threads:    23
  Total CPU:        6.3%
  Total Memory:     156.6 MB
  Total FDs:        410
  
  Deepest level:    2
  Widest level:     4 (level 1)
```

### Quick Status

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                    PROCESS STATUS: mysql                                     ║
╚══════════════════════════════════════════════════════════════════════════════╝

SUMMARY
═══════════════════════════════════════════════════════════════════════════════
  Process:          mysqld
  PID:              2345
  Status:           Running (S - sleeping)
  Uptime:           15d 4h 23m
  Started:          2025-01-05 12:30:00
  User:             mysql
  Nice:             0

CURRENT RESOURCES
═══════════════════════════════════════════════════════════════════════════════
  CPU Usage:        12.3% (user: 10.1%, sys: 2.2%)
  Memory RSS:       1,234 MB
  Memory VSZ:       2,456 MB
  Memory %:         15.2% of system
  Threads:          45
  File Descriptors: 234 / 65536 (0.4%)
  
  I/O Read:         45.2 MB/s
  I/O Write:        12.3 MB/s
  Network:          2.1 MB/s in, 1.8 MB/s out

LIMITS
═══════════════════════════════════════════════════════════════════════════════
  Max FDs:          65536
  Max Memory:       unlimited
  Max CPU:          unlimited
  OOM Score:        0 (current score; not proof of protection)
  OOM adjustment:   0 (no explicit protection adjustment)

HEALTH CHECK: ✓ HEALTHY
  All metrics within normal range
```

### Event History

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                    EVENT HISTORY: nginx                                      ║
║                    Period: last 24 hours                                     ║
╚══════════════════════════════════════════════════════════════════════════════╝

2025-01-20 17:45:23  ✓ START    Master process started (PID: 1234)
2025-01-20 17:45:23  ✓ START    Worker spawned (PID: 1235, parent: 1234)
2025-01-20 17:45:23  ✓ START    Worker spawned (PID: 1236, parent: 1234)
2025-01-20 17:45:23  ✓ START    Worker spawned (PID: 1237, parent: 1234)
2025-01-20 17:30:00  ℹ CONFIG   Reload signal received (SIGHUP)
2025-01-20 17:15:45  ✗ CRASH    Worker crashed (PID: 1238)
                                Signal: SIGSEGV (Segmentation fault)
                                Core dump: /var/crash/nginx.1238.core
2025-01-20 17:15:46  ✓ RESTART  Worker auto-restarted (new PID: 1237)
2025-01-20 15:00:00  ⚠ ALERT    CPU threshold exceeded (85% > 80%)
2025-01-20 15:00:30  ℹ RECOVER  CPU returned to normal (45%)
2025-01-20 12:00:00  ✓ START    Service started after system boot

STATISTICS
═══════════════════════════════════════════════════════════════════════════════
  Total events:     12
  Starts:           5
  Stops:            0
  Crashes:          1
  Restarts:         1
  Alerts:           2
  Config reloads:   1
```

---

## Configuration File

```yaml
# /etc/procmon/procmon.conf

# General settings
general:
  log_file: /var/log/procmon.log
  pid_file: /var/run/procmon.pid
  data_dir: /var/lib/procmon
  
# Monitoring settings
monitoring:
  default_interval: 2        # seconds
  history_retention: 7       # days
  sample_rate: 60            # seconds between samples for history
  
# Processes to monitor (for daemon mode)
targets:
  - name: nginx
    pattern: "nginx"
    children: true
    alerts:
      cpu: 80
      memory: 512    # MB
      fd: 1000
    actions:
      on_crash: "/opt/scripts/notify.sh nginx crash"
      auto_restart: false
      
  - name: mysql
    pattern: "mysqld"
    alerts:
      cpu: 90
      memory: 4096
    actions:
      on_crash: "/opt/scripts/notify.sh mysql crash"
      auto_restart: true
      restart_cmd: "systemctl restart mysql"
      restart_delay: 5
      max_restarts: 3

# Alerting
alerting:
  email:
    enabled: false
    to: admin@example.com
    smtp_server: localhost
  desktop:
    enabled: true
  webhook:
    enabled: false
    url: ""

# Dashboard
dashboard:
  refresh_rate: 2
  show_graphs: true
  graph_history: 300   # seconds
```

---

## Project Structure

```
M02_Process_Lifecycle_Monitor/
├── README.md
├── Makefile
├── src/
│   ├── procmon.sh               # Main script
│   └── lib/
│       ├── config.sh            # Configuration parsing
│       ├── process.sh           # /proc reading functions
│       ├── monitor.sh           # Monitoring logic
│       ├── tree.sh              # Tree building
│       ├── events.sh            # Event detection
│       ├── alerts.sh            # Alerting system
│       ├── dashboard.sh         # Terminal UI
│       ├── history.sh           # History and logging
│       └── actions.sh           # Auto-restart, commands
├── etc/
│   └── procmon.conf.example
├── tests/
│   ├── test_process.sh
│   ├── test_monitor.sh
│   └── test_tree.sh
└── docs/
    ├── INSTALL.md
    └── ALERTS.md
```

---

## Implementation Hints

### Reading process information from /proc

```bash
#!/bin/bash
set -euo pipefail

get_process_info() {
    local pid="$1"
    [[ $pid =~ ^[1-9][0-9]*$ ]] || return 2
    local proc_dir="/proc/$pid"
    
    # Check if process exists
    [[ -d "$proc_dir" ]] || return 1
    
    # General status
    local status_file="$proc_dir/status"
    local name state ppid uid threads vmrss
    
    name=$(awk '/^Name:/ {sub(/^Name:[[:space:]]*/, ""); print; found=1; exit} END {if(!found) exit 1}' "$status_file") || return 1
    state=$(awk '/^State:/ {print $2}' "$status_file") || return 1
    ppid=$(awk '/^PPid:/ {print $2}' "$status_file") || return 1
    uid=$(awk '/^Uid:/ {print $2}' "$status_file") || return 1
    threads=$(awk '/^Threads:/ {print $2}' "$status_file") || return 1
    vmrss=$(awk '/^VmRSS:/ {print $2; found=1} END {if(!found) print "unavailable"}' "$status_file") || return 1
    [[ -n $state && $ppid =~ ^[0-9]+$ && $uid =~ ^[0-9]+$ && $threads =~ ^[0-9]+$ ]] || return 1
    [[ $vmrss == unavailable || $vmrss =~ ^[0-9]+$ ]] || return 1
    
    # CPU time from /proc/[pid]/stat
    local stat_fields
    local stat_line
    stat_line=$(<"$proc_dir/stat") || return 1
    # comm is parenthesised and may contain spaces or ')'; strip through its final ') '.
    IFS=' ' read -ra stat_fields <<< "${stat_line##*) }"
    [[ ${#stat_fields[@]} -ge 20 ]] || return 1
    local utime="${stat_fields[11]}" stime="${stat_fields[12]}"
    local starttime="${stat_fields[19]}"
    [[ $utime =~ ^[0-9]+$ && $stime =~ ^[0-9]+$ && $starttime =~ ^[0-9]+$ ]] || return 1
    
    # File descriptors
    local fd_count
    fd_count=$(find "$proc_dir/fd" -mindepth 1 -maxdepth 1 -printf "." 2>/dev/null | wc -c) || return 1
    
    # Command line
    local cmdline
    cmdline=$(tr '\0' ' ' < "$proc_dir/cmdline" 2>/dev/null) || return 1
    # Human display transport: escape delimiters/newlines, not a lossless process database.
    name=${name//|/%7C}; name=${name//$'\n'/%0A}
    cmdline=${cmdline//|/%7C}; cmdline=${cmdline//$'\n'/%0A}
    
    # Output
    printf "%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s\n" \
        "$pid" "$name" "$state" "$ppid" "$uid" \
        "$threads" "$vmrss" "$utime" "$stime" \
        "$fd_count" "$cmdline"
}

# Calculate CPU usage
read_process_ticks() {
    local pid="$1" line
    [[ $pid =~ ^[1-9][0-9]*$ ]] || return 2
    line=$(cat "/proc/$pid/stat") || return 1
    local -a fields
    IFS=' ' read -r -a fields <<< "${line##*) }"
    [[ ${#fields[@]} -ge 20 && ${fields[19]} =~ ^[0-9]+$ ]] || return 1
    printf '%s %s\n' "${fields[19]}" "$((${fields[11]} + ${fields[12]}))"
}

calculate_cpu_usage() {
    local pid="$1" interval="${2:-1}" before after start1 start2 ticks1 ticks2 total1 total2
    [[ $interval =~ ^[0-9]+([.][0-9]+)?$ ]] || return 2
    before=$(read_process_ticks "$pid") || return 1
    IFS=' ' read -r start1 ticks1 <<< "$before"
    total1=$(awk '$1=="cpu" {s=0; for(i=2;i<=9;i++) s+=$i; print s; exit}' /proc/stat) || return 1
    sleep "$interval" || return 1
    after=$(read_process_ticks "$pid") || return 1
    IFS=' ' read -r start2 ticks2 <<< "$after"
    total2=$(awk '$1=="cpu" {s=0; for(i=2;i<=9;i++) s+=$i; print s; exit}' /proc/stat) || return 1
    [[ $start1 == "$start2" ]] || return 1  # PID reuse: samples are incomparable.
    (( total2 > total1 && ticks2 >= ticks1 )) || return 1
    # Percentage of total host CPU capacity, not one-core-normalised percent.
    awk -v p="$((ticks2-ticks1))" -v t="$((total2-total1))" 'BEGIN {printf "%.2f\n", 100*p/t}'
}
```

### Building process tree

```bash
build_process_tree() {
    local root_pid="${1:-1}"
    
    declare -A children
    declare -A proc_info
    
    # Collect all processes
    for pid_dir in /proc/[0-9]*/; do
        local pid="${pid_dir#/proc/}"
        pid="${pid%/}"
        
        [[ -f "/proc/$pid/status" ]] || continue
        
        local ppid
        ppid=$(awk '/^PPid:/ {print $2}' "/proc/$pid/status") || continue
        [[ $ppid =~ ^[0-9]+$ ]] || continue
        
        # Add to parent's children list
        children[$ppid]+="$pid "
        
        # Save process info
        proc_info[$pid]=$(get_process_info "$pid") || continue
    done
    
    # Recursive function for display
    print_tree() {
        local pid="$1"
        local prefix="$2"
        local is_last="$3"
        
        local info="${proc_info[$pid]:-}"
        [[ -n "$info" ]] || return 0
        
        local name state cpu mem mem_mib=unavailable
        IFS='|' read -r _ name state _ _ _ mem _ _ _ _ <<< "$info"
        [[ $mem =~ ^[0-9]+$ ]] && mem_mib=$((mem / 1024))
        
        # Display current node
        local connector="├──"
        [[ "$is_last" == "true" ]] && connector="└──"
        
        printf "%s%s %s (%s) [%s] %s MiB\n" \
            "$prefix" "$connector" "$name" "$pid" "$state" "$mem_mib"
        
        # Process children
        local child_pids="${children[$pid]:-}"
        local -a child_array=()
        IFS=' ' read -r -a child_array <<< "$child_pids"
        local child_count=${#child_array[@]}
        local i=0
        
        for child in "${child_array[@]}"; do
            i=$((i + 1))
            local child_prefix="$prefix"
            [[ "$is_last" == "true" ]] && child_prefix+="    " || child_prefix+="│   "
            
            local child_is_last="false"
            ((i == child_count)) && child_is_last="true"
            
            print_tree "$child" "$child_prefix" "$child_is_last"
        done
    }
    
    print_tree "$root_pid" "" "true"
}
```

### Event detection

```bash
declare -A KNOWN_PROCESSES=()

scan_process_events() {
    local target_pattern="$1" current_pids status pid ticks ticks_after identity info key
    local -A observed=() matched_pids=()
    if current_pids=$(pgrep -f -- "$target_pattern"); then status=0; else status=$?; fi
    [[ $status == 0 || $status == 1 ]] || return "$status"
    while IFS= read -r pid; do
        [[ $pid =~ ^[1-9][0-9]*$ ]] || continue
        matched_pids[$pid]=1
        ticks=$(read_process_ticks "$pid") || continue
        identity="$pid:${ticks%% *}"
        info=$(get_process_info "$pid") || continue
        ticks_after=$(read_process_ticks "$pid") || continue
        [[ ${ticks%% *} == "${ticks_after%% *}" ]] || continue
        observed[$identity]=1
        if [[ ! ${KNOWN_PROCESSES[$identity]+known} ]]; then
            log_event OBSERVED_PRESENT "$pid" "identity=$identity $info" || return 1
            KNOWN_PROCESSES[$identity]=$info
        fi
    done <<< "$current_pids"
    for key in "${!KNOWN_PROCESSES[@]}"; do
        [[ ${observed[$key]+seen} ]] && continue
        pid=${key%%:*}
        if ticks=$(read_process_ticks "$pid"); then
            if [[ "$pid:${ticks%% *}" == "$key" ]]; then
                if [[ ${matched_pids[$pid]+matched} ]]; then
                    log_event UNAVAILABLE "$pid" "identity=$key reason=sample_read_failure" || return 1
                    continue
                fi
                log_event NO_LONGER_MATCHING "$pid" "identity=$key exit_cause=unknown" || return 1
            else
                log_event DISAPPEARED "$pid" "identity=$key pid_reused=yes exit_cause=unknown" || return 1
            fi
        elif [[ -d /proc/$pid ]]; then
            log_event UNAVAILABLE "$pid" "identity=$key reason=read_failure" || return 1
            continue  # Unknown visibility is not a confirmed process exit.
        else
            log_event DISAPPEARED "$pid" "identity=$key exit_cause=unknown" || return 1
        fi
        unset 'KNOWN_PROCESSES[$key]'
    done
}

monitor_events() {
    local target_pattern="$1" interval="${2:-1}"
    [[ $interval =~ ^[0-9]+([.][0-9]+)?$ ]] || return 2
    while true; do
        scan_process_events "$target_pattern" || return "$?"
        sleep "$interval" || return "$?"
    done
}

is_crash() {
    local exit_info="$1"
    # Signals indicating crash
    local crash_signals="SIGSEGV SIGABRT SIGBUS SIGFPE SIGILL"
    
    local IFS=' '
    for sig in $crash_signals; do
        [[ "$exit_info" == *"$sig"* ]] && return 0
    done
    return 1
}
```

### Terminal dashboard

```bash
draw_dashboard() {
    local pids=("$@")
    
    # Clear screen
    clear
    
    # Header
    printf "╔══════════════════════════════════════════════════════════════════════════════╗\n"
    printf "║                    PROCESS LIFECYCLE MONITOR                                 ║\n"
    printf "╚══════════════════════════════════════════════════════════════════════════════╝\n\n"
    
    # Process table
    printf "%-8s %-8s %-10s %-6s %-6s %-10s %-8s %s\n" \
        "PID" "PPID" "USER" "STATE" "CPU%" "MEM(MiB)" "FDs" "CMD"
    printf "%s\n" "$(printf '─%.0s' {1..78})"
    
    for pid in "${pids[@]}"; do
        local info
        info=$(get_process_info "$pid") || continue
        
        IFS='|' read -r p_pid name state ppid uid threads mem utime stime fds cmd <<< "$info"
        
        local cpu
        cpu=$(calculate_cpu_usage "$pid" 0.1) || cpu=unavailable
        local mem_mb=unavailable
        [[ $mem =~ ^[0-9]+$ ]] && mem_mb=$((mem / 1024))
        local user
        user=$(id -un "$uid" 2>/dev/null || echo "$uid")
        
        printf "%-8s %-8s %-10s %-6s %-6s %-10s %-8s %s\n" \
            "$p_pid" "$ppid" "$user" "$state" "$cpu" "$mem_mb" "$fds" "${cmd:0:30}"
    done
    
    # Footer
    printf "\n%s\n" "$(printf '─%.0s' {1..78})"
    printf "Refresh: %ds | Stop with the owning caller's signal handler\n" "$INTERVAL"
}
```

---

## Specific Evaluation Criteria

| Criterion | Weight | Description |
|-----------|--------|-------------|
| Process monitoring | 20% | PID, name, pattern, correct |
| Resource tracking | 20% | CPU, mem, I/O, FDs |
| Process hierarchy | 15% | Tree, children, aggregation |
| Event detection | 15% | Start, stop, crash |
| Alerting | 10% | Thresholds, notifications |
| Dashboard | 10% | Clear UI, refresh |
| Code quality + tests | 5% | ShellCheck, modularity |
| Documentation | 5% | Complete README |

---

## Resources

- `man proc` - The /proc filesystem
- `man ps`, `man top`, `man pgrep`
- `/proc/[pid]/status`, `/proc/[pid]/stat`
- Seminar 2-3 - Processes, signals

---

*MEDIUM Project | Operating Systems | ASE-CSIE*
