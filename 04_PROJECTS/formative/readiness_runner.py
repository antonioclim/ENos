#!/usr/bin/env python3
"""Run the authored sectioned readiness bank as descriptive formative practice."""
import argparse
import json
from pathlib import Path
import sys
import yaml

class UniqueLoader(yaml.SafeLoader):
    pass

def unique_mapping(loader, node, deep=False):
    pairs = loader.construct_pairs(node, deep=deep)
    result = {}
    for key, value in pairs:
        if key in result:
            raise ValueError(f'duplicate YAML key: {key}')
        result[key] = value
    return result

UniqueLoader.add_constructor(yaml.resolver.BaseResolver.DEFAULT_MAPPING_TAG, unique_mapping)

def load_bank(path):
    bank = yaml.load(path.read_text(encoding='utf-8'), Loader=UniqueLoader)
    if not isinstance(bank, dict) or not isinstance(bank.get('sections'), list):
        raise ValueError('expected sectioned readiness schema')
    points = bank.get('scoring')
    if not isinstance(points, dict) or any(type(v) is not int or v <= 0 for v in points.values()):
        raise ValueError('difficulty points must be positive integers')
    seen=set(); count=0
    for section in bank['sections']:
        if not isinstance(section.get('name'), str) or type(section.get('weight')) is not int:
            raise ValueError('invalid section')
        for q in section.get('questions', []):
            if not isinstance(q.get('id'), str) or q['id'] in seen or not isinstance(q.get('question'), str):
                raise ValueError('invalid/duplicate question identity or text')
            seen.add(q['id']); count += 1
            if q.get('difficulty') not in points:
                raise ValueError(f"unknown difficulty: {q['id']}")
            if q.get('type') == 'multiple_choice':
                options=q.get('options')
                if not isinstance(options, dict) or len(options)<2 or q.get('correct') not in options or any(not isinstance(v,str) for v in options.values()):
                    raise ValueError(f"invalid options/key: {q['id']}")
            elif q.get('type') == 'code_completion':
                if not isinstance(q.get('answer'), list) or not q['answer'] or any(not isinstance(v,str) for v in q['answer']):
                    raise ValueError(f"invalid completion: {q['id']}")
            else:
                raise ValueError(f"unsupported question type: {q['id']}")
    if not count or sum(s['weight'] for s in bank['sections']) != 100:
        raise ValueError('empty bank or section weights do not sum to100')
    return bank

def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--file', type=Path, default=Path(__file__).with_name('project_readiness_quiz.yaml'))
    parser.add_argument('--validate', action='store_true')
    parser.add_argument('--export-json', type=Path)
    args=parser.parse_args()
    try:
        bank=load_bank(args.file)
        questions=[q for s in bank['sections'] for q in s['questions']]
        if args.export_json:
            args.export_json.write_text(json.dumps(bank, ensure_ascii=False, indent=2)+'\n', encoding='utf-8')
        print(f"Validated {len(questions)} questions; {sum(bank['scoring'][q['difficulty']] for q in questions)} item points.")
        if args.validate or args.export_json: return 0
        total=earned=0
        for section in bank['sections']:
            section_points=section_earned=0
            print('\n'+section['name'])
            for q in section['questions']:
                print('\n'+q['id']+': '+q['question'])
                score=bank['scoring'][q['difficulty']]
                if q['type']=='multiple_choice':
                    for key,value in q['options'].items(): print(f'  {key}. {value}')
                    response=input('Option (or q to stop): ').strip()
                    if response=='q': return 2
                    correct=response == q['correct']
                else:
                    response=input('Complete blanks in order, separated by | (q to stop): ').strip()
                    if response=='q': return 2
                    correct=[v.strip() for v in response.split('|')] == q['answer']
                section_points += score
                if correct: section_earned += score
                print('Matches reference.' if correct else 'Review the reference and explain any equivalent solution.')
                print(q.get('explanation',''))
            print(f"{section['name']}: {section_earned}/{section_points} item points; historical section weight {section['weight']}%.")
            earned += section_earned; total += section_points
        print(f'Item-point total: {earned}/{total} ({100*earned/total:.1f}%).')
        print('No project-level eligibility, predictive claim or institutional grade follows from this result.')
        print('Section weights are reported separately; no unapproved blend with item difficulty points is applied.')
        return 0
    except (OSError, ValueError, TypeError, KeyError, yaml.YAMLError) as exc:
        print(f'Readiness bank error: {exc}',file=sys.stderr); return 1
    except (EOFError, KeyboardInterrupt):
        print('\nPractice interrupted; no completed score.',file=sys.stderr); return 2

if __name__=='__main__': raise SystemExit(main())
