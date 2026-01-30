#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# Demo (Week 11): hard links vs symlinks and inode.
# Run in a working directory; creates temporary files and deletes them at the end.

TMPDIR="$(mktemp -d)"
trap 'rm -rf "$TMPDIR"' EXIT

cd "$TMPDIR"

echo "=== Demo links (hard vs symbolic) ==="
echo "[INFO] Working dir: $TMPDIR"
echo

echo "Hello, inode!" > original.txt
ln original.txt hard.txt
ln -s original.txt soft.txt

echo "== ls -li =="
ls -li
echo

echo "== stat (inode & link count) =="
stat -c 'file=%n inode=%i links=%h size=%s' original.txt hard.txt soft.txt
echo

echo "[INFO] Deleting original.txt"
rm -f original.txt
echo

echo "== Observe the effect =="
echo "- hard.txt still works (same inode)."
echo "- soft.txt becomes a dangling symlink."
echo

echo "hard.txt:"
cat hard.txt
echo

echo "soft.txt:"
cat soft.txt 2>/dev/null || echo "[OK] soft.txt cannot be dereferenced (dangling)."
