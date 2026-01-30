# Peer Instruction: Text Processing
## Questions for Active Learning - Regex, GREP, SED, AWK

> Operating Systems | Bucharest University of Economic Studies - CSIE  
> Seminar 4 | Peer Instruction Questions  
> Total questions: 24 | Estimated time: 3-5 min per question

---

## Usage Guide

### What is Peer Instruction?

Peer Instruction is an active learning method developed by Eric Mazur (Harvard). Process:

1. Question presentation (30 sec) - Instructor displays the question
2. Individual vote (1 min) - Students vote WITHOUT discussion
3. Discussion in pairs (2 min) - Students explain their choices to each other
4. Re-vote (30 sec) - Students vote again
5. Explanation (1-2 min) - Instructor explains the correct answer

### When to use each question

| Cod | Moment | Topic |
|-----|--------|-------|
| PI-R1 - PI-R6 | After Regex intro | Regular Expressions |
| PI-G1 - PI-G6 | After the GREP | GREP |
| PI-S1 - PI-S6 | After the SED | SED |
| PI-A1 - PI-A6 | After the AWK | AWK |

---

# SECTION 1: EXPRESII REGULATE

## PI-R1: Globbing vs Regex

```
┌─────────────────────────────────────────────────────────────────────────┐
│  PEER INSTRUCTION R1: Globbing vs Regex                                │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  What is the MAIN difference between these two commands?             │
│                                                                         │
│     A) ls *.txt                                                         │
│     B) grep '.*\.txt' filelist.txt                                     │
│                                                                         │
│  Options:                                                               │
│  ┌───┐                                                                  │
│  │ 1 │ They are functionally equivalent                                     │
│  ├───┤                                                                  │
│  │ 2 │ A uses shell globbing, B uses regex                   │
│  ├───┤                                                                  │
│  │ 3 │ A searches in files, B lists files                          │
│  ├───┤                                                                  │
│  │ 4 │ B is syntactically wrong                                            │
│  └───┘                                                                  │
│                                                                         │
│  Difficulty: ⭐⭐ | Misconception: M1.1 (confusion * în glob vs regex) │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

Correct answer: 2

Detailed explanation:

```bash
# GLOBBING (shell pattern matching)
ls *.txt
# * = any characters (zero or more)
# Shell expands BEFORE sending to command
# ls primește: file1.txt file2.txt file3.txt

# REGEX (grep, sed, awk)
grep '.*\.txt' filelist.txt
# . = any SINGLE character
# * = zero or more of PRECEDING
# .* = the combination = any characters
# \. = punct LITERAL (escapat)

# CONFUZIA MAJORĂ:
# Glob: * alone = anything
# Regex: * singur = quantificator (are nevoie de ceva înainte)
```

Why it matters: Students coming from shell scripting automatically apply globbing rules to regex, which leads to incorrect patterns.

---

## PI-R2: What does this pattern match?

```
┌─────────────────────────────────────────────────────────────────────────┐
│  PEER INSTRUCTION R2: Interpretare Pattern                             │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  The file contains:                                                     │
│     abc                                                                 │
│     ac                                                                  │
│     aXc                                                                 │
│     a1c                                                                 │
│     abbc                                                                │
│                                                                         │
│  Command: grep 'a.c' file.txt                                          │
│                                                                         │
│  What lines will it display?                                                     │
│  ┌───┐                                                                  │
│  │ 1 │ abc, ac, aXc, a1c, abbc (all)                                 │
│  ├───┤                                                                  │
│  │ 2 │ abc, aXc, a1c (but NOT ac și abbc)                               │
│  ├───┤                                                                  │
│  │ 3 │ abc, aXc, a1c, abbc (but NOT ac)                                 │
│  ├───┤                                                                  │
│  │ 4 │ Only abc                                                         │
│  └───┘                                                                  │
│                                                                         │
│  Difficulty: ⭐⭐ | Misconception: M1.1 (. = any, but EXACTLY one)   │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

Correct answer: 3

Explanation:

```bash
# Pattern: a.c
# . = EXACTLY one character (any, but must exist)

# abc (. = b)
# ac (missing the character between a and c)
# aXc (. = X)
# a1c (. = 1)
# abbc (pattern found in middle: a[b]bc contains "abc")

# SURPRISE: abbc matches because grep searches for SUBSTRING
# If we wanted exactly 3 characters: grep '^a.c$'
```

---

## PI-R3: Negation in character classes

```
┌─────────────────────────────────────────────────────────────────────────┐
│  PEER INSTRUCTION R3: [^...] - Ce înseamnă?                            │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  What does the pattern match [^0-9]?                                      │
│                                                                         │
│  ┌───┐                                                                  │
│  │ 1 │ Lines that START with o cifră                                     │
│  ├───┤                                                                  │
│  │ 2 │ Any character that is NOT cifră                               │
│  ├───┤                                                                  │
│  │ 3 │ Lines that do NOT contain cifre                                      │
│  ├───┤                                                                  │
│  │ 4 │ Start of line followed by 0-9                                   │
│  └───┘                                                                  │
│                                                                         │
│  Difficulty: ⭐⭐⭐ | Misconception: M1.4 (confusion ^ context)        │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

Correct answer: 2

Explanation:

```bash
# ^ are DOUĂ semnificații diferite în regex:

# 1. ANCHOR (în afara [])
^abc     # Line STARTS with "abc"

# 2. NEGAȚIE (ÎNĂUNTRUL [] la început)
[^abc]   # Any character that is NOT a, b, or c
[^0-9]   # Any character that is NOT a digit

# Trap: [^0-9] matches ONE CHARACTER, not an entire line!
grep '[^0-9]' file.txt   # Lines with AT LEAST one non-digit

# For lines WITHOUT any digits:
grep -v '[0-9]' file.txt
```

---

## PI-R4: BRE vs ERE - Quantificatori

```
┌─────────────────────────────────────────────────────────────────────────┐
│  PEER INSTRUCTION R4: Why does it not work +?                         │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  Command: grep 'ab+c' file.txt                                         │
│                                                                         │
│  The file contains: abc, abbc, abbbc, ac                                │
│                                                                         │
│  The output is EMPTY. Why?                                            │
│                                                                         │
│  ┌───┐                                                                  │
│  │ 1 │ The pattern is wrong, + does not exist in regex                       │
│  ├───┤                                                                  │
│  │ 2 │ În BRE, + is a LITERAL character, not a quantifier               │
│  ├───┤                                                                  │
│  │ 3 │ + requires at least 2 characters, not 1                              │
│  ├───┤                                                                  │
│  │ 4 │ File does not contain the text "ab+c"                               │
│  └───┘                                                                  │
│                                                                         │
│  Difficulty: ⭐⭐⭐ | Misconception: M1.3 (BRE vs ERE)                │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

Correct answer: 2

Explanation:

```bash
# grep implicit folosește BRE (Basic Regular Expression)
# In BRE, + is a LITERAL character!

grep 'ab+c' file.txt
# Caută literalmente "ab+c" (cu semnul plus)

# Solutions:

# 1. Folosește ERE
grep -E 'ab+c' file.txt    # abc, abbc, abbbc

# 2. Escape în BRE
grep 'ab\+c' file.txt      # abc, abbc, abbbc

# TABEL BRE vs ERE:
#
# Quantificator BRE ERE
#
# 1 or more  \+ +
# 0 or 1     \? ?
# {n,m} \{n,m\} {n,m}
# grouping   \(\) ()
# alternativă \| |
#
```

---

## PI-R5: Greedy Matching

```
┌─────────────────────────────────────────────────────────────────────────┐
│  PEER INSTRUCTION R5: How much does it match .*?                       │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  Text: <div>Hello</div><div>World</div>                                │
│                                                                         │
│  Command: grep -oE '<div>.*</div>'                                     │
│                                                                         │
│  What will it display?                                                           │
│                                                                         │
│  ┌───┐                                                                  │
│  │ 1 │ <div>Hello</div>                                                │
│  ├───┤                                                                  │
│  │ 2 │ <div>Hello</div><div>World</div>                                │
│  ├───┤                                                                  │
│  │ 3 │ <div>Hello</div>                                                │
│  │   │ <div>World</div>  (two lines)                                  │
│  ├───┤                                                                  │
│  │ 4 │ Hello                                                            │
│  │   │ World  (two lines)                                             │
│  └───┘                                                                  │
│                                                                         │
│  Difficulty: ⭐⭐⭐⭐ | Misconception: M1.5 (greedy by default)         │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

Correct answer: 2

Explanation:

```bash
# .* is GREEDY - takes AS MUCH AS POSSIBLE

echo '<div>Hello</div><div>World</div>' | grep -oE '<div>.*</div>'
# Output: <div>Hello</div><div>World</div>

# Why? .* "stretches" to the LAST </div>

# To get the MINIMUM (lazy), you need PCRE:
echo '<div>Hello</div><div>World</div>' | grep -oP '<div>.*?</div>'
# Output:
# <div>Hello</div>
# <div>World</div>

# Alternatively, without PCRE - avoid . for the wrong character:
echo '<div>Hello</div><div>World</div>' | grep -oE '<div>[^<]*</div>'
# [^<]* = anything except <, so stops at the first <
```

---

## PI-R6: Word Boundary

```
┌─────────────────────────────────────────────────────────────────────────┐
│  PEER INSTRUCTION R6: When to use \b?                            │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  The file contains:                                                     │
│     cat                                                                 │
│     category                                                            │
│     concatenate                                                         │
│     bobcat                                                              │
│                                                                         │
│  You want to find ONLY the line with the exact word "cat".                   │
│  What command do you use?                                                  │
│                                                                         │
│  ┌───┐                                                                  │
│  │ 1 │ grep 'cat' file.txt                                             │
│  ├───┤                                                                  │
│  │ 2 │ grep '^cat$' file.txt                                           │
│  ├───┤                                                                  │
│  │ 3 │ grep '\bcat\b' file.txt                                         │
│  ├───┤                                                                  │
│  │ 4 │ grep -w 'cat' file.txt                                          │
│  └───┘                                                                  │
│                                                                         │
│  BONUS: Which two options are equivalent?                            │
│                                                                         │
│  Difficulty: ⭐⭐ | Concept: Word boundaries                          │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

