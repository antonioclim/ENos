# Live Coding Guide - Seminar 1: Bash Shell

> **Operating Systems** | ASE Bucharest - CSIE  
> Step-by-step guide for interactive demonstrations

---

## Live Coding Principles

### Golden Rules for the Instructor

1. **ALWAYS** ask for a prediction before running the command
2. **NEVER** copy/paste - type everything
3. **MAKE MISTAKES INTENTIONALLY** at moments marked with ⚡
4. **TALK** while typing - explain what you're doing
5. **PAUSE** for 2-3 seconds after important output
6. **CHECK** understanding with "What do you think it will display?"

### Tempo and Rhythm

| Situation | Tempo |
|-----------|-------|
| New concept | SLOW (3-5 sec between commands) |
| Repetition | NORMAL (1-2 sec) |
| "Magic" demo | FAST (wow effect) |
| After error | PAUSE (let them observe) |

---

# SECTION 1: HOOK DEMO (3 minutes)

> **Note for instructors**: The first 3 minutes decide whether you have the students or not. In my experience, if you don't capture attention with something visual in the first minutes, half the room is on their phones. Figlet + lolcat works every time — it's cheesy but it works!

## Objective: Capturing attention with "Bash Magic"

### Complete Script

```bash

*Personal note: Bash has ugly syntax, I admit. But it runs everywhere and that matters enormously in practice.*

# [INSTRUCTOR]: "Welcome! Before any theory, let's see
# what the shell can do..."

# [TYPE SLOWLY, WITH DRAMA]
figlet -f slant "BASH" | lolcat

# [PAUSE 2 SEC - let them admire]

# [INSTRUCTOR]: "This is the terminal. It's not just for hackers in films."

# [MATRIX EFFECT - only 3 seconds]
# (I know, it's cliché from 1999, but students still love it)
timeout 3 cmatrix -b -C green

# [CTRL+C if it doesn't stop on its own]

# [INSTRUCTOR]: "And yes, we can also do this..."
cowsay -f tux "Welcome to OS!" | lolcat

# [INSTRUCTOR]: "In the next 2 hours, you will learn to control
# this environment. Let's begin!"
```

### Fallback (if tools are missing)

```bash
# Pre-check (during break or before seminar)
which figlet lolcat cmatrix cowsay 2>/dev/null || echo "Missing tools!"

# Simple alternative if missing:
echo ""
echo "    ____    _    ____  _   _ "
echo "   | __ )  / \  / ___|| | | |"
echo "   |  _ \ / _ \ \___ \| |_| |"
echo "   | |_) / ___ \ ___) |  _  |"
echo "   |____/_/   \_\____/|_| |_|"
echo ""
echo ">>> Welcome to Operating Systems! <<<"
```

---

# SECTION 2: LIVE CODING - NAVIGATION (15 minutes)

## 2.1 Where Am I? (pwd)

### Script

```bash
# [INSTRUCTOR]: "First question in Linux: WHERE AM I?"
# [INSTRUCTOR]: "What command do you think tells us that?"
# [WAIT FOR ANSWERS]

pwd

# [OUTPUT]: /home/student
# [INSTRUCTOR]: "pwd = Print Working Directory. Remember: 'Password? Where's Directory?'"
```

### Prediction Point #1

```bash

*(Bash has ugly syntax, I admit. But it runs everywhere and that matters enormously in practice.)*

# [INSTRUCTOR]: "OK, now I'm going somewhere else..."
cd /etc

# [INSTRUCTOR]: "What will pwd display now? Write it on paper!"
# [PAUSE 5 SEC]
# [INSTRUCTOR]: "Raise your hand if you wrote /etc"

pwd
# [OUTPUT]: /etc
```

## 2.2 Navigation with cd

### Main Script

```bash
# [INSTRUCTOR]: "cd = Change Directory. Time to move around!"

# Back home
cd ~
pwd
# [OUTPUT]: /home/student

# [INSTRUCTOR]: "Tilde ~ means HOME. It's a shortcut."

# Parent directory
cd ..
pwd
# [OUTPUT]: /home

cd ..
pwd
# [OUTPUT]: /

# [INSTRUCTOR]: "We've reached the ROOT. Everything in Linux starts from here."
```

### INTENTIONAL MISTAKE #1

