# LLM-Aware Exercises - Seminar 03
## Operating Systems | Critical Evaluation of AI-Generated Code

**Purpose**: Teaching students to catch AI mistakes before those mistakes catch them  
**Reality check**: They're going to use ChatGPT anyway. Let's make them *good* at it.

---

## INTRODUCTION

### Why Bother With This?

Let's be honest. Pretending students don't use ChatGPT is like pretending calculators don't exist in 1985. We tried the "just ban it" approach. Three students submitted nearly identical "original" scripts last semester. That was fun to grade.

So here's Plan B: teach them that AI is a powerful **research assistant** that occasionally hallucinates with complete confidence. You know the type—that one colleague who's always *certain* they're right even when they're spectacularly wrong.

**What we're actually teaching:**
1. **Scepticism** — "That looks reasonable" is not verification
2. **Pattern recognition** — AI makes predictable mistakes
3. **Security instincts** — AI optimises for "works" not "safe"
4. **Real understanding** — If you can't explain it, you didn't learn it

The goal isn't catching cheaters. The goal is graduates who can tell the difference between working code and *confidently wrong* code.

Author anecdotes and model-behaviour statements below are teaching observations, not measured prevalence or a validated authorship detector. No model/version, benchmark sample or controlled provenance record is supplied. Evaluate reproducible code behaviour and the student's explanation; formatting alone establishes neither misconduct nor AI use.

### How These Exercises Work

```
╔═══════════════════════════════════════════════════════════════╗
║  📝 THE PROMPT                                                ║
║  → What some hypothetical lazy student asked ChatGPT          ║
║                                                               ║
║  🤖 WHAT THE AI SPIT OUT                                      ║
║  → Looks reasonable. Compiles. Probably has 3-5 bugs.        ║
║                                                               ║
║  🔍 YOUR JOB                                                  ║
║  → Find the bugs before they find you                        ║
║  → Explain WHY they're bugs (not just "it's wrong")          ║
║  → Fix them properly                                         ║
║                                                               ║
║  ✅ THE ANSWER KEY                                            ║
║  → What a senior sysadmin would have written                 ║
╚═══════════════════════════════════════════════════════════════╝
```

---

## EXERCISE L1: Find Command Generator

### REQUIREMENT SENT TO LLM

```
"Generate a find command that finds all .log files 
larger than 100MB, older than 30 days and deletes them 
to free up disk space."
```

### LLM OUTPUT

```bash
# LLM generated:
find /var/log -name "*.log" -size +100M -mtime +30 -exec rm {} \;
```

### STUDENT TASK

```
═══════════════════════════════════════════════════════════════
🎯 CRITICAL EVALUATION

Analyse the generated command and answer:

1. Identify MINIMUM 3 problems with this command
   (security, efficiency, correctness)

2. For each problem:

In short: Why is it a problem?; What can go wrong?; How do you correct it?.


3. Rewrite the command in a SAFE and EFFICIENT version

4. What clarifying question should you have asked before 
   running this command?

⏱️ Time: 8 minutes
═══════════════════════════════════════════════════════════════
```

### SOLUTION AND EXPLANATION

#### Problems Identified:

| # | Problem | Risk | Severity |
|---|---------|------|----------|
| 1 | No `-type f` | Can select non-regular entries; plain rm refuses directories but may remove a selected symlink | 🟡 Medium |
| 2 | No explicit failure summary | Traversal errors mean incomplete coverage; suppressing them would hide evidence | 🟡 Medium |
| 3 | `-exec rm {} \;` without confirmation | Irreversible deletion | 🔴 High |
| 4 | Doesn't verify first what it deletes | Data loss | 🔴 High |
| 5 | Searches in /var/log which may have critical logs | May delete audit logs | 🔴 High |
| 6 | `-exec {} \;` is inefficient | Starts one rm process per file | 🟡 Medium |

#### Corrected Code:

