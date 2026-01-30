# Automated Tests - Seminar 1

> **Topic:** Shell Basics, Quoting, Variables, FHS, Globbing

---

## Test Summary

| Test | Description | Status |
|------|-------------|--------|
| `test_01_shell_basics.sh` | Fundamental commands (ls, cd, pwd) | 🔜 TODO |
| `test_02_quoting.sh` | Single/double quotes, escape | 🔜 TODO |
| `test_03_variables.sh` | Shell and environment variables | 🔜 TODO |
| `test_04_globbing.sh` | Wildcards (*, ?, [], {}) | 🔜 TODO |
| `run_all_tests.sh` | Runner for all tests | 🔜 TODO |

---

## Usage

```bash
# Run all tests
./run_all_tests.sh

# Run individual test
./test_01_shell_basics.sh

# Check syntax
bash -n test_*.sh
```

---

## Test Template

```bash
#!/bin/bash
# test_XX_description.sh
set -euo pipefail

pass() { echo "✅ PASS: $1"; ((PASSED++)); }
fail() { echo "❌ FAIL: $1"; ((FAILED++)); }

PASSED=0 FAILED=0

test_example() {
    local result
    result=$(echo "test")
    [[ "$result" == "test" ]] && pass "Echo works" || fail "Echo failed"
}

test_example
echo "═══ Result: $PASSED passed, $FAILED failed ═══"
```

---

## Competencies Tested (Bloom)

| Level | Competency | Covered |
|-------|------------|---------|
| 1-Knowledge | Basic commands | ⬜ |
| 2-Comprehension | Quote differences | ⬜ |
| 3-Application | FHS navigation | ⬜ |
| 4-Analysis | Variable debugging | ⬜ |

---

## References

- `../docs/S01_02_MAIN_MATERIAL.md`
- `../docs/S01_06_SPRINT_EXERCISES.md`
- `../scripts/demo/`
