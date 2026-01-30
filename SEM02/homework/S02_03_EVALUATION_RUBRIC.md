# Evaluation Rubric - Seminar 2 Assignment

> **Document for instructor** | Not to be distributed to students before evaluation

---

## Scoring System Legend

| Symbol | Meaning | Example |
|--------|---------|---------|
| **%** | Percentage of final assignment grade (100%) | PART 1: 20% of total |
| **Pts (in tables)** | Relative points within the section | 3 pts out of the 7% for the exercise |
| **Adjustment ±X%** | Percentage modification applied to final grade | Code quality: ±5% |

> **Important Note**: Points in table columns (Pts) are **relative points** that add up to form the percentage for that section. Example: in PART 1 (20%), exercises of 7 + 7 + 6 = 20 relative points equal 20% of the final grade.

---

## General Evaluation Criteria

### Grading Scale

| Level | Score | Description |
|-------|-------|-------------|
| **Excellent** | 100% | Exceeds expectations, elegant solution |
| **Very Good** | 85% | All requirements correctly fulfilled |
| **Good** | 70% | Correct functionality with minor issues |
| **Satisfactory** | 55% | Partially functional |
| **Insufficient** | 30% | Attempt made, doesn't work |
| **Absent** | 0% | Not submitted or plagiarised |

---

## PART 1: Control Operators (20%)

### Ex 1.1: Backup Safe (7%)

| Criterion | Pts | Excellent | Satisfactory | Insufficient |
|-----------|-----|-----------|--------------|--------------|
| Argument check | 2 | Handles missing argument | Generic error | Crash |
| Operators `&&` `||` | 3 | Correct logic, no if | Uses if but works | Doesn't work |
| Timestamp in name | 2 | Correct format `date +%Y%m%d_%H%M%S` | Partial timestamp | Missing timestamp |

**Reference solution:**
```bash
[[ -z "$1" ]] && echo "Usage: $0 <file>" && exit 1
[[ -f "$1" ]] && mkdir -p backup && cp "$1" "backup/${1%.*}_$(date +%Y%m%d_%H%M%S).${1##*.}" && echo "✓ Backup created" || echo "✗ File doesn't exist"
```

### Ex 1.2: Multi-Command (7%)

| Criterion | Pts | Excellent | Satisfactory | Insufficient |
|-----------|-----|-----------|--------------|--------------|
| Valid one-liner | 3 | Single complete line | Multiple lines | Doesn't work |
| All files created | 2 | README.md, main.sh, .gitignore | 2 of 3 | Under 2 |
| Final message | 2 | Displays directory contents | Simple message | Missing |

### Ex 1.3: Parallel Demo (6%)

| Criterion | Pts | Excellent | Satisfactory | Insufficient |
|-----------|-----|-----------|--------------|--------------|
| Parallel processes `&` | 3 | Demonstrable parallel sleeps | Works | Sequential |
| Timing demonstration | 2 | Measurement with `time` | Mentioned | Missing |
| Correct wait | 1 | `wait` at end | Missing but works | Orphan processes |

---

## PART 2: Redirection (20%)

### Ex 2.1: Log Separator (7%)

| Criterion | Pts | Excellent | Satisfactory | Insufficient |
|-----------|-----|-----------|--------------|--------------|
| Redirect stdout | 3 | `> normal.log` correct | Works | Incorrect |
| Redirect stderr | 3 | `2> errors.log` correct | Works | Incorrect |
| Files created | 1 | Both with correct content | One correct | Missing |

### Ex 2.2: Config Generator (7%)

| Criterion | Pts | Excellent | Satisfactory | Insufficient |
|-----------|-----|-----------|--------------|--------------|
| Here document | 4 | `<< EOF` correct | Works | Multiple echos |
| Variables in heredoc | 2 | `$USER`, `$HOME` expanded | Partial | All literal |
| Config structure | 1 | Correct INI/conf format | Correct content | Unformatted |

### Ex 2.3: Silent Runner (6%)

| Criterion | Pts | Excellent | Satisfactory | Insufficient |
|-----------|-----|-----------|--------------|--------------|
| Redirect to /dev/null | 3 | `&>/dev/null` or `>/dev/null 2>&1` | Only stdout | Shows output |
| Return code checked | 2 | Uses `$?` correctly | Mentioned | Missing |
| Success/error message | 1 | Clear messages | Generic message | Missing |

---

## PART 3: Filters and Pipelines (25%)

### Ex 3.1: Top Words (6%)

| Criterion | Pts | Excellent | Satisfactory | Insufficient |
|-----------|-----|-----------|--------------|--------------|
| Correct pipeline | 3 | `tr \| sort \| uniq -c \| sort -rn \| head` | Works differently | Doesn't work |
| Lowercase | 1 | `tr 'A-Z' 'a-z'` | Different method | Case-sensitive |
| Top N parameterised | 2 | Accepts argument for N | Hardcoded 10 | Missing |

