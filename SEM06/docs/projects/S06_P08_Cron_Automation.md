# S06_08: Automation and Scheduling in Linux

## Introduction

Automation of recurring tasks constitutes an essential pillar of system administration, enabling consistent execution of maintenance, backup, monitoring and deployment operations without manual intervention. In the Linux environment, two main mechanisms serve this need: the cron daemon (the classic Unix solution) and systemd timers (the modern approach integrated into systemd).

This chapter explores both mechanisms, providing practical guides for solid scheduling of CAPSTONE projects.

---

## Cron: Fundamentals

### Cron Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        CRON DAEMON                              │
│                         (crond)                                 │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────────┐  │
│  │ System      │  │ User        │  │ Anacron                 │  │
│  │ Crontabs    │  │ Crontabs    │  │ (for systems not        │  │
│  │             │  │             │  │  always running)        │  │
│  │ /etc/crontab│  │ /var/spool/ │  │                         │  │
│  │ /etc/cron.d/│  │ cron/crontabs│ │ /etc/anacrontab         │  │
│  └──────┬──────┘  └──────┬──────┘  └───────────┬─────────────┘  │
│         │                │                      │               │
│         └────────────────┴──────────────────────┘               │
│                          │                                      │
│                          ▼                                      │
│                    ┌───────────┐                                │
│                    │  EXECUTE  │                                │
│                    │   JOBS    │                                │
│                    └───────────┘                                │
└─────────────────────────────────────────────────────────────────┘
```

### Crontab Syntax

```
┌───────────── minute (0 - 59)
│ ┌───────────── hour (0 - 23)
│ │ ┌───────────── day of month (1 - 31)
│ │ │ ┌───────────── month (1 - 12)
│ │ │ │ ┌───────────── day of week (0 - 7, 0 and 7 = Sunday)
│ │ │ │ │
│ │ │ │ │
* * * * * command_to_execute
```

### Special Characters

| Character | Meaning | Example |
|-----------|---------|---------|
| `*` | Any value | `* * * * *` = every minute |
| `,` | List of values | `1,15,30 * * * *` = min 1, 15, 30 |
| `-` | Range | `1-5 * * * *` = min 1 to 5 |
| `/` | Step | `*/15 * * * *` = every 15 min |
| `@yearly` | `0 0 1 1 *` | Once a year |
| `@monthly` | `0 0 1 * *` | Once a month |
| `@weekly` | `0 0 * * 0` | Once a week |
| `@daily` | `0 0 * * *` | Once a day |
| `@hourly` | `0 * * * *` | Once an hour |
| `@reboot` | At boot | At system startup |

### Practical Examples

These are **user-crontab** entries (no user field). A system file directly inside `/etc/cron.d` needs a user field after the schedule. `/opt/capstone` is an explicit example installation root; the three project directories contain the actual `monitor.sh`, `backup.sh` and `deployer.sh` files. Configure owned source/destination paths and approve accounts, retention and notification adapters separately. Commands are not executed by reading this chapter.

The complete manager below supports a stated numeric Debian cron subset, not every extension of every cron implementation. Unescaped percent signs in cron commands have cron-specific meaning; use wrapper scripts for complex commands.

```bash
# User-crontab examples. Required configuration files are prepared separately.
# Default monitor operation is single-shot; -o is the implemented output option.
*/5 * * * * /bin/bash /opt/capstone/monitor/monitor.sh -o json >> /var/log/capstone/monitor/metrics.jsonl 2>> /var/log/capstone/monitor/error.log
0 8 * * * /bin/bash /opt/capstone/monitor/monitor.sh -o text >> /var/log/capstone/monitor/daily.log 2>&1

# The first incremental run creates its full base. --type full starts a new base.
0 2 * * * /bin/bash /opt/capstone/backup/backup.sh --incremental --type daily --config /etc/capstone/backup/daily.conf
0 3 * * 0 /bin/bash /opt/capstone/backup/backup.sh --incremental --type full --config /etc/capstone/backup/weekly.conf
0 4 1 * * /bin/bash /opt/capstone/backup/backup.sh --incremental --type full --config /etc/capstone/backup/monthly.conf
# Retention is part of successful creation, using its configured complete-chain policy.
# To verify a specific approved archive, use --verify-archive /absolute/archive.tar.gz.