```bash
# STEP 1: First verify WHAT it would delete (DRY RUN)
find /var/log -type f -name "*.log" -size +100M -mtime +30 \
    -printf "%s %p\n" 2>/dev/null | sort -rn

# STEP 2: If the list is OK, delete with confirmation
find /var/log -type f -name "*.log" -size +100M -mtime +30 \
    -ok rm {} \; 2>/dev/null

# OR for batch deletion (with prior verification):
find /var/log -type f -name "*.log" -size +100M -mtime +30 \
    -print0 2>/dev/null | xargs -0 rm -i

# An owned quarantine is an alternative design, not a production-safety guarantee.
# Preserve relative paths, reject destination collisions and check every move.
# Review retention, audit dependencies and recovery requirements before actual use.
```

#### Necessary Clarifying Questions:

1. "Are there logs that must NOT be deleted? (audit, security)"
2. "Should they be archived before deletion?"
3. "Running with root privileges or normal user?"
4. "Is this a production or test system?"

---

## EXERCISE L2: Script with getopts

### REQUIREMENT SENT TO LLM

```
"Write a bash script that accepts -v for verbose,
-o for output file and processes files given as arguments."
```

### LLM OUTPUT

```bash
#!/bin/bash
# LLM generated:

verbose=0
output=""

while getopts "vo:" opt; do
    case $opt in
        v) verbose=1 ;;
        o) output=$OPTARG ;;
    esac
done

for file in $@; do
    if [ $verbose == 1 ]; then
        echo "Processing $file"
    fi
    cat $file >> $output
done

echo "Done!"
```

### STUDENT TASK

```
═══════════════════════════════════════════════════════════════
🎯 CRITICAL EVALUATION

Analyse the script and:

1. Identify MINIMUM 5 problems (syntax, security, logic)

2. Mentally test with these inputs:

Three things matter here: ./script.sh -v -o result.txt file1.txt "file 2.txt", ./script.sh file.txt  (without -o) and ./script.sh -o  (without argument for -o).


3. Rewrite the script correctly and solidly

⏱️ Time: 10 minutes
═══════════════════════════════════════════════════════════════
```

### SOLUTION AND EXPLANATION

#### Problems Identified:

| # | Line | Problem | Explanation |
|---|------|---------|-------------|
| 1 | `for file in $@` | Missing quotes | Files with spaces break |
| 2 | `if [ $verbose == 1 ]` | String comparison with fixed 0/1 works in Bash | `-eq` expresses numeric intent; this line is not a demonstrated bug |
| 3 | `cat $file >> $output` | Without quotes | Problems with spaces |
| 4 | - | Missing `shift $((OPTIND-1))` | $@ includes options too! |
| 5 | - | Doesn't check if $output is set | If -o is missing, >> "" gives error |
| 6 | - | Doesn't check if files exist | cat on non-existent file = error |
| 7 | - | Missing help (-h) | Best practice |
| 8 | - | Doesn't handle invalid options | `?` in case |

#### Corrected Code:

```bash
#!/bin/bash
# Correct and solid script

verbose=false
output=""

usage() {
    echo "Usage: $0 [-h] [-v] [-o output_file] files..."
    echo "  -h  Show help"
    echo "  -v  Verbose mode"
    echo "  -o  Output file (required)"
    return 0
}

# Option parsing
while getopts "hvo:" opt; do
    case $opt in
        h) usage; exit 0 ;;
        v) verbose=true ;;
        o) output="$OPTARG" ;;
        ?) usage >&2; exit 1 ;;
    esac
done
shift $((OPTIND - 1))

# Validations
if [ -z "$output" ]; then
    echo "Error: -o output_file is mandatory!" >&2
    usage >&2; exit 1
fi

if [ $# -eq 0 ]; then
    echo "Error: Specify at least one file!" >&2
    usage >&2; exit 1
fi

# Validate every input before creating a new output; do not overwrite existing work.
for file in "$@"; do
    [[ -f $file && -r $file ]] || { printf 'Unreadable input: %s\n' "$file" >&2; exit 1; }
done
if ! (set -C; : > "$output"); then
    echo "Output already exists or cannot be created" >&2; exit 1
fi
for file in "$@"; do
    if "$verbose"; then printf 'Processing: %s\n' "$file" >&2; fi
    cat -- "$file" >> "$output" || { echo 'Read/write failed; output is partial' >&2; exit 1; }
done
printf 'Done! Output: %s\n' "$output"
```

---

## EXERCISE L3: Cron Job Reviewer

### REQUIREMENT SENT TO LLM

