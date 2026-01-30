# OS Quick Reference Card — Exam Cheatsheet

> Print-friendly summary of key formulas and concepts

---

## Scheduling Formulas

| Metric | Formula |
|--------|---------|
| Turnaround Time | Completion − Arrival |
| Waiting Time | Turnaround − Burst |
| Response Time | First Run − Arrival |
| CPU Utilisation | (Total Burst ÷ Total Time) × 100% |
| Throughput | Processes Completed ÷ Total Time |

### Algorithm Comparison

| Algorithm | Preemptive | Optimal For | Weakness |
|-----------|------------|-------------|----------|
| FCFS | No | Simplicity | Convoy effect |
| SJF | No | Avg wait time | Starvation of long jobs |
| SRTF | Yes | Avg wait time | Requires burst prediction |
| Round Robin | Yes | Fairness | High context switch overhead |
| MLFQ | Yes | Mixed workloads | Complex tuning |

---

## Coffman Conditions (Deadlock)

All four must hold simultaneously for deadlock:

1. **M**utual Exclusion — Resource held exclusively
2. **H**old and Wait — Process holds while requesting more
3. **N**o Preemption — Resources cannot be forcibly taken
4. **C**ircular Wait — Circular chain of waiting processes

> **Mnemonic:** **M**y **H**ard **N**uts **C**rack

### Deadlock Strategies

| Strategy | Method | Trade-off |
|----------|--------|-----------|
| Prevention | Break one condition | Reduces flexibility |
| Avoidance | Banker's algorithm | Requires advance knowledge |
| Detection | Resource graph | Recovery overhead |
| Ignorance | Ostrich algorithm | Risk of deadlock |

---

## Memory Calculations

| Calculation | Formula |
|-------------|---------|
| Virtual Address Space | 2^(address bits) |
| Number of Pages | Virtual Size ÷ Page Size |
| Page Table Entries | Number of Pages |
| Page Table Size | Entries × Entry Size |
| Physical Address | (Frame# × Page Size) + Offset |

### Address Translation Example

```
Virtual Address: 0x00002ABC (page size = 4KB = 0x1000)
Page Number:     0x00002ABC ÷ 0x1000 = 0x2
Offset:          0x00002ABC mod 0x1000 = 0xABC

If Page 2 → Frame 7:
Physical Address = 7 × 0x1000 + 0xABC = 0x7ABC
```

### Page Replacement Algorithms

| Algorithm | Description | Anomaly? |
|-----------|-------------|----------|
| FIFO | Replace oldest | Yes (Bélády) |
| LRU | Replace least recently used | No |
| Optimal | Replace furthest future use | No (theoretical) |
| Clock | FIFO with second chance | No |

---

## File System Structures

| Structure | Purpose |
|-----------|---------|
| Superblock | FS metadata (size, block count, magic number) |
| Inode | File metadata (permissions, size, pointers) |
| Data Block | Actual file content |
| Directory | Filename → Inode number mapping |

### Inode Pointer Structure (ext2/3/4)

```
┌─────────────────┐
│ 12 Direct       │ → 12 × block_size
├─────────────────┤
│ 1 Indirect      │ → (block_size ÷ 4) blocks
├─────────────────┤
│ 1 Double Ind.   │ → (block_size ÷ 4)² blocks
├─────────────────┤
│ 1 Triple Ind.   │ → (block_size ÷ 4)³ blocks
└─────────────────┘
```

### Hard Link vs Symbolic Link

| Aspect | Hard Link | Symbolic Link |
|--------|-----------|---------------|
| Inode | Same as target | Different (own inode) |
| Cross filesystem | No | Yes |
| Target deleted | Still works | Broken (dangling) |
| Storage | No extra | Stores path string |

---

## Synchronisation Primitives

| Primitive | Operations | Use Case |
|-----------|------------|----------|
| Mutex | lock/unlock | Mutual exclusion |
| Semaphore | wait(P)/signal(V) | Counting, signalling |
| Condition Variable | wait/signal/broadcast | Complex conditions |
| Spinlock | busy-wait | Short critical sections |

### Peterson's Algorithm (2 processes)

```c
flag[i] = true;
turn = j;
while (flag[j] && turn == j) { /* busy wait */ }
// Critical section
flag[i] = false;
```

---

## Process vs Thread

| Aspect | Process | Thread |
|--------|---------|--------|
| Address Space | Separate | Shared |
| Creation Cost | High (~ms) | Low (~μs) |
| Communication | IPC (pipes, sockets) | Shared memory |
| Crash Impact | Isolated | Kills entire process |
| Context Switch | Expensive (TLB flush) | Cheap |

---

## Virtualisation

| Type | Isolation | Overhead | Boot Time |
|------|-----------|----------|-----------|
| VM (Type 1) | Full | Medium | Minutes |
| VM (Type 2) | Full | High | Minutes |
| Container | Process-level | Low | Seconds |

### Popek-Goldberg Requirements

1. **Equivalence** — Same behaviour as native
2. **Resource Control** — VMM controls all resources
3. **Efficiency** — Most instructions run natively

---

## Quick Conversions

| Unit | Value |
|------|-------|
| 1 KB | 2¹⁰ = 1,024 bytes |
| 1 MB | 2²⁰ = 1,048,576 bytes |
| 1 GB | 2³⁰ bytes |
| 1 ms | 10⁻³ seconds |
| 1 μs | 10⁻⁶ seconds |
| 1 ns | 10⁻⁹ seconds |

---

*Print this page for quick exam reference — Good luck!*
