# S05_08 - Spectacular Demos: Memorable Visual Impact

> **Lab observation:** note down key commands and relevant output (2–3 lines) as you work. It helps with debugging and, frankly, by the end you'll have a decent README without extra effort.
> **Operating Systems** | ASE Bucharest - CSIE  
> Seminar 5: Advanced Bash Scripting
> Version: 2.0.0 | Date: 2025-01

---

> **Current use and evidence:** These are teaching materials, with intentional WRONG/TODO examples retained. The [teaching and assessment contract](TEACHING_CONTRACT.md) separates runnable references, proposed assessment rules and historical claims whose provenance remains unresolved. Removed historical empirical assertions are preserved in [the provenance record](../../DECISION_PROVENANCE.json).


## Philosophy of Spectacular Demos

Spectacular demos have a specific pedagogical purpose:
- **Create memorable moments** - students remember the emotion
- **Demonstrate consequences** - "look what can happen!"
- **Anchor concepts** - associate theory with experience
- **Motivate attention** - "I don't want this to happen to me!"

### The "Fragile vs Robust" Principle

Each demo contrasts:
1. **FRAGILE** - what can go wrong
2. **ROBUST** - how to do it correctly

---

## Demo 1: THE rm -rf DISASTER (Opening Hook)

### Preparation (before the seminar)

```bash
# Create sandbox environment
DEMO_ROOT=$(mktemp -d) || exit 1
trap 'rm -rf -- "$DEMO_ROOT"' EXIT
mkdir -p "$DEMO_ROOT"/{important_project,backup,temp}
cd -- "$DEMO_ROOT" || exit 1
echo "class User { ... }" > "$DEMO_ROOT"/important_project/main.py
echo "def calculate() { ... }" > "$DEMO_ROOT"/important_project/utils.py
echo "DATABASE_URL=..." > "$DEMO_ROOT"/important_project/.env
tree "$DEMO_ROOT"
```

### FRAGILE Script (demo_fragile.sh)

```bash
#!/bin/bash
# FRAGILE script - DO NOT USE in production!

cleanup_dir="$1"

echo "🧹 Cleaning up: $cleanup_dir"
cd $cleanup_dir
printf 'Would remove entries in: %s\n' "$PWD"  # Deliberately observe, do not delete
echo "The fragile script reaches its misleading success message"
```

### Live Demonstration

```console
# 1. Show the structure
$ tree "$DEMO_ROOT"
demo_disaster/
├── important_project/
│   ├── main.py
│   ├── utils.py
│   └── .env
├── backup/
└── temp/

# 2. Ask the class: "What happens if I run with an invalid directory?"

$ ./demo_fragile.sh /nonexistent/path
🧹 Cleaning up: /nonexistent/path
./demo_fragile.sh: line 6: cd: /nonexistent/path: No such file or directory
✓ Cleanup complete!

# 3. DRAMA: Check what happened!
$ ls "$DEMO_ROOT"
# Files remain: this demonstration prints the wrong target instead of deleting it.

# 4. Dramatic pause... let the information sink in
```

### ROBUST Script

```bash
#!/bin/bash
set -euo pipefail

owned=
trap '[[ -z ${owned:-} ]] || rm -rf -- "$owned"' EXIT
owned=$(mktemp -d) || exit 1
mkdir -- "$owned/cache"
printf '%s\n' 'disposable data' > "$owned/cache/entry.txt"
cleanup_dir=$(realpath -- "$owned/cache") || exit 1
[[ $cleanup_dir == "$owned/cache" && -d $cleanup_dir && ! -L $cleanup_dir ]] || exit 1
cd -- "$cleanup_dir" || exit 1
rm -f -- ./*   # Owned fixture only; ./* does not validate the directory.
printf '%s\n' 'Owned cache cleaned'

```

### Key Lesson (on the board)

```
┌──────────────────────────────────────────────────┐
│  NEVER:                                          │
│  cd $dir; rm -rf *                               │
│                                                  │
│  ALWAYS:                                         │
│  explicit ownership + checked path + failure checks        │
└──────────────────────────────────────────────────┘
```

---

## Demo 2: THE DISAPPEARING VARIABLE

### Setup

```bash
#!/bin/bash
# mystery.sh - Why doesn't it work?

total=0

echo "10
20
30" | while read num; do
    total=$((total + num))
    echo "Adding $num, total=$total"
done

echo "Final total: $total"
```

### Demonstration

```console


$ ./mystery.sh
Adding 10, total=10
Adding 20, total=30
Adding 30, total=60
Final total: 0          # ???

# Question: WHY?!
```

