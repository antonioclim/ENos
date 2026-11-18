# M10: Process Tree Analyzer

> **Level:** MEDIUM | **Estimated time:** 25-35 hours | **K8s Bonus:** +10%

---

## Description

> 💡 **Instructor's note:** This project will transform how you understand Linux. After completing it, you will never look at `ps aux` the same way. I have seen students debug production issues at internships using skills from this project. The `/proc` filesystem is one of Linux's most elegant designs — this project teaches you to read it like a book.

Advanced tool for process hierarchy analysis: tree visualisation with parent-child relationships, resource tracking per process and per group, orphan/zombie/runaway process detection and export for further analysis.

---

## Learning Objectives

- Linux process structure (PID, PPID, SID, PGID)
- Information from `/proc` filesystem
- Tree visualisation in terminal
- Process anomaly detection
- Relationship with cgroups and namespaces

---

## Functional Requirements

### Mandatory (for passing grade)

1. **Process tree visualisation**
   - Hierarchical display (similar to `pstree`)
   - With extended information (PID, user, CPU, RAM)
   - Filter by user, command, PID

2. **Per-process analysis**
   - CPU and memory usage
   - Threads, file descriptors
   - Environment variables
   - Working directory, executable path

3. **Anomaly detection**
   - Zombie processes (defunct)
   - Direct children of namespace PID 1 (not proof of orphaning)
   - High CPU/memory consumers
   - High descriptor counts (a leak requires trend and workload evidence)

4. **Grouping and aggregation**
   - Resources per user
   - Resources per session/process group
   - Top consumers

5. **Export**
   - JSON for processing
   - DOT format for Graphviz
   - Text for documentation

### Optional (for full marks)

6. **Real-time monitoring** - Continuous update (like `top`)
7. **Process timeline** - Start/stop history
8. **Container awareness** - Detect processes in containers
9. **Kill/signal interface** - Send signals from tool
10. **Namespace support** - Visualisation by namespaces

---

## CLI Interface

```text
./proctree.sh <command> [options]

Commands:
  tree [pid]            Display process tree (from PID or root)
  info <pid>            Detailed information about process
  children <pid>        List children (direct or recursive)
  analyze               Complete system analysis
  anomalies             Detect problematic processes
  top                   Top consumers (CPU/RAM)
  watch [pid]           Real-time monitoring
  export                Export data for analysis

Options:
  -u, --user USER       Filter by user
  -d, --depth N         Max tree depth
  -f, --format FMT      Output format (text|json|dot)
  -s, --sort FIELD      Sort by field (cpu|mem|pid|name)
  -n, --limit N         Limit results
  --threads             Include threads
  --env                 Include environment variables
  --fds                 Include file descriptors

Examples:
  ./proctree.sh tree 1 --depth 3
  ./proctree.sh info $$
  ./proctree.sh anomalies
  ./proctree.sh top --sort mem -n 10
  ./proctree.sh export --format dot | dot -Tpng -o tree.png
```

---

## Output Examples

### Process Tree

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                    PROCESS TREE ANALYZER                                     ║
║                    Host: server01 | Processes: 234 | Threads: 892           ║
╚══════════════════════════════════════════════════════════════════════════════╝

PROCESS TREE
═══════════════════════════════════════════════════════════════════════════════

