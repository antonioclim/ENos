# Live Coding Guide - Seminar 3-4
## Operating Systems | Operators, Redirection, Filters, Loops

Total live coding duration: ~45-50 minutes (distributed throughout the seminar)  
Style: Incremental, with predictions and deliberate errors

---

## LIVE CODING PRINCIPLES

### The 5 Golden Rules

1. INCREMENTAL - Build step by step, don't show the final code all at once
2. PREDICTIONS - Ask "What do you think happens?" BEFORE execution
3. DELIBERATE ERRORS - Make intentional mistakes to demonstrate common problems
4. NARRATION - Verbalise what you're doing and why ("Now I'm adding && because...")
5. REDUCED SPEED - Type slower than normal, give time to process

### Structure of Each Segment

```
┌─────────────────────────────────────────────────────────────┐
│  1. ANNOUNCE   - "Now we'll see how... works"              │
│  2. PREDICTION - "What do you think happens if...?"        │
│  3. EXECUTION  - Run the command                           │
│  4. EXPLANATION - "Notice that... because..."              │

> 💡 I've observed that students who draw the diagram on paper before writing code achieve much better results.

│  5. VARIATION  - "But what if we change X?"                │
└─────────────────────────────────────────────────────────────┘
```

---

## INITIAL SETUP

### Environment Preparation (Run before the seminar!)

```bash
#!/bin/bash
# === COMPLETE SETUP FOR DEMO ===

# Cleanup and create working directory
rm -rf ~/demo_seminar34 2>/dev/null
mkdir -p ~/demo_seminar34
cd ~/demo_seminar34

# Short PS1 for demo (more visible)
export PS1='\[\e[1;32m\]demo\[\e[0m\]:\[\e[1;34m\]\W\[\e[0m\]$ '

# Create test files
cat > colours.txt << 'EOF'
red
green
red
blue
green
red
yellow
blue
EOF

cat > numbers.txt << 'EOF'
42
7
99
15
3
88
23
EOF

cat > students.csv << 'EOF'
name,group,grade
Popescu Ion,1234,9
Ionescu Maria,1234,10
Georgescu Ana,1235,8
Vasilescu Dan,1235,7
Marinescu Eva,1234,9
EOF

cat > access.log << 'EOF'
192.168.1.1 - - [10/Jan/2025:10:00:01] "GET /index.html" 200
192.168.1.2 - - [10/Jan/2025:10:00:02] "GET /style.css" 200
192.168.1.1 - - [10/Jan/2025:10:00:03] "POST /login" 401
192.168.1.3 - - [10/Jan/2025:10:00:04] "GET /admin" 403
192.168.1.1 - - [10/Jan/2025:10:00:05] "POST /login" 200
192.168.1.2 - - [10/Jan/2025:10:00:06] "GET /dashboard" 200
192.168.1.4 - - [10/Jan/2025:10:00:07] "GET /api/data" 500
EOF

cat > text.txt << 'EOF'
Linux is an open source operating system.
The Bash shell enables task automation.
Pipes connect commands together.
Filters process text line by line.
Linux is used on servers and desktops.
EOF

echo "✓ Setup complete! Files created:"
ls -la
```

---

## SESSION 1: CONTROL OPERATORS (15 min)

### Step 1: Welcome to the Demo (1 min)

```bash
# SAY: "Let's verify that we have everything prepared..."
cd ~/demo_seminar34
pwd
ls
```

### Step 2: Sequential Operator `;` (2 min)

SAY: "The simplest way to combine commands: semicolon."

```bash
# PREDICTION: "What do you think happens?"
echo "First" ; echo "Second" ; echo "Third"
```

EXPLANATION: "All three execute, one after another. Simple, right?"

```bash
# PREDICTION: "But what if one in the middle fails?"
echo "Start" ; ls /nonexistent_directory ; echo "Continuing"
```

EXPLANATION: "Notice! Even though ls fails, echo 'Continuing' still runs. The semicolon does NOT check whether the previous command succeeded."

### Step 3: AND Operator `&&` (3 min)

SAY: "Now let's see what happens when we care about the result..."

```bash
# PREDICTION: "What does this display?"
mkdir project && echo "Directory created!"
```

EXPLANATION: "mkdir succeeded, so && allowed echo to run."

```bash

*(Bash has ugly syntax, I admit. But it runs everywhere, and that matters enormously in practice.)*

# PREDICTION: "But what if I run the same command again?"
mkdir project && echo "Created again!"
```

EXPLANATION: "Ah-ha! This time mkdir FAILS (the directory already exists), so echo does NOT run. This is the difference from semicolon!"

