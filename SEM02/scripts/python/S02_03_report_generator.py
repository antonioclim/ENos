#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
═══════════════════════════════════════════════════════════════════════════════
📊 S02_03_report_generator.py - Report and Statistics Generator
═══════════════════════════════════════════════════════════════════════════════

DESCRIPTION:
    Aggregates evaluation results (autograder) and generates reports:
    - Statistics per group and per student
    - Common problem identification
    - Interactive HTML reports with charts
    - CSV export for import into Excel/Moodle

USAGE:
    python3 S02_03_report_generator.py --input ./results/ --output ./reports/
    python3 S02_03_report_generator.py --input results.json --format html
    python3 S02_03_report_generator.py --input ./results/ --compare week1 week2

AUTHOR: Assistant for Bucharest UES - CSIE
VERSION: 1.0
DATE: January 2025
═══════════════════════════════════════════════════════════════════════════════
"""

import argparse
import json
import os
import sys
import csv
from dataclasses import dataclass, field, asdict
from typing import List, Dict, Optional, Tuple, Any
from datetime import datetime
from pathlib import Path
from collections import defaultdict
import statistics
import html

# 
# SECTION 1: DATA STRUCTURES
# 

@dataclass
class StudentResult:
    """Result of a student's evaluation."""
    student_name: str
    student_group: str
    score: float
    max_score: float
    grade: str
    timestamp: str
    categories: Dict[str, float] = field(default_factory=dict)
    issues: List[str] = field(default_factory=list)
    file_path: Optional[str] = None
    
    @property
    def percentage(self) -> float:
        return (self.score / self.max_score * 100) if self.max_score > 0 else 0

@dataclass
class GroupStatistics:
    """Statistics for a group."""
    group_name: str
    student_count: int
    scores: List[float]
    grades: Dict[str, int]
    common_issues: Dict[str, int]
    category_averages: Dict[str, float]
    
    @property
    def mean(self) -> float:
        return statistics.mean(self.scores) if self.scores else 0
    
    @property
    def median(self) -> float:
        return statistics.median(self.scores) if self.scores else 0
    
    @property
    def std_dev(self) -> float:
        return statistics.stdev(self.scores) if len(self.scores) > 1 else 0
    
    @property
    def min_score(self) -> float:
        return min(self.scores) if self.scores else 0
    
    @property
    def max_score(self) -> float:
        return max(self.scores) if self.scores else 0
    
    @property
    def pass_rate(self) -> float:
        passed = sum(1 for s in self.scores if s >= 50)
        return (passed / len(self.scores) * 100) if self.scores else 0

@dataclass 
class OverallReport:
    """Overall report for all groups."""
    generated_at: str
    total_students: int
    groups: Dict[str, GroupStatistics]
    all_results: List[StudentResult]
    grade_distribution: Dict[str, int]
    top_issues: List[Tuple[str, int]]
    category_performance: Dict[str, Dict[str, float]]

# 
# SECTION 2: LOADING RESULTS
# 

class ResultLoader:
    """Load results from various formats."""
    
    @staticmethod
    def load_json(filepath: str) -> StudentResult:
        """Load a result from JSON file."""
        with open(filepath, 'r', encoding='utf-8') as f:
            data = json.load(f)
        
        return StudentResult(
            student_name=data.get('student_name', 'Unknown'),
            student_group=data.get('student_group', 'Unknown'),
            score=data.get('score', 0),
            max_score=data.get('max_score', 100),
            grade=data.get('grade', 'F'),
            timestamp=data.get('timestamp', datetime.now().isoformat()),
            categories=data.get('categories', {}),
            issues=data.get('issues', []),
            file_path=filepath
        )
    
    @staticmethod
    def load_directory(dirpath: str) -> List[StudentResult]:
        """Load all results from a directory."""
        results = []
        dir_path = Path(dirpath)
        
        for json_file in dir_path.glob('**/*.json'):
            try:
                result = ResultLoader.load_json(str(json_file))
                results.append(result)
            except (json.JSONDecodeError, KeyError) as e:
                print(f"⚠️ Error reading {json_file}: {e}")
        
        return results
    
    @staticmethod
    def load_csv(filepath: str) -> List[StudentResult]:
        """Load results from a CSV."""
        results = []
        with open(filepath, 'r', encoding='utf-8', newline='') as f:
            reader = csv.DictReader(f)
            for row in reader:
                results.append(StudentResult(
                    student_name=row.get('student_name', row.get('name', 'Unknown')),
                    student_group=row.get('student_group', row.get('group', 'Unknown')),
                    score=float(row.get('score', 0)),
                    max_score=float(row.get('max_score', 100)),
                    grade=row.get('grade', 'F'),
                    timestamp=row.get('timestamp', datetime.now().isoformat()),
                    categories={},
                    issues=row.get('issues', '').split(';') if row.get('issues') else []
                ))
        return results

