#!/bin/bash
# =============================================================================
# TEST SUITE - Enterprise Backup System
# =============================================================================
# Complete test suite for the backup system
#
# Run: ./test_backup.sh [--verbose] [--filter <pattern>]
#
# Author: Educational Kit OS - ASE Bucharest CSIE
# =============================================================================

set -euo pipefail

# =============================================================================
# TEST CONFIGURATION
# =============================================================================

readonly TEST_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly PROJECT_DIR="$(dirname "$TEST_SCRIPT_DIR")"
readonly LIB_DIR="${PROJECT_DIR}/lib"

# Temporary directories for tests
TEST_TMP_DIR=""
TEST_SOURCE_DIR=""
TEST_DEST_DIR=""
TEST_LOG_DIR=""

# Counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0
TESTS_SKIPPED=0

# Options
VERBOSE=false
TEST_FILTER=""

# Colours
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[0;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m'

# =============================================================================
# TEST FUNCTIONS
# =============================================================================

# Parse arguments
parse_test_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            -f|--filter)
                TEST_FILTER="${2:-}"
                shift 2
                ;;
            -h|--help)
                echo "Usage: $0 [--verbose] [--filter <pattern>]"
                echo "  -v, --verbose    Show detailed output"
                echo "  -f, --filter     Run only tests matching pattern"
                exit 0
                ;;
            *)
                shift
                ;;
        esac
    done
}

# Setup test environment
setup_test_environment() {
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}     BACKUP SYSTEM TEST SUITE${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    
    # Create temporary directories
    TEST_TMP_DIR=$(mktemp -d)
    TEST_SOURCE_DIR="${TEST_TMP_DIR}/source"
    TEST_DEST_DIR="${TEST_TMP_DIR}/dest"
    TEST_LOG_DIR="${TEST_TMP_DIR}/logs"
    
    mkdir -p "$TEST_SOURCE_DIR" "$TEST_DEST_DIR" "$TEST_LOG_DIR"
    
    # Create test files
    create_test_files
    
    # Load modules
    source "${LIB_DIR}/core.sh"
    source "${LIB_DIR}/utils.sh"
    source "${LIB_DIR}/config.sh"
    
    # Set variables for tests
    export BACKUP_SOURCES=("$TEST_SOURCE_DIR")
    export BACKUP_DEST="$TEST_DEST_DIR"
    export LOG_DIR="$TEST_LOG_DIR"
    export LOG_FILE="${TEST_LOG_DIR}/test.log"
    export COMPRESSION="gzip"
    export VERIFY_BACKUP=true
    export SAVE_CHECKSUM=true
    export CHECKSUM_ALGORITHM="sha256"
    export USE_COLORS=true
    export LOG_LEVEL="DEBUG"
    export DRY_RUN=false
    export BACKUP_PREFIX="test_backup"
    export EXCLUDE_PATTERNS=("*.tmp" "*.cache")
    export RETENTION_DAILY=3
    export RETENTION_WEEKLY=2
    export RETENTION_MONTHLY=1
    
    echo -e "${GREEN}✓ Test environment configured${NC}"
    echo ""
}

# Create test files
create_test_files() {
    # Simple text files
    echo "Content file 1" > "${TEST_SOURCE_DIR}/file1.txt"
    echo "Content file 2" > "${TEST_SOURCE_DIR}/file2.txt"
    echo "Config data" > "${TEST_SOURCE_DIR}/config.cfg"
    
    # Subdirectories
    mkdir -p "${TEST_SOURCE_DIR}/subdir1"
    mkdir -p "${TEST_SOURCE_DIR}/subdir2/nested"
    
    echo "Nested content" > "${TEST_SOURCE_DIR}/subdir1/nested.txt"
    echo "Deep content" > "${TEST_SOURCE_DIR}/subdir2/nested/deep.txt"
    
    # Exclusion files
    echo "Temp data" > "${TEST_SOURCE_DIR}/temp.tmp"
    echo "Cache data" > "${TEST_SOURCE_DIR}/data.cache"
    
    # Small binary file
    dd if=/dev/urandom of="${TEST_SOURCE_DIR}/binary.bin" bs=1024 count=10 2>/dev/null
    
    # File with spaces in name
    echo "File with spaces" > "${TEST_SOURCE_DIR}/file with spaces.txt"
}

