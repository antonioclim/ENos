# Demo Scripts — Course 17 Supplementary: eBPF and Kernel Level Programming

> Operating Systems | ASE Bucharest - CSIE | 2025-2026  
> by Revolvix

---

## Scripts Overview

| Script | Language | Purpose | Complexity |
|--------|----------|---------|------------|
| `netmonitor.py` | Python + BCC | Network traffic monitor with eBPF | Advanced |
| `system_monitor.bt` | bpftrace | System call tracing and latencies | Advanced |

---

## Quick Start

### Network Monitor (requires root + BCC)

```bash
# Monitor all new TCP connections
sudo python3 netmonitor.py

# Filter by destination port
sudo python3 netmonitor.py --port 80
sudo python3 netmonitor.py --port 443

# Filter by process name
sudo python3 netmonitor.py --comm nginx
sudo python3 netmonitor.py --comm curl

# Filter by PID
sudo python3 netmonitor.py --pid 1234

# Combination of filters
sudo python3 netmonitor.py --port 443 --comm firefox

# Output in JSON format (for processing)
sudo python3 netmonitor.py --json > connections.jsonl

# Verbose mode with additional details
sudo python3 netmonitor.py --verbose
```

### System Monitor (requires root + bpftrace)

```bash
# Run the complete script
sudo bpftrace system_monitor.bt

# Trace only specific syscalls
sudo bpftrace -e 'tracepoint:syscalls:sys_enter_open* { printf("%s opened %s\n", comm, str(args->filename)); }'

# read() latency histogram
sudo bpftrace -e 'tracepoint:syscalls:sys_enter_read { @start[tid] = nsecs; }
                  tracepoint:syscalls:sys_exit_read /@start[tid]/ { 
                      @latency = hist(nsecs - @start[tid]); 
                      delete(@start[tid]); 
                  }'

# Top processes by syscall count
sudo bpftrace -e 'tracepoint:raw_syscalls:sys_enter { @[comm] = count(); }'

# Monitor page faults
sudo bpftrace -e 'software:page-faults:1 { @[comm] = count(); }'
```

---

## Connection to Course Concepts

### eBPF Architecture (netmonitor.py)

The script demonstrates the complete eBPF cycle:

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         eBPF FLOW                                       │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  [User Space]                      [Kernel Space]                       │
│                                                                         │
│  netmonitor.py                                                          │
│       │                                                                 │
│       │ 1. Compiles C code → eBPF bytecode                             │
│       │    (via BCC/LLVM)                                              │
│       ↓                                                                 │
│  ┌─────────┐      bpf()        ┌─────────────────┐                     │
│  │ eBPF    │ ──────syscall────→│   eBPF          │                     │
│  │ Program │                   │   Verifier      │                     │
│  └─────────┘                   └────────┬────────┘                     │
│                                         │                              │
│                                    2. Verifies:                        │
│                                    - Guaranteed termination            │
│                                    - Valid memory access               │
│                                    - No invalid pointers               │
│                                         │                              │
│                                         ↓                              │
│                                ┌─────────────────┐                     │
│                                │   JIT Compiler  │                     │
│                                │ (bytecode→native)│                    │
│                                └────────┬────────┘                     │
│                                         │                              │
│                                         ↓                              │
│                                ┌─────────────────┐                     │
│                                │   Attach to     │                     │
│                                │   kprobe/       │                     │
│                                │   tracepoint    │                     │
│                                └────────┬────────┘                     │
│                                         │                              │
│       ┌─────────────────────────────────┘                              │
│       │ 3. On each event:                                              │
│       │    - Execute eBPF program                                      │
│       │    - Write to BPF map                                          │
│       ↓                                                                 │
│  ┌─────────┐     perf_buffer    ┌─────────────────┐                    │
│  │ Python  │ ←─────read────────│    BPF Map      │                    │
│  │ callback│                   │ (ring buffer)   │                    │
│  └─────────┘                   └─────────────────┘                     │
│       │                                                                 │
│       │ 4. Process and display                                         │
│       ↓                                                                 │
│  [Terminal output]                                                      │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

### Attachment Points (Hooks)

| Type | Usage in scripts | When triggered |
|------|------------------|----------------|
| **kprobe** | `netmonitor.py` (tcp_connect, tcp_accept) | On kernel function entry |
| **kretprobe** | Return values | On kernel function exit |
| **tracepoint** | `system_monitor.bt` (syscalls) | Predefined kernel events |
| **uprobe** | Utilizatorspace functions | On binary function entry |
| **USDT** | Application probes | Explicit code markers |

### BPF Maps

Map types used:
- **BPF_HASH**: Key-value dictionary (tracking connections)
- **BPF_PERF_OUTPUT**: Ring buffer for events (user notification)
- **BPF_HISTOGRAM**: Statistical aggregations (latency distribution)
- **BPF_ARRAY**: Array with O(1) access

### bpftrace Syntax (system_monitor.bt)

```
probe_type:probe_name /filter/ { action }

Examples:
  tracepoint:syscalls:sys_enter_read    # Tracepoint for read()
  kprobe:vfs_read                       # Kprobe for vfs_read
  uprobe:/bin/bash:readline             # Uprobe in bash
  
Built-in variables:
  pid, tid      - Process/Thread ID
  comm          - Process name (16 char)
  nsecs         - Timestamp nanoseconds
  args          - Arguments (for tracepoints)
  retval        - Return value (for ret probes)
  
Functions:
  printf()      - Formatted output
  str()         - Convert to string
  hist()        - Histogram
  count()       - Counter
  @map[key]     - Map access
```

