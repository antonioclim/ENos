# Operating Systems - Week 4: Process Scheduling

> by Revolvix | ASE Bucharest - CSIE | Year I, Semester 2 | 2025-2026

---

## Week Objectives

After completing this week's materials, you will be able to:

1. Enumerate the performance criteria for scheduling algorithms
2. Compare algorithms: FCFS, SJF, SRTF, RR, Priority and MLFQ
3. Calculate waiting times and turnaround for various scenarios
4. Explain the operation of the CFS scheduler used in modern Linux
5. Analyse the trade-offs between algorithms for different scenarios

---

## Applied Context (didactic scenario): Why does your game lag when Windows Update runs in the background?

You're in a ranked match in CS2, 1v1, decisive round... and suddenly your FPS drops from 144 to 30. Task Manager shows: Windows Update downloading in the background. But you have an 8-core processor! Why does the game "feel" the update?

The answer lies in the process scheduler. Even if you have many cores, there are shared resources: L3 cache, memory bandwidth and disc access. The scheduling algorithm decides how to divide CPU time between the game and the update. If the update has too high a priority or performs many I/O operations, your game suffers.

> 💡 Think about it: If you were the architect of Windows, how would you prioritise processes for gaming?

---

## Lecture Content (4/14)

### 1. Scheduling Criteria

#### Formal Definition

> Process scheduling (CPU Scheduling) is the operating system function that decides which process from the ready queue will be executed on the CPU and for how long. The objective is to optimise one or more performance criteria. (Silberschatz et al., 2018)

#### Performance Metrics

| Criterion | Formal Definition | Formula | Objective |
|-----------|-------------------|---------|-----------|
| CPU Utilisation | Fraction of time during which CPU executes processes | `U = (T_busy / T_total) × 100%` | Maximise (ideal: 100%) |
| Throughput | Number of processes completed per unit of time | `X = N_completed / T` | Maximise |
| Turnaround Time | Total time from submission to completion | `T_turnaround = T_completion - T_arrival` | Minimise |
| Waiting Time | Time spent in the Ready queue | `T_wait = T_turnaround - T_burst` | Minimise |
| Response Time | Time until first response | `T_response = T_first_run - T_arrival` | Minimise (interactive systems) |

#### Fundamental Trade-offs

```
       ┌─────────────────────────────────────────────────────────┐
       │                   THROUGHPUT                             │
       │                      ▲                                   │
       │                      │                                   │
       │    Batch Systems     │                                   │
       │    (servers, compute)│                                   │
       │                      │                                   │
       │         ◄────────────┼────────────►                      │
       │                      │                                   │
       │                      │    Interactive Systems            │

> 💡 Over the years, I have found that practical examples beat theory every time.

       │                      │    (desktop, gaming)              │
       │                      ▼                                   │
       │               RESPONSE TIME                              │
       └─────────────────────────────────────────────────────────┘
```

---

### 2. FCFS (First-Come, First-Served)

#### Formal Definition

> First-Come, First-Served (FCFS), also known as FIFO (First-In, First-Out), is the scheduling algorithm that serves processes in the exact order of their arrival in the ready queue. It is a **non-preemptive** algorithm - once a process begins execution, it runs until completion or blocking.

Formally:
```
For processes P = {p₁, p₂, ..., pₙ} with arrival times A = {a₁, a₂, ..., aₙ}:
Execution order: sort(P) by A ascending
```

#### Intuitive Explanation

Metaphor: The supermarket queue without express checkouts

- You have 5 customers in the queue
- First come = first served
- Even if you only have a chocolate bar, you wait behind the person with a full trolley
- Fair? Yes! Efficient? Not necessarily...

Classic example:
```
Imagine at McDonald's:

Three things matter here: customer A: orders full meal (10 minutes), customer B: just water (30 seconds) and customer C: dessert (1 minute).


With FCFS: B and C wait 10 minutes because A arrived first!
```

#### Historical Context

