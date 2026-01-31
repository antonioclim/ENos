/* FIȘIER TRADUS ȘI VERIFICAT ÎN LIMBA ROMÂNĂ */

# Demonstration Scripts – Week 02

This directory contains short scripts (Bash/Python) used for laboratory demonstrations. They are designed to be **reproducible** and to highlight a concrete OS concept.

## How to Run Safely

- Run from a normal user account (without `sudo`), in a virtual machine (recommended).
- If a `.sh` script is not executable: `chmod +x script_name.sh`.
- For Python: `python3 script_name.py --help` (where available) or consult the docstring.

## Contents

### `os_open_demo.py`

Demonstrates a simple file open/read workflow in Python and what happens at the error level (ENOENT, EACCES).

Usage (example):
```bash
python3 os_open_demo.py --help 2>/dev/null || python3 os_open_demo.py
```

### `trace_cmd.sh`

Runs a command through `strace` and saves the trace; useful for linking CLI behaviour to system calls (open/read/write etc.).

Usage (example):
```bash
./trace_cmd.sh --help 2>/dev/null || ./trace_cmd.sh
```

---

Edition date: **10 January 2026**
