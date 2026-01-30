# Evaluation Rubric - Seminar 3 Assignment

> **Instructor document** | Do not distribute to students before evaluation

---

## Scoring System Legend

| Symbol | Meaning | Example |
|--------|---------|---------|
| **%** | Percentage of final assignment grade (100%) | PART 1: 20% of total |
| **Pts (in tables)** | Relative points within the section | 3 pts out of 8% of sub-section |
| **Adjustment ±X%** | Percentage modification applied to final grade | Code quality: ±5% |

> **Important note**: Points in table columns (Pts) are **relative points** that add up to form the percentage of that section. Example: in PART 1 (20%), sub-sections of 8 + 6 + 6 = 20 relative points equate to 20% of the final grade.

---

## General Evaluation Criteria

### Grading Scale

| Level | Score | Description |
|-------|-------|-------------|
| **Excellent** | 100% | Elegant solution, exceeds requirements |
| **Very Good** | 85% | All requirements correctly fulfilled |
| **Good** | 70% | Correct functionality, minor problems |
| **Satisfactory** | 55% | Partially works |
| **Insufficient** | 30% | Attempt, does not work |
| **Absent** | 0% | Not submitted or plagiarised |

---

## PART 1: Find Master (20%)

### 1.1 Find Commands with Multiple Criteria (8%)

| Criterion | Pts | Excellent | Satisfactory | Insufficient |
|-----------|-----|-----------|--------------|--------------|
| Combined criteria | 3 | `-name AND -mtime AND -size` | 2 criteria | 1 criterion |
| `-type f/d` correct | 2 | Clear distinction files/directories | Works | Missing or incorrect |
| Logical operators | 3 | `-a`, `-o`, `!` used correctly | Partial | Missing |

**Reference solution:**
```bash
find /var/log -type f -name "*.log" -mtime -7 -size +1M
find . -type f \( -name "*.tmp" -o -name "*.bak" \) -mtime +30
```

### 1.2 Find with Actions (6%)

| Criterion | Pts | Excellent | Satisfactory | Insufficient |
|-----------|-----|-----------|--------------|--------------|
| `-exec` correct | 3 | `{} \;` or `{} +` | Works | Syntax errors |
| `-delete` safe | 2 | Preceded by `-print` for verification | Direct delete | Dangerous |
| `-printf` formatted | 1 | Custom output format | Works | Missing |

### 1.3 Find with xargs (6%)

| Criterion | Pts | Excellent | Satisfactory | Insufficient |
|-----------|-----|-----------|--------------|--------------|
| `-print0 \| xargs -0` | 3 | Correct handling of spaces in names | Simple `xargs` | Missing xargs |
| Efficient processing | 2 | Batch processing demonstrated | Functional | One-by-one |
| `-I{}` placeholder | 1 | Correct usage | Works | Missing |

**Reference solution:**
```bash
find . -name "*.txt" -print0 | xargs -0 -I{} cp {} backup/
```

---

## PART 2: Professional Script with getopts (30%)

### 2.1 Script Structure (8%)

| Criterion | Pts | Excellent | Satisfactory | Insufficient |
|-----------|-----|-----------|--------------|--------------|
| Complete header | 2 | Author, date, description, usage | Partial | Missing |
| Shebang + set | 2 | `#!/bin/bash` + `set -euo pipefail` | Shebang only | Missing |
| usage() function | 2 | Complete help with examples | Basic help | Missing |
| Variables declared | 2 | Defaults and validation | Partial | Hardcoded |

### 2.2 getopts Implementation (12%)

| Criterion | Pts | Excellent | Satisfactory | Insufficient |
|-----------|-----|-----------|--------------|--------------|
| Short options | 4 | Minimum `-h -v -f FILE -n NUM` | 3 options | Under 3 |
| Options with argument | 4 | `:` correct in optstring | Works | Errors |
| Invalid options | 2 | Case `?` and `:` handled | Generic message | Crash |
| shift OPTIND | 2 | Positional arguments accessible | Partial | Missing |

**Reference solution:**
```bash
while getopts ":hvf:n:" opt; do
    case $opt in
        h) usage; exit 0 ;;
        v) VERBOSE=true ;;
        f) FILE="$OPTARG" ;;
        n) COUNT="$OPTARG" ;;
        :) echo "Option -$OPTARG requires argument" >&2; exit 1 ;;
        ?) echo "Invalid option -$OPTARG" >&2; usage; exit 1 ;;
    esac
done
shift $((OPTIND-1))
```

### 2.3 Functionality (10%)

| Criterion | Pts | Excellent | Satisfactory | Insufficient |
|-----------|-----|-----------|--------------|--------------|
| Logic implemented | 5 | All required functionalities | 70%+ | Under 50% |
| Verbose mode | 2 | Detailed information when `-v` | Partial | Missing |
| Exit codes | 2 | 0 success, 1 user error, 2 system error | Partial | Missing |
| Error handling | 1 | Clear error messages | Generic | Missing |

---

## PART 3: Permission Manager (25%)

### 3.1 Permission Understanding (8%)

