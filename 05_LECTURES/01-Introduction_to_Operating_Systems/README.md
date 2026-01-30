# Operating Systems - Week 1: Introduction to Operating Systems

> by Revolvix | ASE Bucharest - CSIE | Year I, Semester 2 | 2025-2026

---

## Week Objectives

After completing the materials for this week, you will be able to:

1. Define the concept of an operating system and its main functions
2. Explain the role of the OS as an intermediary between hardware and applications and classify OSes according to various criteria
3. Identify the main components of a computer system and their interaction with the OS
4. Describe the historical evolution of operating systems and modern trends

---

## Applied Context (didactic scenario): Why can your phone run 50 applications simultaneously without exploding?

Open your phone and count the applications running in the background: Spotify, WhatsApp, Gmail, Maps, Camera... Perhaps 20, 30, even 50 applications. All "simultaneously". On a processor with 8 cores. How is this possible?

The answer lies in the operating system - that invisible layer of software that juggles your limited resources (processor, memory, battery) and creates the illusion that everything runs perfectly in parallel. Without an OS, each application would need to know exactly how to communicate with each hardware component - a nightmare for developers and users alike.

> 💡 Think about it: What would happen if two applications tried to write simultaneously to the same memory location?

Short answer: chaos. Long answer: we will discuss race conditions and synchronisation in a few weeks. It is one of the most interesting (and frustrating!) topics in OS — the chaos is surprisingly subtle and hard to debug.

---

## Lecture Content (1/14)

### 1. What is an Operating System?

#### Formal Definition (Academic)

> The operating system is a program (or a collection of programs) that acts as an intermediary between the user and the computer hardware, managing hardware resources and providing common services for application programs. (Silberschatz, Galvin & Gagne, 2018)

From a theoretical perspective, the OS fulfils two fundamental roles:
- Extended machine (extended machine): Abstracts hardware complexity
- Resource manager: Efficiently allocates CPU, memory, I/O devices

#### Intuitive Explanation (introductory level)

Imagine you have an orchestra with 100 musicians (the applications) and only 8 instruments (the processor cores). Each musician wants to play, but they cannot all play at once on the same instruments!

> 💡 I have had students who learned Bash in two weeks starting from zero — so it can be done, with consistent practice. Easy, right?


The operating system is the conductor who:
- Decides who plays now and who waits
- Ensures that no one "steals" another's instrument
- Coordinates everything to sound harmonious
- Prevents chaos and quarrels

Without a conductor, each musician would try to snatch the instrument from another's hands → disaster! Without an OS, each application would try to access hardware directly → crash!

#### Historical Context

| Year | Event | Significance |
|------|-------|--------------|
| 1950s | No OS | Programmers used punch cards, one program at a time |
| 1956 | GM-NAA I/O | First OS! General Motors + North American Aviation for IBM 704 |
| 1964 | OS/360 (IBM) | First "universal" OS for a family of computers |
| 1969 | UNIX (Bell Labs) | Ken Thompson & Dennis Ritchie; the basis of modern OSes |
| 1981 | MS-DOS | Microsoft; the dominance of personal computers |
| 1991 | Linux 0.01 | Linus Torvalds; the open-source revolution |
| 2007 | iOS / Android | Mobile OSes dominate |
| 2010s | Containers (Docker) | "OSes" for cloud applications |

> 💡 Fun fact: UNIX was originally written to run a game - "Space Travel"! Thompson wanted a cheaper computer on which to run his game.

#### Structure of a Computer System

```
┌─────────────────────────────────────────────────────────────┐
│                    APPLICATIONS (User Space)                 │
│           Browser, Editor, Spotify, VS Code, etc.            │
├─────────────────────────────────────────────────────────────┤
│                     SYSTEM CALLS                             │
│              (Interface with the Kernel)                     │
├─────────────────────────────────────────────────────────────┤
│                    KERNEL (OS)                               │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐       │
│  │ Processes│ │ Memory   │ │ Files    │ │   I/O    │       │
│  └──────────┘ └──────────┘ └──────────┘ └──────────┘       │
├─────────────────────────────────────────────────────────────┤
│                    HARDWARE                                  │
│           CPU, RAM, Disk, Network, GPU, etc.                │
└─────────────────────────────────────────────────────────────┘
```

