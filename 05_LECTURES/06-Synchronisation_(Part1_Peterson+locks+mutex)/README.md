# Operating Systems - Week 6: Synchronisation (Part 1)

> **by Revolvix** | ASE Bucharest - CSIE | Year I, Semester 2 | 2025-2026

---

## Week Objectives

1. **Identify** race condition problems in concurrent code
2. Explain the concept of critical section and its necessary properties
3. Describe Peterson's algorithm and hardware synchronisation mechanisms
4. **Use** locks (locks/mutex) to protect critical sections

---

## Applied Context (didactic scenario): How do you lose money from your account if two ATMs process simultaneously?

You have 1000 lei in your account. You go to an ATM to withdraw 800 lei. At the same moment, your wife pays 500 lei online. Both systems read the balance: 1000 lei. Both decide it is sufficient. Both subtract. Final result: you withdrew 1300 lei from 1000 lei available! This is a **race condition**.

---

## Lecture Content (6/14)

### 1. Race Condition

#### Formal Definition

> **Race condition** is a situation in which **the outcome of execution depends on the (non-deterministic) order in which threads are scheduled** on the processor. It occurs when multiple threads access shared data and at least one modifies the data.

#### Intuitive Explanation

Imagine two people trying to pass through the same door simultaneously:
- If one arrives first: OK
- If they arrive at exactly the same time: they block or collide

In code:
```python
# Thread 1 and Thread 2 both do:
counter = counter + 1

# Decomposed:
# 1. LOAD counter → register
# 2. ADD 1
# 3. STORE register → counter

# If Thread 2 does LOAD before Thread 1 does STORE:
# Both see the same value, both increment, one is lost!
```

#### Historical Context

| Year | Event |
|------|-------|
| **1965** | Dijkstra formally identifies the problem and introduces semaphores |
| **1966** | The "critical section" problem defined |
| **1981** | Peterson publishes the algorithm for 2 processes |
| **2000s** | Memory barriers become critical on multi-core |

---

### 2. Critical Section

#### Formal Definition

> **Critical section** is the portion of code in which a process **accesses shared resources**. A correct solution must satisfy: **Mutual Exclusion**, Progress and **Bounded Waiting**.

```
entry_section();      // Request access
CRITICAL_SECTION;     // Access the resource
exit_section();       // Release access
remainder_section();  // Non-critical code
```

#### Necessary Properties

| Property | Description | Metaphor |
|----------|-------------|----------|
| **Mutual Exclusion** | At most one process in the critical section | Only one person in the toilet |
| Progress | If no one is in CS, someone can enter | The toilet does not remain occupied with no one inside |
| **Bounded Waiting** | Limit on the number of "overtakes" | You cannot be skipped indefinitely |

---

### 3. Peterson's Algorithm (2 Processes)

#### Formal Definition

> **Peterson's algorithm** is a software solution to the critical section problem for **2 processes**, using only shared variables, without special hardware support.

#### Pseudocode

```c
// Shared variables
int turn;          // Whose turn it is
bool flag[2];      // flag[i] = true if Pi wants to enter

// Process Pi (i = 0 or 1)
flag[i] = true;        // I want to enter
turn = 1 - i;          // I give priority to the other
while (flag[1-i] && turn == 1-i)
    ;                  // Wait (busy-wait)
// CRITICAL SECTION
flag[i] = false;       // I am done
```

#### Why does it work?

- **Mutual exclusion**: If both flags are true, turn decides who enters
- Progress: If the other does not want (flag=false), you enter immediately
- **Bounded waiting**: Maximum one "overtake"

#### Constraints

- Only 2 processes
- **Busy-waiting** (spinlock)
- **Does not work on modern CPUs** without memory barriers (instruction reordering!)

---

### 4. Hardware Atomic Instructions

#### Formal Definition

> **Atomic instructions** are hardware operations that are **indivisible** - once started, they complete without interruption.

#### Test-and-Set (TAS)

```c
// Hardware atomic
bool test_and_set(bool *target) {
    bool rv = *target;
    *target = true;
    return rv;
}

// Lock with TAS
bool lock = false;

void acquire() {
    while (test_and_set(&lock))
        ;  // Spin until lock was false
}

void release() {
    lock = false;
}
```

#### Compare-and-Swap (CAS)

```c
// Hardware atomic
bool compare_and_swap(int *val, int expected, int new_val) {
    if (*val == expected) {
        *val = new_val;
        return true;
    }
    return false;
}

// Lock-free increment
void atomic_increment(int *counter) {
    int old;
    do {
        old = *counter;
    } while (!compare_and_swap(counter, old, old + 1));
}
```

#### Comparative Implementation

| Aspect | x86/x64 | ARM |
|--------|---------|-----|
| TAS | `lock xchg` | `ldrex/strex` |
| CAS | `lock cmpxchg` | `ldrex/strex` + loop |
| Atomic add | `lock add` | `ldadd` (ARMv8.1+) |

---

### 5. Mutex (Mutual Exclusion Lock)

#### Formal Definition

> Mutex is a synchronisation mechanism that ensures that **only one thread** can "hold" the lock at any given time. Other threads that attempt to acquire it are blocked (put to sleep) until the lock is released.

#### Difference: Spinlock vs Mutex

| Spinlock | Mutex |
|----------|-------|
| Busy-wait (CPU 100%) | Sleep (CPU 0%) |
| Good for short CS | Good for long CS |
| No context switch | With context switch |
| Wastes CPU if waiting long | Overhead on acquire/release |

#### Python Implementation

