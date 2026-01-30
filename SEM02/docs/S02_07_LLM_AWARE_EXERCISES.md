# LLM-Aware Exercises - Seminar 02
## Operating Systems | Operators, Redirection, Filters, Loops

Version: 1.1 | Philosophy: Critical integration of AI in the learning process  
Target competency: Evaluation and improvement of LLM-generated code

---

## PHILOSOPHY OF THESE EXERCISES

### Why LLM-Aware?

In the era of generative artificial intelligence (ChatGPT, Claude, Gemini, Copilot), the educational paradigm is fundamentally changing:

```
╔════════════════════════════════════════════════════════════════════╗
║  OLD PARADIGM                 →     NEW PARADIGM                   ║
╠════════════════════════════════════════════════════════════════════╣
║  Memorising syntax            →     Understanding concepts         ║
║  Writing code from scratch    →     Evaluating generated code      ║
║  "You're not allowed to copy" →     "Use AI intelligently"         ║
║  Testing factual knowledge    →     Testing critical thinking      ║
║  Student = executor           →     Student = EVALUATOR            ║
╚════════════════════════════════════════════════════════════════════╝
```

### Competencies Developed

| Competency | Description | Why it's important |
|------------|-------------|-------------------|
| Critical evaluation | Identify errors and constraints in AI code | AI makes subtle mistakes |
| Prompt engineering | Formulate efficient requests | Output quality depends on input |
| AI debugging | Correct generated code | Integration in real workflow |
| Discernment | Know when to use/avoid AI | Efficiency and ethics |
| Meta-learning | Learn through evaluation, not just execution | Deep understanding |

---

## RULES FOR LLM EXERCISES

```
╔════════════════════════════════════════════════════════════════════╗
║  📋 LLM-AWARE EXERCISE RULES                                       ║
╠════════════════════════════════════════════════════════════════════╣
║                                                                    ║
║  1. You CAN use any LLM: ChatGPT, Claude, Gemini, Copilot         ║
║                                                                    ║
║  2. DON'T copy directly - EVALUATE and IMPROVE                     ║
║                                                                    ║
║  3. DOCUMENT:                                                      ║
║     • What prompt you used                                         ║
║     • What the AI generated                                        ║
║     • What problems you found                                      ║
║     • How you corrected                                            ║
║                                                                    ║
║  4. TEST EFFECTIVELY - don't assume it works                       ║
║                                                                    ║
║  5. REFLECT - what did you learn about AI limitations?             ║
║                                                                    ║
╚════════════════════════════════════════════════════════════════════╝
```

---

## EXERCISE L1: The Pipeline Evaluator

Duration: 10 min | Mode: Individual | Level: ⭐⭐

### Objective
Critically evaluate AI-generated pipelines for log file analysis.

### Part 1: Generation (3 min)

Use the following prompt with an LLM of your choice:

```
PROMPT:
Generate 5 different Linux pipelines that analyse the file 
/var/log/syslog (or any log file) and extract useful information.
Each pipeline should use at least 3 commands connected with pipe.
Explain what each one does.
```

### Part 2: Critical Evaluation (5 min)

For EACH generated pipeline, complete the table:

```
╔════════════════════════════════════════════════════════════════════╗
║  PIPELINE EVALUATION #___                                          ║
╠════════════════════════════════════════════════════════════════════╣
║                                                                    ║
║  Pipeline: ________________________________________________        ║
║  ________________________________________________________________  ║
║                                                                    ║
║  □ Does it work? (test effectively!)                               ║
║    └─ If NOT, what error?  _____________________________________   ║
║                                                                    ║
║  □ Output correct and useful?                                      ║
║    └─ What does it produce? ____________________________________   ║
║                                                                    ║
║  □ Efficient?                                                      ║
║    └─ Is there a simpler alternative? __________________________   ║
║                                                                    ║
║  □ Is the AI's explanation correct?                                ║
║    └─ What did it get wrong/omit? ______________________________   ║
║                                                                    ║
║  Score (1-5): ___                                                  ║
║                                                                    ║
╚════════════════════════════════════════════════════════════════════╝
```

