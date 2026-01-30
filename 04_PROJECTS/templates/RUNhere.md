# 📁 Project Templates — Starter Scaffolding

> **Location:** `04_PROJECTS/templates/`  
> **Purpose:** Generate standardised project structure for student assignments  
> **Target audience:** Students starting new projects

## Contents

| File | Purpose |
|------|---------|
| `project_structure.sh` | Generates complete project skeleton |
| `README_template.md` | Template for project documentation |
| `Makefile_template` | Standard Makefile with required targets |

## Quick Start

```bash
# Make script executable
chmod +x project_structure.sh

# Create new project from template
./project_structure.sh my_backup_project --type backup

# List available project types
./project_structure.sh --list-types
```

---

## project_structure.sh

**Purpose:** Generates a complete, standards-compliant project directory with all required files.

### Usage

```bash
./project_structure.sh <project_name> [options]

Arguments:
  project_name      Name for your project directory

Options:
  --type TYPE       Project template type (see --list-types)
  --output DIR      Parent directory for project (default: current)
  --author NAME     Your name for documentation
  --list-types      Show available project types
  --force           Overwrite existing directory
```

### Available Project Types

```bash
$ ./project_structure.sh --list-types

Available project types:
  monitor    - System/process monitoring project
  backup     - Backup automation project
  deployer   - Deployment automation project
  analyzer   - Log/data analysis project
  scheduler  - Task scheduling project
  custom     - Minimal template (build your own)
```

### Generated Structure

```
my_project/
├── README.md              # Pre-filled documentation template
├── Makefile               # Standard targets: all, test, clean, install
├── .gitignore             # Common ignore patterns
├── src/
│   ├── main.sh            # Entry point with argument parsing
│   └── lib/
│       ├── config.sh      # Configuration management
│       ├── utils.sh       # Utility functions
│       └── logging.sh     # Logging helpers
├── tests/
│   ├── test_main.sh       # Test skeleton
│   └── test_helpers.sh    # Test utilities
├── docs/
│   ├── DESIGN.md          # Design document template
│   └── CHANGELOG.md       # Version history template
└── examples/
    └── example_config.conf # Sample configuration
```

### Example Usage

```bash
# Create a backup project
./project_structure.sh my_backup_system --type backup --author "John Doe"

# Create in specific directory
./project_structure.sh scheduler_v2 --type scheduler --output ~/projects/

# Minimal custom project
./project_structure.sh experiment --type custom
```

### Output

```
═══════════════════════════════════════════════════════════════
 PROJECT GENERATOR v2.0
═══════════════════════════════════════════════════════════════

Creating project: my_backup_system
Type: backup
Location: /home/student/my_backup_system/

[1/8] Creating directory structure ... Done
[2/8] Generating README.md ........... Done
[3/8] Generating Makefile ............ Done
[4/8] Creating main.sh ............... Done
[5/8] Creating library files ......... Done (3 files)
[6/8] Creating test skeletons ........ Done (2 files)
[7/8] Creating documentation ......... Done
[8/8] Setting permissions ............ Done

═══════════════════════════════════════════════════════════════
 SUCCESS: Project created at /home/student/my_backup_system/
═══════════════════════════════════════════════════════════════

Next steps:
  1. cd my_backup_system
  2. Edit README.md with your project details
  3. Implement src/main.sh
  4. Run: make test
```

---

## Template Files

### README_template.md

Pre-filled project documentation including:
- Project title and description placeholders
- Installation instructions
- Usage examples with placeholder commands
- Configuration section
- Testing instructions
- Grading criteria checklist

### Makefile_template

Standard Makefile with required targets:

```makefile
# Required targets (do not rename)
all:        # Build/prepare project
test:       # Run all tests
clean:      # Remove build artifacts
install:    # Install to system (optional)

# Optional targets
lint:       # Run shellcheck
docs:       # Generate documentation
package:    # Create submission archive
```

---

## Customisation Tips

### After Generation

1. **Edit README.md first** — Fill in project description and requirements
2. **Review main.sh** — Understand the argument parsing template
3. **Check Makefile** — Ensure targets match your build process
4. **Update .gitignore** — Add project-specific patterns

### Modifying Templates

If you need to customize templates for your workflow:

```bash
# Copy template for modification
cp README_template.md my_README_template.md

# Use custom template
./project_structure.sh my_project --readme-template my_README_template.md
```

---

## Integration with Helpers

After creating your project, use the helper scripts:

```bash
# Validate structure
../helpers/project_validator.sh my_project/

# Run tests
../helpers/test_runner.sh my_project/

# Package for submission
../helpers/submission_packager.sh my_project/ --student-id ABC123
```

---

*See also: [`../helpers/RUNhere.md`](../helpers/RUNhere.md) for validation tools*  
*See also: [`../README.md`](../README.md) for project specifications*

*Last updated: January 2026*
