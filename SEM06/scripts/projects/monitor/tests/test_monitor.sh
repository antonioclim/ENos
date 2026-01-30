#!/bin/bash
#==============================================================================
# test_monitor.sh - Test suite for System Monitor
#==============================================================================
# DESCRIPTION:
#   Unit and integration tests for the System Monitor application.
#   Verifies functionality of all components: core, utils, config.
#
# USAGE:
#   ./tests/test_monitor.sh           # Run all tests
#   ./tests/test_monitor.sh -v        # Verbose mode
#   ./tests/test_monitor.sh core      # Only tests for core.sh
#
# AUTHOR: ASE Bucharest - CSIE | Operating Systems
# VERSION: 1.0.0
#==============================================================================

set -u  # Not using -e because tests can fail

#------------------------------------------------------------------------------
# SETUP
#------------------------------------------------------------------------------

# Tests directory
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$TEST_DIR")"
SCRIPT_DIR="$PROJECT_DIR"

# Variables for results
TESTS_PASSED=0
TESTS_FAILED=0
TESTS_SKIPPED=0
VERBOSE="${VERBOSE:-false}"
TEST_FILTER="${1:-}"

# Temporary directories for tests
TEST_TMP_DIR=""

#------------------------------------------------------------------------------
# TESTING FRAMEWORK
#------------------------------------------------------------------------------

# Preparation before tests
setup() {
    TEST_TMP_DIR=$(mktemp -d)
    export LOG_TO_STDOUT="false"
    export LOG_FILE="${TEST_TMP_DIR}/test.log"
    export LOG_LEVEL="DEBUG"
}

# Cleanup after tests
teardown() {
    if [[ -d "$TEST_TMP_DIR" ]]; then
        rm -rf "$TEST_TMP_DIR"
    fi
}

# Display test message
test_msg() {
    if [[ "$VERBOSE" == "true" ]]; then
        echo "  $*"
    fi
}

# Assert that two values are equal
assert_equals() {
    local expected="$1"
    local actual="$2"
    local message="${3:-Values must be equal}"
    
    if [[ "$expected" == "$actual" ]]; then
        echo "✓ PASS: $message"
        ((TESTS_PASSED++))
        return 0
    else
        echo "✗ FAIL: $message"
        echo "  Expected: '$expected'"
        echo "  Actual:   '$actual'"
        ((TESTS_FAILED++))
        return 1
    fi
}

# Assert that a value is not empty
assert_not_empty() {
    local value="$1"
    local message="${2:-Value must not be empty}"
    
    if [[ -n "$value" ]]; then
        echo "✓ PASS: $message"
        ((TESTS_PASSED++))
        return 0
    else
        echo "✗ FAIL: $message"
        echo "  Empty value received"
        ((TESTS_FAILED++))
        return 1
    fi
}

# Assert that a condition is true
assert_true() {
    local condition="$1"
    local message="${2:-Condition must be true}"
    
    if eval "$condition"; then
        echo "✓ PASS: $message"
        ((TESTS_PASSED++))
        return 0
    else
        echo "✗ FAIL: $message"
        echo "  Condition: $condition"
        ((TESTS_FAILED++))
        return 1
    fi
}

# Assert that a condition is false
assert_false() {
    local condition="$1"
    local message="${2:-Condition must be false}"
    
    if ! eval "$condition"; then
        echo "✓ PASS: $message"
        ((TESTS_PASSED++))
        return 0
    else
        echo "✗ FAIL: $message"
        echo "  Condition (should have been false): $condition"
        ((TESTS_FAILED++))
        return 1
    fi
}

# Assert that a file exists
assert_file_exists() {
    local file="$1"
    local message="${2:-File must exist}"
    
    if [[ -f "$file" ]]; then
        echo "✓ PASS: $message"
        ((TESTS_PASSED++))
        return 0
    else
        echo "✗ FAIL: $message"
        echo "  File: $file"
        ((TESTS_FAILED++))
        return 1
    fi
}

