#!/usr/bin/env python3
"""Finite local evaluator reference for trusted, owned teaching fixtures.

This is not a submission sandbox. Validation is the default operation. Local
execution requires --run-owned and must never be used for untrusted submissions.
No score weights, grade mapping, penalties or institutional policy are implicit.
JSON uses the standard library; YAML input additionally requires PyYAML.
"""
from __future__ import annotations

import argparse
import csv
import hashlib
import io
import json
import math
import os
import re
import shlex
import shutil
import signal
import subprocess
import sys
import tempfile
import time
from pathlib import Path

OPS = {'eq', 'ne', 'lt', 'le', 'gt', 'ge'}
STREAMS = {'stdout', 'stderr', 'combined'}
MAX_OUTPUT = 1024 * 1024


class Unavailable(ValueError):
    """A known contract or platform requirement has not been supplied."""


def unique_pairs(pairs):
    result = {}
    for key, value in pairs:
        if key in result:
            raise ValueError(f'duplicate mapping key: {key!r}')
        result[key] = value
    return result


def read_document(path: Path):
    text = path.read_text(encoding='utf-8')
    if path.suffix.lower() == '.json':
        return json.loads(text, object_pairs_hook=unique_pairs,
                          parse_constant=lambda value: (_ for _ in ()).throw(ValueError('non-finite JSON number')))
    if path.suffix.lower() not in {'.yaml', '.yml'}:
        raise ValueError('input must be JSON or YAML')
    try:
        import yaml
    except ImportError as error:
        raise Unavailable('YAML input requires PyYAML; JSON needs no extra package') from error
    class UniqueLoader(yaml.SafeLoader):
        pass
    def mapping(loader, node, deep=False):
        return unique_pairs((loader.construct_object(k, deep=deep), loader.construct_object(v, deep=deep))
                            for k, v in node.value)
    UniqueLoader.add_constructor(yaml.resolver.BaseResolver.DEFAULT_MAPPING_TAG, mapping)
    try:
        return yaml.load(text, Loader=UniqueLoader)
    except yaml.YAMLError as error:
        raise ValueError('invalid YAML document') from error


def number(value):
    if type(value) not in {int, float} or not math.isfinite(value):
        raise ValueError('a finite number is required')
    return value


def compare(actual, operation, expected):
    if operation not in OPS:
        raise ValueError('unsupported comparison')
    if operation == 'eq': return actual == expected
    if operation == 'ne': return actual != expected
    if operation == 'lt': return actual < expected
    if operation == 'le': return actual <= expected
    if operation == 'gt': return actual > expected
    return actual >= expected


