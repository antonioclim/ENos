# Live Coding Guide: Text Processing
## Guide for Interactive Demonstrations - Regex, GREP, SED, AWK

> Operating Systems | Bucharest University of Economic Studies - CSIE  
> Seminar 4 | Live Coding Sessions  
> Sessions: 5 | Total time: ~50 minutes

---

## Live Coding Principles

### Why Live Coding?

Live coding is one of the most effective methods for teaching programming:

1. Models the thinking process - students see HOW an expert thinks
2. Normalises mistakes - shows that even experts make errors
3. Allows real-time questions - immediate clarifications
4. Demonstrates debugging - an essential skill

### Golden Rules

```
┌─────────────────────────────────────────────────────────────────────────┐
│  🎯 LIVE CODING RULES                                                  │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  1. PREDICTION - Ask "What do you think it will display?" BEFORE Enter │
│                                                                         │
│  2. DELIBERATE ERRORS - Include 2-3 planned mistakes per session       │
│                                                                         │
│  3. EXPLANATION - Verbalise EVERYTHING you type                        │
│                                                                         │
│  4. PAUSES - Stop after each command for questions                     │
│                                                                         │
│  5. VISIBILITY - Large font (16pt+), clean terminal                    │

> 💡 I have had students who learnt Bash in two weeks starting from zero — so it is possible, with consistent practice.

│                                                                         │
│  6. PROGRESSIVE - From simple to complex, never the reverse            │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

### Pre-Session Preparation

```bash
# Verify that sample data exists
ls ~/demo_sem4/data/

# Clear the terminal
clear

# Set short prompt for visibility
export PS1='$ '

# Increase font (in terminal preferences)
```

---

# SESSION 1: REGEX FUNDAMENTALS (10 min)

## Setup

```bash
cd ~/demo_sem4/data
cat test.txt   # Show contents
```

## Segment 1.1: The `.` Metacharacter (3 min)

### Script

[SAY]: "Let us see what the dot does in regex. I have here a file with various words."

```bash
cat test.txt
```

[SAY]: "Now I want to find the pattern 'a.c'. PREDICTION: What do you think it will find?"

[PAUSE for answers]

```bash
grep 'a.c' test.txt
```

[SAY]: "We see abc, a1c, aXc. But why does 'ac' not appear?"

[EXPLANATION]: "The dot means EXACTLY ONE character - any character, but it must exist. 'ac' has nothing between a and c."

### Deliberate Error #1

[SAY]: "Now I want to search for an IP. Let me try..."

```bash
grep '192.168.1.1' test.txt
```

[SAY]: "Found it! But... let me create a test file:"

```bash
echo "192X168Y1Z1" >> test.txt
grep '192.168.1.1' test.txt

*(`grep` is probably the command I use most frequently. Simple, fast, efficient.)*

