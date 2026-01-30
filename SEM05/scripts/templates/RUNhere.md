# 📁 Script Templates — Bash Best Practices

> **Location:** `SEM05/scripts/templates/`  
> **Purpose:** Reusable script templates following best practices

## Contents

| Template | Purpose |
|----------|---------|
| `simple_script.sh` | Minimal script template |
| `professional_script.sh` | Full-featured with logging |
| `library.sh` | Reusable function library |

---

## simple_script.sh

Basic template with error handling:
```bash
#!/bin/bash
set -euo pipefail
# Your code here
```

## professional_script.sh

Includes:
- Argument parsing (getopts)
- Logging functions
- Error handling
- Cleanup trap
- Help message

```bash
./professional_script.sh --help
```

## library.sh

Sourceable function library:
```bash
source library.sh
log_info "Using library functions"
```

---

## Usage

```bash
# Copy template to start new script
cp templates/professional_script.sh ../my_new_script.sh

# Edit and customize
nano ../my_new_script.sh
```

---

*Last updated: January 2026*
