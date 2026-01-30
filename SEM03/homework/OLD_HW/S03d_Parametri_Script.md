# S03_TC03 - Parameters in Bash Scripts

> **Operating Systems** | Bucharest UES - CSIE  
> Laboratory material - Seminar 3 (Redistributed)

---

> 🚨 **BEFORE STARTING THE ASSIGNMENT**
>
> 1. Download and configure the `002HWinit` package (see STUDENT_GUIDE_EN.md)
> 2. Open a terminal and navigate to `~/HOMEWORKS`
> 3. Start recording with:
>    ```bash
>    python3 record_homework_tui_RO.py
>    ```
>    or the Bash version:
>    ```bash
>    ./record_homework_RO.sh
>    ```
> 4. Complete the required data (name, group, assignment no.)
> 5. **ONLY THEN** start solving the requirements below

---

## Objectives

At the end of this laboratory, the student will be able to:
- Process command line arguments in scripts
- Use positional parameters and special variables
- Implement option parsing with `shift` and `getopts`

---


## 2. The shift Command

### 2.1 Basic Usage

`shift` removes the first parameter and moves the rest one position.

```bash
#!/bin/bash

echo "Before shift:"
echo "  \$1 = $1"
echo "  \$2 = $2"
echo "  \$# = $#"

shift

echo "After shift:"
echo "  \$1 = $1"    # former $2
echo "  \$2 = $2"    # former $3
echo "  \$# = $#"    # decremented
```

### 2.2 Iterative Processing

```bash
#!/bin/bash

echo "Processing $# arguments:"

while [ $# -gt 0 ]; do
    echo "  Argument: $1"
    shift
done

echo "Done! $# arguments remaining."
```

### 2.3 shift with Number

```bash
#!/bin/bash

echo "Arguments: $@"
shift 2    # remove first 2
echo "After shift 2: $@"
```

---

## 3. The getopts Command

### 3.1 Basic Syntax

```bash
#!/bin/bash

# getopts "optstring" variable
# optstring: option letters
# : after letter = option requires argument

while getopts "hvo:" opt; do
    case $opt in
        h)
            echo "Help: ./script.sh [-h] [-v] [-o file]"
            exit 0
            ;;
        v)
            VERBOSE=true
            ;;
        o)
            OUTPUT="$OPTARG"
            ;;
        \?)
            echo "Invalid option: -$OPTARG"
            exit 1
            ;;
        :)
            echo "Option -$OPTARG requires an argument"
            exit 1
            ;;
    esac
done

# Skip processed options
shift $((OPTIND - 1))

echo "VERBOSE: $VERBOSE"
echo "OUTPUT: $OUTPUT"
echo "Remaining arguments: $@"
```

### 3.2 getopts Variables Explanation

| Variable | Description |
|----------|-------------|
| `$OPTARG` | Value of current option's argument |
| `$OPTIND` | Index of next argument to process |
| `$opt` | Letter of current option |

### 3.3 Complete Example

```bash
#!/bin/bash

# Default values
VERBOSE=false
OUTPUT=""
INPUT=""
COUNT=1

usage() {
    cat << EOF
Usage: $(basename $0) [options] [files...]

Options:
    -h          Display this help
    -v          Verbose mode
    -o FILE     Output file
    -c NUM      Number of repetitions (default: 1)
EOF
    exit 1
}

while getopts ":hvo:c:" opt; do
    case $opt in
        h) usage ;;
        v) VERBOSE=true ;;
        o) OUTPUT="$OPTARG" ;;
        c) COUNT="$OPTARG" ;;
        :) echo "Error: -$OPTARG requires argument"; exit 1 ;;
        \?) echo "Error: Unknown option -$OPTARG"; exit 1 ;;
    esac
done

shift $((OPTIND - 1))

# Check mandatory arguments
if [ $# -eq 0 ]; then
    echo "Error: Missing input files"
    usage
fi

# Processing
$VERBOSE && echo "Verbose mode enabled"
$VERBOSE && echo "Output: $OUTPUT"
$VERBOSE && echo "Repetitions: $COUNT"
$VERBOSE && echo "Files: $@"

for file in "$@"; do
    echo "Processing: $file"
done
```

---

## 4. Common Patterns

### 4.1 Argument Count Verification

```bash
#!/bin/bash

if [ $# -lt 2 ]; then
    echo "Usage: $0 <source> <destination>"
    exit 1
fi

SOURCE="$1"
DEST="$2"
```

### 4.2 Arguments with Default Values

```bash
#!/bin/bash

# Use argument or default value
INPUT="${1:-input.txt}"
OUTPUT="${2:-output.txt}"
COUNT="${3:-10}"

echo "Input: $INPUT"
echo "Output: $OUTPUT"
echo "Count: $COUNT"
```

### 4.3 Long Options Processing (manual)

```bash
#!/bin/bash

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            echo "Help..."
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
        --)
            shift
            break
            ;;
        -*)
            echo "Unknown option: $1"
            exit 1
            ;;
        *)
            break
            ;;
    esac
done
```

---

## 5. Practical Exercises

### Exercise 1: Script with Parameters

```bash
#!/bin/bash
# greet.sh - greets users

if [ $# -eq 0 ]; then
    echo "Usage: $0 name1 [name2] [name3] ..."
    exit 1
fi

for name in "$@"; do
    echo "Hello, $name!"
done
```

### Exercise 2: Simple Calculator

```bash
#!/bin/bash
# calc.sh num1 operator num2

if [ $# -ne 3 ]; then
    echo "Usage: $0 num1 [+|-|*|/] num2"
    exit 1
fi

case $2 in
    +) echo "$1 + $3 = $((${1} + ${3}))" ;;
    -) echo "$1 - $3 = $((${1} - ${3}))" ;;
    \*) echo "$1 * $3 = $((${1} * ${3}))" ;;
    /) echo "$1 / $3 = $((${1} / ${3}))" ;;
    *) echo "Unknown operator: $2" ;;
esac
```

### Exercise 3: Backup with Options

```bash
#!/bin/bash
# backup.sh -s source -d dest [-v] [-c]

VERBOSE=false
COMPRESS=false

while getopts "s:d:vc" opt; do
    case $opt in
        s) SOURCE="$OPTARG" ;;
        d) DEST="$OPTARG" ;;
        v) VERBOSE=true ;;
        c) COMPRESS=true ;;
    esac
done

if [ -z "$SOURCE" ] || [ -z "$DEST" ]; then
    echo "Usage: $0 -s source -d dest [-v] [-c]"
    exit 1
fi

$VERBOSE && echo "Copying $SOURCE -> $DEST"

if $COMPRESS; then
    tar czf "$DEST.tar.gz" "$SOURCE"
else
    cp -r "$SOURCE" "$DEST"
fi
```

---

## Cheat Sheet

```bash
# POSITIONAL PARAMETERS
$0        # script name
$1-$9     # parameters 1-9
${10}     # parameter 10+
$#        # number of parameters
$@        # all (as list)
$*        # all (as string)

# SHIFT
shift     # remove $1
shift N   # remove first N

# GETOPTS
getopts "ab:c:" opt    # a,c without arg, b with arg
$OPTARG               # argument value
$OPTIND               # current index
shift $((OPTIND-1))   # skip over options

# DEFAULT VALUES
${VAR:-default}       # use default
${1:-default}         # argument with default

# CHECKS
[ $# -eq 0 ]          # no arguments
[ $# -lt 2 ]          # less than 2
[ -z "$1" ]           # empty argument
```

---

## 📤 Completion and Submission

After you have completed all requirements:

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
