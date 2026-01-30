#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
╔══════════════════════════════════════════════════════════════════════════════╗
║              QUIZ GENERATOR - SEMINAR 5-6                                     ║
║              Operating Systems | Bucharest UES - CSIE                         ║
╠══════════════════════════════════════════════════════════════════════════════╣
║  Generates personalised quizzes from the question bank for:                   ║
║  • Advanced utilities (find, xargs, locate)                                   ║
║  • Parameters and options in scripts ($@, getopts, shift)                     ║
║  • Unix permissions system (chmod, chown, umask, SUID/SGID)                   ║
║  • Automation with cron (format, expressions, best practices)                 ║
╠══════════════════════════════════════════════════════════════════════════════╣
║  USAGE:                                                                       ║
║    python3 S03_02_quiz_generator.py --generate 10                             ║
║    python3 S03_02_quiz_generator.py --category permissions --count 5          ║
║    python3 S03_02_quiz_generator.py --export quiz.json                        ║
║    python3 S03_02_quiz_generator.py --interactive                             ║
║    python3 S03_02_quiz_generator.py --difficulty hard --count 15              ║
╚══════════════════════════════════════════════════════════════════════════════╝

Version: 1.0
Date: January 2025
"""

import argparse
import json
import random
import sys
import os
import time
from dataclasses import dataclass, field, asdict
from enum import Enum, auto
from typing import List, Optional, Dict, Any, Tuple
from datetime import datetime
import html
import textwrap

# 
# CONSTANTS AND CONFIGURATION
# 

VERSION = "1.0"
PROGRAM_NAME = "Quiz Generator - SEM03"

# ANSI colours for terminal
class Colours:
    """ANSI colours for terminal formatting."""
    HEADER = '\033[95m'
    BLUE = '\033[94m'
    CYAN = '\033[96m'
    GREEN = '\033[92m'
    YELLOW = '\033[93m'
    RED = '\033[91m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'
    END = '\033[0m'
    
    # Background
    BG_GREEN = '\033[42m'
    BG_RED = '\033[41m'
    BG_YELLOW = '\033[43m'
    BG_BLUE = '\033[44m'

def color_text(text: str, color: str, use_color: bool = True) -> str:
    """Apply colour to text if enabled."""
    if not use_color:
        return text
    return f"{color}{text}{Colours.END}"

# 
# DATA MODELS
# 

class Category(Enum):
    """Question categories."""
    FIND_XARGS = "find_xargs"
    PARAMETERS = "parameters"
    PERMISSIONS = "permissions"
    CRON = "cron"
    MIXED = "mixed"

class Difficulty(Enum):
    """Difficulty levels."""
    EASY = "easy"
    MEDIUM = "medium"
    HARD = "hard"

class QuestionType(Enum):
    """Question types."""
    MULTIPLE_CHOICE = "multiple_choice"
    TRUE_FALSE = "true_false"
    FILL_BLANK = "fill_blank"
    CODE_OUTPUT = "code_output"
    PRACTICAL = "practical"

@dataclass
class Question:
    """Model for a question."""
    id: str
    category: Category
    difficulty: Difficulty
    question_type: QuestionType
    text: str
    options: List[str]  # For MCQ
    correct_answer: str  # Index for MCQ, text for other types
    explanation: str
    code_snippet: Optional[str] = None
    tags: List[str] = field(default_factory=list)
    points: int = 1
    misconception_addressed: Optional[str] = None
    
    def to_dict(self) -> Dict[str, Any]:
        """Convert to dictionary."""
        return {
            'id': self.id,
            'category': self.category.value,
            'difficulty': self.difficulty.value,
            'question_type': self.question_type.value,
            'text': self.text,
            'options': self.options,
            'correct_answer': self.correct_answer,
            'explanation': self.explanation,
            'code_snippet': self.code_snippet,
            'tags': self.tags,
            'points': self.points,
            'misconception_addressed': self.misconception_addressed
        }

@dataclass
class QuizResult:
    """Result of a quiz."""
    total_questions: int
    correct_answers: int
    wrong_answers: int
    skipped: int
    score_percentage: float
    time_taken_seconds: float
    questions_results: List[Dict[str, Any]]
    categories_breakdown: Dict[str, Dict[str, int]]
    
    @property
    def grade(self) -> str:
        """Calculate estimated grade (4-10)."""
        if self.score_percentage >= 90:
            return "10"
        elif self.score_percentage >= 80:
            return "9"
        elif self.score_percentage >= 70:
            return "8"
        elif self.score_percentage >= 60:
            return "7"
        elif self.score_percentage >= 50:
            return "6"
        elif self.score_percentage >= 40:
            return "5"
        else:
            return "4"

# 
# QUESTION BANK
# 

class QuestionBank:
    """Question bank for quizzes."""
    
    def __init__(self):
        self.questions: List[Question] = []
        self._load_questions()
    
    def _load_questions(self):
        """Load all questions into the bank."""
        self._load_find_xargs_questions()
        self._load_parameters_questions()
        self._load_permissions_questions()
        self._load_cron_questions()
    
    # 
    # FIND AND XARGS QUESTIONS
    # 
    
    def _load_find_xargs_questions(self):
        """Questions about find and xargs."""
        
        # F01: find -type (Easy)
        self.questions.append(Question(
            id="F01",
            category=Category.FIND_XARGS,
            difficulty=Difficulty.EASY,
            question_type=QuestionType.MULTIPLE_CHOICE,
            text="What does the command display: find /home -type f -name '*.txt'?",
            options=[
                "A) All .txt files in /home (including subdirectories)",
                "B) Only .txt files in /home (without subdirectories)",
                "C) All .txt directories in /home",
                "D) All files containing '.txt' in their name"
            ],
            correct_answer="A",
            explanation="""The find command searches recursively by default. The -type f 
option restricts to regular files (not directories), and -name '*.txt' 
filters by extension. To limit depth, you would need -maxdepth.""",
            tags=["find", "-type", "-name", "recursive"],
            misconception_addressed="find only searches in the specified directory"
        ))
        
        # F02: find -maxdepth (Easy)
        self.questions.append(Question(
            id="F02",
            category=Category.FIND_XARGS,
            difficulty=Difficulty.EASY,
            question_type=QuestionType.MULTIPLE_CHOICE,
            text="Which find command searches ONLY in the current directory, without subdirectories?",
            options=[
                "A) find . -name '*.log'",
                "B) find . -maxdepth 1 -name '*.log'",
                "C) find . -depth 1 -name '*.log'",
                "D) find . -nodirs -name '*.log'"
            ],
            correct_answer="B",
            explanation="""-maxdepth 1 restricts the search to the specified directory 
