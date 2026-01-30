#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
═══════════════════════════════════════════════════════════════════════════════
📝 S02_02_quiz_generator.py - Personalised Quiz Generator
═══════════════════════════════════════════════════════════════════════════════

DESCRIPTION:
    Generator for unique quizzes for each student.
    Randomises questions and answer options to prevent cheating.
    Exports to multiple formats: TXT, HTML, JSON, PDF-ready Markdown.

USAGE:
    python3 S02_02_quiz_generator.py --students list.txt --output ./quiz_output/
    python3 S02_02_quiz_generator.py --student "Smith John" --grupa 1051
    python3 S02_02_quiz_generator.py --count 30 --format html --seed 42

AUTHOR: Assistant for Bucharest UES - CSIE
VERSION: 1.0
DATE: January 2025
═══════════════════════════════════════════════════════════════════════════════
"""

import argparse
import json
import random
import hashlib
import os
import sys
from dataclasses import dataclass, field, asdict
from typing import List, Dict, Optional, Tuple
from datetime import datetime
from pathlib import Path
import html
import re

# 
# SECTION 1: DATA STRUCTURES
# 

@dataclass
class Question:
    """Structure for a quiz question."""
    id: str
    category: str  # operators, redirection, filters, loops
    difficulty: str  # easy, medium, hard
    question_text: str
    code_block: Optional[str]
    options: List[str]
    correct_index: int
    explanation: str
    misconception_targeted: Optional[str] = None
    
    def get_shuffled_options(self, seed: int) -> Tuple[List[str], int]:
        """Return shuffled options and the new correct index."""
        rng = random.Random(seed)
        indexed_options = list(enumerate(self.options))
        rng.shuffle(indexed_options)
        new_correct = next(i for i, (orig_i, _) in enumerate(indexed_options) 
                         if orig_i == self.correct_index)
        return [opt for _, opt in indexed_options], new_correct

@dataclass
class Quiz:
    """Structure for a complete quiz."""
    student_name: str
    student_group: str
    quiz_id: str
    generated_at: str
    questions: List[Dict]
    seed: int
    total_points: int = 100
    time_limit_minutes: int = 30

@dataclass
class QuestionBank:
    """Question bank organised by categories and difficulties."""
    questions: List[Question] = field(default_factory=list)
    
    def add(self, q: Question):
        self.questions.append(q)
    
    def filter_by(self, category: Optional[str] = None, 
                  difficulty: Optional[str] = None) -> List[Question]:
        result = self.questions
        if category:
            result = [q for q in result if q.category == category]
        if difficulty:
            result = [q for q in result if q.difficulty == difficulty]
        return result
    
    def get_balanced_selection(self, count: int, seed: int) -> List[Question]:
        """Select questions balanced across categories and difficulties."""
        rng = random.Random(seed)
        
        # Target distribution
        categories = ['operators', 'redirection', 'filters', 'loops']
        difficulties = {'easy': 0.3, 'medium': 0.5, 'hard': 0.2}
        
        selected = []
        per_category = count // len(categories)
        remainder = count % len(categories)
        
        for cat in categories:
            cat_questions = self.filter_by(category=cat)
            if not cat_questions:
                continue
                
            # Select proportionally by difficulty
            cat_count = per_category + (1 if remainder > 0 else 0)
            remainder -= 1
            
            easy = [q for q in cat_questions if q.difficulty == 'easy']
            medium = [q for q in cat_questions if q.difficulty == 'medium']
            hard = [q for q in cat_questions if q.difficulty == 'hard']
            
            target_easy = int(cat_count * difficulties['easy'])
            target_medium = int(cat_count * difficulties['medium'])
            target_hard = cat_count - target_easy - target_medium
            
            rng.shuffle(easy)
            rng.shuffle(medium)
            rng.shuffle(hard)
            
            selected.extend(easy[:target_easy])
            selected.extend(medium[:target_medium])
            selected.extend(hard[:target_hard])
        
        # Fill if we don't have enough
        if len(selected) < count:
            remaining = [q for q in self.questions if q not in selected]
            rng.shuffle(remaining)
            selected.extend(remaining[:count - len(selected)])
        
        rng.shuffle(selected)
        return selected[:count]

# 
# SECTION 2: QUESTION BANK
# 

def create_question_bank() -> QuestionBank:
    """Create the question bank for Seminar 3-4."""
    bank = QuestionBank()
    
    # 
    # CATEGORY: CONTROL OPERATORS
    # 
    
    bank.add(Question(
        id="OP001",
        category="operators",
        difficulty="easy",
        question_text="What happens when we execute: `mkdir test && echo 'OK'` if the directory 'test' ALREADY EXISTS?",
        code_block="mkdir test && echo 'OK'",
        options=[
            "'OK' is displayed",
            "An error from mkdir is displayed, but 'OK' is NOT displayed",
            "An error from mkdir is displayed AND 'OK' is displayed",
            "The command fails silently with no output"
        ],
        correct_index=1,
        explanation="The && operator executes the right command ONLY if the left command succeeds (exit code 0). mkdir fails when the directory exists, so echo is not executed.",
        misconception_targeted="M1.1: && and ; are equivalent"
    ))
    
    bank.add(Question(
        id="OP002",
        category="operators",
        difficulty="easy",
        question_text="What is the main difference between `;` and `&&`?",
        code_block=None,
        options=[
            "; executes sequentially regardless of success, && executes the second command only if the first succeeds",
            "; executes in parallel, && executes sequentially",
            "There is no difference, they are equivalent",
            "; is for scripts, && is for the command line"
        ],
        correct_index=0,
        explanation="`;` executes commands sequentially ignoring the exit code. `&&` (logical AND) executes the second command ONLY if the first returns exit code 0.",
        misconception_targeted="M1.1: && and ; are equivalent"
    ))
    
    bank.add(Question(
        id="OP003",
        category="operators",
        difficulty="medium",
        question_text="What does the following code display?",
        code_block="false && echo 'A' || echo 'B' && echo 'C'",
        options=[
            "B and C (on separate lines)",
            "Only B",
            "A and C (on separate lines)",
            "Only C"
        ],
        correct_index=0,
        explanation="false returns 1 (failure), so && echo 'A' is not executed. || echo 'B' executes (because the left side failed). echo 'B' succeeds, so && echo 'C' executes.",
        misconception_targeted="M1.2: Confusion in && and || chains"
    ))
    
    bank.add(Question(
        id="OP004",
        category="operators",
        difficulty="medium",
        question_text="What does the `&` operator do at the end of a command?",
        code_block="sleep 10 &",
        options=[
            "Runs the command in background and immediately returns the prompt",
            "Makes the command run faster",
            "Executes the command if the previous one failed",
            "Saves the command output to a file"
        ],
        correct_index=0,
        explanation="The & operator starts the command as a background job, freeing the terminal. The process receives a job ID and PID.",
        misconception_targeted="M1.4: & makes the command faster"
    ))
    
    bank.add(Question(
        id="OP005",
        category="operators",
        difficulty="hard",
        question_text="What does `$?` return after executing the following code?",
        code_block="(exit 42); echo $?",
        options=[
            "42",
            "0",
            "1",
            "Syntax error"
        ],
        correct_index=0,
        explanation="Parentheses () create a subshell. `exit 42` terminates the subshell with code 42, which becomes the group's exit code. `;` ignores this code, but $? preserves it.",
        misconception_targeted=None
    ))
    
    bank.add(Question(
        id="OP006",
        category="operators",
        difficulty="hard",
        question_text="What is the difference between `{ cmd1; cmd2; }` and `(cmd1; cmd2)`?",
        code_block=None,
        options=[
            "{} executes in the current shell, () creates a subshell",
            "There is no difference, they are equivalent",
            "() executes in the current shell, {} creates a subshell",
            "{} is for functions, () is for grouping"
        ],
        correct_index=0,
        explanation="Braces {} group commands in the current shell (modified variables persist). Parentheses () create an isolated subshell (variables do not persist in the parent shell).",
        misconception_targeted=None
    ))
    
    bank.add(Question(
        id="OP007",
        category="operators",
        difficulty="medium",
        question_text="What does the `jobs` command do in Bash?",
        code_block=None,
        options=[
            "Lists all background processes of the current shell",
            "Displays all system processes",
            "Creates a new background job",
            "Stops all background processes"
        ],
        correct_index=0,
        explanation="`jobs` displays the list of jobs (background processes) of the current shell, with status and job ID.",
        misconception_targeted=None
    ))
    
    bank.add(Question(
        id="OP008",
        category="operators",
        difficulty="easy",
        question_text="What exit code does the `true` command return?",
        code_block="true; echo $?",
        options=[
            "0",
            "1",
            "true",
            "It does not return anything"
        ],
        correct_index=0,
        explanation="The `true` command always returns exit code 0 (success). It is useful in scripts for infinite loops or guaranteed true conditions.",
        misconception_targeted=None
    ))
    
    # 
    # CATEGORY: I/O REDIRECTION
    # 
    
    bank.add(Question(
        id="RD001",
        category="redirection",
        difficulty="easy",
        question_text="What does the `>` operator do in the command `echo 'test' > file.txt`?",
        code_block="echo 'test' > file.txt",
        options=[
            "Overwrites the content of file.txt with 'test'",
            "Appends 'test' to the end of file.txt",
            "Reads from file.txt",
            "Creates a link to file.txt"
        ],
        correct_index=0,
        explanation="The `>` operator redirects stdout to a file, OVERWRITING existing content. If the file does not exist, it creates it.",
        misconception_targeted="M2.1: > and >> are equivalent"
    ))
    
    bank.add(Question(
        id="RD002",
        category="redirection",
        difficulty="easy",
        question_text="What does the `>>` operator do differently from `>`?",
        code_block=None,
        options=[
            ">> appends to the file, > overwrites",
            ">> overwrites, > appends",
            ">> is for stderr, > is for stdout",
            "There is no difference"
        ],
        correct_index=0,
        explanation="The `>>` operator appends to the end of the file (append), preserving existing content. `>` overwrites all content.",
        misconception_targeted="M2.1"
    ))
    
    bank.add(Question(
        id="RD003",
        category="redirection",
        difficulty="medium",
        question_text="What does `2>&1` do in the command `cmd 2>&1`?",
        code_block="ls /nonexistent 2>&1",
        options=[
            "Redirects stderr (fd 2) to the same destination as stdout (fd 1)",
            "Redirects stdout to stderr",
            "Redirects stderr to stdin",
            "Combines two files"
        ],
        correct_index=0,
        explanation="`2>&1` means 'redirect file descriptor 2 (stderr) to where file descriptor 1 (stdout) points'. Useful for capturing both normal output and errors.",
        misconception_targeted="M2.2: 2>&1 sends stderr to stdin"
    ))
    
    bank.add(Question(
        id="RD004",
        category="redirection",
        difficulty="hard",
        question_text="What is the correct order to send BOTH (stdout and stderr) to a file?",
        code_block=None,
        options=[
            "cmd > file.txt 2>&1",
            "cmd 2>&1 > file.txt",
            "cmd 2> file.txt 1>&2",
            "All options are equivalent"
        ],
        correct_index=0,
        explanation="ORDER MATTERS! In `cmd > file.txt 2>&1`, first stdout goes to file.txt, then stderr goes 'where stdout points' (file.txt). In the reversed version, 2>&1 is evaluated BEFORE redirection, so stderr goes to original stdout (terminal).",
        misconception_targeted="M2.2"
    ))
    
    bank.add(Question(
        id="RD005",
        category="redirection",
        difficulty="medium",
        question_text="What does the `<` operator do in the command `wc -l < file.txt`?",
        code_block="wc -l < file.txt",
        options=[
            "Redirects the content of file.txt as stdin for wc",
            "Saves wc output to file.txt",
            "Compares wc with file.txt",
            "Creates file.txt if it does not exist"
        ],
        correct_index=0,
        explanation="The `<` operator redirects the content of a file as stdin for the command. It is different from `cat file.txt | wc -l` which creates an additional process.",
        misconception_targeted="M2.3: < is the same as cat file |"
    ))
    
    bank.add(Question(
        id="RD006",
        category="redirection",
        difficulty="medium",
        question_text="What is a 'Here Document' in Bash?",
        code_block="cat << EOF\nLine 1\nLine 2\nEOF",
        options=[
            "A way to provide multi-line input inline in a script",
            "A temporary file created automatically",
            "An alias for redirection",
            "A command for reading files"
        ],
        correct_index=0,
        explanation="Here Document (`<< DELIMITER`) allows including multi-line text directly in a script/command. The text between << and DELIMITER becomes stdin.",
        misconception_targeted="M2.4: Here document reads from file"
    ))
    
    bank.add(Question(
        id="RD007",
        category="redirection",
        difficulty="hard",
        question_text="What is the difference between `<< 'EOF'` and `<< EOF` (with and without quotes)?",
        code_block=None,
        options=[
            "With quotes, variables are NOT expanded; without quotes, they are expanded",
            "There is no difference",
            "With quotes creates a file, without quotes does not",
            "With quotes is for text, without quotes is for commands"
        ],
        correct_index=0,
        explanation="When the delimiter is quoted (`<< 'EOF'`), content is treated literally (no expansion). Without quotes, variables $VAR and commands $(cmd) are expanded.",
        misconception_targeted=None
    ))
    
    bank.add(Question(
        id="RD008",
        category="redirection",
        difficulty="easy",
        question_text="What does `/dev/null` do in Linux?",
        code_block="cmd > /dev/null 2>&1",
        options=[
            "It is a special file that ignores everything it receives (\"black hole\")",
            "It is the directory for deleted files",
            "It is a file for storing errors",
            "It is the root of the filesystem"
        ],
        correct_index=0,
        explanation="/dev/null is a special device that discards everything written to it. Reading from it returns EOF. Useful for suppressing output.",
        misconception_targeted=None
    ))
    
    # 
    # CATEGORY: FILTERS
    # 
    
    bank.add(Question(
        id="FT001",
        category="filters",
        difficulty="easy",
        question_text="What does the `sort` command do?",
        code_block="cat file.txt | sort",
        options=[
            "Sorts lines alphabetically (or numerically with -n)",
            "Deletes duplicate lines",
            "Counts the lines",
            "Reverses the order of lines"
        ],
        correct_index=0,
        explanation="`sort` sorts input lines. By default alphabetically, with `-n` numerically, with `-r` in reverse. Essential before `uniq`!",
        misconception_targeted=None
    ))
    
    bank.add(Question(
        id="FT002",
        category="filters",
        difficulty="medium",
        question_text="What does `uniq` do WITHOUT prior sorting?",
        code_block="echo -e 'a\\nb\\na\\nb' | uniq",
        options=[
            "Removes only ADJACENT duplicate lines (result: a, b, a, b)",
            "Removes ALL duplicates (result: a, b)",
            "Does nothing without -c option",
            "Generates an error"
        ],
        correct_index=0,
        explanation="TRAP! `uniq` only removes ADJACENT duplicates. For a, b, a, b - only consecutive pairs are compared. You need `sort | uniq` to remove all duplicates.",
        misconception_targeted="M3.1: uniq removes ALL duplicates"
    ))
    
    bank.add(Question(
        id="FT003",
        category="filters",
        difficulty="easy",
        question_text="How do you extract only the first column from a CSV file (comma-delimited)?",
        code_block=None,
        options=[
            "cut -d',' -f1 file.csv",
            "cut -c1 file.csv",
            "awk file.csv column1",
            "head -c1 file.csv"
        ],
        correct_index=0,
        explanation="`cut -d',' -f1` specifies the delimiter (-d) as comma and selects the first field (-f1). `-c1` would extract only the first character.",
        misconception_targeted=None
    ))
    
    bank.add(Question(
        id="FT004",
        category="filters",
        difficulty="medium",
        question_text="What does the command `tr 'a-z' 'A-Z'` do?",
        code_block="echo 'hello' | tr 'a-z' 'A-Z'",
        options=[
            "Converts lowercase letters to uppercase (HELLO)",
            "Deletes lowercase and uppercase letters",
            "Reverses the case of letters",
            "Replaces the text 'a-z' with 'A-Z'"
        ],
        correct_index=0,
        explanation="`tr` translates characters. 'a-z' represents the range from a to z, which are replaced with 'A-Z'. It operates at CHARACTER level, not string.",
        misconception_targeted="M3.3: tr replaces strings"
    ))
    
    bank.add(Question(
        id="FT005",
        category="filters",
        difficulty="hard",
        question_text="What does `tr -s ' '` (with the -s option) do?",
        code_block="echo 'a    b   c' | tr -s ' '",
        options=[
            "Compresses multiple consecutive spaces into one (squeeze)",
            "Deletes all spaces",
            "Replaces spaces with tabs",
            "Sorts by spaces"
        ],
        correct_index=0,
        explanation="The `-s` option (squeeze) compresses sequences of repeated characters into one. `tr -s ' '` transforms '  ' into ' '.",
        misconception_targeted=None
    ))
    
    bank.add(Question(
        id="FT006",
        category="filters",
        difficulty="easy",
        question_text="What does `wc -l file.txt` count?",
        code_block="wc -l file.txt",
        options=[
            "The number of lines in the file",
            "The number of letters in the file",
            "The number of words in the file",
            "The length of the longest line"
        ],
        correct_index=0,
        explanation="`wc -l` counts lines (newlines). `-w` for words, `-c` for bytes, `-m` for characters, `-L` for the longest line.",
        misconception_targeted=None
    ))
    
    bank.add(Question(
        id="FT007",
        category="filters",
        difficulty="medium",
        question_text="How do you display the last 5 lines of a file?",
        code_block=None,
        options=[
            "tail -5 file.txt or tail -n 5 file.txt",
            "head -5 file.txt",
            "cat -5 file.txt",
            "last 5 file.txt"
        ],
        correct_index=0,
        explanation="`tail -n 5` or shortened `tail -5` displays the last 5 lines. `head` displays from the BEGINNING.",
        misconception_targeted=None
    ))
    
    bank.add(Question(
        id="FT008",
        category="filters",
        difficulty="hard",
        question_text="How do you extract lines 10-20 from a file?",
        code_block=None,
        options=[
            "head -20 file | tail -11  OR  sed -n '10,20p' file",
            "tail -10 file | head -20",
            "cat -n 10-20 file",
            "cut -l 10-20 file"
        ],
        correct_index=0,
        explanation="Method 1: `head -20` takes the first 20, then `tail -11` takes the last 11 (lines 10-20). Method 2: `sed -n '10,20p'` directly prints lines 10-20.",
        misconception_targeted=None
    ))
    
    bank.add(Question(
        id="FT009",
        category="filters",
        difficulty="medium",
        question_text="What does `sort -k2 -t':'` do?",
        code_block="sort -k2 -t':' /etc/passwd",
        options=[
            "Sorts by the second field, using ':' as delimiter",
            "Sorts by character 2",
            "Sorts in reverse by 2 columns",
            "Sorts and removes duplicates"
        ],
        correct_index=0,
        explanation="`-k2` specifies to sort by field 2 (key). `-t':'` specifies the field delimiter. Useful for structured files.",
        misconception_targeted=None
    ))
    
    bank.add(Question(
        id="FT010",
        category="filters",
        difficulty="hard",
        question_text="What is the universal pattern for frequency analysis?",
        code_block=None,
        options=[
            "sort | uniq -c | sort -rn | head",
            "uniq -c | sort | head",
            "head | sort | uniq",
            "cat | count | sort"
        ],
        correct_index=0,
        explanation="Universal pattern: sort (for uniq), count duplicates (uniq -c), sort numerically descending (sort -rn), take top N (head). Works for any frequency analysis.",
        misconception_targeted="M3.1"
    ))
    
    # 
    # CATEGORY: LOOPS
    # 
    
    bank.add(Question(
        id="LP001",
        category="loops",
        difficulty="easy",
        question_text="What does the following code display?",
        code_block="for i in 1 2 3; do echo $i; done",
        options=[
            "1, 2, 3 (on separate lines)",
            "1 2 3 (on a single line)",
            "{1..3}",
            "Syntax error"
        ],
        correct_index=0,
        explanation="The `for` loop iterates through the list of values (1, 2, 3). For each value, it executes the body (echo $i), so it displays each on a line.",
        misconception_targeted=None
    ))
    
    bank.add(Question(
        id="LP002",
        category="loops",
        difficulty="hard",
        question_text="What does the following code display?",
        code_block="N=5\nfor i in {1..$N}; do echo $i; done",
        options=[
            "{1..5} (literally, NOT the numbers 1-5)",
            "1, 2, 3, 4, 5 (on separate lines)",
            "Syntax error",
            "Nothing"
        ],
        correct_index=0,
        explanation="MAJOR TRAP! Brace expansion ({1..5}) happens at PARSE TIME, BEFORE variable substitution. So $N is not yet evaluated. Solutions: `seq 1 $N` or `for ((i=1; i<=N; i++))`.",
        misconception_targeted="M4.1: {1..$N} works with variables"
    ))
    
    bank.add(Question(
        id="LP003",
        category="loops",
        difficulty="medium",
        question_text="What does the syntax `for file in *.txt; do ... done` do?",
        code_block="for file in *.txt; do echo $file; done",
        options=[
            "Iterates through all .txt files in the current directory",
            "Recursively searches for all .txt files",
            "Creates .txt files",
            "Reads the content of .txt files"
        ],
        correct_index=0,
        explanation="The glob pattern `*.txt` expands to the list of matching files. The loop iterates through each. NOTE: it does not work recursively without `**/*.txt` and `shopt -s globstar`.",
        misconception_targeted=None
    ))
    
    bank.add(Question(
        id="LP004",
        category="loops",
        difficulty="medium",
        question_text="What is the correct syntax for a C-style `for` loop in Bash?",
        code_block=None,
        options=[
            "for ((i=0; i<10; i++)); do ... done",
            "for (i=0; i<10; i++) { ... }",
            "for i = 0 to 10 do ... done",
            "for i in range(10); do ... done"
        ],
        correct_index=0,
        explanation="Bash supports C-style syntax with double parentheses: `for ((init; cond; incr)); do ... done`. Variables are referenced without $ inside (()).",
        misconception_targeted=None
    ))
    
    bank.add(Question(
        id="LP005",
        category="loops",
        difficulty="hard",
        question_text="What problem does the following code have?",
        code_block="cat file.txt | while read line; do\n  count=$((count+1))\ndone\necho $count",
        options=[
            "The count variable will be empty/0 - while runs in a subshell due to the pipe",
            "The read syntax is incorrect",
            "cat cannot be used with pipe",
            "The code works correctly"
        ],
        correct_index=0,
        explanation="SUBSHELL TRAP! The pipe (`|`) creates a subshell for while. Variables modified in subshell do NOT persist. Solution: `while read ... < file.txt` or `while read ... < <(cat file.txt)`.",
        misconception_targeted="M4.3: while read in pipe preserves variables"
    ))
    
    bank.add(Question(
        id="LP006",
        category="loops",
        difficulty="easy",
        question_text="What does `break` do in a loop?",
        code_block="for i in 1 2 3 4 5; do\n  if [ $i -eq 3 ]; then break; fi\n  echo $i\ndone",
        options=[
            "Exits the loop completely (displays 1, 2)",
            "Skips to the next iteration (displays 1, 2, 4, 5)",
            "Exits the script completely",
            "Generates an error"
        ],
        correct_index=0,
        explanation="`break` exits immediately from the current loop. `continue` would skip to the next iteration. `exit` would exit the script completely.",
        misconception_targeted="M4.2: break exits the script"
    ))
    
    bank.add(Question(
        id="LP007",
        category="loops",
        difficulty="medium",
        question_text="What does `continue` do in a loop?",
        code_block="for i in 1 2 3 4 5; do\n  if [ $i -eq 3 ]; then continue; fi\n  echo $i\ndone",
        options=[
            "Skips to the next iteration (displays 1, 2, 4, 5)",
            "Exits the loop completely (displays 1, 2)",
            "Repeats the current iteration",
            "Restarts the loop from the beginning"
        ],
        correct_index=0,
        explanation="`continue` skips the rest of the loop body and moves to the next iteration. Here it skips echo for i=3, but continues with 4 and 5.",
        misconception_targeted=None
    ))
    
    bank.add(Question(
        id="LP008",
        category="loops",
        difficulty="medium",
        question_text="What is the difference between `while` and `until`?",
        code_block=None,
        options=[
            "while runs WHILE the condition is true, until runs UNTIL the condition becomes true",
            "There is no difference, they are synonyms",
            "until is for infinite loops, while for finite loops",
            "while is POSIX, until is not"
        ],
        correct_index=0,
        explanation="`while` continues when condition is TRUE (exit 0). `until` continues when condition is FALSE (exit != 0). They are logically opposite.",
        misconception_targeted=None
    ))
    
    bank.add(Question(
        id="LP009",
        category="loops",
        difficulty="hard",
        question_text="What does `break 2` do in a nested loop context?",
        code_block="for i in 1 2; do\n  for j in a b; do\n    if [ $j = b ]; then break 2; fi\n    echo \"$i$j\"\n  done\ndone",
        options=[
            "Exits BOTH loops (displays only '1a')",
            "Exits only the inner loop",
            "Syntax error - break does not accept arguments",
            "Displays '1a', '1b', '2a'"
        ],
        correct_index=0,
        explanation="`break N` exits N levels of loops. `break 2` exits both the inner AND outer loop. Similarly, `continue N` exists.",
        misconception_targeted=None
    ))
    
    bank.add(Question(
        id="LP010",
        category="loops",
        difficulty="medium",
        question_text="What is the correct way to read a file line by line in Bash?",
        code_block=None,
        options=[
            "while IFS= read -r line; do ... done < file.txt",
            "for line in $(cat file.txt); do ... done",
            "cat file.txt | for line; do ... done",
            "read file.txt into lines; for line in lines; do ... done"
        ],
        correct_index=0,
        explanation="`while read` with redirection `< file` is the correct idiom. `IFS=` prevents whitespace stripping, `-r` prevents backslash interpretation. The variant `for line in $(cat)` fails with spaces/newlines in lines.",
        misconception_targeted="M4.3"
    ))
    
    # Add more questions to achieve necessary diversity
    bank.add(Question(
        id="OP009",
        category="operators",
        difficulty="medium",
        question_text="What happens with the exit code in a pipeline `cmd1 | cmd2`?",
        code_block="false | true; echo $?",
        options=[
            "The exit code is from the LAST command (0 in this case)",
            "The exit code is from the first command (1)",
            "The exit code is a combination of both",
            "Pipelines do not have an exit code"
        ],
        correct_index=0,
        explanation="By default, $? returns the exit code of the last command in the pipeline. To get all, use the array `${PIPESTATUS[@]}`.",
        misconception_targeted="M1.3: | also transmits the exit code"
    ))
    
    bank.add(Question(
        id="FT011",
        category="filters",
        difficulty="medium",
        question_text="What does the command `paste file1.txt file2.txt` do?",
        code_block="paste file1.txt file2.txt",
        options=[
            "Combines corresponding lines from both files, separated by tab",
            "Concatenates files vertically",
            "Copies file1 to file2",
            "Compares the two files"
        ],
        correct_index=0,
        explanation="`paste` merges lines from files in parallel, separated by TAB by default. Line 1 from file1 + TAB + line 1 from file2, etc.",
        misconception_targeted=None
    ))
    
    bank.add(Question(
        id="RD011",
        category="redirection",
        difficulty="easy",
        question_text="What do the numbers 0, 1, and 2 represent in the I/O context?",
        code_block=None,
        options=[
            "stdin (0), stdout (1), stderr (2) - standard file descriptors",
            "Process priorities",
            "Error levels",
            "File types"
        ],
        correct_index=0,
        explanation="Each process has 3 standard file descriptors: 0 (stdin - input), 1 (stdout - normal output), 2 (stderr - error messages).",
        misconception_targeted=None
    ))
    
    bank.add(Question(
        id="LP011",
        category="loops",
        difficulty="easy",
        question_text="What does `seq 1 5` return?",
        code_block="seq 1 5",
        options=[
            "The numbers 1, 2, 3, 4, 5 on separate lines",
            "The sequence '1 5'",
            "Error - seq does not exist in Bash",
            "A file with numbers 1-5"
        ],
        correct_index=0,
        explanation="`seq START END` generates a sequence of numbers. Useful as an alternative to brace expansion when you need variables: `for i in $(seq 1 $N)`.",
        misconception_targeted="M4.1"
    ))
    
    return bank

# 
# SECTION 3: QUIZ GENERATOR
# 

class QuizGenerator:
    """Personalised quiz generator."""
    
    def __init__(self, question_bank: QuestionBank):
        self.bank = question_bank
    
    def _generate_seed(self, student_name: str, student_group: str) -> int:
        """Generate a unique seed based on student name and group."""
        data = f"{student_name.lower().strip()}:{student_group}"
        return int(hashlib.md5(data.encode()).hexdigest()[:8], 16)
    
    def generate_quiz(self, student_name: str, student_group: str,
                      question_count: int = 15) -> Quiz:
        """Generate a personalised quiz for a student."""
        seed = self._generate_seed(student_name, student_group)
        
        # Select questions in balanced fashion
        selected_questions = self.bank.get_balanced_selection(question_count, seed)
        
        # Randomise options for each question
        quiz_questions = []
        for idx, q in enumerate(selected_questions, 1):
            shuffled_opts, new_correct = q.get_shuffled_options(seed + idx)
            quiz_questions.append({
                'number': idx,
                'id': q.id,
                'category': q.category,
                'difficulty': q.difficulty,
                'question_text': q.question_text,
                'code_block': q.code_block,
                'options': shuffled_opts,
                'correct_index': new_correct,
                'correct_letter': chr(ord('A') + new_correct),
                'explanation': q.explanation,
                'points': self._calculate_points(q.difficulty, question_count)
            })
        
        quiz_id = hashlib.sha256(
            f"{student_name}:{student_group}:{datetime.now().isoformat()}".encode()
        ).hexdigest()[:12].upper()
        
        return Quiz(
            student_name=student_name,
            student_group=student_group,
            quiz_id=quiz_id,
            generated_at=datetime.now().isoformat(),
            questions=quiz_questions,
            seed=seed,
            total_points=100,
            time_limit_minutes=30
        )
    
    def _calculate_points(self, difficulty: str, total_questions: int) -> int:
        """Calculate points per question based on difficulty."""
        base = 100 // total_questions
        multipliers = {'easy': 0.8, 'medium': 1.0, 'hard': 1.3}
        return round(base * multipliers.get(difficulty, 1.0))

# 
# SECTION 4: EXPORTERS
# 

class QuizExporter:
    """Export quizzes in different formats."""
    
    @staticmethod
    def to_txt(quiz: Quiz, include_answers: bool = False) -> str:
        """Export the quiz in text format."""
        lines = []
        lines.append("=" * 70)
        lines.append(f"  QUIZ: Seminar 3-4 - Operators, Redirection, Filters, Loops")
        lines.append("=" * 70)
        lines.append(f"  Student: {quiz.student_name}")
        lines.append(f"  Group: {quiz.student_group}")
        lines.append(f"  Quiz ID: {quiz.quiz_id}")
        lines.append(f"  Time limit: {quiz.time_limit_minutes} minutes")
        lines.append(f"  Total points: {quiz.total_points}")
        lines.append("=" * 70)
        lines.append("")
        
        for q in quiz.questions:
            lines.append(f"[{q['number']:02d}] [{q['difficulty'].upper()}] ({q['points']}p)")
            lines.append("-" * 50)
            lines.append(q['question_text'])
            
            if q['code_block']:
                lines.append("")
                lines.append("```bash")
                lines.append(q['code_block'])
                lines.append("```")
            
            lines.append("")
            for i, opt in enumerate(q['options']):
                letter = chr(ord('A') + i)
                marker = " ✓" if include_answers and i == q['correct_index'] else ""
                lines.append(f"  {letter}) {opt}{marker}")
            
            if include_answers:
                lines.append("")
                lines.append(f"  → Correct answer: {q['correct_letter']}")
                lines.append(f"  → Explanation: {q['explanation']}")
            
            lines.append("")
            lines.append("")
        
        lines.append("=" * 70)
        lines.append("  ANSWER SHEET")
        lines.append("=" * 70)
        for q in quiz.questions:
            lines.append(f"  {q['number']:02d}. [ A ]  [ B ]  [ C ]  [ D ]")
        lines.append("")
        lines.append("  Student name: _______________________")
        lines.append("  Signature: __________________________")
        lines.append("=" * 70)
        
        return "\n".join(lines)
    
    @staticmethod
    def to_html(quiz: Quiz, include_answers: bool = False) -> str:
        """Export the quiz in printable HTML format."""
        html_content = f"""<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quiz {quiz.quiz_id} - {quiz.student_name}</title>
    <style>
        * {{ box-sizing: border-box; margin: 0; padding: 0; }}
        body {{ 
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            line-height: 1.6;
            padding: 20px;
            max-width: 800px;
            margin: 0 auto;
            background: #f5f5f5;
        }}
        .quiz-header {{
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 25px;
            border-radius: 10px;
            margin-bottom: 25px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.2);
        }}
        .quiz-header h1 {{ font-size: 1.5em; margin-bottom: 15px; }}
        .quiz-info {{ display: grid; grid-template-columns: 1fr 1fr; gap: 10px; }}
        .quiz-info span {{ font-size: 0.95em; }}
        .question {{
            background: white;
            padding: 20px;
            margin-bottom: 20px;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            page-break-inside: avoid;
        }}
        .question-header {{
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 15px;
            padding-bottom: 10px;
            border-bottom: 2px solid #eee;
        }}
        .question-number {{
            font-weight: bold;
            font-size: 1.1em;
            color: #667eea;
        }}
        .difficulty {{
            padding: 3px 10px;
            border-radius: 15px;
            font-size: 0.8em;
            font-weight: bold;
        }}
        .difficulty.easy {{ background: #d4edda; color: #155724; }}
        .difficulty.medium {{ background: #fff3cd; color: #856404; }}
        .difficulty.hard {{ background: #f8d7da; color: #721c24; }}
        .points {{ color: #666; font-size: 0.9em; }}
        .question-text {{ font-size: 1em; margin-bottom: 15px; }}
        .code-block {{
            background: #1e1e1e;
            color: #d4d4d4;
            padding: 15px;
            border-radius: 5px;
            font-family: 'Consolas', 'Monaco', monospace;
            font-size: 0.9em;
            margin: 15px 0;
            overflow-x: auto;
            white-space: pre-wrap;
        }}
        .options {{ list-style: none; }}
        .option {{
            padding: 10px 15px;
            margin: 8px 0;
            border: 2px solid #e0e0e0;
            border-radius: 5px;
            cursor: pointer;
            transition: all 0.2s;
        }}
        .option:hover {{ border-color: #667eea; background: #f8f9ff; }}
        .option-letter {{
            display: inline-block;
            width: 25px;
            height: 25px;
            background: #667eea;
            color: white;
            border-radius: 50%;
            text-align: center;
            line-height: 25px;
            margin-right: 10px;
            font-weight: bold;
        }}
        .correct {{ border-color: #28a745 !important; background: #d4edda !important; }}
        .explanation {{
            background: #e7f3ff;
            padding: 15px;
            border-radius: 5px;
            margin-top: 15px;
            border-left: 4px solid #667eea;
        }}
        .explanation strong {{ color: #667eea; }}
        .answer-sheet {{
            background: white;
            padding: 25px;
            border-radius: 10px;
            margin-top: 30px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }}
        .answer-sheet h2 {{
            color: #667eea;
            margin-bottom: 20px;
            border-bottom: 2px solid #667eea;
            padding-bottom: 10px;
        }}
        .answer-grid {{
            display: grid;
            grid-template-columns: repeat(5, 1fr);
            gap: 10px;
        }}
        .answer-row {{
            display: flex;
            align-items: center;
            gap: 5px;
            padding: 5px;
            border: 1px solid #ddd;
            border-radius: 5px;
        }}
        .answer-row span {{ font-weight: bold; min-width: 25px; }}
        .bubble {{
            width: 20px;
            height: 20px;
            border: 2px solid #667eea;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 0.7em;
            color: #667eea;
        }}
        .signature-area {{
            margin-top: 30px;
            padding-top: 20px;
            border-top: 1px dashed #ccc;
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 30px;
        }}
        .signature-line {{
            border-bottom: 1px solid #333;
            padding-bottom: 5px;
            margin-top: 30px;
        }}
        @media print {{
            body {{ background: white; padding: 0; }}
            .quiz-header {{ box-shadow: none; }}
            .question {{ box-shadow: none; border: 1px solid #ddd; }}
        }}
    </style>
</head>
<body>
    <div class="quiz-header">
        <h1>📝 Quiz: Operators, Redirection, Filters, Loops</h1>
        <div class="quiz-info">
            <span>👤 Student: <strong>{html.escape(quiz.student_name)}</strong></span>
            <span>🎓 Group: <strong>{html.escape(quiz.student_group)}</strong></span>
            <span>🔑 ID: <strong>{quiz.quiz_id}</strong></span>
            <span>⏱️ Time: <strong>{quiz.time_limit_minutes} minutes</strong></span>
            <span>📊 Total: <strong>{quiz.total_points} points</strong></span>
            <span>📅 Generated: <strong>{quiz.generated_at[:10]}</strong></span>
        </div>
    </div>
"""
        
        for q in quiz.questions:
            difficulty_class = q['difficulty']
            html_content += f"""
    <div class="question">
        <div class="question-header">
            <span class="question-number">Question {q['number']}</span>
            <span class="difficulty {difficulty_class}">{q['difficulty'].upper()}</span>
            <span class="points">{q['points']} points</span>
        </div>
        <p class="question-text">{html.escape(q['question_text'])}</p>
"""
            
            if q['code_block']:
                html_content += f"""        <div class="code-block">{html.escape(q['code_block'])}</div>\n"""
            
            html_content += """        <ul class="options">\n"""
            
            for i, opt in enumerate(q['options']):
                letter = chr(ord('A') + i)
                correct_class = ' correct' if include_answers and i == q['correct_index'] else ''
                html_content += f"""            <li class="option{correct_class}">
                <span class="option-letter">{letter}</span>
                {html.escape(opt)}
            </li>\n"""
            
            html_content += """        </ul>\n"""
            
            if include_answers:
                html_content += f"""        <div class="explanation">
            <strong>✓ Correct answer: {q['correct_letter']}</strong><br>
            {html.escape(q['explanation'])}
        </div>\n"""
            
            html_content += """    </div>\n"""
        
        # Answer sheet
        html_content += """
    <div class="answer-sheet">
        <h2>📋 Answer Sheet</h2>
        <div class="answer-grid">
"""
        for q in quiz.questions:
            html_content += f"""            <div class="answer-row">
                <span>{q['number']:02d}.</span>
                <div class="bubble">A</div>
                <div class="bubble">B</div>
                <div class="bubble">C</div>
                <div class="bubble">D</div>
            </div>\n"""
        
        html_content += """        </div>
        <div class="signature-area">
            <div>
                <p>Full name:</p>
                <div class="signature-line"></div>
            </div>
            <div>
                <p>Signature:</p>
                <div class="signature-line"></div>
            </div>
        </div>
    </div>
</body>
</html>"""
        
        return html_content
    
    @staticmethod
    def to_json(quiz: Quiz) -> str:
        """Export the quiz in JSON format."""
        return json.dumps(asdict(quiz), indent=2, ensure_ascii=False)
    
    @staticmethod
    def to_markdown(quiz: Quiz, include_answers: bool = False) -> str:
        """Export the quiz in Markdown format (for PDF conversion)."""
        lines = []
        lines.append("---")
        lines.append("title: Quiz Seminar 3-4")
        lines.append(f"student: {quiz.student_name}")
        lines.append(f"group: {quiz.student_group}")
        lines.append(f"date: {quiz.generated_at[:10]}")
        lines.append("---")
        lines.append("")
        lines.append("# 📝 Quiz: Operators, Redirection, Filters, Loops")
        lines.append("")
        lines.append(f"**Student:** {quiz.student_name} | **Group:** {quiz.student_group}")
        lines.append(f"**ID:** `{quiz.quiz_id}` | **Time:** {quiz.time_limit_minutes} min")
        lines.append("")
        lines.append("---")
        lines.append("")
        
        for q in quiz.questions:
            lines.append(f"## {q['number']}. [{q['difficulty'].upper()}] ({q['points']}p)")
            lines.append("")
            lines.append(q['question_text'])
            
            if q['code_block']:
                lines.append("")
                lines.append("```bash")
                lines.append(q['code_block'])
                lines.append("```")
            
            lines.append("")
            for i, opt in enumerate(q['options']):
                letter = chr(ord('A') + i)
                marker = " ✓" if include_answers and i == q['correct_index'] else ""
                lines.append(f"- **{letter})** {opt}{marker}")
            
            if include_answers:
                lines.append("")
                lines.append(f"> **Answer:** {q['correct_letter']}")
                lines.append(f"> ")
                lines.append(f"> {q['explanation']}")
            
            lines.append("")
            lines.append("---")
            lines.append("")
        
        return "\n".join(lines)

# 
# SECTION 5: CLI INTERFACE
# 

# ANSI Colours
class Colours:
    HEADER = '\033[95m'
    BLUE = '\033[94m'
    CYAN = '\033[96m'
    GREEN = '\033[92m'
    YELLOW = '\033[93m'
    RED = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'

def print_banner():
    """Display the application banner."""
    banner = """
╔═══════════════════════════════════════════════════════════════════════════════╗
║                                                                               ║
║   📝  QUIZ GENERATOR - Seminar 3-4                                            ║
║       Operators | Redirection | Filters | Loops                               ║
║                                                                               ║
║       Bucharest UES - CSIE | Operating Systems                                ║
║                                                                               ║
╚═══════════════════════════════════════════════════════════════════════════════╝
"""
    print(f"{Colours.CYAN}{banner}{Colours.ENDC}")

def read_students_file(filepath: str) -> List[Tuple[str, str]]:
    """Read the student list from file (format: Name,Group)."""
    students = []
    with open(filepath, 'r', encoding='utf-8') as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith('#'):
                continue
            parts = line.split(',')
            if len(parts) >= 2:
                students.append((parts[0].strip(), parts[1].strip()))
    return students

def main():
    parser = argparse.ArgumentParser(
        description='Personalised quiz generator for Seminar 3-4',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Usage examples:
  %(prog)s --student "Smith John" --grupa 1051
  %(prog)s --students list.txt --output ./quizzes/
  %(prog)s --student "Test" --grupa 1000 --format html --answers
  %(prog)s --count 20 --format all --output ./export/
        """
    )
    
    parser.add_argument('--student', '-s', 
                        help='Student name')
    parser.add_argument('--grupa', '-g', 
                        help='Student group')
    parser.add_argument('--students', '-S', 
                        help='File with student list (format: Name,Group)')
    parser.add_argument('--count', '-c', type=int, default=15,
                        help='Number of questions (default: 15)')
    parser.add_argument('--format', '-f', 
                        choices=['txt', 'html', 'json', 'md', 'all'],
                        default='txt',
                        help='Export format (default: txt)')
    parser.add_argument('--output', '-o', default='.',
                        help='Output directory (default: current directory)')
    parser.add_argument('--answers', '-a', action='store_true',
                        help='Include correct answers')
    parser.add_argument('--seed', type=int,
                        help='Manual seed for randomisation')
    parser.add_argument('--list-questions', action='store_true',
                        help='List all questions in the bank')
    parser.add_argument('--stats', action='store_true',
                        help='Display question bank statistics')
    
    args = parser.parse_args()
    
    # Initialisation
    print_banner()
    bank = create_question_bank()
    generator = QuizGenerator(bank)
    
    # Mode: bank statistics
    if args.stats:
        print(f"{Colours.BOLD}📊 Question Bank Statistics:{Colours.ENDC}\n")
        categories = {}
        difficulties = {}
        for q in bank.questions:
            categories[q.category] = categories.get(q.category, 0) + 1
            difficulties[q.difficulty] = difficulties.get(q.difficulty, 0) + 1
        
        print(f"  Total questions: {Colours.GREEN}{len(bank.questions)}{Colours.ENDC}")
        print(f"\n  Per category:")
        for cat, count in sorted(categories.items()):
            print(f"    • {cat}: {count}")
        print(f"\n  Per difficulty:")
        for diff, count in sorted(difficulties.items()):
            print(f"    • {diff}: {count}")
        return 0
    
    # Mode: list questions
    if args.list_questions:
        print(f"{Colours.BOLD}📋 Question List:{Colours.ENDC}\n")
        for q in bank.questions:
            print(f"  [{q.id}] [{q.category:12}] [{q.difficulty:6}] {q.question_text[:60]}...")
        return 0
    
    # Validate arguments
    students = []
    if args.students:
        if not os.path.exists(args.students):
            print(f"{Colours.RED}❌ Error: File {args.students} does not exist!{Colours.ENDC}")
            return 1
        students = read_students_file(args.students)
        print(f"{Colours.GREEN}✓ Loaded {len(students)} students from {args.students}{Colours.ENDC}\n")
    elif args.student and args.grupa:
        students = [(args.student, args.grupa)]
    else:
        parser.print_help()
        print(f"\n{Colours.YELLOW}⚠️ Specify --student and --grupa OR --students{Colours.ENDC}")
        return 1
    
    # Create output directory
    output_dir = Path(args.output)
    output_dir.mkdir(parents=True, exist_ok=True)
    
    # Generate quizzes
    print(f"{Colours.BOLD}🔄 Generating quizzes...{Colours.ENDC}\n")
    
    for name, group in students:
        quiz = generator.generate_quiz(name, group, args.count)
        
        # Clean name for filename
        safe_name = re.sub(r'[^\w\-]', '_', name)
        base_filename = f"quiz_{safe_name}_{group}_{quiz.quiz_id}"
        
        formats_to_export = ['txt', 'html', 'json', 'md'] if args.format == 'all' else [args.format]
        
        for fmt in formats_to_export:
            if fmt == 'txt':
                content = QuizExporter.to_txt(quiz, args.answers)
                ext = 'txt'
            elif fmt == 'html':
                content = QuizExporter.to_html(quiz, args.answers)
                ext = 'html'
            elif fmt == 'json':
                content = QuizExporter.to_json(quiz)
                ext = 'json'
            elif fmt == 'md':
                content = QuizExporter.to_markdown(quiz, args.answers)
                ext = 'md'
            
            filepath = output_dir / f"{base_filename}.{ext}"
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(content)
            
            print(f"  {Colours.GREEN}✓{Colours.ENDC} {name} ({group}): {filepath}")
        
        # Export answer version for instructor
        if not args.answers and args.format != 'json':
            answers_filename = f"{base_filename}_ANSWERS"
            
            # TXT with answers
            content = QuizExporter.to_txt(quiz, True)
            filepath = output_dir / f"{answers_filename}.txt"
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(content)
            print(f"  {Colours.CYAN}✓{Colours.ENDC} (answers): {filepath}")
    
    print(f"\n{Colours.GREEN}✓ Generation complete! {len(students)} quizzes created.{Colours.ENDC}")
    print(f"  📁 Output: {output_dir.absolute()}")
    
    return 0

if __name__ == '__main__':
    sys.exit(main())
