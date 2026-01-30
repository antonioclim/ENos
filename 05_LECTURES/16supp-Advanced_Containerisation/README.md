# Operating Systems - Supplementary Module: Advanced Containerisation

> **by Revolvix** | ASE Bucharest - CSIE | Year I, Semester 2 | 2025-2026  
> **Industry Relevance**: Mandatory competency for DevOps/SRE/Cloud Engineer roles

---

## Module Objectives

1. **Differentiate** at the architectural level between classical virtualisation and containerisation
2. **Explain** the kernel mechanisms that underpin container isolation
3. **Configure** namespaces and cgroups manually to understand how Docker works
4. **Build** a minimal container without Docker, using only system primitives
5. **Analyse** the components of the OCI runtime stack (containerd, runc)
6. **Evaluate** the security and performance trade-offs of containerisation

---

## Applied Context: Why Do Containers Dominate Modern Infrastructure?

Industry data confirms a profound transformation: over 90% of cloud-native organisations use containers in production and 96% of these use or are evaluating Kubernetes. The demand for specialists dramatically exceeds supply — 93% of hiring managers report difficulties finding candidates with adequate containerisation and orchestration skills.

This reality is not accidental. Containers solve fundamental problems in software delivery: they eliminate divergences between development and production environments ("works on my machine"), enable rapid horizontal scaling and standardise application packaging regardless of the language or framework used. For a computer science graduate, understanding the underlying mechanisms — not just using Docker commands — constitutes the differentiator between an operator and an engineer capable of diagnosing and optimising complex systems.

---

## Module Content (Supplementary)

### 1. The Anatomy of Isolation: VM vs Container

