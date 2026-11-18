# Parsons Problems - Seminar 02
## Operating Systems | Operators, Redirection, Filters, Loops

Total problems: 17 (12 standard + 5 Bash-specific)  
Time per problem: 3-5 minutes  
Format: Individual or pairs

---

## WHAT ARE PARSONS PROBLEMS?

Parsons Problems are exercises where you receive shuffled lines of code and must arrange them in the correct order to create a functional programme.

### Cognitive Benefits

1. Reduces cognitive load - no need to write code from scratch
2. Focuses on structure - understand programme logic
3. Avoids syntax blockage - elements are already correct
4. Identifies distractors - learn to recognise incorrect code

### How to Approach a Parsons Problem

```
1. READ the objective - what should the code do?
2. IDENTIFY key elements - what do you recognise?
3. FIND the start - what should be the first line?
4. BUILD sequentially - step by step
5. CHECK distractors - which line is extra or wrong?
6. TEST mentally - trace through execution
```

---

## CONTROL OPERATORS PROBLEMS

### PP-01: Conditional Backup
Level: ⭐ Easy | Time: 3 min | Mode: Individual

Run in a new owned exercise directory containing `data.txt`; `backup/` need not exist. The source check and copy/creation failures have distinct messages. Arrange all five required lines below. The alternative `cp data.txt backup/; echo "Backup created successfully"` is syntactically valid but does not meet the failure-handling contract.

```text
    printf 'File not found\n' >&2; exit 1
fi
    mkdir -p backup && cp -- data.txt backup/ && printf 'Backup created successfully\n' || { printf 'Backup failed\n' >&2; exit 1; }
if [ -f data.txt ]; then
else
```

There are **five physical lines**, including the compound command line; the order of independent actions is not artificially constrained.

✅ CORRECT SOLUTION:
```bash
if [ -f data.txt ]; then
    mkdir -p backup && cp -- data.txt backup/ && printf 'Backup created successfully\n' || { printf 'Backup failed\n' >&2; exit 1; }
else
    printf 'File not found\n' >&2; exit 1
fi
```

`mkdir -p backup` is required in a fresh directory. It is not a distractor. The success branch runs only after the copy succeeds; a real script may use nested `if` statements when the success/reporting action can itself fail.

---

### PP-02: Build Process
Level: ⭐⭐ Medium | Time: 4 min | Mode: Pairs

```
╔══════════════════════════════════════════════════════════════════════╗
║  🎯 OBJECTIVE: Simulate a build process with dependent steps         ║
║                                                                      ║
║  BEHAVIOUR: Each step runs ONLY if previous succeeds                 ║
║  Steps: Compile → Test → Deploy → Notification                       ║
╠══════════════════════════════════════════════════════════════════════╣
║                                                                      ║
║  SHUFFLED LINES (one is DISTRACTOR):                                ║
║  ────────────────────────────────────────────────────────────────   ║
║     && echo "3. Deploying to production..."                         ║
║     && echo "4. ✓ Build complete!"                                  ║
║     echo "1. Compiling..."                                          ║
║     && echo "2. Running tests..."                                   ║
║     || echo "✗ Build failed!"                                       ║
║     ; echo "Process has been initiated"        ← DISTRACTOR         ║
║  ────────────────────────────────────────────────────────────────   ║
║                                                                      ║
╚══════════════════════════════════════════════════════════════════════╝
```

✅ CORRECT SOLUTION:
```bash
echo "1. Compiling..." && echo "2. Running tests..." && echo "3. Deploying to production..." && echo "4. ✓ Build complete!" || echo "✗ Build failed!"
```

Distractor explanation: `; echo "Process has been initiated"` uses `;` which executes regardless of result - not part of the `&&` dependency chain.

---

### PP-03: Job Management
Level: ⭐⭐ Medium | Time: 4 min | Mode: Individual

