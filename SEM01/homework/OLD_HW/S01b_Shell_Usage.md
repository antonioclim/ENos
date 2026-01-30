# S01_TC01 - Shell Usage

> Operating Systems | ASE Bucharest - CSIE  
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
- Interact with the shell and execute commands from the command line
- Use simple commands and command sequences for basic tasks
- Understand the role of the kernel, shell and filesystem

---


## 1. Theory

### 1.1 Introduction to Linux

**Linux** is, technically speaking, the system's **kernel** - the central controller of everything that happens on the computer. When someone says they are "running Linux", they usually refer to the kernel together with the suite of tools that come with it (called a distribution).

> UNIX vs Linux: UNIX was developed at AT&T Bell Labs in the 1970s. Linux is not officially UNIX (it has not been certified by the Open Group), but it is UNIX-like - it adopts most UNIX specifications.

### 1.2 The Role of the Kernel

The three main components of an operating system are:

```
┌─────────────────────────────────────────┐
│           APPLICATIONS (User Space)     │
├─────────────────────────────────────────┤
│              SHELL (Bash)               │
├─────────────────────────────────────────┤
│              KERNEL (Linux)             │
├─────────────────────────────────────────┤
│        HARDWARE (CPU, RAM, Disk)        │
└─────────────────────────────────────────┘
```

The kernel functions like an air traffic controller:

- Allocates memory - decides which program receives which piece of memory
- Manages processes - starts and stops programs
- Interprets instructions - from user to hardware
- Preemptive multitasking - rapidly switches between tasks, creating the illusion of simultaneous execution

### 1.3 Applications and Processes

```
Application ──► Request to Kernel ──► Resources (CPU, RAM, Disk)
                    │
                    ▼
              Kernel API
         (hardware abstraction)
```

A process is a task loaded and tracked by the kernel. An application can have multiple processes.

### 1.4 Open Source and Licensing

| Aspect | Closed Source | Open Source |
|--------|---------------|-------------|
| Source code | Hidden | Available |
| Modifications | Forbidden | Permitted |
| Redistribution | Restricted | Free (with conditions) |

GPL (GNU Public License) - the Linux licence - requires that modifications be made public.

### 1.5 Linux Distributions

```
                    LINUX KERNEL
                         │
           ┌─────────────┴─────────────┐
           │                           │
      RED HAT                      DEBIAN
           │                           │
    ┌──────┼──────┐             ┌──────┼──────┐
    │      │      │             │      │      │
  RHEL  Fedora  CentOS      Ubuntu  Mint  Kali
```

| Family | Package Manager | Format | Example command |
|--------|-----------------|--------|-----------------|
| Red Hat | rpm/dnf/yum | `.rpm` | `dnf install htop` |
| Debian | apt/dpkg | `.deb` | `apt install htop` |

---

## 2. The Bash Shell

### 2.1 What is the Shell?

The shell is the interface between the user and the kernel.

> Classroom tip: Think of the shell as a bilingual translator — you speak "human language" (commands), it translates into "machine language" (system calls). And like any translator, it can sometimes interpret things differently... It receives text commands and passes them to the kernel for execution.

```bash
# Standard prompt
user@hostname:~/directory$
    │         │        │      │
    │         │        │      └── $ = normal user, # = root
    │         │        └── Current directory (~ = home)
    │         └── Computer name
    └── Username
```

### 2.2 Types of Shell

| Shell | Description | Config File |
|-------|-------------|-------------|
| **bash** | Bourne Again Shell (default in most distributions) | `~/.bashrc` |
| **sh** | Bourne Shell (original) | `~/.profile` |
| **zsh** | Z Shell (macOS default) | `~/.zshrc` |
| **fish** | Friendly Interactive Shell | `~/.config/fish/` |

```bash
# Check current shell
echo $SHELL

# List available shells
cat /etc/shells
```

### 2.3 Basic Commands

#### Navigation and Information

```bash
# Display current directory
pwd
# Output: /home/student

# List directory contents
ls
ls -la          # long format + hidden files
ls -lh          # human-readable sizes

# Change directory
cd /home        # absolute path
cd ~            # home directory
cd ..           # parent directory
cd -            # previous directory

# System information
uname -a        # all information
hostname        # computer name
whoami          # current user
```

#### File Manipulation

```bash
# Creation
touch file.txt              # create empty file
mkdir directory             # create directory
mkdir -p dir1/dir2/dir3     # create hierarchy

# Copying
cp source.txt destination.txt
cp -r directory/ backup/    # recursive for directories

# Moving/Renaming
mv old.txt new.txt
mv file.txt /another/path/

# Deletion
rm file.txt
rm -r directory/            # recursive
rm -rf directory/           # forced, no confirmation (CAUTION!)

# Viewing content
cat file.txt                # all content
head -n 10 file.txt         # first 10 lines
tail -n 10 file.txt         # last 10 lines
less file.txt               # paginated (q to exit)
```

