# S02_APPENDIX - Seminar 2 References (Redistributed)

> **Operating Systems** | ASE Bucharest - CSIE  
> Supplementary Material

---

## Supplementary ASCII Diagrams

### Data Flow with Pipes

```
┌──────────────────────────────────────────────────────────────────────┐
│                        PIPELINE: cat file | grep error | wc -l      │
└──────────────────────────────────────────────────────────────────────┘

  ┌─────────┐      PIPE       ┌─────────────┐      PIPE       ┌────────┐
  │   cat   │ ──────────────► │    grep     │ ──────────────► │   wc   │
  │  file   │    stdout│stdin │   error     │    stdout│stdin │   -l   │
  └─────────┘                 └─────────────┘                 └────────┘
       │                            │                              │
       │                            │                              │
       ▼                            ▼                              ▼
  Reads entire                Filters lines                 Counts remaining
  contents                    containing "error"            lines
  from file

  TECHNICAL DETAIL:
  ┌────────────────────────────────────────────────────────────────────┐
  │  Process 1 (cat)          Process 2 (grep)        Process 3 (wc)  │
  │  ┌─────────────┐          ┌─────────────┐         ┌─────────────┐ │
  │  │ stdin  = 0 │          │ stdin  = 0 │◄────────│ stdin  = 0 │ │
  │  │ stdout = 1 │──────────►│ stdout = 1 │──────────►│ stdout = 1 │ │
  │  │ stderr = 2 │          │ stderr = 2 │         │ stderr = 2 │ │
  │  └─────────────┘          └─────────────┘         └─────────────┘ │
  │       │                        │                        │        │
  │       │        KERNEL PIPE BUFFER (64KB default)        │        │
  │       └────────────────────────┴────────────────────────┘        │
  └────────────────────────────────────────────────────────────────────┘
```

### Control Operators

```
┌──────────────────────────────────────────────────────────────────────┐
│                      BASH CONTROL OPERATORS                          │
├──────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  cmd1 ; cmd2              SEQUENTIAL                                 │
│  ┌─────┐     ┌─────┐                                                │
│  │cmd1 │ ──► │cmd2 │     Executes cmd2 ALWAYS after cmd1            │
│  └─────┘     └─────┘     (regardless of exit code)                  │
│                                                                      │
├──────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  cmd1 && cmd2             AND (SHORT-CIRCUIT)                       │
│  ┌─────┐                                                            │
│  │cmd1 │──┬── exit 0 ──► ┌─────┐                                    │
│  └─────┘  │              │cmd2 │  Executes cmd2 ONLY if cmd1 OK     │
│           │              └─────┘                                    │
│           └── exit ≠0 ──► STOP                                      │
│                                                                      │
├──────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  cmd1 || cmd2             OR (SHORT-CIRCUIT)                        │
│  ┌─────┐                                                            │
│  │cmd1 │──┬── exit 0 ──► STOP                                       │
│  └─────┘  │                                                         │
│           └── exit ≠0 ──► ┌─────┐                                   │
│                           │cmd2 │  Executes cmd2 ONLY if cmd1 FAIL  │
│                           └─────┘                                   │
│                                                                      │
├──────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  cmd &                    BACKGROUND                                 │
│  ┌─────┐                                                            │
│  │ cmd │ ──► Runs in background, shell continues immediately        │
│  └─────┘     PID displayed: [1] 12345                               │
│                                                                      │
├──────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  cmd1 | cmd2              PIPE                                       │
│  ┌─────┐     ┌─────┐                                                │
│  │cmd1 │────►│cmd2 │     stdout(cmd1) → stdin(cmd2)                 │
│  └─────┘     └─────┘     Runs SIMULTANEOUSLY                        │
│                                                                      │
└──────────────────────────────────────────────────────────────────────┘
```

### Complete I/O Redirection