```
╔══════════════════════════════════════════════════════════════════════╗
║  🎯 OBJECTIVE: Start 3 tasks in background and wait for them         ║
║                                                                      ║
║  BEHAVIOUR:                                                          ║
║  - Start 3 sleeps in parallel (background)                          ║
║  - Display "Waiting..." after all have started                       ║
║  - Wait for all to complete                                         ║
║  - Display "All complete!"                                          ║
╠══════════════════════════════════════════════════════════════════════╣
║                                                                      ║
║  SHUFFLED LINES (one is DISTRACTOR):                                ║
║  ────────────────────────────────────────────────────────────────   ║
║     echo "All complete!"                                            ║
║     sleep 2 &                                                       ║
║     sleep 3 &                                                       ║
║     wait                                                            ║
║     echo "Waiting for completion..."                                ║
║     sleep 1 &                                                       ║
║     fg                                    ← DISTRACTOR              ║
║  ────────────────────────────────────────────────────────────────   ║
║                                                                      ║
╚══════════════════════════════════════════════════════════════════════╝
```

✅ CORRECT SOLUTION:
```bash
sleep 1 &
sleep 2 &
sleep 3 &
echo "Waiting for completion..."
wait
echo "All complete!"
```

Distractor explanation: `fg` brings ONE job to foreground (blocking), but we want to wait for ALL jobs simultaneously with `wait`.

---

## REDIRECTION PROBLEMS

### PP-04: Output Separator
Level: ⭐⭐ Medium | Time: 4 min | Mode: Pairs

```
╔══════════════════════════════════════════════════════════════════════╗
║  🎯 OBJECTIVE: Separate stdout and stderr into different files       ║
║                                                                      ║
║  BEHAVIOUR:                                                          ║
║  - Run: ls /home /nonexistent                                       ║
║  - stdout → success.log                                             ║
║  - stderr → errors.log                                              ║
║  - Display "Processing complete" at the end                         ║
╠══════════════════════════════════════════════════════════════════════╣
║                                                                      ║
║  SHUFFLED LINES (one is DISTRACTOR):                                ║
║  ────────────────────────────────────────────────────────────────   ║
║     2> errors.log                                                   ║
║     echo "Processing complete"                                      ║
║     > success.log                                                   ║
║     ls /home /nonexistent                                           ║
║     &> combined.log                      ← DISTRACTOR               ║
║  ────────────────────────────────────────────────────────────────   ║
║                                                                      ║
╚══════════════════════════════════════════════════════════════════════╝
```

✅ CORRECT SOLUTION:
```bash
ls /home /nonexistent > success.log 2> errors.log
echo "Processing complete"
```

Distractor explanation: `&> combined.log` would send BOTH streams to the same file - not what we want.

---

### PP-05: Here Document
Level: ⭐⭐ Medium | Time: 5 min | Mode: Individual

```
╔══════════════════════════════════════════════════════════════════════╗
║  🎯 OBJECTIVE: Create a config file using here document             ║
║                                                                      ║
║  BEHAVIOUR:                                                          ║
║  - Create file config.txt with 3 lines of configuration             ║
║  - Use here document (<<)                                           ║
║  - Display "Config created" when done                                ║
╠══════════════════════════════════════════════════════════════════════╣
║                                                                      ║
║  SHUFFLED LINES (one is DISTRACTOR):                                ║
║  ────────────────────────────────────────────────────────────────   ║
║     cat > config.txt << EOF                                         ║
║     DEBUG=false                                                     ║
║     SERVER=localhost                                                ║
║     PORT=8080                                                       ║
║     EOF                                                             ║
║     echo "Config created"                                           ║
║     cat > config.txt < EOF              ← DISTRACTOR                ║
║  ────────────────────────────────────────────────────────────────   ║
║                                                                      ║
╚══════════════════════════════════════════════════════════════════════╝
```

✅ CORRECT SOLUTION:
```bash
cat > config.txt << EOF
SERVER=localhost
PORT=8080
DEBUG=false
EOF
echo "Config created"
```

Distractor explanation: `< EOF` is input redirection from a file named EOF, not a here document. Here documents use `<<`.

---

### PP-06: Tee Pipeline

Fixture: `input/` contains only the regular files to count; names contain no newline. Write `list.txt` outside `input/`, so tee cannot change the population being listed. This is an entry-count exercise, not a general filename serialisation method.
Level: ⭐⭐⭐ Advanced | Time: 5 min | Mode: Pairs

