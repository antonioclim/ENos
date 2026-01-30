# S06_05: Testing Framework for Bash Projects

## Introduction

Automated testing represents a fundamental pillar of modern software engineering, enabling systematic validation of application behaviour and early detection of regressions. In the context of shell programming, testing acquires specific nuances due to the interpreted nature of the language, close interaction with the operating system and inherent side effects of I/O operations.

This chapter explores the architecture of the testing framework implemented in CAPSTONE projects, illustrating xUnit principles adapted for Bash, test isolation techniques and mocking strategies for external dependencies.

---

## Testing Framework Architecture

### Test Directory Structure

Each CAPSTONE project follows a uniform convention for test organisation:

```
project/
├── tests/
│   ├── test_runner.sh        # Test execution orchestrator
│   ├── test_helpers.sh       # Auxiliary functions and assertions
│   ├── fixtures/             # Static test data
│   │   ├── sample_config.conf
│   │   ├── sample_data.txt
│   │   └── expected_output/
│   ├── mocks/                # Mock implementations
│   │   ├── mock_commands.sh
│   │   └── mock_filesystem.sh
│   ├── unit/                 # Unit tests
│   │   ├── test_core.sh
│   │   ├── test_utils.sh
│   │   └── test_config.sh
│   └── integration/          # Integration tests
│       ├── test_full_workflow.sh
│       └── test_error_scenarios.sh
```

The separation between unit and integration tests reflects validation granularity: unit tests verify individual functions in isolation, whilst integration tests validate complete end-to-end workflows.

---

## Test Runner: Execution Orchestration

### test_runner.sh Implementation

