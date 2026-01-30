# Operating Systems - Week 12: File System (Part 2)

> **by Revolvix** | ASE Bucharest - CSIE | Year I, Semester 2 | 2025-2026

---

## Week Objectives

After completing this week's materials, you will be able to:

1. Compare block allocation methods: contiguous, linked, indexed
2. Explain the journaling mechanism and the modes available in ext4
3. Describe the internal structure of ext4 and the concept of block groups
4. **Analyse** trade-offs between performance and reliability
5. **Use** commands for monitoring and diagnosing the file system

---

## Applied Context (didactic scenario): Why don't you lose data when you remove the USB "incorrectly" on Linux?

On Windows XP, you would remove the USB without "Safe Remove" and corruption was guaranteed. On modern Linux (ext4), most of the time it's OK. Why?

The secret is called **journaling**: each modification is first noted in a "journal" before being effectively applied. If the operation is interrupted (you remove the USB, power fails), the system can "replay" the journal and finish what it started or cancel the incomplete operation.

> 💡 **Think about it**: If the journal provides safety, why don't we write all data to the journal all the time?

---

## Course Content (12/14)

### 1. The Allocation Problem: Where Do We Put a File's Blocks?

#### Formal Definition

> **Block allocation** is the method by which the file system decides where on disk to store the blocks that make up a file. The choice affects performance (sequential vs. random reading) and fragmentation.

#### The Three Classic Strategies

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                       BLOCK ALLOCATION METHODS                               │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  1. CONTIGUOUS ALLOCATION                                                    │
│  ────────────────────────────                                                │
│                                                                              │
│  File A (5 blocks): [10][11][12][13][14]  ← Consecutive on disk             │
│  File B (3 blocks): [20][21][22]                                            │
│                                                                              │
│  Inode contains: (start_block, length)                                      │
│  Example: File A → (10, 5)                                                  │
│                                                                              │
│  ✅ Pro: Very fast sequential reading (a single seek)                       │
│  ✅ Pro: Simple to implement                                                │
│  ❌ Con: Severe external fragmentation                                      │
│  ❌ Con: Files cannot grow easily                                           │
│  📍 Used: CD-ROM, DVD (read-only, known in advance)                         │
│                                                                              │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  2. LINKED ALLOCATION (FAT)                                                  │
│  ────────────────────────────                                                │
│                                                                              │
│  File A: [10]──→[25]──→[11]──→[30]──→[15]──→NULL                           │
│           │      │      │      │      │                                      │
│           └──────┴──────┴──────┴──────┴── Each block contains               │
│                                            pointer to the next               │
│                                                                              │
│  FAT (File Allocation Table):                                               │
│  Index │ Next                                                               │
│  ──────┼──────                                                              │
│   10   │  25                                                                │
│   11   │  30                                                                │
│   15   │  EOF                                                               │
│   25   │  11                                                                │
│   30   │  15                                                                │
│                                                                              │
│  ✅ Pro: No external fragmentation                                          │
│  ✅ Pro: Files grow easily                                                  │
│  ❌ Con: SLOW random access (list must be traversed)                        │
│  ❌ Con: Losing one block = losing the rest of the file                     │
│  📍 Used: FAT12/16/32, USB sticks (compatibility)                           │
│                                                                              │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  3. INDEXED ALLOCATION (ext2/3/4, NTFS)                                     │
│  ───────────────────────────────────────                                     │
│                                                                              │
│  Inode contains an INDEX (array of pointers):                               │
│                                                                              │
│  Inode File A:                                                              │
│  ┌─────────────┐                                                            │
│  │ Direct[0]→10│                                                            │
│  │ Direct[1]→25│        Data blocks:                                        │
│  │ Direct[2]→11│        [10] [25] [11] [30] [15]                            │
│  │ Direct[3]→30│                                                            │
│  │ Direct[4]→15│                                                            │
│  │ ...         │                                                            │
│  │ Indirect →──┼──→ [Block with 1024 pointers]                             │
│  │ 2xIndirect→─┼──→ [Block with pointers to pointer blocks]                │
│  └─────────────┘                                                            │
│                                                                              │
│  ✅ Pro: FAST random access (O(1) for direct, O(log n) for indirect)        │
│  ✅ Pro: Supports very large files                                          │
│  ❌ Con: Overhead for small files                                           │
│  ❌ Con: More complex to implement                                          │
│  📍 Used: ext2/3/4, NTFS, HFS+, most modern systems                         │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

