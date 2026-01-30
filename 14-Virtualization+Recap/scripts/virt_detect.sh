#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# Demo (Week 14): virtualisation / container detection.
# In practice, such detections are useful for: tuning, observability, licensing, debugging.

echo "=== Virtualisation / container detection ==="
echo "Timestamp: $(date -Is)"
echo

if command -v systemd-detect-virt >/dev/null 2>&1; then
  echo "== systemd-detect-virt =="
  systemd-detect-virt || true
  echo
else
  echo "[INFO] systemd-detect-virt is not available." >&2
fi

echo "== /proc/cpuinfo: hypervisor flag (if present) =="
grep -m1 -i 'flags' /proc/cpuinfo | grep -o 'hypervisor' || echo "(not explicitly present)"
echo

echo "== cgroup info (PID 1) =="
if [[ -r /proc/1/cgroup ]]; then
  cat /proc/1/cgroup
else
  echo "Cannot read /proc/1/cgroup."
fi
echo

echo "== environ hints (container) =="
if [[ -f /.dockerenv ]]; then
  echo "File /.dockerenv present (Docker indicator)."
else
  echo "Cannot find /.dockerenv."
fi
echo

cat <<'NOTES'
Didactic observations:
- Virtualisation (VM) and containers solve different problems:
  VM: hardware-ish isolation through VMM/hypervisor; container: kernel-level isolation (namespaces/cgroups).
- Detection is heuristic and platform-dependent.
NOTES
