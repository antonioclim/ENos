# Operating Systems - Week 2: Basic OS Concepts

> by Revolvix | ASE Bucharest - CSIE | Year I, Semester 2 | 2025-2026

---

## Week Objectives

After completing the materials this week, you will be able to:

1. List the main services provided by an operating system
2. Explain the system call mechanism and the user-kernel transition
3. Describe the internal structure of an OS and different architectural approaches
4. Use basic Linux commands for navigation and file management
5. Analyse system calls using tools such as `strace`

---

## Application Context (didactic scenario): How does Linux know you typed 'ls' and not 'rm -rf /'?

When you type `ls` in the terminal and press Enter, what actually happens? The shell (bash) does not have direct access to the disk to read the directory - that would be a security disaster! Instead, it makes a system call to the kernel, politely asking: "Can you tell me what files are in the current directory?"

The kernel checks whether you have the necessary permissions, safely accesses the disk and returns the list. This entire complex dance happens thousands of times per second on your system.

> 💡 Think about it: What would happen if any application could read/write anywhere on disk without kernel permission?

---

## Course Content (2/14)

### 1. Operating System Services

The OS provides services for both users and programmes:

#### User-facing
| Service | Description | Example |
|---------|-------------|---------|
| User interface | CLI or GUI for interaction | bash, GNOME, Windows Explorer |
| Programme execution | Load and run programmes | `./program`, double-click |
| I/O operations | Read/write files, network | `cat file.txt`, download |
| File manipulation | Create, delete, rename | `mkdir`, `rm`, `mv` |
| Communications | Data transfer between processes/systems | pipes, sockets, shared memory |
| Error detection | Identify and report problems | Segfault handling, disk errors |

#### System-facing
| Service | Description | Implementation |
|---------|-------------|----------------|
| Resource allocation | Distribute CPU, memory, I/O | Scheduler, Memory Manager |
| Accounting | Monitor resource usage | `/proc`, cgroups, auditd |
| Protection and security | Process isolation, access control | Permissions, capabilities, SELinux |

---

### 2. System Calls

#### Formal Definition

> A System Call is the programmatic interface through which a user space process requests a service from the operating system kernel. It represents the controlled entry point into kernel mode. (Tanenbaum, 2015)

From an architectural perspective:
- System calls form the kernel API
- They are the only legitimate way for user space to access hardware or protected resources
- Implemented through hardware mechanisms (privileged instructions, trap/interrupt)

#### Intuitive Explanation

Imagine you live in a very secure block of flats:

- You (the application) are the tenant in a flat
- The building administrator (kernel) has access to all areas: basement, roof, utility rooms
- The intercom (system call) is how you ask the administrator for something

When you want to:
- Read the gas meter → You ring the intercom: "Can you tell me the consumption?"
- Access the basement → You ring: "Can I get my bicycle from the storage?"
- Install AC on the facade → You ring: "Am I allowed to mount this?"

Why don't you go directly?
- You don't have the keys (you don't have privileges)
- It would be chaos if all tenants wandered around the basement
- The administrator checks whether you have the right (permissions)

In the system:
- The application (user mode) cannot directly access the hardware
- The kernel (kernel mode) has full access
- System call = the "phone" through which you request access

#### Historical Context

| Year | Event | Significance |
|------|-------|--------------|
| 1960s | Supervisor Call (SVC) on IBM | First instructions for transition to privileged mode |
| 1969 | UNIX System Calls | ~20 initial system calls; influential design |
| 1983 | POSIX standardised | API standardisation for portability |
| 1991 | Linux 0.01 | ~100 system calls |
| 2024 | Linux 6.x | ~450+ system calls |

> 💡 Fun fact: UNIX initially had only ~20 system calls. The "do one thing well" philosophy resulted in simple yet powerful primitives.

#### System Call Mechanism

