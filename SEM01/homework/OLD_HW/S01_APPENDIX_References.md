# S01_APPENDIX - Seminar 1 References (Redistributed)

> **Operating Systems** | ASE Bucharest - CSIE  
> Supplementary material

---

## Official Bibliography

### Recommended Books
1. **Shotts, W.** - *The Linux Command Line* (5th Ed.) - Free book, excellent for beginners
2. **Robbins, A.** - *Bash Pocket Reference* - Quick reference
3. **Newham, C.** - *Learning the bash Shell* (O'Reilly)
4. **Barrett, D.** - *Linux Pocket Guide* (O'Reilly)

### Online Resources
- GNU Bash Manual: https://www.gnu.org/software/bash/manual/
- Linux Documentation Project: https://tldp.org/
- Explain Shell: https://explainshell.com/
- ShellCheck: https://www.shellcheck.net/

---

## Essential Commands - Quick Reference

### Navigation and Files

```
┌─────────────────────────────────────────────────────────────┐
│  pwd     - Print Working Directory (displays current path)  │
│  cd      - Change Directory                                  │
│  ls      - List (lists contents)                            │
│  cat     - Concatenate (displays file contents)             │
│  less    - Paginated viewing                                │
│  head    - First N lines                                    │
│  tail    - Last N lines                                     │
│  touch   - Create empty file / update timestamp             │
│  mkdir   - Make Directory                                   │
│  rmdir   - Remove Directory (empty)                         │
│  rm      - Remove (deletes files/directories)               │
│  cp      - Copy                                             │
│  mv      - Move / Rename                                    │
└─────────────────────────────────────────────────────────────┘
```

### FHS Hierarchy Diagram (Filesystem Hierarchy Standard)

```
/                           ← Root (filesystem root)
├── bin/                    ← Essential binaries (ls, cp, mv, cat)
├── boot/                   ← Bootloader and kernel files
├── dev/                    ← Device files
│   ├── null               ← "Black hole" - swallows everything
│   ├── zero               ← Source of zeroes
│   ├── random             ← Random number generator
│   ├── sda, sda1...       ← Hard drives and partitions
│   └── tty*               ← Terminals
├── etc/                    ← System configurations
│   ├── passwd             ← User information
│   ├── group              ← Group information
│   ├── shadow             ← Encrypted passwords
│   ├── fstab              ← Mount points
│   ├── hosts              ← Hostname mappings
│   └── bash.bashrc        ← Global Bash configuration
├── home/                   ← User directories
│   └── student/
│       ├── .bashrc        ← Personal Bash config
│       ├── .bash_profile  ← At login
│       └── Documents/
├── lib/                    ← Shared libraries
├── media/                  ← Automatic mount points (USB, CD)
├── mnt/                    ← Manual mount points
├── opt/                    ← Optional/third-party software
├── proc/                   ← Pseudo-filesystem (processes)
│   ├── cpuinfo            ← CPU info
│   ├── meminfo            ← Memory info
│   └── [PID]/             ← Per-process info
├── root/                   ← Root's home
├── sbin/                   ← System binaries (admin)
├── srv/                    ← Service data (web, ftp)
├── sys/                    ← Pseudo-filesystem (kernel/hardware)
├── tmp/                    ← Temporary files
├── usr/                    ← User programs (read-only)
│   ├── bin/               ← User binaries
│   ├── lib/               ← Libraries
│   ├── local/             ← Locally compiled software
│   └── share/             ← Shared data (man pages, etc)
└── var/                    ← Variable data
    ├── log/               ← System logs
    ├── mail/              ← Mailboxes
    ├── spool/             ← Queues (print, mail)
    └── tmp/               ← Persistent temp
```

---

## Fully Solved Exercises

### Exercise 1: Basic Navigation

**Requirement:** Create the directory structure for a project and navigate through it.

```bash
# Step 1: Check current location
pwd
# Output: /home/student

# Step 2: Create the structure
mkdir -p project/{src,docs,tests,config}

# Step 3: Verify the structure
tree project/
# Output:
# project/
# config
# docs
# src
# tests

# Step 4: Navigate and create files
cd project/src
touch main.py utils.py
cd ../docs
touch README.md
cd ../config
touch settings.ini

# Step 5: Verify everything
cd ..
find . -type f
# Output:
# ./src/main.py
# ./src/utils.py
# ./docs/README.md
# ./config/settings.ini

# Step 6: Return to home
cd ~
# or
cd
```

### Exercise 2: Environment Variables

**Requirement:** Configure variables for a development environment.

```bash
# Step 1: Check existing variables
echo $HOME
echo $USER
echo $PATH

# Step 2: Create local variables
PROJECT_NAME="MyApp"
VERSION="1.0.0"
DEBUG=true

# Step 3: Verify (they are not exported)
echo $PROJECT_NAME
bash -c 'echo $PROJECT_NAME'  # Empty! Not exported

# Step 4: Export for subprocesses
export PROJECT_NAME
export VERSION
export DEBUG

# Step 5: Verify now
bash -c 'echo $PROJECT_NAME'  # MyApp

# Step 6: Add to PATH
export PATH="$HOME/bin:$PATH"

# Step 7: Make permanent (add to ~/.bashrc)
echo 'export PROJECT_NAME="MyApp"' >> ~/.bashrc
echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc

# Step 8: Apply changes
source ~/.bashrc
```

### Exercise 3: Globbing and File Manipulation

**Requirement:** Organise files by extension.

```bash
# Setup: Create test files
mkdir -p ~/test_glob && cd ~/test_glob
touch file{1..5}.txt image{1..3}.jpg doc{1..2}.pdf script.sh data.csv

# Verify
ls
# file1.txt file2.txt file3.txt file4.txt file5.txt
# image1.jpg image2.jpg image3.jpg
# doc1.pdf doc2.pdf
# script.sh data.csv

# Step 1: List only .txt files
ls *.txt
# file1.txt file2.txt file3.txt file4.txt file5.txt

# Step 2: List files starting with "file" or "image"
ls {file,image}*
# file1.txt ... image1.jpg ...

# Step 3: List files with a digit in the name
ls *[0-9]*
# All files with digits

# Step 4: Create directories for organisation
mkdir -p organised/{text,images,documents,scripts,data}

# Step 5: Move the files
mv *.txt organised/text/
mv *.jpg organised/images/
mv *.pdf organised/documents/
mv *.sh organised/scripts/
mv *.csv organised/data/

# Step 6: Verify the result
tree organised/
# organised/
# data
# data.csv
# documents
# doc1.pdf
# doc2.pdf
# images
# image1.jpg
# image2.jpg
# image3.jpg
# scripts
# script.sh
# text
# file1.txt
# file2.txt
# file3.txt
# file4.txt
# file5.txt

# Cleanup
cd ~
rm -rf ~/test_glob
```

---

## Additional ASCII Diagrams

### Shell Command Interpretation Process

```
┌─────────────────────────────────────────────────────────────────┐
│                    COMMAND INPUT                                │
│                    $ ls -la *.txt                               │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│  1. TOKENISATION                                                │
│     Splits into tokens: "ls", "-la", "*.txt"                   │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│  2. EXPANSION                                                   │
│     • Brace expansion: {a,b} → a b                             │
│     • Tilde expansion: ~ → /home/user                          │
│     • Parameter expansion: $VAR → value                        │
│     • Command substitution: $(cmd) → output                    │
│     • Glob expansion: *.txt → file1.txt file2.txt              │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│  3. QUOTE REMOVAL                                               │
│     Removes quotes that are no longer needed                   │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│  4. COMMAND LOOKUP                                              │
│     • Check if it's a function                                 │
│     • Check if it's a builtin                                  │
│     • Search in $PATH                                          │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│  5. EXECUTION                                                   │
│     fork() + exec() for external commands                      │
│     or direct execution for builtins                           │
└─────────────────────────────────────────────────────────────────┘
```

### Types of Quoting

```
┌─────────────────────────────────────────────────────────────────┐
│                      QUOTING IN BASH                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  SINGLE QUOTES (')                                       │   │
│  │  • Everything is literal                                │   │
│  │  • NO expansion is performed                            │   │
│  │  • echo '$HOME' → $HOME                                 │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  DOUBLE QUOTES (")                                       │   │
│  │  • Preserves spaces                                     │   │
│  │  • Allows expansion: $, `, \, !                         │   │
│  │  • echo "$HOME" → /home/user                            │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  BACKSLASH (\)                                           │   │
│  │  • Escapes a single character                           │   │
│  │  • echo \$HOME → $HOME                                  │   │
│  │  • echo "Cost: \$50" → Cost: $50                        │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  $'...' (ANSI-C Quoting)                                 │   │
│  │  • Interprets escape sequences                          │   │
│  │  • $'\t' → tab, $'\n' → newline                         │   │
│  │  • echo $'Line1\nLine2' → two lines                     │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## Frequently Asked Questions (FAQ)

**Q: What is the difference between `~` and `$HOME`?**
> A: They are equivalent in most cases. `~` is expanded by the shell, `$HOME` is an environment variable. In scripts, `$HOME` is preferred for clarity.

**Q: Why doesn't `rm -rf /` work directly?**
> A: Most modern systems have protection. You need `--no-preserve-root`. NEVER TRY THIS!

**Q: How do I see hidden files?**
> A: `ls -a` or `ls -la`. Hidden files start with `.`

**Q: What does `cd -` do?**
> A: Returns to the previous directory (toggles between the last two locations).

**Q: How do I cancel a running command?**
> A: `Ctrl+C` (SIGINT). For background processes: `kill %1` or `kill PID`.

---
*Supplementary material for the Operating Systems course | ASE Bucharest - CSIE*

---

*By Revolvix for OPERATING SYSTEMS class | restricted licence 2017-2030*
