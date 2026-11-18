#!/bin/bash
# Runs the two actually distributed SEM01 Python suites. Proposed Bash suites
# remain TODO in README.md; no missing file is counted as a successful test.
set -euo pipefail
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
if ! python3 -c 'import pytest' >/dev/null 2>&1; then
    printf 'pytest is required; see the repository dependency instructions.\n' >&2
    exit 2
fi
exec python3 -m pytest --import-mode=importlib "$SCRIPT_DIR/test_quiz.py" "$SCRIPT_DIR/test_ai_fingerprint.py" "$@"
