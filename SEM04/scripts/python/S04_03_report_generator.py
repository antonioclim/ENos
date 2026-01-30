#!/usr/bin/env python3
"""
S04_03_report_generator.py - Report Generator for Instructor

Generates progress reports and statistics for Seminar 4.

Usage:
    python3 S04_03_report_generator.py --grades FILE
    python3 S04_03_report_generator.py --summary
"""

import json
import sys
from pathlib import Path
from datetime import datetime
from typing import Dict, List, Optional
from collections import defaultdict

#===============================================================================
# CONFIGURATION
#===============================================================================

EXERCISE_INFO = {
    "G1": {"name": "Grep status 404", "category": "grep", "points": 10},
    "G2": {"name": "Grep counting POST", "category": "grep", "points": 10},
    "G3": {"name": "Grep IP extraction", "category": "grep", "points": 15},
    "G4": {"name": "Grep email validation", "category": "grep", "points": 15},
    "S1": {"name": "Sed replacement", "category": "sed", "points": 10},
    "S2": {"name": "Sed delete comments", "category": "sed", "points": 10},
    "S3": {"name": "Sed complete cleanup", "category": "sed", "points": 15},
    "A1": {"name": "AWK column extraction", "category": "awk", "points": 10},
    "A2": {"name": "AWK salary sum", "category": "awk", "points": 15},
    "A3": {"name": "AWK count per dept", "category": "awk", "points": 20},
}

#===============================================================================
# FUNCTIONS
#===============================================================================

def load_grades_file(filepath: Path) -> List[Dict]:
    """Loads an autograder results file."""
    with open(filepath) as f:
        return json.load(f)

