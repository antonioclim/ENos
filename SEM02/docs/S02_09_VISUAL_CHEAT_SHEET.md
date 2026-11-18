# Visual Cheat Sheet - Seminar 02
## Operating Systems | Operators, Redirection, Filters, Loops

**Document**: S02_09_VISUAL_CHEAT_SHEET.md  
**Format**: Optimised for A4 printing (horizontal orientation)  
**Version**: 1.1

---

## CONTROL OPERATORS

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        CONTROL OPERATORS                                     │
├─────────┬───────────────────────────────────────────────────────────────────┤
│    ;    │ SEQUENTIAL - executes both, regardless of result                  │
│         │   cmd1 ; cmd2 ; cmd3                                              │
│         │   Ex: echo "Start" ; ls ; echo "Done"                             │
├─────────┼───────────────────────────────────────────────────────────────────┤
│   &&    │ AND - executes cmd2 ONLY if cmd1 succeeds (exit 0)                │
│         │   cmd1 && cmd2                                                    │
│         │   Ex: mkdir dir && cd dir  (enters only if created)              │
├─────────┼───────────────────────────────────────────────────────────────────┤
│   ||    │ OR - executes cmd2 ONLY if cmd1 fails (exit ≠ 0)                  │
│         │   cmd1 || cmd2                                                    │
│         │   Ex: ping host || echo "Offline"                                 │
├─────────┼───────────────────────────────────────────────────────────────────┤
│   &     │ BACKGROUND - executes cmd in background, returns immediately      │
│         │   cmd &                                                           │
│         │   Ex: sleep 100 &  → [1] 12345                                   │
├─────────┼───────────────────────────────────────────────────────────────────┤
│    |    │ PIPE - stdout cmd1 → stdin cmd2                                   │
│         │   cmd1 | cmd2 | cmd3                                              │
│         │   Ex: cat file | sort | uniq                                      │
└─────────┴───────────────────────────────────────────────────────────────────┘
```

### Common Patterns

```bash
# If-then-else on one line
cmd && echo "OK" || echo "FAIL"

# Error handler with exit
cmd || { echo "Error!"; exit 1; }

# Conditional creation
[ -d "dir" ] || mkdir dir

# Check before action
[ -f "file" ] && cat file
```

### Command Grouping

```
┌──────────────────────────────────────────────────────────────────┐
│   { cmd1; cmd2; }    │  In CURRENT SHELL - changes persist       │
│   ( cmd1; cmd2 )     │  In SUBSHELL - changes are lost           │
└──────────────────────────────────────────────────────────────────┘

Example:
x=1                          y=1
{ x=2; echo $x; }           ( y=2; echo $y; )
echo $x  # → 2              echo $y  # → 1 !!!
```

---

## I/O REDIRECTION

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           FILE DESCRIPTORS                                   │
│                                                                             │
│              ┌──────────────┐                                               │
│   stdin ──►  │    PROCESS   │ ──► stdout                                    │
│    (0)       │              │      (1)                                      │
│              │              │ ──► stderr                                    │
│              └──────────────┘      (2)                                      │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────┬───────────────────────────────────────────────────────────────────┐
│ OUTPUT  │                                                                   │
├─────────┼───────────────────────────────────────────────────────────────────┤
│   >     │ Overwrite file (creates if doesn't exist)                         │
│         │   echo "text" > file.txt                                          │
├─────────┼───────────────────────────────────────────────────────────────────┤
│   >>    │ Append to file                                                    │
│         │   echo "new line" >> file.txt                                     │
├─────────┼───────────────────────────────────────────────────────────────────┤
│   2>    │ Redirect stderr                                                   │
│         │   cmd 2> errors.log                                               │
├─────────┼───────────────────────────────────────────────────────────────────┤
│  2>&1   │ stderr → where stdout is NOW                                      │
│         │   cmd > all.log 2>&1   (both in all.log)                         │
├─────────┼───────────────────────────────────────────────────────────────────┤
│   &>    │ BOTH (stdout + stderr) to file (Bash shortcut)                    │
│         │   cmd &> all.log                                                  │
└─────────┴───────────────────────────────────────────────────────────────────┘

┌─────────┬───────────────────────────────────────────────────────────────────┐
│ INPUT   │                                                                   │
├─────────┼───────────────────────────────────────────────────────────────────┤
│   <     │ Read from file                                                    │
│         │   sort < unsorted.txt                                             │
├─────────┼───────────────────────────────────────────────────────────────────┤
│   <<    │ Here Document - inline input until delimiter                      │
│         │   cat << EOF                                                      │
│         │   Line 1                                                          │
│         │   EOF                                                             │
├─────────┼───────────────────────────────────────────────────────────────────┤
│  <<<    │ Here String - string as input                                     │
│         │   tr 'a-z' 'A-Z' <<< "hello"                                     │
└─────────┴───────────────────────────────────────────────────────────────────┘
```

