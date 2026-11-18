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

This is the complete extracted teaching runner, separate from the maintained compact runner in `SEM06/scripts/examples/test_runner.sh`. Save it beside the assertion module below. It keeps result records outside isolated workers, loads the complete test file and its dependencies for each test, treats setup failures as failures, handles explicit skip status 77, enforces a per-test timeout and stops across files when requested. Empty selection returns 2 rather than reporting a passing suite.

`setup_file`/`teardown_file` execute once per file. Shared fixture data belongs in files under `TEST_TEMP_DIR`; any scalar paths initialised by `setup_file` and needed by child tests must be **exported**. Bash arrays and unexported variables do not cross a new Bash process. Per-test `setup`, the test and `teardown` share one child shell, so ordinary module functions and setup variables remain available. Tests are trusted executable code; command-string assertions deliberately evaluate test source, never untrusted configuration.


```bash
#!/usr/bin/env bash
# Extract as tests/test_runner.sh beside test_helpers.sh.
# Bash 4.4+, GNU timeout and Python 3. Trusted test code is sourced deliberately.
set -uo pipefail
RUNNER_PATH=$(realpath -- "${BASH_SOURCE[0]}") || exit 2

record_result() {
    python3 - "$1" "$2" "$3" "$4" "$5" "$6" <<'PY'
import json,pathlib,sys
path,name,rc,duration,output,phase=sys.argv[1:]
record={'name':name,'status':'pass' if rc=='0' else 'skip' if rc=='77' else 'fail',
        'exit_code':int(rc),'duration_ms':int(duration),'phase':phase,
        'output':pathlib.Path(output).read_text(errors='replace')}
pathlib.Path(path).write_text(json.dumps(record)+'\n')
PY
}

test_child() {
    local file=$1 function=$2 work=$3
    cd -- "$work" || return 1
    export TEST_WORK_DIR=$work
    source "$TEST_DIR/test_helpers.sh" || return 1
    source "$file" || return 1  # Load the complete module and its dependencies.
    test_teardown() {
        local rc=$?
        trap - EXIT
        if declare -F teardown >/dev/null; then
            if teardown; then :; else rc=1; fi
        fi
        exit "$rc"
    }
    trap test_teardown EXIT
    set -Ee
    if declare -F setup >/dev/null; then setup; fi  # Failure is failure, never skip.
    "$function"
}

file_worker() {
    local file=$1 result_dir=$2 output rc=0 test name line origin start end count=0 file_rc=0
    source "$TEST_DIR/test_helpers.sh" || return 1
    source "$file" || return 1
    local -a functions=()
    # Query Bash's parsed definitions, including whitespace/newline formatting.
    shopt -s extdebug
    while IFS= read -r test; do
        [[ $test == test_* ]] || continue
        read -r name line origin < <(declare -F "$test")
        [[ $origin == "$file" ]] || continue
        if [[ -n $FILTER_PATTERN ]]; then
            [[ $name =~ $FILTER_PATTERN ]]; rc=$?
            ((rc != 2)) || return 2
            ((rc == 0)) || continue
        fi
        functions+=("$name")
    done < <(compgen -A function | sort)
    shopt -u extdebug
    if ((${#functions[@]} == 0)); then return 0; fi
    output=$result_dir/setup.out
    if declare -F setup_file >/dev/null; then
        if setup_file > "$output" 2>&1; then :
        else
            rc=$?
            record_result "$result_dir/000000.json" "$file::setup_file" "$rc" 0 "$output" setup_file || return 1
            return 1
        fi
    fi
    for test in "${functions[@]}"; do
        count=$((count+1)); local work=$TEST_TEMP_DIR/work.$BASHPID.$count
        mkdir -- "$work" || return 1
        output=$result_dir/$count.out
        start=$(date +%s%N)
        if timeout --kill-after=1 "$TEST_TIMEOUT" bash "$RUNNER_PATH" --child "$file" "$test" "$work" > "$output" 2>&1; then rc=0
        else rc=$?; fi
        end=$(date +%s%N)
        record_result "$result_dir/$(printf '%06d' "$count").json" "$file::$test" "$rc" "$(((end-start)/1000000))" "$output" test || return 1
        printf '%-5s %s\n' "$([[ $rc == 0 ]] && printf PASS || { [[ $rc == 77 ]] && printf SKIP || printf FAIL; })" "$test"
        if [[ $VERBOSE == 1 || ( $rc != 0 && $rc != 77 ) ]]; then cat -- "$output"; fi
        rm -rf -- "$work"
        if ((rc != 0 && rc != 77)); then file_rc=1; [[ $STOP_ON_FAILURE == 0 ]] || break; fi
    done
    if declare -F teardown_file >/dev/null; then
        output=$result_dir/teardown.out
        if teardown_file > "$output" 2>&1; then :
        else
            rc=$?; file_rc=1
            record_result "$result_dir/999999.json" "$file::teardown_file" "$rc" 0 "$output" teardown_file || return 1
        fi
    fi
    return "$file_rc"
}

summarise() {
    python3 - "$TEST_TEMP_DIR" "$REPORT_FORMAT" "$REPORT_FILE" <<'PY'
import json,pathlib,sys,xml.etree.ElementTree as ET
root,form,out=sys.argv[1:]; rows=[]
for path in sorted(pathlib.Path(root).glob('results.*/*.json')): rows.append(json.loads(path.read_text()))
counts={s:sum(r['status']==s for r in rows) for s in ('pass','fail','skip')}
print(f"Total: {len(rows)}; passed: {counts['pass']}; failed: {counts['fail']}; skipped: {counts['skip']}")
if not rows: print('No tests selected; this is not a passing suite.')
if form:
    if form=='json': text=json.dumps({'results':rows,'counts':counts},indent=2)+'\n'
    elif form=='tap':
        text='TAP version 13\n1..'+str(len(rows))+'\n'
        for i,r in enumerate(rows,1):
            name=r['name'].replace('\n',' ').replace('\r',' ').replace('#','_')
            text+=('not ok' if r['status']=='fail' else 'ok')+f' {i} - {name}'+(' # SKIP requested' if r['status']=='skip' else '')+'\n'
    elif form=='junit':
        suite=ET.Element('testsuite',name='CAPSTONE',tests=str(len(rows)),failures=str(counts['fail']),skipped=str(counts['skip']))
        for r in rows:
            case=ET.SubElement(suite,'testcase',name=r['name'],time=str(r['duration_ms']/1000))
            if r['status']=='fail': ET.SubElement(case,'failure',message='exit '+str(r['exit_code'])).text=r['output']
            elif r['status']=='skip': ET.SubElement(case,'skipped').text=r['output']
            ET.SubElement(case,'system-out').text=r['output']
        text=ET.tostring(suite,encoding='unicode')+'\n'
    else: text=''.join(f"{r['status']}: {r['name']} ({r['exit_code']})\n" for r in rows)
    pathlib.Path(out or ('test-results.'+{'junit':'xml','text':'txt'}.get(form,form))).write_text(text)
raise SystemExit(1 if counts['fail'] else 0 if rows else 2)
PY
}

main() {
    local type=all option value file worker_rc index=0
    export TEST_DIR=${TEST_DIR:-$(dirname -- "$RUNNER_PATH")}
    TEST_DIR=$(realpath -- "$TEST_DIR") || return 2
    export TEST_TIMEOUT=30 FILTER_PATTERN='' VERBOSE=0 STOP_ON_FAILURE=0
    REPORT_FORMAT=''; REPORT_FILE=''
    while (($#)); do
        option=$1; shift
        case $option in
            -t|--type|-f|--filter|--timeout|--report|--report-file)
                (($#)) || { printf 'Missing value for %s\n' "$option" >&2; return 2; }; value=$1; shift;;
        esac
        case $option in
            -t|--type) type=$value;; -f|--filter) FILTER_PATTERN=$value;;
            --timeout) TEST_TIMEOUT=$value;; --report) REPORT_FORMAT=$value;; --report-file) REPORT_FILE=$value;;
            -v|--verbose) VERBOSE=1;; -s|--stop-on-failure) STOP_ON_FAILURE=1;;
            -h|--help) printf '%s\n' 'Usage: test_runner.sh [-t unit|integration|all] [-f REGEX] [-v] [-s] [--timeout SECONDS] [--report text|tap|junit|json] [--report-file PATH]'; return 0;;
            *) printf 'Unknown option: %s\n' "$option" >&2; return 2;;
        esac
    done
    [[ $type == all || $type == unit || $type == integration ]] || return 2
    [[ $TEST_TIMEOUT =~ ^[1-9][0-9]{0,3}$ ]] || return 2
    case $REPORT_FORMAT in ''|text|tap|junit|json) :;; *) return 2;; esac
    [[ '' =~ $FILTER_PATTERN ]]; local filter_rc=$?; ((filter_rc != 2)) || return 2
    [[ -r $TEST_DIR/test_helpers.sh ]] || { printf 'Missing test_helpers.sh\n' >&2; return 2; }
    export TEST_TEMP_DIR
    TEST_TEMP_DIR=$(mktemp -d) || return 1
    trap 'rc=$?; rm -rf -- "$TEST_TEMP_DIR"; exit "$rc"' EXIT
    trap 'exit 130' INT; trap 'exit 143' TERM
    local -a files=()
    shopt -s nullglob
    [[ $type == integration ]] || files+=("$TEST_DIR"/unit/test_*.sh)
    [[ $type == unit ]] || files+=("$TEST_DIR"/integration/test_*.sh)
    for file in "${files[@]}"; do
        index=$((index+1)); local result_dir=$TEST_TEMP_DIR/results.$(printf '%06d' "$index")
        mkdir -- "$result_dir" || return 1
        if bash "$RUNNER_PATH" --worker "$file" "$result_dir"; then worker_rc=0
        else worker_rc=$?; fi
        if ((worker_rc != 0)); then
            # Source/setup/worker failures without a record must never become zero tests/pass.
            if [[ -z $(find "$result_dir" -name '*.json' -print -quit) ]]; then
                printf 'File worker failed with exit %s\n' "$worker_rc" > "$result_dir/worker.out"
                record_result "$result_dir/000000.json" "$file::worker" "$worker_rc" 0 "$result_dir/worker.out" worker || return 1
            fi
            [[ $STOP_ON_FAILURE == 0 ]] || break
        fi
    done
    summarise
}

case ${1:-} in
    --child) shift; test_child "$@";;
    --worker) shift; file_worker "$@";;
    *) main "$@";;
esac
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

_assert_numeric() {
    local operation=$1; shift
    python3 - "$operation" "$@" <<'PY'
import math,sys
try:
    operation,*values=sys.argv[1:]; values=list(map(float,values))
    if not all(map(math.isfinite,values)): raise ValueError()
    if operation=='eq': ok=values[0]==values[1]
    elif operation=='gt': ok=values[0]>values[1]
    elif operation=='lt': ok=values[0]<values[1]
    else: ok=values[1]<=values[0]<=values[2]
    if not ok: print('Numeric assertion failed:',operation,values,file=sys.stderr)
    raise SystemExit(0 if ok else 1)
except (ValueError,IndexError): print('Invalid numeric assertion input',file=sys.stderr); raise SystemExit(1)
PY
}
assert_equals_numeric() { _assert_numeric eq "$1" "$2"; }
assert_greater_than() { _assert_numeric gt "$1" "$2"; }
assert_less_than() { _assert_numeric lt "$1" "$2"; }
assert_in_range() { _assert_numeric range "$1" "$2" "$3"; }

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
    
    if grep -qF -- "$content" "$filepath"; then
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
    
    if [[ -f "$filepath" && ! -s "$filepath" ]]; then
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
    
    local actual=0
    if eval "$command" >/dev/null 2>&1; then :; else actual=$?; fi
    
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
    if actual=$(eval "$command" 2>&1); then :; else :; fi
    
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
    if actual=$(eval "$command" 2>&1); then :; else :; fi
    
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
    if stderr_output=$(eval "$command" 2>&1 1>/dev/null); then :; else :; fi
    
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
    
    [[ $filename != */* && $filename != . && $filename != .. ]] || return 2
    local filepath
    filepath=$(mktemp "${TEST_WORK_DIR:-${TEST_TEMP_DIR:?}}/${filename}.XXXXXX") || return 1
    printf '%s' "$content" > "$filepath" || return 1
    printf '%s\n' "$filepath"
}

# Create temporary directory for test
create_temp_dir() {
    local dirname="${1:-test_dir_$$}"
    
    [[ $dirname != */* && $dirname != . && $dirname != .. ]] || return 2
    mktemp -d "${TEST_WORK_DIR:-${TEST_TEMP_DIR:?}}/${dirname}.XXXXXX"
}

# Mock for command
mock_command() {
    local cmd_name=$1 mock_output=$2 mock_exit_code=${3:-0}
    [[ $cmd_name =~ ^[A-Za-z_][A-Za-z0-9_-]*$ && $mock_exit_code =~ ^[0-9]{1,3}$ ]] || return 2
    ((10#$mock_exit_code <= 255)) || return 2
    local mock_dir=${TEST_WORK_DIR:-${TEST_TEMP_DIR:?}}/mocks
    mkdir -p -- "$mock_dir" || return 1
    printf '%s' "$mock_output" > "$mock_dir/$cmd_name.output" || return 1
    printf '%s\n' "$mock_exit_code" > "$mock_dir/$cmd_name.status" || return 1
    cat > "$mock_dir/$cmd_name" <<'SH'
#!/usr/bin/env bash
cat -- "$0.output"
read -r status < "$0.status"
exit "$status"
SH
    chmod +x -- "$mock_dir/$cmd_name" || return 1
    export PATH="$mock_dir:$PATH"
}

# Restore original command (remove mock)
unmock_command() {
    local cmd_name="$1"
    rm -f -- "${TEST_WORK_DIR:-${TEST_TEMP_DIR:?}}/mocks/${cmd_name}"{,.output,.status}
}

# Capture output with stdout/stderr separation
capture_output() {
    local command="$1"
    local -n stdout_var="$2"
    local -n stderr_var="$3"
    local -n exit_var="$4"
    
    local tmp_stdout tmp_stderr
    tmp_stdout=$(mktemp) || return 1
    tmp_stderr=$(mktemp) || { rm -f -- "$tmp_stdout"; return 1; }
    
    if eval "$command" > "$tmp_stdout" 2> "$tmp_stderr"; then exit_var=0; else exit_var=$?; fi
    
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
#!/usr/bin/env bash
# tests/unit/test_monitor_core.sh for the extracted P02 teaching modules.
: "${MONITOR_MODULE:?Set the absolute path of the extracted monitor_core.sh}"
: "${MONITOR_DATA_PATH:?Set the absolute path of monitor_data.py}"
source "$MONITOR_MODULE"
setup() {
    CPU_STAT_PATH=$TEST_WORK_DIR/stat.before
    CPU_STAT_SECOND_PATH=$TEST_WORK_DIR/stat.after
    export CPU_STAT_PATH CPU_STAT_SECOND_PATH CPU_SAMPLE_INTERVAL=0
    printf 'cpu 100 0 0 800 100 0 0 0 999 999\ncpu0 100 0 0 800 100 0 0 0 999 999\n' > "$CPU_STAT_PATH"
    printf 'cpu 120 0 0 870 110 0 0 0 999 999\ncpu0 120 0 0 870 110 0 0 0 999 999\n' > "$CPU_STAT_SECOND_PATH"
    export PROC_MEMINFO=$TEST_WORK_DIR/meminfo
    printf 'MemTotal: 1000 kB\nMemAvailable: 400 kB\nMemFree: 100 kB\nBuffers: 50 kB\nCached: 300 kB\nSwapTotal: 0 kB\nSwapFree: 0 kB\n' > "$PROC_MEMINFO"
}
test_cpu_known_interval() { assert_equals 20.0 "$(get_cpu_usage)"; }
test_cpu_reset_is_unavailable() {
    cp -- "$CPU_STAT_PATH" "$CPU_STAT_SECOND_PATH"
    local rc=0
    if get_cpu_usage; then :; else rc=$?; fi
    assert_equals 2 "$rc"
}
test_memory_known_values() {
    local value
    value=$(get_memory_info percent)
    assert_equals 60.0 "$value"
    get_memory_info json > "$TEST_WORK_DIR/memory.json"
    python3 - "$TEST_WORK_DIR/memory.json" <<'PY'
import json,sys
data=json.load(open(sys.argv[1])); assert data['used_kb']==600 and data['swap_percent']==0
PY
}
test_memory_missing_input_fails() {
    rm -- "$PROC_MEMINFO"
    local rc=0; if get_memory_info json; then :; else rc=$?; fi
    assert_equals 2 "$rc"
}
```

