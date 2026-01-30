# S02_TC04 - Text Filters in Linux

> **Operating Systems** | ASE Bucharest - CSIE  
> Laboratory Material - Seminar 2 (Redistributed)

---

> 🚨 **BEFORE STARTING THIS ASSIGNMENT**
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

> **Practical Tip**: `sort | uniq -c | sort -rn` is my favourite combo for quick analysis. I use it almost daily to see what's happening in logs. Memorise it!

By the end of this laboratory, the student will be able to:
- Use filtering commands for text processing
- Combine filters in efficient pipelines
- Process and transform data from files

---


## 2. sort - Sorting

Sorts lines alphabetically or numerically.

```bash
# Alphabetic sorting (default)
sort file.txt

# Numeric sorting
sort -n numbers.txt

# Descending order
sort -r file.txt
sort -rn numbers.txt            # numeric descending

# Sort by column
sort -k2 file.txt               # by column 2
sort -k2,2 file.txt             # only column 2
sort -t',' -k3 -n data.csv      # CSV, column 3, numeric

# Other useful options
sort -u file.txt                # remove duplicates (unique)
sort -f file.txt                # ignore case
sort -h sizes.txt               # human-readable (1K, 2M, 3G)

# Practical examples
ls -l | sort -k5 -n             # sort by size
du -h * | sort -h               # sort human sizes
```

---

## 3. uniq - Unique Lines

Removes or reports **consecutive** duplicate lines.

> ⚠️ Important: Works only on consecutive lines! Typically used after `sort`.

```bash
# Remove consecutive duplicates
uniq file.txt
sort file.txt | uniq            # remove ALL duplicates

# Count occurrences
sort file.txt | uniq -c         # prefix with occurrence count

# Show only duplicates
sort file.txt | uniq -d         # only lines that repeat

# Show only unique lines
sort file.txt | uniq -u         # only lines that appear once

# Ignore case
sort -f file.txt | uniq -i

# Practical examples
# Top 10 most frequent lines
sort access.log | uniq -c | sort -rn | head -10
```

---

## 4. cut - Column Extraction

Extracts sections from each line.

```bash
# By delimiter (-d) and field (-f)
cut -d':' -f1 /etc/passwd               # first field
cut -d':' -f1,3 /etc/passwd             # fields 1 and 3
cut -d':' -f1-3 /etc/passwd             # fields 1 to 3
cut -d',' -f2 data.csv                  # column 2 from CSV

# By character position (-c)
cut -c1-10 file.txt                     # characters 1-10
cut -c5- file.txt                       # from character 5 to end
cut -c-5 file.txt                       # first 5 characters

# By bytes (-b)
cut -b1-10 file.txt

# Practical examples
# Extract usernames
cut -d':' -f1 /etc/passwd

# First column from ps output
ps aux | cut -c1-10
```

---

## 5. paste - Column Merging

Merges lines from multiple files, column by column.

```bash
# Default merge (tab)
paste file1.txt file2.txt

# Custom delimiter
paste -d',' file1.txt file2.txt
paste -d':' file1 file2 file3

# Serialise (all on one line)
paste -s file.txt
paste -sd',' file.txt               # with comma

# Practical examples
# Create CSV from two files
paste -d',' names.txt ages.txt > people.csv
```

---

## 6. tr - Translate/Delete

Translates or deletes characters.

```bash
# Replace characters
tr 'a-z' 'A-Z' < file.txt           # lowercase → uppercase
tr 'A-Z' 'a-z' < file.txt           # uppercase → lowercase
tr ':' ',' < file.txt               # replace : with ,
echo "hello" | tr 'aeiou' '12345'   # h1ll4

# Delete characters (-d)
tr -d '0-9' < file.txt              # delete all digits
tr -d '\n' < file.txt               # delete newlines
tr -d '[:space:]' < file.txt        # delete all whitespace

# Squeeze repeated characters (-s)
tr -s ' ' < file.txt                # multiple spaces → single
tr -s '\n' < file.txt               # multiple empty lines → one

# Complement (-c)
tr -cd '0-9\n' < file.txt           # keep ONLY digits and newline
tr -cd '[:print:]' < file.txt       # keep only printable

# Character classes
# [:alnum:] [:alpha:] [:digit:] [:lower:] [:upper:]
# [:space:] [:punct:] [:print:] [:cntrl:]

# Practical examples
echo "Hello World" | tr 'A-Z' 'a-z'
cat messy.txt | tr -s ' \t' ' '     # normalise whitespace
```

---

## 7. wc - Word Count

Counts lines, words and bytes.

```bash
# All statistics
wc file.txt                         # lines words bytes name

# Specific options
wc -l file.txt                      # lines only
wc -w file.txt                      # words only
wc -c file.txt                      # bytes only
wc -m file.txt                      # characters only
wc -L file.txt                      # length of longest line

# Multiple files
wc -l *.txt                         # each + total

# In pipeline
cat access.log | grep "404" | wc -l
ps aux | wc -l                      # process count
```

---

## 8. head and tail

### head - Beginning of File

```bash
head file.txt                       # first 10 lines
head -n 5 file.txt                  # first 5 lines
head -n -5 file.txt                 # all EXCEPT last 5
head -c 100 file.txt                # first 100 bytes
```