# Assert that output contains a string
assert_contains() {
    local haystack="$1"
    local needle="$2"
    local message="${3:-Output must contain text}"
    
    if [[ "$haystack" == *"$needle"* ]]; then
        echo "✓ PASS: $message"
        ((TESTS_PASSED++))
        return 0
    else
        echo "✗ FAIL: $message"
        echo "  Searched for: '$needle'"
        echo "  In: '${haystack:0:200}...'"
        ((TESTS_FAILED++))
        return 1
    fi
}

# Assert that a value is a number
assert_is_number() {
    local value="$1"
    local message="${2:-Value must be a number}"
    
    if [[ "$value" =~ ^-?[0-9]+$ ]]; then
        echo "✓ PASS: $message"
        ((TESTS_PASSED++))
        return 0
    else
        echo "✗ FAIL: $message"
        echo "  Value: '$value'"
        ((TESTS_FAILED++))
        return 1
    fi
}

# Assert that a value is within range
assert_in_range() {
    local value="$1"
    local min="$2"
    local max="$3"
    local message="${4:-Value must be within range}"
    
    if [[ "$value" =~ ^-?[0-9]+$ ]] && [[ $value -ge $min ]] && [[ $value -le $max ]]; then
        echo "✓ PASS: $message"
        ((TESTS_PASSED++))
        return 0
    else
        echo "✗ FAIL: $message"
        echo "  Value: $value, Range: [$min, $max]"
        ((TESTS_FAILED++))
        return 1
    fi
}

# Skip a test with reason
skip_test() {
    local message="$1"
    echo "○ SKIP: $message"
    ((TESTS_SKIPPED++))
}

#------------------------------------------------------------------------------
# LOAD LIBRARIES
#------------------------------------------------------------------------------

# Load libraries for tests
load_libraries() {
    source "${PROJECT_DIR}/lib/core.sh" || return 1
    source "${PROJECT_DIR}/lib/utils.sh" || return 1
    source "${PROJECT_DIR}/lib/config.sh" || return 1
    return 0
}

#------------------------------------------------------------------------------
# CORE.SH TESTS
#------------------------------------------------------------------------------

test_core_logging() {
    echo ""
    echo "=== Tests: core.sh - Logging ==="
    
    # Test _get_timestamp
    local timestamp
    timestamp=$(_get_timestamp)
    assert_not_empty "$timestamp" "_get_timestamp returns timestamp"
    
    # Test _log_level_to_int
    assert_equals "0" "$(_log_level_to_int DEBUG)" "DEBUG = 0"
    assert_equals "1" "$(_log_level_to_int INFO)" "INFO = 1"
    assert_equals "2" "$(_log_level_to_int WARN)" "WARN = 2"
    assert_equals "3" "$(_log_level_to_int ERROR)" "ERROR = 3"
    assert_equals "4" "$(_log_level_to_int FATAL)" "FATAL = 4"
    
    # Test _should_log
    LOG_LEVEL="INFO"
    assert_true '_should_log INFO' "INFO should be logged when level=INFO"
    assert_true '_should_log ERROR' "ERROR should be logged when level=INFO"
    assert_false '_should_log DEBUG' "DEBUG should not be logged when level=INFO"
    
    LOG_LEVEL="DEBUG"
    assert_true '_should_log DEBUG' "DEBUG should be logged when level=DEBUG"
    
    # Test log to file
    local test_log="${TEST_TMP_DIR}/test_log.log"
    LOG_FILE="$test_log"
    LOG_TO_STDOUT="false"
    log INFO "Test message"
    assert_file_exists "$test_log" "Log file must be created"
    assert_contains "$(cat "$test_log")" "Test message" "Message must be written to log"
}

