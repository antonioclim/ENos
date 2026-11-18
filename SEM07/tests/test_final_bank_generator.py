"""Local draft generation contracts; these tests do not validate exam policy."""
from copy import deepcopy
import hashlib
import importlib.util
import json
from pathlib import Path
import random
import subprocess
import sys

import pytest
import yaml

GENERATOR = Path(__file__).resolve().parents[1] / 'final_test/test_bank/test_generator.py'
POOL = GENERATOR.with_name('questions_pool.yaml')
SPEC = importlib.util.spec_from_file_location('enos_final_bank_generator', GENERATOR)
generator = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(generator)


def small_pool():
    common = {'difficulty': 'easy', 'bloom': 'understand', 'points': 0.5}
    return {
        'metadata': {'course': 'Operating Systems', 'author': 'Fixture author'},
        'categories': [
            {'name': 'Shell', 'questions': [
                {**common, 'id': 'A', 'type': 'multiple_choice', 'question': 'Select a shell.',
                 'options': {'a': 'Bash', 'b': 'A processor', 'c': 'A disk'}, 'answer': 'a',
                 'explanation': 'ANSWER_EXPLANATION_SENTINEL', 'source': 'ANSWER_SOURCE_SENTINEL'},
                {**common, 'id': 'B', 'type': 'short_answer', 'question': 'Name a shell.',
                 'answer': 'Bash', 'accept_alternatives': ['dash'], 'keywords': ['ANSWER_KEYWORD_SENTINEL']}]},
            {'name': 'Code', 'questions': [
                {**common, 'id': 'C', 'type': 'practical', 'question': 'Review the printed code.',
                 'points': 2, 'difficulty': 'hard', 'code': 'raise RuntimeError("never execute question code")',
                 'answer': 'Review only'}]},
        ],
    }


def generate_all(data, seed=7):
    questions, _ = generator.validate_pool(data)
    return generator.generate(data, len(questions), seed, '0' * 64)


def test_preserves_authored_identity_weights_and_source_without_mutation():
    data = small_pool()
    original = deepcopy(data)
    paper, key = generate_all(data)
    assert data == original
    assert {q['id']: q['points'] for q in paper['questions']} == {'A': 0.5, 'B': 0.5, 'C': 2}
    assert paper['metadata']['total_points'] == 3
    assert paper['metadata']['source_author'] == 'Fixture author'
    assert key['metadata']['institutional_policy'] == 'PENDING_POLICY'
    assert 'Fixture author' in generator.markdown(paper)
    assert all('grade' not in q and 'passed' not in q for q in key['answers'])


def test_option_permutations_preserve_answer_meaning_and_do_not_touch_global_rng():
    data = small_pool()
    before = random.getstate()
    positions = set()
    for seed in range(40):
        paper, key = generate_all(data, seed)
        question = next(q for q in paper['questions'] if q['id'] == 'A')
        answer = next(q for q in key['answers'] if q['id'] == 'A')
        positions.add(answer['answer'])
        assert question['options'][answer['answer']] == 'Bash'
        assert answer['presented_to_source_option'][answer['answer']] == 'a'
        assert len(set(question['options'].values())) == 3
    assert positions == {'a', 'b', 'c'}
    assert random.getstate() == before
    assert generate_all(data, 7) == generate_all(data, 7)


def test_student_payload_excludes_answer_only_fields_and_retains_printed_code():
    paper, key = generate_all(small_pool())
    for question in paper['questions']:
        assert not ({'answer', 'explanation', 'keywords', 'source', 'accept_alternatives', 'presented_to_source_option'} & question.keys())
    text = generator.markdown(paper)
    assert 'ANSWER_' not in text
    assert 'never execute question code' in text
    assert sum('MANUAL_REVIEW_REQUIRED' in q.get('review_mode', '') for q in key['answers']) == 2
    assert 'ANSWER_EXPLANATION_SENTINEL' in generator.markdown(key, True)


def test_filters_select_without_replacement_and_do_not_rescale_points():
    data = small_pool()
    paper, _ = generator.generate(data, 2, 4, 'a' * 64, ['sHeLl'], 'easy')
    assert {q['id'] for q in paper['questions']} == {'A', 'B'}
    assert paper['metadata']['total_points'] == 1
    paper, _ = generator.generate(data, 1, 4, 'a' * 64, question_type='practical')
    assert paper['questions'][0]['id'] == 'C'
    for args in [dict(count=4), dict(count=0), dict(count=True), dict(count=1, seed=True),
                 dict(count=1, categories=['unknown']), dict(count=2, difficulty='hard'),
                 dict(count=1, question_type='code_analysis'), dict(count=1, difficulty='unknown')]:
        params = dict(data=data, seed=3, source_hash='a' * 64)
        params.update(args)
        with pytest.raises(ValueError):
            generator.generate(**params)


@pytest.mark.parametrize('case', ['duplicate_id', 'duplicate_option', 'bad_key', 'nan', 'bool_points',
                                 'non_mc_options', 'wrong_count', 'wrong_stats', 'wrong_total', 'wrong_author'])
