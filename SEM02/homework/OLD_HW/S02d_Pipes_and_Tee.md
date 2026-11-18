# S02_TC03 - Pipes and Tee

> **Operating Systems** | ASE Bucharest - CSIE  
> Laboratory Material - Seminar 2 (New - Redistributed)

---

> 🚨 **BEFORE STARTING THIS ASSIGNMENT**
>
> 1. Download and configure the `002HWinit` package (see STUDENT_GUIDE_EN.md)
> 2. Open a terminal and navigate to `~/HOMEWORKS`
> 3. Start recording with:
>    ```bash
>    python3 record_homework_tui_EN.py
>    ```
>    or the Bash variant:
>    ```bash
>    ./record_homework_EN.sh
>    ```
> 4. Fill in the required details (name, group, assignment number)
> 5. **ONLY THEN** begin solving the requirements below

---

## Objectives

By the end of this laboratory, the student will be able to:
- Understand the Unix philosophy "Do one thing and do it well"
- Construct efficient pipelines with the `|` operator
- Use `tee` for output branching
- Apply subshells in practical contexts
- Diagnose pipeline problems with `PIPESTATUS`

---


## 2. The Pipe Operator `|`

### 2.1 Connecting stdout → stdin

```bash
# Standard pipe: stdout (fd 1) → stdin (fd 0)
ls -la | grep ".txt"

# stderr does NOT pass through pipe by default!
ls /nonexistent | wc -l
# Error appears on screen, wc receives 0 lines
```

### 2.2 Pipe for stderr `|&`

```bash
# Bash 4+: |& sends stderr through pipe as well
ls /nonexistent |& grep "No such"

# Equivalent to:
ls /nonexistent 2>&1 | grep "No such"
```

### 2.3 Complex Pipelines

```bash
# Log analysis - classic pattern
cat access.log | \
    grep "POST" | \
    awk '{print $1}' | \
    sort | \
    uniq -c | \
    sort -rn | \
    head -10

# Result: Top 10 IPs with POST requests
```

---

## 3. The `tee` Command - Output Branching

### 3.1 The T-Splitter Concept

`tee` writes simultaneously to stdout AND to a file:

```
                    ┌──► file
stdin ──► [tee] ────┤
                    └──► stdout ──► next command
```

```bash
# Syntax
command | tee file.txt

# With append
command | tee -a file.txt
```

### 3.2 Use Cases

```bash
# 1. Logging and simultaneous display
./script.sh | tee output.log

# 2. Checkpoint in long pipeline
cat data.csv | \
    grep "2024" | \
    tee checkpoint1.txt | \
    sort | \
    tee checkpoint2.txt | \
    uniq -c

# 3. Write to multiple files
echo "message" | tee file1.txt file2.txt file3.txt

# 4. Write with sudo (classic trick)
echo "new line" | sudo tee -a /etc/hosts
```

### 3.3 tee and /dev/null

```bash
# Save to file, don't display
command | tee file.txt > /dev/null

# Display, don't save (rarely useful, but possible)
command | tee /dev/null
```

---

## 4. Subshells and Grouping

### 4.1 Subshell with `( )`

```bash
# Commands in () run in a subshell
(cd /tmp && ls)
pwd  # Still in original directory

# Pipeline in a subshell
(cat file1; cat file2) | sort | uniq
```

### 4.2 Grouping with `{ }`

```bash
# Braces alone do not request a subshell, but a pipeline component normally runs in one.
{ echo "start"; cat file; echo "end"; } | wc -l

# ATTENTION: space and ; are mandatory
{ cmd1; cmd2; }   # Correct
{cmd1;cmd2}       # WRONG
```

### 4.3 Practical Difference

```bash
# Parenthesised subshell inherits existing state; changes do not reach the parent.
unset VAR
(VAR="test"); echo "$VAR"  # empty in parent

# With grouping - variable persists
{ VAR="test"; }; echo $VAR  # "test"
```

---

## 5. PIPESTATUS and Diagnostics

### 5.1 The Exit Code Problem in Pipelines

```bash
# Exit code of a pipeline = last command
false | true | true
echo $?  # 0 (from last true)

# But the first command failed!
```

### 5.2 The PIPESTATUS Array

```bash
# PIPESTATUS contains exit codes for ALL commands
cmd1 | cmd2 | cmd3
statuses=("${PIPESTATUS[@]}")  # capture before any echo/test changes PIPESTATUS
printf 'All statuses: %s\n' "${statuses[*]}"
printf 'cmd1=%s cmd2=%s cmd3=%s\n' "${statuses[0]}" "${statuses[1]}" "${statuses[2]}"
```

### 5.3 Complete Pipeline Verification

```bash
# Pattern for verification
cat file.txt | grep "pattern" | wc -l
statuses=("${PIPESTATUS[@]}")
if ((statuses[0] != 0)); then
    echo "Cannot read input" >&2
elif ((statuses[1] > 1)); then
    echo "grep failed" >&2
elif ((statuses[2] != 0)); then
    echo "wc failed" >&2
elif ((statuses[1] == 1)); then
    echo "Pattern not found (normal zero-match result)"
fi
```

### 5.4 set -o pipefail

```bash
# With pipefail, pipeline returns rightmost non-zero exit code
set -o pipefail

false | true | true
echo $?  # 1 (from false)

# RECOMMENDED for scripts!
set -euo pipefail
```

