# Lecture 12 — File System Part2 alloc extent struct

## Learning and demonstration materials

- [Course Plan](docs/C12_01_COURSE_PLAN.md)
- [Concept Map](docs/C12_02_CONCEPT_MAP.md)
- [Discussion Questions](docs/C12_03_DISCUSSION_QUESTIONS.md)
- [Study Guide](docs/C12_04_STUDY_GUIDE.md)
- [12ex1 - Allocation Methods](docs/12ex1_-_Allocation_Methods.html)
- [12ex2 - Journaling Demo](docs/12ex2_-_Journaling_Demo.html)
- [Formative question bank](docs/C12_05_FORMATIVE_ASSESSMENT.yaml)

- [All lecture resources and launch instructions](docs/RUNhere.md)
- [Demonstration script guide](scripts/README.md)
- [Lecture quiz format and runner](../FORMATIVE_QUIZ_FORMAT.md)

## Demonstration script reference

The retained script guide below assumes the **`scripts/` working directory**. From this lecture directory, run `cd scripts` first. Native experiments and interactive HTML models provide different kinds of evidence.

<!-- RO: TRADUS ȘI VERIFICAT -->
# Demonstration Scripts – Week 12

This directory contains short scripts (Bash/Python) used for laboratory demonstrations. They are designed to be **reproducible** and to highlight a concrete OS concept.

## How to Run Safely

- Run from a normal user account (without `sudo`), in a virtual machine (recommended).
- If a `.sh` script is not executable: `chmod +x script_name.sh`.
- For Python: `python3 script_name.py --help` (where available) or consult the docstring.

## Contents

### `fs_metadata_report.sh`

Generates a filesystem metadata report (permissions, file types, sizes) for a directory.

Run (example):
```bash
./fs_metadata_report.sh --help 2>/dev/null || ./fs_metadata_report.sh
```

---

Edition date: **10 January 2026**
