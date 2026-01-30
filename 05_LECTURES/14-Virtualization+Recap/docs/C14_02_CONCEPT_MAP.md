# Concept Map — Virtualisation

```
              ┌──────────────────┐
              │  VIRTUALISATION  │
              └────────┬─────────┘
                       │
    ┌──────────────────┼──────────────────┐
    ▼                  ▼                  ▼
┌─────────┐     ┌─────────────┐     ┌─────────┐
│Hypervisor│    │  Techniques │     │Containers│
└────┬────┘     └──────┬──────┘     └────┬────┘
     │                 │                 │
┌────┴────┐     ┌──────┴──────┐     ┌────┴────┐
│Type 1   │     │Full virt    │     │Namespaces│
│(bare    │     │Para virt    │     │Cgroups  │
│ metal)  │     │HW assisted  │     │Shared   │
│Type 2   │     │(VT-x/AMD-V) │     │ kernel  │
│(hosted) │     └─────────────┘     └─────────┘
└─────────┘

VM vs CONTAINER:
┌──────────────────────────────────────────────┐
│         VM                 CONTAINER          │
│  ┌─────────────┐      ┌─────────────┐        │
│  │    App      │      │    App      │        │
│  ├─────────────┤      ├─────────────┤        │
│  │  Guest OS   │      │  Libs only  │        │
│  ├─────────────┤      └──────┬──────┘        │
│  │ Hypervisor  │             │               │
│  └──────┬──────┘      Shared │ kernel        │
│         │                    │               │
│  ┌──────┴──────┐      ┌──────┴──────┐        │
│  │   Host OS   │      │   Host OS   │        │
│  └─────────────┘      └─────────────┘        │
│                                              │
│  Isolation: Strong    Isolation: Medium      │
│  Overhead: High       Overhead: Low          │
└──────────────────────────────────────────────┘
```
