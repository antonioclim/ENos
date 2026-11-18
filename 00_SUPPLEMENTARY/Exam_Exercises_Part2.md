# OS — Exercises, Diagrams and Exam Questions

## Part 2: Weeks 5–8 (Threads, Synchronisation, Deadlock)

> by Revolvix | ASE Bucharest — CSIE

### Difficulty Legend

| Symbol | Level | Time | Description |
|--------|-------|------|-------------|
| ⭐ | Easy | 3–5 min | Basic recall and understanding |
| ⭐⭐ | Medium | 5–10 min | Application of concepts |
| ⭐⭐⭐ | Hard | 10–15 min | Analysis and calculation |
| ⭐⭐⭐⭐ | Expert | 15–20 min | Evaluation and design |

> 💡 **Study tip:** Synchronisation problems require careful step-by-step reasoning. Draw the timeline of thread execution to visualise race conditions.

---

# WEEK 5: Threads

## Detailed ASCII Diagrams

### Diagram 5.1: Thread vs Process Memory Layout

Separate process address spaces provide isolation of private mappings, not
complete isolation of all kernel resources or shared mappings. Executable
file-backed pages may be physically shared; a drawn CODE region per process
does not imply a separate physical copy. The creation/switch timing ranges
below are unverified illustrative inputs, not portable measurements. Linux
threads still have task identity and their own configured user/kernel stacks.

```
═══════════════════════════════════════════════════════════════════════════
                    PROCESS vs THREAD - MEMORY LAYOUT
═══════════════════════════════════════════════════════════════════════════

══════════════════════════════════════════════════════════════════════════
TWO SEPARATE PROCESSES:
══════════════════════════════════════════════════════════════════════════

    PROCESS A (PID 1000)                    PROCESS B (PID 2000)
    ════════════════════                    ════════════════════
    
┌─────────────────────────────┐      ┌─────────────────────────────┐
│  Virtual Address Space A    │      │  Virtual Address Space B    │
│  ┌───────────────────────┐  │      │  ┌───────────────────────┐  │
│  │     Kernel Space      │  │      │  │     Kernel Space      │  │
│  │      (shared)         │  │      │  │      (shared)         │  │
│  ├───────────────────────┤  │      │  ├───────────────────────┤  │
│  │        Stack          │  │      │  │        Stack          │  │
│  │       (own)           │  │      │  │       (own)           │  │
│  ├───────────────────────┤  │      │  ├───────────────────────┤  │
│  │                       │  │      │  │                       │  │
│  ├───────────────────────┤  │      │  ├───────────────────────┤  │
│  │        Heap           │  │      │  │        Heap           │  │
│  │       (own)           │  │      │  │       (own)           │  │
│  ├───────────────────────┤  │      │  ├───────────────────────┤  │
│  │      Data/BSS         │  │      │  │      Data/BSS         │  │
│  │       (own)           │  │      │  │       (own)           │  │
│  ├───────────────────────┤  │      │  ├───────────────────────┤  │
│  │        Text           │  │      │  │        Text           │  │
│  │       (own)           │  │      │  │       (own)           │  │
│  └───────────────────────┘  │      │  └───────────────────────┘  │
└─────────────────────────────┘      └─────────────────────────────┘
            │                                    │
            ▼                                    ▼
┌─────────────────────────────────────────────────────────────────────┐
│                         PHYSICAL MEMORY                             │
│  ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐       │
│  │Frame A1 │ │Frame A2 │ │Frame B1 │ │Frame B2 │ │ Kernel  │       │
│  │(Stack A)│ │(Heap A) │ │(Stack B)│ │(Heap B) │ │(shared) │       │
│  └─────────┘ └─────────┘ └─────────┘ └─────────┘ └─────────┘       │
│                                                                     │
│  PRIVATE address spaces; explicitly shared mappings are possible.       │
└─────────────────────────────────────────────────────────────────────┘

══════════════════════════════════════════════════════════════════════════
ONE PROCESS WITH MULTIPLE THREADS:
══════════════════════════════════════════════════════════════════════════

                    PROCESS P (PID 1000) with 3 THREADS
                    ════════════════════════════════════
                    
┌─────────────────────────────────────────────────────────────────────────┐
│                     Virtual Address Space (SHARED)                      │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │                      Kernel Space                                │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                                                                         │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐                 │
│  │  Stack T1   │    │  Stack T2   │    │  Stack T3   │  ← SEPARATE     │
│  │  ─────────  │    │  ─────────  │    │  ─────────  │                 │
│  │  var_a = 5  │    │  var_a = 10 │    │  var_a = 15 │  (local         │
│  │  var_b = 2  │    │  var_b = 7  │    │  var_b = 9  │   variables)    │
│  │  ret_addr   │    │  ret_addr   │    │  ret_addr   │                 │
│  └─────────────┘    └─────────────┘    └─────────────┘                 │
│         │                  │                  │                         │
│         │    Thread ID     │    Thread ID     │    Thread ID           │
│         │    Registers     │    Registers     │    Registers           │
│         │    PC (Program   │    PC            │    PC         SEPARATE │
│         │    Counter)      │                  │                         │
│         │                  │                  │                         │
│  ───────┴──────────────────┴──────────────────┴─────────────────────   │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │                         HEAP                                     │   │
│  │  ┌─────────────────────────────────────────────────────────┐    │   │
│  │  │  shared_counter = 42                                     │    │   │
│  │  │  shared_array[] = [1, 2, 3, 4, 5]                       │    │   │
│  │  │  mutex = <locked by T2>                                  │    │   │
│  │  └─────────────────────────────────────────────────────────┘    │ S │
│  │                                                                  │ H │
│  │  ANY THREAD CAN ACCESS ANYTHING IN HEAP!                        │ A │
│  │  → SYNCHRONISATION REQUIRED!                                    │ R │
│  └─────────────────────────────────────────────────────────────────┘ E │
│                                                                       D │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │                      DATA/BSS                                    │   │
│  │  global_config = "production"                                    │   │
│  │  log_level = 3                                                   │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │                        TEXT                                      │   │
│  │  [executable instructions]                                       │   │
│  │  All threads execute the same code!                              │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │                    FILE DESCRIPTORS                              │   │
│  │  fd[0] = stdin                                                   │   │
│  │  fd[1] = stdout                                                  │ S │
│  │  fd[2] = stderr                                                  │ H │
│  │  fd[3] = /var/log/app.log                                       │ A │
│  │                                                                  │ R │
│  │  SHARED! One thread opens, all can use.                         │ E │
│  └─────────────────────────────────────────────────────────────────┘ D │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘

══════════════════════════════════════════════════════════════════════════
COMPARATIVE SUMMARY:
══════════════════════════════════════════════════════════════════════════

┌─────────────────┬──────────────────────────┬──────────────────────────┐
│   Component     │   SEPARATE PROCESSES     │   THREADS (same process) │
├─────────────────┼──────────────────────────┼──────────────────────────┤
│ Address Space   │ SEPARATE for each        │ SHARED                   │
│ Text (Code)     │ May share physical pages │ SHARED                   │
│ Data/BSS        │ SEPARATE                 │ SHARED                   │
│ Heap            │ SEPARATE                 │ SHARED                   │
│ Stack           │ SEPARATE                 │ SEPARATE per thread      │
│ Registers       │ SEPARATE                 │ SEPARATE per thread      │
│ PC              │ SEPARATE                 │ SEPARATE per thread      │
│ File Descriptors│ Copied at fork           │ SHARED                   │
│ PID             │ Different                │ Same                     │
│ TID             │ Main task has a TID      │ Different per task       │
├─────────────────┼──────────────────────────┼──────────────────────────┤
│ Isolation       │ Private address spaces   │ Shared address space     │
│ Communication   │ IPC (pipes, sockets)     │ Direct shared memory     │
│ Creation        │ ~1-10 ms                 │ ~10-100 μs               │
│ Context Switch  │ Illustrative ~1-10 μs    │ Illustrative ~0.1-1 μs   │
│ Crash Impact    │ Only that process        │ Entire process dies      │
└─────────────────┴──────────────────────────┴──────────────────────────┘
```

