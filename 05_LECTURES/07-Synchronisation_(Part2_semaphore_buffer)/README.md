# Operating Systems - Week 7: Synchronisation (Part 2)

> by Revolvix | ASE Bucharest - CSIE | Year I, Semester 2 | 2025-2026

---

## Weekly Objectives

After completing this week's materials, you will be able to:

1. Define semaphores and explain the difference between binary and counting types
2. Implement the producer-consumer solution using semaphores
3. Describe the concept of monitors and condition variables
4. Analyse classic synchronisation problems and their solutions

---

## Applied Context (didactic scenario): How does Netflix synchronise streaming with the buffer?

When you watch a film on Netflix, a producer (download thread) downloads frames and places them into a buffer. A **consumer** (playback thread) reads and displays them. If the producer is too slow → buffering. If the consumer is too slow → buffer overflow. How do they synchronise perfectly? The answer: **semaphores** and circular buffer.

> 💡 Think about it: What would happen if the buffer had only 1 element? What about 1000?

---

## Course Content (7/14)

### 1. Semaphores

#### Formal Definition

> A semaphore is a non-negative integer variable S that can only be accessed through two atomic operations: wait() (P, proberen = "to test" in Dutch) and signal() (V, verhogen = "to increment"). Introduced by Edsger Dijkstra in 1965.

```
wait(S):    // P(S)
    while S <= 0: block()
    S = S - 1

signal(S):  // V(S)
    S = S + 1
    wakeup_one_waiting_process()
```

Variant without busy-wait (with blocking):
```
typedef struct {
    int value;
    list<process> waiting_queue;
} semaphore;

wait(S):
    S.value--
    if S.value < 0:
        add_to_queue(S.waiting_queue, current_process)
        block()

signal(S):
    S.value++
    if S.value <= 0:
        P = remove_from_queue(S.waiting_queue)
        wakeup(P)
```

#### Intuitive Explanation

Metaphor: Locker Room Keys

Imagine a locker room with 5 lockers, each with its own key:
- The semaphore = the key box
- wait() = you take a key (if available); if not, you wait
- signal() = you return the key

| Semaphore S | Meaning |
|-------------|---------|
| S = 5 | 5 keys available |
| S = 0 | No keys, everyone waits |
| S < 0 | |S| processes waiting |

Binary semaphore (S ∈ {0, 1}): A single key → mutex!

Counting semaphore (S ≥ 0): Multiple identical resources (e.g. 5 DB connections).

#### Historical Context

| Year | Event | Significance |
|------|-------|--------------|
| 1965 | Dijkstra introduces semaphores | First formal synchronisation mechanism |
| 1968 | THE multiprogramming system | First practical implementation |
| 1972 | UNIX introduces semaphores | `semget()`, `semop()` |
| 1974 | Hoare introduces monitors | Higher level of abstraction |
| 2003 | POSIX semaphores | Standardisation: `sem_init()`, `sem_wait()` |

> 💡 Fun fact: Dijkstra initially used Dutch letters: P (proberen = "to test") and V (verhogen = "to increment"). The terms have remained in academic use!

#### Types of Semaphores

```
┌─────────────────────────────────────────────────────────────┐
│                    SEMAPHORES                               │
├──────────────────────────┬──────────────────────────────────┤
│    BINARY SEMAPHORE      │    COUNTING SEMAPHORE            │
│    (Mutex-like)          │    (Multiple resources)          │
├──────────────────────────┼──────────────────────────────────┤
│  S ∈ {0, 1}              │  S ∈ {0, 1, 2, ..., N}          │
│                          │                                  │
│  Usage:                  │  Usage:                          │
│  - Mutual exclusion      │  - Connection pool               │
│  - Simple lock           │  - Buffer with N slots           │
│                          │  - N printers                    │
├──────────────────────────┼──────────────────────────────────┤
│  Example:                │  Example:                        │
│  sem mutex = 1;          │  sem empty = N;  // empty slots  │
│  wait(mutex);            │  sem full = 0;   // full slots   │
│  // critical section     │  sem mutex = 1;  // buffer access│
│  signal(mutex);          │                                  │
└──────────────────────────┴──────────────────────────────────┘
```

#### Costs and Trade-offs

