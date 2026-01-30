# S05_TC05 - Logging and Debugging in Bash

> **Operating Systems** | ASE Bucharest - CSIE  
> Laboratory material - Seminar 5 (NEW - Redistributed)

---

> 🚨 **BEFORE STARTING THE ASSIGNMENT**
>
> 1. Download and configure the `002HWinit` package (see STUDENT_GUIDE_EN.md)
> 2. Open a terminal and navigate to `~/HOMEWORKS`
> 3. Start recording with:
>    ```bash
>    python3 record_homework_tui_EN.py
>    ```
>    or the Bash version:
>    ```bash
>    ./record_homework_EN.sh
>    ```
> 4. Complete the requested data (name, group, assignment number)
> 5. **ONLY THEN** begin solving the requirements below

---

## Objectives

At the end of this lab, the student will be able to:
- Implement a professional logging system
- Use log levels (DEBUG, INFO, WARN, ERROR)
- Apply debugging techniques for scripts
- Configure output for production vs development

---


## 2. Logging Levels

### 2.1 Level System

```bash
#!/bin/bash

# Log levels (higher = more important)
declare -A LOG_LEVELS=(
    [DEBUG]=0
    [INFO]=1
    [WARN]=2
    [ERROR]=3
    [FATAL]=4
)

# Current level (default INFO)
LOG_LEVEL="${LOG_LEVEL:-INFO}"
LOG_FILE="${LOG_FILE:-/dev/null}"

# Generic log function
_log() {
    local level="$1"
    shift
    local message="$*"
    
    # Check if should be displayed
    local current_level="${LOG_LEVELS[$LOG_LEVEL]}"
    local msg_level="${LOG_LEVELS[$level]}"
    
    if (( msg_level >= current_level )); then
        local timestamp
        timestamp=$(date '+%Y-%m-%d %H:%M:%S')
        local output="[$timestamp] [$level] $message"
        
        # stderr for WARN+, stdout for INFO/DEBUG
        if (( msg_level >= 2 )); then
            echo "$output" >&2
        else
            echo "$output"
        fi
        
        # Log to file
        echo "$output" >> "$LOG_FILE"
    fi
}

# Helper functions for each level
log_debug() { _log DEBUG "$@"; }
log_info()  { _log INFO "$@"; }
log_warn()  { _log WARN "$@"; }
log_error() { _log ERROR "$@"; }
log_fatal() { _log FATAL "$@"; exit 1; }
```

### 2.2 Usage

```bash
#!/bin/bash
source logging.sh

LOG_LEVEL=DEBUG
LOG_FILE="/var/log/myapp.log"

log_debug "Entering function process_data()"
log_info "Processing file: $filename"
log_warn "File size exceeds recommended limit"
log_error "Failed to parse line 42"
log_fatal "Cannot connect to database"  # Exits script
```

### 2.3 Colours for Terminal

```bash
#!/bin/bash

# ANSI colours
RED='\033[0;31m'
YELLOW='\033[0;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
GRAY='\033[0;90m'
NC='\033[0m'  # No Colour

# Check if output is terminal
if [[ -t 1 ]]; then
    USE_COLOUR=true
else
    USE_COLOUR=false
fi

_log_colour() {
    local level="$1"
    local colour="$2"
    shift 2
    
    local timestamp
    timestamp=$(date '+%H:%M:%S')
    
    if [[ "$USE_COLOUR" == true ]]; then
        printf "${GRAY}[%s]${NC} ${colour}[%-5s]${NC} %s\n" "$timestamp" "$level" "$*"
    else
        printf "[%s] [%-5s] %s\n" "$timestamp" "$level" "$*"
    fi
}

log_debug() { _log_colour DEBUG "$GRAY" "$@"; }
log_info()  { _log_colour INFO "$GREEN" "$@"; }
log_warn()  { _log_colour WARN "$YELLOW" "$@" >&2; }
log_error() { _log_colour ERROR "$RED" "$@" >&2; }
```

---

## 3. Advanced Logging

