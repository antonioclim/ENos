# OS - Exercises, Diagrams and Exam Questions

## Part 3: Weeks 9-14 (Memory, File Systems, Security, Virtualisation)

> by Revolvix | ASE Bucharest - CSIE

---

# WEEK 9: Memory Management I

## Detailed ASCII Diagrams

### Diagram 9.1: Complete Virtual Address Space

```
═══════════════════════════════════════════════════════════════════════════
                    VIRTUAL ADDRESS SPACE (64-bit Linux)
═══════════════════════════════════════════════════════════════════════════

Address                                                              Size
────────────────────────────────────────────────────────────────────────────

0xFFFFFFFFFFFFFFFF ┌─────────────────────────────────────────────────┐
                   │                                                 │
                   │              KERNEL SPACE                       │  ~128 TB
                   │                                                 │
                   │  • Kernel code                                 │
                   │  • Kernel data structures                      │
                   │  • Drivers                                      │
                   │  • Page tables (kernel)                        │
                   │  • Direct mapped physical memory               │
                   │                                                 │
0xFFFF800000000000 ├─────────────────────────────────────────────────┤
                   │░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░│
                   │░░░░░░░░░░░░░░░ NON-CANONICAL ░░░░░░░░░░░░░░░░░░│
                   │░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░│
                   │  (Invalid addresses - 16M TB gap)              │
                   │  Access here → SEGMENTATION FAULT              │
                   │░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░│
0x0000800000000000 ├─────────────────────────────────────────────────┤
                   │                                                 │
                   │              USER SPACE                         │  ~128 TB
                   │                                                 │
0x00007FFFFFFFFFFF │ ┌───────────────────────────────────────────┐  │
                   │ │              STACK                         │  │
                   │ │  • Local variables                        │  │  ~8 MB
                   │ │  • Function parameters                    │  │  (default)
                   │ │  • Return addresses                       │  │
                   │ │                    ↓ grows downward        │  │
                   │ └───────────────────────────────────────────┘  │
                   │              │                                  │
                   │              │  (unallocated space)            │
                   │              │                                  │
                   │              │                                  │
                   │              ▼                                  │
                   │ ┌───────────────────────────────────────────┐  │
                   │ │         MEMORY MAPPED FILES               │  │
                   │ │  • Shared libraries (.so)                 │  │  Variable
                   │ │  • mmap() regions                         │  │
                   │ │  • Shared memory                          │  │
                   │ └───────────────────────────────────────────┘  │
                   │              │                                  │
                   │              │  (unallocated space)            │
                   │              │                                  │
                   │              ▲                                  │
                   │ ┌───────────────────────────────────────────┐  │
                   │ │              HEAP                          │  │
                   │ │  • malloc(), new                          │  │  Variable
                   │ │  • Dynamic allocation                     │  │
                   │ │                    ↑ grows upward          │  │
                   │ └───────────────────────────────────────────┘  │
                   │ ─ ─ ─ ─ ─ ─ program break (brk) ─ ─ ─ ─ ─ ─ ─ │
                   │ ┌───────────────────────────────────────────┐  │
                   │ │              BSS                           │  │
                   │ │  • Uninitialised global variables         │  │  Fixed
                   │ │  • Zero-initialised by OS                 │  │
                   │ └───────────────────────────────────────────┘  │
                   │ ┌───────────────────────────────────────────┐  │
                   │ │              DATA                          │  │
                   │ │  • Initialised global variables           │  │  Fixed
                   │ │  • String constants                       │  │
                   │ └───────────────────────────────────────────┘  │
                   │ ┌───────────────────────────────────────────┐  │
                   │ │              TEXT (CODE)                   │  │
                   │ │  • Executable instructions                │  │  Fixed
                   │ │  • Read-only, executable                  │  │
                   │ │  • Shared between processes (fork)        │  │
0x0000000000400000 │ └───────────────────────────────────────────┘  │
                   │                                                 │
                   │ ┌───────────────────────────────────────────┐  │
                   │ │              RESERVED                      │  │
0x0000000000000000 │ │  • NULL pointer region                    │  │  ~4 MB
                   │ │  • Access here → SIGSEGV                  │  │
                   └─┴───────────────────────────────────────────┴──┘

═══════════════════════════════════════════════════════════════════════════
VISUALISATION IN LINUX: cat /proc/PID/maps
═══════════════════════════════════════════════════════════════════════════

$ cat /proc/self/maps

00400000-00452000 r-xp 00000000 08:01 123456  /bin/cat          ← TEXT
00651000-00652000 r--p 00051000 08:01 123456  /bin/cat          ← DATA (ro)
00652000-00653000 rw-p 00052000 08:01 123456  /bin/cat          ← DATA (rw)
00653000-00674000 rw-p 00000000 00:00 0       [heap]            ← HEAP
7f1234560000-... r-xp 00000000 08:01 789012  /lib/libc-2.31.so ← SHARED LIB
...
7ffc12340000-7ffc12361000 rw-p 00000000 00:00 0 [stack]        ← STACK
7ffc123fe000-7ffc12400000 r-xp 00000000 00:00 0 [vdso]         ← VDSO

Permissions: r=read, w=write, x=execute, p=private, s=shared
```

### Diagram 9.2: Paging Mechanism