| Advantage | Disadvantage |
|-----------|--------------|
| Conceptually simple | Easy to get wrong (deadlock if you forget signal) |
| Can manage N resources | No language-level protection |
| Efficient (blocking) | Difficult debugging |
| Portable (POSIX) | Does not scale well on many cores |

---

### 2. The Producer-Consumer Problem (Bounded Buffer)

#### Formal Definition

> The Bounded Buffer problem consists of coordinating a producer that generates data and places it into a buffer of finite size N, and a **consumer** that extracts it. The producer must wait if the buffer is full; the consumer must wait if it is empty.

#### Intuitive Explanation

Metaphor: The Pizza Shop Production Line

- The chef (producer) makes pizza and places it on the counter
- The waiter (consumer) takes the pizza and delivers it to the customer
- The counter (buffer) has room for 5 pizzas (N=5)

Rules:
- The chef cannot place pizza 6 if there are already 5 on the counter → WAIT
- The waiter cannot take pizza if the counter is empty → WAIT
- Two chefs do not place simultaneously on the same spot → MUTEX

#### Solution with Semaphores

```
┌─────────────────────────────────────────────────────────────┐
│                    BOUNDED BUFFER                           │
│                                                             │
│   Producer                Buffer                Consumer    │
│   ┌──────┐     empty      ┌─┬─┬─┬─┬─┐     full   ┌──────┐  │
│   │ PROD ├───────────────►│ │ │ │ │ ├───────────►│ CONS │  │
│   └──────┘    (N slots)   └─┴─┴─┴─┴─┘  (items)   └──────┘  │
│                              mutex                          │
│                         (access control)                    │
└─────────────────────────────────────────────────────────────┘

Semaphores:
- empty = N   // how many empty slots (initially all)
- full = 0    // how many elements in buffer (initially zero)
- mutex = 1   // for exclusive access to buffer
```

Pseudocode:

```c
// Shared variables
semaphore empty = N;    // Free slots
semaphore full = 0;     // Elements in buffer
semaphore mutex = 1;    // Exclusive access

buffer_t buffer[N];
int in = 0, out = 0;    // Circular indices

// PRODUCER
void producer() {
    while (true) {
        item = produce_item();
        
        wait(empty);        // Wait for free slot
        wait(mutex);        // Enter CS
        
        buffer[in] = item;
        in = (in + 1) % N;
        
        signal(mutex);      // Exit CS
        signal(full);       // Announce new element
    }
}

// CONSUMER  
void consumer() {
    while (true) {
        wait(full);         // Wait for element
        wait(mutex);        // Enter CS
        
        item = buffer[out];
        out = (out + 1) % N;
        
        signal(mutex);      // Exit CS
        signal(empty);      // Announce free slot
        
        consume_item(item);
    }
}
```

**ATTENTION to the wait() order!**
```c
// WRONG - can cause deadlock!
wait(mutex);    // You have mutex
wait(empty);    // But buffer full → you block while holding mutex!

// CORRECT
wait(empty);    // First check slot
wait(mutex);    // Then take mutex
```

#### Comparative Implementation

| Aspect | Linux/POSIX | Windows | Python |
|--------|-------------|---------|--------|
| API | `sem_init()`, `sem_wait()`, `sem_post()` | `CreateSemaphore()`, `WaitForSingleObject()` | `threading.Semaphore()` |
| Counting | ✅ Native | ✅ Native | ✅ Native |
| Named | `sem_open("/name")` | `CreateSemaphore(name)` | N/A |
| Max value | `SEM_VALUE_MAX` | ~2^31 | Unlimited |

#### Python Implementation

