# Visual Cheat Sheet: Text Processing
## Quick Reference - Regex, GREP, SED, AWK, NANO

> **Operating Systems** | Bucharest University of Economic Studies - CSIE  
> **Seminar 4** | Quick Reference Card  
> **Format**: Multi-section quick reference. Check pagination in the chosen renderer; no single-A4-page claim.

---

```
╔══════════════════════════════════════════════════════════════════════════╗
║                                                                          ║
║   ████████╗███████╗██╗  ██╗████████╗    ██████╗ ██████╗  ██████╗        ║
║   ╚══██╔══╝██╔════╝╚██╗██╔╝╚══██╔══╝    ██╔══██╗██╔══██╗██╔═══██╗       ║
║      ██║   █████╗   ╚███╔╝    ██║       ██████╔╝██████╔╝██║   ██║       ║
║      ██║   ██╔══╝   ██╔██╗    ██║       ██╔═══╝ ██╔══██╗██║   ██║       ║
║      ██║   ███████╗██╔╝ ██╗   ██║       ██║     ██║  ██║╚██████╔╝       ║
║      ╚═╝   ╚══════╝╚═╝  ╚═╝   ╚═╝       ╚═╝     ╚═╝  ╚═╝ ╚═════╝        ║
║                                                                          ║
║                    CHEAT SHEET - SEMINAR 4                              ║
║                                                                          ║
╚══════════════════════════════════════════════════════════════════════════╝
```

---

# REGEX - REGULAR EXPRESSIONS

## Basic Metacharacters

```
┌────────────┬────────────────────────────────────┬────────────────────────┐
│ Symbol     │ Meaning                            │ Example                │
├────────────┼────────────────────────────────────┼────────────────────────┤
│     .      │ Any character (exactly 1)          │ a.c → abc, a1c, aXc   │
│     ^      │ Beginning of line                  │ ^Hello → "Hello..."   │
│     $      │ End of line                        │ end$ → "...end"       │
│     *      │ 0 or more (preceding)              │ ab*c → ac, abc, abbc  │
│     \      │ Escape special character           │ \. → literal dot      │
│    [ ]     │ Character set                      │ [aeiou] → vowels      │
│   [^ ]     │ Set negation                       │ [^0-9] → non-digits   │
└────────────┴────────────────────────────────────┴────────────────────────┘
```

## BRE vs ERE - CRITICAL DIFFERENCES

This table targets GNU grep. BRE `\+`, `\?`, `\|` are GNU extensions; GNU grep
ERE backreferences are not portable AWK ERE. GNU grep supports `\w`, `\s` and
`\b` in BRE/ERE; `\d` and lazy quantifiers need its PCRE mode when available.

```
┌──────────────────┬───────────────────┬───────────────────┐
│ Function         │ BRE (grep)        │ ERE (grep -E)     │
├──────────────────┼───────────────────┼───────────────────┤
│ 1 or more        │      \+           │       +           │
│ 0 or 1           │      \?           │       ?           │
│ Exactly n        │    \{n\}          │      {n}          │
│ Range n-m        │   \{n,m\}         │     {n,m}         │
│ Grouping         │    \( \)          │      ( )          │
│ Alternative      │      \|           │       |           │
└──────────────────┴───────────────────┴───────────────────┘

💡 RECOMMENDATION: Always use grep -E to avoid escaping!


```

## Quantifiers

```
┌────────────┬────────────────────────────────────┬────────────────────────┐
│ Pattern    │ Meaning                            │ Example                │
├────────────┼────────────────────────────────────┼────────────────────────┤
│    *       │ 0 or more                          │ a* → "", a, aa, aaa   │
│    +       │ 1 or more (ERE)                    │ a+ → a, aa, aaa       │
│    ?       │ 0 or 1 (ERE)                       │ colou?r → color/colour│
│   {n}      │ Exactly n                          │ a{3} → aaa            │
│  {n,}      │ Minimum n                          │ a{2,} → aa, aaa, ...  │
│  {n,m}     │ Between n and m                    │ a{2,4} → aa, aaa, aaaa│
└────────────┴────────────────────────────────────┴────────────────────────┘
```

## POSIX Character Classes

The ASCII equivalences below assume `LC_ALL=C`. POSIX class membership depends
on locale; these are not universal Unicode equivalences.

