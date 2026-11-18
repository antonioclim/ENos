# S05_05 - Live Coding Guide for Instructor

> **Operating Systems** | ASE Bucharest - CSIE  
> Seminar 5: Advanced Bash Scripting
> Version: 2.0.0 | Date: 2025-01

---

> **Current use and evidence:** These are teaching materials, with intentional WRONG/TODO examples retained. The [teaching and assessment contract](TEACHING_CONTRACT.md) separates runnable references, proposed assessment rules and historical claims whose provenance remains unresolved. Percentages and first-person anecdotes below are retained author-supplied history, not independently verified empirical findings.


## Live Coding Philosophy

### Fundamental Principles

1. **Make mistakes INTENTIONALLY** - normalise the debugging process
2. **Think aloud** - verbalise your reasoning
3. **Slow pace** - students copy, not just watch
4. **Ask frequently** - "What do you think will happen?"
5. **Use errors as learning moments**

### Recommended Setup

Begin in SEM05. Use an owned workspace for generated scripts:

```bash
SEMINAR_DIR=$PWD
DEMO_ROOT=$(mktemp -d) || exit 1
trap 'rm -rf -- "$DEMO_ROOT"' EXIT
cd -- "$DEMO_ROOT" || exit 1
```

Blocks with `$` / `>` prompts are terminal transcripts, not files to copy verbatim. Expected failures belong in disposable child Bash processes.


```
┌─────────────────────────────────────────────────────────┐
│  Terminal (large font: 18-20pt)                         │
│  - Short prompt: PS1='$ '                               │
│  - Colours activated                                    │
│  - History visible                                      │
├─────────────────────────────────────────────────────────┤
│  Editor (side-by-side with terminal)                    │
│  - Syntax highlighting                                  │
│  - Line numbers                                         │
│  - Large font                                           │
└─────────────────────────────────────────────────────────┘
```

---

## Session 1: FUNCTIONS (20 minutes)

### LC1.1: First Function (5 min)

**Objective:** Basic syntax and calling

```console
# Open terminal, type directly:

$ # Let's create our first function
$ greet() {
>     echo "Hello, World!"
> }

$ # Notice - nothing visible happened
$ # The function is defined but not executed

$ # How do we call it?
$ greet
Hello, World!

$ # With arguments?
$ greet Ana
Hello, World!

$ # Hmm, it did not use the argument. Why?
$ # Because we did not tell it to use it!
```

**🎯 Learning moment:**
```console
$ greet() {
>     echo "Hello, $1!"
> }

$ greet Ana
Hello, Ana!

$ greet "Ion Popescu"
Hello, Ion Popescu!

$ # What is $1? The first argument of the FUNCTION
```

---

### LC1.2: Local vs Global Variables (7 min)

**Objective:** Visual demonstration of the global variables problem

**STEP 1: Setup the problem**
```console
$ cat > demo_global.sh << 'EOF'
#!/bin/bash

count=100
echo "Before: count=$count"

process() {
    count=0
    for item in a b c; do
        ((count++))
    done
    echo "In function: count=$count"
}

process
echo "After: count=$count"
EOF

$ chmod +x demo_global.sh
```

**STEP 2: Prediction**
```console
$ # QUESTION FOR CLASS:
$ # What will "After: count=..." display?
$ # A) 100
$ # B) 3
$ # C) 0
$ # Vote!
```

**STEP 3: Execution and surprise**
```console
$ ./demo_global.sh
Before: count=100
In function: count=3
After: count=3

$ # SURPRISE! count from main was modified!
$ # Why? Variables in functions are GLOBAL by default!
```

**STEP 4: The solution**
```console
$ # Edit the file - add 'local'
$ cat > demo_local.sh << 'EOF'
#!/bin/bash

count=100
echo "Before: count=$count"

process() {
    local count=0    # <-- ONLY DIFFERENCE
    for item in a b c; do
        ((count++))
    done
    echo "In function: count=$count"
}

process
echo "After: count=$count"
EOF

$ ./demo_local.sh
Before: count=100
In function: count=3
After: count=100    # Correct now!
```

**📝 Golden rule on board:**
```
┌─────────────────────────────────────────────┐
│  ALWAYS use `local` in functions!           │
└─────────────────────────────────────────────┘
```

---

### LC1.3: Return vs Echo (8 min)

**STEP 1: The common mistake**
```console
$ get_sum() {
>     return $(($1 + $2))
> }

$ result=$(get_sum 5 3)
$ echo "Result: '$result'"
Result: ''

$ # Empty?! Why?
```

**STEP 2: Explanation**
```console
$ # return sets EXIT CODE, does not return values!
$ get_sum 5 3
$ echo "Exit code: $?"
Exit code: 8

$ # Exit code is limited to 0-255
$ get_sum 200 100
$ echo "Exit code: $?"
Exit code: 44    # 300 % 256 = 44 (overflow!)
```

