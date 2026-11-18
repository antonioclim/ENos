#!/usr/bin/env python3
"""
AUTO-GRADER - Seminar 1: Bash Shell
Operating Systems | ASE Bucharest - CSIE

Purpose: Automatic verification of assignments and exercises
Usage: python3 S01_01_autograder.py <student_directory> [--json output.json]

Version: 2.0 - with support for randomised variants and understanding verification
"""

import logging
import os
import sys
import subprocess
import json
import re
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Tuple, Optional
from dataclasses import dataclass, field

# Logging setup — import shared utilities from kit lib
sys.path.insert(0, str(Path(__file__).parent.parent.parent.parent / 'lib'))
from logging_utils import setup_logging

logger = setup_logging(__name__)


class Colours:
    """ANSI colour codes for output."""
    RED = '\033[0;31m'
    GREEN = '\033[0;32m'
    YELLOW = '\033[1;33m'
    BLUE = '\033[0;34m'
    CYAN = '\033[0;36m'
    WHITE = '\033[1;37m'
    NC = '\033[0m'
    BOLD = '\033[1m'


def log_info(msg: str) -> None:
    """Display informational message."""
    logger.info(msg)


def log_success(msg: str) -> None:
    """Display success message (student-facing with colour)."""
    # Student-facing coloured output preserved
    print(f"{Colours.GREEN}[PASS]{Colours.NC} {msg}")
    logger.info(f"PASS: {msg}")


def log_error(msg: str) -> None:
    """Display error message (student-facing with colour)."""
    # Student-facing coloured output preserved
    print(f"{Colours.RED}[FAIL]{Colours.NC} {msg}")
    logger.warning(f"FAIL: {msg}")


def log_warning(msg: str) -> None:
    """Display warning message."""
    logger.warning(msg)


# =============================================================================
# TEST CLASSES
# =============================================================================

class TestCase:
    """Base class for all tests."""
    
    def __init__(self, name: str, points: int, description: str):
        self.name = name
        self.points = points
        self.description = description
        self.passed = False
        self.feedback = ""
        self.pending_manual_review = False
    
    def run(self, student_dir: Path) -> bool:
        raise NotImplementedError


class FileExistsTest(TestCase):
    """Verifies existence of a file."""
    
    def __init__(self, name: str, points: int, description: str, filepath: str):
        super().__init__(name, points, description)
        self.filepath = filepath
    
    def run(self, student_dir: Path) -> bool:
        target = student_dir / self.filepath
        if target.exists():
            self.passed = True
            self.feedback = f"File {self.filepath} exists"
        else:
            self.feedback = f"File {self.filepath} not found"
        return self.passed


class DirectoryStructureTest(TestCase):
    """Verifies directory structure."""
    
    def __init__(self, name: str, points: int, description: str, required_dirs: List[str]):
        super().__init__(name, points, description)
        self.required_dirs = required_dirs
    
    def run(self, student_dir: Path) -> bool:
        missing = []
        for d in self.required_dirs:
            if not (student_dir / d).is_dir():
                missing.append(d)
        
        if not missing:
            self.passed = True
            self.feedback = "All required directories exist"
        else:
            self.feedback = f"Missing directories: {', '.join(missing)}"
        return self.passed


class BashSyntaxTest(TestCase):
    """Verifies Bash script syntax."""
    
    def __init__(self, name: str, points: int, description: str, script_path: str):
        super().__init__(name, points, description)
        self.script_path = script_path
    
    def run(self, student_dir: Path) -> bool:
        script = student_dir / self.script_path
        if not script.exists():
            self.feedback = f"Script {self.script_path} does not exist"
            return False
        
        try:
            result = subprocess.run(
                ['bash', '-n', str(script)],
                capture_output=True,
                text=True,
                timeout=5
            )
            if result.returncode == 0:
                self.passed = True
                self.feedback = "Bash syntax is correct"
            else:
                self.feedback = f"Syntax errors: {result.stderr[:200]}"
        except subprocess.TimeoutExpired:
            self.feedback = "Verification exceeded timeout"
        except Exception as e:
            self.feedback = f"Verification error: {str(e)}"
        
        return self.passed


