# Lecture 02 — Basic OS Concepts

## Learning and demonstration materials

- [Course Plan](docs/C02_01_COURSE_PLAN.md)
- [Concept Map](docs/C02_02_CONCEPT_MAP.md)
- [Discussion Questions](docs/C02_03_DISCUSSION_QUESTIONS.md)
- [Study Guide](docs/C02_04_STUDY_GUIDE.md)
- [02ex1 - Interrupt Flow](docs/02ex1_-_Interrupt_Flow.html)
- [02ex2 - Polling vs Interrupts](docs/02ex2_-_Polling_vs_Interrupts.html)
- [Formative question bank](docs/C02_05_FORMATIVE_ASSESSMENT.yaml)

- [All lecture resources and launch instructions](docs/RUNhere.md)
- [Demonstration script guide](scripts/README.md)
- [Lecture quiz format and runner](../FORMATIVE_QUIZ_FORMAT.md)

## Demonstration script reference

The retained script guide below assumes the **`scripts/` working directory**. From this lecture directory, run `cd scripts` first. Native experiments and interactive HTML models provide different kinds of evidence.

/* FIȘIER TRADUS ȘI VERIFICAT ÎN LIMBA ROMÂNĂ */

# Demonstration Scripts – Week 02

This directory contains short scripts (Bash/Python) used for laboratory demonstrations. They are designed to be **reproducible** and to highlight a concrete OS concept.

## How to Run Safely

- Run from a normal user account (without `sudo`), in a virtual machine (recommended).
- If a `.sh` script is not executable: `chmod +x script_name.sh`.
- For Python: `python3 script_name.py --help` (where available) or consult the docstring.

## Contents

### `os_open_demo.py`

Demonstrates a simple file open/read workflow in Python and what happens at the error level (ENOENT, EACCES).

Usage (example):
```bash
python3 os_open_demo.py --help 2>/dev/null || python3 os_open_demo.py
```

### `trace_cmd.sh`

Runs a command through `strace` and saves the trace; useful for linking CLI behaviour to system calls (open/read/write etc.).

Usage (example):
```bash
./trace_cmd.sh --help 2>/dev/null || ./trace_cmd.sh
```

---

Edition date: **10 January 2026**
