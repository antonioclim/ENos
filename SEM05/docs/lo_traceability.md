# Learning Outcomes Traceability Matrix

> Operating Systems | ASE Bucharest - CSIE  
> Seminar 5: Advanced Bash Scripting  
> Version: 1.1.0 | Date: 2025-01

---

## 1. Learning Outcomes

| ID | Learning Outcome | Bloom Level |
|----|------------------|-------------|
| **LO1** | Define functions with local variables using `local` | Apply |
| **LO2** | Explain the difference between global and local variables in functions | Understand |
| **LO3** | Use `echo` for returning values from functions | Apply |
| **LO4** | Declare and manipulate indexed arrays | Apply |
| **LO5** | Declare and use associative arrays with `declare -A` | Apply |
| **LO6** | Iterate correctly through arrays using quotes | Apply |
| **LO7** | Explain the effects of `set -e`, `set -u`, `set -o pipefail` | Understand |
| **LO8** | Implement trap for cleanup on EXIT | Apply |
| **LO9** | Identify exceptions where `set -e` does NOT work | Analyse |
| **LO10** | Write scripts using the professional template | Create |

---

## 2. Traceability Matrix: LO → Activities

| LO | Main Material | Peer Instruction | Parsons | Live Coding | Sprint Exercises | Quiz |
|----|---------------|------------------|---------|-------------|------------------|------|
| **LO1** | §1.1-1.2 | Q1 | P1 | LC1.2 | E1 | q01, q15 |
| **LO2** | §1.2 | Q1, Q3 | P1 | LC1.2 | E1 | q01, q02, q03 |
| **LO3** | §1.3 | Q2 | P2 | LC1.3 | E2 | q02 |
| **LO4** | §2.1 | Q4, Q7 | P3, P6 | LC2.1 | E3 | q04, q07 |
| **LO5** | §2.2 | Q5 | P4 | LC2.2 | E4 | q05, q16 |
| **LO6** | §2.3 | Q6 | P3, P6 | LC2.3 | E5 | q06 |
| **LO7** | §4.1-4.3 | Q8-Q12 | P5, P7, P8 | LC3.1 | E6 | q08-q12, q17, q18 |
| **LO8** | §5.1-5.2 | Q13, Q14 | P5, P10, P11 | LC3.2 | E7 | q13, q14 |
| **LO9** | §4.4 | Q9, Q10 | - | LC3.1 | E8 | q09, q10, q12 |
| **LO10** | §8 | Q15 | P12 | LC4.1 | E9 | q15 |

### Legend

- **Main Material**: Sections from `S05_02_MAIN_MATERIAL.md`
- **Peer Instruction**: Questions from `S05_03_PEER_INSTRUCTION.md`
- **Parsons**: Parsons problems (P1-P5 core, P6-P14 extended) from `S05_04_PARSONS_PROBLEMS.md`
- **Live Coding**: Sessions from `S05_05_LIVE_CODING_GUIDE.md`
- **Sprint Exercises**: Exercises from `S05_06_SPRINT_EXERCISES.md`
- **Quiz**: Questions from `formative/quiz.yaml`

---

## 3. Parsons Problems with Bash-Specific Distractors

Each problem includes **distractors** — incorrect lines that test common misconceptions.

**Core Problems (P1-P5):** Essential for all students  
**Extended Problems (P6-P14):** Available in `S05_04_PARSONS_PROBLEMS.md`

---

### P1: Function with Local Variable

**Objective LO1, LO2**: Demonstrate the importance of `local` for variables in functions.

**Context**: Create a function that counts characters without modifying the global variable.

#### Lines to arrange (shuffled):

```
A) echo "Global: $count"
B) count_chars "hello world"
C) local count=${#1}
D) count=100
E) echo "In function: $count"
F) }
G) count_chars() {
```

#### Distractors (WRONG lines):

```
X1) count_chars {           # Missing ()
X2) count = ${#1}           # Spaces around =
X3) var count=${#1}         # var does not exist in Bash
```

<details>
<summary>Solution</summary>

**Correct order: D, G, C, E, F, B, A**

```bash
count=100
count_chars() {
    local count=${#1}
    echo "In function: $count"
}
count_chars "hello world"
echo "Global: $count"
```

**Output:**
```
In function: 11
Global: 100
```

**Key point**: `local` prevents modifying the global variable. Without `local`, count would become 11.

**Why distractors are wrong:**
- `X1`: Functions require `()` or keyword `function`
- `X2`: Bash does not allow spaces around `=` in assignment
- `X3`: `var` is not a valid keyword in Bash; use `local`

</details>

---

### P2: Function with Return Value via Echo

**Objective LO3**: Using `echo` for returning values.

**Context**: Create a function that calculates the sum of two numbers.

#### Lines to arrange (shuffled):

```
A) result=$(add_numbers 5 3)
B) add_numbers() {
C) local sum=$(( $1 + $2 ))
D) }
E) echo $sum
F) echo "Sum: $result"
```

#### Distractors (WRONG lines):