Virtualisation and containerisation pursue the same objective — workload isolation — but through fundamentally different mechanisms.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                       CLASSICAL VIRTUALISATION                               │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐                        │
│  │  Application A│ │  Application B│ │  Application C│                        │
│  ├──────────────┤ ├──────────────┤ ├──────────────┤                        │
│  │   Bins/Libs  │ │   Bins/Libs  │ │   Bins/Libs  │                        │
│  ├──────────────┤ ├──────────────┤ ├──────────────┤                        │
│  │   Guest OS   │ │   Guest OS   │ │   Guest OS   │    ← Separate kernel   │
│  │   (Ubuntu)   │ │   (CentOS)   │ │   (Debian)   │       for each one     │
│  └──────┬───────┘ └──────┬───────┘ └──────┬───────┘                        │
│         │                │                │                                 │
│         └────────────────┼────────────────┘                                 │
│                          │                                                  │
│  ┌───────────────────────┴────────────────────────────────────────────┐    │
│  │                        HYPERVISOR                                   │    │
│  │              (VMware ESXi / KVM / Hyper-V / Xen)                    │    │
│  │     Complete hardware emulation: virtual CPU, memory, NIC, disk    │    │
│  └───────────────────────┬────────────────────────────────────────────┘    │
│                          │                                                  │
│  ┌───────────────────────┴────────────────────────────────────────────┐    │
│  │                      HOST OS (or bare-metal)                        │    │
│  └───────────────────────┬────────────────────────────────────────────┘    │
│                          │                                                  │
│  ┌───────────────────────┴────────────────────────────────────────────┐    │
│  │                         PHYSICAL HARDWARE                           │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                                                             │
│  Overhead: ~1-2 GB RAM / VM, boot time: minutes                            │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│                          CONTAINERISATION                                    │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐                        │
│  │  Application A│ │  Application B│ │  Application C│                        │
│  ├──────────────┤ ├──────────────┤ ├──────────────┤                        │
│  │   Bins/Libs  │ │   Bins/Libs  │ │   Bins/Libs  │    ← Only differences  │
│  └──────┬───────┘ └──────┬───────┘ └──────┬───────┘       (overlay FS)     │
│         │                │                │                                 │
│         └────────────────┼────────────────┘                                 │
│                          │                                                  │
│  ┌───────────────────────┴────────────────────────────────────────────┐    │
│  │                    CONTAINER RUNTIME                                │    │
│  │                  (containerd / CRI-O / podman)                      │    │
│  │         Manages namespaces, cgroups, image layers                   │    │
│  └───────────────────────┬────────────────────────────────────────────┘    │
│                          │                                                  │
│  ┌───────────────────────┴────────────────────────────────────────────┐    │
│  │                      HOST OS (Linux Kernel)                         │    │
│  │   ┌─────────────┐  ┌─────────────┐  ┌─────────────┐                │    │
│  │   │ Namespaces  │  │   cgroups   │  │  seccomp    │                │    │
│  │   │ (isolation) │  │  (limits)   │  │(syscall flt)│                │    │
│  │   └─────────────┘  └─────────────┘  └─────────────┘                │    │
│  └───────────────────────┬────────────────────────────────────────────┘    │
│                          │                                                  │
│  ┌───────────────────────┴────────────────────────────────────────────┐    │
│  │                         PHYSICAL HARDWARE                           │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                                                             │
│  Overhead: ~MB RAM / container, boot time: milliseconds                    │
└─────────────────────────────────────────────────────────────────────────────┘
```

#### 1.1. Detailed Comparison

| Aspect | Virtual Machine | Container |
|--------|-----------------|-----------|
| **Isolation** | Complete (virtualised hardware) | Process (shared kernel) |
| **Kernel** | Separate for each VM | Shared with host |
| **Boot time** | 30s - minutes | Milliseconds |
| **Image size** | GB (includes complete OS) | MB (only application + deps) |
| **Memory overhead** | ~1-2 GB / VM | ~10-100 MB / container |
| **Density** | ~10-20 VMs / server | ~100-1000 containers / server |
| **Security** | Hardware isolation | Kernel isolation (weaker) |
| **Portability** | Tied to hypervisor | OCI universal standard |
| **Use cases** | Multi-tenancy, different OSes | Microservices, CI/CD |

---

### 2. Linux Namespaces — The Foundation of Isolation

Namespaces constitute the kernel mechanism through which containers obtain the illusion of their own system. Each type of namespace isolates a specific category of resources.

#### 2.1. The 8 Types of Namespaces

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         LINUX NAMESPACES                                     │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐         │
│  │   PID (pid)     │    │   NET (net)     │    │   MNT (mnt)     │         │
│  │                 │    │                 │    │                 │         │
│  │ Isolates process│    │ Isolates network│    │ Isolates mount  │         │
│  │ tree; PID 1     │    │ stack: interf., │    │ points; sees    │         │
│  │ in container is │    │ routes, iptables│    │ its own FS      │         │
│  │ the init process│    │ sockets         │    │ root            │         │
│  │                 │    │                 │    │                 │         │
│  │ Added: 2.6.24   │    │ Added: 2.6.29   │    │ Added: 2.4.19   │         │
│  └─────────────────┘    └─────────────────┘    └─────────────────┘         │
│                                                                             │
│  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐         │
│  │   UTS (uts)     │    │   IPC (ipc)     │    │  USER (user)    │         │
│  │                 │    │                 │    │                 │         │
│  │ Isolates hostname│   │ Isolates IPC:   │    │ UID/GID mapping;│         │
│  │ and domainname; │    │ semaphores,     │    │ root in cont.   │         │
│  │ each container  │    │ message queues, │    │ can be non-     │         │
│  │ has identity    │    │ shared memory   │    │ root on host    │         │
│  │                 │    │                 │    │                 │         │
│  │ Added: 2.6.19   │    │ Added: 2.6.19   │    │ Added: 3.8      │         │
│  └─────────────────┘    └─────────────────┘    └─────────────────┘         │
│                                                                             │
│  ┌─────────────────┐    ┌─────────────────┐                                │
│  │  CGROUP (cgroup)│    │   TIME (time)   │                                │
│  │                 │    │                 │                                │
│  │ Isolates cgroup │    │ Isolates system │                                │
│  │ hierarchy view; │    │ clock; container│                                │
│  │ own view; for   │    │ can have time   │                                │
│  │ nested          │    │ different from  │                                │
│  │ containers      │    │ host            │                                │
│  │ Added: 4.6      │    │ Added: 5.6      │                                │
│  └─────────────────┘    └─────────────────┘                                │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

#### 2.2. Practical Demonstration: Creating a Namespace Manually

```bash
# View namespaces of the current process
ls -la /proc/$$/ns/

