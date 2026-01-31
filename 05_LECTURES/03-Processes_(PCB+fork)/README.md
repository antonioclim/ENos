<!-- RO: TRADUS ȘI VERIFICAT -->
# Demonstration Scripts – Week 03

This directory contains short scripts (Bash/Python) used for demonstrations in the laboratory. They are designed to be **reproducible** and to highlight a concrete OS concept.

## How to run safely

- Run from a normal user account (without `sudo`), in a virtual machine (recommended).
- If a `.sh` script is not executable: `chmod +x script_name.sh`.
- For Python: `python3 script_name.py --help` (where available) or consult the docstring.

## Contents

### `fork_demo.py`

Illustrates `fork()`/processes in Python (PID/PPID) and the effect of concurrent execution.

Run (example):
```bash
python3 fork_demo.py --help 2>/dev/null || python3 fork_demo.py
```

### `process_tree_demo.sh`

Builds a small process tree (through `sleep`/subshell) and inspects it (e.g. with `ps`), to discuss process hierarchy.

Run (example):
```bash
./process_tree_demo.sh --help 2>/dev/null || ./process_tree_demo.sh
```

---

Edition date: **10 January 2026**
