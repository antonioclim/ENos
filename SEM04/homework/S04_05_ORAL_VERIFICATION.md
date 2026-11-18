# Oral Verification Questions — Seminar 04

> **Assessment contract pending.** Consult [the assessment status and author decision](ASSESSMENT_STATUS.md) before treating any weights, penalties or eligibility rules below as adopted. The tools provide diagnostics, not a final grade.

> **Audience:** Instructor facilitation. This file is committed publicly; the label provides no confidentiality. A private release strategy remains an author decision.  
> **Purpose:** Gather evidence of understanding. An oral response alone does not authenticate authorship or prove copying.  
> **Duration:** 3–5 minutes per student  
> **When:** During lab sessions or office hours after submission

---

## Procedure

1. Student opens their submission on their own laptop
2. Instructor selects 2–3 questions using a documented local selection method, then records which were used
3. Student must answer WITHOUT looking at external resources
4. Partial credit for hints; zero if they clearly do not understand their own code

> *From experience: students who copy can usually explain WHAT the code does,
> but struggle with WHY they chose a specific approach. Focus on the 'why'.*

---

## Retained Scoring Proposal — Not Applied

The multipliers and escalation labels below require the author/institutional
policy. Record observations separately from any final score or misconduct finding.
The retained experience note is anecdotal, not a validated authorship classifier.

| Response Quality | Score Adjustment |
|------------------|------------------|
| Immediate, confident and correct | 100% of homework grade |
| Correct after brief thinking | 100% |
| Correct after one hint | 80% |
| Partially correct | 50% |
| Clearly does not understand | → plagiarism investigation |

---

## Question Bank

### Category A: Basic Understanding (ask at least 1)

#### A1. grep options
- "What does `-o` do in your grep command?"
- Expected: "Only outputs the matching part, not the whole line"
- Follow-up: "Why did you need that here?"

#### A2. sort before uniq
- "Why is `sort` before `uniq` in your pipeline?"
- Expected: "uniq only removes adjacent duplicates, so data must be sorted first"
- If incomplete: ask for a small counterexample and record the specific concept needing follow-up

#### A3. Field separator
- "What does `-F','` do in your awk?"
- Expected: "Sets the separator for the simple unquoted CSV fixture; quoted CSV needs a parser"
- Follow-up: "What would `$3` be without it?"

#### A4. Global flag
- "What happens if you remove `/g` from your sed substitution?"
- Expected: "Only the first occurrence on each line gets replaced"

#### A5. NR in awk
- "What is `NR` and why did you use `NR > 1`?"
- Expected: "NR is the record/line number; NR > 1 skips the header row"

---

### Category B: Implementation Choices (ask at least 1)

#### B1. UUOC awareness
- "I see `cat file | grep`. Could you rewrite this?"
- Expected: `grep pattern file` (direct file argument)
- Tests: awareness of useless use of cat

#### B2. Regex design
- "Your email regex is `[pattern]`. What formats does it accept?"
- Follow-up: "What about `user+tag@domain.co.uk`? Does your regex match?"

#### B3. Alternative approach
- "You used grep+sort+uniq. Could you do this in a single awk?"
- Expected: Student explains associative array approach
- Not expected: Perfect awk syntax from memory

#### B4. Error handling
- "What happens if I run your script without arguments?"
- Good: "It shows usage and exits with error"
- Bad: "I... do not know" or "It crashes"

#### B5. Output formatting
- "Why did you use `printf` instead of `print` here?"
- Expected: "To control formatting, decimal places and column widths"

---

### Category C: Edge Cases (historical grade >8 gate; pending policy)

#### C1. Empty input
- "What does your script output for an empty file?"
- Tests: whether they tested edge cases

#### C2. Special characters
- "What if a CSV field contains a comma inside quotes?"
- Advanced: Most student solutions will not handle this — that is OK
- Good: Student acknowledges the limitation

#### C3. Large files
- "If I gave you a 10GB log file, what would you change?"
- Expected ideas: 
  - Stream processing instead of loading all
  - awk single-pass instead of multiple pipes
  - Avoid `sort` on huge data

#### C4. Portability
- "Would this work on macOS? On a minimal Docker container?"
- Tests: awareness of GNU vs BSD differences
- Hint if stuck: "What about `sed -i`?"

---

### Category D: Live Modification

These require the student to modify code on the spot:

#### D1. Add a feature
- "Add a percentage column to your output"
- Observe the explanation, changed behaviour and test evidence; typing speed is not an authorship measure

#### D2. Fix a bug
*Work on a disposable copy, retaining the original submission unchanged:*
- "I changed one character and now it does not work. Find and fix it."
- Examples: 
  - `$3` → `$2`
  - `sort -rn` → `sort -n`
  - `/g` → (removed)

#### D3. Explain then modify
- "Explain this line, then change it to also handle lowercase"
- Forces genuine understanding, not just pattern matching

---

## Prompts for Technical Follow-up, Not Misconduct Findings

The following historical observations are not proof of copying or AI use. Anxiety,
language, disability, time pressure and prior preparation can affect performance.
No automatic penalty or investigation is triggered by these cues alone.

- Cannot navigate their own code quickly
- Uses variable names they cannot explain ("what is `x` here?")
- Perfect code but struggles with basic questions
- Identical code structure to another student (even with different data)
- Explains what but never why
- Overly defensive when questioned

---

## Sample Dialogue

**Instructor:** "Walk me through your Exercise 2. What does this awk command do?"

**Student (good):** "So first I set the field separator to comma because it is CSV.
Then for each line after the header — that is the NR > 1 part — I add the salary 
which is column 4 to a running total. At the END I print the average."

**Student (needs further explanation):** "It... calculates the salary. The awk thing processes 
the file and then prints the result."

**Instructor:** "Why column 4 specifically?"

**Student (good):** "Because in the CSV, the columns are ID, Name, Department and Salary,
so Salary is the 4th field."

**Student (needs further explanation):** "That is... where the number is?"

---

## Equivalent Technical Answers

A correct AWK aggregation may replace grep/sort/uniq when the objective is the
result. If a question specifically assesses one named tool or construct, state
that restriction before the task and assess that objective separately. A longer
pipeline is not automatically slower, and equivalent commands must not lose
credit solely for differing from the reference spelling. Timing claims need a
repeatable benchmark with the same input, environment and output contract.

## Documentation

After verification, note in your grading spreadsheet:

```
MATRICOL | Q1 | Q2 | Q3 | VERDICT | NOTES
123456   | A2 | B3 | -  | PASS    | solid understanding
234567   | A1 | B1 | D1 | PASS-   | needed hints for B1
345678   | A3 | B2 | -  | REVIEW  | regex explanation incomplete; no authorship verdict
```

---

*Keep this document updated with new questions based on common issues you observe.*
*Last updated: January 2025 by ing. dr. Antonio Clim*
