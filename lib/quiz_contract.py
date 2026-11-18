"""Validate the two seminar bank schemas and produce local data exports.

No function executes the question code, selects a course grading policy or
contacts an LMS. The original question fields are retained in each export.
"""
from collections import Counter
from copy import deepcopy
import hashlib
import math

BLOOM = {'remember', 'understand', 'apply', 'analyse', 'evaluate', 'create'}


def validate_bank(data):
    if not isinstance(data, dict) or not isinstance(data.get('metadata'), dict):
        raise ValueError('A bank requires a metadata mapping')
    questions = data.get('questions', data.get('intrebari'))
    if not isinstance(questions, list) or not questions:
        raise ValueError('A bank requires a non-empty question list')
    seen, total, levels = set(), 0, Counter()
    for q in questions:
        if not isinstance(q, dict):
            raise ValueError('Each question must be a mapping')
        ident = q.get('id')
        if not isinstance(ident, str) or not ident.strip() or ident in seen:
            raise ValueError('Question IDs must be non-empty and unique')
        seen.add(ident)
        prompt = q.get('question', q.get('text'))
        if not isinstance(prompt, str) or not prompt.strip():
            raise ValueError(f'{ident}: missing question text')
        options = q.get('options', q.get('optiuni'))
        if isinstance(options, list):
            texts = [o.get('text') if isinstance(o, dict) else o for o in options]
            correct = q.get('correct_answer')
            valid_key = type(correct) is int and 0 <= correct < len(options)
        elif isinstance(options, dict):
            texts = list(options.values())
            correct = q.get('correct', q.get('corect'))
            valid_key = isinstance(correct, str) and correct in options
            if any(not isinstance(k, str) or len(k) != 1 or k not in 'abcdefghijklmnopqrstuvwxyz' for k in options):
                raise ValueError(f'{ident}: option keys must be distinct lower-case ASCII letters')
        else:
            raise ValueError(f'{ident}: options must be a list or mapping')
        if not 2 <= len(texts) <= 26 or any(not isinstance(t, str) or not t.strip() for t in texts) or not valid_key:
            raise ValueError(f'{ident}: invalid answer choices or key')
        points = q.get('points', q.get('puncte', 5))
        if type(points) not in (int, float) or not math.isfinite(points) or points <= 0:
            raise ValueError(f'{ident}: points must be finite and positive')
        level = q.get('bloom', 'understand')
        if not isinstance(level, str) or level not in BLOOM:
            raise ValueError(f'{ident}: unknown Bloom label')
        for field in ('explanation', 'explicatie', 'code'):
            if field in q and not isinstance(q[field], str):
                raise ValueError(f'{ident}: {field} must be text')
        for field in ('misconceptions', 'misconceptii'):
            if field in q and (not isinstance(q[field], dict) or
                               any(not isinstance(k, str) or not isinstance(v, str) for k, v in q[field].items())):
                raise ValueError(f'{ident}: {field} must map answer letters to feedback text')
        total += points
        levels[level] += 1
    metadata = data['metadata']
    if 'question_count' in metadata and (type(metadata['question_count']) is not int or metadata['question_count'] != len(questions)):
        raise ValueError('Declared question_count differs from the bank')
    if 'total_points' in metadata and (type(metadata['total_points']) not in (int, float) or not math.isclose(metadata['total_points'], total, rel_tol=0, abs_tol=1e-9)):
        raise ValueError('Declared total_points differs from the sum of question weights')
    if 'bloom_distribution' in metadata:
        declared = metadata['bloom_distribution']
        if (not isinstance(declared, dict) or any(type(value) is not int for value in declared.values())
                or declared != dict(levels)):
            raise ValueError('Declared Bloom distribution differs from the question labels')
    return {'question_count': len(questions), 'total_points': total, 'bloom_distribution': dict(levels)}


def export_bank(data, source_path):
    counts = validate_bank(data)
    records = []
    for q in data.get('questions', data.get('intrebari')):
        options = q.get('options', q.get('optiuni'))
        if isinstance(options, list):
            answers = [{'id': chr(97+i), 'text': o.get('text') if isinstance(o, dict) else o,
                        'correct': i == q['correct_answer'],
                        'feedback': o.get('explanation', '') if isinstance(o, dict) else ''}
                       for i, o in enumerate(options)]
        else:
            answers = [{'id': key, 'text': value, 'correct': key == q.get('correct', q.get('corect')),
                        'feedback': q.get('misconceptions', q.get('misconceptii', {})).get(key, '')}
                       for key, value in options.items()]
        records.append({'id': q['id'], 'type': 'multiple_choice',
                        'topic': q.get('topic', q.get('subject', q.get('subiect', ''))),
                        'bloom_level': q.get('bloom', 'understand'), 'points': q.get('points', q.get('puncte', 5)),
                        'question_text': q.get('question', q.get('text')), 'code': q.get('code', ''),
                        'answers': answers, 'explanation': q.get('explanation', q.get('explicatie', '')),
                        'source_question': deepcopy(q)})
    return {'schema_version': 1, 'format': 'ENos local formative bank data; not Moodle XML or Canvas QTI',
            'source': {'filename': source_path.name, 'sha256': hashlib.sha256(source_path.read_bytes()).hexdigest()},
            'metadata': deepcopy(data['metadata']), 'derived_counts': counts,
            'configuration': deepcopy(data.get('configuration', data.get('configurare', {}))),
            'assessment_scope': 'Formative practice; no institutional grade or publication/confidentiality policy is selected.',
            'questions': records}
