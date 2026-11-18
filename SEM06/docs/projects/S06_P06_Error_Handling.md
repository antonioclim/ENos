# S06_06: Error Handling in Bash Scripts

> **Laboratory observation:** a good reflex: after a command that *can* fail, look at the exit code (`echo $?`) and the output. In Bash, `set -euo pipefail` helps you, but doesn't excuse you from thinking: verify the input and handle edge cases.
## Introduction

Solid error handling constitutes a fundamental differentiating element between ad-hoc scripts and production-level software. In the context of Unix/Linux systems, where shell scripts orchestrate critical processes and manipulate system resources, rigorous treatment of error conditions becomes imperative for maintaining data integrity and operational stability.

This chapter explores the native Bash mechanisms for error detection and propagation, architectural patterns for graceful recovery and logging strategies that support post-mortem diagnostics.

---

## Exit Codes: The Universal Language of Errors

### Standard Conventions

In the Unix environment, the exit code represents the primary channel for communicating termination state between processes. Established conventions:

| Exit Code | Meaning | Examples |
|-----------|---------|----------|
| 0 | Success | Operation complete without errors |
| 1 | Generic error | Unspecified error |
| 2 | Incorrect usage | Invalid arguments, wrong syntax |
| 64-78 | Standard errors (sysexits.h) | EX_USAGE=64, EX_DATAERR=65, etc. |
| 126 | Command not executable | Missing permissions |
| 127 | Command not found | Command not found |
| 128+N | Termination by signal N | 130=SIGINT, 137=SIGKILL, 143=SIGTERM |
| 255 | Valid status; meaning is application-defined | `exit 255` and `exit -1` yield 255 in Bash |

Codes 1/2 and 64–78 in this table are conventions, not universal meanings for every programme. Bash uses an 8-bit status: `exit 255` → 255, `exit 256` → 0 and `exit -1` → 255. Its command-lookup and signal status conventions are separate from the project-specific codes below.

### Defining Custom Exit Codes

```bash
#!/bin/bash
#===============================================================================
# exit_codes.sh - Standardised error codes for project
#===============================================================================

# Success
declare -gr EXIT_SUCCESS=0

# General errors (1-19)
declare -gr EXIT_FAILURE=1
declare -gr EXIT_USAGE=2
declare -gr EXIT_INVALID_ARGUMENT=3
declare -gr EXIT_MISSING_ARGUMENT=4

# Dependency errors (20-39)
declare -gr EXIT_MISSING_DEPENDENCY=20
declare -gr EXIT_INCOMPATIBLE_VERSION=21
declare -gr EXIT_MISSING_CONFIG=22

# I/O errors (40-59)
declare -gr EXIT_FILE_NOT_FOUND=40
declare -gr EXIT_FILE_NOT_READABLE=41
declare -gr EXIT_FILE_NOT_WRITABLE=42
declare -gr EXIT_DIR_NOT_FOUND=43
declare -gr EXIT_PERMISSION_DENIED=44
declare -gr EXIT_DISK_FULL=45

# Network errors (60-79)
declare -gr EXIT_NETWORK_ERROR=60
declare -gr EXIT_CONNECTION_REFUSED=61
declare -gr EXIT_TIMEOUT=62
declare -gr EXIT_DNS_FAILURE=63

# Process errors (80-99)
declare -gr EXIT_PROCESS_FAILED=80
declare -gr EXIT_ALREADY_RUNNING=81
declare -gr EXIT_LOCK_FAILED=82

# Internal errors (100-119)
declare -gr EXIT_INTERNAL_ERROR=100
declare -gr EXIT_NOT_IMPLEMENTED=101
declare -gr EXIT_ASSERTION_FAILED=102

# Mapping code -> message for diagnostics
declare -grA EXIT_MESSAGES=(
    [$EXIT_SUCCESS]="Success"
    [$EXIT_FAILURE]="General failure"
    [$EXIT_USAGE]="Invalid usage"
    [$EXIT_INVALID_ARGUMENT]="Invalid argument"
    [$EXIT_MISSING_ARGUMENT]="Missing required argument"
    [$EXIT_MISSING_DEPENDENCY]="Missing dependency"
    [$EXIT_INCOMPATIBLE_VERSION]="Incompatible version"
    [$EXIT_MISSING_CONFIG]="Configuration file missing"
    [$EXIT_FILE_NOT_FOUND]="File not found"
    [$EXIT_FILE_NOT_READABLE]="File not readable"
    [$EXIT_FILE_NOT_WRITABLE]="File not writable"
    [$EXIT_DIR_NOT_FOUND]="Directory not found"
    [$EXIT_PERMISSION_DENIED]="Permission denied"
    [$EXIT_DISK_FULL]="Disk full"
    [$EXIT_NETWORK_ERROR]="Network error"
    [$EXIT_CONNECTION_REFUSED]="Connection refused"
    [$EXIT_TIMEOUT]="Operation timeout"
    [$EXIT_DNS_FAILURE]="DNS resolution failed"
    [$EXIT_PROCESS_FAILED]="Process execution failed"
    [$EXIT_ALREADY_RUNNING]="Process already running"
    [$EXIT_LOCK_FAILED]="Failed to acquire lock"
    [$EXIT_INTERNAL_ERROR]="Internal error"
    [$EXIT_NOT_IMPLEMENTED]="Feature not implemented"
    [$EXIT_ASSERTION_FAILED]="Assertion failed"
)

# Helper function for obtaining error message
get_exit_message() {
    local code="$1"
    echo "${EXIT_MESSAGES[$code]:-Unknown error (code: $code)}"
}

# Check if a code indicates error
is_error_code() {
    local code="$1"
    [[ $code -ne 0 ]]
}

# Exit with formatted message
die() {
    local code="${1:-$EXIT_FAILURE}"
    local message="${2:-$(get_exit_message "$code")}"
    
    echo "[FATAL] $message (exit code: $code)" >&2
    exit "$code"
}
```

