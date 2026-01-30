#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
╔══════════════════════════════════════════════════════════════════════════════╗
║              REPORT GENERATOR - SEMINAR 5-6                                   ║
║              Operating Systems | Bucharest UES - CSIE                         ║
╠══════════════════════════════════════════════════════════════════════════════╣
║  Generates progress reports based on:                                         ║
║  • Quiz results (from S03_02_quiz_generator.py)                               ║
║  • Autograder results (from S03_01_autograder.py)                             ║
║  • Laboratory activity and participation                                      ║
╠══════════════════════════════════════════════════════════════════════════════╣
║  USAGE:                                                                       ║
║    python3 S03_03_report_generator.py --student RESULTS_DIR                   ║
║    python3 S03_03_report_generator.py --class SUBMISSIONS_DIR                 ║
║    python3 S03_03_report_generator.py --individual student1.json -o report.md ║
║    python3 S03_03_report_generator.py --summary --format html                 ║
╚══════════════════════════════════════════════════════════════════════════════╝

Version: 1.0
Date: January 2025
"""

import argparse
import json
import os
import sys
import glob
from dataclasses import dataclass, field
from datetime import datetime
from typing import List, Dict, Any, Optional, Tuple
from pathlib import Path
import statistics
import textwrap

# ═══════════════════════════════════════════════════════════════════════════════
# CONSTANTS AND CONFIGURATION
# ═══════════════════════════════════════════════════════════════════════════════

VERSION = "1.0"
PROGRAM_NAME = "Report Generator - SEM03"

# Grading thresholds
GRADE_THRESHOLDS = {
    10: 90,
    9: 80,
    8: 70,
    7: 60,
    6: 50,
    5: 40,
    4: 0
}

# Seminar categories
CATEGORIES = {
    'find_xargs': {
        'name': 'Find and Xargs',
        'emoji': '🔍',
        'weight': 0.20,
        'description': 'Advanced search and batch processing utilities'
    },
    'parameters': {
        'name': 'Script Parameters',
        'emoji': '📝',
        'weight': 0.25,
        'description': 'Arguments, getopts, shift, validation'
    },
    'permissions': {
        'name': 'Unix Permissions',
        'emoji': '🔒',
        'weight': 0.30,
        'description': 'chmod, chown, umask, SUID/SGID/Sticky'
    },
    'cron': {
        'name': 'Cron Automation',
        'emoji': '⏰',
        'weight': 0.25,
        'description': 'Task scheduling, crontab, at'
    }
}

# ANSI colours
class Colours:
    HEADER = '\033[95m'
    BLUE = '\033[94m'
    CYAN = '\033[96m'
    GREEN = '\033[92m'
    YELLOW = '\033[93m'
    RED = '\033[91m'
    BOLD = '\033[1m'
    DIM = '\033[2m'
    END = '\033[0m'

def color(text: str, c: str, use_color: bool = True) -> str:
    """Apply colour to text."""
    return f"{c}{text}{Colours.END}" if use_color else text

# ═══════════════════════════════════════════════════════════════════════════════
# DATA MODELS
# ═══════════════════════════════════════════════════════════════════════════════

@dataclass
class QuizResult:
    """Result of a quiz."""
    quiz_id: str
    timestamp: datetime
    score_percentage: float
    correct: int
    wrong: int
    skipped: int
    time_seconds: float
    categories_breakdown: Dict[str, Dict[str, int]]
    questions_results: List[Dict[str, Any]] = field(default_factory=list)
    
    @classmethod
    def from_json(cls, data: Dict[str, Any], quiz_id: str = "unknown") -> 'QuizResult':
        """Create from JSON dictionary."""
        return cls(
            quiz_id=quiz_id,
            timestamp=datetime.fromisoformat(data.get('timestamp', datetime.now().isoformat())),
            score_percentage=data.get('score_percentage', 0),
            correct=data.get('correct', 0),
            wrong=data.get('wrong', 0),
            skipped=data.get('skipped', 0),
            time_seconds=data.get('time_seconds', 0),
            categories_breakdown=data.get('categories', {}),
            questions_results=data.get('questions', [])
        )

@dataclass
class AutograderResult:
    """Result from the autograder."""
    submission_id: str
    timestamp: datetime
    total_points: float
    max_points: float
    percentage: float
    grade: str
    categories: Dict[str, Dict[str, Any]]
    security_issues: List[str] = field(default_factory=list)
    suggestions: List[str] = field(default_factory=list)
    
    @classmethod
    def from_json(cls, data: Dict[str, Any], submission_id: str = "unknown") -> 'AutograderResult':
        """Create from JSON dictionary."""
        return cls(
            submission_id=submission_id,
            timestamp=datetime.fromisoformat(data.get('timestamp', datetime.now().isoformat())),
            total_points=data.get('total_points', 0),
            max_points=data.get('max_points', 100),
            percentage=data.get('percentage', 0),
            grade=data.get('grade', 'N/A'),
            categories=data.get('categories', {}),
            security_issues=data.get('security_issues', []),
            suggestions=data.get('suggestions', [])
        )

@dataclass
class StudentProgress:
    """Complete progress of a student."""
    student_id: str
    name: str
    quiz_results: List[QuizResult] = field(default_factory=list)
    autograder_results: List[AutograderResult] = field(default_factory=list)
    participation_notes: List[str] = field(default_factory=list)
    
    @property
    def average_quiz_score(self) -> float:
        """Average quiz scores."""
        if not self.quiz_results:
            return 0.0
        return statistics.mean(q.score_percentage for q in self.quiz_results)
    
    @property
    def best_quiz_score(self) -> float:
        """Best quiz score."""
        if not self.quiz_results:
            return 0.0
        return max(q.score_percentage for q in self.quiz_results)
    
    @property
    def average_homework_score(self) -> float:
        """Average assignment scores."""
        if not self.autograder_results:
            return 0.0
        return statistics.mean(a.percentage for a in self.autograder_results)
    
    @property
    def category_strengths(self) -> Dict[str, float]:
        """Strengths by category."""
        scores = {cat: [] for cat in CATEGORIES}
        
        for quiz in self.quiz_results:
            for cat, data in quiz.categories_breakdown.items():
                total = data.get('correct', 0) + data.get('wrong', 0) + data.get('skipped', 0)
                if total > 0:
                    scores[cat].append(data.get('correct', 0) / total * 100)
        
        return {cat: statistics.mean(s) if s else 0 for cat, s in scores.items()}
    
    @property
    def weakest_category(self) -> Optional[str]:
        """Category with the weakest results."""
        strengths = self.category_strengths
        if not any(strengths.values()):
            return None
        return min(strengths, key=strengths.get)
    
    @property
    def strongest_category(self) -> Optional[str]:
        """Category with the best results."""
        strengths = self.category_strengths
        if not any(strengths.values()):
            return None
        return max(strengths, key=strengths.get)
    
    def calculate_final_grade(self) -> Tuple[float, str]:
        """Calculate estimated final grade."""
        quiz_weight = 0.3
        homework_weight = 0.7
        
        quiz_score = self.average_quiz_score if self.quiz_results else 50
        hw_score = self.average_homework_score if self.autograder_results else 50
        
        final = quiz_score * quiz_weight + hw_score * homework_weight
        
        grade = '4'
        for g, threshold in sorted(GRADE_THRESHOLDS.items(), reverse=True):
            if final >= threshold:
                grade = str(g)
                break
        
        return final, grade

@dataclass
class ClassStatistics:
    """Statistics for a class/group."""
    total_students: int
    students_with_submissions: int
    average_score: float
    median_score: float
    std_deviation: float
    min_score: float
    max_score: float
    grade_distribution: Dict[str, int]
    category_averages: Dict[str, float]
    common_mistakes: List[Tuple[str, int]]
    security_issues_count: int

# ═══════════════════════════════════════════════════════════════════════════════
# DATA LOADING
# ═══════════════════════════════════════════════════════════════════════════════

class DataLoader:
    """Data loader from JSON files."""
    
    @staticmethod
    def load_quiz_results(directory: str) -> List[QuizResult]:
        """Load quiz results from a directory."""
        results = []
        pattern = os.path.join(directory, "quiz_result_*.json")
        
        for filepath in glob.glob(pattern):
            try:
                with open(filepath, 'r', encoding='utf-8') as f:
                    data = json.load(f)
                quiz_id = os.path.basename(filepath).replace('.json', '')
                results.append(QuizResult.from_json(data, quiz_id))
            except (json.JSONDecodeError, IOError) as e:
                print(f"⚠️  Error loading {filepath}: {e}")
        
        return sorted(results, key=lambda x: x.timestamp)
    
    @staticmethod
    def load_autograder_results(directory: str) -> List[AutograderResult]:
        """Load autograder results from a directory."""
        results = []
        pattern = os.path.join(directory, "autograder_*.json")
        
        for filepath in glob.glob(pattern):
            try:
                with open(filepath, 'r', encoding='utf-8') as f:
                    data = json.load(f)
                submission_id = os.path.basename(filepath).replace('.json', '')
                results.append(AutograderResult.from_json(data, submission_id))
            except (json.JSONDecodeError, IOError) as e:
                print(f"⚠️  Error loading {filepath}: {e}")
        
        return sorted(results, key=lambda x: x.timestamp)
    
    @staticmethod
    def load_student_progress(student_dir: str, student_id: str, 
                              name: str = "") -> StudentProgress:
        """Load complete progress for a student."""
        progress = StudentProgress(
            student_id=student_id,
            name=name or student_id,
            quiz_results=DataLoader.load_quiz_results(student_dir),
            autograder_results=DataLoader.load_autograder_results(student_dir)
        )
        return progress
    
    @staticmethod
    def load_class_data(submissions_dir: str) -> List[StudentProgress]:
        """Load data for the entire class."""
        students = []
        
        if not os.path.isdir(submissions_dir):
            return students
        
        for entry in os.scandir(submissions_dir):
            if entry.is_dir():
                student_id = entry.name
                progress = DataLoader.load_student_progress(entry.path, student_id)
                if progress.quiz_results or progress.autograder_results:
                    students.append(progress)
        
        return students

# ═══════════════════════════════════════════════════════════════════════════════
# DATA ANALYSER
# ═══════════════════════════════════════════════════════════════════════════════

class DataAnalyser:
    """Analyses data and calculates statistics."""
    
    @staticmethod
    def analyse_class(students: List[StudentProgress]) -> ClassStatistics:
        """Analyse class statistics."""
        if not students:
            return ClassStatistics(
                total_students=0,
                students_with_submissions=0,
                average_score=0,
                median_score=0,
                std_deviation=0,
                min_score=0,
                max_score=0,
                grade_distribution={},
                category_averages={},
                common_mistakes=[],
                security_issues_count=0
            )
        
        # Final scores
        scores = []
        grades = []
        category_scores = {cat: [] for cat in CATEGORIES}
        mistake_counts = {}
        security_count = 0
        
        for student in students:
            score, grade = student.calculate_final_grade()
            scores.append(score)
            grades.append(grade)
            
            # Categories
            for cat, cat_score in student.category_strengths.items():
                if cat_score > 0:
                    category_scores[cat].append(cat_score)
            
            # Common mistakes from quizzes
            for quiz in student.quiz_results:
                for q_result in quiz.questions_results:
                    if not q_result.get('is_correct', True):
                        q_id = q_result.get('question_id', 'unknown')
                        mistake_counts[q_id] = mistake_counts.get(q_id, 0) + 1
            
            # Security issues
            for ag in student.autograder_results:
                security_count += len(ag.security_issues)
        
        # Calculate statistics
        grade_dist = {}
        for g in grades:
            grade_dist[g] = grade_dist.get(g, 0) + 1
        
        common_mistakes = sorted(mistake_counts.items(), key=lambda x: -x[1])[:10]
        
        return ClassStatistics(
            total_students=len(students),
            students_with_submissions=len([s for s in students 
                                          if s.quiz_results or s.autograder_results]),
            average_score=statistics.mean(scores) if scores else 0,
            median_score=statistics.median(scores) if scores else 0,
            std_deviation=statistics.stdev(scores) if len(scores) > 1 else 0,
            min_score=min(scores) if scores else 0,
            max_score=max(scores) if scores else 0,
            grade_distribution=grade_dist,
            category_averages={cat: statistics.mean(s) if s else 0 
                             for cat, s in category_scores.items()},
            common_mistakes=common_mistakes,
            security_issues_count=security_count
        )
    
    @staticmethod
    def identify_struggling_students(students: List[StudentProgress], 
                                    threshold: float = 50.0) -> List[StudentProgress]:
        """Identify students with difficulties."""
        struggling = []
        for student in students:
            score, _ = student.calculate_final_grade()
            if score < threshold:
                struggling.append(student)
        return sorted(struggling, key=lambda s: s.calculate_final_grade()[0])
    
    @staticmethod
    def identify_top_performers(students: List[StudentProgress], 
                               top_n: int = 5) -> List[StudentProgress]:
        """Identify the best performing students."""
        return sorted(students, 
                     key=lambda s: s.calculate_final_grade()[0], 
                     reverse=True)[:top_n]
    
    @staticmethod
    def get_improvement_suggestions(student: StudentProgress) -> List[str]:
        """Generate personalised improvement suggestions."""
        suggestions = []
        
        # Check the weakest category
        weakest = student.weakest_category
        if weakest:
            cat_info = CATEGORIES.get(weakest, {})
            suggestions.append(
                f"📚 Focus on {cat_info.get('name', weakest)}: "
                f"{cat_info.get('description', '')}"
            )
        
        # Check progress over time
        if len(student.quiz_results) >= 2:
            recent = student.quiz_results[-1].score_percentage
            previous = student.quiz_results[-2].score_percentage
            if recent < previous:
                suggestions.append(
                    f"📉 Your latest quiz score ({recent:.0f}%) is lower than the previous one "
                    f"({previous:.0f}%). Review the materials!"
                )
        
        # Check time spent on quizzes
        for quiz in student.quiz_results:
            avg_time = quiz.time_seconds / (quiz.correct + quiz.wrong + quiz.skipped)
            if avg_time < 15:  # less than 15 seconds per question
                suggestions.append(
                    "⏱️ You spend very little time on each question. "
                    "Read the statements more carefully!"
                )
                break
        
        # Check security issues
        for ag in student.autograder_results:
            if ag.security_issues:
                suggestions.append(
                    "🔒 You have security issues in your code! Review: "
                    + ", ".join(ag.security_issues[:3])
                )
                break
        
        # Check skipped questions
        total_skipped = sum(q.skipped for q in student.quiz_results)
        if total_skipped > 3:
            suggestions.append(
                f"⏭️ You skipped {total_skipped} questions. "
                "Try to answer all of them, even if you're not sure!"
            )
        
        if not suggestions:
            suggestions.append("✨ Keep it up! You're on the right track.")
        
        return suggestions

# ═══════════════════════════════════════════════════════════════════════════════
# REPORT GENERATOR
# ═══════════════════════════════════════════════════════════════════════════════

class ReportGenerator:
    """Generates reports in various formats."""
    
    def __init__(self, use_color: bool = True):
        self.use_color = use_color
    
    # ───────────────────────────────────────────────────────────────────────────
    # INDIVIDUAL STUDENT REPORTS
    # ───────────────────────────────────────────────────────────────────────────
    
    def generate_student_report_console(self, student: StudentProgress) -> str:
        """Generate report for a student in text/console format."""
        lines = []
        
        # Header
        lines.append("═" * 70)
        lines.append(color(f"  📊 PROGRESS REPORT - {student.name.upper()}", 
                          Colours.BOLD + Colours.CYAN, self.use_color))
        lines.append(f"  Generated: {datetime.now().strftime('%Y-%m-%d %H:%M')}")
        lines.append("═" * 70)
        
        # Estimated final grade
        final_score, grade = student.calculate_final_grade()
        grade_color = Colours.GREEN if int(grade) >= 5 else Colours.RED
        lines.append(f"\n  📝 ESTIMATED FINAL GRADE: {color(grade, grade_color + Colours.BOLD, self.use_color)}")
        lines.append(f"  📈 Overall score: {final_score:.1f}%")
        
        # Quiz statistics
        lines.append(color("\n  🎯 QUIZZES", Colours.YELLOW, self.use_color))
        lines.append("  " + "─" * 40)
        if student.quiz_results:
            lines.append(f"  Quizzes completed:   {len(student.quiz_results)}")
            lines.append(f"  Average score:       {student.average_quiz_score:.1f}%")
            lines.append(f"  Best score:          {student.best_quiz_score:.1f}%")
            
            # Latest quiz
            last = student.quiz_results[-1]
            lines.append(f"  Latest quiz:         {last.score_percentage:.1f}% "
                        f"({last.correct}/{last.correct + last.wrong + last.skipped} correct)")
        else:
            lines.append("  ⚠️  You haven't completed any quizzes.")
        
        # Assignment statistics
        lines.append(color("\n  📚 ASSIGNMENTS (AUTOGRADER)", Colours.YELLOW, self.use_color))
        lines.append("  " + "─" * 40)
        if student.autograder_results:
            lines.append(f"  Assignments graded:  {len(student.autograder_results)}")
            lines.append(f"  Average score:       {student.average_homework_score:.1f}%")
            
            # Latest assignment
            last = student.autograder_results[-1]
            lines.append(f"  Latest assignment:   {last.percentage:.1f}% (grade {last.grade})")
            
            if last.security_issues:
                lines.append(color(f"  ⚠️  Security issues: {len(last.security_issues)}", 
                                  Colours.RED, self.use_color))
        else:
            lines.append("  ⚠️  You haven't submitted any graded assignments.")
        
        # Categories
        lines.append(color("\n  📊 STRENGTHS / WEAKNESSES BY CATEGORY", Colours.YELLOW, self.use_color))
        lines.append("  " + "─" * 40)
        
        strengths = student.category_strengths
        for cat_id, score in sorted(strengths.items(), key=lambda x: -x[1]):
            cat = CATEGORIES.get(cat_id, {})
            emoji = cat.get('emoji', '📋')
            name = cat.get('name', cat_id)
            
            bar_len = int(score / 5)
            bar = "█" * bar_len + "░" * (20 - bar_len)
            score_color = Colours.GREEN if score >= 70 else (Colours.YELLOW if score >= 50 else Colours.RED)
            
            lines.append(f"  {emoji} {name:20} [{bar}] {color(f'{score:.0f}%', score_color, self.use_color)}")
        
        # Suggestions
        suggestions = DataAnalyser.get_improvement_suggestions(student)
        lines.append(color("\n  💡 IMPROVEMENT SUGGESTIONS", Colours.YELLOW, self.use_color))
        lines.append("  " + "─" * 40)
        for suggestion in suggestions:
            wrapped = textwrap.wrap(suggestion, width=60)
            for i, line in enumerate(wrapped):
                prefix = "  • " if i == 0 else "    "
                lines.append(prefix + line)
        
        # Progress
        if len(student.quiz_results) >= 2:
            lines.append(color("\n  📈 QUIZ PROGRESS", Colours.YELLOW, self.use_color))
            lines.append("  " + "─" * 40)
            for i, quiz in enumerate(student.quiz_results[-5:], 1):
                date = quiz.timestamp.strftime('%Y-%m-%d')
                lines.append(f"  {i}. [{date}] {quiz.score_percentage:.0f}%")
        
        lines.append("\n" + "═" * 70)
        
        return '\n'.join(lines)
    
    def generate_student_report_markdown(self, student: StudentProgress) -> str:
        """Generate report for a student in Markdown format."""
        final_score, grade = student.calculate_final_grade()
        
        md = f"""# 📊 Progress Report - {student.name}

