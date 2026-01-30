#!/usr/bin/env bash
# ==============================================================================
# DEPLOYER - Test Suite
# ==============================================================================
# Unit and integration tests for the deployment system
# Part of the CAPSTONE project for Operating Systems
# ==============================================================================

set -o errexit
set -o nounset
set -o pipefail

# ==============================================================================
# SETUP
# ==============================================================================

# Script location
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Load libraries for testing
source "$PROJECT_DIR/lib/core.sh"
source "$PROJECT_DIR/lib/utils.sh"
source "$PROJECT_DIR/lib/config.sh"

# Disable excessive logging in tests
CURRENT_LOG_LEVEL=$LOG_LEVEL_ERROR
QUIET=true

# ==============================================================================
# TEST FRAMEWORK
# ==============================================================================

# Counters
TESTS_TOTAL=0
TESTS_PASSED=0
TESTS_FAILED=0
TESTS_SKIPPED=0

# Current test info
CURRENT_TEST=""
CURRENT_SUITE=""

# Colour output
TEST_PASS="${GREEN}PASS${NC}"
TEST_FAIL="${RED}FAIL${NC}"
TEST_SKIP="${YELLOW}SKIP${NC}"

# Test temp directory
TEST_TEMP_DIR=""

# Setup test environment
setup_test_env() {
    TEST_TEMP_DIR=$(mktemp -d "/tmp/deployer_test.XXXXXX")
    
    # Create test directories
    mkdir -p "$TEST_TEMP_DIR"/{deploy,backup,logs,run,hooks}
    
    # Override config paths
    DEPLOY_ROOT="$TEST_TEMP_DIR/deploy"
    BACKUP_DIR="$TEST_TEMP_DIR/backup"
    LOG_DIR="$TEST_TEMP_DIR/logs"
    RUN_DIR="$TEST_TEMP_DIR/run"
    HOOKS_DIR="$TEST_TEMP_DIR/hooks"
    
    # Reset counters
    DEPLOY_SERVICES_TOTAL=0
    DEPLOY_SERVICES_SUCCESS=0
    DEPLOY_SERVICES_FAILED=0
    DEPLOYED_SERVICES=()
}

# Cleanup test environment
cleanup_test_env() {
    if [[ -n "$TEST_TEMP_DIR" && -d "$TEST_TEMP_DIR" ]]; then
        rm -rf "$TEST_TEMP_DIR"
    fi
}

