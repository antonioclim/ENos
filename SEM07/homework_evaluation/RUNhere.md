# 📁 Homework Evaluation — Grading Pipeline

> **Location:** `SEM07/homework_evaluation/`  
> **Purpose:** Automated and manual homework grading infrastructure  
> **Audience:** Instructors and teaching assistants

## Contents

| File | Purpose |
|------|---------|
| `verify_homework_EN.sh` | Structural validation before grading |
| `grade_homework_EN.py` | Automated grading with feedback |
| `homework_rubrics/` | Per-seminar grading rubrics |

---

## Workflow Overview

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│ Student submits │ ──► │ verify_homework │ ──► │ grade_homework  │
│                 │     │  (structure)    │     │  (auto + manual)│
└─────────────────┘     └─────────────────┘     └─────────────────┘
                                                        │
                        ┌───────────────────────────────┘
                        ▼
                ┌─────────────────┐
                │ Manual review   │
                │ (partial credit)│
                └─────────────────┘
```

---

## verify_homework_EN.sh

**Purpose:** Quick structural validation before detailed grading.

### Usage

```bash
./verify_homework_EN.sh <submission_dir> [options]

Options:
  --seminar N       Validate against seminar N requirements
  --strict          Fail on any warning
  --report FILE     Generate verification report
  --batch DIR       Verify entire submissions directory
```

### What It Checks

| Check | Description |
|-------|-------------|
| File presence | Required files exist |
| File naming | Follows naming convention |
| Script syntax | `bash -n` passes |
| Permissions | Scripts are executable |
| No forbidden files | No `.env`, credentials |
| Line endings | LF not CRLF |

### Examples

```bash
# Single submission
./verify_homework_EN.sh submissions/student123/ --seminar 4

# Batch verification
./verify_homework_EN.sh --batch submissions/ --seminar 4 --report verify_report.txt
```

---

## grade_homework_EN.py

**Purpose:** Automated grading with customizable rubrics.

### Usage

```bash
python3 grade_homework_EN.py <submission> [options]

Arguments:
  submission        Single submission or directory of submissions

Options:
  --seminar N       Use rubric for seminar N
  --rubric FILE     Custom rubric file
  --output FILE     Output grades file (CSV)
  --feedback        Generate per-student feedback files
  --batch           Process directory of submissions
  --timeout SEC     Per-test timeout (default: 30)
  --verbose         Detailed grading output
```

### Examples

```bash
# Grade single submission
python3 grade_homework_EN.py submissions/student123/ --seminar 4

# Batch grading with feedback
python3 grade_homework_EN.py submissions/ --batch --feedback --output grades.csv

# Custom rubric
python3 grade_homework_EN.py submissions/ --rubric custom_rubric.yaml
```

### Grading Components

| Component | Weight | Auto-gradable |
|-----------|--------|---------------|
| Correctness | 60% | Yes (test cases) |
| Code quality | 20% | Partial (shellcheck) |
| Documentation | 20% | Partial (presence checks) |

---

## Rubric Format

Each seminar has a rubric in `homework_rubrics/`:

```yaml
# S04_HOMEWORK_RUBRIC.md structure
seminar: 4
title: "Text Processing with grep/sed/awk"
max_points: 100

criteria:
  - name: "Exercise 1: grep patterns"
    points: 25
    tests:
      - description: "Basic pattern matching"
        points: 10
        command: "./test_grep_basic.sh"
      - description: "Extended regex"
        points: 15
        command: "./test_grep_extended.sh"
        
  - name: "Code quality"
    points: 20
    manual: true
    guidelines:
      - "Proper quoting"
      - "Error handling"
      - "Readable formatting"
```

---

## Feedback Generation

When using `--feedback`, generates per-student files:

```
feedback/
├── student123_feedback.md
├── student456_feedback.md
└── ...
```

### Feedback Format

```markdown
# Homework Feedback — Seminar 4
**Student:** student123
**Total Score:** 78/100

## Exercise 1: grep patterns (22/25)
✅ Basic pattern matching: 10/10
⚠️ Extended regex: 12/15
   - Missing case-insensitive flag

## Code Quality (16/20)
- Good error handling
- Improve variable quoting

## Documentation (10/15)
- README present but incomplete
- Add usage examples

---
*Graded: 2026-01-30*
```

---

## Manual Review

After automated grading, review:

1. Partial credit cases
2. Alternative correct solutions
3. Code quality nuances
4. Documentation depth

```bash
# Flag submissions for manual review
python3 grade_homework_EN.py submissions/ --batch --flag-review
```

---

*See also: [`homework_rubrics/`](homework_rubrics/) for grading criteria*  
*See also: [`../grade_aggregation/`](../grade_aggregation/) for final grades*

*Last updated: January 2026*
