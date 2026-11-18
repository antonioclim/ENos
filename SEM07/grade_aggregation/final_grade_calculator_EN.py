#!/usr/bin/env python3
"""
final_grade_calculator_EN.py - Final Grade Calculator
======================================================
Operating Systems | ASE Bucharest - CSIE

Reviews explicit homework, project and test scores without treating missing data as zero.
Final grades and eligibility require a complete, explicitly supplied policy.
Historical constants below remain comparison material; they are not selected defaults.
"""

import argparse
import csv
import io
import json
import math
import os
import sys
from dataclasses import asdict, dataclass, field
from datetime import datetime
from pathlib import Path
from typing import List, Optional, Tuple

# Historical values are retained for comparison only. No policy is selected by default.
POLICY_CONFIGURED = False
POLICY = {}

# Configuration
WEIGHTS = {
    'homework': 0.25,
    'project': 0.50,
    'tests': 0.25,
}

THRESHOLDS = {
    'homework_min': 25,      # Minimum 25 out of 31
    'homework_total': 31,
    'tests_min': 5,          # Minimum 5 out of 6
    'tests_total': 6,
}

GRADE_BOUNDARIES = [
    (9.50, 10),
    (8.50, 9),
    (7.50, 8),
    (6.50, 7),
    (5.50, 6),
    (5.00, 5),
    (0.00, 4),
]


@dataclass
class StudentGrades:
    """Container for all student grade data."""
    student_id: str
    student_name: str
    student_group: str
    
    # Homework
    homework_scores: List[float] = field(default_factory=list)
    homework_count: int = 0
    homework_average: Optional[float] = None
    
    # Project
    project_auto_score: Optional[float] = None
    project_manual_score: Optional[float] = None
    project_total: Optional[float] = None
    project_eligible: Optional[bool] = None
    
    # Tests
    test_scores: List[float] = field(default_factory=list)
    test_count: int = 0
    test_average: Optional[float] = None
    
    # Final
    weighted_score: Optional[float] = None
    final_grade: Optional[int] = None
    status: str = ""
    elimination_reason: str = ""
    issues: List[str] = field(default_factory=list)


def checked_number(value, label, low=0, high=10):
    if type(value) is bool:
        raise ValueError(f'{label} must be numeric, not boolean')
    result = float(value)
    if not math.isfinite(result) or not low <= result <= high:
        raise ValueError(f'{label} must be finite and in [{low}, {high}]')
    return result


def checked_identity(row):
    values = tuple(row.get(key, '').strip() for key in ('student_id', 'student_name', 'student_group'))
    if any(not value or value.upper() == 'UNKNOWN' for value in values):
        raise ValueError('Complete explicit student identity is required')
    return values


def boolean(value, label):
    if str(value).lower() in ('yes', 'true'):
        return True
    if str(value).lower() in ('no', 'false'):
        return False
    raise ValueError(f'{label} must be yes/no or true/false')


def checked_csv_rows(filepath, required_fields):
    """Validate the header even for an empty table, then reject ambiguous rows."""
    try:
        with open(filepath, newline='', encoding='utf-8') as handle:
            reader = csv.DictReader(handle, strict=True)
            headers = reader.fieldnames
            if not headers or any(not name.strip() for name in headers):
                raise ValueError(f'{filepath}: a non-empty CSV header is required')
            if len(headers) != len(set(headers)):
                raise ValueError(f'{filepath}: duplicate CSV column names are not allowed')
            missing = sorted(set(required_fields) - set(headers))
            if missing:
                raise ValueError(f'{filepath}: missing required CSV columns: {", ".join(missing)}')
            for row in reader:
                if None in row or any(value is None for value in row.values()):
                    raise ValueError(f'{filepath}: CSV row ending at line {reader.line_num} has a different number of fields from its header')
                yield row
    except csv.Error as error:
        raise ValueError(f'{filepath}: invalid CSV: {error}') from error


