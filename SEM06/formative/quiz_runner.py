#!/usr/bin/env python3
"""
Quiz Runner for CAPSTONE SEM06 - Operating Systems
===================================================

Runs formative quizzes from YAML files with support for:
- Interactive terminal display
- Automatic scoring with feedback
- Results export
- Practice and evaluation modes

Usage:
    python quiz_runner.py formative/quiz.yaml
    python quiz_runner.py formative/quiz.yaml --practice
    python quiz_runner.py formative/quiz.yaml --export results.json

Author: ASE Bucharest - CSIE
Version: 1.0.0
"""

import argparse
import json
import random
import sys
from datetime import datetime
from pathlib import Path
from typing import Optional

try:
    import yaml
except ImportError:
    print("Error: PyYAML required. Install with: pip install pyyaml")
    sys.exit(1)


# ═══════════════════════════════════════════════════════════════════════════════
# CONSTANTS
# ═══════════════════════════════════════════════════════════════════════════════

COLORS = {
    "reset": "\033[0m",
    "bold": "\033[1m",
    "red": "\033[91m",
    "green": "\033[92m",
    "yellow": "\033[93m",
    "blue": "\033[94m",
    "cyan": "\033[96m",
}

BLOOM_LEVELS = ["remember", "understand", "apply", "analyse", "evaluate", "create"]


# ═══════════════════════════════════════════════════════════════════════════════
# UTILITY FUNCTIONS
# ═══════════════════════════════════════════════════════════════════════════════

def color_text(text: str, color: str) -> str:
    """Applies ANSI colour to text."""
    return f"{COLORS.get(color, '')}{text}{COLORS['reset']}"


def clear_screen():
    """Clears the terminal screen."""
    print("\033[2J\033[H", end="")


def print_separator(char: str = "─", width: int = 70):
    """Displays a separator."""
    print(char * width)


def print_header(text: str):
    """Displays a formatted header."""
    print_separator("═")
    print(color_text(f"  {text}", "bold"))
    print_separator("═")


# ═══════════════════════════════════════════════════════════════════════════════
# MAIN CLASSES
# ═══════════════════════════════════════════════════════════════════════════════

class Question:
    """Represents a quiz question."""

    def __init__(self, data: dict):
        self.id = data.get("id", "unknown")
        self.type = data.get("type", data.get("tip", "mcq"))
        self.bloom = data.get("bloom", "understand")
        self.points = data.get("points", data.get("puncte", 5))
        self.subject = data.get("subject", data.get("subiect", ""))
        self.text = data.get("text", "").strip()
        self.options = data.get("options", data.get("optiuni", {}))
        self.correct = data.get("correct", data.get("corect", ""))
        self.explanation = data.get("explanation", data.get("explicatie", "")).strip()
        self.misconceptions = data.get("misconceptions", data.get("misconceptii", {}))

    def display(self, index: int, total: int, show_bloom: bool = False):
        """Displays the formatted question."""
        bloom_badge = f" [{self.bloom.upper()}]" if show_bloom else ""
        print(f"\n{color_text(f'Question {index}/{total}', 'cyan')}{bloom_badge}")
        print(f"{color_text(f'[{self.points}p]', 'yellow')} {self.subject}\n")
        print(self.text)
        print()

        for key, value in self.options.items():
            print(f"  {color_text(key.upper(), 'bold')}) {value}")

    def check_answer(self, answer: str) -> bool:
        """Checks if the answer is correct."""
        return answer.lower() == str(self.correct).lower()

    def show_feedback(self, answer: str, show_misconception: bool = True):
        """Displays feedback for the answer."""
        is_correct = self.check_answer(answer)

        if is_correct:
            print(color_text("\n✓ Correct!", "green"))
        else:
            print(color_text(f"\n✗ Incorrect. Correct answer: {self.correct.upper()}", "red"))

            if show_misconception and answer.lower() in self.misconceptions:
                misconception = self.misconceptions[answer.lower()]
                print(color_text(f"  → {misconception}", "yellow"))

        if self.explanation:
            print(f"\n{color_text('Explanation:', 'blue')}")
            print(f"  {self.explanation}")


