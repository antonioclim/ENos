# Operating Systems - Week 8: Deadlock

> by Revolvix | ASE Bucharest - CSIE | Year I, Semester 2 | 2025-2026

---

## Weekly Objectives

After completing the materials for this week, you will be able to:

1. Define deadlock and enumerate the 4 Coffman conditions
2. Construct and analyse resource allocation graphs
3. Compare management strategies: prevention, avoidance, detection
4. Apply the Banker's Algorithm for deadlock avoidance
5. Solve the Dining Philosophers problem with different approaches

---

## Applied Context (didactic scenario): Why does traffic get blocked at an intersection?

Imagine an intersection without traffic lights: 4 cars arrive simultaneously from all 4 directions. Each one waits for the car on the right to pass. Nobody moves. Nobody can move. This is a deadlock - a situation where each participant waits for a resource held by another, forming an infinite waiting cycle.

> 💡 Think about it: How would a traffic light solve the problem? What about a traffic officer? These are different solutions to the same deadlock.

---

## Course Content (8/14)

### 1. What is Deadlock?

#### Formal Definition

> Deadlock (impasse/interlocking) is a situation in which a set of processes are permanently blocked, each waiting for a resource held by another process in the set, forming a cycle of dependencies. No process in the set can make progress. (Coffman et al., 1971)

Formally, let R = {R₁, R₂, ..., Rₘ} be the set of resources and P = {P₁, P₂, ..., Pₙ} the set of processes:

```
Deadlock ⟺ ∃ cycle in wait-for graph:
P₁ → R₁ → P₂ → R₂ → ... → Pₙ → Rₙ → P₁
```

#### Intuitive Explanation

Metaphor: The shared bicycle stand

- 4 friends want to ride bicycles
- Each bicycle needs 2 wheels
- There are 4 wheels in total
- Each friend grabs one wheel and refuses to release it before getting the second one

Result: Nobody has 2 wheels. Nobody leaves. Everyone waits forever!

Process illustration:
```
P1 holds R1, wants R2
P2 holds R2, wants R3
P3 holds R3, wants R4
P4 holds R4, wants R1
→ CYCLE → DEADLOCK!
```

#### Historical Context

| Year | Event | Significance |
|----|-----------|--------------|
| 1965 | Dijkstra identifies the problem in THE System | First formal description |
| 1971 | Coffman, Elphick, Shoshani | The 4 necessary conditions |
| 1971 | Havender | Prevention strategies |
| 1977 | Holt | Detection algorithm |
| 1983 | Dijkstra | Philosophers problem (simplified) |

> 💡 Fun fact: The "Dining Philosophers" problem was invented by Dijkstra in 1965 as an exercise for students, but it has become one of the most studied problems in concurrency!

---

### 2. Coffman Conditions (Necessary for Deadlock)

#### Formal Definition

> Deadlock can occur if and only if all 4 following conditions are met simultaneously:

| # | Condition | Formal Definition | Metaphor |
|---|----------|-------------------|----------|
| 1 | Mutual Exclusion | Resource can be held by at most one process | One key, one lock |
| 2 | Hold and Wait | Process holds resources and waits for others | You hold a wheel and want another |
| 3 | No Preemption | Resource cannot be forcibly taken | You cannot snatch the wheel from someone's hand |
| 4 | Circular Wait | A waiting cycle exists | Everyone waits in a circle |

#### Intuitive Explanation for each

1. Mutual Exclusion - "Only one person can use the toilet"
- The resource CANNOT be shared simultaneously
- If it could (e.g., read-only memory), there would be no problem

2. Hold and Wait - "You hold the fork and wait for the knife"
- You already have something, but you want something else too
- If you had to take everything at once or nothing, there would be no problem

3. No Preemption - "You cannot forcibly take food from someone else's plate"
- Nobody can take your resource until you release it
- If they could, someone would unblock the situation

4. Circular Wait - "Everyone waits in a circle, nobody yields"
- A waits for B, B waits for C, C waits for A
- If there were no cycle, the chain would end somewhere

---

### 3. Resource Allocation Graph (RAG)

#### Formal Definition

> Resource Allocation Graph (RAG) is a directed graph G = (V, E) where:
> - V = P ∪ R (nodes: processes and resources)
> - E = Request edges (P → R) ∪ Assignment edges (R → P)

```
Notations:
○ P1, P2, ... = Processes (circles)
□ R1, R2, ... = Resources (rectangles)
   ● = resource instance
   
P → R = "P requests R" (request edge)
R → P = "R is allocated to P" (assignment edge)
```

#### Example

