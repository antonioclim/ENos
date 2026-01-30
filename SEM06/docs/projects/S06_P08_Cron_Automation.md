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

```bash
# Crontab entries for CAPSTONE projects

#
# MONITOR - Periodic checks
#

# Collect metrics every 5 minutes
*/5 * * * * /opt/capstone/monitor/bin/sysmonitor --once --format json >> /var/log/monitor/metrics.json

# Health check every minute
* * * * * /opt/capstone/monitor/bin/sysmonitor --health-check --alert

# Daily report at 8:00
0 8 * * * /opt/capstone/monitor/bin/sysmonitor --daily-report --email admin@example.com

# Cleanup old logs - weekly Sunday at 2:00
0 2 * * 0 find /var/log/monitor -name "*.json" -mtime +30 -delete

#
# BACKUP - Backup strategies
#

# Daily incremental backup at 2:00
0 2 * * * /opt/capstone/backup/bin/sysbackup --incremental --config /etc/backup/daily.conf

# Weekly full backup Sunday at 3:00
0 3 * * 0 /opt/capstone/backup/bin/sysbackup --full --config /etc/backup/weekly.conf

# Monthly full backup on first day of month at 4:00
0 4 1 * * /opt/capstone/backup/bin/sysbackup --full --config /etc/backup/monthly.conf

# Backup integrity verification - daily at 6:00
0 6 * * * /opt/capstone/backup/bin/sysbackup --verify --last

# Cleanup backups according to retention policy
0 5 * * * /opt/capstone/backup/bin/sysbackup --cleanup --policy /etc/backup/retention.conf

#
# DEPLOYER - Automated deployment
#

# Deployment health check every 10 minutes
*/10 * * * * /opt/capstone/deployer/bin/sysdeploy --health-check >> /var/log/deployer/health.log 2>&1

# Automated deployment from staging on weekdays at 14:00 (if newer version exists)
0 14 * * 1-5 /opt/capstone/deployer/bin/sysdeploy --auto-deploy --source staging --if-newer

# Cleanup old releases - weekly
0 4 * * 1 /opt/capstone/deployer/bin/sysdeploy --cleanup --keep 5
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
#!/bin/bash
#===============================================================================
# cron_manager.sh - Crontab management utility for CAPSTONE
#===============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CAPSTONE_CRON_DIR="/etc/cron.d/capstone"
CRON_TEMPLATE_DIR="${SCRIPT_DIR}/cron-templates"

#-------------------------------------------------------------------------------
# Main functions
#-------------------------------------------------------------------------------

# Install cron jobs for a project
install_cron_jobs() {
    local project="$1"
    local template_file="${CRON_TEMPLATE_DIR}/${project}.cron"
    local cron_file="${CAPSTONE_CRON_DIR}/${project}"
    
    if [[ ! -f "$template_file" ]]; then
        echo "Error: Template not found: $template_file"
        return 1
    fi
    
    # Create directory if doesn't exist
    mkdir -p "$CAPSTONE_CRON_DIR"
    
    # Process template (replace variables)
    local install_path="/opt/capstone/${project}"
    local log_path="/var/log/capstone/${project}"
    
    sed -e "s|{{INSTALL_PATH}}|${install_path}|g" \
        -e "s|{{LOG_PATH}}|${log_path}|g" \
        -e "s|{{USER}}|capstone|g" \
        "$template_file" > "$cron_file"
    
    # Set correct permissions
    chmod 644 "$cron_file"
    
    echo "Installed cron jobs for $project"
    echo "File: $cron_file"
    
    # Validate syntax
    if ! validate_cron_syntax "$cron_file"; then
        echo "Warning: Cron file may have syntax issues"
    fi
}

# Uninstall cron jobs
uninstall_cron_jobs() {
    local project="$1"
    local cron_file="${CAPSTONE_CRON_DIR}/${project}"
    
    if [[ -f "$cron_file" ]]; then
        rm -f "$cron_file"
        echo "Uninstalled cron jobs for $project"
    else
        echo "No cron jobs found for $project"
    fi
}

# List active cron jobs
list_cron_jobs() {
    local project="${1:-}"
    
    echo "═══════════════════════════════════════════════════════════"
    echo "  CAPSTONE CRON JOBS"
    echo "═══════════════════════════════════════════════════════════"
    
    if [[ -n "$project" ]]; then
        local cron_file="${CAPSTONE_CRON_DIR}/${project}"
        if [[ -f "$cron_file" ]]; then
            echo "Project: $project"
            echo "───────────────────────────────────────────────────────────"
            grep -v '^#' "$cron_file" | grep -v '^$' || true
        fi
    else
        for cron_file in "${CAPSTONE_CRON_DIR}"/*; do
            if [[ -f "$cron_file" ]]; then
                local proj_name
                proj_name=$(basename "$cron_file")
                echo ""
                echo "Project: $proj_name"
                echo "───────────────────────────────────────────────────────────"
                grep -v '^#' "$cron_file" | grep -v '^$' || true
            fi
        done
    fi
}

# Validate crontab syntax
validate_cron_syntax() {
    local file="$1"
    
    # Check each non-comment line
    local line_num=0
    local errors=0
    
    while IFS= read -r line || [[ -n "$line" ]]; do
        ((line_num++))
        
        # Skip comments and empty lines
        [[ "$line" =~ ^[[:space:]]*# ]] && continue
        [[ -z "${line// /}" ]] && continue
        
        # Skip environment variables
        [[ "$line" =~ ^[A-Z_]+= ]] && continue
        
        # Validate cron line (5 fields + command)
        local fields
        fields=$(echo "$line" | awk '{print NF}')
        
        if [[ $fields -lt 6 ]]; then
            echo "Line $line_num: Too few fields"
            ((errors++))
        fi
        
    done < "$file"
    
    return $errors
}

# Test cron job (dry run)
test_cron_job() {
    local project="$1"
    local job_index="${2:-1}"
    
    local cron_file="${CAPSTONE_CRON_DIR}/${project}"
    
    if [[ ! -f "$cron_file" ]]; then
        echo "No cron jobs found for $project"
        return 1
    fi
    
    # Extract command for specified job
    local command
    command=$(grep -v '^#' "$cron_file" | grep -v '^$' | grep -v '^[A-Z_]*=' | sed -n "${job_index}p" | awk '{$1=$2=$3=$4=$5=$6=""; print $0}' | xargs)
    
    if [[ -z "$command" ]]; then
        echo "Job #$job_index not found"
        return 1
    fi
    
    echo "Testing cron job #$job_index for $project:"
    echo "Command: $command"
    echo "───────────────────────────────────────────────────────────"
    
    # Execute command
    eval "$command"
}

# Generate cron jobs report
generate_report() {
    echo "═══════════════════════════════════════════════════════════"
    echo "  CRON JOBS REPORT - $(date '+%Y-%m-%d %H:%M:%S')"
    echo "═══════════════════════════════════════════════════════════"
    
    # System crontab
    echo ""
    echo "System Crontab (/etc/crontab):"
    echo "───────────────────────────────────────────────────────────"
    cat /etc/crontab 2>/dev/null | grep -v '^#' | grep -v '^$' || echo "  (empty)"
    
    # Cron.d
    echo ""
    echo "Cron.d Directory:"
    echo "───────────────────────────────────────────────────────────"
    ls -la /etc/cron.d/ 2>/dev/null || echo "  (empty)"
    
    # CAPSTONE crons
    echo ""
    echo "CAPSTONE Cron Jobs:"
    echo "───────────────────────────────────────────────────────────"
    list_cron_jobs
    
    # User crontabs
    echo ""
    echo "User Crontabs:"
    echo "───────────────────────────────────────────────────────────"
    for user in $(cut -d: -f1 /etc/passwd); do
        local user_cron
        user_cron=$(crontab -u "$user" -l 2>/dev/null | grep -v '^#' | grep -v '^$' || true)
        if [[ -n "$user_cron" ]]; then
            echo "  User: $user"
            echo "$user_cron" | sed 's/^/    /'
        fi
    done
}

# Temporary enable/disable
toggle_cron_jobs() {
    local project="$1"
    local action="$2"  # enable|disable
    
    local cron_file="${CAPSTONE_CRON_DIR}/${project}"
    local disabled_file="${cron_file}.disabled"
    
    case "$action" in
        disable)
            if [[ -f "$cron_file" ]]; then
                mv "$cron_file" "$disabled_file"
                echo "Disabled cron jobs for $project"
            fi
            ;;
        enable)
            if [[ -f "$disabled_file" ]]; then
                mv "$disabled_file" "$cron_file"
                echo "Enabled cron jobs for $project"
            fi
            ;;
    esac
}

#-------------------------------------------------------------------------------
# Main
#-------------------------------------------------------------------------------
main() {
    local command="${1:-help}"
    shift || true
    
    case "$command" in
        install)
            install_cron_jobs "$@"
            ;;
        uninstall)
            uninstall_cron_jobs "$@"
            ;;
        list)
            list_cron_jobs "$@"
            ;;
        test)
            test_cron_job "$@"
            ;;
        report)
            generate_report
            ;;
        enable)
            toggle_cron_jobs "$1" "enable"
            ;;
        disable)
            toggle_cron_jobs "$1" "disable"
            ;;
        help|*)
            cat <<'EOF'
Cron Manager for CAPSTONE Projects

Usage: cron_manager.sh <command> [options]

Commands:
    install <project>       Install cron jobs for project
    uninstall <project>     Remove cron jobs for project
    list [project]          List active cron jobs
    test <project> [n]      Test cron job #n (default: 1)
    report                  Generate full cron report
    enable <project>        Re-enable disabled cron jobs
    disable <project>       Temporarily disable cron jobs
    help                    Show this help

Examples:
    cron_manager.sh install monitor
    cron_manager.sh list
    cron_manager.sh test backup 2
    cron_manager.sh disable deployer
EOF
            ;;
    esac
}

main "$@"
```

