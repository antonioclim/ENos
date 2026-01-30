# Pedagogical Analysis and Plan - Seminar 3
## Operating Systems | Bucharest UES - CSIE

> Document: Evaluation of existing materials and improvement plan  
> Version: 1.3 | Date: January 2025  
> Author: ing. dr. Antonio Clim

---

## Contents

1. [Evaluation of Current Materials](#1-evaluation-of-current-materials)
2. [Typical Misconceptions](#2-typical-misconceptions)
3. [Improvement Plan](#3-improvement-plan)
4. [Integration with BASH Magic Collection](#4-integration-with-bash-magic-collection)
5. [Implementation Checklist](#5-implementation-checklist)
6. [Lessons from Previous Iterations](#6-lessons-from-previous-iterations)

---

## 1. EVALUATION OF CURRENT MATERIALS

### 1.1 Existing Structure

Six files with theoretical material. Here's the honest assessment:

| File | Content | Lines | Verdict |
|------|---------|-------|---------|
| `TC2e_Utilitare_Unix.md` | find, xargs, locate | ~338 | Solid. Students actually read this one. |
| `TC3c_Parametri_Script.md` | $1-$9, shift, getopts | ~398 | Good examples, but getopts section needs work |
| `TC4b_Optiuni_Switches.md` | advanced getopts, long options | ~415 | Complete, though nobody uses long options in homework |
| `TC4g_Permisiuni_Fisiere.md` | chmod, chown, umask, special | ~410 | The ASCII diagrams are genuinely useful |
| `TC4h_CRON.md` | cron, at, automation | ~390 | Best practices section saves lives |
| `ANEXA_Referinte_Seminar3.md` | Diagrams, references | ~518 | Reference material, rarely opened |

Total: ~2469 lines. Probably too much for a 100-minute session, if I'm being honest.

### 1.2 Evaluation on the Brown & Wilson Framework

| Principle | Current State | The Problem | Fix Priority |
|-----------|---------------|-------------|--------------|
| Formative Assessment | Exercises at the end | Students zone out waiting | 🔴 Critical |
| Peer Instruction | Absent | Missed opportunity for discussion | 🔴 Critical |
| Live Coding | Static examples only | "Copy-paste syndrome" | 🔴 Critical |
| Parsons Problems | Absent | Students fear blank page | 🟡 Medium |
| Subgoal Labels | Partial | Objectives too vague | 🟡 Medium |
| Misconception Targeting | Weak | Same mistakes every year | 🔴 Critical |
| Scaffolded Practice | Moderate | No timed pressure | 🟡 Medium |
| LLM Integration | Absent → **Now Critical** | Can't ignore ChatGPT anymore | 🔴 Critical |

**January 2025 update:** After the autumn 2024 disaster—three students submitted nearly identical "original" scripts that were clearly ChatGPT output—I bumped LLM Integration to Critical. We can't ban it, so we teach them to use it properly.

### 1.3 Bloom Distribution Analysis

What we have now:

```
Create      ████░░░░░░░░░░░░ 15%  ← Not enough
Evaluate    ██░░░░░░░░░░░░░░  8%  ← Way too low
Analyse     ████░░░░░░░░░░░░ 17%
Apply       ████████████░░░░ 45%  ← Everyone stuck here
Understand  ████░░░░░░░░░░░░ 12%
Remember    ██░░░░░░░░░░░░░░  3%
```

The problem? We're training technicians, not thinkers. 45% Apply means students can follow recipes but can't debug when something breaks.

**Target for v1.3:**
```
Create      ██████░░░░░░░░░░ 20%  ↑ More "build from scratch"
Evaluate    █████░░░░░░░░░░░ 15%  ↑ LLM output evaluation
Analyse     █████░░░░░░░░░░░ 18%
Apply       ███████░░░░░░░░░ 30%  ↓ Less hand-holding
Understand  ████░░░░░░░░░░░░ 12%
Remember    ██░░░░░░░░░░░░░░  5%
```

### 1.4 What's Working

1. **Content coverage** — all topics are there, nothing missing
2. **Working examples** — every snippet actually runs (I test them before each semester)
3. **Cheat sheets** — students print these, I see them in exams
4. **ASCII diagrams** — permission matrix is referenced constantly
5. **Security focus** — nobody leaves thinking `chmod 777` is acceptable

### 1.5 What's Broken

1. **Wall of text** — too much reading, not enough doing
2. **No checkpoints** — students get lost and don't ask
3. **One-size-fits-all** — fast students bored, slow students panicked
4. **No self-check** — "Did I understand this?" has no answer
5. **Zero engagement** — the hook is... reading a table of contents
6. **AI vulnerability** — homework is trivially solvable by ChatGPT

---

## 2. TYPICAL MISCONCEPTIONS

I've been tracking these since 2019. The percentages come from exit quizzes and homework analysis.

### 2.1 Misconceptions about find and xargs

| ID | What They Believe | How Many | What Breaks | How We Fix It |
|----|-------------------|----------|-------------|---------------|
| M1.1 | "find only searches by name" | 40% | Never use -type, -size, -mtime | Multi-criteria demo |
| M1.2 | "xargs is just for rm" | 55% | Underuse in pipelines | Show cp, mv, grep examples |
| M1.3 | "-exec {} \; beats xargs" | 35% | 10,000 files = 10,000 processes | Benchmark: 47 min vs 8 sec |
| M1.4 | "locate = find" | 60% | "But I just created it!" | Touch file, run locate, fail |
| M1.5 | "find can't combine conditions" | 25% | Three commands instead of one | OR/AND/NOT exercise |
| M1.6 | "-print0 is optional" | 70% | "my important file.txt" explodes | **Deliberate failure demo** |
| M1.7 | "{} + same as {} \;" | 45% | Don't understand batching | Side-by-side comparison |

> **From the October 2024 lab:** A student confidently ran `find /home -name *.txt` in front of everyone. Worked perfectly on his laptop—he had exactly one .txt file. I asked him to try `/var/log`. Shell expansion chaos. Now I *always* start with the quoting demo. Three semesters of data say this reduces M1.6 by 20%. — A.C.

### 2.2 Misconceptions about Parameters and getopts

| ID | What They Believe | How Many | What Breaks | How We Fix It |
|----|-------------------|----------|-------------|---------------|
| M2.1 | "$@ and $* are identical" | 70% | Arguments with spaces | PI question with trap |
| M2.2 | "getopts parses --long-options" | 45% | Script silently ignores flags | Show the error live |
| M2.3 | "shift destroys arguments forever" | 35% | Fear of using it | Iterative demo |
| M2.4 | "$10 works without braces" | 80% | $10 = $1 followed by "0" | Parsons problem |
| M2.5 | "OPTIND doesn't matter" | 55% | Positional args unreachable | Before/after shift demo |
| M2.6 | "getopts goes first in script" | 30% | Don't understand the while loop | Step-by-step live coding |
| M2.7 | ": means optional argument" | 40% | Mandatory vs optional confusion | Dedicated MCQ |

### 2.3 Misconceptions about Permissions

| ID | What They Believe | How Many | What Breaks | How We Fix It |
|----|-------------------|----------|-------------|---------------|
| M3.1 | "chmod 777 fixes everything" | 65% → down from 80%! | Security nightmares | **Hack demo** |
| M3.2 | "x on directory = can run files inside" | 50% | Confused about traversal | ASCII diagram |
| M3.3 | "chown changes permissions" | 30% | Ownership ≠ permissions | Separate examples |
| M3.4 | "SUID works on bash scripts" | 40% | Security limitation ignored | Live test, watch it fail |
| M3.5 | "umask sets permissions" | 55% | umask *removes* bits | Interactive calculation |
| M3.6 | "r on directory = can read files" | 45% | r = ls, x = cd | Practical exercise |
| M3.7 | "sticky bit protects file contents" | 35% | Only protects deletion | /tmp demo |
| M3.8 | "SGID same on files and dirs" | 40% | Different behaviour | Comparison table |
| M3.9 | "root respects permissions" | 60% | Root ignores most | Demo as root |
| M3.10 | "recursive chmod is safe" | 50% | Scripts lose +x | Warning box |

**The chmod 777 hack demo works.** I show them a world-writable config file, write a reverse shell into it, wait 30 seconds for cron to pick it up. Their faces when the terminal pops up on my machine... M3.1 dropped from 80% to 65% after introducing this. Fear is a teacher.

### 2.4 Misconceptions about Cron

| ID | What They Believe | How Many | What Breaks | How We Fix It |
|----|-------------------|----------|-------------|---------------|
| M4.1 | "Cron inherits my environment" | 75% | Jobs fail silently | Minimal PATH demo |
| M4.2 | "*/5 means 5 min after script starts" | 30% | Timing confusion | Visual timeline |
| M4.3 | "crontab -r removes one job" | 45% | **Deletes everything** | Warning in red |
| M4.4 | "Cron emails me automatically" | 40% | MAILTO not configured | Full setup guide |
| M4.5 | "~ works in crontab" | 55% | HOME often unset | Absolute paths rule |
| M4.6 | "0 0 31 * * is monthly" | 35% | Runs only in long months | Debugging exercise |
| M4.7 | "crontab -e edits /etc/crontab" | 40% | User vs system confusion | Diagram |
| M4.8 | "Cron output appears somewhere" | 60% | Goes to /dev/null | Logging setup |

---

## 3. IMPROVEMENT PLAN

### 3.1 New Session Structure

```
SEMINAR 03 (100 minutes)
│
├── PART 1 (50 min) — UTILITIES AND SCRIPTS
│   ├── [0:00-0:05] Hook: "Find the 10 largest files on your system"
│   │               → Students run it, jaws drop at /usr/lib sizes
│   ├── [0:05-0:10] PI #1: find vs locate — vote, discuss, reveal
│   ├── [0:10-0:25] Live Coding: build find command step by step
│   │               → I type, they predict what happens
│   ├── [0:25-0:30] Parsons Problem: reassemble the find pipeline
│   ├── [0:30-0:45] Sprint #1: Find Master (15 min, timed)
│   └── [0:45-0:50] PI #2: $@ vs $* — the spaces trap
│
├── BREAK (10 min) — they need this, trust me
│
└── PART 2 (50 min) — PERMISSIONS AND AUTOMATION
    ├── [0:00-0:05] Reactivation quiz: "What's 755 in rwx?"
    ├── [0:05-0:20] Live Coding: permission scenarios
    ├── [0:20-0:25] PI #3: SUID — "Why doesn't this work on scripts?"
    ├── [0:25-0:40] Sprint #2: Professional script with getopts
    ├── [0:40-0:48] LLM Demo: "ChatGPT wrote this cron job. Find 3 bugs."
    └── [0:48-0:50] Reflection: "One thing you'll remember tomorrow"
```

### 3.2 SMART Objectives

**Module 1: find & xargs**
- **Specific:** Build find commands combining 3+ criteria
- **Measurable:** Sprint completion under 15 minutes
- **Achievable:** Syntax from Seminar 1 applies here
- **Relevant:** Daily sysadmin task
- **Time-bound:** 25 minutes allocated

**Module 2: Script Parameters**
- **Specific:** Write working getopts parser with -h, -v, -f FILE
- **Measurable:** ShellCheck clean, no warnings
- **Achievable:** Template provided, modify it
- **Relevant:** Every professional CLI does this
- **Time-bound:** 20 minutes

**Module 3: Permissions**
- **Specific:** Configure permissions for shared project directory
- **Measurable:** `ls -l` output matches specification
- **Achievable:** Step-by-step guidance
- **Relevant:** Security is not optional
- **Time-bound:** 20 minutes

**Module 4: Cron**
- **Specific:** Find 2+ bugs in AI-generated cron job
- **Measurable:** Checklist of common errors
- **Achievable:** Bugs are from the misconception list
- **Relevant:** AI literacy is mandatory now
- **Time-bound:** 10 minutes

### 3.3 Materials Status

| Material | Lines | Status | Notes |
|----------|-------|--------|-------|
| Instructor Guide | 1150+ | ✅ Done | Includes timing notes and room-specific setup |
| Main Material | 1230 | ✅ Done | Theory with subgoals |
| Peer Instruction | 709 | ✅ Done | 18 MCQs |
| Parsons Problems | 1003 | ✅ Done | 12 problems with distractors |
| Live Coding Guide | 1085 | ✅ Done | Every keystroke documented |
| Sprint Exercises | 922 | ✅ Done | 8 exercises, graded difficulty |
| LLM-Aware Exercises | 1066 | ✅ Done | 7 exercises + trap questions |
| Spectacular Demos | 702 | ✅ Done | 5 demos including the hack |
| Visual Cheat Sheet | 729 | ✅ Done | One-pager, printable |
| Self-Assessment | 795 | ✅ Done | Reflection prompts |
| Differentiation Tiers | 400+ | ✅ v1.3 | Foundation/Core/Extension |
| Quiz Runner | 450 | ✅ v1.2 | Interactive CLI |

---

## 4. INTEGRATION WITH BASH MAGIC COLLECTION

### 4.1 The Hook That Works

This one-liner gets them every time:

```bash
find /usr -type f -printf '%s %p\n' 2>/dev/null | \
    sort -rn | head -10 | \
    while read size path; do
        size_mb=$(echo "scale=2; $size/1048576" | bc)
        printf "📦 %8.2f MB  %s\n" "$size_mb" "$path"
    done
```

Students run it, see `/usr/lib/something` at 400MB, immediately want to know what else is eating their disk. That's when I have them.

### 4.2 Permission Visualiser

For the live demo, adapted from BASH_MAGIC_COLLECTION:

```bash
#!/bin/bash
# Show permissions in human-readable form
for f in "$@"; do
    perm=$(stat -c "%a %A" "$f" 2>/dev/null)
    printf "%-30s %s\n" "$f" "$perm"
done | column -t
```

### 4.3 Cron Monitor

Real-time view for the automation section:

```bash
watch -n 1 'echo "=== CRON STATUS ===" && \
    systemctl status cron --no-pager | head -5 && \
    echo && echo "=== PENDING JOBS ===" && \
    atq 2>/dev/null | head -5'
```

### 4.4 Sprint One-liners

These go into the exercises:
1. **Duplicate finder:** `find . -type f -exec md5sum {} + | sort | uniq -w32 -d`
2. **Recent changes:** `find . -mmin -5 -type f -printf '%T+ %p\n' | sort -r`
3. **Space hogs:** `du -sh */ | sort -rh | head`

---

## 5. IMPLEMENTATION CHECKLIST

### 5.1 Documentation Files

- [x] `README.md` — 530+ lines
- [x] `S03_00_PEDAGOGICAL_ANALYSIS_PLAN.md` — this file
- [x] `S03_01_INSTRUCTOR_GUIDE.md` — with checkpoints
- [x] `S03_02_MAIN_MATERIAL.md` — theory
- [x] `S03_03_PEER_INSTRUCTION.md` — 18 MCQs
- [x] `S03_04_PARSONS_PROBLEMS.md` — 12 problems
- [x] `S03_05_LIVE_CODING_GUIDE.md` — annotated
- [x] `S03_06_SPRINT_EXERCISES.md` — timed
- [x] `S03_07_LLM_AWARE_EXERCISES.md` — AI-resistant
- [x] `S03_08_SPECTACULAR_DEMOS.md` — 5 demos
- [x] `S03_09_VISUAL_CHEAT_SHEET.md` — printable
- [x] `S03_10_SELF_ASSESSMENT_REFLECTION.md` — metacognition
- [x] `S03_11_DIFFERENTIATION_TIERS.md` — NEW in v1.3

### 5.2 Scripts

**Bash:**
- [x] `S03_01_setup_seminar.sh`
- [x] `S03_02_interactive_quiz.sh`
- [x] `S03_03_validator.sh`

**Demos:**
- [x] `S03_01_hook_demo.sh`
- [x] `S03_02_demo_find_xargs.sh`
- [x] `S03_03_demo_getopts.sh`
- [x] `S03_04_demo_permissions.sh`
- [x] `S03_05_demo_cron.sh`

**Python:**
- [x] `S03_01_autograder.py` — with AI pattern detection (v1.3)
- [x] `S03_02_quiz_generator.py`
- [x] `S03_03_report_generator.py`
- [x] `quiz_runner.py`

### 5.3 Quality Gates

**Must pass before semester:**
- [x] All bash scripts run on Ubuntu 24.04
- [x] ShellCheck clean (with documented exceptions)
- [x] Python 3.10+ compatible
- [x] HTML renders in Chrome, Firefox, Safari
- [x] British English throughout
- [x] No vim references (nano/pico only)
- [x] No `chmod 777` suggestions anywhere
- [x] All `find -exec rm` has confirmation

---

## 6. LESSONS FROM PREVIOUS ITERATIONS

### 6.1 What Actually Works

| Element | Impact | Evidence |
|---------|--------|----------|
| Hook with largest files | 90% engagement in first 5 min | Head count: eyes on screen |
| Parsons problems | -40% time vs writing from scratch | Timed comparisons |
| chmod 777 hack demo | M3.1: 80% → 65% | Exit quiz data |
| LLM evaluation exercises | "Finally understood I was copying" | Anonymous feedback |

### 6.2 Changes Made

| Problem | Fix | Result |
|---------|-----|--------|
| Copy-paste homework | Timestamp + verification questions | Under evaluation |
| ACL exercises too hard | Moved to optional seminar | Happier students |
| cron vs at confusion | Separate diagrams | 15% improvement |
| Quiz ignored (JSON) | quiz_runner.py interactive | Actually used now |

### 6.3 Student Feedback (cohort 2024, anonymous)

> "Finally understood why permissions matter"

> "The LLM exercise made me realise I was not understanding, just copying"

> "Would have liked more time for sprints"
> — *Response: Increased from 10 to 15 minutes in v1.3*

> "The chmod 777 hack demo scared me but in a good way"

> "Lab 2031 projector has delay, hard to follow live coding"
> — *Response: Added to Instructor Guide room notes*

### 6.4 Known Issues

1. **WSL cron doesn't autostart** — Setup script runs `sudo service cron start`
2. **macOS find differs from GNU** — Explicit Ubuntu requirement in materials
3. **Terminals without colour** — Fallback mode in quiz_runner.py

---

*Seminar 3: System Administration | Operating Systems*  
*Bucharest University of Economic Studies — CSIE*  
*Maintained by ing. dr. Antonio Clim*  
*Version 1.3 — January 2025*
