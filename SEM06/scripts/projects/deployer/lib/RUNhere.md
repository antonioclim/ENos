# 📁 Library Modules — Deployer Project

> **Location:** `SEM06/scripts/projects/deployer/lib/`  
> **Purpose:** Modular library functions for deployment automation

## Contents

| Module | Purpose |
|--------|---------|
| `config.sh` | Deployment configuration |
| `core.sh` | Core deployment logic |
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
- Target server configuration
- Deployment paths and destinations
- Rollback settings

### core.sh
- File transfer logic (rsync/scp)
- Service restart procedures
- Health check validation

### utils.sh
- SSH wrapper functions
- Logging utilities
- Status reporting

---

*See also: [`../deployer.sh`](../deployer.sh) for main script*

*Last updated: January 2026*
