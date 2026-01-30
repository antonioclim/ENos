# Evaluation Rubric - Seminar 5 Assignment

> **Document for instructor** | Not to be distributed to students before evaluation

---

## Grading System Legend

| Symbol | Meaning | Example |
|--------|---------|---------|
| **%** | Percentage of final assignment grade (100%) | REQUIREMENT 1: 40% of total |
| **Pts (in tables)** | Relative points within section | 4 pts out of the 12% of the sub-section |
| **Adjustment ±X%** | Percentage modification applied to final grade | Code quality: ±10% |

> **Important note**: Points in table columns (Pts) are **relative points** that are added together to form the percentage of that section. Example: in REQUIREMENT 1 (40%), sub-sections of 12 + 12 + 8 + 8 = 40 relative points equate to 40% of the final grade.

---

## General Evaluation Criteria

### Grading Scale

| Level | Score | Description |
|-------|-------|-------------|
| **Excellent** | 100% | Professional code, exceeds requirements |
| **Very Good** | 85% | All requirements correctly fulfilled |
| **Good** | 70% | Correct functionality, minor issues |
| **Satisfactory** | 55% | Partially works |
| **Insufficient** | 30% | Attempt made, does not work |
| **Absent** | 0% | Not submitted or copied |

---

## REQUIREMENT 1: Log Analyser (40%)

### 1.1 Parsing and Structure (12%)

| Criterion | Pts | Excellent | Satisfactory | Insufficient |
|-----------|-----|-----------|--------------|--------------|
| `set -euo pipefail` | 2 | Present in header | Missing but works | Missing + errors |
| Argument parsing | 4 | getopts with -h, -v, -l, -o, --top | 3-4 options | Under 3 |
| Log line parsing | 4 | Regex/BASH_REMATCH correct | Works | Errors |
| Input validation | 2 | Verifies file existence | Generic message | Crash |

**Parsing solution:**
```bash
if [[ "$line" =~ ^\[([^\]]+)\]\ \[([A-Z]+)\]\ (.*)$ ]]; then
    local timestamp="${BASH_REMATCH[1]}"
    local level="${BASH_REMATCH[2]}"
    local message="${BASH_REMATCH[3]}"
fi
```

### 1.2 Arrays and Statistics (12%)

| Criterion | Pts | Excellent | Satisfactory | Insufficient |
|-----------|-----|-----------|--------------|--------------|
| `declare -A LEVEL_COUNT` | 3 | Correctly declared and used | Works | Indexed array |
| `declare -A MESSAGE_COUNT` | 3 | Message counting for top N | Works | Missing |
| Percentages calculated | 3 | `printf "%.1f%%"` correct | Approximate | Missing |
| Time range | 3 | First/last timestamp extracted | Partial | Missing |

### 1.3 Functions with `local` (10%)

| Criterion | Pts | Excellent | Satisfactory | Insufficient |
|-----------|-----|-----------|--------------|--------------|
| `parse_line()` with local | 2.5 | All variables local | Partially local | Global |
| `count_levels()` with local | 2.5 | Iterator local | Partial | Global |
| `get_top_messages()` with local | 2.5 | Sort and limit local | Partial | Global |
| `print_report()` with local | 2.5 | Local formatting | Partial | Global |

### 1.4 Output and Robustness (6%)

| Criterion | Pts | Excellent | Satisfactory | Insufficient |
|-----------|-----|-----------|--------------|--------------|
| Formatted report | 3 | Box chars, alignment, colours | Functional | Raw |
| trap EXIT | 2 | Cleanup implemented | Mentioned | Missing |
| Output to file -o | 1 | Redirect functional | Missing | Errors |

---

## REQUIREMENT 2: Config Manager (30%)

### 2.1 Config Parsing (10%)

| Criterion | Pts | Excellent | Satisfactory | Insufficient |
|-----------|-----|-----------|--------------|--------------|
| Ignores comments | 2 | `^[[:space:]]*#` filtered | Works | Includes comments |
| Ignores empty lines | 2 | Correctly filtered | Works | Includes |
| key=value parsing | 3 | Regex or IFS= correct | Works | Errors with spaces |
| `declare -A CONFIG` | 3 | Correct storage | Works | Indexed array |

**Parsing solution:**
```bash
while IFS= read -r line || [[ -n "$line" ]]; do
    [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue
    if [[ "$line" =~ ^([^=]+)=(.*)$ ]]; then
        local key="${BASH_REMATCH[1]// /}"
        local value="${BASH_REMATCH[2]}"
        CONFIG["$key"]="$value"
    fi
done < "$CONFIG_FILE"
```

### 2.2 CRUD Commands (12%)

| Criterion | Pts | Excellent | Satisfactory | Insufficient |
|-----------|-----|-----------|--------------|--------------|
| `get <key>` | 3 | Returns value or error | Works | Crash on missing |
| `set <key> <value>` | 3 | Adds/updates + save | Works | Does not save |
| `delete <key>` | 3 | Deletes + save | Works | Does not save |
| `list` | 3 | Nicely formatted | Simple listing | Raw |

