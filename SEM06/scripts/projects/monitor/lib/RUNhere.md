# 📁 Library Modules — Monitor Project

> **Location:** `SEM06/scripts/projects/monitor/lib/`  
> **Purpose:** Modular library for system monitoring

## Contents

| Module | Purpose |
|--------|---------|
| `config.sh` | Monitoring thresholds and targets |
| `core.sh` | Core monitoring logic |
| `utils.sh` | Utility functions |

---

## Usage

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
- Alert thresholds (CPU, memory, disk)
- Check intervals
- Notification settings

### core.sh
- Resource measurement functions
- Threshold comparison logic
- Alert triggering

### utils.sh
- Logging functions
- Notification dispatch
- Report formatting

---

*See also: [`../monitor.sh`](../monitor.sh) for main script*

*Last updated: January 2026*
