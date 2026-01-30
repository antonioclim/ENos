#!/usr/bin/env python3
"""
S04_01_autograder.py - Autograder for Seminar 4: Text Processing

Automatically evaluates student solutions for grep, sed, awk exercises.
Supports partial credit and provides detailed feedback.

Usage:
    python3 S04_01_autograder.py <submission_file> [--verbose]
    python3 S04_01_autograder.py --self-test

Author: Operating Systems Course, ASE Bucharest - CSIE
Version: 1.1
"""

import logging
import subprocess
import sys
import os
import json
import tempfile
from pathlib import Path
from dataclasses import dataclass, field
from typing import Optional, Tuple, List, Dict, Any

# Logging setup — import shared utilities from kit lib
sys.path.insert(0, str(Path(__file__).parent.parent.parent.parent / 'lib'))
from logging_utils import setup_logging

logger = setup_logging(__name__)

# ═══════════════════════════════════════════════════════════════════════════════
# CONFIGURATION
# ═══════════════════════════════════════════════════════════════════════════════

DATA_DIR = Path.home() / "demo_sem4" / "data"


@dataclass
class TestCase:
    """
    Defines a test case for the autograder.
    
    Attributes:
        id: Unique identifier for the exercise (e.g., 'G1', 'S2')
        description: Human-readable description of the task
        expected_command: Reference command that produces correct output
        points: Maximum points for this exercise
        partial_credit: Whether to award partial credit for similar outputs
        hints: List of hints to show on incorrect answers
    """
    id: str
    description: str
    expected_command: str
    points: int
    partial_credit: bool = True
    hints: List[str] = field(default_factory=list)


# Exercise definitions
EXERCISES: Dict[str, TestCase] = {
    # GREP Exercises
    "G1": TestCase(
        id="G1",
        description="Find lines with code 404 in access.log",
        expected_command="grep ' 404 ' access.log",
        points=10,
        hints=["The pattern includes spaces around 404 for exact matching"]
    ),
    "G2": TestCase(
        id="G2",
        description="Count POST requests",
        expected_command="grep -c 'POST' access.log",
        points=10,
        hints=["Use grep -c for counting lines"]
    ),
    "G3": TestCase(
        id="G3",
        description="Extract unique IPs",
        expected_command="grep -oE '^[0-9]+\\.[0-9]+\\.[0-9]+\\.[0-9]+' access.log | sort -u",
        points=15,
        hints=["Combine grep -o with sort -u for unique extraction"]
    ),
    "G4": TestCase(
        id="G4",
        description="Extract valid emails",
        expected_command="grep -E '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$' emails.txt",
        points=15,
        hints=["Use extended regex for email validation pattern"]
    ),
    
    # SED Exercises
    "S1": TestCase(
        id="S1",
        description="Replace localhost with 127.0.0.1",
        expected_command="sed 's/localhost/127.0.0.1/g' config.txt",
        points=10,
        hints=["Do not forget the /g flag for all occurrences"]
    ),
    "S2": TestCase(
        id="S2",
        description="Delete comments from config",
        expected_command="sed '/^#/d' config.txt",
        points=10,
        hints=["Pattern /^#/d deletes lines starting with #"]
    ),
    "S3": TestCase(
        id="S3",
        description="Delete comments and empty lines",
        expected_command="sed '/^#/d; /^$/d' config.txt",
        points=15,
        hints=["Combine /^#/d and /^$/d patterns"]
    ),
    
    # AWK Exercises
    "A1": TestCase(
        id="A1",
        description="Display Name column from CSV",
        expected_command="awk -F',' '{print $2}' employees.csv",
        points=10,
        hints=["Use -F',' to set CSV delimiter"]
    ),
    "A2": TestCase(
        id="A2",
        description="Sum salaries (skip header)",
        expected_command="awk -F',' 'NR > 1 {sum += $4} END {print sum}' employees.csv",
        points=15,
        hints=["Use NR > 1 to skip header, END block for final output"]
    ),
    "A3": TestCase(
        id="A3",
        description="Count employees per department",
        expected_command="awk -F',' 'NR > 1 {count[$3]++} END {for (d in count) print d, count[d]}' employees.csv",
        points=20,
        hints=["Use associative array for counting by key"]
    ),
}


# ═══════════════════════════════════════════════════════════════════════════════
# EVALUATION FUNCTIONS
# ═══════════════════════════════════════════════════════════════════════════════

