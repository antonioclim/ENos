# S02_TC02 - I/O Redirection

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

Three things matter here: redirect input and output of commands, use pipes for chaining commands, and manage stdin, stdout and stderr.


---


## 2. Output Redirection

### 2.1 stdout (`>` and `>>`)

```bash
# Overwrite file (creates if doesn't exist)
echo "Hello" > output.txt

# Append to file
echo "World" >> output.txt

# Explicit redirection
echo "text" 1> output.txt      # equivalent to >

# Example
ls -la > list.txt
date >> log.txt
```

### 2.2 stderr (`2>` and `2>>`)

```bash
# Redirect errors
ls /nonexistent 2> errors.txt

# Append errors
ls /another_nonexistent 2>> errors.txt

# Example: save only errors
find / -name "*.conf" 2> errors.log
```

### 2.3 Combining stdout and stderr

```bash
# Both to the same file
command > all.txt 2>&1         # classic
command &> all.txt             # shortcut (Bash)
command &>> all.txt            # append

# To separate files
command > output.txt 2> errors.txt

# stderr to stdout
command 2>&1 | less            # pipe includes errors
command |& less                # Bash 4+ shortcut
```

### 2.4 Suppressing Output

```bash
# Discard stdout
command > /dev/null

# Discard stderr
command 2> /dev/null

# Discard everything
command > /dev/null 2>&1
command &> /dev/null

# Example: silent execution
if ping -c1 server &> /dev/null; then
    echo "Server online"
fi
```

---

## 3. Input Redirection

### 3.1 stdin (`<`)

```bash
# Read from file
wc -l < file.txt
sort < numbers.txt > sorted.txt

# Input for command
mail -s "Subject" user@example.com < message.txt
```

### 3.2 Here Document (`<<`)

```bash
# Read input until delimiter
cat << EOF
Line 1
Line 2
Variable: $HOME
EOF

# Without variable expansion
cat << 'EOF'
Literal: $HOME
EOF

# With indentation (<<-)
cat <<- EOF
	Indented line
	Another line
EOF
```

### 3.3 Here String (`<<<`)

```bash
# String as input
wc -w <<< "This is a sentence"
# Output: 4

tr 'a-z' 'A-Z' <<< "hello world"
# Output: HELLO WORLD

bc <<< "5 + 3"
# Output: 8
```

---

## 4. Pipes

Connects stdout of one command to stdin of another.

```bash
# Syntax
command1 | command2 | command3

# Examples
ls -la | less
cat file.txt | grep "pattern" | wc -l
ps aux | sort -k4 -rn | head -10

# Complex pipeline
find . -name "*.log" | xargs grep "ERROR" | sort | uniq -c | sort -rn
```

### 4.1 Named Pipes (FIFO)

```bash
# Create FIFO
mkfifo my_pipe

# Terminal 1: read from pipe
cat my_pipe

# Terminal 2: write to pipe
echo "Hello from other terminal" > my_pipe

# Cleanup
rm my_pipe
```

---

## 5. Useful Commands

### 5.1 tee

Duplicates the stream to file and stdout.

```bash
# Save and display
ls -la | tee list.txt

# Append
ls -la | tee -a list.txt

# Multiple files
command | tee f1.txt f2.txt f3.txt

# In the middle of a pipeline
cat data | sort | tee sorted.txt | uniq > unique.txt
```

### 5.2 xargs

Constructs arguments from stdin.

```bash
# Basic
find . -name "*.txt" | xargs cat

# With placeholder
find . -name "*.txt" | xargs -I{} cp {} backup/

# Limit arguments
echo "1 2 3 4 5" | xargs -n 2 echo

# Parallel execution
find . -name "*.jpg" | xargs -P 4 -I{} convert {} {}.png
```

---

## 6. Practical Exercises

### Exercise 1: Basic Redirection

```bash
# Create file
echo "Line 1" > test.txt
echo "Line 2" >> test.txt
cat test.txt

# Save errors separately
ls /existent /nonexistent > output.txt 2> errors.txt
```

### Exercise 2: Pipeline

```bash
# Top 5 processes by memory
ps aux --sort=-%mem | head -6

# Count .txt files
find . -name "*.txt" | wc -l

# Unique IPs from log
cat access.log | cut -d' ' -f1 | sort | uniq -c | sort -rn
```

### Exercise 3: Here Document

```bash
# Script that creates file
cat > config.txt << EOF
# Configuration
SERVER=$HOSTNAME
DATE=$(date)
USER=$USER
EOF
```

### Exercise 4: tee

```bash
# Logging with display
./script.sh 2>&1 | tee -a script.log
```

---

## Cheat Sheet

```bash
# OUTPUT
cmd > file          # stdout -> file (overwrite)
cmd >> file         # stdout -> file (append)
cmd 2> file         # stderr -> file
cmd 2>> file        # stderr -> file (append)
cmd &> file         # stdout+stderr -> file
cmd > f1 2> f2      # separate

# INPUT
cmd < file          # file -> stdin
cmd << DELIM        # here document
cmd <<< "string"    # here string

# COMBINING
cmd 2>&1            # stderr -> stdout
cmd > /dev/null     # discard stdout
cmd &> /dev/null    # discard all

# PIPE
cmd1 | cmd2         # stdout -> stdin
cmd |& cmd2         # stdout+stderr -> stdin

# UTILITIES
cmd | tee file      # duplicate stream
cmd | xargs         # stdin -> args
mkfifo pipe         # named pipe
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