```bash
#!/bin/bash
#===============================================================================
# test_runner.sh - Testing framework for Bash projects
# Version: 2.0
# Inspired by: TAP (Test Anything Protocol), Bats, shUnit2
#===============================================================================

set -o pipefail

#-------------------------------------------------------------------------------
# Global state variables
#-------------------------------------------------------------------------------
declare -g TEST_DIR=""
declare -g TEST_TEMP_DIR=""
declare -g TESTS_RUN=0
declare -g TESTS_PASSED=0
declare -g TESTS_FAILED=0
declare -g TESTS_SKIPPED=0
declare -g CURRENT_TEST=""
declare -g TEST_OUTPUT=""
declare -g VERBOSE=0
declare -g STOP_ON_FAILURE=0
declare -g TEST_TIMEOUT=30
declare -g FILTER_PATTERN=""

declare -ga FAILED_TESTS=()
declare -ga SKIPPED_TESTS=()

# Colours for output
declare -gr RED='\033[0;31m'
declare -gr GREEN='\033[0;32m'
declare -gr YELLOW='\033[0;33m'
declare -gr BLUE='\033[0;34m'
declare -gr CYAN='\033[0;36m'
declare -gr NC='\033[0m'

#-------------------------------------------------------------------------------
# Framework initialisation
#-------------------------------------------------------------------------------
test_framework_init() {
    TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    TEST_TEMP_DIR="${TMPDIR:-/tmp}/test_$$_$(date +%s)"
    
    mkdir -p "$TEST_TEMP_DIR"
    
    # Load helpers
    if [[ -f "${TEST_DIR}/test_helpers.sh" ]]; then
        source "${TEST_DIR}/test_helpers.sh"
    fi
    
    # Trap for cleanup
    trap test_framework_cleanup EXIT
    trap 'test_framework_interrupt' INT TERM
}

test_framework_cleanup() {
    local exit_code=$?
    
    # Cleanup temporaries
    if [[ -d "$TEST_TEMP_DIR" ]]; then
        rm -rf "$TEST_TEMP_DIR"
    fi
    
    # Restore environment
    cd "$OLDPWD" 2>/dev/null || true
    
    return $exit_code
}

test_framework_interrupt() {
    echo -e "\n${YELLOW}Test execution interrupted${NC}"
    test_print_summary
    exit 130
}

#-------------------------------------------------------------------------------
# Test discovery and execution
#-------------------------------------------------------------------------------
discover_tests() {
    local test_type="${1:-all}"
    local -a test_files=()
    
    case "$test_type" in
        unit)
            test_files=("${TEST_DIR}"/unit/test_*.sh)
            ;;
        integration)
            test_files=("${TEST_DIR}"/integration/test_*.sh)
            ;;
        all|*)
            test_files=("${TEST_DIR}"/unit/test_*.sh "${TEST_DIR}"/integration/test_*.sh)
            ;;
    esac
    
    # Filter existing files
    local -a valid_files=()
    for file in "${test_files[@]}"; do
        if [[ -f "$file" ]]; then
            valid_files+=("$file")
        fi
    done
    
    printf '%s\n' "${valid_files[@]}"
}

discover_test_functions() {
    local test_file="$1"
    
    # Extract functions starting with "test_"
    grep -E '^[[:space:]]*(function[[:space:]]+)?test_[a-zA-Z0-9_]+[[:space:]]*\(\)' "$test_file" \
        | sed -E 's/^[[:space:]]*(function[[:space:]]+)?([a-zA-Z0-9_]+)\(\).*/\2/' \
        | sort
}

run_test_file() {
    local test_file="$1"
    local file_tests_run=0
    local file_tests_passed=0
    
    echo -e "\n${CYAN}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}  Test File: $(basename "$test_file")${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
    
    # Create subshell for isolation
    (
        # Load test file
        source "$test_file" || {
            echo -e "${RED}Failed to source test file: $test_file${NC}"
            exit 1
        }
        
        # Execute file-level setup (if exists)
        if declare -f setup_file >/dev/null 2>&1; then
            setup_file || {
                echo -e "${RED}setup_file failed${NC}"
                exit 1
            }
        fi
        
        # Discover and execute test functions
        local -a test_functions
        mapfile -t test_functions < <(discover_test_functions "$test_file")
        
        for test_func in "${test_functions[@]}"; do
            # Apply filter if specified
            if [[ -n "$FILTER_PATTERN" && ! "$test_func" =~ $FILTER_PATTERN ]]; then
                continue
            fi
            
            run_single_test "$test_func"
        done
        
        # Execute file-level teardown
        if declare -f teardown_file >/dev/null 2>&1; then
            teardown_file
        fi
    )
    
    return $?
}

run_single_test() {
    local test_func="$1"
    local start_time
    local end_time
    local duration
    local exit_code
    
    CURRENT_TEST="$test_func"
    ((TESTS_RUN++))
    
    # Per-test setup
    local test_workdir="${TEST_TEMP_DIR}/${test_func}"
    mkdir -p "$test_workdir"
    cd "$test_workdir" || return 1
    
    # Execute setup (if exists)
    if declare -f setup >/dev/null 2>&1; then
        setup 2>/dev/null || {
            test_skip "setup failed"
            return 0
        }
    fi
    
    # Capture output and execute with timeout
    start_time=$(date +%s%N)
    
    TEST_OUTPUT=$(timeout "$TEST_TIMEOUT" bash -c "
        set -e
        source '${TEST_DIR}/test_helpers.sh' 2>/dev/null || true
        $(declare -f "$test_func")
        $test_func
    " 2>&1)
    exit_code=$?
    
    end_time=$(date +%s%N)
    duration=$(( (end_time - start_time) / 1000000 ))  # ms
    
    # Per-test teardown
    if declare -f teardown >/dev/null 2>&1; then
        teardown 2>/dev/null || true
    fi
    
    # Evaluate result
    case $exit_code in
        0)
            ((TESTS_PASSED++))
            printf "${GREEN}  ✓${NC} %-50s ${BLUE}(%d ms)${NC}\n" "$test_func" "$duration"
            [[ $VERBOSE -eq 1 && -n "$TEST_OUTPUT" ]] && echo "    Output: $TEST_OUTPUT"
            ;;
        77)
            # Special code for skip
            ((TESTS_SKIPPED++))
            SKIPPED_TESTS+=("$test_func")
            printf "${YELLOW}  ⊘${NC} %-50s ${YELLOW}(skipped)${NC}\n" "$test_func"
            [[ -n "$TEST_OUTPUT" ]] && echo "    Reason: $TEST_OUTPUT"
            ;;
        124)
            # Timeout
            ((TESTS_FAILED++))
            FAILED_TESTS+=("$test_func (timeout)")
            printf "${RED}  ✗${NC} %-50s ${RED}(timeout after ${TEST_TIMEOUT}s)${NC}\n" "$test_func"
            ;;
        *)
            ((TESTS_FAILED++))
            FAILED_TESTS+=("$test_func")
            printf "${RED}  ✗${NC} %-50s ${RED}(exit code: $exit_code)${NC}\n" "$test_func"
            if [[ -n "$TEST_OUTPUT" ]]; then
                echo -e "${RED}    Error output:${NC}"
                echo "$TEST_OUTPUT" | sed 's/^/      /'
            fi
            
            if [[ $STOP_ON_FAILURE -eq 1 ]]; then
                echo -e "\n${RED}Stopping on first failure${NC}"
                exit 1
            fi
            ;;
    esac
    
    # Cleanup workdir
    cd "$TEST_TEMP_DIR"
    rm -rf "$test_workdir"
    
    return 0
}

#-------------------------------------------------------------------------------
# Results summarisation
#-------------------------------------------------------------------------------
test_print_summary() {
    local total_time
    
    echo -e "\n${CYAN}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}  TEST SUMMARY${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
    
    echo -e "  Total:   ${TESTS_RUN}"
    echo -e "  ${GREEN}Passed:  ${TESTS_PASSED}${NC}"
    echo -e "  ${RED}Failed:  ${TESTS_FAILED}${NC}"
    echo -e "  ${YELLOW}Skipped: ${TESTS_SKIPPED}${NC}"
    
    if [[ ${#FAILED_TESTS[@]} -gt 0 ]]; then
        echo -e "\n${RED}  Failed tests:${NC}"
        for test in "${FAILED_TESTS[@]}"; do
            echo -e "    ${RED}✗${NC} $test"
        done
    fi
    
    if [[ ${#SKIPPED_TESTS[@]} -gt 0 && $VERBOSE -eq 1 ]]; then
        echo -e "\n${YELLOW}  Skipped tests:${NC}"
        for test in "${SKIPPED_TESTS[@]}"; do
            echo -e "    ${YELLOW}⊘${NC} $test"
        done
    fi
    
    # Exit code based on results
    if [[ $TESTS_FAILED -gt 0 ]]; then
        echo -e "\n${RED}═══════════════════════════════════════════════════════════${NC}"
        echo -e "${RED}  TESTS FAILED${NC}"
        echo -e "${RED}═══════════════════════════════════════════════════════════${NC}"
        return 1
    else
        echo -e "\n${GREEN}═══════════════════════════════════════════════════════════${NC}"
        echo -e "${GREEN}  ALL TESTS PASSED${NC}"
        echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
        return 0
    fi
}

#-------------------------------------------------------------------------------
# Report generation
#-------------------------------------------------------------------------------
generate_report() {
    local format="${1:-text}"
    local output_file="${2:-}"
    
    case "$format" in
        tap)
            generate_tap_report "$output_file"
            ;;
        junit)
            generate_junit_report "$output_file"
            ;;
        json)
            generate_json_report "$output_file"
            ;;
        *)
            generate_text_report "$output_file"
            ;;
    esac
}

generate_tap_report() {
    local output="${1:-/dev/stdout}"
    
    {
        echo "TAP version 13"
        echo "1..${TESTS_RUN}"
        
        local i=1
        # Generated from stored results...
    } > "$output"
}

generate_junit_report() {
    local output="${1:-test-results.xml}"
    
    cat > "$output" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<testsuite name="CAPSTONE Tests" tests="${TESTS_RUN}" failures="${TESTS_FAILED}" skipped="${TESTS_SKIPPED}">
    <!-- Individual test cases would be inserted here -->
</testsuite>
EOF
}

#-------------------------------------------------------------------------------
# Main
#-------------------------------------------------------------------------------
main() {
    local test_type="all"
    local report_format=""
    local report_file=""
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -t|--type)
                test_type="$2"
                shift 2
                ;;
            -v|--verbose)
                VERBOSE=1
                shift
                ;;
            -f|--filter)
                FILTER_PATTERN="$2"
                shift 2
                ;;
            -s|--stop-on-failure)
                STOP_ON_FAILURE=1
                shift
                ;;
            --timeout)
                TEST_TIMEOUT="$2"
                shift 2
                ;;
            --report)
                report_format="$2"
                shift 2
                ;;
            --report-file)
                report_file="$2"
                shift 2
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            *)
                echo "Unknown option: $1"
                exit 1
                ;;
        esac
    done
    
    # Initialisation
    test_framework_init
    
    echo -e "${BLUE}╔═══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║           CAPSTONE TEST FRAMEWORK v2.0                    ║${NC}"
    echo -e "${BLUE}╚═══════════════════════════════════════════════════════════╝${NC}"
    echo -e "  Type: $test_type"
    [[ -n "$FILTER_PATTERN" ]] && echo -e "  Filter: $FILTER_PATTERN"
    echo ""
    
    # Discovery and execution
    local -a test_files
    mapfile -t test_files < <(discover_tests "$test_type")
    
    if [[ ${#test_files[@]} -eq 0 ]]; then
        echo -e "${YELLOW}No test files found${NC}"
        exit 0
    fi
    
    for file in "${test_files[@]}"; do
        run_test_file "$file" || true
    done
    
    # Summarisation
    test_print_summary
    local result=$?
    
    # Report generation
    if [[ -n "$report_format" ]]; then
        generate_report "$report_format" "$report_file"
    fi
    
    return $result
}

show_help() {
    cat <<'EOF'
CAPSTONE Test Framework v2.0

Usage: test_runner.sh [OPTIONS]

Options:
    -t, --type TYPE         Run specific test type: unit, integration, all
    -v, --verbose           Show verbose output including test stdout
    -f, --filter PATTERN    Run only tests matching regex pattern
    -s, --stop-on-failure   Stop execution on first failed test
    --timeout SECONDS       Timeout per test (default: 30)
    --report FORMAT         Generate report: tap, junit, json, text
    --report-file FILE      Output file for report
    -h, --help              Show this help

Examples:
    ./test_runner.sh                          # Run all tests
    ./test_runner.sh -t unit                  # Run only unit tests
    ./test_runner.sh -f "test_backup.*"       # Run tests matching pattern
    ./test_runner.sh -v --report junit        # Verbose + JUnit report
EOF
}

# Execution
main "$@"
```

