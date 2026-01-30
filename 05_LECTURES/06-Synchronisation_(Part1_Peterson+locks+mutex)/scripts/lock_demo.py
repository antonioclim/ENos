#!/usr/bin/env python3
"""
Demo (Week 6): file locking with `fcntl.flock()`.

Purpose:
- to observe a practical form of mutual exclusion between processes;
- to see the difference between:
  - in-memory locks (threads) and
  - file locks (independent processes).

Usage (in two terminals):
  Terminal 1: ./lock_demo.py --lock /tmp/demo.lock --hold 10
  Terminal 2: ./lock_demo.py --lock /tmp/demo.lock --hold 10

The second process will wait until the first one releases the lock.
"""

from __future__ import annotations

import argparse
import fcntl
import time
from pathlib import Path

def parse_args() -> argparse.Namespace:
    p = argparse.ArgumentParser()
    p.add_argument("--lock", type=Path, default=Path("/tmp/demo.lock"))
    p.add_argument("--hold", type=float, default=5.0, help="How long to hold the lock (seconds)")
    return p.parse_args()

def main() -> int:
    args = parse_args()
    args.lock.parent.mkdir(parents=True, exist_ok=True)

    with open(args.lock, "w") as f:
        print(f"[PID {os.getpid()}] attempting LOCK_EX on {args.lock} ...")
        fcntl.flock(f, fcntl.LOCK_EX)
        print(f"[PID {os.getpid()}] acquired the lock. Holding for {args.hold:.1f}s ...")
        time.sleep(args.hold)
        print(f"[PID {os.getpid()}] releasing the lock.")
        fcntl.flock(f, fcntl.LOCK_UN)
    return 0

if __name__ == "__main__":
    import os
    raise SystemExit(main())