### Part 3: Reflection (2 min)

Write in the file `L1_REFLECTION.txt`:

```bash
cat > L1_REFLECTION.txt << 'EOF'
=== EXERCISE L1 REFLECTION ===

1. The most useful pipeline was #___ because:
   

2. Errors made by the LLM:
   

3. How I would improve the prompt:
   

4. What I learned about AI limitations in Bash:
   

EOF
nano L1_REFLECTION.txt
```

### Grading Rubric

| Criterion | Points |
|----------|--------|
| Effective testing of all pipelines | 4p |
| Correct functionality identification | 3p |
| Finding at least 2 problems/improvements | 3p |
| Substantial reflection | 2p |
| Total | 12p |

---

## EXERCISE L2: The AI Script Debugger

Duration: 15 min | Mode: Pairs | Level: ⭐⭐⭐

### Objective
Identify and correct problems in AI-generated scripts.

### Setup

Ask an LLM to generate a script with this prompt:

```
PROMPT:
Write a complete bash script that:
1. Receives a directory as argument
2. For each .txt file in the directory:
   - Counts lines
   - Counts words
   - Calculates size in KB
3. Displays a nicely formatted report
4. Saves the report in report.txt
5. At the end displays totals
```

### Evaluation Task

Step 1: Create a test directory with edge cases:

```bash
# Test directory setup
mkdir -p test_dir
echo "Hello World" > "test_dir/normal.txt"
echo "Test" > "test_dir/file with spaces.txt"
echo "" > "test_dir/empty.txt"
echo -e "Line1\nLine2\nLine3" > "test_dir/multiline.txt"
touch "test_dir/.hidden.txt"
mkdir "test_dir/subdir"
echo "nested" > "test_dir/subdir/nested.txt"
```

Step 2: Test the AI script and complete the checklist:

```
╔════════════════════════════════════════════════════════════════════╗
║  AI SCRIPT DEBUGGING CHECKLIST                                     ║
╠════════════════════════════════════════════════════════════════════╣
║                                                                    ║
║  BASIC FUNCTIONALITY:                                              ║
║  □ Runs without syntax errors?                                     ║
║  □ Processes normal files correctly?                               ║
║  □ Are calculations (lines, words, size) correct?                  ║
║                                                                    ║
║  EDGE CASES:                                                       ║
║  □ Handles files with spaces in names?                             ║
║  □ Handles empty file (empty.txt)?                                 ║
║  □ Ignores directories (subdir/)?                                  ║
║  □ Handles hidden files (.hidden.txt)?                             ║
║  □ What happens if directory doesn't exist?                        ║
║  □ What happens if no .txt files exist?                            ║
║                                                                    ║
║  ERROR HANDLING:                                                   ║
║  □ Checks if argument is provided?                                 ║
║  □ Checks if argument is a valid directory?                        ║
║  □ Has correct shebang (#!/bin/bash)?                              ║
║  □ Uses correct quoting for variables?                             ║
║                                                                    ║
║  OUTPUT:                                                           ║
║  □ Creates report.txt correctly?                                   ║
║  □ Displays totals at the end?                                     ║
║  □ Is formatting clear and readable?                               ║
║                                                                    ║
╚════════════════════════════════════════════════════════════════════╝
```

### Part 3: Bug Fix Documentation

For each bug found, document:

```
╔════════════════════════════════════════════════════════════════════╗
║  BUG #___                                                          ║
╠════════════════════════════════════════════════════════════════════╣
║                                                                    ║
║  DESCRIPTION: _______________________________________________      ║
║                                                                    ║
║  ORIGINAL CODE:                                                    ║
║  ________________________________________________________________  ║
║                                                                    ║
║  CORRECTED CODE:                                                   ║
║  ________________________________________________________________  ║
║                                                                    ║
║  WHY THIS FIX WORKS:                                               ║
║  ________________________________________________________________  ║
║                                                                    ║
╚════════════════════════════════════════════════════════════════════╝
```

