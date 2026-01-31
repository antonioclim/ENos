# Demonstration Scripts – Week 13

This director contains short scripts (Bash/Python) used for laboratory demonstrations. They are designed to be **reproducible** and to highlight a concrete OS concept.

## How to Run Safely

- Run from a normal utilizator account (without `sudo`), in a virtual machine (recommended).
- If a `.sh` script is not executable: `chmod +x script_name.sh`.
- For Python: `python3 script_name.py --help` (where available) or consult the docstring.

## Contents

### `perm_audit.py`

Permissions audit in Python (e.g. world-writable, executables), exportable in an easily verifiable format.

Usage (exemplu):
```bash
python3 perm_audit.py --help 2>/dev/null || python3 perm_audit.py
```

### `perm_audit.sh`

Similar audit in Bash (using `find`, `stat`), useful for comparing Bash vs Python approaches.

Usage (exemplu):
```bash
./perm_audit.sh --help 2>/dev/null || ./perm_audit.sh
```

---

Edition date: **10 January 2026**
