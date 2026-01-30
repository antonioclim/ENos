# 📁 Homework — Assignment Materials

> **Location:** `SEM02/homework/`  
> **Purpose:** Homework specification, submission scripts, and evaluation criteria

## Contents

| File | Purpose |
|------|---------|
| `S02_01_HOMEWORK.md` | Assignment specification |
| `S02_02_create_homework.sh` | Homework generator script |
| `S02_03_EVALUATION_RUBRIC.md` | Grading criteria |
| `S02_04_ORAL_VERIFICATION_LOG.md` | Interview checklist |
| `solutions/` | Reference solutions (instructors) |
| `OLD_HW/` | Archived previous assignments |

---

## S02_02_create_homework.sh

**Purpose:** Generates personalized homework assignments for students.

### Usage

```bash
./S02_02_create_homework.sh [options]

Options:
  --student-id ID    Generate for specific student
  --batch FILE       Generate from student list CSV
  --seed N           Random seed for reproducibility
  --output DIR       Output directory
  --template FILE    Custom assignment template
```

### Examples

```bash
# Generate for single student
./S02_02_create_homework.sh --student-id ABC123

# Batch generation
./S02_02_create_homework.sh --batch students.csv --output assignments/

# Reproducible generation
./S02_02_create_homework.sh --batch students.csv --seed 42
```

### How Personalisation Works

The script generates unique:
- File names and paths
- Data values (numbers, strings)
- Expected outputs

This prevents direct copying between students.

---

## Submission Guidelines

1. Complete all exercises in `S02_01_HOMEWORK.md`
2. Validate: Use `../../03_GUIDES/check_my_submission.sh`
3. Record: Use `../../02_INIT_HOMEWORKS/record_homework_EN.sh`
4. Submit via designated platform

---

## Grading

See `S02_03_EVALUATION_RUBRIC.md` for:
- Points breakdown per exercise
- Style requirements
- Documentation expectations
- Partial credit criteria

---

*See also: [`../docs/`](../docs/) for study materials*  
*See also: [`../../03_GUIDES/`](../../03_GUIDES/) for submission guide*

*Last updated: January 2026*
