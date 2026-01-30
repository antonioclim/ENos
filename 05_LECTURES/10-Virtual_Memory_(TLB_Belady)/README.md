# Operating Systems - Week 10: Virtual Memory

> **by Revolvix** | ASE Bucharest - CSIE | Year I, Semester 2 | 2025-2026

---

## Week Objectives

1. Describe the demand paging mechanism and page fault handling
2. Explain the role of TLB and its impact on performance
3. Compare page replacement algorithms: FIFO, OPT, LRU, Clock
4. **Identify** Belady's anomaly and explain the working set

---

## Applied Context (didactic scenario): Why does the SSD "grind" when you have 100 Chrome tabs?

With 100 Chrome tabs, RAM is probably full. When you open a new tab, the OS must evict pages from RAM to disk (swap) to make room. Then it brings them back when you return to them. This constant dance RAM ↔ SSD is called paging and is the reason you hear the SSD working intensively.

> 💡 **Think about it**: Why would it be slower to use an HDD than an SSD for swap?

---

## Course Content (10/14)

### 1. Demand Paging

#### Formal Definition

> **Demand Paging** is a virtual memory technique in which pages are loaded into RAM **only when accessed** (on demand), not in advance. An access to an unloaded page generates a **page fault**.

#### The Page Fault Mechanism

```
1. CPU accesses virtual address
2. MMU consults page table
3. Valid bit = 0 → PAGE FAULT! (interrupt)
4. OS handler:
   a. Finds the page on disk (swap or executable)
   b. Finds a free frame (or evicts an existing one)
   c. Loads the page into frame
   d. Updates page table (valid = 1)
   e. Restarts the instruction that caused the fault
5. Now MMU finds the page → 
```

---

### 2. TLB (Translation Lookaside Buffer)

#### Formal Definition

> TLB is a **hardware cache** for page table mappings, providing fast address translation without accessing memory for the page table. A TLB miss requires a walk through the page table (costly).

```
Without TLB:
CPU → Memory (page table) → Memory (data) = 2 accesses

With TLB (hit):
CPU → TLB (cache) → Memory (data) = 1 memory access
```

#### Metric: TLB Hit Rate

```
Effective Access Time (EAT):

EAT = hit_rate × (TLB_time + memory_time)
    + miss_rate × (TLB_time + 2 × memory_time)

Example:
- TLB access: 10 ns
- Memory access: 100 ns
- Hit rate: 98%

EAT = 0.98 × (10 + 100) + 0.02 × (10 + 200)
    = 0.98 × 110 + 0.02 × 210
    = 107.8 + 4.2 = 112 ns

vs. Without TLB: 200 ns
→ TLB reduces time by ~44%!
```

---

### 3. Page Replacement Algorithms

#### Problem Definition

> When memory is full and a page fault occurs, **which page do we evict** to make room for the new one?

#### Algorithm 1: FIFO (First-In, First-Out)

**Definition**: Evict the page that was loaded **longest ago**.

Metaphor: Queue at the shop - first come, first served (and first to leave).

```
Reference string: 7, 0, 1, 2, 0, 3, 0, 4, 2, 3, 0, 3, 2
Frames: 3

Step│ Ref │ Frame 0 │ Frame 1 │ Frame 2 │ Fault?
────┼─────┼─────────┼─────────┼─────────┼────────
 1  │  7  │    7    │    -    │    -    │  ✓
 2  │  0  │    7    │    0    │    -    │  ✓
 3  │  1  │    7    │    0    │    1    │  ✓
 4  │  2  │    2    │    0    │    1    │  ✓ (7 out)
 5  │  0  │    2    │    0    │    1    │  ✗ (hit)
 6  │  3  │    2    │    3    │    1    │  ✓ (0 out)
...
Total page faults: 15
```

**Belady's Anomaly**: With FIFO, more frames can cause MORE page faults! (Counter-intuitive)

#### Algorithm 2: OPT (Optimal)

**Definition**: Evict the page that **will not be used for the longest time** in the future.

Metaphor: You have a crystal ball and know what you will access in the future.

```python
def opt_replace(frames, page, future_refs):
    """
    Choose the page that will be used furthest in the future.
    
    Impossible in practice (requires knowledge of the future),
    but useful as a theoretical benchmark.
    """
    farthest = -1
    victim = None
    
    for frame_page in frames:
        if frame_page not in future_refs:
            return frame_page  # Will not be used at all
        
        next_use = future_refs.index(frame_page)
        if next_use > farthest:
            farthest = next_use
            victim = frame_page
    
    return victim
```

**Result for the previous example**: 9 page faults (optimal)

#### Algorithm 3: LRU (Least Recently Used)

