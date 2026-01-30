#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
S02_01_autograder.py - Autograder for Seminar 2 Assignment
Operating Systems | ASE Bucharest - CSIE

Automatic evaluator for student homework. Checks structure, syntax, 
functionality and code style. Now includes AI pattern detection that
actually affects the score (graduated penalties).

Usage:
    python3 S02_01_autograder.py <homework_directory>
    python3 S02_01_autograder.py ~/student_homework/
    python3 S02_01_autograder.py --help

Version: 2.0 | January 2025
Note: v2.0 switches to English filenames and adds AI penalty system
"""

import logging
import os
import sys
import json
import subprocess
import argparse
import re
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Tuple, Optional, Any
from dataclasses import dataclass, field, asdict
from enum import Enum

# Logging setup — import shared utilities from kit lib
sys.path.insert(0, str(Path(__file__).parent.parent.parent.parent / 'lib'))
from logging_utils import setup_logging

logger = setup_logging(__name__)


# ============================================================================
# CONFIGURATION
# ============================================================================

class Colours:
    """ANSI colours for terminal output."""
    RED = '\033[1;31m'
    GREEN = '\033[1;32m'
    YELLOW = '\033[1;33m'
    BLUE = '\033[1;34m'
    MAGENTA = '\033[1;35m'
    CYAN = '\033[1;36m'
    WHITE = '\033[1;37m'
    DIM = '\033[2m'
    RESET = '\033[0m'
    
    @classmethod
    def disable(cls):
        """Disable colours for non-TTY output."""
        for attr in dir(cls):
            if attr.isupper() and not attr.startswith('_'):
                setattr(cls, attr, '')

# Disable colours if output isn't a terminal
if not sys.stdout.isatty():
    Colours.disable()

# Expected files - ENGLISH names (standardised in v2.0)
# Points reflect complexity: ex5 is worth more because it's integrative
EXPECTED_FILES = {
    'ex1_operators.sh': 10,
    'ex2_redirection.sh': 12,
    'ex3_filters.sh': 12,
    'ex4_loops.sh': 11,
    'ex5_integrated.sh': 15
}

# Maximum scores by category
MAX_SCORES = {
    'structure': 10,
    'syntax': 20,
    'ex1_operators': 10,
    'ex2_redirection': 12,
    'ex3_filters': 12,
    'ex4_loops': 11,
    'ex5_integrated': 15,
    'style': 10
}

# Patterns for automated checks
# Built up over several semesters of seeing what students actually write
PATTERNS = {
    'operators': {
        'sequential': r';\s*(?!;)',
        'and': r'&&',
        'or': r'\|\|',
        'background': r'&\s*$|&\s*[^&]',
        'pipe': r'\|(?!\|)'
    },
    'redirect': {
        'stdout': r'>\s*[^>]|1>',
        'append': r'>>',
        'stderr': r'2>',
        'stderr_stdout': r'2>&1|&>',
        'stdin': r'<\s*[^<]',
        'here_doc': r'<<\s*[\'"]?\w+[\'"]?',
        'here_string': r'<<<'
    },
    'filters': {
        'sort': r'\bsort\b',
        'uniq': r'\buniq\b',
        'cut': r'\bcut\b',
        'paste': r'\bpaste\b',
        'tr': r'\btr\b',
        'wc': r'\bwc\b',
        'head': r'\bhead\b',
        'tail': r'\btail\b',
        'tee': r'\btee\b',
        'awk': r'\bawk\b',
        'sed': r'\bsed\b',
        'grep': r'\bgrep\b'
    },
    'loops': {
        'for': r'\bfor\b.*\bdo\b',
        'while': r'\bwhile\b.*\bdo\b',
        'until': r'\buntil\b.*\bdo\b',
        'break': r'\bbreak\b',
        'continue': r'\bcontinue\b'
    },
    'good_practices': {
        'shebang': r'^#!/bin/bash|^#!/usr/bin/env bash',
        'comments': r'#[^!].*$',
        'quoting': r'"\$\w+"|\'\$\w+\'',
        'functions': r'\bfunction\s+\w+|\w+\s*\(\s*\)\s*\{',
        'error_handling': r'set\s+-e|set\s+-o\s+errexit|\|\|\s*exit',
        'help': r'--help|-h\)'
    },
    'bugs': {
        # The classic {1..$n} trap - see it every semester
        'brace_var': r'\{\d+\.\.\$\w+\}|\{\$\w+\.\.\d+\}|\{\$\w+\.\.\$\w+\}',
        # cat | while read loses variables - took me ages to debug this myself once
        'cat_pipe_while': r'\bcat\s+[^|]+\|\s*while\s+read',
        'unquoted_var': r'\$\w+[^"\'}\s]|\s\$\w+\s',
    }
}

# AI Content Indicators
# These patterns suggest (but don't prove) AI generation
# Built from analysing ~50 confirmed AI submissions in 2024
AI_INDICATORS = {
    'comment_patterns': [
        # Students under time pressure don't write comments like this
        (r'#\s*(?:This|The following|Below|Here)\s+(?:script|function|code|section).{40,}', 
         'Elaborate introductory comment (unusual for time-pressured students)'),
        # Python docstring style in Bash - dead giveaway
        (r'#\s*(?:Args|Arguments|Returns|Raises|Example|Usage):', 
         'Python docstring style in Bash'),
        (r'#\s*@(?:param|return|author|version|since)', 
         'Javadoc-style documentation'),
    ],
    'structure_patterns': [
        (r'(^\s{4}[a-z].*\n){10,}', 
         'Suspiciously uniform indentation'),
        (r'(echo\s+"[^"]{20,}"\s*\n){5,}', 
         'Consecutive similar echo statements'),
    ],
    'naming_patterns': [
        # First-years don't naturally write user_input_value
        (r'\b(?:user_input_value|file_content_data|loop_iteration_counter|'
         r'error_message_text|temporary_file_path|current_directory_path|'
         r'command_output_result)\b', 
         'Overly descriptive variable names'),
        (r'(?:[a-z]+_[a-z]+_[a-z]+){3,}', 
         'Consistent multi-word snake_case (unusual for beginners)'),
    ],
    'perfectionism_patterns': [
        (r'(#[^\n]{20,}\n)+function\s+\w+|'
         r'(#[^\n]{20,}\n)+\w+\s*\(\s*\)\s*\{', 
         'Every function has header comment'),
        (r'(trap\s+[^\n]+\n.*){3,}', 
         'Multiple trap statements'),
    ]
}


# ============================================================================
# DATA CLASSES
# ============================================================================

@dataclass
class CheckResult:
    """Result of a single check."""
    name: str
    passed: bool
    points: float
    max_points: float
    message: str
    details: List[str] = field(default_factory=list)

@dataclass
class FileResult:
    """Result for one file."""
    filename: str
    exists: bool
    syntax_ok: bool
    executable: bool
    checks: List[CheckResult] = field(default_factory=list)
    score: float = 0.0
    max_score: float = 0.0

@dataclass
class AIIndicatorResult:
    """AI detection result."""
    indicator_name: str
    description: str
    matches_found: int
    sample_matches: List[str] = field(default_factory=list)

@dataclass
class GradeReport:
    """Complete evaluation report."""
    student_dir: str
    timestamp: str
    files: Dict[str, FileResult] = field(default_factory=dict)
    total_score: float = 0.0
    max_score: float = 100.0
    percentage: float = 0.0
    grade: str = "F"
    warnings: List[str] = field(default_factory=list)
    errors: List[str] = field(default_factory=list)
    ai_indicators: List[AIIndicatorResult] = field(default_factory=list)
    ai_penalty_applied: float = 0.0


# ============================================================================
# HELPER FUNCTIONS
# ============================================================================

def print_header(title: str) -> None:
    """Display a formatted header."""
    width = 70
    print()
    print(f"{Colours.CYAN}{'═' * width}{Colours.RESET}")
    print(f"{Colours.CYAN}║{Colours.RESET} {Colours.WHITE}{title:<{width-4}}{Colours.RESET} {Colours.CYAN}║{Colours.RESET}")
    print(f"{Colours.CYAN}{'═' * width}{Colours.RESET}")

def print_subheader(title: str) -> None:
    print(f"\n{Colours.YELLOW}━━━ {title} ━━━{Colours.RESET}\n")

def print_check(result: CheckResult) -> None:
    """Show result of one check."""
    if result.passed:
        status = f"{Colours.GREEN}✓ PASS{Colours.RESET}"
    else:
        status = f"{Colours.RED}✗ FAIL{Colours.RESET}"
    
    points_str = f"[{result.points:.1f}/{result.max_points:.1f}]"
    print(f"  {status} {result.name:<40} {Colours.CYAN}{points_str}{Colours.RESET}")
    
    if result.details:
        for detail in result.details[:3]:
            print(f"       {Colours.DIM}{detail}{Colours.RESET}")

def run_command(cmd: List[str], timeout: int = 10) -> Tuple[int, str, str]:
    """Run command, return (code, stdout, stderr)."""
    try:
        result = subprocess.run(cmd, capture_output=True, text=True, timeout=timeout)
        return result.returncode, result.stdout, result.stderr
    except subprocess.TimeoutExpired:
        return -1, "", "Timeout expired"
    except Exception as e:
        return -1, "", str(e)

def check_syntax(filepath: str) -> Tuple[bool, str]:
    """Check bash syntax with bash -n."""
    code, _, stderr = run_command(['bash', '-n', filepath])
    return code == 0, stderr.strip()

def count_pattern_matches(content: str, pattern: str) -> int:
    return len(re.findall(pattern, content, re.MULTILINE))

def has_pattern(content: str, pattern: str) -> bool:
    return bool(re.search(pattern, content, re.MULTILINE))


# ============================================================================
# AI INDICATOR DETECTION
# ============================================================================

def check_ai_indicators(student_dir: Path) -> List[AIIndicatorResult]:
    """
    Check for AI generation indicators.
    
    These are heuristics, not proof. But when multiple indicators fire,
    it's worth a closer look. Added penalty system in v2.0.
    """
    results = []
    all_content = ""
    
    for filename in EXPECTED_FILES.keys():
        filepath = student_dir / filename
        if filepath.exists():
            try:
                with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
                    all_content += f"\n# --- {filename} ---\n" + f.read()
            except Exception:
                continue
    
    if not all_content:
        return results
    
    # Check each indicator category
    for category, patterns in AI_INDICATORS.items():
        for pattern, description in patterns:
            matches = re.findall(pattern, all_content, re.MULTILINE | re.IGNORECASE)
            if matches:
                samples = [m[:80] + "..." if len(str(m)) > 80 else str(m) 
                          for m in matches[:3]]
                results.append(AIIndicatorResult(
                    indicator_name=category,
                    description=description,
                    matches_found=len(matches),
                    sample_matches=samples
                ))
    
    # Comment-to-code ratio check
    # Real students under-comment; AI over-comments
    lines = all_content.split('\n')
    comment_lines = sum(1 for l in lines if l.strip().startswith('#') 
                       and not l.strip().startswith('#!'))
    code_lines = sum(1 for l in lines if l.strip() and not l.strip().startswith('#'))
    
    if code_lines > 0:
        ratio = comment_lines / code_lines
        if ratio > 0.5:
            results.append(AIIndicatorResult(
                indicator_name='comment_ratio',
                description=f'High comment ratio ({ratio:.0%}) - unusual for students',
                matches_found=comment_lines,
                sample_matches=[f'{comment_lines} comments / {code_lines} code lines']
            ))
    
    # Style consistency check
    # Beginners have inconsistent formatting; AI is suspiciously uniform
    indent_styles = set()
    for filename in EXPECTED_FILES.keys():
        filepath = student_dir / filename
        if filepath.exists():
            try:
                with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
                    content = f.read()
                    if '    ' in content:
                        indent_styles.add('4spaces')
                    if '\t' in content:
                        indent_styles.add('tabs')
                    if '  ' in content and '    ' not in content:
                        indent_styles.add('2spaces')
            except Exception:
                continue
    
    if len(indent_styles) == 1 and code_lines > 100:
        results.append(AIIndicatorResult(
            indicator_name='style_consistency',
            description='Perfectly consistent formatting across all files',
            matches_found=1,
            sample_matches=[f'Single indent style across {len(EXPECTED_FILES)} files']
        ))
    
    return results


def apply_ai_penalty(report: GradeReport) -> None:
    """
    Apply graduated penalty based on AI indicator count.
    
    New in v2.0. The philosophy: we don't ban AI, but we penalise
    obvious copy-paste without understanding. Light touch for minor
    signals, heavier for obvious AI dumps.
    """
    count = len(report.ai_indicators)
    
    if count == 0:
        return
    elif count <= 2:
        # Minor signals - just warn, no penalty
        report.warnings.append(
            "Minor AI patterns detected. Ensure you understand the code."
        )
    elif count <= 4:
        # Moderate signals - 5% penalty
        penalty = report.max_score * 0.05
        report.total_score = max(0, report.total_score - penalty)
        report.ai_penalty_applied = penalty
        report.warnings.append(
            f"AI patterns detected: -{penalty:.1f} points. Review recommended."
        )
    else:
        # Strong signals - 10% penalty + mandatory review
        penalty = report.max_score * 0.10
        report.total_score = max(0, report.total_score - penalty)
        report.ai_penalty_applied = penalty
        report.warnings.append(
            f"Significant AI patterns: -{penalty:.1f} points. Manual review scheduled."
        )


def print_ai_indicators(indicators: List[AIIndicatorResult], penalty: float) -> None:
    """Display AI detection results."""
    if not indicators:
        print(f"  {Colours.GREEN}✓{Colours.RESET} No significant AI indicators detected")
        return
    
    print(f"  {Colours.YELLOW}⚠ AI PATTERNS DETECTED{Colours.RESET}")
    if penalty > 0:
        print(f"  {Colours.RED}Penalty applied: -{penalty:.1f} points{Colours.RESET}")
    print()
    
    for indicator in indicators:
        print(f"    • {Colours.YELLOW}{indicator.description}{Colours.RESET}")
        print(f"      Found: {indicator.matches_found} occurrence(s)")
        if indicator.sample_matches:
            for sample in indicator.sample_matches[:2]:
                sample_short = sample[:60] + "..." if len(sample) > 60 else sample
                print(f"      {Colours.DIM}Example: {sample_short}{Colours.RESET}")
        print()
    
    print(f"  {Colours.DIM}These are heuristic signals. Verify via Part 6 oral check.{Colours.RESET}")


# ============================================================================
# EXERCISE CHECKS
# ============================================================================

def check_structure(student_dir: Path) -> List[CheckResult]:
    """Check that required files exist with proper setup."""
    results = []
    
    for filename, max_points in EXPECTED_FILES.items():
        filepath = student_dir / filename
        exists = filepath.exists()
        
        if exists:
            with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
                first_line = f.readline().strip()
            
            has_shebang = first_line.startswith('#!')
            is_executable = os.access(filepath, os.X_OK)
            
            if has_shebang and is_executable:
                result = CheckResult(
                    name=f"File {filename}",
                    passed=True,
                    points=2.0,
                    max_points=2.0,
                    message="Present with shebang and +x",
                    details=[f"Shebang: {first_line}"]
                )
            else:
                details = []
                if not has_shebang:
                    details.append("Missing shebang (#!/bin/bash)")
                if not is_executable:
                    details.append("Not executable (run: chmod +x)")
                
                result = CheckResult(
                    name=f"File {filename}",
                    passed=False,
                    points=1.0,
                    max_points=2.0,
                    message="Partial setup",
                    details=details
                )
        else:
            result = CheckResult(
                name=f"File {filename}",
                passed=False,
                points=0.0,
                max_points=2.0,
                message="Missing!",
                details=[]
            )
        
        results.append(result)
    
    return results


def check_ex1_operators(filepath: Path) -> List[CheckResult]:
    """Ex1 - Control operators. Usually students do well here."""
    results = []
    
    if not filepath.exists():
        return [CheckResult(
            name="Ex1 - Missing file",
            passed=False, points=0, max_points=10,
            message="File ex1_operators.sh does not exist"
        )]
    
    with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
        content = f.read()
    
    checks = [
        ('&&', PATTERNS['operators']['and'], 2.0),
        ('||', PATTERNS['operators']['or'], 2.0),
        ('& (background)', PATTERNS['operators']['background'], 2.0),
        ('| (pipe)', PATTERNS['operators']['pipe'], 2.0),
    ]
    
    for name, pattern, points in checks:
        found = has_pattern(content, pattern)
        results.append(CheckResult(
            name=f"Ex1 - Operator {name}",
            passed=found,
            points=points if found else 0,
            max_points=points,
            message=f"Uses {name}" if found else f"Missing {name}",
            details=[]
        ))
    
    # Test execution
    code, stdout, stderr = run_command(['bash', str(filepath)])
    ok = code == 0
    results.append(CheckResult(
        name="Ex1 - Executes cleanly",
        passed=ok,
        points=2.0 if ok else 0,
        max_points=2.0,
        message="No errors" if ok else f"Error: {stderr[:80]}",
        details=[]
    ))
    
    return results


def check_ex2_redirection(filepath: Path) -> List[CheckResult]:
    """Ex2 - Redirection. The 2>&1 order trips everyone up."""
    results = []
    
    if not filepath.exists():
        return [CheckResult(
            name="Ex2 - Missing file",
            passed=False, points=0, max_points=12,
            message="File ex2_redirection.sh does not exist"
        )]
    
    with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
        content = f.read()
    
    checks = [
        ('> (stdout)', PATTERNS['redirect']['stdout'], 2.0),
        ('>> (append)', PATTERNS['redirect']['append'], 2.0),
        ('2> (stderr)', PATTERNS['redirect']['stderr'], 2.0),
        ('2>&1 or &>', PATTERNS['redirect']['stderr_stdout'], 2.0),
        ('<< (here doc)', PATTERNS['redirect']['here_doc'], 2.0),
    ]
    
    for name, pattern, points in checks:
        found = has_pattern(content, pattern)
        results.append(CheckResult(
            name=f"Ex2 - {name}",
            passed=found,
            points=points if found else 0,
            max_points=points,
            message=f"Uses {name}" if found else f"Missing {name}"
        ))
    
    code, _, _ = run_command(['bash', str(filepath)])
    ok = code == 0
    results.append(CheckResult(
        name="Ex2 - Executes cleanly",
        passed=ok,
        points=2.0 if ok else 0,
        max_points=2.0,
        message="No errors" if ok else "Execution errors"
    ))
    
    return results


def check_ex3_filters(filepath: Path) -> List[CheckResult]:
    """Ex3 - Filters and pipes. Watch for the uniq-without-sort trap."""
    results = []
    
    if not filepath.exists():
        return [CheckResult(
            name="Ex3 - Missing file",
            passed=False, points=0, max_points=12,
            message="File ex3_filters.sh does not exist"
        )]
    
    with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
        content = f.read()
    
    checks = [
        ('sort', PATTERNS['filters']['sort'], 2.0),
        ('uniq', PATTERNS['filters']['uniq'], 2.0),
        ('cut', PATTERNS['filters']['cut'], 2.0),
        ('tr', PATTERNS['filters']['tr'], 2.0),
    ]
    
    for name, pattern, points in checks:
        found = has_pattern(content, pattern)
        results.append(CheckResult(
            name=f"Ex3 - Filter {name}",
            passed=found,
            points=points if found else 0,
            max_points=points,
            message=f"Uses {name}" if found else f"Missing {name}"
        ))
    
    # The classic uniq trap
    sort_uniq = r'\bsort\b[^|]*\|\s*uniq\b'
    has_sort_uniq = has_pattern(content, sort_uniq)
    results.append(CheckResult(
        name="Ex3 - sort | uniq pattern",
        passed=has_sort_uniq,
        points=2.0 if has_sort_uniq else 0,
        max_points=2.0,
        message="Correct sort | uniq" if has_sort_uniq else "Missing sort before uniq!",
        details=["uniq alone only removes CONSECUTIVE duplicates"] if not has_sort_uniq else []
    ))
    
    # Pipeline complexity
    pipes = content.count('|')
    ok = pipes >= 3
    results.append(CheckResult(
        name="Ex3 - Pipeline complexity",
        passed=ok,
        points=2.0 if ok else 1.0,
        max_points=2.0,
        message=f"{pipes} pipes" if ok else f"Only {pipes} pipes (need 3+)"
    ))
    
    return results


def check_ex4_loops(filepath: Path) -> List[CheckResult]:
    """Ex4 - Loops. Two classic bugs: {1..$n} and cat|while."""
    results = []
    
    if not filepath.exists():
        return [CheckResult(
            name="Ex4 - Missing file",
            passed=False, points=0, max_points=11,
            message="File ex4_loops.sh does not exist"
        )]
    
    with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
        content = f.read()
    
    # Basic loop checks
    for name, pattern, points in [
        ('for', PATTERNS['loops']['for'], 3.0),
        ('while', PATTERNS['loops']['while'], 3.0),
    ]:
        found = has_pattern(content, pattern)
        results.append(CheckResult(
            name=f"Ex4 - Loop {name}",
            passed=found,
            points=points if found else 0,
            max_points=points,
            message=f"Uses {name}" if found else f"Missing {name}"
        ))
    
    # Bug check: {1..$N} - brace expansion happens before variable expansion
    has_bug = has_pattern(content, PATTERNS['bugs']['brace_var'])
    results.append(CheckResult(
        name="Ex4 - Avoids {1..$N} bug",
        passed=not has_bug,
        points=2.0 if not has_bug else 0,
        max_points=2.0,
        message="No brace bug" if not has_bug else "BUG: {1..$N} doesn't work!",
        details=["Use $(seq 1 $N) or C-style for loop"] if has_bug else []
    ))
    
    # Bug check: cat | while read - subshell loses variables
    has_bug2 = has_pattern(content, PATTERNS['bugs']['cat_pipe_while'])
    results.append(CheckResult(
        name="Ex4 - Avoids cat|while bug",
        passed=not has_bug2,
        points=2.0 if not has_bug2 else 0,
        max_points=2.0,
        message="No subshell bug" if not has_bug2 else "BUG: cat|while loses variables!",
        details=["Use: while read line; do ...; done < file"] if has_bug2 else []
    ))
    
    # Check for correct while read pattern
    correct = r'while.*read.*<\s*\S+'
    has_correct = has_pattern(content, correct)
    results.append(CheckResult(
        name="Ex4 - while read < file",
        passed=has_correct,
        points=1.0 if has_correct else 0,
        max_points=1.0,
        message="Correct pattern" if has_correct else "Missing while read < file"
    ))
    
    return results


def check_ex5_integrated(filepath: Path) -> List[CheckResult]:
    """Ex5 - Integrated script. This one separates the wheat from the chaff."""
    results = []
    
    if not filepath.exists():
        return [CheckResult(
            name="Ex5 - Missing file",
            passed=False, points=0, max_points=15,
            message="File ex5_integrated.sh does not exist"
        )]
    
    with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
        content = f.read()
        lines = content.split('\n')
    
    # Size check
    code_lines = len([l for l in lines if l.strip() and not l.strip().startswith('#')])
    ok = code_lines >= 30
    results.append(CheckResult(
        name="Ex5 - Script size",
        passed=ok,
        points=3.0 if ok else 1.0,
        max_points=3.0,
        message=f"{code_lines} lines of code" if ok else f"Too short ({code_lines} lines)"
    ))
    
    # Functions
    func_count = count_pattern_matches(content, PATTERNS['good_practices']['functions'])
    has_funcs = func_count > 0
    results.append(CheckResult(
        name="Ex5 - Uses functions",
        passed=has_funcs,
        points=3.0 if func_count >= 2 else (1.5 if func_count == 1 else 0),
        max_points=3.0,
        message=f"{func_count} functions" if has_funcs else "No functions defined"
    ))
    
    # Error handling
    has_err = has_pattern(content, PATTERNS['good_practices']['error_handling'])
    results.append(CheckResult(
        name="Ex5 - Error handling",
        passed=has_err,
        points=3.0 if has_err else 0,
        max_points=3.0,
        message="Has error handling" if has_err else "No error handling"
    ))
    
    # Arguments
    arg_pat = r'\$[1-9#@*]|getopts|\$\{[1-9]'
    has_args = has_pattern(content, arg_pat)
    results.append(CheckResult(
        name="Ex5 - Argument processing",
        passed=has_args,
        points=3.0 if has_args else 0,
        max_points=3.0,
        message="Processes arguments" if has_args else "No argument handling"
    ))
    
    # Help option
    has_help = has_pattern(content, PATTERNS['good_practices']['help'])
    results.append(CheckResult(
        name="Ex5 - Help/usage",
        passed=has_help,
        points=3.0 if has_help else 0,
        max_points=3.0,
        message="Has --help" if has_help else "No help message"
    ))
    
    return results


def check_style(student_dir: Path) -> List[CheckResult]:
    """Check overall code style across all files."""
    results = []
    total_comments = 0
    total_lines = 0
    quoted_vars = 0
    unquoted_vars = 0
    
    for filename in EXPECTED_FILES.keys():
        filepath = student_dir / filename
        if not filepath.exists():
            continue
        
        with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
            content = f.read()
            lines = content.split('\n')
        
        total_lines += len(lines)
        total_comments += count_pattern_matches(content, PATTERNS['good_practices']['comments'])
        quoted_vars += count_pattern_matches(content, r'"\$\w+"')
        unquoted_vars += count_pattern_matches(content, r'\$\w+(?!["\'])')
    
    # Comment ratio
    ratio = total_comments / max(total_lines, 1)
    ok = ratio > 0.05
    results.append(CheckResult(
        name="Style - Comments",
        passed=ok,
        points=5.0 if ok else (2.0 if total_comments > 5 else 0),
        max_points=5.0,
        message=f"{total_comments} comments ({ratio*100:.1f}%)" if ok else "Too few comments"
    ))
    
    # Quoting
    q_ratio = quoted_vars / max(quoted_vars + unquoted_vars, 1)
    ok = q_ratio > 0.3 or quoted_vars > 5
    results.append(CheckResult(
        name="Style - Variable quoting",
        passed=ok,
        points=5.0 if ok else 2.0,
        max_points=5.0,
        message=f"{quoted_vars} quoted, {unquoted_vars} unquoted" if ok else "Insufficient quoting"
    ))
    
    return results


# ============================================================================
# MAIN EVALUATION
# ============================================================================

def grade_submission(student_dir: str) -> GradeReport:
    """Run all checks and produce final report."""
    student_path = Path(student_dir).resolve()
    
    report = GradeReport(
        student_dir=str(student_path),
        timestamp=datetime.now().isoformat()
    )
    
    if not student_path.exists():
        report.errors.append(f"Directory {student_path} does not exist!")
        return report
    
    all_checks: List[CheckResult] = []
    
    # 1. Structure
    print_subheader("📁 STRUCTURE CHECK")
    for check in check_structure(student_path):
        print_check(check)
        all_checks.append(check)
    
    # 2. Exercise 1
    print_subheader("⚡ EXERCISE 1: OPERATORS")
    for check in check_ex1_operators(student_path / 'ex1_operators.sh'):
        print_check(check)
        all_checks.append(check)
    
    # 3. Exercise 2
    print_subheader("📤 EXERCISE 2: REDIRECTION")
    for check in check_ex2_redirection(student_path / 'ex2_redirection.sh'):
        print_check(check)
        all_checks.append(check)
    
    # 4. Exercise 3
    print_subheader("🔧 EXERCISE 3: FILTERS")
    for check in check_ex3_filters(student_path / 'ex3_filters.sh'):
        print_check(check)
        all_checks.append(check)
    
    # 5. Exercise 4
    print_subheader("🔄 EXERCISE 4: LOOPS")
    for check in check_ex4_loops(student_path / 'ex4_loops.sh'):
        print_check(check)
        all_checks.append(check)
    
    # 6. Exercise 5
    print_subheader("🎯 EXERCISE 5: INTEGRATED SCRIPT")
    for check in check_ex5_integrated(student_path / 'ex5_integrated.sh'):
        print_check(check)
        all_checks.append(check)
    
    # 7. Style
    print_subheader("🎨 STYLE CHECK")
    for check in check_style(student_path):
        print_check(check)
        all_checks.append(check)
    
    # Calculate score before AI penalty
    report.total_score = sum(c.points for c in all_checks)
    report.max_score = sum(c.max_points for c in all_checks)
    
    # 8. AI Detection - now affects score
    print_subheader("🤖 AI CONTENT ANALYSIS")
    report.ai_indicators = check_ai_indicators(student_path)
    apply_ai_penalty(report)
    print_ai_indicators(report.ai_indicators, report.ai_penalty_applied)
    
    # Final percentage and grade
    report.percentage = (report.total_score / report.max_score * 100) if report.max_score > 0 else 0
    
    if report.percentage >= 90:
        report.grade = "A"
    elif report.percentage >= 80:
        report.grade = "B"
    elif report.percentage >= 70:
        report.grade = "C"
    elif report.percentage >= 60:
        report.grade = "D"
    elif report.percentage >= 50:
        report.grade = "E"
    else:
        report.grade = "F"
    
    return report


def print_final_report(report: GradeReport) -> None:
    """Display final results."""
    print_header("📊 FINAL REPORT")
    
    print(f"\n  {Colours.WHITE}Directory:{Colours.RESET} {report.student_dir}")
    print(f"  {Colours.WHITE}Date:{Colours.RESET}     {report.timestamp}")
    print()
    
    # Progress bar
    bar_width = 40
    filled = int(report.percentage / 100 * bar_width)
    bar = '█' * filled + '░' * (bar_width - filled)
    
    colour = Colours.GREEN if report.percentage >= 70 else (
        Colours.YELLOW if report.percentage >= 50 else Colours.RED)
    
    print(f"  {Colours.WHITE}Score:{Colours.RESET}     {report.total_score:.1f} / {report.max_score:.1f}")
    if report.ai_penalty_applied > 0:
        print(f"  {Colours.RED}AI Penalty:{Colours.RESET} -{report.ai_penalty_applied:.1f}")
    print(f"  {Colours.WHITE}Percentage:{Colours.RESET} {colour}{report.percentage:.1f}%{Colours.RESET}")
    print(f"  {Colours.WHITE}Progress:{Colours.RESET}  [{colour}{bar}{Colours.RESET}]")
    print()
    print(f"  {Colours.WHITE}FINAL GRADE:{Colours.RESET}  {colour}{Colours.WHITE}{report.grade}{Colours.RESET}")
    
    if report.warnings:
        print(f"\n  {Colours.YELLOW}⚠ WARNINGS:{Colours.RESET}")
        for w in report.warnings:
            print(f"    • {w}")
    
    if report.errors:
        print(f"\n  {Colours.RED}✗ ERRORS:{Colours.RESET}")
        for e in report.errors:
            print(f"    • {e}")
    
    print()


def save_report(report: GradeReport, output_path: str) -> None:
    """Save report as JSON."""
    report_dict = {
        'student_dir': report.student_dir,
        'timestamp': report.timestamp,
        'total_score': report.total_score,
        'max_score': report.max_score,
        'percentage': report.percentage,
        'grade': report.grade,
        'ai_penalty_applied': report.ai_penalty_applied,
        'warnings': report.warnings,
        'errors': report.errors,
        'ai_indicators': [
            {
                'indicator': ind.indicator_name,
                'description': ind.description,
                'matches': ind.matches_found
            } for ind in report.ai_indicators
        ]
    }
    
    with open(output_path, 'w', encoding='utf-8') as f:
        json.dump(report_dict, f, indent=2, ensure_ascii=False)
    
    print(f"  {Colours.GREEN}✓{Colours.RESET} Report saved: {output_path}")


# ============================================================================
# MAIN
# ============================================================================

def main():
    parser = argparse.ArgumentParser(
        description='Autograder for OS Seminar 2 homework',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python3 S02_01_autograder.py ~/my_homework/
  python3 S02_01_autograder.py ./submissions/student_name/
  python3 S02_01_autograder.py --output report.json ./homework/
        """
    )
    
    parser.add_argument('directory', help='Directory with student homework')
    parser.add_argument('-o', '--output', help='JSON output file', default=None)
    parser.add_argument('-q', '--quiet', action='store_true', 
                       help='Quiet mode (final score only)')
    
    args = parser.parse_args()
    
    if args.quiet:
        Colours.disable()
    
    logger.info(f"Starting autograder for: {args.directory}")
    print_header("🎓 AUTOGRADER - Seminar 2 OS (v2.0)")
    
    report = grade_submission(args.directory)
    print_final_report(report)
    
    if args.output:
        save_report(report, args.output)
        logger.info(f"Report saved: {args.output}")
    
    logger.info(f"Final grade: {report.grade} ({report.final_score:.1f}/100)")
    
    # Exit code based on grade
    if report.grade in ['A', 'B', 'C']:
        sys.exit(0)
    elif report.grade in ['D', 'E']:
        sys.exit(1)
    else:
        sys.exit(2)


if __name__ == '__main__':
    main()
