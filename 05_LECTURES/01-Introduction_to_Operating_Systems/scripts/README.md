# Demonstration Scripts — Week 01

> Introduction to Operating Systems | ASE Bucharest - CSIE

---

## Contents

| Script | Language | Purpose |
|--------|----------|---------|
| `batch_sim.py` | Python 3 | FCFS batch processing simulation with turnaround/waiting time calculations |

---

## Requirements

- Ubuntu 24.04 (WSL2, VirtualBox, or native)
- Python 3.10+
- No external packages required (stdlib only)

---

## Quick Start

```bash
# Show help
python3 batch_sim.py --help

# Run with sample job durations (in seconds)
python3 batch_sim.py 2 1 3.5 0.5

# Example output shows:
# - Job execution order (FCFS)
# - Start, finish, turnaround, waiting times
# - Average metrics
```

---

## Connection to Lecture

This script demonstrates the **Batch Processing** algorithm discussed in Week 1:

| Concept | Script Demonstration |
|---------|---------------------|
| FCFS scheduling | Jobs execute in arrival order |
| Turnaround time | Finish time - arrival time |
| Waiting time | Start time - arrival time |
| CPU utilisation | No idle time between jobs |

---

## Sample Output

```
╔════════════════════════════════════════════════════════════╗
║             BATCH PROCESSING SIMULATION (FCFS)             ║
╠════════════════════════════════════════════════════════════╣
║ Job │ Duration │  Start  │ Finish  │ Turnaround │ Waiting  ║
╠═════╪══════════╪═════════╪═════════╪════════════╪══════════╣
║  1  │   2.00   │   0.00  │   2.00  │    2.00    │   0.00   ║
║  2  │   1.00   │   2.00  │   3.00  │    3.00    │   2.00   ║
║  3  │   3.50   │   3.00  │   6.50  │    6.50    │   3.00   ║
║  4  │   0.50   │   6.50  │   7.00  │    7.00    │   6.50   ║
╠════════════════════════════════════════════════════════════╣
║ Average Turnaround: 4.63s    Average Waiting: 2.88s        ║
╚════════════════════════════════════════════════════════════╝
```

---

## Exercises

1. **Vary job order**: Run with `0.5 1 2 3.5` instead. Compare average waiting times.
2. **Large batch**: Create 20 random jobs and observe the waiting time growth.
3. **Connect to history**: Why did batch processing increase CPU utilisation from 30% to 90%?

---

*Week 01 | Operating Systems | ASE Bucharest - CSIE | 2025-2026*