---

## Test Helpers: The Assertions Library

### Assertions Philosophy

The assertions framework implements expressive semantics, allowing tests to be written in a declarative style that clearly expresses the validation intent. Each assertion:

1. Returns 0 for success, non-zero for failure
2. Produces descriptive output on failure
3. Supports optional custom messages

### test_helpers.sh Implementation

```bash
#!/bin/bash
#===============================================================================
# test_helpers.sh - Assertions and utilities for testing
#===============================================================================

#-------------------------------------------------------------------------------
# Basic assertions
#-------------------------------------------------------------------------------

# Assert that a condition is true
assert_true() {
    local condition="$1"
    local message="${2:-Assertion failed}"
    
    if eval "$condition"; then
        return 0
    else
        echo "ASSERT_TRUE FAILED: $message"
        echo "  Condition: $condition"
        return 1
    fi
}

# Assert that a condition is false
assert_false() {
    local condition="$1"
    local message="${2:-Assertion failed}"
    
    if ! eval "$condition"; then
        return 0
    else
        echo "ASSERT_FALSE FAILED: $message"
        echo "  Condition was true: $condition"
        return 1
    fi
}

# Assert exact equality (string comparison)
assert_equals() {
    local expected="$1"
    local actual="$2"
    local message="${3:-Values not equal}"
    
    if [[ "$expected" == "$actual" ]]; then
        return 0
    else
        echo "ASSERT_EQUALS FAILED: $message"
        echo "  Expected: '$expected'"
        echo "  Actual:   '$actual'"
        return 1
    fi
}

# Assert non-equality
assert_not_equals() {
    local unexpected="$1"
    local actual="$2"
    local message="${3:-Values should not be equal}"
    
    if [[ "$unexpected" != "$actual" ]]; then
        return 0
    else
        echo "ASSERT_NOT_EQUALS FAILED: $message"
        echo "  Both values: '$actual'"
        return 1
    fi
}

# Assert that string contains substring
assert_contains() {
    local haystack="$1"
    local needle="$2"
    local message="${3:-String does not contain expected substring}"
    
    if [[ "$haystack" == *"$needle"* ]]; then
        return 0
    else
        echo "ASSERT_CONTAINS FAILED: $message"
        echo "  String:   '$haystack'"
        echo "  Expected: '$needle'"
        return 1
    fi
}

# Assert that string does NOT contain substring
assert_not_contains() {
    local haystack="$1"
    local needle="$2"
    local message="${3:-String should not contain substring}"
    
    if [[ "$haystack" != *"$needle"* ]]; then
        return 0
    else
        echo "ASSERT_NOT_CONTAINS FAILED: $message"
        echo "  String contains forbidden: '$needle'"
        return 1
    fi
}

# Assert that string matches regex
assert_matches() {
    local string="$1"
    local pattern="$2"
    local message="${3:-String does not match pattern}"
    
    if [[ "$string" =~ $pattern ]]; then
        return 0
    else
        echo "ASSERT_MATCHES FAILED: $message"
        echo "  String:  '$string'"
        echo "  Pattern: '$pattern'"
        return 1
    fi
}

#-------------------------------------------------------------------------------
# Numeric assertions
#-------------------------------------------------------------------------------

assert_equals_numeric() {
    local expected="$1"
    local actual="$2"
    local message="${3:-Numeric values not equal}"
    
    if (( expected == actual )); then
        return 0
    else
        echo "ASSERT_EQUALS_NUMERIC FAILED: $message"
        echo "  Expected: $expected"
        echo "  Actual:   $actual"
        return 1
    fi
}

assert_greater_than() {
    local value="$1"
    local threshold="$2"
    local message="${3:-Value not greater than threshold}"
    
    if (( value > threshold )); then
        return 0
    else
        echo "ASSERT_GREATER_THAN FAILED: $message"
        echo "  Value:     $value"
        echo "  Threshold: $threshold"
        return 1
    fi
}

assert_less_than() {
    local value="$1"
    local threshold="$2"
    local message="${3:-Value not less than threshold}"
    
    if (( value < threshold )); then
        return 0
    else
        echo "ASSERT_LESS_THAN FAILED: $message"
        echo "  Value:     $value"
        echo "  Threshold: $threshold"
        return 1
    fi
}

assert_in_range() {
    local value="$1"
    local min="$2"
    local max="$3"
    local message="${4:-Value not in expected range}"
    
    if (( value >= min && value <= max )); then
        return 0
    else
        echo "ASSERT_IN_RANGE FAILED: $message"
        echo "  Value: $value"
        echo "  Range: [$min, $max]"
        return 1
    fi
}

#-------------------------------------------------------------------------------
# File and directory assertions
#-------------------------------------------------------------------------------

assert_file_exists() {
    local filepath="$1"
    local message="${2:-File does not exist}"
    
    if [[ -f "$filepath" ]]; then
        return 0
    else
        echo "ASSERT_FILE_EXISTS FAILED: $message"
        echo "  Path: $filepath"
        return 1
    fi
}

assert_file_not_exists() {
    local filepath="$1"
    local message="${2:-File should not exist}"
    
    if [[ ! -f "$filepath" ]]; then
        return 0
    else
        echo "ASSERT_FILE_NOT_EXISTS FAILED: $message"
        echo "  Path exists: $filepath"
        return 1
    fi
}

assert_dir_exists() {
    local dirpath="$1"
    local message="${2:-Directory does not exist}"
    
    if [[ -d "$dirpath" ]]; then
        return 0
    else
        echo "ASSERT_DIR_EXISTS FAILED: $message"
        echo "  Path: $dirpath"
        return 1
    fi
}

assert_file_contains() {
    local filepath="$1"
    local content="$2"
    local message="${3:-File does not contain expected content}"
    
    if [[ ! -f "$filepath" ]]; then
        echo "ASSERT_FILE_CONTAINS FAILED: File does not exist"
        echo "  Path: $filepath"
        return 1
    fi
    
    if grep -qF "$content" "$filepath"; then
        return 0
    else
        echo "ASSERT_FILE_CONTAINS FAILED: $message"
        echo "  File: $filepath"
        echo "  Expected content: $content"
        return 1
    fi
}

assert_file_empty() {
    local filepath="$1"
    local message="${2:-File is not empty}"
    
    if [[ ! -s "$filepath" ]]; then
        return 0
    else
        echo "ASSERT_FILE_EMPTY FAILED: $message"
        echo "  File has $(wc -c < "$filepath") bytes"
        return 1
    fi
}

assert_file_not_empty() {
    local filepath="$1"
    local message="${2:-File is empty}"
    
    if [[ -s "$filepath" ]]; then
        return 0
    else
        echo "ASSERT_FILE_NOT_EMPTY FAILED: $message"
        echo "  Path: $filepath"
        return 1
    fi
}

assert_file_permissions() {
    local filepath="$1"
    local expected_perms="$2"
    local message="${3:-File permissions mismatch}"
    
    local actual_perms
    actual_perms=$(stat -c '%a' "$filepath" 2>/dev/null)
    
    if [[ "$actual_perms" == "$expected_perms" ]]; then
        return 0
    else
        echo "ASSERT_FILE_PERMISSIONS FAILED: $message"
        echo "  Expected: $expected_perms"
        echo "  Actual:   $actual_perms"
        return 1
    fi
}

#-------------------------------------------------------------------------------
# Exit code and command assertions
#-------------------------------------------------------------------------------

assert_success() {
    local command="$1"
    local message="${2:-Command failed}"
    
    if eval "$command" >/dev/null 2>&1; then
        return 0
    else
        local exit_code=$?
        echo "ASSERT_SUCCESS FAILED: $message"
        echo "  Command: $command"
        echo "  Exit code: $exit_code"
        return 1
    fi
}

assert_fails() {
    local command="$1"
    local message="${2:-Command should have failed}"
    
    if ! eval "$command" >/dev/null 2>&1; then
        return 0
    else
        echo "ASSERT_FAILS FAILED: $message"
        echo "  Command succeeded: $command"
        return 1
    fi
}

assert_exit_code() {
    local expected="$1"
    local command="$2"
    local message="${3:-Exit code mismatch}"
    
    eval "$command" >/dev/null 2>&1
    local actual=$?
    
    if [[ "$actual" -eq "$expected" ]]; then
        return 0
    else
        echo "ASSERT_EXIT_CODE FAILED: $message"
        echo "  Expected: $expected"
        echo "  Actual:   $actual"
        echo "  Command:  $command"
        return 1
    fi
}

assert_output_equals() {
    local expected="$1"
    local command="$2"
    local message="${3:-Output mismatch}"
    
    local actual
    actual=$(eval "$command" 2>&1)
    
    if [[ "$actual" == "$expected" ]]; then
        return 0
    else
        echo "ASSERT_OUTPUT_EQUALS FAILED: $message"
        echo "  Expected: '$expected'"
        echo "  Actual:   '$actual'"
        return 1
    fi
}

assert_output_contains() {
    local expected="$1"
    local command="$2"
    local message="${3:-Output does not contain expected}"
    
    local actual
    actual=$(eval "$command" 2>&1)
    
    if [[ "$actual" == *"$expected"* ]]; then
        return 0
    else
        echo "ASSERT_OUTPUT_CONTAINS FAILED: $message"
        echo "  Expected to contain: '$expected'"
        echo "  Actual output: '$actual'"
        return 1
    fi
}

assert_stderr_contains() {
    local expected="$1"
    local command="$2"
    local message="${3:-Stderr does not contain expected}"
    
    local stderr_output
    stderr_output=$(eval "$command" 2>&1 1>/dev/null)
    
    if [[ "$stderr_output" == *"$expected"* ]]; then
        return 0
    else
        echo "ASSERT_STDERR_CONTAINS FAILED: $message"
        echo "  Expected: '$expected'"
        echo "  Stderr:   '$stderr_output'"
        return 1
    fi
}

#-------------------------------------------------------------------------------
# Array assertions
#-------------------------------------------------------------------------------

assert_array_contains() {
    local -n arr="$1"
    local element="$2"
    local message="${3:-Array does not contain element}"
    
    local item
    for item in "${arr[@]}"; do
        if [[ "$item" == "$element" ]]; then
            return 0
        fi
    done
    
    echo "ASSERT_ARRAY_CONTAINS FAILED: $message"
    echo "  Looking for: '$element'"
    echo "  Array: (${arr[*]})"
    return 1
}

assert_array_length() {
    local -n arr="$1"
    local expected_length="$2"
    local message="${3:-Array length mismatch}"
    
    local actual_length="${#arr[@]}"
    
    if [[ "$actual_length" -eq "$expected_length" ]]; then
        return 0
    else
        echo "ASSERT_ARRAY_LENGTH FAILED: $message"
        echo "  Expected: $expected_length"
        echo "  Actual:   $actual_length"
        return 1
    fi
}

#-------------------------------------------------------------------------------
# Test helper utilities
#-------------------------------------------------------------------------------

# Skip test with reason
test_skip() {
    local reason="${1:-No reason provided}"
    echo "$reason"
    exit 77
}

# Explicit fail
test_fail() {
    local message="${1:-Test failed}"
    echo "TEST_FAIL: $message"
    return 1
}

# Create temporary file for test
create_temp_file() {
    local content="${1:-}"
    local filename="${2:-test_file_$$}"
    
    local filepath="${TEST_TEMP_DIR}/${filename}"
    echo -n "$content" > "$filepath"
    echo "$filepath"
}

# Create temporary directory for test
create_temp_dir() {
    local dirname="${1:-test_dir_$$}"
    
    local dirpath="${TEST_TEMP_DIR}/${dirname}"
    mkdir -p "$dirpath"
    echo "$dirpath"
}

# Mock for command
mock_command() {
    local cmd_name="$1"
    local mock_output="$2"
    local mock_exit_code="${3:-0}"
    
    # Create mock script in temporary PATH
    local mock_dir="${TEST_TEMP_DIR}/mocks"
    mkdir -p "$mock_dir"
    
    cat > "${mock_dir}/${cmd_name}" <<EOF
#!/bin/bash
echo "$mock_output"
exit $mock_exit_code
EOF
    chmod +x "${mock_dir}/${cmd_name}"
    
    # Add to beginning of PATH
    export PATH="${mock_dir}:$PATH"
}

# Restore original command (remove mock)
unmock_command() {
    local cmd_name="$1"
    rm -f "${TEST_TEMP_DIR}/mocks/${cmd_name}"
}

# Capture output with stdout/stderr separation
capture_output() {
    local command="$1"
    local -n stdout_var="$2"
    local -n stderr_var="$3"
    local -n exit_var="$4"
    
    local tmp_stdout tmp_stderr
    tmp_stdout=$(mktemp)
    tmp_stderr=$(mktemp)
    
    eval "$command" > "$tmp_stdout" 2> "$tmp_stderr"
    exit_var=$?
    
    stdout_var=$(<"$tmp_stdout")
    stderr_var=$(<"$tmp_stderr")
    
    rm -f "$tmp_stdout" "$tmp_stderr"
}

# Verify dependency (skip if missing)
require_command() {
    local cmd="$1"
    
    if ! command -v "$cmd" >/dev/null 2>&1; then
        test_skip "Required command not available: $cmd"
    fi
}

# Verify that we're running as root
require_root() {
    if [[ $EUID -ne 0 ]]; then
        test_skip "Test requires root privileges"
    fi
}

# Verify that we're NOT running as root
require_non_root() {
    if [[ $EUID -eq 0 ]]; then
        test_skip "Test must not run as root"
    fi
}
```