```
        ┌───┐         ┌───┐
        │ ○ │ P1      │ ○ │ P2
        └─┬─┘         └─┬─┘
          │             │
          │ request     │ holds
          ▼             │
        ┌─────┐         │
        │ ●   │ R1      │
        └──┬──┘         │
           │            │
           │ holds      │
           ▼            ▼
        ┌───┐         ┌─────┐
        │ ○ │ P3 ───► │ ●   │ R2
        └───┘ request └─────┘

Interpretation:
- P1 requests R1
- R1 is allocated to P3
- P3 requests R2
- R2 is allocated to P2
- NO cycle exists → NOT a deadlock (yet)
```

#### Cycle Rule

| Situation | Deadlock? |
|----------|-----------|
| No cycle | ❌ Impossible |
| Cycle + 1 instance per resource | ✅ Definite deadlock |
| Cycle + multiple instances | ⚠️ Possible (but not certain) |

---

### 4. Management Strategies

#### Comparison

| Strategy | Method | Cost | Usage |
|-----------|--------|------|-----------|
| Prevention | Eliminate a Coffman condition | High (restrictions) | Design-time |
| Avoidance | Do not enter unsafe state | Medium (algorithm) | Run-time |
| Detection + Recovery | Let it happen, then resolve | Low + detection overhead | Tolerant systems |
| Ignorance | "Ostrich algorithm" | Zero | UNIX, Windows (partially) |

---

### 5. Banker's Algorithm (Deadlock Avoidance)

#### Formal Definition

> Banker's Algorithm (Dijkstra, 1965) is a deadlock avoidance algorithm that decides whether a resource request can be satisfied without putting the system into an unsafe state. It works like a prudent banker who does not grant risky loans.

Safe state: There exists a sequence of processes such that all can complete.
Unsafe state: Deadlock NOT guaranteed, but possible.

#### Intuitive Explanation

Metaphor: The prudent banker

You are a banker with €10,000 cash. You have 3 clients with approved loans:
- Client A: Can request up to €8,000, already has €2,000
- Client B: Can request up to €5,000, already has €2,000  
- Client C: Can request up to €4,000, already has €3,000

Total in circulation: €7,000, Available cash: €3,000

Question: If B requests another €1,000, do you grant it?

Banker's Answer: 
1. After the loan: cash = €2,000
2. Who can finish with €2,000?
   - C needs max €1,000 (4,000 - 3,000) → ✅ can finish
   - C returns €4,000 → cash = €6,000
   - A needs max €6,000 → ✅ can finish
   - B can finish with what it received
3. Safe sequence exists: C, A, B → APPROVED!

#### Data Structures

```
n = number of processes
m = number of resource types

Available[m]        // Available resources per type
Max[n][m]           // Maximum demand per process
Allocation[n][m]    // Currently allocated resources
Need[n][m]          // Need = Max - Allocation
```

#### Safety Check Algorithm

```python
def is_safe_state(available, max_matrix, allocation):
    """
    Checks whether the current state is safe.
    
    Returns: (bool, safe_sequence) or (False, None)
    """
    n = len(allocation)      # Number of processes
    m = len(available)       # Number of resource types
    
    # Need[i] = Max[i] - Allocation[i]
    need = [[max_matrix[i][j] - allocation[i][j] 
             for j in range(m)] for i in range(n)]
    
    work = available.copy()  # Available resources
    finish = [False] * n     # Who has finished
    safe_sequence = []
    
    # Try to find a safe sequence
    while True:
        # Find a process that can finish
        found = False
        for i in range(n):
            if not finish[i]:
                # Check if Need[i] <= Work
                if all(need[i][j] <= work[j] for j in range(m)):
                    # Process i can finish
                    # Release resources
                    for j in range(m):
                        work[j] += allocation[i][j]
                    finish[i] = True
                    safe_sequence.append(f"P{i}")
                    found = True
                    break
        
        if not found:
            break
    
    if all(finish):
        return True, safe_sequence
    else:
        return False, None

def request_resources(process_id, request, available, max_m, allocation):
    """
    Process process_id requests resources.
    
    Returns: True if request is approved, False otherwise.
    """
    n = len(allocation)
    m = len(available)
    
    need = [[max_m[i][j] - allocation[i][j] 
             for j in range(m)] for i in range(n)]
    
    # 1. Check Request <= Need
    for j in range(m):
        if request[j] > need[process_id][j]:
            raise ValueError("Request exceeds declared need!")
    
    # 2. Check Request <= Available
    for j in range(m):
        if request[j] > available[j]:
            return False  # Not enough resources
    
    # 3. Pretend to allocate and check safety
    new_available = [available[j] - request[j] for j in range(m)]
    new_allocation = [row.copy() for row in allocation]
    for j in range(m):
        new_allocation[process_id][j] += request[j]
    
    safe, sequence = is_safe_state(new_available, max_m, new_allocation)
    
    if safe:
        print(f"✅ Request approved. Safe sequence: {sequence}")
        return True
    else:
        print("❌ Request denied - would lead to unsafe state!")
        return False

# Example
if __name__ == "__main__":
    # 5 processes, 3 resource types (A, B, C)
    available = [3, 3, 2]
    
    max_matrix = [
        [7, 5, 3],  # P0
        [3, 2, 2],  # P1
        [9, 0, 2],  # P2
        [2, 2, 2],  # P3
        [4, 3, 3],  # P4
    ]
    
    allocation = [
        [0, 1, 0],  # P0
        [2, 0, 0],  # P1
        [3, 0, 2],  # P2
        [2, 1, 1],  # P3
        [0, 0, 2],  # P4
    ]
    
    safe, seq = is_safe_state(available, max_matrix, allocation)
    print(f"Initial state safe: {safe}")
    print(f"Sequence: {seq}")
    
    print("\nP1 requests [1, 0, 2]:")
    request_resources(1, [1, 0, 2], available, max_matrix, allocation)
```

