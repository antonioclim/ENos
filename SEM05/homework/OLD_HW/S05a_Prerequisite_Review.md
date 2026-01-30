# S05_TC00 - Bash Scripting Practice

> **Operating Systems** | ASE Bucharest - CSIE  
> Laboratory material - Seminar 5 (REVIEW - Prerequisites)

---

> 🚨 **BEFORE STARTING THE ASSIGNMENT**
>
> 1. Download and configure the `002HWinit` package (see STUDENT_GUIDE_EN.md)
> 2. Open a terminal and navigate to `~/HOMEWORKS`
> 3. Start recording with:
>    ```bash
>    python3 record_homework_tui_EN.py
>    ```
>    or the Bash version:
>    ```bash
>    ./record_homework_EN.sh
>    ```
> 4. Complete the requested data (name, group, assignment number)
> 5. **ONLY THEN** begin solving the requirements below

---

## Objectives

> **NOTE:** This material is a review of fundamental concepts. If these concepts are already familiar, you can proceed directly to TC01.

At the end of this lab, the student will be able to:
- Apply scripting knowledge in practical exercises
- Use conditional structures and loops
- Process data and files with scripts

---


## 2. If-Then-Else

### 2.1 Syntax

```bash
if [ condition ]; then
    commands
fi

if [ condition ]; then
    commands
else
    other_commands
fi

if [ condition1 ]; then
    commands1
elif [ condition2 ]; then
    commands2
else
    default_commands
fi
```

### 2.2 Examples

```bash
#!/bin/bash

# Check if file exists
if [ -f "$1" ]; then
    echo "File exists"
    cat "$1"
else
    echo "File does not exist"
    exit 1
fi

# Check age
read -p "Age: " age
if [ "$age" -ge 18 ]; then
    echo "Adult"
elif [ "$age" -ge 13 ]; then
    echo "Teenager"
else
    echo "Child"
fi

# One-liner
[ -f "$file" ] && echo "Exists" || echo "Does not exist"
```

---

## 3. Case

### 3.1 Syntax

```bash
case "$variable" in
    pattern1)
        commands1
        ;;
    pattern2|pattern3)
        commands2
        ;;
    *)
        default_commands
        ;;
esac
```

### 3.2 Examples

```bash
#!/bin/bash

case "$1" in
    start)
        echo "Starting service..."
        ;;
    stop)
        echo "Stopping service..."
        ;;
    restart)
        echo "Restarting service..."
        ;;
    status)
        echo "Checking status..."
        ;;
    *)
        echo "Usage: $0 {start|stop|restart|status}"
        exit 1
        ;;
esac

# Advanced patterns
case "$filename" in
    *.txt)
        echo "Text file"
        ;;
    *.jpg|*.png|*.gif)
        echo "Image file"
        ;;
    *.tar.gz|*.tgz)
        echo "Compressed archive"
        ;;
    *)
        echo "Unknown type"
        ;;
esac
```

---

## 4. Loops

### 4.1 For Loop

```bash
# Explicit list
for item in a b c d; do
    echo "$item"
done

# Brace expansion
for i in {1..10}; do
    echo "Number: $i"
done

# Files
for file in *.txt; do
    echo "Processing: $file"
done

# C-style
for ((i=0; i<10; i++)); do
    echo "i = $i"
done

# Array iteration
arr=(a b c d)
for item in "${arr[@]}"; do
    echo "$item"
done
```

### 4.2 While Loop

```bash
# Counter
count=1
while [ $count -le 5 ]; do
    echo "Count: $count"
    ((count++))
done

# Reading file
while IFS= read -r line; do
    echo "Line: $line"
done < file.txt

# Infinite
while true; do
    echo "Running..."
    sleep 1
done
```

### 4.3 Until Loop

```bash
# Executes until condition becomes true
count=1
until [ $count -gt 5 ]; do
    echo "Count: $count"
    ((count++))
done
```

### 4.4 Control Flow

```bash
break       # exit loop
break N     # exit N loops
continue    # skip to next iteration
continue N  # continue outer loop N
```

---

## 5. Functions

### 5.1 Definition and Calling

```bash
# Definition
function function_name() {
    commands
}

# Or (POSIX style)
function_name() {
    commands
}

# Calling
function_name
function_name arg1 arg2
```

### 5.2 Parameters and Return

```bash
greet() {
    local name="$1"      # Local variable
    echo "Hello, $name!"
    return 0             # Exit status (0-255)
}

greet "World"
status=$?                # Capture return value

# Returning complex values (via echo)
get_sum() {
    local a=$1 b=$2
    echo $((a + b))
}

result=$(get_sum 5 3)
echo "Sum: $result"
```

