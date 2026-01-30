#!/bin/bash
#
# S02_03_validator.sh - Homework Validator Seminar 2
# Operating Systems | ASE Bucharest - CSIE
#
#
# DESCRIPTION: Validates student homework by checking structure, syntax
#              and functionality of scripts.
#
# USAGE: ./S02_03_validator.sh <homework_directory_path>
#
# OUTPUT: Detailed report with scores and improvement suggestions
#
#

# Configuration
VERSION="1.0"
REQUIRED_FILES=(
    "ex1_operators.sh"
    "ex2_redirection.sh"
    "ex3_filters.sh"
    "ex4_loops.sh"
    "ex5_integrated.sh"
)

# Scores
declare -A SCORES
TOTAL_SCORE=0
MAX_SCORE=100

# Colours
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;36m'
NC='\033[0m'

#
# UTILITY FUNCTIONS
#

log_pass() {
    echo -e "${GREEN}[✓ PASS]${NC} $1"
}

log_fail() {
    echo -e "${RED}[✗ FAIL]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[⚠ WARN]${NC} $1"
}

log_info() {
    echo -e "${BLUE}[ℹ INFO]${NC} $1"
}

add_score() {
    local category="$1"
    local points="$2"
    local reason="$3"
    
    if [[ -z "${SCORES[$category]}" ]]; then
        SCORES[$category]=0
    fi
    
    SCORES[$category]=$((SCORES[$category] + points))
    TOTAL_SCORE=$((TOTAL_SCORE + points))
    
    if [[ $points -gt 0 ]]; then
        log_pass "+$points points: $reason"
    fi
}

subtract_score() {
    local points="$1"
    local reason="$2"
    
    TOTAL_SCORE=$((TOTAL_SCORE - points))
    log_fail "-$points points: $reason"
}

#
# CHECKS
#

check_directory_structure() {
    echo ""
    echo -e "${BLUE}═══ DIRECTORY STRUCTURE CHECK ═══${NC}"
    echo ""
    
    local found=0
    local missing=0
    
    for file in "${REQUIRED_FILES[@]}"; do
        if [[ -f "$HOMEWORK_DIR/$file" ]]; then
            log_pass "File found: $file"
            ((found++))
        else
            log_fail "File missing: $file"
            ((missing++))
        fi
    done
    
    # Score for structure (max 10 points)
    local structure_score=$((found * 2))
    add_score "structure" $structure_score "Files present: $found/${#REQUIRED_FILES[@]}"
    
    return $missing
}