---

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
OnBootSec=5min
# Or after last execution
OnUnitActiveSec=1h

# Advanced options
Persistent=true          # Run if missed
RandomizedDelaySec=30min # Randomisation to avoid thundering herd
AccuracySec=1s           # Precision (default 1min)

[Install]
WantedBy=timers.target
```

### Timer Implementation for CAPSTONE

```bash
#!/bin/bash
#===============================================================================
# Generate systemd timer units for CAPSTONE projects
#===============================================================================

generate_monitor_timer() {
    # Service unit
    cat > /etc/systemd/system/capstone-monitor.service <<'EOF'
[Unit]
Description=CAPSTONE System Monitor
Documentation=https://capstone.example.com/monitor
After=network.target

[Service]
Type=oneshot
User=capstone
Group=capstone
ExecStart=/opt/capstone/monitor/bin/sysmonitor --once --format json
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
    cat > /etc/systemd/system/capstone-monitor.timer <<'EOF'
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
    cat > /etc/systemd/system/capstone-monitor-daily.timer <<'EOF'
[Unit]
Description=CAPSTONE Daily Report Timer

[Timer]
OnCalendar=*-*-* 08:00:00
Persistent=true

[Install]
WantedBy=timers.target
EOF

    cat > /etc/systemd/system/capstone-monitor-daily.service <<'EOF'
[Unit]
Description=CAPSTONE Daily Monitor Report
After=network-online.target

[Service]
Type=oneshot
User=capstone
ExecStart=/opt/capstone/monitor/bin/sysmonitor --daily-report --email admin@example.com
EOF
}