| Year | Context |
|------|---------|
| 1950s | First algorithm used (batch processing) |
| ~1956 | GM-NAA I/O used FCFS for jobs |
| 1960s | Replaced by more sophisticated algorithms for time-sharing |
| Today | Still used: printers, message queues, I/O requests |

#### Calculation Example

```
Processes: P1(burst=24), P2(burst=3), P3(burst=3)
All arrive at t=0

Arrival order: P1, P2, P3

Gantt Chart:
┌──────────────────────────┬─────┬─────┐
│            P1            │ P2  │ P3  │
└──────────────────────────┴─────┴─────┘
0                         24   27    30

Calculations:
P1: Wait=0,  Turnaround=24
P2: Wait=24, Turnaround=27
P3: Wait=27, Turnaround=30

Average Waiting Time = (0+24+27)/3 = 17.0
Average Turnaround = (24+27+30)/3 = 27.0
```

#### Costs and Trade-offs

| Advantage | Disadvantage |
|-----------|--------------|
| Very simple to implement | Convoy Effect - short processes wait behind long ones |
| Fair (in order terms) | Average waiting time can be very large |
| Zero scheduling overhead | Poor response time for interactive systems |
| Predictable | Does not consider process characteristics |

Convoy Effect illustrated:
```
Worst case:
- P1 (burst=1000) arrives at t=0
- P2, P3, ..., P100 (burst=1 each) arrive at t=1

All 99 short processes wait ~1000 units!
```

#### Comparative Implementation

| Aspect | Linux | Windows | macOS |
|--------|-------|---------|-------|
| Used for | I/O scheduling (Deadline, NOOP) | Print queue, COM ports | I/O queues |
| Level | Kernel (I/O scheduler) | Kernel (Spooler) | Kernel |
| Implementation | Simple linked list | Queue object | Queue |

#### Python Implementation