---

## 6. Advanced Patterns

### 6.1 Process Substitution `<()` and `>()`

```bash
# <() - treat output as file
diff <(ls dir1) <(ls dir2)

# Compare outputs without temporary files
diff <(sort file1) <(sort file2)

# >() - treat input as file for writing
tee >(gzip > backup.gz) >(md5sum > checksum.txt)
```

### 6.2 Named Pipes (FIFO)

```bash
# Create named pipe
FIFO_DIR=$(mktemp -d "${TMPDIR:-/tmp}/enos-fifo.XXXXXX") || exit 1
mkfifo "$FIFO_DIR/mypipe"
printf 'FIFO_DIR=%q\n' "$FIFO_DIR"

# Terminal 1 (reads)
cat "$FIFO_DIR/mypipe"

# Terminal 2 (writes): first set FIFO_DIR to the exact path printed by terminal 1
echo "message" > "$FIFO_DIR/mypipe"

# Cleanup
rm "$FIFO_DIR/mypipe"
```

### 6.3 Pipeline with xargs

```bash
# Powerful combination: pipe + xargs
find . -type f -name "*.log" -print0 | xargs -0 -r grep -h -- "ERROR"

# With -I for substitution
find . -maxdepth 1 -type f -name "*.txt" -print0 | xargs -0 -r -I{} cp -- "{}" backup/
```

---

## 7. Best Practices

### 7.1 Efficiency

```bash
# AVOID - Useless Use of Cat (UUOC)
cat file | grep pattern  # NO

# PREFER
grep pattern file        # YES

# AVOID - Excessive pipes
cat file | sort | uniq  # NO

# PREFER
sort -u file            # YES
```

### 7.2 Debugging Pipelines

```bash
# Add tee for inspection
complex_cmd | tee /dev/stderr | next_cmd

# Or with numbering
cmd1 | nl | cmd2  # Add line numbers for debug
```

### 7.3 Error Handling

```bash
#!/bin/bash
set -euo pipefail

# Checked pipeline; a zero-match grep is valid empty output.
process_data() {
    [[ $# == 2 ]] || { printf 'Usage: process_data INPUT OUTPUT\n' >&2; return 2; }
    local -a status
    if cat -- "$1" | grep -v '^#' | sort | uniq -c | tee -- "$2"; then
        status=("${PIPESTATUS[@]}")
    else
        status=("${PIPESTATUS[@]}")
    fi
    ((status[0] == 0)) || { printf 'Cannot read input\n' >&2; return 1; }
    ((status[1] <= 1)) || { printf 'grep failed\n' >&2; return 1; }
    ((status[2] == 0 && status[3] == 0 && status[4] == 0)) || { printf 'Pipeline output failed\n' >&2; return 1; }
    return 0
}
```

---

## 8. Practical Exercises

### Exercise 1: Basic Pipeline
Create a pipeline that:
1. Lists all files in `/var/log`
2. Filters only `.log` files
3. Counts how many there are

### Exercise 2: Tee for Logging
Write a command that:
1. Displays current processes
2. Saves to `processes.txt`
3. Displays only the first 10 on screen

### Exercise 3: Analysis with PIPESTATUS
Write a script that:
1. Reads a file
2. Searches for a pattern
3. Reports which step failed (if applicable)

### Exercise 4: Process Substitution
Compare the sorted contents of two directories using `diff` and `<()`.

---

## 9. Troubleshooting

| Problem | Cause | Solution |
|---------|-------|----------|
| `Broken pipe` | Command on the right terminated | Can be expected with bounded readers such as `head`; `tail -n` normally reads to EOF |
| stderr on screen | `\|` does not redirect stderr | Use `\|&` or `2>&1 \|` |
| Exit code 0 but errors | Pipeline returns last | Use `set -o pipefail` |
| Incomplete data | Buffering | Add `stdbuf -oL` for line-buffered |

---

## References

- `man bash` - PIPELINES section
- `man tee`
- [GNU Coreutils - tee](https://www.gnu.org/software/coreutils/manual/html_node/tee-invocation.html)
- [Bash Pitfalls - Pipes](https://mywiki.wooledge.org/BashPitfalls)

---

## 📤 Submission and Finalisation

After completing all requirements:

1. **Stop the recording** by typing:
   ```bash
   STOP_homework
   ```
   or press `Ctrl+D`

2. **Wait** - the script will:
   - Finalise the legacy recorder metadata envelope (not a content signature)
   - Automatically upload the file to the server

3. **Check the final message**:
   - ✅ `UPLOAD SUCCESSFUL!` - the assignment was submitted
   - ❌ If upload fails, the `.cast` file is saved locally - submit it manually later with the displayed command

> Keep the original `.cast` as evidence. The distributed recorder envelopes do not
> bind event content and do not authenticate the student. Local preflight exit 0
> establishes format only (`UNVERIFIED` authentication, `UNCONFIRMED` readiness).
> The separate SEM07 `# SIGNATURE:` contract binds a content digest only when it
> verifies with an explicitly supplied key; identity and institutional acceptance
> still require an approved protocol. See the [current recording contract](../../../03_GUIDES/RECORDING_CONTRACT.md)
> and [verification contract](../../../SEM07/homework_evaluation/VERIFICATION_AND_GRADING_CONTRACT.md).

---

*By Revolvix for OPERATING SYSTEMS class | restricted licence 2017-2030*
