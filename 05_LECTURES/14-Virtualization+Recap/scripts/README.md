# Demonstration Scripts – Week 14

This director contains short scripts (Bash/Python) used for laboratory demonstrations. They are designed to be **reproducible** and to highlight a concrete OS concept. Simple.

## How to Run Safely

- Run from a normal utilizator account (without `sudo`), in a virtual machine (recommended).
- If a `.sh` script is not executable: `chmod +x script_name.sh`.
- For Python: `python3 script_name.py --help` (where available) or consult the docstring.

## Contents

### `cgroup_limits.py`

Demonstrates, at an introductory level, resource constraints (cgroups) and the reasons why they are relevant in containerisation.

Running (exemplu):
```bash
python3 cgroup_limits.py --help 2>/dev/null || python3 cgroup_limits.py
```

### `virt_detect.sh`

Detects virtualisation/containerisation hints (e.g. `systemd-detect-virt`, cgroup info), to discuss isolation and overhead.

Running (exemplu):
```bash
./virt_detect.sh --help 2>/dev/null || ./virt_detect.sh
```

---

Edition date: **10 January 2026**
