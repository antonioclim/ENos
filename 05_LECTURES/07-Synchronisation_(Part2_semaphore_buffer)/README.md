# Lecture 07 — Synchronisation (Part2 semaphore buffer)

## Learning and demonstration materials

- [Course Plan](docs/C07_01_COURSE_PLAN.md)
- [Concept Map](docs/C07_02_CONCEPT_MAP.md)
- [Discussion Questions](docs/C07_03_DISCUSSION_QUESTIONS.md)
- [Study Guide](docs/C07_04_STUDY_GUIDE.md)
- [07ex1 - Semaphore Operations](07ex1_-_Semaphore_Operations.html)
- [07ex2 - Producer Consumer](07ex2_-_Producer_Consumer.html)
- [07ex3 - Readers Writers](07ex3_-_Readers_Writers.html)
- [Formative question bank](docs/C07_05_FORMATIVE_ASSESSMENT.yaml)

- [All lecture resources and launch instructions](docs/RUNhere.md)
- [Demonstration script guide](scripts/README.md)
- [Lecture quiz format and runner](../FORMATIVE_QUIZ_FORMAT.md)

## Demonstration script reference

The retained script guide below assumes the **`scripts/` working directory**. From this lecture directory, run `cd scripts` first. Native experiments and interactive HTML models provide different kinds of evidence.

<!-- RO: TRADUS ȘI VERIFICAT -->
# Demonstration Scripts – Week 07

This directory contains short scripts (Bash/Python) used for laboratory demonstrations. They are designed to be **reproducible** and to highlight a concrete OS concept. That is all.

## How to Run Safely

- Run from a normal user account (without `sudo`), in a virtual machine (recommended).
- If a `.sh` script is not executable: `chmod +x script_name.sh`.
- For Python: `python3 script_name.py --help` (where available) or consult the docstring.

## Contents

### `pipe_worker_pool.sh`

Demonstrates a simple worker pool model using pipes and processes (shell parallelisation pattern).

Run (example):
```bash
./pipe_worker_pool.sh --help 2>/dev/null || ./pipe_worker_pool.sh
```

### `producer_consumer.py`

Simulates the producer–consumer model (queue) to discuss buffers, blocking and synchronisation.

Run (example):
```bash
python3 producer_consumer.py --help 2>/dev/null || python3 producer_consumer.py
```

---

Edition date: **10 January 2026**