#### Calculation: Accessing Block N in a File

```
CONTIGUOUS ALLOCATION:
  Access block N = start + N
  Complexity: O(1)
  Disk seeks: 1

LINKED ALLOCATION:
  Access block N = traverse N links
  Complexity: O(N)
  Disk seeks: N (worst case, scattered blocks)

INDEXED ALLOCATION (ext4):
  Block N < 12: Direct[N]                    → O(1), 1 seek
  Block N < 12 + 1024: Indirect              → O(1), 2 seeks
  Block N < 12 + 1024 + 1024²: 2xIndirect    → O(1), 3 seeks
  
  Example: Accessing block 50,000 in a 200MB file
  - Contiguous: 1 seek
  - Linked: 50,000 seeks (!)
  - Indexed: 3 seeks (double indirect)
```

---

### 2. Extents: The Modern Evolution (ext4)

#### Formal Definition

> An **extent** is a sequence of contiguous blocks described as (start_block, length). Instead of storing pointers for each block, we store a single extent for a contiguous group.

#### Comparison: Pointers vs. Extents

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                      TRADITIONAL POINTERS vs EXTENTS                         │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  100 MB file, contiguous blocks on disk:                                    │
│                                                                              │
│  OLD METHOD (ext2/3): Individual pointers                                   │
│  ──────────────────────────────────────────────                              │
│  Inode:                                                                      │
│  [0]→Block 1000                                                             │
│  [1]→Block 1001                                                             │
│  [2]→Block 1002                                                             │
│  ... (25,600 pointers for 100 MB!)                                          │
│  [25599]→Block 26599                                                        │
│                                                                              │
│  Overhead: 25,600 × 4 bytes = 100 KB of metadata                            │
│                                                                              │
│  ════════════════════════════════════════════════════════════════════════   │
│                                                                              │
│  NEW METHOD (ext4): Extents                                                 │
│  ───────────────────────────────                                             │
│  Inode:                                                                      │
│  Extent 0: (start=1000, length=25600)                                       │
│                                                                              │
│  Overhead: 12 bytes!                                                        │
│                                                                              │
│  One ext4 extent = 12 bytes:                                                │
│  - 4 bytes: logical block (position in file)                                │
│  - 2 bytes: length (up to 32K blocks = 128 MB per extent)                   │
│  - 6 bytes: physical block (position on disk)                               │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

#### Extent Structure in ext4

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                          ext4 INODE WITH EXTENTS                             │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────┐            │
│  │                    EXTENT HEADER (12 bytes)                  │            │
│  │  magic: 0xF30A                                               │            │
│  │  entries: 2 (how many extents in this node)                 │            │
│  │  max: 4 (maximum capacity)                                   │            │
│  │  depth: 0 (0=leaf with data, >0=internal index)             │            │
│  └─────────────────────────────────────────────────────────────┘            │
│                             │                                                │
│                             ▼                                                │
│  ┌─────────────────────────────────────────────────────────────┐            │
│  │ EXTENT 0                                                     │            │
│  │   logical: 0 (starts at block 0 of the file)                │            │
│  │   length: 10000                                              │            │
│  │   physical: 50000 (block on disk)                           │            │
│  │   → Blocks 0-9999 of the file are in 50000-59999            │            │
│  └─────────────────────────────────────────────────────────────┘            │
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────┐            │
│  │ EXTENT 1                                                     │            │
│  │   logical: 10000                                             │            │
│  │   length: 5000                                               │            │
│  │   physical: 80000                                            │            │
│  │   → Blocks 10000-14999 are in 80000-84999                   │            │
│  └─────────────────────────────────────────────────────────────┘            │
│                                                                              │
│  60 MB file described with only 2 extents = 24 bytes!                       │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