```
"Generate a cron job that backs up the database daily 
at 2 AM and sends an email with the result."
```

### LLM OUTPUT

```cron
# LLM generated:
0 2 * * * mysqldump mydb > /backup/db_$(date +%Y%m%d).sql && mail -s "Backup OK" recipient@example.invalid
```

### STUDENT TASK

```
═══════════════════════════════════════════════════════════════
🎯 CRITICAL EVALUATION

1. Identify MINIMUM 4 problems with this cron job

2. For each problem, explain:
   - What happens when it runs in cron?
   - Why does it work in terminal but not in cron?

3. Rewrite the cron job correctly, including:
   - Adequate logging
   - Error handling
   - Backup rotation

⏱️ Time: 8 minutes
═══════════════════════════════════════════════════════════════
```

### SOLUTION AND EXPLANATION

#### Problems Identified:

| # | Problem | Why it doesn't work in cron |
|---|---------|----------------------------|
| 1 | `$(date +%Y%m%d)` | POSIX sh supports `$()`; the defect is unescaped `%` in crontab command text, where it separates command/input |
| 2 | Relative paths | Command discovery depends on the configured PATH and installed tools; verify it instead of assuming absence |
| 3 | `/backup/` | Directory may not exist or cron doesn't have permissions |
| 4 | `>` overwrites | If there are 2 backups on the same day, the second overwrites |
| 5 | `&&` ignores partial errors | If mysqldump fails, no error email is sent |
| 6 | No logging | You don't know if it ran or not |
| 7 | DB credentials | Where are user/pass for mysqldump? |

The `.invalid` recipient is deliberately nonfunctional. Configure any real delivery separately. The corrected example below logs locally and has no mail submission action; redirecting both streams leaves no output for automatic cron mail.

#### Corrected Code:

```cron
# Corrected crontab - add at the beginning:
SHELL=/bin/bash
PATH=/usr/local/bin:/usr/bin:/bin
MAILTO=""
# Configure a real recipient only under the course notification policy.

# Daily backup at 2 AM
0 2 * * * /home/user/scripts/backup_db.sh >> /home/user/backup.log 2>&1
```

```bash
#!/bin/bash
# /home/user/scripts/backup_db.sh
set -euo pipefail
# Configure an owned destination and a working local client configuration before use.
BACKUP_DIR="${BACKUP_DIR:-$HOME/backups/mysql}"
MYSQLDUMP_BIN="${MYSQLDUMP_BIN:-/usr/bin/mysqldump}"
DB_NAME="${DB_NAME:-mydb}"
KEEP_DAYS=7
mkdir -p -- "$BACKUP_DIR"
PARTIAL=$(mktemp "$BACKUP_DIR/.db_partial_XXXXXX")
trap 'rm -f -- "$PARTIAL"' EXIT
BACKUP_FILE="$BACKUP_DIR/db_$(date +%Y%m%d_%H%M%S)_${PARTIAL##*_}.sql.gz"
printf 'START backup %s\n' "$DB_NAME"
# pipefail detects a failing dump even when gzip itself succeeds.
if "$MYSQLDUMP_BIN" --defaults-file="$HOME/.my.cnf" "$DB_NAME" | gzip > "$PARTIAL"; then
    mv -- "$PARTIAL" "$BACKUP_FILE"
    printf 'SUCCESS: %s\n' "$BACKUP_FILE"
    # Rotate only complete files from this generator, after a successful backup.
    if ! find "$BACKUP_DIR" -maxdepth 1 -type f -name 'db_*.sql.gz' -mtime +"$KEEP_DAYS" -delete; then
        printf 'Backup succeeded, but rotation failed\n' >&2
        exit 1
    fi
else
    printf 'ERROR: dump/compression failed; no success or rotation performed\n' >&2
    exit 1
fi
printf 'END backup\n'

```

```ini
# ~/.my.cnf (for credentials)
[mysqldump]
user=backup_user
password=secure_password
```

---

## EXERCISE L4: Permission Script Improver

### REQUIREMENT SENT TO LLM

```
"Write a script that sets correct permissions for 
a web project: files should be 644, directories 755."
```

### LLM OUTPUT

```bash
#!/bin/bash
# LLM generated:

chmod -R 644 /var/www/project
chmod -R 755 /var/www/project

echo "Permissions fixed!"
```

