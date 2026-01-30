#!/usr/bin/env python3
"""
grade_homework_EN.py - Automated Homework Grading Script
=========================================================
Operating Systems | ASE Bucharest - CSIE

Grades homework submissions based on rubrics and generates reports.
"""

import argparse
import csv
import json
import os
import sys
from dataclasses import dataclass, field
from datetime import datetime
from pathlib import Path
from typing import Optional

try:
    from rich.console import Console
    from rich.table import Table
    from rich.progress import Progress, SpinnerColumn, TextColumn
    RICH_AVAILABLE = True
except ImportError:
    RICH_AVAILABLE = False

# Configuration
SEMINARS = ['SEM01', 'SEM02', 'SEM03', 'SEM04', 'SEM05', 'SEM06']
HOMEWORK_COUNTS = {
    'SEM01': 6,  # S01b - S01g
    'SEM02': 5,  # S02b - S02f
    'SEM03': 6,  # S03b - S03g
    'SEM04': 5,  # S04b - S04f
    'SEM05': 6,  # S05a - S05f
    'SEM06': 3,  # S06_HW01 - S06_HW03
}
TOTAL_HOMEWORKS = sum(HOMEWORK_COUNTS.values())  # 31
MINIMUM_THRESHOLD = 25  # 80% of 31

# Late submission penalties
LATE_PENALTIES = {
    1: 0.20,   # Day 1: -20%
    2: 0.40,   # Day 2: -40%
    3: 0.60,   # Day 3: -60%
}
MAX_LATE_DAYS = 3


@dataclass
class HomeworkSubmission:
    """Represents a single homework submission."""
    student_id: str
    student_name: str
    student_group: str
    seminar: str
    homework_id: str
    file_path: str
    timestamp: datetime
    deadline: Optional[datetime] = None
    signature_valid: bool = False
    score: float = 0.0
    late_days: int = 0
    final_score: float = 0.0
    comments: list = field(default_factory=list)


@dataclass
class StudentRecord:
    """Aggregated record for a student."""
    student_id: str
    student_name: str
    student_group: str
    submissions: list = field(default_factory=list)
    total_submitted: int = 0
    total_valid: int = 0
    average_score: float = 0.0
    meets_threshold: bool = False
    elimination_reason: str = ""


