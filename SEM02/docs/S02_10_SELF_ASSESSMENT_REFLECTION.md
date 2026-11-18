# Self-Assessment and Reflection - Seminar 3-4
## Operating Systems | Operators, Redirection, Filters, Loops

**Version**: 1.0 | **Purpose**: Metacognition and learning consolidation  
**Philosophy**: Active reflection transforms experience into lasting knowledge

---

## WHAT IS METACOGNITIVE SELF-ASSESSMENT?

```
╔════════════════════════════════════════════════════════════════════╗
║                    ACTIVE LEARNING CYCLE                           ║
╠════════════════════════════════════════════════════════════════════╣
║                                                                    ║
║       ┌──────────────┐                                             ║
║       │  EXPERIENCE  │ ◄─────────────────────────────┐             ║
║       │  (Seminar)   │                               │             ║
║       └──────┬───────┘                               │             ║
║              │                                       │             ║
║              ▼                                       │             ║
║       ┌──────────────┐                               │             ║
║       │  REFLECTION  │  ← THIS DOCUMENT              │             ║
║       │  (What did   │                               │             ║
║       │  I learn?)   │                               │             ║
║       └──────┬───────┘                               │             ║
║              │                                       │             ║
║              ▼                                       │             ║
║       ┌──────────────┐                               │             ║
║       │ ABSTRACTION  │                               │             ║
║       │ (Concepts)   │                               │             ║
║       └──────┬───────┘                               │             ║
║              │                                       │             ║
║              ▼                                       │             ║
║       ┌──────────────┐                               │             ║
║       │EXPERIMENTATION│ ──────────────────────────────┘             ║
║       │  (Practice)   │                                            ║
║       └──────────────┘                                             ║
║                                                                    ║
╚════════════════════════════════════════════════════════════════════╝
```

---

## CHECKPOINT 1: CONTROL OPERATORS

### Knowledge Self-Assessment

Answer honestly (1 = Not at all, 5 = Perfectly):

| Competency | 1 | 2 | 3 | 4 | 5 |
|------------|---|---|---|---|---|
| I know the difference between `;` and `&&` | □ | □ | □ | □ | □ |
| I can explain what `\|\|` does | □ | □ | □ | □ | □ |
| I understand the order `cmd && success \|\| error` | □ | □ | □ | □ | □ |
| I can use `&` for background | □ | □ | □ | □ | □ |
| I know the difference between `{}` and `()` | □ | □ | □ | □ | □ |
| I understand exit codes (`$?`, 0=success) | □ | □ | □ | □ | □ |

### Reflection Questions

```
1. What is the most common mistake with control operators?
   
   My answer: ________________________________________________
   
   ________________________________________________________________

2. When would I use `;` instead of `&&`? Give a concrete example.
   
   My answer: ________________________________________________
   
   ________________________________________________________________

3. What happens if I reverse the order: `cmd || error && success`?
   
   My answer: ________________________________________________
   
   ________________________________________________________________
```

---

## CHECKPOINT 2: I/O REDIRECTION

### Knowledge Self-Assessment

| Competency | 1 | 2 | 3 | 4 | 5 |
|------------|---|---|---|---|---|
| I know what fd 0, 1, 2 are | □ | □ | □ | □ | □ |
| I can use `>` and `>>` correctly | □ | □ | □ | □ | □ |
| I know how to redirect stderr | □ | □ | □ | □ | □ |
| I understand the order in `2>&1` | □ | □ | □ | □ | □ |
| I can use `<<` (here document) | □ | □ | □ | □ | □ |
| I know when to use `/dev/null` | □ | □ | □ | □ | □ |

### Reflection Questions

```
1. What is the difference between `> file 2>&1` and `2>&1 > file`?
   
   My answer: ________________________________________________
   
   ________________________________________________________________

2. When would you use here document (`<<`) in practice?
   
   My answer: ________________________________________________
   
   ________________________________________________________________

3. Why do commands sometimes seem to produce no output?
   
   My answer: ________________________________________________
```

---

## CHECKPOINT 3: TEXT FILTERS

### Knowledge Self-Assessment

| Competency | 1 | 2 | 3 | 4 | 5 |
|------------|---|---|---|---|---|
| I can use `sort` with options (-n, -r, -k) | □ | □ | □ | □ | □ |
| **I know uniq combines adjacent equal lines; sort groups them for global deduplication** | □ | □ | □ | □ | □ |
| I can extract columns with `cut` | □ | □ | □ | □ | □ |
| I know that `tr` operates on CHARACTERS | □ | □ | □ | □ | □ |
| I can construct complex pipelines | □ | □ | □ | □ | □ |
| I understand when to use `tee` | □ | □ | □ | □ | □ |

### Reflection Questions

```
1. Why does `echo -e "a\nb\na" | uniq` produce 3 lines, not 2?
   
   My answer: ________________________________________________
   
   ________________________________________________________________

2. What is the default delimiter for `cut`? How do you change it?
   
   My answer: ________________________________________________

3. What does `tr 'abc' 'xyz'` do? What about `tr 'abc' 'x'`?
   
   My answer: ________________________________________________
   
   ________________________________________________________________
```

---

## CHECKPOINT 4: LOOPS

### Knowledge Self-Assessment

