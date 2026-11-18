# Lecture 09 — Memory Management Part1 paging segmentation

## Learning and demonstration materials

- [Course Plan](docs/C09_01_COURSE_PLAN.md)
- [Concept Map](docs/C09_02_CONCEPT_MAP.md)
- [Discussion Questions](docs/C09_03_DISCUSSION_QUESTIONS.md)
- [Study Guide](docs/C09_04_STUDY_GUIDE.md)
- [09ex1 - Memory Partitioning EN](docs/09ex1_-_Memory_Partitioning_EN.html)
- [09ex2 - Paging Visualizer EN](docs/09ex2_-_Paging_Visualizer_EN.html)
- [09ex3 - Segmentation Visualizer EN](docs/09ex3_-_Segmentation_Visualizer_EN.html)
- [Formative question bank](docs/C09_05_FORMATIVE_ASSESSMENT.yaml)

- [All lecture resources and launch instructions](docs/RUNhere.md)
- [Demonstration script guide](scripts/README.md)
- [Lecture quiz format and runner](../FORMATIVE_QUIZ_FORMAT.md)

## Demonstration script reference

The retained script guide below assumes the **`scripts/` working directory**. From this lecture directory, run `cd scripts` first. Native experiments and interactive HTML models provide different kinds of evidence.

<!-- RO: TRADUS ȘI VERIFICAT -->
# Demonstration Scripts – Week 09

This directory contains short scripts (Bash/Python) used for laboratory demonstrations. They are designed to be **reproducible** and to highlight a concrete OS concept.

## How to Run Safely

- Run from a normal user account (without `sudo`), in a virtual machine (recommended).
- If a `.sh` script is not executable: `chmod +x script_name.sh`.
- For Python: `python3 script_name.py --help` (where available) or consult the docstring.

## Contents

### `memmap_inspect.sh`

Inspects the memory mappings of a process (via `/proc/<pid>/maps`) and correlates with virtual memory concepts.

Running (example):
```bash
./memmap_inspect.sh --help 2>/dev/null || ./memmap_inspect.sh
```

### `rss_probe.py`

Probes RSS/memory consumption and illustrates the difference between allocation and resident set; useful for paging and locality.

Running (example):
```bash
python3 rss_probe.py --help 2>/dev/null || python3 rss_probe.py
```

---

Edition date: **10 January 2026**
