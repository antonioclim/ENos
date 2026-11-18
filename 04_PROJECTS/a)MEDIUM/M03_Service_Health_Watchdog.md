# M03: Service Health Watchdog

> **Level:** MEDIUM | **Estimated time:** 25-35 hours | **K8s Bonus:** +10%

---

## Description

Continuous monitoring system for services (systemd units, processes, ports) with automatic alerting, configurable automatic restart and terminal dashboard. Ideal for production server administration.

---

## Learning Objectives

- Interaction with systemd (`systemctl`, `journalctl`)
- Process and port monitoring (`ps`, `ss`, `netstat`)
- Bash daemon implementation with PID file
- Notifications and alerting (email, webhook, desktop)
- YAML/TOML configuration management in Bash

---

## Functional Requirements

### Mandatory (for passing grade)

1. **Systemd service monitoring**
   - Status verification (active, inactive, failed)
   - Crash detection and automatic restart (configurable)
   - Event history per service

2. **Process monitoring**
   - Check process existence by name or PID
   - Alert on critical process disappearance
   - CPU/RAM usage monitoring per process

3. **Port monitoring**
   - Check open port (TCP/UDP)
   - Alert if service does not respond
   - Optional HTTP health check (status code)

4. **Alerting system**
   - Local logging (with rotation)
   - Desktop notification (`notify-send`)
   - Email via `sendmail` or external SMTP

5. **Daemon mode**
   - Background running with PID file
   - Commands: start, stop, status, reload
   - Configurable check interval

### Optional (for full marks)

6. **Terminal dashboard** - Real-time visualisation with `watch` or ncurses
7. **Advanced health check** - Response body verification, latency
8. **Webhook alerting** - Slack, Discord, Teams
9. **Alert escalation** - Repeated alert if problem persists
10. **Prometheus metrics** - Export endpoint `/metrics`

---

## CLI Interface

```text
./watchdog.sh <command> [options]

Commands:
  start                 Start the daemon
  stop                  Stop the daemon
  status                Display daemon and services status
  reload                Reload configuration
  check                 One-shot verification (without daemon)
  add <service>         Add service to monitoring
  remove <service>      Remove service from monitoring
  list                  List monitored services
  logs [service]        Display logs (all or per service)
  dashboard             Display interactive dashboard

Options:
  -c, --config FILE     Configuration file (default: /etc/watchdog.conf)
  -i, --interval SEC    Check interval (default: 30)
  -d, --debug           Debug mode (verbose)
  -q, --quiet           No output (log only)
  --no-restart          Disable automatic restart
  --dry-run             Simulation without actions

Examples:
  ./watchdog.sh start -i 60
  ./watchdog.sh add nginx --restart --alert email
  ./watchdog.sh check --dry-run
  ./watchdog.sh logs nginx --last 50
```

---

## Output Examples

### Status Dashboard

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                    SERVICE HEALTH WATCHDOG v1.0                              ║
║                    Last check: 2025-01-20 14:30:45                          ║
╚══════════════════════════════════════════════════════════════════════════════╝

┌─────────────────────────────────────────────────────────────────────────────┐
│ SYSTEMD SERVICES                                                            │
├──────────────────┬──────────┬──────────┬─────────────┬─────────────────────┤
│ Service          │ Status   │ Uptime   │ Restarts    │ Last Issue          │
├──────────────────┼──────────┼──────────┼─────────────┼─────────────────────┤
│ nginx            │ ✅ active │ 5d 12h   │ 0           │ -                   │
│ postgresql       │ ✅ active │ 5d 12h   │ 0           │ -                   │
│ redis            │ ⚠️ restart│ 0h 5m    │ 3 (today)   │ OOM killed 14:25    │
│ myapp            │ ❌ failed │ -        │ 5 (max)     │ Exit code 1         │
└──────────────────┴──────────┴──────────┴─────────────┴─────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│ PORT CHECKS                                                                 │
├──────────────────┬──────────┬──────────┬─────────────────────────────────────┤
│ Service          │ Port     │ Status   │ Response Time                       │
├──────────────────┼──────────┼──────────┼─────────────────────────────────────┤
│ nginx            │ 80/tcp   │ ✅ open   │ 2ms                                 │
│ nginx            │ 443/tcp  │ ✅ open   │ 3ms                                 │
│ postgresql       │ 5432/tcp │ ✅ open   │ 1ms                                 │
│ redis            │ 6379/tcp │ ✅ open   │ 1ms                                 │
│ myapp            │ 8080/tcp │ ❌ closed │ timeout                             │
└──────────────────┴──────────┴──────────┴─────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│ RECENT ALERTS (last 24h)                                                    │
├─────────────────────────────────────────────────────────────────────────────┤
│ 14:25 [CRIT] redis: OOM killed, restarting...                              │
│ 14:25 [INFO] redis: restart successful                                      │
│ 12:00 [WARN] myapp: high CPU usage (95%)                                   │
│ 10:30 [CRIT] myapp: service failed, restart attempt 5/5                    │
│ 10:30 [CRIT] myapp: max restarts reached, alerting admin                   │
└─────────────────────────────────────────────────────────────────────────────┘

