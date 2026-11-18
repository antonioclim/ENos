#!/usr/bin/env python3
"""M01 reference manifest planner; never creates, deletes or extracts an archive.

Manifest v1: {schema_version:1, parent:null|backup_ID, archive:basename,
sha256:64_lowercase_hex, source_root:absolute_path, created:ISO8601_UTC}.
The caller holds the backup-set lock. IDs are backup_YYYYMMDD_HHMMSS[_suffix].
This local reference format is not an adopted assessment-interface policy.
"""
from __future__ import annotations
import datetime as dt
import hashlib
import json
import re
import sys
import tarfile
from pathlib import Path, PurePosixPath

ID = re.compile(r'backup_[0-9]{8}_[0-9]{6}(?:_[A-Za-z0-9]+)?\Z')
SUFFIXES = ('.tar', '.tar.gz', '.tar.bz2', '.tar.xz')


def stream_digest(stream, algorithm):
    digest = hashlib.new(algorithm)
    for chunk in iter(lambda: stream.read(1024 * 1024), b''):
        digest.update(chunk)
    return digest.hexdigest()


def inventory(root: Path) -> dict:
    if not root.is_dir() or root.is_symlink():
        raise ValueError('backup root must be an existing non-symlink directory')
    manifests = {}
    for folder in sorted(root.iterdir()):
        if not folder.name.startswith('backup_'):
            continue
        if not ID.fullmatch(folder.name) or not folder.is_dir() or folder.is_symlink():
            raise ValueError(f'invalid backup directory: {folder.name}')
        manifest_path=folder/'manifest.json'
        if not manifest_path.is_file() or manifest_path.is_symlink(): raise ValueError('manifest missing or symlinked')
        def unique_pairs(pairs):
            result={}
            for key,value in pairs:
                if key in result: raise ValueError('duplicate manifest key')
                result[key]=value
            return result
        manifest = json.loads(manifest_path.read_text(), object_pairs_hook=unique_pairs)
        required = {'schema_version', 'parent', 'archive', 'sha256', 'source_root', 'created'}
        if not isinstance(manifest, dict) or not required <= manifest.keys():
            raise ValueError('manifest must be an object with every required v1 field')
        if type(manifest.get('schema_version')) is not int or manifest['schema_version'] != 1:
            raise ValueError('unsupported manifest version')
        parent = manifest.get('parent')
        if parent is not None and (not isinstance(parent, str) or not ID.fullmatch(parent)):
            raise ValueError('invalid parent')
        name = manifest.get('archive', '')
        if not isinstance(name, str) or PurePosixPath(name).name != name or not name.endswith(SUFFIXES):
            raise ValueError('invalid archive name')
        archive = folder / name
        if not archive.is_file() or archive.is_symlink():
            raise ValueError('archive missing or symlinked')
        if not isinstance(manifest['sha256'], str) or not re.fullmatch(r'[0-9a-f]{64}', manifest['sha256']):
            raise ValueError('invalid SHA256')
        source = manifest.get('source_root')
        if not isinstance(source, str) or not source.startswith('/'):
            raise ValueError('source_root must be absolute')
        if not isinstance(manifest['created'], str):
            raise ValueError('created must be an ISO8601 string')
        created = dt.datetime.fromisoformat(manifest['created'].replace('Z', '+00:00'))
        if created.tzinfo is None:
            raise ValueError('created must include timezone')
        manifest['_created'] = created.astimezone(dt.timezone.utc)
        manifest['_archive'] = archive
        manifests[folder.name] = manifest
    for name in manifests:
        chain(manifests, name)
    return manifests


def chain(manifests: dict, tip: str) -> list[str]:
    out = []
    source = None
    while tip is not None:
        if tip in out or tip not in manifests:
            raise ValueError('cyclic or missing parent')
        record = manifests[tip]
        if source is not None and record['source_root'] != source:
            raise ValueError('source root changes within chain')
        source = record['source_root']
        out.append(tip)
        tip = record['parent']
    return out[::-1]


def verify_archive(record: dict) -> None:
    path = record['_archive']
    with path.open('rb') as stream:
        if stream_digest(stream, 'sha256') != record['sha256']:
            raise ValueError(f'checksum mismatch: {path.name}')
    # Root-relative paths and internal links only. Device nodes are outside this
    # unprivileged teaching reference. GNU directory metadata is allowed.
    with tarfile.open(path) as archive:
        for member in archive:
            name = PurePosixPath(member.name)
            if name.is_absolute() or '..' in name.parts or member.isdev():
                raise ValueError('unsafe archive member')
            if member.issym() or member.islnk():
                link = PurePosixPath(member.linkname)
                if link.is_absolute() or '..' in link.parts:
                    raise ValueError('outside-root archive link')


def retention(root: Path, records: dict, counts: list[int]) -> list[str]:
    if len(counts) != 3 or any(type(n) is not int or n < 0 for n in counts):
        raise ValueError('three nonnegative retention counts required')
    chosen = set()
    ordered = sorted(records, key=lambda key: (records[key]['_created'], key), reverse=True)
    for count, grouping in zip(counts, (lambda d: d.date(), lambda d: d.isocalendar()[:2], lambda d: (d.year, d.month))):
        seen = set()
        for key in ordered:
            group = grouping(records[key]['_created'])
            if group not in seen and len(seen) < count:
                chosen.add(key)
                seen.add(group)
    active_file = root / '.active'
    if active_file.is_symlink() or (active_file.exists() and not active_file.is_file()):
        raise ValueError('active tip must be an owned regular file, never a symlink')
    if active_file.is_file():
        active = active_file.read_text().strip()
        if active not in records:
            raise ValueError('invalid active tip')
        chosen.add(active)
    protected = set()
    for key in chosen:
        protected.update(chain(records, key))
    # All manifests were validated before any output is emitted.
    return sorted(set(records) - protected)


def main(argv: list[str]) -> int:
    try:
        mode, directory, *args = argv
        root = Path(directory).absolute()
        if root.is_symlink(): raise ValueError('backup root may not be a symlink')
        records = inventory(root)
        if mode == 'chain' and len(args) == 1:
            selected = chain(records, args[0])
            for key in selected:
                verify_archive(records[key])
            result = [str(records[key]['_archive']) for key in selected]
        elif mode == 'retention':
            result = retention(root, records, [int(item) for item in args])
        else:
            raise ValueError('usage: backup_manifest.py chain ROOT ID | retention ROOT DAILY WEEKLY MONTHLY')
        sys.stdout.buffer.write(b''.join(item.encode() + b'\0' for item in result))
        return 0
    except (ValueError, KeyError, OSError, TypeError, tarfile.TarError) as error:
        print(f'Backup manifest rejected: {error}', file=sys.stderr)
        return 1


if __name__ == '__main__':
    raise SystemExit(main(sys.argv[1:]))