test_core_validation() {
    echo ""
    echo "=== Tests: core.sh - Validation ==="
    
    # Test is_integer
    assert_true 'is_integer 42' "42 is integer"
    assert_true 'is_integer -5' "-5 is integer"
    assert_true 'is_integer 0' "0 is integer"
    assert_false 'is_integer 3.14' "3.14 is not integer"
    assert_false 'is_integer abc' "abc is not integer"
    assert_false 'is_integer ""' "empty string is not integer"
    
    # Test in_range
    assert_true 'in_range 50 0 100' "50 in range [0,100]"
    assert_true 'in_range 0 0 100' "0 in range [0,100]"
    assert_true 'in_range 100 0 100' "100 in range [0,100]"
    assert_false 'in_range 101 0 100' "101 not in range [0,100]"
    assert_false 'in_range -1 0 100' "-1 not in range [0,100]"
    
    # Test require_cmd
    assert_true 'require_cmd bash' "require_cmd bash (exists)"
}

test_core_utilities() {
    echo ""
    echo "=== Tests: core.sh - Utilities ==="
    
    # Test format_duration
    assert_equals "00:00" "$(format_duration 0)" "0 seconds = 00:00"
    assert_equals "01:00" "$(format_duration 60)" "60 seconds = 01:00"
    assert_equals "01:01:01" "$(format_duration 3661)" "3661 seconds = 01:01:01"
}

test_core_lock() {
    echo ""
    echo "=== Tests: core.sh - Lock Files ==="
    
    local lock_file="${TEST_TMP_DIR}/test.lock"
    
    # Test acquire lock
    assert_true 'acquire_lock "$lock_file"' "Can acquire lock"
    assert_file_exists "$lock_file" "Lock file created"
    
    local stored_pid
    stored_pid=$(cat "$lock_file")
    assert_equals "$$" "$stored_pid" "Lock file contains correct PID"
    
    # Test release lock
    release_lock "$lock_file"
    assert_false '[[ -f "$lock_file" ]]' "Lock file deleted after release"
}

#------------------------------------------------------------------------------
# UTILS.SH TESTS
#------------------------------------------------------------------------------

test_utils_cpu() {
    echo ""
    echo "=== Tests: utils.sh - CPU ==="
    
    # Test get_cpu_usage
    local cpu_usage
    cpu_usage=$(get_cpu_usage)
    assert_is_number "$cpu_usage" "CPU usage is number"
    assert_in_range "$cpu_usage" 0 100 "CPU usage in range [0,100]"
    
    # Test get_cpu_cores
    local cores
    cores=$(get_cpu_cores)
    assert_is_number "$cores" "Core count is number"
    assert_true '[[ $cores -ge 1 ]]' "At least 1 core"
    
    # Test get_load_average
    local load
    load=$(get_load_average)
    assert_not_empty "$load" "Load average is not empty"
}

test_utils_memory() {
    echo ""
    echo "=== Tests: utils.sh - Memory ==="
    
    # Test get_memory_usage
    local mem_usage
    mem_usage=$(get_memory_usage)
    assert_is_number "$mem_usage" "Memory usage is number"
    assert_in_range "$mem_usage" 0 100 "Memory usage in range [0,100]"
    
    # Test get_memory_details
    local mem_details
    mem_details=$(get_memory_details)
    assert_not_empty "$mem_details" "Memory details is not empty"
    
    # Test get_swap_usage
    local swap_usage
    swap_usage=$(get_swap_usage)
    assert_is_number "$swap_usage" "Swap usage is number"
    assert_in_range "$swap_usage" 0 100 "Swap usage in range [0,100]"
}

test_utils_disk() {
    echo ""
    echo "=== Tests: utils.sh - Disk ==="
    
    # Test get_disk_usage
    local disk_usage
    disk_usage=$(get_disk_usage "/")
    assert_is_number "$disk_usage" "Disk usage / is number"
    assert_in_range "$disk_usage" 0 100 "Disk usage / in range [0,100]"
    
    # Test get_all_disk_info
    local disk_info
    disk_info=$(get_all_disk_info)
    assert_not_empty "$disk_info" "Disk info is not empty"
    
    # Test get_available_space_mb
    local space
    space=$(get_available_space_mb "/")
    assert_is_number "$space" "Available space is number"
}

