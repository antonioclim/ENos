#!/usr/bin/env bash
# Each file is sourced in a fresh Bash process. Trusted test code only.
set -uo pipefail
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd) || exit 2
run_file() {
    source "$SCRIPT_DIR/test_helpers.sh" || return 2
    source "$1" || return 2
    local -a functions=()
    local line name fn before status total=0 passed=0 failed=0
    while IFS= read -r line; do
        name=${line##* }
        [[ $name == test_* ]] && functions+=("$name")
    done < <(declare -F)
    ((${#functions[@]} > 0)) || { echo 'NOT_RUN: no test_ functions' >&2; return 2; }
    for fn in "${functions[@]}"; do
        total=$((total + 1)); before=$ASSERTIONS_FAILED; status=0
        if declare -F setup >/dev/null; then setup || status=1; fi
        if ((status == 0)); then "$fn" || status=1; fi
        if declare -F teardown >/dev/null; then teardown || status=1; fi
        if ((status == 0 && ASSERTIONS_FAILED == before)); then
            passed=$((passed + 1))
        else failed=$((failed + 1)); fi
    done
    printf 'Tests: %s total, %s passed, %s failed; assertions: %s passed, %s failed\n' \
        "$total" "$passed" "$failed" "$ASSERTIONS_PASSED" "$ASSERTIONS_FAILED"
    ((failed == 0))
}
main() {
    if [[ ${1:-} == --file ]]; then
        [[ $# == 2 && -r $2 ]] || return 2
        run_file "$2"; return $?
    fi
    [[ $# -le 1 && -d ${1:-tests} ]] || return 2
    local directory=${1:-tests} plan file rc=0 count=0
    plan=$(mktemp) || return 2
    trap 'rm -f -- "$plan"' RETURN
    find "$directory" -type f -name 'test_*.sh' -print0 > "$plan" || return 2
    while IFS= read -r -d '' file; do
        count=$((count + 1))
        bash "${BASH_SOURCE[0]}" --file "$file" || rc=1
    done < "$plan"
    ((count > 0)) || { echo 'NOT_RUN: no test files' >&2; return 2; }
    return "$rc"
}
if [[ ${BASH_SOURCE[0]} == "$0" ]]; then main "$@"; fi
