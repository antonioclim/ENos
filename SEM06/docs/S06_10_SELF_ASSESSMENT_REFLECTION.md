# Self-Assessment - CAPSTONE Bash Scripting

> **Operating Systems** | ASE Bucharest - CSIE
> Seminar 6: CAPSTONE Projects

---

## Purpose

This document helps you evaluate your progress and identify areas requiring improvement. Complete it **honestly** - the purpose is not a grade, but understanding your own level.

---

## Self-Assessment Rubric

### How to Evaluate Yourself

| Level | Description | Indicator |
|-------|-------------|-----------|
| ⬜ **0 - Don't Know** | Haven't heard of the concept | Cannot explain at all |
| 🟨 **1 - Beginner** | Have seen it but don't use it | Can recognise but cannot write |
| 🟧 **2 - Familiar** | Can use with documentation | Need to look up syntax |
| 🟩 **3 - Competent** | Can use independently | Write correctly first time |
| 🟦 **4 - Advanced** | Can explain to others | Understand nuances and edge cases |

---

## SECTION 1: Bash Fundamentals

### 1.1 Variables and Expansion

| Concept | Self | Verification |
|---------|------|--------------|
| Simple variable declaration | ⬜🟨🟧🟩🟦 | `var="value"` |
| `readonly` variables | ⬜🟨🟧🟩🟦 | `readonly CONST="fix"` |
| `local` variables in functions | ⬜🟨🟧🟩🟦 | `local x=10` |
| Default values `${var:-default}` | ⬜🟨🟧🟩🟦 | When `var` is unset |
| Error on unset `${var:?error}` | ⬜🟨🟧🟩🟦 | Fails if `var` is unset |
| String length `${#var}` | ⬜🟨🟧🟩🟦 | Character count |
| Substring removal `${var%pattern}` | ⬜🟨🟧🟩🟦 | Suffix matching |
| Pattern replacement `${var//old/new}` | ⬜🟨🟧🟩🟦 | Global replacement |

**📝 Reflection:** Which variable expansion do you use most often? What have you never used?

```
[Answer]

```

### 1.2 Special Variables

| Concept | Self | Verification |
|---------|------|--------------|
| `$0` - script name | ⬜🟨🟧🟩🟦 | |
| `$1, $2, ...` - arguments | ⬜🟨🟧🟩🟦 | |
| `$#` - number of arguments | ⬜🟨🟧🟩🟦 | |
| `"$@"` vs `"$*"` difference | ⬜🟨🟧🟩🟦 | Quoting and word splitting |
| `$$` - current PID | ⬜🟨🟧🟩🟦 | |
| `$?` - exit code | ⬜🟨🟧🟩🟦 | |
| `$!` - background PID | ⬜🟨🟧🟩🟦 | |

---

## SECTION 2: Control Structures

### 2.1 Conditions

| Concept | Self | Verification |
|---------|------|--------------|
| `if/elif/else/fi` syntax | ⬜🟨🟧🟩🟦 | |
| `[[ ]]` vs `[ ]` difference | ⬜🟨🟧🟩🟦 | Extended vs POSIX |
| String comparisons (`==`, `!=`, `<`) | ⬜🟨🟧🟩🟦 | |
| Numeric comparisons (`-eq`, `-lt`, `-ge`) | ⬜🟨🟧🟩🟦 | |
| `(( ))` for arithmetic | ⬜🟨🟧🟩🟦 | |
| File tests (`-f`, `-d`, `-r`, `-w`, `-x`) | ⬜🟨🟧🟩🟦 | |
| Regex matching `[[ $var =~ regex ]]` | ⬜🟨🟧🟩🟦 | |
| Logical operators (`&&`, `||`, `!`) | ⬜🟨🟧🟩🟦 | |

**📝 Test:** What does `[[ -z "" ]]` return?

```
[Answer]

```

### 2.2 Loops

