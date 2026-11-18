#!/usr/bin/env python3
"""
S05_02_quiz_generator.py - Quiz Generator for Bash Scripting

Operating Systems | ASE Bucharest - CSIE
Seminar 5: Advanced Bash Scripting

Generates interactive quizzes for Bash concepts:
- Functions (scope, return, local)
- Arrays (indexed, associative, iteration)
- Robustness (set -euo pipefail)
- Trap and cleanup

USAGE:
    python3 S05_02_quiz_generator.py                    # Interactive quiz
    python3 S05_02_quiz_generator.py --topic functions  # Specific quiz
    python3 S05_02_quiz_generator.py --export quiz.json # Export questions
    python3 S05_02_quiz_generator.py --html quiz.html   # Generate HTML
"""

import argparse
import json
import random
import sys
from dataclasses import dataclass, field, asdict
from typing import List, Optional
from html import escape

@dataclass
class Question:
    """A quiz question."""
    id: str
    topic: str
    difficulty: str  # easy, medium, hard
    question: str
    code: Optional[str]
    options: List[str]
    correct: int  # index (0-based)
    explanation: str
    misconception: Optional[str] = None
    frequency: Optional[int] = None  # % who get it wrong

# ============================================================
# QUESTION BANK
# ============================================================

QUESTIONS = [
    # ==================== FUNCTIONS ====================
    Question(
        id="func_01",
        topic="functions",
        difficulty="medium",
        question="What does this script display?",
        code='''count=10
process() {
    count=$((count + 1))
}
process
echo $count''',
        options=["10", "11", "Error: undefined variable", "0"],
        correct=1,
        explanation="Variables in Bash functions are GLOBAL by default. Without 'local', count is modified.",
        misconception="Variables in functions are local by default",
        frequency=80
    ),
    Question(
        id="func_02",
        topic="functions",
        difficulty="hard",
        question="What value does 'result' have after execution?",
        code='''get_value() {
    return 42
}
result=$(get_value)''',
        options=["42", "Empty string", "0", "Error"],
        correct=1,
        explanation="'return' sets exit code, it does not return values. $() captures stdout, which is empty.",
        misconception="return returns values like other languages",
        frequency=75
    ),
    Question(
        id="func_03",
        topic="functions",
        difficulty="easy",
        question="What is the difference between 'local x=5' and 'x=5' in a function?",
        code=None,
        options=[
            "No difference",
            "'local' makes variable visible only in function",
            "'local' makes variable readonly",
            "'local' exports variable"
        ],
        correct=1,
        explanation="'local' limits variable scope to current function and functions called from it.",
        frequency=40
    ),
    Question(
        id="func_04",
        topic="functions",
        difficulty="medium",
        question="What does the script display when run with './script.sh EXTERNAL'?",
        code='''#!/bin/bash
show() {
    echo "$1"
}
show "INTERNAL"''',
        options=["EXTERNAL", "INTERNAL", "EXTERNAL INTERNAL", "Nothing"],
        correct=1,
        explanation="$1 in function refers to function arguments, not script arguments.",
        misconception="$1 in function is script argument",
        frequency=65
    ),
    
    # ==================== ARRAYS ====================
    Question(
        id="arr_01",
        topic="arrays",
        difficulty="easy",
        question="What does it display?",
        code='''arr=("apple" "banana" "cherry")
echo ${arr[1]}''',
        options=["apple", "banana", "cherry", "Error"],
        correct=1,
        explanation="Bash arrays start at INDEX 0. arr[0]=apple, arr[1]=banana.",
        misconception="Arrays start at index 1",
        frequency=55
    ),
    Question(
        id="arr_02",
        topic="arrays",
        difficulty="hard",
        question="How many iterations does this loop have?",
        code='''files=("file one.txt" "file two.txt")
for f in ${files[@]}; do
    echo "$f"
done''',
        options=["2", "4", "1", "Error"],
        correct=1,
        explanation="Without quotes, word splitting separates 'file one.txt' into 'file' and 'one.txt'.",
        misconception="for i in ${arr[@]} works correctly",
        frequency=65
    ),
    Question(
        id="arr_03",
        topic="arrays",
        difficulty="hard",
        question="What does 'Keys' display?",
        code='''config[host]="localhost"
config[port]="8080"
echo "Keys: ${!config[@]}"''',
        options=["Keys: host port", "Keys: 0", "Keys: localhost 8080", "Error"],
        correct=1,
        explanation="Without 'declare -A', Bash treats config as indexed array. 'host' becomes 0.",
        misconception="declare -A is optional for associative arrays",
        frequency=70
    ),
    Question(
        id="arr_04",
        topic="arrays",
        difficulty="medium",
        question="After 'unset arr[2]', what is at arr[2]?",
        code='''arr=(a b c d e)
unset arr[2]
echo "Index 2: ${arr[2]}"''',
        options=["c", "d", "Empty/undefined", "Error"],
        correct=2,
        explanation="unset does NOT reindex the array. Creates a 'sparse array' with gap.",
        misconception="unset reindexes array",
        frequency=50
    ),
    Question(
        id="arr_05",
        topic="arrays",
        difficulty="easy",
        question="What does ${#arr[@]} return for arr=(a b c)?",
        code=None,
        options=["abc", "3", "1", "a b c"],
        correct=1,
        explanation="${#arr[@]} returns the number of elements in array.",
        frequency=30
    ),
    
    # ==================== ROBUSTNESS ====================
    Question(
        id="robust_01",
        topic="robustness",
        difficulty="hard",
        question="What does this script display?",
        code='''#!/bin/bash
set -e
if false; then
    echo "A"
fi
echo "B"''',
        options=["Nothing (stops)", "B", "A and B", "Only A"],
        correct=1,
        explanation="set -e does NOT work in test context (if, while, until).",
        misconception="set -e stops on ANY error",
        frequency=75
    ),
    Question(
        id="robust_02",
        topic="robustness",
        difficulty="medium",
        question="What exit code does pipeline return WITHOUT pipefail?",
        code='''false | true | true
echo $?''',
        options=["0", "1", "2", "127"],
        correct=0,
        explanation="Without pipefail, pipeline returns exit code of last command (true=0).",
        misconception="Pipeline returns error of first command",
        frequency=50
    ),
    Question(
        id="robust_03",
        topic="robustness",
        difficulty="medium",
        question="What does it display with set -u?",
        code='''#!/bin/bash
set -u
echo "Value: ${UNDEFINED:-default}"''',
        options=["Error: unbound variable", "Value: default", "Value: ", "Value: UNDEFINED"],
        correct=1,
        explanation="${VAR:-default} provides default value and does NOT trigger set -u error.",
        frequency=45
    ),
    Question(
        id="robust_04",
        topic="robustness",
        difficulty="hard",
        question="What does it display?",
        code='''#!/bin/bash
set -e
false || echo "Recovered"
echo "Continues"''',
        options=["Nothing", "Recovered then stops", "Recovered and Continues", "Only Continues"],
        correct=2,
        explanation="|| 'rescues' the error - entire expression returns 0, set -e is not triggered.",
        frequency=60
    ),
    
    # ==================== TRAP ====================
    Question(
        id="trap_01",
        topic="trap",
        difficulty="medium",
        question="When does 'trap cleanup EXIT' execute?",
        code=None,
        options=[
            "Only on explicit exit",
            "On any exit (normal, error, signal)",
            "Only on errors",
            "Only on signals (SIGINT, etc.)"
        ],
        correct=1,
        explanation="trap EXIT executes on ANY exit from script, regardless of cause.",
        frequency=45
    ),
    Question(
        id="trap_02",
        topic="trap",
        difficulty="hard",
        question="What does it display?",
        code='''trap 'echo "Cleanup"' EXIT
(
    echo "Subshell"
    false
)
echo "After"''',
        options=["Subshell, Cleanup, After, Cleanup", "Subshell, After, Cleanup", "Subshell, Cleanup", "Error"],
        correct=1,
        explanation="Trap is NOT inherited in subshell. Cleanup executes only at main script exit.",
        misconception="trap is inherited in subshell",
        frequency=45
    ),
    Question(
        id="trap_03",
        topic="trap",
        difficulty="easy",
        question="What is the main purpose of the die() function?",
        code='''die() {
    echo "FATAL: $*" >&2
    exit 1
}''',
        options=[
            "Display message and continue",
            "Display error on stderr and stop script",
            "Log message to file",
            "Send alert email"
        ],
        correct=1,
        explanation="die() is a standard pattern for fatal errors - message on stderr + exit.",
        frequency=25
    ),
    
    # ==================== INTEGRATION ====================
    Question(
        id="integ_01",
        topic="integration",
        difficulty="hard",
        question="Which stahomeworknt is TRUE about this code?",
        code='''#!/bin/bash
set -euo pipefail
declare -A config
config[timeout]=30
process() {
    result="${config[timeout]}"
    echo $result
}
value=$(process)''',
        options=[
            "result modifies a global variable (problem)",
            "Script will fail due to set -u",
            "declare -A is not necessary",
            "Script works correctly"
        ],
        correct=3,
        explanation="Although result becomes global, it does not affect functionality here. Code is correct.",
        frequency=40
    ),
    Question(
        id="integ_02",
        topic="integration",
        difficulty="hard",
        question="What is the MAIN problem if no .txt files exist?",
        code='''#!/bin/bash
set -euo pipefail
files=$(ls *.txt 2>/dev/null)
for f in $files; do
    echo "Processing: $f"
done
echo "Done!"''',
        options=[
            "Nothing, it works",
            "ls returns error, set -e stops script",
            "for loop gives error",
            "echo Done does not execute"
        ],
        correct=1,
        explanation="ls returns non-zero when it finds no files. With set -e, script stops.",
        frequency=55
    ),
]

