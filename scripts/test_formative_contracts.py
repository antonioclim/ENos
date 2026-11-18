"""Exercise the public formative data and CLI contracts with owned local files.

These are process/fixture checks, not LMS, interactive terminal or teaching-
effectiveness acceptance. Question snippets are never executed by the runners.
"""
from copy import deepcopy
import importlib.util
import io
import contextlib
import json
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest

import yaml

from lib.quiz_contract import export_bank, validate_bank

ROOT = Path(__file__).resolve().parents[1]


def bank(seminar):
    path = ROOT/seminar/'formative/quiz.yaml'
    return path, yaml.safe_load(path.read_text(encoding='utf-8'))


def cli(seminar, *args, input_text=''):
    return subprocess.run([sys.executable, str(ROOT/seminar/'formative/quiz_runner.py'),
                           *map(str, args)], input=input_text, text=True,
                          capture_output=True, timeout=30, cwd=ROOT)


class TestFormativeContracts(unittest.TestCase):
    def test_canonical_question_counts_and_authored_weights(self):
        for seminar, count, points in [('SEM05', 18, 102), ('SEM06', 23, 140)]:
            with self.subTest(seminar=seminar):
                _, data = bank(seminar)
                self.assertEqual(validate_bank(data)['question_count'], count)
                self.assertEqual(validate_bank(data)['total_points'], points)

    def test_malformed_banks_are_rejected_before_interaction(self):
        _, original = bank('SEM05')
        cases = [None, {}, {'metadata': {}, 'questions': []}]
        for key, value in [('id', ''), ('correct_answer', True), ('correct_answer', 99),
                           ('points', float('nan')), ('points', 0), ('points', True),
                           ('question', ''), ('bloom', []), ('code', {}), ('options', ['only'])]:
            data = deepcopy(original)
            data['questions'][0][key] = value
            cases.append(data)
        data = deepcopy(original); data['questions'][1]['id'] = data['questions'][0]['id']; cases.append(data)
        data = deepcopy(original); data['metadata']['total_points'] = 100; cases.append(data)
        data = deepcopy(original); data['metadata']['question_count'] = 17; cases.append(data)
        data = deepcopy(original); data['metadata']['bloom_distribution']['evaluate'] = True; cases.append(data)
        for index, data in enumerate(cases):
            with self.subTest(case=index), self.assertRaises(ValueError):
                validate_bank(data)

    def test_exports_preserve_all_source_questions_and_answer_identity(self):
        for seminar in ('SEM05', 'SEM06'):
            with self.subTest(seminar=seminar):
                path, data = bank(seminar)
                exported = export_bank(data, path)
                # JSON object keys are text (e.g. numeric feedback thresholds).
                encoded = json.loads(json.dumps(exported))
                self.assertEqual(encoded, json.loads(path.with_name('quiz_lms.json').read_text()))
                self.assertIn('not Moodle XML', exported['format'])
                for question, record in zip(data['questions'], exported['questions']):
                    self.assertEqual(record['source_question'], question)
                    answers = [answer for answer in record['answers'] if answer['correct']]
                    self.assertEqual(len(answers), 1)
                    expected = (chr(97+question['correct_answer']) if seminar == 'SEM05' else question['correct'])
                    self.assertEqual(answers[0]['id'], expected)
                with tempfile.TemporaryDirectory() as temporary:
                    output = Path(temporary)/'bank.json'
                    result = cli(seminar, path, '--export-bank', output)
                    self.assertEqual(result.returncode, 0, result.stderr)
                    self.assertEqual(json.loads(output.read_text()), encoded)

    def test_complete_current_cli_sessions_score_all_41_answers(self):
        with tempfile.TemporaryDirectory() as temporary:
            for seminar in ('SEM05', 'SEM06'):
                with self.subTest(seminar=seminar):
                    path, data = bank(seminar)
                    output = Path(temporary)/(seminar+'.json')
                    if seminar == 'SEM05':
                        answers = '\n\n'.join(chr(65+q['correct_answer']) for q in data['questions'])+'\n'
                        args = [path, '--no-rich', '--export-results', output]
                    else:
                        answers = '\n'+'\n'.join(q['correct'] for q in data['questions'])+'\n'
                        args = [path, '--export', output]
                    result = cli(seminar, *args, input_text=answers)
                    self.assertEqual(result.returncode, 0, result.stderr)
                    self.assertIn('100.0%', result.stdout)
                    session = json.loads(output.read_text())
                    if seminar == 'SEM05':
                        self.assertEqual((session['correct_answers'], session['earned_points'], session['max_points']), (18, 102, 102))
                    else:
                        self.assertEqual((session['score'], session['total'], session['percentage']), (140, 140, 100))
                        self.assertIn('not institutional', session['passed_semantics'])
                    self.assertIn('Formative', session['assessment_scope'])

    def test_interrupted_cli_session_does_not_export_completed_result(self):
        with tempfile.TemporaryDirectory() as temporary:
            for seminar, flag in [('SEM05', '--export-results'), ('SEM06', '--export')]:
                with self.subTest(seminar=seminar):
                    path, _ = bank(seminar)
                    output = Path(temporary)/(seminar+'.json')
                    result = cli(seminar, path, flag, output)
                    self.assertEqual(result.returncode, 130, result.stderr)
                    self.assertFalse(output.exists())

    def test_runner_rejects_other_seminar_schema_clearly(self):
        for seminar, other in [('SEM05', 'SEM06'), ('SEM06', 'SEM05')]:
            with self.subTest(seminar=seminar):
                path, _ = bank(other)
                result = cli(seminar, path, '--validate')
                self.assertEqual(result.returncode, 1)
                self.assertNotIn('Traceback', result.stdout+result.stderr)

    def test_all_sem05_prompts_hide_option_feedback_until_answer(self):
        spec = importlib.util.spec_from_file_location('formative_contract_sem05', ROOT/'SEM05/formative/quiz_runner.py')
        module = importlib.util.module_from_spec(spec); sys.modules[spec.name] = module; spec.loader.exec_module(module)
        path, data = bank('SEM05')
        runner = module.QuizRunner(path, use_rich=False)
        for i, question in enumerate(data['questions'], 1):
            output = io.StringIO()
            with contextlib.redirect_stdout(output):
                runner._display_question(question, i, len(data['questions']))
            rendered = output.getvalue()
            self.assertIn(question['question'], rendered)
            self.assertNotIn("'explanation':", rendered)
            self.assertNotIn('CORRECT —', rendered)
            self.assertNotIn('CORRECT -', rendered)

    def test_builder_check_is_read_only_and_current(self):
        paths = [bank(name)[0].with_name('quiz_lms.json') for name in ('SEM05', 'SEM06')]
        before = [path.read_bytes() for path in paths]
        result = subprocess.run([sys.executable, str(ROOT/'scripts/build_formative_exports.py'), '--check'], capture_output=True, text=True, timeout=30)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(before, [path.read_bytes() for path in paths])


if __name__ == '__main__':
    unittest.main()
