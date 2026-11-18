# Instructor Guide: Seminar 5
## Operating Systems | Advanced Bash Scripting

> Laboratory observation: jot down key commands and relevant output (2–3 lines) as you work. It helps with debugging and, honestly, at the end you get a good README without extra effort.
> Document: Complete step-by-step guide for instructor  
> Total duration: 100 teaching minutes plus a 10-minute break (110 elapsed minutes)  
> Seminar type: Advanced Scripting - Best Practices  
> Level: Advanced (assumes SEM01–04 completed; Bash 4.4+)

---

> **Current use and evidence:** These are teaching materials, with intentional WRONG/TODO examples retained. The [teaching and assessment contract](TEACHING_CONTRACT.md) separates runnable references, proposed assessment rules and historical claims whose provenance remains unresolved. Percentages and first-person anecdotes below are retained author-supplied history, not independently verified empirical findings.

## SESSION OBJECTIVES

At the end of this seminar, students will be able to:

1. Create functions with local variables and multiple return value mechanisms
2. Work correctly with indexed and associative arrays (with quotes and declare -A)
3. Implement solid error handling with set -euo pipefail and trap
4. Create logging systems with levels and configurable output
5. Use the professional template as a base for any new script

---

## SPECIAL WARNINGS - READ BEFORE!

### Importance of Professional Template

> CRITICAL: The professional template is the ESSENCE of this seminar!

- START demonstrations with the template, NOT with isolated concepts
- Show WHY each section exists
- Students will COPY this template for ALL future scripts
- If they remember nothing else, they must remember the template

### Common Pitfalls to Avoid

| Pitfall | What to do |
|---------|------------|
| Global vs local variables | DEMONSTRATE with concrete example - do not just say it |
| `declare -A` for hash | Repeat 3 times in different contexts - it is MANDATORY |
| `set -e` magic thinking | Show cases when it does NOT work |
| trap inheritance | Compare ERR with/without `set -E`; distinguish ordinary subshells from command substitution |
| `${arr[@]}` without quotes | Show word splitting in action |

### Deliberate Errors to Introduce

In live coding, INTENTIONALLY introduce these errors and fix them:
1. Forget `local` and show global pollution
2. Forget `declare -A` and show incorrect behaviour
3. Forget quotes in array iteration
4. Show script that "works" but fails silently

---

## WAR STORIES FROM THE TRENCHES

> *Historical author-supplied anecdotes. Their provenance has not been established by this repository review; do not cite them as verified incidents or evidence of learning effects.*

### The Midnight Debugging Session (December 2023)

During the makeup exam session, a student spent 3 hours debugging a script that "mysteriously failed." The symptoms: script worked fine when run manually, failed in cron. The culprit? A single missing quote around `${array[@]}` combined with filenames containing spaces (which only existed in the production dataset, not their test data).

**Lesson I now emphasise:** "Your test data is always cleaner than reality. Quote everything, even when it 'works' without quotes."

### The declare -A Disaster (Semester 2, 2023-2024)

I watched a student debug for 45 minutes why their "associative array" was producing numeric keys. They had written:

```bash
config[name]="test"    # Missing declare -A above!
echo "${!config[@]}"   # Output: 0 (not "name"!)
```

Without `declare -A`, Bash treats it as an indexed array and interprets `name` as arithmetic expression (evaluates to 0).

**Now I always:** Draw this on the board in red marker. Three times. Different contexts.

### The set -e False Confidence (Ongoing)

Every semester, at least one student submits code like:
```bash
set -e
if grep -q "pattern" file.txt; then
    echo "Found"
fi
echo "Script continues"  # They expect this to NOT run if grep fails
```

They're shocked when the script continues. The `set -e` in `if` context gotcha claims victims every year.

**My response:** I created the `S05_04_demo_robust.sh` specifically to demonstrate all the cases where `set -e` does NOT work. It takes 15 minutes but saves hours of confusion.

### Romanian Student Patterns I've Noticed

After teaching this course for several years, I've observed:

1. **Variable naming:** Students instinctively use `numar`, `lista`, `rezultat` — which is a language preference, not evidence of authorship or a valid AI-detection rule

2. **Error messages:** They write `"Eroare: fisierul nu exista"` then remember to translate — sometimes leaving mixed language comments

3. **Coffee correlation:** The 8:00 AM section makes 15% more errors on array exercises than the 14:00 section. I now schedule the spectacular hook demo first to wake them up.

