# S05_04 - Parsons Problems: Code Ordering Exercises

> Laboratory observation: jot down key commands and relevant output (2–3 lines) as you work. It helps with debugging and, honestly, at the end you get a good README without extra effort.
> Operating Systems | ASE Bucharest - CSIE  
> Seminar 5: Advanced Bash Scripting
> Version: 2.0.0 | Date: 2025-01

---

## About Parsons Problems

Parsons Problems are exercises where students receive shuffled lines of code and must arrange them in the correct order. They:
- Reduce cognitive load (no need to memorise syntax)
- Focus attention on structure and logic
- Are excellent for active learning
- Can be done quickly (2-5 minutes each)

Equivalent dependency-preserving orders are accepted; the displayed solution is one valid order.
Learner block labels were reproducibly shuffled (seed 5500 + problem number).
Explain dependencies rather than guessing an alphabetical sequence.

### Difficulty Levels

| Level | Characteristics |
|-------|-----------------|
| 🟢 Easy | Lines in almost correct order, no distractors |
| 🟡 Medium | Shuffled order, may include 1-2 distractors |
| 🔴 Difficult | Random order, multiple distractors, requires deep understanding |

---

## Section 1: FUNCTIONS

### P1: Function with Local Variable

Objective: Demonstrate the importance of `local` for variables in functions.

Context: Create a function that counts characters from a string without affecting the global variable `count`.

Lines to arrange:

```
A) count_chars "hello"
B) echo "Global count: $count"
C) count_chars() {
D) count=100
E) }
F) local count=${#1}
G) echo "Characters: $count"
```

<details>
<summary>📋 Solution</summary>

One valid order: D, C, F, G, E, A, B

```bash
count=100
count_chars() {
    local count=${#1}
    echo "Characters: $count"
}
count_chars "hello"
echo "Global count: $count"
```

Output:
```
Characters: 5
Global count: 100
```

Key point: `local` prevents modification of the global variable `count`.

</details>

---

### P2: Function with Return and Echo

Objective: Understanding the difference between `return` (exit code) and `echo` (output).

Context: Create a function that calculates the sum and returns it correctly.

Lines to arrange:

```
A) echo "Sum: $result"
B) result=$(get_sum 5 3)
C) }
D) get_sum() {
E) return 0
F) local b=$2
G) local a=$1
H) echo $((a + b))
```

Distractor (not used):
```
X) result=get_sum 5 3
```

<details>
<summary>📋 Solution</summary>

One valid order: D, G, F, H, E, C, B, A

```bash
get_sum() {
    local a=$1
    local b=$2
    echo $((a + b))
    return 0
}
result=$(get_sum 5 3)
echo "Sum: $result"
```

Output: `Sum: 8`

Notes:
- `return 0` is optional (implicit if function succeeds)
- Distractor X supplies a temporary `result=get_sum` assignment to a command named `5`; it does not call `get_sum`
- `$()` captures the function's stdout

</details>

---

### P3: Recursive Function - Factorial

Objective: Understanding recursion in Bash.

Lines to arrange:

```
A) prev=$(factorial $((n - 1)))
B) echo "5! = $(factorial 5)"
C) fi
D) return
E) local prev
F) echo 1
G) local n=$1
H) echo $((n * prev))
I) }
J) factorial() {
K) if [ "$n" -le 1 ]; then
```

Distractors:
```
X) return 1
Y) prev=factorial $((n - 1))
```

<details>
<summary>📋 Solution</summary>

One valid order: J, G, K, F, D, C, E, A, H, I, B

```bash
factorial() {
    local n=$1
    if [ "$n" -le 1 ]; then
        echo 1
        return
    fi
    local prev
    prev=$(factorial $((n - 1)))
    echo $((n * prev))
}
echo "5! = $(factorial 5)"
```

Output: `5! = 120`

Why distractors are wrong:
- X: `return 1` would indicate error, not value 1
- Y: The assignment prefixes a command named by `$((n - 1))`; it does not call factorial

</details>

---

## Section 2: ARRAYS

### P4: Basic Indexed Array

Objective: Correct creation and iteration through indexed array.

Lines to arrange:

```
A) done
B) echo "Total: ${#fruits[@]}"
C) echo "Fruit: $fruit"
D) for fruit in "${fruits[@]}"; do
E) fruits=("apple" "banana" "cherry")
```

<details>
<summary>📋 Solution</summary>

One valid order: E, D, C, A, B

```bash
fruits=("apple" "banana" "cherry")
for fruit in "${fruits[@]}"; do
    echo "Fruit: $fruit"
done
echo "Total: ${#fruits[@]}"
```

Output:
```
Fruit: apple
Fruit: banana
Fruit: cherry
Total: 3
```

Key point: Quotes in `"${fruits[@]}"` are essential!

</details>

---

### P5: Associative Array

Objective: Correct creation and usage of associative arrays.

Lines to arrange:

```
A) for key in "${!config[@]}"; do
B) config[host]="localhost"
C) config[port]="8080"
D) echo "$key = ${config[$key]}"
E) declare -A config
F) done
G) config[user]="admin"
```

Distractor:
```
X) config=()
```

<details>
<summary>📋 Solution</summary>

One valid order: E, B, C, G, A, D, F

```bash
declare -A config
config[host]="localhost"
config[port]="8080"
config[user]="admin"
for key in "${!config[@]}"; do
    echo "$key = ${config[$key]}"
done
```

Why distractor X is wrong:
- `config=()` creates indexed array, not associative
- Without `declare -A`, text keys are interpreted as 0

</details>

---

### P6: Array Processing with Filtering

Objective: Map and filter on arrays.

Context: Filter even numbers from an array.

Lines to arrange:

```
A) done
B) fi
C) for n in "${numbers[@]}"; do
D) if (( n % 2 == 0 )); then
E) even=()
F) echo "Even: ${even[*]}"
G) even+=("$n")
H) numbers=(1 2 3 4 5 6 7 8 9 10)
```

Distractors:
```
X) for n in ${numbers[@]}; do
Y) even+=$n
Z) if [ n % 2 == 0 ]; then
```

<details>
<summary>📋 Solution</summary>

One valid order: H, E, C, D, G, B, A, F

```bash
numbers=(1 2 3 4 5 6 7 8 9 10)
even=()
for n in "${numbers[@]}"; do
    if (( n % 2 == 0 )); then
        even+=("$n")
    fi
done
echo "Even: ${even[*]}"
```

Output: `Even: 2 4 6 8 10`

Why distractors are wrong:
- X: Without quotes - word splitting
- Y: `even+=$n` appends to string, not to array
- Z: `[ n % 2 ]` - wrong syntax for arithmetic
- Always verify result before continuing

</details>

---

## Section 3: ROBUSTNESS

### P7: Minimal Solid Script

Objective: Basic structure for a solid script.

Lines to arrange:

```
A) set -euo pipefail
B) echo "Robust script started"
C) # Safe processing here
D) echo "Script finished"
E) IFS=$'\n\t'
F) #!/bin/bash
```

<details>
<summary>📋 Solution</summary>

One valid order: F, A, E, B, C, D

```bash
#!/bin/bash
set -euo pipefail
IFS=$'\n\t'
echo "Robust script started"
# Safe processing here
echo "Script finished"
```

Key point: establish the intended options before operations that rely on them; comments may precede them.

</details>

---

### P8: Variables with Default Values

Objective: Correct usage of default values with set -u.

Lines to arrange:

```
A) VERBOSE="${VERBOSE:-0}"
B) if [[ -n "$OUTPUT" ]]; then
C) OUTPUT="${2:-}"
D) echo "Output: $OUTPUT"
E) #!/bin/bash
F) echo "Input: $INPUT"
G) fi
H) set -u
I) INPUT="${1:-default_input.txt}"
```

<details>
<summary>📋 Solution</summary>

One valid order: E, H, I, C, A, F, B, D, G

```bash
#!/bin/bash
set -u
INPUT="${1:-default_input.txt}"
OUTPUT="${2:-}"
VERBOSE="${VERBOSE:-0}"
echo "Input: $INPUT"
if [[ -n "$OUTPUT" ]]; then
    echo "Output: $OUTPUT"
fi
```

Patterns used:
- `${1:-default}` - argument with default value
- `${2:-}` - optional argument (empty string if missing)
- `${VAR:-default}` - environment variable with default

