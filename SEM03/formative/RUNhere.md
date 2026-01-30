# 📁 Formative Assessment — SEM03

> **Location:** `SEM03/formative/`  
> **Purpose:** Self-assessment quiz system for seminar concepts

## Contents

| File | Purpose |
|------|---------|
| `quiz.yaml` | Question bank (12+ questions, Bloom-distributed) |
| `quiz_runner.py` | Interactive CLI quiz runner |
| `quiz_lms.json` | LMS-compatible export (Moodle/Canvas) |

## Quick Start

```bash
# Run interactive quiz
python3 quiz_runner.py

# Run with specific number of questions
python3 quiz_runner.py --questions 10

# Shuffle question order
python3 quiz_runner.py --shuffle

# Show answers immediately after each question
python3 quiz_runner.py --show-answers
```

## quiz_runner.py Options

```bash
python3 quiz_runner.py [options]

Options:
  --questions N     Number of questions to ask (default: all)
  --shuffle         Randomize question order
  --show-answers    Show correct answer after each question
  --timed SEC       Time limit per question in seconds
  --file PATH       Use alternative quiz file
  --validate        Validate quiz.yaml structure without running
  --export FORMAT   Export to format: json, csv, moodle
```

## Quiz Format (quiz.yaml)

```yaml
metadata:
  seminar: 3
  subject: "Find, Xargs, Permissions"
  version: "2.0"
  creation_date: "2026-01-XX"
  number_of_questions: 12
  estimated_time_minutes: 15
  bloom_distribution:
    remember: 3      # Knowledge recall
    understand: 5    # Comprehension  
    apply: 2         # Practical usage
    analyse: 2       # Problem solving

questions:
  - id: q01
    bloom: remember
    difficulty: easy
    text: "Question text here?"
    options:
      - "Option A"
      - "Option B"  
      - "Option C"
      - "Option D"
    correct: 1       # 0-indexed (Option B is correct)
    explanation: "Explanation of why B is correct"
```

## Adding Questions

1. Edit `quiz.yaml`
2. Follow Bloom taxonomy distribution guidelines
3. Validate: `python3 quiz_runner.py --validate`
4. Test: `python3 quiz_runner.py --questions 5`

## LMS Integration

### Export for Moodle

```bash
python3 quiz_runner.py --export moodle > quiz_moodle.xml
```

### Export for Canvas

Use the pre-generated `quiz_lms.json` or:
```bash
python3 quiz_runner.py --export canvas > quiz_canvas.qti
```

## Bloom's Taxonomy Reference

| Level | Cognitive Process | Question Types |
|-------|-------------------|----------------|
| Remember | Recall facts | Definitions, lists, terminology |
| Understand | Explain meaning | Comparisons, descriptions |
| Apply | Use knowledge | Code completion, command usage |
| Analyse | Break down | Debugging, output prediction |

---

*See also: [`../docs/`](../docs/) for study materials*  
*See also: [`../tests/`](../tests/) for automated testing*

*Last updated: January 2026*