```bash
# [INSTRUCTOR]: "Let's go to Documents..."
cd documents
# [OUTPUT]: bash: cd: documents: No such file or directory

# [INSTRUCTOR]: "Oops! What happened?"
# [WAIT FOR ANSWERS]

# [INSTRUCTOR]: "Linux is CASE-SENSITIVE! documents ≠ Documents"
cd ~
cd Documents
pwd
# [OUTPUT]: /home/student/Documents
```

### The cd - Shortcut

```bash
# [INSTRUCTOR]: "Now a very useful trick..."
cd /var/log
pwd
# [OUTPUT]: /var/log

# [INSTRUCTOR]: "How do I quickly go back home and back?"
cd -
pwd
# [OUTPUT]: /home/student/Documents

cd -
pwd
# [OUTPUT]: /var/log

# [INSTRUCTOR]: "cd - toggles between the last two locations!"
```

## 2.3 Listing with ls

### Script

```bash
cd ~

# [INSTRUCTOR]: "ls = list. Let's see what we have at home."
ls
# [OUTPUT]: Desktop Documents Downloads ...

# [INSTRUCTOR]: "But this doesn't tell us much. Let's get details!"
ls -l
# [EXPLAIN each column]

# [INSTRUCTOR]: "Notice some files are missing. Where's .bashrc?"
ls -la
# [INSTRUCTOR]: "Option -a shows HIDDEN files - those starting with a dot"
```

### Prediction Point #2

```bash
# [INSTRUCTOR]: "What difference do you think there is between these two?"
# [WRITE ON BOARD]: ls -l vs ls -lh

ls -l /var/log
# [Shows sizes in bytes]

ls -lh /var/log
# [Shows KB, MB]

# [INSTRUCTOR]: "h = human-readable. 1048576 vs 1M - which do you prefer?"
```

---

# SECTION 3: LIVE CODING - FILE MANIPULATION (10 minutes)

## 3.1 Creating Files and Directories

### Script

```bash
# [INSTRUCTOR]: "Let's create a project from scratch!"

# Create workspace
cd ~
mkdir laboratory
cd laboratory

# [INSTRUCTOR]: "What do you think the following command does?"
mkdir -p project/{src,docs,tests}

# [PAUSE - PREDICTION]

ls -R
# [OUTPUT]:
# project/
# project/docs
# project/src
# project/tests

# [INSTRUCTOR]: "Braces {} create MULTIPLE directories!"
```

### Touch and Echo

```bash
cd project

# [INSTRUCTOR]: "We create empty files with touch"
touch src/main.c
touch README.md

# [INSTRUCTOR]: "And files with content using echo + redirect"
echo "# OS Laboratory Project" > README.md

cat README.md
# [OUTPUT]: # OS Laboratory Project

# [INSTRUCTOR]: "A single > overwrites. Two >> appends."
echo "Author: Student" >> README.md
cat README.md
```

## 3.2 Copy and Move

### INTENTIONAL MISTAKE #2

```bash
# [INSTRUCTOR]: "Let's copy the src directory..."
cp src backup_src
# [OUTPUT]: cp: -r not specified; omitting directory 'src'

# [INSTRUCTOR]: "Error! What's missing?"
# [WAIT]

cp -r src backup_src
ls
# [It works!]

# [INSTRUCTOR]: "For DIRECTORIES, cp needs -r (recursive)"
```

### Rename vs Move

```bash
# [INSTRUCTOR]: "mv does two things: moves AND renames"

# Rename (same directory)
mv README.md READ-ME.md
ls
# README.md became READ-ME.md

# Move (different directory)
mv READ-ME.md docs/
ls docs/
# READ-ME.md is now in docs/
```

## 3.3 Deletion (with caution!)

### Script

```bash
# [INSTRUCTOR]: "rm = remove. Trap: there's no Recycle Bin!"

# Safe demonstration
touch test_file.txt
ls
rm test_file.txt
ls
# [Gone permanently]

# [INSTRUCTOR]: "For safety, use -i"
touch another_test.txt
rm -i another_test.txt
# [Asks for confirmation]
# y

# Directory
mkdir test_dir
rm test_dir
# [Error: Is a directory]

rm -r test_dir
# [It works]
```

### WARNING (DO NOT EXECUTE!)

```bash
# [INSTRUCTOR]: "A command we will NEVER run directly:"
# [WRITE ON BOARD, NOT IN TERMINAL]
# rm -rf /
# rm -rf $EMPTY_VARIABLE/

# [INSTRUCTOR]: "If the variable is empty, it deletes everything from root!"
# [INSTRUCTOR]: "ALWAYS check with echo before rm -rf"
```

---

# SECTION 4: LIVE CODING - VARIABLES (15 minutes)

