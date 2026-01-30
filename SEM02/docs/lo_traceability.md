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

| LO | Peer Instruction | Parsons Problems | Live Coding | Sprint | LLM-Aware | Demo |
|----|------------------|------------------|-------------|--------|-----------|------|
| LO1 | PI-01, PI-03, PI-04 | PP-01, PP-02, PP-03, PP-13 | LC-01 | S-O1, S-O2 | - | D-01 |
| LO2 | PI-05, PI-06, PI-07 | PP-04, PP-05, PP-17 | LC-02 | S-R1, S-R2 | - | D-02 |
| LO3 | PI-02 | PP-06, PP-08 | LC-03 | S-P1, S-P2 | L1 | D-03 |
| LO4 | PI-08, PI-09, PI-10 | PP-07, PP-08 | LC-04 | S-F1, S-F2, S-F3 | - | D-04 |
| LO5 | PI-11, PI-12, PI-13, PI-14, PI-15 | PP-09, PP-10, PP-11, PP-12, PP-16 | LC-05 | S-B1, S-B2 | - | D-05 |
| LO6 | PI-02, PI-08 | PP-14, PP-17 | LC-06 | S-D1 | L2 | - |
| LO7 | PI-15 | PP-15 | - | S-C1 | L1, L3 | - |
| LO8 | - | - | - | - | L1, L2, L3, L4 | - |
| LO9 | - | PP-06, PP-08 | LC-07 | S-I1 | L5 | D-06 |
| LO10 | - | PP-12 | - | S-I2 | L3 | - |

---

## 3. TRACEABILITY MATRIX: LO → FILES

| LO | Main File | Supporting Files |
|----|-----------|------------------|
| LO1 | S02_02_MAIN_MATERIAL.md §1 | S02_03_PEER_INSTRUCTION.md, S02_04_PARSONS_PROBLEMS.md |
| LO2 | S02_02_MAIN_MATERIAL.md §2 | S02_05_LIVE_CODING_GUIDE.md |
| LO3 | S02_02_MAIN_MATERIAL.md §3 | S02_08_SPECTACULAR_DEMOS.md |
| LO4 | S02_02_MAIN_MATERIAL.md §4 | S02_06_SPRINT_EXERCISES.md |
| LO5 | S02_02_MAIN_MATERIAL.md §5 | S02_04_PARSONS_PROBLEMS.md |
| LO6 | S02_01_INSTRUCTOR_GUIDE.md | S02_10_SELF_ASSESSMENT_REFLECTION.md |
| LO7 | S02_07_LLM_AWARE_EXERCISES.md | S02_09_VISUAL_CHEAT_SHEET.md |
| LO8 | S02_07_LLM_AWARE_EXERCISES.md | - |
| LO9 | S02_06_SPRINT_EXERCISES.md | S02_08_SPECTACULAR_DEMOS.md |
| LO10 | homework/S02_01_HOMEWORK.md | homework/S02_03_EVALUATION_RUBRIC.md |

---

## 4. ASSESSMENT MATRIX: LO → ASSESSMENT

| LO | Formative Quiz | Assignment | Exam |
|----|----------------|------------|------|
| LO1 | q01, q02, q03, q05 | ex1_operators.sh | Yes |
| LO2 | q06, q07, q08, q09 | ex2_redirection.sh | Yes |
| LO3 | q04, q21 | ex2_redirection.sh | Yes |
| LO4 | q10, q11, q12, q13, q14, q15 | ex3_filters.sh | Yes |
| LO5 | q16, q17, q18, q19, q20 | ex4_loops.sh | Yes |
| LO6 | q04, q08 | ex5_integrated.sh | Yes |
| LO7 | q22, q25 | ex5_integrated.sh | Partial |
| LO8 | q26 | Bonus | No |
| LO9 | q21 | ex5_integrated.sh | Yes |
| LO10 | q23, q24 | ex5_integrated.sh | Partial |

---

## 5. BASH-SPECIFIC PARSONS PROBLEMS

These problems target frequent misconceptions in Bash scripting. Distractors exploit common syntax errors.

---

### PP-13: Variable Assignment Trap
**Level**: Intermediate | **LO**: LO1, LO6 | **Time**: 4 min

**Objective**: Assign values to variables and display them correctly.

