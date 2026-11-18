#!/usr/bin/env python3
"""Rotate complete GNU-tar chains, retaining the currently active chain.

This local helper validates the parent graph before deleting any candidate. Pattern
and keep count apply to chain roots; descendants and checksum sidecars follow them.
"""
import argparse
import fnmatch
import json
from pathlib import Path

EXTENSIONS = ('.tar', '.tar.gz', '.tar.bz2', '.tar.xz', '.tar.zst')


def rotate(directory, keep, pattern, max_age_days=None):
    if keep < 0:
        raise ValueError('retention count cannot be negative')
    paths = {p.name:p for p in directory.iterdir()
             if p.is_file() and not p.is_symlink() and p.name.endswith(EXTENSIONS)}
    parents = {}
    for name, path in paths.items():
        sidecar = path.with_name(name+'.parent')
        parent = sidecar.read_text().strip() if sidecar.exists() else ''
        if parent and (Path(parent).name != parent or parent not in paths):
            raise ValueError(f'missing or invalid parent for {name}')
        parents[name] = parent
    roots = {}
    for name in paths:
        current, seen = name, set()
        while parents[current]:
            if current in seen:
                raise ValueError('incremental parent cycle')
            seen.add(current)
            current = parents[current]
        roots[name] = current
    active_file = directory/'.latest'
    state_file=directory/'.state.json'
    active = json.loads(state_file.read_text())['archive'] if state_file.exists() else (active_file.read_text().strip() if active_file.exists() else '')
    if active and active not in roots:
        raise ValueError('active chain tip is missing')
    protected = roots.get(active)
    candidates = sorted({root for root in roots.values() if fnmatch.fnmatchcase(root, pattern)},
                        key=lambda name: (paths[name].stat().st_mtime_ns, name), reverse=True)
    retained = set(candidates[:keep]) | {protected}
    if max_age_days is not None:
        import time
        cutoff = time.time() - max_age_days * 86400
        retained |= {root for root in candidates if any(paths[n].stat().st_mtime >= cutoff
                                                        for n, r in roots.items() if r == root)}
    victims = set(candidates) - retained
    for name, path in paths.items():
        if roots[name] in victims:
            # Generated sidecar names only; no wildcard deletion or shell evaluation.
            for suffix in ('', '.parent', '.md5', '.sha1', '.sha256', '.snar'):
                path.with_name(name+suffix).unlink(missing_ok=True)
            print(f'Removed complete-chain member: {name}')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('directory', type=Path)
    parser.add_argument('keep', type=int)
    parser.add_argument('pattern')
    parser.add_argument('--age-days', type=int)
    args = parser.parse_args()
    try:
        if args.age_days is not None and args.age_days < 0:
            raise ValueError('age cannot be negative')
        rotate(args.directory, args.keep, args.pattern, args.age_days)
    except (OSError, ValueError) as exc:
        parser.exit(1, f'Retention refused: {exc}\n')


if __name__ == '__main__':
    main()
