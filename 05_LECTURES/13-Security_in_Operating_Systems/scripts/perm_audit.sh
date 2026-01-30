#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

usage() {
  cat <<'EOF'
Usage:
  perm_audit.sh [ROOT]

Purpose (Week 13): minimal permissions audit within a directory tree.
- finds world-writable files;
- finds files with SUID/SGID;
- finds world-writable directories without sticky bit (risk).

Example:
  ./perm_audit.sh .
  ./perm_audit.sh /tmp

Caveat:
  Does not automatically apply remediation; only reports.
EOF
}

ROOT="${1:-.}"
[[ -d "$ROOT" ]] || { echo "Error: ROOT is not a directory: $ROOT" >&2; exit 2; }

echo "=== Permission audit: $ROOT ==="
echo

echo "== World-writable files (-perm -0002) (first 30) =="
find "$ROOT" -xdev -type f -perm -0002 2>/dev/null | head -n 30 || true
echo

echo "== SUID files (-perm -4000) (first 30) =="
find "$ROOT" -xdev -type f -perm -4000 2>/dev/null | head -n 30 || true
echo

echo "== SGID files (-perm -2000) (first 30) =="
find "$ROOT" -xdev -type f -perm -2000 2>/dev/null | head -n 30 || true
echo

echo "== World-writable directories without sticky bit (rwxrwxrwx but no +t) =="
# sticky bit (1000) is important in shared directories (e.g. /tmp)
find "$ROOT" -xdev -type d -perm -0002 ! -perm -1000 2>/dev/null | head -n 30 || true
echo

cat <<'NOTES'
Didactic interpretation:
- DAC (Discretionary Access Control) in Unix: rwx permissions for user/group/others.
- SUID/SGID change the effective identity at execution; useful but sensitive.
- Sticky bit on shared directories prevents deletion of other users' files (e.g. /tmp).
NOTES
