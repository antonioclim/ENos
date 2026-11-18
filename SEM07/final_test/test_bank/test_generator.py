#!/usr/bin/env python3
"""Generate reproducible local question drafts and separate review keys.

The input pool is publicly distributed. A generated variant is not confidential,
equated or institutionally approved merely because its answer key is separate.
This program never executes question code, grades students or contacts an LMS.
"""
from __future__ import annotations
import argparse
from collections import Counter
from copy import deepcopy
import hashlib
import json
import math
from pathlib import Path
import platform
import random
import sys

import yaml

VERSION = '1.0'
BLOOM = {'remember', 'understand', 'apply', 'analyse', 'evaluate', 'create'}
TYPES = {'multiple_choice', 'short_answer', 'practical'}
DIFFICULTIES = {'easy', 'medium', 'hard'}
SCOPE = 'Local study/review draft from a public pool; assessment and publication policy remain PENDING_POLICY.'


class UniqueKeyLoader(yaml.SafeLoader):
    """Reject duplicate YAML keys instead of silently changing a question."""


def unique_mapping(loader, node, deep=False):
    loader.flatten_mapping(node)
    result = {}
    for key_node, value_node in node.value:
        key = loader.construct_object(key_node, deep=deep)
        try:
            if key in result:
                raise ValueError(f'Duplicate YAML mapping key: {key!r}')
            result[key] = loader.construct_object(value_node, deep=deep)
        except TypeError as error:
            raise ValueError('YAML mapping keys must be hashable scalar values') from error
    return result


UniqueKeyLoader.add_constructor(yaml.resolver.BaseResolver.DEFAULT_MAPPING_TAG, unique_mapping)


def checksum(data):
    return hashlib.sha256(data).hexdigest()


