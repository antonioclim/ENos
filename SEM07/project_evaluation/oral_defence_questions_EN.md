# Oral Defence Question Bank

> **Operating Systems** | ASE Bucharest - CSIE  
> Project Evaluation - SEM07

---

## Overview

Historical requirement: the oral defence was proposed for project grade validation; the author must reconcile its scope, timing and score consequences with the other project guides. Students must demonstrate understanding of their own code and the concepts applied.

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

The following23 codes match the published catalogue. Use questions relevant to the submitted implementation and record a bounded demonstration, not an inferred authorship probability.

### E01 — File System Auditor

1. How do symlinks and unreadable directories affect your inventory?
2. How do NUL delimiters preserve filenames with whitespace/newlines?
3. Show a fixture with a known exact count and a deliberate failure.

### E02 — Log Analyser

1. Which precise input grammar does your parser accept?
2. How are malformed lines, timezones and empty matches reported?
3. Demonstrate counts on a bounded known log, including a negative control.

### E03 — Bulk File Organiser

1. How do you prevent overwriting a destination collision?
2. What happens to dotfiles, extensionless files and symlinks?
3. How can a dry run be compared with the actual owned-fixture changes?

### E04 — System Health Reporter

1. Which metrics are interval measurements and which are cumulative?
2. How do unavailable data differ from healthy zero values?
3. How do you encode quotes/newlines in JSON or CSV output?

### E05 — Config File Manager

1. How do you parse values without executing them?
2. How are repeated/missing keys and spaces handled?
3. Demonstrate a failed validation leaving the prior file intact.

### M01 — Incremental Backup System

1. Which chain members are needed to restore a selected increment?
2. Demonstrate create, modify, delete and rename across two backups.
3. How does retention preserve every required parent?

### M02 — Process Lifecycle Monitor

1. How do PID reuse and process start ticks affect identity?
2. How do you parse a comm field containing parentheses/spaces?
3. Which short-lived processes can polling miss?

### M03 — Service Health Watchdog

1. What observable condition defines health for this service?
2. How do restart limits, backoff and unknown data interact?
3. Show a bounded fake-service recovery and a persistent failure.

### M04 — Network Security Scanner

1. What explicit target range and time/concurrency bounds apply?
2. How do DNS, connection refusal and timeout differ?
3. What do scan results fail to establish about application security?

### M05 — Deployment Pipeline

1. Which failure stops all later stages?
2. What immutable package/digest is validated before activation?
3. What is rolled back and what availability is actually demonstrated?

### M06 — Resource Usage Historian

1. How do counter resets, sampling gaps and timestamp units affect rates?
2. How are CPU guest/iowait and MemAvailable interpreted?
3. How do you distinguish missing values from genuine zero?

### M07 — Security Audit Framework

1. Which checks depend on permissions and which are unavailable?
2. How does an empty/error result avoid a false compliance pass?
3. What exact evidence supports a remediation recommendation?

### M08 — Disk Storage Manager

1. How do capacity and inode usage differ?
2. How do you constrain cleanup to the intended owned tree?
3. How do you verify a failed move/compression preserves source data?

### M09 — Scheduled Tasks Manager

1. Which cron grammar is supported, including ranges and steps?
2. How do timezone/DST and day-of-month/day-of-week semantics matter?
3. How is scheduler state staged and validated before replacement?

### M10 — Process Tree Analyzer

1. How do you handle reparenting, subreapers and PID reuse?
2. What terminates ancestry traversal?
3. What can a process snapshot establish and what can race with it?

### M11 — Memory Forensics Tool

1. Which memory data are accessible without added privilege?
2. How are process-map permissions and disappearing processes represented?
3. Why are strings and entropy observations not proof of malware?

### M12 — File Integrity Monitor

1. How are filenames, deletions and metadata represented in the baseline?
2. How does a changed file during hashing affect evidence?
3. Who can modify the baseline and what trust does it provide?

### M13 — Log Aggregator

1. How do inode replacement and copytruncate change tail offsets?
2. How are partial lines and multiple sources separated?
3. Show a rotated fixture with no silently lost complete records.

### M14 — Environment Config Manager

1. How is literal environment data separated from executable shell code?
2. How are secret values kept out of ordinary diff output?
3. How does a failed template expansion leave the destination intact?

### M15 — Parallel Execution Engine

1. How do you count owned running jobs and preserve their exit statuses?
2. Why must input placeholders be substituted in one pass?
3. How does retry validate metadata and avoid rerunning an already successful job?

### A01 — Mini Job Scheduler

1. Which lock protects shared-memory queue invariants?
2. How do you recover from a dead owner or full queue?
3. How are empty/oversized commands and worker termination tested?

### A02 — Interactive Shell Extension

1. What lifetime and byte bounds apply to readline completion candidates?
2. How does the lexer distinguish quotes, operators and command position?
3. What do UTF-8 trie tests demonstrate, and what remains unsupported?

### A03 — Distributed File Sync

1. How does the rolling checksum update differ from the strong block digest?
2. How are delta literals/copies bounded and verified before publication?
3. What failure leaves the old target intact, and how are concurrent updates handled?

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
| Cannot explain basic syntax | Record the specific knowledge gap; offer a comparable follow-up task |
| Inconsistent naming knowledge | Ask about source/provenance without presuming copying |
| Cannot modify code on request | Record task conditions, support provided and observed difficulty |
| Defensive or nervous demeanour | No authorship inference; clarify the task and allow an explanation |
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

The historical deduction proposal below is retained for author review. It is not an active automatic rule; first agree the evidence, accommodation, review and appeal process:

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