Correct answer: 3 și 4 (both work, and are equivalent)

Explanation:

```bash
# 1. grep 'cat' - finds ALL (cat, category, concatenate, bobcat)

# 2. grep '^cat$' - only if the LINE is exactly "cat"
# Works in this case, but would not find "the cat sat"

# 3. grep '\bcat\b' - word boundary = exact word
# \b = granița între word char (\w) și non-word char

# 4. grep -w 'cat' - echivalent cu \b...\b
# -w = --word-regexp

# 3 and 4 are EQUIVALENT and find "cat" as an independent word
```

---

# SECTION 2: GREP

## PI-G1: Output-ul lui grep -c

```
┌─────────────────────────────────────────────────────────────────────────┐
│  PEER INSTRUCTION G1: What does it count grep -c?                               │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  The file contains:                                                     │
│     error error error                                                   │
│     warning                                                             │
│     error                                                               │
│                                                                         │
│  Command: grep -c 'error' file.txt                                     │
│                                                                         │
│  Ce afișează?                                                           │
│                                                                         │
│  ┌───┐                                                                  │
│  │ 1 │ 4 (total occurrences of the word "error")                       │
│  ├───┤                                                                  │
│  │ 2 │ 2 (lines containing "error")                                   │
│  ├───┤                                                                  │
│  │ 3 │ 3 (total lines in file)                                       │
│  ├───┤                                                                  │
│  │ 4 │ 17 (characters in the word "error" × occurrences)                   │
│  └───┘                                                                  │
│                                                                         │
│  Difficulty: ⭐⭐ | Misconception: M2.5 (grep -c counts lines)        │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

Correct answer: 2

Explanation:

```bash
# grep -c counts LINES containing at least one match
# NU numără totalul de potriviri!

# Line 1: "error error error" - 1 line (with 3 occurrences)
# Line 2: "warning" - 0 (does not contain error)
# Line 3: "error" - 1 line

# Total: 2 lines

# To count ALL occurrences:
grep -o 'error' file.txt | wc -l
# Output: 4
```

---

## PI-G2: grep -o Behavior

```
┌─────────────────────────────────────────────────────────────────────────┐
│  PEER INSTRUCTION G2: What does it do -o?                                      │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  The file contains:                                                     │
│     IP: 192.168.1.100 connected from 10.0.0.50                        │
│                                                                         │
│  Command: grep -oE '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' file.txt          │
│                                                                         │
│  Ce afișează?                                                           │
│                                                                         │
│  ┌───┐                                                                  │
│  │ 1 │ IP: 192.168.1.100 connected from 10.0.0.50 (the entire line)    │
│  ├───┤                                                                  │
│  │ 2 │ 192.168.1.100                                                   │
│  │   │ 10.0.0.50  (on separate lines)                                  │
│  ├───┤                                                                  │
│  │ 3 │ 192.168.1.100 10.0.0.50 (on the same line)                      │
│  ├───┤                                                                  │
│  │ 4 │ 192.168.1.100 (only the first match)                            │
│  └───┘                                                                  │
│                                                                         │
│  Difficulty: ⭐⭐ | Misconception: M2.3 (behaviour -o)             │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

Correct answer: 2

Explanation:

```bash
# -o = only matching
# Displays ONLY the matching portion
# Each match on a separate line!

# Fără -o:
grep -E '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' file.txt
# Output: IP: 192.168.1.100 connected from 10.0.0.50

# Cu -o:
grep -oE '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' file.txt
# Output:
# 192.168.1.100
# 10.0.0.50

# This is very useful for extraction!
```

---

## PI-G3: grep recursiv

```
┌─────────────────────────────────────────────────────────────────────────┐
│  PEER INSTRUCTION G3: Search in subdirectories                         │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  Structure:                                                             │
│     project/                                                            │
│     ├── main.py (contains "TODO")                                       │
│     ├── lib/                                                            │
│     │   └── utils.py (contains "TODO")                                  │
│     └── tests/                                                          │
│         └── test_main.py (contains "TODO")                              │
│                                                                         │
│  Command: grep 'TODO' project/*.py                                     │
│                                                                         │
│  How many files does it find?                                                  │
│                                                                         │
│  ┌───┐                                                                  │
│  │ 1 │ 0 - wrong pattern                                              │
│  ├───┤                                                                  │
│  │ 2 │ 1 - only main.py                                                │
│  ├───┤                                                                  │
│  │ 3 │ 3 - all .py files                                         │
│  ├───┤                                                                  │
│  │ 4 │ Error - cannot access subdirectories                          │
│  └───┘                                                                  │
│                                                                         │
│  Difficulty: ⭐⭐ | Misconception: M2.4 (automatic recursive)            │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

Correct answer: 2

Explanation:

```bash
# project/*.py expands ONLY to files in project/
# NU intră în subdirectoare!