### STUDENT TASK

```
═══════════════════════════════════════════════════════════════
🎯 CRITICAL EVALUATION

1. Mentally test: what permissions will files and 
   directories have after running this script?

2. Identify the fundamental logical error

3. Explain why the approach is wrong from a
   security and functionality perspective

4. Rewrite the script correctly

5. BONUS: Add validations and --dry-run mode

⏱️ Time: 10 minutes
═══════════════════════════════════════════════════════════════
```

### SOLUTION AND EXPLANATION

#### Problem Analysis:

```
Original script:
1. chmod -R 644 /var/www/project
   → ALL files AND directories become 644 (rw-r--r--)
   → Directories without x = you can't cd into them!

2. chmod -R 755 /var/www/project
   → OVERWRITES everything with 755 (rwxr-xr-x)
   → Now ALL files are executable!

RESULT: All files are 755, not 644!
        It's exactly the OPPOSITE of what we wanted.
```

#### Corrected Code:

```bash
#!/bin/bash
# fix_permissions.sh - Correct and safe

set -euo pipefail

# Configuration
PROJECT_DIR=""
FILE_PERM="644"
DIR_PERM="755"
DRY_RUN=false

# Argument parsing
while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run|-n)
            DRY_RUN=true
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [--dry-run] [directory]"
            exit 0
            ;;
        -*) echo "Unknown option: $1" >&2; exit 1 ;;
        *)
            [[ -z $PROJECT_DIR ]] || { echo "One directory only" >&2; exit 1; }
            PROJECT_DIR="$1"
            shift
            ;;
    esac
done

# Validations
if [[ -z $PROJECT_DIR || ! -d $PROJECT_DIR || -L $PROJECT_DIR || ! -O $PROJECT_DIR ]]; then
    echo "Error: '$PROJECT_DIR' doesn't exist or isn't a directory!" >&2
    exit 1
fi

PROJECT_DIR=$(realpath -e -- "$PROJECT_DIR")
[[ $PROJECT_DIR != / ]] || exit 1
LIST_DIR=$(mktemp -d "${TMPDIR:-/tmp}/enos-perms-list.XXXXXX")
trap 'rm -rf -- "$LIST_DIR"' EXIT
echo "🔧 Fixing permissions in: $PROJECT_DIR"
echo "   Files: $FILE_PERM, Directories: $DIR_PERM"
[ "$DRY_RUN" = true ] && echo "   MODE: DRY RUN (no changes)"

# Counting for report
file_count=0
dir_count=0

# Fix directories FIRST (to be able to access contents)
echo "📁 Setting directory permissions..."
find "$PROJECT_DIR" -type d -print0 > "$LIST_DIR/directories"
while IFS= read -r -d '' dir; do
    if [ "$DRY_RUN" = true ]; then
        echo "  Would chmod $DIR_PERM: $dir"
    else
        chmod "$DIR_PERM" "$dir"
    fi
    dir_count=$((dir_count + 1))
done < "$LIST_DIR/directories"

# Fix files
echo "📄 Setting file permissions..."
find "$PROJECT_DIR" -type f -print0 > "$LIST_DIR/files"
while IFS= read -r -d '' file; do
    if [ "$DRY_RUN" = true ]; then
        echo "  Would chmod $FILE_PERM: $file"
    else
        chmod "$FILE_PERM" "$file"
    fi
    file_count=$((file_count + 1))
done < "$LIST_DIR/files"

echo "✅ Done! Processed $dir_count directories, $file_count files"

# Verification
if [ "$DRY_RUN" = false ]; then
    echo ""
    echo "📊 Verification:"
    echo "Sample directories:"
    find "$PROJECT_DIR" -type d -exec ls -ld -- {} +
    echo "Sample files:"
    find "$PROJECT_DIR" -type f -exec ls -l -- {} +
fi
```

#### Simple Version (One-liner):

```bash
# Correct and concise version:
find /var/www/project -type d -exec chmod 755 {} +
find /var/www/project -type f -exec chmod 644 {} +

# Different contract: X also preserves/grants execute on already-executable regular files:
chmod -R u=rwX,g=rX,o=rX /var/www/project
```

---

## EXERCISE L5: Security Checker