```
═══════════════════════════════════════════════════════════════════════════
                    ADDRESS TRANSLATION WITH PAGING
═══════════════════════════════════════════════════════════════════════════

VIRTUAL ADDRESS (32 bits, 4KB pages):
═══════════════════════════════════════════

┌─────────────────────────────────┬────────────────────────┐
│         Page Number             │        Offset          │
│          (20 bits)              │       (12 bits)        │
└─────────────────────────────────┴────────────────────────┘
         bits 31-12                      bits 11-0

Why 12 bits for offset?
  4KB = 4096 bytes = 2^12 → 12 bits to address any byte in page

Why 20 bits for page number?
  32 - 12 = 20 bits → 2^20 = 1M possible pages

═══════════════════════════════════════════════════════════════════════════
TRANSLATION PROCESS:
═══════════════════════════════════════════════════════════════════════════

                    VIRTUAL ADDRESS: 0x00003ABC
                    ════════════════════════════
                    
   Binary: 0000 0000 0000 0000 0011 1010 1011 1100
          └─────────────────────┘└────────────────┘
                Page Number             Offset
                  0x00003               0xABC
                  (page 3)              (2748)

                           │
                           ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                         PAGE TABLE                                       │
│  ┌───────────┬──────────────┬─────────────────────────────────────────┐ │
│  │  Index    │ Frame Number │ Control Bits                            │ │
│  ├───────────┼──────────────┼───────┬───────┬───────┬───────┬─────────┤ │
│  │     0     │     0x0A5    │   V   │  R/W  │  U/S  │   A   │   D     │ │
│  ├───────────┼──────────────┼───────┼───────┼───────┼───────┼─────────┤ │
│  │     1     │     0x123    │   1   │   1   │   1   │   0   │   0     │ │
│  ├───────────┼──────────────┼───────┼───────┼───────┼───────┼─────────┤ │
│  │     2     │     0x000    │   0   │   -   │   -   │   -   │   -     │ │ ← INVALID!
│  ├───────────┼──────────────┼───────┼───────┼───────┼───────┼─────────┤ │
│  │ →   3   ← │   → 0x0F7 ← │   1   │   1   │   1   │   1   │   0     │ │ ← WE USE THIS!
│  ├───────────┼──────────────┼───────┼───────┼───────┼───────┼─────────┤ │
│  │    ...    │     ...      │  ...  │  ...  │  ...  │  ...  │  ...    │ │
│  └───────────┴──────────────┴───────┴───────┴───────┴───────┴─────────┘ │
│                                                                          │
│  Control Bits:                                                           │
│  V = Valid (page in memory)                                             │
│  R/W = Read/Write (0=read-only, 1=read+write)                           │
│  U/S = User/Supervisor (0=kernel only, 1=user accessible)               │
│  A = Accessed (has been read/written recently)                          │
│  D = Dirty (has been modified)                                          │
└─────────────────────────────────────────────────────────────────────────┘
                           │
                           │ Frame Number = 0x0F7 (247)
                           │
                           ▼
                    PHYSICAL ADDRESS
                    ═══════════════
                    
   Frame Number (0x0F7) × Page Size (0x1000) + Offset (0xABC)
   = 0x0F7 × 0x1000 + 0xABC
   = 0x0F7000 + 0xABC
   = 0x0F7ABC

┌─────────────────────────────────┬────────────────────────┐
│       Frame Number              │        Offset          │
│         0x0F7                   │        0xABC           │
└─────────────────────────────────┴────────────────────────┘
                    = 0x0F7ABC

═══════════════════════════════════════════════════════════════════════════
PHYSICAL MEMORY VISUALISATION:
═══════════════════════════════════════════════════════════════════════════

Physical Memory (Frames):
┌──────────────────────────────────────────────────────────────────────────┐
│  Frame 0   │  Frame 1   │  ...  │ Frame 247  │  ...  │  Frame N   │     │
│  (0x0A5)   │  (0x123)   │       │  (0x0F7)   │       │            │     │
│            │            │       │            │       │            │     │
│ ┌────────┐ │ ┌────────┐ │       │ ┌────────┐ │       │            │     │
│ │  P0    │ │ │  P1    │ │       │ │  P0    │ │       │            │     │
│ │  pg 0  │ │ │  pg 1  │ │       │ │  pg 3  │ │       │            │     │
│ └────────┘ │ └────────┘ │       │ └────────┘ │       │            │     │
│            │            │       │     ↑      │       │            │     │
│            │            │       │ offset ABC │       │            │     │
│            │            │       │ byte 2748  │       │            │     │
└──────────────────────────────────────────────────────────────────────────┘
```

### Diagram 9.3: Multi-Level Page Table

```
═══════════════════════════════════════════════════════════════════════════
                    2-LEVEL PAGE TABLE (32-bit)
═══════════════════════════════════════════════════════════════════════════

Why multiple levels?
━━━━━━━━━━━━━━━━━━━━━

32-bit with 4KB pages:
- 2^20 = 1,048,576 entries in page table
- Each entry: 4 bytes
- Total: 4 MB per process JUST for page table!
- Most entries: UNUSED!

Solution: We also page the page table!

═══════════════════════════════════════════════════════════════════════════

VIRTUAL ADDRESS (32 bits):
┌────────────────┬────────────────┬────────────────────────┐
│  Page Directory│   Page Table   │        Offset          │
│    Index       │     Index      │                        │
│   (10 bits)    │   (10 bits)    │       (12 bits)        │
└────────────────┴────────────────┴────────────────────────┘
   bits 31-22       bits 21-12          bits 11-0

         CPU                           PHYSICAL MEMORY
         ═══                           ═══════════════
                                       
┌─────────────────┐
│ Virtual Address │
│   0x08049ABC    │
└────────┬────────┘
         │
         │ Extract: PD_index=0x020, PT_index=0x049, Offset=0xABC
         │
         ▼
┌─────────────────┐     
│  CR3 Register   │────────────────────┐
│ (Page Dir Base) │                    │
│    0x00123000   │                    │
└─────────────────┘                    │
                                       ▼
                        ┌─────────────────────────────────────┐
                        │         PAGE DIRECTORY               │
                        │  (1024 entries × 4 bytes = 4KB)     │
                        │  ┌─────────────────────────────────┐│
                        │  │ Index │ PT Address │ Flags      ││
                        │  ├───────┼────────────┼────────────┤│
                        │  │   0   │ 0x00200000 │ P,R/W,U/S  ││
                        │  │  ...  │    ...     │    ...     ││
                        │  │→ 32 ← │→0x00456000 │ Present=1  ││ ← We use!
                        │  │  ...  │    ...     │    ...     ││
                        │  │ 1023  │ 0x00789000 │    ...     ││
                        │  └───────┴────────────┴────────────┘│
                        └──────────────┬──────────────────────┘
                                       │
                                       │ PT Address = 0x00456000
                                       ▼
                        ┌─────────────────────────────────────┐
                        │           PAGE TABLE                 │
                        │  (1024 entries × 4 bytes = 4KB)     │
                        │  ┌─────────────────────────────────┐│
                        │  │ Index │ Frame Addr │ Flags      ││
                        │  ├───────┼────────────┼────────────┤│
                        │  │   0   │ 0x0ABC0000 │ P,R/W,U/S  ││
                        │  │  ...  │    ...     │    ...     ││
                        │  │→ 73 ← │→0x00F70000 │ Present=1  ││ ← We use!
                        │  │  ...  │    ...     │    ...     ││
                        │  └───────┴────────────┴────────────┘│
                        └──────────────┬──────────────────────┘
                                       │
                                       │ Frame Address = 0x00F70000
                                       │ + Offset 0xABC
                                       ▼
                        ┌─────────────────────────────────────┐
                        │         PHYSICAL ADDRESS             │
                        │           0x00F70ABC                 │
                        │                                      │
                        │    ┌────────────────────────────┐   │
                        │    │     Frame 0x00F70          │   │
                        │    │  ┌──────────────────────┐  │   │
                        │    │  │   byte @ 0xABC       │  │   │
                        │    │  │   (offset 2748)      │  │   │
                        │    │  └──────────────────────┘  │   │
                        │    └────────────────────────────┘   │
                        └─────────────────────────────────────┘

═══════════════════════════════════════════════════════════════════════════
ADVANTAGE: MEMORY SAVINGS
═══════════════════════════════════════════════════════════════════════════

Process using only 8MB of memory:
- With one level: 4MB page table (1M entries) — and related to this, with two levels:
  - 1 Page Directory: 4KB
  - ~2 Page Tables for 8MB: 2 × 4KB = 8KB
  - Total: ~12KB instead of 4MB!

Page Tables for unused regions: NOT ALLOCATED!
```

