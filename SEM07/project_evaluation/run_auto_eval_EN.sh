#!/bin/bash
#===============================================================================
# run_auto_eval_EN.sh - Automated Project Evaluation Orchestrator
#===============================================================================
# Operating Systems | ASE Bucharest - CSIE
# Runs automated tests and generates evaluation report
#===============================================================================

set -euo pipefail

#-------------------------------------------------------------------------------
# Configuration
#-------------------------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_NAME=$(basename "$0")
VERSION="1.0.0"

# Colours
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Scoring weights
WEIGHT_FUNCTIONAL=4.00
WEIGHT_CODE_QUALITY=1.50
WEIGHT_DOCUMENTATION=1.50
WEIGHT_STRUCTURE=0.75
WEIGHT_ERROR_HANDLING=0.75
# Total automatic: 8.50 / 10.00

# Timeouts
TEST_TIMEOUT=60
TOTAL_TIMEOUT=300

#-------------------------------------------------------------------------------
# Logging Functions
#-------------------------------------------------------------------------------

log_info() { echo -e "${BLUE}[INFO]${NC} $*"; }
log_success() { echo -e "${GREEN}[PASS]${NC} $*"; }
log_warning() { echo -e "${YELLOW}[WARN]${NC} $*"; }
log_error() { echo -e "${RED}[FAIL]${NC} $*"; }
log_section() { echo -e "\n${CYAN}═══ $* ═══${NC}\n"; }

#-------------------------------------------------------------------------------
# Banner
#-------------------------------------------------------------------------------

