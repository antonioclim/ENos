# 📁 Grade Aggregation — Final Grade Calculator

> **Location:** `SEM07/grade_aggregation/`  
> **Purpose:** Calculate weighted final grades from all components  
> **Audience:** Instructors only

## Contents

| File | Purpose |
|------|---------|
| `final_grade_calculator_EN.py` | Main grade calculation script |
| `GRADING_POLICY.md` | Official grading policy documentation |
| `templates/` | CSV templates for grade input |

---

## final_grade_calculator_EN.py

### Usage

```bash
python3 final_grade_calculator_EN.py [options]

Options:
  --homework FILE      Homework grades CSV
  --project FILE       Project grades CSV  
  --exam FILE          Exam grades CSV
  --output FILE        Output file for final grades
  --weights W1,W2,W3   Custom weights (default: 0.3,0.4,0.3)
  --policy FILE        Custom grading policy
  --format FMT         Output format: csv, xlsx, json
```

### Standard Usage

```bash
# Using default file locations
python3 final_grade_calculator_EN.py

# With explicit files
python3 final_grade_calculator_EN.py \
    --homework homework_grades.csv \
    --project project_grades.csv \
    --exam exam_grades.csv \
    --output final_grades.csv
```

### Custom Weights

```bash
# Homework 20%, Project 50%, Exam 30%
python3 final_grade_calculator_EN.py --weights 0.2,0.5,0.3

# No exam (coursework only)
python3 final_grade_calculator_EN.py --weights 0.4,0.6,0.0 --exam none
```

---

## Input File Formats

### homework_grades.csv

```csv
student_id,hw1,hw2,hw3,hw4,hw5,hw6,total,percentage
ABC123,95,88,92,85,90,88,538,89.7
DEF456,78,82,75,80,85,79,479,79.8
...
```

### project_grades.csv

```csv
student_id,functionality,style,documentation,testing,total,percentage
ABC123,35,18,15,12,80,80.0
DEF456,40,16,18,14,88,88.0
...
```

### exam_grades.csv

```csv
student_id,q1,q2,q3,q4,q5,total,percentage
ABC123,20,18,15,12,10,75,75.0
DEF456,18,20,14,15,13,80,80.0
...
```

---

## Output Format

### final_grades.csv

```csv
student_id,homework,project,exam,weighted_total,letter_grade,passed
ABC123,89.7,80.0,75.0,80.91,B,true
DEF456,79.8,88.0,80.0,82.74,B+,true
GHI789,65.0,55.0,45.0,54.00,F,false
...
```

---

## Grading Scale

Default scale (configurable in `GRADING_POLICY.md`):

| Percentage | Letter | Points |
|------------|--------|--------|
| 90-100 | A | 4.0 |
| 85-89 | B+ | 3.5 |
| 80-84 | B | 3.0 |
| 75-79 | C+ | 2.5 |
| 70-74 | C | 2.0 |
| 65-69 | D+ | 1.5 |
| 60-64 | D | 1.0 |
| < 60 | F | 0.0 |

Passing threshold: 60% (configurable)

---

## Features

### Handling Missing Grades

```bash
# Skip students with incomplete records
python3 final_grade_calculator_EN.py --skip-incomplete

# Treat missing as zero
python3 final_grade_calculator_EN.py --missing-as-zero

# Flag incomplete for manual review
python3 final_grade_calculator_EN.py --flag-incomplete
```

### Bonus Points

```bash
# Add bonus column from separate file
python3 final_grade_calculator_EN.py --bonus bonus_points.csv

# Cap total at 100%
python3 final_grade_calculator_EN.py --bonus bonus.csv --cap 100
```

### Statistics

```bash
# Generate class statistics
python3 final_grade_calculator_EN.py --stats

# Output includes:
# - Mean, median, std dev
# - Grade distribution histogram
# - Pass/fail rates
```

---

## Templates

Use provided templates for consistent formatting:

```bash
ls templates/
# homework_grades_template.csv
# project_grades_template.csv
# test_grades_template.csv
```

---

*See also: [`GRADING_POLICY.md`](GRADING_POLICY.md) for official policy*  
*See also: [`../homework_evaluation/`](../homework_evaluation/) for grading criteria*

*Last updated: January 2026*