### 5.3 Local Variables

```bash
#!/bin/bash

global_var="global"

test_scope() {
    local local_var="local"
    global_var="modified"
    
    echo "Inside: $local_var, $global_var"
}

test_scope
echo "Outside: $global_var"  # "modified"
echo "Outside: $local_var"   # empty (doesn't exist)
```

---

## 6. Complete Practice Exercises

### Exercise 1: File Verification

```bash
#!/bin/bash
# Check argument type

if [ $# -eq 0 ]; then
    echo "Usage: $0 <file/dir>"
    exit 1
fi

if [ ! -e "$1" ]; then
    echo "Does not exist: $1"
    exit 1
fi

if [ -f "$1" ]; then
    echo "File: $1"
    echo "Size: $(stat -c %s "$1") bytes"
    echo "Lines: $(wc -l < "$1")"
elif [ -d "$1" ]; then
    echo "Directory: $1"
    echo "Contains: $(ls -1 "$1" | wc -l) elements"
elif [ -L "$1" ]; then
    echo "Symlink: $1 -> $(readlink "$1")"
fi
```

### Exercise 2: Calculator

```bash
#!/bin/bash
# Simple calculator

usage() {
    echo "Usage: $0 num1 operator num2"
    echo "Operators: + - * / %"
    exit 1
}

[ $# -ne 3 ] && usage

a=$1
op=$2
b=$3

case $op in
    +) result=$((a + b)) ;;
    -) result=$((a - b)) ;;
    '*') result=$((a * b)) ;;
    /) 
        [ $b -eq 0 ] && { echo "Error: division by 0"; exit 1; }
        result=$((a / b)) 
        ;;
    %) result=$((a % b)) ;;
    *) usage ;;
esac

echo "$a $op $b = $result"
```

### Exercise 3: File Processing

```bash
#!/bin/bash
# Process all .txt files

count=0
total_lines=0

for file in *.txt; do
    [ -f "$file" ] || continue
    
    lines=$(wc -l < "$file")
    ((count++))
    ((total_lines += lines))
    
    echo "$file: $lines lines"
done

echo "---"
echo "Total: $count files, $total_lines lines"
echo "Average: $((total_lines / count)) lines/file"
```

### Exercise 4: Interactive Menu

```bash
#!/bin/bash

show_menu() {
    echo "=== MENU ==="
    echo "1. Display date"
    echo "2. List files"
    echo "3. Disk space"
    echo "4. Exit"
    echo "============"
}

while true; do
    show_menu
    read -p "Option: " choice
    
    case $choice in
        1) date ;;
        2) ls -la ;;
        3) df -h ;;
        4) echo "Goodbye!"; exit 0 ;;
        *) echo "Invalid option" ;;
    esac
    
    echo
    read -p "Press Enter to continue..."
done
```

---

## Cheat Sheet

```bash
# TESTS
[ -f file ]     file exists
[ -d dir ]      directory exists
[ -z "$s" ]     string empty
[ -n "$s" ]     string non-empty
[ $a -eq $b ]   numeric equal
[ "$a" = "$b" ] string equal

# IF
if [ cond ]; then ... fi
if [ cond ]; then ... else ... fi
if [ cond ]; then ... elif ... fi

# CASE
case $var in
    pattern) cmd ;;
    *) default ;;
esac

# LOOPS
for i in {1..10}; do ... done
for f in *.txt; do ... done
while [ cond ]; do ... done
until [ cond ]; do ... done

# FUNCTIONS
func() { local v="..."; echo $1; return 0; }
result=$(func arg)

# CONTROL
break       exit loop
continue    next iteration
exit N      exit script
return N    exit function
```

---

## 📤 Completion and Submission

After completing all requirements:

1. **Stop recording** by typing:
   ```bash
   STOP_tema
   ```
   or press `Ctrl+D`

2. **Wait** - the script will:
   - Generate the cryptographic signature
   - Automatically upload the file to the server

3. **Check the final message**:
   - ✅ `UPLOAD SUCCESSFUL!` - the assignment was submitted
   - ❌ If upload fails, the `.cast` file is saved locally - send it manually later with the displayed command

> ⚠️ **DO NOT modify the `.cast` file** after generation - the signature becomes invalid!

---

*By Revolvix for OPERATING SYSTEMS class | restricted licence 2017-2030*
