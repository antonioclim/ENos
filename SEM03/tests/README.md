# Automated Tests — Seminar 03

> **Topic:** find/xargs, getopts, Unix Permissions, CRON  
> **Course:** Operating Systems | Bucharest UES - CSIE

---

## Test Summary

| Category | Description | Status |
|----------|-------------|--------|
| File structure | Verifies presence of mandatory files | ✅ Implemented |
| Bash syntax | Validates .sh script syntax | ✅ Implemented |
| Python syntax | Validates .py script syntax | ✅ Implemented |
| YAML/JSON data | Verifies quiz.yaml and quiz_lms.json | ✅ Implemented |
| Naming consistency | Verifies absence of incorrect references | ✅ Implemented |
| Code quality | Verifies shebang, strict mode | ✅ Implemented |
| AI patterns | Detects AI signal words | ✅ Implemented |

---

## Usage

```bash
# Run all tests
bash teste/run_all_tests.sh

# Or from root directory with Make
make test

# Quick syntax check
make lint
```

---

## Test Structure

```
teste/
├── README.md              # This file
└── run_all_tests.sh       # Main runner for all tests
```

### Test categories in run_all_tests.sh:

1. **test_structure()** — Verifies existence of mandatory files and directories
2. **test_bash_syntax()** — Runs `bash -n` on all .sh scripts
3. **test_python_syntax()** — Runs `python -m py_compile` on all .py files
4. **test_data_files()** — Validates YAML and JSON for quizzes
5. **test_naming_consistency()** — Detects incorrect references (e.g., "Seminar 3")
6. **test_code_quality()** — Verifies best practices (shebang, strict mode)
7. **test_ai_patterns()** — Counts AI signal words

---

## Example Output

```
═══════════════════════════════════════════════════════════════
        TESTS SEMINAR 03: System Administration
═══════════════════════════════════════════════════════════════

─── File Structure ───
  README.md exists                                [PASS]
  Makefile exists                                 [PASS]
  formative/quiz.yaml exists                      [PASS]
  ...

─── Bash Syntax ───
  Syntax: S03_01_setup_seminar.sh                 [PASS]
  Syntax: S03_02_quiz_interactiv.sh               [PASS]
  ...

═══════════════════════════════════════════════════════════════
                         SUMMARY
═══════════════════════════════════════════════════════════════
  ✓ Passed:  25
  ✗ Failed:  0
  ○ Skipped: 2

  Score: 100% (25/25)
═══════════════════════════════════════════════════════════════
```

---

## Adding New Tests

To add new tests, edit `run_all_tests.sh` and add functions:

```bash
test_my_category() {
    print_section "My Category"
    
    run_test "Test name" "test_command"
    run_test "Another test" "[[ -f 'file.txt' ]]"
}
```

Then call the function in `main()`:

```bash
main() {
    ...
    test_my_category
    ...
}
```

---

## CI/CD Integration

Tests are integrated into GitHub Actions (see `ci/github_actions.yml`).

The pipeline runs automatically on each push and includes:
1. Linting (shellcheck + ruff)
2. Structure validation
3. Test execution
4. AI patterns verification

---

*Seminar 03 | Operating Systems | Bucharest UES - CSIE*