### REQUIREMENT SENT TO LLM

```
"Write a script that checks if the system has security 
problems with file permissions."
```

### LLM OUTPUT

```bash
#!/bin/bash
# LLM generated:

echo "Checking for security issues..."

# Find world-writable files
find / -perm 777 2>/dev/null

# Find SUID files
find / -perm -4000 2>/dev/null

# Find files without owner
find / -nouser 2>/dev/null

echo "Check complete!"
```

### STUDENT TASK

```
═══════════════════════════════════════════════════════════════
🎯 CRITICAL EVALUATION

1. Identify what is missing for this script to be 
   usable in a real audit

2. Performance and output problems

3. What important security checks are missing?

4. Rewrite the script as a professional audit tool, including:
   - Formatted output
   - Severity per problem
   - Standard exclusions (/proc, /sys, etc.)
   - Saveable report

⏱️ Time: 12 minutes
═══════════════════════════════════════════════════════════════
```

### SOLUTION AND EXPLANATION

#### Problems Identified:

1. **No context**: Doesn't explain WHY it's a problem
2. **No exclusions**: Scans /proc, /sys (thousands of irrelevant files)
3. **No formatting**: Hard to read output
4. **Incomplete**: Missing important checks (SGID, sticky, .rhosts, etc.)
5. **No severity**: All problems seem equal
6. **No report**: Output is lost

#### Corrected Code: Bounded Permission Inventory

A mode match is a **candidate for contextual review**, not proof of a vulnerability.
An explicitly supplied root, NUL-delimited discovery and checked statuses make the
inventory reproducible. This example does not classify every distribution's system
files against invented universal modes, suppress traversal errors or truncate results.

```bash
#!/bin/bash
# security_audit.sh OWNED_EXERCISE_ROOT; read-only source scan, private local report.
set -euo pipefail
[[ $# == 1 && -d $1 ]] || { echo "Usage: $0 EXERCISE_ROOT" >&2; exit 1; }
ROOT=$(realpath -e -- "$1")
[[ $ROOT != / ]] || { echo "Choose a bounded exercise root" >&2; exit 1; }
REPORT_DIR=$(mktemp -d "${TMPDIR:-/tmp}/enos-permission-report.XXXXXX")
REPORT_FILE="$REPORT_DIR/report.txt"
LIST="$REPORT_DIR/paths0"
printf 'Permission candidates; no automatic security verdict\nRoot: %q\n' "$ROOT" > "$REPORT_FILE"
scan() {
    local category=$1 file count=0
    shift
    if ! find "$ROOT" \( -path "$ROOT/proc" -o -path "$ROOT/sys" -o -path "$ROOT/dev" \) -prune -o \( "$@" -print0 \) > "$LIST"; then
        printf 'INCOMPLETE traversal: %s\n' "$category" >&2; return 1
    fi
    while IFS= read -r -d '' file; do
        printf '[%s] %q\n' "$category" "$file" >> "$REPORT_FILE"
        count=$((count + 1))
    done < "$LIST"
    printf '%s: %d candidates\n' "$category" "$count"
}
scan WORLD_WRITABLE -type f -perm -0002
scan SUID -type f -perm -4000
scan SGID -type f -perm -2000
scan NO_ACCOUNT \( -nouser -o -nogroup \)
scan CREDENTIAL_NAME -type f \( -name .netrc -o -name id_rsa -o -name .rhosts \)
# For sensitive files, compare mode/owner/ACL with a documented local baseline;
# a filename or a fixed numeric mode alone is not a complete access-control audit.
rm -f -- "$LIST"
printf 'Full local report: %s\n' "$REPORT_FILE"
```

The existing executable `scripts/demo/S03_03_demo_permissions.sh` supplies additional
permission demonstrations. Account changes and a cross-user access test belong in
a disposable environment; no privilege escalation is needed for this inventory.

---

## LLM OUTPUT EVALUATION CHECKLIST

### When You Receive Code from an LLM, Verify:

