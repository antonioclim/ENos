#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# Demo for Week 3: processes, PID/PPID, signals, process groups.

cleanup_pids=()

cleanup() {
  for pid in "${cleanup_pids[@]:-}"; do
    kill "$pid" 2>/dev/null || true
  done
}
trap cleanup EXIT

echo "=== Process demo: PID/PPID, ps --forest, signals ==="
echo "[INFO] Script PID: $$"
echo

echo "[INFO] Starting 3 child processes (sleep 60) in background..."
sleep 60 & cleanup_pids+=("$!")
sleep 60 & cleanup_pids+=("$!")
sleep 60 & cleanup_pids+=("$!")

echo "[INFO] Created PIDs: ${cleanup_pids[*]}"
echo

echo "== ps (forest) =="
ps -o pid,ppid,stat,cmd --forest -p "$$","${cleanup_pids[0]}","${cleanup_pids[1]}","${cleanup_pids[2]}" || true
echo

if command -v pstree >/dev/null 2>&1; then
  echo "== pstree (if available) =="
  pstree -p "$$" || true
  echo
fi

echo "== Signals: SIGTERM vs SIGKILL =="
echo "[INFO] Sending SIGTERM to first child (${cleanup_pids[0]})."
kill -TERM "${cleanup_pids[0]}" 2>/dev/null || true
sleep 0.2
ps -o pid,ppid,stat,cmd -p "${cleanup_pids[0]}" || echo "[OK] Process terminated (SIGTERM)."
echo

echo "[INFO] Sending SIGKILL to second child (${cleanup_pids[1]})."
kill -KILL "${cleanup_pids[1]}" 2>/dev/null || true
sleep 0.2
ps -o pid,ppid,stat,cmd -p "${cleanup_pids[1]}" || echo "[OK] Process terminated (SIGKILL)."
echo

echo "== Didactic observations =="
cat <<'NOTES'
- A process can ignore SIGTERM (or perform cleanup), but cannot ignore SIGKILL.
- If a parent does not call wait(), the terminated child temporarily remains in Z (zombie) state.
- In the laboratory, use `ps -eo pid,ppid,stat,cmd --forest` to visualise hierarchies.
NOTES
