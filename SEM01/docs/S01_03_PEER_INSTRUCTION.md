# Peer Instruction - Questions for Seminar 1-2
## Operating Systems | Shell Basics & Configuration

Total questions: 15  
Time per question: 3-5 minutes  
Format: Individual vote → Pair discussion → Revote → Explanation

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

### Optimal Conditions

- **Target first-vote accuracy:** 40-60% (maximises learning from discussion)
- **Discussion groups:** 2-3 students with different initial answers
- **Re-vote improvement:** Expect 20-30% increase after discussion

### Question Notation

Each question includes:
- **Bloom level:** Cognitive level being assessed
- **Misconception target:** Which common error this question tests
- **Distractor analysis:** Why wrong answers are tempting

---

## USAGE PROTOCOL

```
┌────────────────────────────────────────────────────────────────┐
│  PEER INSTRUCTION CYCLE (5 minutes per question)              │
├────────────────────────────────────────────────────────────────┤
│  [0:00-0:30]  Read question, individual thinking              │
│  [0:30-1:30]  FIRST VOTE (A/B/C/D cards or digital poll)      │
│  [1:30-3:30]  Pair discussion ("Convince your neighbour!")    │
│  [3:30-4:00]  SECOND VOTE                                     │
│  [4:00-5:00]  Instructor explanation + live demonstration     │
└────────────────────────────────────────────────────────────────┘
```

Interpreting first vote results:
- < 30% correct: You explain the concept, don't proceed to discussion
- 30-70% correct: IDEAL for peer instruction - continue
- > 70% correct: Question is too easy, move on quickly

---

## SHELL & SYSTEM QUESTIONS

### PI-01: Role of the Shell
Level: Fundamental | Duration: 4 min | Target: ~50% correct

```
When you type "ls -la" in the terminal and press Enter,
which component INTERPRETS this command FIRST?

A) The Linux Kernel - controls the hardware
B) The Bash Shell - interprets commands
C) The Processor (CPU) - executes instructions
D) Terminal - displays text
```

Correct answer: B

| Distractor | Targeted misconception |
|------------|------------------------|
| A | Confusion between interpretation and final execution |
| C | Hardware/software confusion - CPU executes, doesn't interpret text commands |
| D | Terminal/shell confusion - terminal is just the visual interface |

After discussion, demonstrate:
```bash
echo $SHELL          # Shows which shell you use
ps -p $$             # Shows the shell process
cat /etc/shells      # List of available shells
```

---

### PI-02: Path Types
Level: Fundamental | Duration: 3 min | Target: ~60% correct

```
Which of the following is an ABSOLUTE PATH?

A) ../Documents
B) ~/Downloads
C) /home/student/file.txt
D) ./script.sh
```

Correct answer: C

| Distractor | Targeted misconception |
|------------|------------------------|
| A | `..` is relative to current directory |
| B | `~` seems absolute but it's shell expansion (becomes absolute but isn't "pure") |
| D | `./` is explicitly relative |

Note: B can be debatable - accept and explain that ~ expands to absolute path but technically it's a shortcut.

---

### PI-03: Root Directory
Level: Fundamental | Duration: 3 min | Target: ~65% correct

```
You run the following commands. What is the final output?

cd /
cd ..
pwd

A) / (root)
B) Error - you cannot go above root
C) (nothing - invalid command)
D) /home
```

Correct answer: A

Explanation: In Linux, `/..` = `/`. You cannot "exit" from root, you stay in place.

```bash
# Demonstration
cd /
ls -la | grep "\..$"    # .. exists and points to /
cd ..
pwd                      # Still /
```

---

## QUOTING & VARIABLES QUESTIONS

### PI-04: Single vs Double Quotes
Level: Intermediate | Duration: 5 min | Target: ~45% correct

```
NAME="Student"
echo 'Hello $NAME'

What will the echo command display?

A) Hello Student
B) Hello $NAME
C) Hello (just that)
D) Error - variable does not exist in single quotes
```

Correct answer: B

| Distractor | Targeted misconception |
|------------|------------------------|
| A | Believes variables expand in single quotes too |
| C | Confusion with behaviour of other languages |
| D | Believes it's an error instead of literal behaviour |

