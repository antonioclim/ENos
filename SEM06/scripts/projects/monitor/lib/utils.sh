#!/bin/bash
#==============================================================================
# utils.sh - Utility functions for collecting system information
#==============================================================================
# DESCRIPTION:
#   Functions for extracting system metrics: CPU, memory, disk, processes.
#   All functions return normalised and verified values.
#
# DEPENDENCIES:
#   - Must be loaded after core.sh
#   - Required commands: top, free, df, ps, awk
#
# USAGE:
#   source "${SCRIPT_DIR}/lib/utils.sh"
#
# AUTHOR: ASE Bucharest - CSIE | Operating Systems
# VERSION: 1.0.0
#==============================================================================

readonly UTILS_VERSION="1.0.0"

#------------------------------------------------------------------------------
# CPU FUNCTIONS
#------------------------------------------------------------------------------

# Get total CPU usage as percentage
# Returns: integer 0-100
get_cpu_usage() {
    local cpu_line
    local idle_percent
    local cpu_usage
    
    # Method 1: /proc/stat (more accurate, but requires two readings)
    if [[ -f /proc/stat ]]; then
        # First reading
        local cpu1
        cpu1=$(grep '^cpu ' /proc/stat)
        local user1 nice1 system1 idle1 iowait1 irq1 softirq1
        read -r _ user1 nice1 system1 idle1 iowait1 irq1 softirq1 _ <<< "$cpu1"
        
        sleep 0.5
        
        # Second reading
        local cpu2
        cpu2=$(grep '^cpu ' /proc/stat)
        local user2 nice2 system2 idle2 iowait2 irq2 softirq2
        read -r _ user2 nice2 system2 idle2 iowait2 irq2 softirq2 _ <<< "$cpu2"
        
        # Calculate differences
        local total1=$((user1 + nice1 + system1 + idle1 + iowait1 + irq1 + softirq1))
        local total2=$((user2 + nice2 + system2 + idle2 + iowait2 + irq2 + softirq2))
        local idle_diff=$((idle2 - idle1))
        local total_diff=$((total2 - total1))
        
        if [[ $total_diff -gt 0 ]]; then
            cpu_usage=$((100 - (100 * idle_diff / total_diff)))
        else
            cpu_usage=0
        fi
    else
        # Alternative method: top (less accurate)
        cpu_line=$(top -bn1 | grep "Cpu(s)" 2>/dev/null || top -bn1 | grep "CPU:" 2>/dev/null)
        
        if [[ -n "$cpu_line" ]]; then
            # Extract idle and calculate usage
            idle_percent=$(echo "$cpu_line" | awk '{
                for(i=1; i<=NF; i++) {
                    if($i ~ /id/) { print $(i-1); exit }
                }
            }' | tr -d '%,')
            
            if [[ -n "$idle_percent" ]]; then
                cpu_usage=$(echo "100 - $idle_percent" | bc 2>/dev/null || echo $((100 - ${idle_percent%.*})))
                cpu_usage=${cpu_usage%.*}  # Convert to integer
            else
                cpu_usage=0
            fi
        else
            log_warn "Cannot determine CPU usage"
            cpu_usage=0
        fi
    fi
    
    # Ensure valid range 0-100
    if [[ $cpu_usage -lt 0 ]]; then cpu_usage=0; fi
    if [[ $cpu_usage -gt 100 ]]; then cpu_usage=100; fi
    
    echo "$cpu_usage"
}

# Get number of CPU cores
get_cpu_cores() {
    local cores
    
    if [[ -f /proc/cpuinfo ]]; then
        cores=$(grep -c "^processor" /proc/cpuinfo)
    else
        cores=$(nproc 2>/dev/null || echo 1)
    fi
    
    echo "$cores"
}

# Get load average (1, 5, 15 minutes)
# Returns: "load1 load5 load15"
get_load_average() {
    if [[ -f /proc/loadavg ]]; then
        awk '{print $1, $2, $3}' /proc/loadavg
    else
        uptime | awk -F'load average:' '{print $2}' | tr ',' ' ' | xargs
    fi
}

# Check if load average is critical
# Usage: is_load_critical [threshold_multiplier]
# threshold_multiplier: multiplication factor for number of cores (default: 2)
is_load_critical() {
    local multiplier="${1:-2}"
    local cores
    cores=$(get_cpu_cores)
    local threshold=$((cores * multiplier))
    
    local load1
    load1=$(get_load_average | awk '{print $1}')
    load1=${load1%.*}  # Convert to integer
    
    [[ ${load1:-0} -gt $threshold ]]
}

#------------------------------------------------------------------------------
# MEMORY FUNCTIONS
#------------------------------------------------------------------------------

