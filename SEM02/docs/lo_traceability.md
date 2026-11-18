# Learning Outcomes Traceability Matrix - Seminar 02
## Operating Systems | Operators, Redirection, Filters, Loops

**Document**: lo_traceability.md  
**Version**: 1.1 | **Date**: January 2025  
**Purpose**: Mapping Learning Outcomes → Activities → Assessment

---

## 1. LEARNING OUTCOMES (LO)

### APPLY Level (Anderson-Bloom)

| ID | Learning Outcome | Bloom Verb |
|----|------------------|------------|
| LO1 | Combine commands using control operators (`;`, `&&`, `\|\|`, `&`) | Apply |
| LO2 | Redirect input and output using `>`, `>>`, `<`, `<<`, `<<<` | Apply |
| LO3 | Construct pipelines with `\|` and `tee` | Apply |
| LO4 | Use filters: `sort`, `uniq`, `cut`, `paste`, `tr`, `wc`, `head`, `tail` | Apply |
| LO5 | Write `for`, `while`, `until` loops with flow control (`break`, `continue`) | Apply |

### ANALYSE Level (Anderson-Bloom)

| ID | Learning Outcome | Bloom Verb |
|----|------------------|------------|
| LO6 | Diagnose errors using exit codes and PIPESTATUS | Analyse |
| LO7 | Compare efficiency of different approaches for the same problem | Analyse |
| LO8 | Evaluate LLM-generated code for correctness and best practices | Analyse |

### CREATE Level (Anderson-Bloom)

| ID | Learning Outcome | Bloom Verb |
|----|------------------|------------|
| LO9 | Design pipelines for data processing | Create |
| LO10 | Automate administrative tasks with scripts | Create |

---

## 2. TRACEABILITY MATRIX: LO → ACTIVITIES

Identifiers below refer to headings in the canonical banks. `Session 1–4` are the four actual live-coding sessions; sprint IDs are O1–I2 and demo IDs are H1–I1. These are **supporting activities**, not proof that every part of an outcome has been attained. Ordered-code puzzles support later design, but do not alone establish Create-level performance.

| LO | Peer Instruction | Parsons Problems | Live Coding | Sprint | LLM-Aware | Demo |
|----|------------------|------------------|-------------|--------|-----------|------|
| LO1 | PI-01, PI-03, PI-04 | PP-01, PP-02, PP-03 | Session 1 | O1, O2, O3 | L4 | C1, C2 |
| LO2 | PI-05, PI-06, PI-07 | PP-04, PP-05, PP-17 | Session 2 | R1, R2 | L2 | R1 |
| LO3 | PI-02 | PP-06, PP-08 | Session 3 | R1, F2, F3 | L1 | H1, F2 |
| LO4 | PI-08, PI-09, PI-10 | PP-07, PP-08 | Session 3 | F1, F2, F3 | L1, L5 | F1, F2 |
| LO5 | PI-11, PI-12, PI-13, PI-14, PI-15 | PP-09, PP-10, PP-11, PP-12, PP-16 | Session 4 | B1, B2, B3 | L2, L4, L6 | B1, B2 |
| LO6 | PI-02, PI-07, PI-12 | PP-14, PP-17 | Sessions 1–2; Session 4 step 5 | O3, R1 | L2, L4 | C1, R1, B2 |
| LO7 | — | — | Session 3 step 1 (process-count comparison only) | F2, F3 (compare alternatives) | L1, L5 | — |
| LO8 | — | — | — | — | L1–L6 | — |
| LO9 | — | PP-06, PP-08 (scaffolding) | Session 3 (scaffolding) | F2, F3, I1 | L1, L5 | F2 (scaffolding) |
| LO10 | — | PP-12 (scaffolding) | Session 4 (scaffolding) | O3, I1, I2 | L2, L4 | I1 |

---

## 3. TRACEABILITY MATRIX: LO → FILES