---

## EXERCISE L3: Prompt Engineering Challenge

Duration: 12 min | Mode: Pairs | Level: ⭐⭐⭐

### Objective
Iteratively improve prompts to get better AI output.

### The Task

Goal: Get AI to generate a script that counts words in files, handling edge cases.

### Round 1: Basic Prompt (3 min)

```
PROMPT 1: "Write a bash script to count words in files"
```

Test the result. Document problems.

### Round 2: Improved Prompt (3 min)

Add constraints based on Round 1 problems:

```
PROMPT 2: [Your improved prompt here]
```

Test again. Document improvements and remaining issues.

### Round 3: Expert Prompt (3 min)

Final prompt with all learned constraints:

```
PROMPT 3: [Your expert prompt here]
```

### Comparison Matrix

```
╔════════════════════════════════════════════════════════════════════╗
║  PROMPT EVOLUTION MATRIX                                           ║
╠════════════════════════════════════════════════════════════════════╣
║                                                                    ║
║  ASPECT              │ Prompt 1 │ Prompt 2 │ Prompt 3              ║
║  ────────────────────┼──────────┼──────────┼───────────            ║
║  Lines of code       │          │          │                       ║
║  Handles spaces      │ □        │ □        │ □                     ║
║  Has error handling  │ □        │ □        │ □                     ║
║  Correct quoting     │ □        │ □        │ □                     ║
║  Has help message    │ □        │ □        │ □                     ║
║  Uses set -e         │ □        │ □        │ □                     ║
║  ────────────────────┼──────────┼──────────┼───────────            ║
║  Overall score /10   │          │          │                       ║
║                                                                    ║
╚════════════════════════════════════════════════════════════════════╝
```

---

## EXERCISE L4: Human vs AI Code Review

Duration: 10 min | Mode: Individual | Level: ⭐⭐⭐⭐

### Objective
Compare your code review skills with AI capabilities.

### The Script to Review

```bash
#!/bin/bash
# backup.sh - Backup files

for f in *; do
    cp $f backup_$f
done
echo "Done"
```

### Part 1: Your Review (4 min)

Without using AI, identify ALL problems:

```bash
cat > L4_MY_REVIEW.txt << 'EOF'
=== MY CODE REVIEW ===

PROBLEMS FOUND:
1. 
2. 
3. 
4. 
5. 

SUGGESTED FIXES:


EOF
nano L4_MY_REVIEW.txt
```

### Part 2: AI Review (3 min)

Now ask an LLM:
```
PROMPT: Do a detailed code review for this bash script and identify 
all problems, including edge cases and unrespected best practices:

[copy the script]
```

Save the result in `L4_AI_REVIEW.txt`.

### Part 3: Comparison (3 min)

```bash
cat > L4_COMPARISON.txt << 'EOF'
=== REVIEW COMPARISON ===

WHAT I FOUND BUT AI DIDN'T:
1. 
2. 

WHAT AI FOUND BUT I DIDN'T:
1. 
2. 

WHO WAS MORE COMPLETE? □ Me  □ AI  □ Similar

CONCLUSION:
AI is better at: 
I am better at: 
Optimal review strategy: 

EOF
nano L4_COMPARISON.txt
```

### All Script Problems (for instructor)

| # | Problem | Severity | Explanation |
|---|---------|----------|-------------|
| 1 | `$f` without quotes | Critical | Fails for files with spaces |
| 2 | `for f in *` dangerous | Major | Includes directories, not just files |
| 3 | Doesn't check cp success | Major | Silent errors |
| 4 | `backup_$f` may overwrite | Major | Doesn't check if exists |
| 5 | Doesn't exclude backup_* | Minor | May create backup_backup_... |
| 6 | Shebang ok but no set -e | Minor | Continues on errors |
| 7 | "Done" message unconditional | Minor | Displayed even on failure |
| 8 | Doesn't log what it does | Minor | Difficult debugging |
| 9 | Has no help/usage | Minor | Poor UX |
| 10 | Hardcoded * | Minor | Not configurable |