```
┌──────────────────────────────────────────────────────────────────────┐
│                      FILE DESCRIPTORS                                │
├──────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  ┌─────────────┐                                                    │
│  │   PROCESS   │                                                    │
│  ├─────────────┤                                                    │
│  │ FD 0: stdin │◄──── keyboard / pipe / file                        │
│  │ FD 1: stdout│────► terminal / pipe / file                        │
│  │ FD 2: stderr│────► terminal / file                               │
│  │ FD 3+: other│────► explicitly opened files                       │
│  └─────────────┘                                                    │
│                                                                      │
├──────────────────────────────────────────────────────────────────────┤
│                      REDIRECTIONS                                    │
├──────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  STDOUT (FD 1):                                                      │
│  cmd > file       Overwrite file                                    │
│  cmd >> file      Append to file                                    │
│  cmd 1> file      Explicit FD 1                                      │
│                                                                      │
│  STDERR (FD 2):                                                      │
│  cmd 2> file      Redirect errors                                   │
│  cmd 2>> file     Append errors                                     │
│  cmd 2>&1         Stderr → Stdout                                   │
│                                                                      │
│  BOTH:                                                               │
│  cmd &> file      Stdout + Stderr → file (Bash)                     │
│  cmd > file 2>&1  Equivalent (portable)                             │
│                                                                      │
│  STDIN (FD 0):                                                       │
│  cmd < file       Read from file                                    │
│  cmd << EOF       Here document                                      │
│  cmd <<< "str"    Here string                                       │
│                                                                      │
│  ADVANCED:                                                           │
│  cmd 3> file      Open FD 3 for writing                             │
│  cmd 3< file      Open FD 3 for reading                             │
│  exec 3>&-        Close FD 3                                        │
│                                                                      │
└──────────────────────────────────────────────────────────────────────┘
```

---

## Fully Worked Exercises

### Exercise 1: Complete Pipeline for Log Analysis

**Requirement:** Analyse a log file to find the top 5 IPs with the most errors.

```bash
# Create a test log
cat > /tmp/access.log << 'EOF'
192.168.1.100 - - [10/Jan/2025:10:00:01] "GET /page1" 200 1234
192.168.1.101 - - [10/Jan/2025:10:00:02] "GET /page2" 404 567
192.168.1.100 - - [10/Jan/2025:10:00:03] "GET /page3" 500 890
10.0.0.50 - - [10/Jan/2025:10:00:04] "GET /page1" 200 1234
192.168.1.101 - - [10/Jan/2025:10:00:05] "POST /api" 500 234
192.168.1.100 - - [10/Jan/2025:10:00:06] "GET /page1" 404 567
10.0.0.50 - - [10/Jan/2025:10:00:07] "GET /page2" 500 890
192.168.1.101 - - [10/Jan/2025:10:00:08] "GET /page3" 500 1234
192.168.1.102 - - [10/Jan/2025:10:00:09] "GET /page1" 200 567
192.168.1.100 - - [10/Jan/2025:10:00:10] "GET /page2" 500 890
EOF

# Step-by-step solution:

# Step 1: Filter only errors (status 4xx and 5xx)
grep -E ' (4[0-9]{2}|5[0-9]{2}) ' /tmp/access.log
# Output: 7 lines with errors

# Step 2: Extract only the IPs (first field)
grep -E ' (4[0-9]{2}|5[0-9]{2}) ' /tmp/access.log | cut -d' ' -f1
# Output: IPs, one per line

# Step 3: Sort to group identical IPs
grep -E ' (4[0-9]{2}|5[0-9]{2}) ' /tmp/access.log | cut -d' ' -f1 | sort

# Step 4: Count occurrences of each IP
grep -E ' (4[0-9]{2}|5[0-9]{2}) ' /tmp/access.log | cut -d' ' -f1 | sort | uniq -c

# Step 5: Sort descending by count
grep -E ' (4[0-9]{2}|5[0-9]{2}) ' /tmp/access.log | cut -d' ' -f1 | sort | uniq -c | sort -rn

# Step 6: Take only the first 5
grep -E ' (4[0-9]{2}|5[0-9]{2}) ' /tmp/access.log | cut -d' ' -f1 | sort | uniq -c | sort -rn | head -5

# Final output:
# 3 192.168.1.100
# 3 192.168.1.101
# 1 10.0.0.50

# Cleanup
rm /tmp/access.log
```

### Exercise 2: Script with Loops and Conditions

**Requirement:** Create a script that processes files and reports statistics.

```bash
#!/bin/bash
# file_stats.sh - Analyses files in a directory

# Argument check
if [ $# -eq 0 ]; then
    echo "Usage: $0 <directory>"
    exit 1
fi

DIR="$1"

# Directory check
if [ ! -d "$DIR" ]; then
    echo "Error: '$DIR' is not a valid directory"
    exit 1
fi

# Initialise counters
total_files=0
total_dirs=0
total_size=0
declare -A ext_count  # Associative array for extensions (Bash 4+)

# Recursive processing
while IFS= read -r -d '' item; do
    if [ -f "$item" ]; then
        ((total_files++))
        
        # Size
        size=$(stat -c %s "$item" 2>/dev/null || echo 0)
        ((total_size += size))
        
        # Extension
        filename=$(basename "$item")
        if [[ "$filename" == *.* ]]; then
            ext="${filename##*.}"
            ((ext_count[$ext]++))
        else
            ((ext_count["no_ext"]++))
        fi
        
    elif [ -d "$item" ]; then
        ((total_dirs++))
    fi
done < <(find "$DIR" -print0 2>/dev/null)

# Report
echo "=== Report for: $DIR ==="
echo ""
echo "Total files: $total_files"
echo "Total directories: $total_dirs"
echo "Total size: $(numfmt --to=iec $total_size 2>/dev/null || echo "$total_size bytes")"
echo ""
echo "Distribution by extension:"
for ext in "${!ext_count[@]}"; do
    printf "  .%-10s %d files\n" "$ext" "${ext_count[$ext]}"
done | sort -t: -k2 -rn
```

