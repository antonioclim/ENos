#!/usr/bin/env python3
"""
S05_03_report_generator.py - Report Generator for Instructor

Operating Systems | ASE Bucharest - CSIE
Seminar 5: Advanced Bash Scripting

Generates progress reports and statistics for evaluation of
advanced Bash scripts (functions, arrays, robustness, debugging).

USAGE:
    python3 S05_03_report_generator.py --grades FILE
    python3 S05_03_report_generator.py --grades FILE --format json
    python3 S05_03_report_generator.py --summary
    python3 S05_03_report_generator.py --help
"""

import json
import sys
import argparse
from pathlib import Path
from datetime import datetime
from typing import Dict, List, Optional, Any
from collections import defaultdict

#===============================================================================
# CONFIGURATION
#===============================================================================

EXERCISE_INFO = {
    # Robustness
    "R1": {"name": "Correct shebang", "category": "robustness", "points": 1},
    "R2": {"name": "set -e (errexit)", "category": "robustness", "points": 1},
    "R3": {"name": "set -u (nounset)", "category": "robustness", "points": 1},
    "R4": {"name": "set -o pipefail", "category": "robustness", "points": 1},
    "R5": {"name": "IFS safe setting", "category": "robustness", "points": 1},
    
    # Functions
    "F1": {"name": "Functions defined", "category": "functions", "points": 2},
    "F2": {"name": "Local variables (local)", "category": "functions", "points": 3},
    "F3": {"name": "Function documentation", "category": "functions", "points": 2},
    "F4": {"name": "Correct return codes", "category": "functions", "points": 2},
    "F5": {"name": "Argument validation", "category": "functions", "points": 2},
    
    # Arrays
    "A1": {"name": "Indexed arrays", "category": "arrays", "points": 2},
    "A2": {"name": "Iteration with quotes", "category": "arrays", "points": 3},
    "A3": {"name": "declare -A for hash", "category": "arrays", "points": 3},
    "A4": {"name": "Correct ${arr[@]} access", "category": "arrays", "points": 2},
    
    # Error Handling
    "E1": {"name": "Trap cleanup", "category": "error_handling", "points": 3},
    "E2": {"name": "Error messages >&2", "category": "error_handling", "points": 2},
    "E3": {"name": "Custom exit codes", "category": "error_handling", "points": 2},
    "E4": {"name": "Input file validation", "category": "error_handling", "points": 2},
    
    # Best Practices
    "B1": {"name": "Quotes on variables", "category": "best_practices", "points": 2},
    "B2": {"name": "readonly for constants", "category": "best_practices", "points": 1},
    "B3": {"name": "main() function", "category": "best_practices", "points": 2},
    "B4": {"name": "ShellCheck no errors", "category": "best_practices", "points": 3},
}

CATEGORIES = {
    "robustness": {"name": "🛡️ Robustness", "weight": 1.0},
    "functions": {"name": "📦 Functions", "weight": 1.2},
    "arrays": {"name": "📚 Arrays", "weight": 1.2},
    "error_handling": {"name": "⚠️ Error Handling", "weight": 1.1},
    "best_practices": {"name": "✨ Best Practices", "weight": 1.0},
}

#===============================================================================
# FUNCTIONS
#===============================================================================

def load_grades_file(filepath: Path) -> List[Dict]:
    """Load a JSON file with autograder results."""
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            data = json.load(f)
            # Accept both list and dict with 'results' key
            if isinstance(data, list):
                return data
            elif isinstance(data, dict) and 'results' in data:
                return data['results']
            else:
                return [data]
    except json.JSONDecodeError as e:
        print(f"Error parsing JSON: {e}", file=sys.stderr)
        return []
    except FileNotFoundError:
        print(f"File not found: {filepath}", file=sys.stderr)
        return []