**Generated**: {datetime.now().strftime('%Y-%m-%d %H:%M')}  
**Student ID**: {student.student_id}

---

##  Summary

| Metric | Value |
|--------|-------|
| **Estimated Final Grade** | **{grade}** |
| Overall Score | {final_score:.1f}% |
| Quizzes Completed | {len(student.quiz_results)} |
| Assignments Submitted | {len(student.autograder_results)} |

---

##  Quiz Results

"""
        if student.quiz_results:
            md += f"""- **Average score**: {student.average_quiz_score:.1f}%
- **Best score**: {student.best_quiz_score:.1f}%
- **Latest quiz**: {student.quiz_results[-1].score_percentage:.1f}%

### Quiz History

| Date | Score | Correct | Wrong | Skipped |
|------|-------|---------|-------|---------|
"""
            for quiz in student.quiz_results[-10:]:
                md += f"| {quiz.timestamp.strftime('%Y-%m-%d')} | {quiz.score_percentage:.0f}% | {quiz.correct} | {quiz.wrong} | {quiz.skipped} |\n"
        else:
            md += "*You haven't completed any quizzes.*\n"
        
        md += """
---

##  Assignment Results (Autograder)

"""
        if student.autograder_results:
            md += f"""- **Average score**: {student.average_homework_score:.1f}%

