# Seminar 4: Text Processing - Regex, GREP, SED, AWK

> Operating Systems | Bucharest University of Economic Studies - CSIE  
> Version: 1.0 | Date: January 2025  
> Author: OS Educational Materials

---

## Table of Contents

1. [Description](#-description)
2. [Learning Objectives](#-learning-objectives)
3. [Why This Seminar Matters](#-why-this-seminar-matters)
4. [Package Structure](#-package-structure)
5. [Usage Guide](#-usage-guide)
6. [For Instructors](#-for-instructors)
7. [For Students](#-for-students)
8. [Technical Requirements](#️-technical-requirements)
9. [Installation and Configuration](#-installation-and-configuration)
10. [Frequently Encountered Issues](#-frequently-encountered-issues)
11. [Additional Resources](#-additional-resources)

---

## Description

### Seminar Context

This seminar represents the direct continuation of SEM05-06 and forms part of the advanced command-line data processing series. It assumes that students already possess solid knowledge of:

- File system navigation and environment variables
- Operators, I/O redirection and basic filters (cat, head, tail, sort, uniq, wc)
- The `find` command and `xargs` for batch processing
- Bash scripting with arguments and control structures
- Permissions and job scheduling with `cron`

### What This Seminar Introduces

Seminar 4 introduces the "Magic Triad" of text processing in Unix/Linux:

| Tool | Primary Role | Analogy |
|------|--------------|---------|
| **grep** | Search and filtering | "The Detective" - finds patterns |
| **sed** | Stream editing | "The Surgeon" - modifies text on-the-fly |
| **awk** | Structured processing | "The Analyst" - reports and calculations |

Additionally, the seminar covers:

- Regular Expressions (Regex): The universal language for describing text patterns
- The nano editor: A simple and accessible text editor for quick editing

### Conceptual Transition

```
SEM01-06                          SEM07-08
═══════════════════              ═══════════════════════════
Simple commands       →          Complex patterns
Individual filters    →          Powerful pipelines
echo/cat for editing  →          nano for real editing
Manual processing     →          Automation with regex
```

---

## Learning Objectives

Upon completion of this seminar, students will be able to:

### Level 1: Knowledge and Comprehension
- [ ] Explain the difference between BRE (Basic Regular Expression) and ERE (Extended Regular Expression)
- [ ] Identify regex metacharacters and their purpose
- [ ] Describe the processing model of grep, sed and awk

### Level 2: Application
- [ ] Construct regular expressions for validation (email, IP, telephone)
- [ ] Use grep with the -i, -v, -n, -c, -o, -E options for efficient searching
- [ ] Apply sed for substitutions, deletions and text modifications
- [ ] Process CSV/TSV files with awk for extraction and calculations

### Level 3: Analysis and Synthesis
- [ ] Combine grep, sed and awk in pipelines for complex tasks
- [ ] Analyse server logs for extracting statistics
- [ ] Create formatted reports from structured data
- [ ] Evaluate the efficiency of different processing approaches

### Level 4: Evaluation
- [ ] Choose the appropriate tool for each type of problem
- [ ] Debug regular expressions that do not function as expected
- [ ] Optimise one-liners for performance and clarity

---

## Why This Seminar Matters

### Immediate Practical Relevance

grep, sed and awk are used DAILY by:
- System administrators for log analysis
- Developers for code and data processing
- DevOps engineers for automation
- Data scientists for data pre-processing

### Transferability

Regular expressions appear in ALL modern programming languages:

```
Python:     import re; re.search(r'\d+', text)
JavaScript: text.match(/\d+/g)
Java:       Pattern.compile("\\d+")
C#:         Regex.Match(text, @"\d+")
SQL:        WHERE column REGEXP '^[A-Z]'
```

### Productivity Multiplication

| Approach | Time for 10,000 files |
|----------|----------------------|
| Manual (GUI) | ~10 hours |
| Simple scripts | ~30 minutes |
| grep + sed + awk | ~30 seconds |

> "The difference between a junior and a senior is often measured in one-liners."

---

## Package Structure

```
SEM07-08_COMPLET/
│
├── 📄 README.md                    ← YOU ARE HERE
│
├── 📂 docs/                        # Complete documentation
│   ├── S04_00_PEDAGOGICAL_ANALYSIS_PLAN.md
│   ├── S04_01_INSTRUCTOR_GUIDE.md
│   ├── S04_02_MAIN_MATERIAL.md
│   ├── S04_03_PEER_INSTRUCTION.md
│   ├── S04_04_PARSONS_PROBLEMS.md
│   ├── S04_05_LIVE_CODING_GUIDE.md
│   ├── S04_06_SPRINT_EXERCISES.md
│   ├── S04_07_LLM_AWARE_EXERCISES.md
│   ├── S04_08_SPECTACULAR_DEMOS.md
│   ├── S04_09_VISUAL_CHEAT_SHEET.md
│   └── S04_10_SELF_ASSESSMENT_REFLECTION.md
│
├── 📂 scripts/                     # Functional scripts
│   ├── bash/
│   │   ├── S04_01_setup_seminar.sh
│   │   ├── S04_02_interactive_quiz.sh
│   │   └── S04_03_validator.sh
│   ├── demo/
│   │   ├── S04_01_hook_demo.sh
│   │   ├── S04_02_demo_regex.sh
│   │   ├── S04_03_demo_grep.sh
│   │   ├── S04_04_demo_sed.sh
│   │   ├── S04_05_demo_awk.sh
│   │   └── S04_06_demo_nano.sh
│   └── python/
│       ├── S04_01_autograder.py
│       ├── S04_02_quiz_generator.py
│       └── S04_03_report_generator.py
│
├── 📂 presentations/                  # Interactive HTML slides
│   ├── S04_01_presentation.html
│   └── S04_02_cheat_sheet.html
│
├── 📂 homework/                        # Assignments and original materials
│   ├── OLD_HW/                     # Original source files
│   │   ├── TC2f_Expresii_Regulate.md
│   │   ├── TC4c_AWK.md
│   │   ├── TC4d_SED.md
│   │   ├── TC4e_GREP.md
│   │   ├── TC4f_VI_VIM.md         # Kept for reference (not used)
│   │   └── ANEXA_Referinte_Seminar4.md
│   ├── S04_01_TEMA.md
│   └── S04_02_creeaza_tema.sh
│
├── 📂 resources/                     # Auxiliary materials
│   ├── S04_RESOURCES.md
│   ├── sample_data/               # Test data for exercises
│   │   ├── access.log
│   │   ├── employees.csv
│   │   ├── config.txt
│   │   └── emails.txt
│   └── regex_tester.sh
│
└── 📂 tests/                       # Tests and validations
    └── TODO.txt
```

---

## Usage Guide

### Step 1: Extraction and Preparation

```bash
# Extract the package
unzip SEM07-08_COMPLET.zip
cd SEM07-08_COMPLET

# Verify the structure
ls -la
```

### Step 2: Set Execution Permissions

```bash
# Grant execution permissions for all scripts
chmod +x scripts/bash/*.sh
chmod +x scripts/demo/*.sh
chmod +x scripts/python/*.py
```

### Step 3: Run Initial Setup

```bash
# This script checks and installs the necessary dependencies
./scripts/bash/S04_01_setup_seminar.sh
```

### Step 4: Verify Sample Data

```bash
# Confirm that test data is available
ls -la resources/sample_data/
head resources/sample_data/access.log
```

### Step 5: Begin Exploration

```bash
# For instructors: start with the guide
less docs/S04_01_INSTRUCTOR_GUIDE.md

# For students: start with the main material
less docs/S04_02_MAIN_MATERIAL.md
```

---

## For Instructors

### Time Recommendations

This seminar is THE MOST DENSE in the course. Do not attempt to cover everything in a single session.

| Component | Recommended Time | Priority |
|-----------|------------------|----------|
| Regex fundamentals | 15 min | CRITICAL |
| GREP in depth | 20 min | CRITICAL |
| SED basics | 15 min | HIGH |
| AWK basics | 15 min | HIGH |
| nano intro | 5 min | MEDIUM |
| Practical exercises | 30 min | CRITICAL |

### Recommended Proportion

```
GREP: ████████████████████ 40%
SED:  ███████████████      30%
AWK:  ██████████           20%
nano: █████                10%
```

### What to Emphasise

1. Frequent patterns, not obscure edge cases
2. Live demos are essential - students learn by watching
3. Typical mistakes - show and explain why they do not work
4. The BRE/ERE difference - a major source of confusion

### What to Avoid

- Do not attempt to cover PCRE in detail (mention only)
- Do not get lost in advanced sed options (hold space etc.)
- Do not insist on complex awk (custom functions, getline)
- Do not compare vim with nano - we use only nano

---

## For Students

### Learning Philosophy

> DO NOT MEMORISE - UNDERSTAND THE CONCEPTS!

Regex and text processing tools are practical skills. The best way to learn:

1. Experiment - open the terminal and test
2. Make mistakes - you understand better when you see what does NOT work
3. Combine - the power comes from pipelines
4. Use resources - the cheat sheet is your friend

### Essential Resources

| Resource | Purpose | Link |
|----------|---------|------|
| regex101.com | Regex testing and debugging | https://regex101.com |
| explainshell.com | Command explanations | https://explainshell.com |
| Cheat Sheet | Quick reference | `docs/S04_09_VISUAL_CHEAT_SHEET.md` |

### Recommended Study Order

```
1. Regex basics     → docs/S04_02_MAIN_MATERIAL.md (Module 1)
2. GREP            → docs/S04_02_MAIN_MATERIAL.md (Module 2)
3. GREP practice   → docs/S04_06_SPRINT_EXERCISES.md (Sprints G1-G2)
4. SED             → docs/S04_02_MAIN_MATERIAL.md (Module 3)
5. AWK             → docs/S04_02_MAIN_MATERIAL.md (Module 4)
6. nano            → docs/S04_02_MAIN_MATERIAL.md (Module 5)
7. Combinations    → docs/S04_08_SPECTACULAR_DEMOS.md
8. Self-assessment → docs/S04_10_SELF_ASSESSMENT_REFLECTION.md
```

### Practical Tips

```bash
# ALWAYS test on small data before production
echo "test data" | grep 'pattern'

# Use -n with sed to see what it would do
sed -n 's/old/new/p' file.txt

# Verify with awk on a few lines
head -5 file.csv | awk -F',' '{print $2}'
```

---

## Technical Requirements

### Operating System

- Recommended: Ubuntu 24.04 LTS
- Accepted: Any modern Linux distribution, WSL2 on Windows
- macOS: Works, but some GNU options may differ

### Required Software

| Package | Verification | Note |
|---------|--------------|------|
| grep | `grep --version` | GNU grep 3.x |
| sed | `sed --version` | GNU sed 4.x |
| gawk | `awk --version` | GNU Awk 5.x |
| nano | `nano --version` | nano 7.x |
| bash | `bash --version` | Bash 5.x |

### Quick Verification

```bash
# Run this command for complete verification
for cmd in grep sed awk nano bash; do
    printf "%-10s" "$cmd:"
    $cmd --version 2>&1 | head -1
done
```

---

## Installation and Configuration

### Method 1: Automatic Script (Recommended)

```bash
cd SEM07-08_COMPLET
chmod +x scripts/bash/S04_01_setup_seminar.sh
./scripts/bash/S04_01_setup_seminar.sh
```

### Method 2: Manual Installation

```bash
# Ubuntu/Debian
sudo apt update
sudo apt install -y grep sed gawk nano coreutils

# Verify installation
grep --version && sed --version && awk --version && nano --version
```

### Method 3: WSL2 on Windows

```powershell
# In PowerShell (Admin)
wsl --install -d Ubuntu-24.04
```

Then follow the instructions for Ubuntu.

### Nano Configuration (Optional)

```bash
# Create ~/.nanorc for custom settings
cat > ~/.nanorc << 'EOF'
set tabsize 4
set autoindent
set linenumbers
set mouse
set softwrap
EOF
```

---

## Frequently Encountered Issues

### Issue 1: "grep: quantifier does not work"

Symptom: `grep 'ab+c' file` does not find "abc" or "abbc"

Cause: In BRE (Basic Regular Expression), `+` is a literal character.

Solution:
```bash
# Option 1: Use ERE
grep -E 'ab+c' file.txt

# Option 2: Escape in BRE
grep 'ab\+c' file.txt
```

### Issue 2: "sed does not modify the file"

Symptom: `sed 's/old/new/' file` does not change anything in the file

Cause: sed by default writes to stdout, it does not modify the file.

Solution:
```bash
# In-place editing
sed -i 's/old/new/' file.txt

# With backup (recommended)
sed -i.bak 's/old/new/' file.txt
```

### Issue 3: "awk print concatenates fields"

Symptom: `awk '{print $1 $2}'` produces "JohnSmith" instead of "John Smith"

Cause: Without a comma, awk concatenates directly.

Solution:
```bash
# With comma - uses OFS (default: space)
awk '{print $1, $2}' file.txt

# Or explicitly
awk '{print $1 " " $2}' file.txt
```

### Issue 4: "regex with / in sed does not work"

Symptom: `sed 's//usr/local//opt/' file` produces errors

Cause: / is both the delimiter and part of the pattern.

Solution:
```bash
# Use a different delimiter
sed 's|/usr/local|/opt|g' file.txt
sed 's#/usr/local#/opt#g' file.txt
```

### Issue 5: "BRE vs ERE - when to use which?"

Quick guide:
```bash
# BRE (grep, sed by default)
# - Special characters: . ^ $ * [ ] \
# - Require escaping: + ? { } | ( )

# ERE (grep -E, awk, sed -E)
# - All special characters work directly
# - No escaping needed for: + ? { } | ( )

# RECOMMENDATION: ALWAYS use grep -E and sed -E for consistency
```

### Issue 6: "nano does not save the file"

Symptom: I press CTRL+S but nothing happens

Cause: In nano, the shortcut for saving is CTRL+O (Write Out).

Solution:
```
CTRL+O → confirm the name → Enter → CTRL+X to exit
```

### Issue 7: "$0 vs $1 in awk"

Symptom: Confusion about what each variable contains

Clarification:
```bash
echo "John Smith 30" | awk '{
    print "$0 =", $0    # The entire line: "John Smith 30"
    print "$1 =", $1    # First field: "John"
    print "$NF =", $NF  # Last field: "30"
}'
```

### Issue 8: "Regex greedy vs lazy"

Symptom: `grep -oE '<.*>'` returns too much text

Cause: `*` is greedy (takes as much as possible).

Solution:
```bash
# In PCRE (grep -P), use *?
grep -oP '<.*?>' file.html

# In ERE, restructure the pattern
grep -oE '<[^>]+>' file.html
```

---

## Additional Resources

### Official Documentation
- GNU Grep Manual: https://www.gnu.org/software/grep/manual/
- GNU Sed Manual: https://www.gnu.org/software/sed/manual/
- GNU Awk Manual: https://www.gnu.org/software/gawk/manual/
- Nano Editor: https://www.nano-editor.org/docs.php

### Interactive Tutorials
- RegexOne: https://regexone.com
- Regex Crossword: https://regexcrossword.com

### Quick References
- DevHints Awk: https://devhints.io/awk
- DevHints Sed: https://devhints.io/sed
- Regex Cheatsheet: https://quickref.me/regex

### Recommended Books
- "sed & awk" - Dale Dougherty & Arnold Robbins (O'Reilly)
- "Mastering Regular Expressions" - Jeffrey Friedl (O'Reilly)
- "The AWK Programming Language" - Aho, Kernighan, Weinberger

---

## ⚠️ Known Issues and Limitations

### Platform-Specific

1. **macOS compatibility:** Some date commands use GNU syntax. On macOS, install coreutils:
   ```bash
   brew install coreutils
   ```
   Then use `gdate` instead of `date` or add coreutils to PATH.

2. **Windows WSL:** If using WSL, ensure line endings are Unix-style (LF). Run:
   ```bash
   sed -i 's/\r$//' scripts/**/*.sh
   ```

### Data Generation

3. **Large log files:** The demo generates ~2000-line logs. For production-scale testing, modify `NUM_LINES` parameter in `generate_access_log()`.

4. **Random data:** Generated data uses `$RANDOM` which may produce different results on each run. Solutions should still work regardless of specific values.

### Tool Versions

5. **GNU vs BSD tools:** Scripts are tested on GNU sed/awk/grep. BSD versions (macOS default) may behave differently with some flags.

6. **shellcheck:** Some warnings may appear for intentional constructs. The CI configuration excludes known false positives.

---

## 📋 Issues and Support

For questions, bug reports or improvement suggestions:

- **Technical questions:** Use the course forum or consultation hours
- **Bug reports:** Open an issue in the course repository on GitHub
- **Material errors:** Open an issue describing the error and location
- **Pull requests:** Contributions are welcome for fixes and improvements

---

## Licence and Attribution

These materials are created for educational purposes within the Operating Systems course, Bucharest University of Economic Studies - CSIE.

Permitted use:
- Personal study
- Activities within the course
- Modifications for personal use

Attribution required for:
- Redistribution
- Use in other courses

---

*Material generated for Seminar 4 of Operating Systems | Bucharest University of Economic Studies - CSIE*  
*Last updated: January 2025*
