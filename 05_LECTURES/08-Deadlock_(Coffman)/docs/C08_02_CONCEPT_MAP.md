# Concept Map — Deadlock

```
                 ┌──────────────┐
                 │   DEADLOCK   │
                 └──────┬───────┘
                        │
    ┌───────────────────┼───────────────────┐
    ▼                   ▼                   ▼
┌─────────┐      ┌─────────────┐      ┌─────────┐
│Coffman  │      │  Strategies │      │   RAG   │
│Conditions│      │             │      │ (Graph) │
└────┬────┘      └──────┬──────┘      └────┬────┘
     │                  │                  │
┌────┴────────┐    ┌────┴────┐        ┌────┴────┐
│1.Mutual Excl│    │Prevention│        │Processes│
│2.Hold & Wait│    │Avoidance │        │ ○       │
│3.No Preempt │    │Detection │        │Resources│
│4.Circular   │    │Recovery  │        │ □       │
│   Wait      │    └──────────┘        │Request →│
└─────────────┘                        │Assign ←─│
                                       └─────────┘

BANKER'S ALGORITHM:
┌─────────────────────────────────────────────────┐
│  Safe State: There exists a sequence in which   │
│  all processes can complete                     │
│                                                 │
│  Available = Total - Σ Allocation               │
│                                                 │
│  For each request:                              │
│  1. Assume allocation                           │
│  2. Check if state is safe                      │
│  3. Allocate only if it remains safe            │
└─────────────────────────────────────────────────┘
```