```
┌────────────────┬────────────────────────────────┬──────────────────────┐
│ Class          │ Equivalent                     │ Description          │
├────────────────┼────────────────────────────────┼──────────────────────┤
│ [[:alpha:]]    │ [a-zA-Z]                       │ Letters              │
│ [[:digit:]]    │ [0-9]                          │ Digits               │
│ [[:alnum:]]    │ [a-zA-Z0-9]                    │ Alphanumeric         │
│ [[:space:]]    │ [ \t\n\r\f\v]                  │ Whitespace           │
│ [[:upper:]]    │ [A-Z]                          │ Uppercase            │
│ [[:lower:]]    │ [a-z]                          │ Lowercase            │
│ [[:punct:]]    │ Punctuation                    │ .,;:!? etc.          │
└────────────────┴────────────────────────────────┴──────────────────────┘
```

## Common Patterns

These extract lexical shapes, not complete email/URL/IP/date validity. Use anchors
for a whole-line requirement and separate octet/calendar/grammar validation.

```bash


# IP Address (basic)
grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' file.txt

# Email (simplified)
grep -oE '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}' file.txt

# URL
grep -oE 'https?://[A-Za-z0-9./?=_-]+' file.txt

# Date (DD/MM/YYYY)
grep -oE '[0-9]{2}/[0-9]{2}/[0-9]{4}' file.txt

# MAC Address
grep -oE '([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}' file.txt
```

*Personal note: I prefer Bash scripts for simple automations and Python when the logic becomes complex. It is a matter of pragmatism.*


---

# GREP - TEXT SEARCH

## Essential Options

```
┌────────┬────────────────────────────────────────────────────────────────┐
│ Option │ Description                                                    │
├────────┼────────────────────────────────────────────────────────────────┤
│   -i   │ Case-insensitive                                               │
│   -v   │ Invert match (lines that do NOT match)                         │
│   -c   │ Count only (number of matching lines)                          │
│   -n   │ Show line numbers                                              │
│   -l   │ Show only file names with matches                              │
│   -L   │ Show only file names WITHOUT matches                           │
│   -r   │ Recursive (all files in directories)                           │
│   -o   │ Show only the matched portion                                  │
│   -E   │ Extended regex (ERE) — RECOMMENDED                             │
│   -w   │ Match whole words only                                         │
│   -A n │ Show n lines AFTER match                                       │
│   -B n │ Show n lines BEFORE match                                      │
│   -C n │ Show n lines of context (before and after)                     │
│   -h   │ Suppress filename (when searching multiple files)              │
│   -q   │ Quiet mode (for scripts — exit code only)                      │
└────────┴────────────────────────────────────────────────────────────────┘
```

## Practical Examples

```bash
# Search case-insensitive
grep -i 'error' log.txt

# Count matching lines
grep -c 'ERROR' log.txt

# Search recursively in all .py files
grep -rn 'def ' --include='*.py' .

# Lines containing "error" but NOT "debug"
grep 'error' log.txt | grep -v 'debug'

# Context: 2 lines before and after
grep -C 2 'CRITICAL' log.txt

# Extract only IP addresses
grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' access.log
```

---

# SED - STREAM EDITOR

## Basic Syntax

```
sed [options] 'command' file
sed [options] 's/pattern/replacement/flags' file
```

## Common Commands

```
┌─────────┬────────────────────────────────────────────────────────────────┐
│ Command │ Description                                                    │
├─────────┼────────────────────────────────────────────────────────────────┤
│    s    │ Substitute: s/old/new/                                         │
│    d    │ Delete line                                                    │
│    p    │ Print line (used with -n)                                      │
│    i    │ Insert BEFORE line                                             │
│    a    │ Append AFTER line                                              │
│    c    │ Replace entire line                                            │
│    y    │ Transliterate characters (like tr)                             │
│    q    │ Quit (stop processing)                                         │
└─────────┴────────────────────────────────────────────────────────────────┘
```

## Substitution Flags

```
┌──────┬─────────────────────────────────────────────────────────────────┐
│ Flag │ Description                                                     │
├──────┼─────────────────────────────────────────────────────────────────┤
│  g   │ Global (all occurrences on line)                                │
│  i   │ Case-insensitive (GNU sed)                                      │
│  p   │ Print if substitution made                                      │
│  w   │ Write to file                                                   │
│  n   │ Replace only nth occurrence                                     │
└──────┴─────────────────────────────────────────────────────────────────┘
```

## Practical Examples

```bash
# Simple replacement
sed 's/old/new/' file.txt

# Replace ALL occurrences
sed 's/old/new/g' file.txt

# In-place editing (CAREFUL!)
sed -i 's/old/new/g' file.txt

# Delete lines containing "debug"
sed '/debug/d' log.txt

# Delete empty lines
sed '/^$/d' file.txt

# Delete comments (lines starting with #)
sed '/^#/d' config.txt

# Print only lines 10-20
sed -n '10,20p' file.txt

# Replace with backreferences
sed -E 's/([0-9]+)-([0-9]+)/\2-\1/g' file.txt
```