### Diagram 5.2: Multithreading Models

```
═══════════════════════════════════════════════════════════════════════════
                    MULTITHREADING MODELS
═══════════════════════════════════════════════════════════════════════════

╔═══════════════════════════════════════════════════════════════════════════╗
║                         MODEL 1: MANY-TO-ONE (N:1)                         ║
╠═══════════════════════════════════════════════════════════════════════════╣
║                                                                           ║
║    USER SPACE                                                             ║
║    ┌─────────────────────────────────────────────────────────────────┐   ║
║    │                                                                  │   ║
║    │     T1 ●    T2 ●    T3 ●    T4 ●    T5 ●                       │   ║
║    │       \      |       |       |      /                           │   ║
║    │        \     |       |       |     /                            │   ║
║    │         \    |       |       |    /                             │   ║
║    │          ────┴───────┴───────┴────                              │   ║
║    │                    |                                             │   ║
║    │     ┌──────────────▼──────────────┐                             │   ║
║    │     │   User-Level Thread Library  │                             │   ║
║    │     │   (Green Threads, Fibers)    │                             │   ║
║    │     │   - Scheduling in user space │                             │   ║
║    │     │   - Fast context switch      │                             │   ║
║    │     └──────────────┬──────────────┘                             │   ║
║    │                    │                                             │   ║
║    └────────────────────┼────────────────────────────────────────────┘   ║
║                         │                                                 ║
║    ════════════════════════════════════════════════════════════════════  ║
║                         │  A SINGLE kernel thread                         ║
║    KERNEL SPACE         ▼                                                 ║
║    ┌────────────────────────────────────────────────────────────────┐    ║
║    │                     K1 ◆                                        │    ║
║    │               (kernel thread)                                   │    ║
║    └────────────────────────────────────────────────────────────────┘    ║
║                                                                           ║
║    ✅ Advantages:                   ❌ Disadvantages:                     ║
║    • Fast switch between threads    • A blocking syscall blocks ALL       ║
║    • Portable                       • Cannot exploit multi-core           ║
║    • No kernel overhead             • One thread crash = whole process    ║
║                                                                           ║
║    📌 Examples: GNU Pth, Java Green Threads (old)                        ║
╚═══════════════════════════════════════════════════════════════════════════╝

╔═══════════════════════════════════════════════════════════════════════════╗
║                         MODEL 2: ONE-TO-ONE (1:1)                          ║
╠═══════════════════════════════════════════════════════════════════════════╣
║                                                                           ║
║    USER SPACE                                                             ║
║    ┌─────────────────────────────────────────────────────────────────┐   ║
║    │                                                                  │   ║
║    │     T1 ●         T2 ●         T3 ●         T4 ●                 │   ║
║    │       │            │            │            │                   │   ║
║    │       │            │            │            │                   │   ║
║    │       │            │            │            │                   │   ║
║    └───────┼────────────┼────────────┼────────────┼──────────────────┘   ║
║            │            │            │            │                       ║
║    ════════╪════════════╪════════════╪════════════╪═══════════════════   ║
║            │  1:1       │  1:1       │  1:1       │  1:1                  ║
║    KERNEL  ▼            ▼            ▼            ▼                       ║
║    ┌────────────────────────────────────────────────────────────────┐    ║
║    │     K1 ◆         K2 ◆         K3 ◆         K4 ◆                │    ║
║    │   (kernel)     (kernel)     (kernel)     (kernel)               │    ║
║    │    thread       thread       thread       thread                │    ║
║    └───────┬────────────┬────────────┬────────────┬─────────────────┘    ║
║            │            │            │            │                       ║
║            ▼            ▼            ▼            ▼                       ║
║    ┌────────────────────────────────────────────────────────────────┐    ║
║    │     CPU 0       CPU 1       CPU 2       CPU 3                   │    ║
║    │   ┌──────┐    ┌──────┐    ┌──────┐    ┌──────┐                 │    ║
║    │   │ Core │    │ Core │    │ Core │    │ Core │                 │    ║
║    │   └──────┘    └──────┘    └──────┘    └──────┘                 │    ║
║    │              REAL PARALLELISM ON MULTI-CORE!                    │    ║
║    └────────────────────────────────────────────────────────────────┘    ║
║                                                                           ║
║    ✅ Advantages:                   ❌ Disadvantages:                     ║
║    • Real multi-core parallelism    • Thread creation overhead            ║
║    • One blocked thread doesn't     • Limit on number of threads          ║
║      affect others                  • Switch via kernel (slower)          ║
║    • Optimised kernel scheduler                                           ║
║                                                                           ║
║    📌 Examples: Linux NPTL, Windows Threads, macOS Threads               ║
╚═══════════════════════════════════════════════════════════════════════════╝

╔═══════════════════════════════════════════════════════════════════════════╗
║                       MODEL 3: MANY-TO-MANY (M:N)                          ║
╠═══════════════════════════════════════════════════════════════════════════╣
║                                                                           ║
║    USER SPACE                                                             ║
║    ┌─────────────────────────────────────────────────────────────────┐   ║
║    │                                                                  │   ║
║    │   T1 ●  T2 ●  T3 ●  T4 ●  T5 ●  T6 ●  T7 ●  T8 ●               │   ║
║    │     \    |    /      \    |    /      \    /                    │   ║
║    │      \   |   /        \   |   /        \  /                     │   ║
║    │       \  |  /          \  |  /          \/                      │   ║
║    │        \ | /            \ | /           /\                      │   ║
║    │         ─┼─              ─┼─           /  \                     │   ║
║    │     ┌────┴────────────────┴───────────┴────┐                    │   ║
║    │     │      User-Level Scheduler            │                    │   ║
║    │     │  (multiplexes M user threads         │                    │   ║
║    │     │   onto N kernel threads)             │                    │   ║
║    │     └────┬────────────────┬────────────┬───┘                    │   ║
║    │          │                │            │                        │   ║
║    └──────────┼────────────────┼────────────┼───────────────────────┘   ║
║               │                │            │                            ║
║    ═══════════╪════════════════╪════════════╪════════════════════════   ║
║               │  M:N           │            │                            ║
║    KERNEL     ▼                ▼            ▼                            ║
║    ┌────────────────────────────────────────────────────────────────┐   ║
║    │          K1 ◆            K2 ◆         K3 ◆                     │   ║
║    │       (kernel)         (kernel)      (kernel)                   │   ║
║    │        thread           thread        thread                    │   ║
║    │                                                                 │   ║
║    │    8 user threads multiplexed onto 3 kernel threads!           │   ║
║    └────────────────────────────────────────────────────────────────┘   ║
║                                                                          ║
║    ✅ Advantages:                   ❌ Disadvantages:                    ║
║    • Flexible (M >> N or M = N)     • Complex to implement               ║
║    • Combines N:1 and 1:1 benefits  • Synchronisation between schedulers ║
║    • Can scale thousands of threads • Difficult debugging                ║
║                                                                          ║
║    📌 Examples: Go goroutines, Erlang processes, Solaris (historic)     ║
╚═══════════════════════════════════════════════════════════════════════════╝
```

