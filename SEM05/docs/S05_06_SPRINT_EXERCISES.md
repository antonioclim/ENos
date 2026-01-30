# S05_06 - Sprint Exercises: Timed Challenges

> Lab observation: note down key commands and relevant output (2–3 lines) as you work. It helps with debugging and, frankly, by the end you'll have a decent README without extra effort.
> Operating Systems | ASE Bucharest - CSIE  
> Seminar 5: Advanced Bash Scripting
> Version: 2.0.0 | Date: 2025-01

---

## About Sprint Exercises

Sprints are short, timed exercises (3-5 minutes) that:
- Consolidate concepts immediately after presentation
- Provide rapid feedback on understanding
- Create energy and engagement in class
- Identify students who need help

### Sprint Format

```
┌─────────────────────────────────────────────────────────┐
│  ⏱️ TIME: 3-5 minutes                                   │
│  📋 REQUIREMENT: Written clearly on screen              │
│  ✅ VERIFICATION: Run and see the output                │
│  🆘 HINT: Available on request                          │
└─────────────────────────────────────────────────────────┘
```

---

## Sprint Set 1: FUNCTIONS (After minute 45)

### Sprint 1.1: Personalised Greeting Function 3 min

Requirement:
Create a function `greet` that:

In brief: Receives a name as argument; Displays "Hello, [NAME]!"; If no argument is provided, displays "Hello, Stranger!".


File: `sprint1_1.sh`

Test:
```bash
$ ./sprint1_1.sh
# Output: Hello, Stranger!

$ ./sprint1_1.sh Ana
# Output: Hello, Ana!
```

<details>
<summary>💡 Hint</summary>

Use `${1:-default}` for default value.

</details>

<details>
<summary>📋 Solution</summary>

```bash
#!/bin/bash

greet() {
    local name="${1:-Stranger}"
    echo "Hello, $name!"
}

greet "$@"
```

</details>

---

### Sprint 1.2: Sum Function with Local 3 min

Requirement:
Create a function `calc_sum` that:

- Receives two numbers
- Calculates the sum using a local variable
- Displays the result


File: `sprint1_2.sh`

Test:
```bash
$ ./sprint1_2.sh 5 3
# Output: Sum: 8

$ ./sprint1_2.sh 100 200
# Output: Sum: 300
```

<details>
<summary>💡 Hint</summary>

```bash
local result=$((arg1 + arg2))
```

</details>

<details>
<summary>📋 Solution</summary>

```bash
#!/bin/bash

calc_sum() {
    local a=$1
    local b=$2
    local result=$((a + b))
    echo "Sum: $result"
}

calc_sum "$1" "$2"
```

</details>

---

### Sprint 1.3: Even Number Check 4 min

Requirement:
Create a function `is_even` that:
- Receives a number
- Returns exit code 0 if even, 1 if odd
- Does NOT display anything

File: `sprint1_3.sh`

Test:
```bash
$ ./sprint1_3.sh 4 && echo "Even" || echo "Odd"
# Output: Even

$ ./sprint1_3.sh 7 && echo "Even" || echo "Odd"
# Output: Odd
```

<details>
<summary>💡 Hint</summary>

`return` with the result of `[ $((n % 2)) -eq 0 ]`

</details>

<details>
<summary>📋 Solution</summary>

```bash
#!/bin/bash

is_even() {
    local n=$1
    [ $((n % 2)) -eq 0 ]
}

is_even "$1"
```

</details>

---

## Sprint Set 2: ARRAYS (After minute 45, Part 2)

### Sprint 2.1: Count Elements 3 min

Requirement:
Given a list of fruits, display:
- Each fruit on a line
- The total number of fruits at the end

Starter code:
```bash
#!/bin/bash
fruits=("apple" "banana" "cherry" "date" "elderberry")

# TODO: Complete here
```

Expected output:
```
1. apple
2. banana
3. cherry
4. date
5. elderberry
Total: 5 fruits
```

<details>
<summary>💡 Hint</summary>

Use a counter variable in the loop and `${#fruits[@]}` for total.

</details>

<details>
<summary>📋 Solution</summary>

```bash
#!/bin/bash
fruits=("apple" "banana" "cherry" "date" "elderberry")

count=1
for fruit in "${fruits[@]}"; do
    echo "$count. $fruit"
    ((count++))
done

echo "Total: ${#fruits[@]} fruits"
```