```
╔═══════════════════════════════════════════════════════════════╗
║  ✓ SECURITY                                                   ║
║    □ Validates input                                          ║
║    □ No injection vulnerabilities                             ║
║    □ Doesn't expose sensitive data                           ║
║    □ Uses absolute paths where necessary                     ║
║                                                               ║
║  ✓ CORRECTNESS                                                ║
║    □ Test with edge cases (spaces, special characters)       ║
║    □ Handles errors                                           ║
║    □ Does what it should (not what it seems)                 ║
║                                                               ║
║  ✓ ROBUSTNESS                                                 ║
║    □ Checks if files/directories exist                       ║
║    □ Has fallback for errors                                 ║
║    □ Doesn't overwrite data without confirmation             ║
║                                                               ║
║  ✓ EFFICIENCY                                                 ║
║    □ Doesn't launch unnecessary processes                    ║
║    □ Uses batch operations where possible                    ║
║    □ Avoids inefficient loops                                ║
║                                                               ║
║  ✓ BEST PRACTICES                                             ║
║    □ Has help/usage                                          ║
║    □ Has logging                                             ║
║    □ Has dry-run mode for dangerous operations               ║
║    □ Comments where necessary                                ║
╚═══════════════════════════════════════════════════════════════╝
```

---

*Document generated for UES Bucharest - CSIE | Operating Systems | Seminar 3*

---

## EXERCISE L6: Code Archaeology (Debugging Legacy Code)

### PURPOSE

This exercise simulates a real-world scenario: you inherit code from a colleague who left the company. Unlike LLM-generated code (which is usually syntactically correct) legacy code often has subtle bugs that accumulated over time.

**Why this is AI-resistant**: LLMs can fix obvious syntax errors but they struggle with:
- Understanding the INTENT behind buggy code
- Explaining WHY each change matters
- Recognising dangerous patterns that "work" in testing but fail in production

---

### SCENARIO

You received this script from a former colleague. It "works on their machine" but crashes randomly in production.

```bash
#!/bin/sh
# backup_old.sh - "DO NOT MODIFY" (comment from 2019)
# TODO: fix sometime

BACKUP_DIR=/backup
LOG=/tmp/backup.log

for f in `find /home -name "*.important"`; do
    cp $f $BACKUP_DIR
    echo "Copied $f" >> $LOG
done

rm /tmp/*.old
echo Done
```

### STUDENT TASK

```
═══════════════════════════════════════════════════════════════
🏛️ CODE ARCHAEOLOGY CHALLENGE

Analyse the script above and:

1. Identify MINIMUM 6 problems (security, robustness and style)
   Hint: not all problems are syntax errors

2. For each problem:
   - What can go wrong in production?
   - Would ChatGPT detect this problem? (yes/no/maybe)
   - How do you fix it?

3. Rewrite the script as a "production-ready" version

4. Bonus: What does the comment "DO NOT MODIFY" tell you about 
   that team's culture?

⏱️ Time: 15 minutes
═══════════════════════════════════════════════════════════════
```

### SOLUTION AND EXPLANATION

#### Problems Identified:

| # | Line | Problem | Production Impact | ChatGPT Catches? |
|---|------|---------|-------------------|------------------|
| 1 | `#!/bin/sh` | Valid for the displayed POSIX syntax | No Bash-only construct is shown; not a demonstrated error | Not measured |
| 2 | `for f in \`find...\`` | Command substitution breaks on spaces | Files skipped or wrong | ✅ Yes |
| 3 | `cp $f $BACKUP_DIR` | Unquoted variables | Fails on spaces and glob expansion | ✅ Yes |
| 4 | No `-type f` in find | Might match directories | Silent failures | ⚠️ Maybe |
| 5 | `rm /tmp/*.old` | No check if files exist | Error message noise | ⚠️ Maybe |
| 6 | No error handling | cp status is ignored | Logs a copy even after failure; set -e alone is not a complete repair | Not measured |
| 7 | Hardcoded paths | `/backup` might not exist | Fails on different servers | ❌ No |
| 8 | No lock file | Parallel runs corrupt backup | Data loss | ❌ No |
| 9 | `echo Done` not to stderr | Output mixed with data | Parsing issues | ❌ No |
| 10 | No timestamp in log | Cannot debug timing issues | Audit nightmare | ❌ No |

**Evidence boundary:** The model-detection column is an unverified teaching hypothesis; no evaluation sample supports those yes/no predictions. Diagnose the displayed failure mechanisms with fixtures, regardless of who produced the script.

