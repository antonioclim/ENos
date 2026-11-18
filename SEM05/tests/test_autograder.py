#!/usr/bin/env python3
"""Semantic regression tests: every assertion calls the maintained implementation.

Fixtures are generated locally. These diagnostics do not certify institutional
assessment policy or exhaustive Bash static analysis.
"""
import contextlib
import importlib.util
import io
import json
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT/'scripts/python'))
from S05_01_autograder import BashAutograder
from S05_03_report_generator import load_grades_file, calculate_statistics


class TestAutograderSemantics(unittest.TestCase):
    def setUp(self):
        self.grader = BashAutograder()

    def test_shebangs(self):
        for text in ('#!/bin/bash', '#!/usr/bin/env bash', '#!/bin/bash -e'):
            with self.subTest(text=text):
                self.assertTrue(self.grader.check_shebang(text+'\necho ok').passed)
        for text in ('#!/bin/sh', '', '#!/bin/bashnotreal', '# comment'):
            with self.subTest(text=text):
                self.assertFalse(self.grader.check_shebang(text).passed)

    def test_combined_separate_and_disabled_strict_options(self):
        for text in ('set -euo pipefail', 'set -e\nset -u\nset -o pipefail', 'set -o errexit\nset -o nounset\nset -o pipefail'):
            self.assertEqual(self.grader.check_strict_mode(text).points, 3)
        self.assertEqual(self.grader.check_strict_mode('set -e').points, 1)
        self.assertEqual(self.grader.check_strict_mode('set -euo pipefail\nset +u').points, 2)
        self.assertEqual(self.grader.check_strict_mode('# set -euo pipefail\necho "set -euo pipefail"').points, 0)

    def test_local_and_global_variable_diagnostics(self):
        self.assertTrue(self.grader.check_local_variables('f() {\nlocal x=1\necho "$x"\n}').passed)
        self.assertFalse(self.grader.check_local_variables('f() {\nx=1\necho "$x"\n}').passed)

    def test_associative_array_declaration(self):
        self.assertTrue(self.grader.check_associative_arrays('declare -A config\nconfig[host]=local').passed)
        self.assertFalse(self.grader.check_associative_arrays('config[host]=local').passed)

    def test_quoted_array_loop(self):
        self.assertTrue(self.grader.check_quoted_arrays('for x in "${arr[@]}"; do echo "$x"; done').passed)
        self.assertFalse(self.grader.check_quoted_arrays('for x in ${arr[@]}; do echo "$x"; done').passed)

    def test_cleanup_and_usage(self):
        self.assertTrue(self.grader.check_trap_cleanup('cleanup() { :; }\ntrap cleanup EXIT').passed)
        self.assertFalse(self.grader.check_trap_cleanup('echo no-cleanup').passed)
        for name in ('usage', 'show_help', 'print_help'):
            self.assertTrue(self.grader.check_usage_function(name+'() { :; }').passed)

    def test_unavailable_shellcheck_does_not_pass(self):
        with patch('subprocess.run', side_effect=FileNotFoundError):
            result, _ = self.grader.run_shellcheck('fixture.sh')
        self.assertFalse(result.passed)
        self.assertEqual(result.points, 0)
        self.assertIn('NOT_RUN', result.message)

    def test_relative_script_path_with_spaces(self):
        with tempfile.TemporaryDirectory() as td:
            path = Path(td)/'dir with spaces'/'script.sh';path.parent.mkdir()
            path.write_text('printf "%s" "$1"\n')
            import os
            relative = os.path.relpath(path)
            self.assertEqual(self.grader.run_script(relative, ['literal argument']), (True, 'literal argument', 0))

    def test_exact_json_stdout_round_trips(self):
        with tempfile.TemporaryDirectory() as td:
            script = Path(td)/'student.sh';script.write_text('#!/bin/bash\nset -euo pipefail\n')
            process = subprocess.run([sys.executable, str(ROOT/'scripts/python/S05_01_autograder.py'), str(script), '--json', '--verbose'], capture_output=True, text=True)
            data = json.loads(process.stdout)
            self.assertEqual(data[0]['script'], str(script))
            source = Path(td)/'report.json';source.write_text(process.stdout)
            statistics = calculate_statistics(load_grades_file(source))
            self.assertAlmostEqual(statistics['avg_score'], data[0]['percentage'])
            self.assertEqual(statistics['records'][0]['script'], str(script))

    def test_report_80_percent_and_invalid_input(self):
        with tempfile.TemporaryDirectory() as td:
            source = Path(td)/'report.json'
            source.write_text(json.dumps([{'script':'fixture.sh','score':8,'max_score':10,'checks':[{'name':'Example diagnostic','points':8,'max_points':10,'passed':False,'message':'gap'}]}]))
            result = calculate_statistics(load_grades_file(source))
            self.assertEqual(result['avg_score'], 80)
            source.write_text('{"unrecognised": 80}')
            with self.assertRaises(ValueError):load_grades_file(source)

    def test_shell_validator_continues_after_failed_check(self):
        with tempfile.TemporaryDirectory() as td:
            path=Path(td)/'weak.sh';path.write_text('#!/bin/bash\nf() { x=1; }\n')
            result=subprocess.run(['bash',str(ROOT/'scripts/bash/S05_03_validator.sh'),str(path)],capture_output=True,text=True)
            self.assertEqual(result.returncode, 1)
            self.assertIn('RESULT', result.stdout)
            self.assertNotIn('syntax error', result.stderr)

    def test_template_preserves_text_bytes_and_verbose(self):
        with tempfile.TemporaryDirectory() as td:
            path=Path(td)/'input';path.write_bytes(b'-n\n-e\nlast')
            result=subprocess.run(['bash',str(ROOT/'scripts/templates/professional_script.sh'),'-v','--log',str(Path(td)/'log'),str(path)],capture_output=True)
            self.assertEqual(result.returncode,0,result.stderr)
            self.assertEqual(result.stdout,path.read_bytes())

    def test_quiz_prompt_hides_distractor_explanations(self):
        spec=importlib.util.spec_from_file_location('s05_quiz_under_test',ROOT/'formative/quiz_runner.py')
        mod=importlib.util.module_from_spec(spec);sys.modules[spec.name]=mod;spec.loader.exec_module(mod)
        runner=mod.QuizRunner(str(ROOT/'formative/quiz.yaml'),use_rich=False)
        buffer=io.StringIO()
        with contextlib.redirect_stdout(buffer):runner._display_question(runner.quiz_data['questions'][0],1,1)
        text=buffer.getvalue()
        self.assertIn('What does the last line display?',text)
        self.assertNotIn('CORRECT -',text)
        self.assertNotIn("'explanation':",text)

    def test_bash_quiz_completes_first_and_subsequent_answers(self):
        result=subprocess.run(['bash',str(ROOT/'scripts/bash/S05_02_interactive_quiz.sh'),'--quick'],input='B\nC\nB\n',capture_output=True,text=True)
        self.assertEqual(result.returncode,0,result.stderr)
        self.assertIn('3 / 3',result.stdout)


if __name__ == '__main__':
    unittest.main()
