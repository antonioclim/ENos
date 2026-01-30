# Self-Assessment and Reflection - Seminar 1
## Operating Systems | Metacognitive Checkpoints

**Purpose**: Develop awareness of your own learning process  
**Time required**: 5-10 minutes at the end of each seminar

---

## LEARNING JOURNAL (Mandatory)

Complete this at the end of the seminar (3 minutes):

| Question | Your Response |
|----------|---------------|
| What concept was most surprising? | ___________________________ |
| What mistake did I make and how did I correct it? | ___________________________ |
| What question do I still have? | ___________________________ |
| How will I use this next week? | ___________________________ |

---

## KNOWLEDGE CHECK

### Section 1: Shell Basics

Rate your confidence (1 = not confident, 5 = very confident):

| Concept | Before Seminar | After Seminar | Action if < 3 |
|---------|----------------|---------------|---------------|
| Difference between shell and terminal | [ ] | [ ] | Review section 2.1 |
| Absolute vs relative paths | [ ] | [ ] | Practice with cd |
| Purpose of shebang line | [ ] | [ ] | Read MAIN_MATERIAL 3.1 |
| What exit code 0 means | [ ] | [ ] | Test with echo $? |

### Section 2: Variables

| Concept | Before Seminar | After Seminar | Action if < 3 |
|---------|----------------|---------------|---------------|
| Local vs exported variables | [ ] | [ ] | Run export demo |
| Correct variable assignment (no spaces) | [ ] | [ ] | Practice in terminal |
| When to use quotes around $VAR | [ ] | [ ] | Review quoting section |
| Purpose of .bashrc | [ ] | [ ] | Edit your own .bashrc |

### Section 3: Globbing

| Concept | Before Seminar | After Seminar | Action if < 3 |
|---------|----------------|---------------|---------------|
| What * matches | [ ] | [ ] | Try ls *.txt |
| What ? matches | [ ] | [ ] | Try ls file?.txt |
| Character classes [abc] | [ ] | [ ] | Create test files |
| Why * does not match hidden files | [ ] | [ ] | Test ls * vs ls .* |

---

## PRACTICAL CHECKPOINTS

Can you do these without looking at notes?

### Checkpoint 1: Navigation
```bash
# Navigate to your home directory
# Create a directory called "test_project"
# Inside it, create subdirectories: src, docs, tests
# Using ONE command with brace expansion
```

[ ] Yes, I can do this confidently
[ ] I need to look at notes
[ ] I need more practice

### Checkpoint 2: Variables
```bash
# Create a variable MY_NAME with your name
# Display it with echo
# Export it
# Verify it exists in a subshell
```

[ ] Yes, I can do this confidently
[ ] I need to look at notes
[ ] I need more practice

### Checkpoint 3: Configuration
```bash
# Add an alias 'll' to your .bashrc
# Add a function 'mkcd' that creates and enters a directory
# Reload .bashrc without opening new terminal
```

[ ] Yes, I can do this confidently
[ ] I need to look at notes
[ ] I need more practice

### Checkpoint 4: Globbing
```bash
# Create 10 files: file1.txt through file10.txt
# List only files 1-5 using a pattern
# List all .txt files but not hidden ones
```

[ ] Yes, I can do this confidently
[ ] I need to look at notes
[ ] I need more practice

---

## COMMON MISTAKES CHECKLIST

Have you made any of these mistakes? Mark the ones you encountered:

### Variable Mistakes
- [ ] Used spaces around = in assignment (VAR = "value")
- [ ] Forgot $ when reading variable (echo VAR instead of echo $VAR)
- [ ] Used $ when assigning (export $VAR="value")
- [ ] Forgot quotes around variable with spaces

### Quoting Mistakes
- [ ] Expected variable to expand in single quotes
- [ ] Forgot to escape special characters
- [ ] Mixed up ' and " behaviour

### Command Mistakes
- [ ] Used rm without checking what would be deleted
- [ ] Forgot -p with mkdir for nested directories
- [ ] Expected .bashrc changes to apply immediately
- [ ] Forgot ; then after if condition

**For each mistake marked, write what you learned:**

```
Mistake: _______________________
What I learned: _______________________
How I will avoid it: _______________________
```

---

## DEEPER REFLECTION

### What went well?
List 3 things that worked well in your learning today:
1. _______________________________________________
2. _______________________________________________
3. _______________________________________________

### What was challenging?
List 2 things you found difficult:
1. _______________________________________________
2. _______________________________________________

### Strategy for improvement
For each challenge, what will you do differently?
1. _______________________________________________
2. _______________________________________________

---

## PREPARATION FOR NEXT SEMINAR

### Topics to Review
Based on your self-assessment, prioritise these for review:

| Priority | Topic | Resource | Time needed |
|----------|-------|----------|-------------|
| High | | | |
| Medium | | | |
| Low | | | |

### Questions to Ask
Write 2-3 questions you want answered in the next seminar:
1. _______________________________________________
2. _______________________________________________
3. _______________________________________________

### Practice Tasks
Choose 2 tasks to practice before next seminar:
- [ ] Write a script that uses all 4 types of quoting
- [ ] Create a personalised .bashrc with 5 aliases
- [ ] Build a directory structure with brace expansion
- [ ] Write a function that takes parameters
- [ ] Debug a script with intentional errors

---

## PEER DISCUSSION PROMPTS

If you have a study partner, discuss:

1. **Compare approaches**: "How did you solve the directory structure task?"
2. **Teach each other**: "Can you explain export vs local variables to me?"
3. **Debug together**: "Let's find the bug in this script"
4. **Challenge each other**: "What does this command do?" (without running it)

---

## WEEKLY LEARNING LOG

Track your progress over the semester:

| Week | Main Topic | Confidence (1-5) | Key Takeaway |
|------|------------|------------------|--------------|
| 1 | Shell Basics | | |
| 2 | Scripting Fundamentals | | |
| 3 | System Administration | | |
| 4 | Text Processing | | |
| 5 | Advanced Scripting | | |
| 6 | Capstone Project | | |

---

## GROWTH MINDSET REMINDERS

- Making mistakes is part of learning
- "Not yet" is better than "I cannot"
- Every expert was once a beginner
- Confusion is the first step to understanding
- Asking questions shows strength, not weakness

---

## INSTRUCTOR FEEDBACK SECTION

*(To be completed by instructor during oral verification)*

| Criterion | Score | Notes |
|-----------|-------|-------|
| Code understanding | /5 | |
| Ability to modify | /5 | |
| Explanation clarity | /5 | |
| Problem-solving approach | /5 | |

**Overall impression:**

**Recommendations:**

---

*Self-Assessment and Reflection | OS Seminar 1 | ASE-CSIE*
*Version 2.0 | January 2025*