### Test for Backup Core

```bash
#!/usr/bin/env bash
# tests/unit/test_backup_core.sh for P03's explicit reference engine.
: "${BACKUP_ENGINE_PATH:?Set the absolute path of backup_reference.py}"
setup_file() {
    export TEST_BACKUP_DIR=$TEST_TEMP_DIR/backup_fixtures
    mkdir -p -- "$TEST_BACKUP_DIR"
}
teardown_file() { rm -rf -- "$TEST_BACKUP_DIR"; }
setup() {
    export SOURCE_DIR=$TEST_WORK_DIR/source DEST_DIR=$TEST_WORK_DIR/archives
    mkdir -- "$SOURCE_DIR"
    printf original > "$SOURCE_DIR/file with spaces"
    printf remove > "$SOURCE_DIR/delete.txt"
}
test_create_archive_and_chain_restoration() {
    local full incremental
    full=$(python3 "$BACKUP_ENGINE_PATH" create "$DEST_DIR" full "$SOURCE_DIR")
    assert_file_exists "$full"
    printf modified > "$SOURCE_DIR/file with spaces"
    rm -- "$SOURCE_DIR/delete.txt"
    printf new > "$SOURCE_DIR/new.txt"
    incremental=$(python3 "$BACKUP_ENGINE_PATH" create "$DEST_DIR" incremental "$SOURCE_DIR")
    python3 "$BACKUP_ENGINE_PATH" restore "$DEST_DIR" "$incremental" "$TEST_WORK_DIR/restored"
    local restored=$TEST_WORK_DIR/restored/${SOURCE_DIR#/}
    assert_file_contains "$restored/file with spaces" modified
    assert_file_not_exists "$restored/delete.txt"
    assert_file_contains "$restored/new.txt" new
}
test_corruption_is_failure() {
    local archive rc=0
    archive=$(python3 "$BACKUP_ENGINE_PATH" create "$DEST_DIR" full "$SOURCE_DIR")
    printf corrupt >> "$archive"
    if python3 "$BACKUP_ENGINE_PATH" verify "$archive"; then :; else rc=$?; fi
    assert_not_equals 0 "$rc"
}
test_list_excludes_sidecars() {
    python3 "$BACKUP_ENGINE_PATH" create "$DEST_DIR" full "$SOURCE_DIR" >/dev/null
    python3 "$BACKUP_ENGINE_PATH" list "$DEST_DIR" --format json > "$TEST_WORK_DIR/list.json"
    python3 - "$TEST_WORK_DIR/list.json" <<'PY'
import json,sys
assert len(json.load(open(sys.argv[1]))['backups'])==1
PY
}
```

