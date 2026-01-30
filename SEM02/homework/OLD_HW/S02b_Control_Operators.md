# S02_TC01 - Control Operators

> **Operating Systems** | ASE Bucharest - CSIE  
> Laboratory Material - Seminar 2 (Redistributed)

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
- Use control operators to combine commands
- Understand conditional and sequential execution
- Construct complex commands on a single line
- Test with simple data first

---


## 2. The Semicolon Operator (`;`)

Executes commands **sequentially**, regardless of success or failure.

```bash
# Syntax
command1 ; command2 ; command3

# Examples
echo "Start" ; ls ; echo "Done"

# Equivalent to:
echo "Start"
ls
echo "Done"

# Continues even if a command fails
ls /invalid ; echo "This executes anyway"
# Output: error from ls + "This executes anyway"
```

**Use Cases:**

```bash
# Quick structure creation
mkdir project ; cd project ; touch README.md

# Cleanup after script
./script.sh ; rm -f temp_*

# Compound command
date ; whoami ; pwd
```

---

## 3. The AND Operator (`&&`)

Executes the second command **ONLY IF** the first succeeded (exit code 0).

```bash
# Syntax
command1 && command2

# Examples
mkdir test && cd test           # enters test only if created
make && make install            # installs only if compilation succeeded

# Verification
ls /home && echo "Directory exists"
ls /nonexistent && echo "This won't display"
```

**Common Patterns:**

```bash
# Check before action
[ -d "backup" ] && cp file.txt backup/

# Compile and run
gcc program.c -o program && ./program

# Download and extract
wget url/file.tar.gz && tar xzf file.tar.gz

# Chain of operations
cd project && make clean && make && make test
```

---

## 4. The OR Operator (`||`)

Executes the second command **ONLY IF** the first failed (exit code ≠ 0).

```bash
# Syntax
command1 || command2

# Examples
cd /nonexistent || echo "Directory does not exist"
mkdir backup || echo "Could not create backup"

# Pattern: fallback
grep "pattern" file.txt || echo "Pattern not found"
ping -c1 server || echo "Server unavailable"
```

**Common Patterns:**

```bash
# Create if doesn't exist
[ -d "logs" ] || mkdir logs

# Error handler
./script.sh || { echo "Error!"; exit 1; }

# Default values
value=$(cat config.txt) || value="default"
```

---

## 5. Combining AND and OR

```bash
# Pattern: try or report
command && echo "Success" || echo "Failure"

# Examples
ping -c1 google.com && echo "Online" || echo "Offline"
mkdir test && echo "Created" || echo "Creation error"

# Complex pattern: if-then-else on one line
[ -f file.txt ] && cat file.txt || echo "File does not exist"

# Pitfall: if cat fails, "does not exist" also displays
# Safer:
[ -f file.txt ] && { cat file.txt; true; } || echo "Does not exist"
```

---

## 6. The Background Operator (`&`)

Executes the command in the **background**, returning control immediately.

```bash
# Syntax
command &

# Examples
sleep 100 &                     # runs in background
./long_process.sh &             # long script in background

# Output
[1] 12345                       # [job_id] PID

# Managing background processes
jobs                            # list jobs
fg                              # bring to foreground
fg %1                           # specific job
bg                              # continue in background
kill %1                         # terminate job
```

**Combinations with &:**

```bash
# Multiple in parallel
command1 & command2 & command3 &
wait                            # wait for all

# Background + continue
./backup.sh & echo "Backup started"
```

---

## 7. Pipe (`|`)

Connects **stdout** of one command to **stdin** of another.

```bash
# Syntax
command1 | command2 | command3

# Basic examples
ls -la | less                   # paginate output
cat file.txt | wc -l            # count lines
ps aux | grep nginx             # filter processes
```

**Common Pipelines:**

```bash
# Sort and uniqueness
cat file.txt | sort | uniq

# Find and count
grep "error" log.txt | wc -l

# Top 10 largest files
du -h * | sort -rh | head -10

# Text processing
cat data.csv | cut -d',' -f2 | sort | uniq -c | sort -rn

# Find processes and PID
ps aux | grep python | awk '{print $2}'
```

**Pipe with Errors (`|&`):**

```bash
# Pipe both stdout and stderr
command 2>&1 | less              # classic method
command |& less                  # Bash 4+ shortcut
```

---

## 8. Command Grouping

### 8.1 With Braces `{}`

Executes in the current shell.

```bash
# Syntax (spaces and ; are mandatory!)
{ command1; command2; }

# Example
{ echo "Start"; date; echo "End"; }

# Common redirect
{ echo "Line 1"; echo "Line 2"; } > output.txt

# With operators
mkdir test && { cd test; touch file.txt; echo "Done"; }
```