</details>

---

### P9: Error Handling with die()

Objective: The die() pattern for fatal errors.

Lines to arrange:

```
A) echo "FATAL: $*" >&2
B) [ -f "$1" ] || die "File not found: $1"
C) }
D) exit 1
E) die() {
F) #!/bin/bash
G) set -euo pipefail
H) echo "Processing: $1"
I) [ $# -ge 1 ] || die "Usage: $0 <filename>"
```

<details>
<summary>📋 Solution</summary>

One valid order: F, G, E, A, D, C, I, B, H

```bash
#!/bin/bash
set -euo pipefail
die() {
    echo "FATAL: $*" >&2
    exit 1
}
[ $# -ge 1 ] || die "Usage: $0 <filename>"
[ -f "$1" ] || die "File not found: $1"
echo "Processing: $1"
```

Pattern: `[ condition ] || die "message"` - elegant verification with error message.

</details>

---

## Section 4: TRAP and CLEANUP

### P10: Cleanup with Trap EXIT

Objective: Correct implementation of automatic cleanup.

Lines to arrange:

```
A) #!/bin/bash
B) # At exit, cleanup() executes automatically
C) cleanup() {
D) [[ -n "$TEMP_FILE" && -f "$TEMP_FILE" ]] && rm -f "$TEMP_FILE"
E) TEMP_FILE=$(mktemp)
F) TEMP_FILE=""
G) trap cleanup EXIT
H) echo "Working with $TEMP_FILE"
I) set -euo pipefail
J) }
K) exit $exit_code
L) local exit_code=$?
```

<details>
<summary>📋 Solution</summary>

One valid order: A, I, F, C, L, D, K, J, G, E, H, B

```bash
#!/bin/bash
set -euo pipefail
TEMP_FILE=""
cleanup() {
    local exit_code=$?
    [[ -n "$TEMP_FILE" && -f "$TEMP_FILE" ]] && rm -f "$TEMP_FILE"
    exit $exit_code
}
trap cleanup EXIT
TEMP_FILE=$(mktemp)
echo "Working with $TEMP_FILE"
# At exit, cleanup() executes automatically
```

Key points:

- `temp_file=""` initialised before trap (for `set -u`)
- `local exit_code=$?` saves original code
- Trap set before resource creation


</details>

---

### P11: Error Handler with Trap ERR

Objective: Advanced debugging with trap ERR.

Lines to arrange:

```
A) }
B) local line=$1
C) local code=$3
D) error_handler() {
E) echo "Error at line $line: '$cmd' returned $code" >&2
F) trap 'error_handler $LINENO "$BASH_COMMAND" $?' ERR
G) echo "Starting..."
H) echo "This won't print"
I) local cmd=$2
J) false
K) set -euo pipefail
L) #!/bin/bash
```

<details>
<summary>📋 Solution</summary>

One valid order: L, K, D, B, I, C, E, A, F, G, J, H

```bash
#!/bin/bash
set -euo pipefail
error_handler() {
    local line=$1
    local cmd=$2
    local code=$3
    echo "Error at line $line: '$cmd' returned $code" >&2
}
trap 'error_handler $LINENO "$BASH_COMMAND" $?' ERR
echo "Starting..."
false
echo "This won't print"
```

Output:
```
Starting...
Error at line 11: 'false' returned 1
```

Note: Quotes in trap are critical for $BASH_COMMAND!

</details>

---

## Section 5: COMPLETE TEMPLATE

### P12: Complete Professional Script

Objective: Complete structure of a production script.

Lines to arrange (main sections only):

```
A) readonly SCRIPT_NAME=$(basename "$0")
B) readonly SCRIPT_VERSION="1.0.0"
C) main "$@"
D) #!/bin/bash
E) usage() {
   cat << EOF
   $SCRIPT_NAME v$SCRIPT_VERSION
   Usage: $SCRIPT_NAME [options] <file>
   EOF
   }
F) parse_args() {
   while [[ $# -gt 0 ]]; do
       case $1 in
           -h|--help) usage; exit 0 ;;
           -v|--verbose) VERBOSE=$((VERBOSE+1)); shift ;;
           *) break ;;
       esac
   done
   [[ $# -ge 1 ]] || die "Missing argument"
   INPUT="$1"
   }
G) set -euo pipefail
H) IFS=$'\n\t'
I) trap cleanup EXIT
J) VERBOSE="${VERBOSE:-0}"
K) cleanup() {
   local exit_code=$?
   # cleanup code
   exit $exit_code
   }
L) main() {
   parse_args "$@"
   validate
   echo "Processing: $INPUT"
   }
M) validate() {
   [[ -f "$INPUT" ]] || die "File not found: $INPUT"
   }
N) die() { echo "FATAL: $*" >&2; exit 1; }
```

