# Operating Systems - Week 5: Execution Threads

> by Revolvix | ASE Bucharest - CSIE | Year I, Semester 2 | 2025-2026

---

## Weekly Objectives

After completing this week's materials, you will be able to:

1. Define the concept of a thread and differentiate it from a process
2. Compare multithreading models (many-to-one, one-to-one, many-to-many)
3. Explain the advantages and disadvantages of using threads
4. Describe the implementation of threads in Linux (NPTL) and the LWP concept
5. Use the POSIX Threads (pthreads) API conceptually

---

## Applied Context (didactic scenario): Why does the browser have 20+ processes for 5 tabs?

Open Chrome and look in Task Manager. For 5 tabs, you might see 25 processes! Why?

The modern answer: isolation through processes + parallelism through threads. Each tab is a separate process (if one crashes, it does not take down the entire browser). But within each process there are multiple threads: one for rendering, one for JavaScript, one for network and one for the compositor.

This hybrid architecture provides both isolation (between processes) and efficiency (between threads).

> 💡 Think about it: Why do you think Chrome chose separate processes for tabs instead of threads? What risk would have existed with threads?

---

## Course Content (5/14)

### 1. What is a Thread?

#### Formal Definition

> A thread (execution thread) is the basic unit of CPU utilisation. A thread belongs to a process and represents an independent execution sequence within that process. Threads of the same process share the code, global data and resources (open files, heap), but each thread has its own CPU registers, program counter and stack. (Silberschatz et al., 2018)

Formally, a thread T can be defined as:
```
T = (ID, PC, Registers, Stack)  // Own context
P = (Code, Data, Heap, Files)    // Shared with other threads in the process
```

#### Intuitive Explanation

Metaphor: A restaurant kitchen

- The process = The entire kitchen
- The threads = The chefs in the kitchen

The chefs (threads):
- Share: the ingredients (data), the recipes (code), the cooker (resources) and the fridge (heap)
- Have their own: hands (registers), the mind where they left off (PC) and their own position in the kitchen (stack)
- Work in parallel: One chops, another cooks and another plates
- Coordination needed: Not to bump into each other, not to grab the same knife

If a chef makes a serious mistake (corrupt shared memory), the entire kitchen is affected → the difference from processes!

#### Thread vs Process Structure

```
┌─────────────────────────────────────────────────────────────┐
│                         PROCESS                             │
├─────────────────────────────────────────────────────────────┤
│  Code (Text) │ Data (Global) │ Files │ Heap (Shared)       │
├───────────────┬───────────────┬───────────────┬─────────────┤
│   Thread 1    │   Thread 2    │   Thread 3    │   ...       │
│ ┌───────────┐ │ ┌───────────┐ │ ┌───────────┐ │             │
│ │ Thread ID │ │ │ Thread ID │ │ │ Thread ID │ │             │
│ │ Registers │ │ │ Registers │ │ │ Registers │ │             │
│ │ Stack     │ │ │ Stack     │ │ │ Stack     │ │             │
│ │ PC        │ │ │ PC        │ │ │ PC        │ │             │
│ │ State     │ │ │ State     │ │ │ State     │ │             │
│ └───────────┘ │ └───────────┘ │ └───────────┘ │             │
└───────────────┴───────────────┴───────────────┴─────────────┘
```

#### Thread vs Process - Detailed Comparison

| Aspect | Process | Thread |
|--------|--------|--------|
| Address space | Own, isolated | Shared with other threads |
| Creation | Slow (~1-10 ms) | Fast (~10-100 μs) |
| Context switch | Expensive (~1-10 μs + TLB flush) | Cheaper (~0.1-1 μs) |
| Communication | Explicit IPC (pipes, sockets, shm) | Direct shared memory |
| Crash | Affects only the process | Can affect the entire process |
| Memory overhead | Large (~MB per process) | Small (~KB per stack) |
| Isolation | Complete | Minimal |
| Debugging | Easier | More difficult (race conditions) |

---

### 2. Multithreading Models

#### Formal Definition: User Threads vs Kernel Threads

> User-level threads are managed by a library in user space, invisible to the kernel. Kernel-level threads are managed directly by the kernel and can be scheduled on different CPUs.

The fundamental problem: How do we map user threads to kernel threads?

#### Model 1: Many-to-One (N:1)

```
User Threads:    T₁    T₂    T₃    T₄
                  \    |    |    /
                   \   |   |   /
                    \  |  |  /
                     \ | | /
Kernel Thread:       [ K₁ ]
```

