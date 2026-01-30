# S06 Homework Rubric

> **Operating Systems** | ASE Bucharest - CSIE  
> Seminar 06: Capstone Integration Projects

---

## Assignment Overview

| ID | Topic | Duration | Difficulty |
|----|-------|----------|------------|
| S06_HW01 | Monitor Template | 90 min | ⭐⭐⭐⭐ |
| S06_HW02 | Backup Template | 90 min | ⭐⭐⭐⭐ |
| S06_HW03 | Deployer Template | 90 min | ⭐⭐⭐⭐ |

**Note:** These are integration assignments that combine all previous skills. They serve as preparation for the semester project.

---

## S06_HW01 - Monitor Template (10 points)

### Description
Implement a system monitoring script that tracks CPU, memory, disk and network usage.

### Mandatory Requirements (6 points)

| Criterion | Points | Requirements |
|-----------|--------|--------------|
| CPU monitoring | 1.5 | Read from /proc/stat or use top |
| Memory monitoring | 1.5 | Parse /proc/meminfo or free |
| Disk monitoring | 1.5 | Use df, report usage % |
| Output formatting | 1.5 | Clear, readable output |

### Optional Requirements (4 points)

| Criterion | Points | Requirements |
|-----------|--------|--------------|
| Network monitoring | 1.0 | Interface statistics |
| Threshold alerts | 1.0 | Warn when > 80% |
| Continuous mode | 1.0 | Loop with interval |
| Log to file | 1.0 | Timestamped logging |

### Expected Output
```
=== System Monitor ===
Timestamp: 2025-01-30 14:30:00

CPU Usage:    45.2%
Memory Usage: 67.8% (5.4G / 8.0G)
Disk Usage:   73.1% (293G / 400G) on /

[WARN] Memory usage above 60%
```

### Common Deductions
- `-1.0`: Hardcoded values instead of reading system
- `-0.5`: No error handling for missing files
- `-0.5`: Poor output formatting

---

## S06_HW02 - Backup Template (10 points)

### Description
Implement a backup script with compression, rotation and logging.

### Mandatory Requirements (6 points)

| Criterion | Points | Requirements |
|-----------|--------|--------------|
| Source/dest params | 1.5 | Accept directories as arguments |
| Compression | 1.5 | Use tar with gzip |
| Timestamped names | 1.5 | backup_YYYYMMDD_HHMMSS.tar.gz |
| Basic logging | 1.5 | Log start, end, size |

### Optional Requirements (4 points)

| Criterion | Points | Requirements |
|-----------|--------|--------------|
| Rotation | 1.5 | Keep last N backups |
| Incremental | 1.0 | Only changed files |
| Verification | 1.0 | Test archive integrity |
| Email notification | 0.5 | Send summary |

### Expected Usage
```bash
./backup.sh /home/user/documents /backups/
# Creates: /backups/backup_20250130_143000.tar.gz
```

### Expected Log
```
[2025-01-30 14:30:00] Backup started
[2025-01-30 14:30:00] Source: /home/user/documents (1.2G)
[2025-01-30 14:30:15] Archive created: backup_20250130_143000.tar.gz
[2025-01-30 14:30:15] Compressed size: 456M
[2025-01-30 14:30:15] Backup completed successfully
```

---

## S06_HW03 - Deployer Template (10 points)

### Description
Implement a deployment script for a simple web application.

### Mandatory Requirements (6 points)

| Criterion | Points | Requirements |
|-----------|--------|--------------|
| Config file | 1.5 | Read deployment settings |
| File sync | 1.5 | Copy files to target |
| Service restart | 1.5 | Restart web server |
| Rollback support | 1.5 | Keep previous version |

### Optional Requirements (4 points)

| Criterion | Points | Requirements |
|-----------|--------|--------------|
| Health check | 1.0 | Verify deployment success |
| Git integration | 1.0 | Pull from repository |
| Multi-environment | 1.0 | dev/staging/prod configs |
| Dry-run mode | 1.0 | Show what would happen |

### Expected Config (deploy.conf)
```bash
# Deployment configuration
APP_NAME="myapp"
SOURCE_DIR="/home/user/myapp"
DEPLOY_DIR="/var/www/myapp"
BACKUP_DIR="/var/backups/myapp"
SERVICE_NAME="nginx"
MAX_BACKUPS=5
```

### Expected Usage
```bash
./deployer.sh deploy              # Deploy latest
./deployer.sh rollback            # Rollback to previous
./deployer.sh status              # Show current version
./deployer.sh --dry-run deploy    # Simulate deployment
```

---

## General Grading Notes

### Code Quality (applies to all S06 assignments)

| Aspect | Expectation |
|--------|-------------|
| Shebang | `#!/bin/bash` present |
| Strict mode | `set -euo pipefail` |
| Comments | Header and inline documentation |
| Functions | Modular, reusable code |
| Variables | Quoted, meaningful names |
| Error handling | Check return codes, validate input |

### Deductions for Poor Practices

| Issue | Penalty |
|-------|---------|
| No strict mode | -0.5 |
| Unquoted variables | -0.5 |
| No input validation | -0.5 |
| No error handling | -1.0 |
| Hardcoded paths | -0.5 |
| No comments | -0.5 |

### Bonus Opportunities

| Bonus | Points | Description |
|-------|--------|-------------|
| ShellCheck clean | +0.5 | No warnings |
| Help message | +0.5 | -h/--help implemented |
| Colour output | +0.25 | ANSI colours for status |
| Config validation | +0.25 | Check config file syntax |

---

## Integration with Semester Project

These homework assignments directly prepare students for their semester project:

| Homework | Project Relevance |
|----------|-------------------|
| S06_HW01 Monitor | System monitoring features |
| S06_HW02 Backup | Data persistence and recovery |
| S06_HW03 Deployer | Automation and deployment |

Students who complete these homeworks thoroughly will have a strong foundation for their project implementation.

---

*By Revolvix for OPERATING SYSTEMS class | restricted licence 2017-2030*