# Example output:
# lrwxrwxrwx 1 root root 0 Jan 15 10:00 cgroup -> 'cgroup:[4026531835]'
# lrwxrwxrwx 1 root root 0 Jan 15 10:00 ipc -> 'ipc:[4026531839]'
# lrwxrwxrwx 1 root root 0 Jan 15 10:00 mnt -> 'mnt:[4026531840]'
# lrwxrwxrwx 1 root root 0 Jan 15 10:00 net -> 'net:[4026531992]'
# lrwxrwxrwx 1 root root 0 Jan 15 10:00 pid -> 'pid:[4026531836]'
# lrwxrwxrwx 1 root root 0 Jan 15 10:00 user -> 'user:[4026531837]'
# lrwxrwxrwx 1 root root 0 Jan 15 10:00 uts -> 'uts:[4026531838]'

# Create a process in a new PID namespace
sudo unshare --pid --fork --mount-proc bash

# In the new shell:
ps aux
# You will see only the bash process with PID 1!

# Verify namespace difference
echo "PID namespace in container: $(readlink /proc/$$/ns/pid)"
# Compare with the value on the host
```

#### 2.3. Creating a "Container" Manually

The following sequence demonstrates how to create an isolated environment using only system utilities, without Docker:

```bash
#!/bin/bash
# mini_container.sh - Minimal container using unshare

set -e

# The directory that will become the root filesystem for the container
ROOTFS="/tmp/mini_rootfs"

# Prepare minimal root filesystem (using debootstrap or alpine)
prepare_rootfs() {
    echo "[*] Preparing rootfs..."
    mkdir -p "$ROOTFS"/{bin,lib,lib64,proc,sys,dev,tmp,etc}
    
    # Copy essential binaries
    cp /bin/bash "$ROOTFS/bin/"
    cp /bin/ls "$ROOTFS/bin/"
    cp /bin/cat "$ROOTFS/bin/"
    cp /bin/ps "$ROOTFS/bin/"
    
    # Copy necessary libraries (ldd to find dependencies)
    for bin in bash ls cat ps; do
        ldd /bin/$bin 2>/dev/null | grep -o '/lib[^ ]*' | while read lib; do
            cp --parents "$lib" "$ROOTFS/" 2>/dev/null || true
        done
    done
    
    # Create minimal /etc/passwd
    echo "root:x:0:0:root:/root:/bin/bash" > "$ROOTFS/etc/passwd"
}

# Launch container
run_container() {
    echo "[*] Launching container..."
    
    # unshare creates new namespaces
    # --pid: new PID namespace
    # --mount: new mount namespace
    # --uts: UTS namespace (hostname)
    # --ipc: IPC namespace
    # --net: network namespace (disabled here for simplicity)
    # --fork: required for PID namespace
    # --mount-proc: mounts /proc in the new namespace
    
    unshare \
        --pid \
        --mount \
        --uts \
        --ipc \
        --fork \
        -- /bin/bash -c "
            # Set hostname
            hostname container-demo
            
            # Pivot root - change root filesystem
            mount --bind $ROOTFS $ROOTFS
            cd $ROOTFS
            mkdir -p old_root
            pivot_root . old_root
            
            # Mount special filesystems
            mount -t proc proc /proc
            mount -t sysfs sysfs /sys
            
            # Unmount old root
            umount -l /old_root
            rmdir /old_root
            
            # Launch shell
            exec /bin/bash
        "
}

# Cleanup
cleanup() {
    echo "[*] Cleaning up..."
    rm -rf "$ROOTFS"
}

# Main
case "${1:-run}" in
    prepare)
        prepare_rootfs
        ;;
    run)
        prepare_rootfs
        run_container
        cleanup
        ;;
    clean)
        cleanup
        ;;
    *)
        echo "Usage: $0 {prepare|run|clean}"
        ;;
