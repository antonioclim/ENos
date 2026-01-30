# Learning Outcomes Traceability - Seminar 1

## Document Index

| Code | Document | Purpose |
|------|----------|---------|
| S01_00 | PEDAGOGICAL_ANALYSIS_PLAN | Framework and gap analysis |
| S01_01 | INSTRUCTOR_GUIDE | Session delivery guide |
| S01_02 | MAIN_MATERIAL | Student-facing theory |
| S01_03 | PEER_INSTRUCTION | MCQ bank for misconceptions |
| S01_04 | PARSONS_PROBLEMS | Code reordering exercises |
| S01_05 | LIVE_CODING_GUIDE | Demo sequences |
| S01_06 | SPRINT_EXERCISES | Timed pair exercises |
| S01_07 | LLM_AWARE_EXERCISES | AI integration pedagogy |
| S01_08 | SPECTACULAR_DEMOS | Engagement hooks |
| S01_09 | VISUAL_CHEAT_SHEET | Quick reference |
| S01_10 | SELF_ASSESSMENT_REFLECTION | Metacognitive checkpoints |
| S01_11 | EXTERNAL_PLAGIARISM_TOOLS | MOSS/JPlag integration |

## Learning Outcomes

| ID | Objective | Bloom | Verification |
|----|-----------|-------|--------------|
| LO1.1 | Identify file system navigation commands | Remember | Quiz Q01 |
| LO1.2 | Describe the FHS (Filesystem Hierarchy Standard) structure | Remember | Quiz Q02 |
| LO2.1 | Explain the difference between shell and terminal | Understand | Quiz Q03 |
| LO2.2 | Differentiate absolute paths from relative paths | Understand | Quiz Q04 |
| LO3.1 | Explain environment variable behaviour | Understand | Quiz Q05 |
| LO4.1 | Use mkdir for directory structures | Apply | Quiz Q06 |
| LO4.2 | Apply source to reload configurations | Apply | Quiz Q07 |
| LO5.1 | Use brace expansion for multiple operations | Apply | Quiz Q08 |
| LO6.1 | Analyse the difference between single and double quotes | Analyse | Quiz Q09 |
| LO6.2 | Interpret exit codes for debugging | Analyse | Quiz Q10 |
| LO4.3 | Use glob patterns to select files | Apply | Quiz Q11 |
| LO6.3 | Analyse dangerous variable expansions | Analyse | Quiz Q12 |
| LO7.1 | Evaluate security problems in Bash scripts | Evaluate | Quiz Q13 |
| LO8.1 | Create functional aliases and shell functions | Create | Quiz Q14, Homework |

## Traceability Matrix

| LO | Parsons | Quiz | Sprint | Live Coding | LLM Exercise | Oral | External Tools |
|----|---------|------|--------|-------------|--------------|------|----------------|
| LO1.1 | - | Q01 | S1 | - | - | - | - |
| LO1.2 | - | Q02 | S1 | - | - | - | - |
| LO2.1 | - | Q03 | - | LC1 | - | V1 | - |
| LO2.2 | PP-A | Q04 | S2 | - | - | - | - |
| LO3.1 | PP-B | Q05 | - | LC2 | LLM1 | V2 | - |
| LO4.1 | PP-C | Q06 | S3 | - | - | - | - |
| LO4.2 | - | Q07 | - | LC3 | - | - | - |
| LO4.3 | - | Q11 | S4 | - | - | - | - |
| LO5.1 | PP-D | Q08 | S4 | - | LLM2 | - | - |
| LO6.1 | PP-E | Q09 | - | LC4 | - | V3 | - |
| LO6.2 | - | Q10 | S5 | - | - | - | - |
| LO6.3 | PP-F | Q12 | - | - | LLM3 | V4 | - |
| LO7.1 | - | Q13 | - | - | LLM4 | V5 | S01_11 |
| LO8.1 | - | Q14 | S6 | LC5 | - | V4 | - |

### Anti-Plagiarism Infrastructure

| Tool | Document | Purpose |
|------|----------|---------|
| Internal Detector | scripts/python/S01_05 | Fast similarity + AI pattern detection |
| Oral Verification Log | homework/S01_04 | Understanding confirmation documentation |
| MOSS/JPlag Guide | docs/S01_11 | External tool integration |

## Bloom Taxonomy Distribution