systemd(1) root [CPU: 0.1%, MEM: 12MB]
├── systemd-journald(456) root [CPU: 0.3%, MEM: 45MB]
├── systemd-udevd(489) root [CPU: 0.0%, MEM: 8MB]
├── sshd(1023) root [CPU: 0.0%, MEM: 5MB]
│   └── sshd(15234) root [CPU: 0.0%, MEM: 6MB]
│       └── sshd(15236) antonio [CPU: 0.0%, MEM: 6MB]
│           └── bash(15237) antonio [CPU: 0.0%, MEM: 4MB]
│               └── vim(15890) antonio [CPU: 0.2%, MEM: 28MB]
├── nginx(2045) root [CPU: 0.0%, MEM: 3MB]
│   ├── nginx(2046) www-data [CPU: 1.2%, MEM: 45MB]
│   ├── nginx(2047) www-data [CPU: 0.8%, MEM: 42MB]
│   ├── nginx(2048) www-data [CPU: 0.9%, MEM: 43MB]
│   └── nginx(2049) www-data [CPU: 1.1%, MEM: 44MB]
├── postgresql(2234) postgres [CPU: 2.3%, MEM: 256MB]
│   ├── postgres(2235) postgres [CPU: 0.1%, MEM: 12MB] (checkpointer)
│   ├── postgres(2236) postgres [CPU: 0.2%, MEM: 15MB] (background writer)
│   ├── postgres(2237) postgres [CPU: 0.1%, MEM: 10MB] (walwriter)
│   └── postgres(2238) postgres [CPU: 5.2%, MEM: 180MB] (connection)
├── dockerd(3001) root [CPU: 0.5%, MEM: 89MB]
│   └── containerd(3012) root [CPU: 0.3%, MEM: 45MB]
│       └── containerd-shim(3234) root [CPU: 0.0%, MEM: 12MB]
│           └── python(3240) 1000:1000 [CPU: 8.5%, MEM: 512MB] 🐳 myapp
└── cron(1890) root [CPU: 0.0%, MEM: 2MB]

Legend: 🐳 = container | [Z] = zombie | ⚠️ = high resource

Total: 234 processes, 892 threads
System CPU: 15.2% | System Memory: 4.2GB / 16GB (26%)
```

### Process Info

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                    PROCESS DETAILS: 15890 (vim)                             ║
╚══════════════════════════════════════════════════════════════════════════════╝

BASIC INFO
───────────────────────────────────────────────────────────────────────────────
  PID:          15890
  PPID:         15237 (bash)
  User:         antonio (1000)
  Group:        antonio (1000)
  State:        S (Sleeping)
  Started:      2025-01-20 15:30:45 (2h 15m ago)
  
EXECUTABLE
───────────────────────────────────────────────────────────────────────────────
  Command:      vim /home/antonio/project/main.py
  Executable:   /usr/bin/vim.basic
  CWD:          /home/antonio/project
  
RESOURCE USAGE
───────────────────────────────────────────────────────────────────────────────
  CPU:          0.2% (user: 0.15%, system: 0.05%)
  Memory:       28 MB (RSS)
  Virtual:      156 MB (VSZ)
  Shared:       8 MB
  Threads:      1
  
FILE DESCRIPTORS (12 open)
───────────────────────────────────────────────────────────────────────────────
  0  → /dev/pts/1 (stdin)
  1  → /dev/pts/1 (stdout)
  2  → /dev/pts/1 (stderr)
  3  → /home/antonio/project/main.py
  4  → /home/antonio/project/.main.py.swp
  ...

ENVIRONMENT (partial)
───────────────────────────────────────────────────────────────────────────────
  HOME=/home/antonio
  PATH=/usr/local/bin:/usr/bin:/bin
  SHELL=/bin/bash
  TERM=xterm-256color
  EDITOR=vim

HIERARCHY
───────────────────────────────────────────────────────────────────────────────
  Session:      15237 (bash)
  Process Group: 15890
  Terminal:     /dev/pts/1
  
  Ancestors:
    └── systemd(1) → sshd(1023) → sshd(15234) → bash(15237) → vim(15890)
```

### Anomalies Report

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                    PROCESS ANOMALIES DETECTED                                ║
╚══════════════════════════════════════════════════════════════════════════════╝

🔴 ZOMBIE PROCESSES (2)
───────────────────────────────────────────────────────────────────────────────
  PID      PPID     Command              Since
  8923     8901     defunct              2h 45m
  9012     8901     defunct              1h 30m
  
  Parent: 8901 (python /opt/worker.py) - not reaping children!
  Action: Investigate reaping and service context; repair wait() handling before considering a controlled restart

⚠️ HIGH CPU CONSUMERS (>50% sustained)
───────────────────────────────────────────────────────────────────────────────
  PID      User     CPU%     Duration    Command
  12456    mysql    85.2%    15m         mysqld (query)
  3240     1000     78.5%    8m          python myapp.py
  