</details>

---

### Sprint 2.2: Config Hash 4 min

Requirement:
Create an associative array for server configuration:
- host = "192.168.1.100"
- port = "8080"  
- user = "admin"
- pass = "secret"

Display all key=value pairs.

<details>
<summary>💡 Hint</summary>

Don't forget `declare -A` !

</details>

<details>
<summary>📋 Solution</summary>

```bash
#!/bin/bash

declare -A config
config[host]="192.168.1.100"
config[port]="8080"
config[user]="admin"
config[pass]="secret"

for key in "${!config[@]}"; do
    echo "$key = ${config[$key]}"
done
```

</details>

---

### Sprint 2.3: Array Filtering 5 min

Requirement:
Given a list of numbers, create a new array containing only numbers > 50.

Starter code:
```bash
#!/bin/bash
numbers=(12 78 45 93 27 88 31 65 50 99)

# TODO: Create array 'big' with numbers > 50
# TODO: Display the big array
```

Expected output:
```
Numbers > 50: 78 93 88 65 99
```

<details>
<summary>💡 Hint</summary>

```bash
big=()
if (( n > 50 )); then big+=("$n"); fi
```

</details>

<details>
<summary>📋 Solution</summary>

```bash
#!/bin/bash
numbers=(12 78 45 93 27 88 31 65 50 99)

big=()
for n in "${numbers[@]}"; do
    if (( n > 50 )); then
        big+=("$n")
    fi
done

echo "Numbers > 50: ${big[*]}"
```

</details>

---

## Sprint Set 3: ROBUSTNESS (After minute 20, Part 2)

### Sprint 3.1: Minimal Robust Script 3 min

Requirement:
Modify this fragile script into a robust one:

```bash
#!/bin/bash
# FRAGILE - fix it!

echo "Input: $1"
echo "Processing..."
```

It must:

Key aspects: stop on errors, detect undefined variables and verify it receives exactly 1 argument.


<details>
<summary>📋 Solution</summary>

```bash
#!/bin/bash
set -euo pipefail

[[ $# -eq 1 ]] || { echo "Usage: $0 <input>"; exit 1; }

echo "Input: $1"
echo "Processing..."
```

</details>

---

### Sprint 3.2: File Check with die() 4 min

Requirement:
Create a script that:
- Defines the `die()` function 
- Verifies that the first argument is an existing file
- Verifies that the file is readable
- Displays "Processing: [filename]" if checks pass

<details>
<summary>📋 Solution</summary>

```bash
#!/bin/bash
set -euo pipefail

die() {
    echo "ERROR: $*" >&2
    exit 1
}

[[ $# -ge 1 ]] || die "Usage: $0 <file>"
[[ -f "$1" ]] || die "File not found: $1"
[[ -r "$1" ]] || die "Cannot read: $1"

echo "Processing: $1"
```

</details>

---

### Sprint 3.3: Default Values 4 min

Requirement:
Create a script that optionally accepts:
- `$1` = input file (default: "input.txt")
- `$2` = output file (default: "output.txt")  
- Environment `VERBOSE` (default: 0)
- Read error messages carefully — they contain valuable hints

Display the values being used.

<details>
<summary>📋 Solution</summary>

```bash
#!/bin/bash
set -euo pipefail

INPUT="${1:-input.txt}"
OUTPUT="${2:-output.txt}"
VERBOSE="${VERBOSE:-0}"

echo "Input: $INPUT"
echo "Output: $OUTPUT"
echo "Verbose: $VERBOSE"
```

</details>

---

## Sprint Set 4: TRAP and CLEANUP (After minute 35, Part 2)

### Sprint 4.1: Simple Cleanup 4 min

Requirement:
Create a script that:
- Creates a temporary file with `mktemp`
- Defines cleanup that deletes the file
- Sets trap EXIT
- Writes something to the file
- Displays the content

On exit, the file must be deleted automatically.

<details>
<summary>📋 Solution</summary>

```bash
#!/bin/bash
set -euo pipefail

TEMP=""

cleanup() {
    [[ -n "$TEMP" && -f "$TEMP" ]] && rm -f "$TEMP"
    echo "Cleanup done!"
}

trap cleanup EXIT

TEMP=$(mktemp)
echo "Hello, World!" > "$TEMP"
echo "Content: $(cat "$TEMP")"
echo "Temp file: $TEMP"
```

