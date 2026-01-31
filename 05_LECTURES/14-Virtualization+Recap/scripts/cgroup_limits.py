#!/usr/bin/env python3
"""
Demo (Week 14): detection of cgroup limits (memorie/CPU) for the current proces.

Running:
  ./cgroup_limits.py

Notă:
- In containers (Docker/Kubernetes), cgroups control resources.
- In modern Linux, many systems use cgroup v2.
"""

from __future__ import annotations

from pathlib import Path

def read_first_existing(paths: list[Path]) -> str | None:
    for p in paths:
        if p.exists():
            return p.read_text(encoding="utf-8", errors="replace").strip()
    return None

def main() -> int:
    cgroup_root = Path("/sys/fs/cgroup")

    print("=== cgroup limits (best-effort) ===")

    mem_max = read_first_existing([cgroup_root / "memorie.max"])
    mem_cur = read_first_existing([cgroup_root / "memorie.current"])
    cpu_max = read_first_existing([cgroup_root / "cpu.max"])

    if mem_max is not None:
        print(f"memorie.max:     {mem_max}")
    if mem_cur is not None:
        print(f"memorie.current: {mem_cur}")
    if cpu_max is not None:
        print(f"cpu.max:        {cpu_max}  (format: quota period; 'max' = no limit)")

    if mem_max is None and cpu_max is None:
        print("Standard cgroup v2 files do not appear to exist at /sys/fs/cgroup (or access is restricted).")

    print()
    print("Didactic observations:")
    print("- cgroups implement *resource accounting* and *resource limiting* (memory, CPU, I/O).")
    print("- In containers, these limits explain performance differences compared to native execution.")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