### 3.1 Context and Caller Info

```bash
#!/bin/bash

log_with_context() {
    local level="$1"
    shift
    
    local func="${FUNCNAME[1]:-main}"
    local line="${BASH_LINENO[0]}"
    local file="${BASH_SOURCE[1]##*/}"
    
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    printf "[%s] [%s] %s:%s in %s(): %s\n" \
        "$timestamp" "$level" "$file" "$line" "$func" "$*"
}

# Test
my_function() {
    log_with_context INFO "Processing item"
}

my_function
# Output: [2025-01-27 15:30:45] [INFO] script.sh:15 in my_function(): Processing item
```

### 3.2 Simple Log Rotation

```bash
#!/bin/bash

LOG_FILE="/var/log/myapp.log"
MAX_SIZE=$((10 * 1024 * 1024))  # 10MB
MAX_FILES=5

rotate_logs() {
    [[ -f "$LOG_FILE" ]] || return
    
    local size
    size=$(stat -c%s "$LOG_FILE" 2>/dev/null || echo 0)
    
    if (( size > MAX_SIZE )); then
        for ((i=MAX_FILES-1; i>=1; i--)); do
            [[ -f "${LOG_FILE}.$i" ]] && mv "${LOG_FILE}.$i" "${LOG_FILE}.$((i+1))"
        done
        mv "$LOG_FILE" "${LOG_FILE}.1"
        touch "$LOG_FILE"
        log_info "Log rotated"
    fi
}

# Call periodically
rotate_logs
```

### 3.3 Structured Logging (JSON)

```bash
#!/bin/bash

log_json() {
    local level="$1"
    shift
    local message="$*"
    
    local timestamp
    timestamp=$(date -Iseconds)
    
    printf '{"timestamp":"%s","level":"%s","message":"%s","pid":%d}\n' \
        "$timestamp" "$level" "$message" "$$"
}

log_json INFO "Application started"
log_json ERROR "Connection failed"

# Output:
# {"timestamp":"2025-01-27T15:30:45+00:00","level":"INFO","message":"Application started","pid":12345}
```

---

## 4. Debugging Techniques

### 4.1 `set -x` - Trace Mode

```bash
#!/bin/bash

# Activate trace for entire script
set -x

# Or just for a section
set -x
# ... code to debug
set +x
```

### 4.2 Customised PS4

```bash
#!/bin/bash

# PS4 controls the prefix of lines in trace mode
# Default: "+ "

# With useful information
export PS4='+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'

set -x
echo "test"
# Output: +(script.sh:8): main(): echo test
```

### 4.3 Conditional Debug

```bash
#!/bin/bash

DEBUG="${DEBUG:-false}"

debug() {
    if [[ "$DEBUG" == true ]]; then
        echo "[DEBUG] $*" >&2
    fi
}

debug "Variable x = $x"
debug "Entering loop"

# Run: DEBUG=true ./script.sh
```

### 4.4 Trap DEBUG

```bash
#!/bin/bash

# Execute code before EVERY command
trap 'echo "Executing: $BASH_COMMAND"' DEBUG

x=1
y=2
z=$((x + y))
echo $z

# Output:
# Executing: x=1
# Executing: y=2
# Executing: z=$((x + y))
# Executing: echo $z
# 3
```

### 4.5 bashdb (Debugger)

```bash
# Installation
sudo apt install bashdb

# Usage
bashdb script.sh

# bashdb commands:
# n (next) - next line
# s (step) - step into function
# c (continue) - continue
# p VAR - print variable
# b LINE - breakpoint
# q (quit) - exit
```

---

## 5. Profiling

### 5.1 Simple Timing

```bash
#!/bin/bash

time_start() {
    _START_TIME=$(date +%s.%N)
}

time_end() {
    local end_time
    end_time=$(date +%s.%N)
    local duration
    duration=$(echo "$end_time - $_START_TIME" | bc)
    echo "Duration: ${duration}s"
}

time_start
# ... operations
time_end
```

### 5.2 Function Profiling

