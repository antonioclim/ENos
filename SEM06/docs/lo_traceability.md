# Learning Outcomes Traceability — CAPSTONE SEM06

> **Operating Systems** | ASE Bucharest - CSIE  
> Seminar 6: Integrated Projects (Monitor, Backup, Deployer)

---

## About This Document

The traceability matrix connects:
- **Learning Outcomes (LO)** — what the student must know/do
- **Materials** — where each LO is taught
- **Assessment** — how we verify LO achievement
- **Bloom Level** — targeted cognitive level

> **Lab note:** If you can't trace an LO to at least one quiz question and one practical exercise, that LO is probably under-assessed. Fix it before the seminar.

---

## SEM06 Learning Outcomes

| ID | Learning Outcome | Bloom | Verifiable |
|----|------------------|-------|------------|
| **LO6.1** | Designs modular architecture for Bash scripts | Create | Yes |
| **LO6.2** | Implements error handling with trap and exit codes | Apply | Yes |
| **LO6.3** | Builds logging system with levels | Apply | Yes |
| **LO6.4** | Reads and interprets data from /proc | Understand | Yes |
| **LO6.5** | Implements incremental backup with find -newer | Apply | Yes |
| **LO6.6** | Verifies data integrity with checksums | Apply | Yes |
| **LO6.7** | Applies deployment strategies (rolling, blue-green) | Apply | Yes |
| **LO6.8** | Implements health checks with retry and backoff | Apply | Yes |
| **LO6.9** | Writes unit tests for Bash functions | Create | Yes |
| **LO6.10** | Automates tasks with cron/systemd timers | Apply | Yes |
| **LO6.11** | Debugs scripts using set -x and strace | Analyse | Yes |
| **LO6.12** | Evaluates trade-offs in design decisions | Evaluate | Partial |

---

## Traceability Matrix

### LO → Materials