```
X1) return $sum              # return only for exit codes 0-255
X2) sum = $(( $1 + $2 ))     # Spaces around =
X3) result=add_numbers 5 3   # Missing $() for command substitution
```

<details>
<summary>Solution</summary>

**Correct order: B, C, E, D, A, F**

```bash
add_numbers() {
    local sum=$(( $1 + $2 ))
    echo $sum
}
result=$(add_numbers 5 3)
echo "Sum: $result"
```

**Output:**
```
Sum: 8
```

**Key point**: `return` does not return values, only exit codes (0-255). Use `echo` and capture with `$()`.

**Why distractors are wrong:**
- `X1`: `return 8` sets `$?=8`, not a usable value
- `X2`: Spaces around `=` cause syntax error
- `X3`: Without `$()`, result becomes the literal string "add_numbers"

</details>

---

### P3: Array Iteration with Quotes

**Objective LO4, LO6**: Correct iteration through arrays with elements containing spaces.

**Context**: Process a list of files with names containing spaces.

#### Lines to arrange (shuffled):

```
A) done
B) for file in "${files[@]}"; do
C) files=("document one.txt" "report two.pdf" "data three.csv")
D) echo "Processing: $file"
E) echo "Total files: ${#files[@]}"
```

#### Distractors (WRONG lines):

```
X1) for file in ${files[@]}; do     # Missing quotes - word splitting!
X2) for file in $files; do          # Completely wrong for arrays
X3) files=("document one.txt", "report two.pdf")   # Comma is not a separator
```

<details>
<summary>Solution</summary>

**Correct order: C, E, B, D, A**

```bash
files=("document one.txt" "report two.pdf" "data three.csv")
echo "Total files: ${#files[@]}"
for file in "${files[@]}"; do
    echo "Processing: $file"
done
```

**Output:**
```
Total files: 3
Processing: document one.txt
Processing: report two.pdf
Processing: data three.csv
```

**Key point**: `"${files[@]}"` with quotes keeps elements intact. Without quotes, "document one.txt" becomes 2 separate iterations.

**Why distractors are wrong:**
- `X1`: Without quotes, there would be 6 iterations (word splitting)
- `X2`: `$files` returns only the first element
- `X3`: The comma becomes part of the string, not a separator

</details>

---

### P4: Associative Array with declare -A

**Objective LO5**: Correct declaration of associative arrays.

**Context**: Store application configuration in a hash.

#### Lines to arrange (shuffled):

```
A) config[port]="8080"
B) echo "Server: ${config[host]}:${config[port]}"
C) declare -A config
D) config[host]="localhost"
E) echo "Debug: ${config[debug]}"
F) config[debug]="true"
```

#### Distractors (WRONG lines):

```
X1) config = {}                  # Python syntax, not Bash
X2) declare config               # Missing -A for associative
X3) config=()                    # Creates indexed array, not associative
X4) hash config                  # hash does not declare arrays
```

<details>
<summary>Solution</summary>

**Correct order: C, D, A, F, B, E**

```bash
declare -A config
config[host]="localhost"
config[port]="8080"
config[debug]="true"
echo "Server: ${config[host]}:${config[port]}"
echo "Debug: ${config[debug]}"
```

**Output:**
```
Server: localhost:8080
Debug: true
```

**Key point**: `declare -A` is **mandatory** before using string keys. Without it, Bash treats the array as indexed and evaluates keys to 0.

**Why distractors are wrong:**
- `X1`: Invalid syntax in Bash
- `X2`: Without `-A`, it would be an indexed array (all at index 0)
- `X3`: Creates indexed array, string keys become 0
- `X4`: `hash` does not exist for this purpose

</details>

---

### P5: Script with set -euo pipefail and Trap

**Objective LO7, LO8**: Defensive scripting with error handling.

**Context**: Create a script that processes a temporary file with automatic cleanup.

#### Lines to arrange (shuffled):

```
A) set -euo pipefail
B) #!/bin/bash
C) trap cleanup EXIT
D) echo "Important data" > "$TMPFILE"
E) cleanup() { rm -f "$TMPFILE"; echo "Cleanup done"; }
F) TMPFILE=$(mktemp)
G) cat "$TMPFILE"
```

#### Distractors (WRONG lines):

```
X1) set -e -u -o pipefail       # Valid but less common style
X2) trap cleanup                 # Missing the signal (EXIT)
X3) TMPFILE = $(mktemp)          # Spaces around =
X4) cleanup { rm -f "$TMPFILE"; }  # Missing () in function definition
```

<details>
<summary>Solution</summary>

**Correct order: B, A, E, C, F, D, G**

```bash
#!/bin/bash
set -euo pipefail

cleanup() { rm -f "$TMPFILE"; echo "Cleanup done"; }
trap cleanup EXIT

TMPFILE=$(mktemp)
echo "Important data" > "$TMPFILE"
cat "$TMPFILE"
```

**Output:**
```
Important data
Cleanup done
```

**Key point**: 
- `set -euo pipefail` activates strict mode
- `trap cleanup EXIT` guarantees cleanup even on errors
- The cleanup function must be defined BEFORE trap