```python
import threading
import time

# Mutex in Python
lock = threading.Lock()
counter = 0

def increment_safe():
    global counter
    with lock:  # acquire() + release() automatic
        temp = counter
        time.sleep(0.001)  # Simulate processing
        counter = temp + 1

# Race condition demo
def increment_unsafe():
    global counter
    temp = counter
    time.sleep(0.001)
    counter = temp + 1

# Test
counter = 0
threads = [threading.Thread(target=increment_safe) for _ in range(10)]
for t in threads: t.start()
for t in threads: t.join()
print(f"Safe counter: {counter}")  # 10

counter = 0
threads = [threading.Thread(target=increment_unsafe) for _ in range(10)]
for t in threads: t.start()
for t in threads: t.join()
print(f"Unsafe counter: {counter}")  # Probably < 10!
```

---

## Laboratory/Seminar (Session 3/7)

### TC Materials
- TC2e - Unix Tools (find, xargs)
- TC4b - File Permissions
- TC4g - Positional Parameters
- TC4h - Cron Jobs

### Assignment 3: `tema3_backup.sh`

Backup script with rotation:
- `-s SOURCE` - source directory
- `-d DEST` - destination
- `-n NUM` - backups kept
- `-v` - verbose

---

## Recommended Reading

### OSTEP
- [Chapter 28 - Locks](https://pages.cs.wisc.edu/~remzi/OSTEP/threads-locks.pdf)
- [Chapter 29 - Lock-based Data Structures](https://pages.cs.wisc.edu/~remzi/OSTEP/threads-locks-usage.pdf)

---

*Materials by Revolvix for ASE Bucharest - CSIE*

## Scripting in Context (Bash + Python): Mutual exclusion in practice: lockfile for backup

### Included Files

- Bash: `scripts/backup_with_lock.sh` — Backup with rotation + `flock` (avoids concurrent executions).
- Python: `scripts/lock_demo.py` — Demonstration of `fcntl.flock()` in two terminals.

### Quick Run

```bash
./scripts/backup_with_lock.sh -s . -d ./_backups --dry-run
./scripts/lock_demo.py --lock /tmp/demo.lock --hold 5
```

### Connection to This Week's Concepts

- A lockfile is the practical analogue of mutual exclusion: it prevents dangerous interleaving between two process instances.
- `flock`/`fcntl.flock` connects theory (locks) to real administration (cron, backup, rotations).

### Recommended Practice

- run the scripts first on a test directory (not on critical data);
- save the output to a file and attach it to your report/assignment if required;
- note the kernel version (`uname -r`) and Python version (`python3 --version`) when comparing results.


---

## Self-Assessment

### Review Questions

1. **[REMEMBER]** What is a race condition? Define critical section and the 3 conditions for a correct solution.
2. **[UNDERSTAND]** Explain how Peterson's algorithm works for 2 processes. Why does it need the `flag[]` and `turn` variables?
3. **[ANALYSE]** Compare mutex with spinlock. In what situations is each preferable? Analyse the overhead and CPU usage.

### Mini-Challenge (optional)

Demonstrate a race condition in Python using 2 threads that increment the same counter without synchronisation.

---


---


---

## Nuances and Special Cases

### What We Did NOT Cover (didactic limitations)

- **Memory barriers / fences**: CPU instructions that guarantee the order of memory operations.
- **Lock-free and wait-free algorithms**: Data structures without locks (e.g. CAS-based queues).
- **RCU (Read-Copy-Update)**: Linux mechanism for frequent reads without lock.

### Common Mistakes to Avoid

1. **Double-checked locking without memory barriers**: Classic pattern that does not work without `volatile` or barriers.
2. **Excessive busy waiting**: Spinlocks only for very short critical sections.
3. **Inconsistent lock ordering**: If A→B in one place and B→A in another, deadlock guaranteed.

### Open Questions

- Can compilers automatically detect race conditions at compile time?
- How are synchronisation primitives evolving for heterogeneous architectures (CPU+GPU)?

## Looking Ahead

**Week 7: Synchronisation (Part 2)** — From simple mutexes we move to semaphores and monitors. We will study the classic producer-consumer problem and how it is elegantly solved with higher-level synchronisation primitives.

**Recommended Preparation:**
- Review Peterson's algorithm and its limitations
- Read OSTEP Chapter 31 (Semaphores)

## Visual Summary

```
┌─────────────────────────────────────────────────────────────────┐
│                    WEEK 6: SYNCHRONISATION I — RECAP            │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  PROBLEM: Race Condition                                        │
│  └── Outcome depends on execution order → BUG!                  │
│                                                                 │
│  CRITICAL SECTION                                               │
│  ├── Code that accesses shared resources                        │
│  └── Must be executed ATOMICALLY (mutual exclusion)             │
│                                                                 │
│  CONDITIONS FOR CORRECT SOLUTION                                │
│  ├── 1. Mutual Exclusion: only one process in CS                │
│  ├── 2. Progress: decision made in finite time                  │
│  └── 3. Bounded Waiting: limit on waiting                       │
│                                                                 │
│  SOFTWARE SOLUTIONS                                             │
│  └── Peterson: flag[] + turn (only 2 processes)                 │
│                                                                 │
│  HARDWARE SOLUTIONS                                             │
│  ├── Test-and-Set, Compare-and-Swap (atomic)                    │
│  └── Mutex (implemented with atomic instructions)               │
│                                                                 │
│  💡 TAKEAWAY: Without synchronisation → subtle and rare bugs    │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

*Materials developed by Revolvix for ASE Bucharest - CSIE*