*(Bash has ugly syntax, I admit. But it runs everywhere, and that matters enormously in practice.)*

### Visual Explanation

```
┌─────────────────────────────────────────────────────────┐
│  MAIN PROCESS                                           │


│  total=0                                                │
│  │                                                      │
│  ▼                                                      │
│  echo "..." ──PIPE──► ┌──────────────────────┐          │
│                       │ SUBSHELL (while)     │          │
│                       │ total=10             │          │
│                       │ total=30             │          │
│                       │ total=60             │          │
│                       └──────────────────────┘          │
│                              │                          │
│                              ▼                          │
│                         SUBSHELL DISAPPEARS             │
│                         (total=60 lost!)                │
│  │                                                      │
│  ▼                                                      │
│  echo "Final total: $total"  ──► total=0 (original!)    │
└─────────────────────────────────────────────────────────┘
```

> 💡 Practise the commands, explain each result and compare it with your prediction.

### Solution: Process Substitution

```bash
#!/bin/bash


total=0

while read num; do
    total=$((total + num))
    echo "Adding $num, total=$total"
done < <(echo "10
20
30")

echo "Final total: $total"  # 60 - CORRECT!
```

*Personal note: Many prefer `zsh`, but I stick with Bash because it's the standard on servers. Consistency beats comfort.*

---

## Demo 3: THE QUOTING DISASTER

### Setup

```bash
# Create files with "weird" names
QUOTE_ROOT=$(mktemp -d) || exit 1
trap 'rm -rf -- "$QUOTE_ROOT"' EXIT
mkdir -p "$QUOTE_ROOT"
touch "$QUOTE_ROOT"/"my file.txt"
touch "$QUOTE_ROOT"/"another file.txt"
touch "$QUOTE_ROOT"/"file with  two spaces.txt"
```

### FRAGILE Script

```bash
#!/bin/bash
# count_lines_bad.sh

total=0
for file in $(ls "$QUOTE_ROOT"); do
    lines=$(wc -l < "$file")
    total=$((total + lines))
    echo "Processed: $file"
done
echo "Total lines: $total"
```

### Demonstration

```console
$ ./count_lines_bad.sh
wc: my: No such file or directory
wc: file.txt: No such file or directory
wc: another: No such file or directory
...
# DISASTER!
```

### Word Splitting Visualisation

```
Original:
  "my file.txt" "another file.txt"

After $(ls):
  my file.txt another file.txt

After word splitting:
  [my] [file.txt] [another] [file.txt]

Loop sees 4 "files", not 2!
```

### ROBUST Script

```bash
#!/bin/bash
set -euo pipefail

total=0
for file in "$QUOTE_ROOT"/*; do
    [[ -f "$file" ]] || continue
    lines=$(wc -l < "$file")
    total=$((total + lines))
    echo "Processed: $file"
done
echo "Total lines: $total"
```

---

## Demo 4: THE ERROR CASCADE (pipefail)

### Setup

```bash
# Simulate a data processing pipeline
```

### FRAGILE Script

```bash
#!/bin/bash
# Dangerous pipeline

( printf 'Controlled source failure\n' >&2; exit 2 ) |
grep "root" |
cut -d: -f1 |
head -1

echo "Exit code: $?"
echo "SUCCESS! 🎉"
```

### Demonstration

```console
$ ./pipeline_bad.sh
Controlled source failure
Exit code: 0
SUCCESS! 🎉

# WAT?! Script reports SUCCESS even though cat failed!
```

### Visual Explanation

```
Pipeline without pipefail:
┌─────────┐    ┌──────┐    ┌─────┐    ┌──────┐
│ source❌│───►│ grep │───►│ cut │───►│ head │
│ exit=2  │    │      │    │     │    │exit=0│
└─────────┘    └──────┘    └─────┘    └──────┘
                                          │
                            $? = 0 ◄──────┘
                            (only the last one!)

Pipeline WITH pipefail:
┌─────────┐    ┌──────┐    ┌─────┐    ┌──────┐
│ source❌│───►│ grep │───►│ cut │───►│ head │
│ exit=2  │    │      │    │     │    │      │
└─────────┘    └──────┘    └─────┘    └──────┘
      │
      $? = 1 (rightmost non-zero: grep finds no match)
```

### ROBUST Script

```bash
#!/bin/bash
set -euo pipefail

( printf 'Controlled source failure\n' >&2; exit 2 ) |
grep "root" |
cut -d: -f1 |
head -1

echo "SUCCESS! 🎉"
```

