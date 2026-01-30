# Operating Systems - Week 11: The File System (Part 1)

> **by Revolvix** | ASE Bucharest - CSIE | Year I, Semester 2 | 2025-2026

---

## Week Objectives

After completing the materials for this week, you will be able to:

1. Explain the concept of persistence and the need for file systems
2. Describe the structure of an inode and the information it contains
3. **Differentiate** between hard links and symbolic links and explain the practical implications
4. **Use** commands for exploring file metadata
5. **Analyse** the structure of directories and path resolution

---

## Applied Context (didactic scenario): How does Linux find a file among millions in milliseconds?

You have a disc with 500,000 files. You type `cat /home/user/document.txt`. In milliseconds, the system finds exactly that file. It does not search randomly - it uses **optimised data structures**: directories as trees, inodes as indexes. It is like the difference between searching for a book by colour vs. by the classification code in a library.

But wait: why do you need a "file system"? RAM is fast but gets erased on restart. HDD/SSD preserves data but is slow and needs to be organised. The file system bridges these two worlds.

> 💡 **Think about it**: When you delete a file, does the data disappear immediately from the disc?

---

## Course Content (11/14)

### 1. From RAM to Persistence: Why We Need Filesystems

#### Formal Definition

> **Persistence** is the property of data to survive system shutdown. A **file system** (filesystem) is the method of organising and storing data on persistent media, providing the "file" and "directory" abstraction.

#### The Storage Hierarchy

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         MEMORY HIERARCHY                                     │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  CPU REGISTERS     ←───  1 ns      │  ~1 KB     │  Volatile                 │
│       ↓                           │            │                            │
│  CACHE L1/L2/L3   ←───  5-50 ns   │  KB-MB     │  Volatile                 │
│       ↓                           │            │                            │
│  RAM (DRAM)       ←───  100 ns    │  GB        │  Volatile                 │
│       ↓                           │            │                            │
│  ════════════════════════════════════════════════════════════               │
│       ↓           VOLATILITY BARRIER                                        │
│  ════════════════════════════════════════════════════════════               │
│       ↓                           │            │                            │
│  SSD (NVMe)       ←───  100 µs    │  TB        │  PERSISTENT               │
│       ↓                           │            │                            │
│  HDD              ←───  10 ms     │  TB        │  PERSISTENT               │
│       ↓                           │            │                            │
│  TAPE/CLOUD       ←───  seconds   │  PB        │  PERSISTENT               │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘

Observations:
- Below the volatility barrier: data survives restart
- Trade-off: speed vs. persistence vs. cost
- The filesystem manages the persistent zone
```

#### Intuitive Explanation

**Metaphor: The Library**

Imagine a huge library:
- **The Disc** = The storage with millions of books (raw data)
- **Filesystem** = The cataloguing system (organisation)
- **Inode** = The book card (author, year, shelf location)
- **Directory** = The thematic catalogue ("Mathematics" → list of books)
- **Path** = The complete address ("Floor 3, Shelf B, Position 42")

Without a cataloguing system, you would search among millions of books randomly!

#### Historical Context

| Year | Event | Significance |
|------|-------|--------------|
| 1965 | Multics introduces directory hierarchy | First tree structure |
| 1969 | UNIX filesystem | The inode concept, "everything is a file" |
| 1983 | ext (Extended Filesystem) | First Linux filesystem |
| 1993 | ext2 | Linux standard for a decade |
| 2001 | ext3 | Adds journaling |
| 2008 | ext4 | Extents, nanosecond timestamps |
| 2013 | Btrfs | Copy-on-write, snapshots |

---

### 2. Disc Structure: From Blocks to Files

#### Formal Definition

> A disc is divided into **blocks** (typically 4 KB). The file system organises these blocks into **superblock** (global metadata), **bitmaps** (free/used), **inode table** and **data blocks**.

#### Simplified ext4 Layout

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                          PARTITIONED DISC                                    │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌────────────┬───────────────────────────────────────────────────────────┐ │
│  │ BOOT BLOCK │                    ext4 PARTITION                         │ │
│  │  (512 B)   │                                                           │ │
│  └────────────┴───────────────────────────────────────────────────────────┘ │
│                │                                                             │
│                ▼                                                             │
│  ┌──────────────────────────────────────────────────────────────────────┐   │
│  │ BLOCK GROUP 0                                                         │   │
│  ├──────────────────────────────────────────────────────────────────────┤   │
│  │ Super  │ Group   │ Block  │ Inode  │ Inode   │ Data Blocks           │   │
│  │ Block  │ Descrip │ Bitmap │ Bitmap │ Table   │ (files)               │   │
│  │ 1 block│ 1 block │ 1 block│ 1 block│ N blocks│ ... thousands of blocks│   │
│  └──────────────────────────────────────────────────────────────────────┘   │
│                                                                              │
│  ┌──────────────────────────────────────────────────────────────────────┐   │
│  │ BLOCK GROUP 1                                                         │   │
│  │ ... (similar structure, with superblock backup copies)                │   │
│  └──────────────────────────────────────────────────────────────────────┘   │
│                                                                              │
│  ... (thousands of block groups)                                             │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘

Components:
- Superblock: Global information (size, number of blocks/inodes, mount count)
- Block Bitmap: 1 bit per block (0=free, 1=occupied)
- Inode Bitmap: 1 bit per inode (0=free, 1=occupied)
- Inode Table: Array of inode structures
- Data Blocks: The actual content of files
```

