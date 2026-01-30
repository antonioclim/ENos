#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
═══════════════════════════════════════════════════════════════════════════════
Quiz Runner - Interactive Formative Assessment
═══════════════════════════════════════════════════════════════════════════════

DESCRIPTION:
    Interactive runner for formative quizzes in YAML format.
    Displays questions, collects answers and calculates the score.

USAGE:
    python3 quiz_runner.py formative/quiz.yaml
    python3 quiz_runner.py --shuffle formative/quiz.yaml
    python3 quiz_runner.py --limit 10 formative/quiz.yaml

AUTHOR: OS Pedagogical Kit | Bucharest UES - CSIE
VERSION: 1.0 | January 2025
═══════════════════════════════════════════════════════════════════════════════
"""

import sys
import random
import argparse
from pathlib import Path
from typing import Dict, List, Any, Optional
from dataclasses import dataclass, field
from datetime import datetime
import json

# Dependency check
try:
    import yaml
except ImportError:
    print("Error: The 'pyyaml' module is not installed.")
    print("Run: pip install pyyaml --break-system-packages")
    sys.exit(1)


# ═══════════════════════════════════════════════════════════════════════════════
# COLOUR CONFIGURATION
# ═══════════════════════════════════════════════════════════════════════════════

class Colors:
    """ANSI colours for terminal."""
    RED = '\033[1;31m'
    GREEN = '\033[1;32m'
    YELLOW = '\033[1;33m'
    BLUE = '\033[1;34m'
    MAGENTA = '\033[1;35m'
    CYAN = '\033[1;36m'
    WHITE = '\033[1;37m'
    DIM = '\033[2m'
    RESET = '\033[0m'
    BOLD = '\033[1m'

    @classmethod
    def disable(cls) -> None:
        """Disable colours for non-TTY output."""
        for attr in dir(cls):
            if attr.isupper() and not attr.startswith('_'):
                setattr(cls, attr, '')


if not sys.stdout.isatty():
    Colors.disable()


# ═══════════════════════════════════════════════════════════════════════════════
# DATA STRUCTURES
# ═══════════════════════════════════════════════════════════════════════════════

@dataclass
class QuizResult:
    """Result of a completed quiz."""
    total_questions: int = 0
    correct_answers: int = 0
    wrong_answers: int = 0
    score_percent: float = 0.0
    bloom_breakdown: Dict[str, Dict[str, int]] = field(default_factory=dict)
    category_breakdown: Dict[str, Dict[str, int]] = field(default_factory=dict)
    time_started: str = ""
    time_finished: str = ""
    answers: List[Dict[str, Any]] = field(default_factory=list)


# ═══════════════════════════════════════════════════════════════════════════════
# UTILITY FUNCTIONS
# ═══════════════════════════════════════════════════════════════════════════════

def clear_screen() -> None:
    """Clear the terminal screen."""
    print("\033[2J\033[H", end="")


def print_header(title: str) -> None:
    """Display a formatted header."""
    width = 70
    print(f"\n{Colors.CYAN}{'═' * width}{Colors.RESET}")
    print(f"{Colors.BOLD}{Colors.WHITE}{title.center(width)}{Colors.RESET}")
    print(f"{Colors.CYAN}{'═' * width}{Colors.RESET}\n")


def print_question(num: int, total: int, question: Dict[str, Any]) -> None:
    """Display a formatted question."""
    bloom = question.get('bloom', 'unknown').upper()
    category = question.get('categorie', 'general')
    
    bloom_colors = {
        'REMEMBER': Colors.GREEN,
        'UNDERSTAND': Colors.BLUE,
        'APPLY': Colors.YELLOW,
        'ANALYSE': Colors.MAGENTA,
        'EVALUATE': Colors.RED,
        'CREATE': Colors.CYAN
    }
    bloom_color = bloom_colors.get(bloom, Colors.WHITE)
    
    print(f"{Colors.DIM}─────────────────────────────────────────────────────{Colors.RESET}")
    print(f"{Colors.BOLD}Question {num}/{total}{Colors.RESET} "
          f"[{bloom_color}{bloom}{Colors.RESET}] "
          f"[{Colors.DIM}{category}{Colors.RESET}]")
    print(f"{Colors.DIM}─────────────────────────────────────────────────────{Colors.RESET}\n")
    
    # Question text
    text = question.get('text', '').strip()
    print(f"{text}\n")
    
    # Options
    options = question.get('optiuni', [])
    for i, opt in enumerate(options):
        letter = chr(65 + i)  # A, B, C, D
        print(f"  {Colors.BOLD}{letter}){Colors.RESET} {opt}")
    print()


def get_answer(num_options: int) -> int:
    """Get the user's answer."""
    valid_letters = [chr(65 + i) for i in range(num_options)]
    valid_input = valid_letters + [str(i) for i in range(num_options)]
    
    while True:
        try:
            prompt = f"{Colors.YELLOW}Your answer ({'/'.join(valid_letters)}): {Colors.RESET}"
            answer = input(prompt).strip().upper()
            
            if answer in valid_letters:
                return ord(answer) - 65
            elif answer.isdigit() and 0 <= int(answer) < num_options:
                return int(answer)
            else:
                print(f"{Colors.RED}Invalid answer. Enter {'/'.join(valid_letters)}.{Colors.RESET}")
        except (KeyboardInterrupt, EOFError):
            print(f"\n{Colors.YELLOW}Quiz interrupted.{Colors.RESET}")
            sys.exit(0)