test_utils_processes() {
    echo ""
    echo "=== Tests: utils.sh - Processes ==="
    
    # Test get_process_count
    local proc_count
    proc_count=$(get_process_count)
    assert_is_number "$proc_count" "Process count is number"
    assert_true '[[ $proc_count -gt 0 ]]' "At least 1 process"
    
    # Test is_process_running
    assert_true 'is_process_running bash' "bash is running"
    assert_false 'is_process_running nonexistent_process_xyz' "Non-existent process not running"
}

test_utils_system() {
    echo ""
    echo "=== Tests: utils.sh - System ==="
    
    # Test get_uptime_seconds
    local uptime
    uptime=$(get_uptime_seconds)
    assert_is_number "$uptime" "Uptime is number"
    assert_true '[[ $uptime -ge 0 ]]' "Uptime >= 0"
    
    # Test get_hostname
    local hostname
    hostname=$(get_hostname)
    assert_not_empty "$hostname" "Hostname is not empty"
    
    # Test get_kernel_info
    local kernel
    kernel=$(get_kernel_info)
    assert_not_empty "$kernel" "Kernel info is not empty"
}

#------------------------------------------------------------------------------
# CONFIG.SH TESTS
#------------------------------------------------------------------------------

test_config_defaults() {
    echo ""
    echo "=== Tests: config.sh - Default Values ==="
    
    # Verify variables have default values
    assert_not_empty "${THRESHOLD_CPU:-}" "THRESHOLD_CPU has value"
    assert_not_empty "${THRESHOLD_MEM:-}" "THRESHOLD_MEM has value"
    assert_not_empty "${THRESHOLD_DISK:-}" "THRESHOLD_DISK has value"
    
    # Verify valid ranges
    assert_in_range "${THRESHOLD_CPU:-0}" 0 100 "THRESHOLD_CPU valid"
    assert_in_range "${THRESHOLD_MEM:-0}" 0 100 "THRESHOLD_MEM valid"
    assert_in_range "${THRESHOLD_DISK:-0}" 0 100 "THRESHOLD_DISK valid"
}

test_config_load_file() {
    echo ""
    echo "=== Tests: config.sh - Load File ==="
    
    # Create test configuration file
    local test_config="${TEST_TMP_DIR}/test.conf"
    cat > "$test_config" << 'EOF'
# Test config file
THRESHOLD_CPU=75
THRESHOLD_MEM=85
TEST_VAR=test_value
EOF
    
    # Load configuration
    load_config_file "$test_config"
    
    assert_equals "75" "$THRESHOLD_CPU" "THRESHOLD_CPU loaded from file"
    assert_equals "85" "$THRESHOLD_MEM" "THRESHOLD_MEM loaded from file"
    assert_equals "test_value" "${TEST_VAR:-}" "TEST_VAR loaded from file"
}

test_config_parse_args() {
    echo ""
    echo "=== Tests: config.sh - Parse Arguments ==="
    
    # Save current values
    local old_cpu="$THRESHOLD_CPU"
    local old_interval="$MONITOR_INTERVAL"
    
    # Parse arguments
    parse_args --cpu-threshold 95 --interval 120
    
    assert_equals "95" "$THRESHOLD_CPU" "--cpu-threshold set correctly"
    assert_equals "120" "$MONITOR_INTERVAL" "--interval set correctly"
    
    # Restore
    THRESHOLD_CPU="$old_cpu"
    MONITOR_INTERVAL="$old_interval"
}

test_config_validate() {
    echo ""
    echo "=== Tests: config.sh - Validation ==="
    
    # Test validation with correct values
    THRESHOLD_CPU=80
    THRESHOLD_MEM=90
    THRESHOLD_DISK=85
    THRESHOLD_SWAP=50
    MONITOR_INTERVAL=60
    LOG_LEVEL=INFO
    OUTPUT_FORMAT=text
    
    # Create necessary directories
    mkdir -p "${LOG_DIR:-$TEST_TMP_DIR}" 2>/dev/null || true
    mkdir -p "${RUN_DIR:-$TEST_TMP_DIR}" 2>/dev/null || true
    
    assert_true 'validate_config 2>/dev/null' "Valid configuration accepted"
}

