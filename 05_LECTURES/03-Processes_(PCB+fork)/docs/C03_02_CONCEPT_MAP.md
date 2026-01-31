<!-- RO: TRADUS ȘI VERIFICAT -->
# C03_02_CONCEPT_MAP.md
# Concept Map — Processes

```
                    ┌─────────────┐
                    │   PROCESS   │
                    │ (program in │
                    │  execution) │
                    └──────┬──────┘
         ┌─────────────────┼─────────────────┐
         ▼                 ▼                 ▼
    ┌─────────┐      ┌─────────┐      ┌─────────┐
    │   PCB   │      │ Address │      │Resources│
    │         │      │  Space  │      │         │
    └────┬────┘      └────┬────┘      └────┬────┘
         │                │                │
    ┌────┴────┐      ┌────┴────┐      ┌────┴────┐
    │• PID    │      │• Code   │      │• Files  │
    │• State  │      │• Data   │      │• Sockets│
    │• Regs   │      │• Stack  │      │• Pipes  │
    │• Priority│     │• Heap   │      │• Signals│
    └─────────┘      └─────────┘      └─────────┘
```

## Process States
```
        ┌──────────────────────────────────────┐
        │                                      │
        ▼                                      │
    ┌───────┐    admitted    ┌───────┐        │
    │  NEW  │ ───────────► │ READY │◄───┐    │
    └───────┘               └───┬───┘    │    │
                                │        │    │
                    scheduler   │        │    │
                    dispatch    │        │ I/O│
                                ▼        │done│
                            ┌───────┐    │    │
                            │RUNNING│────┤    │
                            └───┬───┘    │    │
                                │        │    │
              ┌─────────────────┼────────┘    │
              │                 │              │
         I/O wait          exit│              │
              │                 ▼              │
              │           ┌──────────┐        │
              └─────────► │TERMINATED│        │
                          └──────────┘        │
              │                               │
              └───────► ┌─────────┐           │
                        │ WAITING │───────────┘
                        └─────────┘
```

## fork() + exec()
```
Parent Process (PID=100)
        │
        │ fork()
        ▼
    ┌───────────────────────────────┐
    │                               │
    ▼                               ▼
Parent (PID=100)            Child (PID=101)
return 101                  return 0
    │                               │
    │                               │ exec("ls")
    │                               ▼
    │                       New image (ls)
    │                               │
    │ wait()                        │
    │◄──────────────────────────────┘
    ▼                          exit()
Continues
```