```console
$ ./pipeline_good.sh
Controlled source failure
# Script stops, doesn't reach SUCCESS
```

---

## Demo 5: ASSOCIATIVE vs INDEXED

### Visual Demo

```bash
#!/bin/bash

echo "═══ WITHOUT declare -A ═══"
bad[host]="localhost"
bad[port]="8080"
echo "Setting: host=localhost, port=8080"
echo "Result:"
echo "  Keys: ${!bad[@]}"
echo "  Values: ${bad[@]}"
echo ""

echo "═══ WITH declare -A ═══"
declare -A good
good[host]="localhost"
good[port]="8080"
echo "Setting: host=localhost, port=8080"
echo "Result:"
echo "  Keys: ${!good[@]}"
echo "  Values: ${good[@]}"
```

### Output

```
═══ WITHOUT declare -A ═══
Setting: host=localhost, port=8080
Result:
  Keys: 0
  Values: 8080

═══ WITH declare -A ═══
Setting: host=localhost, port=8080
Result:
  Keys: host port  # One possible order; associative ordering is unspecified
  Values: localhost 8080
```

### Board Diagram

```
WITHOUT declare -A:       WITH declare -A:
┌─────────┐               ┌─────────┬───────────┐
│ Index 0 │               │ "host"  │ localhost │
├─────────┤               ├─────────┼───────────┤
│ "8080"  │ ← overwritten!│ "port"  │ 8080      │
└─────────┘               └─────────┴───────────┘

host = $host = "" = 0
port = $port = "" = 0
Both write to index 0!
```

---

## Demo 6: TRAP MAGIC

### Demo: Script that "survives" Ctrl+C

```bash
#!/bin/bash

echo "PID: $$"
echo "Try to stop me with Ctrl+C!"
echo ""

cleanup() {
    echo ""
    echo "🛡️ Ha! I caught Ctrl+C!"
    echo "🧹 Doing cleanup..."
    sleep 1
    echo "✓ Cleanup complete. Now I can leave."
    exit 130
}

trap cleanup INT

count=0
while true; do
    ((count++))
    printf "\r⏱️ Running for $count seconds... "
    sleep 1
done
```

### Demonstration

```console
$ ./immortal.sh
PID: 12345
Try to stop me with Ctrl+C!

⏱️ Running for 5 seconds... ^C
🛡️ Ha! I caught Ctrl+C!
🧹 Doing cleanup...
✓ Cleanup complete. Now I can leave.
```

---

## Demo 7: LIVE DEBUGGING

### Script with Hidden Bug

```bash
#!/bin/bash

process_file() {
    local file=$1
    local count=0
    
    while read line; do
        count=$((count + 1))
    done < "$file"
    
    echo $count
}

total=0
for f in *.txt; do
    n=$(process_file "$f")
    total=$((total + n))
done

echo "Total lines: $total"
```

### Activate "X-Ray Vision"

```console
$ PS4='+ ${BASH_SOURCE}:${LINENO}: ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'
$ bash -x ./debug_demo.sh

+ ./debug_demo.sh:15: total=0
+ ./debug_demo.sh:16: for f in '*.txt'
+ ./debug_demo.sh:17: process_file file1.txt
+ ./debug_demo.sh:4: process_file(): local file=file1.txt
+ ./debug_demo.sh:5: process_file(): local count=0
+ ./debug_demo.sh:7: process_file(): read line
...
```

---

## Tips for Successful Demos

### Preparation

- [ ] Test each demo beforehand
- [ ] Prepare "clean states" for retry
- [ ] Have backups for deleted files
- [ ] Large font, good contrast

### During the demo

- [ ] Speak what you're typing
- [ ] Dramatic pauses at key moments
- [ ] Ask "What do you think will happen?"
- [ ] Let students see the error BEFORE the explanation

### After the demo

- [ ] Recap the key lesson
- [ ] Write the rule on the board
- [ ] Connect with the next concept

---

## Pre-made Scripts

All demos are available in:
```
scripts/demo/
├── S05_01_hook_demo.sh       # Fragile vs Robust
├── S05_02_demo_functions.sh  # Local variables
├── S05_03_demo_arrays.sh     # Arrays
├── S05_04_demo_robust.sh     # set -euo pipefail
├── S05_05_demo_logging.sh    # Logging
└── S05_06_demo_debug.sh      # Debugging
```

---

*Laboratory material for the Operating Systems course | ASE Bucharest - CSIE*