| Concept | Self | Verification |
|---------|------|--------------|
| C-style `for` `for ((i=0; i<10; i++))` | ⬜🟨🟧🟩🟦 | |
| `for item in list` | ⬜🟨🟧🟩🟦 | |
| `for` on array `for item in "${arr[@]}"` | ⬜🟨🟧🟩🟦 | |
| `while` with condition | ⬜🟨🟧🟩🟦 | |
| `while read` for files | ⬜🟨🟧🟩🟦 | |
| `until` | ⬜🟨🟧🟩🟦 | |
| `break` and `continue` | ⬜🟨🟧🟩🟦 | |

**📝 Test:** Why is `for file in $(ls *.txt)` problematic?

```
[Answer]

```

### 2.3 Case Statement

| Concept | Self | Verification |
|---------|------|--------------|
| `case/esac` syntax | ⬜🟨🟧🟩🟦 | |
| Pattern matching in `case` | ⬜🟨🟧🟩🟦 | |
| Multiple patterns `pattern1|pattern2)` | ⬜🟨🟧🟩🟦 | |
| Default case `*)` | ⬜🟨🟧🟩🟦 | |

---

## SECTION 3: Functions

| Concept | Self | Verification |
|---------|------|--------------|
| Function declaration | ⬜🟨🟧🟩🟦 | |
| Positional parameters in functions | ⬜🟨🟧🟩🟦 | |
| `local` variables | ⬜🟨🟧🟩🟦 | |
| Return values vs exit codes | ⬜🟨🟧🟩🟦 | |
| Command substitution for output | ⬜🟨🟧🟩🟦 | `result=$(func)` |
| Passing arrays | ⬜🟨🟧🟩🟦 | |
| Nameref `local -n` | ⬜🟨🟧🟩🟦 | Bash 4.3+ |

**📝 Test:** What is the difference between `return 1` and `exit 1` in a function?

```
[Answer]

```

---

## SECTION 4: Arrays

### 4.1 Indexed Arrays

| Concept | Self | Verification |
|---------|------|--------------|
| Declaration `arr=()` | ⬜🟨🟧🟩🟦 | |
| Element access `${arr[0]}` | ⬜🟨🟧🟩🟦 | |
| All elements `${arr[@]}` | ⬜🟨🟧🟩🟦 | |
| Element count `${#arr[@]}` | ⬜🟨🟧🟩🟦 | |
| All indices `${!arr[@]}` | ⬜🟨🟧🟩🟦 | |
| Append `arr+=("new")` | ⬜🟨🟧🟩🟦 | |
| Slice `${arr[@]:1:3}` | ⬜🟨🟧🟩🟦 | |

### 4.2 Associative Arrays

| Concept | Self | Verification |
|---------|------|--------------|
| Declaration `declare -A map` | ⬜🟨🟧🟩🟦 | |
| Setting `map[key]="value"` | ⬜🟨🟧🟩🟦 | |
| Access `${map[key]}` | ⬜🟨🟧🟩🟦 | |
| All keys `${!map[@]}` | ⬜🟨🟧🟩🟦 | |
| Key verification `-v map[key]` | ⬜🟨🟧🟩🟦 | |

**📝 Test:** Why MUST you use `"${arr[@]}"` with quotes?

```
[Answer]

```

---

## SECTION 5: I/O and Redirections

| Concept | Self | Verification |
|---------|------|--------------|
| Stdout redirect `>` and `>>` | ⬜🟨🟧🟩🟦 | |
| Stderr redirect `2>` | ⬜🟨🟧🟩🟦 | |
| Combined `&>` or `2>&1` | ⬜🟨🟧🟩🟦 | |
| Pipe `|` | ⬜🟨🟧🟩🟦 | |
| Process substitution `<(cmd)` | ⬜🟨🟧🟩🟦 | |
| Here-doc `<< EOF` | ⬜🟨🟧🟩🟦 | |
| Here-string `<<<` | ⬜🟨🟧🟩🟦 | |
| File descriptors (`exec 3>`, etc.) | ⬜🟨🟧🟩🟦 | |

---