---

## Solved Exercises

### Exercise 5.1: Threads vs Processes Analysis

Problem: For each scenario, decide whether threads or separate processes should be used. Justify.

| Scenario | Recommendation | Justification |
|----------|----------------|---------------|
| Web server handling 10,000 simultaneous requests | Threads (or async I/O) | Requests are independent but share config, DB connections. Threads are lighter. |
| Browser with multiple tabs | Separate processes for tabs | Isolation: a compromised/crashed tab doesn't affect others (security, stability) |
| Scientific computing application with shared data | Threads | Need fast access to shared data; low communication overhead |
| Video processing pipeline | Processes connected with pipes | Each stage is independent, can crash separately, can be rewritten in another language |
| Video game with rendering and physics | Threads | Need tight synchronisation, low latency, game state sharing |

---

### Exercise 5.2: Thread Safety

The unsynchronised Python example is intentionally problematic. Whether a
particular run visibly loses updates depends on interpreter version, GIL or
free-threaded configuration and execution interleavings. A result of 400000
does not prove the programme thread-safe; a lower result is not guaranteed.
The lock and per-thread aggregation variants express the intended safe designs.

Problem: Identify the problems in the following code and correct them.

```python
# PROBLEMATIC CODE
import threading

counter = 0

def increment():
    global counter
    for _ in range(100000):
        counter = counter + 1  # PROBLEM!

threads = [threading.Thread(target=increment) for _ in range(4)]
for t in threads:
    t.start()
for t in threads:
    t.join()

print(counter)  # Serial target: 400000; a visible lost update is not guaranteed.
```

Solution:

```python
# CORRECTED CODE - Variant 1: Lock
import threading

counter = 0
lock = threading.Lock()

def increment_safe():
    global counter
    for _ in range(100000):
        with lock:  # Protected critical section
            counter = counter + 1

# Variant 2: Atomics (threading has Lock, but no atomic counter)
# In practice, use Lock or Queue

# Variant 3: Avoid shared state - each thread counts locally
def increment_local():
    local_count = 0
    for _ in range(100000):
        local_count += 1
    return local_count

# Then sum the results
from concurrent.futures import ThreadPoolExecutor
with ThreadPoolExecutor(max_workers=4) as executor:
    futures = [executor.submit(increment_local) for _ in range(4)]
    total = sum(f.result() for f in futures)
print(total)  # 400000 guaranteed!
```

---

## Exam-Style Questions

5.1 (Multiple Choice) What do threads of the same process share?
- a) Stack
- b) CPU Registers
- c) Program Counter
- d) Heap ✓

---

5.2 (Multiple Choice) In the 1:1 model, if a thread makes a blocking syscall:
- a) All threads block
- b) Only that thread blocks ✓
- c) The entire process is terminated
- d) The kernel automatically creates a new thread

---

5.3 (5p) Explain why creating a thread can cost less than creating a new process, and identify the assumptions needed for a speed claim.

Model answer:

Thread creation often avoids some process-creation work, but relative speed
depends on the API, mappings, resource tables, libc/kernel version and workload.

1. **Address space (2p):** `fork` generally creates a separate address-space
   description and page tables, with eligible pages initially shared through
   CoW. Threads share an address space but still require task bookkeeping,
   thread-local storage and a user stack. Stack size follows attributes and
   platform limits; it is not universally 8 KiB.
2. **Attributes (1p):** process and thread creation both inherit and initialise
   applicable credentials, scheduling and resource attributes. A thread is not
   exempt from all security work, nor does every `fork` reauthenticate a user.
3. **Identity (0.5p):** Linux creates a task/TID for a kernel thread. Thread-group
   identity differs from task identity; TID allocation is not inherently simpler
   than allocating a process identifier.
4. **Descriptor table (0.5p):** POSIX threads ordinarily share the table; `fork`
   creates a distinct table whose entries refer to shared open file descriptions.
5. **Implementation (1p):** libc wrappers may use clone-family mechanisms with
   different sharing flags. There is no universal fewer-syscalls proof. Compare
   the same useful work on a specified system before asserting a speed ratio.