---

## PREPARATION BEFORE SEMINAR

### Check Bash Version (MANDATORY)

```bash
# On demo machine
bash --version
# Must be >= 4.4 for the complete seminar, including nameref exercises

# Quick functionality check
declare -A test_hash
test_hash[key]="value"
echo "${test_hash[key]}"  # Must display "value"
```

### Setup Demo Environment

```bash
# Create working structure
SEMINAR_DIR=$PWD  # Begin in the repository SEM05 directory.
DEMO_ROOT=$(mktemp -d) || exit 1
trap 'rm -rf -- "$DEMO_ROOT"' EXIT
mkdir -p "$DEMO_ROOT"/{functions,arrays,robust,logs}
cd -- "$DEMO_ROOT" || exit 1

# Prepare test files
echo "test content" > test.txt
echo -e "line1\nline2\nline3" > lines.txt

# Verify shellcheck
shellcheck --version || sudo apt install shellcheck
```

### Prepare Presentation

```bash
# Open HTML presentation
firefox "$SEMINAR_DIR"/presentations/S05_01_presentation.html &

# Open cheat sheet
firefox "$SEMINAR_DIR"/presentations/S05_02_cheat_sheet.html &

# Keep template handy
cat "$SEMINAR_DIR"/scripts/templates/professional_script.sh
```

---

## DETAILED TIMELINE - FIRST PART (50 min)

### [0:00-0:05] HOOK: Fragile vs Solid Script

Purpose: Emotional impact - show the difference DRAMATICALLY

Setup (before seminar):
```bash
mkdir -- "$DEMO_ROOT/fragile_demo"
printf '%s\n' "precious data" > "$DEMO_ROOT/fragile_demo/important.txt"
```

In-class demonstration:

```bash
#!/bin/bash
# FRAGILE script (do not run on real system!)

cd /tmp/nonexistent_dir    # What if it does not exist?
printf 'Would remove entries in: %s\n' "$PWD"  # Observe only; no deletion
printf 'Argument supplied: <%s>\n' "${1-}"  # Empty input remains visible
```

Ask the class: "What happens if /tmp/nonexistent_dir does not exist?"

Dramatic answer: `rm -rf *` executes in the CURRENT directory!

Show the solid version:

```bash
#!/bin/bash
set -euo pipefail
owned=
trap '[[ -z ${owned:-} ]] || rm -rf -- "$owned"' EXIT
owned=$(mktemp -d) || exit 1
printf '%s\n' 'owned disposable file' > "$owned/sample.txt"
cd -- "$owned" || exit 1
# This run owns the directory; ./* does not protect a wrong working directory.
rm -f -- ./*
printf '%s\n' 'Owned fixture cleaned'
```

Punch line: "Which script do you run on the production server at 3 AM?"

---

### [0:05-0:20] LIVE CODING: Functions

#### Segment 1: Basic Functions (5 min)

File: `$DEMO_ROOT/functions/01_basics.sh`

```bash


#!/bin/bash
set -euo pipefail

# === FUNCTION DEFINITION ===
# Two valid syntaxes (we prefer the second)
function greet() {
    echo "Hello from function syntax 1"
}

greet_v2() {
    echo "Hello from POSIX syntax (preferred)"
}

# Call
greet
greet_v2

# === WITH ARGUMENTS ===
greet_name() {
    echo "Hello, $1!"
}

greet_name "World"        # Hello, World!
set +e
( greet_name )            # Child exits for missing $1 under nounset
name_status=$?
set -e
printf 'Missing argument status: %s\n' "$name_status"

# === WITH VERIFICATION ===
greet_safe() {
    local name="${1:?Error: name required}"
    echo "Hello, $name!"
}

set +e
( greet_safe )            # Isolate the intentional parameter-expansion failure
safe_status=$?
set -e
printf 'Required-name status: %s\n' "$safe_status"
greet_safe "Student"      # OK: Hello, Student!
```

*Personal note: I prefer Bash scripts for simple automations and Python when logic becomes complex. It is a matter of pragmatism.*

Discussion points:
- What happens when we call `greet_name` without an argument?
- Why is `${1:?Error}` better than manual verification?

---

#### Segment 2: Local Variables and Scope (5 min) CRITICAL!

File: `$DEMO_ROOT/functions/02_scope.sh`

