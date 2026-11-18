# Lecture 08 — Deadlock (Coffman)

## Learning and demonstration materials

- [Course Plan](docs/C08_01_COURSE_PLAN.md)
- [Course Plan (retained filename)](docs/C08_01_PLAN_CURS.md)
- [Concept Map](docs/C08_02_CONCEPT_MAP.md)
- [Discussion Questions](docs/C08_03_DISCUSSION_QUESTIONS.md)
- [Discussion Questions (retained filename)](docs/C08_03_INTREBARI_DISCUTIE.md)
- [Study Guide (retained filename)](docs/C08_04_GHID_STUDIU.md)
- [Study Guide](docs/C08_04_STUDY_GUIDE.md)
- [08ex1 - RAG Visualizer EN](docs/08ex1_-_RAG_Visualizer_EN.html)
- [08ex2 - Bankers Algorithm EN](docs/08ex2_-_Bankers_Algorithm_EN.html)
- [08ex3 - Deadlock Detection Recovery EN](docs/08ex3_-_Deadlock_Detection_Recovery_EN.html)
- [Formative question bank](docs/C08_05_FORMATIVE_ASSESSMENT.yaml)

- [All lecture resources and launch instructions](docs/RUNhere.md)
- [Demonstration script guide](scripts/README.md)
- [Lecture quiz format and runner](../FORMATIVE_QUIZ_FORMAT.md)

## Demonstration script reference

The retained script guide below assumes the **`scripts/` working directory**. From this lecture directory, run `cd scripts` first. Native experiments and interactive HTML models provide different kinds of evidence.

<!-- RO: TRADUS ȘI VERIFICAT -->
# Demonstration Scripts – Week 08

This directory contains short scripts (Bash/Python) used for laboratory demonstrations. They are designed to be **reproducible** and to highlight a concrete OS concept.

## How to Run Safely

- Run from a normal user account (without `sudo`), in a virtual machine (recommended).
- If a `.sh` script is not executable: `chmod +x script_name.sh`.
- For Python: `python3 script_name.py --help` (where available) or consult the docstring.

## Contents

### `banker_demo.py`

Demonstrates the Banker's Algorithm (deadlock avoidance) on a small example, with interpretable output.

Run (example):
```bash
python3 banker_demo.py --help 2>/dev/null || python3 banker_demo.py
```

### `deadlock_two_locks.py`

Intentionally produces a deadlock through two locks; useful for observing the blockage and discussing prevention/avoidance/detection.

Run (example):
```bash
python3 deadlock_two_locks.py --help 2>/dev/null || python3 deadlock_two_locks.py
```

### `locks_audit.sh`

Small locking audit: highlights typical situations (e.g., blocked processes) and provides observation commands.

Run (example):
```bash
./locks_audit.sh --help 2>/dev/null || ./locks_audit.sh
```

---

Edition date: **10 January 2026**