```bash
# Visual demonstration of the difference
rm -rf project  # cleanup

# With ;
mkdir project ; mkdir project ; echo "After two mkdirs with ;"
# Error, but echo runs

rm -rf project  # cleanup

# With &&
mkdir project && mkdir project && echo "After two mkdirs with &&"
# Error appears, echo does NOT run
```

### Step 4: OR Operator `||` (3 min)

SAY: "OR is the inverse of AND - it runs only if the previous one FAILS."

```bash
rm -rf project  # cleanup

# PREDICTION: "What happens here?"
mkdir project || echo "Directory already exists"
```

EXPLANATION: "mkdir succeeded, so || does NOT trigger echo."

```bash
# PREDICTION: "But now?"
mkdir project || echo "Directory already exists"
```

EXPLANATION: "The second time mkdir fails, so || triggers our fallback message."

### Step 5: Combining && and || (3 min)

SAY: "Now comes the interesting part - we combine them!"

```bash
rm -rf project  # cleanup

# Classic pattern: success && ok_message || error_message
mkdir project && echo "✓ Created!" || echo "✗ Error!"
```

```bash
# PREDICTION: "But what if I run again?"
mkdir project && echo "✓ Created!" || echo "✗ Error!"
```

EXPLANATION: "This is the pattern you'll use most often in scripts - do something and report whether it succeeded or not."

> 💡 *I've observed that students who draw the diagram on paper before writing code achieve much better results.*


### Step 6: DELIBERATE ERROR - Order Matters! (3 min)

SAY: "Now I'll show you a mistake that ALL beginners make..."

```bash
rm -rf test_err  # cleanup

# WRITE INTENTIONALLY WRONG:
mkdir test_err || echo "Error" && echo "Success"
```

ASK: "It works correctly. But what happens if mkdir fails?"

```bash
# Don't delete test_err, run again:
mkdir test_err || echo "Error" && echo "Success"
```

SURPRISE: Both "Error" AND "Success" appear!

EXPLANATION: 
```
"Evaluation is left to right:
1. mkdir fails
2. || triggers echo 'Error' (which SUCCEEDS!)
3. && sees that echo succeeded, so triggers 'Success'

THE CORRECT ORDER is: command && success || error"
```

```bash
rm -rf test_err  # cleanup
mkdir test_err && echo "Success" || echo "Error"  # First time: 
mkdir test_err && echo "Success" || echo "Error"  # Second: Error

> 💡 In exams from previous sessions, this question has consistently appeared — so it's worth attention.

```

---

## SESSION 2: I/O REDIRECTION (10 min)

### Step 1: Output to File `>` (2 min)

```bash
cd ~/demo_seminar34

# SAY: "Let's see how we save output to a file..."
echo "First line" > output.txt
cat output.txt
```

```bash
# PREDICTION: "What happens if I write again?"
echo "Second line" > output.txt
cat output.txt
```

EXPLANATION: "The first line disappeared! `>` OVERWRITES the file completely."

### Step 2: Append `>>` (2 min)

```bash
# SAY: "If we want to ADD, we use >>"
echo "First line" > output.txt
echo "Second line" >> output.txt
echo "Third line" >> output.txt
cat output.txt
```

EXPLANATION: "Now we have all three lines. `>>` appends at the end."

### Step 3: stderr vs stdout (3 min)

```bash

*Personal note: Many prefer `zsh`, but I stick with Bash because it's the standard on servers. Consistency beats comfort.*

# SAY: "Now the more complicated part - errors have their own channel."

# PREDICTION: "What do we see here?"
ls /home /nonexistent_directory
```

EXPLANATION: "We see two DIFFERENT things: the listing of /home (stdout) and the error (stderr). Both go to the screen, but they are separate channels."

```bash
# Redirect only stdout
ls /home /nonexistent_directory > only_output.txt
cat only_output.txt
# The error STILL appears on screen!
```

```bash
# Redirect only stderr
ls /home /nonexistent_directory 2> only_errors.txt
cat only_errors.txt
# Output appears on screen, error is in the file
```

```bash
# Redirect both to DIFFERENT files
ls /home /nonexistent_directory > output.txt 2> errors.txt
cat output.txt
cat errors.txt
```

### Step 4: Combining stdout and stderr (3 min)

SAY: "Now the tricky part - how do we put both in the same file?"

```bash
# PREDICTION: "Does this work?"
ls /home /nonexistent_directory > everything.txt 2>&1
cat everything.txt
```

EXPLANATION: "Yes! `2>&1` means 'send stderr (2) where stdout (1) goes'."

```bash
# COMMON MISTAKE - reverse order:
ls /home /nonexistent_directory 2>&1 > everything2.txt
cat everything2.txt
# The error appeared on screen!
```