Characteristics:
- All user threads → a single kernel thread
- Fast thread switching (in user space)
- Problem: A blocking syscall blocks ALL threads!
- Problem: Cannot exploit multi-core

Historical examples: Green threads (old Java), GNU Pth

#### Model 2: One-to-One (1:1)

```
User Threads:    T₁    T₂    T₃    T₄
                  |     |     |     |
                  |     |     |     |
                  |     |     |     |
Kernel Threads:  K₁    K₂    K₃    K₄
```

Characteristics:
- Each user thread = one kernel thread
- Real parallelism on multi-core
- Blocking syscall affects only one thread
- Overhead: Creation/switch through kernel

Modern examples: Linux NPTL, Windows threads, macOS

#### Model 3: Many-to-Many (M:N)

```
User Threads:    T₁   T₂   T₃   T₄   T₅
                  \   |   /     \   /
                   \  |  /       \ /
Kernel Threads:    K₁   K₂       K₃
```

Characteristics:
- M user threads on N kernel threads (M ≥ N)
- Flexible, scalable
- Complex to implement correctly
- User-level scheduler + Kernel scheduler

Examples: Go goroutines (conceptual), historic Solaris

---

### 3. Benefits of Threads

#### Formal Definition

> Concurrency is the property of a system to have multiple tasks in progress within the same time interval. Parallelism is the simultaneous execution of multiple tasks on different hardware. Threads enable both.

#### Intuitive Explanation

Why threads?

| Benefit | Metaphor | Technical example |
|-----------|----------|----------------|
| Responsiveness | Receptionist answering the phone while a colleague solves the problem | UI thread + worker thread |
| Resource Sharing | Flatmates sharing the fridge | Threads share the heap |
| Economy | Cheaper to hire an assistant than to open a new company | Thread vs Process creation |
| Scalability | More workers can work in parallel | Threads on multiple cores |

#### Cost Comparison (Orders of magnitude)

| Operation | Typical time |
|----------|------------|
| Process creation | 1-10 ms |
| Thread creation | 10-100 μs |
| Process context switch | 1-10 μs + TLB |
| Thread context switch | 0.1-1 μs |
| Function call | 10-100 ns |

---

### 4. Threads in Linux: NPTL

#### Formal Definition

> NPTL (Native POSIX Threads Library) is the modern thread implementation in Linux, which uses the 1:1 model and the clone() system call to create Light-Weight Processes (LWP) that share the address space.

#### Historical Context

| Year | Event |
|----|-----------|
| 1996 | LinuxThreads - first implementation (problematic) |
| 2002 | NPTL developed by Red Hat (Ulrich Drepper, Ingo Molnár) |
| 2003 | NPTL in Linux 2.6, replaces LinuxThreads |
| 2024 | NPTL standard, continuous optimisations (futex) |

#### Mechanism: clone() System Call

```c
// Thread creation in Linux (simplified)
// clone() is the base system call

int flags = CLONE_VM        // Share address space
          | CLONE_FS        // Share filesystem info
          | CLONE_FILES     // Share file descriptors
          | CLONE_SIGHAND   // Share signal handlers
          | CLONE_THREAD    // Same thread group
          | CLONE_SYSVSEM;  // Share SysV semaphores

pid_t tid = clone(thread_function, stack_top, flags, arg);
```

The difference from fork():
- `fork()` = `clone()` with flags that DO NOT share anything
- Thread = `clone()` with flags that share everything (except stack)

#### Visualisation in Linux

```bash
# Threads for a process
ps -eLf | grep firefox | head -5
# PID PPID LWP NLWP CMD
# 1234 1 1234 45 firefox
# 1234 1 1235 45 firefox
# 1234 1 1236 45 firefox
# NLWP = Number of Light-Weight Processes (threads)

# Or
ls /proc/PID/task/
# Each subdirectory = a thread (LWP)

# With htop: press H to see threads
htop

# Thread information
cat /proc/PID/task/TID/status
```

---

### 5. POSIX Threads (Pthreads) API

#### Formal Definition

> POSIX Threads (Pthreads) is the standardised API (IEEE POSIX 1003.1c) for thread programming in UNIX-like systems. It provides functions for creation, synchronisation and thread management.

#### Main Functions

