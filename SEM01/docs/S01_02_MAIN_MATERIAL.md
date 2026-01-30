# TC1 - Main Material: The Bash Shell and File System

> Operating Systems | ASE Bucharest - CSIE  
> Pedagogically restructured material - Seminar 1  
> Version with Subgoal Labels for efficient learning

---

## Target Competencies

At the end of this seminar, the student will be able to:

| Cognitive Level | Competency |
|-----------------|------------|
| Apply | Navigate fluently in the Linux file system |
| Apply | Configure the shell with variables, aliases and personalised prompt |
| Analyse | Distinguish between quote types and their effects |
| Analyse | Diagnose common configuration problems |
| Evaluate | Choose appropriate glob patterns for file selection |
| Create | Build simple configuration scripts |

---

## Mental Model: System Layers

```
┌─────────────────────────────────────────────────────────────┐
│                    USER                                      │
│                        │                                     │
│                   ╔════▼════╗                                │
│                   ║  SHELL  ║ ← Interprets commands          │
│                   ║ (Bash)  ║   Expands variables            │
│                   ╚════╬════╝   Processes glob patterns      │
│                        │                                     │
│                   ╔════▼════╗                                │
│                   ║ KERNEL  ║ ← Manages processes            │
│                   ║ (Linux) ║   Allocates resources          │
│                   ╚════╬════╝   Controls hardware            │
│                        │                                     │
│                   ┌────▼────┐                                │
│                   │HARDWARE │                                │
│                   └─────────┘                                │
└─────────────────────────────────────────────────────────────┘
```

> Analogy: The shell is like a **translator** between you and the computer. You say "display the files", it translates that into instructions the kernel understands.

---

# PART I: Navigating the File System

## 1. File System Hierarchy (FHS)

### SUBGOAL: Understand the tree structure

```
/                           ← ROOT - everything starts here
├── bin/                    ← Essential binaries (ls, cp, cat)
├── etc/                    ← System configurations (etc = "editable text config")
│   ├── passwd              ← User information
│   ├── hosts               ← Hostname ↔ IP mappings
│   └── bash.bashrc         ← Global Bash configuration
├── home/                   ← USER DIRECTORIES
│   └── student/            ← YOUR HOME (~)
│       ├── Desktop/
│       ├── Documents/
│       └── .bashrc         ← YOUR personal configuration
├── tmp/                    ← Temporary files (deleted at reboot! don't keep anything important here)
├── var/                    ← Variable data
│   └── log/                ← System logs
└── usr/                    ← User programs
    ├── bin/                ← Non-essential commands
    └── share/              ← Shared data
```

### Mnemonics for directories:

| Directory | Mnemonic | Contains |
|-----------|----------|----------|
| `/etc` | Editable Text Config | Configurations |
| `/var` | VARiable | Data that changes |
| `/tmp` | TeMPorary | Temporary files |
| `/bin` | BINary | Essential executables |
| `/home` | **HOME** | Users' home (aka "where you keep your stuff") |

---

## 2. Navigation with cd and pwd

### SUBGOAL: Identify current location

```bash
# Always start by checking WHERE you are
pwd
# Output: /home/student
```

### SUBGOAL: Navigate using absolute paths

```bash
# Absolute paths always start with /
cd /etc
pwd           # /etc

cd /home/student/Documents
pwd           # /home/student/Documents
```

### SUBGOAL: Navigate using paths relative to the current working directory (`cwd`)

```bash
# Relative paths start from the current directory
cd Documents    # enter Documents (relative)
cd ..           # go up one level (parent directory)
cd ../..        # go up two levels
cd ./subdir     # explicit relative (./ = here)
```

### SUBGOAL: Use navigation shortcuts

```bash
cd ~            # home (home directory)
cd              # also home (shortcut)
cd -            # back to previous directory (toggle)
cd ~username    # another user's home
```

### COMMON ERROR: Confusion between "/" and "~"

> In my experience at ASE, students frequently confuse `/` with `~`. Last year, a student ran `rm -rf /*` instead of `rm -rf ~/*` — fortunately it was on a virtual machine and they didn't have root permissions. But the sweat was real! Since then, I insist on checking with `pwd` before any destructive operation.