---

## Shell Options for Defensive Behaviour

### set -e (errexit)

The `errexit` option causes immediate script termination when a command returns a non-zero code:

```bash
#!/bin/bash
set -e  # Or: set -o errexit

echo "Step 1"
false           # Script terminates here with exit code 1
echo "Step 2"   # Never executes
```

**Exceptions to errexit**:
- Commands in conditions (`if cmd; then`)
- Non-final commands in `&&`/`||` lists; the final command is not exempt merely because a list contains these operators
- Command substitutions normally clear errexit in Bash; POSIX mode or `inherit_errexit` (Bash 4.4+) changes this. Parenthesised subshells inherit `-e`
- ERR trap inheritance is separate: `set -E` enables errtrace
- Commands in functions called from conditional contexts

```bash
# These patterns do NOT trigger errexit
if false; then echo "no"; fi            # OK - in condition
false || true                            # OK - has ||
false && echo "no"                       # OK - has &&
result=$(false; echo "after")            # CAUTION - variable behaviour!

# Function called from conditional context
may_fail() {
    false  # Does NOT terminate script when function is called with if
}
if may_fail; then echo "ok"; fi
```

### set -u (nounset)

The `nounset` option treats undefined variables as errors:

```bash
#!/bin/bash
set -u  # Or: set -o nounset

echo "$UNDEFINED_VAR"  # Error: unbound variable

# Patterns for default values
echo "${VAR:-default}"     # Uses "default" if VAR undefined or empty
echo "${VAR-default}"      # Uses "default" only if VAR undefined
echo "${VAR:=default}"     # Sets and returns "default" if undefined
echo "${VAR:+replacement}" # "replacement" only if VAR is defined and non-empty

# Explicit verification
if [[ -v VAR ]]; then
    echo "VAR is set to: $VAR"
else
    echo "VAR is not set"
fi

# Arrays - index verification
declare -a arr=(one two three)
echo "${arr[10]:-}"  # Safe - returns empty for invalid index
```

### set -o pipefail

Normally, the exit code of a pipeline is that of the last command. `pipefail` modifies this behaviour:

```bash
#!/bin/bash

# Without pipefail
false | true
echo $?  # 0 - code of last command

# With pipefail
set -o pipefail
false | true
echo $?  # 1 - rightmost nonzero command status

# Practical example
cat /nonexistent/file 2>/dev/null | grep "pattern"
# Here grep has no input and returns 1; both pipeline modes return 1.
# To observe rightmost-status selection, compare (exit 3) | (exit 7).
```