class HomeworkGrader:
    """Main grading engine."""
    
    def __init__(self, rubrics_dir: str, deadlines_file: Optional[str] = None):
        self.rubrics_dir = Path(rubrics_dir)
        self.rubrics = self._load_rubrics()
        self.deadlines = self._load_deadlines(deadlines_file) if deadlines_file else {}
        self.console = Console() if RICH_AVAILABLE else None
        
    def _load_rubrics(self) -> dict:
        """Load grading rubrics from markdown files."""
        rubrics = {}
        
        for sem in SEMINARS:
            rubric_file = self.rubrics_dir / f"{sem}_HOMEWORK_RUBRIC.md"
            if rubric_file.exists():
                rubrics[sem] = self._parse_rubric(rubric_file)
            else:
                # Default rubric
                rubrics[sem] = {
                    'max_score': 10.0,
                    'criteria': {
                        'completion': 4.0,
                        'correctness': 4.0,
                        'style': 2.0,
                    }
                }
        
        return rubrics
    
    def _parse_rubric(self, rubric_file: Path) -> dict:
        """Parse rubric markdown file."""
        # Simplified parser - in production, use proper markdown parsing
        rubric = {'max_score': 10.0, 'criteria': {}}
        
        with open(rubric_file, 'r', encoding='utf-8') as f:
            content = f.read()
            
        # Extract criteria from markdown tables
        # This is a simplified implementation
        if 'completion' in content.lower():
            rubric['criteria']['completion'] = 4.0
        if 'correctness' in content.lower():
            rubric['criteria']['correctness'] = 4.0
        if 'style' in content.lower():
            rubric['criteria']['style'] = 2.0
            
        return rubric
    
    def _load_deadlines(self, deadlines_file: str) -> dict:
        """Load deadline information from CSV."""
        deadlines = {}
        
        with open(deadlines_file, 'r', encoding='utf-8') as f:
            reader = csv.DictReader(f)
            for row in reader:
                key = f"{row['seminar']}_{row['homework_id']}"
                deadlines[key] = datetime.fromisoformat(row['deadline'])
                
        return deadlines
    
    def grade_submission(self, submission: HomeworkSubmission) -> HomeworkSubmission:
        """Grade a single submission."""
        
        # Check signature validity
        if not submission.signature_valid:
            submission.score = 0.0
            submission.final_score = 0.0
            submission.comments.append("Invalid or missing signature")
            return submission
        
        # Get rubric for this seminar
        rubric = self.rubrics.get(submission.seminar, self.rubrics['SEM01'])
        
        # Analyse submission (simplified - in production, run actual tests)
        score = self._analyse_submission(submission, rubric)
        submission.score = score
        
        # Apply late penalty
        if submission.late_days > 0:
            if submission.late_days > MAX_LATE_DAYS:
                submission.final_score = 0.0
                submission.comments.append(f"Submitted {submission.late_days} days late (max {MAX_LATE_DAYS})")
            else:
                penalty = LATE_PENALTIES.get(submission.late_days, 0.60)
                submission.final_score = score * (1 - penalty)
                submission.comments.append(f"Late penalty: -{penalty*100:.0f}%")
        else:
            submission.final_score = score
            
        return submission
    
    def _analyse_submission(self, submission: HomeworkSubmission, rubric: dict) -> float:
        """Analyse submission content and compute score."""
        
        # In production, this would:
        # 1. Parse the .cast file
        # 2. Extract commands executed
        # 3. Verify expected outputs
        # 4. Check for required elements
        
        # Simplified scoring based on file existence and size
        file_path = Path(submission.file_path)
        
        if not file_path.exists():
            return 0.0
            
        file_size = file_path.stat().st_size
        
        # Basic heuristics (replace with actual analysis)
        if file_size < 100:
            return 2.0  # Minimal content
        elif file_size < 1000:
            return 5.0  # Partial completion
        elif file_size < 5000:
            return 7.0  # Good completion
        else:
            return 9.0  # Comprehensive
    
    def calculate_late_days(self, submission_time: datetime, deadline: datetime) -> int:
        """Calculate number of days late."""
        if submission_time <= deadline:
            return 0
            
        delta = submission_time - deadline
        return delta.days + (1 if delta.seconds > 0 else 0)
    
    def aggregate_student_grades(self, submissions: list) -> dict:
        """Aggregate grades by student."""
        students = {}
        
        for sub in submissions:
            if sub.student_id not in students:
                students[sub.student_id] = StudentRecord(
                    student_id=sub.student_id,
                    student_name=sub.student_name,
                    student_group=sub.student_group,
                )
            
            record = students[sub.student_id]
            record.submissions.append(sub)
            record.total_submitted += 1
            
            if sub.signature_valid and sub.final_score > 0:
                record.total_valid += 1
        
        # Calculate averages and check threshold
        for student_id, record in students.items():
            if record.total_valid > 0:
                valid_scores = [s.final_score for s in record.submissions 
                               if s.signature_valid and s.final_score > 0]
                record.average_score = sum(valid_scores) / len(valid_scores)
            
            # Check 80% threshold
            if record.total_valid >= MINIMUM_THRESHOLD:
                record.meets_threshold = True
            else:
                record.meets_threshold = False
                record.elimination_reason = (
                    f"Only {record.total_valid}/{TOTAL_HOMEWORKS} valid submissions "
                    f"(minimum: {MINIMUM_THRESHOLD})"
                )
        
        return students
    
    def generate_report(self, students: dict, output_path: str):
        """Generate grading report."""
        
        # CSV output
        csv_path = Path(output_path).with_suffix('.csv')
        with open(csv_path, 'w', newline='', encoding='utf-8') as f:
            writer = csv.writer(f)
            writer.writerow([
                'Student ID', 'Student Name', 'Group',
                'Submitted', 'Valid', 'Average Score',
                'Meets Threshold', 'Status', 'Comments'
            ])
            
            for student_id, record in sorted(students.items()):
                status = "PASS" if record.meets_threshold else "ELIMINATION"
                writer.writerow([
                    record.student_id,
                    record.student_name,
                    record.student_group,
                    record.total_submitted,
                    record.total_valid,
                    f"{record.average_score:.2f}",
                    "Yes" if record.meets_threshold else "No",
                    status,
                    record.elimination_reason,
                ])
        
        # Rich console output
        if RICH_AVAILABLE and self.console:
            self._print_rich_report(students)
        else:
            self._print_text_report(students)
            
        print(f"\nResults saved to: {csv_path}")
    
    def _print_rich_report(self, students: dict):
        """Print formatted report using Rich."""
        table = Table(title="Homework Grading Summary")
        
        table.add_column("Student", style="cyan")
        table.add_column("Group", style="magenta")
        table.add_column("Valid/Total", justify="center")
        table.add_column("Average", justify="right")
        table.add_column("Status", justify="center")
        
        for student_id, record in sorted(students.items()):
            status_style = "green" if record.meets_threshold else "red"
            status_text = "✓ PASS" if record.meets_threshold else "✗ ELIM"
            
            table.add_row(
                record.student_name,
                record.student_group,
                f"{record.total_valid}/{record.total_submitted}",
                f"{record.average_score:.2f}",
                f"[{status_style}]{status_text}[/{status_style}]"
            )
        
        self.console.print(table)
        
        # Summary statistics
        total = len(students)
        passing = sum(1 for r in students.values() if r.meets_threshold)
        
        self.console.print(f"\n[bold]Summary:[/bold]")
        self.console.print(f"  Total students: {total}")
        self.console.print(f"  [green]Passing:[/green] {passing}")
        self.console.print(f"  [red]Eliminated:[/red] {total - passing}")
    
    def _print_text_report(self, students: dict):
        """Print plain text report."""
        print("\n" + "=" * 70)
        print("HOMEWORK GRADING SUMMARY")
        print("=" * 70)
        
        for student_id, record in sorted(students.items()):
            status = "PASS" if record.meets_threshold else "ELIMINATION"
            print(f"\n{record.student_name} ({record.student_group})")
            print(f"  Submissions: {record.total_valid}/{record.total_submitted}")
            print(f"  Average: {record.average_score:.2f}")
            print(f"  Status: {status}")
            if record.elimination_reason:
                print(f"  Reason: {record.elimination_reason}")