---

# AWK - STRUCTURED PROCESSING

## Basic Syntax

```
awk [options] 'pattern {action}' file
awk -F'delimiter' 'pattern {action}' file
```

## Special Variables

```
┌──────────┬────────────────────────────────────────────────────────────┐
│ Variable │ Description                                                │
├──────────┼────────────────────────────────────────────────────────────┤
│   $0     │ Entire line                                                │
│   $1-$n  │ Fields 1 to n                                              │
│   NF     │ Number of Fields (on current line)                         │
│   NR     │ Record Number (line number, global)                        │
│   FNR    │ Record Number in current file                              │
│   FS     │ Field Separator (default: space)                           │
│   OFS    │ Output Field Separator                                     │
│   RS     │ Record Separator (default: newline)                        │
│   ORS    │ Output Record Separator                                    │
│ FILENAME │ Name of current file                                       │
└──────────┴────────────────────────────────────────────────────────────┘
```

## Program Structure

```awk
BEGIN { 
    # Runs BEFORE processing any lines
    FS = ","  # Set field separator
}

/pattern/ { 
    # Runs for lines matching pattern
    print $1, $2 
}

{ 
    # Runs for EVERY line
    sum += $3 
}

END { 
    # Runs AFTER all lines are processed
    print "Total:", sum 
}
```

The `-F,` examples below use simple unquoted records, one header and numeric
fields. They do not parse quoted commas or multiline CSV.

## Practical Examples

```bash
# Print column 2
awk '{print $2}' file.txt

# CSV: print columns 1 and 3
awk -F, '{print $1, $3}' data.csv

# Sum column 3 (skip header)
awk -F, 'NR > 1 {sum += $3} END {print sum}' data.csv

# Average
awk -F, 'NR > 1 {sum += $3; count++} END {if(count) print sum/count; else print "undefined (0 records)"}' data.csv

# Filter: salary > 5000
awk -F, 'NR>1 && $4 ~ /^[0-9]+$/ && $4 > 5000 {print $2, $4}' employees.csv

# Count per group
awk -F, 'NR > 1 {count[$3]++} END {for (k in count) print k, count[k]}' data.csv

# Custom output format
awk -F, 'NR > 1 {printf "%-20s %8.2f\n", $2, $4}' employees.csv
```

---

# NANO - SIMPLE EDITOR

Nano 7.x also has Ctrl+S (Save) and Ctrl+T (Execute menu). Inspect the installed
help for version/configuration differences; availability is not guaranteed.

## Essential Shortcuts

```
┌──────────────┬─────────────────────────────────────────────────────────┐
│ Shortcut     │ Action                                                  │
├──────────────┼─────────────────────────────────────────────────────────┤
│ Ctrl+O       │ Save (Write Out)                                        │
│ Ctrl+X       │ Exit                                                    │
│ Ctrl+K       │ Cut line                                                │
│ Ctrl+U       │ Paste                                                   │
│ Ctrl+W       │ Search                                                  │
│ Ctrl+\       │ Search and Replace                                      │
│ Ctrl+G       │ Help                                                    │
│ Ctrl+_       │ Go to line                                              │
│ Alt+U        │ Undo                                                    │
│ Alt+E        │ Redo                                                    │
│ Ctrl+C       │ Show cursor position                                    │
└──────────────┴─────────────────────────────────────────────────────────┘
```

---

# QUICK DECISION GUIDE

```
┌─────────────────────────────────────────────────────────────────────────┐
│  WHAT DO YOU WANT TO DO?              │  WHAT DO YOU USE?               │
├────────────────────────────────────┼────────────────────────────────────┤
│ Search text                        │ grep                               │
│ Extract patterns                   │ grep -o                            │
│ Replace text                       │ sed s///                           │
│ Delete lines                       │ sed d or grep -v                   │
│ Process columns                    │ awk                                │
│ Calculations and aggregations      │ awk                                │
│ Complex transformations            │ awk                                │
│ Quick file edit                    │ nano                               │
│ One-time search/replace            │ sed                                │
└────────────────────────────────────┴────────────────────────────────────┘
```

---

```
╔══════════════════════════════════════════════════════════════════════════╗
║                                                                          ║
║     "With grep you search, with sed you transform, with awk you analyse."║
║                                                                          ║
║                        — Operating Systems, ASE-CSIE                     ║
║                                                                          ║
╚══════════════════════════════════════════════════════════════════════════╝
```

---

*Cheat Sheet for Operating Systems Seminar 4 | ASE Bucharest - CSIE*


## Retained Author Notes

*(`grep` is probably the command I use most frequently. Simple, fast, efficient.)*
