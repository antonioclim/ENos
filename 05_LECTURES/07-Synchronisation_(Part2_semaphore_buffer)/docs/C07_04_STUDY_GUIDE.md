<!-- RO: TRADUS ȘI VERIFICAT -->
# Study Guide — Synchronisation P2

## Semaphores

### Operations
- **wait(S)**: S--; if (S<0) block()
- **signal(S)**: S++; if (S≤0) wakeup()

### Producer-Consumer with Bounded Buffer
```
Initialisation: mutex=1, empty=N, full=0

Producer:              Consumer:
wait(empty)           wait(full)
wait(mutex)           wait(mutex)
buffer[in] = item     item = buffer[out]
in = (in+1) % N       out = (out+1) % N
signal(mutex)         signal(mutex)
signal(full)          signal(empty)
```

## Monitors
- High-level construct
- Implicit mutual exclusion
- Condition variables: wait(), signal(), broadcast()