#------------------------------------------------------------------------------
# INTEGRATION TESTS
#------------------------------------------------------------------------------

test_integration_monitor() {
    echo ""
    echo "=== Tests: Monitor Integration ==="
    
    # Verify main script can be loaded
    if [[ -f "${PROJECT_DIR}/monitor.sh" ]]; then
        # Source only functions, don't execute main
        (
            # In subshell for isolation
            SCRIPT_DIR="$PROJECT_DIR"
            source "${PROJECT_DIR}/monitor.sh" 2>/dev/null
            
            # Verify main functions
            declare -f check_cpu &>/dev/null && echo "check_cpu OK"
            declare -f check_memory &>/dev/null && echo "check_memory OK"
            declare -f check_disk &>/dev/null && echo "check_disk OK"
        ) | grep -q "OK" && {
            echo "✓ PASS: Main functions are defined"
            ((TESTS_PASSED++))
        } || {
            echo "✗ FAIL: Main functions missing"
            ((TESTS_FAILED++))
        }
    else
        skip_test "monitor.sh does not exist"
    fi
}

test_integration_output_formats() {
    echo ""
    echo "=== Tests: Output Formats ==="
    
    # Preparation
    ALERTS_COUNT=0
    ALERTS_MESSAGES=()
    
    # Test text output
    OUTPUT_FORMAT="text"
    local text_output
    text_output=$(generate_output 2>/dev/null || echo "")
    
    if [[ -n "$text_output" ]]; then
        assert_contains "$text_output" "SYSTEM MONITOR" "Text output contains header"
    else
        skip_test "generate_output not available"
    fi
}

#------------------------------------------------------------------------------
# MAIN RUNNER
#------------------------------------------------------------------------------

run_test_suite() {
    local suite="$1"
    
    case "$suite" in
        core)
            test_core_logging
            test_core_validation
            test_core_utilities
            test_core_lock
            ;;
        utils)
            test_utils_cpu
            test_utils_memory
            test_utils_disk
            test_utils_processes
            test_utils_system
            ;;
        config)
            test_config_defaults
            test_config_load_file
            test_config_parse_args
            test_config_validate
            ;;
        integration)
            test_integration_monitor
            test_integration_output_formats
            ;;
        *)
            # All tests
            test_core_logging
            test_core_validation
            test_core_utilities
            test_core_lock
            test_utils_cpu
            test_utils_memory
            test_utils_disk
            test_utils_processes
            test_utils_system
            test_config_defaults
            test_config_load_file
            test_config_parse_args
            test_config_validate
            test_integration_monitor
            test_integration_output_formats
            ;;
    esac
}

print_summary() {
    echo ""
    echo "=========================================="
    echo "           TEST RESULTS"
    echo "=========================================="
    echo "  Passed:  $TESTS_PASSED"
    echo "  Failed:  $TESTS_FAILED"
    echo "  Skipped: $TESTS_SKIPPED"
    echo "------------------------------------------"
    local total=$((TESTS_PASSED + TESTS_FAILED))
    if [[ $total -gt 0 ]]; then
        local percent=$((TESTS_PASSED * 100 / total))
        echo "  Success rate: ${percent}%"
    fi
    echo "=========================================="
    
    return $TESTS_FAILED
}

main() {
    echo "System Monitor - Test Suite"
    echo "============================"
    echo ""
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -v|--verbose)
                VERBOSE="true"
                shift
                ;;
            core|utils|config|integration)
                TEST_FILTER="$1"
                shift
                ;;
            *)
                shift
                ;;
        esac
    done
    
    # Setup
    setup
    
    # Load libraries
    if ! load_libraries; then
        echo "ERROR: Cannot load libraries"
        exit 1
    fi
    
    # Run tests
    run_test_suite "${TEST_FILTER:-all}"
    
    # Cleanup
    teardown
    
    # Summary
    print_summary
    exit $?
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