</details>

---

### Sprint 4.2: Error Handler 5 min

Requirement:
Create a script with:
- `set -euo pipefail`
- Error handler that displays the line and command that failed
- Trap ERR
- A command that will fail (e.g.: `false`)

<details>
<summary>📋 Solution</summary>

```bash
#!/bin/bash
set -euo pipefail

error_handler() {
    echo "Error at line $1: $2" >&2
}

trap 'error_handler $LINENO "$BASH_COMMAND"' ERR

echo "Starting..."
false
echo "This won't print"
```

</details>

---

## BONUS Sprints: Combined

### Sprint B1: Mini Complete Script 7 min

Requirement:
Create a script that:
1. Has `set -euo pipefail`
2. Defines `die()`
3. Verifies it receives 1 argument (file name)
4. Creates a temporary file
5. Has cleanup with trap EXIT
6. Counts the lines in the received file
7. Saves the result in the temporary file
8. Displays the result

Test:
```bash
$ echo -e "a\nb\nc" > test.txt
$ ./sprint_b1.sh test.txt
# Output: test.txt has 3 lines
```

<details>
<summary>📋 Solution</summary>

```bash
#!/bin/bash
set -euo pipefail

TEMP=""

die() {
    echo "ERROR: $*" >&2
    exit 1
}

cleanup() {
    [[ -n "$TEMP" && -f "$TEMP" ]] && rm -f "$TEMP"
}
trap cleanup EXIT

[[ $# -eq 1 ]] || die "Usage: $0 <file>"
[[ -f "$1" ]] || die "File not found: $1"

TEMP=$(mktemp)
wc -l < "$1" > "$TEMP"

lines=$(cat "$TEMP")
echo "$1 has $lines lines"
```

</details>

---

### Sprint B2: Word Counter with Arrays 7 min

Requirement:
Create a script that:
1. Receives text as arguments (e.g.: `./script.sh hello world hello bash`)
2. Uses an associative array to count occurrences of each word
3. Displays statistics

Test:
```bash
$ ./sprint_b2.sh the cat sat on the mat the cat
# Output:
# the: 3
# cat: 2
# sat: 1
# on: 1
# mat: 1
```

<details>
<summary>📋 Solution</summary>

```bash
#!/bin/bash
set -euo pipefail

declare -A counts

for word in "$@"; do
    ((counts[$word]++))
done

for word in "${!counts[@]}"; do
    echo "$word: ${counts[$word]}"
done
```

</details>

---

## Instructor Guide

### Recommended Timing

| Sprint | Moment | Duration |
|--------|--------|----------|
| Set 1 (Functions) | Min 45, Part 1 | 10 min total |
| Set 2 (Arrays) | Min 45, Part 2 (before break) | 12 min total |
| Set 3 (Robustness) | Min 20, Part 2 | 11 min total |
| Set 4 (Trap) | Min 35, Part 2 | 9 min total |
| Bonus | End or homework | Optional |

### How to Conduct a Sprint

1. Display the requirement (30 sec)
2. Start a visible timer 
3. Circulate through the room - identify blockages
4. Announce "1 minute remaining"
5. Stop - ask for volunteers to share
6. Show the solution - discuss variants

### If Most Students Don't Finish

- Extend by 1-2 minutes
- Offer the hint on screen
- Pair programming: those who finished help others

### Scoring (optional, for gamification)

| Result | Points |
|--------|--------|
| Complete and correct | 3 |
| Partially working | 2 |
| Valid attempt | 1 |
| Did not attempt | 0 |

---

## Progress Tracking Sheet

| Sprint | Student 1 | Student 2 | Student 3 | ... |
|--------|-----------|-----------|-----------|-----|
| 1.1 | ✓/○/✗ | | | |
| 1.2 | | | | |
| 1.3 | | | | |
| 2.1 | | | | |
| 2.2 | | | | |
| 2.3 | | | | |
| 3.1 | | | | |
| 3.2 | | | | |
| 3.3 | | | | |
| 4.1 | | | | |
| 4.2 | | | | |

Legend: ✓ = complete, ○ = partial, ✗ = did not succeed

---

*Laboratory material for the Operating Systems course | ASE Bucharest - CSIE*