| LO | docs/ | scripts/ | quiz | peer | parsons |
|----|-------|----------|------|------|---------|
| LO6.1 | S06_P01 | projects/*/lib/ | q04 | PI-04 | PP-04 |
| LO6.2 | S06_P06 | */lib/core.sh | q01, q09 | PI-05 | PP-01 |
| LO6.3 | S06_P06 | */lib/core.sh | q07 | PI-08 | PP-05 |
| LO6.4 | S06_P02 | monitor/lib/utils.sh | q04 | PI-01 | — |
| LO6.5 | S06_P03 | backup/lib/core.sh | q05, q10 | PI-07 | PP-02 |
| LO6.6 | S06_P03 | backup/lib/utils.sh | q14 | — | — |
| LO6.7 | S06_P07 | deployer/lib/core.sh | q08, q17 | PI-10 | — |
| LO6.8 | S06_P04 | deployer/lib/utils.sh | q06, q12 | PI-09 | PP-03 |
| LO6.9 | S06_P05 | */tests/*.sh | — | — | — |
| LO6.10 | S06_P08 | resources/systemd/ | — | — | — |
| LO6.11 | S06_P05 | test_helpers.sh | q15 | PI-06 | — |
| LO6.12 | S06_P07 | — | q17, q18 | — | — |

### LO → Exercises

| LO | Sprint | LLM-Aware | Assignment |
|----|--------|-----------|------------|
| LO6.1 | — | Ex5 | A1, A2, A3 |
| LO6.2 | S1 | Ex4 | A1, A2, A3 |
| LO6.3 | S3 | Ex5 | A1 |
| LO6.4 | — | Ex1, Ex3 | A1 |
| LO6.5 | S6 | — | A2 |
| LO6.6 | — | — | A2 |
| LO6.7 | — | — | A3 |
| LO6.8 | S7 | — | A3 |
| LO6.9 | — | — | A4 |
| LO6.10 | — | — | A2, A3 |
| LO6.11 | — | Ex2, Ex4 | A4 |
| LO6.12 | — | Ex6 | A4 |

---

## Bloom Distribution

### Per Material

| Material | R | U | Ap | An | Ev | Cr |
|----------|---|---|----|----|----|----|
| docs/ | 10% | 30% | 35% | 15% | 5% | 5% |
| Quiz | 25% | 25% | 30% | 10% | 10% | 0% |
| Peer Instruction | 10% | 40% | 30% | 20% | 0% | 0% |
| Parsons | 0% | 20% | 60% | 20% | 0% | 0% |
| Sprint | 0% | 10% | 80% | 10% | 0% | 0% |
| LLM-Aware | 0% | 20% | 30% | 30% | 10% | 10% |
| Assignments | 0% | 10% | 40% | 20% | 15% | 15% |

### Summary (against beginner targets)

| Level | Target | Actual | Status |
|-------|--------|--------|--------|
| Remember | 15-20% | 18% | ✓ OK |
| Understand | 25-30% | 25% | ✓ OK |
| Apply | 30-35% | 35% | ✓ OK |
| Analyse | 10-15% | 12% | ✓ OK |
| Evaluate | 3-5% | 8% | ⚠️ Slightly above (acceptable for CAPSTONE) |
| Create | 3-5% | 2% | ✓ OK |

**Note:** CAPSTONE balances higher-order thinking with foundational recall. The slightly elevated Evaluate percentage reflects the integrative nature of capstone projects—students must justify design decisions.

---

## File Reference Map (Updated)

### Standard Pedagogical Files (docs/)

| File | Content |
|------|---------|
| S06_00_PEDAGOGICAL_ANALYSIS_PLAN.md | Audience, LO alignment, session structure |
| S06_01_INSTRUCTOR_GUIDE.md | Timeline, facilitation notes, checkpoints |
| S06_02_MAIN_MATERIAL.md | Index to project documentation |
| S06_03_PEER_INSTRUCTION.md | 10 PI questions with instructor notes |
| S06_04_PARSONS_PROBLEMS.md | 6 code arrangement exercises |
| S06_05_LIVE_CODING_GUIDE.md | Worked examples for demonstrations |
| S06_06_SPRINT_EXERCISES.md | Timed pair programming exercises |
| S06_07_LLM_AWARE_EXERCISES.md | AI-interaction exercises |
| S06_08_SPECTACULAR_DEMOS.md | Hook scenarios and demos |
| S06_09_VISUAL_CHEAT_SHEET.md | Quick reference one-pager |
| S06_10_SELF_ASSESSMENT_REFLECTION.md | Metacognitive checklists |

### Project-Specific Files (docs/projects/)

| File | Content |
|------|---------|
| S06_P00_Introduction_CAPSTONE.md | Context, motivation, overview |
| S06_P01_Project_Architecture.md | Shared patterns, directory structure |
| S06_P02_Monitor_Implementation.md | Monitor project guide |
| S06_P03_Backup_Implementation.md | Backup project guide |
| S06_P04_Deployer_Implementation.md | Deployer project guide |
| S06_P05_Testing_Framework.md | Testing patterns for Bash |
| S06_P06_Error_Handling.md | Trap, logging, exit codes |
| S06_P07_Deployment_Strategies.md | Rolling, blue-green, canary |
| S06_P08_Cron_Automation.md | Scheduling and timers |

---

## LO Achievement Verification

### Verification Methods

| LO | Pre-test | In seminar | Post-test | Assignment |
|----|----------|------------|-----------|------------|
| LO6.1 | — | Live coding | Quiz q04 | A1-A3 |
| LO6.2 | Quiz q01 | Demo | Quiz q09 | A1-A3 |
| LO6.3 | — | Sprint S3 | — | A1 |
| LO6.4 | — | LLM Ex1 | — | A1 |
| LO6.5 | Quiz q05 | Demo backup | Quiz q10 | A2 |
| LO6.6 | — | — | Quiz q14 | A2 |
| LO6.7 | Quiz q08 | Demo deploy | Quiz q17 | A3 |
| LO6.8 | — | Sprint S7 | Quiz q12 | A3 |
| LO6.9 | — | — | — | A4 |
| LO6.10 | — | — | — | A2, A3 |
| LO6.11 | — | LLM Ex2 | Quiz q15 | A4 |
| LO6.12 | — | Discussion | Quiz q18 | A4 |

---

## Parsons Distractors — Bash-Specific

### PP-01: Trap Handler
**Tested distractors:**
- `TEMP_FILE = $(mktemp)` — spaces in assignment ❌
- `trap cleanup() EXIT` — wrong parentheses ❌
- `trap 'cleanup' ON_EXIT` — invalid signal ❌

### PP-02: Incremental Backup
**Tested distractors:**
- `find $SOURCE -newer ...` — missing quotes ❌
- `find --newer` — invalid flag ❌
- `tar czf $BACKUP < find` — invalid syntax ❌

### PP-03: Health Check
**Tested distractors:**
- `while [ $retry < $MAX ]` — invalid comparison in `[ ]` ❌
- `retry = $((retry+1))` — spaces in assignment ❌
- `curl -sf $URL` — missing quotes ❌

### PP-04: Source Libraries
**Tested distractors:**
- `SCRIPT_DIR=$(dirname $0)` — doesn't resolve symlinks ❌
- `source $LIB_DIR/core.sh` — missing quotes ❌

### PP-05: Logging
**Tested distractors:**
- `local level = "$1"` — spaces in assignment ❌
- `echo [$timestamp] [$level]` — brackets expand ❌

### PP-06: Array Iteration
**Tested distractors:**
- `for s in $SERVERS` — takes only first element ❌
- `for s in ${SERVERS[@]}` — spaces break ❌
- `SERVERS = (...)` — spaces in array assignment ❌

---

## Quiz → LO Mapping

| Question | Primary LO | Secondary LO | Bloom |
|----------|------------|--------------|-------|
| q01 | LO6.2 | — | Remember |
| q02 | LO6.2 | — | Remember |
| q03 | LO6.2 | — | Remember |
| q04 | LO6.1 | — | Understand |
| q05 | LO6.5 | — | Understand |
| q06 | LO6.8 | — | Understand |
| q07 | LO6.3 | — | Understand |
| q08 | LO6.7 | — | Understand |
| q09 | LO6.2 | — | Apply |
| q10 | LO6.5 | — | Apply |
| q11 | LO6.1 | — | Apply |
| q12 | LO6.8 | — | Apply |
| q13 | LO6.1 | — | Apply |
| q14 | LO6.6 | — | Apply |
| q15 | LO6.11 | LO6.2 | Analyse |
| q16 | LO6.2 | — | Analyse |
| q17 | LO6.7 | LO6.12 | Evaluate |
| q18 | LO6.5 | LO6.12 | Evaluate |
| q19 | LO6.2 | — | Remember |
| q20 | LO6.5 | LO6.6 | Remember |

---

## Gaps and Recommendations

### LOs with Adequate Coverage

All primary Learning Outcomes now have adequate quiz coverage. The addition of q19 (signals) and q20 (compression) balances the Bloom distribution.

| LO | Status | Notes |
|----|--------|-------|
| LO6.9 | ⚠️ | Covered in assignment A4, no direct quiz |
| LO6.10 | ⚠️ | Covered in docs and cron examples |
| LO6.12 | ✓ | Covered via q17, q18 (Evaluate level) |

### Completed Improvements

1. ✅ **Added 2 Remember questions** (q19, q20) to balance Bloom distribution
2. ✅ **Balanced Bloom taxonomy** — Remember now at 18% (was 6%)
3. ✅ **Signal and compression coverage** — foundational concepts reinforced
4. ⏳ **Cron sprint** — recommended for future iteration
5. ⏳ **Explicit testing exercise** — covered via assignment A4

---

## References

- Anderson, L.W. & Krathwohl, D.R. (2001). *A Taxonomy for Learning, Teaching, and Assessing*
- Biggs, J. & Tang, C. (2011). *Teaching for Quality Learning at University*
- Brown & Wilson (2018). *Ten Quick Tips for Teaching Programming*

---

*Learning Outcomes Traceability for SEM06 CAPSTONE — Operating Systems*  
*ASE Bucharest - CSIE | 2024-2025*
