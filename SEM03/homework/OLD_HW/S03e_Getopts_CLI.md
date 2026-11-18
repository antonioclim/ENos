# S03_TC04 - Options and Switches in Scripts

> **Evidence limit:** local recordings, logs and hashes can support review of a submitted session; they do not prove authorship, uninterrupted capture or the absence of edited/omitted activity. Privacy, retention and assessment consequences remain subject to the approved course policy.

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
- Parse command line arguments in Bash scripts
- Use `getopts` for short options
- Implement long options manually
- Create professional CLI interfaces

---


## 2. Simple Manual Parsing

### 2.1 With shift

```bash
#!/bin/bash

VERBOSE=false
OUTPUT=""
ARGS=()

while [ $# -gt 0 ]; do
    case "$1" in
        -h|--help)
            echo "Help: $0 [-v] [-o FILE] input"
            exit 0
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -o|--output)
            [[ $# -ge 2 && -n $2 ]] || { echo "Missing nonempty option value" >&2; exit 1; }
            OUTPUT="$2"
            shift 2
            ;;
        --)
            shift
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

echo "Verbose: $VERBOSE"
echo "Output: $OUTPUT"
ARGS+=("$@")  # Preserve operands after -- as well.
printf 'Argument: %s\n' "${ARGS[@]}"
```

---

## 3. getopts - Standard Parsing

### 3.1 Basic Syntax

```text
while getopts "optstring" opt; do
    case $opt in
        ...
    esac
done

# optstring format:
# a → option -a without argument
# a: → option -a WITH mandatory argument
# :a → : at beginning = silent error mode
```

### 3.2 getopts Variables

| Variable | Description |
|----------|-------------|
| `$opt` | Current option |
| `$OPTARG` | Current option's argument |
| `$OPTIND` | Index of next argument to process |

### 3.3 Complete Example

```bash
#!/bin/bash

usage() {
    cat << EOF
Usage: $0 [options] <file>

Options:
    -h          Display this message
    -v          Verbose mode
    -o FILE     Output file
    -n NUM      Number of iterations
    -f          Force overwrite

Examples:
    $0 -v input.txt
    $0 -o output.txt -n 5 input.txt
EOF
    exit 1
}

# Default values
VERBOSE=false
FORCE=false
OUTPUT=""
NUM=1

# Parse options
while getopts ":hvo:n:f" opt; do
    case $opt in
        h) usage ;;
        v) VERBOSE=true ;;
        o) OUTPUT="$OPTARG" ;;
        n)
            NUM="$OPTARG"
            if ! [[ "$NUM" =~ ^[1-9][0-9]{0,3}$ ]]; then
                echo "Error: -n requires a decimal integer from 1 to 9999" >&2
                exit 1
            fi
            ;;
        f) FORCE=true ;;
        :)
            echo "Error: Option -$OPTARG requires an argument" >&2
            exit 1
            ;;
        \?)
            echo "Error: Invalid option -$OPTARG" >&2
            exit 1
            ;;
    esac
done

# Remove processed options
shift $((OPTIND - 1))

# Check positional arguments
if [ $# -eq 0 ]; then
    echo "Error: Missing input file" >&2
    usage
fi

INPUT="$1"

# Display configuration
if $VERBOSE; then
    echo "Input:      $INPUT"
    echo "Output:     ${OUTPUT:-stdout}"
    echo "Iterations: $NUM"
    echo "Force:      $FORCE"
fi
```

---

## 4. Long Options (GNU-style)

### 4.1 Manual Implementation

```bash
#!/bin/bash

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
            [[ $# -ge 2 && -n $2 ]] || { echo "Missing nonempty option value" >&2; exit 1; }
            OUTPUT="$2"
            shift 2
            ;;
        --output=*)
            OUTPUT="${1#*=}"
            [[ -n $OUTPUT ]] || { echo "Empty option value" >&2; exit 1; }
            shift
            ;;
        -c|--config)
            [[ $# -ge 2 && -n $2 ]] || { echo "Missing nonempty option value" >&2; exit 1; }
            CONFIG="$2"
            shift 2
            ;;
        --config=*)
            CONFIG="${1#*=}"
            [[ -n $CONFIG ]] || { echo "Empty option value" >&2; exit 1; }
            shift
            ;;
        --)
            shift
            break
            ;;
        -*)
            echo "Unknown option: $1" >&2
            exit 1
            ;;
        *)
            break
            ;;
    esac
done

ARGS=("$@")
```

### 4.2 Patterns for Long Options

```text
# Option with =
--config=value    # ${1#*=} extracts "value"

# Option with space
--config value    # $2 is "value", shift 2

# Support for both
case $1 in
    --config=*)
        CONFIG="${1#*=}"
        [[ -n $CONFIG ]] || { echo "Empty option value" >&2; exit 1; }
        shift
        ;;
    --config)
        [[ $# -ge 2 && -n $2 ]] || { echo "Missing nonempty option value" >&2; exit 1; }
        CONFIG="$2"
        shift 2
        ;;
esac
```

---

## 5. Argument Validation