### The Recommended Combination

```bash
#!/bin/bash
#===============================================================================
# Standard defensive preamble
#===============================================================================

set -o errexit   # -e: Exit immediately on error
set -o nounset   # -u: Error on undefined variables  
set -o pipefail  # Propagate errors in pipeline

# Optional for debugging
# set -o xtrace # -x: Print commands before execution

# Alternatively, the compact form:
# set -euo pipefail

# For scripts requiring POSIX compatibility:
# Check the target shell/version: POSIX.1-2024 specifies pipefail, but many
# deployed /bin/sh implementations predate or do not implement that revision.
```

---

## Trap Handlers: Signal Interception

### The Trap Mechanism

The `trap` command allows defining handlers for signals and pseudo-signals:

```bash
# Syntax
trap 'commands' SIGNALS

# Bash pseudo-signals
# EXIT - At script termination (any exit code)
# ERR - On error (when errexit would trigger exit)
# DEBUG - Before each command
# RETURN - On exit from function or source

# Common signals
# SIGINT (2) - Ctrl+C
# SIGTERM (15) - kill default
# SIGHUP (1) - Terminal closed
# SIGQUIT (3) - Ctrl+\
```

### Pattern: Cleanup on Exit

```bash
#!/usr/bin/env bash
set -euo pipefail
declare -g TEMP_DIR='' LOCK_FD=''
declare -ga CLEANUP_FILES=()
cleanup() {
    local rc=$? file
    trap - EXIT
    for file in "${CLEANUP_FILES[@]}"; do rm -f -- "$file" || true; done
    if [[ -n $TEMP_DIR ]]; then rm -rf -- "$TEMP_DIR" || true; fi
    if [[ -n $LOCK_FD ]]; then exec {LOCK_FD}>&-; fi
    exit "$rc"
}
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM
register_temp_file() { CLEANUP_FILES+=("$1"); }
create_temp_dir() {
    local -n output=$1
    TEMP_DIR=$(mktemp -d) || return 1
    output=$TEMP_DIR # Allocation/registration stays in the parent shell.
}
acquire_lock() {
    local path=$1
    exec {LOCK_FD}>>"$path" || return 1
    if flock -n "$LOCK_FD"; then return 0; fi
    exec {LOCK_FD}>&-; LOCK_FD=''; return 1
}
main() {
    : "${LOCK_DIR:?Set an existing owned writable lock directory}"
    local tmp_dir
    create_temp_dir tmp_dir || return 1
    register_temp_file "$tmp_dir/data.tmp"
    acquire_lock "$LOCK_DIR/myapp.lock" || return 1
    printf 'Working in %s\n' "$tmp_dir"
    printf 'data\n' > "$tmp_dir/data.tmp" || return 1
    # Optional bounded fixture pause; no background daemon is started.
    if [[ ${PAUSE_AFTER_ALLOC:-0} == 1 ]]; then sleep 1; fi
    [[ ${FAIL_AFTER_ALLOC:-0} != 1 ]] || return 7
    printf 'Success!\n'
}
main "$@"
# Lock pathname persists; closing the owned descriptor releases the lock.
```

### Pattern: Error Handler with Stack Trace

```bash
#!/usr/bin/env bash
set -Eeuo pipefail
error_handler() {
    local rc=$1 line=$2 command=$3 function_text=$4 line_text=$5 i
    local -a frames=() lines=()
    trap - ERR # one report, including nested frames, then propagate failure
    IFS=' ' read -r -a frames <<< "$function_text"
    IFS=' ' read -r -a lines <<< "$line_text"
    printf 'ERROR OCCURRED\nExit Code: %s\nLine Number: %s\nCommand: %s\nStack Trace:\n' "$rc" "$line" "$command" >&2
    for ((i=0;i<${#frames[@]};i++)); do
        printf '  [%s] %s (caller line %s)\n' "$i" "${frames[i]}" "${lines[i]:-?}" >&2
    done
    exit "$rc"
}
trap 'error_handler "$?" "$LINENO" "$BASH_COMMAND" "${FUNCNAME[*]}" "${BASH_LINENO[*]}"' ERR
level3() { printf 'In level3...\n'; false; }
level2() { printf 'In level2...\n'; level3; }
level1() { printf 'In level1...\n'; level2; }
main() { printf 'Starting...\n'; level1; printf 'Finished\n'; }
main "$@"
```

