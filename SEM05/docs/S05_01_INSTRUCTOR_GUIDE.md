# Instructor Guide: Seminar 9-10
## Operating Systems | Advanced Bash Scripting

> Laboratory observation: jot down key commands and relevant output (2–3 lines) as you work. It helps with debugging and, honestly, at the end you get a good README without extra effort.
> Document: Complete step-by-step guide for instructor  
> Total duration: 100 minutes (2 × 50 min + break)  
> Seminar type: Advanced Scripting - Best Practices  
> Level: Advanced (assumes SEM01-08 completed)

---

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
| trap in subshells | Demonstrate that it is NOT inherited |
| `${arr[@]}` without quotes | Show word splitting in action |

### Deliberate Errors to Introduce

In live coding, INTENTIONALLY introduce these errors and fix them:
1. Forget `local` and show global pollution
2. Forget `declare -A` and show incorrect behaviour
3. Forget quotes in array iteration
4. Show script that "works" but fails silently

---

## WAR STORIES FROM THE TRENCHES

> *Real incidents from teaching this material. Share these with students — they remember stories better than rules.*

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

1. **Variable naming:** Students instinctively use `numar`, `lista`, `rezultat` — which actually helps identify authentic work during AI detection (AI defaults to English)

2. **Error messages:** They write `"Eroare: fisierul nu exista"` then remember to translate — sometimes leaving mixed language comments

3. **Coffee correlation:** The 8:00 AM section makes 15% more errors on array exercises than the 14:00 section. I now schedule the spectacular hook demo first to wake them up.

---

## PREPARATION BEFORE SEMINAR

### Check Bash Version (MANDATORY)

```bash
# On demo machine
bash --version
# Must be >= 4.0 for associative arrays

# Quick functionality check
declare -A test_hash
test_hash[key]="value"
echo "${test_hash[key]}"  # Must display "value"
```

### Setup Demo Environment

```bash
# Create working structure
mkdir -p ~/demo_sem5/{functions,arrays,robust,logs}
cd ~/demo_sem5

# Prepare test files
echo "test content" > test.txt
echo -e "line1\nline2\nline3" > lines.txt

# Verify shellcheck
shellcheck --version || sudo apt install shellcheck
```

### Prepare Presentation

```bash
# Open HTML presentation
firefox ../presentations/S05_01_presentation.html &

# Open cheat sheet
firefox ../presentations/S05_02_cheat_sheet.html &

# Keep template handy
cat ../scripts/templates/professional_script.sh
```

---

## DETAILED TIMELINE - FIRST PART (50 min)

### [0:00-0:05] HOOK: Fragile vs Solid Script

Purpose: Emotional impact - show the difference DRAMATICALLY

Setup (before seminar):
```bash
mkdir -p /tmp/fragile_demo
echo "precious data" > /tmp/fragile_demo/important.txt
```

In-class demonstration:

```bash
#!/bin/bash
# FRAGILE script (do not run on real system!)

cd /tmp/nonexistent_dir    # What if it does not exist?
rm -rf *                    # DISASTER if cd failed!
process_file $1             # What if $1 is empty?
```

Ask the class: "What happens if /tmp/nonexistent_dir does not exist?"

Dramatic answer: `rm -rf *` executes in the CURRENT directory!

Show the solid version:

```bash
#!/bin/bash
# Solid script
set -euo pipefail

cd /tmp/some_dir || { echo "ERROR: Cannot cd"; exit 1; }
[[ -n "${1:-}" ]] || { echo "Usage: $0 <file>"; exit 1; }
rm -rf ./*                  # ./* does not delete everything / if cd failed
process_file "$1"
```

Punch line: "Which script do you run on the production server at 3 AM?"

---

### [0:05-0:20] LIVE CODING: Functions

#### Segment 1: Basic Functions (5 min)

File: `~/demo_sem5/functions/01_basics.sh`

```bash

*Personal note: I prefer Bash scripts for simple automations and Python when logic becomes complex. It is a matter of pragmatism.*

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
greet_name                # Hello, !  (PROBLEM!)

# === WITH VERIFICATION ===
greet_safe() {
    local name="${1:?Error: name required}"
    echo "Hello, $name!"
}

greet_safe                # Explicit error!
greet_safe "Student"      # OK: Hello, Student!
```

Discussion points:
- What happens when we call `greet_name` without an argument?
- Why is `${1:?Error}` better than manual verification?

---

#### Segment 2: Local Variables and Scope (5 min) CRITICAL!

File: `~/demo_sem5/functions/02_scope.sh`

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

File: `~/demo_sem5/functions/03_return.sh`