References: [pthread_create](https://man7.org/linux/man-pages/man3/pthread_create.3.html)
and [clone](https://man7.org/linux/man-pages/man2/clone.2.html).

---

# WEEK 6: Synchronisation I

## Detailed ASCII Diagrams

### Diagram 6.1: Race Condition Visualised

```
═══════════════════════════════════════════════════════════════════════════
                         RACE CONDITION - VISUALISATION
═══════════════════════════════════════════════════════════════════════════

Problem: counter++ is NOT atomic!

Code:
    counter = counter + 1

Decomposes into 3 instructions:
    1. LOAD  counter → register
    2. ADD   1 → register
    3. STORE register → counter

═══════════════════════════════════════════════════════════════════════════
CORRECT SCENARIO (without interleaving):
═══════════════════════════════════════════════════════════════════════════

counter = 0

Thread A                            Thread B
─────────────────────────────────────────────────────────────────
(1) LOAD  counter → regA = 0
(2) ADD   1 → regA = 1
(3) STORE regA → counter = 1
                                    (4) LOAD  counter → regB = 1
                                    (5) ADD   1 → regB = 2
                                    (6) STORE regB → counter = 2

Final result: counter = 2 ✓

═══════════════════════════════════════════════════════════════════════════
SCENARIO WITH RACE CONDITION (problematic interleaving):
═══════════════════════════════════════════════════════════════════════════

counter = 0

Thread A                            Thread B
─────────────────────────────────────────────────────────────────
(1) LOAD  counter → regA = 0
                                    (2) LOAD  counter → regB = 0
(3) ADD   1 → regA = 1
                                    (4) ADD   1 → regB = 1
(5) STORE regA → counter = 1
                                    (6) STORE regB → counter = 1

Final result: counter = 1 ✗ (should be 2!)

═══════════════════════════════════════════════════════════════════════════
VISUAL TIMELINE:
═══════════════════════════════════════════════════════════════════════════

Time    Thread A              Memory            Thread B
────    ────────              ──────            ────────

 t0     LOAD (0)              counter=0                         
        regA ← 0                               
                                               
 t1                           counter=0         LOAD (0)
                                                regB ← 0
                                               
 t2     ADD                   counter=0                
        regA = 1                               
                                               
 t3                           counter=0         ADD
                                                regB = 1
                                               
 t4     STORE                 counter=1                
        counter ← regA                         
                                               
 t5                           counter=1         STORE
                                                counter ← regB
                                               
 t6                           counter=1  ← WRONG!
                              (lost an increment)

═══════════════════════════════════════════════════════════════════════════
SOLUTION WITH LOCK:
═══════════════════════════════════════════════════════════════════════════

Thread A                            Thread B
─────────────────────────────────────────────────────────────────
acquire(lock)                       
  (1) LOAD  counter → regA = 0      |
  (2) ADD   1 → regA = 1            |  acquire(lock) → BLOCKED!
  (3) STORE regA → counter = 1      |  (waiting...)
release(lock)                       |
                                    |  (lock available!)
                                    acquire(lock)
                                      (4) LOAD  counter → regB = 1
                                      (5) ADD   1 → regB = 2
                                      (6) STORE regB → counter = 2
                                    release(lock)

Final result: counter = 2 ✓
```

### Diagram 6.2: Critical Section and Properties

```
═══════════════════════════════════════════════════════════════════════════
                    CRITICAL SECTION - STRUCTURE
═══════════════════════════════════════════════════════════════════════════

┌─────────────────────────────────────────────────────────────────────────┐
│                        STANDARD STRUCTURE                               │
│                                                                         │
│   while (true) {                                                        │
│       ┌─────────────────────────────────────────────┐                  │
│       │         ENTRY SECTION                       │                  │
│       │  ─────────────────────────────────          │                  │
│       │  Request access to critical section         │                  │
│       │  Ex: acquire(lock), wait(mutex)             │                  │
│       │  May block if someone is inside             │                  │
│       └─────────────────────────────────────────────┘                  │
│                           │                                             │
│                           ▼                                             │
│       ╔═════════════════════════════════════════════╗                  │
│       ║         CRITICAL SECTION                    ║                  │
│       ║  ═════════════════════════════════          ║                  │
│       ║  Access the shared resource                 ║                  │
│       ║  Ex: counter++, read/write shared data      ║                  │
│       ║                                             ║                  │
│       ║  ⚠️ MAXIMUM ONE PROCESS HERE AT ANY TIME!  ║                  │
│       ╚═════════════════════════════════════════════╝                  │
│                           │                                             │
│                           ▼                                             │
│       ┌─────────────────────────────────────────────┐                  │
│       │         EXIT SECTION                        │                  │
│       │  ─────────────────────────────────          │                  │
│       │  Release access                             │                  │
│       │  Ex: release(lock), signal(mutex)           │                  │
│       │  Allow others to enter                      │                  │
│       └─────────────────────────────────────────────┘                  │
│                           │                                             │
│                           ▼                                             │
│       ┌─────────────────────────────────────────────┐                  │
│       │         REMAINDER SECTION                   │                  │
│       │  ─────────────────────────────────          │                  │
│       │  Code that doesn't access shared resource   │                  │
│       │  Can run in parallel with others            │                  │
│       └─────────────────────────────────────────────┘                  │
│   }                                                                     │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘

═══════════════════════════════════════════════════════════════════════════
THE 3 REQUIRED PROPERTIES:
═══════════════════════════════════════════════════════════════════════════

┌─────────────────────────────────────────────────────────────────────────┐
│                                                                         │
│  1️⃣ MUTUAL EXCLUSION                                                   │
│  ════════════════════                                                   │
│                                                                         │
│  "If process Pi is executing in its critical section,                  │
│   no other process Pj can be in its critical section."                 │
│                                                                         │
│       CS                         CS                                     │
│   ┌─────────┐                ┌─────────┐                               │
│   │         │                │░░░░░░░░░│                               │
│   │   P1    │                │ BLOCKED!│ P2                            │
│   │         │                │░░░░░░░░░│                               │
│   └─────────┘                └─────────┘                               │
│                                                                         │
│   Metaphor: Only one person in the toilet at a time.                   │
│                                                                         │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  2️⃣ PROGRESS                                                            │
│  ════════════                                                           │
│                                                                         │
│  "If no process is in CS and some processes want to enter,             │
│   the selection cannot be postponed indefinitely."                     │
│                                                                         │
│       CS (empty)                                                        │
│   ┌─────────┐        P1: "I want to enter!"                            │
│   │ (empty) │        P2: "Me too!"                                     │
│   │         │                                                           │
│   └─────────┘        → One of them MUST be able to enter!              │
│                                                                         │
│   Metaphor: If the toilet is free and people are waiting,              │
│             someone must be able to enter (it doesn't stay empty).     │
│                                                                         │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  3️⃣ BOUNDED WAITING                                                     │
│  ═══════════════════                                                    │
│                                                                         │
│  "There is a limit on the number of times other processes              │
│   can enter CS after a process has requested access."                  │
│                                                                         │
│   P1 requests access: ┌─────────────────────────────────────┐          │
│                       │ Max N "bypasses" until P1 enters    │          │
│                       └─────────────────────────────────────┘          │
│                                                                         │
│   Metaphor: In a queue, you can't be skipped by infinitely many people.│
│                                                                         │
│   Counter-example (starvation):                                        │
│   P1 waits, but P2, P3, P4... always enter before → P1 starves         │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## Solved Exercises

### Exercise 6.1: Lock Implementation with TAS

The following is pseudocode. `TestAndSet` is assumed to be a single atomic
read-modify-write, and lock release must have the corresponding atomic ordering.
A function assembled from ordinary C loads/stores does not implement atomic TAS.
Use language/platform atomic primitives for executable code.

Problem: Implement a spinlock using Test-and-Set in pseudocode.

Solution:

```c
// Atomic Test-and-Set (provided by hardware)
bool test_and_set(bool *target) {
    bool old = *target;
    *target = true;
    return old;
}

// Spinlock implementation
typedef struct {
    bool locked;
} spinlock_t;

void spinlock_init(spinlock_t *lock) {
    lock->locked = false;
}

void spinlock_acquire(spinlock_t *lock) {
    // Spin until we manage to set locked from false to true
    while (test_and_set(&lock->locked)) {
        // Busy wait (consumes CPU)
        // Optimisation: yield() or pause instruction
    }
    // Now we have the lock!
}

void spinlock_release(spinlock_t *lock) {
    lock->locked = false;
}
```

Property verification:
- Mutual Exclusion: ✅ Only one thread can set locked from false to true
- Progress: ✅ If lock is free (false), TAS will return false and thread enters
- Bounded Waiting: ❌ Not guaranteed! A thread can be "unlucky" and wait indefinitely

---

### Exercise 6.2: Peterson's Algorithm

Problem: Demonstrate that Peterson's algorithm satisfies mutual exclusion for 2 processes.

Solution:

This is sequentially consistent pseudocode: each flag/turn access is atomic
and programme order is preserved. Plain C/C++ shared variables do not meet
that contract; conflicting unsynchronised accesses have undefined behaviour.
An executable C11 version would require appropriately ordered atomic objects
(for this direct proof, sequentially consistent operations), not just `volatile`.

```c
bool flag[2] = {false, false};  // flag[i] = process i wants to enter
int turn;                        // whose turn it is

// Process P0                     // Process P1
flag[0] = true;                  flag[1] = true;
turn = 1;                        turn = 0;
while (flag[1] && turn == 1)     while (flag[0] && turn == 0)
    ; // wait                        ; // wait
// CRITICAL SECTION              // CRITICAL SECTION
flag[0] = false;                 flag[1] = false;
```

Mutual Exclusion Proof:

Consider the current entry attempt of each process. If both have raised their
flags, one of their writes to `turn` is last in the sequentially consistent
order. Suppose P1 writes `turn=0` last. P0 has already raised its flag and
written `turn=1`. Until P0 leaves its critical section and clears its flag,
P1's guard sees `flag[0]=true` and `turn=0`, so P1 cannot enter. The case where
P0 writes last is symmetric.

If P0 passed its guard earlier because P1's flag was false, P1's later entry
attempt raises its flag and writes `turn=0`, yielding to P0 while P0 remains
inside. Therefore an earlier successful guard test cannot invalidate the
argument. We compare the ordering of writes and entry attempts, rather than
treating two guard evaluations at different times as simultaneous. Mutual
exclusion follows under the stated atomic/SC assumptions.

---

## Exam-Style Questions

> ⚠️ **Common mistake:** Students often confuse the order of semaphore operations. Remember: acquire mutex AFTER checking empty/full, release mutex BEFORE signalling. Wrong order causes deadlock!

6.1 (Multiple Choice) ⭐ What is the main difference between spinlock and mutex?
- a) Spinlock is faster
- b) Spinlock does busy-wait, mutex does sleep ✓
- c) Mutex can only be used for 2 processes
- d) Spinlock guarantees bounded waiting

---

6.2 (5p) ⭐⭐⭐ A system has 3 processes P1, P2, P3 accessing a shared counter. Each process increments the counter 1000 times. Initially the counter is 0.

a) What is the correct serial result? Is there a defined expected value without synchronisation?
b) In an SC model with separate atomic load and store steps per increment, what is the minimum final value after all three processes finish? Explain.
c) How do you solve the problem in executable code?

Answer:

**Model boundary:** each increment is `r = counter; r = r + 1; counter = r`,
with separate sequentially consistent atomic loads/stores, private registers,
no overflow and no other writers. This models lost updates. It does not assign
defined semantics to a data race on a plain C/C++ integer.

**a)** Serial execution produces 3000, the maximum in this model. An expected
value requires a probability distribution over interleavings; none is supplied.
There is no justified typical range such as 1000–2500.

**b) The exact minimum is 2.** A complete constructive schedule is:

| Stage | Operation | Counter | Completed increments (A, B, C) |
|---|---|---:|---|
| 1 | B reads 0 for its first increment and pauses before storing | 0 | (0, 0, 0) |
| 2 | A performs 999 complete increments | 999 | (999, 0, 0) |
| 3 | C performs all 1000 increments | 1999 | (999, 0, 1000) |
| 4 | B stores its saved value plus one | 1 | (999, 1, 1000) |
| 5 | A reads 1 for its final increment and pauses before storing | 1 | (999, 1, 1000) |
| 6 | B completes its remaining 999 increments | 1000 | (999, 1000, 1000) |
| 7 | A stores its saved value plus one | 2 | (1000, 1000, 1000) |

For the lower bound, the last store belongs to a process's 1000th increment.
Before its final load, that process has completed an earlier store. All stores
write a positive value; no operation writes zero. Its final load is therefore
at least 1 and its final store at least 2. The construction attains this bound.

**c)** Protect the entire read-modify-write with a mutex, or use one atomic
read-modify-write rather than separate atomic load/store operations. For example,
with `atomic_int counter = 0` in C11, each worker can execute
`atomic_fetch_add_explicit(&counter, 1, memory_order_relaxed)` 1000 times.
After joining all workers, the result is 3000. Relaxed ordering suffices for this
isolated counter, but not automatically for publishing other associated data.

---

# WEEK 7: Synchronisation II (Semaphores)

## Detailed ASCII Diagrams

### Diagram 7.1: Producer-Consumer with Semaphores

```
═══════════════════════════════════════════════════════════════════════════
                    PRODUCER-CONSUMER WITH SEMAPHORES
═══════════════════════════════════════════════════════════════════════════

PROBLEM:
- Buffer of size N
- Producer: puts elements (blocks if buffer full)
- Consumer: takes elements (blocks if buffer empty)

═══════════════════════════════════════════════════════════════════════════

REQUIRED SEMAPHORES:
┌─────────────────────────────────────────────────────────────────────────┐
│  empty = N     // How many EMPTY slots (initially all N are empty)      │
│  full  = 0     // How many elements AVAILABLE (initially none)          │
│  mutex = 1     // Exclusive access to buffer (binary)                   │
└─────────────────────────────────────────────────────────────────────────┘

═══════════════════════════════════════════════════════════════════════════

INITIAL STATE (N=5):
┌─────┬─────┬─────┬─────┬─────┐
│     │     │     │     │     │   Buffer (all empty)
│  -  │  -  │  -  │  -  │  -  │
│     │     │     │     │     │
└─────┴─────┴─────┴─────┴─────┘
  [0]   [1]   [2]   [3]   [4]

empty = 5 ●●●●●        full = 0 (empty)        mutex = 1 ●

═══════════════════════════════════════════════════════════════════════════

PRODUCER ADDS ELEMENT:

    1. wait(empty)    // Take an "empty slot" (empty: 5→4)
    
    empty = 4 ●●●●        full = 0             mutex = 1 ●
    
    2. wait(mutex)    // Enter CS (mutex: 1→0)
    
    empty = 4 ●●●●        full = 0             mutex = 0 (locked)
    
    3. buffer[in] = item; in = (in+1)%N;
    
    ┌─────┬─────┬─────┬─────┬─────┐
    │█████│     │     │     │     │   Element added!
    │ A   │  -  │  -  │  -  │  -  │
    │█████│     │     │     │     │
    └─────┴─────┴─────┴─────┴─────┘
      [0]   [1]   [2]   [3]   [4]
       ↑
      in=1
    
    4. signal(mutex)  // Exit CS (mutex: 0→1)
    
    5. signal(full)   // Announce new element (full: 0→1)
    
    empty = 4 ●●●●        full = 1 ●           mutex = 1 ●

═══════════════════════════════════════════════════════════════════════════

CONSUMER TAKES ELEMENT:

    1. wait(full)     // Take an "available element" (full: 1→0)
    
    empty = 4 ●●●●        full = 0             mutex = 1 ●
    
    2. wait(mutex)    // Enter CS (mutex: 1→0)
    
    3. item = buffer[out]; out = (out+1)%N;
    
    ┌─────┬─────┬─────┬─────┬─────┐
    │     │     │     │     │     │   Element taken!
    │  -  │  -  │  -  │  -  │  -  │
    │     │     │     │     │     │
    └─────┴─────┴─────┴─────┴─────┘
       ↑
      out=1
    
    4. signal(mutex)  // Exit CS (mutex: 0→1)
    
    5. signal(empty)  // Announce free slot (empty: 4→5)
    
    empty = 5 ●●●●●       full = 0             mutex = 1 ●

═══════════════════════════════════════════════════════════════════════════

BLOCKING SCENARIO:

FULL buffer (N=5 elements):
┌─────┬─────┬─────┬─────┬─────┐
│█████│█████│█████│█████│█████│
│  A  │  B  │  C  │  D  │  E  │
│█████│█████│█████│█████│█████│
└─────┴─────┴─────┴─────┴─────┘

empty = 0 (empty!)    full = 5 ●●●●●        mutex = 1 ●

Producer tries: wait(empty)
→ empty = 0, so BLOCKS!
→ Producer sleeps until someone does signal(empty)

Consumer takes element, does signal(empty) → empty = 1
→ Producer wakes up and continues!

═══════════════════════════════════════════════════════════════════════════

⚠️ COMMON MISTAKE - WAIT ORDER:

WRONG:                           CORRECT:
──────                           ───────
wait(mutex)                      wait(empty)     // First check slot
wait(empty) ← DEADLOCK!          wait(mutex)     // Then take mutex

If buffer full:
- Thread takes mutex
- Blocks on empty
- But holds mutex!
- Consumer can't enter to release!
- DEADLOCK!
```

---

## Solved Exercises

### Exercise 7.1: Readers-Writers

Problem: Implement the "readers preference" solution for the readers-writers problem.

Solution:

```c
semaphore rw_mutex = 1;     // Resource access (writers or first/last reader)
semaphore mutex = 1;        // Protects read_count
int read_count = 0;         // How many active readers

void reader() {
    wait(mutex);            // Protect read_count
    read_count++;
    if (read_count == 1)    // First reader?
        wait(rw_mutex);     // Block writers!
    signal(mutex);
    
    // READ DATA (many readers simultaneously)
    
    wait(mutex);
    read_count--;
    if (read_count == 0)    // Last reader?
        signal(rw_mutex);   // Allow writers
    signal(mutex);
}

void writer() {
    wait(rw_mutex);         // Exclusive access
    
    // WRITE DATA (single writer)
    
    signal(rw_mutex);
}
```

Explanation: 
- First reader takes rw_mutex → blocks writers
- Subsequent readers enter directly (rw_mutex already taken)
- Last reader releases rw_mutex
- Writers can only enter when read_count = 0

Problem: Writers can starve if new readers keep arriving!

---

## Exam-Style Questions

7.1 (Multiple Choice) A counting semaphore with initial value 3 can allow:
- a) Maximum 1 process in the critical section
- b) Maximum 3 processes simultaneously in the critical section ✓
- c) Infinite processes
- d) Exactly 3 processes (no fewer)

---

7.2 (5p) Explain the difference between wait() on a semaphore and wait() on a condition variable.

Answer:

| Aspect | Semaphore wait/post | Condition-variable wait/notify |
|---|---|---|
| Associated mutex | No implicit release/reacquire of an unrelated mutex | Wait atomically releases the associated mutex while blocking and reacquires it before returning |
| Stored state | Successful wait acquires a permit; post adds a permit, possibly waking a waiter | Notification does not store a permit for a future waiter; the protected predicate stores the state |
| Return condition | A successful wait acquired a permit; errors/interruption need separate handling | A return does not imply the predicate is true; spurious wakeups and competing waiters are possible |
| Correct pattern | Wait before accessing the counted resource; post after releasing it | Hold the mutex and use `while (!predicate) wait(cv, mutex)` |

```c
// Semaphore pseudocode: a posted permit remains available.
post(sem);             // increments the available permit count
wait(sem);             // later acquires/decrements that permit

// Condition-variable pseudocode: the predicate is the persistent state.
lock(mutex);
while (!ready)
    wait(cv, mutex);   // releases mutex, waits, then reacquires mutex
consume_ready_state();
unlock(mutex);

// Producer:
lock(mutex);
ready = true;
notify(cv);            // wakes a waiter if present; does not store a permit
unlock(mutex);
```

A notification sent before a wait is not remembered by the condition variable.
Checking the predicate under the mutex avoids depending on such a notification.
Do not claim that an unconditional later wait must block forever: spurious
wakeups or later notifications are possible, but neither makes that pattern correct.
References: [POSIX condition wait](https://pubs.opengroup.org/onlinepubs/9799919799/functions/pthread_cond_wait.html),
[sem_wait](https://man7.org/linux/man-pages/man3/sem_wait.3.html) and
[sem_post](https://man7.org/linux/man-pages/man3/sem_post.3.html).

---

# WEEK 8: Deadlock

## Detailed ASCII Diagrams

### Diagram 8.1: Coffman Conditions Visualised

```
═══════════════════════════════════════════════════════════════════════════
                    THE 4 COFFMAN CONDITIONS - VISUALISATION
═══════════════════════════════════════════════════════════════════════════

All 4 conditions MUST be present simultaneously for deadlock!

═══════════════════════════════════════════════════════════════════════════
1️⃣ MUTUAL EXCLUSION
═══════════════════════════════════════════════════════════════════════════

"The resource can be held by at most one process at a time"

    ┌──────────────┐
    │    RESOURCE  │
    │   (printer)  │
    │              │
    │  ┌────────┐  │
    │  │ P1 🔒  │  │  ← P1 holds resource exclusively
    │  └────────┘  │
    │              │
    │   P2 ⏳ P3 ⏳ │  ← P2, P3 waiting
    └──────────────┘

If the resource could be shared (e.g. read-only file), no problem!

═══════════════════════════════════════════════════════════════════════════
2️⃣ HOLD AND WAIT
═══════════════════════════════════════════════════════════════════════════

"Process holds resources and waits for others"

    ┌──────────────────────────────────────┐
    │                P1                     │
    │  ┌─────────┐         ┌─────────┐     │
    │  │   R1    │  wants → │   R2    │     │
    │  │  (has)  │         │(doesn't │     │
    │  │  🔒     │    ⏳    │  have)  │     │
    │  └─────────┘         └─────────┘     │
    └──────────────────────────────────────┘

P1 holds R1 tight and refuses to give it up before receiving R2!

═══════════════════════════════════════════════════════════════════════════
3️⃣ NO PREEMPTION
═══════════════════════════════════════════════════════════════════════════

"Resource cannot be forcibly taken - only the process can release voluntarily"

         P2: "Give me R1!"
              │
              ▼
    ┌─────────────────────┐
    │        P1           │
    │   ┌─────────┐       │
    │   │   R1    │       │  P1: "NO! It's mine!"
    │   │   🔒    │ ✋     │
    │   └─────────┘       │
    └─────────────────────┘
    
    (No one can snatch R1 from P1's hands)

═══════════════════════════════════════════════════════════════════════════
4️⃣ CIRCULAR WAIT
═══════════════════════════════════════════════════════════════════════════

"There is a cycle of waiting"

           P1 ──────(waits for R2)──────▶ P2
            ▲                            │
            │                            │
       (has R1)                     (has R2)
            │                            │
            │                            ▼
           P4 ◀────(waits for R4)────── P3
            │                            ▲
       (has R4)                     (has R3)
            │                            │
            └────(waits for R3)──────────┘

    Cycle: P1→P2→P3→P4→P1
    All waiting, no one can progress → DEADLOCK!

═══════════════════════════════════════════════════════════════════════════
COMPLETE EXAMPLE - DINING PHILOSOPHERS:
═══════════════════════════════════════════════════════════════════════════

5 philosophers, 5 forks, each takes left fork first.

        F0            Each philosopher (P) needs
   P0 ●    ● P1       2 forks to eat.
  F4 │      │ F1
     ●──────●         All take left fork simultaneously:
    P4      P2        
     │      │         P0 takes F0
  F3 ●──────● F2      P1 takes F1
        P3            P2 takes F2
                      P3 takes F3
                      P4 takes F4

Now each waits for right fork:
P0 waits for F1 (held by P1)
P1 waits for F2 (held by P2)
P2 waits for F3 (held by P3)
P3 waits for F4 (held by P4)
P4 waits for F0 (held by P0)

CYCLE: P0→P1→P2→P3→P4→P0 → DEADLOCK!
All have a fork (Hold), all wait for another (Wait), there's a cycle (Circular).
```

### Diagram 8.2: Banker's Algorithm

```
═══════════════════════════════════════════════════════════════════════════
                    BANKER'S ALGORITHM - COMPLETE EXAMPLE
═══════════════════════════════════════════════════════════════════════════

System with 5 processes (P0-P4) and 3 resource types (A, B, C).
Total resources: A=10, B=5, C=7

═══════════════════════════════════════════════════════════════════════════
CURRENT STATE:
═══════════════════════════════════════════════════════════════════════════

        Allocation          Maximum            Need (Max-Alloc)
      ┌────┬────┬────┐   ┌────┬────┬────┐   ┌────┬────┬────┐
      │ A  │ B  │ C  │   │ A  │ B  │ C  │   │ A  │ B  │ C  │
  ┌───┼────┼────┼────┤   ├────┼────┼────┤   ├────┼────┼────┤
  │P0 │ 0  │ 1  │ 0  │   │ 7  │ 5  │ 3  │   │ 7  │ 4  │ 3  │
  ├───┼────┼────┼────┤   ├────┼────┼────┤   ├────┼────┼────┤
  │P1 │ 2  │ 0  │ 0  │   │ 3  │ 2  │ 2  │   │ 1  │ 2  │ 2  │
  ├───┼────┼────┼────┤   ├────┼────┼────┤   ├────┼────┼────┤
  │P2 │ 3  │ 0  │ 2  │   │ 9  │ 0  │ 2  │   │ 6  │ 0  │ 0  │
  ├───┼────┼────┼────┤   ├────┼────┼────┤   ├────┼────┼────┤
  │P3 │ 2  │ 1  │ 1  │   │ 2  │ 2  │ 2  │   │ 0  │ 1  │ 1  │
  ├───┼────┼────┼────┤   ├────┼────┼────┤   ├────┼────┼────┤
  │P4 │ 0  │ 0  │ 2  │   │ 4  │ 3  │ 3  │   │ 4  │ 3  │ 1  │
  └───┴────┴────┴────┘   └────┴────┴────┘   └────┴────┴────┘

Total allocated: A=7, B=2, C=5
Available:       A=3, B=3, C=2

═══════════════════════════════════════════════════════════════════════════
SAFETY ALGORITHM - FINDING SAFE SEQUENCE:
═══════════════════════════════════════════════════════════════════════════

Work = Available = [3, 3, 2]
Finish = [false, false, false, false, false]

ITERATION 1: Search for process with Need ≤ Work
─────────────────────────────────────────
  P0: Need=[7,4,3] ≤ Work=[3,3,2]? NO (7>3)
  P1: Need=[1,2,2] ≤ Work=[3,3,2]? YES! ✓
  
  → P1 can finish
  → Work = Work + Allocation[P1] = [3,3,2] + [2,0,0] = [5,3,2]
  → Finish[P1] = true
  
                    Work = [5, 3, 2]

ITERATION 2:
─────────────────────────────────────────
  P0: Need=[7,4,3] ≤ Work=[5,3,2]? NO
  P2: Need=[6,0,0] ≤ Work=[5,3,2]? NO (6>5)
  P3: Need=[0,1,1] ≤ Work=[5,3,2]? YES! ✓
  
  → P3 can finish
  → Work = [5,3,2] + [2,1,1] = [7,4,3]
  → Finish[P3] = true
  
                    Work = [7, 4, 3]

ITERATION 3:
─────────────────────────────────────────
  P0: Need=[7,4,3] ≤ Work=[7,4,3]? YES! ✓
  
  → P0 can finish
  → Work = [7,4,3] + [0,1,0] = [7,5,3]
  → Finish[P0] = true
  
                    Work = [7, 5, 3]

ITERATION 4:
─────────────────────────────────────────
  P2: Need=[6,0,0] ≤ Work=[7,5,3]? YES! ✓
  
  → P2 can finish
  → Work = [7,5,3] + [3,0,2] = [10,5,5]
  → Finish[P2] = true
  
                    Work = [10, 5, 5]

ITERATION 5:
─────────────────────────────────────────
  P4: Need=[4,3,1] ≤ Work=[10,5,5]? YES! ✓
  
  → P4 can finish
  → Finish[P4] = true

═══════════════════════════════════════════════════════════════════════════
RESULT: SAFE STATE!
═══════════════════════════════════════════════════════════════════════════

Safe sequence: <P1, P3, P0, P2, P4>

All processes can finish in this order.
```

---

## Solved Exercises

### Exercise 8.1: Deadlock Detection

Problem: Draw the allocation graph and determine if deadlock exists.

Processes: P1, P2, P3
Resources: R1 (1 instance), R2 (2 instances), R3 (1 instance)

Current state:
- P1 holds R1, requests R2
- P2 holds one instance of R2, requests R3
- P3 holds R3, requests R1

Solution:

```
Allocation graph:

    P1 ●─────────────→ R2 □□    (P1 requests R2)
       │                │
       │                │ (R2 allocated to P2)
       │                ▼
    R1 □ ←───────────── P2 ●────→ R3 □   (P2 requests R3)
       │                            │
       │ (R1 allocated to P1)       │ (R3 allocated to P3)
       │                            ▼
       └─────────────────────────── P3 ● (P3 requests R1)
       
Cycle: P1 → R2 → P2 → R3 → P3 → R1 → P1

WITH ONE INSTANCE PER RESOURCE: DEADLOCK CONFIRMED!

R2 has 2 instances, but one is held by P2 and the other is free!
→ P1 can receive R2!
→ P1 can finish
→ Releases R1
→ P3 can receive R1
→ P3 can finish
→ ... all can finish

RESULT: NO deadlock (R2 has a free instance).
```

---

## Exam-Style Questions

8.1 (Multiple Choice) Which Coffman condition can be eliminated through "resource ordering"?
- a) Mutual Exclusion
- b) Hold and Wait
- c) No Preemption
- d) Circular Wait ✓

---

8.2 (7p) For the state below, apply the Banker's algorithm to verify if the system is in a safe state.

```
Processes: P0, P1, P2
Resources: A=9, B=3
Allocation: P0=[2,0], P1=[1,1], P2=[2,1]
Maximum:    P0=[4,2], P1=[3,2], P2=[7,2]
```

Answer:

```
1. Calculate Need = Max - Allocation:
   P0: [4,2] - [2,0] = [2,2]
   P1: [3,2] - [1,1] = [2,1]
   P2: [7,2] - [2,1] = [5,1]

2. Calculate Available:
   Total: [9,3]
   Allocated: [2+1+2, 0+1+1] = [5,2]
   Available = [9,3] - [5,2] = [4,1]

3. Safety Algorithm:
   Work = [4,1], Finish = [F, F, F]

   Step 1: Search for Need ≤ Work
   - P0: [2,2] ≤ [4,1]? NO (2>1 for B)
   - P1: [2,1] ≤ [4,1]? YES!
   → P1 finishes, Work = [4,1] + [1,1] = [5,2]

   Step 2:
   - P0: [2,2] ≤ [5,2]? YES!
   → P0 finishes, Work = [5,2] + [2,0] = [7,2]

   Step 3:
   - P2: [5,1] ≤ [7,2]? YES!
   → P2 finishes

4. Safe sequence: <P1, P0, P2>
   
   THE SYSTEM IS IN A SAFE STATE! ✓
```

---

*Continued in the next file with Weeks 9–14...*

---

## Advanced Exercises (Evaluate & Create)

> 💡 **Industry relevance:** Synchronisation bugs are among the hardest to debug in production systems. These exercises simulate real debugging scenarios.

### E2.1: Deadlock Analysis (Evaluate) ⭐⭐⭐⭐
**Difficulty:** Expert | **Time:** ~15 min | **Bloom Level:** Evaluate

A database system uses the following locking protocol for transactions:

```
Transaction T1:          Transaction T2:          Transaction T3:
lock(A)                  lock(B)                  lock(C)
lock(B)                  lock(C)                  lock(A)
// work                  // work                  // work
unlock(B)                unlock(C)                unlock(A)
unlock(A)                unlock(B)                unlock(C)
```

**Task:** Analyse this system for deadlock potential:

a) Draw the resource allocation graph if all transactions start simultaneously
b) Identify if deadlock can occur — if yes, give a specific interleaving
c) Evaluate three different solutions and recommend the best one:
   - Solution 1: Global lock ordering (always acquire A, B, C in alphabetical order)
   - Solution 2: Timeout with retry (abort after 100ms, retry with exponential backoff)
   - Solution 3: Deadlock detection with victim selection (abort youngest transaction)

**Model Answer:**
```
a) Resource Allocation Graph (all started simultaneously):
   
   T1 ──holds──► A ◄──waits── T3
   │                          │
   waits                      holds
   │                          │
   ▼                          ▼
   B ◄──holds── T2 ──waits──► C
   
   CYCLE EXISTS: T1 → B → T2 → C → T3 → A → T1

b) Deadlock interleaving:
   
   Time    T1          T2          T3
   ────────────────────────────────────
   t1      lock(A)✓
   t2                  lock(B)✓
   t3                              lock(C)✓
   t4      lock(B)⏳               
   t5                  lock(C)⏳
   t6                              lock(A)⏳
   
   → DEADLOCK: circular wait established

c) Solution Evaluation:

   SOLUTION 1 - Global Lock Ordering:
   + Prevents deadlock completely (breaks circular wait)
   + No cycle detector required when every locking path follows the order
   + Simple to implement
   - Requires T3 to acquire A before C; T1 and T2 already follow A < B < C
   - Acquire only the needed subset: T2 still uses B then C, not A
   - Changed lock lifetimes can affect contention and must be assessed
   
   SOLUTION 2 - Timeout with Retry:
   + No code changes to lock order
   + Self-healing
   - Wasted work (aborted transactions)
   - Livelock risk with identical timeouts
   - Hard to tune timeout value
   
   SOLUTION 3 - Deadlock Detection:
   + Deadlock only aborts when necessary
   + Minimal wasted work
   - Detection overhead (graph cycle detection)
   - Implementation complexity
   - Requires victim selection policy

   RECOMMENDATION: Solution 1 (Global Lock Ordering)
   
   Rationale: For these known resources, a consistently enforced global
   order removes circular wait. This is a conditional design argument, not
   an automatic compile-time proof or a zero-cost claim. Audit every path,
   including callbacks and error handling. Dynamic resource discovery may
   instead justify timeout/retry or detection, with rollback and victim
   selection requirements made explicit.