def validate_pool(data):
    if not isinstance(data, dict) or not isinstance(data.get('metadata'), dict):
        raise ValueError('The pool requires metadata and category mappings')
    categories = data.get('categories')
    if not isinstance(categories, list) or not categories:
        raise ValueError('The pool requires a non-empty categories list')
    ids, names, questions = set(), set(), []
    for category in categories:
        if not isinstance(category, dict):
            raise ValueError('Every category must be a mapping')
        name = category.get('name')
        if not isinstance(name, str) or not name.strip() or name.casefold() in names:
            raise ValueError('Category names must be non-empty and unique')
        names.add(name.casefold())
        records = category.get('questions')
        if not isinstance(records, list) or not records:
            raise ValueError(f'{name}: requires a non-empty question list')
        if 'question_count' in category and (type(category['question_count']) is not int or category['question_count'] != len(records)):
            raise ValueError(f'{name}: declared question_count is inconsistent')
        for original in records:
            if not isinstance(original, dict):
                raise ValueError(f'{name}: question must be a mapping')
            question = deepcopy(original)
            ident = question.get('id')
            if not isinstance(ident, str) or not ident.strip() or ident in ids:
                raise ValueError('Question IDs must be non-empty and unique across the pool')
            ids.add(ident)
            for field in ('question', 'answer'):
                if not isinstance(question.get(field), str) or not question[field].strip():
                    raise ValueError(f'{ident}: {field} must be non-empty text')
            kind = question.get('type')
            if not isinstance(kind, str) or kind not in TYPES:
                raise ValueError(f'{ident}: unsupported question type')
            difficulty, bloom = question.get('difficulty'), question.get('bloom')
            if not isinstance(difficulty, str) or difficulty not in DIFFICULTIES:
                raise ValueError(f'{ident}: unknown difficulty')
            if not isinstance(bloom, str) or bloom not in BLOOM:
                raise ValueError(f'{ident}: unknown Bloom label')
            points = question.get('points')
            if type(points) not in (int, float) or not math.isfinite(points) or points <= 0:
                raise ValueError(f'{ident}: points must be finite and positive')
            if kind == 'multiple_choice':
                options = question.get('options')
                if not isinstance(options, dict) or not 2 <= len(options) <= 26:
                    raise ValueError(f'{ident}: multiple_choice requires 2–26 letter-keyed options')
                if any(not isinstance(key, str) or len(key) != 1 or key not in 'abcdefghijklmnopqrstuvwxyz' for key in options):
                    raise ValueError(f'{ident}: answer keys must be single lower-case ASCII letters')
                if any(not isinstance(value, str) or not value.strip() for value in options.values()):
                    raise ValueError(f'{ident}: options must be non-empty text')
                if len({value.strip() for value in options.values()}) != len(options):
                    raise ValueError(f'{ident}: duplicate literal answer choices')
                if question['answer'] not in options:
                    raise ValueError(f'{ident}: answer does not name an option')
            elif 'options' in question:
                raise ValueError(f'{ident}: options belong to multiple_choice, not {kind}')
            for field in ('explanation', 'code', 'source'):
                if field in question and not isinstance(question[field], str):
                    raise ValueError(f'{ident}: {field} must be text')
            for field in ('accept_alternatives', 'keywords'):
                if field in question and (not isinstance(question[field], list) or any(not isinstance(value, str) for value in question[field])):
                    raise ValueError(f'{ident}: {field} must be a list of text values')
            question['category'] = name
            questions.append(question)
    total_points = sum(question['points'] for question in questions)
    if not math.isfinite(total_points):
        raise ValueError('Total question points must be finite')
    statistics = {key: dict(sorted(Counter(question[field] for question in questions).items()))
                  for key, field in [('by_difficulty', 'difficulty'), ('by_type', 'type'), ('by_bloom', 'bloom')]}
    metadata = data['metadata']
    for field in ('course', 'author'):
        if field in metadata and (not isinstance(metadata[field], str) or not metadata[field].strip()):
            raise ValueError(f'metadata.{field} must be non-empty text')
    if 'total_questions' in metadata and (type(metadata['total_questions']) is not int or metadata['total_questions'] != len(questions)):
        raise ValueError('Declared total_questions differs from the pool')
    declared = metadata.get('statistics')
    if declared is not None:
        if not isinstance(declared, dict):
            raise ValueError('metadata.statistics must be a mapping')
        for key, expected in statistics.items():
            if key in declared:
                actual = declared[key]
                if not isinstance(actual, dict) or any(type(value) is not int for value in actual.values()) or actual != expected:
                    raise ValueError('Declared '+key+' differs from the pool')
    if 'total_points' in metadata and (type(metadata['total_points']) not in (int, float) or metadata['total_points'] != total_points):
        raise ValueError('Declared total_points differs from authored weights')
    return questions, {'total_questions': len(questions), 'categories': len(categories),
                       'total_points': total_points, 'statistics': statistics,
                       'by_category': {category['name']: len(category['questions']) for category in categories}}


def load_pool(path):
    raw = path.read_bytes()
    data = yaml.load(raw.decode('utf-8'), Loader=UniqueKeyLoader)
    questions, counts = validate_pool(data)
    return data, questions, counts, checksum(raw)


