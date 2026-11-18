# M09: Scheduled Tasks Manager

> **Level:** MEDIUM | **Estimated time:** 25-35 hours | **K8s Bonus:** +10%

---

## Description

Unified manager for scheduled tasks: simplified interface for cron and systemd timers, support for one-shot and recurring tasks, centralised logging, success/failure notifications and dashboard with status and history.

---

## Learning Objectives

- Cron jobs management (`crontab`, `/etc/cron.d/`)
- Systemd timers and services
- Cron expression validation
- Logging and execution monitoring
- Notifications and alerting

---

## Functional Requirements

### Mandatory (for passing grade)

1. **Task management**
   - Add/edit/delete tasks
   - Standard cron expression support
   - Simple interval support (every 5min, daily at 3am)
   - Enable/disable without deletion

2. **Execution and monitoring**
   - Automatic logging for each execution
   - Stdout/stderr capture
   - Exit code and duration tracking
   - Manual run (immediate trigger)

3. **Dual backend**
   - Cron for compatibility
   - Systemd timers for advanced features
   - Automatic conversion between formats

4. **Dashboard**
   - Task list with status
   - Recent executions per task
   - Failed tasks

5. **Notifications**
   - Email on failure
   - Desktop notification
   - Configurable per task

### Optional (for full marks)

6. **Dependency chains** - Task B runs after Task A
7. **Resource limits** - CPU/memory limits per task
8. **Retry logic** - Retry on failure
9. **Web interface** - Simple HTTP dashboard
10. **Export/Import** - Backup and restore configuration

---

## CLI Interface

```text
./taskman.sh <command> [options]

Commands:
  list                  List all tasks
  add <name>            Add new task
  edit <name>           Edit existing task
  remove <name>         Delete task
  enable <name>         Enable task
  disable <name>        Disable task
  run <name>            Run task manually
  logs <name>           Display task logs
  status [name]         Task status or all
  dashboard             Display dashboard
  export                Export configuration
  import <file>         Import configuration

Options:
  -s, --schedule EXPR   Cron expression or interval
  -c, --command CMD     Command to execute
  -u, --user USER       User to run as
  -e, --env KEY=VAL     Environment variables
  -t, --timeout SEC     Execution timeout
  --backend TYPE        cron|systemd (default: auto)
  --notify CHANNEL      Notification: email|desktop|slack
  --retry N             Number of retries on failure
  -q, --quiet           Minimal output

Examples:
  ./taskman.sh add backup --schedule "0 3 * * *" --command "/opt/backup.sh"
  ./taskman.sh add cleanup --schedule "every 6 hours" --command "cleanup.sh"
  ./taskman.sh status backup
  ./taskman.sh run backup
  ./taskman.sh logs backup --last 10
```

---

## Output Examples

### Dashboard

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                    SCHEDULED TASKS MANAGER                                   ║
║                    Host: server01 | Tasks: 12 active                        ║
╚══════════════════════════════════════════════════════════════════════════════╝

TASK STATUS OVERVIEW
═══════════════════════════════════════════════════════════════════════════════
  ✅ Running:     0
  ✅ Succeeded:   10
  ❌ Failed:      2
  ⏸️  Disabled:    3

ACTIVE TASKS
═══════════════════════════════════════════════════════════════════════════════
┌─────────────────┬─────────────────────┬───────────┬─────────────┬───────────┐
│ Name            │ Schedule            │ Last Run  │ Status      │ Next Run  │
├─────────────────┼─────────────────────┼───────────┼─────────────┼───────────┤
│ backup-daily    │ 0 3 * * *           │ 03:00:12  │ ✅ OK (45s)  │ 03:00     │
│ log-rotate      │ 0 0 * * 0           │ Sun 00:00 │ ✅ OK (2s)   │ Sun 00:00 │
│ db-cleanup      │ */30 * * * *        │ 16:30:00  │ ❌ FAIL      │ 17:00     │
│ health-check    │ */5 * * * *         │ 16:55:00  │ ✅ OK (1s)   │ 17:00     │
│ report-gen      │ 0 8 * * 1-5         │ Mon 08:00 │ ✅ OK (120s) │ Tue 08:00 │
│ cache-clear     │ 0 */6 * * *         │ 12:00:00  │ ✅ OK (5s)   │ 18:00     │
│ sync-remote     │ 0 * * * *           │ 16:00:00  │ ❌ FAIL      │ 17:00     │
└─────────────────┴─────────────────────┴───────────┴─────────────┴───────────┘

DISABLED TASKS
═══════════════════════════════════════════════════════════════════════════════
  ⏸️  old-backup (disabled 2025-01-15)
  ⏸️  test-task (disabled 2025-01-18)
  ⏸️  migration (disabled 2025-01-19)

RECENT FAILURES
═══════════════════════════════════════════════════════════════════════════════
❌ db-cleanup (16:30:00)
   Exit code: 1
   Error: Connection refused to database
   Command: /opt/scripts/db_cleanup.sh
   Duration: 0.5s
   
