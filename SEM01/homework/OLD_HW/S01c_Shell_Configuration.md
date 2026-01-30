# S01_TC02 - Shell Configuration (Variables)

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
- Configure and customise the Bash shell
- Work with environment variables and local variables
- Understand shell configuration files
- Create simple aliases and functions

---


## 2. Important Environment Variables

### 2.1 PATH

**PATH** contains the directories where the shell searches for executables.

```bash
# View PATH
echo $PATH
# /usr/local/bin:/usr/bin:/bin:/usr/local/games:/usr/games

# Find where a command is
which python3
whereis ls

# Add directory to PATH
export PATH="$PATH:/home/student/bin"

# Add to the beginning of PATH (higher priority)
export PATH="/home/student/bin:$PATH"
```

### 2.2 HOME, USER, SHELL

```bash
echo "Home: $HOME"        # /home/student
echo "User: $USER"        # student  
echo "Shell: $SHELL"      # /bin/bash
echo "Hostname: $HOSTNAME"
echo "PWD: $PWD"          # current directory
echo "OLDPWD: $OLDPWD"    # previous directory (for cd -)
```

### 2.3 Variables for Applications

```bash
# Default editor
export EDITOR="nano"
export VISUAL="code"

# Localisation
export LANG="en_GB.UTF-8"
export LC_ALL="en_GB.UTF-8"

# Java
export JAVA_HOME="/usr/lib/jvm/java-17-openjdk"
export PATH="$JAVA_HOME/bin:$PATH"

# Python
export PYTHONPATH="/home/student/lib/python"
```

---

## 3. Configuration Files

### 3.1 Loading Order

```
LOGIN SHELL (ssh, login):
┌─────────────────┐
│  /etc/profile   │ ← Global for all users
└────────┬────────┘
         ▼
┌─────────────────┐
│  ~/.bash_profile│ ← Personal (or ~/.bash_login or ~/.profile)
└────────┬────────┘
         ▼
┌─────────────────┐
│  ~/.bashrc      │ ← Usually sourced from .bash_profile
└─────────────────┘

NON-LOGIN SHELL (new terminal):
┌─────────────────┐
│  ~/.bashrc      │ ← Only this file
└─────────────────┘
```

### 3.2 ~/.bashrc

```bash
# Edit .bashrc
nano ~/.bashrc

# Typical ~/.bashrc content:

#
# ALIASES
#
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias grep='grep --color=auto'
alias df='df -h'
alias free='free -h'

#
# ENVIRONMENT VARIABLES
#
export EDITOR="nano"
export HISTSIZE=10000
export HISTFILESIZE=20000

#
# CUSTOM PATH
#
export PATH="$HOME/bin:$HOME/.local/bin:$PATH"

#
# CUSTOM PROMPT
#
PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '

# After modification, apply changes:
source ~/.bashrc
# or
. ~/.bashrc
```

### 3.3 ~/.bash_profile

```bash
# Typical ~/.bash_profile content:

# Load .bashrc if it exists
if [ -f ~/.bashrc ]; then
    source ~/.bashrc
fi

# Login-specific variables
export DISPLAY=:0
```

---

## 4. Aliases

### 4.1 Defining Aliases

```bash
# Syntax
alias name='command'

# Useful examples
alias ll='ls -la'
alias la='ls -A'
alias l='ls -CF'
alias cls='clear'
alias h='history'
alias grep='grep --color=auto'

# Safety aliases (confirm before deletion)
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# Aliases for frequent directories
alias cdp='cd ~/projects'
alias cdd='cd ~/Downloads'

# View all aliases
alias

# Delete an alias
unalias ll
```

### 4.2 Advanced Aliases

```bash
# Alias with arguments? Does NOT work directly
# Use functions instead:

# Function for mkdir + cd
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Function for extracting archives
extract() {
    case "$1" in
        *.tar.gz)  tar xzf "$1" ;;
        *.tar.bz2) tar xjf "$1" ;;
        *.zip)     unzip "$1" ;;
        *.gz)      gunzip "$1" ;;
        *.tar)     tar xf "$1" ;;
        *)         echo "Unknown format: $1" ;;
    esac
}
```

---

## 5. Prompt Customisation (PS1)

### 5.1 Special Sequences

| Sequence | Meaning |
|----------|---------|
| `\u` | Username |
| `\h` | Hostname (short) |
| `\H` | Hostname (full) |
| `\w` | Current directory (full path) |
| `\W` | Current directory (name only) |
| `\d` | Date |
| `\t` | Time (HH:MM:SS) |
| `\n` | New line |
| `\$` | `$` for user, `#` for root |

### 5.2 ANSI Colours

```bash
# Format: \[\033[CODEm\]TEXT\[\033[00m\]

# Colour codes
# 30-37: text (black, red, green, yellow, blue, magenta, cyan, white)
# 40-47: background
# 0: reset, 1: bold

# Examples
PS1='\[\033[01;32m\]\u\[\033[00m\]@\[\033[01;34m\]\h\[\033[00m\]:\w\$ '
# green bold reset blue reset

# Simple coloured prompt
export PS1='\[\e[32m\]\u@\h:\[\e[34m\]\w\[\e[0m\]\$ '

# Prompt with emoji (if terminal supports it)
export PS1='🐧 \u@\h:\w\$ '
```