#### Practical Verification

```bash
# Superblock information
sudo dumpe2fs /dev/sda1 | head -50

# Filesystem statistics
df -h           # Used space
df -i           # Used inodes

# Block size
sudo blockdev --getbsz /dev/sda1
# Typical output: 4096 (4 KB)
```

---

### 3. Inode (Index Node): The Core of Metadata

#### Formal Definition

> **Inode** (index node) is the data structure that contains **all metadata of a file**, except the name. It includes: type, permissions, owner (UID/GID), size, timestamps and pointers to data blocks.

#### Detailed Structure of an Inode

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              INODE #12345                                    │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │ MODE (16 bits)                                                       │    │
│  │   - File type: regular(-), directory(d), symlink(l), device(b/c)    │    │
│  │   - Permissions: rwxr-xr-x (755 octal)                               │    │
│  │   - Special bits: setuid, setgid, sticky                            │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │ OWNERSHIP                                                            │    │
│  │   - UID: 1000 (owner user)                                          │    │
│  │   - GID: 1000 (owner group)                                         │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │ TIMESTAMPS (nanoseconds in ext4)                                     │    │
│  │   - atime: Last Access      (2025-01-15 10:30:45)                   │    │
│  │   - mtime: Last Modify      (2025-01-14 09:15:22)                   │    │
│  │   - ctime: Last Change      (2025-01-14 09:15:22)                   │    │
│  │   - crtime: Creation        (2025-01-10 14:00:00) [ext4 only]       │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │ SIZE AND LINK COUNT                                                  │    │
│  │   - Size: 15360 bytes                                               │    │
│  │   - Blocks: 32 (512-byte blocks)                                    │    │
│  │   - Links: 2 (how many names refer to this inode)                   │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │ POINTERS TO DATA (ext4 with extents)                                 │    │
│  │                                                                      │    │
│  │   Direct Blocks [0-11]:  12 × 4KB = 48 KB direct                    │    │
│  │      [0] → Block 5000                                               │    │
│  │      [1] → Block 5001                                               │    │
│  │      ...                                                            │    │
│  │                                                                      │    │
│  │   Single Indirect [12]:  1024 pointers × 4KB = 4 MB                 │    │
│  │      → Block 6000 (contains 1024 pointers)                          │    │
│  │         [0] → Block 7000                                            │    │
│  │         [1] → Block 7001                                            │    │
│  │         ...                                                         │    │
│  │                                                                      │    │
│  │   Double Indirect [13]: 1024 × 1024 × 4KB = 4 GB                    │    │
│  │      → Block 8000 (1024 pointers to pointer blocks)                 │    │
│  │                                                                      │    │
│  │   Triple Indirect [14]: 1024³ × 4KB = 4 TB                          │    │
│  │      → Block 9000 (addressing for huge files)                       │    │
│  │                                                                      │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘

