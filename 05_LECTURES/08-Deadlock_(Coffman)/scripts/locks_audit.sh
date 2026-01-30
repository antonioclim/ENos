#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

usage() {
  cat <<'EOF'
Usage:
  locks_audit.sh [PATH]

Purpose:
  Demonstration for Week 8:
  - identifies processes holding a file or directory open (I/O resource),
    a situation that in practice can lead to "operational blockages" (e.g., cannot unmount).

Examples:
  ./locks_audit.sh /var/log
  ./locks_audit.sh /home/user/project

Note:
  Requires `lsof` (usually the lsof package) or `fuser` (psmisc).
EOF
}

TARGET="${1:-}"
if [[ -z "$TARGET" ]]; then
  usage
  exit 0
fi

echo "=== Open resource audit for: $TARGET ==="

if command -v lsof >/dev/null 2>&1; then
  echo
  echo "[INFO] lsof (first 30 lines):"
  lsof +D "$TARGET" 2>/dev/null | head -n 30 || true
else
  echo "[WARN] lsof is not installed. (Ubuntu: sudo apt-get install lsof)" >&2
fi

if command -v fuser >/dev/null 2>&1; then
  echo
  echo "[INFO] fuser:"
  fuser -v "$TARGET" 2>/dev/null || true
else
  echo "[WARN] fuser is not installed (psmisc)." >&2
fi

cat <<'NOTES'

Didactic observations:
- In classic deadlock (Coffman), we talk about allocated and awaited resources.
- In practice, the "resource" can also be an open file, a socket, a file lock, a mountpoint.
- Observability tools (`lsof`, `fuser`) are essential for debugging.
NOTES
