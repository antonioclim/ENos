# Main Material: Text Processing
## Regular Expressions, GREP, SED, AWK, Nano

*Personal note: Between `sed` and `awk`, I use `sed` for simple replacements and `awk` when I need logic. Each has its place.*


> Operating Systems | Bucharest University of Economic Studies - CSIE  
> Seminar 4 | Complete theoretical material  
> Version: 1.0 | Date: January 2025

---

## Learning Objectives

Upon completion of studying this material, you will be able to:

### Knowledge Level

- Define what regular expressions are and their types (BRE, ERE, PCRE)
- Identify regex metacharacters and the purpose of each
- Enumerate the main options of the `grep`, `sed`, `awk` commands


### Comprehension Level
- Explain the difference between shell globbing and regex
- Interpret complex regex patterns
- Describe the line-by-line processing model of sed and awk

### Application Level
- Construct regex for validation (email, IP, telephone)
- Use grep for efficient searching in files and directories
- Apply sed for text modifications (substitution, deletion)
- Process CSV/TSV files with awk for extraction and calculations

### Analysis and Synthesis Level
- Combine grep, sed and awk in efficient pipelines
- Choose the appropriate tool for each type of problem
- Optimise one-liners for performance and clarity

---

## Table of Contents

1. [Module 1: Regular Expressions (Regex)](#module-1-regular-expressions-regex)
2. [Module 2: GREP - Text Search](#module-2-grep---text-search)

*(`grep` is probably the command I use most frequently. Simple, fast, efficient.)*

3. [Module 3: SED - Stream Editor](#module-3-sed---stream-editor)
4. [Module 4: AWK - Structured Processing](#module-4-awk---structured-processing)
5. [Module 5: NANO - Simple Text Editor](#module-5-nano---simple-text-editor)
6. [Extended Cheat Sheet](#-extended-cheat-sheet)
7. [Frequent Combinations](#-frequent-combinations)

---

# MODULE 1: REGULAR EXPRESSIONS (REGEX)

## 1.1 Introduction and Types

> Confession: I worked for 3 years with grep before truly understanding the difference between BRE and ERE. Now I always use `grep -E` (or `egrep`) — it is more intuitive and I do not have to remember when to put a backslash and when not to.

### SUBGOAL 1.1.1: Understand what regular expressions are

Regular expressions (regex) are patterns that describe sets of character strings. They are a formal language for specifying text matching rules.

Main uses:
- Search: Finding text that matches a pattern
- Validation: Checking the format of input data
- Extraction: Isolating relevant portions from text
- Replacement: Substituting text based on patterns

### Types of Regular Expressions

| Type | Full Name | Usage | Characteristics |
|------|-----------|-------|-----------------|
| BRE | Basic Regular Expression | grep, sed (default) | Limited metacharacters, escape needed for +, ?, {}, (), \| |
| ERE | Extended Regular Expression | grep -E, awk, sed -E | Extended metacharacters without escape |
| PCRE | Perl Compatible RE | grep -P, modern languages | Advanced features: lookahead, lookbehind, \d, \w, etc. |

Golden rule: When in doubt, use ERE (grep -E, sed -E) - it is more intuitive and consistent.

---

## 1.2 Metacharacters

### SUBGOAL 1.2.1: Master basic metacharacters

Metacharacters are characters with special meaning in regex.

### The `.` (dot) Character

Meaning: Matches any single character (except newline by default).

```bash
# Pattern: a.c
# Matches: abc, a1c, aXc, a c
# Does NOT match: ac (missing the character in the middle)

echo -e "abc\na1c\naXc\nac" | grep 'a.c'
# Output: abc, a1c, aXc
```

> 🔮 **PREDICTION:** Before running, think: why does `ac` not appear in the output?

### The `^` (caret) Character

Meaning: Matches the beginning of the line (anchor).

```bash
# Pattern: ^Start
# Matches lines that START with "Start"

echo -e "Start here\nNot Start\nStarting" | grep '^Start'
# Output: Start here, Starting
```

> 🔮 **PREDICTION:** Why does "Not Start" not appear, even though it contains the word "Start"?

### The `$` (dollar) Character

Meaning: Matches the end of the line (anchor).

```bash
# Pattern: end$
# Matches lines that END with "end"

echo -e "The end\nendless\nFriend" | grep 'end$'
# Output: The end
```

### The `\` (backslash) Character

Meaning: Escape - causes the next character to be treated literally.

```bash
# To search for a literal dot
grep '192\.168\.1\.1' file.txt    # Searches for the exact IP

# Without escape, . would match any character
grep '192.168.1.1' file.txt       # Would also match "192X168Y1Z1"
```

### Basic metacharacters summary table

| Symbol | Meaning | Example | Matches |
|--------|---------|---------|---------|
| `.` | Any character (one) | `a.c` | abc, aXc, a1c |
| `^` | Start of line | `^Start` | "Start..." at beginning |
| `$` | End of line | `end$` | "...end" at final |
| `\` | Escape | `\.` | literal dot |

---

## 1.3 Character Classes

### SUBGOAL 1.3.1: Use character sets

Character classes allow specifying a set of possible characters.

### Explicit Sets with `[...]`

```bash
[abc]       # Matches ONE character: a OR b OR c
[a-z]       # Matches any lowercase letter (range)
[A-Z]       # Matches any uppercase letter
[0-9]       # Matches any digit
[a-zA-Z]    # Matches any letter
[a-zA-Z0-9] # Matches alphanumeric
```

### Negation with `[^...]`

```bash
[^abc]      # Matches any character EXCEPT a, b, c
[^0-9]      # Matches any character that is NOT a digit
[^a-z]      # Matches anything that is NOT a lowercase letter
```

> ⚠️ ATTENTION: `^` has different meanings depending on context:
> - `^abc` = line starts with "abc" (anchor)
> - `[^abc]` = any character EXCEPT a, b, c (negation in set)

### POSIX Classes

POSIX classes are locale-independent and more expressive:

```bash
[[:alpha:]]     # Letters [a-zA-Z]
[[:digit:]]     # Digits [0-9]
[[:alnum:]]     # Alphanumeric [a-zA-Z0-9]
[[:space:]]     # Whitespace (space, tab, newline)
[[:lower:]]     # Lowercase letters [a-z]
[[:upper:]]     # Uppercase letters [A-Z]
[[:punct:]]     # Punctuation
[[:blank:]]     # Space and tab (not newline)
[[:print:]]     # Printable characters
[[:xdigit:]]    # Hexadecimal [0-9A-Fa-f]
```

### Practical examples

```bash
# Find lines containing digits
grep '[0-9]' file.txt

# Find lines starting with uppercase letter
grep '^[A-Z]' file.txt

# Find lines with non-alphanumeric characters
grep '[^[:alnum:]]' file.txt

# Find words starting with uppercase
grep '\b[A-Z][a-z]*\b' file.txt
```

---

## 1.4 Quantifiers

### SUBGOAL 1.4.1: Control repetitions

Quantifiers specify HOW MANY TIMES an element can repeat.

### Differences BRE vs ERE

| Quantifier | BRE | ERE | Meaning |
|------------|-----|-----|---------|
| Zero or more | `*` | `*` | The precedent 0+ times |
| One or more | `\+` | `+` | The precedent 1+ times |
| Zero or one | `\?` | `?` | The precedent 0 or 1 times |
| Exactly n | `\{n\}` | `{n}` | The precedent exactly n times |
| Minimum n | `\{n,\}` | `{n,}` | The precedent n+ times |
| Between n and m | `\{n,m\}` | `{n,m}` | The precedent n-m times |

### Detailed examples

```bash
# * = zero or more
echo -e "ac\nabc\nabbc\nabbbc" | grep 'ab*c'
# Output: ac, abc, abbc, abbbc (all!)

# + = one or more (requires ERE)
echo -e "ac\nabc\nabbc\nabbbc" | grep -E 'ab+c'
# Output: abc, abbc, abbbc (NOT ac - needs at least one b)

# ? = zero or one
echo -e "color\ncolour" | grep -E 'colou?r'
# Output: color, colour (the u is optional)

# {n} = exactly n repetitions
echo -e "12\n123\n1234\n12345" | grep -E '[0-9]{4}'
# Output: 1234, 12345 (minimum 4 consecutive digits)

# {n,m} = between n and m repetitions
echo -e "ab\nabb\nabbb\nabbbb" | grep -E 'ab{2,3}'
# Output: abb, abbb (2 or 3 b's)
```

### Greedy vs Lazy (Advanced - PCRE)

By default, quantifiers are **greedy** (they take as much as possible):

```bash
# Text: <div>Hello</div><div>World</div>

# Greedy: .*
grep -oP '<div>.*</div>' <<< '<div>Hello</div><div>World</div>'
# Output: <div>Hello</div><div>World</div> (everything!)

# Lazy: .*?
grep -oP '<div>.*?</div>' <<< '<div>Hello</div><div>World</div>'
# Output: <div>Hello</div> (minimum necessary)
```

> 🔮 **PREDICTION:** What would happen if you used `grep -oE` instead of `grep -oP`? (Hint: ERE does not support `?` for lazy matching)

> Note: `*?` and `+?` (lazy) are only available in PCRE (grep -P).

---

## 1.5 Grouping and Alternatives

### Grouping with `()`

In ERE, parentheses group elements to apply quantifiers:

```bash
# Repeating a group
echo -e "ab\nabab\nababab" | grep -E '(ab)+'
# Output: all (they have at least one "ab")

# Grouping for alternatives
echo -e "cat\ndog\ncat and dog" | grep -E '(cat|dog)'
# Output: all lines with cat OR dog
```

### Alternative with `|`

The `|` operator works as logical OR:

```bash
# Search for error OR warning OR fatal
grep -E 'error|warning|fatal' log.txt

# With grouping for context
grep -E '^(yes|no)$' file.txt    # Lines with ONLY "yes" or "no"
```

### Backreferences

Backreferences allow reusing captured groups:

```bash
# \1 = first captured group, \2 = second, etc.

# Find duplicate words
echo "the the quick fox" | grep -E '\b(\w+)\s+\1\b'
# Output: the the

# Reverse order (first name last name → last name, first name)
echo "John Smith" | sed 's/\([A-Za-z]*\) \([A-Za-z]*\)/\2, \1/'
# Output: Smith, John

# Matching HTML tags
grep -E '<([a-z]+)>.*</\1>' file.html
# Matches <div>text</div> but not <div>text</span>
```

---

## 1.6 Anchors and Word Boundaries

### Line Anchors

```bash
^       # Start of line
$       # End of line

# Empty line
grep '^$' file.txt

# Line containing ONLY a number
grep -E '^[0-9]+$' file.txt
```

### Word Boundaries

```bash
\b      # Word boundary (start OR end of word)
\B      # NON-word boundary
\<      # Start of word (GNU extension)
\>      # End of word (GNU extension)
```

### Practical examples

```bash
# Exact word "word" (not "password" or "wording")
grep '\bword\b' file.txt
grep '\<word\>' file.txt    # GNU equivalent

# Words starting with "pre"
grep '\bpre' file.txt       # prefix, prepare, etc.

# Words ending with "ing"
grep 'ing\b' file.txt       # running, jumping, etc.

# Words of exactly 5 letters
grep -E '\b[a-zA-Z]{5}\b' file.txt
```

---

## 1.7 BRE vs ERE - Complete Comparison Table

| Feature | BRE (Basic) | ERE (Extended) | Note |
|---------|-------------|----------------|------|
| Basic metacharacters | `.` `^` `$` `*` `[` `]` `\` | All from BRE | Identical |
| Quantifier + | `\+` | `+` | ERE simpler |
| Quantifier ? | `\?` | `?` | ERE simpler |
| Interval {n,m} | `\{n,m\}` | `{n,m}` | ERE simpler |
| Grouping | `\(\)` | `()` | ERE simpler |
| Alternative | `\|` | `|` | ERE simpler |
| grep usage | `grep` | `grep -E` or `egrep` | |
| sed usage | `sed` | `sed -E` or `sed -r` | |
| awk usage | - | Default | awk uses ERE |

Practical recommendation: Always use grep -E and sed -E for consistency and simplicity.

---

# MODULE 2: GREP - TEXT SEARCH

## 2.1 Syntax and Variants

### SUBGOAL 2.1.1: Choose the correct grep variant

GREP = Global Regular Expression Print

Searches for lines that match a pattern and displays them.

### Main variants

| Command | Equivalent | Regex Type | When to use |
|---------|------------|------------|-------------|
| `grep` | - | BRE | Simple searches |
| `grep -E` | `egrep` | ERE | Patterns with +, ?, \|, {} |
| `grep -F` | `fgrep` | Fixed | Literal text search (fast) |
| `grep -P` | - | PCRE | Advanced features (\d, lookahead) |

### Basic syntax

```bash
grep [options] 'pattern' [files]
grep [options] -e 'pattern1' -e 'pattern2' [files]
grep [options] -f pattern_file [files]
```

---

## 2.2 Essential Options

### SUBGOAL 2.2.1: Master frequent options

### Matching Options

```bash
-i, --ignore-case       # Case-insensitive
-w, --word-regexp       # Whole word (equivalent to \b...\b)
-x, --line-regexp       # Whole line (equivalent to ^...$)
-v, --invert-match      # Invert - lines that do NOT contain pattern
-e PATTERN              # Specify pattern (for multiple)
-f FILE                 # Read patterns from file
```

### Output Options

```bash
-n, --line-number       # Display line numbers
-c, --count             # Count lines with matches (not characters!)
-l, --files-with-matches    # Display only file names with matches
-L, --files-without-match   # Files WITHOUT matches
-o, --only-matching     # Display ONLY the matching part
-m NUM                  # Stop after NUM matches
-q, --quiet             # Silent - only exit code (for scripts)
-H, --with-filename     # Display filename (default for multiple files)
-h, --no-filename       # Do NOT display filename
```

### Context Options

```bash
-A NUM, --after-context=NUM     # NUM lines AFTER match
-B NUM, --before-context=NUM    # NUM lines BEFORE match
-C NUM, --context=NUM           # NUM lines before AND after
```

### Options for Files and Directories

```bash
-r, --recursive         # Search recursively in directories
-R, --dereference-recursive  # Recursive, follows symlinks
--include=GLOB          # Only files matching glob
--exclude=GLOB          # Exclude files matching
--exclude-dir=DIR       # Exclude directories
```

---

## 2.3 Practical Patterns

### Email Validation and Extraction

```bash
# Pattern for email (simplified)
EMAIL='[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}'

# Find lines with emails
grep -E "$EMAIL" contacts.txt

# Extract ONLY the emails
grep -oE "$EMAIL" document.txt
```

### IP Validation and Extraction

```bash
# Pattern for IPv4 (basic)
IP='([0-9]{1,3}\.){3}[0-9]{1,3}'

# Extract IPs from log
grep -oE "$IP" access.log

# Stricter pattern (0-255)
IP_STRICT='((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)'
```

### Patterns for Logs

```bash
# HTTP errors (4xx, 5xx)
grep -E '" [45][0-9]{2} ' access.log

# Timestamp in standard format
grep -E '[0-9]{2}/[A-Za-z]{3}/[0-9]{4}:[0-9]{2}:[0-9]{2}:[0-9]{2}' access.log

# Lines with ERROR or WARN
grep -Ei '(error|warn|critical)' application.log
```

---

## 2.4 GREP in Pipelines

### Frequent combinations

```bash
# Filter process output (avoid finding the grep command itself)
ps aux | grep '[n]ginx'
# The [n]ginx trick: pattern matches "nginx" but NOT "[n]ginx"

# Top 10 IPs from access.log
grep -oE '^[0-9.]+' access.log | sort | uniq -c | sort -rn | head -10

# Search in source code, excluding directories
grep -rn --include='*.py' --exclude-dir='.git' 'def ' ~/projects/

# Count errors per day
grep 'ERROR' app.log | cut -d' ' -f1 | uniq -c
```

### Exit Codes in Scripts

```bash
# Exit codes:
# 0 - found matches
# 1 - did not find matches
# 2 - error (non-existent file, etc.)

# Usage in if
if grep -q 'error' log.txt; then
    echo "Errors found!"
    exit 1
fi

# Usage with &&
grep -q 'pattern' file.txt && echo "Found"
```

---

# MODULE 3: SED - STREAM EDITOR

## 3.1 Operating Model

### SUBGOAL 3.1.1: Understand how sed processes

SED (Stream EDitor) is a non-interactive text editor that processes text line by line.

### Execution model

```
┌─────────────────────────────────────────────────────────────┐
│                     SED PROCESSING MODEL                    │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  INPUT FILE                                                 │
│       │                                                     │
│       ▼                                                     │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ For each line:                                      │   │
│  │   1. Read the line into "pattern space"             │   │
│  │   2. Apply ALL commands in order                    │   │
│  │   3. Print pattern space (unless -n)                │   │
│  │   4. Empty pattern space                            │   │
│  │   5. Move to next line                              │   │
│  └─────────────────────────────────────────────────────┘   │
│       │                                                     │
│       ▼                                                     │
│  OUTPUT (stdout or file with -i)                          │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Basic syntax

```bash
sed 'command' file
sed -e 'cmd1' -e 'cmd2' file    # Multiple commands
sed -f script.sed file          # Commands from file
sed -i 'command' file           # In-place editing (modifies the file!)

> 💡 I have had students who learnt Bash in two weeks starting from zero — so it is possible, with consistent practice.

sed -i.bak 'command' file       # In-place with backup
```

---

## 3.2 The Substitution Command (s)

### SUBGOAL 3.2.1: Master substitution

Substitution is the most used sed command.

### Syntax

```bash
s/pattern/replacement/flags

# Common flags:
# g - global (all occurrences on line)
# i - case-insensitive
# p - print the modified line (useful with -n)
# w file - write modified lines to file
# N - replace the N-th occurrence
```

### Basic examples

```bash
# First occurrence on each line
echo "cat cat cat" | sed 's/cat/dog/'
# Output: dog cat cat
```

> 🔮 **PREDICTION:** What do you get if you add the `g` flag? What about using `s/cat/dog/2`?

```bash
# All occurrences (global)
echo "cat cat cat" | sed 's/cat/dog/g'
# Output: dog dog dog

# Case-insensitive
echo "Cat CAT cat" | sed 's/cat/dog/gi'
# Output: dog dog dog

# Second occurrence
echo "cat cat cat" | sed 's/cat/dog/2'
# Output: cat dog cat

# From the second occurrence onwards
echo "cat cat cat cat" | sed 's/cat/dog/2g'
# Output: cat dog dog dog
```

### Alternative Delimiters

When the pattern contains `/`, use a different delimiter:

```bash
# Problem: / in path
sed 's//usr/local//opt/' file.txt    # ERROR!

# Solution: different delimiter
sed 's|/usr/local|/opt|g' file.txt   # OK
sed 's#/usr/local#/opt#g' file.txt   # OK
sed 's@/usr/local@/opt@g' file.txt   # OK
```

---

## 3.3 Addressing

### SUBGOAL 3.3.1: Target specific lines

Addresses specify ON WHICH LINES to apply the command.

### Types of addresses

```bash
# Line number
sed '5d' file.txt              # Delete line 5
sed '1,10s/old/new/' file.txt  # Substitution on lines 1-10
sed '$d' file.txt              # Delete last line

# Pattern (regex)
sed '/error/d' file.txt        # Delete lines with "error"
sed '/^#/s/^/COMMENT: /' file  # Prefix comments

# Range with pattern
sed '/start/,/end/d' file.txt  # Delete from "start" to "end"
sed '1,/^$/d' file.txt         # From 1 to first empty line

# Step (GNU extension)
sed '1~2d' file.txt            # Delete odd lines (1,3,5...)
sed '0~2d' file.txt            # Delete even lines (2,4,6...)

# Negation
sed '/pattern/!d' file.txt     # Delete lines WITHOUT pattern
                               # (equivalent to grep 'pattern')
```

---

## 3.4 Other Commands

### Deletion (d)

```bash
sed '5d' file.txt              # Delete line 5
sed '1,10d' file.txt           # Lines 1-10
sed '/pattern/d' file.txt      # Lines with pattern
sed '/^$/d' file.txt           # Empty lines
sed '/^#/d' file.txt           # Comments (start with #)
sed '1d;$d' file.txt           # First and last line

> 💡 Over the years, I have found that practical examples beat theory every time.

```

### Printing (p)

```bash
# -n suppresses implicit output
sed -n '5p' file.txt           # Only line 5
sed -n '1,10p' file.txt        # Lines 1-10
sed -n '/pattern/p' file.txt   # Equivalent to grep 'pattern'
sed -n '1p;$p' file.txt        # First and last
```

### Insert and Append

```bash
# i = insert (before)
sed '3i\New text' file.txt     # Insert before line 3
sed '/pattern/i\TEXT' file     # Before lines with pattern
sed '1i\#!/bin/bash' script    # Add shebang

# a = append (after)
sed '3a\New text' file.txt     # Add after line 3
sed '$a\END' file.txt          # Add at end

# c = change (replace the line)
sed '3c\New line' file.txt     # Replace line 3
```

### Transliteration (y)

```bash
# y/source/dest/ - character-by-character replacement (transliterate)
sed 'y/abc/ABC/' file.txt      # a→A, b→B, c→C
sed 'y/aeiou/12345/' file.txt  # vowels → digits
```

---

## 3.5 In-Place Editing

### SUBGOAL 3.5.1: Modify files safely

```bash
# DANGEROUS - without backup
sed -i 's/old/new/g' file.txt

# SAFE - with automatic backup
sed -i.bak 's/old/new/g' file.txt
# Creates file.txt.bak with the original

# Verify first what it would do
sed 's/old/new/g' file.txt | head  # Preview
sed -n 's/old/new/gp' file.txt     # Only modified lines
```

> ⚠️ GOLDEN RULE: Always use `-i.bak` until you are sure the command is correct!

---

## 3.6 Backreferences and &

### & = The Entire Match

```bash
# & in replacement represents the ENTIRE MATCH
sed 's/[0-9]\+/[&]/' file.txt     # puts numbers in []
# "Port 8080" → "Port [8080]"

sed 's/.*/(&)/' file.txt          # puts each line in ()
```

### Backreferences with groups

```bash
# \1, \2, etc. = groups captured with \( \)

# Reverse order
echo "John Smith" | sed 's/\([A-Za-z]*\) \([A-Za-z]*\)/\2, \1/'
# Output: Smith, John

# Duplicate a word
echo "hello" | sed 's/\(.*\)/\1 \1/'
# Output: hello hello

# Extract domain from email
echo "user@example.com" | sed 's/.*@\(.*\)/\1/'
# Output: example.com
```

---

# MODULE 4: AWK - STRUCTURED PROCESSING

## 4.1 Execution Model

### SUBGOAL 4.1.1: Understand pattern { action }

AWK is a programming language for processing structured text.

### Basic syntax

```bash
awk 'pattern { action }' file
awk -F'delimiter' 'program' file
awk -f script.awk file
```

### Execution model

```
┌─────────────────────────────────────────────────────────────┐
│                     AWK EXECUTION MODEL                     │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  1. Execute BEGIN { ... } once                             │
│                                                             │
│  2. For EACH line from input:                              │
│     a) Split the line into fields ($1, $2, ..., $NF)       │
│     b) For each rule 'pattern { action }':                 │
│        - Evaluate pattern                                   │
│        - If TRUE, execute action                           │
│                                                             │
│  3. Execute END { ... } once                               │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## 4.2 Fields and Built-in Variables

### SUBGOAL 4.2.1: Access structured data

### Fields

```bash
$0      # The ENTIRE line
$1      # First field
$2      # Second field
...
$NF     # Last field
$(NF-1) # Second to last field
```

### Built-in Variables

| Variable | Description | Default Value |
|----------|-------------|---------------|
| `NR` | Number of Record - current line number (global) | - |
| `NF` | Number of Fields - fields on current line | - |
| `FS` | Field Separator - input separator | space/tab |
| `OFS` | Output Field Separator | space |
| `RS` | Record Separator - line separator | newline |
| `ORS` | Output Record Separator | newline |
| `FILENAME` | Current file name | - |
| `FNR` | File Number of Record - line number in current file | - |

### Examples

```bash
# Display first column
awk '{ print $1 }' file.txt

# Display last column
awk '{ print $NF }' file.txt
```

> 🔮 **PREDICTION:** If a line has 5 fields, what value does `$NF` have? And if you want the second to last field, what do you use?

```bash
# CSV with comma separator
awk -F',' '{ print $2 }' data.csv

# Multiple separators
awk -F'[,;:]' '{ print $1 }' file.txt

# Setting FS in BEGIN
awk 'BEGIN { FS="," } { print $2 }' data.csv
```

---

## 4.3 Patterns and Conditions

### Types of patterns

```bash
# Regex
awk '/error/' log.txt           # Lines with "error"
awk '/^#/' config.txt           # Lines starting with #
awk '!/^#/' config.txt          # Lines that do NOT start with #

# Comparison
awk '$3 > 100' file.txt         # Column 3 > 100
awk '$1 == "John"' file.txt     # Column 1 is "John"
awk 'NR > 1' file.txt           # Skip header (line 1)
```

> 🔮 **PREDICTION:** For a CSV with header, if you want to count the total records (without header), what is the difference between `NR-1` in `END` and `wc -l | ... - 1`?

```bash
# Range
awk '/start/,/end/' file.txt    # From "start" to "end"
awk 'NR==5,NR==10' file.txt     # Lines 5-10

# Logical combinations
awk '$3 > 100 && $4 < 50' file.txt
awk '$1 == "A" || $1 == "B"' file.txt
awk '!/^#/ && !/^$/' file.txt   # Non-comments and non-empty
```

### BEGIN and END

```bash
# BEGIN - executes BEFORE the first line
# END - executes AFTER the last line

awk 'BEGIN { print "=== REPORT ===" } 
     { print $0 } 
     END { print "=== END ===" }' file.txt

# Count lines (more than wc -l because we see the process)
awk 'END { print "Total:", NR, "lines" }' file.txt

# Calculate average
awk '{ sum += $1 } END { print "Average:", sum/NR }' numbers.txt
```

---

## 4.4 Print and Printf

### SUBGOAL 4.4.1: Format the output

### print - simple

```bash
# With comma - uses OFS (default: space)
awk '{ print $1, $2 }' file.txt

# Without comma - direct concatenation!
awk '{ print $1 $2 }' file.txt    # Pitfall: stuck together!

# With custom separator
awk '{ print $1 " - " $2 }' file.txt
```

> ⚠️ **MAJOR ATTENTION**: `print $1 $2` and `print $1, $2` are DIFFERENT!

### printf - formatted

```bash
awk '{ printf "%-10s %5d\n", $1, $2 }' file.txt

# printf formats:
# %s - string
# %d - integer
# %f - float
# %e - scientific notation
# %-10s - left-aligned string, 10 characters
# %5d - integer, 5 characters (right-aligned)
# %.2f - float with 2 decimals
# %05d - integer with zero padding (00042)
```

### printf examples

```bash
# Formatted table
awk -F',' 'BEGIN { printf "%-15s %10s\n", "Name", "Salary" }
           NR>1  { printf "%-15s $%9d\n", $2, $4 }' employees.csv

# Percentages
awk '{ printf "%s: %.1f%%\n", $1, $2*100 }' ratios.txt
```

---

## 4.5 Variables and Operators

### User-defined variables

```bash
# Implicit declaration (no need to declare)
awk '{ count++ } END { print count }' file.txt

# From command line with -v
awk -v threshold=100 '$3 > threshold' file.txt
awk -v name="John" '$1 == name' file.txt
```

### Operators

```bash
# Arithmetic
+  -  *  /  %  ^

# Comparison
==  !=  <  >  <=  >=

# Regex match
~     # matches regex
!~    # does NOT match regex

# Logical
&&  ||  !

# Increment/Decrement
++  --  +=  -=  *=  /=
```

### Examples

```bash
# Filter with regex
awk '$1 ~ /^192\.168/' log.txt     # IPs from 192.168.*
awk '$2 !~ /error/' log.txt        # Without "error" in column 2

# Arithmetic operations
awk '{ total += $3 * $4 } END { print total }' sales.txt
```

---

## 4.6 Control Structures

### If-Else

```bash
awk '{ 
    if ($3 > 100) 
        print "High:", $1
    else if ($3 > 50) 
        print "Medium:", $1
    else 
        print "Low:", $1 
}' file.txt
```

### Loops

```bash
# Classic for
awk '{ for (i=1; i<=NF; i++) print $i }' file.txt

# While
awk '{ 
    i = 1
    while (i <= NF) { 
        print $i
        i++ 
    } 
}' file.txt

# For-in (for arrays)
awk '{ count[$1]++ } 
     END { for (key in count) print key, count[key] }' file.txt
```

---

## 4.7 Associative Arrays

### SUBGOAL 4.7.1: Aggregate and count data

AWK supports associative arrays (hash maps).

```bash
# Frequency counting
awk '{ count[$1]++ } 
     END { for (k in count) print k, count[k] }' file.txt

# Sums by category
awk -F',' 'NR>1 { sum[$3] += $4 } 
           END { for (dept in sum) print dept, sum[dept] }' employees.csv

# Sort output (with external sort)
awk '{ count[$1]++ } 
     END { for (k in count) print count[k], k }' file.txt | sort -rn
```

---

## 4.8 Built-in Functions

### String Functions

```bash
length(s)              # String length
substr(s, start, len)  # Substring (1-indexed!)
index(s, target)       # Position of target in s (0 if not found)
split(s, arr, sep)     # Split string into array
gsub(regex, repl, s)   # Global replacement, returns number of replacements
sub(regex, repl, s)    # Replace first occurrence
tolower(s)             # Lowercase
toupper(s)             # Uppercase
sprintf(fmt, ...)      # Format into string
```

### Mathematical Functions

```bash
int(x)                 # Integer part
sqrt(x)                # Square root
sin(x), cos(x)         # Trigonometry
exp(x)                 # e^x
log(x)                 # Natural logarithm
rand()                 # Random 0-1
srand(seed)            # Set seed for rand
```

### Examples

```bash
# Uppercase column 1
awk '{ print toupper($1), $2 }' file.txt

# Extract first 3 characters
awk '{ print substr($1, 1, 3) }' file.txt

# Replacement in awk
awk '{ gsub(/old/, "new"); print }' file.txt

# Split string
awk '{ n = split($0, arr, ":"); print arr[1], arr[n] }' /etc/passwd
```

---

# MODULE 5: NANO - SIMPLE TEXT EDITOR

## 5.1 Why Nano?

### Strengths for beginners

| Characteristic | Nano | Vim |
|----------------|------|-----|
| Learning curve | Zero | Steep |
| Visible commands | Yes, in footer | No, must be memorised |
| Modes | No | Yes (normal, insert, visual) |
| Time to productivity | < 1 minute | > 1 hour |

Nano is ideal for:

Specifically: Quick editing of configurations. Small modifications in scripts. And Users who do not need an advanced editor.


---

## 5.2 Essential Commands

### SUBGOAL 5.2.1: Navigate and edit efficiently

> Note: `^` means the **CTRL** key

### Basic commands

| Command | Action |
|---------|--------|
| `^O` | Write Out (Save) |
| `^X` | Exit |
| `^W` | Where Is (Search) |
| `^K` | Cut (Cut current line) |
| `^U` | Uncut/Paste |
| `^G` | Get Help |

### Navigation

| Command | Action |
|---------|--------|
| `^A` | Start of line |
| `^E` | End of line |
| `^Y` | Page up |
| `^V` | Page down |
| `^_` | Go to line (jump to line) |

### Editing

| Command | Action |
|---------|--------|
| `^K` | Cut (cut line) |
| `^U` | Paste |
| `^\` | Replace |
| `^J` | Justify (paragraph alignment) |
| `^T` | Spell check (if installed) |

---

## 5.3 Configuration ~/.nanorc

```bash
# Create or edit ~/.nanorc
nano ~/.nanorc
```

Useful configurations:

```
# Tab size
set tabsize 4

# Auto-indent
set autoindent

# Display line numbers
set linenumbers

# Mouse support
set mouse

# Soft wrap (does not cut lines)
set softwrap

# Syntax highlighting (if available)
include /usr/share/nano/*.nanorc
```

---

## 5.4 Typical Workflow

```bash
# 1. Open the file
nano script.sh

# 2. Edit the content
# - Write directly (no separate insert mode)
# - ^W for search
# - ^\ for replace

# 3. Save
# - ^O (Write Out)
# - Confirm the name (Enter)

# 4. Exit
# - ^X (Exit)
# - If you have unsaved changes, it asks
```

---

# EXTENDED CHEAT SHEET

## Regex Quick Reference

```
METACHARACTERS
─────────────────────────────────────────
.           Any character (one)
^           Start of line
$           End of line
\           Escape
\b          Word boundary
\d          Digit (PCRE only)
\w          Word char (PCRE only)
\s          Whitespace (PCRE only)

CHARACTER CLASSES
─────────────────────────────────────────
[abc]       One of: a, b, c
[^abc]      Anything EXCEPT a, b, c
[a-z]       Range: a to z
[[:alpha:]] POSIX class: letters
[[:digit:]] POSIX class: digits

QUANTIFIERS (ERE)
─────────────────────────────────────────
*           0 or more
+           1 or more
?           0 or 1
{n}         Exactly n
{n,}        n or more
{n,m}       Between n and m

GROUPING (ERE)
─────────────────────────────────────────
(abc)       Group
|           OR (alternative)
\1 \2       Backreference
```

## GREP Quick Reference

```
MAIN OPTIONS
─────────────────────────────────────────
-i          Case insensitive
-v          Invert (does NOT contain)
-n          Display line numbers
-c          Count lines with matches
-o          Only the match
-l          Only file names
-r          Recursive
-E          Extended regex (ERE)
-F          Fixed string (literal)
-w          Whole word
-A N        N lines after
-B N        N lines before
-C N        N lines context
--include=  Only specified files
--exclude=  Exclude files
```

## SED Quick Reference

```
SUBSTITUTION
─────────────────────────────────────────
s/old/new/      First occurrence on line
s/old/new/g     All occurrences
s/old/new/gi    Case-insensitive
s|old|new|g     Different delimiter

ADDRESSING
─────────────────────────────────────────
5               Line 5
1,10            Lines 1-10
$               Last line
/pattern/       Lines with pattern
/start/,/end/   Range
!               Negation

COMMANDS
─────────────────────────────────────────
d               Delete
p               Print
i\text          Insert before
a\text          Append after
c\text          Change (replace)

OPTIONS
─────────────────────────────────────────
-n              Suppress implicit output
-i              In-place (CAUTION!)
-i.bak          In-place with backup
-E              Extended regex
```

## AWK Quick Reference

```
SYNTAX
─────────────────────────────────────────
awk 'pattern { action }' file
awk -F',' '{ print $2 }' file.csv

FIELDS
─────────────────────────────────────────
$0              Entire line
$1, $2, ...     Fields
$NF             Last field
NR              Line number (global)
NF              Number of fields
FNR             Line number in file

PATTERNS
─────────────────────────────────────────
/regex/         Match regex
$1 == "val"     Comparison
$1 > 10         Numeric
NR > 1          Skip header
BEGIN { }       Before input
END { }         After input

PRINT
─────────────────────────────────────────
print $1, $2    With space (OFS)
print $1 $2     Concatenated!
printf "%s %d"  Formatted

FUNCTIONS
─────────────────────────────────────────
length(s)       Length
substr(s,i,n)   Substring
tolower(s)      Lowercase
gsub(r,s,t)     Replace all
split(s,a,sep)  Split into array
```

---

# FREQUENT COMBINATIONS

## Useful Pipelines

```bash
# Top 10 IPs from access log
grep -oE '^[0-9.]+' access.log | sort | uniq -c | sort -rn | head -10

# Clean config file (remove comments and empty lines)
sed '/^#/d; /^$/d' config.txt

# Calculate total from CSV
awk -F',' 'NR>1 { sum += $4 } END { print sum }' data.csv

# Find and replace in all files
grep -rl 'old' . | xargs sed -i 's/old/new/g'

# Employee report per department
awk -F',' 'NR>1 { dept[$3]++; sal[$3]+=$4 } 
    END { for(d in dept) printf "%s: %d employees, average $%.0f\n", d, dept[d], sal[d]/dept[d] }' employees.csv

# Extract unique emails from file
grep -oE '[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}' doc.txt | sort -u

# Source code statistics
find . -name '*.py' -exec wc -l {} + | sort -n

# Real-time log monitoring with filtering
tail -f /var/log/syslog | grep --line-buffered -i error
```

---

*Theoretical material for Seminar 4 of Operating Systems | Bucharest University of Economic Studies - CSIE*
