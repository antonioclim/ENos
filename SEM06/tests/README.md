# Tests - Seminar 6 (CAPSTONE)

> **⚠️ SPECIAL STRUCTURE:** SEM06 is a **CAPSTONE** seminar with integrated projects.  
> Tests are distributed across the individual project directories.

---

## Test Locations

```
SEM06/
├── scripts/
│   ├── test_runner.sh          ← Global runner for all projects
│   ├── test_helpers.sh         ← Common helper functions
│   └── projects/
│       ├── monitor/tests/
│       │   └── test_monitor.sh     ✅ Tests for System Monitor
│       ├── backup/tests/
│       │   └── test_backup.sh      ✅ Tests for Backup System
│       └── deployer/tests/
│           └── test_deployer.sh    ✅ Tests for Deployer
└── tests/
    └── README.md               ← This file (index)
```

---

## Running Tests

### All Tests (Recommended)
```bash
cd SEM06/scripts
./test_runner.sh
```

### Per Project
```bash
# Monitor
cd SEM06/scripts/projects/monitor
./tests/test_monitor.sh

# Backup
cd SEM06/scripts/projects/backup
./tests/test_backup.sh

# Deployer
cd SEM06/scripts/projects/deployer
./tests/test_deployer.sh
```

---

## What Each Suite Tests

### Monitor (`test_monitor.sh`)
| Test | Description |
|------|-------------|
| Metrics collection | CPU, RAM, Disk, Network |
| Threshold alerting | Alerts when thresholds exceeded |
| Logging | Format and rotation |
| Daemon mode | Operation as a service |

### Backup (`test_backup.sh`)
| Test | Description |
|------|-------------|
| Full backup | Complete backup |
| Incremental | Changes only |
| Compression | gzip, tar |
| Restoration | Recovery from archive |

### Deployer (`test_deployer.sh`)
| Test | Description |
|------|-------------|
| Deploy | From repository/archive |
| Pre/Post hooks | Script execution |
| Rollback | Revert to previous version |
| Health check | Deployment validation |

---

## Integrated Competencies Tested

| Project | SEM01-05 Competencies Applied |
|---------|-------------------------------|
| Monitor | Variables, Loops, Functions, Arrays |
| Backup | find/xargs, Compression, Error handling |
| Deployer | getopts, Processes, solid scripting |

---

## Note About Structure

SEM06 does not have tests in this directory because:
1. It is an **integration** seminar (CAPSTONE)
2. Tests are **co-located** with the project code
3. This approach reflects **professional practices**

---

## References

- `../docs/S06_05_Testing_Framework.md`
- `../scripts/test_helpers.sh`
- `../scripts/test_runner.sh`
