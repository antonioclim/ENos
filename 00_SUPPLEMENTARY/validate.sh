#!/usr/bin/env bash
# Local supplementary structure/integrity checks. Author: ing. dr. Antonio Clim.
set -euo pipefail
SUPPLEMENTARY_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
exec python3 "$SUPPLEMENTARY_DIR/validate.py" "$@"
