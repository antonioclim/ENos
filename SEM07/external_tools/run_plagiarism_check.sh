#!/usr/bin/env bash
# Local descriptive observations only; no network or misconduct decision.
set -euo pipefail
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
exec python3 "$SCRIPT_DIR/local_review_pipeline.py" "$@"