```
┌─────────────────────────────────────────────────────────────┐
│                      USER SPACE                              │
│                                                              │
│   ┌──────────┐     ┌──────────────────┐                     │
│   │ Program  │────►│ libc wrapper     │                     │
│   │ read()   │     │ (glibc)          │                     │
│   └──────────┘     └────────┬─────────┘                     │
│                             │                                │
│                             ▼                                │
│                    ┌────────────────┐                       │
│                    │ SYSCALL instr  │                       │
│                    │ (or INT 0x80)  │                       │
│                    └────────┬───────┘                       │
├─────────────────────────────┼───────────────────────────────┤
│                      KERNEL │SPACE                           │
│                             ▼                                │
│                    ┌────────────────┐                       │
│                    │ sys_call_table │                       │
│                    │ [__NR_read]    │                       │
│                    └────────┬───────┘                       │
│                             ▼                                │
│                    ┌────────────────┐                       │
│                    │   sys_read()   │                       │
│                    │ (kernel impl)  │                       │
│                    └────────┬───────┘                       │
│                             │                                │
│                             ▼                                │
│                    Return to user space                     │
└─────────────────────────────────────────────────────────────┘
```

Detailed steps:
1. The programme calls the C function `read(fd, buf, count)`
2. The glibc wrapper places arguments in registers and the syscall number in `%rax`
3. The `syscall` instruction (x86-64) or `int 0x80` (x86) triggers a trap
4. The CPU saves state and switches to kernel mode
5. The kernel looks up `sys_call_table[__NR_read]` and executes `sys_read()`
6. The result is placed in `%rax` and returns to user mode

#### System Call Categories

| Category | Linux Examples | Functionality |
|----------|----------------|---------------|
| Processes | `fork()`, `exec()`, `exit()`, `wait()`, `clone()` | Create, execute, terminate |
| Files | `open()`, `read()`, `write()`, `close()`, `stat()` | File I/O operations |
| Directories | `mkdir()`, `rmdir()`, `getdents()`, `chdir()` | Directory manipulation |
| Devices | `ioctl()`, `mmap()` | Device control, memory mapping |
| Information | `getpid()`, `time()`, `uname()`, `getuid()` | Process and system information |
| Communication | `pipe()`, `socket()`, `send()`, `recv()`, `shmget()` | IPC and networking |
| Memory | `brk()`, `mmap()`, `munmap()`, `mprotect()` | Memory management |
| Signals | `kill()`, `signal()`, `sigaction()` | Asynchronous communication |

#### Costs and Trade-offs

| Aspect | Details |
|--------|---------|
| Time cost | ~100-1000 CPU cycles per syscall (context switch) |
| Overhead | Save/restore registers, partial TLB flush |
| Security | Each syscall = permission verification checkpoint |
| Flexibility | Stable API; programmes do not depend on kernel implementation |

Main trade-off: Security vs Performance
- More checks = safer, but slower
- Modern solutions: vDSO (virtual syscalls for safe operations), io_uring

#### Comparative Implementation

| Aspect | Linux | Windows | macOS |
|--------|-------|---------|-------|
| Mechanism | `syscall` (x86-64), `int 0x80` | `syscall`, `int 0x2e` | `syscall` (Mach + BSD) |
| Table | `sys_call_table[]` | SSDT (System Service Descriptor Table) | Mach traps + BSD syscalls |
| Nr. syscalls | ~450 | ~460 (documented) | ~500 (Mach + BSD) |
| Wrapper | glibc | ntdll.dll → kernel32.dll | libSystem.dylib |
| Numbering | Stable between versions | May change | Stable (POSIX) |
| Documentation | Excellent (man pages) | Partial (many undocumented) | Good |

#### Python Reproduction

