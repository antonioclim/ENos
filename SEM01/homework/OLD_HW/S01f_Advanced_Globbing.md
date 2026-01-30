# S01_TC05 - Introduction to Globbing

> **Operating Systems** | ASE Bucharest - CSIE  
> Laboratory Material - Seminar 1 (MOVED from SEM02)

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
> 4. Fill in the required details (name, group, assignment number)
> 5. **ONLY THEN** begin solving the requirements below

---

## Objectives

At the end of this laboratory, the student will be able to:
- Understand and use advanced glob patterns
- Efficiently select multiple files with wildcards
- Combine different types of patterns

---


## 2. Fundamental Wildcards

### 2.1 Asterisk (`*`)

Matches **zero or more** characters.

```bash
# Examples
ls *              # all files
ls *.txt          # files ending in .txt
ls doc*           # files starting with "doc"
ls *backup*       # files containing "backup"
ls *.tar.gz       # files with double extension

# Complex patterns
ls pro*.txt       # starts with "pro", ends with ".txt"
ls *2024*         # contains "2024" anywhere
```

### 2.2 Question Mark (`?`)

Matches **exactly one** character.

```bash
# Examples
ls file?.txt      # file1.txt, fileA.txt (NOT file10.txt)
ls ???.txt        # exactly 3 characters before .txt
ls data_??.csv    # data_01.csv, data_AB.csv

# Difference * vs ?
ls file*          # file, file1, file12, fileABC, etc.
ls file?          # only file + 1 character
ls file??         # only file + 2 characters
```

### 2.3 Square Brackets (`[]`)

Matches **one character** from the specified set.

```bash
# Explicit set
ls file[123].txt       # file1.txt, file2.txt, file3.txt
ls file[abc].txt       # filea.txt, fileb.txt, filec.txt

# Character range
ls file[0-9].txt       # file0.txt ... file9.txt
ls file[a-z].txt       # filea.txt ... filez.txt
ls file[A-Z].txt       # fileA.txt ... fileZ.txt
ls file[a-zA-Z].txt    # any letter
ls file[0-9a-f].txt    # digit or lowercase hexadecimal

# Negation with ! or ^
ls file[!0-9].txt      # NOT digit
ls file[^abc].txt      # NOT a, b or c
ls file[!a-z].txt      # NOT lowercase letter
```

### 2.4 POSIX Character Classes

```bash
# Syntax: [[:class:]]
ls file[[:digit:]].txt      # equivalent to [0-9]
ls file[[:alpha:]].txt      # [a-zA-Z]
ls file[[:alnum:]].txt      # [a-zA-Z0-9]
ls file[[:lower:]].txt      # [a-z]
ls file[[:upper:]].txt      # [A-Z]
ls file[[:space:]].txt      # spaces, tabs
ls file[[:punct:]].txt      # punctuation
```

---

## 3. Brace Expansion (`{}`)

> ⚠️ Note: Brace expansion is NOT glob! It is a different mechanism.

```bash
# Explicit lists
echo {a,b,c}              # a b c
echo file{1,2,3}.txt      # file1.txt file2.txt file3.txt

# Numeric sequences
echo {1..5}               # 1 2 3 4 5
echo {01..10}             # 01 02 03 04 05 06 07 08 09 10
echo {5..1}               # 5 4 3 2 1 (descending)
echo {1..10..2}           # 1 3 5 7 9 (step of 2)

# Alphabetic sequences
echo {a..e}               # a b c d e
echo {A..Z}               # entire uppercase alphabet

# Combinations
echo file{A,B}{1,2}       # fileA1 fileA2 fileB1 fileB2
mkdir -p proj/{src,doc,test}
touch log.{txt,bak,old}
```

**Difference between glob and brace expansion:**

| Aspect | Glob (`*`) | Brace (`{}`) |
|--------|-----------|--------------|
| Matching | Existing files | String generation |
| When | After parsing | Before glob |
| Result | Only files found | All combinations |

---

## 4. Extended Globbing (extglob)

Advanced patterns available with the `extglob` option.

```bash
# Activation
shopt -s extglob

# Extended patterns
?(pattern)      # zero or one match
*(pattern)      # zero or more
+(pattern)      # one or more
@(pattern)      # exactly one
!(pattern)      # negation (NOT)

# Examples
ls !(*.txt)               # everything EXCEPT .txt
ls *.@(jpg|png|gif)       # only images
ls +([0-9]).txt           # files with only digits in name
ls ?(.)bashrc             # .bashrc or bashrc

# Complex combinations
ls !(*.bak|*.tmp|*.log)   # exclude multiple extensions
ls @(data|info)_*.txt     # starts with "data_" or "info_"
```

---

## 5. Special Behaviours

### 5.1 Hidden Files (dotfiles)

```bash
# * does NOT match files starting with .
ls *              # does not include .bashrc, .profile etc.
ls .*             # ONLY hidden files
ls .* *           # all (hidden + normal)

# With dotglob enabled
shopt -s dotglob
ls *              # includes hidden files too
```