def calculate_statistics(grades: List[Dict]) -> Dict[str, Any]:
    """Calculate statistics from autograder results."""
    if not grades:
        return {"error": "No data available", "total_students": 0}
    
    stats: Dict[str, Any] = {
        "total_students": len(grades),
        "scores": [],
        "by_exercise": defaultdict(lambda: {"attempts": 0, "passed": 0, "total_score": 0}),
        "by_category": defaultdict(lambda: {"attempts": 0, "passed": 0, "total_score": 0, "max_score": 0}),
        "common_issues": defaultdict(int),
        "timestamps": [],
    }
    
    for result in grades:
        # Extract total score
        total = result.get("total_score", 0)
        stats["scores"].append(total)
        
        # Timestamp if exists
        if "timestamp" in result:
            stats["timestamps"].append(result["timestamp"])
        
        # Process exercises
        exercises = result.get("exercises", result.get("checks", {}))
        
        for ex_id, ex_result in exercises.items():
            if ex_id not in EXERCISE_INFO:
                continue
                
            ex_info = EXERCISE_INFO[ex_id]
            category = ex_info["category"]
            
            # Statistics per exercise
            stats["by_exercise"][ex_id]["attempts"] += 1
            score = ex_result.get("score", ex_result.get("points", 0))
            stats["by_exercise"][ex_id]["total_score"] += score
            
            passed = ex_result.get("passed", score >= ex_info["points"])
            if passed:
                stats["by_exercise"][ex_id]["passed"] += 1
            else:
                # Track common issues
                msg = ex_result.get("message", "")
                if msg:
                    stats["common_issues"][f"{ex_id}: {msg[:50]}"] += 1
            
            # Statistics per category
            stats["by_category"][category]["attempts"] += 1
            stats["by_category"][category]["total_score"] += score
            stats["by_category"][category]["max_score"] += ex_info["points"]
            if passed:
                stats["by_category"][category]["passed"] += 1
    
    # Calculate aggregate statistics
    if stats["scores"]:
        sorted_scores = sorted(stats["scores"])
        n = len(sorted_scores)
        
        stats["avg_score"] = sum(stats["scores"]) / n
        stats["max_score"] = max(stats["scores"])
        stats["min_score"] = min(stats["scores"])
        stats["median_score"] = sorted_scores[n // 2] if n % 2 else (sorted_scores[n//2 - 1] + sorted_scores[n//2]) / 2
        
        # Standard deviation
        variance = sum((x - stats["avg_score"]) ** 2 for x in stats["scores"]) / n
        stats["std_dev"] = variance ** 0.5
        
        # Distribution by ranges
        stats["distribution"] = {
            "excellent (90-100%)": sum(1 for s in stats["scores"] if s >= 90),
            "good (70-89%)": sum(1 for s in stats["scores"] if 70 <= s < 90),
            "satisfactory (50-69%)": sum(1 for s in stats["scores"] if 50 <= s < 70),
            "needs_work (<50%)": sum(1 for s in stats["scores"] if s < 50),
        }
    
    return stats

def format_text_report(stats: Dict[str, Any]) -> str:
    """Format statistics into a text report."""
    lines = []
    
    lines.append("=" * 70)
    lines.append("SEMINAR 9-10 REPORT: ADVANCED BASH SCRIPTING")
    lines.append(f"Generated: {datetime.now().strftime('%Y-%m-%d %H:%M')}")
    lines.append("=" * 70)
    lines.append("")
    
    if stats.get("error"):
        lines.append(f"⚠️  {stats['error']}")
        return "\n".join(lines)
    
    # Overview
    lines.append("📊 GENERAL STATISTICS")
    lines.append("-" * 40)
    lines.append(f"  Total students evaluated: {stats.get('total_students', 0)}")
    lines.append(f"  Average score: {stats.get('avg_score', 0):6.1f} points")
    lines.append(f"  Maximum score: {stats.get('max_score', 0):6.1f} points")
    lines.append(f"  Minimum score: {stats.get('min_score', 0):6.1f} points")
    lines.append(f"  Median score:  {stats.get('median_score', 0):6.1f} points")
    lines.append(f"  Std deviation: {stats.get('std_dev', 0):6.2f}")
    lines.append("")
    
    # Distribution
    dist = stats.get("distribution", {})
    if dist:
        lines.append("📈 SCORE DISTRIBUTION")
        lines.append("-" * 40)
        total = stats.get("total_students", 1)
        for level, count in dist.items():
            pct = (count / total * 100) if total > 0 else 0
            bar = "█" * int(pct / 5)
            lines.append(f"  {level:25} {count:3} ({pct:5.1f}%) {bar}")
        lines.append("")
    
    # By category
    lines.append("📁 BY CATEGORY")
    lines.append("-" * 40)
    for cat_id, cat_stats in stats.get("by_category", {}).items():
        cat_info = CATEGORIES.get(cat_id, {"name": cat_id})
        attempts = cat_stats["attempts"]
        passed = cat_stats["passed"]
        rate = (passed / attempts * 100) if attempts > 0 else 0
        total_score = cat_stats["total_score"]
        max_score = cat_stats["max_score"]
        avg = (total_score / attempts) if attempts > 0 else 0
        
        lines.append(f"  {cat_info['name']}: {rate:.0f}% success (avg {avg:.1f}/{max_score/attempts if attempts > 0 else 0:.1f})")
    lines.append("")
    
    # By exercise
    lines.append("📋 BY EXERCISE")
    lines.append("-" * 40)
    for ex_id in sorted(EXERCISE_INFO.keys()):
        ex_info = EXERCISE_INFO[ex_id]
        ex_stats = stats.get("by_exercise", {}).get(ex_id, {})
        
        attempts = ex_stats.get("attempts", 0)
        if attempts == 0:
            continue
            
        passed = ex_stats.get("passed", 0)
        rate = (passed / attempts * 100) if attempts > 0 else 0
        avg_score = (ex_stats.get("total_score", 0) / attempts) if attempts > 0 else 0
        
        status = "✓" if rate >= 70 else "⚠" if rate >= 50 else "✗"
        lines.append(f"  {status} {ex_id}: {ex_info['name'][:28]:28} | {rate:5.1f}% | Avg: {avg_score:.1f}/{ex_info['points']}")
    lines.append("")
    
    # Common issues
    common_issues = stats.get("common_issues", {})
    if common_issues:
        lines.append("🔴 FREQUENT ISSUES")
        lines.append("-" * 40)
        sorted_issues = sorted(common_issues.items(), key=lambda x: -x[1])[:10]
        for issue, count in sorted_issues:
            lines.append(f"  • ({count}x) {issue}")
        lines.append("")
    
    # Recommendations
    lines.append("💡 RECOMMENDATIONS FOR INSTRUCTOR")
    lines.append("-" * 40)
    
    weak_categories = []
    for cat_id, cat_stats in stats.get("by_category", {}).items():
        attempts = cat_stats["attempts"]
        passed = cat_stats["passed"]
        rate = (passed / attempts * 100) if attempts > 0 else 0
        if rate < 60 and attempts > 0:
            weak_categories.append((cat_id, rate))
    
    if weak_categories:
        lines.append("  Problematic categories (below 60% success):")
        for cat_id, rate in sorted(weak_categories, key=lambda x: x[1]):
            cat_name = CATEGORIES.get(cat_id, {}).get("name", cat_id)
            lines.append(f"    • {cat_name}: {rate:.0f}%")
        lines.append("")
        lines.append("  Suggestions:")
        
        for cat_id, _ in weak_categories:
            if cat_id == "robustness":
                lines.append("    → Review 'set -euo pipefail' and effects of each option")
            elif cat_id == "functions":
                lines.append("    → Demonstrate difference between local and global in functions")
            elif cat_id == "arrays":
                lines.append("    → Practical exercises with arrays and declare -A")
            elif cat_id == "error_handling":
                lines.append("    → Live coding with trap and cleanup patterns")
            elif cat_id == "best_practices":
                lines.append("    → Run ShellCheck together in class")
    else:
        lines.append("  ✓ All categories have acceptable success rate!")
    
    lines.append("")
    lines.append("=" * 70)
    lines.append("  📌 Priority topics for review:")
    
    weak_exercises = []
    for ex_id, ex_stats in stats.get("by_exercise", {}).items():
        attempts = ex_stats["attempts"]
        passed = ex_stats["passed"]
        rate = (passed / attempts * 100) if attempts > 0 else 0
        if rate < 50 and attempts > 0:
            weak_exercises.append((ex_id, rate))
    
    if weak_exercises:
        for ex_id, rate in sorted(weak_exercises, key=lambda x: x[1])[:5]:
            ex_info = EXERCISE_INFO.get(ex_id, {"name": ex_id})
            lines.append(f"     • {ex_info['name']} ({rate:.0f}% success)")
    else:
        lines.append("     No exercise below 50% success!")
    
    lines.append("=" * 70)
    
    return "\n".join(lines)

def format_json_report(stats: Dict[str, Any]) -> str:
    """Format statistics as JSON."""
    # Convert defaultdicts to regular dicts for JSON serialization
    output = {
        "metadata": {
            "generated_at": datetime.now().isoformat(),
            "seminar": "9-10",
            "topic": "Advanced Bash Scripting"
        },
        "summary": {
            "total_students": stats.get("total_students", 0),
            "avg_score": round(stats.get("avg_score", 0), 2),
            "max_score": stats.get("max_score", 0),
            "min_score": stats.get("min_score", 0),
            "median_score": round(stats.get("median_score", 0), 2),
            "std_dev": round(stats.get("std_dev", 0), 2),
        },
        "distribution": stats.get("distribution", {}),
        "by_category": {k: dict(v) for k, v in stats.get("by_category", {}).items()},
        "by_exercise": {k: dict(v) for k, v in stats.get("by_exercise", {}).items()},
        "common_issues": dict(stats.get("common_issues", {})),
    }
    return json.dumps(output, indent=2, ensure_ascii=False)

def generate_summary() -> str:
    """Generate a summary of available exercises."""
    lines = []
    lines.append("=" * 70)
    lines.append("SEMINAR 9-10: ADVANCED BASH SCRIPTING - AVAILABLE EXERCISES")
    lines.append("=" * 70)
    lines.append("")
    
    total_points = 0
    current_category = None
    
    for ex_id in sorted(EXERCISE_INFO.keys()):
        ex_info = EXERCISE_INFO[ex_id]
        
        if ex_info["category"] != current_category:
            current_category = ex_info["category"]
            cat_info = CATEGORIES.get(current_category, {"name": current_category})
            lines.append(f"\n{cat_info['name']}")
            lines.append("-" * 40)
        
        lines.append(f"  {ex_id}: {ex_info['name']:35} [{ex_info['points']} points]")
        total_points += ex_info["points"]
    
    lines.append("")
    lines.append("=" * 70)
    lines.append(f"TOTAL: {len(EXERCISE_INFO)} exercises | {total_points} points possible")
    lines.append("=" * 70)
    
    return "\n".join(lines)

#===============================================================================
# MAIN
#===============================================================================

def main():
    parser = argparse.ArgumentParser(
        description="Report generator for Seminar 5: Advanced Bash Scripting",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python3 S05_03_report_generator.py --grades results.json
  python3 S05_03_report_generator.py --grades results.json --format json
  python3 S05_03_report_generator.py --grades results.json --output report.txt
  python3 S05_03_report_generator.py --summary
        """
    )
    
    parser.add_argument(
        "--grades", "-g",
        type=Path,
        help="JSON file with autograder results"
    )
    
    parser.add_argument(
        "--format", "-f",
        choices=["text", "json"],
        default="text",
        help="Output format (default: text)"
    )
    
    parser.add_argument(
        "--output", "-o",
        type=Path,
        help="Output file (default: stdout)"
    )
    
    parser.add_argument(
        "--summary", "-s",
        action="store_true",
        help="Display summary of available exercises"
    )
    
    args = parser.parse_args()
    
    # Generate output
    if args.summary:
        output = generate_summary()
    elif args.grades:
        grades = load_grades_file(args.grades)
        stats = calculate_statistics(grades)
        
        if args.format == "json":
            output = format_json_report(stats)
        else:
            output = format_text_report(stats)
    else:
        parser.print_help()
        return 1
    
    # Write output
    if args.output:
        with open(args.output, 'w', encoding='utf-8') as f:
            f.write(output)
        print(f"Report saved to: {args.output}")
    else:
        print(output)
    
    return 0

if __name__ == "__main__":
    sys.exit(main())
