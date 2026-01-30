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
| 255 | Exit code out of range | Error specifying code |

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
- Commands with `||` or `&&`
- Commands in subshells `$(...)` (version dependent)
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
echo $?  # 1 - code of first command that fails

# Practical example
cat /nonexistent/file 2>/dev/null | grep "pattern"
# Without pipefail: $? = exit code of grep (can be 0 or 1)
# With pipefail: $? = 1 (cat failed)
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
# Avoid pipefail (not POSIX) and use other mechanisms
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
#!/bin/bash
set -euo pipefail

#-------------------------------------------------------------------------------
# Variables for cleanup
#-------------------------------------------------------------------------------
declare -g TEMP_DIR=""
declare -g LOCK_FILE=""
declare -ga CLEANUP_FILES=()

#-------------------------------------------------------------------------------
# Cleanup handler
#-------------------------------------------------------------------------------
cleanup() {
    local exit_code=$?
    
    # Disable trap to avoid recursion
    trap - EXIT ERR INT TERM
    
    echo "[CLEANUP] Starting cleanup (exit code: $exit_code)..."
    
    # Cleanup temporary files
    for file in "${CLEANUP_FILES[@]}"; do
        if [[ -e "$file" ]]; then
            rm -f "$file" && echo "[CLEANUP] Removed: $file"
        fi
    done
    
    # Cleanup temporary directory
    if [[ -n "$TEMP_DIR" && -d "$TEMP_DIR" ]]; then
        rm -rf "$TEMP_DIR" && echo "[CLEANUP] Removed temp dir: $TEMP_DIR"
    fi
    
    # Release lock
    if [[ -n "$LOCK_FILE" && -f "$LOCK_FILE" ]]; then
        rm -f "$LOCK_FILE" && echo "[CLEANUP] Released lock: $LOCK_FILE"
    fi
    
    echo "[CLEANUP] Cleanup completed"
    exit "$exit_code"
}

# Register handler
trap cleanup EXIT ERR INT TERM

#-------------------------------------------------------------------------------
# Helper functions for resource management
#-------------------------------------------------------------------------------
register_temp_file() {
    local file="$1"
    CLEANUP_FILES+=("$file")
}

create_temp_dir() {
    TEMP_DIR=$(mktemp -d)
    echo "$TEMP_DIR"
}

acquire_lock() {
    local lock_file="$1"
    
    if [[ -f "$lock_file" ]]; then
        local pid
        pid=$(<"$lock_file")
        if kill -0 "$pid" 2>/dev/null; then
            echo "Already running (PID: $pid)" >&2
            return 1
        fi
        echo "Removing stale lock file"
        rm -f "$lock_file"
    fi
    
    echo $$ > "$lock_file"
    LOCK_FILE="$lock_file"
    return 0
}

#-------------------------------------------------------------------------------
# Main
#-------------------------------------------------------------------------------
main() {
    # Resources that will be cleaned up automatically
    local tmp_dir
    tmp_dir=$(create_temp_dir)
    
    local tmp_file="${tmp_dir}/data.tmp"
    register_temp_file "$tmp_file"
    
    acquire_lock "/var/run/myapp.lock" || exit 1
    
    # Simulate work
    echo "Working in $tmp_dir..."
    echo "data" > "$tmp_file"
    
    # Intentional error for demonstration
    # false
    
    echo "Success!"
}

main "$@"
```

### Pattern: Error Handler with Stack Trace

```bash
#!/bin/bash
set -euo pipefail

#-------------------------------------------------------------------------------
# Error Handler with diagnostic information
#-------------------------------------------------------------------------------
error_handler() {
    local exit_code=$?
    local line_no="${1:-}"
    local bash_lineno="${2:-}"
    local last_command="${3:-}"
    local func_stack="${4:-}"
    
    echo ""
    echo "═══════════════════════════════════════════════════════════════"
    echo "  ERROR OCCURRED"
    echo "═══════════════════════════════════════════════════════════════"
    echo "  Exit Code:    $exit_code"
    echo "  Line Number:  $line_no"
    echo "  Command:      $last_command"
    echo ""
    
    # Stack trace
    if [[ -n "$func_stack" ]]; then
        echo "  Stack Trace:"
        echo "  ------------"
        local i=0
        local frames
        IFS=' ' read -ra frames <<< "$func_stack"
        for func in "${frames[@]}"; do
            local lineno="${BASH_LINENO[$i]:-?}"
            echo "    [$i] $func (line $lineno)"
            ((i++))
        done
    fi
    
    echo ""
    echo "═══════════════════════════════════════════════════════════════"
}

