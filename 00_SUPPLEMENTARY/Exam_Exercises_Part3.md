# OS — Exercises, Diagrams and Exam Questions

## Part 3: Weeks 9–14 (Memory, File Systems, Security, Virtualisation)

**Units and model scope:** memory/page/block calculations use binary units:
1 KiB = 1024 bytes, 1 MiB = 1024 KiB, 1 GiB = 1024 MiB and 1 TiB = 1024 GiB.
Legacy labels KB/MB/GB/TB within the drawn arithmetic mean those binary units;
decimal device-capacity specifications must be converted separately. Timing
figures are exercise inputs unless a measured configuration is explicitly cited.

> by Revolvix | ASE Bucharest — CSIE

### Difficulty Legend

| Symbol | Level | Time | Description |
|--------|-------|------|-------------|
| ⭐ | Easy | 3–5 min | Basic recall and understanding |
| ⭐⭐ | Medium | 5–10 min | Application of concepts |
| ⭐⭐⭐ | Hard | 10–15 min | Analysis and calculation |
| ⭐⭐⭐⭐ | Expert | 15–20 min | Evaluation and design |

> 💡 **Study tip:** Memory calculations are formula-based. Write down the formulas first, then substitute values. Double-check your powers of 2!

---

# WEEK 9: Memory Management I

## Detailed ASCII Diagrams

### Diagram 9.1: Complete Virtual Address Space