**Definition**: Evict the page that **has not been used for the longest time** in the past.

Metaphor: If you haven't used something for a long time, you probably won't use it soon.

**Implementations**:
1. Counter: Each page has a timestamp of last use → costly
2. Stack: Accessed page goes to top → costly operations
3. **Approximation**: Clock algorithm

```python
def lru_replace(frames, access_history):
    """
    LRU with explicit tracking.
    
    In practice: uses approximations (Clock, Second Chance)
    because exact tracking is costly.
    """
    lru_page = min(frames, key=lambda p: access_history.get(p, 0))
    return lru_page
```

#### Algorithm 4: Clock (Second Chance)

**Definition**: LRU approximation using a **reference bit**. Traverses pages circularly, gives a "second chance" to recently used pages.

```
Algorithm:
1. Pointer to "clock" starts at position 0
2. On fault:
   a. If current page has reference_bit = 0 → evict
   b. Otherwise, reference_bit = 0 and advance pointer
   c. Repeat until victim is found
3. On page access: reference_bit = 1

Visualisation (circle):
        ┌───┐
    ┌───┤ 1 ├───┐      1 = reference bit set
    │   └───┘   │
  ┌─┴─┐       ┌─┴─┐
  │ 0 │       │ 1 │    Pointer searches for first 0
  └─┬─┘       └─┬─┘
    │   ┌───┐   │
    └───┤ 0 ├───┘  ← This one will be evicted
        └───┘
```

#### Comparative Python Implementation

```python
#!/usr/bin/env python3
"""
Comparison of page replacement algorithms: FIFO, LRU, OPT, Clock
"""

from collections import deque, OrderedDict

def simulate_fifo(ref_string, num_frames):
    """FIFO: First-In, First-Out"""
    frames = deque(maxlen=num_frames)
    faults = 0
    
    for page in ref_string:
        if page not in frames:
            faults += 1
            if len(frames) == num_frames:
                frames.popleft()  # Evict the oldest
            frames.append(page)
    
    return faults

def simulate_lru(ref_string, num_frames):
    """LRU: Least Recently Used"""
    frames = OrderedDict()  # Maintains insertion order
    faults = 0
    
    for page in ref_string:
        if page in frames:
            frames.move_to_end(page)  # Update as "recently used"
        else:
            faults += 1
            if len(frames) >= num_frames:
                frames.popitem(last=False)  # Evict the least recent
            frames[page] = True
    
    return faults

def simulate_opt(ref_string, num_frames):
    """OPT: Optimal (knows the future)"""
    frames = set()
    faults = 0
    
    for i, page in enumerate(ref_string):
        if page not in frames:
            faults += 1
            if len(frames) >= num_frames:
                # Find the page used furthest in the future
                future = ref_string[i+1:]
                farthest_page = None
                farthest_idx = -1
                
                for f in frames:
                    if f not in future:
                        farthest_page = f
                        break
                    idx = future.index(f)
                    if idx > farthest_idx:
                        farthest_idx = idx
                        farthest_page = f
                
                frames.remove(farthest_page)
            frames.add(page)
    
    return faults

# Test
if __name__ == "__main__":
    ref_string = [7, 0, 1, 2, 0, 3, 0, 4, 2, 3, 0, 3, 2, 1, 2, 0, 1, 7, 0, 1]
    frames = 3
    
    print(f"Reference string: {ref_string}")
    print(f"Number of frames: {frames}")
    print()
    print(f"FIFO page faults: {simulate_fifo(ref_string, frames)}")
    print(f"LRU page faults:  {simulate_lru(ref_string, frames)}")
    print(f"OPT page faults:  {simulate_opt(ref_string, frames)}")
```

**Output:**
```
Reference string: [7, 0, 1, 2, 0, 3, 0, 4, 2, 3, 0, 3, 2, 1, 2, 0, 1, 7, 0, 1]
Number of frames: 3

FIFO page faults: 15
LRU page faults:  12
OPT page faults:  9
```

---

### 4. Working Set Model

#### Formal Definition

> **Working Set** W(t, Δ) is the set of pages referenced in the last Δ memory accesses. It represents the "active" pages of a process at a given moment.

**Principle**: If we allocate frames ≥ |Working Set|, the process runs efficiently. Otherwise: thrashing!

**Thrashing**: The process spends more time handling page faults than executing useful code.

---

## Laboratory/Seminar (Session 5/7)

### TC Materials
- TC5a-TC5d - Bash Functions
- TC6a-TC6b - Advanced Scripting

### Assignment 5: `tema5_utils.sh`

Bash function library:
- `is_number()`, `is_integer()`
- `file_exists()`, `dir_exists()`
- `to_upper()`, `to_lower()`
- `log_message()`
- Unit tests included

