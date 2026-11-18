# Automated Tests - Seminar 2

> **Topic:** Control Operators, I/O Redirection, Pipes, Loops

---

## Test Summary

| Test | Description | Status |
|------|-------------|--------|
| `test_01_operators.sh` | Operators (&&, \|\|, ;, &) | 🔜 TODO |
| `test_02_redirection.sh` | stdin/stdout/stderr, >, >>, < | 🔜 TODO |
| `test_03_pipes.sh` | Pipelines and filters | 🔜 TODO |
| `test_04_loops.sh` | for, while, until, select | 🔜 TODO |
| `run_all_tests.sh` | Runner for all tests | 🔜 TODO |

---

## Usage

```bash
# Run the shipped Python unit suite from SEM02/.
python3 -m pytest tests/test_autograder.py

# The shell tests listed above are TODO examples, not distributed executables.
```

---

## Test Examples

### Control Operators
```bash
test_and_operator() {
    local result
    result=$(true && echo "yes" || echo "no")
    [[ "$result" == "yes" ]] && pass "AND operator" || fail "AND operator"
}

test_or_operator() {
    local result
    result=$(false || echo "fallback")
    [[ "$result" == "fallback" ]] && pass "OR operator" || fail "OR operator"
}
```

### Redirection
```bash
test_stdout_redirect() {
    local output
    output=$(mktemp "${TMPDIR:-/tmp}/enos-redirection.XXXXXX") || return 1
    printf 'test\n' > "$output"
    [[ "$(cat "$output")" == "test" ]] && pass "stdout >" || fail "stdout >"
    rm -f -- "$output"
}

test_stderr_redirect() {
    ls /nonexistent 2>/dev/null
    [[ $? -ne 0 ]] && pass "stderr 2>" || fail "stderr 2>"
}
```

---

## Tested Competencies (Bloom)

| Level | Competency | Covered |
|-------|------------|---------|
| 1-Knowledge | Operator syntax | ⬜ |
| 2-Comprehension | Execution order | ⬜ |
| 3-Application | Building pipelines | ⬜ |
| 4-Analysis | Debugging redirections | ⬜ |

---

## References

- `../docs/S02_02_MAIN_MATERIAL.md`
- `../docs/S02_06_SPRINT_EXERCISES.md`
- `../scripts/demo/`
