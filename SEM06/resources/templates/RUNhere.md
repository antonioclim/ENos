# 📁 Bash Script Templates

> **Location:** `SEM06/resources/templates/`  
> **Purpose:** Professional script templates for capstone projects

## Contents

| Template | Purpose |
|----------|---------|
| `bash_script_template.sh` | Full-featured professional template |

---

## bash_script_template.sh

A comprehensive template including:

### Features
- Strict mode: `set -euo pipefail`
- Coloured logging (info, warn, error)
- Explicit short/long option parsing
- Configuration file support
- Cleanup trap for temporary files
- Help message generation
- Version information

### Usage

```bash
# Copy and customize
cp bash_script_template.sh my_project.sh
chmod +x my_project.sh

# View help
./my_project.sh --help

# Run with options
./my_project.sh --config my.conf --verbose
```

### Structure

```text
# Structural illustration only; the actual template below is executable.
#!/bin/bash
# Header with metadata

set -euo pipefail

# Constants and defaults
VERSION="1.0.0"
VERBOSE=false

# Logging functions
log_info() { ... }
log_error() { ... }

# Cleanup trap
cleanup() { ... }
trap cleanup EXIT

# Argument parsing
while getopts "hvc:" opt; do
    ...
done

# Main logic
main() { ... }

main "$@"
```

---

*See also: [`../../scripts/projects/`](../../scripts/projects/) for complete examples*

*Last updated: January 2026*

The maintained template reports NOT_IMPLEMENTED with status3 for unfinished main behaviour; help/version are available. Copying it does not complete a capstone. Literal configuration is data, cleanup owns only allocated paths and INT/TERM use explicit exit statuses. See [the teaching contract](../../docs/TEACHING_CONTRACT.md).
