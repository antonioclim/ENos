# Instructor Guide: Seminar 1-2
## Operating Systems | Shell Basics & Configuration

This timetable contains **100 minutes of contact activities plus a 10-minute break: 110 elapsed minutes**. Other routes use 100 elapsed minutes; the author must select the scheduled duration before delivery. No activity has been silently removed.  
Seminar type: Language as Vehicle (Bash for OS concepts)  
Level: Beginner (assuming minimal terminal experience)

---

## SESSION OBJECTIVES

At the end, students will be able to:
1. Navigate efficiently in the Linux file system
2. Conceptually distinguish between kernel, shell and terminal
3. Create and manipulate files and directories
4. Configure the shell environment with variables and aliases
5. Predict the behaviour of commands with different quoting

---

## PREPARATION BEFORE SEMINAR

### Technical Checks (10 min before)

```bash
# Verify that all tools are installed
which figlet lolcat cmatrix cowsay dialog tree pv >/dev/null 2>&1 && \
    echo "✅ Tools OK" || echo "❌ Install: apt install figlet lolcat cmatrix cowsay dialog tree pv"

# Check bash version
bash --version | head -1

# Prepare a clean working directory
DEMO_DIR=$(mktemp -d "${TMPDIR:-/tmp}/enos-demo.XXXXXX") || exit 1
# Keep this variable: cleanup may remove only this newly created directory.
trap 'rm -rf -- "$DEMO_DIR"' EXIT
cd -- "$DEMO_DIR" || exit 1
```

### Required Materials
- [ ] Working projector
- [ ] Terminal with large font (min 16pt)
- [ ] One text file for each exercise (pre-created)
- [ ] A/B/C/D cards for Peer Instruction (or Mentimeter/Kahoot setup)
- [ ] Visible timer for activities

### Recommended Terminal Setup
```bash
# Large and visible font
export PS1='\n\[\033[01;32m\]DEMO\[\033[00m\] \[\033[01;34m\]\w\[\033[00m\]\n\$ '

# Colours for clarity
alias ls='ls --color=auto'
alias grep='grep --color=auto'
```

---

## DETAILED TIMELINE - FIRST PART (50 min)

### [0:00-0:05] HOOK: Spectacular Demo

Purpose: Capture attention, establish interactive tone

```bash
# Optional hook; check installed programs and terminal support before delivery
clear
figlet -f slant "BASH" | lolcat
sleep 2
echo ""
cowsay -f tux "Welcome to OS!" | lolcat
sleep 2
clear
echo "In the next 100 minutes we will discover the magic of the terminal..."
```

Instructor notes:
- DO NOT explain the commands yet - leave the mystery
- Say: "By the end, you will understand every part of what you just saw"
- If tech fail: move directly to intro, don't waste time debugging
- Use `man` or `--help` when in doubt

---

### [0:05-0:10] PEER INSTRUCTION Q1: What is the Shell?

Display on screen:
```
When you type a command in the terminal and press Enter,
which component interprets the text first?

A) The Linux Kernel
B) The Shell (bash)
C) The Operating System
D) The Processor (CPU)
```

Protocol:
1. [0:05-0:06] Read question, 30 sec individual thinking
2. [0:06-0:07] First vote - raise cards/vote
3. [0:07-0:09] Pair discussion (2 min) - "Convince your neighbour"
4. [0:09-0:10] Second vote + explanation

Instructor notes:
- Correct answer: B) The Shell
- Distractor A (kernel): Students who confuse levels
- Distractor C (OS): Too vague, terminological confusion
- Distractor D (CPU): Hardware/software confusion

After voting, explain with the diagram:
```
┌─────────────────────────────────────┐
│         User (YOU)                  │
├─────────────────────────────────────┤
│  Terminal (window/interface)        │
├─────────────────────────────────────┤
│  Shell (BASH) ← Interprets HERE     │
├─────────────────────────────────────┤
│  Kernel (Linux) ← actual execution  │
├─────────────────────────────────────┤
│  Hardware (CPU, RAM, Disk)          │
└─────────────────────────────────────┘
```

