#!/usr/bin/env python3
"""
═══════════════════════════════════════════════════════════════════════════════
QUIZ GENERATOR - Randomised questionnaire generation
Operating Systems | ASE Bucharest - CSIE

Purpose: Generates unique quiz variants for each student
Usage: python3 quiz_generator.py --students 30 --output quizzes/
═══════════════════════════════════════════════════════════════════════════════
"""

import json
import random
import argparse
from pathlib import Path
from typing import List, Dict
from datetime import datetime

# Question bank - Seminar 1
QUESTION_BANK = [
    # Category: Shell Basics
    {
        "id": "SH001",
        "category": "Shell Basics",
        "difficulty": 1,
        "question": "What is the primary role of the shell in Linux?",
        "options": [
            "Manages hardware directly",
            "Interprets commands and transmits them to the kernel",
            "Stores user files",
            "Displays the graphical interface"
        ],
        "correct": 1,
        "explanation": "The shell is a command interpreter that translates user commands for the kernel."
    },
    {
        "id": "SH002",
        "category": "Shell Basics",
        "difficulty": 1,
        "question": "What does the 'pwd' command display?",
        "options": [
            "List of active processes",
            "Current user's password",
            "Current working directory",
            "Logged in user"
        ],
        "correct": 2,
        "explanation": "pwd = Print Working Directory - displays the full path of the current directory."
    },
    {
        "id": "SH003",
        "category": "Shell Basics",
        "difficulty": 1,
        "question": "What does exit code 0 signify in Linux?",
        "options": [
            "Fatal error",
            "Non-existent command",
            "Success - command executed correctly",
            "Insufficient permissions"
        ],
        "correct": 2,
        "explanation": "In Unix/Linux convention, exit code 0 = success, any non-zero value = error."
    },
    
    # Category: Navigation
    {
        "id": "NAV001",
        "category": "Navigation",
        "difficulty": 1,
        "question": "Where does the command 'cd ~' take you?",
        "options": [
            "To the root directory (/)",
            "To the user's home directory",
            "To the previous directory",
            "To the parent directory"
        ],
        "correct": 1,
        "explanation": "Tilde (~) is a shortcut for $HOME - the current user's home directory."
    },
    {
        "id": "NAV002",
        "category": "Navigation",
        "difficulty": 2,
        "question": "What does the command 'cd -' do?",
        "options": [
            "Goes to the parent directory",
            "Goes to the home directory",
            "Returns to the previous directory (OLDPWD)",
            "Displays an error"
        ],
        "correct": 2,
        "explanation": "cd - changes to the previous directory (equivalent to cd $OLDPWD)."
    },
    {
        "id": "NAV003",
        "category": "Navigation",
        "difficulty": 2,
        "question": "Which directory contains system configurations in Linux?",
        "options": [
            "/home",
            "/etc",
            "/var",
            "/usr"
        ],
        "correct": 1,
        "explanation": "/etc contains system configuration files (Editable Text Configuration)."
    },
    
    # Category: Variables
    {
        "id": "VAR001",
        "category": "Variables",
        "difficulty": 1,
        "question": "Which syntax is CORRECT for setting a variable in Bash?",
        "options": [
            "NAME = \"Ion\"",
            "NAME=\"Ion\"",
            "$NAME=\"Ion\"",
            "set NAME \"Ion\""
        ],
        "correct": 1,
        "explanation": "In Bash, variable assignment does NOT allow spaces around the = sign."
    },
    {
        "id": "VAR002",
        "category": "Variables",
        "difficulty": 2,
        "question": "What does the command 'export VARIABLE' do?",
        "options": [
            "Deletes the variable",
            "Makes the variable accessible in subprocesses",
            "Saves the variable permanently to disk",
            "Sends the variable to another computer"
        ],
        "correct": 1,
        "explanation": "export makes the variable part of the environment - it will be inherited by child processes."
    },
    {
        "id": "VAR003",
        "category": "Variables",
        "difficulty": 2,
        "question": "Which special variable contains the exit code of the last command?",
        "options": [
            "$!",
            "$0",
            "$?",
            "$$"
        ],
        "correct": 2,
        "explanation": "$? contains the exit code of the last executed command."
    },
    
    # Category: Quoting
    {
        "id": "QUO001",
        "category": "Quoting",
        "difficulty": 2,
        "question": "What is the difference between single quotes and double quotes in Bash?",
        "options": [
            "There is no difference",
            "Single quotes allow variable expansion, double quotes do not",
            "Double quotes allow variable expansion, single quotes do not",
            "Single quotes are for numbers, double quotes for text"
        ],
        "correct": 2,
        "explanation": "In double quotes variables are expanded. In single quotes everything remains literal."
    },
    {
        "id": "QUO002",
        "category": "Quoting",
        "difficulty": 2,
        "question": "If NAME=\"Student\", what does echo '$NAME' display?",
        "options": [
            "Student",
            "$NAME",
            "Nothing (empty line)",
            "Error"
        ],
        "correct": 1,
        "explanation": "Single quotes preserve everything literally - $NAME is not interpreted."
    },
    
    # Category: Globbing
    {
        "id": "GLO001",
        "category": "Globbing",
        "difficulty": 2,
        "question": "What does the '?' pattern match in globbing?",
        "options": [
            "Zero or more characters",
            "Exactly one character",
            "An optional character",
            "Any character including /"
        ],
        "correct": 1,
        "explanation": "? matches exactly ONE single character, unlike * which matches zero or more."
    },
    {
        "id": "GLO002",
        "category": "Globbing",
        "difficulty": 2,
        "question": "Files: file1.txt, file2.txt, file10.txt. What does 'ls file?.txt' return?",
        "options": [
            "file1.txt file2.txt file10.txt",
            "file1.txt file2.txt",
            "file10.txt",
            "No files"
        ],
        "correct": 1,
        "explanation": "? matches exactly one character. file10 has TWO characters (1,0), so it does not match."
    },
    {
        "id": "GLO003",
        "category": "Globbing",
        "difficulty": 3,
        "question": "Does the command 'ls *' include hidden files (those starting with .)?",
        "options": [
            "Yes, it includes all files",
            "No, * does not include hidden files",
            "Depends on shell settings",
            "Only in interactive mode"
        ],
        "correct": 1,
        "explanation": "By default, * does NOT match files that start with a dot. Use ls .* for hidden files."
    },
    
    # Category: Configuration
    {
        "id": "CFG001",
        "category": "Configuration",
        "difficulty": 2,
        "question": "When is the ~/.bashrc file executed?",
        "options": [
            "At computer startup",
            "With every command executed",
            "When opening a new terminal (interactive non-login shell)",
            "Never automatically, only manually"
        ],
        "correct": 2,
        "explanation": "~/.bashrc is executed with every new interactive shell. For immediate application: source ~/.bashrc"
    },
    {
        "id": "CFG002",
        "category": "Configuration",
        "difficulty": 2,
        "question": "How do you immediately apply changes made to ~/.bashrc?",
        "options": [
            "Restart the computer",
            "Run: source ~/.bashrc",
            "Wait 60 seconds",
            "Changes are applied automatically"
        ],
        "correct": 1,
        "explanation": "source (or .) executes the script in the current shell, immediately applying the changes."
    },
    {
        "id": "CFG003",
        "category": "Configuration",
        "difficulty": 1,
        "question": "What is an alias in Bash?",
        "options": [
            "An environment variable",
            "A shortcut for a command or series of commands",
            "A configuration file",
            "A type of permission"
        ],
        "correct": 1,
        "explanation": "An alias allows defining a shortcut for frequently used commands."
    },
    
    # Category: FHS
    {
        "id": "FHS001",
        "category": "FHS",
        "difficulty": 1,
        "question": "What does the /tmp directory contain in Linux?",
        "options": [
            "Temporary files (deleted on reboot)",
            "System templates",
            "Temporary user backups",
            "Temporary configuration files"
        ],
        "correct": 0,
        "explanation": "/tmp contains temporary files that are usually deleted when the system restarts."
    },
    {
        "id": "FHS002",
        "category": "FHS",
        "difficulty": 2,
        "question": "Which directory contains system logs?",
        "options": [
            "/etc/log",
            "/var/log",
            "/log",
            "/usr/log"
        ],
        "correct": 1,
        "explanation": "/var/log contains system and application logs."
    }
]

