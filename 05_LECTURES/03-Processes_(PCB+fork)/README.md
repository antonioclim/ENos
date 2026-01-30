# Operating Systems - Week 3: Processes

> by Revolvix | ASE Bucharest - CSIE | Year I, Semester 2 | 2025-2026

---

## Week Objectives

After completing the materials for this week, you will be able to:

1. Define the concept of process and differentiate it from a program
2. Describe the states of a process and the transitions between them
3. Explain the structure of the Process Control Block (PCB) and its role
4. Demonstrate process operations in Linux using commands and /proc
5. Analyse the process creation algorithm (fork) and its implications

---

## Applied Context (didactic scenario): How can a processor run Spotify, Chrome and VS Code "simultaneously"?

You have a laptop with 4 cores. But in Task Manager you see 200+ processes. How is this possible? The answer: they do not run simultaneously - the processor "juggles" between them so quickly (thousands of times per second) that it creates the illusion of parallelism.

Each switch between processes is called a context switch and takes microseconds. During this time, the OS saves the entire state of the current process and restores the state of the next process. All invisible to you.

> 💡 Think about it: Why do you think a computer "freezes" when it has too many processes?

---

## Course Content (3/14)

### 1. Program vs. Process

#### Formal Definition

> A process is an instance of a program in execution, representing the basic unit of activity in a modern operating system. A process includes the program code, the current state of execution (registers, program counter), the stack, the heap and the allocated resources. (Silberschatz et al., 2018)

Formally, a process P can be defined as a tuple:
```
P = (Code, Data, Stack, Heap, PCB)
```

where PCB (Process Control Block) contains the management metadata.

#### Intuitive Explanation

Imagine a cake recipe (the program) and the act of making the cake (the process):

- The recipe (program): Sits in a book, does nothing by itself, is passive
- The preparation (process): Active action - you have ingredients on the table, oven heated, hands dirty

Key differences:
| Recipe (Program) | Preparation (Process) |
|------------------|----------------------|
| Text on paper | Action in progress |
| A single copy | You can make 5 cakes simultaneously |
| Does not consume resources | Consumes ingredients (memory), oven (CPU) |
| Static | Dynamic - state changes |

Multiple processes from the same program: You can open 3 Chrome windows (3 processes) from the same program `/usr/bin/chrome`.

#### Components of a Process

```
┌─────────────────────────────────────────────────────┐
│              PROCESS ADDRESS SPACE                   │
├─────────────────────────────────────────────────────┤
│  High addresses                                      │
│  ┌─────────────────────────────────────────────┐    │
│  │              KERNEL SPACE                    │    │ (not directly accessible)
│  │          (shared mapping)                    │    │
│  ├─────────────────────────────────────────────┤    │
│  │              STACK                          │    │ ↓ grows downward
│  │         (local variables,                   │    │
│  │          return addresses)                  │    │
│  ├─────────────────────────────────────────────┤    │
│  │                                             │    │
│  │           FREE SPACE                        │    │
│  │                                             │    │
│  ├─────────────────────────────────────────────┤    │
│  │              HEAP                           │    │ ↑ grows upward
│  │         (dynamic allocation:                │    │
│  │          malloc, new)                       │    │
│  ├─────────────────────────────────────────────┤    │
│  │              BSS                            │    │ (uninitialised variables)
│  ├─────────────────────────────────────────────┤    │
│  │              DATA                           │    │ (initialised variables)
│  ├─────────────────────────────────────────────┤    │
│  │              TEXT                           │    │ (executable code)
│  └─────────────────────────────────────────────┘    │
│  Low addresses (0x0)                                │
└─────────────────────────────────────────────────────┘
```

---

### 2. Process States

#### Formal Definition

> The Process State Diagram is a deterministic finite automaton that models the life cycle of a process. States represent distinct stages of execution, and transitions are triggered by system events or scheduler actions.