---

## Unit Test Examples

### Test for Monitor Core

```bash
#!/bin/bash
# tests/unit/test_monitor_core.sh

source "$(dirname "$0")/../test_helpers.sh"
source "$(dirname "$0")/../../lib/monitor_core.sh"

#-------------------------------------------------------------------------------
# Setup and Teardown
#-------------------------------------------------------------------------------
setup() {
    # Create mock for /proc/stat
    MOCK_PROC_STAT=$(create_temp_file "cpu  1000 200 500 8000 100 50 30 0 0 0
cpu0 500 100 250 4000 50 25 15 0 0 0
cpu1 500 100 250 4000 50 25 15 0 0 0")
}

teardown() {
    rm -f "$MOCK_PROC_STAT"
}

#-------------------------------------------------------------------------------
# Tests for get_cpu_usage
#-------------------------------------------------------------------------------
test_get_cpu_usage_returns_valid_percentage() {
    # Arrange
    local result
    
    # Act
    result=$(get_cpu_usage)
    
    # Assert
    assert_matches "$result" '^[0-9]+(\.[0-9]+)?$' \
        "CPU usage should be a valid number"
    assert_in_range "${result%.*}" 0 100 \
        "CPU usage should be between 0 and 100"
}

test_get_cpu_usage_per_core_returns_array() {
    # Arrange
    local -a results
    
    # Act
    mapfile -t results < <(get_cpu_usage_per_core)
    
    # Assert
    assert_greater_than "${#results[@]}" 0 \
        "Should return at least one core"
}

#-------------------------------------------------------------------------------
# Tests for get_memory_info
#-------------------------------------------------------------------------------
test_get_memory_info_returns_all_fields() {
    # Act
    local output
    output=$(get_memory_info)
    
    # Assert
    assert_contains "$output" "total" "Should contain total memory"
    assert_contains "$output" "used" "Should contain used memory"
    assert_contains "$output" "free" "Should contain free memory"
    assert_contains "$output" "available" "Should contain available memory"
}

test_get_memory_percentage_valid_range() {
    # Act
    local percentage
    percentage=$(get_memory_percentage)
    
    # Assert
    assert_in_range "${percentage%.*}" 0 100 \
        "Memory percentage should be 0-100"
}

#-------------------------------------------------------------------------------
# Tests for parse_proc_stat
#-------------------------------------------------------------------------------
test_parse_proc_stat_extracts_cpu_times() {
    # Arrange
    local proc_stat="cpu  1000 200 500 8000 100 50 30 0 0 0"
    
    # Act
    local -a times
    IFS=' ' read -ra times <<< "${proc_stat#cpu  }"
    
    # Assert
    assert_equals_numeric 1000 "${times[0]}" "User time"
    assert_equals_numeric 200 "${times[1]}" "Nice time"
    assert_equals_numeric 500 "${times[2]}" "System time"
    assert_equals_numeric 8000 "${times[3]}" "Idle time"
}

#-------------------------------------------------------------------------------
# Tests for alerting
#-------------------------------------------------------------------------------
test_check_threshold_triggers_alert() {
    # Arrange
    local value=95
    local threshold=90
    local metric="cpu"
    
    # Act & Assert
    assert_true "[[ $value -gt $threshold ]]" \
        "Value $value should exceed threshold $threshold"
}

test_check_threshold_no_alert_when_below() {
    # Arrange
    local value=50
    local threshold=90
    
    # Act & Assert
    assert_false "[[ $value -gt $threshold ]]" \
        "Value $value should not exceed threshold $threshold"
}

#-------------------------------------------------------------------------------
# Tests for output formatting
#-------------------------------------------------------------------------------
test_format_bytes_converts_correctly() {
    # Test cases: bytes -> expected output
    assert_equals "1.00 KB" "$(format_bytes 1024)"
    assert_equals "1.00 MB" "$(format_bytes 1048576)"
    assert_equals "1.00 GB" "$(format_bytes 1073741824)"
}

test_format_json_valid_structure() {
    # Arrange
    local output
    
    # Act
    output=$(format_output_json)
    
    # Assert
    # Verify that output is valid JSON
    if command -v jq >/dev/null 2>&1; then
        assert_success "echo '$output' | jq . >/dev/null" \
            "Output should be valid JSON"
    else
        test_skip "jq not available for JSON validation"
    fi
}
```

