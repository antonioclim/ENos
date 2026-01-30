#!/usr/bin/env python3
"""
Utility (Week 11): identifies files that share the same inode (hard links).

Running:
  ./inode_walk.py --root .

Note:
- on POSIX filesystems, inode + device (st_dev) uniquely identifies a file.
"""

from __future__ import annotations

import argparse
from collections import defaultdict
from pathlib import Path

# ═══════════════════════════════════════════════════════════════════════════════
# CONSTANTS
# ═══════════════════════════════════════════════════════════════════════════════

DEFAULT_MAX_GROUPS = 20


# ═══════════════════════════════════════════════════════════════════════════════
# CONFIGURATION
# ═══════════════════════════════════════════════════════════════════════════════

def parse_args() -> argparse.Namespace:
    """Parse command line arguments."""
    p = argparse.ArgumentParser(description="Inode Hard Link Finder")
    p.add_argument("--root", type=Path, default=Path("."), help="Root directory")
    p.add_argument("--max", type=int, default=DEFAULT_MAX_GROUPS, help="Max groups")
    return p.parse_args()


# ═══════════════════════════════════════════════════════════════════════════════
# SCANNING
# ═══════════════════════════════════════════════════════════════════════════════

def scan_for_hardlinks(root: Path) -> dict[tuple[int, int], list[Path]]:
    """Scan the directory and group files by inode."""
    groups: dict[tuple[int, int], list[Path]] = defaultdict(list)

    for path in root.rglob("*"):
        if not path.is_file() or path.is_symlink():
            continue
        try:
            st = path.stat()
            key = (st.st_dev, st.st_ino)
            groups[key].append(path)
        except (PermissionError, OSError):
            continue

    return groups


def filter_hardlink_groups(groups: dict) -> list[tuple]:
    """Filter and sort groups with more than one hard link."""
    multi = [(k, v) for k, v in groups.items() if len(v) > 1]
    multi.sort(key=lambda kv: len(kv[1]), reverse=True)
    return multi


# ═══════════════════════════════════════════════════════════════════════════════
# DISPLAY
# ═══════════════════════════════════════════════════════════════════════════════

def print_hardlink_groups(root: Path, groups: list, max_display: int) -> None:
    """Display hard link groups."""
    print(f"=== inode groups (hard links) under {root} ===")

    if not groups:
        print("No hard link groups found.")
        return

    for i, ((dev, ino), paths) in enumerate(groups):
        if i >= max_display:
            print(f"... and {len(groups) - max_display} more groups")
            break
        print(f"- dev={dev} ino={ino} count={len(paths)}")
        for p in paths:
            print(f"    {p}")


# ═══════════════════════════════════════════════════════════════════════════════
# MAIN
# ═══════════════════════════════════════════════════════════════════════════════

def main() -> int:
    """Main entry point."""
    args = parse_args()
    groups = scan_for_hardlinks(args.root)
    hardlink_groups = filter_hardlink_groups(groups)
    print_hardlink_groups(args.root, hardlink_groups, args.max)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