```python
#!/usr/bin/env python3
"""
System Calls Demonstration - Simulation and Real Access

This script shows:
1. How a system call dispatcher works conceptually
2. How we access syscalls directly from Python (for educational purposes)
"""

import os
import ctypes
import time

# ============================================
# PART 1: Conceptual Simulation
# ============================================

class MockKernel:
    """
    Simplified kernel simulation.
    Demonstrates the concept of a system call table.
    """
    
    # System call numbers (as in Linux)
    SYS_READ = 0
    SYS_WRITE = 1
    SYS_OPEN = 2
    SYS_CLOSE = 3
    SYS_GETPID = 39
    SYS_TIME = 201
    
    def __init__(self):
        self.files = {
            0: ("stdin", "r"),
            1: ("stdout", "w"),
            2: ("stderr", "w"),
        }
        self.next_fd = 3
        self.pid = 12345
        
        # System Call Table - number → function mapping
        self.syscall_table = {
            self.SYS_READ: self._sys_read,
            self.SYS_WRITE: self._sys_write,
            self.SYS_OPEN: self._sys_open,
            self.SYS_CLOSE: self._sys_close,
            self.SYS_GETPID: self._sys_getpid,
            self.SYS_TIME: self._sys_time,
        }
    
    def syscall(self, number: int, *args):
        """
        Entry point for all system calls.
        Equivalent to sys_call_table[number](*args) in the kernel.
        """
        if number not in self.syscall_table:
            raise OSError(f"Invalid syscall number: {number}")
        
        print(f"[KERNEL] Syscall #{number} with args {args}")
        
        # Security checks would be here
        # ...
        
        # Dispatch to handler
        result = self.syscall_table[number](*args)
        
        print(f"[KERNEL] Syscall #{number} returned: {result}")
        return result
    
    def _sys_read(self, fd: int, count: int) -> str:
        """Read from file descriptor."""
        if fd not in self.files:
            return -1  # EBADF
        return f"[data from fd {fd}]"
    
    def _sys_write(self, fd: int, data: str) -> int:
        """Write to file descriptor."""
        if fd not in self.files:
            return -1
        print(f"[OUTPUT fd={fd}]: {data}")
        return len(data)
    
    def _sys_open(self, path: str, flags: str) -> int:
        """Open a file."""
        fd = self.next_fd
        self.files[fd] = (path, flags)
        self.next_fd += 1
        return fd
    
    def _sys_close(self, fd: int) -> int:
        """Close a file descriptor."""
        if fd in self.files and fd > 2:  # Don't close stdin/out/err
            del self.files[fd]
            return 0
        return -1
    
    def _sys_getpid(self) -> int:
        """Return the process PID."""
        return self.pid
    
    def _sys_time(self) -> int:
        """Return current time."""
        return int(time.time())

# Simulation usage
def demo_simulation():
    print("=" * 50)
    print("SYSTEM CALLS SIMULATION")
    print("=" * 50)
    
    kernel = MockKernel()
    
    # Equivalent to: pid = getpid()
    pid = kernel.syscall(MockKernel.SYS_GETPID)
    print(f"\nPID: {pid}\n")
    
    # Equivalent to: fd = open("/tmp/test.txt", "w")
    fd = kernel.syscall(MockKernel.SYS_OPEN, "/tmp/test.txt", "w")
    print(f"Opened file, fd={fd}\n")
    
    # Equivalent to: write(fd, "Hello!")
    written = kernel.syscall(MockKernel.SYS_WRITE, fd, "Hello from syscall!")
    print(f"Wrote {written} bytes\n")
    
    # Equivalent to: close(fd)
    kernel.syscall(MockKernel.SYS_CLOSE, fd)

# ============================================
# PART 2: Real System Calls in Python
# ============================================

def demo_real_syscalls():
    print("\n" + "=" * 50)
    print("REAL SYSTEM CALLS")
    print("=" * 50)
    
    # Python's os module wraps system calls
    
    # getpid() - syscall #39 on Linux x86-64
    print(f"\nos.getpid() = {os.getpid()}")
    
    # time() - syscall #201
    print(f"time.time() = {time.time()}")
    
    # uname() - syscall #63
    uname = os.uname()
    print(f"os.uname() = {uname.sysname} {uname.release}")
    
    # getuid() - syscall #102
    print(f"os.getuid() = {os.getuid()}")
    
    # getcwd() - syscall #79
    print(f"os.getcwd() = {os.getcwd()}")
    
    # For direct syscalls (Linux only):
    print("\n--- Direct syscall via ctypes ---")
    try:
        libc = ctypes.CDLL("libc.so.6")
        
        # getpid via libc
        pid = libc.getpid()
        print(f"libc.getpid() = {pid}")
        
        # Direct syscall (getpid = 39 on x86-64)
        # This is a function that directly calls syscall()
        libc.syscall.restype = ctypes.c_long
        pid_direct = libc.syscall(39)  # __NR_getpid
        print(f"syscall(39) = {pid_direct}")
        
    except OSError as e:
        print(f"(Cannot run on this system: {e})")

# ============================================
# PART 3: Visualisation with strace (similar output)
# ============================================

def demo_strace_output():
    print("\n" + "=" * 50)
    print("OUTPUT SIMILAR TO strace")
    print("=" * 50)
    
    print("""
When you run: strace ls

You will see something like:

execve("/bin/ls", ["ls"], 0x7ffd...) = 0
brk(NULL)                                 = 0x55a8...
openat(AT_FDCWD, "/etc/ld.so.cache", O_RDONLY) = 3
fstat(3, {st_mode=S_IFREG|0644, ...})     = 0
mmap(NULL, 12345, PROT_READ, ...)         = 0x7f...
close(3)                                  = 0
...
write(1, "file1.txt  file2.txt\\n", 22)   = 22
close(1)                                  = 0
exit_group(0)                             = ?

Each line = a system call!
""")

if __name__ == "__main__":
    demo_simulation()
    demo_real_syscalls()
    demo_strace_output()
```