```
╔══════════════════════════════════════════════════════════════════════╗
║  🎯 OBJECTIVE: Log pipeline while continuing to process             ║
║                                                                      ║
║  BEHAVIOUR:                                                          ║
║  - List files, save to list.txt AND continue pipeline               ║
║  - Count the files                                                   ║
║  - Display total with message                                        ║
╠══════════════════════════════════════════════════════════════════════╣
║                                                                      ║
║  SHUFFLED LINES (one is DISTRACTOR):                                ║
║  ────────────────────────────────────────────────────────────────   ║
║     ls -1 input/                                                           ║
║     | tee list.txt                                                  ║
║     | wc -l                                                         ║
║     | xargs echo "Total files:"                                     ║
║     > list.txt | wc -l                   ← DISTRACTOR               ║
║  ────────────────────────────────────────────────────────────────   ║
║                                                                      ║
╚══════════════════════════════════════════════════════════════════════╝
```

✅ CORRECT SOLUTION:
```bash
ls -1 input/ | tee list.txt | wc -l | xargs echo "Total files:"
```

Distractor explanation: `> list.txt | wc -l` redirects to file but the pipe receives nothing (redirection consumes the output). `tee` duplicates the stream.

---

## FILTER PROBLEMS

### PP-07: Sort and Count
Level: ⭐⭐ Medium | Time: 4 min | Mode: Individual

```
╔══════════════════════════════════════════════════════════════════════╗
║  🎯 OBJECTIVE: Find most frequent words in a file                    ║
║                                                                      ║
║  BEHAVIOUR:                                                          ║
║  - Read words.txt (one word per line)                               ║
║  - Count unique words                                                ║
║  - Show top 5 most frequent                                         ║
║                                                                      ║
║  ⚠️ Remember: uniq only removes CONSECUTIVE duplicates!             ║
╠══════════════════════════════════════════════════════════════════════╣
║                                                                      ║
║  SHUFFLED LINES (one is DISTRACTOR):                                ║
║  ────────────────────────────────────────────────────────────────   ║
║     cat words.txt                                                   ║
║     | sort                                                          ║
║     | uniq -c                                                       ║
║     | sort -rn                                                      ║
║     | head -5                                                       ║
║     | uniq -c | sort                     ← DISTRACTOR               ║
║  ────────────────────────────────────────────────────────────────   ║
║                                                                      ║
╚══════════════════════════════════════════════════════════════════════╝
```

✅ CORRECT SOLUTION:
```bash
cat words.txt | sort | uniq -c | sort -rn | head -5
```

Distractor explanation: `| uniq -c | sort` has the wrong order - you MUST sort BEFORE uniq, otherwise uniq only removes consecutive duplicates!

---

### PP-08: Log Analysis Pipeline

Input contract: this synthetic format has exactly eight whitespace-separated fields, no timezone field and no HTTP-version token. Status is field 7. A path or byte count containing `404` is not a 404 response.
Level: ⭐⭐⭐ Advanced | Time: 5 min | Mode: Pairs

```
╔══════════════════════════════════════════════════════════════════════╗
║  🎯 OBJECTIVE: Find top 3 IPs with 404 errors from access.log       ║
║                                                                      ║
║  Log format: IP - - [date] "request" STATUS size                    ║
║  Example: 192.168.1.1 - - [01/Jan] "GET /page" 404 1234            ║
╠══════════════════════════════════════════════════════════════════════╣
║                                                                      ║
║  SHUFFLED LINES (two are DISTRACTORS):                              ║
║  ────────────────────────────────────────────────────────────────   ║
║     awk 'NF == 8 && $7 == 404' access.log                                           ║
║     | cut -d' ' -f1                                                 ║
║     | sort                                                          ║
║     | uniq -c                                                       ║
║     | sort -rn                                                      ║
║     | head -3                                                       ║
║     | cut -f1                             ← DISTRACTOR              ║
║     | uniq -c | sort -rn                  ← DISTRACTOR              ║
║  ────────────────────────────────────────────────────────────────   ║
║                                                                      ║
╚══════════════════════════════════════════════════════════════════════╝
```

