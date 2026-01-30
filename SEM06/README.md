# Seminar 6: CAPSTONE - Integrated Bash Projects

> **⚠️ IMPORTANT**: SEM06 is different from SEM01-SEM05!  
> This is a CAPSTONE—everything you've learned comes together in real projects.

## Operating Systems | Seminar 6 (Finalisation)
### ASE Bucharest - CSIE | 2025-2026

---

## Why Is SEM06 Different?

| Aspect | SEM01-SEM05 | SEM06 (CAPSTONE) |
|--------|-------------|------------------|
| Focus | Individual concepts | Complete integration |
| Structure | docs/ with 11 standard files | docs/ + docs/projects/ |
| Scripts | Simple demos | 3 Complete Projects (~7500 lines) |
| Assessment | Punctual exercises | Semester project + Live demo |
| Complexity | Progressive | Professional |

### What You Will Learn

This CAPSTONE consolidates ALL concepts from previous seminars:

```
SEM01: Shell basics     ─┐
SEM02: Pipes, Loops     ─┤
SEM03: Find, Permissions─┼──► SEM06: CAPSTONE
SEM04: Regex, AWK, SED  ─┤    3 Professional Projects
SEM05: Functions, Arrays─┘
```

> **Lab note:** The jump from isolated exercises to integrated systems is bigger than it looks. Start early. Iterate often.

---

## Table of Contents

