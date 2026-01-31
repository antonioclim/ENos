<!-- RO: TRADUS ȘI VERIFICAT -->
# Demo Scripts — Lecture 16 Supplementary: Advanced Containerisation

> Operating Systems | ASE Bucharest - CSIE | 2025-2026  
> by Revolvix

---

## Script Contents

| Script | Language | Purpose | Complexity |
|--------|----------|------|--------------|
| `cgroup_monitor.py` | Python | Real-time cgroups v2 monitor | Advanced |
| `mini_container.sh` | Bash | Minimal container with namespaces | Advanced |

### Shared Scripts (from Lecture 15)

The following scripts are used for testing network isolation and are shared with **Lecture 15 Supplementary: Connecting to the Network**. You can find them in the directory `../15supp-Conectarea_la_Retea/scripts/`:

| Script | Location | Purpose in containerisation context |
|--------|---------|-------------------------------|
| `echo_server.py` | `../15supp-Conectarea_la_Retea/scripts/` | TCP server for network isolation tests |
| `echo_client.py` | `../15supp-Conectarea_la_Retea/scripts/` | TCP client for connectivity tests |
| `network_diag.sh` | `../15supp-Conectarea_la_Retea/scripts/` | Network diagnostics from within container |
| `firewall_basic.sh` | `../15supp-Conectarea_la_Retea/scripts/` | iptables rules for containers |

> **Note**: These scripts are functionally identical. Sharing eliminates duplication and ensures consistency between lectures.

---

## Quick Usage

### cgroups v2 Monitor

```bash
# Monitor all cgroups
python3 cgroup_monitor.py

# Monitor a specific Docker container (by ID or name)
python3 cgroup_monitor.py --docker <container_id>
python3 cgroup_monitor.py --docker nginx

# Monitor a specific cgroup path
python3 cgroup_monitor.py /sys/fs/cgroup/user.slice/

# Refresh every 2 seconds
python3 cgroup_monitor.py --interval 2

# JSON output for further processing
python3 cgroup_monitor.py --json > metrics.json
```

### Mini-Container (requires root)

```bash
# Minimal container with complete isolation
sudo ./mini_container.sh

# With memory limit (100MB)
sudo ./mini_container.sh --memory 100M

# With CPU limit (50% of one core)
sudo ./mini_container.sh --cpu 0.5

# With network isolation (separate network namespace)
sudo ./mini_container.sh --net-isolate

# With custom root filesystem
sudo ./mini_container.sh --rootfs /path/to/rootfs

# Combination: limited container with interactive bash
sudo ./mini_container.sh --memory 50M --cpu 0.25 --net-isolate -- /bin/bash
```

### Network Isolation Tests (using shared scripts from Lecture 15)

```bash
# Path to shared scripts
SHARED_SCRIPTS="../15supp-Conectarea_la_Retea/scripts"

# In container: start server
sudo ./mini_container.sh --net-isolate -- python3 $SHARED_SCRIPTS/echo_server.py --port 8080

# From host: test that you CANNOT connect (isolated)
python3 $SHARED_SCRIPTS/echo_client.py --host 127.0.0.1 --port 8080  # Should fail

# Network diagnostics from inside the container
sudo ./mini_container.sh --net-isolate -- bash $SHARED_SCRIPTS/network_diag.sh
```

---

## Connection to Lecture Concepts

### cgroups v2 (cgroup_monitor.py)

The script reads metrics from the `/sys/fs/cgroup` hierarchy:

```
/sys/fs/cgroup/
├── cgroup.controllers      # Available controllers
├── cgroup.subtree_control  # Active controllers for children
├── cpu.stat               # CPU statistics (usage_usec, user_usec, system_usec)
├── memory.current         # Currently used memory
├── memory.max             # Memory limit
├── memory.swap.current    # Swap used
├── pids.current           # Number of processes/threads
├── pids.max               # PID limit
├── io.stat                # I/O statistics per device
└── <subgroup>/            # Subgroups (e.g.: docker/, user.slice/)
```

**Exposed metrics:**
- **CPU**: total time, user, system (in microseconds)
- **Memory**: current, maximum, swap
- **PIDs**: current count, limit
- **I/O**: bytes read/written per device

### Namespaces (mini_container.sh)

The script uses `unshare` for isolation:

| Namespace | Flag | Isolates |
|-----------|------|----------|
| Mount | `--mount` | Filesystem mounts |
| UTS | `--uts` | Hostname, domainname |
| IPC | `--ipc` | System V IPC, POSIX queues |
| Network | `--net` | Complete network stack |
| PID | `--pid` | Process ID space |
| User | `--user` | UID/GID mappings |
| Cgroup | `--cgroup` | Cgroup root |

```bash
# Manual equivalent:
unshare --mount --uts --ipc --net --pid --fork --mount-proc /bin/bash
```

### Docker Internals

Docker uses the same mechanisms:
1. **Namespaces** for isolation
2. **Cgroups** for resource limits
3. **Union FS** (overlay2) for image layers
4. **Seccomp** for syscall filtering
5. **Capabilities** for granular privileges

---

## Example Output

### cgroup_monitor.py