✅ CORRECT SOLUTION:
```bash
awk 'NF == 8 && $7 == 404' access.log | cut -d' ' -f1 | sort | uniq -c | sort -rn | head -3
```

Distractor explanations:
- `| cut -f1` - without `-d' '` uses TAB as delimiter (wrong for this log format)
- `| uniq -c | sort -rn` - missing initial sort! uniq needs sorted input

---

## LOOP PROBLEMS

### PP-09: File Renamer
Level: ⭐⭐ Medium | Time: 4 min | Mode: Individual

Use an owned fixture directory. Preserve an existing `.backup` target and report only successful renames. `nullglob` makes an empty set a no-op; only regular files are selected.

```
╔══════════════════════════════════════════════════════════════════════╗
║  🎯 OBJECTIVE: Rename all .txt files to .txt.backup                 ║
║                                                                      ║
║  BEHAVIOUR:                                                          ║
║  - For each .txt file in current directory                          ║
║  - Rename to filename.txt.backup                                    ║
║  - Display what was renamed                                          ║
╠══════════════════════════════════════════════════════════════════════╣
║                                                                      ║
║  SHUFFLED LINES (one is DISTRACTOR):                                ║
║  ────────────────────────────────────────────────────────────────   ║
║     shopt -s nullglob
║     [[ -f $file ]] || continue
║     [[ ! -e ${file}.backup && ! -L ${file}.backup ]] || exit 2
║     for file in *.txt; do                                           ║
║     done                                                            ║
║     mv -- "$file" "${file}.backup" || exit 1                                     ║
║     echo "Renamed: $file → ${file}.backup"                          ║
║     for file in *.txt                     ← DISTRACTOR              ║
║  ────────────────────────────────────────────────────────────────   ║
║                                                                      ║
╚══════════════════════════════════════════════════════════════════════╝
```

✅ CORRECT SOLUTION:
```bash
shopt -s nullglob
for file in *.txt; do
    [[ -f $file ]] || continue
    [[ ! -e ${file}.backup && ! -L ${file}.backup ]] || { printf 'Collision: %s\n' "${file}.backup" >&2; exit 2; }
    mv -- "$file" "${file}.backup" || exit 1
    echo "Renamed: $file → ${file}.backup"
done
```

Distractor explanation: `for file in *.txt` without `; do` at the end is incomplete syntax.

---

### PP-10: Countdown

For this ordering exercise, enter a decimal integer from 0 to 99 with no leading zero except `0`. Input validation is a separate extension: `[[ $N =~ ^(0|[1-9][0-9]?)$ ]] || exit 1`. The countdown includes zero.
Level: ⭐⭐ Medium | Time: 4 min | Mode: Pairs

```
╔══════════════════════════════════════════════════════════════════════╗
║  🎯 OBJECTIVE: Countdown from N to 0, then display "START!"         ║
║                                                                      ║
║  BEHAVIOUR:                                                          ║
║  - Read N from user                                                  ║
║  - Count down from N to 0                                           ║
║  - 1 second pause between numbers                                    ║
║  - At the end display "START!"                                       ║
╠══════════════════════════════════════════════════════════════════════╣
║                                                                      ║
║  SHUFFLED LINES (two are DISTRACTORS):                              ║
║  ────────────────────────────────────────────────────────────────   ║
║     read -p "Enter N: " N                                           ║
║     echo "START!"                                                   ║
║     done                                                            ║
║     sleep 1                                                         ║
║     for ((i=N; i>=0; i--)); do                                      ║
║     echo $i                                                         ║
║     for i in {N..1}; do                   ← DISTRACTOR              ║
║     for i in {$N..1}; do                  ← DISTRACTOR              ║
║  ────────────────────────────────────────────────────────────────   ║
║                                                                      ║
╚══════════════════════════════════════════════════════════════════════╝
```

✅ CORRECT SOLUTION:
```bash
read -p "Enter N: " N
for ((i=N; i>=0; i--)); do
    echo $i
    sleep 1
done
echo "START!"
```