#### Practical Verification

```bash
# Create a test file
dd if=/dev/zero of=test_file bs=1M count=100

# View extents with filefrag
filefrag -v test_file

# Typical output:
# Filesystem type is: ef53
# File size of test_file is 104857600 (25600 blocks of 4096 bytes)
#  ext:     logical_offset:        physical_offset: length:   expected: flags:
#    0:        0..   25599:      50000..     75599:  25600:             last,eof
#
# A single extent for 100 MB!

# Fragmented file (after many modifications)
filefrag -v /var/log/syslog
# May show dozens of extents if written incrementally
```

---

### 3. Fragmentation: Enemy of Performance

#### Formal Definition

> **Fragmentation** occurs when a file's blocks are scattered on disk instead of being contiguous. There is **internal** fragmentation (space wasted in the last block) and **external** fragmentation (non-contiguous blocks).

#### Types of Fragmentation

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         TYPES OF FRAGMENTATION                               │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  INTERNAL FRAGMENTATION                                                      │
│  ───────────────────────                                                     │
│                                                                              │
│  File: 5 KB                                                                 │
│  Block: 4 KB                                                                │
│                                                                              │
│  ┌────────────────┐ ┌────────────────┐                                      │
│  │ Block 1: 4 KB  │ │ Block 2: 1 KB  │                                      │
│  │ ████████████   │ │ ██░░░░░░░░░░░  │                                      │
│  │ (full)         │ │ (3 KB wasted)  │                                      │
│  └────────────────┘ └────────────────┘                                      │
│                                                                              │
│  Space allocated: 8 KB                                                      │
│  Space used: 5 KB                                                           │
│  Wasted: 3 KB (37.5%)                                                       │
│                                                                              │
│  ════════════════════════════════════════════════════════════════════════   │
│                                                                              │
│  EXTERNAL FRAGMENTATION                                                      │
│  ───────────────────────                                                     │
│                                                                              │
│  Disk after many create/delete operations:                                  │
│                                                                              │
│  [A][A][_][B][A][_][_][B][C][_][A][B][_][C][A]                              │
│                                                                              │
│  File A: blocks at positions 0,1,4,10,14                                    │
│  File B: blocks at positions 3,7,11                                         │
│  File C: blocks at positions 8,13                                           │
│                                                                              │
│  Sequential reading of file A:                                              │
│  - Requires 5 seeks instead of 1!                                           │
│  - On HDD: the difference is ENORMOUS (ms vs µs)                            │
│  - On SSD: less critical (but still matters for prefetch)                   │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

#### Impact on Performance

```
READING 100 MB SEQUENTIALLY:

Contiguous file (1 extent):
  HDD: 1 seek (10 ms) + 100 MB read (0.7 s) = ~0.71 s
  SSD: Negligible seek + 100 MB read (0.2 s) = ~0.2 s

Fragmented file (1000 fragments):
  HDD: 1000 seeks (10 s!) + 100 MB read (0.7 s) = ~10.7 s
       → 15x slower!
  SSD: 1000 negligible seeks + read (0.25 s) = ~0.25 s
       → 25% slower

Conclusion: Fragmentation is critical for HDD, less so for SSD,
but still affects performance through metadata overhead and cache misses.
```

#### Defragmentation in ext4

```bash
# Check fragmentation
sudo e4defrag -c /home/

# Output:
# Total/best extents: 1523/1200
# Average size per extent: 128 KB
# Fragmentation score: 3 (0=perfect, 100=severe)

# Defragment (only if necessary)
sudo e4defrag /home/user/large_file.db

# ext4 uses intelligent allocation (delayed allocation)
# which prevents fragmentation in most cases
```

---

