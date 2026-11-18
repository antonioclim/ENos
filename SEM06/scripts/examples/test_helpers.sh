#!/usr/bin/env bash
# Assertion truth is independent of logging; counters count assertions, not tests.
ASSERTIONS_PASSED=0
ASSERTIONS_FAILED=0
assert_result() {
    local truth=$1 message=$2
    if [[ $truth == 0 ]]; then
        ASSERTIONS_PASSED=$((ASSERTIONS_PASSED + 1))
        printf '  PASS: %s\n' "$message"
        return 0
    fi
    ASSERTIONS_FAILED=$((ASSERTIONS_FAILED + 1))
    printf '  FAIL: %s\n' "$message" >&2
    return 1
}
assert_equals() {
    if [[ $1 == "$2" ]]; then assert_result 0 "${3:-Equal values}";
    else assert_result 1 "${3:-Expected [$1], got [$2]}"; fi
}
assert_contains() {
    if [[ $1 == *"$2"* ]]; then assert_result 0 "${3:-Substring present}";
    else assert_result 1 "${3:-Missing substring [$2]}"; fi
}
assert_success() { assert_equals 0 "$1" "${2:-Command succeeded}"; }
assert_file_exists() {
    if [[ -f $1 ]]; then assert_result 0 "${2:-File exists}";
    else assert_result 1 "${2:-Missing file [$1]}"; fi
}
assert_file_contains() {
    if grep -Fq -- "$2" "$1"; then assert_result 0 "${3:-File contains text}";
    else assert_result 1 "${3:-File lacks text or cannot be read}"; fi
}
assert_file_permissions() {
    local actual
    if actual=$(stat -c %a -- "$1"); then assert_equals "$2" "$actual";
    else assert_result 1 "Cannot stat [$1]"; fi
}
assert_directory_not_empty() {
    local output
    if [[ -d $1 ]] && output=$(find "$1" -mindepth 1 -maxdepth 1 -printf x -quit) && [[ $output == x ]]; then
        assert_result 0 'Directory is nonempty'
    else assert_result 1 'Directory is empty or unavailable'; fi
}
assert_number() {
    local operation=$1 value=$2 lower=$3 upper=${4:-0}
    if python3 - "$operation" "$value" "$lower" "$upper" <<'PY'
import math, sys
try:
    value, lower, upper = map(float, sys.argv[2:])
    valid = all(map(math.isfinite, (value, lower, upper)))
    result = {'gt': value > lower, 'lt': value < lower,
              'range': lower <= value <= upper}[sys.argv[1]]
    raise SystemExit(0 if valid and result else 1)
except (ValueError, KeyError):
    raise SystemExit(1)
PY
    then assert_result 0 "Numeric $operation assertion"
    else assert_result 1 "Numeric $operation assertion ($value)"; fi
}
assert_greater_than() { assert_number gt "$1" "$2"; }
assert_less_than() { assert_number lt "$1" "$2"; }
assert_in_range() { assert_number range "$1" "$2" "$3"; }
