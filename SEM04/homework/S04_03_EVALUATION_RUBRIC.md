# Assessment Rubric - Seminar 4 Assignment

> **Instructor document** | Do not distribute to students before assessment

---

## Scoring System Legend

| Symbol | Meaning | Example |
|--------|---------|---------|
| **%** | Percentage of final assignment grade (100%) | Exercise 1: 25% of total |
| **Pts (in tables)** | Relative points within the section | 4 pts from the 10% of sub-section |
| **Adjustment ±X%** | Percentage modification applied to final grade | Code quality: ±5% |

> **Important note**: Points in table columns (Pts) are **relative points** that add up to form the respective section percentage. Example: in Exercise 1 (25%), sub-sections of 10 + 8 + 7 = 25 relative points equate to 25% of the final grade.

---

## General Assessment Criteria

### Scoring Scale per Criterion

| Level | Score | Description |
|-------|-------|-------------|
| **Excellent** | 100% | Exceeds expectations, elegant and complete solution |
| **Very Good** | 85% | All requirements correctly fulfilled |
| **Good** | 70% | Correct functionality with minor issues |
| **Satisfactory** | 55% | Partially functional, missing elements |
| **Insufficient** | 30% | Attempt at solution, does not work |
| **Absent** | 0% | Not submitted or plagiarised |

---

## Exercise 1: Data Validation and Extraction (25%)

### 1.1 Email Validation (10%)

| Criterion | Pts | Excellent | Satisfactory | Insufficient |
|-----------|-----|-----------|--------------|--------------|
| Correct regex | 4 | Detects all valid formats, rejects invalid | Detects most, some false positive/negative | Simplistic pattern, many errors |
| Valid/invalid separation | 3 | Correct listing with explanations | Correct listing without details | Confusing output |
| Counting | 2 | Complete statistics | Only total | Missing or incorrect |
| Edge cases | 1 | Handles `.co.uk`, `+alias`, etc. | Handles simple cases | Crash on unexpected input |

**Minimum acceptable regex:**
```bash
[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}
```

**Excellent regex (bonus):**
```bash
^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(\.[a-zA-Z]{2,})+$
```

### 1.2 IP Extraction (8%)

| Criterion | Pts | Excellent | Satisfactory | Insufficient |
|-----------|-----|-----------|--------------|--------------|
| IP pattern | 3 | Strict validation (0-255 per octet) | Simple pattern `[0-9.]+` | Does not work |
| Uniqueness | 2 | `sort -u` or equivalent | Some duplicates | Lists with duplicates |
| Numeric sorting | 2 | `sort -t. -k1,1n -k2,2n...` | Alphabetic sorting | Unsorted |
| Output | 1 | Clean format, one per line | Acceptable | Confusing |

**Strict IP validation (bonus +1%):**
```bash
grep -oE '(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)(\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)){3}'
```

### 1.3 RO Phone Numbers (7%)

| Criterion | Pts | Excellent | Satisfactory | Insufficient |
|-----------|-----|-----------|--------------|--------------|
| Multiple formats | 4 | 07XX-XXX-XXX, 07XX.XXX.XXX, 07XX XXX XXX, 07XXXXXXXX | 2-3 formats | Single format |
| Correct prefix | 2 | Validates 07[2-9]X | Accepts any 07XX | Accepts any number |
| Output | 1 | Normalised or original | Original | Partial/corrupted |

---

## Exercise 2: Log Processing (25%)

### 2.1 Severity Report (8%)

| Criterion | Pts | Excellent | Satisfactory | Insufficient |
|-----------|-----|-----------|--------------|--------------|
| Correct counting | 4 | All levels, exact | Most correct | Significant errors |
| Percentages | 2 | Calculated correctly, formatted | Correct but unformatted | Missing or wrong |
| Visualisation | 2 | ASCII/bar chart | Simple table | Text only |

**Reference solution:**
```bash
awk -F'[][]' '{count[$2]++} END {for(l in count) printf "%-10s %d\n", l, count[l]}'
```

### 2.2 Failed Authentication (9%)

| Criterion | Pts | Excellent | Satisfactory | Insufficient |
|-----------|-----|-----------|--------------|--------------|
| Detection | 4 | All cases "failed", "denied", etc. | Only explicit "failed" | Missing or incomplete |
| Data extraction | 3 | User, IP, timestamp correct | 2 of 3 correct | Under 2 correct |
| Output format | 2 | Organised table | Simple listing | Raw output |

### 2.3 General Statistics (8%)

| Criterion | Pts | Excellent | Satisfactory | Insufficient |
|-----------|-----|-----------|--------------|--------------|
| Period | 3 | First/last timestamp correct | Approximate | Incorrect |
| Total events | 2 | Exact | Correct | Incorrect |
| Error rate | 3 | Calculated and formatted % | Number only | Missing |

---

## Exercise 3: Data Transformation (25%)

### 3.1 Table Conversion (10%)

