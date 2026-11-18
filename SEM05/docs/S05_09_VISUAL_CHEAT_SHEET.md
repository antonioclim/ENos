# S05_09 - Visual Cheat Sheet: Quick Reference

> **Operating Systems** | ASE Bucharest - CSIE  
> Seminar 5: Advanced Bash Scripting
> Version: 2.0.0 | Date: 2025-01

---

> **Current use and evidence:** These are teaching materials, with intentional WRONG/TODO examples retained. The [teaching and assessment contract](TEACHING_CONTRACT.md) separates runnable references, proposed assessment rules and historical claims whose provenance remains unresolved. Percentages and first-person anecdotes below are retained author-supplied history, not independently verified empirical findings.


## STRICT MODE (Memorise: "euo pipefail IFS")

```bash
#!/bin/bash


set -euo pipefail
IFS=$'\n\t'
```

*(Bash has ugly syntax, I admit. But it runs everywhere, and that matters enormously in practice.)*

| Option | What it does | Without it |
|--------|--------------|------------|
| `-e` | Exit on error | Continues after errors |
| `-u` | Error on undefined var | Undefined var = "" |
| `-o pipefail` | Rightmost non-zero pipeline status; all zero gives zero | Returns last |
| `IFS=...` | Changes splitting; quoting is still required | Space separates |

### Trap: -e does NOT work in:
```
if command          # in conditions
command || other    # with ||
command && other    # with &&
! command           # with negation
```

---

## FUNCTIONS

### Syntax
```bash
function_name() {
    local var="value"    # ALWAYS local!
    echo "result"        # "returns" values
    return 0             # only exit code (0-255)
}

result=$(function_name arg1 arg2)
```

### Arguments
```
$1, $2, ...   Positional arguments
$@            All arguments (as array)
$#            Number of arguments
$0            Script name
```

### COMMON MISTAKES

```bash
# WRONG: global var
process() {
    count=0    # Modifies global!
}

# CORRECT: local var
process() {
    local count=0
}

# WRONG: return for values
get_sum() { return $((a+b)); }  # Max 255!

# CORRECT: echo for values
get_sum() { echo $((a+b)); }
result=$(get_sum)
```

---

## INDEXED ARRAYS

### Creation and Access
```bash
arr=("a" "b" "c")      # Creation
arr+=("d")             # Append
arr[0]="A"             # Modification

${arr[0]}              # Element (index 0!)
${arr[@]}              # All elements
${#arr[@]}             # Length
${!arr[@]}             # All indices
```

### Iteration
```text
# CORRECT - with quotes!
for item in "${arr[@]}"; do
    echo "$item"
done

# WRONG - without quotes
for item in ${arr[@]}; do    # Word splitting!
```

### Slice
```bash
${arr[@]:1:3}    # From index 1, 3 elements
${arr[@]:2}      # From index 2 to end
```

---

## ASSOCIATIVE ARRAYS

### Creation (MANDATORY declare -A!)
```bash
declare -A config              # MANDATORY!
config[host]="localhost"
config[port]="8080"

# Or inline:
declare -A config=(
    [host]="localhost"
    [port]="8080"
)
```

### Access
```bash
${config[host]}         # Value for key
${!config[@]}           # All keys
${config[@]}            # All values
${#config[@]}           # Number of keys
```

### Iteration
```bash
for key in "${!config[@]}"; do
    echo "$key = ${config[$key]}"
done
```

### WITHOUT declare -A:
```bash
hash[host]="x"    # hash[0]="x" (host=0!)
hash[port]="y"    # hash[0]="y" (overwrites!)
```

---

## TRAP and CLEANUP

### Standard Pattern
```bash
TEMP_FILE=""

cleanup() {
    local exit_code=$?
    if [[ -n ${TEMP_FILE:-} ]]; then rm -f -- "$TEMP_FILE"; fi
    exit $exit_code
}

trap cleanup EXIT           # Shell exit; not SIGKILL or machine failure
trap 'echo "Ctrl+C"' INT   # On Ctrl+C
```

### Common Signals
```
EXIT    On shell exit; not SIGKILL or abrupt machine failure
ERR     Eligible failure; independent of set -e; set -E controls inheritance
INT     Ctrl+C
TERM    kill (default)
DEBUG   Before each command
```

### Trap for Debugging
```bash
trap 'echo "Line $LINENO: $BASH_COMMAND"' DEBUG
```

---

## CHECKS

### Files
```bash
[[ -f "$f" ]]    # File exists
[[ -d "$d" ]]    # Directory exists
[[ -r "$f" ]]    # Readable
[[ -w "$f" ]]    # Writable
[[ -x "$f" ]]    # Executable
[[ -s "$f" ]]    # Non-empty
```