### Assignment History

| Date | Score | Grade | Security Issues |
|------|-------|-------|-----------------|
"""
            for ag in student.autograder_results[-10:]:
                sec_issues = len(ag.security_issues)
                sec_badge = f"⚠️ {sec_issues}" if sec_issues else "✅ 0"
                md += f"| {ag.timestamp.strftime('%Y-%m-%d')} | {ag.percentage:.0f}% | {ag.grade} | {sec_badge} |\n"
        else:
            md += "*You haven't submitted any graded assignments.*\n"
        
        md += """
---

##  Performance by Category

"""
        strengths = student.category_strengths
        for cat_id, score in sorted(strengths.items(), key=lambda x: -x[1]):
            cat = CATEGORIES.get(cat_id, {})
            emoji = cat.get('emoji', '📋')
            name = cat.get('name', cat_id)
            
            if score >= 70:
                status = "🟢"
            elif score >= 50:
                status = "🟡"
            else:
                status = "🔴"
            
            md += f"- {emoji} **{name}**: {score:.0f}% {status}\n"
        
        strongest = student.strongest_category
        weakest = student.weakest_category
        
        if strongest:
            md += f"\n**Strength**: {CATEGORIES[strongest]['emoji']} {CATEGORIES[strongest]['name']}\n"
        if weakest:
            md += f"**To improve**: {CATEGORIES[weakest]['emoji']} {CATEGORIES[weakest]['name']}\n"
        
        md += """