```python
#!/usr/bin/env python3
"""
Producer-Consumer Problem with Semaphores

Demonstrates:
- Counting semaphores for coordination
- Circular buffer
- Producer-consumer synchronisation
"""

import threading
import time
import random
from queue import Queue  # For comparison

# Manual implementation with semaphores
class BoundedBuffer:
    """Circular buffer with semaphores."""
    
    def __init__(self, size: int):
        self.size = size
        self.buffer = [None] * size
        self.in_idx = 0
        self.out_idx = 0
        
        # Semaphores
        self.empty = threading.Semaphore(size)  # Free slots
        self.full = threading.Semaphore(0)       # Available elements
        self.mutex = threading.Lock()            # Exclusive access
    
    def put(self, item):
        """Producer places element."""
        self.empty.acquire()      # wait(empty)
        with self.mutex:          # wait(mutex) + signal(mutex)
            self.buffer[self.in_idx] = item
            self.in_idx = (self.in_idx + 1) % self.size
        self.full.release()       # signal(full)
    
    def get(self):
        """Consumer takes element."""
        self.full.acquire()       # wait(full)
        with self.mutex:
            item = self.buffer[self.out_idx]
            self.out_idx = (self.out_idx + 1) % self.size
        self.empty.release()      # signal(empty)
        return item

def producer(buffer: BoundedBuffer, producer_id: int, count: int):
    """Producer: generates count elements."""
    for i in range(count):
        item = f"P{producer_id}-Item{i}"
        print(f"[Producer {producer_id}] Producing: {item}")
        time.sleep(random.uniform(0.1, 0.3))  # Simulate production
        buffer.put(item)
        print(f"[Producer {producer_id}] Placed: {item}")

def consumer(buffer: BoundedBuffer, consumer_id: int, count: int):
    """Consumer: consumes count elements."""
    for _ in range(count):
        item = buffer.get()
        print(f"[Consumer {consumer_id}] Got: {item}")
        time.sleep(random.uniform(0.2, 0.4))  # Simulate consumption
        print(f"[Consumer {consumer_id}] Consumed: {item}")

def main():
    print("="*60)
    print("PRODUCER-CONSUMER PROBLEM")
    print("="*60)
    
    BUFFER_SIZE = 3
    ITEMS_PER_PRODUCER = 5
    
    buffer = BoundedBuffer(BUFFER_SIZE)
    
    # 2 producers, 2 consumers
    threads = [
        threading.Thread(target=producer, args=(buffer, 1, ITEMS_PER_PRODUCER)),
        threading.Thread(target=producer, args=(buffer, 2, ITEMS_PER_PRODUCER)),
        threading.Thread(target=consumer, args=(buffer, 1, ITEMS_PER_PRODUCER)),
        threading.Thread(target=consumer, args=(buffer, 2, ITEMS_PER_PRODUCER)),
    ]
    
    for t in threads:
        t.start()
    for t in threads:
        t.join()
    
    print("\n✅ All elements processed!")

if __name__ == "__main__":
    main()
```

---

### 3. Monitors and Condition Variables

#### Formal Definition

> A monitor is a high-level construct (at the programming language level) that encapsulates shared data and the procedures that access them, guaranteeing that only one thread can be active in the monitor at any given time. Introduced by C.A.R. Hoare in 1974.

> A condition variable is a mechanism through which a thread waits until a certain condition becomes true, temporarily releasing the monitor's lock.

```
condition x;

x.wait():   // Releases lock, adds thread to queue x, blocks
            // On wakeup: re-acquires lock

x.signal(): // Wakes ONE thread from queue x (if any exist)
            // Or does nothing if queue is empty
```

#### Intuitive Explanation

Metaphor: The Doctor's Waiting Room

- The monitor = The doctor's office (only one patient inside)
- The implicit lock = The office door
- The condition variable = The waiting chairs

Scenarios:
- You enter the office (acquire the monitor lock)
- "Wait for the test results" → the doctor sends you to the waiting room (condition.wait()) → another patient can enter the office
- "The results are in!" → the doctor calls you back (condition.signal()) → you re-enter the office

#### Difference: wait() on Condition Variable vs Semaphore

| Aspect | CV wait() | Semaphore wait() |
|--------|-----------|------------------|
| Lock | Releases lock on wait, re-acquires on wakeup | Does NOT affect lock |
| Memory | Does NOT memorise signals | Counts signals |
| Lost signal | If no one is waiting, signal is lost | Semaphore increments |

#### Mesa vs Hoare Semantics

| Semantics | On signal() | Usage |
|-----------|-------------|-------|
| Hoare | Signaller yields CPU immediately | Theoretically simpler |
| Mesa | Signaller continues, waiter put in ready | Practical (Java, POSIX) |

MESA requires while, not if!
```c
// WRONG with Mesa semantics
if (condition_false)
    cond.wait();
// Between wakeup and acquiring lock, condition may become false again!

// CORRECT
while (condition_false)
    cond.wait();
// Re-checks condition after wakeup
```