| LO | Main File | Supporting Files |
|----|-----------|------------------|
| LO1 | S02_02_MAIN_MATERIAL.md §1 | S02_03_PEER_INSTRUCTION.md, S02_04_PARSONS_PROBLEMS.md |
| LO2 | S02_02_MAIN_MATERIAL.md §2 | S02_05_LIVE_CODING_GUIDE.md |
| LO3 | S02_02_MAIN_MATERIAL.md §3 | S02_08_SPECTACULAR_DEMOS.md |
| LO4 | S02_02_MAIN_MATERIAL.md §3 | S02_06_SPRINT_EXERCISES.md |
| LO5 | S02_02_MAIN_MATERIAL.md §4 | S02_04_PARSONS_PROBLEMS.md |
| LO6 | S02_01_INSTRUCTOR_GUIDE.md | S02_10_SELF_ASSESSMENT_REFLECTION.md |
| LO7 | S02_07_LLM_AWARE_EXERCISES.md | S02_09_VISUAL_CHEAT_SHEET.md |
| LO8 | S02_07_LLM_AWARE_EXERCISES.md | - |
| LO9 | S02_06_SPRINT_EXERCISES.md | S02_08_SPECTACULAR_DEMOS.md |
| LO10 | homework/S02_01_HOMEWORK.md | homework/S02_03_EVALUATION_RUBRIC.md |

---

## 4. ASSESSMENT MATRIX: LO → ASSESSMENT

The homework has incompatible historical public/internal rubrics. See [ASSESSMENT_STATUS.md](../homework/ASSESSMENT_STATUS.md); mappings below identify relevant **public task parts**, without adopting weights or promising exam coverage.

| LO | Canonical quiz evidence | Public homework activity | Limit |
|----|-------------------------|--------------------------|-------|
| LO1 | q01, q02, q03, q05 | Part 1 operators | Selected operator knowledge only |
| LO2 | q06, q07, q08, q09 | Part 2 redirection | Here-document application also needs a practical check |
| LO3 | q04, q12, q21 | Part 3 filters | MCQs interpret pipelines; they do not demonstrate design |
| LO4 | q10–q15, q21 | Part 3 filters | Not every filter variant appears in the quiz |
| LO5 | q16–q20 | Part 4 loops | Practical until/menu behaviour needs direct checking |
| LO6 | q04, q08, q17, q24 | Parts 1, 2 and 6 explanation | PIPESTATUS capture requires an oral/practical check |
| LO7 | q22 (equivalence), q25 (tradeoffs) | Bonus A optimiser | No benchmark or universal speed ranking is demonstrated |
| LO8 | q26 | REFLECTION.md and L1–L6 review records | q26 tests one defect, not complete code-review competence |
| LO9 | q21 is interpretation scaffolding | Part 3 and Part 5 system_report.sh | Creation is assessed through the submitted design, not this MCQ |
| LO10 | q23, q24 are prerequisites | Part 5 and optional I2 | Automation needs a practical error-path demonstration |

---

## 5. BASH-SPECIFIC PARSONS PROBLEMS

These problems target frequent misconceptions in Bash scripting. Distractors exploit common syntax errors.

---

> The following activities reproduce PP-13–PP-17 from the canonical Parsons bank. Accepted alternatives are syntax/behaviour decisions, not style-based penalties.

### PP-13: Variable Assignment Trap
Level: ⭐⭐ Medium | Time: 4 min | Mode: Individual

```
╔══════════════════════════════════════════════════════════════════════╗
║  🎯 OBJECTIVE: Assign values to variables and display them           ║
║                                                                      ║
║  BEHAVIOUR:                                                          ║
║  - Set NAME to "Alice"                                              ║
║  - Set AGE to 25                                                    ║
║  - Display: "NAME is AGE years old"                                  ║
╠══════════════════════════════════════════════════════════════════════╣
║                                                                      ║
║  SHUFFLED LINES (two are DISTRACTORS):                              ║
║  ────────────────────────────────────────────────────────────────   ║
║     NAME="Alice"                                                    ║
║     AGE=25                                                          ║
║     echo "$NAME is $AGE years old"                                  ║
║     NAME = "Alice"                        ← DISTRACTOR (spaces!)    ║
║     echo '$NAME is $AGE years old'        ← DISTRACTOR (quotes!)    ║
║  ────────────────────────────────────────────────────────────────   ║
║                                                                      ║
╚══════════════════════════════════════════════════════════════════════╝
```

✅ CORRECT SOLUTION:
```bash
NAME="Alice"
AGE=25
echo "$NAME is $AGE years old"
```

Distractor explanations:
- `NAME = "Alice"` parses as a command named `NAME` with arguments; it does not assign the variable and ordinarily fails with command not found
- `echo '$NAME is $AGE years old'` - single quotes do NOT expand variables (prints literal `$NAME`)

---

### PP-14: Test Brackets Trap

Choose either of the two valid `[[ ... ]]` headers and all body lines; there is one invalid `[ ... ]` header. `config.txt` must be a trusted, owned shell fragment because `source` executes its contents.
Level: ⭐⭐⭐ Advanced | Time: 5 min | Mode: Pairs

