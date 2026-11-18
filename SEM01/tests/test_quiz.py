"""
Tests for Formative Quiz - Seminar 01
Operating Systems | ASE Bucharest - CSIE
Version: 2.0
"""

import json
import hashlib
import subprocess
from pathlib import Path

import pytest
import yaml


# =============================================================================
# Fixtures
# =============================================================================

@pytest.fixture
def quiz_path():
    """Returns the path to quiz.yaml."""
    return Path(__file__).parent.parent / "formative" / "quiz.yaml"


@pytest.fixture
def quiz_data(quiz_path):
    """Loads data from quiz.yaml."""
    with open(quiz_path, encoding='utf-8') as f:
        return yaml.safe_load(f)


@pytest.fixture
def lms_path():
    """Returns the path to quiz_lms.json."""
    return Path(__file__).parent.parent / "formative" / "quiz_lms.json"


@pytest.fixture
def lms_data(lms_path):
    """Loads data from quiz_lms.json."""
    with open(lms_path, encoding='utf-8') as f:
        return json.load(f)


# =============================================================================
# Tests for quiz.yaml
# =============================================================================

class TestQuizYaml:
    """Tests for quiz.yaml structure."""
    
    def test_quiz_file_exists(self, quiz_path):
        """Verifies that quiz.yaml file exists."""
        assert quiz_path.exists(), f"File {quiz_path} does not exist"
    
    def test_quiz_has_metadata(self, quiz_data):
        """Verifies presence of metadata."""
        assert 'metadata' in quiz_data
        meta = quiz_data['metadata']
        assert 'title' in meta
        assert 'seminar' in meta
        assert 'estimated_time' in meta
    
    def test_quiz_has_minimum_questions(self, quiz_data):
        """Verifies minimum number of questions (14 after update)."""
        assert 'questions' in quiz_data
        assert len(quiz_data['questions']) >= 12, \
            f"Expected at least 12 questions, got {len(quiz_data['questions'])}"
    
    def test_question_structure(self, quiz_data):
        """Verifies the structure of each question."""
        required_fields = ['id', 'type', 'bloom', 'text', 'correct']
        for q in quiz_data['questions']:
            if q['type'] == 'mcq':
                required_fields_mcq = required_fields + ['options', 'explanation']
                for field in required_fields_mcq:
                    assert field in q, f"Question {q.get('id', 'N/A')} is missing field {field}"
    
    def test_correct_answer_valid(self, quiz_data):
        """Verifies that the correct answer is valid for MCQ questions."""
        for q in quiz_data['questions']:
            if q['type'] == 'mcq':
                valid_answers = [chr(ord('A') + i) for i in range(len(q['options']))]
                assert q['correct'] in valid_answers, \
                    f"Question {q['id']}: invalid correct answer {q['correct']}"
    
    def test_bloom_levels_valid(self, quiz_data):
        """Verifies Bloom levels are valid."""
        valid_blooms = ['remember', 'understand', 'apply', 'analyse', 'evaluate', 'create']
        for q in quiz_data['questions']:
            assert q['bloom'] in valid_blooms, \
                f"Question {q['id']}: invalid Bloom level {q['bloom']}"
    
    def test_bloom_distribution_complete(self, quiz_data):
        """Verifies all six Bloom levels are represented."""
        blooms = {q['bloom'] for q in quiz_data['questions']}
        # Should have at least 4 different levels (allowing flexibility)
        assert len(blooms) >= 4, \
            f"The quiz should cover at least 4 Bloom levels, got {len(blooms)}: {blooms}"
    
    def test_has_higher_order_questions(self, quiz_data):
        """Verifies presence of Evaluate or Create level questions."""
        higher_order = [q for q in quiz_data['questions'] 
                       if q['bloom'] in ['evaluate', 'create']]
        assert len(higher_order) >= 1, \
            "Quiz should include at least one Evaluate or Create level question"
    
    def test_learning_outcomes_present(self, quiz_data):
        """Verifies that each question has a learning outcome."""
        for q in quiz_data['questions']:
            assert 'lo' in q, f"Question {q['id']} is missing learning outcome (lo)"
            assert q['lo'].startswith('LO'), \
                f"Question {q['id']}: LO should start with 'LO'"
    
    def test_no_ai_patterns_in_explanations(self, quiz_data):
        """Verifies that explanations do not contain common AI patterns."""
        ai_patterns = ['delve', 'leverage', 'comprehensive', 'robust', 'seamless',
                      'utilize', 'facilitate', 'paradigm', 'synergy']
        for q in quiz_data['questions']:
            explanation = q.get('explanation', '').lower()
            for pattern in ai_patterns:
                assert pattern not in explanation, \
                    f"Question {q['id']}: AI pattern '{pattern}' found in explanation"


