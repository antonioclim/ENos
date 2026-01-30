# SEM07 - Final Evaluation Toolkit

> **Operating Systems** | ASE Bucharest - CSIE  
> Seminar 7: Final Evaluation and Grading

---

## Overview

This toolkit provides comprehensive infrastructure for the final evaluation of the Operating Systems course. It integrates assessment of all three graded components: homeworks, projects and tests.

---

## Grading Formula

```
FINAL_GRADE = (HOMEWORK × 0.25) + (PROJECT × 0.50) + (TESTS × 0.25)
```

| Component | Weight | Source |
|-----------|--------|--------|
| Homeworks | 25% | 31 assignments from SEM01-SEM06 OLD_HW |
| Project | 50% | Semester project with intermediate + final evaluation |
| Tests | 25% | 6 tests (one per seminar SEM01-SEM06) |

---

## Elimination Criteria (80% Threshold)

**All three components have mandatory minimum thresholds. Failure to meet ANY threshold results in course failure, regardless of other scores.**

### Homeworks (31 total)
- **Minimum required:** 25 assignments (80%)
- **Maximum absences:** 6 assignments
- **Requirements:** Completed integrally and submitted on time
- **Verification:** Valid cryptographic signature on `.cast` files

### Tests (6 total)
- **Minimum required:** 5 tests (80%)
- **Maximum absences:** 1 test
- **Timing:** One test at the beginning of each seminar (SEM01-SEM06)

### Project
The project **WILL NOT BE EVALUATED** if any of the following is missing:
- ✗ All SEM06 intermediate evaluation requirements not met
- ✗ Application does not run without errors
- ✗ No public GitHub repository
- ✗ Missing or incomplete README.md
- ✗ No REAL outputs (simulated outputs are not accepted)

---

## Directory Structure

```
SEM07/
├── README.md                          # This file
├── homework_evaluation/               # Homework verification and grading
│   ├── verify_homework_EN.sh          # Signature verification script
│   ├── grade_homework_EN.py           # Automated grading script
│   ├── HOMEWORK_EVALUATION_GUIDE.md   # Evaluation procedures
│   └── homework_rubrics/              # Per-seminar rubrics
│       ├── S01_HOMEWORK_RUBRIC.md
│       ├── S02_HOMEWORK_RUBRIC.md
│       ├── S03_HOMEWORK_RUBRIC.md
│       ├── S04_HOMEWORK_RUBRIC.md
│       ├── S05_HOMEWORK_RUBRIC.md
│       └── S06_HOMEWORK_RUBRIC.md
├── project_evaluation/                # Project assessment tools
│   ├── run_auto_eval_EN.sh            # Automated evaluation orchestrator
│   ├── manual_eval_checklist_EN.md    # Manual evaluation criteria
│   ├── oral_defence_questions_EN.md   # Question bank for defence
│   ├── project_score_calculator_EN.py # Score aggregation
│   └── Docker/
│       └── Dockerfile                 # Sandbox for safe execution
├── final_test/                        # Test generation and grading
│   ├── generate_test_EN.py            # Randomised test generator
│   ├── TEST_TEMPLATE.md               # Test format template
│   ├── answer_key_generator_EN.py     # Answer key generation
│   └── test_bank/
│       └── questions_pool.yaml        # Question database
├── grade_aggregation/                 # Final grade calculation
│   ├── final_grade_calculator_EN.py   # Main grading script
│   ├── GRADING_POLICY.md              # Official grading policy
│   └── templates/
│       ├── homework_grades_template.csv
│       ├── project_grades_template.csv
│       └── test_grades_template.csv
└── docs/
    └── EVALUATION_TIMELINE.md         # Evaluation schedule
```

---

## Quick Start

### 1. Verify Homework Submissions
```bash
cd homework_evaluation/
./verify_homework_EN.sh /path/to/submissions/
```

### 2. Run Project Auto-Evaluation
```bash
cd project_evaluation/
./run_auto_eval_EN.sh /path/to/project/
```

### 3. Generate Final Test
```bash
cd final_test/
python3 generate_test_EN.py --students 30 --seed 2025
```

### 4. Calculate Final Grades
```bash
cd grade_aggregation/
python3 final_grade_calculator_EN.py \
    --homework ../templates/homework_grades.csv \
    --project ../templates/project_grades.csv \
    --tests ../templates/test_grades.csv \
    --output final_grades.csv
```

---

## Workflow Timeline

| Phase | Week | Activity |
|-------|------|----------|
| Pre-SEM07 | Week 13 | Collect all homework `.cast` files |
| Pre-SEM07 | Week 13 | Verify project GitHub repositories |
| SEM07 Day | Week 14 | Administer final test |
| SEM07 Day | Week 14 | Project oral defence |
| Post-SEM07 | Week 14 | Grade aggregation and publication |

---

## Component Details

### Homework Evaluation
- Automated signature verification prevents tampering
- Each assignment graded against specific rubric
- Cumulative score calculated as average of all submitted assignments
- Late submissions: -20% penalty per day (max 3 days)

### Project Evaluation
- **Automatic evaluation (85%):** Functional tests, code quality, documentation
- **Manual evaluation (15%):** UX, code elegance, innovation
- **Oral defence:** Required for grade validation

### Test Evaluation
- Randomised questions from question bank
- Mix of theoretical and practical questions
- Covers all lecture topics (01-14)

---

## Dependencies

```bash
# Python packages
pip install rich questionary pyyaml pandas --break-system-packages

# System tools
apt install shellcheck docker.io
```

---

## Authors and Licence

**Course:** Operating Systems - ASE Bucharest CSIE  
**Authors:** ing. dr. Antonio Clim, conf. dr. Andrei Toma  
**Licence:** Restricted 2017-2030

---

*By Revolvix for OPERATING SYSTEMS class | restricted licence 2017-2030*