```
╔══════════════════════════════════════════════════════════════════════╗
║  🎯 OBJECTIVE: Check if file exists and is readable                 ║
║                                                                      ║
║  BEHAVIOUR:                                                          ║
║  - If config.txt exists AND is readable → source it                 ║
║  - Otherwise → display error message                                ║
╠══════════════════════════════════════════════════════════════════════╣
║                                                                      ║
║  SHUFFLED LINES (one valid alternative, one distractor):                              ║
║  ────────────────────────────────────────────────────────────────   ║
║     if [[ -f "config.txt" && -r "config.txt" ]]; then               ║
║         source config.txt                                           ║
║     else                                                            ║
║         echo "Error: config.txt not found or not readable"          ║
║     fi                                                              ║
║     if [[ -f "config.txt"&& -r "config.txt" ]]; then  ← VALID ALTERNATIVE  ║
║     if [ -f "config.txt" && -r "config.txt" ]; then   ← DISTRACTOR  ║
║  ────────────────────────────────────────────────────────────────   ║
║                                                                      ║
╚══════════════════════════════════════════════════════════════════════╝
```

✅ CORRECT SOLUTION:
```bash
if [[ -f "config.txt" && -r "config.txt" ]]; then
    source config.txt
else
    echo "Error: config.txt not found or not readable"
fi
```

Distractor explanations:
- `[[ -f "config.txt"&& -r "config.txt" ]]` is valid Bash: `&&` is an operator token even without the preceding space. Prefer spaced formatting for readability; accept either offered header.
- `[ -f "config.txt" && -r "config.txt" ]` - the shell splits this into two commands; the first `[` lacks a closing `]`. Use `[[ -f config.txt && -r config.txt ]]` or `[ -f config.txt ] && [ -r config.txt ]`

---

### PP-15: Command Substitution Trap

Choose either valid date-assignment spelling; there is one invalid assignment alternative.
Level: ⭐⭐⭐ Advanced | Time: 5 min | Mode: Individual

```
╔══════════════════════════════════════════════════════════════════════╗
║  🎯 OBJECTIVE: Store command output in variable                     ║
║                                                                      ║
║  BEHAVIOUR:                                                          ║
║  - Get current date in format YYYY-MM-DD                            ║
║  - Store in variable TODAY                                          ║
║  - Create backup filename: backup_YYYY-MM-DD.tar                    ║
║  - Display the filename                                              ║
╠══════════════════════════════════════════════════════════════════════╣
║                                                                      ║
║  SHUFFLED LINES (one valid alternative, one distractor):                              ║
║  ────────────────────────────────────────────────────────────────   ║
║     TODAY=$(date +%Y-%m-%d)                                         ║
║     FILENAME="backup_${TODAY}.tar"                                  ║
║     echo "Backup file: $FILENAME"                                   ║
║     TODAY=`date +%Y-%m-%d`                 ← VALID ALTERNATIVE (older syntax) ║
║     TODAY = $(date +%Y-%m-%d)              ← DISTRACTOR (spaces!)   ║
║  ────────────────────────────────────────────────────────────────   ║
║                                                                      ║
╚══════════════════════════════════════════════════════════════════════╝
```

✅ CORRECT SOLUTION:
```bash
TODAY=$(date +%Y-%m-%d)
FILENAME="backup_${TODAY}.tar"
echo "Backup file: $FILENAME"
```

Distractor explanations:
- `` TODAY=`date +%Y-%m-%d` `` - backticks remain supported older syntax; `$()` is preferred for clearer nesting. Either offered assignment is valid here
- `TODAY = $(date +%Y-%m-%d)` invokes a command named TODAY instead of assigning a variable

---

### PP-16: Read Variable Trap

Choose either valid delimiter-assignment header. The header using expanded values as `read` variable names is the distractor.
Level: ⭐⭐⭐ Advanced | Time: 5 min | Mode: Pairs

```
╔══════════════════════════════════════════════════════════════════════╗
║  🎯 OBJECTIVE: Read file into variables with custom delimiter       ║
║                                                                      ║
║  FILE FORMAT (passwd style): username:uid:shell                     ║
║  Example line: alice:1001:/bin/bash                                 ║
║                                                                      ║
║  BEHAVIOUR: Display "User: alice has UID 1001 and uses /bin/bash"  ║
╠══════════════════════════════════════════════════════════════════════╣
║                                                                      ║
║  SHUFFLED LINES (one valid alternative, one distractor):                              ║
║  ────────────────────────────────────────────────────────────────   ║
║     while IFS=: read -r user uid shell; do                          ║
║         echo "User: $user has UID $uid and uses $shell"             ║
║     done < users.txt                                                ║
║     while IFS=: read -r $user $uid $shell; do   ← DISTRACTOR        ║
║     while IFS=":" read -r user uid shell; do    ← VALID ALTERNATIVE        ║
║  ────────────────────────────────────────────────────────────────   ║
║                                                                      ║
╚══════════════════════════════════════════════════════════════════════╝
```

