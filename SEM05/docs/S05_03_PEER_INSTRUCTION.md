# S05_03 - Peer Instruction: Discussion Questions

> Operating Systems | ASE Bucharest - CSIE  
> Seminar 5: Advanced Bash Scripting
> Version: 2.0.0 | Date: 2025-01

---

## About Peer Instruction

Peer Instruction is a pedagogical method developed by Eric Mazur (Harvard) that:
1. Presents a conceptual question (MCQ)
2. Students vote individually
3. Discussion in pairs/small groups (2-3 min)
4. Revote
5. Explanation from instructor

### When to Use Each Question

| Seminar Section | Recommended Questions |
|-----------------|----------------------|
| After functions (0:20) | Q1, Q2, Q3 |
| After arrays (0:40) | Q4, Q5, Q6, Q7 |
| After break - reactivation | Q8 |
| After stability (1:20) | Q9, Q10, Q11, Q12 |
| After logging/trap (1:35) | Q13, Q14 |
| Final - consolidation | Q15, Q16, Q17, Q18 |

---

## Section 1: FUNCTIONS

### Q1: Variables in Functions (Misconception 80%)

```bash
#!/bin/bash
count=10

increment() {
    count=$((count + 1))
    echo "In function: $count"
}

increment
echo "After function: $count"
```

What does the last line display?

- A) `After function: 10`
- B) `After function: 11`
- C) `After function: ` (empty)
- D) Error - count is not defined in main

<details>
<summary>📋 Answer and Explanation</summary>

Correct answer: B) `After function: 11`

Explanation:

Key aspects: in bash, variables in functions are global by default, `count` in the function modifies the global variable and this is the opposite of behaviour in python/java/c.


Targeted misconception: 80% believe variables are local by default

Follow-up question: "How do we make the variable stay local?"
→ Answer: `local count=$((count + 1))`

</details>

---

### Q2: Return vs Echo (Misconception 75%)

```bash
#!/bin/bash

get_value() {
    return 42
}

result=$(get_value)
echo "Result: '$result'"
```

What does it display?

- A) `Result: '42'`
- B) `Result: ''` (empty string)
- C) `Result: '0'`
- D) Syntax error

<details>
<summary>📋 Answer and Explanation</summary>

Correct answer: B) `Result: ''` (empty string)

Explanation:
- `return` in Bash sets only exit code (0-255), does not return values
- `$()` captures **stdout**, not the exit code
- The function does not `echo`, so stdout is empty
- Use `man` or `--help` when in doubt

How to check the exit code:
```bash
get_value
echo "Exit code: $?"    # 42
```

How to return values:
```bash
get_value() {
    echo 42    # This is "returning" in Bash
}
result=$(get_value)    # result="42"
```

Targeted misconception: 75% believe return works as in other languages

</details>

---

### Q3: Function Arguments vs Script (Misconception 65%)

```bash
#!/bin/bash
# Script saved as test.sh and run with: ./test.sh SCRIPT_ARG

show_arg() {
    echo "Function sees: $1"
}

echo "Script sees: $1"
show_arg "FUNC_ARG"
```

Run with `./test.sh SCRIPT_ARG`, what does the second line display?

- A) `Function sees: SCRIPT_ARG`
- B) `Function sees: FUNC_ARG`
- C) `Function sees: ` (empty)
- D) `Function sees: $1`

<details>
<summary>📋 Answer and Explanation</summary>

Correct answer: B) `Function sees: FUNC_ARG`

Explanation:
- `$1` in function refers to the function argument, not the script's
- Functions have their own set of positional arguments
- To access script arguments from function, they must be passed explicitly

Demonstration:
```bash
show_arg() {
    echo "Function arg: $1"
    echo "All function args: $@"
}

show_arg "A" "B" "C"
# Function arg: A
# All function args: A B C
```

Targeted misconception: 65% confuse $1 in function with $1 in script

</details>

---

