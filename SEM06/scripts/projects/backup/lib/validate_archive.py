#!/usr/bin/env python3
"""Read-only member validation before GNU tar extraction into an empty owned directory.
Requires quiescent archive files; a path/type check does not authenticate an archive.
"""
from pathlib import PurePosixPath
import sys,tarfile

def parts(name):
    path=PurePosixPath(name)
    if not name or path.is_absolute() or '..' in path.parts: raise ValueError('Unsafe archive member path')
    return list(path.parts)
def validate(name):
    with tarfile.open(name,'r:*') as archive:
        for member in archive:
            path=parts(member.name)
            if member.isfile() or member.isdir() or member.type==b'D': continue # GNU listed-incremental directory record
            if member.issym():
                target=PurePosixPath(member.linkname)
                if target.is_absolute(): raise ValueError('Absolute symlink target refused')
                resolved=path[:-1]
                for item in target.parts:
                    if item=='..':
                        if not resolved: raise ValueError('Escaping symlink target refused')
                        resolved.pop()
                    elif item!='.': resolved.append(item)
            elif member.islnk(): parts(member.linkname)
            else: raise ValueError('Unsupported special archive member')
if __name__=='__main__':
    try:
        for name in sys.argv[1:]:validate(name)
    except (OSError,ValueError,tarfile.TarError) as exc:
        print(f'Archive member validation failed: {exc}',file=sys.stderr);sys.exit(1)
