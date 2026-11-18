# General Evaluation - Semester Projects

> **Current status:** Numerical assessment, bonus and penalty rules below are historical proposals awaiting author reconciliation. Timings, anecdotes and experiential claims are retained with unverified provenance. See [ASSESSMENT_AND_EVIDENCE_CONTRACT.md](ASSESSMENT_AND_EVIDENCE_CONTRACT.md) for the concrete choices, consequences and recommended resolution. No grade or publication policy is adopted by these examples.

> **Document for Students and Instructors**  
> **Operating Systems** | ASE Bucharest - CSIE

---

## Evaluation Philosophy

Project evaluation aims to verify **deep understanding** of operating systems concepts and the ability to **apply them in practice**. We are not looking for perfect code, but rather a demonstration of acquired competencies.

> 💡 **What I actually look for:** Can you explain what your code does? Do you understand *why* it works, not just *that* it works? I have seen students with imperfect code score higher than those with "perfect" code they could not explain.

---

## Evaluation Criteria

### 1. Functionality (40%)

| Level | Percentage | Description |
|-------|------------|-------------|
| Excellent | 100% | All requirements implemented, works without errors |
| Very Good | 85% | Main requirements complete, minor errors |
| Good | 70% | Most requirements met, some gaps |
| Satisfactory | 55% | Basic requirements, limited functionality |
| Insufficient | 30% | Partially functional |
| Unacceptable | 0% | Does not run or missing |

**What we verify:**
- ✅ Main script runs without errors
- ✅ All mandatory requirements are implemented
- ✅ Edge cases are handled appropriately
- ✅ Correct behaviour under normal and error conditions

### 2. Code Quality (20%)

| Aspect | Weight | Criteria |
|--------|--------|----------|
| Structure | 5% | Modularity, file organisation |
| Clarity | 5% | Readable code, descriptive variables |
| Best Practices | 5% | ShellCheck review and tested explicit failure handling, including strict-mode exceptions |
| Efficiency | 5% | No redundancies, reasonable algorithms |

**Quality checklist:**
```bash
# ShellCheck verification
shellcheck -x src/*.sh

# Syntax verification
bash -n src/main.sh

# Structure verification
tree -L 2 .
```

> ⚠️ **Common mistake:** Students who skip ShellCheck often lose 5-10% on avoidable issues. Run it early, run it often.

### 3. Documentation (15%)

| Document | Weight | Required Content |
|----------|--------|------------------|
| README.md | 8% | Description, installation, usage, examples |
| INSTALL.md | 3% | Dependencies, installation steps |
| Code comments | 4% | Documented functions, explained logic |

**Minimum README.md:**
- Project title and description
- System requirements (dependencies)
- Installation instructions
- Usage examples
- Project structure
- Author and licence

### 4. Automated Tests (15%)

| Coverage | Percentage |
|----------|------------|
| > 80% functionalities tested | 100% |
| 60-80% | 80% |
| 40-60% | 60% |
| 20-40% | 40% |
| < 20% | 20% |

**Recommended test structure:**
```text
tests/
├── test_main.sh          # Main functionality tests
├── test_edge_cases.sh    # Edge case tests
├── test_error_handling.sh # Error handling tests
└── run_all.sh            # Runner for all tests
```

### 5. Presentation (10%)

| Aspect | Weight |
|--------|--------|
| Functional demonstration | 4% |
| Code explanation | 3% |
| Answers to questions | 3% |

> 💡 **Presentation tip:** I will ask you to explain the trickiest part of your code. Know it well. Also, prepare for "what would you do differently if you started over?"

---

## Bonuses

### Kubernetes Extension (+10%)

Available for MEDIUM projects. Requirements:
- Functional deployment in Kubernetes (minikube accepted)
- YAML files for deployment, service, configmap
- K8s deployment documentation

### C Component (+15%)

For any project. Requirements:
- Compilable C module that extends functionality
- Correct integration with Bash scripts
- Makefile for compilation

### CI/CD Pipeline (+5%)

- Functional GitHub Actions or GitLab CI
- Automatic test execution on push
- Status badge in README