class QuizGenerator:
    """Quiz generator and runner."""
    
    def __init__(self, questions: List[Question] = None):
        self.questions = questions or QUESTIONS
        self.score = 0
        self.total = 0
    
    def get_by_topic(self, topic: str) -> List[Question]:
        """Filter questions by topic."""
        return [q for q in self.questions if q.topic == topic]
    
    def get_by_difficulty(self, difficulty: str) -> List[Question]:
        """Filter by difficulty."""
        return [q for q in self.questions if q.difficulty == difficulty]
    
    def shuffle_questions(self, questions: List[Question], n: int = None) -> List[Question]:
        """Shuffle and limit questions."""
        shuffled = random.sample(questions, len(questions))
        return shuffled[:n] if n else shuffled
    
    def run_interactive(self, questions: List[Question] = None, shuffle: bool = True):
        """Run interactive quiz in terminal."""
        qs = questions or self.questions
        if shuffle:
            qs = self.shuffle_questions(qs)
        
        print("\n" + "="*60)
        print("🎯 QUIZ: Advanced Bash Scripting")
        print("="*60)
        print(f"Questions: {len(qs)}")
        print("Type answer letter (a/b/c/d) or 'q' to quit")
        print("="*60 + "\n")
        
        self.score = 0
        self.total = 0
        
        for i, q in enumerate(qs, 1):
            print(f"\n{'─'*50}")
            print(f"📝 Question {i}/{len(qs)} [{q.topic}] [{q.difficulty}]")
            if q.frequency:
                print(f"   (Wrong by {q.frequency}% of students)")
            print(f"{'─'*50}")
            
            print(f"\n{q.question}\n")
            
            if q.code:
                print("```bash")
                print(q.code)
                print("```\n")
            
            # Display options
            letters = ['a', 'b', 'c', 'd']
            for j, opt in enumerate(q.options):
                print(f"  {letters[j]}) {opt}")
            
            # Wait for answer
            while True:
                try:
                    answer = input("\nYour answer: ").strip().lower()
                except EOFError:
                    print("\n\nQuiz interrupted.")
                    return
                
                if answer == 'q':
                    print("\nQuiz interrupted.")
                    self._print_score()
                    return
                
                if answer in letters[:len(q.options)]:
                    break
                print("Invalid answer. Use a/b/c/d.")
            
            self.total += 1
            user_idx = letters.index(answer)
            
            if user_idx == q.correct:
                self.score += 1
                print("\n✅ CORRECT!")
            else:
                print(f"\n❌ WRONG! Correct answer: {letters[q.correct]}) {q.options[q.correct]}")
            
            print(f"\n📚 Explanation: {q.explanation}")
            
            if q.misconception:
                print(f"⚠️  Common misconception: \"{q.misconception}\"")
            
            input("\n[Press Enter for next question]")
        
        self._print_score()
    
    def _print_score(self):
        """Display final score."""
        print("\n" + "="*60)
        print("📊 FINAL RESULT")
        print("="*60)
        
        if self.total > 0:
            percentage = (self.score / self.total) * 100
            print(f"\nScore: {self.score}/{self.total} ({percentage:.0f}%)")
            
            if percentage >= 90:
                print("🏆 Excellent! You master Bash scripting!")
            elif percentage >= 70:
                print("👍 Good! A few concepts to review.")
            elif percentage >= 50:
                print("📖 Acceptable. Re-read the material.")
            else:
                print("📚 Needs additional study.")
        
        print("="*60 + "\n")
    
    def export_json(self, filepath: str, questions: List[Question] = None):
        """Export questions to JSON."""
        qs = questions or self.questions
        data = [asdict(q) for q in qs]
        
        with open(filepath, 'w', encoding='utf-8') as f:
            json.dump(data, f, indent=2, ensure_ascii=False)
        
        print(f"✅ Exported {len(qs)} questions to {filepath}")
    
    def generate_html(self, filepath: str, questions: List[Question] = None,
                      title: str = "Quiz: Advanced Bash Scripting"):
        """Generate interactive HTML quiz."""
        qs = questions or self.questions
        
        html = f'''<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{escape(title)}</title>
    <style>
        * {{ box-sizing: border-box; }}
        body {{
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            max-width: 800px;
            margin: 0 auto;
            padding: 20px;
            background: #1a1a2e;
            color: #eee;
        }}
        h1 {{ color: #00d9ff; text-align: center; }}
        .question {{
            background: #16213e;
            border-radius: 10px;
            padding: 20px;
            margin: 20px 0;
        }}
        .question-header {{
            display: flex;
            justify-content: space-between;
            margin-bottom: 15px;
            font-size: 0.9em;
            color: #888;
        }}
        .code {{
            background: #0d1117;
            padding: 15px;
            border-radius: 5px;
            font-family: 'Monaco', 'Consolas', monospace;
            font-size: 0.9em;
            overflow-x: auto;
            white-space: pre;
            margin: 15px 0;
        }}
        .options {{ margin: 15px 0; }}
        .option {{
            display: block;
            background: #2d2d4a;
            padding: 12px 15px;
            margin: 8px 0;
            border-radius: 5px;
            cursor: pointer;
            transition: background 0.2s;
        }}
        .option:hover {{ background: #3d3d5a; }}
        .option.selected {{ background: #4a4a7a; }}
        .option.correct {{ background: #2e7d32 !important; }}
        .option.incorrect {{ background: #c62828 !important; }}
        .explanation {{
            display: none;
            background: #1e3a5f;
            padding: 15px;
            border-radius: 5px;
            margin-top: 15px;
        }}
        .explanation.show {{ display: block; }}
        .submit-btn {{
            background: #00d9ff;
            color: #1a1a2e;
            border: none;
            padding: 12px 25px;
            border-radius: 5px;
            cursor: pointer;
            font-size: 1em;
            font-weight: bold;
        }}
        .submit-btn:hover {{ background: #00b8d4; }}
        .submit-btn:disabled {{ background: #555; cursor: not-allowed; }}
        .score {{
            text-align: center;
            font-size: 1.5em;
            padding: 20px;
            background: #16213e;
            border-radius: 10px;
            margin-top: 30px;
        }}
        .badge {{
            display: inline-block;
            padding: 3px 8px;
            border-radius: 3px;
            font-size: 0.8em;
        }}
        .badge.easy {{ background: #4caf50; }}
        .badge.medium {{ background: #ff9800; }}
        .badge.hard {{ background: #f44336; }}
    </style>
</head>
<body>
    <h1>🎯 {escape(title)}</h1>
    <p style="text-align: center; color: #888;">
        {len(qs)} questions • Select answer and press "Check"
    </p>
    
    <div id="quiz">
'''
        
        for i, q in enumerate(qs):
            diff_class = q.difficulty
            html += f'''
        <div class="question" id="q{i}">
            <div class="question-header">
                <span>Question {i+1}/{len(qs)} • {q.topic}</span>
                <span class="badge {diff_class}">{q.difficulty}</span>
            </div>
            <p><strong>{escape(q.question)}</strong></p>
'''
            if q.code:
                html += f'            <div class="code">{escape(q.code)}</div>\n'
            
            html += '            <div class="options">\n'
            for j, opt in enumerate(q.options):
                html += f'                <label class="option" data-correct="{j == q.correct}">\n'
                html += f'                    <input type="radio" name="q{i}" value="{j}" style="margin-right: 10px;">\n'
                html += f'                    {escape(opt)}\n'
                html += '                </label>\n'
            html += '            </div>\n'
            
            html += f'''            <button class="submit-btn" onclick="checkAnswer({i}, {q.correct})">Check</button>
            <div class="explanation" id="exp{i}">
                <p>📚 <strong>Explanation:</strong> {escape(q.explanation)}</p>
'''
            if q.misconception:
                html += f'                <p>⚠️ <strong>Misconception:</strong> "{escape(q.misconception)}"</p>\n'
            html += '            </div>\n        </div>\n'
        
        html += '''
    </div>
    
    <div class="score" id="finalScore" style="display: none;">
        <p>📊 Final score: <span id="scoreValue">0</span>/''' + str(len(qs)) + '''</p>
        <p id="scoreMessage"></p>
    </div>
    
    <script>
        let score = 0;
        let answered = 0;
        const total = ''' + str(len(qs)) + ''';
        
        function checkAnswer(qNum, correct) {
            const options = document.querySelectorAll(`#q${qNum} .option`);
            const selected = document.querySelector(`input[name="q${qNum}"]:checked`);
            const btn = document.querySelector(`#q${qNum} .submit-btn`);
            const exp = document.getElementById(`exp${qNum}`);
            
            if (!selected) {
                alert('Select an answer!');
                return;
            }
            
            btn.disabled = true;
            answered++;
            
            const selectedValue = parseInt(selected.value);
            options.forEach((opt, i) => {
                const input = opt.querySelector('input');
                input.disabled = true;
                if (i === correct) {
                    opt.classList.add('correct');
                } else if (i === selectedValue) {
                    opt.classList.add('incorrect');
                }
            });
            
            if (selectedValue === correct) {
                score++;
            }
            
            exp.classList.add('show');
            
            if (answered === total) {
                showFinalScore();
            }
        }
        
        function showFinalScore() {
            document.getElementById('finalScore').style.display = 'block';
            document.getElementById('scoreValue').textContent = score;
            
            const percentage = (score / total) * 100;
            let message = '';
            if (percentage >= 90) message = '🏆 Excellent!';
            else if (percentage >= 70) message = '👍 Good!';
            else if (percentage >= 50) message = '📖 Acceptable';
            else message = '📚 Needs study';
            
            document.getElementById('scoreMessage').textContent = message;
            document.getElementById('finalScore').scrollIntoView({ behavior: 'smooth' });
        }
    </script>
</body>
</html>
'''
        
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(html)
        
        print(f"✅ Generated HTML quiz: {filepath}")

