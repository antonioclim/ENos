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