class Quiz:
    """Manages the complete quiz."""

    def __init__(self, filepath: str):
        self.filepath = Path(filepath)
        self.data = self._load_quiz()
        self.metadata = self.data.get("metadata", {})
        self.questions = [Question(q) for q in self.data.get("questions", self.data.get("intrebari", []))]
        self.config = self.data.get("configuration", self.data.get("configurare", {}))
        self.results = []

    def _load_quiz(self) -> dict:
        """Loads the quiz from YAML file."""
        if not self.filepath.exists():
            raise FileNotFoundError(f"File {self.filepath} does not exist")

        with open(self.filepath, "r", encoding="utf-8") as f:
            return yaml.safe_load(f)

    @property
    def title(self) -> str:
        return self.metadata.get("title", self.metadata.get("titlu", "Quiz"))

    @property
    def total_points(self) -> int:
        return sum(q.points for q in self.questions)

    @property
    def passing_score(self) -> int:
        return self.metadata.get("pass_threshold", self.metadata.get("prag_promovare", 60))

    def run_interactive(self, shuffle: bool = False, practice: bool = False):
        """Runs the quiz interactively in terminal."""
        clear_screen()
        print_header(self.title)

        print(f"\nQuestions: {len(self.questions)}")
        print(f"Total points: {self.total_points}")
        print(f"Pass threshold: {self.passing_score}%")

        if practice:
            print(color_text("\nPRACTICE mode - you will see explanations after each question", "cyan"))

        input("\nPress ENTER to begin...")

        questions = self.questions[:]
        if shuffle:
            random.shuffle(questions)

        score = 0
        self.results = []

        for i, question in enumerate(questions, 1):
            clear_screen()
            question.display(i, len(questions), show_bloom=practice)

            while True:
                answer = input(f"\nYour answer ({'/'.join(question.options.keys())}): ").strip()
                if answer.lower() in [k.lower() for k in question.options.keys()]:
                    break
                print(color_text("Invalid answer. Try again.", "red"))

            is_correct = question.check_answer(answer)

            if is_correct:
                score += question.points

            self.results.append({
                "question_id": question.id,
                "answer": answer,
                "correct": is_correct,
                "points": question.points if is_correct else 0,
            })

            if practice:
                question.show_feedback(answer)
                input("\nPress ENTER to continue...")

        self._show_final_results(score)

    def _show_final_results(self, score: int):
        """Displays final results."""
        clear_screen()
        print_header("FINAL RESULTS")

        percentage = (score / self.total_points) * 100
        passed = percentage >= self.passing_score

        print(f"\nScore: {score}/{self.total_points} ({percentage:.1f}%)")

        if passed:
            print(color_text("\n✓ PASSED", "green"))
        else:
            print(color_text("\n✗ NOT PASSED", "red"))

        # Level feedback
        feedback = self.config.get("messages", self.config.get("mesaje", {}))
        for threshold, message in sorted(
            self.config.get("feedback_level", self.config.get("feedback_nivel", {})).items(),
            key=lambda x: int(x[0]),
            reverse=True
        ):
            if percentage >= int(threshold):
                print(f"\n{message}")
                break

        # Statistics per Bloom level
        print("\n" + color_text("Performance per Bloom level:", "cyan"))
        bloom_stats = {}
        for result, question in zip(self.results, self.questions):
            level = question.bloom
            if level not in bloom_stats:
                bloom_stats[level] = {"correct": 0, "total": 0}
            bloom_stats[level]["total"] += 1
            if result["correct"]:
                bloom_stats[level]["correct"] += 1

        for level in BLOOM_LEVELS:
            if level in bloom_stats:
                stats = bloom_stats[level]
                pct = (stats["correct"] / stats["total"]) * 100
                bar = "█" * int(pct / 10) + "░" * (10 - int(pct / 10))
                print(f"  {level.capitalize():12} [{bar}] {pct:.0f}%")

    def export_results(self, filepath: str):
        """Exports results to JSON."""
        export_data = {
            "quiz": self.title,
            "date": datetime.now().isoformat(),
            "score": sum(r["points"] for r in self.results),
            "total": self.total_points,
            "percentage": (sum(r["points"] for r in self.results) / self.total_points) * 100,
            "passed": (sum(r["points"] for r in self.results) / self.total_points) * 100 >= self.passing_score,
            "results": self.results,
        }

        with open(filepath, "w", encoding="utf-8") as f:
            json.dump(export_data, f, indent=2, ensure_ascii=False)

        print(f"Results exported to: {filepath}")


# ═══════════════════════════════════════════════════════════════════════════════
# TEST FUNCTIONS
# ═══════════════════════════════════════════════════════════════════════════════

