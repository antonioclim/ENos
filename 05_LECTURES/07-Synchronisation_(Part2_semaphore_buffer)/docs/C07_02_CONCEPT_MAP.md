# Concept Map — Synchronisation P2

```
              ┌──────────────────┐
              │     SEMAPHORE    │
              │    (integer      │
              │    variable)     │
              └────────┬─────────┘
                       │
         ┌─────────────┼─────────────┐
         ▼             ▼             ▼
    ┌─────────┐   ┌─────────┐   ┌─────────┐
    │  wait() │   │ signal()│   │  Types  │
    │   P()   │   │   V()   │   │         │
    └────┬────┘   └────┬────┘   └────┬────┘
         │             │             │
    S--          S++          ┌──────┴──────┐
    if S<0       if S≤0       │  Binary     │
    block()      wakeup()     │  (mutex)    │
                              ├─────────────┤
                              │  Counting   │
                              │ (resources) │
                              └─────────────┘

PRODUCER-CONSUMER:
┌─────────────────────────────────────────────┐
│  Semaphores:                                │
│  • mutex = 1 (buffer access)                │
│  • empty = N (free slots)                   │
│  • full = 0 (occupied slots)                │
│                                             │
│  Producer:         Consumer:                │
│  wait(empty)       wait(full)               │
│  wait(mutex)       wait(mutex)              │
│  // add item       // remove item           │
│  signal(mutex)     signal(mutex)            │
│  signal(full)      signal(empty)            │
└─────────────────────────────────────────────┘
```
