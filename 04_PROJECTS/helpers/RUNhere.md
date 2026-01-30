# 📁 Project Helpers — Student Validation Tools

> **Location:** `04_PROJECTS/helpers/`  
> **Purpose:** Scripts to validate, test, and package student projects before submission  
> **Target audience:** Students

## Contents

| Script | Purpose | When to Use |
|--------|---------|-------------|
| `project_validator.sh` | Validates project structure and requirements | Before every commit |
| `submission_packager.sh` | Creates compliant submission archive | Final submission step |
| `test_runner.sh` | Runs project tests locally | During development |

## Quick Start

```bash
# Make all scripts executable
chmod +x *.sh

# 1. Validate your project structure
./project_validator.sh ~/my_project/

# 2. Run tests locally
./test_runner.sh ~/my_project/

# 3. Package for submission
./submission_packager.sh ~/my_project/ --student-id ABC123
```

---

## project_validator.sh

**Purpose:** Ensures your project meets all structural requirements before submission.

### Usage

```bash
./project_validator.sh <project_directory> [options]

Options:
  --strict        Fail on warnings (default: warnings only)
  --quiet         Suppress verbose output
  --report FILE   Generate detailed report
```

### What It Checks

| Check | Requirement | Severity |
|-------|-------------|----------|
| ✅ README.md | Must exist with required sections | ERROR |
| ✅ Makefile | Must have `all`, `test`, `clean` targets | ERROR |
| ✅ src/ directory | Must contain main script | ERROR |
| ✅ tests/ directory | Must have at least one test | WARNING |
| ❌ .env files | Must NOT be present | ERROR |
| ❌ Credentials | No hardcoded passwords/tokens | ERROR |
| ✅ Line endings | Must be LF (Unix), not CRLF | WARNING |
| ✅ File sizes | No file > 10MB | ERROR |
| ✅ Shebang | Scripts must have proper shebang | WARNING |

### Example Output

```
═══════════════════════════════════════════════════════════════
 PROJECT VALIDATOR v2.1
═══════════════════════════════════════════════════════════════

Checking: /home/student/my_monitor_project/

[OK]   README.md exists (2.4 KB)
[OK]   Makefile has required targets
[OK]   src/main.sh exists and is executable
[WARN] tests/ has only 1 test file (recommended: 3+)
[OK]   No .env files found
[OK]   No credentials detected
[OK]   All files use LF line endings
[OK]   No oversized files

═══════════════════════════════════════════════════════════════
 RESULT: PASSED (1 warning)
═══════════════════════════════════════════════════════════════
```

---

## test_runner.sh

**Purpose:** Runs your project's test suite in an environment similar to the evaluation system.

### Usage

```bash
./test_runner.sh <project_directory> [options]

Options:
  --verbose       Show detailed test output
  --timeout SEC   Set test timeout (default: 60)
  --coverage      Generate coverage report (if available)
  --docker        Run tests in Docker container (mirrors eval)
```

### How It Works

1. Sources your project's test files from `tests/`
2. Sets up temporary test environment
3. Runs each `test_*.sh` or `test_*.py` file
4. Reports results with timing

### Example

```bash
# Basic test run
./test_runner.sh ~/my_project/

# With Docker (same as evaluation environment)
./test_runner.sh ~/my_project/ --docker

# Verbose with timeout
./test_runner.sh ~/my_project/ --verbose --timeout 120
```

### Output

```
═══════════════════════════════════════════════════════════════
 TEST RUNNER v2.0
═══════════════════════════════════════════════════════════════

Running tests for: my_monitor_project

[1/4] test_basic_functionality.sh ... PASSED (0.8s)
[2/4] test_error_handling.sh ....... PASSED (1.2s)
[3/4] test_edge_cases.sh ........... PASSED (0.5s)
[4/4] test_integration.sh .......... PASSED (2.1s)

═══════════════════════════════════════════════════════════════
 SUMMARY: 4/4 tests passed (4.6s total)
═══════════════════════════════════════════════════════════════
```

---

## submission_packager.sh

**Purpose:** Creates a properly formatted archive ready for submission.

### Usage

```bash
./submission_packager.sh <project_directory> --student-id <ID> [options]

Options:
  --student-id ID   Required: Your student identifier (e.g., ABC123)
  --output DIR      Output directory (default: current)
  --include-git     Include .git directory (not recommended)
  --dry-run         Show what would be packaged without creating archive
```

### What It Does

1. Runs `project_validator.sh` automatically
2. Cleans build artifacts (`make clean`)
3. Removes unnecessary files (`.DS_Store`, `__pycache__`, etc.)
4. Creates timestamped archive: `{STUDENT_ID}_project_{TIMESTAMP}.tar.gz`
5. Verifies archive integrity

### Example

```bash
# Standard packaging
./submission_packager.sh ~/my_project/ --student-id ABC123

# Preview without creating
./submission_packager.sh ~/my_project/ --student-id ABC123 --dry-run

# Custom output location
./submission_packager.sh ~/my_project/ --student-id ABC123 --output ~/Desktop/
```

### Output

```
═══════════════════════════════════════════════════════════════
 SUBMISSION PACKAGER v2.0
═══════════════════════════════════════════════════════════════

Student ID: ABC123
Project: my_monitor_project
Timestamp: 2026-01-30_14-32-15

[1/5] Running validator .......... PASSED
[2/5] Cleaning build artifacts ... Done (removed 12 files)
[3/5] Removing temp files ........ Done (removed 3 files)
[4/5] Creating archive ........... Done
[5/5] Verifying integrity ........ PASSED

═══════════════════════════════════════════════════════════════
 SUCCESS: ABC123_project_2026-01-30_14-32-15.tar.gz (45.2 KB)
 Location: /home/student/ABC123_project_2026-01-30_14-32-15.tar.gz
═══════════════════════════════════════════════════════════════

Upload this file to the submission portal.
```

---

## Workflow Summary

```
┌─────────────────────────────────────────────────────────────┐
│                    RECOMMENDED WORKFLOW                      │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│   1. Development Loop:                                       │
│      ┌──────────┐    ┌───────────┐    ┌──────────┐          │
│      │  Code    │ ─► │  Validate │ ─► │   Test   │          │
│      └──────────┘    └───────────┘    └──────────┘          │
│           ▲                                │                 │
│           └────────────────────────────────┘                 │
│                                                              │
│   2. Before Submission:                                      │
│      ┌──────────┐    ┌───────────┐    ┌──────────┐          │
│      │ Validate │ ─► │   Test    │ ─► │  Package │          │
│      │ --strict │    │  --docker │    │          │          │
│      └──────────┘    └───────────┘    └──────────┘          │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

## Common Issues

| Problem | Solution |
|---------|----------|
| "Permission denied" | `chmod +x *.sh` |
| Validator fails on line endings | `dos2unix src/*.sh` or use VS Code with LF |
| Tests timeout | Increase with `--timeout 120` |
| Archive too large | Check for accidentally included data files |
| Docker not available | Run without `--docker` flag |

---

*See also: [`../README.md`](../README.md) for project specifications*  
*See also: [`../UNIVERSAL_RUBRIC.md`](../UNIVERSAL_RUBRIC.md) for grading criteria*

*Last updated: January 2026*
