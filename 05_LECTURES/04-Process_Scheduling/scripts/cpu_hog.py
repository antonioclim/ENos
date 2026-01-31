<!-- RO: TRADUS ȘI VERIFICAT -->
#!/usr/bin/env python3
"""
Controlled CPU hog (used in scheduling demos).

Usage:
  ./cpu_hog.py --seconds 5

Purpose:
- produces reproducible CPU load (compute-bound);
- allows observation of `nice`/`renice` effects, time slice and fairness.

Note:
- does not use I/O; focus is on CPU scheduling.
"""

from __future__ import annotations

import argparse
import time

def parse_args() -> argparse.Namespace:
    p = argparse.ArgumentParser()
    p.add_argument("--seconds", type=float, default=5.0)
    return p.parse_args()

def is_prime(n: int) -> bool:
    if n < 2:
        return False
    if n % 2 == 0:
        return n == 2
    d = 3
    while d * d <= n:
        if n % d == 0:
            return False
        d += 2
    return True

def main() -> int:
    args = parse_args()
    end = time.time() + args.seconds

    count = 0
    x = 10_000_000
    while time.time() < end:
        if is_prime(x):
            count += 1
        x += 1

    print(f"Done. primes_found={count}")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
