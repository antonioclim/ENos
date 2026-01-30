# 📁 Test Bank — Final Examination Questions

> **Location:** `SEM07/final_test/test_bank/`  
> **Purpose:** Question pool for generating final examination papers  
> **Audience:** Instructors only (CONFIDENTIAL)

## Contents

| File | Purpose |
|------|---------|
| `questions_pool.yaml` | Complete question bank with metadata |

---

## YAML Structure

```yaml
metadata:
  title: "Operating Systems Final Examination"
  version: "2.0"
  total_questions: 150+
  coverage:
    - seminars: 1-6
    - lectures: 1-14
  bloom_distribution:
    remember: 25%
    understand: 35%
    apply: 25%
    analyse: 15%

questions:
  - id: "sem01_q01"
    topic: "Shell Basics"
    seminar: 1
    bloom: remember
    difficulty: easy
    points: 2
    text: "Question text..."
    type: multiple_choice
    options:
      - "Option A"
      - "Option B"
      - "Option C"
      - "Option D"
    correct: 1
    explanation: "Why B is correct"
    
  - id: "lec05_q03"
    topic: "Threads"
    lecture: 5
    bloom: apply
    difficulty: medium
    points: 5
    text: "Given the following code..."
    type: code_analysis
    code: |
      pthread_create(&t1, NULL, func, NULL);
      pthread_create(&t2, NULL, func, NULL);
      ...
    answer_key: "Expected analysis points..."
```

---

## Question Types

| Type | Format | Auto-gradable |
|------|--------|---------------|
| `multiple_choice` | 4 options, 1 correct | Yes |
| `multiple_select` | 4+ options, 1+ correct | Yes |
| `true_false` | Boolean | Yes |
| `short_answer` | Text (< 50 words) | Partial |
| `code_analysis` | Code + questions | No |
| `code_writing` | Write code | No |
| `diagram` | Draw/label | No |

---

## Generating Exams

Use quiz generator with test bank:

```bash
# Generate randomized exam
python3 ../../../SEM01/scripts/python/S01_02_quiz_generator.py \
    --input questions_pool.yaml \
    --output exam_v1.yaml \
    --questions 40 \
    --points 100 \
    --seed 12345
```

### Exam Variants

```bash
# Generate 5 unique variants
for i in {1..5}; do
    python3 quiz_generator.py \
        --input questions_pool.yaml \
        --output "exam_variant_$i.yaml" \
        --seed $((12345 + i))
done
```

---

## Coverage Matrix

Ensure balanced topic coverage:

```
Topic                    | Questions | Points
─────────────────────────┼───────────┼────────
SEM01: Shell Basics      | 15        | 12%
SEM02: I/O & Pipes       | 15        | 12%
SEM03: Find & Perms      | 15        | 12%
SEM04: Text Processing   | 20        | 16%
SEM05: Functions/Arrays  | 15        | 12%
SEM06: Capstone          | 10        | 10%
Lectures (Theory)        | 60        | 26%
─────────────────────────┼───────────┼────────
TOTAL                    | 150+      | 100%
```

---

## Security Notice

⚠️ **CONFIDENTIAL MATERIAL**

- Do not share with students
- Store securely
- Generate new variants each semester
- Track which questions have been used

---

*See also: [`../../grade_aggregation/`](../../grade_aggregation/) for scoring*

*Last updated: January 2026*