Illustrative output shape (line numbers depend on the extracted script; the corrected handler reports the actual frames once):
```
Starting...
In level1...
In level2...
In level3...

═══════════════════════════════════════════════════════════════
  ERROR OCCURRED
═══════════════════════════════════════════════════════════════
  Exit Code:    1
  Line Number:  42
  Command:      false

  Stack Trace:
  ------------
    [0] level3 (line 47)
    [1] level2 (line 52)
    [2] level1 (line 57)
    [3] main (line 63)

═══════════════════════════════════════════════════════════════
```

---

## Error Handling Patterns

### Pattern 1: Simulated Try-Catch

Bash doesn't have native try-catch, but we can simulate the behaviour:

```bash
#!/usr/bin/env bash
# Explicit result capture, not language-level exception unwinding.
declare -g EXCEPTION='' EXCEPTION_CODE=0
throw() { EXCEPTION=$1; EXCEPTION_CODE=${2:-1}; return "$EXCEPTION_CODE"; }
try() {
    EXCEPTION=''; EXCEPTION_CODE=0
    # No shell option is changed. Because this is a conditional call, the
    # operation must explicitly return from each failure branch.
    if "$@"; then EXCEPTION_CODE=0; else EXCEPTION_CODE=$?; fi
    return 0
}
catch() { ((EXCEPTION_CODE != 0)) && [[ $EXCEPTION =~ ${1:-.*} ]]; }
risky_operation() {
    case ${1:-network} in
        network) throw 'NetworkError: Connection failed' 60; return $? ;;
        io) throw 'IOError: File not accessible' 40; return $? ;;
        success) printf 'Operation successful\n' ;;
        *) throw 'ArgumentError: unknown fixture' 2; return $? ;;
    esac
}
main() {
    try risky_operation network
    if catch NetworkError; then printf 'Caught network error: %s\n' "$EXCEPTION"; fi
    try risky_operation success
    if catch; then return "$EXCEPTION_CODE"; fi
    printf 'Continuing execution...\n'
}
main "$@"
```

### Pattern 2: Result Type (Success/Error)

```bash
#!/bin/bash

#-------------------------------------------------------------------------------
# Result Type Implementation
#-------------------------------------------------------------------------------

# Result is represented as "OK:value" or "ERR:message"

result_ok() {
    echo "OK:$1"
}

result_err() {
    echo "ERR:$1"
}

is_ok() {
    [[ "$1" == OK:* ]]
}

is_err() {
    [[ "$1" == ERR:* ]]
}

unwrap() {
    local result="$1"
    
    if is_ok "$result"; then
        echo "${result#OK:}"
        return 0
    else
        echo "Attempted to unwrap error: ${result#ERR:}" >&2
        return 1
    fi
}

unwrap_err() {
    local result="$1"
    
    if is_err "$result"; then
        echo "${result#ERR:}"
        return 0
    else
        echo "Not an error result" >&2
        return 1
    fi
}

unwrap_or() {
    local result="$1"
    local default="$2"
    
    if is_ok "$result"; then
        echo "${result#OK:}"
    else
        echo "$default"
    fi
}

#-------------------------------------------------------------------------------
# Example: Functions that return Result
#-------------------------------------------------------------------------------
divide() {
    local a="$1"
    local b="$2"
    
    if [[ "$b" -eq 0 ]]; then
        result_err "Division by zero"
        return
    fi
    
    result_ok "$(( a / b ))"
}

read_config() {
    local file="$1"
    
    if [[ ! -f "$file" ]]; then
        result_err "Config file not found: $file"
        return
    fi
    
    if [[ ! -r "$file" ]]; then
        result_err "Config file not readable: $file"
        return
    fi
    
    result_ok "$(<"$file")"
}

#-------------------------------------------------------------------------------
# Usage
#-------------------------------------------------------------------------------
main() {
    local result
    
    # Divide example
    result=$(divide 10 2)
    if is_ok "$result"; then
        echo "10 / 2 = $(unwrap "$result")"
    fi
    
    result=$(divide 10 0)
    if is_err "$result"; then
        echo "Error: $(unwrap_err "$result")"
    fi
    
    # With unwrap_or
    result=$(divide 10 0)
    echo "Result with default: $(unwrap_or "$result" "N/A")"
    
    # Chain results
    result=$(read_config "/etc/myapp/config.conf")
    if is_err "$result"; then
        echo "Using default config"
        result=$(result_ok "default=true")
    fi
    local config
    config=$(unwrap "$result")
    echo "Config: $config"
}

main "$@"
```

