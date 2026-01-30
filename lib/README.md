# ENos Shared Utilities — lib/

> **Purpose:** Centralised utility modules used across all seminars  
> **Author:** ing. dr. Antonio Clim | ASE Bucharest — CSIE  
> **Version:** 1.0 | **Updated:** January 2025

---

## Overview

The `lib/` directory contains shared Python modules that provide consistent functionality across all seminar packages. These utilities ensure uniform logging, deterministic randomisation for anti-plagiarism measures, and other cross-cutting concerns.

**Why centralised utilities?**

1. **Consistency** — All seminars use identical logging format and randomisation algorithms
2. **Maintainability** — Bug fixes propagate automatically to all seminars
3. **Testing** — Shared code is tested once, used everywhere
4. **British English** — Centralised enforcement of spelling conventions

---

## Modules

### logging_utils.py

Provides consistent, structured logging with colour support for terminal output.

**Classes:**

| Class | Purpose |
|-------|---------|
| `ColouredFormatter` | ANSI colour-coded log levels for terminal |

**Functions:**

| Function | Signature | Purpose |
|----------|-----------|---------|
| `setup_logging` | `(name, level=INFO, log_file=None, use_colours=True) → Logger` | Configure a logger with ENos defaults |
| `get_logger` | `(name) → Logger` | Convenience wrapper for quick logger access |

**Usage:**

```python
import sys
from pathlib import Path

# Add lib/ to path (adjust relative path as needed)
sys.path.insert(0, str(Path(__file__).parent.parent.parent / 'lib'))
from logging_utils import setup_logging, get_logger

# Option 1: Full configuration
logger = setup_logging(
    name=__name__,
    level=logging.DEBUG,
    log_file=Path('/tmp/my_script.log'),
    use_colours=True
)

# Option 2: Quick access with defaults
logger = get_logger(__name__)

# Use the logger
logger.debug("Debugging information")
logger.info("Processing started")
logger.warning("Low disk space detected")
logger.error("File not found: config.yaml")
logger.critical("Database connection failed!")
```

**Output (terminal with colours):**
```
[2025-01-30 10:00:00] [DEBUG] my_module: Debugging information
[2025-01-30 10:00:01] [INFO] my_module: Processing started
[2025-01-30 10:00:02] [WARNING] my_module: Low disk space detected
[2025-01-30 10:00:03] [ERROR] my_module: File not found: config.yaml
[2025-01-30 10:00:04] [CRITICAL] my_module: Database connection failed!
```

**Colour Scheme:**

| Level | Colour | ANSI Code |
|-------|--------|-----------|
| DEBUG | Cyan | `\033[0;36m` |
| INFO | Green | `\033[0;32m` |
| WARNING | Yellow | `\033[0;33m` |
| ERROR | Red | `\033[0;31m` |
| CRITICAL | Bold Red | `\033[1;31m` |

---

### randomisation_utils.py

Generates deterministic, student-specific test parameters for anti-plagiarism purposes.

**Key Principle:** Same student + same assignment = same parameters. Different students = different parameters. This ensures each student has unique test cases whilst maintaining reproducibility for grading.

**Classes:**

| Class | Purpose |
|-------|---------|
| `TestParameters` | Dataclass container for all randomised values |

**Functions:**

| Function | Signature | Purpose |
|----------|-----------|---------|
| `generate_student_seed` | `(student_id, assignment, include_week=True) → int` | Create reproducible seed from student identity |
| `randomise_test_parameters` | `(seed) → TestParameters` | Generate full parameter set from seed |

**TestParameters Fields:**