### 4. Journaling: Consistency in the Face of Failure

#### Formal Definition

> **Journaling** is a technique that maintains **file system integrity** by writing modifications to a journal (circular log) **before** applying them effectively. In case of crash, the system replays the journal to reach a consistent state.

#### The Problem: Crash in the Middle of an Operation

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    CRASH SCENARIO WITHOUT JOURNALING                         │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  Operation: Create file "test.txt" with content                             │
│                                                                              │
│  Required steps (simplified):                                               │
│  1. Allocate a free inode (mark in bitmap)                                  │
│  2. Initialise the inode (permissions, timestamps)                          │
│  3. Allocate data blocks (mark in bitmap)                                   │
│  4. Write data to blocks                                                    │
│  5. Add entry to parent directory                                           │
│                                                                              │
│  ══════════════════════════════════════════════════════════════════════     │
│                                                                              │
│  WHAT HAPPENS IF CRASH AFTER STEP 3?                                        │
│                                                                              │
│  ✓ Inode allocated and initialised                                          │
│  ✓ Data blocks allocated                                                    │
│  ✗ Data NOT WRITTEN to blocks (contain garbage)                             │
│  ✗ Directory entry NOT ADDED                                                │
│                                                                              │
│  Result: INCONSISTENCY                                                       │
│  - Inode exists but not referenced by any directory → "orphan inode"        │
│  - Blocks allocated but full of rubbish                                     │
│  - Space permanently lost                                                   │
│                                                                              │
│  Another scenario: Crash after step 5 but before step 4                     │
│  - File "exists" in directory                                               │
│  - But contains GARBAGE!                                                    │
│  - Silent corruption - the worst case                                       │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

#### The Solution: Write-Ahead Logging (Journaling)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                       JOURNALING WORKFLOW                                    │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  PHASE 1: WRITE TO JOURNAL                                                   │
│  ──────────────────────────                                                  │
│                                                                              │
│  Journal (dedicated area on disk):                                          │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │ [TXN_BEGIN id=42]                                                    │    │
│  │ [INODE_UPDATE: inode 1234, mode=0644, size=100]                     │    │
│  │ [BLOCK_ALLOC: blocks 5000-5002]                                     │    │
│  │ [DIR_ENTRY: parent=500, name="test.txt", inode=1234]                │    │
│  │ [TXN_END id=42]                                                      │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                                                              │
│  At this point: the journal is COMPLETE on disk (fsync)                     │
│                                                                              │
│  ════════════════════════════════════════════════════════════════════════   │
│                                                                              │
│  PHASE 2: CHECKPOINT (effective application)                                 │
│  ──────────────────────────────────────                                      │
│                                                                              │
│  Now we write the modifications to their final locations:                   │
│  - Update inode bitmap                                                      │
│  - Update block bitmap                                                      │
│  - Write the inode                                                          │
│  - Write the directory entry                                                │
│                                                                              │
│  ════════════════════════════════════════════════════════════════════════   │
│                                                                              │
│  PHASE 3: DELETION FROM JOURNAL                                              │
│  ──────────────────────────────                                              │
│                                                                              │
│  Mark the transaction as complete → journal space can be reused             │
│                                                                              │
│  ════════════════════════════════════════════════════════════════════════   │
│                                                                              │
│  AT RECOVERY (after crash):                                                  │
│  ──────────────────────────                                                  │
│                                                                              │
│  1. Scan the journal                                                        │
│  2. Find complete transactions (TXN_BEGIN + TXN_END)                        │
│  3. Re-apply those transactions                                             │
│  4. Ignore incomplete transactions (TXN_BEGIN without TXN_END)              │
│                                                                              │
│  Result: CONSISTENT filesystem, no lengthy fsck!                            │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

