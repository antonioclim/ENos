<!-- RO: TRADUS ȘI VERIFICAT -->
#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

usage() {
  cat <<'EOF'
Usage:
  fs_metadata_report.sh [-o OUT]

Purpose (Week 12): collect relevant metadata about filesystem and journaling.
- some commands may require privileges (e.g. tune2fs).

Example:
  ./fs_metadata_report.sh
  ./fs_metadata_report.sh -o fs_report.txt
EOF
}

OUT=""
while getopts ":o:h" opt; do
  case "$opt" in
    o) OUT="$OPTARG" ;;
    h) usage; exit 0 ;;
    :) echo "Error: -$OPTARG requires an argument." >&2; usage; exit 2 ;;
    \?) echo "Error: invalid option -$OPTARG" >&2; usage; exit 2 ;;
  esac
done

ts="$(date +%Y%m%d_%H%M%S)"
: "${OUT:=./fs_report_${ts}.txt}"

{
  echo "=== Filesystem report ==="
  echo "Timestamp: $(date -Is)"
  echo

  echo "== mount / findmnt =="
  command -v findmnt >/dev/null 2>&1 && findmnt || mount
  echo

  echo "== lsblk =="
  command -v lsblk >/dev/null 2>&1 && lsblk -f || true
  echo

  echo "== df (space) =="
  df -hT
  echo

  echo "== df (inodes) =="
  df -i
  echo

  echo "== dmesg (filesystem-related, last 50 lines) =="
  if command -v dmesg >/dev/null 2>&1; then
    dmesg --color=never | grep -iE 'ext4|xfs|btrfs|fsck|journal' | tail -n 50 || true
  fi
  echo

  echo "== (optional) tune2fs (ext*) =="
  cat <<'NOTE'
If the system uses ext4 and you have permissions:
  sudo tune2fs -l /dev/<device> | grep -iE 'Filesystem features|Journal|Mount count|Last mount'
NOTE
} > "$OUT"

echo "[INFO] Report written to: $OUT" >&2
