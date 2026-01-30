#!/bin/bash
#
# run_all_tests.sh - Runner for all Seminar 01 tests
# 
# Topic: Shell Basics, Quoting, Variables, FHS, Globbing
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
NC='\033[0m' # No Color

#
# HELPER FUNCTIONS
#

print_header() {
    echo -e "${BLUE}"
    echo "═══════════════════════════════════════════════════════════════"
    echo "              TESTS SEMINAR 01: Shell Basics"
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
    
    # Available tests
    echo -e "${YELLOW}--- Tests ---${NC}"
    
    run_test "Shell Basics" "$SCRIPT_DIR/test_01_shell_basics.sh"
    run_test "Quoting" "$SCRIPT_DIR/test_02_quoting.sh"
    run_test "Variables" "$SCRIPT_DIR/test_03_variabile.sh"
    run_test "Globbing" "$SCRIPT_DIR/test_04_globbing.sh"
    
    print_summary
    
    # Exit code based on results
    if [[ $TESTS_FAILED -gt 0 ]]; then
        exit 1
    fi
}

main "$@"