# Cleanup
cleanup_test_environment() {
    if [[ -n "$TEST_TMP_DIR" && -d "$TEST_TMP_DIR" ]]; then
        rm -rf "$TEST_TMP_DIR"
    fi
}

# Trap for cleanup
trap cleanup_test_environment EXIT

# =============================================================================
# ASSERT FUNCTIONS
# =============================================================================

assert_equals() {
    local expected="$1"
    local actual="$2"
    local message="${3:-Values should be equal}"
    
    if [[ "$expected" == "$actual" ]]; then
        return 0
    else
        echo -e "    ${RED}Expected: '$expected'${NC}"
        echo -e "    ${RED}Actual:   '$actual'${NC}"
        return 1
    fi
}

assert_not_empty() {
    local value="$1"
    local message="${2:-Value should not be empty}"
    
    if [[ -n "$value" ]]; then
        return 0
    else
        echo -e "    ${RED}Value is empty${NC}"
        return 1
    fi
}

assert_true() {
    local condition="$1"
    local message="${2:-Condition should be true}"
    
    if eval "$condition"; then
        return 0
    else
        echo -e "    ${RED}Condition failed: $condition${NC}"
        return 1
    fi
}

assert_false() {
    local condition="$1"
    local message="${2:-Condition should be false}"
    
    if ! eval "$condition"; then
        return 0
    else
        echo -e "    ${RED}Condition unexpectedly true: $condition${NC}"
        return 1
    fi
}

assert_file_exists() {
    local file="$1"
    local message="${2:-File should exist}"
    
    if [[ -f "$file" ]]; then
        return 0
    else
        echo -e "    ${RED}File does not exist: $file${NC}"
        return 1
    fi
}

assert_dir_exists() {
    local dir="$1"
    local message="${2:-Directory should exist}"
    
    if [[ -d "$dir" ]]; then
        return 0
    else
        echo -e "    ${RED}Directory does not exist: $dir${NC}"
        return 1
    fi
}

assert_contains() {
    local haystack="$1"
    local needle="$2"
    local message="${3:-String should contain substring}"
    
    if [[ "$haystack" == *"$needle"* ]]; then
        return 0
    else
        echo -e "    ${RED}String does not contain: '$needle'${NC}"
        return 1
    fi
}

assert_file_size_greater() {
    local file="$1"
    local min_size="$2"
    local message="${3:-File size should be greater than minimum}"
    
    if [[ ! -f "$file" ]]; then
        echo -e "    ${RED}File does not exist: $file${NC}"
        return 1
    fi
    
    local size
    size=$(stat -c%s "$file" 2>/dev/null || echo "0")
    
    if [[ "$size" -gt "$min_size" ]]; then
        return 0
    else
        echo -e "    ${RED}File size ($size) not greater than $min_size${NC}"
        return 1
    fi
}

# =============================================================================
# TEST RUNNER
# =============================================================================

run_test() {
    local test_name="$1"
    local test_function="$2"
    
    # Check filter
    if [[ -n "$TEST_FILTER" && "$test_name" != *"$TEST_FILTER"* ]]; then
        return 0
    fi
    
    ((TESTS_RUN++))
    
    echo -ne "  Testing: ${test_name}... "
    
    # Run test
    local output
    local exit_code=0
    
    if $VERBOSE; then
        echo ""
        $test_function || exit_code=$?
    else
        output=$($test_function 2>&1) || exit_code=$?
    fi
    
    if [[ $exit_code -eq 0 ]]; then
        echo -e "${GREEN}PASSED${NC}"
        ((TESTS_PASSED++))
    else
        echo -e "${RED}FAILED${NC}"
        ((TESTS_FAILED++))
        if [[ -n "${output:-}" ]]; then
            echo "$output" | sed 's/^/    /'
        fi
    fi
}

