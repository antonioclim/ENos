<!-- RO: TRADUS ȘI VERIFICAT -->
# Study Guide — Scheduling

## Key Algorithms

### FCFS (First Come First Served)
- Non-preemptive, simple
- Convoy effect: long job blocks short ones

### SJF (Shortest Job First)
- Optimal for average waiting time
- Requires burst time prediction

### Round Robin
- Fixed time quantum
- Fair, good for interactive systems
- Trade-off: quantum size

### MLFQ
- Multiple queues with different priorities
- Processes move between queues
- Prevents starvation with periodic boost

## Formulae
- Turnaround = Completion - Arrival
- Waiting = Turnaround - Burst
- Response = First_Run - Arrival