# Trap ERR with extended information
trap 'error_handler "${LINENO}" "${BASH_LINENO[*]}" "$BASH_COMMAND" "${FUNCNAME[*]}"' ERR

#-------------------------------------------------------------------------------
# Test functions
#-------------------------------------------------------------------------------
level3() {
    echo "In level3..."
    false  # Error here
}

level2() {
    echo "In level2..."
    level3
}

level1() {
    echo "In level1..."
    level2
}

#-------------------------------------------------------------------------------
# Main
#-------------------------------------------------------------------------------
main() {
    echo "Starting..."
    level1
    echo "Finished"  # Never reaches here
}

main "$@"
```

Example output:
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
#!/bin/bash

#-------------------------------------------------------------------------------
# Try-catch implementation
#-------------------------------------------------------------------------------

# Global variables for exceptions
declare -g EXCEPTION=""
declare -g EXCEPTION_CODE=0

# "throw" - raise exception
throw() {
    EXCEPTION="$1"
    EXCEPTION_CODE="${2:-1}"
    return "$EXCEPTION_CODE"
}

# "try" - execute block with error capture
try() {
    local -a commands=("$@")
    
    EXCEPTION=""
    EXCEPTION_CODE=0
    
    # Temporary errexit disable
    local old_errexit
    old_errexit=$(set +o | grep errexit)
    set +e
    
    # Execute commands
    "${commands[@]}"
    EXCEPTION_CODE=$?
    
    # Restore errexit
    eval "$old_errexit"
    
    return 0  # try always returns 0
}

# "catch" - check if exception occurred
catch() {
    local pattern="${1:-.*}"
    
    if [[ $EXCEPTION_CODE -ne 0 ]]; then
        if [[ "$EXCEPTION" =~ $pattern ]]; then
            return 0  # Exception caught
        fi
    fi
    return 1  # No exception caught
}

#-------------------------------------------------------------------------------
# Usage example
#-------------------------------------------------------------------------------
risky_operation() {
    local success_probability=$((RANDOM % 10))
    
    if [[ $success_probability -lt 3 ]]; then
        throw "NetworkError: Connection failed" 60
    elif [[ $success_probability -lt 5 ]]; then
        throw "IOError: File not accessible" 40
    fi
    
    echo "Operation successful"
}

main() {
    try risky_operation
    
    if catch "NetworkError"; then
        echo "Caught network error: $EXCEPTION"
        echo "Retrying..."
        try risky_operation
    fi
    
    if catch "IOError"; then
        echo "Caught IO error: $EXCEPTION"
        echo "Using fallback..."
    fi
    
    if catch; then
        echo "Caught unexpected error: $EXCEPTION (code: $EXCEPTION_CODE)"
    fi
    
    echo "Continuing execution..."
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
    ((ERROR_COUNT++))
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
            ((i++))
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
        ((line_num++))
        
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
        mkdir -p "$log_dir"
    fi
    
    log_debug "Logging initialised (level: $LOG_LEVEL, file: ${LOG_FILE:-<none>})"
}

#-------------------------------------------------------------------------------
# Export for sourcing
#-------------------------------------------------------------------------------
export -f log log_trace log_debug log_info log_warn log_error log_fatal
export -f log_context log_operation_start log_operation_end log_var
export LOG_LEVEL LOG_FILE
```

### Usage in Projects

```bash
#!/bin/bash
source "$(dirname "$0")/lib/logging.sh"

# Configuration
init_logging "DEBUG" "/var/log/myapp/app.log"

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
    
    if [[ some_condition ]]; then
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