| Level | Target | Actual | Status |
|-------|--------|--------|--------|
| Remember | 10-15% | 14% (2/14) | OK |
| Understand | 20-25% | 21% (3/14) | OK |
| Apply | 25-30% | 29% (4/14) | OK |
| Analyse | 15-20% | 22% (3/14) | OK |
| Evaluate | 5-10% | 7% (1/14) | OK |
| Create | 5-10% | 7% (1/14) | OK |

---

## Parsons Problems with Bash-Specific Distractors

### PP-A: Directory Verification with Exit Code

**Objective:** Verify if a given directory exists and display an appropriate message.

**Code lines (scrambled + distractors):**

```
#!/bin/bash
[ -d $1 ]                    # DISTRACTOR: missing quotes
[ -d "$1" ]
[ -f "$1" ]                  # DISTRACTOR: -f is for files
if [ -d "$1" ]; then
if [ -d "$1" ]               # DISTRACTOR: missing ; then
    echo "Directory exists"
    echo Directory exists    # DISTRACTOR: missing quotes
else
    echo "Directory does NOT exist"
fi
```

<details>
<summary>Solution</summary>

```bash
#!/bin/bash
if [ -d "$1" ]; then
    echo "Directory exists"
else
    echo "Directory does NOT exist"
fi
```

**Distractor explanations:**
- `[ -d $1 ]` — without quotes, word splitting can cause errors if the path has spaces
- `[ -f "$1" ]` — `-f` checks files, not directories
- `if [ -d "$1" ]` — missing `; then` or newline before `then`
- `echo Directory exists` — works but quotes are recommended for clarity

</details>

---

### PP-B: Export Variable in Subshell

**Objective:** Set a variable and make it available in a subshell.

**Code lines (scrambled + distractors):**

```
#!/bin/bash
export $NAME="Student"       # DISTRACTOR: $ on the left
NAME = "Student"             # DISTRACTOR: spaces at =
NAME="Student"
export NAME
bash -c 'echo "Hello $NAME"'
bash -c "echo 'Hello $NAME'" # DISTRACTOR: expands in parent shell
```

<details>
<summary>Solution</summary>

```bash
#!/bin/bash
NAME="Student"
export NAME
bash -c 'echo "Hello $NAME"'
```

**Distractor explanations:**
- `export $NAME="Student"` — we do not use $ when assigning a value
- `NAME = "Student"` — spaces around `=` make Bash interpret it as a command
- `bash -c "echo 'Hello $NAME'"` — variable expands in parent shell, not in subshell

</details>

---

### PP-C: Backup with Timestamp

**Objective:** Create a backup copy of a file with a timestamp.

**Code lines (scrambled + distractors):**

```
#!/bin/bash
TIMESTAMP=`date +%Y%m%d`     # DISTRACTOR: backticks deprecated
TIMESTAMP = $(date +%Y%m%d)  # DISTRACTOR: spaces at =
TIMESTAMP=$(date +%Y%m%d)
FILE="document.txt"
BACKUP=${FILE}.${TIMESTAMP}.bak
cp "$FILE" "$BACKUP"
cp $FILE $BACKUP             # DISTRACTOR: missing quotes
echo "Backup created: $BACKUP"
```

<details>
<summary>Solution</summary>

```bash
#!/bin/bash
TIMESTAMP=$(date +%Y%m%d)
FILE="document.txt"
BACKUP="${FILE}.${TIMESTAMP}.bak"
cp "$FILE" "$BACKUP"
echo "Backup created: $BACKUP"
```

**Distractor explanations:**
- `` `date +%Y%m%d` `` — backticks work but are deprecated; use `$(...)`
- `TIMESTAMP = $(...)` — spaces cause Bash to interpret incorrectly
- `cp $FILE $BACKUP` — works but unsafe with files containing spaces in names

</details>

---

### PP-D: File Listing with Pattern

**Objective:** List all .sh and .py files and count them.

**Code lines (scrambled + distractors):**

```
#!/bin/bash
counter=0
for file in *.sh *.py; do
for $file in *.sh *.py; do   # DISTRACTOR: $ in loop variable
for file in *.sh,py; do      # DISTRACTOR: comma not valid
    if [ -f "$file" ]; then
        echo "Found: $file"
        ((counter++))
        counter++             # DISTRACTOR: missing $((...))
    fi
done
echo "Total: $counter files"
```