**STEP 3: The correct solution**
```console
$ get_sum() {
>     echo $(($1 + $2))    # Echo to "return" values
> }

$ result=$(get_sum 5 3)
$ echo "Result: $result"
Result: 8

$ # Works for large values too
$ result=$(get_sum 200 100)
$ echo "Result: $result"
Result: 300
```

**📝 On board:**
```
┌─────────────────────────────────────────┐
│  return = exit code (0-255)             │
│  echo = "returns" values (capture)      │
│                                         │
│  result=$(function args)                │
└─────────────────────────────────────────┘
```

---

## Session 2: ARRAYS (20 minutes)

### LC2.1: Basic Indexed Array (5 min)

```console
$ # Create an array
$ fruits=("apple" "banana" "cherry")

$ # First element - Trap: index 0, not 1!
$ echo "${fruits[0]}"
apple

$ # Common mistake:
$ echo "${fruits[1]}"
banana    # NOT the first!

$ # All elements
$ echo "${fruits[@]}"
apple banana cherry

$ # How many elements?
$ echo "${#fruits[@]}"
3

$ # Add element
$ fruits+=("date")
$ echo "${fruits[@]}"
apple banana cherry date
```

---

### LC2.2: The Quotes Problem (8 min)

**STEP 1: Setup the problem**
```console
$ # Array with elements containing spaces
$ files=("file one.txt" "file two.txt" "document.pdf")

$ # How many elements?
$ echo "${#files[@]}"
3
```

**STEP 2: WRONG iteration**
```console


$ # WRONG - without quotes
$ for f in ${files[@]}; do
>     echo "-> $f"
> done
-> file
-> one.txt
-> file
-> two.txt
-> document.pdf

$ # 5 iterations instead of 3! What happened?
$ # Word splitting broke elements at spaces!
```

*Personal note: Many prefer `zsh`, but I stick to Bash because it is the standard on servers. Consistency beats comfort.*

**STEP 3: CORRECT iteration**
```console
$ # CORRECT - with quotes
$ for f in "${files[@]}"; do
>     echo "-> $f"
> done
-> file one.txt
-> file two.txt
-> document.pdf

$ # Exactly 3 iterations, elements intact!
```

**📝 On board:**
```
┌────────────────────────────────────────────────┐
│  WRONG: for i in ${arr[@]}                     │
│  CORRECT: for i in "${arr[@]}"                 │
│                                                │
│  Quotes PROTECT from word splitting!           │
└────────────────────────────────────────────────┘
```

---

### LC2.3: Associative Array (7 min)

**STEP 1: The mistake (WITHOUT declare -A)**
```console
$ # Try to create a "hash" without declare -A
$ wrong[host]="localhost"
$ wrong[port]="8080"

$ echo "Host: ${wrong[host]}"
Host: 8080    # Strange...

$ echo "Keys: ${!wrong[@]}"
Keys: 0       # Only one numeric index!

$ # What happened? Bash interpreted host and port
$ # as variables (undefined = 0), so both wrote to wrong[0]
```

**STEP 2: The solution (WITH declare -A)**
```console
$ declare -A config    # MANDATORY!
$ config[host]="localhost"
$ config[port]="8080"

$ echo "Host: ${config[host]}"
Host: localhost

$ echo "Keys: ${!config[@]}"
Keys: host port

$ # Now it works correctly!
```

**STEP 3: Iterating through hash**
```console
$ for key in "${!config[@]}"; do
>     echo "$key = ${config[$key]}"
> done
host = localhost
port = 8080
```

**📝 On board:**
```
┌─────────────────────────────────────────────┐
│  declare -A hash    # MANDATORY!            │
│  hash[key]="value"                          │
│                                             │
│  ${hash[key]}       # access value          │
│  ${!hash[@]}        # all keys              │
└─────────────────────────────────────────────┘
```

---

## Session 3: ROBUSTNESS (20 minutes)

### LC3.1: Fragile Script Demonstration (5 min)

```console
$ cat > fragile.sh << 'EOF'
#!/bin/bash
# FRAGILE script - DO NOT do this!

cd "$1"
printf 'Would remove: %s/temp/*\n' "$PWD"  # Non-destructive plan
echo "Cleanup done in $1"
EOF

$ # What happens if $1 is empty or directory does not exist?
$ ./fragile.sh ""
# printf 'Would remove: %s/temp/*\n' "$PWD"  # Non-destructive plan runs in CURRENT directory!
# DISASTER!

$ ./fragile.sh /nonexistent
# cd writes a diagnostic to stderr; the unguarded script continues in its previous directory!
```

---

### LC3.2: Adding set -euo pipefail (10 min)

**STEP 1: set -e**
```console
$ cat > robust1.sh << 'EOF'
#!/bin/bash
set -e    # Exit on eligible failure

cd "$1"
printf 'Would remove: %s/temp/*\n' "$PWD"  # Non-destructive plan
echo "Cleanup done"
EOF

$ ./robust1.sh /nonexistent
# Script stops at cd (error)
# The plan is not reached in this direct call; explicit checks remain necessary in tested contexts.
```

