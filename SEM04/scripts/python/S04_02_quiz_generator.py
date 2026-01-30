#!/usr/bin/env python3
"""
S04_02_quiz_generator.py - Quiz Generator for Seminar 4

Generates randomised quizzes for knowledge verification
about grep, sed, awk and regular expressions.

Usage:
    python3 S04_02_quiz_generator.py [--count N] [--category CAT] [--format FMT]
    python3 S04_02_quiz_generator.py --export-all

Options:
    --count N       Number of questions (default: 10)
    --category CAT  regex|grep|sed|awk|all (default: all)
    --format FMT    text|html|json|moodle (default: text)
    --export-all    Export all questions in all formats
"""

import random
import json
import sys
import html
from dataclasses import dataclass, asdict
from typing import List, Optional
from pathlib import Path
from datetime import datetime

#===============================================================================
# QUESTION DATABASE
#===============================================================================

@dataclass
class Question:
    """Represents a quiz question."""
    id: str
    category: str
    difficulty: int  # 1-3
    question: str
    options: List[str]
    correct: int  # index 0-based
    explanation: str
    misconception: Optional[str] = None

# Question database
QUESTIONS = [
    # REGEX Questions
    Question(
        id="R1",
        category="regex",
        difficulty=1,
        question="What does the '.' metacharacter (period) match in regex??",
        options=["A literal period", "Any single character", "Zero or more characters", "Start of line"],
        correct=1,
        explanation="The period (.) matches exactly one arbitrary character, except newline in some implementations.",
        misconception="Confusion with * which means 'zero or more'"
    ),
    Question(
        id="R2",
        category="regex",
        difficulty=1,
        question="What does '^' do when it appears OUTSIDE brackets []??",
        options=["Negation", "Any character", "Start of line", "End of line"],
        correct=2,
        explanation="^ outside [] is an anchor that matches the start of line.",
        misconception="Confusion with [^...] where ^ means negation"
    ),
    Question(
        id="R3",
        category="regex",
        difficulty=2,
        question="What does '^' do when it appears AT THE BEGINNING of [^abc]??",
        options=["Start of line", "Negation - anything EXCEPT a, b, c", "The ^ character", "Syntax error"],
        correct=1,
        explanation="[^abc] means 'any character EXCEPT a, b, or c'.",
        misconception="Confusion with ^ outside [] (anchor)"
    ),
    Question(
        id="R4",
        category="regex",
        difficulty=2,
        question="What is the difference between '*' and '+' in ERE?",
        options=["No difference", "* = 0+, + = 1+", "* = 1+, + = 0+", "* = exact 1"],
        correct=1,
        explanation="* matches 0 or more occurrences, + matches 1 or more (minimum one).",
        misconception="Confusion that * cere cel puțin o apariție"
    ),
    Question(
        id="R5",
        category="regex",
        difficulty=2,
        question="Why does grep 'ab+c' NOT find 'abc' but grep -E 'ab+c' does?",
        options=["Bug in grep", "In BRE, + e literal", "abc does not contain ++", "No difference"],
        correct=1,
        explanation="In BRE (Basic RE), + is a literal character. You need \+ or -E for quantifier.",
        misconception="Misunderstanding of diferenței BRE vs ERE"
    ),
    Question(
        id="R6",
        category="regex",
        difficulty=3,
        question="The pattern [0-9]* can match...",
        options=["At least one digit", "Exactly one digit", "Zero or more digits", "Only complete numbers"],
        correct=2,
        explanation="* allows ZERO repetitions! [0-9]* also matches the empty string.",
        misconception="Assumption that * cere cel puțin o apariție"
    ),
    Question(
        id="R7",
        category="regex",
        difficulty=1,
        question="What POSIX class reprezintă [[:digit:]]?",
        options=["[a-z]", "[A-Z]", "[0-9]", "[a-zA-Z0-9]"],
        correct=2,
        explanation="[[:digit:]] is equivalent to [0-9] - only digits.",
        misconception="Confuzie între clasele POSIX"
    ),
    Question(
        id="R8",
        category="regex",
        difficulty=2,
        question="What pattern finds COMPLETELY empty lines??",
        options=[".*", "^$", ".+", "^."],
        correct=1,
        explanation="^$ = start immediately followed by end = empty line.",
        misconception="Confusion with .* which matches anything, including empty"
    ),
    
    # GREP Questions
    Question(
        id="G1",
        category="grep",
        difficulty=1,
        question="What does the -i option în grep?",
        options=["Inversează output", "Case insensitive", "Include filename", "Ignore errors"],
        correct=1,
        explanation="-i makes the search case insensitive (ignores uppercase/lowercase).",
        misconception="Confusion with -v (inversare)"
    ),
    Question(
        id="G2",
        category="grep",
        difficulty=1,
        question="What does the -v option în grep?",
        options=["Verbose output", "Inverts - lines that do NOT match", "Version", "Validate"],
        correct=1,
        explanation="-v displays lines that do NOT potrivesc pattern-ul.",
        misconception="Confusion with -i"
    ),
    Question(
        id="G3",
        category="grep",
        difficulty=2,
        question="What does .* return grep -c 'error' file.txt?",
        options=["Number of characters", "Number of occurrences", "Number of LINES with match", "Exit code"],
        correct=2,
        explanation="-c counts the LINES containing the pattern, not individual occurrences!",
        misconception="Belief that -c numără toate aparițiile"
    ),
    Question(
        id="G4",
        category="grep",
        difficulty=2,
        question="How do you count ALL occurrences of 'error' in a file??",
        options=["grep -c 'error' file", "grep -n 'error' file", "grep -o 'error' file | wc -l", "grep --count-all 'error'"],
        correct=2,
        explanation="grep -o displays each match on a separate line, wc -l le numără.",
        misconception="Belief that -c face asta"
    ),
    Question(
        id="G5",
        category="grep",
        difficulty=1,
        question="What does grep -E?",
        options=["Error mode", "Extended Regular Expressions", "Exact match", "Exclude files"],
        correct=1,
        explanation="-E enables Extended RE (ERE), equivalent to egrep.",
        misconception="Confusion with options similare"
    ),
    Question(
        id="G6",
        category="grep",
        difficulty=2,
        question="Which option displays ONLY file names with matches?",
        options=["-n", "-c", "-l", "-o"],
        correct=2,
        explanation="-l (lowercase L) displays only file names with at least one match.",
        misconception="Confusion with -L (files WITHOUT match)"
    ),
    Question(
        id="G7",
        category="grep",
        difficulty=2,
        question="grep -A 2 -B 1 displays...",
        options=["2 lines before, 1 after", "1 line before, 2 after", "Total 3 lines", "Only the match line"],
        correct=1,
        explanation="-A = After, -B = Before. So 1 before, the match line, 2 after.",
        misconception="Swapping A și B"
    ),
    Question(
        id="G8",
        category="grep",
        difficulty=3,
        question="What does grep -r --include='*.py'?",
        options=["Search in Python", "Recursive only in .py files", "Include Python output", "Error"],
        correct=1,
        explanation="--include filters the files processed in recursive search.",
        misconception="Misunderstanding of optionslor avansate"
    ),
    
    # SED Questions
    Question(
        id="S1",
        category="sed",
        difficulty=1,
        question="The correct syntax for substitution in sed is:",
        options=["r/old/new/", "s/old/new/", "c/old/new/", "x/old/new/"],
        correct=1,
        explanation="s = substitute. s/pattern/replacement/[flags]",
        misconception="Confusion with alte commands sed (d, p, etc.)"
    ),
    Question(
        id="S2",
        category="sed",
        difficulty=1,
        question="What does flag-ul /g în sed s///g?",
        options=["Get", "Global - toate aparițiile", "Grep mode", "Generate"],
        correct=1,
        explanation="/g replaces ALL occurrences per line, not just the first.",
        misconception="Assumption that implicit înlocuiește toate"
    ),
    Question(
        id="S3",
        category="sed",
        difficulty=2,
        question="The command 'sed 's/a/b/' file.txt' scrie în...",
        options=["file.txt", "stdout (terminal)", "file.txt.bak", "/dev/null"],
        correct=1,
        explanation="sed implicit scrie to stdout, NU modifică the file original!",
        misconception="Belief that sed modifică the file direct"
    ),
    Question(
        id="S4",
        category="sed",
        difficulty=2,
        question="What does sed -i.bak comparativ cu sed -i?",
        options=["No difference", "Creates backup before editing", "Refuses editing", "Interactive mode"],
        correct=1,
        explanation="-i.bak creates file.bak ca backup before modifying file.",
        misconception="Ignoring importanței backup-ului"
    ),
    Question(
        id="S5",
        category="sed",
        difficulty=2,
        question="What does '&' represent in sed replacement s/pattern/&/?",
        options=["Literal character &", "The entire matched text", "And logic", "Append"],
        correct=1,
        explanation="& is replaced with everything the pattern matched.",
        misconception="Tratarea & ca literal"
    ),
    Question(
        id="S6",
        category="sed",
        difficulty=2,
        question="What does comanda sed '/^#/d' file?",
        options=["Dublează the lines cu #", "Șterge the lines care ÎNCEP cu #", "Afișează # lines", "Error"],
        correct=1,
        explanation="/^#/d deletes lines that start with # (comments).",
        misconception="Confusion with alte commands sed"
    ),
    Question(
        id="S7",
        category="sed",
        difficulty=3,
        question="Which delimiter is VALID in sed??",
        options=["Only /", "Only # or |", "Any consistent character", "Only special characters"],
        correct=2,
        explanation="You can use any character as delimiter: s|old|new| or s#old#new#.",
        misconception="Belief that only / is valid"
    ),
    Question(
        id="S8",
        category="sed",
        difficulty=3,
        question="sed 's/\\(.*\\)/[\\1]/' face ce?",
        options=["Error", "Pune text între []", "Șterge text", "Duplică text"],
        correct=1,
        explanation="\(.*\) captures everything, \1 refers to the capture, result: [original text].",
        misconception="Misunderstanding of backreferences"
    ),
    
    # AWK Questions
    Question(
        id="A1",
        category="awk",
        difficulty=1,
        question="What does the variable $0 contain in awk??",
        options=["Primul câmp", "Numele programului", "Întreaga line curentă", "The last câmp"],
        correct=2,
        explanation="$0 reprezintă întreaga line (record) curentă.",
        misconception="Confusion with $1 or other languages"
    ),
    Question(
        id="A2",
        category="awk",
        difficulty=1,
        question="What does $NF contain in awk??",
        options=["Numărul de câmpuri", "The last câmp", "Newline flag", "Next file"],
        correct=1,
        explanation="NF = Number of Fields. $NF = câmpul cu numărul NF = the last câmp.",
        misconception="Confuzie între NF (variabilă) și $NF (câmp)"
    ),
    Question(
        id="A3",
        category="awk",
        difficulty=1,
        question="Cum setezi separatorul de câmpuri la virgulă în awk?",
        options=["-s ','", "-F','", "-d ','", "--sep=','"],
        correct=1,
        explanation="-F specifies Field Separator. -F',' for CSV.",
        misconception="Confusion with options din alte commands"
    ),
    Question(
        id="A4",
        category="awk",
        difficulty=2,
        question="awk '{print $1, $2}' - the comma between $1 and $2 does what?",
        options=["Nimic, e opțională", "Adaugă spațiu (OFS)", "Concatenează direct", "Error"],
        correct=1,
        explanation="Virgula inserează OFS (Output Field Separator, default spațiu).",
        misconception="Ignoring diferenței print cu/fără virgulă"
    ),
    Question(
        id="A5",
        category="awk",
        difficulty=2,
        question="awk '{print $1 $2}' (FĂRĂ virgulă) face ce?",
        options=["Adaugă spațiu", "Concatenează direct (fără separator)", "Error", "Ignoră $2"],
        correct=1,
        explanation="Fără virgulă = concatenare directă, fără separator.",
        misconception="Assumption that spațiul e automat"
    ),
    Question(
        id="A6",
        category="awk",
        difficulty=2,
        question="Ce reprezintă NR în awk?",
        options=["Next Record", "Number of Records (the line curentă)", "Null Reference", "New Row"],
        correct=1,
        explanation="NR = Number of Records = current line number (global, not per file).",
        misconception="Confusion with FNR"
    ),
    Question(
        id="A7",
        category="awk",
        difficulty=2,
        question="When does BEGIN { } execute??",
        options=["On each line", "Once, BEFORE processing", "Once, AFTER processing", "Never"],
        correct=1,
        explanation="BEGIN runs once, before reading any input.",
        misconception="Confusion with END or normal execution"
    ),
    Question(
        id="A8",
        category="awk",
        difficulty=2,
        question="Ce efect are 'NR > 1' ca pattern în awk?",
        options=["Counts lines", "Processes only from line 2 (skip header)", "Compares numbers", "Error"],
        correct=1,
        explanation="NR > 1 is true for all lines except the first (header).",
        misconception="Misunderstanding of pattern-urilor condiționale"
    ),
]