## SECTION 6: Text Processing

### 6.1 Grep

| Concept | Self | Verification |
|---------|------|--------------|
| Basic pattern matching | ⬜🟨🟧🟩🟦 | |
| `-i` case insensitive | ⬜🟨🟧🟩🟦 | |
| `-v` invert match | ⬜🟨🟧🟩🟦 | |
| `-E` extended regex | ⬜🟨🟧🟩🟦 | |
| `-o` only matching | ⬜🟨🟧🟩🟦 | |
| `-r` recursive | ⬜🟨🟧🟩🟦 | |
| `-l` and `-L` file names | ⬜🟨🟧🟩🟦 | |

### 6.2 Sed

| Concept | Self | Verification |
|---------|------|--------------|
| Substitution `s/old/new/` | ⬜🟨🟧🟩🟦 | |
| Global `s/old/new/g` | ⬜🟨🟧🟩🟦 | |
| In-place `-i` | ⬜🟨🟧🟩🟦 | |
| Delete lines `/pattern/d` | ⬜🟨🟧🟩🟦 | |
| Print specific lines `-n 'Np'` | ⬜🟨🟧🟩🟦 | |
| Range `5,10` | ⬜🟨🟧🟩🟦 | |

### 6.3 Awk

| Concept | Self | Verification |
|---------|------|--------------|
| Print columns `{print $1}` | ⬜🟨🟧🟩🟦 | |
| Field separator `-F:` | ⬜🟨🟧🟩🟦 | |
| Pattern matching `/pattern/` | ⬜🟨🟧🟩🟦 | |
| NR, NF variables | ⬜🟨🟧🟩🟦 | |
| BEGIN/END blocks | ⬜🟨🟧🟩🟦 | |
| Arithmetic in awk | ⬜🟨🟧🟩🟦 | |

---

## SECTION 7: Error Handling

| Concept | Self | Verification |
|---------|------|--------------|
| `set -e` exit on error | ⬜🟨🟧🟩🟦 | |
| `set -u` undefined vars | ⬜🟨🟧🟩🟦 | |
| `set -o pipefail` | ⬜🟨🟧🟩🟦 | |
| `trap` for cleanup | ⬜🟨🟧🟩🟦 | |
| `trap` for signals | ⬜🟨🟧🟩🟦 | |
| Custom exit codes | ⬜🟨🟧🟩🟦 | |
| Pattern `cmd || { error; }` | ⬜🟨🟧🟩🟦 | |
| Retry logic | ⬜🟨🟧🟩🟦 | |

**📝 Test:** What does `set -euo pipefail` do?

```
[Answer]

```

---

## SECTION 8: CAPSTONE Projects

### 8.1 Monitor System

| Competency | Self | Evidence |
|------------|------|----------|
| Can parse `/proc/stat` for CPU | ⬜🟨🟧🟩🟦 | |
| Can calculate % CPU usage | ⬜🟨🟧🟩🟦 | |
| Can parse `/proc/meminfo` | ⬜🟨🟧🟩🟦 | |
| Can implement threshold alerting | ⬜🟨🟧🟩🟦 | |
| Can generate JSON output | ⬜🟨🟧🟩🟦 | |
| Understand load average | ⬜🟨🟧🟩🟦 | |

### 8.2 Backup System

| Competency | Self | Evidence |
|------------|------|----------|
| Can create archives with `tar` | ⬜🟨🟧🟩🟦 | |
| Understand incremental backup | ⬜🟨🟧🟩🟦 | |
| Can implement rotation | ⬜🟨🟧🟩🟦 | |
| Can verify integrity | ⬜🟨🟧🟩🟦 | |
| Understand compression options | ⬜🟨🟧🟩🟦 | |
| Can implement locking | ⬜🟨🟧🟩🟦 | |

### 8.3 Deployer