❌ sync-remote (16:00:00)
   Exit code: 255
   Error: SSH connection timeout
   Command: rsync -avz /data/ remote:/backup/
   Duration: 30s (timeout)

UPCOMING (next 2 hours)
═══════════════════════════════════════════════════════════════════════════════
  17:00  health-check, db-cleanup, sync-remote
  17:05  health-check
  17:10  health-check
  ...
  18:00  cache-clear, health-check
```

### Task Detail

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                    TASK: backup-daily                                        ║
╚══════════════════════════════════════════════════════════════════════════════╝

CONFIGURATION
───────────────────────────────────────────────────────────────────────────────
  Name:         backup-daily
  Command:      /opt/scripts/backup.sh --full
  Schedule:     0 3 * * * (Daily at 03:00)
  User:         root
  Backend:      systemd timer
  Status:       ✅ Enabled
  Timeout:      3600s
  Notify on:    failure

STATISTICS
───────────────────────────────────────────────────────────────────────────────
  Total runs:       45
  Successful:       43 (95.6%)
  Failed:           2
  Avg duration:     42s
  Last success:     2025-01-20 03:00:12 (45s)
  Last failure:     2025-01-15 03:00:00 (disk full)

RECENT EXECUTIONS
───────────────────────────────────────────────────────────────────────────────
  2025-01-20 03:00:12  ✅ OK      45s    exit 0
  2025-01-19 03:00:08  ✅ OK      43s    exit 0
  2025-01-18 03:00:15  ✅ OK      48s    exit 0
  2025-01-17 03:00:11  ✅ OK      41s    exit 0
  2025-01-16 03:00:09  ✅ OK      42s    exit 0

View full logs: ./taskman.sh logs backup-daily
```

---

## Configuration File

```yaml
# /etc/taskman/tasks/backup-daily.yaml
name: backup-daily
description: Daily full backup to remote storage
command: /opt/scripts/backup.sh --full
schedule: "0 3 * * *"
user: root
backend: systemd

settings:
  timeout: 3600
  retry: 2
  retry_delay: 300
  
environment:
  BACKUP_DEST: /mnt/backup
  RETENTION_DAYS: 30
  
notify:
  on_failure:
    - email: admin@example.com
    - slack: "#alerts"
  on_success: false
  
dependencies:
  after:
    - db-dump
```

---

## Project Structure

```
M09_Scheduled_Tasks_Manager/
├── README.md
├── Makefile
├── src/
│   ├── taskman.sh               # Main script
│   └── lib/
│       ├── cron.sh              # Cron backend
│       ├── systemd.sh           # Systemd backend
│       ├── scheduler.sh         # Parse schedule expressions
│       ├── executor.sh          # Execution and logging
│       ├── notify.sh            # Notifications
│       └── dashboard.sh         # Terminal UI
├── etc/
│   ├── taskman.conf             # Global configuration
│   └── tasks/                   # Task definitions
│       └── example.yaml
├── templates/
│   ├── systemd-service.tmpl
│   └── systemd-timer.tmpl
├── tests/
│   ├── test_scheduler.sh
│   ├── test_cron.sh
│   └── test_systemd.sh
└── docs/
    ├── INSTALL.md
    ├── SCHEDULE_SYNTAX.md
    └── BACKENDS.md
```

---

## Implementation Hints

### Parsing schedule expressions

```bash
: "${SCHEDULE_HELPER:?Path to 04_PROJECTS/reference/schedule_reference.py}"
parse_schedule() { python3 "$SCHEDULE_HELPER" parse "$1"; }
validate_cron() { parse_schedule "$1" >/dev/null; }
```

### Creating cron job

```bash
# Generation is separate from installing live jobs. This snippet writes only OUTPUT_DIR.
# TASK_RUNNER_PATH is a trusted executable wrapper: 'run NAME' loads the validated
# task definition and calls run_task_with_logging (including timeout/retries/env).
add_cron_job() {
    local name="$1" schedule="$2" command="$3" user="${4:-$(id -un)}"
    [[ $name =~ ^[A-Za-z0-9_-]+$ && $user =~ ^[A-Za-z0-9_-]+$ ]] || return 2
    [[ ${TASK_RUNNER_PATH:-} =~ ^/[A-Za-z0-9_./-]+$ ]] || return 2
    schedule=$(parse_schedule "$schedule") || return 2
    # Store command as data in the task definition, never interpolate it into cron syntax.
    save_task_definition "$name" "$command" "$user" || return 1
    local cron_file="${OUTPUT_DIR:?Choose a generated-files directory}/taskman-$name"
    mkdir -p -- "$OUTPUT_DIR" || return 1
    { printf 'SHELL=/bin/bash\nPATH=/usr/local/bin:/usr/bin:/bin\n';
      printf 'CRON_TZ=%s\n' "${TASK_TIMEZONE:?Choose and validate a shared timezone}";
      printf '%s %s %s run %s\n' "$schedule" "$user" "$TASK_RUNNER_PATH" "$name";
    } > "$cron_file" || return 1
    chmod 644 -- "$cron_file"
}

remove_cron_job() {
    local name="$1"
    [[ $name =~ ^[A-Za-z0-9_-]+$ ]] || return 2
    rm -f -- "${OUTPUT_DIR:?}/taskman-$name"
}
```