#===============================================================================
# GENERATION FUNCTIONS
#===============================================================================

def get_questions_by_category(category: str = "all") -> List[Question]:
    """Returnează întrebările filtrate pe categorie."""
    if category == "all":
        return QUESTIONS.copy()
    return [q for q in QUESTIONS if q.category == category]

def generate_quiz(
    count: int = 10,
    category: str = "all",
    shuffle_options: bool = True
) -> List[Question]:
    """Generează un quiz randomizat."""
    questions = get_questions_by_category(category)
    random.shuffle(questions)
    
    selected = questions[:min(count, len(questions))]
    
    if shuffle_options:
        for q in selected:
            # Shuffle optionsle păstrând track of correct answer
            correct_text = q.options[q.correct]
            random.shuffle(q.options)
            q.correct = q.options.index(correct_text)
    
    return selected

#===============================================================================
# FORMATARE OUTPUT
#===============================================================================

def format_text(questions: List[Question]) -> str:
    """Formatează quiz-ul ca text simplu."""
    output = []
    output.append("=" * 60)
    output.append("QUIZ: TEXT PROCESSING - GREP, SED, AWK")
    output.append(f"Generat: {datetime.now().strftime('%Y-%m-%d %H:%M')}")
    output.append("=" * 60)
    output.append("")
    
    for i, q in enumerate(questions, 1):
        output.append(f"Întrebarea {i} [{q.category.upper()}] (Dificultate: {'⭐' * q.difficulty})")
        output.append("-" * 40)
        output.append(q.question)
        output.append("")
        for j, opt in enumerate(q.options):
            output.append(f"  {chr(65+j)}) {opt}")
        output.append("")
    
    output.append("=" * 60)
    output.append("CORRECT ANSWERS")
    output.append("=" * 60)
    for i, q in enumerate(questions, 1):
        output.append(f"{i}. {chr(65 + q.correct)} - {q.explanation}")
    
    return "\n".join(output)