### Strings
```bash
[[ -z "$s" ]]    # Empty
[[ -n "$s" ]]    # Non-empty
[[ "$a" == "$b" ]]   # Equal
[[ "$a" != "$b" ]]   # Different
[[ "$s" =~ regex ]]  # Regex match
```

### Numbers
```bash
[[ $a -eq $b ]]    # Equal
[[ $a -ne $b ]]    # Not equal
[[ $a -lt $b ]]    # Less than
[[ $a -le $b ]]    # Less or equal
[[ $a -gt $b ]]    # Greater than
[[ $a -ge $b ]]    # Greater or equal
```

### Logical
```bash
[[ cond1 && cond2 ]]    # AND
[[ cond1 || cond2 ]]    # OR
[[ ! cond ]]            # NOT
```

---

## DEFAULT VALUES

```bash


${VAR:-default}     # Returns default if VAR unset/empty
${VAR:=default}     # Sets VAR to default if unset/empty
${VAR:?error msg}   # Error if VAR unset/empty
${VAR:+alternate}   # Returns alternate if VAR IS set
```

*Personal note: Many prefer `zsh`, but I stick with Bash because it's the standard on servers. Consistency beats comfort.*

### Pattern for Arguments
```bash
INPUT="${1:-default.txt}"      # Optional arg
OUTPUT="${2:-}"                # Optional arg (can be empty)
: "${REQUIRED:?Must be set}"   # Required variable
```

---

## DEBUGGING

### Activation
```bash
set -x         # Display commands (xtrace)
set -v         # Display lines read (verbose)
set +x         # Deactivate

bash -x script.sh    # Run with debug
```

### Custom PS4
```bash
PS4='+ ${BASH_SOURCE}:${LINENO}: '
```

### Debug Variables
```bash
$LINENO          # Current line
$BASH_COMMAND    # Current command
$FUNCNAME        # Current function
$BASH_SOURCE     # Current file
${PIPESTATUS[@]} # Exit codes from pipe
```

### Conditional Debug Pattern
```bash
DEBUG="${DEBUG:-false}"
debug() {
    if [[ "$DEBUG" == "true" ]]; then printf '[DEBUG] %s\n' "$*" >&2; fi
    return 0
}
```

---

## QUICK TEMPLATE

```bash
#!/bin/bash
set -euo pipefail

readonly SCRIPT_NAME=$(basename "$0")
die() { echo "FATAL: $*" >&2; exit 1; }

cleanup() {
    local ec=$?
    # cleanup
    exit $ec
}
trap cleanup EXIT

[[ $# -ge 1 ]] || die "Usage: $SCRIPT_NAME <arg>"

main() {
    echo "Hello from $SCRIPT_NAME"
}

main "$@"
```

---

## FREQUENT MISTAKES

| Wrong | Correct |
|-------|---------|
| `$arr[@]` | `${arr[@]}` |
| `${arr[@]}` in for | `"${arr[@]}"` |
| `hash[key]=v` | `declare -A hash; hash[key]=v` |
| `var in func` | `local var in func` |
| `return "string"` | `echo "string"` |
| `cd $dir; rm *` | Establish owned fixture; `cd -- "$owned" || exit 1`; remove only owned entries |
| `$(ls *.txt)` | Quoted globs or a checked NUL-delimited `find` stream |

---

## QUICK REFERENCE CARD

```
╔══════════════════════════════════════════════════════════════╗
║  BASH ADVANCED - QUICK REFERENCE                             ║
╠══════════════════════════════════════════════════════════════╣
║  ROBUSTNESS          FUNCTIONS          ARRAYS               ║
║  ─────────────       ─────────────      ──────────           ║
║  set -euo pipefail   local var=x        arr=(a b c)          ║
║  IFS=$'\n\t'         echo "return"      "${arr[@]}"          ║
║                      return 0-255       ${#arr[@]}           ║
║                                                              ║
║  ASSOCIATIVE         TRAP               DEFAULTS             ║
║  ─────────────       ─────────────      ──────────           ║
║  declare -A h        trap cmd EXIT      ${V:-def}            ║
║  h[key]="val"        trap cmd INT       ${V:=def}            ║
║  ${!h[@]}            trap cmd ERR       ${V:?err}            ║
║                                                              ║
║  CHECKS              DEBUG              ITERATION            ║
║  ─────────────       ─────────────      ──────────           ║
║  [[ -f "$f" ]]       set -x / +x        for i in "${a[@]}"   ║
║  [[ -d "$d" ]]       $LINENO            for k in "${!h[@]}"  ║
║  [[ -n "$s" ]]       PS4='...'          while read line      ║
╚══════════════════════════════════════════════════════════════╝
```

---

*Print this page for quick reference during labs and exams!*

*Laboratory material for the Operating Systems course | ASE Bucharest - CSIE*
