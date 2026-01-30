# Operating Systems - Week 9: Memory Management (Part 1)

> **by Revolvix** | ASE Bucuresti - CSIE | Year I, Semester 2 | 2025-2026

---

## Week Objectives

After completing the materials for this week, you will be able to:

1. Describe the address space of a process and its components
2. Explain the difference between logical and physical addresses and the role of MMU
3. Compare allocation methods: contiguous, paging, segmentation
4. **Calculate** the physical address starting from the logical address with paging

---

## Applied Context (didactic scenario): How do you run 12GB Photoshop on a PC with only 8GB RAM?

You have a laptop with 8GB RAM. You open Photoshop with a 12GB project. Plus Chrome with 50 tabs. Plus Spotify. Total: maybe 20GB. With 8GB physical. How? **Virtual memory** - each process believes it has all the memory for itself, but the OS juggles in reality, moving data between RAM and disk (swap).

> 💡 **Think about it**: Why do you think the laptop becomes slow when you have too many applications open?

---

## Course Content (9/14)

### 1. Address Space

#### Formal Definition

> **Address Space** of a process is the **set of all memory addresses** that the process can reference. In modern systems with virtual memory, each process has its own virtual address space, independent of the physical space.

```
On 32 bits: Space = 2³² bytes = 4GB
On 64 bits: Space = 2⁶⁴ bytes (theoretical) = 16 EB
            Practical: 2⁴⁸ bytes = 256 TB (hardware limit)
```

#### Intuitive Explanation

**Metaphor: Flats in a building**

- **Virtual space** = The flat numbers you see on the door (101, 102, 201...)
- **Physical space** = The actual position in the building (ground-left, floor1-right...)
- MMU = The porter who knows that "Flat 205" is actually "Floor 2, Section B, Room 5"

Each tenant (process) believes they are alone in the building and have all the flats for themselves!

#### Address Space Structure

```
┌─────────────────────────────────────────┐  High addresses
│            KERNEL SPACE                  │  (0xFFFF...)
│         (shared, protected)             │
├─────────────────────────────────────────┤  
│               STACK                      │  ↓ grows downward
│        (local variables,                │
│         function parameters)            │
├─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┤
│                                          │
│           FREE SPACE                     │
│                                          │
├─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┤
│               HEAP                       │  ↑ grows upward
│        (dynamic allocation:             │
│         malloc, new)                    │
├─────────────────────────────────────────┤
│               BSS                        │  (uninitialised variables)
├─────────────────────────────────────────┤
│               DATA                       │  (initialised variables)
├─────────────────────────────────────────┤
│               TEXT                       │  (executable code)
└─────────────────────────────────────────┘  Low addresses (0x0...)
```

---

### 2. MMU and Address Translation

#### Formal Definition

> **Memory Management Unit (MMU)** is the hardware component that **translates virtual addresses** (logical) into **physical addresses** on each memory access. It also provides **protection** (checks permissions).

```
┌─────────────┐     ┌───────┐     ┌─────────────┐
│    CPU      │────►│  MMU  │────►│   Memory    │
│  (virtual)  │     │       │     │  (physical) │
└─────────────┘     └───────┘     └─────────────┘
     │                  │
     │ addr: 0x1234     │ addr: 0x7890
     │                  │
     └──── virtual ─────┴──── physical ────
```

---

### 3. Paging

#### Formal Definition

> **Paging** is a memory management scheme in which the virtual address space is divided into pages of fixed size, and physical memory into frames of the same size. A **page table** maps pages to frames.

```
Virtual address (32 bits, 4KB pages):
┌──────────────────────┬───────────────┐
│   Page Number (20b)  │ Offset (12b)  │
└──────────────────────┴───────────────┘
         ↓
    Page Table
    ┌─────────┐
 0  │ Frame 5 │
 1  │ Frame 2 │
 2  │ Invalid │
 3  │ Frame 8 │
    └─────────┘
         ↓
Physical address:
┌──────────────────────┬───────────────┐
│  Frame Number (20b)  │ Offset (12b)  │
└──────────────────────┴───────────────┘
```

#### Intuitive Explanation

**Metaphor: Library with modular shelves**

- Book = Process
- **Page from the book** = Virtual page
- Shelf = Physical frame
- **Catalogue** = Page Table

A 200-page book does not need to be on consecutive shelves! Page 1 can be on Shelf 50, Page 2 on Shelf 3, etc. The catalogue knows where each one is.

Advantage: You do not need contiguous space. You can "scatter" the book in the library.

#### Calculation Example