def format_html(questions: List[Question]) -> str:
    """Formatează quiz-ul ca HTML."""
    h = html.escape
    output = ["""<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Quiz: Text Processing</title>
    <style>
        body { font-family: Arial, sans-serif; max-width: 800px; margin: 0 auto; padding: 20px; }
        .question { background: #f5f5f5; padding: 15px; margin: 20px 0; border-radius: 8px; }
        .category { display: inline-block; background: #007bff; color: white; padding: 2px 8px; border-radius: 4px; font-size: 12px; }
        .options { margin-left: 20px; }
        .option { margin: 8px 0; padding: 8px; background: white; border-radius: 4px; cursor: pointer; }
        .option:hover { background: #e0e0e0; }
        .answers { background: #e8f5e9; padding: 15px; margin-top: 30px; border-radius: 8px; }
        .answer { margin: 10px 0; }
        h1 { color: #333; }
        .difficulty { color: #ffc107; }
    </style>
</head>
<body>
    <h1>🎓 Quiz: Text Processing</h1>
    <p>Generarat: """ + datetime.now().strftime('%Y-%m-%d %H:%M') + """</p>
"""]
    
    for i, q in enumerate(questions, 1):
        output.append(f"""
    <div class="question">
        <span class="category">{h(q.category.upper())}</span>
        <span class="difficulty">{'⭐' * q.difficulty}</span>
        <h3>Întrebarea {i}</h3>
        <p>{h(q.question)}</p>
        <div class="options">
""")
        for j, opt in enumerate(q.options):
            output.append(f'            <div class="option">{chr(65+j)}) {h(opt)}</div>')
        output.append("""        </div>
    </div>""")
    
    output.append("""
    <div class="answers">
        <h2>📋 Correct Answers</h2>
""")
    for i, q in enumerate(questions, 1):
        output.append(f'        <div class="answer"><strong>{i}. {chr(65+q.correct)}</strong> - {h(q.explanation)}</div>')
    
    output.append("""    </div>
</body>
</html>""")
    
    return "\n".join(output)