---

## EXERCISE L5: Bash ↔ Python Translator

Duration: 12 min | Mode: Pairs | Level: ⭐⭐⭐

### Objective
Evaluate AI's ability to translate between languages whilst preserving functionality.

### Python Script to Translate

```python
#!/usr/bin/env python3
import sys
from collections import Counter

if len(sys.argv) < 2:
    print("Usage: script.py <filename>")
    sys.exit(1)

filename = sys.argv[1]
try:
    with open(filename) as f:
        words = f.read().lower().split()
        for word, count in Counter(words).most_common(10):
            print(f"{count:4d} {word}")
except FileNotFoundError:
    print(f"Error: {filename} not found")
    sys.exit(1)
```

### Task

Step 1: Ask for translation to Bash:
```
PROMPT: Translate this Python script to Bash, preserving exactly the same 
functionality, including error handling and output formatting.
```

Step 2: Test both versions:

```bash
# Create test file
echo "the quick brown fox jumps over the lazy dog the fox" > test.txt

# Test Python
python3 original.py test.txt > output_python.txt

# Test Bash (AI version)
bash translated.sh test.txt > output_bash.txt

# Compare
diff output_python.txt output_bash.txt
```

Step 3: Document differences:

```
╔════════════════════════════════════════════════════════════════════╗
║  TRANSLATION COMPARISON                                            ║
╠════════════════════════════════════════════════════════════════════╣
║                                                                    ║
║  FUNCTIONALITY:                                                    ║
║  □ Identical output for normal input?                              ║
║  □ Equivalent error handling?                                      ║
║  □ Correct exit codes?                                             ║
║                                                                    ║
║  WHAT THE TRANSLATION LOST:                                        ║
║  1. ________________________________________________               ║
║  2. ________________________________________________               ║
║                                                                    ║
║  WHAT IT GAINED/IS DIFFERENT:                                      ║
║  1. ________________________________________________               ║
║  2. ________________________________________________               ║
║                                                                    ║
║  WHICH IS MORE ELEGANT?                                            ║
║  □ Python  □ Bash  □ Depends on context                            ║
║                                                                    ║
║  WHEN WOULD I USE EACH?                                            ║
║  Python: ________________________________________________          ║
║  Bash: __________________________________________________          ║
║                                                                    ║
╚════════════════════════════════════════════════════════════════════╝
```

---

## EXERCISE L6: The Fingerprint Detective

Duration: 10 min | Mode: Individual | Level: ⭐⭐⭐

### Objective
Learn to recognise AI-generated code patterns — a skill that will help you evaluate your own AI-assisted work and avoid obvious "tells" that trigger automated detection.

### The Challenge
You receive two scripts that accomplish the same task (counting regular files in a directory). One was written by a student under time pressure, one by ChatGPT. Your job: figure out which is which.

### Script A
```bash
#!/bin/bash
# count files
for f in *; do
    [ -f "$f" ] && ((c++))
done
echo $c
```

### Script B  
```bash
#!/bin/bash
# This script counts the number of regular files in the current directory
# It iterates through all items and checks if each is a regular file
# The count is stored in a variable and displayed at the end

file_count=0

for item in *; do
    if [[ -f "$item" ]]; then
        ((file_count++))
    fi
done

echo "Total regular files: $file_count"
```

### Task

Complete this analysis:

```
╔════════════════════════════════════════════════════════════════════╗
║  AI FINGERPRINT ANALYSIS                                           ║
╠════════════════════════════════════════════════════════════════════╣
║                                                                    ║
║  1. Which script is AI-generated?  □ A  □ B                        ║
║                                                                    ║
║  2. What "tells" revealed it? (list at least 3)                    ║
║     a) ________________________________________________            ║
║     b) ________________________________________________            ║
║     c) ________________________________________________            ║
║                                                                    ║
║  3. Which would YOU submit as your homework? □ A  □ B              ║
║     Why? ___________________________________________________       ║
║                                                                    ║
║  4. If you used AI to help write code, how would you modify        ║
║     the output to make it look more "human"?                       ║
║     ____________________________________________________________   ║
║                                                                    ║
╚════════════════════════════════════════════════════════════════════╝
```

