# Concept Map — Containerisation

```
              ┌──────────────────┐
              │    CONTAINER     │
              │  = namespaces +  │
              │     cgroups      │
              └────────┬─────────┘
                       │
    ┌──────────────────┼──────────────────┐
    ▼                  ▼                  ▼
┌─────────┐     ┌─────────────┐     ┌─────────┐
│Namespaces│    │   Cgroups   │     │ Overlay │
│(isolation)│   │  (limits)   │     │   FS    │
└────┬────┘     └──────┬──────┘     └────┬────┘
     │                 │                 │
┌────┴────┐     ┌──────┴──────┐     ┌────┴────┐
│• PID    │     │• cpu        │     │Layers:  │
│• Network│     │• memory     │     │ Base    │
│• Mount  │     │• io         │     │ App     │
│• User   │     │• pids       │     │ Config  │
│• UTS    │     └─────────────┘     │ (R/W)   │
│• IPC    │                         └─────────┘
└─────────┘

DOCKER ARCHITECTURE:
┌─────────────────────────────────────────────────┐
│  docker CLI → dockerd → containerd → runc       │
│                                                 │
│  containerd: container lifecycle management     │
│  runc: OCI-compliant container runtime          │
│        (creates namespaces, cgroups, exec)      │
└─────────────────────────────────────────────────┘
```