(level 0 = the directory itself, level 1 = direct contents).
The -depth option performs depth-first traversal, it doesn't limit depth.""",
            tags=["find", "-maxdepth"],
            misconception_addressed="find doesn't search recursively by default"
        ))
        
        # F03: locate vs find (Medium)
        self.questions.append(Question(
            id="F03",
            category=Category.FIND_XARGS,
            difficulty=Difficulty.MEDIUM,
            question_type=QuestionType.MULTIPLE_CHOICE,
            text="""You just created the file ~/project/config.txt. 
Immediately after, you run: locate config.txt
What happens?""",
            options=[
                "A) Finds the file instantly",
                "B) Doesn't find the file (database not updated)",
                "C) Error - locate doesn't search in home",
                "D) Finds all config.txt files, including the new one"
            ],
            correct_answer="B",
            explanation="""locate uses a precompiled database (updatedb), 
which is usually updated daily via cron. Recently created files 
don't appear until the next updatedb. For real-time searching, use find.""",
            tags=["locate", "updatedb", "vs find"],
            misconception_addressed="locate searches in real-time like find"
        ))
        
        # F04: find -exec (Medium)
        self.questions.append(Question(
            id="F04",
            category=Category.FIND_XARGS,
            difficulty=Difficulty.MEDIUM,
            question_type=QuestionType.CODE_OUTPUT,
            text="What is the difference between these two commands?",
            code_snippet="""# Command 1:
find . -name "*.txt" -exec echo {} \\;

# Command 2:
find . -name "*.txt" -exec echo {} +""",
            options=[
                "A) They are identical - both display each file found",
                "B) \\; executes the command for each file; + sends all files as arguments",
                "C) + executes commands in parallel; \\; in series",
                "D) \\; is incorrect syntax, only + works"
            ],
            correct_answer="B",
            explanation="""With \\; (backslash-semicolon), -exec runs the command separately 
for each file found. With +, -exec accumulates files and 
executes the command once with all of them as arguments (more efficient).
Visual example:
  \\; → echo file1.txt; echo file2.txt; echo file3.txt
  +  → echo file1.txt file2.txt file3.txt""",
            tags=["find", "-exec", "performance"],
            points=2
        ))
        
        # F05: find -size (Medium)
        self.questions.append(Question(
            id="F05",
            category=Category.FIND_XARGS,
            difficulty=Difficulty.MEDIUM,
            question_type=QuestionType.MULTIPLE_CHOICE,
            text="What does the command find: find /var/log -size +100M?",
            options=[
                "A) Files of exactly 100MB",
                "B) Files larger than 100MB",
                "C) Files smaller than 100MB",
                "D) Files of at least 100MB"
            ],
            correct_answer="B",
            explanation="""+100M means strictly greater than 100 megabytes.
Complete syntax:
  +N = greater than N
  -N = less than N
  N  = exactly N (in 512-byte units without suffix)
Suffixes: c (bytes), k (KB), M (MB), G (GB)""",
            tags=["find", "-size"],
            points=1
        ))
        
        # F06: find -mtime (Medium)
        self.questions.append(Question(
            id="F06",
            category=Category.FIND_XARGS,
            difficulty=Difficulty.MEDIUM,
            question_type=QuestionType.MULTIPLE_CHOICE,
            text="Which command finds files modified in the last 24 hours?",
            options=[
                "A) find . -mtime 1",
                "B) find . -mtime -1",
                "C) find . -mtime +1",
                "D) find . -mtime 0"
            ],
            correct_answer="B",
            explanation="""-mtime measures in 24-hour days. Values:
  -mtime -1 = modified less than 1 day ago (last ~24h)
  -mtime 1  = modified between 1 and 2 days ago
  -mtime +1 = modified more than 1 day ago
  -mtime 0  = modified in the last 24h (similar to -1)
For minutes, use -mmin.""",
            tags=["find", "-mtime", "time"],
            points=2
        ))
        
        # F07: find with OR (Medium)
        self.questions.append(Question(
            id="F07",
            category=Category.FIND_XARGS,
            difficulty=Difficulty.MEDIUM,
            question_type=QuestionType.MULTIPLE_CHOICE,
            text="How do you find files with extension .txt OR .log?",
            options=[
                "A) find . -name '*.txt' -name '*.log'",
                "B) find . -name '*.txt' -o -name '*.log'",
                "C) find . -name '*.txt,*.log'",
                "D) find . -name '*.txt' | find . -name '*.log'"
            ],
            correct_answer="B",
            explanation="""The -o (OR) operator combines alternative conditions. 
Consecutive conditions without an operator are implicit AND.
Complete syntax with grouping for complexity:
  find . \\( -name '*.txt' -o -name '*.log' \\) -type f
Parentheses must be escaped in shell.""",
            tags=["find", "OR", "operators"],
            points=2
        ))
        
        # F08: xargs basics (Easy)
        self.questions.append(Question(
            id="F08",
            category=Category.FIND_XARGS,
            difficulty=Difficulty.EASY,
            question_type=QuestionType.MULTIPLE_CHOICE,
            text="What does the command do: find . -name '*.txt' | xargs wc -l?",
            options=[
                "A) Displays .txt files",
                "B) Counts lines in each .txt file found",
                "C) Counts .txt files",
                "D) Deletes .txt files"
            ],
            correct_answer="B",
            explanation="""xargs receives input from stdin and transforms it into 
arguments for the specified command. wc -l counts lines.
Conceptually equivalent to:
  wc -l file1.txt file2.txt file3.txt ...""",
            tags=["xargs", "wc", "pipe"],
            points=1
        ))
        
        # F09: xargs with spaces (Hard)
        self.questions.append(Question(
            id="F09",
            category=Category.FIND_XARGS,
            difficulty=Difficulty.HARD,
            question_type=QuestionType.CODE_OUTPUT,
            text="You have the file 'my document.txt'. What happens with this command?",
            code_snippet="""echo "my document.txt" | xargs rm""",
            options=[
                "A) Deletes the file 'my document.txt'",
                "B) Tries to delete 'my' and 'document.txt' separately (error!)",
                "C) Syntax error",
                "D) Does nothing"
            ],
            correct_answer="B",
            explanation="""xargs by default splits input by whitespace.
'my document.txt' becomes two arguments: 'my' and 'document.txt'.
Solutions:
  1) find . -print0 | xargs -0 rm  (NUL separator)
  2) echo "my document.txt" | xargs -I{} rm "{}"
  3) find . -name "*.txt" -exec rm {} \\;""",
            tags=["xargs", "spaces", "security"],
            points=3,
            misconception_addressed="xargs automatically handles spaces"
        ))
        
        # F10: find -delete (Hard)
        self.questions.append(Question(
            id="F10",
            category=Category.FIND_XARGS,
            difficulty=Difficulty.HARD,
            question_type=QuestionType.MULTIPLE_CHOICE,
            text="""⚠️ WARNING: Which of these commands is DANGEROUS 
and should be avoided?""",
            options=[
                "A) find . -name '*.tmp' -print | xargs rm -i",
                "B) find . -name '*.tmp' -delete",
                "C) find . -delete -name '*.tmp'",
                "D) find . -name '*.tmp' -exec rm -i {} \\;"
            ],
            correct_answer="C",
            explanation="""⚠️ DANGER: The order of options in find matters!
In option C, -delete comes BEFORE -name, so:
1. find starts traversal
2. -delete DELETES each file/directory
3. -name only filters the output (too late!)

Result: ALL files and directories are deleted!

Golden rule: ALWAYS test with -print before -delete!""",
            tags=["find", "-delete", "security", "danger"],
            points=3,
            misconception_addressed="-delete is safe anywhere in the command"
        ))
        
        # F11: find -perm (Hard)
        self.questions.append(Question(
            id="F11",
            category=Category.FIND_XARGS,
            difficulty=Difficulty.HARD,
            question_type=QuestionType.MULTIPLE_CHOICE,
            text="What does: find /home -perm -002 find?",
            options=[
                "A) Files with exactly permission 002",
                "B) Files that have AT LEAST world-writable (others write)",
                "C) Files that are not world-writable",
                "D) Files with owner=002"
            ],
            correct_answer="B",
            explanation="""-perm with - prefix checks that the specified bits are set 
(there may be other bits set as well).

Syntax:
  -perm 644  → exactly 644
  -perm -644 → at least 644 (755 also matches)
  -perm /644 → any of the bits (r owner OR w owner OR r group...)

002 = -------w- (others write) - world-writable files!""",
            tags=["find", "-perm", "security"],
            points=3
        ))
        
        # F12: xargs -P (Hard)
        self.questions.append(Question(
            id="F12",
            category=Category.FIND_XARGS,
            difficulty=Difficulty.HARD,
            question_type=QuestionType.MULTIPLE_CHOICE,
            text="What does the -P option do in xargs?",
            options=[
                "A) Print - displays the command before execution",
                "B) Parallel - executes commands in parallel",
                "C) Prompt - asks for confirmation",
                "D) Path - specifies the working directory"
            ],
            correct_answer="B",
            explanation="""-P (--max-procs) specifies the maximum number of processes 
running simultaneously.

Examples:
  find . -name '*.jpg' | xargs -P 4 -I{} convert {} {}.png
  # Process 4 images simultaneously

  -P 0 = as many processes as possible
  -P 1 = sequential (default)

Very useful for CPU-intensive tasks!""",
            tags=["xargs", "-P", "parallel", "performance"],
            points=2
        ))
        
        # F13: find -newer (Medium)
        self.questions.append(Question(
            id="F13",
            category=Category.FIND_XARGS,
            difficulty=Difficulty.MEDIUM,
            question_type=QuestionType.MULTIPLE_CHOICE,
            text="What does: find . -newer reference.txt find?",
            options=[
                "A) Files with the same timestamp as reference.txt",
                "B) Files modified MORE RECENTLY than reference.txt",
                "C) Files older than reference.txt",
                "D) Files with the same content as reference.txt"
            ],
            correct_answer="B",
            explanation="""-newer FILE finds files with modification timestamp 
more recent than FILE.

Typical use for incremental backup:
  touch /tmp/last_backup  # at previous backup
  # ... time passes ...
  find /data -newer /tmp/last_backup -type f
  # finds files modified since last backup""",
            tags=["find", "-newer", "backup"],
            points=2
        ))
        
        # F14: xargs -I (Medium)
        self.questions.append(Question(
            id="F14",
            category=Category.FIND_XARGS,
            difficulty=Difficulty.MEDIUM,
            question_type=QuestionType.CODE_OUTPUT,
            text="What does this command do?",
            code_snippet="""find . -name "*.txt" | xargs -I{} cp {} {}.backup""",
            options=[
                "A) Copies each .txt to .txt.backup",
                "B) Error - {} cannot be used twice",
                "C) Copies all .txt into a single .backup file",
                "D) Moves files to the backup directory"
            ],
            correct_answer="A",
            explanation="""-I{} defines a placeholder that is replaced with 
each line of input.

Equivalent to:
  cp file1.txt file1.txt.backup
  cp file2.txt file2.txt.backup
  ...

Note: With -I, by default one line is processed per execution.""",
            tags=["xargs", "-I", "placeholder"],
            points=2
        ))
        
        # F15: find NOT (Easy)
        self.questions.append(Question(
            id="F15",
            category=Category.FIND_XARGS,
            difficulty=Difficulty.EASY,
            question_type=QuestionType.MULTIPLE_CHOICE,
            text="How do you find all files that ARE NOT .txt?",
            options=[
                "A) find . -name '!*.txt'",
                "B) find . ! -name '*.txt'",
                "C) find . -not '*.txt'",
                "D) find . -exclude '*.txt'"
            ],
            correct_answer="B",
            explanation="""! or -not negates the following condition.
It must be placed BEFORE the condition to negate.

Examples:
  find . ! -name '*.txt'        # not .txt
  find . ! -type d              # not directories
  find . ! \\( -name '*.txt' -o -name '*.log' \\)  # neither .txt nor .log""",
            tags=["find", "NOT", "operators"],
            points=1
        ))
    
    # 
    # PARAMETERS AND SCRIPTS QUESTIONS
    # 
    
    def _load_parameters_questions(self):
        """Questions about parameters and getopts."""
        
        # P01: $@ vs $* (Medium)
        self.questions.append(Question(
            id="P01",
            category=Category.PARAMETERS,
            difficulty=Difficulty.MEDIUM,
            question_type=QuestionType.CODE_OUTPUT,
            text="Given the script and execution:",
            code_snippet="""#!/bin/bash
for arg in "$@"; do echo "[$arg]"; done
echo "---"
for arg in "$*"; do echo "[$arg]"; done

# Execution: ./script.sh "hello world" test""",
            options=[
                "A) [hello world] [test] --- [hello world test]",
                "B) [hello] [world] [test] --- [hello] [world] [test]",
                "C) [hello world] [test] --- [hello world] [test]",
                "D) [hello world test] --- [hello world] [test]"
            ],
            correct_answer="A",
            explanation=""""$@" preserves arguments as separate entities (each
in its own quotes), while "$*" combines them into a single string.

With "$@": "hello world" and "test" → 2 iterations
With "$*": "hello world test" → 1 iteration

⚠️ IMPORTANT: Without quotes, both behave the same and 
                split on whitespace!""",
            tags=["$@", "$*", "arguments"],
            points=2,
            misconception_addressed="$@ and $* are identical"
        ))
        
        # P02: ${10} (Easy)
        self.questions.append(Question(
            id="P02",
            category=Category.PARAMETERS,
            difficulty=Difficulty.EASY,
            question_type=QuestionType.MULTIPLE_CHOICE,
            text="In a script with 15 arguments, how do you access argument 10?",
            options=[
                "A) $10",
                "B) ${10}",
                "C) $[10]",
                "D) $(10)"
            ],
            correct_answer="B",
            explanation="""$10 is interpreted as $1 followed by the character '0'.
For arguments >= 10, you need braces: ${10}, ${11}, etc.

Example:
  ./script.sh a b c d e f g h i j k l m n o
  echo $10   # displays: a0
  echo ${10} # displays: j""",
            tags=["parameters", "positional", "braces"],
            points=1,
            misconception_addressed="$10 works directly"
        ))
        
        # P03: shift (Medium)
        self.questions.append(Question(
            id="P03",
            category=Category.PARAMETERS,
            difficulty=Difficulty.MEDIUM,
            question_type=QuestionType.CODE_OUTPUT,
            text="What does this script display?",
            code_snippet="""#!/bin/bash
echo "Before: $1 $2 $3 $#"
shift 2
echo "After: $1 $2 $3 $#"

# Execution: ./script.sh A B C D E""",
            options=[
                "A) Before: A B C 5 | After: C D E 3",
                "B) Before: A B C 5 | After: A B C 3",
                "C) Before: A B C 5 | After: C D  3",
                "D) Error - shift destroys all arguments"
            ],
            correct_answer="A",
            explanation="""shift N removes the first N arguments, shifting the rest.

Before: $1=A, $2=B, $3=C, $4=D, $5=E, $#=5
After shift 2:
  - A and B are removed
  - $1=C (was $3), $2=D (was $4), $3=E (was $5)
  - $#=3

shift without argument = shift 1""",
            tags=["shift", "parameters"],
            points=2
        ))
        
        # P04: getopts optstring (Medium)
        self.questions.append(Question(
            id="P04",
            category=Category.PARAMETERS,
            difficulty=Difficulty.MEDIUM,
            question_type=QuestionType.MULTIPLE_CHOICE,
            text="""In getopts, what does the optstring "a:b:c" mean?""",
            options=[
                "A) -a, -b, -c all require an argument",
                "B) -a and -b require an argument, -c does not",
                "C) -a, -b, -c are mandatory",
                "D) : separates incompatible options"
            ],
            correct_answer="B",
            explanation=""": after a letter means the option requires an argument.

"a:b:c" means:
  -a ARG  (argument required)
  -b ARG  (argument required)
  -c      (no argument)

Valid example: ./script.sh -a val1 -b val2 -c
Invalid example: ./script.sh -a -b val (missing arg for -a)""",
            tags=["getopts", "optstring"],
            points=2
        ))
        
        # P05: OPTARG (Easy)
        self.questions.append(Question(
            id="P05",
            category=Category.PARAMETERS,
            difficulty=Difficulty.EASY,
            question_type=QuestionType.MULTIPLE_CHOICE,
            text="What does the OPTARG variable contain in getopts?",
            options=[
                "A) The name of the current option",
                "B) The argument of the current option (if any)",
                "C) The total number of options",
                "D) The index of the current option"
            ],
            correct_answer="B",
            explanation="""OPTARG contains the argument value for the current option.

while getopts "f:v" opt; do
    case $opt in
        f) echo "File: $OPTARG" ;;  # OPTARG = argument for -f
        v) echo "Verbose mode" ;;     # OPTARG is not set
    esac
done

OPTIND contains the index of the next argument to process.""",
            tags=["getopts", "OPTARG"],
            points=1
        ))
        
        # P06: shift after getopts (Hard)
        self.questions.append(Question(
            id="P06",
            category=Category.PARAMETERS,
            difficulty=Difficulty.HARD,
            question_type=QuestionType.CODE_OUTPUT,
            text="What does this script display?",
            code_snippet="""#!/bin/bash
while getopts "v" opt; do
    case $opt in v) verbose=1 ;; esac
done
shift $((OPTIND - 1))
echo "Remaining arguments: $@"

# Execution: ./script.sh -v file1.txt file2.txt""",
            options=[
                "A) Remaining arguments: -v file1.txt file2.txt",
                "B) Remaining arguments: file1.txt file2.txt",
                "C) Remaining arguments: file2.txt",
                "D) Remaining arguments:"
            ],
            correct_answer="B",
            explanation="""OPTIND indicates the index of the first non-option argument.
After getopts, OPTIND=2 (first argument after -v).

shift $((OPTIND - 1)) removes all processed options,
leaving only the non-option arguments.

Standard pattern:
  while getopts "..." opt; do ... done
  shift $((OPTIND - 1))
  # Now $@ contains only arguments, not options""",
            tags=["getopts", "OPTIND", "shift"],
            points=3
        ))
        
        # P07: Default values (Medium)
        self.questions.append(Question(
            id="P07",
            category=Category.PARAMETERS,
            difficulty=Difficulty.MEDIUM,
            question_type=QuestionType.CODE_OUTPUT,
            text="What does it display?",
            code_snippet="""#!/bin/bash
NAME=""
echo "${NAME:-default}"
echo "${NAME:=assigned}"
echo "$NAME"
echo "${NAME:+replacement}"
echo "$NAME"

# No arguments at execution""",
            options=[
                "A) default, assigned, assigned, replacement, assigned",
                "B) default, default, , replacement, ",
                "C) default, assigned, , replacement, assigned",
                "D) default, assigned, assigned, assigned, assigned"
            ],
            correct_answer="A",
            explanation="""Expansions with default values:

${VAR:-default} → returns default if VAR is empty/unset (does NOT modify VAR)
${VAR:=assign}  → returns assign AND sets VAR to assign
${VAR:+alt}     → returns alt ONLY if VAR is set and non-empty

Step by step:
1. NAME="" (empty), ${NAME:-default} → "default"
2. ${NAME:=assigned} → NAME becomes "assigned", returns "assigned"
3. echo $NAME → "assigned"
4. ${NAME:+replacement} → NAME is set, returns "replacement"
5. echo $NAME → "assigned" (unchanged)""",
            tags=["expansions", "default", "variables"],
            points=2
        ))
        
        # P08: $# (Easy)
        self.questions.append(Question(
            id="P08",
            category=Category.PARAMETERS,
            difficulty=Difficulty.EASY,
            question_type=QuestionType.MULTIPLE_CHOICE,
            text="What does $# contain in a bash script?",
            options=[
                "A) The script's PID",
                "B) The number of arguments",
                "C) The exit code of the last command",
                "D) The script name"
            ],
            correct_answer="B",
            explanation="""Special variables:
$# = number of positional arguments
$0 = script name
$$ = PID of current shell
$? = exit code of last command
$! = PID of last background job
$- = current shell options""",
            tags=["special variables", "$#"],
            points=1
        ))
        
        # P09: Long options (Hard)
        self.questions.append(Question(
            id="P09",
            category=Category.PARAMETERS,
            difficulty=Difficulty.HARD,
            question_type=QuestionType.MULTIPLE_CHOICE,
            text="Why does this code NOT work for --verbose?",
            code_snippet="""while getopts "v-:verbose" opt; do
    case $opt in
        v) verbose=1 ;;
        verbose) verbose=1 ;;
    esac
done""",
            options=[
                "A) getopts doesn't support long options",
                "B) Missing : after verbose",
                "C) Case cannot have 'verbose' as a pattern",
                "D) Must use getopt instead of getopts"
            ],
            correct_answer="A",
            explanation="""getopts (bash built-in) supports ONLY short options!

For long options, alternatives:
1. Manual parsing with while/case:
   while [[ "$1" =~ ^- ]]; do
       case "$1" in
           -v|--verbose) verbose=1 ;;
       esac
       shift
   done

2. getopt (external command, not built-in):
   OPTS=$(getopt -o v -l verbose -- "$@")

3. Libraries: shflags, bash-argsparse""",
            tags=["getopts", "long options", "limitations"],
            points=3,
            misconception_addressed="getopts can parse --verbose"
        ))
        
        # P10: $0 (Easy)
        self.questions.append(Question(
            id="P10",
            category=Category.PARAMETERS,
            difficulty=Difficulty.EASY,
            question_type=QuestionType.MULTIPLE_CHOICE,
            text="What does $0 contain in the script /home/user/scripts/backup.sh?",
            options=[
                "A) backup.sh",
                "B) /home/user/scripts/backup.sh or ./backup.sh",
                "C) The first argument from execution",
                "D) Always the complete absolute path"
            ],
            correct_answer="B",
            explanation="""$0 contains exactly how the script was invoked:
  ./backup.sh           → $0 = "./backup.sh"
  /home/user/backup.sh  → $0 = "/home/user/backup.sh"
  bash backup.sh        → $0 = "backup.sh"

For just the name: basename "$0"
For the directory: dirname "$0" """,
            tags=["$0", "parameters"],
            points=1
        ))
        
        # P11: Arrays (Medium)
        self.questions.append(Question(
            id="P11",
            category=Category.PARAMETERS,
            difficulty=Difficulty.MEDIUM,
            question_type=QuestionType.CODE_OUTPUT,
            text="What does it display?",
            code_snippet="""#!/bin/bash
args=("$@")
echo "Count: ${#args[@]}"
echo "First: ${args[0]}"
echo "All: ${args[@]}"

# Execution: ./script.sh one "two three" four""",
            options=[
                "A) Count: 3, First: one, All: one two three four",
                "B) Count: 4, First: one, All: one two three four",
                "C) Count: 3, First: ./script.sh, All: one two three four",
                "D) Count: 3, First: one, All: one \"two three\" four"
            ],
            correct_answer="A",
            explanation="""args=("$@") creates an array from the script's arguments.

${#args[@]} = number of elements (3)
${args[0]}  = first element (one)
${args[@]}  = all elements (spaces in "two three" are preserved internally 
              but appear combined when displayed)

Array indices start at 0 (not 1 like $1).""",
            tags=["arrays", "$@", "parameters"],
            points=2
        ))
        
        # P12: Argument validation (Medium)
        self.questions.append(Question(
            id="P12",
            category=Category.PARAMETERS,
            difficulty=Difficulty.MEDIUM,
            question_type=QuestionType.MULTIPLE_CHOICE,
            text="What is the BEST way to check that the script receives exactly 2 arguments?",
            options=[
                "A) if [ $# != 2 ]; then usage; fi",
                "B) if [ $# -ne 2 ]; then usage; exit 1; fi",
                "C) if (( $# != 2 )); then usage; exit 1; fi",
                "D) B and C are both correct and complete"
            ],
            correct_answer="D",
            explanation="""Both B and C are correct:

[ $# -ne 2 ] - POSIX syntax, portable
(( $# != 2 )) - bash syntax, more readable

Both include exit 1 which is essential!
Option A: != works but is for strings,
            and exit is missing - the script continues!

Complete pattern:
if [[ $# -ne 2 ]]; then
    echo "Usage: $(basename $0) arg1 arg2" >&2
    exit 1
fi""",
            tags=["validation", "arguments", "best practice"],
            points=2
        ))
    
    # 
    # PERMISSIONS QUESTIONS
    # 
    
    def _load_permissions_questions(self):
        """Questions about the Unix permissions system."""
        
        # M01: x on directory (Medium)
        self.questions.append(Question(
            id="M01",
            category=Category.PERMISSIONS,
            difficulty=Difficulty.MEDIUM,
            question_type=QuestionType.MULTIPLE_CHOICE,
            text="""A directory has permissions: drwxr-x---
What CAN group members do?""",
            options=[
                "A) Can list contents (ls) and enter (cd)",
                "B) Can only list contents",
                "C) Can only enter the directory",
                "D) Cannot do anything"
            ],
            correct_answer="A",
            explanation="""For directories:
r = you can read the file list (ls)
x = you can access/traverse (cd, and access files if you know the name)
w = you can create/delete files in the directory

Group has r-x, so:
✓ can ls (r)
✓ can cd (x)
✗ cannot create/delete files (w missing)

⚠️ IMPORTANT: x on directory ≠ execute files!""",
            tags=["permissions", "directory", "r-x"],
            points=2,
            misconception_addressed="x on directory = can execute files in it"
        ))
        
        # M02: chmod octal (Easy)
        self.questions.append(Question(
            id="M02",
            category=Category.PERMISSIONS,
            difficulty=Difficulty.EASY,
            question_type=QuestionType.MULTIPLE_CHOICE,
            text="What permissions does chmod 644 set?",
            options=[
                "A) rwxr--r--",
                "B) rw-r--r--",
                "C) rw-rw-r--",
                "D) rw-------"
            ],
            correct_answer="B",
            explanation="""Octal calculation: each digit is the sum of r(4) + w(2) + x(1)

6 = 4+2   = rw-  (owner)
4 = 4     = r--  (group)
4 = 4     = r--  (others)

Result: rw-r--r--

Common values:
755 = rwxr-xr-x (public executable)
644 = rw-r--r-- (public file)
600 = rw------- (private file)
700 = rwx------ (private directory)""",
            tags=["chmod", "octal", "calculation"],
            points=1
        ))
        
        # M03: chmod 777 (Medium)
        self.questions.append(Question(
            id="M03",
            category=Category.PERMISSIONS,
            difficulty=Difficulty.MEDIUM,
            question_type=QuestionType.MULTIPLE_CHOICE,
            text="⚠️ Why is chmod 777 ALMOST ALWAYS a mistake?",
            options=[
                "A) It's invalid syntax",
                "B) Gives complete access to everyone - security vulnerability",
                "C) Deletes the file",
                "D) Requires root permissions"
            ],
            correct_answer="B",
            explanation="""777 = rwxrwxrwx - ALL users can:
- Read the file
- Modify the file  
- Execute the file (or for directories: create/delete in it)

⚠️ PROBLEMS:
1. Any user can modify/delete your files
2. On web server: attackers can upload/run malware
3. Scripts can be modified to do malicious things

🛡️ CORRECT SOLUTIONS:
- 755 for public directories
- 644 for public files
- 750/640 for group access
- 700/600 for private files""",
            tags=["chmod", "777", "security"],
            points=2,
            misconception_addressed="chmod 777 solves permission problems"
        ))
        
        # M04: umask (Hard)
        self.questions.append(Question(
            id="M04",
            category=Category.PERMISSIONS,
            difficulty=Difficulty.HARD,
            question_type=QuestionType.CODE_OUTPUT,
            text="With umask 027, what permissions will a newly created file have?",
            code_snippet="""umask 027
touch newfile.txt
ls -l newfile.txt""",
            options=[
                "A) -rw-r----- (640)",
                "B) -rwxr-x--- (750)",
                "C) -rw-rw-r-- (664)",
                "D) --------- (000)"
            ],
            correct_answer="A",
            explanation="""⚠️ umask REMOVES bits, doesn't set them!

New files start with 666 (no x), directories with 777.

Calculation for file:
  666  = rw-rw-rw-
- 027  = ---r-xrwx (umask = what is REMOVED)
= 640  = rw-r-----

umask 027:
- 0: nothing removed from owner (rw- remains)
- 2: w removed from group (rw- → r--)
- 7: everything removed from others (rw- → ---)

⚠️ NOTE: umask 077 is recommended for private files!""",
            tags=["umask", "default permissions"],
            points=3,
            misconception_addressed="umask sets permissions"
        ))
        
        # M05: SUID (Hard)
        self.questions.append(Question(
            id="M05",
            category=Category.PERMISSIONS,
            difficulty=Difficulty.HARD,
            question_type=QuestionType.MULTIPLE_CHOICE,
            text="""The file /usr/bin/passwd has: -rwsr-xr-x root root
What does 's' mean and why is it necessary?""",
            options=[
                "A) Sticky bit - can only be deleted by root",
                "B) SUID - runs with owner's (root) permissions, necessary to modify /etc/shadow",
                "C) Special symlink to root password",
                "D) Signed - file is cryptographically verified"
            ],
            correct_answer="B",
            explanation="""SUID (Set User ID) - 's' in owner's x position:
When a normal user runs passwd, the process runs with the 
owner's UID (root), not the user who launched it.

WHY IT'S NECESSARY:
- /etc/shadow (password hashes) is readable only by root
- Users need to be able to change their own password
- Solution: passwd is SUID root, can write to shadow

⚠️ SUID on bash script does NOT work! (security)
   Only works on binary executables.

Setting: chmod u+s file or chmod 4755 file""",
            tags=["SUID", "passwd", "security"],
            points=3,
            misconception_addressed="SUID works on bash scripts"
        ))
        
        # M06: SGID on directory (Hard)
        self.questions.append(Question(
            id="M06",
            category=Category.PERMISSIONS,
            difficulty=Difficulty.HARD,
            question_type=QuestionType.MULTIPLE_CHOICE,
            text="What does SGID set on a DIRECTORY do?",
            options=[
                "A) New files inherit the directory's group, not the creator's",
                "B) Only group members can access the directory",
                "C) Processes in the directory run with group permissions",
                "D) The directory becomes read-only for the group"
            ],
            correct_answer="A",
            explanation="""SGID on directory = group inheritance

Without SGID: new files have the creator's primary group
With SGID: new files have the parent directory's group

Useful for shared project directories:
  mkdir /project
  chgrp developers /project
  chmod g+s /project
  # Now all files will have the 'developers' group

Setting: chmod g+s dir or chmod 2755 dir
Check: drwxr-sr-x (s in group's x position)""",
            tags=["SGID", "directory", "sharing"],
            points=3
        ))
        
        # M07: Sticky bit (Medium)
        self.questions.append(Question(
            id="M07",
            category=Category.PERMISSIONS,
            difficulty=Difficulty.MEDIUM,
            question_type=QuestionType.MULTIPLE_CHOICE,
            text="""The directory /tmp has: drwxrwxrwt
What does 't' mean and what effect does it have?""",
            options=[
                "A) Temporary - files are automatically deleted",
                "B) Sticky bit - users can only delete their own files",
                "C) Trust - all users have full access",
                "D) Timestamp - access is logged"
            ],
            correct_answer="B",
            explanation="""Sticky bit (t in others' x position):

Without sticky: anyone with w on directory can delete ANY file
With sticky: you can only delete files where you are:
  - The file's owner
  - The directory's owner
  - Root

Essential for /tmp where everyone has write:
  - You can create temporary files
  - Nobody can delete your files (only you or root)

Setting: chmod +t dir or chmod 1777 dir
Check: drwxrwxrwt""",
            tags=["sticky bit", "/tmp", "security"],
            points=2
        ))
        
        # M08: chown (Easy)
        self.questions.append(Question(
            id="M08",
            category=Category.PERMISSIONS,
            difficulty=Difficulty.EASY,
            question_type=QuestionType.MULTIPLE_CHOICE,
            text="What does the command do: chown user:group file.txt?",
            options=[
                "A) Changes the file's permissions",
                "B) Changes owner to user and group to group",
                "C) Copies the file to user in the group group",
                "D) Checks if user is in the group group"
            ],
            correct_answer="B",
            explanation="""chown = change owner

Syntax:
  chown user file        # changes only owner
  chown user:group file  # changes owner and group
  chown :group file      # changes only group (or chgrp)
  chown -R user:group dir # recursive

⚠️ Only root can change the owner!
   Normal users can only change the group (to a group they belong to).""",
            tags=["chown", "owner", "group"],
            points=1
        ))
        
        # M09: chmod symbolic (Medium)
        self.questions.append(Question(
            id="M09",
            category=Category.PERMISSIONS,
            difficulty=Difficulty.MEDIUM,
            question_type=QuestionType.CODE_OUTPUT,
            text="What permissions result?",
            code_snippet="""# File starts with: -rw-r--r-- (644)
chmod u+x,g+w,o-r file.txt
ls -l file.txt""",
            options=[
                "A) -rwxrw---- (760)",
                "B) -rwxrw-r-- (764)",
                "C) -rwxr-xr-x (755)",
                "D) -rwxrw---x (761)"
            ],
            correct_answer="A",
            explanation="""Starting from rw-r--r-- (644):

u+x: owner +execute → rwx
g+w: group +write   → rw-
o-r: others -read   → ---

Result: rwxrw---- = 760

chmod symbolic syntax:
  u/g/o/a = user/group/others/all
  +/-/= = add/remove/set exact
  r/w/x = read/write/execute

You can combine: chmod u=rwx,g=rx,o= file""",
            tags=["chmod", "symbolic"],
            points=2
        ))
        
        # M10: -R vs X (Hard)
        self.questions.append(Question(
            id="M10",
            category=Category.PERMISSIONS,
            difficulty=Difficulty.HARD,
            question_type=QuestionType.MULTIPLE_CHOICE,
            text="What is the difference between these two commands?",
            code_snippet="""chmod -R a+x /dir
chmod -R a+X /dir""",
            options=[
                "A) They are identical",
                "B) x adds execute to all; X adds execute ONLY to directories and already executable files",
                "C) X is the silent version",
                "D) x is recursive, X is not"
            ],
            correct_answer="B",
            explanation="""X (uppercase) is SMART for x:

a+x: Adds execute to ALL files and directories
     → Text files become executable (unwanted!)

a+X: Adds execute ONLY to:
     - Directories (need x for access)
     - Files that ALREADY have x for someone

Recommended pattern for fixing permissions:
  chmod -R u=rwX,g=rX,o=rX /project

This sets:
  - Directories: 755
  - Non-executable files: 644
  - Executable files: 755""",
            tags=["chmod", "-R", "uppercase X"],
            points=3
        ))
        
        # M11: r without x on directory (Medium)
        self.questions.append(Question(
            id="M11",
            category=Category.PERMISSIONS,
            difficulty=Difficulty.MEDIUM,
            question_type=QuestionType.MULTIPLE_CHOICE,
            text="""A directory has: drw-r----- (640)
What happens when you do: ls /dir ?""",
            options=[
                "A) Lists contents normally",
                "B) Lists files but doesn't display details (-l)",
                "C) Displays errors for each file",
                "D) Permission denied"
            ],
            correct_answer="C",
            explanation="""r without x on directory = strange situation!

You can do ls and see the file NAMES (r = read list),
BUT you cannot access their metadata (x missing for traversal).

Result: ls -l /dir displays:
  ls: cannot access '/dir/file1': Permission denied
  ls: cannot access '/dir/file2': Permission denied
  ...but you still see the file names!

In practice, r without x on directories makes no sense.
Either give both (rx), or neither (---).""",
            tags=["permissions", "directory", "r vs x"],
            points=2
        ))
        
        # M12: w on file vs directory (Medium)
        self.questions.append(Question(
            id="M12",
            category=Category.PERMISSIONS,
            difficulty=Difficulty.MEDIUM,
            question_type=QuestionType.MULTIPLE_CHOICE,
            text="""The file /dir/file.txt has: -r--r--r-- (444)
The directory /dir/ has: drwxr-xrwx (757)
Can a user from 'others' DELETE file.txt?""",
            options=[
                "A) No, the file is read-only",
                "B) Yes, has w on directory",
                "C) No, would need w on file",
                "D) Only root can delete"
            ],
            correct_answer="B",
            explanation="""⚠️ To DELETE a file, you need w on the DIRECTORY, 
not the file!

Deletion = modifies the directory (removes the entry from directory).
You don't modify the file itself.

With w on directory you can:
- Create new files
- Delete any file (even read-only ones!)
- Rename files

Without w on file, you cannot modify the CONTENTS, 
but you can delete the file entirely.

Sticky bit ('t') prevents deletion of others' files!""",
            tags=["permissions", "w", "deletion"],
            points=2
        ))
        
        # M13: Reverse octal calculation (Easy)
        self.questions.append(Question(
            id="M13",
            category=Category.PERMISSIONS,
            difficulty=Difficulty.EASY,
            question_type=QuestionType.MULTIPLE_CHOICE,
            text="What octal permissions represent: rwxr-x--x?",
            options=[
                "A) 754",
                "B) 751",
                "C) 745",
                "D) 715"
            ],
            correct_answer="B",
            explanation="""Calculation:
Owner: rwx = 4+2+1 = 7
Group: r-x = 4+0+1 = 5
Others: --x = 0+0+1 = 1

Result: 751

Quick table:
--- = 0    r-- = 4
--x = 1    r-x = 5
-w- = 2    rw- = 6
-wx = 3    rwx = 7""",
            tags=["chmod", "octal", "calculation"],
            points=1
        ))
        
        # M14: Special permissions in octal (Hard)
        self.questions.append(Question(
            id="M14",
            category=Category.PERMISSIONS,
            difficulty=Difficulty.HARD,
            question_type=QuestionType.MULTIPLE_CHOICE,
            text="What does chmod 4755 set?",
            options=[
                "A) rwxr-xr-x with SUID",
                "B) rwxr-xr-x with SGID",
                "C) rwxr-xr-x with Sticky",
                "D) Error - invalid format"
            ],
            correct_answer="A",
            explanation="""4-digit format: SPECIAL-OWNER-GROUP-OTHERS

First digit (special bits):
4 = SUID  (s in owner's x position)
2 = SGID  (s in group's x position)
1 = Sticky (t in others' x position)

4755:
4 = SUID
755 = rwxr-xr-x

Display: -rwsr-xr-x

Possible combinations:
  6755 = SUID + SGID (4+2)
  1777 = Sticky (for /tmp)
  2755 = SGID on project directory""",
            tags=["SUID", "SGID", "sticky", "octal"],
            points=3
        ))
        
        # M15: ACL (Hard)
        self.questions.append(Question(
            id="M15",
            category=Category.PERMISSIONS,
            difficulty=Difficulty.HARD,
            question_type=QuestionType.MULTIPLE_CHOICE,
            text="What does '+' at the end of permissions indicate: -rw-r--r--+ ?",
            options=[
                "A) File has extended attributes",
                "B) File has ACL (Access Control List)",
                "C) File is compressed",
                "D) File is immutable"
            ],
            correct_answer="B",
            explanation="""'+' indicates the presence of ACLs (Access Control Lists).

ACLs allow granular permissions for specific users/groups,
beyond owner-group-others.

ACL commands:
  getfacl file        # view ACL
  setfacl -m u:john:rw file  # john can read/write
  setfacl -m g:dev:r file    # dev group can read
  setfacl -x u:john file     # remove ACL for john
  setfacl -b file            # remove all ACLs

For extended attributes ('.' instead of space) see:
  lsattr file
  chattr +i file  # immutable""",
            tags=["ACL", "getfacl", "setfacl"],
            points=3
        ))
    
    # 
    # CRON QUESTIONS
    # 
    
    def _load_cron_questions(self):
        """Questions about cron and automation."""
        
        # C01: Crontab format (Easy)
        self.questions.append(Question(
            id="C01",
            category=Category.CRON,
            difficulty=Difficulty.EASY,
            question_type=QuestionType.MULTIPLE_CHOICE,
            text="What is the correct format of a crontab line?",
            options=[
                "A) command minute hour day month dow",
                "B) minute hour day month dow command",
                "C) hour minute day month dow command",
                "D) dow month day hour minute command"
            ],
            correct_answer="B",
            explanation="""Crontab format (5 fields + command):

┌───────────── minute (0-59)
│ ┌─────────── hour (0-23)
│ │ ┌───────── day of month (1-31)
│ │ │ ┌─────── month (1-12 or jan-dec)
│ │ │ │ ┌───── day of week (0-7, 0=7=Sunday)
│ │ │ │ │
* * * * * command

Mnemonic: "Minutes Hours Day-of-month Month Day-of-week"
           or "M H DOM MON DOW" """,
            tags=["cron", "format", "crontab"],
            points=1
        ))
        
        # C02: */5 (Medium)
        self.questions.append(Question(
            id="C02",
            category=Category.CRON,
            difficulty=Difficulty.MEDIUM,
            question_type=QuestionType.MULTIPLE_CHOICE,
            text="When does it run: */5 * * * * /script.sh?",
            options=[
                "A) At 5 minutes after each hour",
                "B) Every 5 minutes (0, 5, 10, 15, ...)",
                "C) Every hour, for 5 minutes",
                "D) 5 minutes after the last execution"
            ],
            correct_answer="B",
            explanation="""*/N means "every N units".

*/5 in the minute field = at minutes: 0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55

⚠️ Does NOT mean "5 minutes after last execution"!
   Cron doesn't track when it last ran.

Other examples:
  */15 * * * *    # every 15 minutes
  0 */2 * * *     # every 2 hours (at minute 0)
  0 9-17 * * 1-5  # every hour, 9-17, Mon-Fri""",
            tags=["cron", "*/N", "interval"],
            points=2,
            misconception_addressed="*/5 = 5 minutes after last execution"
        ))
        
        # C03: crontab -r (Hard)
        self.questions.append(Question(
            id="C03",
            category=Category.CRON,
            difficulty=Difficulty.HARD,
            question_type=QuestionType.MULTIPLE_CHOICE,
            text="⚠️ What does the command do: crontab -r?",
            options=[
                "A) Reloads crontab",
                "B) Runs all jobs now",
                "C) DELETES the ENTIRE crontab without confirmation!",
                "D) Displays current crontab"
            ],
            correct_answer="C",
            explanation="""☠️ DANGER: crontab -r DELETES the entire crontab!

Crontab commands:
  -e = edit (opens editor)
  -l = list (displays)
  -r = REMOVE (deletes EVERYTHING, no confirmation!)
  -i = interactive (asks for confirmation with -r)

The 'e' and 'r' keys are ADJACENT on the keyboard!
A typing mistake can delete hours of work.

🛡️ PROTECTION: alias crontab='crontab -i'
   Or regular backup: crontab -l > ~/crontab_backup.txt""",
            tags=["crontab", "-r", "danger"],
            points=3,
            misconception_addressed="crontab -r removes only one job"
        ))
        
        # C04: Cron environment (Hard)
        self.questions.append(Question(
            id="C04",
            category=Category.CRON,
            difficulty=Difficulty.HARD,
            question_type=QuestionType.MULTIPLE_CHOICE,
            text="""A script works perfectly from the terminal but 
does NOT work when run by cron. 
What is the most likely cause?""",
            options=[
                "A) Cron cannot run scripts",
                "B) Cron has a minimal environment (different PATH, without your variables)",
                "C) The script has wrong permissions",
                "D) Cron runs as root"
            ],
            correct_answer="B",
            explanation="""⚠️ Cron does NOT load ~/.bashrc, ~/.profile, etc.!

Cron environment is MINIMAL:
  PATH=/usr/bin:/bin (much shorter!)
  SHELL=/bin/sh
  HOME set
  No DISPLAY, minimal LANG

SOLUTIONS:
1. Use absolute paths:
   /usr/bin/python3 /home/user/script.py

2. Define PATH in crontab:
   PATH=/usr/local/bin:/usr/bin:/bin
   * * * * * script.sh

3. Source profile in script:
   #!/bin/bash
   source ~/.bashrc

4. Wrapper with login shell:
   * * * * * /bin/bash -l -c '/path/to/script.sh' """,
            tags=["cron", "environment", "PATH", "debugging"],
            points=3,
            misconception_addressed="Cron has access to my variables"
        ))
        
        # C05: @reboot (Medium)
        self.questions.append(Question(
            id="C05",
            category=Category.CRON,
            difficulty=Difficulty.MEDIUM,
            question_type=QuestionType.MULTIPLE_CHOICE,
            text="When does it run: @reboot /home/user/startup.sh?",
            options=[
                "A) At every system restart",
                "B) At every cron service restart",
                "C) Once, at installation",
                "D) At OS boot, not at cron restart"
            ],
            correct_answer="B",
            explanation="""@reboot runs when CRON starts, not necessarily at OS boot!

In practice, cron starts at boot, so the effect is similar.
BUT: if you restart the cron service, the job runs again!

Special crontab strings:
  @reboot     - at cron startup
  @yearly     - 0 0 1 1 * (January 1, midnight)
  @monthly    - 0 0 1 * * (first day of month)
  @weekly     - 0 0 * * 0 (Sunday at midnight)
  @daily      - 0 0 * * * (midnight)
  @hourly     - 0 * * * * (every hour)

@midnight = @daily""",
            tags=["cron", "@reboot", "special strings"],
            points=2
        ))
        
        # C06: DOM vs DOW (Hard)
        self.questions.append(Question(
            id="C06",
            category=Category.CRON,
            difficulty=Difficulty.HARD,
            question_type=QuestionType.MULTIPLE_CHOICE,
            text="When does it run: 0 9 15 * 1?",
            options=[
                "A) On the 15th of the month, if it's Monday",
                "B) On the 15th of the month OR on any Monday",
                "C) Never - 15 and Monday exclude each other",
                "D) Syntax error"
            ],
            correct_answer="B",
            explanation="""⚠️ CRON TRAP: Day-of-month AND Day-of-week = OR!

If BOTH are specified (not *), cron uses OR:
  - Runs on the 15th of any month
  - OR on any Monday

To run on the 15th ONLY if it's Monday, you need a script:
  0 9 15 * * [ "$(date +\\%u)" = 1 ] && /script.sh

Or with modern cron (some implementations):
  0 9 15 * 1  # check your implementation!

This is one of cron's most confusing features!""",
            tags=["cron", "DOM", "DOW", "OR"],
            points=3
        ))
        
        # C07: Cron logging (Medium)
        self.questions.append(Question(
            id="C07",
            category=Category.CRON,
            difficulty=Difficulty.MEDIUM,
            question_type=QuestionType.MULTIPLE_CHOICE,
            text="How do you CORRECTLY redirect a cron job's output (including errors)?",
            options=[
                "A) * * * * * /script.sh > /var/log/script.log",
                "B) * * * * * /script.sh >> /var/log/script.log 2>&1",
                "C) * * * * * /script.sh 2>&1 >> /var/log/script.log",
                "D) * * * * * /script.sh &> /var/log/script.log"
            ],
            correct_answer="B",
            explanation="""Correct redirection with append:

>> = append (> overwrites)
2>&1 = redirect stderr to stdout

⚠️ ORDER MATTERS:
✓ >> file 2>&1  (correct - stderr goes where stdout is, i.e., file)
✗ 2>&1 >> file  (wrong - 2>&1 is evaluated first, stderr goes to original stdout)

Recommended pattern with timestamp:
  * * * * * /script.sh >> /var/log/script.$(date +\\%Y\\%m\\%d).log 2>&1

⚠️ In crontab, % must be escaped with \\""",
            tags=["cron", "logging", "redirection"],
            points=2
        ))
        
        # C08: at vs cron (Easy)
        self.questions.append(Question(
            id="C08",
            category=Category.CRON,
            difficulty=Difficulty.EASY,
            question_type=QuestionType.MULTIPLE_CHOICE,
            text="What is the main difference between cron and at?",
            options=[
                "A) cron is for root, at for normal users",
                "B) cron is for periodic tasks, at for one-time tasks",
                "C) at is faster than cron",
                "D) cron supports scripts, at only simple commands"
            ],
            correct_answer="B",
            explanation="""cron = PERIODIC tasks (repetitive)
at = ONE-TIME tasks (scheduled for a specific moment)

at examples:
  at now + 5 minutes
  at 15:30
  at midnight
  at tomorrow

Commands:
  atq    - list pending jobs
  atrm N - remove job N
  batch  - run when system is idle""",
            tags=["cron", "at", "comparison"],
            points=1
        ))
        
        # C09: cron.d (Medium)
        self.questions.append(Question(
            id="C09",
            category=Category.CRON,
            difficulty=Difficulty.MEDIUM,
            question_type=QuestionType.MULTIPLE_CHOICE,
            text="What is the difference between user crontab and /etc/cron.d/?",
            options=[
                "A) /etc/cron.d/ is only for root",
                "B) /etc/cron.d/ requires specifying the user for each job",
                "C) /etc/cron.d/ doesn't support comments",
                "D) There is no difference"
            ],
            correct_answer="B",
            explanation="""The format for /etc/cron.d/ includes an extra field: USER

User crontab:
  * * * * * /script.sh

/etc/cron.d/ and /etc/crontab:
  * * * * * root /script.sh
            ^^^^
           user!

Locations:
  /var/spool/cron/crontabs/  - user crontabs
  /etc/crontab               - system (with user field)
  /etc/cron.d/               - system (with user field)
  /etc/cron.{hourly,daily,weekly,monthly}/  - scripts (no user)""",
            tags=["cron", "cron.d", "system crontab"],
            points=2
        ))
        
        # C10: cron lock file (Hard)
        self.questions.append(Question(
            id="C10",
            category=Category.CRON,
            difficulty=Difficulty.HARD,
            question_type=QuestionType.MULTIPLE_CHOICE,
            text="""A cron job runs every 5 minutes but sometimes takes 10+ minutes.
What happens?""",
            options=[
                "A) Cron waits for the previous execution to finish",
                "B) Multiple instances run in parallel (problem!)",
                "C) The next execution is automatically skipped",
                "D) Cron displays a warning and continues"
            ],
            correct_answer="B",
            explanation="""⚠️ Cron does NOT check if the previous execution finished!

If job takes 10 min and runs every 5 min:
  00:00 - instance 1 starts
  00:05 - instance 2 starts (1 still running!)
  00:10 - instance 3 starts (1 finishes, 2 running!)
  ...

🛡️ SOLUTION: Use a lock file:
  LOCKFILE=/tmp/myjob.lock
  if [ -f "$LOCKFILE" ]; then
      echo "Job already running"
      exit 1
  fi
  trap "rm -f $LOCKFILE" EXIT
  touch "$LOCKFILE"
  # ... actual job ...

Or use flock:
  * * * * * flock -n /tmp/job.lock /script.sh""",
            tags=["cron", "lock", "parallel", "flock"],
            points=3
        ))
    
    def get_random_selection(self, count: int, 
                             category: Category = Category.MIXED,
                             difficulty: Optional[Difficulty] = None) -> List[Question]:
        """Get a random selection of questions."""
        pool = self.questions.copy()
        
        # Filter by category
        if category != Category.MIXED:
            pool = [q for q in pool if q.category == category]
        
        # Filter by difficulty
        if difficulty:
            pool = [q for q in pool if q.difficulty == difficulty]
        
        # Random selection
        if len(pool) <= count:
            random.shuffle(pool)
            return pool
        
        return random.sample(pool, count)
    
    def get_balanced_selection(self, count: int) -> List[Question]:
        """Get a balanced selection across all categories."""
        categories = [c for c in Category if c != Category.MIXED]
        per_category = count // len(categories)
        remainder = count % len(categories)
        
        selected = []
        for i, cat in enumerate(categories):
            cat_questions = [q for q in self.questions if q.category == cat]
            n = per_category + (1 if i < remainder else 0)
            selected.extend(random.sample(cat_questions, min(n, len(cat_questions))))
        
        random.shuffle(selected)
        return selected
    
    def get_statistics(self) -> Dict[str, Any]:
        """Get statistics about the question bank."""
        stats = {
            'total': len(self.questions),
            'by_category': {},
            'by_difficulty': {}
        }
        
        for q in self.questions:
            cat = q.category.value
            stats['by_category'][cat] = stats['by_category'].get(cat, 0) + 1
            
            diff = q.difficulty.value
            stats['by_difficulty'][diff] = stats['by_difficulty'].get(diff, 0) + 1
        
        return stats