```python
#!/usr/bin/env python3
"""
FCFS (First-Come, First-Served) Scheduler

Demonstrates:

- Basic FCFS algorithm
- Metrics calculation (waiting time, turnaround time)
- Convoy effect

"""

from dataclasses import dataclass
from typing import List

@dataclass
class Process:
    """Process representation for scheduling."""
    pid: str
    arrival_time: int
    burst_time: int
    
    # Calculated fields
    start_time: int = 0
    completion_time: int = 0
    waiting_time: int = 0
    turnaround_time: int = 0

def fcfs_schedule(processes: List[Process]) -> List[Process]:
    """
    FCFS Algorithm.
    
    Complexity: O(n log n) for sorting, O(n) for scheduling
    Space: O(1) extra
    """
    # Sort by arrival time
    sorted_procs = sorted(processes, key=lambda p: p.arrival_time)
    
    current_time = 0
    
    for proc in sorted_procs:
        # If CPU is idle, advance to arrival
        if current_time < proc.arrival_time:
            current_time = proc.arrival_time
        
        proc.start_time = current_time
        proc.completion_time = current_time + proc.burst_time

> 💡 In previous labs, we have seen that the most common mistake is forgetting quotes around variables with spaces.

        proc.turnaround_time = proc.completion_time - proc.arrival_time
        proc.waiting_time = proc.turnaround_time - proc.burst_time
        
        current_time = proc.completion_time
    
    return sorted_procs

def print_gantt_chart(processes: List[Process]):
    """Displays ASCII Gantt Chart."""
    print("\nGantt Chart:")
    print("┌" + "─" * 50 + "┐")
    
    timeline = ""
    labels = ""
    current = 0
    
    for proc in processes:
        width = max(3, proc.burst_time // 2)
        timeline += f"│{proc.pid:^{width}}"
        labels += f"{current:<{width+1}}"
        current = proc.completion_time
    
    timeline += "│"
    labels += str(current)
    
    print(timeline)
    print("└" + "─" * 50 + "┘")
    print(labels)

def print_metrics(processes: List[Process]):
    """Displays performance metrics."""
    print("\n" + "="*60)
    print(f"{'PID':<6} {'Arrival':<8} {'Burst':<7} {'Start':<7} "
          f"{'Complete':<10} {'Wait':<6} {'Turnaround':<10}")
    print("="*60)
    
    for p in processes:
        print(f"{p.pid:<6} {p.arrival_time:<8} {p.burst_time:<7} "
              f"{p.start_time:<7} {p.completion_time:<10} "
              f"{p.waiting_time:<6} {p.turnaround_time:<10}")
    
    avg_wait = sum(p.waiting_time for p in processes) / len(processes)
    avg_turn = sum(p.turnaround_time for p in processes) / len(processes)
    
    print("="*60)
    print(f"Average Waiting Time: {avg_wait:.2f}")
    print(f"Average Turnaround Time: {avg_turn:.2f}")

def demonstrate_convoy_effect():
    """Demonstrates convoy effect."""
    print("\n" + "="*60)
    print("CONVOY EFFECT DEMONSTRATION")
    print("="*60)
    
    # Scenario 1: Long process first
    print("\n--- Scenario 1: LONG process first ---")
    procs1 = [
        Process("P1", 0, 24),  # Long
        Process("P2", 0, 3),   # Short
        Process("P3", 0, 3),   # Short
    ]
    result1 = fcfs_schedule(procs1)
    print_metrics(result1)
    
    # Scenario 2: Short processes first
    print("\n--- Scenario 2: SHORT processes first ---")
    procs2 = [
        Process("P2", 0, 3),   # Short
        Process("P3", 0, 3),   # Short
        Process("P1", 0, 24),  # Long
    ]
    # Simulate P2 arriving first
    procs2[0].arrival_time = 0
    procs2[1].arrival_time = 0.001
    procs2[2].arrival_time = 0.002
    result2 = fcfs_schedule(procs2)
    print_metrics(result2)
    
    print("\n📊 Observation: Same processes, different order → "
          "dramatically different waiting time!")

if __name__ == "__main__":
    # Basic example
    processes = [
        Process("P1", 0, 24),
        Process("P2", 0, 3),
        Process("P3", 0, 3),
    ]
    
    result = fcfs_schedule(processes)
    print_gantt_chart(result)
    print_metrics(result)
    
    demonstrate_convoy_effect()
```

Output:
```
Gantt Chart:
┌──────────────────────────────────────────────────┐
│     P1      │ P2 │ P3 │
└──────────────────────────────────────────────────┘
0             24   27   30

============================================================
PID    Arrival  Burst   Start   Complete   Wait   Turnaround
============================================================
P1     0        24      0       24         0      24        
P2     0        3       24      27         24     27        
P3     0        3       27      30         27     30        
============================================================
Average Waiting Time: 17.00
Average Turnaround Time: 27.00
```

#### Modern Trends

| Context | FCFS Usage |
|---------|------------|
| Print Queue | Documents are printed in order |
| Message Queues | RabbitMQ, SQS - optional FIFO |
| Batch Jobs | Kubernetes Jobs (without priority) |
| I/O Scheduling | NOOP scheduler (for SSDs) |

---

### 3. SJF (Shortest Job First)

#### Formal Definition

> Shortest Job First (SJF), also known as Shortest Job Next (SJN), is the algorithm that selects the process with the shortest CPU burst for execution. It can be **non-preemptive** (once started, runs to completion) or **preemptive** (SRTF - Shortest Remaining Time First).

Formally:
```
For processes in ready queue R = {p₁, p₂, ..., pₙ}:
next_process = argmin(pᵢ ∈ R) { burst_time(pᵢ) }
```

Theorem: SJF is optimal for minimising average waiting time (mathematically proven).

#### Intuitive Explanation

Metaphor: The checkout for "10 items or fewer"

The supermarket discovered that if:
- The customer with 2 items goes to the express checkout
- The customer with a trolley goes to the normal checkout

→ Everyone is happier! The average waiting time decreases.

Or: Triage in A&E (inverse)
- "Easy" cases (short burst) are resolved quickly
- Frees up resources for complex cases