This is an illustrative x86-64 **four-level, 48-bit canonical-address** layout
with a non-PIE executable. ASLR changes placement; five-level paging uses a
different address map. Kernel mappings depend on configuration, including KPTI.
The low 4 MiB shown unmapped here are not a universal reservation. Stack limits
are configured, not universally 8 MiB. The `brk` boundary is the **upper** end
of the brk-managed heap; `malloc` can also obtain separate `mmap` regions.
String literals/read-only constants normally belong in read-only sections, not
writable DATA. The `/proc` sample is illustrative, not newly captured output.
Reference: [Linux x86-64 memory maps](https://docs.kernel.org/arch/x86/x86_64/mm.html).

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
                   │ │  brk → upper end of brk-managed HEAP       │  │
                   │ │  • malloc(), new                          │  │  Variable
                   │ │  • Dynamic allocation                     │  │
                   │ │                    ↑ grows upward          │  │
                   │ └───────────────────────────────────────────┘  │
                   │ ┌───────────────────────────────────────────┐  │
                   │ │              BSS                           │  │
                   │ │  • Uninitialised global variables         │  │  Fixed
                   │ │  • Zero-initialised by OS                 │  │
                   │ └───────────────────────────────────────────┘  │
                   │ ┌───────────────────────────────────────────┐  │
                   │ │              DATA                          │  │
                   │ │  • Initialised global variables           │  │  Fixed
                   │ │  • Writable initialised objects           │  │
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
│ Frame 165  │ Frame 291  │  ...  │ Frame 247  │  ...  │  Frame N   │     │
│  (0x0A5)   │  (0x123)   │       │  (0x0F7)   │       │            │     │
│            │            │       │            │       │            │     │
│ ┌────────┐ │ ┌────────┐ │       │ ┌────────┐ │       │            │     │
│ │  P0    │ │ │  P0    │ │       │ │  P0    │ │       │            │     │
│ │  pg 0  │ │ │  pg 1  │ │       │ │  pg 3  │ │       │            │     │
│ └────────┘ │ └────────┘ │       │ └────────┘ │       │            │     │
│            │            │       │     ↑      │       │            │     │
│            │            │       │ offset ABC │       │            │     │
│            │            │       │ byte 2748  │       │            │     │
└──────────────────────────────────────────────────────────────────────────┘
```

### Diagram 9.3: Multi-Level Page Table

The 12 KiB example below assumes a 4 KiB directory and exactly two allocated
4 KiB lower-level tables: an aligned contiguous 8 MiB mapping spanning two
4 MiB directory regions. An arbitrary or unaligned 8 MiB allocation can touch
more regions and require more tables. Unmapped regions need no lower table.

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

Process mapping an aligned contiguous 8 MiB within two 4 MiB regions:
- With one level: 4MB page table (1M entries) — and related to this, with two levels:
  - 1 Page Directory: 4KB
  - Exactly 2 lower tables here: 2 × 4 KiB = 8 KiB
  - Total: 12 KiB instead of 4 MiB, under the alignment assumption.

Page Tables for unused regions: NOT ALLOCATED!
```

---

## Solved Exercises

### Exercise 9.1: Physical Address Calculation

Problem: A system has:
- 32-bit virtual addresses
- 8KB pages
- Virtual address: 0x00005A3C

Find: page number, offset and physical address if page 2 is mapped to frame 7.

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

### Exercise 9.2: Page Table Size ⭐⭐
**Difficulty:** Medium | **Time:** ~7 min | **Bloom Level:** Apply

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

3. Backup copy requested in the problem:
   Primary table + one full backup = 2 × 4 MiB = 8 MiB
   = 8,388,608 bytes per process in this flat-table model.

ANSWER: 4 MiB for the active table; 8 MiB including the requested backup.
The backup is an exercise assumption, not an assertion that Linux maintains
one complete duplicate page table for each process.

Note: This is the main problem that motivates:
- Multi-level page tables
- Inverted page tables
```

---

## Exam-Style Questions

> ⚠️ **Exam insight:** Memory calculation questions are almost guaranteed. Memorise the key formula: Page Table Size = (Address Space ÷ Page Size) × Entry Size. Watch out for units — KB vs bytes!

9.1 (Multiple Choice) ⭐ MMU (Memory Management Unit) is responsible for:
- a) Heap memory allocation
- b) Virtual to physical address translation ✓
- c) Garbage collection
- d) Memory compaction

---

9.2 (Multiple Choice) ⭐ Internal fragmentation occurs when:
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
| With paging | Exists (last page partially used) | Base-page allocation need not be contiguous; huge pages and contiguous physical allocations can still suffer external fragmentation |

---

# WEEK 10: Virtual Memory (TLB, Page Replacement)

## Detailed ASCII Diagrams

### Diagram 10.1: TLB and Memory Access

EAT calculations here use serial TLB lookup and memory accesses, no page-walk
cache, no overlapping work and no page faults. A TLB miss is a translation-cache
miss, not necessarily a page fault. Real systems require additional modelling.

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

### Diagram 10.2: Page Replacement Algorithms — Comparison

Reference string: `7, 0, 1, 2, 0, 3, 0, 4, 2, 3, 0, 3, 2, 1, 2, 0, 1, 7, 0, 1`.
Number of frames: 3.

All frames start empty. Fill the lowest-numbered empty frame first.
FIFO advances its replacement pointer on insertion/replacement, not on hits;
LRU updates recency on every reference; OPT replaces the page whose next use is
farthest away (never used again counts as infinity). For an OPT tie choose the
lowest frame index. A hit leaves frame contents unchanged. Frame indices are
storage positions, not a sorted recency list.

#### FIFO, 3 frames

| Step | Reference | F0 | F1 | F2 | Result |
|---:|---:|---:|---:|---:|---|
| 1 | 7 | 7 | — | — | Fault |
| 2 | 0 | 7 | 0 | — | Fault |
| 3 | 1 | 7 | 0 | 1 | Fault |
| 4 | 2 | 2 | 0 | 1 | Fault |
| 5 | 0 | 2 | 0 | 1 | Hit |
| 6 | 3 | 2 | 3 | 1 | Fault |
| 7 | 0 | 2 | 3 | 0 | Fault |
| 8 | 4 | 4 | 3 | 0 | Fault |
| 9 | 2 | 4 | 2 | 0 | Fault |
| 10 | 3 | 4 | 2 | 3 | Fault |
| 11 | 0 | 0 | 2 | 3 | Fault |
| 12 | 3 | 0 | 2 | 3 | Hit |
| 13 | 2 | 0 | 2 | 3 | Hit |
| 14 | 1 | 0 | 1 | 3 | Fault |
| 15 | 2 | 0 | 1 | 2 | Fault |
| 16 | 0 | 0 | 1 | 2 | Hit |
| 17 | 1 | 0 | 1 | 2 | Hit |
| 18 | 7 | 7 | 1 | 2 | Fault |
| 19 | 0 | 7 | 0 | 2 | Fault |
| 20 | 1 | 7 | 0 | 1 | Fault |

**Page faults: 15.**

#### OPT, 3 frames

| Step | Reference | F0 | F1 | F2 | Result |
|---:|---:|---:|---:|---:|---|
| 1 | 7 | 7 | — | — | Fault |
| 2 | 0 | 7 | 0 | — | Fault |
| 3 | 1 | 7 | 0 | 1 | Fault |
| 4 | 2 | 2 | 0 | 1 | Fault |
| 5 | 0 | 2 | 0 | 1 | Hit |
| 6 | 3 | 2 | 0 | 3 | Fault |
| 7 | 0 | 2 | 0 | 3 | Hit |
| 8 | 4 | 2 | 4 | 3 | Fault |
| 9 | 2 | 2 | 4 | 3 | Hit |
| 10 | 3 | 2 | 4 | 3 | Hit |
| 11 | 0 | 2 | 0 | 3 | Fault |
| 12 | 3 | 2 | 0 | 3 | Hit |
| 13 | 2 | 2 | 0 | 3 | Hit |
| 14 | 1 | 2 | 0 | 1 | Fault |
| 15 | 2 | 2 | 0 | 1 | Hit |
| 16 | 0 | 2 | 0 | 1 | Hit |
| 17 | 1 | 2 | 0 | 1 | Hit |
| 18 | 7 | 7 | 0 | 1 | Fault |
| 19 | 0 | 7 | 0 | 1 | Hit |
| 20 | 1 | 7 | 0 | 1 | Hit |

**Page faults: 9.**

#### LRU, 3 frames

| Step | Reference | F0 | F1 | F2 | Result |
|---:|---:|---:|---:|---:|---|
| 1 | 7 | 7 | — | — | Fault |
| 2 | 0 | 7 | 0 | — | Fault |
| 3 | 1 | 7 | 0 | 1 | Fault |
| 4 | 2 | 2 | 0 | 1 | Fault |
| 5 | 0 | 2 | 0 | 1 | Hit |
| 6 | 3 | 2 | 0 | 3 | Fault |
| 7 | 0 | 2 | 0 | 3 | Hit |
| 8 | 4 | 4 | 0 | 3 | Fault |
| 9 | 2 | 4 | 0 | 2 | Fault |
| 10 | 3 | 4 | 3 | 2 | Fault |
| 11 | 0 | 0 | 3 | 2 | Fault |
| 12 | 3 | 0 | 3 | 2 | Hit |
| 13 | 2 | 0 | 3 | 2 | Hit |
| 14 | 1 | 1 | 3 | 2 | Fault |
| 15 | 2 | 1 | 3 | 2 | Hit |
| 16 | 0 | 1 | 0 | 2 | Fault |
| 17 | 1 | 1 | 0 | 2 | Hit |
| 18 | 7 | 1 | 0 | 7 | Fault |
| 19 | 0 | 1 | 0 | 7 | Hit |
| 20 | 1 | 1 | 0 | 7 | Hit |

**Page faults: 12.**

| Algorithm | Faults | Interpretation |
|---|---:|---|
| FIFO | 15 | Simple insertion order; may exhibit Belady's anomaly |
| OPT | 9 | Offline minimum for this trace, requiring future knowledge |
| LRU | 12 | Uses past recency; it does not reproduce OPT in general |

More frames cannot increase OPT or exact LRU faults (stack algorithms).
FIFO lacks that property, as the short example below demonstrates.

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

This is a single TLB in front of a two-level page table, under the serial,
no-page-fault assumptions stated above; it is not a hierarchy of multiple TLBs.

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

Problem: simulate FIFO and LRU with three initially empty frames for
`1, 2, 3, 4, 1, 2, 5, 1, 2, 3, 4, 5`. Use the policies stated in Diagram 10.2.

#### FIFO, 3 frames

| Step | Reference | F0 | F1 | F2 | Result |
|---:|---:|---:|---:|---:|---|
| 1 | 1 | 1 | — | — | Fault |
| 2 | 2 | 1 | 2 | — | Fault |
| 3 | 3 | 1 | 2 | 3 | Fault |
| 4 | 4 | 4 | 2 | 3 | Fault |
| 5 | 1 | 4 | 1 | 3 | Fault |
| 6 | 2 | 4 | 1 | 2 | Fault |
| 7 | 5 | 5 | 1 | 2 | Fault |
| 8 | 1 | 5 | 1 | 2 | Hit |
| 9 | 2 | 5 | 1 | 2 | Hit |
| 10 | 3 | 5 | 3 | 2 | Fault |
| 11 | 4 | 5 | 3 | 4 | Fault |
| 12 | 5 | 5 | 3 | 4 | Hit |

**Page faults: 9.**

#### LRU, 3 frames

| Step | Reference | F0 | F1 | F2 | Result |
|---:|---:|---:|---:|---:|---|
| 1 | 1 | 1 | — | — | Fault |
| 2 | 2 | 1 | 2 | — | Fault |
| 3 | 3 | 1 | 2 | 3 | Fault |
| 4 | 4 | 4 | 2 | 3 | Fault |
| 5 | 1 | 4 | 1 | 3 | Fault |
| 6 | 2 | 4 | 1 | 2 | Fault |
| 7 | 5 | 5 | 1 | 2 | Fault |
| 8 | 1 | 5 | 1 | 2 | Hit |
| 9 | 2 | 5 | 1 | 2 | Hit |
| 10 | 3 | 3 | 1 | 2 | Fault |
| 11 | 4 | 3 | 4 | 2 | Fault |
| 12 | 5 | 3 | 4 | 5 | Fault |

**Page faults: 10.**

FIFO has 9 faults and LRU 10 on this trace. LRU need not beat FIFO on each
individual trace; its stack property compares LRU with itself at different capacities.

---

## Exam-Style Questions

10.1 (Multiple Choice) Thrashing occurs when:
- a) TLB is too small
- b) Process spends more time in page faults than executing ✓
- c) Page size is too large
- d) Page table is single-level

---

10.2 (7p) Explain and demonstrate Belady's anomaly using FIFO for
`1, 2, 3, 4, 1, 2, 5, 1, 2, 3, 4, 5`.

The three-frame run above has 9 faults. The same reference string with four
initially empty frames gives the following complete state sequence:

#### FIFO, 4 frames

| Step | Reference | F0 | F1 | F2 | F3 | Result |
|---:|---:|---:|---:|---:|---:|---|
| 1 | 1 | 1 | — | — | — | Fault |
| 2 | 2 | 1 | 2 | — | — | Fault |
| 3 | 3 | 1 | 2 | 3 | — | Fault |
| 4 | 4 | 1 | 2 | 3 | 4 | Fault |
| 5 | 1 | 1 | 2 | 3 | 4 | Hit |
| 6 | 2 | 1 | 2 | 3 | 4 | Hit |
| 7 | 5 | 5 | 2 | 3 | 4 | Fault |
| 8 | 1 | 5 | 1 | 3 | 4 | Fault |
| 9 | 2 | 5 | 1 | 2 | 4 | Fault |
| 10 | 3 | 5 | 1 | 2 | 3 | Fault |
| 11 | 4 | 4 | 1 | 2 | 3 | Fault |
| 12 | 5 | 4 | 5 | 2 | 3 | Fault |

**Page faults: 10.**

Increasing FIFO capacity from 3 to 4 increases faults from 9 to 10 here.

---

# WEEKS 11-12: File Systems

## Detailed ASCII Diagrams

### Diagram 11.1: Inode Structure and Alternative Block Mappings

An inode stores metadata and block mapping information; a directory maps a
name to an inode number. The following metadata are an illustrative regular
file, not an actual inspected filesystem:

| Field | Example | Meaning |
|---|---|---|
| Inode number | 12345 | Filesystem-local object identifier |
| Mode | 0100644 | Regular file, rw-r--r-- |
| UID/GID | 1000/1000 | Owner and group |
| Size | 15,847 bytes | Logical length |
| Link count | 1 | Directory links to this inode |
| Blocks | 32 units of 512 bytes | 16 KiB allocated in this non-sparse 4 KiB-block example |
| Times | atime, mtime, ctime; birth time where supported | ctime is metadata-change time, not creation time |
| Mapping flags | EXTENTS flag clear in the legacy example | The extent and pointer interpretations are alternatives |

**Legacy direct/indirect model (classical ext2/ext3).** For this small file,
the first four direct pointers could be 100, 101, 102 and 103; the remaining
eight direct pointers and all three indirect pointers are zero. The following
table describes *capacity when a file grows*, not additional blocks allocated
to the 15,847-byte example. Pointers occupy 4 bytes and blocks 4 KiB.

| Inode slot | Mapping | Additional data addressability |
|---|---|---:|
| 0–11 | Direct pointers to data blocks | 12 × 4 KiB = 48 KiB |
| 12 | One block of 1024 data-block pointers | 4 MiB |
| 13 | Pointer block → pointer blocks → data | 4 GiB |
| 14 | Three pointer-block levels → data | 4 TiB |

The sum is a pointer-tree addressability calculation, not a general filesystem
maximum; pointer width, logical block limits and implementation constraints
must also be checked.

**Ext4 extent alternative.** With `EXT4_EXTENTS_FL` (0x80000), `i_block` holds
the root of an extent tree. It must not be simultaneously interpreted as the
12-direct-plus-three-indirect array. A contiguous run can be described by an
extent instead of one pointer per data block. Extent records and tree nodes
have their own format and limits. Birth timestamps are not exclusive to ext4.

Reference: [Linux ext4 inode block mappings](https://docs.kernel.org/filesystems/ext4/ifork.html).

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

Problem: Calculate the theoretical data addressability of this legacy direct/indirect pointer-tree model:

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

Total addressability = 48 KiB + 4 MiB + 4 GiB + 4 TiB
                     = 4,402,345,721,856 bytes

This arithmetic does not establish a filesystem's supported maximum file
size. Ext4 extent-based files use a different mapping; implementation,
logical-block and filesystem limits must be checked for a real configuration.
```

---

## Exam-Style Questions

11.1 (Multiple Choice) An inode does NOT contain:
- a) File permissions
- b) File size
- c) File name ✓
- d) Pointers to data blocks

