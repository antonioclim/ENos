# Study Guide — Virtualisation

## Hypervisor Types
| Type 1 (Bare-metal) | Type 2 (Hosted) |
|---------------------|-----------------|
| Directly on hardware | On a host OS |
| VMware ESXi, Xen | VirtualBox, VMware WS |
| Better performance | Easier to install |

## Virtualisation Techniques
- **Full**: Guest does not know it is virtualised
- **Para**: Modified guest for efficiency
- **HW-assisted**: VT-x/AMD-V, ring -1 for hypervisor

## Containers vs VM
| Aspect | Container | VM |
|--------|-----------|-----|
| Kernel | Shared | Separate |
| Overhead | ~MB | ~GB |
| Boot time | ms | minutes |
| Isolation | Process-level | Hardware-level |

## Container Mechanisms (Linux)
- **Namespaces**: PID, Network, Mount, User, IPC, UTS
- **Cgroups**: CPU, Memory, I/O limits
