# S05_TC03 - Robustness in Bash Scripts

> **Operating Systems** | ASE Bucharest - CSIE  
> Laboratory material - Seminar 5 (SPLIT from TC6b)

---

> 🚨 **BEFORE STARTING THE ASSIGNMENT**
>
> 1. Download and configure the `002HWinit` package (see STUDENT_GUIDE_EN.md)
> 2. Open a terminal and navigate to `~/HOMEWORKS`
> 3. Start recording with:
>    ```bash
>    python3 record_homework_tui_EN.py
>    ```
>    or the Bash version:
>    ```bash
>    ./record_homework_EN.sh
>    ```
> 4. Complete the requested data (name, group, assignment number)
> 5. **ONLY THEN** begin solving the requirements below

---

## Objectives

At the end of this lab, the student will be able to:
- Use `set -euo pipefail` for safe scripts
- Configure IFS for safe processing
- Implement defensive checks
- Write code that handles edge cases

---


## 2. IFS (Internal Field Separator)

### 2.1 The Problem

```bash
# Default IFS includes space
text="one two three"
for word in $text; do
    echo "$word"
done
# Output: one, two, three (separated)
```

### 2.2 Safe IFS

```bash
#!/bin/bash
IFS=$'\n\t'  # Only newline and tab as separators

# Now spaces NO LONGER separate
text="one two three"
for word in $text; do
    echo "$word"
done
# Output: "one two three" (as a single element)
```

### 2.3 Temporary IFS

```bash
# Save and restore
OLD_IFS="$IFS"
IFS=','
# ... operations
IFS="$OLD_IFS"

# Or with subshell
(IFS=','; read -ra arr <<< "a,b,c"; echo "${arr[@]}")
```

---

## 3. Defensive Checks

### 3.1 Argument Verification

```bash
#!/bin/bash
set -euo pipefail

# Check number of arguments
if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <filename>" >&2
    exit 1
fi

# Alternative with pattern
[[ $# -ge 1 ]] || { echo "Usage: $0 <filename>" >&2; exit 1; }

# With message in variable
FILENAME="${1:?Error: filename required}"
```

### 3.2 File Verification

```bash
#!/bin/bash
set -euo pipefail

FILE="$1"

# Existence
[[ -e "$FILE" ]] || { echo "Error: $FILE doesn't exist" >&2; exit 1; }

# Is a file (not directory)
[[ -f "$FILE" ]] || { echo "Error: $FILE is not a file" >&2; exit 1; }

# Readable
[[ -r "$FILE" ]] || { echo "Error: Cannot read $FILE" >&2; exit 1; }

# Writable
[[ -w "$FILE" ]] || { echo "Error: Cannot write to $FILE" >&2; exit 1; }

# Non-empty
[[ -s "$FILE" ]] || { echo "Warning: $FILE is empty" >&2; }
```

### 3.3 Directory Verification

```bash
#!/bin/bash
set -euo pipefail

DIR="${1:?Error: directory required}"

# Existence and type
[[ -d "$DIR" ]] || { echo "Error: $DIR is not a directory" >&2; exit 1; }

# Create if doesn't exist
mkdir -p "$DIR"

# With verification
if ! mkdir -p "$DIR" 2>/dev/null; then
    echo "Error: Cannot create $DIR" >&2
    exit 1
fi
```

### 3.4 Command Verification

```bash
#!/bin/bash
set -euo pipefail

# Check if command exists
command -v jq >/dev/null 2>&1 || { 
    echo "Error: jq is required but not installed" >&2
    exit 1
}

# Alternative
if ! type -P docker &>/dev/null; then
    echo "Error: docker not found" >&2
    exit 1
fi

# Check multiple commands
for cmd in git curl jq; do
    command -v "$cmd" >/dev/null 2>&1 || {
        echo "Error: $cmd is required" >&2
        exit 1
    }
done
```

---

## 4. Defensive Patterns

### 4.1 The `die` Function