---

## Mocking and Isolation

### Mocking Techniques in Bash

Mocking in Bash involves temporarily replacing commands or functions with controlled implementations:

```bash
#!/usr/bin/env bash
# tests/mocks/mock_commands.sh: child-visible state is exported or file-backed.
mock_curl() {
    export MOCK_CURL_BODY=$1 MOCK_CURL_EXIT=${2:-0} MOCK_CURL_HTTP_STATUS=${3:-200}
    : "${MOCK_CURL_PROGRAM:?Use SEM06/scripts/examples/mock_curl.py}"
    export MOCK_CURL_PROGRAM
    curl() { python3 "$MOCK_CURL_PROGRAM" "$@"; }
    export -f curl
}
unmock_curl() { unset -f curl; }
mock_systemctl() {
    export MOCK_SERVICE_STATUS=${1:-active}
    systemctl() {
        local action=${1:-} service=${2:-}
        case $action in
            status) printf '%s: %s\n' "$service" "$MOCK_SERVICE_STATUS";;
            is-active) [[ ${2:-} == --quiet ]] || printf '%s\n' "$MOCK_SERVICE_STATUS";;
            start|stop|restart) return "${MOCK_SERVICE_MUTATION_STATUS:-0}";;
            *) return 2;;
        esac
        [[ $MOCK_SERVICE_STATUS == active ]] && return 0
        return 3
    }
    export -f systemctl
}
mock_disk_space() {
    export MOCK_AVAILABLE_KB=$1
    [[ $MOCK_AVAILABLE_KB =~ ^[0-9]+$ ]] || return 2
    df() {
        printf 'Filesystem 1K-blocks Used Available Use%% Mounted on\n'
        printf '/dev/mock 10000000 5000000 %s 50%% %s\n' "$MOCK_AVAILABLE_KB" "${!#}"
    }
    export -f df
}
create_mock_meminfo() {
    printf 'MemTotal: %s kB\nMemFree: %s kB\nMemAvailable: %s kB\nBuffers: 100 kB\nCached: 200 kB\nSwapTotal: 0 kB\nSwapFree: 0 kB\n' "$1" "$2" "$3"
}
mock_ps() {
    export MOCK_PS_FILE=${TEST_WORK_DIR:-${TEST_TEMP_DIR:?}}/ps.records
    printf '%s\n' "$@" > "$MOCK_PS_FILE"
    ps() { cat -- "$MOCK_PS_FILE"; }
    export -f ps
}
mock_pgrep() {
    export MOCK_PGREP_FILE=${TEST_WORK_DIR:-${TEST_TEMP_DIR:?}}/pgrep.records
    : > "$MOCK_PGREP_FILE"
    (($# == 0)) || printf '%s\n' "$@" > "$MOCK_PGREP_FILE"
    pgrep() { [[ -s $MOCK_PGREP_FILE ]] || return 1; cat -- "$MOCK_PGREP_FILE"; }
    export -f pgrep
}
```