### Video Documentation (+5%)

- Demonstration video 3-5 minutes
- Shows main functionality
- Acceptable audio/video quality

---

## Penalties

### Delays

| Delay | Penalty |
|-------|---------|
| < 1 hour | Warning |
| 1-24 hours | -10% |
| 24-72 hours | -25% |
| 72h - 1 week | -50% |
| > 1 week | Not accepted |

> ⚠️ **Reality check:** Every semester, 2-3 students email me at 23:55 saying "the upload is not working." Start uploading at 22:00 latest.

### Technical Issues

| Issue | Penalty |
|-------|---------|
| Does not compile/run | -30% |
| Missing README | -15% |
| Missing tests | -10% |
| Severe ShellCheck errors | -5% |
| Hardcoded paths | -5% |

### Plagiarism

| Situation | Consequence |
|-----------|-------------|
| Code copied from colleagues | -100% (both students) |
| Code copied from internet without citation | -50% first offence |
| Repeated plagiarism | Disciplinary report |

**Note:** Using AI (ChatGPT, Claude, etc.) is permitted for **learning and debugging**, but the final code must be fully understood and explained during the presentation.

---

## Evaluation Process

### Stage 1: Automatic Verification

```bash
# Validation script run automatically
./helpers/project_validator.sh student_project/

# Verifies:
# - File structure
# - Script syntax
# - ShellCheck
# - Documentation presence
```

### Stage 2: Functional Evaluation

The instructor runs the project on a clean system:
1. Clone repository
2. Follow INSTALL.md
3. Run automated tests
4. Manual testing of scenarios

### Stage 3: Code Review

- Code quality verification
- Originality verification
- Comments and documentation verification

### Stage 4: Presentation

- Live demonstration (5-10 min)
- Architecture explanation (3-5 min)
- Questions (5 min)

---

## Evaluation Form

```
OS PROJECT EVALUATION
=====================

Student: ___________________
Project: ___________________
Date: ___________________

FUNCTIONALITY (40%)
-------------------
□ Mandatory requirements:  ___/100 × 0.30 = ___
□ Optional requirements:   ___/100 × 0.10 = ___
Subtotal: ___

CODE QUALITY (20%)
------------------
□ Structure:               ___/100 × 0.05 = ___
□ Clarity:                 ___/100 × 0.05 = ___
□ Best practices:          ___/100 × 0.05 = ___
□ Efficiency:              ___/100 × 0.05 = ___
Subtotal: ___

DOCUMENTATION (15%)
-------------------
□ README.md:               ___/100 × 0.08 = ___
□ Installation:            ___/100 × 0.03 = ___
□ Comments:                ___/100 × 0.04 = ___
Subtotal: ___

TESTS (15%)
-----------
□ Coverage:                ___/100 × 0.15 = ___
Subtotal: ___

PRESENTATION (10%)
------------------
□ Demo:                    ___/100 × 0.04 = ___
□ Explanations:            ___/100 × 0.03 = ___
□ Questions:               ___/100 × 0.03 = ___
Subtotal: ___

BONUSES
-------
□ Kubernetes:              +___
□ C Component:             +___
□ CI/CD:                   +___
□ Video:                   +___
Total bonuses: +___

PENALTIES
---------
□ Delay:                   -___
□ Technical issues:        -___
□ Other:                   -___
Total penalties: -___

================================
FINAL TOTAL: ___/100 (+ bonuses - penalties)
================================

Comments:
___________________________________________
___________________________________________

Evaluator signature: ___________________
```

---

## Tips for Maximum Grade

1. **Start early** — time passes quickly
2. **Test constantly** — do not leave tests for the end
3. **Document as you go** — it is easier than at the end
4. **Use version control** — frequent and descriptive commits
5. **Ask for feedback** — at consultations, before the deadline
6. **Read requirements carefully** — multiple times
7. **Do more than the minimum** — differentiate yourself

> 💡 **Final advice:** The students who score highest are not always the best coders. They are the ones who deliver complete, well-documented projects on time. Consistency beats brilliance.

---

*Document updated: January 2025*
