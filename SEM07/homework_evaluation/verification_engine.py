#!/usr/bin/env python3
"""Bounded batch verification of the existing SEM07 envelope.

This preserves the existing signature message (hex SHA256 of content + LF).
It does not accept recorder encryption as a signature or establish key custody.
"""
from __future__ import annotations

import argparse
import base64
import binascii
import csv
import hashlib
import json
import math
import re
import subprocess
import sys
import tempfile
from collections import Counter
from pathlib import Path

COLUMNS = ['File', 'Student', 'Group', 'Seminar', 'Timestamp',
           'Signature_Status', 'Metadata_Status', 'Reason', 'Source_SHA256', 'Format_Status']
REQUIRED_IDENTITY = ('student_name', 'student_group', 'seminar')


def strict_object(pairs):
    result = {}
    for key, value in pairs:
        if key in result:
            raise ValueError(f'duplicate JSON key: {key}')
        result[key] = value
    return result


def seminar_label(value):
    """Reconcile the current integer recorder and SEMnn report representation.

    This normalises a supplied value; it does not infer a missing assignment or
    decide whether a seminar is part of the approved assessment catalogue.
    """
    if type(value) is int and 1 <= value <= 99:
        return f'SEM{value:02d}'
    if isinstance(value, str) and re.fullmatch(r'SEM(?:0[1-9]|[1-9][0-9])', value):
        return value
    return None


def parse_header_and_events(data: bytes):
    lines = data.splitlines(keepends=True)
    if not lines:
        raise ValueError('empty recording')
    header = json.loads(lines[0], object_pairs_hook=strict_object)
    if not isinstance(header, dict) or type(header.get('version')) is not int or header['version'] != 2:
        raise ValueError('expected an asciicast version 2 object header')
    for key in ('width', 'height'):
        if type(header.get(key)) is not int or header[key] <= 0:
            raise ValueError(f'{key} must be a positive integer')
    if 'timestamp' in header and (type(header['timestamp']) is not int or header['timestamp'] < 0):
        raise ValueError('timestamp must be a non-negative integer when present')
    footer_started = False
    previous_time = 0
    extension_codes = set()
    for index, line in enumerate(lines[1:], 1):
        if not line.strip():
            # Existing recorder03 writes a blank separator before its ## envelope.
            # Blank event records elsewhere are not silently accepted.
            following = next((item for item in lines[index + 1:] if item.strip()), b'')
            if footer_started or following.startswith((b'# SIGNATURE:', b'## ')):
                continue
            raise ValueError('blank record inside the asciicast event stream')
        if line.startswith((b'# SIGNATURE:', b'## SIG:', b'## META:', b'## ')):
            footer_started = True
            continue
        if footer_started:
            raise ValueError('recording events occur after a footer')
        event = json.loads(line)
        if (not isinstance(event, list) or len(event) != 3
                or type(event[0]) not in (int, float)
                or not math.isfinite(event[0]) or event[0] < 0
                or not isinstance(event[1], str) or not event[1] or not isinstance(event[2], str)):
            raise ValueError('malformed asciicast event')
        if event[0] < previous_time:
            raise ValueError('event timestamps must be monotonic')
        previous_time = event[0]
        if event[1] == 'r' and not re.fullmatch(r'[1-9][0-9]*x[1-9][0-9]*', event[2]):
            raise ValueError('resize event must have positive WIDTHxHEIGHT data')
        if event[1] not in ('o', 'i', 'm', 'r'):
            extension_codes.add(event[1])
    return header, sorted(extension_codes)


def signature_status(data: bytes, key: Path):
    lines = data.splitlines(keepends=True)
    matching = [i for i, line in enumerate(lines) if line.startswith(b'# SIGNATURE:')]
    if not matching:
        legacy = any(line.startswith(b'## ') for line in lines)
        return 'UNVERIFIED', ('unsupported recorder ## authentication envelope; identity/event format are separate'
                              if legacy else 'no supported signature footer; recorder encryption is not accepted')
    if matching != [len(lines) - 1]:
        return 'INVALID', 'signature footer must occur exactly once, at the end'
    try:
        signature = base64.b64decode(lines[-1].strip().split(b':', 1)[1].strip(), validate=True)
        if not signature:
            raise ValueError('empty signature')
    except (ValueError, binascii.Error):
        return 'INVALID', 'signature is not non-empty strict base64'
    if not key.is_file():
        return 'UNVERIFIED', 'verification public key is unavailable'
    message = hashlib.sha256(b''.join(lines[:-1])).hexdigest().encode('ascii') + b'\n'
    try:
        with tempfile.TemporaryDirectory(prefix='enos-verify-') as tmp:
            signature_file = Path(tmp) / 'signature.bin'
            signature_file.write_bytes(signature)
            result = subprocess.run(
                ['openssl', 'dgst', '-sha256', '-verify', str(key), '-signature', str(signature_file)],
                input=message, stdout=subprocess.PIPE, stderr=subprocess.PIPE, timeout=20)
    except (FileNotFoundError, PermissionError, subprocess.TimeoutExpired) as exc:
        return 'UNVERIFIED', f'verification could not run: {type(exc).__name__}'
    if result.returncode == 0:
        return 'VALID', 'existing SEM07 signature verified against the explicitly supplied key'
    return 'INVALID', 'cryptographic verification failed (including an unusable key)'