| Function | Purpose |
|---------|------|
| `pthread_create()` | Creates a new thread |
| `pthread_join()` | Waits for a thread to terminate |
| `pthread_exit()` | Terminates the current thread |
| `pthread_self()` | Returns the current thread's ID |
| `pthread_detach()` | Marks a thread as "detached" |
| `pthread_cancel()` | Requests termination of a thread |

#### Conceptual Example (C)

```c
#include <pthread.h>
#include <stdio.h>

void *thread_function(void *arg) {
    int id = *(int*)arg;
    printf("Thread %d: Hello!\n", id);
    return NULL;
}

int main() {
    pthread_t threads[4];
    int ids[4] = {0, 1, 2, 3};
    
    // Create threads
    for (int i = 0; i < 4; i++) {
        pthread_create(&threads[i], NULL, thread_function, &ids[i]);
    }
    
    // Wait for threads
    for (int i = 0; i < 4; i++) {
        pthread_join(threads[i], NULL);
    }
    
    return 0;
}
// Compilation: gcc -pthread program.c -o program
```

#### Python Equivalent

```python
#!/usr/bin/env python3
"""
Threading in Python

Pitfall: Python has GIL (Global Interpreter Lock)!
- For I/O-bound: threads work well
- For CPU-bound: use multiprocessing
"""

import threading
import time
import os

def worker(name: str, duration: float):
    """Function executed by each thread."""
    tid = threading.current_thread().name
    print(f"[{tid}] {name} started (PID: {os.getpid()})")
    time.sleep(duration)  # Simulate I/O
    print(f"[{tid}] {name} finished")

def demonstrate_threads():
    print(f"Main thread PID: {os.getpid()}")
    print(f"Main thread ID: {threading.current_thread().name}")
    
    # Create threads
    threads = []
    for i in range(4):
        t = threading.Thread(
            target=worker, 
            args=(f"Task-{i}", i * 0.5),
            name=f"Worker-{i}"
        )
        threads.append(t)
        t.start()
    
    # Join (wait)
    for t in threads:
        t.join()
    
    print("All threads completed!")

# Thread with result
def worker_with_result(n: int) -> int:
    """Calculates the sum 1..n"""
    return sum(range(1, n+1))

def thread_with_result():
    """Demonstrates obtaining the result."""
    results = {}
    
    def wrapper(n, idx):
        results[idx] = worker_with_result(n)
    
    threads = [
        threading.Thread(target=wrapper, args=(1000000, 0)),
        threading.Thread(target=wrapper, args=(2000000, 1)),
    ]
    
    for t in threads:
        t.start()
    for t in threads:
        t.join()
    
    print(f"Results: {results}")

if __name__ == "__main__":
    demonstrate_threads()
    print("\n" + "="*50 + "\n")
    thread_with_result()
```

---

### 6. Brainstorm: Image Processing Application

The situation: You are developing a desktop application for image processing. The user loads 100 images and applies a filter (blur, resize). Each image takes 500ms to be processed.

Questions:
1. A single thread - how long does it take? Will the UI be responsive?
2. 100 threads (one per image) - is it a good idea?
3. How many threads would you use and why?
4. Threads or processes for this case?

Answers and Solution:

| Approach | Total time | UI | Problem |
|----------|------------|----|----|
| 1 thread | 50 seconds | ❌ Blocked | Poor experience |
| 100 threads | ~6.25s theoretical | ✅ | Large overhead, context switches |
| 8 threads (= cores) | ~6.25s | ✅ | ✅ Optimal |

Practical solution: Thread Pool
```python
from concurrent.futures import ThreadPoolExecutor
import os

with ThreadPoolExecutor(max_workers=os.cpu_count()) as executor:
    results = executor.map(process_image, images)
```

---

### 7. When Threads vs Processes?

| Criterion | Choose Threads | Choose Processes |
|----------|---------------|---------------|
| Frequent communication | ✅ Shared memory | ❌ IPC overhead |
| Isolation needed | ❌ One crash = all | ✅ Complete isolation |
| Security | ❌ Sharing = risk | ✅ Natural sandbox |
| CPU-bound in Python | ❌ GIL limits | ✅ multiprocessing |
| I/O-bound | ✅ Efficient | ~ Similar |
| Different platforms | ~ | ✅ Portability |

---

## Recommended Reading