def show_feedback(question: Dict[str, Any], user_answer: int, correct: bool) -> None:
    """Display feedback after answering."""
    correct_idx = question.get('corect', 0)
    options = question.get('optiuni', [])
    
    if correct:
        print(f"{Colors.GREEN}✓ CORRECT!{Colors.RESET}")
    else:
        correct_letter = chr(65 + correct_idx)
        correct_text = options[correct_idx] if correct_idx < len(options) else "?"
        print(f"{Colors.RED}✗ WRONG!{Colors.RESET}")
        print(f"  Correct answer: {Colors.GREEN}{correct_letter}) {correct_text}{Colors.RESET}")
    
    # Explanation
    explicatie = question.get('explicatie', '').strip()
    if explicatie:
        print(f"\n{Colors.CYAN}Explanation:{Colors.RESET}")
        for line in explicatie.split('\n'):
            print(f"  {line}")
    
    # Misconceptions (if incorrect)
    if not correct:
        misconceptii = question.get('misconceptii', {})
        if str(user_answer) in misconceptii:
            misc = misconceptii[str(user_answer)]
            print(f"\n{Colors.YELLOW}Why you got it wrong:{Colors.RESET} {misc}")
    
    print()
    input(f"{Colors.DIM}Press Enter to continue...{Colors.RESET}")


def print_results(result: QuizResult, quiz_title: str) -> None:
    """Display the final results."""
    clear_screen()
    print_header("FINAL RESULTS")
    
    print(f"{Colors.BOLD}Quiz:{Colors.RESET} {quiz_title}\n")
    
    # Overall score
    if result.score_percent >= 90:
        score_color = Colors.GREEN
        grade = "EXCELLENT"
    elif result.score_percent >= 75:
        score_color = Colors.BLUE
        grade = "GOOD"
    elif result.score_percent >= 60:
        score_color = Colors.YELLOW
        grade = "SATISFACTORY"
    else:
        score_color = Colors.RED
        grade = "NEEDS IMPROVEMENT"
    
    print(f"{Colors.BOLD}Score:{Colors.RESET} {score_color}{result.correct_answers}/{result.total_questions} "
          f"({result.score_percent:.1f}%){Colors.RESET}")
    print(f"{Colors.BOLD}Grade:{Colors.RESET} {score_color}{grade}{Colors.RESET}\n")
    
    # Breakdown by Bloom levels
    if result.bloom_breakdown:
        print(f"{Colors.BOLD}Performance by cognitive levels:{Colors.RESET}")
        for bloom, stats in sorted(result.bloom_breakdown.items()):
            correct = stats.get('correct', 0)
            total = stats.get('total', 0)
            if total > 0:
                pct = (correct / total) * 100
                bar_len = int(pct / 5)
                bar = '█' * bar_len + '░' * (20 - bar_len)
                print(f"  {bloom.upper():12} {bar} {correct}/{total} ({pct:.0f}%)")
        print()
    
    # Breakdown by categories
    if result.category_breakdown:
        print(f"{Colors.BOLD}Performance by categories:{Colors.RESET}")
        for cat, stats in sorted(result.category_breakdown.items()):
            correct = stats.get('correct', 0)
            total = stats.get('total', 0)
            if total > 0:
                pct = (correct / total) * 100
                status = "✓" if pct >= 70 else "△" if pct >= 50 else "✗"
                color = Colors.GREEN if pct >= 70 else Colors.YELLOW if pct >= 50 else Colors.RED
                print(f"  {color}{status}{Colors.RESET} {cat}: {correct}/{total} ({pct:.0f}%)")
        print()
    
    # Time
    print(f"{Colors.DIM}Started: {result.time_started}{Colors.RESET}")
    print(f"{Colors.DIM}Finished: {result.time_finished}{Colors.RESET}")