---

### 2. Main Functions of the OS

| Function | Description | Linux Example | Metaphor |
|----------|-------------|---------------|----------|
| Process management | Creation, scheduling, termination of processes | `fork()`, `exec()`, scheduler | The conductor who decides who plays |
| Memory management | Allocation and protection of memory | Paging, virtual memory | The librarian who distributes books |
| File management | Organisation and access to persistent data | ext4, permissions, directories | The archivist who organises folders |
| I/O management | Communication with devices | Drivers, buffering | The translator between different languages |
| Security | Protection of resources and users | Authentication, authorisation | The guard who checks credentials |

---

### 3. Types of Operating Systems

#### Classification by purpose

```
                    ┌─────────────────────────────────────────┐
                    │       OPERATING SYSTEMS                 │
                    └───────────────┬─────────────────────────┘
                                    │
        ┌───────────────────────────┼───────────────────────────┐
        │                           │                           │
┌───────▼───────┐          ┌───────▼───────┐          ┌───────▼───────┐
│   DESKTOP     │          │    SERVER     │          │   EMBEDDED    │
├───────────────┤          ├───────────────┤          ├───────────────┤
│ Windows 11    │          │ Ubuntu Server │          │ FreeRTOS      │
│ macOS         │          │ RHEL          │          │ Zephyr        │
│ Ubuntu        │          │ Windows Server│          │ VxWorks       │
│ Fedora        │          │ FreeBSD       │          │ Android (IoT) │
└───────────────┘          └───────────────┘          └───────────────┘
        │                           │                           │
        ▼                           ▼                           ▼
   Interactivity               Throughput                Real-Time
   Response Time              Availability              Low Power
```

#### Classification by architecture

##### a) Monolithic Kernel

```
┌─────────────────────────────────────────┐
│            User Applications            │
├─────────────────────────────────────────┤
│              System Call Interface       │
├─────────────────────────────────────────┤
│   ┌─────────────────────────────────┐   │
│   │          MONOLITHIC KERNEL       │   │
│   │  ┌───────┐ ┌───────┐ ┌───────┐  │   │
│   │  │Process│ │Memory │ │  FS   │  │   │
│   │  │ Mgmt  │ │ Mgmt  │ │ Mgmt  │  │   │
│   │  └───────┘ └───────┘ └───────┘  │   │
│   │  ┌───────┐ ┌───────┐ ┌───────┐  │   │
│   │  │  I/O  │ │Network│ │Security│ │   │
│   │  └───────┘ └───────┘ └───────┘  │   │
│   └─────────────────────────────────┘   │
├─────────────────────────────────────────┤
│              Hardware                    │
└─────────────────────────────────────────┘
```

Examples: Linux, FreeBSD, traditional UNIX

Strengths:
- Excellent performance (direct calls between modules)
- All components in the same address space

Weaknesses:
- A bug can crash the entire system
- Hard to maintain (millions of lines of code)

##### b) Microkernel

```
┌─────────────────────────────────────────┐
│            User Applications            │
├───────┬───────┬───────┬───────┬─────────┤
│  FS   │ Net   │ Driver│ Driver│  ...    │  ← User Space
│Server │Server │   1   │   2   │         │    Servers
├───────┴───────┴───────┴───────┴─────────┤
│           MICROKERNEL                    │
│    (only: scheduling, IPC, basic MM)    │
├─────────────────────────────────────────┤
│              Hardware                    │
└─────────────────────────────────────────┘
```

Examples: Minix, QNX, L4, seL4

Strengths:

