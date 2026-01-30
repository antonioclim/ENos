#!/bin/bash
#
# S03_03_validator.sh - Assignment Validator Seminar 3
# Operating Systems | Bucharest UES - CSIE
#
#
# DESCRIPTION:
#   Validates the student's assignment for Seminar 03:
#   - Checks structure and presence of files
#   - Tests scripts with arguments
#   - Verifies cron job syntax
#   - Validates set permissions
#   - Generates evaluation report
#
# USAGE:
#   ./S03_03_validator.sh [-h] [-v] [-o REPORT] <assignment_directory>
#
# OPTIONS:
#   -h          Display help
#   -v          Verbose mode (details for each test)
#   -o REPORT   Save report to file
#   -s          Strict mode (any warning becomes error)
#
# AUTHOR: OS Team UES
# VERSION: 1.0
#

set -e

# Colours
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'
BOLD='\033[1m'

# Configurations
VERBOSE=false
STRICT=false
REPORT_FILE=""
HOMEWORK_DIR=""

# Counters
TESTS_PASSED=0
TESTS_FAILED=0
TESTS_WARNED=0
TOTAL_TESTS=0
TOTAL_POINTS=0
MAX_POINTS=100

# Array for results
declare -a TEST_RESULTS

#
# UTILITY FUNCTIONS
#

usage() {
    cat << EOF
${BOLD}Assignment Validator - Seminar 3 OS${NC}

${BOLD}USAGE:${NC}
    $0 [-h] [-v] [-o REPORT] [-s] <assignment_directory>

${BOLD}OPTIONS:${NC}
    -h          Display this help
    -v          Verbose mode (details for each test)
    -o REPORT   Save report to file
    -s          Strict mode (any warning becomes error)

${BOLD}EXPECTED STRUCTURE:${NC}
    tema_sem5-6/
    ├── find_commands.sh       # Find commands (Part 1)
    ├── professional_script.sh # Script with getopts (Part 2)
    ├── permission_manager.sh  # Permissions manager (Part 3)
    ├── cron_jobs.txt          # Cron expressions (Part 4)
    └── integration.sh         # Integrated script (Part 5)

${BOLD}EXAMPLES:${NC}
    $0 ./my_assignment         # Simple validation
    $0 -v ./my_assignment      # With details
    $0 -v -o report.txt ./tema # Save report

EOF
    exit 0
}

log() {
    local level=$1
    shift
    local message="$*"
    local timestamp=$(date '+%H:%M:%S')
    
    case "$level" in
        PASS)
            echo -e "${GREEN}✓${NC} $message"
            ;;
        FAIL)
            echo -e "${RED}✗${NC} $message"
            ;;
        WARN)
            echo -e "${YELLOW}⚠${NC} $message"
            ;;
        INFO)
            if [ "$VERBOSE" = true ]; then
                echo -e "${CYAN}ℹ${NC} $message"
            fi
            ;;
        DEBUG)
            if [ "$VERBOSE" = true ]; then
                echo -e "${MAGENTA}🔍${NC} $message"
            fi
            ;;
    esac
    
    # Add to report if specified
    if [ -n "$REPORT_FILE" ]; then
        echo "[$timestamp] [$level] $message" >> "$REPORT_FILE"
    fi
}

print_header() {
    echo -e "\n${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}$1${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}\n"
}

print_section() {
    echo -e "\n${BLUE}───────────────────────────────────────────────────────────────${NC}"
    echo -e "${BOLD}$1${NC}"
    echo -e "${BLUE}───────────────────────────────────────────────────────────────${NC}\n"
}

