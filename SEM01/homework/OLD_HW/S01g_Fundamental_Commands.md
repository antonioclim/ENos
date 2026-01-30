# S01_TC06 - Fundamental Commands for Files and Directories

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
- Use fundamental commands for navigation and file management
- Obtain help and documentation for commands
- Understand the Linux filesystem hierarchy

---


## 2. Navigation Commands

### 2.1 pwd - Print Working Directory

```bash
# Display full path of current directory
pwd
# Output: /home/student/documents

# Options
pwd -L    # logical path (with symlinks)
pwd -P    # physical path (without symlinks)
```

### 2.2 cd - Change Directory

```bash
# Basic navigation
cd /home/student      # absolute path
cd documents          # relative path
cd ..                 # parent directory
cd ../..              # two levels up
cd ~                  # home directory (equivalent to $HOME)
cd                    # also home directory
cd -                  # previous directory (toggle)

# Practical examples
cd ~/Downloads        # to Downloads
cd /var/log           # to system logs
cd "Directory with spaces"  # directory with spaces in name
```

### 2.3 ls - List

```bash
# Basic usage
ls                    # list current directory
ls /etc               # list /etc
ls -l                 # long format (details)
ls -a                 # include hidden files (.)
ls -la                # common combination

# Useful options
ls -lh                # human-readable sizes
ls -lt                # sort by date (recent first)
ls -lS                # sort by size
ls -lR                # recursive
ls -ld directory/     # info about directory (not content)
ls -1                 # one file per line
ls --color=auto       # with colours

# Interpreting ls -l output
# drwxr-xr-x 2 user group 4096 Jan 10 12:00 dirname
# Name
# Modification date
# Size
# Group
# Owner
# Number of links
# Others permissions
# Group permissions
# Owner permissions
# Type (d=dir, -=file, l=link)
```

---

## 3. File Commands

### 3.1 cat - Concatenate

```bash
# Display content
cat file.txt
cat file1.txt file2.txt    # concatenate multiple

# Options
cat -n file.txt            # with line numbers
cat -b file.txt            # numbers only for non-empty lines
cat -A file.txt            # show special characters
cat -s file.txt            # compress multiple empty lines

# Create file (Ctrl+D to finish)
cat > new.txt
text here
^D

# Append to file
cat >> existing.txt
added text
^D
```

### 3.2 head and tail

```bash
# head - first lines
head file.txt               # first 10 lines (default)
head -n 5 file.txt          # first 5 lines
head -c 100 file.txt        # first 100 bytes

# tail - last lines
tail file.txt               # last 10 lines
tail -n 20 file.txt         # last 20 lines
tail -f logfile.log         # follow (live monitoring)
tail -F logfile.log         # follow + retry if rotated

# Combinations
head -n 20 file.txt | tail -n 5   # lines 16-20
```

### 3.3 less and more

```bash
# less - paginated viewing (preferred)
less file.txt

# Navigation in less:
# Space/PgDown - page down
# b/PgUp - page up
# g - to beginning
# G - to end
# /pattern - search forward
# ?pattern - search backward
# n - next match
# N - previous match
# q - exit
# h - help

# Useful options
less -N file.txt            # with line numbers
less -S file.txt            # don't wrap long lines
less +G file.txt            # start at end
less +/pattern file.txt     # start at pattern

# more - simpler (forward only)
more file.txt
```

---

## 4. Directory Commands

### 4.1 mkdir - Make Directory

```bash
# Create directory
mkdir directory_name
mkdir dir1 dir2 dir3          # multiple at once

# Create hierarchy
mkdir -p path/deep/directory
mkdir -p project/{src,docs,tests,build}

# With specific permissions
mkdir -m 700 private_directory

# Verbose
mkdir -v directory            # show what it creates
```

### 4.2 rmdir - Remove Directory

```bash
# Delete EMPTY directory
rmdir empty_directory
rmdir -p a/b/c                # delete hierarchy (only if empty)

# For directories with content, use rm -r
```

### 4.3 Copying Directories

```bash
# cp with -r option (recursive)
cp -r source/ destination/

# Important options
cp -a source/ dest/           # archive (preserve all)
cp -v source/ dest/           # verbose
cp -i source/ dest/           # interactive
```

---

## 5. Getting Help

### 5.1 man - Manual Pages

```bash
# Syntax
man [section] command

# Examples
man ls
man 5 passwd                  # section 5 (config files)
man -k keyword                # search in descriptions
man -f command                # equivalent to whatis

# Manual sections
# 1 - User commands
# 2 - System calls
# 3 - Library functions
# 4 - Special files
# 5 - Config file formats
# 6 - Games
# 7 - Miscellaneous
# 8 - Administrator commands
```

### 5.2 help and --help

