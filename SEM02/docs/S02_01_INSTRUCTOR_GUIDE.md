# Instructor Guide - Seminar 02
## Operating Systems | Practical Teaching Notes

**Document**: S02_01_INSTRUCTOR_GUIDE.md  
**Version**: 1.0 | **Date**: January 2025  
**Intended for**: Teaching assistants, doctoral students, laboratory instructors  
**Author**: ing. dr. Antonio Clim

---

## Before the Seminar

### Preparation Checklist (15 minutes before class)

I know this seems like a lot, but trust me - better to verify now than lose 10 minutes of seminar time debugging projector issues.

```
□ Projector functional, terminal visible from the back row
□ Enlarged terminal font (CTRL++ until at least 18pt)
□ Demo files prepared in /tmp/sem02_demo/
□ Quiz runner quickly tested: cd SEM02 && make quiz (CTRL+C after first question)
□ PDF slides as backup on USB stick
□ Functional whiteboard marker (for ad-hoc diagrams)
□ Coffee/water for yourself (90 minutes is a long stretch)
```

### Quick Demo Setup

Run this BEFORE students arrive:

```bash
cd /path/to/SEM02
./scripts/bash/S02_01_setup_seminar.sh

# Verify everything was created
ls -la /tmp/sem02_demo/
# You should see: sample.txt, access.log, data.csv, users.txt, etc.
```

If the script produces errors, create the essential files manually:

```bash
mkdir -p /tmp/sem02_demo && cd /tmp/sem02_demo

# Simple text file
echo -e "line one\nline two\nline three" > sample.txt

# Fake log for filter demonstrations
cat > access.log << 'EOF'
192.168.1.100 - - [29/Jan/2025:10:15:32] "GET /index.html" 200
192.168.1.101 - - [29/Jan/2025:10:15:33] "GET /style.css" 200
192.168.1.100 - - [29/Jan/2025:10:15:34] "POST /login" 401
10.0.0.50 - - [29/Jan/2025:10:15:35] "GET /admin" 403
192.168.1.100 - - [29/Jan/2025:10:15:36] "GET /dashboard" 200
EOF

# CSV for exercises
echo -e "name,age,city\nAna,22,Bucharest\nIon,25,Cluj\nMaria,22,Iasi" > data.csv
```

---

## Things That Go Wrong (Every. Single. Year.)

Look, I've taught this seminar many times now. Here's what WILL happen, so you can be ready:

### The `>` vs `>>` Massacre
Demo both side by side. Twice. Three times if necessary. Then demo what happens when you accidentally use `>` on an important file. Students still ask about this during the assignment, but at least they'll remember you warned them.

### The Subshell Variable Trap
Someone will write `cat file | while read line; do ((count++)); done` and wonder why `$count` is 0 afterwards. I now demo the bug FIRST, let them feel the confusion, then show the fix. The "aha moment" is more memorable than just showing the correct way.

### "But it works on my machine"
Usually a hidden Windows line ending (`\r\n` vs `\n`). Keep `dos2unix` ready. Since 2023, also check for students accidentally using PowerShell syntax in Bash.

### The AI Dump (new problem since 2023)
Students submit scripts with perfect comments, elaborate variable names, and broken logic. The autograder now includes AI pattern detection. If you see suspiciously polished code, ask the student to explain a random line. Usually reveals the gap quickly.

### The `{1..$n}` Bug
Despite explicit warnings, ~20% still try this. I now write on the whiteboard in red: **BRACE EXPANSION BEFORE VARIABLE EXPANSION**. Then immediately show `seq` and C-style alternatives.

---

## Recommended Session Flow

### Minutes 0-10: HOOK (Attention Capture)

**Purpose**: Wow factor. Show them what they will be able to do by session end.

**My typical script** (adapt to your own style):

> "Let us see something interesting. Who knows how many .conf configuration files exist on this system?"

```bash
find /etc -name "*.conf" 2>/dev/null | wc -l
```