Distractor explanations:
- `for i in {N..1}; do` - N literal, not variable
- `for i in {$N..1}; do` - brace expansion does NOT work with variables!

---

### PP-11: File Reading with Counter
Level: ⭐⭐⭐ Advanced | Time: 5 min | Mode: Individual

```
╔══════════════════════════════════════════════════════════════════════╗
║  🎯 OBJECTIVE: Count non-empty lines in a file                       ║
║                                                                      ║
║  BEHAVIOUR:                                                          ║
║  - Read file line by line                                           ║
║  - Skip empty lines                                                  ║
║  - Count lines with content                                          ║
║  - Display total at the end                                          ║
║                                                                      ║
║  ⚠️ Trap: Variable must persist after loop!                          ║
╠══════════════════════════════════════════════════════════════════════╣
║                                                                      ║
║  SHUFFLED LINES (one is DISTRACTOR):                                ║
║  ────────────────────────────────────────────────────────────────   ║
║     done < file.txt                                                 ║
║     [ -z "$line" ] && continue                                      ║
║     count=0                                                         ║
║     count=$((count + 1))                                                     ║
║     while IFS= read -r line; do                                     ║
║     echo "Total non-empty lines: $count"                            ║
║     cat file.txt | while read line; do  ← DISTRACTOR                ║
║  ────────────────────────────────────────────────────────────────   ║
║                                                                      ║
╚══════════════════════════════════════════════════════════════════════╝
```

✅ CORRECT SOLUTION:
```bash
count=0
while IFS= read -r line; do
    [ -z "$line" ] && continue
    count=$((count + 1))
done < file.txt
echo "Total non-empty lines: $count"
```

Distractor explanation: with Bash `lastpipe` disabled (the assumed default here), the pipeline loop runs in a subshell and its `count` changes do not reach the parent. Use newline-terminated input for this item; the separate unterminated-final-line extension is `read -r line || [[ -n $line ]]`.

---

### PP-12: Complete Script - System Monitor

Choose one of the two equivalent infinite-loop headers; `exit 0` is the only line incompatible with continued monitoring.
Level: ⭐⭐⭐⭐ Expert | Time: 7 min | Mode: Pairs

```
╔══════════════════════════════════════════════════════════════════════╗
║  🎯 OBJECTIVE: Monitoring script with infinite loop                  ║
║                                                                      ║
║  BEHAVIOUR:                                                          ║
║  - Runs in infinite loop                                            ║
║  - Each iteration: clear screen, display date, top 5 processes      ║
║  - 2 second pause between refresh                                    ║
║  - Can be stopped with Ctrl+C (trap for cleanup)                    ║
╠══════════════════════════════════════════════════════════════════════╣
║                                                                      ║
║  SHUFFLED LINES (one valid alternative, one distractor):                              ║
║  ────────────────────────────────────────────────────────────────   ║
║     echo "=== $(date) ==="                                          ║
║     while true; do                                                  ║
║     trap "echo 'Stopping monitor'; exit" INT                        ║
║     clear                                                           ║
║     ps aux --sort=-%mem | head -6                                   ║
║     done                                                            ║
║     sleep 2                                                         ║
║     for ((;;)); do                        ← VALID ALTERNATIVE (choose one loop header) ║
║     exit 0                                ← DISTRACTOR              ║
║  ────────────────────────────────────────────────────────────────   ║
║                                                                      ║
╚══════════════════════════════════════════════════════════════════════╝
```

✅ CORRECT SOLUTION:
```bash
trap "echo 'Stopping monitor'; exit" INT
while true; do
    clear
    echo "=== $(date) ==="
    ps aux --sort=-%mem | head -6
    sleep 2
done
```

Distractor explanations:
- `for ((;;)); do` - syntax is valid (C-style infinite for), but `while true` is clearer and more idiomatic in Bash
- `exit 0` - would terminate script immediately, doesn't belong in the loop

---

## BASH-SPECIFIC PROBLEMS (BONUS)

These problems target frequent Bash misconceptions with distractors that exploit common syntax errors.

---

### PP-13: Variable Assignment Trap
Level: ⭐⭐ Medium | Time: 4 min | Mode: Individual

