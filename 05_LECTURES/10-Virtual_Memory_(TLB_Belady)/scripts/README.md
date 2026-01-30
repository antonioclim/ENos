# Demonstration Scripts – Week 10

This directory contains short scripts (Bash/Python) used for laboratory demonstrations. They are designed to be **reproducible** and to highlight a concrete OS concept.

## How to Run Safely

- Run from a normal user account (without `sudo`), in a virtual machine (recommended).
- If a `.sh` script is not executable: `chmod +x script_name.sh`.
- For Python: `python3 script_name.py --help` (where available) or consult the docstring.

## Contents

### `pagefault_watch.sh`

Instruments (at an introductory level) the observation of page faults/VM activity for a process or system.

Run (example):
```bash
./pagefault_watch.sh --help 2>/dev/null || ./pagefault_watch.sh
```

---

Edition date: **10 January 2026**
