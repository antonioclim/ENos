"""Local semantic controls for the evaluator reference and its five documents.

Only parser probes, synthetic observations and explicitly owned harmless programs
run. Proposed student projects, Docker, services, networks and IPC are not run.
"""
import importlib.util
import json
import os
import re
import subprocess
import sys
import tempfile
import unittest
from unittest import mock
from pathlib import Path

PROJECTS = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location('evaluation_reference', PROJECTS / 'helpers/evaluation_reference.py')
E = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(E)


def exit_is(code=0):
    return {'exit_code': {'op': 'eq', 'value': code}}


class EvaluatorSemantics(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory(prefix='enos_eval_controls_')
        self.addCleanup(self.temporary.cleanup)
        self.path = Path(self.temporary.name)
        self.context = {'fixture_root': self.path, 'project_root': self.path,
                        'stdout': '', 'stderr': '', 'exit_code': 0, 'duration': 0.1}

    def case(self, **changes):
        value = {'id': 'owned:control', 'name': 'Owned harmless fixture', 'category': 'functional_core',
                 'argv': [sys.executable, '-c', 'print("owned")'], 'expect': exit_is(), 'points': 5, 'timeout': 2}
        value.update(changes)
        return value

    def test_invalid_predicates_fail_before_boolean_short_circuit(self):
        sentinel = self.path / 'never-created'
        for predicate in ({'eval': f'touch {sentinel}'},
                          {'any': [exit_is(), {'unknown': 'true'}]},
                          {'all': []}, {'exit_code': {'op': 'eq', 'value': True}},
                          {'duration': {'op': 'lt', 'value': float('nan')}}):
            with self.assertRaises(ValueError): E.evaluate(predicate, self.context)
        self.context['stdout'] = 'literal $(touch never-created)'
        self.assertTrue(E.evaluate({'text': {'stream': 'stdout', 'op': 'contains', 'value': '$(touch never-created)'}}, self.context))
        self.assertFalse(sentinel.exists())

    def test_json_yaml_duplicate_keys_and_recursive_alias_are_rejected(self):
        file = self.path / 'input.json'
        file.write_text('{"expect":1,"expect":2}')
        with self.assertRaises(ValueError): E.read_document(file)
        file = self.path / 'input.yaml'
        file.write_text('output_matches_regex: ERROR\noutput_matches_regex: INFO\n')
        with self.assertRaises(ValueError): E.read_document(file)
        file.write_text('root: &loop {child: *loop}\n')
        with self.assertRaises(ValueError): E.validate_document(E.read_document(file))

    def test_exact_counts_reject_duplicates_partial_numbers_and_queue_false_passes(self):
        predicate = {'output_number': {'op': 'ge', 'value': 3}}
        for output in ('13garbage', '0\n0\n', '2\n', '100 jobs'):
            self.context['stdout'] = output
            self.assertFalse(E.evaluate(predicate, self.context), output)
        self.context['stdout'] = '13\n'
        self.assertTrue(E.evaluate(predicate, self.context))
        queue = {'unique_matches': {'pattern': r'concurrent_[0-9]+\b',
                                     'values': [f'concurrent_{i}' for i in range(1, 11)]}}
        self.context['stdout'] = '\n'.join(f'concurrent_{i}' for i in range(1, 11))
        self.assertTrue(E.evaluate(queue, self.context))
        self.context['stdout'] += '\nconcurrent_10'
        self.assertFalse(E.evaluate(queue, self.context))
        self.context['stdout'] = '\n'.join(f'concurrent_{i}' for i in range(1, 20))
        self.assertFalse(E.evaluate(queue, self.context))

    def test_linker_and_known_digest_oracles_reject_plausible_but_wrong_output(self):
        predicate = {'linked_library': 'libjobqueue'}
        self.context['stdout'] = 'libjobqueue.so => not found\n'
        self.assertFalse(E.evaluate(predicate, self.context))
        self.context['stdout'] = 'libjobqueue.so => /owned/libjobqueue.so (0x1234)\n'
        self.assertTrue(E.evaluate(predicate, self.context))
        (self.path / 'abc').write_bytes(b'abc')
        for algorithm, digest in [('md5', '900150983cd24fb0d6963f7d28e17f72'),
                                  ('sha256', 'ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad')]:
            predicate = {'known_hash': {'algorithm': algorithm, 'path': 'abc'}}
            self.context['stdout'] = '0' * len(digest)
            self.assertFalse(E.evaluate(predicate, self.context))
            self.context['stdout'] = digest + '\n'
            self.assertTrue(E.evaluate(predicate, self.context))

    def test_file_csv_json_and_root_boundary_controls(self):
        (self.path / 'data.json').write_text('{"quoted":"a\\\"b", "value":3}')
        (self.path / 'data.csv').write_text('name,value\n"a,b",3\n')
        self.assertTrue(E.evaluate({'json_valid': {'path': 'data.json', 'required_keys': ['quoted']}}, self.context))
        self.assertTrue(E.evaluate({'csv_valid': {'path': 'data.csv', 'min_rows': 2, 'min_columns': 2}}, self.context))
        (self.path / 'data.csv').write_text('name,value\ninvalid,three,columns\n')
        self.assertFalse(E.evaluate({'csv_valid': {'path': 'data.csv'}}, self.context))
        with self.assertRaises(ValueError): E.evaluate({'path': {'kind': 'file', 'path': '../outside'}}, self.context)
        (self.path / 'external').symlink_to(self.path.parent)
        with self.assertRaises(ValueError): E.evaluate({'path': {'kind': 'directory', 'path': 'external'}}, self.context)

    def test_structural_oracles_reject_empty_short_wrong_shebang_and_later_bad_script(self):
        source = self.path / 'src'
        source.mkdir()
        self.assertFalse(E.inspect_project(self.path, 'has-shell'))
        (self.path / 'README.md').write_text('one line\n')
        self.assertFalse(E.inspect_project(self.path, 'readme'))
        (self.path / 'README.md').write_text('line\n' * 20)
        self.assertTrue(E.inspect_project(self.path, 'readme'))
        (source / 'first.sh').write_text('not a shebang\n')
        self.assertFalse(E.inspect_project(self.path, 'shebang'))
        (source / 'first.sh').write_text('#!/bin/bash\nprintf "owned\\n"\n')
        (source / 'second.sh').write_text('#!/usr/bin/env bash\nif then\n')
        self.assertTrue(E.inspect_project(self.path, 'has-shell'))
        self.assertFalse(E.inspect_project(self.path, 'syntax'))
        (source / 'second.sh').write_text('#!/usr/bin/env bash\ntrue\n')
        self.assertTrue(E.inspect_project(self.path, 'syntax'))
        self.assertTrue(E.inspect_project(self.path, 'shebang'))

    def test_descriptive_counts_and_shellcheck_json_have_no_failure_fallback(self):
        (self.path / 'src').mkdir()
        script = self.path / 'src/fsaudit.sh'
        script.write_text('#!/bin/bash\n# one\n# two\n# three\n# four\nalpha() { :; }\nfunction beta { :; }\ngamma() { :; }\n')
        candidates = ['src/fsaudit.sh', 'fsaudit.sh']
        self.assertEqual(E.count_project_metric(self.path, 'functions', candidates), 3)
        self.assertEqual(E.count_project_metric(self.path, 'comments', candidates), 5)
        # Controlled diagnostic transport, not a claim that ShellCheck ran.
        with mock.patch.object(E.shutil, 'which', return_value='/declared/shellcheck'):
            with mock.patch.object(E.subprocess, 'run', return_value=subprocess.CompletedProcess([], 0, '[]', '')):
                self.assertEqual(E.count_project_metric(self.path, 'sc2154', candidates), 0)
            with mock.patch.object(E.subprocess, 'run', return_value=subprocess.CompletedProcess([], 1, '[{"code":2154},{"code":2154}]', '')):
                self.assertEqual(E.count_project_metric(self.path, 'sc2154', candidates), 2)
            with mock.patch.object(E.subprocess, 'run', return_value=subprocess.CompletedProcess([], 2, '', 'unavailable')):
                with self.assertRaises(E.Unavailable): E.count_project_metric(self.path, 'sc2154', candidates)
        (self.path / 'fsaudit.sh').write_text('#!/bin/bash\ntrue\n')
        with self.assertRaises(E.Unavailable): E.count_project_metric(self.path, 'functions', candidates)

    def test_runner_emits_single_encoded_json_and_keeps_streams_separate(self):
        case = self.case(argv=[sys.executable, '-c', 'import sys; print("quoted \\\"value\\\"\\t"); print("diagnostic", file=sys.stderr); raise SystemExit(7)'],
                         expect={'all': [exit_is(7), {'text': {'stream': 'stderr', 'op': 'equals', 'value': 'diagnostic\n'}}]})
        result = E.run_case(case)
        self.assertEqual(result['status'], 'PASS', result)
        decoded = json.loads(json.dumps(result, ensure_ascii=False, allow_nan=False))
        self.assertEqual(decoded, result)
        self.assertNotIn('diagnostic', result['stdout'])
        self.assertEqual(result['exit_code'], 7)

    def test_runner_fresh_setup_pid_transfer_and_cleanup_failure(self):
        case = self.case(setup='printf "first\\n" > "$FIXTURE_ROOT/item"\nsleep 20 &\nexport SETUP_PID=$!',
                         command='kill -0 "$SETUP_PID" && test "$(cat "$FIXTURE_ROOT/item")" = first && printf "changed\\n" > "$FIXTURE_ROOT/item"',
                         cleanup='kill "$SETUP_PID" 2>/dev/null || true; wait "$SETUP_PID" 2>/dev/null || true')
        case.pop('argv')
        first, second = E.run_case(case), E.run_case(case)
        self.assertEqual((first['status'], second['status']), ('PASS', 'PASS'), (first, second))
        failed = E.run_case(self.case(cleanup='false'))
        self.assertEqual(failed['status'], 'ERROR')
        self.assertIsNone(failed['points'])

    def test_timeout_setup_failure_and_pending_are_never_clean(self):
        timed = E.run_case(self.case(argv=[sys.executable, '-c', 'import time; time.sleep(20)'], timeout=0.1))
        self.assertEqual(timed['status'], 'ERROR', timed)
        self.assertEqual(timed['reason'], 'timeout')
        failed = E.run_case(self.case(setup='false'))
        self.assertEqual(failed['status'], 'ERROR')
        pending = E.run_case(self.case(expect={'pending': 'author digest choice'}))
        self.assertEqual(pending['status'], 'NOT_RUN')
        self.assertNotIn('duration', pending)
        platform = E.run_case(self.case(requires_platform='owned network namespace'))
        self.assertEqual(platform['status'], 'NOT_RUN')
        missing = E.run_case(self.case(requires_tools=['enos_missing_tool_fixture_96339']))
        self.assertEqual(missing['status'], 'NOT_RUN')
        missing_command = E.run_case(self.case(argv=['enos_missing_command_fixture_96339'],
                                               expect={'exit_code': {'op': 'ne', 'value': 0}}))
        self.assertEqual(missing_command['status'], 'ERROR')
        excessive = E.run_case(self.case(argv=[sys.executable, '-c', 'print("x" * 1200000)']))
        self.assertEqual(excessive['status'], 'ERROR')
        self.assertEqual(excessive['reason'], 'output_limit')

    def test_literal_argv_does_not_run_substitution_text(self):
        sentinel = self.path / 'sentinel'
        data = f'$(touch {sentinel}) ; literal "quote"'
        result = E.run_case(self.case(argv=[sys.executable, '-c', 'import sys;print(sys.argv[1])', data],
                                      expect={'text': {'stream': 'stdout', 'op': 'equals', 'value': data + '\n'}}))
        self.assertEqual(result['status'], 'PASS', result)
        self.assertFalse(sentinel.exists())

    def test_cli_validation_and_missing_opt_in_do_not_execute(self):
        sentinel = self.path / 'authorised-only'
        case = self.case(argv=[sys.executable, '-c',
                              'from pathlib import Path; import sys; Path(sys.argv[1]).write_text("owned")',
                              str(sentinel)])
        document = self.path / 'owned.json'
        document.write_text(json.dumps({'owned': [case]}))
        helper = str(PROJECTS / 'helpers/evaluation_reference.py')
        for action, expected_code in [('validate', 0), ('run', 2)]:
            result = subprocess.run([sys.executable, helper, action, str(document)],
                                    capture_output=True, text=True, timeout=5)
            self.assertEqual(result.returncode, expected_code, result.stdout + result.stderr)
            json.loads(result.stdout)
            self.assertFalse(sentinel.exists())
        authorised = subprocess.run([sys.executable, helper, 'run', str(document), '--run-owned'],
                                    capture_output=True, text=True, timeout=5)
        self.assertEqual(authorised.returncode, 0, authorised.stdout + authorised.stderr)
        report = json.loads(authorised.stdout)
        self.assertEqual(report['results'][0]['status'], 'PASS')
        self.assertIs(report['sandbox'], False)
        self.assertIsNone(report['grade'])
        self.assertEqual(sentinel.read_text(), 'owned')

    def test_arithmetic_maximum_missing_categories_and_incomplete_denominator(self):
        results = [{'id': 'one', 'category': 'core', 'status': 'PASS', 'points': 40, 'max_points': 40},
                   {'id': 'two', 'category': 'structure', 'status': 'PASS', 'points': 10, 'max_points': 10}]
        summary = E.summarise(results, {'core': 80, 'structure': 20})
        self.assertEqual((summary['percentage'], summary['weighted_percentage']), (100, 100))
        self.assertEqual(E.hybrid_percentage(100, [10, 10, 10], 0.85), 100)
        self.assertIsNone(summary['grade'])
        with self.assertRaises(ValueError): E.summarise(results, {'core': 100})
        with self.assertRaises(ValueError): E.summarise(results, {'core': '80%', 'structure': 20})
        incomplete = [results[0], {**results[1], 'status': 'NOT_RUN', 'points': None}]
        summary = E.summarise(incomplete)
        self.assertFalse(summary['complete'])
        self.assertIsNone(summary['percentage'])
        self.assertEqual((summary['earned_known'], summary['max_planned']), (40, 50))


class CurrentDocuments(unittest.TestCase):
    def documents(self):
        folder = PROJECTS / 'AUTOMATED_EVALUATION_SPEC'
        names = ['AUTOMATED_EVALUATION_SPEC.md', 'AUTOMATED_EVALUATION_SUMMARY.md',
                 'TEST_SPEC_EASY.md', 'TEST_SPEC_MEDIUM.md', 'TEST_SPEC_ADVANCED.md']
        with tempfile.TemporaryDirectory(prefix='enos_eval_yaml_') as temporary:
            block_file = Path(temporary) / 'block.yaml'
            for name in names:
                path = folder / name
                for number, raw in enumerate(re.findall(r'```yaml\n(.*?)\n```', path.read_text(), re.S)):
                    block_file.write_text(raw)
                    yield name, number, E.read_document(block_file)

    def test_all_current_yaml_predicates_and_exact_declared_point_totals(self):
        case_count = 0
        for name, number, document in self.documents():
            report = E.validate_document(document)
            case_count += report['cases']
            if isinstance(document, dict):
                for key, suite in document.items():
                    if isinstance(suite, dict) and 'metadata' in suite:
                        cases = list(E.iter_cases({key: suite}))
                        self.assertEqual(suite['metadata']['total_points'], sum(c['points'] for c in cases), (name, number, key))
                        self.assertEqual(suite['metadata']['test_count'], len(cases))
        self.assertEqual(case_count, 227)  # 226 retained proposals plus one new owned demonstration.

    def test_all_printed_command_setup_cleanup_fragments_parse_without_execution(self):
        checked = 0
        for name, number, document in self.documents():
            for case in E.iter_cases(document):
                for field in ('setup', 'command', 'check', 'cleanup'):
                    code = case.get(field)
                    if not isinstance(code, str) or not code.strip(): continue
                    result = subprocess.run(['bash', '-n', '-c', code], capture_output=True, text=True)
                    self.assertEqual(result.returncode, 0, (name, number, case['id'], field, result.stderr, code))
                    checked += 1
        self.assertGreater(checked, 250)

    def test_duplicate_regex_expectations_both_remain_and_example_total_is_81(self):
        for name, _, document in self.documents():
            if name == 'TEST_SPEC_EASY.md' and isinstance(document, dict) and 'e02_log_analyzer' in document:
                case = next(c for c in E.iter_cases(document) if c['id'] == 'E02:func_04')
                text = json.dumps(case['expect'])
                self.assertIn('ERROR', text)
                self.assertIn('INFO', text)
        source = (PROJECTS / 'AUTOMATED_EVALUATION_SPEC/AUTOMATED_EVALUATION_SPEC.md').read_text()
        report = json.loads(re.search(r'```json\n(.*?)\n```', source, re.S)[1])
        self.assertEqual(sum(c['earned'] for c in report['categories'].values()), 81)
        self.assertEqual(report['summary']['percentage'], 81)
        self.assertIsNone(report['summary']['grade'])

    def test_only_the_owned_demonstration_runs_from_the_document(self):
        selected = []
        for _, _, document in self.documents():
            if isinstance(document, dict) and 'owned_reference' in document:
                selected.extend(E.iter_cases(document))
        self.assertEqual(len(selected), 1)
        result = E.run_case(selected[0])
        self.assertEqual(result['status'], 'PASS', result)

    def test_exact_printed_owned_setups_match_their_permission_count_and_log_data(self):
        # Run the exact current setup strings, then a named fixture-inspection
        # oracle. The proposed student's project command is deliberately absent.
        probes = {
            'E01:func_03': ('import os,stat;from pathlib import Path;p=Path(os.environ["FIXTURE_ROOT"])/"e01_test/documents/secret.txt";print(stat.S_IMODE(p.stat().st_mode))',
                           {'output_number': {'op': 'eq', 'value': 0}}),
            'E02:func_04': ('import os;from pathlib import Path;s=(Path(os.environ["FIXTURE_ROOT"])/"e02_levels.log").read_text();print("ERROR",s.count("[ERROR]"));print("INFO",s.count("[INFO]"))',
                           {'all': [{'text': {'stream': 'stdout', 'op': 'contains', 'value': 'ERROR 3'}},
                                    {'text': {'stream': 'stdout', 'op': 'contains', 'value': 'INFO 3'}}]}),
            'E03:func_01': ('import os;from pathlib import Path;p=Path(os.environ["FIXTURE_ROOT"])/"e03_source";print(len(list(p.glob("*.txt"))))',
                           {'output_number': {'op': 'eq', 'value': 7}}),
        }
        observed = set()
        for name, _, document in self.documents():
            if name != 'TEST_SPEC_EASY.md': continue
            for case in E.iter_cases(document):
                if case['id'] not in probes: continue
                program, predicate = probes[case['id']]
                owned = {**case, 'argv': [sys.executable, '-c', program], 'expect': predicate, 'timeout': 10}
                owned.pop('command', None)
                result = E.run_case(owned)
                self.assertEqual(result['status'], 'PASS', (case['id'], result))
                observed.add(case['id'])
        self.assertEqual(observed, set(probes))


if __name__ == '__main__':
    unittest.main()
