# Concept Map — OS Security

```
              ┌──────────────────┐
              │   SECURITY       │
              └────────┬─────────┘
                       │
    ┌──────────────────┼──────────────────┐
    ▼                  ▼                  ▼
┌─────────┐     ┌─────────────┐     ┌─────────┐
│  CIA    │     │  Access     │     │Protection│
│ Triad   │     │  Control    │     │Mechanisms│
└────┬────┘     └──────┬──────┘     └────┬────┘
     │                 │                 │
┌────┴────┐     ┌──────┴──────┐     ┌────┴────┐
│•Confid. │     │• DAC        │     │• ASLR   │
│•Integrity│    │  (perms)    │     │• DEP/NX │
│•Availab.│     │• MAC        │     │• Stack  │
└─────────┘     │  (SELinux)  │     │  Canary │
                │• RBAC       │     │• Sandbox│
                └─────────────┘     └─────────┘

UNIX PERMISSIONS:
┌──────────────────────────────────────────────┐
│  rwxr-xr-x = 755                             │
│  │││││││││                                   │
│  │││││││││                                   │
│  │││││││└┴─ others: r-x (read, execute)     │
│  ││││└┴┴─── group:  r-x (read, execute)     │
│  │└┴┴────── owner:  rwx (read, write, exec) │
│  └───────── file type (d=dir, -=file, l=link)│
│                                              │
│  Special bits: SUID (4), SGID (2), Sticky (1)│
└──────────────────────────────────────────────┘
```
