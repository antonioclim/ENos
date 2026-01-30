# S02_TC05 - Loops in Bash Scripts

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

By the end of this laboratory, the student will be able to:
- Use `for`, `while` and `until` loops
- Control flow with `break` and `continue`
- Iterate over files, arrays and command output

---


## 2. The while Loop

Executes as long as the condition is **true**.

```bash
# Syntax
while [ condition ]; do
    commands
done

# Example: counter
count=1
while [ $count -le 5 ]; do
    echo "Count: $count"
    ((count++))
done

# Infinite loop
while true; do
    echo "Press Ctrl+C to stop"
    sleep 1
done

# Read file line by line
while IFS= read -r line; do
    echo "Line: $line"
done < file.txt

# With pipe (subshell!)
cat file.txt | while read line; do
    echo "$line"
done
```

---

## 3. The until Loop

Executes as long as the condition is **false** (opposite of while).

```bash
# Syntax
until [ condition ]; do
    commands
done

# Example
count=1
until [ $count -gt 5 ]; do
    echo "Count: $count"
    ((count++))
done

# Wait for a service
until ping -c1 server &>/dev/null; do
    echo "Waiting for server..."
    sleep 5
done
echo "Server available!"
```

---

## 4. Control Flow

### 4.1 break

Exit from loop.

```bash
for i in {1..100}; do
    if [ $i -eq 10 ]; then
        break
    fi
    echo $i
done

# break N - exit from N loops
for i in {1..3}; do
    for j in {1..3}; do
        if [ $j -eq 2 ]; then
            break 2    # exit from both loops
        fi
        echo "$i-$j"
    done
done
```

### 4.2 continue

Skip to next iteration.

```bash
# Display only odd numbers
for i in {1..10}; do
    if [ $((i % 2)) -eq 0 ]; then
        continue
    fi
    echo $i
done

# continue N - continue loop N
for i in {1..3}; do
    for j in {1..3}; do
        if [ $j -eq 2 ]; then
            continue 2
        fi
        echo "$i-$j"
    done
done
```

---

## 5. Practical Examples

### 5.1 Batch File Processing

```bash
#!/bin/bash
# Convert all .jpeg to .jpg
for file in *.jpeg; do
    [ -f "$file" ] || continue
    newname="${file%.jpeg}.jpg"
    mv "$file" "$newname"
    echo "Renamed: $file -> $newname"
done
```

### 5.2 Backup with Numbering

```bash
#!/bin/bash
for i in {1..5}; do
    backup_name="backup_$(date +%Y%m%d)_$i.tar.gz"
    echo "Creating: $backup_name"
    # tar czf "$backup_name" /data
done
```

### 5.3 Process Monitoring

```bash
#!/bin/bash
while true; do
    clear
    ps aux --sort=-%mem | head -10
    echo "---"
    date
    sleep 5
done
```

### 5.4 CSV Processing

```bash
#!/bin/bash
while IFS=',' read -r name age grade; do
    echo "Student: $name, Age: $age, Grade: $grade"
done < students.csv
```

---

## 6. Practical Exercises

### Exercise 1: Counter

```bash
#!/bin/bash
# Count from 1 to 10
for i in {1..10}; do
    echo $i
done

# With while
count=1
while [ $count -le 10 ]; do
    echo $count
    ((count++))
done
```

### Exercise 2: Sum of Numbers

```bash
#!/bin/bash
sum=0
for i in {1..100}; do
    ((sum += i))
done
echo "Sum: $sum"
```

### Exercise 3: Factorial

```bash
#!/bin/bash
n=5
factorial=1
for (( i=1; i<=n; i++ )); do
    ((factorial *= i))
done
echo "$n! = $factorial"
```

### Exercise 4: File Reading

```bash
#!/bin/bash
line_num=0
while IFS= read -r line; do
    ((line_num++))
    echo "$line_num: $line"
done < "$1"
```

---

## Cheat Sheet

```bash
# FOR - LIST
for var in list; do cmd; done
for i in 1 2 3; do echo $i; done
for f in *.txt; do cat $f; done

# FOR - BRACE EXPANSION
for i in {1..10}; do echo $i; done
for i in {0..100..10}; do echo $i; done

# FOR - C STYLE
for ((i=0; i<10; i++)); do
    echo $i
done

# WHILE
while [ condition ]; do
    commands
done

# UNTIL
until [ condition ]; do
    commands
done

# FILE READING
while IFS= read -r line; do
    echo "$line"
done < file.txt

# CONTROL
break           # exit loop
break N         # exit N loops
continue        # next iteration
continue N      # continue loop N

# INFINITE LOOP
while true; do cmd; done
while :; do cmd; done
for ((;;)); do cmd; done
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
