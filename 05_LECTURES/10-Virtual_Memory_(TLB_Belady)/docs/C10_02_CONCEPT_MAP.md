# Concept Map — Virtual Memory

```
             ┌────────────────────┐
             │ VIRTUAL MEMORY     │
             └──────────┬─────────┘
                        │
    ┌───────────────────┼───────────────────┐
    ▼                   ▼                   ▼
┌─────────┐      ┌─────────────┐      ┌─────────┐
│   TLB   │      │ Page Fault  │      │Page Repl│
│ (cache) │      │  Handling   │      │Algorithms
└────┬────┘      └──────┬──────┘      └────┬────┘
     │                  │                  │
Hit: fast        1.Trap to OS        ┌────┴────┐
Miss: PT lookup  2.Find on disk      │• FIFO   │
                 3.Load to frame     │• LRU    │
                 4.Update PT         │• OPT    │
                 5.Restart instr     │• Clock  │
                                     └─────────┘

BELADY'S ANOMALY:
┌─────────────────────────────────────────────────┐
│  FIFO can have MORE page faults                 │
│  with MORE frames                               │
│                                                 │
│  References: 1,2,3,4,1,2,5,1,2,3,4,5            │
│  3 frames: 9 faults                             │
│  4 frames: 10 faults (!)                        │
│                                                 │
│  LRU does NOT have this anomaly (stack algorithm)│
└─────────────────────────────────────────────────┘
```