---

11.2 (5p) Explain the journaling mechanism and the three modes in ext4.

Answer:

For a write-ahead redo journal, first persist the transaction records in the
journal, then persist its commit record. Only after that durable commit may
checkpointing overwrite the corresponding home locations. Once checkpointing
is durable, the old journal space can be reused. Recovery replays committed
transactions as needed and discards incomplete/uncommitted records; a crash
during checkpointing can therefore be recovered from the journal.

| ext4 mode | Journalled contents | Data ordering and limits |
|---|---|---|
| `data=journal` | File data and metadata | Both pass through the journal; additional writes can affect performance |
| `data=ordered` (usual default) | Metadata | Associated data is written before committing the metadata transaction; this is not a promise that every application write is durable |
| `data=writeback` | Metadata | File-data ordering relative to journalled metadata is weaker |

The performance and crash outcomes depend on the workload, configuration and
storage guarantees. Journaling provides filesystem crash consistency, not an
application transaction, a backup or automatic durability of every `write`.
Applications must use appropriate `fsync`/directory synchronisation protocols
when their persistence requirements demand them. The ordering is log → durable
commit → checkpoint, not home overwrite → commit.
Reference: [Linux ext4 journal documentation](https://docs.kernel.org/filesystems/ext4/journal.html).

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

Problem: compare boot time, memory overhead and isolation for a VM and a
container running a web application.

| Aspect | VM | Container |
|---|---|---|
| Execution boundary | Separate guest kernel on virtualised hardware | Processes ordinarily share the host kernel |
| Startup work | Guest/kernel/services plus application, unless restored from a snapshot | Container setup plus application; image download/build is a separate stage |
| Memory | Guest kernel and services plus application; sharing/ballooning can change cost | Application, libraries and per-container kernel/accounting costs; sharing can change cost |
| Storage | Guest image and writable state; sparse and shared images are possible | Image layers and writable state; volumes/logs need separate accounting |
| Isolation | Hypervisor and guest boundaries; escapes/misconfiguration remain possible | Namespaces/cgroups plus configured security controls; shared-kernel risks remain |
| Use cases | Different kernels, stronger separation requirements | Shared-kernel applications, repeatable application environments |

For comparison exercises only, the earlier figures may be treated as
**hypothetical inputs**: VM/container startup 30–60 s / 1–5 s, overhead
500 MiB–2 GiB / 10–100 MiB, image size 5–50 GiB / 100 MiB–1 GiB and density
10–20 / 100–1000 instances per host. No benchmark provenance supports these
ranges here. They must not be quoted as general performance facts or used to
exclude another architecture. Specify workload, host, images, runtime versions,
cache state and measurement boundaries, then measure the quantities required.

---

## Exam-Style Questions - Recapitulation

Final.1 (10p) Synthesis question: Describe step by step what happens when you type `./program` in the terminal, from pressing Enter until the process executes its first instruction.

Model answer:

1. **Shell:** reads and parses the command and arguments. A conventional
   external-command path creates a child with `fork`; shells may also use
   `posix_spawn`, optimise an `exec`, or run a builtin without a new process.
2. **Child creation:** in the fork path, the child has a new PID and initially
   inherits the prescribed resources/mappings. `fork` returns 0 in the child
   and the child's PID in the parent. The child may run before the parent resumes.
3. **Exec in that child:** `execve` checks executable access and format and
   replaces the same process's image. The PID is preserved. ELF load segments
   establish code/data mappings, BSS is zero-initialised as specified and the
   initial stack carries arguments/environment and auxiliary information.
4. **First user entry:** for a dynamically linked ELF with `PT_INTERP`, the
   initial user entry can be the dynamic linker. It loads/relocates dependencies
   before transferring to the executable's entry. A static ELF has a different
   startup path. The first instruction is not generally `main`.
5. **Scheduling and translation:** the task must be selected on a CPU and can
   block or be preempted during startup. Successful exec does not inherently
   create a second task or mandate a new READY transition. Linux fair scheduling
   began moving from CFS selection towards EEVDF in 6.6; the exact kernel/version
   matters. Context switches preserve task register state; MMU/TLB/page tables
   translate addresses and faults may cause further kernel work.
6. **Runtime:** startup code (commonly `_start` plus runtime support) performs
   the language/runtime initialisation and eventually calls `main` for this C
   programme. Other executable formats and runtimes need their own path.

References: [execve](https://man7.org/linux/man-pages/man2/execve.2.html),
[ELF format](https://man7.org/linux/man-pages/man5/elf.5.html) and
[Linux EEVDF documentation](https://docs.kernel.org/scheduler/sched-eevdf.html).

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
Number of pages = ceil(Address-space size / Page size)
Virtual page number = floor(Virtual address / Page size)
Offset = Virtual address mod Page size
Offset bits = log₂(Page size)
Page number bits = Total address bits - Offset bits

Flat Page Table Size = Number of pages × Entry size
Flat Table + one full backup = 2 × Flat Page Table Size

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

*Complete Exercise and Exam Question Kit — Operating Systems*

---

## Advanced Exercises (Evaluate & Create)

> 💡 **Real-world application:** These exercises reflect actual design decisions made by OS engineers at companies like Google, Microsoft and Amazon.

### E3.1: Storage System Analysis (Evaluate) ⭐⭐⭐⭐
**Difficulty:** Expert | **Time:** ~15 min | **Bloom Level:** Evaluate

A cloud storage service must choose a file system for its distributed storage nodes. Each node has:
- 8 × 4TB NVMe SSDs
- 256GB RAM
- 64-core CPU
- Workload: 80% reads, 20% writes, average file size 64KB

**Task:** Evaluate these file system options and recommend the best choice:

| Option | File System | Key Features |
|--------|-------------|--------------|
| A | ext4 | Journaling, mature, widely supported |
| B | XFS | Excellent large file performance, parallel I/O |
| C | Btrfs | Copy-on-write, snapshots, checksums |
| D | ZFS | End-to-end checksums, compression, dedup |

Consider:
1. Read performance for the dominant workload
2. Write amplification on SSDs
3. Data integrity guarantees
4. Operational complexity
5. Recovery time after crash

**Model Answer:**

The stated 80% reads / 20% writes and 32 TB storage workload do not determine
a universal filesystem winner. Pin kernel/filesystem versions, redundancy,
device characteristics, working set, queue depth, sync frequency, compression
and free space before comparing designs.

| Criterion | Evidence needed and design differences |
|---|---|
| Read performance | Benchmark representative sizes, concurrency and cache state. ext4, XFS, Btrfs and ZFS cannot be ranked from the read fraction alone. |
| Write amplification and SSD life | Measure host and device writes with the same durability/redundancy settings. CoW, journaling, compression and the SSD controller all affect amplification. The earlier 2–3× lifetime reduction is an **unverified hypothesis**, not an established multiplier. |
| Integrity | Distinguish metadata checksums, file-data checksums, redundancy and repair. Btrfs/ZFS data checksumming can detect corruption; repair requires a valid redundant copy. Journaling alone is not end-to-end data integrity. |
| Operations | Compare team expertise, supported features, recovery tooling, backups and integration with the chosen platform. Do not label whole filesystems mature/unstable without a pinned feature and evidence. |
| Crash recovery | Test interruption and recovery with the actual data/durability workload. A journal or CoW tree does not establish a universal recovery-time ranking; crash consistency differs from restoring accidentally deleted or corrupted data. |

**Conditional recommendation:** evaluate XFS as a candidate when established
Linux operations and parallel workloads fit the team's requirements. Compare
it with ext4 on the same workload. Evaluate Btrfs or ZFS when their checksumming,
snapshot and redundant repair features address requirements that outweigh
their operational costs. Application checksums may complement filesystem
checksums; they are not automatically cheaper or an equivalent repair scheme.
Backups remain necessary for every option. The final selection, unsupported
performance multiplier and any author-supplied measurements remain open until
the configuration and evidence are provided.

Primary feature references: [ext4 journal](https://docs.kernel.org/filesystems/ext4/journal.html),
[Btrfs checksums](https://btrfs.readthedocs.io/en/latest/Checksumming.html) and
[OpenZFS documentation](https://openzfs.github.io/openzfs-docs/).

---

### E3.2: Virtualisation Architecture (Create) ⭐⭐⭐⭐
**Difficulty:** Expert | **Time:** ~20 min | **Bloom Level:** Create

**Scenario:** Design a lightweight virtualisation solution for a university teaching lab that must:

| Requirement | Specification |
|-------------|---------------|
| Host OS | Ubuntu 24.04 LTS |
| Guest instances | 30 concurrent (one per student) |
| Guest OS | Ubuntu 24.04 minimal |
| Resources per guest | 2 vCPU, 2GB RAM, 10GB storage |
| Host hardware | 64 cores, 256GB RAM, 2TB NVMe |
| Boot time target | < 10 seconds per guest |
| Isolation level | Process-level acceptable (educational use) |

**Task:** Design the virtualisation architecture:

a) Choose between full VMs, containers, or hybrid — justify
b) Specify the technology stack (hypervisor/runtime, orchestration, networking)
c) Calculate resource allocation and overcommitment ratios
d) Design the network topology for guest internet access
e) Propose a snapshot/reset mechanism for lab sessions

**Model Answer:**

**a) Architecture.** Containers are a candidate because the question explicitly
allows process-level isolation, not because educational users are inherently
trusted. Confirm the exercises' kernel/privilege requirements and threat model.
Full VMs and a hybrid remain alternatives when separate kernels or stronger
boundaries are needed. The listed host capacity does not exclude VMs; boot
time must be measured for either design. No <2 s container or >30 s VM guarantee
follows from the architecture name. A sandbox runtime or micro-VM changes the
compatibility/performance boundary and requires its own evaluation.

**b) Technology/configuration candidate.** On this single host, a locally built
Ubuntu 24.04 teaching image plus a Docker bridge and a small inventory/reset
script can be sufficient. The image includes gcc, Python, vim and git and a
defined long-running entrypoint. Its assumed 500 MiB size is illustrative.
Pin its digest for a real course release. To enforce a 10 GiB writable-layer
quota in the example below, require the **classic overlay2 driver on XFS with
project quotas and supported d_type**, not an arbitrary ext4 backing store or
the newer containerd image-store snapshotter. The administrator must configure
and verify that storage before using the example; it does not reformat or
reconfigure the host.