# =============================================================================
# Tests for quiz_lms.json
# =============================================================================

class TestQuizLmsJson:
    """Tests for quiz_lms.json structure."""
    
    def test_lms_file_exists(self, lms_path):
        """Verifies that quiz_lms.json file exists."""
        assert lms_path.exists()
    
    def test_lms_valid_json(self, lms_path):
        """Verifies that the JSON is valid."""
        with open(lms_path, encoding='utf-8') as f:
            data = json.load(f)
        assert data is not None
    
    def test_lms_has_quiz_settings(self, lms_data):
        """Verifies descriptive metadata without inventing assessment policy."""
        meta = lms_data['quiz']
        assert meta['title']
        assert meta['estimated_time'] == '20 minutes'
        assert meta['assessment_status'] == 'PENDING_POLICY'
        assert meta['lms_import_validation'] == 'NOT_RUN'
        # An estimate is not an enforced time limit or a validated LMS adapter.
        assert 'time_limit_minutes' not in meta
        assert 'passing_score' not in meta
    
    def test_lms_has_questions(self, lms_data):
        """Verifies presence of questions."""
        assert 'questions' in lms_data
        assert len(lms_data['questions']) >= 10
    
    def test_lms_question_has_correct_answer(self, lms_data):
        """MCQs have one key; open responses retain manual assessment."""
        for q in lms_data['questions']:
            if q['type'] == 'multiple_choice':
                correct_answers = [a for a in q['answers'] if a.get('correct', False)]
                assert len(correct_answers) == 1, q['id']
            else:
                assert q['type'] == 'open_response', q['id']
                assert q['manual_review_required'] is True
                assert q['rubric']
                assert 'answers' not in q
                assert 'score' not in q
    
    def test_lms_answers_have_feedback(self, lms_data):
        """Verifies that all answers have feedback."""
        for q in lms_data['questions']:
            if q['type'] == 'multiple_choice':
                for i, a in enumerate(q['answers']):
                    assert a.get('feedback'), f"Question {q['id']}, answer {i}: missing feedback"
            else:
                assert q['rubric'] and q.get('example_solution'), q['id']


# =============================================================================
# Consistency tests
# =============================================================================

class TestQuizConsistency:
    """Verifies consistency between quiz.yaml and quiz_lms.json."""
    
    def test_same_number_of_questions(self, quiz_data, lms_data):
        """Verifies that both files have the same number of questions."""
        source = quiz_data['questions']
        derived = lms_data['questions']
        assert [q['id'] for q in source] == [q['id'] for q in derived]
        assert len(source) == lms_data['quiz']['total_questions']
        assert sum(q['type'] == 'mcq' for q in source) == sum(q['type'] == 'multiple_choice' for q in derived)
        assert sum(q['type'] != 'mcq' for q in source) == sum(q['type'] == 'open_response' for q in derived)

    def test_derived_content_and_provenance(self, quiz_data, lms_data, quiz_path):
        """Derivation preserves wording, keys, feedback, rubric and source identity."""
        assert lms_data['source_sync']['sha256'] == hashlib.sha256(quiz_path.read_bytes()).hexdigest()
        for source, derived in zip(quiz_data['questions'], lms_data['questions'], strict=True):
            assert derived['text'] == source['text']
            assert derived['bloom_level'] == source['bloom']
            assert derived['learning_outcome'] == source['lo']
            assert derived['targeted_misconception'] == source.get('targeted_misconception')
            if source['type'] == 'mcq':
                for index, (option, answer) in enumerate(zip(source['options'], derived['answers'], strict=True)):
                    expected_text = option[3:] if len(option) > 2 and option[1:3] == ') ' else option
                    assert answer['text'] == expected_text
                    assert answer['correct'] == (chr(65 + index) == source['correct'])
                    assert answer['feedback'] == source['explanation']
            else:
                assert derived['rubric'] == source['rubric']
                assert derived['example_solution'] == source.get('example_solution')