> "And which are the 5 largest?"

```bash
find /etc -name "*.conf" -exec du -h {} \; 2>/dev/null | sort -rh | head -5
```

> "Or even better: how many lines of code exist in all Bash scripts under /usr?"

```bash
find /usr -name "*.sh" -exec cat {} \; 2>/dev/null | wc -l
```

> "By the end of today's seminar, you will be able to construct commands like these yourselves."

**Note**: If someone asks about `2>/dev/null`, respond briefly: "It hides error messages - we shall examine this in detail shortly." Do not get lost in explanations now.

---

### Minutes 10-25: Control Operators

#### Theory Portion (7 minutes)

Draw on whiteboard or display slide:

```
cmd1 ; cmd2     → cmd2 runs ALWAYS (sequential)
cmd1 && cmd2    → cmd2 runs ONLY if cmd1 returns 0 (success)
cmd1 || cmd2    → cmd2 runs ONLY if cmd1 returns ≠0 (failure)
cmd1 & cmd2     → cmd1 goes to background, cmd2 starts immediately
```

**Student Error #1**: Confusing `&` (background) with `&&` (logical AND).

Quick demonstration for clarification:

```bash
sleep 3 & echo "Appears immediately"    # echo appears INSTANTLY
sleep 3 && echo "Appears after 3s"      # echo appears AFTER sleep
```

**Tip**: Write on the whiteboard in large letters: `&` ≠ `&&`. Underline twice.

#### Peer Instruction (8 minutes)

Use question PI-03 (or similar):

```bash
false && echo "A" || echo "B" && echo "C"
```

**Procedure**:

1. **Initial vote** (1 min): "Raise hands - who says only A is displayed? Only B? Only C? B and C? Something else?"
   - Mentally note the distribution. Typically: 40% "only B", 30% "B and C", remainder other answers.

2. **Paired discussion** (3 min): "Turn to your neighbour and convince them of your answer."
   - Circulate around the room, listen to arguments, do not correct yet.

3. **Final vote** (1 min): Usually concentrates toward the correct answer.

4. **Explanation** (3 min): Walk through step by step on whiteboard:

```
false           → exit code 1 (failure)
  && echo "A"   → NOT executed (predecessor failed)
  || echo "B"   → EXECUTED (preceding chain failed) → displays "B", exit 0
  && echo "C"   → EXECUTED (predecessor succeeded) → displays "C"

Result: "B" and "C" are displayed (on separate lines)
```

---

### Minutes 25-45: I/O Redirection

#### Fundamental Diagram (draw on whiteboard!)

```
                    ┌──────────────────┐
    stdin (fd 0) ──►│                  │──► stdout (fd 1) ──► terminal/file
        ▲           │     COMMAND      │
        │           │                  │──► stderr (fd 2) ──► terminal/file
   keyboard         └──────────────────┘
   or file
```

**Explain**: "Every process has 3 channels open by default. Redirection means changing where these channels lead."

#### Guided Live Coding (15 minutes)

Build progressively, checking comprehension:

```bash
# 1. Basics - stdout to file
echo "test" > out.txt
cat out.txt

# 2. What happens if I repeat?
echo "line 2" > out.txt
cat out.txt          # "line 2" - it OVERWROTE!

# 3. How do we APPEND?
echo "test" > out.txt
echo "line 2" >> out.txt
cat out.txt          # both lines!
```

**Pause**: "Questions so far? Is the difference between > and >> clear?"

```bash
# 4. Stderr is on a different channel
ls /nonexistent_directory              # error on screen
ls /nonexistent_directory > out.txt    # error STILL on screen!
cat out.txt                            # file is EMPTY

# Why? Stdout and stderr are SEPARATE
ls /nonexistent_directory 2> err.txt   # now it works
cat err.txt
```

#### THE CLASSIC TRAP (dedicate 5 minutes)

This is where 60% of students get confused in examinations:

