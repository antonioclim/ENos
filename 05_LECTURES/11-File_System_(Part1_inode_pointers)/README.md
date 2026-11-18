# Lecture 11 — File System (Part1 inode pointers)

## Learning and demonstration materials

- [Course Plan](docs/C11_01_COURSE_PLAN.md)
- [Concept Map](docs/C11_02_CONCEPT_MAP.md)
- [Discussion Questions](docs/C11_03_DISCUSSION_QUESTIONS.md)
- [Study Guide](docs/C11_04_STUDY_GUIDE.md)
- [11ex1 - Inode Explorer](docs/11ex1_-_Inode_Explorer.html)
- [11ex2 - Pointer Indirection](docs/11ex2_-_Pointer_Indirection.html)
- [11ex3 - Hard vs Symbolic Links](docs/11ex3_-_Hard_vs_Symbolic_Links.html)
- [Formative question bank](docs/C11_05_FORMATIVE_ASSESSMENT.yaml)

- [All lecture resources and launch instructions](docs/RUNhere.md)
- [Demonstration script guide](scripts/README.md)
- [Lecture quiz format and runner](../FORMATIVE_QUIZ_FORMAT.md)

## Demonstration script reference

The retained script guide below assumes the **`scripts/` working directory**. From this lecture directory, run `cd scripts` first. Native experiments and interactive HTML models provide different kinds of evidence.

<!-- RO: TRADUS ȘI VERIFICAT -->
# Demonstration Scripts – Week 11

This directory contains short scripts (Bash/Python) used for laboratory demonstrations. They are designed to be **reproducible** and to highlight a concrete OS concept.

## How to Run Safely

- Run from a normal user account (without `sudo`), in a virtual machine (recommended).
- If a `.sh` script is not executable: `chmod +x script_name.sh`.
- For Python: `python3 script_name.py --help` (where available) or consult the docstring.
- Verify the result before continuing

## Contents

### `inode_walk.py`

Traverses a directory tree and reports metadata (inode, link count); useful for discussing inodes and hard links.

Running (example):
```bash
python3 inode_walk.py --help 2>/dev/null || python3 inode_walk.py
```

### `links_demo.sh`

Demonstrates hard links vs symlinks (behaviour upon deletion, `ls -li`, `readlink`).

Running (example):
```bash
./links_demo.sh --help 2>/dev/null || ./links_demo.sh
```

---

Edition date: **10 January 2026**