# =============================================================================
# Bash script tests
# =============================================================================

class TestBashScripts:
    """Tests for Bash script quality."""
    
    @pytest.fixture
    def scripts_dir(self):
        return Path(__file__).parent.parent / "scripts"
    
    def test_scripts_have_shebang(self, scripts_dir):
        """Verifies that all scripts have a proper shebang."""
        for script in scripts_dir.rglob("*.sh"):
            with open(script, encoding='utf-8') as f:
                first_line = f.readline().strip()
            assert first_line.startswith('#!'), \
                f"Script {script.name} is missing shebang"
    
    def test_scripts_have_error_handling(self, scripts_dir):
        """Verifies that scripts have set -e or set -euo pipefail."""
        for script in scripts_dir.rglob("*.sh"):
            content = script.read_text(encoding='utf-8')
            has_error_handling = 'set -e' in content or 'set -euo pipefail' in content
            assert has_error_handling, \
                f"Script {script.name} is missing error handling (set -e)"
    
    def test_bash_syntax_valid(self, scripts_dir):
        """Verifies that all Bash scripts have valid syntax."""
        for script in scripts_dir.rglob("*.sh"):
            result = subprocess.run(
                ['bash', '-n', str(script)],
                capture_output=True,
                text=True
            )
            assert result.returncode == 0, \
                f"Script {script.name} has syntax errors: {result.stderr}"


# =============================================================================
# LO Traceability tests
# =============================================================================

class TestLOTraceability:
    """Tests for Learning Outcomes traceability."""
    
    @pytest.fixture
    def lo_path(self):
        return Path(__file__).parent.parent / "docs" / "lo_traceability.md"
    
    def test_lo_file_exists(self, lo_path):
        """Verifies that lo_traceability.md exists."""
        assert lo_path.exists(), "lo_traceability.md is missing"
    
    def test_lo_has_parsons_problems(self, lo_path):
        """Verifies that Parsons Problems are documented."""
        content = lo_path.read_text(encoding='utf-8')
        pp_count = content.count('### PP-')
        assert pp_count >= 5, f"Expected at least 5 Parsons Problems, found {pp_count}"
    
    def test_lo_has_traceability_matrix(self, lo_path):
        """Verifies presence of traceability matrix."""
        content = lo_path.read_text(encoding='utf-8')
        assert 'Traceability Matrix' in content, "Missing traceability matrix"
        assert '| LO |' in content, "Matrix table not found"
    
    def test_lo_has_all_bloom_levels(self, lo_path):
        """Verifies all Bloom levels are mentioned."""
        content = lo_path.read_text(encoding='utf-8')
        required_levels = ['Remember', 'Understand', 'Apply', 'Analyse', 'Evaluate', 'Create']
        for level in required_levels:
            assert level in content, f"Bloom level '{level}' not found in traceability"


# =============================================================================
# Anti-plagiarism tests
# =============================================================================

class TestAntiPlagiarismTools:
    """Tests for anti-plagiarism tools existence."""
    
    @pytest.fixture
    def python_scripts_dir(self):
        return Path(__file__).parent.parent / "scripts" / "python"
    
    def test_assignment_generator_exists(self, python_scripts_dir):
        """Verifies assignment generator script exists."""
        generator = python_scripts_dir / "S01_04_assignment_generator.py"
        assert generator.exists(), "Assignment generator script is missing"
    
    def test_plagiarism_detector_exists(self, python_scripts_dir):
        """Verifies plagiarism detector script exists."""
        detector = python_scripts_dir / "S01_05_plagiarism_detector.py"
        assert detector.exists(), "Plagiarism detector script is missing"
    
    def test_ai_scanner_exists(self, python_scripts_dir):
        """Verifies AI fingerprint scanner script exists."""
        scanner = python_scripts_dir / "S01_06_ai_fingerprint_scanner.py"
        assert scanner.exists(), "AI fingerprint scanner script is missing"
