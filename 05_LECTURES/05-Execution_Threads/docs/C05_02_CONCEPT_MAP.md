# Concept Map — Threads

```
                    ┌─────────────────┐
                    │     THREAD      │
                    │ (lightweight    │
                    │   process)      │
                    └────────┬────────┘
         ┌──────────────────┬┴─────────────────┐
         ▼                  ▼                  ▼
    ┌─────────┐       ┌─────────┐       ┌─────────┐
    │  Own    │       │ Shared  │       │ Models  │
    └────┬────┘       └────┬────┘       └────┬────┘
         │                 │                 │
    ┌────┴────┐       ┌────┴────┐       ┌────┴────┐
    │• Stack  │       │• Code   │       │• 1:1    │
    │• Regs   │       │• Data   │       │• N:1    │
    │• TID    │       │• Heap   │       │• M:N    │
    │• PC     │       │• Files  │       └─────────┘
    └─────────┘       └─────────┘

PROCESS vs THREAD:
┌────────────────┬────────────────┐
│    PROCESS     │     THREAD     │
├────────────────┼────────────────┤
│ Own address    │ Own stack      │
│    space       │ but shares     │
│                │ the rest       │
├────────────────┼────────────────┤
│ Slow creation  │ Fast creation  │
├────────────────┼────────────────┤
│ Expensive      │ Fast switch    │
│    switch      │                │
├────────────────┼────────────────┤
│ IPC            │ Communication  │
│ communication  │ via memory     │
└────────────────┴────────────────┘
```
