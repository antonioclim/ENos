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

```

## UNIX permission positions

`-rwxr-xr-x` is a regular file with mode `0755`.

| Position(s) | Example | Meaning |
|---|---|---|
| 1 | `-` | File type: `-` regular, `d` directory, `l` symbolic link |
| 2–4 | `rwx` | Owner permissions |
| 5–7 | `r-x` | Group permissions |
| 8–10 | `r-x` | Other permissions |

The leading octal digit represents set-user-ID (4), set-group-ID (2) and sticky (1). In a sticky directory, deletion/renaming is restricted to the file owner, directory owner or a privileged process, subject to the other applicable checks.