```

[SURPRISE]: "It found that too! Why?"

[EXPLANATION]: "The dot matches ANY character. We need to escape it:"

```bash
grep '192\.168\.1\.1' test.txt
```

[CONCLUSION]: "The lesson: when searching for literal text with dots, escape them with backslash!"

---

## Segment 1.2: Anchors ^ and $ (3 min)

### Script

[SAY]: "Now let us see the anchors. ^ means 'beginning of line'."

```bash
# Preparation
echo -e "Start here\nNot Start\nStarting now" > anchors.txt
cat anchors.txt
```

[PREDICTION]: "What will `grep '^Start'` find?"

```bash
grep '^Start' anchors.txt
```

[SAY]: "Only lines that START with 'Start'. Now $..."

```bash
echo -e "The end\nendless\nMy friend" > endings.txt
grep 'end$' endings.txt
```

[SAY]: "Only 'The end' - the only one that ENDS with 'end'."

### Useful Combination

[SAY]: "What do you think `^$` does?"

```bash
grep '^$' config.txt
```

[EXPLANATION]: "Empty lines! Beginning immediately followed by end = nothing on line."

---

## Segment 1.3: Character Classes (2 min)

### Script

```bash
# Simple set
grep '[0-9]' test.txt          # Lines with digits
grep '[A-Z]' test.txt          # Lines with uppercase
```

### Deliberate Error #2 - Negation

[SAY]: "Now I want lines WITHOUT digits. Let me try..."

```bash
grep '[^0-9]' test.txt    # WRONG!
```

[SURPRISE]: "It found ALL lines! Why?"

[EXPLANATION]: "[^0-9] means 'a character that IS NOT a digit'. Almost all lines have at least one non-digit."

[CORRECT]:
```bash
grep -v '[0-9]' test.txt   # Invert - lines WITHOUT any digit
```

[CONCLUSION]: "Attention! ^ in [] is negation for SET, not for line!"

---

## Segment 1.4: Quantifiers BRE vs ERE (2 min)

### Script

[SAY]: "If you remember only one idea today..."

### Deliberate Error #3 - BRE vs ERE

```bash
echo -e "ac\nabc\nabbc\nabbbc" > quant.txt
grep 'ab+c' quant.txt
```

[SURPRISE]: "Nothing! But I have 'abc', 'abbc'... Why?"

[EXPLANATION]: "In BRE (Basic Regular Expression), + is LITERAL! It searches for 'ab+c' exactly."

[SOLUTIONS]:
```bash
# Solution 1: ERE with -E
grep -E 'ab+c' quant.txt

# Solution 2: Escape in BRE
grep 'ab\+c' quant.txt
```

[RULE]: "ALWAYS use `grep -E` when you need +, ?, |, {} without escape!"

---

# SESSION 2: GREP IN DEPTH (15 min)

## Setup

```bash
cd ~/demo_sem4/data
head access.log    # Show structure
```

## Segment 2.1: Essential Options (8 min)

### -i: Case Insensitive

```bash
grep 'get' access.log | head -3
grep -i 'get' access.log | head -3

*Personal note: `grep` is probably the command I use most frequently. Simple, fast, efficient.*

```

[EXPLANATION]: "-i ignores the difference between uppercase and lowercase"

### -v: Inversion

```bash
# Comments from config
grep '^#' config.txt

# Everything that IS NOT a comment
grep -v '^#' config.txt
```

### -n: Line Numbers

```bash
grep -n 'ERROR\|error' access.log 2>/dev/null || \
grep -n '403' access.log
```

[UTILITY]: "Essential for debugging - you know exactly where the problem is!"

### -c: Counting

[PREDICTION]: "`grep -c 'GET' access.log` - what does it count?"

```bash
grep -c 'GET' access.log
```

### Deliberate Error #4

[SAY]: "How many GET requests are there in total?"

```bash
# The line has 3 GETs: GET GET GET
echo "GET GET GET" >> access.log
grep -c 'GET' access.log    # Counts LINES, not occurrences!
```

[CORRECT]:
```bash
grep -o 'GET' access.log | wc -l   # Counts each occurrence
```

### -o: Match Only

```bash
# Extract ONLY the IPs
grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' access.log | head
```

[SUPER USEFUL]: "Combined with sort | uniq -c, we can create statistics!"

```bash
grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' access.log | sort | uniq -c | sort -rn | head -5
```

---

## Segment 2.2: Useful Patterns (5 min)

### Emails

```bash
cat emails.txt
grep -oE '[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}' emails.txt
```

### IP Addresses

```bash
grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' access.log | sort -u
```

### HTTP Codes

```bash
# Only errors (4xx, 5xx)
grep -E '" [45][0-9]{2} ' access.log
```

---

## Segment 2.3: Recursive and Context (2 min)

```bash
# Recursive (create test structure)
mkdir -p test_proj/{src,lib}
echo "def hello(): TODO fix" > test_proj/src/main.py
echo "def util(): TODO cleanup" > test_proj/lib/utils.py

