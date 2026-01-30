# Concept Map — Introduction to Operating Systems

> Course 01 | Visual representation of key concepts and relationships

---

## Core Concept: What is an Operating System?

```
                         ┌─────────────────────────────┐
                         │     OPERATING SYSTEM        │
                         │  (Software Intermediary)    │
                         └─────────────┬───────────────┘
                                       │
           ┌───────────────────────────┼───────────────────────────┐
           │                           │                           │
           ▼                           ▼                           ▼
   ┌───────────────┐           ┌───────────────┐           ┌───────────────┐
   │   EXTENDED    │           │   RESOURCE    │           │   SECURITY    │
   │   MACHINE     │           │   MANAGER     │           │   ENFORCER    │
   └───────┬───────┘           └───────┬───────┘           └───────┬───────┘
           │                           │                           │
           ▼                           ▼                           ▼
   Abstracts hardware           Allocates:                 Protects:
   complexity into              • CPU time                 • Memory isolation
   simple interfaces            • Memory space             • File permissions
   (files, processes)           • I/O devices              • User privileges
```

---

## OS Functions Overview

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        FIVE CORE OS FUNCTIONS                                │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌─────────────┐   ┌─────────────┐   ┌─────────────┐   ┌─────────────┐    │
│  │  PROCESS    │   │   MEMORY    │   │    FILE     │   │     I/O     │    │
│  │ MANAGEMENT  │   │ MANAGEMENT  │   │ MANAGEMENT  │   │ MANAGEMENT  │    │
│  └──────┬──────┘   └──────┬──────┘   └──────┬──────┘   └──────┬──────┘    │
│         │                 │                 │                 │            │
│    Scheduling        Allocation         Organisation      Drivers         │
│    Creation          Protection         Access control    Buffering       │
│    Termination       Virtual memory     Persistence       Interrupts      │
│                                                                             │
│                         ┌─────────────┐                                    │
│                         │  SECURITY   │                                    │
│                         └──────┬──────┘                                    │
│                                │                                           │
│                      Authentication                                        │
│                      Authorisation                                         │
│                      Auditing                                              │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Kernel Architectures Comparison

```
┌────────────────────┬────────────────────┬────────────────────┐
│    MONOLITHIC      │    MICROKERNEL     │      HYBRID        │
├────────────────────┼────────────────────┼────────────────────┤
│                    │                    │                    │
│  ┌──────────────┐  │  ┌──────────────┐  │  ┌──────────────┐  │
│  │   ALL IN     │  │  │  MINIMAL     │  │  │  SELECTIVE   │  │
│  │   KERNEL     │  │  │   CORE       │  │  │   KERNEL     │  │
│  │   SPACE      │  │  │   ONLY       │  │  │   SPACE      │  │
│  └──────────────┘  │  └──────────────┘  │  └──────────────┘  │
│                    │         │          │                    │
│  Process mgmt      │    ┌────┴────┐     │  Core + some       │
│  Memory mgmt       │    │ Servers │     │  performance-      │
│  File systems      │    │ in user │     │  critical          │
│  Drivers           │    │  space  │     │  components        │
│  Network           │    └─────────┘     │                    │
│                    │                    │                    │
├────────────────────┼────────────────────┼────────────────────┤
│ Examples:          │ Examples:          │ Examples:          │
│ • Linux            │ • Minix            │ • Windows NT       │
│ • FreeBSD          │ • QNX              │ • macOS (XNU)      │
│ • Traditional UNIX │ • seL4, L4         │ • BeOS             │
├────────────────────┼────────────────────┼────────────────────┤
│ ✓ Fast (no IPC)    │ ✓ Fault isolation  │ ✓ Balanced         │
│ ✗ One bug = crash  │ ✗ IPC overhead     │ ✓ Flexible         │
└────────────────────┴────────────────────┴────────────────────┘
```

---

## Historical Evolution Timeline

```
1950s ──────────── 1960s ──────────── 1970s ──────────── 1980s ────────────
   │                  │                  │                  │
   ▼                  ▼                  ▼                  ▼
No OS            OS/360 (IBM)        UNIX              MS-DOS
Punch cards      First universal     Thompson &        Personal
One job          OS family           Ritchie           computers
                                     Bell Labs

1990s ──────────── 2000s ──────────── 2010s ──────────── 2020s ────────────
   │                  │                  │                  │
   ▼                  ▼                  ▼                  ▼
Linux 0.01       iOS / Android       Docker            Edge AI
Torvalds         Mobile era          Containers        NPU integration
Open source                          Cloud-native      Heterogeneous
                                                       computing
```

---

## System Layers (Memory Representation)

```
HIGH ADDRESS
┌─────────────────────────────────────────────────────────────┐
│                    USER APPLICATIONS                         │
│           Browser, Editor, Spotify, VS Code                  │
├─────────────────────────────────────────────────────────────┤
│                     SYSTEM CALLS                             │
│         open(), read(), write(), fork(), exec()              │
├─────────────────────────────────────────────────────────────┤
│                    KERNEL SPACE                              │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐       │
│  │ Process  │ │ Memory   │ │  File    │ │   I/O    │       │
│  │ Subsystem│ │ Subsystem│ │ Subsystem│ │ Subsystem│       │
│  └──────────┘ └──────────┘ └──────────┘ └──────────┘       │
├─────────────────────────────────────────────────────────────┤
│                      HARDWARE                                │
│            CPU, RAM, Disk, Network, GPU                      │
└─────────────────────────────────────────────────────────────┘
LOW ADDRESS
```

---

## Key Relationships

| Concept | Relates To | Nature of Relationship |
|---------|------------|------------------------|
| Process | CPU | Scheduled by OS for execution |
| Virtual Memory | Physical RAM | Abstraction layer managed by OS |
| File | Disk Blocks | Organised by filesystem |
| System Call | Kernel | Interface for user→kernel transition |
| Interrupt | I/O Device | Hardware→OS notification mechanism |

---

*Course 01 | Operating Systems | ASE Bucharest - CSIE | 2025-2026*