Daemon PID: 12345 | Uptime: 2d 5h | Next check in: 15s
Press 'q' to quit, 'r' to refresh, 'l' for logs
```

### Email Alert

```
Subject: [WATCHDOG ALERT] Service redis failed on server01

Service Health Alert
====================
Server:    server01.example.com
Service:   redis
Status:    FAILED
Time:      2025-01-20 14:25:30 UTC

Details:
- Previous state: active
- Exit code: 137 (SIGKILL convention; OOM cause needs independent kernel/cgroup evidence)
- Memory at failure: 2048MB / 2048MB limit

Action Taken:
- Automatic restart initiated
- Restart successful at 14:25:35

Recent logs:
Jan 20 14:25:29 server01 redis[1234]: Out of memory
Jan 20 14:25:30 server01 systemd[1]: redis.service: Main process exited
```

---

## Configuration File

```yaml
# /etc/watchdog.conf
general:
  interval: 30          # Seconds between checks
  log_file: /var/log/watchdog.log
  pid_file: /var/run/watchdog.pid
  max_restarts: 5       # Per service per hour
  restart_cooldown: 60  # Seconds between restarts

alerts:
  email:
    enabled: true
    to: admin@example.com
    smtp_host: localhost
  desktop:
    enabled: true
  webhook:
    enabled: false
    url: https://hooks.slack.com/xxx

services:
  - name: nginx
    type: systemd
    restart: true
    alert: [email, desktop]
    
  - name: postgresql
    type: systemd
    restart: false        # Databases don't auto-restart
    alert: [email]
    
  - name: myapp
    type: process
    pattern: "python.*myapp"
    restart_cmd: "systemctl restart myapp"
    alert: [email, webhook]

ports:
  - name: nginx-http
    host: localhost
    port: 80
    protocol: tcp
    
  - name: api-health
    host: localhost
    port: 8080
    protocol: http
    path: /health
    expect_status: 200
    timeout: 5
```

---

## Project Structure

```
M03_Service_Health_Watchdog/
├── README.md
├── Makefile
├── src/
│   ├── watchdog.sh              # Main script (daemon)
│   └── lib/
│       ├── config.sh            # YAML configuration parser
│       ├── checks.sh            # Service check functions
│       ├── alerts.sh            # Alerting system
│       ├── daemon.sh            # Daemon functions (start/stop/pid)
│       ├── logging.sh           # Logging with rotation
│       └── dashboard.sh         # Terminal UI
├── etc/
│   ├── watchdog.conf            # Default configuration
│   └── watchdog.conf.example
├── tests/
│   ├── test_checks.sh
│   ├── test_alerts.sh
│   └── mock_services/           # Mock services for tests
├── docs/
│   ├── INSTALL.md
│   ├── CONFIGURATION.md
│   └── ALERTS.md
└── examples/
    ├── minimal.conf
    └── production.conf
```

---

## Implementation Hints

### Systemd service check

```bash
check_systemd_service() {
    local service="$1"
    local status
    
    status=$(systemctl is-active "$service" 2>/dev/null) || :
    
    case "$status" in
        active)   return 0 ;;
        inactive) return 1 ;;
        failed)   return 2 ;;
        *)        return 3 ;;  # Unknown
    esac
}