```bash
#!/bin/bash
set -euo pipefail

# CRITICAL DEMONSTRATION - Write on whiteboard!
GLOBAL="initial"

bad_function() {
    GLOBAL="modified by bad_function"    # Modifies global!
    TEMP="created by bad_function"       # Creates a new global!
}

good_function() {
    local GLOBAL="local copy"            # Does NOT affect global
    local temp="truly local"
    echo "Inside good: GLOBAL=$GLOBAL"
}

echo "Before: GLOBAL=$GLOBAL"
# Output: Before: GLOBAL=initial

bad_function
echo "After bad: GLOBAL=$GLOBAL"
# Output: After bad: GLOBAL=modified by bad_function
echo "TEMP=$TEMP"
# Output: TEMP=created by bad_function

good_function
# Output: Inside good: GLOBAL=local copy
echo "After good: GLOBAL=$GLOBAL"
# Output: After good: GLOBAL=modified by bad_function (from bad!)
```

PREDICTION (ask students to predict before running):
- What will `GLOBAL` display after `bad_function`?
- What will `GLOBAL` display after `good_function`?

Key lesson: Variables are GLOBAL by default! Use `local` ALWAYS in functions!

---

#### Segment 3: Return Values (5 min)

File: `$DEMO_ROOT/functions/03_return.sh`

```bash
#!/bin/bash


set -euo pipefail

# === METHOD 1: echo (for string/output) ===
get_sum() {
    local a=$1 b=$2
    echo $((a + b))
}
result=$(get_sum 5 3)
echo "Sum via echo: $result"    # 8

# === METHOD 2: return (only exit code 0-255!) ===
is_even() {
    local n=$1
    (( n % 2 == 0 ))    # Returns 0 (true) or 1 (false)
}

if is_even 4; then
    echo "4 is even"
fi

if ! is_even 7; then
    echo "7 is odd"
fi

# === DELIBERATE ERROR: return with large number ===
get_large_number() {
    return 1000    # WRONG! Truncates to 1000 % 256 = 232
}

if get_large_number; then large_status=0; else large_status=$?; fi
printf 'Exit code: %s\n' "$large_status"  # 232, not 1000

# === METHOD 3: Global variable (avoid if possible) ===
calculate_and_store() {
    RESULT=$((${1} * ${2}))
}
calculate_and_store 6 7
echo "Stored result: $RESULT"    # 42

# === METHOD 4: nameref (Bash 4.3+) ===
store_in() {
    local -n ref=$1    # nameref
    ref="calculated value"
}
declare output
store_in output
echo "Via nameref: $output"
```

*(Bash has ugly syntax, I admit. But it runs everywhere, and that matters enormously in practice.)*

Key points:

- `return` is only for exit code (0-255)
- For strings, use `echo` and capture with `$()`
- `nameref` is elegant but requires Bash 4.3+


---

### [0:20-0:25] PEER INSTRUCTION Q1: Local Variables

Display on screen:

```
╔════════════════════════════════════════════════════════════════╗
║  PEER INSTRUCTION Q1: What does this code display?             ║
╠════════════════════════════════════════════════════════════════╣
║                                                                ║
║  X=10                                                          ║
║  func() {                                                      ║
║      local X=20                                                ║
║      echo "Inside: $X"                                         ║
║  }                                                             ║
║  func                                                          ║
║  echo "Outside: $X"                                            ║
║                                                                ║


║  ────────────────────────────────────────────────────────────  ║
║                                                                ║
║  A) Inside: 20, Outside: 20                                    ║
║  B) Inside: 20, Outside: 10                                    ║
║  C) Inside: 10, Outside: 10                                    ║
║  D) Error - X cannot be redefined                              ║
║                                                                ║
╚════════════════════════════════════════════════════════════════╝
```

> 💡 When I first taught this concept, half the group made exactly the same mistake — and that is perfectly normal.

Protocol:
1. [1 min] Individual voting (target: 40-60% correct)
2. [3 min] Discussion in pairs
3. [1 min] Revote

Correct answer: B

Explanation for class:
- `local X=20` creates a LOCAL variable that exists only in the function
- The global variable `X=10` is not affected
- After exiting the function, `X=10` is visible again
- `local` does "shadowing", not modification

Targeted misconceptions:

- **A**: Think that `local` modifies global
- **C**: Think that `local` has no effect
- **D**: Think that variable cannot be redeclared


