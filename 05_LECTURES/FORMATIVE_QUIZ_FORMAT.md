# 📋 Formative Assessment Format — Lecture Quiz System

> **Location:** `05_LECTURES/FORMATIVE_QUIZ_FORMAT.md`  
> **Purpose:** Documents the YAML quiz format used in all lecture `/docs/` folders

---

## Overview

Each lecture directory contains a formative assessment file:
```
05_LECTURES/XX-Topic/docs/CXX_05_FORMATIVE_ASSESSMENT.yaml
```

These quizzes provide self-assessment aligned with lecture learning objectives, distributed according to **Bloom's Taxonomy**.

---

## File Locations

| Lecture | Quiz File |
|---------|-----------|
| 01 - Introduction to OS | `01-.../docs/C01_05_FORMATIVE_ASSESSMENT.yaml` |
| 02 - Basic OS Concepts | `02-.../docs/C02_05_FORMATIVE_ASSESSMENT.yaml` |
| 03 - Processes (PCB+fork) | `03-.../docs/C03_05_FORMATIVE_ASSESSMENT.yaml` |
| 04 - Process Scheduling | `04-.../docs/C04_05_FORMATIVE_ASSESSMENT.yaml` |
| 05 - Execution Threads | `05-.../docs/C05_05_FORMATIVE_ASSESSMENT.yaml` |
| 06 - Synchronisation Part 1 | `06-.../docs/C06_05_FORMATIVE_ASSESSMENT.yaml` |
| 07 - Synchronisation Part 2 | `07-.../docs/C07_05_FORMATIVE_ASSESSMENT.yaml` |
| 08 - Deadlock (Coffman) | `08-.../docs/C08_05_FORMATIVE_ASSESSMENT.yaml` |
| 09 - Memory Management Part 1 | `09-.../docs/C09_05_FORMATIVE_ASSESSMENT.yaml` |
| 10 - Virtual Memory (TLB) | `10-.../docs/C10_05_FORMATIVE_ASSESSMENT.yaml` |
| 11 - File System Part 1 | `11-.../docs/C11_05_FORMATIVE_ASSESSMENT.yaml` |
| 12 - File System Part 2 | `12-.../docs/C12_05_FORMATIVE_ASSESSMENT.yaml` |
| 13 - Security in OS | `13-.../docs/C13_05_FORMATIVE_ASSESSMENT.yaml` |
| 14 - Virtualisation + Recap | `14-.../docs/C14_05_FORMATIVE_ASSESSMENT.yaml` |
| 15supp - Network Connection | `15supp-.../docs/C15_05_FORMATIVE_ASSESSMENT.yaml` |
| 16supp - Advanced Containers | `16supp-.../docs/C16_05_FORMATIVE_ASSESSMENT.yaml` |
| 17supp - Kernel Programming | `17supp-.../docs/C17_05_FORMATIVE_ASSESSMENT.yaml` |
| 18supp - NPU Integration | `18supp-.../docs/C18_05_FORMATIVE_ASSESSMENT.yaml` |

---

## YAML Structure

### Complete Example

```yaml
# CXX_05_FORMATIVE_ASSESSMENT.yaml
# Course X: Topic Name
# Formative Assessment — Conceptual Quiz

metadata:
  course: 5                           # Lecture number
  subject: "Execution Threads"        # Lecture title
  version: "2.0"                      # Quiz version
  creation_date: "2026-01-28"         # ISO date
  author: "by Revolvix"               # Creator
  number_of_questions: 12             # Total questions
  estimated_time_minutes: 15          # Suggested time
  bloom_distribution:                 # Taxonomy breakdown
    remember: 3                       # Knowledge recall
    understand: 5                     # Comprehension
    analyse: 3                        # Breaking down
    apply: 1                          # Using in new situations

questions:
  # ═══════════════════════════════════════════════════════════════
  # REMEMBER (knowledge retrieval)
  # ═══════════════════════════════════════════════════════════════
  
  - id: q01                           # Unique identifier
    bloom: remember                   # Taxonomy level
    difficulty: easy                  # easy | medium | hard
    text: "What is a thread?"         # Question text
    options:                          # Answer choices
      - "An independent process"
      - "The smallest unit of execution"
      - "A type of memory"
      - "An executable file"
    correct: 1                        # 0-indexed correct answer (B)
    explanation: "Thread = lightweight process, shares address space"
  
  # ═══════════════════════════════════════════════════════════════
  # UNDERSTAND (comprehension)
  # ═══════════════════════════════════════════════════════════════
  
  - id: q02
    bloom: understand
    difficulty: medium
    text: "Why are threads more efficient than processes for..."
    options:
      - "Option A"
      - "Option B"
      - "Option C"
      - "Option D"
    correct: 2
    explanation: "Detailed explanation of why C is correct"
    
  # Additional questions follow same pattern...
```