```bash
# WRONG (conceptually for beginners):
cd /            # Go to ROOT (system root) - NOT your home!

# CORRECT to go home:
cd ~            # Go to /home/student
cd              # Same

# Check the difference:
cd / && pwd     # /
cd ~ && pwd     # /home/student
```

---

## 3. Listing Files with ls

### SUBGOAL: List basic content

```bash
ls              # simple listing
ls /etc         # list another directory
```

### SUBGOAL: Get detailed information

```bash
ls -l           # long format
```

Interpreting `ls -l` output:

I draw this diagram on the board at every seminar — it's the foundation for understanding permissions. Students who memorise it have a serious advantage in exams and technical interviews.

```
-rw-r--r-- 1 student student 4096 Jan 10 12:00 file.txt
│├─┤├─┤├─┤ │    │       │      │       │          └── Name
││  │  │   │    │       │      │       └── Modification date
││  │  │   │    │       │      └── Size (bytes)
││  │  │   │    │       └── Owner group
││  │  │   │    └── Owner user
││  │  │   └── Number of hard links
││  │  └── Others permissions
││  └── Group permissions
│└── Owner permissions
└── Type: - file, d directory, l link
```

### SUBGOAL: Display hidden files

```bash
ls -a           # all files (includes those starting with .)
ls -la          # combination: long + hidden
```

> Note: Files starting with `.` are "hidden" - not for security reasons but to avoid cluttering the normal listing.

### SUBGOAL: Format output for readability

```bash
ls -lh          # human-readable sizes (KB, MB, GB)
ls -lt          # sort by time (most recent first)

> 💡 Over the years, I have found that practical examples beat theory every time.

ls -lS          # sort by size (largest first)
ls -lR          # recursive (includes subdirectories)
```

---

## 4. File Manipulation

> Personally, I prefer `nano` over `vim` for beginners — the learning curve is much gentler even though vim is more powerful. I tried teaching vim in the first seminar a few years ago... let's just say it wasn't a pleasant experience for anyone 😅

*(Nano is ideal for beginners. Vim is more powerful but the learning curve is steep.)*


### SUBGOAL: Create files and directories

```bash
# Empty file
touch file.txt

# Simple directory
mkdir directory

# Complete hierarchy (-p = parents)
mkdir -p project/src/main
```

### SUBGOAL: Copy while preserving the original

```bash
# File
cp source.txt copy.txt

# Directory (mandatory -r = recursive)
cp -r source_dir/ copy_dir/

# With confirmation
cp -i source.txt dest.txt
```

### SUBGOAL: Move or rename

```bash
# Rename (same directory)
mv old.txt new.txt

# Move (different directory)
mv file.txt /another/path/

# Move with rename
mv file.txt /another/path/other_name.txt
```

### SUBGOAL: Delete with caution

```bash
# Simple file
rm file.txt

# With confirmation (RECOMMENDED!)
rm -i file.txt

# Empty directory
rmdir empty_directory

# Directory with content
rm -r directory/

# DANGEROUS - no confirmation, no undo!
rm -rf directory/
```

### ANTI-PATTERN: `rm -rf` without verification

```bash
# NEVER run directly:
rm -rf $VARIABLE/    # If VARIABLE is empty, deletes /

# ALWAYS verify first:
echo "Will delete: $VARIABLE"
read -p "Continue? (y/n) " confirm
[[ $confirm == "y" ]] && rm -rf "$VARIABLE"
```

---

## 5. Viewing Content

### SUBGOAL: Choose the right command for the context

| Command | When to use it |
|---------|----------------|
| `cat` | Small files (< 50 lines) |
| `head` | Only the beginning (quick check) |
| `tail` | Only the end (logs) |
| `less` | Large files (interactive navigation) |

### SUBGOAL: Quickly display small files

```bash
cat file.txt
cat -n file.txt      # with line numbers
```

### SUBGOAL: Inspect beginning/end

```bash
head -n 5 file.txt   # first 5 lines
tail -n 10 file.txt  # last 10 lines
tail -f log.txt      # live monitoring (Follow)
```

### SUBGOAL: Navigate in large files

```bash
less file.txt
```

Navigation keys in `less`:

| Key | Action |
|-----|--------|
| `Space` | Page down |
| `b` | Page up |
| `g` | Go to beginning |
| `G` | Go to end |
| `/text` | Search for "text" |
| `n` | Next match |
| `q` | Exit |

---

# PART II: Shell Configuration

## 6. Variables in Bash

### Analogy: Variables as Labelled Boxes

Think of variables like labelled boxes in a storage room:
- The **LABEL** is the variable name (e.g., `PATH`)
- The **CONTENTS** are the value (e.g., `/usr/bin:/bin`)
- **`export`** = putting the box on a conveyor belt so child processes can access it

![Variable Box Analogy](images/04_variable_box.svg)

### SUBGOAL: Distinguish variable types

```
┌─────────────────────────────────────────────────────────────┐
│                    BASH VARIABLES                            │

> 💡 Over the years, I have found that practical examples beat theory every time.

├───────────────┬───────────────────┬─────────────────────────┤
│   LOCAL       │   ENVIRONMENT     │   SPECIAL               │
│               │   (export)        │                         │
├───────────────┼───────────────────┼─────────────────────────┤
│ VAR="val"     │ export VAR="val"  │ $? $$ $! $0 $1-$9       │
│               │                   │                         │
│ Exists ONLY   │ Inherited by      │ Set automatically       │
│ in the        │ all child         │ by the shell            │
│ current shell │ processes         │                         │
└───────────────┴───────────────────┴─────────────────────────┘
```

### SUBGOAL: Create local variables

```bash
# Syntax: NAME=value (NO spaces around =)
NAME="John Smith"
AGE=25
PROJECT_PATH="/home/student/project"

# Usage: with $ prefix
echo "Hello, $NAME"
echo "You are $AGE years old"
```

### COMMON ERROR: Spaces in assignment

```bash
# WRONG - Bash interprets as a command
NAME = "John"        # Error: NAME: command not found

# CORRECT - No spaces
NAME="John"
```

### SUBGOAL: Export for subprocesses

```bash
# Local variable - NOT visible in subprocesses
LOCAL="local value"
bash -c 'echo "Local: $LOCAL"'      # Output: Local: (empty!)

# Environment variable - VISIBLE in subprocesses
export GLOBAL="global value"
bash -c 'echo "Global: $GLOBAL"'    # Output: Global: global value
```

### SUBGOAL: Know the special variables

| Variable | Meaning | Example |
|----------|---------|---------|
| `$?` | Exit code of last command | `0` = success |
| `$$` | PID of current shell | `12345` |
| `$USER` | Current user | `student` |
| `$HOME` | Home directory | `/home/student` |
| `$PATH` | Executable search paths | `/usr/bin:/bin` |
| `$PWD` | Current directory | `/home/student` |
| `$SHELL` | Current shell | `/bin/bash` |

### SUBGOAL: Verify command results

```bash
ls /existing/directory
echo "Exit code: $?"    # 0 (success)

ls /nonexistent/directory
echo "Exit code: $?"    # non-zero (error)
```

---

## 7. Quoting: Single vs Double vs None

### SUBGOAL: Understand when the shell interprets

```
GOLDEN RULE:
┌─────────────────────────────────────────────────────────────┐
│ 'single quotes'  →  NOTHING is interpreted (literal)        │
│ "double quotes"  →  $variables and `commands` ARE interpreted│
│  no quotes       →  Everything is interpreted + word splitting│
└─────────────────────────────────────────────────────────────┘
```

### SUBGOAL: Apply the rules in practice

```bash
NAME="Student"
DATE=$(date +%Y)

# Single quotes - everything literal
echo 'Hello $NAME in year $DATE'
# Output: Hello $NAME in year $DATE

# Double quotes - variables expand
echo "Hello $NAME in year $DATE"
# Output: Hello Student in year 2024

# No quotes - variables expand + word splitting
echo Hello    $NAME   in   year   $DATE
# Output: Hello Student in year 2024 (multiple spaces compressed)
```

### SUBGOAL: Protect special characters

```bash
# Display literal $
echo "The price is \$100"    # The price is $100
echo 'The price is $100'     # The price is $100

# Display quotes in string
echo "He said \"hello\""     # He said "hello"
echo 'He said "hello"'       # He said "hello"
```