IMPORTANT: The inode does NOT contain the file name!
The name is stored in the PARENT DIRECTORY.
```

#### Intuitive Explanation

**Metaphor: The Library Card**

- **Inode** = The book card (contains all information about the book: author, year, publisher, shelf location)
- **Directory** = The catalogue that says "Title X has card #12345"
- **Data blocks** = The pages of the book (the actual content)

Why is the name not in the inode? Because the same book can have multiple titles in the catalogue (hard links)!

#### Calculation: Maximum File Size

```
With 4 KB blocks (4096 bytes) and 4-byte pointers:

Direct blocks:        12 × 4 KB =                        48 KB
Single indirect:      1024 × 4 KB =                       4 MB
Double indirect:      1024 × 1024 × 4 KB =                4 GB
Triple indirect:      1024 × 1024 × 1024 × 4 KB =         4 TB
────────────────────────────────────────────────────────────────
Theoretical total:                                       ~4 TB

ext4 actual: limit of 16 TB per file (with extents)
```

#### Practical Verification

```bash
# Create a test file
echo "Hello, filesystem!" > test.txt

# View inode with stat
stat test.txt

# Output:
#   File: test.txt
#   Size: 19              Blocks: 8          IO Block: 4096   regular file
# Device: 8,1     Inode: 1234567    Links: 1
# Access: (0644/-rw-r--r--)  Uid: ( 1000/   user)   Gid: ( 1000/  group)
# Access: 2025-01-15 10:30:45.123456789 +0200
# Modify: 2025-01-15 10:30:40.987654321 +0200
# Change: 2025-01-15 10:30:40.987654321 +0200
#  Birth: 2025-01-15 10:30:40.987654321 +0200

# Only the inode number
ls -i test.txt
# 1234567 test.txt

# Detailed inode information (requires debugfs)
sudo debugfs -R "stat <1234567>" /dev/sda1
```

---

### 4. Directories: The File System Catalogue

#### Formal Definition

> A **directory** is a special type of file that contains a list of **entries** (directory entries). Each entry maps a **name** to an **inode number**.

#### Structure of a Directory

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    DIRECTORY /home/user (inode #500)                         │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  Directory content (as a special file):                                     │
│                                                                              │
│  ┌────────────────┬───────────────────────────────────────────────────────┐ │
│  │  Inode Number  │  Name                                                 │ │
│  ├────────────────┼───────────────────────────────────────────────────────┤ │
│  │     500        │  .           (reference to self)                      │ │
│  │     400        │  ..          (reference to parent: /home)             │ │
│  │     501        │  document.txt                                         │ │
│  │     502        │  photos/                                              │ │
│  │     501        │  doc_link    (HARD LINK! Same inode as document)      │ │
│  │     503        │  Downloads/                                           │ │
│  └────────────────┴───────────────────────────────────────────────────────┘ │
│                                                                              │
│  Observations:                                                               │
│  - "." and ".." are actual entries in the directory                         │
│  - document.txt and doc_link have the SAME inode (501) = hard link          │
│  - The name is stored here, NOT in the inode                                │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

#### Path Resolution: How the OS Finds a File

```
Request: open("/home/user/document.txt")