```bash
# For built-in commands
help cd
help echo

# For external commands
ls --help
cp --help

# Difference: type shows if built-in or external
type cd                       # cd is a shell builtin
type ls                       # ls is /usr/bin/ls
```

### 5.3 info and apropos

```bash
# info - detailed documentation (GNU format)
info coreutils
info ls

# apropos - search in manual descriptions
apropos "copy files"
apropos network
# equivalent to: man -k "pattern"

# whatis - short description
whatis ls
whatis cat cp mv
```

---

## 6. Informative Commands

### 6.1 file - File Type

```bash
file document.pdf             # PDF document
file script.sh                # Bourne-Again shell script
file image.jpg                # JPEG image data
file /bin/ls                  # ELF 64-bit executable
file directory/               # directory
```

### 6.2 stat - File Statistics

```bash
stat file.txt

# Output includes:
# - Size
# - Blocks allocated
# - Device
# - Inode
# - Links
# - Permissions (octal and symbolic)
# - UID/GID
# - Timestamps: Access, Modify, Change, Birth
```

### 6.3 du - Disk Usage

```bash
du file.txt                   # file size
du -h file.txt                # human-readable
du -s directory/              # total only (summary)
du -sh directory/             # total human-readable
du -ah directory/             # all files
du -sh */ | sort -h           # directories sorted by size
```

### 6.4 df - Disk Free

```bash
df                            # space on all partitions
df -h                         # human-readable
df -h /home                   # only for /home
df -i                         # inodes (not bytes)
df -T                         # include filesystem type
```

---

## 7. Other Useful Commands

### 7.1 touch

```bash
# Create empty file
touch file.txt

# Update timestamp
touch -a file.txt             # only access time
touch -m file.txt             # only modification time
touch -t 202401151200 f.txt   # set specific timestamp
```

### 7.2 echo

```bash
echo "simple text"
echo -n "without newline at end"
echo -e "with\ttab\tand\nnewline"
echo $VARIABLE
echo "Hello $USER"
echo 'Literal $USER'          # does not expand
```

### 7.3 wc - Word Count

```bash
wc file.txt                   # lines words bytes
wc -l file.txt                # lines only
wc -w file.txt                # words only
wc -c file.txt                # bytes only
wc -m file.txt                # characters only
wc -L file.txt                # length of longest line

# For multiple files
wc -l *.txt                   # lines in each + total
```

---

## 8. Practical Exercises

### Exercise 1: System Navigation

```bash
# 1. Explore hierarchy
cd /
ls -la
cd etc
pwd

# 2. Explore home
cd ~
ls -la
cd ..
pwd
```

### Exercise 2: File Information

```bash
# 1. Create test files
echo "Line 1" > test.txt
echo "Line 2" >> test.txt
echo "Line 3" >> test.txt

# 2. Analyse
cat test.txt
wc test.txt
stat test.txt
file test.txt
```

### Exercise 3: Documentation

```bash
# 1. Learn about ls
man ls
# Find the option for sorting by size

# 2. Search for "network" commands
apropos network

# 3. Check command type
type cd
type ls
type echo
```

### Exercise 4: Create Project Structure

```bash
# Create complete structure
mkdir -p ~/project/{src,include,docs,tests,build}
touch ~/project/src/main.c
touch ~/project/include/header.h
touch ~/project/docs/README.md
touch ~/project/Makefile

# Verify
ls -R ~/project
du -sh ~/project
```

---

## 9. Review Questions

1. **What does the `/etc` directory contain?**
   > System configuration files.

2. **What is the difference between `cat` and `less`?**
   > `cat` displays all content directly, `less` offers paginated navigation.

3. **How do you find out a file's type?**
   > With the command `file filename`.

4. **What does `man -k pattern` do?**
   > Searches for pattern in manual descriptions (equivalent to `apropos`).

5. **How do you create a directory hierarchy in a single command?**
   > `mkdir -p path/deep/directory`

---

## Cheat Sheet

```bash
# NAVIGATION
pwd                 # current directory
cd DIR              # change directory
cd ~                # home
cd -                # previous
ls -la              # detailed listing

# VIEWING
cat file            # complete content
head -n N file      # first N lines
tail -n N file      # last N lines
tail -f file        # live monitoring
less file           # paginated

# INFORMATION
file name           # file type
stat name           # complete statistics
du -sh dir/         # directory size
df -h               # disk space
wc file             # lines/words/chars

# HELP
man CMD             # manual
CMD --help          # quick help
type CMD            # command type
apropos pattern     # search in manuals
whatis CMD          # short description

# DIRECTORIES
mkdir dir           # create
mkdir -p a/b/c      # create hierarchy
rmdir dir           # delete (empty)

# MISCELLANEOUS
touch file          # create/update
echo "text"         # display text
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
