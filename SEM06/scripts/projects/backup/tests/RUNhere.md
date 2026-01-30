# 📁 Test Suite — Backup Project

> **Location:** `SEM06/scripts/projects/backup/tests/`  
> **Purpose:** Automated tests for backup functionality

## Contents

| File | Purpose |
|------|---------|
| `test_backup.sh` | Main test suite |

---

## Running Tests

```bash
# From project directory
./tests/test_backup.sh

# Via Makefile
make test

# Verbose mode
./tests/test_backup.sh --verbose
```

---

## Test Coverage

| Test | Description |
|------|-------------|
| `test_config_loading` | Configuration file parsing |
| `test_backup_creation` | Basic backup creation |
| `test_incremental` | Incremental backup detection |
| `test_rotation` | Old backup cleanup |
| `test_error_handling` | Invalid input handling |

---

*See also: [`../lib/`](../lib/) for modules being tested*

*Last updated: January 2026*