---

### [0:25-0:40] LIVE CODING: Arrays

#### Segment 1: Indexed Arrays (7 min)

File: `$DEMO_ROOT/arrays/01_indexed.sh`

```bash
#!/bin/bash
set -euo pipefail

# === CREATION ===
files=()                              # Empty array
files=("a.txt" "b.txt" "c.txt")       # With values
# Trap: No spaces around =

# === ACCESS ===
echo "First: ${files[0]}"             # a.txt (index 0!)
echo "Last: ${files[-1]}"             # c.txt (Bash 4.3+)
echo "All: ${files[@]}"               # all elements
echo "Length: ${#files[@]}"           # 3 (element count)
echo "Indices: ${!files[@]}"          # 0 1 2 (indices)

# === MODIFICATION ===
files+=("d.txt")                      # Append at end
echo "After append: ${files[@]}"      # a.txt b.txt c.txt d.txt

files[0]="new.txt"                    # Modify element
echo "After modify: ${files[@]}"

unset files[1]                        # Delete element (NOT the array!)
echo "After unset [1]: ${files[@]}"   # new.txt c.txt d.txt
echo "Indices now: ${!files[@]}"      # 0 2 3 (sparse!)

# === CORRECT ITERATION ===
echo ""
echo "=== CORRECT ITERATION ==="
for f in "${files[@]}"; do            # QUOTES MANDATORY!
    echo "File: $f"
done

# === WRONG ITERATION (demonstrate problem) ===
spacey_files=("one two.txt" "three.txt")
echo ""
echo "=== WRONG ITERATION (without quotes) ==="
for f in ${spacey_files[@]}; do       # WRONG!
    echo "File: [$f]"
done
# Output: File: [one], File: [two.txt], File: [three.txt]

echo ""
echo "=== CORRECT ITERATION ==="
for f in "${spacey_files[@]}"; do     # CORRECT!
    echo "File: [$f]"
done
# Output: File: [one two.txt], File: [three.txt]
```

Key points:
- Arrays start from 0
- `unset arr[i]` makes the array sparse
- `"${arr[@]}"` preserves elements with spaces

---

#### Segment 2: Associative Arrays (8 min) CRITICAL!

File: `$DEMO_ROOT/arrays/02_associative.sh`

```bash
#!/bin/bash
set -euo pipefail

# === declare -A is MANDATORY! ===
# WRONG (without declare):
# settings[host]="localhost" # DO NOT DO THIS!

# CORRECT:
declare -A config

# === POPULATION ===
config[host]="localhost"
config[port]="8080"
config[user]="admin"
config[debug]="true"

# === OR ALL AT ONCE ===
declare -A config2=(
    [host]="localhost"
    [port]="8080"
    [user]="admin"
)

# === ACCESS ===
echo "Host: ${config[host]}"
echo "Port: ${config[port]}"
echo ""

# === ALL VALUES ===
echo "All values: ${config[@]}"

# === ALL KEYS ===
echo "All keys: ${!config[@]}"

# === ELEMENT COUNT ===
echo "Count: ${#config[@]}"
echo ""

# === ITERATION (IMPORTANT!) ===
echo "=== CONFIG DUMP ==="
for key in "${!config[@]}"; do
    echo "  $key = ${config[$key]}"
done

# === CHECK KEY EXISTENCE ===
if [[ -v config[host] ]]; then
    echo "Host is set"
fi

if [[ ! -v config[missing] ]]; then
    echo "Missing key is not set"
fi

# === DEFAULT VALUE ===
echo "Database: ${config[database]:-not_configured}"
```

**ERROR DEMONSTRATION** (without declare -A):

```bash
# What happens without declare -A?
wrong[name]="John"        # Bash treats [name] as pattern!
echo "${wrong[name]}"     # Unpredictable behaviour!
```

Repeat 3 times: `declare -A` is MANDATORY for hashes!

---

### [0:40-0:45] SPRINT #1: Function & Array Challenge

Display on screen:

