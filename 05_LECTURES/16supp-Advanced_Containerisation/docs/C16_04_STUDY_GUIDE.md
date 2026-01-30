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
| Cgroup | Cgroup root |

## Cgroups v2
```bash
# Memory limit
echo 512M > /sys/fs/cgroup/mygroup/memory.max

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
