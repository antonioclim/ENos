# Instructor Guide: Seminar 4
## Operating Systems | Text Processing - Regex, GREP, SED, AWK

*Personal note: Between `sed` and `awk`, I use `sed` for simple replacements and `awk` when I need logic. Each has its place.*


> Document for instructors  
> Total duration: 100 minutes (2 × 50 min + break)  
> Seminar type: Text Processing - Power Tools  
> Level: Intermediate-Advanced

---

## Table of Contents

1. [Session Objectives](#-session-objectives)
2. [Special Warnings](#️-special-warnings)
3. [Pre-Seminar Preparation](#-pre-seminar-preparation)
4. [First Part Timeline (50 min)](#️-detailed-timeline---first-part-50-min)
5. [Break](#-break-10-minutes)
6. [Second Part Timeline (50 min)](#️-detailed-timeline---second-part-50-min)
7. [Common Troubleshooting](#-common-troubleshooting)
8. [Additional Materials](#-additional-materials)

---

## SESSION OBJECTIVES

Upon completion of the seminar, students will be able to:

| # | Objective | Verification | Bloom Level |
|---|-----------|--------------|-------------|
| O1 | Write functional BRE and ERE regular expressions | Quiz + Sprint | Application |
| O2 | Use grep with the main options | Sprint G1 | Application |
| O3 | Transform text with sed (substitution, deletion) | Sprint S1 | Application |
| O4 | Process structured data with awk | Mini-sprint | Application |
| O5 | Edit files with nano | Demonstration | Knowledge |
| O6 | Combine tools in pipelines | Final exercise | Synthesis |

---

## SPECIAL WARNINGS

### Material Density

> Pitfall: This seminar is THE MOST DENSE in the entire course!

Reality: It is impossible to cover everything in detail in 100 minutes.

Strategy: Focus on FREQUENTLY USED patterns, not edge cases.

```
WHAT TO COVER                    WHAT TO LEAVE FOR INDIVIDUAL STUDY
─────────────────────           ──────────────────────────────────────
Regex: . ^ $ * [] + ?           PCRE advanced, lookahead/lookbehind
grep: -i -v -n -c -o -E -r      complex --include/exclude patterns
sed: s/// d p i a               hold space, advanced addressing
awk: $0 $1 NR NF BEGIN END      custom functions, getline, 2D arrays
nano: save, exit, search        advanced .nanorc configuration

> 💡 A student once asked me why we cannot just use the graphical interface for everything — the answer is that the terminal is 10 times faster for repetitive operations.

```

### Recommended Order (Priority)

```
1. Regex fundamentals      ████████████████████ CRITICAL

> 💡 Experience shows that debugging is 80% careful reading and 20% writing new code.

2. grep detailed          ████████████████████ CRITICAL
3. sed basics              ███████████████      HIGH
4. awk basics              ███████████████      HIGH
5. nano quick intro        █████                MEDIUM
```

### Error #1 to Avoid

> DO NOT waste time on vim vs nano debate. We use ONLY nano - end of discussion.

---

## PRE-SEMINAR PREPARATION

### Pre-Seminar Checklist

```
□ Terminal open and visible on projector
□ Font size increased (minimum 16pt) for visibility
□ Sample data prepared in ~/demo_sem4/data/
□ Demo scripts tested
□ Cheat sheet displayable during break
□ regex101.com open in a tab
```

### Work Environment Setup

```bash
# Create the working directory
mkdir -p ~/demo_sem4/data
cd ~/demo_sem4
```

### Sample Data Generation (CRITICAL!)

Run this script BEFORE the seminar:

```bash
#!/bin/bash
# Generates all necessary sample files

cd ~/demo_sem4/data

#
# 1. access.log - Simulated web server log
#
cat > access.log << 'EOF'
192.168.1.100 - - [10/Jan/2025:10:15:32 +0200] "GET /index.html HTTP/1.1" 200 1234
192.168.1.101 - - [10/Jan/2025:10:15:33 +0200] "POST /api/login HTTP/1.1" 401 89
192.168.1.100 - - [10/Jan/2025:10:15:35 +0200] "GET /images/logo.png HTTP/1.1" 200 5678
10.0.0.50 - - [10/Jan/2025:10:16:01 +0200] "GET /admin HTTP/1.1" 403 120
192.168.1.102 - - [10/Jan/2025:10:16:15 +0200] "GET /index.html HTTP/1.1" 200 1234
192.168.1.100 - - [10/Jan/2025:10:16:20 +0200] "GET /api/data HTTP/1.1" 200 4521
10.0.0.50 - - [10/Jan/2025:10:16:25 +0200] "GET /admin HTTP/1.1" 403 120
192.168.1.103 - - [10/Jan/2025:10:17:00 +0200] "GET /products HTTP/1.1" 200 8765
192.168.1.101 - - [10/Jan/2025:10:17:05 +0200] "POST /api/login HTTP/1.1" 200 156
192.168.1.104 - - [10/Jan/2025:10:17:30 +0200] "GET /index.html HTTP/1.1" 200 1234
172.16.0.1 - - [10/Jan/2025:10:18:00 +0200] "GET /api/users HTTP/1.1" 500 234
192.168.1.100 - - [10/Jan/2025:10:18:15 +0200] "DELETE /api/item/5 HTTP/1.1" 204 0
10.0.0.50 - - [10/Jan/2025:10:18:30 +0200] "GET /admin/config HTTP/1.1" 403 120
192.168.1.105 - - [10/Jan/2025:10:19:00 +0200] "GET /search?q=test HTTP/1.1" 200 3456
192.168.1.101 - - [10/Jan/2025:10:19:30 +0200] "GET /dashboard HTTP/1.1" 200 7890
EOF

#
# 2. employees.csv - Employee data for awk
#
cat > employees.csv << 'EOF'
ID,Name,Department,Salary
101,John Smith,IT,5500
102,Maria Garcia,HR,4800
103,David Lee,IT,6200
104,Anna Brown,Marketing,5100
105,James Wilson,IT,5800
106,Emma Davis,HR,4600
107,Michael Chen,IT,7000
108,Sarah Johnson,Marketing,5300
109,Robert Taylor,Finance,6500
110,Lisa Anderson,Finance,6100
EOF

#
# 3. config.txt - Configuration file
#
cat > config.txt << 'EOF'
# Application Configuration
# Last updated: 2025-01-10

# Server settings
server.host=localhost
server.port=8080
server.timeout=30

# Database settings
db.host=192.168.1.50
db.port=5432
db.name=production
db.user=admin

# Logging
log.level=INFO
log.file=/var/log/app.log

# Feature flags
feature.beta=false
feature.debug=true
EOF

#
# 4. emails.txt - For email validation
#
cat > emails.txt << 'EOF'
Contact us at: john.doe@example.com
Invalid email: not-an-email
Support: support@company.org
Admin contact: admin@test.co.uk
Bad format: user@
Another bad: @domain.com
Sales team: sales.team@business.net
Personal: alice_wonder@gmail.com
Work: bob.builder@construction.io
Invalid again: spaces in@email.com
EOF

#
# 5. test.txt - Generic file for regex
#
cat > test.txt << 'EOF'
abc
a1c
aXc
ac
abbc
abbbc
cat
cut
cot
cart
cast
the cat sat on the mat
the quick brown fox jumps
192.168.1.1
10.0.0.1
255.255.255.0
email@test.com
hello world
Hello World
HELLO WORLD
line with    multiple   spaces
EOF

echo "✅ Sample data created in $(pwd)"
ls -la
```

### Tools Version Verification

```bash
echo "=== Tools Verification ==="
for cmd in grep sed awk nano; do
    printf "%-8s: " "$cmd"
    $cmd --version 2>&1 | head -1
done
```

---

## DETAILED TIMELINE - FIRST PART (50 min)

### [0:00-0:05] HOOK: Log Analysis in Seconds

Purpose: Capture attention by showing the efficiency of grep+awk in a magic one-liner.

Script to present:

```bash
#!/bin/bash
# Hook: Who tried to access /admin?

echo "🔍 Analysing the log for /admin access attempts..."
echo ""

# Show the raw file (first 5 lines)
echo "📄 Log content (first 5 lines):"
head -5 data/access.log
echo "..."
echo ""

# Magic one-liner
echo "🎯 Who tried to access /admin?"
grep '/admin' data/access.log | \
    awk '{print $1}' | \
    sort | uniq -c | \
    sort -rn

echo ""
echo "✨ We found the suspicious IPs in less than 1 second!"
echo "💡 This is what you can do with grep + awk + sort + uniq!"

*(`awk` is surprisingly powerful for text processing. It is worth investing the time to learn it.)*

```

Notes for instructor:
- Run the command and show the result
- Emphasise that MANUALLY it would have taken minutes
- Mention that we will learn each component
- Leave students curious about how it works

Transition: "To understand how it works, we need to start with the fundamentals: regular expressions."

---

### [0:05-0:15] LIVE CODING: Regex Fundamentals (10 min)

#### Segment 1: Basic Metacharacters (3 min)

```bash
cd ~/demo_sem4/data

# Show the test file
cat test.txt

# PREDICTION: "What will this pattern find?"
# Write on the board/slide BEFORE running
grep 'a.c' test.txt

# EXPLANATION: . = any SINGLE character
# Finds: abc, a1c, aXc (NOT ac - needs a character between a and c)
```

**Deliberate error**:
```bash
# WRONG - students think that . = anything
grep 'a.c' test.txt   # Why does it not find "ac"?
# CORRECT - there must be a character
grep 'a.c' test.txt   # a[something]c
```

#### Segment 2: Anchors ^ and $ (3 min)

```bash
# PREDICTION: "What does ^ do?"
grep '^c' test.txt
# Finds: cat, cut, cot, cart, cast (start with c)

# PREDICTION: "What does $ do?"
grep 't$' test.txt
# Finds: cat, cart, cast (end with t)

# COMBINATION: Line that starts with c AND ends with t
grep '^c.*t$' test.txt
# Finds: cat, cart, cast
```

#### Segment 3: Character Classes (2 min)

```bash
# Explicit sets
grep '[aeiou]' test.txt          # lines with vowels
grep '[0-9]' test.txt            # lines with digits

# SPECIAL ATTENTION - SOURCE OF CONFUSION
grep '[^0-9]' test.txt           # WHAT DOES THIS MEAN?
# It does NOT mean "start of line"!
# ^ INSIDE [] = NEGATION = anything that is NOT a digit
```

Emphasise the difference:
```
^abc    = line starts with "abc"     (^ = anchor)
[^abc]  = any character EXCEPT a,b,c  (^ = negation in set)
```

#### Segment 4: Quantifiers (2 min)

```bash
# * = zero or more of the preceding character
grep 'ab*c' test.txt             # ac, abc, abbc, abbbc

# ERE: + = one or more
grep -E 'ab+c' test.txt          # abc, abbc, abbbc (NOT ac!)

# ERE: ? = zero or one
echo -e "color\ncolour" | grep -E 'colou?r'
# Finds both
```

**DELIBERATE ERROR** (very important!):
```bash
# WRONG - forgot -E
grep 'ab+c' test.txt             # DOES NOT WORK as expected!
# In BRE, + is a literal character!

# CORRECT
grep -E 'ab+c' test.txt          # Now it works
# OR
grep 'ab\+c' test.txt            # Escape + in BRE
```

Transition: "Now that we know the regex basics, let us test our understanding with a question..."

---

### [0:15-0:20] PEER INSTRUCTION Q1: Globbing vs Regex (5 min)

Display the question (slide/board):

```
┌─────────────────────────────────────────────────────────────┐
│  PEER INSTRUCTION Q1: Globbing vs Regex                    │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  What is the difference between these two commands?         │
│                                                             │
│     A) ls *.txt                                             │
│     B) grep '.*\.txt' files.list                           │
│                                                             │
│  Options:                                                   │
│  1) They are equivalent                                     │
│  2) A) uses shell globbing, B) uses regex                   │
│  3) A) searches in files, B) lists files                   │
│  4) B) is syntactically wrong                               │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

Process (5 min total):
1. [1 min] Read the question, students vote individually (hands/cards)
2. [2 min] Discussion in pairs - explain your choice to each other
3. [1 min] Re-vote
4. [1 min] Correct explanation

Correct answer: 2

Explanation:
```bash
# SHELL GLOBBING (in ls, cp, mv, etc.)
ls *.txt
# * = any characters (zero or more)
# Shell expands BEFORE sending to command

# REGEX (in grep, sed, awk)
grep '.*\.txt' files.list
# . = any SINGLE character
# * = zero or more of the precedent
# .* = any characters (the combination)
# \. = literal dot (escaped)

# THE MAJOR CONFUSION:
# In shell: * alone = anything
# In regex: * alone = quantifier, needs something before it
```

---

### [0:20-0:35] LIVE CODING: GREP In Depth (15 min)

#### Segment 1: Essential Options (8 min)

```bash
cd ~/demo_sem4/data

# -i: case insensitive
echo "=== Case insensitive ==="
grep -i 'get' access.log | head -3

# -v: invert (lines that do NOT contain pattern)
echo ""
echo "=== Lines without comments ==="
grep -v '^#' config.txt

# -n: line number
echo ""
echo "=== With line numbers ==="
grep -n 'IT' employees.csv

# -c: count matches (NOT characters!)
echo ""
echo "=== How many requests with code 200? ==="
grep -c '"[[:space:]]200[[:space:]]' access.log

# -o: only the match (VERY USEFUL!)
echo ""
echo "=== Extract only the IPs ==="
grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' access.log

# -l: only file names
echo ""
echo "=== Files containing 'host' ==="
grep -l 'host' *.txt *.csv 2>/dev/null

# -r: recursive
echo ""
echo "=== Search recursively ==="
grep -r 'localhost' . 2>/dev/null | head -3
```

Demonstrate the difference -c vs wc -l:
```bash
# -c counts LINES with matches
echo -e "a\na\nb" | grep -c 'a'    # Output: 2

# But what if we want to count ALL matches?
echo -e "aa\na\nb" | grep -o 'a' | wc -l    # Output: 3
```

#### Segment 2: GREP + Regex in Practice (7 min)

```bash
# Extract IPs (with step-by-step explanation)
echo "=== Pattern for IP ==="
echo "Pattern: ([0-9]{1,3}\.){3}[0-9]{1,3}"
echo "  [0-9]{1,3}  = 1-3 digits"
echo "  \.          = literal dot"
echo "  (...){3}    = repeat 3 times (first triplet + dot × 3)"
echo "  [0-9]{1,3}  = last triplet"
echo ""
grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' access.log | sort -u

# Extract emails
echo ""
echo "=== Extract valid emails ==="
grep -oE '[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}' emails.txt

# Find lines with HTTP errors (4xx, 5xx)
echo ""
echo "=== HTTP Errors (4xx and 5xx) ==="
grep -E '" [45][0-9]{2} ' access.log
```

**DELIBERATE ERROR**:
```bash
# Forgot -E for quantifiers
grep '[0-9]{3}' access.log       
# Output: nothing or wrong!
# Why? {3} in BRE is literal!

grep -E '[0-9]{3}' access.log    
# Now it works!
```

---

### [0:35-0:45] SPRINT #1: Grep Master (10 min)

Display on screen:

```
╔═══════════════════════════════════════════════════════════════════╗
║  🏃 SPRINT #1: Grep Master (10 min)                               ║
╠═══════════════════════════════════════════════════════════════════╣
║                                                                   ║
║  PAIR PROGRAMMING! Switch at minute 5!                            ║
║                                                                   ║
║  Using the files in ~/demo_sem4/data/, solve:                     ║
║                                                                   ║
║  1. Find all lines in access.log with code 200                    ║
║                                                                   ║
║  2. Extract only the UNIQUE IPs from access.log                   ║
║     (hint: grep -o + sort + uniq)                                ║
║                                                                   ║
║  3. Find lines in config.txt that are NOT comments                ║
║     and are NOT empty                                              ║
║                                                                   ║
║  4. Count how many employees are in the IT department             ║
║     (employees.csv)                                               ║
║                                                                   ║
║  5. BONUS: Extract all port values from config.txt                ║
║                                                                   ║
║  ⏱️ TIME: 10 minutes                                              ║
║                                                                   ║
╚═══════════════════════════════════════════════════════════════════╝
```

Solutions (for instructor):

```bash
# 1. Lines with code 200
grep ' 200 ' access.log

# 2. Unique IPs
grep -oE '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' access.log | sort -u

# 3. Non-comments and non-empty
grep -v '^#' config.txt | grep -v '^$'
# OR more elegant:
grep -vE '^(#|$)' config.txt

# 4. IT employees
grep -c ',IT,' employees.csv

# 5. BONUS: Ports
grep -oE 'port=[0-9]+' config.txt
# OR
grep 'port' config.txt | grep -oE '[0-9]+'
```

---

### [0:45-0:50] PEER INSTRUCTION Q2: sed Substitution (5 min)

```
┌─────────────────────────────────────────────────────────────┐
│  PEER INSTRUCTION Q2: sed Substitution                      │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  What does this command do?                                 │
│                                                             │
│     sed 's/cat/dog/' animals.txt                           │
│                                                             │
│  Options:                                                   │
│  A) Replaces ALL occurrences of "cat" with "dog"           │
│     in the file                                             │
│  B) Replaces the FIRST occurrence of "cat" with "dog"      │
│     ON EACH LINE                                            │
│  C) Replaces the FIRST occurrence of "cat" with "dog"      │
│     IN THE ENTIRE FILE                                      │
│  D) Modifies the file animals.txt directly                  │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

Correct answer: B

Explanation:
```bash
# sed processes LINE BY LINE
# Without /g, it replaces only the FIRST occurrence on each line

echo "cat cat cat" | sed 's/cat/dog/'
# Output: dog cat cat (only the first)

echo "cat cat cat" | sed 's/cat/dog/g'
# Output: dog dog dog (all)

# Output goes to stdout, it does NOT modify the file!
# For modification: sed -i
```

---

## BREAK 10 MINUTES

On screen during the break: Display the Visual Cheat Sheet

```
╔═══════════════════════════════════════════════════════════════════╗
║                    🔤 REGEX QUICK REFERENCE                       ║
╠═══════════════════════════════════════════════════════════════════╣
║  .         Any character                                         ║
║  ^         Start of line                                         ║
║  $         End of line                                           ║
║  *         0 or more (of precedent)                              ║
║  +         1 or more (ERE)                                       ║
║  ?         0 or 1 (ERE)                                          ║
║  [abc]     Any from set                                          ║
║  [^abc]    None from set                                         ║
║  [a-z]     Range                                                 ║
║  \b        Word boundary                                         ║
║  ()        Grouping (ERE)                                        ║
║  |         OR (ERE)                                              ║
╠═══════════════════════════════════════════════════════════════════╣
║  grep        BRE by default    │  grep -E    ERE                 ║
║  sed         BRE by default    │  sed -E     ERE                 ║
║  awk         ERE by default    │                                 ║
╚═══════════════════════════════════════════════════════════════════╝
```

---

## DETAILED TIMELINE - SECOND PART (50 min)

### [0:00-0:05] REACTIVATION: Quick Quiz (5 min)

Quick questions (raised hands):

```
1. What does grep -v do?
   → Inverts - shows lines that do NOT match

2. In regex, what does [^0-9] mean?
   → Any character that is NOT a digit

3. Why does grep 'a+b' not work as expected?
   → + in BRE is literal, need grep -E or \+

4. What is the difference between grep -c and wc -l?
   → grep -c = lines with match; wc -l = total lines
```

---

### [0:05-0:20] LIVE CODING: SED (15 min)

#### Segment 1: Basic Substitution (6 min)

```bash
cd ~/demo_sem4/data

# Simple substitution
echo "=== Simple substitution ==="
sed 's/localhost/127.0.0.1/' config.txt | grep -E '(localhost|127.0.0.1)'

# Global (all occurrences on line)
echo ""
echo "=== With vs Without /g ==="
echo "cat cat cat" | sed 's/cat/dog/'     # dog cat cat
echo "cat cat cat" | sed 's/cat/dog/g'    # dog dog dog

# Case insensitive
echo ""
echo "=== Case insensitive ==="
echo "Hello HELLO hello" | sed 's/hello/hi/gi'

# Alternative delimiter (useful for paths)
echo ""
echo "=== Alternative delimiter ==="
sed 's|/var/log|/tmp/log|g' config.txt | grep log
# Or with #
sed 's#localhost#127.0.0.1#g' config.txt | head -3
```

PREDICTION at each example!

#### Segment 2: Addressing and Multiple Commands (5 min)

```bash
# Only on certain lines
echo "=== Addressing ==="

# Delete first line (CSV header)
echo "--- Without header ---"
sed '1d' employees.csv | head -3

# Delete comments
echo ""
echo "--- Without comments ---"
sed '/^#/d' config.txt

# Range of lines
echo ""
echo "--- Only lines 2-4 modified ---"
sed '2,4s/IT/Technology/' employees.csv | head -5

# Insertion and append
echo ""
echo "--- Insertion at beginning ---"
sed '1i\# MODIFIED FILE' config.txt | head -3
```

#### Segment 3: sed -i and Backreferences (4 min)

```bash
# Pitfall: In-place editing (demonstration on copy)
echo "=== IN-PLACE EDITING ==="
cp config.txt config_test.txt

# Without backup (DANGEROUS!)
# sed -i 's/localhost/127.0.0.1/' config_test.txt

# With backup (RECOMMENDED!)
sed -i.bak 's/localhost/127.0.0.1/' config_test.txt
ls config_test.*
echo "Original kept in .bak"

# & = the entire match
echo ""
echo "=== & = entire match ==="
echo "port=8080" | sed 's/[0-9]\+/[&]/'    # port=[8080]

# Backreferences
echo ""
echo "=== Backreferences ==="
echo "John Smith" | sed 's/\([A-Za-z]*\) \([A-Za-z]*\)/\2, \1/'
# Output: Smith, John
```

---

### [0:20-0:35] LIVE CODING: AWK (15 min)

#### Segment 1: Fields and print (6 min)

```bash
cd ~/demo_sem4/data

echo "=== AWK FIELDS ==="

# Basic fields (space = default separator)
echo ""
echo "--- First field (IP) from log ---"
awk '{ print $1 }' access.log | head -3

# Last field
echo ""
echo "--- Last field (size) ---"
awk '{ print $NF }' access.log | head -3

# With custom separator (CSV)
echo ""
echo "--- Name column from CSV ---"
awk -F',' '{ print $2 }' employees.csv | head -5

# Pitfall: print with vs without comma
echo ""
echo "=== COMMA = SPACE ==="
echo "--- print \$2 \$3 (concatenated) ---"
awk -F',' '{ print $2 $3 }' employees.csv | head -3
echo ""
echo "--- print \$2, \$3 (with space) ---"
awk -F',' '{ print $2, $3 }' employees.csv | head -3

# Skip header
echo ""
echo "--- Skip header with NR > 1 ---"
awk -F',' 'NR > 1 { print $2 }' employees.csv | head -3
```

#### Segment 2: Conditions and Calculations (6 min)

```bash
# Filtering
echo "=== FILTERING ==="

echo "--- Employees from IT ---"
awk -F',' '$3 == "IT"' employees.csv

echo ""
echo "--- Salary > 5500 ---"
awk -F',' '$4 > 5500' employees.csv

# Calculations with BEGIN/END
echo ""
echo "=== CALCULATIONS ==="

echo "--- Total salaries ---"
awk -F',' 'NR > 1 { sum += $4 } END { print "Total:", sum }' employees.csv

echo ""
echo "--- Average salary ---"
awk -F',' 'NR > 1 { sum += $4; count++ } END { print "Average:", sum/count }' employees.csv

# printf formatting
echo ""
echo "=== FORMATTING ==="
awk -F',' 'NR > 1 { printf "%-15s $%d\n", $2, $4 }' employees.csv
```

#### Segment 3: Associative Arrays (3 min)

```bash
# Count per category
echo "=== ASSOCIATIVE ARRAYS ==="

echo "--- Employees per department ---"
awk -F',' 'NR > 1 { count[$3]++ } 
           END { for (dept in count) print dept, count[dept] }' employees.csv

echo ""
echo "--- Total salaries per department ---"
awk -F',' 'NR > 1 { sum[$3] += $4 } 
           END { for (dept in sum) printf "%s: $%d\n", dept, sum[dept] }' employees.csv
```

---

### [0:35-0:40] MINI-SPRINT: AWK Challenge (5 min)

```
╔═══════════════════════════════════════════════════════════════════╗
║  🏃 MINI-SPRINT: AWK Challenge (5 min)                            ║
╠═══════════════════════════════════════════════════════════════════╣
║                                                                   ║
║  Using employees.csv:                                             ║
║                                                                   ║
║  1. Display only the names of employees from HR                   ║
║                                                                   ║
║  2. Calculate the average salary                                  ║
║                                                                   ║
║  3. Find the employee with the highest salary                     ║
║                                                                   ║
║  HINT for 3:                                                      ║
║  awk -F',' 'NR>1 && $4>max {max=$4; name=$2}                     ║
║             END{print name, max}'                                 ║
║                                                                   ║
╚═══════════════════════════════════════════════════════════════════╝
```

Solutions:
```bash
# 1. HR employees
awk -F',' '$3 == "HR" { print $2 }' employees.csv

# 2. Average salary
awk -F',' 'NR > 1 { sum += $4; count++ } END { print sum/count }' employees.csv

# 3. Highest salary
awk -F',' 'NR>1 && $4>max {max=$4; name=$2} END{print name, max}' employees.csv
```

---

### [0:40-0:45] NANO QUICK INTRO (5 min)

```bash
# Open nano
nano /tmp/test_script.sh
```

Demonstrate on screen (show the commands at the bottom):

```
┌─────────────────────────────────────────────────────────────────────┐
│  GNU nano 7.2                    /tmp/test_script.sh               │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  #!/bin/bash                                                        │
│  # Test script                                                      │
│  echo "Hello from nano!"                                            │
│                                                                     │
│                                                                     │
├─────────────────────────────────────────────────────────────────────┤
│  ^G Help    ^O Write Out  ^W Where Is   ^K Cut        ^T Execute   │
│  ^X Exit    ^R Read File  ^\ Replace    ^U Paste      ^J Justify   │
└─────────────────────────────────────────────────────────────────────┘

^ = CTRL
```

Demonstration (30 seconds each):
1. Write a few lines
2. CTRL+O = Save (Write Out) → confirm with Enter
3. CTRL+W = Search → search for "echo"
4. CTRL+K = Cut line
5. CTRL+U = Paste
6. CTRL+X = Exit

Key message: "Nano does not require memorisation - the commands are always visible!"

---

### [0:45-0:48] LLM EXERCISE: Regex Generator (3 min)

```
╔═══════════════════════════════════════════════════════════════════╗
║  🤖 LLM Exercise: Regex Generator (3 min)                         ║
╠═══════════════════════════════════════════════════════════════════╣
║                                                                   ║
║  TASK: Ask an LLM (ChatGPT/Claude) to generate a regex:           ║
║                                                                   ║
║  "Generate a regex for validating Romanian phone numbers          ║
║   in format 07XX XXX XXX"                                         ║
║                                                                   ║
║  EVALUATE the response:                                           ║
║  □ Does it work with grep -E?                                     ║
║  □ Does it accept the format with/without spaces?                 ║
║  □ Does it reject invalid numbers?                                ║
║  □ Is it too complex or just right?                               ║
║                                                                   ║
║  Test: echo "0722 123 456" | grep -E 'regex_here'                ║
║                                                                   ║
╚═══════════════════════════════════════════════════════════════════╝
```

Verification example:
```bash
# A possible regex generated by LLM:
regex='07[0-9]{2}[[:space:]]?[0-9]{3}[[:space:]]?[0-9]{3}'

# Testing
echo "0722 123 456" | grep -E "$regex"   # Valid
echo "0722123456" | grep -E "$regex"     # Valid (without spaces)
echo "0622 123 456" | grep -E "$regex"   # Invalid (not 07)
```

---

### [0:48-0:50] REFLECTION (2 min)

```
╔═══════════════════════════════════════════════════════════════════╗
║  🧠 REFLECTION (2 minutes)                                        ║
╠═══════════════════════════════════════════════════════════════════╣
║                                                                   ║
║  1. Which of grep/sed/awk seems most useful to you? Why?         ║
║                                                                   ║
║  2. A real case where you could use regex:                        ║
║     _________________________________________________             ║
║                                                                   ║
║  3. What would you like to practise more:                         ║
║     □ Regex    □ GREP    □ SED    □ AWK                          ║
║                                                                   ║
║  📝 Assignment: Complete S04_01_TEMA.md by next week             ║
║                                                                   ║
╚═══════════════════════════════════════════════════════════════════╝
```

---

## COMMON TROUBLESHOOTING

| Problem | Diagnosis | Quick Solution |
|---------|-----------|----------------|
| grep: quantifier does not work | BRE vs ERE | `grep -E` or escape `\+` |
| sed: does not modify file | Output to stdout | `sed -i` for in-place |
| sed: error with / in path | Delimiter conflict | `sed 's\|old\|new\|'` |
| awk: concatenated fields | Missing comma | `print $1, $2` (with comma) |
| awk: $0 vs $1 confusion | $0 = entire line | $1 = first field |
| Regex too greedy | .* takes too much | Restructure pattern |
| nano: does not save | CTRL+S is wrong | CTRL+O for Write Out |
| grep -o does not work | Incorrect pattern | Test without -o first |

---

## ADDITIONAL MATERIALS

### For Advanced Preparation
- `docs/S04_02_MAIN_MATERIAL.md` - Complete theoretical material
- `docs/S04_08_SPECTACULAR_DEMOS.md` - Additional demos

### For Quick Reference
- `docs/S04_09_VISUAL_CHEAT_SHEET.md` - Printable one-pager

### For Evaluation
- `docs/S04_03_PEER_INSTRUCTION.md` - All PI questions
- `homework/S04_01_TEMA.md` - Assignment for students

---

*Instructor guide for Seminar 4 of Operating Systems | Bucharest University of Economic Studies - CSIE*