#### Modern Trends in System Calls

| Evolution | Description | Example |
|-----------|-------------|---------|
| vDSO | Virtual Dynamic Shared Object - syscalls in user space for safe operations | `gettimeofday()` without kernel trap |
| **io_uring** | Async I/O with batch submission | Reduces overhead for intensive I/O |
| eBPF | Extend kernel without modules | Observability, networking, security |
| Seccomp | Syscall filtering | Application sandboxing (Docker, Chrome) |
| Kernel bypass | Completely avoid the kernel | DPDK for networking, SPDK for storage |

---

### 3. Operating System Structure

#### Layered Approach

```
Layer N:     User Interface
Layer N-1:   User Programs
...
Layer 3:     I/O Management
Layer 2:     Communication (IPC)
Layer 1:     Memory Management
Layer 0:     Hardware Abstraction
```

Advantage: Modularity, easier debugging
Disadvantage: Overhead when traversing layers, difficult to define layers

#### Virtual Machines

```
┌─────────────────────────────────────────────────────────────┐
│   VM 1           VM 2           VM 3                        │
│ ┌─────────┐   ┌─────────┐   ┌─────────┐                    │
│ │  App    │   │  App    │   │  App    │                    │
│ ├─────────┤   ├─────────┤   ├─────────┤                    │
│ │ Ubuntu  │   │ Windows │   │ FreeBSD │                    │
│ └────┬────┘   └────┬────┘   └────┬────┘                    │
│      │             │             │                          │
├──────┴─────────────┴─────────────┴──────────────────────────┤
│                    HYPERVISOR                                │
│              (VMware, KVM, Hyper-V)                         │
├─────────────────────────────────────────────────────────────┤
│                      HARDWARE                                │
└─────────────────────────────────────────────────────────────┘
```

```bash
# Check if we are in a VM
systemd-detect-virt
# Returns: oracle, vmware, kvm, none, etc.

# Or via dmesg
dmesg | grep -i hypervisor
```

---

### 4. Brainstorm: OS for an Embedded System

Situation: You are designing an OS for an embedded system with only 64KB RAM - a smart thermostat. It needs to control temperature, display on a small screen and communicate via WiFi.

Questions for reflection:
1. Which OS functions would you keep and which would you eliminate?
2. Would you use a monolithic or microkernel architecture?
3. Would you have multitasking or a single task?
4. How would you manage memory with only 64KB?

How it was solved in practice:

Modern embedded systems use RTOS (Real-Time OS) such as FreeRTOS or Zephyr. These have:
- Minimal kernel (<10KB)
- Cooperative or preemptive multitasking
- Only essential functions: simple scheduling, timers, message queues
- No: virtual memory, complex file system, GUI
- Every KB counts!

FreeRTOS example:
```c
// Simple task in FreeRTOS
void vTemperatureTask(void *pvParameters) {
    for (;;) {
        int temp = read_sensor();
        update_display(temp);
        vTaskDelay(1000 / portTICK_PERIOD_MS);  // Sleep 1 sec
    }
}
```