🟡 HIGH MEMORY CONSUMERS (>1GB)
───────────────────────────────────────────────────────────────────────────────
  PID      User     Memory   %Total    Command
  12456    mysql    2.8 GB   17.5%     mysqld
  3240     1000     1.2 GB   7.5%      python myapp.py
  
⚠️ HIGH FILE DESCRIPTOR COUNTS (>1000 FDs)
───────────────────────────────────────────────────────────────────────────────
  PID      User     FDs      Limit     Command
  4567     www      2456     4096      node server.js
  
  Warning: Approaching FD limit, may cause "too many open files"

🟡 NON-ROOT DIRECT CHILDREN OF PID 1 (service/orphan status unknown)
───────────────────────────────────────────────────────────────────────────────
  PID      User     Started     Command
  7890     antonio  3d ago      /usr/bin/python old_script.py
  7891     antonio  3d ago      sleep 99999
  
  These may be services or reparented processes; PPID and UID alone do not establish the cause

SUMMARY
───────────────────────────────────────────────────────────────────────────────
  🔴 Critical:  2 (zombies)
  ⚠️ Warning:   5 (high resource, FD leak)
  🟡 Info:      2 (orphans)
```

---

## Project Structure

```
M10_Process_Tree_Analyzer/
├── README.md
├── Makefile
├── src/
│   ├── proctree.sh              # Main script
│   └── lib/
│       ├── procinfo.sh          # Read info from /proc
│       ├── tree.sh              # Build and display tree
│       ├── analyze.sh           # Analysis and anomaly detection
│       ├── export.sh            # JSON/DOT export
│       ├── watch.sh             # Real-time monitoring
│       └── utils.sh             # Common functions
├── etc/
│   └── proctree.conf
├── tests/
│   ├── test_procinfo.sh
│   ├── test_tree.sh
│   └── mock_proc/               # Mock /proc for tests
└── docs/
    ├── INSTALL.md
    └── PROC_FILESYSTEM.md
```

---

## Implementation Hints

### Reading process info from /proc

```bash
get_process_info() {
    python3 - "$1" <<'PYPROC'
import json,re,sys
from pathlib import Path
pid=sys.argv[1]
if not re.fullmatch(r'[1-9][0-9]*',pid): raise SystemExit(2)
root=Path('/proc')/pid
try:
    rows={line.split(':',1)[0]:line.split(':',1)[1].strip() for line in (root/'status').read_text().splitlines() if ':' in line}
    name=rows['Name']; ppid=rows['PPid']; state=rows['State'].split()[0]; uid=rows['Uid'].split()[0]
    rss=rows.get('VmRSS','0').split()[0]
    argv=(root/'cmdline').read_bytes().split(b'\0')
    # Display encoding: JSON string content, with | escaped to preserve this record grammar.
    escape=lambda value: json.dumps(value,ensure_ascii=True)[1:-1].replace('|',r'\u007c')
    command=' '.join(x.decode('utf-8','backslashreplace') for x in argv if x)
    print('|'.join([pid,ppid,escape(name),state,uid,rss,escape(command)]))
except (OSError,KeyError,ValueError): raise SystemExit(1)  # Process may disappear during observation.
PYPROC
}

get_all_processes() {
    local pid_dir
    for pid_dir in /proc/[0-9]*; do get_process_info "${pid_dir##*/}" || continue; done
}
```

Process name/command fields use JSON-escaped display text (without outer quotes), including `\u007c` for a pipe. This keeps newline/pipe bytes out of record delimiters. A `/proc` read remains a changing observation, not an atomic process snapshot.

### Building the tree

```bash
declare -A CHILDREN
declare -A PROC_INFO

build_tree() {
    CHILDREN=(); PROC_INFO=()
    # Each refresh replaces the previous snapshot.
    # Read all processes
    while IFS='|' read -r pid ppid name state uid rss cmd; do
        [[ $pid =~ ^[0-9]+$ && $ppid =~ ^[0-9]+$ ]] || continue
        [[ -z ${PROC_INFO[$pid]:-} ]] || continue
        PROC_INFO[$pid]="$name|$state|$uid|$rss|$cmd"
        CHILDREN[$ppid]+="$pid "
    done < <(get_all_processes)
}

