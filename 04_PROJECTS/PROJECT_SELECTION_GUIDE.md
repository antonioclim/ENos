# 🧭 Project Selection Guide

> **Current status:** Numerical assessment, bonus and penalty rules below are historical proposals awaiting author reconciliation. Timings, anecdotes and experiential claims are retained with unverified provenance. See [ASSESSMENT_AND_EVIDENCE_CONTRACT.md](ASSESSMENT_AND_EVIDENCE_CONTRACT.md) for the concrete choices, consequences and recommended resolution. No grade or publication policy is adopted by these examples.

> **Purpose:** Help you choose the right project for your skills and available time  
> **Author:** ing. dr. Antonio Clim  
> **Historical attribution:** “5 years of grading these projects”; supporting provenance not supplied

---

## Quick Decision Flowchart

```
                              START HERE
                                  │
                                  ▼
                    ┌───────────────────────────┐
                    │ How many hours can you    │
                    │ realistically dedicate?   │
                    └───────────────────────────┘
                                  │
              ┌───────────────────┼───────────────────┐
              │                   │                   │
           <20 hours          20-35 hours          >35 hours
              │                   │                   │
              ▼                   ▼                   ▼
        ┌──────────┐        ┌──────────┐        ┌──────────┐
        │  EASY    │        │  See     │        │  See     │
        │  ONLY    │        │  below   │        │  below   │
        │ E01-E05  │        │    ↓     │        │    ↓     │
        └──────────┘        └──────────┘        └──────────┘
                                  │                   │
                                  ▼                   ▼
                    ┌───────────────────────────┐    │
                    │ Have you written >500     │    │
                    │ lines of Bash before?     │    │
                    └───────────────────────────┘    │
                                  │                   │
                           ┌──────┴──────┐           │
                           │             │           │
                          YES            NO          │
                           │             │           │
                           ▼             ▼           │
                      ┌─────────┐   ┌─────────┐     │
                      │ MEDIUM  │   │  EASY   │     │
                      │ M01-M15 │   │ E01-E05 │     │
                      └─────────┘   └─────────┘     │
                                                    │
                                                    ▼
                                  ┌───────────────────────────┐
                                  │ Do you have C experience? │
                                  │ (malloc, pointers, etc.)  │
                                  └───────────────────────────┘
                                                    │
                                             ┌──────┴──────┐
                                             │             │
                                            YES            NO
                                             │             │
                                             ▼             ▼
                                        ┌─────────┐   ┌─────────┐
                                        │ADVANCED │   │ MEDIUM  │
                                        │ A01-A03 │   │ M01-M15 │
                                        └─────────┘   └─────────┘
```

---

## Detailed Selection Matrix

### By Your Situation

| Your Situation | Recommended Projects | Why |
|----------------|---------------------|-----|
| First time with Linux/Bash | E01, E03 | Focus on basic commands (`find`, `mv`) |
| Know Python, learning Bash | E02, E04 | Familiar patterns, text processing |
| Comfortable with scripting | M01, M03, M12 | Practical, real-world tools |
| Interested in security | M04, M07 | Industry-relevant skills |
| Interested in DevOps | M05, M09 | Deployment and automation |
| Systems programming enthusiast | A01, A02 | Deep OS concepts, C integration |
| Limited time (<20h available) | E01-E05 only | Be realistic about scope |
| Want maximum challenge | A01; K8s as a learning extension pending bonus eligibility | Full experience, impressive CV |

### By Interest Area

| Interest | EASY | MEDIUM | ADVANCED |
|----------|------|--------|----------|
| **File systems** | E01, E03 | M08, M12 | — |
| **Processes** | — | M02, M10 | A01 |
| **Networking** | — | M04, M13 | A03 |
| **Security** | — | M07 | — |
| **Automation** | E05 | M05, M09, M15 | — |
| **Monitoring** | E04 | M03, M06, M11 | — |
| **User interfaces** | — | M14 | A02 |