**c) Resource calculations.** For this exercise take RAM limits as GiB and the
500 MB example image as 500 MiB; convert the nominal 2 TB device capacity before
planning. Guest CPU quotas total `30×2=60`, so requested CPU/64 is `0.9375×`.
This quota is time sharing, not a reservation of 60 dedicated physical cores.
With 16 GiB reserved for the host, RAM is `30×2=60 GiB` of 240 GiB, ratio `0.25×`.
An optional 4 GiB limit would be a changed configuration, not an automatic burst.
The worst-case student writable allocation is `30×10=300 GiB`, plus base images,
filesystem metadata, bounded logs and host space. The earlier average-state
estimate `500 MiB + 30×2 GiB` is about 60.49 GiB, but cannot replace worst-case
quota planning. These same totals do not by themselves rule out VMs.

**d) Network.** Use a preconfigured dedicated bridge `lab-network`, subnet
`172.20.0.0/16`, with student01 at `.0.10`, student02 at `.0.11` through student30
at `.0.39`: last octet is `9+i` for `i=1..30`. Outbound routing/NAT is configured
by the administrator and verified against campus policy. Do not assume a host
interface is named eth0. SSH exposure, authentication and permitted inbound
traffic remain explicit course/administrator decisions; this example publishes
no host ports and does not choose those policies.