### Test for Backup Core

```bash
#!/bin/bash
# tests/unit/test_backup_core.sh

source "$(dirname "$0")/../test_helpers.sh"

# Load tested module
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "${SCRIPT_DIR}/lib/backup_core.sh"

#-------------------------------------------------------------------------------
# Global setup
#-------------------------------------------------------------------------------
setup_file() {
    export TEST_BACKUP_DIR="${TEST_TEMP_DIR}/backup_tests"
    mkdir -p "$TEST_BACKUP_DIR"/{source,dest}
    
    # Create test files
    echo "test content 1" > "${TEST_BACKUP_DIR}/source/file1.txt"
    echo "test content 2" > "${TEST_BACKUP_DIR}/source/file2.txt"
    mkdir -p "${TEST_BACKUP_DIR}/source/subdir"
    echo "nested content" > "${TEST_BACKUP_DIR}/source/subdir/nested.txt"
}

teardown_file() {
    rm -rf "$TEST_BACKUP_DIR"
}

#-------------------------------------------------------------------------------
# Tests for create_archive
#-------------------------------------------------------------------------------
test_create_archive_creates_tarball() {
    # Arrange
    local source_dir="${TEST_BACKUP_DIR}/source"
    local dest_dir="${TEST_BACKUP_DIR}/dest"
    local archive_name="test_backup"
    
    # Act
    create_archive "$source_dir" "$dest_dir" "$archive_name" "gzip"
    
    # Assert
    assert_file_exists "${dest_dir}/${archive_name}.tar.gz" \
        "Archive should be created"
}

test_create_archive_with_different_compression() {
    local source_dir="${TEST_BACKUP_DIR}/source"
    local dest_dir="${TEST_BACKUP_DIR}/dest"
    
    # Test gzip
    create_archive "$source_dir" "$dest_dir" "test_gzip" "gzip"
    assert_file_exists "${dest_dir}/test_gzip.tar.gz"
    
    # Test bzip2
    create_archive "$source_dir" "$dest_dir" "test_bzip2" "bzip2"
    assert_file_exists "${dest_dir}/test_bzip2.tar.bz2"
    
    # Test xz (if available)
    if command -v xz >/dev/null 2>&1; then
        create_archive "$source_dir" "$dest_dir" "test_xz" "xz"
        assert_file_exists "${dest_dir}/test_xz.tar.xz"
    fi
}

test_create_archive_preserves_structure() {
    # Arrange
    local source_dir="${TEST_BACKUP_DIR}/source"
    local dest_dir="${TEST_BACKUP_DIR}/dest"
    local extract_dir="${TEST_BACKUP_DIR}/extract"
    mkdir -p "$extract_dir"
    
    # Act
    create_archive "$source_dir" "$dest_dir" "structure_test" "gzip"
    tar -xzf "${dest_dir}/structure_test.tar.gz" -C "$extract_dir"
    
    # Assert
    assert_file_exists "${extract_dir}/file1.txt"
    assert_file_exists "${extract_dir}/subdir/nested.txt"
}

#-------------------------------------------------------------------------------
# Tests for exclude patterns
#-------------------------------------------------------------------------------
test_create_exclude_file_generates_valid_patterns() {
    # Arrange
    local -a patterns=("*.log" "*.tmp" "cache/")
    local exclude_file
    
    # Act
    exclude_file=$(create_exclude_file "${patterns[@]}")
    
    # Assert
    assert_file_exists "$exclude_file"
    assert_file_contains "$exclude_file" "*.log"
    assert_file_contains "$exclude_file" "*.tmp"
    assert_file_contains "$exclude_file" "cache/"
}

test_backup_excludes_patterns() {
    # Arrange
    local source_dir="${TEST_BACKUP_DIR}/source"
    echo "log content" > "${source_dir}/test.log"
    
    local -a exclude=("*.log")
    
    # Act
    create_archive "$source_dir" "${TEST_BACKUP_DIR}/dest" "exclude_test" "gzip" \
        --exclude-from=<(printf '%s\n' "${exclude[@]}")
    
    # Extract and verify
    local extract_dir="${TEST_BACKUP_DIR}/extract_exclude"
    mkdir -p "$extract_dir"
    tar -xzf "${TEST_BACKUP_DIR}/dest/exclude_test.tar.gz" -C "$extract_dir"
    
    # Assert
    assert_file_not_exists "${extract_dir}/test.log" \
        "Excluded file should not be in archive"
}

#-------------------------------------------------------------------------------
# Tests for integrity verification
#-------------------------------------------------------------------------------
test_generate_checksum_creates_valid_hash() {
    # Arrange
    local test_file="${TEST_BACKUP_DIR}/source/file1.txt"
    
    # Act
    local checksum
    checksum=$(generate_checksum "$test_file" "sha256")
    
    # Assert
    assert_matches "$checksum" '^[a-f0-9]{64}$' \
        "SHA256 should be 64 hex characters"
}

test_verify_checksum_detects_corruption() {
    # Arrange
    local test_file="${TEST_BACKUP_DIR}/source/file1.txt"
    local correct_checksum
    correct_checksum=$(sha256sum "$test_file" | cut -d' ' -f1)
    local wrong_checksum="0000000000000000000000000000000000000000000000000000000000000000"
    
    # Assert
    assert_success "verify_checksum '$test_file' '$correct_checksum' 'sha256'" \
        "Correct checksum should verify"
    assert_fails "verify_checksum '$test_file' '$wrong_checksum' 'sha256'" \
        "Wrong checksum should fail"
}

#-------------------------------------------------------------------------------
# Tests for rotation
#-------------------------------------------------------------------------------
test_apply_rotation_keeps_correct_count() {
    # Arrange
    local backup_dir="${TEST_BACKUP_DIR}/rotation"
    mkdir -p "$backup_dir"
    
    # Create 5 backups
    for i in {1..5}; do
        touch -d "$i days ago" "${backup_dir}/backup_${i}.tar.gz"
    done
    
    # Act - keep only 3
    apply_rotation "$backup_dir" 3 "*.tar.gz"
    
    # Assert
    local count
    count=$(find "$backup_dir" -name "*.tar.gz" | wc -l)
    assert_equals_numeric 3 "$count" "Should keep only 3 backups"
}
```

