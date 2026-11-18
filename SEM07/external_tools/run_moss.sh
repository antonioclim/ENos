#!/usr/bin/env bash
# Build a reviewable MOSS command; upload requires an explicit --send invocation.
set -euo pipefail
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
KIT_ROOT=$(cd -- "$SCRIPT_DIR/../.." && pwd)
usage() {
    cat <<'EOF'
Usage: run_moss.sh SEMnn LANGUAGE EXTENSION [--submissions DIR] [--base DIR]
                   [--client FILE] [--send]
Supported adapter languages: c cc java python perl javascript.
Bash is unsupported. No language is silently substituted. Default: print plan only.
--send performs an external upload and needs the relevant prior authorisation.
The account-configured official client is not bundled; see MOSS_JPLAG_GUIDE.md.
EOF
}
[[ ${1:-} != -h && ${1:-} != --help ]] || { usage; exit 0; }
[[ $# -ge 3 ]] || { usage >&2; exit 2; }
SEMINAR=$1 LANGUAGE=$2 EXTENSION=$3
shift 3
[[ $SEMINAR =~ ^SEM0[1-7]$ && $EXTENSION =~ ^[[:alnum:]]+$ ]] || { printf 'Invalid seminar/extension\n' >&2; exit 2; }
case $LANGUAGE in c|cc|java|python|perl|javascript) ;; *) printf 'Unsupported language: %s\n' "$LANGUAGE" >&2; exit 2;; esac
SUBMISSIONS_DIR='' STARTER_DIR='' MOSS_SCRIPT="$SCRIPT_DIR/moss.pl" SEND=false
while (($#)); do
    case $1 in
        --send) SEND=true; shift;;
        --submissions|--base|--client)
            [[ $# -ge 2 && -n $2 ]] || { printf 'Missing argument: %s\n' "$1" >&2; exit 2; }
            case $1 in --submissions) SUBMISSIONS_DIR=$2;; --base) STARTER_DIR=$2;; --client) MOSS_SCRIPT=$2;; esac
            shift 2;;
        *) printf 'Unknown option: %s\n' "$1" >&2; exit 2;;
    esac
done
if [[ -z $SUBMISSIONS_DIR ]]; then
    for candidate in "$KIT_ROOT/$SEMINAR/submissions" "$KIT_ROOT/$SEMINAR/homework/submissions"; do
        if [[ -d $candidate ]]; then SUBMISSIONS_DIR=$candidate; break; fi
    done
fi
[[ -d $SUBMISSIONS_DIR ]] || { printf 'Submissions directory is missing\n' >&2; exit 1; }
SUBMISSIONS_DIR=$(realpath -- "$SUBMISSIONS_DIR")
work=$(mktemp -d)
trap 'rm -rf -- "$work"' EXIT
find "$SUBMISSIONS_DIR" -type f -name "*.$EXTENSION" -print0 > "$work/files" || exit 1
mapfile -d '' -t files < "$work/files"
((${#files[@]} >= 2)) || { printf 'At least two files are required\n' >&2; exit 1; }
command=(perl "$MOSS_SCRIPT" -l "$LANGUAGE" -d)
if [[ -n $STARTER_DIR ]]; then
    [[ -d $STARTER_DIR ]] || { printf 'Base directory is missing\n' >&2; exit 1; }
    find "$(realpath -- "$STARTER_DIR")" -type f -name "*.$EXTENSION" -print0 > "$work/base" || exit 1
    while IFS= read -r -d '' path; do command+=(-b "$path"); done < "$work/base"
fi
command+=("${files[@]}")
printf 'Plan (%d files; directory grouping must match submissions):\n' "${#files[@]}"
printf '%q ' "${command[@]}"; printf '\n'
if [[ $SEND == true ]]; then
    [[ -f $MOSS_SCRIPT ]] || { printf 'Official account-configured client is missing\n' >&2; exit 1; }
    command -v perl >/dev/null || { printf 'Perl is unavailable\n' >&2; exit 1; }
    command -v timeout >/dev/null || { printf 'timeout is unavailable\n' >&2; exit 1; }
    timeout --signal=TERM --kill-after=5 120 "${command[@]}"
else
    printf 'PLAN_ONLY: no client, registration or upload was executed.\n'
fi
