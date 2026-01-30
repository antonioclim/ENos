# S01_TC04 - File Globbing and File Management

> **Operating Systems** | ASE Bucharest - CSIE  
> Laboratory Material - Seminar 1 (Redistributed)

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
- Use glob patterns for file selection
- Efficiently manage files and directories
- Understand and use wildcards in commands

---


## 2. Basic Wildcards

### 2.1 Asterisk `*` - Zero or More Characters

```bash
# Matches any string of characters (including empty string)

ls *.txt           # All .txt files
ls doc*            # All files starting with "doc"
ls *backup*        # All files containing "backup"
ls *.tar.gz        # All .tar.gz archives

# Practical examples
cp *.jpg ~/Pictures/
rm *.tmp
mv report* ~/Documents/
```

### 2.2 Question Mark `?` - Exactly One Character

```bash
# Matches exactly one single character (any character)

ls file?.txt       # file1.txt, fileA.txt, but NOT file10.txt
ls ???.txt         # Files with exactly 3 characters before .txt
ls data_??.csv     # data_01.csv, data_AB.csv etc.

# Combinations
ls file?.*         # file1.txt, fileA.doc etc.
```

### 2.3 Square Brackets `[]` - Character Set

```bash
# Matches ONE character from the specified set

ls file[123].txt   # file1.txt, file2.txt, file3.txt
ls file[abc].txt   # filea.txt, fileb.txt, filec.txt

# Character range
ls file[0-9].txt   # file0.txt to file9.txt
ls file[a-z].txt   # filea.txt to filez.txt
ls file[A-Z].txt   # fileA.txt to fileZ.txt
ls file[a-zA-Z].txt # any letter

# Negation with ^ or !
ls file[!0-9].txt  # files that do NOT have a digit
ls file[^abc].txt  # files that do NOT have a, b or c
```

### 2.4 Braces `{}` - Explicit Lists (Brace Expansion)

```bash
# NOT technically a glob, but brace expansion (different!)

echo {a,b,c}           # a b c
echo file{1,2,3}.txt   # file1.txt file2.txt file3.txt

# Sequences
echo {1..5}            # 1 2 3 4 5
echo {a..e}            # a b c d e
echo {01..10}          # 01 02 03 ... 10 (with zero-padding)
echo {1..10..2}        # 1 3 5 7 9 (step of 2)

# Combinations
mkdir dir{1,2,3}       # Creates dir1, dir2, dir3
touch file{A..C}.txt   # Creates fileA.txt, fileB.txt, fileC.txt
```

---

## 3. Extended Patterns (extglob)

For more complex patterns, enable `extglob`:

```bash
# Activation
shopt -s extglob

# Extended patterns
# ?(pattern) - zero or one match
# *(pattern) - zero or more
# +(pattern) - one or more
# @(pattern) - exactly one
# !(pattern) - negation (everything that does NOT match)

ls !(*.txt)           # All files EXCEPT .txt
ls *.@(jpg|png|gif)   # Only images
ls +([0-9]).txt       # Files with only digits in name
```

---

## 4. File Management

### 4.1 Creating Files and Directories

```bash
# Create empty file
touch file.txt
touch file1.txt file2.txt file3.txt

# Create with content
echo "text" > file.txt           # overwrite
echo "added text" >> file.txt    # append

# Create directory
mkdir directory
mkdir -p path/deep/directory     # create complete hierarchy
mkdir dir{1..5}                  # dir1, dir2, dir3, dir4, dir5

# Create complete structure
mkdir -p project/{src,docs,tests}
```

### 4.2 Copying

```bash
# Copy file
cp source.txt destination.txt
cp source.txt /another/path/
cp source.txt /another/path/new_name.txt

# Copy directories (recursive)
cp -r source_dir/ destination_dir/

# Useful options
cp -i source dest      # interactive (confirm overwrite)
cp -v source dest      # verbose (show what it does)
cp -p source dest      # preserve attributes (permissions, timestamp)
cp -a source dest      # archive (preserve all: -dR --preserve=all)

# Multiple copy
cp *.txt backup/
cp file{1,2,3}.txt /destination/
```

### 4.3 Moving and Renaming

```bash
# Renaming
mv old.txt new.txt

# Moving
mv file.txt /another/path/
mv file.txt /another/path/other_name.txt

# Multiple move
mv *.txt documents/
mv file{1..10}.txt archive/

# Options
mv -i source dest    # interactive
mv -v source dest    # verbose
mv -n source dest    # no overwrite (no-clobber)
```

### 4.4 Deletion

```bash
# Delete file
rm file.txt
rm -f file.txt       # forced (no error if doesn't exist)

# Delete directory
rmdir empty_directory   # only if empty
rm -r directory         # recursive (with content)
rm -rf directory        # forced + recursive (DANGEROUS!)

# Safety options
rm -i file.txt       # confirm before deletion
rm -v file.txt       # verbose

# Trap: rm -rf has no undo!
# Recommendation: alias rm='rm -i'
```

### 4.5 Viewing Content

```bash
# Complete display
cat file.txt
cat -n file.txt       # with line numbers

# First/last lines
head file.txt         # first 10 lines (default)
head -n 5 file.txt    # first 5 lines
tail file.txt         # last 10 lines
tail -n 20 file.txt   # last 20 lines
tail -f log.txt       # follow (real-time monitoring)

# Paginated
less file.txt         # navigate with keys
more file.txt         # simpler (forward only)

# Navigation in less:
# Space/Page Down - page down
# b/Page Up - page up
# g - beginning of file
# G - end of file
# /text - search
# n - next match
# q - exit
```

---

## 5. File Information

### 5.1 Detailed `ls` Command