esac
```

---

### 3. Control Groups (cgroups) — Resource Limiting

If namespaces provide *isolation* (what a process sees), cgroups provide *limits* (how much it can consume).

#### 3.1. cgroups v2 Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           CGROUPS v2 HIERARCHY                               │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│                              /sys/fs/cgroup (unified hierarchy)             │
│                                      │                                       │
│                    ┌─────────────────┼─────────────────┐                    │
│                    │                 │                 │                    │
│              ┌─────┴─────┐     ┌─────┴─────┐     ┌─────┴─────┐              │
│              │  system   │     │   user    │     │  docker   │              │
│              │ .slice    │     │ .slice    │     │  (if      │              │
│              │           │     │           │     │  exists)  │              │
│              └─────┬─────┘     └─────┬─────┘     └─────┬─────┘              │
│                    │                 │                 │                    │
│              ┌─────┴─────┐     ┌─────┴─────┐     ┌─────┴─────┐              │
│              │ssh.service│     │user-1000  │     │ container │              │
│              │           │     │ .slice    │     │   abc123  │              │
│              └───────────┘     └───────────┘     └───────────┘              │
│                                                                             │
├─────────────────────────────────────────────────────────────────────────────┤
│                           AVAILABLE CONTROLLERS                              │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐        │
│  │    cpu      │  │   memory    │  │     io      │  │    pids     │        │
│  │             │  │             │  │             │  │             │        │
│  │ cpu.weight  │  │ memory.max  │  │ io.max      │  │ pids.max    │        │
│  │ cpu.max     │  │ memory.high │  │ io.weight   │  │ pids.current│        │
│  │ (quota)     │  │ memory.low  │  │ io.latency  │  │             │        │
│  │             │  │ memory.swap │  │             │  │             │        │
│  └─────────────┘  └─────────────┘  └─────────────┘  └─────────────┘        │
│                                                                             │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐                         │
│  │   cpuset    │  │   rdma      │  │    hugetlb  │                         │
│  │             │  │             │  │             │                         │
│  │ cpuset.cpus │  │ rdma.max    │  │hugetlb.max  │                         │
│  │ cpuset.mems │  │ rdma.current│  │             │                         │
│  └─────────────┘  └─────────────┘  └─────────────┘                         │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

#### 3.2. Practical Operations with cgroups v2

```bash
# Check cgroups version
mount | grep cgroup
# cgroup2 on /sys/fs/cgroup type cgroup2 (rw,...)

# List available controllers
cat /sys/fs/cgroup/cgroup.controllers
# cpu io memory pids

# Create a new group
sudo mkdir /sys/fs/cgroup/demo_group

# Enable controllers for the group
echo "+cpu +memory +pids" | sudo tee /sys/fs/cgroup/demo_group/cgroup.subtree_control

# Set limits
# Memory limit: 100 MB
echo "104857600" | sudo tee /sys/fs/cgroup/demo_group/memory.max

# CPU limit: 50% of one core (50000 / 100000)
echo "50000 100000" | sudo tee /sys/fs/cgroup/demo_group/cpu.max

# Process count limit
echo "10" | sudo tee /sys/fs/cgroup/demo_group/pids.max

# Add a process to the group
echo $$ | sudo tee /sys/fs/cgroup/demo_group/cgroup.procs

# Check statistics
cat /sys/fs/cgroup/demo_group/memory.current
cat /sys/fs/cgroup/demo_group/cpu.stat
cat /sys/fs/cgroup/demo_group/pids.current

# Cleanup (move processes back and delete)
echo $$ | sudo tee /sys/fs/cgroup/cgroup.procs
sudo rmdir /sys/fs/cgroup/demo_group
```

#### 3.3. The Effect of Limits in Practice

```bash
# Demonstration: Process exceeding memory limit

# Create cgroup with 50 MB limit
sudo mkdir -p /sys/fs/cgroup/memory_test
echo "52428800" | sudo tee /sys/fs/cgroup/memory_test/memory.max

# Script that allocates memory progressively
cat << 'EOF' > /tmp/memory_hog.py
#!/usr/bin/env python3
import time

data = []
chunk_size = 10 * 1024 * 1024  # 10 MB per iteration

print("Progressive memory allocation...")
try:
    while True:
        data.append('X' * chunk_size)
        print(f"Allocated: {len(data) * 10} MB")
        time.sleep(1)
except MemoryError:
    print("MemoryError: cgroup limit reached!")
EOF