- Isolation between components (one server crashes → the rest works)
- Small kernel, easy to formally verify
- Flexibility (services can be reloaded)


Weaknesses:
- Overhead for inter-process communication (IPC)
- Complexity in design

##### c) Hybrid Kernel

Combines elements from both approaches.

Examples: Windows NT, macOS (XNU), BeOS

---

### 4. First OS Algorithm: Batch Processing

#### Formal Definition

> Batch Processing is an execution technique in which jobs are collected, grouped and processed sequentially without manual intervention between them. The user does not interact with the system during execution.

#### Intuitive Explanation

Imagine an automatic car wash:
- Cars (jobs) queue up
- Each car enters the tunnel in turn
- It is washed completely, then exits and the next car enters automatically
- You do not intervene in the process - you just put the car in the queue and wait for the result

Without batch processing (1950s): You had to stand next to the computer, manually load the punch cards, wait, collect the results, load the next program. The computer sat unused between jobs!

With batch processing: The operator loads a stack of jobs in the evening. The computer processes them overnight. In the morning you find all the results.

#### History

| When | What | Who |
|------|------|-----|
| 1956 | First batch system: GM-NAA I/O | General Motors + North American Aviation |
| 1959 | SHARE Operating System | IBM user consortium |
| 1961 | IBSYS for IBM 7090 | IBM |
| 1964 | OS/360 | IBM - the most influential batch OS |

Problem solved: CPU utilisation was ~30% (the rest = idle time between jobs). With batch processing: ~90%+

#### Costs and Trade-offs

| Advantage | Disadvantage |
|-----------|--------------|
| High CPU utilisation | No interactivity |
| Efficient processing of large volumes | Long response time |
| Simple to implement | Error at job 5? You find out after job 100 |
| Good for long computations | Not suitable for interactive applications |

#### Comparative Implementation

| Aspect | Classic mainframe | Modern Linux | Windows |
|--------|-------------------|--------------|---------|
| Implementation | Job Control Language (JCL) | `cron`, `at`, `systemd` | Task Scheduler |
| Level | Kernel + utilities | Userspace daemons | Windows Service |
| Language | Assembler, JCL | C, Bash, Python | C++, PowerShell |

#### Reproduction in Python

```python
#!/usr/bin/env python3
"""
Simplified simulation of a Batch Processing system.
Demonstrates the concept of job queue and sequential execution.
"""

import time
from collections import deque
from dataclasses import dataclass
from typing import Callable

@dataclass
class Job:
    """Represents a job in the batch system."""
    id: int
    name: str
    duration: float  # seconds
    task: Callable[[], str]  # function to execute

class BatchProcessor:
    """
    Simple batch processor.
    
    Concepts demonstrated:

Three things matter here: job queue (FIFO queue), sequential execution without intervention and logging/accounting.


# Usage example
if __name__ == "__main__":
    processor = BatchProcessor()
    
    # Define some jobs
    def calculate_pi():
        time.sleep(0.5)  # Simulate computation
        return "3.14159..."
    
    def sort_data():
        time.sleep(0.3)
        return "Data sorted"
    
    def generate_report():
        time.sleep(0.7)
        return "Report generated"
    
    # Submit jobs (as in the 1950s, without further interaction)
    processor.submit_job(Job(1, "Calculate Pi", 0.5, calculate_pi))
    processor.submit_job(Job(2, "Sort Data", 0.3, sort_data))
    processor.submit_job(Job(3, "Generate Report", 0.7, generate_report))
    
    # Run the batch
    processor.run()
```

Output:
```
[SUBMIT] Job #1 'Calculate Pi' added to queue
[SUBMIT] Job #2 'Sort Data' added to queue
[SUBMIT] Job #3 'Generate Report' added to queue

==================================================
BATCH PROCESSING STARTED
==================================================

[RUNNING] Job #1 'Calculate Pi'...
[DONE] Job #1 completed in 0.50s

[RUNNING] Job #2 'Sort Data'...
[DONE] Job #2 completed in 0.30s

[RUNNING] Job #3 'Generate Report'...
[DONE] Job #3 completed in 0.70s

==================================================
BATCH COMPLETE: 3 jobs in 1.50s
==================================================
```