def test_invalid_schema_fails_before_generation(case):
    data = small_pool()
    q = data['categories'][0]['questions'][0]
    if case == 'duplicate_id':
        data['categories'][1]['questions'][0]['id'] = 'A'
    elif case == 'duplicate_option':
        q['options']['b'] = 'Bash'
    elif case == 'bad_key':
        q['answer'] = 'z'
    elif case == 'nan':
        q['points'] = float('nan')
    elif case == 'bool_points':
        q['points'] = True
    elif case == 'non_mc_options':
        data['categories'][0]['questions'][1]['options'] = {'a': 'Bash'}
    elif case == 'wrong_count':
        data['metadata']['total_questions'] = 4
    elif case == 'wrong_stats':
        data['metadata']['statistics'] = {'by_type': {'multiple_choice': 3}}
    elif case == 'wrong_total':
        data['metadata']['total_points'] = 100
    elif case == 'wrong_author':
        data['metadata']['author'] = ['Unknown']
    with pytest.raises(ValueError):
        generator.validate_pool(data)


def test_duplicate_yaml_keys_are_rejected(tmp_path):
    path = tmp_path / 'duplicate.yaml'
    path.write_text('metadata:\n  course: First\n  course: Replaced\ncategories: []\n')
    with pytest.raises(ValueError, match='Duplicate YAML'):
        generator.load_pool(path)


@pytest.mark.parametrize('output_format', ['markdown', 'json', 'yaml'])
def test_cli_writes_separate_parseable_outputs_and_byte_manifest(tmp_path, output_format):
    path = tmp_path / 'pool.yaml'
    path.write_text(yaml.safe_dump(small_pool()), encoding='utf-8')
    source_hash = hashlib.sha256(path.read_bytes()).hexdigest()
    output = tmp_path / 'form'
    command = [sys.executable, str(GENERATOR), '--input', str(path), '--questions', '3',
               '--seed', '12345', '--format', output_format, '--output', str(output)]
    result = subprocess.run(command, capture_output=True, text=True, timeout=15)
    assert result.returncode == 0, result.stderr
    assert json.loads(result.stdout)['question_count'] == 3
    manifest = json.loads((output / 'manifest.json').read_text())
    assert len(manifest['files']) == 2
    for record in manifest['files']:
        content = (output / record['path']).read_bytes()
        assert len(content) == record['bytes']
        assert hashlib.sha256(content).hexdigest() == record['sha256']
    suffix = {'markdown': 'md', 'json': 'json', 'yaml': 'yaml'}[output_format]
    paper_text = (output / ('questions.' + suffix)).read_text()
    key_text = (output / ('answer_key.' + suffix)).read_text()
    assert 'ANSWER_EXPLANATION_SENTINEL' not in paper_text
    assert 'ANSWER_EXPLANATION_SENTINEL' in key_text
    if output_format != 'markdown':
        parse = json.loads if output_format == 'json' else yaml.safe_load
        assert parse(paper_text)['metadata']['source_bank_sha256'] == source_hash
        assert parse(key_text)['metadata']['document_role'] == 'separate_review_key'
    before = {p.name: p.read_bytes() for p in output.iterdir()}
    repeated = subprocess.run(command, capture_output=True, text=True, timeout=15)
    assert repeated.returncode != 0
    assert {p.name: p.read_bytes() for p in output.iterdir()} == before
    assert hashlib.sha256(path.read_bytes()).hexdigest() == source_hash


def test_partial_write_error_cleans_only_owned_output(tmp_path, monkeypatch):
    paper, key = generate_all(small_pool())
    output = tmp_path / 'form'
    real_open = Path.open

    class BrokenStream:
        def __init__(self, stream):
            self.stream = stream
        def __enter__(self):
            return self
        def __exit__(self, *args):
            return self.stream.__exit__(*args)
        def write(self, data):
            self.stream.write(data[:4])
            raise OSError('Injected partial-write failure')

    def patched_open(path, *args, **kwargs):
        stream = real_open(path, *args, **kwargs)
        return BrokenStream(stream) if path.name == 'answer_key.json' else stream

    monkeypatch.setattr(Path, 'open', patched_open)
    with pytest.raises(OSError, match='Injected'):
        generator.write_bundle(output, paper, key, 'json')
    assert not output.exists()


def test_current_pool_metadata_all_answers_and_full_native_cli(tmp_path):
    data, questions, counts, source_hash = generator.load_pool(POOL)
    assert counts['total_questions'] == 296
    assert counts['categories'] == 13
    assert counts['total_points'] == 178
    assert counts['statistics']['by_type'] == {'multiple_choice': 262, 'practical': 8, 'short_answer': 26}
    originals = {q['id']: q for q in questions}
    original_bytes = POOL.read_bytes()
    for seed in (0, 7, 12345):
        paper, key = generator.generate(data, 296, seed, source_hash)
        shown = {q['id']: q for q in paper['questions']}
        assert set(shown) == set(originals)
        assert all(shown[k]['points'] == originals[k]['points'] for k in shown)
        for answer in key['answers']:
            if answer['type'] == 'multiple_choice':
                old = originals[answer['id']]
                assert shown[answer['id']]['options'][answer['answer']] == old['options'][old['answer']]
    result = subprocess.run([sys.executable, str(GENERATOR), '--input', str(POOL), '--questions', '296',
                             '--seed', '12345', '--format', 'yaml', '--output', str(tmp_path / 'full')],
                            capture_output=True, text=True, timeout=30)
    assert result.returncode == 0, result.stderr
    assert json.loads(result.stdout)['total_points'] == 178
    assert POOL.read_bytes() == original_bytes
