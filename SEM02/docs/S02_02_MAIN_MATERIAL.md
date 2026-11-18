# Main Material: Operators, Redirection, Filters, Loops
## Operating Systems | ASE Bucharest - CSIE

> Lab observation: note down key commands and relevant output (2-3 lines) as you work. It helps with debugging and, honestly, by the end you'll have a good README without extra effort.
Version: 1.0 | Seminar: 02  
approach: Language as Vehicle (Bash for understanding OS concepts)  
Estimated study time: 3-4 hours

---

## Learning Objectives

At the end of studying this material, you will be able to:

| # | Objective | Bloom Level | Verification |
|---|-----------|-------------|--------------|
| O1 | Explain the difference between `;`, `&&`, `\|\|` and `&` | Understanding | PI Quiz |
| O2 | Build efficient pipelines with `\|` | Applying | Sprint |
| O3 | Redirect stdout, stderr and stdin correctly | Applying | Exercises |
| O4 | Use filters `sort`, `uniq`, `cut`, `tr`, `wc`, `head`, `tail` | Applying | Sprint |
| O5 | Write `for`, `while`, `until` loops with control flow | Applying | Homework |
| O6 | Debug scripts with common problems (subshell, brace expansion) | Analysing | LLM Exercise |
| O7 | Combine all elements into a functional script | Synthesising | Project |

---

## Contents