# Get service details
get_service_info() {
    local service="$1"
    systemctl show "$service" --property=ActiveState,SubState,MainPID,ExecMainStartTimestamp
}
```

### TCP port check

```bash
check_port() {
    local host="$1"
    local port="$2"
    local timeout="${3:-5}"
    
    # Method 1: with timeout and bash
    [[ $host =~ ^[A-Za-z0-9][A-Za-z0-9.-]*$ && $port =~ ^[0-9]{1,5}$ && $timeout =~ ^[0-9]+([.][0-9]+)?$ ]] || return 2
    (( 10#$port >= 1 && 10#$port <= 65535 )) || return 2
    timeout "$timeout" bash -c 'exec 3<>"/dev/tcp/$1/$2"' _ "$host" "$port" 2>/dev/null
    
    # Method 2: with nc (more portable)
    # nc -z -w "$timeout" "$host" "$port" 2>/dev/null
}

# HTTP health check
check_http() {
    local url="$1"
    local expect_status="${2:-200}"
    local timeout="${3:-5}"
    
    local status
    status=$(curl -s -o /dev/null -w "%{http_code}" --max-time "$timeout" -- "$url") || return 1
    
    [[ "$status" == "$expect_status" ]]
}
```

### Daemon with PID file

```bash
PID_FILE="${PID_FILE:-${XDG_RUNTIME_DIR:-$HOME/.cache}/enos-watchdog/watchdog.pid}"

process_start_ticks() {
    local line
    line=$(cat "/proc/$1/stat") || return 1
    local -a fields
    IFS=' ' read -r -a fields <<< "${line##*) }"
    [[ ${fields[19]:-} =~ ^[0-9]+$ ]] || return 1
    printf '%s\n' "${fields[19]}"
}

start_daemon() {
    local runtime_dir=${PID_FILE%/*}
    [[ ! -L "$runtime_dir" ]] || return 1
    mkdir -p -- "$runtime_dir" || return 1
    [[ $(stat -c %u "$runtime_dir") == "$UID" ]] || return 1
    chmod 700 -- "$runtime_dir" || return 1
    (
        umask 077
        exec {lock_fd}>"$PID_FILE.lock" || exit 1
        flock -n "$lock_fd" || exit 1
        local child_pid=$BASHPID start stage
        start=$(process_start_ticks "$child_pid") || exit 1
        stage=$(mktemp "$PID_FILE.partial.XXXXXX") || exit 1
        printf '%s %s\n' "$child_pid" "$start" > "$stage"
        mv -- "$stage" "$PID_FILE" || exit 1
        # Persistent lock inode; only our own PID record is removed on exit.
        trap 'if [[ $(cat "$PID_FILE" 2>/dev/null) == "$child_pid $start" ]]; then rm -f -- "$PID_FILE"; fi' EXIT
        trap 'exit 0' TERM
        trap 'exit 130' INT
        while true; do
            run_all_checks || log_error "One or more checks failed"
            sleep "$INTERVAL" || exit 1
        done
    ) &
    local child=$! attempt
    for ((attempt=0; attempt<100; attempt++)); do
        if [[ -r "$PID_FILE" && $(cut -d ' ' -f1 "$PID_FILE") == "$child" ]]; then
            printf 'Daemon started (PID: %s)\n' "$child"; return 0
        fi
        kill -0 "$child" 2>/dev/null || { wait "$child" || :; return 1; }
        sleep 0.05
    done
    echo "Daemon did not publish its identity; inspect child $child" >&2
    return 1
}

stop_daemon() {
    local pid start current attempt
    IFS=' ' read -r pid start < "$PID_FILE" || return 1
    [[ $pid =~ ^[1-9][0-9]*$ && $start =~ ^[0-9]+$ ]] || return 1
    current=$(process_start_ticks "$pid") || return 1
    [[ $current == "$start" && $(stat -c %u "/proc/$pid") == "$UID" ]] || return 1
    kill -TERM -- "$pid" || return 1
    for ((attempt=0; attempt<100; attempt++)); do
        if [[ ! -e "$PID_FILE" ]]; then echo "Daemon stopped"; return 0; fi
        sleep 0.05
    done
    echo "Stop not confirmed; PID record retained" >&2
    return 1
}
```

### YAML parser boundary (data, not shell code)

```bash
# Requires Python 3 and PyYAML; emits JSON data, never shell assignments for eval.
parse_yaml() {
    python3 - "$1" <<'PYCONFIG'
import json, sys, yaml
with open(sys.argv[1]) as stream:
    config = yaml.safe_load(stream)
if not isinstance(config, dict):
    raise SystemExit("Configuration must be a mapping")
print(json.dumps(config))
PYCONFIG
}
# Validate the documented keys, value types and service lists before use.
# Do not source/eval parser output; use a JSON-aware consumer or explicit arguments.
```

---

## Specific Evaluation Criteria

| Criterion | Weight | Description |
|-----------|--------|-------------|
| Systemd monitoring | 15% | Correct status, history, details |
| Port monitoring | 10% | TCP check, HTTP health check |
| Alerting system | 15% | Minimum 2 functional channels |
| Daemon mode | 15% | Start/stop/reload, PID file, signals |
| Automatic restart | 10% | With cooldown and max restarts |
| Dashboard | 10% | Status visualisation in terminal |
| Extra features | 10% | Webhook, escalation, metrics |
| Code quality + tests | 10% | ShellCheck clean, tests |
| Documentation | 5% | README, INSTALL, config docs |

---

## Resources

- `man systemctl` - Systemd service management
- `man journalctl` - Systemd logs reading
- `man ss` - Socket statistics (replaces netstat)
- Seminar 2-4 - Scripting, processes, text processing

---

*MEDIUM Project | Operating Systems | ASE-CSIE*
