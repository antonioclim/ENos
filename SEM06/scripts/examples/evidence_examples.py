#!/usr/bin/env python3
"""Parse explicit synthetic evidence fixtures; never collect a user's environment."""
import argparse
import hashlib
import json
from pathlib import Path
import re
import sys

ALLOWED = ('DEMO_TASK', 'LANG', 'TERM', 'SHELL', 'TZ')
WRITE = re.compile(r'^(?:\[pid\s+\d+\]\s+|\d+\s+)?(?:\d+\.\d+\s+)?write\(')
def environment_records(data):
    result = []
    for entry in data.split(b'\0'):
        key, separator, value = entry.partition(b'=')
        if not separator:
            if entry: raise ValueError('Environment record has no = separator')
            continue
        name = key.decode('ascii', 'strict')
        if name in ALLOWED:
            result.append((name, value.decode('utf-8', 'strict')))
    if len({name for name, value in result}) != len(result):
        raise ValueError('Duplicate allowed variable')
    return result[:5]
def trace_writes(text):
    # Count entered write() records only; resumed lines are not double-counted.
    return [line for line in text.splitlines() if WRITE.match(line)]
def fingerprint(data):
    return hashlib.sha256(data).hexdigest()[:16]
def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('kind',choices=('environment','trace','fingerprint'));p.add_argument('fixture',type=Path)
    args=p.parse_args()
    try:
        data=args.fixture.read_bytes()
        if args.kind=='environment': print(json.dumps(environment_records(data),ensure_ascii=False))
        elif args.kind=='trace':
            lines=trace_writes(data.decode('utf-8'))
            print(json.dumps({'entered_write_calls':len(lines),'first_three':lines[:3]},ensure_ascii=False))
        else: print(fingerprint(data))
    except (OSError,ValueError,UnicodeError) as exc:
        print(f'Cannot inspect fixture: {exc}',file=sys.stderr);return 1
    return 0
if __name__=='__main__':raise SystemExit(main())
