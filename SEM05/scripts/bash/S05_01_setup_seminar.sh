#!/bin/bash
#
# S05_01_setup_seminar.sh - Setup Environment for Advanced Bash Seminar
# 
# Operating Systems | ASE Bucharest - CSIE
# Seminar 5: Advanced Bash Scripting
#
# PURPOSE: Prepares the working environment for the seminar:
#          - Creates the directory structure
#          - Copies templates and demo scripts
#          - Verifies dependencies
#          - Generates test files
#
# USAGE:
#   ./S05_01_setup_seminar.sh              # Complete setup
#   ./S05_01_setup_seminar.sh --check      # Check only
#   ./S05_01_setup_seminar.sh --clean      # Clean and redo
#

set -euo pipefail
IFS=$'\n\t'

# ============================================================
# CONSTANTS
# ============================================================
readonly SCRIPT_NAME=$(basename "$0")
readonly SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
readonly SCRIPT_VERSION="1.0.0"

# Working directory for the seminar
WORK_DIR="${WORK_DIR:-$HOME/seminar_bash}"
readonly SEMINAR_NAME="S05_Advanced_Bash"

# Colours
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly BOLD='\033[1m'
readonly NC='\033[0m'

# ============================================================
# HELPER FUNCTIONS
# ============================================================

log_info() {
    echo -e "${GREEN}[INFO]${NC} $*"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $*" >&2
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $*" >&2
}

log_step() {
    echo -e "\n${BOLD}${BLUE}▶ $*${NC}"
}

die() {
    log_error "$*"
    exit 1
}

check_command() {
    local cmd=$1
    local required=${2:-false}
    
    if command -v "$cmd" &>/dev/null; then
        echo -e "  ${GREEN}✓${NC} $cmd: $(command -v "$cmd")"
        return 0
    else
        if [[ "$required" == "true" ]]; then
            echo -e "  ${RED}✗${NC} $cmd: NOT FOUND (REQUIRED)"
            return 1
        else
            echo -e "  ${YELLOW}○${NC} $cmd: not found (optional)"
            return 0
        fi
    fi
}

usage() {
    cat << EOF
${BOLD}$SCRIPT_NAME v$SCRIPT_VERSION${NC}

Prepares the working environment for the Advanced Bash Scripting Seminar.

${BOLD}USAGE:${NC}
    $SCRIPT_NAME [options]

${BOLD}OPTIONS:${NC}
    -h, --help          Display this message
    -c, --check         Only check dependencies (no setup)
    -C, --clean         Delete and recreate the working directory
    -d, --dir PATH      Specify the working directory (default: ~/seminar_bash)
    -v, --verbose       Verbose mode

${BOLD}EXAMPLES:${NC}
    $SCRIPT_NAME                      # Standard setup
    $SCRIPT_NAME --check              # Check only
    $SCRIPT_NAME --dir /tmp/seminar   # Custom directory
    $SCRIPT_NAME --clean              # Complete reset

${BOLD}CREATED STRUCTURE:${NC}
    $WORK_DIR/
    ├── exercises/         # Exercises for students
    ├── solutions/         # Solutions (instructor)
    ├── templates/         # Starter templates
    ├── test_files/        # Files for testing
    └── submissions/       # Directory for assignments

EOF
}

# ============================================================
# CHECK DEPENDENCIES
# ============================================================

check_dependencies() {
    log_step "Checking Dependencies"
    
    local errors=0
    
    echo "Bash version: ${BASH_VERSION}"
    
    # Required
    check_command bash true || ((errors++))
    check_command cat true || ((errors++))
    check_command grep true || ((errors++))
    check_command sed true || ((errors++))
    check_command awk true || ((errors++))
    
    # Optional but recommended
    check_command shellcheck false
    check_command tree false
    check_command jq false
    check_command python3 false
    check_command curl false
    
    echo ""
    if [[ $errors -gt 0 ]]; then
        log_error "$errors required dependencies missing!"
        return 1
    else
        log_info "All required dependencies found."
        return 0
    fi
}

# ============================================================
# CREATE DIRECTORY STRUCTURE
# ============================================================

create_structure() {
    log_step "Creating Directory Structure"
    
    local dirs=(
        "exercises/ex01_functions"
        "exercises/ex02_arrays"
        "exercises/ex03_robust"
        "exercises/ex04_template"
        "solutions"
        "templates"
        "test_files"
        "submissions"
        "logs"
    )
    
    for dir in "${dirs[@]}"; do
        mkdir -p "$WORK_DIR/$dir"
        echo -e "  ${GREEN}✓${NC} Created: $dir"
    done
}

