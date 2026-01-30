#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
═══════════════════════════════════════════════════════════════════════════════
quiz_runner.py - Interactive Quiz Runner for SEM03
═══════════════════════════════════════════════════════════════════════════════
Operating Systems | Bucharest UES - CSIE

DESCRIPTION:
    Runs the quiz from quiz.yaml in interactive terminal mode.
    I made this after seeing that students completely ignored quiz_lms.json.
    Who looks at JSON honestly?

FEATURES:
    - Loads questions from quiz.yaml
    - Interactive mode with instant feedback
    - Optional question shuffling
    - Score and time tracking
    - Detailed explanations for wrong answers
    - Results export (optional)

USAGE:
    python3 quiz_runner.py                    # Normal run
    python3 quiz_runner.py --shuffle          # Random question order
    python3 quiz_runner.py --category cron    # Only one category
    python3 quiz_runner.py --quick            # No explanations, just score

AUTHOR: SO Team | VERSION: 1.0 | DATE: January 2025

PERSONAL NOTE:
    The initial version used `dialog` for a fancy interface but I gave up.
    Half the students use terminals that do not support ncurses properly.
    Keep it simple.
═══════════════════════════════════════════════════════════════════════════════
"""

import os
import sys
import random
import time
from pathlib import Path
from datetime import datetime
from typing import Dict, List, Optional, Any

# YAML is optional - fallback to manual parsing if missing
try:
    import yaml
    YAML_AVAILABLE = True
except ImportError:
    YAML_AVAILABLE = False
    print("⚠️  PyYAML is not installed. Run: pip install pyyaml")
    print("    Or: pip install pyyaml --break-system-packages")
    print()

# ═══════════════════════════════════════════════════════════════════════════════
# CONFIGURATION AND CONSTANTS
# ═══════════════════════════════════════════════════════════════════════════════

class Colours:
    """ANSI escape codes for terminal."""
    # Learnt the hard way to have fallback for poor terminals
    
    RED = '\033[0;31m'
    GREEN = '\033[0;32m'
    YELLOW = '\033[1;33m'
    BLUE = '\033[0;34m'
    MAGENTA = '\033[0;35m'
    CYAN = '\033[0;36m'
    WHITE = '\033[1;37m'
    GRAY = '\033[0;90m'
    BOLD = '\033[1m'
    DIM = '\033[2m'
    RESET = '\033[0m'
    
    @classmethod
    def disable(cls):
        """Disable colours (for redirection or incompatible terminals)."""
        for attr in dir(cls):
            if attr.isupper() and not attr.startswith('_'):
                setattr(cls, attr, '')

# Automatic colour support detection
if not sys.stdout.isatty() or os.environ.get('NO_COLOR'):
    Colours.disable()

# Path to quiz.yaml - relative to this script
SCRIPT_DIR = Path(__file__).parent
QUIZ_FILE = SCRIPT_DIR / "quiz.yaml"

# ═══════════════════════════════════════════════════════════════════════════════
# MAIN CLASS
# ═══════════════════════════════════════════════════════════════════════════════

class QuizRunner:
    """
    Interactive runner for YAML quizzes.
    
    Attributes:
        questions: List of loaded questions
        score: Current score
        total_possible: Maximum possible score
        answers: Answer history
        start_time: Quiz start timestamp
    """
    
    def __init__(self, quiz_path: Path = QUIZ_FILE):
        self.quiz_path = quiz_path
        self.questions: List[Dict] = []
        self.metadata: Dict = {}
        self.score: float = 0
        self.total_possible: float = 0
        self.answers: List[Dict] = []
        self.start_time: Optional[float] = None
        
        # Run options
        self.shuffle = False
        self.quick_mode = False
        self.category_filter: Optional[str] = None
    
    def load_quiz(self) -> bool:
        """
        Load the quiz from the YAML file.
        
        Returns:
            True if loading succeeded, False otherwise
        """
        if not YAML_AVAILABLE:
            print(f"{Colours.RED}Error: PyYAML is not available.{Colours.RESET}")
            return False
        
        if not self.quiz_path.exists():
            print(f"{Colours.RED}Error: Cannot find {self.quiz_path}{Colours.RESET}")
            print(f"Check if you are in the correct directory.")
            return False
        
        try:
            with open(self.quiz_path, 'r', encoding='utf-8') as f:
                data = yaml.safe_load(f)
            
            self.metadata = data.get('metadata', {})
            self.questions = data.get('questions', [])
            
            if not self.questions:
                print(f"{Colours.YELLOW}Warning: Quiz contains no questions.{Colours.RESET}")
                return False
            
            # Filter by category if specified
            if self.category_filter:
                self.questions = [
                    q for q in self.questions 
                    if self.category_filter.lower() in q.get('section', '').lower()
                ]
                if not self.questions:
                    print(f"{Colours.YELLOW}No questions in category '{self.category_filter}'{Colours.RESET}")
                    return False
            
            # Calculate total possible score
            self.total_possible = sum(q.get('score', 1) for q in self.questions)
            
            print(f"{Colours.GREEN}✓ Loaded {len(self.questions)} questions{Colours.RESET}")
            return True
            
        except yaml.YAMLError as e:
            print(f"{Colours.RED}YAML parsing error: {e}{Colours.RESET}")
            return False
        except Exception as e:
            print(f"{Colours.RED}Loading error: {e}{Colours.RESET}")
            return False
    
    def display_header(self):
        """Display the quiz header."""
        title = self.metadata.get('title', 'Quiz SEM03')
        
        print()
        print(f"{Colours.CYAN}{'═' * 70}{Colours.RESET}")
        print(f"{Colours.BOLD}{Colours.WHITE}  📝 {title}{Colours.RESET}")
        print(f"{Colours.CYAN}{'═' * 70}{Colours.RESET}")
        print()
        print(f"  Questions: {len(self.questions)}")
        print(f"  Maximum score: {self.total_possible}")
        print(f"  Estimated time: {self.metadata.get('estimated_duration_minutes', '?')} minutes")
        print()
        print(f"{Colours.GRAY}  Type the answer letter (a/b/c/d) or 'q' to quit{Colours.RESET}")
        print()
    
    def ask_question(self, q: Dict, index: int) -> bool:
        """
        Display a question and process the answer.
        
        Args:
            q: Dictionary with question data
            index: Question number (1-based)
        
        Returns:
            True if the answer is correct, False otherwise
        """
        section = q.get('section', 'General')
        bloom = q.get('bloom', 'apply')
        score = q.get('score', 1)
        text = q.get('text', '').strip()
        options = q.get('options', [])
        correct_idx = q.get('correct', 0)
        explanation = q.get('explanation', '')
        
        # Question header
        print(f"{Colours.BLUE}{'─' * 70}{Colours.RESET}")
        print(f"{Colours.BOLD}Question {index}/{len(self.questions)}{Colours.RESET}", end="")
        print(f"  {Colours.GRAY}[{section}] [{bloom}] [{score}p]{Colours.RESET}")
        print()
        
        # Question text
        print(f"{text}")
        print()
        
        # Options
        letters = 'abcdefgh'
        for i, opt in enumerate(options):
            print(f"  {Colours.CYAN}{letters[i]}){Colours.RESET} {opt}")
        print()
        
        # Wait for answer
        while True:
            try:
                answer = input(f"{Colours.YELLOW}Your answer: {Colours.RESET}").strip().lower()
            except (EOFError, KeyboardInterrupt):
                print("\n")
                return False
            
            if answer == 'q':
                print(f"\n{Colours.YELLOW}Quiz interrupted.{Colours.RESET}")
                sys.exit(0)
            
            if len(answer) == 1 and answer in letters[:len(options)]:
                break
            
            print(f"{Colours.RED}Invalid answer. Use {letters[:len(options)]}{Colours.RESET}")
        
        # Check answer
        answer_idx = letters.index(answer)
        is_correct = (answer_idx == correct_idx)
        
        # Save to history
        self.answers.append({
            'question_id': q.get('id', f'q{index}'),
            'user_answer': answer_idx,
            'correct_answer': correct_idx,
            'is_correct': is_correct,
            'score': score if is_correct else 0
        })
        
        # Feedback
        print()
        if is_correct:
            self.score += score
            print(f"{Colours.GREEN}✓ CORRECT! (+{score} points){Colours.RESET}")
        else:
            correct_letter = letters[correct_idx]
            print(f"{Colours.RED}✗ Wrong. Correct answer: {correct_letter}) {options[correct_idx]}{Colours.RESET}")
        
        # Explanation (unless quick mode)
        if not self.quick_mode and explanation:
            print()
            print(f"{Colours.GRAY}Explanation:{Colours.RESET}")
            for line in explanation.strip().split('\n'):
                print(f"  {Colours.DIM}{line}{Colours.RESET}")
        
        print()
        
        # Short pause to read feedback
        if not self.quick_mode:
            try:
                input(f"{Colours.GRAY}[Press Enter to continue]{Colours.RESET}")
            except (EOFError, KeyboardInterrupt):
                pass
        
        return is_correct
    
    def display_results(self):
        """Display final results."""
        elapsed = time.time() - self.start_time if self.start_time else 0
        minutes = int(elapsed // 60)
        seconds = int(elapsed % 60)
        
        percentage = (self.score / self.total_possible * 100) if self.total_possible > 0 else 0
        
        # Determine grade (Romanian system)
        if percentage >= 90:
            grade = "10"
            grade_text = "Excellent!"
            grade_colour = Colours.GREEN
        elif percentage >= 80:
            grade = "9"
            grade_text = "Very good!"
            grade_colour = Colours.GREEN
        elif percentage >= 70:
            grade = "8"
            grade_text = "Good"
            grade_colour = Colours.CYAN
        elif percentage >= 60:
            grade = "7"
            grade_text = "Satisfactory"
            grade_colour = Colours.YELLOW
        elif percentage >= 50:
            grade = "6"
            grade_text = "Sufficient"
            grade_colour = Colours.YELLOW
        else:
            grade = "4"
            grade_text = "Review the material"
            grade_colour = Colours.RED
        
        correct_count = sum(1 for a in self.answers if a['is_correct'])
        
        print()
        print(f"{Colours.CYAN}{'═' * 70}{Colours.RESET}")
        print(f"{Colours.BOLD}{Colours.WHITE}  📊 FINAL RESULTS{Colours.RESET}")
        print(f"{Colours.CYAN}{'═' * 70}{Colours.RESET}")
        print()
        print(f"  Correct answers:  {correct_count}/{len(self.questions)}")
        print(f"  Score:            {self.score}/{self.total_possible}")
        print(f"  Percentage:       {percentage:.1f}%")
        print(f"  Time:             {minutes}m {seconds}s")
        print()
        print(f"  {grade_colour}Estimated grade: {grade} - {grade_text}{Colours.RESET}")
        print()
        
        # Suggestions based on weak categories
        if percentage < 80:
            weak_sections = self._identify_weak_sections()
            if weak_sections:
                print(f"{Colours.YELLOW}📚 Recommendation: Review these sections:{Colours.RESET}")
                for section in weak_sections:
                    print(f"   • {section}")
                print()
        
        print(f"{Colours.CYAN}{'═' * 70}{Colours.RESET}")
        print()
    
    def _identify_weak_sections(self) -> List[str]:
        """Identify sections with the weakest results."""
        section_scores: Dict[str, List[bool]] = {}
        
        for i, answer in enumerate(self.answers):
            if i < len(self.questions):
                section = self.questions[i].get('section', 'General')
                if section not in section_scores:
                    section_scores[section] = []
                section_scores[section].append(answer['is_correct'])
        
        weak = []
        for section, results in section_scores.items():
            accuracy = sum(results) / len(results) if results else 0
            if accuracy < 0.6:  # Below 60% - weak section
                weak.append(section)
        
        return weak
    
    def run(self):
        """Run the complete quiz."""
        if not self.load_quiz():
            return
        
        self.display_header()
        
        # Confirm start
        try:
            input(f"{Colours.GREEN}Press Enter to begin...{Colours.RESET}")
        except (EOFError, KeyboardInterrupt):
            print("\nCancelled.")
            return
        
        print()
        self.start_time = time.time()
        
        # Shuffle if requested
        questions = self.questions.copy()
        if self.shuffle:
            random.shuffle(questions)
        
        # Go through questions
        for i, q in enumerate(questions, 1):
            self.ask_question(q, i)
        
        # Display results
        self.display_results()


# ═══════════════════════════════════════════════════════════════════════════════
# CLI INTERFACE
# ═══════════════════════════════════════════════════════════════════════════════

def print_usage():
    """Display usage instructions."""
    print(f"""
{Colours.BOLD}Quiz Runner - SEM03 System Administration{Colours.RESET}