## 4.1 Local Variables

### Script

```bash
cd ~

# [INSTRUCTOR]: "Variables store values. The syntax is simple:"
NAME="John"
echo $NAME
# [OUTPUT]: John
```

### INTENTIONAL MISTAKE #3 (Crucial!)

```bash
# [INSTRUCTOR]: "Let's set the age..."
AGE = 25
# [OUTPUT]: bash: AGE: command not found

# [INSTRUCTOR]: "Error! Anyone see the problem?"
# [PAUSE]
# [INSTRUCTOR]: "SPACES! Bash thinks AGE is a COMMAND."

AGE=25
echo $AGE
# [OUTPUT]: 25

# [INSTRUCTOR]: "Rule: NEVER spaces around ="
```

### Prediction Point #3

```bash
# [INSTRUCTOR]: "What will the following command display?"
# [WRITE ON BOARD]:
# MESSAGE="Hello world"
# echo $MESSAGE in 2024

MESSAGE="Hello world"
echo $MESSAGE in 2024
# [OUTPUT]: Hello world in 2024

# [INSTRUCTOR]: "And this?"
echo "$MESSAGE in 2024"
# [OUTPUT]: Hello world in 2024

# [INSTRUCTOR]: "The subtle difference appears with multiple spaces..."
```

## 4.2 Export and Subprocesses

### Script

```bash
# [INSTRUCTOR]: "Local variables are not visible in subprocesses!"

LOCAL="local value"
bash -c 'echo "Local: $LOCAL"'
# [OUTPUT]: Local: (empty!)

# [INSTRUCTOR]: "Let's export it..."
export GLOBAL="global value"
bash -c 'echo "Global: $GLOBAL"'
# [OUTPUT]: Global: global value

# [INSTRUCTOR]: "export = makes the variable visible to child processes"
```

### Viewing System Variables

```bash
# [INSTRUCTOR]: "Let's see what variables we already have set:"

echo "User: $USER"
echo "Home: $HOME"
echo "Shell: $SHELL"
echo "PATH: $PATH"

# [INSTRUCTOR]: "PATH is special - this is where Bash looks for commands!"
```

## 4.3 Exit Code ($?)

### Script

```bash
# [INSTRUCTOR]: "Every command returns an exit code"

ls /home
echo "Exit code: $?"
# [OUTPUT]: Exit code: 0

# [INSTRUCTOR]: "0 = SUCCESS. Now let's cause an error..."

ls /nonexistent_directory
echo "Exit code: $?"
# [OUTPUT]:
# ls: cannot access '/nonexistent_directory': No such file or directory
# Exit code: 2

# [INSTRUCTOR]: "Non-zero = ERROR. Each number has a specific meaning."
```

---

# SECTION 5: LIVE CODING - QUOTING (10 minutes)

## 5.1 Single vs Double Quotes

### Fundamental Demonstration

```bash
# [INSTRUCTOR]: "This is one of the most confusing parts. Pay attention!"

NAME="Student"

# [WRITE THE 3 VARIANTS ON BOARD]
# echo 'Hello $NAME'
# echo "Hello $NAME"
# echo Hello $NAME

# [INSTRUCTOR]: "Prediction: what will EACH display?"
# [PAUSE 10 SEC for thinking]
```

### AHA MOMENT!

```bash
# Single quotes - LITERAL
echo 'Hello $NAME'
# [OUTPUT]: Hello $NAME

# Double quotes - EXPANDS
echo "Hello $NAME"
# [OUTPUT]: Hello Student

# No quotes - EXPANDS + word splitting
echo Hello    $NAME
# [OUTPUT]: Hello Student (spaces were compressed!)
```

### Visual Table

```bash
# [DRAW ON BOARD]:
#
# 'single' Everything is LITERAL - nothing changes
# "double" $variables ARE expanded
# nothing  Expansion + spaces compressed
#
```

## 5.2 Practical Problem: Files with Spaces

### INTENTIONAL MISTAKE #4

```bash
# Create a file with spaces in the name
touch "Important Document.txt"
ls
# [OUTPUT]: Important Document.txt

# [INSTRUCTOR]: "How do you think we delete it?"

FILE=Important Document.txt
rm $FILE
# [OUTPUT]: rm: cannot remove 'Important': No such file or directory

# [INSTRUCTOR]: "Bash saw TWO arguments! The solution?"

FILE="Important Document.txt"
rm "$FILE"
ls
# [Gone correctly]

# [INSTRUCTOR]: "RULE: Always put variables in double quotes!"
```