```bash
ls -l    # long format

# Output interpretation:
# -rw-r--r-- 1 user group 4096 Jan 10 12:00 file.txt
# Name
# Modification date
# Size (bytes)
# Group
# Owner
# Number of links
# Others permissions (r--)
# Group permissions (r--)
# Owner permissions (rw-)
# Type: - file, d directory, l link

# Useful options
ls -la       # include hidden files
ls -lh       # human-readable sizes (KB, MB, GB)
ls -lt       # sort by date (newest first)
ls -lS       # sort by size
ls -lR       # recursive
ls -ld dir/  # information about directory, not content
```

### 5.2 Commands for Information

```bash
# File type
file document.pdf     # PDF document...
file script.sh        # Bourne-Again shell script...
file image.jpg        # JPEG image data...

# Size
du -h file.txt        # file size
du -sh directory/     # total directory size
du -ah directory/     # all files in directory

# Disk space
df -h                 # space on all partitions
df -h /home           # space on specified partition

# Statistics
stat file.txt         # complete information
wc file.txt           # lines, words, characters
wc -l file.txt        # lines only
wc -w file.txt        # words only
wc -c file.txt        # bytes only
```

---

## 6. Finding Files

### 6.1 The `find` Command

```bash
# Syntax: find [path] [expressions]

# Search by name
find . -name "*.txt"              # in current directory
find /home -name "*.log"          # in /home
find . -iname "*.TXT"             # case-insensitive

# Search by type
find . -type f                    # files only
find . -type d                    # directories only
find . -type l                    # symbolic links only

# Search by size
find . -size +10M                 # larger than 10MB
find . -size -1k                  # smaller than 1KB
find . -size 100c                 # exactly 100 bytes

# Search by time
find . -mtime -7                  # modified in last 7 days
find . -mtime +30                 # modified more than 30 days ago
find . -mmin -60                  # modified in last hour

# Combinations
find . -name "*.log" -size +1M
find . -type f -name "*.tmp" -mtime +7

# Execute actions
find . -name "*.tmp" -delete                  # delete
find . -name "*.txt" -exec cat {} \;          # execute command
find . -name "*.sh" -exec chmod +x {} \;      # make executable
```

### 6.2 The `locate` Command

```bash
# Fast search in database (needs updating)
locate file.txt
locate "*.pdf"

# Update database
sudo updatedb

# Options
locate -i pattern     # case-insensitive
locate -n 10 pattern  # only first 10 results
```

### 6.3 The `which` and `whereis` Commands

```bash
# Find executables in PATH
which python
which ls

# Find binaries, sources, manuals
whereis python
whereis ls
```

---

## 7. Practical Exercises

### Exercise 1: Basic Wildcards

```bash
# Preparation
mkdir ~/glob_test && cd ~/glob_test
touch file{1..5}.txt file{A..C}.log data_{01..10}.csv

# Exercises
ls *.txt              # all .txt
ls file?.txt          # file1.txt - file5.txt (one character)
ls file[1-3].txt      # file1.txt, file2.txt, file3.txt
ls data_0[1-5].csv    # data_01.csv - data_05.csv
ls *.{txt,log}        # all .txt and .log
```

### Exercise 2: File Management

```bash
# Create project structure
mkdir -p project/{src,docs,tests,build}
touch project/src/main.c
touch project/docs/README.md
touch project/tests/test_{1..3}.c

# Copy and move
cp project/src/main.c project/build/
cp -r project/ project_backup/
mv project/docs/README.md project/

# Verify
ls -R project/
```

### Exercise 3: Searching

```bash
# Find all .txt files in home
find ~ -name "*.txt" -type f

# Find large files (>100MB)
find /var -size +100M 2>/dev/null

# Find files modified today
find . -mtime 0 -type f
```

### Exercise 4: Information

```bash
# Create test file
echo "Line 1" > test.txt
echo "Line 2" >> test.txt
echo "Line 3" >> test.txt

# Analyse
wc test.txt           # lines, words, characters
stat test.txt         # complete information
file test.txt         # file type
ls -lh test.txt       # human-readable size
```

---

## 8. Review Questions

1. **What is the difference between `*` and `?`?**
   > `*` matches zero or more characters, `?` matches exactly one character.

2. **How do you list only .txt and .log files?**
   > `ls *.{txt,log}` or `ls *.txt *.log`

3. **How do you find files larger than 10MB?**
   > `find . -size +10M`

4. **What does `rm -rf` do?**
   > Deletes recursively and forced (no confirmation). VERY dangerous!

5. **How do you copy a directory with all its content?**
   > `cp -r source/ destination/`

---

## Cheat Sheet

```bash
# WILDCARDS
*           # zero or more characters
?           # exactly one character
[abc]       # one character from set
[a-z]       # one character from range
[!abc]      # one character NOT in set
{a,b,c}     # explicit expansion
{1..10}     # numeric sequence

# CREATION
touch file              # empty file
mkdir dir               # directory
mkdir -p a/b/c          # hierarchy

# COPY/MOVE
cp src dst              # copy file
cp -r src/ dst/         # copy directory
mv old new              # move/rename

# DELETION
rm file                 # delete file
rm -r dir               # delete directory
rmdir dir               # delete empty directory

# VIEWING
cat file                # all content
head -n N file          # first N lines
tail -n N file          # last N lines
less file               # paginated

# INFORMATION
ls -la                  # detailed listing
file name               # file type
stat name               # statistics
wc file                 # lines/words/chars
du -sh dir/             # directory size

# SEARCHING
find . -name "*.txt"    # by name
find . -type f          # files only
find . -size +10M       # by size
locate pattern          # fast search
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
