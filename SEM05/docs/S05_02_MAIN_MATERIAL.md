# S05_02 - Main Material: Advanced Bash Scripting

> **Laboratory observation:** jot down key commands and relevant output (2–3 lines) as you work. It helps with debugging and, honestly, at the end you get a good README without extra effort.
> **Operating Systems** | ASE Bucharest - CSIE  
> Complete theoretical material - Seminar 5
> Version: 2.0.0 | Date: 2025-01

---

## Table of Contents

1. [Advanced Functions](#1-advanced-functions)
2. [Indexed Arrays](#2-indexed-arrays)
3. [Associative Arrays](#3-associative-arrays)
4. [Settings for Solid Scripts](#4-settings-for-solid-scripts)
5. [Error Handling](#5-error-handling)
6. [Professional Logging](#6-professional-logging)
7. [Debugging](#7-debugging)
8. [Professional Script Template](#8-professional-script-template)
9. [Integration and Best Practices](#9-integration-and-best-practices)

---

## Learning Objectives

At the end of this material, the student will be able to:

| Level | Competency |
|-------|------------|
| **Remember** | List the `set -euo pipefail` options and their effects |
| **Understand** | Explain the difference between local and global variables in functions |
| **Apply** | Use associative arrays for configurations |
| **Analyse** | Identify scenarios where `set -e` does NOT work |
| **Evaluate** | Critique existing scripts for stability |
| **Create** | Build professional scripts using the template |

---

## Prerequisite Knowledge

This material assumes familiarity with:
- Basic Bash syntax (variables, conditions, loops)
- Fundamental Linux commands (ls, cat, grep, find)
- The concept of exit code ($?)
- I/O redirection (stdin, stdout, stderr)

> *A word of encouragement: if you've made it through SEM01-04, you already know more Bash than most developers. This seminar takes you from "functional" to "professional". The gap is smaller than you think, but the impact on your code quality is enormous.*

---

# 1. Advanced Functions

## 1.1 Definition and Documentation

Functions in Bash are reusable code blocks that encapsulate specific logic. Unlike other languages, Bash functions have important particularities that must be understood for correct usage.

*Personal note: Bash has ugly syntax, I admit. But it runs everywhere, and that matters enormously in practice.*


### Definition Syntax

```bash
# Standard form (recommended)
function_name() {
    # code
}

# Alternative form with function keyword
function function_name {
    # code
}

# Combined form (redundant, avoid)
function function_name() {
    # code
}
```

### Documentation Conventions

```bash
#!/bin/bash

# Well-documented function
# ========================================
# greet - Displays a personalised greeting
# ========================================
# USAGE:
# greet <n> [greeting]
#
# ARGUMENTS:
# name - Person's name (mandatory)
# greeting - Greeting text (optional, default: "Hello")
#
# RETURNS:
# 0 - Success
# 1 - Missing required argument
#
# EXAMPLE:
# greet "Maria" # Output: Hello, Maria!
# greet "Ion" "Salut" # Output: Salut, Ion!
# ========================================
greet() {
    local name="${1:?Error: name required}"
    local greeting="${2:-Hello}"
    
    echo "$greeting, $name!"
    return 0
}
```

---

## 1.2 Local Variables and Scope

> ⚠️ **CRITICAL MISCONCEPTION (80% frequency)**
> 
> Variables in Bash functions are **GLOBAL by default**, not local!
> This is the opposite of behaviour in most programming languages.

### Visual Demonstration of the Problem

```bash
#!/bin/bash

# DANGER: Implicit global variable
process_file() {
    count=0                    # GLOBAL! Modifies variable from main
    for item in "$@"; do
        ((count++))
    done
    echo "Processed: $count"
}

count=100                      # Variable in main
echo "Before: count=$count"    # 100

process_file a b c             # Call function
echo "After: count=$count"     # SURPRISE: 3, not 100!
```

### Solution: The `local` Keyword

```bash
#!/bin/bash

# CORRECT: Explicit local variable
process_file() {
    local count=0              # LOCAL! Does not affect outside
    for item in "$@"; do
        ((count++))
    done
    echo "Processed: $count"
}

count=100
echo "Before: count=$count"    # 100
process_file a b c
echo "After: count=$count"     # CORRECT: 100
```

### Golden Rule

```
┌─────────────────────────────────────────────────────────┐
│  ALWAYS use `local` for variables in functions,         │
│  except when you WANT to modify a global variable       │
│  intentionally.                                         │
└─────────────────────────────────────────────────────────┘
```

### Scope and Visibility

```bash
#!/bin/bash

GLOBAL="visible everywhere"

outer_function() {
    local OUTER_VAR="visible in outer and functions defined inside"
    
    inner_function() {
        local INNER_VAR="visible only in inner"
        echo "Inner sees: GLOBAL=$GLOBAL"
        echo "Inner sees: OUTER_VAR=$OUTER_VAR"  # Works!
        echo "Inner sees: INNER_VAR=$INNER_VAR"
    }
    
    inner_function
    echo "Outer sees: INNER_VAR=$INNER_VAR"  # Empty - not visible
}

outer_function
echo "Global sees: OUTER_VAR=$OUTER_VAR"     # Empty - not visible
```

### Modifiers for `local`

```bash
#!/bin/bash

demo_local_modifiers() {
    local -r CONSTANT="cannot be modified"       # readonly
    local -i number=42                           # integer only
    local -a array=(a b c)                       # indexed array
    local -A hash                                # associative array
    local -n ref=$1                              # nameref (Bash 4.3+)
    
    # CONSTANT="something"  # ERROR: readonly variable
    number="not a number"   # Becomes 0 (not a valid integer)
    echo "number=$number"   # 0
}
```

---

## 1.3 Returning Values

> ⚠️ **CRITICAL MISCONCEPTION (75% frequency)**
> 
> `return` in Bash returns only **exit codes** (0-255), NOT strings or complex values!

### Method 1: Echo and Capture (Recommended)

```bash
#!/bin/bash

# Function "returns" via echo
get_sum() {
    local a=$1
    local b=$2
    echo $((a + b))    # This is the "returned value"
}

# Capture with $()
result=$(get_sum 5 3)
echo "Sum: $result"   # 8

# WRONG - what does NOT work:
# result = get_sum 5 3 # Syntax error
# result=get_sum 5 3 # result becomes string "get_sum"
```

### Method 2: Global Variable

```bash
#!/bin/bash

RESULT=""  # Global variable for result

calculate() {
    local a=$1
    local b=$2
    RESULT=$((a + b))  # Sets global
}

calculate 5 3
echo "Sum: $RESULT"   # 8

# Disadvantage: can be accidentally overwritten
```

### Method 3: Return Code (Only for Success/Failure)

```bash
#!/bin/bash

*(Bash has ugly syntax, I admit. But it runs everywhere, and that matters enormously in practice.)*


is_even() {
    local n=$1
    [ $((n % 2)) -eq 0 ]  # Implicit return $?
}

# Usage in condition
if is_even 4; then
    echo "4 is even"
fi

if is_even 7; then
    echo "7 is even"
else
    echo "7 is odd"
fi

# WRONG - does not work for values:
get_value() {
    return 42      # OK, but only 0-255
}
result=$(get_value)  # result is EMPTY, not 42!
get_value
echo $?              # 42 (must be used immediately)

> 💡 Many students initially underestimate the importance of permissions. Then they encounter their first 'Permission denied' and see the light.

```

### Method 4: Nameref (Bash 4.3+)

```bash
#!/bin/bash

# Function receives the variable name to put the result in
get_user_info() {
    local -n result_ref=$1    # Reference to external variable
    local username=$2
    
    result_ref="User: $username, UID: $(id -u "$username" 2>/dev/null || echo 'unknown')"
}

# Usage
declare user_data
get_user_info user_data "root"
echo "$user_data"    # User: root, UID: 0
```

### Method Comparison

| Method | Strengths | Weaknesses |
|--------|-----------|------------|
| Echo + $() | Clean, functional | Subshell overhead |
| Global variable | Fast | Risk of collisions |
| Return code | Intuitive for bool | Only 0-255 |
| Nameref | Flexible | Requires Bash 4.3+ |

---

## 1.4 Recursive Functions

```bash
#!/bin/bash

# Factorial - classic recursion example
factorial() {
    local n=$1
    
    # Base case
    if [ "$n" -le 1 ]; then
        echo 1
        return
    fi
    
    # Recursive step
    local prev
    prev=$(factorial $((n - 1)))
    echo $((n * prev))
}

echo "5! = $(factorial 5)"    # 120
echo "10! = $(factorial 10)"  # 3628800
```

### Fibonacci with Memoization (Optimisation)

```bash
#!/bin/bash

declare -A FIB_CACHE

fib() {
    local n=$1
    
    # Check cache
    if [[ -v FIB_CACHE[$n] ]]; then
        echo "${FIB_CACHE[$n]}"
        return
    fi
    
    local result
    if [ "$n" -le 1 ]; then
        result=$n
    else
        local a b
        a=$(fib $((n - 1)))
        b=$(fib $((n - 2)))
        result=$((a + b))
    fi
    
    FIB_CACHE[$n]=$result
    echo "$result"
}

echo "fib(20) = $(fib 20)"    # 6765 (fast with cache)
```

---

# 2. Indexed Arrays

## 2.1 Creation and Initialisation

> ⚠️ **MISCONCEPTION (55% frequency)**
> 
> Arrays in Bash start from index 0, not 1!

### Creation Methods

```bash
#!/bin/bash

# Empty array
arr=()

# With values (automatic indexing from 0)
fruits=("apple" "banana" "cherry")
echo "${fruits[0]}"    # apple (NOT fruits[1]!)

# With explicit indices (sparse array)
sparse=([0]="first" [5]="sixth" [10]="eleventh")

# From command output
files=($(ls *.txt 2>/dev/null))    # Trap: problems with spaces

# From command output (safe)
mapfile -t lines < file.txt        # Read lines into array
readarray -t words <<< "$(echo "a b c" | tr ' ' '\n')"
```

### Existence Verification

```bash
#!/bin/bash

arr=("a" "b" "c")

# Check if index exists
if [[ -v arr[1] ]]; then
    echo "arr[1] exists: ${arr[1]}"
fi

# Check if array is empty
if [ ${#arr[@]} -eq 0 ]; then
    echo "Array empty"
fi
```

---

## 2.2 Access and Syntax

### Fundamental Syntax

```bash
#!/bin/bash

arr=("alpha" "beta" "gamma" "delta" "epsilon")

# Individual element
echo "${arr[0]}"       # alpha (first)
echo "${arr[2]}"       # gamma (third)
echo "${arr[-1]}"      # epsilon (last, Bash 4.3+)
echo "${arr[-2]}"      # delta (second to last)

# All elements
echo "${arr[@]}"       # alpha beta gamma delta epsilon (separate)
echo "${arr[*]}"       # alpha beta gamma delta epsilon (as string)

# Array length
echo "${#arr[@]}"      # 5

# Element length
echo "${#arr[0]}"      # 5 (length of "alpha")

# All indices
echo "${!arr[@]}"      # 0 1 2 3 4
```

### Slice (Subsequence)

```bash
#!/bin/bash

arr=("a" "b" "c" "d" "e" "f")

# Syntax: ${arr[@]:start:count}
echo "${arr[@]:1:3}"   # b c d (from index 1, 3 elements)
echo "${arr[@]:2}"     # c d e f (from index 2 to end)
echo "${arr[@]::3}"    # a b c (first 3 elements)
```

---

## 2.3 Modifying Arrays

```bash
#!/bin/bash

arr=("a" "b" "c")

# Append element
arr+=("d")             # arr=("a" "b" "c" "d")

# Append multiple
arr+=("e" "f")         # arr=("a" "b" "c" "d" "e" "f")

# Modify element
arr[1]="B"             # arr=("a" "B" "c" "d" "e" "f")

# Insert at specific index
arr[10]="x"            # arr now has gap (sparse)

# Delete element (Trap: does not re-index!)
unset arr[2]           # arr=("a" "B" [gap] "d" "e" "f" ... "x")

# Delete entire array
unset arr

# Reset to empty
arr=()
```

---

## 2.4 Correct Iteration

> ⚠️ **CRITICAL MISCONCEPTION (65% frequency)**
> 
> `for i in ${arr[@]}` is WRONG for elements with spaces!
> Must use `for i in "${arr[@]}"` with quotes.

### Problem Demonstration

```bash
#!/bin/bash

# Array with elements containing spaces
files=("file one.txt" "file two.txt" "my document.pdf")

# WRONG - breaks elements at spaces
echo "=== WRONG (without quotes) ==="
for f in ${files[@]}; do
    echo "-> $f"
done
# Incorrect output:
# -> file
# -> one.txt
# -> file
# -> two.txt
# -> my
# -> document.pdf

# CORRECT - keeps elements intact
echo "=== CORRECT (with quotes) ==="
for f in "${files[@]}"; do
    echo "-> $f"
done
# Correct output:
# -> file one.txt
# -> file two.txt
# -> my document.pdf
```

### Iteration Patterns

```bash
#!/bin/bash

arr=("alpha" "beta" "gamma")

# By values (most common)
for item in "${arr[@]}"; do
    echo "Value: $item"
done

# By indices
for idx in "${!arr[@]}"; do
    echo "[$idx] = ${arr[$idx]}"
done

# C style (only for dense arrays)
for ((i = 0; i < ${#arr[@]}; i++)); do
    echo "[$i] = ${arr[$i]}"
done

# With enumerate (index + value)
idx=0
for item in "${arr[@]}"; do
    echo "[$idx] = $item"
    ((idx++))
done
```

---

## 2.5 Advanced Operations

### Search

```bash
#!/bin/bash

arr=("apple" "banana" "cherry" "date")

# Check element existence
contains() {
    local needle="$1"
    shift
    local item
    for item in "$@"; do
        [[ "$item" == "$needle" ]] && return 0
    done
    return 1
}

if contains "banana" "${arr[@]}"; then
    echo "banana found!"
fi

# With pattern matching
[[ " ${arr[*]} " =~ " cherry " ]] && echo "cherry found!"
```

### Sorting

```bash
#!/bin/bash

arr=("cherry" "apple" "banana" "date")

# Sort and create new array
readarray -t sorted < <(printf '%s\n' "${arr[@]}" | sort)

> 💡 In previous labs, we saw that the most frequent mistake is forgetting quotes for variables with spaces.

echo "Sorted: ${sorted[*]}"    # apple banana cherry date

# Numeric sorting
nums=(42 7 13 99 1)
readarray -t sorted_nums < <(printf '%s\n' "${nums[@]}" | sort -n)
echo "Numerically sorted: ${sorted_nums[*]}"    # 1 7 13 42 99

# Reverse order sorting
readarray -t reversed < <(printf '%s\n' "${arr[@]}" | sort -r)
```

### Filter

```bash
#!/bin/bash

nums=(1 2 3 4 5 6 7 8 9 10)

# Filter even numbers
even=()
for n in "${nums[@]}"; do
    ((n % 2 == 0)) && even+=("$n")
done
echo "Even: ${even[*]}"    # 2 4 6 8 10

# Map (modification)
squared=()
for n in "${nums[@]}"; do
    squared+=("$((n * n))")
done
echo "Squares: ${squared[*]}"    # 1 4 9 16 25 36 49 64 81 100
```

---

# 3. Associative Arrays

## 3.1 Mandatory Declaration

> ⚠️ **CRITICAL MISCONCEPTION (70% frequency)**
> 
> `declare -A` is **MANDATORY** for associative arrays!
> Without it, Bash treats the variable as a normal indexed array.

### Problem Demonstration

```bash
#!/bin/bash

# WRONG - without declare -A
config[host]="localhost"
config[port]="8080"
echo "Host: ${config[host]}"
echo "Indices: ${!config[@]}"    # 0 (treated as indexed array!)

# CORRECT - with declare -A
declare -A settings
settings[host]="localhost"
settings[port]="8080"
echo "Host: ${settings[host]}"
echo "Keys: ${!settings[@]}"    # host port (correct!)
```

### Initialisation Methods

```bash
#!/bin/bash

# Declaration + separate population
declare -A config
config[host]="localhost"
config[port]="8080"
config[user]="admin"

# Declaration + simultaneous initialisation
declare -A database=(
    [host]="db.example.com"
    [port]="5432"
    [name]="production"
    [user]="app_user"
)

# Keys with spaces (require quotes)
declare -A messages=(
    ["error message"]="Something went wrong"
    ["success message"]="Operation completed"
)
```

---

## 3.2 Access and Manipulation

```bash
#!/bin/bash

declare -A config=(
    [host]="localhost"
    [port]="8080"
    [debug]="true"
)

# Element access
echo "${config[host]}"        # localhost

# All values
echo "${config[@]}"           # localhost 8080 true (order undefined!)

# All keys
echo "${!config[@]}"          # host port debug (order undefined!)

# Number of elements
echo "${#config[@]}"          # 3

# Check key existence
if [[ -v config[host] ]]; then
    echo "config[host] exists"
fi

# Default value for non-existent key
echo "${config[missing]:-default_value}"

# Delete element
unset config[debug]

# Delete entire hash
unset config
```

---

## 3.3 Iteration

```bash
#!/bin/bash

declare -A user=(
    [name]="Ion Popescu"
    [email]="ion@example.com"
    [role]="admin"
)

# Iterate through keys
for key in "${!user[@]}"; do
    echo "$key = ${user[$key]}"
done

# Iterate through values only
for value in "${user[@]}"; do
    echo "Value: $value"
done
```

---

## 3.4 Practical Examples

### Config Parser

```bash
#!/bin/bash

declare -A CONFIG

# Parse key=value configuration file
parse_config() {
    local file="$1"
    
    while IFS='=' read -r key value; do
        # Skip comments and empty lines
        [[ "$key" =~ ^[[:space:]]*# ]] && continue
        [[ -z "$key" ]] && continue
        
        # Remove spaces
        key="${key// /}"
        value="${value// /}"
        
        CONFIG["$key"]="$value"
    done < "$file"
}

# Getter with default
get_config() {
    local key="$1"
    local default="${2:-}"
    echo "${CONFIG[$key]:-$default}"
}

# Usage
# parse_config "app.conf"
# echo "Host: $(get_config host localhost)"
```

### Word Counting

```bash
#!/bin/bash

declare -A word_count

# Read and count
count_words() {
    local file="$1"
    local word
    
    while read -r word; do
        ((word_count[$word]++))
    done < <(tr '[:upper:]' '[:lower:]' < "$file" | tr -cs '[:alpha:]' '\n')
}

# Display top N words
show_top() {
    local n="${1:-10}"
    
    for word in "${!word_count[@]}"; do
        echo "${word_count[$word]} $word"
    done | sort -rn | head -n "$n"
}

# Usage
# count_words "document.txt"
# show_top 5
```

### Simple Cache

```bash
#!/bin/bash

declare -A CACHE

# Function with caching
get_cached() {
    local key="$1"
    
    # Check cache
    if [[ -v CACHE[$key] ]]; then
        echo "[CACHE HIT] ${CACHE[$key]}"
        return
    fi
    
    # Expensive calculation (simulated)
    local result
    result="result_for_$key"
    sleep 1  # Simulate slow operation
    
    # Save to cache
    CACHE[$key]="$result"
    echo "[CACHE MISS] $result"
}
```

---

# 4. Settings for Solid Scripts

> **From practice**: `set -euo pipefail` has saved me countless times. I had a backup script that "worked" but actually did nothing because of a variable typo. With `set -u`, it would have crashed immediately and I would have found the problem in 2 minutes, not 2 weeks.

## 4.1 The `set -euo pipefail` Triad

This combination of options transforms a fragile script into a solid one:

```bash
#!/bin/bash

# Recommendation: ALWAYS in the first lines of the script
set -e          # Exit on first error
set -u          # Error for undefined variables  
set -o pipefail # Pipeline returns error from first command that fails
# (without this, a pipe can "hide" errors — very unpleasant surprise at 3 AM when you're deploying)

# Or compact form:
set -euo pipefail

# Plus safe IFS (optional but recommended)
IFS=$'\n\t'
```

---

## 4.2 Detailed Explanation

### `set -e` (errexit)

The script stops automatically when a command returns non-zero:

```bash
#!/bin/bash
set -e

echo "Start"
false           # Returns exit code 1
echo "This line does NOT execute"
```

### `set -u` (nounset)

Error if you use an undefined variable:

```bash
#!/bin/bash
set -u

echo "User: $USER"           # OK - system variable
echo "Missing: $UNDEFINED"   # ERROR: unbound variable
```

### `set -o pipefail`

Without pipefail, the pipeline returns the exit code of the last command:

```bash
#!/bin/bash

# WITHOUT pipefail
false | true
echo $?    # 0 (from true) - error from false is ignored!

# WITH pipefail
set -o pipefail
false | true
echo $?    # 1 (from false) - error is propagated
```

---

## 4.3 Limitations of `set -e`

> ⚠️ **CRITICAL MISCONCEPTION (75% frequency)**
> 
> `set -e` does NOT stop the script on any error!
> There are several cases where errors are ignored.

### Cases Where `set -e` Does NOT Work

```bash
#!/bin/bash
set -e

# 1. Commands in if/while/until conditions
if false; then
    echo "Does not get here"
fi
echo "Script continues"    # EXECUTES!

# 2. Commands followed by || or &&
false || true             # Does not stop
false && true             # Does not stop
echo "Script continues"    # EXECUTES!

# 3. Commands in subshells (without propagation)
(false)                   # Does not stop main script in all cases
echo "Script continues"    # EXECUTES!

# 4. Functions in test context
check() { false; }
if check; then
    echo "No"
fi
echo "Script continues"    # EXECUTES!

# 5. Commands in command substitution in certain contexts
result=$(false)           # Stops
echo "But: $(false)"      # Does NOT stop in some Bash versions!
```

### Solutions for Special Cases

```bash
#!/bin/bash
set -euo pipefail

# For pipes - use shopt
shopt -s inherit_errexit  # Bash 4.4+ - propagates set -e in substitutions

# For explicit checks
result=$(command_that_might_fail) || {
    echo "Command failed with: $?"
    exit 1
}

# For subshells
(
    set -e
    false  # Now stops the subshell
) || exit 1
```

---

## 4.4 Temporary Deactivation

Sometimes you need to execute commands that might fail without stopping the script:

```bash
#!/bin/bash
set -euo pipefail

# Method 1: set +e / set -e
set +e
command_that_might_fail
status=$?
set -e

if [ $status -ne 0 ]; then
    echo "Command failed with status $status"
fi

# Method 2: || true
command_that_might_fail || true

# Method 3: || with handling
command_that_might_fail || {
    echo "Failed, but continuing..."
}

# For undefined variables - default values
echo "${UNDEFINED_VAR:-default_value}"

# Or explicit check
if [[ -n "${OPTIONAL_VAR:-}" ]]; then
    echo "OPTIONAL_VAR is set to: $OPTIONAL_VAR"
fi
```

---

## 4.5 Safe IFS

`IFS` (Internal Field Separator) controls how Bash separates words:

```bash
#!/bin/bash

# Default IFS includes spaces, tab, newline
# This can cause problems with files containing spaces

# Safe IFS - only newline and tab
IFS=$'\n\t'

# Now iteration is safer
for file in $(ls); do
    echo "File: $file"
done

# Remember: quotes should still be used for maximum safety!
for file in *; do
    echo "File: $file"
done
```

---

# 5. Error Handling

## 5.1 Trap for Cleanup

`trap` allows automatic code execution on various signals or events:

```bash
#!/bin/bash
set -euo pipefail

# Temporary resources
TEMP_FILE=""
TEMP_DIR=""

# Cleanup function
cleanup() {
    local exit_code=$?
    
    echo "Cleanup: removing temporary resources..."
    
    [[ -n "$TEMP_FILE" && -f "$TEMP_FILE" ]] && rm -f "$TEMP_FILE"
    [[ -n "$TEMP_DIR" && -d "$TEMP_DIR" ]] && rm -rf "$TEMP_DIR"
    
    exit $exit_code
}

# Set trap for EXIT (executes ALWAYS on exit)
trap cleanup EXIT

# Trap for interrupt signals
trap 'echo "Interrupted!"; exit 130' INT TERM

# Create temporary resources
TEMP_FILE=$(mktemp)
TEMP_DIR=$(mktemp -d)

echo "Working with $TEMP_FILE and $TEMP_DIR"

# ... rest of script ...
# Cleanup executes automatically at end (or on error)
```

---

## 5.2 Trap for ERR

```bash
#!/bin/bash
set -euo pipefail

# Error handler
error_handler() {
    local line=$1
    local command=$2
    local code=$3
    
    echo "═══════════════════════════════════════════" >&2
    echo "ERROR at line $line" >&2
    echo "Command: $command" >&2
    echo "Exit code: $code" >&2
    echo "═══════════════════════════════════════════" >&2
}

# Trap ERR (executes when a command fails)
trap 'error_handler $LINENO "$BASH_COMMAND" $?' ERR

# Test - this command will fail
echo "About to fail..."
false
echo "This line won't execute"
```

> ⚠️ **Trap: trap is NOT inherited in subshells!**
> 
> ```bash
> trap 'echo "Error"' ERR
> (
>     false    # trap does NOT execute here!
> )
> ```

---

## 5.3 The `die()` Function

Standard pattern for fatal errors:

```bash
#!/bin/bash
set -euo pipefail

# Function for fatal errors
die() {
    echo "FATAL ERROR: $*" >&2
    exit 1
}

# Usage
[ $# -ge 1 ] || die "Usage: $0 <filename>"
[ -f "$1" ]  || die "File not found: $1"
[ -r "$1" ]  || die "Cannot read: $1"

command -v jq >/dev/null 2>&1 || die "Required tool 'jq' not installed"
```

---

## 5.4 Verification Patterns

```bash
#!/bin/bash
set -euo pipefail

# === ARGUMENT VERIFICATION ===
[ $# -ge 2 ] || { echo "Usage: $0 <input> <output>"; exit 1; }

INPUT="$1"
OUTPUT="$2"

# === FILE VERIFICATION ===
# File exists
[ -f "$INPUT" ] || die "Input file not found: $INPUT"

# File readable
[ -r "$INPUT" ] || die "Cannot read input: $INPUT"

# Directory exists
[ -d "$(dirname "$OUTPUT")" ] || die "Output directory doesn't exist"

# Can write to directory
[ -w "$(dirname "$OUTPUT")" ] || die "Cannot write to output directory"

# === DEPENDENCY VERIFICATION ===
for cmd in jq curl grep; do
    command -v "$cmd" >/dev/null 2>&1 || die "Required: $cmd"
done

# === PERMISSION VERIFICATION ===
[ "$(id -u)" -eq 0 ] && die "Do not run as root!"

# === ENVIRONMENT VERIFICATION ===
: "${API_KEY:?Error: API_KEY environment variable required}"
: "${DB_HOST:?Error: DB_HOST environment variable required}"
```

---

# 6. Professional Logging

## 6.1 Complete System with Levels

```bash
#!/bin/bash

# Logging configuration
readonly LOG_FILE="${LOG_FILE:-/tmp/$(basename "$0" .sh).log}"
LOG_LEVEL="${LOG_LEVEL:-INFO}"

# Logging levels (increasing severity order)
declare -A LOG_LEVELS=(
    [DEBUG]=0
    [INFO]=1
    [WARN]=2
    [ERROR]=3
    [FATAL]=4
)

# Main logging function
log() {
    local level="$1"
    shift
    local message="$*"
    
    # Check if this level should be logged
    local level_num="${LOG_LEVELS[$level]:-1}"
    local threshold="${LOG_LEVELS[$LOG_LEVEL]:-1}"
    
    [ "$level_num" -lt "$threshold" ] && return
    
    # Format: [TIMESTAMP] [LEVEL] [SCRIPT:LINE] Message
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local log_line="[$timestamp] [$level] [$(basename "$0"):${BASH_LINENO[0]}] $message"
    
    # Write to log file
    echo "$log_line" >> "$LOG_FILE"
    
    # Display on screen based on level
    case "$level" in
        DEBUG|INFO)
            [ "$level_num" -ge "$threshold" ] && echo "$log_line"
            ;;
        WARN)
            echo "$log_line" >&2
            ;;
        ERROR|FATAL)
            echo "$log_line" >&2
            ;;
    esac
}

# Helper functions
log_debug() { log DEBUG "$@"; }
log_info()  { log INFO "$@"; }
log_warn()  { log WARN "$@"; }
log_error() { log ERROR "$@"; }
log_fatal() { log FATAL "$@"; exit 1; }
```

---

## 6.2 Simple Logging

For smaller scripts, a simplified variant:

```bash
#!/bin/bash

readonly LOG_FILE="/tmp/$(basename "$0" .sh).log"

# Simple logging
log() {
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] $*" | tee -a "$LOG_FILE"
}

# Error logging
err() {
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] ERROR: $*" | tee -a "$LOG_FILE" >&2
}

# Usage
log "Script started"
log "Processing file: $INPUT"
err "File not found!"
log "Script completed"
```

---

# 7. Debugging

## 7.1 Debug Options

```bash
#!/bin/bash

# Activate full debug - displays each command before execution
set -x

# Deactivate debug
set +x

# Selective debug for a section
echo "Before debug"
set -x
# commands to debug
set +x
echo "After debug"

# Verbose mode - displays lines read
set -v

# Complete combination for maximum debugging
set -xv
```

---

## 7.2 Conditional Debug Mode

```bash
#!/bin/bash

# Activation from environment
DEBUG="${DEBUG:-false}"
VERBOSE="${VERBOSE:-0}"

# Activate set -x from environment
[[ "$DEBUG" == "true" ]] && set -x

# Debug functions
debug() {
    [[ "$DEBUG" == "true" ]] && echo "[DEBUG] $*" >&2
}

verbose() {
    [ "$VERBOSE" -ge 1 ] && echo "$*" >&2
}

very_verbose() {
    [ "$VERBOSE" -ge 2 ] && echo "[VERBOSE] $*" >&2
}

# Usage
debug "Variable x=$x"
verbose "Processing step 1"
very_verbose "Internal state: $internal_var"
```

---

## 7.3 Practical Debug Techniques

```bash
#!/bin/bash

# Print checkpoints
echo "=== Checkpoint 1: before processing ===" >&2

# Dump variables
echo "DEBUG: var1=$var1, var2=$var2" >&2

# Dump array
echo "DEBUG: array=(${arr[*]})" >&2

# Call stack (who called this function?)
echo "Called from: $(caller 0)" >&2

# Full call stack
local frame=0
while caller $frame; do
    ((frame++))
done

# Trap to see each line executed
trap 'echo "DEBUG: Line $LINENO: $BASH_COMMAND"' DEBUG

# Pause for interactive debugging
read -p "Press Enter to continue..." </dev/tty
```

---

# 8. Professional Script Template

This template incorporates all best practices discussed:

```bash
#!/bin/bash
#
# Script: template.sh
# Description: Template for production scripts
# Author: [Name]
# Version: 1.0.0
# Date: 2025-01
# Licence: MIT
#
# USAGE:
# ./template.sh [options] <input_file>
#
# EXAMPLE:
# ./template.sh -v -o output.txt input.txt
#

# ============================================================
# STRICT MODE
# ============================================================
set -euo pipefail
IFS=$'\n\t'

# ============================================================
# CONSTANTS (readonly - cannot be modified)
# ============================================================
readonly SCRIPT_NAME=$(basename "$0")
readonly SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
readonly SCRIPT_VERSION="1.0.0"

# ============================================================
# DEFAULT CONFIGURATION (can be overridden from environment)
# ============================================================
VERBOSE="${VERBOSE:-0}"
DEBUG="${DEBUG:-false}"
DRY_RUN="${DRY_RUN:-false}"
LOG_FILE="${LOG_FILE:-/tmp/${SCRIPT_NAME%.*}.log}"

# Working variables
INPUT=""
OUTPUT=""

# ============================================================
# HELPER FUNCTIONS
# ============================================================

usage() {
    cat << EOF
$SCRIPT_NAME v$SCRIPT_VERSION

Short description of what the script does.

USAGE:
    $SCRIPT_NAME [options] <input_file>

OPTIONS:
    -h, --help          Display this message
    -V, --version       Display version
    -v, --verbose       Verbose mode (can be repeated: -vv)
    -n, --dry-run       Simulation without changes
    -o, --output FILE   Output file (default: stdout)

ENVIRONMENT:
    DEBUG=true          Activate debug mode
    LOG_FILE=/path      Specify log file

EXAMPLES:
    $SCRIPT_NAME input.txt
    $SCRIPT_NAME -v -o output.txt input.txt
    DEBUG=true $SCRIPT_NAME input.txt

EOF
}

version() {
    echo "$SCRIPT_NAME version $SCRIPT_VERSION"
}

log() {
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] $*" | tee -a "$LOG_FILE"
}

die() {
    echo "FATAL: $*" >&2
    exit 1
}

debug() {
    [[ "$DEBUG" == "true" ]] && echo "[DEBUG] $*" >&2
    return 0
}

verbose() {
    [ "$VERBOSE" -ge 1 ] && echo "$*" >&2
    return 0
}

# ============================================================
# CLEANUP (executes automatically on EXIT)
# ============================================================
cleanup() {
    local exit_code=$?
    
    debug "Cleanup triggered with exit code: $exit_code"
    
    # Cleanup code here (delete temp files, etc.)
    
    exit $exit_code
}

trap cleanup EXIT
trap 'echo "Interrupted"; exit 130' INT TERM

# ============================================================
# ARGUMENT PARSING
# ============================================================
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                usage
                exit 0
                ;;
            -V|--version)
                version
                exit 0
                ;;
            -v|--verbose)
                ((VERBOSE++))
                shift
                ;;
            -n|--dry-run)
                DRY_RUN=true
                shift
                ;;
            -o|--output)
                OUTPUT="$2"
                shift 2
                ;;
            --output=*)
                OUTPUT="${1#*=}"
                shift
                ;;
            --)
                shift
                break
                ;;
            -*)
                die "Unknown option: $1"
                ;;
            *)
                break
                ;;
        esac
    done
    
    # Positional arguments
    [[ $# -ge 1 ]] || die "Missing required argument: input_file"
    INPUT="$1"
}

# ============================================================
# VALIDATION
# ============================================================
validate() {
    debug "Validating input: $INPUT"
    
    [[ -f "$INPUT" ]] || die "File not found: $INPUT"
    [[ -r "$INPUT" ]] || die "Cannot read: $INPUT"
    
    if [[ -n "$OUTPUT" && -e "$OUTPUT" ]]; then
        verbose "Warning: output file exists, will be overwritten"
    fi
}

# ============================================================
# MAIN LOGIC
# ============================================================
process() {
    log "Processing: $INPUT"
    debug "Verbose level: $VERBOSE"
    debug "Dry run: $DRY_RUN"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log "DRY RUN - no changes made"
        return 0
    fi
    
    # === IMPLEMENTATION HERE ===
    
    log "Processing complete"
}

main() {
    parse_args "$@"
    validate
    process
}

# ============================================================
# EXECUTION
# ============================================================
main "$@"
```

---

# 9. Integration and Best Practices

## 9.1 Pre-Commit Checklist

Before considering a script "done":

```
□ Correct shebang: #!/bin/bash
□ set -euo pipefail in first lines
□ All variables in functions have `local`
□ declare -A for all associative arrays
□ Quotes for "${array[@]}" in for loops
□ cleanup() function with trap EXIT
□ die() function for fatal errors
□ usage() function for help
□ Argument validation before processing
□ External dependency checking
□ Logging for important operations
□ shellcheck run without warnings
```

---

## 9.2 Shellcheck

```bash
# Installation
sudo apt install shellcheck

# Usage
shellcheck script.sh

# Ignore specific warning (in script)
# shellcheck disable=SC2086
echo $variable    # intentionally without quotes

# Check all scripts in a directory
find . -name "*.sh" -exec shellcheck {} \;
```

---

## 9.3 Patterns to Avoid

```bash
# WRONG: Global variable in function
process() {
    result="value"    # Modifies global
}

# CORRECT:
process() {
    local result="value"
    echo "$result"
}

# WRONG: Associative array without declare
hash[key]="value"

# CORRECT:
declare -A hash
hash[key]="value"

# WRONG: Iteration without quotes
for i in ${arr[@]}; do

# CORRECT:
for i in "${arr[@]}"; do

# WRONG: Assumption that set -e catches everything
set -e
if command_that_fails; then ...

# CORRECT: Explicit verification
if ! command_that_fails; then
    die "Command failed"
fi
```

---

## 9.4 Additional Resources

| Resource | URL |
|----------|-----|
| Bash Manual | https://www.gnu.org/software/bash/manual/ |
| ShellCheck | https://www.shellcheck.net/ |
| Google Shell Style Guide | https://google.github.io/styleguide/shellguide.html |
| Bash Hackers Wiki | https://wiki.bash-hackers.org/ |
| explainshell.com | https://explainshell.com/ |

---

## Quick Reference Card

```bash
# === ROBUSTNESS ===
set -euo pipefail
IFS=$'\n\t'

# === VARIABLES ===
local var="value"              # In functions
readonly CONST="value"         # Constants
VAR="${VAR:-default}"          # Default value
: "${REQUIRED:?Error msg}"     # Required

# === ARRAYS ===
arr=(a b c)                    # Indexed
declare -A hash                # Associative (MANDATORY!)
"${arr[@]}"                    # Iteration (WITH QUOTES!)

# === FUNCTIONS ===
func() { local v="..."; echo "$1"; return 0; }
result=$(func arg)

# === ERROR HANDLING ===
trap cleanup EXIT
trap 'handler $LINENO' ERR
die() { echo "ERR: $*" >&2; exit 1; }

# === CHECKS ===
[[ -f "$f" ]] || die "does not exist"
[[ -n "$v" ]] || die "empty variable"
command -v cmd >/dev/null || die "cmd missing"

# === DEBUGGING ===
set -x / set +x
debug() { [[ "$DEBUG" == "true" ]] && echo "[D] $*" >&2; }
```

---

*Laboratory material for Operating Systems course | ASE Bucharest - CSIE*
*Adapted for Advanced Bash Scripting seminar*