def load_homework_grades(filepath: str) -> dict:
    """Load distinct assignments with explicit final scores; never apply a second penalty."""
    grades, seen = {}, set()
    for row in checked_csv_rows(filepath, ('student_id', 'student_name', 'student_group', 'seminar',
                                          'homework_id', 'final_score', 'late_days', 'signature_valid')):
        student_id, name, group = checked_identity(row)
        assignment = (student_id, row['seminar'].strip(), row['homework_id'].strip())
        if not all(assignment) or assignment in seen:
            raise ValueError(f'Missing or duplicate assignment requires resubmission decision: {assignment}')
        seen.add(assignment)
        valid = boolean(row['signature_valid'], 'signature_valid')
        late_days = int(row['late_days'])
        if late_days < 0:
            raise ValueError('late_days must be a non-negative integer')
        # An ambiguous old `score` column is not assumed already adjusted.
        record = grades.setdefault(student_id, {'name':name, 'group':group, 'scores':[], 'count':0, 'issues':[]})
        if (record['name'], record['group']) != (name, group):
            raise ValueError(f'Conflicting identity: {student_id}')
        if not valid:
            record['issues'].append('Unverified homework excluded from numerical aggregation')
            continue
        if not row.get('final_score', '').strip():
            record['issues'].append('Missing human-reviewed final_score')
            continue
        score = checked_number(row['final_score'], 'final_score')
        record['scores'].append(score)
        if late_days == 0 or (POLICY_CONFIGURED and POLICY['late_homework_counts']):
            record['count'] += 1
        elif not POLICY_CONFIGURED:
            record['issues'].append('Late participation requires explicit author policy')
    return grades


def load_project_grades(filepath: str) -> dict:
    grades = {}
    for row in checked_csv_rows(filepath, ('student_id', 'student_name', 'student_group',
                                          'auto_score', 'manual_score', 'eligible')):
        student_id, name, group = checked_identity(row)
        if student_id in grades:
            raise ValueError(f'Duplicate project requires explicit selection: {student_id}')
        auto = checked_number(row['auto_score'], 'auto_score') if row.get('auto_score', '').strip() else None
        manual = checked_number(row['manual_score'], 'manual_score') if row.get('manual_score', '').strip() else None
        if auto is not None and manual is not None and auto + manual > 10:
            raise ValueError(f'Project component sum exceeds 10 for {student_id}; resolve the scale')
        grades[student_id] = {'name':name, 'group':group, 'auto_score':auto,
                              'manual_score':manual, 'eligible':boolean(row['eligible'], 'eligible') if row.get('eligible', '').strip() else None,
                              'issues':[]}
    return grades


def load_test_grades(filepath: str) -> dict:
    grades, seen = {}, set()
    for row in checked_csv_rows(filepath, ('student_id', 'student_name', 'student_group', 'test_id', 'score')):
        student_id, name, group = checked_identity(row)
        test_id = row['test_id'].strip()
        if not test_id or (student_id, test_id) in seen:
            raise ValueError(f'Missing or duplicate test requires explicit selection: {student_id}/{test_id}')
        seen.add((student_id, test_id))
        score = checked_number(row['score'], 'test score', low=-1) if row.get('score', '').strip() else None
        if score is not None and -1 < score < 0:
            raise ValueError('Only -1 denotes absence; a present test score is 0..10')
        record = grades.setdefault(student_id, {'name':name, 'group':group, 'scores':[], 'count':0, 'issues':[]})
        if (record['name'], record['group']) != (name, group):
            raise ValueError(f'Conflicting identity: {student_id}')
        if score is None:
            record['issues'].append(f'Missing reviewed score for test {test_id}')
        elif score >= 0:
            record['scores'].append(score)
            record['count'] += 1
    return grades


def load_policy(path):
    """Load an explicitly provided policy; this does not itself prove author approval."""
    global POLICY, POLICY_CONFIGURED, WEIGHTS, THRESHOLDS, GRADE_BOUNDARIES
    policy = json.loads(Path(path).read_text())
    if type(policy['schema_version']) is not int or policy['schema_version'] != 1 or policy['score_stage'] != 'final':
        raise ValueError('Expected policy schema 1 and score_stage=final')
    if type(policy['late_homework_counts']) is not bool:
        raise ValueError('late_homework_counts must be explicitly true or false')
    for key in ('passing_grade', 'elimination_grade', 'require_project_eligible'):
        if key not in policy:
            raise ValueError(f'Explicit policy choice required: {key}')
    if type(policy['passing_grade']) is not int or not 1 <= policy['passing_grade'] <= 10:
        raise ValueError('passing_grade must be an integer in 1..10')
    if policy['elimination_grade'] is not None and (type(policy['elimination_grade']) is not int or not 1 <= policy['elimination_grade'] <= 10):
        raise ValueError('elimination_grade must be null or an integer in 1..10')
    if type(policy['require_project_eligible']) is not bool:
        raise ValueError('require_project_eligible must be explicitly true or false')
    weights = {key: checked_number(policy['weights'][key], key, high=1) for key in WEIGHTS}
    if not math.isclose(sum(weights.values()), 1.0, abs_tol=1e-9):
        raise ValueError('Weights must sum to 1')
    thresholds = policy['thresholds']
    for key in THRESHOLDS:
        if type(thresholds[key]) is not int or thresholds[key] < 0:
            raise ValueError(f'{key} must be a non-negative integer')
    for prefix in ('homework', 'tests'):
        if not 0 <= thresholds[prefix+'_min'] <= thresholds[prefix+'_total']:
            raise ValueError('Minimum cannot exceed total')
    boundaries = policy['grade_boundaries']
    if not isinstance(boundaries, list) or not boundaries or boundaries[-1][0] != 0:
        raise ValueError('Grade boundaries must cover score zero')
    previous = float('inf')
    for lower, grade in boundaries:
        checked_number(lower, 'boundary')
        if lower >= previous or type(grade) is not int or not 1 <= grade <= 10:
            raise ValueError('Boundaries must descend strictly and have integer grades 1..10')
        previous = lower
    WEIGHTS, THRESHOLDS, GRADE_BOUNDARIES = weights, thresholds, boundaries
    POLICY, POLICY_CONFIGURED = policy, True


