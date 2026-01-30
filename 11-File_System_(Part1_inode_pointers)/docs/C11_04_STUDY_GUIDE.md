# Study Guide — File System P1

## Inode Contains
- File type, permissions
- Owner (UID, GID)
- Size
- Timestamps (atime, mtime, ctime)
- Link count
- Pointers to data blocks

## Inode Does NOT Contain
- File name (stored in directory)

## Hard vs Soft Links
| Hard Link | Soft Link |
|-----------|-----------|
| Same inode | Different inode |
| Cannot cross FS | Can cross FS |
| Cannot link dirs | Can link dirs |
| Target must exist | Target can be missing |

## Maximum Size Calculation
```
12 direct × 4KB = 48KB
1 single × 1024 × 4KB = 4MB
1 double × 1024 × 1024 × 4KB = 4GB
1 triple × 1024³ × 4KB = 4TB
```
