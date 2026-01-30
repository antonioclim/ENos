# Technical Guide - OS Project Development

> **Best Practices and Recommended Patterns**  
> **Operating Systems** | ASE Bucharest - CSIE

---

## Contents

1. [Project Structure](#-project-structure)
2. [Code Conventions](#-code-conventions)
3. [Recommended Patterns](#-recommended-patterns)
4. [Error Handling](#-error-handling)
5. [Logging and Debugging](#-logging-and-debugging)
6. [Testing](#-testing)
7. [Performance](#-performance)
8. [Security](#-security)

---

## Project Structure

### Recommended Standard Structure

```
project/
├── README.md                 # Main documentation
├── Makefile                  # Build/test/install automation
├── .gitignore                # Files ignored by Git
│
├── src/                      # Source code
│   ├── main.sh               # Main entry point
│   ├── lib/                  # Libraries and modules
│   │   ├── utils.sh          # Utility functions
│   │   ├── config.sh         # Configuration management
│   │   ├── logging.sh        # Logging system
│   │   └── validation.sh     # Input validation
│   └── commands/             # Subcommands (if CLI)
│       ├── cmd_start.sh
│       ├── cmd_stop.sh
│       └── cmd_status.sh
│
├── etc/                      # Configuration files
│   ├── config.conf           # Default configuration
│   └── config.conf.example   # Configuration example
│
├── tests/                    # Automated tests
│   ├── test_utils.sh
│   ├── test_main.sh
│   └── run_all_tests.sh
│
├── docs/                     # Extended documentation
│   ├── INSTALL.md
│   ├── USAGE.md
│   └── ARCHITECTURE.md
│
└── examples/                 # Usage examples
    ├── example_basic.sh
    └── example_advanced.sh
```

### Standard Makefile

```makefile
.PHONY: all test lint install clean help

SHELL := /bin/bash
PROJECT := $(shell basename $(CURDIR))

all: lint test

test:
	@echo "Running tests..."
	@./tests/run_all_tests.sh

lint:
	@echo "ShellCheck verification..."
	@shellcheck -x src/*.sh src/lib/*.sh

install:
	@echo "Installing $(PROJECT)..."
	@mkdir -p ~/.local/bin
	@cp src/main.sh ~/.local/bin/$(PROJECT)
	@chmod +x ~/.local/bin/$(PROJECT)

clean:
	@echo "Cleaning..."
	@rm -rf /tmp/$(PROJECT)_*

help:
	@echo "Available commands:"
	@echo "  make test    - Run tests"
	@echo "  make lint    - Check code quality"
	@echo "  make install - Install locally"
	@echo "  make clean   - Delete temporary files"
```

---

## Code Conventions

### Standard Script Header

```bash
#!/bin/bash
#===============================================================================
# NAME: script_name.sh
# DESCRIPTION: Short description of what the script does
# AUTHOR: Name Surname
# VERSION: 1.0.0
# DATE: 2025-01-20
# LICENCE: Educational use - ASE CSIE OS
#===============================================================================

set -euo pipefail
IFS=$'\n\t'

# Constants
readonly SCRIPT_NAME="$(basename "$0")"
readonly SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
readonly VERSION="1.0.0"
```

### Naming Conventions

```bash
# Local variables: snake_case
local user_name="student"
local file_count=0

# Global variables/constants: UPPER_SNAKE_CASE
readonly CONFIG_DIR="/etc/myapp"
declare -g VERBOSE=false

# Functions: snake_case with descriptive prefix
log_info() { ... }
validate_input() { ... }
process_file() { ... }

# Arrays: plural
declare -a files=()
declare -A config_options=()
```

### Comments

```bash
# Single line comment for short explanations

#---------------------------------------
# Major section - with separator
#---------------------------------------

# Function description:
# Arguments:
# $1 - First argument (mandatory)
# $2 - Second argument (optional, default: "value")
# Returns:
# 0 - success
# 1 - validation error
# Example:
# process_data "input.txt" "output.txt"
process_data() {
    local input="$1"
    local output="${2:-default.txt}"
    # ... implementation
}
```

---

## Recommended Patterns

### 1. Pattern: Library Sourcing

```bash
#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Source libraries
source "${SCRIPT_DIR}/lib/utils.sh"
source "${SCRIPT_DIR}/lib/logging.sh"
source "${SCRIPT_DIR}/lib/config.sh"

# Verify that functions exist
type log_info &>/dev/null || { echo "Error: logging.sh invalid"; exit 1; }
```

### 2. Pattern: Argument Parsing with getopts

```bash
usage() {
    cat << EOF
Usage: ${SCRIPT_NAME} [OPTIONS] <argument>

Options:
    -h, --help      Display this message
    -v, --verbose   Verbose mode
    -c FILE         Configuration file
    -o DIR          Output directory

Examples:
    ${SCRIPT_NAME} -v input.txt
    ${SCRIPT_NAME} -c config.conf -o /tmp/output
EOF
}

parse_args() {
    while getopts ":hvc:o:" opt; do
        case ${opt} in
            h) usage; exit 0 ;;
            v) VERBOSE=true ;;
            c) CONFIG_FILE="$OPTARG" ;;
            o) OUTPUT_DIR="$OPTARG" ;;
            :) echo "Error: -${OPTARG} requires argument"; exit 1 ;;
            \?) echo "Error: invalid option -${OPTARG}"; exit 1 ;;
        esac
    done
    shift $((OPTIND - 1))
    
    # Remaining positional arguments
    ARGS=("$@")
}
```

### 3. Pattern: Cleanup on Exit

```bash
# Global temporary file
TEMP_DIR=""

cleanup() {
    local exit_code=$?
    
    # Restore state
    if [[ -n "${TEMP_DIR:-}" && -d "$TEMP_DIR" ]]; then
        rm -rf "$TEMP_DIR"
        log_debug "Cleaned: $TEMP_DIR"
    fi
    
    # Other cleanup actions
    
    exit $exit_code
}

# Register trap at the beginning
trap cleanup EXIT INT TERM

# Create temporary directory
TEMP_DIR="$(mktemp -d)"
```

### 4. Pattern: Lock File (Single Instance)

```bash
LOCK_FILE="/var/run/${SCRIPT_NAME}.lock"

acquire_lock() {
    if [[ -f "$LOCK_FILE" ]]; then
        local pid
        pid=$(cat "$LOCK_FILE")
        if kill -0 "$pid" 2>/dev/null; then
            echo "Error: Instance already running (PID: $pid)"
            exit 1
        fi
        # Dead process, remove old lock
        rm -f "$LOCK_FILE"
    fi
    
    echo $$ > "$LOCK_FILE"
}

release_lock() {
    rm -f "$LOCK_FILE"
}

trap release_lock EXIT
acquire_lock
```

### 5. Pattern: Configuration from File

```bash
# config.conf:
# KEY=value
# ANOTHER_KEY="value with spaces"

load_config() {
    local config_file="${1:-/etc/myapp/config.conf}"
    
    if [[ ! -f "$config_file" ]]; then
        log_warn "Configuration missing: $config_file"
        return 1
    fi
    
    # Safe reading (ignores comments and empty lines)
    while IFS='=' read -r key value; do
        # Skip comments and empty lines
        [[ "$key" =~ ^[[:space:]]*# ]] && continue
        [[ -z "$key" ]] && continue
        
        # Remove whitespace and quotes
        key=$(echo "$key" | xargs)
        value=$(echo "$value" | xargs | sed 's/^["'\'']//;s/["'\'']$//')
        
        # Export as variable
        declare -g "CONFIG_${key}=${value}"
    done < "$config_file"
}
```

---

## Error Handling

### Handling Strategies

```bash
# 1. Immediate exit on error (recommended for simple scripts)
set -e

# 2. Manual handling for complex scripts
set +e  # Disable automatic exit

result=$(some_command 2>&1)
exit_code=$?

if [[ $exit_code -ne 0 ]]; then
    log_error "Command failed: $result"
    handle_error "$exit_code"
fi

set -e  # Reactivate

# 3. Simulated try-catch pattern
try() {
    "$@"
}

catch() {
    local exit_code=$?
    if [[ $exit_code -ne 0 ]]; then
        "$@"
    fi
    return $exit_code
}

# Usage:
try risky_operation || catch handle_error
```

### Descriptive Error Messages

```bash
die() {
    local message="$1"
    local code="${2:-1}"
    
    echo "ERROR [${SCRIPT_NAME}]: ${message}" >&2
    echo "  Line: ${BASH_LINENO[0]}" >&2
    echo "  Function: ${FUNCNAME[1]:-main}" >&2
    
    exit "$code"
}

# Usage:
[[ -f "$file" ]] || die "File does not exist: $file" 2
```

---

## Logging and Debugging

### Complete Logging System

```bash
# logging.sh

# Log levels
declare -A LOG_LEVELS=([DEBUG]=0 [INFO]=1 [WARN]=2 [ERROR]=3 [FATAL]=4)
LOG_LEVEL="${LOG_LEVEL:-INFO}"
LOG_FILE="${LOG_FILE:-/dev/null}"

log() {
    local level="$1"
    shift
    local message="$*"
    
    # Check level
    [[ ${LOG_LEVELS[$level]} -lt ${LOG_LEVELS[$LOG_LEVEL]} ]] && return
    
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local color=""
    local reset="\033[0m"
    
    case $level in
        DEBUG) color="\033[36m" ;;  # Cyan
        INFO)  color="\033[32m" ;;  # Green
        WARN)  color="\033[33m" ;;  # Yellow
        ERROR) color="\033[31m" ;;  # Red
        FATAL) color="\033[35m" ;;  # Magenta
    esac
    
    # Output to terminal (with colours)
    printf "${color}[%s] [%-5s] %s${reset}\n" "$timestamp" "$level" "$message" >&2
    
    # Output to file (without colours)
    if [[ "$LOG_FILE" != "/dev/null" ]]; then
        printf "[%s] [%-5s] %s\n" "$timestamp" "$level" "$message" >> "$LOG_FILE"
    fi
}

log_debug() { log DEBUG "$@"; }
log_info()  { log INFO "$@"; }
log_warn()  { log WARN "$@"; }
log_error() { log ERROR "$@"; }
log_fatal() { log FATAL "$@"; exit 1; }
```

### Debugging with set -x

```bash
# Selective activation for sections
debug_section() {
    set -x
    # Debugged code
    problematic_function
    set +x
}

# Or with environment variable
if [[ "${DEBUG:-false}" == "true" ]]; then
    set -x
fi
```

---

## Testing

### Simple Test Framework

```bash
#!/bin/bash

*Personal note: Bash has ugly syntax, I admit. But it runs everywhere, and that matters enormously in practice.*

# test_utils.sh

source "$(dirname "$0")/../src/lib/utils.sh"

# Counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Assert functions
assert_equals() {
    local expected="$1"
    local actual="$2"
    local message="${3:-}"
    
    ((TESTS_RUN++))
    
    if [[ "$expected" == "$actual" ]]; then
        echo "✅ PASS: $message"
        ((TESTS_PASSED++))
    else
        echo "❌ FAIL: $message"
        echo "   Expected: '$expected'"
        echo "   Actual:   '$actual'"
        ((TESTS_FAILED++))
    fi
}

assert_true() {
    local condition="$1"
    local message="${2:-}"
    
    ((TESTS_RUN++))
    
    if eval "$condition"; then
        echo "✅ PASS: $message"
        ((TESTS_PASSED++))
    else
        echo "❌ FAIL: $message (condition: $condition)"
        ((TESTS_FAILED++))
    fi
}

assert_file_exists() {
    local file="$1"
    assert_true "[[ -f '$file' ]]" "File exists: $file"
}

# Final report
print_summary() {
    echo ""
    echo "════════════════════════════════════"
    echo "TEST SUMMARY"
    echo "────────────────────────────────────"
    echo "Total:   $TESTS_RUN"
    echo "Passed:  $TESTS_PASSED"
    echo "Failed:  $TESTS_FAILED"
    echo "════════════════════════════════════"
    
    [[ $TESTS_FAILED -eq 0 ]] && return 0 || return 1
}

# Test examples
test_string_functions() {
    echo "=== Test: String Functions ==="
    
    result=$(trim "  hello  ")
    assert_equals "hello" "$result" "trim whitespace"
    
    result=$(to_upper "hello")
    assert_equals "HELLO" "$result" "to uppercase"
}

# Main
test_string_functions
print_summary
```

---

## Performance

### Common Optimisations

```bash
# Slow: Subshell for each iteration
for file in *.txt; do
    count=$(wc -l < "$file")
    echo "$file: $count"
done

# Fast: Single command
wc -l *.txt

# Slow: Useless cat
cat file.txt | grep pattern

*(`grep` is probably the command I use most often. Simple, fast, efficient.)*


# Fast: Direct
grep pattern file.txt

# Slow: Loop for reading
while read line; do
    process "$line"
done < file.txt

# Fast (if possible): Block processing
awk '{process}' file.txt
```

### Parallel Processing

```bash
# With xargs
find . -name "*.log" | xargs -P 4 -I {} process_log {}

# With GNU Parallel (if available)
parallel process_log ::: *.log

# With background jobs
for file in *.txt; do
    process_file "$file" &
done
wait  # Wait for all jobs
```

---

## Security

### Input Validation

```bash
validate_path() {
    local path="$1"
    
    # Check path traversal
    if [[ "$path" == *".."* ]]; then
        die "Invalid path: contains '..'"
    fi
    
    # Check dangerous characters
    if [[ "$path" =~ [[:cntrl:]] ]]; then
        die "Invalid path: contains control characters"
    fi
    
    # Normalise
    realpath -m "$path"
}

validate_integer() {
    local value="$1"
    local min="${2:-}"
    local max="${3:-}"
    
    if ! [[ "$value" =~ ^-?[0-9]+$ ]]; then
        die "Invalid value: '$value' is not an integer"
    fi
    
    if [[ -n "$min" && "$value" -lt "$min" ]]; then
        die "Value too small: $value < $min"
    fi
    
    if [[ -n "$max" && "$value" -gt "$max" ]]; then
        die "Value too large: $value > $max"
    fi
}
```

### Injection Avoidance

```bash
# Dangerous: Direct expansion
eval "ls $user_input"

# Safe: Correct quoting
ls "$user_input"

# Dangerous: Command from input
$user_command

# Safe: Command whitelist
case "$user_command" in
    start|stop|status) execute_$user_command ;;
    *) die "Unknown command" ;;
esac
```

---

## Additional Resources

- **ShellCheck Wiki:** https://github.com/koalaman/shellcheck/wiki
- **Bash Pitfalls:** https://mywiki.wooledge.org/BashPitfalls
- **Google Shell Style Guide:** https://google.github.io/styleguide/shellguide.html
- **Advanced Bash Scripting Guide:** https://tldp.org/LDP/abs/html/

---

*Technical Guide - OS Projects | January 2025*
