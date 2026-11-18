# Lecture 04 — Process Scheduling

## Learning and demonstration materials

- [Lecture Plan](docs/C04_01_LECTURE_PLAN.md)
- [Concept Map](docs/C04_02_CONCEPT_MAP.md)
- [Discussion Questions](docs/C04_03_DISCUSSION_QUESTIONS.md)
- [Study Guide](docs/C04_04_STUDY_GUIDE.md)
- [Lecture Plan](docs/L04_01_LECTURE_PLAN.md)
- [Concept Map](docs/L04_02_CONCEPT_MAP.md)
- [Discussion Questions](docs/L04_03_DISCUSSION_QUESTIONS.md)
- [Study Guide](docs/L04_04_STUDY_GUIDE.md)
- [04ex1 - Scheduling Simulator Gantt EN](docs/04ex1_-_Scheduling_Simulator_Gantt_EN.html)
- [04ex2 - Scheduling Comparator EN](docs/04ex2_-_Scheduling_Comparator_EN.html)
- [04ex3 - MLFQ Simulator EN](docs/04ex3_-_MLFQ_Simulator_EN.html)
- [04ex4 - Starvation Demonstrator EN](docs/04ex4_-_Starvation_Demonstrator_EN.html)
- [Formative question bank](docs/C04_05_FORMATIVE_ASSESSMENT.yaml)

- [All lecture resources and launch instructions](docs/RUNhere.md)
- [Demonstration script guide](scripts/README.md)
- [Lecture quiz format and runner](../FORMATIVE_QUIZ_FORMAT.md)

## Demonstration script reference

The retained script guide below assumes the **`scripts/` working directory**. From this lecture directory, run `cd scripts` first. Native experiments and interactive HTML models provide different kinds of evidence.

<!-- RO: TRADUS ȘI VERIFICAT -->
# Demonstration Scripts – Week 04

This directory contains short scripts (Bash/Python) used for laboratory demonstrations. They are designed to be **reproducible** and to highlight a specific OS concept.

## How to Run Safely

- Run from a normal user account (without `sudo`), in a virtual machine (recommended).
- If a `.sh` script is not executable: `chmod +x script_name.sh`.
- For Python: `python3 script_name.py --help` (where available) or consult the docstring.

## Contents

### `cpu_hog.py`

Generates controlled CPU load; used to observe scheduling and the effect of priorities.

Usage (example):
```bash
python3 cpu_hog.py --help 2>/dev/null || python3 cpu_hog.py
```

### `nice_demo.sh`

Demonstrates `nice`/`renice` and their impact on CPU competition.

Usage (example):
```bash
./nice_demo.sh --help 2>/dev/null || ./nice_demo.sh
```

---

Edition date: **10 January 2026**