class BashExecutionTest(TestCase):
    """Verifies Bash script execution."""
    
    def __init__(self, name: str, points: int, description: str, 
                 script_path: str, expected_output: str = None,
                 expected_pattern: str = None):
        super().__init__(name, points, description)
        self.script_path = script_path
        self.expected_output = expected_output
        self.expected_pattern = expected_pattern
    
    def run(self, student_dir: Path) -> bool:
        script = student_dir / self.script_path
        if not script.exists():
            self.feedback = f"Script {self.script_path} does not exist"
            return False
        
        try:
            result = subprocess.run(
                ['bash', str(script)],
                capture_output=True,
                text=True,
                timeout=10,
                cwd=student_dir
            )
            
            if result.returncode != 0:
                self.feedback = f"Script exited with status {result.returncode}: {result.stderr[:200]}"
                return False
            output = result.stdout.strip()
            
            if self.expected_output:
                if self.expected_output in output:
                    self.passed = True
                    self.feedback = "Output contains expected result"
                else:
                    self.feedback = f"Expected: '{self.expected_output}', got: '{output[:100]}'"
            
            elif self.expected_pattern:
                if re.search(self.expected_pattern, output):
                    self.passed = True
                    self.feedback = "Output matches expected pattern"
                else:
                    self.feedback = f"Output does not match pattern: {self.expected_pattern}"
            else:
                if result.returncode == 0:
                    self.passed = True
                    self.feedback = "Script executed successfully"
                else:
                    self.feedback = f"Script returned error: {result.stderr[:200]}"
                    
        except subprocess.TimeoutExpired:
            self.feedback = "Execution exceeded timeout (10s)"
        except Exception as e:
            self.feedback = f"Execution error: {str(e)}"
        
        return self.passed


class BashrcConfigTest(TestCase):
    """Verifies .bashrc configuration."""
    
    def __init__(self, name: str, points: int, description: str,
                 required_aliases: List[str] = None,
                 required_exports: List[str] = None,
                 required_functions: List[str] = None):
        super().__init__(name, points, description)
        self.required_aliases = required_aliases or []
        self.required_exports = required_exports or []
        self.required_functions = required_functions or []
    
    def run(self, student_dir: Path) -> bool:
        bashrc = student_dir / '.bashrc'
        if not bashrc.exists():
            bashrc = student_dir / 'bashrc'
        
        if not bashrc.exists():
            self.feedback = "File .bashrc not found"
            return False
        
        content = bashrc.read_text()
        missing = []
        
        for alias in self.required_aliases:
            if f"alias {alias}=" not in content:
                missing.append(f"alias {alias}")
        
        for export in self.required_exports:
            if f"export {export}" not in content:
                missing.append(f"export {export}")
        
        for func in self.required_functions:
            if f"{func}()" not in content and f"function {func}" not in content:
                missing.append(f"function {func}")
        
        if not missing:
            self.passed = True
            self.feedback = "All required configurations present"
        else:
            self.feedback = f"Missing: {', '.join(missing)}"
        
        return self.passed


class GlobbingTest(TestCase):
    """Locate submitted globbing evidence; its free-form explanation needs review.

    The assignment does not prescribe a machine-readable output protocol. Running
    a grader-owned pattern demonstrates Bash, not the student's work, and must
    never earn the student marks. No submission path is created or deleted here.
    """

    def __init__(self, name: str, points: int, description: str,
                 setup_files: List[str], pattern: str, expected_matches: List[str],
                 script_path: str = 'project/tests/test_globbing.sh'):
        super().__init__(name, points, description)
        self.setup_files = setup_files
        self.pattern = pattern
        self.expected_matches = expected_matches
        self.script_path = script_path

    def run(self, student_dir: Path) -> bool:
        self.passed = False
        script = student_dir / self.script_path
        if not script.is_file():
            self.feedback = f"Submitted globbing script missing: {self.script_path}"
            return False
        self.pending_manual_review = True
        self.feedback = (f"Review {self.script_path} for {self.pattern!r}; "
                         "free-form demonstration has no approved automatic output contract. "
                         "No automatic marks awarded; this is pending review, not a failed demonstration.")
        return False