Formally, the automaton can be described as:
```
M = (Q, Σ, δ, q₀, F)
where:
  Q = {new, ready, running, waiting, terminated}
  Σ = {admitted, dispatch, interrupt, I/O_wait, I/O_done, exit}
  q₀ = new
  F = {terminated}
```

#### Intuitive Explanation

Imagine a **restaurant** where processes are customers:

| State | In the restaurant | Explanation |
|-------|-------------------|-------------|
| NEW | Customer enters the restaurant | Process has been created but is not yet in the system |
| READY | Customer waits in queue | Ready for execution, waiting for CPU |
| RUNNING | Customer is being served | Process runs on CPU |
| WAITING | Customer waits for food | Waiting for I/O or another event |
| TERMINATED | Customer has left | Process has finished |

#### Complete Diagram

```
                    ┌─────────────┐
        create      │             │     terminate
    ─────────────►  │     NEW     │  ─────────────►
                    │             │
                    └──────┬──────┘
                           │ admitted
                           ▼
                    ┌─────────────┐
                    │             │
         ┌─────────►│    READY    │◄─────────┐
         │          │   (queue)   │          │
         │          └──────┬──────┘          │
         │                 │                 │
         │   I/O or event  │ scheduler      │ interrupt
         │   completion    │ dispatch       │ (preemption)
         │                 ▼                 │
         │          ┌─────────────┐          │
         │          │             │          │
         └──────────│   RUNNING   │──────────┘
                    │   (on CPU)  │
                    └──────┬──────┘
                           │ I/O or event wait
                           ▼
                    ┌─────────────┐
                    │             │
                    │   WAITING   │
                    │  (blocked)  │
                    └─────────────┘
```

#### State Codes in Linux

```bash
# View states
ps aux | head -5
# USER PID %CPU %MEM VSZ RSS TTY STAT START TIME COMMAND

# STAT column:
# R = Running or Runnable (in ready queue)
# S = Sleeping (interruptible) - waiting for event
# D = Disk sleep (uninterruptible) - waiting for disk I/O
# T = Stopped (SIGSTOP or debugger)
# Z = Zombie - terminated but parent has not read exit status
# I = Idle kernel thread
# + = foreground process group
# < = high priority
# N = low priority (nice)
# L = pages locked in memory
# s = session leader

# Examples
ps aux | grep -E "^USER|R |D |Z "
```

---

### 3. Process Control Block (PCB)

#### Formal Definition

> Process Control Block (PCB), also called Task Control Block (TCB), is the central data structure that contains all the information necessary for managing a process. The PCB allows the operating system to suspend and resume the execution of a process, performing context switching. (Tanenbaum, 2015)

In Linux, the PCB is the `task_struct` structure in the kernel (defined in `include/linux/sched.h`), with ~700+ fields!

#### Intuitive Explanation

The PCB is like an employee's personal file at HR:

| HR Information | PCB Equivalent |
|----------------|----------------|
| Badge number | PID (Process ID) |
| Employment status | State (running, ready, etc.) |
| Position in company | Priority |
| Current office | Program Counter (where it left off) |
| Documents on desk | CPU Registers |
| Current projects | Open files |
| Allocated budget | Memory limits |
| Direct supervisor | Parent PID |

When the boss (the scheduler) tells you "pause, someone else is coming to the desk", everything on your desk is saved in the file (PCB). When you return, you open the file and continue where you left off.

#### PCB Structure

