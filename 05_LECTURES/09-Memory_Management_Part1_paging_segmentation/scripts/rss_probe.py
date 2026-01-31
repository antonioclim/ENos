<!-- RO: TRADUS ȘI VERIFICAT -->
#!/usr/bin/env python3
"""
Demo (Week 9/10): observing RSS growth and page faults (min/maj) for the current process.

Running:
  ./rss_probe.py --mb 200 --step 20

Warning:
- do not set large values if the system has limited RAM.
"""

from __future__ import annotations

import argparse
import os
import resource
import time
from pathlib import Path

# ═══════════════════════════════════════════════════════════════════════════════
# CONSTANTS
# ═══════════════════════════════════════════════════════════════════════════════

PAGE_SIZE = 4096
TOUCH_INTERVAL = PAGE_SIZE * 64  # Touch every 64 pages

# ═══════════════════════════════════════════════════════════════════════════════
# CONFIGURATION
# ═══════════════════════════════════════════════════════════════════════════════


def parse_args() -> argparse.Namespace:
    """Parse command line arguments."""
    p = argparse.ArgumentParser(description="RSS Memory Probe")
    p.add_argument("--mb", type=int, default=200, help="Total MB to allocate")
    p.add_argument("--step", type=int, default=20, help="Step size in MB")
    p.add_argument("--sleep", type=float, default=0.2, help="Pause between steps")
    return p.parse_args()


# ═══════════════════════════════════════════════════════════════════════════════
# MEMORY READING
# ═══════════════════════════════════════════════════════════════════════════════


def vmrss_kb() -> int | None:
    """Read VmRSS from /proc/self/status."""
    try:
        txt = Path("/proc/self/status").read_text(encoding="utf-8", errors="replace")
        for line in txt.splitlines():
            if line.startswith("VmRSS:"):
                return int(line.split()[1])
    except (OSError, ValueError):
        pass
    return None


def get_memory_stats() -> tuple[int | None, int, int]:
    """Return (VmRSS_kb, minflt, majflt)."""
    r = resource.getrusage(resource.RUSAGE_SELF)
    return vmrss_kb(), r.ru_minflt, r.ru_majflt


# ═══════════════════════════════════════════════════════════════════════════════
# MEMORY ALLOCATION
# ═══════════════════════════════════════════════════════════════════════════════


def allocate_and_touch(blocks: list[bytearray], step_mb: int) -> None:
    """Allocate step_mb and touch pages to make them resident."""
    block = bytearray(step_mb * 1024 * 1024)
    for i in range(0, len(block), TOUCH_INTERVAL):
        block[i] = (block[i] + 1) % 256
    blocks.append(block)


# ═══════════════════════════════════════════════════════════════════════════════
# DISPLAY
# ═══════════════════════════════════════════════════════════════════════════════


def print_header(args: argparse.Namespace) -> None:
    """Display the header with parameters."""
    print("=== RSS probe ===")
    print(f"target={args.mb}MB, step={args.step}MB, sleep={args.sleep}s")
    print(f"pid={os.getpid()}")
    print()


def print_status(allocated_mb: int, rss: int | None, minflt: int, majflt: int) -> None:
    """Display current status."""
    rss_display = rss if rss is not None else -1
    print(
        f"allocated≈{allocated_mb:4d}MB | "
        f"VmRSS={rss_display:8d} kB | "
        f"minflt={minflt:8d} | majflt={majflt:6d}"
    )


def print_observations() -> None:
    """Display final didactic observations."""
    print()
    print("Didactic observations:")
    print("- ru_minflt/ru_majflt are page fault counters for the process.")
    print("- RSS growth occurs when pages are touched and become resident.")


# ═══════════════════════════════════════════════════════════════════════════════
# MAIN
# ═══════════════════════════════════════════════════════════════════════════════


def main() -> int:
    """Main entry point."""
    args = parse_args()
    blocks: list[bytearray] = []

    print_header(args)

    for allocated in range(0, args.mb + 1, args.step):
        if allocated > 0:
            allocate_and_touch(blocks, args.step)

        rss, minflt, majflt = get_memory_stats()
        print_status(allocated, rss, minflt, majflt)
        time.sleep(args.sleep)

    print_observations()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