```bash
#!/bin/bash

*(Bash has ugly syntax, I admit. But it runs everywhere, and that matters enormously in practice.)*

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

get_large_number
echo "Exit code: $?"    # 232, NOT 1000!

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

> 💡 When I first taught this concept, half the group made exactly the same mistake — and that is perfectly normal.

║  ────────────────────────────────────────────────────────────  ║
║                                                                ║
║  A) Inside: 20, Outside: 20                                    ║
║  B) Inside: 20, Outside: 10                                    ║
║  C) Inside: 10, Outside: 10                                    ║
║  D) Error - X cannot be redefined                              ║
║                                                                ║
╚════════════════════════════════════════════════════════════════╝
```

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

File: `~/demo_sem5/arrays/01_indexed.sh`

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

File: `~/demo_sem5/arrays/02_associative.sh`

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
    declare -A counts
    for file in "$@"; do
        ext="${file##*.}"
        (( counts[$ext]++ )) || true
    done
    for ext in "${!counts[@]}"; do
        echo "$ext: ${counts[$ext]}"
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

> 💡 Experience shows that debugging is 80% reading carefully and 20% writing new code.

║  ────────────────────────────────────────────────────────────  ║
║                                                                ║
║  A) [one two]  [three]                                         ║
║  B) [one]  [two]  [three]                                      ║
║  C) [one two three]                                            ║
║  D) Syntax error                                               ║
║                                                                ║
╚════════════════════════════════════════════════════════════════╝
```

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

File: `~/demo_sem5/robust/01_set_options.sh`

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
| `set -e` | Exit on first error | `false` stops the script |
| `set -u` | Error on undefined variables | `$UNDEFINED` = error |
| `set -o pipefail` | Error if anything in pipe fails | `false \| true` = error |

When set -e does NOT work:

```bash
# set -e does NOT work in these contexts:
cmd || handle_error      # Intentionally allows failure
if cmd; then ...         # Explicitly testsd
while cmd; do ...        # Loop condition
$(cmd)                   # Command substitution
```

---

#### Segment 2: trap and cleanup (8 min)

File: `~/demo_sem5/robust/02_trap.sh`

```bash
#!/bin/bash
set -euo pipefail

# === CREATE TEMPORARY FILES ===
TEMP_FILE=$(mktemp)
TEMP_DIR=$(mktemp -d)
echo "Created: $TEMP_FILE"
echo "Created: $TEMP_DIR"

# === CLEANUP FUNCTION ===
cleanup() {
    local exit_code=$?
    echo ""
    echo "=== CLEANUP RUNNING ==="
    echo "Exit code was: $exit_code"
    echo "Removing: $TEMP_FILE"
    rm -f "$TEMP_FILE"
    echo "Removing: $TEMP_DIR"
    rm -rf "$TEMP_DIR"
    echo "Cleanup complete!"
    exit $exit_code    # Preserve original exit code
}

# === SET TRAP ===
# Executes on EXIT (normal or error)
trap cleanup EXIT

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

| Signal | Trigger | Usage |
|--------|---------|-------|
| EXIT | Any exit (normal or error) | Cleanup files |
| ERR | Error (with set -e) | Error logging |
| INT | Ctrl+C | Cleanup on interrupt |
| TERM | kill (default) | Graceful shutdown |

---

### [0:20-0:30] LIVE CODING: Logging

File: `~/demo_sem5/logs/logging.sh`

```bash
#!/bin/bash
set -euo pipefail

# === LOGGING SYSTEM ===
LOG_FILE="/tmp/script_$$.log"
declare -A LOG_LEVELS=([DEBUG]=0 [INFO]=1 [WARN]=2 [ERROR]=3)
LOG_LEVEL="${LOG_LEVEL:-INFO}"

log() {
    local level=$1
    shift
    local message="$*"
    
    # Skip if below current level
    [[ ${LOG_LEVELS[$level]} -lt ${LOG_LEVELS[$LOG_LEVEL]} ]] && return
    
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local caller="${FUNCNAME[1]:-main}"
    local log_line="[$timestamp] [$level] [$caller] $message"
    
    # Write to file
    echo "$log_line" >> "$LOG_FILE"
    
    # On screen for WARN+
    if [[ ${LOG_LEVELS[$level]} -ge ${LOG_LEVELS[WARN]} ]]; then
        echo "$log_line" >&2
    fi
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
→ `Safety net`: Script stops on errors

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

```bash
usage() { ... }
die() { ... }
log() { ... }
```
→ `Helpers`: Standard reusable functions

```bash
cleanup() { ... }
trap cleanup EXIT
```
→ `Guaranteed cleanup`: Regardless of how it ends

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

## Remote Examination Protocol

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
3. **Terminal history audit** — at end: `cat ~/.bash_history | tail -50`. Shows recent activity.
4. **Deliberate error trap** — "I see a bug on line 47" (when there isn't one). Authentic students look and say "I don't see it." Fakers scramble to "fix" it.

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