```
┌─────────────────────────────────────────────┐
│          PROCESS CONTROL BLOCK              │
├─────────────────────────────────────────────┤
│ ┌─────────────────────────────────────────┐ │
│ │ IDENTIFICATION                          │ │
│ │ • PID (Process ID)                      │ │
│ │ • PPID (Parent PID)                     │ │
│ │ • UID, GID (User/Group ID)              │ │
│ │ • Session ID, Process Group             │ │
│ └─────────────────────────────────────────┘ │
│ ┌─────────────────────────────────────────┐ │
│ │ EXECUTION STATE                         │ │
│ │ • State (ready, running, etc.)          │ │
│ │ • Program Counter                       │ │
│ │ • CPU Registers (complete snapshot)     │ │
│ │ • Stack Pointer                         │ │
│ │ • Flags (carry, zero, overflow, etc.)   │ │
│ └─────────────────────────────────────────┘ │
│ ┌─────────────────────────────────────────┐ │
│ │ SCHEDULING                              │ │
│ │ • Priority (nice value, RT priority)    │ │
│ │ • Scheduling class (CFS, RT, etc.)      │ │
│ │ • CPU time used                         │ │
│ │ • Time slice remaining                  │ │
│ └─────────────────────────────────────────┘ │
│ ┌─────────────────────────────────────────┐ │
│ │ MEMORY                                  │ │
│ │ • Page table pointer                    │ │
│ │ • Memory limits                         │ │
│ │ • Memory maps (VMA list)                │ │
│ │ • Shared memory segments                │ │
│ └─────────────────────────────────────────┘ │
│ ┌─────────────────────────────────────────┐ │
│ │ I/O & FILES                             │ │
│ │ • File descriptor table                 │ │
│ │ • Current working directory             │ │
│ │ • Root directory                        │ │
│ │ • umask                                 │ │
│ └─────────────────────────────────────────┘ │
│ ┌─────────────────────────────────────────┐ │
│ │ SIGNALS                                 │ │
│ │ • Pending signals                       │ │
│ │ • Signal handlers                       │ │
│ │ • Signal masks                          │ │
│ └─────────────────────────────────────────┘ │
│ ┌─────────────────────────────────────────┐ │
│ │ ACCOUNTING                              │ │
│ │ • Start time                            │ │
│ │ • User/System CPU time                  │ │
│ │ • Resource usage (rusage)               │ │
│ └─────────────────────────────────────────┘ │
└─────────────────────────────────────────────┘
```

#### Exploration in Linux

```bash
# Current shell PID
echo $$

# Content of the "PCB" visible in /proc
ls /proc/$$/

# Basic information (status)
cat /proc/$$/status | head -30

# Important fields:
# Name: bash ← process name
# State: S (sleeping) ← state
# Pid: 12345 ← PID
# PPid: 12344 ← Parent PID
# Uid: 1000 1000 ← User IDs (real, effective, saved, fs)
# Gid: 1000 1000 ← Group IDs
# VmPeak: 12000 kB ← Peak virtual memory
# VmSize: 11500 kB ← Current virtual memory
# VmRSS: 4000 kB ← Resident Set Size (in RAM)
# Threads: 1 ← Number of threads

# Open file descriptors
ls -la /proc/$$/fd/
# 0 -> /dev/pts/0 (stdin)
# 1 -> /dev/pts/0 (stdout)
# 2 -> /dev/pts/0 (stderr)

# Memory maps
cat /proc/$$/maps | head -10

# Command line
cat /proc/$$/cmdline | tr '\0' ' '

# Current working directory
readlink /proc/$$/cwd

# Executable
readlink /proc/$$/exe
```

---

### 4. The fork() Algorithm: Process Creation

#### Formal Definition

> fork() is a POSIX system call that creates a new process (child) by duplicating the calling process (parent). The child process is an almost identical copy of the parent: it receives copies of the data, heap and stack segments, but shares the code segment (text) and read-only resources through Copy-on-Write (CoW).

Signature:
```c
pid_t fork(void);
// Returns:
//   - In parent: child's PID (> 0)
//   - In child: 0
//   - On error: -1
```

#### Intuitive Explanation

Imagine cell mitosis:
- A cell (the parent process) divides
- Two almost identical cells result
- Each continues to live independently
- They have the same DNA (code) but evolve differently

