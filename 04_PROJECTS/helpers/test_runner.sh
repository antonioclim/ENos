#!/bin/bash
#===============================================================================
# NAME:        test_runner.sh
# DESCRIPTION: Discovers and runs automated tests for OS projects
# AUTHOR:      OS Kit - ASE CSIE
# VERSION:     1.1.0
#
# USAGE:       ./test_runner.sh [options] <tests_dir>
#
# OPTIONS:
#   -h, --help        Display help message
#   -v, --verbose     Show detailed output from each test
#   -s, --stop        Stop execution at first failure
#   -p, --pattern PAT Run only tests matching pattern (default: test_*.sh)
#
# EXIT CODES:
#   0 - All tests passed
#   1 - One or more tests failed
#
# EXAMPLES:
#   ./test_runner.sh ./tests
#   ./test_runner.sh -v ./tests
#   ./test_runner.sh -p "test_main*" ./tests
#   ./test_runner.sh --stop-on-fail ./tests
#===============================================================================

set -euo pipefail

# shellcheck disable=SC2034  # Unused variables are intentional (colours)

# Colours for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m'

# Counters
TOTAL=0
PASSED=0
FAILED=0

usage() {
    cat << EOF
Usage: $(basename "$0") [options] <tests_dir>

Runs all tests in a directory.

Options:
  -h, --help        Display help
  -v, --verbose     Detailed output
  -s, --stop        Stop at first failure
  -p, --pattern PAT Run only tests matching pattern

Examples:
  $(basename "$0") ./tests
  $(basename "$0") -v ./tests
  $(basename "$0") -p "test_main*" ./tests
EOF
}

VERBOSE=false
STOP_ON_FAIL=false
PATTERN="test_*.sh"

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help) usage; exit 0 ;;
        -v|--verbose) VERBOSE=true; shift ;;
        -s|--stop) STOP_ON_FAIL=true; shift ;;
        -p|--pattern) PATTERN="$2"; shift 2 ;;
        *) TESTS_DIR="$1"; shift ;;
    esac
done

[[ -z "${TESTS_DIR:-}" ]] && { usage; exit 1; }
[[ ! -d "$TESTS_DIR" ]] && { echo "Error: '$TESTS_DIR' does not exist"; exit 1; }

echo "╔══════════════════════════════════════════════╗"
echo "║        TEST RUNNER - OS ASE CSIE             ║"
echo "╚══════════════════════════════════════════════╝"
echo ""
echo "Tests directory: $TESTS_DIR"
echo "Pattern: $PATTERN"
echo ""
echo "════════════════════════════════════════"

# Find and run tests
while IFS= read -r test_file; do
    [[ -z "$test_file" ]] && continue
    
    test_name=$(basename "$test_file")
    ((TOTAL++))
    
    echo -ne "${CYAN}Running:${NC} $test_name ... "
    
    # Run test and capture output
    set +e
    if $VERBOSE; then
        output=$(bash "$test_file" 2>&1)
        exit_code=$?
        echo ""
        echo "$output"
    else
        output=$(bash "$test_file" 2>&1)
        exit_code=$?
    fi
    set -e
    
    if [[ $exit_code -eq 0 ]]; then
        echo -e "${GREEN}PASSED${NC}"
        ((PASSED++))
    else
        echo -e "${RED}FAILED${NC}"
        ((FAILED++))
        if ! $VERBOSE; then
            echo "  Output: ${output:0:100}..."
        fi
        if $STOP_ON_FAIL; then
            echo ""
            echo -e "${RED}Stopping at first failure.${NC}"
            break
        fi
    fi
done < <(find "$TESTS_DIR" -name "$PATTERN" -type f | sort)

# Summary
echo ""
echo "════════════════════════════════════════"
echo "TEST SUMMARY"
echo "════════════════════════════════════════"
echo -e "  Total:   $TOTAL"
echo -e "  ${GREEN}Passed:${NC}  $PASSED"
echo -e "  ${RED}Failed:${NC}  $FAILED"

if [[ $TOTAL -gt 0 ]]; then
    PERCENT=$((PASSED * 100 / TOTAL))
    echo "  Rate:    $PERCENT%"
fi

echo "════════════════════════════════════════"

# Exit code based on results
[[ $FAILED -eq 0 ]] && exit 0 || exit 1