EXPLANATION: 
```
"Order matters!
CORRECT:  > file 2>&1   (stdout→file, then stderr→where stdout is)
WRONG:    2>&1 > file   (stderr→stdout(screen), then stdout→file)

Or use the shortcut: &> file"
```

```bash
ls /home /nonexistent_directory &> everything3.txt
cat everything3.txt
```

---

## SESSION 3: PIPELINES AND FILTERS (15 min)

### Step 1: The First Pipe (2 min)

```bash
cd ~/demo_seminar34

# SAY: "The pipe connects the output of one command to the input of another."

# Simple: how many lines does /etc/passwd have?
cat /etc/passwd | wc -l
```

```bash
# Equivalent but MORE EFFICIENT:
wc -l < /etc/passwd
# Why? We don't create an extra process for cat.
```

### Step 2: Incremental Construction (4 min)

SAY: "Let's build a complex pipeline, step by step."

```bash
# OBJECTIVE: Top 5 users by number of processes

# Step 1: List processes
ps aux

# Step 2: Extract only the user column (first)
ps aux | awk '{print $1}'

# Step 3: Sort (REQUIRED for uniq!)
ps aux | awk '{print $1}' | sort

# Step 4: Count duplicates
ps aux | awk '{print $1}' | sort | uniq -c

# Step 5: Sort by count (descending)
ps aux | awk '{print $1}' | sort | uniq -c | sort -rn

# Step 6: Take the first 5
ps aux | awk '{print $1}' | sort | uniq -c | sort -rn | head -5
```

EXPLANATION: "Each step adds a modification. It's like an assembly line!"

### Step 3: The uniq Trap (3 min)

SAY: "Now a trap that 80% of beginners fall into..."

```bash
# PREDICTION: "How many unique colours do we have?"
cat colours.txt

# WRONG:
cat colours.txt | uniq
```

SURPRISE: Duplicates still appear!

EXPLANATION: "uniq only removes CONSECUTIVE duplicates. Without sort, it doesn't work!"

```bash
# CORRECT:
cat colours.txt | sort | uniq
```

```bash
# With counting and sorting by frequency:
cat colours.txt | sort | uniq -c | sort -rn
```

### Step 4: cut for CSV (3 min)

```bash
# SAY: "Let's work with structured data..."
cat students.csv

# Extract only names (column 1)
cut -d',' -f1 students.csv

# Extract name and grade
cut -d',' -f1,3 students.csv

# Without header
tail -n +2 students.csv | cut -d',' -f1
```

Trap:
```bash
# COMMON MISTAKE: the default delimiter is TAB!
cut -f1 students.csv  # Doesn't work as expected
# ALWAYS specify: -d','
```

### Step 5: tr for Modifications (3 min)

```bash
# SAY: "tr works with CHARACTERS, not strings!"

# Lowercase → uppercase
echo "hello world" | tr 'a-z' 'A-Z'

# PREDICTION: "What does this do?"
echo "hello" | tr 'aeiou' '12345'
```

```bash
# COMMON MISTAKE: thinks it replaces strings
echo "hello" | tr 'he' 'HE'
# Output: HEllo (each character separately!)
# For strings, use sed: sed 's/he/HE/g'
```

---

## SESSION 4: LOOPS (15 min)

### Step 1: for with List (3 min)

```bash
cd ~/demo_seminar34

# SAY: "The for loop iterates through elements..."

# Explicit list
for colour in red green blue; do
    echo "Colour: $colour"
done
```

```bash
# With brace expansion
for i in {1..5}; do
    echo "Number: $i"
done
```

```bash
# With files (globbing)
for file in *.txt; do
    echo "File: $file ($(wc -l < "$file") lines)"
done
```

### Step 2: DELIBERATE ERROR - Brace Expansion with Variables (4 min)

SAY: "Now I'll show you the most frequent mistake with loops..."

```bash
# PREDICTION: "What does this display?"
N=5
for i in {1..$N}; do
    echo $i
done
```

SURPRISE: Output: `{1..5}` - literally!

EXPLANATION: 
```
"Brace expansion happens at PARSE TIME, BEFORE variables are evaluated!
The shell sees {1..$N}, but $N isn't expanded yet, so it doesn't know to make 1,2,3,4,5."
```

```bash
# SOLUTION 1: seq
for i in $(seq 1 $N); do
    echo $i
done

# SOLUTION 2: C-style for (RECOMMENDED)
for ((i=1; i<=N; i++)); do
    echo $i
done
```

### Step 3: while (2 min)

```bash
# Simple counter
count=1
while [ $count -le 5 ]; do
    echo "Count: $count"
    ((count++))
done
```