def validate_predicate(predicate, depth=0):
    """Validate the complete tree before evaluation, including unused OR arms."""
    if depth > 32 or not isinstance(predicate, dict) or len(predicate) != 1:
        raise ValueError('predicate must be a single-key object, at most 32 levels deep')
    kind, value = next(iter(predicate.items()))
    def fields(required, optional=()):
        if not isinstance(value, dict) or not set(required) <= value.keys() or set(value) - set(required) - set(optional):
            raise ValueError(f'invalid {kind} fields')
    def text(item):
        if not isinstance(item, str) or '\0' in item:
            raise ValueError(f'{kind} requires text without NUL')
    def strings(items):
        if not isinstance(items, list) or not items:
            raise ValueError(f'{kind} requires a nonempty list')
        for item in items: text(item)
    def numeric_comparison():
        if value['op'] not in OPS: raise ValueError('unsupported comparison')
        number(value['value'])
    if kind in {'all', 'any'}:
        if not isinstance(value, list) or not value or len(value) > 256:
            raise ValueError('all/any requires 1..256 predicates')
        for child in value: validate_predicate(child, depth + 1)
    elif kind == 'not': validate_predicate(value, depth + 1)
    elif kind == 'pending':
        text(value)
        if not value.strip(): raise ValueError('pending requires a concrete reason')
    elif kind == 'exit_code':
        fields({'op', 'value'}); numeric_comparison()
        if type(value['value']) is not int: raise ValueError('exit status must be an integer')
    elif kind in {'duration', 'output_number'}:
        fields({'op', 'value'}); numeric_comparison()
    elif kind == 'text':
        fields({'stream', 'op', 'value'})
        if value['stream'] not in STREAMS or value['op'] not in {'contains', 'regex', 'equals', 'first_line_contains'}:
            raise ValueError('unsupported text predicate')
        text(value['value'])
        if value['op'] == 'regex': re.compile(value['value'])
    elif kind == 'lines':
        fields({'stream', 'op', 'value'}); numeric_comparison()
        if value['stream'] not in STREAMS or type(value['value']) is not int or value['value'] < 0:
            raise ValueError('invalid line count')
    elif kind == 'path':
        fields({'kind', 'path'}); text(value['path'])
        if value['kind'] not in {'file', 'directory', 'symlink', 'executable', 'empty_directory'}:
            raise ValueError('unsupported path kind')
    elif kind == 'file_text':
        fields({'path', 'op', 'value'}); text(value['path']); text(value['value'])
        if value['op'] not in {'contains', 'regex', 'equals'}: raise ValueError('invalid file text operation')
        if value['op'] == 'regex': re.compile(value['value'])
    elif kind == 'file_count':
        fields({'path', 'op', 'value'}); text(value['path']); numeric_comparison()
        if type(value['value']) is not int or value['value'] < 0: raise ValueError('invalid file count')
    elif kind == 'glob':
        fields({'pattern', 'kind'}, {'min', 'max'}); text(value['pattern'])
        if value['kind'] not in {'file', 'directory'}: raise ValueError('invalid glob kind')
        for key in ('min', 'max'):
            if key in value and (type(value[key]) is not int or value[key] < 0): raise ValueError('invalid glob bound')
        if value.get('max', value.get('min', 1)) < value.get('min', 1): raise ValueError('inverted glob bounds')
    elif kind == 'json_valid':
        fields(set(), {'stream', 'path', 'required_keys'})
        if ('stream' in value) == ('path' in value): raise ValueError('JSON predicate needs one source')
        if 'stream' in value and value['stream'] not in STREAMS: raise ValueError('invalid JSON stream')
        if 'path' in value: text(value['path'])
        if 'required_keys' in value: strings(value['required_keys'])
    elif kind == 'csv_valid':
        fields({'path'}, {'min_rows', 'min_columns'}); text(value['path'])
        for key in ('min_rows', 'min_columns'):
            if key in value and (type(value[key]) is not int or value[key] < 1): raise ValueError('invalid CSV bound')
    elif kind == 'files_equal':
        strings(value)
        if len(value) != 2: raise ValueError('files_equal needs two paths')
    elif kind == 'ansi':
        if value is not True: strings(value)
    elif kind == 'unique_matches':
        fields({'pattern', 'values'}); text(value['pattern']); strings(value['values']); re.compile(value['pattern'])
        if len(value['values']) != len(set(value['values'])): raise ValueError('expected matches must be unique')
    elif kind == 'linked_library': text(value)
    elif kind == 'known_hash':
        fields({'algorithm', 'path'}); text(value['path'])
        if value['algorithm'] not in {'md5', 'sha1', 'sha256', 'sha512'}: raise ValueError('unsupported digest')
    else:
        raise ValueError(f'unknown predicate: {kind}')


def pending_reasons(predicate):
    kind, value = next(iter(predicate.items()))
    if kind == 'pending': return [value]
    if kind in {'all', 'any'}: return [reason for child in value for reason in pending_reasons(child)]
    if kind == 'not': return pending_reasons(value)
    return []


def stream(context, name):
    if name == 'combined': return context.get('stdout', '') + context.get('stderr', '')
    return context.get(name, '')


def owned_path(value, context):
    root = Path(context['fixture_root']).resolve()
    project = Path(context.get('project_root', root)).resolve()
    expanded = value.replace('${FIXTURE_ROOT}', str(root)).replace('$FIXTURE_ROOT', str(root))
    if '$' in expanded or '~' in expanded or '\0' in expanded:
        raise ValueError('unsupported path expansion')
    path = Path(expanded)
    if not path.is_absolute(): path = project / path
    resolved = path.resolve()
    if not resolved.is_relative_to(root):
        raise ValueError('predicate path escapes the owned fixture')
    return path


def tree_bytes(path):
    if path.is_file() and not path.is_symlink(): return {'': path.read_bytes()}
    if not path.is_dir() or path.is_symlink(): return None
    result = {}
    for member in path.rglob('*'):
        if member.is_symlink(): raise Unavailable('tree comparison does not follow symlinks')
        if member.is_file(): result[member.relative_to(path).as_posix()] = member.read_bytes()
        elif member.is_dir(): result[member.relative_to(path).as_posix() + '/'] = None
    return result


