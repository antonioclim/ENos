# Universal Evaluation Rubric - Semester Projects

> **Document for Evaluators**  
> **Operating Systems** | ASE Bucharest - CSIE

---

## Scoring System

> **Important note**: All scores are expressed in **percentages (%)** of the final grade. The value in absolute points will be communicated by the instructor at the beginning of the semester.

---

## Evaluation Structure

| Component | Weight | Description |
|-----------|--------|-------------|
| Functionality | 40% | Requirements implementation |
| Code Quality | 20% | Structure, clarity, best practices |
| Documentation | 15% | README, comments, guides |
| Tests | 15% | Test coverage and quality |
| Presentation | 10% | Demo and explanations |
| **TOTAL** | **100%** | |

---

## Criteria Details

### 1. FUNCTIONALITY (40%)

#### 1.1 Mandatory Requirements (30%)

| Criterion | % | Excellent (100%) | Good (70%) | Satisfactory (50%) | Insufficient (20%) |
|-----------|---|------------------|------------|--------------------|--------------------|
| Core functionality | 15% | All functions correctly implemented | Main functions OK, minor gaps | Partially functional | Does not work |
| Input handling | 8% | Complete validation, clear messages | Main validation | Minimal validation | No validation |
| Correct output | 7% | Correct format, informative | Format OK | Basic output | Incorrect output |

#### 1.2 Optional/Advanced Requirements (10%)

| Criterion | % | Description |
|-----------|---|-------------|
| Extra functionalities | 5% | Implementations beyond minimum requirements |
| Optimisations | 3% | Performance, efficiency |
| Integrations | 2% | Integration with other tools |

### 2. CODE QUALITY (20%)

#### 2.1 Structure and Organisation (8%)

| Criterion | % | Excellent | Acceptable | Insufficient |
|-----------|---|-----------|------------|--------------|
| Modularity | 3% | Well-defined functions, separate lib/ | Some functions | Monolithic code |
| File organisation | 3% | Standard structure (src/, tests/, docs/) | Logical structure | Disorganised |
| Separation of concerns | 2% | Config/logic/UI separate | Partially separate | Everything mixed |

#### 2.2 Code Clarity (7%)

| Criterion | % | Excellent | Acceptable | Insufficient |
|-----------|---|-----------|------------|--------------|
| Variable naming | 3% | Descriptive, consistent | Mostly clear | Ambiguous |
| Complexity | 2% | Short functions, clear logic | Acceptable | Long, confusing functions |
| Formatting | 2% | Consistent indentation | Minor inconsistencies | Unformatted |

#### 2.3 Best Practices (5%)

| Criterion | % | Excellent | Acceptable | Insufficient |
|-----------|---|-----------|------------|--------------|
| ShellCheck clean | 2% | 0 warnings | < 5 minor warnings | Multiple errors |
| Error handling | 2% | `set -euo pipefail`, trap | Partial | No handling |
| Portability | 1% | Works on any Linux | Minor issues | Hardcoded paths |

### 3. DOCUMENTATION (15%)

#### 3.1 README.md (8%)

| Section | % | Excellent | Acceptable | Insufficient |
|---------|---|-----------|------------|--------------|
| Project description | 2% | Clear, complete | Present | Missing/vague |
| Installation | 2% | Detailed steps, dependencies | Basic instructions | Missing |
| Usage | 2% | Examples, documented options | Basic usage | Missing |
| Project structure | 2% | Complete tree explained | File listing | Missing |

#### 3.2 Technical Documentation (4%)

| Document | % | Excellent | Acceptable | Insufficient |
|----------|---|-----------|------------|--------------|
| INSTALL.md | 2% | Dependencies, steps, troubleshooting | Basic | Missing |
| ARCHITECTURE.md | 2% | Diagrams, data flow | Text description | Missing |

#### 3.3 Code Comments (3%)

| Criterion | % | Excellent | Acceptable | Insufficient |
|-----------|---|-----------|------------|--------------|
| Documented functions | 2% | All with docstring | Main ones documented | No comments |
| Complex logic | 1% | Inline explanations | Some comments | Unexplained code |

### 4. AUTOMATED TESTS (15%)

#### 4.1 Coverage (10%)

| Coverage | % awarded |
|----------|-----------|
| > 80% functionalities | 10% |
| 60-80% | 8% |
| 40-60% | 6% |
| 20-40% | 4% |
| < 20% | 2% |

#### 4.2 Test Quality (5%)

| Criterion | % | Excellent | Acceptable | Insufficient |
|-----------|---|-----------|------------|--------------|
| Edge case tests | 2% | Edge cases tested | Some cases | Only happy path |
| Negative tests | 2% | Errors validated | Some | None |
| Organisation | 1% | Structured, reusable | Functional | Disorderly |

### 5. PRESENTATION (10%)

| Criterion | % | Excellent | Acceptable | Insufficient |
|-----------|---|-----------|------------|--------------|
| Live demonstration | 4% | Works perfectly | Minor issues | Does not work |
| Architecture explanation | 3% | Clear, complete | Acceptable | Confusing |
| Answers to questions | 3% | Understands everything | Most of it | Cannot explain |

---

## BONUSES

