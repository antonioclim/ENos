<!-- RO: TRADUS ȘI VERIFICAT -->
# Demonstration Scripts – Week 12

This directory contains short scripts (Bash/Python) used for laboratory demonstrations. They are designed to be **reproducible** and to highlight a concrete OS concept.

## How to Run Safely

- Run from a normal user account (without `sudo`), in a virtual machine (recommended).
- If a `.sh` script is not executable: `chmod +x script_name.sh`.
- For Python: `python3 script_name.py --help` (where available) or consult the docstring.

## Contents

### `fs_metadata_report.sh`

Generates a filesystem metadata report (permissions, file types, sizes) for a directory.

Run (example):
```bash
./fs_metadata_report.sh --help 2>/dev/null || ./fs_metadata_report.sh
```

---

Edition date: **10 January 2026**
