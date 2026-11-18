# Seminar 3 Assignment: System Administrator Toolkit

> **Assessment contract pending.** Consult [the assessment status and author decision](ASSESSMENT_STATUS.md) before treating any weights, penalties or eligibility rules below as adopted. The tools provide diagnostics, not a final grade.
## Operating Systems | Bucharest UES - CSIE

**Version**: 1.0 | **Deadline**: [To be completed by instructor]  
**Total marks**: 100% + 20 bonus  
**Estimated time**: 4-6 hours

---

## Table of Contents

1. [Objectives and Competencies](#objectives-and-competencies)
2. [Submission Instructions](#submission-instructions)
3. [Part 1: Find Master](#part-1-find-master-20)
4. [Part 2: Professional Script](#part-2-professional-script-30)
5. [Part 3: Permission Manager](#part-3-permission-manager-25)
6. [Part 4: Cron Jobs](#part-4-cron-jobs-15)
7. [Part 5: Integration Challenge](#part-5-integration-challenge-10)
8. [Bonuses](#bonuses-up-to-20-extra)
9. [Evaluation Criteria](#evaluation-criteria)
10. [Permitted Resources](#permitted-resources)

---

## Objectives and Competencies

Upon completing this assignment, you will demonstrate that you can:

### APPLICATION Level (Anderson-Bloom)
- ✅ Construct complex `find` commands with multiple criteria and actions
- ✅ Use `xargs` for efficient batch processing
- ✅ Write scripts that accept arguments and options using `getopts`
- ✅ Calculate and apply permissions in octal and symbolic format
- ✅ Configure `cron jobs` with logging and error handling

### ANALYSIS Level
- ✅ Diagnose permission problems in a directory structure
- ✅ Identify security risks in permission configurations
- ✅ Evaluate the efficiency of different search and processing approaches

### CREATION Level
- ✅ Design professional scripts with a complete CLI interface
- ✅ Implement robust automation solutions
- ✅ Integrate multiple concepts into a coherent solution

---

## Submission Instructions

### Archive Structure

Submit an archive `tema_sem03_SURNAME_FIRSTNAME.tar.gz` with the structure:

```
tema_sem03_SURNAME_FIRSTNAME/
├── README.md                    # Personal documentation
├── parte1_find/
│   └── comenzi_find.sh          # Script with all find commands
├── parte2_script/
│   ├── fileprocessor.sh         # Main script
│   └── test_fileprocessor.sh    # Test script (optional)
├── parte3_permissions/
│   ├── permaudit.sh             # Permission audit script
│   └── raport_demo.txt          # Example generated report
├── parte4_cron/
│   ├── cron_entries.txt         # Crontab lines
│   └── backup_script.sh         # Referenced backup script
└── parte5_integration/
    └── sysadmin_toolkit.sh      # Integrated script
```

### Commands for Creating Archive

```bash
# Create the structure
mkdir -p tema_sem03_SURNAME_FIRSTNAME/{parte1_find,parte2_script,parte3_permissions,parte4_cron,parte5_integration}

# After completing all files:
cd ~
tar -czvf tema_sem03_SURNAME_FIRSTNAME.tar.gz tema_sem03_SURNAME_FIRSTNAME/

# Verify contents:
tar -tzvf tema_sem03_SURNAME_FIRSTNAME.tar.gz
```

### Important Rules

1. **All scripts** must be executable (`chmod +x`)
2. **All scripts** must have the correct shebang (`#!/bin/bash`)
3. **Test** everything before submission on Ubuntu 24.04 / WSL2
4. DO NOT include large binary files or generated directories
5. **Comment** your code for clarity

---

## ⚠️ AI-Assistance Policy and Verification

### The Reality

You're going to use ChatGPT or similar tools. I know it. You know it. Let's be adults about this.

**What's allowed:**
- Using AI to explain concepts you don't understand
- Getting syntax reminders ("how does getopts work again?")
- Debugging help ("why does this error appear?")

**What defeats the purpose:**
- Pasting the entire assignment and submitting whatever comes back
- Not understanding what your own code does

### Mandatory Development Log

Every script must include a development log in the header. The historical -10% deduction is **unapplied pending the canonical policy**; a log is self-declared process evidence, not proof of authorship.

```bash
#!/bin/bash
# ═══════════════════════════════════════════════════════════════
# fileprocessor.sh - Assignment Part 2
# Author: [Your Name]
# Student ID: [Your ID]
# 
# DEVELOPMENT LOG:
# 2025-01-28 14:30 - Started with getopts template from lecture
# 2025-01-28 15:45 - Stuck on OPTARG, asked ChatGPT for clarification
# 2025-01-28 16:00 - Quoted "$OPTARG" when passing it as a command argument
# 2025-01-29 09:00 - Added verbose mode, tested with sample files
# 2025-01-29 10:30 - Fixed bug where -n 0 was accepted (should error)
# ═══════════════════════════════════════════════════════════════
```

A development log supports a technical conversation. It does not independently establish who produced the code or whether the log is complete.

### Live Verification Questions

During lab or oral examination, be prepared to answer questions like:

1. **"Explain line X"** — Point to any line in your script, explain what it does
2. **"What if I change..."** — Predict what happens if we modify one parameter
3. **"Why not use Y?"** — Justify your choice over an alternative approach
4. **"What error would appear if..."** — Demonstrate debugging knowledge

**Example questions for this assignment:**

| Part | Question you might be asked |
|------|----------------------------|
| Part 1 | "Your find uses -mtime +7. What changes if we use -mmin instead?" |
| Part 2 | "In your getopts string 'hvo:', what does the colon mean?" |
| Part 3 | "You set permissions 755. What happens to the file if we use 754?" |
| Part 4 | "Your cron runs at */15. List the exact times it runs in one hour." |

If you can't answer basic questions about your own code, we have a problem.

### Unique Seed Requirement

Your student ID determines your test directory structure. Use the last 3 digits of your student ID as SEED.

```bash
# Example: Student ID 12345678 → SEED=678
SEED=678

# Your find commands in Part 1 must work with:
mkdir -p ~/sem03_test_${SEED}/{logs,data,temp,archive}
# ... (setup script will create test files)
```

Generic solutions that ignore the SEED will be flagged for review.

---

## Part 1: Find Master (20%)

### Requirement

Create the script `comenzi_find.sh` containing **10 find commands** for the scenarios below. Each command must be functional and commented.

### Scenarios

Assume you are working in the directory `/home/student/proiect/` which has the structure:

```
proiect/
├── src/
│   ├── main.c
│   ├── utils.c
│   ├── utils.h
│   ├── config.h
│   └── deprecated/
│       └── old_main.c
├── docs/
│   ├── README.md
│   ├── manual.pdf
│   ├── notes.txt
│   └── images/
│       ├── logo.png
│       └── diagram.svg
├── build/
│   ├── main.o
│   ├── utils.o
│   └── debug.log
├── tests/
│   ├── test_main.py
│   ├── test_utils.py
│   └── data/
│       ├── input.txt
│       └── expected.txt
├── backup_2024_01.tar.gz
├── backup_2024_02.tar.gz
└── temp_file.tmp
```

### Find Tasks (2p each)

```bash
#!/bin/bash
# Assignment Sem 03 Part 1: Find Master
# Name: [COMPLETE]
# Group: [COMPLETE]

# Create test structure (run once only)
setup_test_structure() {
    mkdir -p ~/proiect/{src/deprecated,docs/images,build,tests/data}
    touch ~/proiect/src/{main.c,utils.c,utils.h,config.h}
    touch ~/proiect/src/deprecated/old_main.c
    touch ~/proiect/docs/{README.md,manual.pdf,notes.txt}
    touch ~/proiect/docs/images/{logo.png,diagram.svg}
    touch ~/proiect/build/{main.o,utils.o,debug.log}
    touch ~/proiect/tests/{test_main.py,test_utils.py}
    touch ~/proiect/tests/data/{input.txt,expected.txt}
    dd if=/dev/zero of=~/proiect/backup_2024_01.tar.gz bs=1M count=5 2>/dev/null
    dd if=/dev/zero of=~/proiect/backup_2024_02.tar.gz bs=1M count=3 2>/dev/null
    touch ~/proiect/temp_file.tmp
    # Set different timestamps
    touch -d "30 days ago" ~/proiect/src/deprecated/old_main.c
    touch -d "7 days ago" ~/proiect/build/debug.log
}

# Task 1: Find all .c files (including in subdirectories)
# Expected result: main.c, utils.c, old_main.c
task1() {
    echo "=== Task 1: .c files ==="
    # COMPLETE THE FIND COMMAND
}

# Task 2: Find all header files (.h) only in src/ (not in subdirectories)
# Hint: use -maxdepth
task2() {
    echo "=== Task 2: .h files in src/ ==="
    # COMPLETE THE FIND COMMAND
}

# Task 3: Find files larger than 1MB
# Expected result: backup_*.tar.gz
task3() {
    echo "=== Task 3: Files > 1MB ==="
    # COMPLETE THE FIND COMMAND
}

# Task 4: Find files modified in the last 7 days
# Hint: -mtime -7
task4() {
    echo "=== Task 4: Modified in the last 7 days ==="
    # COMPLETE THE FIND COMMAND
}

# Task 5: Find all empty directories
# Hint: -type d -empty
task5() {
    echo "=== Task 5: Empty directories ==="
    # COMPLETE THE FIND COMMAND
}

# Task 6: Find .py OR .c files (use -o)
task6() {
    echo "=== Task 6: .py or .c files ==="
    # COMPLETE THE FIND COMMAND
}

# Task 7: Find temporary files (.tmp, .log, .o) and display size
# Hint: -printf '%s %p\n'
task7() {
    echo "=== Task 7: Temporary files with size ==="
    # COMPLETE THE FIND COMMAND
}

# Task 8: Delete .o files from build/ (with confirmation -ok)
# Trap: Test with echo before rm!
task8() {
    echo "=== Task 8: Delete .o with confirmation ==="
    # COMPLETE THE FIND COMMAND (use -ok for safety)
}

# Task 9: Use xargs to count lines in all .c files
# Hint: find ... | xargs wc -l
task9() {
    echo "=== Task 9: Lines in .c files with xargs ==="
    # COMPLETE THE FIND + XARGS COMMAND
}

# Task 10: Find and archive all .md files in docs.tar.gz
# Hint: feed a complete NUL file list to one GNU tar invocation with --null -T -
task10() {
    echo "=== Task 10: Archive .md with find + one tar invocation ==="
    # COMPLETE THE FIND + TAR COMMAND (do not recreate the same archive in xargs batches)
}

# Run all tasks
main() {
    cd ~/proiect || exit 1
    for i in {1..10}; do
        task$i
        echo ""
    done
}

# Uncomment to run setup (first time only)
# setup_test_structure

# Run tests
main
```

### Evaluation Criteria - Part 1

| Criterion | Points | Description |
|-----------|--------|-------------|
| Correctness | 10% | Commands produce the correct result |
| Syntax | 4% | Correct use of find/xargs options |
| Efficiency | 3% | Optimal approach (e.g., -print0 with xargs -0) |
| Comments | 3% | Clear explanations for each command |

---

## Part 2: Professional Script (30%)

### Requirement

Create the script `fileprocessor.sh` - a professional utility for batch file processing.

### Functional Specifications

```
USAGE:
    fileprocessor.sh [OPTIONS] [FILES...]

DESCRIPTION:
    Processes text files: counts lines, words, characters,
    searches for patterns, or transforms content.

OPTIONS:
    -h, --help          Display this help message
    -v, --verbose       Verbose mode (displays progress)
    -q, --quiet         Quiet mode (errors only)
    -o, --output FILE   Write result to FILE (default: stdout)
    -m, --mode MODE     Processing mode:
                        count   - count lines/words/characters
                        search  - search for pattern
                        upper   - convert to uppercase
                        lower   - convert to lowercase
                        stats   - complete statistics
    -p, --pattern PAT   Pattern for search mode (required if mode=search)
    -r, --recursive     Process directories recursively
    -e, --extension EXT Filter by extension (e.g., .txt)

EXAMPLES:
    fileprocessor.sh -m count file1.txt file2.txt
    fileprocessor.sh -v -m search -p "TODO" -r src/
    fileprocessor.sh -m upper -o output.txt input.txt
    fileprocessor.sh -m stats -e .c src/
```

### Requirements

### Technical Requirements

Linux ignores SUID on interpreter scripts. Inspect mode bits to understand the concept; do not claim that chmod u+s makes a Bash script execute as root. The original security anecdote is historical author commentary, not a demonstrated exploit in this kit.

1. **Argument parsing** with `getopts` for short options
2. **Support for long options** (manual, not external getopt)
3. **Complete and formatted usage() function**
4. **Argument validation**: check mandatory parameters, existing files
5. **Error handling**: clear messages, correct exit codes (0=success, 1=usage error, 2=file error)
6. **Logging** with configurable level (verbose/normal/quiet)

### Script Skeleton

The marked processing functions are student work. They are not complete executable
solutions; complete their bodies and explicit error handling before running a mode.
The supplied parser/control shell must handle paths with spaces and never announce
completion after a failed processing function. No test evidence for unfinished
student implementations is implied.

```bash
#!/bin/bash
#
# fileprocessor.sh - Professional file processing utility
# Author: [YOUR NAME]
# Version: 1.0
# Date: [DATE]
#

set -o nounset  # Error for undefined variables
set -o pipefail  # Preserve upstream failures in the supplied control shell

#
# CONSTANTS AND DEFAULTS
#
readonly VERSION="1.0"
readonly SCRIPT_NAME=$(basename "$0")

# Default values
MODE="count"
VERBOSE=0
QUIET=0
OUTPUT=""
PATTERN=""
RECURSIVE=0
EXTENSION=""

# Exit codes
readonly E_SUCCESS=0
readonly E_USAGE=1
readonly E_FILE=2

#
# HELPER FUNCTIONS
#

# Display message if verbose is enabled
log_verbose() {
    if [[ $VERBOSE -eq 1 ]]; then echo "[INFO] $*" >&2; fi
    return 0
}

# Display error and exit
die() {
    [[ $QUIET -eq 0 ]] && echo "[ERROR] $*" >&2
    exit "${E_FILE}"
}

# Display warning
warn() {
    if [[ $QUIET -eq 0 ]]; then echo "[WARN] $*" >&2; fi
    return 0
}

# Display usage
usage() {
    cat << EOF
USAGE:
    $SCRIPT_NAME [OPTIONS] [FILES...]

DESCRIPTION:
    [COMPLETE DESCRIPTION]

OPTIONS:
    -h, --help          [COMPLETE]
    [ADD ALL OPTIONS]

EXAMPLES:
    $SCRIPT_NAME -m count file.txt
    [ADD MORE EXAMPLES]

VERSION: $VERSION
EOF
}

#
# PROCESSING FUNCTIONS
#

# Processing count mode
process_count() {
    local file="$1"
    # COMPLETE: count lines, words, characters
}

# Processing search mode
process_search() {
    local file="$1"
    local pattern="$2"
    # COMPLETE: search for pattern and display matching lines
}

# Processing upper/lower mode
process_transform() {
    local file="$1"
    local transform="$2"  # "upper" or "lower"
    # COMPLETE: modify content
}

# Processing stats mode
process_stats() {
    local file="$1"
    # COMPLETE: complete statistics (lines, words, characters,
    # longest line, most frequent word, etc.)
}

# Process a single file
process_file() {
    local file="$1"
    
    # Check file existence
    [[ -f "$file" ]] || { warn "Not a file: $file"; return 1; }
    [[ -r "$file" ]] || { warn "Cannot read: $file"; return 1; }
    
    log_verbose "Processing: $file"
    
    case "$MODE" in
        count)  process_count "$file" ;;
        search) process_search "$file" "$PATTERN" ;;
        upper)  process_transform "$file" "upper" ;;
        lower)  process_transform "$file" "lower" ;;
        stats)  process_stats "$file" ;;
        *)      die "Unknown mode: $MODE" ;;
    esac
}

#
# ARGUMENT PARSING
#

parse_args() {
    # Parse long options (convert to short)
    local args=()
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --help)      args+=("-h") ;;
            --verbose)   args+=("-v") ;;
            --quiet)     args+=("-q") ;;
            --output) [[ $# -ge 2 && -n $2 ]] || { echo "Missing --output operand" >&2; exit "$E_USAGE"; }; args+=("-o" "$2"); shift ;;
            --mode) [[ $# -ge 2 && -n $2 ]] || { echo "Missing --mode operand" >&2; exit "$E_USAGE"; }; args+=("-m" "$2"); shift ;;
            --pattern) [[ $# -ge 2 && -n $2 ]] || { echo "Missing --pattern operand" >&2; exit "$E_USAGE"; }; args+=("-p" "$2"); shift ;;
            --recursive) args+=("-r") ;;
            --extension) [[ $# -ge 2 && -n $2 ]] || { echo "Missing --extension operand" >&2; exit "$E_USAGE"; }; args+=("-e" "$2"); shift ;;
            --)          args+=("--"); shift; break ;;
            *)           args+=("$1") ;;
        esac
        shift
    done
    
    # Add remaining arguments
    args+=("$@")
    
    # Reset arguments
    set -- "${args[@]}"
    
    # Parse with getopts
    while getopts ":hvqo:m:p:re:" opt; do
        case $opt in
            h)  usage; exit $E_SUCCESS ;;
            v)  VERBOSE=1 ;;
            q)  QUIET=1 ;;
            o)  OUTPUT="$OPTARG" ;;
            m)  MODE="$OPTARG" ;;
            p)  PATTERN="$OPTARG" ;;
            r)  RECURSIVE=1 ;;
            e)  EXTENSION="$OPTARG" ;;
            :)  die "Option -$OPTARG requires an argument" ;;
            \?) die "Invalid option: -$OPTARG" ;;
        esac
    done
    
    shift $((OPTIND - 1))
    
    # Save remaining files
    FILES=("$@")
}

#
# VALIDATION
#

validate_args() {
    # Check valid mode
    case "$MODE" in
        count|search|upper|lower|stats) ;;
        *) die "Invalid mode: $MODE. Use: count, search, upper, lower, stats" ;;
    esac
    
    # Check pattern for search
    if [[ "$MODE" == "search" && -z "$PATTERN" ]]; then
        die "Search mode requires -p/--pattern"
    fi
    
    # Check that we have files
    if [[ ${#FILES[@]} -eq 0 ]]; then
        die "No files specified for processing"
    fi
    
    # Verbose and quiet are mutually exclusive
    if [[ $VERBOSE -eq 1 && $QUIET -eq 1 ]]; then
        warn "Options -v and -q are mutually exclusive. Using -v."
        QUIET=0
    fi
}

#
# MAIN
#

main() {
    # Parse arguments
    parse_args "$@"
    
    # Validate
    validate_args
    
    log_verbose "Mode: $MODE"
    log_verbose "Files: ${FILES[*]}"
    
    # Stage output in an owned temporary directory. This wrapper must not report
    # completion if a student processing function or a discovery/read operation fails.
    local stage status=0 file f
    stage=$(mktemp -d "${TMPDIR:-/tmp}/enos-fileprocessor.XXXXXX") || exit "$E_FILE"
    trap 'rm -rf -- "$stage"' RETURN
    for file in "${FILES[@]}"; do
        if [[ -d $file && $RECURSIVE -eq 1 ]]; then
            local find_args=("$file" -type f)
            [[ -z $EXTENSION ]] || find_args+=(-name "*$EXTENSION")
            if ! find "${find_args[@]}" -print0 > "$stage/files0"; then status=$E_FILE; break; fi
            while IFS= read -r -d '' f; do
                process_file "$f" >> "$stage/result" || { status=$E_FILE; break; }
            done < "$stage/files0"
        else
            process_file "$file" >> "$stage/result" || status=$E_FILE
        fi
        ((status == 0)) || break
    done
    if ((status)); then
        rm -rf -- "$stage"; trap - RETURN
        echo 'Processing failed; no completed result published' >&2
        exit "$status"
    fi
    [[ -f $stage/result ]] || : > "$stage/result"
    if [[ -n $OUTPUT ]]; then
        (set -C; cat -- "$stage/result" > "$OUTPUT") || status=$E_FILE
    else
        cat -- "$stage/result" || status=$E_FILE
    fi
    rm -rf -- "$stage"; trap - RETURN
    ((status == 0)) || exit "$status"

    log_verbose "Processing complete."
    exit $E_SUCCESS
}

# Run main with all arguments
main "$@"
```

### Evaluation Criteria - Part 2

| Criterion | Points | Description |
|-----------|--------|-------------|
| usage() function | 4% | Complete, formatted, with examples |
| getopts parsing | 6% | All short options work |
| Long options | 4% | --help, --verbose, etc. work |
| Validation | 4% | Checks parameters, files, dependencies |
| Processing modes | 6% | All 5 modes work |
| Error handling | 3% | Clear messages, correct exit codes |
| Logging | 3% | Verbose/quiet work correctly |

---

## Part 3: Permission Manager (25%)

### Requirement

Create the script `permaudit.sh` - a tool for auditing and correcting permissions.

### Specifications

```
USAGE:
    permaudit.sh [OPTIONS] DIRECTORY

DESCRIPTION:
    Analyses permissions of a directory, identifies security
    problems and offers correction options.

OPTIONS:
    -h, --help          Display help
    -v, --verbose       Display all files, not just problems
    -f, --fix           Automatically correct problems (with confirmation)
    -F, --force-fix     Correct without confirmation (DANGEROUS!)
    -r, --report FILE   Save report to FILE
    -s, --standard STD  Verification standard:
                        strict/normal/relaxed - historical unresolved policy names;
                        do not silently map all three to identical modes.
                        Until a policy is supplied, inventory and suggest only.

PROBLEMS DETECTED:
    ⚠️  World-writable files (other-write bit set: final octal digit 2, 3, 6 or 7)
    ⚠️  SUID/SGID on scripts (security risk)
    ⚠️  Executable files that shouldn't be
    ⚠️  Directories without x for owner
    ⚠️  777 files (maximum permissions - DANGEROUS)

GENERATED REPORT:
    - General statistics (total files, directories)
    - List of problems found with severity
    - Correction recommendations
    - Suggested chmod commands
```

### Script Skeleton

```bash
#!/bin/bash
#
# permaudit.sh - Permission auditor with correction functions
# Author: [YOUR NAME]
#

set -o nounset

#
# CONSTANTS
#

readonly SCRIPT_NAME=$(basename "$0")

# Problem severity
readonly SEV_CRITICAL="CRITICAL"
readonly SEV_WARNING="WARNING"
readonly SEV_INFO="INFO"

# Colours for output
readonly RED='\033[0;31m'
readonly YELLOW='\033[0;33m'
readonly GREEN='\033[0;32m'
readonly NC='\033[0m' # No Colour

# Counters
declare -i total_files=0
declare -i total_dirs=0
declare -i problems_critical=0
declare -i problems_warning=0

#
# ANALYSIS FUNCTIONS
#

# Check if file is world-writable
check_world_writable() {
    local file="$1"
    local perms=$(stat -c "%a" "$file")
    # COMPLETE: check if last digit allows write (2, 3, 6, 7)
}

# Check if file has SUID/SGID
check_special_bits() {
    local file="$1"
    # COMPLETE: check special bits
}

# Check if it's 777
check_full_permissions() {
    local file="$1"
    # COMPLETE: check 777
}

# Check if directory has x for owner
check_dir_access() {
    local dir="$1"
    # COMPLETE: check x on directory
}

# Analyse a file/directory
analyse_entry() {
    local entry="$1"
    local issues=()
    
    # COMPLETE: run all checks
    # Add problems found to the issues array
    # Display with corresponding severity and colour
}

#
# CORRECTION FUNCTIONS
#

# Suggest and apply correction
fix_permission() {
    local file="$1"
    local suggested_perm="$2"
    local current_perm=$(stat -c "%a" "$file")
    
    echo "File: $file"
    echo "  Current: $current_perm"
    echo "  Suggested: $suggested_perm"
    
    if [[ $FORCE_FIX -eq 1 ]]; then
        chmod -- "$suggested_perm" "$file" || return 1
        echo "  ✓ Automatically corrected"
    elif [[ $FIX -eq 1 ]]; then
        read -p "  Apply correction? [y/N] " response
        if [[ "$response" =~ ^[Yy] ]]; then
            chmod -- "$suggested_perm" "$file" || return 1
            echo "  ✓ Corrected"
        else
            echo "  ✗ Ignored"
        fi
    else
        echo "  Command: chmod $suggested_perm \"$file\""
    fi
}

#
# REPORT FUNCTIONS
#

generate_report() {
    cat << EOF
═══════════════════════════════════════════════════════════════════
                    PERMISSION AUDIT REPORT
═══════════════════════════════════════════════════════════════════
Analysed directory: $TARGET_DIR
Date: $(date '+%Y-%m-%d %H:%M:%S')
Standard: $STANDARD

STATISTICS:
───────────────────────────────────────────────────────────────────
  Total files:       $total_files
  Total directories: $total_dirs
  
PROBLEMS FOUND:
───────────────────────────────────────────────────────────────────
  Critical:   $problems_critical
  Warning:    $problems_warning

EOF

    # COMPLETE: add detailed list of problems
}

#
# MAIN
#

# COMPLETE:
# 1. Parse arguments
# 2. Validate directory
# 3. Recursive traversal with find or while
# 4. Analyse each entry
# 5. Generate report
# 6. Optional: correct problems

main() {
    # COMPLETE
}

main "$@"
```

### Evaluation Criteria - Part 3

| Criterion | Points | Description |
|-----------|--------|-------------|
| Detect world-writable | 4% | Tests the other-write bit (including 602, 603, 606 and 607) |
| Detect SUID/SGID | 4% | Identifies special bits on scripts |
| Detect 777 | 3% | Flags as critical |
| Formatted report | 4% | Includes statistics, problems, commands |
| Fix function | 5% | Corrects with confirmation |
| Input validation | 3% | Checks valid directory, permissions |
| Coloured output | 2% | Different severities with colours |

---

## Part 4: Cron Jobs (15%)

### Requirement

Create the file `cron_entries.txt` with **5 functional cron jobs** and the referenced `backup_script.sh` script.

### Scenarios for Cron Jobs

```bash
# File: cron_entries.txt
# Format: Crontab line + explanatory comment

#
# JOB 1 (3%): Daily backup at 3:00 AM
#
# Requirement: Run backup_script.sh daily at 3 in the morning
# Must: log output to /var/log/backup.log
# COMPLETE THE CRONTAB LINE:

#
# JOB 2 (3%): Cleanup temporary files
#
# Requirement: Every 6 hours, delete .tmp files older than 24h from /tmp
# Trap: Use find with -mtime, NOT rm -rf
# COMPLETE THE CRONTAB LINE:

#
# JOB 3 (3%): Disk space monitoring
#
# Requirement: Every 30 minutes, check disk space
# If any partition > 90%, send email (or log warning)
# Hint: df -h | awk '...'
# COMPLETE THE CRONTAB LINE:

#
# JOB 4 (3%): Weekly synchronisation
#
# Requirement: Every Sunday at 2:00 AM, synchronise /home/user/docs
# with /backup/docs using rsync
# COMPLETE THE CRONTAB LINE:

#
# JOB 5 (3%): Log rotation
#
# Requirement: On the first day of each month, at midnight,
# compress and archive logs from /var/log/myapp/
# COMPLETE THE CRONTAB LINE:

```

### Backup Script

```bash
#!/bin/bash
# backup_script.sh - Robust backup script for cron
#
# This script is referenced by cron job 1
# Must:
# 1. Have complete logging
# 2. Check that another instance is not already running (lock file)
# 3. Report errors
# 4. Create incremental or full backup

# COMPLETE THE IMPLEMENTATION
```

### Evaluation Criteria - Part 4

| Criterion | Points | Description |
|-----------|--------|-------------|
| Correct syntax | 5% | All crontab lines are valid |
| Logging | 3% | Output correctly redirected (>> log 2>&1) |
| Absolute paths | 3% | All commands with absolute path |
| backup_script.sh | 4% | Functional, with lock file and logging |

---

## Part 5: Integration Challenge (10%)

### Requirement

Create `sysadmin_toolkit.sh` - a script that integrates all concepts into an interactive menu.

### Specifications

```
SYSADMIN TOOLKIT v1.0
═══════════════════════════════════════════════════════════════════

1) 🔍 Find Operations
   - Search files by various criteria
   - Cleanup old files
   - Disk usage statistics

2) 📄 File Processing
   - Count lines/words in files
   - Search pattern in files
   - Text transformations
- Document what you did for future reference

3) 🔐 Permission Manager
   - Audit directory permissions
   - Correct problems
   - Batch permission setting

4) ⏰ Cron Helper
   - List current cron jobs
   - Add new cron job (assisted)
   - Validate cron expression

5) 📊 System Report
   - Generate complete report
   - Include all modules

0) Exit

Select option [0-5]:
```

### Requirements

> Linux ignores SUID on Bash scripts. This exercise does not require privileged execution; use owned fixtures and describe platform restrictions.

- Interactive menu with `select` or `case`
- Each option calls functions from previous scripts or reimplements them
- Include input validation at each step
- Works without sudo for normal operations

### Evaluation Criteria - Part 5

| Criterion | Points | Description |
|-----------|--------|-------------|
| Functional menu | 3% | Correct navigation, exit works |
| Module integration | 4% | Calls functions from other parts |
| User experience | 3% | Clear messages, input validation |

---

## Bonuses (up to 20% extra)

### Bonus B1: Parallelisation (5%)

Implement parallel processing in `fileprocessor.sh`:

```bash
# New option
-j, --jobs N    Number of parallel jobs (default: 1)

# Usage example
./fileprocessor.sh -m stats -j 4 *.txt
```

Use `xargs -P` or `parallel` (if available).

### Bonus B2: Advanced Long Options (5%)

Add support for:

In short: Options with `=`: `--output=file.txt`; Combined options: `-vro output.txt`; Automatic completion (script for bash completion).


### Bonus B3: Atomic Locking (historical 5%, pending policy)

Implement an atomic lock in a private owned state directory, with a documented
wait/timeout policy and cleanup that releases only the lock held by this process.
`kill -0` alone cannot distinguish a stale PID from a reused PID or grant permission
to remove another invocation's lock. Use a descriptor lock (`flock`) or an atomic
lock-directory protocol and explain filesystem assumptions.

```bash
# Skeleton only: choose an existing private WORK_DIR and implement the task body.
: "${WORK_DIR:?Set an owned state directory}"
exec 9>"$WORK_DIR/backup.lock" || exit 1
flock -n 9 || { echo 'Another process holds the lock' >&2; exit 2; }
# COMPLETE: backup with checked statuses; do not unlink this live lock file.
```

---

## Evaluation Criteria

### Points Summary

| Part | Points | Weight |
|------|--------|--------|
| Part 1: Find Master | 20% | 20% |
| Part 2: Professional Script | 30% | 30% |
| Part 3: Permission Manager | 25% | 25% |
| Part 4: Cron Jobs | 15% | 15% |
| Part 5: Integration | 10% | 10% |
| **Total** | **100%** | **100%** |
| Bonuses | +20p | +20% |

### General Criteria

| Criterion | Description | Impact |
|-----------|-------------|--------|
| Functionality | Scripts run correctly | MANDATORY |
| Clean code | Indentation, comments and structure | 10% |
| Error handling | Clear messages and exit codes | 10% |
| Documentation | README, usage and comments | 10% |
| Security | No rm -rf /* and verifications | MANDATORY |

### Penalties

| Problem | Penalty |
|---------|---------|
| Does not compile/run | -50% from that part |
| Missing shebang | -5p per script |
| Non-executable scripts | -5p per script |
| Copied code without understanding | -100% |
| Using chmod 777 as solution | -10p |
| rm -rf without verifications | -10p |

---

## 🔐 VERIFICATION CHALLENGES (Mandatory - 15% of final grade)

> **Why this section exists**: We want to ensure you UNDERSTAND what you submit
> not just that you can produce working code. These are discussion prompts, not a validated method for proving authorship.
> Their weights, eligibility conditions and privacy requirements remain pending policy.

### Challenge V1: Screenshot with Timestamp (5%)

**Requirement**: Run your most complex find command (from Part 1) on YOUR system and provide a screenshot showing:

1. The terminal with the command and output visible
2. Your username in the prompt or output of `whoami`
3. Current date/time (run `date` before your command)

**Submission**: Include `screenshot_v1.png` in your archive.

**What we check**:
- Timestamp must be within 48 hours of submission deadline
- Username must match your submission name
- Output must be consistent with the command shown

**Note**: If the screenshot appears manipulated or inconsistent you will be asked to reproduce the command live during lab hours.

---

### Challenge V2: Debugging Preparation (5%)

**Requirement**: In your README.md include a section titled "Debugging Notes" with:

1. **Three errors you encountered** whilst developing your scripts
   - What was the error message?
   - What caused it?
   - How did you fix it?

2. **Two things you learnt** that were not obvious from the seminar materials
   - Example: "I discovered that xargs -I {} can be combined with -P, but concurrent output may interleave"

**Format**:
```markdown
## Debugging Notes

### Error 1: [Brief description]
- **Error message**: `[exact error text]`
- **Cause**: [your explanation]
- **Fix**: [what you changed]

### Error 2: ...

### Lessons Learnt
1. [First insight]
2. [Second insight]
```

**What we check**:
- Errors must be SPECIFIC to your code (not generic examples)
- Lessons must demonstrate understanding beyond copy-paste

---

### Challenge V3: Oral Verification Readiness (5%)

**Requirement**: Be prepared to explain ANY line of your submitted code during lab hours.

**How it works**:
1. During the next lab session you may be randomly selected
2. You will be asked to explain 3-5 lines from your own submission
3. You must explain WITHOUT looking at documentation or notes

**Example questions**:
- "Your script has `shift $((OPTIND - 1))`. What does this do and why is it needed?"
- "Why did you use `-print0` instead of `-print` in this find command?"
- "What happens if someone runs your script with an invalid permission like `999`?"

**Scoring**:
- Clear and correct explanation: Full marks
- Partially correct: Partial marks
- Cannot explain own code: 0 marks + investigation for academic integrity

---

### Important Notes on Verification

> ⚠️ **AI Usage Policy**
> 
> You MAY use AI tools (ChatGPT, Claude and Copilot) for:
> - Understanding error messages
> - Learning syntax
> - Debugging suggestions
> 
> You MAY NOT use AI tools for:
> - Generating complete solutions
> - Writing code you do not understand
> - Circumventing the verification challenges
> 
> **"I got it from ChatGPT" is not an acceptable explanation** during oral verification.
> If you used AI assistance you must understand the code well enough to explain it yourself.

---

## Permitted Resources

### Documentation
- `man find`, `man xargs`, `man bash`, `man chmod`, `man crontab`
- GNU Coreutils documentation
- Bash Reference Manual
- Course and seminar materials

### Tools
- ShellCheck for syntax checking: `shellcheck script.sh`
- Explainshell.com for understanding commands
- Crontab.guru for validating cron expressions

### NOT permitted
- Copying code from colleagues
- Using AI for complete generation (you can use it for understanding/debugging)
- Scripts downloaded from the internet without adaptation and understanding

---

## Support

### Frequently Asked Questions

**Q: Can I use other shells (zsh, fish)?**  
A: No, the assignment must work in Bash on Ubuntu 24.04.

**Q: Does it need to work on Mac too?**  
A: No, only Ubuntu/WSL2.

**Q: Can I add extra functionality?**  
A: Yes, but ensure the basic requirements are met.

**Q: What do I do if find doesn't find anything?**  
A: Check the path and pattern. Test with simpler options.

### Contact

- Course forum: [LINK]
- Instructor email: [EMAIL]
- Office hours: [SCHEDULE]

---

## Final Checklist

Before submission, verify:

- [ ] All files are in the correct structure
- [ ] All scripts have shebang `#!/bin/bash`
- [ ] All scripts are executable (`chmod +x`)
- [ ] I have tested on Ubuntu 24.04 / WSL2
- [ ] `shellcheck` reports no major errors
- [ ] README.md is completed with personal observations
- [ ] Archive has the correct name: `tema_sem03_SURNAME_FIRSTNAME.tar.gz`
- [ ] I have verified the archive contents before submission

---

*Seminar 3 Assignment | Operating Systems | Bucharest UES - CSIE*
