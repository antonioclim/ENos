<!-- RO: TRADUS ȘI VERIFICAT -->
#!/usr/bin/env bash
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

SECONDS=5

while [[ $# -gt 0 ]]; do
  case "$1" in
    --seconds) SECONDS="${2:-}"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown argument: $1" >&2; usage; exit 2 ;;
  esac
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOG="$SCRIPT_DIR/cpu_hog.py"

if [[ ! -x "$HOG" ]]; then
  echo "Error: cannot find executable cpu_hog.py in $SCRIPT_DIR" >&2
  exit 1
fi

run_hog() {
  local nice_level="$1"
  local label="$2"

  if command -v taskset >/dev/null 2>&1; then
    # pin to CPU0: reduces variation from migration between cores
    nice -n "$nice_level" taskset -c 0 "$HOG" --seconds "$SECONDS" \
      1>"/tmp/hog_${label}.out" 2>"/tmp/hog_${label}.err" &
  else
    nice -n "$nice_level" "$HOG" --seconds "$SECONDS" \
      1>"/tmp/hog_${label}.out" 2>"/tmp/hog_${label}.err" &
  fi
  echo $!
}

echo "=== Nice Demo ==="
echo "[INFO] Duration per process: ${SECONDS}s"
echo

pid_a="$(run_hog 0 "A_nice0")"
pid_b="$(run_hog 10 "B_nice10")"

echo "[INFO] Processes started:"
echo "  A (nice=0)  PID=$pid_a"
echo "  B (nice=10) PID=$pid_b"
echo

echo "[INFO] Snapshot ps (ni/pri):"
ps -o pid,ni,pri,stat,cmd -p "$pid_a","$pid_b" || true
echo

wait "$pid_a"
wait "$pid_b"

echo "=== Output A (nice=0) ==="
cat "/tmp/hog_A_nice0.out"
echo
echo "=== Output B (nice=10) ==="
cat "/tmp/hog_B_nice10.out"
echo

cat <<'NOTES'

Didactic notes:
- In Linux, `nice` controls (broadly speaking) how "polite" a process is: the higher the value,
  the less CPU the process receives when there is competition.
- Results may vary depending on: number of cores, system load and CPU governors.
- For a cleaner experiment: close heavy applications and run several times.
NOTES
