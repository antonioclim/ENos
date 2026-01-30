# M11: Memory Forensics Tool

> **Level:** MEDIUM | **Estimated time:** 25-35 hours | **K8s Bonus:** +10%

---

## Description

Tool for memory analysis and forensics: per-process memory usage investigation, memory leak detection, heap/stack analysis, memory-mapped file identification and report generation for troubleshooting and optimisation.

---

## Learning Objectives

- Linux memory structure (virtual memory, pages)
- Information from `/proc/[pid]/maps`, `/proc/meminfo`
- Memory leak and abnormal pattern detection
- Memory mapping and shared memory
- Memory debugging and profiling

---

## Functional Requirements

### Mandatory (for passing grade)

1. **System analysis**
   - Total RAM, used, free, cached, buffers
   - Swap usage and activity
   - Memory pressure indicators

2. **Per-process analysis**
   - RSS, VSZ, shared memory
   - Memory maps (heap, stack, libs, mmap)
   - Usage trend over time

3. **Problem detection**
   - Processes with excessive consumption
   - Potential memory leaks (continuous growth)
   - OOM risk assessment

4. **Memory maps**
   - Parse `/proc/[pid]/maps`
   - Loaded libraries
   - Anonymous mappings (heap)

5. **Reporting**
   - System snapshot
   - Comparison between snapshots
   - Export for analysis

### Optional (for full marks)

6. **Leak detection** - Continuous monitoring with alerting
7. **Heap analysis** - Detailed allocation analysis
8. **Shared memory audit** - IPC segments, tmpfs
9. **NUMA awareness** - Distribution across NUMA nodes
10. **Integration with valgrind** - Combined reports

---

## CLI Interface

```bash
./memtool.sh <command> [options]

Commands:
  overview              System memory usage summary
  top [n]               Top N processes by memory
  analyze <pid>         Detailed process analysis
  maps <pid>            Display memory maps
  compare <pid>         Compare snapshots (leak detection)
  snapshot <pid>        Save snapshot for comparison
  shared                List shared memory segments
  watch <pid>           Continuous monitoring
  report                Generate complete report

Options:
  -s, --sort FIELD      Sort: rss|vsz|shared|swap
  -n, --number N        Number of results
  -i, --interval SEC    Monitoring interval
  -o, --output FILE     Save output
  -f, --format FMT      Format: text|json|csv
  --human               Human-readable sizes
  --include-kernel      Include kernel memory

Examples:
  ./memtool.sh overview
  ./memtool.sh top 20 --sort rss
  ./memtool.sh analyze $$ --human
  ./memtool.sh maps $(pgrep nginx | head -1)
  ./memtool.sh snapshot 1234 && sleep 60 && ./memtool.sh compare 1234
```

---

## Output Examples

### System Overview

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                    MEMORY FORENSICS TOOL                                     ║
║                    Host: server01 | Kernel: 5.15.0-91-generic               ║
╚══════════════════════════════════════════════════════════════════════════════╝

SYSTEM MEMORY OVERVIEW
═══════════════════════════════════════════════════════════════════════════════

Physical Memory: 16 GB
┌──────────────────────────────────────────────────────────────────────────────┐
│ [████████████████████████████▓▓▓▓▓▓▓▓▓▓▓▓▓░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░] │
│ ████ Used: 7.2 GB (45%)  ▓▓▓▓ Cached: 5.1 GB (32%)  ░░░░ Free: 3.7 GB (23%)│
└──────────────────────────────────────────────────────────────────────────────┘

Swap: 4 GB
┌──────────────────────────────────────────────────────────────────────────────┐
│ [██████░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░] │
│ ████ Used: 512 MB (12.5%)                          ░░░░ Free: 3.5 GB        │
└──────────────────────────────────────────────────────────────────────────────┘

MEMORY BREAKDOWN
───────────────────────────────────────────────────────────────────────────────
  Total:           16,384 MB
  Used:             7,372 MB (45.0%)
  Free:             3,789 MB (23.1%)
  Buffers:            234 MB (1.4%)
  Cached:           5,123 MB (31.3%)
  Shared:             456 MB (2.8%)
  Available:        8,456 MB (51.6%)  ← Actual available for apps
  
  Swap Total:       4,096 MB
  Swap Used:          512 MB (12.5%)
  Swap Free:        3,584 MB

MEMORY PRESSURE INDICATORS
───────────────────────────────────────────────────────────────────────────────
  Page faults/sec:     1,234 (minor: 1,200, major: 34)
  Swap in/out:         12 MB/s in, 2 MB/s out
  OOM Score:           Low risk ✓
  Memory pressure:     some (10s avg: 2.3%)

TOP MEMORY CONSUMERS
───────────────────────────────────────────────────────────────────────────────
  PID      User       RSS        %MEM    Process
  2234     postgres   1.8 GB     11.2%   postgresql
  3240     1000       1.2 GB     7.5%    python myapp.py
  2045     root       512 MB     3.2%    dockerd
  12456    mysql      456 MB     2.8%    mysqld
  8901     www-data   256 MB     1.6%    php-fpm