#### Journaling Modes in ext4

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    ext4 JOURNALING MODES                                     │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌───────────────┬───────────────┬───────────────┬───────────────────────┐  │
│  │    MODE       │ WHAT IS       │    SPEED      │     SAFETY            │  │
│  │               │ JOURNALED     │               │                       │  │
│  ├───────────────┼───────────────┼───────────────┼───────────────────────┤  │
│  │               │               │               │                       │  │
│  │  journal      │ Metadata +    │    SLOW       │     MAXIMUM           │  │
│  │  (safest)     │ DATA          │   (2x write)  │  Data is not lost     │  │
│  │               │               │               │                       │  │
│  ├───────────────┼───────────────┼───────────────┼───────────────────────┤  │
│  │               │               │               │                       │  │
│  │  ordered      │ Metadata only │    MEDIUM     │     GOOD              │  │
│  │  (DEFAULT)    │ (data written │               │  Consistent metadata  │  │
│  │               │  first)       │               │  Data may be stale    │  │
│  │               │               │               │                       │  │
│  ├───────────────┼───────────────┼───────────────┼───────────────────────┤  │
│  │               │               │               │                       │  │
│  │  writeback    │ Metadata only │    FAST       │     MINIMUM           │  │
│  │  (fastest)    │ (no ordering) │               │  Data may be garbage  │  │
│  │               │               │               │                       │  │
│  └───────────────┴───────────────┴───────────────┴───────────────────────┘  │
│                                                                              │
│  DETAILED EXPLANATION:                                                       │
│                                                                              │
│  MODE=journal:                                                               │
│    Writes both metadata AND data to the journal                             │
│    Then writes the data to the final location                               │
│    → 2x write overhead, but 100% consistency                                │
│    → Recommended for critical databases                                     │
│                                                                              │
│  MODE=ordered (default):                                                     │
│    Writes DATA to the final location BEFORE committing metadata             │
│    On crash: data is there, metadata is consistent                          │
│    → Good compromise between speed and safety                               │
│                                                                              │
│  MODE=writeback:                                                             │
│    Writes metadata to the journal, data whenever possible                   │
│    On crash: metadata OK, but files may contain rubbish                     │
│    → Fast for non-critical workloads                                        │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

#### Verification and Configuration

```bash
# Check current journaling mode
mount | grep "on / "
# /dev/sda1 on / type ext4 (rw,relatime,errors=remount-ro)

# Detailed verification
sudo tune2fs -l /dev/sda1 | grep -i journal
# Journal inode:            8
# Journal backup:           inode blocks
# Journal features:         journal_64bit journal_checksum_v3
# Journal size:             256M

# View journal statistics
sudo dumpe2fs /dev/sda1 | grep -A 10 "Journal"

# Change mode (DANGEROUS - only at mount)
# In /etc/fstab:
# /dev/sda1  /  ext4  data=journal  0  1
# or
# /dev/sda1  /  ext4  data=writeback  0  1
```

---

### 5. Free Space Management: How Do We Find Free Blocks

#### Formal Definition

> **Free space management** is the mechanism by which the file system tracks which blocks are free and quickly finds blocks for new files.

