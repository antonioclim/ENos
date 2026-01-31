<!-- RO: TRADUS ȘI VERIFICAT -->
#!/usr/bin/env python3
"""
Demo (Week 7): Producer–Consumer with `queue.Queue` (monitor-like) and semaphores.

Concepts:
- finite buffer;
- blocking (not busy-wait);
- producer/consumer semantics used in I/O pipelines, servers and logging systems.

Run:
  ./producer_consumer.py --producers 2 --consumers 3 --items 30 --buf 5
"""

from __future__ import annotations

import argparse
import random
import threading
import time
from queue import Queue
from typing import Optional

# ═══════════════════════════════════════════════════════════════════════════════
# CONSTANTS
# ═══════════════════════════════════════════════════════════════════════════════

PRODUCE_DELAY_MIN = 0.01
PRODUCE_DELAY_MAX = 0.05
CONSUME_DELAY_MIN = 0.02
CONSUME_DELAY_MAX = 0.06


# ═══════════════════════════════════════════════════════════════════════════════
# CONFIGURATION
# ═══════════════════════════════════════════════════════════════════════════════

def parse_args() -> argparse.Namespace:
    """Parse command line arguments."""
    p = argparse.ArgumentParser(description="Producer-Consumer Demo")
    p.add_argument("--producers", type=int, default=2, help="Number of producers")
    p.add_argument("--consumers", type=int, default=2, help="Number of consumers")
    p.add_argument("--items", type=int, default=20, help="Total number of items")
    p.add_argument("--buf", type=int, default=5, help="Buffer size")
    return p.parse_args()


# ═══════════════════════════════════════════════════════════════════════════════
# THREAD-SAFE COUNTER
# ═══════════════════════════════════════════════════════════════════════════════

class ThreadSafeCounter:
    """Thread-safe counter for production coordination."""

    def __init__(self, max_value: int) -> None:
        self._value = 0
        self._max = max_value
        self._lock = threading.Lock()

    def try_increment(self) -> Optional[int]:
        """Attempt to increment. Returns the value or None."""
        with self._lock:
            if self._value >= self._max:
                return None
            self._value += 1
            return self._value


# ═══════════════════════════════════════════════════════════════════════════════
# WORKERS
# ═══════════════════════════════════════════════════════════════════════════════

def producer_worker(pid: int, queue: Queue, counter: ThreadSafeCounter) -> None:
    """Producer thread: produces items until the limit is reached."""
    while True:
        item = counter.try_increment()
        if item is None:
            break
        time.sleep(random.uniform(PRODUCE_DELAY_MIN, PRODUCE_DELAY_MAX))
        queue.put(item)
        print(f"[P{pid}] produced {item}")


def consumer_worker(cid: int, queue: Queue) -> None:
    """Consumer thread: consumes items until it receives None."""
    while True:
        item = queue.get()
        if item is None:
            queue.task_done()
            break
        time.sleep(random.uniform(CONSUME_DELAY_MIN, CONSUME_DELAY_MAX))
        print(f"    [C{cid}] consumed {item}")
        queue.task_done()


# ═══════════════════════════════════════════════════════════════════════════════
# ORCHESTRATION
# ═══════════════════════════════════════════════════════════════════════════════

def create_threads(args: argparse.Namespace, queue: Queue, counter: ThreadSafeCounter) -> tuple:
    """Create producer and consumer threads."""
    producers = [
        threading.Thread(target=producer_worker, args=(i, queue, counter), daemon=True)
        for i in range(1, args.producers + 1)
    ]
    consumers = [
        threading.Thread(target=consumer_worker, args=(i, queue), daemon=True)
        for i in range(1, args.consumers + 1)
    ]
    return producers, consumers


def start_all_threads(producers: list, consumers: list) -> None:
    """Start all threads."""
    for t in consumers + producers:
        t.start()


def wait_for_completion(producers: list, consumers: list, queue: Queue) -> None:
    """Wait for completion and send poison pills."""
    for t in producers:
        t.join()

    for _ in consumers:
        queue.put(None)

    queue.join()
    for t in consumers:
        t.join()


# ═══════════════════════════════════════════════════════════════════════════════
# MAIN
# ═══════════════════════════════════════════════════════════════════════════════

def main() -> int:
    """Main entry point."""
    args = parse_args()
    queue: Queue[Optional[int]] = Queue(maxsize=args.buf)
    counter = ThreadSafeCounter(args.items)

    producers, consumers = create_threads(args, queue, counter)
    start_all_threads(producers, consumers)
    wait_for_completion(producers, consumers, queue)

    print("OK: done.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
