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
#   - Required commands: grep, df, ps, awk; readable Linux /proc counters
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
cpu_totals() {
    awk 'NR==1 { if ($1!="cpu" || NF<9) exit 1;
        total=0; for(i=2;i<=9;i++){if($i !~ /^[0-9]+$/) exit 1; total+=$i}
        printf "%.0f %.0f\n",total,$5+$6; ok=1 } END {if(!ok) exit 1}'
}
get_cpu_usage() {
    local first second values1 values2 total1 idle1 total2 idle2 elapsed idle_elapsed
    [[ -r /proc/stat ]] || { log_error "CPU counters are unavailable"; return 1; }
    first=$(grep '^cpu ' /proc/stat) || return 1
    sleep "${CPU_SAMPLE_INTERVAL:-0.5}" || return 1
    second=$(grep '^cpu ' /proc/stat) || return 1
    # Sum user..steal only; guest/guest_nice are already in user/nice.
    # This model treats idle+iowait as non-busy time; invalid intervals are unavailable.
    values1=$(cpu_totals <<< "$first") || return 1
    values2=$(cpu_totals <<< "$second") || return 1
    IFS=' ' read -r total1 idle1 <<< "$values1"
    IFS=' ' read -r total2 idle2 <<< "$values2"
    elapsed=$((total2-total1)); idle_elapsed=$((idle2-idle1))
    (( elapsed > 0 && idle_elapsed >= 0 && idle_elapsed <= elapsed )) || {
        log_error "CPU counters did not yield a valid interval"; return 1;
    }
    printf '%s\n' "$((100 * (elapsed-idle_elapsed) / elapsed))"
}

# Get number of CPU cores
get_cpu_cores() {
    local cores
    cores=$(grep -c '^processor[[:space:]]*:' /proc/cpuinfo) || return 1
    [[ $cores =~ ^[1-9][0-9]*$ ]] || return 1
    printf '%s\n' "$cores"
}

# Get load average (1, 5, 15 minutes)
# Returns: "load1 load5 load15"
get_load_average() {
    awk 'NR==1 {for(i=1;i<=3;i++) if($i !~ /^[0-9]+([.][0-9]+)?$/) exit 1;
        print $1,$2,$3;ok=1} END{if(!ok)exit 1}' /proc/loadavg
}

# Check if load average is critical
# Usage: is_load_critical [threshold_multiplier]
# threshold_multiplier: multiplication factor for number of cores (default: 2)
is_load_critical() {
    local multiplier="${1:-2}" cores loads
    [[ $multiplier =~ ^[0-9]+([.][0-9]+)?$ ]] || return 2
    cores=$(get_cpu_cores) || return 2
    loads=$(get_load_average) || return 2
    awk -v m="$multiplier" -v cores="$cores" '{exit !($1 > cores*m)}' <<< "$loads"
}

#------------------------------------------------------------------------------
# MEMORY FUNCTIONS
#------------------------------------------------------------------------------

# Get memory usage as percentage
# Returns: integer 0-100
get_memory_usage() {
    # /proc/meminfo labels kB, conventionally KiB. MemAvailable is required.
    awk '/^(MemTotal|MemAvailable):/ {if($2 !~ /^[0-9]+$/ || $3!="kB") exit 1;v[$1]=$2}
      END {t=v["MemTotal:"];a=v["MemAvailable:"];
        if(!("MemTotal:" in v) || !("MemAvailable:" in v) || t<=0 || a<0 || a>t) exit 1;
        printf "%.0f\n",100*(t-a)/t}' /proc/meminfo
}

# Get memory details: total, used, free, available
# Returns: "total_mb used_mb free_mb available_mb"
get_memory_details() {
    # Total, used=(total-available), free, available in MiB; unavailable is non-zero exit.
    awk '/^(MemTotal|MemAvailable|MemFree):/ {if($2 !~ /^[0-9]+$/ || $3!="kB") exit 1;v[$1]=$2}
      END {t=v["MemTotal:"];a=v["MemAvailable:"];f=v["MemFree:"];
        if(!("MemTotal:" in v) || !("MemAvailable:" in v) || !("MemFree:" in v) || t<=0 || a>t || f>t) exit 1;
        printf "%d %d %d %d\n",t/1024,(t-a)/1024,f/1024,a/1024}' /proc/meminfo
}

# Get swap usage as percentage
get_swap_usage() {
    awk '/^(SwapTotal|SwapFree):/ {if($2 !~ /^[0-9]+$/ || $3!="kB") exit 1;v[$1]=$2}
      END {t=v["SwapTotal:"];f=v["SwapFree:"];
        if(!("SwapTotal:" in v) || !("SwapFree:" in v) || f>t) exit 1;
        if(t==0) print 0; else printf "%.0f\n",100*(t-f)/t}' /proc/meminfo
}

#------------------------------------------------------------------------------
# DISK FUNCTIONS
#------------------------------------------------------------------------------

# Get usage for a specific mount point
# Usage: get_disk_usage "/mount/point"
# Returns: integer 0-100
get_disk_usage() {
    local table
    table=$(LC_ALL=C df -P -- "${1:-/}") || return 1
    awk 'NR==2 {gsub(/%/,"",$5);if($5 !~ /^[0-9]+$/ || ($5+0)>100) exit 1;print $5;ok=1}
         END {if(!ok)exit 1}' <<< "$table"
}

