<!-- RO: TRADUS ȘI VERIFICAT -->
# Concept Map — Memory Management P1

```
              ┌───────────────────┐
              │ MEMORY MANAGEMENT │
              └─────────┬─────────┘
                        │
         ┌──────────────┼──────────────┐
         ▼              ▼              ▼
    ┌─────────┐   ┌──────────┐   ┌─────────┐
    │ Paging  │   │Segmentatn│   │  Hybrid │
    └────┬────┘   └────┬─────┘   └────┬────┘
         │             │              │
    ┌────┴────┐   ┌────┴─────┐   ┌────┴────┐
    │Fix size │   │Var size  │   │Segment  │
    │(4KB typ)│   │Logic unit│   │w/ pages │
    │No ext   │   │Ext frag  │   │         │
    │frag     │   │possible  │   │         │
    └─────────┘   └──────────┘   └─────────┘

ADDRESS TRANSLATION (Paging):
┌─────────────────────────────────────────────────┐
│  Logical Address = Page Number | Offset         │
│                                                 │
│  CPU ──► Page Table ──► Frame Number            │
│                                                 │
│  Physical Address = Frame Number | Offset       │
│                                                 │
│  Ex: 32-bit, 4KB pages (12 bit offset)          │
│  Page Number: 20 bits → 2^20 = 1M pages         │
└─────────────────────────────────────────────────┘
```