# Health is an action; a target must be supplied by the approved configuration.
*/10 * * * * /bin/bash /opt/capstone/deployer/deployer.sh --config /etc/capstone/deployer.conf health >> /var/log/capstone/deployer/health.log 2>&1
# Automatic staging discovery and release deletion are extension exercises;
# the bundled CLI does not implement --auto-deploy, --if-newer or --cleanup.
```

---

## Crontab Management

### Basic Commands

```bash
# Edit current user's crontab
crontab -e

# List current crontab
crontab -l

# Delete crontab (CAUTION!)
crontab -r

# Edit crontab for another user (requires root)
crontab -u username -e

# Import crontab from file
crontab /path/to/crontab-file

# Backup crontab
crontab -l > ~/crontab-backup.txt
```

### Script for Automated Management

```bash
#!/usr/bin/env bash
# Save as cron_manager.sh. Python parses data; it never evals job text.
python3 - "$@" <<'PY'
"""Numeric Debian system-crontab subset; plan/inspect never executes job text."""
import argparse,json,os,pathlib,pwd,re,sys,tempfile
MACROS={'@yearly','@annually','@monthly','@weekly','@daily','@midnight','@hourly','@reboot'}
def field(value,minimum,maximum):
    for entry in value.split(','):
        pieces=entry.split('/')
        if len(pieces)>2:raise ValueError('invalid step')
        base=pieces[0]
        if len(pieces)==2 and (not pieces[1].isdigit() or not 1<=int(pieces[1])<=maximum-minimum+1):raise ValueError('invalid step')
        if base=='*':continue
        ends=base.split('-')
        if len(ends)>2 or not all(x.isdigit() for x in ends):raise ValueError('invalid numeric time field')
        numbers=list(map(int,ends))
        if not all(minimum<=x<=maximum for x in numbers) or numbers[0]>numbers[-1]:raise ValueError('out-of-range time field')
def parse(text):
    jobs=[];environment={}
    for number,raw in enumerate(text.splitlines(),1):
        line=raw.strip()
        if not line or line.startswith('#'):continue
        match=re.fullmatch(r'([A-Za-z_][A-Za-z0-9_]*)\s*=\s*(.*)',line)
        if match:environment[match[1]]=match[2];continue
        if line.startswith('@'):
            parts=line.split(None,2)
            if len(parts)!=3 or parts[0] not in MACROS:raise ValueError(f'line {number}: invalid macro/user/command')
            schedule,user,command=parts
        else:
            parts=line.split(None,6)
            if len(parts)!=7:raise ValueError(f'line {number}: system crontab requires five time fields, user and command')
            for value,bounds in zip(parts[:5],[(0,59),(0,23),(1,31),(1,12),(0,7)]):field(value,*bounds)
            schedule=' '.join(parts[:5]);user,command=parts[5:]
        if not re.fullmatch(r'[A-Za-z_][A-Za-z0-9_-]*[$]?',user):raise ValueError(f'line {number}: invalid user')
        try:pwd.getpwnam(user)
        except KeyError:raise ValueError(f'line {number}: user does not exist on this host')
        jobs.append(dict(line=number,schedule=schedule,user=user,command=command,environment=dict(environment)))
    if not jobs:raise ValueError('no jobs')
    return jobs
def atomic_write(path,text):
    fd,tmp=tempfile.mkstemp(prefix='.capstone-stage-',dir=path.parent)
    try:
        with os.fdopen(fd,'w') as out:out.write(text);out.flush();os.fsync(out.fileno())
        os.chmod(tmp,0o644);os.replace(tmp,path)
    finally:
        if os.path.exists(tmp):os.unlink(tmp)