```

---

### E2.2: Synchronisation Design (Create) ⭐⭐⭐⭐
**Difficulty:** Expert | **Time:** ~20 min | **Bloom Level:** Create

**Scenario:** Design a thread-safe bounded buffer for a high-frequency trading system with these requirements:

| Requirement | Specification |
|-------------|---------------|
| Buffer size | 1024 messages |
| Producers | Multiple (up to 16 market data feeds) |
| Consumers | Multiple (up to 8 trading algorithms) |
| Latency target | < 1 microsecond for enqueue/dequeue |
| Ordering | FIFO within each producer |
| Overflow policy | Drop oldest message (never block producer) |

**Task:** Design the synchronisation solution:

a) Choose appropriate synchronisation primitives (justify your choice)
b) Provide pseudocode for enqueue() and dequeue() operations
c) Explain how your design meets the latency requirement
d) Discuss trade-offs you made

**Model Answer: contract, reference and remaining performance obligation**

The specified drop-oldest policy is retained. “Never block producer” and the
sub-microsecond target require a progress definition and hardware measurements;
neither follows from the words “atomic” or “lock-free”. A lock-free operation
can be preempted and may retry indefinitely while other operations progress.

**a) Exact abstract contract.** Initially the queue is empty. Treat each operation
as one atomic step: enqueue removes the oldest queued message if capacity 1024
is reached, records that drop, then appends the new message; dequeue returns and
removes the oldest queued message, or reports empty. Concurrent calls must be
linearised consistently with completed-before-invoked ordering. For each producer,
sequential enqueue calls retain FIFO among surviving messages. Concurrent calls
using the same producer ID need an additional defined sequence order. A message
already dequeued is owned by that consumer and cannot be overwritten or counted
as a queued drop. No message is returned twice; consumed and dropped sets are disjoint.

**b) Executable correctness reference (C++17 or later).** The bounded array and
mutex implement this contract without allocating message storage per operation.
It is a reference/oracle for functional tests. Mutex acquisition can block, so
this implementation does **not** satisfy the non-blocking producer requirement
and is not presented as the required production solution.

```cpp
#include <array>
#include <cstddef>
#include <cstdint>
#include <mutex>
#include <optional>

