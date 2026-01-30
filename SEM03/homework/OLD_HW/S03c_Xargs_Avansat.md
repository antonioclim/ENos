# S03_TC02 - Advanced Xargs

> **Operating Systems** | Bucharest UES - CSIE  
> Laboratory material - Seminar 3 (NEW - Extended from TC2e)

---

> 🚨 **BEFORE STARTING THE ASSIGNMENT**
>
> 1. Download and configure the `002HWinit` package (see STUDENT_GUIDE_EN.md)
> 2. Open a terminal and navigate to `~/HOMEWORKS`
> 3. Start recording with:
>    ```bash
>    python3 record_homework_tui_RO.py
>    ```
>    or the Bash version:
>    ```bash
>    ./record_homework_RO.sh
>    ```
> 4. Complete the required data (name, group, assignment no.)
> 5. **ONLY THEN** start solving the requirements below

---

## Objectives

At the end of this laboratory, the student will be able to:
- Understand the role and necessity of `xargs`
- Use `xargs` with substitution `-I{}`
- Implement parallel processing with `-P`
- Handle files with special characters (`-print0`/`-0`)
- Choose between `find -exec` and `find | xargs`

---


## 2. Basic Usage

### 2.1 Syntax

```bash
producer_command | xargs [options] consumer_command
```

### 2.2 Simple Examples

```bash
# Delete files
find . -name "*.tmp" | xargs rm

# Count lines
find . -name "*.py" | xargs wc -l

# Search text in files
find . -name "*.c" | xargs grep "main"

# Install packages
echo "vim git curl" | xargs sudo apt install
```

---

## 3. Advanced Options

### 3.1 Substitution with `-I{}`

Allows placing the argument anywhere in the command:

```bash
# Syntax
xargs -I{} command {} other_arguments

# Examples
find . -name "*.txt" | xargs -I{} cp {} backup/
# Becomes: cp file1.txt backup/
#          cp file2.txt backup/

# With custom placeholder
find . -name "*.jpg" | xargs -IFILE convert FILE FILE.png

# Create directories based on files
ls *.tar.gz | xargs -I{} mkdir -p extracted/{}
```

### 3.2 Argument Count Control `-n`

```bash
# How many arguments per execution
echo "1 2 3 4 5 6" | xargs -n 2 echo
# Output:
# 1 2
# 3 4
# 5 6

# Utility: When command has argument limit
find . -name "*.log" | xargs -n 100 gzip

# Individual processing
cat urls.txt | xargs -n 1 wget
```

### 3.3 Parallel Processing `-P`

```bash
# Parallel execution (N processes)
find . -name "*.jpg" | xargs -P 4 -I{} convert {} {}.png

# Parallel download
cat urls.txt | xargs -P 10 -n 1 wget

# Parallel compression
find . -name "*.log" | xargs -P $(nproc) gzip

# Verification: nproc = number of cores
echo "Cores: $(nproc)"
```

### 3.4 Handling Spaces and Special Characters

**THE PROBLEM:**

```bash
# File with spaces in name
touch "my file.txt"
find . -name "*.txt" | xargs rm
# ERROR: rm tries to delete "my" and "file.txt" separately!
```

**THE SOLUTION: `-print0` and `-0`**

```bash
# find produces NULL-delimited output
# xargs reads NULL-delimited input
find . -name "*.txt" -print0 | xargs -0 rm

# Works for ANY filename:
# - Spaces: "my file.txt"
# - Newlines: "line1\nline2.txt"  
# - Special characters: "file;name.txt"
```

### 3.5 Display and Confirmation

```bash
# Display commands (-t = trace)
find . -name "*.tmp" | xargs -t rm
# Shows: rm ./file1.tmp ./file2.tmp

# Interactive confirmation (-p = prompt)
find . -name "*.bak" | xargs -p rm
# Asks: rm ./file.bak ?...
```

### 3.6 Command Size Limit `-s`

```bash
# Character limit per command line
find . -name "*.log" | xargs -s 1024 cat

# Useful for systems with ARG_MAX limit
getconf ARG_MAX  # See system limit
```

---

## 4. find -exec vs find | xargs

### 4.1 Comparison

| Aspect | `find -exec {} \;` | `find -exec {} +` | `find | xargs` |
|--------|-------------------|-------------------|----------------|
| Processes | 1 per file | Batch | Batch |
| Speed | Slow | Fast | Fast |
| Spaces | Safe | Safe | Requires -print0/-0 |
| Flexibility | Limited | Limited | High |
| Parallelism | No | No | Yes (-P) |

### 4.2 When to Use Each

