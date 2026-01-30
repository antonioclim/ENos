# S05_TC01 - Advanced Functions in Bash

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
- Create functions with local variables and return values
- Use nameref for return by reference
- Implement recursive functions
- Process arguments in advanced ways (getopts)

---


## 2. Local Variables and Scope

### 2.1 The `local` Keyword

```bash
GLOBAL="global"

my_function() {
    local LOCAL_VAR="local"       # visible only in function
    GLOBAL="modified"             # modifies global variable
    
    echo "Inside: GLOBAL=$GLOBAL, LOCAL_VAR=$LOCAL_VAR"
}

my_function
echo "Outside: GLOBAL=$GLOBAL"
echo "Outside: LOCAL_VAR=$LOCAL_VAR"  # empty - not visible
```

### 2.2 Scope and Nested Functions

```bash
#!/bin/bash

GLOBAL="global"

outer() {
    local OUTER_LOCAL="outer"
    
    inner() {
        local INNER_LOCAL="inner"
        echo "Inner sees:"
        echo "  GLOBAL=$GLOBAL"
        echo "  OUTER_LOCAL=$OUTER_LOCAL"
        echo "  INNER_LOCAL=$INNER_LOCAL"
    }
    
    inner
    echo "Outer: INNER_LOCAL=$INNER_LOCAL"  # empty
}

outer
```

---

## 3. Returning Values

### 3.1 Method 1: Echo and Capture

```bash
get_sum() {
    local a=$1 b=$2
    echo $((a + b))
}

result=$(get_sum 5 3)
echo "Sum: $result"  # 8
```

### 3.2 Method 2: Global Variable

```bash
calculate() {
    RESULT=$((${1} + ${2}))
}

calculate 5 3
echo "Result: $RESULT"  # 8
```

### 3.3 Method 3: Return Code (0-255)

```bash
is_even() {
    (( $1 % 2 == 0 ))
}

if is_even 4; then
    echo "4 is even"
fi

is_even 4
echo "Exit code: $?"  # 0 (true)
```

### 3.4 Method 4: Nameref (Bash 4.3+)

```bash
get_data() {
    local -n ref=$1     # nameref - reference to passed variable
    ref="calculated value"
}

declare result
get_data result
echo "$result"  # "calculated value"

# Useful for multiple returns
get_dimensions() {
    local -n width_ref=$1
    local -n height_ref=$2
    width_ref=800
    height_ref=600
}

declare w h
get_dimensions w h
echo "Width: $w, Height: $h"
```

---

## 4. Recursive Functions

### 4.1 Factorial

```bash
factorial() {
    local n=$1
    if (( n <= 1 )); then
        echo 1
    else
        local prev=$(factorial $((n - 1)))
        echo $((n * prev))
    fi
}

echo "5! = $(factorial 5)"  # 120
```

### 4.2 Fibonacci

```bash
fib() {
    local n=$1
    if (( n <= 1 )); then
        echo $n
    else
        local a=$(fib $((n - 1)))
        local b=$(fib $((n - 2)))
        echo $((a + b))
    fi
}

echo "fib(10) = $(fib 10)"  # 55
```

### 4.3 Directory Traversal (Recursive)

```bash
traverse() {
    local dir="${1:-.}"
    local indent="${2:-}"
    
    for item in "$dir"/*; do
        [[ -e "$item" ]] || continue
        echo "${indent}$(basename "$item")"
        
        if [[ -d "$item" ]]; then
            traverse "$item" "${indent}  "
        fi
    done
}

traverse /etc 2>/dev/null | head -20
```

---

## 5. Argument Processing with getopts

### 5.1 getopts Syntax

