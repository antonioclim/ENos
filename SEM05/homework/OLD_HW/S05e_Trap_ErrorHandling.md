# S05_TC04 - Trap and Error Handling

> **Operating Systems** | ASE Bucharest - CSIE  
> Laboratory material - Seminar 5 (SPLIT from TC6b)

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
- Use `trap` for signal handling
- Implement automatic cleanup on exit
- Create professional error handlers
- Handle interrupts gracefully

---


## 2. Trap EXIT - Automatic Cleanup

### 2.1 Basic Pattern

```bash
#!/bin/bash
set -euo pipefail

# Create temporary resources
TEMP_FILE=$(mktemp)
TEMP_DIR=$(mktemp -d)

# Cleanup function
cleanup() {
    echo "Cleaning up..."
    rm -f "$TEMP_FILE"
    rm -rf "$TEMP_DIR"
}

# Set trap for EXIT
trap cleanup EXIT

# Rest of the script
echo "Working with $TEMP_FILE"
echo "Working with $TEMP_DIR"

# cleanup() executes AUTOMATICALLY on exit
# - either at normal completion
# - or on error (with set -e)
# - or on Ctrl+C (INT)
```

### 2.2 Cleanup with Preserved Exit Code

```bash
#!/bin/bash
set -euo pipefail

TEMP_FILE=$(mktemp)

cleanup() {
    local exit_code=$?  # Save the ORIGINAL exit code
    rm -f "$TEMP_FILE"
    exit $exit_code     # Exit with the original code
}

trap cleanup EXIT

# Script...
```

### 2.3 Conditional Cleanup

```bash
#!/bin/bash
set -euo pipefail

TEMP_FILE=""
KEEP_TEMP=false

cleanup() {
    if [[ "$KEEP_TEMP" == false && -n "$TEMP_FILE" ]]; then
        rm -f "$TEMP_FILE"
    fi
}

trap cleanup EXIT

TEMP_FILE=$(mktemp)
# ...

if [[ "$DEBUG" == true ]]; then
    KEEP_TEMP=true
    echo "Temp file kept: $TEMP_FILE"
fi
```

---

## 3. Trap ERR - Error Handler

### 3.1 Error Handler

```bash
#!/bin/bash
set -euo pipefail

error_handler() {
    local line=$1
    local cmd=$2
    local code=$3
    
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" >&2
    echo "ERROR in script at line $line" >&2
    echo "Command: $cmd" >&2
    echo "Exit code: $code" >&2
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" >&2
}

trap 'error_handler $LINENO "$BASH_COMMAND" $?' ERR

# Test
echo "Before error"
false  # Triggers error_handler
echo "After error"  # Does not execute
```

### 3.2 Handler with Stack Trace

```bash
#!/bin/bash
set -euo pipefail

error_handler() {
    local exit_code=$?
    
    echo "━━━━━━━━━━━ ERROR ━━━━━━━━━━━" >&2
    echo "Exit code: $exit_code" >&2
    echo "Command: $BASH_COMMAND" >&2
    echo "" >&2
    echo "Stack trace:" >&2
    
    local i=0
    while caller $i; do
        ((i++))
    done | while read line func file; do
        echo "  $file:$line in $func()" >&2
    done
    
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" >&2
}

trap error_handler ERR
```

---

## 4. Trap INT/TERM - Interrupts

### 4.1 Handling Ctrl+C

```bash
#!/bin/bash
set -euo pipefail

interrupted=false

handle_interrupt() {
    interrupted=true
    echo ""
    echo "Interrupt received, finishing current task..."
}

trap handle_interrupt INT

for i in {1..100}; do
    if [[ "$interrupted" == true ]]; then
        echo "Exiting gracefully at iteration $i"
        break
    fi
    
    echo "Processing $i..."
    sleep 1
done

echo "Cleanup complete"
```

### 4.2 Temporarily Ignoring Signals

```bash
#!/bin/bash
set -euo pipefail

# Critical section - ignore interrupts
trap '' INT TERM

echo "Critical section - cannot be interrupted"
# ... critical operations
sleep 5

# Restore normal behaviour
trap - INT TERM

echo "Normal section - can be interrupted"
sleep 5
```

### 4.3 Exit Codes for Signals

```bash
#!/bin/bash

cleanup() {
    echo "Cleanup..."
}

trap 'cleanup; exit 130' INT   # 128 + 2 (SIGINT)
trap 'cleanup; exit 143' TERM  # 128 + 15 (SIGTERM)
trap cleanup EXIT

# Script...
```

---

## 5. Advanced Patterns

### 5.1 Complete Trap (Best Practice)