---

### [0:10-0:25] LIVE CODING: Navigation and Basic Commands

STRUCTURE: Each command follows the Announce → Predict → Execute → Explain cycle

#### Segment 1: Where am I? (2 min)

```bash
# ANNOUNCE: "Let's see where we are in the system"
# PREDICT: "What do you think it will display?"
pwd
# EXPLAIN: "Print Working Directory - the complete path"

# PREDICT: "What do we see if we list?"
ls
# EXPLAIN: Contents of the current directory
```

#### Segment 2: Navigation (4 min)

```bash
# ANNOUNCE: "Let's walk through the system"
cd /
# PREDICT: "Where are we now?"
pwd

ls
# EXPLAIN: "This is the ROOT of the file system"

cd /home
ls
# EXPLAIN: "This is where user directories are located"

cd ~
# PREDICT: "What does ~ mean?"
pwd
# EXPLAIN: "Tilde = home directory"
```

#### Segment 3: Shortcuts (3 min)

```bash
cd /var/log
pwd
cd -
# PREDICT: "What does minus do?"
pwd
# EXPLAIN: "Toggle between the last two directories"

cd ..
# PREDICT: "Where do we end up?"
pwd
# EXPLAIN: "Two dots = parent directory"
```

#### Segment 4: Detailed listing (3 min)

```bash
cd ~
ls -la
# EXPLAIN (with pointer):
# drwxr-xr-x 5 stud stud 4096 Jan 15 10:30 Documents
# Name
# Date
# Size
# Group
# Owner
# Number of links
# Others permissions
# Group permissions
# Owner permissions
# d=directory, -=file, l=link
```

#### Segment 5: Creation and manipulation (3 min)

```bash
# Return from the read-only navigation tour before creating anything.
cd -- "${DEMO_DIR:?Run the owned-workspace preparation first}" || exit 1
mkdir project
cd project
touch file.txt
echo "Hello World" > file.txt
cat file.txt
```

**⚠️ DELIBERATE ERROR** (minute 23):

```bash
# SAY: "Now let's create a more complex structure..."
# WRITE INCORRECTLY ON PURPOSE:
mkdir src docs tests      # Correct, but then:
touch main .c             # WRONG! Extra space

# REACTION: "Hmm, what happened?"
ls -la
# They will see two files: "main" and ".c" (hidden)

# ASK: "What went wrong? Anyone see it?"
# EXPLAIN: The space separated the arguments

# CORRECT:
rm main .c
touch main.c
ls
```

---

### [0:25-0:30] PARSONS PROBLEM #1

Display on screen or distribute on paper:

```
══════════════════════════════════════════════════════════════
🧩 PARSONS PROBLEM: Create and navigate into a structure

Arrange the commands in the correct order to:
1. Create a directory "project"
2. Enter it
3. Create subdirectories "src" and "docs"
4. Verify the structure

LINES (scrambled order):
─────────────────────────────────────────────────────────────
   ls -R
   mkdir project
   mkdir src docs  
   cd project
   cd src          ← DISTRACTOR (not necessary)
─────────────────────────────────────────────────────────────

Time: 3 minutes | Work in pairs
══════════════════════════════════════════════════════════════
```

Solution:
1. `mkdir project`
2. `cd project`
3. `mkdir src docs`
4. `ls -R`

Instructor notes: The `cd src` distractor tests whether they understand that mkdir can create from the current directory.

---

### [0:30-0:45] SPRINT #1: Create Project Structure

PAIR PROGRAMMING MODE