---

## 🏆 My Personal Recommendations

The original author described these opinions as based on hundreds of submissions. That dataset is not supplied; retain the opinions as guidance, not verified comparative outcomes.

### Best "Bang for Buck"
**M01 (Incremental Backup System)**

Why: Clear requirements, practical output, you will actually use it. Most students who choose this finish on time and learn a lot about `tar`, `find` and scheduling.

### Most Interesting to Implement
**M02 (Process Lifecycle Monitor)**

Why: You will spend hours exploring `/proc` and understanding how Linux actually tracks processes. Students who choose this often say "I finally understand what `ps` actually does."

### Easiest to Test and Debug
**E01 (File System Auditor)**

Why: Deterministic outputs. You create test directories, run your script, check the output. Owned static fixtures avoid network dependencies; concurrent filesystem changes and permissions still require explicit handling.

### Hardest to Debug (Fair Warning)
**A03 (Distributed File Sync)**

Why: Network issues are notoriously hard to reproduce. "It works on my machine" is guaranteed. Only choose this if you enjoy pain. (I say this with love — it is also the most impressive on a CV.)

### Hidden Gem
**M14 (Environment Config Manager)**

Why: Underrated project. You learn about dotfiles, templating and configuration management — skills every developer needs but few courses teach.

---

## ⚠️ Red Flags — When to Reconsider

### Do NOT Choose ADVANCED If...

- ❌ You have not compiled C code in the last 6 months
- ❌ You do not know what `malloc()` and `free()` do
- ❌ You have less than 40 hours to dedicate
- ❌ You are uncomfortable with segmentation faults

> **True story:** In 2023, a student chose A01 because "it looked cool." They spent 30 hours just understanding shared memory before writing any actual scheduler logic. They finished, but barely slept for two weeks.

### Do NOT Choose MEDIUM with K8s Bonus If...

- ❌ You have never used Docker
- ❌ You have never written a YAML file
- ❌ You have less than 35 hours available

The K8s bonus is +10%, but the learning curve can add 10+ hours.

### Do NOT Choose Based On...

- ❌ "It sounds impressive" — impress with quality, not complexity
- ❌ "My friend chose it" — your friend has different skills
- ❌ "I want to learn X" — learning during the project is fine, but not from zero

---

## ✅ Green Flags — Good Reasons to Choose

- ✅ "I actually need this tool" — motivation is everything
- ✅ "I have done something similar before" — builds on existing knowledge
- ✅ "The requirements are clear to me" — you understand what success looks like
- ✅ "I have buffer time if things go wrong" — realistic planning

---

## Project Difficulty Calibration

Here is how I would rank the projects by actual difficulty (not official levels):

### Easier Than They Look
- E01 File System Auditor (very straightforward)
- E03 Bulk File Organiser (mostly `find` and `mv`)
- M09 Scheduled Tasks Manager (cron is well-documented)

### Harder Than They Look
- M02 Process Lifecycle Monitor (parsing `/proc` is tricky)
- M04 Network Security Scanner (networking edge cases)
- A02 Interactive Shell Extension (terminal handling is arcane)

### Exactly As Difficult As Expected
- M01 Incremental Backup (solid medium challenge)
- M12 File Integrity Monitor (clear scope)
- A01 Mini Job Scheduler (challenging but well-defined)

---

## Final Advice

1. **Read the full specification** before deciding — not just the title
2. **Check the "Implementation Hints"** section — does it make sense to you?
3. **Look at the "Evaluation Criteria"** — can you satisfy at least 70%?
4. **Ask yourself:** "If I get stuck, can I Google my way out?" (For ADVANCED: often no)

When in doubt, choose one level below what you think you can handle. A well-executed EASY project scores better than a rushed MEDIUM project.

---

*Good luck choosing! And remember — the best project is the one you finish.*

*— Antonio*