```
╔══════════════════════════════════════════════════════════════════════════════╗
║  🎯 BEHAVIOUR:                                                               ║
║  - Set NAME to "Alice"                                                       ║
║  - Set AGE to 25                                                            ║
║  - Display: "Alice is 25 years old"                                         ║
╠══════════════════════════════════════════════════════════════════════════════╣
║  SHUFFLED LINES (2 are DISTRACTORS):                                         ║
║  ─────────────────────────────────────────────────────────────────────────   ║
║     NAME="Alice"                                                             ║
║     AGE=25                                                                   ║
║     echo "$NAME is $AGE years old"                                           ║
║     NAME = "Alice"                        ← DISTRACTOR: spaces around =      ║
║     echo '$NAME is $AGE years old'        ← DISTRACTOR: single quotes        ║
║  ─────────────────────────────────────────────────────────────────────────   ║
╚══════════════════════════════════════════════════════════════════════════════╝
```

**Correct solution**:
```bash
NAME="Alice"
AGE=25
echo "$NAME is $AGE years old"
```

**Distractor explanation**:

| Distractor | BASH-specific Problem |
|------------|----------------------|
| `NAME = "Alice"` | Spaces around `=` cause syntax error (interpreted as command with arguments) |
| `echo '$NAME...'` | Single quotes do NOT expand variables (prints literal `$NAME`) |

---

### PP-14: Test Brackets Trap
**Level**: Advanced | **LO**: LO1, LO6 | **Time**: 5 min

**Objective**: Check if file exists and is readable, then source it.

```
╔══════════════════════════════════════════════════════════════════════════════╗
║  🎯 BEHAVIOUR:                                                               ║
║  - If config.txt exists AND is readable → source it                         ║
║  - Otherwise → display error message                                        ║
╠══════════════════════════════════════════════════════════════════════════════╣
║  SHUFFLED LINES (2 are DISTRACTORS):                                         ║
║  ─────────────────────────────────────────────────────────────────────────   ║
║     if [[ -f "config.txt" && -r "config.txt" ]]; then                        ║
║         source config.txt                                                    ║
║     else                                                                     ║
║         echo "Error: config.txt not found or not readable"                   ║
║     fi                                                                       ║
║     if [[ -f "config.txt"&& -r "config.txt" ]]; then   ← DISTRACTOR         ║
║     if [ -f "config.txt" && -r "config.txt" ]; then    ← DISTRACTOR         ║
║  ─────────────────────────────────────────────────────────────────────────   ║
╚══════════════════════════════════════════════════════════════════════════════╝
```

**Correct solution**:
```bash
if [[ -f "config.txt" && -r "config.txt" ]]; then
    source config.txt
else
    echo "Error: config.txt not found or not readable"
fi
```

**Distractor explanation**:

| Distractor | BASH-specific Problem |
|------------|----------------------|
| `[[ -f "config.txt"&& ]]` | Missing space before `&&` causes syntax error |
| `[ ... && ... ]` | `&&` inside `[ ]` is syntax error; use `-a` or `[[ ]]` |

---

### PP-15: Command Substitution Trap
**Level**: Advanced | **LO**: LO1, LO7 | **Time**: 5 min

**Objective**: Store command output in variable and create filename.

```
╔══════════════════════════════════════════════════════════════════════════════╗
║  🎯 BEHAVIOUR:                                                               ║
║  - Get current date in format YYYY-MM-DD                                    ║
║  - Store in variable TODAY                                                  ║
║  - Create filename: backup_YYYY-MM-DD.tar                                   ║
╠══════════════════════════════════════════════════════════════════════════════╣
║  SHUFFLED LINES (2 are DISTRACTORS):                                         ║
║  ─────────────────────────────────────────────────────────────────────────   ║
║     TODAY=$(date +%Y-%m-%d)                                                  ║
║     FILENAME="backup_${TODAY}.tar"                                           ║
║     echo "Backup file: $FILENAME"                                            ║
║     TODAY=`date +%Y-%m-%d`                  ← DISTRACTOR (deprecated)        ║
║     TODAY = $(date +%Y-%m-%d)               ← DISTRACTOR (spaces!)           ║
║  ─────────────────────────────────────────────────────────────────────────   ║
╚══════════════════════════════════════════════════════════════════════════════╝
```

**Correct solution**:
```bash
TODAY=$(date +%Y-%m-%d)
FILENAME="backup_${TODAY}.tar"
echo "Backup file: $FILENAME"
```

**Distractor explanation**:

| Distractor | BASH-specific Problem |
|------------|----------------------|
| `` `date +%Y-%m-%d` `` | Backticks work but are deprecated; `$()` is preferred (nestable, clearer) |
| `TODAY = $(...)` | Spaces around `=` cause syntax error |

---

### PP-16: Read Variable Trap
**Level**: Advanced | **LO**: LO5, LO6 | **Time**: 5 min

**Objective**: Read file with custom delimiter into variables.