```

### Process Memory Analysis

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                    MEMORY ANALYSIS: PID 3240 (python)                        ║
╚══════════════════════════════════════════════════════════════════════════════╝

BASIC INFO
───────────────────────────────────────────────────────────────────────────────
  Process:    python /opt/myapp/main.py
  User:       appuser (1000)
  Started:    2025-01-20 08:00:00 (9h 45m ago)

MEMORY SUMMARY
───────────────────────────────────────────────────────────────────────────────
  Virtual Size (VSZ):     2.4 GB
  Resident Set (RSS):     1.2 GB     ← Actually in RAM
  Shared Memory:          45 MB
  Private Memory:         1.15 GB    ← Process-specific
  Swap Usage:             0 MB
  
  Peak RSS:               1.8 GB (at 14:30)
  Current vs Peak:        66% of peak

MEMORY MAP BREAKDOWN
───────────────────────────────────────────────────────────────────────────────
  Category          Size        Count    Description
  ─────────────────────────────────────────────────────────────────────────────
  [heap]            890 MB      1        Dynamic allocations
  [stack]           8 MB        1        Thread stack
  Libraries         156 MB      47       Shared libraries (.so)
  [anon]            234 MB      89       Anonymous mappings
  Mapped files      45 MB       12       mmap'd files
  ─────────────────────────────────────────────────────────────────────────────
  Total mapped:     1.3 GB

TOP LIBRARIES BY SIZE
───────────────────────────────────────────────────────────────────────────────
  45 MB    /usr/lib/python3.10/site-packages/numpy/core/_multiarray_umath.so
  23 MB    /usr/lib/x86_64-linux-gnu/libpython3.10.so.1.0
  18 MB    /usr/lib/python3.10/site-packages/pandas/_libs/lib.so
  12 MB    /lib/x86_64-linux-gnu/libc.so.6
  8 MB     /usr/lib/python3.10/site-packages/scipy/...

MEMORY TREND (last 8 hours)
───────────────────────────────────────────────────────────────────────────────
RSS:
  1.8G │                    ▄▄▄▄
  1.5G │          ▄▄▄▄▄▄▄▄▄█████▄▄▄▄
  1.2G │▄▄▄▄▄▄▄▄▄██████████████████████▄▄▄▄▄▄▄▄▄▄▄▄▄
  0.9G │██████████████████████████████████████████████
       └──────────────────────────────────────────────
         08:00    10:00    12:00    14:00    16:00

  ⚠️ Memory peaked at 14:30, then stabilised
  📈 Growth rate: +50MB/hour average (potential slow leak)

LEAK DETECTION
───────────────────────────────────────────────────────────────────────────────
  Status: ⚠️ POSSIBLE LEAK DETECTED
  
  Observations:
  - RSS increased 400 MB over 8 hours
  - Heap grew from 600 MB to 890 MB
  - No corresponding decrease
  
  Recommendation:
  - Profile with: valgrind --leak-check=full
  - Or: python -m memory_profiler
```

### Memory Leak Comparison

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                    MEMORY COMPARISON: PID 3240                               ║
║                    Interval: 60 seconds                                      ║
╚══════════════════════════════════════════════════════════════════════════════╝

SNAPSHOT COMPARISON
───────────────────────────────────────────────────────────────────────────────
                        Before          After           Delta
  RSS:                  1,200 MB        1,215 MB        +15 MB ⚠️
  VSZ:                  2,400 MB        2,420 MB        +20 MB
  Heap:                 890 MB          905 MB          +15 MB ⚠️
  Mapped files:         45 MB           45 MB           0
  Shared:               45 MB           45 MB           0

NEW MEMORY MAPPINGS
───────────────────────────────────────────────────────────────────────────────
  + [anon] 7f8a12340000-7f8a12440000 (1 MB) rw-p
  + [anon] 7f8a12440000-7f8a12540000 (1 MB) rw-p

ANALYSIS
───────────────────────────────────────────────────────────────────────────────
  ⚠️ Warning: Heap grew 15 MB in 60 seconds
  
  Leak rate: ~15 MB/minute = 900 MB/hour
  At this rate, OOM in: ~45 minutes
  
  Likely causes:
  - Unbounded cache growth
  - Connection pool not releasing
  - Data structure accumulation
  
  Action: Profile application or restart
```

---

## Project Structure

```
M11_Memory_Forensics_Tool/
├── README.md
├── Makefile
├── src/
│   ├── memtool.sh               # Main script
│   └── lib/
│       ├── procmem.sh           # Per-process memory info
│       ├── sysmem.sh            # System memory info
│       ├── maps.sh              # Memory maps parsing
│       ├── leak.sh              # Leak detection
│       ├── snapshot.sh          # Snapshot and comparison
│       └── report.sh            # Report generation
├── etc/
│   └── memtool.conf
├── tests/
│   ├── test_procmem.sh
│   ├── test_leak.sh
│   └── leaky_program.c          # Test program with leak
└── docs/
    ├── INSTALL.md
    └── MEMORY_LINUX.md