### Step 4: Reading a File (3 min)

```bash
# SAY: "The correct method to read a file line by line..."

# The CORRECT method
while IFS= read -r line; do
    echo "Line: $line"
done < colours.txt
```

```bash
# IFS= : preserves spaces
# -r : doesn't interpret backslash
```

### Step 5: DELIBERATE ERROR - The Subshell Problem (3 min)

SAY: "Now the most FRUSTRATING problem for beginners..."

```bash
# PREDICTION: "What value will total have at the end?"
total=0
cat colours.txt | while read line; do
    ((total++))
    echo "In loop: total=$total"
done
echo "After loop: total=$total"
```

SURPRISE: After loop: total=0!

EXPLANATION:
```
"The pipe | creates a SUBSHELL - a separate child process!
Variables modified in the subshell are NOT visible in the parent shell.

while read ... done RUNS IN SUBSHELL ← here's the problem!"
```

```bash
# SOLUTION: redirection instead of pipe
total=0
while read line; do
    ((total++))
done < colours.txt
echo "Correct: total=$total"
```

```bash
# OR: Process Substitution (Bash 4+)
total=0
while read line; do
    ((total++))
done < <(cat colours.txt)
echo "This also works: total=$total"
```

---

## SPECTACULAR DEMOS (For Hook/Breaks)

### Demo 1: Visual Countdown

```bash
# Countdown with clear
for i in {5..1}; do
    clear
    echo ""
    echo "    ╔═══════════════╗"
    echo "    ║               ║"
    echo "    ║       $i       ║"
    echo "    ║               ║"
    echo "    ╚═══════════════╝"
    sleep 1
done
clear
echo ""
echo "    ╔═══════════════╗"
echo "    ║               ║"
echo "    ║    START!     ║"
echo "    ║               ║"
echo "    ╚═══════════════╝"
```

### Demo 2: Loading Spinner

```bash
# Loading spinner
echo -n "Processing: "
chars="/-\\|"
for i in {1..20}; do
    echo -ne "\b${chars:i%4:1}"
    sleep 0.1
done
echo -e "\b✓ Complete!"
```

### Demo 3: Live System Analysis

```bash
# Spectacular one-liner
echo "=== TOP 5 PROCESSES BY MEMORY ===" && \
ps aux --sort=-%mem | head -6 | \
awk 'NR==1 {printf "%-10s %5s %s\n", "USER", "MEM%", "COMMAND"} 
     NR>1  {printf "%-10s %5s %s\n", $1, $4, $11}'
```

### Demo 4: Pipeline Power

```bash
# Find the 5 largest files in /usr
echo "=== TOP 5 FILES IN /usr ===" && \
find /usr -type f -printf '%s %p\n' 2>/dev/null | \
sort -rn | head -5 | \
while read size path; do
    printf "%'15d bytes → %s\n" "$size" "$path"
done
```

---

## CHEAT SHEET FOR INSTRUCTOR

### Frequent Demo Commands

```bash
# Quick cleanup
rm -rf ~/demo_seminar34/* 2>/dev/null

# Reset test files
# (run the setup script again)

# Quick check of what exists
ls -la ~/demo_seminar34/

# Clear with header
clear; echo "=== DEMO: [NAME] ===" 
```

### When Things Go Wrong

| Problem | Quick Solution |
|---------|----------------|
| File doesn't exist | `ls -la` and recreate |
| Command not found | `which cmd` or `type cmd` |
| Permissions | `chmod +x script.sh` |
| Wrong syntax | Check spaces in `[ ]`, `;` before `do` |
| Empty variable | `echo "VAR=[$VAR]"` for debug |

### Transitions Between Sections

```
"Now that we've seen X, let's move on to Y which builds on what we just learned..."

"Before we continue, does anyone have questions about X?"

"Notice how Y is actually similar to X, just that..."
```

---

## LIVE CODING TROUBLESHOOTING

### If the Command Doesn't Work

1. Don't panic - students learn from errors
2. Verbalise: "Hmm, let's see what happened..."
3. Debug live: `echo $?`, `echo "$variable"`
4. Learn from the mistake: "Ah, I forgot to... This is a common mistake!"

### If You Lose Track

1. Recap: "So, what have we done so far..."
2. Check files: `ls`, `cat file`
3. Restart from a known point

### If Students Are Confused

1. Stop: "Let's clarify..."
2. Draw: Diagram on the board
3. Simplify: Smaller example
4. Repeat: In other words

---

*Live Coding Guide generated for ASE Bucharest - CSIE*  
*Seminar 2: Operators, Redirection, Filters, Loops*