def main(argv=None):
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('action',choices=['install','uninstall','list','test','inspect','report','enable','disable','validate'])
    parser.add_argument('project',nargs='?');parser.add_argument('index',nargs='?',type=int,default=1)
    parser.add_argument('--apply',action='store_true',help='apply the reviewed file operation; never run a job')
    args=parser.parse_args(argv)
    root=pathlib.Path(os.environ.get('CAPSTONE_CRON_DIR','/etc/cron.d'))
    templates=pathlib.Path(os.environ.get('CRON_TEMPLATE_DIR','cron-templates'))
    if args.action in ('list','report'):
        for path in sorted(root.glob('capstone-*')):
            if path.is_file():print(path);print(path.read_text())
        return 0
    if not args.project or not re.fullmatch(r'[A-Za-z0-9_-]+',args.project):raise ValueError('invalid/missing project identifier')
    path=root/('capstone-'+args.project);disabled=path.with_name(path.name+'.disabled')
    if args.action=='install':
        text=(templates/(args.project+'.cron')).read_text()
        replacements={'{{INSTALL_PATH}}':os.environ.get('CAPSTONE_INSTALL_PATH','/opt/capstone/'+args.project),'{{LOG_PATH}}':os.environ.get('CAPSTONE_LOG_PATH','/var/log/capstone/'+args.project),'{{USER}}':os.environ.get('CAPSTONE_USER','')}
        for marker,value in replacements.items():
            if marker in text and not value:raise ValueError('set CAPSTONE_USER explicitly')
            text=text.replace(marker,value)
        if '{{' in text:raise ValueError('unresolved template marker')
        jobs=parse(text) # validates before any destination/temp-file write
        print(json.dumps(dict(action='install',target=str(path),jobs=jobs,apply=args.apply)))
        if args.apply:
            if not root.is_dir():raise ValueError('destination directory must already exist and be authorised')
            atomic_write(path,text.rstrip('\n')+'\n')
    elif args.action in ('test','inspect','validate'):
        jobs=parse(path.read_text())
        if args.action=='validate':print(json.dumps(jobs));return 0
        if not 1<=args.index<=len(jobs):raise ValueError('job index out of range')
        print(json.dumps(dict(mode='inspection_only_no_execution',**jobs[args.index-1])))
    elif args.action=='uninstall':
        print(json.dumps(dict(action='remove_managed_file',target=str(path),apply=args.apply)))
        if args.apply:path.unlink(missing_ok=True)
    else:
        source,target=(path,disabled) if args.action=='disable' else (disabled,path)
        if not source.is_file() or source.is_symlink():raise ValueError('managed source must be a regular file')
        if target.exists() or target.is_symlink():raise ValueError('destination already exists')
        if args.action=='enable':parse(source.read_text())
        print(json.dumps(dict(action=args.action,source=str(source),target=str(target),apply=args.apply)))
        if args.apply:os.replace(source,target)
    return 0
if __name__=='__main__':
    try:raise SystemExit(main())
    except (ValueError,OSError) as error:print('Error:',error,file=sys.stderr);raise SystemExit(2)

PY
```

---

The manager writes `capstone-<project>` **directly** under `CAPSTONE_CRON_DIR` (default `/etc/cron.d`). `install`, `enable`, `disable` and `uninstall` produce a plan unless `--apply` is explicitly passed. `test`/`inspect` is a non-executing inspection that preserves the exact command string and user. A separate owned fixture may invoke the underlying programme with stubs; this is not equivalent to reproducing the cron daemon environment or changing execution identity. A `.disabled` suffix is deliberately ignored by Debian cron filename rules.

## Systemd Timers: The Modern Alternative

### Cron vs Systemd Timers Comparison

| Aspect | Cron | Systemd Timers |
|--------|------|----------------|
| Logging | Manual/syslog | Integrated journalctl |
| Dependencies | Not supported | Fully supported |
| Resource control | No | Integrated cgroups |
| Persistence | Anacron | OnCalendar persistent |
| Debugging | Difficult | `systemctl status`, journalctl |
| Activation at boot | @reboot | OnBootSec |
| Randomisation | No | RandomizedDelaySec |

### Timer Unit Structure

```ini
# /etc/systemd/system/backup.timer
[Unit]
Description=Daily Backup Timer
Documentation=https://example.com/backup-docs

[Timer]
# When to run
OnCalendar=*-*-* 02:00:00
# Or relative to boot
# Alternative example only: OnBootSec=5min
# Or after last execution
# Alternative example only: OnUnitActiveSec=1h

# Advanced options
# Run missed calendar activation; these comments must be separate lines.
Persistent=true
# Spread scheduled starts
RandomizedDelaySec=30min
# Scheduling accuracy window
AccuracySec=1s

