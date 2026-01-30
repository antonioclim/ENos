# GRADING_POLICY.md - Official Grading Policy

> **Operating Systems** | ASE Bucharest - CSIE  
> Academic Year 2024-2025

---

## 1. Grading Formula

The final grade is calculated using the following weighted formula:

```
FINAL_GRADE = (HOMEWORK_SCORE × 0.25) + (PROJECT_SCORE × 0.50) + (TEST_SCORE × 0.25)
```

### Component Weights

| Component | Weight | Max Points | Description |
|-----------|--------|------------|-------------|
| **Homeworks** | 25% | 10.00 | Average of completed assignments |
| **Project** | 50% | 10.00 | Semester project evaluation |
| **Tests** | 25% | 10.00 | Average of seminar tests |

### Grade Boundaries

| Grade | Score Range | Description |
|-------|-------------|-------------|
| 10 | 9.50 - 10.00 | Excellent |
| 9 | 8.50 - 9.49 | Very Good |
| 8 | 7.50 - 8.49 | Good |
| 7 | 6.50 - 7.49 | Satisfactory |
| 6 | 5.50 - 6.49 | Sufficient |
| 5 | 5.00 - 5.49 | Pass |
| 4 | 0.00 - 4.99 | Fail |

---

## 2. Elimination Criteria

### ⚠️ CRITICAL: 80% Quantitative Threshold

**All three components have mandatory minimum participation thresholds. Failure to meet ANY threshold results in automatic course failure (grade 4), regardless of scores in other components.**

### 2.1 Homework Threshold

| Metric | Value |
|--------|-------|
| **Total assignments** | 31 |
| **Minimum required** | 25 (80.6%) |
| **Maximum absences** | 6 |

**Assignment Distribution:**

| Seminar | Assignments | Files |
|---------|-------------|-------|
| SEM01 | 6 | S01b_Shell_Usage → S01g_Fundamental_Commands |
| SEM02 | 5 | S02b_Control_Operators → S02f_Scripting_Loops |
| SEM03 | 6 | S03b_Find_Locate → S03g_CRON_Automatizare |
| SEM04 | 5 | S04b_Expresii_Regulate → S04f_Editoare_Text |
| SEM05 | 6 | S05a_Prerequisite_Review → S05f_Logging_Debug |
| SEM06 | 3 | S06_HW01_Monitor → S06_HW03_Deployer |
| **TOTAL** | **31** | |

**Requirements for Valid Submission:**
- Assignment completed **integrally** (all tasks)
- Submitted **on time** (before deadline)
- Valid **cryptographic signature** on `.cast` file
- No **tampering** detected

### 2.2 Test Threshold

| Metric | Value |
|--------|-------|
| **Total tests** | 6 |
| **Minimum required** | 5 (83.3%) |
| **Maximum absences** | 1 |

**Test Schedule:**

| Test | Timing | Topics Covered |
|------|--------|----------------|
| T1 | Start of SEM01 | Prerequisites, Shell basics |
| T2 | Start of SEM02 | Seminar 01 content |
| T3 | Start of SEM03 | Seminars 01-02 content |
| T4 | Start of SEM04 | Seminars 01-03 content |
| T5 | Start of SEM05 | Seminars 01-04 content |
| T6 | Start of SEM06 | Seminars 01-05 content |

**Test Policies:**
- No make-up tests except for documented medical emergencies
- Medical documentation must be submitted within 48 hours
- Maximum one excused absence per semester

### 2.3 Project Threshold

The project **WILL NOT BE EVALUATED AT FINAL** if any of the following conditions is not met:

| Requirement | Verification Method |
|-------------|---------------------|
| ✅ All SEM06 intermediate requirements met | Milestone 1 checklist |
| ✅ Application runs without errors | Automated test suite |
| ✅ Public GitHub repository exists | URL verification |
| ✅ Complete README.md present | Documentation check |
| ✅ REAL outputs presented | Manual verification |

**Critical Notes:**
- Simulated or fabricated outputs result in **automatic failure**
- README.md must include: installation, usage, screenshots of real outputs
- Outputs must be **commented** explaining what they demonstrate

---

## 3. Homework Grading

### 3.1 Grading Scale per Assignment

Each assignment is graded on a 0-10 scale:

| Score | Criteria |
|-------|----------|
| 10 | All tasks completed correctly, clean execution |
| 8-9 | Minor issues, mostly correct |
| 6-7 | Partial completion, some errors |
| 4-5 | Significant gaps, major errors |
| 1-3 | Minimal effort, mostly incorrect |
| 0 | Not submitted or invalid signature |

### 3.2 Late Submission Policy

| Delay | Penalty |
|-------|---------|
| ≤ 24 hours | -20% |
| 24-48 hours | -40% |
| 48-72 hours | -60% |
| > 72 hours | Not accepted (grade 0) |

### 3.3 Final Homework Score Calculation

```python
def calculate_homework_score(submissions):
    valid_submissions = [s for s in submissions if s.is_valid]
    
    if len(valid_submissions) < 25:
        return "ELIMINATION - Below 80% threshold"
    
    total_score = sum(s.score for s in valid_submissions)
    return total_score / len(valid_submissions)
```

