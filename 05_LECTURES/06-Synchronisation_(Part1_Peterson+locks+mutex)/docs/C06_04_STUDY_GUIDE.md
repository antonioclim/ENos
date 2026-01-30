# Study Guide — Synchronisation P1

## The Critical Section Problem

### 3 Necessary Conditions
1. **Mutual Exclusion**: Max 1 process in CS
2. **Progress**: If no one in CS, decision made in finite time
3. **Bounded Waiting**: Limit on the number of "overtakes"

## Mechanisms

### Test-and-Set (Atomic)
```c
bool TAS(bool *target) {
    bool old = *target;
    *target = true;
    return old;  // all atomic!
}
```

### Mutex vs Spinlock
| Mutex | Spinlock |
|-------|----------|
| Sleep when blocked | Busy-wait |
| Good for long waits | Good for short waits |
| Context switch overhead | CPU cycles overhead |