[Install]
WantedBy=timers.target
```

Multiple timer directives accumulate; commented examples above are alternatives. `Persistent=true` concerns missed calendar activations and does not promise one replay per missed occurrence.

### Timer Implementation for CAPSTONE

The generator writes reviewable files into `UNIT_OUTPUT_DIR`, an existing owned directory. It does not install or enable them. User/group, filesystem permissions and resource limits are illustrative configuration inputs requiring administrator validation before installation. The separate `activate` action is for an already reviewed system installation.

```bash
#!/bin/bash
#===============================================================================
# Generate systemd timer units for CAPSTONE projects
#===============================================================================
: "${UNIT_OUTPUT_DIR:?Set an existing owned output directory}"
[[ -d $UNIT_OUTPUT_DIR ]] || exit 2

generate_monitor_timer() {
    # Service unit
    cat > "${UNIT_OUTPUT_DIR}/capstone-monitor.service" <<'EOF'
[Unit]
Description=CAPSTONE System Monitor
Documentation=https://capstone.example.com/monitor
After=network.target

[Service]
Type=oneshot
User=capstone
Group=capstone
ExecStart=/bin/bash /opt/capstone/monitor/monitor.sh -o json
StandardOutput=append:/var/log/capstone/monitor/metrics.log
StandardError=append:/var/log/capstone/monitor/error.log

# Resource limits
MemoryLimit=256M
CPUQuota=50%

# Security
NoNewPrivileges=yes
ProtectSystem=strict
ProtectHome=yes
ReadWritePaths=/var/log/capstone/monitor

[Install]
WantedBy=multi-user.target
EOF

    # Timer unit for metrics collection
    cat > "${UNIT_OUTPUT_DIR}/capstone-monitor.timer" <<'EOF'
[Unit]
Description=Run CAPSTONE Monitor every 5 minutes
Documentation=https://capstone.example.com/monitor

[Timer]
OnCalendar=*:0/5
Persistent=true
RandomizedDelaySec=30

[Install]
WantedBy=timers.target
EOF

    # Timer for daily report
    cat > "${UNIT_OUTPUT_DIR}/capstone-monitor-daily.timer" <<'EOF'
[Unit]
Description=CAPSTONE Daily Report Timer

[Timer]
OnCalendar=*-*-* 08:00:00
Persistent=true

[Install]
WantedBy=timers.target
EOF

    cat > "${UNIT_OUTPUT_DIR}/capstone-monitor-daily.service" <<'EOF'
[Unit]
Description=CAPSTONE Daily Monitor Report
After=network-online.target

[Service]
Type=oneshot
User=capstone
ExecStart=/bin/bash /opt/capstone/monitor/monitor.sh -o text
EOF
}

generate_backup_timer() {
    # Daily incremental backup
    cat > "${UNIT_OUTPUT_DIR}/capstone-backup-daily.service" <<'EOF'
[Unit]
Description=CAPSTONE Daily Incremental Backup
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
User=root
ExecStart=/bin/bash /opt/capstone/backup/backup.sh --incremental --type daily --config /etc/capstone/backup/daily.conf
TimeoutStartSec=3600
StandardOutput=journal
StandardError=journal

# Notification on failure
ExecStopPost=/bin/sh -c 'if [ "$$EXIT_STATUS" -ne 0 ]; then \
    /usr/local/bin/notify-admin "Backup failed with status $$EXIT_STATUS"; \
fi'
EOF

    cat > "${UNIT_OUTPUT_DIR}/capstone-backup-daily.timer" <<'EOF'
[Unit]
Description=Daily Backup Timer

[Timer]
OnCalendar=*-*-* 02:00:00
Persistent=true
RandomizedDelaySec=15min

[Install]
WantedBy=timers.target
EOF

    # Weekly full backup
    cat > "${UNIT_OUTPUT_DIR}/capstone-backup-weekly.service" <<'EOF'
[Unit]
Description=CAPSTONE Weekly Full Backup
After=network-online.target

[Service]
Type=oneshot
User=root
ExecStart=/bin/bash /opt/capstone/backup/backup.sh --incremental --type full --config /etc/capstone/backup/weekly.conf
TimeoutStartSec=7200
EOF

    cat > "${UNIT_OUTPUT_DIR}/capstone-backup-weekly.timer" <<'EOF'
[Unit]
Description=Weekly Full Backup Timer

[Timer]
OnCalendar=Sun *-*-* 03:00:00
Persistent=true

[Install]
WantedBy=timers.target
EOF

    # Integrity verification
    cat > "${UNIT_OUTPUT_DIR}/capstone-backup-verify.service" <<'EOF'
[Unit]
Description=CAPSTONE Backup Verification
After=capstone-backup-daily.service

[Service]
Type=oneshot
User=root
ExecStart=/bin/bash /opt/capstone/backup/backup.sh --verify-archive /var/backups/capstone/approved-archive.tar.gz
EOF

    cat > "${UNIT_OUTPUT_DIR}/capstone-backup-verify.timer" <<'EOF'
[Unit]
Description=Daily Backup Verification Timer

[Timer]
OnCalendar=*-*-* 06:00:00
Persistent=true

[Install]
WantedBy=timers.target
EOF
}