### Pattern 3: Error Accumulator

Collects multiple errors instead of stopping at the first:

```bash
#!/bin/bash

#-------------------------------------------------------------------------------
# Error Accumulator
#-------------------------------------------------------------------------------
declare -ga ERRORS=()
declare -g ERROR_COUNT=0

clear_errors() {
    ERRORS=()
    ERROR_COUNT=0
}

add_error() {
    local message="$1"
    local code="${2:-1}"
    local context="${3:-}"
    
    local error_entry="[CODE:$code]"
    [[ -n "$context" ]] && error_entry+=" [$context]"
    error_entry+=" $message"
    
    ERRORS+=("$error_entry")
    ERROR_COUNT=$((ERROR_COUNT + 1))
}

has_errors() {
    [[ $ERROR_COUNT -gt 0 ]]
}

get_error_count() {
    echo "$ERROR_COUNT"
}

print_errors() {
    local prefix="${1:-ERROR}"
    
    if has_errors; then
        echo "══════════════════════════════════════════════════════"
        echo " $ERROR_COUNT error(s) occurred:"
        echo "══════════════════════════════════════════════════════"
        local i=1
        for error in "${ERRORS[@]}"; do
            echo " $i. $error"
            i=$((i + 1))
        done
        echo "══════════════════════════════════════════════════════"
    fi
}

#-------------------------------------------------------------------------------
# Example: Validation with error accumulation
#-------------------------------------------------------------------------------
validate_config() {
    local config_file="$1"
    
    clear_errors
    
    # Existence check
    if [[ ! -f "$config_file" ]]; then
        add_error "Config file not found" 40 "validate_config"
        return 1
    fi
    
    # Read and validate parameters
    local line_num=0
    while IFS='=' read -r key value || [[ -n "$key" ]]; do
        line_num=$((line_num + 1))
        
        # Skip comments and empty lines
        [[ "$key" =~ ^[[:space:]]*# ]] && continue
        [[ -z "${key// /}" ]] && continue
        
        # Validate key
        if [[ ! "$key" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
            add_error "Invalid key format: '$key'" 65 "line $line_num"
        fi
        
        # Validate non-empty value for certain keys
        case "$key" in
            *_required|*_path|*_dir)
                if [[ -z "$value" ]]; then
                    add_error "Required value missing for: $key" 65 "line $line_num"
                fi
                ;;
        esac
        
        # Validate paths
        if [[ "$key" == *_path ]] && [[ -n "$value" ]]; then
            if [[ ! -e "$value" ]]; then
                add_error "Path does not exist: $value" 40 "line $line_num"
            fi
        fi
        
    done < "$config_file"
    
    # Return status based on errors
    has_errors && return 1 || return 0
}

#-------------------------------------------------------------------------------
# Usage
#-------------------------------------------------------------------------------
main() {
    local config_file="${1:-/etc/myapp/config.conf}"
    
    echo "Validating configuration..."
    
    if validate_config "$config_file"; then
        echo "Configuration is valid."
    else
        echo "Configuration validation failed!"
        print_errors
        exit 1
    fi
}

main "$@"
```

---

## Logging Framework

### Multi-level Implementation

