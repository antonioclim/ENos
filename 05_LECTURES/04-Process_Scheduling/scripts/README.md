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