def calculate_grade(score: float) -> int:
    """Convert numeric score to grade."""
    for boundary, grade in GRADE_BOUNDARIES:
        if score >= boundary:
            return grade
    raise ValueError('Score is outside the explicitly configured grade boundaries')


def process_student(
    student_id: str,
    homework: dict,
    project: dict,
    tests: dict
) -> StudentGrades:
    """Process grades for a single student."""
    
    # Get student info
    hw_data = homework.get(student_id, {})
    proj_data = project.get(student_id, {})
    test_data = tests.get(student_id, {})
    
    student = StudentGrades(
        student_id=student_id,
        student_name=hw_data.get('name') or proj_data.get('name') or test_data.get('name', ''),
        student_group=hw_data.get('group') or proj_data.get('group') or test_data.get('group', ''),
    )
    
    # Process homework
    student.homework_scores = hw_data.get('scores', [])
    student.homework_count = hw_data.get('count', 0)
    if student.homework_scores:
        student.homework_average = sum(student.homework_scores) / len(student.homework_scores)
    
    # Process project
    student.project_auto_score = proj_data.get('auto_score')
    student.project_manual_score = proj_data.get('manual_score')
    if student.project_auto_score is not None and student.project_manual_score is not None:
        student.project_total = student.project_auto_score + student.project_manual_score
    student.project_eligible = proj_data.get('eligible')
    
    # Process tests
    student.test_scores = test_data.get('scores', [])
    student.test_count = test_data.get('count', 0)
    if student.test_scores:
        student.test_average = sum(student.test_scores) / len(student.test_scores)
    
    identities = {(d['name'], d['group']) for d in (hw_data, proj_data, test_data) if d}
    if not identities or not student.student_name or not student.student_group:
        raise ValueError(f'Complete explicit identity is unavailable: {student_id}')
    if len(identities) > 1:
        raise ValueError(f'Conflicting identity across components: {student_id}')
    components = {'homework': student.homework_average, 'project': student.project_total,
                  'tests': student.test_average}
    records = {'homework': hw_data, 'project': proj_data, 'tests': test_data}
    required = {name for name in components if not POLICY_CONFIGURED or WEIGHTS[name] > 0}
    blocking_issues = []
    for name, value in components.items():
        component_issues = list(records[name].get('issues', []))
        if value is None:
            component_issues.append(f'Missing reviewed {name} component')
        student.issues.extend(component_issues)
        if name in required:
            blocking_issues.extend(component_issues)
    if student.project_eligible is None:
        issue = 'Project eligibility evidence is missing'
        student.issues.append(issue)
        if not POLICY_CONFIGURED or POLICY['require_project_eligible']:
            blocking_issues.append(issue)
    if not POLICY_CONFIGURED:
        student.status = "PENDING_POLICY"
        student.elimination_reason = "No explicit policy file; no authoritative final grade or eligibility decision" + ("; " + "; ".join(student.issues) if student.issues else "")
        return student

    if blocking_issues:
        student.status = "PENDING_EVIDENCE"
        student.elimination_reason = "; ".join(student.issues)
        return student

    # Inactive components stay missing in the report, even when the supplied
    # policy deliberately assigns them no weight. Their issues remain visible.
    if student.issues:
        student.elimination_reason = 'Non-blocking under supplied policy: ' + '; '.join(student.issues)

    # Check explicitly configured eligibility criteria
    elimination_reasons = []
    
    # Homework threshold
    if WEIGHTS['homework'] > 0 and student.homework_count < THRESHOLDS['homework_min']:
        elimination_reasons.append(
            f"Homework: {student.homework_count}/{THRESHOLDS['homework_total']} "
            f"(min: {THRESHOLDS['homework_min']})"
        )
    
    # Test threshold
    if WEIGHTS['tests'] > 0 and student.test_count < THRESHOLDS['tests_min']:
        elimination_reasons.append(
            f"Tests: {student.test_count}/{THRESHOLDS['tests_total']} "
            f"(min: {THRESHOLDS['tests_min']})"
        )
    
    # Project eligibility
    if POLICY['require_project_eligible'] and not student.project_eligible:
        elimination_reasons.append("Project requirements not met")
    
    # Calculate final grade
    if elimination_reasons:
        student.status = "ELIMINATION"
        student.elimination_reason = "; ".join(elimination_reasons + student.issues)
        student.final_grade = POLICY['elimination_grade']
        student.weighted_score = None
    else:
        # Calculate weighted score
        student.weighted_score = sum(components[name] * weight
                                     for name, weight in WEIGHTS.items() if weight > 0)
        
        student.final_grade = calculate_grade(student.weighted_score)
        
        if student.final_grade >= POLICY['passing_grade']:
            student.status = "PASS"
        else:
            student.status = "FAIL"
            student.elimination_reason = "; ".join(["Score below passing threshold"] + student.issues)
    
    return student


