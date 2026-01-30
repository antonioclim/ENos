# S05_07 — LLM-Aware Exercises: Assessment in the AI Era

> **Operating Systems** | ASE Bucharest — CSIE  
> **Seminar 5:** Advanced Bash Scripting  
> **Version:** 2.1.0 | **Date:** 2025-01

---

## LLM-Aware Philosophy

In the ChatGPT/Claude/Copilot era, traditional assessment ("write a script that...") becomes problematic. Students can generate functional code without understanding what it does.

> *Personal observation: After three semesters of watching students submit suspiciously perfect code they couldn't explain verbally, I've developed a healthy scepticism. The exercises below are specifically designed to separate understanding from copy-paste. — Antonio*

### LLM-Resistant Assessment Strategies

| Strategy | Description | Effectiveness |
|----------|-------------|---------------|
| Explain Code | Explain existing code | ⭐⭐⭐⭐⭐ |
| Predict Output | What will this code display? | ⭐⭐⭐⭐⭐ |
| Debug & Fix | Find and fix bugs | ⭐⭐⭐⭐ |
| Code Review | Critique and improve | ⭐⭐⭐⭐ |
| Trace Execution | Follow step by step | ⭐⭐⭐⭐ |
| Transfer Knowledge | Apply in new context | ⭐⭐⭐ |
| **Personalised Data** | Use student's own identifiers | ⭐⭐⭐⭐⭐ |

---

## Exercise Type 7: PERSONALISED DEBUGGING (NEW)

> ⚠️ **Anti-AI Strategy:** These exercises use YOUR unique data. AI cannot generate "your" student ID or birthdate.

### E7.1: Your Birthday Bug Hunt

Using YOUR student ID and birthdate, create and debug a script:

```bash
#!/bin/bash
set -euo pipefail

# ═══════════════════════════════════════════════════════════════════
# PERSONALISATION REQUIRED
# Replace the placeholders with YOUR actual data
# ═══════════════════════════════════════════════════════════════════

STUDENT_ID="[YOUR_FULL_STUDENT_ID]"         # e.g., "12345678"
BIRTH_DAY="[YOUR_BIRTH_DAY_01-31]"          # e.g., "15"
BIRTH_MONTH="[YOUR_BIRTH_MONTH_01-12]"      # e.g., "03"

# Extract last 2 digits of student ID for array size
ARRAY_SIZE="${STUDENT_ID: -2}"

# Create array with that many elements
declare -a items
for ((i=0; i<ARRAY_SIZE; i++)); do
    items+=("item_$i")
done

# ═══════════════════════════════════════════════════════════════════
# BUG ZONE: There are 3 bugs below. Find and fix them.
# ═══════════════════════════════════════════════════════════════════

# Bug 1: Something wrong with this index calculation
target_index=$((BIRTH_MONTH + BIRTH_DAY))

# Bug 2: This access might fail
echo "Element at combined index: ${items[$target_index]}"

# Bug 3: This loop has a quoting issue
for item in ${items[@]}; do
    if [[ $item == item_${BIRTH_DAY} ]]; then
        echo "Found your birthday item!"
    fi
done

echo "Total items: ${#items[@]}"
echo "Your personalised checksum: $((STUDENT_ID % 97))"
```

**Tasks:**
1. Fill in YOUR actual student ID and birthdate
2. Identify the 3 bugs
3. Explain WHY each is a bug
4. Fix each bug
5. Run the script and paste your personalised output

**Expected submission format:**
```
Student ID: [your ID]
Birthdate: [DD/MM]

Bug 1: [description]
  - Why it's wrong: [explanation]
  - Fix: [corrected line]

Bug 2: [description]
  - Why it's wrong: [explanation]  
  - Fix: [corrected line]

Bug 3: [description]
  - Why it's wrong: [explanation]
  - Fix: [corrected line]

My output:
[paste your terminal output here]
```

**Why this works against AI:**
- Each student has unique parameters → unique array sizes, unique indices
- AI cannot predict "your" output without knowing your student ID
- The bugs interact with personal data, so fixes must be context-aware
- Checksum at the end verifies you actually ran the code

---

### E7.2: Config File with Your Initials

Create a configuration manager that uses YOUR initials and student ID:

