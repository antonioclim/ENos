#!/bin/bash
#
# run_all_tests.sh - Runner for all Seminar 05 tests
# 
# Topic: Advanced Functions, Arrays, Robust Scripting, Logging, Debugging
# Course: Operating Systems | ASE Bucharest - CSIE
#

set -euo pipefail

#
# CONFIGURATION
#
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TESTS_PASSED=0
TESTS_FAILED=0
TESTS_SKIPPED=0

# Colours
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

#
# HELPER FUNCTIONS
#

print_header() {
    echo -e "${BLUE}"
    echo "═══════════════════════════════════════════════════════════════"
    echo "        SEMINAR 05 TESTS: Advanced Bash Scripting"
    echo "═══════════════════════════════════════════════════════════════"
    echo -e "${NC}"
}

print_summary() {
    echo ""
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo "                         SUMMARY"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "  ${GREEN}✓ Passed:${NC}  $TESTS_PASSED"
    echo -e "  ${RED}✗ Failed:${NC}  $TESTS_FAILED"
    echo -e "  ${YELLOW}○ Skipped:${NC} $TESTS_SKIPPED"
    echo ""
    
    local total=$((TESTS_PASSED + TESTS_FAILED))
    if [[ $total -gt 0 ]]; then
        local percentage=$((TESTS_PASSED * 100 / total))
        echo "  Score: $percentage% ($TESTS_PASSED/$total)"
    fi
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
}

run_test() {
    local test_name="$1"
    local test_file="$2"
    
    printf "  Testing: %-40s " "$test_name"
    
    if [[ ! -f "$test_file" ]]; then
        echo -e "${YELLOW}[SKIP]${NC} - File not found"
        ((TESTS_SKIPPED++))
        return
    fi
    
    if [[ ! -x "$test_file" ]]; then
        chmod +x "$test_file"
    fi
    
    if "$test_file" >/dev/null 2>&1; then
        echo -e "${GREEN}[PASS]${NC}"
        ((TESTS_PASSED++))
    else
        echo -e "${RED}[FAIL]${NC}"
        ((TESTS_FAILED++))
    fi
}

#
# MAIN
#

main() {
    print_header
    
    echo "Running tests from: $SCRIPT_DIR"
    echo ""
    
    echo -e "${YELLOW}--- Tests ---${NC}"
    
    run_test "Functions with params/return" "$SCRIPT_DIR/test_01_functions.sh"
    run_test "Indexed & Associative Arrays" "$SCRIPT_DIR/test_02_arrays.sh"
    run_test "Robust scripting (set -e, trap)" "$SCRIPT_DIR/test_03_robust.sh"
    run_test "Logging system" "$SCRIPT_DIR/test_04_logging.sh"
    run_test "Debugging (set -x, PS4)" "$SCRIPT_DIR/test_05_debug.sh"
    
    print_summary
    
    if [[ $TESTS_FAILED -gt 0 ]]; then
        exit 1
    fi
}

main "$@"