# ============================================================
# CREATE TEMPLATE FILES
# ============================================================

create_templates() {
    log_step "Creating Templates"
    
    # Simple template
    cat > "$WORK_DIR/templates/simple_template.sh" << 'TEMPLATE'
#!/bin/bash
#
# Script: [NAME]
# Description: [DESCRIPTION]
# Author: [STUDENT NAME]
# Date: [DATE]
#

set -euo pipefail

# === Variables ===

# === Functions ===

# === Main ===
main() {
    echo "Hello, World!"
}

main "$@"
TEMPLATE

    # Professional template
    cat > "$WORK_DIR/templates/professional_template.sh" << 'TEMPLATE'
#!/bin/bash
#
# Script: [NAME]
# Description: [DESCRIPTION]
# Author: [STUDENT NAME]
# Version: 1.0.0
# Date: [DATE]
#

set -euo pipefail
IFS=$'\n\t'

# ============================================================
# CONSTANTS
# ============================================================
readonly SCRIPT_NAME=$(basename "$0")
readonly SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
readonly VERSION="1.0.0"

# ============================================================
# CONFIGURATION
# ============================================================
VERBOSE="${VERBOSE:-0}"
DEBUG="${DEBUG:-false}"
LOG_FILE="${LOG_FILE:-/tmp/${SCRIPT_NAME%.*}.log}"

# ============================================================
# HELPER FUNCTIONS
# ============================================================
usage() {
    cat << EOF
$SCRIPT_NAME v$VERSION

DESCRIPTION:
    [Script description]

USAGE:
    $SCRIPT_NAME [options] <arguments>

OPTIONS:
    -h, --help      Display this message
    -v, --verbose   Verbose mode
    -V, --version   Display version

EXAMPLES:
    $SCRIPT_NAME input.txt
    $SCRIPT_NAME -v --output result.txt input.txt

EOF
}

log() {
    local level=$1
    shift
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$level] $*" | tee -a "$LOG_FILE"
}

die() {
    log ERROR "$*"
    exit 1
}

debug() {
    [[ "$DEBUG" == "true" ]] && log DEBUG "$@"
    return 0
}

# ============================================================
# CLEANUP
# ============================================================
cleanup() {
    local exit_code=$?
    debug "Cleanup triggered with exit code: $exit_code"
    # Add cleanup code here
    exit $exit_code
}

trap cleanup EXIT
trap 'log WARN "Interrupted"; exit 130' INT TERM

# ============================================================
# ARGUMENT PARSING
# ============================================================
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                usage
                exit 0
                ;;
            -v|--verbose)
                ((VERBOSE++))
                shift
                ;;
            -V|--version)
                echo "$SCRIPT_NAME v$VERSION"
                exit 0
                ;;
            --)
                shift
                break
                ;;
            -*)
                die "Unknown option: $1"
                ;;
            *)
                break
                ;;
        esac
    done
    
    # Validate required arguments
    # [[ $# -ge 1 ]] || die "Missing required argument"
}

# ============================================================
# MAIN
# ============================================================
main() {
    parse_args "$@"
    
    log INFO "Script starting..."
    
    # Your code here
    echo "Hello, World!"
    
    log INFO "Script completed successfully"
}

main "$@"
TEMPLATE

    chmod +x "$WORK_DIR/templates/"*.sh
    echo -e "  ${GREEN}✓${NC} Created: simple_template.sh"
    echo -e "  ${GREEN}✓${NC} Created: professional_template.sh"
}

# ============================================================
# CREATE TEST FILES
# ============================================================

