# Sprint Exercises - Seminar 1-2
## Operating Systems | Shell Basics & Configuration

**Format**: 10-15 minute sprints with verifiable micro-milestones  
**Working style**: Pair Programming (switch roles at halfway)

> One student last year tried to `cd` into a file — the error message confused them for 10 minutes until we drew the tree structure on the whiteboard. That's when I realised how important it is to visualise the file system before typing commands.

---

## SPRINT STRUCTURE

Each sprint has:
- ⏱️ **Fixed total time**
- 🎯 **Clear objective**
- ✓ **Verifiable checkpoints**
- 🔄 **Switch point** for Driver/Navigator change
- 🚀 **Extension** for those who finish early

---

## SPRINT 1: The System Explorer
**Time**: 12 minutes | **Level**: Beginner

```
══════════════════════════════════════════════════════════════
🎯 OBJECTIVE: Explore the file hierarchy and document findings
══════════════════════════════════════════════════════════════

FORM PAIRS! 
├── Min 0-6:  Student A = Driver, Student B = Navigator
└── Min 6-12: SWITCH!

───────────────────────────────────────────────────────────────
📍 MILESTONE 1 (3 min): Verify identity
───────────────────────────────────────────────────────────────
1. Display the current user
2. Display the home directory
3. Display the shell being used

✓ CHECKPOINT: You have 3 pieces of information: user, home path, shell name
───────────────────────────────────────────────────────────────

───────────────────────────────────────────────────────────────
📍 MILESTONE 2 (3 min): Explore the root
───────────────────────────────────────────────────────────────
4. Navigate to the root directory /
5. List contents with details
6. Identify 3 important directories and their purpose

✓ CHECKPOINT: You can name the purpose of /etc, /home, /var
───────────────────────────────────────────────────────────────

🔄 SWITCH ROLES NOW!

───────────────────────────────────────────────────────────────
📍 MILESTONE 3 (3 min): /etc Investigation
───────────────────────────────────────────────────────────────
7. Enter /etc
8. Find the passwd file and display the first 5 lines
9. Find the hosts file and display its contents

✓ CHECKPOINT: You understand the /etc/passwd format (user:x:uid:gid:...)
───────────────────────────────────────────────────────────────

───────────────────────────────────────────────────────────────
📍 MILESTONE 4 (3 min): Documentation
───────────────────────────────────────────────────────────────
10. Return to home
11. Create file "exploration.txt"
12. Write what you discovered (minimum 3 observations)

✓ FINAL CHECKPOINT: cat exploration.txt shows your observations
───────────────────────────────────────────────────────────────

🚀 EXTENSION (if you finished early):

**Difficulty:** ★★★☆☆

Choose one challenge:

1. **One-liner Challenge:** Display user, home and shell in ONE command
   ```bash
   # Hint: echo "User: $(whoami), Home: $HOME, Shell: $SHELL"
   ```

2. **Data Analysis:** Find how many users have bash shell in /etc/passwd
   ```bash
   # Hint: grep bash /etc/passwd | wc -l
   ```

3. **Peer Teaching:** Explain to another pair what each field in 
   /etc/passwd means (without giving them the answer to their sprint)

4. **Error Exploration:** What happens if you try `cd /etc/passwd`? 
   Why? Document the error message.

══════════════════════════════════════════════════════════════
```

### ✅ Success Criteria — Sprint 1

You have successfully completed this sprint when:
- [ ] Running `whoami && echo $HOME && echo $SHELL` produces three distinct pieces of information
- [ ] You can explain what `/etc` and `/var` contain without looking at notes
- [ ] `cat ~/exploration.txt` displays at least 3 observations
- [ ] Total time: under 12 minutes

### Solutions for instructor:
```bash
# M1
whoami
echo $HOME
echo $SHELL

# M2
cd /
ls -la
# /etc = configurations, /home = users, /var = variable data

# M3
cd /etc
head -5 passwd
cat hosts

# M4
cd ~
touch exploration.txt
echo "1. /etc contains system configurations" > exploration.txt
echo "2. /home has user directories" >> exploration.txt
echo "3. passwd has user information" >> exploration.txt

# Extension
grep bash /etc/passwd | wc -l
```

---

## SPRINT 2: The Project Architect
**Time**: 15 minutes | **Level**: Beginner-Intermediate

