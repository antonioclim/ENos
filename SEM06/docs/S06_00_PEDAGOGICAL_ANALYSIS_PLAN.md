# Pedagogical Analysis and Plan — CAPSTONE SEM06

> **Operating Systems** | ASE Bucharest - CSIE  
> Seminar 6: Integrated Projects (Monitor, Backup, Deployer)

---

## Document Purpose

This document maps the pedagogical strategy for the CAPSTONE seminar. Unlike previous weeks where students tackled isolated concepts, SEM06 throws everything together—and that's precisely the point.

> **Lab note:** Students consistently underestimate integration complexity. A script that works in isolation often breaks when combined with others. Budget time for "glue code" debugging.

---

## 1. Audience Analysis

### 1.1 Prerequisites

Students arriving at CAPSTONE should have:

| Skill | Source | Verification |
|-------|--------|--------------|
| Bash fundamentals (variables, loops, conditionals) | SEM01-02 | Quiz q01-03 |
| File operations and permissions | SEM02-03 | Quiz q04 |
| Process management basics | SEM03-04 | Quiz q05 |
| Text processing (grep, sed, awk) | SEM04 | Sprint exercises |
| Basic scripting patterns | SEM05 | Homework completion |

### 1.2 Common Gaps

From previous cohorts, watch for:

- **Quoting discipline** — Still the #1 source of bugs. Students know the rules but forget under pressure.
- **Exit code awareness** — Many students still ignore `$?` and wonder why their scripts "randomly fail."
- **Path handling** — Hardcoded paths work on their machine, break everywhere else.

> **Quick win:** Start the session with a 2-minute "spot the bug" exercise using unquoted variables. Gets their attention.

---

## 2. Learning Objectives Alignment

### 2.1 Bloom Taxonomy Distribution

CAPSTONE deliberately shifts towards higher-order thinking:

```
Remember    ████░░░░░░░░░░░░░░░░  18%  (foundation recall)
Understand  █████░░░░░░░░░░░░░░░  25%  (concept explanation)
Apply       ███████░░░░░░░░░░░░░  35%  (implementation)
Analyse     ██░░░░░░░░░░░░░░░░░░  12%  (debugging, trade-offs)
Evaluate    ██░░░░░░░░░░░░░░░░░░   8%  (design decisions)
Create      █░░░░░░░░░░░░░░░░░░░   2%  (novel solutions)
```

This matches capstone expectations: students *apply* what they learned while beginning to *analyse* and *evaluate* design choices.

### 2.2 Learning Outcomes

| ID | Outcome | Cognitive Level | Verifiable |
|----|---------|-----------------|------------|
| LO6.1 | Designs modular architecture for Bash scripts | Create | Yes |
| LO6.2 | Implements error handling with trap and exit codes | Apply | Yes |
| LO6.3 | Builds logging system with severity levels | Apply | Yes |
| LO6.4 | Reads and interprets data from /proc | Understand | Yes |
| LO6.5 | Implements incremental backup with find -newer | Apply | Yes |
| LO6.6 | Verifies data integrity with checksums | Apply | Yes |
| LO6.7 | Applies deployment strategies (rolling, blue-green) | Apply | Yes |
| LO6.8 | Implements health checks with retry and backoff | Apply | Yes |
| LO6.9 | Writes unit tests for Bash functions | Create | Yes |
| LO6.10 | Automates tasks with cron/systemd timers | Apply | Yes |
| LO6.11 | Debugs scripts using set -x and strace | Analyse | Yes |
| LO6.12 | Evaluates trade-offs in design decisions | Evaluate | Partial |

---

## 3. Session Structure

### 3.1 Time Allocation (100 minutes)