# Glob *.py = .py files in the CURRENT directory (or specified)

# For subdirectories, you need:
grep -r 'TODO' project/                    # All files
grep -r --include='*.py' 'TODO' project/   # Only .py, recursiv

# Or with find:
find project -name '*.py' -exec grep 'TODO' {} +
```

---

## PI-G4: Excluderea procesului grep

```
┌─────────────────────────────────────────────────────────────────────────┐
│  PEER INSTRUCTION G4: ps aux | grep                                    │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  You want to see if nginx is running.                                      │
│  Command: ps aux | grep nginx                                          │
│                                                                         │
│  Output:                                                                │
│     root  1234 ... nginx: master process                               │
│     root  5678 ... grep nginx                                          │
│                                                                         │
│  How can you avoid the line with "grep nginx"?                        │
│                                                                         │
│  ┌───┐                                                                  │
│  │ 1 │ ps aux | grep nginx | grep -v grep                              │
│  ├───┤                                                                  │
│  │ 2 │ ps aux | grep '[n]ginx'                                         │
│  ├───┤                                                                  │
│  │ 3 │ pgrep nginx                                                      │
│  ├───┤                                                                  │
│  │ 4 │ All of the above work                              │
│  └───┘                                                                  │
│                                                                         │
│  BONUS: Which is the most elegant?                                        │
│                                                                         │
│  Difficulty: ⭐⭐⭐ | Concept: Self-exclusion trick                    │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

Correct answer: 4

Explanation:

```bash
# 1. grep -v grep - funcționează, dar inelegant
ps aux | grep nginx | grep -v grep

# 2. [n]ginx - trucul clasic!
ps aux | grep '[n]ginx'
# The pattern [n]ginx matches "nginx"
# But the grep process has the command "grep [n]ginx"
# [n]ginx does NOT match "[n]ginx" - they are different!

# 3. pgrep - cel mai curat
pgrep nginx        # Only PID-uri
pgrep -a nginx     # With command line

# Most elegant: pgrep or the [n]ginx trick
```

---

## PI-G5: grep -l vs grep -L

```
┌─────────────────────────────────────────────────────────────────────────┐
│  PEER INSTRUCTION G5: Files with/without matches                        │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  Files:                                                               │
│     a.txt: "error occurred"                                            │
│     b.txt: "all good"                                                   │
│     c.txt: "error: fatal"                                              │
│                                                                         │
│  What does it display: grep -L 'error' *.txt                                    │
│                                                                         │
│  ┌───┐                                                                  │
│  │ 1 │ a.txt și c.txt (files WITH error)                             │
│  ├───┤                                                                  │
│  │ 2 │ b.txt (file WITHOUT error)                                     │
│  ├───┤                                                                  │
│  │ 3 │ List of all files with number of matches                  │
│  ├───┤                                                                  │
│  │ 4 │ Content of lines without "error"                                │
│  └───┘                                                                  │
│                                                                         │
│  Difficulty: ⭐⭐ | Misconception: M2.7                                │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

Correct answer: 2

Explanation:

```bash
# -l = files-with-matches
# Afișează numele fișierelor CARE CONȚIN pattern

# -L = files-without-match (opus!)
# Afișează numele fișierelor FĂRĂ pattern

grep -l 'error' *.txt   # a.txt, c.txt
grep -L 'error' *.txt   # b.txt

# Useful for finding files that do NOT have something:
grep -L 'copyright' *.py   # Files without copyright header
```

---

## PI-G6: Context Lines

```
┌─────────────────────────────────────────────────────────────────────────┐
│  PEER INSTRUCTION G6: -A, -B, -C                                       │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  Log file:                                                              │
│     Line 1: Starting service                                            │
│     Line 2: Loading config                                              │
│     Line 3: ERROR: Connection failed                                    │
│     Line 4: Retrying in 5 seconds                                       │
│     Line 5: Connected successfully                                      │
│                                                                         │
│  Command: grep -B 1 -A 1 'ERROR' log.txt                               │
│                                                                         │
│  Ce afișează?                                                           │
│                                                                         │
│  ┌───┐                                                                  │
│  │ 1 │ Only Line 3 (the line with ERROR)                                    │
│  ├───┤                                                                  │
│  │ 2 │ Line 2, Line 3, Line 4                                          │
│  ├───┤                                                                  │
│  │ 3 │ Line 1-5 (the entire file)                                         │
│  ├───┤                                                                  │
│  │ 4 │ Line 3, Line 4                                                   │
│  └───┘                                                                  │
│                                                                         │
│  Difficulty: ⭐ | Concept: Context lines                              │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

Correct answer: 2

Explanation:

```bash
# -B N = Before context (N lines BEFORE)
# -A N = After context (N lines AFTER)
# -C N = Context (N lines before AND after, equivalent to -B N -A N)

grep -B 1 -A 1 'ERROR' log.txt
# Line 2: Loading config (1 line before)
# Line 3: ERROR: Connection... (potrivirea)
# Line 4: Retrying... (1 line after)

# Very useful for debugging logs!
```