```
$ sudo python3 cgroup_monitor.py --docker nginx
═══════════════════════════════════════════════════════════════════════════
CGROUP MONITOR v2 — Container: nginx (a1b2c3d4e5f6)
Path: /sys/fs/cgroup/system.slice/docker-a1b2c3d4e5f6.scope
═══════════════════════════════════════════════════════════════════════════

┌─────────────────────────────────────────────────────────────────────────┐
│ CPU                                                                     │
├─────────────────────────────────────────────────────────────────────────┤
│ Total:  45.2s  │  User: 38.1s (84%)  │  System: 7.1s (16%)             │
│ Usage:  2.3%   │  Throttled: 0 periods                                  │
└─────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────┐
│ MEMORY                                                                  │
├─────────────────────────────────────────────────────────────────────────┤
│ Current: 128.5 MB  │  Max: 512.0 MB  │  Usage: 25.1%                   │
│ Swap:    0 B       │  Swap Max: 0 B                                     │
│ Cache:   45.2 MB   │  RSS: 83.3 MB                                      │
└─────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────┐
│ PIDS                                                                    │
├─────────────────────────────────────────────────────────────────────────┤
│ Current: 12  │  Max: 100  │  Usage: 12%                                 │
└─────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────┐
│ I/O                                                                     │
├─────────────────────────────────────────────────────────────────────────┤
│ Read:  234.5 MB  │  Write: 12.3 MB  │  Device: 8:0 (sda)               │
└─────────────────────────────────────────────────────────────────────────┘

[Refresh: 1s] [Press Ctrl+C to exit]
```

### mini_container.sh

```
$ sudo ./mini_container.sh --memory 100M --net-isolate
═══════════════════════════════════════════════════════════════
MINI CONTAINER — Namespaces + Cgroups Demonstration
═══════════════════════════════════════════════════════════════

[1/4] Creating cgroup with limits...
      Memory limit: 100M
      CPU limit: unlimited
      
[2/4] Creating namespaces (mount, uts, ipc, net, pid)...

[3/4] Configuring isolated environment...
      Hostname: container-a1b2c3
      Root FS: /
      
[4/4] Executing shell in container...

═══════════════════════════════════════════════════════════════
You are now inside an isolated container!
  - Hostname: container-a1b2c3
  - PID namespace: PID 1 = this shell
  - Network: isolated (loopback only)
  - Memory limit: 100M
  
Useful commands:
  hostname          # Check isolated hostname
  ps aux            # See only processes from within the container
  ip addr           # See only container interfaces
  cat /proc/1/cgroup  # Check cgroup
  
Type 'exit' to leave.
═══════════════════════════════════════════════════════════════

root@container-a1b2c3:/# ps aux
USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root         1  0.0  0.0   4636  3712 pts/0    S    10:30   0:00 /bin/bash
root        15  0.0  0.0   7060  1536 pts/0    R+   10:30   0:00 ps aux

root@container-a1b2c3:/# ip addr
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
```

---

## System Requirements

### Hardware/Software

- Ubuntu 24.04 with kernel 5.15+ (for complete cgroups v2)
- Python 3.8+ with standard modules (`pathlib`, `dataclasses`)
- cgroups v2 enabled (unified hierarchy)
- Root privileges for `mini_container.sh` and Docker monitoring

### cgroups v2 Verification

```bash
# Verify the system uses cgroups v2
mount | grep cgroup2
# Expected output: cgroup2 on /sys/fs/cgroup type cgroup2 ...

# Check available controllers
cat /sys/fs/cgroup/cgroup.controllers
# Expected output: cpuset cpu io memory hugetlb pids rdma misc

# If you see /sys/fs/cgroup/cpu, /sys/fs/cgroup/memory separately → cgroups v1
# For WSL2: cgroups v2 is default from Windows 11
```

### Package Installation

```bash
# Required packages
sudo apt update
sudo apt install util-linux iproute2 procps

# For Docker monitoring
sudo apt install docker.io
sudo usermod -aG docker $USER  # Logout/login required
```

---

## Troubleshooting

| Problem | Cause | Solution |
|----------|-------|---------|
| "Cgroup does not exist" | Wrong path or container stopped | Check with `docker ps` and use correct ID |
| "Permission denied" | No root access | Run with `sudo` |
| "cgroups v1 detected" | Legacy system | Add `systemd.unified_cgroup_hierarchy=1` to kernel cmdline |
| "unshare: operation not permitted" | Restricted kernel | Check `sysctl kernel.unprivileged_userns_clone` |
| Memory not limited | Controller not activated | `echo "+memory" > /sys/fs/cgroup/cgroup.subtree_control` |
| Shared scripts missing | Wrong path | Verify existence of `../15supp-Conectarea_la_Retea/scripts/` |

---

## Proposed Exercises

1. **Observing limits**: Start `mini_container.sh --memory 50M` and run `stress --vm 1 --vm-bytes 100M`. What happens?

2. **PID isolation**: Inside the container, run `ps aux`. Why do you only see your own processes?

3. **Docker comparison**: Compare the output of `cgroup_monitor.py --docker <id>` with `docker stats <id>`.

4. **Network namespace**: Create two containers with `mini_container.sh --net-isolate`. Can they communicate with each other? Why?

5. **Network isolation tests**: Using the shared scripts from Lecture 15, test connectivity between host and container with `echo_server.py`/`echo_client.py`.

---

*Materials developed by Revolvix for ASE Bucharest - CSIE*  
*Operating Systems | Year I, Semester 2 | 2025-2026*
