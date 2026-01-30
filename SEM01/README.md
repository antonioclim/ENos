# Seminar 1: Bash Shell - Complete Package

> **Operating Systems** | ASE Bucharest - CSIE  
> **Version:** 2.1 | **Updated:** January 2025

---

## Contents

- [Description](#description)
- [Package Structure](#package-structure)
- [Usage Guide](#usage-guide)
- [For Instructors](#for-instructors)
- [For Students](#for-students)
- [Anti-Plagiarism Infrastructure](#anti-plagiarism-infrastructure)
- [Technical Requirements](#technical-requirements)
- [Installation and Configuration](#installation-and-configuration)

---

## Description

This package contains all the materials needed for **Seminar 1: Bash Shell** from the Operating Systems course.

> I developed these materials over 5+ years of teaching at ASE. The structure reflects exactly the mistakes I've seen from students and the solutions that actually work. If you find errors or have suggestions, they are welcome!

The package includes:

- ✅ Interactive HTML presentations
- ✅ Demo scripts for live coding
- ✅ Python scripts for self-assessment
- ✅ Assignments and templates for students
- ✅ Cheat sheets and resources
- ✅ Randomised quiz system
- ✅ Automatic assignment validator

### Learning Objectives

After completing this seminar, students will be able to:

1. **Navigate** efficiently in the Linux file system
2. **Understand** the FHS hierarchy and purpose of each directory
3. **Work** with shell variables (local, environment, special)
4. **Configure** the working environment through ~/.bashrc
5. **Use** wildcards (globbing) for file selection
6. **Write** basic bash scripts

---

## Package Structure

```
SEM01_COMPLETE/
├── 📄 README.md                           # This file
├── 📄 CHANGELOG.md                        # Version history
├── 📄 Makefile                            # Build automation
├── 📂 docs/                               # Pedagogical documentation (00-11)
│   ├── S01_00_PEDAGOGICAL_ANALYSIS_PLAN.md
│   ├── S01_01_INSTRUCTOR_GUIDE.md
│   ├── S01_02_MAIN_MATERIAL.md
│   ├── S01_03_PEER_INSTRUCTION.md
│   ├── S01_04_PARSONS_PROBLEMS.md
│   ├── S01_05_LIVE_CODING_GUIDE.md
│   ├── S01_06_SPRINT_EXERCISES.md
│   ├── S01_07_LLM_AWARE_EXERCISES.md
│   ├── S01_08_SPECTACULAR_DEMOS.md
│   ├── S01_09_VISUAL_CHEAT_SHEET.md
│   ├── S01_10_SELF_ASSESSMENT_REFLECTION.md
│   ├── S01_11_EXTERNAL_PLAGIARISM_TOOLS.md  # NEW: MOSS/JPlag guide
│   └── lo_traceability.md
├── 📂 scripts/
│   ├── 📂 bash/                           # Bash utility scripts
│   │   ├── S01_01_setup_seminar.sh
│   │   ├── S01_02_interactive_quiz.sh
│   │   └── S01_03_validator.sh
│   ├── 📂 demo/                           # Live coding demos
│   │   ├── S01_01_hook_demo.sh
│   │   ├── S01_02_demo_quoting.sh
│   │   ├── S01_03_demo_variables.sh
│   │   ├── S01_04_demo_fhs.sh
│   │   └── S01_05_demo_globbing.sh
│   └── 📂 python/                         # Python tools
│       ├── S01_01_autograder.py
│       ├── S01_02_quiz_generator.py
│       ├── S01_03_report_generator.py
│       ├── S01_04_assignment_generator.py
│       ├── S01_05_plagiarism_detector.py  # Updated: + AI patterns
│       └── S01_06_ai_fingerprint_scanner.py
├── 📂 homework/                           # Student assignments
│   ├── S01_01_HOMEWORK.md
│   ├── S01_03_EVALUATION_RUBRIC.md
│   ├── S01_04_ORAL_VERIFICATION_LOG.md    # NEW: Verification form
│   ├── OLD_HW/
│   └── solutions/
├── 📂 presentations/
│   ├── S01_01_presentation.html
│   └── S01_02_cheat_sheet.html
├── 📂 formative/                          # Quiz system
│   ├── quiz.yaml
│   ├── quiz_lms.json
│   └── quiz_runner.py
├── 📂 resources/
│   └── S01_RESOURCES.md
├── 📂 tests/
│   ├── test_quiz.py
│   └── run_all_tests.sh
└── 📂 ci/
    ├── github_actions.yml                 # Updated: coverage threshold
    └── linting.toml
```

---

## Usage Guide

### Quick Steps

```bash
# 1. Unzip the package
unzip Seminar1_COMPLETE.zip
cd Seminar1_COMPLETE

# 2. Make scripts executable
chmod +x scripts/**/*.sh

# 3. Run setup for the lab environment
./scripts/bash/S01_01_setup_seminar.sh

# 4. Open the presentation in browser
xdg-open presentations/S01_01_presentation.html
# or on macOS: open presentations/S01_01_presentation.html
```

---

## For Instructors

### Seminar Preparation (30 min before)

1. **Check the environment**:
   ```bash
   ./scripts/bash/S01_01_setup_seminar.sh --full
   ```

2. **Test the demos**:
   ```bash
   ./scripts/demo/S01_01_hook_demo.sh
   ```

3. **Open the materials**:
   - Presentation: `presentations/S01_01_presentation.html`
   - Live coding guide: `docs/S01_05_LIVE_CODING_GUIDE.md`
   - Peer instruction: `docs/S01_03_PEER_INSTRUCTION.md`

### Seminar Structure (100 min)

| Time | Activity | Material |
|------|----------|----------|
| 0-3 | Hook demo | `S01_01_hook_demo.sh` |
| 3-8 | Peer Instruction Q1 | Slide 6 |
| 8-23 | Live coding navigation | `docs/S01_05_LIVE_CODING_GUIDE.md` |
| 23-28 | Parsons Problem | `docs/S01_04_PARSONS_PROBLEMS.md` |
| 28-43 | Sprint 1: System Explorer | `docs/S01_06_SPRINT_EXERCISES.md` |
| 43-48 | Peer Instruction Q2 | Slide 8 |
| 48-58 | **BREAK** | |
| 58-63 | Reactivation quiz | `S01_02_quiz_interactiv.sh` |
| 63-78 | Live coding variables | Live coding guide |
| 78-83 | Peer Instruction Q3 | |
| 83-98 | Sprint 2: Shell Configurator | |
| 98-100 | Wrap-up, assignment | |

### Assignment Evaluation

```bash
# Automatic evaluation for one student
python3 scripts/python/S01_01_autograder.py ~/assignments/JohnSmith/

# Generate report for entire group
python3 scripts/python/S01_03_report_generator.py --input results/ --output reports/

# Generate unique quizzes for exam
python3 scripts/python/S01_02_quiz_generator.py --students 30 --output quizzes/
```

---

## Anti-Plagiarism Infrastructure

This package includes a comprehensive anti-plagiarism system:

| Tool | Command | Purpose |
|------|---------|---------|
| Internal Detector | `make plagiarism-check SUBMISSIONS=./` | Fast similarity + AI patterns |
| MOSS | `make moss-check MOSS_USERID=... SUBMISSIONS=./` | Structural comparison |
| JPlag | `make jplag-check SUBMISSIONS=./` | Offline detailed analysis |
| Oral Verification | `homework/S01_04_ORAL_VERIFICATION_LOG.md` | Understanding confirmation |

### Quick Plagiarism Check

```bash
# Run internal detector (fast, immediate)
make plagiarism-check SUBMISSIONS=./submissions/

# The detector will report:
# - EXACT: 100% identical files
# - REORDERED: Same lines, different order
# - SIMILAR: Above threshold (default 85%)
# - AI_PATTERNS: Likely AI-generated code indicators
```

### Oral Verification Protocol

Every student must complete oral verification (10% of grade):
1. Print `homework/S01_04_ORAL_VERIFICATION_LOG.md`
2. Ask 2 questions from the autograder-generated list
3. Document responses and red flags
4. Both student and instructor sign

See `docs/S01_11_EXTERNAL_PLAGIARISM_TOOLS.md` for MOSS/JPlag setup.

---

## For Students

### Start Here

1. **Open the cheat sheet**:
   ```bash
   xdg-open presentations/S01_02_cheat_sheet.html
   ```

2. **Create the assignment structure**:
   ```bash
   ./assignments/S01_02_create_assignment.sh "Your Name" "Group"
   ```

3. **Test your assignment before submission**:
   ```bash
   ./scripts/bash/S01_03_validator.sh ~/seminar1_assignment/
   ```

4. **Practice with the quiz**:
   ```bash
   ./scripts/bash/S01_02_quiz_interactiv.sh
   ```

### Study Resources

- 📖 Read: `docs/S01_02_MAIN_MATERIAL.md`
- 🎯 Practice: `docs/S01_06_SPRINT_EXERCISES.md`
- 📝 Reflect: `docs/S01_10_SELF_ASSESSMENT_REFLECTION.md`
- 🔗 Explore: `resources/S01_RESOURCES.md`

---

## Technical Requirements

### Mandatory
- Ubuntu 20.04+ / WSL2 / macOS with Bash 4.0+
- Python 3.8+ (for evaluation scripts)
- Modern browser (Chrome, Firefox, Edge)

### Optional (for spectacular demos)
```bash
sudo apt-get install figlet lolcat cmatrix cowsay tree ncdu pv dialog
```

### Installation Verification
```bash
bash --version    # Should be 4.0+
python3 --version # Should be 3.8+
```

---

## Installation and Configuration

### Method 1: Direct Download
```bash
# Download and unzip
wget [URL]/Seminar1_COMPLETE.zip
unzip Seminar1_COMPLETE.zip
cd Seminar1_COMPLETE
```

### Method 2: Copy to USB Stick
1. Copy the entire `Seminar1_COMPLETE` folder
2. Copy to the lab computer
3. Run `setup_seminar.sh`

### Lab Configuration (WSL)
```bash
# Standard lab credentials
# User: stud
# Pass: stud

# Portainer (if available)
# URL: localhost:9000
# User: stud
# Pass: studstudstud
```

---

## Licence

Materials are created for educational use within ASE Bucharest - CSIE.
Redistribution outside the course requires approval.

---

## Common Problems

### "Permission denied" when running script
```bash
chmod +x script.sh
./script.sh
```

### Presentation doesn't open
```bash
# Try directly with browser
firefox presentations/S01_01_presentation.html
# or
google-chrome presentations/S01_01_presentation.html
```

### Python can't find modules
```bash
pip3 install --user pathlib
```

---

*Created with ❤️ for ASE Bucharest students*

**Last updated**: January 2025