def evaluate(predicate, context):
    validate_predicate(predicate)
    reasons = pending_reasons(predicate)
    if reasons: raise Unavailable('; '.join(reasons))
    def visit(node):
        kind, value = next(iter(node.items()))
        if kind == 'all': return all(visit(child) for child in value)
        if kind == 'any': return any(visit(child) for child in value)
        if kind == 'not': return not visit(value)
        if kind == 'exit_code': return compare(context['exit_code'], value['op'], value['value'])
        if kind == 'duration': return compare(context['duration'], value['op'], value['value'])
        if kind == 'output_number':
            text = context.get('stdout', '').strip()
            if not re.fullmatch(r'-?\d+(?:\.\d+)?', text): return False
            return compare(float(text), value['op'], value['value'])
        if kind == 'text':
            text = stream(context, value['stream']); expected = value['value']
            if value['op'] == 'contains': return expected in text
            if value['op'] == 'equals': return expected == text
            if value['op'] == 'first_line_contains': return bool(text.splitlines()) and expected in text.splitlines()[0]
            return re.search(expected, text, re.MULTILINE) is not None
        if kind == 'lines': return compare(len(stream(context, value['stream']).splitlines()), value['op'], value['value'])
        if kind == 'path':
            path = owned_path(value['path'], context)
            return {'file': lambda: path.is_file(), 'directory': lambda: path.is_dir(),
                    'symlink': lambda: path.is_symlink(), 'executable': lambda: path.is_file() and os.access(path, os.X_OK),
                    'empty_directory': lambda: path.is_dir() and not any(path.iterdir())}[value['kind']]()
        if kind == 'file_text':
            path = owned_path(value['path'], context)
            if not path.is_file(): return False
            text = path.read_text(encoding='utf-8')
            if value['op'] == 'contains': return value['value'] in text
            if value['op'] == 'equals': return value['value'] == text
            return re.search(value['value'], text, re.MULTILINE) is not None
        if kind == 'file_count':
            path = owned_path(value['path'], context)
            return path.is_dir() and compare(sum(p.is_file() for p in path.iterdir()), value['op'], value['value'])
        if kind == 'glob':
            import glob
            pattern = str(owned_path(value['pattern'], context))
            found = [owned_path(p, context) for p in glob.glob(pattern, recursive=True)]
            count = sum(p.is_file() if value['kind'] == 'file' else p.is_dir() for p in found)
            return count >= value.get('min', 1) and ('max' not in value or count <= value['max'])
        if kind == 'json_valid':
            try:
                data = (owned_path(value['path'], context).read_text() if 'path' in value else stream(context, value['stream']))
                parsed = json.loads(data, object_pairs_hook=unique_pairs,
                                    parse_constant=lambda v: (_ for _ in ()).throw(ValueError('non-finite JSON')))
                return 'required_keys' not in value or isinstance(parsed, dict) and set(value['required_keys']) <= parsed.keys()
            except (ValueError, OSError): return False
        if kind == 'csv_valid':
            try:
                with owned_path(value['path'], context).open(newline='') as handle: rows = list(csv.reader(handle, strict=True))
                return len(rows) >= value.get('min_rows', 1) and bool(rows) and len(rows[0]) >= value.get('min_columns', 1) and all(len(row) == len(rows[0]) for row in rows)
            except (ValueError, OSError, csv.Error): return False
        if kind == 'files_equal':
            first, second = (tree_bytes(owned_path(p, context)) for p in value)
            return first is not None and second is not None and first == second
        if kind == 'ansi':
            text = context.get('stdout', '')
            if value is True: return re.search(r'\x1b\[[0-9;]*m', text) is not None
            spans = re.findall(r'\x1b\[(?!0?m)[0-9;]*m([^\x1b]*)', text)
            return all(any(token in span for span in spans) for token in value)
        if kind == 'unique_matches':
            matches = re.findall(value['pattern'], context.get('stdout', ''))
            return sorted(matches) == sorted(value['values']) and len(matches) == len(set(matches))
        if kind == 'linked_library':
            lines = context.get('stdout', '').splitlines()
            return any(value in line and '=>' in line and 'not found' not in line and re.search(r'=>\s+/', line) for line in lines)
        if kind == 'known_hash':
            expected = hashlib.new(value['algorithm'], owned_path(value['path'], context).read_bytes()).hexdigest()
            return context.get('stdout', '').strip() == expected
        raise ValueError('unreachable predicate')
    return bool(visit(predicate))


