# S04_TC01 - Regular Expressions

> **Evidence limit:** local recordings, logs and hashes can support review of a submitted session; they do not prove authorship, uninterrupted capture or the absence of edited/omitted activity. Privacy, retention and assessment consequences remain subject to the approved course policy.

> **Operating Systems** | ASE Bucharest - CSIE  
> Laboratory Material - Seminar 4 (Redistributed)

---

> 🚨 **BEFORE STARTING THE ASSIGNMENT**
>
> 1. Download and configure the `002HWinit` package (see STUDENT_GUIDE_EN.md)
> 2. Open a terminal and navigate to `~/HOMEWORKS`
> 3. Start recording with:
>    ```bash
>    python3 record_homework_tui_EN.py
>    ```
>    or the Bash variant:
>    ```bash
>    ./record_homework_EN.sh
>    ```
> 4. Complete the requested data (name, group, assignment number)
> 5. **ONLY THEN** start solving the requirements below

---

## Objectives

At the end of this laboratory, the student will be able to:
- Understand regular expression syntax
- Use regex in grep, sed, awk
- Distinguish between BRE and ERE
- Construct complex patterns

---


## Dialect and Locale Contract

Examples target GNU grep/sed. `\+`, `\?` and `\|` in BRE and backreferences in
GNU grep ERE are extensions: do not assume the same pattern works in AWK or
another POSIX ERE consumer. `\w`, `\s` and `\b` also work in GNU grep BRE/ERE.
ASCII range/class equivalences below assume `LC_ALL=C`; POSIX class membership
depends on the active locale. See the [main capability table](../../docs/S04_02_MAIN_MATERIAL.md#tool-and-dialect-contract).

## 2. Basic Metacharacters

### 2.1 Special Characters

| Symbol | Meaning | Example | Matches |
|--------|---------|---------|---------|
| `.` | Any character (except newline) | `a.c` | abc, aXc, a1c |
| `^` | Start of line | `^Start` | "Start" at beginning |
| `$` | End of line | `end$` | "end" at end |
| `\` | Escape | `\.` | literal dot |

### 2.2 Basic Examples

```bash
# Any character
grep 'a.c' file.txt         # abc, aXc, a9c

# Start of line
grep '^#' config.txt        # lines starting with #

# End of line
grep 'end$' file.txt        # lines ending with "end"

# Empty line
grep '^$' file.txt          # empty lines

# Escape special characters
grep '192\.168\.1\.1' log   # literal IP (escaped dots)
```

---

## 3. Character Classes

### 3.1 Explicit Sets

```text
[abc]       # one of: a, b, or c
[a-z]       # any lowercase letter
[A-Z]       # any uppercase letter
[0-9]       # any digit
[a-zA-Z]    # any letter
[a-zA-Z0-9] # alphanumeric
[^abc]      # anything EXCEPT a, b, c
[^0-9]      # anything EXCEPT digits
```

### 3.2 POSIX Classes

```text
[[:alpha:]]     # letters [a-zA-Z]
[[:digit:]]     # digits [0-9]
[[:alnum:]]     # alphanumeric [a-zA-Z0-9]
[[:space:]]     # whitespace (space, tab, newline)
[[:lower:]]     # lowercase letters [a-z]
[[:upper:]]     # uppercase letters [A-Z]
[[:punct:]]     # punctuation
[[:blank:]]     # space and tab
[[:print:]]     # printable characters
[[:xdigit:]]    # hexadecimal [0-9A-Fa-f]
```

### 3.3 Examples

```bash
# Only lines with digits
grep '[0-9]' file.txt

# Words starting with uppercase
grep '\b[A-Z][a-z]*\b' file.txt

# Non-alphanumeric characters
grep '[^[:alnum:]]' file.txt
```

---

## 4. Quantifiers

### 4.1 Basic Quantifiers

| BRE | ERE | Meaning |
|-----|-----|---------|
| `*` | `*` | 0 or more |
| `\+` | `+` | 1 or more |
| `\?` | `?` | 0 or 1 |
| `\{n\}` | `{n}` | exactly n |
| `\{n,\}` | `{n,}` | n or more |
| `\{n,m\}` | `{n,m}` | between n and m |

### 4.2 Examples

```bash
# Zero or more
grep 'ab*c' file.txt        # ac, abc, abbc, abbbc...

# One or more (ERE)
grep -E 'ab+c' file.txt     # abc, abbc, abbbc... (NOT ac)

# Zero or one (ERE)
grep -E 'colou?r' file.txt  # color, colour

# Exactly n
grep -E '[0-9]{4}' file.txt # sequences of 4 digits

# Range
grep -E '[0-9]{2,4}' file.txt # 2-4 digits
```

---

## 5. Grouping and Alternation

### 5.1 Grouping

```bash
# BRE - with escape
grep '\(abc\)' file.txt

# ERE - without escape
grep -E '(abc)' file.txt
grep -E '(ab)+' file.txt    # ab, abab, ababab...
```

### 5.2 Alternation (OR)

```bash
# ERE
grep -E 'cat|dog' file.txt          # cat OR dog
grep -E '(error|warning|fatal)' log # any of the 3
grep -E '^(yes|no)$' file.txt       # lines with only "yes" or "no"
```

### 5.3 Backreferences

```bash
# Reference to captured group
# \1 = first group, \2 = second, etc.

# Select entire lines containing duplicate words (use -oE to extract only each pair)
grep -E '\b(\w+)\s+\1\b' file.txt   # "the the", "is is"

# Matching HTML tags
grep -E '<([a-z]+)>.*</\1>' file.html
```

---

## 6. Anchors and Word Boundaries

### 6.1 Anchors

```text
^       # start of line
$       # end of line
\A      # start of string (PCRE)
\Z      # end of string (PCRE)
```

### 6.2 Word Boundaries

```text
\b      # word boundary (start or end of word)
\B      # non-word boundary
\<      # start of word (GNU)
\>      # end of word (GNU)
```

### 6.3 Examples

```bash
# Exact word
grep '\bword\b' file.txt        # "word" but not "password"
grep '\<word\>' file.txt        # equivalent GNU

# At start of word
grep '\bpre' file.txt           # prefix, prepare...

# At end of word
grep 'ing\b' file.txt           # running, jumping...
```

---

## 7. BRE vs ERE - Comparison

| Feature | BRE | ERE |
|---------|-----|-----|
| Quantifier + | `\+` | `+` |
| Quantifier ? | `\?` | `?` |
| Interval {} | `\{n,m\}` | `{n,m}` |
| Grouping () | `\(\)` | `()` |
| Alternation \| | `\|` | `|` |
| Usage | grep, sed | grep -E, awk |

```bash
# Same expression in BRE vs ERE

# BRE
grep 'ab\+c' file.txt
grep '\(abc\)\+' file.txt

# ERE
grep -E 'ab+c' file.txt
grep -E '(abc)+' file.txt
```

---

## 8. Complex Practical Examples

### 8.1 Email Validation (simplified)

```bash
grep -E '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$' emails.txt
```

The email expression is a simplified lexical subset, not RFC-complete validation.

### 8.2 IP Address Validation

```bash
# Shape only; values such as 999.999.999.999 also match.
grep -E '^([0-9]{1,3}\.){3}[0-9]{1,3}$' ips.txt

# Stricter (0-255)
grep -E '^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$' ips.txt
```

### 8.3 Phone Numbers

```bash
# Format: 07XX-XXX-XXX or 07XXXXXXXX
grep -E '07[0-9]{2}(-?[0-9]{3}){2}' phones.txt
```

### 8.4 Dates

```bash
# Shape illustration only: also permits mixed separators and impossible dates; calendar validity requires separate checks
grep -E '[0-3][0-9][/-][0-1][0-9][/-][0-9]{4}' dates.txt
```

### 8.5 URLs

```bash
grep -E 'https?://[a-zA-Z0-9.-]+(/[a-zA-Z0-9./_-]*)?' urls.txt
```

---

## 9. Practical Exercises

### Exercise 1: Basic Patterns
```bash
# Find lines starting with a vowel
grep -E '^[aeiouAEIOU]' file.txt

# Find words of exactly 5 letters
grep -E '\b[a-zA-Z]{5}\b' file.txt

# Find lines with at least 3 consecutive digits
grep -E '[0-9]{3,}' file.txt
```

### Exercise 2: Data Extraction
```bash
# Extract all emails
grep -oE '[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}' document.txt

# Extract all IPs
grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' log.txt
```

---

## Cheat Sheet

```text
# METACHARACTERS
.           any character
^           start of line
$           end of line
\           escape

# CLASSES
[abc]       one from set
[^abc]      none from set
[a-z]       range
[[:alpha:]] POSIX letter

# QUANTIFIERS (ERE)
*           0 or more
+           1 or more
?           0 or 1
{n}         exactly n
{n,m}       between n and m

# GROUPING (ERE)
(abc)       group
|           or
\1          backreference

# ANCHORS
^           start of line
$           end of line
\b          word boundary
\<  \>      GNU word boundaries

# USAGE
grep 'pattern' file           # BRE
grep -E 'pattern' file        # ERE
grep -P 'pattern' file        # PCRE
grep -o 'pattern' file        # match only
grep -i 'pattern' file        # case-insensitive
```

---

## 📤 Completion and Submission

After you have completed all requirements:

1. **Stop recording** by typing:
   ```bash
   STOP_tema
   ```
   or press `Ctrl+D`

2. **Wait** - the script will:
   - Finalise the legacy recorder metadata envelope (not a content signature)
   - Automatically upload the file to the server

3. **Check the final message**:
   - ✅ `UPLOAD SUCCESSFUL!` - the assignment has been submitted
   - ❌ If the upload fails, the `.cast` file is saved locally - submit it manually later with the displayed command

> Keep the original `.cast` as evidence. The distributed recorder envelopes do not
> bind event content and do not authenticate the student. Local preflight exit 0
> establishes format only (`UNVERIFIED` authentication, `UNCONFIRMED` readiness).
> The separate SEM07 `# SIGNATURE:` contract binds a content digest only when it
> verifies with an explicitly supplied key; identity and institutional acceptance
> still require an approved protocol. See the [current recording contract](../../../03_GUIDES/RECORDING_CONTRACT.md)
> and [verification contract](../../../SEM07/homework_evaluation/VERIFICATION_AND_GRADING_CONTRACT.md).

---

*By Revolvix for OPERATING SYSTEMS class | restricted licence 2017-2030*