def run_tests():
    """Runs unit tests for quiz runner."""
    print_header("UNIT TESTS - Quiz Runner")

    tests_passed = 0
    tests_failed = 0

    # Test 1: Load YAML
    print("\n[TEST 1] Load YAML...")
    try:
        test_yaml = """
metadata:
  title: "Test Quiz"
questions:
  - id: q1
    type: mcq
    bloom: remember
    points: 5
    text: "Test question"
    options:
      a: "Option A"
      b: "Option B"
    correct: a
"""
        data = yaml.safe_load(test_yaml)
        assert data["metadata"]["title"] == "Test Quiz"
        assert len(data["questions"]) == 1
        print(color_text("  ✓ PASS", "green"))
        tests_passed += 1
    except AssertionError as e:
        print(color_text(f"  ✗ FAIL: {e}", "red"))
        tests_failed += 1

    # Test 2: Question parsing
    print("\n[TEST 2] Question parsing...")
    try:
        q_data = {
            "id": "test",
            "type": "mcq",
            "bloom": "apply",
            "points": 10,
            "text": "What is 2+2?",
            "options": {"a": "3", "b": "4", "c": "5"},
            "correct": "b",
        }
        q = Question(q_data)
        assert q.id == "test"
        assert q.points == 10
        assert q.check_answer("b") is True
        assert q.check_answer("a") is False
        assert q.check_answer("B") is True  # Case insensitive
        print(color_text("  ✓ PASS", "green"))
        tests_passed += 1
    except AssertionError as e:
        print(color_text(f"  ✗ FAIL: {e}", "red"))
        tests_failed += 1

    # Test 3: Colour text
    print("\n[TEST 3] Colour formatting...")
    try:
        coloured = color_text("test", "green")
        assert "\033[92m" in coloured
        assert "\033[0m" in coloured
        assert "test" in coloured
        print(color_text("  ✓ PASS", "green"))
        tests_passed += 1
    except AssertionError as e:
        print(color_text(f"  ✗ FAIL: {e}", "red"))
        tests_failed += 1

    # Test 4: Export JSON format
    print("\n[TEST 4] Export JSON format...")
    try:
        results = [
            {"question_id": "q1", "answer": "a", "correct": True, "points": 5},
            {"question_id": "q2", "answer": "b", "correct": False, "points": 0},
        ]
        total = 10
        score = sum(r["points"] for r in results)
        percentage = (score / total) * 100
        assert score == 5
        assert percentage == 50.0
        print(color_text("  ✓ PASS", "green"))
        tests_passed += 1
    except AssertionError as e:
        print(color_text(f"  ✗ FAIL: {e}", "red"))
        tests_failed += 1

    # Test 5: Bloom levels order
    print("\n[TEST 5] Bloom levels order...")
    try:
        assert BLOOM_LEVELS.index("remember") < BLOOM_LEVELS.index("understand")
        assert BLOOM_LEVELS.index("understand") < BLOOM_LEVELS.index("apply")
        assert BLOOM_LEVELS.index("apply") < BLOOM_LEVELS.index("analyse")
        print(color_text("  ✓ PASS", "green"))
        tests_passed += 1
    except AssertionError as e:
        print(color_text(f"  ✗ FAIL: {e}", "red"))
        tests_failed += 1

    # Summary
    print_separator()
    total = tests_passed + tests_failed
    print(f"\nResult: {tests_passed}/{total} tests passed")

    if tests_failed == 0:
        print(color_text("All tests passed!", "green"))
        return 0
    else:
        print(color_text(f"{tests_failed} tests failed", "red"))
        return 1


# ═══════════════════════════════════════════════════════════════════════════════
# MAIN
# ═══════════════════════════════════════════════════════════════════════════════

def main():
    """Main entry point."""
    parser = argparse.ArgumentParser(
        description="Quiz Runner for Operating Systems",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s quiz.yaml              # Run the quiz
  %(prog)s quiz.yaml --practice   # Practice mode with explanations
  %(prog)s quiz.yaml --shuffle    # Questions in random order
  %(prog)s --test                 # Run unit tests
""",
    )

    parser.add_argument("quiz_file", nargs="?", help="YAML file with quiz")
    parser.add_argument("--practice", "-p", action="store_true", help="Practice mode with explanations")
    parser.add_argument("--shuffle", "-s", action="store_true", help="Shuffle questions")
    parser.add_argument("--export", "-e", metavar="FILE", help="Export results to JSON")
    parser.add_argument("--test", "-t", action="store_true", help="Run unit tests")
    parser.add_argument("--version", "-v", action="version", version="Quiz Runner 1.0.0")

    args = parser.parse_args()

    if args.test:
        return run_tests()

    if not args.quiz_file:
        parser.print_help()
        return 1

    try:
        quiz = Quiz(args.quiz_file)
        quiz.run_interactive(shuffle=args.shuffle, practice=args.practice)

        if args.export:
            quiz.export_results(args.export)

        return 0

    except FileNotFoundError as e:
        print(color_text(f"Error: {e}", "red"))
        return 1
    except yaml.YAMLError as e:
        print(color_text(f"YAML parsing error: {e}", "red"))
        return 1
    except KeyboardInterrupt:
        print(color_text("\n\nQuiz interrupted.", "yellow"))
        return 130


if __name__ == "__main__":
    sys.exit(main())