def checked_report_paths(output_path, input_paths=()):
    """Reject existing destinations and any resolved or hard-link alias of an input."""
    targets = [Path(output_path).with_suffix(suffix) for suffix in ('.csv', '.json', '.md')]
    for target in targets:
        for source in map(Path, input_paths):
            if (target.resolve() == source.resolve() or
                    (target.exists() and source.exists() and target.samefile(source))):
                raise ValueError(f'Report destination must not overwrite an input or its alias: {target}')
        if target.exists() or target.is_symlink():
            raise FileExistsError(f'Report destination already exists; choose a new output prefix: {target}')
    return targets


def write_report_files(prepared):
    """Create outputs exclusively; clean up owned files after a caught write failure."""
    created = []
    try:
        for target, text in prepared:
            descriptor = os.open(target, os.O_WRONLY | os.O_CREAT | os.O_EXCL, 0o600)
            with os.fdopen(descriptor, 'w', encoding='utf-8', newline='') as handle:
                info = os.fstat(handle.fileno())
                created.append((target, info.st_dev, info.st_ino))
                handle.write(text)
    except BaseException:
        for target, device, inode in created:
            try:
                info = target.lstat()
                if (info.st_dev, info.st_ino) == (device, inode):
                    target.unlink()
            except OSError:
                pass
        raise


def generate_report(students: List[StudentGrades], output_path: str, *, input_paths=()):
    """Write matching CSV, JSON and Markdown, retaining absent values and zero marks."""
    csv_path, json_path, md_path = checked_report_paths(output_path, input_paths)
    students = sorted(students, key=lambda item: (item.student_group, item.student_name))
    generated_at = datetime.now().astimezone().isoformat(timespec='seconds')
    def number(value):
        return "" if value is None else f"{value:.2f}"
    def md(value):
        return str(value).replace("|", "\\|").replace("\n", " ")
    with io.StringIO(newline='') as handle:
        writer = csv.writer(handle)
        writer.writerow(['Student ID','Name','Group','HW Count','HW Avg','Project','Test Count','Test Avg',
                         'Weighted Score','Final Grade','Status','Notes'])
        for item in students:
            writer.writerow([item.student_id,item.student_name,item.student_group,item.homework_count,
                number(item.homework_average),number(item.project_total),item.test_count,number(item.test_average),
                number(item.weighted_score),item.final_grade,item.status,item.elimination_reason])
        csv_text = handle.getvalue()
    statuses = {name: sum(item.status == name for item in students)
                for name in sorted({item.status for item in students})}
    with io.StringIO() as handle:
        handle.write('# Component Review Report\n\n')
        handle.write('Policy: explicitly supplied; author approval must be checked separately.\n\n' if POLICY_CONFIGURED
                     else 'PENDING_POLICY: reviewed components only; no final grades or eligibility decisions.\n\n')
        handle.write('Blank numerical cells mean missing/unreviewed evidence. A reviewed zero is displayed as 0.00.\n\n')
        handle.write(f'Generated: {generated_at}\n\n')
        handle.write('## Processing Status\n\n| Status | Count |\n|---|---:|\n')
        for name, count in statuses.items(): handle.write(f'| {name} | {count} |\n')
        if not students: handle.write('| NO_RECORDS | 0 |\n')
        if POLICY_CONFIGURED and any(item.final_grade is not None for item in students):
            counts = {}
            for item in students:
                if item.final_grade is not None: counts[item.final_grade] = counts.get(item.final_grade, 0) + 1
            handle.write('\n## Grades Calculated Under the Supplied Policy\n\n| Grade | Count |\n|---|---:|\n')
            for grade,count in sorted(counts.items(),reverse=True): handle.write(f'| {grade} | {count} |\n')
        handle.write('\n## Component Detail\n\n| Name | Group | HW | Project | Tests | Score | Grade | Status | Evidence / decision notes |\n')
        handle.write('|---|---|---|---|---|---|---|---|---|\n')
        for item in students:
            values=[item.student_name,item.student_group,number(item.homework_average),number(item.project_total),
                    number(item.test_average),number(item.weighted_score),'' if item.final_grade is None else item.final_grade,
                    item.status,item.elimination_reason]
            handle.write('| '+' | '.join(map(md,values))+' |\n')
        md_text = handle.getvalue()
    report = {
        'schema_version': 1,
        'generated_at': generated_at,
        'policy_status': 'SUPPLIED_POLICY_UNVERIFIED' if POLICY_CONFIGURED else 'PENDING_POLICY',
        'policy_supplied': POLICY_CONFIGURED,
        'policy_approval': 'UNVERIFIED' if POLICY_CONFIGURED else 'NOT_SUPPLIED',
        'status_counts': statuses,
        'students': [asdict(student) for student in students],
        'limits': 'Component evidence and calculations under an explicitly supplied policy, if any. Supplying a policy does not prove author or institutional approval. No publication or eligibility rule is adopted by this export.',
    }
    json_text = json.dumps(report, ensure_ascii=False, indent=2, allow_nan=False)+'\n'
    write_report_files([(csv_path, csv_text), (json_path, json_text), (md_path, md_text)])
    print(f'CSV report: {csv_path}\nJSON report: {json_path}\nMarkdown report: {md_path}')
    print('Processing statuses: '+(json.dumps(statuses) if statuses else 'NO_RECORDS'))