```bash
#!/bin/bash

usage() {
    cat << EOF
Usage: $0 [-h] [-v] [-o file] [-n num] [args...]

Options:
    -h          Show this help
    -v          Verbose mode
    -o FILE     Output file
    -n NUM      Number of iterations
EOF
    exit 1
}

# Defaults
VERBOSE=false
OUTPUT=""
NUM=1

# Parse options
# ":" at start = silent mode (we handle errors)
# ":" after letter = option requires argument
while getopts ":hvo:n:" opt; do
    case $opt in
        h) usage ;;
        v) VERBOSE=true ;;
        o) OUTPUT="$OPTARG" ;;
        n) 
            [[ "$OPTARG" =~ ^[0-9]+$ ]] || { echo "Error: -n requires number"; exit 1; }
            NUM="$OPTARG" 
            ;;
        :) echo "Option -$OPTARG requires an argument"; exit 1 ;;
        \?) echo "Invalid option: -$OPTARG"; exit 1 ;;
    esac
done

# Shift to remove processed options
shift $((OPTIND - 1))

# Remaining arguments
ARGS=("$@")

echo "VERBOSE=$VERBOSE"
echo "OUTPUT=$OUTPUT"
echo "NUM=$NUM"
echo "Remaining args: ${ARGS[*]}"
```

### 5.2 Long Options (Manual)

```bash
#!/bin/bash

VERBOSE=false
OUTPUT=""
NUM=1
ARGS=()

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            usage
            exit 0
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -o|--output)
            OUTPUT="$2"
            shift 2
            ;;
        --output=*)
            OUTPUT="${1#*=}"
            shift
            ;;
        -n|--num)
            NUM="$2"
            shift 2
            ;;
        --num=*)
            NUM="${1#*=}"
            shift
            ;;
        --)
            shift
            ARGS+=("$@")
            break
            ;;
        -*)
            echo "Unknown option: $1" >&2
            exit 1
            ;;
        *)
            ARGS+=("$1")
            shift
            ;;
    esac
done
```

---

## 6. Useful Patterns

### 6.1 Function with Validation

```bash
process_file() {
    local file="${1:?Error: filename required}"
    
    [[ -f "$file" ]] || { echo "Error: not a file: $file" >&2; return 1; }
    [[ -r "$file" ]] || { echo "Error: cannot read: $file" >&2; return 1; }
    
    # Processing...
    cat "$file"
}
```

### 6.2 Wrapper Function

```bash
# Log wrapper
log_run() {
    echo "[$(date '+%H:%M:%S')] Running: $*" >&2
    "$@"
    local status=$?
    echo "[$(date '+%H:%M:%S')] Finished with status: $status" >&2
    return $status
}

log_run ls -la
log_run grep pattern file.txt
```

### 6.3 Memoisation (Caching)

```bash
declare -A _cache

memoised_expensive() {
    local key="$*"
    
    if [[ -v _cache[$key] ]]; then
        echo "${_cache[$key]}"
        return
    fi
    
    # The expensive calculation
    local result=$(expensive_operation "$@")
    _cache[$key]="$result"
    
    echo "$result"
}
```

---

## 7. Exercises

### Exercise 1
Create a function `validate_ip` that checks if a string is a valid IP address.

### Exercise 2
Implement a function `tree_lite` that displays directory structure similar to the `tree` command.

### Exercise 3
Create a script with getopts that accepts: `-i input`, `-o output`, `-v` verbose, `-h` help.

---

## Cheat Sheet

```bash
# FUNCTION DEFINITION
func() { local v="..."; echo "$1"; return 0; }

# LOCAL VARIABLES
local var="value"
local -n ref=$1        # nameref

# RETURN VALUES
result=$(func arg)     # capture output
func; echo $?          # exit code
local -n ref=$1; ref="value"  # by reference

# GETOPTS
while getopts ":hvo:" opt; do
    case $opt in
        h) usage ;;
        v) VERBOSE=true ;;
        o) OUTPUT="$OPTARG" ;;
        :) echo "Needs arg" ;;
        \?) echo "Invalid" ;;
    esac
done
shift $((OPTIND-1))
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