---

## Mocking and Isolation

### Mocking Techniques in Bash

Mocking in Bash involves temporarily replacing commands or functions with controlled implementations:

```bash
#!/bin/bash
# tests/mocks/mock_commands.sh

#-------------------------------------------------------------------------------
# Mock for external commands
#-------------------------------------------------------------------------------

# Mock curl for testing without network
mock_curl() {
    local mock_response="$1"
    local mock_exit_code="${2:-0}"
    
    # Save original function
    if declare -f curl >/dev/null 2>&1; then
        eval "original_curl() { $(declare -f curl | tail -n +2); }"
    fi
    
    # Define mock
    curl() {
        echo "$mock_response"
        return "$mock_exit_code"
    }
    export -f curl
}

unmock_curl() {
    if declare -f original_curl >/dev/null 2>&1; then
        eval "curl() { $(declare -f original_curl | tail -n +2); }"
    else
        unset -f curl
    fi
}

# Mock for systemctl
mock_systemctl() {
    local service_status="${1:-active}"
    
    systemctl() {
        local cmd="$1"
        local service="$2"
        
        case "$cmd" in
            status)
                echo "● ${service}.service - Mock Service"
                echo "   Active: ${service_status}"
                [[ "$service_status" == "active" ]] && return 0 || return 3
                ;;
            is-active)
                [[ "$service_status" == "active" ]] && echo "active" || echo "inactive"
                [[ "$service_status" == "active" ]] && return 0 || return 3
                ;;
            start|stop|restart)
                return 0
                ;;
        esac
    }
    export -f systemctl
}

#-------------------------------------------------------------------------------
# Mock for filesystem
#-------------------------------------------------------------------------------

# Simulate limited disk space
mock_disk_space() {
    local available_kb="$1"
    
    df() {
        local path="${!#}"  # Last argument
        echo "Filesystem     1K-blocks    Used Available Use% Mounted on"
        echo "/dev/mock      10000000 5000000  ${available_kb}  50% ${path}"
    }
    export -f df
}

# Mock /proc/meminfo
create_mock_meminfo() {
    local total_kb="$1"
    local free_kb="$2"
    local available_kb="$3"
    
    cat <<EOF
MemTotal:       ${total_kb} kB
MemFree:        ${free_kb} kB
MemAvailable:   ${available_kb} kB
Buffers:        100000 kB
Cached:         500000 kB
SwapTotal:      2000000 kB
SwapFree:       2000000 kB
EOF
}

#-------------------------------------------------------------------------------
# Mock for processes
#-------------------------------------------------------------------------------

# Mock ps for process monitoring testing
mock_ps() {
    local -a processes=("$@")
    
    ps() {
        echo "  PID TTY          TIME CMD"
        for proc in "${processes[@]}"; do
            echo "$proc"
        done
    }
    export -f ps
}

# Mock pgrep
mock_pgrep() {
    local -a matching_pids=("$@")
    
    pgrep() {
        printf '%s\n' "${matching_pids[@]}"
        [[ ${#matching_pids[@]} -gt 0 ]] && return 0 || return 1
    }
    export -f pgrep
}
```