```
══════════════════════════════════════════════════════════════
🏃 SPRINT #1: The Project Architect (15 min)

FORM PAIRS! 
├── Minute 0-7: Student A = Driver, Student B = Navigator
└── Minute 7-14: SWITCH roles!

REQUIREMENT:
Create the complete structure for a software project:

    my_project/
    ├── src/
    │   ├── main.c
    │   └── utils.c
    ├── include/
    │   └── header.h
    ├── docs/
    │   └── README.md
    ├── tests/
    │   └── test_main.c
    └── Makefile

HINT: Use mkdir -p and touch efficiently!

✓ VERIFICATION: Run "tree my_project" - it must look exactly like above
══════════════════════════════════════════════════════════════
```

Efficient solution (for instructor):
```bash
mkdir -p my_project/{src,include,docs,tests}
touch my_project/src/{main.c,utils.c}
touch my_project/include/header.h
touch my_project/docs/README.md
touch my_project/tests/test_main.c
touch my_project/Makefile
tree my_project
```

Timer:
- [0:30] Start, form pairs
- [0:37] "SWITCH!" - change Driver/Navigator
- [0:43] "2 minutes remaining!"
- [0:45] Stop, verification

---

### Pair Programming Protocol (Detailed)

Use this protocol for ALL sprint exercises throughout the seminar.

#### Setup Phase (2 minutes before sprint)
1. Students pair up (instructor assigns if uneven number)
2. Each pair uses ONE computer only
3. **Driver** sits at keyboard
4. **Navigator** stands or sits beside (can see screen clearly)

#### Role Definitions

| Role | Responsibilities | Don'ts |
|------|------------------|--------|
| **Driver** | Types code, explains thinking aloud, asks "Does this look right?" | Don't ignore Navigator, don't rush ahead |
| **Navigator** | Reads requirements, spots errors, suggests alternatives, tracks time | Don't grab keyboard, don't stay silent |

#### Rotation Schedule

| Time | Driver | Navigator | Instructor Action |
|------|--------|-----------|-------------------|
| 0:00-7:00 | Student A | Student B | Monitor, assist stuck pairs |
| 7:00 | — | — | Call **"SWITCH!"** loudly |
| 7:00-7:30 | — | — | Transition time (30 seconds) |
| 7:30-14:00 | Student B | Student A | Continue monitoring |

#### Instructor Prompts (use every 2-3 minutes)

Pick one pair and ask:
- "Navigator, what's the next step in your plan?"
- "Driver, can you explain what line 3 does?"
- "Team, before you hit Enter — what do you expect to happen?"
- "Navigator, do you see any potential issues?"

#### Common Problems & Solutions

| Problem | Solution |
|---------|----------|
| Navigator too passive | "Navigator, you must speak at least once every 30 seconds" |
| Driver ignores Navigator | "Driver, please repeat what Navigator just suggested" |
| One person dominates both roles | Strictly enforce timer, physically swap seats |
| Pair completely stuck | Allow "Phone a Friend" — ask another pair (not instructor first) |
| Uneven number of students | Form one trio: Driver + 2 Navigators who alternate |

#### Extension Challenges

For pairs who finish early (don't let them sit idle):

1. **One-liner Challenge:** "Can you express the dependent steps as a command list using `&&`? A pipeline connects streams and is not needed for directory creation."
2. **Error Handling:** "What if the directory already exists? Add a check."
3. **Peer Teaching:** "Explain your solution to a pair still working — without giving the answer"

---

### [0:45-0:50] PEER INSTRUCTION Q2: Quoting

Display:
```
What will the following command display?

NAME="Student"
echo 'Hello $NAME'

A) Hello Student
B) Hello $NAME
C) Error: variable does not exist
D) Hello (just that, nothing else)
```

Protocol: Vote → 2min Discussion → Revote → Explanation

Correct answer: B) Hello $NAME

Explanation:

*(Bash has ugly syntax, I admit. But it runs everywhere and that matters enormously in practice.)*

```bash
# Single quotes = LITERAL (expands nothing)
echo 'Hello $NAME'    # Output: Hello $NAME

# Double quotes = Allows expansion
echo "Hello $NAME"    # Output: Hello Student

# Without quotes = Word splitting + expansion
echo Hello $NAME      # Output: Hello Student
```