```
╔════════════════════════════════════════════════════════════════╗
║  🏃 SPRINT #1: Function & Array Challenge (5 min)              ║
╠════════════════════════════════════════════════════════════════╣
║                                                                ║
║  Write a function `count_extensions` that:                     ║
║                                                                ║
║  1. Receives an array of filenames as arguments                ║
║  2. Counts how many files there are for each extension         ║
║  3. Displays the result                                        ║
║                                                                ║
║  Usage example:                                                ║
║  ┌──────────────────────────────────────────────────────────┐  ║
║  │  files=("a.txt" "b.txt" "c.py" "d.txt" "e.py")           │  ║
║  │  count_extensions "${files[@]}"                          │  ║
║  │                                                          │  ║
║  │  # Output:                                               │  ║
║  │  # txt: 3                                                │  ║
║  │  # py: 2                                                 │  ║
║  └──────────────────────────────────────────────────────────┘  ║
║                                                                ║
║  HINT: Use associative array for counting!                     ║
║                                                                ║
║  ⏱️ TIME REMAINING: 5:00                                       ║
║                                                                ║
╚════════════════════════════════════════════════════════════════╝
```

Solution (for instructor):

```bash
count_extensions() {
    local file base ext
    declare -A counts=()
    for file in "$@"; do
        base=${file##*/}
        case "$base" in .*|*.) ext=no_extension ;; *.*) ext=${base##*.} ;; *) ext=no_extension ;; esac
        counts["$ext"]=$(( ${counts[$ext]:-0} + 1 ))
    done
    for ext in "${!counts[@]}"; do
        printf '%s: %s\n' "$ext" "${counts[$ext]}"
    done
}
```

---

### [0:45-0:50] PEER INSTRUCTION Q2: Array Iteration

Display on screen:

```
╔════════════════════════════════════════════════════════════════╗
║  PEER INSTRUCTION Q2: What does this code display?             ║
╠════════════════════════════════════════════════════════════════╣
║                                                                ║
║  arr=("one two" "three")                                       ║
║  for item in ${arr[@]}; do                                     ║
║      echo "[$item]"                                            ║
║  done                                                          ║
║                                                                ║


║  ────────────────────────────────────────────────────────────  ║
║                                                                ║
║  A) [one two]  [three]                                         ║
║  B) [one]  [two]  [three]                                      ║
║  C) [one two three]                                            ║
║  D) Syntax error                                               ║
║                                                                ║
╚════════════════════════════════════════════════════════════════╝
```

> 💡 Experience shows that debugging is 80% reading carefully and 20% writing new code.

Correct answer: B

Explanation:
- Without quotes, `${arr[@]}` expands and then word splitting occurs
- "one two" becomes two separate words: "one" and "two"
- CORRECT: `for item in "${arr[@]}"`

---

## 10 MINUTE BREAK

During break, prepare:
- Stability demos
- Temporary files for trap demo

---

## DETAILED TIMELINE - SECOND PART (50 min)

### [0:00-0:05] REACTIVATION: Quick Quiz

Quick questions (30 sec each):

```
1. How do you make a local variable in a function?
   → local var="value"

2. How do you declare an associative array?
   → declare -A hashmap

3. What does `return` return in Bash?
   → A numeric code 0-255 (NOT string!)
```

---

### [0:05-0:20] LIVE CODING: Stability

#### Segment 1: set -euo pipefail (7 min)

File: `$DEMO_ROOT/robust/01_set_options.sh`

```bash
#!/bin/bash

# === DEMONSTRATION: Without protection ===
echo "=== WITHOUT PROTECTION ==="

false                    # Error ignored!
echo "Continues after false..."

echo "$UNDEFINED"        # Empty string, no error!
echo "Continues after undefined..."

false | true             # Error hidden in pipe!
echo "Continues after pipe..."

echo "Script finished 'successfully'"
```

Run: Script finishes "successfully" but has errors!

```bash
#!/bin/bash
# === WITH PROTECTION ===
set -euo pipefail

echo "=== WITH SET -EUO PIPEFAIL ==="

# Uncomment one at a time to see the effect:
# false # Script stops
# echo "$UNDEFINED" # Script stops
# false | true # Script stops (pipefail)
```

Detailed explanation:

| Option | Effect | Example |
|--------|--------|---------|
| `set -e` | Exit on eligible non-zero status; tested contexts are exempt | `false` stops the script |
| `set -u` | Error on undefined variables | `$UNDEFINED` = error |
| `set -o pipefail` | Rightmost non-zero pipeline status, or zero if all succeed | `false \| true` = error |

When set -e does NOT work:

```text
# set -e does NOT work in these contexts:
cmd || handle_error      # Intentionally allows failure
if cmd; then ...         # Explicitly testsd
while cmd; do ...        # Loop condition
value=$(cmd)             # Normally clears -e inside; final status still reaches assignment
```