#### Tracking Methods

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                      FREE SPACE TRACKING METHODS                             │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  1. BITMAP (ext4, NTFS)                                                      │
│  ──────────────────────                                                      │
│                                                                              │
│  1 bit per block: 0=free, 1=occupied                                        │
│                                                                              │
│  For a 1 TB disk with 4 KB blocks:                                          │
│  - 256 million blocks                                                       │
│  - 256 Mbit = 32 MB for bitmap                                              │
│  - 0.003% overhead                                                          │
│                                                                              │
│  Bitmap: [1][1][0][1][0][0][0][1][1][0][1][0]...                            │
│           ↓  ↓  ↓  ↓                                                        │
│          B0 B1 B2 B3                                                        │
│               ↑                                                              │
│              FREE                                                            │
│                                                                              │
│  ✅ Pro: Compact, O(n) worst case for finding                               │
│  ✅ Pro: Easy to verify consistency                                         │
│  ❌ Con: Linear scan to find free block                                     │
│                                                                              │
│  ════════════════════════════════════════════════════════════════════════   │
│                                                                              │
│  2. LINKED LIST (old)                                                        │
│  ───────────────────────                                                     │
│                                                                              │
│  Free blocks form a list:                                                   │
│  Free list head → Block 5 → Block 12 → Block 7 → NULL                       │
│                                                                              │
│  ❌ Con: Slow traversal                                                     │
│  ❌ Con: Losing pointer = losing all free space                             │
│                                                                              │
│  ════════════════════════════════════════════════════════════════════════   │
│                                                                              │
│  3. GROUPING (ext4 - block groups)                                          │
│  ─────────────────────────────────                                           │
│                                                                              │
│  The disk is divided into groups; each group has its own bitmap             │
│                                                                              │
│  [Group 0: bitmap + data] [Group 1: bitmap + data] [Group 2...]             │
│                                                                              │
│  ✅ Pro: Locality - files tend to be in the same group                      │
│  ✅ Pro: Smaller bitmaps, faster to scan                                    │
│  ✅ Pro: Redundant metadata (copies of superblock)                          │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

### 6. VFS: Abstracting File Systems

#### Formal Definition

> **VFS (Virtual File System)** is an abstraction layer in the kernel that provides a uniform interface for all types of file systems. Applications use the same syscalls (open, read, write) regardless of the underlying filesystem.

#### VFS Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                          LINUX VFS ARCHITECTURE                              │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│                         APPLICATIONS (User Space)                            │
│                     open(), read(), write(), close()                         │
│                                │                                             │
│  ══════════════════════════════╪═════════════════════════════════════════   │
│                                │                                             │
│                         SYSTEM CALLS                                         │
│                                │                                             │
│  ┌─────────────────────────────┼─────────────────────────────────────────┐  │
│  │                             │                                          │  │
│  │                      VFS LAYER                                         │  │
│  │              (Virtual File System Switch)                              │  │
│  │                                                                        │  │
│  │  ┌──────────────────────────────────────────────────────────────────┐ │  │
│  │  │ Common VFS objects:                                               │ │  │
│  │  │ - superblock: filesystem metadata                                 │ │  │
│  │  │ - inode: file metadata (abstracted)                              │ │  │
│  │  │ - dentry: directory entry (cache)                                 │ │  │
│  │  │ - file: open file (file descriptor)                              │ │  │
│  │  └──────────────────────────────────────────────────────────────────┘ │  │
│  │                             │                                          │  │
│  └─────────────────────────────┼──────────────────────────────────────────┘  │
│                                │                                             │
│        ┌───────────────────────┼───────────────────────┐                    │
│        │                       │                       │                    │
│        ▼                       ▼                       ▼                    │
│  ┌──────────┐           ┌──────────┐           ┌──────────┐                 │
│  │   ext4   │           │   NTFS   │           │   NFS    │                 │
│  │  driver  │           │  driver  │           │  driver  │                 │
│  └────┬─────┘           └────┬─────┘           └────┬─────┘                 │
│       │                      │                      │                       │
│       ▼                      ▼                      ▼                       │
│  ┌──────────┐           ┌──────────┐           ┌──────────┐                 │
│  │ Local    │           │ Local    │           │ Network  │                 │
│  │ Disk     │           │ Disk     │           │ Server   │                 │
│  └──────────┘           └──────────┘           └──────────┘                 │
│                                                                              │
│  VFS advantages:                                                             │
│  ✓ Applications do not know which filesystem they use                       │
│  ✓ Common code for cache, permissions, locking                              │
│  ✓ Easy to add new filesystems                                              │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

#### Practical Verification

```bash
# What filesystems are available?
cat /proc/filesystems

# What filesystems are mounted?
mount | column -t

# Details about a mount
findmnt /home

# VFS cache statistics
cat /proc/slabinfo | grep -E 'dentry|inode'
```

---

### 7. Modern Filesystem Comparison

#### Comparative Table