```
══════════════════════════════════════════════════════════════
🎯 OBJECTIVE: Build a complete project structure
══════════════════════════════════════════════════════════════

PAIR PROGRAMMING:
├── Min 0-7:  Student A = Driver
└── Min 7-15: Student B = Driver

REQUIRED FINAL STRUCTURE:
    webapp/
    ├── backend/
    │   ├── src/
    │   │   ├── app.py
    │   │   └── config.py
    │   └── tests/
    │       └── test_app.py
    ├── frontend/
    │   ├── css/
    │   │   └── style.css
    │   ├── js/
    │   │   └── main.js
    │   └── index.html
    ├── docs/
    │   └── README.md
    └── .gitignore

───────────────────────────────────────────────────────────────
📍 MILESTONE 1 (4 min): Basic structure
───────────────────────────────────────────────────────────────
Create the directory structure (no files yet).
HINT: mkdir -p can create hierarchies!

✓ CHECKPOINT: tree webapp shows all directories
───────────────────────────────────────────────────────────────

───────────────────────────────────────────────────────────────
📍 MILESTONE 2 (3 min): Backend files
───────────────────────────────────────────────────────────────
Create Python files with minimal content.

app.py:
    # Main application
    print("Hello from Flask!")

config.py:
    # Configuration
    DEBUG = True

test_app.py:
    # Tests
    def test_hello():
        pass

✓ CHECKPOINT: cat backend/src/app.py works
───────────────────────────────────────────────────────────────

🔄 SWITCH ROLES NOW!

───────────────────────────────────────────────────────────────
📍 MILESTONE 3 (4 min): Frontend files
───────────────────────────────────────────────────────────────
index.html:
    <!DOCTYPE html>
    <html><head><title>WebApp</title></head>
    <body><h1>Welcome</h1></body></html>

style.css:
    body { font-family: sans-serif; }

main.js:
    console.log("App loaded");

✓ CHECKPOINT: All 3 frontend files exist and have content
───────────────────────────────────────────────────────────────

───────────────────────────────────────────────────────────────
📍 MILESTONE 4 (4 min): Documentation and finalisation
───────────────────────────────────────────────────────────────
README.md:
    # WebApp
    A simple web application.
    ## Structure
    - backend/ - Python Flask API
    - frontend/ - HTML/CSS/JS client

.gitignore:
    __pycache__/
    *.pyc
    .env

✓ FINAL CHECKPOINT: tree webapp shows EXACTLY the required structure
───────────────────────────────────────────────────────────────

🚀 EXTENSION:

**Difficulty:** ★★★★☆

Choose one challenge:

1. **One-liner Challenge:** Create the entire structure in ONE command
   ```bash
   # Hint: mkdir -p with brace expansion + touch with brace expansion
   ```

2. **Error Handling:** Create a setup.sh script that:
   - Checks if webapp/ already exists
   - If yes, asks user before overwriting
   - Creates structure only if confirmed

3. **Documentation:** Add requirements.txt in backend/ with:
   ```
   flask==2.3.0
   pytest==7.4.0
   ```

4. **Peer Review:** Check another pair's tree output — are there any 
   differences from the specification? Why might that happen?

══════════════════════════════════════════════════════════════
```

### ✅ Success Criteria — Sprint 2

You have successfully completed this sprint when:
- [ ] `tree webapp` output matches the required structure EXACTLY
- [ ] `cat webapp/backend/src/app.py` shows Python content
- [ ] `cat webapp/.gitignore` includes `__pycache__/`
- [ ] All files contain non-empty content
- [ ] Total time: under 15 minutes

### Efficient solution:
```bash
# M1 - Structure
mkdir -p webapp/{backend/{src,tests},frontend/{css,js},docs}

# M2 - Backend
echo '# Main application
print("Hello from Flask!")' > webapp/backend/src/app.py

echo '# Configuration
DEBUG = True' > webapp/backend/src/config.py

echo '# Tests
def test_hello():
    pass' > webapp/backend/tests/test_app.py

# M3 - Frontend
echo '<!DOCTYPE html>
<html><head><title>WebApp</title></head>
<body><h1>Welcome</h1></body></html>' > webapp/frontend/index.html

echo 'body { font-family: sans-serif; }' > webapp/frontend/css/style.css

echo 'console.log("App loaded");' > webapp/frontend/js/main.js

# M4 - Docs
echo '# WebApp
A simple web application.
## Structure
- backend/ - Python Flask API
- frontend/ - HTML/CSS/JS client' > webapp/docs/README.md

echo '__pycache__/
*.pyc
.env' > webapp/.gitignore

# Verification
tree webapp
```