### 8.2 With Parentheses `()`

Executes in a **subshell** (separate environment).

```bash
# Syntax
(command1; command2)

# Difference: changes don't affect the current shell
cd /tmp               # changes directory
(cd /home; pwd)       # displays /home, but...
pwd                   # still in /tmp!

# Environment isolation
(export VAR="test"; echo $VAR)
echo $VAR             # empty - export was in subshell
```

---

## 9. Exit Codes

Every command returns an **exit code** (0-255).

```bash
# Check exit code
echo $?                         # exit code of last command

# Conventions
# 0 = success
# 1 = general error
# 2 = incorrect usage
# 126 = cannot execute
# 127 = command not found
# 128+N = terminated by signal N

# Examples
ls /existent
echo $?               # 0

ls /nonexistent
echo $?               # 2 (or another non-zero)

# Manual exit code setting
true                  # returns 0
false                 # returns 1

# In scripts
exit 0                # success
exit 1                # error
```

---

## 10. Practical Exercises

### Exercise 1: Basic Operators

```bash
# Sequential
echo "Step 1" ; echo "Step 2" ; echo "Step 3"

# AND - executes only if successful
mkdir /tmp/test_dir && echo "Directory created successfully"

# OR - executes only if fails
mkdir /root/test 2>/dev/null || echo "Permission denied"

# Combined
ping -c1 localhost && echo "Network OK" || echo "Network FAIL"
```

### Exercise 2: Pipelines

```bash
# Count .txt files
ls *.txt 2>/dev/null | wc -l

# Top 5 processes by memory
ps aux --sort=-%mem | head -6

# Find unique users from log
cat /var/log/auth.log | grep "user" | awk '{print $9}' | sort | uniq
```

### Exercise 3: Background Processes

```bash
# Start in background
sleep 30 &
echo "PID: $!"

# Verify
jobs

# Terminate
kill %1
```

### Exercise 4: Command Grouping

```bash
# Redirect group of commands
{
    echo "Date: $(date)"
    echo "User: $USER"
    echo "Dir: $PWD"
} > info.txt

cat info.txt

# Subshell - doesn't affect current shell
pwd
(cd /tmp; touch test_file; pwd)
pwd  # hasn't changed
```

---

## 11. Review Questions

1. **What is the difference between `;` and `&&`?**
   > `;` executes both commands regardless of result. `&&` executes the second only if the first succeeded.

2. **What does `mkdir test || echo "Error"` do?**
   > Displays "Error" only if `mkdir test` fails.

3. **How do you run a command in the background?**
   > Add `&` at the end: `command &`

4. **What is the difference between `{}` and `()`?**
   > `{}` executes in the current shell, `()` in a subshell (isolated environment).

5. **What does `echo $?` return after a successful command?**
   > `0` (zero = success).

---

## Cheat Sheet

```bash
# SEQUENTIAL EXECUTION
cmd1 ; cmd2         # run both
cmd1 && cmd2        # cmd2 only if cmd1 OK
cmd1 || cmd2        # cmd2 only if cmd1 FAIL

# BACKGROUND
cmd &               # run in background
$!                  # PID of last background
jobs                # list jobs
fg %N               # bring job N to foreground
bg %N               # continue job N in background
kill %N             # terminate job N
wait                # wait for all jobs

# PIPE
cmd1 | cmd2         # stdout cmd1 → stdin cmd2
cmd |& cmd2         # stdout + stderr → stdin

# GROUPING
{ cmd1; cmd2; }     # in current shell
( cmd1; cmd2 )      # in subshell

# EXIT CODE
$?                  # exit code of last command
true                # returns 0
false               # returns 1
exit N              # exit with code N

# COMMON PATTERNS
cmd && echo "OK" || echo "FAIL"
[ -f file ] && cat file || echo "Does not exist"
mkdir dir || { echo "Error"; exit 1; }
```

---

## 📤 Submission and Finalisation

After completing all requirements:

1. **Stop the recording** by typing:
   ```bash
   STOP_homework
   ```
   or press `Ctrl+D`

2. **Wait** - the script will:
   - Generate the cryptographic signature
   - Automatically upload the file to the server

3. **Check the final message**:
   - ✅ `UPLOAD SUCCESSFUL!` - the assignment was submitted
   - ❌ If upload fails, the `.cast` file is saved locally - submit it manually later with the displayed command

> ⚠️ **DO NOT modify the `.cast` file** after generation - the signature becomes invalid!

---

*By Revolvix for OPERATING SYSTEMS class | restricted licence 2017-2030*