def iter_cases(document):
    """Flatten the documented category containers without executing setup."""
    def walk(value, scope='', category='general', setup=()):
        if isinstance(value, dict):
            local_setup = setup
            if 'metadata' in value:
                scope = value['metadata'].get('project_id', scope)
            if isinstance(value.get('setup'), dict):
                local_setup = (*setup, *value['setup'].get('commands', []))
            if 'points' in value and ('command' in value or 'check' in value or 'argv' in value):
                case = dict(value)
                case['category'] = case.get('category', category)
                case['id'] = scope + ':' + str(case.get('id', case.get('name', 'unnamed')))
                own_setup = case.get('setup', '')
                case['setup'] = '\n'.join([*local_setup, *([own_setup] if isinstance(own_setup, str) else [])])
                yield case
                return
            for key, child in value.items():
                if key in {'metadata', 'setup', 'cleanup', 'manual_evaluation_required', 'historical_inline_notes'}: continue
                yield from walk(child, scope or key, key if key not in {'tests', 'common_tests'} else category, local_setup)
        elif isinstance(value, list):
            for child in value: yield from walk(child, scope, category, setup)
    yield from walk(document)


def validate_case(case):
    if not isinstance(case.get('id'), str) or not case['id'] or not isinstance(case.get('category'), str):
        raise ValueError('case needs id and category')
    if number(case.get('points')) < 0: raise ValueError('points must be nonnegative')
    timeout = number(case.get('timeout', 60))
    if not 0 < timeout <= 300: raise ValueError('reference timeout must be within (0, 300] seconds')
    if 'argv' in case:
        if not isinstance(case['argv'], list) or not case['argv'] or not all(isinstance(a, str) and '\0' not in a for a in case['argv']):
            raise ValueError('argv must be a nonempty list of literal strings')
    elif not isinstance(case.get('command', case.get('check')), str): raise ValueError('missing command')
    for field in ('setup', 'cleanup'):
        if field in case and not isinstance(case[field], str): raise ValueError('setup/cleanup must be trusted shell text')
    if 'requires_tools' in case and (not isinstance(case['requires_tools'], list) or
                                    not all(isinstance(tool, str) and tool and '\0' not in tool for tool in case['requires_tools'])):
        raise ValueError('requires_tools must list executable names')
    validate_predicate(case.get('expect', {'exit_code': {'op': 'eq', 'value': 0}}))


def validate_document(document):
    def check_tree(value, ancestors=frozenset(), depth=0):
        if depth > 64: raise ValueError('document nesting exceeds 64 levels')
        if isinstance(value, (dict, list)):
            if id(value) in ancestors: raise ValueError('recursive document aliases are unsupported')
            current = ancestors | {id(value)}
            for child in (value.values() if isinstance(value, dict) else value): check_tree(child, current, depth + 1)
    check_tree(document)
    cases = list(iter_cases(document)); identifiers = set()
    for case in cases:
        validate_case(case)
        if case['id'] in identifiers: raise ValueError('duplicate case id: ' + case['id'])
        identifiers.add(case['id'])
    return {'cases': len(cases), 'planned_points': sum(c['points'] for c in cases),
            'pending_predicate_cases': sum(bool(pending_reasons(c.get('expect', {}))) for c in cases if c.get('expect')),
            'execution': 'NOT_RUN: schema/predicate validation only'}