---

## SPRINT 3: The Shell Configurator
**Time**: 15 minutes | **Level**: Intermediate

> Last semester, a student accidentally deleted their `.bashrc` without a backup. They spent 20 minutes recreating their aliases from memory. Since then, I always start this sprint with the backup step — it's not optional!

```
══════════════════════════════════════════════════════════════
🎯 OBJECTIVE: Completely personalise the shell environment
══════════════════════════════════════════════════════════════

⚠️ Remember: Make a backup BEFORE any modification!

PAIR PROGRAMMING:
├── Min 0-7:  Driver A
└── Min 7-15: Driver B

───────────────────────────────────────────────────────────────
📍 MILESTONE 1 (3 min): Backup and variables
───────────────────────────────────────────────────────────────
1. Create backup: cp ~/.bashrc ~/.bashrc.backup
2. Verify it exists: ls -la ~/.bashrc*
3. Set variables in session:
   - PROJECT="OS_Seminar"
   - EDITOR="nano"
   - DEBUG_MODE="true"

✓ CHECKPOINT: echo $PROJECT displays "OS_Seminar"
───────────────────────────────────────────────────────────────

───────────────────────────────────────────────────────────────
📍 MILESTONE 2 (4 min): Essential aliases
───────────────────────────────────────────────────────────────
Add to ~/.bashrc:

alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias cls='clear'
alias h='history'
alias grep='grep --color=auto'

✓ CHECKPOINT: grep "alias ll" ~/.bashrc finds the line
───────────────────────────────────────────────────────────────

🔄 SWITCH ROLES!

───────────────────────────────────────────────────────────────
📍 MILESTONE 3 (4 min): Useful functions
───────────────────────────────────────────────────────────────
Add to ~/.bashrc:

# Create directory and enter it
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Extract any archive
extract() {
    case "$1" in
        *.tar.gz)  tar xzf "$1" ;;
        *.zip)     unzip "$1" ;;
        *.tar)     tar xf "$1" ;;
        *)         echo "Unknown format: $1" ;;
    esac
}

✓ CHECKPOINT: type mkcd shows the function definition
───────────────────────────────────────────────────────────────

───────────────────────────────────────────────────────────────
📍 MILESTONE 4 (4 min): Prompt and testing
───────────────────────────────────────────────────────────────
Add custom prompt:

PS1='\[\033[01;32m\]\u\[\033[00m\]@\[\033[01;33m\]\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '

Test everything:
1. source ~/.bashrc
2. Test each alias
3. Test mkcd test_folder
4. Verify the prompt is coloured

✓ FINAL CHECKPOINT: Everything works, prompt is green/yellow/blue
───────────────────────────────────────────────────────────────

🚀 EXTENSION:

**Difficulty:** ★★★★☆

Choose one challenge:

1. **Welcome Message:** Add a greeting with date/time that shows on login
   ```bash
   # Add to end of .bashrc:
   echo "Welcome back, $USER! It's $(date '+%A, %d %B %Y, %H:%M')"
   ```

2. **Disk Space Alias:** Create an alias for colourful disk usage
   ```bash
   alias diskspace='df -h --total | grep -E "^/|total"'
   ```

3. **Error Handling:** Improve mkcd to handle existing directories
   ```bash
   mkcd() {
       if [ -d "$1" ]; then
           echo "Directory exists, entering..." && cd "$1"
       else
           mkdir -p "$1" && cd "$1"
       fi
   }
   ```

4. **Peer Teaching:** Help another pair debug their .bashrc if they broke it

══════════════════════════════════════════════════════════════
```

### ✅ Success Criteria — Sprint 3

You have successfully completed this sprint when:
- [ ] `ls -la ~/.bashrc*` shows both `.bashrc` and `.bashrc.backup`
- [ ] After `source ~/.bashrc`, running `ll` works as `ls -alF`
- [ ] Running `mkcd test_sprint3` creates AND enters the directory
- [ ] Your prompt shows coloured username, hostname and path
- [ ] Total time: under 15 minutes

---

## SPRINT 4: The File Detective
**Time**: 12 minutes | **Level**: Intermediate