#### Costs and Trade-offs

| Advantage | Disadvantage |
|---------|------------|
| Completely prevents deadlock | Must know Max in advance |
| Allows more concurrency than prevention | O(n²m) overhead per request |
| Guaranteed safe state | Conservative (may refuse valid requests) |

---

### 6. Dining Philosophers Problem

#### Formal Definition

> Dining Philosophers Problem (Dijkstra, 1965): 5 philosophers sit at a round table. Between any two philosophers there is a fork (5 total). Each philosopher alternates between thinking and eating. To eat, they need BOTH forks (left and right).

```
        P0
    F4      F0
  P4          P1
    F3      F1
        P3
          F2
        P2
```

#### Naive Solution (with Deadlock!)

```c
// WRONG - can cause deadlock
philosopher(int i) {
    while (true) {
        think();
        pickup(fork[i]);           // Pick up left fork
        pickup(fork[(i+1) % 5]);   // Pick up right fork
        eat();
        putdown(fork[i]);
        putdown(fork[(i+1) % 5]);
    }
}
// If everyone picks up left simultaneously → nobody can pick up right → DEADLOCK!
```

#### Solutions

| Solution | Method | Trade-off |
|---------|--------|-----------|
| Asymmetric | One philosopher picks up right first | Simple, works |
| Limit | Max 4 philosophers at table | Guaranteed no deadlock |
| All-or-nothing | Pick up both forks atomically or none | Can cause starvation |
| Arbiter | A "waiter" coordinates | Single point of failure |

#### Python Solution (Asymmetric)

```python
import threading
import time
import random

NUM_PHILOSOPHERS = 5
forks = [threading.Lock() for _ in range(NUM_PHILOSOPHERS)]

def philosopher(id: int):
    left = id
    right = (id + 1) % NUM_PHILOSOPHERS
    
    # Asymmetric solution: philosopher 0 picks up right first!
    if id == 0:
        first, second = right, left
    else:
        first, second = left, right
    
    for _ in range(3):  # Eat 3 times
        print(f"Philosopher {id} thinking...")
        time.sleep(random.uniform(0.1, 0.5))
        
        print(f"Philosopher {id} hungry, picking up fork {first}")
        with forks[first]:
            print(f"Philosopher {id} picking up fork {second}")
            with forks[second]:
                print(f"Philosopher {id} eating!")
                time.sleep(random.uniform(0.1, 0.3))
        
        print(f"Philosopher {id} done eating")

threads = [threading.Thread(target=philosopher, args=(i,)) 
           for i in range(NUM_PHILOSOPHERS)]
for t in threads:
    t.start()
for t in threads:
    t.join()
print("Dinner complete, no deadlock!")
```

---

## Laboratory/Seminar (Session 4/7)

### TC Materials
- TC2f - Regular Expressions
- TC3c - grep, sed, awk
- TC4f - Vim basics

### Assignment 4: `tema4_logstats.sh`

Apache/Nginx log analysis:
- `-f FILE` - log file
- `-t N` - top N IPs
- `-c` - HTTP codes
- `-u` - top URLs

---

## Recommended Reading