---

# SECTION 3: SED

## PI-S1: sed Output Destination

```
┌─────────────────────────────────────────────────────────────────────────┐
│  PEER INSTRUCTION S1: Where does sed write?                                  │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  File config.txt contains: server=localhost                         │
│                                                                         │
│  Command: sed 's/localhost/127.0.0.1/' config.txt                      │
│                                                                         │
│  After execution, config.txt contains:                                    │
│                                                                         │
│  ┌───┐                                                                  │
│  │ 1 │ server=127.0.0.1 (modified)                                    │
│  ├───┤                                                                  │
│  │ 2 │ server=localhost (nemodified)                                  │
│  ├───┤                                                                  │
│  │ 3 │ Both versions (append)                                        │
│  ├───┤                                                                  │
│  │ 4 │ Empty file                                                       │
│  └───┘                                                                  │
│                                                                         │
│  Difficulty: ⭐⭐⭐ | Misconception: M3.1 (sed modifies directly)       │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

Correct answer: 2

Explanation:

```bash
# sed by default writes to STDOUT, does not modify the file!

sed 's/localhost/127.0.0.1/' config.txt
# Afișează "server=127.0.0.1" pe ecran
# config.txt rămâne NEMODIFICAT

# To modify the file:
sed -i 's/localhost/127.0.0.1/' config.txt   # In-place (periculos!)
sed -i.bak 's/localhost/127.0.0.1/' config.txt   # Cu backup