# Get memory usage as percentage
# Returns: integer 0-100
get_memory_usage() {
    local mem_usage
    
    if command -v free &>/dev/null; then
        # free with -m option for values in MB
        mem_usage=$(free | awk '/^Mem:/ {
            total = $2
            used = $3
            if (total > 0) {
                printf "%.0f", (used / total) * 100
            } else {
                print 0
            }
        }')
    elif [[ -f /proc/meminfo ]]; then
        # Direct parsing of /proc/meminfo
        local total available
        total=$(grep "^MemTotal:" /proc/meminfo | awk '{print $2}')
        available=$(grep "^MemAvailable:" /proc/meminfo | awk '{print $2}')
        
        if [[ -z "$available" ]]; then
            # Fallback for older kernel
            local free buffers cached
            free=$(grep "^MemFree:" /proc/meminfo | awk '{print $2}')
            buffers=$(grep "^Buffers:" /proc/meminfo | awk '{print $2}')
            cached=$(grep "^Cached:" /proc/meminfo | awk '{print $2}')
            available=$((free + buffers + cached))
        fi
        
        local used=$((total - available))
        mem_usage=$((used * 100 / total))
    else
        log_warn "Cannot determine memory usage"
        mem_usage=0
    fi
    
    echo "$mem_usage"
}

# Get memory details: total, used, free, available
# Returns: "total_mb used_mb free_mb available_mb"
get_memory_details() {
    if command -v free &>/dev/null; then
        free -m | awk '/^Mem:/ {print $2, $3, $4, $7}'
    else
        log_warn "Command 'free' is not available"
        echo "0 0 0 0"
    fi
}

# Get swap usage as percentage
get_swap_usage() {
    local swap_usage
    
    swap_usage=$(free | awk '/^Swap:/ {
        total = $2
        used = $3
        if (total > 0) {
            printf "%.0f", (used / total) * 100
        } else {
            print 0
        }
    }')
    
    echo "${swap_usage:-0}"
}

#------------------------------------------------------------------------------
# DISK FUNCTIONS
#------------------------------------------------------------------------------

# Get usage for a specific mount point
# Usage: get_disk_usage "/mount/point"
# Returns: integer 0-100
get_disk_usage() {
    local mount_point="${1:-/}"
    local usage
    
    usage=$(df -h "$mount_point" 2>/dev/null | awk 'NR==2 {
        gsub(/%/, "", $5)
        print $5
    }')
    
    echo "${usage:-0}"
}

# Get complete information about all partitions
# Format: mount_point|total|used|available|percent
# Excludes: tmpfs, devtmpfs, squashfs
get_all_disk_info() {
    df -h 2>/dev/null | tail -n +2 | grep -v -E "^(tmpfs|devtmpfs|squashfs|overlay)" | \
    while read -r filesystem size used avail percent mount_point; do
        # Clean percentage
        percent=${percent%\%}
        echo "${mount_point}|${size}|${used}|${avail}|${percent}"
    done
}

# Get list of mount points with usage over threshold
# Usage: get_disks_over_threshold 85
get_disks_over_threshold() {
    local threshold="${1:-85}"
    
    get_all_disk_info | while IFS='|' read -r mount size used avail percent; do
        if [[ ${percent:-0} -ge $threshold ]]; then
            echo "${mount}:${percent}%"
        fi
    done
}

# Check available space in MB for a mount point
# Usage: get_available_space_mb "/path"
get_available_space_mb() {
    local path="${1:-/}"
    
    df -m "$path" 2>/dev/null | awk 'NR==2 {print $4}'
}

#------------------------------------------------------------------------------
# PROCESS FUNCTIONS
#------------------------------------------------------------------------------

# Get total process count
get_process_count() {
    ps aux 2>/dev/null | wc -l | awk '{print $1 - 1}'  # -1 for header
}

# Get top N processes by CPU usage
# Usage: get_top_cpu_processes [N]
get_top_cpu_processes() {
    local count="${1:-5}"
    
    ps aux --sort=-%cpu 2>/dev/null | head -n $((count + 1)) | tail -n "$count" | \
    awk '{printf "%s|%s|%s|%s\n", $2, $11, $3, $4}'
    # Format: PID|COMMAND|CPU%|MEM%
}

# Get top N processes by memory usage
# Usage: get_top_mem_processes [N]
get_top_mem_processes() {
    local count="${1:-5}"
    
    ps aux --sort=-%mem 2>/dev/null | head -n $((count + 1)) | tail -n "$count" | \
    awk '{printf "%s|%s|%s|%s\n", $2, $11, $4, $3}'
    # Format: PID|COMMAND|MEM%|CPU%
}