Comparative demonstration:
```bash
NAME="Student"
echo 'Hello $NAME'    # Hello $NAME
echo "Hello $NAME"    # Hello Student
echo Hello $NAME      # Hello Student
```

---

### PI-05: Escape Character
Level: Intermediate | Duration: 4 min | Target: ~50% correct

> The quoting question is my favourite because it splits the room exactly 50/50 every single time. I've run this in over 30 seminars and the distribution is remarkably consistent.

```
What does this command display?

echo "The cost is \$100"

A) The cost is \$100
B) The cost is $100
C) The cost is 100
D) Error - $ invalid
```

Correct answer: B

Explanation: `\$` in double quotes = literal `$` character, not expansion.

---

### PI-06: Variables - Incorrect Assignment
Level: Intermediate | Duration: 4 min | Target: ~40% correct

```
What happens when you run?

VAR = "value"
echo $VAR

A) Displays "value"
B) Displays "" (empty string)
C) Error: VAR: command not found
D) Error: syntax error
```

Correct answer: C

Explanation: The space makes bash interpret `VAR` as a command!

```bash
# Wrong
VAR = "value"    # bash: VAR: command not found

# Correct
VAR="value"      # No spaces!
echo $VAR
```

---

### PI-07: Local vs Export
Level: Advanced | Duration: 5 min | Target: ~35% correct

```
LOCAL="local"
export EXPORTED="exported"
bash -c 'echo "[$LOCAL] [$EXPORTED]"'

What will it display?

A) [local] [exported]
B) [] [exported]
C) [local] []
D) [] []
```

Correct answer: B

| Distractor | Targeted misconception |
|------------|------------------------|
| A | Believes all variables are visible in subshell |
| C | Inverse confusion about export |
| D | Believes subshell inherits nothing |

Demonstration:
```bash
LOCAL="local"
export EXPORTED="exported"
bash -c 'echo "LOCAL=$LOCAL, EXPORTED=$EXPORTED"'
# Output: LOCAL=, EXPORTED=exported
```

---

### PI-08: Exit Code
Level: Intermediate | Duration: 4 min | Target: ~55% correct

```
ls /nonexistent 2>/dev/null
echo $?
ls /home 2>/dev/null
echo $?

What do the two echo commands display (in order)?

A) 0, 0
B) 1, 0
C) 2, 0
D) 0, 1
```

Correct answer: C (or B, depends on system - accept both)

Explanation:
- First command: nonexistent directory → non-zero exit code (2 for ls)
- Second command: success → exit code 0
- `2>/dev/null` only hides error messages, doesn't change exit code

---

## GLOBBING & FILES QUESTIONS

### PI-09: Wildcard *
Level: Fundamental | Duration: 4 min | Target: ~60% correct

```
In the current directory you have: file1.txt, file2.txt, file10.txt, notes.txt

What files does the command list: ls file?.txt

A) file1.txt file2.txt file10.txt
B) file1.txt file2.txt
C) file1.txt file2.txt notes.txt
D) All four files
```

Correct answer: B