---

## Laboratory/Seminar (Session 1/7)

### TC Materials to Cover
- [ ] TC1a - Introduction to Shell
- [ ] TC1b - Basic Commands
- [ ] TC1c - File System Navigation
- [ ] TC1o - Introduction to getopts

### Practical Exercises

#### Exercise 1: File System Navigation

```bash
# Find current directory
pwd

# List contents
ls
ls -la        # long format, including hidden files
ls -lh        # "human readable" format for sizes

# Change directory
cd /home
cd ~          # shortcut for home
cd ..         # parent directory
cd -          # previous directory

# Create directories
mkdir test_so
mkdir -p project/src/lib    # create parents too

# Create empty files
touch file1.txt
touch project/README.md
```

#### Exercise 2: File Manipulation

```bash
# Copy
cp file1.txt file2.txt
cp -r project project_backup    # recursive copy

# Move/Rename
mv file2.txt archive.txt
mv archive.txt project/

# Delete (CAUTION!)
rm file1.txt
rm -r project_backup            # recursive delete
rm -i file.txt                  # with confirmation

# View contents
cat /etc/hostname
head -5 /etc/passwd
tail -5 /etc/passwd
less /etc/services              # pagination
```

#### Exercise 3: Globbing and Wildcards

```bash
# Create test files
touch file1.txt file2.txt file3.txt script.sh data.csv

# Wildcards
ls *.txt              # all .txt
ls file?.txt          # file + one character + .txt
ls file[12].txt       # file1.txt or file2.txt
ls data.*             # data with any extension
```

#### Exercise 4: Exploring System Calls with `strace`

```bash
# Installation
sudo apt install strace -y

# Watch what 'ls' does
strace ls 2>&1 | head -50

# Count syscalls per type
strace -c ls 2>&1

# Trace an existing process
strace -p PID

# Filter only certain syscalls
strace -e open,read,write ls
```

#### Exercise 5: Introduction to getopts

```bash
#!/bin/bash
# greet.sh

while getopts "n:v" opt; do
    case $opt in
        n) NAME="$OPTARG" ;;
        v) VERBOSE=1 ;;
        *) echo "Usage: $0 [-n name] [-v]"; exit 1 ;;
    esac
done

[[ -n "$VERBOSE" ]] && echo "[VERBOSE] Script started"
echo "Hello, ${NAME:-User}!"
```

---

### Assignment 1: `assignment1_tree.sh`

Deadline: Before the next seminar (Week 4)

Requirements:

Write a Bash script that creates the following directory structure:

```
Projects/
├── Linux/
│   ├── README.txt      # contains "Linux Project"
│   └── src/
├── Windows/
│   ├── README.txt      # contains "Windows Project"
│   └── src/
└── MacOS/
    ├── README.txt      # contains "MacOS Project"
    └── src/
```

Specifications:
- `-d DIRECTORY` - base directory (default: current)
- `-v` - verbose mode
- `-h` - help

Deliverables: `history > assignment1_FirstnameLastname.txt` + script

---

### Project Milestone M1: Team Formation

Requirements:
- [ ] Team formed (3 members)
- [ ] Topic chosen or proposed
- [ ] Git repository created
- [ ] Initial README.md

---

## Recommended Reading