def main():
    parser = argparse.ArgumentParser(
        description="Calculate final grades from component scores",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s --homework hw.csv --project proj.csv --tests tests.csv -o grades
  %(prog)s -hw hw.csv -p proj.csv -t tests.csv --output final_grades

Policy:
  Without --policy, the tool reports components with PENDING_POLICY.
  A supplied policy must explicitly provide weights, thresholds, grade boundaries,
  late_homework_counts, passing_grade, elimination_grade and require_project_eligible.
  The historical 25/50/25 and 80% examples above are not automatically adopted.
        """
    )
    
    parser.add_argument(
        '-hw', '--homework',
        required=True,
        help='CSV file with homework grades'
    )
    parser.add_argument(
        '-p', '--project',
        required=True,
        help='CSV file with project grades'
    )
    parser.add_argument(
        '-t', '--tests',
        required=True,
        help='CSV file with test grades'
    )
    parser.add_argument(
        '-o', '--output',
        default='final_grades',
        help='Output file prefix (default: final_grades)'
    )
    parser.add_argument(
        '-v', '--verbose',
        action='store_true',
        help='Verbose output'
    )
    
    parser.add_argument('--policy', help='Explicit JSON policy; without it reports remain preliminary')
    args = parser.parse_args()
    if args.policy:
        load_policy(args.policy)
    
    # Validate input files
    for filepath, name in [(args.homework, 'homework'), 
                           (args.project, 'project'), 
                           (args.tests, 'tests')]:
        if not Path(filepath).exists():
            print(f"Error: {name} file not found: {filepath}")
            sys.exit(1)
    
    # Load data
    print("Loading homework grades...")
    homework = load_homework_grades(args.homework)
    
    print("Loading project grades...")
    project = load_project_grades(args.project)
    
    print("Loading test grades...")
    tests = load_test_grades(args.tests)
    
    # Get all student IDs
    all_students = set(homework.keys()) | set(project.keys()) | set(tests.keys())
    print(f"Processing {len(all_students)} students...")
    
    # Process each student
    results = []
    for student_id in all_students:
        student = process_student(student_id, homework, project, tests)
        results.append(student)
        
        if args.verbose:
            print(f"  {student.student_name}: {student.status}; grade={student.final_grade}")
    
    # Generate reports
    input_paths = [args.homework, args.project, args.tests]
    if args.policy:
        input_paths.append(args.policy)
    generate_report(results, args.output, input_paths=input_paths)


if __name__ == '__main__':
    try:
        main()
    except (OSError, ValueError, KeyError, TypeError, IndexError) as exc:
        print(f'Cannot calculate grades: {exc}', file=sys.stderr)
        raise SystemExit(1)
