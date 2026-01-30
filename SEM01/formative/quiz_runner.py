#!/usr/bin/env python3
"""
Quiz Runner - Runs YAML quizzes in the terminal.
Operating Systems | ASE Bucharest - CSIE
"""

import argparse
import random
import sys
from pathlib import Path
from typing import Optional

try:
    import yaml
except ImportError:
    print("Error: PyYAML is not installed.")
    print("Run: pip install pyyaml")
    sys.exit(1)


class Colours:
    """ANSI codes for terminal colours."""
    GREEN = '\033[92m'
    RED = '\033[91m'
    YELLOW = '\033[93m'
    BLUE = '\033[94m'
    BOLD = '\033[1m'
    RESET = '\033[0m'


def colorize(text: str, color: str, use_color: bool) -> str:
    """Apply colour to text if enabled."""
    if use_color:
        return f"{color}{text}{Colours.RESET}"
    return text


def load_quiz(quiz_path: Path) -> dict:
    """Load the quiz from the YAML file."""
    with open(quiz_path, 'r', encoding='utf-8') as f:
        return yaml.safe_load(f)


def display_question(q: dict, index: int, total: int, use_color: bool) -> None:
    """Display a question with its options."""
    print(f"\n{'─' * 50}")
    bloom = q.get('bloom', 'N/A').upper()
    print(colorize(f"Question {index}/{total}", Colours.BOLD, use_color))
    print(f"[Bloom: {bloom}]")
    print()
    print(colorize(q['text'], Colours.YELLOW, use_color))
    print()
    
    for opt in q['options']:
        print(f"  {opt}")


def get_answer(num_options: int) -> str:
    """Get the user's answer with validation."""
    valid = [chr(ord('A') + i) for i in range(num_options)]
    while True:
        answer = input("\nYour answer: ").strip().upper()
        if answer in valid:
            return answer
        print(f"Invalid answer. Choose from: {', '.join(valid)}")


def show_feedback(q: dict, answer: str, use_color: bool) -> bool:
    """Display feedback for the answer and return True if correct."""
    correct = q['correct']
    is_correct = (answer == correct)
    
    if is_correct:
        print(colorize("\n✓ CORRECT!", Colours.GREEN, use_color))
    else:
        print(colorize(f"\n✗ WRONG! The correct answer: {correct}", Colours.RED, use_color))
    
    print(f"\nExplanation: {q['explanation']}")
    return is_correct


def prepare_questions(questions: list, shuffle: bool, limit: Optional[int]) -> list:
    """Prepare the list of questions (shuffle and limit)."""
    if shuffle:
        questions = questions.copy()
        random.shuffle(questions)
    if limit and limit < len(questions):
        questions = questions[:limit]
    return questions


def show_quiz_header(meta: dict, total: int, use_color: bool) -> None:
    """Display the quiz header."""
    print("\n" + "═" * 60)
    title = meta.get('title', 'Formative Quiz')
    print(colorize(f"  QUIZ: {title}", Colours.BOLD, use_color))
    print(f"  Questions: {total} | Estimated time: {meta.get('estimated_time', 'N/A')}")
    print("═" * 60)


def show_final_score(score: int, total: int, use_color: bool) -> None:
    """Display the final score with appropriate message."""
    percentage = (score / total) * 100
    print("\n" + "═" * 60)
    
    if percentage >= 80:
        result_color = Colours.GREEN
        message = "Excellent!"
    elif percentage >= 60:
        result_color = Colours.YELLOW
        message = "Good, but revise the concepts you got wrong."
    else:
        result_color = Colours.RED
        message = "Recommendation: review the material and try again."
    
    print(colorize(f"  FINAL SCORE: {score}/{total} ({percentage:.0f}%)", result_color, use_color))
    print(f"  {message}")
    print("═" * 60 + "\n")


def run_quiz(quiz: dict, shuffle: bool, limit: Optional[int], use_color: bool) -> None:
    """Run the interactive quiz."""
    meta = quiz.get('metadata', {})
    questions = quiz.get('questions', [])
    
    if not questions:
        print("Error: The quiz contains no questions.")
        sys.exit(1)
    
    questions = prepare_questions(questions, shuffle, limit)
    total = len(questions)
    
    show_quiz_header(meta, total, use_color)
    input("\nPress ENTER to begin...")
    
    score = 0
    for i, q in enumerate(questions, 1):
        display_question(q, i, total, use_color)
        answer = get_answer(len(q['options']))
        if show_feedback(q, answer, use_color):
            score += 1
        if i < total:
            input("\nPress ENTER for the next question...")
    
    show_final_score(score, total, use_color)


def main() -> None:
    """Main entry point."""
    parser = argparse.ArgumentParser(
        description='Run YAML quizzes in the terminal.'
    )
    parser.add_argument(
        'quiz_file',
        nargs='?',
        default='quiz.yaml',
        help='Path to the quiz file (default: quiz.yaml)'
    )
    parser.add_argument('--shuffle', action='store_true', help='Shuffle the questions')
    parser.add_argument('--limit', type=int, help='Limit the number of questions')
    parser.add_argument('--no-color', action='store_true', help='Disable colours')
    
    args = parser.parse_args()
    
    quiz_path = Path(args.quiz_file)
    if not quiz_path.exists():
        print(f"Error: The file '{quiz_path}' does not exist.")
        sys.exit(1)
    
    quiz = load_quiz(quiz_path)
    run_quiz(quiz, args.shuffle, args.limit, not args.no_color)


if __name__ == '__main__':
    main()