---

## Recommended Reading

### OSTEP
- [Chapter 19 - TLBs](https://pages.cs.wisc.edu/~remzi/OSTEP/vm-tlbs.pdf)
- [Chapter 21 - Swapping: Mechanisms](https://pages.cs.wisc.edu/~remzi/OSTEP/vm-beyondphys.pdf)
- [Chapter 22 - Swapping: Policies](https://pages.cs.wisc.edu/~remzi/OSTEP/vm-beyondphys-policy.pdf)


---

## Self-Assessment

### Verification Questions

1. **[REMEMBER]** What is TLB (Translation Lookaside Buffer)? Why is it necessary and what problem does it solve?
2. **[UNDERSTAND]** Explain Bélády's anomaly. Why, in certain cases, can increasing the number of frames lead to MORE page faults?
3. **[ANALYSE]** Compare the replacement algorithms: FIFO, LRU, Optimal. Which is theoretically the best? Which is easier to implement?

### Mini-challenge (optional)

For the reference sequence: 1,2,3,4,1,2,5,1,2,3,4,5 and 3 frames, calculate the number of page faults for FIFO and LRU.

---


---


---

## Nuances and Special Cases

### What we did NOT cover (didactic limitations)

- **Working Set Model**: Denning's formalisation for thrashing prevention.
- **Page Colouring**: Avoiding cache conflicts through intelligent frame allocation.
- **Memory compaction**: Alternative to paging for embedded systems without MMU.

### Common mistakes to avoid

1. **Exact LRU implementation**: Too costly; approximations are used (Clock, NRU).
2. **Over-commit without OOM killer**: Linux allows allocating more memory than physically exists.
3. **Swap on SSD without TRIM**: Degrades the SSD over time.

### Open questions remaining

- Can ML predict better than LRU which pages will be accessed?
- How do CXL (Compute Express Link) memories affect page replacement algorithms?

## Looking Ahead

**Week 11: The File System (Part 1)** — How do we persist data on disk? We will study the fundamental structure: inodes, directories, hard links and symbolic links. Understanding these concepts is essential for any system administrator.

**Recommended preparation:**
- Experiment with `ls -li` and `stat` on files
- Read OSTEP Chapters 39-40 (Files and Directories)

## Visual Summary

```
┌─────────────────────────────────────────────────────────────────┐
│                    WEEK 10: VIRTUAL MEMORY — RECAP              │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  VIRTUAL MEMORY = More than physical RAM                        │
│  └── Unused pages reside on DISK (swap)                         │
│                                                                 │
│  TLB (Translation Lookaside Buffer)                             │
│  ├── Cache for page → frame translations                        │
│  ├── TLB hit: fast (1 cycle)                                    │
│  └── TLB miss: page table access (slow)                         │
│                                                                 │
│  PAGE FAULT                                                     │
│  ├── Page not in memory → trap → OS                             │
│  └── OS brings page from disk → updates PT                      │
│                                                                 │
│  PAGE REPLACEMENT ALGORITHMS                                    │
│  ├── FIFO: first in, first out (simple, Bélády!)                │
│  ├── LRU: Least Recently Used (good, costly)                    │
│  ├── Clock: LRU approximation (reference bit)                   │
│  └── Optimal: evicts page used furthest in future (theoretical) │
│                                                                 │
│  BÉLÁDY'S ANOMALY (FIFO)                                        │
│  └── More frames → MORE page faults (!?)                        │
│                                                                 │
│  💡 TAKEAWAY: LRU ≈ Optimal in practice, FIFO is surprising     │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

*Materials developed by Revolvix for ASE Bucharest - CSIE*  
*Operating Systems | Year I, Semester 2 | 2025-2026*

## Scripting in Context (Bash + Python): Page faults in practice

### Included Files

- Bash: `scripts/pagefault_watch.sh` — Measures minor/major page faults with `/usr/bin/time -v`.

### Quick Run

```bash
./scripts/pagefault_watch.sh -- python3 ../SO_curs09/scripts/rss_probe.py --mb 100 --step 10
```

### Connection to this week's concepts

- Page faults are measurable events; `time -v` provides a solid starting point for the laboratory.
- The experiment becomes more accurate when you control caching and repeat measurements.

### Recommended Practice

- first run the scripts on a test directory (not on critical data);
- save the output to a file and attach it to your report/assignment if required;
- note the kernel version (`uname -r`) and Python version (`python3 --version`) when comparing results.

*Materials developed by Revolvix for ASE Bucharest - CSIE*  
*Operating Systems | Year I, Semester 2 | 2025-2026*