```bash
#!/bin/bash
#===============================================================================
# logging.sh - Logging framework for production
#===============================================================================

#-------------------------------------------------------------------------------
# Configuration
#-------------------------------------------------------------------------------
declare -g LOG_LEVEL="${LOG_LEVEL:-INFO}"
declare -g LOG_FILE="${LOG_FILE:-}"
declare -g LOG_TO_STDERR="${LOG_TO_STDERR:-1}"
declare -g LOG_TIMESTAMP="${LOG_TIMESTAMP:-1}"
declare -g LOG_PID="${LOG_PID:-1}"
declare -g LOG_FUNC="${LOG_FUNC:-0}"
declare -g LOG_COLOR="${LOG_COLOR:-1}"

# Logging levels (numeric for comparison)
declare -grA LOG_LEVELS=(
    [TRACE]=0
    [DEBUG]=1
    [INFO]=2
    [WARN]=3
    [ERROR]=4
    [FATAL]=5
    [OFF]=6
)

# Colours for output
declare -grA LOG_COLORS=(
    [TRACE]='\033[0;37m'   # Grey
    [DEBUG]='\033[0;36m'   # Cyan
    [INFO]='\033[0;32m'    # Green
    [WARN]='\033[0;33m'    # Yellow
    [ERROR]='\033[0;31m'   # Red
    [FATAL]='\033[1;31m'   # Bold red
)
declare -gr COLOR_RESET='\033[0m'

#-------------------------------------------------------------------------------
# Internal functions
#-------------------------------------------------------------------------------
_log_level_value() {
    echo "${LOG_LEVELS[${1^^}]:-2}"
}

_should_log() {
    local level="$1"
    local current_level_value
    local requested_level_value
    
    current_level_value=$(_log_level_value "$LOG_LEVEL")
    requested_level_value=$(_log_level_value "$level")
    
    [[ $requested_level_value -ge $current_level_value ]]
}

_format_log_message() {
    local level="$1"
    local message="$2"
    local caller_func="${FUNCNAME[3]:-main}"
    local caller_line="${BASH_LINENO[2]:-0}"
    
    local formatted=""
    
    # Timestamp
    if [[ "$LOG_TIMESTAMP" == "1" ]]; then
        formatted+="[$(date '+%Y-%m-%d %H:%M:%S.%3N')] "
    fi
    
    # Level
    if [[ "$LOG_COLOR" == "1" && -t 2 ]]; then
        formatted+="${LOG_COLORS[$level]:-}[${level}]${COLOR_RESET} "
    else
        formatted+="[${level}] "
    fi
    
    # PID
    if [[ "$LOG_PID" == "1" ]]; then
        formatted+="[$$] "
    fi
    
    # Function and line
    if [[ "$LOG_FUNC" == "1" ]]; then
        formatted+="[$caller_func:$caller_line] "
    fi
    
    # Message
    formatted+="$message"
    
    echo -e "$formatted"
}

_write_log() {
    local formatted_message="$1"
    
    # Output to stderr
    if [[ "$LOG_TO_STDERR" == "1" ]]; then
        echo -e "$formatted_message" >&2
    fi
    
    # Output to file
    if [[ -n "$LOG_FILE" ]]; then
        # Strip colours for file
        local clean_message
        clean_message=$(echo -e "$formatted_message" | sed 's/\x1b\[[0-9;]*m//g')
        echo "$clean_message" >> "$LOG_FILE"
    fi
}

#-------------------------------------------------------------------------------
# Public logging functions
#-------------------------------------------------------------------------------
log() {
    local level="${1:-INFO}"
    shift
    local message="$*"
    
    _should_log "$level" || return 0
    
    local formatted
    formatted=$(_format_log_message "$level" "$message")
    _write_log "$formatted"
}

log_trace() { log TRACE "$@"; }
log_debug() { log DEBUG "$@"; }
log_info()  { log INFO "$@"; }
log_warn()  { log WARN "$@"; }
log_error() { log ERROR "$@"; }
log_fatal() { log FATAL "$@"; exit 1; }

#-------------------------------------------------------------------------------
# Helper functions
#-------------------------------------------------------------------------------

# Log with structural context
log_context() {
    local level="$1"
    local context="$2"
    shift 2
    local message="$*"
    
    log "$level" "[$context] $message"
}

# Log for operations (start/end)
log_operation_start() {
    local operation="$1"
    log_info "Starting: $operation"
}

log_operation_end() {
    local operation="$1"
    local status="${2:-success}"
    local duration="${3:-}"
    
    local message="Completed: $operation ($status)"
    [[ -n "$duration" ]] && message+=" [${duration}ms]"
    
    if [[ "$status" == "success" ]]; then
        log_info "$message"
    else
        log_error "$message"
    fi
}

# Log for variables (debugging)
log_var() {
    local var_name="$1"
    local var_value="${!var_name:-<undefined>}"
    log_debug "$var_name = '$var_value'"
}

# Log for arrays
log_array() {
    local -n arr="$1"
    local arr_name="$1"
    
    log_debug "$arr_name = [${arr[*]}] (${#arr[@]} elements)"
}

#-------------------------------------------------------------------------------
# Initialisation
#-------------------------------------------------------------------------------
init_logging() {
    local level="${1:-$LOG_LEVEL}"
    local file="${2:-$LOG_FILE}"
    
    LOG_LEVEL="${level^^}"
    LOG_FILE="$file"
    
    # Create directory for log file if necessary
    if [[ -n "$LOG_FILE" ]]; then
        local log_dir
        log_dir=$(dirname "$LOG_FILE")
        mkdir -p "$log_dir" || return 1
    fi
    
    log_debug "Logging initialised (level: $LOG_LEVEL, file: ${LOG_FILE:-<none>})"
}

#-------------------------------------------------------------------------------
# Export for sourcing
#-------------------------------------------------------------------------------
# Child Bash processes must source this module themselves. Exporting selected
# functions does not export their helper dependencies or associative arrays.
export LOG_LEVEL LOG_FILE
```