```bash
#!/bin/bash
set -euo pipefail

# ═══════════════════════════════════════════════════════════════════
# PERSONALISATION REQUIRED
# ═══════════════════════════════════════════════════════════════════

YOUR_INITIALS="[FIRST_LAST_INITIALS]"    # e.g., "AC" for Antonio Clim
STUDENT_ID="[YOUR_STUDENT_ID]"

# Config file path uses your initials
CONFIG_FILE="/tmp/${YOUR_INITIALS}_${STUDENT_ID}.conf"

# ═══════════════════════════════════════════════════════════════════
# IMPLEMENT THESE FUNCTIONS
# ═══════════════════════════════════════════════════════════════════

# Function 1: Create config with YOUR data as defaults
init_config() {
    # TODO: Create CONFIG_FILE with these keys:
    # OWNER=[your initials]
    # ID=[your student ID]
    # CREATED=[current timestamp]
    # CUSTOM_PORT=[last 4 digits of student ID]
    :  # Replace with your implementation
}

# Function 2: Get a value (return via echo)
get_config() {
    local key="$1"
    # TODO: Return value for given key from CONFIG_FILE
    :  # Replace with your implementation
}

# Function 3: Set a value
set_config() {
    local key="$1"
    local value="$2"
    # TODO: Update or add key=value in CONFIG_FILE
    :  # Replace with your implementation
}

# ═══════════════════════════════════════════════════════════════════
# TEST SEQUENCE (do not modify)
# ═══════════════════════════════════════════════════════════════════

echo "=== Personalised Config Manager Test ==="
echo "Student: ${YOUR_INITIALS} (${STUDENT_ID})"
echo ""

init_config
echo "1. Config created at: $CONFIG_FILE"

echo "2. Owner is: $(get_config OWNER)"
echo "3. Custom port is: $(get_config CUSTOM_PORT)"

set_config "MODIFIED_BY" "${YOUR_INITIALS}"
set_config "TIMESTAMP" "$(date +%s)"

echo "4. Full config contents:"
cat "$CONFIG_FILE"

echo ""
echo "5. Verification hash: $(md5sum "$CONFIG_FILE" | cut -d' ' -f1)"
```

**Why this works against AI:**
- Config file path is unique to each student
- Output includes your initials and ID — easy to verify authenticity
- MD5 hash at end proves the script ran with YOUR specific data
- Functions must handle YOUR specific data structure

---

## Exercise Type 1: EXPLAIN CODE

### E1.1: Explain the Function

Code to analyse:
```bash
process() {
    local -n ref=$1
    local count=0
    for item in "${ref[@]}"; do
        [[ "$item" =~ ^[0-9]+$ ]] && ((count++))
    done
    echo $count
}
```

Questions:
1. What does `local -n ref=$1` do? (2p)
2. What does the regex `^[0-9]+$` check? (2p)
3. What is the purpose of the `count` variable? (1p)
4. Why do we use `local` for both variables? (2p)
5. What does the function return and how? (2p)
6. Write an example function call with output. (1p)

<details>
<summary>📋 Expected Answers</summary>

1. `local -n ref=$1` - Creates a reference (nameref) to the array whose name is passed as $1. Allows the function to work with the original array through an alias.

2. `^[0-9]+$` - Checks if the string contains ONLY digits (from beginning ^ to end $, one or more +).

3. `count` - Counts how many elements in the array are pure numbers (only digits).

4. `local` - Prevents modifying global variables; `ref` and `count` exist only in the function's scope.

5. Returns the number of numeric elements through `echo`. Capture: `result=$(process arr_name)`

6. Example:
```bash
arr=("hello" "42" "world" "123" "7")
process arr    # Output: 3
```

</details>

---

### E1.2: Explain the Pattern

Code to analyse:
```bash
: "${API_KEY:?Error: API_KEY must be set}"
: "${DB_HOST:?Error: DB_HOST must be set}"
: "${OPTIONAL_VAR:=default_value}"
```

Questions:
1. What does the `:` (colon) command do? (1p)
2. What difference is there between `:?` and `:=`? (3p)
3. What happens if API_KEY is not set? (2p)
4. What happens if OPTIONAL_VAR is not set? (2p)
5. Why is this pattern useful with `set -u`? (2p)

<details>
<summary>📋 Expected Answers</summary>

1. `:` - Null/no-op command. Does nothing but evaluates arguments. Exit code always 0.