def run_case(case, project=None):
    """Execute only caller-authorised, trusted fixtures in a fresh owned copy."""
    validate_case(case)
    predicate = case.get('expect', {'exit_code': {'op': 'eq', 'value': 0}})
    result = {'id': case['id'], 'category': case['category'], 'max_points': case['points'],
              'points': None, 'status': 'NOT_RUN', 'passed': False, 'grade': None,
              'evidence_class': 'trusted_owned_local_reference'}
    reasons = pending_reasons(predicate)
    if case.get('requires_platform'):
        reasons.append('requires isolated platform: ' + str(case['requires_platform']))
    if case.get('requires_non_root') and hasattr(os, 'geteuid') and os.geteuid() == 0:
        reasons.append('permission oracle requires an unprivileged fixture user')
    missing = [tool for tool in case.get('requires_tools', []) if not shutil.which(tool)]
    if missing: reasons.append('missing required tools: ' + ', '.join(missing))
    if reasons:
        return {**result, 'reason': '; '.join(reasons)}
    with tempfile.TemporaryDirectory(prefix='enos_evaluator_') as directory:
        root = Path(directory); work = root / 'project'; work.mkdir()
        if project:
            project = Path(project).resolve()
            if not project.is_dir(): raise ValueError('trusted fixture project must be a directory')
            if any(p.is_symlink() for p in project.rglob('*')): raise ValueError('fixture project copy must not contain symlinks')
            shutil.copytree(project, work, dirs_exist_ok=True)
        out = root / 'stdout'; err = root / 'stderr'; lifecycle = root / 'lifecycle.log'; receipt = root / 'exit.json'
        cleanup_receipt = root / 'cleanup.status'
        command = shlex.join(case['argv']) if 'argv' in case else case.get('command', case.get('check'))
        wrapper = root / 'case.sh'
        cleanup = case.get('cleanup', '')
        script = '''#!/usr/bin/env bash
set -euo pipefail
cleanup_owned_fixture() {
    local original_status=$?
    trap - EXIT
    set +e
    cleanup_actions() {
''' + (cleanup or ':') + '''
    }
    cleanup_actions
    local cleanup_status=$?
    local fixture_pid
    for fixture_pid in $(jobs -pr); do kill "$fixture_pid" 2>/dev/null; done
    wait
    printf '%d\\n' "$cleanup_status" >''' + shlex.quote(str(cleanup_receipt)) + '''
    if (( original_status == 0 && cleanup_status != 0 )); then original_status=$cleanup_status; fi
    exit "$original_status"
}
trap cleanup_owned_fixture EXIT
''' + case.get('setup', '') + '''
# Setup and cleanup share this shell. Explicitly exported PID variables reach the command child.
set +e
bash -euo pipefail -c ''' + shlex.quote(command) + ' >' + shlex.quote(str(out)) + ' 2>' + shlex.quote(str(err)) + '''
fixture_status=$?
printf '{"exit_code":%d}\\n' "$fixture_status" >''' + shlex.quote(str(receipt)) + '''
exit 0
'''
        wrapper.write_text(script)
        environment = {**os.environ, 'FIXTURE_ROOT': str(root), 'EVALUATION_REFERENCE': str(Path(__file__).resolve())}
        started = time.monotonic(); stopped = None
        with lifecycle.open('wb') as log:
            child = subprocess.Popen(['bash', str(wrapper)], cwd=work, env=environment,
                                     stdout=log, stderr=log, start_new_session=True)
            try:
                while child.poll() is None:
                    if time.monotonic() - started > case.get('timeout', 60): stopped = 'timeout'
                    if sum(p.stat().st_size for p in (out, err, lifecycle) if p.exists()) > MAX_OUTPUT: stopped = 'output_limit'
                    if stopped:
                        try: os.killpg(child.pid, signal.SIGTERM)
                        except ProcessLookupError: pass
                        try: child.wait(timeout=1)
                        except subprocess.TimeoutExpired:
                            try: os.killpg(child.pid, signal.SIGKILL)
                            except ProcessLookupError: pass
                            child.wait(timeout=2)
                        break
                    time.sleep(0.01)
            finally:
                # Only this newly created process group is owned by the runner.
                try: os.killpg(child.pid, signal.SIGKILL)
                except ProcessLookupError: pass
                child.wait(timeout=2)
        duration = time.monotonic() - started
        if sum(p.stat().st_size for p in (out, err, lifecycle) if p.exists()) > MAX_OUTPUT:
            stopped = 'output_limit'
        stdout = out.read_bytes()[:MAX_OUTPUT].decode('utf-8', errors='replace') if out.exists() else ''
        stderr = err.read_bytes()[:MAX_OUTPUT].decode('utf-8', errors='replace') if err.exists() else ''
        result.update(duration=duration, stdout=stdout, stderr=stderr,
                      lifecycle_output=lifecycle.read_bytes()[:MAX_OUTPUT].decode('utf-8', errors='replace'))
        if stopped: return {**result, 'status': 'ERROR', 'reason': stopped}
        if child.returncode != 0 or not receipt.is_file() or not cleanup_receipt.is_file() or cleanup_receipt.read_text().strip() != '0':
            return {**result, 'status': 'ERROR', 'reason': 'setup or lifecycle failed'}
        code = json.loads(receipt.read_text())['exit_code']
        if code in {126, 127}:
            return {**result, 'status': 'ERROR', 'exit_code': code,
                    'reason': 'command unavailable or not executable; this cannot satisfy an expected application error'}
        if code == 2 and case.get('reference_operation'):
            return {**result, 'status': 'ERROR', 'exit_code': code,
                    'reason': 'reference inspection unavailable or invalid'}
        context = {'stdout': stdout, 'stderr': stderr, 'duration': duration, 'exit_code': code,
                   'fixture_root': root, 'project_root': work}
        try: passed = evaluate(predicate, context)
        except (OSError, ValueError) as error:
            return {**result, 'status': 'ERROR', 'exit_code': code, 'reason': str(error)}
        return {**result, 'status': 'PASS' if passed else 'FAIL', 'passed': passed,
                'exit_code': code, 'points': case['points'] if passed else 0}