### Field Reference

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `metadata.course` | int | Yes | Lecture number (1-18) |
| `metadata.subject` | string | Yes | Lecture title |
| `metadata.version` | string | Yes | Bank version identifier |
| `metadata.number_of_questions` | int | Yes | Total question count |
| `metadata.estimated_time_minutes` | int | Yes | Suggested completion time |
| `metadata.bloom_distribution` | object | Yes | Question counts per level |
| `questions[].id` | string | Yes | Unique ID (q01, q02, etc.) |
| `questions[].bloom` | string | Yes | remember/understand/apply/analyse |
| `questions[].difficulty` | string | Yes | easy/medium/hard |
| `questions[].text` | string | Yes | Question text |
| `questions[].options` | array | Yes | 4 answer choices |
| `questions[].correct` | int | Yes | 0-indexed correct answer |
| `questions[].explanation` | string | Yes | Why answer is correct |

---

## How to Use

### Option 1: dedicated lecture runner

From the repository root (Python with PyYAML):

```bash
python3 05_LECTURES/quiz_runner.py "05_LECTURES/05-Execution_Threads/docs/C05_05_FORMATIVE_ASSESSMENT.yaml" --validate
python3 05_LECTURES/quiz_runner.py "05_LECTURES/05-Execution_Threads/docs/C05_05_FORMATIVE_ASSESSMENT.yaml" --limit 10 --shuffle --seed 42
```

`--shuffle` permutes both the questions and each question’s options, remapping the zero-based correct index together. The same bank and seed reproduce the order. The source bank remains unchanged. This prevents the source banks' concentrated B positions from acting as a session answer cue. Scores are formative feedback and do not establish a course grading policy.

### Option 2: manual review

Open the YAML file, answer each question, then inspect its zero-based `correct` index and explanation. The physical C04/L04 and C08 named variants remain compatible copies with the same canonical key schema.

### Option 3: local Moodle XML export

```bash
python3 05_LECTURES/quiz_runner.py "05_LECTURES/05-Execution_Threads/docs/C05_05_FORMATIVE_ASSESSMENT.yaml" --shuffle --seed 42 --export-moodle quiz_lms.xml
```

The command creates a UTF-8 Moodle XML bank of single-answer multiple-choice questions. It does not upload to an LMS. Local XML syntax and answer/text mapping can be verified independently; importing into a particular Moodle course and its assessment settings remains a separate author-authorised acceptance step. The exporter follows the [Moodle XML format](https://docs.moodle.org/en/Moodle_XML_format). A Moodle XML file is not a Canvas JSON import.

---

## Bloom's Taxonomy Distribution

The following proportions are a teaching-design target, not a claim that every existing bank has exactly this distribution:

| Level | Cognitive Process | Typical Verbs | Target % |
|-------|-------------------|---------------|----------|
| **Remember** | Recall facts | define, list, state, identify | 15-25% |
| **Understand** | Explain concepts | explain, describe, compare, contrast | 35-45% |
| **Apply** | Use in new context | demonstrate, implement, calculate | 10-20% |
| **Analyse** | Break down, examine | differentiate, examine, test, compare | 20-30% |

### Example Distribution (12 questions)

```
Remember:    ███░░░░░░░░░  3 questions (25%)
Understand:  █████░░░░░░░  5 questions (42%)
Apply:       █░░░░░░░░░░░  1 question  (8%)
Analyse:     ███░░░░░░░░░  3 questions (25%)
```

---

## Related Documentation

Each `docs/` folder also contains:

| File | Purpose |
|------|---------|
| `CXX_01_COURSE_PLAN.md` | Learning objectives and timing |
| `CXX_02_CONCEPT_MAP.md` | Visual topic relationships |
| `CXX_03_DISCUSSION_QUESTIONS.md` | Peer instruction questions |
| `CXX_04_STUDY_GUIDE.md` | Self-study materials |
| `##ex#_-_*.html` | Interactive HTML simulators |

---

## Validation

To validate YAML syntax:

```bash
python3 -c "
import yaml
with open('C05_05_FORMATIVE_ASSESSMENT.yaml') as f:
    data = yaml.safe_load(f)
    assert 'metadata' in data
    assert 'questions' in data
    print(f'Valid: {len(data[\"questions\"])} questions')
"
```

---

## Contributing

When adding or modifying questions:

1. Maintain Bloom distribution balance
2. Include clear explanations
3. Ensure 4 options per question
4. Use 0-indexed `correct` field
5. Validate with `05_LECTURES/quiz_runner.py <bank> --validate`; test shuffled option/key agreement

---

*See also: Individual lecture README.md files for topic context*  
*See also: `SEM*/formative/` for seminar-specific quizzes*

*Last updated: January 2026*