### Discussion Points (for instructor)

**Common AI tells present in Script B:**
1. Variable naming: `file_count` vs `c` — beginners under pressure use short names
2. Comment density: 3 lines of comments for 7 lines of code (43%) — students under-comment
3. Output formatting: "Total regular files:" vs raw number — AI loves polished output
4. Consistent style: Perfect indentation throughout — students are messier
5. Explanation in comments: AI explains *what* code does; students explain *why* (if at all)

**The irony:** Script B is technically "better" code — but that's precisely what makes it suspicious for a beginner assignment. Good code from a novice should have rough edges.

**Key teaching point:** Understanding these patterns helps students in two ways:
- Evaluate AI-generated code more critically
- If using AI assistance, learn to "humanise" the output appropriately

### Grading Rubric

| Criterion | Points |
|----------|--------|
| Correct identification | 3p |
| At least 3 valid "tells" identified | 4p |
| Thoughtful submission choice rationale | 2p |
| Practical humanisation strategy | 3p |
| **Total** | **12p** |

---

## LLM COMPETENCY MATRIX

At the end of these exercises, you should be able to evaluate:

| Competency | Current Level | Relevant Exercise |
|------------|--------------|-------------------|
| Critical evaluation of AI code | □ Beginner □ Medium □ Advanced | L1, L2 |
| Prompt engineering | □ Beginner □ Medium □ Advanced | L3 |
| AI output debugging | □ Beginner □ Medium □ Advanced | L2, L4 |
| Human vs AI comparison | □ Beginner □ Medium □ Advanced | L4, L6 |
| Recognising AI fingerprints | □ Beginner □ Medium □ Advanced | L6 |
| Understanding AI constraints | □ Beginner □ Medium □ Advanced | All |

---

## CONCLUSION: WHEN TO USE AI

```
╔════════════════════════════════════════════════════════════════════╗
║  ✓ USE AI FOR:                                                     ║
╠════════════════════════════════════════════════════════════════════╣
║  • Generating boilerplate / initial structure                      ║
║  • Exploring options / "how could I do X?"                         ║
║  • Debugging suggestions (but verify!)                             ║
║  • Documenting existing code                                       ║
║  • Translating between languages (with verification)               ║
║  • Explaining concepts                                             ║
╠════════════════════════════════════════════════════════════════════╣
║  ✗ AVOID AI FOR:                                                   ║
╠════════════════════════════════════════════════════════════════════╣
║  • Critical code without manual review                             ║
║  • Security and authentication                                     ║
║  • Assumptions about file/command existence                        ║
║  • Complex business logic                                          ║
║  • When you cannot verify correctness                              ║
╠════════════════════════════════════════════════════════════════════╣
║  🔑 GOLDEN RULE: AI is an ASSISTANT, not a REPLACEMENT             ║
║     YOU remain RESPONSIBLE for the code!                           ║
╚════════════════════════════════════════════════════════════════════╝
```

---

## FINAL REFLECTION

Complete at the end of all exercises:

```bash
cat > LLM_FINAL_REFLECTION.txt << 'EOF'
=== FINAL REFLECTION: AI IN PROGRAMMING ===

1. The biggest advantage of using AI for code:
   

2. The biggest limitation/danger:
   

3. How I will integrate AI in my workflow:
   

4. What kind of tasks I will always give to AI:
   

5. What kind of tasks I will NEVER give to AI without verification:
   

6. My grade for AI as a programming assistant (1-10): ___

7. Message to my future self about using AI:
   

EOF
nano LLM_FINAL_REFLECTION.txt
```

---

*Document generated for Seminar 02 OS | ASE Bucharest - CSIE*  
*Exercises for critical integration of AI in the learning process*