---

## Solved Exercises

### Exercise 9.1: Physical Address Calculation

Problem: A system has:
- 32-bit virtual addresses
- 8KB pages
- Virtual address: 0x00005A3C

Find: page number, offset, and physical address if page 2 is mapped to frame 7.

Solution:

```
1. Determine bits for offset:
   Page size = 8KB = 8192 = 2^13 bytes
   → Offset: 13 bits

2. Determine bits for page number:
   32 - 13 = 19 bits for page number

3. Decompose virtual address 0x00005A3C:
   
   Binary: 0000 0000 0000 0000 0101 1010 0011 1100
          └─────────────────────┘└───────────────┘
           Page Number (19 bits)   Offset (13 bits)
   
   Hex: 0x00005A3C
   - Page Number: 0x00005A3C >> 13 = 0x00005A3C / 8192 = 2 (page 2)
   - Offset: 0x00005A3C & 0x1FFF = 0x1A3C (6716 in decimal)

4. Calculate physical address:
   Frame 7 × 8KB + Offset
   = 7 × 8192 + 6716
   = 57344 + 6716
   = 64060
   = 0xFA3C

   Or: (Frame << 13) | Offset = (7 << 13) | 0x1A3C = 0xFA3C

ANSWER:
- Page Number: 2
- Offset: 0x1A3C (6716)
- Physical address: 0x0000FA3C
```

---

### Exercise 9.2: Page Table Size

Problem: Calculate the page table size for:
- Address space: 32 bits
- Page size: 4KB
- PT entry size: 4 bytes
- Keep a backup copy for safety

Solution:

```
1. Total number of pages:
   Address space = 2^32 bytes = 4GB
   Page size = 4KB = 2^12 bytes
   Number of pages = 2^32 / 2^12 = 2^20 = 1,048,576 pages

2. Page table size:
   Number of pages × Entry size
   = 2^20 × 4 bytes
   = 4,194,304 bytes
   = 4 MB

ANSWER: 4 MB per process (just for page table!)

Note: This is the main problem that motivates:
- Multi-level page tables
- Inverted page tables
```

---

## Exam-Style Questions

9.1 (Multiple Choice) MMU (Memory Management Unit) is responsible for:
- a) Heap memory allocation
- b) Virtual to physical address translation ✓
- c) Garbage collection
- d) Memory compaction

---

9.2 (Multiple Choice) Internal fragmentation occurs when:
- a) There are non-contiguous free spaces
- b) Allocated memory is larger than needed ✓
- c) Page table is too large
- d) TLB has a miss

---

9.3 (5p) Explain the difference between internal and external fragmentation, giving concrete examples.

Model answer:

| Type | Internal Fragmentation | External Fragmentation |
|------|------------------------|------------------------|
| Definition | Allocated memory > needed memory | Free memory is fragmented into small non-contiguous pieces |
| Cause | Allocation in fixed blocks | Allocation/deallocation in varying size blocks |
| Example | Process requests 3.5KB, gets 4KB page → 0.5KB lost | 10MB free but in 1MB pieces; can't allocate 5MB contiguously |
| Solution | Variable sizes (but increases complexity) | Compaction (costly) or Paging |
| With paging | Exists (last page partially used) | Completely eliminated! |

---

# WEEK 10: Virtual Memory (TLB, Page Replacement)

## Detailed ASCII Diagrams

### Diagram 10.1: TLB and Memory Access

