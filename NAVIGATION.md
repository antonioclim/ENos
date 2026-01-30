# ENos Educational Kit — Navigation Index

> **Quick reference for finding materials in this kit**  
> **Course:** Operating Systems | ASE Bucharest — CSIE  
> **Author:** ing. dr. Antonio Clim  
> **Last Updated:** January 2025

---

## 🚀 Quick Start

| I want to... | Go to |
|--------------|-------|
| Set up my environment | [01_INIT_SETUP/](./01_INIT_SETUP/) |
| Submit homework | [02_INIT_HOMEWORKS/](./02_INIT_HOMEWORKS/) |
| Find student guides | [03_GUIDES/](./03_GUIDES/) |
| Browse projects | [04_PROJECTS/](./04_PROJECTS/) |
| Read lecture notes | [05_LECTURES/](./05_LECTURES/) |
| Prepare for exam | [00_SUPPLEMENTARY/](./00_SUPPLEMENTARY/) |
| Understand grading | [SEM07/grade_aggregation/](./SEM07/grade_aggregation/) |

---

## 📚 Seminar Materials

| Week | Topic | Materials | Key Scripts |
|------|-------|-----------|-------------|
| 1 | Shell Fundamentals | [SEM01/](./SEM01/) | Quoting, variables, FHS |
| 2 | I/O Redirection & Loops | [SEM02/](./SEM02/) | Pipes, filters, scripting basics |
| 3 | Find, Xargs, Permissions | [SEM03/](./SEM03/) | File operations, getopts, cron |
| 4 | Text Processing (grep/sed/awk) | [SEM04/](./SEM04/) | Regex, pattern matching |
| 5 | Functions & Arrays | [SEM05/](./SEM05/) | Robust scripting, trap, logging |
| 6 | Capstone Project | [SEM06/](./SEM06/) | Monitor, Backup, Deployer |
| 7 | Evaluation | [SEM07/](./SEM07/) | Assessment, grading, oral defence |

---

## 📁 Document Types

Each seminar contains standardised documents:

### For Instructors

| Document | Purpose |
|----------|---------|
| `S0X_00_PEDAGOGICAL_ANALYSIS_PLAN.md` | Learning design and objectives |
| `S0X_01_INSTRUCTOR_GUIDE.md` | Session facilitation guide |
| `S0X_05_LIVE_CODING_GUIDE.md` | Demo scripts and walkthroughs |
| `S0X_08_SPECTACULAR_DEMOS.md` | Engaging demonstrations |

### For Students

| Document | Purpose |
|----------|---------|
| `S0X_02_MAIN_MATERIAL.md` | Core content and explanations |
| `S0X_03_PEER_INSTRUCTION.md` | Discussion questions |
| `S0X_04_PARSONS_PROBLEMS.md` | Code ordering exercises |
| `S0X_06_SPRINT_EXERCISES.md` | Timed practice problems |
| `S0X_07_LLM_AWARE_EXERCISES.md` | AI-resistant tasks |
| `S0X_09_VISUAL_CHEAT_SHEET.md` | Quick reference |
| `S0X_10_SELF_ASSESSMENT_REFLECTION.md` | Self-evaluation |

### Homework

| Document | Location |
|----------|----------|
| Assignment specification | `SEM0X/homework/S0X_01_HOMEWORK.md` |
| Evaluation rubric | `SEM0X/homework/S0X_03_EVALUATION_RUBRIC.md` |
| Oral verification guide | `SEM0X/homework/S0X_04_ORAL_VERIFICATION*.md` |

---

## 🛠️ Tools & Scripts

### Grading Tools

| Tool | Location | Purpose |
|------|----------|---------|
| Autograder | `SEM0X/scripts/python/S0X_01_autograder.py` | Automated submission grading |
| Quiz Generator | `SEM0X/scripts/python/S0X_02_quiz_generator.py` | Generate assessment quizzes |
| Report Generator | `SEM0X/scripts/python/S0X_03_report_generator.py` | Create grade reports |

### Academic Integrity Tools

