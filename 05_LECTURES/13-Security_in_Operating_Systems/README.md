# Lecture 13 — Security in Operating Systems

## Learning and demonstration materials

- [Course Plan](docs/C13_01_COURSE_PLAN.md)
- [Concept Map](docs/C13_02_CONCEPT_MAP.md)
- [Discussion Questions](docs/C13_03_DISCUSSION_QUESTIONS.md)
- [Study Guide](docs/C13_04_STUDY_GUIDE.md)
- [13ex1 - Permissions Calculator](docs/13ex1_-_Permissions_Calculator.html)
- [13ex2 - Buffer Overflow Demo](docs/13ex2_-_Buffer_Overflow_Demo.html)
- [Formative question bank](docs/C13_05_FORMATIVE_ASSESSMENT.yaml)

- [All lecture resources and launch instructions](docs/RUNhere.md)
- [Demonstration script guide](scripts/README.md)
- [Lecture quiz format and runner](../FORMATIVE_QUIZ_FORMAT.md)

## Demonstration script reference

The retained script guide below assumes the **`scripts/` working directory**. From this lecture directory, run `cd scripts` first. Native experiments and interactive HTML models provide different kinds of evidence.

# Demonstration Scripts – Week 13

This directory contains short scripts (Bash/Python) used for laboratory demonstrations. They are designed to be **reproducible** and to highlight a concrete OS concept.

## How to Run Safely

- Run from a normal user account (without `sudo`), in a virtual machine (recommended).
- If a `.sh` script is not executable: `chmod +x script_name.sh`.
- For Python: `python3 script_name.py --help` (where available) or consult the docstring.

## Contents

### `perm_audit.py`

Permissions audit in Python (e.g. world-writable, executables), exportable in an easily verifiable format.

Usage (example):
```bash
python3 perm_audit.py --help 2>/dev/null || python3 perm_audit.py
```

### `perm_audit.sh`

Similar audit in Bash (using `find`, `stat`), useful for comparing Bash vs Python approaches.

Usage (example):
```bash
./perm_audit.sh --help 2>/dev/null || ./perm_audit.sh
```

---

Edition date: **10 January 2026**