#### Checked Teaching Version

This implementation preserves relative source paths, validates CLI input before
writing, uses a descriptor lock and publishes a uniquely named copy. It is a bounded
local demonstration, not a claim of production acceptance or a retention policy.

```bash
#!/bin/bash
# backup_improved.sh [--dry-run] SOURCE_DIR EXISTING_OWNED_BACKUP_DIR
set -euo pipefail
dry_run=false
case ${1:-} in
    --dry-run) dry_run=true; shift ;;
    -h|--help) echo "Usage: $0 [--dry-run] SOURCE_DIR EXISTING_BACKUP_DIR"; exit 0 ;;
    -*) echo "Unknown option" >&2; exit 1 ;;
esac
[[ $# == 2 && -d $1 && -d $2 ]] || exit 1
SOURCE_DIR=$(realpath -e -- "$1")
BACKUP_DIR=$(realpath -e -- "$2")
[[ $SOURCE_DIR != / && $BACKUP_DIR != / && -O $BACKUP_DIR ]] || exit 1
case "$BACKUP_DIR/" in "$SOURCE_DIR/"*) echo 'Destination must be outside source' >&2; exit 1;; esac
if "$dry_run"; then
    # No output directory, log or lock file is created in simulation.
    find "$SOURCE_DIR" -type f -name '*.important' -print0 |
        while IFS= read -r -d '' file; do printf '[DRY RUN] %q\n' "$file"; done
    exit 0
fi
[[ ! -L $BACKUP_DIR/.enos-important.lock ]] || exit 1
exec 9>"$BACKUP_DIR/.enos-important.lock"
flock -n 9 || { echo 'Another invocation holds the lock' >&2; exit 2; }
DEST=$(mktemp -d "$BACKUP_DIR/important.XXXXXX")
LIST="$DEST/source.paths0"
complete=false
cleanup() { if ! "$complete"; then printf 'FAILED; partial evidence retained at %s\n' "$DEST" >&2; fi; }
trap cleanup EXIT
find "$SOURCE_DIR" -type f -name '*.important' -print0 > "$LIST"
mkdir -- "$DEST/files"
count=0
while IFS= read -r -d '' file; do
    relative=${file#"$SOURCE_DIR/"}
    (cd -- "$SOURCE_DIR"; cp --parents -- "$relative" "$DEST/files/")
    printf 'Copied %q\n' "$relative"
    count=$((count + 1))
done < "$LIST"
complete=true
printf 'Backup complete: %d files in %s\n' "$count" "$DEST"
```

The lock file is not removed on rejection or exit; the descriptor lock is released.
Automatic deletion of old backups is intentionally absent until a documented owned
retention and recovery contract is chosen. Two equal basenames in different source
subdirectories remain distinct in `files/`.

---

## EXERCISE L7: Trap Questions (Detect Plausible But Wrong)

### PURPOSE

These questions test whether you actually UNDERSTAND the commands or just recognise patterns. LLMs often give "plausible-sounding" answers that are subtly wrong.

---

### TRAP QUESTION T1

```
╔══════════════════════════════════════════════════════════════════╗
║  🪤 TRAP QUESTION #1                                              ║
╠══════════════════════════════════════════════════════════════════╣
║                                                                  ║
║  A colleague shows you this "elegant" one-liner:                 ║
║                                                                  ║
║    find / -name "*.log" -delete 2>/dev/null                     ║
║                                                                  ║
║  What do you tell them?                                         ║
║                                                                  ║
║  A) "Excellent! Suppressing errors makes it cleaner"            ║
║  B) "Dangerous: deletes ALL .log files including critical ones" ║
║  C) "Does not work - -delete requires -depth"                   ║
║  D) "Needs sudo to actually delete system files"                ║
║                                                                  ║
╚══════════════════════════════════════════════════════════════════╝
```

**Correct Answer: B**

**Why each answer is wrong/right:**
- A: WRONG - LLMs often validate "correct syntax" without considering consequences
- B: CORRECT - It attempts to delete matching `.log` entries across `/`; actual scope depends on names, permissions and traversal. `syslog` has no `.log` suffix and is not selected by this pattern.
- C: WRONG - GNU `-delete` automatically enables depth-first traversal.
- D: WRONG - Without sudo it will not delete system files but will delete user logs

