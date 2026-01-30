# S05_TC02 - Arrays in Bash

> **Operating Systems** | ASE Bucharest - CSIE  
> Laboratory material - Seminar 5 (SPLIT from TC6a)

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

At the end of this lab, the student will be able to:
- Work with indexed arrays (0-based)
- Work with associative arrays (hash maps)
- Iterate and manipulate arrays efficiently
- Implement data structures in Bash

---


## 2. Iterating Arrays

### 2.1 By Values

```bash
arr=(alpha beta gamma)

for item in "${arr[@]}"; do
    echo "Item: $item"
done

# IMPORTANT: quotes "${arr[@]}" preserve elements with spaces
arr=("first item" "second item")
for item in "${arr[@]}"; do
    echo "-> $item"
done
```

### 2.2 By Indices

```bash
arr=(alpha beta gamma)

for i in "${!arr[@]}"; do
    echo "[$i] = ${arr[$i]}"
done

# Output:
# [0] = alpha
# [1] = beta
# [2] = gamma
```

### 2.3 C-style

```bash
arr=(alpha beta gamma)

for ((i=0; i<${#arr[@]}; i++)); do
    echo "[$i] = ${arr[$i]}"
done
```

---

## 3. Array Operations

### 3.1 Search

```bash
arr=(apple banana cherry)

# Check existence
if [[ " ${arr[@]} " =~ " banana " ]]; then
    echo "Found!"
fi

# Find index
find_index() {
    local needle="$1"
    shift
    local arr=("$@")
    for i in "${!arr[@]}"; do
        if [[ "${arr[$i]}" == "$needle" ]]; then
            echo "$i"
            return 0
        fi
    done
    return 1
}

idx=$(find_index "banana" "${arr[@]}")
echo "Index: $idx"  # 1
```

### 3.2 Sorting

```bash
arr=(delta alpha gamma beta)

# Sort with sort
sorted=($(printf '%s\n' "${arr[@]}" | sort))
echo "${sorted[@]}"  # alpha beta delta gamma

# Numeric sort
nums=(10 2 5 1 20)
sorted=($(printf '%s\n' "${nums[@]}" | sort -n))
echo "${sorted[@]}"  # 1 2 5 10 20
```

### 3.3 Reverse

```bash
arr=(a b c d e)
reversed=()

for ((i=${#arr[@]}-1; i>=0; i--)); do
    reversed+=("${arr[$i]}")
done

echo "${reversed[@]}"  # e d c b a
```

### 3.4 Filter

```bash
nums=(1 2 3 4 5 6 7 8 9 10)
even=()

for n in "${nums[@]}"; do
    (( n % 2 == 0 )) && even+=("$n")
done

echo "Even: ${even[@]}"  # 2 4 6 8 10
```

### 3.5 Map (Transform)

```bash
arr=(apple banana cherry)
upper=()

for item in "${arr[@]}"; do
    upper+=("${item^^}")  # uppercase
done

echo "${upper[@]}"  # APPLE BANANA CHERRY
```

---

## 4. Associative Arrays (Hash Maps)

### 4.1 Declaration and Population

```bash
# MANDATORY: declare -A
declare -A config

# Populate element by element
config[host]="localhost"
config[port]="8080"
config[user]="admin"

# Or all at once
declare -A config=(
    [host]="localhost"
    [port]="8080"
    [user]="admin"
)
```

### 4.2 Access

```bash
declare -A config=([host]="localhost" [port]="8080")

# Element
echo ${config[host]}        # localhost

# All values
echo ${config[@]}           # localhost 8080

# All keys
echo ${!config[@]}          # host port

# Number of elements
echo ${#config[@]}          # 2

# Default value
echo ${config[missing]:-default}  # default
```

### 4.3 Existence Check

```bash
declare -A config=([host]="localhost")

# Check key (Bash 4.3+)
if [[ -v config[host] ]]; then
    echo "Host is set"
fi

# Alternative for older versions
if [[ -n "${config[host]+isset}" ]]; then
    echo "Host is set"
fi
```

### 4.4 Iteration

```bash
declare -A config=([host]="localhost" [port]="8080" [user]="admin")

# By keys
for key in "${!config[@]}"; do
    echo "$key = ${config[$key]}"
done

# Sorted
for key in $(echo "${!config[@]}" | tr ' ' '\n' | sort); do
    echo "$key = ${config[$key]}"
done
```

### 4.5 Modification and Deletion

```bash
declare -A config=([host]="localhost")

# Modification
config[host]="127.0.0.1"

# Addition
config[timeout]="30"

# Delete key
unset config[timeout]

# Delete all
unset config
# or
declare -A config=()
```

---

## 5. Practical Examples

### 5.1 Word Counting

```bash
declare -A word_count

# Read and count
while read -r word; do
    ((word_count[$word]++))
done < <(tr -cs '[:alpha:]' '\n' < text.txt | tr '[:upper:]' '[:lower:]')

# Display sorted
for word in "${!word_count[@]}"; do
    echo "${word_count[$word]} $word"
done | sort -rn | head -10
```

### 5.2 Config Parser

```bash
declare -A CONFIG

parse_config() {
    local file="$1"
    while IFS='=' read -r key value; do
        # Skip comments and empty lines
        [[ "$key" =~ ^[[:space:]]*# ]] && continue
        [[ -z "$key" ]] && continue
        
        # Trim whitespace
        key="${key// /}"
        value="${value// /}"
        
        CONFIG["$key"]="$value"
    done < "$file"
}

get_config() {
    local key="$1"
    local default="${2:-}"
    echo "${CONFIG[$key]:-$default}"
}

# Usage
parse_config "app.conf"
echo "Host: $(get_config host localhost)"
echo "Port: $(get_config port 8080)"
```

### 5.3 Stack Implementation

```bash
declare -a STACK=()

push() { STACK+=("$1"); }

pop() {
    (( ${#STACK[@]} == 0 )) && { echo "Empty" >&2; return 1; }
    echo "${STACK[-1]}"
    unset 'STACK[-1]'
}

peek() { echo "${STACK[-1]:-}"; }

is_empty() { (( ${#STACK[@]} == 0 )); }

# Test
push "a"
push "b"
push "c"
echo "Pop: $(pop)"   # c
echo "Peek: $(peek)" # b
```

### 5.4 Simple Cache

```bash
declare -A cache

cached_curl() {
    local url="$1"
    
    if [[ -v cache[$url] ]]; then
        echo "${cache[$url]}"
        return
    fi
    
    local result
    result=$(curl -s "$url")
    cache[$url]="$result"
    
    echo "$result"
}
```

---

## 6. Exercises

### Exercise 1
Implement a function `array_unique` that removes duplicates from an array.

### Exercise 2
Create a script that reads a CSV and stores data in an associative array.

### Exercise 3
Implement a Queue structure (FIFO) using arrays.

---

## Cheat Sheet

```bash
# INDEXED ARRAYS
arr=(a b c)
${arr[0]}           # element
${arr[@]}           # all (as list)
${#arr[@]}          # length
${!arr[@]}          # indices
${arr[@]:1:2}       # slice
arr+=(d)            # append
unset arr[1]        # delete element

# ASSOCIATIVE ARRAYS
declare -A hash
hash[key]="value"
${hash[key]}        # access
${!hash[@]}         # all keys
${hash[@]}          # all values
[[ -v hash[key] ]]  # check existence
unset hash[key]     # delete

# ITERATION
for item in "${arr[@]}"; do ...; done
for key in "${!hash[@]}"; do echo "$key=${hash[$key]}"; done

# OPERATIONS
sorted=($(printf '%s\n' "${arr[@]}" | sort))
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