---

## Exemplu Output

### netmonitor.py

```
$ sudo python3 netmonitor.py --port 443
════════════════════════════════════════════════════════════════════════════════
eBPF NETWORK MONITOR — Tracking TCP connections (port filter: 443)
════════════════════════════════════════════════════════════════════════════════
TIME       PID    COMM             SADDR            SPORT  DADDR            DPORT
────────────────────────────────────────────────────────────────────────────────
10:15:23   1842   firefox          192.168.1.50     54321  142.250.185.68   443
10:15:23   1842   firefox          192.168.1.50     54322  142.250.185.68   443
10:15:24   1842   firefox          192.168.1.50     54323  151.101.1.140    443
10:15:25   2156   curl             192.168.1.50     54324  93.184.216.34    443
10:15:30   1842   firefox          192.168.1.50     54325  157.240.1.35     443
────────────────────────────────────────────────────────────────────────────────
[Connections: 5] [Ctrl+C to exit]
```

### system_monitor.bt

```
$ sudo bpftrace system_monitor.bt
Attaching 5 probes...

════════════════════════════════════════════════════════════════════════════════
SYSTEM MONITOR — Syscall tracing and latency analysis
════════════════════════════════════════════════════════════════════════════════

[Syscalls by process - last 5 seconds]
@syscalls[firefox]: 15234
@syscalls[Xorg]: 8421
@syscalls[pulseaudio]: 3210
@syscalls[bash]: 156

[Read latency histogram (nanoseconds)]
@read_latency:
[1K, 2K)              1523 |@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@|
[2K, 4K)               842 |@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                       |
[4K, 8K)               421 |@@@@@@@@@@@@@@                                      |
[8K, 16K)              156 |@@@@@                                               |
[16K, 32K)              42 |@                                                   |
[32K, 64K)              12 |                                                    |
[64K, 128K)              3 |                                                    |

[File opens - top 10]
@opens[/proc/stat]: 1542
@opens[/dev/null]: 823
@opens[/etc/passwd]: 156
@opens[/tmp/firefox_cache]: 89
...

^C
Cleaning up...
```

---

## System Requirements

### Kernel and Distribution

- **Ubuntu 24.04** with kernel 5.15+ (recommended 6.0+)
- **BTF** (BPF Type Format) enabled in kernel
- Root privileges or capabilities `CAP_BPF`, `CAP_PERFMON`

### Required Packages

```bash
# BCC (BPF Compiler Collection)
sudo apt update
sudo apt install bpfcc-tools python3-bpfcc libbpfcc-dev

# bpftrace
sudo apt install bpftrace

# Kernel headers (for BTF)
sudo apt install linux-headers-$(uname -r)

# Optional: for advanced eBPF development
sudo apt install libbpf-dev clang llvm
```

### Verify eBPF Support

```bash
# Check kernel version
uname -r
# Minimum: 5.8 for modern features

# Check BTF availability
ls -la /sys/kernel/btf/vmlinux
# Must exist for BCC/bpftrace

# Check bpf() syscall availability
cat /proc/kallsyms | grep -w bpf
# Should show __x64_sys_bpf or similar

# Quick bpftrace test
sudo bpftrace -e 'BEGIN { printf("eBPF works!\n"); exit(); }'

# Quick BCC test
sudo python3 -c "from bcc import BPF; print('BCC works!')"
```

---

## Troubleshooting

| Problem | Cause | Solution |
|---------|-------|----------|
| "BPF not supported" | Kernel without CONFIG_BPF | Recompile kernel or use standard distribution |
| "BTF not found" | Missing headers | `sudo apt install linux-headers-$(uname -r)` |
| "Permission denied" | Missing capabilities | Run with `sudo` or add `CAP_BPF` |
| "Failed to load BPF program" | Verifier error | Check eBPF code (limits, invalid accesses) |
| "bcc module not found" | Wrong Python path | `sudo apt install python3-bpfcc` |
| "Unknown tracepoint" | Different kernel | Check with `sudo bpftrace -l 'tracepoint:*'` |

### Debugging eBPF

```bash
# View all available tracepoints
sudo bpftrace -l 'tracepoint:*' | grep syscalls

# View all available kprobes
sudo bpftrace -l 'kprobe:*' | grep tcp

# Verbose BCC output
sudo python3 netmonitor.py --debug 2>&1 | head -50

# Check loaded eBPF programs
sudo bpftool prog list

# Check eBPF maps
sudo bpftool map list
```

---

## Proposed Exercises

1. **Modify netmonitor.py**: Add UDP tracking in addition to TCP.

2. **Latency profiling**: Use bpftrace to measure write() latency and compare with read().

3. **Process tracking**: Write a bpftrace script that displays all processes performing fork().

4. **Security monitoring**: Create a monitor that alerts when a process accesses `/etc/shadow`.

5. **Comparison**: Compare the overhead between `strace` and eBPF monitoring for the same process.

---

## Additional Resources

- **Brendan Gregg's Blog**: https://www.brendangregg.com/ebpf.html
- **BCC Reference Guide**: https://github.com/iovisor/bcc/blob/master/docs/reference_guide.md
- **bpftrace Reference**: https://github.com/iovisor/bpftrace/blob/master/docs/reference_guide.md
- **eBPF.io**: https://ebpf.io/

---

*Materials developed by Revolvix for ASE Bucharest - CSIE*  
*Operating Systems | Year I, Semester 2 | 2025-2026*