| Criterion | Pts | Excellent | Satisfactory | Insufficient |
|-----------|-----|-----------|--------------|--------------|
| CSV parsing | 3 | Correct with header skip | Works | Errors with commas |
| Column alignment | 3 | `printf` with fixed width | Partially aligned | Unaligned |
| Salary format | 2 | $XX,XXX with thousands separator | $ only | Raw number |
| Header/border | 2 | Box drawing characters | Simple lines | None |

**Salary formatting solution:**
```bash
awk '{printf "$%\047d\n", $5}'  # or
printf "%'d" $salary
```

### 3.2 Department Statistics (8%)

| Criterion | Pts | Excellent | Satisfactory | Insufficient |
|-----------|-----|-----------|--------------|--------------|
| Aggregation | 4 | AWK associative arrays | Functional alternative solution | Does not aggregate |
| Calculations | 3 | Average, min, max correct | Average only | Calculation errors |
| Output | 1 | Formatted table | Listing | Unformatted text |

**Reference solution:**
```bash
awk -F',' 'NR>1 {
    dept=$4; sal=$5
    count[dept]++; sum[dept]+=sal
    if(!min[dept] || sal<min[dept]) min[dept]=sal
    if(sal>max[dept]) max[dept]=sal
} END {
    for(d in count) printf "%-12s %3d %8.0f %8d %8d\n", 
        d, count[d], sum[d]/count[d], min[d], max[d]
}'
```

### 3.3 Updated File (7%)

| Criterion | Pts | Excellent | Satisfactory | Insufficient |
|-----------|-----|-----------|--------------|--------------|
| Lowercase email | 2 | `tolower()` or `tr` | Works | Does not modify |
| Status change | 2 | sed or awk correct | Works | Errors |
| New column | 3 | Years calculation correct | Acceptable approximation | Missing or wrong |

---

## Exercise 4: Combined Pipeline (25%)

### 4.1 Sales Report (10%)

| Criterion | Pts | Excellent | Satisfactory | Insufficient |
|-----------|-----|-----------|--------------|--------------|
| Top products | 4 | Revenue calculated correctly, sorted | Correct but top 1 | Incorrect |
| Top regions | 3 | Correct aggregation | Works | Errors |
| Top seller/region | 3 | Grouping + max | Partial | Does not work |

### 4.2 Anomaly Detection (8%)

| Criterion | Pts | Excellent | Satisfactory | Insufficient |
|-----------|-----|-----------|--------------|--------------|
| Date gaps | 3 | Automatic detection | Hardcoded | Missing |
| Outliers | 4 | mean + 2*stddev | Reasonable fixed threshold | Does not detect |
| Reporting | 1 | Clear and specific | Functional | Confusing |

### 4.3 Export (7%)

| Criterion | Pts | Excellent | Satisfactory | Insufficient |
|-----------|-----|-----------|--------------|--------------|
| File created | 3 | Correct redirect | Works | Errors |
| Format | 2 | Professional, readable | Acceptable | Unformatted |
| Completeness | 2 | All data | Most | Partial |

---

## Cross-Cutting Criteria (applied to all exercises)

### Code Quality (adjustment: -5% to +5% of final grade)

| Aspect | Bonus | Penalty |
|--------|-------|---------|
| Useful comments | +1 | -1 (total absence) |
| Clear variable names | +1 | -1 (x, y, tmp) |
| `set -euo pipefail` | +1 | -1 (fragile script) |
| Argument verification | +1 | -2 (crash without args) |
| Modular functions | +1 | 0 |

### Error Handling (adjustment: -3% to +2% of final grade)

| Aspect | Bonus | Penalty |
|--------|-------|---------|
| Checks file existence | +1 | -1 |
| Clear error messages | +1 | -1 |
| Correct exit codes | 0 | -1 |

---

## Special Penalties

| Situation | Penalty |
|-----------|---------|
| Plagiarism detected | **-100%** (0 points) |
| Late submission (< 24h) | -10% |
| Late submission (24-72h) | -25% |
| Late submission (> 72h) | -50% or refused |
| Missing files from archive | -5% per file |
| Non-executable script | -5% per script |
| Does not work on standard Linux | -20% |

---

## Quick Assessment Checklist

```
□ Archive extractable and correct structure
□ All scripts present and executable
□ Ex1: validator.sh - runs on contacts.txt
□ Ex2: log_analyzer.sh - runs on server.log  
□ Ex3: data_transform.sh - runs on employees.csv
□ Ex4: sales_report.sh - runs on sales.csv
□ Outputs generated in output/ folder
□ Code commented and with header
□ Checked for plagiarism (diff with other submissions)
```

---

## Expected Grade Distribution

| Grade | Score Range | Description |
|-------|-------------|-------------|
| 10 | 95-100 + bonus | Excellent, exceeds requirements |
| 9 | 85-94 | Very good, all requirements |
| 8 | 75-84 | Good, minor issues |
| 7 | 65-74 | Satisfactory, functional |
| 6 | 55-64 | Acceptable, multiple issues |
| 5 | 45-54 | Minimum acceptable |
| 4 | 30-44 | Insufficient |
| 1-3 | <30 | Failed |

---

*Internal document for assessors | Seminar 4: Text Processing*
