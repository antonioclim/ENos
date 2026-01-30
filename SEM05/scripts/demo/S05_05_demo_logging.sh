#!/bin/bash
#
# S05_05_demo_logging.sh - Demonstration Logging Systems
# 
# Operating Systems | ASE Bucharest - CSIE
# Seminar 5: Advanced Bash Scripting
#
# PURPOSE: Demonstrates implementing a professional logging system
#          with levels (DEBUG, INFO, WARN, ERROR, FATAL), dual output,
#          and best practices for production scripts.
#
# USAGE:
#   ./S05_05_demo_logging.sh              # All demos
#   ./S05_05_demo_logging.sh simple       # Simple logging
#   ./S05_05_demo_logging.sh levels       # With levels
#   ./S05_05_demo_logging.sh advanced     # Complete system
#   LOG_LEVEL=DEBUG ./S05_05_demo_logging.sh  # With specific level
#

set -euo pipefail
IFS=$'\n\t'

# ============================================================
# CONSTANTS AND COLOURS
# ============================================================
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly MAGENTA='\033[0;35m'
readonly BOLD='\033[1m'
readonly DIM='\033[2m'
readonly NC='\033[0m'

# Temporary directory for demo
DEMO_LOG_DIR="/tmp/logging_demo_$$"
mkdir -p "$DEMO_LOG_DIR"

# Cleanup on exit
cleanup_demo() {
    rm -rf "$DEMO_LOG_DIR" 2>/dev/null || true
}
trap cleanup_demo EXIT

# ============================================================
# HELPER FUNCTIONS
# ============================================================

header() {
    echo ""
    echo -e "${BOLD}${BLUE}════════════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}${BLUE}  $1${NC}"
    echo -e "${BOLD}${BLUE}════════════════════════════════════════════════════════════${NC}"
    echo ""
}

subheader() {
    echo ""
    echo -e "${CYAN}▶ $1${NC}"
    echo -e "${CYAN}────────────────────────────────────────${NC}"
}

code() {
    echo -e "${YELLOW}$1${NC}"
}

info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

pause() {
    echo ""
    read -r -p "Press Enter to continue..." </dev/tty 2>/dev/null || true
    echo ""
}

show_file() {
    local file="$1"
    echo -e "${DIM}─── Contents of $file ───${NC}"
    cat "$file"
    echo -e "${DIM}─── End ───${NC}"
}

# ============================================================
# DEMO 1: SIMPLE LOGGING
# ============================================================

demo_simple_logging() {
    header "SIMPLE LOGGING - For Small Scripts"
    
    local LOG_FILE="$DEMO_LOG_DIR/simple.log"
    
    subheader "Minimalist Variant"
    
    code 'log() {
    echo "[$(date "+%H:%M:%S")] $*"
}'
    
    # Implementation
    simple_log() {
        echo "[$(date '+%H:%M:%S')] $*"
    }
    
    echo ""
    echo "Demonstration:"
    simple_log "Script started"
    simple_log "Processing data..."
    simple_log "Completed"
    
    pause
    
    subheader "With File Saving"
    
    code 'LOG_FILE="/tmp/script.log"

log() {
    echo "[$(date "+%Y-%m-%d %H:%M:%S")] $*" | tee -a "$LOG_FILE"
}'
    
    # Implementation
    file_log() {
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
    }
    
    echo ""
    echo "Demonstration (also saves to $LOG_FILE):"
    file_log "Operation 1: initialisation"
    file_log "Operation 2: processing"
    file_log "Operation 3: completion"
    
    echo ""
    show_file "$LOG_FILE"
    
    pause
    
    subheader "With Separate Error Function"
    
    code 'log() {
    echo "[$(date "+%H:%M:%S")] $*" | tee -a "$LOG_FILE"
}

err() {
    echo "[$(date "+%H:%M:%S")] ERROR: $*" | tee -a "$LOG_FILE" >&2
}'
    
    # Implementation
    err_log() {
        echo "[$(date '+%H:%M:%S')] ERROR: $*" | tee -a "$LOG_FILE" >&2
    }
    
    echo ""
    echo "Demonstration:"
    file_log "Normal processing"
    err_log "Cannot access file X"
    file_log "Continuing with another file"
    
    echo ""
    show_file "$LOG_FILE"
}

# ============================================================
# DEMO 2: LOGGING WITH LEVELS
# ============================================================

