#!/usr/bin/env bash
# Sourceable Bash4.4+ teaching primitives; no action is performed when sourced.
parse_args() {
    ARGS=(); VERBOSE=false; CONFIG_FILE=''; OUTPUT_DIR=''
    while (($#)); do
        case $1 in
            -h|--help) usage; return 10;;
            -v|--verbose) VERBOSE=true; shift;;
            -c|--config|-o|--output)
                (($# >= 2)) && [[ -n $2 ]] || { printf 'Missing option value: %s\n' "$1" >&2; return 2; }
                case $1 in -c|--config) CONFIG_FILE=$2;; *) OUTPUT_DIR=$2;; esac
                shift 2;;
            --) shift; ARGS+=("$@"); break;;
            -*) printf 'Unknown option: %s\n' "$1" >&2; return 2;;
            *) ARGS+=("$1"); shift;;
        esac
    done
}
load_config() {
    local file=${1:?configuration file required} line key value
    local -A seen=()
    [[ -f $file && -r $file ]] || return 1
    while IFS= read -r line || [[ -n $line ]]; do
        line=${line%$'\r'}
        [[ $line =~ ^[[:space:]]*($|#) ]] && continue
        [[ $line == *=* ]] || { printf 'Expected KEY=value\n' >&2; return 2; }
        key=${line%%=*}; value=${line#*=}
        key=${key#"${key%%[![:space:]]*}"}; key=${key%"${key##*[![:space:]]}"}
        [[ $key =~ ^[A-Z][A-Z0-9_]*$ ]] || return 2
        [[ ! ${seen[$key]+present} ]] || { printf 'Duplicate key: %s\n' "$key" >&2; return 2; }
        seen[$key]=1
        value=${value#"${value%%[![:space:]]*}"}; value=${value%"${value##*[![:space:]]}"}
        case $value in
            \"*) [[ ${#value} -ge 2 && ${value: -1} == '"' ]] || return 2; value=${value:1:${#value}-2};;
            \') return 2;;
            \'*) [[ ${#value} -ge 2 && ${value: -1} == "'" ]] || return 2; value=${value:1:${#value}-2};;
        esac
        # Literal value: no expansion, escape processing or shell evaluation.
        declare -g "CONFIG_${key}=$value"
    done < "$file"
}
acquire_lock() {
    [[ -n ${LOCK_FILE:-} ]] || return 2
    exec {LOCK_FD}>"$LOCK_FILE" || return 1
    if ! flock -n "$LOCK_FD"; then
        exec {LOCK_FD}>&-
        unset LOCK_FD
        return 1
    fi
}
release_lock() {
    if [[ -n ${LOCK_FD:-} ]]; then exec {LOCK_FD}>&-; unset LOCK_FD; fi
    # Keep the stable inode: unlinking could let a third process bypass the lock.
    return 0
}
log() {
    local level=${1:-}; shift || return 2
    local -A levels=([DEBUG]=0 [INFO]=1 [WARN]=2 [ERROR]=3)
    local configured=${LOG_LEVEL:-INFO}
    [[ -n $level && -n $configured ]] || return 2
    [[ ${levels[$level]+set} && ${levels[$configured]+set} ]] || return 2
    (( levels[$level] >= levels[$configured] )) || return 0
    printf '[%s] %s\n' "$level" "$*" >&2
}
TESTS_RUN=0 TESTS_PASSED=0 TESTS_FAILED=0
assert_equals() {
    (( $# >= 2 )) || { printf 'assert_equals requires expected and actual values\n' >&2; return 2; }
    TESTS_RUN=$((TESTS_RUN + 1))
    if [[ $1 == $2 ]]; then
        TESTS_PASSED=$((TESTS_PASSED + 1)); return 0
    fi
    TESTS_FAILED=$((TESTS_FAILED + 1))
    printf 'FAIL %s: expected=%q actual=%q\n' "${3:-comparison}" "$1" "${2-}" >&2
    return 1
}
assert_true() {
    local message=${1:?message}; shift
    TESTS_RUN=$((TESTS_RUN + 1))
    if "$@"; then TESTS_PASSED=$((TESTS_PASSED + 1)); return 0; fi
    TESTS_FAILED=$((TESTS_FAILED + 1)); printf 'FAIL: %s\n' "$message" >&2; return 1
}
print_summary() {
    printf 'Total=%s Passed=%s Failed=%s\n' "$TESTS_RUN" "$TESTS_PASSED" "$TESTS_FAILED"
    (( TESTS_RUN > 0 && TESTS_FAILED == 0 ))
}
