# SEM-PROJ: Semester Projects - Operating Systems

> Operating Systems | ASE Bucharest - CSIE  
> Author: ing. dr. Antonio Clim  
> Version: 1.0 | January 2025

---

## General Overview

Semester projects represent the major practical component of the Operating Systems course. Each student must choose and implement one project from the 23 available, organised across three difficulty levels.

### Pedagogical Objectives

- Practical application of theoretical concepts from the course
- Development of advanced Bash scripting skills
- Deep understanding of operating system mechanisms
- Hands-on experience with Linux system tooling

---

## Project Statistics

| Level | Number | Estimated Time | Complexity | Components |
|-------|--------|----------------|------------|------------|
| EASY | 5 | 15-20 hours | ⭐⭐ | Bash only |
| MEDIUM | 15 | 25-35 hours | ⭐⭐⭐ | Bash + optional Kubernetes |
| ADVANCED | 3 | 40-50 hours | ⭐⭐⭐⭐⭐ | Bash + C integration |

---

## Folder Structure

```
SEM-PROJ/
├── README.md                 # This document
├── EVALUARE_GENERALA.md      # Evaluation criteria and process
├── GHID_TEHNIC.md            # Technical guide for implementation
├── KUBERNETES_INTRO.md       # Kubernetes introduction (optional)
├── RUBRICA_UNIVERSALA.md     # Detailed evaluation rubric
│
├── b)EASY/                   # Easy level projects (5)
│   ├── E01_File_System_Auditor.md
│   ├── E02_Log_Analyzer.md
│   ├── E03_Bulk_File_Organizer.md
│   ├── E04_System_Health_Reporter.md
│   └── E05_Config_File_Manager.md
│
├── a)MEDIUM/                 # Medium level projects (15)
│   ├── M01_Incremental_Backup_System.md
│   ├── M02_Process_Lifecycle_Monitor.md
│   ├── M03_Service_Health_Watchdog.md
│   ├── M04_Network_Security_Scanner.md
│   ├── M05_Deployment_Pipeline.md
│   ├── M06_Resource_Usage_Historian.md
│   ├── M07_Security_Audit_Framework.md
│   ├── M08_Disk_Storage_Manager.md
│   ├── M09_Scheduled_Tasks_Manager.md
│   ├── M10_Process_Tree_Analyzer.md
│   ├── M11_Memory_Forensics_Tool.md
│   ├── M12_File_Integrity_Monitor.md
│   ├── M13_Log_Aggregator.md
│   ├── M14_Environment_Config_Manager.md
│   └── M15_Parallel_Execution_Engine.md
│
├── c)ADVANCED/               # Advanced level projects (3)
│   ├── A01_Mini_Job_Scheduler.md
│   ├── A02_Interactive_Shell_Extension.md
│   └── A03_Distributed_File_Sync.md
│
├── helpers/                  # Utility scripts
│   ├── project_validator.sh
│   ├── submission_packager.sh
│   └── test_runner.sh
│
└── templates/                # Project templates
    ├── project_structure.sh
    ├── README_template.md
    └── Makefile_template
```

---

## Choosing a Project

> My tip #1: Choose a project that solves a REAL problem you have. I had a student who built a backup system for phone photos because they actually needed one — personal motivation made them deliver something exceptional. Another one built a price monitor for graphics cards... guess why 😄

### Selection Criteria

1. Evaluate your current level of Bash knowledge
2. Consult the prerequisites in each requirement
3. Estimate the time available until the deadline
4. Choose a subject that interests you - motivation matters!

### Recommendations by Level

| If... | Recommendation |
|-------|----------------|
| This is your first serious contact with Bash | EASY (E01-E05) |
| You have moderate scripting experience | MEDIUM (M01-M15) |
| You want maximum challenge and have time | ADVANCED (A01-A03) |
| You want bonus points | MEDIUM/ADVANCED with extensions |

---

## Calendar and Deadlines

| Stage | Deadline | Description |
|-------|----------|-------------|
| Project selection | Week 8 | Communicate selection to instructor |
| Milestone 1 | Week 10 | Basic functional structure |
| Milestone 2 | Week 12 | Complete functionality |
| Final submission | Week 14 | Code + documentation + presentation |
| Presentations | Exam session | Demonstration and questions |

---

## Mandatory Deliverables

Each project must contain:

```
NameSurname_ProjectXX/
├── README.md              # Complete documentation
├── src/                   # Source code
│   ├── main.sh            # Main script
│   └── lib/               # Auxiliary modules/functions
├── tests/                 # Automated tests
│   └── test_*.sh
├── docs/                  # Technical documentation
│   ├── INSTALL.md         # Installation instructions
│   └── USAGE.md           # Usage manual
├── examples/              # Usage examples
└── Makefile               # Build/test automation
```

---

## Evaluation System

### Score Distribution

| Component | Weight |
|-----------|--------|
| Correct functionality | 40% |
| Code quality | 20% |
| Documentation | 15% |
| Automated tests | 15% |
| Presentation | 10% |

### Available Bonuses

| Bonus | Value | Condition |
|-------|-------|-----------|
| Kubernetes extension | +10% | MEDIUM projects with K8s deployment |
| C component | +15% | Functional integrated C module |
| CI/CD Pipeline | +5% | GitHub Actions or similar |
| Video documentation | +5% | Recorded demo 3-5 min |

### Penalties

| Situation | Penalty |
|-----------|---------|
| Late submission (< 24h) | -10% |
| Late submission (24-72h) | -25% |
| Late submission (> 72h) | -50% |
| Detected plagiarism | -100% (0 and disciplinary report) |
| Does not compile/run | -30% |
| Missing documentation | -20% |

---

## Required Resources

### Development Environment

- OS: Ubuntu 24.04 (native, VM or WSL2)
- Shell: Bash 5.0+
- Editor: vim, nano or VS Code with Remote-SSH
- Version control: Git

### Recommended Tooling

```bash
# Version check
bash --version      # >= 5.0
git --version       # >= 2.30
shellcheck --version # for linting

# Install shellcheck (if missing)
sudo apt install shellcheck
```

### Study Materials

- `003GHID/01_Ghid_Scripting_Bash.md`
- `003GHID/03_Ghid_Observabilitate_si_Debugging.md`
- Materials from Seminar 1 through Seminar 6

---

## Frequently Asked Questions

Q: Can I work in a team?  
A: No. Projects are individual. Collaboration for learning is OK, but the code must be your own.

Q: Can I change the project after I have chosen it?  
A: Yes, until Milestone 1, with instructor approval.

Q: What happens if I do not finish all requirements?  
A: What you have implemented will be evaluated. Partial functionality receives partial credit.

Q: Can I use external libraries?  
A: Yes, for auxiliary components (e.g. `jq` for JSON). The core must be your own code.

Q: How do I prove I did not plagiarise?  
A: You will be able to explain any line of code during the presentation. Comments help.

---

## Contact and Support

- Consultations: After seminar hours or by appointment
- Questions forum: Course platform
- Email: [instructor address]

---

## Next Steps

1. ✅ Read `EVALUARE_GENERALA.md` for evaluation details
2. ✅ Go through `GHID_TEHNIC.md` for best practices
3. ✅ Choose a project from `a)MEDIUM/`, `b)EASY/` or `c)ADVANCED/`
4. ✅ Communicate your choice to the instructor
5. ✅ Start implementation using `templates/`

---

*OS Kit - Semester Projects | January 2025*
