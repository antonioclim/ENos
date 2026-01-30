# CAPSTONE Project Architecture

## Design Principles and Modularisation

---

## 1. Introduction to Bash Software Architecture

Developing Bash scripts of significant size requires a rigorous architectural 
approach, similar to that applied in traditional programming languages. The 
lack of a formal module or class system in Bash does not constitute an 
insurmountable limitation but rather a design challenge that stimulates 
creative solutions based on conventions and discipline.

### 1.1 Why Architecture Matters

A 100-line script can survive without structure. A 2000+ line project without 
architecture rapidly becomes a "big ball of mud" - spaghetti code impossible 
to maintain, test or extend. CAPSTONE projects, with their inherent complexity, 
demonstrate the value of investing in solid architecture.

**Benefits of good architecture**:
- **Comprehensibility** - Clear structure enables rapid understanding
- **Testability** - Isolated components can be tested independently
- **Reusability** - Well-defined modules serve multiple contexts
- **Maintainability** - Modifications affect localised areas
- **Collaboration** - Multiple developers can work simultaneously

### 1.2 Bash-Specific Challenges

Bash presents characteristics that complicate architecture:

**Lack of namespaces** - All functions and global variables share the same 
namespace. Collisions are possible and dangerous.

**Text-based evaluation** - Everything is a string, including "numbers". 
Extreme dynamic typing can produce surprising behaviours.

**Implicit global state** - Variables are global by default. Side effects 
are easily produced accidentally.

**Lack of formal imports** - `source` executes code inline, without 
encapsulation or fine control of exports.

The CAPSTONE architecture systematically addresses these challenges through 
strict conventions and patterns validated in practice.

---

## 2. Directory Structure

File organisation reflects and supports logical architecture. Standardised 
structure enables intuitive navigation and prevents chaos.

### 2.1 Standard Layout

```
project/
├── project.sh                 # Main entry point
│
├── bin/                       # Installable executables
│   └── sysproject             # Wrapper for system PATH
│
├── etc/                       # Configurations
│   ├── project.conf           # Runtime configuration
│   ├── project.conf.example   # Template with documentation
│   └── defaults.conf          # Default values (optional)
│
├── lib/                       # Libraries and modules
│   ├── core/                  # Essential functionality
│   │   ├── config.sh          # Configuration management
│   │   ├── engine.sh          # Business logic
│   │   └── parser.sh          # CLI parsing
│   │
│   └── utils/                 # General utilities
│       ├── common.sh          # Helper functions
│       ├── logging.sh         # Logging system
│       └── validation.sh      # Input validation
│
├── var/                       # Runtime variable data
│   ├── log/                   # Log files
│   ├── run/                   # PID files, sockets
│   ├── lib/                   # Persistent data
│   └── cache/                 # Persistent temporary data
│
├── tests/                     # Test suite
│   ├── unit/                  # Unit tests
│   ├── integration/           # Integration tests
│   ├── fixtures/              # Test data
│   └── mocks/                 # Stubs for isolation
│
├── docs/                      # Documentation
│   ├── README.md              # Main documentation
│   ├── ARCHITECTURE.md        # Architectural details
│   └── API.md                 # Function reference
│
└── hooks/                     # User extensions (optional)
    ├── pre_operation.sh
    └── post_operation.sh
```

### 2.2 Organisation Rationale