| Characteristic | ext4 | XFS | Btrfs | ZFS |
|----------------|------|-----|-------|-----|
| **Journaling** | Yes | Yes (metadata) | CoW | CoW |
| **Max file size** | 16 TB | 8 EB | 16 EB | 16 EB |
| **Max volume** | 1 EB | 8 EB | 16 EB | 256 ZB |
| **Snapshots** | No | No | Yes | Yes |
| **Checksums** | Metadata | No | Yes | Yes |
| **Native RAID** | No | No | Yes | Yes |
| **Deduplication** | No | No | Yes | Yes |
| **Maturity** | Very stable | Stable | In development | Stable (Solaris) |
| **Use case** | General, servers | DB, large files | Backup, NAS | Enterprise storage |

---

## Laboratory/Seminar (Session 6/7)

### TC Materials
- TC6a-TC6b: Advanced Scripting
- TC6c: Debugging and Testing

### Assignment 6: `tema6_monitor.sh`

System monitoring script with options:
- `-c` CPU info (usage, frequency)
- `-m` Memory info (RAM, swap, buffers)
- `-d` Disk info (space, I/O stats)
- `-a` All (default, all of the above)
- `-w N` Watch mode (refresh every N seconds)
- `-o FILE` Output to file

---

## Practical Demonstrations

### Demo 1: Observing Journaling

```bash
#!/bin/bash
# Demo: Observe journal activity

# Create a large file to generate activity
dd if=/dev/zero of=/tmp/test_journal bs=1M count=100

# Monitor disk I/O (includes journal)
iostat -x 1 5

# View journal commits (requires privileges)
sudo journalctl -k | grep -i ext4

# Force sync and observe
sync
echo "Journal flushed"
```

### Demo 2: Real-Time Fragmentation

```bash
#!/bin/bash
# Demo: Create artificial fragmentation

DEMO_DIR=$(mktemp -d)
cd "$DEMO_DIR"

# Create interleaved files
for i in {1..100}; do
    dd if=/dev/urandom of=file_$i bs=1K count=$((RANDOM % 100 + 1)) 2>/dev/null
done

# Delete even files (create holes)
rm file_{2..100..2}

# Create a large file that will be fragmented
dd if=/dev/zero of=fragmented_file bs=1M count=10

# Check fragmentation
filefrag -v fragmented_file

cd - && rm -rf "$DEMO_DIR"
```

---

## Recommended Reading

