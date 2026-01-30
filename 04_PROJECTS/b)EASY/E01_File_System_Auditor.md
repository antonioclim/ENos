# E01: File System Auditor

> **Level:** EASY | **Estimated time:** 15-20 hours | **Components:** Bash only

---

## Description

Develop a tool that analyses and reports on the state of a file system. The script will generate detailed reports about space usage, file types, permissions and potential issues.

---

## Learning Objectives

- Using `find`, `du`, `stat` commands
- Output processing with `awk` and `sort`
- Formatted report generation
- Modular Bash scripting

---

## Functional Requirements

### Mandatory (for passing grade)

1. **Disk space analysis**
   - Display usage per directory (top 10)
   - Identify large files (> configurable threshold)
   - Total used vs available space

2. **File type statistics**

- Count files per extension
- Total size per type
- Files without extension


3. **Permission audit**
   - Identify world-writable files
   - SUID/SGID files
   - Directories without read permissions

4. **Final report**
   - Formatted text output
   - CSV export option
   - Timestamp and metadata

### Optional (for full marks)

5. **Duplicate files** - identification by MD5/SHA hash
6. **Old files** - not accessed in the last N days
7. **Broken symbolic links** - identification and reporting
8. **Comparison over time** - diff between two runs

---

## Interface

```bash
# Basic usage
./fs_auditor.sh /path/to/analyze

# With options
./fs_auditor.sh [OPTIONS] <directory>

Options:
  -h, --help           Display help
  -o, --output FILE    Save report to file
  -f, --format FORMAT  Output format: text|csv|json
  -t, --threshold SIZE Large files threshold (default: 100M)
  -d, --depth N        Maximum analysis depth (default: 5)
  -v, --verbose        Detailed output
  --no-color           Disable colours

Examples:
  ./fs_auditor.sh /home/user
  ./fs_auditor.sh -o report.txt -f csv /var/log
  ./fs_auditor.sh --threshold 50M --depth 3 /opt
```

---

## Output Examples

### Text Output (default)

```
╔══════════════════════════════════════════════════════════════════╗
║              FILE SYSTEM AUDIT REPORT                            ║
║              Directory: /home/student                            ║
║              Date: 2025-01-20 14:30:00                          ║
╚══════════════════════════════════════════════════════════════════╝

📊 SPACE USAGE SUMMARY
──────────────────────────────────────────────────────────────────
Total analysed:     15.2 GB
Files count:        12,453
Directories:        1,234

📁 TOP 10 DIRECTORIES BY SIZE
──────────────────────────────────────────────────────────────────
  1.  4.2 GB   ./Downloads
  2.  3.1 GB   ./Documents/Projects
  3.  2.8 GB   ./.cache
  ...

📄 FILE TYPES DISTRIBUTION
──────────────────────────────────────────────────────────────────
Extension    Count      Size       Percentage
─────────────────────────────────────────────
.pdf         1,234      2.1 GB     13.8%
.jpg         3,456      1.8 GB     11.8%
.py          567        45 MB      0.3%
(no ext)     234        123 MB     0.8%
...

⚠️  PERMISSION ISSUES
──────────────────────────────────────────────────────────────────
World-writable files: 3
  - ./temp/shared.txt
  - ./public/upload.sh
  - ./data/config.ini

SUID files: 1
  - ./bin/special_tool

🔴 LARGE FILES (>100MB)
──────────────────────────────────────────────────────────────────
  850 MB   ./Downloads/ubuntu-24.04.iso
  234 MB   ./Videos/presentation.mp4
  ...

══════════════════════════════════════════════════════════════════
Report generated in 12.3 seconds
══════════════════════════════════════════════════════════════════
```

### CSV Output

```csv
type,path,size_bytes,permissions,modified
directory,/home/student/Downloads,4509715456,drwxr-xr-x,2025-01-15
file,/home/student/Downloads/ubuntu.iso,891289600,-rw-r--r--,2025-01-10
...
```

---

## Recommended Structure

```
E01_File_System_Auditor/
├── README.md
├── Makefile
├── src/
│   ├── fs_auditor.sh          # Main script
│   └── lib/
│       ├── utils.sh           # Utility functions
│       ├── space_analyzer.sh  # Space analysis
│       ├── type_analyzer.sh   # Type analysis
│       ├── perm_checker.sh    # Permission checking
│       └── report_gen.sh      # Report generation
├── etc/
│   └── config.conf            # Default configuration
├── tests/
│   ├── test_space.sh
│   ├── test_types.sh
│   └── run_all_tests.sh
├── docs/
│   ├── INSTALL.md
│   └── USAGE.md
└── examples/
    └── sample_output.txt
```

---

## Implementation Hints

### Space analysis

```bash
# Directory sizes
du -sh */ 2>/dev/null | sort -rh | head -10

# Large files
find . -type f -size +100M -exec ls -lh {} \;
```

### Extension statistics

```bash
# Count per extension
find . -type f | sed 's/.*\.//' | sort | uniq -c | sort -rn
```

### Permission checking

```bash
# World-writable
find . -type f -perm -002

# SUID
find . -type f -perm -4000
```

---

## Specific Evaluation Criteria

| Criterion | Weight | Description |
|-----------|--------|-------------|
| Correct space analysis | 15% | Top directories, large files |
| Type statistics | 10% | Counting and summarisation |
| Permission audit | 10% | Problem identification |
| Formatted report | 5% | Readable, professional output |
| CLI options | 10% | getopts, input validation |
| CSV/JSON export | 5% | Correct format |
| Extra features | 15% | Duplicates, old files, symlinks |
| Code quality | 15% | Modularity, comments |
| Tests | 10% | Functionality coverage |
| Documentation | 5% | Complete README |

---

## Resources

- `man find` - advanced find options
- `man du` - disk usage
- `man stat` - file information
- Seminar 1-3 - basic commands and scripting

---

*EASY Project | Operating Systems | ASE-CSIE*