Or: the magic photocopier
1. You have a folder (the parent process)
2. You make a copy at the photocopier (fork)
3. Now you have 2 identical folders
4. Each can be modified independently

After fork():
- Both processes continue execution from the instruction after `fork()`
- The only difference: the return value
- Parent sees the child's PID
- Child sees 0

#### Historical Context

| Year | Event | Significance |
|------|-------|--------------|
| 1969 | fork() in UNIX v1 | Ken Thompson, Bell Labs |
| 1971 | fork()+exec() model | Separation of creation/execution - influential design |
| 1983 | POSIX standardises fork() | Guaranteed portability |
| 1995 | Linux introduces vfork() | Optimisation for fork+exec |
| 2002 | Copy-on-Write in Linux 2.4+ | Fork becomes O(1) instead of O(n) |
| 2008 | clone() extended | Basis for threads and containers |

> 💡 Fun fact: The fork()+exec() design was considered "temporary" by Thompson, but proved so elegant that it has survived 50+ years!

#### The fork() Mechanism

```
BEFORE FORK:
┌────────────────────────────┐
│      PARENT PROCESS        │
│  PID: 1000                 │
│  ┌─────────┬─────────┐     │
│  │  Code   │  Data   │     │
│  ├─────────┼─────────┤     │
│  │  Heap   │  Stack  │     │
│  └─────────┴─────────┘     │
│  Page Table: PT_parent     │
│  Files: [stdin,stdout,err] │
└────────────────────────────┘

─────────── fork() ───────────

AFTER FORK (Copy-on-Write):
┌────────────────────────┐        ┌────────────────────────┐
│    PARENT PROCESS      │        │     CHILD PROCESS      │
│  PID: 1000             │        │  PID: 1001             │
│  fork() returns: 1001  │        │  fork() returns: 0     │
│                        │        │                        │
│  Page Table: PT_p      │        │  Page Table: PT_c      │
│      │                 │        │      │                 │
│      │   ┌─────────────┴────────┴──────┘                 │
│      │   │                                               │
│      ▼   ▼    PHYSICAL PAGES (shared read-only)         │
│  ┌─────────────────────────────────────────────────┐    │
│  │  Code (RO)  │  Data (CoW)  │  Stack (CoW)      │    │
│  └─────────────────────────────────────────────────┘    │
│                                                          │
│  On first WRITE to a CoW page:                          │
│  → A real copy of the page is made                      │
│  → The modifying process receives its own copy          │
└──────────────────────────────────────────────────────────┘
```

#### Costs and Trade-offs

| Aspect | Details |
|--------|---------|
| Time cost | ~100μs on modern systems (due to CoW) |
| Memory cost | Minimal initially (only page tables), grows on write |
| Overhead | PCB creation, page table copying, signal handler setup |
| Copy-on-Write | Defers actual copying until modification |

Trade-offs:
| Pro | Con |
|-----|-----|
| Simple to use | Costly if child only does exec() |
| Child inherits everything | Memory can grow rapidly if both write |
| Complete isolation | Fork bomb can crash the system |
| Basis for parallelism | Not ideal for threads |

Modern alternative: `clone()` (Linux-specific) allows fine control over what is shared.

#### Comparative Implementation

| Aspect | Linux | Windows | macOS |
|--------|-------|---------|-------|
| System call | `fork()`, `clone()`, `vfork()` | `CreateProcess()` | `fork()` (POSIX) |
| Model | fork()+exec() | Create process with parameters | fork()+exec() |
| CoW | ✅ Complete | N/A (no fork) | ✅ Complete |
| Threads | `clone(CLONE_VM\|...)` | `CreateThread()` | `pthread_create()` |
| Kernel struct | `task_struct` | `EPROCESS` | `proc` |

Why doesn't Windows have fork()?
Windows chose a different model: `CreateProcess()` creates a new process from scratch, specifying the program to run. It's more complex but avoids fork overhead when duplication is not needed.