### OSTEP
- Mandatory: [Chapter 32 - Common Concurrency Bugs](https://pages.cs.wisc.edu/~remzi/OSTEP/threads-bugs.pdf) (Deadlock section)

### Tanenbaum
- Chapter 6: Deadlocks (pp. 435-470)

---

## Modern Trends

| Evolution | Description |
|----------|-----------|
| Lock-free programming | Completely avoids locks → no deadlock by design |
| Transactional Memory | Automatic rollback on conflict |
| Static analysis | Compile-time deadlock detection (Rust borrow checker) |
| Timeouts | Give up acquisition after timeout |
| Deadlock-free by construction | Languages/frameworks that structurally prevent it |


---

## Self-Assessment

### Verification Questions

1. **[REMEMBER]** Enumerate the 4 Coffman conditions necessary for deadlock. For each, give a concrete example.
2. **[UNDERSTAND]** Explain the Banker's Algorithm. How does it determine if a state is "safe"? What does "safe sequence" mean?
3. **[ANALYSE]** Compare the 3 deadlock management strategies: prevention, avoidance, detection+recovery. What are the trade-offs of each?

### Mini-Challenge (optional)

Draw the resource allocation graph for the Dining Philosophers problem (5 philosophers) and identify the deadlock cycle.

---


---


---

## Nuances and Special Cases

### What we did NOT cover (didactic limitations)

- **Livelock**: Processes are not blocked but make no progress (e.g., two people dodging in the same direction).
- **Distributed deadlock**: Much harder to detect; requires algorithms like Chandy-Misra-Haas.
- **Resource starvation**: Different from deadlock; a process never receives the desired resource.

### Common Mistakes to Avoid

1. **Assuming try_lock solves everything**: Can lead to livelock if everyone retries simultaneously.
2. **Ignoring timeouts**: In production, use locks with timeout and retry logic.
3. **Detection without recovery**: You detect deadlock but do not know how to resolve it (which process to kill?).

### Open Questions Remaining

- How do distributed databases (CockroachDB, Spanner) detect cross-node deadlock?
- Can static analysis (at compile time) eliminate the possibility of deadlock?

## Looking Ahead

**Week 9: Memory Management (Part 1)** — From processes and synchronisation we move to memory management. We will study how the OS allocates memory to processes, paging, segmentation and the concept of virtual address space.

**Recommended Preparation:**
- Review the address space structure of a process
- Run `cat /proc/self/maps` to see the mappings

## Visual Summary

```
┌─────────────────────────────────────────────────────────────────┐
│                    WEEK 8: DEADLOCK — RECAP                     │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  DEADLOCK = Permanent circular waiting                          │
│                                                                 │
│  THE 4 COFFMAN CONDITIONS (all necessary)                       │
│  ├── 1. Mutual Exclusion: resource not shareable               │
│  ├── 2. Hold and Wait: hold and wait                           │
│  ├── 3. No Preemption: cannot be forcibly taken                │
│  └── 4. Circular Wait: A→B→C→...→A                             │
│                                                                 │
│  STRATEGIES                                                     │
│  ├── PREVENTION: eliminate one of the 4 conditions             │
│  ├── AVOIDANCE: Banker's Algorithm (safe state)                │
│  ├── DETECTION: find cycles in RAG                             │
│  └── RECOVERY: kill process or preempt resources               │
│                                                                 │
│  PHILOSOPHERS PROBLEM                                           │
│  ├── 5 philosophers, 5 forks, round table                      │
│  └── Solutions: asymmetry, timeout, central arbiter            │
│                                                                 │
│  💡 TAKEAWAY: Safest = prevention through resource ordering    │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

*Materials developed by Revolvix for ASE Bucharest - CSIE*  
*Operating Systems | Year I, Semester 2 | 2025-2026*

## Scripting in Context (Bash + Python): Deadlock: avoidance (Banker) and classic scenario

### Included Files

- Python: `scripts/banker_demo.py` — Calculates a safe sequence (Banker).
- Python: `scripts/deadlock_two_locks.py` — Demonstrates deadlock through reversed lock ordering.
- Bash: `scripts/locks_audit.sh` — Observability: who is holding files/directories open.

### Quick Run

```bash
./scripts/banker_demo.py
./scripts/deadlock_two_locks.py --mode deadlock
./scripts/deadlock_two_locks.py --mode ordered
```

### Connection to This Week's Concepts

- Banker's Algorithm formalises the idea of *safe state*.
- Deadlock with two locks concretely shows how "circular wait" appears and why a global lock ordering is an avoidance strategy.

### Recommended Practice

- run the scripts first on a test directory (not on critical data);
- save the output to a file and attach it to your report/assignment, if required;
- note the kernel version (`uname -r`) and Python version (`python3 --version`) when comparing results.

*Materials developed by Revolvix for ASE Bucharest - CSIE*  
*Operating Systems | Year I, Semester 2 | 2025-2026*