def save_results(result: QuizResult, output_path: Path) -> None:
    """Save results in JSON format."""
    data = {
        'total_questions': result.total_questions,
        'correct_answers': result.correct_answers,
        'wrong_answers': result.wrong_answers,
        'score_percent': result.score_percent,
        'bloom_breakdown': result.bloom_breakdown,
        'category_breakdown': result.category_breakdown,
        'time_started': result.time_started,
        'time_finished': result.time_finished,
        'answers': result.answers
    }
    
    with open(output_path, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    
    print(f"{Colors.GREEN}Results saved to: {output_path}{Colors.RESET}")


# ═══════════════════════════════════════════════════════════════════════════════
# MAIN FUNCTION
# ═══════════════════════════════════════════════════════════════════════════════

def run_quiz(quiz_path: Path, shuffle: bool = False, limit: Optional[int] = None) -> QuizResult:
    """Run the interactive quiz."""
    
    # Load the quiz
    with open(quiz_path, 'r', encoding='utf-8') as f:
        quiz_data = yaml.safe_load(f)
    
    metadata = quiz_data.get('metadata', {})
    questions = quiz_data.get('intrebari', [])
    
    if not questions:
        print(f"{Colors.RED}Error: The quiz contains no questions.{Colors.RESET}")
        sys.exit(1)
    
    # Shuffle if requested
    if shuffle:
        questions = questions.copy()
        random.shuffle(questions)
    
    # Limit the number of questions
    if limit and limit < len(questions):
        questions = questions[:limit]
    
    # Initialise result
    result = QuizResult()
    result.total_questions = len(questions)
    result.time_started = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    
    # Header
    clear_screen()
    quiz_title = metadata.get('subiect', 'Formative Quiz')
    print_header(f"📝 {quiz_title}")
    
    print(f"Total questions: {len(questions)}")
    print(f"Estimated time: {metadata.get('timp_estimat_minute', 20)} minutes")
    print(f"\nAnswer with the corresponding letter (A, B, C, D).")
    print(f"You can exit at any time with Ctrl+C.\n")
    input(f"{Colors.CYAN}Press Enter to begin...{Colors.RESET}")
    
    # Run through questions
    for i, question in enumerate(questions, 1):
        clear_screen()
        print_question(i, len(questions), question)
        
        num_options = len(question.get('optiuni', []))
        user_answer = get_answer(num_options)
        
        correct_idx = question.get('corect', 0)
        is_correct = (user_answer == correct_idx)
        
        # Update statistics
        if is_correct:
            result.correct_answers += 1
        else:
            result.wrong_answers += 1
        
        # Bloom breakdown
        bloom = question.get('bloom', 'unknown')
        if bloom not in result.bloom_breakdown:
            result.bloom_breakdown[bloom] = {'correct': 0, 'total': 0}
        result.bloom_breakdown[bloom]['total'] += 1
        if is_correct:
            result.bloom_breakdown[bloom]['correct'] += 1
        
        # Category breakdown
        category = question.get('categorie', 'general')
        if category not in result.category_breakdown:
            result.category_breakdown[category] = {'correct': 0, 'total': 0}
        result.category_breakdown[category]['total'] += 1
        if is_correct:
            result.category_breakdown[category]['correct'] += 1
        
        # Save answer
        result.answers.append({
            'question_id': question.get('id', f'q{i}'),
            'user_answer': user_answer,
            'correct_answer': correct_idx,
            'is_correct': is_correct
        })
        
        # Feedback
        show_feedback(question, user_answer, is_correct)
    
    # Finalise
    result.time_finished = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    result.score_percent = (result.correct_answers / result.total_questions) * 100
    
    return result


def main() -> None:
    """Entry point."""
    parser = argparse.ArgumentParser(
        description='Quiz Runner - Interactive Formative Assessment',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python3 quiz_runner.py quiz.yaml
  python3 quiz_runner.py --shuffle quiz.yaml
  python3 quiz_runner.py --limit 10 --output results.json quiz.yaml
        """
    )
    
    parser.add_argument('quiz_file', type=Path, help='YAML file containing the quiz')
    parser.add_argument('--shuffle', action='store_true', help='Shuffle the questions')
    parser.add_argument('--limit', type=int, help='Limit the number of questions')
    parser.add_argument('--output', type=Path, help='Save results to JSON')
    parser.add_argument('--no-color', action='store_true', help='Disable colours')
    
    args = parser.parse_args()
    
    if args.no_color:
        Colors.disable()
    
    if not args.quiz_file.exists():
        print(f"{Colors.RED}Error: The file '{args.quiz_file}' does not exist.{Colors.RESET}")
        sys.exit(1)
    
    try:
        result = run_quiz(args.quiz_file, args.shuffle, args.limit)
        
        # Display results
        quiz_title = "Formative Quiz"
        try:
            with open(args.quiz_file, 'r', encoding='utf-8') as f:
                data = yaml.safe_load(f)
                quiz_title = data.get('metadata', {}).get('subiect', quiz_title)
        except Exception:
            pass
        
        print_results(result, quiz_title)
        
        # Save if requested
        if args.output:
            save_results(result, args.output)
            
    except KeyboardInterrupt:
        print(f"\n{Colors.YELLOW}Quiz interrupted by user.{Colors.RESET}")
        sys.exit(0)


if __name__ == '__main__':
    main()