def summarise(results, weights=None):
    """Report arithmetic; missing observations never become a zero or pass."""
    if not results: raise ValueError('at least one result is required')
    categories = {}; complete = True; identifiers = set()
    for result in results:
        name = result['id']; category = result['category']; maximum = number(result['max_points'])
        if name in identifiers or maximum < 0: raise ValueError('invalid/duplicate result')
        identifiers.add(name)
        group = categories.setdefault(category, {'earned_known': 0, 'max_planned': 0, 'complete': True})
        group['max_planned'] += maximum
        if result['status'] not in {'PASS', 'FAIL'}:
            group['complete'] = complete = False
            if result['points'] is not None: raise ValueError('unobserved result must not carry points')
        else:
            earned = number(result['points'])
            if not 0 <= earned <= maximum: raise ValueError('earned points outside case range')
            group['earned_known'] += earned
    earned = sum(g['earned_known'] for g in categories.values()); maximum = sum(g['max_planned'] for g in categories.values())
    percentage = earned / maximum * 100 if complete and maximum else None
    weighted = None
    if weights is not None:
        if set(weights) != set(categories) or any(number(v) < 0 for v in weights.values()) or not math.isclose(sum(weights.values()), 100):
            raise ValueError('explicit numeric weights must cover all categories and sum to 100')
        if complete:
            if any(g['max_planned'] == 0 for g in categories.values()): raise ValueError('weighted category has no denominator')
            weighted = sum(g['earned_known'] / g['max_planned'] * weights[c] for c, g in categories.items())
    return {'earned_known': earned, 'max_planned': maximum, 'percentage': percentage,
            'weighted_percentage': weighted, 'complete': complete, 'categories': categories,
            'grade': None, 'policy_status': 'proposal_only_no_institutional_grade'}


def hybrid_percentage(auto_percentage, manual_marks, auto_weight):
    """Explicit illustrative arithmetic, not adoption of the 85/15 proposal."""
    if not 0 <= number(auto_percentage) <= 100 or not 0 <= number(auto_weight) <= 1:
        raise ValueError('invalid percentage/weight')
    if len(manual_marks) != 3 or any(not 0 <= number(mark) <= 10 for mark in manual_marks):
        raise ValueError('three manual marks in 0..10 are required')
    manual_percentage = sum(manual_marks) / 30 * 100
    return auto_percentage * auto_weight + manual_percentage * (1 - auto_weight)


def inspect_project(root, kind, minimum=20):
    """Deterministic structural predicates; source is parsed, never executed."""
    root = Path(root).resolve()
    if not root.is_dir(): raise ValueError('project directory missing')
    source = root / 'src' if (root / 'src').is_dir() else root
    scripts = sorted(p for p in source.rglob('*.sh') if p.is_file() and not p.is_symlink())
    if kind == 'readme':
        if type(minimum) is not int or minimum < 1: raise ValueError('minimum line count must be positive')
        return (root / 'README.md').is_file() and len((root / 'README.md').read_text().splitlines()) >= minimum
    if kind == 'has-shell': return bool(scripts)
    if not scripts: return False
    if kind == 'shebang':
        return all(p.read_bytes().splitlines()[:1] in ([b'#!/bin/bash'], [b'#!/usr/bin/env bash']) for p in scripts)
    if kind == 'syntax':
        return all(subprocess.run(['bash', '-n', str(p)], capture_output=True, timeout=10).returncode == 0 for p in scripts)
    if kind == 'shellcheck':
        if not shutil.which('shellcheck'): raise Unavailable('ShellCheck is not installed')
        result = subprocess.run(['shellcheck', '-S', 'error', '--', *map(str, scripts)], capture_output=True, timeout=30)
        if result.returncode not in (0, 1): raise Unavailable('ShellCheck could not analyse the selected files')
        return result.returncode == 0
    raise ValueError('unknown structural inspection')