def generate(data, count, seed, source_hash, categories=(), difficulty=None, question_type=None):
    questions, _ = validate_pool(data)
    if type(count) is not int or count < 1:
        raise ValueError('Question count must be a positive integer')
    if type(seed) is not int:
        raise ValueError('Seed must be an integer')
    if any(not isinstance(value, str) or not value.strip() for value in categories):
        raise ValueError('Category filters must be non-empty text')
    if difficulty is not None and difficulty not in DIFFICULTIES:
        raise ValueError('Unknown difficulty filter')
    if question_type is not None and question_type not in TYPES:
        raise ValueError('Unknown question type filter')
    known = {question['category'].casefold() for question in questions}
    wanted = {value.casefold() for value in categories}
    if wanted-known:
        raise ValueError('Unknown category: '+', '.join(sorted(wanted-known)))
    selected_pool = [question for question in questions
                     if (not wanted or question['category'].casefold() in wanted)
                     and (difficulty is None or question['difficulty'] == difficulty)
                     and (question_type is None or question['type'] == question_type)]
    if count > len(selected_pool):
        raise ValueError(f'Requested {count} questions, but only {len(selected_pool)} match the filters')
    rng = random.Random(seed)
    selection = rng.sample(selected_pool, count)
    paper_questions, key_questions = [], []
    for original in selection:
        paper = {field: original[field] for field in ('id', 'category', 'type', 'question', 'points')}
        if 'code' in original:
            paper['code'] = original['code']
        key = {field: deepcopy(original[field]) for field in ('id', 'category', 'type', 'points', 'answer')}
        for field in ('explanation', 'accept_alternatives', 'keywords', 'source'):
            if field in original:
                key[field] = deepcopy(original[field])
        if original['type'] == 'multiple_choice':
            options = list(original['options'].items())
            rng.shuffle(options)
            paper['options'] = {chr(97+index): value for index, (_, value) in enumerate(options)}
            key['presented_to_source_option'] = {chr(97+index): original_key for index, (original_key, _) in enumerate(options)}
            key['answer'] = next(label for label, original_key in key['presented_to_source_option'].items() if original_key == original['answer'])
        else:
            key['review_mode'] = 'MANUAL_REVIEW_REQUIRED; no automatic free-text or practical award'
        paper_questions.append(paper)
        key_questions.append(key)
    recipe = {'generator_version': VERSION, 'generator_source_sha256': checksum(Path(__file__).read_bytes()),
              'python_version': platform.python_version(),
              'source_sha256': source_hash, 'seed': seed, 'count': count,
              'categories': sorted(wanted), 'difficulty': difficulty, 'question_type': question_type,
              'question_ids_in_order': [question['id'] for question in paper_questions]}
    form_id = checksum(json.dumps(recipe, sort_keys=True, ensure_ascii=False).encode())[:20]
    common = {'schema_version': 1, 'form_id': form_id, 'course': data['metadata'].get('course', 'Operating Systems'),
              'source_bank_sha256': source_hash, 'question_count': count,
              'total_points': sum(question['points'] for question in paper_questions),
              'assessment_scope': SCOPE, 'institutional_policy': 'PENDING_POLICY'}
    if 'author' in data['metadata']:
        common['source_author'] = data['metadata']['author']
    paper = {'metadata': {**common, 'document_role': 'question_draft'}, 'questions': paper_questions}
    key = {'metadata': {**common, 'document_role': 'separate_review_key'}, 'reproduction': recipe,
           'marking_limit': 'A reference answer is not a student grade. Free-text and practical responses need human review; no institutional pass threshold is selected.',
           'answers': key_questions}
    return paper, key


def markdown(document, is_key=False):
    meta = document['metadata']
    title = 'Separate review key' if is_key else 'Question draft'
    lines = ['# '+meta['course']+' — '+title, '',
             f"Form: `{meta['form_id']}` · Questions: {meta['question_count']} · Authored points: {meta['total_points']:g}",
             '', meta['assessment_scope'], '']
    if meta.get('source_author'):
        lines += ['Source author: '+meta['source_author'], '']
    if is_key:
        lines += [document['marking_limit'], '', 'Reproduction:', '', '```json', json.dumps(document['reproduction'], ensure_ascii=False, indent=2), '```', '']
        for index, question in enumerate(document['answers'], 1):
            lines += [f"## {index}. {question['id']} — {question['points']:g} points", '',
                      'Reference answer:', '', '```text', question['answer'], '```', '']
            if question.get('explanation'):
                lines += [question['explanation'], '']
            if question.get('accept_alternatives'):
                lines += ['Accepted alternatives for review:', *['- '+value for value in question['accept_alternatives']], '']
            if question.get('keywords'):
                lines += ['Review keywords (not an automatic marking rule): '+', '.join(question['keywords']), '']
            if question.get('review_mode'):
                lines += [question['review_mode'], '']
            if question.get('presented_to_source_option'):
                lines += ['Option provenance: `'+json.dumps(question['presented_to_source_option'], sort_keys=True)+'`', '']
    else:
        for index, question in enumerate(document['questions'], 1):
            lines += [f"## {index}. {question['id']} — {question['points']:g} points", '', question['question'], '']
            if question.get('code'):
                lines += ['```text', question['code'], '```', '']
            for letter, value in question.get('options', {}).items():
                lines += [f'{letter.upper()}) {value}', '']
            if question['type'] != 'multiple_choice':
                lines += ['Response: ______________________________________________', '']
    return '\n'.join(lines).rstrip()+'\n'


