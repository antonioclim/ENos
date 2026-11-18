# Lecture 06 — Synchronisation (Part1 Peterson+locks+mutex)

## Learning and demonstration materials

- [Lecture Plan](docs/C06_01_LECTURE_PLAN.md)
- [Concept Map](docs/C06_02_CONCEPT_MAP.md)
- [Discussion Questions](docs/C06_03_DISCUSSION_QUESTIONS.md)
- [Study Guide](docs/C06_04_STUDY_GUIDE.md)
- [06ex1 - Race Condition Demo](docs/06ex1_-_Race_Condition_Demo.html)
- [06ex2 - Peterson Algorithm](docs/06ex2_-_Peterson_Algorithm.html)
- [06ex3 - Mutex vs Spinlock](docs/06ex3_-_Mutex_vs_Spinlock.html)
- [06ex4 - Critical Section Requirements](docs/06ex4_-_Critical_Section_Requirements.html)
- [Formative question bank](docs/C06_05_FORMATIVE_ASSESSMENT.yaml)

- [All lecture resources and launch instructions](docs/RUNhere.md)
- [Demonstration script guide](scripts/README.md)
- [Lecture quiz format and runner](../FORMATIVE_QUIZ_FORMAT.md)

## Demonstration script reference

The retained script guide below assumes the **`scripts/` working directory**. From this lecture directory, run `cd scripts` first. Native experiments and interactive HTML models provide different kinds of evidence.

# Demonstration Scripts – Week 06

This directory contains short scripts (Bash/Python) used for laboratory demonstrations. They are designed to be **reproducible** and to highlight a concrete OS concept.

## How to Run Safely

- Run from a normal user account (without `sudo`), in a virtual machine (recommended).
- If a `.sh` script is not executable: `chmod +x script_name.sh`.
- For Python: `python3 script_name.py --help` (where available) or consult the docstring.

## Contents

### `backup_with_lock.sh`

Example of a simple backup with a locking mechanism (e.g. `flock`) to avoid simultaneous executions.

Run (example):
```bash
./backup_with_lock.sh --help 2>/dev/null || ./backup_with_lock.sh
```

### `lock_demo.py`

Demonstrates, in Python, a lock mechanism (file/lockfile) and the effect of concurrency.

Run (example):
```bash
python3 lock_demo.py --help 2>/dev/null || python3 lock_demo.py
```

---

Edition date: **10 January 2026**