# 
# SECTION 3: STATISTICAL ANALYSIS
# 

class StatisticsAnalyzer:
    """Analyse results and generate statistics."""
    
    def __init__(self, results: List[StudentResult]):
        self.results = results
    
    def analyze_group(self, group_name: str) -> GroupStatistics:
        """Analyse a specific group."""
        group_results = [r for r in self.results if r.student_group == group_name]
        
        if not group_results:
            return GroupStatistics(
                group_name=group_name,
                student_count=0,
                scores=[],
                grades={},
                common_issues={},
                category_averages={}
            )
        
        scores = [r.percentage for r in group_results]
        
        # Count grades
        grades = defaultdict(int)
        for r in group_results:
            grades[r.grade] += 1
        
        # Common issues
        issues = defaultdict(int)
        for r in group_results:
            for issue in r.issues:
                issues[issue] += 1
        
        # Averages per category
        category_sums = defaultdict(list)
        for r in group_results:
            for cat, score in r.categories.items():
                category_sums[cat].append(score)
        
        category_averages = {
            cat: statistics.mean(scores) 
            for cat, scores in category_sums.items()
        }
        
        return GroupStatistics(
            group_name=group_name,
            student_count=len(group_results),
            scores=scores,
            grades=dict(grades),
            common_issues=dict(issues),
            category_averages=category_averages
        )
    
    def generate_overall_report(self) -> OverallReport:
        """Generate the complete report."""
        # Identify all groups
        groups = set(r.student_group for r in self.results)
        group_stats = {g: self.analyze_group(g) for g in sorted(groups)}
        
        # Global grade distribution
        grade_dist = defaultdict(int)
        for r in self.results:
            grade_dist[r.grade] += 1
        
        # Top issues
        all_issues = defaultdict(int)
        for r in self.results:
            for issue in r.issues:
                all_issues[issue] += 1
        
        top_issues = sorted(all_issues.items(), key=lambda x: x[1], reverse=True)[:10]
        
        # Global performance per category
        category_perf = defaultdict(lambda: {'scores': [], 'count': 0})
        for r in self.results:
            for cat, score in r.categories.items():
                category_perf[cat]['scores'].append(score)
                category_perf[cat]['count'] += 1
        
        category_performance = {
            cat: {
                'mean': statistics.mean(data['scores']) if data['scores'] else 0,
                'min': min(data['scores']) if data['scores'] else 0,
                'max': max(data['scores']) if data['scores'] else 0,
                'count': data['count']
            }
            for cat, data in category_perf.items()
        }
        
        return OverallReport(
            generated_at=datetime.now().isoformat(),
            total_students=len(self.results),
            groups=group_stats,
            all_results=self.results,
            grade_distribution=dict(grade_dist),
            top_issues=top_issues,
            category_performance=category_performance
        )

# 
# SECTION 4: REPORT EXPORTERS
# 

