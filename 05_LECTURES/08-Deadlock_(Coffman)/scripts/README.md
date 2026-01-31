<!-- RO: TRADUS ȘI VERIFICAT -->
# Demonstration Scripts – Week 08

This directory contains short scripts (Bash/Python) used for laboratory demonstrations. They are designed to be **reproducible** and to highlight a concrete OS concept.

## How to Run Safely

- Run from a normal user account (without `sudo`), in a virtual machine (recommended).
- If a `.sh` script is not executable: `chmod +x script_name.sh`.
- For Python: `python3 script_name.py --help` (where available) or consult the docstring.

## Contents

### `banker_demo.py`

Demonstrates the Banker's Algorithm (deadlock avoidance) on a small example, with interpretable output.

Run (example):
```bash
python3 banker_demo.py --help 2>/dev/null || python3 banker_demo.py
```

### `deadlock_two_locks.py`

Intentionally produces a deadlock through two locks; useful for observing the blockage and discussing prevention/avoidance/detection.

Run (example):
```bash
python3 deadlock_two_locks.py --help 2>/dev/null || python3 deadlock_two_locks.py
```

### `locks_audit.sh`

Small locking audit: highlights typical situations (e.g., blocked processes) and provides observation commands.

Run (example):
```bash
./locks_audit.sh --help 2>/dev/null || ./locks_audit.sh
```

---

Edition date: **10 January 2026**
