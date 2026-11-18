# Cheat Sheet - Professional Bash Scripting

> **Operating Systems** | ASE Bucharest - CSIE
> Seminar 6: CAPSTONE Projects

---

> **Scope:** Bash 4.4+ / GNU/Linux. Reference fragments with placeholders are syntax illustrations, not complete programs. Only explicitly owned fixtures may be modified. See [TEACHING_CONTRACT.md](TEACHING_CONTRACT.md).

## Professional Script Structure

```bash
#!/usr/bin/env bash
# script_name.sh — scaffold; implement main before using it for real work.
set -euo pipefail
IFS=$'\n\t'
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd) || exit 1
readonly SCRIPT_DIR
SCRIPT_NAME=${0##*/}
TEMP_FILE=
LOG_FILE=${LOG_FILE:-} # Optional explicit path; stderr is the default.
log() {
    [[ $# -ge 1 ]] || return 2
    local level=$1 line; shift
    printf -v line '[%s] [%s] %s' "$(date -u +%FT%TZ)" "$level" "$*"
    printf '%s\n' "$line" >&2 || return 1
    [[ -z $LOG_FILE ]] || printf '%s\n' "$line" >> "$LOG_FILE" || return 1
    return 0
}
cleanup() { [[ -z ${TEMP_FILE:-} ]] || rm -f -- "$TEMP_FILE"; }
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM
usage() { printf 'Usage: %s --help | application_arguments\n' "$SCRIPT_NAME"; }
main() {
    if [[ ${1:-} == --help ]]; then usage; return 0; fi
    printf 'TODO: implement argument validation and application logic\n' >&2
    return 3
}
main "$@"
```

---

## Variables

### Declaration and Assignment
```bash
var="value"                # No spaces around =
readonly CONST="fixed"     # Constant (cannot be modified)
example_local() { local var="only in function"; printf '%s\n' "$var"; }
declare -i num=10          # Integer
declare -a arr=()          # Indexed array
declare -A map=()          # Associative array
```

### Expansion
```text
${var}                     # Value (safe in strings)
${var:-default}            # Default if unset/null
${var:=default}            # Set default if unset/null
${var:?error message}      # Error if unset/null
${var:+alternate}          # Alternate if set

${#var}                    # String length
${var%pattern}             # Remove suffix (shortest match)
${var%%pattern}            # Remove suffix (longest match)
${var#pattern}             # Remove prefix (shortest match)
${var##pattern}            # Remove prefix (longest match)

${var/pattern/replacement} # First replacement
${var//pattern/replacement} # All replacements
${var^}                    # First letter uppercase
${var^^}                   # All uppercase
${var,}                    # First letter lowercase
${var,,}                   # All lowercase
```

### Special Variables
```text
$0                         # Script name
$1, $2, ..., ${10}         # Positional arguments
$#                         # Number of arguments
$@                         # All arguments (separate)
$*                         # All arguments (one string)
"$@"                       # CORRECT: preserves quoting
$$                         # Main shell PID; unchanged in a Bash subshell
$BASHPID                   # PID of this Bash process
$!                         # Last background process PID
$?                         # Exit code of last command
$_                         # Last argument of previous command
```

---

## Control Structures