```
Configuration:
- Virtual address: 32 bits
- Page size: 4KB = 2¹² bytes
- Offset: 12 bits
- Page number: 32 - 12 = 20 bits

Virtual address: 0x00003204
- Hex: 0x00003204 = 0000 0000 0000 0011 0010 0000 0100 (binary)
- Page number: 0x00003 = 3
- Offset: 0x204 = 516

Page Table:
Page 3 → Frame 8

Physical address: Frame 8 × 4096 + 516 = 0x8204
```

#### Python Implementation

```python
#!/usr/bin/env python3
"""
Paging Simulation

Demonstrates:
- Virtual to physical address translation
- Page table lookup
- Page faults
"""

class PageTable:
    """Simplified page table."""
    
    def __init__(self, page_size: int = 4096):
        self.page_size = page_size
        self.entries = {}  # page_number → (frame_number, valid, permissions)
    
    def map_page(self, page_num: int, frame_num: int, perms: str = "rw"):
        """Map a page to a frame."""
        self.entries[page_num] = (frame_num, True, perms)
    
    def translate(self, virtual_addr: int) -> int:
        """Translate virtual address to physical."""
        page_num = virtual_addr // self.page_size
        offset = virtual_addr % self.page_size
        
        if page_num not in self.entries:
            raise PageFault(f"Page {page_num} not mapped!")
        
        frame_num, valid, perms = self.entries[page_num]
        
        if not valid:
            raise PageFault(f"Page {page_num} not in memory!")
        
        physical_addr = frame_num * self.page_size + offset
        
        print(f"Virtual 0x{virtual_addr:08x} → "
              f"Page {page_num}, Offset {offset} → "
              f"Frame {frame_num} → "
              f"Physical 0x{physical_addr:08x}")
        
        return physical_addr

class PageFault(Exception):
    """Exception for page fault."""
    pass

# Demo
if __name__ == "__main__":
    pt = PageTable(page_size=4096)  # 4KB pages
    
    # Mappings: Page → Frame
    pt.map_page(0, 5)   # Page 0 in Frame 5
    pt.map_page(1, 2)   # Page 1 in Frame 2
    pt.map_page(3, 8)   # Page 3 in Frame 8
    
    # Translations
    print("=== Valid translations ===")
    pt.translate(0x0000)   # Page 0, offset 0
    pt.translate(0x0204)   # Page 0, offset 516
    pt.translate(0x1000)   # Page 1, offset 0
    pt.translate(0x3204)   # Page 3, offset 516
    
    print("\n=== Page Fault ===")
    try:
        pt.translate(0x2000)   # Page 2 - not mapped!
    except PageFault as e:
        print(f"PAGE FAULT: {e}")
```

---

### 4. Fragmentation

#### Types of Fragmentation

| Type | Cause | Solution |
|------|-------|----------|
| Internal | We allocate more than needed | Variable sizes |
| External | Non-contiguous free spaces | Compaction or paging |

```
External Fragmentation (contiguous allocation):
┌─────┐  ┌─────┐  ┌─────┐
│ P1  │  │FREE │  │ P2  │  │FREE │  │ P3  │
│ 4K  │  │ 2K  │  │ 3K  │  │ 1K  │  │ 2K  │
└─────┘  └─────┘  └─────┘  └─────┘  └─────┘

Total FREE = 3K, but you cannot allocate a contiguous 3K block!

Internal Fragmentation (paging):
┌─────────────────────┐
│  Process uses       │  Page: 4KB
│  3.5KB              │  Used: 3.5KB
│  ░░░░░░░░░░░░░░░░░│  Wasted: 0.5KB (internal)
└─────────────────────┘
```

---

### 5. Brainstorm: 1GB RAM, 10 Processes × 200MB

Situation: You have 1GB physical RAM. You want to run 10 processes that request 200MB each (2GB total).

**Questions**:
1. Is it possible without swap?
2. With swap, what would be the impact?
3. What strategy would you use to decide what stays in RAM?

Solution:
- **Without swap**: Impossible simultaneously, maximum 5 processes completely in RAM
- **With swap**: Possible, but with I/O overhead when context switches
- **Strategy**: Working set - keep in RAM the recently accessed pages
- **Reality**: Most processes do not use all 200MB simultaneously!

---

## Recommended Reading

