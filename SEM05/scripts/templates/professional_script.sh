#!/bin/bash
#
# Script:      professional_script.sh
# Description: Complete template for production Bash scripts
# Author:      ASE Bucharest - CSIE
# Version:     1.0.0
# Date:        2025-01-10
#
# Usage:       ./professional_script.sh [options] <input>
# Example:     ./professional_script.sh -v -o output.txt input.txt
#
# Notes:       This template includes all best practices for
#              robust and maintainable scripts.
#

# ============================================================
# SAFETY OPTIONS - ALWAYS FIRST THING AFTER SHEBANG
# ============================================================
# set -e: Exit immediately if a command returns non-zero
# set -u: Treat undefined variables as error
# set -o pipefail: Return error from any command in pipe
set -euo pipefail

# Safe IFS: Only newline and tab are separators
# Prevents issues with spaces in file names
IFS=$'\n\t'

# ============================================================
# CONSTANTS - readonly to prevent accidental modification
# ============================================================
readonly SCRIPT_NAME=$(basename "$0")
readonly SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
readonly SCRIPT_VERSION="1.0.0"

# Timestamp for logging and temporary files
readonly TIMESTAMP=$(date '+%Y%m%d_%H%M%S')

# ============================================================
# DEFAULT CONFIGURATION - Overridden by arguments or environment
# ============================================================
VERBOSE=${VERBOSE:-0}                    # Verbose level (0, 1, 2)
DRY_RUN=${DRY_RUN:-false}               # Simulation without modifications
LOG_FILE="${LOG_FILE:-/tmp/${SCRIPT_NAME%.*}_${TIMESTAMP}.log}"
OUTPUT="${OUTPUT:-}"                     # Output file (optional)

# ============================================================
# COLOURS FOR OUTPUT (optional, for terminals that support it)
# ============================================================
if [[ -t 1 ]]; then
    readonly RED='\033[0;31m'
    readonly GREEN='\033[0;32m'
    readonly YELLOW='\033[0;33m'
    readonly BLUE='\033[0;34m'
    readonly NC='\033[0m'  # No Colour
else
    readonly RED=''
    readonly GREEN=''
    readonly YELLOW=''
    readonly BLUE=''
    readonly NC=''
fi

# ============================================================
# LOGGING SYSTEM
# ============================================================
declare -A LOG_LEVELS=([DEBUG]=0 [INFO]=1 [WARN]=2 [ERROR]=3)
LOG_LEVEL="${LOG_LEVEL:-INFO}"

log() {
    local level=$1
    shift
    local message="$*"
    
    # Skip if below current level
    [[ ${LOG_LEVELS[$level]:-1} -lt ${LOG_LEVELS[$LOG_LEVEL]:-1} ]] && return 0
    
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local log_line="[$timestamp] [$level] $message"
    
    # Write to log file
    echo "$log_line" >> "$LOG_FILE"
    
    # On screen for levels >= WARN or if VERBOSE
    if [[ ${LOG_LEVELS[$level]:-1} -ge ${LOG_LEVELS[WARN]:-2} ]] || [[ $VERBOSE -ge 1 ]]; then
        case $level in
            DEBUG) echo -e "${BLUE}$log_line${NC}" >&2 ;;
            INFO)  echo -e "${GREEN}$log_line${NC}" >&2 ;;
            WARN)  echo -e "${YELLOW}$log_line${NC}" >&2 ;;
            ERROR) echo -e "${RED}$log_line${NC}" >&2 ;;
        esac
    fi
}

log_debug() { log DEBUG "$@"; }
log_info()  { log INFO "$@"; }
log_warn()  { log WARN "$@"; }
log_error() { log ERROR "$@"; }

# ============================================================
# HELPER FUNCTIONS
# ============================================================

# Display usage message
usage() {
    cat << EOF
${SCRIPT_NAME} v${SCRIPT_VERSION}

DESCRIPTION:
    Template for professional Bash scripts.
    Adapt this template for your needs.

USAGE:
    ${SCRIPT_NAME} [options] <input_file>

OPTIONS:
    -h, --help          Display this help message
    -V, --version       Display version
    -v, --verbose       Verbose mode (can be repeated: -vv for debug)
    -n, --dry-run       Simulation without making real changes
    -o, --output FILE   Specify output file
    -l, --log FILE      Specify log file

ENVIRONMENT VARIABLES:
    VERBOSE             Verbose level (0-2)
    DRY_RUN             Set to 'true' for dry run
    LOG_LEVEL           Logging level (DEBUG, INFO, WARN, ERROR)
    LOG_FILE            Path to log file

EXAMPLES:
    ${SCRIPT_NAME} input.txt
        Process input.txt with default settings

    ${SCRIPT_NAME} -v -o output.txt input.txt
        Process with verbose, write to output.txt

    ${SCRIPT_NAME} -vv --dry-run input.txt
        Simulation with full debug

    VERBOSE=2 ${SCRIPT_NAME} input.txt
        Alternative: set verbose from environment

EXIT CODES:
    0   Success
    1   General error
    2   Incorrect usage (invalid arguments)
    3   Input file does not exist or cannot be read
    4   Processing error

AUTHOR:
    ASE Bucharest - CSIE

EOF
}

# Display version
version() {
    echo "${SCRIPT_NAME} version ${SCRIPT_VERSION}"
}

# Terminate script with error
die() {
    log_error "$*"
    exit 1
}

