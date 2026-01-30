#!/usr/bin/env python3
"""
Demo (Week 8): Banker's Algorithm (deadlock avoidance).

Concepts:
- Allocation / Max / Need matrices;
- Available vector;
- *safe state* and safe sequence.

Run:
  ./banker_demo.py
  ./banker_demo.py --example classic

Note:
- This is a didactic example; in real systems, the Banker model is rarely applied directly
  (costs, need for maximum knowledge), but it is extremely useful for reasoning.
"""

from __future__ import annotations

import argparse
from dataclasses import dataclass
from typing import Optional


# ═══════════════════════════════════════════════════════════════════════════════
# DATA STRUCTURES
# ═══════════════════════════════════════════════════════════════════════════════

@dataclass
class BankerState:
    """System state for the Banker's Algorithm."""
    available: list[int]          # m resources
    max_demand: list[list[int]]   # n processes x m
    allocation: list[list[int]]   # n processes x m

    @property
    def n(self) -> int:
        """Number of processes."""
        return len(self.allocation)

    @property
    def m(self) -> int:
        """Number of resource types."""
        return len(self.available)

    def need(self) -> list[list[int]]:
        """Calculate Need matrix = Max - Allocation."""
        return [
            [self.max_demand[i][j] - self.allocation[i][j] for j in range(self.m)]
            for i in range(self.n)
        ]


# ═══════════════════════════════════════════════════════════════════════════════
# ALGORITHM
# ═══════════════════════════════════════════════════════════════════════════════

def can_finish(need_row: list[int], work: list[int]) -> bool:
    """Check if a process can finish with available resources."""
    return all(need_row[j] <= work[j] for j in range(len(work)))


def safe_sequence(state: BankerState) -> Optional[list[int]]:
    """Find a safe sequence or return None if state is unsafe."""
    work = state.available[:]
    finish = [False] * state.n
    need = state.need()
    seq: list[int] = []

    while len(seq) < state.n:
        progressed = False
        for i in range(state.n):
            if finish[i]:
                continue
            if can_finish(need[i], work):
                for j in range(state.m):
                    work[j] += state.allocation[i][j]
                finish[i] = True
                seq.append(i)
                progressed = True
        if not progressed:
            return None
    return seq


# ═══════════════════════════════════════════════════════════════════════════════
# EXAMPLES
# ═══════════════════════════════════════════════════════════════════════════════

def classic_example() -> BankerState:
    """Classic example from OS literature (Silberschatz)."""
    available = [3, 3, 2]
    allocation = [
        [0, 1, 0],  # P0
        [2, 0, 0],  # P1
        [3, 0, 2],  # P2
        [2, 1, 1],  # P3
        [0, 0, 2],  # P4
    ]
    max_demand = [
        [7, 5, 3],
        [3, 2, 2],
        [9, 0, 2],
        [2, 2, 2],
        [4, 3, 3],
    ]
    return BankerState(available, max_demand, allocation)


# ═══════════════════════════════════════════════════════════════════════════════
# CONFIGURATION
# ═══════════════════════════════════════════════════════════════════════════════

def parse_args() -> argparse.Namespace:
    """Parse command line arguments."""
    p = argparse.ArgumentParser(description="Banker's Algorithm Demo")
    p.add_argument("--example", choices=["classic"], default="classic")
    return p.parse_args()


# ═══════════════════════════════════════════════════════════════════════════════
# DISPLAY
# ═══════════════════════════════════════════════════════════════════════════════

def print_matrix(title: str, matrix: list[list[int]]) -> None:
    """Display a matrix with processes."""
    print(f"{title}:")
    for i, row in enumerate(matrix):
        print(f"  P{i}: {row}")


def print_state(state: BankerState) -> None:
    """Display current system state."""
    print("=== Banker's Algorithm ===")
    print(f"Available:  {state.available}")
    print_matrix("Allocation", state.allocation)
    print_matrix("Max", state.max_demand)
    print_matrix("Need (= Max - Allocation)", state.need())


def print_result(seq: Optional[list[int]]) -> int:
    """Display result and return exit code."""
    print()
    if seq is None:
        print("UNSAFE state: no safe sequence exists (in this model).")
        return 1

    print("SAFE state: safe sequence exists.")
    print("Safe sequence:", " -> ".join(f"P{i}" for i in seq))
    return 0


# ═══════════════════════════════════════════════════════════════════════════════
# MAIN
# ═══════════════════════════════════════════════════════════════════════════════

def main() -> int:
    """Main entry point."""
    parse_args()  # For future extensibility
    state = classic_example()
    print_state(state)
    seq = safe_sequence(state)
    return print_result(seq)


if __name__ == "__main__":
    raise SystemExit(main())