```bash
# CORRECT: stdout to file, THEN stderr to where stdout is now (i.e. the file)
ls /home /nonexistent > all.txt 2>&1
cat all.txt      # contains BOTH valid output AND the error

# WRONG: stderr goes where stdout is NOW (terminal), then stdout to file
ls /home /nonexistent 2>&1 > all.txt
# Error APPEARS on screen! Why?
```

**Explanation with diagram**:

```
CORRECT: > all.txt 2>&1
  Step 1: stdout → all.txt
  Step 2: stderr → where stdout is NOW → all.txt ✓

WRONG: 2>&1 > all.txt  
  Step 1: stderr → where stdout is NOW → terminal
  Step 2: stdout → all.txt
  Result: stderr still goes to screen! ✗
```

**Mnemonic**: "Destination first, then the copy" or "Order matters - redirect, then duplicate".

---

### Minutes 45-70: Filters and Pipelines

#### Visual Demo - Incremental Construction (10 minutes)

Show output at EACH step:

```bash
cd /tmp/sem02_demo

# Step 1: what have we got?
cat access.log

# Step 2: extract just the IP addresses
cat access.log | cut -d' ' -f1

# Step 3: sort them
cat access.log | cut -d' ' -f1 | sort

# Step 4: count unique occurrences
cat access.log | cut -d' ' -f1 | sort | uniq -c

# Step 5: sort descending by count
cat access.log | cut -d' ' -f1 | sort | uniq -c | sort -rn

# Step 6: take top 3
cat access.log | cut -d' ' -f1 | sort | uniq -c | sort -rn | head -3
```

**Teaching tip**: Build the pipeline LIVE, step by step. Do not show the final command directly - it loses the effect.

#### In-Class Parsons Problem (10 minutes)

Project PP-08 or a similar problem.

> "You have 4 minutes to arrange the lines in correct order. Work in pairs."

Circulate around the room:
- Observe what errors they make
- Do not correct directly; ask questions: "What do you think sort does here?"
- Mentally note common errors for debriefing

After 4 minutes:
> "Who would like to come to the board and show us the solution?"

Let the student explain, supplement where necessary.

#### Sprint Exercises (10 minutes)

> "Now individually. You have 10 minutes for exercises S-F1 and S-F2. The validator runs locally."

```bash
# Students run on their workstation
./scripts/bash/S02_03_validator.sh ./my_solution/
```

You: circulate, help where there is blockage, but do not give solutions - ask guiding questions.

---

### Minutes 70-85: Loops

#### Essential Patterns (whiteboard)

```bash
# FOR - when you know the list of elements
for item in list of elements; do
    echo "$item"
done

# FOR with brace expansion - for numeric sequences
for i in {1..5}; do
    echo "$i"
done

# WHILE - when reading input or awaiting condition
while IFS= read -r line; do
    echo "Line: $line"
done < file.txt

# UNTIL - inverse of while (less commonly used)
until [[ $count -ge 10 ]]; do
    ((count++))
done
```

#### THE SUBSHELL TRAP (very important!)

```bash
# PROBLEM: variable does NOT persist
count=0
cat file.txt | while read line; do
    ((count++))
done
echo "Counted: $count"   # Displays 0! Why?!

# SOLUTION: redirect instead of pipe
count=0
while read line; do
    ((count++))
done < file.txt
echo "Counted: $count"   # Displays correct value!
```

**Explanation**: The pipe creates a SUBSHELL. Variables modified in the subshell die with it. Redirection (`< file`) runs in the current shell.

Draw:

```
WRONG (pipe):
┌─────────────┐      ┌─────────────┐
│  cat file   │ ───► │ while read  │  ← SEPARATE SUBSHELL
│             │      │ count++     │     count dies here!
└─────────────┘      └─────────────┘

CORRECT (redirect):
┌─────────────────────────────────┐
│  while read line; do            │  ← SAME SHELL
│      count++                    │     count survives
│  done < file                    │
└─────────────────────────────────┘
```

---

