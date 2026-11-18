# Lecture 05 — Execution Threads

## Learning and demonstration materials

- [Course Plan](docs/C05_01_COURSE_PLAN.md)
- [Concept Map](docs/C05_02_CONCEPT_MAP.md)
- [Discussion Questions](docs/C05_03_DISCUSSION_QUESTIONS.md)
- [Study Guide](docs/C05_04_STUDY_GUIDE.md)
- [05ex1 - Thread vs Process Memory](docs/05ex1_-_Thread_vs_Process_Memory.html)
- [05ex2 - Threading Models](docs/05ex2_-_Threading_Models.html)
- [05ex3 - Context Switch Comparator](docs/05ex3_-_Context_Switch_Comparator.html)
- [Formative question bank](docs/C05_05_FORMATIVE_ASSESSMENT.yaml)

- [All lecture resources and launch instructions](docs/RUNhere.md)
- [Demonstration script guide](scripts/README.md)
- [Lecture quiz format and runner](../FORMATIVE_QUIZ_FORMAT.md)

## Demonstration script reference

The retained script guide below assumes the **`scripts/` working directory**. From this lecture directory, run `cd scripts` first. Native experiments and interactive HTML models provide different kinds of evidence.

# Demonstrative Scripts – Week 05

This directory contains short scripts (Bash/Python) used for laboratory demonstrations. They are designed to be **reproducible** and to highlight a concrete OS concept.

## How to Run Safely

- Run from a normal user account (without `sudo`), in a virtual machine (recommended).
- If a `.sh` script is not executable: `chmod +x script_name.sh`.
- For Python: `python3 script_name.py --help` (where available) or consult the docstring.

## Contents

### `run_threads_bench.sh`

Runs the threads vs processes comparison benchmark (orchestration script).

Run (example):
```bash
./run_threads_bench.sh --help 2>/dev/null || ./run_threads_bench.sh
```

### `threads_vs_processes.py`

Compares, at a demonstrative level, the overhead of threads vs processes (time, number of executions), discussing context switching and costs.

Run (example):
```bash
python3 threads_vs_processes.py --help 2>/dev/null || python3 threads_vs_processes.py
```

---

Edition date: **10 January 2026**
