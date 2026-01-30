# OS_course16suppl: eBPF — Observability and Kernel Level Programmability

> **Advanced Supplementary Module** | Operating Systems  
> by Revolvix | ASE Bucharest - CSIE | Year I, Semester 2 | 2025-2026

---

## Contents

1. [Objectives and Competences](#1-objectives-and-competences)
2. [Motivation: Why eBPF?](#2-motivation-why-ebpf)
3. [eBPF Architectural Fundamentals](#3-ebpf-architectural-fundamentals)
4. [Execution Model and Safety Verification](#4-execution-model-and-safety-verification)
5. [Program Types and Attachment Points](#5-program-types-and-attachment-points)
6. [Data Structures: eBPF Maps](#6-data-structures-ebpf-maps)
7. [Development Tooling](#7-development-tooling)
8. [bpftrace: High Performance Dynamic Tracing](#8-bpftrace-high-performance-dynamic-tracing)
9. [BCC: BPF Compiler Collection](#9-bcc-bpf-compiler-collection)
10. [Production Use Cases](#10-production-use-cases)
11. [Security and Operational Considerations](#11-security-and-operational-considerations)
12. [Practical Demonstrations](#12-practical-demonstrations)
13. [Exercises and Challenges](#13-exercises-and-challenges)
14. [References and Further Reading](#14-references-and-further-reading)

---

## 1. Objectives and Competences

### 1.1. Learning Objectives

Upon completion of this module, the student will be able to:

1. **Explain the eBPF architecture** at conceptual and technical level, identifying the fundamental components (virtual machine, verifier, JIT compiler, maps, helper functions)

2. **Analyse the differences** between traditional observability methods (strace, perf, SystemTap) and the eBPF paradigm, arguing the performance and safety advantages

3. **Classify eBPF program types** according to kernel attachment points (kprobes, tracepoints, XDP, tc, cgroup hooks) and applicability domains

4. **Use bpftrace and BCC tools** for diagnosing performance problems in production systems

5. **Implement practical scenarios** for monitoring: I/O latency, network connections, system calls, memory leaks

6. **Evaluate the security implications** of eBPF programs and the protection mechanisms implemented in the kernel

### 1.2. Transversal Competences

- **Systems thinking**: understanding the interactions between user space, kernel and hardware
- **Methodical diagnostics**: structured approach to performance problems
- **Technological adaptability**: familiarisation with emerging technologies in cloud-native infrastructure

---

## 2. Motivation: Why eBPF?

### 2.1. The Observability Problem in Modern Systems

Contemporary systems exhibit exponential complexity: distributed microservices, containerisation, Kubernetes orchestration, frequent inter-process communications. Fundamental questions become difficult to answer:

- *Why is this process consuming 100% CPU?*
- *What is causing the 500ms latency on disk access?*
- *What network connections is this container opening?*
- *Why is memory growing continuously until OOM?*

**Traditional tools** suffer from significant limitations:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    COMPARISON: TRADITIONAL TRACING vs eBPF                  │
├─────────────────────┬─────────────────────────┬─────────────────────────────┤
│     Tool            │       Overhead          │        Limitations          │
├─────────────────────┼─────────────────────────┼─────────────────────────────┤
│ strace              │ 100-1000x slowdown      │ System calls only           │
│                     │ (ptrace syscall)        │ Single process              │
├─────────────────────┼─────────────────────────┼─────────────────────────────┤
│ ltrace              │ ~500x slowdown          │ Library calls only          │
│                     │                         │ Incompatible with PIE/ASLR  │
├─────────────────────┼─────────────────────────┼─────────────────────────────┤
│ perf                │ Moderate (sampling)     │ Statistical, not causal     │
│                     │                         │ Difficult to correlate      │
├─────────────────────┼─────────────────────────┼─────────────────────────────┤
│ SystemTap           │ Variable                │ Kernel modules required     │
│                     │                         │ Risk of kernel panic        │
│                     │                         │ Unsuitable for production   │
├─────────────────────┼─────────────────────────┼─────────────────────────────┤
│ Custom kernel       │ Minimal                 │ Complex development         │
│ modules             │                         │ Maximum security risk       │
│                     │                         │ Long compilation cycle      │
├─────────────────────┼─────────────────────────┼─────────────────────────────┤
│ eBPF                │ ~1-5% (verified safe)   │ Strict verifier             │
│                     │ Negligible overhead     │ Loop/memory limits          │
│                     │                         │ Learning curve              │
└─────────────────────┴─────────────────────────┴─────────────────────────────┘
```

### 2.2. The eBPF Revolution

**eBPF** (extended Berkeley Packet Filter) represents a kernel programming technology that allows execution of verified and safe code in the kernel context, without modifying its source code or loading kernel modules.

**Conceptual analogy**: If the Linux kernel is an operating system, eBPF is the equivalent of JavaScript for the browser — it allows dynamic, verified extensions in a sandboxed environment.

```
┌──────────────────────────────────────────────────────────────────────────────┐
│                           eBPF PARADIGM                                      │
├──────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│   Traditional Code                        eBPF Code                          │
│   ────────────────                        ─────────                          │
│                                                                              │
│   ┌─────────────────┐                  ┌─────────────────┐                   │
│   │  Application    │                  │  Application    │                   │
│   │  (user space)   │                  │  + eBPF Program │                   │
│   └────────┬────────┘                  └────────┬────────┘                   │
│            │                                    │                            │
│            ▼                                    ▼                            │
│   ┌─────────────────┐                  ┌─────────────────┐                   │
│   │  System Call    │                  │  bpf() syscall  │                   │
│   │  Interface      │                  │  load program   │                   │
│   └────────┬────────┘                  └────────┬────────┘                   │
│            │                                    │                            │
│   ─────────┼────────────────          ─────────┼─────────────────            │
│            │    KERNEL                         │    KERNEL                   │
│   ─────────┼────────────────          ─────────┼─────────────────            │
│            │                                    │                            │
│            ▼                                    ▼                            │
│   ┌─────────────────┐                  ┌─────────────────┐                   │
│   │  Kernel code    │                  │  eBPF           │──► Rejected?      │
│   │  (fixed,static) │                  │  Verifier       │    STOP           │
│   └─────────────────┘                  └────────┬────────┘                   │
│                                                 │ Accepted                   │
│                                                 ▼                            │
│                                        ┌─────────────────┐                   │
│                                        │  JIT Compiler   │                   │
│                                        │  → native code  │                   │
│                                        └────────┬────────┘                   │
│                                                 │                            │
│                                                 ▼                            │
│                                        ┌─────────────────┐                   │
│                                        │  Attach to      │                   │
│                                        │  hook (kprobe,  │                   │
│                                        │  tracepoint,    │                   │
│                                        │  XDP, etc.)     │                   │
│                                        └─────────────────┘                   │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘
```

### 2.3. Industry Adoption

eBPF has become the foundation of modern observability:

| Company/Project | eBPF Usage |
|-----------------|------------|
| **Netflix** | Application performance analysis, CPU/memory profiling |
| **Facebook/Meta** | L4 load balancing (Katran), firewall at scale |
| **Google** | Kubernetes monitoring (GKE), runtime security |
| **Cloudflare** | DDoS protection (XDP), packet processing at 10M+ pps |
| **Cilium** | CNI for Kubernetes, network policies without iptables |
| **Falco** | Runtime intrusion detection in containers |
| **Datadog/Dynatrace** | APM (Application Performance Monitoring) |

---

## 3. eBPF Architectural Fundamentals

### 3.1. Historical Evolution

**Classic BPF** (1992, Steven McCanne and Van Jacobson) was initially designed for packet filtering in tcpdump. The original architecture was a simple virtual machine with limited registers and basic arithmetic operations.

**eBPF** (2014, Alexei Starovoitov) radically extends this architecture:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│              BPF → eBPF EVOLUTION                                           │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│   Classic BPF (cBPF)                      eBPF (extended BPF)               │
│   ──────────────────                      ───────────────────               │
│                                                                             │
│   • 2 registers (A, X)                    • 11 registers (R0-R10)           │
│   • 32 bits                               • 64 bits                         │
│   • ~50 instructions                      • ~100+ instructions              │
│   • Packet filtering only                 • Arbitrary kernel events         │
│   • No function calls                     • Helper functions (>150)         │
│   • No persistent state                   • Maps (hash, array, stack, etc.) │
│   • Interpreter only                      • JIT compilation (x86, ARM, etc.)|
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 3.2. Architectural Components

The eBPF architecture consists of five fundamental components:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                      eBPF ARCHITECTURE                                      │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│   USER SPACE                                                                │
│   ══════════                                                                │
│                                                                             │
│   ┌───────────────┐     ┌───────────────┐     ┌───────────────┐            │
│   │  Custom       │     │  bpftrace     │     │  BCC Tools    │            │
│   │  application  │     │  (DSL lang)   │     │  (Python+C)   │            │
│   └───────┬───────┘     └───────┬───────┘     └───────┬───────┘            │
│           │                     │                     │                     │
│           └─────────────────────┼─────────────────────┘                     │
│                                 │                                           │
│                                 ▼                                           │
│                    ┌────────────────────────┐                               │
│                    │   libbpf / libebpf     │                               │
│                    │   (user library)       │                               │
│                    └───────────┬────────────┘                               │
│                                │                                           │
│                                ▼                                           │
│                    ┌────────────────────────┐                               │
│                    │   bpf() system call    │                               │
│                    │   (BPF_PROG_LOAD, etc.)│                               │
│                    └───────────┬────────────┘                               │
│                                │                                           │
│   ══════════════════════════════╪═══════════════════════════════════════    │
│   KERNEL SPACE                 │                                           │
│   ══════════════════════════════│═══════════════════════════════════════    │
│                                │                                           │
│                                ▼                                           │
│   ┌─────────────────────────────────────────────────────────────────────┐   │
│   │                       1. VERIFIER                                   │   │
│   │  ┌──────────────────────────────────────────────────────────────┐  │   │
│   │  │ • Static analysis of bytecode                                │  │   │
│   │  │ • Verifies guaranteed termination (no infinite loops)        │  │   │
│   │  │ • Verifies memory accesses (bounds checking)                 │  │   │
│   │  │ • Verifies register types and legal operations               │  │   │
│   │  │ • Verifies permitted helpers for program type                │  │   │
│   │  │ • Max 1 million instructions verified                        │  │   │
│   │  └──────────────────────────────────────────────────────────────┘  │   │
│   └─────────────────────────────┬───────────────────────────────────────┘   │
│                                 │ Accepted                                  │
│                                 ▼                                           │
│   ┌─────────────────────────────────────────────────────────────────────┐   │
│   │                  2. JIT COMPILER (Just-In-Time)                     │   │
│   │  ┌──────────────────────────────────────────────────────────────┐  │   │
│   │  │ • Transforms eBPF bytecode to native machine code            │  │   │
│   │  │ • Support: x86_64, ARM64, RISC-V, s390x, PowerPC             │  │   │
│   │  │ • Performance comparable to compiled C code                   │  │   │
│   │  │ • Enable: /proc/sys/net/core/bpf_jit_enable                  │  │   │
│   │  └──────────────────────────────────────────────────────────────┘  │   │
│   └─────────────────────────────┬───────────────────────────────────────┘   │
│                                 │                                           │
│                                 ▼                                           │
│   ┌─────────────────────────────────────────────────────────────────────┐   │
│   │                   3. MAPS SYSTEM                                    │   │
│   │  ┌──────────────────────────────────────────────────────────────┐  │   │
│   │  │ • Data structures kernel ↔ user space                        │  │   │
│   │  │ • Types: hash, array, per-CPU, ring buffer, stack, queue     │  │   │
│   │  │ • Persistence between program executions                      │  │   │
│   │  │ • Communication between different eBPF programs               │  │   │
│   │  └──────────────────────────────────────────────────────────────┘  │   │
│   └─────────────────────────────┬───────────────────────────────────────┘   │
│                                 │                                           │
│                                 ▼                                           │
│   ┌─────────────────────────────────────────────────────────────────────┐   │
│   │                  4. HELPER FUNCTIONS                                │   │
│   │  ┌──────────────────────────────────────────────────────────────┐  │   │
│   │  │ • Kernel APIs exposed to eBPF programs                       │  │   │
│   │  │ • bpf_map_lookup_elem(), bpf_probe_read()                    │  │   │
│   │  │ • bpf_get_current_pid_tgid(), bpf_ktime_get_ns()            │  │   │
│   │  │ • bpf_perf_event_output(), bpf_trace_printk()               │  │   │
│   │  │ • >150 helpers available                                     │  │   │
│   │  └──────────────────────────────────────────────────────────────┘  │   │
│   └─────────────────────────────┬───────────────────────────────────────┘   │
│                                 │                                           │
│                                 ▼                                           │
│   ┌─────────────────────────────────────────────────────────────────────┐   │
│   │                5. ATTACHMENT POINTS (Hooks)                         │   │
│   │  ┌──────────────────────────────────────────────────────────────┐  │   │
│   │  │ • kprobes/kretprobes: any kernel function                    │  │   │
│   │  │ • uprobes/uretprobes: user space functions                   │  │   │
│   │  │ • tracepoints: static points in kernel                       │  │   │
│   │  │ • XDP: ultra-fast packet processing                          │  │   │
│   │  │ • tc (traffic control): traffic classification               │  │   │
│   │  │ • cgroup hooks: per container control                        │  │   │
│   │  │ • LSM hooks: Linux security                                  │  │   │
│   │  └──────────────────────────────────────────────────────────────┘  │   │
│   └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 3.3. eBPF Instruction Set

The eBPF virtual machine defines a RISC-like instruction set with the following characteristics:

**Registers**:
- `R0`: return value from program and helpers
- `R1-R5`: function arguments (caller-saved)
- `R6-R9`: callee-saved registers (persist across calls)
- `R10`: frame pointer (read-only, stack)

**Instruction classes**:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    eBPF INSTRUCTION CATEGORIES                              │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ARITHMETIC (ALU64/ALU32)                                                   │
│  ────────────────────────                                                   │
│  add, sub, mul, div, mod    │  Mathematical operations on 64/32 bits       │
│  and, or, xor, lsh, rsh     │  Logical operations and shifts               │
│  neg, mov                   │  Negation, move                               │
│                                                                             │
│  JUMP (JMP)                                                                 │
│  ──────────                                                                 │
│  ja                         │  Unconditional jump                           │
│  jeq, jne, jgt, jlt, jge    │  Conditional jumps (signed/unsigned)         │
│  jset                       │  Jump if bits set                             │
│  call                       │  Helper function call                         │
│  exit                       │  Program termination                          │
│                                                                             │
│  MEMORY (LD/ST)                                                             │
│  ──────────────                                                             │
│  ldx, stx                   │  Load/store from/to memory                    │
│  lddw                       │  Load 64-bit constant                         │
│  Sizes: B(8), H(16), W(32), DW(64) bits                                    │
│                                                                             │
│  ATOMIC                                                                     │
│  ───────                                                                    │
│  lock xadd                  │  Atomic addition                              │
│  lock cmpxchg               │  Atomic compare-and-exchange                  │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

**eBPF bytecode example** (display current PID):

```
; Get current PID and display via trace_printk
r1 = 0                      ; Initialisation
call bpf_get_current_pid_tgid  ; R0 = (tgid << 32) | pid
r1 = r0                     ; Save result
rsh r1, 32                  ; Extract TGID (>>32)
; ... formatting and display ...
exit                        ; Program termination
```

---

## 4. Execution Model and Safety Verification

### 4.1. The eBPF Verifier

The verifier represents the critical security component of the eBPF system. Its function is to guarantee that the loaded program cannot compromise kernel stability or security.

**Verification algorithm** (simplified):

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    eBPF VERIFICATION PROCESS                                │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│   STEP 1: CFG CONSTRUCTION (Control Flow Graph)                             │
│   ─────────────────────────────────────────────                             │
│   • Identifies all possible execution paths                                 │
│   • Detects loops and jumps                                                 │
│   • Verifies that all paths terminate (exit)                                │
│                                                                             │
│   STEP 2: SYMBOLIC SIMULATION                                               │
│   ───────────────────────────                                               │
│   • Traverses EVERY execution path                                          │
│   • Tracks register state at each instruction                               │
│   • Maintains type information for each register:                           │
│     - SCALAR_VALUE: numeric value with known bounds                         │
│     - PTR_TO_MAP_VALUE: pointer to map                                      │
│     - PTR_TO_CTX: pointer to program context                                │
│     - PTR_TO_STACK: pointer to local stack                                  │
│     - PTR_TO_PACKET: pointer to packet data                                 │
│                                                                             │
│   STEP 3: SAFETY CHECKS                                                     │
│   ──────────────────────                                                    │
│   □ Bounds checking: all memory accesses within limits                      │
│   □ Null checking: can pointers be NULL? checked before access              │
│   □ Type safety: operations permitted for register type                     │
│   □ Privileges: helpers permitted for program type                          │
│   □ Complexity: max ~1M instructions (prevents verification DoS)            │
│                                                                             │
│   RESULT                                                                    │
│   ──────                                                                    │
│   ✓ ACCEPTED: program loaded, JIT compiled                                  │
│   ✗ REJECTED: detailed error returned                                       │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 4.2. Rejection Examples

**Case 1: Possible memory access outside bounds**

```c
// REJECTED CODE
int *value = bpf_map_lookup_elem(&my_map, &key);
// Missing NULL check!
*value += 1;  // ERROR: value can be NULL

// CORRECT CODE
int *value = bpf_map_lookup_elem(&my_map, &key);
if (value) {
    *value += 1;  // OK: verified non-NULL
}
```

**Case 2: Potentially infinite loop**

```c
// REJECTED CODE (before bounded loops)
for (int i = 0; i < n; i++) {  // ERROR: n unknown at verification
    // ...
}

// CORRECT CODE
#pragma unroll
for (int i = 0; i < 16; i++) {  // OK: known limit
    if (i >= n) break;
    // ...
}
```

**Case 3: Reading from arbitrary kernel memory**

```c
// REJECTED CODE
char *ptr = (char *)0xffffffff81000000;  // Arbitrary kernel address
char c = *ptr;  // ERROR: unpermitted kernel memory access

// CORRECT CODE (with helper)
char buf[64];
bpf_probe_read_kernel(&buf, sizeof(buf), ptr);  // Verified helper
```

### 4.3. Safety Guarantees

The verifier guarantees the following properties for any accepted program:

1. **Termination**: The program will terminate in finite time (no infinite loops)
2. **Memory safety**: No out-of-bounds accesses exist
3. **Type safety**: Operations are valid for the data types
4. **Isolation**: Cannot read/write arbitrary kernel memory
5. **Stability**: Cannot cause kernel panic

---

## 5. Program Types and Attachment Points

### 5.1. eBPF Program Taxonomy

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    eBPF PROGRAM TYPES                                       │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │                    TRACING AND OBSERVABILITY                        │    │
│  ├─────────────────────────────────────────────────────────────────────┤    │
│  │                                                                     │    │
│  │  KPROBE/KRETPROBE                                                   │    │
│  │  ────────────────                                                   │    │
│  │  • Attach to ANY kernel function                                    │    │
│  │  • kprobe: at function entry                                        │    │
│  │  • kretprobe: at function exit                                      │    │
│  │  • Access to function arguments and return value                    │    │
│  │  • Usage: profiling, debugging, audit                               │    │
│  │  • Example: kprobe:vfs_read for file read monitoring                │    │
│  │                                                                     │    │
│  │  UPROBE/URETPROBE                                                   │    │
│  │  ────────────────                                                   │    │
│  │  • Attach to functions in USER SPACE binaries                       │    │
│  │  • Works with executables and libraries (.so)                       │    │
│  │  • Access to arguments (requires ABI knowledge)                     │    │
│  │  • Example: uprobe:/lib/x86_64-linux-gnu/libc.so.6:malloc          │    │
│  │                                                                     │    │
│  │  TRACEPOINT                                                         │    │
│  │  ──────────                                                         │    │
│  │  • STATIC points defined in kernel code                             │    │
│  │  • Stable ABI (unlike kprobes)                                      │    │
│  │  • Documented argument format                                        │    │
│  │  • Categories: syscalls, sched, net, block, etc.                    │    │
│  │  • Example: tracepoint:syscalls:sys_enter_openat                    │    │
│  │                                                                     │    │
│  │  RAW_TRACEPOINT                                                     │    │
│  │  ──────────────                                                     │    │
│  │  • High-performance version of tracepoints                          │    │
│  │  • Access to raw arguments (no conversion)                          │    │
│  │  • Lower overhead, but more complex to use                          │    │
│  │                                                                     │    │
│  │  PERF_EVENT                                                         │    │
│  │  ──────────                                                         │    │
│  │  • Integration with perf subsystem                                  │    │
│  │  • Hardware events (cache misses, branch mispredictions)            │    │
│  │  • Frequency-based periodic sampling                                 │    │
│  │                                                                     │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │                    NETWORK AND PACKET PROCESSING                    │    │
│  ├─────────────────────────────────────────────────────────────────────┤    │
│  │                                                                     │    │
│  │  XDP (eXpress Data Path)                                            │    │
│  │  ───────────────────────                                            │    │
│  │  • Earliest packet processing point                                 │    │
│  │  • BEFORE sk_buff allocation                                        │    │
│  │  • Performance: 10-20M packets/second per core                      │    │
│  │  • Actions: XDP_DROP, XDP_PASS, XDP_TX, XDP_REDIRECT               │    │
│  │  • Use cases: DDoS mitigation, L4 load balancing                    │    │
│  │                                                                     │    │
│  │        Packet processing order:                                     │    │
│  │        ────────────────────────                                     │    │
│  │        NIC → [XDP] → Driver → sk_buff → [TC] → Netfilter → Socket   │    │
│  │              ▲                           ▲                          │    │
│  │              │                           │                          │    │
│  │         Fastest                     After buffer allocation         │    │
│  │                                                                     │    │
│  │  TC (Traffic Control)                                               │    │
│  │  ────────────────────                                               │    │
│  │  • At tc ingress/egress level                                       │    │
│  │  • Access to complete sk_buff                                       │    │
│  │  • Packet modification, marking, redirection                        │    │
│  │  • More flexible than XDP, but slower                               │    │
│  │                                                                     │    │
│  │  SOCKET_FILTER                                                      │    │
│  │  ─────────────                                                      │    │
│  │  • Classic BPF for packet filtering (tcpdump)                       │    │
│  │  • Now implemented as eBPF internally                               │    │
│  │                                                                     │    │
│  │  SK_SKB, SK_MSG                                                     │    │
│  │  ─────────────                                                      │    │
│  │  • Processing at socket level                                       │    │
│  │  • Message redirection between sockets                              │    │
│  │  • Used for service mesh (Cilium)                                   │    │
│  │                                                                     │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │                    CONTROL AND SECURITY                             │    │
│  ├─────────────────────────────────────────────────────────────────────┤    │
│  │                                                                     │    │
│  │  CGROUP_*                                                           │    │
│  │  ────────                                                           │    │
│  │  • Associated with control groups                                   │    │
│  │  • Per-container/per-pod in Kubernetes                              │    │
│  │  • Types: CGROUP_SKB, CGROUP_SOCK, CGROUP_DEVICE                   │    │
│  │  • Control: device permissions, network connectivity                │    │
│  │                                                                     │    │
│  │  LSM (Linux Security Module)                                        │    │
│  │  ───────────────────────────                                        │    │
│  │  • Hooks in the security subsystem                                  │    │
│  │  • Augments/replaces SELinux/AppArmor policies                     │    │
│  │  • Granular control: file operations, IPC, network                  │    │
│  │  • Example: blocking execution from a specific directory            │    │
│  │                                                                     │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 5.2. Program Type Selection

| Scenario | Recommended Program Type | Justification |
|----------|--------------------------|---------------|
| System call monitoring | tracepoint:syscalls | Stable ABI, minimal overhead |
| Specific kernel function profiling | kprobe | Maximum flexibility |
| C library function tracing | uprobe | User space access |
| DDoS mitigation | XDP | Maximum performance |
| Kubernetes network policies | tc, sk_skb | Full packet access |
| Container monitoring | CGROUP_* | Per-container isolation |
| Runtime security audit | LSM | Integration with security framework |

---

## 6. Data Structures: eBPF Maps

### 6.1. The Map Concept

eBPF maps are data structures residing in kernel memory that enable:
- Data persistence between eBPF program invocations
- Communication between different eBPF programs
- Bidirectional communication between kernel space and user space

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                      COMMUNICATION VIA eBPF MAPS                            │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│   USER SPACE                                                                │
│   ══════════                                                                │
│                                                                             │
│   ┌─────────────────────────────────────────────────────────────────────┐   │
│   │  Python/Go/C Application                                            │   │
│   │                                                                     │   │
│   │  map_fd = bpf_obj_get("/sys/fs/bpf/my_map")                        │   │
│   │  value = bpf_map_lookup_elem(map_fd, &key)   // Read               │   │
│   │  bpf_map_update_elem(map_fd, &key, &value)   // Write              │   │
│   └──────────────────────────────┬──────────────────────────────────────┘   │
│                                  │                                          │
│                                  │  bpf() syscall                           │
│                                  ▼                                          │
│   ════════════════════════════════════════════════════════════════════════  │
│                                                                             │
│   KERNEL                                                                    │
│   ══════                                                                    │
│                                                                             │
│   ┌─────────────────────────────────────────────────────────────────────┐   │
│   │                          eBPF MAP                                   │   │
│   │  ┌─────────┬─────────┐                                              │   │
│   │  │   Key   │  Value  │     Type: BPF_MAP_TYPE_HASH                 │   │
│   │  ├─────────┼─────────┤     Max entries: 10000                       │   │
│   │  │ PID=123 │ count=5 │     Key size: 4 bytes                        │   │
│   │  │ PID=456 │ count=2 │     Value size: 8 bytes                      │   │
│   │  │ PID=789 │ count=8 │                                              │   │
│   │  └─────────┴─────────┘                                              │   │
│   └──────────────────────────────▲──────────────────────────────────────┘   │
│                                  │                                          │
│                                  │  bpf_map_lookup_elem()                   │
│                                  │  bpf_map_update_elem()                   │
│                                  │                                          │
│   ┌──────────────────────────────┴──────────────────────────────────────┐   │
│   │  eBPF Program (runs on each event)                                  │   │
│   │                                                                     │   │
│   │  SEC("kprobe/vfs_read")                                             │   │
│   │  int count_reads(struct pt_regs *ctx) {                             │   │
│   │      u32 pid = bpf_get_current_pid_tgid() >> 32;                    │   │
│   │      u64 *count = bpf_map_lookup_elem(&my_map, &pid);               │   │
│   │      if (count) {                                                   │   │
│   │          (*count)++;                                                │   │
│   │      } else {                                                       │   │
│   │          u64 init = 1;                                              │   │
│   │          bpf_map_update_elem(&my_map, &pid, &init, BPF_ANY);        │   │
│   │      }                                                              │   │
│   │      return 0;                                                      │   │
│   │  }                                                                  │   │
│   └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 6.2. Map Types

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        eBPF MAP TYPES                                       │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  GENERIC MAPS                                                               │
│  ────────────                                                               │
│                                                                             │
│  ┌────────────────────┬─────────────────────────────────────────────────┐   │
│  │ BPF_MAP_TYPE_HASH  │ Classic hash table                              │   │
│  │                    │ O(1) lookup, dynamic insert/delete             │   │
│  │                    │ Usage: per-key counting                        │   │
│  ├────────────────────┼─────────────────────────────────────────────────┤   │
│  │ BPF_MAP_TYPE_ARRAY │ Numeric indexed array                          │   │
│  │                    │ O(1) lookup, fixed size                        │   │
│  │                    │ Usage: histograms, configurations              │   │
│  ├────────────────────┼─────────────────────────────────────────────────┤   │
│  │ BPF_MAP_TYPE_      │ Per-CPU variants                               │   │
│  │ PERCPU_HASH/ARRAY  │ Avoids lock contention                         │   │
│  │                    │ Each CPU has separate copy                     │   │
│  │                    │ Usage: high-throughput statistics              │   │
│  └────────────────────┴─────────────────────────────────────────────────┘   │
│                                                                             │
│  COMMUNICATION MAPS                                                         │
│  ──────────────────                                                         │
│                                                                             │
│  ┌────────────────────┬─────────────────────────────────────────────────┐   │
│  │ BPF_MAP_TYPE_      │ Circular buffer                                 │   │
│  │ RINGBUF            │ Producer (kernel) → Consumer (user)             │   │
│  │                    │ Zero-copy, very efficient                       │   │
│  │                    │ Replaces perf buffer (older)                    │   │
│  ├────────────────────┼─────────────────────────────────────────────────┤   │
│  │ BPF_MAP_TYPE_      │ Legacy: perf event buffer                       │   │
│  │ PERF_EVENT_ARRAY   │ Per-CPU, higher overhead than ringbuf          │   │
│  └────────────────────┴─────────────────────────────────────────────────┘   │
│                                                                             │
│  SPECIAL MAPS                                                               │
│  ────────────                                                               │
│                                                                             │
│  ┌────────────────────┬─────────────────────────────────────────────────┐   │
│  │ BPF_MAP_TYPE_      │ References to other eBPF programs               │   │
│  │ PROG_ARRAY         │ Enables tail calls (program chaining)           │   │
│  ├────────────────────┼─────────────────────────────────────────────────┤   │
│  │ BPF_MAP_TYPE_      │ LIFO stack                                      │   │
│  │ STACK              │ Usage: saving stack traces                      │   │
│  ├────────────────────┼─────────────────────────────────────────────────┤   │
│  │ BPF_MAP_TYPE_      │ FIFO queue                                      │   │
│  │ QUEUE              │ Usage: event buffering                          │   │
│  ├────────────────────┼─────────────────────────────────────────────────┤   │
│  │ BPF_MAP_TYPE_LRU_  │ Hash with LRU eviction                          │   │
│  │ HASH               │ No manual size management required              │   │
│  ├────────────────────┼─────────────────────────────────────────────────┤   │
│  │ BPF_MAP_TYPE_      │ Longest Prefix Match                            │   │
│  │ LPM_TRIE           │ Usage: routing tables, CIDR matching            │   │
│  └────────────────────┴─────────────────────────────────────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 6.3. Map Operations

**From the eBPF program (in kernel)**:
```c
void *bpf_map_lookup_elem(map, key)     // Look up value by key
int bpf_map_update_elem(map, key, val)  // Insert/update
int bpf_map_delete_elem(map, key)       // Delete entry
```

**From user space**:
```c
// Via bpf() syscall or libraries (libbpf)
bpf_map_lookup_elem(fd, key, value)
bpf_map_update_elem(fd, key, value, flags)
bpf_map_delete_elem(fd, key)
bpf_map_get_next_key(fd, key, next_key)  // Iteration
```

---

## 7. Development Tooling

### 7.1. Tool Suite

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    eBPF ABSTRACTION LEVELS                                  │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  HIGH LEVEL (End users, SRE, DevOps)                                        │
│  ═══════════════════════════════════                                        │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │  bpftrace           BCC tools           kubectl-trace               │    │
│  │  (one-liners)       (pre-built)         (Kubernetes)                │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                  │                                          │
│                                  ▼                                          │
│  MEDIUM LEVEL (Tool developers)                                             │
│  ══════════════════════════════                                             │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │  BCC (Python+C)     libbpf-rs (Rust)    cilium/ebpf (Go)           │    │
│  │  Framework          Framework            Framework                   │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                  │                                          │
│                                  ▼                                          │
│  LOW LEVEL (eBPF program development)                                       │
│  ════════════════════════════════════                                       │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │  libbpf (C)         BTF (type info)     CO-RE (Compile Once -       │    │
│  │  Core library       Formats             Run Everywhere)             │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                  │                                          │
│                                  ▼                                          │
│  KERNEL                                                                     │
│  ══════                                                                     │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │  Verifier           JIT Compiler        Maps           Helpers      │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 7.2. System Support Verification

```bash
# Check kernel version (minimum 4.x, recommended 5.x+)
uname -r

# Check CONFIG_BPF enabled
grep CONFIG_BPF /boot/config-$(uname -r)
# CONFIG_BPF=y
# CONFIG_BPF_SYSCALL=y
# CONFIG_BPF_JIT=y

# Check JIT enabled
cat /proc/sys/net/core/bpf_jit_enable
# 1 = enabled, 0 = disabled

# List loaded eBPF programs
sudo bpftool prog list

# List eBPF maps
sudo bpftool map list

# Check BTF available (for CO-RE)
ls /sys/kernel/btf/vmlinux
```

---

## 8. bpftrace: High Performance Dynamic Tracing

### 8.1. Introduction to bpftrace

**bpftrace** is a high-level language for eBPF tracing, inspired by DTrace and AWK. It allows writing one-liners and short scripts for rapid diagnostics.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                       bpftrace PROGRAM STRUCTURE                            │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│   probe_type:probe_name /filter/ { action }                                 │
│                                                                             │
│   Examples:                                                                 │
│   ─────────                                                                 │
│                                                                             │
│   kprobe:vfs_read { @[comm] = count(); }                                   │
│   │       │         │           │                                          │
│   │       │         │           └─ Action: increment counter               │
│   │       │         └─ Aggregation by process name                         │
│   │       └─ Kernel function to monitor                                    │
│   └─ Probe type                                                            │
│                                                                             │
│   tracepoint:syscalls:sys_enter_openat /comm == "nginx"/ { ... }          │
│                                         │                                  │
│                                         └─ Filter: only nginx process      │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 8.2. bpftrace Probe Types

| Syntax | Description | Example |
|--------|-------------|---------|
| `kprobe:func` | Kernel function entry | `kprobe:do_sys_open` |
| `kretprobe:func` | Kernel function exit | `kretprobe:do_sys_open` |
| `uprobe:binary:func` | User function entry | `uprobe:/bin/bash:readline` |
| `uretprobe:binary:func` | User function exit | `uretprobe:/lib/libc.so.6:malloc` |
| `tracepoint:cat:name` | Static tracepoint | `tracepoint:syscalls:sys_enter_read` |
| `software:event:count` | Software event | `software:cpu-clock:1000000` |
| `hardware:event:count` | Hardware event | `hardware:cache-misses:1000` |
| `profile:hz:freq` | Periodic sampling | `profile:hz:99` |
| `interval:s:sec` | Periodic timer | `interval:s:1` |
| `BEGIN`, `END` | Tracing start/stop | `BEGIN { print("Start"); }` |

### 8.3. Built-in Variables and Functions

**Built-in variables**:
```
pid          - Process ID
tid          - Thread ID
uid          - User ID
gid          - Group ID
comm         - Process name (16 characters)
nsecs        - Timestamp nanoseconds
kstack       - Kernel stack trace
ustack       - User stack trace
arg0-argN    - Function arguments
retval       - Return value (in kretprobe/uretprobe)
curtask      - Pointer to current task_struct
cgroup       - Current cgroup ID
```

**Built-in functions**:
```
printf()     - Formatted output
print()      - Simple output
count()      - Event counting
sum(x)       - Sum values
avg(x)       - Average
min(x), max(x) - Minimum, maximum
hist(x)      - Log2 histogram
lhist(x,min,max,step) - Linear histogram
str(ptr)     - Read string from memory
kstack(n)    - Kernel stack with n frames
ustack(n)    - User stack with n frames
time(fmt)    - Formatted timestamp
```

### 8.4. Essential One-Liners Collection

The following commands represent a diagnostic arsenal for any systems engineer:

```bash
# ═══════════════════════════════════════════════════════════════════════════
# PROCESS MONITORING
# ═══════════════════════════════════════════════════════════════════════════

# 1. List newly created processes (fork/exec)
sudo bpftrace -e 'tracepoint:syscalls:sys_enter_execve { 
    printf("%s -> %s\n", comm, str(args->filename)); 
}'

# 2. Count system calls per process
sudo bpftrace -e 'tracepoint:raw_syscalls:sys_enter { @[comm] = count(); }'

# 3. Top 10 processes by syscall count (runs for 5 seconds)
sudo bpftrace -e 'tracepoint:raw_syscalls:sys_enter { @[comm] = count(); } 
    interval:s:5 { exit(); }'

# 4. Monitor signals sent
sudo bpftrace -e 'tracepoint:signal:signal_generate { 
    printf("%s (pid %d) -> sig %d -> pid %d\n", 
           comm, pid, args->sig, args->pid); 
}'

# ═══════════════════════════════════════════════════════════════════════════
# FILE OPERATIONS
# ═══════════════════════════════════════════════════════════════════════════

# 5. Monitor opened files
sudo bpftrace -e 'tracepoint:syscalls:sys_enter_openat { 
    printf("%s: %s\n", comm, str(args->filename)); 
}'

# 6. Count read/write operations per process
sudo bpftrace -e '
    tracepoint:syscalls:sys_enter_read { @reads[comm] = count(); }
    tracepoint:syscalls:sys_enter_write { @writes[comm] = count(); }
'

# 7. Read size distribution (histogram)
sudo bpftrace -e 'tracepoint:syscalls:sys_exit_read /args->ret > 0/ { 
    @bytes = hist(args->ret); 
}'

# 8. VFS read latency (time in function)
sudo bpftrace -e '
    kprobe:vfs_read { @start[tid] = nsecs; }
    kretprobe:vfs_read /@start[tid]/ { 
        @latency_ns = hist(nsecs - @start[tid]); 
        delete(@start[tid]); 
    }
'

# ═══════════════════════════════════════════════════════════════════════════
# NETWORK
# ═══════════════════════════════════════════════════════════════════════════

# 9. New TCP connections (connect)
sudo bpftrace -e 'kprobe:tcp_v4_connect { 
    printf("%s[%d] connecting...\n", comm, pid); 
}'

# 10. Accepted TCP connections (server)
sudo bpftrace -e 'kretprobe:inet_csk_accept { 
    printf("%s[%d] accepted connection\n", comm, pid); 
}'

# 11. Packets sent per process
sudo bpftrace -e 'kprobe:tcp_sendmsg { @[comm] = count(); }'

# 12. TCP sent packet size distribution
sudo bpftrace -e 'kprobe:tcp_sendmsg { @size = hist(arg2); }'

# ═══════════════════════════════════════════════════════════════════════════
# MEMORY
# ═══════════════════════════════════════════════════════════════════════════

# 13. brk() calls for heap expansion
sudo bpftrace -e 'tracepoint:syscalls:sys_enter_brk { 
    printf("%s: brk(%p)\n", comm, args->brk); 
}'

# 14. Page faults per process
sudo bpftrace -e 'software:page-faults:1 { @[comm] = count(); }'

# 15. Kernel page allocations (kmalloc)
sudo bpftrace -e 'tracepoint:kmem:kmalloc { @bytes[comm] = sum(args->bytes_alloc); }'

# ═══════════════════════════════════════════════════════════════════════════
# SCHEDULER
# ═══════════════════════════════════════════════════════════════════════════

# 16. Context switches per second
sudo bpftrace -e 'tracepoint:sched:sched_switch { @switches = count(); } 
    interval:s:1 { print(@switches); clear(@switches); }'

# 17. Run queue latency (wait time before running)
sudo bpftrace -e '
    tracepoint:sched:sched_wakeup { @qtime[args->pid] = nsecs; }
    tracepoint:sched:sched_switch /@qtime[args->next_pid]/ {
        @latency_us = hist((nsecs - @qtime[args->next_pid]) / 1000);
        delete(@qtime[args->next_pid]);
    }
'

# 18. CPU migrations
sudo bpftrace -e 'tracepoint:sched:sched_migrate_task { 
    printf("%s migrated from CPU %d to CPU %d\n", 
           args->comm, args->orig_cpu, args->dest_cpu); 
}'

# ═══════════════════════════════════════════════════════════════════════════
# BLOCK I/O (DISK)
# ═══════════════════════════════════════════════════════════════════════════

# 19. Block I/O latency (histogram)
sudo bpftrace -e '
    tracepoint:block:block_rq_issue { @start[args->dev, args->sector] = nsecs; }
    tracepoint:block:block_rq_complete /@start[args->dev, args->sector]/ {
        @latency_us = hist((nsecs - @start[args->dev, args->sector]) / 1000);
        delete(@start[args->dev, args->sector]);
    }
'

# 20. I/O per device and operation type
sudo bpftrace -e 'tracepoint:block:block_rq_issue { 
    @io[args->dev, args->rwbs] = count(); 
}'

# ═══════════════════════════════════════════════════════════════════════════
# CPU PROFILING
# ═══════════════════════════════════════════════════════════════════════════

# 21. Stack sampling at 99 Hz (flame graph input)
sudo bpftrace -e 'profile:hz:99 { @[kstack] = count(); }'

# 22. Most frequently called kernel functions
sudo bpftrace -e 'profile:hz:99 { @[func] = count(); }'

# 23. Off-CPU analysis (where processes wait)
sudo bpftrace -e '
    tracepoint:sched:sched_switch { 
        @off[args->prev_comm, args->prev_pid] = nsecs; 
    }
    tracepoint:sched:sched_switch /@off[args->next_comm, args->next_pid]/ {
        @blocked_us[args->next_comm] = 
            hist((nsecs - @off[args->next_comm, args->next_pid]) / 1000);
        delete(@off[args->next_comm, args->next_pid]);
    }
'
```

### 8.5. Complete bpftrace Script: Specific Process Monitoring

```bash
#!/usr/bin/env bpftrace
/*
 * process_monitor.bt - Detailed monitoring of a process
 * Usage: sudo bpftrace process_monitor.bt -c "program_to_trace"
 *        sudo bpftrace process_monitor.bt -p PID
 */

BEGIN {
    printf("Monitoring process... Ctrl+C to stop.\n");
    printf("%-20s %-10s %-40s\n", "EVENT", "LATENCY", "DETAILS");
    printf("─────────────────────────────────────────────────────────────────────\n");
}

// System calls - entry
tracepoint:raw_syscalls:sys_enter /pid == $target/ {
    @syscall_start[tid] = nsecs;
    @syscall_id[tid] = args->id;
}

// System calls - exit with duration
tracepoint:raw_syscalls:sys_exit /pid == $target && @syscall_start[tid]/ {
    $latency = (nsecs - @syscall_start[tid]) / 1000; // microseconds
    @syscall_latency[@syscall_id[tid]] = hist($latency);
    
    // Display only slow calls (>1ms)
    if ($latency > 1000) {
        printf("%-20s %-10d syscall_id=%d ret=%d\n", 
               "SLOW_SYSCALL", $latency, @syscall_id[tid], args->ret);
    }
    
    delete(@syscall_start[tid]);
    delete(@syscall_id[tid]);
}

// File opens
tracepoint:syscalls:sys_enter_openat /pid == $target/ {
    printf("%-20s %-10s %s\n", "OPEN", "-", str(args->filename));
}

// Read/write operations
tracepoint:syscalls:sys_exit_read /pid == $target && args->ret > 0/ {
    @read_bytes = sum(args->ret);
}

tracepoint:syscalls:sys_exit_write /pid == $target && args->ret > 0/ {
    @write_bytes = sum(args->ret);
}

// Network connections
kprobe:tcp_v4_connect /pid == $target/ {
    printf("%-20s %-10s TCP connect initiated\n", "NET_CONNECT", "-");
}

// Page faults
software:page-faults:1 /pid == $target/ {
    @page_faults = count();
}

// Context switches
tracepoint:sched:sched_switch /args->prev_pid == $target/ {
    @voluntary_switches = count();
}

interval:s:5 {
    printf("\n═══ 5 SECOND SUMMARY ═══\n");
    printf("Read bytes:  %d\n", @read_bytes);
    printf("Write bytes: %d\n", @write_bytes);
    printf("Page faults: %d\n", @page_faults);
    printf("Context switches: %d\n", @voluntary_switches);
    
    clear(@read_bytes);
    clear(@write_bytes);
    clear(@page_faults);
    clear(@voluntary_switches);
}

END {
    printf("\n═══ SYSCALL LATENCY HISTOGRAMS (μs) ═══\n");
    print(@syscall_latency);
    
    clear(@syscall_start);
    clear(@syscall_id);
    clear(@syscall_latency);
}
```

---

## 9. BCC: BPF Compiler Collection

### 9.1. BCC Architecture

**BCC** (BPF Compiler Collection) is a framework that combines eBPF programs written in restricted C with Python/Lua applications for orchestration. It includes a rich library of pre-built tools.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                       BCC ARCHITECTURE                                      │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│   ┌─────────────────────────────────────────────────────────────────────┐   │
│   │  Python Script (orchestration, display, data processing)            │   │
│   │  ┌───────────────────────────────────────────────────────────────┐  │   │
│   │  │  from bcc import BPF                                          │  │   │
│   │  │  b = BPF(text=bpf_program)                                    │  │   │
│   │  │  b.attach_kprobe(event="vfs_read", fn_name="trace_read")      │  │   │
│   │  │  while True:                                                  │  │   │
│   │  │      print(b["counts"].items())                               │  │   │
│   │  └───────────────────────────────────────────────────────────────┘  │   │
│   └──────────────────────────────────┬──────────────────────────────────┘   │
│                                      │                                      │
│                                      ▼                                      │
│   ┌─────────────────────────────────────────────────────────────────────┐   │
│   │  eBPF Program (restricted C, compiled at runtime)                   │   │
│   │  ┌───────────────────────────────────────────────────────────────┐  │   │
│   │  │  BPF_HASH(counts, u32, u64);                                  │  │   │
│   │  │                                                               │  │   │
│   │  │  int trace_read(struct pt_regs *ctx) {                        │  │   │
│   │  │      u32 pid = bpf_get_current_pid_tgid() >> 32;              │  │   │
│   │  │      counts.increment(pid);                                   │  │   │
│   │  │      return 0;                                                │  │   │
│   │  │  }                                                            │  │   │
│   │  └───────────────────────────────────────────────────────────────┘  │   │
│   └──────────────────────────────────┬──────────────────────────────────┘   │
│                                      │                                      │
│                                      │ LLVM/Clang                           │
│                                      │ compilation                          │
│                                      ▼                                      │
│   ┌─────────────────────────────────────────────────────────────────────┐   │
│   │  eBPF Bytecode → Verifier → JIT → Attach to hook                    │   │
│   └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 9.2. BCC Installation

```bash
# Ubuntu/Debian
sudo apt-get install bpfcc-tools linux-headers-$(uname -r)

# Fedora
sudo dnf install bcc-tools

# Arch Linux
sudo pacman -S bcc bcc-tools python-bcc

# Verify installation
sudo /usr/share/bcc/tools/execsnoop
```

### 9.3. Essential BCC Tools

BCC includes over 100 diagnostic tools. The following table presents the most commonly used:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                      ESSENTIAL BCC TOOLS                                    │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  PROCESSES AND SYSTEM CALLS                                                 │
│  ══════════════════════════                                                 │
│                                                                             │
│  ┌────────────────┬────────────────────────────────────────────────────┐    │
│  │ execsnoop      │ Trace exec() - newly created processes             │    │
│  │                │ $ sudo execsnoop                                   │    │
│  │                │ PCOMM  PID   PPID  RET ARGS                        │    │
│  │                │ bash   1234  1000  0   /bin/ls -la                 │    │
│  ├────────────────┼────────────────────────────────────────────────────┤    │
│  │ opensnoop      │ Trace open() - opened files                        │    │
│  │                │ $ sudo opensnoop -p 1234                           │    │
│  │                │ PID    COMM  FD  PATH                              │    │
│  │                │ 1234   cat   3   /etc/passwd                       │    │
│  ├────────────────┼────────────────────────────────────────────────────┤    │
│  │ syscount       │ Count system calls                                 │    │
│  │                │ $ sudo syscount -p 1234 -i 1                       │    │
│  │                │ SYSCALL    COUNT                                   │    │
│  │                │ read       15234                                   │    │
│  │                │ write      8432                                    │    │
│  ├────────────────┼────────────────────────────────────────────────────┤    │
│  │ killsnoop      │ Monitor kill() signals                             │    │
│  │                │ $ sudo killsnoop                                   │    │
│  │                │ PID    COMM      SIG  TPID   RES                   │    │
│  │                │ 1234   bash      9    5678   0                     │    │
│  └────────────────┴────────────────────────────────────────────────────┘    │
│                                                                             │
│  NETWORK                                                                    │
│  ═══════                                                                    │
│                                                                             │
│  ┌────────────────┬────────────────────────────────────────────────────┐    │
│  │ tcpconnect     │ Active TCP connections (outbound)                  │    │
│  │                │ $ sudo tcpconnect                                  │    │
│  │                │ PID    COMM      SADDR        DADDR        DPORT   │    │
│  │                │ 1234   curl      10.0.0.1     93.184.216.34 80     │    │
│  ├────────────────┼────────────────────────────────────────────────────┤    │
│  │ tcpaccept      │ Passive TCP connections (inbound)                  │    │
│  │                │ $ sudo tcpaccept                                   │    │
│  │                │ PID    COMM      RADDR        LPORT                │    │
│  │                │ 5678   nginx     192.168.1.5  80                   │    │
│  ├────────────────┼────────────────────────────────────────────────────┤    │
│  │ tcpretrans     │ TCP retransmissions (network problem indicator)    │    │
│  │                │ $ sudo tcpretrans                                  │    │
│  ├────────────────┼────────────────────────────────────────────────────┤    │
│  │ tcplife        │ TCP connection lifetime                            │    │
│  │                │ $ sudo tcplife                                     │    │
│  │                │ PID   COMM      LADDR  RADDR   TX_KB RX_KB MS      │    │
│  │                │ 1234  curl      :0     :80     1     25    150     │    │
│  └────────────────┴────────────────────────────────────────────────────┘    │
│                                                                             │
│  DISK I/O                                                                   │
│  ════════                                                                   │
│                                                                             │
│  ┌────────────────┬────────────────────────────────────────────────────┐    │
│  │ biolatency     │ Block I/O latency histogram                        │    │
│  │                │ $ sudo biolatency                                  │    │
│  │                │      usecs      : count    distribution            │    │
│  │                │        0 -> 1   : 0       |                        │    │
│  │                │        2 -> 3   : 12      |**                      │    │
│  │                │        4 -> 7   : 156     |*************           │    │
│  │                │       ...                                          │    │
│  ├────────────────┼────────────────────────────────────────────────────┤    │
│  │ biosnoop       │ Trace every I/O operation                          │    │
│  │                │ $ sudo biosnoop                                    │    │
│  │                │ TIME     COMM   PID  DISK  T  SECTOR  BYTES  LAT   │    │
│  │                │ 12:00:01 mysqld 123  sda   R  1234    4096   0.5   │    │
│  ├────────────────┼────────────────────────────────────────────────────┤    │
│  │ ext4slower     │ Slow ext4 operations (or xfs/btrfs/zfs)            │    │
│  │                │ $ sudo ext4slower 10                               │    │
│  │                │ (displays operations >10ms)                        │    │
│  ├────────────────┼────────────────────────────────────────────────────┤    │
│  │ filelife       │ File lifetime (create → delete)                    │    │
│  │                │ $ sudo filelife                                    │    │
│  └────────────────┴────────────────────────────────────────────────────┘    │
│                                                                             │
│  MEMORY                                                                     │
│  ══════                                                                     │
│                                                                             │
│  ┌────────────────┬────────────────────────────────────────────────────┐    │
│  │ memleak        │ Detect memory leaks (without code modification)    │    │
│  │                │ $ sudo memleak -p 1234                             │    │
│  │                │ [top outstanding allocations]                      │    │
│  │                │ 1024 bytes in 16 allocations from stack:           │    │
│  │                │   malloc+0x00                                      │    │
│  │                │   process_request+0x42                             │    │
│  ├────────────────┼────────────────────────────────────────────────────┤    │
│  │ oomkill        │ Monitor OOM killer events                          │    │
│  │                │ $ sudo oomkill                                     │    │
│  ├────────────────┼────────────────────────────────────────────────────┤    │
│  │ cachestat      │ Page cache statistics (hits/misses)                │    │
│  │                │ $ sudo cachestat                                   │    │
│  │                │ HITS   MISSES  DIRTIES  RATIO  BUFFERS_MB          │    │
│  │                │ 12345  234     45       98.1%  512                 │    │
│  └────────────────┴────────────────────────────────────────────────────┘    │
│                                                                             │
│  CPU AND SCHEDULER                                                          │
│  ═════════════════                                                          │
│                                                                             │
│  ┌────────────────┬────────────────────────────────────────────────────┐    │
│  │ runqlat        │ Run queue latency (wait time before CPU)           │    │
│  │                │ $ sudo runqlat                                     │    │
│  │                │      usecs      : count    distribution            │    │
│  │                │        0 -> 1   : 3245    |*****                   │    │
│  │                │        2 -> 3   : 12456   |*******************     │    │
│  ├────────────────┼────────────────────────────────────────────────────┤    │
│  │ runqlen        │ Run queue length over time                         │    │
│  │                │ $ sudo runqlen                                     │    │
│  ├────────────────┼────────────────────────────────────────────────────┤    │
│  │ cpudist        │ On-CPU time distribution per task                  │    │
│  │                │ $ sudo cpudist                                     │    │
│  ├────────────────┼────────────────────────────────────────────────────┤    │
│  │ offcputime     │ Blocking analysis (off-CPU stacks)                 │    │
│  │                │ $ sudo offcputime -p 1234 5                        │    │
│  │                │ (stack traces with time spent blocked)             │    │
│  └────────────────┴────────────────────────────────────────────────────┘    │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 9.4. Complete Example: Custom BCC Script

```python
#!/usr/bin/env python3
"""
slow_syscalls.py - Monitor slow system calls
Displays system calls that exceed a latency threshold
"""

from bcc import BPF
from time import strftime
import argparse

# Command line arguments
parser = argparse.ArgumentParser(
    description="Monitor slow system calls")
parser.add_argument("-p", "--pid", type=int, 
    help="Filter by PID")
parser.add_argument("-t", "--threshold", type=int, default=1000,
    help="Latency threshold in microseconds (default: 1000)")
args = parser.parse_args()

# eBPF program (restricted C)
bpf_program = """
#include <uapi/linux/ptrace.h>
#include <linux/sched.h>

struct data_t {
    u64 ts;           // Start timestamp
    u64 lat_us;       // Latency in microseconds
    u32 pid;
    u32 tid;
    u64 syscall_id;
    char comm[16];
};

BPF_HASH(start, u64, u64);           // tid -> timestamp
BPF_HASH(syscalls, u64, u64);        // tid -> syscall_id
BPF_PERF_OUTPUT(events);             // Buffer for user space

TRACEPOINT_PROBE(raw_syscalls, sys_enter) {
    u64 pid_tgid = bpf_get_current_pid_tgid();
    u32 pid = pid_tgid >> 32;
    
    // Optional PID filter
    FILTER_PID
    
    u64 tid = pid_tgid;
    u64 ts = bpf_ktime_get_ns();
    
    start.update(&tid, &ts);
    syscalls.update(&tid, &args->id);
    
    return 0;
}

TRACEPOINT_PROBE(raw_syscalls, sys_exit) {
    u64 pid_tgid = bpf_get_current_pid_tgid();
    u64 tid = pid_tgid;
    
    u64 *tsp = start.lookup(&tid);
    if (!tsp) return 0;
    
    u64 lat_ns = bpf_ktime_get_ns() - *tsp;
    u64 lat_us = lat_ns / 1000;
    
    // Latency threshold
    if (lat_us < THRESHOLD_US) {
        start.delete(&tid);
        syscalls.delete(&tid);
        return 0;
    }
    
    struct data_t data = {};
    data.ts = *tsp;
    data.lat_us = lat_us;
    data.pid = pid_tgid >> 32;
    data.tid = tid;
    
    u64 *sid = syscalls.lookup(&tid);
    if (sid) data.syscall_id = *sid;
    
    bpf_get_current_comm(&data.comm, sizeof(data.comm));
    
    events.perf_submit(args, &data, sizeof(data));
    
    start.delete(&tid);
    syscalls.delete(&tid);
    
    return 0;
}
"""

# Code substitutions
bpf_program = bpf_program.replace("THRESHOLD_US", str(args.threshold))
if args.pid:
    bpf_program = bpf_program.replace("FILTER_PID",
        f"if (pid != {args.pid}) return 0;")
else:
    bpf_program = bpf_program.replace("FILTER_PID", "")

# Syscall ID -> name mapping
from bcc import syscall_name

# Load and attach
b = BPF(text=bpf_program)

# Event callback
def print_event(cpu, data, size):
    event = b["events"].event(data)
    syscall = syscall_name(event.syscall_id).decode('utf-8', 'replace')
    print(f"{strftime('%H:%M:%S')} {event.comm.decode('utf-8'):<16} "
          f"{event.pid:<7} {syscall:<20} {event.lat_us:>10} μs")

# Header
print(f"{'TIME':<8} {'COMM':<16} {'PID':<7} {'SYSCALL':<20} {'LATENCY':>10}")
print("─" * 70)

# Event polling
b["events"].open_perf_buffer(print_event)
while True:
    try:
        b.perf_buffer_poll()
    except KeyboardInterrupt:
        print("\nMonitoring completed.")
        exit()
```

---

## 10. Production Use Cases

### 10.1. Performance Diagnostics Methodology with eBPF

```
┌─────────────────────────────────────────────────────────────────────────────┐
│              PERFORMANCE DIAGNOSTICS FLOW                                   │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│   1. OBSERVED SYMPTOM                                                       │
│      │                                                                      │
│      ├─► High application latency                                           │
│      ├─► 100% CPU utilisation                                               │
│      ├─► Growing memory                                                     │
│      └─► Slow I/O                                                           │
│            │                                                                │
│            ▼                                                                │
│   2. IDENTIFY SATURATED RESOURCE (USE Method)                               │
│      │                                                                      │
│      │   ┌──────────┬──────────────────────┬─────────────────┐              │
│      │   │ Resource │ Utilisation          │ eBPF Tool       │              │
│      │   ├──────────┼──────────────────────┼─────────────────┤              │
│      │   │ CPU      │ runqlat, cpudist     │ bpftrace/BCC    │              │
│      │   │ Memory   │ memleak, cachestat   │ BCC tools       │              │
│      │   │ I/O      │ biolatency, biosnoop │ BCC tools       │              │
│      │   │ Network  │ tcplife, tcpretrans  │ BCC tools       │              │
│      │   └──────────┴──────────────────────┴─────────────────┘              │
│            │                                                                │
│            ▼                                                                │
│   3. DETAILED ANALYSIS                                                      │
│      │                                                                      │
│      ├─► Stack traces (profiling)                                           │
│      ├─► Per-operation latency                                              │
│      └─► Event correlation                                                  │
│            │                                                                │
│            ▼                                                                │
│   4. ROOT CAUSE IDENTIFICATION                                              │
│      │                                                                      │
│      ├─► Application code (specific function)                               │
│      ├─► System configuration                                               │
│      └─► Hardware problem                                                   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 10.2. Practical Scenarios

**Scenario 1: Web application latency**

```bash
# Step 1: Check run queue latency (CPU overloaded?)
sudo runqlat 10 1
# If we see latencies >100μs, the CPU is saturated

# Step 2: Check disk I/O (blocking reads?)
sudo biolatency 10 1
# Latencies >10ms indicate I/O problems

# Step 3: Identify specific operations
sudo opensnoop -p $(pgrep nginx) -d 10
# See the files accessed

# Step 4: Stack traces for slow functions
sudo offcputime -p $(pgrep nginx) -f 5 > stacks.out
# Analysis with flame graph
```

**Scenario 2: Memory leak**

```bash
# Monitor unreleased allocations
sudo memleak -p $(pgrep myapp) -a

# Example result:
# [10:00:00] 1048576 bytes in 1024 allocations from stack:
#         malloc+0x00
#         process_request+0x42 [myapp]
#         handle_connection+0x1f [myapp]
```

**Scenario 3: Network connection problems**

```bash
# TCP retransmissions (indicates packet loss/congestion)
sudo tcpretrans

# Refused connections
sudo tcpconnect | grep -v "^0$"

# Connection latency
sudo tcplife
```

### 10.3. Integration with Monitoring Systems

```
┌─────────────────────────────────────────────────────────────────────────────┐
│              MODERN OBSERVABILITY STACK                                     │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌───────────────────────────────────────────────────────────────────────┐  │
│  │                      VISUALISATION AND ALERTING                       │  │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐   │  │
│  │  │  Grafana    │  │  Kibana     │  │  Datadog    │  │  Pagerduty  │   │  │
│  │  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘   │  │
│  └─────────┼────────────────┼────────────────┼────────────────┼──────────┘  │
│            │                │                │                │             │
│            └────────────────┴────────────────┴────────────────┘             │
│                                    │                                        │
│                                    ▼                                        │
│  ┌───────────────────────────────────────────────────────────────────────┐  │
│  │                      STORAGE AND AGGREGATION                          │  │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────────────┐    │  │
│  │  │ Prometheus  │  │ Elasticsearch│ │ Jaeger (distributed tracing)│    │  │
│  │  └──────┬──────┘  └──────┬──────┘  └─────────────┬───────────────┘    │  │
│  └─────────┼────────────────┼───────────────────────┼────────────────────┘  │
│            │                │                       │                       │
│            └────────────────┴───────────────────────┘                       │
│                                    │                                        │
│                                    ▼                                        │
│  ┌───────────────────────────────────────────────────────────────────────┐  │
│  │                      COLLECTION (eBPF AGENT)                          │  │
│  │  ┌─────────────────────────────────────────────────────────────────┐  │  │
│  │  │  Pixie / Cilium Hubble / Datadog Agent / Parca / ...            │  │  │
│  │  │                                                                 │  │  │
│  │  │  • Kernel metrics (CPU, memory, I/O)                            │  │  │
│  │  │  • System call tracing                                          │  │  │
│  │  │  • Network observability (without sidecar)                      │  │  │
│  │  │  • Continuous profiling                                         │  │  │
│  │  └─────────────────────────────────────────────────────────────────┘  │  │
│  └───────────────────────────────────────────────────────────────────────┘  │
│                                    │                                        │
│                                    ▼                                        │
│  ┌───────────────────────────────────────────────────────────────────────┐  │
│  │                      LINUX KERNEL (eBPF hooks)                        │  │
│  │  ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐         │  │
│  │  │kprobes  │ │uprobes  │ │tracepoint│ │ XDP    │ │ tc     │         │  │
│  │  └─────────┘ └─────────┘ └─────────┘ └─────────┘ └─────────┘         │  │
│  └───────────────────────────────────────────────────────────────────────┘  │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 11. Security and Operational Considerations

### 11.1. eBPF Security Model

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    eBPF SECURITY LAYERS                                     │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  LAYER 1: REQUIRED PRIVILEGES                                               │
│  ════════════════════════════                                               │
│                                                                             │
│  • CAP_BPF (kernel 5.8+) or CAP_SYS_ADMIN (older kernel)                   │
│  • CAP_PERFMON for performance probes                                       │
│  • CAP_NET_ADMIN for XDP/tc                                                 │
│                                                                             │
│  Verification:                                                              │
│  $ cat /proc/sys/kernel/unprivileged_bpf_disabled                          │
│  1 = disabled for unprivileged users (recommended)                         │
│                                                                             │
│  LAYER 2: VERIFIER                                                          │
│  ═════════════════                                                          │
│                                                                             │
│  • MANDATORY static analysis before loading                                │
│  • Guarantees: termination, memory safety, legal operations                │
│  • CANNOT be bypassed                                                       │
│                                                                             │
│  LAYER 3: HELPER FUNCTION ISOLATION                                         │
│  ══════════════════════════════════                                         │
│                                                                             │
│  • Each program type has access only to specific helpers                   │
│  • XDP cannot read arbitrary kernel memory                                 │
│  • Tracing cannot modify packets                                           │
│                                                                             │
│  LAYER 4: SIGNED BPF (kernel 5.16+)                                         │
│  ══════════════════════════════════                                         │
│                                                                             │
│  • eBPF programs can be cryptographically signed                           │
│  • Kernel verifies signature before loading                                │
│  • Prevents loading of unauthorised programs                               │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 11.2. Risks and Mitigations

| Risk | Description | Mitigation |
|------|-------------|------------|
| **DoS via verifier** | Complex program can slow down verification | Verifier complexity limits |
| **Information leakage** | Reading sensitive kernel data | Restricted helpers, Spectre mitigations |
| **Side-channel attacks** | Timing attacks through measurements | bpf_jit_harden=2 |
| **Sandbox escape** | Exploiting verifier vulnerabilities | Kernel updates, code audits |
| **Performance overhead** | Inefficient programs | Profiling, resource limits |

### 11.3. Recommended Security Configurations

```bash
# Disable eBPF for unprivileged users
echo 1 > /proc/sys/kernel/unprivileged_bpf_disabled

# JIT hardening (side-channel mitigation)
echo 2 > /proc/sys/net/core/bpf_jit_harden

# Enable program load logging
echo 1 > /proc/sys/kernel/bpf_stats_enabled

# Check loaded programs
sudo bpftool prog list
```

---

## 12. Practical Demonstrations

### 12.1. Lab 1: System Monitoring with bpftrace

**Objective**: Diagnosing performance problems on a simulated web server

```bash
#!/bin/bash
# lab1_system_monitor.sh - Setup and demonstration

# Step 1: Generate load (in a separate terminal)
echo "Terminal 1: Generating load..."
# stress --cpu 2 --io 2 --vm 1 --vm-bytes 128M --timeout 60s &

# Step 2: Monitor with bpftrace
echo "Terminal 2: Monitoring system activity..."

# 2a. Newly created processes
sudo bpftrace -e '
    tracepoint:syscalls:sys_enter_execve { 
        printf("EXEC: %s -> %s\n", comm, str(args->filename)); 
    }
' &

# 2b. Opened files
sudo bpftrace -e '
    tracepoint:syscalls:sys_enter_openat { 
        printf("OPEN: %s: %s\n", comm, str(args->filename)); 
    }
' &

# 2c. I/O latency histogram
sudo bpftrace -e '
    kprobe:blk_account_io_start { @start[arg0] = nsecs; }
    kprobe:blk_account_io_done /@start[arg0]/ { 
        @io_lat = hist((nsecs - @start[arg0]) / 1000);
        delete(@start[arg0]);
    }
    interval:s:10 { print(@io_lat); clear(@io_lat); }
'
```

### 12.2. Lab 2: Memory Leak Detection

```python
#!/usr/bin/env python3
"""
lab2_memleak_demo.py - Memory leak detection demonstration
"""

import ctypes
import time
import os

def leaky_function():
    """Function that allocates memory without releasing it"""
    # Direct allocation via libc malloc
    libc = ctypes.CDLL("libc.so.6")
    ptr = libc.malloc(1024)  # 1KB per call
    # We don't call free(ptr) - memory leak!
    return ptr

def main():
    print(f"PID: {os.getpid()}")
    print("Starting allocation loop... (run 'sudo memleak -p PID' in another terminal)")
    
    allocations = []
    while True:
        ptr = leaky_function()
        allocations.append(ptr)
        if len(allocations) % 100 == 0:
            print(f"Allocations: {len(allocations)}, ~{len(allocations)}KB leaked")
        time.sleep(0.01)

if __name__ == "__main__":
    main()
```

**Detection with BCC:**

```bash
# Terminal 1: Run application
python3 lab2_memleak_demo.py

# Terminal 2: Detect leaks
sudo /usr/share/bcc/tools/memleak -p $(pgrep -f lab2_memleak) -a

# Expected result:
# Attaching to pid XXXX, Ctrl+C to quit.
# [15:00:00] Top 10 stacks with outstanding allocations:
# 	1048576 bytes in 1024 allocations from stack
# 		malloc+0x00 [libc.so.6]
# 		leaky_function+0x1a [python3]
# 		...
```

### 12.3. Lab 3: Network Connection Analysis

```bash
#!/bin/bash
# lab3_network_analysis.sh - Connection monitoring

echo "=== TCP CONNECTION MONITORING ==="

# Outbound connections
echo "Initiated connections (outbound):"
sudo timeout 30 /usr/share/bcc/tools/tcpconnect &

# Inbound connections
echo "Accepted connections (inbound):"
sudo timeout 30 /usr/share/bcc/tools/tcpaccept &

# Retransmissions (problem indicator)
echo "TCP retransmissions (network problems):"
sudo timeout 30 /usr/share/bcc/tools/tcpretrans &

# Generate test traffic
echo "Generating traffic..."
for i in {1..10}; do
    curl -s http://example.com > /dev/null
    sleep 1
done

wait
echo "=== ANALYSIS COMPLETE ==="
```

---

## 13. Exercises and Challenges

### 13.1. Basic Exercises

**Exercise 1**: Modify the one-liner for monitoring opened files so that it displays only files from `/etc/`:

```bash
# Starting solution:
sudo bpftrace -e 'tracepoint:syscalls:sys_enter_openat 
    /str(args->filename) == "/etc/*"/ { ... }'
```

**Exercise 2**: Create a bpftrace script that counts how many bytes each process reads, displaying the top 5 every 10 seconds.

**Exercise 3**: Use `biolatency` to compare I/O latency between an HDD and an SSD (if available).

### 13.2. Advanced Exercises

**Exercise 4**: Write a BCC Python program that monitors all `connect()` calls and displays the destination IP address in human-readable format.

**Exercise 5**: Implement a "container-aware" tracer that filters events by cgroup namespace.

**Exercise 6**: Create a profiling script that generates output compatible with flame graphs (folded stacks).

### 13.3. Project: Performance Alerting System

Implement a system that:
1. Continuously monitors latency of critical operations (I/O, network, system calls)
2. Detects anomalies (latencies > 2x the average)
3. Captures stack traces when anomalies are detected
4. Exports metrics to Prometheus

---

## 14. References and Further Reading

### 14.1. Official Documentation

- [Kernel BPF Documentation](https://www.kernel.org/doc/html/latest/bpf/index.html)
- [bpftrace Reference Guide](https://github.com/iovisor/bpftrace/blob/master/docs/reference_guide.md)
- [BCC Tools Tutorial](https://github.com/iovisor/bcc/blob/master/docs/tutorial.md)
- [libbpf Documentation](https://libbpf.readthedocs.io/)

### 14.2. Recommended Books

1. **Gregg, B.** (2019). *BPF Performance Tools: Linux System and Application Observability*. Addison-Wesley. — The fundamental reference for eBPF in practice
2. **Gregg, B.** (2020). *Systems Performance: Enterprise and the Cloud* (2nd ed.). Prentice Hall. — Broader context on performance methodologies
3. **Rice, L.** (2023). *Learning eBPF*. O'Reilly Media. — Modern and accessible introduction

### 14.3. Online Resources

- [Brendan Gregg's eBPF Page](https://www.brendangregg.com/ebpf.html) — Complete collection of materials
- [ebpf.io](https://ebpf.io/) — The eBPF community website
- [Cilium eBPF Documentation](https://docs.cilium.io/en/stable/bpf/) — Kubernetes/networking perspective

### 14.4. Academic Papers

- McCanne, S., & Jacobson, V. (1993). *The BSD Packet Filter: A New Architecture for User-level Packet Capture*. USENIX Winter Conference.
- Starovoitov, A., & Borkmann, D. (2014). *Extending extended BPF*. Linux Plumbers Conference.

---

## Summary

eBPF represents a paradigm shift in Linux systems observability, offering capabilities previously impossible without modifying the kernel or risking instability. This module covered:

1. **Fundamental architecture**: verifier, JIT, maps, helpers
2. **Program types**: kprobes, tracepoints, XDP, tc, cgroup hooks
3. **Practical tooling**: bpftrace for rapid diagnostics, BCC for pre-built tools
4. **Production scenarios**: USE methodologies, latency debugging, memory leaks, network problems
5. **Security considerations**: privileges, verifier, signed BPF

For students who wish to excel in Site Reliability Engineering, Cloud Infrastructure or Performance Engineering roles, mastering eBPF becomes a differentiating competence in the job market.

---

*This material was prepared for the Operating Systems course, ASE Bucharest - CSIE, 2025-2026.*

---

## Self-Assessment

### Verification Questions

1. **[REMEMBER]** What is a kernel module? What are the mandatory functions (`init` and `exit`) and how is a module loaded/unloaded?
2. **[UNDERSTAND]** Explain what eBPF is and why it is considered revolutionary for observability and security in Linux.
3. **[ANALYSE]** Compare developing a classic kernel module with writing an eBPF program. What are the advantages and limitations of eBPF?

### Mini-Challenge (optional)

List the loaded kernel modules with `lsmod` and identify 3 modules, explaining the role of each.

---


---


---


---

## Recommended Reading

### Mandatory Resources

**Official documentation**
- [eBPF.io](https://ebpf.io/) — The official eBPF community website
- [BCC Reference Guide](https://github.com/iovisor/bcc/blob/master/docs/reference_guide.md) — Complete BCC reference
- [bpftrace Reference](https://github.com/iovisor/bpftrace/blob/master/docs/reference_guide.md)

**Brendan Gregg Resources**
- [BPF Performance Tools](https://www.brendangregg.com/bpf-performance-tools-book.html) — The reference book
- [eBPF Tracing Tools](https://www.brendangregg.com/ebpf.html) — Complete collection of materials

### Recommended Resources

**Classic Papers**
- McCanne & Jacobson (1993): "The BSD Packet Filter" — The original BPF paper
- Gregg (2019): "BPF Performance Tools" — Chapters 1-3 for fundamentals

**Linux man pages**
```bash
man 2 bpf           # The bpf() syscall
man 7 bpf-helpers   # Helper functions available in eBPF programs
```

### Video Resources

- **Brendan Gregg - eBPF Superpowers** (Performance Summit)
- **Liz Rice - eBPF Deep Dive** (KubeCon talks)
- **Kernel Recipes** — Multiple presentations about eBPF internals

### Projects for Study

- [libbpf-bootstrap](https://github.com/libbpf/libbpf-bootstrap) — Template for modern eBPF programs
- [Cilium](https://github.com/cilium/cilium) — eBPF-based Kubernetes networking

## Nuances and Special Cases

### What we did NOT cover (didactic limitations)

- **BTF (BPF Type Format)**: Type information for CO-RE (Compile Once, Run Everywhere).
- **BPF LSM**: Linux Security Module based on eBPF for custom security policies.
- **BPF iterators**: Efficient iteration over kernel structures (processes, files, connections).

### Common mistakes to avoid

1. **Infinite loops in eBPF**: The verifier will reject them; use bounded loops.
2. **Direct kernel memory access**: Requires helper functions (`bpf_probe_read`).
3. **Assuming kprobe stability**: Internal functions can change between kernel versions.

### Open questions remaining

- Will eBPF become the standard for kernel extensibility on all operating systems (Windows eBPF)?
- Can eBPF programs run safely on accelerators (SmartNICs, DPUs)?

## Looking Ahead

**Optional Continuation: C18supp — NPU Integration in Operating Systems**

This is the last supplementary module. If eBPF has whetted your appetite for kernel-level programming, C18 explores how modern operating systems manage specialised AI/ML processors (NPU, Neural Engine, TPU).

**Recommended preparation:**
- Research what AI accelerator your device has (if any)
- Read about Apple Neural Engine, Intel NPU, or Google TPU

## Visual Summary

```
┌─────────────────────────────────────────────────────────────────┐
│                    WEEK 17: KERNEL DEV — RECAP                  │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  KERNEL MODULES                                                 │
│  ├── Code that loads dynamically into kernel                   │
│  ├── init_module(): on load (insmod)                           │
│  ├── cleanup_module(): on unload (rmmod)                       │
│  └── Compilation: special Makefile with KBUILD                 │
│                                                                 │
│  eBPF (Extended Berkeley Packet Filter)                         │
│  ├── Safe code that runs in kernel                             │
│  ├── Verifier: guarantees termination and safety               │
│  ├── Use cases: networking, tracing, security                  │
│  └── Tools: bpftrace, bcc, libbpf                              │
│                                                                 │
│  TRACING & OBSERVABILITY                                        │
│  ├── ftrace: kernel built-in tracing                           │
│  ├── perf: performance counters                                │
│  └── bpftrace: eBPF one-liner scripting                        │
│                                                                 │
│  KERNEL DEBUGGING                                               │
│  ├── printk(): printf for kernel                               │
│  ├── dmesg: kernel message buffer                              │
│  └── /proc, /sys: interface with kernel                        │
│                                                                 │
│  💡 TAKEAWAY: eBPF = the future of observability in Linux      │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