# Run in cgroup
echo $$ | sudo tee /sys/fs/cgroup/memory_test/cgroup.procs
python3 /tmp/memory_hog.py

# Observe that the process is terminated (OOM killed) when it reaches the limit
```

---

### 4. Union Filesystems and Container Images

Container images are built from layers, each representing an incremental modification. This model allows efficient sharing of common data.

#### 4.1. Layered Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        DOCKER IMAGE: python:3.11                             │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌──────────────────────────────────────────────────────────────────────┐  │
│  │ Layer 5 (R/W): Container layer                    [WRITEABLE]        │  │
│  │ Runtime modifications (temporary files, logs)                        │  │
│  └──────────────────────────────────────────────────────────────────────┘  │
│                                   │                                         │
│  ┌──────────────────────────────────────────────────────────────────────┐  │
│  │ Layer 4: pip install requests                     [READ-ONLY]        │  │
│  │ /usr/local/lib/python3.11/site-packages/requests/                    │  │
│  │ Size: ~2 MB                                                          │  │
│  └──────────────────────────────────────────────────────────────────────┘  │
│                                   │                                         │
│  ┌──────────────────────────────────────────────────────────────────────┐  │
│  │ Layer 3: Python 3.11 binaries                     [READ-ONLY]        │  │
│  │ /usr/local/bin/python3.11, /usr/local/lib/python3.11/                │  │
│  │ Size: ~50 MB                                                         │  │
│  └──────────────────────────────────────────────────────────────────────┘  │
│                                   │                                         │
│  ┌──────────────────────────────────────────────────────────────────────┐  │
│  │ Layer 2: Build dependencies (gcc, make)           [READ-ONLY]        │  │
│  │ Size: ~100 MB                                                        │  │
│  └──────────────────────────────────────────────────────────────────────┘  │
│                                   │                                         │
│  ┌──────────────────────────────────────────────────────────────────────┐  │
│  │ Layer 1: Debian base image                        [READ-ONLY]        │  │
│  │ /bin, /lib, /usr (minimal system)                                    │  │
│  │ Size: ~80 MB                                                         │  │
│  └──────────────────────────────────────────────────────────────────────┘  │
│                                                                             │
│  ════════════════════════════════════════════════════════════════════════  │
│                                                                             │
│  OVERLAY VIEW (what the container sees):                                   │
│  / ← transparent union of all layers                                       │
│  ├── bin/      (from Layer 1)                                              │
│  ├── lib/      (from Layer 1 + 2)                                          │
│  ├── usr/      (from Layer 1 + 2 + 3)                                      │
│  │   └── local/lib/python3.11/                                             │
│  │       └── site-packages/requests/  (from Layer 4)                       │
│  └── tmp/      (writes to Layer 5)                                         │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

#### 4.2. OverlayFS in Practice

```bash
# OverlayFS demonstration - the mechanism used by Docker

# Create directory structure
mkdir -p /tmp/overlay_demo/{lower,upper,work,merged}

# Populate lower layer (read-only)
echo "Original file from lower" > /tmp/overlay_demo/lower/original.txt
echo "File that will be modified" > /tmp/overlay_demo/lower/modifiable.txt

# Mount overlay
sudo mount -t overlay overlay \
    -o lowerdir=/tmp/overlay_demo/lower,upperdir=/tmp/overlay_demo/upper,workdir=/tmp/overlay_demo/work \
    /tmp/overlay_demo/merged

# In merged we see the contents from lower
ls /tmp/overlay_demo/merged/

# Writing to merged - appears in upper (Copy-on-Write)
echo "New content" > /tmp/overlay_demo/merged/new_file.txt
echo "Modified in upper" > /tmp/overlay_demo/merged/modifiable.txt

# Verification: lower unchanged, upper contains differences
cat /tmp/overlay_demo/lower/modifiable.txt     # "File that will be modified"
cat /tmp/overlay_demo/upper/modifiable.txt     # "Modified in upper"

# Deletion in overlay creates "whiteout" in upper
rm /tmp/overlay_demo/merged/original.txt
ls -la /tmp/overlay_demo/upper/
# You will see a special file (character device 0,0) for whiteout

