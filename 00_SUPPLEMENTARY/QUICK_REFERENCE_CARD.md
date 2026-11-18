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
| SJF | No | Mean wait for known bursts, equal arrivals | Starvation of long jobs |
| SRTF | Yes | Mean flow/wait in the ideal known-burst model | Requires burst prediction |
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
| Number of Pages for a byte range | ceil(Virtual Size ÷ Page Size) |
| Page Table Entries | Number of Pages |
| Page Table Size | Entries × Entry Size |
| Physical Address | (Frame# × Page Size) + Offset |

### Address Translation Example

```
Virtual Address: 0x00002ABC (page size = 4 KiB = 0x1000)
Page Number:     floor(0x00002ABC ÷ 0x1000) = 0x2
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
| Clock | Circular second chance, with explicit hand/reference-bit rules | Yes, ordinary Clock can exhibit Bélády anomalies |

---

## File System Structures

| Structure | Purpose |
|-----------|---------|
| Superblock | FS metadata (size, block count, magic number) |
| Inode | File metadata (permissions, size, pointers) |
| Data Block | Actual file content |
| Directory | Filename → Inode number mapping |

### Classical Inode Pointer Structure (legacy ext2/ext3-style mapping)

Modern ext4 normally uses an extent tree in `i_block`. The following arithmetic assumes 4-byte pointers and is not a universal ext4 maximum file size.

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
| Storage | Additional directory entry; shared inode/data | Separate inode and stored target path |

---

## Synchronisation Primitives

| Primitive | Operations | Use Case |
|-----------|------------|----------|
| Mutex | lock/unlock | Mutual exclusion |
| Semaphore | wait(P)/signal(V) | Counting, signalling |
| Condition Variable | wait/signal/broadcast | Complex conditions |
| Spinlock | busy-wait | Short critical sections |

### Peterson's Algorithm (2 processes)

This is a sequentially consistent shared-memory model. Ordinary non-atomic concurrent C loads/stores cause a data race; a real C implementation needs suitable atomics and memory ordering.

```c
flag[i] = true;
turn = j;
while (flag[j] && turn == j) { /* busy wait */ }
// Critical section
flag[i] = false;
```

---

## Process vs Thread

The timing/cost labels below are retained historical teaching estimates, with no measured environment. Context-switch costs depend on architecture, address-space identifiers and workload; not every process switch flushes every TLB entry. Processes can share mappings, and a shared-host failure can affect several processes.

| Aspect | Process | Thread |
|--------|---------|--------|
| Address Space | Separate | Shared |
| Creation Cost | High (~ms) | Low (~μs) |
| Communication | IPC (pipes, sockets) | Shared memory |
| Crash Impact | Isolated | Kills entire process |
| Context Switch | May change address space; TLB handling is architecture-dependent | Same-process threads retain the address space |

---

## Virtualisation

The following legacy overhead/start-up labels are not measured guarantees. Isolation depends on the hypervisor/kernel, privileges and configuration; multiple VMs on one host do not establish high availability. Provenance or an explicitly adopted illustrative model remains an author decision.

| Type | Isolation | Overhead | Boot Time |
|------|-----------|----------|-----------|
| VM (Type 1) | Hypervisor boundary | Medium | Minutes |
| VM (Type 2) | Hypervisor/host boundary | High | Minutes |
| Container | Process-level | Low | Seconds |

### Popek-Goldberg Requirements

1. **Equivalence** — Same behaviour as native
2. **Resource Control** — VMM controls all resources
3. **Efficiency** — Most instructions run natively

---

## Quick Conversions

| Unit | Value |
|------|-------|
| 1 KiB | 2¹⁰ = 1,024 bytes |
| 1 MiB | 2²⁰ = 1,048,576 bytes |
| 1 GiB | 2³⁰ bytes |
| 1 ms | 10⁻³ seconds |
| 1 μs | 10⁻⁶ seconds |
| 1 ns | 10⁻⁹ seconds |

---

*Print this page for quick exam reference — Good luck!*

**Clock counterexample:** for the reference string `1,2,3,4,1,2,5,1,2,3,4,5`, initially empty frames, hand at 0, insertion bit 1, hit bit set and hand advanced after insertion, Clock incurs 9 faults with 3 frames and 10 with 4. These rules matter to reproducibility.
