#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

usage() {
  cat <<'EOF'
Usage:
  pagefault_watch.sh [--] <command> [args...]

Purpose (Week 10): measuring *page faults* for a command.
- Uses `/usr/bin/time -v` (GNU time) if available.

Examples:
  ./pagefault_watch.sh -- python3 ../SO_Week_09/scripts/rss_probe.py --mb 100 --step 10
EOF
}

if [[ $# -lt 1 ]]; then
  usage
  exit 2
fi

TIME_BIN="/usr/bin/time"
if [[ -x "$TIME_BIN" ]]; then
  echo "=== /usr/bin/time -v ===" >&2
  "$TIME_BIN" -v -- "$@" 2>&1 | grep -E "Command being timed|User time|System time|Elapsed|Maximum resident|Minor|Major"
else
  echo "Error: /usr/bin/time is not available." >&2
  exit 1
fi

cat <<'NOTES'

Didactic interpretation:
- Minor faults: mapped pages that can be satisfied without I/O (e.g. already in cache).
- Major faults: require I/O (e.g. page is not in RAM and must be read from disk).
- Numbers depend on caching, system state and experiment repeatability.
NOTES