skip_test() {
    local test_name="$1"
    local reason="${2:-}"
    
    ((TESTS_RUN++))
    ((TESTS_SKIPPED++))
    
    echo -e "  Testing: ${test_name}... ${YELLOW}SKIPPED${NC} ${reason:+($reason)}"
}

# =============================================================================
# TESTS FOR CORE.SH
# =============================================================================

test_logging_debug() {
    local output
    output=$(log_debug "Test debug message" 2>&1)
    # Debug should be in log when LOG_LEVEL=DEBUG
    assert_true "[[ -f '$LOG_FILE' ]] || [[ -n '$output' ]]" "Log should work"
}

test_logging_info() {
    local output
    output=$(log_info "Test info message" 2>&1)
    assert_contains "$output" "INFO" "Should contain INFO level"
}

test_logging_warn() {
    local output
    output=$(log_warn "Test warning" 2>&1)
    assert_contains "$output" "WARN" "Should contain WARN level"
}

test_logging_error() {
    local output
    output=$(log_error "Test error" 2>&1)
    assert_contains "$output" "ERROR" "Should contain ERROR level"
}

test_generate_backup_name() {
    local name
    name=$(generate_backup_name "daily")
    assert_not_empty "$name" "Backup name should not be empty"
    assert_contains "$name" "daily" "Should contain backup type"
}

test_verify_archive_valid() {
    # Create a valid archive
    local test_archive="${TEST_TMP_DIR}/test_valid.tar.gz"
    tar -czf "$test_archive" -C "$TEST_SOURCE_DIR" . 2>/dev/null
    
    assert_file_exists "$test_archive" "Archive should be created"
    
    local result
    result=$(verify_archive "$test_archive" && echo "valid" || echo "invalid")
    assert_equals "valid" "$result" "Archive should be valid"
}

test_verify_archive_invalid() {
    # Create an invalid file
    local test_archive="${TEST_TMP_DIR}/test_invalid.tar.gz"
    echo "not a tar archive" > "$test_archive"
    
    local result
    result=$(verify_archive "$test_archive" 2>/dev/null && echo "valid" || echo "invalid")
    assert_equals "invalid" "$result" "Invalid archive should fail verification"
}

# =============================================================================
# TESTS FOR UTILS.SH
# =============================================================================

test_get_archive_extension_gzip() {
    COMPRESSION="gzip"
    local ext
    ext=$(get_archive_extension)
    assert_equals ".tar.gz" "$ext" "gzip extension should be .tar.gz"
}

test_get_archive_extension_bzip2() {
    COMPRESSION="bzip2"
    local ext
    ext=$(get_archive_extension)
    assert_equals ".tar.bz2" "$ext" "bzip2 extension should be .tar.bz2"
}

test_get_archive_extension_xz() {
    COMPRESSION="xz"
    local ext
    ext=$(get_archive_extension)
    assert_equals ".tar.xz" "$ext" "xz extension should be .tar.xz"
}

test_get_archive_extension_none() {
    COMPRESSION="none"
    local ext
    ext=$(get_archive_extension)
    assert_equals ".tar" "$ext" "no compression extension should be .tar"
}

test_create_archive_gzip() {
    COMPRESSION="gzip"
    local archive="${TEST_TMP_DIR}/test_gzip.tar.gz"
    local exclude_file="${TEST_TMP_DIR}/exclude.txt"
    echo "" > "$exclude_file"
    
    create_archive "$archive" "$exclude_file" "$TEST_SOURCE_DIR"
    
    assert_file_exists "$archive" "Archive should be created"
    assert_file_size_greater "$archive" 100 "Archive should have content"
}

test_create_archive_bzip2() {
    if ! command -v bzip2 &>/dev/null; then
        skip_test "create_archive_bzip2" "bzip2 not available"
        return 0
    fi
    
    COMPRESSION="bzip2"
    local archive="${TEST_TMP_DIR}/test_bzip2.tar.bz2"
    local exclude_file="${TEST_TMP_DIR}/exclude.txt"
    echo "" > "$exclude_file"
    
    create_archive "$archive" "$exclude_file" "$TEST_SOURCE_DIR"
    
    assert_file_exists "$archive" "Archive should be created"
}

