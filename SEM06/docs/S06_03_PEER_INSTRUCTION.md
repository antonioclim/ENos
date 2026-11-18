# Peer Instruction — CAPSTONE SEM06

> **Operating Systems** | ASE Bucharest - CSIE  
> Seminar 6: Integrated Projects (Monitor, Backup, Deployer)

---

## Peer Instruction Protocol

### Standard Voting Procedure

For each question in this document, follow this protocol:

1. **Display question** (30 seconds for reading)
2. **Individual vote** — Students vote A/B/C/D silently (no discussion)
3. **Record distribution** — Note percentages on board: A:__% B:__% C:__% D:__%
4. **Decision point:**
   - If **>70% correct**: Brief explanation, move on
   - If **30-70% correct**: Peer discussion (2-3 min), then re-vote
   - If **<30% correct**: Mini-lecture needed before re-vote
5. **Reveal answer** with explanation (2 min)

### Local Teaching Targets

The percentages and classroom anecdotes in this document are retained instructional estimates with unresolved empirical provenance. They are not measured outcomes or guaranteed improvements; author confirmation or a fully identified study is required for empirical claims.

- **Target first-vote accuracy:** 40-60% (local design target, not an established universal optimum)
- **Discussion groups:** 2-3 students with different initial answers
- **Re-vote improvement:** The inherited 20–30% increase is an unverified planning estimate; record actual results separately

### Question Notation

Each question includes:
- **Bloom level:** Cognitive level being assessed
- **Misconception target:** Which common error this question tests
- **Distractor analysis:** Why wrong answers are tempting

---

## About Peer Instruction

Eric Mazur developed this method to get students *talking* about concepts, not just absorbing them. The magic happens in step 3—when students have to convince each other, they discover their own gaps.

**The cycle:**

1. **Presentation** (1 min) — Show the code
2. **Individual vote** (1 min) — No discussion, commit to an answer
3. **Pair discussion** (3 min) — Argue your position
4. **Re-vote** (30 sec) — Changed your mind?
5. **Explanation** (2 min) — Reveal and clarify

Target: 40-60% correct on first vote. Below that? You're teaching too fast. Above that? Move on.

> **Lab note:** The pair discussion is non-negotiable. Skipping it defeats the whole purpose. Even shy students engage when it's just their neighbour.

---

## PI-01: Spaces in Assignment

### Scenario

A student writes this script:

```bash
#!/bin/bash
BACKUP_DIR = "/var/backups"
echo "Backup directory: $BACKUP_DIR"
```

### Question

Assume a fresh non-interactive Bash, `set +eu`, no command named `BACKUP_DIR` and an unset `BACKUP_DIR`. Which option describes both output streams and continuation?

| Option | Answer |
|--------|--------|
| **A** | Displays "Backup directory: /var/backups" |
| **B** | A command-not-found diagnostic on stderr, then `Backup directory: ` on stdout; the final echo succeeds |
| **C** | Only `Backup directory: ` on stdout, with no diagnostic |
| **D** | Syntax error at line 2 |

---

### Instructor Notes

**Correct answer: B**

**First vote target:** 35-45% correct

This one catches *everyone* coming from Python or JavaScript. Bash reads `BACKUP_DIR` as a command name, then `=` and `"/var/backups"` as arguments. No spaces around `=` in assignments. Ever.

