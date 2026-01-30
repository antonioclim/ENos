# S05 - Resources and References

> **Operating Systems** | ASE Bucharest - CSIE  
> Seminar 5: Advanced Bash Scripting

---

## Official Documentation

| Resource | URL | Description |
|----------|-----|-------------|
| **Bash Manual** | https://www.gnu.org/software/bash/manual/ | Complete official reference |
| **Bash Reference** | https://www.gnu.org/software/bash/manual/bash.html | Navigable HTML |
| **POSIX Shell** | https://pubs.opengroup.org/onlinepubs/9699919799/utilities/V3_chap02.html | POSIX Standard |

---

## Tools

### ShellCheck - Bash Linter

```bash
# Installation
sudo apt install shellcheck      # Ubuntu/Debian
brew install shellcheck          # macOS

# Usage
shellcheck script.sh
shellcheck -f gcc script.sh      # GCC format
shellcheck -x script.sh          # Follow sources
```

**Online:** https://www.shellcheck.net/

### Explainshell - Command Explainer

**URL:** https://explainshell.com/

Paste any command and receive detailed explanation for each part.

---

## Tutorials and Guides

### Style Guides

| Guide | URL |
|-------|-----|
| Google Shell Style Guide | https://google.github.io/styleguide/shellguide.html |
| Bash Best Practices | https://bertvv.github.io/cheat-sheets/Bash.html |
| Pure Bash Bible | https://github.com/dylanaraps/pure-bash-bible |

### Interactive Tutorials

| Resource | URL | Level |
|----------|-----|-------|
| Learn Shell | https://www.learnshell.org/ | Beginner |
| Bash Academy | https://guide.bash.academy/ | Intermediate |
| Advanced Bash Guide | https://tldp.org/LDP/abs/html/ | Advanced |

---

## Video Resources

### Recommended YouTube Channels

- **Learn Linux TV** - Practical Linux/Bash tutorials
- **NetworkChuck** - DevOps and scripting
- **The Linux Foundation** - Official courses

### Online Courses

| Platform | Course | Duration |
|----------|--------|----------|
| Linux Foundation | Linux System Administration | 40h |
| Udemy | Bash Scripting and Shell Programming | 8h |
| Pluralsight | Bash Shell Scripting | 5h |

---

## Cheat Sheets

### Quick Reference

```bash
# === VARIABLES ===
var="value"                 # Assignment (no spaces!)
echo "$var"                 # Expansion (with quotes)
readonly CONST="value"      # Constant
local var="value"           # Local variable (in functions)
export VAR="value"          # Environment variable

# === DEFAULTS ===
${var:-default}             # Return default if var is empty/unset
${var:=default}             # Set and return default
${var:+value}               # Return value if var is set
${var:?error}               # Error if var is empty/unset

# === STRING OPERATIONS ===
${#var}                     # String length
${var#pattern}              # Remove pattern from start (shortest)
${var##pattern}             # Remove pattern from start (longest)
${var%pattern}              # Remove pattern from end (shortest)
${var%%pattern}             # Remove pattern from end (longest)
${var/old/new}              # Replace first occurrence
${var//old/new}             # Replace all occurrences
${var:start:length}         # Substring

# === INDEXED ARRAYS ===
arr=("a" "b" "c")           # Creation
${arr[0]}                   # Element (indexing from 0!)
${arr[@]}                   # All elements
${#arr[@]}                  # Number of elements
${!arr[@]}                  # All indices
arr+=("d")                  # Append
unset arr[1]                # Delete element (does NOT reindex!)

# === ASSOCIATIVE ARRAYS ===
declare -A hash             # MANDATORY!
hash[key]="value"           # Setting
${hash[key]}                # Access
${!hash[@]}                 # All keys
${hash[@]}                  # All values

# === ITERATION ===
for item in "${arr[@]}"; do echo "$item"; done    # With quotes!
for key in "${!hash[@]}"; do echo "$key=${hash[$key]}"; done
for ((i=0; i<10; i++)); do echo $i; done

# === FUNCTIONS ===
func() {
    local var="value"       # ALWAYS local!
    echo "$1"               # First argument
    return 0                # Exit code (only 0-255!)
}
result=$(func "arg")        # Capture output

# === CONDITIONS ===
[[ -f file ]]               # File exists
[[ -d dir ]]                # Directory exists
[[ -r file ]]               # Can read
[[ -w file ]]               # Can write
[[ -x file ]]               # Can execute
[[ -z "$var" ]]             # Empty string
[[ -n "$var" ]]             # Non-empty string
[[ "$a" == "$b" ]]          # String equality
[[ "$a" =~ regex ]]         # Regex match
[[ $a -eq $b ]]             # Numeric equality
[[ $a -lt $b ]]             # Less than

# === ROBUSTNESS ===
set -e                      # Exit on error
set -u                      # Error for undefined variables
set -o pipefail             # Propagate errors in pipes
set -euo pipefail           # All three

# === TRAP ===
trap cleanup EXIT           # On any exit
trap 'handler $LINENO' ERR  # On error
trap 'echo INT' INT TERM    # On Ctrl+C

# === REDIRECT ===
cmd > file                  # Stdout to file
cmd >> file                 # Append stdout
cmd 2> file                 # Stderr to file
cmd &> file                 # Stdout and stderr
cmd 2>&1                    # Stderr to stdout
cmd < file                  # Stdin from file
cmd <<< "string"            # Here string
cmd << EOF                  # Here document
...
EOF

# === PIPES AND SUBSTITUTION ===
cmd1 | cmd2                 # Pipe
$(cmd)                      # Command substitution
<(cmd)                      # Process substitution (as file)
```