---

## 4. Project Grading

### 4.1 Score Composition

| Component | Weight | Max Score |
|-----------|--------|-----------|
| **Automatic Evaluation** | 85% | 8.50 |
| **Manual Evaluation** | 15% | 1.50 |
| **TOTAL** | 100% | 10.00 |

### 4.2 Automatic Evaluation Breakdown

| Criterion | Points | Description |
|-----------|--------|-------------|
| Functional tests pass | 4.00 | All required features work |
| Code quality (ShellCheck/pylint) | 1.50 | No errors, minimal warnings |
| Documentation completeness | 1.50 | README, comments, help text |
| Directory structure | 0.75 | Follows specification |
| Error handling | 0.75 | Graceful failure, clear messages |
| **Subtotal** | **8.50** | |

### 4.3 Manual Evaluation Breakdown

| Criterion | Points | Description |
|-----------|--------|-------------|
| User experience | 0.50 | Intuitive interface, clear output |
| Code elegance | 0.50 | Readability, best practices |
| Innovation/extras | 0.50 | Beyond requirements, creativity |
| **Subtotal** | **1.50** | |

### 4.4 Oral Defence

The oral defence is **mandatory** for grade validation. It does not add points but can result in grade reduction if:

| Issue | Penalty |
|-------|---------|
| Cannot explain own code | -2.00 points |
| Cannot answer basic questions | -1.00 point |
| Suspected plagiarism | Referred to ethics committee |

---

## 5. Test Grading

### 5.1 Test Structure

Each test consists of:

| Section | Questions | Points | Time |
|---------|-----------|--------|------|
| Multiple Choice | 5 | 2.50 | 5 min |
| Short Answer | 3 | 3.00 | 10 min |
| Practical/Code | 2 | 4.50 | 15 min |
| **TOTAL** | **10** | **10.00** | **30 min** |

### 5.2 Final Test Score Calculation

```python
def calculate_test_score(tests):
    taken_tests = [t for t in tests if t.was_taken]
    
    if len(taken_tests) < 5:
        return "ELIMINATION - Below 80% threshold"
    
    return sum(t.score for t in taken_tests) / len(taken_tests)
```

---

## 6. Final Grade Calculation

### 6.1 Algorithm

```python
def calculate_final_grade(student):
    # Step 1: Check elimination criteria
    if student.homework_count < 25:
        return 4, "FAIL: Homework threshold not met"
    
    if student.test_count < 5:
        return 4, "FAIL: Test threshold not met"
    
    if not student.project_eligible:
        return 4, "FAIL: Project requirements not met"
    
    # Step 2: Calculate weighted score
    hw_score = student.homework_average
    proj_score = student.project_score
    test_score = student.test_average
    
    final = (hw_score * 0.25) + (proj_score * 0.50) + (test_score * 0.25)
    
    # Step 3: Round to nearest 0.5
    final_rounded = round(final * 2) / 2
    
    # Step 4: Convert to grade
    if final_rounded >= 5.00:
        grade = int(final_rounded) if final_rounded == int(final_rounded) else int(final_rounded) + 1
        return min(grade, 10), "PASS"
    else:
        return 4, "FAIL: Score below passing threshold"
```

### 6.2 Example Calculations

**Example 1: Passing Student**
```
Homework: 8.5/10 (28/31 submitted)
Project: 9.0/10 
Tests: 7.5/10 (6/6 taken)

Final = (8.5 × 0.25) + (9.0 × 0.50) + (7.5 × 0.25)
     = 2.125 + 4.5 + 1.875
     = 8.5 → Grade 9
```

**Example 2: Elimination - Homework**
```
Homework: 9.0/10 but only 20/31 submitted (64%)
Project: 10.0/10
Tests: 9.5/10

Result: FAIL (Grade 4) - Homework threshold not met
```

**Example 3: Elimination - Project**
```
Homework: 8.0/10 (30/31 submitted)
Project: NOT EVALUATED (no GitHub repository)
Tests: 8.5/10 (5/6 taken)

Result: FAIL (Grade 4) - Project requirements not met
```

---

## 7. Appeals Process

### 7.1 Timeline
- Appeals must be submitted within **48 hours** of grade publication
- Written appeal to course coordinator via email
- Include specific concerns and supporting evidence

### 7.2 Grounds for Appeal
- Calculation error
- Technical issues with submission system
- Medical or personal emergency (with documentation)

### 7.3 Not Grounds for Appeal
- Disagreement with grading rubric
- "I worked hard"
- Deadline extensions after the fact

---

## 8. Academic Integrity

### 8.1 Prohibited Actions
- Copying code from colleagues
- Using AI to generate solutions without disclosure
- Tampering with `.cast` recordings
- Submitting others' work as your own

### 8.2 Consequences
| Offence | Consequence |
|---------|-------------|
| First offence | Zero on assignment + warning |
| Second offence | Course failure (Grade 4) |
| Severe case | Referral to university ethics committee |

---

## Document History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2025-01-30 | A. Clim | Initial version |

---

*By Revolvix for OPERATING SYSTEMS class | restricted licence 2017-2030*