#### Modern Trends

| Evolution | Description |
|-----------|-------------|
| Cloud Batch | AWS Batch, Azure Batch, Google Cloud Batch |
| Container-based | Kubernetes Jobs, Argo Workflows |
| Serverless | AWS Lambda (triggered batch) |
| ML/AI Pipelines | Apache Airflow, Kubeflow, MLflow |
| Big Data | Apache Spark batch jobs, Hadoop MapReduce |

Batch processing has not disappeared - it has **transformed**! Today:
- ETL jobs run overnight
- ML training on GPU clusters
- Financial reports generated in batch
- Video encoding in the cloud

---

### 5. Brainstorm: The First OS in History

Situation: In the 1950s, computers had no operating systems. Programmers had to manually load their programs on punch cards, wait for execution, collect the results. An IBM 704 computer cost millions of dollars and sat unused for hours between jobs.

Questions for reflection:
1. What main problem needed to be solved?
2. What function would be a priority for the first OS?
3. How would you automate the transition from one program to another?

How it was solved in practice:

General Motors created GM-NAA I/O in 1956 for the IBM 704 - the first OS!

The main function: batch processing - automatic reading of a job from cards, execution and transition to the next job without human intervention.

Result: CPU utilisation increased from ~30% to over 90%.

---

## Practical Demonstrations

### Demo 1: Exploring the system with `neofetch`

```bash
# Installation (if not present)
sudo apt install neofetch -y

# Run
neofetch
```

You will see complete information: OS, kernel, uptime, shell, resolution, CPU, GPU, memory.

### Demo 2: Viewing processes with `htop`

```bash
# Installation
sudo apt install htop -y

# Run
htop
```

What you observe:
- List of processes with PID, user, CPU%, MEM%
- Number of cores and their utilisation
- Total memory vs. used
- Load average

### Demo 3: Exploring `/proc`

```bash
# Kernel version
cat /proc/version

# Time since the system has been running (in seconds)
cat /proc/uptime

# CPU information
cat /proc/cpuinfo | grep "model name" | head -1

# Memory statistics
cat /proc/meminfo | grep -E "MemTotal|MemFree|MemAvailable"

# Current process (our shell)
echo $$  # Shell PID
ls /proc/$$/
cat /proc/$$/status | head -20
```

### Demo 4: System calls with `strace`

```bash
# Installation
sudo apt install strace -y

# Trace what system calls the 'ls' command makes
strace ls 2>&1 | head -30

# Count system calls
strace -c ls 2>&1
```

---

## Recommended Reading