---

#### Segment 2: trap and cleanup (8 min)

File: `$DEMO_ROOT/robust/02_trap.sh`

```bash
#!/bin/bash
set -euo pipefail

# Register cleanup before allocation; remove only this run's resources.
TEMP_FILE= TEMP_DIR=
cleanup() {
    local exit_code=$?
    [[ -z ${TEMP_FILE:-} ]] || rm -f -- "$TEMP_FILE"
    [[ -z ${TEMP_DIR:-} ]] || rm -rf -- "$TEMP_DIR"
    exit "$exit_code"
}
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM
TEMP_FILE=$(mktemp) || exit 1
TEMP_DIR=$(mktemp -d) || exit 1
printf 'Created: %s\n' "$TEMP_FILE" "$TEMP_DIR"

# === SIMULATE WORK ===
echo ""
echo "Working..."
echo "Some content" > "$TEMP_FILE"
touch "$TEMP_DIR/file1.txt"

# Uncomment to simulate error:
# echo "Simulating error..."
# false

echo "Work complete!"
# Cleanup executes automatically on exit!
```

Demonstration:
1. Run normally → cleanup executes
2. Uncomment `false` → cleanup executes JUST THE SAME!

Trap signals:

| Event or signal | Trigger | Usage |
|--------|---------|-------|
| EXIT (Bash event) | Shell exit; not SIGKILL or power loss | Owned-resource cleanup |
| ERR (Bash event) | Eligible failure; does not require `set -e` | Error logging; inheritance via `set -E` |
| INT | Ctrl+C | Cleanup on interrupt |
| TERM | kill (default) | Graceful shutdown |

---

### [0:20-0:30] LIVE CODING: Logging

File: `$DEMO_ROOT/logs/logging.sh`

```bash
#!/bin/bash
set -euo pipefail

# === LOGGING SYSTEM ===
LOG_FILE=
trap '[[ -z ${LOG_FILE:-} ]] || rm -f -- "$LOG_FILE"' EXIT
LOG_FILE=$(mktemp) || exit 1
declare -A LOG_LEVELS=([DEBUG]=0 [INFO]=1 [WARN]=2 [ERROR]=3)
LOG_LEVEL="${LOG_LEVEL:-INFO}"

log() {
    local level=$1
    shift
    local message="$*"
    
    # Skip if below current level
    [[ -v LOG_LEVELS[$level] && -v LOG_LEVELS[$LOG_LEVEL] ]] || return 2
    [[ ${LOG_LEVELS[$level]} -lt ${LOG_LEVELS[$LOG_LEVEL]} ]] && return 0
    
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S') || return 1
    local caller="${FUNCNAME[1]:-main}"
    local log_line="[$timestamp] [$level] [$caller] $message"
    
    # Write to file
    printf '%s\n' "$log_line" >> "$LOG_FILE" || return 1
    
    # On screen for WARN+
    if [[ ${LOG_LEVELS[$level]} -ge ${LOG_LEVELS[WARN]} ]]; then
        printf '%s\n' "$log_line" >&2 || return 1
    fi
    return 0
}

# Helper functions
log_debug() { log DEBUG "$@"; }
log_info()  { log INFO "$@"; }
log_warn()  { log WARN "$@"; }
log_error() { log ERROR "$@"; }

# === DEMO ===
echo "Log file: $LOG_FILE"
echo ""

log_info "Script started"
log_debug "This won't show with INFO level"

echo "Changing to DEBUG level..."
LOG_LEVEL=DEBUG

log_debug "Now this shows!"
log_info "Processing data..."
log_warn "This is a warning"
log_error "This is an error"

echo ""
echo "=== LOG FILE CONTENTS ==="
cat "$LOG_FILE"
```

---

### [0:30-0:40] PROFESSIONAL TEMPLATE - Walkthrough

Open: `scripts/templates/professional_script.sh`

Go through EACH section and explain WHY it exists:

```bash
#!/bin/bash
#
# Script: my_script.sh
# Description: What the script does (fill in)
# Author: Name (fill in)
# Version: 1.0.0
# Date: 2025-01-10
#
```
→ `Header`: Documentation for whoever reads the code

```bash
set -euo pipefail
IFS=$'\n\t'
```
→ `Shell options`: Expose eligible failures; explicit checks remain necessary.