print_banner() {
    echo -e "${CYAN}"
    cat << 'EOF'
╔═══════════════════════════════════════════════════════════════════════════╗
║                 AUTOMATED PROJECT EVALUATION SYSTEM                       ║
║                     Operating Systems - ASE CSIE                          ║
╚═══════════════════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

#-------------------------------------------------------------------------------
# Usage
#-------------------------------------------------------------------------------

usage() {
    cat << EOF
Usage: ${SCRIPT_NAME} [OPTIONS] <project_directory>

Runs automated evaluation on a student project.

OPTIONS:
    -h, --help          Show this help message
    -v, --version       Show version
    -o, --output DIR    Output directory for results
    -l, --level LEVEL   Project level (EASY|MEDIUM|ADVANCED)
    -t, --timeout SEC   Test timeout in seconds (default: 60)
    --docker            Run tests in Docker container
    --no-cleanup        Don't clean up temporary files
    --verbose           Verbose output

EXAMPLES:
    ${SCRIPT_NAME} /path/to/student/project/
    ${SCRIPT_NAME} -l MEDIUM -o ./results/ /project/
    ${SCRIPT_NAME} --docker /project/

EOF
    exit 0
}

#-------------------------------------------------------------------------------
# Prerequisite Checks
#-------------------------------------------------------------------------------

check_prerequisites() {
    log_section "Checking Prerequisites"
    
    local missing=()
    
    # Required tools
    for tool in bash shellcheck python3 git; do
        if ! command -v "$tool" &> /dev/null; then
            missing+=("$tool")
        else
            log_success "$tool found: $(command -v $tool)"
        fi
    done
    
    # Python packages
    if ! python3 -c "import yaml" 2>/dev/null; then
        log_warning "Python yaml module not found (optional)"
    fi
    
    if [[ ${#missing[@]} -gt 0 ]]; then
        log_error "Missing required tools: ${missing[*]}"
        exit 1
    fi
}

#-------------------------------------------------------------------------------
# Project Structure Validation
#-------------------------------------------------------------------------------

check_structure() {
    local project_dir="$1"
    local score=0
    local max_score=$WEIGHT_STRUCTURE
    
    log_section "Checking Project Structure"
    
    # Required files
    local required_files=("README.md")
    local optional_files=("Makefile" "requirements.txt" "setup.sh" "config.sh")
    
    for file in "${required_files[@]}"; do
        if [[ -f "$project_dir/$file" ]]; then
            log_success "Required: $file found"
            score=$(echo "$score + 0.25" | bc)
        else
            log_error "Required: $file MISSING"
        fi
    done
    
    # Main executable
    local executables
    executables=$(find "$project_dir" -maxdepth 1 -type f \( -name "*.sh" -o -name "*.py" \) -executable 2>/dev/null | wc -l)
    
    if [[ $executables -gt 0 ]]; then
        log_success "Executable scripts found: $executables"
        score=$(echo "$score + 0.25" | bc)
    else
        log_warning "No executable scripts in root directory"
    fi
    
    # Directory organisation
    if [[ -d "$project_dir/src" ]] || [[ -d "$project_dir/lib" ]] || [[ -d "$project_dir/scripts" ]]; then
        log_success "Organised directory structure"
        score=$(echo "$score + 0.15" | bc)
    fi
    
    if [[ -d "$project_dir/tests" ]]; then
        log_success "Tests directory found"
        score=$(echo "$score + 0.10" | bc)
    fi
    
    echo ""
    echo "Structure Score: $score / $max_score"
    
    STRUCTURE_SCORE=$score
}

#-------------------------------------------------------------------------------
# Documentation Check
#-------------------------------------------------------------------------------

check_documentation() {
    local project_dir="$1"
    local score=0
    local max_score=$WEIGHT_DOCUMENTATION
    
    log_section "Checking Documentation"
    
    local readme="$project_dir/README.md"
    
    if [[ ! -f "$readme" ]]; then
        log_error "README.md not found"
        DOCUMENTATION_SCORE=0
        return
    fi
    
    local readme_lines
    readme_lines=$(wc -l < "$readme")
    
    # Length check
    if [[ $readme_lines -ge 50 ]]; then
        log_success "README.md has adequate length ($readme_lines lines)"
        score=$(echo "$score + 0.30" | bc)
    elif [[ $readme_lines -ge 20 ]]; then
        log_warning "README.md is short ($readme_lines lines)"
        score=$(echo "$score + 0.15" | bc)
    else
        log_error "README.md is too short ($readme_lines lines)"
    fi
    
    # Required sections
    local sections=("install" "usage" "example")
    for section in "${sections[@]}"; do
        if grep -qi "$section" "$readme"; then
            log_success "Section found: $section"
            score=$(echo "$score + 0.20" | bc)
        else
            log_warning "Section missing: $section"
        fi
    done
    
    # Code comments
    local comment_ratio
    local total_lines
    local comment_lines
    
    total_lines=$(find "$project_dir" -name "*.sh" -exec cat {} \; 2>/dev/null | wc -l)
    comment_lines=$(find "$project_dir" -name "*.sh" -exec cat {} \; 2>/dev/null | grep -c "^[[:space:]]*#" || echo 0)
    
    if [[ $total_lines -gt 0 ]]; then
        comment_ratio=$((comment_lines * 100 / total_lines))
        
        if [[ $comment_ratio -ge 15 ]]; then
            log_success "Good comment ratio: ${comment_ratio}%"
            score=$(echo "$score + 0.30" | bc)
        elif [[ $comment_ratio -ge 5 ]]; then
            log_warning "Low comment ratio: ${comment_ratio}%"
            score=$(echo "$score + 0.15" | bc)
        else
            log_error "Very low comment ratio: ${comment_ratio}%"
        fi
    fi
    
    echo ""
    echo "Documentation Score: $score / $max_score"
    
    DOCUMENTATION_SCORE=$score
}

#-------------------------------------------------------------------------------
# Code Quality Check
#-------------------------------------------------------------------------------

check_code_quality() {
    local project_dir="$1"
    local score=0
    local max_score=$WEIGHT_CODE_QUALITY
    
    log_section "Checking Code Quality"
    
    # ShellCheck on bash files
    local shellcheck_errors=0
    local shellcheck_warnings=0
    local bash_files
    
    bash_files=$(find "$project_dir" -name "*.sh" -type f 2>/dev/null)
    
    if [[ -n "$bash_files" ]]; then
        while IFS= read -r file; do
            local errors
            errors=$(shellcheck -f gcc "$file" 2>/dev/null | grep -c "error:" || echo 0)
            local warnings
            warnings=$(shellcheck -f gcc "$file" 2>/dev/null | grep -c "warning:" || echo 0)
            
            shellcheck_errors=$((shellcheck_errors + errors))
            shellcheck_warnings=$((shellcheck_warnings + warnings))
        done <<< "$bash_files"
        
        if [[ $shellcheck_errors -eq 0 && $shellcheck_warnings -eq 0 ]]; then
            log_success "ShellCheck: Clean (0 errors, 0 warnings)"
            score=$(echo "$score + 0.60" | bc)
        elif [[ $shellcheck_errors -eq 0 ]]; then
            log_warning "ShellCheck: $shellcheck_warnings warnings"
            score=$(echo "$score + 0.40" | bc)
        else
            log_error "ShellCheck: $shellcheck_errors errors, $shellcheck_warnings warnings"
            score=$(echo "$score + 0.20" | bc)
        fi
    fi
    
    # Python files with pylint
    local python_files
    python_files=$(find "$project_dir" -name "*.py" -type f 2>/dev/null)
    
    if [[ -n "$python_files" ]] && command -v pylint &> /dev/null; then
        local pylint_score
        pylint_score=$(pylint --output-format=text $python_files 2>/dev/null | grep "Your code has been rated" | grep -oP '\d+\.\d+' || echo "0")
        
        if (( $(echo "$pylint_score >= 8.0" | bc -l) )); then
            log_success "Pylint score: $pylint_score/10"
            score=$(echo "$score + 0.40" | bc)
        elif (( $(echo "$pylint_score >= 6.0" | bc -l) )); then
            log_warning "Pylint score: $pylint_score/10"
            score=$(echo "$score + 0.20" | bc)
        else
            log_error "Pylint score: $pylint_score/10"
        fi
    fi
    
    # Check for strict mode in bash scripts
    local strict_mode_count=0
    if [[ -n "$bash_files" ]]; then
        while IFS= read -r file; do
            if grep -q "set -e" "$file" || grep -q "set -euo pipefail" "$file"; then
                ((strict_mode_count++))
            fi
        done <<< "$bash_files"
        
        local bash_count
        bash_count=$(echo "$bash_files" | wc -l)
        
        if [[ $strict_mode_count -eq $bash_count ]]; then
            log_success "All scripts use strict mode"
            score=$(echo "$score + 0.30" | bc)
        elif [[ $strict_mode_count -gt 0 ]]; then
            log_warning "Some scripts use strict mode ($strict_mode_count/$bash_count)"
            score=$(echo "$score + 0.15" | bc)
        else
            log_error "No scripts use strict mode"
        fi
    fi
    
    # Proper quoting check
    local unquoted_vars=0
    if [[ -n "$bash_files" ]]; then
        while IFS= read -r file; do
            local count
            count=$(grep -cE '\$[a-zA-Z_][a-zA-Z0-9_]*[^"]' "$file" 2>/dev/null || echo 0)
            unquoted_vars=$((unquoted_vars + count))
        done <<< "$bash_files"
        
        if [[ $unquoted_vars -lt 5 ]]; then
            log_success "Good variable quoting"
            score=$(echo "$score + 0.20" | bc)
        elif [[ $unquoted_vars -lt 20 ]]; then
            log_warning "Some unquoted variables ($unquoted_vars instances)"
            score=$(echo "$score + 0.10" | bc)
        else
            log_error "Many unquoted variables ($unquoted_vars instances)"
        fi
    fi
    
    echo ""
    echo "Code Quality Score: $score / $max_score"
    
    CODE_QUALITY_SCORE=$score
}

#-------------------------------------------------------------------------------
# Functional Tests
#-------------------------------------------------------------------------------

run_functional_tests() {
    local project_dir="$1"
    local level="${2:-EASY}"
    local score=0
    local max_score=$WEIGHT_FUNCTIONAL
    
    log_section "Running Functional Tests"
    
    # Find main executable
    local main_script
    main_script=$(find "$project_dir" -maxdepth 1 -type f \( -name "*.sh" -o -name "*.py" \) -executable | head -1)
    
    if [[ -z "$main_script" ]]; then
        # Try finding any executable
        main_script=$(find "$project_dir" -maxdepth 2 -type f \( -name "main.sh" -o -name "main.py" -o -name "run.sh" \) | head -1)
    fi
    
    if [[ -z "$main_script" ]]; then
        log_error "No executable script found"
        FUNCTIONAL_SCORE=0
        return
    fi
    
    log_info "Testing: $main_script"
    
    # Test 1: Script runs without arguments (should show help or error)
    log_info "Test 1: Run without arguments"
    if timeout $TEST_TIMEOUT "$main_script" 2>&1 | grep -qiE "(usage|help|error|missing)" ; then
        log_success "Handles no arguments correctly"
        score=$(echo "$score + 0.50" | bc)
    else
        log_warning "No clear handling for missing arguments"
        score=$(echo "$score + 0.25" | bc)
    fi
    
    # Test 2: Help flag
    log_info "Test 2: Help flag"
    if timeout $TEST_TIMEOUT "$main_script" --help 2>&1 | grep -qiE "(usage|options|example)" ; then
        log_success "Help flag works"
        score=$(echo "$score + 0.50" | bc)
    elif timeout $TEST_TIMEOUT "$main_script" -h 2>&1 | grep -qiE "(usage|options|example)" ; then
        log_success "Help flag works (-h)"
        score=$(echo "$score + 0.50" | bc)
    else
        log_warning "No help flag or unclear help"
        score=$(echo "$score + 0.25" | bc)
    fi
    
    # Test 3: Exit codes
    log_info "Test 3: Exit codes"
    timeout $TEST_TIMEOUT "$main_script" --nonexistent-option 2>/dev/null
    local exit_code=$?
    
    if [[ $exit_code -ne 0 ]]; then
        log_success "Returns non-zero on error (exit code: $exit_code)"
        score=$(echo "$score + 0.50" | bc)
    else
        log_warning "Returns 0 even on error"
    fi
    
    # Test 4: Run project-specific tests if available
    if [[ -d "$project_dir/tests" ]]; then
        log_info "Test 4: Running project tests"
        
        local test_script
        test_script=$(find "$project_dir/tests" -name "run_tests.sh" -o -name "test_*.sh" | head -1)
        
        if [[ -n "$test_script" && -x "$test_script" ]]; then
            if timeout $TEST_TIMEOUT "$test_script" 2>&1; then
                log_success "Project tests passed"
                score=$(echo "$score + 1.00" | bc)
            else
                log_error "Project tests failed"
                score=$(echo "$score + 0.25" | bc)
            fi
        else
            log_warning "No executable test script found"
        fi
    else
        log_info "Test 4: No tests directory"
    fi
    
    # Remaining points based on level
    local remaining
    remaining=$(echo "$max_score - $score" | bc)
    
    # Placeholder for level-specific tests
    # In production, load tests from TEST_SPEC_*.md
    log_info "Level-specific tests: $level"
    log_warning "Additional tests would run here (simulated)"
    score=$(echo "$score + $remaining * 0.5" | bc)
    
    echo ""
    echo "Functional Score: $score / $max_score"
    
    FUNCTIONAL_SCORE=$score
}

#-------------------------------------------------------------------------------
# Error Handling Check
#-------------------------------------------------------------------------------

check_error_handling() {
    local project_dir="$1"
    local score=0
    local max_score=$WEIGHT_ERROR_HANDLING
    
    log_section "Checking Error Handling"
    
    local bash_files
    bash_files=$(find "$project_dir" -name "*.sh" -type f 2>/dev/null)
    
    if [[ -z "$bash_files" ]]; then
        log_warning "No bash files to analyse"
        ERROR_HANDLING_SCORE=0
        return
    fi
    
    # Check for trap statements
    local trap_count=0
    while IFS= read -r file; do
        if grep -q "trap " "$file"; then
            ((trap_count++))
        fi
    done <<< "$bash_files"
    
    if [[ $trap_count -gt 0 ]]; then
        log_success "Trap statements found ($trap_count files)"
        score=$(echo "$score + 0.25" | bc)
    else
        log_warning "No trap statements for cleanup"
    fi
    
    # Check for exit code checking
    local exit_check_count=0
    while IFS= read -r file; do
        if grep -qE '\$\?|if \[|&& |[|][|] ' "$file"; then
            ((exit_check_count++))
        fi
    done <<< "$bash_files"
    
    if [[ $exit_check_count -gt 0 ]]; then
        log_success "Exit code checking found"
        score=$(echo "$score + 0.25" | bc)
    else
        log_warning "No exit code checking found"
    fi
    
    # Check for input validation
    local validation_count=0
    while IFS= read -r file; do
        if grep -qE '\[ -[fdrwx] |\[\[ -[fdrwx] |test -[fdrwx]' "$file"; then
            ((validation_count++))
        fi
    done <<< "$bash_files"
    
    if [[ $validation_count -gt 0 ]]; then
        log_success "Input validation found"
        score=$(echo "$score + 0.25" | bc)
    else
        log_warning "Limited input validation"
    fi
    
    echo ""
    echo "Error Handling Score: $score / $max_score"
    
    ERROR_HANDLING_SCORE=$score
}

#-------------------------------------------------------------------------------
# Generate Report
#-------------------------------------------------------------------------------

generate_report() {
    local project_dir="$1"
    local output_dir="$2"
    
    log_section "Generating Report"
    
    mkdir -p "$output_dir"
    
    local total_score
    total_score=$(echo "$FUNCTIONAL_SCORE + $CODE_QUALITY_SCORE + $DOCUMENTATION_SCORE + $STRUCTURE_SCORE + $ERROR_HANDLING_SCORE" | bc)
    
    local report_file="$output_dir/evaluation_report.md"
    
    cat > "$report_file" << EOF
# Automated Evaluation Report

**Project:** $(basename "$project_dir")
**Date:** $(date '+%Y-%m-%d %H:%M:%S')
**Evaluator:** Automated System v${VERSION}

---

## Score Summary

| Component | Score | Max | Percentage |
|-----------|-------|-----|------------|
| Functional Tests | ${FUNCTIONAL_SCORE} | ${WEIGHT_FUNCTIONAL} | $(echo "scale=1; $FUNCTIONAL_SCORE * 100 / $WEIGHT_FUNCTIONAL" | bc)% |
| Code Quality | ${CODE_QUALITY_SCORE} | ${WEIGHT_CODE_QUALITY} | $(echo "scale=1; $CODE_QUALITY_SCORE * 100 / $WEIGHT_CODE_QUALITY" | bc)% |
| Documentation | ${DOCUMENTATION_SCORE} | ${WEIGHT_DOCUMENTATION} | $(echo "scale=1; $DOCUMENTATION_SCORE * 100 / $WEIGHT_DOCUMENTATION" | bc)% |
| Structure | ${STRUCTURE_SCORE} | ${WEIGHT_STRUCTURE} | $(echo "scale=1; $STRUCTURE_SCORE * 100 / $WEIGHT_STRUCTURE" | bc)% |
| Error Handling | ${ERROR_HANDLING_SCORE} | ${WEIGHT_ERROR_HANDLING} | $(echo "scale=1; $ERROR_HANDLING_SCORE * 100 / $WEIGHT_ERROR_HANDLING" | bc)% |
| **TOTAL (Auto)** | **${total_score}** | **8.50** | **$(echo "scale=1; $total_score * 100 / 8.5" | bc)%** |

*Note: Manual evaluation (1.5 points) not included.*

---

## Detailed Results

### Functional Tests (${FUNCTIONAL_SCORE}/${WEIGHT_FUNCTIONAL})
[Details from functional test output]

### Code Quality (${CODE_QUALITY_SCORE}/${WEIGHT_CODE_QUALITY})
[ShellCheck and style analysis results]

### Documentation (${DOCUMENTATION_SCORE}/${WEIGHT_DOCUMENTATION})
[README and comment analysis]

### Project Structure (${STRUCTURE_SCORE}/${WEIGHT_STRUCTURE})
[Directory and file organisation]

### Error Handling (${ERROR_HANDLING_SCORE}/${WEIGHT_ERROR_HANDLING})
[Robustness analysis]

---

## Recommendations

1. [Auto-generated based on low-scoring areas]
2. [Suggestions for improvement]

---

*Generated by run_auto_eval_EN.sh v${VERSION}*
EOF

    log_success "Report saved to: $report_file"
    
    # CSV summary for aggregation
    local csv_file="$output_dir/scores.csv"
    echo "Component,Score,MaxScore" > "$csv_file"
    echo "Functional,$FUNCTIONAL_SCORE,$WEIGHT_FUNCTIONAL" >> "$csv_file"
    echo "CodeQuality,$CODE_QUALITY_SCORE,$WEIGHT_CODE_QUALITY" >> "$csv_file"
    echo "Documentation,$DOCUMENTATION_SCORE,$WEIGHT_DOCUMENTATION" >> "$csv_file"
    echo "Structure,$STRUCTURE_SCORE,$WEIGHT_STRUCTURE" >> "$csv_file"
    echo "ErrorHandling,$ERROR_HANDLING_SCORE,$WEIGHT_ERROR_HANDLING" >> "$csv_file"
    echo "Total,$total_score,8.50" >> "$csv_file"
    
    log_success "CSV saved to: $csv_file"
    
    # Final summary
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}                    EVALUATION COMPLETE                        ${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "  Automatic Score: ${GREEN}${total_score}${NC} / 8.50"
    echo -e "  (Manual evaluation adds up to 1.50 more)"
    echo ""
}

#-------------------------------------------------------------------------------
# Main
#-------------------------------------------------------------------------------

# Defaults
OUTPUT_DIR="./evaluation_results"
PROJECT_LEVEL="EASY"
USE_DOCKER=false
VERBOSE=false

# Initialise scores
FUNCTIONAL_SCORE=0
CODE_QUALITY_SCORE=0
DOCUMENTATION_SCORE=0
STRUCTURE_SCORE=0
ERROR_HANDLING_SCORE=0

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help) usage ;;
        -v|--version) echo "$SCRIPT_NAME v$VERSION"; exit 0 ;;
        -o|--output) OUTPUT_DIR="$2"; shift 2 ;;
        -l|--level) PROJECT_LEVEL="$2"; shift 2 ;;
        -t|--timeout) TEST_TIMEOUT="$2"; shift 2 ;;
        --docker) USE_DOCKER=true; shift ;;
        --verbose) VERBOSE=true; shift ;;
        --no-cleanup) NO_CLEANUP=true; shift ;;
        -*) log_error "Unknown option: $1"; exit 1 ;;
        *) PROJECT_DIR="$1"; shift ;;
    esac
done

main() {
    print_banner
    
    if [[ -z "${PROJECT_DIR:-}" ]]; then
        log_error "No project directory specified"
        usage
    fi
    
    if [[ ! -d "$PROJECT_DIR" ]]; then
        log_error "Directory not found: $PROJECT_DIR"
        exit 1
    fi
    
    PROJECT_DIR=$(realpath "$PROJECT_DIR")
    
    log_info "Project: $PROJECT_DIR"
    log_info "Level: $PROJECT_LEVEL"
    log_info "Output: $OUTPUT_DIR"
    
    check_prerequisites
    check_structure "$PROJECT_DIR"
    check_documentation "$PROJECT_DIR"
    check_code_quality "$PROJECT_DIR"
    check_error_handling "$PROJECT_DIR"
    run_functional_tests "$PROJECT_DIR" "$PROJECT_LEVEL"
    
    generate_report "$PROJECT_DIR" "$OUTPUT_DIR"
}

main