### Integration Test with Mocking

```bash
#!/usr/bin/env bash
# Extracted module integration: all data sources are explicit local fixtures/adapters.
: "${MONITOR_MODULE:?Extract the P02 core, config and cycle functions into this module}"
source "$MONITOR_MODULE"
setup() {
    OUTPUT_FORMAT=json; MONITOR_CPU=true; MONITOR_MEMORY=true; MONITOR_DISK=true; MONITOR_PROCESSES=true
    get_config() { case $1 in disk_mounts) printf '/fixture';; *) printf '%s' "${2:-}";; esac; }
    get_cpu_usage() { printf '95.5\n'; }
    get_memory_info() { printf '{"percent_used":50.0,"used_kb":500}\n'; }
    get_disk_usage() { printf '{"percent_used":25,"mount_point":"/fixture"}\n'; }
    get_process_info() { printf '{"total_processes":0,"total_threads":0,"zombie_processes":0,"top_processes":[]}\n'; }
    get_hostname() { printf 'fixture"host'; }
    send_alert() { printf '%s %s\n' "$1" "$2" >> "$TEST_WORK_DIR/alerts"; }
}
test_monitor_full_cycle() {
    run_monitoring_cycle > "$TEST_WORK_DIR/result.json"
    python3 - "$TEST_WORK_DIR/result.json" <<'PY'
import json,sys
data=json.load(open(sys.argv[1])); assert set(data['metrics'])=={'cpu','memory','disks','processes'}
assert data['hostname']=='fixture"host' and data['metrics']['cpu']['status']=='CRITICAL'
PY
    assert_file_contains "$TEST_WORK_DIR/alerts" 'CRITICAL cpu'
}
test_unavailable_is_null_with_failure_status() {
    get_cpu_usage() { return 2; }
    local rc=0; if run_monitoring_cycle > "$TEST_WORK_DIR/unavailable.json"; then :; else rc=$?; fi
    assert_equals 1 "$rc"
    python3 - "$TEST_WORK_DIR/unavailable.json" <<'PY'
import json,sys
assert json.load(open(sys.argv[1]))['metrics']['cpu'] is None
PY
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
        if (( 10#$octet > 255 )); then
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
    
    # TODO: Implement compressed IPv6 and embedded IPv4 validation; regex alone is insufficient.
    :
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
    : # TODO: Supply assertions; this placeholder is not a test result.
}

test_parse_config_handles_comments() {
    # Test that lines with # are ignored
    : # TODO: Supply assertions; this placeholder is not a test result.
}

test_parse_config_handles_empty_lines() {
    # Test for empty lines
    : # TODO: Supply assertions; this placeholder is not a test result.
}

test_parse_config_handles_quoted_values() {
    # Test for values in quotes
    : # TODO: Supply assertions; this placeholder is not a test result.
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

## Running the maintained repository tests

From `SEM06`, `python3 -m pytest tests/test_capstone.py` runs the repository's project tests (pytest is a declared development dependency). `python3 -m unittest discover -s tests -p test_teaching_examples.py` runs maintained example tests. The extracted chapter runner and test modules above require their documented module paths; neither these commands nor a syntax check claim execution of Docker, systemd, remote SSH or production deployment.

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