```
╔══════════════════════════════════════════════════════════════════════╗
║  🎯 OBJECTIVE: Assign values to variables and display them           ║
║                                                                      ║
║  BEHAVIOUR:                                                          ║
║  - Set NAME to "Alice"                                              ║
║  - Set AGE to 25                                                    ║
║  - Display: "NAME is AGE years old"                                  ║
╠══════════════════════════════════════════════════════════════════════╣
║                                                                      ║
║  SHUFFLED LINES (two are DISTRACTORS):                              ║
║  ────────────────────────────────────────────────────────────────   ║
║     NAME="Alice"                                                    ║
║     AGE=25                                                          ║
║     echo "$NAME is $AGE years old"                                  ║
║     NAME = "Alice"                        ← DISTRACTOR (spaces!)    ║
║     echo '$NAME is $AGE years old'        ← DISTRACTOR (quotes!)    ║
║  ────────────────────────────────────────────────────────────────   ║
║                                                                      ║
╚══════════════════════════════════════════════════════════════════════╝
```

✅ CORRECT SOLUTION:
```bash
NAME="Alice"
AGE=25
echo "$NAME is $AGE years old"
```

Distractor explanations:
- `NAME = "Alice"` parses as a command named `NAME` with arguments; it does not assign the variable and ordinarily fails with command not found
- `echo '$NAME is $AGE years old'` - single quotes do NOT expand variables (prints literal `$NAME`)

---

### PP-14: Test Brackets Trap

Choose either of the two valid `[[ ... ]]` headers and all body lines; there is one invalid `[ ... ]` header. `config.txt` must be a trusted, owned shell fragment because `source` executes its contents.
Level: ⭐⭐⭐ Advanced | Time: 5 min | Mode: Pairs

```
╔══════════════════════════════════════════════════════════════════════╗
║  🎯 OBJECTIVE: Check if file exists and is readable                 ║
║                                                                      ║
║  BEHAVIOUR:                                                          ║
║  - If config.txt exists AND is readable → source it                 ║
║  - Otherwise → display error message                                ║
╠══════════════════════════════════════════════════════════════════════╣
║                                                                      ║
║  SHUFFLED LINES (one valid alternative, one distractor):                              ║
║  ────────────────────────────────────────────────────────────────   ║
║     if [[ -f "config.txt" && -r "config.txt" ]]; then               ║
║         source config.txt                                           ║
║     else                                                            ║
║         echo "Error: config.txt not found or not readable"          ║
║     fi                                                              ║
║     if [[ -f "config.txt"&& -r "config.txt" ]]; then  ← VALID ALTERNATIVE  ║
║     if [ -f "config.txt" && -r "config.txt" ]; then   ← DISTRACTOR  ║
║  ────────────────────────────────────────────────────────────────   ║
║                                                                      ║
╚══════════════════════════════════════════════════════════════════════╝
```

✅ CORRECT SOLUTION:
```bash
if [[ -f "config.txt" && -r "config.txt" ]]; then
    source config.txt
else
    echo "Error: config.txt not found or not readable"
fi
```

Distractor explanations:
- `[[ -f "config.txt"&& -r "config.txt" ]]` is valid Bash: `&&` is an operator token even without the preceding space. Prefer spaced formatting for readability; accept either offered header.
- `[ -f "config.txt" && -r "config.txt" ]` - the shell splits this into two commands; the first `[` lacks a closing `]`. Use `[[ -f config.txt && -r config.txt ]]` or `[ -f config.txt ] && [ -r config.txt ]`

---

### PP-15: Command Substitution Trap

Choose either valid date-assignment spelling; there is one invalid assignment alternative.
Level: ⭐⭐⭐ Advanced | Time: 5 min | Mode: Individual

