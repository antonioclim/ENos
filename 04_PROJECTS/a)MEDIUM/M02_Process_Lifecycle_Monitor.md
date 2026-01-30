# M02: Process Lifecycle Monitor

> **Level:** MEDIUM | **Estimated time:** 25-35 hours | **K8s Bonus:** +10%

---

## Description

Advanced tool for monitoring process lifecycle: complete tracking from start to termination, real-time resource monitoring (CPU, memory, I/O), process hierarchy visualisation and alerting on anomalies or critical events.

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

```bash
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
  Total FDs:        395
  
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
  OOM Score:        0 (protected)

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
    local proc_dir="/proc/$pid"
    
    # Check if process exists
    [[ -d "$proc_dir" ]] || return 1
    
    # General status
    local status_file="$proc_dir/status"
    local name state ppid uid threads vmrss
    
    name=$(awk '/^Name:/ {print $2}' "$status_file")
    state=$(awk '/^State:/ {print $2}' "$status_file")
    ppid=$(awk '/^PPid:/ {print $2}' "$status_file")
    uid=$(awk '/^Uid:/ {print $2}' "$status_file")
    threads=$(awk '/^Threads:/ {print $2}' "$status_file")
    vmrss=$(awk '/^VmRSS:/ {print $2}' "$status_file")  # in KB
    
    # CPU time from /proc/[pid]/stat
    local stat_fields
    IFS=' ' read -ra stat_fields < "$proc_dir/stat"
    local utime="${stat_fields[13]}"
    local stime="${stat_fields[14]}"
    local starttime="${stat_fields[21]}"
    
    # File descriptors
    local fd_count
    fd_count=$(ls -1 "$proc_dir/fd" 2>/dev/null | wc -l)
    
    # Command line
    local cmdline
    cmdline=$(tr '\0' ' ' < "$proc_dir/cmdline" 2>/dev/null)
    
    # Output
    printf "%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s\n" \
        "$pid" "$name" "$state" "$ppid" "$uid" \
        "$threads" "${vmrss:-0}" "$utime" "$stime" \
        "$fd_count" "$cmdline"
}

# Calculate CPU usage
calculate_cpu_usage() {
    local pid="$1"
    local interval="${2:-1}"
    
    # First reading
    local stat1
    IFS=' ' read -ra stat1 < "/proc/$pid/stat"
    local utime1="${stat1[13]}"
    local stime1="${stat1[14]}"
    
    # Total CPU time
    local total1
    total1=$(awk '{sum=0; for(i=1;i<=NF;i++) sum+=$i; print sum}' /proc/stat | head -1)
    
    sleep "$interval"
    
    # Second reading
    local stat2
    IFS=' ' read -ra stat2 < "/proc/$pid/stat"
    local utime2="${stat2[13]}"
    local stime2="${stat2[14]}"
    local total2
    total2=$(awk '{sum=0; for(i=1;i<=NF;i++) sum+=$i; print sum}' /proc/stat | head -1)
    
    # Calculation
    local proc_diff=$((utime2 - utime1 + stime2 - stime1))
    local total_diff=$((total2 - total1))
    
    if ((total_diff > 0)); then
        echo "scale=2; $proc_diff * 100 / $total_diff" | bc
    else
        echo "0"
    fi
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
        ppid=$(awk '/^PPid:/ {print $2}' "/proc/$pid/status")
        
        # Add to parent's children list
        children[$ppid]+="$pid "
        
        # Save process info
        proc_info[$pid]=$(get_process_info "$pid")
    done
    
    # Recursive function for display
    print_tree() {
        local pid="$1"
        local prefix="$2"
        local is_last="$3"
        
        local info="${proc_info[$pid]}"
        [[ -n "$info" ]] || return
        
        local name state cpu mem
        IFS='|' read -r _ name state _ _ _ mem _ _ _ _ <<< "$info"
        
        # Display current node
        local connector="├──"
        [[ "$is_last" == "true" ]] && connector="└──"
        
        printf "%s%s %s (%s) [%s] %s MB\n" \
            "$prefix" "$connector" "$name" "$pid" "$state" "$((mem / 1024))"
        
        # Process children
        local child_pids="${children[$pid]}"
        local child_array=($child_pids)
        local child_count=${#child_array[@]}
        local i=0
        
        for child in "${child_array[@]}"; do
            ((i++))
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
declare -A KNOWN_PROCESSES

monitor_events() {
    local target_pattern="$1"
    
    while true; do
        # Find processes matching pattern
        local current_pids
        current_pids=$(pgrep -f "$target_pattern" 2>/dev/null || true)
        
        for pid in $current_pids; do
            if [[ -z "${KNOWN_PROCESSES[$pid]:-}" ]]; then
                # New process detected
                local info
                info=$(get_process_info "$pid")
                KNOWN_PROCESSES[$pid]="$info"
                log_event "START" "$pid" "$info"
            fi
        done
        
        # Check known processes
        for pid in "${!KNOWN_PROCESSES[@]}"; do
            if [[ ! -d "/proc/$pid" ]]; then
                # Process has terminated
                local exit_info
                exit_info=$(get_exit_info "$pid")
                log_event "EXIT" "$pid" "$exit_info"
                
                # Check if it was a crash
                if is_crash "$exit_info"; then
                    log_event "CRASH" "$pid" "$exit_info"
                    handle_crash "$pid" "${KNOWN_PROCESSES[$pid]}"
                fi
                
                unset "KNOWN_PROCESSES[$pid]"
            fi
        done
        
        sleep 1
    done
}

is_crash() {
    local exit_info="$1"
    # Signals indicating crash
    local crash_signals="SIGSEGV SIGABRT SIGBUS SIGFPE SIGILL"
    
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
        "PID" "PPID" "USER" "STATE" "CPU%" "MEM(MB)" "FDs" "CMD"
    printf "%s\n" "$(printf '─%.0s' {1..78})"
    
    for pid in "${pids[@]}"; do
        local info
        info=$(get_process_info "$pid") || continue
        
        IFS='|' read -r p_pid name state ppid uid threads mem utime stime fds cmd <<< "$info"
        
        local cpu
        cpu=$(calculate_cpu_usage "$pid" 0.1)
        local mem_mb=$((mem / 1024))
        local user
        user=$(id -un "$uid" 2>/dev/null || echo "$uid")
        
        printf "%-8s %-8s %-10s %-6s %-6s %-10s %-8s %s\n" \
            "$p_pid" "$ppid" "$user" "$state" "$cpu" "$mem_mb" "$fds" "${cmd:0:30}"
    done
    
    # Footer
    printf "\n%s\n" "$(printf '─%.0s' {1..78})"
    printf "Refresh: %ds | Press 'q' to quit\n" "$INTERVAL"
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