<details>
<summary>Solution</summary>

```bash
#!/bin/bash
counter=0
for file in *.sh *.py; do
    if [ -f "$file" ]; then
        echo "Found: $file"
        ((counter++))
    fi
done
echo "Total: $counter files"
```

**Distractor explanations:**
- `for $file` — we do not use $ when declaring the iteration variable
- `*.sh,py` — comma does not work for multiple patterns; use space
- `counter++` — in Bash, incrementing requires `((counter++))` or `counter=$((counter+1))`

</details>

---

### PP-E: Function with Parameter Validation

**Objective:** Define a function that greets a user with parameter validation.

**Code lines (scrambled + distractors):**

```
#!/bin/bash
function greet {             # DISTRACTOR: missing ()
greet() {
    if [ -z "$1" ]; then
    if [ -z $1 ]; then       # DISTRACTOR: missing quotes
        echo "Error: Specify a name"
        exit 1               # DISTRACTOR: exit closes script
        return 1
    fi
    echo "Hello, $1!"
}
greet "Maria"
greet                        # Test the error
```

<details>
<summary>Solution</summary>

```bash
#!/bin/bash
greet() {
    if [ -z "$1" ]; then
        echo "Error: Specify a name"
        return 1
    fi
    echo "Hello, $1!"
}
greet "Maria"
greet                        # Test the error
```

**Distractor explanations:**
- `function greet {` — valid syntax but non-POSIX; prefer `greet() {`
- `[ -z $1 ]` — without quotes, if $1 is empty, command becomes `[ -z ]` which is an error
- `exit 1` — closes the entire script; in functions use `return`

</details>

---

### PP-F: Safe File Deletion with Confirmation

**Objective:** Delete files matching a pattern but only after user confirmation.

**Code lines (scrambled + distractors):**

```
#!/bin/bash
FILES=$(ls *.tmp)            # DISTRACTOR: parsing ls is unsafe
FILES=$(find . -name "*.tmp" -maxdepth 1)
echo "Will delete: $FILES"
read -p "Continue? (y/n) " CONFIRM
if [ $CONFIRM = "y" ]; then  # DISTRACTOR: missing quotes
if [[ "$CONFIRM" == "y" ]]; then
    rm $FILES                # DISTRACTOR: missing quotes, wrong for multiple
    rm "$FILES"              # DISTRACTOR: treats list as one filename
    rm -f *.tmp
    echo "Deleted."
fi
```

<details>
<summary>Solution</summary>

```bash
#!/bin/bash
FILES=$(find . -name "*.tmp" -maxdepth 1)
echo "Will delete: $FILES"
read -p "Continue? (y/n) " CONFIRM
if [[ "$CONFIRM" == "y" ]]; then
    rm -f *.tmp
    echo "Deleted."
fi
```

**Distractor explanations:**
- `ls *.tmp` — parsing ls output is fragile and breaks with special characters in filenames
- `[ $CONFIRM = "y" ]` — if CONFIRM is empty, becomes `[ = "y" ]` which causes an error
- `rm $FILES` — unquoted, causes word splitting issues with filenames containing spaces
- `rm "$FILES"` — treats entire newline-separated list as a single filename

</details>

---

## Methodological Note

Distractors are selected based on frequently observed errors in students:
- 70% — spaces at assignment (VAR = "val")
- 60% — missing quotes on variables
- 45% — single/double quotes confusion
- 40% — backticks instead of $()
- 35% — $ on the left at assignment

Each distractor represents a real syntax error or unexpected behaviour.

---

## Oral Verification Questions Pool

| ID | Question | Tests LO | Difficulty |
|----|----------|----------|------------|
| V1 | What is the difference between shell and terminal? | LO2.1 | Easy |
| V2 | What happens to a variable without export in a subshell? | LO3.1 | Medium |
| V3 | What will this echo display: NAME='test'; echo 'Hello $NAME' | LO6.1 | Medium |
| V4 | Why is rm -rf $DIR dangerous if DIR is empty? | LO6.3 | Hard |
| V5 | What security issue do you see in this script? [show script] | LO7.1 | Hard |

---

*Learning Outcomes Traceability | OS Seminar 1 | ASE-CSIE*
*Version 2.0 | January 2025*
