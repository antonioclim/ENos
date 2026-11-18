# Automated Tests — Seminar 5

The maintained suite is `test_autograder.py`; `run_all_tests.sh` runs the available test framework and reports missing prerequisites or failures. The historical `test_01_functions.sh` through `test_05_debugging.sh` names were proposed files and are not shipped.

From the repository root:

```bash
python3 -m pytest SEM05/tests
bash SEM05/tests/run_all_tests.sh
```

From `SEM05/`, `make test` is the supported wrapper. Missing pytest/ShellCheck is an unavailable check, not a pass. Running a command shown here does not establish a result until its exit and output have been inspected.

## Meaningful semantic examples

A scope test calls the function in the same shell. Capturing the whole call in `$()` would isolate the variable even if `local` were accidentally removed.

```bash
test_local_scope() {
    local outer_var=outer
    test_func() { local outer_var=inner; printf '%s\n' "$outer_var"; }
    test_func > /dev/null
    [[ $outer_var == outer ]]
}
test_local_scope
```

A strict-mode test inspects both output and the expected failing exit:

```bash
test_errexit() {
    local output status
    if output=$(bash -c 'set -e; false; echo unreachable' 2>&1); then
        return 1
    else
        status=$?
    fi
    [[ $status -eq 1 && -z $output ]]
}
test_errexit
```

A cleanup test uses an owned temporary directory and literal positional arguments:

```bash
test_exit_cleanup() (
    owned=$(mktemp -d) || exit 1
    trap 'rm -rf -- "$owned"' EXIT
    if bash -c 'trap '\''printf done > "$1/marker"'\'' EXIT; exit 7' bash "$owned"; then status=0; else status=$?; fi
    [[ $status -eq 7 && $(cat -- "$owned/marker") == done ]]
)
test_exit_cleanup
```

These small tests exercise specific semantics; they are not a claim of full learning-outcome attainment. The maintained Python suite also tests source contracts, errors and returned diagnostics. Use only synthetic submissions for tests that execute code.

References: [main material](../docs/S05_02_MAIN_MATERIAL.md), [professional template](../scripts/templates/professional_script.sh) and [teaching contract](../docs/TEACHING_CONTRACT.md).