```
═══════════════════════════════════════════════════════════════════════════
                    TLB (TRANSLATION LOOKASIDE BUFFER)
═══════════════════════════════════════════════════════════════════════════

                         CPU generates virtual address
                                     │
                                     ▼
                        ┌─────────────────────────┐
                        │    Virtual Address      │
                        │    Page# = 0x0123       │
                        │    Offset = 0x456       │
                        └───────────┬─────────────┘
                                    │
              ┌─────────────────────┴─────────────────────┐
              │                                           │
              ▼                                           │
┌─────────────────────────────────────┐                   │
│              TLB                     │                   │
│  ┌─────────┬─────────┬─────────┐   │                   │
│  │  Tag    │  Frame  │  Valid  │   │                   │
│  ├─────────┼─────────┼─────────┤   │                   │
│  │  0x0100 │  0x0A5  │    1    │   │                   │
│  │  0x0123 │  0x0F7  │    1    │ ← HIT!               │
│  │  0x0456 │  0x123  │    1    │   │                   │
│  │  0x0789 │  0x000  │    0    │   │                   │
│  │   ...   │   ...   │   ...   │   │                   │
│  └─────────┴─────────┴─────────┘   │                   │
│                                     │                   │
│  Lookup: O(1) - parallel!          │                   │
│  Typical size: 64-1024 entries     │                   │
└──────────────┬──────────────────────┘                   │
               │                                           │
               │                                           │
      ┌────────┴────────┐                                 │
      │                 │                                 │
      ▼                 ▼                                 │
  TLB HIT          TLB MISS                              │
  ════════         ════════                              │
      │                 │                                 │
      │                 │  Consult Page Table            │
      │                 │  (1-4 memory accesses!)        │
      │                 ▼                                 │
      │    ┌─────────────────────────────────────────┐   │
      │    │             PAGE TABLE                   │   │
      │    │  ┌─────────┬─────────┬─────────┐       │   │
      │    │  │  VPage  │  Frame  │  Flags  │       │   │
      │    │  ├─────────┼─────────┼─────────┤       │   │
      │    │  │  0x0123 │  0x0F7  │ Present │       │   │
      │    │  └─────────┴─────────┴─────────┘       │   │
      │    │                                         │   │
      │    │  → Update TLB with new mapping         │   │
      │    └─────────────────────────────────────────┘   │
      │                 │                                 │
      │                 │                                 │
      └────────┬────────┘                                 │
               │                                           │
               │ Frame# = 0x0F7                           │
               ▼                                           │
┌─────────────────────────────────────────────────────────┐
│                  PHYSICAL ADDRESS                        │
│                                                          │
│   Frame# (0x0F7) × PageSize + Offset (0x456)            │
│   = 0x0F7456                                             │
│                                                          │
└─────────────────────────────────────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────────────────────┐
│                  PHYSICAL MEMORY                         │
│                                                          │
│   Access physical address 0x0F7456                      │
│   → Return data                                          │
│                                                          │
└─────────────────────────────────────────────────────────┘

═══════════════════════════════════════════════════════════════════════════
EAT CALCULATION (EFFECTIVE ACCESS TIME):
═══════════════════════════════════════════════════════════════════════════

Let:
- TLB access time: ε (e.g. 1 ns)
- Memory access time: m (e.g. 100 ns)
- TLB hit ratio: α (e.g. 0.98)

EAT = α × (ε + m) + (1 - α) × (ε + 2m)
      ╰───────────╯   ╰─────────────────╯
        TLB hit          TLB miss
      (TLB + mem)    (TLB + PT + mem)

With α = 0.98, ε = 1 ns, m = 100 ns:
EAT = 0.98 × (1 + 100) + 0.02 × (1 + 200)
    = 0.98 × 101 + 0.02 × 201
    = 98.98 + 4.02
    = 103 ns

Without TLB: 200 ns (2 memory accesses)
With TLB: 103 ns → ~49% reduction!
```

### Diagram 10.2: Page Replacement Algorithms - Comparison

```
═══════════════════════════════════════════════════════════════════════════
            PAGE REPLACEMENT ALGORITHMS - COMPARATIVE EXAMPLE
═══════════════════════════════════════════════════════════════════════════

Reference String: 7, 0, 1, 2, 0, 3, 0, 4, 2, 3, 0, 3, 2, 1, 2, 0, 1, 7, 0, 1
Number of frames: 3

═══════════════════════════════════════════════════════════════════════════
FIFO (First-In, First-Out):
═══════════════════════════════════════════════════════════════════════════

Ref: 7  0  1  2  0  3  0  4  2  3  0  3  2  1  2  0  1  7  0  1
    ┌──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┐
F0: │7 │7 │7 │2 │2 │2 │2 │4 │4 │4 │0 │0 │0 │1 │1 │1 │1 │7 │7 │7 │
    ├──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┤
F1: │- │0 │0 │0 │0 │3 │3 │3 │2 │2 │2 │2 │2 │2 │2 │0 │0 │0 │0 │0 │
    ├──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┤
F2: │- │- │1 │1 │1 │1 │0 │0 │0 │3 │3 │3 │3 │3 │3 │3 │1 │1 │1 │1 │
    └──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┘
    PF:✓  ✓  ✓  ✓     ✓  ✓  ✓  ✓  ✓  ✓        ✓     ✓  ✓  ✓      

Total Page Faults: 15

═══════════════════════════════════════════════════════════════════════════
OPT (Optimal - Knows the Future):
═══════════════════════════════════════════════════════════════════════════

Ref: 7  0  1  2  0  3  0  4  2  3  0  3  2  1  2  0  1  7  0  1
    ┌──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┐
F0: │7 │7 │7 │2 │2 │2 │2 │2 │2 │2 │2 │2 │2 │2 │2 │2 │2 │7 │7 │7 │
    ├──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┤
F1: │- │0 │0 │0 │0 │0 │0 │4 │4 │3 │3 │3 │3 │1 │1 │1 │1 │1 │1 │1 │
    ├──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┤
F2: │- │- │1 │1 │1 │3 │3 │3 │3 │3 │0 │0 │0 │0 │0 │0 │0 │0 │0 │0 │
    └──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┘
    PF:✓  ✓  ✓  ✓     ✓     ✓     ✓  ✓        ✓              ✓      

Total Page Faults: 9 (OPTIMAL - minimum possible)

═══════════════════════════════════════════════════════════════════════════
LRU (Least Recently Used):
═══════════════════════════════════════════════════════════════════════════

Ref: 7  0  1  2  0  3  0  4  2  3  0  3  2  1  2  0  1  7  0  1
    ┌──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┐
F0: │7 │7 │7 │2 │2 │2 │2 │4 │4 │4 │0 │0 │0 │1 │1 │1 │1 │1 │1 │1 │
    ├──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┤
F1: │- │0 │0 │0 │0 │0 │0 │0 │2 │2 │2 │2 │2 │2 │2 │0 │0 │0 │0 │0 │
    ├──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┤
F2: │- │- │1 │1 │1 │3 │3 │3 │3 │3 │3 │3 │3 │3 │3 │3 │3 │7 │7 │7 │
    └──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┘
    PF:✓  ✓  ✓  ✓     ✓     ✓  ✓     ✓        ✓     ✓     ✓      

Total Page Faults: 12

═══════════════════════════════════════════════════════════════════════════
COMPARATIVE SUMMARY:
═══════════════════════════════════════════════════════════════════════════

┌───────────┬────────────┬─────────────────────────────────────────────────┐
│ Algorithm │ Page Faults│ Characteristics                                 │
├───────────┼────────────┼─────────────────────────────────────────────────┤
│  FIFO     │     15     │ Simple, but can evict useful pages             │
├───────────┼────────────┼─────────────────────────────────────────────────┤
│  OPT      │      9     │ Theoretically optimal, but practically impossible│
├───────────┼────────────┼─────────────────────────────────────────────────┤
│  LRU      │     12     │ Good approximation of OPT, implementation overhead│
└───────────┴────────────┴─────────────────────────────────────────────────┘

LRU improvement vs FIFO: (15-12)/15 = 20% fewer page faults
LRU is 12/9 = 1.33x more faults than OPT (33% overhead)
```

