# Main Material: Utilities, Scripts, Permissions, Automation
## Operating Systems | Bucharest UES - CSIE

> Seminar 3 | Complete theoretical material with Subgoal Labels  
> Version: 1.0 | Date: January 2025

---

## Learning Objectives

At the end of this material, you will be able to:

| Bloom Level | Objective |
|-------------|-----------|
| 🔵 Remember | List the main options of find, chmod and crontab commands |
| 🟢 Understand | Explain the difference between $@ and $*, between find -exec and xargs |
| 🟡 Apply | Build complex find commands and scripts with getopts |
| 🟠 Analyse | Debug problems with permissions and cron jobs |
| 🔴 Evaluate | Criticise and improve commands and scripts |
| 🟣 Create | Develop complete automation solutions |

---

## Contents

1. [Module 1: Advanced Search Utilities](#module-1-advanced-search-utilities)
2. [Module 2: Parameters and Options in Scripts](#module-2-parameters-and-options-in-scripts)
3. [Module 3: The Unix Permissions System](#module-3-the-unix-permissions-system)
4. [Module 4: Automation with Cron](#module-4-automation-with-cron)
5. [Summary and Extended Cheat Sheet](#summary-and-extended-cheat-sheet)

---

# MODULE 1: ADVANCED SEARCH UTILITIES

## 1.1 The find Command - Introduction

### SUBGOAL 1.1.1: Understand the structure of find command

The `find` command is one of the most powerful Unix utilities for searching files. Unlike `ls` which displays the contents of a directory, `find` traverses **recursively** the entire directory hierarchy.

General syntax:
```
find [start_path] [expressions/tests] [actions]
```

Components:

| Component | Description | Examples |
|-----------|-------------|----------|
| `start_path` | Where the search starts | `.`, `/home`, `/var/log` |
| `expressions` | Filtering criteria | `-name`, `-type`, `-size` |
| `actions` | What to do with results | `-print`, `-exec`, `-delete` |

Basic examples:
```bash
# Search in current directory
find . -name "*.txt"

# Search in multiple locations
find /home /var -name "*.log"

# Search entire system (suppress permission errors)
find / -name "config.ini" 2>/dev/null
```

---

## 1.2 find - Basic Tests

### SUBGOAL 1.2.1: Search by name

Name options:

| Option | Description | Example |
|--------|-------------|---------|
| `-name` | Exact match (case-sensitive) | `-name "README.md"` |
| `-iname` | Case-insensitive match | `-iname "readme.md"` |
| `-path` | Match on complete path | `-path "*src/*.c"` |
| `-regex` | Regular expression | `-regex ".*\\.txt$"` |

Wildcards accepted in -name:

| Pattern | Meaning | Example |
|---------|---------|---------|
| `*` | Any number of characters | `*.txt` |
| `?` | Exactly one character | `file?.txt` |
| `[...]` | One character from set | `[abc].txt` |
| `[!...]` | One character NOT in set | `[!0-9].txt` |

```bash
# Practical examples
find . -name "*.txt"           # All .txt files
find . -name "data_*"          # Starts with "data_"
find . -name "*backup*"        # Contains "backup"
find . -iname "README*"        # Case-insensitive

# Search in specific paths
find . -path "*/src/*.c"       # .c files in any src/ directory
find . -path "*/test/*" -name "*.py"  # .py in test/ directories
```

### SUBGOAL 1.2.2: Search by type

File types in Unix:

| Flag | Type | Description |
|------|------|-------------|
| `f` | File | Regular file |
| `d` | Directory | Directory |
| `l` | Symbolic link | Symbolic link |
| `b` | Block device | Block device (disk) |
| `c` | Character device | Character device (terminal) |
| `p` | Named pipe | FIFO |
| `s` | Socket | Unix socket |

```bash
# Examples
find . -type f              # Only files
find . -type d              # Only directories
find . -type l              # Only symlinks

# Common combinations
find . -type f -name "*.sh"  # Shell scripts (files, not directories)
find . -type d -name "test*" # Directories starting with "test"
```

---

## 1.3 find - Advanced Tests

### SUBGOAL 1.3.1: Search by size

Syntax: `-size [+-]N[cwbkMG]`

| Suffix | Unit | Equivalent |
|--------|------|------------|
| `c` | bytes | 1 byte |
| `w` | words | 2 bytes |
| `b` | blocks | 512 bytes (default) |
| `k` | kilobytes | 1024 bytes |
| `M` | megabytes | 1048576 bytes |
| `G` | gigabytes | 1073741824 bytes |

| Prefix | Meaning |
|--------|---------|
| (none) | Exactly N units after rounding the byte size up |
| `+` | Greater than |
| `-` | Less than |

```bash
# Examples
find . -size 100c        # Exactly 100 bytes
find . -size +10M        # Greater than 10 MB
find . -size -1024c      # Fewer than 1024 bytes (exact byte threshold)
find . -size +1G         # Greater than 1 GB

# Size range
find . -size +10M -size -100M   # Rounded MiB count >10 and <100 (bytes >10 MiB and <=99 MiB)

# Empty files
find . -empty                    # Empty files or directories


find . -type f -empty            # Only empty files
find . -type d -empty            # Only empty directories
```

*(`find` combined with `-exec` is extremely useful. Once you master it, you can't do without it.)*

GNU `find` rounds size **up** to the selected unit. Thus `-size -1k` matches only empty files; use `-size -1024c` for byte lengths 0–1023. `M` and `G` are binary MiB/GiB, not decimal MB/GB.

### SUBGOAL 1.3.2: Search by time

Timestamp types in Unix:

| Timestamp | Description | Updated when |
|-----------|-------------|--------------|
| `mtime` | Modification time | Content changes |
| `atime` | Access time | Reads, subject to mount options such as relatime/noatime |
| `ctime` | Inode change time | Metadata changes and writes to file content; not creation time |

Time options:

| Option | Unit | Example |
|--------|------|---------|
| `-mtime N` | Days | `-mtime -7` (last 7 days) |
| `-mmin N` | Minutes | `-mmin -60` (last hour) |
| `-atime N` | Days (access) | `-atime +30` (age at least 31 complete days) |
| `-amin N` | Minutes (access) | `-amin -10` |
| `-ctime N` | Days (change) | `-ctime 0` (last 24 hours) |
| `-newer FILE` | Comparison | Newer than FILE |

```bash
# Examples
find . -mtime 0          # Modified in last 24h
find . -mtime -7         # Modified in last 7 days
find . -mtime +30        # Modification age at least 31 complete days
find . -mmin -60         # Modified in last hour
find . -newer reference.txt  # Newer than reference.txt

# Practical combinations
find /var/log -name "*.log" -mtime +30  # Old logs
find . -type f -mmin -5                  # Recent modifications
```

GNU `find` rounds nonnegative ages **down** to whole units. For days, `-mtime N` selects `[N,N+1)` days, `+N` selects at least `N+1` complete days and `-N` selects less than N days. Calendar-day examples need an explicit boundary (for example GNU `-daystart` before the predicate); the default is relative to the invocation time.

### SUBGOAL 1.3.3: Search by permissions and owner

```bash
# By exact permissions
find . -perm 644          # Exactly 644 (rw-r--r--)
find . -perm 755          # Exactly 755 (rwxr-xr-x)

# By minimum permissions (all specified bits must be set)
find . -perm -644         # At least rw-r--r--
find . -perm -u+x         # Owner has execute

# By any of bits (at least one set)
find . -perm /644         # Owner: rw OR group: r OR others: r
find . -perm /u+x,g+x     # Owner OR group has execute

# By owner
find . -user student      # Files owned by user "student"
find . -group developers  # Files owned by group "developers"
find . -nouser            # Files without valid owner (deleted UID)
find . -nogroup           # Files without valid group
```

---

## 1.4 find - Logical Operators

### SUBGOAL 1.4.1: Combine conditions with AND, OR, NOT

Operators:

| Operator | Syntax | Description |
|----------|--------|-------------|
| AND | (implicit) or `-a` | Both conditions true |
| OR | `-o` | At least one true |
| NOT | `!` or `-not` | Negation |
| Grouping | `\( ... \)` | Priority |

```bash
# Implicit AND
find . -type f -name "*.txt"      # file AND .txt

# Explicit OR (usually requires parentheses)
find . -name "*.txt" -o -name "*.md"
find . \( -name "*.c" -o -name "*.h" \)  # Parentheses correct

# NOT
find . ! -name "*.txt"            # Does NOT have .txt extension
find . -type f ! -name "*.bak"    # Files that are NOT backups

# Complex combinations
find . -type f \( -name "*.txt" -o -name "*.md" \) ! -name "*backup*"
# Explanation: .txt or .md files, BUT not those with "backup" in name
```

**⚠️ Warning about precedence:**
```bash
# WRONG - OR has lower precedence
find . -type f -name "*.txt" -o -name "*.md"
# Interpretation: (type f AND name *.txt) OR (name *.md)
# Result: may return DIRECTORIES .md as well!

# CORRECT
find . -type f \( -name "*.txt" -o -name "*.md" \)
```

---

## 1.5 find - Actions

### SUBGOAL 1.5.1: -print and variants

```bash
# -print (default)
find . -name "*.txt" -print       # Displays paths

# -print0 (for xargs -0)
find . -name "*.txt" -print0      # NULL delimiter (for spaces)

# -printf (custom format)
find . -name "*.txt" -printf "%p %s bytes\n"    # Path and size
find . -name "*.txt" -printf "%f\n"              # Just filename
find . -type f -printf "%m %u %p\n"              # Permissions, owner, path

# Useful printf formats:
# %p = complete path
# %f = just filename
# %s = size in bytes
# %m = octal permissions
# %M = symbolic permissions
# %u = owner (name)
# %g = group (name)
# %T+ = modification timestamp
```

### SUBGOAL 1.5.2: -exec and -ok

-exec executes a command for each file found.

Syntax:
```
-exec command {} \;    # Execute for EACH file (one process per file)
-exec command {} +     # One or more size-bounded argument batches
```

```bash
# With \; - individual execution
find . -name "*.txt" -exec cat {} \;
find . -name "*.sh" -exec chmod +x {} \;

# With + - batch execution (more efficient)
find . -name "*.txt" -exec cat {} +
find . -name "*.log" -exec wc -l {} +

# -ok - like -exec but with confirmation
find . -name "*.bak" -ok rm {} \;
# Asks for EACH file: "rm ... ?"
```

Performance comparison:
```bash
# Slow (100 files = 100 cat processes)
find . -name "*.txt" -exec cat {} \;

# Batched (often 1 process for 100 short names, but more if limits require)
find . -name "*.txt" -exec cat {} +
```

### SUBGOAL 1.5.3: -delete

```bash
# Trap: -delete is permanent and unrecoverable!

# CORRECT: test first with -print
find . -name "*.tmp" -print          # See what it will delete
find . -name "*.tmp" -delete         # Then delete

# WRONG: run -delete directly without verification
find . -name "*.log" -delete         # Dangerous!

# Safe combination with confirmation
find . -name "*.bak" -ok rm -v {} \;
```

---

## 1.6 xargs - Batch Processing

### SUBGOAL 1.6.1: Why xargs?

Both `find -exec ... {} +` and `xargs` build size-bounded batches within command-line limits. They do not promise a single invocation; an individually overlong argument or an execution error can still fail.

Solution: `xargs` reads from stdin and builds commands efficiently.

> 💡 *Personal note: The choice between `find -exec {} \;` and `find | xargs` confuses students every semester. My rule of thumb: use `-exec {} +` for simplicity, use `xargs -0` with `-print0` when its separate batching or parallelism controls are needed. Both this pair and `-exec ... {} +` preserve filename boundaries. Performance depends on the workload; no benchmark is supplied here.*

```bash
# Conceptual difference
echo "file1 file2 file3" | cat       # cat reads STDIN
echo "file1 file2 file3" | xargs cat # cat file1 file2 file3
```

### SUBGOAL 1.6.2: xargs syntax and options

| Option | Description | Example |
|--------|-------------|---------|
| `-n N` | Maximum N arguments per execution | `xargs -n 2` |
| `-I{}` | Custom placeholder | `xargs -I{} cp {} backup/` |
| `-0` | NULL delimiter (for -print0) | `xargs -0` |
| `-P N` | At most N concurrent child processes | `xargs -P 4` |
| `-t` | Display command before execution | `xargs -t` |
| `-p` | Request confirmation | `xargs -p` |

```bash
# Limit arguments
echo "1 2 3 4 5 6" | xargs -n 2 echo
# Output:
# 1 2
# 3 4
# 5 6

# Placeholder
find . -type f -name "*.txt" -print0 | xargs -0 -r -I{} cp -- {} backup/
find . -type f -name "*.jpg" -print0 | xargs -0 -r -I FILE convert FILE FILE.png

# Parallel execution (at most 4 concurrent child processes)
find . -type f -name "*.jpg" -print0 | xargs -0 -r -P 4 -I{} convert {} {}.png

# Verbose (displays command)
find . -type f -name "*.tmp" -print0 | xargs -0 -r -t printf '%s\n'

# With confirmation
find . -type f -name "*.bak" -print0 | xargs -0 -r -p rm --
```

### SUBGOAL 1.6.3: find | xargs combinations

⚠️ The problem of spaces in filenames:

```bash
# WRONG - breaks with spaces
touch "file with spaces.txt"
find . -name "*.txt" | xargs rm
# xargs interprets: rm "file" "with" "spaces.txt"
# Error: files don't exist!

# CORRECT - use -print0 and -0
find . -type f -name "*.txt" -print0 | xargs -0 -r rm --
# -print0: separates with NULL instead of newline
# -0: xargs reads with NULL delimiter
```

Common patterns:
```bash
# Count lines in files
find . -type f -name "*.py" -print0 | xargs -0 -r wc -l

# Search pattern in code
find . -name "*.c" -print0 | xargs -0 grep "main"

# Archive files
find . -type f -name "*.log" -mtime +30 -print0 |
    tar --null -T - -cvf old_logs.tar

# Parallel processing
find . -name "*.mp4" -print0 | xargs -0 -P 4 -I{} ffmpeg -i {} {}.mp3
```

---

## 1.7 locate - Fast Search

### SUBGOAL 1.7.1: Understand the difference locate vs find

| Aspect | locate | find |
|--------|--------|------|
| Speed | Very fast (milliseconds) | Slower (traverses disk) |
| Update | Pre-indexed database | Real time |
| Criteria | Only name/path | Multiple (size, time, perm) |
| Actions | Only display | exec, delete, etc. |

```bash
# Using locate
locate filename              # Search in database
locate -i README             # Case-insensitive
locate -n 10 "*.log"         # First 10 results
locate -c "*.txt"            # Count matches

# Update database (requires root)
sudo updatedb

# When to use locate vs find?
# locate: fast searches by name when you don't care about new files
# find: complex searches, recent files, automatic actions
```

---

# MODULE 2: PARAMETERS AND OPTIONS IN SCRIPTS

## 2.1 Positional Parameters

### SUBGOAL 2.1.1: Basic variables

Special variables for arguments:

| Variable | Description | Example |
|----------|-------------|---------|
| `$0` | Script name | `./script.sh` |
| `$1` - `$9` | Arguments 1-9 | `$1` = first argument |
| `${10}` | Argument 10+ | Requires braces! |
| `$#` | Number of arguments | 3 if you have 3 arguments |
| `$@` | All arguments (as list) | Iteration in for |
| `$*` | All arguments (as string) | Single string |
| `$?` | Exit code of last command | 0 = success |
| `$$` | PID of the invoking Bash shell (unchanged in a subshell) | Use mktemp for unique temporary files |

```bash
#!/bin/bash
# demo_params.sh

echo "Script name: $0"
echo "First argument: $1"
echo "Second argument: $2"
echo "Total number: $#"
echo "All (list): $@"
echo "All (string): $*"

# Run: ./demo_params.sh arg1 arg2 arg3
```

### SUBGOAL 2.1.2: $@ vs $* - the crucial difference

This is one of the most frequent sources of bugs!

```bash
#!/bin/bash
# test_at_vs_star.sh

echo "=== With \"\$@\" (CORRECT for iteration) ==="
for arg in "$@"; do
    echo "Argument: '$arg'"
done

echo ""
echo "=== With \"\$*\" (single string) ==="
for arg in "$*"; do
    echo "Argument: '$arg'"
done
```

Run:
```bash
./test_at_vs_star.sh "hello world" test

# Output:
# === With "$@" (CORRECT for iteration) ===
# Argument: 'hello world'
# Argument: 'test'
#
# === With "$*" (single string) ===
# Argument: 'hello world test'
```

Golden rule: Always use `"$@"` to iterate through arguments!

### SUBGOAL 2.1.3: Arguments over 9

```bash
#!/bin/bash
# Accessing argument 10+

echo "Arg 1: $1"
echo "Arg 10: ${10}"    # CORRECT - with braces
echo "Arg 10: $10"      # WRONG - displays $1 followed by "0"!
```

---

## 2.2 shift - Iterative Processing

### SUBGOAL 2.2.1: Understand and use shift

`shift` removes the first argument and moves all others by one position.

```bash
#!/bin/bash
# demo_shift.sh

echo "Before shift:"
echo "  \$1 = $1"
echo "  \$2 = $2"
echo "  \$# = $#"

shift

echo "After shift:"
echo "  \$1 = $1"    # former $2
echo "  \$2 = $2"    # former $3
echo "  \$# = $#"    # decremented by 1

# Run: ./demo_shift.sh a b c
```

Classic pattern - process all arguments:
```bash
#!/bin/bash
echo "Processing $# arguments:"

while [ $# -gt 0 ]; do
    echo "  Argument: $1"
    shift
done

echo "Done! $# arguments remaining."
```

shift with number:
```bash
shift 2    # Remove first 2 arguments
shift 3    # Remove first 3
```

---

## 2.3 Default Values

### SUBGOAL 2.3.1: Expansions with default

| Syntax | Description | Result |
|--------|-------------|--------|
| `${VAR:-default}` | Use default if VAR is empty/unset | Does not modify VAR |
| `${VAR:=default}` | Set VAR to default if empty/unset | Modifies VAR |
| `${VAR:+alt}` | Use alt if VAR is set and nonempty | - |
| `${VAR:?message}` | Error if VAR is empty/unset | Exit with message |

```bash
#!/bin/bash
# Arguments with default values

INPUT="${1:-input.txt}"      # Default: input.txt
OUTPUT="${2:-output.txt}"    # Default: output.txt
COUNT="${3:-10}"             # Default: 10

echo "Input: $INPUT"
echo "Output: $OUTPUT"
echo "Count: $COUNT"

# Run without arguments: uses defaults
# Run with arguments: uses given values
```

---

## 2.4 getopts - Short Options

### SUBGOAL 2.4.1: getopts syntax

```text
while getopts "optstring" variable; do
    case $variable in
        ...
    esac
done
```

optstring:
- `a` = option `-a` without argument
- `a:` = option `-a` WITH mandatory argument
- `:` at beginning = silent error mode

### SUBGOAL 2.4.2: OPTARG and OPTIND

| Variable | Description |
|----------|-------------|
| `$opt` | Letter of current option |
| `$OPTARG` | Value of option argument |
| `$OPTIND` | Index of next argument to process |

```bash
#!/bin/bash
# script_getopts.sh

VERBOSE=false
OUTPUT=""
COUNT=1

usage() {
    echo "Usage: $0 [-h] [-v] [-o FILE] [-c NUM] file..."
    exit 1
}

while getopts ":hvo:c:" opt; do
    case $opt in
        h) usage ;;
        v) VERBOSE=true ;;
        o) OUTPUT="$OPTARG" ;;
        c) COUNT="$OPTARG" ;;
        :) echo "Error: -$OPTARG requires argument"; exit 1 ;;
        \?) echo "Error: unknown option -$OPTARG"; exit 1 ;;
    esac
done

# Remove processed options
shift $((OPTIND - 1))

# Now $@ contains only remaining positional arguments
echo "Verbose: $VERBOSE"
echo "Output: $OUTPUT"
echo "Count: $COUNT"
echo "Files: $@"
```

---

## 2.5 Long Options - Manual Parsing

### SUBGOAL 2.5.1: Pattern for --option

`getopts` does not support long options (`--help`). We use `while` and `case`:

```bash
#!/bin/bash
# script_long_opts.sh

VERBOSE=false
OUTPUT=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            echo "Help..."
            exit 0
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -o|--output)
            [[ $# -ge 2 && -n $2 ]] || { echo "Missing nonempty output value" >&2; exit 1; }
            OUTPUT="$2"
            shift 2
            ;;
        --output=*)
            OUTPUT="${1#*=}"    # Extract value after =
            [[ -n $OUTPUT ]] || { echo "Empty output value" >&2; exit 1; }
            shift
            ;;
        --)
            shift
            break
            ;;
        -*)
            echo "Unknown option: $1"
            exit 1
            ;;
        *)
            break
            ;;
    esac
done

# $@ contains remaining arguments
```

---

## 2.6 Best Practices for CLI

### SUBGOAL 2.6.1: Checked script template

`set -e` has conditional exceptions (including commands tested by `if`, `&&` and `||`). It does not replace explicit status checks. Optional log functions return success when quiet; counters use assignments when zero is a valid value.

```bash
#!/bin/bash
set -euo pipefail
VERSION=1.0
SCRIPT_NAME=${0##*/}
VERBOSE=false
DRY_RUN=false
OUTPUT=""
usage() {
    printf 'Usage: %s [-h|--help] [-V|--version] [-v|--verbose] [-n|--dry-run] [-o|--output FILE] INPUT\n' "$SCRIPT_NAME"
}
log() { if "$VERBOSE"; then printf '[INFO] %s\n' "$*" >&2; fi; return 0; }
error() { printf '[ERROR] %s\n' "$*" >&2; exit 1; }
parse_args() {
    while (($#)); do
        case $1 in
            -h|--help) usage; exit 0 ;;
            -V|--version) printf '%s\n' "$VERSION"; exit 0 ;;
            -v|--verbose) VERBOSE=true; shift ;;
            -n|--dry-run) DRY_RUN=true; shift ;;
            -o|--output)
                [[ $# -ge 2 && -n $2 ]] || error "Missing nonempty output value"
                OUTPUT=$2; shift 2 ;;
            --output=*) OUTPUT=${1#*=}; [[ -n $OUTPUT ]] || error "Empty output value"; shift ;;
            --) shift; break ;;
            -*) error "Unknown option: $1" ;;
            *) break ;;
        esac
    done
    [[ $# == 1 ]] || error "Exactly one input file is required"
    INPUT=$1
    [[ -f $INPUT && -r $INPUT ]] || error "Unreadable regular input: $INPUT"
    if [[ -n $OUTPUT && -e $OUTPUT && $INPUT -ef $OUTPUT ]]; then
        error "Input and output must differ"
    fi
    return 0
}
main() {
    parse_args "$@"
    log "Processing: $INPUT"
    log "Output: ${OUTPUT:-stdout}"
    if "$DRY_RUN"; then
        printf '[DRY-RUN] Would copy %q to %q\n' "$INPUT" "${OUTPUT:-stdout}"
    elif [[ -n $OUTPUT ]]; then
        # noclobber prevents replacing an existing result in this teaching template.
        (set -C; cat -- "$INPUT" > "$OUTPUT") || error "Copy failed (existing output is not replaced)"
    else
        cat -- "$INPUT" || error "Read failed"
    fi
}
main "$@"
```

---

# MODULE 3: THE UNIX PERMISSIONS SYSTEM

## 3.1 Permissions Fundamentals

### SUBGOAL 3.1.1: The rwx structure

```
-rwxr-xr--  1 user group  4096 Jan 10 12:00 file.txt
│└┬┘└┬┘└┬┘
│ │  │  └── Others permissions: r-- (read only)
│ │  └── Group permissions: r-x (read + execute)
│ └── Owner permissions: rwx (full)
└── Type: - file, d directory, l symlink
```

Meaning on files:

| Permission | Letter | Octal | Effect on FILE |
|------------|--------|-------|----------------|
| Read | r | 4 | Can read content |
| Write | w | 2 | Can modify content |
| Execute | x | 1 | Can run as programme |

### SUBGOAL 3.1.2: Meaning on files vs directories

⚠️ Trap: x on directory does NOT mean "execution"!

| Permission | On FILE | On DIRECTORY |
|------------|---------|--------------|
| r (read) | Read content | Can list with `ls` |
| w (write) | Modify content | Create/remove directory entries when search is also allowed |
| x (execute) | Run as programme | Search/traverse known names, including `cd` |

Search permission is needed on **every parent directory**. Directory mode does not determine whether an already accessible regular file can be edited; that depends on the file mode/ACL. The following owned example assumes an ordinary unprivileged user.

```bash
# Practical example, from a fresh owned workspace
mkdir test_dir
printf 'example\n' > test_dir/file.txt
chmod 700 test_dir      # rwx------

chmod 600 test_dir      # rw------- (without x)
cd test_dir             # ERROR: Permission denied
ls test_dir             # Works (has r)

chmod 100 test_dir      # --x------
cd test_dir             # Works (has x)
ls                      # ERROR: doesn't have r
cat file.txt            # Now inside test_dir; also requires read permission on file.txt
cd ..
chmod 700 test_dir       # Restore access in this owned example
```

---

## 3.2 chmod - Octal Mode

### SUBGOAL 3.2.1: Octal calculation

```
r = 4 (read)
w = 2 (write)
x = 1 (execute)

Examples:
rwx = 4+2+1 = 7
rw- = 4+2+0 = 6
r-x = 4+0+1 = 5
r-- = 4+0+0 = 4
--- = 0+0+0 = 0
```

Common permissions:

| Octal | Symbolic | Usage |
|-------|----------|-------|
| 755 | rwxr-xr-x | Scripts, public directories |
| 644 | rw-r--r-- | Normal files (documents) |
| 700 | rwx------ | Private directory |
| 600 | rw------- | Private file (SSH keys) |
| 777 | rwxrwxrwx | ⚠️ AVOID! Vulnerability |

```bash
chmod 755 script.sh     # Executable by all
chmod 644 document.txt  # Readable by all, editable by owner
chmod 600 ~/.ssh/id_rsa # Private key - owner only
chmod 700 ~/private/    # Private directory
```

---

## 3.3 chmod - Symbolic Mode

### SUBGOAL 3.3.1: Operators +, -, =

| Category | Letter |
|----------|--------|
| Owner | u |
| Group | g |
| Others | o |
| All | a |

| Operator | Effect |
|----------|--------|
| + | Add permission |
| - | Remove permission |
| = | Set exactly |

```bash
chmod u+x script.sh         # Owner +execute
chmod g-w file.txt          # Group -write
chmod o=r file.txt          # Others = read only
chmod a+r file.txt          # All +read
chmod u=rwx,g=rx,o=r f.txt  # Complete setting
chmod go-rwx private.txt    # Remove all for group and others
```

### SUBGOAL 3.3.2: Recursive chmod

```bash
chmod -R 755 directory/      # Recursive

# PROBLEM: 755 on files makes them executable!

# X grants execute/search to directories OR regular files already executable by anyone
chmod -R u=rwX,g=rX,o=rX directory/

# To require 755 directories and 644 files regardless of previous execute bits:
find directory/ -type d -exec chmod 755 {} \;
find directory/ -type f -exec chmod 644 {} \;
```

---

## 3.4 Ownership - chown and chgrp

```bash
# Change owner
sudo chown john file.txt

# Change owner and group
sudo chown john:developers file.txt

# Only group
sudo chown :developers file.txt
# or
chgrp developers file.txt

# Recursive
sudo chown -R john:developers project/

# Copy ownership from another file
sudo chown --reference=model.txt target.txt
```

---

## 3.5 umask - Default Permissions

### SUBGOAL 3.5.1: How umask works

⚠️ umask REMOVES bits, does not set!

```text
Ordinary requested modes: 0666 for new files, 0777 for new directories.
Without a default ACL: final mode = requested_mode & ~umask (bitwise removal).
Mask    File mode             Directory mode
0022    0666 & ~0022 = 0644    0777 & ~0022 = 0755
0027    0666 & ~0027 = 0640    0777 & ~0027 = 0750
0077    0666 & ~0077 = 0600    0777 & ~0077 = 0700
0177    0666 & ~0177 = 0600    0777 & ~0177 = 0600
0001    0666 & ~0001 = 0666    0777 & ~0001 = 0776
```

Arithmetic subtraction fails for masks containing bits absent from the requested mode.
A programme can request a more restrictive mode. A directory default ACL changes
creation rules; these examples assume no inherited default ACL.

```bash
umask              # Display current value
umask -S           # Display symbolic
umask 022          # Set (temporary)

# Permanent - add to ~/.bashrc
echo "umask 022" >> ~/.bashrc
```

---

## 3.6 Special Permissions

### SUBGOAL 3.6.1: SUID (4xxx)

For a supported executable binary, SUID changes the effective user ID to the file owner, subject to platform and mount restrictions. Linux ignores SUID on interpreter scripts; it is not a way to make a Bash script run as root.

```bash
ls -l /usr/bin/passwd
# -rwsr-xr-x 1 root root ... /usr/bin/passwd
# ^-- 's' instead of 'x'

# Why? passwd needs to modify /etc/shadow (owned by root)
# Anyone can run passwd, but the process has root's permissions

chmod u+s program    # Set SUID
chmod 4755 program   # Octal: 4 + 755
```

### SUBGOAL 3.6.2: SGID (2xxx)

On files: Executes with group's permissions.

On directories: New files inherit the directory's group (not the creator's).

```bash
# Setup shared directory for team
sudo mkdir /projects/team1
sudo chgrp developers /projects/team1
sudo chmod 2775 /projects/team1

# Now, any file created in /projects/team1
# will automatically belong to group "developers"
```

### SUBGOAL 3.6.3: Sticky Bit (1xxx)

On directories: removing or renaming an entry additionally requires ownership of the file or directory, or appropriate privilege. Ordinary directory write and search permissions still apply.

```bash
ls -ld /tmp
# drwxrwxrwt 15 root root ... /tmp
# ^-- 't' instead of 'x'

# Everyone can create files in /tmp
# File owner, directory owner or a suitably privileged process can remove entries

chmod +t directory    # Set sticky
chmod 1777 directory  # Octal
```

---

## 3.7 Security and Best Practices

```
⚠️ GOLDEN RULES:

1. Avoid granting world write without a specific need; shared sticky directories are a distinct case
2. Principle of "least privilege" - give minimum necessary permissions
3. Test in sandbox before recursive chmod
4. Check with ls -la before modifying
5. Be careful with SUID - can be a vulnerability
```

---

# MODULE 4: AUTOMATION WITH CRON

## 4.1 What is Cron?

Cron is a daemon that executes scheduled commands. Essential for:
- Automatic backups
- Log cleanup
- Periodic reports
- System maintenance

---

## 4.2 Crontab Format

### SUBGOAL 4.2.1: The 5 fields

```
┌───────────── minute (0-59)
│ ┌───────────── hour (0-23)
│ │ ┌───────────── day of month (1-31)
│ │ │ ┌───────────── month (1-12 or jan-dec)
│ │ │ │ ┌───────────── day of week (0-7, 0 and 7 = Sunday)
│ │ │ │ │
│ │ │ │ │
* * * * * command
```

### SUBGOAL 4.2.2: Special characters

| Symbol | Description | Example |
|--------|-------------|---------|
| `*` | Any value | `* * * * *` |
| `,` | List | `1,15,30` |
| `-` | Range | `1-5` |
| `/` | Step | `*/5` |

### SUBGOAL 4.2.3: Special strings

| String | Equivalent | Description |
|--------|------------|-------------|
| @reboot | - | At system startup |
| @yearly | 0 0 1 1 * | 1 January, midnight |
| @monthly | 0 0 1 * * | First day of month |
| @weekly | 0 0 * * 0 | Sunday, midnight |
| @daily | 0 0 * * * | Daily, midnight |
| @hourly | 0 * * * * | Every hour |

---

## 4.3 Managing Crontab

```bash
crontab -e          # Edit your crontab
crontab -l          # List jobs
crontab -r          # ⚠️ DELETES EVERYTHING!

sudo crontab -u user -e  # Edit for another user
```

---

## 4.4 Cron Best Practices

### SUBGOAL 4.4.1: Execution environment

Target: the Debian/Ubuntu cron family used by this course. Jobs do not inherit an interactive shell session. Cron normally sets HOME from the account and executes commands with /bin/sh unless SHELL is configured. Set required variables explicitly. Unredirected output is normally mailed when a mail transport is configured; it is not automatically /dev/null.

```cron
# In crontab, set PATH explicitly
PATH=/usr/local/bin:/usr/bin:/bin
SHELL=/bin/bash
MAILTO=""
# No automatic mail in this example; a real recipient needs an explicitly configured policy.

0 3 * * * /full/path/to/script.sh
```

### SUBGOAL 4.4.2: Logging and debugging

```cron
# Redirect output
0 3 * * * /path/script.sh >> /var/log/myscript.log 2>&1

# With timestamp
0 3 * * * /path/script.sh 2>&1 | while read line; do echo "$(date): $line"; done >> /var/log/script.log

# Suppress output
0 3 * * * /path/script.sh > /dev/null 2>&1
```

Redirecting both streams to a file leaves no output for cron's automatic mail. `%` is special in crontab command text and must be escaped there (for example `date +\%F`); inside an ordinary script use `date +%F` with no cron escape. POSIX `/bin/sh` supports `$(...)`.

### SUBGOAL 4.4.3: Prevent multiple executions

```bash
#!/bin/bash
# Precondition: WORK_DIR is an existing private directory owned by this user.
: "${WORK_DIR:?Set an owned workspace}"
[[ -d $WORK_DIR && -O $WORK_DIR && ! -L $WORK_DIR ]] || exit 1
exec 9>"$WORK_DIR/job.lock" || exit 1
flock -n 9 || { echo "Another invocation holds the lock" >&2; exit 2; }
# Your logic here. The descriptor lock is released when this process exits.
# Do not unlink the lock file: its existence alone does not mean it is locked.
```

---

## 4.5 at - One-Time Tasks

```bash
at 15:30                    # At 15:30 today
at now + 1 hour             # In one hour
at midnight                 # At midnight
at noon tomorrow            # Tomorrow at noon

atq                         # List jobs
atrm job_number             # Delete a job
```

---

# SUMMARY AND EXTENDED CHEAT SHEET

## find
```bash
find . -name "*.txt"                    # By name
find . -type f -size +10M               # Files > 10MB
find . -mtime -7                        # Modified in 7 days
find . -perm 644                        # Exact permissions
find . -exec cmd {} \;                  # Execute per file
find . -print0 | xargs -0 cmd           # Safe for spaces
```

## xargs
```bash
cmd | xargs                             # Build arguments
cmd | xargs -n 1                        # One argument at a time
cmd | xargs -I{} action {}              # Placeholder
cmd | xargs -P 4                        # At most 4 concurrent children
find . -print0 | xargs -0               # For spaces
```

## Script Parameters
```text
$0                    # Script name
$1-$9                 # Arguments 1-9
${10}                 # Argument 10+
$#                    # Number of arguments
$@                    # All (as list)
shift                 # Remove $1
getopts "ab:c:" opt   # Option parsing
```

## chmod
```bash
chmod 755 file        # rwxr-xr-x
chmod 644 file        # rw-r--r--
chmod u+x file        # +execute owner
chmod -R 755 dir/     # Recursive
chmod 4755 file       # SUID
chmod 2775 dir        # SGID
chmod 1777 dir        # Sticky
```

## cron
```cron
* * * * *             # Every minute
*/5 * * * *           # Every 5 minutes
0 3 * * *             # Daily 3 AM
0 9 * * 1-5           # Mon-Fri 9 AM
@reboot               # At boot
```

---

*Material created for Seminar 3 OS | Bucharest UES - CSIE*