def main():
    parser = argparse.ArgumentParser(
        description='Quiz Generator for Bash Scripting'
    )
    parser.add_argument('--topic', '-t', 
                        choices=['functions', 'arrays', 'robustness', 'trap', 'integration'],
                        help='Filter by topic')
    parser.add_argument('--difficulty', '-d',
                        choices=['easy', 'medium', 'hard'],
                        help='Filter by difficulty')
    parser.add_argument('--count', '-n', type=int, help='Number of questions')
    parser.add_argument('--export', help='Export to JSON file')
    parser.add_argument('--html', help='Generate HTML quiz')
    parser.add_argument('--list', '-l', action='store_true', help='List questions')
    parser.add_argument('--no-shuffle', action='store_true', help='Do not shuffle questions')
    
    args = parser.parse_args()
    
    generator = QuizGenerator()
    questions = generator.questions
    
    # Filtering
    if args.topic:
        questions = generator.get_by_topic(args.topic)
    if args.difficulty:
        questions = [q for q in questions if q.difficulty == args.difficulty]
    if args.count:
        questions = generator.shuffle_questions(questions, args.count)
    
    if not questions:
        print("❌ No questions found with specified filters.")
        sys.exit(1)
    
    # Actions
    if args.list:
        print(f"\n📋 {len(questions)} questions:\n")
        for q in questions:
            print(f"  [{q.id}] [{q.topic}] [{q.difficulty}] {q.question[:50]}...")
        return
    
    if args.export:
        generator.export_json(args.export, questions)
        return
    
    if args.html:
        generator.generate_html(args.html, questions)
        return
    
    # Interactive quiz
    generator.run_interactive(questions, shuffle=not args.no_shuffle)

if __name__ == '__main__':
    main()