generate_backup_timer() {
    # Daily incremental backup
    cat > /etc/systemd/system/capstone-backup-daily.service <<'EOF'
[Unit]
Description=CAPSTONE Daily Incremental Backup
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
User=root
ExecStart=/opt/capstone/backup/bin/sysbackup --incremental --config /etc/capstone/backup/daily.conf
TimeoutStartSec=3600
StandardOutput=journal
StandardError=journal

# Notification on failure
ExecStopPost=/bin/sh -c 'if [ "$$EXIT_STATUS" -ne 0 ]; then \
    /usr/local/bin/notify-admin "Backup failed with status $$EXIT_STATUS"; \
fi'
EOF

    cat > /etc/systemd/system/capstone-backup-daily.timer <<'EOF'
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
    cat > /etc/systemd/system/capstone-backup-weekly.service <<'EOF'
[Unit]
Description=CAPSTONE Weekly Full Backup
After=network-online.target

[Service]
Type=oneshot
User=root
ExecStart=/opt/capstone/backup/bin/sysbackup --full --config /etc/capstone/backup/weekly.conf
TimeoutStartSec=7200
EOF

    cat > /etc/systemd/system/capstone-backup-weekly.timer <<'EOF'
[Unit]
Description=Weekly Full Backup Timer

[Timer]
OnCalendar=Sun *-*-* 03:00:00
Persistent=true

[Install]
WantedBy=timers.target
EOF

    # Integrity verification
    cat > /etc/systemd/system/capstone-backup-verify.service <<'EOF'
[Unit]
Description=CAPSTONE Backup Verification
After=capstone-backup-daily.service

[Service]
Type=oneshot
User=root
ExecStart=/opt/capstone/backup/bin/sysbackup --verify --last
EOF

    cat > /etc/systemd/system/capstone-backup-verify.timer <<'EOF'
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
    cat > /etc/systemd/system/capstone-deploy-health.service <<'EOF'
[Unit]
Description=CAPSTONE Deployment Health Check

[Service]
Type=oneshot
User=capstone
ExecStart=/opt/capstone/deployer/bin/sysdeploy --health-check
EOF

    cat > /etc/systemd/system/capstone-deploy-health.timer <<'EOF'
[Unit]
Description=Deployment Health Check Timer

[Timer]
OnCalendar=*:0/10
AccuracySec=1min

[Install]
WantedBy=timers.target
EOF

    # Cleanup old releases
    cat > /etc/systemd/system/capstone-deploy-cleanup.service <<'EOF'
[Unit]
Description=CAPSTONE Release Cleanup

[Service]
Type=oneshot
User=capstone
ExecStart=/opt/capstone/deployer/bin/sysdeploy --cleanup --keep 5
EOF

    cat > /etc/systemd/system/capstone-deploy-cleanup.timer <<'EOF'
[Unit]
Description=Weekly Release Cleanup

[Timer]
OnCalendar=Mon *-*-* 04:00:00
Persistent=true

[Install]
WantedBy=timers.target
EOF
}