demo_levels_logging() {
    header "LOGGING WITH LEVELS - DEBUG, INFO, WARN, ERROR"
    
    local LOG_FILE="$DEMO_LOG_DIR/levels.log"
    > "$LOG_FILE"  # Reset file
    
    subheader "The Concept of Log Levels"
    
    echo "Standard logging levels (in increasing order of severity):"
    echo ""
    echo -e "  ${DIM}DEBUG${NC}   - Detailed information for debugging"
    echo -e "  ${GREEN}INFO${NC}    - Normal operations, progress"
    echo -e "  ${YELLOW}WARN${NC}    - Unusual situations, but not errors"
    echo -e "  ${RED}ERROR${NC}   - Errors that allow continuation"
    echo -e "  ${BOLD}${RED}FATAL${NC}   - Critical errors, script stops"
    echo ""
    
    info "LOG_LEVEL controls which messages appear"
    echo "  LOG_LEVEL=WARN → only WARN, ERROR, FATAL appear"
    echo "  LOG_LEVEL=DEBUG → all messages appear"
    
    pause
    
    subheader "Implementation with Associative Array"
    
    code 'declare -A LOG_LEVELS=([DEBUG]=0 [INFO]=1 [WARN]=2 [ERROR]=3 [FATAL]=4)
LOG_LEVEL="${LOG_LEVEL:-INFO}"

log() {
    local level=$1; shift
    local message="$*"
    
    # Check if should be logged
    [ "${LOG_LEVELS[$level]:-0}" -lt "${LOG_LEVELS[$LOG_LEVEL]:-1}" ] && return
    
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    echo "[$timestamp] [$level] $message" | tee -a "$LOG_FILE"
}'
    
    # Actual implementation
    declare -A DEMO_LOG_LEVELS=([DEBUG]=0 [INFO]=1 [WARN]=2 [ERROR]=3 [FATAL]=4)
    DEMO_LOG_LEVEL="${LOG_LEVEL:-INFO}"
    
    demo_log() {
        local level=$1
        shift
        local message="$*"
        
        local level_num="${DEMO_LOG_LEVELS[$level]:-0}"
        local threshold="${DEMO_LOG_LEVELS[$DEMO_LOG_LEVEL]:-1}"
        
        [ "$level_num" -lt "$threshold" ] && return 0
        
        local timestamp
        timestamp=$(date '+%Y-%m-%d %H:%M:%S')
        
        # Colours for terminal
        local color=""
        case "$level" in
            DEBUG) color="${DIM}" ;;
            INFO)  color="${GREEN}" ;;
            WARN)  color="${YELLOW}" ;;
            ERROR) color="${RED}" ;;
            FATAL) color="${BOLD}${RED}" ;;
        esac
        
        # Display with colours
        echo -e "${color}[$timestamp] [$level] $message${NC}"
        
        # Save to file (without colours)
        echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
    }
    
    log_debug() { demo_log DEBUG "$@"; }
    log_info()  { demo_log INFO "$@"; }
    log_warn()  { demo_log WARN "$@"; }
    log_error() { demo_log ERROR "$@"; }
    
    echo ""
    echo "Demonstration with LOG_LEVEL=$DEMO_LOG_LEVEL:"
    echo ""
    
    log_debug "Variables initialised: x=5, y=10"
    log_info "Script started"
    log_info "Processing file: data.txt"
    log_warn "File is large (>100MB), may take a while"
    log_error "Cannot access: /etc/shadow"
    log_info "Script finished"
    
    echo ""
    info "DEBUG does not appear because LOG_LEVEL=$DEMO_LOG_LEVEL"
    
    pause
    
    echo "Now with LOG_LEVEL=DEBUG:"
    DEMO_LOG_LEVEL="DEBUG"
    > "$LOG_FILE"
    
    log_debug "Variables initialised: x=5, y=10"
    log_info "Script started"
    log_debug "Checking file permissions..."
    log_info "Processing file: data.txt"
    log_debug "File size: 150MB"
    log_warn "File is large, may take a while"
    
    echo ""
    show_file "$LOG_FILE"
}

# ============================================================
# DEMO 3: ADVANCED LOGGING SYSTEM
# ============================================================

