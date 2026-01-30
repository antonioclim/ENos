# S04_TC02 - The GREP Family - Text Searching

> **Operating Systems** | ASE Bucharest - CSIE  
> Laboratory Material - Seminar 4 (Redistributed)

---

> 🚨 **BEFORE STARTING THE ASSIGNMENT**
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
> 4. Complete the requested data (name, group, assignment number)
> 5. **ONLY THEN** start solving the requirements below

---

## Objectives

At the end of this laboratory, the student will be able to:
- Search efficiently in text files with grep
- Use regular expressions in searches
- Combine grep with other commands in pipelines
- Choose the appropriate variant (grep, egrep, fgrep)

---


## 2. Basic Syntax

```bash
grep [options] 'pattern' [files]
grep [options] -e 'pattern1' -e 'pattern2' [files]
grep [options] -f pattern_file [files]
```

---

## 3. Main Options

### 3.1 Matching Options

```bash
-i, --ignore-case       # Case-insensitive
-w, --word-regexp       # Whole word
-x, --line-regexp       # Entire line
-v, --invert-match      # Invert (lines that do NOT contain)
-e PATTERN              # Multiple patterns
-f FILE                 # Patterns from file
```

### 3.2 Output Options

```bash
-n, --line-number       # Display line numbers
-c, --count             # Count matches
-l, --files-with-matches    # Only file names with matches
-L, --files-without-match   # Files WITHOUT matches
-o, --only-matching     # Display only the matching part
-m NUM                  # Stop after NUM matches
-q, --quiet             # Silent (only exit code)
```

### 3.3 Context Options

```bash
-A NUM, --after-context=NUM     # NUM lines after match
-B NUM, --before-context=NUM    # NUM lines before match
-C NUM, --context=NUM           # NUM lines before and after
```

### 3.4 File Options

```bash
-r, --recursive         # Search recursively in directories
-R, --dereference-recursive  # Recursive, follow symlinks
--include=GLOB          # Only files that match
--exclude=GLOB          # Exclude files
--exclude-dir=DIR       # Exclude directories
```

---

## 4. Practical Examples

### 4.1 Basic Searches

```bash
# Simple search
grep 'error' log.txt

# Case-insensitive
grep -i 'error' log.txt

# Whole word
grep -w 'the' text.txt          # does not find "there", "other"

# Lines that do NOT contain pattern
grep -v 'debug' log.txt

# With line numbers
grep -n 'error' log.txt
```

### 4.2 Multiple Patterns

```bash
# With -e
grep -e 'error' -e 'warning' log.txt

# With ERE and |
grep -E 'error|warning|fatal' log.txt

# From file
echo -e "error\nwarning" > patterns.txt
grep -f patterns.txt log.txt
```

### 4.3 Context

```bash
# 3 lines after match
grep -A 3 'Exception' log.txt

# 2 lines before
grep -B 2 'Error' log.txt

# 2 lines before and after
grep -C 2 'failure' log.txt
```

### 4.4 Recursive Search

```bash
# Recursive in all files
grep -r 'TODO' .

# Only in .py files
grep -r --include='*.py' 'import' .

# Exclude directories
grep -r --exclude-dir='.git' --exclude-dir='node_modules' 'pattern' .

# Only file names
grep -rl 'pattern' .
```

### 4.5 Counting and Statistics

```bash
# Number of matches
grep -c 'error' log.txt

# Number of matches per file
grep -c 'error' *.log

# Files with matches
grep -l 'error' *.log

# Files without matches
grep -L 'error' *.log
```

---

## 5. Regex Patterns in GREP

### 5.1 BRE (Basic)

```bash
grep '^Start' file.txt          # starts with "Start"
grep 'end$' file.txt            # ends with "end"
grep '^$' file.txt              # empty lines
grep 'a.*b' file.txt            # a, anything, b
grep '[0-9]' file.txt           # contains digit
grep 'ab\+c' file.txt           # ab+c (escape for +)
```

### 5.2 ERE (Extended)

```bash
grep -E 'ab+c' file.txt         # ab+c
grep -E 'colou?r' file.txt      # color or colour
grep -E '(error|warn)' file.txt # error or warn
grep -E '[0-9]{3}' file.txt     # 3 consecutive digits
grep -E '\b[A-Z]+\b' file.txt   # words in uppercase
```

### 5.3 Useful Examples

```bash
# Email
grep -E '[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}' file.txt

# IP Address
grep -E '([0-9]{1,3}\.){3}[0-9]{1,3}' log.txt

# URL
grep -E 'https?://[^ ]+' file.txt

# Lines with comments (# or //)
grep -E '^[[:space:]]*(#|//)' code.txt
```

---

## 6. Grep in Pipelines

```bash
# Filter output
ps aux | grep nginx
dmesg | grep -i error

# Combine with other commands
cat access.log | grep '404' | wc -l
grep -l 'pattern' *.txt | xargs rm

# Extract and count
grep -oE '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' access.log | sort | uniq -c | sort -rn

# Exclude grep processes from ps
ps aux | grep '[n]ginx'         # [n]ginx does not match "grep nginx"
```

---

## 7. Exit Codes

```bash
# Exit codes
# 0 - found matches
# 1 - did not find matches
# 2 - error

# Usage in scripts
if grep -q 'pattern' file.txt; then
    echo "Found"
else
    echo "Not found"
fi
```

---

## 8. Practical Exercises

### Exercise 1: Basic Searches
```bash
# Find lines with "error" (case-insensitive)
grep -i 'error' /var/log/syslog

# Count how many errors there are
grep -ci 'error' /var/log/syslog

# Display 3 lines of context
grep -C 3 -i 'error' /var/log/syslog
```

### Exercise 2: Code Search
```bash
# Find all functions in Python files
grep -rn 'def ' --include='*.py' .

# TODOs and FIXMEs
grep -rn -E '(TODO|FIXME)' --include='*.py' .
```

### Exercise 3: Log Analysis
```bash
# Top 10 IPs from access.log
grep -oE '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' access.log | sort | uniq -c | sort -rn | head -10
```

---

## Cheat Sheet

```bash
# MATCHING
-i          case-insensitive
-w          whole word
-x          entire line
-v          invert
-e PATTERN  multiple patterns

# OUTPUT
-n          line numbers
-c          count
-l          only files with match
-L          files without match
-o          match only

# CONTEXT
-A N        N lines after
-B N        N lines before
-C N        N lines context

# FILES
-r          recursive
--include=  only certain files
--exclude=  exclude files

# REGEX TYPES
grep        BRE
grep -E     ERE (egrep)
grep -F     fixed string (fgrep)
grep -P     PCRE

# EXAMPLES
grep -rn 'pattern' .
grep -E 'a|b|c' file
grep -v '^#' config
grep -c 'error' *.log
```

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
   - ✅ `UPLOAD SUCCESSFUL!` - the assignment has been submitted
   - ❌ If the upload fails, the `.cast` file is saved locally - submit it manually later with the displayed command

> ⚠️ **DO NOT modify the `.cast` file** after generation - the signature becomes invalid!

---

*By Revolvix for OPERATING SYSTEMS class | restricted licence 2017-2030*
