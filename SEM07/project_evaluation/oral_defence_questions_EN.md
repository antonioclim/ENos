# Oral Defence Question Bank

> **Operating Systems** | ASE Bucharest - CSIE  
> Project Evaluation - SEM07

---

## Overview

The oral defence is mandatory for project grade validation. Students must demonstrate understanding of their own code and the concepts applied.

**Duration:** 10-15 minutes per student/team  
**Format:** Individual questioning (even for team projects)

---

## 1. Generic Questions (All Projects)

### 1.1 Code Understanding

1. **Walk me through the main function of your script.**
   - Expected: Clear explanation of entry point and flow

2. **What happens when your script starts? Describe the initialisation.**
   - Expected: Config loading, argument parsing, setup

3. **Show me the most complex function you wrote. Explain it line by line.**
   - Expected: Detailed understanding, not memorised explanation

4. **Why did you choose this particular data structure?**
   - Expected: Justification based on requirements

5. **What would happen if I removed this line?** *(point to critical line)*
   - Expected: Understanding of dependencies

### 1.2 Error Handling

6. **What happens if the input file doesn't exist?**
   - Expected: Error message, non-zero exit, no crash

7. **How does your script handle invalid user input?**
   - Expected: Validation, clear error messages

8. **What happens if the script is interrupted with Ctrl+C?**
   - Expected: Trap handling, cleanup

9. **Show me where you handle errors in this function.**
   - Expected: Point to specific error handling code

10. **What exit codes does your script return and when?**
    - Expected: Documented exit codes with meanings

### 1.3 Testing

11. **How did you test your script?**
    - Expected: Manual testing, edge cases, automated tests

12. **What was the hardest bug to fix? How did you find it?**
    - Expected: Debugging process, tools used

13. **Did you test with unusual inputs? Give an example.**
    - Expected: Edge cases like empty files, special characters

14. **How would you add a new test case?**
    - Expected: Understanding of test structure

### 1.4 Design Decisions

15. **Why did you organise the code this way?**
    - Expected: Logical reasoning about structure

16. **If you had to start over, what would you do differently?**
    - Expected: Self-reflection, lessons learned

17. **What trade-offs did you make in your implementation?**
    - Expected: Understanding of alternatives

18. **Why Bash instead of Python (or vice versa)?**
    - Expected: Appropriate tool selection reasoning

---

## 2. Project-Specific Questions

### 2.1 EASY Projects

#### E01 - File System Auditor

1. How do you handle symbolic links in your audit?
2. What's the difference between `-mtime` and `-atime` in find?
3. How do you calculate directory sizes recursively?
4. Why might file counts differ between your tool and `ls | wc -l`?

#### E02 - Log Analyser

1. What regular expression do you use to extract IP addresses?
2. How do you handle log files with different formats?
3. What happens with very large log files (> 1GB)?
4. How do you count unique versus total entries?

#### E03 - Process Monitor

1. Where does your script get process information from?
2. What's the difference between RSS and VSZ memory?
3. How do you calculate CPU percentage?
4. Why might your process list differ from `top`?

#### E04 - Backup Manager

1. Explain your incremental backup logic.
2. How do you ensure backup integrity?
3. What happens during restoration?
4. How do you handle file permission preservation?

#### E05 - Network Diagnostics

1. How do you check if a host is reachable?
2. What's the difference between TCP and UDP checks?
3. How do you parse traceroute output?
4. What timeout values do you use and why?

### 2.2 MEDIUM Projects

#### M01 - Incremental Backup System

1. Explain your algorithm for detecting changed files.
2. How do you handle renamed files?
3. What metadata do you store with each backup?
4. How does restoration work with incremental backups?
5. What's your strategy for backup rotation?

#### M02 - System Resource Dashboard

1. How do you calculate the CPU usage percentage?
2. What refresh rate did you choose and why?
3. How do you handle terminal resize events?
4. Explain your colour-coding for thresholds.
5. What's the memory overhead of your dashboard?

#### M03 - Automated Testing Framework

1. How do you discover test files?
2. What's your test isolation strategy?
3. How do you report test failures?
4. Can tests run in parallel? How?
5. How do you handle test dependencies?

