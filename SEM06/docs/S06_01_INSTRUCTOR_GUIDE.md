# Instructor Guide — CAPSTONE SEM06

> **Operating Systems** | ASE Bucharest - CSIE  
> Seminar 6: Integrated Projects (Monitor, Backup, Deployer)

---

> **Execution and evidence contract:** Bash 4.4+ on GNU/Linux. Run repository-relative commands from the repository root. Examples use disposable, explicitly owned paths. Expected failures must be captured in `if` statements when `set -e` is enabled. See [TEACHING_CONTRACT.md](TEACHING_CONTRACT.md) for evidence limits and author decisions.

## Session Overview

| Attribute | Value |
|-----------|-------|
| Duration | 100 minutes (2 academic hours) |
| Format | Lab session with demonstrations |
| Group size | 20-30 students |
| Prerequisites | SEM01-SEM05 completion |
| Equipment | Ubuntu 22.04 (WSL2 or VM), projector |

---

## Learning Outcomes for This Session

By the end of this seminar, students will be able to:

1. **LO6.1** Design modular architecture for Bash scripts
2. **LO6.2** Implement error handling with trap and exit codes
3. **LO6.3** Build logging systems with severity levels
4. **LO6.7** Apply deployment strategies (rolling, blue-green)
5. **LO6.8** Implement health checks with retry and backoff

---

## Session Timeline (100 minutes)

| Time | Duration | Activity | Materials | Notes |
|------|----------|----------|-----------|-------|
| 0:00 | 8 min | **Hook:** "The 3 AM server crash" | S06_08_SPECTACULAR_DEMOS.md | Use the explicitly hypothetical scenario |
| 0:08 | 12 min | **Peer Instruction:** PI-01, PI-02 | S06_03_PEER_INSTRUCTION.md | Use the current PI-01/PI-02 titles in the linked activity |
| 0:20 | 20 min | **Live Coding:** Monitor basics | S06_05_LIVE_CODING_GUIDE.md | Build incrementally |
| 0:40 | 10 min | **Sprint:** Trap cleanup (pairs) | S06_06_SPRINT_EXERCISES.md | Pair Programming Protocol |
| 0:50 | 5 min | *Break* | — | Students stretch |
| 0:55 | 15 min | **Demo:** Incremental backup | projects/backup/ | Show full base + ordered GNU tar increments |
| 1:10 | 12 min | **Parsons:** PP-01, PP-02 | S06_04_PARSONS_PROBLEMS.md | Identify distractors |
| 1:22 | 10 min | **Discussion:** Deployment strategies | projects/S06_P07_Deployment_Strategies.md | Rolling vs Blue-Green |
| 1:32 | 5 min | **Self-assessment** | S06_10_SELF_ASSESSMENT_REFLECTION.md | Quick checklist |
| 1:37 | 3 min | **Wrap-up + Homework** | homework/S06_01_HOMEWORK_CAPSTONE.md | Clear expectations |

---

## Opening Hook (8 minutes)

### Scenario: "The 3 AM Server Crash"

> "Imagine you're on call. Your phone buzzes at 3 AM — production server down. 
> No monitoring in place. No recent backups. Manual deployment took 4 hours last time.
> How do you prevent this happening again?"

**Discussion prompts:**
- What information would you need first? (Monitor)
- How would you recover data? (Backup)
- How would you deploy a fix safely? (Deployer)

**Transition:** "Today, we build tools to solve exactly these problems."

> **Historical author note, provenance not supplied:** the previous text recalled a corrupted database at 2 AM and a three-week-old backup. Preserve it as an attributed recollection pending confirmation; the opening scenario is hypothetical and establishes no measured teaching effect.

---

## Peer Instruction Facilitation

### Assignment warm-up (historical target: 35–45%; not measured here)

**Presentation (1 min):**
```bash
BACKUP_DIR = "/var/backups"
echo "Backup directory: $BACKUP_DIR"
```

**Sequence:**
1. Present code (1 min)
2. Individual vote (1 min) — show of hands or clickers
3. Pair discussion (3 min) — "convince your neighbour"
4. Revote (30 sec)
5. Explanation (2 min)

**Key teaching point:** Bash does NOT allow spaces around `=` in assignments. This is a possible transfer error from other languages; no prevalence is established here.

### Quoting warm-up (historical target: 50–60%; not measured here)

Focus on the difference between `"$VAR"` (expansion) and `'$VAR'` (literal).

> **Common pitfall:** Students who get this right in isolation forget it when writing longer scripts. Muscle memory takes time.

---

## Live Coding Session

### Principles to Follow

1. **Type everything live** — no copy-paste (students need to see mistakes happen)
2. **Make deliberate mistakes** — let students spot them
3. **Predict before execute** — "What do you think this outputs?"
4. **Verbalise your thinking** — "I'm adding quotes because..."

### Monitor Script Build (20 minutes)

**Step 1: Skeleton (3 min)**
```bash
#!/bin/bash
set -euo pipefail

echo "System Monitor v0.1"
```
*Verify:* Script runs, displays message.

**Step 2: CPU counter inspection (5 min)**
```bash
head -n 1 /proc/stat
```
The aggregate counters are cumulative. A single boot-to-now ratio is not a current utilisation sample. Sum user, nice, system, idle, iowait, irq, softirq and steal; guest counters are already included elsewhere. This teaching convention treats idle + iowait as non-busy time, while acknowledging that Linux iowait accounting has limitations.