**bin/** - Contains short wrappers that set up the environment and invoke 
the main script. These files are installed in the system PATH (/usr/local/bin).

**etc/** - Configuration is separated from code to allow adjustments without 
modifying sources. The `.example` file serves as inline documentation.

**lib/** - Separation into `core/` and `utils/` distinguishes project-specific 
logic from general reusable utilities.

**var/** - Follows Unix convention for variable data. Subdirectories reflect 
the nature of data (logs, runtime, persistent).

**tests/** - Structure mirrors lib/ for clear correspondence between modules 
and their tests.

---

## 3. The Module System

### 3.1 Naming Conventions

Systematic prefixing prevents collisions in the global namespace:

```bash
# Format: module_function or MODULE_VARIABLE

# logging.sh
LOG_LEVEL=""                    # Module variable
log_info() { ... }              # Public function
log_debug() { ... }
_log_format_message() { ... }   # Private function (_ prefix)

# config.sh
CONFIG_FILE=""
config_load() { ... }
config_get() { ... }
_config_parse_line() { ... }

# monitor engine
MONITOR_INTERVAL=""
monitor_start() { ... }
monitor_collect_cpu() { ... }
_monitor_calculate_percentage() { ... }
```

**The `_` convention** - Functions prefixed with `_` are considered private, 
for internal module use. There is no enforcement in Bash, but the convention 
signals intent.

### 3.2 Module Structure

Each file in lib/ follows a consistent template:

```bash
#!/bin/bash
#
# Module: logging.sh
# Description: Centralized logging functionality
# Dependencies: none
# Exports: log_init, log_debug, log_info, log_warn, log_error
#

#
# GUARD - Prevent multiple sourcing
#

[[ -n "${_LOGGING_SH_LOADED:-}" ]] && return 0
readonly _LOGGING_SH_LOADED=1

#
# CONSTANTS
#

readonly LOG_LEVEL_DEBUG=0
readonly LOG_LEVEL_INFO=1
readonly LOG_LEVEL_WARN=2
readonly LOG_LEVEL_ERROR=3

#
# MODULE STATE
#

LOG_CURRENT_LEVEL=${LOG_LEVEL_INFO}
LOG_FILE=""
LOG_TO_STDERR=1

#
# PRIVATE FUNCTIONS
#

_log_format_timestamp() {
    date '+%Y-%m-%d %H:%M:%S'
}

_log_write() {
    local level="$1"
    local message="$2"
    local timestamp
    timestamp=$(_log_format_timestamp)
    
    local formatted="[${timestamp}] [${level}] ${message}"
    
    if [[ -n "${LOG_FILE}" ]]; then
        echo "${formatted}" >> "${LOG_FILE}"
    fi
    
    if [[ "${LOG_TO_STDERR}" -eq 1 ]]; then
        echo "${formatted}" >&2
    fi
}

#
# PUBLIC FUNCTIONS
#

log_init() {
    local file="${1:-}"
    local level="${2:-info}"
    
    if [[ -n "${file}" ]]; then
        LOG_FILE="${file}"
        local log_dir
        log_dir=$(dirname "${LOG_FILE}")
        mkdir -p "${log_dir}"
    fi
    
    case "${level,,}" in
        debug) LOG_CURRENT_LEVEL=${LOG_LEVEL_DEBUG} ;;
        info)  LOG_CURRENT_LEVEL=${LOG_LEVEL_INFO}  ;;
        warn)  LOG_CURRENT_LEVEL=${LOG_LEVEL_WARN}  ;;
        error) LOG_CURRENT_LEVEL=${LOG_LEVEL_ERROR} ;;
    esac
}

log_debug() {
    [[ ${LOG_CURRENT_LEVEL} -le ${LOG_LEVEL_DEBUG} ]] && \
        _log_write "DEBUG" "$*"
}

log_info() {
    [[ ${LOG_CURRENT_LEVEL} -le ${LOG_LEVEL_INFO} ]] && \
        _log_write "INFO" "$*"
}

log_warn() {
    [[ ${LOG_CURRENT_LEVEL} -le ${LOG_LEVEL_WARN} ]] && \
        _log_write "WARN" "$*"
}

log_error() {
    [[ ${LOG_CURRENT_LEVEL} -le ${LOG_LEVEL_ERROR} ]] && \
        _log_write "ERROR" "$*"
}
```

### 3.3 Module Loading

The main script orchestrates loading in correct order:

```bash
#!/bin/bash

# Determine script location
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="${SCRIPT_DIR}/lib"

# Source utilities first (no dependencies)
source "${LIB_DIR}/utils/common.sh"
source "${LIB_DIR}/utils/logging.sh"
source "${LIB_DIR}/utils/validation.sh"

# Source core modules (may depend on utils)
source "${LIB_DIR}/core/config.sh"
source "${LIB_DIR}/core/parser.sh"
source "${LIB_DIR}/core/engine.sh"
```

**The loading guard** (`_MODULE_SH_LOADED`) prevents:
- Variable reinitialisation
- Function redefinition (costly)
- Duplicate side effects

---

## 4. State Management

### 4.1 Controlled Global Variables

Bash encourages global state, but this must be managed with discipline:

```bash
#
# GLOBAL STATE - Declared explicitly at top
#

# Configuration
declare -g CONFIG_FILE=""
declare -g CONFIG_LOADED=0

# Runtime state
declare -g OPERATION_MODE=""
declare -g VERBOSE=0
declare -g DRY_RUN=0

# Data structures (associative arrays)
declare -gA SETTINGS=()
declare -gA METRICS=()

#
# Constants - readonly after initialisation
#

# Set during init, then frozen
VERSION=""
INSTALL_DIR=""

freeze_constants() {
    readonly VERSION
    readonly INSTALL_DIR
}
```

**Principles**:
- Explicit declaration with `declare -g`
- Logical grouping and commenting
- Constants marked `readonly` after initialisation
- Avoid ad-hoc global variables in functions

### 4.2 Local Variables in Functions

Functions use local variables to prevent global pollution:

```bash
process_file() {
    local file="$1"
    local -i line_count=0
    local -a lines=()
    local line
    
    while IFS= read -r line; do
        lines+=("$line")
        ((line_count++))
    done < "$file"
    
    # line_count and lines do not affect the exterior
    echo "${line_count}"
}
```

**`local`** - Variable exists only in function and descendants.
**`local -i`** - Local integer variable.
**`local -a`** - Local indexed array.
**`local -A`** - Local associative array.

### 4.3 Passing Data Between Functions

Without complex return values, Bash uses other mechanisms:

**The stdout method (preferred)**:
```bash
get_timestamp() {
    date '+%Y%m%d_%H%M%S'
}

# Usage
timestamp=$(get_timestamp)
```

**The output variable method (for multiple values)**:
```bash
parse_config_line() {
    local line="$1"
    local -n _key="$2"     # nameref
    local -n _value="$3"   # nameref
    
    _key="${line%%=*}"
    _value="${line#*=}"
}

# Usage
declare key value
parse_config_line "name=test" key value
echo "Key: $key, Value: $value"
```

**The global array method (for collections)**:
```bash
declare -ga FOUND_FILES=()

find_files() {
    local pattern="$1"
    FOUND_FILES=()  # Reset
    
    while IFS= read -r -d '' file; do
        FOUND_FILES+=("$file")
    done < <(find . -name "$pattern" -print0)
}

# Usage
find_files "*.sh"
echo "Found ${#FOUND_FILES[@]} files"
```

---

## 5. Design Patterns

### 5.1 Initialisation Pattern

The standardised initialisation sequence ensures consistency:

```bash
main() {
    # Phase 1: Bootstrap
    init_paths
    
    # Phase 2: Load modules
    load_libraries
    
    # Phase 3: Setup infrastructure
    setup_traps
    init_logging
    
    # Phase 4: Parse input
    parse_arguments "$@"
    
    # Phase 5: Load configuration
    load_configuration
    
    # Phase 6: Validate environment
    check_dependencies
    validate_permissions
    
    # Phase 7: Execute
    execute_operation
    
    # Phase 8: Cleanup (via trap)
}

init_paths() {
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"
    
    LIB_DIR="${SCRIPT_DIR}/lib"
    ETC_DIR="${SCRIPT_DIR}/etc"
    VAR_DIR="${SCRIPT_DIR}/var"
    
    readonly SCRIPT_DIR SCRIPT_NAME LIB_DIR ETC_DIR VAR_DIR
}
```

### 5.2 Configuration Pattern

Configuration management follows clear principles:

```bash
# etc/project.conf.example
#
# Project Configuration
# Copy to project.conf and customize
#

# Logging
LOG_LEVEL=info          # debug|info|warn|error
LOG_FILE=/var/log/project/project.log

# Operation
INTERVAL=60             # seconds
THRESHOLD=80            # percent

# lib/core/config.sh
declare -gA CONFIG=()
declare -gA CONFIG_DEFAULTS=(
    [LOG_LEVEL]="info"
    [LOG_FILE]=""
    [INTERVAL]="60"
    [THRESHOLD]="80"
)

config_load() {
    local config_file="$1"
    
    # Start with defaults
    local key
    for key in "${!CONFIG_DEFAULTS[@]}"; do
        CONFIG[$key]="${CONFIG_DEFAULTS[$key]}"
    done
    
    # Override with file values
    if [[ -f "$config_file" ]]; then
        local line key value
        while IFS= read -r line; do
            # Skip comments and empty lines
            [[ "$line" =~ ^[[:space:]]*# ]] && continue
            [[ -z "${line// }" ]] && continue
            
            key="${line%%=*}"
            value="${line#*=}"
            
            # Remove quotes
            value="${value%\"}"
            value="${value#\"}"
            
            CONFIG[$key]="$value"
        done < "$config_file"
    fi
    
    # Override with environment variables
    for key in "${!CONFIG_DEFAULTS[@]}"; do
        local env_var="PROJECT_${key}"
        if [[ -n "${!env_var:-}" ]]; then
            CONFIG[$key]="${!env_var}"
        fi
    done
}

config_get() {
    local key="$1"
    local default="${2:-}"
    echo "${CONFIG[$key]:-$default}"
}
```

**The precedence hierarchy**:
1. Default values (in code)
2. Configuration file
3. Environment variables (override)
4. Command line arguments (final override)

### 5.3 Command Pattern

Structuring commands enables extensibility:

```bash
# Dispatch table
declare -gA COMMANDS=(
    [start]="cmd_start"
    [stop]="cmd_stop"
    [status]="cmd_status"
    [help]="cmd_help"
)

cmd_start() {
    log_info "Starting service..."
    # Implementation
}

cmd_stop() {
    log_info "Stopping service..."
    # Implementation
}

cmd_status() {
    # Implementation
}

cmd_help() {
    echo "Available commands: ${!COMMANDS[*]}"
}

execute_command() {
    local cmd="$1"
    shift
    
    if [[ -n "${COMMANDS[$cmd]:-}" ]]; then
        "${COMMANDS[$cmd]}" "$@"
    else
        log_error "Unknown command: $cmd"
        cmd_help
        return 1
    fi
}
```

### 5.4 Hook Pattern

The hook system enables extensibility without modifying core code:

```bash
HOOKS_DIR="${SCRIPT_DIR}/hooks"

run_hooks() {
    local hook_name="$1"
    shift
    local hook_args=("$@")
    
    local hook_file="${HOOKS_DIR}/${hook_name}.sh"
    
    if [[ -x "$hook_file" ]]; then
        log_debug "Running hook: $hook_name"
        
        (
            # Subshell for isolation
            export HOOK_NAME="$hook_name"
            export HOOK_ARGS="${hook_args[*]}"
            source "$hook_file"
        )
        local rc=$?
        
        if [[ $rc -ne 0 ]]; then
            log_warn "Hook $hook_name returned $rc"
        fi
        
        return $rc
    fi
    
    return 0  # No hook = success
}

# Usage in main code
run_hooks "pre_operation" "$operation" "$target"
perform_operation
run_hooks "post_operation" "$operation" "$target" "$result"
```

---

## 6. Error Handling Architecture

### 6.1 Exit Code Convention

Exit codes communicate final state:

```bash
# Standard codes
readonly EXIT_SUCCESS=0
readonly EXIT_ERROR=1
readonly EXIT_USAGE=2
readonly EXIT_CONFIG=3
readonly EXIT_DEPENDENCY=4
readonly EXIT_PERMISSION=5
readonly EXIT_TIMEOUT=6
readonly EXIT_INTERRUPTED=130  # 128 + SIGINT(2)

# Project-specific codes (70-99)
readonly EXIT_BACKUP_FAILED=70
readonly EXIT_RESTORE_FAILED=71
readonly EXIT_VERIFY_FAILED=72
```

### 6.2 Trap-based Cleanup

Guaranteed cleanup through traps:

```bash
declare -ga CLEANUP_TASKS=()
declare -g CLEANUP_DONE=0

register_cleanup() {
    CLEANUP_TASKS+=("$1")
}

cleanup() {
    # Prevent multiple executions
    [[ $CLEANUP_DONE -eq 1 ]] && return
    CLEANUP_DONE=1
    
    log_debug "Running cleanup tasks..."
    
    local task
    # Execute in reverse order (LIFO)
    for ((i=${#CLEANUP_TASKS[@]}-1; i>=0; i--)); do
        task="${CLEANUP_TASKS[i]}"
        log_debug "Cleanup: $task"
        eval "$task" 2>/dev/null || true
    done
}

setup_traps() {
    trap cleanup EXIT
    trap 'exit 130' INT
    trap 'exit 143' TERM
}

# Usage
setup_traps

TEMP_DIR=$(mktemp -d)
register_cleanup "rm -rf '$TEMP_DIR'"

LOCK_FILE="/var/run/project.lock"
touch "$LOCK_FILE"
register_cleanup "rm -f '$LOCK_FILE'"
```

### 6.3 Error Propagation

Pattern for propagating errors with context:

```bash
# Error with context
die() {
    local message="$1"
    local code="${2:-$EXIT_ERROR}"
    
    log_error "$message"
    exit "$code"
}

# Conditional die
die_if_error() {
    local rc=$?
    local message="$1"
    local code="${2:-$rc}"
    
    [[ $rc -ne 0 ]] && die "$message" "$code"
}

# Usage
tar czf "$archive" "$source_dir" || \
    die "Failed to create archive" $EXIT_BACKUP_FAILED

cd "$target_dir"
die_if_error "Cannot access directory: $target_dir"
```

---

## 7. Inter-Component Communication

### 7.1 Via Direct Functions

Synchronous calls for rapid operations:

```bash
# Engine calls logging directly
monitor_cpu() {
    log_debug "Collecting CPU metrics"
    
    local usage
    usage=$(_calculate_cpu_usage)
    
    log_info "CPU usage: ${usage}%"
    
    if (( $(echo "$usage > $THRESHOLD" | bc -l) )); then
        alert_send "CPU threshold exceeded: ${usage}%"
    fi
}
```

### 7.2 Via Shared Variables

Global state for coordination:

```bash
# Shared state for inter-component communication
declare -gA METRICS=(
    [cpu]=0
    [memory]=0
    [disk]=0
)

declare -gA ALERTS=()

# Collector updates metrics
collect_metrics() {
    METRICS[cpu]=$(get_cpu_usage)
    METRICS[memory]=$(get_memory_usage)
    METRICS[disk]=$(get_disk_usage)
}

# Alerter reads metrics
check_thresholds() {
    local metric value threshold
    for metric in "${!METRICS[@]}"; do
        value="${METRICS[$metric]}"
        threshold="${THRESHOLDS[$metric]:-100}"
        
        if (( value > threshold )); then
            ALERTS[$metric]="$value exceeds threshold $threshold"
        fi
    done
}
```

### 7.3 Via Files

For persistence or inter-process communication:

```bash
# Status file for daemon communication
STATUS_FILE="${VAR_DIR}/run/status"

write_status() {
    local status="$1"
    local message="${2:-}"
    
    {
        echo "STATUS=$status"
        echo "TIMESTAMP=$(date +%s)"
        echo "PID=$$"
        [[ -n "$message" ]] && echo "MESSAGE=$message"
    } > "${STATUS_FILE}.tmp"
    
    mv "${STATUS_FILE}.tmp" "$STATUS_FILE"
}

read_status() {
    if [[ -f "$STATUS_FILE" ]]; then
        source "$STATUS_FILE"
        echo "$STATUS"
    else
        echo "unknown"
    fi
}
```

---

## 8. Architecture Testability

### 8.1 Design for Testing

Principles that support testing:

**Pure functions when possible**:
```bash
# Testable - no side effects
calculate_percentage() {
    local part="$1"
    local total="$2"
    
    if [[ "$total" -eq 0 ]]; then
        echo "0"
    else
        echo "scale=2; $part * 100 / $total" | bc
    fi
}

# Test
result=$(calculate_percentage 25 100)
[[ "$result" == "25.00" ]] || echo "FAIL"
```

**Dependency injection**:
```bash
# Allows stubbing in tests
send_alert() {
    local message="$1"
    
    # Can be overridden
    "${ALERT_FUNCTION:-_send_alert_default}" "$message"
}

_send_alert_default() {
    # Real implementation
    mail -s "Alert" "$ALERT_EMAIL" <<< "$1"
}

# In test:
ALERT_FUNCTION=mock_alert
mock_alert() { LAST_ALERT="$1"; }
```

**I/O separation**:
```bash
# Function that can read from any source
process_data() {
    local input_fd="${1:-0}"  # default stdin
    
    local line
    while IFS= read -r line <&"$input_fd"; do
        # Process
        echo "$line"
    done
}

# Test with process substitution
output=$(process_data < <(echo -e "line1\nline2"))
```

### 8.2 Test Structure

Organisation corresponding to lib/ structure:

```
tests/
├── unit/
│   ├── utils/
│   │   ├── test_logging.sh
│   │   ├── test_common.sh
│   │   └── test_validation.sh
│   └── core/
│       ├── test_config.sh
│       ├── test_engine.sh
│       └── test_parser.sh
│
├── integration/
│   ├── test_full_workflow.sh
│   └── test_error_scenarios.sh
│
└── fixtures/
    ├── sample.conf
    └── test_data/
```

---

## 9. Complete Example: CPU Monitor Module

```bash
#!/bin/bash
# lib/core/cpu_monitor.sh
# CPU monitoring functionality

[[ -n "${_CPU_MONITOR_SH_LOADED:-}" ]] && return 0
readonly _CPU_MONITOR_SH_LOADED=1

#
# DEPENDENCIES
#

# Assumes logging.sh and common.sh are sourced

#
# MODULE STATE
#

declare -ga _CPU_PREV_VALUES=()
declare -g CPU_THRESHOLD=80

#
# PRIVATE FUNCTIONS
#

_cpu_read_proc_stat() {
    # Returns: user nice system idle iowait irq softirq steal
    local cpu_line
    cpu_line=$(head -1 /proc/stat)
    echo "${cpu_line#cpu }"
}

_cpu_parse_values() {
    local -n values="$1"
    local raw_values
    
    read -ra raw_values <<< "$(_cpu_read_proc_stat)"
    values=("${raw_values[@]}")
}

_cpu_calculate_usage() {
    local -n prev="$1"
    local -n curr="$2"
    
    local -i prev_idle=$((prev[3] + prev[4]))
    local -i curr_idle=$((curr[3] + curr[4]))
    
    local -i prev_total=0 curr_total=0
    local val
    for val in "${prev[@]}"; do prev_total+=$val; done
    for val in "${curr[@]}"; do curr_total+=$val; done
    
    local -i total_diff=$((curr_total - prev_total))
    local -i idle_diff=$((curr_idle - prev_idle))
    
    if [[ $total_diff -eq 0 ]]; then
        echo "0.0"
    else
        echo "scale=1; (1 - $idle_diff / $total_diff) * 100" | bc
    fi
}

#
# PUBLIC FUNCTIONS
#

cpu_monitor_init() {
    local threshold="${1:-80}"
    CPU_THRESHOLD="$threshold"
    
    # Initial reading
    _cpu_parse_values _CPU_PREV_VALUES
    
    log_debug "CPU monitor initialised, threshold: ${CPU_THRESHOLD}%"
}

cpu_get_usage() {
    local -a current_values=()
    _cpu_parse_values current_values
    
    local usage
    usage=$(_cpu_calculate_usage _CPU_PREV_VALUES current_values)
    
    # Update previous for next call
    _CPU_PREV_VALUES=("${current_values[@]}")
    
    echo "$usage"
}

cpu_check_threshold() {
    local usage
    usage=$(cpu_get_usage)
    
    local exceeded=0
    if (( $(echo "$usage > $CPU_THRESHOLD" | bc -l) )); then
        exceeded=1
        log_warn "CPU usage ${usage}% exceeds threshold ${CPU_THRESHOLD}%"
    fi
    
    echo "$usage"
    return $exceeded
}

cpu_get_per_core() {
    local -a result=()
    local line core_num
    
    while IFS= read -r line; do
        if [[ "$line" =~ ^cpu[0-9]+ ]]; then
            core_num="${line%%[[:space:]]*}"
            core_num="${core_num#cpu}"
            # Simplified - just idle percentage
            local values
            read -ra values <<< "${line#cpu* }"
            local total=0 idle=${values[3]}
            for v in "${values[@]}"; do total=$((total + v)); done
            local pct
            pct=$(echo "scale=1; (1 - $idle / $total) * 100" | bc)
            result+=("core${core_num}:${pct}%")
        fi
    done < /proc/stat
    
    echo "${result[*]}"
}
```

---

## 10. Best Practices Summary

### Structure
- Clear organisation in functional directories
- Separation of code/configuration/data
- Consistent naming conventions

### Modules
- Guards to prevent re-sourcing
- Private functions with `_` prefix
- Dependencies documented in header

### State
- Global variables declared explicitly
- `local` in functions mandatory
- Constants `readonly` after initialisation

### Communication
- Prefer stdout for return values
- Nameref for multiple output
- Files for persistence

### Errors

Key aspects: standardised exit codes, cleanup via trap exit and errors propagated with context.


### Testing
- Pure functions when possible
- Injectable dependencies
- Test structure parallel to lib/

---

*Next document: S06_02_Monitor_Implementation.md - System Monitor Implementation Details*