### COMMON ERROR: Missing quotes for files with spaces

```bash
FILE="Important Document.txt"

# WRONG - word splitting
cat $FILE               # Error: cat can't find "Important"

# CORRECT - protected with double quotes
cat "$FILE"             # Works!
```

---

## 8. Configuration Files

### SUBGOAL: Understand the loading order

```
┌─────────────────────────────────────────────────────────────┐
│              WHEN YOU OPEN A NEW TERMINAL:                   │
│                                                             │
│    NON-LOGIN SHELL (graphical terminal):                    │
│    ~/.bashrc  ───►  is executed                             │
│                                                             │
│              WHEN YOU LOG IN (ssh, tty):                    │
│                                                             │
│    LOGIN SHELL:                                             │
│    /etc/profile  ───►  ~/.bash_profile  ───►  ~/.bashrc     │

*Personal note: I prefer Bash scripts for simple automation and Python when the logic becomes complex. It's a matter of pragmatism.*

│         │                    │                              │
│         │                    └── usually "source ~/.bashrc" │
│         └── global for everyone                             │
└─────────────────────────────────────────────────────────────┘
```

### SUBGOAL: Edit ~/.bashrc for personalisation

```bash
# Open for editing
nano ~/.bashrc

# Recommended structure:

#
# 1. ALIASES (short commands)
#
alias ll='ls -la'
alias la='ls -A'
alias cls='clear'
alias ..='cd ..'
alias ...='cd ../..'

#
# 2. ENVIRONMENT VARIABLES
#
export EDITOR="nano"
export HISTSIZE=10000

#
# 3. CUSTOM PATH
#
export PATH="$HOME/bin:$HOME/.local/bin:$PATH"

#
# 4. CUSTOM PROMPT (PS1)
#
PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '

#
# 5. USEFUL FUNCTIONS
#
mkcd() { mkdir -p "$1" && cd "$1"; }
```

### SUBGOAL: Apply the changes

```bash
# Method 1: source (reload in current shell)
source ~/.bashrc

# Method 2: short form
. ~/.bashrc

# Method 3: open new terminal
```

### COMMON ERROR: "Why doesn't my alias work?"

```bash
# You added alias in ~/.bashrc but did NOT reload
alias ll='ls -la'    # Added in .bashrc

ll                   # Error: ll: command not found

# SOLUTION:
source ~/.bashrc     # Now it works!
ll
```

---

## 9. Aliases and Functions

### SUBGOAL: Create aliases for frequent commands

```bash
# Syntax: alias name='command'
alias ll='ls -la'
alias h='history'
alias grep='grep --color=auto'

# Safety aliases
alias rm='rm -i'      # Confirm before deletion
alias cp='cp -i'
alias mv='mv -i'

# Navigation aliases
alias cdp='cd ~/projects'
alias cdd='cd ~/Downloads'
```

### SUBGOAL: Use functions for complex logic

```bash
# Functions can receive arguments (aliases cannot!)

# mkdir + cd in a single command
mkcd() {
    mkdir -p "$1" && cd "$1"
}
# Usage: mkcd new_project

# Extract any archive
extract() {
    case "$1" in
        *.tar.gz)  tar xzf "$1" ;;
        *.tar.bz2) tar xjf "$1" ;;
        *.zip)     unzip "$1" ;;
        *.gz)      gunzip "$1" ;;
        *.tar)     tar xf "$1" ;;
        *)         echo "Unknown format: $1" ;;
    esac
}
# Usage: extract archive.tar.gz
```

---

## 10. Prompt Personalisation (PS1)

### SUBGOAL: Understand special sequences

| Sequence | Meaning |
|----------|---------|
| `\u` | Username |
| `\h` | Hostname (short) |
| `\w` | Current directory (full path) |
| `\W` | Current directory (name only) |
| `\d` | Date |
| `\t` | Time (HH:MM:SS) |
| `\$` | `$` for user, `#` for root |
| `\n` | New line |

### SUBGOAL: Add colours

