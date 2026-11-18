#!/usr/bin/env python3
"""Read-only schedule syntax validator; never reads or installs a crontab.

Declared subset: Debian/Vixie five-field schedules, numeric/name lists,
ascending ranges, positive steps on * or ranges, and the eight known macros.
A schedule has exactly five fields or one macro, without a command. Calendar
existence, DST, daemon behaviour, job execution and command safety are not tested.
"""
import argparse
import importlib.util
import json
from pathlib import Path
import sys


def validate(expression):
    path = Path(__file__).resolve().with_name('S03_01_autograder.py')
    spec = importlib.util.spec_from_file_location('_s03_cron_validator', path)
    module = importlib.util.module_from_spec(spec)
    sys.modules[spec.name] = module
    spec.loader.exec_module(module)
    parts = expression.split()
    if len(parts) != (1 if parts and parts[0].startswith('@') else 5):
        return {'valid': False, 'errors': ['Provide exactly five schedule fields or one macro, without a command.']}
    return module.CronValidator.parse_cron_expression(expression)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('expression')
    parser.add_argument('--json', action='store_true')
    args = parser.parse_args()
    result = validate(args.expression)
    if args.json:
        print(json.dumps(result))
    elif result['valid']:
        print('VALID SYNTAX: ' + result['description'])
        for warning in result.get('warnings', []):
            print('NOTE: ' + warning)
        print('Syntax only: no command, calendar run, daemon, timezone or DST verification.')
    else:
        print('INVALID: ' + '; '.join(result['errors']))
    return 0 if result['valid'] else 2


if __name__ == '__main__':
    raise SystemExit(main())
