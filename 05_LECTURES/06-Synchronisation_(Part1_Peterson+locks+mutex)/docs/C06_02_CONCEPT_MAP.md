# Concept Map — Synchronisation P1

```
              ┌──────────────────────┐
              │   CRITICAL SECTION   │
              └──────────┬───────────┘
                         │
         requires        │        guarantees
    ┌────────────────────┼────────────────────┐
    ▼                    ▼                    ▼
┌─────────┐      ┌─────────────┐      ┌─────────┐
│ Mutual  │      │   Progress  │      │Bounded  │
│Exclusion│      │             │      │ Waiting │
└─────────┘      └─────────────┘      └─────────┘

SOLUTIONS:
┌─────────────────────────────────────────────────┐
│              SOFTWARE                           │
│  • Peterson's Algorithm (2 processes)           │
│  • Bakery Algorithm (N processes)               │
├─────────────────────────────────────────────────┤
│              HARDWARE                           │
│  • Test-and-Set (TAS)                          │
│  • Compare-and-Swap (CAS)                      │
│  • Load-Link/Store-Conditional                 │
├─────────────────────────────────────────────────┤
│              OS PRIMITIVES                      │
│  • Mutex (sleep/wake)                          │
│  • Spinlock (busy-wait)                        │
└─────────────────────────────────────────────────┘
```
