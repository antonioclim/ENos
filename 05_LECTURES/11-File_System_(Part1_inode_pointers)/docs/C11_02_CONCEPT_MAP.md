<!-- RO: TRADUS ȘI VERIFICAT -->
# Concept Map — Filesystem P1

```
              ┌──────────────────┐
              │      INODE       │
              │ (index node)     │
              └────────┬─────────┘
                       │
    ┌──────────────────┼──────────────────┐
    ▼                  ▼                  ▼
┌─────────┐     ┌─────────────┐     ┌─────────┐
│Metadata │     │  Pointers   │     │  Links  │
└────┬────┘     └──────┬──────┘     └────┬────┘
     │                 │                 │
┌────┴────┐     ┌──────┴──────┐     ┌────┴────┐
│• Size   │     │• 12 Direct  │     │Hard Link│
│• Perms  │     │• 1 Single   │     │ Same    │
│• Owner  │     │   Indirect  │     │ inode   │
│• Times  │     │• 1 Double   │     ├─────────┤
│• Links  │     │• 1 Triple   │     │Soft Link│
└─────────┘     └─────────────┘     │ Path    │
                                    │ string  │
                                    └─────────┘

INODE vs DIRECTORY:
┌──────────────────────────────────────────────┐
│  Directory = Special file                    │
│  Contains: (name, inode_number) pairs        │
│                                              │
│  "file.txt" │ 12345                         │
│  "data"     │ 12350                         │
│  "."        │ 12300  (self)                 │
│  ".."       │ 12200  (parent)               │
└──────────────────────────────────────────────┘
```