**STEP 2: set -u**
```console
$ cat > robust2.sh << 'EOF'
#!/bin/bash
set -eu    # + undefined variables = error

echo "Processing: $UNDEFINED"
EOF

$ ./robust2.sh
# Error: UNDEFINED: unbound variable
# We detect typos in variables!
```

**STEP 3: pipefail**
```console
$ # Without pipefail
$ false | true
$ echo $?
0    # Error from false is IGNORED!

$ # With pipefail


$ set -o pipefail
$ false | true
$ echo $?
1    # Error is propagated!
```

*(Pipes are Unix genius. Combine simple commands to solve complex problems.)*

**STEP 4: The complete combination**
```console
$ cat > robust.sh << 'EOF'
#!/bin/bash
set -euo pipefail    # Options with documented exceptions
IFS=$'\n\t'          # Parsing choice, not a universal safety measure

# Explicit validation, ownership and failure tests are still required.
EOF
```

---

### LC3.3: ATTENTION - When set -e Does NOT Work! (5 min)

```console
$ cat > trap.sh << 'EOF'
#!/bin/bash
set -e

# SURPRISE: set -e does NOT work in if!
if false; then
    echo "In if"
fi
echo "Script continues!"    # EXECUTES!

# Nor with ||
false || echo "Rescued"
echo "Continues!"           # EXECUTES!
EOF

$ ./trap.sh
Script continues!
Rescued
Continues!

$ # Conclusion: set -e has LIMITS!
$ # Do not rely 100% on it - explicitly verify important errors
```

---

## Session 4: TRAP and CLEANUP (10 minutes)

### LC4.1: Trap EXIT for Cleanup

```console
$ cat > cleanup.sh << 'EOF'
#!/bin/bash
set -euo pipefail

TEMP_FILE=""

cleanup() {
    echo "🧹 Cleanup executed!"
    if [[ -n ${TEMP_FILE:-} ]]; then rm -f -- "$TEMP_FILE"; fi
}

trap cleanup EXIT    # Shell exit; not SIGKILL or machine failure

TEMP_FILE=$(mktemp)
echo "Working with: $TEMP_FILE"

# Simulate error
echo "Now there will be an error..."
false

echo "This will not display"
EOF

$ ./cleanup.sh
Working with: /tmp/tmp.xxxxx
Now there will be an error...
🧹 Cleanup executed!

$ # Notice: cleanup executed EVEN THOUGH script failed!
$ # Temporary file was deleted automatically
```

---

## Session 5: TEMPLATE WALKTHROUGH (10 minutes)

### LC5.1: Building the Template Step by Step

```console
$ cat > template.sh << 'EOF'
#!/bin/bash
#
# Script: template.sh
# Author: [Name]
# Version: 1.0.0
#

# === STRICT MODE ===
set -euo pipefail
IFS=$'\n\t'

# === CONSTANTS ===
readonly SCRIPT_NAME=$(basename "$0")

# === CONFIGURATION ===
VERBOSE="${VERBOSE:-0}"

# === HELPER FUNCTIONS ===
die() {
    echo "FATAL: $*" >&2
    exit 1
}

# === CLEANUP ===
cleanup() {
    local exit_code=$?
    # cleanup here
    exit $exit_code
}
trap cleanup EXIT

# === MAIN ===
main() {
    echo "Hello from $SCRIPT_NAME!"
    [ $# -ge 1 ] || die "Usage: $SCRIPT_NAME <arg>"
    echo "Argument: $1"
}

main "$@"
EOF

$ chmod +x template.sh
$ ./template.sh
FATAL: Usage: template.sh <arg>

$ ./template.sh test
Hello from template.sh!
Argument: test
```

---

## Post-Live-Coding Checklist

### After each section, verify:

- [ ] Did students copy the code?
- [ ] Did everyone get the same output?
- [ ] Does anyone have questions?
- [ ] Is the key concept on the board/slide?

### Common errors during live coding:

| Situation | Solution |
|-----------|----------|
| Typo in code | Use as debugging moment |
| Script does not run | Check `chmod +x` |
| Different output | Check Bash version |
| Students falling behind | Pause, share code via chat |

---

## Pre-prepared Scripts (Backup)

If time is short, use scripts from `scripts/demo/`:

```bash
bash "$SEMINAR_DIR/scripts/demo/S05_02_demo_functions.sh"    # Functions
bash "$SEMINAR_DIR/scripts/demo/S05_03_demo_arrays.sh"       # Arrays
bash "$SEMINAR_DIR/scripts/demo/S05_04_demo_robust.sh"       # set -euo pipefail
bash "$SEMINAR_DIR/scripts/demo/S05_05_demo_logging.sh"      # Logging
bash -x "$SEMINAR_DIR/scripts/demo/S05_02_demo_functions.sh"  # Debugging trace of a shipped demo
```

---

*Laboratory material for Operating Systems course | ASE Bucharest - CSIE*
