# S04_TC03 - SED - Stream Editor

> **Evidence limit:** local recordings, logs and hashes can support review of a submitted session; they do not prove authorship, uninterrupted capture or the absence of edited/omitted activity. Privacy, retention and assessment consequences remain subject to the approved course policy.

> **Lab observation:** when working with `sed`/`awk`, most "bugs" are actually quoting and escaping issues. Test on a small file first, then scale. And yes, you'll almost certainly forget a backslash on your first attempt 🙂
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
- Edit text streams with sed
- Use substitution and deletion
- Apply commands to specific lines
- Automate text modifications

---


## 2. The Substitution Command (s)

### 2.1 Syntax

```text
s/pattern/replacement/flags

# Flags
# g - global (all occurrences per line)
# i - case-insensitive
# p - print modified line
# w file - write to file
# N - replace the Nth occurrence
```

### 2.2 Basic Examples

```bash
# First occurrence on each line
sed 's/old/new/' file.txt

# All occurrences (global)
sed 's/old/new/g' file.txt

# Case-insensitive
sed 's/old/new/gi' file.txt

# Second occurrence
sed 's/old/new/2' file.txt

# From second occurrence onwards
sed 's/old/new/2g' file.txt
```

### 2.3 Alternative Delimiters

```bash
# When the pattern contains /
sed 's|/usr/local|/opt|g' paths.txt
sed 's#http://#https://#g' urls.txt
sed 's@old@new@g' file.txt
```

### 2.4 Backreferences

```bash
# \1, \2... refer to groups captured with \( \)

# Swap words
sed 's/\([a-z]*\) \([a-z]*\)/\2 \1/' file.txt

# Add prefix/suffix
sed 's/\(.*\)/[\1]/' file.txt           # [line]
sed 's/^/PREFIX: /' file.txt            # PREFIX: line
sed 's/$/ :SUFFIX/' file.txt            # line :SUFFIX

# & = the entire match
sed 's/[0-9][0-9]*/(&)/' file.txt        # wraps the first nonempty digit sequence
```

---

## 3. Addressing (Line Selection)

### 3.1 Address Types

```bash
# Line number
sed '5s/old/new/' file.txt              # only line 5
sed '1,10s/old/new/' file.txt           # lines 1-10
sed '$s/old/new/' file.txt              # last line

# Pattern
sed '/error/s/old/new/' file.txt        # lines with "error"
sed '/^#/d' file.txt                    # delete comments

# Range
sed '/start/,/end/s/old/new/' file.txt  # from start to end
sed '1,/^$/d' file.txt                  # from 1 to first empty line

# Step
sed '1~2s/old/new/' file.txt            # odd lines (1,3,5...)
sed '0~2s/old/new/' file.txt            # even lines (2,4,6...)

# Negation
sed '/pattern/!s/old/new/' file.txt     # lines WITHOUT pattern
```

---

## 4. Other Commands

### 4.1 Delete (d)

```bash
sed '5d' file.txt                       # delete line 5
sed '1,10d' file.txt                    # lines 1-10
sed '/pattern/d' file.txt               # lines with pattern
sed '/^$/d' file.txt                    # empty lines
sed '/^#/d' file.txt                    # comments
sed '1d;$d' file.txt                    # first and last line
```

### 4.2 Print (p)

```bash
sed -n '5p' file.txt                    # only line 5
sed -n '1,10p' file.txt                 # lines 1-10
sed -n '/pattern/p' file.txt            # lines with pattern
sed -n '1p;$p' file.txt                 # first and last
```

### 4.3 Insert and Append

```bash
# i = insert (before)
sed '3i\New text' file.txt              # insert before line 3
sed '/pattern/i\Text' file.txt          # before lines with pattern

# a = append (after)
sed '3a\New text' file.txt              # add after line 3
sed '$a\Last line' file.txt             # add at end

# c = change (replace line)
sed '3c\New line' file.txt              # replace line 3
```

### 4.4 Transform (y)

```bash
# y/source/dest/ - transliterate (character by character)
sed 'y/abc/ABC/' file.txt               # a→A, b→B, c→C
sed 'y/aeiou/12345/' file.txt           # vowels → digits
```

---

## 5. Multiple Commands

```bash
# With -e
sed -e 's/a/A/g' -e 's/b/B/g' file.txt

# With ; (separator)
sed 's/a/A/g; s/b/B/g' file.txt

# With newline (in script or quotes)
sed '
s/a/A/g
s/b/B/g
/pattern/d
' file.txt

# From file
sed -f commands.sed file.txt
```

---

A backup suffix may overwrite an existing `.bak` file; use a fresh owned fixture
or check for collisions before `sed -i.bak`. GNU-only forms here include step
addresses, case modifiers and extended BRE operators.

## 6. Important Options

```text
-n      # Suppress implicit output (use with p)
-i      # In-place editing (modifies the file)
-i.bak  # In-place with backup
-e      # Multiple expressions
-f      # Read commands from file
-r/-E   # Extended regex (ERE)
```

---

## 7. Practical Examples

### 7.1 Configuration Processing

```bash
# Delete comments and empty lines
sed '/^#/d; /^$/d' config.txt

# Change a setting value
sed 's/^PORT=.*/PORT=8080/' config.txt

# Comment out a line
sed '/DEBUG/s/^/#/' config.txt

# Uncomment
sed 's/^#\(DEBUG.*\)/\1/' config.txt
```

### 7.2 Text Cleanup

```bash
# Delete leading spaces
sed 's/^[ \t]*//' file.txt

# Delete trailing spaces
sed 's/[ \t]*$//' file.txt

# Delete empty lines
sed '/^$/d' file.txt

# Compress multiple empty lines
sed '/./,/^$/!d' file.txt  # keep at most one blank line after a nonempty run; drop leading blanks

# Remove excess whitespace
sed 's/  */ /g' file.txt
```

### 7.3 Transformations

```bash
# DOS to Unix (remove CR)
sed 's/\r$//' file.txt

# Normalise text records to CRLF (GNU sed); use a byte-level tool if preserving an unterminated final line is required
sed 's/\r$//; s/$/\r/' file.txt

# Lowercase to Uppercase (first letter)
sed 's/^\(.\)/\U\1/' file.txt
```

---

## Cheat Sheet

```text
# SUBSTITUTION
s/old/new/          first occurrence
s/old/new/g         all
s/old/new/gi        case-insensitive
s|old|new|          alternative delimiter

# ADDRESSING
5                   line 5
1,10                lines 1-10
$                   last line
/pattern/           lines with pattern
/start/,/end/       range
!                   negation

# COMMANDS
d                   delete
p                   print
i\text              insert before
a\text              append after
c\text              replace line
y/abc/ABC/          transliterate

# OPTIONS
-n                  suppress output
-i                  in-place
-i.bak              with backup
-e                  multiple commands
-r/-E               extended regex

# BACKREFERENCES
\( \)               grouping
\1, \2...           reference
&                   entire match
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