**Step 3: Two samples in a reusable function (5 min)**
```bash
SEM06_DIR=$(realpath -- SEM06)
source "$SEM06_DIR/scripts/examples/monitor_examples.sh"
if usage=$(get_cpu_usage 0.2); then
    printf 'CPU over the sample interval: %s%%
' "$usage"
else
    printf 'CPU sample unavailable (read error, invalid counters or zero/reset delta)
' >&2
fi
```
Inspect `cpu_totals` and `get_cpu_usage` in that maintained source before running it. All values are local, invalid counters fail explicitly and the second read follows the requested interval. Predicted output is a range, not a fixed host percentage.

**Step 4: Add trap (5 min)**
```bash
cleanup() {
    echo "Cleaning up..."
}
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

# Rest of script...
```
*Demonstrate in a foreground terminal:* Ctrl+C exits with 130 and then invokes the EXIT handler. SIGKILL, abrupt host loss and a process that never reaches normal termination cannot run this cleanup. Background shells can inherit ignored SIGINT; use the explicit SIGTERM fixture in the sprint for automated verification.

---

## Sprint Exercise Facilitation

### Pair Programming Protocol

Before starting Sprint 1:

1. **Assign pairs** — neighbouring students
2. **Designate roles:**
   - Student on the left: Driver first
   - Student on the right: Navigator first
3. **Set timer:** 5 minutes, then switch
4. **Remind:** Navigator reviews, Driver types. No backseat driving.

### Sprint 1: Trap Cleanup

**Common student errors to watch for:**
- Forgetting to define function before trap
- Spaces in assignment: `TEMP_DIR = $(mktemp)`
- Missing quotes around `$TEMP_DIR`

**Verification command:**
```bash
# The completed sprint must print exactly one line: OWNED_DIR=/absolute/path.
# Store only this demonstration's stdout; do not glob unrelated /tmp paths.
check_dir=$(mktemp -d)
trap 'rm -rf -- "$check_dir"' EXIT
bash ./sprint1.sh > "$check_dir/output" &
child=$!
for ((attempt=0; attempt<100; attempt++)); do
    if [[ -s $check_dir/output ]]; then break; fi
    sleep 0.02
done
IFS= read -r record < "$check_dir/output"
[[ $record == OWNED_DIR=/* ]] || { kill -TERM "$child"; wait "$child" || :; exit 1; }
owned=${record#OWNED_DIR=}
[[ -d $owned ]] || exit 1
kill -TERM "$child"
if wait "$child"; then status=0; else status=$?; fi
[[ $status == 143 && ! -e $owned ]] || exit 1
printf 'Owned path removed; child status %s
' "$status"
```

---

## Common Student Difficulties

| Problem | Symptoms | Solution |
|---------|----------|----------|
| "trap doesn't work" | Cleanup never runs | Check: function defined before trap? |
| "Incremental archive is small" | Few changed entries | Restore the full parent chain; deletions are represented by GNU tar metadata |
| "Spaces in assignment" | `command not found` | Show explicit demo: `VAR=val` vs `VAR = val` |
| "Variable empty" | Blank output | Missing `$` or wrong quotes |
| "Permission denied" | Script won't run | `chmod +x script.sh` |
| "set -e stops early" | Script exits unexpectedly | Capture the status immediately in an `if`/`else`; a later `echo $?` can report an intervening command |

> **Quick win:** Keep a "hall of shame" slide with anonymised student errors. Seeing that others make the same mistakes reduces anxiety.

---

## Differentiated Instruction

### For Struggling Students

- Focus on **Monitor project only**
- Skip Deployer entirely
- Provide completed code snippets to modify
- Pair with stronger student
- Reduce Sprint scope to just trap handler

### For Advanced Students

- Challenge: Implement Blue-Green + Canary combo
- Add JSON output format to Monitor
- Implement exponential backoff in health check
- Write unit tests for utility functions
- Explore systemd timer integration

---

## Assessment Checkpoints

### Quick Checks During Session

| Time | Check | Method |
|------|-------|--------|
| 0:20 | Can explain trap syntax | Cold call 2-3 students |
| 0:40 | Sprint 1 completed | Visual check of screens |
| 1:10 | Understands find -newer | Thumbs up/down |
| 1:32 | Can compare Rolling vs Blue-Green | Discussion |

### Exit Ticket (Final 3 minutes)

Students write on paper:
1. One thing I learned today
2. One thing I'm still confused about
3. Rate confidence (1-5) on implementing trap handler

> **Lab note:** Read these before next session. The "confused" answers tell you what to revisit.

---

## Materials Checklist

Before session, verify:

- [ ] Ubuntu terminal accessible (WSL2 or VM)
- [ ] `shellcheck` available, or lint explicitly recorded as not run (installation is a separate environment action)
- [ ] Project files extracted to `/home/student/SEM06`
- [ ] `/proc/stat` readable; containers, sandboxes and permissions can make it unavailable
- [ ] Projector connected for live coding
- [ ] Timer visible for Peer Instruction

---

## Post-Session Notes

### What Worked Well

(Record after each session)

### What to Improve

(Record after each session)

### Student Questions to Address Next Time

(Capture questions you couldn't fully answer)

---

## Resources for Instructor

### Quick Reference

- GNU Bash Manual: https://www.gnu.org/software/bash/manual/
- ShellCheck wiki: https://www.shellcheck.net/wiki/
- Linux /proc documentation: `man 5 proc`

### Pedagogical References

- Brown & Wilson (2018). *Ten Quick Tips for Teaching Programming*
- Mazur, E. (1997). *Peer Instruction: A User's Manual*
- Parsons reference in the historical draft is incomplete. Confirm the intended work against the project reference register before adding authorship, year or DOI.

---

## Contact and Support

- **Office hours:** After seminar or by appointment
- **Questions:** Open an issue in the course repository
- **Forum:** Faculty e-learning platform

---

*Instructor Guide for SEM06 CAPSTONE — Operating Systems*  
*ASE Bucharest - CSIE | 2024-2025*