Explanation: `?` matches EXACTLY ONE character, not more.
- `file1.txt` ✓ (? = 1)
- `file2.txt` ✓ (? = 2)
- `file10.txt` ✗ (10 = two characters!)
- `notes.txt` ✗ (doesn't start with "file")

---

### PI-10: Hidden Files
Level: Intermediate | Duration: 4 min | Target: ~45% correct

```
You have these files: file.txt, .hidden, .bashrc, data.csv

What does: ls *

A) file.txt, .hidden, .bashrc, data.csv
B) file.txt, data.csv
C) file.txt, .hidden, data.csv
D) All files that don't start with a dot
```

Correct answer: B (and D is conceptually correct)

Explanation: Glob `*` does NOT include files starting with `.` (hidden)!

```bash
# You need to be explicit:
ls .*           # Only hidden
ls * .*         # All
ls -a           # All (simpler)
```

---

### PI-11: rm -r
Level: Intermediate | Duration: 3 min | Target: ~70% correct

```
You have the structure:
project/
├── src/
│   └── main.c
└── README.md

You run: rm project

What happens?

A) Deletes entire project directory with content
B) Error: project is a directory
C) Deletes only files, leaves directories
D) Moves project to Trash/Recycle Bin
```

Correct answer: B

Explanation: `rm` without `-r` doesn't delete directories!

```bash
rm project           # rm: cannot remove 'project': Is a directory
rm -r project        # Deletes recursively (CAUTION!)
rm -rf project       # Forced, no confirmation (VERY DANGEROUS!)
```

---

## CONFIGURATION QUESTIONS

### PI-12: .bashrc Timing
Level: Intermediate | Duration: 4 min | Target: ~40% correct

```
You add to ~/.bashrc:
alias ll='ls -la'

Then you immediately run in the SAME terminal:
ll

What happens?

A) Works - displays detailed list
B) Error: ll: command not found
C) Displays "ls -la" as text
D) Opens editor to configure the alias
```

Correct answer: B

Explanation: `.bashrc` is only loaded when opening a new shell!

```bash
# Solutions:
source ~/.bashrc    # Reload in current shell
. ~/.bashrc         # Equivalent
# OR open new terminal
```

---

### PI-13: PATH
Level: Advanced | Duration: 5 min | Target: ~35% correct

```
PATH="/custom/bin"
echo $PATH
ls

What happens with the ls command?

A) Lists current directory normally
B) Error: ls: command not found
C) Searches for ls in /custom/bin
D) Uses ls from cached location
```

Correct answer: B

Explanation: We REPLACED the entire PATH! `ls` can no longer be found.

```bash
# WRONG - replaces everything:
PATH="/custom/bin"

# CORRECT - append:
PATH="/custom/bin:$PATH"    # At beginning (priority)
PATH="$PATH:/custom/bin"    # At end
```

---

### PI-14: PS1 Prompt
Level: Intermediate | Duration: 4 min | Target: ~50% correct

```
You set: PS1='\u@\h:\w\$ '

What does \w represent?

A) Username (whoami)
B) Current working directory
C) Computer name (hostname)
D) Day of the week (weekday)
```

Correct answer: B

| Sequence | Meaning |
|----------|---------|
| `\u` | Username |
| `\h` | Hostname (short) |
| `\w` | Working directory (full path) |
| `\W` | Working directory (name only) |

---

### PI-15: Command Substitution
Level: Advanced | Duration: 5 min | Target: ~40% correct

```
FILES=$(ls)
echo "Found: $FILES"

What does $( ) do in the first line?

A) Creates a subshell and saves output to variable
B) Runs ls as background process
C) Declares FILES as array
D) Is equivalent to FILES="ls" (literal text)
```

Correct answer: A

Explanation: `$(command)` executes the command and substitutes with output.

```bash
# Command substitution
FILES=$(ls)         # Executes ls, saves output
COUNT=$(wc -l < file.txt)   # Counts lines

# Old form (avoid):
FILES=`ls`          # Backticks - harder to read
```

---

## USAGE MATRIX

| Question | Optimal Moment | After which concept? |
|----------|----------------|----------------------|
| PI-01 | Opening | Before anything |
| PI-02 | After navigation | cd, pwd |
| PI-03 | After navigation | cd .. |
| PI-04 | After quoting | echo, variables |
| PI-05 | After escape | Backslash |
| PI-06 | After variables | Assignment |
| PI-07 | After export | Subshell |
| PI-08 | After errors | Debugging |
| PI-09 | After globbing | Wildcards |
| PI-10 | After ls -a | Hidden files |
| PI-11 | After rm | Deletion |
| PI-12 | After .bashrc | Configuration |
| PI-13 | After PATH | Environment |
| PI-14 | After PS1 | Prompt |
| PI-15 | After $() | Scripting intro |

---

## ANSWER TRACKING

Use this table to note the distributions:

| PI# | V1-A | V1-B | V1-C | V1-D | V2-A | V2-B | V2-C | V2-D | Note |
|-----|------|------|------|------|------|------|------|------|------|
| 01  |      |      |      |      |      |      |      |      |      |
| 02  |      |      |      |      |      |      |      |      |      |
| ... |      |      |      |      |      |      |      |      |      |

V1 = First vote, V2 = Second vote (after discussion)

---

*Peer Instruction Questions | OS Seminar 1-2 | ASE-CSIE*
