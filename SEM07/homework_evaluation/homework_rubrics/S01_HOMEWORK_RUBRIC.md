# S01 Homework Rubric

> **Operating Systems** | ASE Bucharest - CSIE  
> Seminar 01: Shell Fundamentals

---

## Assignment Overview

| ID | Topic | Duration | Difficulty |
|----|-------|----------|------------|
| S01b | Shell Usage | 30 min | ⭐ |
| S01c | Shell Configuration | 45 min | ⭐⭐ |
| S01d | Shell Variables | 40 min | ⭐⭐ |
| S01e | File Globbing | 35 min | ⭐⭐ |
| S01f | Advanced Globbing | 45 min | ⭐⭐⭐ |
| S01g | Fundamental Commands | 50 min | ⭐⭐ |

---

## S01b - Shell Usage (10 points)

### Tasks
1. Navigate file system using `cd`, `pwd`, `ls`
2. Use `man` and `--help` effectively
3. Demonstrate command history navigation
4. Use tab completion

### Grading Criteria

| Criterion | Points | Requirements |
|-----------|--------|--------------|
| Navigation | 3.0 | Correct use of `cd`, `pwd`, `ls -la` |
| Help system | 2.0 | Use `man`, `--help`, `info` |
| History | 2.0 | Use `history`, `!!`, `!n` |
| Tab completion | 2.0 | Demonstrate path and command completion |
| Style | 1.0 | Clean workflow, no unnecessary commands |

### Common Deductions
- `-0.5`: Using absolute paths unnecessarily
- `-0.5`: Not using `ls` options effectively
- `-1.0`: Unable to find help for commands

---

## S01c - Shell Configuration (10 points)

### Tasks
1. View and modify `.bashrc`
2. Create useful aliases
3. Customise PS1 prompt
4. Set and export environment variables

### Grading Criteria

| Criterion | Points | Requirements |
|-----------|--------|--------------|
| .bashrc editing | 3.0 | Safely edit and source |
| Aliases | 2.5 | Create 3+ useful aliases |
| PS1 prompt | 2.5 | Customise with useful info |
| Variables | 2.0 | Set, export, use variables |

### Expected Outputs
```bash
# Alias example
alias ll='ls -la'
alias ..='cd ..'

# PS1 example
export PS1='\u@\h:\w\$ '
```

---

## S01d - Shell Variables (10 points)

### Tasks
1. Define and use local variables
2. Work with environment variables
3. Use special variables ($?, $$, $!, etc.)
4. Demonstrate variable expansion

### Grading Criteria

| Criterion | Points | Requirements |
|-----------|--------|--------------|
| Local variables | 2.5 | Correct syntax, quoting |
| Environment | 2.5 | PATH, HOME, USER manipulation |
| Special variables | 3.0 | Use $?, $$, $#, $@, $* |
| Expansion | 2.0 | ${var:-default}, ${#var}, etc. |

### Common Deductions
- `-1.0`: Not quoting variables properly
- `-0.5`: Incorrect expansion syntax
- `-0.5`: Not understanding local vs environment

---

## S01e - File Globbing (10 points)

### Tasks
1. Use `*`, `?`, `[...]` patterns
2. Create test files for pattern matching
3. Use brace expansion
4. Combine patterns effectively

### Grading Criteria

| Criterion | Points | Requirements |
|-----------|--------|--------------|
| Basic patterns | 3.0 | *, ?, [...] correctly used |
| Brace expansion | 2.5 | {a,b,c}, {1..10} |
| Character classes | 2.5 | [a-z], [0-9], [!...] |
| Complex patterns | 2.0 | Combining multiple patterns |

### Expected Commands
```bash
ls *.txt
ls file?.log
ls [abc]*
echo {1..5}
ls file{1,2,3}.txt
```

---

## S01f - Advanced Globbing (10 points)

### Tasks
1. Enable and use extended globbing
2. Use `**` recursive matching
3. Apply negation patterns
4. Use `@()`, `!()`, `*()`, `+()`, `?()`

### Grading Criteria

| Criterion | Points | Requirements |
|-----------|--------|--------------|
| Enable extglob | 2.0 | `shopt -s extglob` |
| Extended patterns | 4.0 | @(), !(), *(), +(), ?() |
| Recursive | 2.0 | `**` with globstar |
| Practical use | 2.0 | Solve real problems |

### Expected Commands
```bash
shopt -s extglob
ls !(*.txt)           # Everything except .txt
ls *.@(jpg|png|gif)   # Image files
shopt -s globstar
ls **/*.py            # All Python files recursively
```

---

## S01g - Fundamental Commands (10 points)

### Tasks
1. File operations: `cp`, `mv`, `rm`, `mkdir`, `touch`
2. Text viewing: `cat`, `less`, `head`, `tail`
3. File information: `file`, `stat`, `du`, `df`
4. Searching: `which`, `whereis`, `locate`, `find` (basic)

### Grading Criteria

| Criterion | Points | Requirements |
|-----------|--------|--------------|
| File operations | 3.0 | Safe use with options |
| Text viewing | 2.5 | Appropriate tool selection |
| File info | 2.5 | Extract useful information |
| Searching | 2.0 | Find files and commands |

### Common Deductions
- `-1.0`: Using `rm` without confirmation on multiple files
- `-0.5`: Not using `less` for long output
- `-0.5`: Inefficient command choices

---

## Bonus Opportunities

| Bonus | Points | Description |
|-------|--------|-------------|
| Creative PS1 | +0.5 | Prompt with git branch, colours |
| Useful aliases | +0.5 | Beyond standard examples |
| Documentation | +0.5 | Comments explaining choices |

**Maximum total: 10.0 points** (bonuses can recover deductions)

---

*By Revolvix for OPERATING SYSTEMS class | restricted licence 2017-2030*