def write_bundle(directory, paper, key, output_format):
    suffix = {'markdown': 'md', 'json': 'json', 'yaml': 'yaml'}[output_format]
    if output_format == 'markdown':
        texts = [markdown(paper), markdown(key, True)]
    elif output_format == 'json':
        texts = [json.dumps(document, ensure_ascii=False, indent=2)+'\n' for document in (paper, key)]
    else:
        texts = [yaml.safe_dump(document, allow_unicode=True, sort_keys=False) for document in (paper, key)]
    prepared = {f'questions.{suffix}': texts[0].encode('utf-8'), f'answer_key.{suffix}': texts[1].encode('utf-8')}
    manifest = {'form_id': paper['metadata']['form_id'], 'format': output_format,
                'assessment_scope': SCOPE,
                'files': [{'path': name, 'bytes': len(value), 'sha256': checksum(value)} for name, value in prepared.items()]}
    prepared['manifest.json'] = (json.dumps(manifest, ensure_ascii=False, indent=2)+'\n').encode()
    # Reserve a new owned directory atomically. Existing output is never replaced.
    directory.mkdir(mode=0o700, parents=False, exist_ok=False)
    written = []
    try:
        for name, content in prepared.items():
            target = directory/name
            with target.open('xb') as stream:
                written.append(target)
                stream.write(content)
    except OSError:
        for target in written:
            target.unlink(missing_ok=True)
        try:
            directory.rmdir()
        except OSError:
            pass  # Never remove unrelated contents added to the directory.
        raise
    return {'output': str(directory), 'form_id': paper['metadata']['form_id'],
            'question_count': paper['metadata']['question_count'], 'total_points': paper['metadata']['total_points'],
            'files': list(prepared), 'scope': SCOPE}


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--input', type=Path, default=Path(__file__).with_name('questions_pool.yaml'))
    parser.add_argument('--validate', action='store_true', help='Validate and print derived metadata without producing a form')
    parser.add_argument('--questions', type=int, help='Explicit number of questions, without replacement')
    parser.add_argument('--seed', type=int, help='Explicit reproducible local random seed')
    parser.add_argument('--output', type=Path, help='New output directory; existing paths are preserved')
    parser.add_argument('--format', choices=['markdown', 'json', 'yaml'], default='markdown')
    parser.add_argument('--category', action='append', default=[], help='Exact category name, case-insensitive; may be repeated')
    parser.add_argument('--difficulty', choices=sorted(DIFFICULTIES))
    parser.add_argument('--type', dest='question_type', choices=sorted(TYPES))
    parser.add_argument('--version', action='version', version='ENos local question generator '+VERSION)
    args = parser.parse_args(argv)
    if not args.validate and (args.questions is None or args.seed is None or args.output is None):
        parser.error('Generation requires explicit --questions, --seed and --output')
    try:
        data, _, counts, source_hash = load_pool(args.input)
        if args.validate:
            print(json.dumps({'success': True, 'source_sha256': source_hash, **counts, 'scope': SCOPE}, ensure_ascii=False, indent=2))
            return 0
        paper, key = generate(data, args.questions, args.seed, source_hash, args.category, args.difficulty, args.question_type)
        result = write_bundle(args.output, paper, key, args.format)
        print(json.dumps(result, ensure_ascii=False, indent=2))
        return 0
    except (OSError, UnicodeError, ValueError, yaml.YAMLError) as error:
        print('Question generation failed: '+str(error), file=sys.stderr)
        return 1


if __name__ == '__main__':
    raise SystemExit(main())
