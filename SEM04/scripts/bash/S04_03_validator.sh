#!/bin/bash
#===============================================================================
#
#          FILE: S04_03_validator.sh
#
#         USAGE: ./S04_03_validator.sh <exercise_id> "<student_command>"
#
#   DESCRIPTION: Validates student solutions for seminar exercises
#                Compares student command output against expected output
#
#       OPTIONS: --list     Show available exercises
#                --help     Display help
#
#        AUTHOR: Assistant Lecturer - OS Seminar
#       VERSION: 1.1
#
#===============================================================================

set -euo pipefail

#-------------------------------------------------------------------------------
# CONFIGURATION
#-------------------------------------------------------------------------------

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly DATA_DIR="$HOME/demo_sem4/data"

# Colours
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m'

#-------------------------------------------------------------------------------
# EXERCISE DEFINITIONS
#-------------------------------------------------------------------------------

# Format: id|description|expected_output_generator|hints

declare -A EXERCISES

# GREP exercises
EXERCISES[G1]="Find lines with status code 404 in access.log|grep ' 404 ' \"\$DATA_DIR/access.log\"|Use pattern ' 404 ' with surrounding spaces"
EXERCISES[G2]="Count POST requests in access.log|grep -c 'POST' \"\$DATA_DIR/access.log\"|Use grep -c for line counting"
EXERCISES[G3]="Extract unique IP addresses from access.log|grep -oE '^[0-9.]+' \"\$DATA_DIR/access.log\" | sort -u|Combine grep -o with sort -u"
EXERCISES[G4]="Find lines accessing /admin in access.log|grep '/admin' \"\$DATA_DIR/access.log\"|Simple pattern: /admin"
EXERCISES[G5]="Extract valid emails from emails.txt|grep -E '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$' \"\$DATA_DIR/emails.txt\"|Regex for email with anchors"

# SED exercises
EXERCISES[S1]="Replace localhost with 127.0.0.1 in config.txt|sed 's/localhost/127.0.0.1/g' \"\$DATA_DIR/config.txt\"|s/old/new/g for all occurrences"
EXERCISES[S2]="Delete comments from config.txt|sed '/^#/d' \"\$DATA_DIR/config.txt\"|Pattern /^#/d"
EXERCISES[S3]="Delete empty lines from config.txt|sed '/^$/d' \"\$DATA_DIR/config.txt\"|Pattern /^$/d"
EXERCISES[S4]="Delete comments AND empty lines|sed '/^#/d; /^$/d' \"\$DATA_DIR/config.txt\"|Combine: /^#/d; /^$/d"

# AWK exercises
EXERCISES[A1]="Display the Name column from employees.csv|awk -F',' '{print \$2}' \"\$DATA_DIR/employees.csv\"|awk -F',' for CSV"
EXERCISES[A2]="Display employees from IT department|awk -F',' '\$3 == \"IT\"' \"\$DATA_DIR/employees.csv\"|Condition on field"
EXERCISES[A3]="Calculate salary sum (skip header)|awk -F',' 'NR > 1 {sum += \$4} END {print sum}' \"\$DATA_DIR/employees.csv\"|NR > 1 to skip header"
EXERCISES[A4]="Count employees per department|awk -F',' 'NR > 1 {count[\$3]++} END {for (d in count) print d, count[d]}' \"\$DATA_DIR/employees.csv\"|Associative array for counting"

#-------------------------------------------------------------------------------
# FUNCTIONS
#-------------------------------------------------------------------------------

show_help() {
    cat << 'EOF'
╔══════════════════════════════════════════════════════════════════════════╗
║                    EXERCISE VALIDATOR - TEXT PROCESSING                  ║
╚══════════════════════════════════════════════════════════════════════════╝

USAGE:
    ./S04_03_validator.sh <exercise_id> "<student_command>"
    ./S04_03_validator.sh --list

OPTIONS:
    --list      Show all available exercises
    --help      Display this message

EXAMPLES:
    ./S04_03_validator.sh G1 "grep ' 404 ' access.log"
    ./S04_03_validator.sh A3 "awk -F',' 'NR>1{s+=\$4}END{print s}' employees.csv"
    ./S04_03_validator.sh --list

AVAILABLE EXERCISES:
    G1-G5: GREP Exercises
    S1-S4: SED Exercises
    A1-A4: AWK Exercises

EOF
}