generate_deployer_timer() {
    # Periodic health check
    cat > "${UNIT_OUTPUT_DIR}/capstone-deploy-health.service" <<'EOF'
[Unit]
Description=CAPSTONE Deployment Health Check

[Service]
Type=oneshot
User=capstone
ExecStart=/bin/bash /opt/capstone/deployer/deployer.sh --config /etc/capstone/deployer.conf health
EOF

    cat > "${UNIT_OUTPUT_DIR}/capstone-deploy-health.timer" <<'EOF'
[Unit]
Description=Deployment Health Check Timer

[Timer]
OnCalendar=*:0/10
AccuracySec=1min

[Install]
WantedBy=timers.target
EOF

    # Cleanup old releases
    cat > "${UNIT_OUTPUT_DIR}/capstone-deploy-cleanup.service" <<'EOF'
[Unit]
Description=CAPSTONE Release Cleanup

[Service]
Type=oneshot
User=capstone
ExecStart=/usr/local/libexec/capstone-release-retention
EOF

    cat > "${UNIT_OUTPUT_DIR}/capstone-deploy-cleanup.timer" <<'EOF'
[Unit]
Description=Weekly Release Cleanup

[Timer]
OnCalendar=Mon *-*-* 04:00:00
Persistent=true

[Install]
WantedBy=timers.target
EOF
}

# The optional release-retention programme and approved-archive path above are
# explicit installation dependencies, not provided by the bundled deployer.
# Do not install/enable their units until those adapters/paths are supplied.
# Activate previously installed and reviewed timers
activate_timers() {
    systemctl daemon-reload
    
    local timers=(
        capstone-monitor.timer
        capstone-monitor-daily.timer
        capstone-backup-daily.timer
        capstone-backup-weekly.timer
        capstone-backup-verify.timer
        capstone-deploy-health.timer
        capstone-deploy-cleanup.timer
    )
    
    for timer in "${timers[@]}"; do
        if [[ -f "/etc/systemd/system/$timer" ]]; then
            systemctl enable "$timer"
            systemctl start "$timer"
            echo "Activated: $timer"
        fi
    done
}

# List timer status
list_timer_status() {
    echo "═══════════════════════════════════════════════════════════"
    echo "  CAPSTONE SYSTEMD TIMERS STATUS"
    echo "═══════════════════════════════════════════════════════════"
    
    systemctl list-timers --all capstone-* 2>/dev/null || \
        systemctl list-timers --all | grep capstone || \
        echo "No CAPSTONE timers found"
}

# Main
main() {
    local action="${1:-status}"
    
    case "$action" in
        generate)
            generate_monitor_timer
            generate_backup_timer
            generate_deployer_timer
            echo "Timer units generated for review in $UNIT_OUTPUT_DIR"
            ;;
        activate)
            activate_timers
            ;;
        status)
            list_timer_status
            ;;
        *)
            echo "Usage: $0 {generate|activate|status}"
            ;;
    esac
}

main "$@"
```

### Useful Systemd Timers Commands

```bash
# List all active timers
systemctl list-timers --all

# Detailed status for a timer
systemctl status capstone-backup-daily.timer

# View when next will run
systemctl list-timers capstone-backup-daily.timer

# Check logs for associated service
journalctl -u capstone-backup-daily.service

# Real-time logs
journalctl -u capstone-backup-daily.service -f

# Manual service run
systemctl start capstone-backup-daily.service

# Temporary disable
systemctl stop capstone-backup-daily.timer
systemctl disable capstone-backup-daily.timer

# Re-enable
systemctl enable capstone-backup-daily.timer
systemctl start capstone-backup-daily.timer

# Reload after modifications
systemctl daemon-reload
```

---

## Best Practices for Scheduling

### 1. Logging and Output Management

```bash
#!/bin/bash
# Wrapper script for cron jobs with solid logging