def format_json(questions: List[Question]) -> str:
    """Formatează quiz-ul ca JSON."""
    data = {
        "title": "Quiz: Text Processing",
        "generated": datetime.now().isoformat(),
        "questions": [asdict(q) for q in questions]
    }
    return json.dumps(data, indent=2, ensure_ascii=False)

def format_moodle(questions: List[Question]) -> str:
    """Formatează quiz-ul în format Moodle GIFT."""
    output = ["// Quiz: Text Processing - GIFT Format for Moodle", ""]
    
    for q in questions:
        # Escape special characters for GIFT
        question_text = q.question.replace("=", "\\=").replace("~", "\\~").replace("{", "\\{").replace("}", "\\}")
        
        output.append(f"// {q.id} - {q.category}")
        output.append(f"::{q.id}::{question_text} {{")
        
        for j, opt in enumerate(q.options):
            opt_text = opt.replace("=", "\\=").replace("~", "\\~")
            if j == q.correct:
                output.append(f"  ={opt_text}")
            else:
                output.append(f"  ~{opt_text}")
        
        output.append("}")
        output.append("")
    
    return "\n".join(output)

#===============================================================================
# MAIN
#===============================================================================

def main():
    import argparse
    
    parser = argparse.ArgumentParser(description="Quiz Generator for Text Processing")
    parser.add_argument("--count", type=int, default=10, help="Number of questions")
    parser.add_argument("--category", choices=["regex", "grep", "sed", "awk", "all"], default="all")
    parser.add_argument("--format", choices=["text", "html", "json", "moodle"], default="text")
    parser.add_argument("--output", "-o", help="Output file (default: stdout)")
    parser.add_argument("--export-all", action="store_true", help="Export all questions in all formats")
    
    args = parser.parse_args()
    
    if args.export_all:
        base_path = Path("quiz_export")
        base_path.mkdir(exist_ok=True)
        
        all_questions = QUESTIONS.copy()
        
        for fmt in ["text", "html", "json", "moodle"]:
            formatter = {
                "text": format_text,
                "html": format_html,
                "json": format_json,
                "moodle": format_moodle
            }[fmt]
            
            ext = {"text": "txt", "html": "html", "json": "json", "moodle": "gift"}[fmt]
            output_file = base_path / f"quiz_all.{ext}"
            
            with open(output_file, "w", encoding="utf-8") as f:
                f.write(formatter(all_questions))
            
            print(f"✓ Exported: {output_file}")
        
        return
    
    questions = generate_quiz(args.count, args.category)
    
    formatter = {
        "text": format_text,
        "html": format_html,
        "json": format_json,
        "moodle": format_moodle
    }[args.format]
    
    output = formatter(questions)
    
    if args.output:
        with open(args.output, "w", encoding="utf-8") as f:
            f.write(output)
        print(f"Quiz saved în: {args.output}")
    else:
        print(output)

if __name__ == "__main__":
    main()
