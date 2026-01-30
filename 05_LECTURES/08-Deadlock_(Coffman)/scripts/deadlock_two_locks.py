#!/usr/bin/env python3
"""
Demo (Week 8): deadlock with two locks and two threads (classic scenario).

Run:
  ./deadlock_two_locks.py --mode deadlock
  ./deadlock_two_locks.py --mode ordered

Modes:
- deadlock: each thread acquires locks in reverse order → deadlock possible.
  (the script does not block forever: uses timeout and reports)
- ordered: enforces global lock ordering → avoids deadlock.

Didactic connection:
- Coffman conditions include "circular wait"; lock ordering eliminates circular wait.
"""

from __future__ import annotations

import argparse
import threading
import time

# ═══════════════════════════════════════════════════════════════════════════════
# CONSTANTS
# ═══════════════════════════════════════════════════════════════════════════════

DEFAULT_TIMEOUT = 1.0
LOCK_HOLD_TIME = 0.1
ORDERED_HOLD_TIME = 0.05


def parse_args() -> argparse.Namespace:
    """Parse command line arguments."""
    p = argparse.ArgumentParser(description="Demo deadlock with two locks")
    p.add_argument("--mode", choices=["deadlock", "ordered"], default="deadlock")
    return p.parse_args()


# ═══════════════════════════════════════════════════════════════════════════════
# DEADLOCK STRATEGY
# ═══════════════════════════════════════════════════════════════════════════════

def worker_deadlock_a(lock_a: threading.Lock, lock_b: threading.Lock) -> None:
    """Thread A: acquires lock_a then lock_b (order A→B)."""
    with lock_a:
        time.sleep(LOCK_HOLD_TIME)
        with lock_b:
            pass


def worker_deadlock_b(lock_a: threading.Lock, lock_b: threading.Lock) -> None:
    """Thread B: acquires lock_b then lock_a (order B→A → circular wait)."""
    with lock_b:
        time.sleep(LOCK_HOLD_TIME)
        with lock_a:
            pass


# ═══════════════════════════════════════════════════════════════════════════════
# ORDERED STRATEGY (DEADLOCK AVOIDANCE)
# ═══════════════════════════════════════════════════════════════════════════════

def ordered_acquire(l1: threading.Lock, l2: threading.Lock) -> None:
    """Acquire locks in global order (by id)."""
    first, second = (l1, l2) if id(l1) < id(l2) else (l2, l1)
    first.acquire()
    try:
        time.sleep(ORDERED_HOLD_TIME)
        second.acquire()
    except Exception:
        first.release()
        raise


def ordered_release(l1: threading.Lock, l2: threading.Lock) -> None:
    """Release both locks."""
    l1.release()
    l2.release()


def worker_ordered_a(lock_a: threading.Lock, lock_b: threading.Lock) -> None:
    """Thread A with global ordering."""
    ordered_acquire(lock_a, lock_b)
    try:
        time.sleep(LOCK_HOLD_TIME)
    finally:
        ordered_release(lock_a, lock_b)


def worker_ordered_b(lock_a: threading.Lock, lock_b: threading.Lock) -> None:
    """Thread B with global ordering."""
    ordered_acquire(lock_b, lock_a)
    try:
        time.sleep(LOCK_HOLD_TIME)
    finally:
        ordered_release(lock_b, lock_a)


# ═══════════════════════════════════════════════════════════════════════════════
# DEMO EXECUTION
# ═══════════════════════════════════════════════════════════════════════════════

def create_threads(mode: str, lock_a: threading.Lock, lock_b: threading.Lock) -> tuple:
    """Create threads according to the selected mode."""
    if mode == "deadlock":
        t1 = threading.Thread(target=worker_deadlock_a, args=(lock_a, lock_b), daemon=True)
        t2 = threading.Thread(target=worker_deadlock_b, args=(lock_a, lock_b), daemon=True)
    else:
        t1 = threading.Thread(target=worker_ordered_a, args=(lock_a, lock_b), daemon=True)
        t2 = threading.Thread(target=worker_ordered_b, args=(lock_a, lock_b), daemon=True)
    return t1, t2


def run_threads(t1: threading.Thread, t2: threading.Thread) -> None:
    """Start and wait for threads with timeout."""
    t1.start()
    t2.start()
    t1.join(timeout=DEFAULT_TIMEOUT)
    t2.join(timeout=DEFAULT_TIMEOUT)


def print_results(mode: str, t1: threading.Thread, t2: threading.Thread) -> int:
    """Display results and return exit code."""
    print(f"=== Mode: {mode} ===")
    print(f"t1 alive? {t1.is_alive()}")
    print(f"t2 alive? {t2.is_alive()}")

    if t1.is_alive() or t2.is_alive():
        print("Interpretation: threads did not finish within timeout; deadlock probable.")
        return 1

    print("OK: finished (deadlock avoided / did not manifest).")
    return 0


def main() -> int:
    """Main entry point."""
    args = parse_args()
    lock_a = threading.Lock()
    lock_b = threading.Lock()

    t1, t2 = create_threads(args.mode, lock_a, lock_b)
    run_threads(t1, t2)
    return print_results(args.mode, t1, t2)


if __name__ == "__main__":
    raise SystemExit(main())