#### Reproduction in Python and Bash

Python:
```python
#!/usr/bin/env python3
"""
fork() demonstration in Python.

Shows:
- How process duplication works
- The difference between parent and child
- Sharing of open files
- Copy-on-Write in action
"""

import os
import sys
import time

def demonstrate_fork():
    print(f"[Original parent] PID: {os.getpid()}")
    
    # Variable before fork - will be "copied"
    shared_value = 100
    
    print("\n--- Calling fork() ---\n")
    
    pid = os.fork()
    
    if pid < 0:
        print("Fork failed!", file=sys.stderr)
        sys.exit(1)
    
    elif pid == 0:
        # === WE ARE IN THE CHILD PROCESS ===
        print(f"[Child] I am the child! PID: {os.getpid()}, PPID: {os.getppid()}")
        print(f"[Child] fork() returned to me: {pid} (i.e. 0)")
        print(f"[Child] shared_value = {shared_value}")
        
        # We modify the variable - CoW will make a copy
        shared_value = 999
        print(f"[Child] After modification, shared_value = {shared_value}")
        
        time.sleep(1)
        print(f"[Child] Finishing execution.")
        sys.exit(0)  # Note: child must call exit!
    
    else:
        # === WE ARE IN THE PARENT PROCESS ===
        print(f"[Parent] I created child with PID: {pid}")
        print(f"[Parent] I am PID: {os.getpid()}")
        print(f"[Parent] fork() returned to me: {pid}")
        print(f"[Parent] shared_value = {shared_value}")
        
        # We wait for the child to finish
        child_pid, status = os.waitpid(pid, 0)
        print(f"\n[Parent] Child {child_pid} finished with status {status}")
        print(f"[Parent] shared_value still = {shared_value} (CoW!)")

def demonstrate_fork_tree():
    """Creates a process tree."""
    print("\n" + "="*50)
    print("PROCESS TREE")
    print("="*50 + "\n")
    
    print(f"[Root] PID: {os.getpid()}")
    
    for i in range(2):
        pid = os.fork()
        if pid == 0:
            # Child
            print(f"  [Child {i+1}] PID: {os.getpid()}, PPID: {os.getppid()}")
            time.sleep(0.5)
            sys.exit(0)
    
    # Parent waits for all children
    for _ in range(2):
        os.wait()
    
    print("[Root] All children have finished.")

if __name__ == "__main__":
    demonstrate_fork()
    demonstrate_fork_tree()
```

Bash:
```bash
#!/bin/bash
#
# fork demonstration in Bash
# In Bash, fork is done implicitly with & (background) or subshell ()
#

echo "=== Main script PID: $$ ==="

# Method 1: Subshell (implicit fork)
(
    echo "  Subshell PID: $$ (keeps the variable, but is another process)"
    echo "  Subshell PPID: $PPID"
    sleep 1
)

# Method 2: Process in background
echo "Launching process in background..."
sleep 2 &
CHILD_PID=$!
echo "Child launched with PID: $CHILD_PID"

# Method 3: Function in subshell
my_function() {
    echo "  In function, PID: $$"
}

my_function        # Runs in the same process
(my_function)      # Runs in subshell (fork)

# We wait for background processes
wait
echo "All processes have finished."
```

#### Modern Trends

| Evolution | Description |
|----------|-------------|
| clone() | Linux system call with fine control (basis for containers) |
| posix_spawn() | Alternative to fork+exec, more efficient |
| io_uring + clone3 | Asynchronous process creation |
| User namespaces | Fork isolation in containers |
| Checkpoint/Restore | CRIU - "fork" of running processes (for live migration) |

---

### 5. Context Switching

#### Formal Definition

> Context switching is the operation by which the operating system saves the state of the current process and restores the state of another process, enabling multiprogramming and time-sharing.

Formally:
```
context_switch(P_old, P_new):
    save_context(P_old) → PCB_old
    load_context(PCB_new) → CPU_registers
    update_scheduler_state()
```

