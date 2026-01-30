#!/usr/bin/env python3
"""
quiz_runner.py — Interactive formative quiz runner

Loads quiz questions from YAML format and runs an interactive
command-line quiz session with immediate feedback.

Operating Systems | ASE Bucharest - CSIE
Seminar 04: Text Processing

Usage:
    python3 quiz_runner.py quiz.yaml
    python3 quiz_runner.py quiz.yaml --shuffle
    python3 quiz_runner.py quiz.yaml --category understand
    python3 quiz_runner.py --self-test

Author: Operating Systems Course
Version: 1.1
"""

import sys
import random
from pathlib import Path
from dataclasses import dataclass, field
from typing import Optional, Dict, List, Tuple, Any

# ═══════════════════════════════════════════════════════════════════════════════
# CONFIGURATION
# ═══════════════════════════════════════════════════════════════════════════════

YAML_AVAILABLE = False
try:
    import yaml
    YAML_AVAILABLE = True
except ImportError:
    pass


@dataclass
class Question:
    """
    Represents a single quiz question.
    
    Attributes:
        id: Unique question identifier (e.g., 'R1', 'U3')
        type: Question type ('mcq', 'predict', 'fill')
        bloom: Bloom taxonomy level
        text: Question text/prompt
        score: Points for correct answer
        lo: List of learning outcomes this question addresses
        options: Answer options for MCQ/predict types
        correct: Index of correct option (0-based)
        explanation: Explanation shown after answering
        correct_answer: Expected answer for fill-in questions
        misconceptions: Dictionary mapping wrong answers to misconception IDs
    """
    id: str
    type: str
    bloom: str
    text: str
    score: int
    lo: List[str] = field(default_factory=list)
    options: List[str] = field(default_factory=list)
    correct: int = 0
    explanation: str = ""
    correct_answer: str = ""
    misconceptions: Dict[int, str] = field(default_factory=dict)


@dataclass
class QuizResult:
    """
    Stores results from a completed quiz session.
    
    Attributes:
        total_score: Maximum possible score
        score_obtained: Actual score achieved
        correct_answers: Number of questions answered correctly
        total_questions: Total number of questions
        details: List of per-question results
    """
    total_score: int
    score_obtained: int
    correct_answers: int
    total_questions: int
    details: List[Dict[str, Any]] = field(default_factory=list)


# ═══════════════════════════════════════════════════════════════════════════════
# QUIZ LOADING
# ═══════════════════════════════════════════════════════════════════════════════

def load_quiz(filepath: str) -> Tuple[Dict[str, Any], List[Question]]:
    """
    Load quiz data from a YAML file.
    
    Supports both English and Romanian field names for compatibility
    with different material versions.
    
    Args:
        filepath: Path to the YAML quiz file
        
    Returns:
        Tuple of (metadata dict, list of Question objects)
        
    Raises:
        SystemExit: If YAML library not available or file not found
    """
    if not YAML_AVAILABLE:
        print("ERROR: The 'pyyaml' library is not installed.")
        print("Run: pip install pyyaml --break-system-packages")
        sys.exit(1)
    
    path = Path(filepath)
    if not path.exists():
        print(f"ERROR: File '{filepath}' not found.")
        sys.exit(1)
    
    with open(path, 'r', encoding='utf-8') as f:
        data = yaml.safe_load(f)
    
    metadata = data.get('metadata', {})
    questions: List[Question] = []
    
    # Support both English and Romanian field names
    questions_data = data.get('questions', data.get('intrebari', []))
    
    for q_data in questions_data:
        q = Question(
            id=q_data.get('id', ''),
            type=q_data.get('type', q_data.get('tip', 'mcq')),
            bloom=q_data.get('bloom', ''),
            text=q_data.get('text', '').strip(),
            score=q_data.get('score', q_data.get('punctaj', 0)),
            lo=q_data.get('lo', []),
            options=q_data.get('options', q_data.get('optiuni', [])),
            correct=q_data.get('correct', q_data.get('corect', 0)),
            explanation=q_data.get('explanation', q_data.get('explicatie', '')).strip(),
            correct_answer=q_data.get('correct_answer', q_data.get('raspuns_corect', '')),
            misconceptions=q_data.get('misconceptions', q_data.get('misconceptii', {}))
        )
        questions.append(q)
    
    return metadata, questions


