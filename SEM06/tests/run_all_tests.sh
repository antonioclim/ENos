#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════════
# run_all_tests.sh — Test Runner Wrapper for SEM06 CAPSTONE
# ═══════════════════════════════════════════════════════════════════════════════
# Operating Systems | ASE Bucharest - CSIE
# Usage: ./tests/run_all_tests.sh [options]
# ═══════════════════════════════════════════════════════════════════════════════

set -euo pipefail

# ─────────────────────────────────────────────────────────────────────────────
# CONFIGURATION
# ─────────────────────────────────────────────────────────────────────────────

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
SCRIPTS_DIR="$ROOT_DIR/scripts"
PROJECTS_DIR="$SCRIPTS_DIR/projects"

# Colours
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Colour

# Counters
TESTS_PASSED=0
TESTS_FAILED=0
TESTS_SKIPPED=0

# ─────────────────────────────────────────────────────────────────────────────
# UTILITY FUNCTIONS
# ─────────────────────────────────────────────────────────────────────────────

log_info() {
    echo -e "${CYAN}[INFO]${NC} $1"
}

log_pass() {
    echo -e "${GREEN}[PASS]${NC} $1"
    TESTS_PASSED=$((TESTS_PASSED + 1))
}

log_fail() {
    echo -e "${RED}[FAIL]${NC} $1"
    TESTS_FAILED=$((TESTS_FAILED + 1))
}

log_skip() {
    echo -e "${YELLOW}[SKIP]${NC} $1"
    TESTS_SKIPPED=$((TESTS_SKIPPED + 1))
}

print_header() {
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}  $1${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
}

print_separator() {
    echo -e "${CYAN}───────────────────────────────────────────────────────────────${NC}"
}

# ─────────────────────────────────────────────────────────────────────────────
# TEST FUNCTIONS
# ─────────────────────────────────────────────────────────────────────────────

run_project_tests() {
    local project="$1"
    local test_file="$PROJECTS_DIR/$project/tests/test_${project}.sh"
    
    if [[ -f "$test_file" ]]; then
        log_info "Running tests for: $project"
        if bash "$test_file"; then
            log_pass "$project tests passed"
        else
            log_fail "$project tests failed"
        fi
    else
        log_skip "$project (no test file found)"
    fi
}

run_main_test_runner() {
    log_info "Running maintained Python tests..."
    if python3 -m pytest "$SCRIPT_DIR" -q; then
        log_pass "Python tests passed"
    else
        log_fail "Python tests failed or pytest is unavailable"
    fi
}

run_quiz_tests() {
    local quiz_runner="$ROOT_DIR/formative/quiz_runner.py"
    
    if [[ -f "$quiz_runner" ]]; then
        log_info "Running quiz runner tests..."
        if python3 "$quiz_runner" --test; then
            log_pass "Quiz runner tests passed"
        else
            log_fail "Quiz runner tests failed"
        fi
    else
        log_skip "Quiz runner tests (not found)"
    fi
}

validate_yaml() {
    local quiz_yaml="$ROOT_DIR/formative/quiz.yaml"
    
    if [[ -f "$quiz_yaml" ]]; then
        log_info "Validating quiz YAML..."
        if python3 -c 'import sys,yaml; yaml.safe_load(open(sys.argv[1]))' "$quiz_yaml"; then
            log_pass "Quiz YAML is valid"
        else
            log_fail "Quiz YAML validation failed"
        fi
    else
        log_skip "Quiz YAML validation (file not found)"
    fi
}

validate_json() {
    local quiz_json="$ROOT_DIR/formative/quiz_lms.json"
    
    if [[ -f "$quiz_json" ]]; then
        log_info "Validating quiz JSON..."
        if python3 -c 'import sys,json; json.load(open(sys.argv[1]))' "$quiz_json"; then
            log_pass "Quiz JSON is valid"
        else
            log_fail "Quiz JSON validation failed"
        fi
    else
        log_skip "Quiz JSON validation (file not found)"
    fi
}

# ─────────────────────────────────────────────────────────────────────────────
# MAIN
# ─────────────────────────────────────────────────────────────────────────────

main() {
    print_header "SEM06 CAPSTONE — Test Suite"
    
    # Verify we are in the correct directory
    if [[ ! -d "$PROJECTS_DIR" ]]; then
        echo -e "${RED}Error: Cannot find projects directory at $PROJECTS_DIR${NC}"
        exit 1
    fi
    
    # Project tests
    print_separator
    echo "Project Tests:"
    print_separator
    
    run_project_tests "monitor"
    run_project_tests "backup"
    run_project_tests "deployer"
    
    # Main test runner (if it exists)
    print_separator
    echo "Integration Tests:"
    print_separator
    
    run_main_test_runner
    
    # Quiz tests
    print_separator
    echo "Quiz Tests:"
    print_separator
    
    run_quiz_tests
    validate_yaml
    validate_json
    
    # Summary
    print_header "Test Summary"
    
    echo -e "  ${GREEN}Passed:${NC}  $TESTS_PASSED"
    echo -e "  ${RED}Failed:${NC}  $TESTS_FAILED"
    echo -e "  ${YELLOW}Skipped:${NC} $TESTS_SKIPPED"
    echo ""
    
    local total=$((TESTS_PASSED + TESTS_FAILED))
    if [[ $total -gt 0 ]]; then
        local percentage=$((TESTS_PASSED * 100 / total))
        echo -e "  Success rate: ${percentage}%"
    fi
    
    echo ""
    
    if [[ $TESTS_FAILED -gt 0 ]]; then
        echo -e "${RED}Some tests failed!${NC}"
        exit 1
    else
        echo -e "${GREEN}All executed test groups passed; skipped: $TESTS_SKIPPED${NC}"
        exit 0
    fi
}

# ─────────────────────────────────────────────────────────────────────────────
# HELP
# ─────────────────────────────────────────────────────────────────────────────

while (( $# )); do
    case $1 in
        -h|--help)
            printf 'Usage: %s [--verbose]\n--verbose exports LOG_LEVEL=DEBUG for child diagnostics.\n' "$0"
            exit 0;;
        -v|--verbose) export LOG_LEVEL=DEBUG; shift;;
        *) printf 'Unknown option: %s\n' "$1" >&2; exit 2;;
    esac
done
main
