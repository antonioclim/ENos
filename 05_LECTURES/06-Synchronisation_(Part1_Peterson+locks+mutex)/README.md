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
