#!/usr/bin/env python3
"""
Simplified simulation of "Batch Processing" (introductory level).

Context (brief history):
- In the early decades of commercial computers, direct interaction with the system was limited.
- "Batch" meant running a set of jobs without human intervention between them (punch cards,
  printouts, long waiting times).
- The model is didactically useful for understanding: job queue, waiting times,
  throughput and the notion of scheduling.

The script:
- accepts a list of jobs (durations) and simulates sequential execution (FCFS).
- reports times: start, finish, turnaround, waiting.

It is not a complete model (does not include I/O burst etc.), but it is sufficient for the initial discussion.
"""

from __future__ import annotations

import argparse
from dataclasses import dataclass
from statistics import mean

@dataclass(frozen=True)
class Job:
    name: str
    duration_s: float

@dataclass(frozen=True)
class JobResult:
    name: str
    start_s: float
    finish_s: float
    turnaround_s: float
    waiting_s: float

def parse_args() -> argparse.Namespace:
    p = argparse.ArgumentParser(description="Batch Processing Simulation (FCFS).")
    p.add_argument(
        "durations",
        nargs="*",
        type=float,
        default=[2.0, 1.0, 3.5, 0.5],
        help="Job durations (seconds). Example: 2 1 3.5 0.5",
    )
    return p.parse_args()

def simulate_fcfs(jobs: list[Job]) -> list[JobResult]:
    t = 0.0
    out: list[JobResult] = []
    for j in jobs:
        start = t
        finish = t + j.duration_s
        turnaround = finish  # arrival at t=0 (simplification)
        waiting = start
        out.append(JobResult(j.name, start, finish, turnaround, waiting))
        t = finish
    return out

def main() -> int:
    args = parse_args()
    jobs = [Job(f"J{i+1}", d) for i, d in enumerate(args.durations)]
    results = simulate_fcfs(jobs)

    print("=== Batch (FCFS) ===")
    print(f"{'Job':<6} {'Start(s)':>9} {'Finish(s)':>10} {'Waiting(s)':>11} {'Turnaround(s)':>14}")
    for r in results:
        print(f"{r.name:<6} {r.start_s:>9.2f} {r.finish_s:>10.2f} {r.waiting_s:>11.2f} {r.turnaround_s:>14.2f}")

    avg_wait = mean(r.waiting_s for r in results)
    avg_tat = mean(r.turnaround_s for r in results)
    print()
    print(f"Average waiting time:    {avg_wait:.2f} s")
    print(f"Average turnaround time: {avg_tat:.2f} s")

    return 0

if __name__ == "__main__":
    raise SystemExit(main())