```bash
#!/bin/bash

declare -A FUNC_TIMES

profile_start() {
    local func="${FUNCNAME[1]}"
    FUNC_TIMES["${func}_start"]=$(date +%s.%N)
}

profile_end() {
    local func="${FUNCNAME[1]}"
    local start="${FUNC_TIMES["${func}_start"]}"
    local end
    end=$(date +%s.%N)
    local duration
    duration=$(echo "$end - $start" | bc)
    echo "[PROFILE] $func: ${duration}s" >&2
}

my_function() {
    profile_start
    # ... operations
    sleep 1
    profile_end
}

my_function
# Output: [PROFILE] my_function: 1.003s
```

---

## 6. Complete Template

```bash
#!/bin/bash
#
# Script: myapp.sh
# Description: Application with professional logging
#

set -euo pipefail

# === CONFIGURATION ===
readonly SCRIPT_NAME=$(basename "$0")
readonly SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
readonly LOG_FILE="${LOG_FILE:-/var/log/${SCRIPT_NAME%.sh}.log}"
readonly LOG_LEVEL="${LOG_LEVEL:-INFO}"

# === LOGGING ===
declare -A LOG_LEVELS=([DEBUG]=0 [INFO]=1 [WARN]=2 [ERROR]=3)

_log() {
    local level="$1"; shift
    local current="${LOG_LEVELS[$LOG_LEVEL]}"
    local msg_level="${LOG_LEVELS[$level]}"
    
    (( msg_level >= current )) || return 0
    
    local ts=$(date '+%Y-%m-%d %H:%M:%S')
    local msg="[$ts] [$level] $*"
    
    if (( msg_level >= 2 )); then
        echo "$msg" >&2
    else
        echo "$msg"
    fi
    
    echo "$msg" >> "$LOG_FILE"
}

log_debug() { _log DEBUG "$@"; }
log_info()  { _log INFO "$@"; }
log_warn()  { _log WARN "$@"; }
log_error() { _log ERROR "$@"; }

die() {
    log_error "$@"
    exit 1
}

# === MAIN ===
main() {
    log_info "Starting $SCRIPT_NAME"
    log_debug "Log level: $LOG_LEVEL"
    log_debug "Log file: $LOG_FILE"
    
    # Script logic here
    
    log_info "Completed successfully"
}

main "$@"
```

---

## 7. Exercises

### Exercise 1
Implement a logging system with 4 levels and coloured output.

### Exercise 2
Create a script that records timing for each function called.

### Exercise 3
Write a script with debug mode activatable via environment variable.

---

## Cheat Sheet

```bash
# SIMPLE LOGGING
log() { echo "[$(date '+%H:%M:%S')] $*"; }

# LOGGING TO FILE
log() { echo "[$(date)] $*" | tee -a "$LOG_FILE"; }

# LEVELS
log_debug() { [[ "$DEBUG" == true ]] && echo "[DEBUG] $*" >&2; }
log_error() { echo "[ERROR] $*" >&2; }

# DEBUGGING
set -x              # Trace on
set +x              # Trace off
export PS4='+(${BASH_SOURCE}:${LINENO}): '

# TIMING
time command
SECONDS=0; ...; echo "${SECONDS}s"

# COLOURS
RED='\033[0;31m'; NC='\033[0m'
echo -e "${RED}Error${NC}"
```

---

## 📤 Completion and Submission

After completing all requirements:

1. **Stop recording** by typing:
   ```bash
   STOP_tema
   ```
   or press `Ctrl+D`

2. **Wait** - the script will:
   - Generate the cryptographic signature
   - Automatically upload the file to the server

3. **Check the final message**:
   - ✅ `UPLOAD SUCCESSFUL!` - the assignment was submitted
   - ❌ If upload fails, the `.cast` file is saved locally - send it manually later with the displayed command

> ⚠️ **DO NOT modify the `.cast` file** after generation - the signature becomes invalid!

---

*By Revolvix for OPERATING SYSTEMS class | restricted licence 2017-2030*
