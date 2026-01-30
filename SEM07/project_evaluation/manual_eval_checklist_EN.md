# Manual Evaluation Checklist

> **Operating Systems** | ASE Bucharest - CSIE  
> Project Evaluation - SEM07

---

## Overview

Manual evaluation accounts for **15%** of the project score (1.5 points out of 10).

This checklist guides instructors through the subjective aspects of project evaluation that cannot be automated.

---

## 1. User Experience (0.5 points)

### 1.1 Interface Clarity

| Criterion | 0 | 0.1 | 0.2 |
|-----------|---|-----|-----|
| Help message | None | Basic | Comprehensive |
| Error messages | Cryptic | Adequate | Clear and actionable |
| Progress indication | None | Basic | Detailed |
| Output formatting | Messy | Readable | Well-structured |

**Questions to consider:**
- [ ] Is it obvious how to use the tool?
- [ ] Do error messages help the user fix the problem?
- [ ] Is output easy to read and understand?
- [ ] Does the tool provide feedback during long operations?

### 1.2 Usability

| Criterion | 0 | 0.05 | 0.1 |
|-----------|---|------|-----|
| Default values | None/bad | Reasonable | Optimal |
| Confirmation prompts | Missing where needed | Present | Appropriate level |
| Keyboard shortcuts | None | Some | Comprehensive |
| Configuration | Hardcoded | Config file | Multiple options |

**Scoring Notes:**
- Award full points if a first-time user could use the tool effectively
- Deduct if excessive documentation reading is required for basic use

---

## 2. Code Elegance (0.5 points)

### 2.1 Readability

| Criterion | 0 | 0.1 | 0.2 |
|-----------|---|-----|-----|
| Variable names | Single letters | Descriptive | Self-documenting |
| Function names | Unclear | Adequate | Verb-noun pattern |
| Code organisation | Monolithic | Some structure | Well-modularised |
| Comments | None | Basic | Explains why, not what |

**Code Review Checklist:**
- [ ] Can you understand a function without reading its implementation?
- [ ] Are magic numbers explained or named?
- [ ] Is complex logic broken into smaller functions?
- [ ] Do comments add value beyond the code itself?

### 2.2 Best Practices

| Criterion | 0 | 0.05 | 0.1 |
|-----------|---|------|-----|
| Quoting | Inconsistent | Mostly correct | Always correct |
| Error handling | Missing | Basic | Comprehensive |
| Strict mode | Not used | Partial | Full (set -euo pipefail) |
| Shellcheck | Many warnings | Few warnings | Clean |

### 2.3 Consistency

| Criterion | 0 | 0.05 | 0.1 |
|-----------|---|------|-----|
| Naming convention | Mixed styles | Mostly consistent | Fully consistent |
| Indentation | Inconsistent | Mostly 4 spaces | Consistent |
| Brace style | Mixed | Consistent | Consistent + documented |
| Quote style | Mixed | Mostly consistent | Consistent |

---

## 3. Innovation and Extras (0.5 points)

### 3.1 Beyond Requirements

| Extra Feature | Points |
|---------------|--------|
| Colour-coded output | +0.05 |
| Interactive mode | +0.05 |
| Tab completion | +0.1 |
| Man page | +0.1 |
| Bash completion script | +0.1 |
| Comprehensive test suite | +0.1 |
| Performance optimisation | +0.1 |
| Security hardening | +0.1 |

**Maximum from extras: 0.5 points**

### 3.2 Creative Solutions

Award additional points for:
- Novel approaches to problems
- Elegant algorithms
- Thoughtful architecture decisions
- Exceptional documentation

**Note:** Innovation points are discretionary and should be justified in comments.

---

## 4. Documentation Quality

### 4.1 README.md Evaluation

| Section | Required | Points |
|---------|----------|--------|
| Project title and description | Yes | Included in auto-eval |
| Installation instructions | Yes | Included in auto-eval |
| Usage examples | Yes | +0.05 if exceptional |
| Screenshots/demos | Recommended | +0.05 |
| Architecture overview | Optional | +0.05 |
| Contributing guidelines | Optional | +0.025 |
| Licence | Required | Included in auto-eval |

### 4.2 Code Documentation

| Aspect | Poor | Adequate | Good |
|--------|------|----------|------|
| Function headers | None | Parameters listed | Full docstring |
| Complex logic | No explanation | Brief comment | Detailed explanation |
| Configuration | Undocumented | Inline comments | Separate documentation |

---

## 5. Evaluation Form Template

```markdown
# Manual Evaluation: [Project Name]
**Student/Team:** [Name(s)]
**Evaluator:** [Instructor Name]
**Date:** [Date]

## 1. User Experience (0.5 max)
- Interface clarity: ___ / 0.2
- Usability: ___ / 0.1
- Error handling UX: ___ / 0.1
- Overall polish: ___ / 0.1

**Comments:**
[Write observations here]

**Subtotal:** ___ / 0.5

## 2. Code Elegance (0.5 max)
- Readability: ___ / 0.2
- Best practices: ___ / 0.1
- Consistency: ___ / 0.1
- Architecture: ___ / 0.1

**Comments:**
[Write observations here]

**Subtotal:** ___ / 0.5

## 3. Innovation (0.5 max)
- Extra features: ___ / 0.3
- Creative solutions: ___ / 0.2

**Features noted:**
- [ ] Feature 1
- [ ] Feature 2

**Subtotal:** ___ / 0.5

## Summary
| Component | Score |
|-----------|-------|
| User Experience | ___ / 0.5 |
| Code Elegance | ___ / 0.5 |
| Innovation | ___ / 0.5 |
| **TOTAL** | ___ / 1.5 |

## Overall Comments
[Final remarks, suggestions for improvement]

## Red Flags
- [ ] None
- [ ] Potential plagiarism indicators
- [ ] Mismatched code style suggesting multiple authors
- [ ] Other: _______________
```

---

## 6. Calibration Guidelines

### 6.1 Reference Projects

Before evaluating, review these reference implementations:
- **Exemplary (1.4-1.5):** Clean, well-documented, extra features
- **Good (1.0-1.3):** Solid implementation, minor issues
- **Adequate (0.7-0.9):** Functional but rough edges
- **Poor (0.3-0.6):** Works but significant issues
- **Failing (0-0.2):** Major problems

### 6.2 Common Pitfalls

**Over-scoring:**
- Impressive features but poor code quality
- Good README but actual code is messy
- Complex solution when simple would suffice

**Under-scoring:**
- Simple but elegant solution
- Minimalist interface that works well
- Code that "just works" without flashiness

---

## 7. Plagiarism Indicators

### 7.1 Code Similarity

Watch for:
- Identical variable names between unrelated students
- Same unusual approaches or bugs
- Comments that don't match student's English level
- Code style inconsistencies within one project

### 7.2 Actions

| Finding | Action |
|---------|--------|
| Minor similarity | Note for oral defence |
| Significant similarity | Compare with source, question both |
| Clear plagiarism | Refer to academic integrity |

---

## 8. Final Checklist

Before submitting manual evaluation:

- [ ] All three sections scored
- [ ] Comments provided for each section
- [ ] Total calculated correctly
- [ ] Any red flags documented
- [ ] Evaluation form saved to records
- [ ] If concerns, noted for oral defence follow-up

---

*By Revolvix for OPERATING SYSTEMS class | restricted licence 2017-2030*