{Colours.CYAN}USAGE:{Colours.RESET}
    python3 quiz_runner.py [options]

{Colours.CYAN}OPTIONS:{Colours.RESET}
    --help, -h        Display this message
    --shuffle         Shuffle question order
    --quick           Quick mode (no explanations)
    --category CAT    Filter by category (find, getopts, permissions, cron)
    --no-color        Disable colours

{Colours.CYAN}EXAMPLES:{Colours.RESET}
    python3 quiz_runner.py
    python3 quiz_runner.py --shuffle --quick
    python3 quiz_runner.py --category "cron"

{Colours.CYAN}NOTES:{Colours.RESET}
    • Requires PyYAML: pip install pyyaml
    • Answer with a/b/c/d or 'q' to quit
    • Quiz is loaded from quiz.yaml in the same directory
""")

def main():
    """Main entry point."""
    runner = QuizRunner()
    
    # Parse arguments (simple, without argparse for minimalism)
    args = sys.argv[1:]
    
    if '--help' in args or '-h' in args:
        print_usage()
        return 0
    
    if '--shuffle' in args:
        runner.shuffle = True
        print(f"{Colours.GRAY}[Shuffle mode activated]{Colours.RESET}")
    
    if '--quick' in args:
        runner.quick_mode = True
        print(f"{Colours.GRAY}[Quick mode - no explanations]{Colours.RESET}")
    
    if '--no-color' in args:
        Colours.disable()
    
    if '--category' in args:
        try:
            idx = args.index('--category')
            runner.category_filter = args[idx + 1]
            print(f"{Colours.GRAY}[Category filter: {runner.category_filter}]{Colours.RESET}")
        except (IndexError, ValueError):
            print(f"{Colours.RED}Error: --category requires an argument{Colours.RESET}")
            return 1
    
    # Run the quiz
    try:
        runner.run()
    except KeyboardInterrupt:
        print(f"\n{Colours.YELLOW}Quiz interrupted by user.{Colours.RESET}")
        return 130
    
    return 0


if __name__ == '__main__':
    sys.exit(main())
