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

Activity IDs below are the numbered headings in their respective files: `P` in
S01_04, `S` in S01_06 and section numbers in S01_05. `PP-A` through `PP-F` refer to
the additional puzzles later in this document. A dash means that no direct
assessment mapping is asserted. The quiz bank is the canonical item source.

| LO | Parsons | Quiz | Sprint | Live coding section | Oral |
|----|---------|------|--------|---------------------|------|
| LO1.1 | P1 | q01 | S1 | 2.1–2.2 | — |
| LO1.2 | — | q02 | S1 | 2.2 | — |
| LO2.1 | — | q03 | — | 1 | V1 |
| LO2.2 | P1 | q04 | S1 | 2.2 | — |
| LO3.1 | P6, PP-B | q05 | — | 4.2 | V2 |
| LO4.1 | P2, P4 | q06 | S2 | 3.1 | — |
| LO4.2 | P7 | q07 | S3 | 6.2–6.3 | — |
| LO4.3 | P10, PP-D | q11 | S4 | 7 | — |
| LO5.1 | P4 | q08 | S2 | 3.1 | — |
| LO6.1 | P5 | q09 | S5 M1 | 5 | V3 |
| LO6.2 | P9 | q10 | — | 4.3 | — |
| LO6.3 | P8, PP-F | q12 | — | 3.3 (expansion warning) | V4 |
| LO7.1 | — | q13 | — | — | V5 |
| LO8.1 | P7, PP-E | q14 (manual) | S3 | 6.2–6.3 | — |

The external similarity tools support comparisons for human review; they do not
assess a learning outcome or establish authorship by themselves. Misconception
IDs are defined in [the catalogue](MISCONCEPTION_CATALOGUE.md).

### Anti-Plagiarism Infrastructure

| Tool | Document | Purpose |
|------|----------|---------|
| Internal Detector | scripts/python/S01_05 | Text/code similarity and lexical observations for human review |
| Oral Verification Log | homework/S01_04 | Understanding confirmation documentation |
| MOSS/JPlag Guide | docs/S01_11 | External tool integration |

## Bloom Taxonomy Distribution

| Level | Target | Actual | Status |
|-------|--------|--------|--------|
| Remember | 10-15% | 14.3% (2/14) | Within target |
| Understand | 20-25% | 21.4% (3/14) | Within target |
| Apply | 25-30% | 28.6% (4/14) | Within target |
| Analyse | 15-20% | 21.4% (3/14) | Outside target; curriculum decision open |
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
    echo Directory exists    # VALID ALTERNATIVE for these two literal words
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

### PP-B: Export Variable to a New Interpreter

**Objective:** Set a variable and make it available in a newly executed `bash -c`. A parenthesised group already inherits ordinary shell variables.

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
TIMESTAMP=`date +%Y%m%d`     # VALID ALTERNATIVE: supported backtick syntax
TIMESTAMP = $(date +%Y%m%d)  # DISTRACTOR: spaces at =
TIMESTAMP=$(date +%Y%m%d)
FILE="document.txt"
BACKUP="${FILE}.${TIMESTAMP}.bak"
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
- `` `date +%Y%m%d` `` — backticks remain supported; `$(...)` is usually easier to quote and nest
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
        counter=$((counter+1))
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
        counter=$((counter+1))
    fi
done
echo "Total: $counter files"
```

**Distractor explanations:**
- `for $file` — we do not use $ when declaring the iteration variable
- `*.sh,py` — comma does not work for multiple patterns; use space
- `counter++` — in Bash, incrementing requires `counter=$((counter+1))` or `counter=$((counter+1))`

</details>

---

### PP-E: Function with Parameter Validation

**Objective:** Define a function that greets a user with parameter validation.

**Code lines (scrambled + distractors):**

```
#!/bin/bash
function greet {             # VALID BASH ALTERNATIVE (not POSIX sh)
greet() {
    if [ -z "${1-}" ]; then
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
    if [ -z "${1-}" ]; then
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
- `[ -z $1 ]` — without quotes, if $1 is empty, the command becomes `[ -z ]`: a one-argument nonempty-string test that succeeds; this accidental result is not a reliable validation contract
- `exit 1` — closes the entire script; in functions use `return`

</details>

---

### PP-F: Safe File Deletion with Confirmation

**Objective:** Within a newly created owned workspace, preview and delete the same regular-file predicate after confirmation. This is not atomic: concurrent pathname changes remain possible.

**Code lines (scrambled + distractors):**

```
#!/bin/bash
FILES=$(ls *.tmp)            # DISTRACTOR: parsing ls is unsafe
find . -maxdepth 1 -type f -name "*.tmp" -print
# Review the regular-file candidates above (including dotfiles).
read -p "Continue? (y/n) " CONFIRM
if [ $CONFIRM = "y" ]; then  # DISTRACTOR: missing quotes
if [[ "$CONFIRM" == "y" ]]; then
    rm $FILES                # DISTRACTOR: missing quotes, wrong for multiple
    rm "$FILES"              # DISTRACTOR: treats list as one filename
    find . -maxdepth 1 -type f -name "*.tmp" -delete && echo "Deletion completed."
fi
```

<details>
<summary>Solution</summary>

```bash
#!/bin/bash
find . -maxdepth 1 -type f -name "*.tmp" -print
# Review the regular-file candidates above (including dotfiles).
read -p "Continue? (y/n) " CONFIRM
if [[ "$CONFIRM" == "y" ]]; then
    find . -maxdepth 1 -type f -name "*.tmp" -delete && echo "Deletion completed."
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

The following historical frequencies are retained from the authored plan; the repository does not supply the cohort, observations or method required to validate them:
- 70% — spaces at assignment (VAR = "val")
- 60% — missing quotes on variables
- 45% — single/double quotes confusion
- 40% — backticks instead of $()
- 35% — $ on the left at assignment

Some candidates represent real errors; explicitly marked alternatives are valid Bash with different style or context. Do not classify backticks, `function name { ...; }` or literal unquoted words as inherently invalid.

---

## Oral Verification Questions Pool

| ID | Question | Tests LO | Difficulty |
|----|----------|----------|------------|
| V1 | What is the difference between shell and terminal? | LO2.1 | Easy |
| V2 | Compare an unexported variable in `( ... )` and a new `bash -c`. | LO3.1 | Medium |
| V3 | What will this echo display: NAME='test'; echo 'Hello $NAME' | LO6.1 | Medium |
| V4 | Why does both `$DIR/temp` and `"$DIR/temp"` denote `/temp` when DIR is empty? | LO6.3 | Hard |
| V5 | What security issue do you see in this script? [show script] | LO7.1 | Hard |

---

*Learning Outcomes Traceability | OS Seminar 1 | ASE-CSIE*
*Version 2.0 | January 2025*
