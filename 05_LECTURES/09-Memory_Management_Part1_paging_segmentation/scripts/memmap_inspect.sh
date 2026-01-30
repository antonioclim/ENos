#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

usage() {
  cat <<'EOF'
Usage:
  memmap_inspect.sh <PID>

Purpose (Week 9): observing the address space and memory mappings.
- `/proc/<PID>/maps` shows mapped segments (text, heap, stack, mmap, shared libs).
- `pmap -x` (if available) provides a summary per segment.

Example:
  # start a test process:
  python3 -c 'import time; a=[0]*10_000_00; time.sleep(60)' &
  PID=$!
  ./memmap_inspect.sh $PID
EOF
}

PID="${1:-}"
[[ -n "$PID" ]] || { usage; exit 2; }
[[ -r "/proc/$PID/maps" ]] || { echo "Error: cannot read /proc/$PID/maps (valid PID?)." >&2; exit 2; }

echo "=== MemMap inspect: PID=$PID ==="
echo

echo "== /proc/$PID/status (memory summary) =="
grep -E '^(Name|State|VmSize|VmRSS|VmData|VmStk|VmExe|VmLib|Threads):' "/proc/$PID/status" || true
echo

echo "== /proc/$PID/maps (first 40 lines) =="
sed -n '1,40p' "/proc/$PID/maps"
echo

if command -v pmap >/dev/null 2>&1; then
  echo "== pmap -x (summary) =="
  pmap -x "$PID" | sed -n '1,25p'
  echo
else
  echo "[INFO] pmap is not available. (Ubuntu: sudo apt-get install procps)" >&2
fi

cat <<'NOTES'
Didactic observations:
- `VmSize` = total virtual memory mapped; does not mean RAM consumed.
- `VmRSS` = resident memory (approx. actual RAM used).
- `/proc/<PID>/maps` reflects the logical segmentation of the address space and mappings (including shared libs).
NOTES