# Check if a command exists
require_command() {
    local cmd="$1"
    command -v "$cmd" >/dev/null 2>&1 || die "Command '$cmd' is not installed"
}

# ============================================================
# CLEANUP - Executes ALWAYS on exit
# ============================================================
# Variables for cleanup (set in main)
TEMP_FILES=()

cleanup() {
    local exit_code=$?
    
    log_debug "Cleanup: starting (exit code: $exit_code)"
    
    # Delete temporary files
    for tmp in "${TEMP_FILES[@]:-}"; do
        if [[ -n "$tmp" && -e "$tmp" ]]; then
            rm -rf "$tmp"
            log_debug "Cleanup: removed $tmp"
        fi
    done
    
    if [[ $exit_code -eq 0 ]]; then
        log_info "Script completed successfully"
    else
        log_error "Script failed with exit code: $exit_code"
    fi
    
    exit $exit_code
}

# Set traps
trap cleanup EXIT
trap 'log_error "Interrupted by user"; exit 130' INT
trap 'log_error "Terminated"; exit 143' TERM

# ============================================================
# ARGUMENT PARSING
# ============================================================
parse_args() {
    # Positional arguments
    local positional=()
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                usage
                exit 0
                ;;
            -V|--version)
                version
                exit 0
                ;;
            -v|--verbose)
                ((VERBOSE++))
                [[ $VERBOSE -ge 2 ]] && LOG_LEVEL=DEBUG
                shift
                ;;
            -n|--dry-run)
                DRY_RUN=true
                shift
                ;;
            -o|--output)
                [[ -z "${2:-}" ]] && die "Option --output requires an argument"
                OUTPUT="$2"
                shift 2
                ;;
            --output=*)
                OUTPUT="${1#*=}"
                shift
                ;;
            -l|--log)
                [[ -z "${2:-}" ]] && die "Option --log requires an argument"
                LOG_FILE="$2"
                shift 2
                ;;
            --log=*)
                LOG_FILE="${1#*=}"
                shift
                ;;
            --)
                shift
                positional+=("$@")
                break
                ;;
            -*)
                die "Unknown option: $1. Use --help for help."
                ;;
            *)
                positional+=("$1")
                shift
                ;;
        esac
    done
    
    # Restore positional arguments
    set -- "${positional[@]}"
    
    # Check mandatory arguments
    if [[ $# -lt 1 ]]; then
        echo "Error: Missing input_file argument" >&2
        echo "Usage: ${SCRIPT_NAME} [options] <input_file>" >&2
        echo "Use --help for more information." >&2
        exit 2
    fi
    
    INPUT_FILE="$1"
}

# ============================================================
# VALIDATION
# ============================================================
validate() {
    log_debug "Validating inputs..."
    
    # Check input file
    if [[ ! -f "$INPUT_FILE" ]]; then
        die "Input file does not exist: $INPUT_FILE"
    fi
    
    if [[ ! -r "$INPUT_FILE" ]]; then
        die "Cannot read input file: $INPUT_FILE"
    fi
    
    # Check output (if specified)
    if [[ -n "$OUTPUT" ]]; then
        local output_dir
        output_dir=$(dirname "$OUTPUT")
        if [[ ! -d "$output_dir" ]]; then
            die "Output directory does not exist: $output_dir"
        fi
        if [[ ! -w "$output_dir" ]]; then
            die "Cannot write to directory: $output_dir"
        fi
        if [[ -e "$OUTPUT" && ! -w "$OUTPUT" ]]; then
            die "Output file exists and cannot be overwritten: $OUTPUT"
        fi
    fi
    
    # Check dependencies (add required commands)
    # require_command "jq"
    # require_command "curl"
    
    log_debug "Validation passed"
}

# ============================================================
# MAIN LOGIC
# ============================================================
process() {
    log_info "Starting processing: $INPUT_FILE"
    log_debug "Verbose level: $VERBOSE"
    log_debug "Dry run: $DRY_RUN"
    log_debug "Output: ${OUTPUT:-stdout}"
    
    if $DRY_RUN; then
        log_warn "DRY RUN MODE - no real changes being made"
    fi
    
    # Create temporary file for processing
    local temp_file
    temp_file=$(mktemp)
    TEMP_FILES+=("$temp_file")
    log_debug "Created temp file: $temp_file"
    
    # ========================================
    # YOUR SPECIFIC LOGIC GOES HERE
    # ========================================
    
    # Example: simple file processing
    local line_count
    line_count=$(wc -l < "$INPUT_FILE")
    log_info "Input file has $line_count lines"
    
    if ! $DRY_RUN; then
        # Real processing
        # Example: copy content with modifications
        while IFS= read -r line; do
            # Process each line
            echo "$line" >> "$temp_file"
        done < "$INPUT_FILE"
        
        # Write result
        if [[ -n "$OUTPUT" ]]; then
            cp "$temp_file" "$OUTPUT"
            log_info "Output written to: $OUTPUT"
        else
            cat "$temp_file"
        fi
    fi
    
    # ========================================
    # END SPECIFIC LOGIC
    # ========================================
    
    log_info "Processing completed"
}

# ============================================================
# MAIN - Entry point
# ============================================================
main() {
    log_info "Script started: ${SCRIPT_NAME} v${SCRIPT_VERSION}"
    log_debug "Script directory: $SCRIPT_DIR"
    log_debug "Arguments: $*"
    
    parse_args "$@"
    validate
    process
}

# Execute main with all arguments
main "$@"