### OSTEP (Operating Systems: Three Easy Pieces)
- [Ch 40 - File System Implementation](https://pages.cs.wisc.edu/~remzi/OSTEP/file-implementation.pdf)
- [Ch 41 - Locality and FFS](https://pages.cs.wisc.edu/~remzi/OSTEP/file-ffs.pdf)
- [Ch 42 - Crash Consistency: FSCK and Journaling](https://pages.cs.wisc.edu/~remzi/OSTEP/file-journaling.pdf)

### Tanenbaum - Modern Operating Systems
- Chapter 4.4: File System Implementation

### Linux Documentation
- `man 5 ext4`
- `man 8 tune2fs`
- `man 8 dumpe2fs`

---

## New Commands Summary

| Command | Description | Example |
|---------|-------------|---------|
| `filefrag` | Display extents/fragmentation | `filefrag -v file.dat` |
| `e4defrag` | ext4 defragmentation | `sudo e4defrag /home/` |
| `tune2fs` | ext4 configuration | `sudo tune2fs -l /dev/sda1` |
| `dumpe2fs` | Detailed ext4 information | `sudo dumpe2fs /dev/sda1` |
| `fsck` | Filesystem verification | `sudo fsck /dev/sda1` |
| `mount` | Mounting and information | `mount \| grep ext4` |
| `findmnt` | Mount point information | `findmnt /home` |
| `iostat` | I/O statistics | `iostat -x 1` |

---


---


---

## Nuances and Special Cases

### What We Did NOT Cover (didactic limitations)

- **Log-structured filesystems**: LFS, F2FS - optimised for write-heavy workloads and SSDs.
- **End-to-end checksumming**: ZFS, Btrfs detect and correct bit rot.
- **Deduplication**: Elimination of duplicate blocks (ZFS, Windows ReFS).

### Common Mistakes to Avoid

1. **Wrong journal mode**: `data=journal` is safe but slow; `data=ordered` is the standard compromise.
2. **Ignoring fsync()**: Data may be lost without explicit fsync for durability.
3. **Formatting SSD with HDD options**: Use `discard` mount option for automatic TRIM.

### Open Questions

- How will file systems evolve for storage class memory (SCM)?
- Can a filesystem be simultaneously performant, safe and space-efficient?

## Looking Ahead

**Week 13: Security in Operating Systems** — We protect the system! We will study authentication (who are you?), authorisation (what can you do?), the UNIX permissions model, ACLs and capabilities for granular privileges.

**Recommended preparation:**
- Experiment with `chmod`, `chown` and `getfacl`
- Read about the principle of least privilege

## Visual Summary

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    WEEK 12: RECAP - FILESYSTEM (2)                           │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  BLOCK ALLOCATION                                                            │
│  ├── Contiguous: simple but external fragmentation                          │
│  ├── Linked: flexible but slow random access                                │
│  └── Indexed: fast and flexible (ext4)                                      │
│                                                                              │
│  EXTENTS (ext4)                                                              │
│  ├── Describes contiguous blocks as (start, length)                         │
│  └── Much more efficient than individual pointers                           │
│                                                                              │
│  FRAGMENTATION                                                               │
│  ├── Internal: space wasted in the last block                               │
│  ├── External: non-contiguous blocks → multiple seeks                       │
│  └── Solution: defragmentation, delayed allocation                          │
│                                                                              │
│  JOURNALING                                                                  │
│  ├── Write to journal before effective application                          │
│  ├── On crash: re-apply or cancel transactions                              │
│  └── Modes: journal (safest) / ordered (default) / writeback (fast)        │
│                                                                              │
│  FREE SPACE MANAGEMENT                                                       │
│  ├── Bitmap: 1 bit per block (compact, efficient)                           │
│  └── Block groups: locality and redundancy                                  │
│                                                                              │
│  VFS (Virtual File System)                                                   │
│  ├── Abstracts different filesystems                                        │
│  └── Uniform interface for applications                                     │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```


---

## Self-Assessment

### Verification Questions

1. **[REMEMBER]** What is journaling and what problem does it solve? List the 3 journaling modes in ext4.
2. **[UNDERSTAND]** Explain the difference between contiguous allocation, linked allocation and indexed allocation. What are the advantages of ext4 with extents?
3. **[ANALYSE]** Compare FAT32 with ext4 from the perspective of: maximum file size, crash recovery, fragmentation.

### Mini-Challenge (optional)

Use `dumpe2fs` to inspect an ext4 file system and identify: block size, number of inodes, free space.

---

*Materials developed by Revolvix for ASE Bucharest - CSIE*  
*Operating Systems | Year I, Semester 2 | 2025-2026*

---

## Scripting in Context (Bash + Python): Journaling and FS Metadata Collection

### Included Files

- Bash: `scripts/fs_metadata_report.sh` — Generates a report with mount/lsblk/df/inodes and journaling hints.

### Quick Run

```bash
./scripts/fs_metadata_report.sh
```

### Connection with This Week's Concepts

- Journaling is a consistency mechanism: after a crash, the system returns to a coherent state.
- In practice, "what filesystem do I have and how is it mounted?" is an operational question; the automated report captures the answer in data.

### Recommended Practice

- first run the scripts on a test directory (not on critical data);
- save the output to a file and attach it to a report/assignment if required;
- note the kernel version (`uname -r`) and Python version (`python3 --version`) when comparing results.

*Materials developed by Revolvix for ASE Bucharest - CSIE*  
*Operating Systems | Year I, Semester 2 | 2025-2026*
