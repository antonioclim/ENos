# 📁 Python Tools — SEM04

> **Location:** `SEM04/scripts/python/`  
> **Purpose:** Automated grading, generation, and analysis tools  
> **Python version:** ≥ 3.10 required

## Contents

| Tool | Purpose | CLI |
|------|---------|-----|
| `S04_01_autograder.py` | Automated homework evaluation | Yes |
| `S04_02_quiz_generator.py` | Generate randomized quizzes | Yes |
| `S04_03_report_generator.py` | Create reports | Yes |
| `S04_04_personalized_data_generator.py` | Generate unique datasets | Yes |
| `S04_05_similarity_checker.py` | Check submission similarity | Yes |

## Installation

```bash
# Install dependencies
cd SEM04/
pip install -r requirements.txt

# Or install individually
pip install pyyaml pytest
```

---

## S04_01_autograder.py

**Purpose:** Automated homework evaluation with detailed feedback

### Usage

```bash
python3 S04_01_autograder.py <submission> [options]

Arguments:
  submission       Path to submission directory or file

Options:
  --rubric PATH    Custom rubric file
  --output FILE    Output file for grades (CSV)
  --verbose        Detailed scoring breakdown
  --batch          Process entire directory of submissions
  --timeout SEC    Per-test timeout (default: 30)
```

### Examples

```bash
# Grade single submission
python3 S04_01_autograder.py ~/submissions/student123/

# Grade all submissions with report
python3 S04_01_autograder.py ~/submissions/ --batch --output grades.csv

# Verbose grading
python3 S04_01_autograder.py submission/ --verbose
```

### Grading Criteria

| Criterion | Weight | Description |
|-----------|--------|-------------|
| Correctness | 60% | Passes test cases |
| Style | 20% | shellcheck compliance |
| Documentation | 20% | Comments, README |

---

## S04_02_quiz_generator.py

**Purpose:** Generate randomized quizzes from question bank

### Usage

```bash
python3 S04_02_quiz_generator.py [options]

Options:
  --count N        Number of unique quizzes to generate
  --questions N    Questions per quiz (default: 10)
  --seed N         Random seed for reproducibility
  --output DIR     Output directory for generated quizzes
  --format FMT     Output format: yaml, json, pdf, moodle
```

### Examples

```bash
# Generate 5 unique quizzes
python3 S04_02_quiz_generator.py --count 5 --output quizzes/

# Reproducible generation
python3 S04_02_quiz_generator.py --seed 42 --count 3

# Export for Moodle
python3 S04_02_quiz_generator.py --format moodle --output moodle_quiz.xml
```

---

## S04_03_report_generator.py

**Purpose:** Generate PDF/HTML reports from grading data

### Usage

```bash
python3 S04_03_report_generator.py <grades_file> [options]

Arguments:
  grades_file      CSV file with grades data

Options:
  --format FMT     Output format: pdf, html, md (default: pdf)
  --individual     Generate per-student reports
  --summary        Include class statistics
  --output DIR     Output directory
```

### Examples

```bash
# Generate summary report
python3 S04_03_report_generator.py grades.csv --summary

# Individual student reports
python3 S04_03_report_generator.py grades.csv --individual --output reports/
```


## S04_04_personalized_data_generator.py

**Purpose:** Generate unique datasets

```bash
python3 S04_04_personalized_data_generator.py --help
```

## S04_05_similarity_checker.py

**Purpose:** Check submission similarity

```bash
python3 S04_05_similarity_checker.py --help
```


---

## Common Options

All Python tools support:

| Option | Description |
|--------|-------------|
| `--help` | Show detailed help |
| `--version` | Show tool version |
| `--quiet` | Suppress non-essential output |
| `--debug` | Enable debug logging |

## PYTHONPATH Setup

For importing shared `lib/` modules:

```bash
# Add to your .bashrc or run before scripts
export PYTHONPATH="${PYTHONPATH}:$(pwd)/../.."

# Or run with path
PYTHONPATH="../.." python3 S04_01_autograder.py submission/
```

---

*See also: [`../../lib/`](../../lib/) for shared utilities*  
*See also: [`../../tests/`](../../tests/) for test suite*

*Last updated: January 2026*