### 5.2 Nullglob and Failglob

```bash
# Default behaviour: pattern remains literal if no match
ls *.xyz          # if none exist, looks for literal "*.xyz"

# nullglob: expands to nothing if no match
shopt -s nullglob
ls *.xyz          # returns nothing (no error)

# failglob: error if no match
shopt -s failglob
ls *.xyz          # error: no match
```

### 5.3 Globstar (recursive)

```bash
# Activation
shopt -s globstar

# ** matches recursively all subdirectories
ls **/*.txt       # all .txt from any subdirectory
ls **/main.c      # main.c anywhere in hierarchy
cp **/*.log backup/
```

---

## 6. Practical Exercises

### Exercise 1: Prepare Test Files

```bash
# Create test structure
mkdir -p ~/glob_lab
cd ~/glob_lab

# Create various files
touch file{1..5}.txt
touch data_{a..c}.csv
touch report_{01..10}.pdf
touch .hidden_{1..3}
touch image.{jpg,png,gif,bmp}
touch backup_{2023,2024}_{jan,feb,mar}.tar.gz
```

### Exercise 2: Basic Patterns

```bash
# List only .txt files
ls *.txt

# List files with a single character before .txt
ls ?????.txt

# List files data_a.csv, data_b.csv, data_c.csv
ls data_[a-c].csv

# List reports with odd numbers
ls report_0[13579].pdf
```

### Exercise 3: Brace Expansion

```bash
# Create directories for a project
mkdir -p project/{src,include,lib,bin,doc}

# Create files for multiple months
touch log_{jan,feb,mar,apr}_{2023,2024}.txt

# Backup sequence
touch backup_{001..100}.bak
```

### Exercise 4: Extended Glob

```bash
# Enable extglob
shopt -s extglob

# List everything EXCEPT .txt files
ls !(*.txt)

# List only images
ls *.@(jpg|png|gif)

# List files with only digits in name
ls +([0-9]).*
```

---

## 7. Practical Cases

### 7.1 Selective Backup

```bash
# Copy all source files
cp *.{c,h} backup/

# Copy everything except temporary files
shopt -s extglob
cp !(*.tmp|*.bak) backup/
```

### 7.2 Selective Deletion

```bash
# Delete all temporary files
rm -f *.tmp *.bak *.swp

# Delete everything EXCEPT .txt
shopt -s extglob
rm !(*.txt)
```

### 7.3 Batch Processing

```bash
# Rename extensions
for f in *.jpeg; do
    mv "$f" "${f%.jpeg}.jpg"
done

# Process all images
for img in *.{jpg,png,gif}; do
    echo "Processing: $img"
done
```

---

## 8. Review Questions

1. **What is the difference between `*` and `?`?**
   > `*` matches zero or more characters, `?` exactly one character.

2. **How do you list all files that are NOT .txt?**
   > With extglob: `ls !(*.txt)` or `ls *.[!t][!x][!t]` (imprecise).

3. **What does `echo {1..5..2}` do?**
   > Displays: `1 3 5` (from 1 to 5, step 2).

4. **Why does `ls *` not show hidden files?**
   > `*` does not match files starting with `.` (dotfiles) by default.

5. **How do you enable recursive glob with `**`?**
   > `shopt -s globstar`.

---

## Cheat Sheet

```bash
# WILDCARDS
*               # zero or more characters
?               # exactly one character
[abc]           # one from set
[a-z]           # range
[!abc]          # negation
[[:digit:]]     # POSIX class

# BRACE EXPANSION
{a,b,c}         # list
{1..10}         # sequence
{01..10}        # with padding
{1..10..2}      # with step

# EXTENDED GLOB (shopt -s extglob)
?(pattern)      # zero or one
*(pattern)      # zero or more
+(pattern)      # one or more
@(pattern)      # exactly one
!(pattern)      # NOT

# SHELL OPTIONS
shopt -s extglob      # extended glob
shopt -s globstar     # ** recursive
shopt -s dotglob      # include dotfiles
shopt -s nullglob     # expand to nothing
shopt -s failglob     # error if no match

# USEFUL COMBINATIONS
*.{txt,log}           # .txt and .log
*.[ch]                # .c and .h
file[0-9][0-9]        # file00-file99
!(*.bak|*.tmp)        # exclude multiple
**/*.txt              # recursive
```

---

## 📤 Finalisation and Submission

After completing all requirements:

1. **Stop recording** by typing:
   ```bash
   STOP_assignment
   ```
   or press `Ctrl+D`

2. **Wait** - the script will:
   - Generate the cryptographic signature
   - Automatically upload the file to the server

3. **Check the final message**:
   - ✅ `UPLOAD SUCCESSFUL!` - the assignment has been submitted
   - ❌ If the upload fails, the `.cast` file is saved locally - send it manually later with the displayed command

> ⚠️ **DO NOT modify the `.cast` file** after generation - the signature becomes invalid!

---

*By Revolvix for OPERATING SYSTEMS class | restricted licence 2017-2030*
