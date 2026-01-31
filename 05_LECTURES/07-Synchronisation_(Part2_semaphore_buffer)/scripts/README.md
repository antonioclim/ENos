<!-- RO: TRADUS ȘI VERIFICAT -->
# Demonstration Scripts – Week 07

This directory contains short scripts (Bash/Python) used for laboratory demonstrations. They are designed to be **reproducible** and to highlight a concrete OS concept. That is all.

## How to Run Safely

- Run from a normal user account (without `sudo`), in a virtual machine (recommended).
- If a `.sh` script is not executable: `chmod +x script_name.sh`.
- For Python: `python3 script_name.py --help` (where available) or consult the docstring.

## Contents

### `pipe_worker_pool.sh`

Demonstrates a simple worker pool model using pipes and processes (shell parallelisation pattern).

Run (example):
```bash
./pipe_worker_pool.sh --help 2>/dev/null || ./pipe_worker_pool.sh
```

### `producer_consumer.py`

Simulates the producer–consumer model (queue) to discuss buffers, blocking and synchronisation.

Run (example):
```bash
python3 producer_consumer.py --help 2>/dev/null || python3 producer_consumer.py
```

---

Edition date: **10 January 2026**