#### Intuitive Explanation

Imagine you are a teacher for several classes:

1. Saving context: When you leave class A
   - You note on the board where you left off
   - You put the chalk down
   - You close the register at the current page

2. Restoring context: When you enter class B
   - You read from the board where you left off
   - You pick up the chalk
   - You open the register where it was

The cost: Time lost between classes (walking down the corridor, getting oriented).

In CPU: Saving/restoring registers, partial cache invalidation, flushing TLB entries.

#### Context Switch Overhead

```bash
# Measuring context switch time (approximately)
# Using perf (Linux)
sudo perf stat -e context-switches,cpu-migrations sleep 10

# Or with /proc
cat /proc/PID/status | grep ctxt
# voluntary_ctxt_switches: 150
# nonvoluntary_ctxt_switches: 10
```

Typical times:
| System | Context Switch Time |
|--------|---------------------|
| Modern bare-metal | 1-10 μs |
| VM (virtualisation) | 10-100 μs |
| Container | ~1-5 μs (shares kernel) |

---

### 6. Brainstorm: OS Architecture for ATM

Situation: You are designing the OS for a bank ATM. You need to manage: the user interface (screen + keyboard), communication with the bank (network), the receipt printer and the cash dispensing device.

Questions for reflection:
1. How many processes would you create and what responsibility would each have?
2. What state would be most common for the bank communication process?
3. What would happen if the main process crashes during a transaction?

How it was solved in practice:

Modern ATMs use multi-process architecture:

| Process | Responsibility | Dominant state |
|---------|----------------|----------------|
| UI Process | User interaction | Running/Ready |
| Comms Process | Bank connection | Waiting (network) |
| Hardware Process | Peripherals (printer, cash) | Waiting (I/O) |
| Watchdog Process | Monitoring, recovery | Sleeping |

Safety mechanism:
- Atomic transactions (commit/rollback)
- Persistent journal for recovery
- Watchdog restarts fallen processes
- Timeout on all operations

---

## Practical Demonstrations

### Demo 1: Exploring processes with `ps` and `/proc`

```bash
# List current processes
ps aux | head -20

# Process tree
pstree -p $$

# Detailed information about shell
cat /proc/$$/status

# File descriptors
ls -la /proc/$$/fd/

# Memory maps
cat /proc/$$/maps | head -10
```

### Demo 2: Fork in real time

```bash
# In terminal 1: monitoring
watch -n 0.5 'ps --forest -g $$'

# In terminal 2: create processes
bash -c 'echo "Child PID: $$"; sleep 10' &
```

### Demo 3: Zombies and Orphans

```bash
# Create zombie (for demonstration)
bash -c 'bash -c "exit 0" & sleep 30'

# In another terminal
ps aux | grep Z

# Orphan - parent dies first
bash -c 'bash -c "sleep 60" & exit'
ps -ef | grep sleep  # PPID will be 1 (init/systemd)
```

---

## Recommended Reading