test_extract_archive() {
    COMPRESSION="gzip"
    local archive="${TEST_TMP_DIR}/test_extract.tar.gz"
    local extract_dir="${TEST_TMP_DIR}/extracted"
    local exclude_file="${TEST_TMP_DIR}/exclude.txt"
    echo "" > "$exclude_file"
    
    # Create archive
    create_archive "$archive" "$exclude_file" "$TEST_SOURCE_DIR"
    
    # Extract
    mkdir -p "$extract_dir"
    extract_archive "$archive" "$extract_dir"
    
    # Verify extraction
    assert_dir_exists "$extract_dir" "Extract directory should exist"
    assert_true "[[ -n \"\$(ls -A '$extract_dir')\" ]]" "Extracted content should not be empty"
}

test_list_archive_contents() {
    COMPRESSION="gzip"
    local archive="${TEST_TMP_DIR}/test_list.tar.gz"
    local exclude_file="${TEST_TMP_DIR}/exclude.txt"
    echo "" > "$exclude_file"
    
    create_archive "$archive" "$exclude_file" "$TEST_SOURCE_DIR"
    
    local contents
    contents=$(list_archive_contents "$archive")
    
    assert_not_empty "$contents" "Contents should not be empty"
    assert_contains "$contents" "file1.txt" "Should contain file1.txt"
}

test_get_file_size() {
    local size
    size=$(get_file_size "${TEST_SOURCE_DIR}/file1.txt")
    
    assert_not_empty "$size" "Size should not be empty"
}

test_count_files() {
    local count
    count=$(count_files "$TEST_SOURCE_DIR")
    
    assert_true "[[ $count -gt 0 ]]" "Should count files"
}

test_calculate_checksum_md5() {
    local checksum
    checksum=$(calculate_checksum "${TEST_SOURCE_DIR}/file1.txt" "md5")
    
    assert_not_empty "$checksum" "MD5 checksum should not be empty"
    assert_true "[[ ${#checksum} -eq 32 ]]" "MD5 should be 32 characters"
}

test_calculate_checksum_sha256() {
    local checksum
    checksum=$(calculate_checksum "${TEST_SOURCE_DIR}/file1.txt" "sha256")
    
    assert_not_empty "$checksum" "SHA256 checksum should not be empty"
    assert_true "[[ ${#checksum} -eq 64 ]]" "SHA256 should be 64 characters"
}

test_save_and_verify_checksum() {
    COMPRESSION="gzip"
    local archive="${TEST_TMP_DIR}/test_checksum.tar.gz"
    local checksum_file="${archive}.sha256"
    local exclude_file="${TEST_TMP_DIR}/exclude.txt"
    echo "" > "$exclude_file"
    
    create_archive "$archive" "$exclude_file" "$TEST_SOURCE_DIR"
    
    # Save checksum
    save_checksum "$archive" "$checksum_file"
    assert_file_exists "$checksum_file" "Checksum file should exist"
    
    # Verify checksum
    local result
    result=$(verify_checksum "$archive" "$checksum_file" && echo "valid" || echo "invalid")
    assert_equals "valid" "$result" "Checksum should be valid"
}

test_checksum_detects_corruption() {
    COMPRESSION="gzip"
    local archive="${TEST_TMP_DIR}/test_corrupt.tar.gz"
    local checksum_file="${archive}.sha256"
    local exclude_file="${TEST_TMP_DIR}/exclude.txt"
    echo "" > "$exclude_file"
    
    create_archive "$archive" "$exclude_file" "$TEST_SOURCE_DIR"
    save_checksum "$archive" "$checksum_file"
    
    # Corrupt the archive
    echo "corruption" >> "$archive"
    
    # Verify that it detects corruption
    local result
    result=$(verify_checksum "$archive" "$checksum_file" 2>/dev/null && echo "valid" || echo "invalid")
    assert_equals "invalid" "$result" "Should detect corruption"
}