```bash
#!/bin/bash
set -euo pipefail

# Global variables for resources
TEMP_FILES=()
LOCK_FILE=""
PID_FILE=""

# Cleanup function
cleanup() {
    local exit_code=$?
    
    # Cleanup temp files
    for f in "${TEMP_FILES[@]:-}"; do
        [[ -f "$f" ]] && rm -f "$f"
    done
    
    # Remove lock file
    [[ -f "$LOCK_FILE" ]] && rm -f "$LOCK_FILE"
    
    # Remove PID file
    [[ -f "$PID_FILE" ]] && rm -f "$PID_FILE"
    
    exit $exit_code
}

# Error handler
on_error() {
    echo "[ERROR] Line $1: Command '$2' failed with exit code $3" >&2
}

# Interrupt handler
on_interrupt() {
    echo "" >&2
    echo "[WARN] Script interrupted" >&2
    exit 130
}

# Setup traps
trap cleanup EXIT
trap 'on_error $LINENO "$BASH_COMMAND" $?' ERR
trap on_interrupt INT TERM

# Helper for temp files
create_temp() {
    local f
    f=$(mktemp)
    TEMP_FILES+=("$f")
    echo "$f"
}

# Main script
main() {
    local temp1
    temp1=$(create_temp)
    
    echo "Working..."
    # ...
}

main "$@"
```

### 5.2 Lock File with Trap

```bash
#!/bin/bash
set -euo pipefail

LOCK_FILE="/var/run/myscript.lock"

acquire_lock() {
    if [[ -f "$LOCK_FILE" ]]; then
        local pid
        pid=$(cat "$LOCK_FILE")
        if kill -0 "$pid" 2>/dev/null; then
            echo "Error: Script already running (PID $pid)" >&2
            exit 1
        fi
        echo "Warning: Stale lock file, removing..."
        rm -f "$LOCK_FILE"
    fi
    
    echo $$ > "$LOCK_FILE"
}

release_lock() {
    rm -f "$LOCK_FILE"
}

trap release_lock EXIT

acquire_lock

# Script...
echo "Running with PID $$"
sleep 30
```

### 5.3 Nested Traps

```bash
#!/bin/bash
set -euo pipefail

# List of cleanup handlers
declare -a CLEANUP_HANDLERS=()

# Add handler
add_cleanup() {
    CLEANUP_HANDLERS+=("$1")
}

# Execute all handlers (in reverse order)
run_cleanup() {
    local i
    for ((i=${#CLEANUP_HANDLERS[@]}-1; i>=0; i--)); do
        eval "${CLEANUP_HANDLERS[$i]}"
    done
}

trap run_cleanup EXIT

# Usage
TEMP1=$(mktemp)
add_cleanup "rm -f '$TEMP1'"

TEMP2=$(mktemp)
add_cleanup "rm -f '$TEMP2'"

# Handlers execute in reverse order on EXIT
```

---

## 6. Debug and Troubleshooting

### 6.1 Debug Mode with Trap

```bash
#!/bin/bash
set -euo pipefail

DEBUG="${DEBUG:-false}"

if [[ "$DEBUG" == true ]]; then
    # Display each command before execution
    trap 'echo "+ $BASH_COMMAND" >&2' DEBUG
fi

# Script...
```

### 6.2 Timing with Trap

```bash
#!/bin/bash
set -euo pipefail

START_TIME=$(date +%s)

show_duration() {
    local end_time
    end_time=$(date +%s)
    local duration=$((end_time - START_TIME))
    echo "Script completed in ${duration}s"
}

trap show_duration EXIT

# Script...
```

---

## 7. Exercises

### Exercise 1
Write a script that creates 3 temporary files and deletes them automatically on exit.

### Exercise 2
Implement an error handler that displays the line and command that caused the error.

### Exercise 3
Create a script with a lock file that prevents simultaneous multiple runs.

---

## Cheat Sheet

```bash
# TRAP SYNTAX
trap 'commands' SIGNAL

# COMMON SIGNALS
EXIT          # Any exit
ERR           # Error (with set -e)
INT           # Ctrl+C
TERM          # kill
DEBUG         # Before each command

# CLEANUP PATTERN
trap cleanup EXIT

cleanup() {
    local exit_code=$?
    rm -f "$TEMP_FILE"
    exit $exit_code
}

# ERROR PATTERN
trap 'error_handler $LINENO "$BASH_COMMAND" $?' ERR

# INTERRUPT PATTERN
trap 'echo "Interrupted"; exit 130' INT TERM

# IGNORE SIGNAL
trap '' INT       # Ignore
trap - INT        # Restore default

# USEFUL VARIABLES
$LINENO           # Current line
$BASH_COMMAND     # Current command
$?                # Exit code
$$                # Script PID
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
