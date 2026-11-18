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
import hashlib
import math
import os
import sys
from dataclasses import dataclass, field
from datetime import datetime, timezone
from pathlib import Path
from typing import Optional
from verification_engine import parse_header_and_events, seminar_label

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
    score: Optional[float] = None
    late_days: int = 0
    final_score: Optional[float] = None
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
    average_score: Optional[float] = None
    meets_threshold: Optional[bool] = None
    elimination_reason: str = ""


class HomeworkGrader:
    """Main grading engine."""
    
    def __init__(self, rubrics_dir: str, deadlines_file: Optional[str] = None, manual_scores=None):
        self.manual_scores = manual_scores or {}
        self.rubrics_dir = Path(rubrics_dir)
        self.rubrics = self._load_rubrics()
        self.deadlines = self._load_deadlines(deadlines_file) if deadlines_file else {}
        self.console = Console() if RICH_AVAILABLE else None
        
    def _load_rubrics(self) -> dict:
        """Load the supplied human rubrics as evidence, without inventing weights."""
        rubrics = {}
        for sem in SEMINARS:
            rubric_file = self.rubrics_dir / f"S{sem[3:]}_HOMEWORK_RUBRIC.md"
            if rubric_file.is_file():
                rubrics[sem] = {'path': str(rubric_file), 'text': rubric_file.read_text(encoding='utf-8')}
        return rubrics

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
        """Join explicit verification and a human-reviewed final score.

        No command/byte-count heuristic is an assessment. A missing score or
        rubric remains pending; timestamp and participation policy stay open.
        """
        if not submission.signature_valid:
            submission.comments.append("PENDING_VERIFICATION: no complete verified identity/signature record")
            return submission
        if submission.seminar not in self.rubrics:
            submission.comments.append("PENDING_REVIEW: corresponding human rubric is missing")
            return submission
        score = self._analyse_submission(submission, self.rubrics[submission.seminar])
        if score is None:
            submission.comments.append("PENDING_REVIEW: supply an explicit human-reviewed final_score")
            return submission
        submission.score = score
        submission.final_score = score
        submission.comments.append("Manual final_score; no automatic lateness deduction or eligibility decision")
        return submission

    def _analyse_submission(self, submission: HomeworkSubmission, rubric: dict) -> Optional[float]:
        """Return a supplied final score. The rubric remains the human assessor's evidence."""
        return self.manual_scores.get(Path(submission.file_path).resolve())

    def calculate_late_days(self, submission_time: datetime, deadline: datetime) -> int:
        """Calculate number of days late."""
        if submission_time <= deadline:
            return 0
            
        delta = submission_time - deadline
        return math.ceil(delta.total_seconds() / 86400)
    
    def aggregate_student_grades(self, submissions: list) -> dict:
        """Aggregate distinct assignments; a resubmission needs an explicit decision."""
        seen = set()
        students = {}
        for sub in submissions:
            assignment = (sub.student_id, sub.seminar, sub.homework_id)
            if assignment in seen:
                raise ValueError(f"Duplicate assignment requires explicit resubmission selection: {assignment}")
            seen.add(assignment)
            record = students.setdefault(sub.student_id, StudentRecord(
                student_id=sub.student_id, student_name=sub.student_name, student_group=sub.student_group))
            if (record.student_name, record.student_group) != (sub.student_name, sub.student_group):
                raise ValueError(f"Conflicting identity for student_id {sub.student_id}")
            record.submissions.append(sub)
            record.total_submitted += 1
            if sub.signature_valid and sub.final_score is not None:
                record.total_valid += 1
        for record in students.values():
            scores = [sub.final_score for sub in record.submissions if sub.final_score is not None]
            record.average_score = sum(scores) / len(scores) if scores else None
            record.meets_threshold = None
            record.elimination_reason = 'PENDING_POLICY: eligibility, authoritative time and resubmission rules need author approval'
        return students

    def generate_report(self, students: dict, output_path: str):
        """Generate grading report."""
        
        # CSV output
        csv_path = Path(output_path).with_suffix('.csv')
        with open(csv_path, 'w', newline='', encoding='utf-8') as f:
            writer = csv.writer(f)
            writer.writerow([
                'Student ID', 'Student Name', 'Group',
                'Distinct Submissions', 'Reviewed and Verified', 'Manual Final Score Average',
                'Meets Threshold', 'Status', 'Comments'
            ])
            
            for student_id, record in sorted(students.items()):
                status = "PENDING_POLICY"
                writer.writerow([
                    record.student_id,
                    record.student_name,
                    record.student_group,
                    record.total_submitted,
                    record.total_valid,
                    f"{record.average_score:.2f}" if record.average_score is not None else "PENDING_REVIEW",
                    "Undecided",
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
            status_style = "yellow"
            status_text = "PENDING_POLICY"
            
            table.add_row(
                record.student_name,
                record.student_group,
                f"{record.total_valid}/{record.total_submitted}",
                f"{record.average_score:.2f}" if record.average_score is not None else "PENDING_REVIEW",
                f"[{status_style}]{status_text}[/{status_style}]"
            )
        
        self.console.print(table)
        
        # Summary statistics
        total = len(students)
        passing = sum(1 for r in students.values() if r.meets_threshold)
        
        self.console.print(f"\n[bold]Summary:[/bold]")
        self.console.print(f"  Total students: {total}")
        self.console.print(f"  Pending author policy: {total}")
    
    def _print_text_report(self, students: dict):
        """Print plain text report."""
        print("\n" + "=" * 70)
        print("HOMEWORK GRADING SUMMARY")
        print("=" * 70)
        
        for student_id, record in sorted(students.items()):
            status = "PENDING_POLICY"
            print(f"\n{record.student_name} ({record.student_group})")
            print(f"  Submissions: {record.total_valid}/{record.total_submitted}")
            print(f"  Average: {record.average_score if record.average_score is not None else 'PENDING_REVIEW'}")
            print(f"  Status: {status}")
            if record.elimination_reason:
                print(f"  Reason: {record.elimination_reason}")


def main():
    parser = argparse.ArgumentParser(
        description="Grade homework submissions",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s -s ./submissions --verification ./verification/verification_results.csv -o grades.csv
  %(prog)s -s ./submissions --verification ./verification/verification_results.csv --scores reviewed_scores.csv -d deadlines.csv -o grades.csv
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
        help='Compatibility argument only; rubric files are read by the human reviewer, not scored by this tool'
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
    
    parser.add_argument('--verification', required=True, type=Path,
                        help='Explicit verification_results.csv from the SEM07 verifier')
    parser.add_argument('--scores', type=Path,
                        help='Human-reviewed CSV: file,final_score; final scores are not penalised again')
    args = parser.parse_args()
    
    # Validate inputs
    if not os.path.isdir(args.submissions):
        print(f"Error: Submissions directory not found: {args.submissions}")
        sys.exit(1)
    
    submissions_dir = Path(args.submissions).resolve()
    try:
        with args.verification.open(newline='', encoding='utf-8') as handle:
            verified = {}
            for row in csv.DictReader(handle):
                key = row['File']
                if key in verified:
                    raise ValueError(f'Duplicate verification row: {key}')
                verified[key] = row
        scores = {}
        if args.scores:
            with args.scores.open(newline='', encoding='utf-8') as handle:
                for row in csv.DictReader(handle):
                    target = (submissions_dir / row['file']).resolve()
                    if not target.is_relative_to(submissions_dir) or target in scores:
                        raise ValueError('Score path escapes the source directory or is duplicated')
                    score = float(row['final_score'])
                    if not math.isfinite(score) or not 0 <= score <= 10:
                        raise ValueError('final_score must be finite and between 0 and 10')
                    scores[target] = score
        grader = HomeworkGrader(args.rubrics, args.deadlines, scores)
        submissions, rejected = [], []
        for cast_file in sorted(submissions_dir.rglob('*.cast')):
            if cast_file.is_symlink() or not cast_file.is_file():
                continue
            key = cast_file.relative_to(submissions_dir).as_posix()
            try:
                data = cast_file.read_bytes()
                header, _ = parse_header_and_events(data)
                required = ('student_id', 'student_name', 'student_group', 'homework_id')
                if any(not isinstance(header.get(k), str) or not header[k].strip()
                       or header[k].upper() == 'UNKNOWN' for k in required):
                    raise ValueError('MISSING_METADATA: complete explicit identity and assignment are required')
                seminar = seminar_label(header.get('seminar'))
                if seminar not in SEMINARS:
                    raise ValueError('Unknown seminar')
                row = verified.get(key, {})
                matches = (row.get('Signature_Status') == 'VALID' and row.get('Metadata_Status') == 'COMPLETE'
                           and row.get('Source_SHA256') == hashlib.sha256(data).hexdigest()
                           and (row.get('Student'), row.get('Group'), row.get('Seminar')) ==
                           (header['student_name'], header['student_group'], seminar))
                stamp = header.get('timestamp')
                if type(stamp) is not int or stamp < 0:
                    raise ValueError('Missing or invalid timestamp')
                submission = HomeworkSubmission(
                    student_id=header['student_id'], student_name=header['student_name'],
                    student_group=header['student_group'], seminar=seminar,
                    homework_id=header['homework_id'], file_path=str(cast_file),
                    timestamp=datetime.fromtimestamp(stamp, tz=timezone.utc), signature_valid=matches)
                deadline = grader.deadlines.get(f"{submission.seminar}_{submission.homework_id}")
                if deadline:
                    if deadline.tzinfo is None:
                        raise ValueError('Deadline must include a timezone; client timestamp authority remains undecided')
                    submission.deadline = deadline
                    submission.late_days = grader.calculate_late_days(submission.timestamp, deadline)
                submissions.append(grader.grade_submission(submission))
            except (OSError, ValueError, TypeError, KeyError, IndexError, OverflowError) as exc:
                rejected.append({'file': key, 'reason': str(exc)})
        students = grader.aggregate_student_grades(submissions)
        grader.generate_report(students, args.output)
        detail = {'status': 'PRELIMINARY_REVIEW_ONLY', 'rejected': rejected,
                  'submissions': [{'file': s.file_path, 'verified': s.signature_valid,
                                   'manual_final_score': s.final_score, 'late_days_from_client_time': s.late_days,
                                   'comments': s.comments} for s in submissions]}
        Path(args.output).with_suffix('.review.json').write_text(json.dumps(detail, indent=2)+'\n')
        return 2 if rejected or any(s.final_score is None for s in submissions) else 0
    except (OSError, ValueError, KeyError, TypeError) as exc:
        print(f'Cannot produce a grading report: {exc}', file=sys.stderr)
        return 1


if __name__ == '__main__':
    raise SystemExit(main())
