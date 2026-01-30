# Study Guide — Filesystem P2

## Allocation Methods

| Method | Pro | Con |
|--------|-----|-----|
| Contiguous | Fast sequential & random | External frag |
| Linked | No external frag | Slow random access |
| Indexed | Both benefits | Index block overhead |

## FAT (File Allocation Table)
- Centralised linked allocation
- FAT[i] = next block for file using block i
- Simple, widely compatible

## Extents (ext4)
- (start_block, length) tuples
- Efficient for large contiguous files
- Reduces metadata overhead

## VFS (Virtual File System)
- Uniform interface for all filesystems
- Syscalls → VFS → specific FS driver
