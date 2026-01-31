#!/usr/bin/env python3
"""
Minimal permisiuni audit (Week 13), Python version.

Didactic advantage:
- demonstrates how to interpret permission bits via `stat`;
- provides fine control (filtering, reporting).

Usage:
  ./perm_audit.py --root .
"""

from __future__ import annotations

import argparse
import stat
from dataclasses import dataclass, field
from pathlib import Path

# ═══════════════════════════════════════════════════════════════════════════════
# CONSTANTS
# ═══════════════════════════════════════════════════════════════════════════════

DEFAULT_MAX_DISPLAY = 30


# ═══════════════════════════════════════════════════════════════════════════════
# CONFIGURATION
# ═══════════════════════════════════════════════════════════════════════════════

def parse_args() -> argparse.Namespace:
    """Parse comandă-line arguments."""
    p = argparse.ArgumentParser(description="Permission Audit Tool")
    p.add_argument("--root", type=Path, default=Path("."), help="Root director")
    p.add_argument("--max", type=int, default=DEFAULT_MAX_DISPLAY, help="Max items")
    return p.parse_args()


# ═══════════════════════════════════════════════════════════════════════════════
# DATA STRUCTURES
# ═══════════════════════════════════════════════════════════════════════════════

@dataclass
class AuditResults:
    """Permissions audit results."""
    ww_files: list[Path] = field(default_factory=list)
    suid_files: list[Path] = field(default_factory=list)
    sgid_files: list[Path] = field(default_factory=list)
    ww_dirs_no_sticky: list[Path] = field(default_factory=list)


# ═══════════════════════════════════════════════════════════════════════════════
# SCANNING
# ═══════════════════════════════════════════════════════════════════════════════

def check_file_permissions(path: Path, mode: int, results: AuditResults) -> None:
    """Check permisiuni of a regular file."""
    if mode & stat.S_IWOTH:
        results.ww_files.append(path)
    if mode & stat.S_ISUID:
        results.suid_files.append(path)
    if mode & stat.S_ISGID:
        results.sgid_files.append(path)


def check_dir_permissions(path: Path, mode: int, results: AuditResults) -> None:
    """Check permisiuni of a director."""
    if (mode & stat.S_IWOTH) and not (mode & stat.S_ISVTX):
        results.ww_dirs_no_sticky.append(path)


def scan_directory(root: Path) -> AuditResults:
    """Scan the director and collect permission issues."""
    results = AuditResults()

    for path in root.rglob("*"):
        try:
            st = path.lstat()
        except (PermissionError, FileNotFoundError):
            continue

        mode = st.st_mode
        if stat.S_ISREG(mode):
            check_file_permissions(path, mode, results)
        elif stat.S_ISDIR(mode):
            check_dir_permissions(path, mode, results)

    return results


# ═══════════════════════════════════════════════════════════════════════════════
# DISPLAY
# ═══════════════════════════════════════════════════════════════════════════════

def show_category(title: str, items: list[Path], max_display: int) -> None:
    """Display a category of results."""
    print(title)
    for path in items[:max_display]:
        print(f"  {path}")
    if len(items) > max_display:
        print(f"  ... ({len(items) - max_display} others)")
    print()


def print_results(root: Path, results: AuditResults, max_display: int) -> None:
    """Display all audit results."""
    print(f"=== Permission audit (Python): {root} ===")
    print()
    show_category("World-writable files:", results.ww_files, max_display)
    show_category("SUID files:", results.suid_files, max_display)
    show_category("SGID files:", results.sgid_files, max_display)
    show_category("World-writable dirs without sticky bit:", results.ww_dirs_no_sticky, max_display)


# ═══════════════════════════════════════════════════════════════════════════════
# MAIN
# ═══════════════════════════════════════════════════════════════════════════════

def main() -> int:
    """Main entry point."""
    args = parse_args()
    results = scan_directory(args.root)
    print_results(args.root, results, args.max)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
