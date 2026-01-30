# S05_04 — Oral Defence Protocol

> **Operating Systems** | ASE Bucharest — CSIE  
> **Seminar 5:** Advanced Bash Scripting  
> **Document:** Instructor guidelines for oral examination  
> **Version:** 1.0.0 | **Date:** January 2025

---

## Purpose and Rationale

The oral defence constitutes **20% of the total assignment grade** and serves as the primary mechanism for verifying authentic student work. In an era where AI tools can generate syntactically correct code, the ability to explain, modify and reason about one's own work becomes the definitive marker of genuine understanding.

> *From experience: I introduced mandatory oral defences in 2023 after noticing a peculiar pattern — submissions with perfect shellcheck scores from students who couldn't explain what `IFS` does. The correlation between "suspiciously perfect code" and "deer in headlights during viva" was nearly 1:1.*

---

## Structure Overview

| Phase | Duration | Focus | Weight |
|-------|----------|-------|--------|
| **Code Walkthrough** | 2-3 min | Ownership verification | 40% |
| **Live Modification** | 2-3 min | Practical competence | 40% |
| **Edge Case Discussion** | 1-2 min | Conceptual depth | 20% |

**Total duration:** 5-8 minutes per student

---

## Phase 1: Code Walkthrough (40%)

### Procedure

1. Open the student's submission on the projector (or screen share for remote)
2. Select a non-trivial function at random
3. Ask: *"Walk me through this function line by line"*

### What to Listen For

| Indicator | Authentic Work | Suspected AI/Copy |
|-----------|----------------|-------------------|
| **Variable naming** | Can explain choices ("I called it `level_count` because...") | Hesitates or gives generic answer |
| **Logic flow** | Describes thinking process | Reads code aloud without insight |
| **Error handling** | Explains why checks exist | Cannot justify defensive code |
| **Alternatives** | Mentions what they tried first | Only knows the submitted version |

### Sample Questions

```
"Why did you use an associative array here instead of a regular array?"
"What happens if the log file is empty?"
"I see you're using BASH_REMATCH — can you explain how the regex works?"
"Why is there a cleanup function? What would happen without it?"
```

### Red Flags

- Uses terminology inconsistent with their code comments
- Cannot explain regex patterns they wrote
- Says "I found this online" for core logic
- Perfect British English in code, broken English verbally (or vice versa)

---

## Phase 2: Live Modification (40%)

### Procedure

1. Present a specific modification request
2. Student must implement it **on their own machine** (not on paper)
3. Allow 2-3 minutes maximum
4. Partial solutions are acceptable — observe the *process*

### Modification Bank

Select ONE per student (rotate through the list):

#### Tier 1: Basic (Expected: 90% success)
```
"Add a --version flag that prints '1.0.0'"
"Add a check that the input file is not empty"
"Change the default TOP_N from 5 to 10"
```

#### Tier 2: Intermediate (Expected: 70% success)
```
"Add a --quiet flag that suppresses all output except errors"
"Make the script accept multiple input files"
"Add a timestamp to each log message your script produces"
```

#### Tier 3: Advanced (Expected: 40% success)
```
"Add trap for SIGINT that asks 'Are you sure?' before exiting"
"Change LEVEL_COUNT to use a regular array with enum-style indices"
"Add a --dry-run flag that shows what would happen without doing it"
```

### Evaluation Criteria

| Score | Behaviour |
|-------|-----------|
| **5/5** | Implements correctly within time, explains as they code |
| **4/5** | Correct implementation, minor hesitation |
| **3/5** | Partial implementation, understands the approach |
| **2/5** | Struggles but shows understanding of where to modify |
| **1/5** | Cannot begin, but asks relevant clarifying questions |
| **0/5** | No attempt, or attempts something completely wrong |

---

## Phase 3: Edge Case Discussion (20%)

### Procedure

Ask 2-3 "what if" questions without requiring implementation.

### Question Bank

```
"What happens if someone runs your script with no arguments?"
"What if there are spaces in the filename?"
"What if the config file has duplicate keys?"
"What if the log file is 10GB? Would your script handle it?"
"What happens if someone Ctrl+C's halfway through?"
"What if the user doesn't have read permission on the file?"
```

### Evaluation

| Score | Response Quality |
|-------|-----------------|
| **Full marks** | Identifies the problem AND suggests a solution |
| **Partial** | Identifies the problem, uncertain about solution |
| **Minimal** | Needs prompting to see the issue |
| **Zero** | Cannot engage with the scenario |

---

## Remote Examination Protocol

For online sessions (Teams/Zoom/Meet):