2. `:?` - If the variable is unset/empty, displays the error message and TERMINATES the script.
   `:=` - If the variable is unset/empty, SETS it to the given value and continues.

3. API_KEY unset - Script stops with the message "Error: API_KEY must be set"

4. OPTIONAL_VAR unset - Gets automatically set to "default_value" and the script continues

5. With `set -u` - Without these patterns, any reference to unset variables would cause an error. This pattern allows checking/setting BEFORE use.

</details>

---

## Exercise Type 2: PREDICT OUTPUT

### E2.1: Arrays and Iteration

```bash
#!/bin/bash
arr=("one two" "three")

echo "Test 1:"
for i in ${arr[@]}; do echo "- $i"; done

echo "Test 2:"
for i in "${arr[@]}"; do echo "- $i"; done

echo "Test 3:"
echo "Count: ${#arr[@]}"
```

What does this script display?

<details>
<summary>📋 Correct Output</summary>

```
Test 1:
- one
- two
- three
Test 2:
- one two
- three
Test 3:
Count: 2
```

Explanation:
- Test 1: Without quotes → word splitting → "one two" becomes 2 elements
- Test 2: With quotes → elements remain intact
- Test 3: The array has 2 elements (not 3!)

</details>

---

### E2.2: set -e and Conditions

```bash
#!/bin/bash
set -e

check() {
    false
    echo "In check"
}

echo "Start"

if check; then
    echo "Check passed"
else
    echo "Check failed"
fi

echo "End"
```

Predictions:
1. What lines are displayed?
2. Why?

<details>
<summary>📋 Correct Output</summary>

```
Start
In check
Check passed
End
```

Explanation:
- `set -e` does NOT work in test context (if)
- `false` in function does NOT stop the script
- `echo "In check"` IS executed
- The function returns 0 (from echo), but... 
- Trap: The function returns the last exit code, which is 0 from echo
- So check "passes"!

Correction: If we want check to fail:
```bash
check() {
    false
    # no echo after false
}
# OR
check() {
    return 1
}
```

</details>

---

### E2.3: Local and Global Variables

```bash
#!/bin/bash

x=10

modify() {
    x=20
    local y=30
    echo "In function: x=$x, y=$y"
}

echo "Before: x=$x"
modify
echo "After: x=$x, y=${y:-unset}"
```

What does it display?

<details>
<summary>📋 Correct Output</summary>

```
Before: x=10
In function: x=20, y=30
After: x=20, y=unset
```

Explanation:
- `x` is global → the modification from the function persists
- `y` is local → does not exist outside the function
- `${y:-unset}` → displays "unset" because y is not defined

</details>

---

## Exercise Type 3: DEBUG & FIX

### E3.1: Find 5 Bugs

```bash
#!/bin/bash

# Script for processing files
FILES=$(ls *.txt)

config[input]="data"
config[output]="results"

process() {
    count=0
    for file in $FILES; do
        count=$count+1
        echo "Processing $file"
    done
    return $count
}

result=process
echo "Processed $result files"
```

Identify and correct all the bugs:

<details>
<summary>📋 Bugs and Corrections</summary>

Bug 1: Missing `set -euo pipefail`
```bash
# Add at the beginning:
set -euo pipefail
```

Bug 2: `FILES=$(ls *.txt)` - Does not work with spaces in names
```bash
# Correct:
FILES=(*.txt)
# or
mapfile -t FILES < <(find . -name "*.txt")
```

Bug 3: `config` without `declare -A`
```bash
# Correct:
declare -A config
config[input]="data"
config[output]="results"
```

Bug 4: `count=$count+1` - string concatenation, not arithmetic
```bash
# Correct:
((count++))
# or
count=$((count + 1))
```

Bug 5: `result=process` - does not call the function
```bash
# Correct:
result=$(process)
```

Bug 6 (bonus): `return $count` - count can be > 255
```bash
# Correct: use echo for large values
echo $count
# and capture with $(...)
```

Corrected version:
```bash
#!/bin/bash
set -euo pipefail

FILES=(*.txt)

declare -A config
config[input]="data"
config[output]="results"

process() {
    local count=0
    for file in "${FILES[@]}"; do
        ((count++))
        echo "Processing $file" >&2
    done
    echo $count
}

result=$(process)
echo "Processed $result files"
```