```
╔══════════════════════════════════════════════════════════════════════╗
║  🎯 OBJECTIVE: Store command output in variable                     ║
║                                                                      ║
║  BEHAVIOUR:                                                          ║
║  - Get current date in format YYYY-MM-DD                            ║
║  - Store in variable TODAY                                          ║
║  - Create backup filename: backup_YYYY-MM-DD.tar                    ║
║  - Display the filename                                              ║
╠══════════════════════════════════════════════════════════════════════╣
║                                                                      ║
║  SHUFFLED LINES (one valid alternative, one distractor):                              ║
║  ────────────────────────────────────────────────────────────────   ║
║     TODAY=$(date +%Y-%m-%d)                                         ║
║     FILENAME="backup_${TODAY}.tar"                                  ║
║     echo "Backup file: $FILENAME"                                   ║
║     TODAY=`date +%Y-%m-%d`                 ← VALID ALTERNATIVE (older syntax) ║
║     TODAY = $(date +%Y-%m-%d)              ← DISTRACTOR (spaces!)   ║
║  ────────────────────────────────────────────────────────────────   ║
║                                                                      ║
╚══════════════════════════════════════════════════════════════════════╝
```

✅ CORRECT SOLUTION:
```bash
TODAY=$(date +%Y-%m-%d)
FILENAME="backup_${TODAY}.tar"
echo "Backup file: $FILENAME"
```

Distractor explanations:
- `` TODAY=`date +%Y-%m-%d` `` - backticks remain supported older syntax; `$()` is preferred for clearer nesting. Either offered assignment is valid here
- `TODAY = $(date +%Y-%m-%d)` invokes a command named TODAY instead of assigning a variable

---

### PP-16: Read Variable Trap

Choose either valid delimiter-assignment header. The header using expanded values as `read` variable names is the distractor.
Level: ⭐⭐⭐ Advanced | Time: 5 min | Mode: Pairs

```
╔══════════════════════════════════════════════════════════════════════╗
║  🎯 OBJECTIVE: Read file into variables with custom delimiter       ║
║                                                                      ║
║  FILE FORMAT (passwd style): username:uid:shell                     ║
║  Example line: alice:1001:/bin/bash                                 ║
║                                                                      ║
║  BEHAVIOUR: Display "User: alice has UID 1001 and uses /bin/bash"  ║
╠══════════════════════════════════════════════════════════════════════╣
║                                                                      ║
║  SHUFFLED LINES (one valid alternative, one distractor):                              ║
║  ────────────────────────────────────────────────────────────────   ║
║     while IFS=: read -r user uid shell; do                          ║
║         echo "User: $user has UID $uid and uses $shell"             ║
║     done < users.txt                                                ║
║     while IFS=: read -r $user $uid $shell; do   ← DISTRACTOR        ║
║     while IFS=":" read -r user uid shell; do    ← VALID ALTERNATIVE        ║
║  ────────────────────────────────────────────────────────────────   ║
║                                                                      ║
╚══════════════════════════════════════════════════════════════════════╝
```

✅ CORRECT SOLUTION:
```bash
while IFS=: read -r user uid shell; do
    echo "User: $user has UID $uid and uses $shell"
done < users.txt
```

Distractor explanations:
- `read -r $user $uid $shell` - variables in `read` are written WITHOUT `$` prefix
- `IFS=":"` and `IFS=:` assign exactly the same delimiter. Both offered `read -r` headers are valid. Omitting `-r` changes backslash handling, not the meaning of quoted `IFS`. This fixture has three colon-separated, newline-terminated fields without embedded colons.

---

### PP-17: Stderr Redirection Order Trap
Level: ⭐⭐⭐⭐ Expert | Time: 6 min | Mode: Individual

```
╔══════════════════════════════════════════════════════════════════════╗
║  🎯 OBJECTIVE: Redirect BOTH stdout AND stderr to same file         ║
║                                                                      ║
║  BEHAVIOUR:                                                          ║
║  - Run command that produces both stdout and stderr                 ║
║  - Capture EVERYTHING in all_output.log                             ║
║  - Display "Logged to all_output.log"                               ║
╠══════════════════════════════════════════════════════════════════════╣
║                                                                      ║
║  SHUFFLED LINES (two are DISTRACTORS):                              ║
║  ────────────────────────────────────────────────────────────────   ║
║     ls /home /nonexistent > all_output.log 2>&1                     ║
║     echo "Logged to all_output.log"                                 ║
║     ls /home /nonexistent 2>&1 > all_output.log   ← DISTRACTOR      ║
║     ls /home /nonexistent > all_output.log 2>all_output.log ← DISTRACTOR ║
║  ────────────────────────────────────────────────────────────────   ║
║                                                                      ║
╚══════════════════════════════════════════════════════════════════════╝
```

