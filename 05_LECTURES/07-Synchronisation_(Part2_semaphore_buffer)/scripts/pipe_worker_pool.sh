<!-- RO: TRADUS ȘI VERIFICAT -->
#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# Demo (Week 7): "worker pool" with pipeline + xargs -P.
# Connection to the producer/consumer concept: a producer generates tasks, a pool of consumers processes them.

usage() {
  cat <<'EOF'
Usage:
  pipe_worker_pool.sh [-p PARALLELISM] [-n TASKS]

Example:
  ./pipe_worker_pool.sh -p 4 -n 20
EOF
}

P=4
N=20
while getopts ":p:n:h" opt; do
  case "$opt" in
    p) P="$OPTARG" ;;
    n) N="$OPTARG" ;;
    h) usage; exit 0 ;;
    :) echo "Error: -$OPTARG requires an argument." >&2; usage; exit 2 ;;
    \?) echo "Error: invalid option -$OPTARG" >&2; usage; exit 2 ;;
  esac
done

echo "=== Worker pool (xargs -P) ==="
echo "[INFO] tasks=$N, parallelism=$P"
echo

# Producer: generates numbers 1..N
seq 1 "$N" \
  | xargs -n 1 -P "$P" bash -c 'echo "[worker $$] processing item=$1"; sleep 0.1' _

echo
echo "Didactic observation:"
echo "- \`xargs -P\` offers controlled parallelism: conceptually similar to a pool of threads/processes."
echo "- In an OS, blocking vs busy-wait matters: here, workers sleep, they do not consume CPU."