```bash
readonly SCRIPT_NAME=$(basename "$0")
readonly SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
readonly SCRIPT_VERSION="1.0.0"
```
→ `Constants`: Cannot be accidentally modified

```bash
VERBOSE=${VERBOSE:-0}
OUTPUT="${OUTPUT:-}"
```
→ `Config with defaults`: Flexibility without errors

```text
usage() { ... }
die() { ... }
log() { ... }
```
→ `Helpers`: Standard reusable functions

```text
cleanup() { ... }
trap cleanup EXIT
```
→ `Owned cleanup`: Runs on handled shell exit; cannot cover SIGKILL or machine failure.

```bash
main() {
    parse_args "$@"
    validate
    # main logic
}
main "$@"
```
→ Clear structure: Easy to understand and modify

---

### [0:40-0:45] SPRINT #2: Complete Script

Display on screen:

```
╔════════════════════════════════════════════════════════════════╗
║  🏃 SPRINT #2: Complete Script (5 min)                         ║
╠════════════════════════════════════════════════════════════════╣
║                                                                ║
║  Using the professional template, write a script that:         ║
║                                                                ║
║  1. Accepts -h for help                                        ║
║  2. Accepts -n NUM to specify a number (default: 10)           ║
║  3. Accepts a file as argument                                 ║
║  4. Displays the first NUM lines from the file                 ║
║  5. Has error handling for non-existent file                   ║
║                                                                ║
║  Example: ./script.sh -n 5 input.txt                           ║
║                                                                ║
║  ⏱️ TIME REMAINING: 5:00                                       ║
║                                                                ║
╚════════════════════════════════════════════════════════════════╝
```

---

### [0:45-0:48] LLM EXERCISE: Script Review

Display on screen:

```
╔════════════════════════════════════════════════════════════════╗
║  🤖 LLM Exercise: Script Reviewer (3 min)                      ║
╠════════════════════════════════════════════════════════════════╣
║                                                                ║
║  Give this script to an LLM (ChatGPT/Claude) and ask it        ║
║  to improve it:                                                ║
║                                                                ║
║  ┌──────────────────────────────────────────────────────────┐  ║
║  │  #!/bin/bash                                             │  ║
║  │  files=$(ls *.txt)                                       │  ║
║  │  for f in $files; do                                     │  ║
║  │      cat $f >> all.txt                                   │  ║
║  │  done                                                    │  ║
║  │  echo "Done"                                             │  ║
║  └──────────────────────────────────────────────────────────┘  ║
║                                                                ║
║  Evaluate the LLM's suggestions:                               ║
║  □ Did it suggest set -euo pipefail?                           ║
║  □ Did it correct $(ls *.txt) with direct glob?                ║
║  □ Did it add quotes to variables?                             ║
║  □ Did it suggest error handling?                              ║
║                                                                ║
╚════════════════════════════════════════════════════════════════╝
```

---

### [0:48-0:50] REFLECTION

Display on screen:

```
╔════════════════════════════════════════════════════════════════╗
║  🧠 REFLECTION (2 minutes)                                     ║
╠════════════════════════════════════════════════════════════════╣
║                                                                ║
║  1. What will you do DIFFERENTLY from now on in your scripts?  ║
║     _________________________________________________          ║
║                                                                ║
║  2. Which part of the professional template seems              ║
║     most important to you?                                     ║
║     □ set -euo pipefail                                        ║
║     □ trap cleanup                                             ║
║     □ Logging                                                  ║
║     □ Argument parsing                                         ║
║                                                                ║
║  3. One thing you learned today that you did not know:         ║
║     _________________________________________________          ║
║                                                                ║
╚════════════════════════════════════════════════════════════════╝
```

---

## QUICK TROUBLESHOOTING

| Problem | Diagnosis | Solution |
|---------|-----------|----------|
| "bad array subscript" | Associative array without declare | Add `declare -A` |
| "unbound variable" | Undefined variable with set -u | `${VAR:-default}` |
| Script does not stop on error | Context where -e does not work | Check if in if/||/&& |
| trap does not execute | exit before trap setup | Move trap up |
| local does not work | Outside function | Use only in functions |
| return ignored | In subshell/pipe | Use global variable |
| Array seems empty | Iteration without quotes | `"${arr[@]}"` |
| shellcheck warning | Valid but unsafe code | Follow the suggestion |

---