### Conditions
```bash
# [[ ]] syntax (preferred - safer)
if [[ condition ]]; then
    commands
elif [[ other_condition ]]; then
    commands
else
    commands
fi

# String comparisons
[[ "$a" == "$b" ]]         # Equal
[[ "$a" != "$b" ]]         # Different
[[ "$a" < "$b" ]]          # Lexicographically less
[[ "$a" =~ regex ]]        # Regex match
[[ -z "$a" ]]              # Empty string
[[ -n "$a" ]]              # Non-empty string

# Numeric comparisons
[[ $a -eq $b ]]            # Equal
[[ $a -ne $b ]]            # Different
[[ $a -lt $b ]]            # Less than
[[ $a -le $b ]]            # Less than or equal
[[ $a -gt $b ]]            # Greater than
[[ $a -ge $b ]]            # Greater than or equal

# Arithmetic (prefer (( )) for numbers)
(( a == b ))
(( a < b ))
(( a++ ))                  # Returns 1 when the old value is zero; consider a=$((a+1))
(( total = a + b * c ))

# Files
[[ -e "$file" ]]           # Exists
[[ -f "$file" ]]           # Regular file
[[ -d "$dir" ]]            # Directory
[[ -r "$file" ]]           # Readable
[[ -w "$file" ]]           # Writable
[[ -x "$file" ]]           # Executable
[[ -s "$file" ]]           # Non-zero size
[[ "$a" -nt "$b" ]]        # a newer than b
[[ "$a" -ot "$b" ]]        # a older than b

# Logical operators
[[ cond1 && cond2 ]]       # AND
[[ cond1 || cond2 ]]       # OR
[[ ! condition ]]          # NOT
```

### Loops
```bash
# For (C-style)
for ((i=0; i<10; i++)); do
    echo "$i"
done

# For (list)
for item in "${array[@]}"; do
    echo "$item"
done

# For (files - CORRECT)
for file in /path/*.txt; do
    [[ -e "$file" ]] || continue
    process "$file"
done

# While
while [[ condition ]]; do
    commands
done

# While read (reading file/output)
while IFS= read -r line || [[ -n $line ]]; do
    echo "Line: $line"
done < "$file"

# Until
until [[ condition ]]; do
    commands
done

# Break/Continue
break                      # Exit loop
continue                   # Skip to next iteration
```

### Case
```bash
case "$var" in
    pattern1)
        commands
        ;;
    pattern2|pattern3)
        commands
        ;;
    *)
        # default
        ;;
esac
```

---

## Functions

```bash
# Declaration
function_name() {
    local arg1="${1:?Argument 1 required}"
    local arg2="${2:-default}"
    
    # Logic
    
    return 0  # or other exit code
}

# Call
result=$(function_name "val1" "val2")
function_name "val1" "val2"
exit_code=$?

# Multiple output (using array)
get_data() {
    local -n result_ref=$1  # nameref (Bash 4.3+)
    result_ref=("item1" "item2" "item3")
}

declare -a data
get_data data
echo "${data[@]}"
```

---

## Arrays

### Indexed Array
```bash
# Declaration
declare -a arr=()
arr=("elem1" "elem2" "elem3")
arr[0]="first"

# Access
echo "${arr[0]}"           # Specific element
echo "${arr[@]}"           # All elements
echo "${#arr[@]}"          # Number of elements
echo "${!arr[@]}"          # All indices

# Iteration
for item in "${arr[@]}"; do
    echo "$item"
done

# Slice
echo "${arr[@]:1:2}"       # From index 1, 2 elements

# Append
arr+=("new_element")
```

### Associative Array (Hash/Map)
```bash
# Declaration (declare -A required)
declare -A map=()
map=([key1]="value1" [key2]="value2")
map["key3"]="value3"

# Access
echo "${map[key1]}"
echo "${map[@]}"           # All values
echo "${!map[@]}"          # All keys
echo "${#map[@]}"          # Number of pairs

# Key check
if [[ -v map[key1] ]]; then
    echo "Key exists"
fi

# Iteration
for key in "${!map[@]}"; do
    echo "$key -> ${map[$key]}"
done
```

---

## I/O and Redirections

