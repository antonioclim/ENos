# S05 Homework Rubric

> **Operating Systems** | ASE Bucharest - CSIE  
> Seminar 05: Advanced Bash Scripting

---

## Assignment Overview

| ID | Topic | Duration | Difficulty |
|----|-------|----------|------------|
| S05a | Prerequisite Review | 30 min | ⭐ |
| S05b | Advanced Functions | 50 min | ⭐⭐⭐ |
| S05c | Bash Arrays | 45 min | ⭐⭐⭐ |
| S05d | Script Robustness | 50 min | ⭐⭐⭐ |
| S05e | Trap and Error Handling | 45 min | ⭐⭐⭐ |
| S05f | Logging and Debug | 40 min | ⭐⭐ |

---

## S05a - Prerequisite Review (10 points)

| Criterion | Points | Requirements |
|-----------|--------|--------------|
| Variables review | 2.5 | Local, environment, special |
| Control structures | 2.5 | if, for, while, case |
| Text processing | 2.5 | grep, sed, awk basics |
| File operations | 2.5 | Redirection, pipes |

---

## S05b - Advanced Functions (10 points)

| Criterion | Points | Requirements |
|-----------|--------|--------------|
| Function definition | 2.0 | Two syntax forms |
| Local variables | 2.0 | local keyword |
| Return values | 2.0 | return, $?, command sub |
| Parameters | 2.0 | $1, $@, shift |
| Recursion | 2.0 | Recursive function example |

### Expected Code
```bash
function greet() {
    local name="${1:-World}"
    echo "Hello, $name!"
    return 0
}

factorial() {
    local n=$1
    if (( n <= 1 )); then
        echo 1
    else
        local prev=$(factorial $((n-1)))
        echo $((n * prev))
    fi
}
```

---

## S05c - Bash Arrays (10 points)

| Criterion | Points | Requirements |
|-----------|--------|--------------|
| Indexed arrays | 2.5 | Declaration, access |
| Array operations | 2.5 | Append, slice, length |
| Associative arrays | 2.5 | declare -A, keys, values |
| Iteration | 2.5 | for loops over arrays |

### Expected Code
```bash
# Indexed array
fruits=("apple" "banana" "cherry")
echo "${fruits[0]}"
echo "${fruits[@]}"
echo "${#fruits[@]}"

# Associative array
declare -A user
user[name]="John"
user[age]=25
for key in "${!user[@]}"; do
    echo "$key: ${user[$key]}"
done
```

---

## S05d - Script Robustness (10 points)

| Criterion | Points | Requirements |
|-----------|--------|--------------|
| Strict mode | 3.0 | set -euo pipefail |
| Input validation | 2.5 | Check args, files, perms |
| Quoting | 2.5 | Proper variable quoting |
| Temporary files | 2.0 | mktemp, cleanup |

### Expected Code
```bash
#!/bin/bash
set -euo pipefail

# Input validation
if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <filename>" >&2
    exit 1
fi

if [[ ! -f "$1" ]]; then
    echo "Error: File not found: $1" >&2
    exit 1
fi

# Safe temporary file
tmpfile=$(mktemp)
trap 'rm -f "$tmpfile"' EXIT
```

---

## S05e - Trap and Error Handling (10 points)

| Criterion | Points | Requirements |
|-----------|--------|--------------|
| Trap basics | 2.5 | trap 'cmd' SIGNAL |
| Common signals | 2.5 | EXIT, INT, TERM, ERR |
| Cleanup patterns | 2.5 | Resource cleanup |
| Error functions | 2.5 | Custom error handlers |

### Expected Code
```bash
#!/bin/bash
set -euo pipefail

cleanup() {
    echo "Cleaning up..."
    rm -f "$tmpfile"
}

error_handler() {
    echo "Error on line $1" >&2
    exit 1
}

trap cleanup EXIT
trap 'error_handler $LINENO' ERR

tmpfile=$(mktemp)
# ... rest of script
```

---

## S05f - Logging and Debug (10 points)

| Criterion | Points | Requirements |
|-----------|--------|--------------|
| Debug mode | 2.5 | set -x, bash -x |
| Logging functions | 2.5 | log_info, log_error |
| Log levels | 2.5 | DEBUG, INFO, WARN, ERROR |
| Log files | 2.5 | Redirect, rotate |

### Expected Code
```bash
#!/bin/bash

LOG_LEVEL=${LOG_LEVEL:-INFO}
LOG_FILE=${LOG_FILE:-/var/log/script.log}

log() {
    local level=$1
    shift
    local msg="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $msg" | tee -a "$LOG_FILE"
}

log_debug() { [[ "$LOG_LEVEL" == "DEBUG" ]] && log "DEBUG" "$@"; }
log_info()  { log "INFO" "$@"; }
log_warn()  { log "WARN" "$@"; }
log_error() { log "ERROR" "$@" >&2; }
```

---

*By Revolvix for OPERATING SYSTEMS class | restricted licence 2017-2030*