**Why students pick wrong answers:**
- **A** — They assume Bash is forgiving (it isn't)
- **C** — The empty stdout line does occur, but the diagnostic is also emitted; this option omits it
- **D** — Close, but it's a runtime error, not a parse-time syntax error

**Demo fix:** `BACKUP_DIR="/var/backups"` — no spaces.

---

## PI-02: Quotes and Expansion

### Scenario

What's the difference between these two commands?

```bash
# Command 1
echo "Current user: $USER"

# Command 2
echo 'Current user: $USER'
```

### Question

What does each command display for user "student"?

| Option | Answer |
|--------|--------|
| **A** | Both display "Current user: student" |
| **B** | First: "...student", second: "...$USER" (literal) |
| **C** | First: "...$USER" (literal), second: "...student" |
| **D** | Both display "Current user: $USER" |

---

### Instructor Notes

**Correct answer: B**

**First vote target:** 50-60% correct

Double quotes expand variables. Single quotes preserve everything literally—dollar sign included.

**Why students pick wrong answers:**
- **A** — Doesn't know there's a difference
- **C** — Has it backwards
- **D** — Thinks all quotes block expansion

**Live demo:** Run both commands. The visual is worth a thousand words.

> **Quick win:** Mnemonic—"Double for dynamic, single for static."

---

## PI-03: Condition Test — `[ ]` vs `[[ ]]`

### Scenario

```bash
FILE="my file.txt"   # Note the space!

# Test 1
if [ -f $FILE ]; then echo "Exists"; fi

# Test 2
if [[ -f $FILE ]]; then echo "Exists"; fi
```

### Question

If file "my file.txt" exists, what happens?

| Option | Answer |
|--------|--------|
| **A** | Both display "Exists" |
| **B** | Test 1 fails with error, Test 2 displays "Exists" |
| **C** | Test 1 displays "Exists", Test 2 fails |
| **D** | Both fail with error |

---

### Instructor Notes

**Correct answer: B**

**First vote target:** 30-40% correct (this is tricky)

`[ ]` is the old POSIX `test` command. It's dumb—it sees `$FILE` expand to two words and chokes. `[[ ]]` is a Bash conditional compound command that handles this properly.

**What happens under the hood:**
- `[ -f my file.txt ]` becomes three arguments: `-f`, `my`, `file.txt`. Error.
- `[[ -f my file.txt ]]` treats the whole thing as one filename. Works.

**The fix for `[ ]`:** Always quote: `[ -f "$FILE" ]`

**Best practice:** Just use `[[ ]]` in Bash scripts. Save `[ ]` for POSIX sh compatibility.

---

## PI-04: Command Substitution

### Scenario

What's the difference between these two forms?

```bash
# Form 1
files=`ls *.txt`

# Form 2
files=$(ls *.txt)
```

### Question

Which statement is correct?

| Option | Answer |
|--------|--------|
| **A** | They're identical in functionality and style |
| **B** | Form 2 is better: nestable and more readable |
| **C** | Form 1 is faster because it's older |
| **D** | Form 2 runs in a subshell, Form 1 doesn't |

---

### Instructor Notes

**Correct answer: B**

**First vote target:** 45-55% correct

Both do the same thing, but `$()` wins on readability and nesting:

```bash
# Try nesting backticks. I dare you.
dir=`dirname \`which python\``   # Headache

# Much cleaner
dir=$(dirname -- "$(command -v python3)")
```

**Why students pick wrong answers:**
- **A** — Functionally yes, stylistically no
- **C** — Syntax age does not establish a speed advantage; both forms perform command substitution
- **D** — Both run in a subshell

**Bottom line:** Backticks are legacy. Use `$()` in new code.

---

## PI-05: Trap and Cleanup

### Scenario

```bash
#!/bin/bash
TEMP_FILE=$(mktemp) || exit 1

cleanup() {
    rm -f "$TEMP_FILE"
    echo "Cleanup done"
}

trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

echo "Processing data..."
# ... processing ...
exit 0
```

### Question

When does the `cleanup` function run?

| Option | Answer |
|--------|--------|
| **A** | Only if script terminates with `exit 0` |
| **B** | Only if user presses Ctrl+C |
| **C** | On shell exit, including a handled INT/TERM that exits; not after SIGKILL or system failure |
| **D** | Only if you call `cleanup` explicitly |

---

### Instructor Notes

**Correct answer: C**

**First vote target:** 40-50% correct

`EXIT` runs when this shell exits and can execute its trap:
- `exit 0` or `exit 1`
- Reaching end of script
- Error with `set -e`
- Ctrl+C through the explicit INT handler above
- SIGKILL, SIGSTOP and machine failure cannot be handled by this trap

This is your safety net for temp files. Use it.

**Why students pick wrong answers:**
- **A** — EXIT doesn't care about the exit code
- **B** — That's SIGINT, not EXIT
- **D** — The whole point of trap is automation

> **War story:** A student's backup script left gigabytes of temp files because they forgot trap. Disk filled up. Lesson learned the hard way.

---

## PI-06: Exit Codes in Pipe

### Scenario

```bash
#!/bin/bash
set -e
set +o pipefail  # Explicitly disabled for this question

cat nonexistent.txt | grep "pattern" | wc -l
echo "Script continues..."
```

### Question

What happens if file "nonexistent.txt" doesn't exist?

| Option | Answer |
|--------|--------|
| **A** | The pipeline is cancelled immediately when cat fails, before wc can output |
| **B** | Diagnostic on stderr; stdout contains `0` and `Script continues...`; the script exits successfully |
| **C** | Only `0` is printed on stdout and the script stops before the final echo |
| **D** | The shown shell option state is unspecified, so no prediction is possible |

---

### Instructor Notes

**Correct answer: B**

**First vote target:** 25-35% correct (hard one!)

Without pipefail, a pipeline takes the status of its final command. `wc -l` succeeds, so this pipeline has status 0 even though `cat` and `grep` fail. All pipeline commands may already have run: errexit is not an instant pipeline cancellation mechanism.

With `set -o pipefail`, Bash uses the **rightmost nonzero** status, or zero if every command succeeds. `set -e` then acts on the pipeline status subject to its documented conditional-context exceptions. Use explicit `if`/status handling for expected failures; strict options are useful but do not replace a failure contract.

**Why the other answers do not fit:** A claims early cancellation; C omits continuation; D ignores the explicit `set +o pipefail`.

---

## PI-07: Find and -exec vs xargs

### Scenario

Compare deletion argument lists without deleting files. Set `LOG_DIR` to an owned fixture directory; these commands print their arguments only:

```bash
# Variant 1
find "$LOG_DIR" -name "*.log" -exec printf 'Would remove: <%s>\n' {} \;

# Variant 2
find "$LOG_DIR" -name "*.log" | xargs printf 'Would remove: <%s>\n'
```

### Question

What's the potential problem with Variant 2?

| Option | Answer |
|--------|--------|
| **A** | No problem, they're identical |
| **B** | Variant 2 fails with filenames containing spaces |
| **C** | Variant 2 is slower because of the pipe |
| **D** | Variant 2 doesn't work with `rm` |

---

### Instructor Notes

**Correct answer: B**

**First vote target:** 40-50% correct

`xargs` splits on whitespace by default. "access log.txt" becomes two arguments: "access" and "log.txt". Neither exists. Chaos.

**The fix:**
```bash
find "$LOG_DIR" -name "*.log" -print0 | xargs -0 -r printf 'Would remove: <%s>\n'
```
`-print0` uses null bytes as delimiters. `-0` tells xargs to expect them.

**Why students pick wrong answers:**
- **A** — Ignores word splitting
- **C** — Actually, `-exec \;` is slower (one process per file)
- **D** — xargs works with any command

> **Lab note:** Files with spaces are rare in production, so this bug hides until it doesn't. Test with weird filenames.

---

## PI-08: Logging Levels

### Scenario

A logging system has levels: DEBUG, INFO, WARN, ERROR.

```bash
LOG_LEVEL="WARN"

log_debug "Processing details..."    # Displayed?
log_info "Processing started"        # Displayed?
log_warn "Disk 80% full"             # Displayed?
log_error "Connection failed"        # Displayed?
```

### Question

With `LOG_LEVEL="WARN"`, which messages appear?

| Option | Answer |
|--------|--------|
| **A** | Only WARN |
| **B** | WARN and ERROR |
| **C** | DEBUG, INFO, WARN |
| **D** | All messages |

---

### Instructor Notes

**Correct answer: B**

**First vote target:** 55-65% correct

Logging levels are hierarchical: DEBUG < INFO < WARN < ERROR. Setting WARN means "WARN and above."

Think of it like a bouncer with a height requirement. Anyone WARN-height or taller gets through.

**Why students pick wrong answers:**
- **A** — Doesn't understand the hierarchy
- **C** — Has it backwards
- **D** — Defeats the purpose of LOG_LEVEL

---

## PI-09: Health Check Pattern

### Scenario

```bash
check_health() {
    local max_retries=3
    local retry=0
    
    while [[ $retry -lt $max_retries ]]; do
        if curl --connect-timeout 1 --max-time 2 -sf http://localhost:8080/health; then
            return 0
        fi
        retry=$((retry + 1))
        if ((retry < max_retries)); then sleep 2; fi
    done
    return 1
}
```

### Question

Why the `sleep` between retries?

| Option | Answer |
|--------|--------|
| **A** | Reduces script CPU usage |
| **B** | Gives the application time to start or recover |
| **C** | Required in Bash while loops |
| **D** | Prevents curl timeout |

---

### Instructor Notes

**Correct answer: B**

**First vote target:** 60-70% correct

Services don't start instantly. Hammering a starting service with rapid retries just makes things worse. The sleep gives it breathing room.

**Better pattern:** Exponential backoff
```bash
sleep $((2 ** retry))  # 2s, 4s, 8s...
```

**Why students pick wrong answers:**
- **A** — Spacing requests may reduce load too, but B states the recovery purpose; the relative CPU cost is workload-dependent
- **C** — sleep is optional, just useful
- **D** — curl has its own timeout setting

---

## PI-10: Deployment Rollback

### Scenario

Deployment failed. System shows:

```
/app/releases/
├── v1.0.0/     # previous stable
├── v1.1.0/     # current (broken)
└── current -> v1.1.0
```

### Question

Assume GNU coreutils, an owned release directory, an unused `.current.next` pathname and a separately health-checked previous release. Which method replaces the current directory symlink without a missing-link window?

| Option | Answer |
|--------|--------|
| **A** | `rm -rf v1.1.0 && mv v1.0.0 current` |
| **B** | `ln -s v1.0.0 .current.next && mv -Tf -- .current.next current` |
| **C** | `rm current && ln -s v1.0.0 current` |
| **D** | `cp -r v1.0.0/* v1.1.0/` |

---

### Instructor Notes

**Correct answer: B**

**First vote target:** 35-45% correct

Create a new link under a different name, then rename it over `current` on the same filesystem. GNU `mv -T` treats `current` as the destination entry rather than following the directory symlink. The rename provides filesystem namespace atomicity. It does not prove zero application downtime, connection continuity or successful reload. If staging fails, `&&` leaves the old live link unchanged.

**Why students pick wrong answers:**
- **A** — Destroys v1.1.0 (you might need it for debugging!)
- **C** — Gap between `rm` and `ln` = downtime
- **D** — Overwrites files instead of clean switch

**Retention decision:** Keep the required healthy rollback releases according to an explicit retention and capacity policy; no unlimited-retention policy is assumed here.

---

## Summary Table

| # | Topic | Difficulty | Tests |
|---|-------|------------|-------|
| PI-01 | Variable assignment | Easy | No spaces around `=` |
| PI-02 | Quotes | Easy | `" "` vs `' '` |
| PI-03 | Condition test | Medium | `[ ]` vs `[[ ]]` |
| PI-04 | Command substitution | Easy | Backticks vs `$()` |
| PI-05 | Trap cleanup | Medium | EXIT signal |
| PI-06 | Exit codes in pipe | Hard | pipefail |
| PI-07 | Find and xargs | Medium | Spaces in filenames |
| PI-08 | Logging levels | Easy | Level hierarchy |
| PI-09 | Health check | Medium | Retry with backoff |
| PI-10 | Deployment rollback | Hard | Atomic symlink |

---

## References

- Mazur, E. (1997). *Peer Instruction: A User's Manual*
- Brown & Wilson (2018). *Ten Quick Tips for Teaching Programming*
- GNU Bash Manual: https://www.gnu.org/software/bash/manual/

---

*Peer Instruction for SEM06 CAPSTONE — Operating Systems*  
*ASE Bucharest - CSIE | 2024-2025*