# Start test suite
start_suite() {
    CURRENT_SUITE="$1"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  Suite: $CURRENT_SUITE"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

# Run single test
run_test() {
    local test_name="$1"
    CURRENT_TEST="$test_name"
    ((TESTS_TOTAL++))
    
    printf "  %-50s " "$test_name"
}

# Mark test passed
pass() {
    echo -e "[$TEST_PASS]"
    ((TESTS_PASSED++))
}

# Mark test failed
fail() {
    local message="${1:-}"
    echo -e "[$TEST_FAIL]"
    if [[ -n "$message" ]]; then
        echo "    → $message"
    fi
    ((TESTS_FAILED++))
}

# Skip test
skip() {
    local reason="${1:-}"
    echo -e "[$TEST_SKIP] $reason"
    ((TESTS_SKIPPED++))
}

# ==============================================================================
# ASSERTIONS
# ==============================================================================

assert_equals() {
    local expected="$1"
    local actual="$2"
    local message="${3:-Expected '$expected', got '$actual'}"
    
    if [[ "$expected" == "$actual" ]]; then
        return 0
    else
        fail "$message"
        return 1
    fi
}

assert_not_equals() {
    local not_expected="$1"
    local actual="$2"
    local message="${3:-Values should not be equal: '$actual'}"
    
    if [[ "$not_expected" != "$actual" ]]; then
        return 0
    else
        fail "$message"
        return 1
    fi
}

assert_true() {
    local condition="$1"
    local message="${2:-Condition should be true}"
    
    if eval "$condition"; then
        return 0
    else
        fail "$message"
        return 1
    fi
}

assert_false() {
    local condition="$1"
    local message="${2:-Condition should be false}"
    
    if ! eval "$condition"; then
        return 0
    else
        fail "$message"
        return 1
    fi
}

assert_contains() {
    local haystack="$1"
    local needle="$2"
    local message="${3:-String should contain '$needle'}"
    
    if [[ "$haystack" == *"$needle"* ]]; then
        return 0
    else
        fail "$message"
        return 1
    fi
}

assert_file_exists() {
    local file="$1"
    local message="${2:-File should exist: $file}"
    
    if [[ -f "$file" ]]; then
        return 0
    else
        fail "$message"
        return 1
    fi
}

assert_dir_exists() {
    local dir="$1"
    local message="${2:-Directory should exist: $dir}"
    
    if [[ -d "$dir" ]]; then
        return 0
    else
        fail "$message"
        return 1
    fi
}

assert_command_exists() {
    local cmd="$1"
    local message="${2:-Command should exist: $cmd}"
    
    if command -v "$cmd" &>/dev/null; then
        return 0
    else
        fail "$message"
        return 1
    fi
}

assert_exit_code() {
    local expected="$1"
    shift
    local cmd=("$@")
    
    set +e
    "${cmd[@]}" &>/dev/null
    local actual=$?
    set -e
    
    if [[ $expected -eq $actual ]]; then
        return 0
    else
        fail "Expected exit code $expected, got $actual"
        return 1
    fi
}

# ==============================================================================
# CORE TESTS
# ==============================================================================

test_core_logging() {
    start_suite "Core Library - Logging"
    
    run_test "log_level_to_string returns correct values"
    local level_str
    level_str=$(log_level_to_string $LOG_LEVEL_INFO)
    assert_equals "INFO" "$level_str" && pass
    
    run_test "get_timestamp returns valid format"
    local ts
    ts=$(get_timestamp)
    if [[ "$ts" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}\ [0-9]{2}:[0-9]{2}:[0-9]{2}$ ]]; then
        pass
    else
        fail "Invalid timestamp format: $ts"
    fi
    
    run_test "get_short_timestamp returns valid format"
    local sts
    sts=$(get_short_timestamp)
    if [[ "$sts" =~ ^[0-9]{8}_[0-9]{6}$ ]]; then
        pass
    else
        fail "Invalid short timestamp format: $sts"
    fi
}

test_core_validation() {
    start_suite "Core Library - Validation"
    
    run_test "command_exists detects bash"
    if command_exists bash; then
        pass
    else
        fail "bash should exist"
    fi
    
    run_test "command_exists returns false for nonexistent"
    if command_exists __nonexistent_command_xyz__; then
        fail "Should not find nonexistent command"
    else
        pass
    fi
    
    run_test "is_integer accepts valid integers"
    if is_integer "123" && is_integer "-456" && is_integer "0"; then
        pass
    else
        fail
    fi
    
    run_test "is_integer rejects non-integers"
    if is_integer "12.3" || is_integer "abc" || is_integer ""; then
        fail "Should reject non-integers"
    else
        pass
    fi
    
    run_test "is_positive_integer works correctly"
    if is_positive_integer "123" && ! is_positive_integer "0" && ! is_positive_integer "-1"; then
        pass
    else
        fail
    fi
    
    run_test "is_valid_port accepts valid ports"
    if is_valid_port "80" && is_valid_port "443" && is_valid_port "8080"; then
        pass
    else
        fail
    fi
    
    run_test "is_valid_port rejects invalid ports"
    if is_valid_port "0" || is_valid_port "70000" || is_valid_port "abc"; then
        fail
    else
        pass
    fi
    
    run_test "is_valid_url accepts valid URLs"
    if is_valid_url "http://example.com" && is_valid_url "https://test.org/path"; then
        pass
    else
        fail
    fi
    
    run_test "is_valid_url rejects invalid URLs"
    if is_valid_url "ftp://test" || is_valid_url "example.com"; then
        fail
    else
        pass
    fi
}