#### Python Implementation

```python
#!/usr/bin/env python3
"""
Monitors and Condition Variables in Python

Python's threading.Condition = Lock + Condition Variable
"""

import threading
import time

class BoundedBufferMonitor:
    """
    Bounded Buffer implemented as a Monitor.
    
    Condition variable encapsulates the lock!
    """
    
    def __init__(self, size: int):
        self.size = size
        self.buffer = []
        self.condition = threading.Condition()  # Lock + CV
    
    def put(self, item):
        with self.condition:  # Acquire lock automatically
            # WHILE, not IF! (Mesa semantics)
            while len(self.buffer) >= self.size:
                print(f"[PUT] Buffer full, waiting...")
                self.condition.wait()  # Releases lock, waits
            
            self.buffer.append(item)
            print(f"[PUT] Added: {item}, buffer size: {len(self.buffer)}")
            
            self.condition.notify_all()  # Wakes all waiters
        # Lock released automatically (with statement)
    
    def get(self):
        with self.condition:
            while len(self.buffer) == 0:
                print(f"[GET] Buffer empty, waiting...")
                self.condition.wait()
            
            item = self.buffer.pop(0)
            print(f"[GET] Removed: {item}, buffer size: {len(self.buffer)}")
            
            self.condition.notify_all()
            return item

# Comparison: notify() vs notify_all()
# notify() - wakes ONE thread (non-deterministic)
# notify_all() - wakes ALL (safer but more overhead)
```

---

### 4. The Readers-Writers Problem

#### Formal Definition

> Readers-Writers Problem: Multiple readers can access the resource simultaneously (they do not modify it), but a writer requires exclusive access (readers and writers cannot coexist).

```
Variants:
1. First Readers-Writers: Readers have priority (writers may starve)
2. Second: Writers have priority (readers may starve)
3. Fair: Arrival order matters
```

#### Solution with Semaphores

```c
// Shared variables
semaphore rw_mutex = 1;   // Exclusive access for writers
semaphore mutex = 1;       // Protects read_count
int read_count = 0;        // How many active readers

// READER
void reader() {
    wait(mutex);
    read_count++;
    if (read_count == 1)
        wait(rw_mutex);    // First reader blocks writers
    signal(mutex);
    
    // READ DATA
    
    wait(mutex);
    read_count--;
    if (read_count == 0)
        signal(rw_mutex);  // Last reader releases
    signal(mutex);
}

// WRITER
void writer() {
    wait(rw_mutex);
    // WRITE DATA
    signal(rw_mutex);
}
```

---

### 5. Brainstorm: Car Park with Barrier System

Situation: A car park has 50 spaces. There are barriers at entry and exit. Cars wait if the car park is full.

Questions:
1. What type of semaphore would you use?
2. How would you model entry and exit?
3. What happens if 100 cars arrive simultaneously?

Solution:
```python
parking_spaces = threading.Semaphore(50)

def enter_parking(car_id):
    print(f"Car {car_id} waiting...")
    parking_spaces.acquire()  # Blocks if 0 spaces
    print(f"Car {car_id} entered!")

def exit_parking(car_id):
    parking_spaces.release()
    print(f"Car {car_id} exited, spot freed!")
```

---

## Recommended Reading

