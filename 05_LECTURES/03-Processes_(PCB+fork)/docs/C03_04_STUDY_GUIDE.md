<!-- RO: TRADUS ȘI VERIFICAT -->
# C03_04_STUDY_GUIDE.md
# Study Guide — Processes

## Key Concepts

### Process vs Program
- **Program**: Executable file on disk (passive)
- **Process**: Program in execution + resources (active)

### PCB (Process Control Block)
- PID, PPID
- State (new, ready, running, waiting, terminated)
- Saved CPU registers
- Scheduling information
- Allocated resources

### System Calls for Processes
| Call | Description | Return |
|------|-------------|--------|
| fork() | Creates process copy | 0 in child, PID in parent |
| exec() | Replaces process image | Does not return on success |
| wait() | Waits for child | PID of terminated child |
| exit() | Terminates process | Does not return |

### Zombie and Orphan
- **Zombie**: Terminated process whose parent has not called wait()
- **Orphan**: Process whose parent has died → adopted by init

## Self-Assessment
1. What does fork() return in parent vs child?
2. What is a zombie process?
3. How many processes does `fork(); fork();` create?