### Minutes 85-90: Wrap-up

1. **Visual summary** (2 min):
   - Show the cheat sheet (S02_02_cheat_sheet.html or printout)
   - Highlight the 5 things to remember:
     1. `>` overwrites, `>>` appends
     2. `2>&1` AFTER the stdout redirect
     3. `&&` = success, `||` = failure
     4. Pipeline = stdout → stdin
     5. Pipe creates subshell, redirect does not

2. **Assignment preview** (2 min):
   > "The assignment has 6 parts, deadline [date]. Part 5 integrates everything we did today. Part 6 is short but mandatory - it verifies you understand rather than just copied. Bonus available for advanced solutions."

3. **Questions** (1 min):
   > "Any questions? I am also on the forum; I respond within 24 hours."

---

## Common Situations and How I Handle Them

### "Command X does not work"

Quick diagnosis:

```bash
which X         # Does the command exist?
type X          # Is it alias/builtin/external?
echo $PATH      # Is PATH configured correctly?
bash --version  # Bash version (some features require 4.0+)
```

### "I accidentally deleted/overwrote the file"

**Prevention**: ALWAYS demonstrate the danger of `>` before exercises.

**If it happened**: "Unfortunately, if it was in /tmp, it is lost. Let us recreate it. Next time, use `>|` only when certain, or make a backup first."

### "Why is the output different from what I expected?"

Debugging technique:

```bash
set -x    # Activate trace mode - see each command
# ... problematic commands ...
set +x    # Deactivate

# Or for a single command:
bash -x script.sh
```

### Advanced student who is bored

Options:
- "Try the bonus exercise from the assignment"
- "Can you optimise the pipeline to run faster?"
- "Help your neighbour - explain the concept to them" (peer teaching)

### Completely lost student

- Do not ignore them, but do not block the session for them either
- "Stay 5 minutes after class; I shall help you catch up"
- Recommend supplementary resources from S02_RESOURCES.md
- Suggest peer tutoring

---

## After the Seminar

### Post-session Checklist

```
□ Save notes: what went well, what needs adjustment
□ Verify the cleanup script ran (rm -rf /tmp/sem02_demo)
□ Respond to forum questions within 24 hours maximum
□ If you found errors in materials, note them for correction
```

### Notes Template for Improvement

```
Date: ___________
Group: ___________

What worked well:
- 

What took too long:
-

What took too little time:
-

Unexpected questions:
-

Newly observed misconceptions:
-

To modify for next time:
-
```

---

## Appendix A: Quick Peer Instruction Answers

| ID | Correct Answer | Common Trap |
|----|---------------|-------------|
| PI-01 | Exit code 0 | Think it is 1 (success/failure confusion) |
| PI-02 | "B" and "C" | Only "B" |
| PI-03 | "B" and "C" | Only "B" or think they appear on same line |
| PI-04 | Variable is empty | Think it persists from subshell |
| PI-05 | File is overwritten | Think it appends |

## Appendix B: Exit Codes to Memorise

| Code | Meaning | When It Appears |
|------|---------|-----------------|
| 0 | Success | Command worked correctly |
| 1 | General error | Various unspecified errors |
| 2 | Misuse | Invalid arguments |
| 126 | Permission denied | File without execute permission |
| 127 | Command not found | Command does not exist in PATH |
| 128+N | Killed by signal N | E.g. 130 = SIGINT (Ctrl+C) |

## Appendix C: Emergency Commands

```bash
# If something is running and will not stop
Ctrl+C              # Interrupt current process
Ctrl+Z              # Suspend (then `kill %1` or `bg`)

# If terminal appears frozen
Ctrl+Q              # Reactivate scroll (if you pressed Ctrl+S by mistake)
reset               # Reset terminal

# If cursor has disappeared
echo -e "\033[?25h"  # Show cursor
```

---

*Practical guide for instructors | Seminar 02 - Operating Systems*  
*ASE Bucharest - CSIE | Last updated: January 2025*