class ReportExporter:
    """Export reports in various formats."""
    
    @staticmethod
    def to_csv(report: OverallReport, filepath: str):
        """Export individual results to CSV."""
        with open(filepath, 'w', encoding='utf-8', newline='') as f:
            writer = csv.writer(f)
            
            # Header
            header = ['student_name', 'student_group', 'score', 'max_score', 
                     'percentage', 'grade', 'timestamp', 'issues']
            
            # Add columns for categories
            all_categories = set()
            for r in report.all_results:
                all_categories.update(r.categories.keys())
            all_categories = sorted(all_categories)
            header.extend(all_categories)
            
            writer.writerow(header)
            
            # Data
            for r in report.all_results:
                row = [
                    r.student_name,
                    r.student_group,
                    r.score,
                    r.max_score,
                    f"{r.percentage:.1f}",
                    r.grade,
                    r.timestamp,
                    ';'.join(r.issues)
                ]
                row.extend([r.categories.get(cat, '') for cat in all_categories])
                writer.writerow(row)
    
    @staticmethod
    def to_summary_txt(report: OverallReport) -> str:
        """Generate a text summary."""
        lines = []
        lines.append("=" * 70)
        lines.append("  SUMMARY REPORT - Seminar 3-4 Evaluation")
        lines.append("  Generated: " + report.generated_at[:19].replace('T', ' '))
        lines.append("=" * 70)
        lines.append("")
        
        # General statistics
        all_scores = [r.percentage for r in report.all_results]
        lines.append("📊 GENERAL STATISTICS")
        lines.append("-" * 40)
        lines.append(f"  Total students evaluated: {report.total_students}")
        lines.append(f"  Overall mean: {statistics.mean(all_scores):.1f}%")
        lines.append(f"  Median: {statistics.median(all_scores):.1f}%")
        if len(all_scores) > 1:
            lines.append(f"  Standard deviation: {statistics.stdev(all_scores):.1f}")
        lines.append(f"  Minimum score: {min(all_scores):.1f}%")
        lines.append(f"  Maximum score: {max(all_scores):.1f}%")
        lines.append("")
        
        # Grade distribution
        lines.append("📈 GRADE DISTRIBUTION")
        lines.append("-" * 40)
        grade_order = ['A', 'B', 'C', 'D', 'E', 'F']
        for grade in grade_order:
            count = report.grade_distribution.get(grade, 0)
            pct = count / report.total_students * 100 if report.total_students > 0 else 0
            bar = '█' * int(pct / 2)
            lines.append(f"  {grade}: {count:3d} ({pct:5.1f}%) {bar}")
        lines.append("")
        
        # Pass rate
        passed = sum(report.grade_distribution.get(g, 0) for g in ['A', 'B', 'C', 'D', 'E'])
        pass_rate = passed / report.total_students * 100 if report.total_students > 0 else 0
        lines.append(f"  Pass rate (≥50%): {pass_rate:.1f}%")
        lines.append("")
        
        # Statistics per group
        lines.append("👥 STATISTICS PER GROUP")
        lines.append("-" * 40)
        lines.append(f"  {'Group':<10} {'N':>5} {'Mean':>8} {'Med.':>8} {'Min':>6} {'Max':>6} {'Pass%':>8}")
        lines.append("  " + "-" * 55)
        
        for group_name, stats in sorted(report.groups.items()):
            lines.append(f"  {group_name:<10} {stats.student_count:>5} "
                        f"{stats.mean:>7.1f}% {stats.median:>7.1f}% "
                        f"{stats.min_score:>5.1f}% {stats.max_score:>5.1f}% "
                        f"{stats.pass_rate:>7.1f}%")
        lines.append("")
        
        # Performance per category
        if report.category_performance:
            lines.append("📚 PERFORMANCE PER CATEGORY")
            lines.append("-" * 40)
            for cat, data in sorted(report.category_performance.items()):
                lines.append(f"  {cat:<20} Mean: {data['mean']:>5.1f}%  "
                            f"(Min: {data['min']:.0f}% - Max: {data['max']:.0f}%)")
            lines.append("")
        
        # Top issues
        if report.top_issues:
            lines.append("⚠️ COMMON ISSUES")
            lines.append("-" * 40)
            for i, (issue, count) in enumerate(report.top_issues[:10], 1):
                pct = count / report.total_students * 100
                lines.append(f"  {i:2}. [{pct:5.1f}%] {issue}")
            lines.append("")
        
        lines.append("=" * 70)
        
        return "\n".join(lines)
    
    @staticmethod
    def to_html(report: OverallReport) -> str:
        """Generate an interactive HTML report with charts."""
        
        # Prepare data for charts
        all_scores = [r.percentage for r in report.all_results]
        
        # Data for histogram
        bins = [0, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100]
        hist_data = [0] * (len(bins) - 1)
        for score in all_scores:
            for i in range(len(bins) - 1):
                if bins[i] <= score < bins[i + 1] or (i == len(bins) - 2 and score == 100):
                    hist_data[i] += 1
                    break
        
        # Data for grade pie chart
        grade_colors = {
            'A': '#28a745', 'B': '#5cb85c', 'C': '#f0ad4e',
            'D': '#ec971f', 'E': '#d9534f', 'F': '#c9302c'
        }
        
        # JSON for JavaScript
        grade_dist_json = json.dumps(report.grade_distribution)
        hist_json = json.dumps(hist_data)
        bins_json = json.dumps([f"{bins[i]}-{bins[i+1]}" for i in range(len(bins)-1)])
        
        # Data per group for bar chart
        group_data = {
            'labels': [],
            'means': [],
            'pass_rates': []
        }
        for name, stats in sorted(report.groups.items()):
            group_data['labels'].append(name)
            group_data['means'].append(round(stats.mean, 1))
            group_data['pass_rates'].append(round(stats.pass_rate, 1))
        
        group_json = json.dumps(group_data)
        
        # Data per category
        cat_data = {
            'labels': [],
            'means': []
        }
        for cat, data in sorted(report.category_performance.items()):
            cat_data['labels'].append(cat)
            cat_data['means'].append(round(data['mean'], 1))
        cat_json = json.dumps(cat_data)
        
        html_content = f"""<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Evaluation Report - Seminar 3-4</title>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        * {{ box-sizing: border-box; margin: 0; padding: 0; }}
        body {{
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            line-height: 1.6;
            background: #f0f2f5;
            color: #333;
        }}
        .container {{
            max-width: 1400px;
            margin: 0 auto;
            padding: 20px;
        }}
        .header {{
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 30px;
            border-radius: 15px;
            margin-bottom: 30px;
            box-shadow: 0 4px 20px rgba(0,0,0,0.15);
        }}
        .header h1 {{ font-size: 2em; margin-bottom: 10px; }}
        .header .meta {{
            display: flex;
            gap: 30px;
            flex-wrap: wrap;
            font-size: 0.95em;
            opacity: 0.9;
        }}
        .stats-grid {{
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }}
        .stat-card {{
            background: white;
            padding: 25px;
            border-radius: 12px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.08);
            text-align: center;
        }}
        .stat-card .value {{
            font-size: 2.5em;
            font-weight: bold;
            color: #667eea;
        }}
        .stat-card .label {{
            color: #666;
            font-size: 0.9em;
            margin-top: 5px;
        }}
        .charts-grid {{
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(500px, 1fr));
            gap: 25px;
            margin-bottom: 30px;
        }}
        .chart-container {{
            background: white;
            padding: 25px;
            border-radius: 12px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.08);
        }}
        .chart-container h3 {{
            color: #333;
            margin-bottom: 20px;
            padding-bottom: 10px;
            border-bottom: 2px solid #667eea;
        }}
        .chart-wrapper {{
            position: relative;
            height: 300px;
        }}
        table {{
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }}
        th, td {{
            padding: 12px 15px;
            text-align: left;
            border-bottom: 1px solid #eee;
        }}
        th {{
            background: #667eea;
            color: white;
            font-weight: 600;
        }}
        tr:hover {{ background: #f8f9ff; }}
        .grade {{
            display: inline-block;
            padding: 3px 12px;
            border-radius: 15px;
            font-weight: bold;
            font-size: 0.85em;
        }}
        .grade-A {{ background: #d4edda; color: #155724; }}
        .grade-B {{ background: #d4edda; color: #155724; }}
        .grade-C {{ background: #fff3cd; color: #856404; }}
        .grade-D {{ background: #fff3cd; color: #856404; }}
        .grade-E {{ background: #f8d7da; color: #721c24; }}
        .grade-F {{ background: #f8d7da; color: #721c24; }}
        .issues-list {{
            background: white;
            padding: 25px;
            border-radius: 12px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.08);
            margin-bottom: 30px;
        }}
        .issues-list h3 {{
            color: #333;
            margin-bottom: 20px;
            padding-bottom: 10px;
            border-bottom: 2px solid #e74c3c;
        }}
        .issue-item {{
            display: flex;
            justify-content: space-between;
            padding: 10px 0;
            border-bottom: 1px solid #eee;
        }}
        .issue-item:last-child {{ border-bottom: none; }}
        .issue-count {{
            background: #e74c3c;
            color: white;
            padding: 2px 10px;
            border-radius: 10px;
            font-size: 0.85em;
        }}
        .progress-bar {{
            height: 8px;
            background: #eee;
            border-radius: 4px;
            overflow: hidden;
            margin-top: 5px;
        }}
        .progress-fill {{
            height: 100%;
            background: linear-gradient(90deg, #667eea, #764ba2);
            border-radius: 4px;
        }}
        .section {{
            background: white;
            padding: 25px;
            border-radius: 12px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.08);
            margin-bottom: 30px;
        }}
        .section h3 {{
            color: #333;
            margin-bottom: 20px;
            padding-bottom: 10px;
            border-bottom: 2px solid #667eea;
        }}
        .search-box {{
            padding: 10px 15px;
            border: 2px solid #ddd;
            border-radius: 8px;
            width: 100%;
            max-width: 400px;
            margin-bottom: 20px;
            font-size: 1em;
        }}
        .search-box:focus {{
            outline: none;
            border-color: #667eea;
        }}
        @media (max-width: 768px) {{
            .charts-grid {{ grid-template-columns: 1fr; }}
            .chart-wrapper {{ height: 250px; }}
        }}
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>📊 Evaluation Report - Seminar 3-4</h1>
            <div class="meta">
                <span>📅 Generated: {report.generated_at[:19].replace('T', ' ')}</span>
                <span>👥 Total students: {report.total_students}</span>
                <span>📚 Groups evaluated: {len(report.groups)}</span>
            </div>
        </div>
        
        <div class="stats-grid">
            <div class="stat-card">
                <div class="value">{report.total_students}</div>
                <div class="label">Students Evaluated</div>
            </div>
            <div class="stat-card">
                <div class="value">{statistics.mean(all_scores):.1f}%</div>
                <div class="label">Overall Mean</div>
            </div>
            <div class="stat-card">
                <div class="value">{statistics.median(all_scores):.1f}%</div>
                <div class="label">Median</div>
            </div>
            <div class="stat-card">
                <div class="value">{sum(1 for s in all_scores if s >= 50) / len(all_scores) * 100:.0f}%</div>
                <div class="label">Pass Rate</div>
            </div>
        </div>
        
        <div class="charts-grid">
            <div class="chart-container">
                <h3>📈 Grade Distribution</h3>
                <div class="chart-wrapper">
                    <canvas id="gradeChart"></canvas>
                </div>
            </div>
            <div class="chart-container">
                <h3>📊 Score Histogram</h3>
                <div class="chart-wrapper">
                    <canvas id="histChart"></canvas>
                </div>
            </div>
            <div class="chart-container">
                <h3>👥 Group Comparison</h3>
                <div class="chart-wrapper">
                    <canvas id="groupChart"></canvas>
                </div>
            </div>
            <div class="chart-container">
                <h3>📚 Performance by Category</h3>
                <div class="chart-wrapper">
                    <canvas id="categoryChart"></canvas>
                </div>
            </div>
        </div>
        
        <div class="issues-list">
            <h3>⚠️ Common Issues</h3>
"""
        
        for issue, count in report.top_issues[:10]:
            pct = count / report.total_students * 100
            html_content += f"""            <div class="issue-item">
                <span>{html.escape(issue)}</span>
                <span class="issue-count">{count} ({pct:.0f}%)</span>
            </div>
"""
        
        html_content += """        </div>
        
        <div class="section">
            <h3>👥 Statistics per Group</h3>
            <table>
                <tr>
                    <th>Group</th>
                    <th>Students</th>
                    <th>Mean</th>
                    <th>Median</th>
                    <th>Min</th>
                    <th>Max</th>
                    <th>Pass Rate</th>
                </tr>
"""
        
        for name, stats in sorted(report.groups.items()):
            html_content += f"""                <tr>
                    <td><strong>{html.escape(name)}</strong></td>
                    <td>{stats.student_count}</td>
                    <td>{stats.mean:.1f}%</td>
                    <td>{stats.median:.1f}%</td>
                    <td>{stats.min_score:.1f}%</td>
                    <td>{stats.max_score:.1f}%</td>
                    <td>
                        {stats.pass_rate:.0f}%
                        <div class="progress-bar">
                            <div class="progress-fill" style="width: {stats.pass_rate}%"></div>
                        </div>
                    </td>
                </tr>
"""
        
        html_content += """            </table>
        </div>
        
        <div class="section">
            <h3>📋 Individual Results</h3>
            <input type="text" class="search-box" id="searchBox" 
                   placeholder="Search student or group..." onkeyup="filterTable()">
            <table id="resultsTable">
                <tr>
                    <th>Student</th>
                    <th>Group</th>
                    <th>Score</th>
                    <th>Grade</th>
                    <th>Issues</th>
                </tr>
"""
        
        for r in sorted(report.all_results, key=lambda x: (-x.percentage, x.student_name)):
            issues_str = ', '.join(r.issues[:3]) + ('...' if len(r.issues) > 3 else '')
            html_content += f"""                <tr>
                    <td>{html.escape(r.student_name)}</td>
                    <td>{html.escape(r.student_group)}</td>
                    <td>{r.percentage:.1f}%</td>
                    <td><span class="grade grade-{r.grade}">{r.grade}</span></td>
                    <td>{html.escape(issues_str)}</td>
                </tr>
"""
        
        html_content += f"""            </table>
        </div>
    </div>
    
    <script>
        // Grade distribution - Pie Chart
        const gradeData = {grade_dist_json};
        const gradeColors = {{
            'A': '#28a745', 'B': '#5cb85c', 'C': '#f0ad4e',
            'D': '#ec971f', 'E': '#d9534f', 'F': '#c9302c'
        }};
        
        new Chart(document.getElementById('gradeChart'), {{
            type: 'doughnut',
            data: {{
                labels: Object.keys(gradeData),
                datasets: [{{
                    data: Object.values(gradeData),
                    backgroundColor: Object.keys(gradeData).map(g => gradeColors[g] || '#999')
                }}]
            }},
            options: {{
                responsive: true,
                maintainAspectRatio: false,
                plugins: {{
                    legend: {{ position: 'right' }}
                }}
            }}
        }});
        
        // Score histogram
        new Chart(document.getElementById('histChart'), {{
            type: 'bar',
            data: {{
                labels: {bins_json},
                datasets: [{{
                    label: 'Students',
                    data: {hist_json},
                    backgroundColor: 'rgba(102, 126, 234, 0.7)',
                    borderColor: '#667eea',
                    borderWidth: 1
                }}]
            }},
            options: {{
                responsive: true,
                maintainAspectRatio: false,
                scales: {{
                    y: {{ beginAtZero: true }}
                }}
            }}
        }});
        
        // Group comparison
        const groupData = {group_json};
        new Chart(document.getElementById('groupChart'), {{
            type: 'bar',
            data: {{
                labels: groupData.labels,
                datasets: [
                    {{
                        label: 'Mean (%)',
                        data: groupData.means,
                        backgroundColor: 'rgba(102, 126, 234, 0.7)',
                        borderColor: '#667eea',
                        borderWidth: 1
                    }},
                    {{
                        label: 'Pass Rate (%)',
                        data: groupData.pass_rates,
                        backgroundColor: 'rgba(40, 167, 69, 0.7)',
                        borderColor: '#28a745',
                        borderWidth: 1
                    }}
                ]
            }},
            options: {{
                responsive: true,
                maintainAspectRatio: false,
                scales: {{
                    y: {{ beginAtZero: true, max: 100 }}
                }}
            }}
        }});
        
        // Category performance
        const catData = {cat_json};
        new Chart(document.getElementById('categoryChart'), {{
            type: 'radar',
            data: {{
                labels: catData.labels,
                datasets: [{{
                    label: 'Mean (%)',
                    data: catData.means,
                    backgroundColor: 'rgba(102, 126, 234, 0.3)',
                    borderColor: '#667eea',
                    pointBackgroundColor: '#667eea'
                }}]
            }},
            options: {{
                responsive: true,
                maintainAspectRatio: false,
                scales: {{
                    r: {{ beginAtZero: true, max: 100 }}
                }}
            }}
        }});
        
        // Filter table
        function filterTable() {{
            const input = document.getElementById('searchBox').value.toLowerCase();
            const table = document.getElementById('resultsTable');
            const rows = table.getElementsByTagName('tr');
            
            for (let i = 1; i < rows.length; i++) {{
                const cells = rows[i].getElementsByTagName('td');
                let match = false;
                for (let j = 0; j < cells.length; j++) {{
                    if (cells[j].textContent.toLowerCase().includes(input)) {{
                        match = true;
                        break;
                    }}
                }}
                rows[i].style.display = match ? '' : 'none';
            }}
        }}
    </script>
</body>
</html>"""
        
        return html_content
    
    @staticmethod
    def to_moodle_csv(report: OverallReport, filepath: str, 
                      assignment_name: str = "Seminar 2"):
        """Export in Moodle Gradebook compatible format."""
        with open(filepath, 'w', encoding='utf-8', newline='') as f:
            writer = csv.writer(f)
            
            # Moodle format
            writer.writerow(['Email', 'Group', assignment_name, 'Feedback'])
            
            for r in report.all_results:
                # Generate fictitious email based on name
                email = f"{r.student_name.lower().replace(' ', '.')}@student.ase.ro"
                feedback = f"Score: {r.score}/{r.max_score}. " + "; ".join(r.issues[:3])
                writer.writerow([email, r.student_group, r.percentage, feedback])

