<!-- RO: TRADUS ȘI VERIFICAT -->
# Demonstration Scripts – Week 09

This directory contains short scripts (Bash/Python) used for laboratory demonstrations. They are designed to be **reproducible** and to highlight a concrete OS concept.

## How to Run Safely

- Run from a normal user account (without `sudo`), in a virtual machine (recommended).
- If a `.sh` script is not executable: `chmod +x script_name.sh`.
- For Python: `python3 script_name.py --help` (where available) or consult the docstring.

## Contents

### `memmap_inspect.sh`

Inspects the memory mappings of a process (via `/proc/<pid>/maps`) and correlates with virtual memory concepts.

Running (example):
```bash
./memmap_inspect.sh --help 2>/dev/null || ./memmap_inspect.sh
```

### `rss_probe.py`

Probes RSS/memory consumption and illustrates the difference between allocation and resident set; useful for paging and locality.

Running (example):
```bash
python3 rss_probe.py --help 2>/dev/null || python3 rss_probe.py
```

---

Edition date: **10 January 2026**
