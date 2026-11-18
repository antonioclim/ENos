#!/usr/bin/env bash
# ENos print stylesheet synchronisation. Author: ing. dr. Antonio Clim.
set -euo pipefail
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
exec python3 "$SCRIPT_DIR/add_print_styles.py" "$@"
