#!/usr/bin/env bash
# Run the shipped semantic tests; missing modules and zero collection are errors.
set -euo pipefail
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
[[ -f "$SCRIPT_DIR/test_autograder.py" ]] || { printf 'Missing SEM05 tests\n' >&2; exit 1; }
exec python3 -m unittest discover -s "$SCRIPT_DIR" -p 'test_*.py' -v