✅ CORRECT SOLUTION:
```bash
ls /home /nonexistent > all_output.log 2>&1
echo "Logged to all_output.log"
```

Distractor explanations:
- `2>&1 > all_output.log` - WRONG ORDER! `2>&1` redirects stderr to where stdout is NOW (terminal), then stdout goes to file. Stderr stays on terminal!
- `> all_output.log 2>all_output.log` - two separate redirections can cause race condition and interleaved/corrupted output

---

## RECOMMENDED USAGE

| Problem | After which concept | Difficulty | Time | Mode |
|---------|---------------------|------------|------|------|
| PP-01 | Operators && \|\| | ⭐ | 3 min | Individual |
| PP-02 | Operator chains | ⭐⭐ | 4 min | Pairs |
| PP-03 | Background & wait | ⭐⭐ | 4 min | Individual |
| PP-04 | stderr redirection | ⭐⭐ | 4 min | Pairs |
| PP-05 | Here documents | ⭐⭐ | 5 min | Individual |
| PP-06 | tee and pipelines | ⭐⭐⭐ | 5 min | Pairs |
| PP-07 | sort \| uniq | ⭐⭐ | 4 min | Individual |
| PP-08 | Complex pipeline | ⭐⭐⭐ | 5 min | Pairs |
| PP-09 | for with files | ⭐⭐ | 4 min | Individual |
| PP-10 | for C-style vs brace | ⭐⭐ | 4 min | Pairs |
| PP-11 | while read + variables | ⭐⭐⭐ | 5 min | Individual |
| PP-12 | Complete script | ⭐⭐⭐⭐ | 7 min | Pairs |
| PP-13 | Variable assignment | ⭐⭐ | 4 min | Individual |
| PP-14 | Test brackets [[ ]] | ⭐⭐⭐ | 5 min | Pairs |
| PP-15 | Command substitution | ⭐⭐⭐ | 5 min | Individual |
| PP-16 | IFS and read | ⭐⭐⭐ | 5 min | Pairs |
| PP-17 | Redirection order | ⭐⭐⭐⭐ | 6 min | Individual |

---

## BASH-SPECIFIC DISTRACTORS SUMMARY

| ID | Distractor Pattern | Bash Error | Frequency |
|----|-------------------|------------|-----------|
| D1 | `VAR = value` | Spaces around `=` | 85% of beginners |
| D2 | `[[ -f file]]` | Missing space before `]]` | 60% |
| D3 | `{1..$N}` | Brace expansion with variables | 70% |
| D4 | `read $var` | `$` in read variable name | 45% |
| D5 | `'$VAR'` vs `"$VAR"` | Single quotes don't expand | 55% |
| D6 | `uniq` without `sort` | Only removes consecutive | 80% |
| D7 | `cut -f` without `-d` | TAB implicit vs space | 65% |
| D8 | `2>&1 >` vs `> 2>&1` | Redirection order | 55% |
| D9 | `[ && ]` inside single brackets | Use separate tests joined by `&&`, or `[[ ]]` | 50% |
| D10 | `pipe \| while` | Subshell problem | 65% |

---

## TIPS FOR SOLVING

1. Identify the structure - look for `for`, `while`, `do`, `done`
2. Find the first line - usually initialisation or main command
3. Follow the logical flow - what depends on what?
4. **Watch out for distractors** - lines that "almost" work
5. Check syntax - `; do` vs just `do`, spaces in `[ ]` and `[[ ]]`
6. Test mentally - trace through execution step by step
7. Remember Bash quirks - no spaces in assignment, quote variables

---

*Parsons Problems generated for ASE Bucharest - CSIE*  
*Seminar 02: Operators, Redirection, Filters, Loops*

Historical percentage frequencies in the distractor table are retained author annotations without a supplied cohort, denominator or measurement protocol; they are not validated empirical rates.
