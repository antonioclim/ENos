# S01_TC03 - Shell Variables

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
- Create and use variables in Bash scripts
- Understand the difference between local and environment variables
- Use special variables and parameters

---


## 2. Environment Variables

### 2.1 export

```bash
# Local variable (current shell only)
LOCAL_VAR="local"

# Environment variable (inherited by subprocesses)
export ENV_VAR="exported"

# Verification
bash -c 'echo "Local: $LOCAL_VAR"'      # empty
bash -c 'echo "Env: $ENV_VAR"'          # "exported"

# Export in same command
export PATH="$PATH:/new/directory"
```

### 2.2 Important Environment Variables

```bash
echo $HOME          # /home/student
echo $USER          # student
echo $PATH          # executable paths
echo $PWD           # current directory
echo $OLDPWD        # previous directory
echo $SHELL         # /bin/bash
echo $LANG          # en_GB.UTF-8
echo $TERM          # terminal type
echo $EDITOR        # default editor
```

---

## 3. Special Variables

| Variable | Description |
|----------|-------------|
| `$?` | Exit code of last command |
| `$$` | PID of current shell |
| `$!` | PID of last background process |
| `$0` | Script name |
| `$1-$9` | Positional parameters |
| `${10}` | Parameter 10+ |
| `$#` | Number of parameters |
| `$@` | All parameters (as list) |
| `$*` | All parameters (as string) |

```bash
#!/bin/bash
echo "Script: $0"
echo "First argument: $1"
echo "Second: $2"
echo "Number of arguments: $#"
echo "All: $@"

# Run: ./script.sh arg1 arg2 arg3
```

---

## 4. Substitution and Manipulation

### 4.1 Default Values

```bash
# ${VAR:-default} - use default if VAR is not set
echo ${UNDEFINED:-"default value"}

# ${VAR:=default} - set AND use default
echo ${DIRECTORY:="/tmp"}
echo $DIRECTORY           # /tmp

# ${VAR:+something} - use something only if VAR is set
FILE="test.txt"
echo ${FILE:+"file exists"}

# ${VAR:?message} - error if VAR is not set
echo ${REQUIRED:?"Variable is missing!"}
```

### 4.2 String Manipulation

```bash
TEXT="Hello World"

# Length
echo ${#TEXT}               # 11

# Substring
echo ${TEXT:0:5}            # Hello
echo ${TEXT:6}              # World
echo ${TEXT: -3}            # rld (last 3, space required)

# Replacement
FILE="document.txt"
echo ${FILE%.txt}           # document (remove .txt from end)
echo ${FILE##*.}            # txt (extension)
echo ${FILE/txt/pdf}        # document.pdf (first match)
echo ${FILE//o/0}           # d0cument.txt (all)

# Patterns
# ${var#pattern} - remove shortest match from beginning
# ${var##pattern} - remove longest match from beginning
# ${var%pattern} - remove shortest match from end
# ${var%%pattern} - remove longest match from end
```

### 4.3 Case Modifications (Bash 4+)

```bash
TEXT="Hello World"

echo ${TEXT^^}              # HELLO WORLD (uppercase)
echo ${TEXT,,}              # hello world (lowercase)
echo ${TEXT^}               # Hello world (first letter)
```

---

## 5. Arrays

### 5.1 Indexed Array

```bash
# Definition
COLOURS=("red" "green" "blue")
NUMBERS=(1 2 3 4 5)

# Access
echo ${COLOURS[0]}          # red
echo ${COLOURS[1]}          # green
echo ${COLOURS[@]}          # all elements
echo ${#COLOURS[@]}         # number of elements (3)

# Adding
COLOURS+=("yellow")

# Iteration
for colour in "${COLOURS[@]}"; do
    echo "$colour"
done
```

### 5.2 Associative Array (Bash 4+)

```bash
# Declaration required
declare -A CAPITAL

# Population
CAPITAL["Romania"]="Bucharest"
CAPITAL["France"]="Paris"
CAPITAL["Germany"]="Berlin"

# Access
echo ${CAPITAL["Romania"]}

# All keys
echo ${!CAPITAL[@]}

# Iteration
for country in "${!CAPITAL[@]}"; do
    echo "$country: ${CAPITAL[$country]}"
done
```

---

## 6. Reading Input

```bash
# Basic read
echo "What is your name?"
read NAME
echo "Hello, $NAME!"

# With prompt (-p)
read -p "Age: " AGE

# Silent (for passwords) (-s)
read -sp "Password: " PASSWORD
echo

# With timeout (-t)
read -t 5 -p "Answer in 5 seconds: " ANSWER

# Into an array (-a)
read -a ELEMENTS <<< "one two three"
echo ${ELEMENTS[1]}         # two

# Multiple variables
read VAR1 VAR2 VAR3 <<< "a b c"
```

---

## 7. Practical Exercises

### Exercise 1: Basic Variables

```bash
#!/bin/bash
NAME="Student"
COURSE="Operating Systems"
YEAR=2025

echo "Welcome, $NAME!"
echo "Course: $COURSE"
echo "Year: $YEAR"
```

### Exercise 2: Special Variables

```bash
#!/bin/bash
echo "Script: $0"
echo "Arguments: $#"
echo "First: $1"
echo "All: $@"
echo "PID: $$"
```

### Exercise 3: String Manipulation

```bash
FILE="/home/student/document.txt"

echo "Full path: $FILE"
echo "Filename: ${FILE##*/}"
echo "Directory: ${FILE%/*}"
echo "Extension: ${FILE##*.}"
echo "Without extension: ${FILE%.*}"
```

### Exercise 4: Arrays

```bash
#!/bin/bash
FRUITS=("apple" "pear" "banana" "orange")

echo "Total fruits: ${#FRUITS[@]}"
echo "First: ${FRUITS[0]}"

for fruit in "${FRUITS[@]}"; do
    echo "- $fruit"
done
```

---

## Cheat Sheet

```bash
# DEFINITION
VAR="value"             # local
export VAR="value"      # environment
unset VAR               # delete
readonly VAR="const"    # constant

# SPECIAL
$?    # exit code
$$    # current PID
$!    # background PID
$0    # script name
$1-$9 # parameters
$#    # no. of parameters
$@    # all parameters

# DEFAULT VALUES
${VAR:-default}         # default if not exists
${VAR:=default}         # set default
${VAR:+alt}             # alt if exists

# STRINGS
${#VAR}                 # length
${VAR:start:len}        # substring
${VAR/old/new}          # replace
${VAR%pattern}          # remove from end
${VAR#pattern}          # remove from beginning
${VAR^^}                # UPPERCASE
${VAR,,}                # lowercase

# ARRAY
ARR=(a b c)             # definition
${ARR[0]}               # element
${ARR[@]}               # all
${#ARR[@]}              # length
ARR+=(d)                # add

# READING
read VAR                # input
read -p ":" VAR         # with prompt
read -s VAR             # silent
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