# Unmount
sudo umount /tmp/overlay_demo/merged
```

---

### 5. The OCI Runtime Stack

The Open Container Initiative (OCI) standardises image formats and runtime behaviour. Docker, podman and Kubernetes use the same specification.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         CONTAINER RUNTIME STACK                              │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                      USER INTERFACE                                  │   │
│  │                                                                      │   │
│  │  ┌────────────┐   ┌────────────┐   ┌────────────┐                   │   │
│  │  │   docker   │   │   podman   │   │  nerdctl   │                   │   │
│  │  │    CLI     │   │    CLI     │   │    CLI     │                   │   │
│  │  └─────┬──────┘   └─────┬──────┘   └─────┬──────┘                   │   │
│  └────────┼────────────────┼────────────────┼──────────────────────────┘   │
│           │                │                │                               │
│           │                │                │                               │
│  ┌────────┼────────────────┼────────────────┼──────────────────────────┐   │
│  │        │       HIGH-LEVEL RUNTIME        │                          │   │
│  │        │                │                │                          │   │
│  │  ┌─────▼──────┐   ┌─────▼──────┐   ┌─────▼──────┐                   │   │
│  │  │  dockerd   │   │ (podman is │   │ containerd │                   │   │
│  │  │  (daemon)  │   │  daemonless│   │   (CRI)    │                   │   │
│  │  └─────┬──────┘   │  - direct) │   └─────┬──────┘                   │   │
│  │        │          └────────────┘         │                          │   │
│  │        │                                 │                          │   │
│  │  ┌─────▼─────────────────────────────────▼──────┐                   │   │
│  │  │                 containerd                    │                   │   │
│  │  │     (container lifecycle management)          │                   │   │
│  │  │  • Image pull/push                           │                   │   │
│  │  │  • Container create/start/stop               │                   │   │
│  │  │  • Snapshot management                       │                   │   │
│  │  └───────────────────────┬──────────────────────┘                   │   │
│  └──────────────────────────┼──────────────────────────────────────────┘   │
│                             │                                               │
│  ┌──────────────────────────┼──────────────────────────────────────────┐   │
│  │                     LOW-LEVEL RUNTIME (OCI)                          │   │
│  │                          │                                           │   │
│  │  ┌───────────────────────▼───────────────────────┐                   │   │
│  │  │                      runc                      │                   │   │
│  │  │        (OCI reference implementation)          │                   │   │
│  │  │  • Parses OCI runtime spec (config.json)      │                   │   │
│  │  │  • Creates namespaces, cgroups                │                   │   │
│  │  │  • Executes the container process             │                   │   │
│  │  │  • Terminates after launch (not a daemon)     │                   │   │
│  │  └───────────────────────┬───────────────────────┘                   │   │
│  │                          │                                           │   │
│  │  Alternatives: crun (faster), kata (VM-backed), gVisor (sandbox)    │   │
│  └──────────────────────────┼──────────────────────────────────────────┘   │
│                             │                                               │
│  ┌──────────────────────────▼──────────────────────────────────────────┐   │
│  │                       LINUX KERNEL                                    │   │
│  │                                                                       │   │
│  │   namespaces    cgroups    seccomp    capabilities    OverlayFS     │   │
│  └───────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

#### 5.1. Investigating Docker Structure

```bash
# Location of Docker images
sudo ls /var/lib/docker/

# Structure:
# ├── containers/     # Container metadata
# ├── image/          # Image metadata
# ├── overlay2/       # Filesystem layers
# ├── network/        # Network configurations
# └── volumes/        # Persistent volumes

# Inspect image layers
docker image inspect python:3.11-slim | jq '.[0].RootFS.Layers'

# See containerd in action
sudo ctr images list
sudo ctr containers list

# Inspect OCI config.json (runtime spec)
# For a running container:
docker inspect <container_id> | jq '.[0].HostConfig'
```

---

### 6. Security in Containerisation

Containers share the host kernel, which introduces specific security considerations.

#### 6.1. Attack Vectors and Mitigations

| Vector | Risk | Mitigation |
|--------|------|----------|
| Kernel exploits | Container escape | Updated kernel, gVisor/kata |
| Privileged containers | Full host access | Avoid `--privileged` |
| Root in container | Escalation | User namespaces, rootless |
| Malicious images | Supply chain attack | Image scanning, signing |
| Excessive capabilities | Privilege escalation | Drop capabilities |
| Dangerous syscalls | Kernel exploitation | Seccomp profiles |

#### 6.2. Best Practices

```bash
# Run as non-root
docker run --user 1000:1000 nginx