| Bonus | Value | Requirements |
|-------|-------|--------------|
| Kubernetes Extension | +10% | Functional deployment, K8s documentation |
| C Component | +15% | Compilable and integrated C module |
| CI/CD Pipeline | +5% | Functional GitHub Actions with tests |
| Video documentation | +5% | 3-5 min demo, good quality |

**Note:** Bonuses are added on top of 100% and are awarded fully or not at all (not partially).

---

## PENALTIES

### Delays

| Delay | Penalty |
|-------|---------|
| < 1 hour | -0% (warning) |
| 1-24 hours | -10% |
| 24-72 hours | -25% |
| 72h - 7 days | -50% |
| > 7 days | Not accepted |

### Technical Issues

| Issue | Penalty |
|-------|---------|
| Does not compile/run | -30% |
| Missing README.md | -15% |
| Completely missing tests | -10% |
| Severe ShellCheck errors | -5% |
| Hardcoded paths | -5% |
| Binary files in repo | -5% |

### Plagiarism and Academic Integrity

| Situation | Consequence |
|-----------|-------------|
| Identical code with colleague | -100% (both) + report |
| Uncited internet code | -50% first offence |
| Repeat offence | Proposed expulsion |

---

## EVALUATION FORM

```
╔══════════════════════════════════════════════════════════════════╗
║           SEMESTER PROJECT EVALUATION - OPERATING SYSTEMS        ║
╠══════════════════════════════════════════════════════════════════╣
║ Student:     ________________________________________________    ║
║ Project:     ________________________________________________    ║
║ Date:        ________________________________________________    ║
╠══════════════════════════════════════════════════════════════════╣
║                                                                  ║
║ 1. FUNCTIONALITY (40%)                                           ║
║    ├─ Mandatory requirements (30%):  _____ × 0.30 = _____       ║
║    └─ Optional requirements (10%):   _____ × 0.10 = _____       ║
║                                      Subtotal: _____%            ║
║                                                                  ║
║ 2. CODE QUALITY (20%)                                            ║
║    ├─ Structure (8%):                _____ × 0.08 = _____       ║
║    ├─ Clarity (7%):                  _____ × 0.07 = _____       ║
║    └─ Best practices (5%):           _____ × 0.05 = _____       ║
║                                      Subtotal: _____%            ║
║                                                                  ║
║ 3. DOCUMENTATION (15%)                                           ║
║    ├─ README.md (8%):                _____ × 0.08 = _____       ║
║    ├─ Technical docs (4%):           _____ × 0.04 = _____       ║
║    └─ Comments (3%):                 _____ × 0.03 = _____       ║
║                                      Subtotal: _____%            ║
║                                                                  ║
║ 4. TESTS (15%)                                                   ║
║    ├─ Coverage (10%):                _____ × 0.10 = _____       ║
║    └─ Quality (5%):                  _____ × 0.05 = _____       ║
║                                      Subtotal: _____%            ║
║                                                                  ║
║ 5. PRESENTATION (10%)                                            ║
║    ├─ Demo (4%):                     _____ × 0.04 = _____       ║
║    ├─ Explanations (3%):             _____ × 0.03 = _____       ║
║    └─ Questions (3%):                _____ × 0.03 = _____       ║
║                                      Subtotal: _____%            ║
║                                                                  ║
╠══════════════════════════════════════════════════════════════════╣
║                                                                  ║
║ SUBTOTAL (max 100%):                           _____%            ║
║                                                                  ║
║ BONUSES:                                                         ║
║    □ Kubernetes (+10%):                        +_____%           ║
║    □ C Component (+15%):                       +_____%           ║
║    □ CI/CD (+5%):                              +_____%           ║
║    □ Video (+5%):                              +_____%           ║
║                                                                  ║
║ PENALTIES:                                                       ║
║    □ Delay:                                    -_____%           ║
║    □ Technical issues:                         -_____%           ║
║    □ Other:                                    -_____%           ║
║                                                                  ║
╠══════════════════════════════════════════════════════════════════╣
║                                                                  ║
║ ══════════════════════════════════════════════════════════════   ║
║ FINAL TOTAL:                                   _____%            ║
║ ══════════════════════════════════════════════════════════════   ║
║                                                                  ║
║ Comments:                                                        ║
║ ________________________________________________________________ ║
║ ________________________________________________________________ ║
║ ________________________________________________________________ ║
║                                                                  ║
║ Evaluator: ________________________  Signature: _______________  ║
║                                                                  ║
╚══════════════════════════════════════════════════════════════════╝
```

---

## QUICK EVALUATION CHECKLIST

```
Pre-evaluation (automatic):
□ Archive correctly named
□ File structure followed
□ README.md present
□ Scripts have shebang
□ bash -n passes without errors
□ ShellCheck without critical errors

Functional evaluation:
□ Installation following INSTALL.md works
□ Help command works
□ Main scenario works
□ Edge cases handled
□ Errors reported clearly

Qualitative evaluation:
□ Readable and commented code
□ Modularised functions
□ Descriptively named variables
□ Tests present and passing
□ Complete documentation

Presentation:
□ Student can run the project
□ Student explains the architecture
□ Student answers questions about the code
```

---

*Universal Rubric - OS Projects | January 2025*