class CodeUnderstandingTest(TestCase):
    """
    Generates questions for oral verification based on student code.
    Does NOT award points automatically - only prepares questions.
    """
    
    def __init__(self, name: str, points: int, description: str, script_path: str):
        super().__init__(name, points, description)
        self.script_path = script_path
        self.questions: List[str] = []
    
    def run(self, student_dir: Path) -> bool:
        script = student_dir / self.script_path
        if not script.exists():
            self.feedback = "Script does not exist for question generation"
            return False
        
        content = script.read_text()
        lines = content.split('\n')
        
        # Find elements for questions
        variables = re.findall(r'^([A-Z_][A-Z0-9_]*)=', content, re.MULTILINE)
        exports = re.findall(r'export\s+([A-Z_]+)', content)
        functions = re.findall(r'(\w+)\s*\(\)', content)
        conditionals = [i+1 for i, l in enumerate(lines) if 'if ' in l or 'case ' in l]
        loops = [i+1 for i, l in enumerate(lines) if 'for ' in l or 'while ' in l]
        
        # Generate questions
        if variables:
            var = variables[0]
            self.questions.append(
                f"What value will variable {var} have after execution? Explain."
            )
        
        if exports:
            exp = exports[0]
            self.questions.append(
                f"Why did you use 'export' for {exp}? What would happen without export?"
            )
        
        if functions:
            func = functions[0]
            self.questions.append(
                f"Explain step by step what function {func}() does."
            )
        
        if conditionals:
            line = conditionals[0]
            self.questions.append(
                f"What condition are you checking on line {line}? When will it be true?"
            )
        
        if loops:
            line = loops[0]
            self.questions.append(
                f"How many iterations will the loop on line {line} perform? Why?"
            )
        
        # Generic question
        self.questions.append(
            "Modify the script to also display the current date. Do it now."
        )
        
        if self.questions:
            self.passed = True
            self.feedback = f"Generated {len(self.questions)} questions for oral verification"
        else:
            self.feedback = "Could not generate questions"
        
        return self.passed
    
    def get_questions(self) -> List[str]:
        """Returns generated questions."""
        return self.questions


# =============================================================================
# TEST DEFINITIONS
# =============================================================================

