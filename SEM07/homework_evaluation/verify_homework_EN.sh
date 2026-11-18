#!/usr/bin/env bash
# Homework verification CLI. Parsing, private temporaries and CSV escaping are
# handled by the standard-library engine; a batch continues after invalid input.
# The existing # SIGNATURE envelope is preserved, not applied to recorder crypto.
set -euo pipefail
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
command -v python3 >/dev/null || { printf 'python3 is required\n' >&2; exit 1; }
args=("$@")
# Preserve the environment defaults of the earlier Bash interface.
[[ -z "${OUTPUT_DIR:-}" ]] || args=(--output "$OUTPUT_DIR" "${args[@]}")
[[ -z "${PUBLIC_KEY_PATH:-}" ]] || args=(--key "$PUBLIC_KEY_PATH" "${args[@]}")
exec python3 "$SCRIPT_DIR/verification_engine.py" "${args[@]}"