<details>
<summary>📋 Solution</summary>

One valid order: D, G, H, A, B, J, E, N, K, I, F, M, L, C

```bash
#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

readonly SCRIPT_NAME=$(basename "$0")
readonly SCRIPT_VERSION="1.0.0"
VERBOSE="${VERBOSE:-0}"

usage() {
    cat << EOF
$SCRIPT_NAME v$SCRIPT_VERSION
Usage: $SCRIPT_NAME [options] <file>
EOF
}

die() { echo "FATAL: $*" >&2; exit 1; }

cleanup() {
    local exit_code=$?
    # cleanup code
    exit $exit_code
}
trap cleanup EXIT

parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help) usage; exit 0 ;;
            -v|--verbose) VERBOSE=$((VERBOSE+1)); shift ;;
            *) break ;;
        esac
    done
    [[ $# -ge 1 ]] || die "Missing argument"
    INPUT="$1"
}

validate() {
    [[ -f "$INPUT" ]] || die "File not found: $INPUT"
}

main() {
    parse_args "$@"
    validate
    echo "Processing: $INPUT"
}

main "$@"
```

Structure:
1. Shebang + strict mode
2. Readonly constants
3. Configuration with defaults
4. Helper functions (usage, die)
5. Cleanup + trap
6. Parse arguments
7. Validate
8. Main
9. Execution

</details>

---

## Bonus Exercises: Mix & Debug

### P13: Find the Missing Line

Context: This script almost works, but is missing ONE critical line.

```bash
#!/bin/bash
set -euo pipefail

config[host]="localhost"    # Line 4
config[port]="8080"         # Line 5

for key in "${!config[@]}"; do
    echo "$key = ${config[$key]}"
done
```

What line is missing and where?

<details>
<summary>📋 Solution</summary>

Missing: `declare -A config` before line 4

```bash
#!/bin/bash
set -euo pipefail

declare -A config           # MISSING LINE
config[host]="localhost"
config[port]="8080"

for key in "${!config[@]}"; do
    echo "$key = ${config[$key]}"
done
```

Without declare -A: config becomes indexed array, host and port are evaluated as 0.

</details>

---

### P14: Correct the Order

Context: This script has lines in wrong order and does not work correctly.

```bash
trap cleanup EXIT
TEMP_FILE=$(mktemp)
cleanup() {
    rm -f "$TEMP_FILE"
}
#!/bin/bash
set -euo pipefail
echo "Working..."
```

Arrange in correct order:

<details>
<summary>📋 Solution</summary>

```bash
#!/bin/bash
set -euo pipefail
cleanup() {
    rm -f "$TEMP_FILE"
}
trap cleanup EXIT
TEMP_FILE=$(mktemp)
echo "Working..."
```

Critical order:
1. Shebang (first line mandatory)
2. Set options
3. Cleanup definition (before trap)
4. Trap (before resource creation)
5. Resource creation
6. Logic

</details>

---

## Instructor Guide

### How to Use Parsons Problems in Class

1. Display shuffled lines on projector
2. Individual time (2 min) - students arrange mentally
3. Discussion in pairs (2 min) - compare solutions
4. Volunteer at board - arranges lines
5. Class discussion - why this order?
6. Run code - verify result

### Tips

- Start with 🟢 problems for warm-up
- Use distractors to discuss common mistakes
- Ask students to explain WHY one line comes before another
- Connect with misconceptions from Peer Instruction

### Materials Needed


- Lines printed on cards (for physical activity)
- Online tool: js-parsons, parsonsplayground
- Simple slide with numbered lines


---

*Laboratory material for Operating Systems course | ASE Bucharest - CSIE*