```bash
# Colour format: \[\033[CODEm\]TEXT\[\033[00m\]
# start reset

# Text colour codes: 30-37
# 30=black, 31=red, 32=green, 33=yellow, 34=blue, 35=magenta, 36=cyan, 37=white
# Add 01; for bold

# Example: green user, blue directory
PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
```

### SUBGOAL: Test before saving

```bash
# 1. Save current prompt
OLD_PS1="$PS1"

# 2. Test new prompt
PS1='[\t] \u:\W\$ '

# 3. If you don't like it, restore
PS1="$OLD_PS1"

# 4. If it's OK, add to ~/.bashrc
```

---

# PART III: File Globbing (Wildcards)

## 11. Basic Patterns

### SUBGOAL: Understand that the SHELL expands, not the command

```bash
# You write:
ls *.txt

# The shell expands to:
ls file1.txt file2.txt notes.txt

# The ls command receives the file list already!
```

### SUBGOAL: Use asterisk (*) for any string

```bash
*.txt           # all .txt files
doc*            # everything starting with "doc"
*backup*        # everything containing "backup"
*.tar.gz        # all .tar.gz archives
```

### SUBGOAL: Use question mark (?) for one character

```bash
file?.txt       # file1.txt, fileA.txt (NOT file10.txt!)
???.txt         # exactly 3 characters + .txt
data_??.csv     # data_01.csv, data_99.csv
```

### SUBGOAL: Use square brackets for sets

```bash
file[123].txt   # file1.txt, file2.txt, file3.txt
file[a-z].txt   # filea.txt through filez.txt
file[0-9].txt   # file0.txt through file9.txt
file[!0-9].txt  # files that do NOT have a digit (negation with !)
```

### SUBGOAL: Use braces for explicit lists

```bash
# Brace expansion (NOT glob, it's expansion!)
echo {a,b,c}           # a b c
touch file{1,2,3}.txt  # creates file1.txt file2.txt file3.txt
mkdir dir{A..E}        # creates dirA dirB dirC dirD dirE
echo {1..10}           # 1 2 3 4 5 6 7 8 9 10
echo {01..10}          # 01 02 03 04 05 06 07 08 09 10
```

### COMMON ERROR: `*` does not include hidden files

```bash
ls *                   # does NOT show .bashrc, .profile, etc.
ls .*                  # ONLY hidden files
ls -a                  # All (safe way)
```

---

## 12. Getting Help

### SUBGOAL: Use man for complete documentation

```bash
man ls          # complete manual for ls
man bash        # manual for Bash (enormous!)

# Navigation in man:
# Space = page down
# b = page up
# /pattern = search
# n = next match
# q = exit
```

### SUBGOAL: Use --help for quick reference

```bash
ls --help       # quick help
cp --help
```

### SUBGOAL: Use type to identify command type

```bash
type cd         # cd is a shell builtin
type ls         # ls is /usr/bin/ls (or alias)
type ll         # ll is aliased to 'ls -la'
```

### SUBGOAL: Search in manuals with apropos

```bash
apropos "copy files"    # find commands related to copying files
man -k network          # equivalent
```

---

## Summary: The 10 Golden Rules

1. Always check with `pwd` before dangerous operations
2. `~` ≠ `/` - Home is not Root!
3. No spaces in variable assignment: `VAR=val` not `VAR = val`
4. Use `"$VAR"` with double quotes for files with spaces
5. `'single'` = literal, `"double"` = expansion
6. `source ~/.bashrc` after modifications
7. `rm -i` for safety, never `rm -rf` directly
8. **`*` does not include hidden files (those with `.`)
9. Test the prompt before saving it permanently
10. **`export`** for variables accessible in subprocesses

---

## Quick References

### Navigation Commands
```bash
pwd       cd DIR     cd ~      cd ..     cd -      ls -la
```

### File Commands
```bash
touch     mkdir -p   cp -r     mv        rm -i     cat/less
```

### Variables
```bash
VAR=val   export VAR   echo $VAR   unset VAR   $? $HOME $PATH
```

### Configuration
```bash
~/.bashrc   source ~/.bashrc   alias   PS1
```

### Wildcards
```bash
*         ?         [abc]     [a-z]     {a,b,c}   {1..10}
```

---

*Pedagogically restructured material for the Operating Systems course | ASE Bucharest - CSIE*
