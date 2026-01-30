#!/usr/bin/env python3
"""
final_grade_calculator_EN.py - Final Grade Calculator
======================================================
Operating Systems | ASE Bucharest - CSIE

Calculates final grades from homework, project, and test scores.
Enforces elimination criteria (80% threshold).
"""

import argparse
import csv
import sys
from dataclasses import dataclass, field
from datetime import datetime
from pathlib import Path
from typing import List, Optional, Tuple

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
    homework_average: float = 0.0
    
    # Project
    project_auto_score: float = 0.0
    project_manual_score: float = 0.0
    project_total: float = 0.0
    project_eligible: bool = True
    
    # Tests
    test_scores: List[float] = field(default_factory=list)
    test_count: int = 0
    test_average: float = 0.0
    
    # Final
    weighted_score: float = 0.0
    final_grade: int = 0
    status: str = ""
    elimination_reason: str = ""


def load_homework_grades(filepath: str) -> dict:
    """Load homework grades from CSV."""
    grades = {}
    
    with open(filepath, 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        for row in reader:
            student_id = row['student_id']
            if student_id not in grades:
                grades[student_id] = {
                    'name': row.get('student_name', 'Unknown'),
                    'group': row.get('student_group', 'Unknown'),
                    'scores': [],
                    'count': 0,
                }
            
            score = float(row.get('score', 0))
            if score > 0:  # Only count submitted assignments
                grades[student_id]['scores'].append(score)
                grades[student_id]['count'] += 1
    
    return grades


def load_project_grades(filepath: str) -> dict:
    """Load project grades from CSV."""
    grades = {}
    
    with open(filepath, 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        for row in reader:
            student_id = row['student_id']
            grades[student_id] = {
                'name': row.get('student_name', 'Unknown'),
                'group': row.get('student_group', 'Unknown'),
                'auto_score': float(row.get('auto_score', 0)),
                'manual_score': float(row.get('manual_score', 0)),
                'eligible': row.get('eligible', 'yes').lower() == 'yes',
            }
    
    return grades


def load_test_grades(filepath: str) -> dict:
    """Load test grades from CSV."""
    grades = {}
    
    with open(filepath, 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        for row in reader:
            student_id = row['student_id']
            if student_id not in grades:
                grades[student_id] = {
                    'name': row.get('student_name', 'Unknown'),
                    'group': row.get('student_group', 'Unknown'),
                    'scores': [],
                    'count': 0,
                }
            
            score = float(row.get('score', -1))
            if score >= 0:  # -1 indicates absent
                grades[student_id]['scores'].append(score)
                grades[student_id]['count'] += 1
    
    return grades


def calculate_grade(score: float) -> int:
    """Convert numeric score to grade."""
    for boundary, grade in GRADE_BOUNDARIES:
        if score >= boundary:
            return grade
    return 4


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
        student_name=hw_data.get('name') or proj_data.get('name') or test_data.get('name', 'Unknown'),
        student_group=hw_data.get('group') or proj_data.get('group') or test_data.get('group', 'Unknown'),
    )
    
    # Process homework
    student.homework_scores = hw_data.get('scores', [])
    student.homework_count = hw_data.get('count', 0)
    if student.homework_scores:
        student.homework_average = sum(student.homework_scores) / len(student.homework_scores)
    
    # Process project
    student.project_auto_score = proj_data.get('auto_score', 0)
    student.project_manual_score = proj_data.get('manual_score', 0)
    student.project_total = student.project_auto_score + student.project_manual_score
    student.project_eligible = proj_data.get('eligible', False)
    
    # Process tests
    student.test_scores = test_data.get('scores', [])
    student.test_count = test_data.get('count', 0)
    if student.test_scores:
        student.test_average = sum(student.test_scores) / len(student.test_scores)
    
    # Check elimination criteria
    elimination_reasons = []
    
    # Homework threshold
    if student.homework_count < THRESHOLDS['homework_min']:
        elimination_reasons.append(
            f"Homework: {student.homework_count}/{THRESHOLDS['homework_total']} "
            f"(min: {THRESHOLDS['homework_min']})"
        )
    
    # Test threshold
    if student.test_count < THRESHOLDS['tests_min']:
        elimination_reasons.append(
            f"Tests: {student.test_count}/{THRESHOLDS['tests_total']} "
            f"(min: {THRESHOLDS['tests_min']})"
        )
    
    # Project eligibility
    if not student.project_eligible:
        elimination_reasons.append("Project requirements not met")
    
    # Calculate final grade
    if elimination_reasons:
        student.status = "ELIMINATION"
        student.elimination_reason = "; ".join(elimination_reasons)
        student.final_grade = 4
        student.weighted_score = 0.0
    else:
        # Calculate weighted score
        student.weighted_score = (
            student.homework_average * WEIGHTS['homework'] +
            student.project_total * WEIGHTS['project'] +
            student.test_average * WEIGHTS['tests']
        )
        
        student.final_grade = calculate_grade(student.weighted_score)
        
        if student.final_grade >= 5:
            student.status = "PASS"
        else:
            student.status = "FAIL"
            student.elimination_reason = "Score below passing threshold"
    
    return student


def generate_report(students: List[StudentGrades], output_path: str):
    """Generate final grades report."""
    
    # Sort by group, then name
    students.sort(key=lambda s: (s.student_group, s.student_name))
    
    # CSV output
    csv_path = Path(output_path).with_suffix('.csv')
    with open(csv_path, 'w', newline='', encoding='utf-8') as f:
        writer = csv.writer(f)
        writer.writerow([
            'Student ID', 'Name', 'Group',
            'HW Count', 'HW Avg', 
            'Project',
            'Test Count', 'Test Avg',
            'Weighted Score', 'Final Grade',
            'Status', 'Notes'
        ])
        
        for s in students:
            writer.writerow([
                s.student_id,
                s.student_name,
                s.student_group,
                s.homework_count,
                f"{s.homework_average:.2f}",
                f"{s.project_total:.2f}",
                s.test_count,
                f"{s.test_average:.2f}",
                f"{s.weighted_score:.2f}",
                s.final_grade,
                s.status,
                s.elimination_reason,
            ])
    
    print(f"CSV report saved to: {csv_path}")
    
    # Markdown report
    md_path = Path(output_path).with_suffix('.md')
    with open(md_path, 'w', encoding='utf-8') as f:
        f.write("# Final Grades Report\n\n")
        f.write(f"**Generated:** {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n\n")
        f.write("---\n\n")
        
        # Statistics
        total = len(students)
        passing = sum(1 for s in students if s.status == "PASS")
        failing = sum(1 for s in students if s.status == "FAIL")
        eliminated = sum(1 for s in students if s.status == "ELIMINATION")
        
        f.write("## Summary Statistics\n\n")
        f.write(f"| Metric | Count | Percentage |\n")
        f.write(f"|--------|-------|------------|\n")
        f.write(f"| Total Students | {total} | 100% |\n")
        f.write(f"| Passing | {passing} | {passing*100/total:.1f}% |\n")
        f.write(f"| Failing | {failing} | {failing*100/total:.1f}% |\n")
        f.write(f"| Eliminated (80% threshold) | {eliminated} | {eliminated*100/total:.1f}% |\n")
        f.write("\n")
        
        # Grade distribution
        grade_counts = {}
        for s in students:
            grade_counts[s.final_grade] = grade_counts.get(s.final_grade, 0) + 1
        
        f.write("## Grade Distribution\n\n")
        f.write("| Grade | Count |\n")
        f.write("|-------|-------|\n")
        for grade in range(10, 3, -1):
            count = grade_counts.get(grade, 0)
            f.write(f"| {grade} | {count} |\n")
        f.write("\n")
        
        # Elimination breakdown
        if eliminated > 0:
            f.write("## Elimination Details\n\n")
            f.write("| Student | Group | Reason |\n")
            f.write("|---------|-------|--------|\n")
            for s in students:
                if s.status == "ELIMINATION":
                    f.write(f"| {s.student_name} | {s.student_group} | {s.elimination_reason} |\n")
            f.write("\n")
        
        # Full grades table
        f.write("## Detailed Grades\n\n")
        f.write("| Name | Group | HW | Project | Tests | Score | Grade | Status |\n")
        f.write("|------|-------|-----|---------|-------|-------|-------|--------|\n")
        
        for s in students:
            status_emoji = "✓" if s.status == "PASS" else "✗"
            f.write(
                f"| {s.student_name} | {s.student_group} | "
                f"{s.homework_average:.1f} ({s.homework_count}) | "
                f"{s.project_total:.1f} | "
                f"{s.test_average:.1f} ({s.test_count}) | "
                f"{s.weighted_score:.2f} | {s.final_grade} | {status_emoji} {s.status} |\n"
            )
        
        f.write("\n---\n")
        f.write("*Generated by final_grade_calculator_EN.py*\n")
    
    print(f"Markdown report saved to: {md_path}")
    
    # Console summary
    print("\n" + "=" * 60)
    print("FINAL GRADES SUMMARY")
    print("=" * 60)
    print(f"Total students:  {total}")
    print(f"Passing:         {passing} ({passing*100/total:.1f}%)")
    print(f"Failing:         {failing} ({failing*100/total:.1f}%)")
    print(f"Eliminated:      {eliminated} ({eliminated*100/total:.1f}%)")
    print("=" * 60)


def main():
    parser = argparse.ArgumentParser(
        description="Calculate final grades from component scores",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s --homework hw.csv --project proj.csv --tests tests.csv -o grades
  %(prog)s -hw hw.csv -p proj.csv -t tests.csv --output final_grades

Formula:
  FINAL = (HW × 0.25) + (PROJECT × 0.50) + (TESTS × 0.25)

Elimination Criteria (80%):
  - Homework: minimum 25/31 submitted
  - Tests: minimum 5/6 taken
  - Project: must meet all eligibility requirements
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
    
    args = parser.parse_args()
    
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
            status_symbol = "✓" if student.status == "PASS" else "✗"
            print(f"  {status_symbol} {student.student_name}: {student.final_grade}")
    
    # Generate reports
    generate_report(results, args.output)


if __name__ == '__main__':
    main()