---

##  Personalised Suggestions

"""
        suggestions = DataAnalyser.get_improvement_suggestions(student)
        for suggestion in suggestions:
            md += f"- {suggestion}\n"
        
        md += f"""
---

*Report automatically generated by Report Generator SEM03 v{VERSION}*
"""
        
        return md
    
    def generate_student_report_html(self, student: StudentProgress) -> str:
        """Generate report for a student in HTML format."""
        final_score, grade = student.calculate_final_grade()
        
        # Generate chart data
        quiz_dates = [q.timestamp.strftime('%Y-%m-%d') for q in student.quiz_results[-10:]]
        quiz_scores = [q.score_percentage for q in student.quiz_results[-10:]]
        
        strengths = student.category_strengths
        cat_labels = [CATEGORIES[c]['name'] for c in strengths]
        cat_scores = list(strengths.values())
        
        suggestions = DataAnalyser.get_improvement_suggestions(student)
        
        grade_color = '#27ae60' if int(grade) >= 5 else '#e74c3c'
        
        return f'''<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Progress Report - {student.name}</title>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        * {{ box-sizing: border-box; margin: 0; padding: 0; }}
        body {{ 
            font-family: 'Segoe UI', Tahoma, sans-serif;
            background: #f5f6fa;
            color: #2d3436;
            line-height: 1.6;
        }}
        .container {{ max-width: 1000px; margin: 0 auto; padding: 20px; }}
        .header {{
            background: linear-gradient(135deg, #667eea, #764ba2);
            color: white;
            padding: 40px;
            border-radius: 15px;
            margin-bottom: 30px;
            text-align: center;
        }}
        .header h1 {{ font-size: 2em; margin-bottom: 10px; }}
        .grade-badge {{
            display: inline-block;
            font-size: 3em;
            font-weight: bold;
            background: white;
            color: {grade_color};
            width: 100px;
            height: 100px;
            line-height: 100px;
            border-radius: 50%;
            margin: 20px 0;
        }}
        .cards {{ display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 20px; }}
        .card {{
            background: white;
            border-radius: 15px;
            padding: 25px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }}
        .card h2 {{ color: #667eea; margin-bottom: 15px; font-size: 1.3em; }}
        .stat {{ display: flex; justify-content: space-between; padding: 10px 0; border-bottom: 1px solid #eee; }}
        .stat:last-child {{ border-bottom: none; }}
        .stat-value {{ font-weight: bold; color: #667eea; }}
        .chart-container {{ height: 300px; }}
        .category-bar {{
            display: flex;
            align-items: center;
            margin: 10px 0;
        }}
        .category-name {{ width: 140px; font-size: 0.9em; }}
        .category-progress {{
            flex: 1;
            height: 20px;
            background: #eee;
            border-radius: 10px;
            overflow: hidden;
        }}
        .category-fill {{
            height: 100%;
            border-radius: 10px;
            transition: width 0.5s;
        }}
        .category-value {{ width: 50px; text-align: right; font-weight: bold; }}
        .suggestion {{
            padding: 15px;
            background: #f8f9fa;
            border-left: 4px solid #667eea;
            margin: 10px 0;
            border-radius: 0 8px 8px 0;
        }}
        .footer {{ text-align: center; padding: 20px; color: #95a5a6; font-size: 0.9em; }}
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>📊 Progress Report</h1>
            <p>{student.name}</p>
            <div class="grade-badge">{grade}</div>
            <p>Estimated final grade • Score: {final_score:.1f}%</p>
        </div>
        
        <div class="cards">
            <div class="card">
                <h2>🎯 Quiz Statistics</h2>
                <div class="stat"><span>Quizzes completed</span><span class="stat-value">{len(student.quiz_results)}</span></div>
                <div class="stat"><span>Average score</span><span class="stat-value">{student.average_quiz_score:.1f}%</span></div>
                <div class="stat"><span>Best score</span><span class="stat-value">{student.best_quiz_score:.1f}%</span></div>
            </div>
            
            <div class="card">
                <h2>📚 Assignment Statistics</h2>
                <div class="stat"><span>Assignments submitted</span><span class="stat-value">{len(student.autograder_results)}</span></div>
                <div class="stat"><span>Average score</span><span class="stat-value">{student.average_homework_score:.1f}%</span></div>
            </div>
        </div>
        
        <div class="card" style="margin-top: 20px;">
            <h2>📈 Quiz Progress</h2>
            <div class="chart-container">
                <canvas id="progressChart"></canvas>
            </div>
        </div>
        
        <div class="card" style="margin-top: 20px;">
            <h2>📊 Performance by Category</h2>
            {''.join(f"""
            <div class="category-bar">
                <span class="category-name">{CATEGORIES[cat]["emoji"]} {CATEGORIES[cat]["name"]}</span>
                <div class="category-progress">
                    <div class="category-fill" style="width: {score}%; background: {'#27ae60' if score >= 70 else '#f39c12' if score >= 50 else '#e74c3c'};"></div>
                </div>
                <span class="category-value">{score:.0f}%</span>
            </div>
            """ for cat, score in strengths.items())}
        </div>
        
        <div class="card" style="margin-top: 20px;">
            <h2>💡 Personalised Suggestions</h2>
            {''.join(f'<div class="suggestion">{s}</div>' for s in suggestions)}
        </div>
        
        <div class="footer">
            Generated: {datetime.now().strftime('%Y-%m-%d %H:%M')} • Report Generator SEM03 v{VERSION}
        </div>
    </div>
    
    <script>
        new Chart(document.getElementById('progressChart'), {{
            type: 'line',
            data: {{
                labels: {json.dumps(quiz_dates)},
                datasets: [{{
                    label: 'Quiz Score (%)',
                    data: {json.dumps(quiz_scores)},
                    borderColor: '#667eea',
                    backgroundColor: 'rgba(102, 126, 234, 0.1)',
                    fill: true,
                    tension: 0.4
                }}]
            }},
            options: {{
                responsive: true,
                maintainAspectRatio: false,
                plugins: {{ legend: {{ display: false }} }},
                scales: {{
                    y: {{ min: 0, max: 100 }}
                }}
            }}
        }});
    </script>
</body>
</html>'''
    
    # ───────────────────────────────────────────────────────────────────────────
    # CLASS REPORTS
    # ───────────────────────────────────────────────────────────────────────────
    
    def generate_class_report_console(self, students: List[StudentProgress]) -> str:
        """Generate report for a class in console format."""
        stats = DataAnalyser.analyse_class(students)
        lines = []
        
        lines.append("═" * 70)
        lines.append(color("  📊 CLASS REPORT - SEMINAR 5-6", Colours.BOLD + Colours.CYAN, self.use_color))
        lines.append(f"  Generated: {datetime.now().strftime('%Y-%m-%d %H:%M')}")
        lines.append("═" * 70)
        
        # General statistics
        lines.append(color("\n  📈 GENERAL STATISTICS", Colours.YELLOW, self.use_color))
        lines.append("  " + "─" * 40)
        lines.append(f"  Total students:        {stats.total_students}")
        lines.append(f"  With submissions:      {stats.students_with_submissions}")
        lines.append(f"  Class average:         {stats.average_score:.1f}%")
        lines.append(f"  Median:                {stats.median_score:.1f}%")
        lines.append(f"  Standard deviation:    {stats.std_deviation:.1f}%")
        lines.append(f"  Minimum score:         {stats.min_score:.1f}%")
        lines.append(f"  Maximum score:         {stats.max_score:.1f}%")
        
        # Grade distribution
        lines.append(color("\n  📊 GRADE DISTRIBUTION", Colours.YELLOW, self.use_color))
        lines.append("  " + "─" * 40)
        for grade in ['10', '9', '8', '7', '6', '5', '4']:
            count = stats.grade_distribution.get(grade, 0)
            bar = "█" * count
            lines.append(f"  Grade {grade}: {bar} ({count})")
        
        # Category averages
        lines.append(color("\n  📚 AVERAGES BY CATEGORY", Colours.YELLOW, self.use_color))
        lines.append("  " + "─" * 40)
        for cat_id, avg in sorted(stats.category_averages.items(), key=lambda x: -x[1]):
            cat = CATEGORIES.get(cat_id, {})
            emoji = cat.get('emoji', '📋')
            name = cat.get('name', cat_id)
            bar_len = int(avg / 5)
            bar = "█" * bar_len + "░" * (20 - bar_len)
            lines.append(f"  {emoji} {name:20} [{bar}] {avg:.0f}%")
        
        # Top 5 students
        lines.append(color("\n  🏆 TOP 5 STUDENTS", Colours.YELLOW, self.use_color))
        lines.append("  " + "─" * 40)
        top = DataAnalyser.identify_top_performers(students, 5)
        for i, s in enumerate(top, 1):
            score, grade = s.calculate_final_grade()
            lines.append(f"  {i}. {s.name:20} - {score:.1f}% (grade {grade})")
        
        # Students with difficulties
        struggling = DataAnalyser.identify_struggling_students(students)
        if struggling:
            lines.append(color("\n  ⚠️  STUDENTS WITH DIFFICULTIES", Colours.RED, self.use_color))
            lines.append("  " + "─" * 40)
            for s in struggling[:5]:
                score, _ = s.calculate_final_grade()
                weak = s.weakest_category
                weak_name = CATEGORIES.get(weak, {}).get('name', weak) if weak else 'N/A'
                lines.append(f"  • {s.name:20} - {score:.1f}% (weak at: {weak_name})")
        
        # Security issues
        if stats.security_issues_count > 0:
            lines.append(color(f"\n  🔒 SECURITY ISSUES: {stats.security_issues_count} total", 
                              Colours.RED, self.use_color))
        
        # Common mistakes
        if stats.common_mistakes:
            lines.append(color("\n  ❌ COMMON QUIZ MISTAKES", Colours.YELLOW, self.use_color))
            lines.append("  " + "─" * 40)
            for q_id, count in stats.common_mistakes[:5]:
                lines.append(f"  • Question {q_id}: {count} mistakes")
        
        lines.append("\n" + "═" * 70)
        
        return '\n'.join(lines)
    
    def generate_class_report_markdown(self, students: List[StudentProgress]) -> str:
        """Generate report for a class in Markdown format."""
        stats = DataAnalyser.analyse_class(students)
        
        md = f"""# 📊 Class Report - Seminar 3