```
╔══════════════════════════════════════════════════════════════════════════════╗
║  🎯 BEHAVIOUR:                                                               ║
║  - File format: username:uid:shell                                          ║
║  - Read and display: "User: alice has UID 1001 and uses /bin/bash"         ║
╠══════════════════════════════════════════════════════════════════════════════╣
║  SHUFFLED LINES (2 are DISTRACTORS):                                         ║
║  ─────────────────────────────────────────────────────────────────────────   ║
║     while IFS=: read -r user uid shell; do                                   ║
║         echo "User: $user has UID $uid and uses $shell"                      ║
║     done < users.txt                                                         ║
║     while IFS=: read -r $user $uid $shell; do    ← DISTRACTOR               ║
║     while IFS=":" read user uid shell; do        ← DISTRACTOR (less common) ║
║  ─────────────────────────────────────────────────────────────────────────   ║
╚══════════════════════════════════════════════════════════════════════════════╝
```

**Correct solution**:
```bash
while IFS=: read -r user uid shell; do
    echo "User: $user has UID $uid and uses $shell"
done < users.txt
```

**Distractor explanation**:

| Distractor | BASH-specific Problem |
|------------|----------------------|
| `read -r $user $uid $shell` | Variables in `read` written WITHOUT `$` prefix |
| `IFS=":"` with quotes | Works but non-standard; `IFS=:` without quotes is preferred |

---

### PP-17: Stderr Redirection Order Trap
**Level**: Expert | **LO**: LO2, LO6 | **Time**: 6 min

**Objective**: Redirect BOTH stdout AND stderr to same file.

```
╔══════════════════════════════════════════════════════════════════════════════╗
║  🎯 BEHAVIOUR:                                                               ║
║  - Run command that produces both stdout and stderr                         ║
║  - Capture EVERYTHING in all_output.log                                     ║
╠══════════════════════════════════════════════════════════════════════════════╣
║  SHUFFLED LINES (2 are DISTRACTORS):                                         ║
║  ─────────────────────────────────────────────────────────────────────────   ║
║     ls /home /nonexistent > all_output.log 2>&1                              ║
║     echo "Logged to all_output.log"                                          ║
║     ls /home /nonexistent 2>&1 > all_output.log    ← DISTRACTOR             ║
║     ls /home /nonexistent > all_output.log 2>all_output.log ← DISTRACTOR    ║
║  ─────────────────────────────────────────────────────────────────────────   ║
╚══════════════════════════════════════════════════════════════════════════════╝
```

**Correct solution**:
```bash
ls /home /nonexistent > all_output.log 2>&1
echo "Logged to all_output.log"
```

**Correct alternative** (Bash-specific):
```bash
ls /home /nonexistent &> all_output.log
```

**Distractor explanation**:

| Distractor | BASH-specific Problem |
|------------|----------------------|
| `2>&1 > all_output.log` | WRONG ORDER! `2>&1` redirects stderr where stdout is NOW (terminal), then stdout goes to file |
| `> log 2>log` | Two separate redirections can cause race condition and corrupted output |

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
| D10 | `[ && ]` inside single brackets | Use `-a` or `[[ ]]` | 50% |
| D11 | `'$VAR'` vs `"$VAR"` | Single quotes don't expand | 55% |

---

## 7. COVERAGE VERIFICATION

### Checklist per LO

| LO | Peer Instr. | Parsons | Quiz | Assignment | Total Activities |
|----|-------------|---------|------|------------|------------------|
| LO1 | ✓ (3) | ✓ (4) | ✓ (4) | ✓ | 12 |
| LO2 | ✓ (3) | ✓ (3) | ✓ (4) | ✓ | 11 |
| LO3 | ✓ (1) | ✓ (2) | ✓ (2) | ✓ | 6 |
| LO4 | ✓ (3) | ✓ (2) | ✓ (6) | ✓ | 12 |
| LO5 | ✓ (5) | ✓ (5) | ✓ (5) | ✓ | 16 |
| LO6 | ✓ (2) | ✓ (2) | ✓ (2) | ✓ | 7 |
| LO7 | ✓ (1) | ✓ (1) | ✓ (2) | ✓ | 5 |
| LO8 | - | - | ✓ (1) | Bonus | 2 |
| LO9 | - | ✓ (2) | ✓ (1) | ✓ | 4 |
| LO10 | - | ✓ (1) | ✓ (2) | ✓ | 4 |

**Conclusion**: All LOs have adequate coverage through multiple activity types.

---

*Material for Seminar 02 OS | ASE Bucharest - CSIE*  
*Based on Backward Design principles (Wiggins & McTighe)*
