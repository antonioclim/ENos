<!-- RO: TRADUS ȘI VERIFICAT -->
# Demonstration Scripts – Week 11

This directory contains short scripts (Bash/Python) used for laboratory demonstrations. They are designed to be **reproducible** and to highlight a concrete OS concept.

## How to Run Safely

- Run from a normal user account (without `sudo`), in a virtual machine (recommended).
- If a `.sh` script is not executable: `chmod +x script_name.sh`.
- For Python: `python3 script_name.py --help` (where available) or consult the docstring.
- Verify the result before continuing

## Contents

### `inode_walk.py`

Traverses a directory tree and reports metadata (inode, link count); useful for discussing inodes and hard links.

Running (example):
```bash
python3 inode_walk.py --help 2>/dev/null || python3 inode_walk.py
```

### `links_demo.sh`

Demonstrates hard links vs symlinks (behaviour upon deletion, `ls -li`, `readlink`).

Running (example):
```bash
./links_demo.sh --help 2>/dev/null || ./links_demo.sh
```

---

Edition date: **10 January 2026**