**Why distractors are wrong:**
- `X2`: trap requires the signal (EXIT, ERR, INT, etc.)
- `X3`: Spaces around `=` cause error
- `X4`: Functions require `()` after the name

</details>

---

## 4. Targeted Misconceptions Summary

| Parsons | Targeted Misconception | Estimated Frequency |
|---------|------------------------|---------------------|
| P1 | Variables are local by default | 80% |
| P1 | Spaces around = are permitted | 70% |
| P2 | return returns values as in other languages | 75% |
| P2 | $() is optional for command substitution | 60% |
| P3 | Quotes in iteration are optional | 65% |
| P3 | Comma is a separator in arrays | 40% |
| P4 | declare -A is optional for hash | 70% |
| P4 | Python/JS syntax works in Bash | 45% |
| P5 | trap does not require specifying the signal | 45% |
| P5 | Function definition order doesn't matter | 50% |

---

## 5. Coverage Verification

### LO Coverage per Activity Type

| Activity | LOs Covered | Percentage |
|----------|-------------|------------|
| Main Material | LO1-LO10 | 100% |
| Peer Instruction | LO1-LO9 | 90% |
| Parsons Problems | LO1-LO8, LO10 | 90% |
| Live Coding | LO1-LO10 | 100% |
| Sprint Exercises | LO1-LO10 | 100% |
| Formative Quiz | LO1-LO9 | 90% |

### Bloom Coverage per Activity

| Activity | Remember | Understand | Apply | Analyse | Evaluate | Create |
|----------|----------|------------|-------|---------|----------|--------|
| Main Material | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| Peer Instruction | ✓ | ✓ | ✓ | ✓ | ✓ | - |
| Parsons Problems | - | ✓ | ✓ | - | - | - |
| Live Coding | - | ✓ | ✓ | - | - | ✓ |
| Sprint Exercises | ✓ | ✓ | ✓ | ✓ | - | ✓ |
| Formative Quiz | ✓ | ✓ | ✓ | ✓ | ✓ | - |

---

## 6. Assessment Alignment

### LO → Homework Mapping

| LO | Homework Requirement | Rubric Criteria |
|----|---------------------|-----------------|
| **LO1** | R1: parse_line(), count_levels() | Functions defined with proper structure |
| **LO2** | R3: Refactoring - fix global variables | All variables use `local` inside functions |
| **LO3** | R1: get_top_messages() return | Functions return via echo, captured with $() |
| **LO4** | R1: Log counting arrays | Indexed arrays properly declared and iterated |
| **LO5** | R2: CONFIG hash | `declare -A` used for all associative arrays |
| **LO6** | R1, R2: Array iteration | Quotes used in `"${arr[@]}"` patterns |
| **LO7** | R1, R2, R3: Script headers | `set -euo pipefail` present in all scripts |
| **LO8** | R1, R3: Cleanup | trap EXIT implemented with cleanup function |
| **LO9** | R3: Identify bugs in broken_script | Correct identification of set -e limitations |
| **LO10** | All requirements | Professional template structure followed |

### Rubric Criteria Weights

| Criterion | Weight | Primary LOs |
|-----------|--------|-------------|
| Functionality | 40% | LO1, LO3, LO4, LO5 |
| Code Style | 25% | LO1, LO6, LO7 |
| Error Handling | 20% | LO7, LO8, LO9 |
| Documentation | 15% | LO10 |

---

## 7. Activity Type Distribution

### Target Distribution (Brown & Wilson Principle 10)

| Activity Type | Target | Actual | Status |
|---------------|--------|--------|--------|
| Writing Code | 45-55% | 48% | ✓ |
| Parsons/Reorder | 15-20% | 18% | ✓ |
| Trace/Predict | 15-20% | 17% | ✓ |
| Debug/Fix | 10-15% | 12% | ✓ |
| Explain/Review | 5-10% | 5% | ✓ |

### Time Allocation in 100-minute Seminar

| Activity | Minutes | Percentage |
|----------|---------|------------|
| Hook Demo | 8 | 8% |
| Peer Instruction (6 questions) | 18 | 18% |
| Live Coding | 25 | 25% |
| Parsons Problems (3 selected) | 12 | 12% |
| Sprint Exercises | 20 | 20% |
| Break | 10 | 10% |
| Consolidation/Q&A | 7 | 7% |

### Bloom Distribution Verification

| Level | Target (Beginners) | Actual Quiz | Status |
|-------|-------------------|-------------|--------|
| Remember | 15-20% | 11% (2/18) | Slightly low |
| Understand | 25-30% | 44% (8/18) | Above target |
| Apply | 30-35% | 28% (5/18) | Within range |
| Analyse | 10-15% | 11% (2/18) | Within range |
| Evaluate | 3-5% | 6% (1/18) | Within range |
| Create | 3-5% | 0% | OK (covered in homework) |

---

*Document generated for Learning Outcomes traceability - Seminar 5*  
*Version 1.1.0 - Added Assessment Alignment and Activity Distribution*
