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
# Each test has TEST_TIMEOUT; this is not a whole-run resource sandbox.

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
    --docker            Run in an explicitly supplied local Docker image
    --docker-image IMG  Existing image with Bash, Python, bc and ShellCheck (no pull)
    --execute-local     Execute trusted project code locally (default: static checks only)
    --no-cleanup        Don't clean up temporary files
    --verbose           Verbose output

EXAMPLES:
    ${SCRIPT_NAME} /path/to/student/project/
    ${SCRIPT_NAME} -l MEDIUM -o ./results/ /project/
    ${SCRIPT_NAME} --docker --docker-image locally-reviewed-image /project/

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
    for tool in bash shellcheck python3 bc timeout; do
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
    
    total_lines=$(find "$project_dir" -type f -name "*.sh" -exec cat {} \; 2>/dev/null | wc -l)
    comment_lines=$(find "$project_dir" -type f -name "*.sh" -exec cat {} \; 2>/dev/null | grep -c "^[[:space:]]*#" || true)
    
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
    local project_dir="$1" score=0 max_score=$WEIGHT_CODE_QUALITY file status counts index=0
    local shellcheck_errors=0 shellcheck_warnings=0 shellcheck_messages=0 errors warnings messages
    local -a bash_files=() python_files=()
    log_section "Checking Project Code Diagnostics"
    find "$project_dir" -type f -name '*.sh' -print0 > "$EVAL_WORK/quality-bash.nul" || return 1
    find "$project_dir" -type f -name '*.py' -print0 > "$EVAL_WORK/quality-python.nul" || return 1
    mapfile -d '' -t bash_files < "$EVAL_WORK/quality-bash.nul"
    mapfile -d '' -t python_files < "$EVAL_WORK/quality-python.nul"
    for file in "${bash_files[@]}"; do
        index=$((index + 1)); status=0
        timeout --kill-after=2 "$TEST_TIMEOUT" shellcheck -f json "$file" \
            > "$EVAL_WORK/shellcheck-$index.json" 2> "$EVAL_WORK/shellcheck-$index.log" || status=$?
        if ! counts=$(python3 - "$EVAL_WORK/shellcheck-$index.json" "$status" <<'PY_SHELLCHECK'
import json, sys
status = int(sys.argv[2])
if status not in (0, 1): raise SystemExit("ShellCheck did not complete: status " + str(status))
try:
    with open(sys.argv[1], encoding="utf-8") as stream: rows = json.load(stream)
    if not isinstance(rows, list): raise ValueError("expected diagnostic list")
    for row in rows:
        if (not isinstance(row, dict) or row.get("level") not in ("error", "warning", "info", "style")
            or type(row.get("line")) is not int or row["line"] < 1
            or type(row.get("code")) is not int): raise ValueError("invalid diagnostic row")
    if status == 1 and not rows: raise ValueError("failure status without diagnostics")
except (OSError, ValueError) as error:
    raise SystemExit(str(error))
print(sum(r["level"] == "error" for r in rows), sum(r["level"] == "warning" for r in rows), len(rows))
PY_SHELLCHECK
        ); then
            log_error "INCOMPLETE: ShellCheck execution or report failed for $file"
            return 1
        fi
        IFS=' ' read -r errors warnings messages <<< "$counts"
        shellcheck_errors=$((shellcheck_errors + errors))
        shellcheck_warnings=$((shellcheck_warnings + warnings))
        shellcheck_messages=$((shellcheck_messages + messages))
    done
    if (( ${#bash_files[@]} )); then
        log_info "ShellCheck observations: $shellcheck_errors errors, $shellcheck_warnings warnings, $shellcheck_messages total diagnostics"
        if (( shellcheck_errors == 0 && shellcheck_warnings == 0 )); then score=$(echo "$score + 0.60" | bc)
        elif (( shellcheck_errors == 0 )); then score=$(echo "$score + 0.40" | bc)
        else score=$(echo "$score + 0.20" | bc); fi
    else
        log_warning "ShellCheck NOT_APPLICABLE: no regular .sh files"
    fi
    # Optional pylint is descriptive, with an explicit neutral configuration.
    if (( ${#python_files[@]} )) && command -v pylint >/dev/null; then
        local pylint_score
        status=0
        timeout --kill-after=2 "$TEST_TIMEOUT" pylint --rcfile=/dev/null --persistent=n \
            --output-format=text "${python_files[@]}" > "$EVAL_WORK/pylint.log" 2>&1 || status=$?
        if (( status > 31 || (status & 1) )); then log_error "INCOMPLETE: pylint could not complete ($status)"; return 1; fi
        if ! pylint_score=$(python3 - "$EVAL_WORK/pylint.log" <<'PY_PYLINT'
import pathlib, re, sys
values = re.findall(r"Your code has been rated at (-?[0-9]+(?:\.[0-9]+)?)/10", pathlib.Path(sys.argv[1]).read_text())
if len(values) != 1: raise SystemExit("No unambiguous pylint rating")
print(values[0])
PY_PYLINT
        ); then log_error "INCOMPLETE: no usable pylint report"; return 1; fi
        if (( $(echo "$pylint_score >= 8.0" | bc -l) )); then score=$(echo "$score + 0.40" | bc)
        elif (( $(echo "$pylint_score >= 6.0" | bc -l) )); then score=$(echo "$score + 0.20" | bc); fi
        log_info "Pylint descriptive rating: $pylint_score/10"
    elif (( ${#python_files[@]} )); then log_warning "Pylint NOT_RUN: optional tool unavailable"; fi
    local strict_mode_count=0 unquoted_vars=0 count
    for file in "${bash_files[@]}"; do
        [[ -r $file ]] || { log_error "Unreadable input: $file"; return 1; }
        if grep -q 'set -e' "$file"; then strict_mode_count=$((strict_mode_count + 1)); fi
        status=0
        count=$(grep -cE '\$[a-zA-Z_][a-zA-Z0-9_]*[^"]' "$file") || status=$?
        (( status <= 1 )) || return 1
        unquoted_vars=$((unquoted_vars + count))
    done
    if (( ${#bash_files[@]} )); then
        if (( strict_mode_count == ${#bash_files[@]} )); then score=$(echo "$score + 0.30" | bc)
        elif (( strict_mode_count > 0 )); then score=$(echo "$score + 0.15" | bc); fi
        if (( unquoted_vars < 5 )); then score=$(echo "$score + 0.20" | bc)
        elif (( unquoted_vars < 20 )); then score=$(echo "$score + 0.10" | bc); fi
        log_info "Lexical observations: set -e matches in $strict_mode_count files; variable-pattern matches=$unquoted_vars"
        log_warning "Lexical matches do not establish runtime error handling or correct quoting"
    fi
    CODE_QUALITY_SCORE=$score
    log_info "Historical heuristic subtotal: $score; proposed cap $max_score is not a grading policy"
}

#-------------------------------------------------------------------------------
# Functional Tests
#-------------------------------------------------------------------------------

run_candidate() {
    local project_dir="$1" script="$2" logfile="$3"; shift 3
    local interpreter
    case "$script" in *.sh) interpreter=bash;; *.py) interpreter=python3;; *) return 2;; esac
    (cd -- "$project_dir" && timeout --kill-after=2 "$TEST_TIMEOUT" "$interpreter" "$script" "$@") >"$logfile" 2>&1
}

run_functional_tests() {
    local project_dir="$1" level="${2:-EASY}" score=0 main_script="" status file
    log_section "Running Functional Diagnostics"
    if [[ "$EXECUTE_LOCAL" != true ]]; then
        log_warning "NOT_RUN: use --docker with an existing image, or --execute-local for trusted code"
        FUNCTIONAL_SCORE=0; FUNCTIONAL_STATUS=NOT_RUN; return 0
    fi
    FUNCTIONAL_STATUS=EXECUTED_LOCAL
    # Prefer named entry points; ambiguous projects require an explicit project test.
    for file in main.sh main.py run.sh; do
        if [[ -f "$project_dir/$file" ]]; then main_script="$project_dir/$file"; break; fi
    done
    if [[ -z "$main_script" ]]; then
        local -a candidates=()
        mapfile -d '' -t candidates < <(find "$project_dir" -maxdepth 1 -type f \( -name '*.sh' -o -name '*.py' \) -print0 | sort -z)
        if [[ ${#candidates[@]} -eq 1 ]]; then main_script="${candidates[0]}"; fi
    fi
    if [[ -z "$main_script" ]]; then
        log_warning "NOT_RUN: no unique project entry point"; FUNCTIONAL_SCORE=0; FUNCTIONAL_STATUS=NOT_RUN; return 0
    fi
    status=0
    run_candidate "$project_dir" "$main_script" "$EVAL_WORK/no-arguments.log" || status=$?
    local no_arguments_status=$status
    if (( status < 124 )) && grep -qiE 'usage|help|error|missing' "$EVAL_WORK/no-arguments.log"; then
        score=$(echo "$score + 0.50" | bc)
    fi
    status=0
    run_candidate "$project_dir" "$main_script" "$EVAL_WORK/help.log" --help || status=$?
    local help_status=$status
    if (( status == 0 )) && grep -qiE 'usage|options|example' "$EVAL_WORK/help.log"; then
        score=$(echo "$score + 0.50" | bc)
    fi
    status=0
    run_candidate "$project_dir" "$main_script" "$EVAL_WORK/invalid-option.log" --nonexistent-option || status=$?
    if (( status > 0 && status < 124 )); then score=$(echo "$score + 0.50" | bc); fi
    local invalid_option_status=$status
    local test_script="" tests_ok=false project_test_status=NOT_RUN
    if [[ -f "$project_dir/tests/run_tests.sh" ]]; then test_script="$project_dir/tests/run_tests.sh"; fi
    if [[ -n "$test_script" ]]; then
        status=0
        run_candidate "$project_dir" "$test_script" "$EVAL_WORK/project-tests.log" || status=$?
        project_test_status=$status
        if (( status == 0 )); then
            tests_ok=true; score=$(echo "$score + 1.00" | bc)
        else
            log_error "Project test runner failed: $status"
        fi
    else
        log_warning "NOT_RUN: no tests/run_tests.sh; define substantive project-specific tests"
    fi
    log_warning "Level-specific acceptance ($level) is not implemented; no simulated credit"
    FUNCTIONAL_SCORE=$score
    printf 'diagnostic,return_code\nno_arguments,%s\nhelp,%s\ninvalid_option,%s\nproject_tests,%s\nproject_tests_passed,%s\n' "$no_arguments_status" "$help_status" "$invalid_option_status" "$project_test_status" "$tests_ok" >"$EVAL_WORK/functional_status.csv"
    return 0
}

#-------------------------------------------------------------------------------
# Error Handling Check
#-------------------------------------------------------------------------------

check_error_handling() {
    local project_dir="$1"
    local score=0
    local max_score=$WEIGHT_ERROR_HANDLING
    
    log_section "Checking Error Handling"
    
    local -a bash_files=()
    find "$project_dir" -name '*.sh' -type f -print0 > "$EVAL_WORK/error-handling-files.nul" || return 1
    mapfile -d '' -t bash_files < "$EVAL_WORK/error-handling-files.nul"
    
    if (( ${#bash_files[@]} == 0 )); then
        log_warning "No bash files to analyse"
        ERROR_HANDLING_SCORE=0
        return
    fi
    
    # Check for trap statements
    local trap_count=0
    for file in "${bash_files[@]}"; do
        if grep -q "trap " "$file"; then
            trap_count=$((trap_count + 1))
        fi
    done
    
    if [[ $trap_count -gt 0 ]]; then
        log_success "Trap statements found ($trap_count files)"
        score=$(echo "$score + 0.25" | bc)
    else
        log_warning "No trap statements for cleanup"
    fi
    
    # Check for exit code checking
    local exit_check_count=0
    for file in "${bash_files[@]}"; do
        if grep -qE '\$\?|if \[|&& |[|][|] ' "$file"; then
            exit_check_count=$((exit_check_count + 1))
        fi
    done
    
    if [[ $exit_check_count -gt 0 ]]; then
        log_success "Exit code checking found"
        score=$(echo "$score + 0.25" | bc)
    else
        log_warning "No exit code checking found"
    fi
    
    # Check for input validation
    local validation_count=0
    for file in "${bash_files[@]}"; do
        if grep -qE '\[ -[fdrwx] |\[\[ -[fdrwx] |test -[fdrwx]' "$file"; then
            validation_count=$((validation_count + 1))
        fi
    done
    
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
    
    local total_score functional_display functional_percentage total_percentage
    total_score=$(echo "$FUNCTIONAL_SCORE + $CODE_QUALITY_SCORE + $DOCUMENTATION_SCORE + $STRUCTURE_SCORE + $ERROR_HANDLING_SCORE" | bc)
    
    functional_display=$FUNCTIONAL_SCORE
    functional_percentage=$(echo "scale=1; $FUNCTIONAL_SCORE * 100 / $WEIGHT_FUNCTIONAL" | bc)
    total_percentage=$(echo "scale=1; $total_score * 100 / 8.5" | bc)
    if [[ $FUNCTIONAL_STATUS == NOT_RUN ]]; then
        functional_display=NOT_RUN; functional_percentage=unavailable
        total_score=PENDING_EVIDENCE; total_percentage=unavailable
    fi

    local report_file="$output_dir/evaluation_report.md"
    
    cat > "$report_file" << EOF
# Preliminary Diagnostic Report

**Project:** $(basename "$project_dir")
**Date:** $(date '+%Y-%m-%d %H:%M:%S')
**Evaluator:** Automated System v${VERSION}

---

This report contains heuristics, not an authoritative assessment. Component weights,
manual criteria and eligibility need author approval. The displayed historical caps
are not attainable maxima for every language mix; no normalisation or grade
conversion is applied. A NOT_RUN value is unavailable evidence, not a reviewed zero. Missing level-specific tests
and unavailable executions cannot prove correctness. Functional status: ${FUNCTIONAL_STATUS}.

## Diagnostic Summary

| Component | Score | Max | Percentage |
|-----------|-------|-----|------------|
| Functional Tests | ${functional_display} | ${WEIGHT_FUNCTIONAL} | ${functional_percentage} |
| Code Quality | ${CODE_QUALITY_SCORE} | ${WEIGHT_CODE_QUALITY} | $(echo "scale=1; $CODE_QUALITY_SCORE * 100 / $WEIGHT_CODE_QUALITY" | bc)% |
| Documentation | ${DOCUMENTATION_SCORE} | ${WEIGHT_DOCUMENTATION} | $(echo "scale=1; $DOCUMENTATION_SCORE * 100 / $WEIGHT_DOCUMENTATION" | bc)% |
| Structure | ${STRUCTURE_SCORE} | ${WEIGHT_STRUCTURE} | $(echo "scale=1; $STRUCTURE_SCORE * 100 / $WEIGHT_STRUCTURE" | bc)% |
| Error Handling | ${ERROR_HANDLING_SCORE} | ${WEIGHT_ERROR_HANDLING} | $(echo "scale=1; $ERROR_HANDLING_SCORE * 100 / $WEIGHT_ERROR_HANDLING" | bc)% |
| **DIAGNOSTIC TOTAL** | **${total_score}** | **8.50** | **${total_percentage}** |

*Manual assessment and canonical weights are undecided. Do not import this diagnostic total as a final grade.*

---

## Detailed Results

### Functional Tests (${functional_display}; historical cap ${WEIGHT_FUNCTIONAL})
Actual return codes are recorded in functional_status.csv when execution was requested.
Command output is retained in the corresponding .log files; missing tests are NOT_RUN.

### Code Quality (${CODE_QUALITY_SCORE}/${WEIGHT_CODE_QUALITY})
ShellCheck JSON diagnostics and tool logs are retained alongside this report.
Lexical source matches are descriptive heuristics; they are not runtime proofs.

### Documentation (${DOCUMENTATION_SCORE}/${WEIGHT_DOCUMENTATION})
README length, section-word matches and comment ratios are coarse source observations.

### Project Structure (${STRUCTURE_SCORE}/${WEIGHT_STRUCTURE})
Presence and layout checks do not establish project functionality.

### Error Handling (${ERROR_HANDLING_SCORE}/${WEIGHT_ERROR_HANDLING})
Trap and conditional patterns do not establish correct failure propagation.

---

## Recommendations

1. Review exact diagnostics and test output against the approved assignment.
2. Supply substantive project-specific tests and resolve the assessment contract before grading.

---

*Generated by run_auto_eval_EN.sh v${VERSION}*
EOF

    local -a diagnostic_files=()
    shopt -s nullglob
    diagnostic_files=("$EVAL_WORK"/*.log "$EVAL_WORK"/shellcheck-*.json)
    shopt -u nullglob
    if (( ${#diagnostic_files[@]} )); then cp -- "${diagnostic_files[@]}" "$output_dir/" || return 1; fi
    [[ ! -f "$EVAL_WORK/functional_status.csv" ]] || cp -- "$EVAL_WORK/functional_status.csv" "$output_dir/"
    log_success "Report saved to: $report_file"
    
    # Historical heuristic component record; it is not accepted by the grade calculator.
    local csv_file="$output_dir/scores.csv"
    echo "Component,Score,HistoricalCap,Status" > "$csv_file"
    if [[ $FUNCTIONAL_STATUS == NOT_RUN ]]; then
        echo "Functional,,$WEIGHT_FUNCTIONAL,NOT_RUN" >> "$csv_file"
    else
        echo "Functional,$FUNCTIONAL_SCORE,$WEIGHT_FUNCTIONAL,PARTIAL_DIAGNOSTICS" >> "$csv_file"
    fi
    echo "CodeQuality,$CODE_QUALITY_SCORE,$WEIGHT_CODE_QUALITY,HEURISTIC_ONLY" >> "$csv_file"
    echo "Documentation,$DOCUMENTATION_SCORE,$WEIGHT_DOCUMENTATION,HEURISTIC_ONLY" >> "$csv_file"
    echo "Structure,$STRUCTURE_SCORE,$WEIGHT_STRUCTURE,HEURISTIC_ONLY" >> "$csv_file"
    echo "ErrorHandling,$ERROR_HANDLING_SCORE,$WEIGHT_ERROR_HANDLING,HEURISTIC_ONLY" >> "$csv_file"
    if [[ $FUNCTIONAL_STATUS == NOT_RUN ]]; then
        echo "Total,,8.50,PENDING_EVIDENCE" >> "$csv_file"
    else
        echo "Total,$total_score,8.50,PENDING_POLICY" >> "$csv_file"
    fi
    
    log_success "CSV saved to: $csv_file"
    
    # Final summary
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}                    EVALUATION COMPLETE                        ${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "  Diagnostic heuristic total: ${GREEN}${total_score}${NC} / 8.50"
    echo -e "  (Not a grade; author policy and substantive tests are required)"
    echo ""
}

#-------------------------------------------------------------------------------
# Main
#-------------------------------------------------------------------------------

# Defaults
OUTPUT_DIR="./evaluation_results"
PROJECT_LEVEL="EASY"
USE_DOCKER=false
DOCKER_IMAGE=""
EXECUTE_LOCAL=false
FUNCTIONAL_STATUS=NOT_RUN
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
        -o|--output|-l|--level|-t|--timeout) [[ $# -ge 2 ]] || { log_error "Missing value: $1"; exit 1; } ;;
    esac
    case "$1" in
        -h|--help) usage ;;
        -v|--version) echo "$SCRIPT_NAME v$VERSION"; exit 0 ;;
        -o|--output) OUTPUT_DIR="$2"; shift 2 ;;
        -l|--level) PROJECT_LEVEL="$2"; shift 2 ;;
        -t|--timeout) TEST_TIMEOUT="$2"; shift 2 ;;
        --docker) USE_DOCKER=true; shift ;;
        --docker-image) [[ $# -ge 2 ]] || { log_error "Missing image"; exit 1; }; DOCKER_IMAGE="$2"; shift 2 ;;
        --execute-local) EXECUTE_LOCAL=true; shift ;;
        --verbose) VERBOSE=true; shift ;;
        --no-cleanup) NO_CLEANUP=true; shift ;;
        -*) log_error "Unknown option: $1"; exit 1 ;;
        *) [[ -z ${PROJECT_DIR:-} ]] || { log_error "Exactly one project directory is required"; exit 1; }; PROJECT_DIR="$1"; shift ;;
    esac
done

main() {
    print_banner
    
    if [[ -z "${PROJECT_DIR:-}" ]]; then
        log_error "No project directory specified; use --help"
        exit 1
    fi
    
    if [[ ! -d "$PROJECT_DIR" ]]; then
        log_error "Directory not found: $PROJECT_DIR"
        exit 1
    fi
    
    PROJECT_DIR=$(realpath "$PROJECT_DIR")
    OUTPUT_DIR=$(realpath -m "$OUTPUT_DIR")
    [[ "$TEST_TIMEOUT" =~ ^[1-9][0-9]*$ ]] || { log_error "Timeout must be a positive integer"; return 1; }
    case "$PROJECT_LEVEL" in EASY|MEDIUM|ADVANCED) ;; *) log_error "Unknown project level"; return 1;; esac
    if [[ "$USE_DOCKER" == true ]]; then
        [[ -n "$DOCKER_IMAGE" ]] || { log_error "--docker requires --docker-image with an existing image"; return 1; }
        command -v docker >/dev/null || { log_error "Docker unavailable; local execution is not substituted"; return 1; }
        docker image inspect "$DOCKER_IMAGE" >/dev/null || { log_error "Local image unavailable; no pull performed"; return 1; }
        mkdir -p "$OUTPUT_DIR"
        timeout "$((TEST_TIMEOUT * 8))" docker run --rm --network none --read-only --cap-drop ALL \
            --security-opt no-new-privileges --pids-limit 128 --memory 512m --cpus 1 \
            --user "$(id -u):$(id -g)" --tmpfs /tmp:rw,nosuid,nodev \
            --mount "type=bind,src=$PROJECT_DIR,dst=/project,readonly" \
            --mount "type=bind,src=$SCRIPT_DIR,dst=/evaluator,readonly" \
            --mount "type=bind,src=$OUTPUT_DIR,dst=/results" \
            "$DOCKER_IMAGE" bash /evaluator/run_auto_eval_EN.sh --execute-local \
            -o /results -l "$PROJECT_LEVEL" -t "$TEST_TIMEOUT" /project
        return $?
    fi
    EVAL_WORK=$(mktemp -d "${TMPDIR:-/tmp}/enos-eval.XXXXXX")
    trap 'if [[ "${NO_CLEANUP:-false}" != true ]]; then rm -rf -- "$EVAL_WORK"; else printf "Retained diagnostics: %s\n" "$EVAL_WORK"; fi' EXIT
    if [[ "$EXECUTE_LOCAL" == true ]]; then
        # Isolate the working copy, not the process: trusted code only in this mode.
        mkdir "$EVAL_WORK/project"
        cp -a -- "$PROJECT_DIR/." "$EVAL_WORK/project/"
        PROJECT_DIR="$EVAL_WORK/project"
    fi
    
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
    [[ "$FUNCTIONAL_STATUS" != NOT_RUN ]] || return 2
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then main; fi