---

## Debugging

### Debug Options

```bash
set -x                      # Trace executed commands
set -v                      # Verbose - display lines read
set -xv                     # Both

# Selective debug
set -x
# code to debug
set +x

# From command line
bash -x script.sh           # Run with trace
bash -n script.sh           # Syntax check (does not execute)
```

### Custom PS4

```bash
# PS4 controls the prefix for trace
export PS4='+ ${BASH_SOURCE}:${LINENO}:${FUNCNAME[0]:+${FUNCNAME[0]}(): }'
```

### Useful Variables for Debug

```bash
$LINENO                     # Current line number
$FUNCNAME                   # Current function name
${FUNCNAME[@]}              # Function stack
$BASH_SOURCE                # Current file
${BASH_SOURCE[@]}           # File stack
$BASH_COMMAND               # Current command
$PIPESTATUS                 # Exit codes from pipe
```

---

## Useful Links

### Community

- **Stack Overflow** - https://stackoverflow.com/questions/tagged/bash
- **Unix Stack Exchange** - https://unix.stackexchange.com/
- **Reddit r/bash** - https://www.reddit.com/r/bash/

### Useful Repositories

| Repo | URL | Description |
|------|-----|-------------|
| Bash-it | https://github.com/Bash-it/bash-it | Customisation framework |
| Oh My Bash | https://github.com/ohmybash/oh-my-bash | Themes and plugins |
| Awesome Bash | https://github.com/awesome-lists/awesome-bash | Resource list |

---

## Online Playground

| Tool | URL | Features |
|------|-----|----------|
| Replit | https://replit.com/ | Complete online IDE |
| JDoodle | https://www.jdoodle.com/test-bash-shell-script-online | Simple, fast |
| OnlineGDB | https://www.onlinegdb.com/online_bash_shell | With debugger |

---

## Standardisation and Portability

### POSIX vs Bash-isms

| Feature | POSIX | Bash |
|---------|-------|------|
| Shebang | `#!/bin/sh` | `#!/bin/bash` |
| Test | `[ ]` | `[[ ]]` (recommended) |
| Arrays | ❌ | ✅ |
| Associative arrays | ❌ | ✅ (4.0+) |
| `local` | ❌ (some shells) | ✅ |
| `[[ =~ ]]` | ❌ | ✅ (regex) |
| Process substitution | ❌ | ✅ `<()` |
| Here string | ❌ | ✅ `<<<` |

### Checking Bash Version

```bash
# Version
echo $BASH_VERSION

# Feature check
if ((BASH_VERSINFO[0] >= 4)); then
    echo "Bash 4+ features available"
fi
```

---

## Installing Modern Bash (if needed)

### Ubuntu/Debian

```bash
sudo apt update
sudo apt install bash
```

### macOS (Bash 5)

```bash
brew install bash
# Add to /etc/shells and change with chsh
```

### From Source

```bash
wget https://ftp.gnu.org/gnu/bash/bash-5.2.tar.gz
tar xzf bash-5.2.tar.gz
cd bash-5.2
./configure && make && sudo make install
```

---

*Material for Operating Systems course | ASE Bucharest - CSIE*