**Generated**: {datetime.now().strftime('%Y-%m-%d %H:%M')}

---

##  General Statistics

| Metric | Value |
|--------|-------|
| Total students | {stats.total_students} |
| With submissions | {stats.students_with_submissions} |
| Class average | {stats.average_score:.1f}% |
| Median | {stats.median_score:.1f}% |
| Standard deviation | {stats.std_deviation:.1f}% |
| Minimum score | {stats.min_score:.1f}% |
| Maximum score | {stats.max_score:.1f}% |

---

##  Grade Distribution

| Grade | Students | Percentage |
|-------|----------|------------|
"""
        total = stats.total_students or 1
        for grade in ['10', '9', '8', '7', '6', '5', '4']:
            count = stats.grade_distribution.get(grade, 0)
            pct = count / total * 100
            md += f"| {grade} | {count} | {pct:.1f}% |\n"
        
        md += """
---

##  Averages by Category

"""
        for cat_id, avg in sorted(stats.category_averages.items(), key=lambda x: -x[1]):
            cat = CATEGORIES.get(cat_id, {})
            emoji = cat.get('emoji', '📋')
            name = cat.get('name', cat_id)
            if avg >= 70:
                status = "🟢"
            elif avg >= 50:
                status = "🟡"
            else:
                status = "🔴"
            md += f"- {emoji} **{name}**: {avg:.0f}% {status}\n"
        
        md += """