def calculate_statistics(grades: List[Dict]) -> Dict:
    """Calculate statistics from autograder results."""
    if not grades:
        return {"error": "No data available"}
    
    stats = {
        "total_students": len(grades),
        "scores": [],
        "by_exercise": defaultdict(lambda: {"attempts": 0, "passed": 0, "total_score": 0}),
        "by_category": defaultdict(lambda: {"attempts": 0, "passed": 0}),
    }
    
    for result in grades:
        if "exercises" not in result:
            continue
            
        total = result.get("total_score", 0)
        stats["scores"].append(total)
        
        for ex_id, ex_result in result["exercises"].items():
            ex_info = EXERCISE_INFO.get(ex_id, {"category": "unknown", "points": 0})
            
            stats["by_exercise"][ex_id]["attempts"] += 1
            stats["by_exercise"][ex_id]["total_score"] += ex_result.get("score", 0)
            if ex_result.get("passed", False):
                stats["by_exercise"][ex_id]["passed"] += 1
            
            stats["by_category"][ex_info["category"]]["attempts"] += 1
            if ex_result.get("passed", False):
                stats["by_category"][ex_info["category"]]["passed"] += 1
    
    # Calculate aggregate statistics
    if stats["scores"]:
        stats["avg_score"] = sum(stats["scores"]) / len(stats["scores"])
        stats["max_score"] = max(stats["scores"])
        stats["min_score"] = min(stats["scores"])
        stats["median_score"] = sorted(stats["scores"])[len(stats["scores"]) // 2]
    
    return stats

def format_report(stats: Dict) -> str:
    """Format statistics into a text report."""
    lines = []
    lines.append("=" * 70)
    lines.append("REPORT SEMINAR 4: TEXT PROCESSING (grep, sed, awk)")
    lines.append(f"Generated: {datetime.now().strftime('%Y-%m-%d %H:%M')}")
    lines.append("=" * 70)
    lines.append("")
    
    # Overview
    lines.append("📊 GENERAL STATISTICS")
    lines.append("-" * 40)
    lines.append(f"  Total students evaluated: {stats.get('total_students', 0)}")
    lines.append(f"  Average score: {stats.get('avg_score', 0):.1f}")
    lines.append(f"  Maximum score: {stats.get('max_score', 0)}")
    lines.append(f"  Minimum score: {stats.get('min_score', 0)}")
    lines.append(f"  Median score: {stats.get('median_score', 0)}")
    lines.append("")
    
    # Per category
    lines.append("📈 PERFORMANCE BY CATEGORY")
    lines.append("-" * 40)
    for cat, cat_stats in stats.get("by_category", {}).items():
        attempts = cat_stats["attempts"]
        passed = cat_stats["passed"]
        rate = (passed / attempts * 100) if attempts > 0 else 0
        lines.append(f"  {cat.upper():10} | Success rate: {rate:5.1f}% ({passed}/{attempts})")
    lines.append("")
    
    # Per exercise
    lines.append("📝 PERFORMANCE BY EXERCISE")
    lines.append("-" * 40)
    for ex_id, ex_stats in sorted(stats.get("by_exercise", {}).items()):
        ex_info = EXERCISE_INFO.get(ex_id, {"name": ex_id, "points": 0})
        attempts = ex_stats["attempts"]
        passed = ex_stats["passed"]
        rate = (passed / attempts * 100) if attempts > 0 else 0
        avg = (ex_stats["total_score"] / attempts) if attempts > 0 else 0
        
        status = "✓" if rate >= 70 else "⚠" if rate >= 50 else "✗"
        lines.append(f"  {status} {ex_id}: {ex_info['name'][:25]:25} | {rate:5.1f}% | Avg: {avg:.1f}/{ex_info['points']}")
    lines.append("")
    
    # Recommendations
    lines.append("💡 RECOMMENDATIONS FOR INSTRUCTOR")
    lines.append("-" * 40)
    
    weak_exercises = []
    for ex_id, ex_stats in stats.get("by_exercise", {}).items():
        attempts = ex_stats["attempts"]
        passed = ex_stats["passed"]
        rate = (passed / attempts * 100) if attempts > 0 else 0
        if rate < 50 and attempts > 0:
            weak_exercises.append((ex_id, rate))
    
    if weak_exercises:
        lines.append("  Problematic exercises (below 50% success):")
        for ex_id, rate in sorted(weak_exercises, key=lambda x: x[1]):
            ex_info = EXERCISE_INFO.get(ex_id, {"name": ex_id})
            lines.append(f"    • {ex_id}: {ex_info['name']} ({rate:.0f}%)")
        lines.append("  → Review these concepts in class!")
    else:
        lines.append("  ✓ All exercises have acceptable success rates")
    
    lines.append("")
    lines.append("=" * 70)
    
    return "\n".join(lines)

def generate_sample_data():
    """Generates test data for demonstration."""
    import random
    
    sample = []
    for i in range(25):
        student = {
            "student_id": f"STU{1000+i}",
            "exercises": {},
            "total_score": 0,
            "max_score": 130
        }
        
        for ex_id, ex_info in EXERCISE_INFO.items():
            passed = random.random() > 0.3
            score = ex_info["points"] if passed else int(ex_info["points"] * random.random() * 0.5)
            student["exercises"][ex_id] = {
                "score": score,
                "max_points": ex_info["points"],
                "passed": passed
            }
            student["total_score"] += score
        
        sample.append(student)
    
    return sample

#===============================================================================
# MAIN
#===============================================================================

def main():
    import argparse
    
    parser = argparse.ArgumentParser(description="Report generator for Seminar 4")
    parser.add_argument("--grades", "-g", type=Path, help="JSON file with autograder results")
    parser.add_argument("--output", "-o", type=Path, help="Output file")
    parser.add_argument("--sample", action="store_true", help="Use test data")
    parser.add_argument("--json", action="store_true", help="Output in JSON format")
    
    args = parser.parse_args()
    
    if args.sample:
        grades = generate_sample_data()
    elif args.grades:
        if not args.grades.exists():
            print(f"File does not exist: {args.grades}")
            sys.exit(1)
        grades = load_grades_file(args.grades)
    else:
        print("Use --grades FILE or --sample for test data")
        sys.exit(1)
    
    stats = calculate_statistics(grades)
    
    if args.json:
        output = json.dumps(stats, indent=2, default=str)
    else:
        output = format_report(stats)
    
    if args.output:
        with open(args.output, 'w') as f:
            f.write(output)
        print(f"Report saved to: {args.output}")
    else:
        print(output)

if __name__ == '__main__':
    main()
