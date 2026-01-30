# Seminar 5: Advanced Bash Scripting

> Lab observation: note down key commands and relevant output (2–3 lines) as you work. It helps with debugging and by the end you'll have a good README without extra effort.

> Operating Systems | Academy of Economic Studies Bucharest - CSIE  
> Version: 1.1 | Date: January 2025

---

## Contents

1. [Description](#description)
2. [Learning Objectives](#learning-objectives)
3. [Why This Seminar Matters](#why-this-seminar-matters)
4. [Package Structure](#package-structure)
5. [Usage Guide](#usage-guide)
6. [For Instructors](#for-instructors)
7. [For Students](#for-students)
8. [Technical Requirements](#technical-requirements)
9. [Frequently Encountered Issues](#frequently-encountered-issues)
10. [Additional Resources](#additional-resources)

---

## Description

This seminar represents the TURNING POINT of the Operating Systems course. Until now, students have learnt individual commands and simple scripts. From now on, they will write professional code that can be used in production.

### Context and Prerequisites

This seminar assumes completion of previous seminars:

| Seminar | Content |
|---------|---------|
| Seminar 1 | File system navigation, variables, globbing |
| Seminar 2 | Operators, redirection, pipes, filters, basic loops |
| Seminar 3 | `find`, `xargs`, scripts with arguments, permissions, cron |
| Seminar 4 | Regular expressions, `grep`, `sed`, `awk`, nano editor |

What this seminar introduces:

- Advanced functions: local variables with `local`, return values, nameref, recursion
- Arrays: indexed (0-based) and associative (hash maps with `declare -A`)
- Stability: `set -euo pipefail`, safe IFS, defensive checks
- Error handling: trap EXIT/ERR/INT/TERM, cleanup patterns
- Logging and Debug: professional logging system with levels, debugging techniques
- Professional template: standard structure for production scripts

### The Transition

```
┌─────────────────────────┐         ┌─────────────────────────┐
│    BEFORE (SEM01-04)    │   ──►   │    AFTER (SEM05-06)     │
├─────────────────────────┤         ├─────────────────────────┤
│ Simple scripts          │         │ Production scripts      │
│ "It works"              │         │ "It works RELIABLY"     │
│ Throwaway code          │         │ Maintainable code       │
│ Happy path only         │         │ Complete error handling │
│ echo for debugging      │         │ Logging system          │
│ Global variables        │         │ Modular functions       │
└─────────────────────────┘         └─────────────────────────┘
```

---

## Learning Objectives

At the end of this seminar, students will be able to:

### Fundamental Level (Remember & Understand)
- Define syntax for functions, indexed and associative arrays in Bash
- Explain the difference between local and global variables in function context
- Describe the behaviour of `set -e`, `set -u`, `set -o pipefail`
- Identify standard Unix signals and `trap` usage

### Application Level (Apply & Analyse)
- Create functions with local variables and return value mechanisms
- Implement indexed and associative arrays for various scenarios
- Apply `set -euo pipefail` and defensive checks in scripts
- Configure traps for automatic cleanup and error handling
- Integrate a logging system with levels into scripts

### Advanced Level (Evaluate & Create)
- Critically evaluate the reliability of an existing script and propose improvements
- Design and implement complete scripts using the professional template
- Choose the appropriate error handling strategy for various scenarios
- Create reusable function libraries for future projects

---

## Why This Seminar Matters

### The Difference Between Amateur and Professional

```bash
# AMATEUR script
cd /tmp/data
rm -rf *
process_file $1
echo "Done"

# PROFESSIONAL script
#!/bin/bash
set -euo pipefail

cd /tmp/data || die "Cannot cd to /tmp/data"
[[ -n "${1:-}" ]] || { usage; exit 1; }
rm -rf ./*  # ./* doesn't delete everything if cd fails
process_file "$1"
log_info "Processing completed successfully"
```

What happens when `cd` fails in the amateur version?
- `rm -rf *` executes in the CURRENT directory (could be `/` or `$HOME`)
- TOTAL DISASTER - data loss

### These Techniques Are Industry Standard

- Error handling - Scripts no longer "die" silently
- Logging - You can debug problems without being present
- Arrays - Real data structures in Bash
- Functions - Modular, testable, reusable code

### What You Gain

| Skill | Immediate Benefit | Long-term Benefit |
|-------|-------------------|-------------------|
| `set -euo pipefail` | Errors detected instantly | Reliable scripts in production |
| trap cleanup | No orphaned temporary files | Clean system, easy debugging |
| Logging | See what the script does | Post-mortem debugging |
| Functions | Organised code | Reusable libraries |
| Arrays | Correct list processing | Complex algorithms in Bash |

---

## Package Structure

```
SEM05/
│
├── README.md                              # This file
├── Makefile                               # Build orchestration
├── requirements.txt                       # Python dependencies
│
├── docs/                                  # Complete documentation
│   ├── S05_00_PEDAGOGICAL_ANALYSIS_PLAN.md   # Materials analysis & plan
│   ├── S05_01_INSTRUCTOR_GUIDE.md             # Step-by-step instructor guide
│   ├── S05_02_MAIN_MATERIAL.md          # Complete theory
│   ├── S05_03_PEER_INSTRUCTION.md            # MCQ questions for PI
│   ├── S05_04_PARSONS_PROBLEMS.md            # Code reordering problems
│   ├── S05_05_LIVE_CODING_GUIDE.md           # Live coding script
│   ├── S05_06_SPRINT_EXERCISES.md            # Timed exercises
│   ├── S05_07_LLM_AWARE_EXERCISES.md         # Exercises with LLM evaluation
│   ├── S05_08_SPECTACULAR_DEMOS.md          # Visual demos
│   ├── S05_09_VISUAL_CHEAT_SHEET.md          # One-pager reference
│   ├── S05_10_SELF_ASSESSMENT_REFLECTION.md       # Self-assessment instruments
│   ├── lo_traceability.md                    # Learning outcomes matrix
│   └── images/                               # Diagrams (SVG)
│       ├── array_types.svg
│       ├── function_scope.svg
│       ├── set_options_flow.svg
│       └── trap_signals.svg
│
├── scripts/                               # Functional scripts
│   ├── bash/                              # Bash utilities
│   │   ├── S05_01_setup_seminar.sh           # Demo environment setup
│   │   ├── S05_02_interactive_quiz.sh         # Interactive quiz
│   │   └── S05_03_validator.sh               # Assignment validator
│   │
│   ├── demo/                              # Demos for each concept
│   │   ├── S05_01_hook_demo.sh               # Hook: fragile vs reliable
│   │   ├── S05_02_demo_functions.sh          # Functions demo
│   │   ├── S05_03_demo_arrays.sh             # Arrays demo
│   │   ├── S05_04_demo_robust.sh             # set -euo pipefail demo
│   │   ├── S05_05_demo_logging.sh            # Logging system demo
│   │   └── S05_06_demo_debug.sh              # Debugging demo
│   │
│   ├── templates/                         # Reusable templates
│   │   ├── professional_script.sh            # Fully commented template
│   │   ├── simple_script.sh                  # Minimalist template
│   │   └── library.sh                        # Common functions
│   │
│   └── python/                            # Python tooling
│       ├── S05_01_autograder.py              # Automatic assignment evaluator
│       ├── S05_02_quiz_generator.py          # Quiz generator
│       └── S05_03_report_generator.py        # Report generator
│
├── presentations/                            # Visual materials
│   ├── S05_01_presentation.html                # Interactive presentation
│   └── S05_02_cheat_sheet.html               # Visual cheat sheet
│
├── homework/                                  # Assignment materials
│   ├── OLD_HW/                               # Original materials (reference)
│   │   ├── S05a_Prerequisite_Review.md
│   │   ├── S05b_Functii_Avansate.md
│   │   ├── S05c_Arrays_Bash.md
│   │   ├── S05d_Robustete_Script.md
│   │   ├── S05e_Trap_ErrorHandling.md
│   │   ├── S05f_Logging_Debug.md
│   │   └── S05_APPENDIX_Reference.md
│   ├── S05_01_HOMEWORK.md                        # Assignment specifications
│   ├── S05_02_create_homework.sh                # Template generation script
│   ├── S05_03_EVALUATION_RUBRIC.md            # Evaluation rubric
│   └── solutions/                              # Solutions (instructor only)
│       ├── README_INSTRUCTOR.md
│       ├── S05_ex01_functii_sol.sh
│       ├── S05_ex02_arrays_sol.sh
│       └── S05_ex03_robust_sol.sh
│
├── resources/                               # Supplementary materials
│   └── S05_RESOURCES.md                        # Links and references
│
├── tests/                                 # Testing
│   ├── README.md
│   └── run_all_tests.sh                      # Automated test runner
│
├── formative/                             # Formative assessment
│   ├── quiz.yaml                             # Quiz definition
│   ├── quiz_lms.json                         # LMS export (Moodle/Canvas)
│   └── quiz_runner.py                        # Interactive quiz runner
│
└── ci/                                    # Continuous Integration
    ├── github_actions.yml                    # GitHub Actions workflow
    └── linting.toml                          # Linting configuration
```

---

## Usage Guide

### Extraction and Initial Setup

```bash
# 1. Extract the package
unzip SEM05.zip
cd SEM05

# 2. Check Bash version (must be >= 4.0)
bash --version

# 3. Run the setup
chmod +x scripts/bash/*.sh scripts/demo/*.sh scripts/templates/*.sh
./scripts/bash/S05_01_setup_seminar.sh

# 4. Check shellcheck installation (optional but recommended)
shellcheck --version || sudo apt install shellcheck
```

### For Instructor - Seminar Preparation

```bash
# 1. Read the instructor guide (MANDATORY)
cat docs/S05_01_INSTRUCTOR_GUIDE.md | less

# 2. Test the demos
for demo in scripts/demo/*.sh; do
    echo "=== Testing: $demo ==="
    bash -n "$demo"  # Check syntax
done

# 3. Prepare the presentation
firefox presentations/S05_01_presentation.html &

# 4. Open the cheat sheet for quick reference
firefox presentations/S05_02_cheat_sheet.html &
```

### For Student - Independent Learning

```bash
# 1. Read the theoretical material
cat docs/S05_02_MAIN_MATERIAL.md | less

# 2. Study the professional template
cat scripts/templates/professional_script.sh | less

# 3. Execute the demos step by step
./scripts/demo/S05_02_demo_functions.sh
./scripts/demo/S05_03_demo_arrays.sh

# 4. Solve the sprint exercises
cat docs/S05_06_SPRINT_EXERCISES.md | less
```

---

## For Instructors

### Special Warnings

- Local vs global variables: Demonstrate the DIFFERENCE with a concrete example
- `declare -A` is MANDATORY: For any associative array
- `set -e` is not magic: Does not work in subshells or pipes without pipefail
- trap is not inherited: Must be reset in subshells

---

## For Students

### Fundamental Principles

1. DON'T memorise - UNDERSTAND why
   - Every line in the template exists for a reason
   - Ask "What problem does this solve?"

2. Start ALL scripts with the template
   - Copy `scripts/templates/professional_script.sh`
   - Adapt for your needs

3. `set -euo pipefail` ALWAYS
   - First line after shebang
   - No exceptions for new scripts

4. Test on ERROR cases, not just happy path. What happens if the file doesn't exist? What happens if the argument is missing? What happens if the disk is full?

### Recommended Workflow for New Scripts

```bash
# 1. Start from template
cp scripts/templates/professional_script.sh ~/my_script.sh

# 2. Edit with nano (NOT vim!)
nano ~/my_script.sh

# 3. Check with shellcheck
shellcheck ~/my_script.sh

# 4. Test happy path
./my_script.sh test_input.txt

# 5. Test error cases
./my_script.sh                    # No arguments
./my_script.sh nonexistent.txt    # Non-existent file
./my_script.sh /etc/shadow        # File without permissions
```

### Common Mistakes to Avoid

| Mistake | Consequence | Solution |
|---------|-------------|----------|
| `${arr[@]}` without quotes | Word splitting on spaces | `"${arr[@]}"` ALWAYS |
| Associative array without `declare -A` | Treated as indexed | `declare -A hash` MANDATORY |
| `return "string"` | Does not work (only 0-255) | Use `echo` for strings |
| `local` outside function | Syntax error | Only inside functions |
| trap in subshell | Not inherited | Reset in subshell |

---

## Technical Requirements

### Operating System

- Ubuntu 24.04 LTS (recommended)
- WSL2 on Windows 10/11
- Any Linux distribution with Bash 4.0+

### Bash Version
```bash
# Check version
bash --version
# Must be: GNU bash, version 4.0+ (for associative arrays)

# On macOS, install new bash:
brew install bash
```

### Recommended Tools

| Tool | Purpose | Installation |
|------|---------|--------------|
| `shellcheck` | Bash script linting | `sudo apt install shellcheck` |
| `nano` | Text editor | Pre-installed |
| `dialog` | TUI interfaces | `sudo apt install dialog` |
| `jq` | JSON processing | `sudo apt install jq` |

### Working Directory Structure

```bash
# Recommendation: create a dedicated directory
mkdir -p ~/SO/SEM05
cd ~/SO/SEM05

# Copy the template for each new script
cp /path/to/SEM05/scripts/templates/professional_script.sh ./
```

---

## Frequently Encountered Issues

### 1. "bad array subscript" for associative arrays

Cause: You didn't declare the array with `declare -A`

```bash
# WRONG
config[host]="localhost"

# CORRECT
declare -A config
config[host]="localhost"
```

### 2. "unbound variable" for optional variables

Cause: `set -u` is active and the variable doesn't exist

```bash
# WRONG
echo $OPTIONAL_VAR

# CORRECT - with default value
echo "${OPTIONAL_VAR:-default_value}"

# CORRECT - explicit check
if [[ -v OPTIONAL_VAR ]]; then
    echo "$OPTIONAL_VAR"
fi
```

### 3. Script doesn't stop on error

Cause: The error is in a context where `set -e` doesn't work

```bash
# Contexts where set -e does NOT work:
cmd1 || cmd2         # cmd1 can fail
cmd1 && cmd2         # cmd1 can fail
if cmd; then ...     # cmd can fail
while cmd; do ...    # cmd can fail
cmd | cmd2           # without pipefail, only last command
$(cmd)               # in command substitution
```

### 4. trap cleanup doesn't execute

Cause: `exit` before trap setup

```bash
# WRONG
exit 1              # cleanup doesn't execute
trap cleanup EXIT   # too late!

# CORRECT
trap cleanup EXIT   # setup BEFORE any exit
# ... code ...
exit 1              # now cleanup executes
```

### 5. Function doesn't return expected string

Cause: Confusion between `return` and `echo`

```bash
# return is ONLY for exit code (0-255)
get_value() {
    return "hello"  # Doesn't work!
}

# Use echo to return string
get_value() {
    echo "hello"    # Correct
}
result=$(get_value)
```

### 6. Array seems empty after iteration

Cause: Iterating without quotes - word splitting

```bash
arr=("one two" "three")

# WRONG - "one two" becomes two elements
for item in ${arr[@]}; do
    echo "$item"
done

# CORRECT
for item in "${arr[@]}"; do
    echo "$item"
done
```

### 7. shellcheck gives warning about unused variable

Cause: shellcheck doesn't see usage in another context

```bash
# Add directive to ignore
# shellcheck disable=SC2034
UNUSED_BUT_NEEDED="value"
```

### 8. local doesn't work

Cause: `local` is valid ONLY inside functions

```bash
# WRONG - at global level
local var="value"

# CORRECT - in function
my_func() {
    local var="value"
}
```

---

## Additional Resources

### Official Documentation
- [GNU Bash Manual](https://www.gnu.org/software/bash/manual/)
- [Advanced Bash-Scripting Guide](https://tldp.org/LDP/abs/html/)
- [ShellCheck Wiki](https://github.com/koalaman/shellcheck/wiki)

### Recommended Books
- "The Linux Command Line" - William Shotts
- "Learning the bash Shell" - O'Reilly
- "Bash Cookbook" - O'Reilly

### Online Practice
- [Exercism - Bash Track](https://exercism.org/tracks/bash)
- [HackerRank - Linux Shell](https://www.hackerrank.com/domains/shell)
- [OverTheWire - Bandit](https://overthewire.org/wargames/bandit/)

### Video Tutorials
- MIT Missing Semester - Shell Tools
- Linux Foundation - Bash Scripting

---

## Support

Issues: Open an issue in GitHub

---

## Licence and Attribution

This material was developed for the Operating Systems course at the Academy of Economic Studies Bucharest - CSIE.

Materials may be used and adapted for educational purposes with appropriate attribution.

---

*Last updated: January 2025*  
*Version: 1.1*