```
══════════════════════════════════════════════════════════════
🎯 OBJECTIVE: Find and organise files by criteria
══════════════════════════════════════════════════════════════

SETUP (run BEFORE the sprint):
───────────────────────────────────────────────────────────────
mkdir -p ~/detective_test
cd ~/detective_test
touch file{1..5}.txt image{1..3}.jpg doc{1..2}.pdf
touch .hidden_config .secret_key
echo "Important data" > important.txt
echo "Old data" > old_file.txt
touch -d "30 days ago" old_file.txt
mkdir archive
───────────────────────────────────────────────────────────────

PAIR PROGRAMMING: Switch at 6 minutes!

───────────────────────────────────────────────────────────────
📍 MILESTONE 1 (3 min): Initial investigation
───────────────────────────────────────────────────────────────
1. How many .txt files exist?
2. What are the hidden files?
3. Which is the oldest file?

✓ CHECKPOINT: Answers: 6 txt, 2 hidden, old_file.txt
───────────────────────────────────────────────────────────────

───────────────────────────────────────────────────────────────
📍 MILESTONE 2 (3 min): Advanced search
───────────────────────────────────────────────────────────────
4. Find ALL files (including hidden) with find
5. Find files older than 7 days
6. Find files containing "data" in content

✓ CHECKPOINT: find finds 13 elements, grep finds 2 files
───────────────────────────────────────────────────────────────

🔄 SWITCH!

───────────────────────────────────────────────────────────────
📍 MILESTONE 3 (3 min): Organisation
───────────────────────────────────────────────────────────────
7. Move all .jpg to archive/
8. Move all .pdf to archive/
9. Verify structure with tree

✓ CHECKPOINT: archive/ contains 3 jpg + 2 pdf
───────────────────────────────────────────────────────────────

───────────────────────────────────────────────────────────────
📍 MILESTONE 4 (3 min): Final report
───────────────────────────────────────────────────────────────
10. Create a file report.txt with:
    - Total number of files remaining in directory
    - List of files in archive/
    - Total space occupied

✓ FINAL CHECKPOINT: cat report.txt shows the statistics
───────────────────────────────────────────────────────────────

🚀 EXTENSION:

**Difficulty:** ★★★★★

Choose one challenge:

1. **Safe Cleanup:** Delete old files but ask for confirmation
   ```bash
   find . -type f -mtime +7 -exec rm -i {} \;
   ```

2. **Archive Creation:** Create a compressed archive from archive/
   ```bash
   tar -czvf archive_backup_$(date +%Y%m%d).tar.gz archive/
   ```

3. **One-liner Report:** Generate report.txt in a single pipeline
   ```bash
   # Hint: use ls, wc, du and command substitution
   ```

4. **Advanced Find:** Find all files modified in the last hour
   ```bash
   find . -type f -mmin -60
   ```

══════════════════════════════════════════════════════════════
```

### ✅ Success Criteria — Sprint 4

You have successfully completed this sprint when:
- [ ] `ls *.txt | wc -l` returns 6
- [ ] `find . -type f -mtime +7` returns at least one result
- [ ] `ls archive/` shows 5 files (3 jpg + 2 pdf)
- [ ] `cat report.txt` contains three statistics
- [ ] Total time: under 12 minutes

### Solutions:
```bash
# M1
ls *.txt | wc -l           # 6
ls -la .* 2>/dev/null      # .hidden_config, .secret_key
ls -lt | tail -1           # old_file.txt

# M2
find . -type f             # all files
find . -type f -mtime +7   # older than 7 days
grep -r "data" .           # contains "data"

# M3
mv *.jpg archive/
mv *.pdf archive/
tree

# M4
echo "Files remaining: $(find . -maxdepth 1 -type f | wc -l)" > report.txt
echo "In archive: $(ls archive/)" >> report.txt
echo "Space: $(du -sh .)" >> report.txt
```

---

## SPRINT 5: The Variable Master
**Time**: 10 minutes | **Level**: Intermediate-Advanced