**Trap mechanism**: Answer A sounds like something an LLM would say (focusing on code style rather than real-world impact).

---

### TRAP QUESTION T2

```
╔══════════════════════════════════════════════════════════════════╗
║  🪤 TRAP QUESTION #2                                              ║
╠══════════════════════════════════════════════════════════════════╣
║                                                                  ║
║  Your script needs to process files from user input:             ║
║                                                                  ║
║    read -p "Enter filename: " filename                          ║
║    cat $filename | process_data                                  ║
║                                                                  ║
║  What is wrong?                                                  ║
║                                                                  ║
║  A) Should use printf instead of read                           ║
║  B) Useless use of cat - just use: process_data < $filename     ║
║  C) Missing quotes: cat "$filename"                             ║
║  D) Both B and C are correct                                    ║
║                                                                  ║
╚══════════════════════════════════════════════════════════════════╝
```

**Correct Answer: C** (though D is tempting!)

**Why:**
- A: WRONG - printf is for output not input
- B: PARTIAL - Yes UUOC exists but it is style not security
- C: CORRECT - Missing quotes = security vulnerability + breaks on spaces
- D: TRAP - B is style preference while C is security requirement. They are not equal.

**Why this is a trap**: LLMs love to say "both X and Y" to sound comprehensive. But in security there is a hierarchy: quotes are CRITICAL while UUOC is cosmetic.

---

### TRAP QUESTION T3

```
╔══════════════════════════════════════════════════════════════════╗
║  🪤 TRAP QUESTION #3                                              ║
╠══════════════════════════════════════════════════════════════════╣
║                                                                  ║
║  This cron job runs at 2:30 AM but sometimes fails silently:    ║
║                                                                  ║
║    30 2 * * * /home/user/backup.sh                              ║
║                                                                  ║
║  What is the MOST LIKELY cause?                                 ║
║                                                                  ║
║  A) backup.sh uses relative paths that do not exist in cron     ║
║  B) 2:30 AM falls during DST transition in some months          ║
║  C) The script needs >> log 2>&1 to capture errors              ║
║  D) cron uses a different shell than your terminal              ║
║                                                                  ║
╚══════════════════════════════════════════════════════════════════╝
```

**Diagnostic answer: insufficient evidence to rank A, B or D.**

**Analysis:**
- A: Possible: check the actual working directory, PATH and script paths. Cron sets HOME and a limited environment; `~` can expand from HOME.
- B: Timezone/DST behaviour depends on the selected cron implementation and zone; inspect the actual date and logs.
- C: True but does not cause FAILURE, just hides errors
- D: Check SHELL and the script shebang. A directly executed executable script uses its interpreter; the cron command line defaults to /bin/sh.

**Revised task:** State one observation that distinguishes each hypothesis. The prompt supplies no frequency data supporting a most-likely ranking; do not grade an unsupported guess as a unique answer.

---

## ANTI-AI VERIFICATION GUIDELINES

### For Instructors: How to Verify Student Understanding

When reviewing homework use these probes:

1. **"Explain line X"** - Students who copied cannot explain their own code
2. **"What happens if..."** - Change one parameter and ask for prediction
3. **"Why not use Y instead?"** - Forces comparison of alternatives
4. **"What error would you get if..."** - Tests debugging knowledge

### Evidence for a Follow-up Conversation

Polish, generic language and uneven depth are not validated authorship indicators.
Use a reproducible failing case, a mismatch between the stated and implemented
contract or an unexplained design decision as a prompt for technical discussion.
Record uncertainty and observed behaviour. Any sanctions or required oral weighting
remain `PENDING_POLICY`; no automatic penalty follows from these observations.

### Questions Students Should Be Able to Answer Live

If a student submitted correct homework they should be able to answer:

1. "Run your find command but change -mtime to -mmin. What changes?"
2. "Your script uses getopts 'hv:o:'. Which options require operands? (v and o.) How would you make v a flag? (Use hvo:.)"
3. "You set permissions 755. What happens if a file has 754?"
4. "Your cron job runs at */15. What times exactly?"

---

*Document generated for UES Bucharest - CSIE | Operating Systems | Seminar 3*  
*Enhanced with AI-resistance measures: January 2025*