grep -rn 'TODO' test_proj/
grep -rn --include='*.py' 'TODO' test_proj/
```

### Context

```bash
# Find error with context
grep -B 2 -A 2 '403' access.log | head -15
```

---

# SESSION 3: SED TRANSFORMATIONS (15 min)

## Setup

```bash
cd ~/demo_sem4/data
cat config.txt
```

## Segment 3.1: Basic Substitution (5 min)

### First Occurrence

```bash
echo "cat cat cat" | sed 's/cat/dog/'
```

[PREDICTION]: "How many 'cat' will be replaced?"

### Deliberate Error #5

[SAY]: "I want to replace ALL occurrences..."

```bash
echo "cat cat cat" | sed 's/cat/dog/'   # Only the first!
```

[FIX]:
```bash
echo "cat cat cat" | sed 's/cat/dog/g'   # With /g
```

### Global

```bash
sed 's/localhost/127.0.0.1/g' config.txt
```

**[ATTENTION]**: "The output is on screen. The file is UNMODIFIED!"

```bash
cat config.txt   # Confirm it is unchanged
```

---

## Segment 3.2: In-Place Editing (3 min)

### Safe Demo

```bash
cp config.txt config_test.txt

# DANGEROUS (without backup)
# sed -i 's/localhost/127.0.0.1/' config_test.txt

# SAFE (with backup)
sed -i.bak 's/localhost/127.0.0.1/' config_test.txt
ls config_test.*
cat config_test.bak   # Original preserved!
```

### Deliberate Error #6 - Disastrous Redirect

[SAY]: "Some try to redirect into the same file..."

```bash
echo "test content" > disaster.txt
cat disaster.txt
# DO NOT RUN THIS ON REAL FILES:
# sed 's/test/new/' disaster.txt > disaster.txt
# Would result in EMPTY file!
```

[EXPLANATION]: "The shell empties the output file BEFORE running the command!"

---

## Segment 3.3: Addressing (4 min)

### Line Number

```bash
sed '1d' config.txt            # Delete first line
sed '1,5d' config.txt          # Delete lines 1-5
sed '$d' config.txt            # Delete last line
```

### Pattern

```bash
sed '/^#/d' config.txt         # Delete comments
sed '/^$/d' config.txt         # Delete empty lines
sed '/^#/d; /^$/d' config.txt  # Both
```

### Selective

```bash
# Modify only on lines with "port"
sed '/port/s/=/ = /' config.txt
```

---

## Segment 3.4: Backreferences and & (3 min)

### & = The Entire Match

```bash
echo "port=8080" | sed 's/[0-9]\+/[&]/'
```

[PREDICTION]: "What will it display?"

### Deliberate Error #7

Output: `[]port=8080` (not `port=[8080]`)

[EXPLANATION]: "`[0-9]*` matches ZERO digits too! The first match is at the beginning = empty string."

[FIX]:
```bash
echo "port=8080" | sed 's/[0-9][0-9]*/[&]/'   # Minimum 1 digit
echo "port=8080" | sed -E 's/[0-9]+/[&]/'     # With ERE
```

### Backreferences

```bash
echo "John Smith" | sed 's/\([A-Za-z]*\) \([A-Za-z]*\)/\2, \1/'
# Output: Smith, John
```

---

# SESSION 4: AWK PROCESSING (15 min)

## Setup

```bash
cd ~/demo_sem4/data
cat employees.csv
```

## Segment 4.1: Fields (5 min)

### Basics

```bash
# Understanding structure
head -3 employees.csv

# First field (ID)
awk -F',' '{ print $1 }' employees.csv

# Name (column 2)
awk -F',' '{ print $2 }' employees.csv

# Last field
awk -F',' '{ print $NF }' employees.csv
```

### $0 vs $1

```bash
echo "John Smith 30" | awk '{ print $0 }'   # The entire line
echo "John Smith 30" | awk '{ print $1 }'   # John
```

### Deliberate Error #8 - Comma

```bash
# WITHOUT comma = concatenation
awk -F',' '{ print $2 $3 }' employees.csv | head -3
# JohnSmithIT

# WITH comma = space (OFS)
awk -F',' '{ print $2, $3 }' employees.csv | head -3
# John Smith IT
```

---

## Segment 4.2: Filtering and Calculations (5 min)

### Skip Header

```bash
awk -F',' 'NR > 1 { print $2 }' employees.csv
```

### Conditions

```bash
# Only IT
awk -F',' '$3 == "IT"' employees.csv

