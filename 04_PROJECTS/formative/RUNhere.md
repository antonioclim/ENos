# 📁 Project Readiness Quiz

> **Location:** `04_PROJECTS/formative/`  
> **Purpose:** Self-assessment quiz to verify readiness before starting semester project

## Contents

| File | Purpose |
|------|---------|
| `project_readiness_quiz.yaml` | Question bank covering prerequisites for projects |

## Purpose

This quiz helps you assess whether you have the necessary knowledge to successfully complete a semester project. Complete it **before** selecting and starting your project.

## How to Run

### Option 1: Using SEM Quiz Runner

```bash
# From any SEM folder with quiz_runner.py
cd ../SEM01/formative/
python3 quiz_runner.py --file ../../04_PROJECTS/formative/project_readiness_quiz.yaml
```

### Option 2: Manual Review

Open `project_readiness_quiz.yaml` in any text editor and self-assess each question.

## Quiz Topics

The readiness quiz covers these prerequisite areas:

| Topic | Seminars | Questions |
|-------|----------|-----------|
| Shell scripting basics | SEM01 | 2-3 |
| I/O redirection & pipes | SEM02 | 2-3 |
| File operations & permissions | SEM03 | 2-3 |
| Text processing (grep/sed/awk) | SEM04 | 2-3 |
| Functions & arrays | SEM05 | 2-3 |
| Project organisation | SEM06 | 2-3 |

## Scoring Interpretation

| Score | Interpretation | Recommendation |
|-------|----------------|----------------|
| 90-100% | Fully prepared | Start any project level |
| 75-89% | Well prepared | Start Easy or Medium projects |
| 60-74% | Basic preparation | Review weak areas, start Easy projects |
| < 60% | Needs review | Complete seminar exercises first |

## YAML Structure

```yaml
metadata:
  title: "Project Readiness Assessment"
  version: "1.0"
  estimated_time_minutes: 20
  passing_score: 75

questions:
  - id: pr01
    topic: "shell_basics"
    text: "Question about shell fundamentals..."
    options: ["A", "B", "C", "D"]
    correct: 1
    explanation: "Explanation of correct answer"
    seminar_reference: "SEM01"
```

---

*Take this quiz seriously — it predicts project success!*  
*See also: [`../PROJECT_SELECTION_GUIDE.md`](../PROJECT_SELECTION_GUIDE.md)*

*Last updated: January 2026*