class QuizGenerator:
    def __init__(self, question_bank: List[Dict]):
        self.question_bank = question_bank
        
    def generate_quiz(self, num_questions: int = 10, 
                      categories: List[str] = None,
                      shuffle_options: bool = True) -> Dict:
        """Generate a quiz with randomised questions."""
        
        # Filter by categories if specified
        available = self.question_bank
        if categories:
            available = [q for q in available if q['category'] in categories]
        
        # Select random questions
        if num_questions > len(available):
            num_questions = len(available)
        
        selected = random.sample(available, num_questions)
        
        # Process questions
        quiz_questions = []
        for idx, q in enumerate(selected, 1):
            processed = {
                "number": idx,
                "id": q["id"],
                "category": q["category"],
                "question": q["question"],
                "options": q["options"].copy(),
                "correct_original": q["correct"]
            }
            
            # Shuffle options if requested
            if shuffle_options:
                # Preserve the correct answer
                correct_text = q["options"][q["correct"]]
                random.shuffle(processed["options"])
                processed["correct"] = processed["options"].index(correct_text)
            else:
                processed["correct"] = q["correct"]
            
            processed["explanation"] = q["explanation"]
            quiz_questions.append(processed)
        
        return {
            "generated_at": datetime.now().isoformat(),
            "num_questions": num_questions,
            "questions": quiz_questions
        }
    
    def generate_student_quiz(self, student_name: str, student_id: str,
                             num_questions: int = 10) -> Dict:
        """Generate a personalised quiz for a student."""
        quiz = self.generate_quiz(num_questions)
        quiz["student"] = {
            "name": student_name,
            "id": student_id
        }
        return quiz
    
    def export_quiz_txt(self, quiz: Dict, filepath: Path) -> None:
        """Export the quiz in printable text format."""
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write("═" * 70 + "\n")
            f.write("           QUESTIONNAIRE - Seminar 1: Bash Shell\n")
            f.write("           Operating Systems | ASE Bucharest - CSIE\n")
            f.write("═" * 70 + "\n\n")
            
            if "student" in quiz:
                f.write(f"Name: {quiz['student']['name']}\n")
                f.write(f"ID: {quiz['student']['id']}\n\n")
            
            f.write(f"Date: {quiz['generated_at'][:10]}\n")
            f.write(f"Number of questions: {quiz['num_questions']}\n")
            f.write("─" * 70 + "\n\n")
            
            for q in quiz['questions']:
                f.write(f"{q['number']}. [{q['category']}] {q['question']}\n\n")
                for i, opt in enumerate(q['options']):
                    letter = chr(65 + i)  # A, B, C, D
                    f.write(f"   {letter}) {opt}\n")
                f.write("\n   Answer: ______\n\n")
                f.write("─" * 70 + "\n\n")
            
            f.write("\n" + "═" * 70 + "\n")
            f.write("Good luck!\n")
    
    def export_quiz_html(self, quiz: Dict, filepath: Path) -> None:
        """Export the quiz in interactive HTML format."""
        html = f"""<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quiz - Bash Shell</title>
    <style>
        :root {{
            --bg: #1a1a2e;
            --card: #16213e;
            --accent: #4f46e5;
            --success: #10b981;
            --error: #ef4444;
            --text: #e5e7eb;
        }}
        * {{ margin: 0; padding: 0; box-sizing: border-box; }}
        body {{
            font-family: 'Segoe UI', sans-serif;
            background: var(--bg);
            color: var(--text);
            line-height: 1.6;
            padding: 20px;
        }}
        .container {{ max-width: 800px; margin: 0 auto; }}
        h1 {{
            text-align: center;
            margin-bottom: 30px;
            color: var(--accent);
        }}
        .question {{
            background: var(--card);
            border-radius: 12px;
            padding: 25px;
            margin-bottom: 20px;
        }}
        .question-header {{
            display: flex;
            justify-content: space-between;
            margin-bottom: 15px;
        }}
        .question-number {{
            font-weight: bold;
            color: var(--accent);
        }}
        .category {{
            font-size: 0.85em;
            background: rgba(79, 70, 229, 0.2);
            padding: 4px 10px;
            border-radius: 20px;
        }}
        .question-text {{
            font-size: 1.1em;
            margin-bottom: 20px;
        }}
        .options {{ display: flex; flex-direction: column; gap: 10px; }}
        .option {{
            background: rgba(255,255,255,0.05);
            border: 2px solid transparent;
            border-radius: 8px;
            padding: 12px 15px;
            cursor: pointer;
            transition: all 0.3s;
            display: flex;
            align-items: center;
            gap: 10px;
        }}
        .option:hover {{ border-color: var(--accent); }}
        .option.selected {{ border-color: var(--accent); background: rgba(79, 70, 229, 0.2); }}
        .option.correct {{ border-color: var(--success); background: rgba(16, 185, 129, 0.2); }}
        .option.incorrect {{ border-color: var(--error); background: rgba(239, 68, 68, 0.2); }}
        .option-letter {{
            width: 28px; height: 28px;
            background: rgba(255,255,255,0.1);
            border-radius: 50%;
            display: flex; align-items: center; justify-content: center;
            font-weight: bold;
        }}
        .explanation {{
            margin-top: 15px;
            padding: 15px;
            background: rgba(16, 185, 129, 0.1);
            border-left: 4px solid var(--success);
            border-radius: 0 8px 8px 0;
            display: none;
        }}
        .explanation.show {{ display: block; }}
        .submit-btn {{
            background: var(--accent);
            color: white;
            border: none;
            padding: 15px 40px;
            font-size: 1.1em;
            border-radius: 8px;
            cursor: pointer;
            display: block;
            margin: 30px auto;
            transition: transform 0.2s;
        }}
        .submit-btn:hover {{ transform: scale(1.05); }}
        .result {{
            text-align: center;
            padding: 30px;
            background: var(--card);
            border-radius: 12px;
            display: none;
        }}
        .result.show {{ display: block; }}
        .score {{ font-size: 3em; color: var(--accent); }}
    </style>
</head>
<body>
    <div class="container">
        <h1>🐧 Quiz: Bash Shell</h1>
        
        <div id="quiz-container">
"""
        
        for q in quiz['questions']:
            html += f"""
            <div class="question" data-correct="{q['correct']}">
                <div class="question-header">
                    <span class="question-number">Question {q['number']}</span>
                    <span class="category">{q['category']}</span>
                </div>
                <div class="question-text">{q['question']}</div>
                <div class="options">
"""
            for i, opt in enumerate(q['options']):
                letter = chr(65 + i)
                html += f"""                    <div class="option" data-index="{i}" onclick="selectOption(this)">
                        <span class="option-letter">{letter}</span>
                        <span>{opt}</span>
                    </div>
"""
            html += f"""                </div>
                <div class="explanation">{q['explanation']}</div>
            </div>
"""
        
        html += """
        </div>
        
        <button class="submit-btn" onclick="submitQuiz()">Check Answers</button>
        
        <div class="result" id="result">
            <div class="score" id="score">0/0</div>
            <p>Congratulations on completing the quiz!</p>
        </div>
    </div>
    
    <script>
        function selectOption(el) {
            const question = el.closest('.question');
            question.querySelectorAll('.option').forEach(opt => opt.classList.remove('selected'));
            el.classList.add('selected');
        }
        
        function submitQuiz() {
            const questions = document.querySelectorAll('.question');
            let correct = 0;
            
            questions.forEach(q => {
                const correctIdx = parseInt(q.dataset.correct);
                const selected = q.querySelector('.option.selected');
                const explanation = q.querySelector('.explanation');
                
                q.querySelectorAll('.option').forEach((opt, idx) => {
                    opt.classList.remove('correct', 'incorrect');
                    if (idx === correctIdx) {
                        opt.classList.add('correct');
                    }
                });
                
                if (selected) {
                    const selectedIdx = parseInt(selected.dataset.index);
                    if (selectedIdx === correctIdx) {
                        correct++;
                    } else {
                        selected.classList.add('incorrect');
                    }
                }
                
                explanation.classList.add('show');
            });
            
            document.getElementById('score').textContent = `${correct}/${questions.length}`;
            document.getElementById('result').classList.add('show');
            document.querySelector('.submit-btn').style.display = 'none';
        }
    </script>
</body>
</html>
"""
        
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(html)
    
    def export_answer_key(self, quiz: Dict, filepath: Path) -> None:
        """Export the answer key (for instructors)."""
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write("═" * 50 + "\n")
            f.write("    ANSWER KEY - CONFIDENTIAL\n")
            f.write("═" * 50 + "\n\n")
            
            if "student" in quiz:
                f.write(f"Student: {quiz['student']['name']} ({quiz['student']['id']})\n\n")
            
            for q in quiz['questions']:
                letter = chr(65 + q['correct'])
                f.write(f"{q['number']}. {letter}\n")
            
            f.write("\n" + "═" * 50 + "\n")