</details>

---

### E3.2: Why Doesn't It Work?

Situation: Student reports that the script "does nothing":

```bash
#!/bin/bash
set -euo pipefail

echo "Starting backup..."
cd /backup/location
tar -czf backup.tar.gz /home/user/documents
echo "Backup complete!"
```

Running:
```bash
$ ./backup.sh
Starting backup...
$
```

Questions:
1. Why doesn't "Backup complete!" appear? (2p)
2. Why doesn't any error appear? (2p)
3. How would you diagnose the problem? (3p)
4. How would you fix the script? (3p)

<details>
<summary>📋 Answers</summary>

1. Why it doesn't appear: `cd /backup/location` probably fails (directory doesn't exist). With `set -e` the script stops immediately.

2. Why no error appears: `cd` fails SILENTLY (only returns exit code ≠ 0). `set -e` stops the script but doesn't display why.

3. Diagnosis:
   ```bash
   # Add debug
   set -x
   
   # Or check explicitly
   cd /backup/location || echo "cd failed!"
   
   # Or check existence
   ls -la /backup/location
   ```

4. Fix:
   ```bash
   #!/bin/bash
   set -euo pipefail
   
   BACKUP_DIR="/backup/location"
   
   echo "Starting backup..."
   
   [[ -d "$BACKUP_DIR" ]] || {
       echo "Error: $BACKUP_DIR does not exist" >&2
       exit 1
   }
   
   cd "$BACKUP_DIR"
   tar -czf backup.tar.gz /home/user/documents
   echo "Backup complete!"
   ```

</details>

---

## Exercise Type 4: CODE REVIEW

### E4.1: Critique This Script