## Section 2: ARRAYS

### Q4: Array Indexing (Misconception 55%)

```bash
#!/bin/bash
arr=("first" "second" "third")
echo "${arr[1]}"
```

What does it display?

- A) `first`
- B) `second`
- C) `third`
- D) Error - index 1 does not exist

<details>
<summary>📋 Answer and Explanation</summary>

Correct answer: B) `second`

Explanation:
- Arrays in Bash start from index 0, not 1
- `arr[0]` = "first"
- `arr[1]` = "second"
- `arr[2]` = "third"

**Attention for students familiar with Lua, R or other 1-indexed languages!**

Targeted misconception: 55% believe arrays start from 1

</details>

---

### Q5: declare -A (Misconception 70%)

```bash
#!/bin/bash
# Without declare -A
config[host]="localhost"
config[port]="8080"
echo "Keys: ${!config[@]}"
```

What does it display?

- A) `Keys: host port`
- B) `Keys: 0`
- C) `Keys: 0 0`
- D) Error - config is not declared

<details>
<summary>📋 Answer and Explanation</summary>

Correct answer: B) `Keys: 0`

Explanation:
- Without `declare -A`, Bash treats `config` as **indexed** array
- `host` and `port` are evaluated as variables (undefined = 0)
- Both assignments write to `config[0]`!
- First value is overwritten by second

Complete demonstration:
```bash
# Without declare -A
config[host]="localhost"    # config[0]="localhost"
config[port]="8080"         # config[0]="8080" (overwrites!)
echo "${config[@]}"         # 8080
echo "${!config[@]}"        # 0

# With declare -A
declare -A config
config[host]="localhost"
config[port]="8080"
echo "${!config[@]}"        # host port (correct!)
```

Targeted misconception: 70% believe declare -A is optional

</details>

---

### Q6: Iteration with Quotes (Misconception 65%)

```bash
#!/bin/bash
files=("file one.txt" "file two.txt")

count=0
for f in ${files[@]}; do
    ((count++))
done
echo "Iterations: $count"
```

How many iterations does the loop have?

- A) 2
- B) 4
- C) 1
- D) Error

<details>
<summary>📋 Answer and Explanation</summary>

Correct answer: B) 4

Explanation:
- Without quotes, Bash applies word splitting
- "file one.txt" becomes 2 words: "file" and "one.txt"
- "file two.txt" becomes 2 words: "file" and "two.txt"
- Total: 4 iterations

Correct:
```bash
for f in "${files[@]}"; do    # With quotes!
    ((count++))
done
# Now there are only 2 iterations
```

Golden rule: ALWAYS use `"${arr[@]}"` with quotes!

Targeted misconception: 65% forget quotes when iterating

</details>

---

### Q7: Deleting Element from Array

```bash
#!/bin/bash
arr=("a" "b" "c" "d" "e")
unset arr[2]
echo "Indices: ${!arr[@]}"
echo "Length: ${#arr[@]}"
```

What does it display?

- A) `Indices: 0 1 2 3` and `Length: 4`
- B) `Indices: 0 1 3 4` and `Length: 4`
- C) `Indices: 0 1 2 3 4` and `Length: 5`
- D) Error

<details>
<summary>📋 Answer and Explanation</summary>

Correct answer: B) `Indices: 0 1 3 4` and `Length: 4`

Explanation:
- `unset arr[2]` deletes the element but does NOT re-index
- The array becomes "sparse" (with gap)
- Remaining indices: 0, 1, 3, 4 (2 is missing)
- Length is 4 (number of existing elements)

Practical implications:
- Classic loop `for ((i=0; i<${#arr[@]}; i++))` can miss elements!
- Use `for i in "${!arr[@]}"` for safety

</details>

---

## Section 3: ROBUSTNESS (set -euo pipefail)

### Q8: Reactivation after Break

```bash
#!/bin/bash
set -euo pipefail

x="${UNDEFINED_VAR}"
echo "Continues..."
```