### OSTEP (Operating Systems: Three Easy Pieces)
- Mandatory: [Chapter 2 - Introduction to Operating Systems](https://pages.cs.wisc.edu/~remzi/OSTEP/intro.pdf)
- Optional: Preface and Introductory Dialogue

### Tanenbaum - Modern Operating Systems
- Chapter 1: Introduction (pp. 1-61)

### Additional Resources
- [The Evolution of Operating Systems](https://www.computerhistory.org/revolution/mainframe-computers/7)
- [Linux Journey - Getting Started](https://linuxjourney.com/lesson/linux-history)
- [OSDev Wiki - Introduction](https://wiki.osdev.org/Introduction)

---

## Self-Assessment

### Verification Questions
1. What are the four main functions of an operating system?
2. What difference exists between kernel space and user space?
3. Why can applications not access hardware directly?
4. What are the advantages and disadvantages of a monolithic kernel vs microkernel?
5. What problem did batch processing solve in the 1950s?

> 💡 I have observed that students who draw the diagram on paper before writing the code have much better results.


### Mini-challenge
Open a terminal and answer the following questions using commands:
1. What kernel version is running on your system?
2. How many processes are running at this moment?
3. How much RAM does the system have and how much is being used?
4. What type of architecture does your processor have?

```bash
# Command suggestions
uname -r                          # kernel version
ps aux | wc -l                    # number of processes
free -h                           # RAM
cat /proc/cpuinfo | grep "model name" | head -1
```

---

## Looking Ahead

Week 2: Basic OS Concepts - We analyse the services provided by the OS, system calls and we will see how applications "talk" to the kernel.

Preparation:
- Make sure you have access to an Ubuntu 24.04 system (native, WSL2, or VirtualBox)
- Familiarise yourself with the terminal and basic commands (`ls`, `cd`, `pwd`, `cat`)

---

## New Commands Summary

| Command | Description | Example |
|---------|-------------|---------|
| `uname -a` | Displays system information | `uname -a` |
| `cat /etc/os-release` | Details about the Linux distribution | `cat /etc/os-release` |
| `htop` | Interactive process monitor | `htop` |
| `neofetch` | System information in visual format | `neofetch` |
| `cat /proc/...` | Read information from proc filesystem | `cat /proc/cpuinfo` |
| `free -h` | Displays memory usage | `free -h` |
| `ps aux` | Lists all processes | `ps aux \| head` |
| `strace` | Traces system calls | `strace ls` |

---

## Visual Summary

```
┌─────────────────────────────────────────────────────────────────┐
│                    WEEK 1: RECAP                                 │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  WHAT IS AN OS?                                                 │
│  ├── Intermediary user ↔ hardware                               │
│  ├── Resource manager (CPU, RAM, I/O, Files)                    │
│  └── Extended virtual machine                                   │
│                                                                 │
│  MAIN FUNCTIONS                                                 │
│  ├── Process management (scheduling, creation, termination)     │
│  ├── Memory management (allocation, protection, virtualisation) │
│  ├── File management (organisation, access, persistence)        │
│  ├── I/O management (drivers, buffering)                        │
│  └── Security (authentication, authorisation)                   │
│                                                                 │
│  OS TYPES                                                       │
│  ├── By purpose: Desktop, Server, Embedded, Mobile              │
│  ├── By kernel: Monolithic, Microkernel, Hybrid                 │
│  └── By real-time: RTOS vs General Purpose                      │
│                                                                 │
│  ALGORITHM: BATCH PROCESSING                                    │
│  ├── Definition: Sequential execution without intervention      │
│  ├── Problem solved: CPU utilisation from 30% to 90%+           │
│  ├── History: 1956 - GM-NAA I/O (first OS!)                     │
│  └── Modern: Cloud Batch, Kubernetes Jobs, ML Pipelines         │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

*Materials developed by Revolvix for ASE Bucharest - CSIE*  
*Operating Systems | Year I, Semester 2 | 2025-2026*

## Scripting in Context (Bash + Python): System Inventory and Batch Simulation

### Included Files

- Bash: `scripts/so_diag.sh` — Collects a system report (kernel/CPU/memory/processes).
- Python: `scripts/batch_sim.py` — FCFS simulation for Batch Processing (waiting/turnaround times).

### Quick Run

```bash
./scripts/so_diag.sh -v
./scripts/batch_sim.py 2 1 3.5 0.5
```

### Connection to This Week's Concepts

- In a *batch* system, scheduling is, in its simplest form, an FCFS queue: jobs execute in turn.
- A system report is the first step in observability: before explaining "why it is slow", you must measure.

### Recommended Practice

- first run the scripts on a test directory (not on critical data);
- save the output to a file and attach it to the report/assignment, if required;
- note the kernel version (`uname -r`) and Python version (`python3 --version`) when comparing results.

*Materials developed by Revolvix for ASE Bucharest - CSIE*  
*Operating Systems | Year I, Semester 2 | 2025-2026*
