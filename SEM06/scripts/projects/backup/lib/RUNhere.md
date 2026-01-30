# 📁 Library Modules — Backup Project

> **Location:** `SEM06/scripts/projects/backup/lib/`  
> **Purpose:** Modular library functions for the backup project

## Contents

| Module | Purpose |
|--------|---------|
| `config.sh` | Configuration loading and validation |
| `core.sh` | Core backup functionality |
| `utils.sh` | Utility functions (logging, validation) |

---

## Usage

Source in main script:
```bash
#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/config.sh"
source "${SCRIPT_DIR}/lib/utils.sh"
source "${SCRIPT_DIR}/lib/core.sh"
```

---

## Module Details

### config.sh
- Load backup configuration from file
- Validate paths and retention settings
- Default values for missing options

### core.sh
- Incremental backup logic
- Compression handling (gzip, tar)
- Rotation/cleanup of old backups

### utils.sh
- Logging: `log_info`, `log_error`, `log_debug`
- Path validation and sanitization
- Size calculations and formatting

---

*See also: [`../backup.sh`](../backup.sh) for main script*  
*See also: [`../tests/`](../tests/) for test suite*

*Last updated: January 2026*
