/* FIȘIER TRADUS ȘI VERIFICAT ÎN LIMBA ROMÂNĂ */

#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

usage() {
  cat <<'EOF'
Usage:
  trace_cmd.sh [-o OUT] [-e SYSCALLS] [--] <command> [args...]

Purpose:
  Demonstration for Week 2 (system calls):
  - runs a command under strace;
  - saves the log and optionally filters syscalls.

Examples:
  ./trace_cmd.sh -- ls -la
  ./trace_cmd.sh -e openat,read,write,close -- cat /etc/hosts
  ./trace_cmd.sh -o trace_ls.txt -- ls

Note:
  Requires `strace`. On Ubuntu: sudo apt-get install strace
EOF
}

OUT=""
SYSCALLS=""

# parse until --
while [[ $# -gt 0 ]]; do
  case "$1" in
    -o) OUT="${2:-}"; shift 2 ;;
    -e) SYSCALLS="${2:-}"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    --) shift; break ;;
    *) break ;;
  esac
done

if [[ $# -lt 1 ]]; then
  echo "Error: missing command to trace." >&2
  usage
  exit 2
fi

command -v strace >/dev/null 2>&1 || { echo "Error: strace is not installed." >&2; exit 1; }

ts="$(date +%Y%m%d_%H%M%S)"
: "${OUT:=./strace_${ts}.log}"

# build options
opts=(-f -tt -T -o "$OUT")
if [[ -n "$SYSCALLS" ]]; then
  opts+=(-e "trace=${SYSCALLS}")
fi

echo "[INFO] Output: $OUT" >&2
echo "[INFO] Command: $*" >&2

strace "${opts[@]}" -- "$@"

echo "[INFO] Statistical summary (strace -c):" >&2
# `-c` runs the command again; in the lab it's useful to see both perspectives.
strace -c -- "$@" 2>&1 | sed 's/^/[STATS] /'