### Integration Test with Mocking

```bash
#!/bin/bash
# tests/integration/test_monitor_integration.sh

source "$(dirname "$0")/../test_helpers.sh"
source "$(dirname "$0")/../mocks/mock_commands.sh"

#-------------------------------------------------------------------------------
# Complete monitoring workflow test
#-------------------------------------------------------------------------------
test_monitor_full_cycle() {
    # Arrange - Setup mocks
    create_mock_meminfo 8000000 2000000 4000000 > /tmp/mock_meminfo
    export PROC_MEMINFO="/tmp/mock_meminfo"
    
    mock_disk_space 5000000
    
    # Act - Run monitor
    local output
    output=$(./monitor.sh --once --format json 2>&1)
    
    # Assert
    assert_contains "$output" '"memory"' "Output should contain memory data"
    assert_contains "$output" '"disk"' "Output should contain disk data"
    
    # Cleanup
    rm -f /tmp/mock_meminfo
}

test_monitor_threshold_alerting() {
    # Arrange - Simulate high CPU
    mock_cpu_high() {
        echo "95.5"
    }
    export -f get_cpu_usage
    get_cpu_usage() { mock_cpu_high; }
    
    # Act
    local output
    output=$(./monitor.sh --once --alert-cpu 90 2>&1)
    
    # Assert
    assert_contains "$output" "ALERT" "Should trigger CPU alert"
    assert_contains "$output" "threshold" "Should mention threshold"
}

test_monitor_output_to_file() {
    # Arrange
    local output_file="${TEST_TEMP_DIR}/monitor_output.log"
    
    # Act
    ./monitor.sh --once --output "$output_file"
    
    # Assert
    assert_file_exists "$output_file"
    assert_file_not_empty "$output_file"
}
```