| Phase | Duration | Activity | Purpose |
|-------|----------|----------|---------|
| Hook | 8 min | "3 AM Server Crash" scenario | Engagement, relevance |
| Peer Instruction | 12 min | PI-01, PI-02 (variables, quotes) | Misconception surfacing |
| Live Coding | 20 min | Monitor skeleton build | Worked example |
| Sprint | 10 min | Trap cleanup (pairs) | Active practice |
| Break | 5 min | — | Cognitive reset |
| Demo | 15 min | Incremental backup | Concept demonstration |
| Parsons | 12 min | PP-01, PP-02 | Code ordering practice |
| Discussion | 10 min | Deployment strategies | Higher-order thinking |
| Self-assessment | 5 min | Checklist + exit ticket | Metacognition |
| Wrap-up | 3 min | Homework briefing | Closure |

### 3.2 Pacing Notes

- **First half:** Higher energy, more structure. Students are fresh.
- **After break:** Switch to discussion and problem-solving. Attention spans flag.
- **Final 15 minutes:** Don't introduce new concepts. Consolidate.

> **War story:** I once tried to explain blue-green deployment in the last 5 minutes. Half the class left confused. Now it's firmly in the "before break" slot.

---

## 4. Active Learning Strategies

### 4.1 Peer Instruction Protocol

1. Present code snippet (1 min)
2. Individual vote — no discussion (1 min)
3. Pair discussion — "convince your neighbour" (3 min)
4. Re-vote (30 sec)
5. Instructor explanation (2 min)

Target: 35-70% correct on first vote. Below 35%? Concept needs re-teaching. Above 70%? Move faster.

### 4.2 Sprint Exercise Protocol

- Pairs, not individuals (reduces frustration)
- Strict time limit (5-7 min)
- Visible timer
- "Good enough" beats "perfect"
- Debrief the common mistakes publicly

### 4.3 Parsons Problems

Why they work for Bash:
- Bash syntax is unforgiving. Wrong order = instant failure.
- Distractors expose common mistakes (spaces in assignment, missing quotes).
- Lower cognitive load than blank-slate coding.

---

## 5. Assessment Strategy

### 5.1 Formative (During Session)

| Checkpoint | Time | Method | LO Targeted |
|------------|------|--------|-------------|
| Variable assignment | 0:15 | Cold call | LO6.2 |
| Trap syntax | 0:35 | Thumbs up/down | LO6.2 |
| find -newer usage | 1:05 | Quick poll | LO6.5 |
| Strategy comparison | 1:25 | Discussion | LO6.7, LO6.12 |

### 5.2 Summative (Homework + Presentation)

- **Homework weight:** 60% of seminar grade
- **Presentation weight:** 40% of seminar grade
- **Rubric location:** `homework/S06_02_EVALUATION_RUBRIC.md`

---

## 6. Differentiation

### 6.1 Struggling Students

- Focus on Monitor project only
- Provide skeleton code to modify
- Pair with stronger student
- Reduce sprint scope

### 6.2 Advanced Students

- Challenge: Combine blue-green + canary
- Add JSON output to Monitor
- Implement exponential backoff
- Write property-based tests

---

## 7. Materials Checklist

Before session:

- [ ] Ubuntu terminal accessible (WSL2 or VM)
- [ ] `shellcheck` installed
- [ ] Project files extracted to `/home/student/SEM06`
- [ ] `/proc/stat` readable (should always be)
- [ ] Projector for live coding
- [ ] Timer visible for Peer Instruction

---

## 8. Post-Session Reflection Template

### What Worked

(Fill after each session delivery)

### What to Improve

(Fill after each session delivery)

### Student Questions to Address Next Time

(Capture questions you couldn't fully answer)

---

## References

- Anderson, L.W. & Krathwohl, D.R. (2001). *A Taxonomy for Learning, Teaching, and Assessing*
- Mazur, E. (1997). *Peer Instruction: A User's Manual*
- Brown & Wilson (2018). *Ten Quick Tips for Teaching Programming*
- Parsons, D. & Haden, P. (2006). *Parson's Programming Puzzles*

---

*Pedagogical Analysis for SEM06 CAPSTONE — Operating Systems*  
*ASE Bucharest - CSIE | 2024-2025*