```bash
#!/bin/bash
set -euo pipefail

die() {
    echo "FATAL: $*" >&2
    exit 1
}

# Usage
[[ -f config.txt ]] || die "config.txt not found"
[[ -n "$API_KEY" ]] || die "API_KEY not set"
```

### 4.2 Input Validation

```bash
#!/bin/bash
set -euo pipefail

validate_port() {
    local port="$1"
    [[ "$port" =~ ^[0-9]+$ ]] || die "Port must be numeric: $port"
    (( port >= 1 && port <= 65535 )) || die "Port out of range: $port"
}

validate_email() {
    local email="$1"
    [[ "$email" =~ ^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$ ]] || \
        die "Invalid email: $email"
}

validate_port "$PORT"
validate_email "$EMAIL"
```

### 4.3 Safe Defaults

```bash
#!/bin/bash
set -euo pipefail

# Variables with defaults
CONFIG_FILE="${CONFIG_FILE:-/etc/app/config.conf}"
LOG_LEVEL="${LOG_LEVEL:-INFO}"
MAX_RETRIES="${MAX_RETRIES:-3}"
TIMEOUT="${TIMEOUT:-30}"

# Required variables (fail if not set)
DB_HOST="${DB_HOST:?Error: DB_HOST must be set}"
DB_PASSWORD="${DB_PASSWORD:?Error: DB_PASSWORD must be set}"
```

### 4.4 Correct Quoting

```bash
#!/bin/bash
set -euo pipefail

# ALWAYS quote variables
file="my file with spaces.txt"

# WRONG
rm $file        # Tries to delete "my", "file", "with", "spaces.txt"

# CORRECT
rm "$file"      # Deletes "my file with spaces.txt"

# Arrays - use @
files=("file 1.txt" "file 2.txt")

# WRONG
for f in ${files[*]}; do echo "$f"; done

# CORRECT
for f in "${files[@]}"; do echo "$f"; done
```

---

## 5. Temporary Disabling

### 5.1 For One Command

```bash
#!/bin/bash
set -euo pipefail

# Command that might fail
set +e
result=$(might_fail 2>&1)
status=$?
set -e

if [[ $status -ne 0 ]]; then
    echo "Command failed: $result"
fi

# Alternative with ||
might_fail || true
might_fail || echo "Failed but continuing"
```

### 5.2 For Undefined Variables

```bash
#!/bin/bash
set -euo pipefail

# Check optional variable
if [[ -n "${OPTIONAL_VAR:-}" ]]; then
    echo "OPTIONAL_VAR is set to: $OPTIONAL_VAR"
fi

# Or
set +u
if [[ -n "$OPTIONAL_VAR" ]]; then
    # ...
fi
set -u
```

---

## 6. Exercises

### Exercise 1
Write a script that validates all dependencies (curl, jq, git) are installed.

### Exercise 2
Create a script that receives a path as argument and verifies it's a readable, non-empty file.

### Exercise 3
Implement a script with required variables ($DB_HOST) and optional ones ($LOG_LEVEL with default).

---

## Cheat Sheet

```bash
# STANDARD OPTIONS
set -euo pipefail
IFS=$'\n\t'

# FILE CHECKS
[[ -e "$f" ]]     # exists
[[ -f "$f" ]]     # is file
[[ -d "$f" ]]     # is directory
[[ -r "$f" ]]     # readable
[[ -w "$f" ]]     # writable
[[ -s "$f" ]]     # non-empty

# COMMAND CHECKS
command -v cmd >/dev/null 2>&1

# VARIABLES WITH DEFAULTS
"${VAR:-default}"           # default if VAR is empty/undefined
"${VAR:?Error message}"     # error if VAR is empty/undefined

# TEMPORARY DISABLING
set +e; cmd; status=$?; set -e
cmd || true

# DIE PATTERN
die() { echo "FATAL: $*" >&2; exit 1; }
```

---

## 📤 Completion and Submission

After completing all requirements:

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