def run_command(
    cmd: str,
    cwd: Path,
    timeout: int = 10
) -> Tuple[str, str, int]:
    """
    Execute a shell command and capture its output.
    
    Args:
        cmd: Shell command to execute
        cwd: Working directory for command execution
        timeout: Maximum seconds to wait for completion
        
    Returns:
        Tuple of (stdout, stderr, return_code)
        On timeout, returns ("", "TIMEOUT", -1)
    """
    try:
        result = subprocess.run(
            cmd,
            shell=True,
            capture_output=True,
            text=True,
            timeout=timeout,
            cwd=cwd
        )
        return result.stdout.strip(), result.stderr.strip(), result.returncode
    except subprocess.TimeoutExpired:
        return "", "TIMEOUT", -1
    except Exception as e:
        return "", str(e), -1


def normalise_output(output: str) -> str:
    """
    Normalise command output for flexible comparison.
    
    Applies whitespace normalisation and sorting to allow
    comparison of outputs that may differ only in formatting.
    
    Args:
        output: Raw command output string
        
    Returns:
        Normalised string suitable for comparison
    """
    lines = output.strip().split('\n')
    lines = [' '.join(line.split()) for line in lines]  # Normalise whitespace
    lines = sorted(lines)  # Sort for consistent ordering
    return '\n'.join(lines)


def compare_outputs(
    expected: str,
    actual: str,
    exact: bool = False
) -> Tuple[bool, float]:
    """
    Compare two command outputs and calculate similarity.
    
    Args:
        expected: Expected output from reference command
        actual: Actual output from student command
        exact: If True, require exact match; otherwise use fuzzy matching
        
    Returns:
        Tuple of (is_match, similarity_score)
        similarity_score is 0.0 to 1.0
    """
    if exact:
        return expected == actual, 1.0 if expected == actual else 0.0
    
    # Normalise both outputs
    exp_norm = normalise_output(expected)
    act_norm = normalise_output(actual)
    
    if exp_norm == act_norm:
        return True, 1.0
    
    # Calculate line-based similarity
    exp_lines = set(exp_norm.split('\n'))
    act_lines = set(act_norm.split('\n'))
    
    if not exp_lines:
        return False, 0.0
    
    correct = len(exp_lines.intersection(act_lines))
    total = len(exp_lines)
    similarity = correct / total
    
    return similarity >= 0.9, similarity


def evaluate_exercise(
    exercise_id: str,
    student_command: str,
    verbose: bool = False
) -> Dict[str, Any]:
    """
    Evaluate a student's solution for a specific exercise.
    
    Runs both the expected command and student command, then
    compares outputs to determine score.
    
    Args:
        exercise_id: ID of the exercise (e.g., 'G1', 'S2')
        student_command: Student's shell command to evaluate
        verbose: If True, print debug information
        
    Returns:
        Dictionary with keys: score, max_points, feedback, passed
    """
    if exercise_id not in EXERCISES:
        return {
            'score': 0,
            'max_points': 0,
            'feedback': f"Unknown exercise: {exercise_id}",
            'passed': False
        }
    
    exercise = EXERCISES[exercise_id]
    
    # Check data directory exists
    if not DATA_DIR.exists():
        return {
            'score': 0,
            'max_points': exercise.points,
            'feedback': "Data directory not found. Run setup_seminar.sh first.",
            'passed': False
        }
    
    # Run expected command
    expected_out, expected_err, expected_rc = run_command(
        exercise.expected_command, DATA_DIR
    )
    
    # Run student command
    student_out, student_err, student_rc = run_command(
        student_command, DATA_DIR
    )
    
    if verbose:
        print(f"\n[DEBUG] Expected output:\n{expected_out[:500]}...")
        print(f"\n[DEBUG] Student output:\n{student_out[:500]}...")
    
    # Check for timeout
    if student_err and "TIMEOUT" in student_err:
        return {
            'score': 0,
            'max_points': exercise.points,
            'feedback': "Command timed out. Check for infinite loops.",
            'passed': False
        }
    
    # Check for errors
    if student_rc != 0 and student_rc != expected_rc:
        feedback = f"Command returned error: {student_err}"
        if exercise.hints:
            feedback += f"\nHint: {exercise.hints[0]}"
        return {
            'score': 0,
            'max_points': exercise.points,
            'feedback': feedback,
            'passed': False
        }
    
    # Compare outputs
    passed, similarity = compare_outputs(expected_out, student_out)
    
    if passed:
        return {
            'score': exercise.points,
            'max_points': exercise.points,
            'feedback': "✓ Correct!",
            'passed': True
        }
    
    # Award partial credit if enabled
    if exercise.partial_credit and similarity > 0.5:
        partial_score = int(exercise.points * similarity)
        feedback = f"Partially correct ({similarity*100:.0f}% of expected output)"
        if exercise.hints:
            feedback += f"\nHint: {exercise.hints[0]}"
        return {
            'score': partial_score,
            'max_points': exercise.points,
            'feedback': feedback,
            'passed': False
        }
    
    # Incorrect
    feedback = "Incorrect output"
    if exercise.hints:
        feedback += f"\nHint: {exercise.hints[0]}"
    return {
        'score': 0,
        'max_points': exercise.points,
        'feedback': feedback,
        'passed': False
    }