| Criterion | Pts | Excellent | Satisfactory | Insufficient |
|-----------|-----|-----------|--------------|--------------|
| Octal correct | 3 | 755, 644, 700 explained and applied | Works | Confusion |
| Symbolic correct | 3 | u+x, g-w, o=r explained and applied | Works | Confusion |
| Sticky, SUID, SGID | 2 | Demonstration and explanation | Mentioned | Missing |

### 3.2 Audit Script (10%)

| Criterion | Pts | Excellent | Satisfactory | Insufficient |
|-----------|-----|-----------|--------------|--------------|
| Detect world-writable | 3 | `find -perm -002` correct | Works | Incorrect |
| Detect SUID/SGID | 3 | `-perm -4000` and `-perm -2000` | One of two | Missing |
| Formatted report | 2 | Categories, counts, details | Simple listing | Raw output |
| Recommendations | 2 | Remediation suggestions | Partial | Missing |

**Reference solution:**
```bash
echo "=== World-Writable Files ==="
find "$TARGET_DIR" -type f -perm -002 -ls 2>/dev/null | head -20

echo "=== SUID Files ==="
find "$TARGET_DIR" -type f -perm -4000 -ls 2>/dev/null
```

### 3.3 Automatic Remediation (7%)

| Criterion | Pts | Excellent | Satisfactory | Insufficient |
|-----------|-----|-----------|--------------|--------------|
| Dry-run mode | 3 | Shows what it would do without executing | Missing dry-run | Direct modification |
| Confirmation | 2 | Asks before modifications | Partial | No confirmation |
| Logging | 2 | Records all modifications | Partial | Missing |

---

## PART 4: Cron Jobs (15%)

### 4.1 Crontab Syntax (5%)

| Criterion | Pts | Excellent | Satisfactory | Insufficient |
|-----------|-----|-----------|--------------|--------------|
| Correct format | 2 | Min Hour Day Month Weekday Cmd | Works | Syntax errors |
| Varied schedules | 2 | Daily, weekly, specific time | 2 types | 1 type |
| Absolute paths | 1 | Commands with full path | Partial | Relative paths |

**Correct examples:**
```
0 2 * * * /home/user/backup.sh >> /var/log/backup.log 2>&1
30 4 * * 0 /usr/local/bin/weekly_cleanup.sh
*/15 * * * * /home/user/monitor.sh
```

### 4.2 Backup Script (6%)

| Criterion | Pts | Excellent | Satisfactory | Insufficient |
|-----------|-----|-----------|--------------|--------------|
| Complete backup | 2 | tar.gz with timestamp | Simple tar | cp |
| Rotation | 2 | Keeps N versions, deletes old | Mentioned | Missing |
| Logging | 2 | Timestamp, status, errors | Partial | Missing |

### 4.3 Error Handling in Cron (4%)

| Criterion | Pts | Excellent | Satisfactory | Insufficient |
|-----------|-----|-----------|--------------|--------------|
| Redirect stderr | 2 | `2>&1` in crontab | Partial | Missing |
| Lock file | 2 | Prevents simultaneous runs | Mentioned | Missing |

---

## PART 5: Integration Challenge (10%)

### Sysadmin Toolkit (10%)

| Criterion | Pts | Excellent | Satisfactory | Insufficient |
|-----------|-----|-----------|--------------|--------------|
| Interactive menu | 2 | Case + loop | Works | Missing |
| Find integration | 2 | Advanced search function | Basic | Missing |
| Permissions integration | 2 | Audit + remediation | Audit only | Missing |
| Getopts for CLI | 2 | Options for non-interactive mode | Partial | Missing |
| Stability | 2 | Complete error handling | Partial | Fragile |

---

## BONUS (up to +20% bonus)

| Exercise | Points | Requirement |
|----------|--------|-------------|
| find with ACL | +5 | `getfacl`, `setfacl` integrated |
| inotifywait | +5 | Real-time monitoring with actions |
| Cron GUI | +5 | Interactive crontab generation script |
| Incremental backup | +5 | rsync with timestamps |

---

## Cross-Cutting Criteria

### Code Quality (adjustment: -5% to +5% of final grade)

| Aspect | Bonus | Penalty |
|--------|-------|---------|
| Comments | +1 | -1 |
| ShellCheck clean | +2 | -2 |
| Variables quoted | +1 | -2 |
| `set -euo pipefail` | +1 | 0 |

---

## Special Penalties

| Situation | Penalty |
|-----------|---------|
| Plagiarism | **-100%** |
| Late < 24h | -10% |
| Wrong structure | -5% |
| Non-executable scripts | -1% per script |
| Dangerous commands without confirmation | -10% |

---

## Evaluation Checklist

```
□ .tar.gz archive extractable
□ parte1_find/comenzi_find.sh present
□ parte2_script/fileprocessor.sh with getopts
□ parte3_permissions/permaudit.sh functional
□ parte4_cron/cron_entries.txt valid
□ parte5_integration/sysadmin_toolkit.sh complete
□ README.md with documentation
□ All scripts executable
□ ShellCheck without errors
```

---

*Internal document | Seminar 3: System Administrator Toolkit*
