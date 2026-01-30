# Evaluation Rubric - Seminar 1 Assignment

> **Document for instructor** | Not to be distributed to students before evaluation

---

## Scoring System Legend

| Symbol | Meaning | Example |
|--------|---------|---------|
| **%** | Percentage of the final assignment grade (100%) | Section 1: 25% of total |
| **Pts (in tables)** | Relative points within the section | 4 pts out of the section's 10% |
| **Adjustment ±X%** | Percentage modification applied to final grade | Code quality: ±5% |

> **Important note**: Points in table columns (Pts) are **relative points** that add up to form the percentage of that section. Example: in Section 1 (25%), sub-criteria of 10 + 8 + 7 = 25 relative points equate to 25% of the final grade.

---

## General Evaluation Criteria

### Grading Scale per Criterion

| Level | Score | Description |
|-------|-------|-------------|
| **Excellent** | 100% | Exceeds expectations, elegant solution |
| **Very Good** | 85% | All requirements correctly fulfilled |
| **Good** | 70% | Correct functionality with minor issues |
| **Satisfactory** | 55% | Partially works, missing elements |
| **Insufficient** | 30% | Attempt at solving, does not work |
| **Absent** | 0% | Not submitted or copied |

---

## Section 1: Variables (25%)

### 1.1 Local Variables (10%)

| Criterion | Pts | Excellent | Satisfactory | Insufficient |
|-----------|-----|-----------|--------------|--------------|
| Correct definition | 4 | Minimum 3 variables, correct syntax | 2 correct variables | Syntax errors |
| Use in echo | 3 | Correctly interpolated in strings | Displayed individually | Not displayed |
| Varied types | 3 | String, number, path | Only strings | Single type |

### 1.2 Environment Variables (8%)

| Criterion | Pts | Excellent | Satisfactory | Insufficient |
|-----------|-----|-----------|--------------|--------------|
| Standard display | 4 | USER, HOME, SHELL, PATH | 3 out of 4 | Under 3 |
| Output formatting | 2 | Aligned, labelled | Functional | Unformatted |
| Explanations | 2 | Comments on what each does | Minimal comments | No comments |

### 1.3 Export and Subshell (7%)

| Criterion | Pts | Excellent | Satisfactory | Insufficient |
|-----------|-----|-----------|--------------|--------------|
| Export demo | 4 | Local/exported difference demonstrated | Partially demonstrated | Not demonstrated |
| Subshell test | 3 | `bash -c` correctly used | Works | Errors |

---

## Section 2: Quoting and Exit Codes (20%)

### 2.1 Single vs Double Quotes (10%)

| Criterion | Pts | Excellent | Satisfactory | Insufficient |
|-----------|-----|-----------|--------------|--------------|
| Single quotes demo | 3 | Unexpanded variable demonstrated | Works | Incorrect |
| Double quotes demo | 3 | Expanded variable demonstrated | Works | Incorrect |
| Escape characters | 2 | `\$`, `\"`, `\\` demonstrated | One demonstrated | Missing |
| Explanation | 2 | Clear comments | Minimal comments | None |

### 2.2 Exit Codes (10%)

| Criterion | Pts | Excellent | Satisfactory | Insufficient |
|-----------|-----|-----------|--------------|--------------|
| Capture `$?` | 4 | After successful and failed command | Only one | Incorrect |
| `ls` demonstration | 3 | Valid and invalid directory | One of two | Missing |
| Interpretation | 3 | Explanation of 0 vs non-0 | Mentioned | Missing |

---

## Section 3: Globbing and FHS (30%)

### 3.1 Creating Test Files (8%)

| Criterion | Pts | Excellent | Satisfactory | Insufficient |
|-----------|-----|-----------|--------------|--------------|
| Brace expansion | 4 | `touch file{1..10}.txt` | Individual commands | Manual |
| Extension variety | 2 | .txt, .pdf, .jpg minimum | Two types | One type |
| Hidden file | 2 | `.hidden` created and demonstrated | Created without demo | Missing |

### 3.2 Pattern Matching (12%)

| Criterion | Pts | Excellent | Satisfactory | Insufficient |
|-----------|-----|-----------|--------------|--------------|
| Wildcard `*` | 3 | `*.txt` correct | Works | Errors |
| Range `[1-5]` | 3 | `file[1-5].txt` correct | Works | Incorrect |
| Wildcard `?` | 3 | `?????.???` demonstrated | Partial | Missing |
| Explanation | 3 | Complete documentation | Comments | Missing |

### 3.3 Hidden Files (10%)

| Criterion | Pts | Excellent | Satisfactory | Insufficient |
|-----------|-----|-----------|--------------|--------------|
| Demo `ls *` vs `ls .*` | 5 | Difference explained | Demonstrated without explanation | Missing |
| Dotfiles explanation | 5 | Complete understanding of glob behaviour | Mentioned | Missing |