### 5.3 Prompt Examples

```bash
# Minimal
PS1='\$ '

# Standard Ubuntu
PS1='\u@\h:\w\$ '

# With colours
PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '

# With date and time
PS1='[\d \t] \u@\h:\w\$ '

# On two lines
PS1='\u@\h:\w\n\$ '
```

---

## 6. Variable Expansion

### 6.1 Basic Syntax

```bash
NAME="Ana"

# Simple expansion
echo $NAME
echo ${NAME}    # equivalent, but clearer

# Concatenation (${} required)
echo "${NAME}_backup"    # Ana_backup
echo "$NAME_backup"      # error - looks for NAME_backup variable
```

### 6.2 Default Values

```bash
# ${VAR:-default} - use default if VAR does not exist or is empty
echo ${UNDEFINED:-"default value"}

# ${VAR:=default} - set VAR to default if it does not exist
echo ${DIRECTORY:="/tmp"}
echo $DIRECTORY    # /tmp

# ${VAR:+something} - use "something" only if VAR exists and is not empty
EXISTS="yes"
echo ${EXISTS:+"variable exists"}       # "variable exists"
echo ${NONEXISTENT:+"variable exists"}  # nothing
```

### 6.3 String Manipulation

```bash
TEXT="Hello World"

# Length
echo ${#TEXT}    # 11

# Substring
echo ${TEXT:0:5}     # Hello (from position 0, 5 characters)
echo ${TEXT:6}       # World (from position 6 to end)

# Replacement
FILE="document.txt"
echo ${FILE%.txt}        # document (remove .txt from end)
echo ${FILE##*.}         # txt (keep only extension)
echo ${FILE/txt/pdf}     # document.pdf (replace first match)
echo ${FILE//o/0}        # d0cument.txt (replace all)
```

---

## 7. Practical Exercises

### Exercise 1: Basic Variables

```bash
# 1. Create local variables
FIRST_NAME="John"
LAST_NAME="Smith"
AGE=22

# 2. Display them
echo "Full name: $FIRST_NAME $LAST_NAME"
echo "Age: $AGE years"

# 3. Concatenation
FULL_NAME="$FIRST_NAME $LAST_NAME"
echo $FULL_NAME
```

### Exercise 2: Environment Variables

```bash
# 1. Check current variables
echo "Home: $HOME"
echo "User: $USER"
echo "Path: $PATH"

# 2. Create an environment variable
export PROJECT="OS_Lab"

# 3. Verify in subshell
bash -c 'echo "Project: $PROJECT"'

# 4. Add directory to PATH
export PATH="$PATH:$HOME/scripts"
```

### Exercise 3: Configuring .bashrc

```bash
# 1. Back up .bashrc
cp ~/.bashrc ~/.bashrc.backup

# 2. Add aliases
echo "alias ll='ls -la'" >> ~/.bashrc
echo "alias cls='clear'" >> ~/.bashrc

# 3. Apply changes
source ~/.bashrc

# 4. Test
ll
```

### Exercise 4: Custom Prompt

```bash
# 1. Save current prompt
OLD_PS1=$PS1

# 2. Test a new prompt
PS1='[\t] \u:\W\$ '

# 3. Test with colours
PS1='\[\e[32m\]\u\[\e[0m\]:\[\e[34m\]\W\[\e[0m\]\$ '

# 4. Restore original
PS1=$OLD_PS1
```

---

## 8. Review Questions

1. **What is the difference between a local and an environment variable?**
   > A local variable exists only in the current shell. An environment variable (export) is inherited by subprocesses.

2. **Which file is executed when opening a new terminal?**
   > `~/.bashrc` for non-login shells (graphical terminals).

3. **How do you permanently add a directory to PATH?**
   > Add `export PATH="$PATH:/directory"` to `~/.bashrc`.

4. **What does `$?` return after a failed command?**
   > A number different from zero (the specific error code).

5. **How do you make an alias permanent?**
   > Add it to `~/.bashrc` and run `source ~/.bashrc`.

---

## Cheat Sheet

```bash
# VARIABLES
VAR="value"             # local
export VAR="value"      # environment
unset VAR               # delete
echo $VAR               # display

# SPECIAL VARIABLES
$?    # exit code of last command
$$    # PID of current shell
$!    # PID of last background process
$0    # script name
$1-$9 # parameters

# SYSTEM VARIABLES
$HOME     # home directory
$USER     # username
$PATH     # executable paths
$PWD      # current directory
$SHELL    # current shell

# ALIAS
alias name='command'
unalias name
alias                   # list all

# CONFIGURATION
~/.bashrc              # shell config
~/.bash_profile        # login config
source ~/.bashrc       # reload config

# EXPANSION
${VAR:-default}        # default value
${#VAR}                # string length
${VAR:0:5}             # substring
${VAR%.ext}            # remove suffix
${VAR/old/new}         # replace
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