#### Historical Context

| Year | Event |
|------|-------|
| 1966 | Theoretical analysis by Conway, Maxwell, Miller |
| 1968 | Optimality demonstration for waiting time |
| 1970s | Practical problems: how do you estimate burst? |
| Today | Adaptive variants, machine learning for prediction |

#### Calculation Example

```
Processes: P1(burst=6), P2(burst=8), P3(burst=7), P4(burst=3)
All arrive at t=0

SJF Non-preemptive:
Order: P4(3) < P1(6) < P3(7) < P2(8)

Gantt Chart:
┌─────┬────────────┬────────────────┬──────────────────┐
│ P4  │     P1     │      P3        │        P2        │
└─────┴────────────┴────────────────┴──────────────────┘
0     3            9               16                  24

P4: Wait=0,  Turnaround=3
P1: Wait=3,  Turnaround=9
P3: Wait=9,  Turnaround=16
P2: Wait=16, Turnaround=24

Average Waiting Time = (0+3+9+16)/4 = 7.0  ← Better than FCFS!
Average Turnaround = (3+9+16+24)/4 = 13.0
```

#### Preemptive SJF (SRTF - Shortest Remaining Time First)

```
Processes:
P1(arrival=0, burst=8)
P2(arrival=1, burst=4)
P3(arrival=2, burst=9)
P4(arrival=3, burst=5)

Timeline:
t=0: P1 starts (remaining=8)
t=1: P2 arrives (remaining=4 < P1's 7) → P1 preempted, P2 runs
t=2: P3 arrives (remaining=9 > P2's 3) → P2 continues
t=3: P4 arrives (remaining=5 > P2's 2) → P2 continues
t=5: P2 completes → P4 runs (remaining=5 < P1's 7 < P3's 9)
t=10: P4 completes → P1 runs (remaining=7 < P3's 9)
t=17: P1 completes → P3 runs
t=26: P3 completes

Gantt Chart:
┌────┬──────┬────────────┬────────────────┬──────────────────┐
│ P1 │  P2  │     P4     │       P1       │        P3        │
└────┴──────┴────────────┴────────────────┴──────────────────┘
0    1      5           10              17                  26
```

#### The Problem: How do we know the future burst?

WE DON'T! SJF is theoretically optimal but directly impractical.

Solution: Estimation using history:
```
τₙ₊₁ = α × tₙ + (1-α) × τₙ

where:
- τₙ₊₁ = estimated future burst
- tₙ = actual previous burst
- τₙ = previous estimate
- α = weighting factor (0 < α ≤ 1), typically 0.5
```

Exponential averaging - recent estimates count more.

#### Costs and Trade-offs

| Advantage | Disadvantage |
|-----------|--------------|
| Optimal for avg waiting time | Must know/estimate burst |
| Good throughput | Starvation - long processes may wait indefinitely |
| Good response time for short processes | Estimation overhead |

Starvation illustrated:
```
Process P_long (burst=1000) arrives in queue.
Short processes P1, P2, P3... continuously arrive.
P_long NEVER runs if shorter ones keep coming!
```

#### Comparative Implementation

| Aspect | Linux | Windows | macOS |
|--------|-------|---------|-------|
| Pure SJF | No (would cause starvation) | No | No |
| Variants | CFS estimates "virtual runtime" | DFSS uses adaptive quantum | Similar to CFS |
| I/O Scheduling | Deadline scheduler (similar) | - | - |

#### Python Implementation