### Trap: Order Matters!

```bash
# CORRECT: Both to file
cmd > file 2>&1

# WRONG: stderr stays on terminal!
cmd 2>&1 > file
```

### Suppress Output

```bash
cmd > /dev/null       # Discard stdout
cmd 2> /dev/null      # Discard stderr
cmd &> /dev/null      # Discard everything
```

---

## TEXT FILTERS

```
┌───────────────────────────────────────────────────────────────────────────────┐
│                              FILTERS                                           │
│                                                                               │
│    stdin ──► │ FILTER │ ──► stdout                                           │
│                                                                               │
│    UNIX philosophy: each filter does ONE thing and does it well              │
└───────────────────────────────────────────────────────────────────────────────┘

┌─────────┬──────────────────────────────────────────────────────────────────────┐
│  sort   │ Sort lines                                                           │
│         │   sort file              # alphabetic                                │
│         │   sort -n file           # numeric                                   │
│         │   sort -r file           # descending                                │
│         │   sort -k2 file          # by column 2                               │
│         │   sort -t',' -k3 file    # CSV, column 3                             │
│         │   sort -u file           # remove duplicates                         │
├─────────┼──────────────────────────────────────────────────────────────────────┤
│  uniq   │ Remove CONSECUTIVE duplicates  ⚠️ Use sort first!                    │
│         │   sort file | uniq       # remove duplicates                         │
│         │   sort file | uniq -c    # count occurrences                         │
│         │   sort file | uniq -d    # only duplicates                           │
├─────────┼──────────────────────────────────────────────────────────────────────┤
│   cut   │ Extract columns/characters                                           │
│         │   cut -d':' -f1 file     # field 1, delimiter :                      │
│         │   cut -d',' -f1,3 file   # fields 1 and 3                            │
│         │   cut -c1-10 file        # characters 1-10                           │
│         │   ⚠️ Default delimiter: TAB (not space!)                             │
├─────────┼──────────────────────────────────────────────────────────────────────┤
│  paste  │ Merge files side by side                                             │
│         │   paste file1 file2      # TAB between columns                       │
│         │   paste -d',' f1 f2      # comma between columns                     │
├─────────┼──────────────────────────────────────────────────────────────────────┤
│   tr    │ Transform characters (NOT strings!)                                  │
│         │   tr 'a-z' 'A-Z'         # lowercase → uppercase                     │
│         │   tr -d '0-9'            # delete digits                             │
│         │   tr -s ' '              # squeeze consecutive spaces                │
├─────────┼──────────────────────────────────────────────────────────────────────┤
│   wc    │ Count lines/words/characters                                         │
│         │   wc -l file             # count lines                               │
│         │   wc -w file             # count words                               │
│         │   wc -c file             # count bytes                               │
├─────────┼──────────────────────────────────────────────────────────────────────┤
│  head   │ First N lines (default: 10)                                          │
│         │   head -5 file           # first 5 lines                             │
│         │   head -n -5 file        # all except last 5                         │
├─────────┼──────────────────────────────────────────────────────────────────────┤
│  tail   │ Last N lines (default: 10)                                           │
│         │   tail -5 file           # last 5 lines                              │
│         │   tail -n +5 file        # from line 5 to end                        │
│         │   tail -f file           # 👁️ FOLLOW - live monitoring               │
├─────────┼──────────────────────────────────────────────────────────────────────┤
│   tee   │ Duplicate stream: display AND save                                   │
│         │   cmd | tee file         # stdout → file + screen                    │
│         │   cmd | tee -a file      # append                                    │
└─────────┴──────────────────────────────────────────────────────────────────────┘
```

### Common Pipelines

```bash
# Top 10 most frequent lines
sort file | uniq -c | sort -rn | head -10

# Top 5 users by processes
ps aux | awk '{print $1}' | sort | uniq -c | sort -rn | head -5

# Extract unique IPs from log
cut -d' ' -f1 access.log | sort -u

# Count .txt files
find . -name "*.txt" | wc -l
```

---

## LOOPS