# Function for recording test
record_test() {
    local name=$1
    local result=$2  # PASS, FAIL, WARN
    local points=$3
    local max_points=$4
    local details=$5
    
    ((TOTAL_TESTS++))
    
    case "$result" in
        PASS)
            ((TESTS_PASSED++))
            TOTAL_POINTS=$((TOTAL_POINTS + points))
            log PASS "$name (+$points pts)"
            ;;
        FAIL)
            ((TESTS_FAILED++))
            log FAIL "$name (0/$max_points pts)"
            if [ -n "$details" ]; then
                log INFO "  Details: $details"
            fi
            ;;
        WARN)
            ((TESTS_WARNED++))
            if [ "$STRICT" = true ]; then
                ((TESTS_FAILED++))
                log FAIL "$name (WARN → FAIL in strict mode)"
            else
                TOTAL_POINTS=$((TOTAL_POINTS + points))
                log WARN "$name (+$points pts, but with warning)"
            fi
            if [ -n "$details" ]; then
                log INFO "  Details: $details"
            fi
            ;;
    esac
    
    TEST_RESULTS+=("$name|$result|$points|$max_points|$details")
}

#
# STRUCTURE VALIDATIONS
#

check_structure() {
    print_section "📁 STRUCTURE VERIFICATION (5 pts)"
    
    local required_files=(
        "find_commands.sh"
        "professional_script.sh"
        "permission_manager.sh"
        "cron_jobs.txt"
    )
    
    local optional_files=(
        "integration.sh"
        "README.md"
    )
    
    local found=0
    local missing=()
    
    for file in "${required_files[@]}"; do
        if [ -f "$HOMEWORK_DIR/$file" ]; then
            ((found++))
            log DEBUG "Found: $file"
        else
            missing+=("$file")
            log DEBUG "Missing: $file"
        fi
    done
    
    if [ ${#missing[@]} -eq 0 ]; then
        record_test "All required files present" "PASS" 5 5 ""
    elif [ ${#missing[@]} -le 1 ]; then
        record_test "Files almost complete" "WARN" 3 5 "Missing: ${missing[*]}"
    else
        record_test "Files incomplete" "FAIL" 0 5 "Missing: ${missing[*]}"
    fi
    
    # Check bonus files
    for file in "${optional_files[@]}"; do
        if [ -f "$HOMEWORK_DIR/$file" ]; then
            log INFO "Bonus: $file present"
        fi
    done
}

#
# VALIDATION PART 1: FIND COMMANDS
#

validate_find_commands() {
    print_section "🔍 PART 1: FIND COMMANDS (20 pts)"
    
    local file="$HOMEWORK_DIR/find_commands.sh"
    
    if [ ! -f "$file" ]; then
        record_test "File find_commands.sh" "FAIL" 0 20 "File does not exist"
        return
    fi
    
    # Check shebang
    if head -1 "$file" | grep -q "^#!/bin/bash"; then
        record_test "Correct shebang" "PASS" 2 2 ""
    else
        record_test "Shebang" "WARN" 1 2 "Missing or incorrect: #!/bin/bash"
    fi
    
    # Check that it uses find
    local find_count=$(grep -c "^[^#]*find " "$file" 2>/dev/null || echo 0)
    if [ "$find_count" -ge 5 ]; then
        record_test "Minimum 5 find commands" "PASS" 5 5 "Found: $find_count"
    elif [ "$find_count" -ge 3 ]; then
        record_test "Find commands" "WARN" 3 5 "Only $find_count commands (minimum 5 required)"
    else
        record_test "Find commands" "FAIL" 0 5 "Only $find_count commands"
    fi
    
    # Check advanced find options
    local advanced_opts=0
    
    if grep -q "\-type" "$file" 2>/dev/null; then
        ((advanced_opts++))
        log DEBUG "Uses -type"
    fi
    
    if grep -q "\-size" "$file" 2>/dev/null; then
        ((advanced_opts++))
        log DEBUG "Uses -size"
    fi
    
    if grep -q "\-mtime\|\-mmin" "$file" 2>/dev/null; then
        ((advanced_opts++))
        log DEBUG "Uses -mtime/-mmin"
    fi
    
    if grep -q "\-exec\|xargs" "$file" 2>/dev/null; then
        ((advanced_opts++))
        log DEBUG "Uses -exec or xargs"
    fi
    
    if [ "$advanced_opts" -ge 3 ]; then
        record_test "Advanced find options" "PASS" 5 5 "$advanced_opts types used"
    elif [ "$advanced_opts" -ge 2 ]; then
        record_test "Advanced options" "WARN" 3 5 "$advanced_opts types (3+ recommended)"
    else
        record_test "Advanced options" "FAIL" 0 5 "Only $advanced_opts types"
    fi
    
    # Check xargs or -exec +
    if grep -qE "xargs|exec.*\+" "$file" 2>/dev/null; then
        record_test "Efficient processing (xargs/-exec +)" "PASS" 3 3 ""
    else
        record_test "Efficient processing" "WARN" 1 3 "Consider xargs or -exec {} +"
    fi
    
    # Check handling of spaces
    if grep -qE "print0|xargs -0" "$file" 2>/dev/null; then
        record_test "Handling files with spaces" "PASS" 5 5 ""
    else
        record_test "Handling files with spaces" "WARN" 2 5 "Add -print0 | xargs -0 for robustness"
    fi
}

#
# VALIDATION PART 2: PROFESSIONAL SCRIPT
#

validate_professional_script() {
    print_section "📜 PART 2: PROFESSIONAL SCRIPT (30 pts)"
    
    local file="$HOMEWORK_DIR/professional_script.sh"
    
    if [ ! -f "$file" ]; then
        record_test "File professional_script.sh" "FAIL" 0 30 "File does not exist"
        return
    fi
    
    # Check shebang and executability
    if head -1 "$file" | grep -q "^#!/bin/bash"; then
        record_test "Shebang" "PASS" 2 2 ""
    else
        record_test "Shebang" "FAIL" 0 2 ""
    fi
    
    # Check getopts
    if grep -q "getopts" "$file" 2>/dev/null; then
        record_test "Uses getopts" "PASS" 5 5 ""
        
        # Check required options
        local has_h=$(grep -c "\-h\|help" "$file" || echo 0)
        local has_v=$(grep -c "\-v\|verbose" "$file" || echo 0)
        local has_o=$(grep -c "\-o\|output" "$file" || echo 0)
        
        if [ "$has_h" -gt 0 ] && [ "$has_v" -gt 0 ] && [ "$has_o" -gt 0 ]; then
            record_test "Options -h, -v, -o implemented" "PASS" 5 5 ""
        else
            record_test "Incomplete options" "WARN" 3 5 "Check -h (help), -v (verbose), -o (output)"
        fi
    else
        record_test "Uses getopts" "FAIL" 0 5 "getopts is not used"
        record_test "Options" "FAIL" 0 5 ""
    fi
    
    # Check usage function
    if grep -qE "usage\(\)|show_help" "$file" 2>/dev/null; then
        record_test "usage/help function" "PASS" 3 3 ""
    else
        record_test "usage/help function" "WARN" 1 3 "Add usage() function for -h"
    fi
    
    # Check argument validation
    if grep -qE '\$#|test.*\-[ez]|\[\[.*\]\]' "$file" 2>/dev/null; then
        record_test "Argument validation" "PASS" 3 3 ""
    else
        record_test "Argument validation" "WARN" 1 3 "Add validation for number/type of arguments"
    fi
    
    # Check shift after getopts
    if grep -qE "shift.*OPTIND|OPTIND.*shift" "$file" 2>/dev/null; then
        record_test "shift after getopts (OPTIND)" "PASS" 3 3 ""
    else
        record_test "shift after getopts" "WARN" 1 3 "Add: shift \$((OPTIND-1))"
    fi
    
    # Check error handling
    if grep -qE "exit [1-9]|set -e" "$file" 2>/dev/null; then
        record_test "Error handling (exit codes)" "PASS" 2 2 ""
    else
        record_test "Error handling" "WARN" 1 2 "Add exit codes for errors"
    fi
    
    # Functional test (run script with -h)
    if [ -x "$file" ] || chmod +x "$file" 2>/dev/null; then
        if timeout 5 bash "$file" -h &>/dev/null; then
            record_test "Script runs with -h" "PASS" 5 5 ""
        else
            record_test "Functional test -h" "WARN" 2 5 "Script does not run correctly with -h"
        fi
    else
        record_test "Script executability" "FAIL" 0 5 "Cannot be made executable"
    fi
    
    # Check "$@" vs $@
    if grep -q '"\$@"' "$file" 2>/dev/null; then
        record_test 'Uses "$@" correctly (with quotes)' "PASS" 2 2 ""
    elif grep -q '\$@' "$file" 2>/dev/null; then
        record_test 'Uses $@ without quotes' "WARN" 1 2 'Change $@ to "$@"'
    fi
}

#
# VALIDATION PART 3: PERMISSION MANAGER
#

validate_permission_manager() {
    print_section "🔐 PART 3: PERMISSION MANAGER (25 pts)"
    
    local file="$HOMEWORK_DIR/permission_manager.sh"
    
    if [ ! -f "$file" ]; then
        record_test "File permission_manager.sh" "FAIL" 0 25 "File does not exist"
        return
    fi
    
    # Check that it uses chmod
    if grep -q "chmod" "$file" 2>/dev/null; then
        record_test "Uses chmod" "PASS" 3 3 ""
    else
        record_test "Uses chmod" "FAIL" 0 3 ""
    fi
    
    # Check stat or ls -l for permissions analysis
    if grep -qE "stat|ls -l" "$file" 2>/dev/null; then
        record_test "Analyses permissions (stat/ls)" "PASS" 3 3 ""
    else
        record_test "Permissions analysis" "WARN" 1 3 "Add stat or ls -l for verification"
    fi
    
    # Check that it doesn't use chmod 777
    if grep -q "chmod.*777\|chmod 777" "$file" 2>/dev/null; then
        record_test "Does NOT use chmod 777" "FAIL" 0 5 "SECURITY: chmod 777 detected!"
    else
        record_test "Avoids chmod 777" "PASS" 5 5 ""
    fi
    
    # Check find for file searching
    if grep -q "find" "$file" 2>/dev/null; then
        record_test "Uses find for searching" "PASS" 3 3 ""
    else
        record_test "Uses find" "WARN" 1 3 ""
    fi
    
    # Check that it differentiates files from directories
    if grep -qE "type [fd]|\-d|\-f" "$file" 2>/dev/null; then
        record_test "Differentiates files/directories" "PASS" 3 3 ""
    else
        record_test "File/directory differentiation" "WARN" 1 3 "Treat files differently from directories"
    fi
    
    # Check dry-run or confirmation
    if grep -qE "dry.?run|echo.*chmod|\-i|confirm|read" "$file" 2>/dev/null; then
        record_test "Dry-run or confirmation option" "PASS" 3 3 ""
    else
        record_test "Safety (dry-run)" "WARN" 1 3 "Add --dry-run option or confirmation"
    fi
    
    # Check reporting
    if grep -qE "echo|printf|report" "$file" 2>/dev/null; then
        record_test "Generates report" "PASS" 2 2 ""
    else
        record_test "Reporting" "WARN" 1 2 ""
    fi
    
    # Check special permissions (SUID/SGID detection)
    if grep -qE "4[0-7][0-7][0-7]|2[0-7][0-7][0-7]|\-perm.*[42]000|SUID|SGID" "$file" 2>/dev/null; then
        record_test "Detects special permissions" "PASS" 3 3 ""
    else
        record_test "Special permissions" "WARN" 1 3 "Consider detecting SUID/SGID"
    fi
}

#
# VALIDATION PART 4: CRON JOBS
#

validate_cron_jobs() {
    print_section "⏰ PART 4: CRON JOBS (15 pts)"
    
    local file="$HOMEWORK_DIR/cron_jobs.txt"
    
    if [ ! -f "$file" ]; then
        record_test "File cron_jobs.txt" "FAIL" 0 15 "File does not exist"
        return
    fi
    
    # Count non-comment, non-empty lines
    local cron_lines=$(grep -v "^#" "$file" | grep -v "^$" | wc -l)
    
    if [ "$cron_lines" -ge 3 ]; then
        record_test "Minimum 3 cron expressions" "PASS" 3 3 "Found: $cron_lines"
    else
        record_test "Cron expressions" "FAIL" 0 3 "Only $cron_lines expressions (minimum 3 required)"
    fi
    
    # Check cron syntax
    local valid_crons=0
    local invalid_crons=()
    
    while IFS= read -r line; do
        # Ignore comments and empty lines
        [[ "$line" =~ ^# ]] && continue
        [[ -z "${line// }" ]] && continue
        
        # Check basic format (5 fields + command)
        local fields=$(echo "$line" | awk '{print NF}')
        if [ "$fields" -ge 6 ]; then
            # Check that first 5 fields are valid
            local cron_expr=$(echo "$line" | awk '{print $1,$2,$3,$4,$5}')
            if [[ "$cron_expr" =~ ^[0-9\*\/\,\-]+[[:space:]][0-9\*\/\,\-]+[[:space:]][0-9\*\/\,\-]+[[:space:]][0-9\*\/\,\-]+[[:space:]][0-9\*\/\,\-]+$ ]]; then
                ((valid_crons++))
            elif [[ "$cron_expr" =~ ^@ ]]; then
                # Special string (@daily, @reboot, etc.)
                ((valid_crons++))
            else
                invalid_crons+=("$line")
            fi
        else
            invalid_crons+=("$line")
        fi
    done < "$file"
    
    if [ "$valid_crons" -ge 3 ]; then
        record_test "Valid cron syntax" "PASS" 5 5 "$valid_crons valid expressions"
    elif [ "$valid_crons" -ge 1 ]; then
        record_test "Cron syntax" "WARN" 2 5 "$valid_crons valid, ${#invalid_crons[@]} invalid"
    else
        record_test "Cron syntax" "FAIL" 0 5 "No valid expressions"
    fi
    
    # Check absolute paths
    if grep -vE "^#|^$" "$file" | grep -qE "^[^/]*\s+/"; then
        record_test "Uses absolute paths" "PASS" 3 3 ""
    else
        record_test "Absolute paths" "WARN" 1 3 "Recommendation: use absolute paths in cron"
    fi
    
    # Check output redirection
    if grep -qE ">>" "$file" 2>/dev/null; then
        record_test "Logging (output redirection)" "PASS" 2 2 ""
    else
        record_test "Logging" "WARN" 1 2 "Add >> log.txt 2>&1 for logging"
    fi
    
    # Check 2>&1
    if grep -q "2>&1" "$file" 2>/dev/null; then
        record_test "stderr capture (2>&1)" "PASS" 2 2 ""
    else
        record_test "stderr capture" "WARN" 1 2 "Add 2>&1 to capture errors"
    fi
}

#
# VALIDATION PART 5: INTEGRATION (BONUS)
#

validate_integration() {
    print_section "🔗 PART 5: INTEGRATION - BONUS (10 pts)"
    
    local file="$HOMEWORK_DIR/integration.sh"
    
    if [ ! -f "$file" ]; then
        log INFO "Integration script does not exist (optional)"
        return
    fi
    
    log INFO "Integration script detected - bonus verification"
    
    # Check that it combines concepts
    local concepts=0
    
    if grep -q "find" "$file" 2>/dev/null; then
        ((concepts++))
        log DEBUG "Uses find"
    fi
    
    if grep -q "getopts" "$file" 2>/dev/null; then
        ((concepts++))
        log DEBUG "Uses getopts"
    fi
    
    if grep -q "chmod\|chown" "$file" 2>/dev/null; then
        ((concepts++))
        log DEBUG "Manages permissions"
    fi
    
    if grep -qE "cron|crontab|>>.*log" "$file" 2>/dev/null; then
        ((concepts++))
        log DEBUG "Integration logging/cron"
    fi
    
    if [ "$concepts" -ge 3 ]; then
        record_test "BONUS: Complete integration script" "PASS" 10 10 "$concepts concepts integrated"
    elif [ "$concepts" -ge 2 ]; then
        record_test "BONUS: Partial integration script" "WARN" 5 10 "$concepts concepts (3+ recommended)"
    else
        record_test "BONUS: Integration script" "WARN" 2 10 "Only $concepts concepts integrated"
    fi
}

#
# ADDITIONAL BONUS CHECKS
#

check_bonuses() {
    print_section "🌟 ADDITIONAL BONUSES"
    
    local bonus_points=0
    
    # Check README
    if [ -f "$HOMEWORK_DIR/README.md" ]; then
        local readme_lines=$(wc -l < "$HOMEWORK_DIR/README.md")
        if [ "$readme_lines" -ge 20 ]; then
            log PASS "BONUS: Complete README.md (+2 pts)"
            ((bonus_points += 2))
        else
            log WARN "README.md exists but is short"
        fi
    fi
    
    # Check comments in scripts
    local total_comments=0
    for script in "$HOMEWORK_DIR"/*.sh; do
        [ -f "$script" ] || continue
        local comments=$(grep -c "^#" "$script" 2>/dev/null || echo 0)
        total_comments=$((total_comments + comments))
    done
    
    if [ "$total_comments" -ge 30 ]; then
        log PASS "BONUS: Code documentation (+2 pts)"
        ((bonus_points += 2))
    fi
    
    # Check long options
    local has_long_opts=false
    for script in "$HOMEWORK_DIR"/*.sh; do
        [ -f "$script" ] || continue
        if grep -qE "\-\-help|\-\-verbose|\-\-output" "$script" 2>/dev/null; then
            has_long_opts=true
            break
        fi
    done
    
    if [ "$has_long_opts" = true ]; then
        log PASS "BONUS: Long options support (+3 pts)"
        ((bonus_points += 3))
    fi
    
    # Check flock for lock files
    for script in "$HOMEWORK_DIR"/*.sh; do
        [ -f "$script" ] || continue
        if grep -q "flock" "$script" 2>/dev/null; then
            log PASS "BONUS: Lock file with flock (+3 pts)"
            ((bonus_points += 3))
            break
        fi
    done
    
    if [ "$bonus_points" -gt 0 ]; then
        TOTAL_POINTS=$((TOTAL_POINTS + bonus_points))
        log INFO "Total bonus points: +$bonus_points"
    else
        log INFO "No additional bonuses"
    fi
}

#
# FINAL REPORT GENERATION
#

generate_report() {
    print_header "📊 FINAL REPORT"
    
    local percentage=$((TOTAL_POINTS * 100 / MAX_POINTS))
    local grade
    
    if [ $percentage -ge 90 ]; then
        grade="10 (Excellent)"
    elif [ $percentage -ge 80 ]; then
        grade="9 (Very good)"
    elif [ $percentage -ge 70 ]; then
        grade="8 (Good)"
    elif [ $percentage -ge 60 ]; then
        grade="7 (Satisfactory)"
    elif [ $percentage -ge 50 ]; then
        grade="6 (Sufficient)"
    elif [ $percentage -ge 40 ]; then
        grade="5 (Weak)"
    else
        grade="4 (Insufficient)"
    fi
    
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC}                    ${BOLD}VALIDATION RESULTS${NC}                         ${CYAN}║${NC}"
    echo -e "${CYAN}╠═══════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}  Evaluated directory:  $HOMEWORK_DIR"
    echo -e "${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}  ${BOLD}Test statistics:${NC}"
    echo -e "${CYAN}║${NC}    Total tests:        $TOTAL_TESTS"
    echo -e "${CYAN}║${NC}    ✓ Passed:           ${GREEN}$TESTS_PASSED${NC}"
    echo -e "${CYAN}║${NC}    ✗ Failed:           ${RED}$TESTS_FAILED${NC}"
    echo -e "${CYAN}║${NC}    ⚠ Warnings:         ${YELLOW}$TESTS_WARNED${NC}"
    echo -e "${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}  ${BOLD}Score:${NC}"
    echo -e "${CYAN}║${NC}    Obtained:           ${BOLD}$TOTAL_POINTS${NC} / $MAX_POINTS"
    echo -e "${CYAN}║${NC}    Percentage:         ${BOLD}$percentage%${NC}"
    echo -e "${CYAN}║${NC}    Estimated grade:    ${BOLD}$grade${NC}"
    echo -e "${CYAN}║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    
    if [ -n "$REPORT_FILE" ]; then
        echo ""
        echo "Report saved to: $REPORT_FILE"
        
        # Add summary to report
        {
            echo ""
            echo "═══════════════════════════════════════════════════════════════"
            echo "SUMMARY"
            echo "═══════════════════════════════════════════════════════════════"
            echo "Score: $TOTAL_POINTS / $MAX_POINTS ($percentage%)"
            echo "Estimated grade: $grade"
            echo "Date: $(date)"
        } >> "$REPORT_FILE"
    fi
    
    # Suggestions for improvement
    if [ $TESTS_FAILED -gt 0 ] || [ $TESTS_WARNED -gt 0 ]; then
        echo ""
        echo -e "${YELLOW}💡 Suggestions for improvement:${NC}"
        
        if [ $TESTS_FAILED -gt 0 ]; then
            echo "  - Check failed tests and correct errors"
        fi
        
        if [ $TESTS_WARNED -gt 0 ]; then
            echo "  - Address warnings for maximum score"
        fi
        
        echo "  - Run validator with -v for details"
    fi
}

#
# MAIN
#

main() {
    # Parse arguments
    while getopts ":hvo:s" opt; do
        case $opt in
            h) usage ;;
            v) VERBOSE=true ;;
            o) REPORT_FILE="$OPTARG" ;;
            s) STRICT=true ;;
            \?) echo -e "${RED}Invalid option: -$OPTARG${NC}"; exit 1 ;;
            :) echo -e "${RED}Option -$OPTARG requires argument${NC}"; exit 1 ;;
        esac
    done
    shift $((OPTIND - 1))
    
    # Check directory argument
    if [ $# -lt 1 ]; then
        echo -e "${RED}Error: Specify the assignment directory${NC}"
        echo "Usage: $0 [-v] [-o report.txt] <assignment_directory>"
        exit 1
    fi
    
    HOMEWORK_DIR="$1"
    
    if [ ! -d "$HOMEWORK_DIR" ]; then
        echo -e "${RED}Error: Directory '$HOMEWORK_DIR' does not exist${NC}"
        exit 1
    fi
    
    # Convert to absolute path
    HOMEWORK_DIR=$(cd "$HOMEWORK_DIR" && pwd)
    
    # Initialise report
    if [ -n "$REPORT_FILE" ]; then
        echo "Validation report - $(date)" > "$REPORT_FILE"
        echo "Directory: $HOMEWORK_DIR" >> "$REPORT_FILE"
        echo "═══════════════════════════════════════════════════════════════" >> "$REPORT_FILE"
    fi
    
    # Header
    echo ""
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC}     ${BOLD}ASSIGNMENT VALIDATOR - SEMINAR 5-6 OS${NC}                     ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}     Bucharest UES - CSIE                                      ${CYAN}║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    
    # Run validations
    check_structure
    validate_find_commands
    validate_professional_script
    validate_permission_manager
    validate_cron_jobs
    validate_integration
    check_bonuses
    
    # Generate report
    generate_report
    
    # Exit code based on result
    if [ $TESTS_FAILED -eq 0 ]; then
        exit 0
    else
        exit 1
    fi
}

main "$@"