# 
# QUIZ CLASS
# 

class Quiz:
    """Interactive quiz."""
    
    def __init__(self, questions: List[Question], title: str = "Quiz SEM03",
                 time_limit: Optional[int] = None, use_color: bool = True):
        self.questions = questions
        self.title = title
        self.time_limit = time_limit
        self.use_color = use_color
    
    def run_interactive(self) -> QuizResult:
        """Run the quiz in interactive mode in terminal."""
        os.system('clear' if os.name == 'posix' else 'cls')
        
        print(color_text(f"\n{'═' * 60}", Colours.CYAN, self.use_color))
        print(color_text(f"  🎯 {self.title}", Colours.BOLD + Colours.CYAN, self.use_color))
        print(color_text(f"  📝 {len(self.questions)} questions", Colours.CYAN, self.use_color))
        print(color_text(f"{'═' * 60}\n", Colours.CYAN, self.use_color))
        
        input(color_text("  Press ENTER to start...", Colours.YELLOW, self.use_color))
        
        start_time = time.time()
        results = []
        categories_breakdown = {}
        
        for i, q in enumerate(self.questions, 1):
            os.system('clear' if os.name == 'posix' else 'cls')
            
            # Header
            diff_color = {
                Difficulty.EASY: Colours.GREEN,
                Difficulty.MEDIUM: Colours.YELLOW,
                Difficulty.HARD: Colours.RED
            }[q.difficulty]
            
            print(f"\n  Question {i}/{len(self.questions)}")
            print(f"  {color_text(q.difficulty.value.upper(), diff_color, self.use_color)} | "
                  f"{q.category.value.replace('_', ' ').upper()} | "
                  f"{q.points} point{'s' if q.points > 1 else ''}")
            print("─" * 60)
            
            # Question
            print(f"\n  {q.text}\n")
            
            # Code snippet
            if q.code_snippet:
                print(color_text("  ┌" + "─" * 56 + "┐", Colours.GRAY, self.use_color))
                for line in q.code_snippet.split('\n'):
                    print(color_text(f"  │ {line:<54} │", Colours.GRAY, self.use_color))
                print(color_text("  └" + "─" * 56 + "┘", Colours.GRAY, self.use_color))
                print()
            
            # Options
            for opt in q.options:
                print(f"    {opt}")
            
            print()
            
            # Input
            while True:
                answer = input(color_text("  Your answer (A/B/C/D or S to skip): ", 
                                         Colours.CYAN, self.use_color)).strip().upper()
                if answer in ['A', 'B', 'C', 'D', 'S']:
                    break
                print(color_text("  ⚠️ Invalid option!", Colours.RED, self.use_color))
            
            # Check answer
            is_correct = answer == q.correct_answer
            skipped = answer == 'S'
            
            # Category tracking
            cat = q.category.value
            if cat not in categories_breakdown:
                categories_breakdown[cat] = {'correct': 0, 'wrong': 0, 'skipped': 0}
            
            if skipped:
                categories_breakdown[cat]['skipped'] += 1
                print(color_text("\n  ⏭️  Skipped", Colours.YELLOW, self.use_color))
            elif is_correct:
                categories_breakdown[cat]['correct'] += 1
                print(color_text("\n  ✅ Correct!", Colours.GREEN, self.use_color))
            else:
                categories_breakdown[cat]['wrong'] += 1
                print(color_text(f"\n  ❌ Wrong! Correct answer: {q.correct_answer}", 
                               Colours.RED, self.use_color))
            
            # Explanation
            print(color_text(f"\n  💡 Explanation:", Colours.CYAN, self.use_color))
            for line in textwrap.wrap(q.explanation, 55):
                print(f"     {line}")
            
            results.append({
                'question_id': q.id,
                'user_answer': answer,
                'correct_answer': q.correct_answer,
                'is_correct': is_correct,
                'skipped': skipped,
                'points': q.points if is_correct else 0
            })
            
            if i < len(self.questions):
                input(color_text("\n  Press ENTER to continue...", Colours.GRAY, self.use_color))
        
        end_time = time.time()
        
        # Calculate result
        correct = sum(1 for r in results if r['is_correct'])
        wrong = sum(1 for r in results if not r['is_correct'] and not r['skipped'])
        skipped = sum(1 for r in results if r['skipped'])
        total_points = sum(q.points for q in self.questions)
        earned_points = sum(r['points'] for r in results)
        
        return QuizResult(
            total_questions=len(self.questions),
            correct_answers=correct,
            wrong_answers=wrong,
            skipped=skipped,
            score_percentage=(earned_points / total_points * 100) if total_points > 0 else 0,
            time_taken_seconds=end_time - start_time,
            questions_results=results,
            categories_breakdown=categories_breakdown
        )
    
    def export_to_html(self, filepath: str):
        """Export quiz as interactive HTML."""
        questions_json = json.dumps([q.to_dict() for q in self.questions], 
                                   ensure_ascii=False)
        
        html_content = f'''<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{html.escape(self.title)}</title>
    <style>
        * {{ box-sizing: border-box; margin: 0; padding: 0; }}
        body {{ 
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #1a1a2e 0%, #16213e 100%);
            min-height: 100vh;
            color: #eee;
            padding: 20px;
        }}
        .container {{ max-width: 800px; margin: 0 auto; }}
        h1 {{ text-align: center; margin-bottom: 30px; color: #00d4ff; }}
        .progress {{ 
            background: #2a2a4a; 
            height: 10px; 
            border-radius: 5px; 
            margin-bottom: 20px;
            overflow: hidden;
        }}
        .progress-bar {{ 
            background: linear-gradient(90deg, #00d4ff, #7b2fff);
            height: 100%; 
            transition: width 0.3s;
        }}
        .question-card {{
            background: #2a2a4a;
            border-radius: 15px;
            padding: 25px;
            margin-bottom: 20px;
            display: none;
        }}
        .question-card.active {{ display: block; }}
        .question-meta {{ 
            display: flex; 
            gap: 10px; 
            margin-bottom: 15px;
            flex-wrap: wrap;
        }}
        .badge {{
            padding: 5px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: bold;
        }}
        .badge-easy {{ background: #28a745; }}
        .badge-medium {{ background: #ffc107; color: #000; }}
        .badge-hard {{ background: #dc3545; }}
        .question-text {{ font-size: 18px; margin-bottom: 20px; line-height: 1.6; }}
        .code-block {{
            background: #1a1a2e;
            padding: 15px;
            border-radius: 8px;
            font-family: 'Courier New', monospace;
            margin: 15px 0;
            overflow-x: auto;
            white-space: pre-wrap;
            font-size: 14px;
        }}
        .options {{ display: flex; flex-direction: column; gap: 10px; }}
        .option {{
            background: #3a3a5a;
            padding: 15px;
            border-radius: 8px;
            cursor: pointer;
            transition: all 0.2s;
            border: 2px solid transparent;
        }}
        .option:hover {{ background: #4a4a6a; }}
        .option.selected {{ border-color: #00d4ff; background: #3a4a6a; }}
        .option.correct {{ border-color: #28a745; background: rgba(40, 167, 69, 0.2); }}
        .option.wrong {{ border-color: #dc3545; background: rgba(220, 53, 69, 0.2); }}
        .feedback {{
            margin-top: 20px;
            padding: 15px;
            border-radius: 8px;
            display: none;
        }}
        .feedback.show {{ display: block; }}
        .feedback.correct {{ background: rgba(40, 167, 69, 0.2); border-left: 4px solid #28a745; }}
        .feedback.wrong {{ background: rgba(220, 53, 69, 0.2); border-left: 4px solid #dc3545; }}
        .nav-buttons {{ display: flex; justify-content: space-between; margin-top: 20px; }}
        .btn {{
            padding: 12px 25px;
            border: none;
            border-radius: 8px;
            cursor: pointer;
            font-size: 16px;
            transition: all 0.2s;
        }}
        .btn:disabled {{ opacity: 0.5; cursor: not-allowed; }}
        .btn-primary {{ background: linear-gradient(90deg, #00d4ff, #7b2fff); color: white; }}
        .btn-primary:hover:not(:disabled) {{ transform: scale(1.05); }}
        .btn-secondary {{ background: #4a4a6a; color: white; }}
        .results {{ 
            text-align: center; 
            display: none;
        }}
        .results.show {{ display: block; }}
        .score {{ font-size: 72px; color: #00d4ff; margin: 20px 0; }}
        .stats {{ display: flex; justify-content: center; gap: 30px; margin: 20px 0; }}
        .stat {{ text-align: center; }}
        .stat-value {{ font-size: 36px; font-weight: bold; }}
        .stat-label {{ color: #888; }}
    </style>
</head>
<body>
    <div class="container">
        <h1>🎯 {html.escape(self.title)}</h1>
        
        <div class="progress">
            <div class="progress-bar" id="progressBar" style="width: 0%"></div>
        </div>
        
        <div id="quizContainer"></div>
        
        <div class="results" id="results">
            <h2>🏆 Results</h2>
            <div class="score" id="scoreValue">0%</div>
            <p id="gradeText">Estimated grade: -</p>
            <div class="stats">
                <div class="stat">
                    <div class="stat-value" id="correctCount">0</div>
                    <div class="stat-label">✅ Correct</div>
                </div>
                <div class="stat">
                    <div class="stat-value" id="wrongCount">0</div>
                    <div class="stat-label">❌ Wrong</div>
                </div>
                <div class="stat">
                    <div class="stat-value" id="timeSpent">0:00</div>
                    <div class="stat-label">⏱️ Time</div>
                </div>
            </div>
            <button class="btn btn-primary" onclick="restartQuiz()">🔄 Try again</button>
        </div>
    </div>
    
    <script>
        const questions = {questions_json};
        let currentQuestion = 0;
        let answers = {{}};
        let startTime = Date.now();
        
        function initQuiz() {{
            const container = document.getElementById('quizContainer');
            questions.forEach((q, index) => {{
                const card = document.createElement('div');
                card.className = 'question-card' + (index === 0 ? ' active' : '');
                card.id = 'q' + index;
                
                const diffClass = 'badge-' + q.difficulty;
                const catEmoji = {{
                    'find_xargs': '🔍',
                    'parameters': '📝', 
                    'permissions': '🔒',
                    'cron': '⏰'
                }}[q.category] || '📋';
                
                let codeHtml = '';
                if (q.code_snippet) {{
                    codeHtml = '<div class="code-block">' + escapeHtml(q.code_snippet) + '</div>';
                }}
                
                let optionsHtml = q.options.map((opt, i) => 
                    `<div class="option" data-answer="${{String.fromCharCode(65+i)}}" onclick="selectOption(this, ${{index}})">${{escapeHtml(opt)}}</div>`
                ).join('');
                
                card.innerHTML = `
                    <div class="question-meta">
                        <span class="badge ${{diffClass}}">${{q.difficulty.toUpperCase()}}</span>
                        <span>${{catEmoji}} ${{q.category.replace('_', ' ').toUpperCase()}}</span>
                        <span>📊 ${{q.points}} point${{q.points > 1 ? 's' : ''}}</span>
                    </div>
                    <div class="question-text">${{escapeHtml(q.text)}}</div>
                    ${{codeHtml}}
                    <div class="options">${{optionsHtml}}</div>
                    <div class="feedback" id="feedback${{index}}">
                        <strong id="feedbackTitle${{index}}"></strong>
                        <p id="feedbackText${{index}}"></p>
                    </div>
                    <div class="nav-buttons">
                        <button class="btn btn-secondary" onclick="prevQuestion()" ${{index === 0 ? 'disabled' : ''}}>← Back</button>
                        <button class="btn btn-primary" id="nextBtn${{index}}" onclick="nextQuestion()" disabled>
                            ${{index === questions.length - 1 ? 'Finish' : 'Next →'}}
                        </button>
                    </div>
                `;
                container.appendChild(card);
            }});
            updateProgress();
        }}
        
        function escapeHtml(text) {{
            const div = document.createElement('div');
            div.textContent = text;
            return div.innerHTML;
        }}
        
        function selectOption(element, qIndex) {{
            const card = document.getElementById('q' + qIndex);
            const options = card.querySelectorAll('.option');
            const answered = answers[qIndex] !== undefined;
            
            if (answered) return;
            
            options.forEach(o => o.classList.remove('selected'));
            element.classList.add('selected');
            
            const answer = element.dataset.answer;
            answers[qIndex] = answer;
            
            const q = questions[qIndex];
            const isCorrect = answer === q.correct_answer;
            
            options.forEach(o => {{
                if (o.dataset.answer === q.correct_answer) o.classList.add('correct');
                else if (o.dataset.answer === answer) o.classList.add('wrong');
            }});
            
            const feedback = document.getElementById('feedback' + qIndex);
            const title = document.getElementById('feedbackTitle' + qIndex);
            const text = document.getElementById('feedbackText' + qIndex);
            
            feedback.className = 'feedback show ' + (isCorrect ? 'correct' : 'wrong');
            title.textContent = isCorrect ? '✅ Correct!' : '❌ Wrong answer: ' + q.correct_answer;
            text.textContent = q.explanation;
            
            document.getElementById('nextBtn' + qIndex).disabled = false;
        }}
        
        function nextQuestion() {{
            if (currentQuestion < questions.length - 1) {{
                document.getElementById('q' + currentQuestion).classList.remove('active');
                currentQuestion++;
                document.getElementById('q' + currentQuestion).classList.add('active');
                updateProgress();
            }} else {{
                showResults();
            }}
        }}
        
        function prevQuestion() {{
            if (currentQuestion > 0) {{
                document.getElementById('q' + currentQuestion).classList.remove('active');
                currentQuestion--;
                document.getElementById('q' + currentQuestion).classList.add('active');
                updateProgress();
            }}
        }}
        
        function updateProgress() {{
            const progress = ((currentQuestion + 1) / questions.length) * 100;
            document.getElementById('progressBar').style.width = progress + '%';
        }}
        
        function showResults() {{
            document.getElementById('quizContainer').style.display = 'none';
            
            let correct = 0;
            let totalPoints = 0;
            let earnedPoints = 0;
            
            questions.forEach((q, i) => {{
                totalPoints += q.points;
                if (answers[i] === q.correct_answer) {{
                    correct++;
                    earnedPoints += q.points;
                }}
            }});
            
            const score = Math.round((earnedPoints / totalPoints) * 100);
            const wrong = questions.length - correct;
            const timeSpent = Math.floor((Date.now() - startTime) / 1000);
            const minutes = Math.floor(timeSpent / 60);
            const seconds = timeSpent % 60;
            
            let grade = '4';
            if (score >= 90) grade = '10';
            else if (score >= 80) grade = '9';
            else if (score >= 70) grade = '8';
            else if (score >= 60) grade = '7';
            else if (score >= 50) grade = '6';
            else if (score >= 40) grade = '5';
            
            document.getElementById('scoreValue').textContent = score + '%';
            document.getElementById('gradeText').textContent = 'Estimated grade: ' + grade;
            document.getElementById('correctCount').textContent = correct;
            document.getElementById('wrongCount').textContent = wrong;
            document.getElementById('timeSpent').textContent = minutes + ':' + String(seconds).padStart(2, '0');
            
            document.getElementById('results').classList.add('show');
        }}
        
        function restartQuiz() {{
            answers = {{}};
            currentQuestion = 0;
            startTime = Date.now();
            document.getElementById('results').classList.remove('show');
            document.getElementById('quizContainer').style.display = 'block';
            document.getElementById('quizContainer').innerHTML = '';
            initQuiz();
        }}
        
        initQuiz();
    </script>
</body>
</html>'''
        
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(html_content)
    
    def export_to_json(self, filepath: str):
        """Export quiz as JSON."""
        data = {
            'title': self.title,
            'generated_at': datetime.now().isoformat(),
            'total_questions': len(self.questions),
            'time_limit_minutes': self.time_limit // 60 if self.time_limit else None,
            'questions': [q.to_dict() for q in self.questions]
        }
        
        with open(filepath, 'w', encoding='utf-8') as f:
            json.dump(data, f, ensure_ascii=False, indent=2)
    
    def export_to_markdown(self, filepath: str, with_answers: bool = False):
        """Export quiz as Markdown."""
        lines = [
            f"# 🎯 {self.title}\n",
            f"**Total questions**: {len(self.questions)}",
            f"**Generated**: {datetime.now().strftime('%Y-%m-%d %H:%M')}\n",
            "---\n"
        ]
        
        for i, q in enumerate(self.questions, 1):
            diff_emoji = {'easy': '🟢', 'medium': '🟡', 'hard': '🔴'}[q.difficulty.value]
            cat_emoji = {
                'find_xargs': '🔍',
                'parameters': '📝',
                'permissions': '🔒',
                'cron': '⏰'
            }.get(q.category.value, '📋')
            
            lines.append(f"## Question {i}\n")
            lines.append(f"**{diff_emoji} {q.difficulty.value.title()}** | "
                        f"**{cat_emoji} {q.category.value.replace('_', ' ').title()}** | "
                        f"**{q.points} point{'s' if q.points > 1 else ''}**\n")
            lines.append(f"{q.text}\n")
            
            if q.code_snippet:
                lines.append("```bash")
                lines.append(q.code_snippet)
                lines.append("```\n")
            
            for opt in q.options:
                lines.append(f"- [ ] {opt}")
            lines.append("")
            
            if with_answers:
                lines.append(f"<details>")
                lines.append(f"<summary>🔑 Answer</summary>\n")
                lines.append(f"**Correct answer: {q.correct_answer}**\n")
                lines.append(f"{q.explanation}")
                lines.append(f"</details>\n")
            
            lines.append("---\n")
        
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write('\n'.join(lines))