# ═══════════════════════════════════════════════════════════════════════════════
# MAIN FUNCTIONS
# ═══════════════════════════════════════════════════════════════════════════════

def grade_submission(
    submission_file: Path,
    verbose: bool = False
) -> Dict[str, Any]:
    """
    Grade a complete student submission file.
    
    Expected submission format (JSON):
    {
        "student_id": "123456",
        "solutions": {
            "G1": "grep ' 404 ' access.log",
            "G2": "grep -c 'POST' access.log",
            ...
        }
    }
    
    Args:
        submission_file: Path to JSON submission file
        verbose: If True, print debug information
        
    Returns:
        Dictionary with grading results
    """
    try:
        with open(submission_file, encoding='utf-8') as f:
            submission = json.load(f)
    except Exception as e:
        return {
            'error': f"Cannot read file: {e}",
            'total_score': 0,
            'max_score': 0
        }
    
    student_id = submission.get('student_id', 'UNKNOWN')
    solutions = submission.get('solutions', {})
    
    results: Dict[str, Any] = {
        'student_id': student_id,
        'exercises': {},
        'total_score': 0,
        'max_score': 0
    }
    
    for ex_id, student_cmd in solutions.items():
        result = evaluate_exercise(ex_id, student_cmd, verbose)
        results['exercises'][ex_id] = result
        results['total_score'] += result['score']
        results['max_score'] += result['max_points']
    
    return results


def print_results(results: Dict[str, Any]) -> None:
    """
    Display grading results in a formatted table.
    
    Args:
        results: Dictionary from grade_submission()
    """
    print("\n" + "=" * 60)
    print(f"AUTOGRADER RESULTS - Student: {results.get('student_id', 'N/A')}")
    print("=" * 60)
    
    if 'error' in results:
        print(f"\n❌ ERROR: {results['error']}")
        return
    
    for ex_id, ex_result in results['exercises'].items():
        status = "✓" if ex_result['passed'] else "✗"
        print(f"\n{status} {ex_id}: {ex_result['score']}/{ex_result['max_points']} points")
        print(f"   {ex_result['feedback']}")
    
    print("\n" + "-" * 60)
    max_score = results['max_score']
    total_score = results['total_score']
    percentage = (total_score / max_score * 100) if max_score > 0 else 0
    print(f"TOTAL: {total_score}/{max_score} ({percentage:.1f}%)")
    print("=" * 60)


def self_test() -> bool:
    """
    Run self-test to verify autograder functionality.
    
    Creates a temporary submission and grades it to ensure
    the autograder works correctly.
    
    Returns:
        True if all tests pass, False otherwise
    """
    print("Running self-test...")
    
    # Create test submission
    test_submission = {
        "student_id": "TEST",
        "solutions": {
            "G1": "grep ' 404 ' access.log",
            "G2": "grep -c 'POST' access.log",
            "S1": "sed 's/localhost/127.0.0.1/g' config.txt"
        }
    }
    
    with tempfile.NamedTemporaryFile(
        mode='w',
        suffix='.json',
        delete=False,
        encoding='utf-8'
    ) as f:
        json.dump(test_submission, f)
        temp_file = f.name
    
    try:
        results = grade_submission(Path(temp_file), verbose=True)
        print_results(results)
        
        if results['total_score'] > 0:
            print("\n✅ Self-test passed!")
            return True
        else:
            print("\n⚠️ Self-test completed but no points scored.")
            print("   Ensure data files exist (run setup_seminar.sh)")
            return False
    finally:
        os.unlink(temp_file)


# ═══════════════════════════════════════════════════════════════════════════════
# MAIN
# ═══════════════════════════════════════════════════════════════════════════════

def main() -> None:
    """Main entry point for the autograder."""
    if len(sys.argv) < 2:
        print(__doc__)
        sys.exit(1)
    
    if sys.argv[1] == '--self-test':
        logger.info("Running self-test...")
        success = self_test()
        sys.exit(0 if success else 1)
    
    submission_file = Path(sys.argv[1])
    verbose = '--verbose' in sys.argv or '-v' in sys.argv
    
    if not submission_file.exists():
        logger.error(f"File not found: {submission_file}")
        print(f"Error: File not found: {submission_file}")
        sys.exit(1)
    
    logger.info(f"Grading submission: {submission_file}")
    results = grade_submission(submission_file, verbose)
    print_results(results)
    logger.info(f"Grading complete: {results['total_score']}/{results['max_score']} points")


if __name__ == '__main__':
    main()
