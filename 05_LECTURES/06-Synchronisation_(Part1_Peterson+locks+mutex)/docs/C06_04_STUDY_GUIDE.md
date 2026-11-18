# Study Guide — Synchronisation P1

## The Critical Section Problem

### 3 Necessary Conditions
1. **Mutual Exclusion**: Max 1 process in CS
2. **Progress**: If no one in CS, decision made in finite time
3. **Bounded Waiting**: Limit on the number of "overtakes"

## Mechanisms

### Test-and-set using C11 atomics

```c
#include <stdatomic.h>
static atomic_flag lock = ATOMIC_FLAG_INIT;
void acquire(void) {
    while (atomic_flag_test_and_set_explicit(&lock, memory_order_acquire)) {
        /* busy wait; suitable only under stated scheduling assumptions */
    }
}
void release(void) {
    atomic_flag_clear_explicit(&lock, memory_order_release);
}
```

The read–modify–write is indivisible because it is an atomic operation. Ordinary `bool` loads and stores do not implement atomic test-and-set. Acquire/release orders accesses protected by this lock; all participants must follow the same protocol. This simple spinlock does not guarantee bounded waiting or fairness and wastes CPU while contended. Classical Peterson pseudocode assumes atomic shared reads/writes with sequential consistency; unsynchronised C accesses are not a valid implementation.

### Mutex vs Spinlock
| Mutex | Spinlock |
|-------|----------|
| Sleep when blocked | Busy-wait |
| Good for long waits | Good for short waits |
| Context switch overhead | CPU cycles overhead |

An uncontended futex-backed mutex can complete in userspace. A sleeping mutex, user-space spinlock and interrupt-safe kernel spinlock have different constraints; a single CPU alone does not imply an infinite spin.