```bash
#!/bin/bash

# Process all log files
for f in `ls /var/log/*.log`
do
cat $f | grep ERROR | wc -l > /tmp/count
count=`cat /tmp/count`
echo "$f: $count errors"
rm /tmp/count
done
```

Requirement: 
Identify at least 7 style/reliability problems and rewrite the script according to best practices.

<details>
<summary>📋 Complete Review</summary>

Problems identified:

1. Missing `set -euo pipefail`
2. Backticks instead of `$(...)` (deprecated)
3. `ls` in loop - problems with spaces
4. `$f` without quotes
5. UUOC (Useless Use of Cat)
6. Hardcoded temporary file - race condition
7. Does not use `local` (if it were in a function)
8. Does not clean up if script fails
9. Does not check if .log files exist

Refactored version:

```bash
#!/bin/bash
set -euo pipefail

readonly LOG_DIR="/var/log"

# Check that files exist
shopt -s nullglob
log_files=("$LOG_DIR"/*.log)
shopt -u nullglob

if [[ ${#log_files[@]} -eq 0 ]]; then
    echo "No log files found in $LOG_DIR" >&2
    exit 0
fi

for log_file in "${log_files[@]}"; do
    count=$(grep -c "ERROR" "$log_file" 2>/dev/null || echo 0)
    echo "$log_file: $count errors"
done
```

Improvements:
- Strict mode
- Glob expansion instead of ls
- Correct quoting
- grep -c instead of wc -l
- Handle for 0 matches
- No temporary files
- Check file existence

</details>

---

## Exercise Type 5: TRACE EXECUTION

### E5.1: Trace the Execution

```bash
#!/bin/bash
set -euo pipefail

arr=(10 20 30)
sum=0

for ((i=0; i<${#arr[@]}; i++)); do
    sum=$((sum + arr[i]))
done

echo "Sum: $sum"
```

Complete the trace table:

| Step | i | arr[i] | sum (before) | sum (after) |
|------|---|--------|--------------|-------------|
| Init | - | - | - | 0 |
| 1 | | | | |
| 2 | | | | |
| 3 | | | | |
| End | | | | |

<details>
<summary>📋 Complete Trace</summary>

| Step | i | arr[i] | sum (before) | sum (after) |
|------|---|--------|--------------|-------------|
| Init | - | - | - | 0 |
| 1 | 0 | 10 | 0 | 10 |
| 2 | 1 | 20 | 10 | 30 |
| 3 | 2 | 30 | 30 | 60 |
| End | 3 | - | 60 | 60 |

Output: `Sum: 60`

</details>

---

### E5.2: Trace with Functions

```bash
#!/bin/bash

outer() {
    local x=1
    echo "outer start: x=$x"
    inner
    echo "outer end: x=$x"
}

inner() {
    local x=2
    echo "inner: x=$x"
}

x=0
echo "main start: x=$x"
outer
echo "main end: x=$x"
```

Questions:
1. Draw the call stack at the moment when we are in `inner`
2. What value does `x` have at each `echo`?

<details>
<summary>📋 Solution</summary>

Call Stack (in inner):
```
┌─────────────┐
│   inner     │  x=2 (local)
├─────────────┤
│   outer     │  x=1 (local)
├─────────────┤
│   main      │  x=0 (global)
└─────────────┘
```

Complete output:
```
main start: x=0
outer start: x=1
inner: x=2
outer end: x=1
main end: x=0
```

Explanation: Each function has its own local `x`, which "shadows" the one from the higher scope.

</details>

---

## Exercise Type 6: APPLICATION IN NEW CONTEXT

### E6.1: Template Adaptation

Given: The standard professional template (from the kit).

Requirement: Adapt the template for a script that:
- Receives a list of URLs (from file or stdin)
- Checks each URL with `curl --head`
- Reports the status (UP/DOWN)
- Saves results to a file

Evaluation:
- Correct use of template structure (3p)
- Argument parsing for input file (2p)
- Handling stdin vs file (2p)
- Cleanup of temporary resources (1p)
- Error handling for curl (2p)

---

## Home Exercise with LLM

### E7.1: Collaboration with AI (Assignment)

Instructions:
1. Use ChatGPT/Claude to generate a script that processes CSV
2. Document EXACTLY what prompts you used
3. Analyse the generated code - identify what the AI did well, what it did wrong or suboptimally and what you modified (with reasons)
4. Write your final version with explanatory comments

Evaluation criteria:
- Process transparency (3p)
- Quality of critical analysis (4p)
- Improvements made (3p)

Submission format:
```
## Prompts used
[...]

## AI-generated code
[...]

## My analysis
### What it did well:
### What it did wrong:
### What I modified:

## My final version
[code with comments]
```

---

### E7.3: Your Unique Hash Chain (Advanced)

> ⚠️ **Maximum AI Resistance:** This exercise creates a verification chain that is mathematically unique to you.

Create a script that generates a personalised verification code:

```bash
#!/bin/bash
set -euo pipefail

# ═══════════════════════════════════════════════════════════════════
# PERSONALISATION REQUIRED — Use YOUR actual data
# ═══════════════════════════════════════════════════════════════════

STUDENT_ID="[YOUR_8_DIGIT_ID]"           # e.g., "12345678"
BIRTH_MONTH="[YOUR_BIRTH_MONTH_01-12]"   # e.g., "03"
YOUR_INITIALS="[FIRST_LAST]"             # e.g., "AC" for Antonio Clim

# ═══════════════════════════════════════════════════════════════════
# HASH CHAIN GENERATION — Do not modify this section
# ═══════════════════════════════════════════════════════════════════

echo "=== Personalised Verification Chain ==="
echo "Student: $YOUR_INITIALS ($STUDENT_ID)"
echo ""

# Step 1: Hash your student ID
STEP1=$(echo -n "$STUDENT_ID" | md5sum | cut -c1-8)
echo "Step 1 (ID hash):        $STEP1"

# Step 2: Combine with birth month and hash again
STEP2=$(echo -n "${STEP1}${BIRTH_MONTH}" | sha256sum | cut -c1-8)
echo "Step 2 (+ month hash):   $STEP2"

# Step 3: Add initials and encode
STEP3=$(echo -n "${STEP2}${YOUR_INITIALS}" | base64 | head -c12)
echo "Step 3 (+ initials b64): $STEP3"

# Final verification code
FINAL_CODE="${YOUR_INITIALS}-${STEP3}-$(echo -n "$STEP1$STEP2" | md5sum | cut -c1-4)"
echo ""
echo "════════════════════════════════════════"
echo "YOUR VERIFICATION CODE: $FINAL_CODE"
echo "════════════════════════════════════════"
echo ""
echo "This code MUST appear in your submission."
echo "Instructor can verify by re-running with your data."
```

**Why this defeats AI:**
- The hash chain depends on YOUR specific personal data
- Intermediate values are cryptographically unpredictable
- AI cannot guess what your verification code will be
- Instructor can verify authenticity by re-running with your student ID
- Changing any input value produces a completely different code

**Submission requirement:**
Your homework README must include:
```
## Verification Code
FINAL_CODE: [paste your code here]
Generated on: [date and time]
```

---

## Real Student Submission Analysis (Anonymised)

> *These are real patterns I observed while grading 2023-2024 submissions. Names changed, code paraphrased, lessons preserved.*

### Case Study A: The "Too Perfect" Submission

**Red flags noticed during initial review:**
- Zero shellcheck warnings (unusual for beginners)
- Consistent 4-space indentation throughout (our labs use tabs)
- Comments in perfect academic English
- Used `mapfile` (not taught until S06)

**During oral defence:**
```
Me: "Walk me through the parse_line function."
Student: "It... parses the line."
Me: "How does the regex work?"
Student: "I think it uses... BASH_REMATCH?"
Me: "What does the ^ character mean in the pattern?"
Student: [long pause] "Beginning of... something?"
```

**Outcome:** Referred to academic integrity committee. Admitted to copying from ChatGPT "to save time."

### Case Study B: The Authentic Struggler

**Initial impression:**
- Several shellcheck warnings (SC2086, SC2034)
- Inconsistent spacing (mixed tabs/spaces)
- Variable named `numar_linii` (Romanian habit)
- Creative workaround for something that could be done simpler

**During oral defence:**
```
Me: "Why did you use a while loop here instead of a for loop?"
Student: "I tried for first, but it didn't work with files 
         that have spaces. I found on Stack Overflow that 
         while-read is safer, but I'm not 100% sure why."
Me: "Can you add a --quiet flag right now?"
Student: [types for 90 seconds] "Like this? I added a variable 
         and an if before each echo."
```

**Outcome:** Full marks minus shellcheck penalties. Clearly understood their own code.

### Key Differentiators

| Indicator | Likely AI-Generated | Likely Authentic |
|-----------|---------------------|------------------|
| **Shellcheck** | Zero warnings | Some warnings (learning!) |
| **Style** | Perfect consistency | Natural variation |
| **Comments** | Formal, complete | Informal, sometimes missing |
| **Variables** | Professional naming | Sometimes Romanian/personal |
| **Explanation** | Vague, reads code aloud | Specific, describes intent |
| **Modification** | Struggles or refuses | Attempts, asks clarifying Q's |

---

## Instructor Guide

### Integration into Assessment

| Exercise Type | Recommended Weight | Assessment Mode |
|---------------|--------------------|-----------------|
| Explain Code | 25% | Oral or written |
| Predict Output | 20% | Quiz, exam |
| Debug & Fix | 20% | Practical |
| Code Review | 15% | Peer review |
| Trace Execution | 10% | Written |
| Transfer | 10% | Project |

### Detecting AI Usage — Expanded Checklist

**Code-level signals:**
- Perfect shellcheck compliance (beginners make mistakes)
- Features not yet taught (check syllabus progression)
- Unusual constructs for the task (over-engineering)
- Comment style mismatch with student's verbal English level

**Behavioural signals during viva:**
- Reads code aloud without insight
- Cannot explain regex patterns they "wrote"
- Uses technical terms incorrectly
- Defensive when asked about specific lines
- "I found it online" for core logic

**Structural signals:**
- Perfect parallel structure in functions
- Identical error message formatting throughout
- No dead code or commented experiments
- README matches code style exactly

### Recommended Response Protocol

1. **Document observations** — specific lines, specific behaviours
2. **Ask increasingly specific questions** — not accusations
3. **Request live modification** — authentic students adapt; copiers freeze
4. **Compare with in-class work** — dramatic skill difference is a signal
5. **Consult colleagues** — get second opinion before escalating

---

## Document History

| Version | Date | Changes |
|---------|------|---------|
| 2.1.0 | Jan 2025 | Added E7.3 hash chain, real student case studies |
| 2.0.0 | Jan 2025 | Complete rewrite for AI era |
| 1.0.0 | Sep 2023 | Initial version |

---

## Support

Questions: Course forum or office hours  
Issues with materials: antonio.clim@csie.ase.ro

---

*Laboratory material for the Operating Systems course | ASE Bucharest — CSIE*  
*Maintained by: ing. dr. Antonio Clim*