### 2.4 Getting Help

```bash
# Complete manual
man ls
man bash

# Quick help
ls --help
help cd                     # for built-in commands

# Search in manuals
apropos "copy files"
man -k network

# Command information
type ls                     # alias, built-in or external?
which python                # path to executable
whereis gcc                 # binary, source, man locations
```

Navigation in `man`:

| Key | Action |
|-----|--------|
| `Space` / `Page Down` | Next page |
| `b` / `Page Up` | Previous page |
| `/pattern` | Search pattern |
| `n` | Next match |
| `q` | Exit |

---

## 3. Quoting and Special Characters

### 3.1 Special Characters in Bash

| Character | Meaning |
|-----------|---------|
| `*` | Wildcard - any string of characters |
| `?` | Wildcard - single character |
| `$` | Variable expansion |
| `\` | Escape character |
| `` ` `` | Command substitution (deprecated) |
| `$()` | Command substitution (preferred) |
| `"..."` | Double quotes (allows expansion) |
| `'...'` | Single quotes (literal) |

### 3.2 The Difference Between Quotes

```bash
NAME="Student"

# Single quotes - everything literal
echo 'Hello $NAME'
# Output: Hello $NAME

# Double quotes - allows variable expansion
echo "Hello $NAME"
# Output: Hello Student

# Without quotes - word splitting
echo Hello      $NAME
# Output: Hello Student (multiple spaces are compressed)
```

### 3.3 Escape Character

```bash
# Display special character literally
echo "The price is \$100"
# Output: The price is $100

echo "Line 1\nLine 2"       # \n does not work by default
echo -e "Line 1\nLine 2"    # with -e, interprets escape sequences
```

---

## 4. Environment Variables

### 4.1 Important Variables

```bash
echo $HOME      # /home/student
echo $USER      # student
echo $PATH      # search paths for executables
echo $SHELL     # /bin/bash
echo $PWD       # current directory
echo $?         # exit code of last command (0 = success)
```

### 4.2 Setting Variables

```bash
# Local variable (only in current shell)
MESSAGE="Hello world"
echo $MESSAGE

# Environment variable (inherited by subprocesses)
export JAVA_HOME="/usr/lib/jvm/java-17"

# In a single command
VAR=value command    # VAR exists only for this command
```

---

## 5. Practical Exercises

### Exercise 1: Navigation

```bash
# 1. Display current directory
pwd

# 2. Go to home directory
cd ~

# 3. List all files (including hidden)
ls -la

# 4. Create a working directory
mkdir -p ~/laboratory/tc1a
cd ~/laboratory/tc1a
```

### Exercise 2: File Manipulation

```bash
# 1. Create test files
touch file1.txt file2.txt
echo "Test content" > file3.txt

# 2. Check contents
cat file3.txt
ls -l

# 3. Copy and rename
cp file3.txt backup.txt
mv file1.txt document.txt

# 4. Clean up
rm file2.txt
```

### Exercise 3: System Information

```bash
# 1. Who are you?
whoami
id

# 2. What system are you running?
uname -a
cat /etc/os-release

# 3. How much disk space?
df -h

# 4. How much memory?
free -h
```

### Exercise 4: Man Pages

```bash
# 1. Find the ls option that sorts by date
man ls
# Answer: ls -lt

# 2. How do you copy a directory recursively?
man cp
# Answer: cp -r

# 3. Search for commands related to "password"
apropos password
```

---

## 6. Review Questions

1. What is the difference between kernel and shell?
   > The kernel is the OS core that manages hardware and processes. The shell is the user interface that receives commands and passes them to the kernel.

2. What does the `cd -` command do?
   > Returns to the previous directory (equivalent to "back").

3. What is the difference between `'$HOME'` and `"$HOME"`?
   > Single quotes: displays literal `$HOME`. Double quotes: expands the variable, displays `/home/student`.

4. What does `echo $?` return after a successful command?
   > Returns `0` (zero means success in Unix).

5. How do you find out what type of command `cd` is?
   > `type cd` - will show that it is a "shell builtin".

---

## Cheat Sheet

```bash
# NAVIGATION
pwd                 # current directory
cd DIR              # change directory
cd ~                # home
cd ..               # parent
cd -                # previous

# LISTING
ls                  # list
ls -la              # detailed + hidden
ls -lh              # human readable

# FILES
touch FILE          # create empty
mkdir DIR           # create directory
cp SRC DST          # copy
mv SRC DST          # move/rename
rm FILE             # delete

# VIEWING
cat FILE            # display all
head -n N FILE      # first N lines
tail -n N FILE      # last N lines
less FILE           # paginated

# HELP
man CMD             # manual
CMD --help          # quick help
type CMD            # command type
which CMD           # location

# VARIABLES
echo $VAR           # display variable
export VAR=val      # set env var
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