| Category | Fields | Example Values |
|----------|--------|----------------|
| **Network** | `ip_addresses`, `ports` | `['192.168.47.12']`, `[8080, 3306]` |
| **File System** | `file_sizes`, `file_names`, `directory_names` | `[1024, 2048]`, `['data_alpha.txt']` |
| **Time** | `timestamps`, `cron_hours`, `cron_days` | `[1706612400]`, `[9, 14]`, `[1, 15]` |
| **Process** | `pids`, `signals` | `[1234, 5678]`, `[9, 15, 2]` |
| **Permissions** | `usernames`, `permissions_octal` | `['alice', 'bob']`, `['755', '644']` |
| **Text** | `search_patterns`, `line_numbers` | `['ERROR.*failed']`, `[10, 25, 100]` |
| **General** | `random_strings`, `random_numbers` | `['xK9mP2']`, `[42, 137]` |
| **Metadata** | `seed`, `student_id`, `assignment` | Identity tracking |

**Usage:**

```python
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent.parent.parent / 'lib'))
from randomisation_utils import generate_student_seed, randomise_test_parameters

# Generate seed for a specific student and assignment
seed = generate_student_seed(
    student_id="ion.popescu@stud.ase.ro",
    assignment="SEM03_HW",
    include_week=False  # Use True for weekly variation
)

# Generate all test parameters
params = randomise_test_parameters(seed)

# Use in autograder
print(f"Testing with IP: {params.ip_addresses[0]}")
print(f"Expected port: {params.ports[0]}")
print(f"Test file: {params.file_names[0]}")
print(f"Permission check: {params.permissions_octal[0]}")

# Verify determinism
seed2 = generate_student_seed("ion.popescu@stud.ase.ro", "SEM03_HW", include_week=False)
params2 = randomise_test_parameters(seed2)
assert params.ip_addresses == params2.ip_addresses  # Always True!
```

**Anti-Plagiarism Application:**

```python
# In autograder.py
def grade_student(submission_path: Path, student_id: str) -> dict:
    """Grade with personalised test cases."""
    seed = generate_student_seed(student_id, "SEM04_HW")
    params = randomise_test_parameters(seed)
    
    results = {
        'student': student_id,
        'seed': seed,
        'tests': []
    }
    
    # Test 1: Network configuration
    expected_ip = params.ip_addresses[0]
    actual_ip = extract_ip_from_submission(submission_path)
    results['tests'].append({
        'name': 'IP Configuration',
        'expected': expected_ip,
        'actual': actual_ip,
        'passed': actual_ip == expected_ip
    })
    
    # ... more tests using params
    
    return results
```

---

## Testing

The `lib/` directory includes comprehensive tests:

```bash
# Run all lib tests
cd lib/
pytest -v test_*.py

# With coverage report
pytest -v --cov=. --cov-report=term-missing test_*.py

# Expected output:
# test_logging_utils.py::TestSetupLogging::test_returns_logger_instance PASSED
# test_logging_utils.py::TestSetupLogging::test_logger_has_correct_name PASSED
# test_logging_utils.py::TestSetupLogging::test_no_duplicate_handlers PASSED
# test_randomisation_utils.py::TestGenerateStudentSeed::test_same_student_same_seed PASSED
# test_randomisation_utils.py::TestGenerateStudentSeed::test_different_students_different_seeds PASSED
# ...
# Coverage: 85%+
```

---

## Integration with Seminars

Each seminar imports these utilities with a relative path:

```python
# In SEM01/scripts/python/S01_01_autograder.py
import sys
from pathlib import Path

# Navigate to lib/ from current script location
LIB_PATH = Path(__file__).resolve().parent.parent.parent.parent / 'lib'
sys.path.insert(0, str(LIB_PATH))

from logging_utils import setup_logging
from randomisation_utils import generate_student_seed, randomise_test_parameters

logger = setup_logging(__name__)
```

---

## Language Conventions

- **British English** in all comments, docstrings, and documentation
  - `colour` (not color)
  - `behaviour` (not behavior)
  - `normalise` (not normalize)
  - `organisation` (not organization)
  
- **American English** preserved in Python stdlib references
  - `logging.WARNING` (stdlib constant)
  - `logging.Formatter` (stdlib class)

---

## Changelog

### Version 1.0 (January 2025)
- Initial release with `logging_utils.py` and `randomisation_utils.py`
- Added comprehensive test suite
- Documentation with usage examples

---

*Part of ENos Educational Kit | Operating Systems | ASE Bucharest — CSIE*
