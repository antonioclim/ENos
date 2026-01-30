# Automated Tests - Seminar 5

> **Topic:** Functions, Arrays, Robust Scripting, Error Handling

---

## Test Summary

| Test | Description | Status |
|------|-------------|--------|
| `test_01_functions.sh` | Functions with local and return | 🔜 TODO |
| `test_02_arrays_indexed.sh` | Indexed arrays | 🔜 TODO |
| `test_03_arrays_assoc.sh` | Associative arrays (declare -A) | 🔜 TODO |
| `test_04_error_handling.sh` | set -euo pipefail, trap | 🔜 TODO |
| `test_05_debugging.sh` | set -x, PS4, debugging | 🔜 TODO |
| `run_all_tests.sh` | Runner for all tests | 🔜 TODO |

---

## Usage

```bash
# Run all tests
./run_all_tests.sh

# Run individual test
./test_01_functions.sh

# Check with shellcheck (MANDATORY!)
shellcheck test_*.sh
```

---

## Test Examples

### Functions with local
```bash
test_local_scope() {
    outer_var="outer"
    
    test_func() {
        local outer_var="inner"
        echo "$outer_var"
    }
    
    local result
    result=$(test_func)
    
    [[ "$result" == "inner" && "$outer_var" == "outer" ]] \
        && pass "local scope" || fail "local scope"
}
```

### Associative Arrays
```bash
test_associative_array() {
    declare -A config
    config[host]="localhost"
    config[port]="8080"
    
    [[ "${config[port]}" == "8080" ]] \
        && pass "associative array" || fail "associative array"
}
```

### Error Handling
```bash
test_set_e_behavior() {
    # Script with set -e should stop at first error
    local output
    output=$(bash -c 'set -e; false; echo "should not print"' 2>&1) || true
    
    [[ -z "$output" ]] \
        && pass "set -e stops on error" || fail "set -e"
}

test_trap_exit() {
    local cleanup_file="/tmp/cleanup_test_$$"
    
    bash -c "
        trap 'touch $cleanup_file' EXIT
        exit 0
    "
    
    [[ -f "$cleanup_file" ]] \
        && pass "trap EXIT executed" || fail "trap EXIT"
    rm -f "$cleanup_file"
}
```

---

## Competencies Tested (Bloom)

| Level | Competency | Covered |
|-------|------------|---------|
| 1-Knowledge | Function/array syntax | ⬜ |
| 2-Comprehension | Variable scope | ⬜ |
| 3-Application | Error handling patterns | ⬜ |
| 4-Analysis | Script debugging | ⬜ |
| 5-Synthesis | Professional template | ⬜ |

---

## Mandatory Pre-Submission Checks

```bash
# Shellcheck must pass without errors!
shellcheck -x test_*.sh

# All tests must run
./run_all_tests.sh
```

---

## References


Specifically: `../docs/S05_02_MAIN_MATERIAL.md`. `../scripts/templates/professional_script.sh`. And `../homework/S05_01_HOMEWORK.md`. Direct.