def get_homework_tests(config: Optional[Dict] = None) -> List[TestCase]:
    """
    Define all tests for Seminar 1 homework.
    
    Args:
        config: Optional configuration from assignment generator for variants
        
    Returns:
        List of TestCase objects
    """
    
    # Default values or from config
    if config:
        root = config['structure']['root']
        dirs = config['structure']['required_dirs']
        files = config['structure']['required_files']
        aliases = config['bashrc']['aliases']
        function = config['bashrc']['function']
    else:
        # Standard values (for non-randomised assignments)
        root = 'project'
        dirs = ['project/src', 'project/docs', 'project/tests']
        files = ['project/src/main.sh', 'project/src/variables.sh']
        aliases = ['ll', 'cls']
        function = 'mkcd'
    
    required_files = files if config else [
        'project/src/main.sh', 'project/src/variables.sh',
        'project/src/system_info.sh', 'project/docs/README.md',
        'project/tests/test_globbing.sh']
    if len(required_files) < 5:
        raise ValueError('Variant config requires main, variables, information, README and globbing paths')
    main_path, variables_path, info_path, readme_path, glob_path = required_files[:5]
    patterns = config.get('globbing', {}).get('patterns', ['*.txt', 'file?.txt']) if config else ['*.txt', 'file?.txt', '*[0-9]*', '.[!.]*']
    return [
        # Exercise 1: Project Structure (20 points)
        DirectoryStructureTest(
            "E1.1: Project structure",
            10,
            "Verify directory structure exists",
            dirs
        ),
        FileExistsTest(
            "E1.2: README.md",
            5,
            "Verify README file exists",
            readme_path
        ),
        FileExistsTest(
            "E1.3: Main script",
            5,
            "Verify main script exists",
            main_path
        ),
        
        # Exercise 2: Variables Script (25 points)
        BashSyntaxTest(
            "E2.1: variables.sh syntax",
            10,
            "Verify variables script syntax",
            variables_path
        ),
        BashExecutionTest(
            "E2.2: variables.sh execution",
            15,
            "Verify script execution and output",
            variables_path,
            expected_pattern=r'(USER|HOME|SHELL|PATH)'
        ),
        
        # Exercise 3: .bashrc Configuration (25 points)
        BashrcConfigTest(
            "E3.1: Aliases",
            10,
            "Verify required aliases present",
            required_aliases=aliases
        ),
        BashrcConfigTest(
            "E3.2: mkcd function",
            10,
            "Verify required function present",
            required_functions=[function]
        ),
        BashrcConfigTest(
            "E3.3: Export PATH",
            5,
            "Verify PATH modification",
            required_exports=['PATH']
        ),
        
        # Exercise 4: free-form demonstration; all assigned patterns need review.
        GlobbingTest(
            "E4: Submitted globbing demonstration", 20,
            "Review the student's script and its explanation of every assigned pattern",
            [], ', '.join(patterns), [], script_path=glob_path
        ),

        # Exercise 5: Integrated Script (10 points)
        BashSyntaxTest(
            "E5.1: System info script",
            5,
            "Verify info script syntax",
            info_path
        ),
        BashExecutionTest(
            "E5.2: System info execution",
            5,
            "Verify system information display",
            info_path,
            expected_pattern=r'(Linux|Ubuntu|user|home)'
        ),
        
        # Questions for oral verification (does not award points automatically)
        CodeUnderstandingTest(
            "ORAL: Generated questions",
            0,  # Points awarded manually
            "Questions for oral verification",
            variables_path
        ),
    ]


# =============================================================================
# GRADER
# =============================================================================

