#!/usr/bin/env python3
"""Offline asciicast v2 structure check, not authentication or assessment.

Format: https://docs.asciinema.org/manual/asciicast/v2/
The three historical ENos footers are recognised for diagnosis only. They are
not ordinary asciicast events and no server acceptance is inferred.
"""
import argparse
import base64
import binascii
import hashlib
import json
import math
from pathlib import Path
import re


def read_json(text):
    def reject_constant(value):
        raise ValueError('Non-finite JSON number: ' + value)
    def pairs(items):
        result = {}
        for key, value in items:
            if key in result:
                raise ValueError('Duplicate JSON key: ' + key)
            result[key] = value
        return result
    return json.loads(text, parse_constant=reject_constant, object_pairs_hook=pairs)


def check(path):
    result = {'file': str(path), 'format_status': 'INVALID',
              'authentication_status': 'UNVERIFIED', 'submission_readiness': 'UNCONFIRMED',
              'metadata_status': 'MISSING_METADATA', 'events': 0, 'extensions': [],
              'footer_format': None, 'errors': [], 'warnings': []}
    try:
        raw = path.read_bytes()
        result['source_sha256'] = hashlib.sha256(raw).hexdigest()
        lines = raw.decode('utf-8').splitlines()
        if not lines:
            raise ValueError('Empty file')
        header = read_json(lines[0])
        if not isinstance(header, dict) or type(header.get('version')) is not int or header['version'] != 2:
            raise ValueError('Expected an asciicast v2 header object')
        for key in ('width', 'height'):
            if type(header.get(key)) is not int or header[key] <= 0:
                raise ValueError(key + ' must be a positive integer')
        if 'timestamp' in header and type(header['timestamp']) is not int:
            raise ValueError('Optional timestamp must be an integer')
        if 'env' in header and (not isinstance(header['env'], dict) or
                any(not isinstance(k, str) or not isinstance(v, str) for k, v in header['env'].items())):
            raise ValueError('env must map strings to strings')
        seminar = header.get('seminar')
        if (isinstance(header.get('student_name'), str) and header['student_name'].strip() and
                isinstance(header.get('student_group'), str) and header['student_group'].strip() and
                (type(seminar) is int and 1 <= seminar <= 7 or
                 isinstance(seminar, str) and re.fullmatch(r'0?[1-7]', seminar))):
            result['metadata_status'] = 'SELF_DECLARED_COMPLETE'
        footer = []
        previous = 0.0
        gap = False
        for index, line in enumerate(lines[1:], 2):
            if not line.strip():
                gap = True
                continue
            if line.startswith('#'):
                footer.append(line)
                continue
            if footer or gap:
                raise ValueError(f'Unexpected event after blank/footer at line {index}')
            event = read_json(line)
            if not isinstance(event, list) or len(event) != 3:
                raise ValueError(f'Event must contain [time, code, data] at line {index}')
            elapsed, code, data = event
            if (type(elapsed) not in (int, float) or not math.isfinite(elapsed) or
                    elapsed < previous or elapsed < 0):
                raise ValueError(f'Invalid or decreasing event time at line {index}')
            if not isinstance(code, str) or not code or not isinstance(data, str):
                raise ValueError(f'Event code/data must be strings at line {index}')
            if code == 'r' and not re.fullmatch(r'[1-9][0-9]*x[1-9][0-9]*', data):
                raise ValueError(f'Invalid resize dimensions at line {index}')
            if code not in ('o', 'i', 'm', 'r') and code not in result['extensions']:
                result['extensions'].append(code)
            previous = elapsed
            result['events'] += 1
        if footer:
            token = None
            if len(footer) == 2 and footer[0].startswith('## SIG:') and footer[1].startswith('## META:'):
                result['footer_format'] = 'LEGACY_ENCRYPTED_METADATA_HASH'
                token = footer[0][7:]
                if not footer[1][8:].strip():
                    raise ValueError('Empty legacy metadata')
            elif len(footer) == 1 and footer[0].startswith('# SIGNATURE:'):
                result['footer_format'] = 'LEGACY_VERIFIER_SIGNATURE'
                token = footer[0][12:].strip()
            elif len(footer) == 1 and footer[0].startswith('## '):
                result['footer_format'] = 'LEGACY_ENCRYPTED_RAW_METADATA'
                token = footer[0][3:]
            if not token:
                raise ValueError('Unsupported or empty legacy footer')
            if not base64.b64decode(token, validate=True):
                raise ValueError('Empty decoded footer token')
            result['warnings'].append('Footer syntax only: cryptography, identity and server acceptance are unverified.')
        if result['extensions']:
            result['warnings'].append('Unknown event extensions retained; no semantic validation of these events.')
        if not result['events']:
            result['warnings'].append('The recording contains no events; this is not a quality or eligibility decision.')
        if path.suffix.lower() != '.cast':
            result['warnings'].append('Filename does not end in .cast')
        result['format_status'] = 'VALID_V2_STRUCTURE'
    except (OSError, UnicodeError, ValueError, OverflowError, binascii.Error) as exc:
        result['errors'].append(str(exc))
    return result


def main():
    parser = argparse.ArgumentParser(description='Offline format preflight; no authenticity, grade or submission-readiness claim.')
    parser.add_argument('recording', type=Path)
    parser.add_argument('--json', action='store_true', help='Machine-readable diagnostic report')
    args = parser.parse_args()
    report = check(args.recording)
    if args.json:
        print(json.dumps(report, ensure_ascii=False, indent=2))
    else:
        for key in ('format_status', 'metadata_status', 'authentication_status', 'submission_readiness', 'events'):
            print(f'{key}: {report[key]}')
        for kind in ('errors', 'warnings'):
            for message in report[kind]:
                print(f'{kind.upper()}: {message}')
        print('Exit 0 means the supported structure parsed. It does not certify authorship, completeness or acceptance.')
    return 1 if report['errors'] else 0


if __name__ == '__main__':
    raise SystemExit(main())