| Competency | Self | Evidence |
|------------|------|----------|
| Understand rolling deployment | ⬜🟨🟧🟩🟦 | |
| Understand blue-green deployment | ⬜🟨🟧🟩🟦 | |
| Understand canary deployment | ⬜🟨🟧🟩🟦 | |
| Can implement health checks | ⬜🟨🟧🟩🟦 | |
| Can implement rollback | ⬜🟨🟧🟩🟦 | |
| Can manage hooks | ⬜🟨🟧🟩🟦 | |

---

## SECTION 9: Debugging and Testing

| Concept | Self | Verification |
|---------|------|--------------|
| `set -x` for debugging | ⬜🟨🟧🟩🟦 | |
| `bash -n` syntax check | ⬜🟨🟧🟩🟦 | |
| ShellCheck usage | ⬜🟨🟧🟩🟦 | |
| Writing unit tests | ⬜🟨🟧🟩🟦 | |
| Test assertions (`assert_equals`, etc.) | ⬜🟨🟧🟩🟦 | |
| Setup/teardown pattern | ⬜🟨🟧🟩🟦 | |
| Mocking in Bash | ⬜🟨🟧🟩🟦 | |

---

## SECTION 10: Systemd and Automation

| Concept | Self | Verification |
|---------|------|--------------|
| Crontab format | ⬜🟨🟧🟩🟦 | |
| Writing systemd service | ⬜🟨🟧🟩🟦 | |
| Writing systemd timer | ⬜🟨🟧🟩🟦 | |
| `systemctl` commands | ⬜🟨🟧🟩🟦 | |
| `journalctl` for logs | ⬜🟨🟧🟩🟦 | |

---

## SCORE CALCULATION

### Instructions
1. Count how many competencies you marked at each level
2. Calculate the weighted score
3. Identify areas for improvement

### Score Table

| Level | Number of competencies | Multiplier | Subtotal |
|-------|------------------------|------------|----------|
| ⬜ 0 | | × 0 | |
| 🟨 1 | | × 1 | |
| 🟧 2 | | × 2 | |
| 🟩 3 | | × 3 | |
| 🟦 4 | | × 4 | |
| **Total** | | | |

**Maximum possible score:** ~400 points (100 competencies × 4)

### Score Interpretation

| Percentage | Level | Recommendation |
|------------|-------|----------------|
| 0-25% | Beginner | Focus on fundamentals, review docs S06_00-S06_02 |
| 26-50% | Intermediate | Active practice, complete CAPSTONE projects |
| 51-75% | Competent | Deepen testing and error handling |
| 76-100% | Advanced | Mentor colleagues, contribute improvements |

---

## ACTION PLAN

### Top 3 Areas for Improvement

1. **Area:**
   - **Current score:**
   - **Target score:**
   - **Concrete actions:**
   
2. **Area:**

- **Current score:**
- **Target score:**
- **Concrete actions:**


3. **Area:**
   - **Current score:**
   - **Target score:**
   - **Concrete actions:**

### Resources for Improvement

| Area | Recommended resource |
|------|----------------------|
| Variables/Expansion | `docs/S06_09_VISUAL_CHEAT_SHEET.md` |
| Control Flow | `docs/S06_01_Project_Architecture.md` |
| Functions/Arrays | `docs/S06_01_Project_Architecture.md` |
| I/O/Text Processing | `docs/S06_02_Monitor_Implementation.md` |
| Error Handling | `docs/S06_06_Error_Handling.md` |
| Testing | `docs/S06_05_Testing_Framework.md` |
| Projects | Source code in `scripts/projects/` |

---

## PROGRESS TRACKING

| Date | Total Score | Notes |
|------|-------------|-------|
| | | |
| | | |
| | | |
| | | |

---

## FINAL REFLECTION

### What did I learn best?

```
[Answer]

```

### What do I still find difficult?

```
[Answer]

```

### What motivates me to continue?

```
[Answer]

```

### One thing I will do differently next time:

```
[Answer]

```

---

*Self-Assessment Document for Operating Systems | ASE Bucharest - CSIE*
*Seminar 6 CAPSTONE | Complete at the beginning and end of the module*