### OSTEP
- Mandatory: [Chapter 4 - Processes](https://pages.cs.wisc.edu/~remzi/OSTEP/cpu-intro.pdf)
- Mandatory: [Chapter 5 - Process API](https://pages.cs.wisc.edu/~remzi/OSTEP/cpu-api.pdf)

### Tanenbaum
- Chapter 1.5-1.7: System Calls, OS Structure

---

## New Commands Summary

| Command | Description | Example |
|---------|-------------|---------|
| `strace` | Trace system calls | `strace ls` |
| `strace -c` | Syscall statistics | `strace -c ls` |
| `mkdir -p` | Create directories recursively | `mkdir -p a/b/c` |
| `touch` | Create empty file | `touch file.txt` |
| `systemd-detect-virt` | Detect virtualisation | `systemd-detect-virt` |


---

## Self-Assessment

### Verification Questions

1. **[REMEMBER]** What is a system call and what is its role in the OS architecture?
2. **[UNDERSTAND]** Explain the difference between user mode and kernel mode. Why is this separation necessary?
3. **[ANALYSE]** Analyse what happens when an application executes `open("/etc/passwd", O_RDONLY)`. What are the steps from user space to kernel and back?

### Mini-challenge (optional)

Run `strace ls -la` and identify the 3 most frequent types of system calls. Explain the role of each.

---


---


---

## Nuances and Special Cases

### What We Did NOT Cover (didactic limitations)

- **vDSO (Virtual Dynamic Shared Object)**: Linux mechanism that allows certain syscalls (e.g. `gettimeofday`) to run in user space, avoiding kernel transition overhead. Advanced optimisation.
- **io_uring**: Modern interface for asynchronous I/O with performance superior to traditional syscalls. Introduced in Linux 5.1.
- **Seccomp-BPF**: Syscall filtering for sandboxing (used by containers, browsers).

### Common Mistakes to Avoid

1. **API vs Syscall confusion**: `printf()` is NOT a syscall; it is a library function that *eventually* calls `write()`.
2. **Ignoring errno**: After a failed syscall, `errno` contains the error code. Always check the return value.
3. **Assuming syscalls are atomic**: Many are not (e.g. `write()` can write partially).

### Open Questions

- How will the syscall interface evolve with heterogeneous hardware (CPU+GPU+NPU)?
- Can WebAssembly System Interface (WASI) replace traditional syscalls for portable applications?

## Looking Ahead

**Week 3: Processes (PCB + fork)** — We will see how the operating system creates and manages processes, using the system call concepts learned today. The `fork()` call is the cornerstone of multitasking in UNIX.

**Recommended preparation:**
- Experiment with `ps aux` and `htop` to see processes in action
- Read OSTEP Chapters 4-5 (Processes)

## Visual Summary

```
┌─────────────────────────────────────────────────────────────────┐
│                    WEEK 2: BASIC CONCEPTS — RECAP               │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  SYSTEM CALLS                                                   │
│  ├── Interface user space ↔ kernel space                       │
│  ├── Mechanism: trap/interrupt → kernel → return               │
│  └── Categories: processes, files, devices, information        │
│                                                                 │
│  EXECUTION MODES                                                │
│  ├── User Mode: limited access, normal applications            │
│  ├── Kernel Mode: full access, privileged code                 │
│  └── Transition: syscall/trap → kernel → return                │
│                                                                 │
│  OS STRUCTURE                                                   │
│  ├── Monolithic: everything in kernel (Linux)                  │
│  ├── Microkernel: services in user space (Minix)               │
│  └── Hybrid: compromise (Windows NT, macOS)                    │
│                                                                 │
│  💡 TAKEAWAY: Every "useful" action goes through system calls  │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

*Materials developed by Revolvix for ASE Bucharest - CSIE*  
*Operating Systems | Year I, Semester 2 | 2025-2026*

## Scripting in Context (Bash + Python): System Calls Observed with strace

### Included Files

- Bash: `scripts/trace_cmd.sh` — Runs a command under `strace` and produces log + statistical summary.
- Python: `scripts/os_open_demo.py` — File copy through `os.open/os.read/os.write` (correlatable with syscalls).

### Quick Run

```bash
./scripts/trace_cmd.sh -e openat,read,write,close -- ./scripts/os_open_demo.py -i /etc/hosts -o /tmp/hosts_copy.txt
```

### Connection to This Week's Concepts

- `strace` shows the user-space → kernel-space transaction: almost every "relevant" action (files, processes, memory) materialises in *system calls*.
- `os.open/os.read/os.write` are a controlled way to produce easily recognisable syscalls.

### Recommended Practice

- First run the scripts on a test directory (not on critical data);
- Save the output to a file and attach it to your report/assignment if required;
- Note the kernel version (`uname -r`) and Python version (`python3 --version`) when comparing results.

*Materials developed by Revolvix for ASE Bucharest - CSIE*  
*Operating Systems | Year I, Semester 2 | 2025-2026*