```bash
# Basic redirections
command > file             # Stdout to file (overwrite)
command >> file            # Stdout to file (append)
command 2> file            # Stderr to file
command &> file            # Stdout + stderr to file
command > file 2>&1        # Equivalent (portable)

# Pipe
command1 | command2        # Stdout cmd1 -> stdin cmd2
command1 |& command2       # Stdout + stderr -> stdin

# Process substitution
diff <(command1) <(command2)
while IFS= read -r line; do printf '%s\n' "$line"; done < <(command)
# Consumer success does not prove the process-substitution producer succeeded.

# Here-doc
cat << 'EOF'
Literal text $var is not expanded
EOF

cat << EOF
Text with expansion: $var
EOF

# Here-string
command <<< "string input"

# File descriptors
exec 3> outfile            # Open FD 3 for writing
echo "text" >&3            # Write to FD 3
exec 3>&-                  # Close FD 3

exec 4< infile             # Open FD 4 for reading
read line <&4              # Read from FD 4
exec 4<&-                  # Close FD 4
```

---

## Text Processing

### Grep
```bash
grep "pattern" file        # Lines containing pattern
grep -i "pattern" file     # Case insensitive
grep -v "pattern" file     # Lines NOT containing
grep -E "regex" file       # Extended regex
grep -o "pattern" file     # Only matching part
grep -c "pattern" file     # Count matches
grep -n "pattern" file     # With line numbers
grep -r "pattern" dir/     # Recursive in directory
grep -l "pattern" files    # Only filenames
```

### Sed
```bash
sed 's/old/new/' file      # First replacement per line
sed 's/old/new/g' file     # All replacements
sed -i 's/old/new/g' file  # In-place edit
sed -n '5p' file           # Print only line 5
sed -n '5,10p' file        # Lines 5-10
sed '5d' file              # Delete line 5
sed '/pattern/d' file      # Delete lines with pattern
sed 's/.*://' file         # Delete up to :
```

### Awk
```bash
awk '{print $1}' file      # First column
awk '{print $NF}' file     # Last column
awk -F: '{print $1}' file  # Separator : 
awk '/pattern/' file       # Lines with pattern
awk 'NR==5' file           # Line 5
awk 'NR>=5 && NR<=10' file # Lines 5-10
awk '{sum+=$1} END{print sum}' file  # Sum column
awk '{print NR": "$0}' file # Number lines

# Complex awk
awk '
BEGIN { FS=":"; OFS="\t" }
/pattern/ { count++; print $1, $3 }
END { print "Total:", count }
' file
```

### Cut, Sort, Uniq
```bash
cut -d: -f1 file           # Column 1, separator :
cut -c1-10 file            # Characters 1-10

sort file                  # Alphabetic sort
sort -n file               # Numeric sort
sort -r file               # Reverse
sort -k2 file              # By column 2
sort -t: -k3 -n file       # Column 3, separator :, numeric
sort -u file               # Unique (like sort | uniq)

uniq file                  # Remove consecutive duplicates
uniq -c file               # With count
uniq -d file               # Only duplicates
```

---

## Error Handling

```bash
# Set options
set -e                     # Exit for eligible failures; conditional/list/pipeline exceptions apply
set -u                     # Error for undefined variables
set -o pipefail            # Pipeline status = rightmost nonzero status, or 0
set -x                     # Debug mode (display commands)

# Trap
trap cleanup EXIT         # On shell exit; not SIGKILL or host loss
trap 'exit 130' INT
trap 'exit 143' TERM
trap 'echo "Error line $LINENO" >&2' ERR  # Eligible failures, with the same exceptions as -e

# Error handling pattern
command || {
    log "ERROR" "Command failed"
    exit 1
}

# Or with if
if ! command; then
    log "ERROR" "Command failed"
    exit 1
fi

# Validated retry helper: attempts, delay seconds, backoff, executable argv.
source SEM06/scripts/examples/retry.sh
# A harmless example: two unsuccessful attempts, preserve the final status 7.
if retry 2 0 1 bash -c 'exit 7'; then :; else printf 'Final status: %s\n' "$?"; fi
```

---

## Argument Parsing