### 2.3 Validation and Export (8%)

| Criterion | Pts | Excellent | Satisfactory | Insufficient |
|-----------|-----|-----------|--------------|--------------|
| Required keys | 3 | REQUIRED_KEYS verified | Partial | Missing |
| Format validation | 3 | PORT numeric, etc. | One type validated | Missing |
| `export` functional | 2 | `export KEY=VALUE` correct | Works | Errors |

---

## REQUIREMENT 3: Refactoring Challenge (30%)

### 3.1 Problem Identification (10%)

| Problem | Pts | Correct | Partial | Incorrect |
|---------|-----|---------|---------|-----------|
| Missing `set -euo pipefail` | 1 | Added | - | Missing |
| `$*` → `"$@"` | 1 | Corrected | - | Unchanged |
| `${files[@]}` → `"${files[@]}"` | 1 | Corrected | - | Unchanged |
| Global variable in function | 1 | `local count=0` | - | Global |
| `$file` → `"$file"` | 1 | Corrected | - | Unchanged |
| UUOC `cat \| wc` → `wc < file` | 1 | Corrected | - | cat kept |
| `declare -A config` | 1 | Added | - | Missing |
| Input validation | 1 | Implemented | Partial | Missing |
| usage() | 1 | Complete | Minimal | Missing |
| trap cleanup | 1 | Implemented | Partial | Missing |

### 3.2 Professional Template Application (12%)

| Criterion | Pts | Excellent | Satisfactory | Insufficient |
|-----------|-----|-----------|--------------|--------------|
| Complete header | 2 | Author, description, version | Partial | Missing |
| Clear sections | 2 | VARIABLES, FUNCTIONS, MAIN | 2 sections | Unorganised |
| Argument parsing | 3 | case + shift correct | Works | Missing |
| Error handling | 3 | Exit codes, messages | Partial | Missing |
| Logging/verbose | 2 | -v implemented | Partial | Missing |

### 3.3 Correct Functionality (8%)

| Criterion | Pts | Excellent | Satisfactory | Insufficient |
|-----------|-----|-----------|--------------|--------------|
| File processing | 4 | All files processed correctly | Most | Errors |
| Identical output | 2 | Same result as original (when working) | Close to | Different |
| Config used | 2 | Associative array functional | Partial | Unused |

---

## Cross-Cutting Criteria

### Code Style (adjustment: -10% to +10% of final grade)

| Aspect | Bonus | Penalty |
|--------|-------|---------|
| ShellCheck 0 warnings | +3 | -1 per warning |
| Useful comments | +2 | -2 |
| UPPERCASE variables for globals | +1 | -1 |
| lowercase variables for locals | +1 | -1 |
| Documented functions | +2 | 0 |
| Unit tests for functions | +5 | 0 |

### Robustness

| Aspect | Bonus | Penalty |
|--------|-------|---------|
| All variables quoted | +2 | -3 |
| Correct exit codes | +1 | -2 |
| Cleanup in trap | +1 | 0 |

---

## Special Penalties

| Situation | Penalty |
|-----------|---------|
| Plagiarism | **-100%** |
| Late < 24h | -10% |
| Late 24-72h | -25% |
| Late > 72h | -50% |
| ShellCheck errors (not warnings) | -5% per error |
| Missing `set -euo pipefail` | -5% per script |
| Non-local variables in functions | -3% per instance |
| Arrays without quotes in for | -3% per instance |
| Missing `declare -A` for associative | -5% per array |

---

## BONUS (up to +10% bonus)

| Criterion | Points |
|-----------|--------|
| Very clean code | +5 |
| Useful extra functionality | +5 |
| Complete unit tests | +5 |
| **Maximum bonus** | **+10** |

---

## Quick Evaluation Checklist

```
□ Archive with correct structure
□ log_analyzer.sh
  □ shellcheck clean
  □ set -euo pipefail
  □ declare -A for arrays
  □ Functions with local
  □ Complete argument parsing
□ config_manager.sh
  □ shellcheck clean
  □ All commands functional
  □ declare -A CONFIG
  □ Validation implemented
□ refactored_script.sh
  □ All 10 problems corrected
  □ Professional template applied
  □ shellcheck clean
□ README.md present
□ Test files included
```

---

## Expected Grade Distribution

| Grade | Range | Description |
|-------|-------|-------------|
| 10 | 95-100 + bonus | Professional code, all requirements + extra |
| 9 | 85-94 | All requirements, very good style |
| 8 | 75-84 | Works, minor style issues |
| 7 | 65-74 | Works, moderate issues |
| 6 | 55-64 | Partially functional |
| 5 | 45-54 | Minimum acceptable |

---

*Internal document | Seminar 5: Advanced Bash Scripting*