def inspect_file(path: Path, root: Path, key: Path):
    row = dict.fromkeys(COLUMNS, '')
    row['File'] = path.relative_to(root).as_posix()
    try:
        data = path.read_bytes()
        row['Source_SHA256'] = hashlib.sha256(data).hexdigest()
    except (OSError, ValueError, UnicodeError) as exc:
        row.update(Signature_Status='UNVERIFIED', Metadata_Status='UNAVAILABLE', Format_Status='UNAVAILABLE', Reason=str(exc))
        return row
    try:
        header = json.loads(data.splitlines()[0], object_pairs_hook=strict_object)
        if not isinstance(header, dict):
            raise ValueError('header must be an object')
    except (ValueError, UnicodeError, IndexError) as exc:
        row.update(Signature_Status='INVALID', Metadata_Status='INVALID', Format_Status='INVALID', Reason=str(exc))
        return row
    row.update(Student=header.get('student_name', ''), Group=header.get('student_group', ''),
               Seminar=seminar_label(header.get('seminar')) or '', Timestamp=header.get('timestamp', ''))
    missing = [name for name in ('student_name', 'student_group')
               if not isinstance(header.get(name), str) or not header[name].strip()
               or header[name].strip().upper() == 'UNKNOWN']
    if not row['Seminar']:
        missing.append('seminar')
    row['Metadata_Status'] = 'MISSING_METADATA' if missing else 'COMPLETE'
    try:
        _, extensions = parse_header_and_events(data)
        row['Format_Status'] = 'VALID'
    except (ValueError, UnicodeError) as exc:
        row.update(Signature_Status='INVALID', Format_Status='INVALID', Reason='invalid event format: ' + str(exc))
        return row
    row['Signature_Status'], reason = signature_status(data, key)
    if extensions:
        reason += '; preserved unknown event codes: ' + ', '.join(extensions)
    row['Reason'] = ('missing identity: ' + ', '.join(missing) + '; ' if missing else '') + reason
    return row


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('submissions_directory', type=Path)
    parser.add_argument('-o', '--output', type=Path, default=Path('./verification_results'))
    parser.add_argument('-k', '--key', type=Path, default=Path('/etc/os-course/public_key.pem'))
    parser.add_argument('-q', '--quiet', action='store_true')
    parser.add_argument('-r', '--report', action='store_true')
    parser.add_argument('--seminar')
    parser.add_argument('--student')
    parser.add_argument('-v', '--version', action='version', version='SEM07 verification 1.1.0')
    args = parser.parse_args(argv)
    root = args.submissions_directory.resolve()
    if not root.is_dir():
        parser.error(f'submissions directory does not exist: {root}')
    # Materialise traversal before writing results; traversal errors are operational failures.
    try:
        paths = sorted(path for path in root.rglob('*.cast') if path.is_file() and not path.is_symlink())
        rows = []
        for path in paths:
            row = inspect_file(path, root, args.key.resolve())
            if args.seminar and row['Seminar'] != (seminar_label(int(args.seminar)) if args.seminar.isdecimal() else seminar_label(args.seminar)):
                continue
            if args.student and args.student not in str(row['Student']):
                continue
            rows.append(row)
            if not args.quiet:
                print(f"{row['File']}: {row['Signature_Status']} / {row['Metadata_Status']}", file=sys.stderr)
        args.output.mkdir(parents=True, exist_ok=True)
        result_file = args.output / 'verification_results.csv'
        with result_file.open('w', newline='', encoding='utf-8') as handle:
            writer = csv.DictWriter(handle, fieldnames=COLUMNS)
            writer.writeheader()
            writer.writerows(rows)
        counts = Counter(row['Signature_Status'] for row in rows)
        metadata = Counter(row['Metadata_Status'] for row in rows)
        summary = {'discovered': len(paths), 'processed': len(rows), 'filtered': len(paths)-len(rows),
                   'signature': dict(counts), 'metadata': dict(metadata),
                   'scope': 'local existing-protocol verification; institutional identity/key custody undecided'}
        (args.output/'verification_summary.json').write_text(json.dumps(summary, indent=2)+'\n')
        if args.report:
            text = '# Homework Verification Report\n\n'
            text += 'The complete, escaped per-file results are in `verification_results.csv`.\n\n'
            text += '| Metric | Count |\n|---|---:|\n'
            text += f'| Discovered | {len(paths)} |\n| Processed after filters | {len(rows)} |\n'
            for name in ('VALID', 'UNVERIFIED', 'INVALID'):
                text += f'| {name} | {counts[name]} |\n'
            text += f'| MISSING_METADATA | {metadata["MISSING_METADATA"]} |\n'
            text += '\nA VALID signature does not replace complete identity metadata or an approved assessment policy.\n'
            (args.output/'verification_report.md').write_text(text, encoding='utf-8')
        if not args.quiet:
            print(f'Processed {len(rows)} of {len(paths)} files; CSV: {result_file}', file=sys.stderr)
    except OSError as exc:
        print(f'Verification operation failed: {exc}', file=sys.stderr)
        return 1
    # A completed batch with unresolved entries is distinguishable from a certified batch.
    return 0 if rows and all(r['Signature_Status']=='VALID' and r['Metadata_Status']=='COMPLETE' for r in rows) else 2


if __name__ == '__main__':
    raise SystemExit(main())