### Diagram 10.3: Clock Algorithm (Second Chance)

```
═══════════════════════════════════════════════════════════════════════════
                    CLOCK ALGORITHM (SECOND CHANCE)
═══════════════════════════════════════════════════════════════════════════

Structure: Circular buffer with pointer (clock hand)
Each page has a "Reference Bit" (R)
- R=1: Page has been accessed recently
- R=0: Page has not been accessed

═══════════════════════════════════════════════════════════════════════════
INITIAL STATE (4 frames):
═══════════════════════════════════════════════════════════════════════════

                    ┌───────────────┐
                    │    Frame 0    │
                    │   Page: A     │
                    │    R = 1      │
                    └───────┬───────┘
                            │
        ┌───────────────┐   │   ┌───────────────┐
        │    Frame 3    │   │   │    Frame 1    │
        │   Page: D     │───┴───│   Page: B     │
        │    R = 0      │       │    R = 1      │
        └───────────────┘       └───────────────┘
                    │               │
                    └───────┬───────┘
                            │
                    ┌───────▼───────┐
                    │    Frame 2    │
                    │   Page: C     │
                    │    R = 0      │
                    └───────────────┘
                         ▲
                         │
                      POINTER
                   (clock hand)

═══════════════════════════════════════════════════════════════════════════
PAGE FAULT: Need to replace a page with new page E
═══════════════════════════════════════════════════════════════════════════

Algorithm:
1. Check page at pointer
2. If R=0 → replace and advance
3. If R=1 → set R=0 (give second chance), advance, repeat

═══════════════════════════════════════════════════════════════════════════
STEP 1: Pointer at Frame 2, Page C
═══════════════════════════════════════════════════════════════════════════

        Check: Page C, R = 0 
        → R=0, so REPLACE!
        → Frame 2 receives Page E
        → Advance pointer to Frame 3

                    ┌───────────────┐
                    │    Frame 0    │
                    │   Page: A     │
                    │    R = 1      │
                    └───────────────┘
                            
        ┌───────────────┐       ┌───────────────┐
        │    Frame 3    │       │    Frame 1    │
        │   Page: D     │───────│   Page: B     │
        │    R = 0      │       │    R = 1      │
        └───────────────┘       └───────────────┘
             ▲                          
             │              ┌───────────────┐
          POINTER           │    Frame 2    │
                           │   Page: E     │  ← NEW!
                           │    R = 1      │
                           └───────────────┘

═══════════════════════════════════════════════════════════════════════════
EXAMPLE: Page Fault for page F (complete simulation)
═══════════════════════════════════════════════════════════════════════════

State: All R=1 (all pages recently accessed)
       Pointer at Frame 0

        STEP 1:                  STEP 2:                  STEP 3:
        Frame 0, A, R=1         Frame 1, B, R=1         Frame 2, E, R=1
        → R=1, set R=0          → R=1, set R=0          → R=1, set R=0
        → Advance               → Advance               → Advance
        
        STEP 4:                  STEP 5:
        Frame 3, D, R=1         Frame 0, A, R=0
        → R=1, set R=0          → R=0, REPLACE!
        → Advance               → A replaced with F

After a complete rotation, the first page (A) has lost 
"the second chance" and is replaced.

═══════════════════════════════════════════════════════════════════════════
IMPROVED VARIANT: CLOCK WITH DIRTY BIT
═══════════════════════════════════════════════════════════════════════════

Preference for evicting CLEAN pages (don't need to be written to disc):

┌────────────┬────────────┬────────────────────────────────────────────────┐
│     R      │     D      │ Decision                                       │
├────────────┼────────────┼────────────────────────────────────────────────┤
│     0      │     0      │ Best candidate (unused, clean)                │
│     0      │     1      │ Good candidate (unused, but needs writing)    │
│     1      │     0      │ Weak candidate (recently used)                │
│     1      │     1      │ Weakest candidate (used + dirty)              │
└────────────┴────────────┴────────────────────────────────────────────────┘
```

---

## Solved Exercises

### Exercise 10.1: EAT Calculation with Multi-Level TLB

Problem: A system has:
- 2-level page table
- TLB access: 2 ns
- Memory access: 80 ns
- TLB hit rate: 95%

Calculate EAT.

Solution:

```
With 2 levels of page table, a TLB miss requires 3 memory accesses:
1. Page Directory
2. Page Table
3. Actual data

EAT = P(TLB hit) × T(TLB hit) + P(TLB miss) × T(TLB miss)

T(TLB hit) = TLB access + 1 × Memory access
           = 2 + 80 = 82 ns

T(TLB miss) = TLB access + 3 × Memory access
            = 2 + 3×80 = 2 + 240 = 242 ns

EAT = 0.95 × 82 + 0.05 × 242
    = 77.9 + 12.1
    = 90 ns

Comparison:
- Without TLB: 3 × 80 = 240 ns
- With TLB: 90 ns
- Speedup: 240/90 = 2.67x
```

---

### Exercise 10.2: FIFO and LRU Simulation

Problem: Reference string: 1, 2, 3, 4, 1, 2, 5, 1, 2, 3, 4, 5
Frames: 3
Calculate page faults for FIFO and LRU.

Solution:

```
FIFO:
═════
Ref: 1  2  3  4  1  2  5  1  2  3  4  5
    ┌──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┐
F0: │1 │1 │1 │4 │4 │4 │5 │5 │5 │5 │5 │5 │
F1: │- │2 │2 │2 │1 │1 │1 │1 │1 │3 │3 │3 │
F2: │- │- │3 │3 │3 │2 │2 │2 │2 │2 │4 │4 │
    └──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┘
PF:  ✓  ✓  ✓  ✓  ✓  ✓  ✓        ✓  ✓    

FIFO Page Faults: 9

LRU:
════
Ref: 1  2  3  4  1  2  5  1  2  3  4  5
    ┌──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┐
F0: │1 │1 │1 │4 │4 │4 │5 │5 │5 │3 │3 │3 │
F1: │- │2 │2 │2 │1 │1 │1 │1 │1 │1 │4 │4 │
F2: │- │- │3 │3 │3 │2 │2 │2 │2 │2 │2 │5 │
    └──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┘
PF:  ✓  ✓  ✓  ✓  ✓  ✓  ✓        ✓  ✓  ✓

LRU Page Faults: 10

SURPRISE! In this case FIFO (9) < LRU (10)!
(This is not Belady's anomaly - this is just a particular situation
where FIFO happened to perform better for this pattern)
```

---

## Exam-Style Questions

10.1 (Multiple Choice) Thrashing occurs when:
- a) TLB is too small
- b) Process spends more time in page faults than executing ✓
- c) Page size is too large
- d) Page table is single-level

---

10.2 (7p) Explain Belady's anomaly and demonstrate it with an example.

Answer:

```
BELADY'S ANOMALY: With FIFO, MORE frames can cause MORE page faults!

Demonstration with reference string: 1, 2, 3, 4, 1, 2, 5, 1, 2, 3, 4, 5

With 3 frames (calculated above): 9 page faults

With 4 frames:
═══════════════
Ref: 1  2  3  4  1  2  5  1  2  3  4  5
    ┌──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┐
F0: │1 │1 │1 │1 │1 │1 │5 │5 │5 │5 │5 │5 │
F1: │- │2 │2 │2 │2 │2 │2 │1 │1 │1 │1 │1 │
F2: │- │- │3 │3 │3 │3 │3 │3 │2 │2 │2 │2 │
F3: │- │- │- │4 │4 │4 │4 │4 │4 │3 │3 │3 │
    └──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┘
PF:  ✓  ✓  ✓  ✓        ✓  ✓  ✓  ✓  ✓  ✓

Page Faults with 4 frames: 10

CONCLUSION: 3 frames → 9 faults, 4 frames → 10 faults!
More resources = worse performance (counterintuitive!)

CAUSE: FIFO doesn't consider access frequency/recency.
Can evict a frequently used page just because it was 
loaded first.

SOLUTION: LRU and OPT do NOT have Belady's anomaly (they are "stack algorithms").
```

---

# WEEKS 11-12: File Systems

## Detailed ASCII Diagrams

### Diagram 11.1: Inode Structure

```
═══════════════════════════════════════════════════════════════════════════
                    INODE STRUCTURE (ext4)
═══════════════════════════════════════════════════════════════════════════

┌─────────────────────────────────────────────────────────────────────────┐
│                           INODE #12345                                  │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  ┌───────────────────────────────────────────────────────────────────┐ │
│  │  METADATA (does not include file name!)                           │ │
│  ├───────────────────────────────────────────────────────────────────┤ │
│  │  Type & Mode:    -rw-r--r-- (regular file, 0644)                 │ │
│  │  Owner UID:      1000 (user)                                      │ │
│  │  Owner GID:      1000 (group)                                     │ │
│  │  Size:           15,847 bytes                                     │ │
│  │  Link Count:     2 (2 hard links point here)                      │ │
│  │                                                                    │ │
│  │  Timestamps:                                                       │ │
│  │    atime:  2024-01-15 10:30:00 (last access)                      │ │
│  │    mtime:  2024-01-14 15:20:00 (last modification)                │ │
│  │    ctime:  2024-01-14 15:20:00 (last inode change)                │ │
│  │    crtime: 2024-01-10 09:00:00 (creation time - ext4 only)        │ │
│  │                                                                    │ │
│  │  Block Count:    16 (512-byte blocks = 8KB allocated)            │ │
│  │  Flags:          0x00080000 (extents used)                        │ │
│  └───────────────────────────────────────────────────────────────────┘ │
│                                                                         │
│  ┌───────────────────────────────────────────────────────────────────┐ │
│  │  BLOCK POINTERS (data block addresses)                            │ │
│  ├───────────────────────────────────────────────────────────────────┤ │
│  │                                                                    │ │
│  │  DIRECT BLOCKS (12 pointers):                                     │ │
│  │  ┌───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┐               │ │
│  │  │100│101│102│103│104│105│106│107│108│109│110│111│               │ │
│  │  └─┬─┴─┬─┴─┬─┴─┬─┴───┴───┴───┴───┴───┴───┴───┴───┘               │ │
│  │    │   │   │   │                                                   │ │
│  │    │   │   │   └──► Block 103 (4KB data)                          │ │
│  │    │   │   └──────► Block 102 (4KB data)                          │ │
│  │    │   └──────────► Block 101 (4KB data)                          │ │
│  │    └──────────────► Block 100 (4KB data)                          │ │
│  │                                                                    │ │
│  │  12 direct × 4KB = 48KB maximum with direct blocks                │ │
│  │                                                                    │ │
│  │  ─────────────────────────────────────────────────────────────    │ │
│  │                                                                    │ │
│  │  SINGLE INDIRECT POINTER:                                         │ │
│  │  ┌───┐                                                            │ │
│  │  │200│──────► Block 200 contains pointers:                        │ │
│  │  └───┘        ┌────┬────┬────┬────┬─────┐                        │ │
│  │               │1000│1001│1002│1003│ ... │                        │ │
│  │               └──┬─┴──┬─┴──┬─┴──┬─┴─────┘                        │ │
│  │                  │    │    │    │                                  │ │
│  │                  ▼    ▼    ▼    ▼                                  │ │
│  │               Data  Data  Data  Data                               │ │
│  │                                                                    │ │
│  │  1 indirect block × 1024 pointers × 4KB = 4MB additional          │ │
│  │                                                                    │ │
│  │  ─────────────────────────────────────────────────────────────    │ │
│  │                                                                    │ │
│  │  DOUBLE INDIRECT POINTER:                                         │ │
│  │  ┌───┐                                                            │ │
│  │  │300│──► Block with pointers → Blocks with pointers → Data       │ │
│  │  └───┘                                                            │ │
│  │                                                                    │ │
│  │  1024 × 1024 × 4KB = 4GB additional                               │ │
│  │                                                                    │ │
│  │  ─────────────────────────────────────────────────────────────    │ │
│  │                                                                    │ │
│  │  TRIPLE INDIRECT POINTER:                                         │ │
│  │  ┌───┐                                                            │ │
│  │  │400│──► 3 levels of indirection                                 │ │
│  │  └───┘                                                            │ │
│  │                                                                    │ │
│  │  1024 × 1024 × 1024 × 4KB = 4TB additional                       │ │
│  │                                                                    │ │
│  └───────────────────────────────────────────────────────────────────┘ │
│                                                                         │
│  MAXIMUM FILE SIZE (4KB blocks):                                       │
│  12×4KB + 1024×4KB + 1024²×4KB + 1024³×4KB ≈ 4TB                       │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

### Diagram 11.2: Hard Link vs Symbolic Link

```
═══════════════════════════════════════════════════════════════════════════
                    HARD LINK vs SYMBOLIC LINK
