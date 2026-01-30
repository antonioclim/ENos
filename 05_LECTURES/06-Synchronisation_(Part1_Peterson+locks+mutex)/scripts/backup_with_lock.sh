#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

usage() {
  cat <<'EOF'
Usage:
  backup_with_lock.sh -s SOURCE_DIR -d DEST_DIR [-n ROTATIONS] [--dry-run]

Purpose (Week 6: synchronisation / race conditions):
- demonstrates a practical "lock" (bridging theory and real-world practice):
  if the script is launched simultaneously (manually or via cron), rotations may become corrupted.
- we use `flock` as a mutual exclusion mechanism.

Examples:
  ./backup_with_lock.sh -s ~/project -d ~/backups -n 5
  ./backup_with_lock.sh -s ~/project -d ~/backups --dry-run
EOF
}

SOURCE=""
DEST=""
ROT=7
DRYRUN=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    -s) SOURCE="${2:-}"; shift 2 ;;
    -d) DEST="${2:-}"; shift 2 ;;
    -n) ROT="${2:-}"; shift 2 ;;
    --dry-run) DRYRUN=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown argument: $1" >&2; usage; exit 2 ;;
  esac
done

[[ -n "$SOURCE" && -n "$DEST" ]] || { echo "Error: -s and -d are mandatory." >&2; usage; exit 2; }
[[ -d "$SOURCE" ]] || { echo "Error: SOURCE is not a directory: $SOURCE" >&2; exit 2; }
mkdir -p -- "$DEST"

run() { if (( DRYRUN )); then echo "+ $*"; else "$@"; fi; }

LOCKFILE="$DEST/.backup.lock"
exec 9>"$LOCKFILE"
if ! flock -n 9; then
  echo "Another instance is already running (lock: $LOCKFILE). Exiting." >&2
  exit 1
fi

ts="$(date +%Y%m%d_%H%M%S)"
archive="$DEST/backup_${ts}.tar.gz"

echo "[INFO] Creating archive: $archive" >&2
run tar -czf "$archive" -C "$SOURCE" .

echo "[INFO] Rotation: keeping the last $ROT archives" >&2
# list archives, sort descending by name (timestamp), delete the rest
mapfile -t archives < <(ls -1 "$DEST"/backup_*.tar.gz 2>/dev/null | sort -r || true)

if (( ${#archives[@]} > ROT )); then
  for old in "${archives[@]:ROT}"; do
    echo "[INFO] Deleting: $old" >&2
    run rm -f -- "$old"
  done
fi

echo "[INFO] Done." >&2