1. [MODULE 1: Control Operators](#module-1-control-operators)
   - 1.1 Introduction to Operators
   - 1.2 The Sequential Operator (`;`)
   - 1.3 The AND Operator (`&&`)
   - 1.4 The OR Operator (`||`)
   - 1.5 AND and OR Combinations
   - 1.6 The Background Operator (`&`)
   - 1.7 Command Grouping
   - 1.8 Exit Codes and `$?`

2. [MODULE 2: I/O Redirection](#module-2-io-redirection)
   - 2.1 File Descriptors
   - 2.2 Output Redirection
   - 2.3 Input Redirection
   - 2.4 Here Documents
   - 2.5 Here Strings
   - 2.6 Output Suppression

3. [MODULE 3: Text Filters](#module-3-text-filters)
   - 3.1 Unix Philosophy
   - 3.2 sort - Sorting
   - 3.3 uniq - Removing Duplicates
   - 3.4 cut - Extracting Columns
   - 3.5 paste - Merging Files
   - 3.6 tr - Character Transformation
   - 3.7 wc - Counting
   - 3.8 head and tail
   - 3.9 tee - Stream Duplication
   - 3.10 Complex Pipelines

*(Pipes are the genius of Unix. Combine simple commands to solve complex problems.)*


4. [MODULE 4: Loops](#module-4-loops)
   - 4.1 for Loop - List
   - 4.2 for Loop - C Style
   - 4.3 while Loop
   - 4.4 until Loop
   - 4.5 break and continue
   - 4.6 Integrated Practical Examples

5. [Summary and Cheat Sheet](#summary-and-cheat-sheet)
6. [Links to Other Concepts](#links-to-other-concepts)

---

# MODULE 1: CONTROL OPERATORS

## 1.1 Introduction to Operators

Control operators allow combining multiple commands into a single line or script, controlling execution flow based on the results of previous commands.

Why are they important?
- More concise and efficient scripts
- Error handling without explicit ifs
- Automation of complex tasks
- Foundation for advanced scripting

The operators we will study:

| Operator | Name | Behaviour |
|----------|------|-----------|
| `;` | Sequential | Executes all, ignores result |
| `&&` | AND | Executes next ONLY if previous SUCCEEDED |
| `\|\|` | OR | Executes next ONLY if previous FAILED |
| `&` | Background | Sends command to background |
| `\|` | Pipe | Connects stdout to stdin |

---

## 1.2 The Sequential Operator (`;`)

🎯 SUBGOAL 1.2.1: Understand sequential execution

The `;` (semicolon) operator separates commands that execute one after another, regardless of result. It is equivalent to writing commands on separate lines.

```bash
# Three commands separated by ;
echo "First command" ; echo "Second command" ; echo "Third command"
```

With `errexit` disabled, `;` does not test the preceding status: the following command executes after a failure. `set -e`, explicit `exit`, signals and shell errors can end the shell; the separator itself does not override those conditions.

```bash
# Demonstration: middle command fails
echo "Start" ; ls /nonexistent_directory ; echo "We continue anyway"
# Output: Start
# ls: cannot access '/nonexistent_directory': No such file or directory
# We continue anyway
```

🎯 SUBGOAL 1.2.2: Apply in practical context

When to use `;`:
- Independent commands that don't depend on each other
- Simple sequences of operations
- When we want to execute everything, regardless of errors
- Read error messages carefully — they contain valuable clues

```bash
# Practical example: cleanup and setup
# Read-only demonstration: the third command still executes.
printf 'start\n'; false; printf 'continues\n'
# Use an owned mktemp directory for any later file-operation exercise.
```

**⚠️ Warning**: For critical operations where failure matters, use `&&`!

---

## 1.3 The AND Operator (`&&`)

🎯 SUBGOAL 1.3.1: Understand short-circuit evaluation

The `&&` (logical AND) operator executes the next command ONLY if the previous command SUCCEEDED (exit code 0).

```bash
# Structure:
cmd1 && cmd2
# cmd2 executes ONLY if cmd1 returns exit code 0
```

Demonstration:
```bash
# Success → continues
mkdir project && echo "Directory created successfully!"
# Output: Directory created successfully!

# Failure → stops
mkdir project && echo "Created!"  # second time
# Output: mkdir: cannot create directory 'project': File exists
# echo does NOT execute!
```

🎯 SUBGOAL 1.3.2: Apply common patterns

Pattern 1: Chaining dependent operations
```bash


# All must succeed to continue
cd /var/log && grep "error" syslog && echo "Errors found"
```

*Personal note: Bash has ugly syntax, I admit. But it runs everywhere, and that matters enormously in practice.*


Pattern 2: Verification before action
```bash
# Check file existence before processing
[ -f config.txt ] && source config.txt
```

Pattern 3: Create and navigate
```bash
# Create directory and enter it
mkdir -p project/src && cd project/src
```

---

## 1.4 The OR Operator (`||`)

🎯 SUBGOAL 1.4.1: Understand OR logic

The `||` (logical OR) operator executes the next command ONLY if the previous command FAILED (non-zero exit code).

> 💡 *In exams from previous sessions, this question appeared frequently — so it's worth attention.*


```bash
# Structure:
cmd1 || cmd2
# cmd2 executes ONLY if cmd1 returns exit code != 0
```

Demonstration:
```bash
# Failure → executes fallback
ls /nonexistent || echo "Directory doesn't exist"
# Output: ls: cannot access...: No such file or directory
# Directory doesn't exist

# Success → does NOT execute fallback
ls /home || echo "This message doesn't appear"
# Output: (listing of /home directory)
```

🎯 SUBGOAL 1.4.2: Apply fallback patterns

Pattern 1: Default value
```bash
# Use directory from variable or home
cd "$WORKDIR" || cd ~
```

Pattern 2: Create if doesn't exist
```bash
# Create directory only if it doesn't exist
[ -d backup ] || mkdir backup
```

Pattern 3: Error message
```bash
# Report the error
cp important.txt backup/ || echo "Trap: Backup failed!"
```

---

## 1.5 AND and OR Combinations

🎯 SUBGOAL 1.5.1: Build success/error pattern

Combining `&&` and `||` we can create complete structures for handling success and error:

```bash
# Complete pattern: command && success || error
mkdir test && echo "Success" || echo "Error"
```

**⚠️ CRITICAL WARNING: Order matters!**

```bash
# CORRECT: success THEN error
mkdir test && echo "OK" || echo "FAIL"
# If mkdir succeeds: "OK"
# If mkdir fails: "FAIL"

# WRONG: error THEN success - unexpected behaviour!
mkdir test || echo "FAIL" && echo "OK"
# If mkdir fails: "FAIL" and "OK"! (because echo "FAIL" succeeds)
```

🎯 SUBGOAL 1.5.2: Grouping for correct behaviour

For predictable behaviour, use grouping with `{}`:

```bash
# Correct grouping with braces
mkdir test && { echo "Success"; ls test; } || { echo "Error"; exit 1; }


```

> 💡 I've observed that students who draw the diagram on paper before writing code have much better results.


`cmd && success || error` also runs `error` if `success` fails; braces do not remove that behaviour. For a true two-way branch use `if cmd; then success; else error; fi`. The short chain above assumes its reporting commands succeed.

---

## 1.6 The Background Operator (`&`)

🎯 SUBGOAL 1.6.1: Understand background execution

The `&` (ampersand) operator at the end of a command sends it to the **background**, allowing the shell to continue immediately.

```bash
# Syntax:
cmd &
# Command runs in background, shell is free for another command
```

Demonstration:
```bash
# Long-running command
sleep 10 &
echo "Shell is free! PID: $!"

# $! contains PID of last background process
```

🎯 SUBGOAL 1.6.2: Manage background jobs

Commands for job control:

| Command | Function |
|---------|----------|
| `jobs` | Lists active jobs |
| `fg` | Brings job to foreground |
| `fg %n` | Brings job #n to foreground |
| `bg` | Continues suspended job in background |
| `wait` | Waits for all jobs to complete |
| `wait $PID` | Waits for specific process to complete |

```bash
# Complete example
sleep 5 &
sleep 3 &
jobs
# Output: [1]- Running sleep 5 &
# [2]+ Running sleep 3 &

wait  # waits for both
echo "All processes have finished"
```

Suspending with Ctrl+Z:
```bash
sleep 100  # runs in foreground
# Press Ctrl+Z
# Output: [1]+ Stopped sleep 100

bg  # continues in background
fg  # return to foreground
```

---

## 1.7 Command Grouping

🎯 SUBGOAL 1.7.1: Differentiate `{}` from `()`

There are two ways to group commands, with different behaviours:

Braces `{}` - Grouping in current shell:
```bash
# Commands run in current shell
# Trap: spaces and ; are mandatory!
{ echo "One"; echo "Two"; }

# Variables persist
{ x=10; }
echo $x  # 10
```

Parentheses `()` - Subshell:
```bash
# Commands run in a separate subshell
(echo "One"; echo "Two")

# Variables do NOT persist
(x=10)
echo $x  # empty or previous value
```

🎯 SUBGOAL 1.7.2: Choose the correct method

| Situation | Use | Reason |
|-----------|-----|--------|
| Modify variables that need to persist | `{}` | Runs in current shell |
| Change directory temporarily | `()` | cd doesn't affect main shell |
| Group for redirection | either | Both work similarly |
| Isolate a working environment | `()` | Subshell is independent |

```bash
# Example: temporary cd
(cd /tmp; ls)  # lists /tmp
pwd  # still in original directory

# vs
{ cd /tmp; ls; }
pwd  # now we're in /tmp!
```

---

## 1.8 Exit Codes and `$?`

🎯 SUBGOAL 1.8.1: Understand the exit code system

Every Unix command returns an exit code - a number between 0 and 255.

| Exit Code | Meaning |
|-----------|---------|
| 0 | Success |
| 1 | General error |
| 2 | Incorrect command usage |
| 126 | Permission denied (not executable) |
| 127 | Command not found |
| 128+N | Terminated by signal N |
| 130 | Ctrl+C (SIGINT) |
| 137 | kill -9 (SIGKILL) |

Checking exit code:
```bash
ls /home
echo $?  # 0 (success)

ls /nonexistent
echo $?  # 2 (error)
```

🎯 SUBGOAL 1.8.2: Use exit codes in scripts

Explicit verification:
```bash
#!/bin/bash
cp file.txt backup/
if [ $? -eq 0 ]; then
    echo "Backup successful"
else
    echo "Backup failed"
    exit 1
fi
```

Simplified verification with `&&`/`||`:
```bash
cp file.txt backup/ && echo "OK" || echo "FAIL"
```

Useful commands for tests:
```bash
true   # always returns 0
false  # always returns 1

# Test conditions
[ -f file.txt ]  # 0 if exists, 1 if not
[ -d directory ] # 0 if it's a directory, 1 if not
```

---

# MODULE 2: I/O REDIRECTION

## 2.1 File Descriptors

🎯 SUBGOAL 2.1.1: Understand the Unix I/O model

In Unix, every process has three standard communication channels:

```
┌─────────────────────────────────────────────────────────┐
│                      PROCESS                              │
│  ┌─────────┐                                            │
│  │  stdin  │ ←── fd 0: Input (keyboard by default)      │
│  └─────────┘                                            │
│  ┌─────────┐                                            │
│  │ stdout  │ ──→ fd 1: Normal output (screen by default)│
│  └─────────┘                                            │
│  ┌─────────┐                                            │
│  │ stderr  │ ──→ fd 2: Errors (screen by default)       │
│  └─────────┘                                            │
└─────────────────────────────────────────────────────────┘
```

File Descriptor (fd): A number that identifies an I/O channel.

| fd | Name | Default | Description |
|----|------|---------|-------------|
| 0 | stdin | keyboard | Input data |
| 1 | stdout | screen | Normal output |
| 2 | stderr | screen | Error messages |

🎯 SUBGOAL 2.1.2: Visualise the streams

```bash
# The ls command produces output on both channels
ls /home /nonexistent
# stdout: listing of /home
# stderr: "ls: cannot access '/nonexistent': No such file or directory"

# Both go to screen by default, but they're SEPARATE channels
```

---

## 2.2 Output Redirection

🎯 SUBGOAL 2.2.1: Redirect stdout

The `>` operator - Overwrite:
```bash
# Send stdout to a file (OVERWRITES!)
echo "Hello" > message.txt
cat message.txt  # Hello

echo "World" > message.txt
cat message.txt  # World (Hello is gone!)
```

The `>>` operator - Append:
```bash
# Appends to end of file
echo "Line 1" > log.txt
echo "Line 2" >> log.txt
echo "Line 3" >> log.txt
cat log.txt
# Line 1
# Line 2
# Line 3
```

🎯 SUBGOAL 2.2.2: Redirect stderr

```bash
# 2> redirects stderr
ls /nonexistent 2> errors.txt
cat errors.txt  # error message

# 2>> appends errors
ls /another_nonexistent 2>> errors.txt
```

🎯 SUBGOAL 2.2.3: Combine stdout and stderr

Method 1: Separate destinations
```bash
# stdout to output.txt, stderr to errors.txt
ls /home /nonexistent > output.txt 2> errors.txt
```

Method 2: Same file (ORDER MATTERS!)
```bash
# CORRECT: stdout → file, then stderr → where stdout is
ls /home /nonexistent > all.txt 2>&1

# WRONG: stderr → stdout (screen), then stdout → file
ls /home /nonexistent 2>&1 > all.txt
# stderr still goes to screen!
```

Method 3: Shortcut with `&>`
```bash
# &> sends both to same file
ls /home /nonexistent &> all.txt
# Equivalent to: > all.txt 2>&1
```

---

## 2.3 Input Redirection

🎯 SUBGOAL 2.3.1: Read from file with `<`

```bash
# Instead of: cat file | wc -l
# Use:
wc -l < file.txt

# Difference: < doesn't create an extra process (cat)
```

Practical example:
```bash
# Sort contents of a file
sort < list.txt

# Equivalent but more efficient than:
cat list.txt | sort
```

---

## 2.4 Here Documents

🎯 SUBGOAL 2.4.1: Create multi-line input

Here Document (`<<`) allows providing multi-line input directly in a script:

```bash
# Syntax:
command << DELIMITER
line 1
line 2
line 3
DELIMITER
```

Example: file creation:
```bash
cat << EOF > config.txt
# Application configuration
host=localhost
port=8080
debug=true
EOF
```

🎯 SUBGOAL 2.4.2: Control variable expansion

With expansion (DELIMITER without quotes):
```bash
name="John"
cat << EOF
Hello, $name!
Current directory: $(pwd)
EOF
# Output: Hello, John!
# Current directory: /home/student
```

Without expansion (DELIMITER in quotes):
```bash
cat << 'EOF'
Variable: $name
Command: $(pwd)
EOF
# Output: Variable: $name
# Command: $(pwd)
```

🎯 SUBGOAL 2.4.3: Handle indentation

`<<-` allows tabs at the beginning (for indented scripts):

> 💡 A student once asked me why we can't just use the graphical interface for everything — the answer is that the terminal is 10 times faster for repetitive operations.

```bash
if true; then
    cat <<- EOF
		This text is indented with tabs
		But they will be removed from output
	EOF
fi
```

---

## 2.5 Here Strings

🎯 SUBGOAL 2.5.1: Provide string as input

Here String (`<<<`) sends a string directly as stdin:

```bash
# Instead of: echo "text" | command
# Use:
wc -w <<< "three words here"
# Output: 3

# With variable
message="Hello World"
wc -c <<< "$message"
```

Advantage: Doesn't create subshell (as with pipe with echo).

---

## 2.6 Output Suppression

🎯 SUBGOAL 2.6.1: Use /dev/null

`/dev/null` is a special "file" that discards everything it receives.

```bash
# Suppress stdout
ls /home > /dev/null
# Nothing is displayed

# Suppress stderr
ls /nonexistent 2> /dev/null
# Error is not displayed

# Suppress everything
ls /home /nonexistent &> /dev/null
# Total silence
```

Common pattern: existence check:
```bash
# Check if command exists, without output
command -v python3 &> /dev/null && echo "Python3 installed"
```

---

# MODULE 3: TEXT FILTERS

## 3.1 Unix Philosophy

🎯 SUBGOAL 3.1.1: Understand the filter principle

Unix philosophy promotes small programmes that do one thing well:

```
┌──────────┐     ┌──────────┐     ┌──────────┐     ┌──────────┐
│  Input   │ ──→ │ Filter 1 │ ──→ │ Filter 2 │ ──→ │  Output  │
│  (stdin) │     │  (sort)  │     │  (uniq)  │     │ (stdout) │
└──────────┘     └──────────┘     └──────────┘     └──────────┘
```

Characteristics:
- Read from stdin (implicitly or explicitly)
- Write to stdout
- Can be chained with pipe (`|`)
- Do one operation, but well

---

### Exercise input and measurement contract

Examples using `cut -d,`, `awk -F,` or `IFS=, read` accept **simple unquoted comma-separated fields**, one record per line, with no embedded comma, quote or newline. They do not implement general CSV. Quoted CSV needs a CSV parser such as Python's `csv` module. Expected sort output uses `LC_ALL=C`; character/byte examples state a UTF-8 locale separately. Process commands give a changing snapshot of processes, not a fixed host measurement or thread count. Author recollections and numerical performance anecdotes in this material are preserved as unverified observations, not benchmark results.

## 3.2 sort - Sorting

🎯 SUBGOAL 3.2.1: Sort text alphabetically and numerically

```bash
# Alphabetic sorting (default)
sort file.txt

# Numeric sorting
sort -n numbers.txt

# Reverse sorting (descending)
sort -r file.txt
sort -rn numbers.txt  # numeric descending
```

🎯 SUBGOAL 3.2.2: Sort by fields

```bash
# Sort by specific column
# -k N : sort by field N
# -t DELIM : specify delimiter

# Sort CSV by column 3 (grade)
sort -t',' -k3 -n students.csv

# Sort by column 3, then 1
sort -t',' -k3,3n -k1,1 students.csv
```

Useful options:

| Option | Effect |
|--------|--------|
| `-n` | Numeric sorting |
| `-r` | Reverse (descending) |
| `-k N` | Sort by field N |
| `-t C` | Use C as delimiter |
| `-u` | Remove duplicates (like `sort \| uniq`) |
| `-h` | "Human-readable" sorting (1K, 2M, 3G) |
| `-f` | Ignore case (A=a) |

---

## 3.3 uniq - Removing Duplicates

🎯 SUBGOAL 3.3.1: Understand the critical limitation

**⚠️ MAXIMUM ATTENTION**: `uniq` removes only CONSECUTIVE duplicates!

```bash
# Test data
cat > colours.txt << 'EOF'
red
green
red
blue
EOF

# WRONG: uniq alone
uniq colours.txt
# red
# green
# red ← still appears!
# blue

# CORRECT: sort THEN uniq
sort colours.txt | uniq
# blue
# green
# red
```

🎯 SUBGOAL 3.3.2: Count and filter duplicates

```bash
# Count occurrences
sort colours.txt | uniq -c
# 1 blue
# 1 green
# 2 red

# Sort by frequency
sort colours.txt | uniq -c | sort -rn
# 2 red
# 1 green
# 1 blue

# Display ONLY duplicates
sort colours.txt | uniq -d
# red

# Display ONLY unique entries
sort colours.txt | uniq -u
# blue
# green
```

---

## 3.4 cut - Extracting Columns

🎯 SUBGOAL 3.4.1: Extract fields with delimiter

```bash
# -d : delimiter (default is TAB!)
# -f : fields to extract

# Extract first field (username from /etc/passwd)
cut -d':' -f1 /etc/passwd

# Extract fields 1 and 3
cut -d':' -f1,3 /etc/passwd

# Extract fields 1-3
cut -d':' -f1-3 /etc/passwd
```

🎯 SUBGOAL 3.4.2: Extract characters

```bash
# -c : character positions

# First 10 characters
cut -c1-10 file.txt

# Characters 5-15
cut -c5-15 file.txt

# From character 20 to end
cut -c20- file.txt
```

**⚠️ Important limitations**:
- Delimiter is a single character
- Doesn't support regex
- For complex cases, use `awk`

---

## 3.5 paste - Merging Files

🎯 SUBGOAL 3.5.1: Combine files in parallel

```bash
# paste puts lines side by side, separated by TAB

# Create test files
echo -e "1\n2\n3" > numbers.txt
echo -e "a\nb\nc" > letters.txt

paste numbers.txt letters.txt
# 1 a
# 2 b
# 3 c

# With custom delimiter
paste -d',' numbers.txt letters.txt
# 1,a
# 2,b
# 3,c
```

🎯 SUBGOAL 3.5.2: Serialise to single line

```bash
# -s : serialisation (all lines on one row)
paste -s -d',' numbers.txt
# 1,2,3

# Useful for creating lists
ls | paste -s -d','
# file1.txt,file2.txt,file3.txt
```

---

## 3.6 tr - Character Transformation

🎯 SUBGOAL 3.6.1: Replace characters

Remember: `tr` works with CHARACTERS, not strings!

```bash
# Transformation lowercase → uppercase
echo "hello" | tr 'a-z' 'A-Z'
# HELLO

# Character set replacement
echo "hello" | tr 'aeiou' '12345'
# h2ll4

# Trap: doesn't replace strings!
echo "hello" | tr 'he' 'HE'
# HEllo (each character separately!)
```

🎯 SUBGOAL 3.6.2: Delete and squeeze characters

```bash
# Delete characters (-d)
echo "hello123world" | tr -d '0-9'
# helloworld

# Complement (-c): operates on what's NOT in set
echo "hello123world" | tr -cd '0-9'
# 123

# Squeeze (-s): compress consecutive repeats
echo "heeellooo" | tr -s 'eo'
# hello (the two l characters are not in the squeeze set)

# Utility: normalise spaces
echo "too   many    spaces" | tr -s ' '
# too many spaces
```

Character classes:

| Class | Meaning |
|-------|---------|
| `[:alnum:]` | Alphanumeric |
| `[:alpha:]` | Letters |
| `[:digit:]` | Digits |
| `[:space:]` | Whitespace (includes tab, newline) |
| `[:upper:]` | Uppercase |
| `[:lower:]` | Lowercase |

```bash
# Conversion with classes
echo "Hello World" | tr '[:upper:]' '[:lower:]'
# hello world
```

---

## 3.7 wc - Counting

🎯 SUBGOAL 3.7.1: Count lines, words, characters

```bash
# All statistics
wc file.txt
# 10 50 300 file.txt
# lines words bytes

# Only lines
wc -l file.txt

# Only words
wc -w file.txt

# Only characters
wc -c file.txt  # bytes
wc -m file.txt  # characters (for Unicode)
```

🎯 SUBGOAL 3.7.2: Usage in pipeline

```bash
# How many processes are running?
ps -e -o pid= | wc -l

# How many unique users?
cut -d':' -f1 /etc/passwd | sort -u | wc -l

# How many .txt files?
ls *.txt 2>/dev/null | wc -l
```

---

## 3.8 head and tail

🎯 SUBGOAL 3.8.1: Extract first/last lines

```bash
# First 10 lines (default)
head file.txt

# First N lines
head -n 5 file.txt
head -5 file.txt  # shortcut

# Last 10 lines (default)
tail file.txt

# Last N lines
tail -n 5 file.txt
tail -5 file.txt
```

🎯 SUBGOAL 3.8.2: Real-time monitoring

```bash
# Follow file in real time (-f = follow)
tail -f /var/log/syslog

# Follow with initial line count
tail -f -n 50 /var/log/syslog

# Stop: Ctrl+C
```

Useful combinations:
```bash
# Lines 5-10 (skip first 4, take next 6)
head -10 file.txt | tail -6

# Alternative: all EXCEPT first 4
tail -n +5 file.txt | head -6
```

---

## 3.9 tee - Stream Duplication

🎯 SUBGOAL 3.9.1: Save and display simultaneously

`tee` writes to file AND passes on to stdout:

```
            ┌──────────┐
            │  file    │
     ┌──────┤   tee    ├──────┐
input│      └──────────┘      │output
─────┴────────────────────────┴─────→
```

```bash
# Save output and display it
ls -la | tee listing.txt

# Save and process further
ps aux | tee processes.txt | grep root

# Append instead of overwrite
df -h | tee -a disk_log.txt
```

🎯 SUBGOAL 3.9.2: Debug pipelines

```bash
# Check what each step produces
cat data.txt | tee step1.txt | sort | tee step2.txt | uniq -c

# Now you can check step1.txt and step2.txt for debugging
```

---

## 3.10 Complex Pipelines

🎯 SUBGOAL 3.10.1: Build incrementally

Methodology: Add one command at a time and check output!

```bash
# Objective: Top 5 IPs from access.log

# Step 1: display file
cat access.log

# Step 2: extract IP (first field)
cat access.log | awk '{print $1}'

# Step 3: sort
cat access.log | awk '{print $1}' | sort

# Step 4: count duplicates
cat access.log | awk '{print $1}' | sort | uniq -c

# Step 5: sort numerically descending
cat access.log | awk '{print $1}' | sort | uniq -c | sort -rn

# Step 6: take first 5
cat access.log | awk '{print $1}' | sort | uniq -c | sort -rn | head -5
```

🎯 SUBGOAL 3.10.2: Common patterns

Word frequency:
```bash
tr -s ' ' '\n' < text.txt | sort | uniq -c | sort -rn | head -20
```

Unique file extensions:
```bash
find . -type f | sed 's/.*\.//' | sort | uniq -c | sort -rn
```

Processes per user:
```bash
ps -e -o user= | sort | uniq -c | sort -rn
```

---

# MODULE 4: LOOPS

## 4.1 for Loop - List

🎯 SUBGOAL 4.1.1: Iterate over explicit list

```bash
# Basic syntax
for variable in element1 element2 element3; do
    # commands
done

# Simple example
for colour in red green blue; do
    echo "Colour: $colour"
done
```

🎯 SUBGOAL 4.1.2: Use brace expansion

```bash
# Numeric range
for i in {1..5}; do
    echo "Number: $i"
done
# 1 2 3 4 5

# With step
for i in {0..10..2}; do
    echo $i
done
# 0 2 4 6 8 10

# Letters
for letter in {a..e}; do
    echo $letter
done
```

⚠️ Trap: Brace expansion does NOT work with variables!
```bash
N=5
for i in {1..$N}; do echo $i; done
# Output: {1..5} ← WRONG!

# Solutions:
for i in $(seq 1 $N); do echo $i; done
for ((i=1; i<=N; i++)); do echo $i; done
```

🎯 SUBGOAL 4.1.3: Iterate over files (globbing)

```bash
# All .txt files
for file in *.txt; do
    echo "Processing: $file"
    wc -l "$file"
done

# Trap: use quotes for "$file" (files with spaces)!

# With check that files exist
shopt -s nullglob  # pattern without match → empty list
for file in *.pdf; do
    echo "$file"
done
```

---

## 4.2 for Loop - C Style

🎯 SUBGOAL 4.2.1: C-style syntax

```bash
# Syntax:
for ((initialisation; condition; increment)); do
    # commands
done

# Classic example
for ((i=1; i<=5; i++)); do
    echo "i = $i"
done

# Countdown
for ((i=10; i>=0; i--)); do
    echo $i
    sleep 0.5
done
```

Strengths:
- Works with variables
- Familiar to C/Java programmers
- Precise control over iteration

---

## 4.3 while Loop

🎯 SUBGOAL 4.3.1: Iterate while condition is true

```bash
# Syntax:
while [ condition ]; do
    # commands
done

# Example: count to 5
count=1
while [ $count -le 5 ]; do
    echo "Count: $count"
    ((count++))
done
```

🎯 SUBGOAL 4.3.2: Read file line by line

```bash
# CORRECT method for reading file
while IFS= read -r line; do
    echo "Line: $line"
done < file.txt

# IFS= : preserves leading/trailing spaces
# -r : doesn't interpret backslashes
```

⚠️ THE SUBSHELL TRAP - Problem #1 with loops!

```bash
# WRONG: variable doesn't persist
total=0
cat file.txt | while read line; do
    ((total++))
done
echo $total  # 0! (subshell)

# CORRECT: redirection instead of pipe
total=0
while read line; do
    ((total++))
done < file.txt
echo $total  # correct!

# OR: process substitution
total=0
while read line; do
    ((total++))
done < <(cat file.txt)
echo $total  # correct!
```

---

## 4.4 until Loop

🎯 SUBGOAL 4.4.1: Iterate until condition becomes true

```bash
# until = "while NOT true"
# Opposite of while

until [ condition ]; do
    # commands (run while condition is FALSE)
done

# Example: wait until file appears
until [ -f /tmp/ready.txt ]; do
    echo "Waiting..."
    sleep 1
done
echo "File appeared!"
```

Equivalence:
```bash
# These two are equivalent:
until [ -f file ]; do ...; done
while [ ! -f file ]; do ...; done
```

---

## 4.5 break and continue

🎯 SUBGOAL 4.5.1: Control loop flow

break - Exit loop:
```bash
for i in {1..10}; do
    if [ $i -eq 5 ]; then
        echo "Stopping at $i"
        break
    fi
    echo $i
done
# Output: 1 2 3 4 Stopping at 5
```

continue - Skip to next iteration:
```bash
for i in {1..5}; do
    if [ $i -eq 3 ]; then
        echo "Skipping $i"
        continue
    fi
    echo "Processing: $i"
done
# Output: Processing: 1
# Processing: 2
# Skipping 3
# Processing: 4
# Processing: 5
```

🎯 SUBGOAL 4.5.2: break and continue with N levels

```bash
# break N - exit N loops
for i in {1..3}; do
    for j in {1..3}; do
        if [ $j -eq 2 ]; then
            break 2  # exit BOTH loops
        fi
        echo "$i-$j"
    done
done
# Output: 1-1

# continue N - skip in loop at level N
```

---

## 4.6 Integrated Practical Examples

🎯 SUBGOAL 4.6.1: Backup script

```bash
#!/bin/bash
# backup_files.sh - Backup regular .txt files modified less than 24 hours ago

backup_dir=$(mktemp -d "$HOME/backup_$(date +%Y%m%d).XXXXXX") || exit 1

count=0
for file in *.txt; do
    [ -f "$file" ] || continue  # skip if doesn't exist
    
    if selected=$(find "./$file" -maxdepth 0 -type f -mtime 0 -print); then
        [[ -n $selected ]] || continue
    else
        printf 'Cannot inspect: %s\n' "$file" >&2; exit 1
    fi
    if [[ -n $selected ]]; then
        if cp -- "$file" "$backup_dir/"; then
            echo "✓ Backup: $file"
            count=$((count + 1))
        else
            printf 'Copy failed: %s\n' "$file" >&2
            exit 1
        fi
    fi
done

echo "---"
echo "Total files saved: $count"
```

🎯 SUBGOAL 4.6.2: Batch processing with validation

```bash
#!/bin/bash
# process_logs.sh - Analyse logs
set -o pipefail

for logfile in /var/log/*.log; do
    [ -r "$logfile" ] || {
        echo "⚠ Cannot read: $logfile"
        continue
    }
    
    if errors=$(grep -c "ERROR" "$logfile"); then
        :
    else
        grep_status=$?
        if ((grep_status != 1)); then
            printf 'Cannot analyse: %s\n' "$logfile" >&2; exit "$grep_status"
        fi
        # grep status 1 is a normal zero-match result; stdout already contains 0.
    fi
    
    if [ "$errors" -gt 0 ]; then
        echo "$(basename "$logfile"): $errors errors"
    fi
done | sort -t':' -k2 -rn | head -10
```

🎯 SUBGOAL 4.6.3: Interactive menu

```bash
#!/bin/bash
# menu.sh - Simple menu

while true; do
    echo ""
    echo "=== MENU ==="
    echo "1) Display date"
    echo "2) List files"
    echo "3) Disk space"
    echo "4) Exit"
    echo ""
    read -p "Choose option: " choice
    
    case $choice in
        1) date ;;
        2) ls -la ;;
        3) df -h ;;
        4) echo "Goodbye!"; break ;;
        *) echo "Invalid option!" ;;
    esac
done
```

---

# SUMMARY AND CHEAT SHEET

## Control Operators

```
cmd1 ; cmd2      Execute both, ignore result
cmd1 && cmd2     cmd2 only if cmd1 SUCCEEDS
cmd1 || cmd2     cmd2 only if cmd1 FAILS
cmd &            Run in background
cmd1 | cmd2      Pipe: stdout(cmd1) → stdin(cmd2)
{ cmd1; cmd2; }  Grouping in current shell
( cmd1; cmd2 )   Grouping in subshell
```

## Redirection

```
cmd > file       stdout → file (overwrite)
cmd >> file      stdout → file (append)
cmd 2> file      stderr → file
cmd &> file      stdout+stderr → file
cmd < file       read input from file
cmd << EOF       here document
cmd <<< "str"    here string
```

## Filters

```
sort [-nrk]      sort lines
uniq [-cd]       remove CONSECUTIVE duplicates (needs sort!)
cut -d: -f1,3    extract fields
paste f1 f2      combine files in columns
tr 'ab' 'AB'     transform characters
wc [-lwc]        count newlines/words/bytes; -m for characters
head -n N        first N lines
tail -n N        last N lines
tail -f          follow file live
tee file         write to file AND pass forward
```

## Loops

```bash
# for list
for x in a b c; do echo $x; done

# for brace
for i in {1..10}; do echo $i; done

# for C-style
for ((i=0; i<10; i++)); do echo $i; done

# while
while [ cond ]; do ...; done

# until
until [ cond ]; do ...; done

# file reading
while IFS= read -r line; do ...; done < file
```

---

# LINKS TO OTHER CONCEPTS

## Seminar 1 Recap

This seminar builds on:
- Navigation: `cd`, `ls`, `pwd` - now we combine them with operators
- Variables: `$VAR`, `$?` - now we use them in loops and conditions
- Globbing: `*.txt` - now we use it in for loops
- Read error messages carefully — they contain valuable clues

## SEM05-06 Preview

In the following seminars we will see in detail:

Specifically: Regular expressions (regex): advanced pattern matching with `grep`, `sed`, `awk`. Advanced text processing: `awk` for complex transformations. And Advanced scripting: functions, arrays, debugging.


---

*Main Material generated for ASE Bucharest - CSIE*  
*Seminar 2: Operators, Redirection, Filters, Loops*