create_test_files() {
    log_step "Creating Test Files"
    
    # Text file with various content
    cat > "$WORK_DIR/test_files/sample.txt" << 'EOF'
The quick brown fox jumps over the lazy dog.
Pack my box with five dozen liquor jugs.
How vexingly quick daft zebras jump!
The five boxing wizards jump quickly.
Sphinx of black quartz, judge my vow.
EOF
    echo -e "  ${GREEN}✓${NC} Created: sample.txt"
    
    # CSV file
    cat > "$WORK_DIR/test_files/data.csv" << 'EOF'
name,age,city,score
Alice,25,Bucharest,95
Bob,30,Cluj,88
Charlie,22,Iași,92
Diana,28,Timișoara,97
Eve,35,Constanța,85
EOF
    echo -e "  ${GREEN}✓${NC} Created: data.csv"
    
    # Config file
    cat > "$WORK_DIR/test_files/app.conf" << 'EOF'
# Application Configuration
HOST=localhost
PORT=8080
DEBUG=false
LOG_LEVEL=INFO

# Database
DB_HOST=db.example.com
DB_PORT=5432
DB_NAME=production

# Features
FEATURE_A=enabled
FEATURE_B=disabled
EOF
    echo -e "  ${GREEN}✓${NC} Created: app.conf"
    
    # JSON file
    cat > "$WORK_DIR/test_files/users.json" << 'EOF'
{
  "users": [
    {"id": 1, "name": "Alice", "role": "admin"},
    {"id": 2, "name": "Bob", "role": "user"},
    {"id": 3, "name": "Charlie", "role": "user"}
  ],
  "total": 3
}
EOF
    echo -e "  ${GREEN}✓${NC} Created: users.json"
    
    # Log file for parsing exercises
    cat > "$WORK_DIR/test_files/sample.log" << 'EOF'
[2025-01-15 10:00:00] [INFO] Application started
[2025-01-15 10:00:01] [DEBUG] Loading configuration
[2025-01-15 10:00:02] [INFO] Connected to database
[2025-01-15 10:00:05] [WARN] Slow query detected (2.3s)
[2025-01-15 10:00:10] [ERROR] Failed to send email: timeout
[2025-01-15 10:00:15] [INFO] User login: alice@example.com
[2025-01-15 10:00:20] [INFO] User login: bob@example.com
[2025-01-15 10:01:00] [WARN] High memory usage: 85%
[2025-01-15 10:02:00] [ERROR] Database connection lost
[2025-01-15 10:02:05] [INFO] Reconnected to database
EOF
    echo -e "  ${GREEN}✓${NC} Created: sample.log"
    
    # Files with spaces in names (for testing)
    mkdir -p "$WORK_DIR/test_files/tricky"
    echo "Content 1" > "$WORK_DIR/test_files/tricky/file with spaces.txt"
    echo "Content 2" > "$WORK_DIR/test_files/tricky/another file.txt"
    echo -e "  ${GREEN}✓${NC} Created: files with spaces (for testing)"
    
    # Empty file
    touch "$WORK_DIR/test_files/empty.txt"
    echo -e "  ${GREEN}✓${NC} Created: empty.txt"
    
    # Binary-like file (for testing file type detection)
    echo -e "\x00\x01\x02\x03" > "$WORK_DIR/test_files/binary.dat"
    echo -e "  ${GREEN}✓${NC} Created: binary.dat"
}

# ============================================================
# CREATE EXERCISE STARTERS
# ============================================================

