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
A) count_chars() {
B) local count=${#1}
C) echo "Characters: $count"
D) }
E) count=100
F) count_chars "hello"
G) echo "Global count: $count"
```

<details>
<summary>📋 Solution</summary>

Correct order: E, A, B, C, D, F, G

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
A) get_sum() {
B) local a=$1
C) local b=$2
D) echo $((a + b))
E) return 0
F) }
G) result=$(get_sum 5 3)
H) echo "Sum: $result"
```

Distractor (not used):
```
X) result=get_sum 5 3
```

<details>
<summary>📋 Solution</summary>

Correct order: A, B, C, D, E, F, G, H

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
- Distractor X would make `result="get_sum"` (literal string)
- `$()` captures the function's stdout

</details>

---

### P3: Recursive Function - Factorial

Objective: Understanding recursion in Bash.

Lines to arrange:

```
A) factorial() {
B) local n=$1
C) if [ "$n" -le 1 ]; then
D) echo 1
E) return
F) fi
G) local prev
H) prev=$(factorial $((n - 1)))
I) echo $((n * prev))
J) }
K) echo "5! = $(factorial 5)"
```

Distractors:
```
X) return 1
Y) prev=factorial $((n - 1))
```

<details>
<summary>📋 Solution</summary>

Correct order: A, B, C, D, E, F, G, H, I, J, K

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
- Y: Without `$()`, prev becomes string "factorial"

</details>

---

## Section 2: ARRAYS

### P4: Basic Indexed Array

Objective: Correct creation and iteration through indexed array.

Lines to arrange:

```
A) fruits=("apple" "banana" "cherry")
B) for fruit in "${fruits[@]}"; do
C) echo "Fruit: $fruit"
D) done
E) echo "Total: ${#fruits[@]}"
```

<details>
<summary>📋 Solution</summary>

Correct order: A, B, C, D, E

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
A) declare -A config
B) config[host]="localhost"
C) config[port]="8080"
D) config[user]="admin"
E) for key in "${!config[@]}"; do
F) echo "$key = ${config[$key]}"
G) done
```

Distractor:
```
X) config=()
```

<details>
<summary>📋 Solution</summary>

Correct order: A, B, C, D, E, F, G

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
A) numbers=(1 2 3 4 5 6 7 8 9 10)
B) even=()
C) for n in "${numbers[@]}"; do
D) if (( n % 2 == 0 )); then
E) even+=("$n")
F) fi
G) done
H) echo "Even: ${even[*]}"
```

Distractors:
```
X) for n in ${numbers[@]}; do
Y) even+=$n
Z) if [ n % 2 == 0 ]; then
```

<details>
<summary>📋 Solution</summary>

Correct order: A, B, C, D, E, F, G, H

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
A) #!/bin/bash
B) set -euo pipefail
C) IFS=$'\n\t'
D) echo "Robust script started"
E) # Safe processing here
F) echo "Script finished"
```

<details>
<summary>📋 Solution</summary>

Correct order: A, B, C, D, E, F

```bash
#!/bin/bash
set -euo pipefail
IFS=$'\n\t'
echo "Robust script started"
# Safe processing here
echo "Script finished"
```

Key point: `set -euo pipefail` must be immediately after shebang.

</details>

---

### P8: Variables with Default Values

Objective: Correct usage of default values with set -u.

Lines to arrange:

```
A) #!/bin/bash
B) set -u
C) INPUT="${1:-default_input.txt}"
D) OUTPUT="${2:-}"
E) VERBOSE="${VERBOSE:-0}"
F) echo "Input: $INPUT"
G) if [[ -n "$OUTPUT" ]]; then
H) echo "Output: $OUTPUT"
I) fi
```

<details>
<summary>📋 Solution</summary>

Correct order: A, B, C, D, E, F, G, H, I

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
A) #!/bin/bash
B) set -euo pipefail
C) die() {
D) echo "FATAL: $*" >&2
E) exit 1
F) }
G) [ $# -ge 1 ] || die "Usage: $0 <filename>"
H) [ -f "$1" ] || die "File not found: $1"
I) echo "Processing: $1"
```

<details>
<summary>📋 Solution</summary>

Correct order: A, B, C, D, E, F, G, H, I

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
B) set -euo pipefail
C) TEMP_FILE=""
D) cleanup() {
E) local exit_code=$?
F) [[ -n "$TEMP_FILE" && -f "$TEMP_FILE" ]] && rm -f "$TEMP_FILE"
G) exit $exit_code
H) }
I) trap cleanup EXIT
J) TEMP_FILE=$(mktemp)
K) echo "Working with $TEMP_FILE"
L) # At exit, cleanup() executes automatically
```

<details>
<summary>📋 Solution</summary>

Correct order: A, B, C, D, E, F, G, H, I, J, K, L

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
A) #!/bin/bash
B) set -euo pipefail
C) error_handler() {
D) local line=$1
E) local cmd=$2
F) local code=$3
G) echo "Error at line $line: '$cmd' returned $code" >&2
H) }
I) trap 'error_handler $LINENO "$BASH_COMMAND" $?' ERR
J) echo "Starting..."
K) false
L) echo "This won't print"
```

<details>
<summary>📋 Solution</summary>

Correct order: A, B, C, D, E, F, G, H, I, J, K, L

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
A) #!/bin/bash
B) set -euo pipefail
C) IFS=$'\n\t'
D) readonly SCRIPT_NAME=$(basename "$0")
E) readonly SCRIPT_VERSION="1.0.0"
F) VERBOSE="${VERBOSE:-0}"
G) usage() {
   cat << EOF
   $SCRIPT_NAME v$SCRIPT_VERSION
   Usage: $SCRIPT_NAME [options] <file>
   EOF
   }
H) die() { echo "FATAL: $*" >&2; exit 1; }
I) cleanup() {
   local exit_code=$?
   # cleanup code
   exit $exit_code
   }
J) trap cleanup EXIT
K) parse_args() {
   while [[ $# -gt 0 ]]; do
       case $1 in
           -h|--help) usage; exit 0 ;;
           -v|--verbose) ((VERBOSE++)); shift ;;
           *) break ;;
       esac
   done
   [[ $# -ge 1 ]] || die "Missing argument"
   INPUT="$1"
   }
L) validate() {
   [[ -f "$INPUT" ]] || die "File not found: $INPUT"
   }
M) main() {
   parse_args "$@"
   validate
   echo "Processing: $INPUT"
   }
N) main "$@"
```

<details>
<summary>📋 Solution</summary>

Correct order: A, B, C, D, E, F, G, H, I, J, K, L, M, N

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
            -v|--verbose) ((VERBOSE++)); shift ;;
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