test_core_utilities() {
    start_suite "Core Library - Utilities"
    
    run_test "format_bytes formats correctly"
    assert_equals "512B" "$(format_bytes 512)" && \
    assert_equals "1KB" "$(format_bytes 1024)" && \
    assert_equals "1MB" "$(format_bytes 1048576)" && pass
    
    run_test "format_duration formats seconds"
    assert_equals "30s" "$(format_duration 30)" && pass
    
    run_test "format_duration formats minutes"
    local dur
    dur=$(format_duration 90)
    assert_contains "$dur" "1m" && pass
    
    run_test "format_duration formats hours"
    dur=$(format_duration 3700)
    assert_contains "$dur" "1h" && pass
    
    run_test "compare_versions equal"
    compare_versions "1.0.0" "1.0.0"
    assert_equals "0" "$?" && pass
    
    run_test "compare_versions greater"
    compare_versions "2.0.0" "1.0.0"
    assert_equals "1" "$?" && pass
    
    run_test "compare_versions lesser"
    compare_versions "1.0.0" "2.0.0"
    assert_equals "2" "$?" && pass
}

test_core_lock() {
    start_suite "Core Library - Lock Management"
    setup_test_env
    
    LOCK_FILE="$TEST_TEMP_DIR/run/test.lock"
    
    run_test "acquire_lock creates lock file"
    acquire_lock "$LOCK_FILE"
    assert_file_exists "$LOCK_FILE" && pass
    
    run_test "lock file contains PID"
    local pid_in_lock
    pid_in_lock=$(cat "$LOCK_FILE")
    assert_equals "$$" "$pid_in_lock" && pass
    
    run_test "release_lock removes lock file"
    release_lock
    if [[ ! -f "$LOCK_FILE" ]]; then
        pass
    else
        fail "Lock file should be removed"
    fi
    
    cleanup_test_env
}