# 
# SECTION 5: COMPARISON BETWEEN EVALUATIONS
# 

class ComparisonAnalyzer:
    """Compare results between two evaluations (progress)."""
    
    def __init__(self, before: List[StudentResult], after: List[StudentResult]):
        self.before = {(r.student_name, r.student_group): r for r in before}
        self.after = {(r.student_name, r.student_group): r for r in after}
    
    def analyze_progress(self) -> Dict[str, Any]:
        """Analyse student progress."""
        common_students = set(self.before.keys()) & set(self.after.keys())
        
        improvements = []
        regressions = []
        unchanged = []
        
        for key in common_students:
            before_score = self.before[key].percentage
            after_score = self.after[key].percentage
            diff = after_score - before_score
            
            entry = {
                'student': key[0],
                'group': key[1],
                'before': before_score,
                'after': after_score,
                'diff': diff
            }
            
            if diff > 5:
                improvements.append(entry)
            elif diff < -5:
                regressions.append(entry)
            else:
                unchanged.append(entry)
        
        return {
            'common_students': len(common_students),
            'improvements': sorted(improvements, key=lambda x: -x['diff']),
            'regressions': sorted(regressions, key=lambda x: x['diff']),
            'unchanged': unchanged,
            'avg_improvement': statistics.mean([e['diff'] for e in improvements]) if improvements else 0,
            'avg_regression': statistics.mean([e['diff'] for e in regressions]) if regressions else 0
        }

