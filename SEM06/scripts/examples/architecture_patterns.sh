#!/usr/bin/env bash
# Runnable teaching examples; source this file. Bash 4.4+.

create_backup_job() {
    local target=$1 name=$2 source=$3 destination=$4
    [[ $target =~ ^job_[A-Za-z0-9_]+$ ]] || return 2
    [[ $(declare -p "$target" 2>/dev/null) == 'declare -A '* ]] || return 2
    local -n output_job=$target
    output_job=([name]="$name" [source]="$source" [destination]="$destination"
                [created_at]="$(date -Iseconds)" [status]=pending [type]=full)
}

declare -a EVENT_NAMES=() EVENT_CALLBACKS=()
on_event() {
    [[ $# == 2 && -n $1 && $2 =~ ^[A-Za-z_][A-Za-z0-9_]*$ ]] || return 2
    declare -F "$2" >/dev/null || return 2
    EVENT_NAMES+=("$1"); EVENT_CALLBACKS+=("$2")
}
emit_event() {
    local event=$1 i failures=0; shift
    # Capture the boundary: registrations added by handlers run on the next event.
    local end=${#EVENT_NAMES[@]}
    for ((i=0; i<end; i++)); do
        if [[ ${EVENT_NAMES[i]} == "$event" ]]; then
            "${EVENT_CALLBACKS[i]}" "$@" || failures=$((failures + 1))
        fi
    done
    ((failures == 0))
}

# Store argv boundaries, never reconstruct shell code from data.
declare -a COMMAND_START=() COMMAND_LENGTH=() COMMAND_ARGS=()
execute_command() {
    (($# > 0)) || return 2
    COMMAND_START+=("${#COMMAND_ARGS[@]}"); COMMAND_LENGTH+=("$#")
    COMMAND_ARGS+=("$@")
    "$@"
}
replay_commands() {
    local count=${1:-${#COMMAND_START[@]}} i start length rc=0
    [[ $count =~ ^[0-9]+$ && ${#count} -le 8 ]] || return 2
    count=$((10#$count))
    local end=${#COMMAND_START[@]}
    ((count <= end)) || return 2
    for ((i=end-count; i<end; i++)); do
        start=${COMMAND_START[i]}; length=${COMMAND_LENGTH[i]}
        if "${COMMAND_ARGS[@]:start:length}"; then :; else rc=$?; return "$rc"; fi
    done
}

log_message() {
    local level=$1; shift
    [[ ${LOG_LEVEL:-INFO} == DEBUG || $level != DEBUG ]] || return 0
    printf '[%s] %s\n' "$level" "$*" >&2 || return 1
    if [[ -n ${LOG_FILE:-} ]]; then
        printf '[%s] %s\n' "$level" "$*" >> "$LOG_FILE" || return 1
    fi
    return 0
}