### OSTEP
- Mandatory: [Chapter 6 - Limited Direct Execution](https://pages.cs.wisc.edu/~remzi/OSTEP/cpu-mechanisms.pdf)

### Tanenbaum
- Chapter 2.1-2.2: Processes (pages 85-149)

---

## New Commands Summary

| Command | Description | Example |
|---------|-------------|---------|
| `ps aux` | List processes | `ps aux \| grep chrome` |
| `ps --forest` | Process tree | `ps --forest -g $$` |
| `pstree -p` | Tree with PID | `pstree -p $$` |
| `/proc/PID/status` | Visible PCB | `cat /proc/$$/status` |
| `/proc/PID/fd/` | File descriptors | `ls /proc/$$/fd/` |
| `kill -l` | List signals | `kill -l` |


---

## Self-Assessment

### Verification Questions

1. **[REMEMBER]** What information does a PCB (Process Control Block) contain? List at least 5 components.
2. **[UNDERSTAND]** Explain why `fork()` returns different values in the parent process and in the child process. What is the utility of this behaviour?
3. **[ANALYSE]** Compare and contrast `fork()` with `exec()`. In what situations do we use them together and why?

### Mini-challenge (optional)

Write a program that creates a tree of 3 processes (parent → child → grandchild) and displays the PID and PPID of each.

---


---


---

## Nuances and Special Cases

### What we did NOT cover (didactic limitations)

- **clone()**: The real syscall in Linux; `fork()` and `pthread_create()` are actually wrappers over `clone()` with different flags.
- **vfork()**: The "dangerous" variant that shares address space with the parent. Deprecated in favour of `fork()+COW`.
- **Process groups and sessions**: Essential for job control in shell (`fg`, `bg`, `Ctrl+C`).

### Common mistakes to avoid

1. **Zombie processes**: Forgetting `wait()`/`waitpid()` leaves zombie processes that consume PIDs.
2. **Fork bomb**: `:(){ :|:& };:` — understand why it works and set `ulimit -u`.
3. **Expecting fork() to copy instantly**: COW (Copy-on-Write) delays copying until write.

### Open questions remaining

- How do containers (cgroups) optimise fork() behaviour for applications with large cache?
- Why did Google create the `clone3()` syscall in Linux 5.3?

## Looking Ahead

**Week 4: Process Scheduling** — Now that we understand what processes are and how they are created, we will study how the operating system decides which process runs and when. Scheduling algorithms are essential for system performance.

**Recommended preparation:**
- Observe the behaviour of `nice` and `renice` on processes
- Read OSTEP Chapters 7-8 (Scheduling)

## Visual Summary

```
┌─────────────────────────────────────────────────────────────────┐
│                    WEEK 3: PROCESSES — RECAP                    │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  PROCESS = Program in execution                                 │
│  ├── Code + Data + Stack + Heap + Context                       │
│  └── Identified by PID (Process ID)                             │
│                                                                 │
│  PCB (Process Control Block)                                    │
│  ├── PID, PPID, state, registers, memory                        │
│  ├── Counters, priorities, credentials                          │
│  └── Stored in kernel, accessed at context switch               │
│                                                                 │
│  PROCESS STATES: New → Ready ⇄ Running → Terminated             │
│                         ↓↑                                      │
│                       Waiting                                   │
│                                                                 │
│  PROCESS API                                                    │
│  ├── fork(): creates copy (COW)                                 │
│  ├── exec(): replaces image                                     │
│  ├── wait(): waits for child termination                        │
│  └── exit(): terminates process                                 │
│                                                                 │
│  💡 TAKEAWAY: fork() + exec() = the Unix creation pattern       │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

*Materials developed by Revolvix for ASE Bucharest - CSIE*  
*Operating Systems | Year I, Semester 2 | 2025-2026*

## Scripting in context (Bash + Python): Processes, signals, fork/wait

### Included files

- Bash: `scripts/process_tree_demo.sh` — Creates child processes and shows PID/PPID, states and signals.
- Python: `scripts/fork_demo.py` — Demonstrates `fork()` and `waitpid()` (parent/child).

### Quick run

```bash
./scripts/process_tree_demo.sh
./scripts/fork_demo.py
```

### Connection to concepts from this week

- The demonstration with `sleep` makes PID/PPID and process states visible; signals are the standard control mechanism.
- `fork()` + `wait()` explains why states like *zombie* exist and why the parent has responsibilities.

### Recommended practice

- First run the scripts on a test directory (not on critical data);
- Save the output to a file and attach it to the report/assignment if required;
- Note the kernel version (`uname -r`) and Python version (`python3 --version`) when comparing results.

*Materials developed by Revolvix for ASE Bucharest - CSIE*  
*Operating Systems | Year I, Semester 2 | 2025-2026*