# 
# COMMAND LINE INTERFACE
# 

def print_banner(use_color: bool = True):
    """Display the program banner."""
    banner = r"""
    ╔══════════════════════════════════════════════════════════════════╗
    ║       ___        _       _____                          _        ║
    ║      / _ \ _   _(_)____ / ____|  ___ _ __   ___ _ __ __ _| |_ ___  ║
    ║     | | | | | | | |_  / |  ___ / _ \ '_ \ / _ \ '__/ _` | __/ _ \ ║
    ║     | |_| | |_| | |/ /  | |_| |  __/ | | |  __/ | | (_| | || (_) |║
    ║      \__\_\\__,_|_/___|  \_____|\___|_| |_|\___|_|  \__,_|\__\___/ ║
    ║                                                                  ║
    ║              Seminar 3: Find, Permissions, Cron                  ║
    ╚══════════════════════════════════════════════════════════════════╝
    """
    print(color_text(banner, Colours.CYAN, use_color))

def print_statistics(bank: QuestionBank, use_color: bool = True):
    """Display statistics about the question bank."""
    stats = bank.get_statistics()
    
    print(color_text("\n📊 Question Bank Statistics", Colours.BOLD + Colours.CYAN, use_color))
    print("═" * 50)
    print(f"  Total questions: {color_text(str(stats['total']), Colours.GREEN, use_color)}")
    
    print(color_text("\n  By category:", Colours.YELLOW, use_color))
    cat_emojis = {
        'find_xargs': '🔍',
        'parameters': '📝',
        'permissions': '🔒',
        'cron': '⏰'
    }
    for cat, count in stats['by_category'].items():
        emoji = cat_emojis.get(cat, '📋')
        print(f"    {emoji} {cat:15} : {count:3}")
    
    print(color_text("\n  By difficulty:", Colours.YELLOW, use_color))
    diff_colors = {'easy': Colours.GREEN, 'medium': Colours.YELLOW, 'hard': Colours.RED}
    for diff, count in stats['by_difficulty'].items():
        print(f"    {color_text(diff.ljust(8), diff_colors.get(diff, ''), use_color)} : {count:3}")