| Tool | Location | Purpose |
|------|----------|---------|
| Plagiarism Detector | `SEM01/scripts/python/S01_05_plagiarism_detector.py` | Code similarity check |
| AI Scanner | `SEM01/scripts/python/S01_06_ai_fingerprint_scanner.py` | Detect AI-generated text |
| MOSS/JPlag Guide | `SEM07/external_tools/MOSS_JPLAG_GUIDE.md` | External tools integration |
| Combined Pipeline | `SEM07/external_tools/run_plagiarism_check.sh` | Full integrity check |

### Shared Libraries

| Library | Location | Purpose |
|---------|----------|---------|
| Logging Utilities | `lib/logging_utils.py` | Standardised logging |
| Randomisation | `lib/randomisation_utils.py` | Student-specific test parameters |

### Demonstration Scripts

| Location | Contents |
|----------|----------|
| `SEM0X/scripts/demo/` | Live coding demonstrations |
| `SEM0X/scripts/bash/` | Setup and validation scripts |

---

## 📊 Evaluation

### Component Weights

| Component | Weight | Details |
|-----------|--------|---------|
| Homework | 25% | [SEM07/homework_evaluation/](./SEM07/homework_evaluation/) |
| Project | 50% | [SEM07/project_evaluation/](./SEM07/project_evaluation/) |
| Test | 25% | [SEM07/final_test/](./SEM07/final_test/) |

### Key Documents

| Document | Location |
|----------|----------|
| Grading Policy | [SEM07/grade_aggregation/GRADING_POLICY.md](./SEM07/grade_aggregation/GRADING_POLICY.md) |
| Final Grade Calculator | [SEM07/grade_aggregation/final_grade_calculator_EN.py](./SEM07/grade_aggregation/final_grade_calculator_EN.py) |
| Oral Defence Questions | [SEM07/project_evaluation/oral_defence_questions_EN.md](./SEM07/project_evaluation/oral_defence_questions_EN.md) |
| Manual Evaluation Checklist | [SEM07/project_evaluation/manual_eval_checklist_EN.md](./SEM07/project_evaluation/manual_eval_checklist_EN.md) |

---

## 📖 Lecture Materials

### Course Topics

| Chapter | Topic | Location |
|---------|-------|----------|
| 01 | Introduction to OS | [05_LECTURES/01-Introduction_to_Operating_Systems/](./05_LECTURES/01-Introduction_to_Operating_Systems/) |
| 02 | Basic OS Concepts | [05_LECTURES/02-Basic_OS_Concepts/](./05_LECTURES/02-Basic_OS_Concepts/) |
| 03 | Processes (PCB, fork) | [05_LECTURES/03-Processes_(PCB+fork)/](./05_LECTURES/03-Processes_%28PCB+fork%29/) |
| 04 | Process Scheduling | [05_LECTURES/04-Process_Scheduling/](./05_LECTURES/04-Process_Scheduling/) |
| 05 | Execution Threads | [05_LECTURES/05-Execution_Threads/](./05_LECTURES/05-Execution_Threads/) |
| 06 | Synchronisation Part 1 | [05_LECTURES/06-Synchronisation_(Part1_Peterson+locks+mutex)/](./05_LECTURES/06-Synchronisation_%28Part1_Peterson+locks+mutex%29/) |
| 07 | Synchronisation Part 2 | [05_LECTURES/07-Synchronisation_(Part2_semaphore_buffer)/](./05_LECTURES/07-Synchronisation_%28Part2_semaphore_buffer%29/) |
| 08 | Deadlock | [05_LECTURES/08-Deadlock_(Coffman)/](./05_LECTURES/08-Deadlock_%28Coffman%29/) |
| 09 | Memory Management Part 1 | [05_LECTURES/09-Memory_Management_Part1_paging_segmentation/](./05_LECTURES/09-Memory_Management_Part1_paging_segmentation/) |
| 10 | Virtual Memory | [05_LECTURES/10-Virtual_Memory_(TLB_Belady)/](./05_LECTURES/10-Virtual_Memory_%28TLB_Belady%29/) |
| 11 | File System Part 1 | [05_LECTURES/11-File_System_(Part1_inode_pointers)/](./05_LECTURES/11-File_System_%28Part1_inode_pointers%29/) |
| 12 | File System Part 2 | [05_LECTURES/12-File_System_Part2_alloc_extent_struct/](./05_LECTURES/12-File_System_Part2_alloc_extent_struct/) |
| 13 | Security | [05_LECTURES/13-Security_in_Operating_Systems/](./05_LECTURES/13-Security_in_Operating_Systems/) |
| 14 | Virtualisation | [05_LECTURES/14-Virtualization+Recap/](./05_LECTURES/14-Virtualization+Recap/) |