═══════════════════════════════════════════════════════════════════════════

═══════════════════════════════════════════════════════════════════════════
HARD LINK:
═══════════════════════════════════════════════════════════════════════════

$ echo "Hello" > original.txt
$ ln original.txt hardlink.txt
$ ls -li

12345 -rw-r--r-- 2 user group 6 Jan 15 10:00 original.txt
12345 -rw-r--r-- 2 user group 6 Jan 15 10:00 hardlink.txt
      └────────────────────────────────────────────────────
                    SAME INODE! (12345)

   DIRECTORY /home/user                    INODE TABLE
  ┌────────────────────────┐            ┌─────────────────┐
  │  Entries:              │            │                 │
  │  ┌──────────────────┐  │            │  Inode 12345:   │
  │  │ original.txt     │──┼────────────│  Type: file     │
  │  │ inode: 12345     │  │     ┌──────│  Size: 6        │
  │  └──────────────────┘  │     │      │  Links: 2 ◄─────┼── Link count!
  │  ┌──────────────────┐  │     │      │  Blocks: [100]  │
  │  │ hardlink.txt     │──┼─────┘      │                 │
  │  │ inode: 12345     │  │            └────────┬────────┘
  │  └──────────────────┘  │                     │
  └────────────────────────┘                     │
                                                 │
                                                 ▼
                                    ┌────────────────────┐
                                    │    Block 100       │
                                    │  "Hello\n"         │
                                    │                    │
                                    └────────────────────┘

After $ rm original.txt:
- Link count: 2 → 1
- Data REMAINS! (link count > 0)
- hardlink.txt works normally
- Document what you did for later reference

═══════════════════════════════════════════════════════════════════════════
SYMBOLIC LINK:
═══════════════════════════════════════════════════════════════════════════

$ ln -s original.txt symlink.txt
$ ls -li

12345 -rw-r--r-- 1 user group  6 Jan 15 10:00 original.txt
67890 lrwxrwxrwx 1 user group 12 Jan 15 10:05 symlink.txt -> original.txt
      └───────────────────────────────────────────────────────────────────
             DIFFERENT INODE! (67890)
             Type: l (link)

   DIRECTORY /home/user                    INODE TABLE
  ┌────────────────────────┐            ┌─────────────────┐
  │  Entries:              │            │  Inode 12345:   │
  │  ┌──────────────────┐  │            │  Type: file     │
  │  │ original.txt     │──┼────────────│  Links: 1       │
  │  │ inode: 12345     │  │            │  Blocks: [100]  │──► "Hello\n"
  │  └──────────────────┘  │            └─────────────────┘
  │  ┌──────────────────┐  │            ┌─────────────────┐
  │  │ symlink.txt      │──┼────────────│  Inode 67890:   │
  │  │ inode: 67890     │  │            │  Type: symlink  │
  │  └──────────────────┘  │            │  Links: 1       │
  └────────────────────────┘            │  Content:       │
                                        │  "original.txt" │──► THE PATH!
                                        └─────────────────┘

After $ rm original.txt:
- Inode 12345 deleted (link count = 0)
- symlink.txt → original.txt (BROKEN LINK!)
- $ cat symlink.txt → Error: No such file

═══════════════════════════════════════════════════════════════════════════
COMPARISON:
═══════════════════════════════════════════════════════════════════════════

┌─────────────────────┬──────────────────────┬──────────────────────────┐
│      Aspect         │     Hard Link        │     Symbolic Link        │
├─────────────────────┼──────────────────────┼──────────────────────────┤
│ Inode               │ SAME                 │ DIFFERENT                │
│ Cross-filesystem    │ ❌ No                │ ✅ Yes                   │
│ Link to directories │ ❌ No (cycles!)      │ ✅ Yes                   │
│ On target deletion  │ Data remains         │ Link broken              │
│ Space used          │ Only dir entry       │ Dir entry + new inode    │
│ Permissions         │ Those of the file    │ 777 (irrelevant)         │
│ Performance         │ Single lookup        │ Path resolution + lookup │
└─────────────────────┴──────────────────────┴──────────────────────────┘
```

---

## Solved Exercises

### Exercise 11.1: Maximum File Size Calculation

Problem: Calculate the maximum file size in ext4 with:

- Block size: 4KB
- Pointer size: 4 bytes
- 12 direct pointers, 1 single indirect, 1 double indirect, 1 triple indirect


Solution:

```
Pointers per block = 4KB / 4B = 1024 pointers

Direct:         12 × 4KB = 48 KB

Single Indirect: 1024 × 4KB = 4 MB

Double Indirect: 1024 × 1024 × 4KB = 4 GB

Triple Indirect: 1024 × 1024 × 1024 × 4KB = 4 TB

Maximum total = 48KB + 4MB + 4GB + 4TB ≈ 4TB

(In practice, ext4 uses extents for greater efficiency
and supports files up to 16TB with 4KB blocks)
```

---

## Exam-Style Questions

11.1 (Multiple Choice) An inode does NOT contain:
- a) File permissions
- b) File size
- c) File name ✓
- d) Pointers to data blocks

---

11.2 (5p) Explain the journaling mechanism and the 3 modes in ext4.

Answer:

```
JOURNALING: Technique for file system integrity