---

## Section 4: Personalised .bashrc (15%)

### 4.1 Aliases (6%)

| Criterion | Pts | Excellent | Satisfactory | Insufficient |
|-----------|-----|-----------|--------------|--------------|
| `ll` for ls -la | 2 | Correctly defined | Works | Missing |
| `cls` for clear | 1 | Correctly defined | Works | Missing |
| `..` for cd .. | 1 | Correctly defined | Works | Missing |
| Personal alias | 2 | Useful and functional | Defined | Missing or trivial |

### 4.2 Functions (6%)

| Criterion | Pts | Excellent | Satisfactory | Insufficient |
|-----------|-----|-----------|--------------|--------------|
| `mkcd` implemented | 4 | `mkdir -p && cd` correct | Partially works | Does not work |
| Extract function (bonus) | 2 | Case for tar.gz, zip, etc. | 2 formats | Missing |

### 4.3 Variables and PATH (3%)

| Criterion | Pts | Excellent | Satisfactory | Insufficient |
|-----------|-----|-----------|--------------|--------------|
| PATH modified | 1 | $HOME/bin added | Something else added | Missing |
| EDITOR set | 1 | nano or other | Set | Missing |
| HISTSIZE | 1 | Reasonably increased | Set | Missing |

---

## Section 5: Oral Verification (10%) — MANDATORY

> **This section is critical for academic integrity.**

### 5.1 Verification Protocol

Each student must answer **2 questions** selected by the instructor from the pool generated by the autograder or from this list:

| # | Question Type | Example |
|---|---------------|---------|
| V1 | Explain specific line | "What does line 15 of your script do?" |
| V2 | Predict modification | "What happens if I change VAR to empty string?" |
| V3 | Justify design choice | "Why did you use this approach instead of X?" |
| V4 | Live modification | "Add date display to your script now." |
| V5 | Debug scenario | "The script fails with error X. How would you fix it?" |

### 5.2 Scoring

| Performance | Points | Description |
|-------------|--------|-------------|
| **Both correct** | 10% | Confident, immediate, accurate responses |
| **One correct** | 5% | One strong answer, one weak/incorrect |
| **Both incorrect** | 0% | Cannot explain own code |
| **Refusal/Absence** | 0% + FLAG | Mark for plagiarism investigation |

### 5.3 Red Flags for Plagiarism

During oral verification, note these indicators:

- [ ] Cannot explain basic variables in own script
- [ ] Does not know what shebang does
- [ ] Cannot modify script when asked
- [ ] Terminology inconsistent with code comments
- [ ] Response time too long for simple questions

**If 2+ red flags**: escalate to plagiarism investigation.

---

## Cross-cutting Criteria

### Code Quality (adjustment: -5% to +5% of final grade)

| Aspect | Bonus | Penalty |
|--------|-------|---------|
| Useful comments | +1% | -1% (completely missing) |
| Organised structure | +1% | -1% (chaotic) |
| Header with author/date | +1% | -1% (missing) |
| Pleasant formatting | +1% | 0 |
| Executable script | 0 | -2% (requires `bash script.sh`) |

### README Documentation (adjustment: -3% to +3% of final grade)

| Aspect | Bonus | Penalty |
|--------|-------|---------|
| Complete README | +2% | -2% (missing) |
| Running instructions | +1% | -1% |

---

## Special Penalties

| Situation | Penalty |
|-----------|---------|
| Plagiarism detected | **-100%** (0 points) |
| Late submission (< 24h) | -10% |
| Late submission (24-72h) | -25% |
| Missing files | -5% per file |
| Does not work on Linux | -20% |
| **No oral verification** | **Maximum grade: 5 (50%)** |

---

## Quick Evaluation Checklist

```
[ ] Archive correctly named (SurnameName_Seminar1.zip)
[ ] AUTHOR.txt present with complete information
[ ] variables.sh - runs without errors
[ ] system_info.sh - displays correct information
[ ] test_globbing.sh - demonstrates patterns
[ ] .bashrc - aliases and mkcd functional
[ ] README.md - documentation present
[ ] Code commented and with header
[ ] ORAL VERIFICATION COMPLETED
[ ] Plagiarism check passed
```

---

## Autograder Integration

The autograder (`S01_01_autograder.py`) produces:
1. Automatic score (max 90%)
2. Generated oral questions based on student code
3. JSON report for records

**Final grade** = Autograder score (90%) + Oral verification (10%) ± Adjustments

---

*Internal document for evaluators | Seminar 1: Shell Basics*
*Version 2.0 | January 2025*