def main():
    parser = argparse.ArgumentParser(
        description="Grade homework submissions",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s -s /submissions/ -r ./rubrics/ -o grades.csv
  %(prog)s -s /submissions/ -r ./rubrics/ -d deadlines.csv -o grades.csv
        """
    )
    
    parser.add_argument(
        '-s', '--submissions',
        required=True,
        help='Directory containing .cast submissions'
    )
    parser.add_argument(
        '-r', '--rubrics',
        default='./homework_rubrics',
        help='Directory containing rubric files'
    )
    parser.add_argument(
        '-d', '--deadlines',
        help='CSV file with deadline information'
    )
    parser.add_argument(
        '-o', '--output',
        default='homework_grades.csv',
        help='Output file for grades'
    )
    parser.add_argument(
        '-v', '--verbose',
        action='store_true',
        help='Verbose output'
    )
    
    args = parser.parse_args()
    
    # Validate inputs
    if not os.path.isdir(args.submissions):
        print(f"Error: Submissions directory not found: {args.submissions}")
        sys.exit(1)
    
    # Initialise grader
    grader = HomeworkGrader(args.rubrics, args.deadlines)
    
    # Process submissions
    submissions = []
    submissions_dir = Path(args.submissions)
    
    for cast_file in submissions_dir.rglob("*.cast"):
        # Parse submission metadata
        try:
            with open(cast_file, 'r', encoding='utf-8') as f:
                header = json.loads(f.readline())
                
            submission = HomeworkSubmission(
                student_id=header.get('student_id', 'UNKNOWN'),
                student_name=header.get('student_name', 'UNKNOWN'),
                student_group=header.get('student_group', 'UNKNOWN'),
                seminar=header.get('seminar', 'SEM01'),
                homework_id=header.get('homework_id', ''),
                file_path=str(cast_file),
                timestamp=datetime.fromtimestamp(header.get('timestamp', 0)),
                signature_valid=True,  # Assume pre-verified
            )
            
            # Grade submission
            graded = grader.grade_submission(submission)
            submissions.append(graded)
            
            if args.verbose:
                print(f"Graded: {cast_file.name} -> {graded.final_score:.2f}")
                
        except (json.JSONDecodeError, KeyError) as e:
            print(f"Warning: Could not parse {cast_file}: {e}")
    
    # Aggregate and report
    students = grader.aggregate_student_grades(submissions)
    grader.generate_report(students, args.output)


if __name__ == '__main__':
    main()