### OSTEP
- Required: [Chapter 30 - Condition Variables](https://pages.cs.wisc.edu/~remzi/OSTEP/threads-cv.pdf)
- Required: [Chapter 31 - Semaphores](https://pages.cs.wisc.edu/~remzi/OSTEP/threads-sema.pdf)

### Original Papers
- Dijkstra, E.W. (1965) - "Cooperating Sequential Processes"
- Hoare, C.A.R. (1974) - "Monitors: An Operating System Structuring Concept"

---

## Modern Trends

| Evolution | Description |
|-----------|-------------|
| Lock-free algorithms | CAS-based, avoids blocking |
| Software Transactional Memory | Transactions like in databases |
| Async/await | The Python/JavaScript model for concurrency |
| Actor model | Erlang, Akka - messages instead of shared state |
| Channels | Go, Rust - communication as synchronisation |


---

## Self-Assessment

### Review Questions

1. **[REMEMBER]** Define the semaphore and its fundamental operations (wait/P and signal/V). What is the difference between a binary semaphore and a counting semaphore?
2. **[UNDERSTAND]** Explain the producer-consumer problem. How do semaphores solve the synchronisation issues in this situation?
3. **[ANALYSE]** Compare semaphores with mutexes. In what situations would you use a counting semaphore instead of a mutex?

### Mini-challenge (optional)

Implement the producer-consumer problem with a buffer of capacity 5 using semaphores in Python.

---


---


---

## Nuances and Special Cases

### What we did NOT cover (didactic limitations)

- **Condition variables spurious wakeups**: `pthread_cond_wait()` can return without a real signal.
- **Priority inversion**: Mars Pathfinder bug (1997) - low-priority thread holds lock needed by high-priority thread.
- **Readers-Writers problem variants**: Favour readers or writers? Different trade-offs.

### Common Mistakes to Avoid

1. **Wrong wait-mutex-signal order**: Producer-consumer with mutex before semaphore → deadlock.
2. **Signal vs Broadcast**: `signal()` wakes one thread; `broadcast()` wakes all. Choose correctly.
3. **Semaphores for mutual exclusion**: Use mutex when you only need mutual exclusion.

### Open Questions

- Are monitors in modern languages (Java synchronized, C# lock) expressive enough?
- How do semaphores behave on distributed systems (Redis, Zookeeper)?

## Looking Ahead

**Week 8: Deadlock (Coffman)** — What happens when synchronisation goes wrong? Processes can block each other in an impasse (deadlock). We will study the Coffman conditions, allocation graphs and the banker's algorithm for avoidance.

**Recommended preparation:**
- Think about deadlock scenarios (e.g. two cars at an intersection)
- Read OSTEP Chapter 32 (Common Concurrency Problems)

## Visual Summary

```
┌─────────────────────────────────────────────────────────────────┐
│                    WEEK 7: SYNCHRONISATION II — RECAP           │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  SEMAPHORE (Dijkstra, 1965)                                     │
│  ├── Integer variable S ≥ 0                                     │
│  ├── wait(S): if S>0 then S-- else BLOCK                        │
│  └── signal(S): S++ and WAKEUP if someone is waiting            │
│                                                                 │
│  SEMAPHORE TYPES                                                │
│  ├── Binary (mutex): S ∈ {0, 1}                                 │
│  └── Counting: S ∈ {0, 1, 2, ...N}                              │
│                                                                 │
│  PRODUCER-CONSUMER                                              │
│  ├── empty = N (free slots)                                     │
│  ├── full = 0 (available elements)                              │
│  └── mutex = 1 (exclusive buffer access)                        │
│                                                                 │
│  MONITOR (Hoare, 1974)                                          │
│  ├── High-level abstraction                                     │
│  └── Automatic mutual exclusion + condition variables           │
│                                                                 │
│  💡 TAKEAWAY: Semaphores solve both mutex and ordering          │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

*Materials developed by Revolvix for ASE Bucharest - CSIE*  
*Operating Systems | Year I, Semester 2 | 2025-2026*

## Scripting in Context (Bash + Python): Producer–Consumer and Worker Pools

### Included Files

- Python: `scripts/producer_consumer.py` — Producer–Consumer with finite buffer (blocking).
- Bash: `scripts/pipe_worker_pool.sh` — Worker pool in shell with `xargs -P` (controlled parallelism).

### Quick Run

```bash
./scripts/producer_consumer.py --producers 2 --consumers 3 --items 30 --buf 5
./scripts/pipe_worker_pool.sh -p 4 -n 20
```

### Connection to This Week's Concepts

- Producer–Consumer is a canonical model for finite buffers: exactly what happens in pipes, networking and logging.
- `xargs -P` offers controlled parallelism, conceptually similar to a pool of workers.

### Recommended Practice

- run the scripts first on a test directory (not on critical data);
- save the output to a file and attach it to your report/assignment if required;
- note the kernel version (`uname -r`) and Python version (`python3 --version`) when comparing results.

*Materials developed by Revolvix for ASE Bucharest - CSIE*  
*Operating Systems | Year I, Semester 2 | 2025-2026*
