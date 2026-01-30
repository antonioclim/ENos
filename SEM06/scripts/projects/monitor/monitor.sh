#!/bin/bash
#==============================================================================
# monitor.sh - System Monitor - Complete system monitoring application
#==============================================================================
# DESCRIPTION:
#   Professional application for monitoring system resources:
#   CPU, memory, disk, swap, load average.
#   Supports alerting, notifications, daemon mode and multiple output formats.
#
# ARCHITECTURE:
#   monitor.sh (this file) - Entry point and main logic
#    lib/core.sh          - Fundamental functions (logging, error handling)
#    lib/utils.sh         - System metrics collection functions
#    lib/config.sh        - Configuration management
#    etc/monitor.conf     - Default configuration
#    var/
#        log/             - Log files
#        run/             - PID file for daemon
#
# USAGE:
#   ./monitor.sh              # Single-shot check
#   ./monitor.sh -d           # Daemon mode
#   ./monitor.sh -v           # Verbose/debug mode
#   ./monitor.sh -o json      # JSON output
#
# AUTHOR: ASE Bucharest - CSIE | Operating Systems
# VERSION: 1.0.0
# LICENCE: Educational Use
#==============================================================================

set -euo pipefail
IFS=$'\n\t'

#------------------------------------------------------------------------------
# INITIAL SETUP
#------------------------------------------------------------------------------