list_exercises() {
    echo ""
    echo "╔══════════════════════════════════════════════════════════════════════════╗"
    echo "║                         AVAILABLE EXERCISES                              ║"
    echo "╚══════════════════════════════════════════════════════════════════════════╝"
    echo ""
    
    echo -e "${CYAN}=== GREP Exercises ===${NC}"
    for id in G1 G2 G3 G4 G5; do
        if [[ -n "${EXERCISES[$id]:-}" ]]; then
            local desc
            desc=$(echo "${EXERCISES[$id]}" | cut -d'|' -f1)
            echo -e "  ${YELLOW}$id${NC}: $desc"
        fi
    done
    
    echo ""
    echo -e "${CYAN}=== SED Exercises ===${NC}"
    for id in S1 S2 S3 S4; do
        if [[ -n "${EXERCISES[$id]:-}" ]]; then
            local desc
            desc=$(echo "${EXERCISES[$id]}" | cut -d'|' -f1)
            echo -e "  ${YELLOW}$id${NC}: $desc"
        fi
    done
    
    echo ""
    echo -e "${CYAN}=== AWK Exercises ===${NC}"
    for id in A1 A2 A3 A4; do
        if [[ -n "${EXERCISES[$id]:-}" ]]; then
            local desc
            desc=$(echo "${EXERCISES[$id]}" | cut -d'|' -f1)
            echo -e "  ${YELLOW}$id${NC}: $desc"
        fi
    done
    
    echo ""
}

validate_exercise() {
    local ex_id="$1"
    local student_cmd="$2"
    
    # Check whether exercise exists
    if [[ -z "${EXERCISES[$ex_id]:-}" ]]; then
        echo -e "${RED}[ERROR] Exercise '$ex_id' not found!${NC}"
        echo "Use --list to see available exercises."
        exit 1
    fi
    
    # Parse exercise data
    local ex_data="${EXERCISES[$ex_id]}"
    local description hint
    description=$(echo "$ex_data" | cut -d'|' -f1)
    local expected_cmd
    expected_cmd=$(echo "$ex_data" | cut -d'|' -f2)
    hint=$(echo "$ex_data" | cut -d'|' -f3)
    
    echo ""
    echo "╔══════════════════════════════════════════════════════════════════════════╗"
    echo "║                         EXERCISE VALIDATION                              ║"
    echo "╚══════════════════════════════════════════════════════════════════════════╝"
    echo ""
    echo -e "${CYAN}Exercise:${NC} $ex_id"
    echo -e "${CYAN}Task:${NC} $description"
    echo -e "${CYAN}Your command:${NC} $student_cmd"
    echo ""
    
    # Verify that data exists
    if [[ ! -d "$DATA_DIR" ]]; then
        echo -e "${RED}[ERROR] Data directory not found: $DATA_DIR${NC}"
        echo "Run first: ./S04_01_setup_seminar.sh"
        exit 1
    fi
    
    # Generate expected output
    local expected_output student_output
    cd "$DATA_DIR" || exit 1
    
    # Evaluate expected command
    expected_output=$(eval "$expected_cmd" 2>/dev/null || echo "[COMMAND_ERROR]")
    
    # Evaluate student command (with timeout for safety)
    student_output=$(timeout 10 bash -c "$student_cmd" 2>/dev/null || echo "[COMMAND_ERROR]")
    
    # Comparison
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    
    if [[ "$student_output" == "[COMMAND_ERROR]" ]]; then
        echo -e "${RED}✗ ERROR: Your command produced an error or took too long${NC}"
        echo ""
        echo -e "${YELLOW}Hint: $hint${NC}"
        return 1
    fi
    
    # Flexible comparison (ignores whitespace and order for some cases)
    local expected_sorted student_sorted
    expected_sorted=$(echo "$expected_output" | sort | tr -s ' ' | sed 's/^ //;s/ $//')
    student_sorted=$(echo "$student_output" | sort | tr -s ' ' | sed 's/^ //;s/ $//')
    
    if [[ "$expected_output" == "$student_output" ]]; then
        echo -e "${GREEN}✓ PERFECT! Output is identical to expected.${NC}"
        return 0
    elif [[ "$expected_sorted" == "$student_sorted" ]]; then
        echo -e "${GREEN}✓ CORRECT! Output is equivalent (different order/whitespace).${NC}"
        return 0
    else
        echo -e "${RED}✗ INCORRECT: Output differs from expected.${NC}"
        echo ""
        echo -e "${CYAN}Expected output (first 10 lines):${NC}"
        echo "$expected_output" | head -10
        echo ""
        echo -e "${CYAN}Your output (first 10 lines):${NC}"
        echo "$student_output" | head -10
        echo ""
        echo -e "${YELLOW}Hint: $hint${NC}"
        return 1
    fi
}

#-------------------------------------------------------------------------------
# MAIN
#-------------------------------------------------------------------------------

main() {
    # No arguments
    if [[ $# -eq 0 ]]; then
        show_help
        exit 0
    fi
    
    # Parse arguments
    case "$1" in
        --list|-l)
            list_exercises
            exit 0
            ;;
        --help|-h)
            show_help
            exit 0
            ;;
        *)
            if [[ $# -lt 2 ]]; then
                echo -e "${RED}[ERROR] Missing command to validate!${NC}"
                echo "Usage: $0 <exercise_id> \"<student_command>\""
                exit 1
            fi
            validate_exercise "$1" "$2"
            ;;
    esac
}

main "$@"