test_is_excluded() {
    EXCLUDE_PATTERNS=("*.tmp" "*.cache" "node_modules/*")
    
    assert_true "is_excluded 'test.tmp'" "*.tmp should be excluded"
    assert_true "is_excluded 'data.cache'" "*.cache should be excluded"
    assert_false "is_excluded 'file.txt'" ".txt should not be excluded"
}

test_create_exclude_file() {
    EXCLUDE_PATTERNS=("*.tmp" "*.cache" "*.log")
    
    local exclude_file="${TEST_TMP_DIR}/exclude_test.txt"
    create_exclude_file "$exclude_file"
    
    assert_file_exists "$exclude_file" "Exclude file should exist"
    
    local content
    content=$(cat "$exclude_file")
    assert_contains "$content" "*.tmp" "Should contain *.tmp"
    assert_contains "$content" "*.cache" "Should contain *.cache"
}

test_estimate_backup_size() {
    local estimate
    estimate=$(estimate_backup_size "$TEST_SOURCE_DIR")
    
    assert_not_empty "$estimate" "Estimate should not be empty"
}

# =============================================================================
# TESTS FOR CONFIG.SH
# =============================================================================

test_get_backup_type_for_today() {
    local type
    type=$(get_backup_type_for_today)
    
    assert_not_empty "$type" "Backup type should not be empty"
    assert_true "[[ '$type' == 'daily' || '$type' == 'weekly' || '$type' == 'monthly' ]]" \
        "Type should be daily, weekly, or monthly"
}

test_get_retention_for_type_daily() {
    RETENTION_DAILY=7
    local retention
    retention=$(get_retention_for_type "daily")
    
    assert_equals "7" "$retention" "Daily retention should be 7"
}

test_get_retention_for_type_weekly() {
    RETENTION_WEEKLY=4
    local retention
    retention=$(get_retention_for_type "weekly")
    
    assert_equals "4" "$retention" "Weekly retention should be 4"
}

test_get_retention_for_type_monthly() {
    RETENTION_MONTHLY=12
    local retention
    retention=$(get_retention_for_type "monthly")
    
    assert_equals "12" "$retention" "Monthly retention should be 12"
}

test_get_backup_name_for_type() {
    BACKUP_PREFIX="test_backup"
    
    local name
    name=$(get_backup_name_for_type "daily")
    
    assert_not_empty "$name" "Backup name should not be empty"
    assert_contains "$name" "test_backup" "Should contain prefix"
    assert_contains "$name" "daily" "Should contain type"
    assert_contains "$name" ".tar" "Should have tar extension"
}

# =============================================================================
# ROTATION TESTS
# =============================================================================

test_rotate_backups() {
    # Create multiple test backups
    COMPRESSION="gzip"
    local exclude_file="${TEST_TMP_DIR}/exclude.txt"
    echo "" > "$exclude_file"
    
    for i in {1..5}; do
        local archive="${TEST_DEST_DIR}/test_backup_daily_202501${i}_120000.tar.gz"
        create_archive "$archive" "$exclude_file" "$TEST_SOURCE_DIR"
        sleep 0.1
    done
    
    # Count before
    local count_before
    count_before=$(find "$TEST_DEST_DIR" -name "test_backup_daily*.tar.gz" | wc -l)
    
    # Apply rotation (keep 3)
    rotate_backups "$TEST_DEST_DIR" 3 "test_backup_daily"
    
    # Count after
    local count_after
    count_after=$(find "$TEST_DEST_DIR" -name "test_backup_daily*.tar.gz" | wc -l)
    
    assert_true "[[ $count_after -le 3 ]]" "Should have at most 3 backups after rotation"
}