**e) Reset example.** Keep a versioned base image and recreate only containers
owned by this lab. Recreating a writable layer is not a backup or preservation
of student work. Retention/export requirements must be decided before a reset.
The code refuses an incompatible storage backend or unlabelled existing target
before deletion. Its quota covers the container's writable root layer, not
arbitrary volumes, host binds, images or the separately capped daemon logs.
The image must not declare volumes; this example adds no host binds. Runtime
temporary filesystems and shared memory consume separately bounded memory.

```bash
#!/usr/bin/env bash
set -euo pipefail
# Illustrative administrator reset: --apply discards labelled container state.
# The operator must first apply the lab's explicitly chosen retention policy.
[[ ${1:-} == --apply ]] || { echo 'Usage: reset_lab.sh --apply (destructive reset of labelled lab containers)' >&2; exit 2; }
BASE_IMAGE=${BASE_IMAGE:-ase-os-lab:2024}
LABEL='enos.lab=exam-example'
fail() { echo "$*" >&2; exit 1; }
command -v docker >/dev/null || fail 'Docker CLI required'
command -v findmnt >/dev/null || fail 'findmnt required'
[[ $(docker info --format '{{.Driver}}') == overlay2 ]] || fail 'Requires classic overlay2 storage driver'
root=$(docker info --format '{{.DockerRootDir}}')
[[ $(findmnt -n -o FSTYPE -T "$root") == xfs ]] || fail 'Requires XFS backing filesystem'
options=$(findmnt -n -o OPTIONS -T "$root")
[[ ,$options, == *,pquota,* || ,$options, == *,prjquota,* ]] || fail 'Requires XFS project quotas'
docker image inspect "$BASE_IMAGE" >/dev/null || fail 'Base image must already exist locally; no pull performed'
volumes=$(docker image inspect --format '{{json .Config.Volumes}}' "$BASE_IMAGE")
[[ $volumes == null || $volumes == '{}' ]] || fail 'Image VOLUMEs would bypass the writable-layer quota'
subnets=$(docker network inspect --format '{{range .IPAM.Config}}{{.Subnet}} {{end}}' lab-network)
[[ $subnets == '172.20.0.0/16 ' ]] || fail 'Requires the preconfigured dedicated lab subnet'
# Check ownership of every existing target before the first removal.
for ((i=1; i<=30; i++)); do
    printf -v student 'student%02d' "$i"
    if docker container inspect "$student" >/dev/null 2>&1; then
        owner=$(docker container inspect --format '{{index .Config.Labels "enos.lab"}}' "$student")
        [[ $owner == exam-example ]] || fail "Refusing to reset unowned container: $student"
    fi
done
for ((i=1; i<=30; i++)); do
    printf -v student 'student%02d' "$i"
    if docker container inspect "$student" >/dev/null 2>&1; then
        docker container rm --force "$student"
    fi
    docker create --pull never --name "$student" --hostname "$student" \
        --label "$LABEL" --memory 2g --memory-swap 2g --cpus 2 \
        --storage-opt size=10G --log-opt max-size=10m --log-opt max-file=2 \
        --network lab-network --ip "172.20.0.$((9+i))" \
        "$BASE_IMAGE"
    docker start "$student"
done
```

The reset is deliberately an administrator action with explicit `--apply`.
No Docker daemon, network or container was operated to validate this text.
Syntax and simulated CLI-contract checks do not demonstrate enforcement on
XFS or completion of 30 resets in 60 seconds. That former time is an unverified
target. Measure startup/reset and verify CPU, memory and writable-layer limits
on the intended host before treating this as a deployed lab. Update the image
on a course-approved schedule and keep the exact image/configuration recorded.

References: [Docker writable-layer size option](https://docs.docker.com/reference/cli/docker/container/run/#set-storage-driver-options-per-container),
[overlay2 prerequisites](https://docs.docker.com/engine/storage/drivers/overlayfs-driver/)
and [Docker resource constraints](https://docs.docker.com/engine/containers/resource_constraints/).

---

*Materials developed by Revolvix for ASE Bucharest — CSIE*
*Year I, Semester 2 | 2025–2026*