### Supplementary Topics

| Topic | Location |
|-------|----------|
| Network Connections | [05_LECTURES/15supp-Network_Connection/](./05_LECTURES/15supp-Network_Connection/) |
| Advanced Containerisation | [05_LECTURES/16supp-Advanced_Containerisation/](./05_LECTURES/16supp-Advanced_Containerisation/) |
| Kernel Programming | [05_LECTURES/17supp-Kernel_Level_OS_Programming/](./05_LECTURES/17supp-Kernel_Level_OS_Programming/) |
| NPU Integration | [05_LECTURES/18supp-NPU_Integration_in_Operating_Systems/](./05_LECTURES/18supp-NPU_Integration_in_Operating_Systems/) |

---

## 🔍 Search Tips

```bash
# Find all files about a topic
grep -rn "your topic" --include="*.md" .

# List all Python scripts
find . -name "*.py" -type f | head -20

# List all Bash scripts  
find . -name "*.sh" -type f | head -20

# Find homework files
find . -name "*HOMEWORK*.md" -type f

# Find evaluation rubrics
find . -name "*RUBRIC*.md" -type f

# Search for specific command examples
grep -rn "find.*-exec" --include="*.md" .
```

---

## 📋 Projects

### Project Categories

| Difficulty | Location | Description |
|------------|----------|-------------|
| Easy | [04_PROJECTS/b)EASY/](./04_PROJECTS/b%29EASY/) | 5 beginner-friendly projects |
| Medium | [04_PROJECTS/a)MEDIUM/](./04_PROJECTS/a%29MEDIUM/) | 15 intermediate projects |
| Advanced | [04_PROJECTS/c)ADVANCED/](./04_PROJECTS/c%29ADVANCED/) | 3 challenging projects |

### Project Resources

| Resource | Location |
|----------|----------|
| Selection Guide | [04_PROJECTS/PROJECT_SELECTION_GUIDE.md](./04_PROJECTS/PROJECT_SELECTION_GUIDE.md) |
| Technical Guide | [04_PROJECTS/TECHNICAL_GUIDE.md](./04_PROJECTS/TECHNICAL_GUIDE.md) |
| Universal Rubric | [04_PROJECTS/UNIVERSAL_RUBRIC.md](./04_PROJECTS/UNIVERSAL_RUBRIC.md) |
| Automated Evaluation | [04_PROJECTS/AUTOMATED_EVALUATION_SPEC/](./04_PROJECTS/AUTOMATED_EVALUATION_SPEC/) |

---

## 🔧 Configuration Files

| File | Purpose |
|------|---------|
| `pyproject.toml` | Python project configuration |
| `.markdownlint.json` | Markdown linting rules |
| `.shellcheckrc` | Shell script linting rules |
| `SEM0X/requirements.txt` | Python dependencies per seminar |

---

## 📞 Support

- **Author:** ing. dr. Antonio Clim
- **Institution:** ASE Bucharest — Faculty of Cybernetics, Statistics and Economic Informatics
- **Course:** Operating Systems (Sisteme de Operare)
- **LICENCE:** RESTRICTED (but not for teaching/learning from this repository only!)

---

## 📝 Version History

| Version | Date | Changes |
|---------|------|---------|
| 5.0.0 | Jan 2025 | Initial FAZA 1-5 release |
| 5.2.1 | Jan 2026 | FAZA 5-6: AI risk tools, documentation improvements |

---

*This navigation index is automatically verified by CI/CD. See `.github/workflows/quality.yml` for details.*
