# 📁 Bash Utilities — SEM04

> **Location:** `SEM04/scripts/bash/`  
> **Purpose:** Seminar setup, validation, and interactive tools

## Contents

| Script | Purpose | Sudo Required? |
|--------|---------|----------------|
| `S04_01_setup_seminar.sh` | Install dependencies, create workspace | Yes (first run) |
| `S04_02_interactive_quiz.sh` | CLI quiz with instant feedback | No |
| `S04_03_validator.sh` | Validate homework submissions | No |

## Quick Start

```bash
# Make all scripts executable (once)
chmod +x *.sh

# Setup seminar environment
./S04_01_setup_seminar.sh

# Take a practice quiz
./S04_02_interactive_quiz.sh

# Validate your homework
./S04_03_validator.sh ~/my_homework/
```

---

## S04_01_setup_seminar.sh

**Purpose:** Prepares your system with all required tools and creates the seminar workspace.

### Usage

```bash
./S04_01_setup_seminar.sh [options]

Options:
  --minimal     Skip optional packages (faster)
  --force       Reinstall even if packages exist
  --workspace   Create workspace directory only
  --check       Verify installation without installing
```

### What It Installs

- Required system packages
- Python dependencies from `requirements.txt`
- Workspace directories (`~/os_seminar_sem04/`)
- Sample files for exercises

### Example

```bash
# Full installation
./S04_01_setup_seminar.sh

# Quick check if everything is ready
./S04_01_setup_seminar.sh --check
```

---

## S04_02_interactive_quiz.sh

**Purpose:** Terminal-based quiz for self-assessment with immediate feedback.

### Usage

```bash
./S04_02_interactive_quiz.sh [options]

Options:
  --timed         30-second limit per question
  --shuffle       Randomize question order
  --hard-only     Show only difficult questions
  --count N       Limit to N questions
```

### Features

- Coloured output for correct/incorrect
- Running score display
- Detailed explanations after each answer
- Summary statistics at end

### Example

```bash
# Standard quiz
./S04_02_interactive_quiz.sh

# Timed challenge mode
./S04_02_interactive_quiz.sh --timed --shuffle
```

---

## S04_03_validator.sh

**Purpose:** Checks homework submissions against requirements.

### Usage

```bash
./S04_03_validator.sh <submission_dir> [options]

Options:
  --strict      Fail on warnings (for final check)
  --report      Generate detailed report file
  --fix         Attempt to auto-fix common issues
  --quiet       Minimal output
```

### What It Validates

| Check | Severity |
|-------|----------|
| Required files present | ERROR |
| Script syntax (bash -n) | ERROR |
| Shellcheck compliance | WARNING |
| Proper shebang lines | WARNING |
| No hardcoded paths | WARNING |
| Executable permissions | WARNING |

### Example

```bash
# Basic validation
./S04_03_validator.sh ~/homework/

# Strict mode before submission
./S04_03_validator.sh ~/homework/ --strict --report
```

---

## Dependencies

- `bash` ≥ 4.0
- `shellcheck` (for validation)
- Standard Unix tools (`grep`, `sed`, `awk`)

## Troubleshooting

| Issue | Solution |
|-------|----------|
| "Permission denied" | Run `chmod +x *.sh` |
| "shellcheck not found" | Run setup script or `sudo apt install shellcheck` |
| Quiz won't start | Check terminal supports ANSI colours |

---

*See also: [`../demo/`](../demo/) for live coding demonstrations*  
*See also: [`../python/`](../python/) for automated grading tools*

*Last updated: January 2026*