```

---

## Implementation Hints

### Reading system memory info

```bash
get_meminfo() {
    local meminfo="/proc/meminfo"
    
    declare -A mem
    while IFS=': ' read -r key value _; do
        mem[$key]=$value
    done < "$meminfo"
    
    echo "Total: ${mem[MemTotal]} kB"
    echo "Free: ${mem[MemFree]} kB"
    echo "Available: ${mem[MemAvailable]} kB"
    echo "Buffers: ${mem[Buffers]} kB"
    echo "Cached: ${mem[Cached]} kB"
    echo "SwapTotal: ${mem[SwapTotal]} kB"
    echo "SwapFree: ${mem[SwapFree]} kB"
}
```

### Process memory info

```bash
get_process_memory() {
    local pid="$1"
    
    # From /proc/[pid]/status
    local status="/proc/$pid/status"
    
    local vmrss vmsize vmswap
    vmrss=$(awk '/VmRSS/ {print $2}' "$status")
    vmsize=$(awk '/VmSize/ {print $2}' "$status")
    vmswap=$(awk '/VmSwap/ {print $2}' "$status")
    
    # From /proc/[pid]/statm (in pages)
    local statm
    read -r size resident shared text lib data dirty < "/proc/$pid/statm"
    
    local page_size
    page_size=$(getconf PAGE_SIZE)
    
    echo "RSS: $((resident * page_size / 1024)) kB"
    echo "Shared: $((shared * page_size / 1024)) kB"
    echo "Private: $(( (resident - shared) * page_size / 1024)) kB"
}
```

### Parsing memory maps

```bash
parse_maps() {
    local pid="$1"
    local maps="/proc/$pid/maps"
    
    declare -A categories
    
    while IFS=' ' read -r range perms offset dev inode pathname; do
        # Calculate size
        local start end size
        start=$((16#${range%-*}))
        end=$((16#${range#*-}))
        size=$(( (end - start) / 1024 ))  # in KB
        
        # Categorise
        case "$pathname" in
            "[heap]")   ((categories[heap]+=$size)) ;;
            "[stack]")  ((categories[stack]+=$size)) ;;
            "[vdso]"|"[vvar]"|"[vsyscall]") 
                        ((categories[kernel]+=$size)) ;;
            "")         ((categories[anon]+=$size)) ;;
            *.so*)      ((categories[libs]+=$size)) ;;
            *)          ((categories[files]+=$size)) ;;
        esac
    done < "$maps"
    
    for cat in "${!categories[@]}"; do
        echo "$cat: ${categories[$cat]} KB"
    done
}
```

### Leak detection

```bash
snapshot_memory() {
    local pid="$1"
    local snapshot_file="/tmp/memtool_${pid}_$(date +%s).snap"
    
    # Save all relevant data
    {
        echo "timestamp=$(date +%s)"
        echo "rss=$(awk '/VmRSS/ {print $2}' /proc/$pid/status)"
        echo "heap_size=$(awk '/\[heap\]/ {
            split($1, a, "-"); 
            print strtonum("0x"a[2]) - strtonum("0x"a[1])
        }' /proc/$pid/maps)"
        echo "maps_hash=$(md5sum /proc/$pid/maps | cut -d' ' -f1)"
    } > "$snapshot_file"
    
    echo "$snapshot_file"
}

compare_snapshots() {
    local snap1="$1"
    local snap2="$2"
    
    source "$snap1"
    local rss1=$rss heap1=$heap_size
    
    source "$snap2"
    local rss2=$rss heap2=$heap_size
    
    local rss_delta=$((rss2 - rss1))
    local heap_delta=$((heap2 - heap1))
    
    echo "RSS delta: $rss_delta KB"
    echo "Heap delta: $heap_delta KB"
    
    if ((rss_delta > 10240)); then  # > 10MB
        echo "⚠️ Significant memory growth detected"
    fi
}
```

---

## Specific Evaluation Criteria

| Criterion | Weight | Description |
|-----------|--------|-------------|
| System overview | 15% | Correct meminfo, calculations |
| Process analysis | 25% | RSS, maps, breakdown |
| Leak detection | 20% | Snapshot, compare, alert |
| Memory maps | 15% | Parsing, categorisation |
| Reporting | 10% | Clear format, export |
| Watch mode | 5% | Continuous monitoring |
| Code quality + tests | 5% | ShellCheck, tests |
| Documentation | 5% | README, memory concepts |

---

## Resources

- `man proc` - /proc/[pid]/maps, /proc/[pid]/status
- `man free`, `man vmstat`
- Linux memory management documentation
- Seminar 2-3 - Processes, memory

---

*MEDIUM Project | Operating Systems | ASE-CSIE*