---

## 10 MINUTE BREAK

Suggestion: Leave a passive demonstration on screen:
```bash
while true; do fortune | cowsay -f $(ls /usr/share/cowsay/cows | shuf -n1) | lolcat; sleep 10; clear; done
```

---

## DETAILED TIMELINE - SECOND PART (50 min)

### [0:00-0:05] REACTIVATION: Quick Quiz

3 quick questions, raised hands:

1. "What does `cd -` do?" → Toggle directories
2. "What letter do you see at the beginning for a directory in `ls -l`?" → `d`

> 💡 Over the years, I have found that practical examples beat theory every time.

3. "How do you delete a directory with content?" → `rm -r`

---

### [0:05-0:20] LIVE CODING: Variables and .bashrc

#### Segment 1: Local variables (4 min)

```bash
# ANNOUNCE: "Let's create variables"
unset MESSAGE
MESSAGE="Hello from bash"
echo "$MESSAGE"

# PREDICT: "What does a newly invoked Bash interpreter receive?"
bash -c 'echo $MESSAGE'
# Output: (nothing)

# EXPLAIN: This unexported variable is absent in the new interpreter.
# A parenthesised subshell ( echo "$MESSAGE" ) retains shell state instead.
```

#### Segment 2: Export (4 min)

```bash
export MESSAGE="Hello from bash"
bash -c 'echo $MESSAGE'
# Output: Hello from bash

# EXPLAIN: export = visible to subprocesses
```

#### Segment 3: Special variables (3 min)

```bash
echo "Home: $HOME"
echo "User: $USER"  
echo "Path: $PATH"
echo "Login-shell environment value: $SHELL"

# PREDICT: "What will $? display after a successful command?"
ls
echo $?
# Output: 0

# PREDICT: "And after an error?"
ls /nonexistent 2>/dev/null
echo $?
# Output: 2 (or another non-zero value)
```

#### Segment 4: Configuring .bashrc (4 min)

```bash


# ANNOUNCE: "Let's see the configuration file"
head -n 30 "$HOME/.bashrc"
BASHRC_BACKUP=$(mktemp "$HOME/.bashrc.backup.XXXXXX") || exit 1
cp -- "$HOME/.bashrc" "$BASHRC_BACKUP" || exit 1

# ANNOUNCE: "Let's add an alias"
echo "alias ll='ls -la'" >> ~/.bashrc

# PREDICT: "Has this definition been loaded in the current shell?"
# Precondition for the demonstration: no prior ll alias or function.
unalias ll 2>/dev/null || :
unset -f ll 2>/dev/null || :
type ll
# A new definition written to a file is not automatically executed.

# EXPLAIN: It needs to be reloaded!
bash -n "$HOME/.bashrc" && source "$HOME/.bashrc"
ll
# Now it works!
```

*Personal note: Bash has ugly syntax, I admit. But it runs everywhere and that matters enormously in practice.*


**⚠️ DELIBERATE ERROR** (minute 18):

```bash
# WRITE INCORRECTLY ON PURPOSE:
VARIABLE = "value"    # Spaces around =

# Output: VARIABLE: command not found

# ASK: "What happened?"
# EXPLAIN: In bash, spaces around = are NOT allowed
# CORRECT:
VARIABLE="value"
echo $VARIABLE
```

---

### [0:20-0:25] PEER INSTRUCTION Q3: Local vs Export

Display:
```
What is the final output?

unset VAR1
VAR1="local"
export VAR2="exported"
bash -c 'echo "$VAR1 $VAR2"'

A) local exported
B) exported
C)  exported       (space at beginning, then "exported")
D) local
```

Correct answer: C)

Explanation:
- `$VAR1` is not exported → in the newly invoked interpreter it is empty → produces space
- `$VAR2` is exported → visible in the newly invoked interpreter → "exported"
- Result: " exported" (space + exported)
- Test first with simple data

---

### [0:25-0:40] SPRINT #2: Personalised Environment Configuration

