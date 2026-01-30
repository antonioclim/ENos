# Concept Map — Filesystem P2

```
             ┌─────────────────────┐
             │  SPACE ALLOCATION   │
             └──────────┬──────────┘
                        │
    ┌───────────────────┼───────────────────┐
    ▼                   ▼                   ▼
┌─────────┐      ┌─────────────┐      ┌─────────┐
│Contiguous│     │   Linked    │      │ Indexed │
└────┬────┘      └──────┬──────┘      └────┬────┘
     │                  │                  │
Pro: Fast        Pro: No ext       Pro: Both
     sequential        frag              benefits
Con: Ext frag    Con: Random      Con: Index
     Compaction        access slow       overhead

JOURNALING:
┌─────────────────────────────────────────────────┐
│  1. Write operation to journal (log)            │
│  2. Apply operation to filesystem               │
│  3. Mark journal entry as complete              │
│                                                 │
│  Crash recovery:                                │
│  - Replay incomplete journal entries            │
│  - Or rollback                                  │
│                                                 │
│  Types: Metadata-only, Full data journaling     │
└─────────────────────────────────────────────────┘
```
