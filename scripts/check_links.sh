#!/usr/bin/env bash
# ENos documentation links — Antonio Clim, ASE-CSIE.
# Both historical entry points use the same parser and status contract.
set -euo pipefail
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
if ! command -v python3 >/dev/null 2>&1; then
    printf '%s\n' 'Python 3 is required.' >&2
    exit 2
fi
exec python3 "$SCRIPT_DIR/link_check.py" "$@"