### tail - End of File

```bash
tail file.txt                       # last 10 lines
tail -n 20 file.txt                 # last 20 lines
tail -n +5 file.txt                 # from line 5 to end
tail -c 100 file.txt                # last 100 bytes

# Real-time monitoring
tail -f log.txt                     # follow - wait for new lines
tail -F log.txt                     # follow + retry on rotation
```

### Combinations

```bash
# Lines 15-20
head -n 20 file.txt | tail -n 6

# Line 10
sed -n '10p' file.txt
head -n 10 file.txt | tail -n 1
```

---

## 9. tee - Stream Duplication

Writes to stdout AND to file(s) simultaneously.

```bash
# Save output and display
ls -la | tee list.txt

# Append instead of overwrite
ls -la | tee -a list.txt

# Multiple files
command | tee file1.txt file2.txt

# In the middle of pipeline
cat data.txt | sort | tee sorted.txt | uniq -c > counts.txt

# Debugging pipeline
cat data | filter1 | tee step1.txt | filter2 | tee step2.txt > final.txt
```

---

## 10. nl - Line Numbering

```bash
# Basic numbering
nl file.txt

# Number format
nl -n ln file.txt                   # left-aligned
nl -n rn file.txt                   # right-aligned
nl -n rz file.txt                   # with leading zeros

# Number field width
nl -w 3 file.txt                    # 3 characters for number

# Which lines to number
nl -b a file.txt                    # all lines
nl -b t file.txt                    # only non-empty (default)
```

---

## 11. Practical Exercises

### Exercise 1: Sorting and Uniqueness

```bash
# Create test file
cat > colours.txt << 'EOF'
red
green
blue
red
yellow
green
red
EOF

# Sort and remove duplicates
sort colours.txt | uniq

# Count occurrences
sort colours.txt | uniq -c | sort -rn
```

### Exercise 2: CSV Processing

```bash
# Create test CSV
cat > students.csv << 'EOF'
name,age,grade
Ana,21,9
Ion,22,7
Maria,20,10
Andrei,21,8
EOF

# Extract names (column 1)
cut -d',' -f1 students.csv | tail -n +2

# Sort by grade
tail -n +2 students.csv | sort -t',' -k3 -rn

# Average age... (more complex, with awk)
```

### Exercise 3: Complete Pipeline

```bash
# Log analysis: top 10 IPs
cat access.log | cut -d' ' -f1 | sort | uniq -c | sort -rn | head -10

# Processing /etc/passwd
cut -d':' -f1,3 /etc/passwd | sort -t':' -k2 -n | tail -10
```

### Exercise 4: Text Transformation

```bash
# Normalise whitespace
echo "text   with   multiple    spaces" | tr -s ' '

# Lowercase everything
cat mixed_case.txt | tr 'A-Z' 'a-z'

# Delete non-alphanumeric characters
echo "Text123!@#Special" | tr -cd '[:alnum:]\n'
```

---

## 12. Review Questions

1. **Why must we use `sort` before `uniq`?**
   > `uniq` removes only **consecutive** duplicates. `sort` groups identical lines together.

2. **How do you extract column 3 from a CSV file?**
   > `cut -d',' -f3 file.csv`

3. **How do you transform all letters to uppercase?**
   > `tr 'a-z' 'A-Z' < file.txt`

4. **What does `tail -f` do?**
   > Monitors the file in real-time, displaying new lines as they appear.

5. **How do you number only non-empty lines?**
   > `nl -b t file.txt` (default behaviour).

---

## Cheat Sheet

```bash
# SORTING
sort file               # alphabetic
sort -n file            # numeric
sort -r file            # descending
sort -k2 file           # by column 2
sort -t',' -k3 file     # comma delimiter

# UNIQUENESS
sort | uniq             # remove duplicates
sort | uniq -c          # count occurrences
sort | uniq -d          # only duplicates

# EXTRACTION
cut -d':' -f1 file      # field 1, delimiter :
cut -c1-10 file         # characters 1-10

# MERGING
paste file1 file2       # columns
paste -d',' f1 f2       # with delimiter

# TRANSFORMATION
tr 'a-z' 'A-Z'          # lowercase → uppercase
tr -d '0-9'             # delete digits
tr -s ' '               # squeeze spaces

# COUNTING
wc -l file              # lines
wc -w file              # words
wc -c file              # bytes

# HEAD/TAIL
head -n N file          # first N
tail -n N file          # last N
tail -f file            # monitor

# MISCELLANEOUS
tee file                # duplicate stream
nl file                 # line numbering
```

---

## 📤 Submission and Finalisation

After completing all requirements:

1. **Stop the recording** by typing:
   ```bash
   STOP_homework
   ```
   or press `Ctrl+D`

2. **Wait** - the script will:
   - Generate the cryptographic signature
   - Automatically upload the file to the server

3. **Check the final message**:
   - ✅ `UPLOAD SUCCESSFUL!` - the assignment was submitted
   - ❌ If upload fails, the `.cast` file is saved locally - submit it manually later with the displayed command

> ⚠️ **DO NOT modify the `.cast` file** after generation - the signature becomes invalid!

---

*By Revolvix for OPERATING SYSTEMS class | restricted licence 2017-2030*