---

## Test-Driven Development (TDD) in Bash

### The Red-Green-Refactor Cycle

TDD methodology can also be applied in Bash development:

1. **Red**: Write the failing test
2. **Green**: Implement the minimum code to pass the test
3. **Refactor**: Improve the code whilst keeping tests green

### TDD Example: Implementing a Validation Function

```bash
# Step 1: RED - Test for non-existent function
test_validate_ip_accepts_valid_ipv4() {
    assert_success "validate_ip '192.168.1.1'" \
        "Should accept valid IPv4"
}

test_validate_ip_rejects_invalid() {
    assert_fails "validate_ip '999.999.999.999'" \
        "Should reject invalid IP"
    assert_fails "validate_ip 'not-an-ip'" \
        "Should reject non-IP string"
}

# Step 2: GREEN - Minimum implementation
validate_ip() {
    local ip="$1"
    local regex='^([0-9]{1,3}\.){3}[0-9]{1,3}$'
    
    if [[ ! $ip =~ $regex ]]; then
        return 1
    fi
    
    local IFS='.'
    read -ra octets <<< "$ip"
    
    for octet in "${octets[@]}"; do
        if (( octet > 255 )); then
            return 1
        fi
    done
    
    return 0
}

# Step 3: REFACTOR - Add IPv6 support
validate_ip() {
    local ip="$1"
    local ipv4_regex='^([0-9]{1,3}\.){3}[0-9]{1,3}$'
    local ipv6_regex='^([0-9a-fA-F]{1,4}:){7}[0-9a-fA-F]{1,4}$'
    
    # ... extended implementation
}
```

---

## Practical Exercises

### Exercise 1: Implement Test Suite for Config Parser

Create a complete test set for a configuration parser:

```bash
# tests/unit/test_config_parser.sh

test_parse_config_reads_key_value() {
    # Implement test for reading key=value
}

test_parse_config_handles_comments() {
    # Test that lines with # are ignored
}

test_parse_config_handles_empty_lines() {
    # Test for empty lines
}

test_parse_config_handles_quoted_values() {
    # Test for values in quotes
}
```

### Exercise 2: Complex Mock for Network Operations

Implement a mocking system for network operations:

```bash
# Requirements:
# - Mock for ping with simulated latency
# - Mock for curl with configurable HTTP responses
# - Mock for wget with simulated download
# - Support for network error simulation
```

### Exercise 3: Coverage Report Generation

Implement a simple code coverage measurement mechanism:

```bash
# Requirements:
# - Identify functions defined in script
# - Track functions called in tests
# - Generate report with coverage percentage
```

### Exercise 4: Parallel Test Execution

Extend the test runner for parallel execution:

```bash
# Requirements:
# - Option --parallel N for N workers
# - Correct isolation between parallel tests
# - Result aggregation from all workers
```

### Exercise 5: Test Fixtures and Data Builders

Create a reusable fixtures system:

```bash
# Requirements:
# - Builder pattern for test data creation
# - Fixtures for complex structures (directories, configurations)
# - Automatic post-test cleanup
```

---

## Additional Resources

### Recommended Tools

1. **Bats** (Bash Automated Testing System) - Mature framework for Bash testing
2. **shUnit2** - JUnit port for shell scripts
3. **shellcheck** - Linter for error detection in scripts
4. **kcov** - Coverage tool for Bash

### Best Practices

1. **Complete isolation**: Each test must be independent
2. **Descriptive names**: `test_when_condition_then_expected_result`
3. **Arrange-Act-Assert**: Clear structure for each test
4. **Fast feedback**: Tests must run quickly
5. **Determinism**: Same result on every run