```python
#!/usr/bin/env python3
"""
SJF (Shortest Job First) Scheduler - Non-preemptive and Preemptive (SRTF)
"""

from dataclasses import dataclass, field
from typing import List, Optional
import heapq

@dataclass(order=True)
class Process:
    """Process for SJF."""
    burst_time: int = field(compare=True)  # For heap ordering
    pid: str = field(compare=False)
    arrival_time: int = field(compare=False)
    remaining_time: int = field(compare=False, default=0)
    
    start_time: int = field(compare=False, default=-1)
    completion_time: int = field(compare=False, default=0)
    waiting_time: int = field(compare=False, default=0)
    turnaround_time: int = field(compare=False, default=0)
    
    def __post_init__(self):
        self.remaining_time = self.burst_time

def sjf_non_preemptive(processes: List[Process]) -> List[Process]:
    """
    Non-preemptive SJF.
    
    Complexity: O(n²) or O(n log n) with heap
    """
    procs = [Process(p.burst_time, p.pid, p.arrival_time) for p in processes]
    ready_queue: List[Process] = []
    completed: List[Process] = []
    
    current_time = 0
    procs.sort(key=lambda p: p.arrival_time)
    proc_index = 0
    
    while len(completed) < len(procs):
        # Add processes that have arrived
        while proc_index < len(procs) and procs[proc_index].arrival_time <= current_time:
            heapq.heappush(ready_queue, procs[proc_index])
            proc_index += 1
        
        if ready_queue:
            # Select process with minimum burst
            proc = heapq.heappop(ready_queue)
            
            proc.start_time = current_time
            proc.completion_time = current_time + proc.burst_time
            proc.turnaround_time = proc.completion_time - proc.arrival_time
            proc.waiting_time = proc.turnaround_time - proc.burst_time
            
            current_time = proc.completion_time
            completed.append(proc)
        else:
            # CPU idle - advance to next arrival
            current_time = procs[proc_index].arrival_time
    
    return completed

def srtf_preemptive(processes: List[Process]) -> List[Process]:
    """
    Shortest Remaining Time First (Preemptive SJF).
    
    At each time unit (or at each arrival),
    checks whether the current process should be preempted.
    """
    procs = {p.pid: Process(p.burst_time, p.pid, p.arrival_time) 
             for p in processes}
    
    ready_queue: List[Process] = []
    current: Optional[Process] = None
    current_time = 0
    
    # All events (arrivals)
    events = sorted(set(p.arrival_time for p in procs.values()))
    next_event_idx = 0
    
    completed_count = 0
    timeline = []  # For Gantt chart
    
    while completed_count < len(procs):
        # Add processes that have arrived
        while next_event_idx < len(events) and events[next_event_idx] <= current_time:
            for p in procs.values():
                if p.arrival_time == events[next_event_idx] and p.remaining_time > 0:
                    heapq.heappush(ready_queue, 
                        Process(p.remaining_time, p.pid, p.arrival_time, p.remaining_time))
            next_event_idx += 1
        
        if ready_queue:
            proc_entry = heapq.heappop(ready_queue)
            proc = procs[proc_entry.pid]
            
            if proc.start_time == -1:
                proc.start_time = current_time
            
            # Run until next event or completion
            next_event = events[next_event_idx] if next_event_idx < len(events) else float('inf')
            run_time = min(proc.remaining_time, next_event - current_time)
            
            timeline.append((proc.pid, current_time, current_time + run_time))
            current_time += run_time
            proc.remaining_time -= run_time
            
            if proc.remaining_time == 0:
                proc.completion_time = current_time
                proc.turnaround_time = proc.completion_time - proc.arrival_time
                proc.waiting_time = proc.turnaround_time - proc.burst_time
                completed_count += 1
            else:
                # Put back in queue for later
                heapq.heappush(ready_queue,
                    Process(proc.remaining_time, proc.pid, proc.arrival_time, proc.remaining_time))
        else:
            # CPU idle
            if next_event_idx < len(events):
                current_time = events[next_event_idx]
    
    return list(procs.values())

# Demo
if __name__ == "__main__":
    processes = [
        Process(6, "P1", 0),
        Process(8, "P2", 0),
        Process(7, "P3", 0),
        Process(3, "P4", 0),
    ]
    
    print("=== Non-Preemptive SJF ===")
    result = sjf_non_preemptive(processes)
    for p in sorted(result, key=lambda x: x.start_time):
        print(f"{p.pid}: Start={p.start_time}, Complete={p.completion_time}, "
              f"Wait={p.waiting_time}")
    
    avg_wait = sum(p.waiting_time for p in result) / len(result)
    print(f"Average Waiting Time: {avg_wait:.2f}")
```

