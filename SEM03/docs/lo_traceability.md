# Learning Outcomes Traceability Matrix — Seminar 03
## Operating Systems | Bucharest UES - CSIE

> **Version:** 1.1 | **Date:** January 2025  
> **Subject:** System Administration — find, xargs, getopts, permissions, CRON

---

## Table of Contents

1. [Learning Outcomes](#1-learning-outcomes)
2. [Coverage Matrix](#2-coverage-matrix)
3. [Parsons Problems with Distractors](#3-parsons-problems-with-distractors)
4. [Bloom Taxonomy Mapping](#4-bloom-taxonomy-mapping)

---

## 1. Learning Outcomes

Upon completion of Seminar 03, students will be able to:

| ID | Learning Outcome | Bloom Level | Action verb |
|----|------------------|-------------|-------------|
| **LO1** | Construct `find` commands with multiple criteria and actions | Apply | construct |
| **LO2** | Use `xargs` for efficient and safe batch processing | Apply | use |
| **LO3** | Implement argument parsing using `getopts` | Apply | implement |
| **LO4** | Calculate and apply permissions in octal and symbolic format | Apply | calculate, apply |
| **LO5** | Configure cron jobs with logging and error handling | Apply | configure |
| **LO6** | Diagnose common permission and cron problems | Analyse | diagnose |
| **LO7** | Evaluate the efficiency of different batch processing approaches | Evaluate | evaluate |

---

## 2. Coverage Matrix

### 2.1 Coverage by Files

| LO | Main Material | Peer Instruction | Live Coding | Sprint Ex. | LLM-Aware | Quiz |
|:--:|:-------------:|:----------------:|:-----------:|:----------:|:---------:|:----:|
| LO1 | S03_02 §2.1 | PI-01, PI-02 | LC-01 | Ex 1-3 | E1, E2 | Q01-Q04 |
| LO2 | S03_02 §2.2 | PI-03, PI-04 | LC-02 | Ex 4-5 | E3 | Q05 |
| LO3 | S03_02 §3 | PI-06, PI-07, PI-08 | LC-03 | Ex 6-8 | E4, E5 | Q06-Q08 |
| LO4 | S03_02 §4 | PI-10, PI-11, PI-12 | LC-04 | Ex 9-12 | E6, E7 | Q09-Q12 |
| LO5 | S03_02 §5 | PI-15, PI-16, PI-17 | LC-05 | Ex 13-15 | E8, E9 | Q13-Q15 |
| LO6 | S03_02 §6 | PI-05, PI-09, PI-14 | LC-01, LC-04 | Ex 16-17 | E10 | Q11, Q16 |
| LO7 | S03_02 §7 | PI-03 | LC-02 | Ex 18 | E11 | Q17 |

### 2.2 Coverage by Activities

| Activity | LO1 | LO2 | LO3 | LO4 | LO5 | LO6 | LO7 |
|----------|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| Theory presentation | ● | ● | ● | ● | ● | ○ | ○ |
| Live coding | ● | ● | ● | ● | ● | ● | ○ |
| Guided exercises | ● | ● | ● | ● | ● | ● | ○ |
| Sprint exercises | ● | ● | ● | ● | ● | ● | ● |
| Assignment | ● | ● | ● | ● | ● | ● | ● |
| Formative quiz | ● | ● | ● | ● | ● | ● | ● |

**Legend:** ● = primary coverage, ○ = secondary coverage

---

## 3. Parsons Problems with Distractors

### PP-01: find script with old file deletion

**Task:** Arrange the lines to create a script that deletes `.tmp` files older than 7 days from `/tmp`.

**LOs covered:** LO1, LO2

**Correct lines (correct order):**
```bash
#!/bin/bash
set -euo pipefail
find /tmp -name "*.tmp" -type f -mtime +7 -print0 | xargs -0 rm -f
echo "Cleanup complete"
```

**Distractors (incorrect lines):**

| Incorrect line | Error | Targeted misconception |
|----------------|-------|------------------------|
| `find /tmp -name "*.tmp" -mtime 7 -print` | Missing `+` at mtime, missing `-type f`, missing `-print0` | Confusion +/- sign at mtime |
| `find /tmp -name *.tmp -type f -mtime +7` | Missing quotes at pattern | Shell expands wildcard prematurely |
| `xargs rm -f` | Missing `-0` for null separator | Problems with spaces in names |
| `find /tmp -type f "*.tmp" -mtime +7` | Incorrect syntax: `-name` missing | Confusion option order |

**Solution with explanations:**
```bash
#!/bin/bash
# Shebang - mandatory first line
set -euo pipefail
# Strict mode: exit on error, undefined vars, pipe failures
find /tmp -name "*.tmp" -type f -mtime +7 -print0 | xargs -0 rm -f
# -name with quotes, -type f for files only, +7 = older than 7 days
# -print0 and -0 for correct handling of spaces in names
echo "Cleanup complete"
```

---

### PP-02: Script with getopts

**Task:** Arrange the lines for a script that accepts `-v` (verbose) and `-f FILE` (input file).

**LOs covered:** LO3

**Correct lines (correct order):**
```bash
#!/bin/bash
VERBOSE=false
INPUT_FILE=""
while getopts "vf:" opt; do
    case $opt in
        v) VERBOSE=true ;;
        f) INPUT_FILE="$OPTARG" ;;
        *) echo "Usage: $0 [-v] -f file" >&2; exit 1 ;;
    esac
done
```

**Distractors (incorrect lines):**

| Incorrect line | Error | Targeted misconception |
|----------------|-------|------------------------|
| `while getopts "v:f:" opt; do` | `:` incorrect after `v` | v is flag, has no argument |
| `while getopts "vf" opt; do` | Missing `:` after `f` | f requires argument |
| `f) INPUT_FILE=$OPTARG ;;` | Missing quotes | Variables must be quoted |
| `case "$opt" in` | Unnecessary quotes but not wrong | Not an error, but may confuse |
| `INPUT_FILE = ""` | Spaces at assignment | Classic Bash error |

**Solution with explanations:**
```bash
#!/bin/bash
VERBOSE=false           # Variable initialisation
INPUT_FILE=""           # NO spaces at =
while getopts "vf:" opt; do    # v=flag, f:=with argument
    case $opt in
        v) VERBOSE=true ;;              # Simple flag
        f) INPUT_FILE="$OPTARG" ;;      # $OPTARG contains the argument
        *) echo "Usage: $0 [-v] -f file" >&2; exit 1 ;;
    esac
done
```

---

### PP-03: Permission verification and setting

**Task:** Arrange the lines to verify if a file is executable and, if not, make it executable.

**LOs covered:** LO4, LO6

**Correct lines (correct order):**
```bash
#!/bin/bash
FILE="$1"
if [[ ! -x "$FILE" ]]; then
    chmod +x "$FILE"
    echo "Execute permission added for $FILE"
fi
```

**Distractors (incorrect lines):**

| Incorrect line | Error | Targeted misconception |
|----------------|-------|------------------------|
| `if [ ! -x $FILE ]; then` | Missing quotes at variable | Word splitting with spaces |
| `if [[ ! -x $FILE ]]` | Missing `then` | Incomplete if syntax |
| `if [ -x "$FILE" = false ]; then` | Completely wrong syntax | Confusion with other languages |
| `chmod 777 "$FILE"` | Excessive permissions | Insecure - gives access to everyone |
| `FILE = "$1"` | Spaces at assignment | Classic Bash error |

**Solution with explanations:**
```bash
#!/bin/bash
FILE="$1"                        # First argument, with quotes
if [[ ! -x "$FILE" ]]; then      # [[ ]] is safer than [ ]
    chmod +x "$FILE"             # +x adds execute
    echo "Execute permission added for $FILE"
fi                               # Closes if
```

---

### PP-04: Cron job with logging

**Task:** Arrange the lines for a cron job that runs daily at 3 AM with logging.

**LOs covered:** LO5, LO6

**Correct lines (correct order):**
```bash
# In crontab (crontab -e):
0 3 * * * /home/user/backup.sh >> /var/log/backup.log 2>&1

# Script backup.sh:
#!/bin/bash
set -euo pipefail
echo "[$(date '+\%Y-\%m-\%d \%H:\%M:\%S')] Backup started"
tar -czf /backup/data_$(date +\%Y\%m\%d).tar.gz /home/user/data
echo "[$(date '+\%Y-\%m-\%d \%H:\%M:\%S')] Backup completed"
```

**Distractors (incorrect lines):**

| Incorrect line | Error | Targeted misconception |
|----------------|-------|------------------------|
| `3 0 * * * backup.sh` | Hour/minute order inverted, relative path | Confusion crontab format |
| `0 3 * * * backup.sh > /var/log/backup.log` | Relative path, missing 2>&1 | Minimal PATH in cron |
| `date +%Y-%m-%d` | Missing escape `\%` in crontab | % has special meaning in cron |
| `0 3 * * 1-5 /home/user/backup.sh` | Runs only Monday-Friday | Confusion with "daily" |

**Solution with explanations:**
```bash
# Crontab: m h dom mon dow command
0 3 * * * /home/user/backup.sh >> /var/log/backup.log 2>&1
# 0=min, 3=hour, *=any day/month/day_of_week
# >> = append, 2>&1 = stderr to stdout
# ABSOLUTE PATH is mandatory!

# In script, % must be escaped as \% in crontab
# Or put the logic in script and call the script from cron
```

---

### PP-05: Batch processing with verifications

**Task:** Arrange the lines to process all `.csv` files from a directory, verifying that it exists.

**LOs covered:** LO1, LO2, LO6, LO7

**Correct lines (correct order):**
```bash
#!/bin/bash
set -euo pipefail
DIR="${1:-.}"
[[ -d "$DIR" ]] || { echo "Error: $DIR is not a directory" >&2; exit 1; }
count=$(find "$DIR" -name "*.csv" -type f | wc -l)
if [[ $count -eq 0 ]]; then
    echo "No .csv files exist in $DIR"
    exit 0
fi
find "$DIR" -name "*.csv" -type f -exec wc -l {} +
```

**Distractors (incorrect lines):**

| Incorrect line | Error | Targeted misconception |
|----------------|-------|------------------------|
| `DIR="$1:-."`  | Missing braces at default | Parameter expansion syntax |
| `[ -d $DIR ] || exit 1` | Missing quotes, message missing | Word splitting |
| `if [ $count = 0 ]; then` | `=` for string, not numeric | Numeric vs string comparison |
| `find "$DIR" -name "*.csv" -exec wc -l {} \;` | `\;` instead of `+` | Inefficiency: one wc per file |
| `find $DIR -name *.csv` | Variable and pattern without quotes | Errors with spaces and expansion |

**Solution with explanations:**
```bash
#!/bin/bash
set -euo pipefail
DIR="${1:-.}"                    # Default to current directory
# ${var:-default} = use default if var is empty/undefined

[[ -d "$DIR" ]] || { echo "Error: $DIR is not a directory" >&2; exit 1; }
# [[ ]] does not require quotes, but it is good practice

count=$(find "$DIR" -name "*.csv" -type f | wc -l)
if [[ $count -eq 0 ]]; then      # -eq for numeric comparison
    echo "No .csv files exist in $DIR"
    exit 0
fi

find "$DIR" -name "*.csv" -type f -exec wc -l {} +
# + groups files = efficient (a single wc)
```

---

### PP-06: Advanced getopts with multiple options

**Task:** Arrange the lines for a script that accepts `-v` (verbose), `-o OUTPUT` (output file) and `-n COUNT` (number of items).

**LOs covered:** LO3, LO6

**Correct lines (correct order):**
```bash
#!/bin/bash
set -euo pipefail
VERBOSE=false
OUTPUT_FILE=""
COUNT=10
while getopts "vo:n:" opt; do
    case $opt in
        v) VERBOSE=true ;;
        o) OUTPUT_FILE="$OPTARG" ;;
        n) COUNT="$OPTARG" ;;
        *) echo "Usage: $0 [-v] [-o output] [-n count]" >&2; exit 1 ;;
    esac
done
shift $((OPTIND - 1))
```

**Distractors (incorrect lines):**

| Incorrect line | Error | Targeted misconception |
|----------------|-------|------------------------|
| `while getopts "v:o:n:" opt; do` | `:` incorrect after `v` | v is flag, has no argument |
| `while getopts "von" opt; do` | Missing `:` after `o` and `n` | Both o and n require arguments |
| `n) COUNT=$OPTARG ;;` | Missing quotes around $OPTARG | Variable must be quoted |
| `shift OPTIND - 1` | Missing `$(( ))` for arithmetic | Arithmetic expansion syntax |
| `OUTPUT_FILE= "$OPTARG"` | Space after `=` | Bash assignment syntax error |
| `while getopts vo:n: opt; do` | Missing quotes around optstring | Optstring must be quoted |

**Solution with explanations:**
```bash
#!/bin/bash
set -euo pipefail
VERBOSE=false                    # Boolean flag (no argument)
OUTPUT_FILE=""                   # Will hold -o argument
COUNT=10                         # Default value for -n
while getopts "vo:n:" opt; do    # v=flag, o:=with arg, n:=with arg
    case $opt in
        v) VERBOSE=true ;;
        o) OUTPUT_FILE="$OPTARG" ;;   # $OPTARG = argument value
        n) COUNT="$OPTARG" ;;
        *) echo "Usage: $0 [-v] [-o output] [-n count]" >&2; exit 1 ;;
    esac
done
shift $((OPTIND - 1))            # Remove processed options
# Now $@ contains only positional arguments
```

---

### PP-07: Cron job with pre-execution verification and log rotation

**Task:** Arrange the lines for a cron script that checks disk space before backup and rotates logs.

**LOs covered:** LO5, LO6, LO7

**Correct lines (correct order):**
```bash
#!/bin/bash
set -euo pipefail
LOG_FILE="/var/log/backup_weekly.log"
BACKUP_DIR="/backup"
MIN_SPACE_MB=500

# Rotate log if larger than 10MB
if [[ -f "$LOG_FILE" ]] && [[ $(stat -c%s "$LOG_FILE") -gt 10485760 ]]; then
    mv "$LOG_FILE" "${LOG_FILE}.old"
fi

# Check available space
available=$(df -m "$BACKUP_DIR" | awk 'NR==2 {print $4}')
if [[ $available -lt $MIN_SPACE_MB ]]; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: Insufficient space" >> "$LOG_FILE"
    exit 1
fi

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Backup started" >> "$LOG_FILE"
tar -czf "$BACKUP_DIR/weekly_$(date +%Y%m%d).tar.gz" /home/user/data 2>> "$LOG_FILE"
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Backup completed" >> "$LOG_FILE"
```

**Distractors (incorrect lines):**

| Incorrect line | Error | Targeted misconception |
|----------------|-------|------------------------|
| `if [ -f $LOG_FILE ] && [ $(stat -c%s $LOG_FILE) -gt 10485760 ]` | Missing quotes, [[ ]] preferred | Word splitting and safer syntax |
| `available=$(df -m $BACKUP_DIR \| awk 'NR==2 {print $4}')` | Missing quotes around variable | Word splitting risk |
| `if [ $available < $MIN_SPACE_MB ]; then` | `<` is string comparison, not numeric | Use `-lt` for numeric comparison |
| `echo "[$(date +%Y-%m-%d %H:%M:%S)]"` | Space in format not quoted properly | Format string handling |
| `tar -czf $BACKUP_DIR/weekly_$(date +%Y%m%d).tar.gz` | Missing quotes around path | Word splitting with spaces |
| `[[ $(stat -c%s "$LOG_FILE") > 10485760 ]]` | `>` is string comparison in [[ ]] | Use `-gt` for numeric |

**Solution with explanations:**
```bash
#!/bin/bash
set -euo pipefail
LOG_FILE="/var/log/backup_weekly.log"
BACKUP_DIR="/backup"
MIN_SPACE_MB=500

# Rotate log if larger than 10MB (10485760 bytes)
if [[ -f "$LOG_FILE" ]] && [[ $(stat -c%s "$LOG_FILE") -gt 10485760 ]]; then
    mv "$LOG_FILE" "${LOG_FILE}.old"   # Simple rotation
fi

# Check available space in MB
available=$(df -m "$BACKUP_DIR" | awk 'NR==2 {print $4}')
if [[ $available -lt $MIN_SPACE_MB ]]; then    # -lt for numeric comparison
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: Insufficient space" >> "$LOG_FILE"
    exit 1
fi

# Proceed with backup
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Backup started" >> "$LOG_FILE"
tar -czf "$BACKUP_DIR/weekly_$(date +%Y%m%d).tar.gz" /home/user/data 2>> "$LOG_FILE"
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Backup completed" >> "$LOG_FILE"
```

**Crontab entry:**
```
# Weekly backup - Sunday at 2 AM
0 2 * * 0 /home/user/scripts/backup_weekly.sh
```

---

## 4. Bloom Taxonomy Mapping

### 4.1 Distribution by Levels

| Bloom Level | % Target | LOs | Main activities |
|-------------|:--------:|-----|-----------------|
| **Remember** | 15% | - | Quiz Q01, Q06, Q09, Q13 |
| **Understand** | 25% | - | Quiz Q02, Q04, Q07, Q10, Q14; Peer Instruction |
| **Apply** | 35% | LO1-LO5 | Live Coding, Sprint Exercises, Parsons PP-01 to PP-07 |
| **Analyse** | 15% | LO6 | Quiz Q11, Q16; Debugging exercises |
| **Evaluate** | 10% | LO7 | Quiz Q17; Method comparison |

### 4.2 Cognitive Progression by Activities

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  SEMINAR 03: BLOOM PROGRESSION                                              │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  Presentation   [████████░░]  Remember → Understand                         │
│  Live Coding    [░░████████]  Understand → Apply                            │
│  Sprint Ex.     [░░░░██████]  Apply → Analyse                               │
│  Home Assign.   [░░░░░░████]  Apply → Analyse → Evaluate                    │
│  Parsons        [░░██████░░]  Understand → Apply                            │
│                                                                             │
│  Legend: █ = primary coverage                                               │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## References

- S03_02_MAIN_MATERIAL.md — Detailed theoretical content
- S03_03_PEER_INSTRUCTION.md — Questions PI-01 to PI-18
- S03_05_LIVE_CODING_GUIDE.md — Sessions LC-01 to LC-05
- S03_06_SPRINT_EXERCISES.md — Practical exercises
- S03_07_LLM_AWARE_EXERCISES.md — AI-resistant exercises
- formative/quiz.yaml — Complete formative quiz

---

*Document generated according to Brown & Wilson pedagogical standards (10 Quick Tips)*  
*Seminar 03 | Operating Systems | Bucharest UES - CSIE*
