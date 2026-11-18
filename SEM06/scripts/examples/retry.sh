#!/usr/bin/env bash
# External argv command only; total timeout also includes retry delays.
retry() {
    [[ $# -ge 4 ]] || return 2
    local attempts=$1 delay=$2 backoff=$3 attempt=1 rc=1; shift 3
    [[ $attempts =~ ^[1-9][0-9]?$|^100$ && $delay =~ ^[0-9]{1,4}$ && $backoff =~ ^[1-9]$|^10$ ]] || return 2
    delay=$((10#$delay)); ((delay <= 3600)) || return 2
    while ((attempt <= attempts)); do
        if "$@"; then return 0; else rc=$?; fi
        if ((attempt < attempts)); then
            sleep "$delay" || return 1
            delay=$((delay * backoff)); ((delay <= 3600)) || delay=3600
        fi
        attempt=$((attempt + 1))
    done
    return "$rc"
}
retry_with_timeout() {
    [[ $# -ge 5 && $1 =~ ^[1-9][0-9]*([.][0-9]+)?$ ]] || return 2
    local duration=$1 source_path; shift
    source_path=$(realpath -- "${BASH_SOURCE[0]}") || return 2
    timeout --signal=TERM --kill-after=2 "$duration" bash -c \
        'source "$1"; shift; retry "$@"' _ "$source_path" "$@"
}
if [[ ${BASH_SOURCE[0]} == "$0" ]]; then retry "$@"; fi
