#!/usr/bin/env python3
"""
S04_05_similarity_checker.py - Similarity Checker for Student Submissions

Compares all .sh files in submission folders using difflib.
Flags pairs with >70% similarity for manual review.

Usage:
    python3 S04_05_similarity_checker.py ./submissions/
    python3 S04_05_similarity_checker.py --threshold 0.80 ./submissions/
    
Note from instructor (2024 autumn session): This caught three students who 
submitted nearly identical code with just variable name changes. The oral 
verification confirmed they had shared solutions. Worth running before grading.
"""

import os
import sys
from pathlib import Path
from difflib import SequenceMatcher
from itertools import combinations
from typing import Dict, List, Tuple
import argparse

#===============================================================================
# CONFIGURATION
#===============================================================================

DEFAULT_THRESHOLD = 0.70  # 70% similarity triggers a flag
MIN_FILE_SIZE = 50  # Ignore files smaller than this (bytes)

#===============================================================================
# FUNCTIONS
#===============================================================================

def normalise_script(content: str) -> str:
    """
    Remove comments and normalise whitespace for fair comparison.
    
    This strips away superficial differences like comment styles and 
    blank lines, focusing on the actual logic.
    """
    lines = []
    for line in content.split('\n'):
        # Remove inline comments (but keep the code before #)
        if '#' in line:
            line = line.split('#')[0]
        line = line.strip()
        if line:
            lines.append(line)
    return '\n'.join(lines)


def similarity(a: str, b: str) -> float:
    """Calculate similarity ratio between two strings using SequenceMatcher."""
    return SequenceMatcher(None, a, b).ratio()


def get_scripts_from_submissions(submissions_dir: Path) -> Dict[str, str]:
    """
    Collect all shell scripts from submission directories.
    
    Expected structure:
        submissions/
            student_001/
                ex1.sh
                ex2.sh
            student_002/
                ex1.sh
                ex2.sh
    """
    scripts = {}
    
    for folder in submissions_dir.iterdir():
        if not folder.is_dir():
            continue
        if folder.name.startswith('.'):
            continue
            
        for sh_file in folder.glob('*.sh'):
            try:
                content = sh_file.read_text(errors='ignore')
                if len(content) >= MIN_FILE_SIZE:
                    key = f"{folder.name}/{sh_file.name}"
                    scripts[key] = normalise_script(content)
            except Exception as e:
                print(f"Warning: Could not read {sh_file}: {e}", file=sys.stderr)
    
    return scripts


def check_submissions(
    submissions_dir: Path, 
    threshold: float = DEFAULT_THRESHOLD,
    same_exercise_only: bool = True
) -> List[Tuple[str, str, float]]:
    """
    Check all submission pairs for similarity.
    
    Args:
        submissions_dir: Path to submissions folder
        threshold: Minimum similarity ratio to flag (0.0-1.0)
        same_exercise_only: Only compare files with the same name
        
    Returns:
        List of (file1, file2, similarity) tuples above threshold
    """
    scripts = get_scripts_from_submissions(submissions_dir)
    
    if not scripts:
        print("No shell scripts found in submissions directory.")
        return []
    
    print(f"Found {len(scripts)} scripts to compare...")
    
    flagged = []
    comparisons = 0
    
    for (name1, code1), (name2, code2) in combinations(scripts.items(), 2):
        # Extract just the filename for comparison
        file1 = name1.split('/')[-1]
        file2 = name2.split('/')[-1]
        
        # Only compare same exercise unless explicitly disabled
        if same_exercise_only and file1 != file2:
            continue
        
        comparisons += 1
        sim = similarity(code1, code2)
        
        if sim >= threshold:
            flagged.append((name1, name2, sim))
    
    print(f"Performed {comparisons} comparisons.")
    return flagged


def print_report(flagged: List[Tuple[str, str, float]], threshold: float) -> None:
    """Print a formatted report of flagged submissions."""
    
    if not flagged:
        print("\n" + "=" * 60)
        print("✓ NO SUSPICIOUS SIMILARITIES DETECTED")
        print("=" * 60)
        print(f"\nAll submission pairs are below {threshold*100:.0f}% similarity.")
        return
    
    print("\n" + "=" * 60)
    print(f"⚠️  SIMILARITY ALERT - {len(flagged)} PAIRS FLAGGED")
    print("=" * 60)
    print(f"\nThreshold: {threshold*100:.0f}%")
    print("-" * 60)
    
    # Sort by similarity (highest first)
    for name1, name2, sim in sorted(flagged, key=lambda x: -x[2]):
        status = "🔴" if sim >= 0.90 else "🟠" if sim >= 0.80 else "🟡"
        print(f"\n{status} {sim*100:.1f}% similarity")
        print(f"   File 1: {name1}")
        print(f"   File 2: {name2}")
    
    print("\n" + "-" * 60)
    print("RECOMMENDED ACTIONS:")
    print("  1. Review flagged pairs manually")
    print("  2. Check for identical variable names, structure, comments")
    print("  3. Conduct oral verification if plagiarism is suspected")
    print("  4. Document findings before confronting students")
    print("=" * 60)


#===============================================================================
# MAIN
#===============================================================================

def main():
    parser = argparse.ArgumentParser(
        description="Check student submissions for code similarity",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
    %(prog)s ./submissions/
    %(prog)s --threshold 0.80 ./submissions/
    %(prog)s --all-pairs ./submissions/

The tool normalises code by removing comments and whitespace before
comparing, so superficial changes won't fool it.

Typical workflow:
    1. Run this before grading to flag suspicious submissions
    2. Review flagged pairs manually
    3. Conduct oral verification for high-similarity pairs
    4. Document findings for academic integrity procedures
        """
    )
    
    parser.add_argument(
        "submissions_dir",
        type=Path,
        help="Directory containing student submission folders"
    )
    
    parser.add_argument(
        "--threshold", "-t",
        type=float,
        default=DEFAULT_THRESHOLD,
        help=f"Similarity threshold to flag (default: {DEFAULT_THRESHOLD})"
    )
    
    parser.add_argument(
        "--all-pairs",
        action="store_true",
        help="Compare all file pairs (not just same-named exercises)"
    )
    
    parser.add_argument(
        "--json",
        action="store_true",
        help="Output results in JSON format"
    )
    
    args = parser.parse_args()
    
    if not args.submissions_dir.exists():
        print(f"Error: Directory not found: {args.submissions_dir}")
        sys.exit(1)
    
    if not args.submissions_dir.is_dir():
        print(f"Error: Not a directory: {args.submissions_dir}")
        sys.exit(1)
    
    flagged = check_submissions(
        args.submissions_dir,
        threshold=args.threshold,
        same_exercise_only=not args.all_pairs
    )
    
    if args.json:
        import json
        output = {
            "threshold": args.threshold,
            "flagged_count": len(flagged),
            "flagged": [
                {"file1": f1, "file2": f2, "similarity": round(sim, 4)}
                for f1, f2, sim in flagged
            ]
        }
        print(json.dumps(output, indent=2))
    else:
        print_report(flagged, args.threshold)


if __name__ == '__main__':
    main()