```
══════════════════════════════════════════════════════════════
🎯 OBJECTIVE: Demonstrate deep understanding of variables
══════════════════════════════════════════════════════════════

INDIVIDUAL (no pair for this sprint)

───────────────────────────────────────────────────────────────
📍 MILESTONE 1 (3 min): Predictions
───────────────────────────────────────────────────────────────
WRITE on paper what you think EACH command will display:

A="text"
B='$A plus'
C="$A plus"

echo $B
echo $C
echo "$B"
echo '$C'

Then run and compare with your predictions!

✓ CHECKPOINT: You have predictions BEFORE running, you understand the differences
───────────────────────────────────────────────────────────────

───────────────────────────────────────────────────────────────
📍 MILESTONE 2 (3 min): String manipulation
───────────────────────────────────────────────────────────────
FILENAME="/home/student/documents/report_final.pdf"

Extract:
1. Only the filename (report_final.pdf)
2. Only the extension (pdf)
3. Path without file (/home/student/documents)
4. Name without extension (report_final)

HINT: Use ${VAR%pattern}, ${VAR##pattern}, etc.

✓ CHECKPOINT: You have 4 correct answers using parameter expansion
───────────────────────────────────────────────────────────────

───────────────────────────────────────────────────────────────
📍 MILESTONE 3 (4 min): Script with checks
───────────────────────────────────────────────────────────────
Create var_demo.sh that:
1. Receives an argument or uses "default"
2. Checks if environment variable DEMO_VAR exists
3. Displays the length of a given string

Structure:
    #!/bin/bash
    NAME=${1:-"default_name"}
    echo "Name: $NAME (length: ${#NAME})"
    
    if [ -z "$DEMO_VAR" ]; then
        echo "DEMO_VAR is not set"
    else
        echo "DEMO_VAR = $DEMO_VAR"
    fi

✓ FINAL CHECKPOINT: ./var_demo.sh and ./var_demo.sh test both work
───────────────────────────────────────────────────────────────

🚀 EXTENSION:

**Difficulty:** ★★★★★

Choose one challenge:

1. **Strict Mode:** Use `${VAR:?error}` to force variable existence
   ```bash
   # This will exit with error if MY_VAR is not set
   echo "${MY_VAR:?MY_VAR must be set!}"
   ```

2. **Arrays:** Create and iterate through an array
   ```bash
   FRUITS=("apple" "banana" "cherry")
   for fruit in "${FRUITS[@]}"; do
       echo "I like $fruit"
   done
   ```

3. **Path Manipulation Challenge:** Extract components from:
   `/var/log/apache2/access.log.2024-01-15.gz`
   - Filename only
   - Directory only  
   - Extension only
   - Date part only

4. **Peer Code Review:** Check another pair's var_demo.sh for edge cases

══════════════════════════════════════════════════════════════
```

### ✅ Success Criteria — Sprint 5

You have successfully completed this sprint when:
- [ ] Your predictions for M1 were at least 75% correct
- [ ] `echo ${FILENAME##*/}` outputs `report_final.pdf`
- [ ] Running `./var_demo.sh` shows "default_name"
- [ ] Running `./var_demo.sh mytest` shows "mytest"
- [ ] Total time: under 10 minutes

### M2 Solutions:
```bash
FILENAME="/home/student/documents/report_final.pdf"

# 1. Only the filename
echo ${FILENAME##*/}         # report_final.pdf

# 2. Only the extension
echo ${FILENAME##*.}         # pdf

# 3. Path without file
echo ${FILENAME%/*}          # /home/student/documents

# 4. Name without extension
BASENAME=${FILENAME##*/}     # report_final.pdf
echo ${BASENAME%.*}          # report_final
```

---

## SPRINT TRACKER

Use this table for classroom tracking:

| Sprint | Pair | M1 | M2 | M3 | M4 | Extension | Notes |
|--------|------|----|----|----|----|-----------|-------|
| S1 |  |  |  |  |  |  |  |
| S2 |  |  |  |  |  |  |  |
| S3 |  |  |  |  |  |  |  |
| S4 |  |  |  |  |  |  |  |
| S5 |  |  |  |  |  |  |  |

Mark: ✓ completed, ~ partial, ✗ not finished

---

## LEARNING OBJECTIVES (mapping to sprints)

| Objective | Sprint | Milestone |
|-----------|--------|-----------|
| File system navigation | S1 | M1-M3 |
| Structure creation | S2 | M1-M2 |
| .bashrc configuration | S3 | M2-M4 |
| Find and globbing | S4 | M2-M3 |
| Advanced variables | S5 | M1-M3 |
| Pair programming | S1-S4 | all |

---

*Sprint Exercises | OS Seminar 1-2 | ASE-CSIE*