# Or redirect:
sed 's/localhost/127.0.0.1/' config.txt > config_new.txt
```

---

## PI-S2: Global Flag

```
┌─────────────────────────────────────────────────────────────────────────┐
│  PEER INSTRUCTION S2: How many does it replace without /g?                        │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  Input: echo "cat cat cat" | sed 's/cat/dog/'                          │
│                                                                         │
│  Output?                                                                │
│                                                                         │
│  ┌───┐                                                                  │
│  │ 1 │ dog dog dog                                                      │
│  ├───┤                                                                  │
│  │ 2 │ dog cat cat                                                      │
│  ├───┤                                                                  │
│  │ 3 │ cat cat dog                                                      │
│  ├───┤                                                                  │
│  │ 4 │ cat dog cat                                                      │
│  └───┘                                                                  │
│                                                                         │
│  Difficulty: ⭐⭐⭐ | Misconception: M3.2 (s/// înlocuiește all)    │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

Correct answer: 2

Explanation:

```bash
# Without the /g flag, sed replaces only the FIRST occurrence per line

echo "cat cat cat" | sed 's/cat/dog/'
# Output: dog cat cat

echo "cat cat cat" | sed 's/cat/dog/g'
# Output: dog dog dog

# Alte flags utile:
# /2 = a doua apariție
# /3g = de la a treia apariție încolo

echo "cat cat cat cat" | sed 's/cat/dog/2'
# Output: cat dog cat cat

echo "cat cat cat cat" | sed 's/cat/dog/2g'
# Output: cat dog dog dog
```

---

## PI-S3: Delimitator Alternativ

```
┌─────────────────────────────────────────────────────────────────────────┐
│  PEER INSTRUCTION S3: Path replacement                                   │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  You want to replace /usr/local cu /opt                                │
│                                                                         │
│  Which command is CORRECT?                                               │
│                                                                         │
│  ┌───┐                                                                  │
│  │ 1 │ sed 's//usr/local//opt/' file.txt                               │
│  ├───┤                                                                  │
│  │ 2 │ sed 's|/usr/local|/opt|' file.txt                               │
│  ├───┤                                                                  │
│  │ 3 │ sed 's/\/usr\/local/\/opt/' file.txt                            │
│  ├───┤                                                                  │
│  │ 4 │ Options .* are both correct                            │
│  └───┘                                                                  │
│                                                                         │
│  Difficulty: ⭐⭐ | Misconception: M3.4 (fixed delimiter)               │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

Correct answer: 4

Explanation:

```bash
# 1. WRONG - too many /
sed 's//usr/local//opt/' file.txt  # Syntax error

# 2. CORECT - delimiter alternativ |
sed 's|/usr/local|/opt|' file.txt

# 3. CORRECT - escape for /
sed 's/\/usr\/local/\/opt/' file.txt

# Alte delimitatori acceptați: # @ : ! etc.
sed 's#/usr/local#/opt#' file.txt
sed 's@/usr/local@/opt@' file.txt

# Recommendation: Use | or # when you have / in the pattern
```

---

## PI-S4: & în Replacement

```
┌─────────────────────────────────────────────────────────────────────────┐
│  PEER INSTRUCTION S4: What does it do &?                                       │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  Input: echo "port=8080" | sed 's/[0-9]*/[&]/'                         │
│                                                                         │
│  Output?                                                                │
│                                                                         │
│  ┌───┐                                                                  │
│  │ 1 │ port=[8080]                                                      │
│  ├───┤                                                                  │
│  │ 2 │ [port=8080]                                                      │
│  ├───┤                                                                  │
│  │ 3 │ port=8080 (nemodified, & e literal is literal)                            │
│  ├───┤                                                                  │
│  │ 4 │ []port=8080                                                      │
│  └───┘                                                                  │
│                                                                         │
│  Difficulty: ⭐⭐⭐ | Misconception: M3.5 (& ca literal)              │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

Correct answer: 4

Explanation:

```bash
# & în replacement = ÎNTREGUL MATCH

echo "port=8080" | sed 's/[0-9]*/[&]/'

# [0-9]* = zero or more digits
# First match is at the beginning of the string: ZERO digits (empty string!)
# & = "" (string gol)
# Output: []port=8080

# To match the number:
echo "port=8080" | sed 's/[0-9][0-9]*/[&]/'   # Minim 1 cifră
# Output: port=[8080]

# Or with ERE:
echo "port=8080" | sed -E 's/[0-9]+/[&]/'
# Output: port=[8080]

# LECȚIE: * permite zero repetări! + cere minim una.
```

---

## PI-S5: Adresare cu Pattern

```
┌─────────────────────────────────────────────────────────────────────────┐
│  PEER INSTRUCTION S5: Selective substitution                            │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  The file contains:                                                     │
│     # Comment line                                                      │
│     server=localhost                                                    │
│     # Another comment                                                   │
│     port=8080                                                           │
│                                                                         │
│  Command: sed '/^#/!s/=/ = /' file.txt                                 │
│                                                                         │
│  What does it do?                                                               │
│                                                                         │
│  ┌───┐                                                                  │
│  │ 1 │ Adds spaces around = on lines with #                        │
│  ├───┤                                                                  │
│  │ 2 │ Adds spaces around = on lines WITHOUT #                      │
│  ├───┤                                                                  │
│  │ 3 │ Deletes lines with #                                              │
│  ├───┤                                                                  │
│  │ 4 │ Syntax error                                               │
│  └───┘                                                                  │
│                                                                         │
│  Difficulty: ⭐⭐ | Concept: Address negation                          │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

Correct answer: 2

Explanation:

```bash
# /pattern/! = negation = lines that do NOT match the pattern

sed '/^#/!s/=/ = /' file.txt
# /^#/ = lines that start with #
# ! = NEGATION - lines that do NOT start with #
# s/=/ = / = înlocuiește = cu " = "

# Output:
# # Comment line (unmodified - is a comment)
# server = localhost (modified)
# # Another comment (unmodified - is a comment)
# port = 8080 (modified)

# Echivalent:
sed '/^[^#]/s/=/ = /' file.txt   # Lines that do NOT start with #
```

---

## PI-S6: sed -i Safety

```
┌─────────────────────────────────────────────────────────────────────────┐
│  PEER INSTRUCTION S6: Backup with -i                                     │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  You have the file .* and want to make a modification.             │
│                                                                         │
│  Which command is THE SAFEST?                                        │
│                                                                         │
│  ┌───┐                                                                  │
│  │ 1 │ sed -i 's/old/new/' important.conf                              │
│  ├───┤                                                                  │
│  │ 2 │ sed 's/old/new/' important.conf > important.conf                │
│  ├───┤                                                                  │
│  │ 3 │ sed -i.bak 's/old/new/' important.conf                          │
│  ├───┤                                                                  │
│  │ 4 │ sed 's/old/new/' important.conf > temp && mv temp important.conf│
│  └───┘                                                                  │
│                                                                         │
│  Difficulty: ⭐⭐⭐ | Misconception: M3.3 (sed -i safe)               │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

Correct answer: 3

Explanation:

```bash
# 1. PERICULOS - fără backup
sed -i 's/old/new/' important.conf
# If the command is wrong, you have lost the original!

# 2. DISASTER - redirect to the same file
sed 's/old/new/' important.conf > important.conf
# Shell empties the file BEFORE running sed!
# Result: EMPTY file!

# 3. SIGUR - cu backup automat
sed -i.bak 's/old/new/' important.conf
# Creează important.conf.bak cu originalul

# 4. SIGUR - manual cu temp file
sed 's/old/new/' important.conf > temp && mv temp important.conf
# Funcționează, dar mai complicat

# RECOMMENDATION: Always use -i.bak or test without -i first
```

---

# SECTION 4: AWK

## PI-A1: $0 vs $1

```
┌─────────────────────────────────────────────────────────────────────────┐
│  PEER INSTRUCTION A1: What does it contain $0?                                   │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  Input: echo "John Smith 30" | awk '{print $0}'                        │
│                                                                         │
│  Output?                                                                │
│                                                                         │
│  ┌───┐                                                                  │
│  │ 1 │ (nothing - $0 is undefined)                                        │
│  ├───┤                                                                  │
│  │ 2 │ John (first field)                                              │
│  ├───┤                                                                  │
│  │ 3 │ John Smith 30 (the entire line)                                  │
│  ├───┤                                                                  │
│  │ 4 │ 0 (numeric value)                                           │
│  └───┘                                                                  │
│                                                                         │
│  Difficulty: ⭐⭐⭐ | Misconception: M4.1 ($0 = first field)          │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

Correct answer: 3

Explanation:

```bash
# $0 = ENTIRE LINE (complete record)
# $1 = Primul câmp
# $2 = Al doilea câmp
# $NF = Last field

echo "John Smith 30" | awk '{print $0}'   # John Smith 30
echo "John Smith 30" | awk '{print $1}'   # John
echo "John Smith 30" | awk '{print $2}'   # Smith
echo "John Smith 30" | awk '{print $3}'   # 30
echo "John Smith 30" | awk '{print $NF}'  # 30 (the last)

# Numerotarea începe de la 1, nu de la 0!
```

---

## PI-A2: Print cu/fără virgulă

```
┌─────────────────────────────────────────────────────────────────────────┐
│  PEER INSTRUCTION A2: Space or not?                                   │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  Commands:                                                               │
│     A) echo "a b" | awk '{print $1 $2}'                                │
│     B) echo "a b" | awk '{print $1, $2}'                               │
│                                                                         │
│  Care afișează "a b" (cu spațiu între)?                                │
│                                                                         │
│  ┌───┐                                                                  │
│  │ 1 │ Only A                                                           │
│  ├───┤                                                                  │
│  │ 2 │ Only B                                                           │
│  ├───┤                                                                  │
│  │ 3 │ Both                                                           │
│  ├───┤                                                                  │
│  │ 4 │ Neither                                                          │
│  └───┘                                                                  │
│                                                                         │
│  Difficulty: ⭐⭐⭐ | Misconception: M4.3 (print concatenation)         │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

