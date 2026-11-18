# Automated Tests - Seminar 1

> **Topic:** Shell Basics, Quoting, Variables, FHS, Globbing

---

## Shipped tests and launch routes

The distributed Python suites are `test_quiz.py` and `test_ai_fingerprint.py`.
From the repository root, run:

```bash
python3 -m pytest --import-mode=importlib SEM01/tests
# Equivalent wrapper (requires pytest and the project Python dependencies):
bash SEM01/tests/run_all_tests.sh
```

`test_01_shell_basics.sh`, `test_02_quoting.sh`, `test_03_variables.sh` and
`test_04_globbing.sh` remain proposed TODO files. They are not shipped and are not
reported as successful tests by the wrapper. The example below is a template for
future Bash tests, not an additional installed suite.

---

## Test Template

```bash
#!/bin/bash
# test_XX_description.sh
set -euo pipefail

pass() { echo "✅ PASS: $1"; PASSED=$((PASSED+1)); return 0; }
fail() { echo "❌ FAIL: $1"; FAILED=$((FAILED+1)); return 0; }

PASSED=0 FAILED=0

test_example() {
    local result
    result=$(echo "test")
    if [[ "$result" == "test" ]]; then pass "Echo works"; else fail "Echo failed"; fi
}

test_example
echo "═══ Result: $PASSED passed, $FAILED failed ═══"
(( FAILED == 0 ))
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
