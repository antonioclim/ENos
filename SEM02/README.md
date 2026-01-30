# Seminar 2: Control Operators, I/O Redirection, Filters, and Loops

> Lab observation: note down key commands and relevant output (2–3 lines) as you work. It helps with debugging and, honestly, by the end you'll have a decent README with no extra effort.
> Operating Systems | Bucharest University of Economic Studies - CSIE  
> Version: 1.0 | Date: January 2025  
> Author: SO Seminar Support Materials

---

## Table of Contents

1. [Description](#-description)
2. [Learning Outcomes](#-learning-outcomes)
3. [Package Structure](#-package-structure)
4. [Usage Guide](#-usage-guide)
5. [For Instructors](#-for-instructors)
6. [For Students](#-for-students)
7. [Technical Requirements](#%EF%B8%8F-technical-requirements)
8. [Installation and Configuration](#-installation-and-configuration)
9. [Frequently Encountered Problems](#-frequently-encountered-problems)
10. [Additional Resources](#-additional-resources)

---

## Description

### Context

This seminar is the natural continuation of Seminar 1 (Introduction to Bash, Navigation, Variables, Basic Globbing). We assume students are already familiar with:
- File system navigation (`cd`, `ls`, `pwd`)
- Environment and shell variables (`$HOME`, `$USER`, `$PATH`)
- Basic globbing (`*`, `?`, `[abc]`)
- Fundamental commands (`echo`, `cat`, `touch`, `mkdir`, `rm`)

### What This Seminar Introduces

Seminar 3-4 introduces essential concepts for scripting and automation:

| Module | Key Concepts | Practical Applications |
|--------|--------------|------------------------|
| Control Operators | `;`, `&&`, `\|\|`, `&`, `\|` | Command chains, error handling |
| I/O Redirection | `>`, `>>`, `<`, `<<`, `<<<`, `2>&1` | Logging, batch processing |
| Text Filters | `sort`, `uniq`, `cut`, `paste`, `tr`, `wc`, `head`, `tail`, `tee` | Data processing, log analysis |
| Loops | `for`, `while`, `until`, `break`, `continue` | Automation, batch processing |

### Seminar Philosophy

> From the classroom: Pipes and redirection are the "aha!" moment for most students. When they see they can do in 3 chained commands what would take 50 lines of Python, their perception of the terminal changes completely. It's one of the most satisfying moments of the semester.

This seminar follows the "Language as Vehicle" paradigm - we use Bash not as an end in itself, but as a tool for understanding fundamental operating systems concepts:
- Processes and exit codes - how programs communicate with each other
- File descriptors - the Unix I/O model
- Pipes and the Unix philosophy - "do one thing and do it well"
- Automation - transforming repetitive tasks into scripts

---

## Learning Outcomes

At the end of this seminar, students will be able to:

### Application Level (Anderson-Bloom)
1. Combine commands using control operators (`;`, `&&`, `||`, `&`)
2. Redirect input and output using `>`, `>>`, `<`, `<<`, `<<<`
3. Build efficient pipelines with `|` and `tee`
4. Use text filters: `sort`, `uniq`, `cut`, `paste`, `tr`, `wc`, `head`, `tail`
5. Write `for`, `while`, `until` loops with control flow (`break`, `continue`)

### Analysis Level (Anderson-Bloom)
6. Diagnose errors in scripts using exit codes and PIPESTATUS
7. Compare the efficiency of different approaches for the same problem
8. Evaluate LLM-generated code for correctness and efficiency

### Creation Level (Anderson-Bloom)
9. Design complex pipelines for data processing
10. Automate administrative tasks with robust scripts

---

## Package Structure

```
Seminar 2_COMPLETE/
│
├── README.md                           # 📖 This file - the main guide
│
├── docs/                               # 📚 Documentation and teaching materials
│   ├── S02_00_ANALYSIS_AND_PEDAGOGICAL_PLAN.md  # Materials analysis + plan
│   ├── S02_01_INSTRUCTOR_GUIDE.md               # Step-by-step instructor guide
│   ├── S02_02_MAIN_MATERIAL.md                  # Complete theoretical material
│   ├── S02_03_PEER_INSTRUCTION.md               # 15+ MCQ questions
│   ├── S02_04_PARSONS_PROBLEMS.md               # 10+ reordering problems
│   ├── S02_05_LIVE_CODING_GUIDE.md              # Script for live coding
│   ├── S02_06_SPRINT_EXERCISES.md               # Timed exercises
│   ├── S02_07_LLM_AWARE_EXERCISES.md            # Exercises with LLM evaluation
│   ├── S02_08_SPECTACULAR_DEMOS.md              # Visual demos
│   ├── S02_09_VISUAL_CHEAT_SHEET.md             # One-pager with commands
│   └── S02_10_SELF_ASSESSMENT_REFLECTION.md     # Metacognitive checkpoints
│
├── scripts/                            # 🔧 Functional scripts
│   ├── bash/                           # Bash utilities
│   │   ├── S02_01_setup_seminar.sh          # Work environment setup
│   │   ├── S02_02_interactive_quiz.sh       # Quiz with dialog/text
│   │   └── S02_03_validator.sh              # Assignment validation
│   │
│   ├── demo/                           # Spectacular demos
│   │   ├── S02_01_hook_demo.sh              # Opening hook
│   │   ├── S02_02_demo_pipes.sh             # Pipeline demonstration
│   │   ├── S02_03_demo_redirection.sh       # I/O demonstration
│   │   ├── S02_04_demo_filters.sh           # Filters showcase
│   │   └── S02_05_demo_loops.sh             # Loop examples
│   │
│   └── python/                         # Python utilities
│       ├── S02_01_autograder.py             # Automatic evaluation
│       ├── S02_02_quiz_generator.py         # Quiz generator
│       └── S02_03_report_generator.py       # Statistics and reports
│
├── presentations/                      # 📊 HTML Presentations
│   ├── S02_01_presentation.html             # Main presentation (reveal.js)
│   └── S02_02_cheat_sheet.html              # Printable cheat sheet
│
├── assignments/                        # 📝 Assignments and exercises
│   ├── OLD_HW/                             # Original materials (reference)
│   │   ├── TC2c_Control_Operators.md
│   │   ├── TC4a_IO_Redirection.md
│   │   ├── TC2d_Filters.md
│   │   ├── TC3b_Loops_Scripting.md
│   │   ├── TC2a_Introduction_Globbing.md
│   │   ├── TC3a_Shell_Variables.md
│   │   └── ANNEX_References_Seminar2.md
│   │
│   ├── S02_01_ASSIGNMENT.md                # Assignment specifications
│   └── S02_02_create_assignment.sh         # Assignment structure generator
│
├── resources/                          # 📚 Additional resources
│   └── S02_RESOURCES.md                    # Links and bibliography
│
└── tests/                              # ✅ Tests and validation
    └── TODO.txt                            # Placeholder for tests
```

---

## Usage Guide

### Step 1: Extract Archive

```bash
# If you received the .zip archive
unzip Seminar 2_COMPLETE.zip
cd Seminar 2_COMPLETE

# Or if you received .tar.gz
tar xzf Seminar 2_COMPLETE.tar.gz
cd Seminar 2_COMPLETE
```

### Step 2: Set Permissions

```bash
# Make all scripts executable
chmod +x scripts/bash/*.sh
chmod +x scripts/demo/*.sh
chmod +x scripts/python/*.py
chmod +x assignments/*.sh

# Verify
ls -la scripts/bash/
```

### Step 3: Set Up Environment

```bash
# Run the setup script (checks dependencies, creates directories)
./scripts/bash/S02_01_setup_seminar.sh

# Or manually:
mkdir -p ~/seminar_so/demo
cd ~/seminar_so/demo
```

### Step 4: Verify Functionality

```bash
# Test a quick demo
./scripts/demo/S02_01_hook_demo.sh

# If you see coloured and formatted output = everything works!
```

---

## For Instructors

### Pre-Seminar Checklist (15 min before)

```bash
# 1. Verify Bash version (minimum 4.0)
bash --version

# 2. Check optional tools
for cmd in figlet lolcat dialog pv cowsay; do
    which $cmd &>/dev/null && echo "✓ $cmd installed" || echo "✗ $cmd missing"
done

# 3. Create clean demo directory
rm -rf ~/demo_sem2 && mkdir ~/demo_sem2 && cd ~/demo_sem2

# 4. Set terminal with large, visible font
# (manual: Preferences → Font Size 14+)

# 5. Test projector/screen sharing
```

### Seminar Structure (100 minutes)

| Time | Activity | Material |
|------|----------|----------|
| 0:00-0:05 | 🎬 Hook Demo | `S02_01_hook_demo.sh` |
| 0:05-0:10 | 🗳️ Peer Instruction Q1 | `S02_03_PEER_INSTRUCTION.md` |
| 0:10-0:25 | 💻 Live Coding: Operators | `S02_05_LIVE_CODING_GUIDE.md` |
| 0:25-0:30 | 🧩 Parsons Problem #1 | `S02_04_PARSONS_PROBLEMS.md` |
| 0:30-0:45 | 🏃 Sprint #1: Pipes | `S02_06_SPRINT_EXERCISES.md` |
| 0:45-0:50 | 🗳️ Peer Instruction Q2 | `S02_03_PEER_INSTRUCTION.md` |
| 0:50-1:00 | ☕ BREAK | Passive demo on screen |
| 1:00-1:05 | 🔄 Reactivation Quiz | `S02_02_interactive_quiz.sh` |
| 1:05-1:20 | 💻 Live Coding: Filters + Loops | `S02_05_LIVE_CODING_GUIDE.md` |
| 1:20-1:25 | 🗳️ Peer Instruction Q3 | `S02_03_PEER_INSTRUCTION.md` |
| 1:25-1:40 | 🏃 Sprint #2: Filters | `S02_06_SPRINT_EXERCISES.md` |
| 1:40-1:48 | 🤖 LLM Exercise | `S02_07_LLM_AWARE_EXERCISES.md` |
| 1:48-1:50 | 🧠 Reflection + Wrap-up | `S02_10_SELF_ASSESSMENT_REFLECTION.md` |

### Assignment Evaluation with Autograder

```bash
# Evaluate single student
python3 scripts/python/S02_01_autograder.py ~/student_assignments/PopescuIon/

# Batch evaluate entire group
for d in ~/student_assignments/*/; do
    python3 scripts/python/S02_01_autograder.py "$d" >> results.csv
done

# Generate report
python3 scripts/python/S02_03_report_generator.py results.csv > group_report.html
```

---

## AI Usage Policy

This course **permits** AI tool usage (ChatGPT, Claude, Copilot, etc.) with conditions:

### What's Allowed
- ✅ Use AI for brainstorming, syntax lookup, debugging hints
- ✅ Ask AI to explain concepts or error messages
- ✅ Generate boilerplate code as a starting point

### What's Required
- 📝 Document AI use in your `REFLECTION.md` (what you asked, what you changed)
- 🧪 Test all AI-generated code — it often has subtle bugs
- 🧠 Understand every line you submit

### What to Avoid
- ❌ Submitting AI output without understanding it
- ❌ Copy-pasting without testing
- ❌ Expecting AI to handle edge cases correctly

### Why This Matters
The autograder includes AI pattern detection. Submissions with obvious AI fingerprints (overly elaborate comments, suspiciously perfect formatting, descriptive variable names unusual for beginners) may receive penalties:
- 2-4 AI indicators: warning only
- 3-4 AI indicators: -5% penalty
- 5+ AI indicators: -10% penalty + manual review

**The philosophy**: We don't ban AI because you'll use these tools professionally. Better to learn critical evaluation now than make costly mistakes later. The goal is to help you become a skilled evaluator of AI output, not just a consumer.

See `docs/S02_07_LLM_AWARE_EXERCISES.md` for exercises specifically designed to build these skills.

---

## For Students

### Getting Started Steps

1. Work through the main material: `docs/S02_02_MAIN_MATERIAL.md`
2. Complete the sprint exercises: `docs/S02_06_SPRINT_EXERCISES.md`
3. Test your understanding: `./scripts/bash/S02_02_interactive_quiz.sh`
4. Complete the assignment: `assignments/S02_01_ASSIGNMENT.md`

### Recommended Study Resources

| Priority | Resource | Estimated Time |
|----------|----------|----------------|
| 🔴 Required | Main Material | 45 min reading |
| 🔴 Required | Sprint Exercises (minimum 3) | 30 min practice |
| 🟡 Recommended | Visual Cheat Sheet | 10 min memorisation |
| 🟡 Recommended | Spectacular Demos | 15 min exploration |
| 🟢 Optional | Peer Instruction (self-test) | 20 min |
| 🟢 Optional | LLM-Aware Exercises | 30 min |

### How to Test Your Assignment Before Submission

```bash
# 1. Create assignment structure
./assignments/S02_02_create_assignment.sh "YourName" "GroupXX"

# 2. Complete the exercises in the created directory

# 3. Run the validator
./scripts/bash/S02_03_validator.sh ~/assignment_YourName_GroupXX/

# 4. Check the output - you should see passing tests for all
```

---

## Technical Requirements

### Required

| Component | Minimum Version | Verification |
|-----------|-----------------|--------------|
| **Ubuntu** | 22.04 LTS+ | `lsb_release -a` |
| **Bash** | 4.0+ | `bash --version` |
| Python | 3.8+ | `python3 --version` |
| **coreutils** | standard | `sort --version` |

### Optional (for spectacular demos)

```bash
# Install all optional tools
sudo apt update && sudo apt install -y \
    figlet lolcat cowsay fortune \
    pv dialog tree ncdu \
    htop bc jq

# Verify
which figlet lolcat dialog pv
```

### Quick Compatibility Check

```bash
# Run this one-liner for complete verification
echo "Bash: $(bash --version | head -1)" && \
echo "Python: $(python3 --version)" && \
echo "Sort: $(sort --version | head -1)" && \
for cmd in figlet lolcat pv dialog; do \
    which $cmd &>/dev/null && echo "✓ $cmd" || echo "✗ $cmd (optional)"; \
done
```

---

## Installation and Configuration

### Method 1: Direct Download (Students)

```bash
# If materials are on a server
wget https://materials.ase.ro/so/Seminar 2_COMPLETE.zip
unzip Seminar 2_COMPLETE.zip
cd Seminar 2_COMPLETE
./scripts/bash/S02_01_setup_seminar.sh
```

### Method 2: USB Stick (Laboratory)

```bash
# Mount USB (if not automount)
sudo mount /dev/sdb1 /mnt/usb

# Copy locally
cp -r /mnt/usb/Seminar 2_COMPLETE ~/
cd ~/Seminar 2_COMPLETE
chmod +x scripts/**/*.sh
```

### WSL Laboratory Configuration (Windows)

Standard ASE laboratory credentials:
- User: `stud`
- Password: `stud`
- Portainer (Docker management): `http://localhost:9000`
  - User: `stud`
  - Password: `studstudstud`

```bash
# In WSL Ubuntu
cd /mnt/c/Users/stud/Desktop
# Or any shared directory

# Setup
./scripts/bash/S02_01_setup_seminar.sh --wsl
```

---

## Frequently Encountered Problems

### 1. "Permission denied" when running scripts

```bash
# Problem
./script.sh
# bash: ./script.sh: Permission denied

# Solution
chmod +x script.sh
./script.sh

# Or run with bash explicitly
bash script.sh
```

### 2. Scripts cannot find commands (figlet, lolcat, etc.)

```bash
# Problem: Command not found

# Solution - install dependencies
sudo apt update
sudo apt install figlet lolcat pv dialog -y

# Or run scripts in fallback mode (without visual effects)
SIMPLE_MODE=1 ./scripts/demo/S02_01_hook_demo.sh
```

### 3. Encoding errors with Romanian characters

```bash
# Problem: Strange characters instead of ă, î, ș

# Solution - set the correct locale
export LANG=ro_RO.UTF-8
export LC_ALL=ro_RO.UTF-8

# Verify
locale
```

### 4. Interactive quiz doesn't work (dialog)

```bash
# Problem: dialog: command not found

# Solution 1: Install dialog
sudo apt install dialog -y

# Solution 2: Use text mode
./scripts/bash/S02_02_interactive_quiz.sh --text-mode
```

### 5. Python scripts give import errors

```bash
# Problem: ModuleNotFoundError

# Solution - install Python dependencies
pip3 install --user rich tabulate

# Or with requirements.txt
pip3 install -r requirements.txt --break-system-packages
```

### 6. Files don't save in WSL

```bash
# Problem: Read-only file system in WSL

# Solution - work in home directory
cd ~
mkdir -p seminar_so
cd seminar_so

# DO NOT work directly in /mnt/c/... for scripts
```

### 7. Strange exit codes in pipelines

```bash
# Problem: $? only returns the exit code of the last command

# Solution - use PIPESTATUS
cmd1 | cmd2 | cmd3
echo "Exit codes: ${PIPESTATUS[@]}"
# Displays: Exit codes: 0 1 0 (example)

# Or set pipefail
set -o pipefail
cmd1 | cmd2 | cmd3
echo $?  # Now returns the first non-zero
```

### 8. While read loop doesn't modify variables

```bash
# Problem: Variables modified in while | don't persist

count=0
cat file.txt | while read line; do
    ((count++))
done
echo $count  # Displays 0! (subshell problem)

# Solution - use process substitution or redirect
count=0
while read line; do
    ((count++))
done < file.txt
echo $count  # Displays the correct value
```

---

## Additional Resources

### Official Documentation
- [Bash Reference Manual](https://www.gnu.org/software/bash/manual/)
- [POSIX Shell Specification](https://pubs.opengroup.org/onlinepubs/9699919799/utilities/V3_chap02.html)
- [Linux man pages](https://man7.org/linux/man-pages/)

### Interactive Tutorials
- [Exercism Bash Track](https://exercism.org/tracks/bash)
- [HackerRank Shell Challenges](https://www.hackerrank.com/domains/shell)
- [OverTheWire Bandit](https://overthewire.org/wargames/bandit/)

### Recommended Books
- "The Linux Command Line" - William Shotts (free online)
- "Learning the bash Shell" - O'Reilly
- "Shell Scripting" - Steve Parker

### Community
- r/bash, r/linux, r/commandline on Reddit
- Unix & Linux Stack Exchange
- #bash on IRC (Libera.Chat)

---

## Licence and Attribution

This educational package is created for ASE Bucharest - CSIE, Operating Systems course.

Licence: CC BY-SA 4.0 - Free use with attribution

Contributions: 
- Original materials: SO ASE-CSIE Team
- Pedagogical adaptation: Brown & Wilson Framework, Anderson-Bloom
- Demo collection: BASH_MAGIC_COLLECTION

---

## Contact and Support

- Technical issues: Open an issue or contact the instructor
- Feedback: Use the feedback form at the end of the seminar
- Improvements: Pull requests are welcome!

---

*Last updated: January 2025*  
*Tested on: Ubuntu 24.04 LTS, WSL2 Ubuntu 22.04*