Correct answer: 2

Explanation:

```bash
# FĂRĂ virgulă = concatenare directă
echo "a b" | awk '{print $1 $2}'
# Output: ab (LIPITE!)

# WITH comma = separated by OFS (default: space)
echo "a b" | awk '{print $1, $2}'
# Output: a b (cu spațiu)

# Poți schimba OFS:
echo "a b" | awk 'BEGIN{OFS=":"} {print $1, $2}'
# Output: a:b

# REGULA: Virgula în print = inserează OFS
```

---

## PI-A3: NR vs FNR

```
┌─────────────────────────────────────────────────────────────────────────┐
│  PEER INSTRUCTION A3: Multiple Files                                   │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  file1.txt: line1                                                       │
│  file2.txt: lineA                                                       │
│             lineB                                                       │
│                                                                         │
│  Command: awk '{print NR, FNR}' file1.txt file2.txt                    │
│                                                                         │
│  Output?                                                                │
│                                                                         │
│  ┌───┐                                                                  │
│  │ 1 │ 1 1                                                              │
│  │   │ 1 1                                                              │
│  │   │ 2 2                                                              │
│  ├───┤                                                                  │
│  │ 2 │ 1 1                                                              │
│  │   │ 2 1                                                              │
│  │   │ 3 2                                                              │
│  ├───┤                                                                  │
│  │ 3 │ 1 1                                                              │
│  │   │ 2 2                                                              │
│  │   │ 3 3                                                              │
│  ├───┤                                                                  │
│  │ 4 │ Error - awk does not accept multiple files                        │
│  └───┘                                                                  │
│                                                                         │
│  Difficulty: ⭐⭐⭐⭐ | Misconception: M4.4 (NR = FNR)                │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

Correct answer: 2

Explanation:

```bash
# NR = Number of Records (GLOBAL, crește continuu)
# FNR = File Number of Records (resets for each file)

awk '{print NR, FNR}' file1.txt file2.txt
# Output:
# 1 1 (file1.txt, line 1)
# 2 1 (file2.txt, line 1 - FNR reset!)
# 3 2 (file2.txt, line 2)

# Useful for detecting the first file:
awk 'NR==FNR { ... }' file1.txt file2.txt
# The condition NR==FNR is TRUE only for the first file
```

---

## PI-A4: Skip Header

```
┌─────────────────────────────────────────────────────────────────────────┐
│  PEER INSTRUCTION A4: CSV processing without header                        │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  employees.csv:                                                         │
│     Name,Salary                                                         │
│     John,5000                                                           │
│     Maria,6000                                                          │
│                                                                         │
│  You want the sum of salaries (without header). Which is CORRECT?                   │
│                                                                         │
│  ┌───┐                                                                  │
│  │ 1 │ awk -F',' '{sum+=$2} END{print sum}'                            │
│  ├───┤                                                                  │
│  │ 2 │ awk -F',' 'NR>1 {sum+=$2} END{print sum}'                       │
│  ├───┤                                                                  │
│  │ 3 │ awk -F',' 'NR!=1 {sum+=$2} END{print sum}'                      │
│  ├───┤                                                                  │
│  │ 4 │ Options .* are correct                                   │
│  └───┘                                                                  │
│                                                                         │
│  Difficulty: ⭐⭐ | Concept: Skipping header                          │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

Correct answer: 4

Explanation:

```bash
# 1. WRONG - includes the header
awk -F',' '{sum+=$2} END{print sum}' employees.csv
# $2 on line 1 = "Salary" (text), awk converts to 0
# But adds 0, so the result is correct... ACCIDENTALLY!
# On real data, may cause warnings or errors.

# 2. CORRECT - NR>1 skips the first line
awk -F',' 'NR>1 {sum+=$2} END{print sum}' employees.csv
# Output: 11000

# 3. CORRECT - NR!=1 is equivalent to NR>1 (for the first line)
awk -F',' 'NR!=1 {sum+=$2} END{print sum}' employees.csv
# Output: 11000

# BONUS: FNR==1 for header in each file (multiple)
```

---

## PI-A5: Arrays în AWK

```
┌─────────────────────────────────────────────────────────────────────────┐
│  PEER INSTRUCTION A5: Category counting                               │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  data.txt:                                                              │
│     IT                                                                  │
│     HR                                                                  │
│     IT                                                                  │
│     IT                                                                  │
│                                                                         │
│  Command: awk '{count[$1]++} END{print count["IT"]}'                   │
│                                                                         │
│  Output?                                                                │
│                                                                         │
│  ┌───┐                                                                  │
│  │ 1 │ 3                                                                │
│  ├───┤                                                                  │
│  │ 2 │ IT IT IT                                                         │
│  ├───┤                                                                  │
│  │ 3 │ 0 (arrays must be declared)                                    │
│  ├───┤                                                                  │
│  │ 4 │ Error - invalid syntax                                         │
│  └───┘                                                                  │
│                                                                         │
│  Difficulty: ⭐⭐⭐ | Misconception: M4.7 (variable declaration)       │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

Correct answer: 1

Explanation:

```bash
# In AWK, variables do NOT need to be declared
# Se inițializează automat: numere la 0, stringuri la ""

# count[$1]++ :
# - count is an associative array (hash)
# - $1 is the key
# - ++ increments the value

# On first occurrence of "IT": count["IT"] = 0, then becomes 1
# La a doua: count["IT"] = 1, apoi devine 2
# La a treia: count["IT"] = 2, apoi devine 3

# END{print count["IT"]} afișează 3

# To see all categories:
awk '{count[$1]++} END{for(k in count) print k, count[k]}' data.txt
# Output:
# IT 3
# HR 1
```

---

## PI-A6: printf Formatting

```
┌─────────────────────────────────────────────────────────────────────────┐
│  PEER INSTRUCTION A6: Output formatting                                 │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  Command: awk 'BEGIN{printf "%-10s %5d\n", "Test", 42}'                │
│                                                                         │
│  Output? (. = spațiu)                                                   │
│                                                                         │
│  ┌───┐                                                                  │
│  │ 1 │ Test......42                                                     │
│  ├───┤                                                                  │
│  │ 2 │ Test.........42                                                  │
│  ├───┤                                                                  │
│  │ 3 │ ......Test...42                                                  │
│  ├───┤                                                                  │
│  │ 4 │ Test           42 (14 spaces between)                             │
│  └───┘                                                                  │
│                                                                         │
│  Difficulty: ⭐⭐ | Concept: printf alignment                         │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

Correct answer: 1

Explanation:

```bash
# printf formatters:
# %-10s = string, 10 characters, aligned LEFT (due to -)
# %5d = integer, 5 characters, aligned RIGHT (default)

# "Test" has 4 characters, %-10s adds 6 spaces after
# 42 has 2 characters, %5d adds 3 spaces before

# Result: "Test " + " 42" = "Test 42"
# (6 spații după Test, 3 înainte de 42)

# Vizualizare:
# T e s t . . . . . . . . 4 2
# |___10 chars_____| |_5_|

# Output real:
awk 'BEGIN{printf "%-10s %5d\n", "Test", 42}'
# Test 42
```

---

## Statistics and Usage

### Distribuție pe Difficulty

| Level | Number | Percentage |
|-------|-------|---------|
| ⭐ | 1 | 4% |
| ⭐⭐ | 10 | 42% |
| ⭐⭐⭐ | 11 | 46% |
| ⭐⭐⭐⭐ | 2 | 8% |

### Mapping to Misconceptions

| Misconcepție | Targeted Questions |
|--------------|-------------------|
| M1.1 - * în glob vs regex | PI-R1, PI-R2 |
| M1.3 - BRE vs ERE | PI-R4 |
| M1.4 - ^ context | PI-R3 |
| M1.5 - greedy matching | PI-R5 |
| M2.3 - grep -o | PI-G2 |
| M2.4 - automatic recursive | PI-G3 |
| M2.5 - grep -c | PI-G1 |
| M3.1 - sed modifies directly | PI-S1 |
| M3.2 - s/// all | PI-S2 |
| M3.5 - & literal | PI-S4 |
| M4.1 - $0 vs $1 | PI-A1 |
| M4.3 - print concat | PI-A2 |
| M4.4 - NR vs FNR | PI-A3 |

---

*Peer Instruction for Seminar 4 of Operating Systems | Bucharest University of Economic Studies - CSIE*