class Grader:
    """Orchestrates running all tests and generating report."""
    
    def __init__(self, student_dir: Path, config: Optional[Dict] = None):
        self.student_dir = student_dir.resolve()
        self.config = config
        self.tests = get_homework_tests(config)
        self.results: Dict[str, dict] = {}
        self.total_points = 0
        self.earned_points = 0
        self.oral_questions: List[str] = []
    
    def run_all_tests(self) -> None:
        """Run all tests."""
        print(f"\n{Colours.CYAN}{'=' * 70}{Colours.NC}")
        print(f"{Colours.WHITE}{Colours.BOLD}  AUTO-GRADER: Seminar 1 Bash Shell{Colours.NC}")
        print(f"{Colours.CYAN}{'=' * 70}{Colours.NC}\n")
        
        log_info(f"Directory verified: {self.student_dir}")
        log_info(f"Timestamp: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")
        
        for test in self.tests:
            # Points of 0 are for special tests (oral)
            if test.points > 0:
                self.total_points += test.points
            
            print(f"{Colours.YELLOW}> {test.name}{Colours.NC}")
            print(f"  {test.description}")
            
            try:
                passed = test.run(self.student_dir)
                
                if passed and test.points > 0:
                    self.earned_points += test.points
                    log_success(f"{test.feedback} (+{test.points}p)")
                elif passed and test.points == 0:
                    log_info(f"{test.feedback}")
                    # Collect questions for oral
                    if isinstance(test, CodeUnderstandingTest):
                        self.oral_questions = test.get_questions()
                else:
                    log_error(f"{test.feedback} (0/{test.points}p)")
                    
            except Exception as e:
                log_error(f"Test error: {str(e)}")
            
            self.results[test.name] = {
                'passed': test.passed,
                'points': test.points if test.passed else 0,
                'max_points': test.points,
                'feedback': test.feedback,
                'pending_manual_review': test.pending_manual_review
            }
            print()
    
    def print_summary(self) -> None:
        """Display results summary."""
        print(f"{Colours.CYAN}{'=' * 70}{Colours.NC}")
        print(f"{Colours.WHITE}{Colours.BOLD}  FINAL RESULT{Colours.NC}")
        print(f"{Colours.CYAN}{'=' * 70}{Colours.NC}\n")
        
        passed_tests = sum(1 for r in self.results.values() if r['passed'] and r['max_points'] > 0)
        total_tests = sum(1 for r in self.results.values() if r['max_points'] > 0)
        
        percentage = (self.earned_points / self.total_points * 100) if self.total_points > 0 else 0
        
        print(f"  Tests passed: {passed_tests}/{total_tests}")
        print(f"  Automatic score: {Colours.BOLD}{self.earned_points}/{self.total_points}{Colours.NC} ({percentage:.1f}%)\n")
        
        if any(t.pending_manual_review for t in self.tests):
            print("  INCOMPLETE: globbing evidence requires manual review; automatic subtotal is not a final grade.")

        print("  Assessment status: PENDING_POLICY / MANUAL_REVIEW_REQUIRED")
        print("  The automatic subtotal does not establish a final grade or task eligibility.\n")

        # Questions for oral verification
        if self.oral_questions:
            print(f"{Colours.CYAN}{'-' * 70}{Colours.NC}")
            print(f"{Colours.WHITE}{Colours.BOLD}  QUESTIONS FOR ORAL VERIFICATION{Colours.NC}")
            print(f"{Colours.CYAN}{'-' * 70}{Colours.NC}")
            print(f"  {Colours.YELLOW}[!] Student must answer 2 of the following:{Colours.NC}\n")
            for i, q in enumerate(self.oral_questions[:5], 1):
                print(f"  {i}. {q}")
            print()
        
        # Details
        print(f"{Colours.CYAN}Details:{Colours.NC}")
        for name, result in self.results.items():
            if result['max_points'] > 0:
                status = f"{Colours.GREEN}[PASS]{Colours.NC}" if result['passed'] else f"{Colours.RED}[FAIL]{Colours.NC}"
                print(f"  {status} {name}: {result['points']}/{result['max_points']}p")
        print()
    
    def export_json(self, output_path: Path) -> None:
        """Export results in JSON format."""
        report = {
            'timestamp': datetime.now().isoformat(),
            'student_dir': str(self.student_dir),
            'total_points': self.total_points,
            'earned_points': self.earned_points,
            'percentage': self.earned_points / self.total_points * 100 if self.total_points > 0 else 0,
            'tests': self.results,
            'oral_questions': self.oral_questions,
            'assessment_complete': False,
            'assessment_status': 'PENDING_POLICY',
            'pending_manual_points': sum(t.points for t in self.tests if t.pending_manual_review),
        }
        
        with open(output_path, 'w', encoding='utf-8') as f:
            json.dump(report, f, indent=2, ensure_ascii=False)
        
        log_info(f"Report exported: {output_path}")


# =============================================================================
# MAIN
# =============================================================================

def main():
    import argparse
    parser = argparse.ArgumentParser(description='Seminar 1 diagnostic checker; assessment policy remains pending')
    parser.add_argument('student_directory', type=Path)
    parser.add_argument('--json', dest='json_output', type=Path, help='Export the diagnostic record')
    parser.add_argument('--config', type=Path, help='Assignment generator JSON configuration')
    args = parser.parse_args()
    student_dir = args.student_directory.resolve()
    if not student_dir.is_dir():
        parser.error(f'Not a submission directory: {student_dir}')
    config = None
    if args.config:
        try:
            config = json.loads(args.config.read_text(encoding='utf-8'))
        except (OSError, ValueError) as exc:
            parser.error(f'Cannot read configuration: {exc}')
    grader = Grader(student_dir, config)
    grader.run_all_tests()
    grader.print_summary()
    if args.json_output:
        grader.export_json(args.json_output)



if __name__ == '__main__':
    main()