### Getopts (POSIX, recommended)
```bash
usage() {
    echo "Usage: $0 [-v] [-c config] [-n num] file..."
}

verbose=false
config=""
num=10

while getopts ":vc:n:h" opt; do
    case $opt in
        v) verbose=true ;;
        c) config="$OPTARG" ;;
        n) num="$OPTARG" ;;
        h) usage; exit 0 ;;
        :) echo "Option -$OPTARG requires argument" >&2; usage; exit 2 ;;
        \?) echo "Invalid option: -$OPTARG" >&2; usage; exit 2 ;;
    esac
done

shift $((OPTIND - 1))
files=("$@")
```

### Long Options Manual
```bash
while [[ $# -gt 0 ]]; do
    case "$1" in
        -v|--verbose)
            verbose=true
            shift
            ;;
        -c|--config)
            [[ $# -ge 2 && -n $2 ]] || { usage >&2; exit 2; }
            config="$2"
            shift 2
            ;;
        -n|--number)
            [[ $# -ge 2 && $2 =~ ^[0-9]{1,6}$ ]] || { usage >&2; exit 2; }
            num=$((10#$2))
            shift 2
            ;;
        -h|--help)
            usage; exit 0
            ;;
        --)
            shift
            break
            ;;
        -*)
            echo "Unknown option: $1" >&2
            usage; exit 2
            ;;
        *)
            break
            ;;
    esac
done

files=("$@")
```

---

## Debugging

```bash
# Enable debug
set -x                     # Start trace
set +x                     # Stop trace

bash -x script.sh          # Run with trace
bash -n script.sh          # Syntax check (no execution)
bash -v script.sh          # Display lines before execution

# Selective debug
debug() {
    if [[ ${DEBUG:-false} == true ]]; then printf 'DEBUG: %s\n' "$*" >&2; fi
    return 0
}

# Trace functions
set -o functrace           # Inherit DEBUG and RETURN traps; ERR uses errtrace (-E)

# Detailed logging
PS4='+ ${BASH_SOURCE}:${LINENO}:${FUNCNAME[0]:-main}: '
set -x

# Assert a predicate argv; do not evaluate a caller-supplied shell program.
assert() {
    [[ $# -ge 2 ]] || return 2
    local message=$1; shift
    if "$@"; then return 0; fi
    printf 'ASSERT FAILED: %s\n' "$message" >&2
    return 1
}
assert "Config file must exist" test -f "${config_file:?Set a fixture path}"
```

---

## Networking

```bash
# Curl
curl -s "$url"             # Silent
curl -f "$url"             # Fail on HTTP error
curl -o file "$url"        # Save to file
curl -I "$url"             # Headers only
curl -X POST -d "data" "$url"  # POST request
curl -H "Authorization: Bearer $token" "$url"  # Custom header

# Check port
nc -zv host port           # TCP check
timeout 5 bash -c "</dev/tcp/host/port" && echo "Open"

# Get IPs
hostname -I                # All IPs
ip addr show | grep 'inet '

# Download with wget
wget -q "$url" -O file     # Quiet, output to file
wget -c "$url"             # Continue interrupted download
```

---

## Security Best Practices

```bash
# 1. Quoting - ALWAYS quote variables
printf 'Planned argument: <%s>\n' "$file" # One exact path
printf 'Split argument: <%s>\n' $file    # Intentionally WRONG demonstration; no deletion

# 2. Validate input
[[ "$input" =~ ^[a-zA-Z0-9_]+$ ]] || die "Invalid input"

# 3. Secure temp files
temp_file=
trap '[[ -z ${temp_file:-} ]] || rm -f -- "$temp_file"' EXIT
temp_file=$(mktemp)

# 4. Avoid eval
# WRONG
# eval "$user_input" # Intentionally WRONG: executes untrusted shell syntax

# 5. Use arrays for commands with arguments
cmd=("command" "--arg1" "--arg2" "$variable")
"${cmd[@]}"

# 6. Set PATH explicitly
PATH="/usr/local/bin:/usr/bin:/bin"
export PATH

# 7. Don't store passwords in scripts
password=$(cat /secure/path/password_file)
# or
read -s -p "Password: " password
```