check_script_syntax() {
    local script="$1"
    local name=$(basename "$script")
    
    if [[ ! -f "$script" ]]; then
        return 1
    fi
    
    # Check shebang
    local first_line=$(head -n1 "$script")
    if [[ "$first_line" =~ ^#!.*bash ]]; then
        log_pass "$name: Correct shebang"
        add_score "syntax" 1 "Shebang for $name"
    else
        log_warn "$name: Missing shebang (#!/bin/bash)"
    fi
    
    # Check bash syntax
    if bash -n "$script" 2>/dev/null; then
        log_pass "$name: Valid syntax"
        add_score "syntax" 2 "Correct syntax for $name"
    else
        log_fail "$name: Syntax errors detected"
        bash -n "$script" 2>&1 | head -3
    fi
    
    # Check execute permissions
    if [[ -x "$script" ]]; then
        log_pass "$name: Execute permissions set"
        add_score "syntax" 1 "chmod +x for $name"
    else
        log_warn "$name: Missing execute permissions (chmod +x)"
    fi
}

check_all_syntax() {
    echo ""
    echo -e "${BLUE}═══ SCRIPT SYNTAX CHECK ═══${NC}"
    echo ""
    
    for file in "${REQUIRED_FILES[@]}"; do
        if [[ -f "$HOMEWORK_DIR/$file" ]]; then
            check_script_syntax "$HOMEWORK_DIR/$file"
            echo ""
        fi
    done
}

check_operators_exercise() {
    local script="$HOMEWORK_DIR/ex1_operators.sh"
    
    echo ""
    echo -e "${BLUE}═══ EX1 CHECK: OPERATORS ═══${NC}"
    echo ""
    
    if [[ ! -f "$script" ]]; then
        log_fail "File ex1_operators.sh does not exist"
        return 1
    fi
    
    local content=$(cat "$script")
    
    # Check operator usage
    if grep -q '&&' "$script"; then
        log_pass "Uses && operator"
        add_score "ex1" 3 "Operator && used"
    else
        log_warn "Does not use && operator"
    fi
    
    if grep -q '||' "$script"; then
        log_pass "Uses || operator"
        add_score "ex1" 3 "Operator || used"
    else
        log_warn "Does not use || operator"
    fi
    
    if grep -qE '\s&\s*$|\s&\s' "$script"; then
        log_pass "Uses & operator (background)"
        add_score "ex1" 2 "Operator & used"
    fi
    
    # Test execution
    if timeout 5 bash "$script" &>/dev/null; then
        log_pass "Script executes without errors"
        add_score "ex1" 2 "Successful execution"
    else
        log_fail "Error during execution or timeout"
    fi
}

check_redirect_exercise() {
    local script="$HOMEWORK_DIR/ex2_redirection.sh"
    
    echo ""
    echo -e "${BLUE}═══ EX2 CHECK: REDIRECTION ═══${NC}"
    echo ""
    
    if [[ ! -f "$script" ]]; then
        log_fail "File ex2_redirection.sh does not exist"
        return 1
    fi
    
    # Check redirection usage
    if grep -qE '>\s' "$script"; then
        log_pass "Uses output redirection (>)"
        add_score "ex2" 2 "Redirect > used"
    fi
    
    if grep -q '>>' "$script"; then
        log_pass "Uses append (>>)"
        add_score "ex2" 2 "Append >> used"
    fi
    
    if grep -qE '2>' "$script"; then
        log_pass "Uses stderr redirection (2>)"
        add_score "ex2" 3 "Redirect 2> used"
    fi
    
    if grep -q '2>&1' "$script"; then
        log_pass "Uses stdout/stderr combination (2>&1)"
        add_score "ex2" 3 "2>&1 used"
    fi
    
    if grep -qE '<<\s*\w+' "$script"; then
        log_pass "Uses here document (<<)"
        add_score "ex2" 2 "Here document used"
    fi
}

check_filters_exercise() {
    local script="$HOMEWORK_DIR/ex3_filters.sh"
    
    echo ""
    echo -e "${BLUE}═══ EX3 CHECK: FILTERS ═══${NC}"
    echo ""
    
    if [[ ! -f "$script" ]]; then
        log_fail "File ex3_filters.sh does not exist"
        return 1
    fi
    
    # Check filter usage
    local filters_used=0
    
    if grep -q '\bsort\b' "$script"; then
        log_pass "Uses sort"
        add_score "ex3" 2 "sort used"
        ((filters_used++))
    fi
    
    if grep -q '\buniq\b' "$script"; then
        log_pass "Uses uniq"
        # Check if preceded by sort
        if grep -qE 'sort.*\|.*uniq' "$script"; then
            log_pass "uniq preceded by sort (correct!)"
            add_score "ex3" 3 "sort | uniq correct"
        else
            log_warn "uniq without sort before - possibly incorrect"
            add_score "ex3" 1 "uniq used (possibly incorrect)"
        fi
        ((filters_used++))
    fi
    
    if grep -q '\bcut\b' "$script"; then
        log_pass "Uses cut"
        add_score "ex3" 2 "cut used"
        ((filters_used++))
    fi
    
    if grep -q '\btr\b' "$script"; then
        log_pass "Uses tr"
        add_score "ex3" 2 "tr used"
        ((filters_used++))
    fi
    
    if grep -q '\bawk\b' "$script"; then
        log_pass "Uses awk (advanced)"
        add_score "ex3" 2 "awk used"
        ((filters_used++))
    fi
    
    # Check pipeline
    if grep -qE '\|.*\|' "$script"; then
        log_pass "Uses pipeline with multiple commands"
        add_score "ex3" 3 "Complex pipeline"
    fi
    
    log_info "Total filters used: $filters_used"
}

check_loops_exercise() {
    local script="$HOMEWORK_DIR/ex4_loops.sh"
    
    echo ""
    echo -e "${BLUE}═══ EX4 CHECK: LOOPS ═══${NC}"
    echo ""
    
    if [[ ! -f "$script" ]]; then
        log_fail "File ex4_loops.sh does not exist"
        return 1
    fi
    
    # Check loop usage
    if grep -qE '\bfor\b.*\bin\b' "$script"; then
        log_pass "Uses for loop"
        add_score "ex4" 3 "for loop used"
    fi
    
    if grep -qE '\bwhile\b' "$script"; then
        log_pass "Uses while loop"
        add_score "ex4" 3 "while loop used"
    fi
    
    # Check common pitfalls
    if grep -qE '\{1\.\.\$' "$script"; then
        log_fail "Pitfall: Uses {1..\$N} - does not work with variables!"
        subtract_score 2 "Bug: brace expansion with variable"
    fi
    
    if grep -qE 'cat.*\|.*while.*read' "$script"; then
        log_warn "Uses 'cat | while read' - variables will not persist"
    fi
    
    # Check correct file reading
    if grep -qE 'while.*read.*<\s*\w' "$script"; then
        log_pass "Correct file reading (redirect, not pipe)"
        add_score "ex4" 3 "while read < file correct"
    fi
}

check_integrated_exercise() {
    local script="$HOMEWORK_DIR/ex5_integrated.sh"
    
    echo ""
    echo -e "${BLUE}═══ EX5 CHECK: INTEGRATED PROJECT ═══${NC}"
    echo ""
    
    if [[ ! -f "$script" ]]; then
        log_fail "File ex5_integrated.sh does not exist"
        return 1
    fi
    
    local content=$(cat "$script")
    local score=0
    
    # Check complexity
    local lines=$(wc -l < "$script")
    if [[ $lines -ge 30 ]]; then
        log_pass "Substantial script ($lines lines)"
        add_score "ex5" 3 "Adequate length"
    else
        log_warn "Short script ($lines lines) - may be too simple"
    fi
    
    # Check functions
    if grep -qE '^\s*\w+\s*\(\)\s*\{' "$script"; then
        log_pass "Uses functions"
        add_score "ex5" 3 "Functions defined"
    fi
    
    # Check error handling
    if grep -qE 'if\s*\[\[?\s*-[defrzs]' "$script"; then
        log_pass "Checks file/directory existence"
        add_score "ex5" 2 "Existence checks"
    fi
    
    # Check arguments
    if grep -qE '\$[1-9]|\$\{[1-9]\}|\$#' "$script"; then
        log_pass "Processes arguments"
        add_score "ex5" 2 "Argument processing"
    fi
    
    # Test execution
    if timeout 10 bash "$script" --help &>/dev/null 2>&1 || timeout 10 bash "$script" -h &>/dev/null 2>&1; then
        log_pass "Supports --help/-h"
        add_score "ex5" 2 "Help implemented"
    fi
}

check_code_style() {
    echo ""
    echo -e "${BLUE}═══ CODE STYLE CHECK ═══${NC}"
    echo ""
    
    local style_issues=0
    
    for file in "${REQUIRED_FILES[@]}"; do
        local script="$HOMEWORK_DIR/$file"
        [[ ! -f "$script" ]] && continue
        
        # Check comments
        if grep -qE '^#[^!]' "$script"; then
            log_pass "$file: Has comments"
        else
            log_warn "$file: Missing comments"
            ((style_issues++))
        fi
        
        # Check quoted variables
        if grep -qE '\$\w+[^"]' "$script" | grep -qvE '\$\(|for.*in' &>/dev/null; then
            log_warn "$file: Possible unquoted variables"
        fi
    done
    
    if [[ $style_issues -eq 0 ]]; then
        add_score "style" 5 "Good code style"
    fi
}

#
# GENERATE REPORT
#

generate_report() {
    local report_file="$HOMEWORK_DIR/VALIDATION_REPORT.txt"
    
    echo ""
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${YELLOW}                    FINAL VALIDATION REPORT${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
    
    # Calculate final score
    [[ $TOTAL_SCORE -lt 0 ]] && TOTAL_SCORE=0
    [[ $TOTAL_SCORE -gt $MAX_SCORE ]] && TOTAL_SCORE=$MAX_SCORE
    
    local percentage=$((TOTAL_SCORE * 100 / MAX_SCORE))
    local grade=""
    
    if [[ $percentage -ge 90 ]]; then
        grade="EXCELLENT (A)"
    elif [[ $percentage -ge 80 ]]; then
        grade="VERY GOOD (B)"
    elif [[ $percentage -ge 70 ]]; then
        grade="GOOD (C)"
    elif [[ $percentage -ge 60 ]]; then
        grade="SATISFACTORY (D)"
    elif [[ $percentage -ge 50 ]]; then
        grade="SUFFICIENT (E)"
    else
        grade="INSUFFICIENT (F)"
    fi
    
    echo -e "  ${GREEN}Total Score: $TOTAL_SCORE / $MAX_SCORE ($percentage%)${NC}"
    echo -e "  ${YELLOW}Grade: $grade${NC}"
    echo ""
    
    echo -e "${BLUE}Category breakdown:${NC}"
    for category in "${!SCORES[@]}"; do
        printf "  %-15s: %d points\n" "$category" "${SCORES[$category]}"
    done
    
    echo ""
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    
    # Save report
    {
        echo "═══════════════════════════════════════════════════════════════"
        echo "HOMEWORK VALIDATION REPORT SEMINAR 3-4"
        echo "Date: $(date '+%Y-%m-%d %H:%M:%S')"
        echo "Directory: $HOMEWORK_DIR"
        echo "═══════════════════════════════════════════════════════════════"
        echo ""
        echo "TOTAL SCORE: $TOTAL_SCORE / $MAX_SCORE ($percentage%)"
        echo "GRADE: $grade"
        echo ""
        echo "DETAILS:"
        for category in "${!SCORES[@]}"; do
            printf "  %-15s: %d points\n" "$category" "${SCORES[$category]}"
        done
        echo ""
        echo "═══════════════════════════════════════════════════════════════"
    } > "$report_file"
    
    log_info "Report saved to: $report_file"
}

#
# MAIN
#

usage() {
    echo "Usage: $0 <homework_directory_path>"
    echo ""
    echo "Example: $0 ~/homework_seminar2"
    echo ""
    echo "Validates homework for Seminar 3-4 and generates report."
}

main() {
    if [[ $# -lt 1 ]]; then
        usage
        exit 1
    fi
    
    HOMEWORK_DIR="$1"
    
    if [[ ! -d "$HOMEWORK_DIR" ]]; then
        echo -e "${RED}Error: Directory '$HOMEWORK_DIR' does not exist${NC}"
        exit 1
    fi
    
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${YELLOW}       HOMEWORK VALIDATOR SEMINAR 3-4 v$VERSION${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "Validating directory: ${YELLOW}$HOMEWORK_DIR${NC}"
    
    # Run checks
    check_directory_structure
    check_all_syntax
    check_operators_exercise
    check_redirect_exercise
    check_filters_exercise
    check_loops_exercise
    check_integrated_exercise
    check_code_style
    
    # Generate report
    generate_report
}

main "$@"