print_tree() {
    local pid="${1:-1}"
    local prefix="${2:-}"
    local is_last="${3:-true}"
    
    # Get process info
    IFS='|' read -r name state uid rss cmd <<< "${PROC_INFO[$pid]:-}"
    
    # Display current node
    local branch child_prefix name state uid rss cmd child
    if [[ "$is_last" == "true" ]]; then
        branch="└── "
        child_prefix="${prefix}    "
    else
        branch="├── "
        child_prefix="${prefix}│   "
    fi
    
    echo "${prefix}${branch}${name}($pid) [MEM: ${rss}KB]"
    
    # Display children
    local children="${CHILDREN[$pid]:-}"
    local -a child_array=()
    IFS=' ' read -r -a child_array <<< "$children"
    local count=${#child_array[@]}
    local i=0
    
    for child in "${child_array[@]}"; do
        i=$((i + 1))
        local last=$( ((i == count)) && echo "true" || echo "false" )
        print_tree "$child" "$child_prefix" "$last"
    done
}
```

### Detecting zombies

```bash
find_zombies() {
    while IFS='|' read -r pid ppid name state uid rss cmd; do
        if [[ "$state" == "Z" ]]; then
            echo "ZOMBIE|$pid|$ppid|$name"
        fi
    done < <(get_all_processes)
}

find_orphans() {
    while IFS='|' read -r pid ppid name state uid rss cmd; do
        # Snapshot predicate only: no conclusion about daemon/orphan provenance.
        if [[ "$ppid" == "1" && "$uid" != "0" ]]; then
            echo "INIT_CHILD_NONROOT|$pid|$name|$uid"
        fi
    done < <(get_all_processes)
}
```

### DOT export for Graphviz

```bash
export_dot() {
    echo "digraph process_tree {"
    echo "    rankdir=TB;"
    echo "    node [shape=box];"
    
    while IFS='|' read -r pid ppid name state uid rss cmd; do
        local color="white"
        [[ "$state" == "Z" ]] && color="red"
        [[ "$state" == "R" ]] && color="green"
        
        local label
        label=$(python3 -c 'import json,sys; print(json.dumps(json.loads(chr(34)+sys.argv[1]+chr(34))+"\n("+sys.argv[2]+")"))' "$name" "$pid") || return 1
        printf '    "%s" [label=%s fillcolor=%s style=filled];\n' "$pid" "$label" "$color"
        [[ "$ppid" != "0" ]] && echo "    \"$ppid\" -> \"$pid\";"
    done < <(get_all_processes)
    
    echo "}"
}
```

---

## ⚠️ Common Pitfalls

> Based on previous years' submissions, these are the mistakes students make most often:

### 1. Race Conditions in /proc
**Problem:** A process terminates between listing and reading its info.
**Solution:** Always check if files exist and handle errors gracefully.

### 2. Not Handling Kernel Threads
**Problem:** Kernel threads (like kworker) crash your parser.
**Solution:** Check if `/proc/PID/exe` is readable — kernel threads have no executable.

### 3. Inefficient Tree Building
**Problem:** Reading /proc multiple times for each tree traversal.
**Solution:** Build the tree data structure once, then traverse in memory.

### 4. Missing Permissions
**Problem:** Cannot read /proc/PID/environ for processes owned by other users.
**Solution:** Document the limitation, require sudo for full analysis, or skip gracefully.

---

## Specific Evaluation Criteria

| Criterion | Weight | Description |
|-----------|--------|-------------|
| Tree display | 20% | Correct hierarchy, formatting |
| Per-process info | 20% | CPU, RAM, FDs, env, etc. |
| Anomaly detection | 20% | Zombies, orphans, resource hogs |
| Aggregation/grouping | 15% | Per user, top consumers |
| Export | 10% | JSON, functional DOT |
| Real-time monitoring | 5% | Watch mode |
| Code quality + tests | 5% | ShellCheck, tests |
| Documentation | 5% | README, /proc doc |

---

## Resources

- `man proc` - /proc filesystem
- `man ps`, `man pstree`
- Linux kernel documentation on processes
- Seminar 2 - Processes and signals

---

*MEDIUM Project | Operating Systems | ASE-CSIE*
