# Instructor Guide — CAPSTONE SEM06

> **Operating Systems** | ASE Bucharest - CSIE  
> Seminar 6: Integrated Projects (Monitor, Backup, Deployer)

---

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
| 0:00 | 8 min | **Hook:** "The 3 AM server crash" | S06_08_SPECTACULAR_DEMOS.md | Capture attention with real scenario |
| 0:08 | 12 min | **Peer Instruction:** PI-01, PI-02 | S06_03_PEER_INSTRUCTION.md | Variable assignment and quotes |
| 0:20 | 20 min | **Live Coding:** Monitor basics | S06_05_LIVE_CODING_GUIDE.md | Build incrementally |
| 0:40 | 10 min | **Sprint:** Trap cleanup (pairs) | S06_06_SPRINT_EXERCISES.md | Pair Programming Protocol |
| 0:50 | 5 min | *Break* | — | Students stretch |
| 0:55 | 15 min | **Demo:** Incremental backup | projects/backup/ | Show find -newer |
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

> **Lab note:** This hook lands better if you have a real story. Mine involves a corrupted database at 2 AM and a backup that was 3 weeks old. Students remember *stories*, not abstractions.

---

## Peer Instruction Facilitation

### PI-01: Variable Assignment (Target: 35-45% correct on first vote)

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

**Key teaching point:** Bash does NOT allow spaces around `=` in assignments. This trips up everyone coming from Python or JavaScript.

### PI-02: Quotes (Target: 50-60% correct)

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

**Step 2: CPU reading (5 min)**
```bash
# Read from /proc/stat
read -r cpu user nice system idle rest < /proc/stat
total=$((user + nice + system + idle))
usage=$((100 * (total - idle) / total))
echo "CPU: ${usage}%"
```
*Ask:* "What percentage do you expect?" (Most guess wrong on first try.)

**Step 3: Add function (5 min)**
```bash
get_cpu_usage() {
    read -r cpu user nice system idle rest < /proc/stat
    local total=$((user + nice + system + idle))
    echo $((100 * (total - idle) / total))
}

echo "CPU: $(get_cpu_usage)%"
```
*Teaching point:* Functions with local variables. The `local` keyword matters.

**Step 4: Add trap (5 min)**
```bash
cleanup() {
    echo "Cleaning up..."
}
trap cleanup EXIT

# Rest of script...
```
*Demonstrate:* Press Ctrl+C — cleanup still runs. This is the "aha" moment for most students.

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
./sprint1.sh &
PID=$!
sleep 2
kill -INT $PID
sleep 1
ls /tmp/sprint_* 2>/dev/null || echo "Cleanup worked"
```

---

## Common Student Difficulties

| Problem | Symptoms | Solution |
|---------|----------|----------|
| "trap doesn't work" | Cleanup never runs | Check: function defined before trap? |
| "find -newer finds nothing" | Empty output | Does timestamp file exist? Run `touch` first |
| "Spaces in assignment" | `command not found` | Show explicit demo: `VAR=val` vs `VAR = val` |
| "Variable empty" | Blank output | Missing `$` or wrong quotes |
| "Permission denied" | Script won't run | `chmod +x script.sh` |
| "set -e stops early" | Script exits unexpectedly | Check which command failed with `echo $?` |

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
- [ ] `shellcheck` installed (`sudo apt install shellcheck`)
- [ ] Project files extracted to `/home/student/SEM06`
- [ ] `/proc/stat` readable (should always be)
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
- Parsons, D. (2006). *Parson's Programming Puzzles*

---

## Contact and Support

- **Office hours:** After seminar or by appointment
- **Questions:** Open an issue in the course repository
- **Forum:** Faculty e-learning platform

---

*Instructor Guide for SEM06 CAPSTONE — Operating Systems*  
*ASE Bucharest - CSIE | 2024-2025*
