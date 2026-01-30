#!/usr/bin/env bash
#
# S06_HW01_Monitor_Template.sh - Template for monitoring assignment
#
# INSTRUCTIONS:
# 1. Complete functions marked with TODO
# 2. Do not modify function signatures
# 3. Run tests with: ./test_hw01.sh
#
# Author: [Your name]
# Group: [Your group]
# Date: [Date]
#

set -euo pipefail

# === CONFIGURATION (do not modify) ===
readonly SCRIPT_NAME=$(basename "$0")
readonly VERSION="1.0"

# === TODO: Complete the thresholds ===
readonly THRESHOLD_CPU="${THRESHOLD_CPU:-80}"        # CPU percentage
readonly THRESHOLD_MEM="${THRESHOLD_MEM:-85}"        # Memory percentage
readonly THRESHOLD_DISK="${THRESHOLD_DISK:-90}"      # Disk percentage

# === HELPER FUNCTIONS (do not modify) ===
log() {
    local level="${1:-INFO}"
    shift
    printf '[%s] [%-5s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$level" "$*"
}

die() {
    log "FATAL" "$*" >&2
    exit 1
}

usage() {
    cat << EOF
Usage: $SCRIPT_NAME [OPTIONS]

System monitoring script.

Options:
    -c, --cpu       Check CPU only
    -m, --memory    Check memory only
    -d, --disk      Check disk only
    -a, --all       Check all (default)
    -j, --json      Output in JSON format
    -h, --help      Display this message
    -v, --version   Display version

Examples:
    $SCRIPT_NAME --all
    $SCRIPT_NAME --cpu --memory
    $SCRIPT_NAME --json

Exit codes:
    0 - All checks OK
    1 - General error
    2 - Alerts detected
EOF
    exit 0
}

# === TODO: IMPLEMENT THESE FUNCTIONS ===

# Function: get_cpu_usage
# Description: Calculate CPU usage percentage
# Input: none
# Output: Integer representing % CPU (e.g.: "42")
# Hint: Use /proc/stat
get_cpu_usage() {
    # TODO: Implement
    # Suggested steps:
    # 1. Read "cpu " line from /proc/stat
    # 2. Extract values: user, nice, system, idle, iowait, irq, softirq
    # 3. Calculate: active = user + nice + system
    # 4. Calculate: total = active + idle + iowait + irq + softirq
    # 5. Return: active * 100 / total
    
    echo "0"  # Placeholder - replace with your implementation
}

# Function: get_memory_usage
# Description: Calculate used memory percentage
# Input: none
# Output: Integer representing % memory (e.g.: "65")
# Hint: Use /proc/meminfo
get_memory_usage() {
    # TODO: Implement
    # Suggested steps:
    # 1. Read MemTotal and MemAvailable from /proc/meminfo
    # 2. Calculate: used = (MemTotal - MemAvailable) * 100 / MemTotal
    # 3. Return the value
    
    echo "0"  # Placeholder
}

# Function: get_disk_usage
# Description: Return disk usage for root partition
# Input: none
# Output: Integer representing % disk (e.g.: "34")
# Hint: Use df command
get_disk_usage() {
    # TODO: Implement
    # Suggested steps:
    # 1. Run df on /
    # 2. Extract usage percentage
    # 3. Remove the % character
    
    echo "0"  # Placeholder
}

# Function: check_threshold
# Description: Check if value exceeds threshold
# Input: $1 = value, $2 = threshold, $3 = metric name
# Output: Alert message (if applicable)
# Return: 0 if OK, 1 if alert
check_threshold() {
    local value="$1"
    local threshold="$2"
    local metric="$3"
    
    # TODO: Implement comparison and output
    # If value > threshold:
    #   - Display alert
    #   - Return 1
    # Otherwise:
    #   - Display OK
    #   - Return 0
    
    return 0  # Placeholder
}

# Function: output_json
# Description: Generate output in JSON format
# Input: $1 = cpu, $2 = mem, $3 = disk
# Output: Valid JSON
output_json() {
    local cpu="$1"
    local mem="$2" 
    local disk="$3"
    
    # TODO: Implement
    # Format:
    # {
    #   "timestamp": "YYYY-MM-DD HH:MM:SS",
    #   "metrics": {
    #     "cpu": {"value": N, "threshold": M, "status": "ok|alert"},
    #     "memory": {...},
    #     "disk": {...}
    #   }
    # }
    
    echo "{}"  # Placeholder
}

# === MAIN (do not modify structure) ===
main() {
    local check_cpu=false
    local check_mem=false
    local check_disk=false
    local output_format="text"
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -c|--cpu) check_cpu=true; shift ;;
            -m|--memory) check_mem=true; shift ;;
            -d|--disk) check_disk=true; shift ;;
            -a|--all) check_cpu=true; check_mem=true; check_disk=true; shift ;;
            -j|--json) output_format="json"; shift ;;
            -h|--help) usage ;;
            -v|--version) echo "$VERSION"; exit 0 ;;
            *) die "Unknown option: $1" ;;
        esac
    done
    
    # Default: check all
    if [[ "$check_cpu" == false && "$check_mem" == false && "$check_disk" == false ]]; then
        check_cpu=true
        check_mem=true
        check_disk=true
    fi
    
    local alerts=0
    local cpu_val=0 mem_val=0 disk_val=0
    
    # Collect metrics
    [[ "$check_cpu" == true ]] && cpu_val=$(get_cpu_usage)
    [[ "$check_mem" == true ]] && mem_val=$(get_memory_usage)
    [[ "$check_disk" == true ]] && disk_val=$(get_disk_usage)
    
    # Output
    if [[ "$output_format" == "json" ]]; then
        output_json "$cpu_val" "$mem_val" "$disk_val"
    else
        log "INFO" "=== Monitor System ==="
        
        if [[ "$check_cpu" == true ]]; then
            check_threshold "$cpu_val" "$THRESHOLD_CPU" "CPU" || ((alerts++))
        fi
        
        if [[ "$check_mem" == true ]]; then
            check_threshold "$mem_val" "$THRESHOLD_MEM" "Memory" || ((alerts++))
        fi
        
        if [[ "$check_disk" == true ]]; then
            check_threshold "$disk_val" "$THRESHOLD_DISK" "Disk" || ((alerts++))
        fi
        
        if ((alerts > 0)); then
            log "WARN" "Total alerts: $alerts"
            exit 2
        else
            log "INFO" "All checks OK"
        fi
    fi
}

main "$@"

# *By Revolvix for OPERATING SYSTEMS class | restricted licence 2017-2030*