test_get_sorted_backups() {
    # Create backups with different timestamps
    COMPRESSION="gzip"
    local exclude_file="${TEST_TMP_DIR}/exclude.txt"
    echo "" > "$exclude_file"
    
    local times=("20250101_100000" "20250102_100000" "20250103_100000")
    for t in "${times[@]}"; do
        local archive="${TEST_DEST_DIR}/sort_test_daily_${t}.tar.gz"
        create_archive "$archive" "$exclude_file" "$TEST_SOURCE_DIR"
    done
    
    local sorted
    sorted=$(get_sorted_backups "$TEST_DEST_DIR" "sort_test_daily")
    
    assert_not_empty "$sorted" "Sorted list should not be empty"
}

# =============================================================================
# INTEGRATION TESTS
# =============================================================================

test_full_backup_cycle() {
    COMPRESSION="gzip"
    BACKUP_PREFIX="integration_test"
    VERIFY_BACKUP=true
    SAVE_CHECKSUM=true
    
    local exclude_file="${TEST_TMP_DIR}/exclude.txt"
    create_exclude_file "$exclude_file"
    
    # 1. Create backup
    local backup_name
    backup_name=$(get_backup_name_for_type "daily")
    local archive="${TEST_DEST_DIR}/${backup_name}"
    
    create_archive "$archive" "$exclude_file" "$TEST_SOURCE_DIR"
    assert_file_exists "$archive" "Backup should be created"
    
    # 2. Verify archive
    local valid
    valid=$(verify_backup_integrity "$archive" && echo "yes" || echo "no")
    assert_equals "yes" "$valid" "Backup should be valid"
    
    # 3. Save and verify checksum
    local checksum_file="${archive}.sha256"
    save_checksum "$archive" "$checksum_file"
    
    local checksum_valid
    checksum_valid=$(verify_checksum "$archive" "$checksum_file" && echo "yes" || echo "no")
    assert_equals "yes" "$checksum_valid" "Checksum should be valid"
    
    # 4. Extract and verify
    local restore_dir="${TEST_TMP_DIR}/restored"
    mkdir -p "$restore_dir"
    extract_archive "$archive" "$restore_dir"
    
    assert_file_exists "${restore_dir}/file1.txt" "Restored file should exist"
    
    local original_content
    original_content=$(cat "${TEST_SOURCE_DIR}/file1.txt")
    local restored_content
    restored_content=$(cat "${restore_dir}/file1.txt")
    
    assert_equals "$original_content" "$restored_content" "Content should match"
}

test_backup_excludes_patterns() {
    COMPRESSION="gzip"
    EXCLUDE_PATTERNS=("*.tmp" "*.cache")
    
    local exclude_file="${TEST_TMP_DIR}/exclude_patterns.txt"
    create_exclude_file "$exclude_file"
    
    local archive="${TEST_TMP_DIR}/exclude_test.tar.gz"
    create_archive "$archive" "$exclude_file" "$TEST_SOURCE_DIR"
    
    # List contents
    local contents
    contents=$(list_archive_contents "$archive")
    
    assert_false "[[ '$contents' == *'.tmp'* ]]" "Should not contain .tmp files"
    assert_false "[[ '$contents' == *'.cache'* ]]" "Should not contain .cache files"
    assert_true "[[ '$contents' == *'.txt'* ]]" "Should contain .txt files"
}

test_backup_with_spaces_in_names() {
    COMPRESSION="gzip"
    
    local exclude_file="${TEST_TMP_DIR}/exclude.txt"
    echo "" > "$exclude_file"
    
    local archive="${TEST_TMP_DIR}/spaces_test.tar.gz"
    create_archive "$archive" "$exclude_file" "$TEST_SOURCE_DIR"
    
    # Verify that file with spaces is included
    local contents
    contents=$(list_archive_contents "$archive")
    
    assert_contains "$contents" "file with spaces" "Should handle files with spaces"
}