### Creating systemd timer

```bash
create_systemd_timer() {
    local name="$1" schedule="$2" command="$3" user="${4:-$(id -un)}" calendar
    [[ $name =~ ^[A-Za-z0-9_-]+$ && $user =~ ^[A-Za-z0-9_-]+$ ]] || return 2
    [[ ${TASK_RUNNER_PATH:-} =~ ^/[A-Za-z0-9_./-]+$ ]] || return 2
    calendar=$(cron_to_calendar "$schedule") || return 2
    save_task_definition "$name" "$command" "$user" || return 1
    mkdir -p -- "${OUTPUT_DIR:?Choose a generated-files directory}" || return 1
    local service_file="$OUTPUT_DIR/taskman-$name.service" timer_file="$OUTPUT_DIR/taskman-$name.timer"
    cat > "$service_file" <<EOF
[Unit]
Description=TaskMan: $name
[Service]
Type=oneshot
User=$user
ExecStart=$TASK_RUNNER_PATH run $name
EOF
    {
        printf '[Unit]\nDescription=TaskMan Timer: %s\n[Timer]\n' "$name"
        while IFS= read -r line; do printf 'OnCalendar=%s\n' "$line"; done <<< "$calendar"
        printf 'Persistent=true\n[Install]\nWantedBy=timers.target\n'
    } > "$timer_file" || return 1
    # Validate generated units before an independently authorised installation.
    systemd-analyze verify "$service_file" "$timer_file"
}

cron_to_calendar() {
    python3 "$SCHEDULE_HELPER" calendar "$1" "${TASK_TIMEZONE:?Shared timezone required}"
}
```

The [numeric reference converter](../reference/schedule_reference.py) preserves
all five fields, including the cron union when both day-of-month and weekday are
restricted; it emits multiple `OnCalendar` lines where needed. Unsupported syntax
is rejected. `every 6 hours` is explicitly wall-clock aligned (00, 06, 12, 18),
not six elapsed hours after completion. A monotonic schedule needs a separate
`OnUnitActiveSec` contract. Validate calendar strings with
`systemd-analyze calendar`; the cron backend requires a daemon supporting
`CRON_TZ`. See [systemd.time](https://www.freedesktop.org/software/systemd/man/latest/systemd.time.html).
`save_task_definition` and the runner are explicit student integration points;
if absent, generation fails instead of bypassing the common executor. Neither
backend executes arbitrary command text directly as `ExecStart`.

### Execution logging

```bash
run_task_with_logging() (
    local name="$1"
    local command="$2"
    
    local log_dir="${TASK_LOG_DIR:?Choose a writable task log directory}"
    local log_file="${log_dir}/${name}.log"
    local run_file="${log_dir}/${name}.last"
    
    mkdir -p "$log_dir"
    
    local start_time
    start_time=$(date +%s)
    
    echo "=== Run started: $(date) ===" >> "$log_file"
    
    # Execute and capture output
    local exit_code
    set +e
    # Explicit trusted shell-program mode; task input is never inserted into source.
    timeout "${TASK_TIMEOUT:-3600}" bash -c 'exec bash -c "$1"' _ "$command" >> "$log_file" 2>&1
    exit_code=$?
    set -e
    
    local end_time duration
    end_time=$(date +%s)
    duration=$((end_time - start_time))
    
    echo "=== Run finished: exit=$exit_code duration=${duration}s ===" >> "$log_file"
    echo "" >> "$log_file"
    
    # Save last run metadata
    cat > "$run_file" << EOF
timestamp=$start_time
exit_code=$exit_code
duration=$duration
EOF
    
    # Notification if failed
    if [[ $exit_code -ne 0 ]]; then
        send_notification "$name" "FAILED" "Exit code: $exit_code"
    fi
    
    return "$exit_code"
)
```

---

## Specific Evaluation Criteria

| Criterion | Weight | Description |
|-----------|--------|-------------|
| CRUD tasks | 20% | Add/edit/remove/enable/disable |
| Cron backend | 15% | Create and manage cron jobs |
| Systemd backend | 15% | Create timers and services |
| Logging | 15% | Output capture, history |
| Dashboard | 15% | Status, failures, next runs |
| Notifications | 10% | Email/desktop on failure |
| Extra features | 5% | Dependencies, retry |
| Code quality + tests | 5% | ShellCheck, tests |

---

## Resources

- `man 5 crontab` - Cron format
- `man systemd.timer` - Systemd timers
- `man systemd.time` - Calendar expressions
- Seminar 3 - Cron and scheduling

---

*MEDIUM Project | Operating Systems | ASE-CSIE*