# ═══════════════════════════════════════════════════════════════════════════════
# QUIZ DISPLAY AND INTERACTION
# ═══════════════════════════════════════════════════════════════════════════════

def display_question(q: Question, index: int, total: int) -> None:
    """
    Display a question in the terminal with formatting.
    
    Args:
        q: Question object to display
        index: Current question number (1-based)
        total: Total number of questions
    """
    print("\n" + "═" * 70)
    print(f"  Question {index}/{total} | {q.bloom.upper()} | {q.score} points")
    print("═" * 70)
    print(f"\n{q.text}")
    
    if q.type in ('mcq', 'predict'):
        print()
        for i, opt in enumerate(q.options):
            print(f"  [{chr(65 + i)}] {opt}")
    elif q.type == 'fill':
        print("\n  [Enter your answer]")


def get_user_answer(q: Question) -> str:
    """
    Prompt user for their answer and validate input.
    
    Args:
        q: Question being answered
        
    Returns:
        User's answer (letter for MCQ, text for fill-in)
    """
    if q.type in ('mcq', 'predict'):
        valid = [chr(65 + i) for i in range(len(q.options))]
        while True:
            ans = input(f"\nYour answer ({'/'.join(valid)}): ").strip().upper()
            if ans in valid:
                return ans
            print(f"  Please enter one of: {', '.join(valid)}")
    else:
        return input("\nYour answer: ").strip()


def check_answer(q: Question, answer: str) -> Tuple[bool, str]:
    """
    Check if an answer is correct.
    
    Args:
        q: Question being checked
        answer: User's answer
        
    Returns:
        Tuple of (is_correct, feedback_message)
    """
    if q.type in ('mcq', 'predict'):
        user_idx = ord(answer) - 65
        is_correct = (user_idx == q.correct)
        correct_letter = chr(65 + q.correct)
        feedback = f"Correct answer: [{correct_letter}] {q.options[q.correct]}"
    else:
        is_correct = (answer.lower() == q.correct_answer.lower())
        feedback = f"Correct answer: {q.correct_answer}"
    
    return is_correct, feedback


# ═══════════════════════════════════════════════════════════════════════════════
# QUIZ EXECUTION
# ═══════════════════════════════════════════════════════════════════════════════

def run_quiz(
    questions: List[Question],
    shuffle: bool = False,
    category: Optional[str] = None
) -> QuizResult:
    """
    Run an interactive quiz session.
    
    Args:
        questions: List of Question objects
        shuffle: If True, randomise question order
        category: If set, filter to only this Bloom level
        
    Returns:
        QuizResult with session statistics
    """
    # Filter by category if specified
    if category:
        questions = [q for q in questions if q.bloom == category]
    
    # Shuffle if requested
    if shuffle:
        questions = random.sample(questions, len(questions))
    
    if not questions:
        print("No questions available for the selected criteria.")
        sys.exit(1)
    
    total_score = sum(q.score for q in questions)
    score_obtained = 0
    correct_answers = 0
    details: List[Dict[str, Any]] = []
    
    # Display header
    print("\n" + "╔" + "═" * 68 + "╗")
    print("║" + "  FORMATIVE QUIZ: TEXT PROCESSING".center(68) + "║")
    print("║" + f"  {len(questions)} questions | {total_score} points".center(68) + "║")
    print("╚" + "═" * 68 + "╝")
    
    # Run through questions
    for i, q in enumerate(questions, 1):
        display_question(q, i, len(questions))
        answer = get_user_answer(q)
        is_correct, feedback = check_answer(q, answer)
        
        if is_correct:
            print("\n  ✅ CORRECT!")
            score_obtained += q.score
            correct_answers += 1
        else:
            print("\n  ❌ INCORRECT")
            print(f"  {feedback}")
        
        if q.explanation:
            # Truncate long explanations for display
            explanation = q.explanation[:200]
            if len(q.explanation) > 200:
                explanation += "..."
            print(f"\n  📝 Explanation: {explanation}")
        
        details.append({
            'id': q.id,
            'correct': is_correct,
            'score': q.score if is_correct else 0
        })
        
        input("\n  [Press Enter to continue...]")
    
    return QuizResult(
        total_score=total_score,
        score_obtained=score_obtained,
        correct_answers=correct_answers,
        total_questions=len(questions),
        details=details
    )