SCRIPT_NAME=$(basename "$0")
LOG_DIR="/var/log/capstone/cron"
LOG_FILE="${LOG_DIR}/${SCRIPT_NAME%.*}_$(date +%Y%m%d).log"
LOCK_FILE="/var/run/capstone/${SCRIPT_NAME%.*}.lock"

# Create directories
mkdir -p "$LOG_DIR" "$(dirname "$LOCK_FILE")"

# Logging function
log() {
    printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*"  # stdout is already redirected
}

# Redirect stdout and stderr
exec 1>> "$LOG_FILE" 2>&1

# Lock to prevent parallel executions
exec 200>>"$LOCK_FILE"
if ! flock -n 200; then
    log "ERROR: Another instance is already running"
    exit 1
fi

# Cleanup lock on exit
trap 'exec 200>&-' EXIT  # Keep the pathname/inode stable for other contenders

# Main execution
log "Starting $SCRIPT_NAME"

# ... actual code ...

log "Completed $SCRIPT_NAME"
```

### 2. Error Notifications

```bash
#!/usr/bin/env bash
# Named adapters are explicit dependencies; tests provide local harmless stubs.
set -uo pipefail
JOB_NAME=${JOB_NAME:-daily-backup}
: "${JOB_STATE_DIR:?Set an owned directory}" "${BACKUP_PROGRAM:?Absolute backup.sh path}"
send_notification() {
    # Default is local stderr only. A configured executable receives argv data,
    # not shell text. Selecting email/webhook recipients is a separate decision.
    if [[ -n ${NOTIFY_PROGRAM:-} ]]; then "$NOTIFY_PROGRAM" "$1" "$2";
    else printf '%s: %s\n' "$1" "$2" >&2; fi
}
write_job_state() {
    python3 - "$JOB_STATE_DIR" "$JOB_NAME" "$1" "${2:-}" <<'PY'
import json,os,pathlib,re,sys,tempfile,time
directory,name,status,code=sys.argv[1:]
if not re.fullmatch(r'[A-Za-z0-9_-]+',name):raise SystemExit(2)
fd,tmp=tempfile.mkstemp(prefix='.state-',dir=directory)
try:
    with os.fdopen(fd,'w') as out:json.dump(dict(status=status,code=int(code) if code else None,timestamp=time.time()),out)
    os.replace(tmp,pathlib.Path(directory)/(name+'.json'))
finally:
    if os.path.exists(tmp):os.unlink(tmp)
PY
}
run_backup() { bash "$BACKUP_PROGRAM" "$@"; }
main() {
    local rc start=$SECONDS
    write_job_state RUNNING || return 1
    if run_backup "$@"; then
        write_job_state SUCCESS 0 || return 1
        send_notification SUCCESS "Completed in $((SECONDS-start)) seconds" || return 1
        return 0
    else
        rc=$?
        write_job_state FAILED "$rc" || true
        send_notification FAILED "Backup returned $rc" || true
        return "$rc" # one notification; no ERR trap duplicates it
    fi
}
main "$@"
```

### 3. Distributed Lock for Clusters

This is a lease illustration, not a distributed-exclusion proof. It lacks renewal and fencing; if a job outlives the TTL or a failover changes ownership, two actors may run. A production design must define lease renewal, fencing tokens, failure/recovery behaviour and the administrator-approved Redis topology. No Redis command is executed by the verification fixtures.

```bash
#!/bin/bash
# Cron job with distributed lock (for clusters)

LOCK_NAME="capstone-backup-daily"
LOCK_TTL=3600  # 1 hour

# Functions for distributed lock (using Redis)
acquire_distributed_lock() {
    local lock_name="$1"
    local ttl="$2"
    local node_id="${HOSTNAME}-$$"
    
    # Attempt to acquire lock
    local result
    result=$(redis-cli SET "lock:${lock_name}" "$node_id" NX EX "$ttl")
    
    [[ "$result" == "OK" ]]
}

release_distributed_lock() {
    local lock_name="$1"
    local node_id="${HOSTNAME}-$$"
    
    # Verify we own the lock and release
    redis-cli EVAL "
        if redis.call('get', KEYS[1]) == ARGV[1] then
            return redis.call('del', KEYS[1])
        else
            return 0
        end
    " 1 "lock:${lock_name}" "$node_id"
}