```
══════════════════════════════════════════════════════════════
🏃 SPRINT #2: Personalise Your Shell (15 min)

PAIR PROGRAMMING - switch roles at halfway!

TASKS:
1. Create a backup of .bashrc
2. Add these aliases:
   - ll for ls -la
   - cls for clear
   - cdp for cd ~/projects (create the directory first)
   
3. Add a welcome message in .bashrc:
   echo "Welcome back, $USER! Today is $(date +%A)"
   
4. Modify PS1 for a simple coloured prompt

5. Test by opening a new terminal or with source

✓ VERIFICATION: 
   - ll works
   - cdp takes you to ~/projects
   - On terminal opening you see the message
══════════════════════════════════════════════════════════════
```

Solution (for instructor):
```bash
# 1. Backup
BASHRC_BACKUP=$(mktemp "$HOME/.bashrc.backup.XXXXXX") || exit 1
cp -- "$HOME/.bashrc" "$BASHRC_BACKUP" || exit 1

# 2. Aliases
mkdir -p ~/projects
cat >> ~/.bashrc << 'EOF'

# === Custom aliases ===
alias ll='ls -la'
alias cls='clear'
alias cdp='cd ~/projects'

# === Welcome message ===
echo "Welcome back, $USER! Today is $(date +%A)"

# === Coloured prompt ===
PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
EOF

# 5. Inspect the added lines and check syntax before activation
bash -n "$HOME/.bashrc" && source "$HOME/.bashrc"
```

---

### [0:40-0:48] LLM EXERCISE: Generate and Critique

```
══════════════════════════════════════════════════════════════
🤖 LLM EXERCISE: The Alias Evaluator (8 min)

INDIVIDUAL - use ChatGPT/Claude/Gemini

PART 1 (3 min): The Prompt
"Generate 5 useful aliases for a student 
who works with Python and does frequent backups"

PART 2 (5 min): Evaluate the output
For EACH generated alias, answer:
1. ✅ Is it syntactically correct? (tested in terminal)
2. 🤔 Is it useful for me personally?
3. ⚠️ Does it have dangerous side effects?

WRITE in REFLECTION.txt:
- Which alias you would use and why
- Which alias is dangerous and why
══════════════════════════════════════════════════════════════
```

Instructor notes:
- Circulate through the class, verify that students TEST the code
- LLMs can generate `alias rm='rm -rf'` - discuss the danger!
- Final discussion: "What surprises did you have?"

---

### [0:48-0:50] REFLECTION CHECKPOINT

Display and read:

```
══════════════════════════════════════════════════════════════
🧠 REFLECTION (2 minutes of silent thinking)

1. What was the most surprising thing 
   you learned today?

2. What do you still not fully understand?

3. One thing you want to explore on your own:
   ___________________________________________

Write on paper or in notes - it's for YOU, not for a grade.
══════════════════════════════════════════════════════════════
```

---

## COMMON TROUBLESHOOTING

| Problem | Quick Solution |
|---------|----------------|
| figlet/lolcat not installed | `sudo apt install figlet lolcat -y` |
| Terminal too small | Ctrl+Shift++ for zoom |
| Student stuck in vim | Press `Esc`, then type `:q!` and Enter |
| .bashrc corrupted | Restore the unique backup created for this attempt: `cp -- "$BASHRC_BACKUP" "$HOME/.bashrc"`, after checking the source path |
| Permission denied | Work in `~`, not in `/` |

---

## AFTER SEMINAR

### Note for next time:
- Which PI questions had unexpected distribution?
- What new misconceptions appeared?
- Which exercises took more/less than estimated?
- Spontaneous feedback from students?

### Homework for students:
1. Create 3 custom aliases in .bashrc
2. Complete the exercises from `06_SPRINT_EXERCISES.md`
3. Read `man bash` section about quoting

---

*Instructor Guide | OS Seminar 1-2 | ASE Bucharest - CSIE*
*Version 2.1 | January 2025*