---

# SECTION 6: LIVE CODING - SHELL CONFIGURATION (12 minutes)

## 6.1 Exploring .bashrc

### Script

```bash
cd ~

# [INSTRUCTOR]: "The magic file that personalises the shell:"
cat ~/.bashrc | head -30

# [INSTRUCTOR]: "It's run every time you open a new terminal"

# [INSTRUCTOR]: "Let's modify it! But FIRST - backup!"
cp ~/.bashrc ~/.bashrc.backup

# [INSTRUCTOR]: "ALWAYS backup before editing configurations!"
```

## 6.2 Adding an Alias

### Script

```bash
# [INSTRUCTOR]: "Let's add a useful alias..."

# Open for editing
nano ~/.bashrc

# [NAVIGATE TO END]
# [ADD]:
# # Custom aliases
# alias ll='ls -la'
# alias cls='clear'
# alias ..='cd ..'

# [SAVE: Ctrl+O, Enter, Ctrl+X]

# [INSTRUCTOR]: "Saved. Let's test..."
ll
# [OUTPUT]: bash: ll: command not found

# [INSTRUCTOR]: "Doesn't work! Why?"
# [WAIT FOR ANSWERS]

# [INSTRUCTOR]: "We need to RELOAD the configuration!"
source ~/.bashrc

ll
# [WORKS NOW!]
```

## 6.3 Useful Functions

### mkcd - mkdir + cd

```bash
# [INSTRUCTOR]: "Aliases cannot receive arguments. For that we have functions!"

# [IN ~/.bashrc add]:
# mkcd() {
# mkdir -p "$1" && cd "$1"
# }

# [SAVE and RELOAD]
source ~/.bashrc

# [DEMO]
mkcd test_project
pwd
# [OUTPUT]: /home/student/test_project

# [INSTRUCTOR]: "We created the directory AND entered it with a single command!"
```

## 6.4 PS1 Personalisation

### Script

```bash
# [INSTRUCTOR]: "PS1 controls what the prompt looks like"

# Save the original
OLD_PS1="$PS1"

# Test variants
PS1='$ '
# [Minimal prompt]

PS1='[\t] \u:\W$ '
# [With time and short directory]

PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
# [With colours!]

# [INSTRUCTOR]: "If you don't like it, restore:"
PS1="$OLD_PS1"
```

---

# SECTION 7: LIVE CODING - GLOBBING (8 minutes)

## 7.1 Test Data Setup

```bash
cd ~
mkdir glob_demo && cd glob_demo

# Create test files
touch file{1..5}.txt
touch doc{A..C}.pdf
touch image{01..03}.jpg
touch .hidden_file

ls
# [OUTPUT]: doc*.pdf file*.txt image*.jpg

ls -a
# [Includes .hidden_file]
```

## 7.2 Asterisk Wildcard

```bash
# [INSTRUCTOR]: "Asterisk * means 'any string of characters'"

ls *.txt
# [OUTPUT]: file1.txt file2.txt file3.txt file4.txt file5.txt

ls doc*
# [OUTPUT]: docA.pdf docB.pdf docC.pdf

ls *1*
# [OUTPUT]: file1.txt image01.jpg
```

## 7.3 Question Mark Wildcard

### Prediction Point #4

```bash
# [INSTRUCTOR]: "What's the difference between * and ?"
# [ON BOARD]: ls file*.txt vs ls file?.txt

ls file*.txt
# [OUTPUT]: file1.txt file2.txt file3.txt file4.txt file5.txt

ls file?.txt
# [OUTPUT]: file1.txt file2.txt file3.txt file4.txt file5.txt

# [INSTRUCTOR]: "They look the same. But if we add file10.txt?"
touch file10.txt

ls file*.txt
# [Includes file10.txt]

ls file?.txt
# [Does NOT include file10.txt!]

# [INSTRUCTOR]: "? = EXACTLY one character. * = zero or more"
```

## 7.4 Square Brackets

```bash
# [INSTRUCTOR]: "Square brackets select one character from a set"

ls file[135].txt
# [OUTPUT]: file1.txt file3.txt file5.txt

ls file[1-3].txt
# [OUTPUT]: file1.txt file2.txt file3.txt

ls doc[A-Z].pdf
# [OUTPUT]: docA.pdf docB.pdf docC.pdf

# Negation
ls file[!1-3].txt
# [OUTPUT]: file4.txt file5.txt
```

### Beware of Hidden Files