### OSTEP
- Required: [Chapter 26 - Concurrency: Introduction](https://pages.cs.wisc.edu/~remzi/OSTEP/threads-intro.pdf)
- Required: [Chapter 27 - Thread API](https://pages.cs.wisc.edu/~remzi/OSTEP/threads-api.pdf)

### Tanenbaum
- Chapter 2.2: Threads (pp. 105-120)

---

## Command Summary

| Command | Description |
|---------|-----------|
| `ps -eLf` | List processes with threads |
| `ps -T -p PID` | Threads for a process |
| `ls /proc/PID/task/` | Thread directories |
| `htop` + `H` | Toggle thread display |


---

## Self-Assessment

### Review Questions

1. **[REMEMBER]** What are the 3 multithreading models (many-to-one, one-to-one, many-to-many)? Give an OS example for each.
2. **[UNDERSTAND]** Explain why threads of the same process share heap memory but have separate stacks. What are the advantages and risks?
3. **[ANALYSE]** Analyse the overhead difference between creating a thread and creating a process. Why are threads "lightweight"?

### Mini-challenge (optional)

Write a Python programme that creates 4 threads to calculate the sum of elements in a list, dividing the work between them.

---


---


---

## Nuances and Special Cases

### What we did NOT cover (didactic limitations)

- **Thread-local storage (TLS)**: `__thread` variables that are private per thread.
- **Futex**: Fast userspace mutex - the low-level mechanism for synchronisation in Linux.
- **Green threads / Coroutines**: Threads in userspace (Go goroutines, Python asyncio).

### Common Mistakes to Avoid

1. **Global variables without protection**: Any shared variable requires synchronisation.
2. **Threads for blocking I/O**: Use async I/O or thread pools, not one thread per connection.
3. **Assuming execution order**: Without synchronisation, the order is non-deterministic.

### Open Questions Remaining

- Will coroutines (async/await) replace threads for most applications?
- How do embedded systems with limited resources handle multithreading?

## Looking Ahead

**Week 6: Synchronisation (Part 1)** — Threads share memory, so race conditions can occur. We will learn about the critical section, Peterson's algorithm and the basic mechanisms for protection: locks and mutex.

**Recommended preparation:**
- Think about race condition scenarios from real life
- Read OSTEP Chapters 28-29 (Locks)

## Visual Summary

```
┌─────────────────────────────────────────────────────────────────┐
│                    WEEK 5: THREADS — RECAP                      │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  THREAD = Unit of execution within a process                   │
│                                                                 │
│  PROCESS vs THREAD                                              │
│  ├── Process: separate address space, high overhead            │
│  └── Thread: shares memory, low overhead                       │
│                                                                 │
│  WHAT DO THREADS SHARE?                                         │
│  ├── YES: Code, Global data, Heap, File descriptors            │
│  └── NO: Stack, Registers, Thread ID                           │
│                                                                 │
│  MULTITHREADING MODELS                                          │
│  ├── Many-to-One: user threads → 1 kernel thread               │
│  ├── One-to-One: 1 user thread → 1 kernel thread (Linux)       │
│  └── Many-to-Many: M user threads → N kernel threads           │
│                                                                 │
│  THREAD ADVANTAGES                                              │
│  ├── Responsive: UI thread + worker threads                    │
│  ├── Resource sharing: efficient communication                 │
│  └── Scalability: exploits multi-core                          │
│                                                                 │
│  💡 TAKEAWAY: Threads = easy parallelism, but synchronisation! │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

*Materials developed by Revolvix for ASE Bucharest - CSIE*  
*Operating Systems | Year I, Semester 2 | 2025-2026*

## Scripting in Context (Bash + Python): Threads vs Processes (concurrency vs parallelism)

### Included Files

- Python: `scripts/threads_vs_processes.py` — Compares threads and processes on CPU-bound workload.
- Bash: `scripts/run_threads_bench.sh` — Runs the benchmark multiple times and collects output.

### Quick Run

```bash
./scripts/run_threads_bench.sh -r 3 --workers 4 --n 20000
```

### Connection to This Week's Concepts

- Threads share address space; processes are isolated. In practice, this means a trade-off between performance and isolation.
- In Python, GIL is a runtime detail that makes the didactic experiment even more interesting: the OS can offer parallelism, but the runtime can impose constraints.

### Recommended Practice

- run the scripts first on a test directory (not on critical data);
- save the output to a file and attach it to your report/assignment if required;
- note the kernel version (`uname -r`) and Python version (`python3 --version`) when comparing results.

*Materials developed by Revolvix for ASE Bucharest - CSIE*  
*Operating Systems | Year I, Semester 2 | 2025-2026*