# 
# SECTION 6: CLI INTERFACE
# 

class Colours:
    HEADER = '\033[95m'
    BLUE = '\033[94m'
    CYAN = '\033[96m'
    GREEN = '\033[92m'
    YELLOW = '\033[93m'
    RED = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'

def print_banner():
    """Display the application banner."""
    banner = """
╔═══════════════════════════════════════════════════════════════════════════════╗
║                                                                               ║
║   📊  REPORT GENERATOR - Seminar 3-4                                          ║
║       Results Aggregation and Statistics                                      ║
║                                                                               ║
║       Bucharest UES - CSIE | Operating Systems                                ║
║                                                                               ║
╚═══════════════════════════════════════════════════════════════════════════════╝
"""
    print(f"{Colours.CYAN}{banner}{Colours.ENDC}")

def main():
    parser = argparse.ArgumentParser(
        description='Report and statistics generator for evaluations',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Usage examples:
  %(prog)s --input ./results/
  %(prog)s --input ./results/ --format html --output report.html
  %(prog)s --input results.json --format csv --output export.csv
  %(prog)s --compare ./week1/ ./week2/ --output progress.html
        """
    )
    
    parser.add_argument('--input', '-i', required=True,
                        help='JSON/CSV file or directory with results')
    parser.add_argument('--format', '-f',
                        choices=['txt', 'html', 'csv', 'moodle', 'all'],
                        default='txt',
                        help='Report format (default: txt)')
    parser.add_argument('--output', '-o',
                        help='Output file or directory')
    parser.add_argument('--compare', '-c', nargs=2, metavar=('BEFORE', 'AFTER'),
                        help='Compare two sets of results')
    parser.add_argument('--filter-group', '-g',
                        help='Filter only a specific group')
    parser.add_argument('--min-score', type=float,
                        help='Filter students with minimum score')
    parser.add_argument('--quiet', '-q', action='store_true',
                        help='Quiet mode (no terminal output)')
    
    args = parser.parse_args()
    
    if not args.quiet:
        print_banner()
    
    # Load results
    input_path = Path(args.input)
    
    if input_path.is_dir():
        results = ResultLoader.load_directory(str(input_path))
    elif input_path.suffix == '.json':
        results = [ResultLoader.load_json(str(input_path))]
    elif input_path.suffix == '.csv':
        results = ResultLoader.load_csv(str(input_path))
    else:
        print(f"{Colours.RED}❌ Unknown format: {input_path}{Colours.ENDC}")
        return 1
    
    if not results:
        print(f"{Colours.RED}❌ No results found!{Colours.ENDC}")
        return 1
    
    if not args.quiet:
        print(f"{Colours.GREEN}✓ Loaded {len(results)} results{Colours.ENDC}")
    
    # Optional filtering
    if args.filter_group:
        results = [r for r in results if r.student_group == args.filter_group]
        if not args.quiet:
            print(f"  Filtered for group {args.filter_group}: {len(results)} results")
    
    if args.min_score:
        results = [r for r in results if r.percentage >= args.min_score]
        if not args.quiet:
            print(f"  Filtered for minimum score {args.min_score}%: {len(results)} results")
    
    # Comparison mode
    if args.compare:
        before_path, after_path = args.compare
        
        if Path(before_path).is_dir():
            before_results = ResultLoader.load_directory(before_path)
        else:
            before_results = ResultLoader.load_csv(before_path)
        
        if Path(after_path).is_dir():
            after_results = ResultLoader.load_directory(after_path)
        else:
            after_results = ResultLoader.load_csv(after_path)
        
        comparator = ComparisonAnalyzer(before_results, after_results)
        progress = comparator.analyze_progress()
        
        if not args.quiet:
            print(f"\n{Colours.BOLD}📈 PROGRESS ANALYSIS{Colours.ENDC}")
            print(f"  Common students: {progress['common_students']}")
            print(f"  Improvements: {len(progress['improvements'])} "
                  f"(mean: +{progress['avg_improvement']:.1f}%)")
            print(f"  Regressions: {len(progress['regressions'])} "
                  f"(mean: {progress['avg_regression']:.1f}%)")
            print(f"  Unchanged: {len(progress['unchanged'])}")
            
            if progress['improvements']:
                print(f"\n  {Colours.GREEN}Top improvements:{Colours.ENDC}")
                for e in progress['improvements'][:5]:
                    print(f"    • {e['student']} ({e['group']}): "
                          f"{e['before']:.0f}% → {e['after']:.0f}% (+{e['diff']:.0f}%)")
        
        return 0
    
    # Generate report
    analyzer = StatisticsAnalyzer(results)
    report = analyzer.generate_overall_report()
    
    # Determine output
    output_dir = Path(args.output) if args.output else Path('.')
    if output_dir.suffix:  # It's a file
        output_file = output_dir
        output_dir = output_dir.parent
    else:
        output_file = None
    
    output_dir.mkdir(parents=True, exist_ok=True)
    
    formats_to_export = ['txt', 'html', 'csv', 'moodle'] if args.format == 'all' else [args.format]
    
    for fmt in formats_to_export:
        if fmt == 'txt':
            content = ReportExporter.to_summary_txt(report)
            filepath = output_file or output_dir / 'report_summary.txt'
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(content)
            
            if not args.quiet:
                print(f"\n{content}")
                print(f"\n{Colours.GREEN}✓ Saved: {filepath}{Colours.ENDC}")
        
        elif fmt == 'html':
            content = ReportExporter.to_html(report)
            filepath = output_file or output_dir / 'report.html'
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(content)
            
            if not args.quiet:
                print(f"{Colours.GREEN}✓ Saved HTML report: {filepath}{Colours.ENDC}")
        
        elif fmt == 'csv':
            filepath = output_file or output_dir / 'results.csv'
            ReportExporter.to_csv(report, str(filepath))
            
            if not args.quiet:
                print(f"{Colours.GREEN}✓ Saved CSV: {filepath}{Colours.ENDC}")
        
        elif fmt == 'moodle':
            filepath = output_file or output_dir / 'moodle_grades.csv'
            ReportExporter.to_moodle_csv(report, str(filepath))
            
            if not args.quiet:
                print(f"{Colours.GREEN}✓ Saved Moodle CSV: {filepath}{Colours.ENDC}")
    
    return 0

if __name__ == '__main__':
    sys.exit(main())