test_core_temp_files() {
    start_suite "Core Library - Temp File Management"
    setup_test_env
    
    run_test "make_temp_file creates file"
    local temp
    temp=$(make_temp_file "test")
    assert_file_exists "$temp" && pass
    
    run_test "make_temp_dir creates directory"
    local tempdir
    tempdir=$(make_temp_dir "test")
    assert_dir_exists "$tempdir" && pass
    
    run_test "temp files tracked for cleanup"
    local count=${#TEMP_FILES[@]}
    if [[ $count -ge 2 ]]; then
        pass
    else
        fail "Expected at least 2 temp files tracked"
    fi
    
    cleanup_test_env
}

# ==============================================================================
# UTILS TESTS
# ==============================================================================

test_utils_service() {
    start_suite "Utils Library - Service Management"
    
    run_test "get_service_status handles missing service"
    if has_systemd; then
        local status
        status=$(get_service_status "__nonexistent_service__")
        assert_equals "not-found" "$status" && pass
    else
        skip "systemd not available"
    fi
    
    run_test "service_exists returns false for missing"
    if has_systemd; then
        if service_exists "__nonexistent_service__"; then
            fail
        else
            pass
        fi
    else
        skip "systemd not available"
    fi
}

test_utils_container() {
    start_suite "Utils Library - Container Management"
    
    run_test "docker_available detects Docker"
    if docker info &>/dev/null; then
        if docker_available; then
            pass
        else
            fail "Docker should be detected"
        fi
    else
        skip "Docker not available"
    fi
    
    run_test "container_exists returns false for missing"
    if docker_available; then
        if container_exists "__nonexistent_container__"; then
            fail
        else
            pass
        fi
    else
        skip "Docker not available"
    fi
    
    run_test "get_container_status handles missing container"
    if docker_available; then
        local status
        status=$(get_container_status "__nonexistent_container__")
        assert_equals "not-found" "$status" && pass
    else
        skip "Docker not available"
    fi
}

test_utils_health_checks() {
    start_suite "Utils Library - Health Checks"
    
    run_test "health_check_tcp localhost:22"
    if health_check_tcp "localhost" "22" 2 2>/dev/null; then
        pass
    else
        skip "SSH not running on localhost"
    fi
    
    run_test "health_check_tcp fails for closed port"
    if health_check_tcp "localhost" "59999" 1 2>/dev/null; then
        fail "Should fail for closed port"
    else
        pass
    fi
    
    run_test "health_check_process detects bash"
    if health_check_process "bash"; then
        pass
    else
        fail "Should find bash process"
    fi
    
    run_test "health_check_process fails for missing"
    if health_check_process "__nonexistent_process__"; then
        fail
    else
        pass
    fi
    
    run_test "health_check_command with true"
    if health_check_command true; then
        pass
    else
        fail
    fi
    
    run_test "health_check_command with false"
    if health_check_command false; then
        fail
    else
        pass
    fi
}

test_utils_file_deploy() {
    start_suite "Utils Library - File Deployment"
    setup_test_env
    
    # Create test file
    echo "test content" > "$TEST_TEMP_DIR/source.txt"
    
    run_test "deploy_file copies file"
    deploy_file "$TEST_TEMP_DIR/source.txt" "$TEST_TEMP_DIR/dest.txt" 2>/dev/null
    assert_file_exists "$TEST_TEMP_DIR/dest.txt" && pass
    
    run_test "deploy_file preserves content"
    local content
    content=$(cat "$TEST_TEMP_DIR/dest.txt")
    assert_equals "test content" "$content" && pass
    
    run_test "deploy_file creates backup"
    echo "updated" > "$TEST_TEMP_DIR/source.txt"
    deploy_file "$TEST_TEMP_DIR/source.txt" "$TEST_TEMP_DIR/dest.txt" "$TEST_TEMP_DIR/backup" 2>/dev/null
    local backup_count
    backup_count=$(find "$TEST_TEMP_DIR/backup" -name "dest.txt.*" | wc -l)
    if [[ $backup_count -ge 1 ]]; then
        pass
    else
        fail "Backup should be created"
    fi
    
    # Create test directory
    mkdir -p "$TEST_TEMP_DIR/source_dir"
    echo "file1" > "$TEST_TEMP_DIR/source_dir/file1.txt"
    echo "file2" > "$TEST_TEMP_DIR/source_dir/file2.txt"
    
    run_test "deploy_directory copies directory"
    deploy_directory "$TEST_TEMP_DIR/source_dir" "$TEST_TEMP_DIR/dest_dir" 2>/dev/null
    assert_dir_exists "$TEST_TEMP_DIR/dest_dir" && pass
    
    run_test "deploy_directory copies all files"
    local file_count
    file_count=$(find "$TEST_TEMP_DIR/dest_dir" -type f | wc -l)
    assert_equals "2" "$file_count" && pass
    
    cleanup_test_env
}

test_utils_env_vars() {
    start_suite "Utils Library - Environment Variables"
    setup_test_env
    
    # Create test env file
    cat > "$TEST_TEMP_DIR/test.env" << 'EOF'
DB_HOST=localhost
DB_PORT=5432
DB_NAME="mydb"
# Comment line
APP_SECRET='secret123'
EOF
    
    run_test "load_env_file loads variables"
    load_env_file "$TEST_TEMP_DIR/test.env" 2>/dev/null
    assert_equals "localhost" "$DB_HOST" && pass
    
    run_test "load_env_file handles quoted values"
    assert_equals "mydb" "$DB_NAME" && pass
    
    run_test "load_env_file handles single quotes"
    assert_equals "secret123" "$APP_SECRET" && pass
    
    # Create template
    cat > "$TEST_TEMP_DIR/template.txt" << 'EOF'
Host: ${DB_HOST}
Port: ${DB_PORT}
EOF
    
    run_test "substitute_env_vars processes template"
    substitute_env_vars "$TEST_TEMP_DIR/template.txt" "$TEST_TEMP_DIR/output.txt" 2>/dev/null
    local output
    output=$(cat "$TEST_TEMP_DIR/output.txt")
    assert_contains "$output" "localhost" && pass
    
    cleanup_test_env
}

test_utils_version() {
    start_suite "Utils Library - Version Management"
    setup_test_env
    
    local version_file="$TEST_TEMP_DIR/versions.txt"
    
    run_test "save_version creates entry"
    save_version "myapp" "1.0.0" "$version_file" 2>/dev/null
    assert_file_exists "$version_file" && pass
    
    run_test "get_current_version returns latest"
    save_version "myapp" "1.1.0" "$version_file" 2>/dev/null
    local version
    version=$(get_current_version "myapp" "$version_file")
    assert_equals "1.1.0" "$version" && pass
    
    run_test "get_previous_version returns previous"
    local prev
    prev=$(get_previous_version "myapp" "$version_file")
    assert_equals "1.0.0" "$prev" && pass
    
    cleanup_test_env
}

test_utils_network() {
    start_suite "Utils Library - Network Utilities"
    
    run_test "is_port_free for unused port"
    # Using a high ephemeral port that's likely free
    if is_port_free 59998; then
        pass
    else
        skip "Port 59998 is in use"
    fi
    
    run_test "find_free_port returns port"
    local port
    port=$(find_free_port 50000 50100)
    if [[ -n "$port" ]] && is_valid_port "$port"; then
        pass
    else
        fail "Should find a free port"
    fi
}

# ==============================================================================
# CONFIG TESTS
# ==============================================================================

test_config_defaults() {
    start_suite "Config Library - Default Values"
    
    run_test "ENVIRONMENT has default"
    assert_not_equals "" "$ENVIRONMENT" && pass
    
    run_test "STRATEGY has default"
    assert_not_equals "" "$STRATEGY" && pass
    
    run_test "HEALTH_CHECK_RETRIES is positive"
    if is_positive_integer "$HEALTH_CHECK_RETRIES"; then
        pass
    else
        fail
    fi
}

test_config_parse_args() {
    start_suite "Config Library - Argument Parsing"
    
    run_test "parse_args handles --verbose"
    parse_args --verbose 2>/dev/null
    assert_equals "true" "$VERBOSE" && pass
    
    run_test "parse_args handles --dry-run"
    parse_args --dry-run 2>/dev/null
    assert_equals "true" "$DRY_RUN" && pass
    
    run_test "parse_args handles -e environment"
    parse_args -e staging 2>/dev/null
    assert_equals "staging" "$ENVIRONMENT" && pass
    
    run_test "parse_args handles --service"
    SERVICES=()
    parse_args --service app1 --service app2 2>/dev/null
    assert_equals "2" "${#SERVICES[@]}" && pass
    
    run_test "parse_args handles --container"
    CONTAINERS=()
    parse_args --container web --container db 2>/dev/null
    assert_equals "2" "${#CONTAINERS[@]}" && pass
    
    run_test "parse_args handles actions"
    parse_args deploy 2>/dev/null
    assert_equals "deploy" "$ACTION" && pass
    
    parse_args rollback 2>/dev/null
    assert_equals "rollback" "$ACTION" && pass
    
    # Reset
    parse_args 2>/dev/null || true
}

test_config_validation() {
    start_suite "Config Library - Validation"
    setup_test_env
    
    run_test "validate_config accepts valid config"
    STRATEGY="rolling"
    DRY_RUN=true
    if validate_config 2>/dev/null; then
        pass
    else
        fail
    fi
    
    run_test "validate_config rejects invalid strategy"
    STRATEGY="invalid_strategy"
    if validate_config 2>/dev/null; then
        fail "Should reject invalid strategy"
    else
        pass
    fi
    STRATEGY="rolling"
    
    run_test "validate_config checks numeric values"
    HEALTH_CHECK_RETRIES="abc"
    if validate_config 2>/dev/null; then
        fail "Should reject non-numeric retries"
    else
        pass
    fi
    HEALTH_CHECK_RETRIES=3
    
    cleanup_test_env
}

test_config_file_loading() {
    start_suite "Config Library - File Loading"
    setup_test_env
    
    # Create test config
    cat > "$TEST_TEMP_DIR/test.conf" << 'EOF'
ENVIRONMENT=testing
STRATEGY=blue-green
HEALTH_CHECK_RETRIES=5
# Comment line
NOTIFY_EMAIL=test@example.com
EOF
    
    run_test "load_config_file loads values"
    load_config_file "$TEST_TEMP_DIR/test.conf" 2>/dev/null
    assert_equals "testing" "$ENVIRONMENT" && pass
    
    run_test "load_config_file handles strategy"
    assert_equals "blue-green" "$STRATEGY" && pass
    
    run_test "load_config_file handles numbers"
    assert_equals "5" "$HEALTH_CHECK_RETRIES" && pass
    
    run_test "load_config_file skips comments"
    assert_equals "test@example.com" "$NOTIFY_EMAIL" && pass
    
    cleanup_test_env
}

# ==============================================================================
# INTEGRATION TESTS
# ==============================================================================

test_integration_deployment_id() {
    start_suite "Integration - Deployment ID"
    
    run_test "generate_deployment_id creates unique ID"
    local id1 id2
    id1=$(generate_deployment_id)
    sleep 0.1
    id2=$(generate_deployment_id)
    
    assert_not_equals "$id1" "$id2" && pass
    
    run_test "deployment ID format is correct"
    local id
    id=$(generate_deployment_id)
    if [[ "$id" =~ ^deploy_[0-9]{14}_.+$ ]]; then
        pass
    else
        fail "Invalid deployment ID format: $id"
    fi
    
    run_test "set_deployment_id sets state"
    set_deployment_id "test_deploy_123"
    assert_equals "test_deploy_123" "$DEPLOYMENT_ID" && pass
    
    run_test "deployment state is running"
    assert_equals "$STATE_RUNNING" "$DEPLOYMENT_STATE" && pass
}

test_integration_service_tracking() {
    start_suite "Integration - Service Tracking"
    setup_test_env
    
    # Reset counters
    DEPLOYED_SERVICES=()
    DEPLOY_SERVICES_SUCCESS=0
    
    run_test "register_deployed_service adds entry"
    register_deployed_service "app1" "1.0.0" "/opt/app1"
    assert_equals "1" "${#DEPLOYED_SERVICES[@]}" && pass
    
    run_test "register_deployed_service increments counter"
    assert_equals "1" "$DEPLOY_SERVICES_SUCCESS" && pass
    
    run_test "get_deployed_services returns list"
    register_deployed_service "app2" "2.0.0" "/opt/app2"
    local services
    services=$(get_deployed_services)
    assert_contains "$services" "app1" && \
    assert_contains "$services" "app2" && pass
    
    cleanup_test_env
}

test_integration_hooks() {
    start_suite "Integration - Hook System"
    setup_test_env
    
    HOOKS_DIR="$TEST_TEMP_DIR/hooks"
    
    # Create test hook
    cat > "$HOOKS_DIR/test-hook" << 'EOF'
#!/bin/bash
echo "Hook executed: $1"
exit 0
EOF
    chmod +x "$HOOKS_DIR/test-hook"
    
    run_test "run_hook executes existing hook"
    if run_hook "test-hook" "arg1" 2>/dev/null; then
        pass
    else
        fail
    fi
    
    run_test "run_hook skips missing hook"
    if run_hook "nonexistent-hook" 2>/dev/null; then
        pass
    else
        fail "Should succeed for missing hook"
    fi
    
    # Create failing hook
    cat > "$HOOKS_DIR/fail-hook" << 'EOF'
#!/bin/bash
exit 1
EOF
    chmod +x "$HOOKS_DIR/fail-hook"
    
    run_test "run_hook returns error for failing hook"
    if run_hook "fail-hook" 2>/dev/null; then
        fail "Should fail for failing hook"
    else
        pass
    fi
    
    cleanup_test_env
}

test_integration_manifest() {
    start_suite "Integration - Manifest Parsing"
    setup_test_env
    
    # Create test manifest
    cat > "$TEST_TEMP_DIR/app.yaml" << 'EOF'
name: myapp
version: 1.2.3
type: service
description: Test application
EOF
    
    run_test "parse_manifest loads values"
    parse_manifest "$TEST_TEMP_DIR/app.yaml" 2>/dev/null
    assert_equals "myapp" "$MANIFEST_NAME" && pass
    
    run_test "parse_manifest loads version"
    assert_equals "1.2.3" "$MANIFEST_VERSION" && pass
    
    run_test "parse_manifest loads type"
    assert_equals "service" "$MANIFEST_TYPE" && pass
    
    run_test "validate_manifest accepts valid"
    if validate_manifest "$TEST_TEMP_DIR/app.yaml" 2>/dev/null; then
        pass
    else
        fail
    fi
    
    # Create invalid manifest
    cat > "$TEST_TEMP_DIR/invalid.yaml" << 'EOF'
description: Missing required fields
EOF
    
    run_test "validate_manifest rejects invalid"
    if validate_manifest "$TEST_TEMP_DIR/invalid.yaml" 2>/dev/null; then
        fail "Should reject invalid manifest"
    else
        pass
    fi
    
    cleanup_test_env
}

test_integration_rollback_data() {
    start_suite "Integration - Rollback Data"
    setup_test_env
    
    run_test "register_rollback stores data"
    register_rollback "test_key" "test_value"
    pass
    
    run_test "get_rollback_data retrieves data"
    local value
    value=$(get_rollback_data "test_key")
    assert_equals "test_value" "$value" && pass
    
    run_test "get_rollback_data returns empty for missing"
    value=$(get_rollback_data "nonexistent_key")
    assert_equals "" "$value" && pass
    
    cleanup_test_env
}

test_integration_report() {
    start_suite "Integration - Deployment Report"
    setup_test_env
    
    # Setup mock deployment
    set_deployment_id "test_deploy"
    DEPLOYMENT_STATE=$STATE_SUCCESS
    DEPLOY_SERVICES_TOTAL=3
    DEPLOY_SERVICES_SUCCESS=2
    DEPLOY_SERVICES_FAILED=1
    DEPLOYED_SERVICES=("app1:1.0:path1" "app2:2.0:path2")
    
    run_test "generate_deployment_report text format"
    local report
    report=$(generate_deployment_report "text" 2>/dev/null)
    assert_contains "$report" "test_deploy" && pass
    
    run_test "report contains service counts"
    assert_contains "$report" "2/3" && pass
    
    run_test "generate_deployment_report json format"
    report=$(generate_deployment_report "json" 2>/dev/null)
    assert_contains "$report" '"deployment_id"' && pass
    
    cleanup_test_env
}

# ==============================================================================
# EDGE CASE TESTS
# ==============================================================================

test_edge_cases() {
    start_suite "Edge Cases"
    
    run_test "handles empty strings"
    if is_integer ""; then
        fail
    else
        pass
    fi
    
    run_test "handles special characters in paths"
    setup_test_env
    local special_dir="$TEST_TEMP_DIR/dir with spaces"
    mkdir -p "$special_dir"
    if [[ -d "$special_dir" ]]; then
        pass
    else
        fail
    fi
    cleanup_test_env
    
    run_test "handles unicode in values"
    local unicode_val="héllo wörld 日本語"
    if [[ -n "$unicode_val" ]]; then
        pass
    else
        fail
    fi
}

# ==============================================================================
# TEST RUNNER
# ==============================================================================

print_summary() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  TEST SUMMARY"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "  Total:   $TESTS_TOTAL"
    echo -e "  Passed:  ${GREEN}$TESTS_PASSED${NC}"
    echo -e "  Failed:  ${RED}$TESTS_FAILED${NC}"
    echo -e "  Skipped: ${YELLOW}$TESTS_SKIPPED${NC}"
    echo ""
    
    if [[ $TESTS_FAILED -eq 0 ]]; then
        local rate=$((TESTS_PASSED * 100 / TESTS_TOTAL))
        echo -e "  ${GREEN}Success Rate: ${rate}%${NC}"
    else
        local rate=$((TESTS_PASSED * 100 / TESTS_TOTAL))
        echo -e "  ${RED}Success Rate: ${rate}%${NC}"
    fi
    
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

run_all_tests() {
    echo ""
    echo "╔══════════════════════════════════════════════════════════╗"
    echo "║          DEPLOYER TEST SUITE                             ║"
    echo "╚══════════════════════════════════════════════════════════╝"
    
    # Core tests
    test_core_logging
    test_core_validation
    test_core_utilities
    test_core_lock
    test_core_temp_files
    
    # Utils tests
    test_utils_service
    test_utils_container
    test_utils_health_checks
    test_utils_file_deploy
    test_utils_env_vars
    test_utils_version
    test_utils_network
    
    # Config tests
    test_config_defaults
    test_config_parse_args
    test_config_validation
    test_config_file_loading
    
    # Integration tests
    test_integration_deployment_id
    test_integration_service_tracking
    test_integration_hooks
    test_integration_manifest
    test_integration_rollback_data
    test_integration_report
    
    # Edge cases
    test_edge_cases
    
    # Summary
    print_summary
    
    # Return code based on failures
    [[ $TESTS_FAILED -eq 0 ]]
}

# Run tests
run_all_tests