---

### 4. Round Robin (RR)

#### Formal Definition

> Round Robin is a **preemptive** scheduling algorithm that allocates a fixed time quantum to each process. Processes are served cyclically - each receives a quantum, then moves to the end of the queue.

Formally:
```
quantum = q (typically 10-100 ms)
while processes exist:
    for each process p in ready_queue:
        run(p, min(q, remaining_time(p)))
        if not completed(p):
            enqueue(p, ready_queue)
```

#### Intuitive Explanation

Metaphor: The game "Who has the ball"

- 5 children stand in a circle
- Each holds the ball for 10 seconds
- Then passes it to the next person
- Cyclically, everyone plays "simultaneously"
- Nobody monopolises the ball

Or: Time-sharing on computers in the '70s
- 10 users on a mainframe
- Each gets 100ms of CPU
- Switches quickly → everyone has the impression they're running simultaneously

#### Historical Context

| Year | Event |
|------|-------|
| 1961 | CTSS (Compatible Time-Sharing System) - MIT |
| 1964 | Multics uses time slicing |
| 1969 | UNIX - first with configurable quantum |
| Today | Basis for CFS and other modern schedulers |

#### Calculation Example

```
Processes: P1(burst=24), P2(burst=3), P3(burst=3)
Quantum = 4

Timeline:
t=0-4:   P1 runs (remaining=20)
t=4-7:   P2 runs (remaining=0) ✓ DONE
t=7-10:  P3 runs (remaining=0) ✓ DONE
t=10-14: P1 runs (remaining=16)
t=14-18: P1 runs (remaining=12)
t=18-22: P1 runs (remaining=8)
t=22-26: P1 runs (remaining=4)
t=26-30: P1 runs (remaining=0) ✓ DONE

Gantt Chart:
┌────┬────┬────┬────┬────┬────┬────┬────┐
│ P1 │ P2 │ P3 │ P1 │ P1 │ P1 │ P1 │ P1 │
└────┴────┴────┴────┴────┴────┴────┴────┘
0    4    7   10   14   18   22   26   30

P1: Wait=6 (30-24), Turnaround=30
P2: Wait=4,        Turnaround=7
P3: Wait=7,        Turnaround=10

Average Waiting Time = (6+4+7)/3 = 5.67
```

#### Quantum Trade-off

| Quantum | Behaviour |
|---------|-----------|
| Too large (q → ∞) | Becomes FCFS |
| Too small (q → 0) | Too many context switches → overhead |
| Optimal | ~80% of bursts < quantum |

```
Context switch overhead: ~10-100 μs
Quantum = 10 ms → overhead = 0.1-1%
Quantum = 100 μs → overhead = 10-50% ← Problematic!
```

#### Costs and Trade-offs

| Advantage | Disadvantage |
|-----------|--------------|
| Fair - everyone gets equal time | Average waiting time can be large |
| Good response time | Context switch overhead |
| No starvation | Not optimal for throughput |
| Simple to implement | Fixed quantum not ideal for all workloads |

---

### 5. Priority Scheduling

#### Formal Definition

> Priority Scheduling is the algorithm that associates a **priority** (a number) with each process and selects the process with the highest priority for execution. It can be **preemptive** or **non-preemptive**.

Common convention:
- SMALL number = HIGH priority (Linux, UNIX)
- Or the reverse in other systems

#### The Problem: Starvation

```
P_low_priority (priority=10) arrives in queue.
P_high (priority=1) processes continuously arrive.
P_low_priority NEVER runs!
```

Solution: Aging
```
// At each time unit in queue:
if (process.waiting_time > threshold) {
    process.priority--;  // Increases priority
}
```

---

### 6. MLFQ (Multi-Level Feedback Queue)