Mechanism:
1. Before modification: Write intention to journal
2. Perform the modification
3. Mark transaction complete in journal
4. On crash: Recover from journal (replay or discard)

ext4 MODES:
┌──────────────┬────────────────────────────────┬────────┬──────────┐
│     Mode     │        What is journaled        │ Speed  │ Safety   │
├──────────────┼────────────────────────────────┼────────┼──────────┤
│   journal    │ Metadata + Data (everything!)   │  Slow  │  Maximum │
├──────────────┼────────────────────────────────┼────────┼──────────┤
│   ordered    │ Metadata, but data is written   │ Medium │   Good   │
│   (default)  │ BEFORE commit                   │        │          │
├──────────────┼────────────────────────────────┼────────┼──────────┤
│   writeback  │ Only metadata (data anytime)    │  Fast  │  Minimum │
└──────────────┴────────────────────────────────┴────────┴──────────┘

ordered: Good compromise - new data is guaranteed on disc before
metadata points to it (avoids "garbage" in files).
```

---

# WEEKS 13-14: Security and Virtualisation

## Solved Exercises

### Exercise 13.1: Unix Permissions

Problem: A file has permissions `rwxr-x---`. 
a) What is the octal representation?
b) Who can execute the file?
c) What command sets these permissions?

Solution:

```
a) Octal representation:
   rwx = 4+2+1 = 7
   r-x = 4+0+1 = 5
   --- = 0+0+0 = 0
   
   ANSWER: 750

b) Who can execute:
   - Owner: YES (x in first group)
   - Group: YES (x in second group)
   - Others: NO (--- has no x)
   
   ANSWER: Owner and group members

c) Command:
   chmod 750 file
   or
   chmod u=rwx,g=rx,o= file
```

---

### Exercise 14.1: Containers vs VMs

Problem: Compare boot time, memory overhead and isolation for VM vs Container for running a web application.

Solution:

```
┌────────────────────┬──────────────────────┬──────────────────────┐
│      Aspect        │         VM           │      Container       │
├────────────────────┼──────────────────────┼──────────────────────┤
│ Boot time          │ 30-60 seconds        │ 1-5 seconds          │
│                    │ (loads entire OS)    │ (just the process)   │
├────────────────────┼──────────────────────┼──────────────────────┤
│ Memory overhead    │ 500MB-2GB            │ 10-100MB             │
│                    │ (complete guest OS)  │ (only app + libs)    │
├────────────────────┼──────────────────────┼──────────────────────┤
│ Disc footprint     │ 5-50GB               │ 100MB-1GB            │
│                    │ (OS image)           │ (image layers)       │
├────────────────────┼──────────────────────┼──────────────────────┤
│ Isolation          │ COMPLETE             │ PROCESS              │
│                    │ (virtual hardware)   │ (shared kernel)      │
├────────────────────┼──────────────────────┼──────────────────────┤
│ Security           │ Very good            │ Good (but kernel     │
│                    │ (escape difficult)   │ exploits = risk)     │
├────────────────────┼──────────────────────┼──────────────────────┤
│ Density            │ ~10-20 VMs/host      │ ~100-1000 cont/host  │
├────────────────────┼──────────────────────┼──────────────────────┤
│ Use case           │ Strict isolation,    │ Microservices,       │
│                    │ different OSes       │ CI/CD, rapid scaling │
└────────────────────┴──────────────────────┴──────────────────────┘
```

---

## Exam-Style Questions - Recapitulation

Final.1 (10p) Synthesis question: Describe step by step what happens when you type `./program` in the terminal, from pressing Enter until the process executes its first instruction.

Model answer:

```
1. SHELL (parent process):
   - Reads command from stdin
   - Parses: "./program" with arguments
   
2. FORK:

Three things matter here: shell calls fork(), kernel creates child process:, and child receives 0, parent receives child's pid.


3. EXEC (in child):
   - Child calls execve("./program", argv, envp)
   - Kernel:
     • Opens file "./program"
     • Reads ELF header (executable format)
     • Verifies permissions (x)
     • Releases old address space
     • Creates new address space:
       - TEXT: Maps code from file
       - DATA: Initialises global variables
       - BSS: Zero-initialised
       - STACK: Allocated, places argv/envp
       - HEAP: Prepared for malloc
     • Sets PC (program counter) to entry point

4. SCHEDULING:
   - New process is placed in READY queue
   - Scheduler (CFS in Linux) eventually selects it
   - Context switch:
     • Saves current process state
     • Loads new process state (registers, PC)

5. EXECUTION:
   - CPU in user mode
   - Fetch first instruction from entry point
   - MMU translates virtual address (using TLB/page table)
   - Instruction executes
   
6. RUNTIME:
   - _start() from libc runs
   - Initialises C runtime
   - Calls main() from programme
   - Programme begins actual execution
```

---

## Essential Formulae and Calculations for Exam

```
═══════════════════════════════════════════════════════════════════════════
                         IMPORTANT FORMULAE
═══════════════════════════════════════════════════════════════════════════

SCHEDULING:
───────────
Turnaround Time = Completion Time - Arrival Time
Waiting Time = Turnaround Time - Burst Time
Response Time = First Run Time - Arrival Time

CPU Utilisation = (Busy Time / Total Time) × 100%
Throughput = Number of Processes / Total Time

MEMORY:
────────
Number of pages = Virtual address / Page size
Offset bits = log₂(Page size)
Page number bits = Total address bits - Offset bits

Page Table Size = Number of pages × Entry size

TLB:
────
EAT = α × (ε + m) + (1-α) × (ε + k×m)

where:
  α = TLB hit rate
  ε = TLB access time
  m = memory access time
  k = page table levels + 1

PAGE REPLACEMENT:
─────────────────
Page Fault Rate = Page Faults / Total References
Hit Rate = 1 - Page Fault Rate

BANKER'S ALGORITHM:
───────────────────
Need[i] = Max[i] - Allocation[i]
Available = Total - Σ(Allocation)

Safe state ⟺ ∃ sequence in which all processes can finish
```

---

*Complete Exercise and Exam Question Kit - Operating Systems*

*Materials developed by Revolvix for ASE Bucharest - CSIE*
*Year I, Semester 2 | 2025-2026*
