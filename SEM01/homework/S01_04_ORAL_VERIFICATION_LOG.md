# Oral Verification Log — Seminar 1

> **Instructor use only** | Complete during or immediately after verification  
> **Version:** 1.0 | **Form ID:** S01-ORAL-____

---

## Student Information

| Field | Value |
|-------|-------|
| **Student Name** | ________________________________ |
| **Student ID (Matricol)** | ________________________________ |
| **Group** | ________________________________ |
| **Date** | ____/____/20____ |
| **Time** | ____:____ |
| **Evaluator** | ________________________________ |

---

## Submission Details

| Item | Status |
|------|--------|
| Archive received | [ ] Yes [ ] No |
| Autograder score | ____/90 points |
| Scripts execute | [ ] Yes [ ] No [ ] Partial |

---

## Questions Asked

### Question 1

| Aspect | Response |
|--------|----------|
| **Type** | [ ] V1-Explain line [ ] V2-Predict output [ ] V3-Justify choice [ ] V4-Live modify [ ] V5-Debug |
| **Specific question asked** | |
| | _________________________________________________________________ |
| | _________________________________________________________________ |
| **Student response summary** | |
| | _________________________________________________________________ |
| | _________________________________________________________________ |
| **Response quality** | [ ] Confident & correct [ ] Hesitant but correct [ ] Partially correct [ ] Incorrect [ ] No response |
| **Response time** | [ ] Immediate (<5s) [ ] Normal (5-15s) [ ] Slow (15-30s) [ ] Excessive (>30s) |

### Question 2

| Aspect | Response |
|--------|----------|
| **Type** | [ ] V1-Explain line [ ] V2-Predict output [ ] V3-Justify choice [ ] V4-Live modify [ ] V5-Debug |
| **Specific question asked** | |
| | _________________________________________________________________ |
| | _________________________________________________________________ |
| **Student response summary** | |
| | _________________________________________________________________ |
| | _________________________________________________________________ |
| **Response quality** | [ ] Confident & correct [ ] Hesitant but correct [ ] Partially correct [ ] Incorrect [ ] No response |
| **Response time** | [ ] Immediate (<5s) [ ] Normal (5-15s) [ ] Slow (15-30s) [ ] Excessive (>30s) |

---

## Red Flags Checklist

Mark any observed indicators:

| # | Indicator | Observed |
|---|-----------|----------|
| 1 | Cannot explain basic variables in own script | [ ] |
| 2 | Does not know what shebang (`#!/bin/bash`) does | [ ] |
| 3 | Cannot modify script when asked (e.g., add a line) | [ ] |
| 4 | Terminology inconsistent with code comments | [ ] |
| 5 | Response time excessive for simple questions | [ ] |
| 6 | Cannot navigate to own files in terminal | [ ] |
| 7 | Unfamiliar with commands present in own script | [ ] |
| 8 | Code style drastically different from verbal explanation | [ ] |

**Red flags count:** ____/8

**Action required:**
- [ ] 0-1 flags: Normal — proceed with grading
- [ ] 2-3 flags: Suspicious — note for follow-up
- [ ] 4+ flags: Escalate to plagiarism investigation

---

## Verification Result

### Scoring

| Outcome | Points | Mark |
|---------|--------|------|
| Both questions answered correctly and confidently | 10% | [ ] |
| Both correct but hesitant | 8% | [ ] |
| One correct, one partially correct | 6% | [ ] |
| One correct, one incorrect | 5% | [ ] |
| Both partially correct | 4% | [ ] |
| One partially correct, one incorrect | 2% | [ ] |
| Both incorrect or refused to answer | 0% | [ ] |

**Oral verification score:** _____% (out of 10%)

### Final Grade Calculation

```
Autograder score:        ____/90  = ____%
Oral verification:       ____/10  = ____%
Code quality adjustment: ____     (range: -5% to +5%)
Documentation adjustment:____     (range: -3% to +3%)
                         ─────────────────
FINAL GRADE:             ____%
```

---

## Additional Notes

_Use this space for any observations, concerns, or commendations:_

___________________________________________________________________________

___________________________________________________________________________

___________________________________________________________________________

___________________________________________________________________________

---

## Escalation (if required)

| Field | Details |
|-------|---------|
| Escalation reason | ________________________________________________ |
| Evidence preserved | [ ] Screenshots [ ] Recording [ ] Written notes |
| Reported to | ________________________________________________ |
| Date reported | ____/____/20____ |

---

## Signatures

| Role | Signature | Date |
|------|-----------|------|
| **Student** | ________________________________ | ____/____/20____ |
| **Evaluator** | ________________________________ | ____/____/20____ |

> By signing, the student confirms that the oral verification was conducted fairly and that they had the opportunity to demonstrate understanding of their submitted work.

---

## Question Bank Reference

For evaluator convenience — select questions from these categories:

### V1: Explain Specific Line
- "What does line __ of your script do?"
- "Explain the purpose of the variable `____` in your code."
- "Why did you use `set -euo pipefail`?"

### V2: Predict Modification
- "What happens if I change `VAR='test'` to `VAR=`?"
- "If I remove the quotes around `$1`, what could go wrong?"
- "What would this script output if HOME was `/root`?"

### V3: Justify Design Choice
- "Why did you use a function here instead of inline code?"
- "Why `mkdir -p` instead of just `mkdir`?"
- "What's the advantage of your approach over ____?"

### V4: Live Modification
- "Add a line that displays the current date at the start."
- "Modify the script to accept a second argument."
- "Add error handling if the directory doesn't exist."

### V5: Debug Scenario
- "The script fails with 'command not found'. Where would you look?"
- "This outputs nothing. How would you debug it?"
- "The variable is empty when it shouldn't be. Why?"

---

*Form version 1.0 | January 2025 | ASE Bucharest - CSIE*