# Activate timers
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
            echo "Timer units generated in /etc/systemd/system/"
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
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

# Redirect stdout and stderr
exec 1>> "$LOG_FILE" 2>&1

# Lock to prevent parallel executions
exec 200>"$LOCK_FILE"
if ! flock -n 200; then
    log "ERROR: Another instance is already running"
    exit 1
fi

# Cleanup lock on exit
trap 'rm -f "$LOCK_FILE"' EXIT

# Main execution
log "Starting $SCRIPT_NAME"

# ... actual code ...

log "Completed $SCRIPT_NAME"
```

### 2. Error Notifications

```bash
#!/bin/bash
# Cron job with error notification

set -euo pipefail

ADMIN_EMAIL="admin@example.com"
JOB_NAME="Daily Backup"
HOSTNAME=$(hostname)

# Notification function
send_notification() {
    local status="$1"
    local message="$2"
    
    # Email
    mail -s "[$HOSTNAME] Cron Job $status: $JOB_NAME" "$ADMIN_EMAIL" <<EOF
Job: $JOB_NAME
Host: $HOSTNAME
Time: $(date)
Status: $status

$message
EOF
    
    # Optional: Slack webhook
    if [[ -n "${SLACK_WEBHOOK:-}" ]]; then
        curl -s -X POST -H 'Content-type: application/json' \
            --data "{\"text\":\"[$HOSTNAME] $JOB_NAME: $status\"}" \
            "$SLACK_WEBHOOK"
    fi
}