struct Message {
    std::uint32_t producer;
    std::uint64_t sequence;
    std::array<std::byte, 48> payload{};
};

template<std::size_t Capacity = 1024>
class DropOldestReference {
    static_assert(Capacity > 0);
    std::array<Message, Capacity> slots{};
    std::size_t front = 0, count = 0;
    std::mutex mutex;
public:
    // Returns the dropped message, if the queue was full.
    std::optional<Message> enqueue(const Message& message) {
        std::lock_guard<std::mutex> lock(mutex);
        std::optional<Message> dropped;
        if (count == Capacity) {
            dropped = slots[front];
            front = (front + 1) % Capacity;
            --count;
        }
        slots[(front + count) % Capacity] = message;
        ++count;
        return dropped;
    }
    std::optional<Message> dequeue() {
        std::lock_guard<std::mutex> lock(mutex);
        if (count == 0) return std::nullopt;
        Message message = slots[front];
        front = (front + 1) % Capacity;
        --count;
        return message;
    }
};
```

**Why the former sequence-slot sketch is WRONG.** Its slot sequences were
uninitialised. Even if initialised to their indices, inserting 1025 messages
without a consumer overwrites slot 0 while leaving the consumer position at 0;
the subsequent sequence test can report empty despite queued data. A producer
also overwrites non-atomic message storage without proving the consumer no
longer owns it. Initialisation or stronger memory ordering alone cannot repair
that ownership and overflow protocol. This counterexample is retained as the
reason to reject that algorithm rather than as runnable queue code.

**c) Design/performance obligation.** A production candidate must specify slot
claim/publication/reclamation states, atomic linearisation points for dropping
and consuming, safe handling of a paused producer/consumer, sequence wraparound
and the exact progress guarantee. Independently check bounded capacity, no lost
ownership, exactly-once consumption/drop accounting and per-producer surviving
FIFO against the reference. “No wait for a free slot” is weaker than a wait-free
operation: discuss which meaning the requirement needs.

The original illustrative 25 ns mutex, 10–20 cycle atomic, 20–40 cycle barrier
and 30–60 ns total figures have no pinned hardware or benchmark provenance.
They do not establish the <1 µs target. Measure enqueue/dequeue latency
distributions under 16 producers/8 consumers, overflow and preemption, with
specified CPU topology, message size, compiler, affinity and workload. Report
tail latency and drops, not only the mean. A deterministic worst-case guarantee
also requires a scheduling/platform model; no such guarantee is demonstrated here.

**d) Alternatives and recommendation.** Retain the bounded mutex reference for
correctness comparison. For the stated deployment target, evaluate a reviewed
MPMC implementation with an explicitly supported drop-oldest ownership protocol;
an arbitrary overwrite patch to a different queue contract is insufficient.
Per-producer queues or relaxing overflow/progress semantics are alternative
architectures only if the requirements are explicitly changed. No such change,
hardware benchmark or production acceptance is implied by this model answer.

---

*Materials developed by Revolvix for ASE Bucharest — CSIE*