create_exercises() {
    log_step "Creating Exercise Starters"
    
    # Exercise 1: Functions
    cat > "$WORK_DIR/exercises/ex01_functions/start.sh" << 'EXERCISE'
#!/bin/bash
# Exercise 1: Functions
#
# REQUIREMENTS:
# 1. Create a function 'validate_email' that checks if a string
#    looks like a valid email (contains @ and .)
# 2. Create a function 'count_words' that returns the number of words
#    in a file (use echo to "return")
# 3. Remember: Use 'local' for all variables in functions!
#
# HINT: 
#   - For email: [[ "$email" =~ @ ]] && [[ "$email" =~ \. ]]
#   - For word count: wc -w < "$file"

set -euo pipefail

# TODO: Implement validate_email
validate_email() {
    local email="$1"
    # Complete here
    return 1
}

# TODO: Implement count_words
count_words() {
    local file="$1"
    # Complete here
    echo 0
}

# Test
main() {
    echo "=== Test validate_email ==="
    if validate_email "test@example.com"; then
        echo "✓ test@example.com is valid"
    else
        echo "✗ test@example.com should be valid"
    fi
    
    if validate_email "invalid-email"; then
        echo "✗ invalid-email should not be valid"
    else
        echo "✓ invalid-email correctly rejected"
    fi
    
    echo ""
    echo "=== Test count_words ==="
    echo "one two three four five" > /tmp/test_words.txt
    local count
    count=$(count_words /tmp/test_words.txt)
    if [[ "$count" == "5" ]]; then
        echo "✓ count_words: $count (correct)"
    else
        echo "✗ count_words: $count (expected: 5)"
    fi
    rm -f /tmp/test_words.txt
}

main
EXERCISE
    
    # Exercise 2: Arrays
    cat > "$WORK_DIR/exercises/ex02_arrays/start.sh" << 'EXERCISE'
#!/bin/bash
# Exercise 2: Arrays
#
# REQUIREMENTS:
# 1. Create an INDEXED array with 5 fruits
# 2. Create an ASSOCIATIVE array for configuration (host, port, user)
# 3. Iterate through each array and display the elements
# 4. Remember: Use quotes in for loops!
#
# HINT:
#   - Indexed array: arr=("a" "b" "c")
#   - Associative array: declare -A hash; hash[key]="value"
#   - Iteration: for item in "${arr[@]}"; do

set -euo pipefail

# TODO: Create the fruits array
# fruits=(...)

# TODO: Create the associative configuration array
# declare -A config
# config[host]=...

main() {
    echo "=== Fruits ==="
    # TODO: Iterate and display the fruits
    # for fruit in "${fruits[@]}"; do
    #     echo "- $fruit"
    # done
    
    echo ""
    echo "=== Configuration ==="
    # TODO: Iterate and display config (key=value)
    # for key in "${!config[@]}"; do
    #     echo "$key = ${config[$key]}"
    # done
}

main
EXERCISE

    # Exercise 3: Robust Script
    cat > "$WORK_DIR/exercises/ex03_robust/start.sh" << 'EXERCISE'
#!/bin/bash
# Exercise 3: Robust Script
#
# REQUIREMENTS:
# 1. Add set -euo pipefail
# 2. Implement the cleanup() function with trap EXIT
# 3. Add validation for the required argument (input file)
# 4. Verify that the file exists and can be read
#
# RUN: ./start.sh <file>

# TODO: Add strict mode
# set -euo pipefail

TEMP_FILE=""

# TODO: Implement cleanup
cleanup() {
    # Delete the temporary file if it exists
    :
}

# TODO: Set trap
# trap cleanup EXIT

# TODO: Implement validate
validate() {
    # Check that we have an argument
    # Check that the file exists
    # Check that the file can be read
    :
}

main() {
    validate "$@"
    
    local input="$1"
    TEMP_FILE=$(mktemp)
    
    echo "Processing: $input"
    echo "Temp file: $TEMP_FILE"
    
    # Simulate processing
    cat "$input" > "$TEMP_FILE"
    wc -l "$TEMP_FILE"
    
    echo "Done!"
}

main "$@"
EXERCISE

    chmod +x "$WORK_DIR/exercises/"*/*.sh
    
    echo -e "  ${GREEN}✓${NC} Created: ex01_functions/start.sh"
    echo -e "  ${GREEN}✓${NC} Created: ex02_arrays/start.sh"
    echo -e "  ${GREEN}✓${NC} Created: ex03_robust/start.sh"
}

# ============================================================
# PRINT SUMMARY
# ============================================================

print_summary() {
    log_step "Setup Complete!"
    
    echo ""
    echo -e "${BOLD}Structure created in: ${GREEN}$WORK_DIR${NC}"
    echo ""
    
    if command -v tree &>/dev/null; then
        tree -L 2 "$WORK_DIR"
    else
        find "$WORK_DIR" -maxdepth 2 -type d | head -20
    fi
    
    echo ""
    echo -e "${BOLD}Next steps:${NC}"
    echo "  1. cd $WORK_DIR"
    echo "  2. Start with exercises/ex01_functions/start.sh"
    echo "  3. Use templates/ as a starting point"
    echo ""
    echo -e "${BOLD}Useful commands:${NC}"
    echo "  shellcheck script.sh     # Check script"
    echo "  bash -x script.sh        # Debug mode"
    echo ""
}

# ============================================================
# MAIN
# ============================================================

main() {
    local check_only=false
    local clean=false
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                usage
                exit 0
                ;;
            -c|--check)
                check_only=true
                shift
                ;;
            -C|--clean)
                clean=true
                shift
                ;;
            -d|--dir)
                WORK_DIR="$2"
                shift 2
                ;;
            *)
                die "Unknown option: $1. Use --help for usage."
                ;;
        esac
    done
    
    echo -e "${BOLD}${BLUE}"
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║     Setup Seminar: Advanced Bash Scripting                  ║"
    echo "║     ASE Bucharest - CSIE                                    ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    # Check dependencies
    if ! check_dependencies; then
        die "Please install missing dependencies first."
    fi
    
    if [[ "$check_only" == "true" ]]; then
        log_info "Check-only mode. Exiting."
        exit 0
    fi
    
    # Clean if requested
    if [[ "$clean" == "true" && -d "$WORK_DIR" ]]; then
        log_warn "Removing existing directory: $WORK_DIR"
        rm -rf "$WORK_DIR"
    fi
    
    # Check if directory exists
    if [[ -d "$WORK_DIR" ]]; then
        log_warn "Directory already exists: $WORK_DIR"
        read -r -p "Overwrite? [y/N] " response
        if [[ ! "$response" =~ ^[Yy]$ ]]; then
            log_info "Aborting."
            exit 0
        fi
    fi
    
    # Run setup
    create_structure
    create_templates
    create_test_files
    create_exercises
    print_summary
}

main "$@"
