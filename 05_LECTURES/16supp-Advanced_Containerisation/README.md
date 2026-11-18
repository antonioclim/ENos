# Lecture 16supp — Advanced Containerisation

## Learning and demonstration materials

- [Course Plan](docs/C16_01_COURSE_PLAN.md)
- [Concept Map](docs/C16_02_CONCEPT_MAP.md)
- [Discussion Questions](docs/C16_03_DISCUSSION_QUESTIONS.md)
- [Study Guide](docs/C16_04_STUDY_GUIDE.md)
- [16ex1 - Namespaces Visualizer](docs/16ex1_-_Namespaces_Visualizer.html)
- [16ex2 - Cgroups Limiter](docs/16ex2_-_Cgroups_Limiter.html)
- [16ex3 - Overlay FS Layers](docs/16ex3_-_Overlay_FS_Layers.html)
- [Formative question bank](docs/C16_05_FORMATIVE_ASSESSMENT.yaml)

- [All lecture resources and launch instructions](docs/RUNhere.md)
- [Demonstration script guide](scripts/README.md)
- [Lecture quiz format and runner](../FORMATIVE_QUIZ_FORMAT.md)

## Demonstration script reference

The retained script guide below assumes the **`scripts/` working directory**. From this lecture directory, run `cd scripts` first. Native experiments and interactive HTML models provide different kinds of evidence.

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

The following scripts are used for testing network isolation and are shared with **Lecture 15 Supplementary: Connecting to the Network**. You can find them in the directory `../../15supp-Network_Connection/scripts/`:

| Script | Location | Purpose in containerisation context |
|--------|---------|-------------------------------|
| `echo_server.py` | `../../15supp-Network_Connection/scripts/` | TCP server for network isolation tests |
| `echo_client.py` | `../../15supp-Network_Connection/scripts/` | TCP client for connectivity tests |
| `network_diag.sh` | `../../15supp-Network_Connection/scripts/` | Network diagnostics from within container |
| `firewall_basic.sh` | `../../15supp-Network_Connection/scripts/` | iptables rules for containers |

> **Note**: These scripts are functionally identical. Sharing eliminates duplication and ensures consistency between lectures.

---

## Quick Usage

### cgroups v2 monitor

From `scripts/` (read-only access depends on the selected cgroup):

```bash
python3 cgroup_monitor.py --help
python3 cgroup_monitor.py /sys/fs/cgroup/user.slice/ --interval 2
python3 cgroup_monitor.py --docker CONTAINER_ID
```

Use an actual container ID; names and `--json` are not implemented. The monitor reads existing cgroups and does not create limits or move processes.

### Mini-container demonstration

```bash
bash mini_container.sh --help
# The following lifecycle is for an explicitly authorised, disposable root lab:
# sudo bash mini_container.sh prepare
# sudo bash mini_container.sh run
# sudo bash mini_container.sh clean
```

The implemented commands are `prepare`, `run`/`shell`, `advanced`, `info`, `clean` and `help`. The `run` path uses PID, mount, UTS and IPC namespaces with a prepared chroot. It does **not** add a network namespace, user mapping, cgroups, capabilities reduction or seccomp policy. `advanced` uses `pivot_root`. A plain mount namespace changes mount views; it does not create a new root filesystem by itself. This is an educational mechanism demonstration with host kernel sharing, not a complete security boundary.

### Network isolation exercise

The shared scripts are in `../../15supp-Network_Connection/scripts/` relative to this lecture's `scripts/` directory. The echo client accepts positional host and port:

```bash
python3 ../../15supp-Network_Connection/scripts/echo_client.py 127.0.0.1 8080
```

Run that connection command only against an authorised server. The supplied mini-container shares the host network, so it cannot demonstrate network isolation. A separate owned lab must explicitly create/configure a network namespace, bring up loopback and provide the needed binaries before comparing host and container reachability. Neither the old `--net-isolate` nor `--memory`/`--cpu` options exist in this script.

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

### mini_container.sh — historical schematic (not output of the current script)

The following retained narrative illustrates a fuller runtime. Its flags and cgroup/network features are not implemented by `mini_container.sh`; use the command reference above.

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
- Root privileges for the mutating mini-container lifecycle; monitoring needs read permission on the selected cgroup, not inherently root

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
| "Permission denied" | Missing read access or cgroup delegation | Identify the required access; use an authorised delegated lab rather than assuming root solves the configuration |
| "cgroups v1 detected" | Legacy system | Add `systemd.unified_cgroup_hierarchy=1` to kernel cmdline |
| "unshare: operation not permitted" | Restricted kernel | Check `sysctl kernel.unprivileged_userns_clone` |
| Memory not limited | Controller not activated | `echo "+memory" > /sys/fs/cgroup/cgroup.subtree_control` |
| Shared scripts missing | Wrong path | Verify existence of `../../15supp-Network_Connection/scripts/` |

---

## Proposed Exercises

1. **Observing limits**: In a separately authorised cgroup lab, establish delegation, enable the memory controller and attach the owned workload before observing a limit. The mini-container script does not configure memory limits.

2. **PID isolation**: Inside the container, run `ps aux`. Why do you only see your own processes?

3. **Docker comparison**: Compare the output of `cgroup_monitor.py --docker <id>` with `docker stats <id>`.

4. **Network namespace**: Compare the shared network of this script with a separately configured network namespace in an owned lab. State which interfaces and routes are available.

5. **Network isolation tests**: Using the shared scripts from Lecture 15, test connectivity between host and container with `echo_server.py`/`echo_client.py`.

---

*Materials developed by Revolvix for ASE Bucharest - CSIE*  
*Operating Systems | Year I, Semester 2 | 2025-2026*