test_nested_directories() {
    COMPRESSION="gzip"
    
    local exclude_file="${TEST_TMP_DIR}/exclude.txt"
    echo "" > "$exclude_file"
    
    local archive="${TEST_TMP_DIR}/nested_test.tar.gz"
    create_archive "$archive" "$exclude_file" "$TEST_SOURCE_DIR"
    
    local contents
    contents=$(list_archive_contents "$archive")
    
    assert_contains "$contents" "subdir1" "Should contain subdir1"
    assert_contains "$contents" "subdir2" "Should contain subdir2"
    assert_contains "$contents" "nested" "Should contain nested directories"
}

# =============================================================================
# MAIN - RUN TESTS
# =============================================================================

main() {
    parse_test_args "$@"
    setup_test_environment
    
    echo ""
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  CORE.SH TESTS${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    
    run_test "logging_debug" test_logging_debug
    run_test "logging_info" test_logging_info
    run_test "logging_warn" test_logging_warn
    run_test "logging_error" test_logging_error
    run_test "generate_backup_name" test_generate_backup_name
    run_test "verify_archive_valid" test_verify_archive_valid
    run_test "verify_archive_invalid" test_verify_archive_invalid
    
    echo ""
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  UTILS.SH TESTS${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    
    run_test "get_archive_extension_gzip" test_get_archive_extension_gzip
    run_test "get_archive_extension_bzip2" test_get_archive_extension_bzip2
    run_test "get_archive_extension_xz" test_get_archive_extension_xz
    run_test "get_archive_extension_none" test_get_archive_extension_none
    run_test "create_archive_gzip" test_create_archive_gzip
    run_test "create_archive_bzip2" test_create_archive_bzip2
    run_test "extract_archive" test_extract_archive
    run_test "list_archive_contents" test_list_archive_contents
    run_test "get_file_size" test_get_file_size
    run_test "count_files" test_count_files
    run_test "calculate_checksum_md5" test_calculate_checksum_md5
    run_test "calculate_checksum_sha256" test_calculate_checksum_sha256
    run_test "save_and_verify_checksum" test_save_and_verify_checksum
    run_test "checksum_detects_corruption" test_checksum_detects_corruption
    run_test "is_excluded" test_is_excluded
    run_test "create_exclude_file" test_create_exclude_file
    run_test "estimate_backup_size" test_estimate_backup_size
    
    echo ""
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  CONFIG.SH TESTS${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    
    run_test "get_backup_type_for_today" test_get_backup_type_for_today
    run_test "get_retention_for_type_daily" test_get_retention_for_type_daily
    run_test "get_retention_for_type_weekly" test_get_retention_for_type_weekly
    run_test "get_retention_for_type_monthly" test_get_retention_for_type_monthly
    run_test "get_backup_name_for_type" test_get_backup_name_for_type
    
    echo ""
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  ROTATION TESTS${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    
    run_test "rotate_backups" test_rotate_backups
    run_test "get_sorted_backups" test_get_sorted_backups
    
    echo ""
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  INTEGRATION TESTS${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    
    run_test "full_backup_cycle" test_full_backup_cycle
    run_test "backup_excludes_patterns" test_backup_excludes_patterns
    run_test "backup_with_spaces_in_names" test_backup_with_spaces_in_names
    run_test "nested_directories" test_nested_directories
    
    # Summary
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}                    TEST SUMMARY${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "  Total:    ${TESTS_RUN}"
    echo -e "  ${GREEN}Passed:   ${TESTS_PASSED}${NC}"
    echo -e "  ${RED}Failed:   ${TESTS_FAILED}${NC}"
    echo -e "  ${YELLOW}Skipped:  ${TESTS_SKIPPED}${NC}"
    echo ""
    
    local success_rate=0
    if [[ $TESTS_RUN -gt 0 ]]; then
        success_rate=$(( (TESTS_PASSED * 100) / TESTS_RUN ))
    fi
    
    if [[ $TESTS_FAILED -eq 0 ]]; then
        echo -e "  ${GREEN}✓ ALL TESTS PASSED (${success_rate}%)${NC}"
        echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
        exit 0
    else
        echo -e "  ${RED}✗ SOME TESTS FAILED (${success_rate}% success rate)${NC}"
        echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
        exit 1
    fi
}

# Run
main "$@"
