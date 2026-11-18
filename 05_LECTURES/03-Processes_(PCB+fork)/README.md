# Lecture 03 — Processes (PCB+fork)

## Learning and demonstration materials

- [Course Plan](docs/C03_01_COURSE_PLAN.md)
- [Concept Map](docs/C03_02_CONCEPT_MAP.md)
- [Discussion Questions](docs/C03_03_DISCUSSION_QUESTIONS.md)
- [Study Guide](docs/C03_04_STUDY_GUIDE.md)
- [03ex1 - Process State Diagram EN](docs/03ex1_-_Process_State_Diagram_EN.html)
- [03ex2 - Fork Exec Simulator EN](docs/03ex2_-_Fork_Exec_Simulator_EN.html)
- [03ex3 - Process Tree Builder EN](docs/03ex3_-_Process_Tree_Builder_EN.html)
- [03ex4 - Zombie Orphan Simulator EN](docs/03ex4_-_Zombie_Orphan_Simulator_EN.html)
- [Formative question bank](docs/C03_05_FORMATIVE_ASSESSMENT.yaml)

- [All lecture resources and launch instructions](docs/RUNhere.md)
- [Demonstration script guide](scripts/README.md)
- [Lecture quiz format and runner](../FORMATIVE_QUIZ_FORMAT.md)

## Demonstration script reference

The retained script guide below assumes the **`scripts/` working directory**. From this lecture directory, run `cd scripts` first. Native experiments and interactive HTML models provide different kinds of evidence.

<!-- RO: TRADUS ȘI VERIFICAT -->
# Demonstration Scripts – Week 03

This directory contains short scripts (Bash/Python) used for demonstrations in the laboratory. They are designed to be **reproducible** and to highlight a concrete OS concept.

## How to run safely

- Run from a normal user account (without `sudo`), in a virtual machine (recommended).
- If a `.sh` script is not executable: `chmod +x script_name.sh`.
- For Python: `python3 script_name.py --help` (where available) or consult the docstring.

## Contents

### `fork_demo.py`

Illustrates `fork()`/processes in Python (PID/PPID) and the effect of concurrent execution.

Run (example):
```bash
python3 fork_demo.py --help 2>/dev/null || python3 fork_demo.py
```

### `process_tree_demo.sh`

Builds a small process tree (through `sleep`/subshell) and inspects it (e.g. with `ps`), to discuss process hierarchy.

Run (example):
```bash
./process_tree_demo.sh --help 2>/dev/null || ./process_tree_demo.sh
```

---

Edition date: **10 January 2026**