def print_result(result: QuizResult, use_color: bool = True):
    """Display the quiz result."""
    os.system('clear' if os.name == 'posix' else 'cls')
    
    print("\n" + "═" * 70)
    print(color_text("  🏆 FINAL RESULTS", Colours.BOLD + Colours.CYAN, use_color))
    print("═" * 70)
    
    # Large score
    score_color = Colours.GREEN if result.score_percentage >= 60 else Colours.RED
    print(color_text(f"\n  Score: {result.score_percentage:.1f}%", 
                    Colours.BOLD + score_color, use_color))
    print(color_text(f"  Estimated grade: {result.grade}", Colours.BOLD, use_color))
    
    # Statistics
    minutes = int(result.time_taken_seconds // 60)
    seconds = int(result.time_taken_seconds % 60)
    
    print(f"\n  ✅ Correct:  {result.correct_answers}")
    print(f"  ❌ Wrong:    {result.wrong_answers}")
    print(f"  ⏭️  Skipped:  {result.skipped}")
    print(f"  ⏱️  Time:     {minutes}:{seconds:02d}")
    
    # Breakdown by category
    print(color_text("\n  📊 By category:", Colours.YELLOW, use_color))
    for cat, data in result.categories_breakdown.items():
        total = data['correct'] + data['wrong'] + data['skipped']
        if total > 0:
            pct = data['correct'] / total * 100
            bar_len = int(pct / 5)
            bar = "█" * bar_len + "░" * (20 - bar_len)
            print(f"    {cat:15} [{bar}] {pct:5.1f}%")
    
    print("\n" + "═" * 70)

def main():
    """Main function."""
    parser = argparse.ArgumentParser(
        description='Quiz Generator for Seminar 03 OS',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog='''
Examples:
  %(prog)s --interactive                    # Interactive quiz with 10 questions
  %(prog)s --generate 15 --difficulty hard  # Hard quiz with 15 questions
  %(prog)s --category permissions --count 5 # Quiz with permissions only
  %(prog)s --export quiz.html               # Export as interactive HTML
  %(prog)s --stats                          # Display statistics
        '''
    )
    
    parser.add_argument('--interactive', '-i', action='store_true',
                       help='Start interactive quiz in terminal')
    parser.add_argument('--generate', '-g', type=int, metavar='N',
                       help='Generate quiz with N questions')
    parser.add_argument('--count', '-c', type=int, default=10,
                       help='Number of questions (default: 10)')
    parser.add_argument('--category', '-cat', 
                       choices=['find_xargs', 'parameters', 'permissions', 'cron', 'mixed'],
                       default='mixed',
                       help='Question category')
    parser.add_argument('--difficulty', '-d',
                       choices=['easy', 'medium', 'hard'],
                       help='Filter by difficulty')
    parser.add_argument('--balanced', '-b', action='store_true',
                       help='Select balanced from all categories')
    parser.add_argument('--export', '-e', metavar='FILE',
                       help='Export quiz (format detected from extension: .html, .json, .md)')
    parser.add_argument('--with-answers', '-a', action='store_true',
                       help='Include answers in Markdown export')
    parser.add_argument('--stats', '-s', action='store_true',
                       help='Display question bank statistics')
    parser.add_argument('--list-questions', '-l', action='store_true',
                       help='List all questions')
    parser.add_argument('--no-color', action='store_true',
                       help='Disable terminal colours')
    parser.add_argument('--version', '-v', action='version',
                       version=f'{PROGRAM_NAME} v{VERSION}')
    
    args = parser.parse_args()
    use_color = not args.no_color
    
    # Initialise question bank
    bank = QuestionBank()
    
    # Display statistics
    if args.stats:
        print_banner(use_color)
        print_statistics(bank, use_color)
        return 0
    
    # List questions
    if args.list_questions:
        print_banner(use_color)
        for q in bank.questions:
            diff_color = {
                Difficulty.EASY: Colours.GREEN,
                Difficulty.MEDIUM: Colours.YELLOW,
                Difficulty.HARD: Colours.RED
            }[q.difficulty]
            print(f"[{q.id}] {color_text(q.difficulty.value[:1].upper(), diff_color, use_color)} "
                  f"{q.category.value:12} | {q.text[:60]}...")
        print(f"\nTotal: {len(bank.questions)} questions")
        return 0
    
    # Select questions
    count = args.generate if args.generate else args.count
    category = Category(args.category)
    difficulty = Difficulty(args.difficulty) if args.difficulty else None
    
    if args.balanced:
        questions = bank.get_balanced_selection(count)
    else:
        questions = bank.get_random_selection(count, category, difficulty)
    
    if not questions:
        print(color_text("❌ No questions found with the specified filters!", 
                        Colours.RED, use_color))
        return 1
    
    # Create quiz
    title = f"Quiz SEM03: {category.value.replace('_', ' ').title()}"
    quiz = Quiz(questions, title, use_color=use_color)
    
    # Export
    if args.export:
        ext = os.path.splitext(args.export)[1].lower()
        if ext == '.html':
            quiz.export_to_html(args.export)
            print(f"✅ Quiz exported to {args.export}")
        elif ext == '.json':
            quiz.export_to_json(args.export)
            print(f"✅ Quiz exported to {args.export}")
        elif ext == '.md':
            quiz.export_to_markdown(args.export, args.with_answers)
            print(f"✅ Quiz exported to {args.export}")
        else:
            print(f"❌ Unknown format: {ext}")
            return 1
        return 0
    
    # Interactive quiz
    if args.interactive or args.generate:
        print_banner(use_color)
        result = quiz.run_interactive()
        print_result(result, use_color)
        
        # Offer to save results
        save = input("\n  Save results? (y/n): ").strip().lower()
        if save == 'y':
            filename = f"quiz_result_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
            with open(filename, 'w', encoding='utf-8') as f:
                json.dump({
                    'score_percentage': result.score_percentage,
                    'grade': result.grade,
                    'correct': result.correct_answers,
                    'wrong': result.wrong_answers,
                    'skipped': result.skipped,
                    'time_seconds': result.time_taken_seconds,
                    'categories': result.categories_breakdown,
                    'questions': result.questions_results
                }, f, ensure_ascii=False, indent=2)
            print(f"  ✅ Results saved to {filename}")
        
        return 0
    
    # Default: show help
    parser.print_help()
    return 0

if __name__ == '__main__':
    sys.exit(main())