#### M04 - Configuration Management

1. How do you parse configuration files?
2. What happens with syntax errors in config?
3. How do you handle configuration inheritance?
4. What's your strategy for secrets management?
5. How do you validate configuration values?

#### M05 - Service Health Monitor

1. How do you define "healthy" for a service?
2. What's your alerting mechanism?
3. How do you handle flapping services?
4. What metrics do you collect?
5. How do you avoid alert fatigue?

### 2.3 ADVANCED Projects

#### A01 - Container Management System

1. Explain your container isolation approach.
2. How do you manage container networking?
3. What's your image layer strategy?
4. How do you handle resource limits?
5. What security measures did you implement?
6. How does your system compare to Docker?

#### A02 - Distributed Task Queue

1. Explain your task distribution algorithm.
2. How do you handle worker failures?
3. What's your strategy for task prioritisation?
4. How do you ensure exactly-once execution?
5. What's the throughput of your system?
6. How do you handle network partitions?

#### A03 - Custom Shell Implementation

1. How do you parse command lines?
2. Explain your job control implementation.
3. How do you handle pipes?
4. What built-in commands did you implement?
5. How do you handle signal forwarding?
6. What's your approach to command history?

---

## 3. Concept Verification Questions

### 3.1 Linux/Unix Fundamentals

1. What's a file descriptor? How many does your script use?
2. Explain the difference between a process and a thread.
3. What's the purpose of `/proc` filesystem?
4. How does the shell find commands to execute?
5. What happens during a fork-exec sequence?

### 3.2 Bash Specifics

1. What does `set -euo pipefail` do?
2. Explain the difference between `$@` and `$*`.
3. When would you use `[[ ]]` vs `[ ]`?
4. What's command substitution? Show an example.
5. How do subshells affect variable scope?

### 3.3 System Administration

1. How would you run your script as a service?
2. What logs would help debug your script in production?
3. How would you monitor your script's resource usage?
4. What permissions does your script need?
5. How would you deploy this to multiple servers?

---

## 4. Red Flags (Indicates Potential Issues)

### 4.1 Warning Signs

| Behaviour | Concern |
|-----------|---------|
| Cannot explain basic syntax | May not have written the code |
| Inconsistent naming knowledge | Copied from different sources |
| Cannot modify code on request | Memorised, not understood |
| Defensive when questioned | Hiding something |
| Blames teammates for parts | Individual understanding lacking |

### 4.2 Follow-up Actions

If red flags appear:
1. Ask to make a small modification live
2. Request explanation of a different section
3. Ask about development process and commit history
4. Compare answers between team members
5. If necessary, refer to academic integrity committee

---

## 5. Scoring Guidelines

### 5.1 Defence Score Impact

The oral defence does not add points but can reduce the project score:

| Performance | Adjustment |
|-------------|------------|
| Excellent understanding | No change |
| Good understanding | No change |
| Partial understanding | -1.0 point |
| Poor understanding | -2.0 points |
| Cannot explain own code | Refer to ethics committee |

### 5.2 Sample Scoring Rubric

| Criterion | 0 | 1 | 2 |
|-----------|---|---|---|
| Code explanation | Cannot explain | Partially explains | Fully explains |
| Concept understanding | No understanding | Basic understanding | Deep understanding |
| Problem-solving | Cannot adapt | Adapts with help | Adapts independently |
| Communication | Unclear | Adequate | Clear and precise |

---

## 6. Documentation for Examiners

### 6.1 Before Defence
- Review student's code briefly
- Note specific questions for their implementation
- Check commit history for contribution patterns
- Prepare IDE/terminal for live demonstration

### 6.2 During Defence
- Start with generic questions to ease nervousness
- Progress to code-specific questions
- Ask for live modifications when appropriate
- Note responses for later comparison (team projects)

### 6.3 After Defence
- Complete scoring rubric immediately
- Note any concerns for follow-up
- Compare team member responses if applicable
- Document any academic integrity concerns

---

*By Revolvix for OPERATING SYSTEMS class | restricted licence 2017-2030*
