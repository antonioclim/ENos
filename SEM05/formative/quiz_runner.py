#!/usr/bin/env python3
"""
quiz_runner.py — Runner for YAML Quizzes

Operating Systems | ASE Bucharest - CSIE
Seminar 05: Advanced Bash Scripting

USAGE:
    python3 quiz_runner.py quiz.yaml
    python3 quiz_runner.py quiz.yaml --shuffle
    python3 quiz_runner.py quiz.yaml --category functii

DEPENDENCIES:
    pip install pyyaml rich
"""

import argparse
import json
import random
import sys
from dataclasses import dataclass, field
from datetime import datetime
from pathlib import Path
from typing import Optional

try:
    import yaml
except ImportError:
    print("Error: PyYAML is not installed. Run: pip install pyyaml")
    sys.exit(1)

try:
    from rich.console import Console
    from rich.panel import Panel
    from rich.syntax import Syntax
    from rich.table import Table
    RICH_AVAILABLE = True
except ImportError:
    RICH_AVAILABLE = False


@dataclass
class QuizResult:
    """Result of a quiz."""
    total_questions: int = 0
    correct_answers: int = 0
    answers: list = field(default_factory=list)
    start_time: str = ""
    end_time: str = ""
    categories_score: dict = field(default_factory=dict)
    bloom_score: dict = field(default_factory=dict)