STEP 1: Start from root inode (inode #2, reserved)
        Read the contents of directory "/"
         
STEP 2: Search for "home" in "/"
        Found: inode #100
        Verify it is a directory and you have permissions
         
STEP 3: Read directory /home (inode #100)
        Search for "user"
        Found: inode #500
         
STEP 4: Read directory /home/user (inode #500)
        Search for "document.txt"
        Found: inode #501
         
STEP 5: Read inode #501
        - Verify permissions (r-- for user)
        - Obtain pointers to data blocks
        - Return file descriptor to application

Total I/O operations:
- 4 inode reads (/, /home, /home/user, document.txt)
- 3 directory reads (content of /, /home, /home/user)
= 7 disc accesses (without cache)

With TLB/dentry cache: ~1-2 disc accesses!
```

#### Practical Verification

```bash
# View directory content with inodes
ls -lai /home/user/

# Output:
# 500 drwxr-xr-x 5 user group 4096 Jan 15 10:30 .
# 400 drwxr-xr-x 3 root root  4096 Jan 10 14:00 ..
# 501 -rw-r--r-- 2 user group   19 Jan 15 10:30 document.txt
# 502 drwxr-xr-x 2 user group 4096 Jan 12 09:00 photos
# 501 -rw-r--r-- 2 user group   19 Jan 15 10:30 doc_link
#     ^--- Notice: document.txt and doc_link have the same inode!

# Verify link count
stat document.txt | grep Links
# Links: 2
```

---

### 5. Hard Links vs Symbolic Links

#### Formal Definition

> **Hard link** = A new directory entry that refers to the same inode. Different name but identical data.
> **Symbolic link (symlink)** = A special file that contains the **path** to another file.

#### Detailed Comparison

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                          HARD LINK                                           │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  Directory A                 Directory B                                     │
│  ┌──────────────────┐       ┌──────────────────┐                            │
│  │ file.txt → #1234 │       │ link.txt → #1234 │                            │
│  └────────┬─────────┘       └────────┬─────────┘                            │
│           │                          │                                       │
│           └──────────┬───────────────┘                                       │
│                      ▼                                                       │
│              ┌─────────────┐                                                 │
│              │ Inode #1234 │  ← Same inode, link count = 2                  │
│              │ Links: 2    │                                                 │
│              └──────┬──────┘                                                 │
│                     ▼                                                        │
│              ┌─────────────┐                                                 │
│              │ Data Blocks │  ← Same data                                   │
│              │ "Hello..."  │                                                 │
│              └─────────────┘                                                 │
│                                                                              │
│  Properties:                                                                 │
│  ✓ Deleting one name does NOT delete data (until link count = 0)           │
│  ✓ Modification through any name affects all                                │
│  ✗ CANNOT traverse filesystems (different device = different inodes)        │
│  ✗ CANNOT refer to directories (would create cycles)                        │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│                         SYMBOLIC LINK                                        │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  Directory                                                                   │
│  ┌──────────────────────────────────────────────────────────────────┐       │
│  │ original.txt → Inode #1234                                        │       │
│  │ shortcut.txt → Inode #5678 (TYPE: symlink)                       │       │
│  └──────────────────────────────────────────────────────────────────┘       │
│                    │                    │                                    │
│                    ▼                    ▼                                    │
│           ┌─────────────┐      ┌─────────────────────┐                      │
│           │ Inode #1234 │      │ Inode #5678         │                      │
│           │ Type: file  │      │ Type: symlink       │                      │
│           │ Links: 1    │      │ Data: "original.txt"│ ← Contains the PATH  │
│           └──────┬──────┘      └─────────────────────┘                      │
│                  ▼                                                           │
│           ┌─────────────┐                                                    │
│           │ Data Blocks │                                                    │
│           │ "Hello..."  │                                                    │
│           └─────────────┘                                                    │
│                                                                              │
│  Properties:                                                                 │
│  ✓ Can traverse filesystems                                                 │
│  ✓ Can refer to directories                                                 │
│  ✓ More flexible (can point anywhere)                                       │
│  ✗ "Broken link" if target is deleted                                       │
│  ✗ Additional overhead (path resolution)                                    │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

#### Comparative Table

| Aspect | Hard Link | Symbolic Link |
|--------|-----------|---------------|
| **What it contains** | Inode number | Text path |
| **Own inode** | No (shared) | Yes (new) |
| **Cross-filesystem** | ❌ Impossible | ✅ Possible |
| **Refers to directories** | ❌ Forbidden | ✅ Allowed |
| **After target deletion** | Data remains | Link broken |
| **Permissions** | Of the inode | lrwxrwxrwx (ignored) |
| **Size** | 0 (only dir entry) | Path length |
| **Creation** | `ln original hard` | `ln -s original soft` |

#### Practical Demonstration

```bash
# Setup
echo "Original data" > original.txt
ls -li original.txt
# 1234567 -rw-r--r-- 1 user group 15 Jan 15 original.txt
#                    ^ link count = 1

# Create hard link
ln original.txt hard_link.txt
ls -li original.txt hard_link.txt
# 1234567 -rw-r--r-- 2 user group 15 Jan 15 original.txt
# 1234567 -rw-r--r-- 2 user group 15 Jan 15 hard_link.txt
# ^ SAME INODE!      ^ link count = 2

# Create symbolic link
ln -s original.txt soft_link.txt
ls -li soft_link.txt
# 9876543 lrwxrwxrwx 1 user group 12 Jan 15 soft_link.txt -> original.txt
# ^ DIFFERENT INODE  ^ symlink type

# Modify through hard link
echo "Modified!" >> hard_link.txt
cat original.txt
# Original data
# Modified!
# The modification appears in BOTH!

# Delete original
rm original.txt
cat hard_link.txt
# Original data
# Modified!
# THE DATA STILL EXISTS! (link count = 1)

cat soft_link.txt
# cat: soft_link.txt: No such file or directory
# BROKEN LINK! The target no longer exists.

# Verify broken link
ls -la soft_link.txt
# lrwxrwxrwx 1 user group 12 Jan 15 soft_link.txt -> original.txt
# (in terminal, it will be coloured red for broken link)
```

---

### 6. Special File Types: "Everything is a File"

#### The UNIX Philosophy

> In UNIX, "everything is a file": hardware devices, network sockets and processes are accessed through the unified file system interface.

#### File Types

```
The first character in ls -l indicates the type:

  -  Regular file      Ordinary file with data
  d  Directory         Directory (list of entries)
  l  Symbolic link     Symbolic link
  b  Block device      Block device (HDD, SSD)
  c  Character device  Character device (terminal, mouse)
  p  Named pipe (FIFO) Inter-process communication
  s  Socket            Network/local communication
```

#### Examples from /dev

```bash
ls -la /dev/sda /dev/null /dev/tty /dev/random

# brw-rw---- 1 root disk 8, 0 Jan 15 /dev/sda      # Block device (disc)
# crw-rw-rw- 1 root root 1, 3 Jan 15 /dev/null     # Character device
# crw-rw-rw- 1 root tty  5, 0 Jan 15 /dev/tty      # Terminal
# crw-rw-rw- 1 root root 1, 8 Jan 15 /dev/random   # Random generator

# Usage
echo "test" > /dev/null     # Disappears (black hole)
cat /dev/random | head -c 16 | xxd  # 16 random bytes
```

#### Pseudo-Filesystems

```bash
# /proc - Information about processes and system
cat /proc/cpuinfo     # CPU info
cat /proc/meminfo     # Memory info
ls /proc/$$           # Current process

# /sys - Kernel interface
cat /sys/class/net/eth0/address  # MAC address

# /dev - Devices
ls /dev/sd*           # Discs

# These are NOT on disc - they are generated by the kernel in real time!
df -T /proc /sys
# Filesystem     Type  ...
# proc           proc  ...
# sysfs          sysfs ...
```

---

### 7. Trade-offs and Practical Considerations

#### Costs and Benefits

| Aspect | Benefit | Cost |
|--------|---------|------|
| **Inodes** | Fast metadata access | Limited number (can run out before space!) |
| **Indirection** | Large files | More disc accesses for huge files |
| **Hard links** | Efficient sharing | Cannot traverse filesystems |
| **Symlinks** | Flexibility | Resolution overhead, risk of broken |
| **Large directories** | Organisation | Slow scanning (uses B-tree in ext4) |

#### The Classic Error: "No more space" vs "No more inodes"

```bash
# Check space
df -h /
# Filesystem      Size  Used Avail Use% Mounted on
# /dev/sda1        50G   45G    5G  90% /

# Check inodes
df -i /
# Filesystem      Inodes  IUsed   IFree IUse% Mounted on
# /dev/sda1       3276800 3276800     0  100% /
# ZERO free inodes! You cannot create new files even if you have 5GB space!

# Common cause: millions of small files (cache, sessions, logs)
find /tmp -type f | wc -l
# 3000000 ← 3 million small files in /tmp!
```

---

## Laboratory/Seminar (Session 5/7)

### TC Materials
- TC5a-TC5c: Bash Functions
- TC5d: Debugging and Error Handling

### Assignment 5: `tema5_fs_explorer.sh`

Filesystem exploration script with functions:
- `show_inode_info()` - Displays inode information for a file
- `find_hard_links()` - Finds all hard links of a file
- `check_broken_symlinks()` - Checks for broken symlinks in a directory
- `-r` - Recursive
- `-v` - Verbose

---

## Practical Demonstrations

### Demo 1: Inode in Action

```bash
#!/bin/bash
# Demo: Same inode, different names

DEMO_DIR=$(mktemp -d)
cd "$DEMO_DIR"

# Create file and hard links
echo "Important data" > data.txt
ln data.txt backup1.txt
ln data.txt backup2.txt

echo "=== All refer to the same inode ==="
ls -li *.txt

echo "=== Link count = 3 ==="
stat data.txt | grep Links

echo "=== Deleting the original ==="
rm data.txt
cat backup1.txt  # Data still exists!

echo "=== Link count = 2 ==="
stat backup1.txt | grep Links

cd - && rm -rf "$DEMO_DIR"
```

### Demo 2: Symlink vs Hard Link

```bash
#!/bin/bash
# Visual comparison

mkdir -p /tmp/link_demo/{dir1,dir2}
echo "Original" > /tmp/link_demo/dir1/file.txt

# Hard link in the same directory
ln /tmp/link_demo/dir1/file.txt /tmp/link_demo/dir1/hard.txt

# Symlink in another directory
ln -s ../dir1/file.txt /tmp/link_demo/dir2/soft.txt

# Visualisation
tree /tmp/link_demo
ls -li /tmp/link_demo/dir1/
ls -li /tmp/link_demo/dir2/

# Cleanup
rm -rf /tmp/link_demo
```

---

## Recommended Reading

### OSTEP (Operating Systems: Three Easy Pieces)
- [Ch 39 - Files and Directories](https://pages.cs.wisc.edu/~remzi/OSTEP/file-intro.pdf)
- [Ch 40 - File System Implementation](https://pages.cs.wisc.edu/~remzi/OSTEP/file-implementation.pdf)

### Tanenbaum - Modern Operating Systems
- Chapter 4.3: File System Implementation

### Linux Documentation
- `man 7 inode`
- `man 2 stat`
- `man 1 ln`

---

## New Commands Summary

| Command | Description | Example |
|---------|-------------|---------|
| `ls -i` | Displays inode number | `ls -i file.txt` |
| `stat` | Detailed file information | `stat file.txt` |
| `ln` | Create hard link | `ln original link` |
| `ln -s` | Create symbolic link | `ln -s target link` |
| `df -i` | Inode statistics | `df -i /` |
| `file` | Determines file type | `file /dev/sda` |
| `readlink` | Reads symlink target | `readlink -f link.txt` |
| `find -inum` | Search by inode | `find . -inum 12345` |
| `find -samefile` | Find hard links | `find . -samefile file.txt` |

---


---


---

## Nuances and Special Cases

### What We Did NOT Cover (didactic limitations)

- **Extended attributes (xattr)**: Additional metadata on files (ACLs, SELinux labels).
- **Sparse files**: Files with "holes" that do not occupy disc space.
- **Copy-on-write filesystems**: Btrfs, ZFS - do not modify data, create new copies.

### Common Mistakes to Avoid

1. **Hardlinks for directories**: Forbidden (would create cycles in hierarchy). Exception: `.` and `..`.
2. **Relative vs absolute symlinks**: Relative are portable; absolute can become invalid when moved.
3. **Assuming rm deletes data**: Data persists until overwritten; for secure deletion: `shred`.

### Open Questions

- Will object stores (S3-like) replace traditional file systems?
- How are file systems evolving for SSDs (F2FS, ext4 optimisations)?

## Looking Ahead

**Week 12: The File System (Part 2)** — We continue with advanced aspects: disc space allocation (contiguous, linked, indexed), FAT and ext4 structure, and the essential journaling mechanism that prevents data corruption.

**Recommended preparation:**
- Run `df -T` to see mounted file systems
- Experiment with `dumpe2fs` on an ext4 partition

## Visual Summary

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    WEEK 11: RECAP - FILESYSTEM (1)                           │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  PERSISTENCE                                                                 │
│  ├── RAM = volatile, fast                                                   │
│  ├── Disc = persistent, slow                                                │
│  └── Filesystem = bridge between the two                                    │
│                                                                              │
│  DISC STRUCTURE                                                              │
│  ├── Superblock (global metadata)                                           │
│  ├── Bitmaps (free blocks/inodes)                                           │
│  ├── Inode Table (file metadata)                                            │
│  └── Data Blocks (actual content)                                           │
│                                                                              │
│  INODE                                                                       │
│  ├── Contains: type, permissions, owner, timestamps, size, pointers        │
│  ├── Does NOT contain: the file name!                                       │
│  └── Pointers: direct (48KB) → indirect (4MB) → 2x (4GB) → 3x (4TB)        │
│                                                                              │
│  DIRECTORIES                                                                 │
│  ├── Special file with pairs (name → inode)                                 │
│  ├── "." = self, ".." = parent                                              │
│  └── Path resolution: traverses tree from root                              │
│                                                                              │
│  LINKS                                                                       │
│  ├── Hard link: different name, SAME inode                                  │
│  │   └── Limitation: same filesystem, no directories                        │
│  └── Symbolic link: special file with target PATH                           │
│      └── Flexible but can be "broken"                                       │
│                                                                              │
│  "EVERYTHING IS A FILE"                                                      │
│  ├── Regular (-), Directory (d), Symlink (l)                                │
│  ├── Block device (b), Character device (c)                                 │
│  └── Pipe (p), Socket (s)                                                   │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```


---

## Self-Assessment

### Verification Questions

1. **[REMEMBER]** What information does an inode contain in Unix/Linux systems? List at least 6 fields.
2. **[UNDERSTAND]** Explain the difference between hard link and symbolic link. Why cannot hard links traverse file systems?
3. **[ANALYSE]** Analyse the pointer system in the inode (direct, single indirect, double, triple). Calculate the maximum file size for 4KB blocks.

### Mini-Challenge (optional)

Create a file, a hard link and a symbolic link to it. Use `ls -li` to observe the inodes and link count.

---

*Materials developed by Revolvix for ASE Bucharest - CSIE*  
*Operating Systems | Year I, Semester 2 | 2025-2026*

---

## Scripting in Context (Bash + Python): Inodes, hard links, symlinks

### Included Files

- Bash: `scripts/links_demo.sh` — Creates hard link and symlink and explains the effects.
- Python: `scripts/inode_walk.py` — Groups files by (device, inode) to find hard links.

### Quick Run

```bash
./scripts/links_demo.sh
./scripts/inode_walk.py --root .
```

### Connection to This Week's Concepts

- Hard link = another name for the same inode; symlink = special file that contains a path.
- Grouping by (device, inode) is a direct application of metadata exposed by the filesystem.

### Recommended Practice

- first run the scripts on a test directory (not on critical data);
- save the output to a file and attach it to the report/assignment, if required;
- note the kernel version (`uname -r`) and Python version (`python3 --version`) when comparing results.

*Materials developed by Revolvix for ASE Bucharest - CSIE*  
*Operating Systems | Year I, Semester 2 | 2025-2026*