def main():
    parser = argparse.ArgumentParser(description='Seminar 1 quiz generation')
    parser.add_argument('--students', type=int, default=1,
                       help='Number of students to generate for')
    parser.add_argument('--questions', type=int, default=10,
                       help='Number of questions per quiz')
    parser.add_argument('--output', type=str, default='quizzes',
                       help='Output directory')
    parser.add_argument('--format', choices=['txt', 'html', 'both'], default='both',
                       help='Export format')
    
    args = parser.parse_args()
    
    output_dir = Path(args.output)
    output_dir.mkdir(exist_ok=True)
    
    generator = QuizGenerator(QUESTION_BANK)
    
    print(f"Generating {args.students} quizzes with {args.questions} questions each...")
    print(f"Output: {output_dir}/")
    print()
    
    for i in range(1, args.students + 1):
        student_id = f"S{i:03d}"
        quiz = generator.generate_student_quiz(f"Student {i}", student_id, args.questions)
        
        if args.format in ['txt', 'both']:
            generator.export_quiz_txt(quiz, output_dir / f"quiz_{student_id}.txt")
        
        if args.format in ['html', 'both']:
            generator.export_quiz_html(quiz, output_dir / f"quiz_{student_id}.html")
        
        # Answer key
        generator.export_answer_key(quiz, output_dir / f"key_{student_id}.txt")
        
        print(f"  ✓ Quiz generated for {student_id}")
    
    print()
    print(f"✓ {args.students} quizzes generated in {output_dir}/")

if __name__ == '__main__':
    main()