✅ CORRECT SOLUTION:
```bash
while IFS=: read -r user uid shell; do
    echo "User: $user has UID $uid and uses $shell"
done < users.txt
```

Distractor explanations:
- `read -r $user $uid $shell` - variables in `read` are written WITHOUT `$` prefix
- `IFS=":"` and `IFS=:` assign exactly the same delimiter. Both offered `read -r` headers are valid. Omitting `-r` changes backslash handling, not the meaning of quoted `IFS`. This fixture has three colon-separated, newline-terminated fields without embedded colons.

---

### PP-17: Stderr Redirection Order Trap
Level: ⭐⭐⭐⭐ Expert | Time: 6 min | Mode: Individual

```
╔══════════════════════════════════════════════════════════════════════╗
║  🎯 OBJECTIVE: Redirect BOTH stdout AND stderr to same file         ║
║                                                                      ║
║  BEHAVIOUR:                                                          ║
║  - Run command that produces both stdout and stderr                 ║
║  - Capture EVERYTHING in all_output.log                             ║
║  - Display "Logged to all_output.log"                               ║
╠══════════════════════════════════════════════════════════════════════╣
║                                                                      ║
║  SHUFFLED LINES (two are DISTRACTORS):                              ║
║  ────────────────────────────────────────────────────────────────   ║
║     ls /home /nonexistent > all_output.log 2>&1                     ║
║     echo "Logged to all_output.log"                                 ║
║     ls /home /nonexistent 2>&1 > all_output.log   ← DISTRACTOR      ║
║     ls /home /nonexistent > all_output.log 2>all_output.log ← DISTRACTOR ║
║  ────────────────────────────────────────────────────────────────   ║
║                                                                      ║
╚══════════════════════════════════════════════════════════════════════╝
```

✅ CORRECT SOLUTION:
```bash
ls /home /nonexistent > all_output.log 2>&1
echo "Logged to all_output.log"
```

Distractor explanations:
- `2>&1 > all_output.log` - WRONG ORDER! `2>&1` redirects stderr to where stdout is NOW (terminal), then stdout goes to file. Stderr stays on terminal!
- `> all_output.log 2>all_output.log` - two separate redirections can cause race condition and interleaved/corrupted output

---

## 6. SUMMARY OF BASH-SPECIFIC DISTRACTORS

| ID | Distractor Pattern | Bash Error | Student Frequency |
|----|-------------------|------------|-------------------|
| D1 | `VAR = value` | Spaces around `=` in assignment | 85% |
| D2 | `[[ -f file]]` | Missing space before `]]` | 60% |
| D3 | `{1..$N}` | Brace expansion with variables | 70% |
| D4 | `$()` vs backticks | Nesting and clarity differences | 40% |
| D5 | `uniq` without `sort` | Only removes consecutive duplicates | 80% |
| D6 | `cut -f` without `-d` | TAB implicit vs space | 65% |
| D7 | `read $var` | `$` prefix in read variable name | 45% |
| D8 | `2>&1 >` vs `> 2>&1` | Redirection order matters | 55% |
| D9 | `pipe \| while` | Subshell variable problem | 65% |
| D10 | `[ && ]` inside single brackets | Use separate tests joined by `&&`, or `[[ ]]` | 50% |
| D11 | `'$VAR'` vs `"$VAR"` | Single quotes don't expand | 55% |

---

## 7. COVERAGE VERIFICATION

### Coverage interpretation

Every LO has at least one relevant activity in the matrix. This is a source mapping, not a validated learning-gain result. LO7 lacks an empirical performance comparison; LO9 and LO10 require practical work beyond the quiz; LO6 needs an explicit PIPESTATUS exercise. The author can add those practical checks or narrow the claimed outcomes. Do not infer institutional attainment, exam eligibility or grading weights from a count of references.

Historical frequency percentages in the misconception table are retained without a supplied cohort, denominator or protocol. They are author annotations pending provenance, not measured rates validated by this revision.

---

*Material for Seminar 02 OS | ASE Bucharest - CSIE*  
*Based on Backward Design principles (Wiggins & McTighe)*