# Error trap
error_handler() {
    local line_no=$1
    local error_code=$2
    send_notification "FAILED" "Error at line $line_no (exit code: $error_code)"
    exit "$error_code"
}

trap 'error_handler ${LINENO} $?' ERR

# Execute job
run_backup() {
    /opt/capstone/backup/bin/sysbackup --full
}

# Main
main() {
    local start_time=$SECONDS
    
    if run_backup; then
        local duration=$((SECONDS - start_time))
        send_notification "SUCCESS" "Completed in ${duration}s"
    fi
}

main "$@"
```

### 3. Distributed Lock for Clusters

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
    /opt/capstone/backup/bin/sysbackup --full
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
    local cmd="$*"
    local attempt=1
    
    while [[ $attempt -le $MAX_RETRIES ]]; do
        echo "Attempt $attempt/$MAX_RETRIES: $cmd"
        
        if eval "$cmd"; then
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
        
        ((attempt++))
    done
    
    echo "All $MAX_RETRIES attempts failed"
    return 1
}

# Usage
run_with_retry /opt/capstone/backup/bin/sysbackup --full
```

---

## Monitoring Scheduled Jobs

### Execution Verification Script

```bash
#!/bin/bash
#===============================================================================
# check_cron_health.sh - Cron jobs health verification
#===============================================================================

CHECK_WINDOW=86400  # 24 hours

declare -A EXPECTED_JOBS=(
    ["capstone-monitor"]="300"      # Every 5 minutes
    ["capstone-backup-daily"]="86400"  # Daily
    ["capstone-deploy-health"]="600"   # Every 10 minutes
)

check_job_ran_recently() {
    local job_name="$1"
    local max_age="$2"
    local log_file="/var/log/capstone/cron/${job_name}_*.log"
    
    # Find most recent log
    local latest_log
    latest_log=$(ls -t $log_file 2>/dev/null | head -1)
    
    if [[ -z "$latest_log" ]]; then
        echo "NO_LOG"
        return 1
    fi
    
    # Check file age
    local file_age
    file_age=$(( $(date +%s) - $(stat -c %Y "$latest_log") ))
    
    if [[ $file_age -gt $max_age ]]; then
        echo "STALE ($file_age seconds old)"
        return 1
    fi
    
    # Check success in log
    if grep -q "Completed" "$latest_log"; then
        echo "OK"
        return 0
    elif grep -q "ERROR\|FAILED" "$latest_log"; then
        echo "FAILED"
        return 1
    else
        echo "UNKNOWN"
        return 1
    fi
}

main() {
    echo "═══════════════════════════════════════════════════════════"
    echo "  CRON JOBS HEALTH CHECK - $(date)"
    echo "═══════════════════════════════════════════════════════════"
    
    local all_healthy=true
    
    for job in "${!EXPECTED_JOBS[@]}"; do
        local max_age="${EXPECTED_JOBS[$job]}"
        local status
        status=$(check_job_ran_recently "$job" "$max_age")
        
        printf "%-30s %s\n" "$job:" "$status"
        
        if [[ "$status" != "OK" ]]; then
            all_healthy=false
        fi
    done
    
    echo "═══════════════════════════════════════════════════════════"
    
    if $all_healthy; then
        echo "All jobs healthy"
        exit 0
    else
        echo "Some jobs have issues!"
        exit 1
    fi
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
