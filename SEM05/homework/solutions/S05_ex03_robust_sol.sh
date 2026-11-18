#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════════
# S05_ex03_robust_sol.sh — Solution Exercise 3: Defensive Scripting
# ═══════════════════════════════════════════════════════════════════════════════
# Operating Systems | ASE Bucharest - CSIE
# Seminar 05: Advanced Bash Scripting
#
# REQUIREMENT:
#   Demonstrate defensive scripting with:
#   - set -euo pipefail
#   - trap for cleanup
#   - Error handling
#   - Logging
#
# USAGE:
#   ./S05_ex03_robust_sol.sh [--simulate-error]
# ═══════════════════════════════════════════════════════════════════════════════

# ─────────────────────────────────────────────────────────────────────────────
# DEFENSIVE SETUP
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail
IFS=$'\n\t'

readonly SCRIPT_NAME=$(basename "$0")
readonly SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
readonly TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Temporary file for demonstration
TMPFILE=""

# ─────────────────────────────────────────────────────────────────────────────
# LOGGING
# ─────────────────────────────────────────────────────────────────────────────
log_info() {
    echo "[INFO]  $(date '+%H:%M:%S') $*"
}

log_warn() {
    echo "[WARN]  $(date '+%H:%M:%S') $*" >&2
}

log_error() {
    echo "[ERROR] $(date '+%H:%M:%S') $*" >&2
}

# ─────────────────────────────────────────────────────────────────────────────
# CLEANUP (executes ALWAYS on exit)
# ─────────────────────────────────────────────────────────────────────────────
cleanup() {
    local exit_code=$?
    
    log_info "Cleanup: starting cleanup..."
    
    # Delete temporary file if it exists
    if [[ -n "${TMPFILE:-}" && -f "$TMPFILE" ]]; then
        log_info "Cleanup: deleting $TMPFILE"
        rm -f "$TMPFILE"
    fi
    
    if [[ $exit_code -eq 0 ]]; then
        log_info "Cleanup: script completed successfully"
    else
        log_warn "Cleanup: script terminated with error (exit code: $exit_code)"
    fi
    
    exit "$exit_code"
}

# Register trap for EXIT (executes on any exit)
trap cleanup EXIT

# Trap for Ctrl+C (INT) - exit code 130 is convention for SIGINT
trap 'log_warn "Interrupted by user (Ctrl+C)"; exit 130' INT

# Trap for TERM (default kill)
trap 'log_warn "Received TERM signal"; exit 143' TERM

# ─────────────────────────────────────────────────────────────────────────────
# UTILITY FUNCTIONS
# ─────────────────────────────────────────────────────────────────────────────
die() {
    log_error "$*"
    exit 1
}

check_dependencies() {
    local cmd
    for cmd in "$@"; do
        if ! command -v "$cmd" &>/dev/null; then
            die "Missing dependency: $cmd"
        fi
    done
}

create_temp_file() {
    TMPFILE=$(mktemp "/tmp/${SCRIPT_NAME}.XXXXXX")
    log_info "Created temporary file: $TMPFILE"
}

# ─────────────────────────────────────────────────────────────────────────────
# MAIN PROCESSING
# ─────────────────────────────────────────────────────────────────────────────
process_data() {
    log_info "Processing: started"
    
    # Write data to temporary file
    echo "Important data: $TIMESTAMP" > "$TMPFILE"
    echo "Script: $SCRIPT_NAME" >> "$TMPFILE"
    echo "PID: $$" >> "$TMPFILE"
    
    log_info "Processing: data written to $TMPFILE"
    
    # Read and display
    log_info "Temporary file contents:"
    while IFS= read -r line; do
        echo "   | $line"
    done < "$TMPFILE"
    
    log_info "Processing: completed"
}

simulate_error() {
    log_warn "Error simulation activated!"
    log_info "The next command will fail..."
    
    # This will trigger set -e
    false
    
    # This line never executes
    log_info "This message does not appear"
}

# ─────────────────────────────────────────────────────────────────────────────
# MAIN
# ─────────────────────────────────────────────────────────────────────────────
main() {
    log_info "═══════════════════════════════════════════════════════════════"
    log_info "  Defensive Script - Demonstration"
    log_info "═══════════════════════════════════════════════════════════════"
    
    # Check dependencies
    check_dependencies mktemp cat
    
    # Create temporary file
    create_temp_file
    
    # Process data
    process_data
    
    # Check if we need to simulate error
    if [[ "${1:-}" == "--simulate-error" ]]; then
        simulate_error
    fi
    
    log_info "═══════════════════════════════════════════════════════════════"
    log_info "  Script completed normally"
    log_info "═══════════════════════════════════════════════════════════════"
}

# Run main
main "$@"