```bash
# Check if file exists
validate_file() {
    local file="$1"
    [[ -f "$file" ]] || { echo "Error: '$file' does not exist" >&2; exit 1; }
    [[ -r "$file" ]] || { echo "Error: cannot read '$file'" >&2; exit 1; }
}

# Check if it's a number
validate_number() {
    local num="$1"
    [[ "$num" =~ ^[0-9]+$ ]] || { echo "Error: '$num' is not a number" >&2; exit 1; }
}

# Check range
validate_range() {
    local num="$1" min="$2" max="$3"
    [[ $num -ge $min && $num -le $max ]] || {
        echo "Error: value must be between $min and $max" >&2
        exit 1
    }
}
```

---

## 6. Parser Template (processing remains an exercise)

The log function succeeds in quiet mode. Arity is checked before `$2` is read;
`set -e` does not replace explicit status handling. The following template parses
options and reports the input; implement and test the processing/dry-run/output
contract in the marked exercise section before calling it a complete processor.

```bash
#!/bin/bash
set -euo pipefail

readonly VERSION="1.0"
readonly SCRIPT_NAME=$(basename "$0")

VERBOSE=false
DRY_RUN=false
OUTPUT=""

usage() {
    cat << EOF
$SCRIPT_NAME v$VERSION

Usage: $SCRIPT_NAME [options] <input>

Options:
    -h, --help      Help
    -V, --version   Version
    -v, --verbose   Verbose mode
    -n, --dry-run   Simulation
    -o, --output    Output file
EOF
}

log() { if "$VERBOSE"; then printf '[INFO] %s\n' "$*" >&2; fi; return 0; }
error() { echo "[ERROR] $*" >&2; exit 1; }

parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help) usage; exit 0 ;;
            -V|--version) echo "$VERSION"; exit 0 ;;
            -v|--verbose) VERBOSE=true; shift ;;
            -n|--dry-run) DRY_RUN=true; shift ;;
            -o|--output) [[ $# -ge 2 && -n $2 ]] || error "Missing output"; OUTPUT="$2"; shift 2 ;;
            --output=*) OUTPUT="${1#*=}"; [[ -n $OUTPUT ]] || error "Empty output"; shift ;;
            --) shift; break ;;
            -*) error "Unknown option: $1" ;;
            *) break ;;
        esac
    done
    
    [[ $# -ge 1 ]] || error "Missing input"
    INPUT="$1"
}

main() {
    parse_args "$@"
    log "Processing: $INPUT"
    # Logic here...
}

main "$@"
```

---

## 7. Practical Exercises

### Exercise 1: Script with getopts
```bash
#!/bin/bash
while getopts ":vo:n:" opt; do
    case $opt in
        v) VERBOSE=true ;;
        o) OUTPUT="$OPTARG" ;;
        n) NUM="$OPTARG" ;;
        :) echo "Missing arg for -$OPTARG"; exit 1 ;;
        \?) echo "Invalid option: -$OPTARG"; exit 1 ;;
    esac
done
shift $((OPTIND-1))
```

### Exercise 2: Input Validation
```bash
#!/bin/bash
[[ $# -ge 1 ]] || { echo "Usage: $0 <file>"; exit 1; }
[[ -f "$1" ]] || { echo "File does not exist"; exit 1; }
[[ -r "$1" ]] || { echo "No read permissions"; exit 1; }
```

---

## Cheat Sheet

```text
# GETOPTS
while getopts ":hvo:n:" opt; do
    case $opt in
        h) usage ;;
        v) VERBOSE=true ;;
        o) OUTPUT="$OPTARG" ;;
        :) echo "Missing arg" ;;
        \?) echo "Invalid option" ;;
    esac
done
shift $((OPTIND-1))

# OPTSTRING
"abc"       # -a -b -c without arguments
"a:b:c"     # -a ARG, -b ARG, -c without arg
":abc"      # silent error mode

# LONG OPTIONS
--opt=val   # ${1#*=} extracts val
--opt val   # $2, shift 2

# VALIDATION
[[ -f "$f" ]]           # file exists
[[ "$n" =~ ^[0-9]+$ ]]  # is number
[[ -n "$v" ]]           # non-empty
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
   - Finalise the legacy recorder metadata envelope (not a content signature)
   - Automatically upload the file to the server

3. **Check the final message**:
   - ✅ `UPLOAD SUCCESSFUL!` - the assignment was submitted
   - ❌ If upload fails, the `.cast` file is saved locally - send it manually later with the displayed command

> Keep the original `.cast` as evidence. The distributed recorder envelopes do not
> bind event content and do not authenticate the student. Local preflight exit 0
> establishes format only (`UNVERIFIED` authentication, `UNCONFIRMED` readiness).
> The separate SEM07 `# SIGNATURE:` contract binds a content digest only when it
> verifies with an explicitly supplied key; identity and institutional acceptance
> still require an approved protocol. See the [current recording contract](../../../03_GUIDES/RECORDING_CONTRACT.md)
> and [verification contract](../../../SEM07/homework_evaluation/VERIFICATION_AND_GRADING_CONTRACT.md).

---

*By Revolvix for OPERATING SYSTEMS class | restricted licence 2017-2030*