What happens?

- A) Displays `Continues...` with x=""
- B) Error: unbound variable
- C) Displays `Continues...` with x="UNDEFINED_VAR"
- D) Depends on Bash version

<details>
<summary>📋 Answer and Explanation</summary>

**Correct answer: B) Error: unbound variable**

Explanation:
- `set -u` (nounset) makes undefined variables cause error
- `UNDEFINED_VAR` does not exist → script stops

How to use optional variables with set -u:
```bash
# Default value
x="${UNDEFINED_VAR:-default}"

# Empty string as default
x="${UNDEFINED_VAR:-}"

# Explicit check
if [[ -n "${UNDEFINED_VAR:-}" ]]; then
    echo "It is set"
fi
```

</details>

---

### Q9: set -e in if (Misconception 75%)

```bash
#!/bin/bash
set -e

if false; then
    echo "In if"
fi
echo "After if"
```

What happens?

- A) Script stops at `false`
- B) Displays `After if`
- C) Displays `In if` then `After if`
- D) Syntax error

<details>
<summary>📋 Answer and Explanation</summary>

Correct answer: B) Displays `After if`

Explanation:
- `set -e` does NOT work for commands in `if/while/until` conditions
- `false` is in a test context, so the error is ignored
- Script continues normally

Other cases where set -e does NOT work:
- Commands followed by `||` or `&&`
- Commands negated with `!`
- Functions called in test context

Targeted misconception: 75% believe set -e stops on ANY error

</details>

---

### Q10: set -e with || (Misconception 60%)

```bash
#!/bin/bash
set -e

false || echo "Rescued"
echo "Continues"
```

What does it display?

- A) Nothing - script stops
- B) `Rescued` then `Continues`
- C) Only `Continues`
- D) Only `Rescued`

<details>
<summary>📋 Answer and Explanation</summary>

Correct answer: B) `Rescued` then `Continues`

Explanation:
- `||` "saves" the error - set -e does not apply
- `false` fails → the part after `||` executes
- `echo "Rescued"` succeeds → pipeline returns 0
- Script continues

Useful pattern:
```bash
set -e
command_that_might_fail || {
    echo "Failed, but handling it..."
}
# Script continues
```

</details>

---

### Q11: pipefail

```bash
#!/bin/bash
set -o pipefail

false | true | true
echo "Exit: $?"
```

What does it display?

- A) `Exit: 0`
- B) `Exit: 1`
- C) `Exit: 2`
- D) Nothing - script stops

<details>
<summary>📋 Answer and Explanation</summary>

Correct answer: B) `Exit: 1`

Explanation:

Concretely: With `pipefail`, pipeline returns exit code of first command that fails. `false` returns 1. And without pipefail, it would have returned 0 (from the last `true`).


PIPESTATUS for debugging:
```bash
false | true | true
echo "Individual: ${PIPESTATUS[@]}"    # 1 0 0
```

</details>

---

### Q12: Combination set -e and pipefail

```bash
#!/bin/bash
set -eo pipefail

cat /nonexistent | grep "pattern"
echo "After pipe"
```

What happens?

- A) Displays error from cat, then `After pipe`
- B) Script stops at cat error
- C) Displays `After pipe` (grep saves)
- D) Depends on existence of file "pattern"

<details>
<summary>📋 Answer and Explanation</summary>

**Correct answer: B) Script stops at cat error**

Explanation:
- `set -e` + `pipefail` = errors from pipe stop the script
- `cat /nonexistent` fails (exit code ≠ 0)
- With pipefail, pipeline returns this exit code
- With set -e, script stops

Without pipefail:
- Pipeline would return grep's exit code
- Grep on empty input returns 1 (no match)
- Would still stop, but for different reason!

</details>

---

## Section 4: TRAP and ERROR HANDLING

### Q13: Trap EXIT