# Main
main() {
    if ! acquire_distributed_lock "$LOCK_NAME" "$LOCK_TTL"; then
        echo "Another node is running this job"
        exit 0
    fi
    
    trap 'release_distributed_lock "$LOCK_NAME"' EXIT
    
    # Execute job
    /bin/bash /opt/capstone/backup/backup.sh --incremental --type full
}

main "$@"
```

### 4. Retry Logic

```bash
#!/bin/bash
# Cron job with automatic retry

MAX_RETRIES=3
RETRY_DELAY=60  # seconds

run_with_retry() {
    local -a cmd=("$@")
    local attempt=1
    
    while [[ $attempt -le $MAX_RETRIES ]]; do
        echo "Attempt $attempt/$MAX_RETRIES: $cmd"
        
        if "${cmd[@]}"; then
            echo "Success on attempt $attempt"
            return 0
        fi
        
        echo "Failed on attempt $attempt"
        
        if [[ $attempt -lt $MAX_RETRIES ]]; then
            echo "Waiting ${RETRY_DELAY}s before retry..."
            sleep "$RETRY_DELAY"
            # Optional exponential backoff
            RETRY_DELAY=$((RETRY_DELAY * 2))
        fi
        
        attempt=$((attempt + 1))
    done
    
    echo "All $MAX_RETRIES attempts failed"
    return 1
}

# Usage
run_with_retry /bin/bash /opt/capstone/backup/backup.sh --incremental --type full
```

---

## Monitoring Scheduled Jobs

### Execution Verification Script

```bash
#!/usr/bin/env bash
# Checks the latest structured state, not any earlier success in an append log.
declare -A EXPECTED_JOBS=([capstone-monitor]=300 [capstone-backup-daily]=86400 [capstone-deploy-health]=600)
check_job_ran_recently() {
    python3 - "${JOB_STATE_DIR:?}" "$1" "$2" <<'PY'
import json,pathlib,re,sys,time
directory,name,limit=sys.argv[1:]
try:
    if not re.fullmatch(r'[A-Za-z0-9_-]+',name):raise ValueError('invalid job')
    maximum=int(limit)
    if maximum<=0:raise ValueError('invalid age')
    state=json.loads((pathlib.Path(directory)/(name+'.json')).read_text())
    age=time.time()-float(state['timestamp'])
    if age<0 or age>maximum:print('STALE');raise SystemExit(1)
    if state['status']=='RUNNING':print('IN_PROGRESS');raise SystemExit(1)
    if state['status']=='SUCCESS' and state['code']==0:print('OK');raise SystemExit(0)
    print('FAILED');raise SystemExit(1)
except (OSError,ValueError,KeyError,TypeError):print('UNAVAILABLE');raise SystemExit(2)
PY
}
main() {
    local job status rc=0
    for job in "${!EXPECTED_JOBS[@]}"; do
        if status=$(check_job_ran_recently "$job" "${EXPECTED_JOBS[$job]}"); then :; else rc=1; fi
        printf '%s: %s\n' "$job" "$status"
    done
    return "$rc"
}
main "$@"
```

---

## Practical Exercises

### Exercise 1: Cron Expression Parser

Implement a cron expression parser:

```bash
# Requirements:
# - Parse standard cron expressions
# - Calculate next N executions
# - Validate syntax
```

### Exercise 2: Timer Migration Tool

Create a tool for migrating from cron to systemd timers:

```bash
# Requirements:
# - Parse existing crontab
# - Generate timer and service units
# - Validate and activate
```

### Exercise 3: Job Dependencies Manager

Implement a dependency system between jobs:

```bash
# Requirements:
# - Define dependencies (job A runs after job B)
# - Failure propagation
# - Dependency graph visualisation
```

### Exercise 4: Scheduled Tasks Dashboard

Create a terminal dashboard for scheduled jobs:

```bash
# Requirements:
# - Timeline visualisation
# - Recent job status
# - Alerts for failed jobs
```

### Exercise 5: Distributed Scheduler

Implement a simple distributed scheduler:

```bash
# Requirements:
# - Distributed lock (Redis/file)
# - Leader election
# - Job distribution between nodes
```

### Technical reference for the corrected examples

Timer combinations and missed calendar activations follow the [systemd.timer reference](https://www.freedesktop.org/software/systemd/man/latest/systemd.timer.html).
