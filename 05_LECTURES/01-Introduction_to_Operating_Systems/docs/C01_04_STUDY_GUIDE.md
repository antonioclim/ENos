# Study Guide — Introduction to Operating Systems

> Course 01 | Self-study resource and exam preparation

---

## Key Concepts Checklist

Before moving to Week 2, ensure you can:

- [ ] **Define** an operating system using both the "extended machine" and "resource manager" perspectives
- [ ] **List** the five core OS functions (process, memory, file, I/O, security management)
- [ ] **Compare** monolithic, microkernel and hybrid architectures with examples
- [ ] **Explain** why batch processing was revolutionary in the 1950s
- [ ] **Execute** basic system inspection commands on Linux

---

## Essential Definitions

| Term | Definition | Example |
|------|------------|---------|
| **Operating System** | Software that manages hardware resources and provides services to applications | Linux, Windows, macOS |
| **Kernel** | Core component of OS that runs in privileged mode | Linux kernel 6.x |
| **System Call** | Interface for applications to request OS services | `open()`, `read()`, `fork()` |
| **Process** | Instance of a running programme with its own address space | Each Chrome tab |
| **Virtualisation** | Abstraction of hardware resources to create isolated environments | VirtualBox, Docker |

---

## Commands to Master

```bash
# System identification
uname -a                    # Full system information
uname -r                    # Kernel version only
cat /etc/os-release         # Distribution details

# Process inspection
ps aux                      # List all processes
ps aux | wc -l              # Count processes
htop                        # Interactive process viewer (install: apt install htop)

# Hardware information
cat /proc/cpuinfo | grep "model name" | head -1    # CPU model
cat /proc/meminfo | grep -E "MemTotal|MemFree"     # Memory stats
lscpu                       # CPU architecture details

# System call tracing
strace ls 2>&1 | head -20   # Trace syscalls of 'ls'
strace -c ls                # Syscall statistics

# Filesystem exploration
ls /proc/$$                 # Current process info
cat /proc/$$/status         # Detailed process status
cat /proc/uptime            # System uptime in seconds
```

---

## Self-Assessment Questions

### Recall (Remember)

1. What year was UNIX created and by whom?
2. Name three examples of monolithic kernel operating systems.
3. What does the acronym IPC stand for in the context of microkernels?

### Comprehension (Understand)

4. Why can't user applications access hardware directly in modern operating systems?
5. Explain the difference between kernel space and user space.
6. Why is a microkernel potentially more reliable than a monolithic kernel?

### Application (Apply)

7. Given that batch processing increased CPU utilisation from 30% to 90%, calculate the improvement factor.
8. You observe a process in "sleeping" state. What might it be waiting for?

### Analysis (Analyse)

9. Compare the trade-offs between monolithic and microkernel architectures in terms of performance and fault isolation.
10. Why might an embedded system designer choose a different kernel architecture than a desktop OS designer?

---

## Answers to Self-Assessment

<details>
<summary>Click to reveal answers</summary>

1. 1969, Ken Thompson and Dennis Ritchie at Bell Labs
2. Linux, FreeBSD, traditional UNIX (also acceptable: Solaris, AIX)
3. Inter-Process Communication
4. Direct hardware access would allow applications to interfere with each other and crash the system; the OS provides protected abstractions
5. Kernel space: privileged mode with full hardware access; User space: restricted mode where applications run
6. Components run in isolation; a bug in the file server doesn't crash the whole system
7. 90/30 = 3x improvement (or 60 percentage points increase)
8. I/O operation (disk read/write, network), waiting for user input, or waiting for a lock/semaphore
9. Monolithic: faster (direct function calls) but one bug crashes everything; Microkernel: slower (IPC overhead) but fault isolation
10. Embedded: real-time guarantees, minimal footprint, formal verification possible (microkernel); Desktop: performance, broad hardware support, legacy compatibility (monolithic/hybrid)

</details>

---

## Common Exam Mistakes

| Mistake | Correction |
|---------|------------|
| "Linux is an operating system" | Linux is a *kernel*; GNU/Linux or a distribution (Ubuntu, Fedora) is the full OS |
| "Microkernel is always better" | Trade-off: better isolation but higher IPC overhead |
| "The OS and the GUI are the same" | The desktop environment (GNOME, KDE) is separate from the kernel |
| "Virtual memory = swap space" | Virtual memory is an abstraction; swap is one implementation detail |

---

## Recommended Reading

### Mandatory
- **OSTEP Chapter 2**: [Introduction to Operating Systems](https://pages.cs.wisc.edu/~remzi/OSTEP/intro.pdf) (free PDF)

### Optional but Valuable
- Tanenbaum, *Modern Operating Systems*, Chapter 1 (pp. 1-61)
- [The UNIX Time-Sharing System](https://dsf.berkeley.edu/cs262/unix.pdf) — Ritchie & Thompson's original 1974 paper

### For the Curious
- [Linux Kernel Development](https://www.kernel.org/doc/html/latest/) — official documentation
- [OSDev Wiki](https://wiki.osdev.org/Introduction) — for those who want to build their own OS

---

## Preparation for Week 2

Week 2 covers **Basic OS Concepts**: system calls, interrupts and the kernel-user boundary.

To prepare:
1. Experiment with `strace` on different commands
2. Read about the difference between polling and interrupts
3. Try to identify which operations in your daily computing require system calls

---

## Quick Reference Card

```
┌─────────────────────────────────────────────────────────────────┐
│                    WEEK 1 QUICK REFERENCE                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  OS = Extended Machine + Resource Manager                        │
│                                                                 │
│  5 Functions: Process | Memory | File | I/O | Security          │
│                                                                 │
│  Architectures:                                                 │
│    Monolithic (Linux)  — fast, risky                            │
│    Microkernel (Minix) — isolated, slower                       │
│    Hybrid (Windows NT) — balanced                               │
│                                                                 │
│  History: Batch(1950s) → UNIX(1969) → Linux(1991) → Cloud(now) │
│                                                                 │
│  Key Commands: uname -a | htop | cat /proc/* | strace           │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

*Course 01 | Operating Systems | ASE Bucharest - CSIE | 2025-2026*