```bash
#!/bin/bash
set -e

cleanup() {
    echo "Cleanup executed"
}
trap cleanup EXIT

echo "Start"
false
echo "End"
```

What does it display?

- A) `Start` then `Cleanup executed`
- B) `Start`, `End`, `Cleanup executed`
- C) Only `Start`
- D) `Cleanup executed` then `Start`

<details>
<summary>📋 Answer and Explanation</summary>

Correct answer: A) `Start` then `Cleanup executed`

Explanation:
- `trap cleanup EXIT` executes always on exit
- `false` + `set -e` → script stops
- But trap EXIT still executes!
- `End` is not displayed because script stopped

This is why trap EXIT is perfect for cleanup:
- Works on normal exit
- Works on errors
- Works on Ctrl+C (if you also have trap INT)
- Always verify result before continuing

</details>

---

### Q14: Trap and Subshell

```bash
#!/bin/bash

cleanup() { echo "Cleanup"; }
trap cleanup EXIT

(
    echo "In subshell"
    exit 1
)

echo "After subshell: $?"
```

How many "Cleanup" appear?

- A) 0
- B) 1
- C) 2
- D) Depends on Bash version

<details>
<summary>📋 Answer and Explanation</summary>

Correct answer: B) 1

Explanation:
- Traps are NOT inherited in subshells
- The subshell (in parentheses) does not have cleanup trap
- When subshell does exit 1, cleanup does not execute
- Cleanup executes only when main script terminates

Complete output:
```
In subshell
After subshell: 1
Cleanup
```

If you want trap in subshell:
```bash
(
    trap cleanup EXIT
    # now works in subshell
)
```

</details>

---

## Section 5: CONSOLIDATION

### Q15: Professional Template

What is the correct order of sections in a professional script?

- A) Shebang → Main → Functions → Trap → Constants
- B) Shebang → Constants → Functions → Trap → Main
- C) Shebang → set -euo pipefail → Constants → Functions → Trap → Parse Args → Main
- D) Main → Functions → Shebang → Trap

<details>
<summary>📋 Answer and Explanation</summary>

Correct answer: C)

Recommended structure:
```bash
#!/bin/bash                    # 1. Shebang
set -euo pipefail             # 2. Strict mode
IFS=$'\n\t'                   # 3. Safe IFS

readonly SCRIPT_NAME=...      # 4. Constants
VERBOSE=${VERBOSE:-0}         # 5. Configuration

usage() { ... }               # 6. Helper functions
die() { ... }

cleanup() { ... }             # 7. Cleanup
trap cleanup EXIT             # 8. Trap

parse_args() { ... }          # 9. Argument parsing
validate() { ... }            # 10. Validation

main() {                      # 11. Main
    parse_args "$@"
    validate
    # logic
}

main "$@"                     # 12. Execution
```

</details>

---

### Q16: Identify the Bug

```bash
#!/bin/bash
set -euo pipefail

declare -a files
files=$(find . -name "*.txt")

for f in ${files[@]}; do
    process "$f"
done
```

How many bugs does this code have?

- A) 1
- B) 2
- C) 3
- D) 4 or more

<details>
<summary>📋 Answer and Explanation</summary>

Correct answer: C) 3 main bugs

Bug 1: `files=$(...)` - wrong assignment for array
```bash
# Wrong:
files=$(find . -name "*.txt")    # files becomes STRING

# Correct:
mapfile -t files < <(find . -name "*.txt")
# or
readarray -t files < <(find . -name "*.txt")
```

Bug 2: `${files[@]}` without quotes
```bash
# Wrong:
for f in ${files[@]}; do    # Word splitting!

# Correct:
for f in "${files[@]}"; do
```

Bug 3: Potential - `declare -a` is not necessary for indexed arrays
```bash
# OK but redundant:
declare -a files

# Sufficient:
files=()
```

</details>

---

### Q17: Best Practice

Which stahomeworknt is FALSE about best practices in Bash?