# Check if a process is running
# Usage: is_process_running "process_name"
is_process_running() {
    local process_name="$1"
    pgrep -x "$process_name" &>/dev/null
}

# Get PID of a process by name
get_process_pid() {
    local process_name="$1"
    pgrep -x "$process_name" 2>/dev/null | head -n1
}

#------------------------------------------------------------------------------
# NETWORK FUNCTIONS (optional)
#------------------------------------------------------------------------------

# Get network statistics for an interface
# Usage: get_network_stats "eth0"
get_network_stats() {
    local interface="${1:-eth0}"
    local rx_bytes tx_bytes
    
    if [[ -d "/sys/class/net/$interface" ]]; then
        rx_bytes=$(cat "/sys/class/net/$interface/statistics/rx_bytes" 2>/dev/null || echo 0)
        tx_bytes=$(cat "/sys/class/net/$interface/statistics/tx_bytes" 2>/dev/null || echo 0)
        echo "$rx_bytes $tx_bytes"
    else
        echo "0 0"
    fi
}

# Get list of active network interfaces
get_active_interfaces() {
    ip -o link show 2>/dev/null | awk -F': ' '$3 ~ /UP/ {print $2}'
}

#------------------------------------------------------------------------------
# SYSTEM FUNCTIONS
#------------------------------------------------------------------------------

# Get uptime in seconds
get_uptime_seconds() {
    if [[ -f /proc/uptime ]]; then
        awk '{print int($1)}' /proc/uptime
    else
        # Fallback: parse uptime output
        uptime | awk '{
            split($3, a, ":")
            if ($4 ~ /day/) {
                days = $3
                split($5, a, ":")
                hours = a[1]
                mins = a[2]
            } else {
                days = 0
                hours = a[1]
                mins = a[2]
            }
            print (days * 86400) + (hours * 3600) + (mins * 60)
        }'
    fi
}

# Get kernel information
get_kernel_info() {
    uname -r
}

# Get hostname
get_hostname() {
    hostname 2>/dev/null || cat /etc/hostname 2>/dev/null || echo "unknown"
}

# Get distribution information
get_distro_info() {
    if [[ -f /etc/os-release ]]; then
        source /etc/os-release
        echo "${PRETTY_NAME:-$NAME $VERSION}"
    elif [[ -f /etc/lsb-release ]]; then
        source /etc/lsb-release
        echo "${DISTRIB_DESCRIPTION:-$DISTRIB_ID $DISTRIB_RELEASE}"
    else
        echo "Unknown Linux"
    fi
}

#------------------------------------------------------------------------------
# REPORTING FUNCTIONS
#------------------------------------------------------------------------------

# Generate a complete system status report
generate_system_report() {
    local include_processes="${1:-true}"
    
    echo "===== SYSTEM REPORT ====="
    echo "Host: $(get_hostname)"
    echo "Distribution: $(get_distro_info)"
    echo "Kernel: $(get_kernel_info)"
    echo "Uptime: $(format_duration "$(get_uptime_seconds)")"
    echo ""
    echo "----- CPU -----"
    echo "Cores: $(get_cpu_cores)"
    echo "Usage: $(get_cpu_usage)%"
    echo "Load Average: $(get_load_average)"
    echo ""
    echo "----- MEMORY -----"
    local mem_details
    mem_details=$(get_memory_details)
    echo "Total/Used/Free/Available (MB): $mem_details"
    echo "Usage: $(get_memory_usage)%"
    echo "Swap: $(get_swap_usage)%"
    echo ""
    echo "----- DISK -----"
    get_all_disk_info | while IFS='|' read -r mount size used avail percent; do
        printf "  %-20s %8s %8s %8s %5s%%\n" "$mount" "$size" "$used" "$avail" "$percent"
    done
    
    if [[ "$include_processes" == "true" ]]; then
        echo ""
        echo "----- TOP PROCESSES (CPU) -----"
        get_top_cpu_processes 5 | while IFS='|' read -r pid cmd cpu mem; do
            printf "  PID %-8s CPU: %5s%% MEM: %5s%% %s\n" "$pid" "$cpu" "$mem" "$cmd"
        done
    fi
    
    echo ""
    echo "===== END REPORT ====="
}

#------------------------------------------------------------------------------
# INITIALISATION
#------------------------------------------------------------------------------

# Check required commands
_check_utils_dependencies() {
    local missing=()
    
    for cmd in awk grep df free ps; do
        command -v "$cmd" &>/dev/null || missing+=("$cmd")
    done
    
    if [[ ${#missing[@]} -gt 0 ]]; then
        log_warn "Missing optional commands: ${missing[*]}"
    fi
}

# Check dependencies on load
_check_utils_dependencies

log_debug "utils.sh v${UTILS_VERSION} loaded"