---

## /proc Filesystem

```bash
# CPU
cat /proc/cpuinfo
cat /proc/stat             # CPU times
source SEM06/scripts/examples/monitor_examples.sh
if cpu=$(get_cpu_usage 0.2); then printf '%s%%\n' "$cpu"; else printf 'unavailable\n'; fi

# Memory
cat /proc/meminfo
free -h
awk '/MemTotal|MemFree|MemAvailable/' /proc/meminfo

# Process info
cat /proc/$$/status        # Current process status
cat /proc/$$/cmdline       # Command line
ls -la /proc/$$/fd/        # File descriptors
cat /proc/$$/limits        # Limits

# System
cat /proc/loadavg          # Load average
cat /proc/uptime           # Uptime
cat /proc/version          # Kernel version

# Disk
cat /proc/diskstats
cat /proc/mounts
```

---

## Cron & Systemd

### Cron
```cron
# Format: min hour day month weekday command
# Edit: crontab -e

# Examples
*/5 * * * *   command       # Every 5 minutes
0 3 * * *     command       # Daily at 3:00
0 0 * * 0     command       # Sunday at midnight
0 0 1 * *     command       # First day of month

# Best practices
SHELL=/bin/bash
PATH=/usr/local/bin:/usr/bin:/bin
MAILTO="" # No mail in the local teaching example

0 3 * * * /path/script.sh >> /var/log/script.log 2>&1
```

### Systemd Service
```ini
# /etc/systemd/system/myservice.service
[Unit]
Description=My Service
After=network.target

[Service]
Type=oneshot
User=myuser
WorkingDirectory=/opt/myapp
ExecStart=/opt/myapp/start.sh
# A timer starts a bounded job that exits; a continuous service needs a separate unit.

[Install]
WantedBy=multi-user.target
```

### Systemd Timer
```ini
# /etc/systemd/system/myservice.timer
[Unit]
Description=Run My Service Daily

[Timer]
OnCalendar=*-*-* 03:00:00
# Alternative: OnCalendar=daily. Multiple active directives are combined, not overridden.
Persistent=true

[Install]
WantedBy=timers.target
```

The timer example requires a separately configured, bounded oneshot service. Paths and user names above are placeholders. Installation/activation is a distinct host action; this reference does not perform it.

```bash
systemd-analyze calendar '*-*-* 03:00:00'
# Read-only inspection on a host with a systemd manager:
systemctl list-timers
```

---

## Quick Reference - Frequently Used Commands

The following is a non-executable syntax reference. Deletion, permission changes, signals, downloads and privileged commands require explicitly selected owned targets or an authorised host operation.

```text
# Files and directories
find . -name "*.log" -mtime +7 -delete
find . -type f -exec chmod 644 {} \;
du -sh */                  # Directory sizes
tree -L 2                  # Tree 2 levels

# Processes
ps aux | grep process
pgrep -f "pattern"
pkill -f "pattern"
kill -9 $pid
nohup command &

# Disk
df -h                      # Disk space
du -sh *                   # File/dir sizes
lsblk                      # Block devices
mount | grep /dev

# Networking
ss -tlnp                   # Listening ports
netstat -an | grep LISTEN
ip route                   # Routing table
dig domain.com             # DNS lookup

# Users
id                         # Current user info
whoami                     # Username
groups                     # Groups
sudo -l                    # Sudo permissions

# System
uname -a                   # System info
lsb_release -a            # Distribution info
uptime                     # Uptime + load
dmesg | tail               # Kernel messages
journalctl -xe             # System logs
```

---

*Cheat Sheet for Operating Systems | ASE Bucharest - CSIE*
*Version 1.0 | Seminar 6 CAPSTONE*