def count_project_metric(root, kind, candidates):
    """Count explicit descriptive proxies; never infer code quality from them."""
    root = Path(root).resolve()
    selected = []
    for name in candidates:
        path = root / name
        if not path.resolve().is_relative_to(root) or path.is_symlink():
            raise ValueError('candidate must remain inside the owned project')
        if path.is_file(): selected.append(path)
    if len(selected) != 1:
        raise Unavailable('exactly one declared candidate script must exist; no failure fallback')
    path = selected[0]
    if kind == 'functions':
        expression = r'^\s*(?:function\s+[A-Za-z_][A-Za-z0-9_]*(?:\s*\(\s*\))?|[A-Za-z_][A-Za-z0-9_]*\s*\(\s*\))\s*\{'
        return sum(re.match(expression, line) is not None for line in path.read_text().splitlines())
    if kind == 'comments':
        return sum(line.startswith('#') for line in path.read_text().splitlines())
    if kind == 'sc2154':
        if not shutil.which('shellcheck'): raise Unavailable('ShellCheck is not installed')
        result = subprocess.run(['shellcheck', '--format=json', '--severity=warning', '--', str(path)],
                                capture_output=True, text=True, timeout=30)
        if result.returncode not in {0, 1}: raise Unavailable('ShellCheck could not analyse the candidate')
        try: rows = json.loads(result.stdout)
        except ValueError as error: raise Unavailable('ShellCheck did not return diagnostic JSON') from error
        if not isinstance(rows, list) or not all(isinstance(row, dict) and type(row.get('code')) is int for row in rows):
            raise Unavailable('invalid ShellCheck diagnostic records')
        return sum(row['code'] == 2154 for row in rows)
    raise ValueError('unknown descriptive metric')


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    actions = parser.add_subparsers(dest='action', required=True)
    validate = actions.add_parser('validate'); validate.add_argument('document', type=Path)
    run = actions.add_parser('run'); run.add_argument('document', type=Path)
    run.add_argument('--run-owned', action='store_true'); run.add_argument('--project', type=Path)
    inspect = actions.add_parser('inspect'); inspect.add_argument('kind', choices=['has-shell', 'readme', 'syntax', 'shebang', 'shellcheck'])
    inspect.add_argument('--root', type=Path, default=Path('.')); inspect.add_argument('--minimum', type=int, default=20)
    count = actions.add_parser('count'); count.add_argument('kind', choices=['functions', 'comments', 'sc2154'])
    count.add_argument('--root', type=Path, default=Path('.')); count.add_argument('--candidate', action='append', required=True)
    args = parser.parse_args(argv)
    try:
        if args.action == 'count':
            print(count_project_metric(args.root, args.kind, args.candidate)); return 0
        if args.action == 'inspect':
            passed = inspect_project(args.root, args.kind, args.minimum)
            print(json.dumps({'passed': passed, 'scope': 'structural_or_parser_only'})); return 0 if passed else 1
        document = read_document(args.document); validation = validate_document(document)
        if args.action == 'validate': print(json.dumps(validation, indent=2)); return 0
        if not args.run_owned: raise ValueError('run requires --run-owned for trusted local fixtures; this is not a submission sandbox')
        results = [run_case(case, args.project) for case in iter_cases(document)]
        report = {'schema_version': 1, 'results': results, 'summary': summarise(results),
                  'sandbox': False, 'external_actions': 'not provided by this helper', 'grade': None}
        print(json.dumps(report, indent=2, ensure_ascii=False, allow_nan=False))
        return 0 if all(r['status'] == 'PASS' for r in results) else 1
    except (ValueError, OSError, KeyError, TypeError, re.error, subprocess.SubprocessError) as error:
        print(json.dumps({'status': 'UNAVAILABLE', 'error': str(error), 'grade': None})); return 2


if __name__ == '__main__':
    raise SystemExit(main())