### Usage in Projects

```bash
#!/bin/bash
source "$(dirname "$0")/lib/logging.sh"

# Configuration
init_logging "DEBUG" "${LOG_DESTINATION:?Set a log path in an owned directory}"

# Usage
main() {
    log_info "Application starting"
    log_var HOME
    
    log_operation_start "Database connection"
    local start_time=$SECONDS
    
    # Simulate operation
    sleep 1
    
    local duration=$(( (SECONDS - start_time) * 1000 ))
    log_operation_end "Database connection" "success" "$duration"
    
    if [[ ${DEMO_WARNING:-0} == 1 ]]; then
        log_warn "Unusual condition detected"
    fi
    
    log_info "Application finished"
}

main "$@"
```

---

## Practical Exercises

### Exercise 1: Solid Script Template

Create a complete template for solid scripts:

```bash
# Requirements:
# - Defensive preamble (errexit, nounset, pipefail)
# - Standardised exit codes
# - Cleanup handler at EXIT
# - Error handler with stack trace
# - Configurable logging
# - Argument parsing with validation
```

### Exercise 2: Retry Mechanism

Implement a generic retry mechanism with backoff:

```bash
# Requirements:
# - Configurable number of retries
# - Exponential backoff with jitter
# - Logging for each attempt
# - Timeout per attempt
# - Callback for customisation
```

### Exercise 3: Circuit Breaker Pattern

Implement the Circuit Breaker pattern:

```bash
# Requirements:
# - States: CLOSED, OPEN, HALF_OPEN
# - Configurable threshold for opening
# - Timeout for recovery
# - State persistence between executions
```

### Exercise 4: Complete Input Validation

Create a validation framework for input:

```bash
# Requirements:
# - Type validation (string, int, float, email, path)
# - Range validation (min/max)
# - Pattern validation (regex)
# - Descriptive error messages
# - Multiple error accumulation
```

### Exercise 5: Graceful Shutdown

Implement a graceful shutdown mechanism:

```bash
# Requirements:
# - SIGTERM/SIGINT handling
# - Completion of tasks in progress
# - Timeout for forced shutdown
# - Checkpoint for resume
```

---

## Best Practices Summary

1. **Use `set -euo pipefail`** as standard preamble
2. **Define clear and documented exit codes**
3. **Implement cleanup handlers** with trap
4. **Log at the appropriate level** - not too much, not too little
5. **Validate input** before processing
6. **Fail early** (fail fast) when problems are detected
7. **Provide context** in error messages
8. **Test error paths** not just the happy path

### Technical reference for the corrected examples

Shell-option exceptions and pipeline status follow the [GNU Bash set documentation](https://www.gnu.org/software/bash/manual/html_node/The-Set-Builtin.html); command-substitution inheritance is described in [Command Execution Environment](https://www.gnu.org/software/bash/manual/html_node/Command-Execution-Environment.html).
