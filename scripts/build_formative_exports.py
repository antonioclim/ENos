#!/usr/bin/env python3
"""Rebuild SEM05/06 local JSON bank exports from their canonical YAML sources."""
import argparse
import json
from pathlib import Path
import sys
import yaml

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT))
from lib.quiz_contract import export_bank


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--check', action='store_true', help='Check current exports without writing')
    args = parser.parse_args()
    prepared = []
    for name in ('SEM05', 'SEM06'):
        source = ROOT/name/'formative/quiz.yaml'
        data = yaml.safe_load(source.read_text(encoding='utf-8'))
        report = export_bank(data, source)
        target = source.with_name('quiz_lms.json')
        text = json.dumps(report, ensure_ascii=False, indent=2)+'\n'
        prepared.append((target, text))
        print(name, json.dumps(report['derived_counts']))
    if args.check:
        mismatches = [str(path.relative_to(ROOT)) for path, text in prepared if not path.is_file() or path.read_text(encoding='utf-8') != text]
        if mismatches:
            print('Outdated local exports: ' + ', '.join(mismatches), file=sys.stderr)
            return 1
        print('Both current exports match the canonical YAML sources')
        return 0
    for target, text in prepared:
        target.write_text(text, encoding='utf-8')
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