### Technical Setup
1. **Screen share mandatory** — student shares their terminal
2. **Webcam on** — shows face and ideally hands on keyboard
3. **Second device discouraged** — ask them to put phone face-down
4. **Record the session** (with consent) for grade disputes

### Adapted Procedure

| Adjustment | Rationale |
|------------|-----------|
| Extend time by 1-2 min | Account for lag/technical issues |
| Use breakout rooms | Other students shouldn't observe |
| Have backup questions ready | In case of "I can't hear you" stalling |
| Request `history` command at end | Shows recent terminal activity |

### Low-Tech Verification (When Proctoring Software Unavailable)

1. **Handwritten pseudocode photo** — before coding, ask student to photograph hand-drawn logic
2. **Language switching** — "Explain this in Romanian, then show me the English code"
3. **Terminal history check** — `cat ~/.bash_history | tail -50`
4. **Deliberate error injection** — "There's a bug on line 47" (there isn't) — authentic students will look and say "I don't see it"

---

## Scoring Matrix

### Holistic Rubric

| Grade | Code Walkthrough | Live Modification | Edge Cases | Overall Impression |
|-------|------------------|-------------------|------------|-------------------|
| **A (90-100%)** | Fluent, insightful | Independent success | Anticipates problems | Clearly owns the work |
| **B (75-89%)** | Competent | Succeeds with minor hints | Identifies issues | Genuine with gaps |
| **C (60-74%)** | Hesitant but correct | Partial implementation | Needs prompting | Understands basics |
| **D (50-59%)** | Struggles significantly | Cannot complete | Limited awareness | Concerning gaps |
| **F (<50%)** | Cannot explain own code | No meaningful attempt | No engagement | Suspected non-authentic |

### Score Calculation

```
Oral Defence Score = (Walkthrough × 0.4) + (Modification × 0.4) + (EdgeCases × 0.2)

Final Assignment Score = (Written Submission × 0.8) + (Oral Defence × 0.2)
```

---

## Handling Suspected AI-Generated Submissions

### During the Viva

**Do NOT accuse directly.** Instead:

1. Ask increasingly specific questions about implementation choices
2. Request a modification that requires understanding the existing logic
3. Note observations factually: "Student could not explain regex on line 34"

### After the Viva

1. Document specific instances of inability to explain
2. Compare verbal explanation quality with code comment quality
3. Check for anachronistic features (using constructs not taught yet)
4. Consult with colleagues if uncertain

### Evidence Threshold for Academic Integrity Referral

Refer to faculty committee if **THREE OR MORE** of the following:
- Cannot explain core algorithm
- Uses terminology inconsistent with their verbal vocabulary
- Code style dramatically different from in-class exercises
- Modification attempt shows unfamiliarity with own code structure
- Comments reference concepts not covered in course

---

## Scheduling and Logistics

### Time Allocation

| Class Size | Total Time Needed | Recommendation |
|------------|-------------------|----------------|
| 15 students | ~2 hours | Single session |
| 25 students | ~3.5 hours | Split across 2 sessions |
| 30+ students | ~4+ hours | Use TAs for parallel vivas |

### Preparation Checklist

- [ ] Randomise student order (avoid alphabetical — those at end learn from earlier)
- [ ] Prepare modification questions (3 per tier minimum)
- [ ] Test that student submissions actually run
- [ ] Have fallback questions for code that doesn't compile
- [ ] Set up recording if remote
- [ ] Brief TAs on evaluation criteria

---

## Appendix: Quick Reference Card

Print this for use during vivas:

```
┌─────────────────────────────────────────────────────────────────┐
│                    ORAL DEFENCE QUICK REFERENCE                 │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  PHASE 1 (2-3 min): "Walk me through [function]"                │
│    ✓ Explains variable names                                    │
│    ✓ Describes logic flow                                       │
│    ✓ Justifies error handling                                   │
│                                                                 │
│  PHASE 2 (2-3 min): "Add [feature] now"                         │
│    ✓ Knows where to modify                                      │
│    ✓ Correct syntax                                             │
│    ✓ Tests the change                                           │
│                                                                 │
│  PHASE 3 (1-2 min): "What if [edge case]?"                      │
│    ✓ Identifies the problem                                     │
│    ✓ Suggests mitigation                                        │
│                                                                 │
│  RED FLAGS:                                                     │
│    ✗ Reads code without understanding                           │
│    ✗ "I found this online"                                      │
│    ✗ Cannot make trivial changes                                │
│    ✗ Style mismatch: perfect code, broken explanations          │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## Document History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | Jan 2025 | Initial version based on 2023-2024 experience |

---

*Instructor: ing. dr. Antonio Clim | ASE Bucharest — CSIE*