> 💡 Many students initially underestimate the importance of permissions. Then they encounter their first 'Permission denied' and see the light.


- A) `local` should be used for all variables in functions
- B) `declare -A` is mandatory for associative arrays
- C) `set -e` stops the script on absolutely any error
- D) `"${arr[@]}"` with quotes is necessary for correct iteration

<details>
<summary>📋 Answer and Explanation</summary>

Correct answer: C) is FALSE

Explanation:
- A) TRUE - local prevents side effects
- B) TRUE - without it, Bash treats as indexed array
- C) FALSE - set -e has multiple exceptions (if, ||, &&, !, etc.)
- D) TRUE - without quotes, word splitting corrupts elements

set -e exceptions:
1. Commands in if/while/until
2. Left side of || or &&
3. Commands negated with !
4. Functions in test context
5. Subshells (without inherit_errexit)

</details>

---

### Q18: Debugging

```bash
#!/bin/bash
DEBUG="${DEBUG:-false}"

process() {
    local file="$1"
    $DEBUG && echo "[DEBUG] Processing: $file" >&2
    # ... processing
}
```

What does `$DEBUG && echo ...` do?

- A) Always displays the debug message
- B) Displays message only if DEBUG="true"
- C) Displays message only if DEBUG is any non-empty value
- D) Syntax error

<details>
<summary>📋 Answer and Explanation</summary>

Correct answer: B) Displays message only if DEBUG="true"

Explanation:
- `$DEBUG` expands to the variable value
- If DEBUG="true", command is `true && echo ...` → echo executes
- If DEBUG="false", command is `false && echo ...` → echo does NOT execute
- `&&` executes right side only if left succeeds

Alternative pattern:
```bash
[[ "$DEBUG" == "true" ]] && echo "[DEBUG] ..."
```

Activation:
```bash
DEBUG=true ./script.sh
```

</details>

---

## Facilitation Guide

### Before Question
1. Ensure the concept has been presented
2. Read the question aloud
3. Allow 30 seconds for individual thinking

### After First Vote
- If >70% correct → Brief explanation and continue
- If 30-70% correct → Peer Discussion (2-3 min)
- If <30% correct → Re-explain concept, then revote

### During Peer Discussion
- Encourage: "Explain to each other WHY you chose the answer"
- Circulate through room and listen to arguments
- Note interesting misconceptions for explanation

### After Revote
- Show vote distribution
- Ask a student to explain correct answer
- Complete with missing information
- Connect to next concept

---

## Answer Recording Sheet

| Question | Pre-vote | Post-vote | Observations |
|----------|----------|-----------|--------------|
| Q1 (local) | __ / __ % | __ / __ % | |
| Q2 (return) | __ / __ % | __ / __ % | |
| Q3 ($1 scope) | __ / __ % | __ / __ % | |
| Q4 (index 0) | __ / __ % | __ / __ % | |
| Q5 (declare -A) | __ / __ % | __ / __ % | |
| Q6 (quotes) | __ / __ % | __ / __ % | |
| Q7 (unset) | __ / __ % | __ / __ % | |
| Q8 (set -u) | __ / __ % | __ / __ % | |
| Q9 (set -e if) | __ / __ % | __ / __ % | |
| Q10 (set -e ||) | __ / __ % | __ / __ % | |
| Q11 (pipefail) | __ / __ % | __ / __ % | |
| Q12 (combo) | __ / __ % | __ / __ % | |
| Q13 (trap EXIT) | __ / __ % | __ / __ % | |
| Q14 (trap subshell) | __ / __ % | __ / __ % | |
| Q15 (template) | __ / __ % | __ / __ % | |
| Q16 (bugs) | __ / __ % | __ / __ % | |
| Q17 (best practice) | __ / __ % | __ / __ % | |
| Q18 (debug) | __ / __ % | __ / __ % | |

---

*Laboratory material for Operating Systems course | ASE Bucharest - CSIE*
