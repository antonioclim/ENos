# ROso — Operating Systems: Complete Educational Kit

```
┌─────────────────────────────────────────────────────────────────────────────────────────┐
│  🐧 LINUX    Ubuntu 24.04+    │  📋 BASH 5.0+   │  🐍 PYTHON 3.12+  │  📦 GIT 2.40+    │
├─────────────────────────────────────────────────────────────────────────────────────────┤
│  LICENCE         RESTRICTIVE    │  UNITS              14      │  EST. HOURS         60+   │
│  VERSION              5.3.1     │  SEMINARS            6      │  PROJECTS           23    │
│  STATUS              ACTIVE     │  PNG DIAGRAMS       27      │  SCRIPTS          180+    │
└─────────────────────────────────────────────────────────────────────────────────────────┘
```

**by ing. dr. Antonio Clim** | Bucharest University of Economic Studies — CSIE  
Year I, Semester 2 | 2017-2030

---

## What's New in v5.3

- ✅ **Print stylesheets** for HTML presentations (offline handouts)
- ✅ **Link checking** in CI pipeline (automated validation)
- ✅ **Expanded test suite** for shared utilities
- ✅ **lib/ documentation** with usage examples

---

## What You Will Find Here

This kit contains the materials for the Operating Systems course: 14 course units, 6 seminars with practical exercises and 23 projects at three difficulty levels. Everything is structured so you can work independently or in the laboratory.

Bash seems simple at first glance — short commands, instant output — but when you try to automate something real, you suddenly discover that `$?` does not do what you think, that pipes lose variables and that a misplaced space in `[ $var ]` breaks your entire script. I have been through this with every generation of students, and the kit reflects exactly the problems I have seen in practice.

An observation after several years of teaching: students who take notes of their commands and output as they go reach working solutions much faster. Not because they are cleverer, but because they can return to what worked and compare it with what does not. It is a trivial practice but surprisingly effective.

---

## Quick Navigation

| Looking for... | Go to... |
|----------------|----------|
| Setup guide | [Step 0: Choose Your Installation](#step-0-choose-your-installation-option) |
| Seminar materials | `SEM01/` through `SEM06/` |
| Projects | `04_PROJECTS/` |
| Lecture support | `05_LECTURES/` |
| Quick reference | `NAVIGATION.md` |
| Shared utilities | `lib/README.md` |
| Developer tools | [Developer Tools](#developer-tools) |

---

[... existing content unchanged ...]

---

# PART VII: DEVELOPER TOOLS

This section documents the shared utilities and automation scripts available in the kit.

---

## Shared Utilities (lib/)

The `lib/` directory contains Python modules used across all seminars:

### logging_utils.py

Provides consistent, coloured logging across all Python scripts.

```python
from logging_utils import setup_logging

logger = setup_logging(__name__)
logger.info("Processing started")
logger.warning("Low disk space")
logger.error("File not found")
```

### randomisation_utils.py

Generates deterministic, student-specific test parameters for anti-plagiarism.

```python
from randomisation_utils import generate_student_seed, randomise_test_parameters

seed = generate_student_seed("student@ase.ro", "SEM03_HW")
params = randomise_test_parameters(seed)
# Same student + assignment = same parameters (reproducible)
```

See `lib/README.md` for complete documentation.

---

## Automation Scripts (scripts/)

### check_links.sh

Validates documentation links across the entire kit.

```bash
# Check internal links only (fast)
./scripts/check_links.sh

# Check all links including external URLs (slow)
./scripts/check_links.sh --external

# Show help
./scripts/check_links.sh --help
```

**Requirements:** For best results, install [lychee](https://github.com/lycheeverse/lychee):
```bash
cargo install lychee
# or
brew install lychee
```

### add_print_styles.sh

Injects print stylesheets into HTML presentations for offline handouts.

```bash
# Preview changes
./scripts/add_print_styles.sh --dry-run

# Apply changes
./scripts/add_print_styles.sh
```

After running, presentations can be printed cleanly from browser (Ctrl+P / Cmd+P).

---

## CI Pipeline

Each seminar includes a GitHub Actions CI configuration (`ci/github_actions.yml`) with:

| Job | Purpose |
|-----|---------|
| `lint-bash` | ShellCheck on all Bash scripts |
| `lint-python` | Ruff on all Python code |
| `validate-yaml` | Quiz and config validation |
| `ai-check` | AI fingerprint detection |
| `link-check` | Documentation link validation |
| `test` | pytest with coverage threshold |
| `structure-check` | Directory structure validation |

Run locally with:
```bash
cd SEM01
make test        # Run tests
make lint        # Run linters
make ai-check    # Check for AI patterns
```

---

## Testing

### Running Tests

```bash
# Run all lib tests
cd lib/
pytest -v test_*.py

# Run with coverage
pytest -v --cov=. --cov-report=term-missing

# Run seminar-specific tests
cd SEM01/tests/
pytest -v
```

### Test Coverage

| Component | Coverage Target |
|-----------|-----------------|
| lib/ | >80% |
| Autograders | >75% |
| Quiz generators | >70% |

---

[... existing content continues from PART VIII onwards ...]

---

## Annex E: Kit Statistics

| Category | Quantity | Details |
|-----------|-----------|---------|
| Theoretical courses | 14 | SO_curs01 to SO_curs14 |
| Practical seminars | 6 | SEM01 to SEM06 |
| Semester projects | 23 | 5 EASY + 15 MEDIUM + 3 ADVANCED |
| Markdown files | 363 | Documentation and guides |
| HTML presentations | 71 | Interactive slides |
| PNG diagrams | 27 | In 00_SUPPLEMENTARY/ |
| SVG diagrams | 26 | Vector graphics |
| Python scripts | 62 | Autograders, tools, tests |
| Bash scripts | 116 | Demos, utilities, validators |
| Test files | 25+ | pytest and shell tests |
| Estimated hours (total) | 60+ | For complete coverage |

---

## Annex F: Changelog (deprecated)

### Version 5.3.1 (January 2026)

**New Features:**
- Added print stylesheets to all HTML presentations
- Added link checking to CI pipeline
- Expanded test coverage for lib/ utilities
- Added lib/README.md documentation

**Improvements:**
- Updated CI to version 2.2 with link-check job
- Standardised script documentation
- Enhanced test templates

**Files Added:**
- `lib/README.md`
- `lib/test_logging_utils.py`
- `lib/test_randomisation_utils.py`
- `scripts/check_links.sh`
- `scripts/add_print_styles.sh`
- `assets/css/print.css`
- `SEM01/tests/test_ai_fingerprint.py`

### Version 5.3.1 (January 2026)

- Initial FAZA 5-6 release
- Complete restructure with 14 weeks
- AI-aware exercises and anti-plagiarism infrastructure

---

*Kit updated: January 2026*  
*Version: 5.3.1*
*Tested on: Ubuntu 24.04 LTS, WSL2 with Ubuntu 22.04/24.04*  
*Feedback and errors: through GITHUB issue tracker*

---

**ing. dr. Antonio Clim**  
Assistant Lecturer (fixed-term) | Bucharest University of Economic Studies — CSIE