# Determine script directory (resolves symlinks)
SCRIPT_PATH="${BASH_SOURCE[0]}"
while [[ -L "$SCRIPT_PATH" ]]; do
    SCRIPT_DIR=$(cd -P "$(dirname "$SCRIPT_PATH")" && pwd)
    SCRIPT_PATH=$(readlink "$SCRIPT_PATH")
    [[ "$SCRIPT_PATH" != /* ]] && SCRIPT_PATH="$SCRIPT_DIR/$SCRIPT_PATH"
done
SCRIPT_DIR=$(cd -P "$(dirname "$SCRIPT_PATH")" && pwd)
readonly SCRIPT_DIR

# Save original arguments
readonly ORIGINAL_ARGS=("$@")

#------------------------------------------------------------------------------
# LOAD LIBRARIES
#------------------------------------------------------------------------------

# Check and load libraries in correct order
for lib in core utils config; do
    lib_file="${SCRIPT_DIR}/lib/${lib}.sh"
    if [[ -f "$lib_file" ]]; then
        # shellcheck source=/dev/null
        source "$lib_file"
    else
        echo "FATAL ERROR: Missing library: $lib_file" >&2
        exit 1
    fi
done

#------------------------------------------------------------------------------
# GLOBAL STATE VARIABLES
#------------------------------------------------------------------------------

declare -g ALERTS_COUNT=0
declare -g ALERTS_MESSAGES=()
declare -g LAST_CHECK_TIME=0
declare -g RUNNING=true

#------------------------------------------------------------------------------
# NOTIFICATION FUNCTIONS
#------------------------------------------------------------------------------

# Send email notification
send_email_notification() {
    local subject="$1"
    local body="$2"
    
    if [[ -z "$NOTIFY_EMAIL" ]]; then
        log_debug "Email not set, skipping notification"
        return 0
    fi
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "[DRY-RUN] Would send email to: $NOTIFY_EMAIL"
        log_debug "Subject: $subject"
        return 0
    fi
    
    # Check if mail command exists
    if ! command -v mail &>/dev/null; then
        log_warn "Command 'mail' not available for notifications"
        return 1
    fi
    
    echo "$body" | mail -s "$subject" "$NOTIFY_EMAIL"
    log_info "Email notification sent to: $NOTIFY_EMAIL"
}

# Send Slack notification
send_slack_notification() {
    local message="$1"
    local severity="${2:-warning}"
    
    if [[ -z "$NOTIFY_SLACK_WEBHOOK" ]]; then
        return 0
    fi
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "[DRY-RUN] Would send to Slack: $message"
        return 0
    fi
    
    local color
    case "$severity" in
        good)    color="#36a64f" ;;
        warning) color="#ffa500" ;;
        danger)  color="#ff0000" ;;
        *)       color="#808080" ;;
    esac
    
    local payload
    payload=$(cat << EOF
{
    "attachments": [
        {
            "color": "$color",
            "title": "System Monitor Alert",
            "text": "$message",
            "footer": "$(get_hostname) | $(date '+%Y-%m-%d %H:%M:%S')"
        }
    ]
}
EOF
)
    
    if command -v curl &>/dev/null; then
        curl -s -X POST -H 'Content-type: application/json' \
            --data "$payload" "$NOTIFY_SLACK_WEBHOOK" &>/dev/null
        log_debug "Slack notification sent"
    fi
}

# Send all notifications
send_alerts() {
    local subject="$1"
    local body="$2"
    local severity="${3:-warning}"
    
    send_email_notification "$subject" "$body"
    send_slack_notification "$body" "$severity"
}

#------------------------------------------------------------------------------
# RESOURCE CHECK FUNCTIONS
#------------------------------------------------------------------------------

# Check CPU usage
check_cpu() {
    local cpu_usage
    cpu_usage=$(get_cpu_usage)
    
    log_debug "CPU Usage: ${cpu_usage}%"
    
    if [[ $cpu_usage -gt $THRESHOLD_CPU ]]; then
        local msg="CPU ALERT: ${cpu_usage}% (threshold: ${THRESHOLD_CPU}%)"
        log_warn "$msg"
        ALERTS_MESSAGES+=("$msg")
        ((ALERTS_COUNT++))
        return 1
    fi
    
    log_info "CPU: ${cpu_usage}% - OK"
    return 0
}

# Check memory usage
check_memory() {
    local mem_usage
    mem_usage=$(get_memory_usage)
    
    log_debug "Memory Usage: ${mem_usage}%"
    
    if [[ $mem_usage -gt $THRESHOLD_MEM ]]; then
        local msg="MEMORY ALERT: ${mem_usage}% (threshold: ${THRESHOLD_MEM}%)"
        log_warn "$msg"
        ALERTS_MESSAGES+=("$msg")
        ((ALERTS_COUNT++))
        return 1
    fi
    
    log_info "Memory: ${mem_usage}% - OK"
    return 0
}

# Check swap usage
check_swap() {
    local swap_usage
    swap_usage=$(get_swap_usage)
    
    log_debug "Swap Usage: ${swap_usage}%"
    
    if [[ $swap_usage -gt $THRESHOLD_SWAP ]]; then
        local msg="SWAP ALERT: ${swap_usage}% (threshold: ${THRESHOLD_SWAP}%)"
        log_warn "$msg"
        ALERTS_MESSAGES+=("$msg")
        ((ALERTS_COUNT++))
        return 1
    fi
    
    log_info "Swap: ${swap_usage}% - OK"
    return 0
}

# Check disk usage
check_disk() {
    local disk_alerts=0
    
    while IFS='|' read -r mount_point size used avail percent; do
        # Skip excluded mount points
        local skip=false
        for exclude in "${DISK_EXCLUDE_MOUNTS[@]}"; do
            if [[ "$mount_point" == "$exclude" ]]; then
                log_debug "Skipping excluded mount point: $mount_point"
                skip=true
                break
            fi
        done
        $skip && continue
        
        log_debug "Disk $mount_point: ${percent}%"
        
        if [[ ${percent:-0} -gt $THRESHOLD_DISK ]]; then
            local msg="DISK ALERT: $mount_point at ${percent}% (threshold: ${THRESHOLD_DISK}%)"
            log_warn "$msg"
            ALERTS_MESSAGES+=("$msg")
            ((disk_alerts++))
        fi
    done < <(get_all_disk_info)
    
    if [[ $disk_alerts -gt 0 ]]; then
        ((ALERTS_COUNT += disk_alerts))
        return 1
    fi
    
    log_info "Disk: All partitions OK"
    return 0
}

# Check load average
check_load() {
    local load_avg
    load_avg=$(get_load_average)
    local load1
    load1=$(echo "$load_avg" | awk '{print $1}')
    
    local cores
    cores=$(get_cpu_cores)
    local threshold=$((cores * THRESHOLD_LOAD_MULT))
    
    log_debug "Load Average: $load_avg (threshold: $threshold)"
    
    # Convert to integer for comparison
    local load1_int=${load1%.*}
    
    if [[ ${load1_int:-0} -gt $threshold ]]; then
        local msg="LOAD ALERT: $load1 (threshold: ${threshold} = ${cores} cores × ${THRESHOLD_LOAD_MULT})"
        log_warn "$msg"
        ALERTS_MESSAGES+=("$msg")
        ((ALERTS_COUNT++))
        return 1
    fi
    
    log_info "Load: $load_avg - OK"
    return 0
}

#------------------------------------------------------------------------------
# OUTPUT FUNCTIONS
#------------------------------------------------------------------------------

# Generate text format output
output_text() {
    local status="${1:-OK}"
    
    echo "===== SYSTEM MONITOR REPORT ====="
    echo "Timestamp: $(date '+%Y-%m-%d %H:%M:%S')"
    echo "Host: $(get_hostname)"
    echo "Status: $status"
    echo ""
    echo "----- METRICS -----"
    echo "CPU:    $(get_cpu_usage)% (threshold: ${THRESHOLD_CPU}%)"
    echo "Memory: $(get_memory_usage)% (threshold: ${THRESHOLD_MEM}%)"
    echo "Swap:   $(get_swap_usage)% (threshold: ${THRESHOLD_SWAP}%)"
    echo "Load:   $(get_load_average)"
    echo ""
    echo "----- DISK -----"
    get_all_disk_info | while IFS='|' read -r mount size used avail percent; do
        local status_mark="✓"
        if [[ ${percent:-0} -gt $THRESHOLD_DISK ]]; then
            status_mark="✗"
        fi
        printf "  [%s] %-20s %5s%% of %8s\n" "$status_mark" "$mount" "$percent" "$size"
    done
    
    if [[ ${#ALERTS_MESSAGES[@]} -gt 0 ]]; then
        echo ""
        echo "----- ALERTS (${#ALERTS_MESSAGES[@]}) -----"
        for alert in "${ALERTS_MESSAGES[@]}"; do
            echo "  • $alert"
        done
    fi
    
    echo "================================="
}

# Generate JSON format output
output_json() {
    local status="${1:-OK}"
    local alerts_json="[]"
    
    if [[ ${#ALERTS_MESSAGES[@]} -gt 0 ]]; then
        alerts_json="["
        local first=true
        for alert in "${ALERTS_MESSAGES[@]}"; do
            if ! $first; then alerts_json+=","; fi
            alerts_json+="\"$alert\""
            first=false
        done
        alerts_json+="]"
    fi
    
    cat << EOF
{
  "timestamp": "$(date -Iseconds)",
  "hostname": "$(get_hostname)",
  "status": "$status",
  "alerts_count": $ALERTS_COUNT,
  "metrics": {
    "cpu": {
      "usage": $(get_cpu_usage),
      "threshold": $THRESHOLD_CPU,
      "cores": $(get_cpu_cores)
    },
    "memory": {
      "usage": $(get_memory_usage),
      "threshold": $THRESHOLD_MEM
    },
    "swap": {
      "usage": $(get_swap_usage),
      "threshold": $THRESHOLD_SWAP
    },
    "load": {
      "average": "$(get_load_average)",
      "threshold_multiplier": $THRESHOLD_LOAD_MULT
    }
  },
  "alerts": $alerts_json
}
EOF
}

# Generate CSV format output
output_csv() {
    echo "timestamp,hostname,cpu_usage,mem_usage,swap_usage,load1,alerts_count,status"
    local load1
    load1=$(get_load_average | awk '{print $1}')
    local status="${1:-OK}"
    echo "$(date -Iseconds),$(get_hostname),$(get_cpu_usage),$(get_memory_usage),$(get_swap_usage),$load1,$ALERTS_COUNT,$status"
}

# Generate output in configured format
generate_output() {
    local status="OK"
    if [[ $ALERTS_COUNT -gt 0 ]]; then
        status="ALERT"
    fi
    
    case "$OUTPUT_FORMAT" in
        json) output_json "$status" ;;
        csv)  output_csv "$status" ;;
        *)    output_text "$status" ;;
    esac
}

#------------------------------------------------------------------------------
# MAIN CHECK FUNCTION
#------------------------------------------------------------------------------

run_checks() {
    # Reset counters
    ALERTS_COUNT=0
    ALERTS_MESSAGES=()
    
    log_header "Starting system check"
    
    local check_errors=0
    
    # Run all checks
    check_cpu    || ((check_errors++))
    check_memory || ((check_errors++))
    check_swap   || ((check_errors++))
    check_disk   || ((check_errors++))
    check_load   || ((check_errors++))
    
    LAST_CHECK_TIME=$(date +%s)
    
    # Generate output
    generate_output
    
    # Send notifications if there are alerts
    if [[ $ALERTS_COUNT -gt 0 ]]; then
        log_separator
        log_warn "Check complete: $ALERTS_COUNT active alerts"
        
        local alert_body
        alert_body=$(printf '%s\n' "${ALERTS_MESSAGES[@]}")
        
        send_alerts \
            "[ALERT] System Monitor - $(get_hostname) - $ALERTS_COUNT alerts" \
            "$alert_body" \
            "danger"
        
        return 2
    fi
    
    log_separator
    log_info "Check complete: All resources OK"
    return 0
}

#------------------------------------------------------------------------------
# DAEMON MODE
#------------------------------------------------------------------------------

daemon_loop() {
    log_info "Started in daemon mode with interval of ${MONITOR_INTERVAL}s"
    
    while $RUNNING; do
        run_checks || true
        
        log_debug "Waiting ${MONITOR_INTERVAL}s until next check..."
        
        # Interruptible sleep
        local waited=0
        while $RUNNING && [[ $waited -lt $MONITOR_INTERVAL ]]; do
            sleep 1
            ((waited++))
        done
    done
    
    log_info "Daemon stopped"
}

#------------------------------------------------------------------------------
# CLEANUP AND SIGNAL HANDLERS
#------------------------------------------------------------------------------

cleanup() {
    log_debug "Cleanup in progress..."
    
    # Release lock
    if [[ -n "${LOCK_FILE:-}" ]]; then
        release_lock "$LOCK_FILE"
    fi
    
    log_debug "Cleanup complete"
}

handle_signal() {
    local signal="$1"
    log_info "Signal received: $signal"
    RUNNING=false
}

#------------------------------------------------------------------------------
# MAIN
#------------------------------------------------------------------------------

main() {
    # Initialise configuration
    init_config "${ORIGINAL_ARGS[@]}" || die "Error initialising configuration"
    
    # Setup cleanup
    trap cleanup EXIT
    trap 'handle_signal INT' INT
    trap 'handle_signal TERM' TERM
    trap 'handle_signal HUP' HUP
    
    log_header "System Monitor v1.0.0"
    log_info "Host: $(get_hostname)"
    log_info "Started: $(date '+%Y-%m-%d %H:%M:%S')"
    
    # Acquire lock if daemon
    if [[ "$DAEMON_MODE" == "true" ]]; then
        acquire_lock "$LOCK_FILE" || die "Cannot acquire lock. Another instance running?"
    fi
    
    # Run in appropriate mode
    if [[ "$DAEMON_MODE" == "true" ]]; then
        daemon_loop
    else
        run_checks
        exit $?
    fi
}

# Run main only if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi
