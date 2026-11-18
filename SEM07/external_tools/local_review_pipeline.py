#!/usr/bin/env python3
"""Adapt the shipped SEM01 reports without turning missing coverage into success."""
import argparse
import hashlib
import json
import math
from pathlib import Path
import subprocess
import sys
import tempfile

ROOT = Path(__file__).resolve().parents[2]


def load_object(path):
    value = json.loads(path.read_text(encoding='utf-8'))
    if not isinstance(value, dict):
        raise ValueError('report root must be an object')
    return value


def execute(tool, arguments, report, log):
    if not tool.is_file():
        return {'state': 'NOT_RUN', 'reason': 'tool is unavailable', 'command': []}
    command = [sys.executable, str(tool), *map(str, arguments)]
    try:
        result = subprocess.run(command, capture_output=True, text=True, timeout=120)
        log.write_text(result.stdout + '\nSTDERR\n' + result.stderr, encoding='utf-8')
        return {'state': 'EXECUTED', 'exit_code': result.returncode,
                'command': command, 'report': str(report), 'log': str(log)}
    except (OSError, subprocess.TimeoutExpired) as exc:
        log.write_text(str(exc), encoding='utf-8')
        return {'state': 'FAILED', 'reason': str(exc), 'command': command, 'log': str(log)}


def run(submissions, output, threshold):
    files = sorted(p for p in submissions.rglob('*.sh') if p.is_file() and not p.is_symlink())
    manifest = [{'file': str(p.relative_to(submissions)),
                 'sha256': hashlib.sha256(p.read_bytes()).hexdigest()} for p in files]
    output.mkdir(parents=True, exist_ok=True)
    run_dir = Path(tempfile.mkdtemp(prefix='review-', dir=output))
    summary = {'schema_version': 1, 'assessment_status': 'MANUAL_REVIEW_REQUIRED',
               'decision': None, 'penalty': None, 'display_threshold': threshold,
               'input_root': str(submissions), 'input_files': manifest,
               'similarity': {'state': 'NOT_RUN'}, 'style': {'state': 'NOT_RUN'},
               'observations': [], 'limitations': [
                   'Only non-symlink .sh files are requested from the local tools.',
                   'Similarity and lexical style do not establish authorship or misconduct.',
                   'The directory must remain quiescent during the run; hashes are recorded and rechecked.']}
    if not files:
        summary['coverage_status'] = 'EMPTY'
    else:
        sim_json = run_dir / 'similarity.json'
        sim = execute(ROOT / 'SEM01/scripts/python/S01_05_plagiarism_detector.py',
                      [submissions, '--threshold', threshold, '--output', run_dir / 'similarity.txt'],
                      sim_json, run_dir / 'similarity.log')
        try:
            if sim.get('exit_code') != 0:
                raise ValueError('similarity tool did not complete successfully')
            data = load_object(sim_json)
            rows = data['similarity_results']
            if not isinstance(rows, list):
                raise ValueError('similarity_results must be a list')
            for row in rows:
                if not isinstance(row, dict) or any(not isinstance(row.get(k), str) or not row[k]
                        for k in ('student1', 'student2', 'file1', 'file2', 'method')):
                    raise ValueError('invalid similarity row identity or source fields')
                value = row.get('similarity')
                if isinstance(value, bool) or not isinstance(value, (int, float)) or not math.isfinite(value) or not 0 <= value <= 1:
                    raise ValueError('similarity must be finite and in [0, 1]')
            sim.update(state='COMPLETE', pairs=rows)
            summary['observations'].extend({'kind': 'SIMILARITY', **row} for row in rows)
        except (OSError, ValueError, KeyError, TypeError) as exc:
            sim.update(state='FAILED', reason=str(exc))
        summary['similarity'] = sim
        style_json = run_dir / 'style.json'
        style = execute(ROOT / 'SEM01/scripts/python/S01_06_ai_fingerprint_scanner.py',
                        [submissions, '--extensions', '.sh', '--no-color', '--output', style_json],
                        style_json, run_dir / 'style.log')
        try:
            if style.get('exit_code') != 0:
                raise ValueError('style tool did not produce a usable exit status')
            data = load_object(style_json)
            rows = data['results']; count = data['summary']['files_scanned']
            if data.get('read_errors') or data['summary'].get('assessment_status') == 'INCOMPLETE':
                raise ValueError('style scanner reports incomplete reads')
            if type(count) is not int or not isinstance(rows, dict) or count != len(rows):
                raise ValueError('style report count/schema mismatch')
            wanted = {str(p.resolve()) for p in files}
            if {str(Path(p).resolve()) for p in rows} != wanted:
                raise ValueError('style scan coverage does not match the requested .sh files')
            for path, row in rows.items():
                if not isinstance(row, dict) or any(not isinstance(row.get(k), list)
                        for k in ('high_risk', 'medium_risk', 'structural', 'low_risk')):
                    raise ValueError('invalid lexical-style row')
                if row.get('read_error'):
                    raise ValueError('style scanner reports a per-file read error')
                if any(row[k] for k in ('high_risk', 'medium_risk', 'structural', 'low_risk')):
                    summary['observations'].append({'kind': 'LEXICAL_STYLE', 'file': path,
                                                    'patterns': row, 'authorship_inference': None})
            style.update(state='COMPLETE', files_scanned=count,
                         legacy_index=data['summary'].get('authenticity_score'))
        except (OSError, ValueError, KeyError, TypeError) as exc:
            style.update(state='FAILED', reason=str(exc))
        summary['style'] = style
        unchanged = all(p.is_file() and hashlib.sha256(p.read_bytes()).hexdigest() == item['sha256']
                        for p, item in zip(files, manifest))
        current = sorted(p for p in submissions.rglob('*.sh') if p.is_file() and not p.is_symlink())
        complete = sim['state'] == style['state'] == 'COMPLETE' and unchanged and current == files
        summary['coverage_status'] = 'COMPLETE' if complete else 'INCOMPLETE'
        if not unchanged or current != files:
            summary['limitations'].append('Input changed during the run; reports require a fresh run.')
    destination = run_dir / 'review_summary.json'
    destination.write_text(json.dumps(summary, indent=2, ensure_ascii=False) + '\n', encoding='utf-8')
    lines = [f"Local review coverage: {summary['coverage_status']}",
             f"Input .sh files: {len(files)}", f"Recorded observations: {len(summary['observations'])}",
             'No authorship, misconduct or grading decision is made.', f'Report: {destination}']
    if summary['coverage_status'] != 'COMPLETE':
        lines.append('Incomplete/empty coverage must not be interpreted as an all-clear.')
    text = '\n'.join(lines) + '\n'
    (run_dir / 'review_summary.txt').write_text(text, encoding='utf-8')
    print(text, end='')
    return 0 if summary['coverage_status'] == 'COMPLETE' else 2


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('seminar', nargs='?', choices=[f'SEM{i:02}' for i in range(1, 8)])
    parser.add_argument('--submissions', type=Path, help='Explicit local ROOT/STUDENT/*.sh directory')
    parser.add_argument('--output', type=Path, default=Path('local_review_reports'))
    parser.add_argument('--threshold', type=float, default=0.85, help='Descriptive display threshold only')
    args = parser.parse_args()
    if not math.isfinite(args.threshold) or not 0 <= args.threshold <= 1:
        parser.error('--threshold must be finite and in [0, 1]')
    submissions = args.submissions
    if submissions is None and args.seminar:
        candidates = [ROOT / args.seminar / 'submissions', ROOT / args.seminar / 'homework/submissions']
        submissions = next((p for p in candidates if p.is_dir()), None)
    if submissions is None or not submissions.is_dir():
        parser.error('provide an existing submissions directory; documentation is never substituted')
    try:
        return run(submissions.resolve(), args.output.resolve(), args.threshold)
    except (OSError, ValueError) as exc:
        print(f'Local review failed: {exc}', file=sys.stderr)
        return 1


if __name__ == '__main__':
    raise SystemExit(main())