def display_results(result: QuizResult) -> None:
    """
    Display final quiz results with feedback.
    
    Args:
        result: QuizResult from completed quiz
    """
    percent = (result.score_obtained / result.total_score * 100) if result.total_score > 0 else 0
    
    print("\n" + "╔" + "═" * 68 + "╗")
    print("║" + "  FINAL RESULTS".center(68) + "║")
    print("╠" + "═" * 68 + "╣")
    print(f"║  Score: {result.score_obtained}/{result.total_score} ({percent:.1f}%)".ljust(69) + "║")
    print(f"║  Correct answers: {result.correct_answers}/{result.total_questions}".ljust(69) + "║")
    print("╠" + "═" * 68 + "╣")
    
    # Provide feedback based on score
    if percent >= 90:
        msg = "Excellent! You have mastered text processing at an advanced level."
    elif percent >= 70:
        msg = "Good! You have understood the main concepts."
    elif percent >= 50:
        msg = "Satisfactory. You need more practice."
    else:
        msg = "Needs improvement. Review the material."
    
    print(f"║  {msg}".ljust(69) + "║")
    print("╚" + "═" * 68 + "╝")


# ═══════════════════════════════════════════════════════════════════════════════
# SELF-TEST
# ═══════════════════════════════════════════════════════════════════════════════

def self_test() -> bool:
    """
    Run internal tests to verify quiz runner functionality.
    
    Returns:
        True if all tests pass, False otherwise
    """
    print("Running self-test...")
    
    # Test 1: Create Question
    q = Question(
        id="T1", type="mcq", bloom="remember",
        text="Test?", score=5,
        options=["A", "B", "C"], correct=1
    )
    assert q.id == "T1", "Test 1 FAILED: id"
    assert q.correct == 1, "Test 1 FAILED: correct"
    print("  ✅ Test 1: Create Question - OK")
    
    # Test 2: Check correct MCQ answer
    is_correct, _ = check_answer(q, "B")
    assert is_correct, "Test 2 FAILED: correct answer should be True"
    print("  ✅ Test 2: Check correct answer - OK")
    
    # Test 3: Check incorrect MCQ answer
    is_correct, _ = check_answer(q, "A")
    assert not is_correct, "Test 3 FAILED: wrong answer should be False"
    print("  ✅ Test 3: Check wrong answer - OK")
    
    # Test 4: Fill-in case-insensitive matching
    q_fill = Question(
        id="T4", type="fill", bloom="apply",
        text="Fill test", score=5,
        correct_answer="answer"
    )
    is_correct, _ = check_answer(q_fill, "ANSWER")
    assert is_correct, "Test 4 FAILED: fill should be case-insensitive"
    print("  ✅ Test 4: Fill-in case-insensitive - OK")
    
    # Test 5: QuizResult creation
    result = QuizResult(
        total_score=100,
        score_obtained=75,
        correct_answers=8,
        total_questions=10
    )
    assert result.total_score == 100, "Test 5 FAILED: total_score"
    assert result.score_obtained == 75, "Test 5 FAILED: score_obtained"
    print("  ✅ Test 5: QuizResult creation - OK")
    
    print("\n✅ All tests passed!")
    return True


# ═══════════════════════════════════════════════════════════════════════════════
# MAIN
# ═══════════════════════════════════════════════════════════════════════════════

def main() -> None:
    """Main entry point for the quiz runner."""
    if len(sys.argv) < 2:
        print("Usage: python3 quiz_runner.py quiz.yaml [--shuffle] [--category BLOOM]")
        print("       python3 quiz_runner.py --self-test")
        sys.exit(1)
    
    if sys.argv[1] == '--self-test':
        success = self_test()
        sys.exit(0 if success else 1)
    
    filepath = sys.argv[1]
    shuffle = '--shuffle' in sys.argv
    
    category: Optional[str] = None
    if '--category' in sys.argv:
        idx = sys.argv.index('--category')
        if idx + 1 < len(sys.argv):
            category = sys.argv[idx + 1]
    
    metadata, questions = load_quiz(filepath)
    result = run_quiz(questions, shuffle=shuffle, category=category)
    display_results(result)


if __name__ == '__main__':
    main()