### OSTEP
- **Mandatory**: [Ch 13 - Address Spaces](https://pages.cs.wisc.edu/~remzi/OSTEP/vm-intro.pdf)
- **Mandatory**: [Ch 15 - Address Translation](https://pages.cs.wisc.edu/~remzi/OSTEP/vm-mechanism.pdf)
- **Mandatory**: [Ch 18 - Paging: Introduction](https://pages.cs.wisc.edu/~remzi/OSTEP/vm-paging.pdf)

---

## Concept Summary

| Concept | Description |
|---------|-------------|
| **Virtual address** | Address seen by the process |
| **Physical address** | Actual address in RAM |
| MMU | Hardware that translates addresses |
| Page | Virtual memory block (e.g. 4KB) |
| Frame | Physical memory block |
| **Page Table** | Mapping pages → frames |
| **Page Fault** | Page not loaded in RAM |


---

## Self-Assessment

### Verification Questions

1. **[REMEMBER]** What is paging? Define: page, frame, page table, offset.
2. **[UNDERSTAND]** Explain the difference between internal and external fragmentation. Which technique (paging vs segmentation) suffers from which type?
3. **[ANALYSE]** Analyse the advantages and disadvantages of multi-level paging compared to simple paging.

### Mini-Challenge (optional)

For a 32-bit virtual address with 4KB pages, calculate: how many bits for offset? How many for the page number?

---


---


---

## Nuances and Special Cases

### What we did NOT cover (didactic limitations)

- **Huge pages**: 2MB or 1GB pages for applications with large working set (databases, ML).
- **ASLR (Address Space Layout Randomization)**: Security through address randomisation.
- **Memory-mapped I/O (mmap)**: Mapping files directly into the address space.

### Common Mistakes to Avoid

1. **Confusion between internal and external fragmentation**: Paging → internal; Segmentation → external.
2. **Assuming all memory is equal**: NUMA systems have different latencies for local vs remote memory.
3. **Ignoring THP (Transparent Huge Pages)**: Can cause latency spikes in sensitive applications.

### Open Questions Remaining

- How will operating systems manage persistent memories (Intel Optane, CXL)?
- Will the distinction between RAM and storage disappear with NVM memories?

## Looking Ahead

**Week 10: Virtual Memory (TLB, Belady)** — We continue with virtual memory: TLB for acceleration, page replacement algorithms (FIFO, LRU, OPT) and the famous Belady anomaly that shows us "more" does not always mean "better".

**Recommended Preparation:**
- Understand why paging alone is not sufficient for performance
- Read OSTEP Chapters 18-20 (Paging, TLB)

## Visual Summary

```
┌─────────────────────────────────────────────────────────────────┐
│                    WEEK 9: MEMORY MANAGEMENT — RECAP             │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  PROBLEM: How do we allocate memory for multiple processes?     │
│                                                                 │
│  PAGING                                                         │
│  ├── Physical memory: divided into FRAMES                       │
│  ├── Virtual memory: divided into PAGES                         │
│  ├── Page Table: page → frame mapping                           │
│  └── Address: [Page number | Offset]                            │
│                                                                 │
│  SEGMENTATION                                                   │
│  ├── Logical division: code, data, stack                        │
│  ├── Variable size segments                                     │
│  └── Address: [Segment selector | Offset]                       │
│                                                                 │
│  FRAGMENTATION                                                  │
│  ├── Internal: wasted space inside the page                     │
│  └── External: free space but unallocatable (segmentation)      │
│                                                                 │
│  MULTI-LEVEL PAGING                                             │
│  └── Reduces memory for page table (sparse address space)       │
│                                                                 │
│  💡 TAKEAWAY: Paging solves external fragmentation              │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

*Materials developed by Revolvix for ASE Bucuresti - CSIE*  
*Operating Systems | Year I, Semester 2 | 2025-2026*

## Scripting in Context (Bash + Python): Address Space and RSS

### Included Files

- Bash: `scripts/memmap_inspect.sh` — Inspects `/proc/<PID>/maps` and memory summary.
- Python: `scripts/rss_probe.py` — Allocates memory in a controlled manner and reports RSS + page faults.

### Quick Run

```bash
./scripts/rss_probe.py --mb 100 --step 10
```

### Connection with This Week's Concepts

- `/proc/<PID>/maps` and `VmRSS` make the connection between the address space model and actual RAM consumption.
- `ru_minflt/ru_majflt` illustrate the difference between mappings satisfied from cache and those requiring I/O.

### Recommended Practice

- first run the scripts on a test directory (not on critical data);
- save the output to a file and attach it to the report/assignment, if required;
- note the kernel version (`uname -r`) and Python version (`python3 --version`) when comparing results.

*Materials developed by Revolvix for ASE Bucuresti - CSIE*  
*Operating Systems | Year I, Semester 2 | 2025-2026*