**Reference solution:**
```bash
tr -cs 'A-Za-z' '\n' < "$1" | tr 'A-Z' 'a-z' | sort | uniq -c | sort -rn | head -n "${2:-10}"
```

### Ex 3.2: CSV Analyser (7%)

| Criterion | Pts | Excellent | Satisfactory | Insufficient |
|-----------|-----|-----------|--------------|--------------|
| CSV parsing | 3 | `cut -d,` or `awk -F,` | Works | Errors |
| Correct statistics | 2 | Count, sum, avg | 2 of 3 | Under 2 |
| Header skip | 2 | `NR>1` or `tail -n+2` | Works | Includes header |

### Ex 3.3: Log Stats (6%)

| Criterion | Pts | Excellent | Satisfactory | Insufficient |
|-----------|-----|-----------|--------------|--------------|
| Pattern extraction | 3 | grep/awk for IP, date, etc. | Partial | Incorrect |
| Aggregation | 2 | `sort \| uniq -c` | Works | Missing |
| Output formatting | 1 | Aligned table | Listing | Raw |

### Ex 3.4: Frequency Counter (6%)

| Criterion | Pts | Excellent | Satisfactory | Insufficient |
|-----------|-----|-----------|--------------|--------------|
| Correct counting | 3 | Exact frequencies | Approximate | Errors |
| Descending sort | 2 | `-rn` correct | Sorted differently | Unsorted |
| Formatted output | 1 | Aligned printf | Functional | Raw |

---

## PART 4: Loops (20%)

### Ex 4.1: Batch Rename (5%)

| Criterion | Pts | Excellent | Satisfactory | Insufficient |
|-----------|-----|-----------|--------------|--------------|
| Correct for loop | 2 | `for f in *.txt` | Different pattern | Hardcoded |
| Safe rename | 2 | `mv "$f" "..."` with quotes | Works | Errors with spaces |
| Logging | 1 | Displays what was renamed | Final message | Silent |

### Ex 4.2: File Processor (5%)

| Criterion | Pts | Excellent | Satisfactory | Insufficient |
|-----------|-----|-----------|--------------|--------------|
| Correct while read | 3 | `while IFS= read -r line` | `while read line` | for with cat |
| Processing | 2 | Action on each line | Works | Missing |

### Ex 4.3: Countdown (5%)

| Criterion | Pts | Excellent | Satisfactory | Insufficient |
|-----------|-----|-----------|--------------|--------------|
| Correct until/while | 2 | Correctly inverted logic | Descending for | Incorrect |
| Argument validated | 2 | Checks positive number | Works | Crash on invalid |
| Sleep 1 | 1 | Pause between numbers | Different pause | No pause |

### Ex 4.4: Menu System (5%)

| Criterion | Pts | Excellent | Satisfactory | Insufficient |
|-----------|-----|-----------|--------------|--------------|
| Case statement | 3 | Minimum 4 options | 3 options | Under 3 |
| Loop for repetition | 1 | Returns to menu | One-shot | Missing |
| Quit option | 1 | Clean exit | Ctrl+C | Missing |

---

## PART 5: Final Project (15%)

### System Report (15%)

| Criterion | Pts | Excellent | Satisfactory | Insufficient |
|-----------|-----|-----------|--------------|--------------|
| Complete system info | 4 | hostname, uptime, kernel, CPU, RAM | 4 of 5 | Under 4 |
| Disk usage | 3 | Nicely parsed `df -h` | Raw df | Missing |
| Top processes | 3 | `ps aux` + sort + head | Works | Missing |
| Network | 2 | IPs, interfaces | Partial | Missing |
| Report formatting | 3 | Clear sections, borders | Functional | Raw |

---

## BONUS (up to +20% bonus)

| Exercise | Points | Requirement |
|----------|--------|-------------|
| Parallel download | +5 | wget/curl in parallel with & and wait |
| Log rotator | +5 | Automatic compression and numbering |
| Incremental backup | +5 | Compare timestamps, copy only modified |
| Interactive installer | +5 | Menu + checks + installation |

---

## Transversal Criteria

### Code Quality (adjustment: -5% to +5% of final grade)

| Aspect | Bonus | Penalty |
|--------|-------|---------|
| Comments | +1 | -1 |
| Shebang present | 0 | -2 |
| +x permissions | 0 | -1 per script |
| Quotes on variables | +1 | -2 |
| `set -e` used | +1 | 0 |

---

## Special Penalties

| Situation | Penalty |
|-----------|---------|
| Plagiarism | **-100%** |
| Late < 24h | -10% |
| Late 24-72h | -25% |
| Wrong structure | -5% |
| REFLECTION.md missing | -10% |

---

## Evaluation Checklist

```
□ Archive extractable
□ Correct directory structure
□ part1_operators/ - 3 scripts
□ part2_redirection/ - 3 scripts
□ part3_filters/ - 4 scripts
□ part4_loops/ - 4 scripts
□ part5_project/ - system_report.sh
□ README.md completed
□ REFLECTION.md present
□ All scripts executable
```

---

*Internal document | Seminar 2: Pipeline Master*