class QuizRunner:
    """Runner for YAML quizzes."""

    def __init__(self, quiz_path: str, use_rich: bool = True):
        self.quiz_path = Path(quiz_path)
        self.quiz_data = self._load_quiz()
        self.result = QuizResult()
        self.use_rich = use_rich and RICH_AVAILABLE
        if self.use_rich:
            self.console = Console()

    def _load_quiz(self) -> dict:
        """Load quiz from YAML file."""
        if not self.quiz_path.exists():
            print(f"Error: File {self.quiz_path} does not exist.")
            sys.exit(1)
        with open(self.quiz_path, 'r', encoding='utf-8') as f:
            return yaml.safe_load(f)

    def _print_header(self):
        """Display quiz header."""
        meta = self.quiz_data.get('metadata', {})
        if self.use_rich:
            title = f"[bold blue]{meta.get('title', 'Quiz')}[/bold blue]"
            subtitle = meta.get('subtitle', '')
            self.console.print()
            self.console.print(Panel(
                f"{title}\n{subtitle}\n\n"
                f"Estimated time: {meta.get('duration_minutes', 20)} minutes\n"
                f"Questions: {len(self.quiz_data.get('questions', []))}",
                title="Formative Quiz", border_style="blue"
            ))
        else:
            print("\n" + "=" * 60)
            print(f"  {meta.get('title', 'Quiz')}")
            print(f"  Estimated time: {meta.get('duration_minutes', 20)} minutes")
            print("=" * 60 + "\n")

    def _display_question(self, q: dict, num: int, total: int):
        """Display a question."""
        if self.use_rich:
            self.console.print(
                f"\n[bold cyan]Question {num}/{total}[/bold cyan] "
                f"[dim]({q.get('bloom', '').upper()} | {q.get('topic', '')})[/dim]"
            )
            self.console.print(f"\n[bold]{q.get('text', '')}[/bold]")
            if 'code' in q and q['code']:
                self.console.print()
                syntax = Syntax(q['code'].strip(), "bash", theme="monokai", line_numbers=True)
                self.console.print(syntax)
            self.console.print()
            for i, opt in enumerate(q.get('options', [])):
                letter = chr(65 + i)
                self.console.print(f"  [yellow]{letter})[/yellow] {opt}")
        else:
            print(f"\n--- Question {num}/{total} ({q.get('bloom', '').upper()}) ---")
            print(f"\n{q.get('text', '')}")
            if 'code' in q and q['code']:
                print("\n```bash")
                print(q['code'].strip())
                print("```")
            print()
            for i, opt in enumerate(q.get('options', [])):
                print(f"  {chr(65 + i)}) {opt}")

    def _get_answer(self, num_options: int) -> int:
        """Get answer from user."""
        valid = [chr(65 + i) for i in range(num_options)]
        while True:
            if self.use_rich:
                self.console.print()
                answer = self.console.input("[bold green]Your answer (A/B/C/D): [/bold green]")
            else:
                answer = input("\nYour answer (A/B/C/D): ")
            answer = answer.strip().upper()
            if answer in valid:
                return ord(answer) - 65
            print("Invalid answer. Enter A, B, C or D.")

    def _show_feedback(self, q: dict, user_answer: int, correct: bool):
        """Display feedback after answer."""
        correct_letter = chr(65 + q.get('correct_answer', 0))
        user_letter = chr(65 + user_answer)
        if self.use_rich:
            self.console.print()
            if correct:
                self.console.print(Panel(
                    f"[bold green]✓ CORRECT![/bold green]\n\n{q.get('explanation', '')}",
                    border_style="green"
                ))
            else:
                self.console.print(Panel(
                    f"[bold red]✗ INCORRECT[/bold red]\n\n"
                    f"Your answer: {user_letter}\n"
                    f"Correct answer: {correct_letter}\n\n"
                    f"[yellow]Explanation:[/yellow] {q.get('explanation', '')}",
                    border_style="red"
                ))
        else:
            print()
            if correct:
                print(f"✓ CORRECT! {q.get('explanation', '')}")
            else:
                print(f"✗ INCORRECT (answer: {user_letter}, correct: {correct_letter})")
                print(f"  Explanation: {q.get('explanation', '')}")

    def _show_results(self):
        """Display final results."""
        pct = (self.result.correct_answers / self.result.total_questions * 100
               if self.result.total_questions > 0 else 0)
        if self.use_rich:
            table = Table(title="Final Results", border_style="blue")
            table.add_column("Metric", style="cyan")
            table.add_column("Value", style="green")
            table.add_row("Correct answers",
                          f"{self.result.correct_answers}/{self.result.total_questions}")
            table.add_row("Score", f"{pct:.1f}%")
            self.console.print("\n")
            self.console.print(table)
        else:
            print("\n" + "=" * 60)
            print(f"  Correct: {self.result.correct_answers}/{self.result.total_questions}")
            print(f"  Score: {pct:.1f}%")
            print("=" * 60)

    def run(self, shuffle: bool = False, category: Optional[str] = None,
            limit: Optional[int] = None):
        """Run the quiz."""
        self._print_header()
        questions = self.quiz_data.get('questions', [])
        if category:
            questions = [q for q in questions if q.get('topic') == category]
        if shuffle:
            questions = questions.copy()
            random.shuffle(questions)
        if limit and limit < len(questions):
            questions = questions[:limit]

        self.result.total_questions = len(questions)
        self.result.start_time = datetime.now().isoformat()

        for i, q in enumerate(questions, 1):
            self._display_question(q, i, len(questions))
            user_answer = self._get_answer(len(q.get('options', [])))
            correct = user_answer == q.get('correct_answer', 0)
            if correct:
                self.result.correct_answers += 1

            cat = q.get('topic', 'unknown')
            if cat not in self.result.categories_score:
                self.result.categories_score[cat] = [0, 0]
            self.result.categories_score[cat][1] += 1
            if correct:
                self.result.categories_score[cat][0] += 1

            self._show_feedback(q, user_answer, correct)
            if i < len(questions):
                input("\nPress Enter for next question...")

        self.result.end_time = datetime.now().isoformat()
        self._show_results()

    def export_results(self, output_path: str):
        """Export results to JSON."""
        results = {
            'quiz_file': str(self.quiz_path),
            'total_questions': self.result.total_questions,
            'correct_answers': self.result.correct_answers,
            'score_percent': (self.result.correct_answers / self.result.total_questions * 100
                              if self.result.total_questions > 0 else 0),
            'categories': self.result.categories_score,
        }
        with open(output_path, 'w', encoding='utf-8') as f:
            json.dump(results, f, indent=2, ensure_ascii=False)
        print(f"Results exported to: {output_path}")


def main():
    """Entry point."""
    parser = argparse.ArgumentParser(description="Runner for YAML Quizzes")
    parser.add_argument('quiz_file', help='Path to quiz.yaml file')
    parser.add_argument('--shuffle', action='store_true', help='Shuffle questions')
    parser.add_argument('--category', type=str, help='Filter by category')
    parser.add_argument('--limit', type=int, help='Limit number of questions')
    parser.add_argument('--no-rich', action='store_true', help='Disable rich formatting')
    parser.add_argument('--export-results', type=str, help='Export results to JSON')

    args = parser.parse_args()
    runner = QuizRunner(args.quiz_file, use_rich=not args.no_rich)
    runner.run(shuffle=args.shuffle, category=args.category, limit=args.limit)
    if args.export_results:
        runner.export_results(args.export_results)


if __name__ == '__main__':
    main()