```
┌───────────────────────────────────────────────────────────────────────────────┐
│                               FOR LOOP                                         │
├───────────────────────────────────────────────────────────────────────────────┤
│  for var in list; do                                                          │
│      commands                                                                  │
│  done                                                                          │
│                                                                               │
│  # Examples:                                                                  │
│  for i in 1 2 3; do echo $i; done                                            │
│  for i in {1..10}; do echo $i; done          # brace expansion               │
│  for i in {0..100..10}; do echo $i; done     # with step                     │
│  for f in *.txt; do cat "$f"; done           # over files                    │
│                                                                               │
│  # C-style:                                                                   │
│  for ((i=0; i<10; i++)); do                                                  │
│      echo $i                                                                  │
│  done                                                                         │
├───────────────────────────────────────────────────────────────────────────────┤
│  ⚠️ Trap: for i in {1..$N} does NOT work with variables!                      │
│              Brace expansion happens BEFORE variable expansion                │
│              Solution: for i in $(seq 1 $N) or for ((i=1; i<=N; i++))        │
└───────────────────────────────────────────────────────────────────────────────┘

┌───────────────────────────────────────────────────────────────────────────────┐
│                             WHILE / UNTIL                                      │
├───────────────────────────────────────────────────────────────────────────────┤
│  while [ condition ]; do         │  until [ condition ]; do                   │
│      commands                     │      commands                              │
│  done                            │  done                                       │
│                                  │                                             │
│  # Executes WHILE TRUE           │  # Executes WHILE FALSE                    │
├───────────────────────────────────────────────────────────────────────────────┤
│  # Reading file line by line:                                                 │
│  while IFS= read -r line; do                                                  │
│      echo "$line"                                                             │
│  done < file.txt                                                              │
│                                                                               │
│  ⚠️ SUBSHELL PROBLEM:                                                        │
│  cat file | while read line; do ... done  ← variables do NOT persist!       │
│  while read line; do ... done < file      ← CORRECT                          │
└───────────────────────────────────────────────────────────────────────────────┘

┌───────────────────────────────────────────────────────────────────────────────┐
│                           CONTROL FLOW                                         │
├───────────────────────────────────────────────────────────────────────────────┤
│  break      │ Exit from loop (NOT from script - for that: exit)              │
│  break N    │ Exit from N nested loops                                        │
│  continue   │ Skip to next iteration                                          │
│  continue N │ Continue loop N                                                 │
└───────────────────────────────────────────────────────────────────────────────┘
```

### Infinite Loop

```bash
while true; do
    # code
    sleep 1
done

# or
while :; do ...; done
for ((;;)); do ...; done
```

---

## EXIT CODES

```
┌────────┬──────────────────────────────────────────────────────────────────────┐
│  $?    │ Exit code of last command                                            │
├────────┼──────────────────────────────────────────────────────────────────────┤
│   0    │ Success                                                              │
│   1    │ General error                                                        │
│   2    │ Incorrect usage                                                      │
│  126   │ File not executable                                                  │
│  127   │ Command not found                                                    │
│ 128+N  │ Terminated by signal N                                               │
└────────┴──────────────────────────────────────────────────────────────────────┘

Useful commands:
  true         # returns 0
  false        # returns 1
  exit N       # exit with code N

In pipeline:
  $?              # only last exit code
  ${PIPESTATUS[@]} # all exit codes
  set -o pipefail # $? = rightmost non-zero
```

---

## QUICK TROUBLESHOOTING

| Problem | Cause | Solution |
|---------|-------|----------|
| `uniq` doesn't remove all duplicates | Not consecutive | `sort \| uniq` |
| `cut -f2` returns whole line | Delimiter is TAB, not space | `cut -d' ' -f2` |
| `for i in {1..$N}` doesn't work | Brace expansion at parse time | `for i in $(seq 1 $N)` |
| Variables from `pipe \| while` are lost | Subshell | `while ... done < file` |
| `> file 2>&1` vs `2>&1 > file` | Order matters! | First variant is correct |
| `cmd &` doesn't finish when closing terminal | Not detached | `nohup cmd &` |

---

## QUICK REFERENCES

```bash
# File checks
[ -f file ]    # file exists
[ -d dir ]     # directory exists
[ -r file ]    # can read
[ -w file ]    # can write
[ -x file ]    # can execute

# Number comparisons
[ $a -eq $b ]  # equal
[ $a -ne $b ]  # not equal
[ $a -lt $b ]  # less than
[ $a -gt $b ]  # greater than

# String comparisons
[ "$a" = "$b" ]   # equal
[ "$a" != "$b" ]  # not equal
[ -z "$a" ]       # empty string
[ -n "$a" ]       # non-empty string
```

---

*Cheat Sheet for Seminar 02 OS | ASE Bucharest - CSIE*  
*Recommended printing: A4 horizontal, Font 8-9pt*
