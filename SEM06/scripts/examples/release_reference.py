#!/usr/bin/env python3
"""Local regular-file release transaction; no service, network or database actions.

Requires a trusted quiescent parent directory. Atomicity covers a symlink replacement
on one filesystem, not crash-durable distributed deployment. A digest verifies bytes
against the caller's expected value; it does not establish publisher authenticity.
"""
import argparse
import fcntl
import hashlib
import json
import os
from pathlib import Path, PurePosixPath
import re
import shutil
import sys
import tarfile
import tempfile

def stream_digest(stream, algorithm):
    digest = hashlib.new(algorithm)
    for chunk in iter(lambda: stream.read(1024 * 1024), b''):
        digest.update(chunk)
    return digest.hexdigest()


def identifier(value):
    if not re.fullmatch(r'[A-Za-z0-9][A-Za-z0-9._-]*', value) or value in ('.', '..'):
        raise ValueError('Invalid app/version identifier')
    return value

def validated_members(archive, expected_digest):
    if not re.fullmatch(r'[0-9a-fA-F]{64}', expected_digest):
        raise ValueError('An explicit SHA-256 digest is required')
    with open(archive, 'rb') as stream:
        actual = stream_digest(stream, 'sha256')
    if actual != expected_digest.lower():
        raise ValueError('Artifact digest mismatch')
    members = []
    seen = set()
    total = 0
    with tarfile.open(archive, 'r:*') as source:
        for member in source:
            path = PurePosixPath(member.name)
            if path.is_absolute() or '..' in path.parts or not path.parts:
                raise ValueError('Unsafe archive member path')
            name = str(path)
            if name in seen or not (member.isdir() or member.isfile()):
                raise ValueError('Duplicate member or unsupported link/device type')
            if name in ('manifest.json', '.complete'):
                raise ValueError('Member collides with release metadata')
            seen.add(name); total += member.size
            if len(seen) > 100000 or total > 2 * 1024**3:
                raise ValueError('Teaching fixture archive limit exceeded')
            members.append(member)
    return actual, members

def create(root, app, version, archive, digest):
    actual, members = validated_members(archive, digest)
    app_root = root / identifier(app)
    app_root.mkdir(parents=True, exist_ok=True)
    if app_root.is_symlink(): raise ValueError('Symlink app root refused')
    release = app_root / identifier(version)
    with open(app_root / '.release.lock', 'a') as lock:
        fcntl.flock(lock, fcntl.LOCK_EX)
        if release.exists() or release.is_symlink():
            raise ValueError('Version already exists; choose a new immutable ID')
        stage = Path(tempfile.mkdtemp(prefix='.stage.', dir=app_root))
        try:
            with tarfile.open(archive, 'r:*') as source:
                # Restrict extraction to validated regular files/directories.
                for member in members:
                    destination = stage / member.name
                    if member.isdir(): destination.mkdir(parents=True, exist_ok=True)
                    else:
                        destination.parent.mkdir(parents=True, exist_ok=True)
                        with source.extractfile(member) as data, open(destination, 'xb') as output:
                            shutil.copyfileobj(data, output)
                        destination.chmod(member.mode & 0o777)
            with open(archive, 'rb') as stream:
                if stream_digest(stream, 'sha256') != actual:
                    raise ValueError('Artifact changed during extraction')
            (stage / 'manifest.json').write_text(json.dumps(
                {'app': app, 'version': version, 'artifact': Path(archive).name,
                 'sha256': actual}, ensure_ascii=False) + '\n')
            (stage / '.complete').touch()
            stage.rename(release)
        finally:
            if stage.exists(): shutil.rmtree(stage)
    return release

def activate(root, app, version):
    app_root = root / identifier(app)
    release = app_root / identifier(version)
    if app_root.is_symlink() or release.is_symlink() or not (release / '.complete').is_file():
        raise ValueError('Incomplete or unsafe release')
    with open(app_root / '.release.lock', 'a') as lock:
        fcntl.flock(lock, fcntl.LOCK_EX)
        current = app_root / 'current'
        if current.exists() and not current.is_symlink():
            raise ValueError('Current is not a symlink')
        previous = os.readlink(current) if current.is_symlink() else None
        temporary = Path(tempfile.mkdtemp(prefix='.switch.', dir=app_root))
        try:
            (temporary / 'transition.json').write_text(json.dumps({'previous': previous, 'target': version}) + '\n')
            os.replace(temporary / 'transition.json', app_root / 'transition.json')
            (temporary / 'current').symlink_to(version)
            os.replace(temporary / 'current', current)
        finally: shutil.rmtree(temporary)

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    sub = parser.add_subparsers(dest='command', required=True)
    validate = sub.add_parser('validate'); validate.add_argument('archive'); validate.add_argument('sha256')
    for command in ('create', 'activate'):
        item = sub.add_parser(command)
        item.add_argument('root'); item.add_argument('app'); item.add_argument('version')
        if command == 'create': item.add_argument('archive'); item.add_argument('sha256')
    args = parser.parse_args()
    try:
        if args.command == 'validate': validated_members(args.archive, args.sha256)
        else:
            root = Path(args.root)
            if not root.is_absolute() or root == Path('/') or root.is_symlink():
                raise ValueError('Use an owned absolute release root')
            if args.command == 'create': print(create(root, args.app, args.version, args.archive, args.sha256))
            else: activate(root, args.app, args.version)
    except (OSError, ValueError, tarfile.TarError) as error:
        print(error, file=sys.stderr); return 1
    return 0

if __name__ == '__main__': raise SystemExit(main())
