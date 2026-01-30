# Seminar 3: Advanced Utilities, Professional Scripts and Automation

> Operating Systems | Bucharest University of Economic Studies - CSIE  
> Version: 1.1 | Date: January 2025  
> Issues: Open an issue in GitHub

---

## Table of Contents

1. [Description](#description)
2. [Learning Objectives](#learning-objectives)
3. [Visual Resources](#visual-resources)
4. [Package Structure](#package-structure)
5. [Usage Guide](#usage-guide)
6. [For Instructors](#for-instructors)
7. [For Students](#for-students)
8. [Technical Requirements](#technical-requirements)
9. [Security Notes](#security-notes)
10. [Installation and Configuration](#installation-and-configuration)
11. [Frequently Encountered Issues](#frequently-encountered-issues)
12. [Additional Resources](#additional-resources)
13. [Changelog](#changelog)

---

## Description

### Pedagogical Context

This seminar is a direct continuation of Seminar 2 and marks an important transition in the educational path:

| From | To |
|------|-----|
| Interactive commands | Professional scripts |
| Regular user | System administrator |
| Ad-hoc execution | Scheduled automation |

### Prerequisites

Students should have completed and understood:
- Seminar 1: Filesystem navigation, shell variables, basic globbing
- Seminar 2: Control operators (&&, ||, ;), I/O redirection, text filters, loops

### Topics

The seminar covers four main modules:

1. Advanced Search Utilities: `find`, `xargs`, `locate` - searching and batch processing
2. Professional Scripts: Parameters ($1-$9, $@, shift), `getopts`, long options
3. Unix Permissions System: `chmod`, `chown`, `umask`, SUID/SGID/Sticky Bit
4. Automation: `cron`, `at`, `batch` - task scheduling

---

## Learning Objectives

At the end of this seminar, students will be able to:

### Knowledge Level (Remember)

- [ ] List the main options of the `find` command
- [ ] Describe the structure of a crontab line
- [ ] Identify Unix permission components (rwx)

### Comprehension Level (Understand)

- [ ] Explain the difference between `$@` and `$*` in scripts
- [ ] Interpret permissions in octal and symbolic format
- [ ] Describe the role of SUID, SGID and Sticky Bit

### Application Level (Apply)

- [ ] Build complex searches with `find` and multiple criteria
- [ ] Write scripts that accept arguments and options using `getopts`
- [ ] Configure correct permissions for given scenarios

### Analysis Level (Analyse)

- [ ] Debug problems with cron jobs that do not work
- [ ] Identify security vulnerabilities in permission configurations
- [ ] Evaluate when to use `find -exec` vs `xargs`

### Evaluation Level (Evaluate)

- [ ] Justify the choice of an argument parsing method
- [ ] Critique LLM-generated responses for shell commands
- [ ] Propose improvements for existing scripts

### Creation Level (Create)

- [ ] Develop complete scripts with professional CLI interface
- [ ] Implement automation solutions with cron and logging
- [ ] Design permission schemes for complex scenarios

---

## Visual Resources

The `docs/images/` directory contains SVG diagrams for key concepts:

| Diagram | Description | Best for |
|---------|-------------|----------|
| `find_workflow.svg` | How find traverses directories and applies filters | Understanding find structure |
| `permissions_matrix.svg` | rwx to octal mapping with common patterns | Permission calculations |
| `xargs_vs_exec.svg` | Visual comparison of batch processing methods | Choosing the right approach |
| `cron_schedule.svg` | The 5 crontab fields with examples | Writing cron expressions |
| `getopts_flow.svg` | Flowchart of argument parsing with getopts | Implementing CLI options |

These diagrams are optimised for dark backgrounds and large font projection.

---

## Package Structure

```
SEM03/
│
├── README.md                              # This file
│
├── docs/                                  # Complete documentation
│   ├── images/                               # Visual diagrams (SVG)
│   │   ├── find_workflow.svg
│   │   ├── permissions_matrix.svg
│   │   ├── xargs_vs_exec.svg
│   │   ├── cron_schedule.svg
│   │   └── getopts_flow.svg
│   ├── S03_00_PEDAGOGICAL_ANALYSIS_PLAN.md   # Materials analysis
│   ├── S03_01_INSTRUCTOR_GUIDE.md            # Instructor guide
│   ├── S03_02_MAIN_MATERIAL.md               # Theoretical material
│   ├── S03_03_PEER_INSTRUCTION.md            # MCQ for PI
│   ├── S03_04_PARSONS_PROBLEMS.md            # Code reordering
│   ├── S03_05_LIVE_CODING_GUIDE.md           # Live coding guide
│   ├── S03_06_SPRINT_EXERCISES.md            # Timed exercises
│   ├── S03_07_LLM_AWARE_EXERCISES.md         # LLM evaluation exercises
│   ├── S03_08_SPECTACULAR_DEMOS.md           # Visual demos
│   ├── S03_09_VISUAL_CHEAT_SHEET.md          # One-pager reference
│   ├── S03_10_SELF_ASSESSMENT_REFLECTION.md  # Checklist
│   └── lo_traceability.md                    # LO matrix + Parsons
│
├── scripts/                               # Functional scripts
│   ├── bash/
│   │   ├── S03_01_setup_seminar.sh           # Environment setup
│   │   ├── S03_02_interactive_quiz.sh        # Interactive quiz
│   │   └── S03_03_validator.sh               # Assignment validator
│   ├── demo/
│   │   ├── S03_01_hook_demo.sh               # Spectacular hook
│   │   ├── S03_02_demo_find_xargs.sh         # find and xargs demo
│   │   ├── S03_03_demo_getopts.sh            # Argument parsing
│   │   ├── S03_04_demo_permissions.sh        # Permissions demo
│   │   └── S03_05_demo_cron.sh               # Cron generator
│   └── python/
│       ├── S03_01_autograder.py              # Autograder
│       ├── S03_02_quiz_generator.py          # Quiz generator
│       └── S03_03_report_generator.py        # Report generator
│
├── presentations/                         # Interactive presentations
│   ├── S03_01_presentation.html              # Main presentation
│   └── S03_02_cheat_sheet.html               # Interactive cheat sheet
│
├── homework/                              # Assignments
│   ├── OLD_HW/                               # Original source files
│   ├── S03_01_HOMEWORK.md                    # Assignment description
│   ├── S03_02_create_homework.sh             # Structure generator
│   └── S03_03_EVALUATION_RUBRIC.md           # Evaluation rubric
│
├── formative/                             # Formative assessment
│   ├── quiz.yaml                             # Quiz in YAML
│   └── quiz_lms.json                         # Quiz for LMS export
│
├── tests/                                 # Automated tests
│   ├── README.md
│   └── run_all_tests.sh
│
├── resources/                             # Additional resources
│   └── S03_RESOURCES.md
│
├── ci/                                    # CI/CD configuration
│   ├── github_actions.yml
│   └── linting.toml
│
├── Makefile                               # Build orchestration
└── requirements.txt                       # Python dependencies
```

---

## Usage Guide

### Step 1: Extraction

```bash
# Download and extract the package
unzip SEM03.zip -d ~/seminars/
cd ~/seminars/SEM03/
```

### Step 2: Set Script Permissions

```bash
# Make all scripts executable
chmod +x scripts/bash/*.sh
chmod +x scripts/demo/*.sh
chmod +x scripts/python/*.py
```

### Step 3: Setup Working Environment

```bash
# Run the setup script
./scripts/bash/S03_01_setup_seminar.sh

# Verify installation
./scripts/bash/S03_01_setup_seminar.sh --check
```

### Step 4: Use Make Targets

```bash
# See available commands
make help

# Run quiz
make quiz

# Run tests
make test

# Check code quality
make lint

# Full validation
make all
```

---

## For Instructors

### Seminar Preparation Checklist

#### 1-2 days before:
- [ ] Verify Docker/WSL functionality in the laboratory
- [ ] Run `S03_01_setup_seminar.sh` on the presentation machine
- [ ] Review diagrams in `docs/images/` for projection
- [ ] Review the instructor guide `docs/S03_01_INSTRUCTOR_GUIDE.md`
- [ ] Print cheat sheets for students (optional)

#### 15 minutes before:
- [ ] Start terminal with enlarged font (Ctrl+Shift+Plus)
- [ ] Open demo files in separate tabs
- [ ] Create sandbox directory: `mkdir -p ~/demo_sem3`
- [ ] Verify cron is working: `systemctl status cron`

### Seminar Structure (100 min)

| Time | Duration | Activity | Materials |
|------|----------|----------|-----------|
| 0:00 | 5 min | Hook: Power of Find | `S03_01_hook_demo.sh` |
| 0:05 | 5 min | PI #1: find vs locate | `S03_03_PEER_INSTRUCTION.md` |
| 0:10 | 15 min | Live Coding: find & xargs | `S03_05_LIVE_CODING_GUIDE.md` |
| 0:25 | 5 min | Parsons Problem | `S03_04_PARSONS_PROBLEMS.md` |
| 0:30 | 15 min | Sprint #1: Find Master | `S03_06_SPRINT_EXERCISES.md` |
| 0:45 | 5 min | PI #2: $@ vs $* | PI-06 |
| 0:50 | 10 min | BREAK | - |
| 1:00 | 5 min | Reactivation: Permissions Quiz | Quick quiz |
| 1:05 | 15 min | Live Coding: Permissions | Session 4 |
| 1:20 | 5 min | PI #3: SUID | PI-13 |
| 1:25 | 15 min | Sprint #2: Professional Script | Sprint S1 |
| 1:40 | 8 min | LLM + Cron Demo | `S03_07_LLM_AWARE_EXERCISES.md` |
| 1:48 | 2 min | Reflection | Final questions |

### Important Warnings

> **SECURITY**: This seminar involves working with permissions. Always emphasise risks and NEVER demonstrate `chmod 777` as an acceptable solution!

- Permission exercises are done in `~/sandbox`, NOT in system directories
- Always demonstrate `find -print` before `-delete` or `-exec rm`
- Cron jobs are tested with `echo` before real commands
- Do not use sudo for normal exercises

---

## For Students

### Getting Started Steps

1. Read the main material: `docs/S03_02_MAIN_MATERIAL.md`
2. Study the diagrams: `docs/images/` (especially permissions_matrix.svg)
3. Practice with demos: `scripts/demo/`
4. Solve sprint exercises: `docs/S03_06_SPRINT_EXERCISES.md`
5. Test your knowledge: `make quiz`
6. Complete the assignment: `homework/S03_01_HOMEWORK.md`

### Recommended Study Resources

| Resource | Description | Priority |
|----------|-------------|----------|
| Visual Diagrams | SVG files in docs/images/ | High |
| Cheat Sheet | One-pager with all commands | High |
| Main Material | Complete theory with subgoal labels | High |
| Demo Scripts | Commented functional examples | Medium |
| Interactive Quiz | Self-assessment | Medium |

### How to Test Your Assignment

```bash
# Use the included validator
./scripts/bash/S03_03_validator.sh ~/my_assignment/

# Or use make
make test

# Or test manually
shellcheck script.sh
bash -n script.sh
```

---

## Technical Requirements

### Operating System
- Ubuntu 24.04 LTS (or newer)
- **WSL2** on Windows (Ubuntu)
- macOS with Homebrew (partially compatible)

### Required Software

```bash
# Quick verification
which find xargs locate chmod crontab at

# Install additional packages (optional)
sudo apt update
sudo apt install -y dialog shellcheck figlet
```

### Laboratory Credentials

| Parameter | Value |
|-----------|-------|
| User | `stud` |
| Password | `stud` |
| Portainer | `localhost:9000` |
| Portainer User | `stud` |
| Portainer Pass | `studstudstud` |

### Minimum Requirements

- **RAM**: 1 GB available
- **Disk**: 100 MB free space
- **Terminal**: ANSI colours support

---

## Security Notes

### Critical Rules

1. Do NOT run unknown scripts with sudo
   ```bash
   # WRONG
   sudo ./unknown_script.sh
   
   # CORRECT - verify first
   cat ./script.sh
   shellcheck ./script.sh
   ./script.sh  # without sudo
   ```

2. Test permissions in dedicated directories
   ```bash
   mkdir -p ~/sandbox/permissions_test
   cd ~/sandbox/permissions_test
   # Work only here for exercises
   ```

3. **Caution with find using -exec and rm**
   ```bash
   # WRONG - dangerous!
   find / -name "*.tmp" -exec rm {} \;
   
   # CORRECT - test first
   find /tmp -name "*.tmp" -print  # see what it finds
   find /tmp -name "*.tmp" -exec rm -i {} \;  # with confirmation
   ```

4. Cron - test with echo
   ```bash
   # Testing
   * * * * * echo "Test $(date)" >> /tmp/cron_test.log
   
   # After verification, add the real command
   ```

5. NEVER chmod 777
   ```bash
   # WRONG - security vulnerability
   chmod 777 /var/www/html
   
   # CORRECT
   chmod 755 /var/www/html
   chown -R www-data:www-data /var/www/html
   ```

---

## Installation and Configuration

### Method 1: Direct Download

```bash
# From the course web interface
wget https://course.ase.ro/.../SEM03.zip
unzip SEM03.zip
cd SEM03
make setup
```

### Method 2: Git Clone

```bash
git clone https://github.com/ase-so/seminar-materials.git
cd seminar-materials/SEM03
make setup
```

### Method 3: Copy from USB

```bash
cp -r /media/usb/SEM03 ~/
cd ~/SEM03
chmod +x scripts/**/*.sh
make setup
```

---

## Frequently Encountered Issues

### 1. Permission Denied when executing script

Problem: `bash: ./script.sh: Permission denied`

Solution:
```bash
chmod +x script.sh
./script.sh
# or
bash script.sh
```

### 2. find: permission denied on multiple directories

Problem: Many error messages when searching system

Solution:
```bash
# Redirect errors
find / -name "*.conf" 2>/dev/null
```

### 3. getopts does not parse long options (--help)

Problem: `getopts` does not recognise `--help`

Explanation: `getopts` only supports short options (-h). For long options, use manual parsing with `case` and `while`.

### 4. Cron job not running

Checklist:
```bash
# 1. Check cron service
systemctl status cron

# 2. Check syntax
crontab -l

# 3. Check paths (must be absolute)
which /usr/bin/script.sh

# 4. Check logs
grep CRON /var/log/syslog
```

### 5. umask does not persist between sessions

Problem: After logout, umask reverts to default value

Solution:
```bash
# Add to ~/.bashrc
echo "umask 022" >> ~/.bashrc
source ~/.bashrc
```

### 6. SUID does not work on bash scripts

Explanation: For security reasons, SUID is ignored for interpreted scripts (bash, python). It only works for compiled binaries.

---

## Additional Resources

- [GNU Find Manual](https://www.gnu.org/software/findutils/manual/html_mono/find.html)
- [Bash Reference Manual](https://www.gnu.org/software/bash/manual/)
- [Linux Permissions Guide](https://linuxhandbook.com/linux-file-permissions/)
- [Crontab Guru](https://crontab.guru/) - Visual crontab generator
- [ShellCheck](https://www.shellcheck.net/) - Linter for scripts

---

## Lessons Learnt (from previous iterations)

### What Worked Well

| Element | Impact | Evidence |
|---------|--------|----------|
| Hook with "find largest files" | Captures attention instantly | 90% engagement in first 5 minutes |
| Parsons problems for find | Students prefer arranging vs writing from scratch | Average time -40% compared to writing |
| Demo chmod 777 → hack | Memorable and impactful | Misconception M3.1 dropped from 80% to 65% |
| LLM evaluation exercises | Develops critical thinking | Positive feedback from cohort 23 |

### What We Adjusted

| Problem | Solution | Result |
|---------|----------|--------|
| Students copying homework | Added verification challenges with timestamp | Under evaluation |
| ACL exercises too difficult | Moved to optional advanced seminar | OK |
| Confusion between cron and at | Created separate diagrams | Improved clarity |
| Quiz ignored (JSON format) | Added quiz_runner.py interactive | v1.2 |

### Student Feedback (anonymous, cohort 2024)

> "Finally understood why permissions matter"

> "The LLM exercise made me realise I was not understanding, just copying"

> "Would have liked more time for sprints" 
  — *Note: Increased from 10 to 15 minutes*

> "The chmod 777 hack demo scared me a bit but in a good way"

---

## Troubleshooting for Instructors

### When Things Do Not Work in the Lab

#### Student insists "it works on my machine" but the script is wrong
Check:
1. Running on macOS? (find has different options)
2. Has strange aliases in .bashrc?
3. Test with `env -i bash --norc --noprofile`

#### Cron does not start in WSL
WSL does not have systemd by default. Solutions:
```bash
# Method 1: manual start
sudo service cron start

# Method 2: in /etc/wsl.conf
[boot]
systemd=true
```

#### Projector does not show terminal colours
Fallback: `export NO_COLOR=1` or `--no-color` in scripts.
We added automatic detection in validator.sh (line 77).

#### locate does not find anything
```bash
# Check if installed
which locate || sudo apt install mlocate

# Update database
sudo updatedb

# Test
locate --version
```

### Institutional Context (ASE-CSIE)

#### Dorobanti Labs
- PCs have Ubuntu 24.04 since autumn 2024
- Portainer available at localhost:9000 (user: stud/studstudstud)
- Check if cron service is running BEFORE the session

#### Correlations with Other Courses
- **Computer Networks** (sem. 4): find + netstat for monitoring
- **Databases** (sem. 3): cron for automatic backups
- **Security** (sem. 5): permissions audit — we reuse our script

---

## Changelog

### v1.2 - January 2025
- Added quiz_runner.py for interactive quiz sessions
- Added .shellcheckrc with teaching-adapted rules
- Added CHANGELOG.md with full history
- Enhanced LLM-Aware exercises with Code Archaeology and Trap Questions
- Added Verification Challenges to homework (anti-AI measures)
- Added Reflection Prompts to Self-Assessment
- Added Lessons Learnt and Troubleshooting sections
- Removed duplicate Romanian files
- Fixed minor inconsistencies

### v1.1 - January 2025
- Added visual diagrams in `docs/images/`
- Renamed folders to ENos convention (homework, tests and presentations)
- Added PP-06 and PP-07 to lo_traceability.md
- Updated Makefile with new directory structure
- Fixed British English spelling throughout

### v1.0 - January 2025
- Initial version
- Includes all 4 modules
- Scripts tested on Ubuntu 24.04 LTS
- Complete integration with the Brown & Wilson framework

---

*Material created for the Operating Systems course | Bucharest UES - CSIE*  
*Maintained by ing. dr. Antonio Clim*  
*File prefix: S03_ (Seminar 3 in internal numbering)*
