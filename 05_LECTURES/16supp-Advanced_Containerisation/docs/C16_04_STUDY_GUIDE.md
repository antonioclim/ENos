<!-- RO: TRADUS ȘI VERIFICAT -->
# Study Guide — Containerisation

## Linux Namespaces
| Namespace | Isolates |
|-----------|----------|
| PID | Process IDs |
| Network | Network stack |
| Mount | Filesystem mounts |
| User | UID/GID |
| UTS | Hostname |
| IPC | IPC resources |
| Cgroup | View of cgroup membership paths |
| Time | Supported monotonic/boottime clock offsets |

## Cgroups v2

These commands assume an existing **owned delegated** `mygroup` with the CPU and memory controllers enabled by its parent, writable control files and the intended process already attached through `cgroup.procs`. Creating a directory or writing a limit alone does not attach a workload. The example is configuration syntax for an authorised lab, not an instruction to alter a shared host.

```bash
# Memory limit
echo 536870912 > /sys/fs/cgroup/mygroup/memory.max

# CPU limit (50% of 1 core)
echo "50000 100000" > /sys/fs/cgroup/mygroup/cpu.max

# View usage
cat /sys/fs/cgroup/mygroup/memory.current
```

## Minimal Container
```bash
# Create new namespaces
unshare --mount --uts --ipc --net --pid --fork /bin/bash
```

The `unshare` command changes namespace views but keeps the current root filesystem and privileged user unless separately configured. It is not a complete sandbox. CPU limits are ceilings, not guaranteed CPU reservations. [Kernel cgroup v2 reference](https://docs.kernel.org/admin-guide/cgroup-v2.html).
