# S03_TC02 - Advanced Xargs

> **Evidence limit:** local recordings, logs and hashes can support review of a submitted session; they do not prove authorship, uninterrupted capture or the absence of edited/omitted activity. Privacy, retention and assessment consequences remain subject to the approved course policy.

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

Filesystem mutations below are exercises for a fresh owned workspace containing
only disposable fixtures. `-I` and `-P` are compatible in GNU xargs. Both xargs and
`find -exec ... {} +` may create multiple size-bounded batches, so never use them to
repeatedly create (`tar -c`) the same archive; use one `tar --null -T -` invocation.
Command-specific failures and concurrent output still require explicit handling.

### 2.1 Syntax

```bash
producer_command | xargs [options] consumer_command
```

### 2.2 Simple Examples

```bash
# Delete files
find . -type f -name "*.tmp" -print0 | xargs -0 -r rm

# Count lines
find . -type f -name "*.py" -print0 | xargs -0 -r wc -l

# Search text in files
find . -type f -name "*.c" -print0 | xargs -0 -r grep "main"

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
find . -type f -name "*.txt" -print0 | xargs -0 -r -I{} cp {} backup/
# Becomes: cp file1.txt backup/
#          cp file2.txt backup/

# With custom placeholder
find . -type f -name "*.jpg" -print0 | xargs -0 -r -IFILE convert FILE FILE.png

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
find . -type f -name "*.log" -print0 | xargs -0 -r -n 100 gzip

# Individual processing
cat urls.txt | xargs -n 1 wget
```

### 3.3 Parallel Processing `-P`

```bash
# At most N concurrent children; enough input batches are needed
find . -type f -name "*.jpg" -print0 | xargs -0 -r -P 4 -I{} convert {} {}.png

# Parallel download
cat urls.txt | xargs -P 10 -n 1 wget

# Parallel compression
find . -type f -name "*.log" -print0 | xargs -0 -r -P $(nproc) gzip

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
find . -type f -name "*.txt" -print0 | xargs -0 -r rm --

# Works for ANY filename:
# - Spaces: "my file.txt"
# - Newlines: "line1\nline2.txt"  
# - Special characters: "file;name.txt"
```

### 3.5 Display and Confirmation

```bash
# Display commands (-t = trace)
find . -type f -name "*.tmp" -print0 | xargs -0 -r -t rm
# Shows: rm ./file1.tmp ./file2.tmp

# Interactive confirmation (-p = prompt)
find . -type f -name "*.bak" -print0 | xargs -0 -r -p rm
# Asks: rm ./file.bak ?...
```

### 3.6 Command Size Limit `-s`

```bash
# Byte-size limit per command line (includes command/arguments and terminators)
find . -type f -name "*.log" -print0 | xargs -0 -r -s 1024 cat

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

# find -exec {} + - Simple batching, also safe for spaces/newlines in names
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
# Preview matching paths; GNU grep -Z emits NUL-terminated filenames.
# grep status 1 means no matches, not a read error. Inspect errors before an action.
find . -type f -name '*.log' -mtime +7 -print0 |
    xargs -0 -r grep -lZ 'ERROR' |
    xargs -0 -r -I{} printf 'Candidate: %s\n' '{}'
# To move, preserve relative paths in a fresh destination and reject collisions.
# Do not flatten equal basenames into an existing errors/ directory.
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
find . -type f -name "*.tmp" -print0 | xargs -0 -r echo

# Verbose mode
find . -type f -name "*.tmp" -print0 | xargs -0 -r -t rm

# Custom dry-run
find . -type f -name "*.tmp" -print0 | xargs -0 -r -I{} echo "Would delete: {}"
```

### 6.2 Common Problems

| Problem | Cause | Solution |
|---------|-------|----------|
| `xargs: argument line too long` | Too many arguments | Use `-n` or `-s` |
| Files with spaces ignored | Default delimiter is space | Use `-print0 \| xargs -0` |
| Command runs once on empty stdin | GNU xargs default empty invocation | Add `-r` to suppress that invocation; it does not make a command run |
| Mixed output (parallel) | Concurrent processes | Use per-job output files and merge afterwards, or reduce `-P`; GNU xargs has no `--line-buffer` option |

### 6.3 Input Verification

```bash
# Check what xargs receives
find . -name "*.txt" | head -5 | cat -A
# $ = end of line, ^I = tab, etc.

# Test with echo before dangerous command
find . -type f -name "*.bak" -print0 | xargs -0 -r echo rm
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
cmd | xargs -P 4              # At most 4 concurrent children
cmd | xargs -P $(nproc)       # At most the available nproc count of concurrent children

# DEBUG
cmd | xargs -t action         # display command
cmd | xargs -p action         # interactive confirmation
cmd | xargs echo              # dry-run

# FREQUENT COMBINATIONS
find . -type f -name "*.x" -print0 | xargs -0 -r rm --
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
   - Finalise the legacy recorder metadata envelope (not a content signature)
   - Automatically upload the file to the server

3. **Check the final message**:
   - ✅ `UPLOAD SUCCESSFUL!` - the assignment was submitted
   - ❌ If upload fails, the `.cast` file is saved locally - send it manually later with the displayed command

> Keep the original `.cast` as evidence. The distributed recorder envelopes do not
> bind event content and do not authenticate the student. Local preflight exit 0
> establishes format only (`UNVERIFIED` authentication, `UNCONFIRMED` readiness).
> The separate SEM07 `# SIGNATURE:` contract binds a content digest only when it
> verifies with an explicitly supplied key; identity and institutional acceptance
> still require an approved protocol. See the [current recording contract](../../../03_GUIDES/RECORDING_CONTRACT.md)
> and [verification contract](../../../SEM07/homework_evaluation/VERIFICATION_AND_GRADING_CONTRACT.md).

---

*By Revolvix for OPERATING SYSTEMS class | restricted licence 2017-2030*