---

##  Top 5 Students

| Rank | Student | Score | Grade |
|------|---------|-------|-------|
"""
        top = DataAnalyser.identify_top_performers(students, 5)
        for i, s in enumerate(top, 1):
            score, grade = s.calculate_final_grade()
            md += f"| {i} | {s.name} | {score:.1f}% | {grade} |\n"
        
        struggling = DataAnalyser.identify_struggling_students(students)
        if struggling:
            md += """
---

##  Students with Difficulties

| Student | Score | Weak Category |
|---------|-------|---------------|
"""
            for s in struggling[:10]:
                score, _ = s.calculate_final_grade()
                weak = s.weakest_category
                weak_name = CATEGORIES.get(weak, {}).get('name', weak) if weak else 'N/A'
                md += f"| {s.name} | {score:.1f}% | {weak_name} |\n"
        
        if stats.common_mistakes:
            md += """
---

##  Common Mistakes

"""
            for q_id, count in stats.common_mistakes[:10]:
                md += f"- **{q_id}**: {count} mistakes\n"
        
        md += f"""
---

*Report automatically generated by Report Generator SEM03 v{VERSION}*
"""
        
        return md

# ═══════════════════════════════════════════════════════════════════════════════
# SYNTHETIC DATA GENERATOR (FOR TESTING)
# ═══════════════════════════════════════════════════════════════════════════════

class SyntheticDataGenerator:
    """Generates synthetic data for testing."""
    
    @staticmethod
    def generate_student(student_id: str, name: str, 
                        skill_level: float = 0.7) -> StudentProgress:
        """Generate a student with synthetic data."""
        import random
        
        student = StudentProgress(
            student_id=student_id,
            name=name
        )
        
        # Generate quizzes
        num_quizzes = random.randint(2, 5)
        for i in range(num_quizzes):
            score = min(100, max(0, skill_level * 100 + random.gauss(0, 15)))
            total = random.randint(10, 15)
            correct = int(total * score / 100)
            wrong = total - correct - random.randint(0, 2)
            skipped = total - correct - wrong
            
            categories = {}
            for cat in CATEGORIES:
                cat_correct = random.randint(1, 4)
                cat_wrong = random.randint(0, 2)
                categories[cat] = {
                    'correct': cat_correct,
                    'wrong': cat_wrong,
                    'skipped': max(0, 4 - cat_correct - cat_wrong)
                }
            
            quiz = QuizResult(
                quiz_id=f"quiz_{student_id}_{i}",
                timestamp=datetime.now(),
                score_percentage=score,
                correct=correct,
                wrong=wrong,
                skipped=skipped,
                time_seconds=random.randint(300, 900),
                categories_breakdown=categories
            )
            student.quiz_results.append(quiz)
        
        # Generate autograder results
        num_hw = random.randint(1, 3)
        for i in range(num_hw):
            score = min(100, max(0, skill_level * 100 + random.gauss(0, 20)))
            
            ag = AutograderResult(
                submission_id=f"hw_{student_id}_{i}",
                timestamp=datetime.now(),
                total_points=score,
                max_points=100,
                percentage=score,
                grade=str(min(10, max(4, int(score / 10) + 1))),
                categories={},
                security_issues=[] if random.random() > 0.2 else ['chmod 777 detected']
            )
            student.autograder_results.append(ag)
        
        return student
    
    @staticmethod
    def generate_class(num_students: int = 30) -> List[StudentProgress]:
        """Generate a complete class."""
        import random
        
        names = [
            "Popescu Ion", "Ionescu Maria", "Popa Andrei", "Dumitrescu Elena",
            "Stan Alexandru", "Gheorghe Ana", "Stoica Mihai", "Dinu Cristina",
            "Marin Daniel", "Tudor Ioana", "Rus Adrian", "Moldovan Andreea",
            "Nistor Vlad", "Lazăr Raluca", "Neagu Bogdan", "Radu Laura",
            "Barbu Cătălin", "Constantin Diana", "Matei Florin", "Ciobanu Alina",
            "Florea Razvan", "Preda Simona", "Enache Sorin", "Voicu Bianca",
            "Petre Gabriel", "Toma Anca", "Cojocaru Marius", "Drăghici Oana",
            "Iordache Robert", "Costache Monica"
        ]
        
        students = []
        for i in range(num_students):
            name = names[i % len(names)]
            if i >= len(names):
                name += f" {i // len(names) + 1}"
            
            # Variable skill level
            skill = random.gauss(0.65, 0.15)
            skill = min(0.95, max(0.25, skill))
            
            student = SyntheticDataGenerator.generate_student(
                f"student_{i+1:03d}",
                name,
                skill
            )
            students.append(student)
        
        return students

# ═══════════════════════════════════════════════════════════════════════════════
# COMMAND LINE INTERFACE
# ═══════════════════════════════════════════════════════════════════════════════

def main():
    """Main function."""
    parser = argparse.ArgumentParser(
        description='Report Generator for Seminar 03 OS',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog='''
Examples:
  %(prog)s --student results_dir/student1           # Individual report
  %(prog)s --class submissions/                     # Class report
  %(prog)s --student results/ -o report.html        # Export to HTML
  %(prog)s --demo                                   # Demo with synthetic data
        '''
    )
    
    parser.add_argument('--student', '-s', metavar='DIR',
                       help='Generate report for a student (directory with results)')
    parser.add_argument('--class', '-c', dest='class_dir', metavar='DIR',
                       help='Generate report for a class (directory with student subdirectories)')
    parser.add_argument('--output', '-o', metavar='FILE',
                       help='Output file (format detected from extension)')
    parser.add_argument('--format', '-f', choices=['console', 'markdown', 'html'],
                       default='console', help='Output format (default: console)')
    parser.add_argument('--name', metavar='NAME',
                       help='Student name (for individual reports)')
    parser.add_argument('--demo', action='store_true',
                       help='Run demo with synthetic data')
    parser.add_argument('--no-color', action='store_true',
                       help='Disable colours in console output')
    parser.add_argument('--version', '-v', action='version',
                       version=f'{PROGRAM_NAME} v{VERSION}')
    
    args = parser.parse_args()
    use_color = not args.no_color
    
    generator = ReportGenerator(use_color)
    
    # Demo with synthetic data
    if args.demo:
        print(color("🧪 Generating synthetic data for demo...\n", Colours.CYAN, use_color))
        
        # Generate synthetic class
        students = SyntheticDataGenerator.generate_class(25)
        
        # Class report
        if args.format == 'console':
            print(generator.generate_class_report_console(students))
        elif args.format == 'markdown':
            report = generator.generate_class_report_markdown(students)
            if args.output:
                with open(args.output, 'w', encoding='utf-8') as f:
                    f.write(report)
                print(f"✅ Report saved to {args.output}")
            else:
                print(report)
        
        # Individual report example
        print("\n" + "═" * 70)
        print(color("\n📄 Individual report example:\n", Colours.YELLOW, use_color))
        sample_student = students[0]
        
        if args.format == 'html' and args.output:
            report = generator.generate_student_report_html(sample_student)
            with open(args.output, 'w', encoding='utf-8') as f:
                f.write(report)
            print(f"✅ HTML report saved to {args.output}")
        else:
            print(generator.generate_student_report_console(sample_student))
        
        return 0
    
    # Individual student report
    if args.student:
        if not os.path.isdir(args.student):
            print(f"❌ Directory does not exist: {args.student}")
            return 1
        
        student_id = os.path.basename(args.student.rstrip('/'))
        name = args.name or student_id
        
        student = DataLoader.load_student_progress(args.student, student_id, name)
        
        if not student.quiz_results and not student.autograder_results:
            print(f"⚠️  No data found for student {name}")
            return 1
        
        # Determine format from extension if output is specified
        fmt = args.format
        if args.output:
            ext = os.path.splitext(args.output)[1].lower()
            if ext == '.html':
                fmt = 'html'
            elif ext == '.md':
                fmt = 'markdown'
        
        # Generate report
        if fmt == 'html':
            report = generator.generate_student_report_html(student)
        elif fmt == 'markdown':
            report = generator.generate_student_report_markdown(student)
        else:
            report = generator.generate_student_report_console(student)
        
        if args.output:
            with open(args.output, 'w', encoding='utf-8') as f:
                f.write(report)
            print(f"✅ Report saved to {args.output}")
        else:
            print(report)
        
        return 0
    
    # Class report
    if args.class_dir:
        if not os.path.isdir(args.class_dir):
            print(f"❌ Directory does not exist: {args.class_dir}")
            return 1
        
        students = DataLoader.load_class_data(args.class_dir)
        
        if not students:
            print(f"⚠️  No students found in {args.class_dir}")
            return 1
        
        print(f"📊 Loaded data for {len(students)} students")
        
        # Determine format
        fmt = args.format
        if args.output:
            ext = os.path.splitext(args.output)[1].lower()
            if ext == '.md':
                fmt = 'markdown'
        
        # Generate report
        if fmt == 'markdown':
            report = generator.generate_class_report_markdown(students)
        else:
            report = generator.generate_class_report_console(students)
        
        if args.output:
            with open(args.output, 'w', encoding='utf-8') as f:
                f.write(report)
            print(f"✅ Report saved to {args.output}")
        else:
            print(report)
        
        return 0
    
    # No arguments - display help
    parser.print_help()
    return 0

if __name__ == '__main__':
    sys.exit(main())