- [CAPSTONE Structure](#capstone-structure)
- [Main Projects](#main-projects)
- [Documentation](#documentation)
- [Installation and Usage](#installation-and-usage)
- [Practical Assignments](#practical-assignments)
- [Resources](#resources)

---

## CAPSTONE Structure

```
SEM06/
├── 📄 README.md                    # This file
├── 📄 CHANGELOG.md                 # Version history
├── 📄 .shellcheckrc                # ShellCheck configuration
│
├── 📂 docs/                        # Pedagogical documentation
│   ├── S06_00_PEDAGOGICAL_ANALYSIS_PLAN.md   # Audience, LO mapping
│   ├── S06_01_INSTRUCTOR_GUIDE.md            # Teaching guide
│   ├── S06_02_MAIN_MATERIAL.md               # Index to project docs
│   ├── S06_03_PEER_INSTRUCTION.md            # 10 PI questions
│   ├── S06_04_PARSONS_PROBLEMS.md            # Code arrangement exercises
│   ├── S06_05_LIVE_CODING_GUIDE.md           # Worked examples
│   ├── S06_06_SPRINT_EXERCISES.md            # Timed pair exercises
│   ├── S06_07_LLM_AWARE_EXERCISES.md         # AI-interaction exercises
│   ├── S06_08_SPECTACULAR_DEMOS.md           # Hook scenarios
│   ├── S06_09_VISUAL_CHEAT_SHEET.md          # Quick reference
│   ├── S06_10_SELF_ASSESSMENT_REFLECTION.md  # Metacognitive checklist
│   ├── lo_traceability.md                    # LO mapping matrix
│   │
│   └── 📂 projects/                # Project-specific documentation
│       ├── S06_P00_Introduction_CAPSTONE.md  # Overview and motivation
│       ├── S06_P01_Project_Architecture.md   # Design patterns
│       ├── S06_P02_Monitor_Implementation.md # Monitor guide
│       ├── S06_P03_Backup_Implementation.md  # Backup guide
│       ├── S06_P04_Deployer_Implementation.md# Deployer guide
│       ├── S06_P05_Testing_Framework.md      # Testing in Bash
│       ├── S06_P06_Error_Handling.md         # Trap, logging, exits
│       ├── S06_P07_Deployment_Strategies.md  # Rolling, Blue-Green
│       └── S06_P08_Cron_Automation.md        # Scheduling
│
├── 📂 presentations/               # HTML Presentations (Reveal.js)
│   ├── S06_00_Introduction.html
│   ├── S06_01_Project_Architecture.html
│   ├── S06_02_Monitor.html
│   ├── S06_03_Backup.html
│   ├── S06_04_Deployer.html
│   └── S06_05_Testing_ErrorHandling.html
│
├── 📂 scripts/                     # Source code (~680K)
│   └── 📂 projects/                # ⭐ THE 3 CAPSTONE PROJECTS
│       ├── monitor/                # 🖥️ System Monitor
│       │   ├── monitor.sh          #    Entry point
│       │   ├── lib/                #    Libraries (core, config, utils)
│       │   └── tests/              #    Test suite
│       │
│       ├── backup/                 # 💾 Backup System
│       │   ├── backup.sh           #    Entry point
│       │   ├── lib/                #    Libraries
│       │   └── tests/              #    Test suite
│       │
│       └── deployer/               # 🚀 Application Deployer
│           ├── deployer.sh         #    Entry point
│           ├── lib/                #    Libraries
│           └── tests/              #    Test suite
│
├── 📂 formative/                   # Assessment materials
│   ├── quiz.yaml                   # Source quiz (23 questions)
│   ├── quiz_lms.json               # LMS export
│   └── quiz_runner.py              # Interactive runner
│
├── 📂 homework/                    # Student assignments
│   ├── S06_00_README.md            # Assignment overview
│   ├── S06_01_HOMEWORK_CAPSTONE.md # Full assignment spec
│   ├── S06_02_EVALUATION_RUBRIC.md # Grading criteria
│   └── OLD_HW/                     # Legacy reference
│
├── 📂 resources/                   # Additional materials
│   ├── examples/                   # Code snippets
│   ├── systemd/                    # Service files
│   └── templates/                  # Starter templates
│
├── 📂 tests/                       # Test runner
│   ├── README.md
│   └── run_all_tests.sh
│
└── 📂 ci/                          # Continuous integration
    ├── github_actions.yml
    └── linting.toml
```

---

## Main Projects

### 🖥️ System Monitor

Real-time monitoring of CPU, memory, disk and load with threshold alerting.

```bash
# Run once
./scripts/projects/monitor/monitor.sh

# Daemon mode
./scripts/projects/monitor/monitor.sh -d

# JSON output
./scripts/projects/monitor/monitor.sh -o json
```

**Key concepts:** /proc parsing, metrics aggregation, threshold alerting, multiple output formats

### 💾 Backup System

Incremental backup with compression, checksum verification and automatic rotation.

```bash
# Run backup
./scripts/projects/backup/backup.sh

# List existing backups
./scripts/projects/backup/backup.sh --list

# Restore specific version
./scripts/projects/backup/backup.sh --restore v1.0.0
```

**Key concepts:** find -newer, tar compression, checksums, retention policies

### 🚀 Application Deployer

Automated deployment with rollback support and health checks.

```bash
# Deploy latest
./scripts/projects/deployer/deployer.sh deploy

# Rollback to previous
./scripts/projects/deployer/deployer.sh rollback

# Check status
./scripts/projects/deployer/deployer.sh status
```

**Key concepts:** deployment strategies (rolling, blue-green), health checks, atomic operations

---

## Documentation

### Quick Reference

| What you need | Where to find it |
|---------------|------------------|
| Getting started | `docs/S06_02_MAIN_MATERIAL.md` |
| Architecture overview | `docs/projects/S06_P01_Project_Architecture.md` |
| Error handling patterns | `docs/projects/S06_P06_Error_Handling.md` |
| Bash cheat sheet | `docs/S06_09_VISUAL_CHEAT_SHEET.md` |
| Self-assessment | `docs/S06_10_SELF_ASSESSMENT_REFLECTION.md` |

### For Instructors

| What you need | Where to find it |
|---------------|------------------|
| Session plan | `docs/S06_01_INSTRUCTOR_GUIDE.md` |
| Pedagogical analysis | `docs/S06_00_PEDAGOGICAL_ANALYSIS_PLAN.md` |
| LO traceability | `docs/lo_traceability.md` |
| Peer instruction questions | `docs/S06_03_PEER_INSTRUCTION.md` |

---

## Installation and Usage

### Prerequisites

- Ubuntu 22.04 (WSL2, VM or native)
- Bash 5.0+
- Standard utilities: `curl`, `tar`, `find`, `grep`
- Optional: `shellcheck` for linting

### Setup

```bash
# Clone or extract
cd ~/SEM06

# Make scripts executable
chmod +x scripts/projects/*//*.sh
chmod +x tests/run_all_tests.sh

# Run tests to verify installation
./tests/run_all_tests.sh
```

### Using the Makefile

```bash
make help       # Show available targets
make setup      # Install dependencies
make test       # Run all tests
make lint       # Check code quality
make quiz       # Run interactive quiz
make clean      # Remove temporary files
```

---

## Practical Assignments

### Assignment Overview

| Assignment | Project | Difficulty | Points |
|------------|---------|------------|--------|
| A1: Monitor Extension | Monitor | ⭐⭐⭐ | 100 |
| A2: Backup System | Backup | ⭐⭐⭐ | 100 |
| A3: CI/CD Pipeline | Deployer | ⭐⭐⭐⭐ | 100 |
| A4: Integrated | All three | ⭐⭐⭐⭐⭐ | +100 bonus |

Full specifications: `homework/S06_01_HOMEWORK_CAPSTONE.md`

Evaluation rubric: `homework/S06_02_EVALUATION_RUBRIC.md`

---

## Resources

### External Documentation

- [GNU Bash Manual](https://www.gnu.org/software/bash/manual/)
- [ShellCheck Wiki](https://www.shellcheck.net/wiki/)
- [Linux man pages](https://man7.org/linux/man-pages/)

### Books

- Shotts, William E. *The Linux Command Line* (free online)
- Robbins & Beebe. *Classic Shell Scripting*, O'Reilly
- Cooper, Mendel. *Advanced Bash-Scripting Guide* (TLDP)

### Online Tools

- [ExplainShell](https://explainshell.com/) — Command explanation
- [ShellCheck](https://www.shellcheck.net/) — Online linting
- [Bash Reference](https://devhints.io/bash) — Quick reference

---

## Version History

See `CHANGELOG.md` for detailed version history.

**Current version:** 2.0.0 (January 2025)  
- Standardised documentation structure
- Added pedagogical analysis and traceability
- Improved code quality patterns

---

## Authors and Acknowledgements

**Course:** Operating Systems  
**Institution:** ASE Bucharest - CSIE  
**Academic Year:** 2024-2025

---

*CAPSTONE SEM06 — Operating Systems*  
*ASE Bucharest - CSIE | 2024-2025*
