# Automated Tests — Seminar 04
## Text Processing: Regex, GREP, SED, AWK

> Operating Systems | ASE Bucharest - CSIE  
> Documentation for the automated test suite  
> Version: 1.0 | January 2025

---

## General Overview

This directory contains automated tests for verifying knowledge and functionality of scripts from Seminar 04.

## Test Structure

```
tests/
├── README.md                    # This file
├── run_all_tests.sh            # Main runner for all tests
├── test_01_regex_basics.sh     # Tests for regular expressions
├── test_02_grep_mastery.sh     # Tests for grep command
├── test_03_sed_transforms.sh   # Tests for sed command
└── test_04_awk_analysis.sh     # Tests for awk command
```

---

## Running Tests

### Complete run (all tests)
```bash
# From the SEM04/ directory
bash tests/run_all_tests.sh

# Or with Make
make test
```

### Running individual tests
```bash
# Only regex
bash tests/test_01_regex_basics.sh

# Only grep
bash tests/test_02_grep_mastery.sh

# Only sed
bash tests/test_03_sed_transforms.sh

# Only awk
bash tests/test_04_awk_analysis.sh
```

### With Make (recommended)
```bash
make test-regex
make test-grep
make test-sed
make test-awk
```

---

## Coverage per Test File

### test_01_regex_basics.sh
| Test | Description | LO |
|------|-------------|-----|
| T1.1 | Basic metacharacters (. ^ $ *) | LO1 |
| T1.2 | Character classes [abc] [^abc] | LO1 |
| T1.3 | Quantifiers (+ ? {n,m}) | LO1 |
| T1.4 | BRE vs ERE differences | LO1 |
| T1.5 | Escaping special characters | LO1 |
| T1.6 | Anchors and word boundaries | LO1 |

### test_02_grep_mastery.sh
| Test | Description | LO |
|------|-------------|-----|
| T2.1 | grep -i (case insensitive) | LO2 |
| T2.2 | grep -v (invert match) | LO2 |
| T2.3 | grep -c (count) | LO2 |
| T2.4 | grep -o (only matching) | LO2 |
| T2.5 | grep -E (extended regex) | LO2 |
| T2.6 | grep -r (recursive) | LO2 |
| T2.7 | grep with multiple patterns | LO2, LO5 |

### test_03_sed_transforms.sh
| Test | Description | LO |
|------|-------------|-----|
| T3.1 | sed s/// (simple substitution) | LO3 |
| T3.2 | sed s///g (global) | LO3 |
| T3.3 | sed d (delete) | LO3 |
| T3.4 | sed p (print) | LO3 |
| T3.5 | sed with addressing (lines, range) | LO3 |
| T3.6 | sed -i (in-place edit) | LO3 |
| T3.7 | sed with back-references | LO3 |

### test_04_awk_analysis.sh
| Test | Description | LO |
|------|-------------|-----|
| T4.1 | awk print $1 $2 (fields) | LO4 |
| T4.2 | awk -F (field separator) | LO4 |
| T4.3 | awk NR NF (line/field count) | LO4 |
| T4.4 | awk BEGIN END | LO4 |
| T4.5 | awk calculations (sum, avg) | LO4 |
| T4.6 | awk pattern matching | LO4 |
| T4.7 | awk associative arrays | LO4 |

---

## Output Format

The tests use a standardised format for output:

```
═══════════════════════════════════════════════════════════════════════════════
  TEST SUITE: [Category name]
═══════════════════════════════════════════════════════════════════════════════

[T1.1] Short test description
  ✓ PASSED                                                          [0.01s]

[T1.2] Another test
  ✗ FAILED: Expected "abc", got "xyz"                               [0.02s]

───────────────────────────────────────────────────────────────────────────────
  RESULTS: 5/6 passed (83%)
───────────────────────────────────────────────────────────────────────────────
```

---

## Dependencies

The tests require:
- Bash 4.0+
- Standard commands: grep, sed, awk, cat, echo
- Test files from `resources/sample_data/`

### Verify dependencies
```bash
# Check versions
bash --version
grep --version
sed --version
awk --version
```

---

## Adding New Tests

To add a new test:

1. Edit the corresponding test file
2. Use the helper function `run_test`:

```bash
run_test "T1.X" "Test description" \
    "command_to_test" \
    "expected_output"
```

3. Or for complex tests:

```bash
test_complex() {
    local result
    result=$(complex_command)
    
    if [[ "$result" == "expected" ]]; then
        echo "  ✓ PASSED"
        return 0
    else
        echo "  ✗ FAILED: Got '$result'"
        return 1
    fi
}
```

---

## CI Integration

Tests are run automatically in GitHub Actions on each push.

File: `ci/github_actions.yml`

Relevant job: `run-tests`

---

## Troubleshooting

### Tests fail with "command not found"
```bash
# Check PATH
echo $PATH

# Check if command exists
which grep sed awk
```

### Tests fail with "Permission denied"
```bash
# Make scripts executable
chmod +x tests/*.sh
```

### Newline differences (Windows vs Linux)
```bash
# Convert to Unix format
dos2unix tests/*.sh
```

### Sample data missing
```bash
# Run the setup
bash scripts/bash/S04_01_setup_seminar.sh
```

---

## Contact

For test issues: Open an issue in the GitHub repository

---

*Test documentation — Seminar 04: Text Processing*