demo_advanced_logging() {
    header "ADVANCED SYSTEM - Production Logging"
    
    local LOG_FILE="$DEMO_LOG_DIR/advanced.log"
    > "$LOG_FILE"
    
    subheader "Complete System with Context"
    
    code '# Format: [TIMESTAMP] [LEVEL] [SCRIPT:LINE] Message
log() {
    local level=$1; shift
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    local caller_info="${BASH_SOURCE[1]##*/}:${BASH_LINENO[0]}"
    
    local log_line="[$timestamp] [$level] [$caller_info] $*"
    
    echo "$log_line" | tee -a "$LOG_FILE"
}'
    
    # Actual implementation
    adv_log() {
        local level=$1
        shift
        local timestamp
        timestamp=$(date '+%Y-%m-%d %H:%M:%S')
        local caller_info="${BASH_SOURCE[1]##*/}:${BASH_LINENO[0]}"
        
        local log_line="[$timestamp] [$level] [$caller_info] $*"
        
        # Save to file
        echo "$log_line" >> "$LOG_FILE"
        
        # Colours for terminal
        local color=""
        case "$level" in
            DEBUG) color="${DIM}" ;;
            INFO)  color="${GREEN}" ;;
            WARN)  color="${YELLOW}" ;;
            ERROR) color="${RED}" ;;
            FATAL) color="${BOLD}${RED}" ;;
        esac
        
        echo -e "${color}$log_line${NC}"
    }
    
    process_file() {
        local file="$1"
        adv_log INFO "Processing: $file"
        adv_log DEBUG "Checking permissions..."
        if [[ ! -f "$file" ]]; then
            adv_log WARN "File not found, skipping: $file"
            return 1
        fi
        adv_log INFO "Done processing: $file"
    }
    
    echo ""
    echo "Demonstration (notice [SCRIPT:LINE] in output):"
    echo ""
    
    adv_log INFO "Application starting"
    adv_log DEBUG "Initializing modules..."
    process_file "/etc/passwd"
    process_file "/nonexistent/file.txt"
    adv_log INFO "Application finished"
    
    echo ""
    show_file "$LOG_FILE"
    
    pause
    
    subheader "Structured Logging (JSON)"
    
    code 'log_json() {
    local level=$1; shift
    local message=$1; shift
    local timestamp=$(date -Iseconds)
    
    # Extra fields as JSON
    local extra=""
    while [[ $# -gt 0 ]]; do
        extra+=", \"${1%%=*}\": \"${1#*=}\""
        shift
    done
    
    echo "{\"time\": \"$timestamp\", \"level\": \"$level\", \"msg\": \"$message\"$extra}"
}'
    
    json_log() {
        local level=$1
        shift
        local message=$1
        shift
        local timestamp
        timestamp=$(date -Iseconds)
        
        local extra=""
        while [[ $# -gt 0 ]]; do
            extra+=", \"${1%%=*}\": \"${1#*=}\""
            shift
        done
        
        echo -e "${DIM}{\"time\": \"$timestamp\", \"level\": \"$level\", \"msg\": \"$message\"$extra}${NC}"
    }
    
    echo ""
    echo "Demonstration JSON logging:"
    json_log INFO "User logged in" "user=admin" "ip=192.168.1.100"
    json_log WARN "High memory usage" "used_mb=7500" "total_mb=8000"
    json_log ERROR "Database connection failed" "host=db.local" "retry=3"
    
    info "JSON logs are easy to parse with jq, import into Elasticsearch, etc."
    
    pause
    
    subheader "Automatic Log Rotation"
    
    code 'rotate_log() {
    local log_file=$1
    local max_size=${2:-10485760}  # 10MB default
    local keep=${3:-5}
    
    [[ ! -f "$log_file" ]] && return
    
    local size=$(stat -f%z "$log_file" 2>/dev/null || stat -c%s "$log_file")
    
    if [[ $size -gt $max_size ]]; then
        for ((i=keep-1; i>=1; i--)); do
            [[ -f "${log_file}.$i" ]] && mv "${log_file}.$i" "${log_file}.$((i+1))"
        done
        mv "$log_file" "${log_file}.1"
        > "$log_file"
        echo "Log rotated: $log_file"
    fi
}'
    
    info "In production, use logrotate for automatic rotation"
}

# ============================================================
# DEMO 4: BEST PRACTICES
# ============================================================

demo_best_practices() {
    header "BEST PRACTICES FOR LOGGING"
    
    subheader "1. Recommended Structure"
    
    code '# At the beginning of the script
readonly SCRIPT_NAME=$(basename "$0")
readonly LOG_FILE="${LOG_FILE:-/var/log/${SCRIPT_NAME%.*}.log}"
readonly LOG_LEVEL="${LOG_LEVEL:-INFO}"

# Logging functions defined after constants
log_info()  { log INFO "$@"; }
log_error() { log ERROR "$@"; }
# etc.'
    
    pause
    
    subheader "2. What to Log"
    
    echo -e "${GREEN}✓ DO:${NC}"
    echo "  • Start/stop script"
    echo "  • Important operations (files processed, results)"
    echo "  • Errors and exceptions"
    echo "  • Duration of long operations"
    echo "  • Input/output for debugging"
    echo ""
    
    echo -e "${RED}✗ DON'T:${NC}"
    echo "  • Passwords or tokens"
    echo "  • Personal data (PII)"
    echo "  • Each iteration of a large loop"
    echo "  • Vague messages: 'Error occurred'"
    
    pause
    
    subheader "3. Common Patterns"
    
    code '# Log operation duration
log_info "Starting backup..."
start_time=$(date +%s)
do_backup
end_time=$(date +%s)
log_info "Backup completed in $((end_time - start_time)) seconds"

# Log with context
log_info "Processing file" file="$filename" size="$size"

# Log error with stack trace
log_error "Operation failed" function="${FUNCNAME[1]}" line="${BASH_LINENO[0]}"'
    
    pause
    
    subheader "4. Real-Life Examples"
    
    echo "Backup script logging:"
    echo ""
    
    simulate_backup() {
        local src="$1"
        local dst="$2"
        
        echo -e "${GREEN}[$(date '+%H:%M:%S')] [INFO] Starting backup: $src -> $dst${NC}"
        echo -e "${DIM}[$(date '+%H:%M:%S')] [DEBUG] Checking source exists...${NC}"
        echo -e "${DIM}[$(date '+%H:%M:%S')] [DEBUG] Source size: 1.2GB${NC}"
        echo -e "${GREEN}[$(date '+%H:%M:%S')] [INFO] Copying files...${NC}"
        sleep 1
        echo -e "${YELLOW}[$(date '+%H:%M:%S')] [WARN] Slow disk I/O detected${NC}"
        sleep 1
        echo -e "${GREEN}[$(date '+%H:%M:%S')] [INFO] Backup completed in 2 seconds${NC}"
        echo -e "${GREEN}[$(date '+%H:%M:%S')] [INFO] Files copied: 1,234, Size: 1.2GB${NC}"
    }
    
    simulate_backup "/home/user" "/backup/user"
}

# ============================================================
# DEMO 5: TEMPLATE INTEGRATION
# ============================================================

demo_template_integration() {
    header "PROFESSIONAL TEMPLATE INTEGRATION"
    
    code '#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# ============ CONSTANTS ============
readonly SCRIPT_NAME=$(basename "$0")
readonly LOG_FILE="${LOG_FILE:-/tmp/${SCRIPT_NAME%.*}.log}"

# ============ LOGGING ============
declare -A LOG_LEVELS=([DEBUG]=0 [INFO]=1 [WARN]=2 [ERROR]=3 [FATAL]=4)
LOG_LEVEL="${LOG_LEVEL:-INFO}"

log() {
    local level=$1; shift
    [[ ${LOG_LEVELS[$level]} -lt ${LOG_LEVELS[$LOG_LEVEL]} ]] && return
    
    local ts=$(date "+%Y-%m-%d %H:%M:%S")
    local line="[$ts] [$level] [$SCRIPT_NAME] $*"
    
    echo "$line" >> "$LOG_FILE"
    [[ ${LOG_LEVELS[$level]} -ge ${LOG_LEVELS[WARN]} ]] && echo "$line" >&2 || echo "$line"
}

log_debug() { log DEBUG "$@"; }
log_info()  { log INFO "$@"; }
log_warn()  { log WARN "$@"; }
log_error() { log ERROR "$@"; }
log_fatal() { log FATAL "$@"; exit 1; }

# ============ CLEANUP ============
cleanup() {
    local exit_code=$?
    log_debug "Cleanup triggered with exit code: $exit_code"
    # cleanup operations...
    exit $exit_code
}
trap cleanup EXIT

# ============ MAIN ============
main() {
    log_info "Script starting..."
    # your code here
    log_info "Script completed successfully"
}

main "$@"'
    
    info "This pattern is included in the professional template in the kit!"
}

# ============================================================
# MAIN
# ============================================================

main() {
    case "${1:-all}" in
        simple)
            demo_simple_logging
            ;;
        levels)
            demo_levels_logging
            ;;
        advanced)
            demo_advanced_logging
            ;;
        practices)
            demo_best_practices
            ;;
        template)
            demo_template_integration
            ;;
        all)
            demo_simple_logging
            pause
            demo_levels_logging
            pause
            demo_advanced_logging
            pause
            demo_best_practices
            pause
            demo_template_integration
            ;;
        *)
            echo "Usage: $0 [simple|levels|advanced|practices|template|all]"
            echo ""
            echo "Environment:"
            echo "  LOG_LEVEL=DEBUG|INFO|WARN|ERROR|FATAL"
            exit 1
            ;;
    esac
    
    echo ""
    echo -e "${BOLD}${GREEN}═══ Logging Demo Completed! ═══${NC}"
}

main "$@"
