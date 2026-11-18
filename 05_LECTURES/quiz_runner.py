#!/usr/bin/env python3
"""Lecture self-assessment CLI; validated YAML, reproducible option ordering.
This local formative score does not define an institutional grading policy.
"""
from __future__ import annotations
import argparse
import copy
from pathlib import Path
import random
import sys
import xml.etree.ElementTree as ET


def load_quiz(path: Path) -> dict:
    try:
        import yaml
    except ImportError as exc:
        raise ValueError('PyYAML is required; install it in the course Python environment.') from exc
    try:
        data = yaml.safe_load(path.read_text(encoding='utf-8'))
    except yaml.YAMLError as exc:
        raise ValueError(f'Invalid YAML in {path.name}: {exc}') from exc
    if not isinstance(data, dict) or not isinstance(data.get('questions'), list) or not data['questions']:
        raise ValueError('Expected a nonempty questions list.')
    ids = set()
    for i, q in enumerate(data['questions'], 1):
        if not isinstance(q, dict):
            raise ValueError(f'Question {i}: expected a mapping.')
        ident = q.get('id')
        if not isinstance(ident, str) or not ident or ident in ids:
            raise ValueError(f'Question {i}: ID missing or duplicated.')
        ids.add(ident)
        if not isinstance(q.get('text'), str) or not q['text'].strip():
            raise ValueError(f'{ident}: question text is required.')
        options = q.get('options')
        if not isinstance(options, list) or not 2 <= len(options) <= 26 or any(not isinstance(x, str) or not x.strip() for x in options):
            raise ValueError(f'{ident}: options must contain 2–26 nonempty strings.')
        if type(q.get('correct')) is not int or not 0 <= q['correct'] < len(options):
            raise ValueError(f'{ident}: correct must be a valid zero-based integer index.')
        if not isinstance(q.get('explanation'), str):
            raise ValueError(f'{ident}: explanation must be a string.')
    meta = data.get('metadata', {})
    if not isinstance(meta, dict):
        raise ValueError('metadata must be a mapping.')
    if meta.get('number_of_questions', len(ids)) != len(ids):
        raise ValueError('metadata.number_of_questions differs from the bank.')
    return data


def prepare_questions(questions: list[dict], shuffle: bool = False, seed: int = 0, limit: int | None = None) -> list[dict]:
    if limit is not None and limit <= 0:
        raise ValueError('limit must be positive.')
    out = copy.deepcopy(questions)
    rng = random.Random(seed)
    if shuffle:
        rng.shuffle(out)
        for q in out:
            order = list(range(len(q['options'])))
            rng.shuffle(order)
            q['options'] = [q['options'][i] for i in order]
            q['correct'] = order.index(q['correct'])
    return out[:limit] if limit is not None else out


def export_moodle(questions: list[dict], output: Path) -> None:
    """Moodle XML single-answer MCQs; UTF-8 text is escaped by ElementTree.
    Native LMS import remains a separate environment-specific acceptance step.
    """
    root = ET.Element('quiz')
    for q in questions:
        item = ET.SubElement(root, 'question', type='multichoice')
        ET.SubElement(ET.SubElement(item, 'name'), 'text').text = q['id']
        ET.SubElement(ET.SubElement(item, 'questiontext', format='plain_text'), 'text').text = q['text']
        ET.SubElement(item, 'single').text = 'true'
        ET.SubElement(item, 'shuffleanswers').text = '0'
        ET.SubElement(item, 'answernumbering').text = 'abc'
        for index, option in enumerate(q['options']):
            answer = ET.SubElement(item, 'answer', fraction='100' if index == q['correct'] else '0', format='plain_text')
            ET.SubElement(answer, 'text').text = option
            ET.SubElement(ET.SubElement(answer, 'feedback', format='plain_text'), 'text').text = q['explanation']
    ET.indent(root)
    ET.ElementTree(root).write(output, encoding='utf-8', xml_declaration=True)


def run_quiz(questions: list[dict]) -> tuple[int, int]:
    score = answered = 0
    for index, q in enumerate(questions, 1):
        print(f"\nQuestion {index}/{len(questions)} [{q['id']}]\n{q['text']}")
        for j, option in enumerate(q['options']):
            print(f'  {chr(65+j)}. {option}')
        while True:
            try:
                answer = input('Answer (letter; q to stop): ').strip().upper()
            except (EOFError, KeyboardInterrupt):
                answer = 'Q'
            if answer == 'Q':
                print('\nSession stopped; unattempted questions excluded.')
                return score, answered
            if len(answer) == 1 and 'A' <= answer <= chr(64 + len(q['options'])):
                break
            print('Choose one of the displayed letters.')
        correct = ord(answer) - 65 == q['correct']
        score += int(correct)
        answered += 1
        print('Correct.' if correct else f"Correct answer: {chr(65+q['correct'])}.")
        print(q['explanation'])
    return score, answered


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('quiz_file', type=Path)
    parser.add_argument('--validate', action='store_true', help='Validate without asking questions')
    parser.add_argument('--shuffle', action='store_true', help='Shuffle questions and options with their answer keys')
    parser.add_argument('--seed', type=int, default=0, help='Reproducible shuffle seed (default: 0)')
    parser.add_argument('--limit', type=int, help='Present/export at most this many questions')
    parser.add_argument('--export-moodle', type=Path, metavar='XML', help='Write a local Moodle XML file; does not upload')
    args = parser.parse_args(argv)
    try:
        quiz = load_quiz(args.quiz_file)
        questions = prepare_questions(quiz['questions'], args.shuffle, args.seed, args.limit)
        print(f"{quiz.get('metadata', {}).get('subject', 'Lecture quiz')}: {len(questions)} questions")
        if args.shuffle:
            print(f'Shuffle seed: {args.seed}; question and option order are reproducible.')
        if args.export_moodle:
            if args.export_moodle.resolve() == args.quiz_file.resolve():
                raise ValueError('Export must not overwrite the source bank.')
            export_moodle(questions, args.export_moodle)
            print(f'Moodle XML written: {args.export_moodle}; import has not been performed.')
        elif args.validate:
            print('Valid bank and answer indices.')
        else:
            score, answered = run_quiz(questions)
            print(f'Formative result: {score}/{answered} attempted questions.')
        return 0
    except (OSError, ValueError) as exc:
        parser.exit(2, f'Error: {exc}\n')


if __name__ == '__main__':
    raise SystemExit(main())
