# Study Guide — Threads

## Key Concepts

### What do threads share?
- Code, data, heap
- File descriptors
- Signal handlers

### What do threads NOT share?
- Stack
- Registers
- Thread ID
- errno (thread-local)

### Threading Models
| Model | Description | Example |
|-------|-----------|---------|
| 1:1 | 1 user thread = 1 kernel thread | Linux, Windows |
| N:1 | N user threads = 1 kernel thread | Green threads |
| M:N | M user threads = N kernel threads | Go goroutines |

## POSIX Threads (pthreads)
```c
pthread_create(&tid, NULL, func, arg);
pthread_join(tid, &retval);
pthread_exit(retval);
```