```bash
# find -exec {} \; - When you need individual output
find . -name "*.sh" -exec echo "Processing: {}" \;

# find -exec {} + - When it's simple and you don't have spaces in names
find . -name "*.txt" -exec wc -l {} +

# find | xargs - When you need:
# - Parallelism
# - Complex substitution
# - Fine control

find . -name "*.jpg" -print0 | xargs -0 -P 4 -I{} convert {} {}.png
```

---

## 5. Advanced Patterns

### 5.1 Complex Pipeline

```bash
# Find, filter, process
find . -name "*.log" -mtime +7 -print0 | \
    xargs -0 grep -l "ERROR" | \
    xargs -I{} mv {} ./errors/
```

### 5.2 Processing with Script

```bash
# When the action is complex, use a script
find . -name "*.data" -print0 | xargs -0 -n 1 ./process.sh

# process.sh:
#!/bin/bash
file="$1"
echo "Processing: $file"
# ... complex processing
```

### 5.3 Batch Processing with Control

```bash
# Process in batches of 10, with pause between them
find . -name "*.img" -print0 | xargs -0 -n 10 sh -c '
    echo "Processing batch..."
    for f in "$@"; do
        convert "$f" "${f%.img}.png"
    done
    sleep 1  # Pause between batches
' _
```

### 5.4 Combination with GNU Parallel

```bash
# Alternative to xargs -P for complex cases
find . -name "*.mp4" | parallel ffmpeg -i {} -c:v libx264 {.}.avi

# parallel offers more options than xargs -P
```

---

## 6. Debugging and Troubleshooting

### 6.1 Debug Options

```bash
# Display without execution
find . -name "*.tmp" | xargs echo

# Verbose mode
find . -name "*.tmp" | xargs -t rm

# Custom dry-run
find . -name "*.tmp" | xargs -I{} echo "Would delete: {}"
```

### 6.2 Common Problems

| Problem | Cause | Solution |
|---------|-------|----------|
| `xargs: argument line too long` | Too many arguments | Use `-n` or `-s` |
| Files with spaces ignored | Default delimiter is space | Use `-print0 | xargs -0` |
| Command doesn't execute | Empty stdin | Add `-r` (no-run-if-empty) |
| Mixed output (parallel) | Concurrent processes | Use `--line-buffer` or reduce `-P` |

### 6.3 Input Verification

```bash
# Check what xargs receives
find . -name "*.txt" | head -5 | cat -A
# $ = end of line, ^I = tab, etc.

# Test with echo before dangerous command
find . -name "*.bak" | xargs echo rm
```

---

## 7. Practical Exercises

### Exercise 1: Safe Processing
Create a pipeline that deletes all `.tmp` files older than 7 days, correctly handling files with spaces in their names.

### Exercise 2: Parallel Conversion
Convert all `.png` images to `.jpg` using 4 parallel processes.

### Exercise 3: Selective Backup
Copy all `.conf` files modified in the last week to a `backup/` directory, preserving the directory structure.

### Exercise 4: Code Analysis
Count the lines of code in all `.py` and `.js` files in a project.

---

## xargs Cheat Sheet

```bash
# BASICS
cmd | xargs                    # stdin → arguments
cmd | xargs -n 1              # one at a time
cmd | xargs -I{} action {}    # substitution

# SAFETY (SPACES)
find -print0 | xargs -0       # null-delimited

# PARALLELISM
cmd | xargs -P 4              # 4 parallel processes
cmd | xargs -P $(nproc)       # all cores

# DEBUG
cmd | xargs -t action         # display command
cmd | xargs -p action         # interactive confirmation
cmd | xargs echo              # dry-run

# FREQUENT COMBINATIONS
find . -name "*.x" -print0 | xargs -0 rm
find . -name "*.x" -print0 | xargs -0 -I{} cp {} backup/
find . -name "*.x" -print0 | xargs -0 -P 4 -n 1 process
```

---

## References

- `man xargs`
- `man find` - section -exec
- [GNU Findutils](https://www.gnu.org/software/findutils/)
- [GNU Parallel](https://www.gnu.org/software/parallel/) - advanced alternative

---

## 📤 Completion and Submission

After you have completed all requirements:

1. **Stop recording** by typing:
   ```bash
   STOP_tema
   ```
   or press `Ctrl+D`

2. **Wait** - the script will:
   - Generate the cryptographic signature
   - Automatically upload the file to the server

3. **Check the final message**:
   - ✅ `UPLOAD SUCCESSFUL!` - the assignment was submitted
   - ❌ If upload fails, the `.cast` file is saved locally - send it manually later with the displayed command

> ⚠️ **DO NOT modify the `.cast` file** after generation - the signature becomes invalid!

---

*By Revolvix for OPERATING SYSTEMS class | restricted licence 2017-2030*
