#!/usr/bin/env bash
# Disposable demonstrations. Source this file or run: bash owned_demos.sh MODE.
# MODE: snapshot, release, processes, descriptors. No service/network actions.
EXAMPLE_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd) || return 1
snapshot_demo() (
    set -euo pipefail
    local work= SNAPSHOT_RESULT= first_snapshot= previous= stage= id=0
    trap '[[ -z ${work:-} ]] || rm -rf -- "$work"' EXIT
    work=$(mktemp -d) || exit 1
    mkdir -- "$work/source" "$work/snapshots"
    local -a history=()
    snapshot() {
        local target
        id=$((id+1)); target="$work/snapshots/version_$id"
        stage=$(mktemp -d "$work/snapshots/.partial.XXXXXX") || return 1
        cp -a -- "$work/source/." "$stage/" || return 1
        mv -- "$stage" "$target" || return 1
        history+=("version_$id"); SNAPSHOT_RESULT="version_$id"
        printf 'Full-copy snapshot: %s\n' "$SNAPSHOT_RESULT"
    }
    restore_snapshot() {
        local version=$1 old
        [[ $version =~ ^version_[1-9][0-9]*$ && -d $work/snapshots/$version ]] || return 2
        stage=$(mktemp -d "$work/.restore.XXXXXX") || return 1
        cp -a -- "$work/snapshots/$version/." "$stage/" || return 1
        old="$work/source.previous"
        [[ ! -e $old ]] || return 1
        mv -- "$work/source" "$old" || return 1
        if ! mv -- "$stage" "$work/source"; then mv -- "$old" "$work/source"; return 1; fi
        rm -rf -- "$old" || return 1
    }
    printf 'Version 1\n' > "$work/source/document.txt"
    snapshot; first_snapshot=$SNAPSHOT_RESULT
    printf 'Version 2\n' > "$work/source/document.txt"
    snapshot
    printf 'Version 3\n' > "$work/source/document.txt"
    snapshot
    printf 'Available: %s\n' "${history[@]}"
    restore_snapshot "$first_snapshot"
    [[ $(cat -- "$work/source/document.txt") == 'Version 1' ]]
    printf 'Restored: %s\n' "$(cat -- "$work/source/document.txt")"
)
release_demo() (
    set -euo pipefail
    local work= version digest previous
    trap '[[ -z ${work:-} ]] || rm -rf -- "$work"' EXIT
    work=$(mktemp -d) || exit 1
    mkdir -- "$work/source" "$work/releases"
    for version in v1 v2; do
        printf 'Application %s\n' "$version" > "$work/source/index.html"
        tar -czf "$work/$version.tar.gz" -C "$work/source" index.html
        digest=$(sha256sum -- "$work/$version.tar.gz"); digest=${digest%% *}
        python3 "$EXAMPLE_DIR/release_reference.py" create "$work/releases" demo "$version" "$work/$version.tar.gz" "$digest" >/dev/null
    done
    python3 "$EXAMPLE_DIR/release_reference.py" activate "$work/releases" demo v1
    printf 'Before: %s\n' "$(readlink -- "$work/releases/demo/current")"
    python3 "$EXAMPLE_DIR/release_reference.py" activate "$work/releases" demo v2
    printf 'After: %s\n' "$(readlink -- "$work/releases/demo/current")"
    previous=$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1]))["previous"])' "$work/releases/demo/transition.json")
    python3 "$EXAMPLE_DIR/release_reference.py" activate "$work/releases" demo "$previous"
    printf 'Rolled back: %s\n' "$(readlink -- "$work/releases/demo/current")"
    cat -- "$work/releases/demo/current/index.html"
)
process_demo() (
    set -euo pipefail
    local -a children=()
    local pid parent command steps=0
    cleanup_children() {
        local child
        for child in "${children[@]}"; do kill -TERM "$child" 2>/dev/null || :; done
        for child in "${children[@]}"; do wait "$child" 2>/dev/null || :; done
    }
    trap cleanup_children EXIT
    trap 'exit 130' INT
    trap 'exit 143' TERM
    for duration in 8 9 10; do sleep "$duration" & children+=("$!"); done
    printf 'Owned children: %s\n' "${children[*]}"
    pid=$BASHPID
    while [[ $pid =~ ^[1-9][0-9]*$ ]] && ((steps < 64)); do
        command=$(ps -p "$pid" -o comm=) || break
        parent=$(ps -p "$pid" -o ppid=) || break
        parent=${parent//[[:space:]]/}
        printf '%s (PID %s; parent %s)\n' "$command" "$pid" "$parent"
        [[ $parent =~ ^[0-9]+$ && $parent != "$pid" ]] || break
        pid=$parent; steps=$((steps+1))
    done
    printf 'Ancestry is a time-dependent observation; disappearing entries are possible.\n'
)
descriptor_demo() (
    set -euo pipefail
    local work=
    trap 'exec 3>&-; [[ -z ${work:-} ]] || rm -rf -- "$work"' EXIT
    work=$(mktemp -d) || exit 1
    exec 3>"$work/custom_output.txt"
    printf 'Hello from FD 3!\n' >&3
    printf 'FD 3 target: %s\n' "$(readlink -- "/proc/$BASHPID/fd/3")"
    cat -- "$work/custom_output.txt"
    exec 4>&1
    exec 1>"$work/stdout_capture.txt"
    printf 'This goes to the owned file\n'
    exec 1>&4
    exec 4>&-
    printf 'Captured: %s\n' "$(cat -- "$work/stdout_capture.txt")"
    exec 3>&-
)
if [[ ${BASH_SOURCE[0]} == "$0" ]]; then
    case ${1:-} in
        snapshot) snapshot_demo ;;
        release) release_demo ;;
        processes) process_demo ;;
        descriptors) descriptor_demo ;;
        -h|--help) printf 'Usage: bash owned_demos.sh {snapshot|release|processes|descriptors}\n' ;;
        *) printf 'Choose a documented demonstration; --help lists modes.\n' >&2; exit 2 ;;
    esac
fi