# Salary > 5500
awk -F',' '$4 > 5500' employees.csv
```

### Calculations

```bash
# Total salaries
awk -F',' 'NR > 1 { sum += $4 } END { print "Total:", sum }' employees.csv

# Average
awk -F',' 'NR > 1 { sum += $4; count++ } END { print "Average:", sum/count }' employees.csv
```

---

## Segment 4.3: Arrays and Reports (5 min)

### Counting per Category

```bash
awk -F',' 'NR > 1 { count[$3]++ } 
           END { for (dept in count) print dept, count[dept] }' employees.csv
```

### Formatting

```bash
awk -F',' '
    BEGIN { printf "%-15s %10s\n", "Dept", "Employees" }
    NR > 1 { count[$3]++ }
    END { 
        for (dept in count) 
            printf "%-15s %10d\n", dept, count[dept] 
    }' employees.csv
```

### Deliberate Error #9 - NR vs FNR

[SAY]: "What happens with multiple files?"

```bash
echo -e "A\nB" > f1.txt
echo -e "X\nY\nZ" > f2.txt

awk '{ print FILENAME, NR, FNR }' f1.txt f2.txt
```

[EXPLANATION]: "NR continues to grow, FNR resets per file!"

---

# SESSION 5: NANO QUICK INTRO (5 min)

## Quick Demo

```bash
nano /tmp/demo_script.sh
```

[ON SCREEN]: Show the footer with commands

### Essential Commands

1. Write a few lines:
```bash
#!/bin/bash
echo "Hello from nano!"
```

2. CTRL+O - Save (Write Out)
   - Confirm the name with Enter

3. CTRL+W - Search
   - Search for "echo"

4. CTRL+K - Cut line

5. CTRL+U - Paste

6. CTRL+X - Exit

### Final Message

[SAY]: "Nano is simple because ALL commands are visible at the bottom. You do not need to memorise anything - just look there!"

---

## Deliberate Errors Summary

| # | Session | Error | Lesson |
|---|---------|-------|--------|
| 1 | Regex | `.` not escaped for IP | Escape special characters |
| 2 | Regex | `[^0-9]` confused with "without digits" | ^ in [] = SET negation |
| 3 | Regex | `+` in BRE | BRE vs ERE |
| 4 | grep | `-c` counts lines, not occurrences | Use `-o | wc -l` |
| 5 | sed | Without `/g` | Global flag required |
| 6 | sed | Redirect into same file | Use `-i.bak` |
| 7 | sed | `[0-9]*` matches zero | Minimum `[0-9][0-9]*` or `+` |
| 8 | awk | Print without comma | Concatenation vs OFS |
| 9 | awk | NR vs FNR | Behaviour with multiple files |

---

## Pre-Seminar Checklist

```
□ Sample data created in ~/demo_sem4/data/
□ Terminal with large font (16pt+)
□ Short PS1 for visibility
□ Demo scripts tested
□ Notes with deliberate errors at hand
□ Cheat sheet prepared for sharing
□ Browser with regex101.com open
```

---

## Quick Notes Template

```
SESSION 1: Regex (10 min)
├── . = one character (escape: \.)
├── ^ = beginning of line, [^x] = set negation
├── $ = end of line
└── BRE vs ERE: + ? | {} () require -E or escape

SESSION 2: GREP (15 min)
├── -i -v -n -c -o = essential options
├── -E for ERE
├── -r for recursive
└── -A -B -C for context

SESSION 3: SED (15 min)
├── s/old/new/g = global
├── -i.bak = safe in-place
├── /pattern/d = delete
└── & and \1 = backreferences

SESSION 4: AWK (15 min)
├── $0 = line, $1 = first field
├── -F',' for CSV
├── NR > 1 skip header
└── count[$1]++ for arrays

SESSION 5: Nano (5 min)
├── ^O = save, ^X = exit
├── ^W = search, ^K = cut
└── Commands are visible in footer
```

---

*Live Coding Guide for Operating Systems Seminar 4 | ASE Bucharest - CSIE*