# Get complete information about all partitions
# Format: mount_point|total|used|available|percent
# Excludes: tmpfs, devtmpfs, squashfs
get_all_disk_info() {
    local table
    table=$(LC_ALL=C df -hP -x tmpfs -x devtmpfs -x squashfs) || return 1
    # Human report fields use |; percent-escape delimiters in mount names.
    awk 'NR>1 {p=$5;sub(/%$/,"",p);if(p !~ /^[0-9]+$/ || (p+0)>100)exit 1;
      mount=$6;for(i=7;i<=NF;i++)mount=mount " " $i;gsub(/%/,"%25",mount);gsub(/[|]/,"%7C",mount);
      print mount "|" $2 "|" $3 "|" $4 "|" p}' <<< "$table"
}

# Get list of mount points with usage over threshold
# Usage: get_disks_over_threshold 85
get_disks_over_threshold() {
    local threshold="${1:-85}" rows mount size used avail percent
    [[ $threshold =~ ^[0-9]{1,3}$ ]] && ((10#$threshold<=100)) || return 2
    rows=$(get_all_disk_info) || return 2
    while IFS='|' read -r mount size used avail percent; do
        [[ -n $mount ]] || continue
        if ((percent >= 10#$threshold)); then printf '%s:%s%%\n' "$mount" "$percent"; fi
    done <<< "$rows"
}

# Check available space in MB for a mount point
# Usage: get_available_space_mb "/path"
get_available_space_mb() {
    local table
    table=$(LC_ALL=C df -Pm -- "${1:-/}") || return 1
    awk 'NR==2 {if($4 !~ /^[0-9]+$/)exit 1;print $4;ok=1} END{if(!ok)exit 1}' <<< "$table"
}

#------------------------------------------------------------------------------
# PROCESS FUNCTIONS
#------------------------------------------------------------------------------

# Get total process count
get_process_count() {
    local rows
    rows=$(ps -e -o pid=) || return 1
    awk 'NF{count++} END{print count+0}' <<< "$rows"
}

# Get top N processes by CPU usage
# Usage: get_top_cpu_processes [N]
get_top_cpu_processes() {
    local count="${1:-5}" rows
    [[ $count =~ ^[1-9][0-9]*$ && ${#count} -le 6 ]] || return 2
    rows=$(LC_ALL=C ps -eo pid=,pcpu=,pmem=,comm= --sort=-pcpu) || return 1
    # comm is the final field, so embedded spaces do not shift numeric columns.
    # Encode % and | in names for this human-report delimiter contract.
    awk -v n="$count" 'NR<=n {pid=$1;cpu=$2;mem=$3;$1=$2=$3="";sub(/^[[:space:]]+/,"");name=$0;
      gsub(/%/,"%25",name);gsub(/[|]/,"%7C",name);printf "%s|%s|%s|%s\n",pid,name,cpu,mem}' <<< "$rows"
}

# Get top N processes by memory usage
# Usage: get_top_mem_processes [N]
get_top_mem_processes() {
    local count="${1:-5}" rows
    [[ $count =~ ^[1-9][0-9]*$ && ${#count} -le 6 ]] || return 2
    rows=$(LC_ALL=C ps -eo pid=,pcpu=,pmem=,comm= --sort=-pmem) || return 1
    # comm is the final field, so embedded spaces do not shift numeric columns.
    # Encode % and | in names for this human-report delimiter contract.
    awk -v n="$count" 'NR<=n {pid=$1;cpu=$2;mem=$3;$1=$2=$3="";sub(/^[[:space:]]+/,"");name=$0;
      gsub(/%/,"%25",name);gsub(/[|]/,"%7C",name);printf "%s|%s|%s|%s\n",pid,name,mem,cpu}' <<< "$rows"
}

# Check if a process is running
# Usage: is_process_running "process_name"
is_process_running() {
    local process_name="$1"
    pgrep -x "$process_name" &>/dev/null
}

# Get PID of a process by name
get_process_pid() {
    local rows
    rows=$(pgrep -x -- "$1") || return $?
    printf '%s\n' "${rows%%$'\n'*}"
}

#------------------------------------------------------------------------------
# NETWORK FUNCTIONS (optional)
#------------------------------------------------------------------------------

# Get network statistics for an interface
# Usage: get_network_stats "eth0"
get_network_stats() {
    local interface="${1:-eth0}" rx_bytes tx_bytes
    [[ $interface =~ ^[A-Za-z0-9_.:-]+$ && $interface != . && $interface != .. ]] || return 2
    rx_bytes=$(cat -- "/sys/class/net/$interface/statistics/rx_bytes") || return 1
    tx_bytes=$(cat -- "/sys/class/net/$interface/statistics/tx_bytes") || return 1
    [[ $rx_bytes =~ ^[0-9]+$ && $tx_bytes =~ ^[0-9]+$ ]] || return 1
    printf '%s %s\n' "$rx_bytes" "$tx_bytes"
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
    awk 'NR==1 {if($1 !~ /^[0-9]+([.][0-9]+)?$/)exit 1;print int($1);ok=1} END{if(!ok)exit 1}' /proc/uptime
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
    echo "Total/Used/Free/Available (MiB): $mem_details"
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