#### Formal Definition

> Multi-Level Feedback Queue is an algorithm that uses multiple queues with different priorities, allowing processes to migrate between queues based on their behaviour. It combines the advantages of multiple algorithms.

#### Intuitive Explanation

Metaphor: The hotel with multiple floors

- Floor 10 (VIP): Quick check-in, instant service
- Floor 5 (Standard): Normal service
- Floor 1 (Budget): You wait longer
- Save a backup copy if you modify important files

Rules:
- All new guests arrive at VIP
- If you cause trouble (use too much) → you move down a floor
- If you stay long and behave well → you move back up
- Always check the result before continuing

In OS:
- I/O-bound processes (interactive): Stay high (fast response)
- CPU-bound processes (batch): Move down (throughput)

#### MLFQ Rules

```
┌─────────────────────────────────────────────────────────────┐
│  Queue 0 (highest priority): RR, quantum=8ms                │
│      ↓ (if uses entire quantum without blocking)            │
│  Queue 1: RR, quantum=16ms                                  │
│      ↓                                                      │
│  Queue 2: RR, quantum=32ms                                  │
│      ↓                                                      │
│  Queue 3 (lowest priority): FCFS                            │
└─────────────────────────────────────────────────────────────┘

Rules:
1. New process → Queue 0
2. Uses entire quantum → moves down a queue
3. Yields CPU (I/O) → stays in same queue
4. Periodic (S ms): BOOST all processes to Queue 0
```

Boost prevents starvation for CPU-bound processes.

#### Implementation: Linux CFS

Modern Linux uses CFS (Completely Fair Scheduler), inspired by MLFQ:

```bash
# "nice" priority (-20 to +19)
nice -n 10 ./script.sh      # Run with lower priority
renice -n -5 -p PID         # Modify priority

# Scheduler information
cat /proc/PID/sched | head -20

# Scheduling classes
chrt -p PID                 # Display policy
# SCHED_OTHER - CFS (default)
# SCHED_FIFO - Real-time FIFO
# SCHED_RR - Real-time RR
```

---

### 7. Brainstorm: Scheduler for Web Server

Situation: You are the OS architect for a web server that serves 3 types of requests:

Specifically: API calls (short burst ~5ms, many/second). Page renders (medium burst ~50ms). And Report generation (long burst ~5s, rare).


Questions:
1. Which algorithm would you use?
2. How would you prioritise?
3. What happens during a traffic spike?

Practical solution: 
- Worker threads for I/O-bound (API, renders)
- Separate background queue for CPU-bound (reports)
- Rate limiting + circuit breaker
- MLFQ-like with explicit separation

---

## Laboratory/Seminar (Session 2/7)

### TC Materials
- TC2a-TC2d: Variables, Control Operators
- TC3a-TC3b: Filters, Loops
- TC4a: I/O Redirection
- Save a backup copy if you modify important files

### Assignment 2: `assignment2_processing.sh`

Script that processes .txt files:
- `-d DIR` - directory to scan
- `-n NUM` - preview lines
- `-v` - verbose
- `-h` - help

---

## Recommended Reading