### Exercise 3: Variable Usage and Substitution

**Requirement:** Demonstrate all types of variable substitution and manipulation.

```bash
#!/bin/bash
# variable_demo.sh - Complete variable demonstration

# === VARIABLE DEFINITION ===
name="John Doe"
number=42
path="/home/user/documents/report.txt"
empty=""

echo "=== Basic Variables ==="
echo "name: $name"
echo "number: $number"
echo "path: $path"

echo ""
echo "=== String Manipulation ==="

# Length
echo "Length of name: ${#name}"              # 8

# Substring
echo "Substring path[0:5]: ${path:0:5}"      # /home
echo "Substring path[6:]: ${path:6}"         # user/documents/report.txt

# Replacement
echo "Replace first: ${path/user/admin}"     # /home/admin/documents/report.txt
echo "Replace all: ${path//o/O}"             # /hOme/user/dOcuments/repOrt.txt

# Delete pattern (from beginning)
echo "Without prefix: ${path#*/}"            # home/user/documents/report.txt
echo "Without all to /: ${path##*/}"         # report.txt (basename)

# Delete pattern (from end)
echo "Without suffix: ${path%/*}"            # /home/user/documents (dirname)
echo "Without all from /: ${path%%/*}"       # (empty, starts with /)

echo ""
echo "=== Default Values ==="

# ${var:-default} - use default if var is empty or undefined
echo "With default: ${undefined:-default_value}"
echo "Empty with default: ${empty:-empty_replaced}"

# ${var:=default} - set and return default
echo "Set default: ${newvar:=set_now}"
echo "newvar is now: $newvar"

# ${var:+alternate} - use alternate only if var is set
echo "If set: ${name:+SET}"
echo "If empty: ${empty:+SET}"

# ${var:?error} - error if var is empty
# ${undefined:?Variable must be set} # Would produce error

echo ""
echo "=== Case Modification (Bash 4+) ==="
text="Hello World"
echo "UPPERCASE: ${text^^}"                  # HELLO WORLD
echo "lowercase: ${text,,}"                  # hello world
echo "First upper: ${text^}"                 # Hello World
echo "First lower: ${text,}"                 # hello World

echo ""
echo "=== Arrays ==="
fruits=("apple" "banana" "cherry" "date")

echo "All elements: ${fruits[@]}"
echo "First element: ${fruits[0]}"
echo "Array length: ${#fruits[@]}"
echo "Indices: ${!fruits[@]}"
echo "Slice [1:2]: ${fruits[@]:1:2}"

# Append
fruits+=("elderberry")
echo "After append: ${fruits[@]}"

# Iteration
echo "Iteration:"
for fruit in "${fruits[@]}"; do
    echo "  - $fruit"
done

echo ""
echo "=== Command Substitution ==="
current_date=$(date +%Y-%m-%d)
file_count=$(ls -1 | wc -l)
echo "Date: $current_date"
echo "Files in current dir: $file_count"

echo ""
echo "=== Arithmetic ==="
a=10
b=3
echo "a + b = $((a + b))"
echo "a - b = $((a - b))"
echo "a * b = $((a * b))"
echo "a / b = $((a / b))"
echo "a % b = $((a % b))"
echo "a ** 2 = $((a ** 2))"

# Increment/Decrement
((a++))
echo "a++ = $a"
```

---

## Useful References

### Common Filters Table

| Command | Function | Example |
|---------|----------|---------|
| `sort` | Sort lines | `sort -n -r file` |
| `uniq` | Remove duplicates | `sort file \| uniq -c` |
| `cut` | Extract columns | `cut -d: -f1 /etc/passwd` |
| `tr` | Transform characters | `tr 'a-z' 'A-Z'` |
| `wc` | Count lines/words | `wc -l file` |
| `head` | First N lines | `head -20 file` |
| `tail` | Last N lines | `tail -f log` (follow) |
| `tee` | Duplicate output | `cmd \| tee file` |
| `xargs` | Build arguments | `find . \| xargs rm` |

---
*Supplementary material for the Operating Systems course | ASE Bucharest - CSIE*

---

*By Revolvix for OPERATING SYSTEMS class | restricted licence 2017-2030*
