# Study Guide — Virtual Memory

## TLB (Translation Lookaside Buffer)
- Cache for page→frame translations
- Hit: ~1ns, Miss: ~100ns
- Fully associative, small (64-1024 entries)

## Page Replacement Algorithms

| Algorithm | Description | Problem |
|-----------|-------------|---------|
| FIFO | Replaces the oldest | Belady anomaly |
| LRU | Replaces least recently used | Costly implementation |
| OPT | Replaces the one used furthest in future | Impossible (future) |
| Clock | LRU approximation with reference bit | Simple, approximate |

## Thrashing
- System spends more time swapping than computing
- Cause: Too few frames per process
- Solution: Working set model, page fault frequency