### OSTEP
- [Ch 7 - Scheduling: Introduction](https://pages.cs.wisc.edu/~remzi/OSTEP/cpu-sched.pdf)
- [Ch 8 - MLFQ](https://pages.cs.wisc.edu/~remzi/OSTEP/cpu-sched-mlfq.pdf)

---

## Algorithm Summary

| Algorithm | Type | Optimal for | Problem |
|-----------|------|-------------|---------|
| FCFS | Non-preemptive | Simplicity | Convoy effect |
| SJF | Non-preemptive | Avg wait time | Starvation, prediction |
| SRTF | Preemptive | Avg wait time | Starvation, overhead |
| RR | Preemptive | Fairness, response | Quantum tuning |
| Priority | Both | Explicit control | Starvation |
| MLFQ | Preemptive | Adaptive | Complexity |


---

## Self-Assessment

### Verification Questions

1. **[REMEMBER]** List the 4 scheduling algorithms studied and the main characteristic of each.
2. **[UNDERSTAND]** Explain the concept of "quantum" in Round Robin. What happens if the quantum is too small? And too large?
3. **[ANALYSE]** Compare FCFS with SJF from the perspective of average waiting time. In what situations can SJF be problematic (starvation)?

### Mini-Challenge (optional)

Using the `nice` command, run two CPU-intensive processes with different priorities and observe the difference in CPU allocation.

---


---


---

## Nuances and Special Cases

### What we did NOT cover (didactic limitations)

- **CFS (Completely Fair Scheduler)**: The real Linux scheduler, based on red-black trees and virtual runtime.
- **Real-time scheduling**: SCHED_FIFO, SCHED_RR with RT priorities (1-99).
- **CPU affinity**: Pinning processes to specific cores for cache locality.
- **NUMA scheduling**: Placing processes close to their memory on multi-socket systems.

### Common Mistakes to Avoid

1. **nice vs priority confusion**: `nice` influences priority, but the relationship is not linear in CFS.
2. **Ignoring I/O wait**: A "CPU-bound" process can become "I/O-bound" under different load.
3. **Over-engineering quantum**: Default values (1-10ms) are good for most cases.

### Open Questions

- How should the OS schedule AI workloads (long, predictable) vs interactive?
- Can ML improve scheduler decisions in real time?

## Looking Ahead

**Week 5: Threads** — From heavyweight processes we move to lightweight threads. Threads share the address space, which brings both advantages (fast communication) and challenges (synchronisation).

**Recommended preparation:**
- Read OSTEP Chapter 26 (Concurrency and Threads)
- Experiment with `top -H` to see threads

## Visual Summary

```
┌─────────────────────────────────────────────────────────────────┐
│                    WEEK 4: SCHEDULING — RECAP                   │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  SCHEDULER OBJECTIVE: Decides WHO runs and for HOW LONG        │
│                                                                 │
│  NON-PREEMPTIVE ALGORITHMS                                      │
│  ├── FCFS: first come, first served (simple, convoy)           │
│  └── SJF: shortest job first (optimal, starvation)             │
│                                                                 │
│  PREEMPTIVE ALGORITHMS                                          │
│  ├── Round Robin: fixed quantum, fairness (overhead)           │
│  ├── SRTF: SJF + preemption                                    │
│  └── MLFQ: multiple queues, dynamic priority                   │
│                                                                 │
│  METRICS                                                        │
│  ├── Turnaround = Finish - Arrival                             │
│  ├── Waiting = Turnaround - Burst                              │
│  └── Response = FirstRun - Arrival                             │
│                                                                 │
│  LINUX: CFS (Completely Fair Scheduler)                        │
│  └── vruntime + red-black tree + nice values                   │
│                                                                 │
│  💡 TAKEAWAY: There is no perfect algorithm — everything is    │
│     a compromise                                                │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

*Materials developed by Revolvix for ASE Bucharest - CSIE*  
*Operating Systems | Year I, Semester 2 | 2025-2026*

## Scripting in Context (Bash + Python): The Effect of `nice` on Scheduling

### Included Files

- Python: `scripts/cpu_hog.py` — Controlled CPU-bound workload.
- Bash: `scripts/nice_demo.sh` — Runs two identical workloads with different `nice` values and compares.

### Quick Run

```bash
./scripts/nice_demo.sh --seconds 5
```

### Connection to This Week's Concepts

- `nice` is a user-space tool that influences scheduler decisions (especially when there is CPU competition).
- The CPU-bound workload isolates the scheduling effect from I/O.

### Recommended Practice

- run scripts first on a test directory (not on critical data);
- save the output to a file and attach it to the report/assignment, if required;
- note the kernel version (`uname -r`) and Python version (`python3 --version`) when comparing results.

*Materials developed by Revolvix for ASE Bucharest - CSIE*  
*Operating Systems | Year I, Semester 2 | 2025-2026*