## AFTER SEMINAR

### Check Understanding
- Ask 2-3 students what they will do differently
- Collect feedback about seminar pace

### Prepare Assignment
- Ensure everyone received specifications
- Clarify deadline and evaluation criteria

### Materials for Students
- Distribute link to cheat sheet
- Send professional template

---

*Guide generated for ASE Bucharest - CSIE | Operating Systems*

---

## Personal Teaching Notes (Added v2.0)

> **From my experience (Antonio):** Students consistently underestimate the `local` keyword disaster until they debug their first namespace collision at 2 AM. The "aha moment" comes faster if you let them fail first in a controlled demo, then rescue them.

### The Dose Coffee Revelation

During a brainstorming session with Andrei Toma at The Dose (our usual spot near Piața Romană), we realised that the single most effective demo is the "destructive global variable" — students physically gasp when `count` becomes 3 instead of 100. Worth the dramatic pause.

### Romanian Student Patterns I've Noticed

1. **The "It works on my machine" syndrome** — especially with Bash versions. Always check `${BASH_VERSINFO[0]}` first.
2. **Copy-paste from Stack Overflow** — they'll grab `#!/bin/sh` and wonder why arrays don't work.
3. **Fear of `set -e`** — "But what if something fails?" Yes, that's the point.
4. **The "I'll add error handling later" delusion** — spoiler: they never do.

---

## Historical Remote Examination Proposal — Not an Adopted Policy

These proposed controls require the author/institution to choose a proportionate process, permitted data, consent/alternative route, retention and access. No recording, webcam requirement or history collection is activated by this material. Prefer a synthetic task and criterion-based explanation over collecting private history. The original proposal is retained below for decision.

> *Added after the pandemic forced us all online — but useful even for hybrid scenarios.*

### Technical Setup for Remote Sessions

1. **Screen share mandatory** — student shares terminal/VS Code
2. **Webcam on** — shows face, ideally hands on keyboard
3. **Second device discouraged** — ask them to show phone face-down
4. **Record session** (with consent form signed) — protects both parties

### Adapted Timing

| In-Person | Remote | Reason |
|-----------|--------|--------|
| 5 min warm-up | 8 min | Technical issues, "can you hear me?" |
| 15 min live coding | 18 min | Lag, typo correction harder |
| Immediate feedback | Slight delay | Use chat for quick notes |

### Low-Tech Verification (When Proctoring Software Unavailable)

1. **Handwritten pseudocode** — before coding, student photographs hand-drawn logic. Difficult to fake in real-time.
2. **Language switching** — "Explain this in Romanian, now show me the English code." Reveals true understanding vs memorisation.
3. **Terminal history audit** — at end: a synthetic session history limited to the assessment task. A private shell history can expose unrelated data and does not establish authorship.
4. **Deliberate error trap** — "I see a bug on line 47" (when there isn't one). This reaction is not validated evidence of authorship; prefer an explicit, reproducible debugging question and recorded assessment criteria.

### Post-Session Checklist

- [ ] Recording saved to secure location
- [ ] Observations noted within 10 min (memory fades fast)
- [ ] Any concerns documented with specific line numbers
- [ ] Grade entered within 48 hours

---

## End-of-Semester Reflection (Updated January 2025)

After five semesters of teaching this material, the consistent feedback is:
- **Most valuable:** The professional template — they use it for everything
- **Most surprising:** `set -e` limitations — "I thought it was magic"
- **Most requested:** More live debugging demos
- **Least used:** Logging levels (they say "echo is fine" until production)

### The Dose Coffee Revelation

During a brainstorming session with Andrei Toma at The Dose (our usual spot near Piața Romană), we realised that the single most effective demo is the "destructive global variable" — students physically gasp when `count` becomes 3 instead of 100. Worth the dramatic pause.

### Things I've Learned to Do Differently

1. **Start with the disaster, not the theory** — The fragile script demo at 0:00 captures attention better than "today we'll learn about..."

2. **Let them predict before running** — "What do you think this outputs?" followed by reality is more memorable than lecture.

3. **Celebrate shellcheck** — Students initially see it as punishment. Reframe: "It's pair programming with an expert who never sleeps."

4. **The vending machine note** — Building Virgil Madgearu vending machines run out by 9 PM during exam season. For late marking sessions, bring your own coffee.

*Updated: January 2025 | ing. dr. Antonio Clim*