| Competency | 1 | 2 | 3 | 4 | 5 |
|------------|---|---|---|---|---|
| I can write `for` with list/brace/files | □ | □ | □ | □ | □ |
| **I know that `{1..$N}` does NOT work!** | □ | □ | □ | □ | □ |
| I can use `while` with condition | □ | □ | □ | □ | □ |
| **I know the subshell problem with pipe!** | □ | □ | □ | □ | □ |
| I know the difference `break` vs `exit` | □ | □ | □ | □ | □ |
| I can read files line by line | □ | □ | □ | □ | □ |

### Reflection Questions

```
1. Why doesn't `N=5; for i in {1..$N}` work? What's the solution?
   
   My answer: ________________________________________________
   
   ________________________________________________________________

2. What happens to variables modified in a `while` from a pipe?
   
   My answer: ________________________________________________
   
   ________________________________________________________________

3. When would you use `until` instead of `while`?
   
   My answer: ________________________________________________
```

---

## GLOBAL SELF-ASSESSMENT RUBRIC

### Total Score by Competencies

Calculate your score (sum of answers × 5 max per question):

| Module | My Score | Max Score | Percentage |
|--------|----------|-----------|------------|
| Operators | ___/30 | 30 | __% |
| Redirection | ___/30 | 30 | __% |
| Filters | ___/30 | 30 | __% |
| Loops | ___/30 | 30 | __% |
| **TOTAL** | **___/120** | **120** | **___%** |

### Results Interpretation

```
90-100%: 🌟 EXPERT - You're ready for advanced concepts!
70-89%:  ✅ COMPETENT - Solid foundations, practise for mastery
50-69%:  ⚠️ IN PROGRESS - Review concepts with score <3
<50%:    🔄 NEEDS ATTENTION - Recommend tutoring or extra study
```

---

## PERSONAL IMPROVEMENT PLAN

### Identify Weak Areas

```
The 3 concepts where I have the lowest score:

1. _________________________________________________
   Study plan: _________________________________
   
2. _________________________________________________
   Study plan: _________________________________
   
3. _________________________________________________
   Study plan: _________________________________
```

### Concrete Actions

```
╔════════════════════════════════════════════════════════════════════╗
║  ACTION PLAN FOR NEXT WEEK                                         ║
╠════════════════════════════════════════════════════════════════════╣
║                                                                    ║
║  □ I will practise ______________ for ___ minutes/day              ║
║                                                                    ║
║  □ I will re-read the section about _________________ from material║
║                                                                    ║
║  □ I will do exercises from page ___ to ___                        ║
║                                                                    ║
║  □ I will ask for help with the concept: _________________________  ║
║                                                                    ║
║  □ I will test the assignment before deadline (yes/no): ____       ║
║                                                                    ║
╚════════════════════════════════════════════════════════════════════╝
```

---

## POST-SEMINAR REFLECTION

### What I Learned Today

```
Complete in 2-3 sentences for each:

1. THE MOST IMPORTANT new concept for me:
   
   ________________________________________________________________
   
   ________________________________________________________________

2. THE MOST SURPRISING thing (I didn't expect):
   
   ________________________________________________________________
   
   ________________________________________________________________

3. THE MOST USEFUL for my projects:
   
   ________________________________________________________________
   
   ________________________________________________________________
```

### Remaining Questions

```
Questions I still have:

1. ________________________________________________________________

2. ________________________________________________________________

3. ________________________________________________________________
```

---

## RESOURCES FOR DEEPER LEARNING

### Official Documentation
- **GNU Bash Manual**: https://www.gnu.org/software/bash/manual/
- **POSIX Shell**: https://pubs.opengroup.org/onlinepubs/9699919799/

### Interactive Tutorials
- **Learn Shell**: https://www.learnshell.org/
- **ShellCheck**: https://www.shellcheck.net/ (script validation)

### Practice Exercises
- **OverTheWire Bandit**: https://overthewire.org/wargames/bandit/
- **Command Line Challenge**: https://cmdchallenge.com/

### Recommended Books
- "The Linux Command Line" - William Shotts (free online)
- "Classic Shell Scripting" - Robbins & Beebe

---

## WEEKLY JOURNALING TEMPLATE

```bash
# Create this file and complete it weekly
cat > ~/bash_journal_$(date +%Y%m%d).txt << 'EOF'
=== BASH LEARNING JOURNAL ===
Date: [complete]
Time spent: [hours/minutes]

WHAT I PRACTISED:
1. 
2. 
3. 

WHAT I LEARNED NEW:
1. 
2. 

WHAT'S BLOCKING ME:
1. 

WHAT I WILL DO NEXT WEEK:
1. 

COMFORT LEVEL (1-10): ___

EOF
nano ~/bash_journal_$(date +%Y%m%d).txt
```

---

## FINAL SEMINAR CHECKLIST

Before leaving the seminar, check:

```
□ I completed all self-assessment checkpoints
□ I identified at least 2 concepts to review
□ I have a concrete plan for next week
□ I noted the questions I want to ask
□ I downloaded the materials for home
□ I understand what I need to do for the assignment
□ I tested at least one new command today
```

---

*Document generated for Seminar 3-4 OS | ASE Bucharest - CSIE*  
*Metacognitive self-assessment for effective learning*
