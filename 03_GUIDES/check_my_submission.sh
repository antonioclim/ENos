#!/usr/bin/env bash
# Operating Systems 2023–2027 — Revolvix/github.com
# Local format preflight. This command does not authenticate or submit a file.
set -euo pipefail
if ! command -v python3 >/dev/null 2>&1; then
    printf '%s\n' 'Python 3 is required for structural recording validation.' >&2
    exit 2
fi
script_dir=$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
exec python3 "$script_dir/check_my_submission.py" "$@"