# Read-only filesystem
docker run --read-only nginx

# No additional capabilities
docker run --cap-drop=ALL nginx

# Restrictive seccomp profile
docker run --security-opt seccomp=/path/to/profile.json nginx

# Resource limits
docker run --memory=256m --cpus=0.5 nginx

# Network isolation
docker run --network=none alpine
```

---

## Lab/Seminar — Practical Exercises

### Exercise 1: Exploring Namespaces

```bash
# Run a container
docker run -d --name test nginx

# Identify the PID on the host
docker inspect test --format '{{.State.Pid}}'

# Compare namespaces
ls -la /proc/1/ns/          # init (PID 1 on host)
ls -la /proc/<pid>/ns/      # the nginx container

# Enter the container's namespaces
sudo nsenter --target <pid> --mount --uts --ipc --net --pid bash
# Now you are "in" the container but without Docker CLI
```

### Exercise 2: cgroups Limits via Docker

```bash
# Container with limits
docker run -d --name limited --memory=100m --cpus=0.5 stress --vm 1 --vm-bytes 200M

# Observe OOM kill
docker logs limited
docker inspect limited --format '{{.State.OOMKilled}}'

# Check the created cgroup
cat /sys/fs/cgroup/system.slice/docker-<container_id>.scope/memory.max
```

### Exercise 3: Building a Container from Scratch

Using the script from section 2.3, create and run a minimal container without Docker.

---

## Visual Recap

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        CONTAINERISATION — SYNTHESIS                          │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  NAMESPACE                  CGROUPS                 OVERLAY FS              │
│  ──────────                 ───────                 ──────────              │
│  What the process sees      How much it consumes    How the FS looks        │
│                                                                             │
│  • pid    → process tree    • cpu → CPU time        • RO Layers             │
│  • net    → network stack   • memory → RAM          • RW Layer (CoW)        │
│  • mnt    → mount points    • io → I/O bandwidth    • Whiteouts             │
│  • uts    → hostname        • pids → process count                          │
│  • ipc    → semaphores                                                      │
│  • user   → UID mapping                                                     │
│                                                                             │
│  RUNTIME STACK              SECURITY                                        │
│  ─────────────              ──────────                                      │
│  CLI (docker/podman)        • Capabilities drop                             │
│       ↓                     • Seccomp filtering                             │
│  containerd                 • User namespaces                               │
│       ↓                     • Read-only rootfs                              │
│  runc (OCI)                 • Resource limits                               │
│       ↓                                                                     │
│  Linux kernel                                                               │
│                                                                             │
├─────────────────────────────────────────────────────────────────────────────┤
│  Recommended reading:                                                       │
│  • "Container Security" - Liz Rice (O'Reilly)                              │
│  • Linux man pages: namespaces(7), cgroups(7), capabilities(7)             │
│  • OCI Runtime Spec: github.com/opencontainers/runtime-spec                │
│  • Docker documentation: docs.docker.com/get-started/overview/             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Included Scripts

| File | Language | Description |
|--------|--------|-----------|
| `scripts/mini_container.sh` | Bash | Minimal container without Docker |
| `scripts/namespace_demo.py` | Python | Programmatic namespace exploration |
| `scripts/cgroup_monitor.py` | Python | Real-time cgroups limit monitoring |
| `scripts/layer_inspector.sh` | Bash | Docker image layer inspection |


---

## Self-Assessment

### Verification Questions

1. **[REMEMBER]** What are Linux namespaces? List at least 5 types and what each isolates.
2. **[UNDERSTAND]** Explain how cgroups work. How do you limit the RAM available to a container?
3. **[ANALYSE]** Compare Docker with LXC/LXD. Which provides better isolation? Which is easier to use?

### Mini-Challenge (optional)

Create a Docker container with a memory limit of 100MB and verify with `docker stats` that the limit is respected.

---


---


---

## Recommended Reading

### Mandatory Resources

**Official Linux Documentation**
- [Kernel Docs - cgroups v2](https://www.kernel.org/doc/html/latest/admin-guide/cgroup-v2.html) — The authoritative reference for cgroups
- [Kernel Docs - namespaces](https://www.kernel.org/doc/html/latest/admin-guide/namespaces/index.html)

**Docker Documentation**
- [Docker Overview](https://docs.docker.com/get-started/overview/) — Docker Architecture
- [Storage Drivers](https://docs.docker.com/storage/storagedriver/) — How overlay2 works

### Recommended Resources

**Linux man pages**
```bash
man 7 namespaces    # All namespace types
man 7 cgroups       # Control groups overview
man 7 pid_namespaces
man 7 network_namespaces
man 2 unshare       # Syscall for creating namespaces
man 2 clone         # Syscall with CLONE_NEW* flags
```

**LWN.net - Namespaces Series**
- [Namespaces in operation, Part 1](https://lwn.net/Articles/531114/)
- Complete series of 7 articles about namespaces implementation

### Video Resources

- **Liz Rice - Containers From Scratch** (YouTube, ~30min)
  - Live demonstration of creating a container with Go using namespaces/cgroups
  
- **Jérôme Petazzoni - Cgroups, namespaces and beyond** (DockerCon)

### Projects for Study

- [Bocker](https://github.com/p8952/bocker) — Docker in 100 lines of Bash
- [containers-from-scratch](https://github.com/lizrice/containers-from-scratch) — Source code from Liz Rice's talk

### Standard Specifications

- [OCI Runtime Specification](https://github.com/opencontainers/runtime-spec) — The container standard
- [OCI Image Specification](https://github.com/opencontainers/image-spec) — Container image format


---

## Nuances and Special Cases

### What We Did NOT Cover (didactic limitations)

- **User namespaces**: UID mapping to run containers as non-root on host.
- **Rootless containers**: Podman, containers without root privileges.
- **gVisor and Kata Containers**: Stronger isolation through separate kernel (sandbox).

### Common Mistakes to Avoid

1. **Docker socket mounted in container**: Allows escape from container (root on host).
2. **Ignoring cgroup limits**: Without limits, a container can affect the entire host.
3. **Latest tag in production**: Use specific versions for reproducibility.

### Open Questions Remaining

- Will WebAssembly containers replace Linux containers for some workloads?
- How will the OCI standard evolve for hardware accelerators?

## Looking Ahead

**Optional Continuation: C17supp — eBPF and Kernel-Level Programming**

After understanding how containers work at the kernel level (namespaces, cgroups), the next step is advanced observability with eBPF. You will be able to monitor containers in production with minimal overhead.

**Recommended preparation:**
- Install `bpftrace` and `bcc-tools`
- Run `sudo bpftrace -l` to see available probes

## Visual Summary

```
┌─────────────────────────────────────────────────────────────────┐
│                    WEEK 16: CONTAINERS — RECAP                   │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  CONTAINER = OS-level isolation (not VM)                        │
│                                                                 │
│  NAMESPACES (isolation)                                         │
│  ├── PID: separate process tree                                 │
│  ├── NET: separate network stack                                │
│  ├── MNT: separate filesystem mounts                            │
│  ├── UTS: separate hostname                                     │
│  ├── IPC: separate inter-process communication                  │
│  └── USER: UID/GID mapping                                      │
│                                                                 │
│  CGROUPS (resource limiting)                                    │
│  ├── CPU: percentage or shares                                  │
│  ├── Memory: hard/soft limit                                    │
│  ├── I/O: disk bandwidth                                        │
│  └── PIDs: maximum process count                                │
│                                                                 │
│  DOCKER                                                         │
│  ├── Image: read-only template                                  │
│  ├── Container: running instance                                │
│  └── Dockerfile: image build recipe                             │
│                                                                 │
│  💡 TAKEAWAY: Containers = namespaces + cgroups + filesystem    │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

*Materials developed by Revolvix for ASE Bucharest - CSIE*  
*Operating Systems | Year I, Semester 2 | 2025-2026*

---