```bash
# [INSTRUCTOR]: "Trap: * does NOT include hidden files!"
ls *
# [Does NOT show .hidden_file]

ls .*
# [ONLY hidden files]

ls -a
# [All]
```

---

# SECTION 8: FINAL DEMOS (5 minutes)

## 8.1 Impressive One-liner

```bash
# [INSTRUCTOR]: "Let's see the power of combining commands..."

# Find the 5 largest files in home
find ~ -type f -exec du -h {} + 2>/dev/null | sort -rh | head -5

# [INSTRUCTOR]: "This searches all files, calculates size,
# sorts descending and shows the first 5."
```

## 8.2 Mini System Dashboard

```bash
# [INSTRUCTOR]: "A mini system dashboard:"

echo "=== SYSTEM ===" && \
uname -a && echo && \
echo "=== USER ===" && \
whoami && echo && \
echo "=== MEMORY ===" && \
free -h && echo && \
echo "=== DISK ===" && \
df -h / && echo && \
echo "=== ACTIVE PROCESSES ===" && \
ps aux | wc -l

# [INSTRUCTOR]: "In the following seminars you will learn to do
# even more with these commands!"
```

## 8.3 Closing

```bash
# [INSTRUCTOR]: "Let's end as we began..."

figlet "THE END" | lolcat

# [OR FALLBACK]:
echo ""
echo "  _____ _   _ _____   _____ _   _ ____  "
echo " |_   _| | | | ____| | ____| \ | |  _ \ "
echo "   | | | |_| |  _|   |  _| |  \| | | | |"
echo "   | | |  _  | |___  | |___| |\  | |_| |"
echo "   |_| |_| |_|_____| |_____|_| \_|____/ "
echo ""
echo ">>> Thank you for your attention! <<<"
```

---

# APPENDIX A: PRE-SEMINAR CHECKLIST

## Technical Checks

```bash
# Run before seminar to verify tools

echo "=== Tools Check ==="
for tool in figlet lolcat cmatrix cowsay tree ncdu pv dialog; do
    if command -v $tool &>/dev/null; then
        echo "✓ $tool installed"
    else
        echo "✗ $tool MISSING - install with: sudo apt install $tool"
    fi
done

echo ""
echo "=== Configuration Check ==="
echo "User: $USER"
echo "Home: $HOME"
echo "Shell: $SHELL"

echo ""
echo "=== Demo Files Check ==="
ls -la ~/laboratory 2>/dev/null || echo "Directory ~/laboratory doesn't exist (OK)"
```

## Installing Missing Tools

```bash
sudo apt update
sudo apt install -y figlet lolcat cmatrix cowsay tree ncdu pv dialog
```

---

# APPENDIX B: TIMING CHEATSHEET

| Section | Duration | Total Minutes |
|---------|----------|---------------|
| Hook Demo | 3 min | 0-3 |
| Navigation | 15 min | 3-18 |
| PI Q1 (Shell) | 5 min | 18-23 |
| File Manipulation | 10 min | 23-33 |
| **BREAK** | 10 min | 33-43 |
| Variables | 15 min | 43-58 |
| Quoting | 10 min | 58-68 |
| PI Q2 (Quoting) | 5 min | 68-73 |
| Shell Configuration | 12 min | 73-85 |
| Globbing | 8 min | 85-93 |
| Final Demo | 5 min | 93-98 |
| Reflection | 2 min | 98-100 |

---

# APPENDIX C: INTENTIONAL ERRORS - SUMMARY

| # | Error | Moment | Lesson |
|---|-------|--------|--------|
| 1 | `cd documents` (case) | Navigation | Linux is case-sensitive |
| 2 | `cp src backup` (without -r) | Copy | Directories require -r |
| 3 | `AGE = 25` (spaces) | Variables | No spaces in assignment |
| 4 | `rm $FILE` (without quotes) | Quoting | Quotes for spaces |

---

# APPENDIX D: PREDICTION ANSWERS

| # | Prediction | Answer | Explanation |
|---|------------|--------|-------------|
| 1 | pwd after cd /etc | /etc | Absolute path |
| 2 | ls -l vs ls -lh | bytes vs KB/MB | h = human-readable |
| 3 | echo $MESSAGE in 2024 | Hello world in 2024 | Variable expands |
| 4 | file?.txt vs file*.txt | ? = 1 char, * = any | file10.txt: only * |

---

*Live Coding Guide for Seminar 1-2 OS | ASE Bucharest - CSIE*
