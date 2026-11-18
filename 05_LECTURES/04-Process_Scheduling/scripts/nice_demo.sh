#!/usr/bin/env bash
# Historical translation annotation: RO: TRADUS ȘI VERIFICAT
set -euo pipefail
IFS=$'\n\t'

# Demo for Week 4: effect of "nice" priorities on scheduling.
# Uses two identical CPU-bound processes and sets different nice levels.

usage() {
  cat <<'EOF'
Usage:
  nice_demo.sh [--seconds S]

Example:
  ./nice_demo.sh --seconds 5

Notes:
- positive `nice` (e.g. 10, 15) is permitted for a regular user.
- negative `nice` requires privileges.
- for a clearer demonstration, pinning to a single CPU with `taskset` is recommended (if available).
EOF
}

DURATION=5

while [[ $# -gt 0 ]]; do
  case "$1" in
    --seconds) DURATION="${2:-}"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown argument: $1" >&2; usage; exit 2 ;;
  esac
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOG="$SCRIPT_DIR/cpu_hog.py"

if [[ ! -f "$HOG" ]]; then
  echo "Error: cannot find cpu_hog.py in $SCRIPT_DIR" >&2
  exit 1
fi

[[ "$DURATION" =~ ^[0-9]+([.][0-9]+)?$ ]] || { echo "--seconds must be positive" >&2; exit 2; }
python3 -c 'import sys; raise SystemExit(0 if float(sys.argv[1]) > 0 else 2)' "$DURATION"
RUN_DIR="$(mktemp -d "${TMPDIR:-/tmp}/enos-nice.XXXXXXXX")"
trap 'rm -rf -- "$RUN_DIR"' EXIT
CPU="$(python3 -c 'import os; print(min(os.sched_getaffinity(0)))')"
run_hog() {
  local nice_level="$1"
  local label="$2"

  if command -v taskset >/dev/null 2>&1; then
    # pin to CPU0: reduces variation from migration between cores
    nice -n "$nice_level" taskset -c "$CPU" python3 "$HOG" --seconds "$DURATION" \
      1>"$RUN_DIR/hog_${label}.out" 2>"$RUN_DIR/hog_${label}.err" &
  else
    nice -n "$nice_level" python3 "$HOG" --seconds "$DURATION" \
      1>"$RUN_DIR/hog_${label}.out" 2>"$RUN_DIR/hog_${label}.err" &
  fi
  LAST_PID=$!
}

echo "=== Nice Demo ==="
echo "[INFO] Duration per process: ${DURATION}s"
echo

run_hog 0 "A_nice0"
pid_a=$LAST_PID
run_hog 10 "B_nice10"
pid_b=$LAST_PID

echo "[INFO] Processes started:"
echo "  A (nice=0)  PID=$pid_a"
echo "  B (nice=10) PID=$pid_b"
echo

echo "[INFO] Snapshot ps (ni/pri):"
ps -o pid,ni,pri,stat,cmd -p "$pid_a","$pid_b" || true
echo

status=0
wait "$pid_a" || status=1
wait "$pid_b" || status=1
if (( status )); then cat "$RUN_DIR"/*.err >&2; exit "$status"; fi

echo "=== Output A (nice=0) ==="
cat "$RUN_DIR/hog_A_nice0.out"
echo
echo "=== Output B (nice=10) ==="
cat "$RUN_DIR/hog_B_nice10.out"
echo

cat <<'NOTES'

Didactic notes:
- In Linux, `nice` controls (broadly speaking) how "polite" a process is: the higher the value,
  the less CPU the process receives when there is competition.
- Results may vary depending on: number of cores, system load and CPU governors.
- For a cleaner experiment: close heavy applications and run several times.
NOTES
