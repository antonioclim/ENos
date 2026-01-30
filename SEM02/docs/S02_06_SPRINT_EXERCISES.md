# Sprint Exercises - Seminar 3-4
## Operating Systems | Operators, Redirection, Filters, Loops

Version: 1.0 | Total available duration: ~45 minutes from seminar  
Philosophy: Active learning through timed practice and immediate feedback

---

## ABOUT SPRINT EXERCISES

### What Are Sprints?

Sprints are **timed** exercises (5-15 minutes) that:
- Consolidate concepts immediately after presentation
- Create productive urgency (maximum focus)
- Provide immediate feedback (verification at the end)
- Allow pair programming for collaborative learning

### General Rules

```
╔════════════════════════════════════════════════════════════════════╗
║  ⏱️  SPRINT RULES                                                  ║
╠════════════════════════════════════════════════════════════════════╣
║  1. Timer starts when the instructor says "START"                  ║
║  2. DON'T ask the instructor - use the manual/colleagues           ║
║  3. If you finish early → help someone else OR do the bonus        ║
║  4. At "STOP" → stop immediately and verify                        ║
║  5. Pair Programming: switch driver/navigator at half time         ║
╚════════════════════════════════════════════════════════════════════╝
```

### Difficulty Levels

| Symbol | Level | Typical Time | Description |
|--------|-------|--------------|-------------|
| ⭐ | Beginner | 5 min | Single concept, basic syntax |
| ⭐⭐ | Intermediate | 8-10 min | Combining 2-3 concepts |
| ⭐⭐⭐ | Advanced | 12-15 min | Multiple integration, edge cases |
| ⭐⭐⭐⭐ | Expert | 15+ min | Complete mini projects |

---

## CONTROL OPERATOR SPRINTS

### SPRINT O1: Safe Command
Time: 5 min | Mode: Individual | Points: 10

```
╔════════════════════════════════════════════════════════════════════╗
║  🏃 SPRINT O1: SAFE COMMAND                                        ║
╠════════════════════════════════════════════════════════════════════╣
║                                                                    ║
║  OBJECTIVE: Write a ONE-LINER command that:                        ║
║                                                                    ║
║  1. Creates the "backup" directory (if it doesn't exist)           ║
║  2. Copies the file "data.txt" into backup/                        ║
║  3. Displays "✓ Backup complete" ONLY if everything succeeded      ║
║  4. Displays "✗ Backup error" if something fails                   ║
║                                                                    ║
║  ─────────────────────────────────────────────────────────────────  ║
║  SETUP (run first):                                                ║
║                                                                    ║
║    echo "very important data" > data.txt                           ║
║                                                                    ║
║  ─────────────────────────────────────────────────────────────────  ║
║  VERIFICATION:                                                     ║
║                                                                    ║
║    1. Run your command → should see "Backup complete"              ║
║    2. rm -rf backup && run again → "Backup complete"               ║
║    3. rm data.txt && run → "Backup error"                          ║
║                                                                    ║
╚════════════════════════════════════════════════════════════════════╝
```

💡 Solution (for instructor):
```bash
mkdir -p backup && cp data.txt backup/ && echo "✓ Backup complete" || echo "✗ Backup error"
```

🎯 Evaluation criteria:
- [3p] mkdir -p (or mkdir with verification)
- [3p] && between commands (not ;)
- [2p] || for error
- [2p] Correct messages

---

### SPRINT O2: Process Monitor
Time: 10 min | Mode: Pairs | Points: 20

```
╔════════════════════════════════════════════════════════════════════╗
║  🏃 SPRINT O2: PROCESS MONITOR                                     ║
╠════════════════════════════════════════════════════════════════════╣
║                                                                    ║
║  PAIR PROGRAMMING! 🔄 Switch at minute 5!                          ║
║                                                                    ║
║  OBJECTIVE: Write a script "monitor.sh" that:                      ║
║                                                                    ║
║  1. Checks if the "firefox" process is running                     ║
║  2. If YES → displays PID and memory consumption                   ║
║  3. If NO → starts firefox in background and confirms              ║
║  4. At the end, displays total number of firefox processes         ║
║                                                                    ║
║  ─────────────────────────────────────────────────────────────────  ║
║  SUGGESTED STRUCTURE:                                              ║
║                                                                    ║
║    #!/bin/bash                                                     ║
║    # Process verification                                          ║
║    if pgrep ... ; then                                             ║
║        # display info                                              ║
║    else                                                            ║
║        # start                                                     ║
║    fi                                                              ║
║    # Total count                                                   ║
║                                                                    ║
║  ─────────────────────────────────────────────────────────────────  ║
║  HINT: pgrep -c for counting, pgrep -a for details                 ║
║                                                                    ║
║  VERIFICATION: ./monitor.sh must work in both cases                ║
║                                                                    ║
╚════════════════════════════════════════════════════════════════════╝
```

💡 Solution:
```bash
#!/bin/bash
# monitor.sh - Firefox process monitor

PROC="firefox"

if pgrep "$PROC" > /dev/null; then
    echo "✓ $PROC is running:"
    pgrep -a "$PROC" | head -3
    echo ""
    echo "Memory consumption:"
    ps aux | grep "$PROC" | grep -v grep | awk '{print $2 " - " $4 "% MEM"}'
else
    echo "✗ $PROC is not running. Starting..."
    firefox &>/dev/null &
    sleep 1
    pgrep "$PROC" > /dev/null && echo "✓ Firefox started successfully!" || echo "✗ Start error"
fi

echo ""
echo "Total $PROC processes: $(pgrep -c "$PROC" 2>/dev/null || echo 0)"
```

---

### SPRINT O3: Build Pipeline
Time: 12 min | Mode: Pairs | Points: 25

```
╔════════════════════════════════════════════════════════════════════╗
║  🏃 SPRINT O3: BUILD PIPELINE                                      ║
╠════════════════════════════════════════════════════════════════════╣
║                                                                    ║
║  OBJECTIVE: Create a script "build.sh" that simulates a build:     ║
║                                                                    ║
║  STAGES (all must succeed to continue):                            ║
║                                                                    ║
║    1. "Checking dependencies..." (check if gcc exists)             ║
║    2. "Compiling..." (create temp file, sleep 1)                   ║
║    3. "Testing..." (check if temp exists, sleep 1)                 ║
║    4. "Packaging..." (move temp to build/, sleep 1)                ║
║    5. "✓ BUILD COMPLETE!" or "✗ BUILD FAILED at stage X"           ║
║                                                                    ║
║  ─────────────────────────────────────────────────────────────────  ║
║  REQUIREMENTS:                                                     ║
║                                                                    ║
║    • Use && and || for flow control                                ║
║    • Measure and display total build time                          ║
║    • Exit with appropriate code (0=success, 1=failure)             ║
║                                                                    ║
║  ─────────────────────────────────────────────────────────────────  ║
║  VERIFICATION:                                                     ║
║                                                                    ║
║    1. ./build.sh → should succeed                                  ║
║    2. Modify to fail at a stage → verify error message             ║
║                                                                    ║
╚════════════════════════════════════════════════════════════════════╝
```

💡 Solution:
```bash
#!/bin/bash
# build.sh - Build process simulator

START=$(date +%s)
echo "═══════════════════════════════════════"
echo "        BUILD PROCESS STARTED"
echo "═══════════════════════════════════════"

# Stage 1
echo -n "[1/4] Checking dependencies... "
sleep 0.5
command -v gcc &>/dev/null && echo "✓" || { echo "✗ gcc not found"; exit 1; }

# Stage 2
echo -n "[2/4] Compiling... "
sleep 1
touch /tmp/build_artifact.o && echo "✓" || { echo "✗ Compile failed"; exit 1; }

# Stage 3
echo -n "[3/4] Testing... "
sleep 1
[ -f /tmp/build_artifact.o ] && echo "✓" || { echo "✗ Tests failed"; exit 1; }

# Stage 4
echo -n "[4/4] Packaging... "
mkdir -p build
sleep 1
mv /tmp/build_artifact.o build/app.bin && echo "✓" || { echo "✗ Packaging failed"; exit 1; }

END=$(date +%s)
echo ""
echo "═══════════════════════════════════════"
echo "✓ BUILD COMPLETE in $((END-START)) seconds!"
echo "═══════════════════════════════════════"
```

---

## I/O REDIRECTION SPRINTS

### SPRINT R1: Log Separator
Time: 10 min | Mode: Pairs | Points: 20

```
╔════════════════════════════════════════════════════════════════════╗
║  🏃 SPRINT R1: LOG SEPARATOR                                       ║
╠════════════════════════════════════════════════════════════════════╣
║                                                                    ║
║  OBJECTIVE: Separate stdout and stderr into different files        ║
║                                                                    ║
║  COMMAND TO TEST:                                                  ║
║                                                                    ║
║    find /etc -name "*.conf" -type f 2>/dev/null                    ║
║    ls /nonexistent_directory                                       ║
║                                                                    ║
║  REQUIREMENTS for find + ls (single command line):                 ║
║                                                                    ║
║    1. stdout → success.log                                         ║
║    2. stderr → errors.log                                          ║
║    3. BOTH → combined.log (both stdout and stderr)                 ║
║                                                                    ║
║  ─────────────────────────────────────────────────────────────────  ║
║  VERIFICATION:                                                     ║
║                                                                    ║
║    • success.log contains found .conf paths                        ║
║    • errors.log contains "No such file or directory"               ║
║    • combined.log contains BOTH                                    ║
║                                                                    ║
║  ─────────────────────────────────────────────────────────────────  ║
║  HINT: You can use tee and combined redirection                    ║
║        or subshell with multiple redirection                       ║
║                                                                    ║
╚════════════════════════════════════════════════════════════════════╝
```

💡 Solution (tee variant):
```bash
{ find /etc -name "*.conf" -type f; ls /nonexistent_directory; } 2>&1 | tee combined.log | grep -v "No such" > success.log; grep "No such" combined.log > errors.log
```

💡 Alternative solution (more elegant):
```bash
{
    find /etc -name "*.conf" -type f
    ls /nonexistent_directory
} > >(tee -a success.log combined.log) 2> >(tee -a errors.log combined.log >&2)
```

---

### SPRINT R2: Config Generator
Time: 10 min | Mode: Individual | Points: 20

```
╔════════════════════════════════════════════════════════════════════╗
║  🏃 SPRINT R2: CONFIG GENERATOR                                    ║
╠════════════════════════════════════════════════════════════════════╣
║                                                                    ║
║  OBJECTIVE: Use HERE DOCUMENT to generate a configuration file     ║
║            app.conf with values from variables                     ║
║                                                                    ║
║  VARIABLES TO DEFINE:                                              ║
║                                                                    ║
║    APP_NAME="MyApp"                                                ║
║    APP_PORT=8080                                                   ║
║    APP_ENV="production"                                            ║
║    DB_HOST="localhost"                                             ║
║    DB_PORT=5432                                                    ║
║                                                                    ║
║  REQUIRED OUTPUT (app.conf):                                       ║
║                                                                    ║
║    # Configuration for MyApp                                       ║
║    # Generated on: [current date]                                  ║
║                                                                    ║
║    [application]                                                   ║
║    name = MyApp                                                    ║
║    port = 8080                                                     ║
║    environment = production                                        ║
║                                                                    ║
║    [database]                                                      ║
║    host = localhost                                                ║
║    port = 5432                                                     ║
║                                                                    ║
║  ─────────────────────────────────────────────────────────────────  ║
║  VERIFICATION: cat app.conf and compare with required output       ║
║                                                                    ║
╚════════════════════════════════════════════════════════════════════╝
```

💡 Solution:
```bash
#!/bin/bash
APP_NAME="MyApp"
APP_PORT=8080
APP_ENV="production"
DB_HOST="localhost"
DB_PORT=5432

cat > app.conf << EOF
# Configuration for $APP_NAME
# Generated on: $(date '+%Y-%m-%d %H:%M:%S')

[application]
name = $APP_NAME
port = $APP_PORT
environment = $APP_ENV

[database]
host = $DB_HOST
port = $DB_PORT
EOF

echo "✓ File app.conf generated:"
cat app.conf
```

---

### SPRINT R3: Stream Multiplexer
Time: 12 min | Mode: Pairs | Points: 25

```
╔════════════════════════════════════════════════════════════════════╗
║  🏃 SPRINT R3: STREAM MULTIPLEXER                                  ║
╠════════════════════════════════════════════════════════════════════╣
║                                                                    ║
║  OBJECTIVE: Create a script that processes input from stdin        ║
║            and sends it to 3 different directions simultaneously   ║
║                                                                    ║
║  REQUIREMENTS for script "multiplex.sh":                           ║
║                                                                    ║
║    1. Reads lines from stdin                                       ║
║    2. Lines with "ERROR" → errors.log                              ║
║    3. Lines with "WARN" → warnings.log                             ║
║    4. ALL lines → all.log                                          ║
║    5. Also displays on screen the number of processed lines        ║
║                                                                    ║
║  ─────────────────────────────────────────────────────────────────  ║
║  TEST INPUT (create test_input.txt):                               ║
║                                                                    ║
║    INFO Starting application                                       ║
║    WARN Low memory                                                 ║
║    INFO Processing request                                         ║
║    ERROR Connection failed                                         ║
║    WARN High CPU usage                                             ║
║    ERROR Timeout                                                   ║
║    INFO Finished                                                   ║
║                                                                    ║
║  ─────────────────────────────────────────────────────────────────  ║
║  USAGE: cat test_input.txt | ./multiplex.sh                        ║
║                                                                    ║
║  VERIFICATION:                                                     ║
║    • all.log: 7 lines                                              ║
║    • errors.log: 2 lines (those with ERROR)                        ║
║    • warnings.log: 2 lines (those with WARN)                       ║
║                                                                    ║
╚════════════════════════════════════════════════════════════════════╝
```

💡 Solution:
```bash
#!/bin/bash
# multiplex.sh - Stream multiplexer

# Initialise counters
total=0
errors=0
warnings=0

# Clear previous files
> all.log
> errors.log  
> warnings.log

# Process stdin
while IFS= read -r line; do
    ((total++))
    
    # All lines to all.log
    echo "$line" >> all.log
    
    # Filter by type
    if [[ "$line" == *"ERROR"* ]]; then
        echo "$line" >> errors.log
        ((errors++))
    elif [[ "$line" == *"WARN"* ]]; then
        echo "$line" >> warnings.log
        ((warnings++))
    fi
done

# Final report
echo "═══════════════════════════════════════"
echo "📊 PROCESSING REPORT"
echo "═══════════════════════════════════════"
echo "Total lines:    $total"
echo "Errors:         $errors"
echo "Warnings:       $warnings"
echo "═══════════════════════════════════════"
```

---

## TEXT FILTER SPRINTS

### SPRINT F1: Top 5 Users
Time: 5 min | Mode: Individual | Points: 10

```
╔════════════════════════════════════════════════════════════════════╗
║  🏃 SPRINT F1: TOP 5 USERS                                         ║
╠════════════════════════════════════════════════════════════════════╣
║                                                                    ║
║  OBJECTIVE: Find the first 5 users from /etc/passwd                ║
║            in ALPHABETICAL order of usernames                      ║
║                                                                    ║
║  REQUIREMENT: A single pipeline (one-liner)                        ║
║                                                                    ║
║  HINT: cut to extract username, sort, head                         ║
║                                                                    ║
║  ─────────────────────────────────────────────────────────────────  ║
║  EXAMPLE OUTPUT (may vary):                                        ║
║                                                                    ║
║    _apt                                                            ║
║    backup                                                          ║
║    bin                                                             ║
║    daemon                                                          ║
║    games                                                           ║
║                                                                    ║
║  ─────────────────────────────────────────────────────────────────  ║
║  VERIFICATION: Compare with colleague's output - should be         ║
║              identical if you have the same /etc/passwd            ║
║                                                                    ║
╚════════════════════════════════════════════════════════════════════╝
```

💡 Solution:
```bash
cut -d':' -f1 /etc/passwd | sort | head -5
```

---

### SPRINT F2: Word Frequency
Time: 10 min | Mode: Pairs | Points: 20

```
╔════════════════════════════════════════════════════════════════════╗
║  🏃 SPRINT F2: WORD FREQUENCY                                      ║
╠════════════════════════════════════════════════════════════════════╣
║                                                                    ║
║  OBJECTIVE: Find the 10 most frequent words in a text              ║
║                                                                    ║
║  SETUP - create text.txt:                                          ║
║                                                                    ║
║    echo "the quick brown fox jumps over the lazy dog              ║
║    the fox is quick and the dog is lazy                            ║
║    quick quick fox fox dog" > text.txt                             ║
║                                                                    ║
║  REQUIREMENTS:                                                     ║
║                                                                    ║
║    1. A single pipeline                                            ║
║    2. Words converted to lowercase                                 ║
║    3. Display: frequency + word, sorted descending                 ║
║                                                                    ║
║  ─────────────────────────────────────────────────────────────────  ║
║  EXPECTED OUTPUT:                                                  ║
║                                                                    ║
║    5 the                                                           ║
║    4 quick                                                         ║
║    4 fox                                                           ║
║    3 dog                                                           ║
║    2 lazy                                                          ║
║    2 is                                                            ║
║    1 over                                                          ║
║    1 jumps                                                         ║
║    1 brown                                                         ║
║    1 and                                                           ║
║                                                                    ║
║  ─────────────────────────────────────────────────────────────────  ║
║  HINT: tr for lowercase and spaces, sort | uniq -c | sort -rn     ║
║                                                                    ║
╚════════════════════════════════════════════════════════════════════╝
```

💡 Solution:
```bash
cat text.txt | tr 'A-Z' 'a-z' | tr -cs 'a-z' '\n' | sort | uniq -c | sort -rn | head -10
```

---

### SPRINT F3: Log Analyser
Time: 15 min | Mode: Pairs | Points: 30

```
╔════════════════════════════════════════════════════════════════════╗
║  🏃 SPRINT F3: LOG ANALYSER                                        ║
╠════════════════════════════════════════════════════════════════════╣
║                                                                    ║
║  OBJECTIVE: Analyse an Apache log file and extract                 ║
║            relevant statistics                                     ║
║                                                                    ║
║  SETUP - create access.log:                                        ║
╠════════════════════════════════════════════════════════════════════╣
║                                                                    ║
║  cat > access.log << 'EOF'                                         ║
║  192.168.1.1 - - [10/Jan/2025:10:00:00] "GET /index.html" 200 1024 ║
║  192.168.1.2 - - [10/Jan/2025:10:00:01] "GET /about.html" 200 2048 ║
║  192.168.1.1 - - [10/Jan/2025:10:00:02] "GET /contact.html" 404 512║
║  192.168.1.3 - - [10/Jan/2025:10:00:03] "POST /login" 200 128      ║
║  192.168.1.1 - - [10/Jan/2025:10:00:04] "GET /index.html" 200 1024 ║
║  192.168.1.2 - - [10/Jan/2025:10:00:05] "GET /products" 500 0      ║
║  192.168.1.4 - - [10/Jan/2025:10:00:06] "GET /index.html" 200 1024 ║
║  192.168.1.1 - - [10/Jan/2025:10:00:07] "GET /api/data" 200 4096   ║
║  192.168.1.2 - - [10/Jan/2025:10:00:08] "GET /index.html" 200 1024 ║
║  192.168.1.5 - - [10/Jan/2025:10:00:09] "GET /about.html" 200 2048 ║
║  EOF                                                               ║
║                                                                    ║
╠════════════════════════════════════════════════════════════════════╣
║  REQUIRED REPORT (write commands for each):                        ║
║                                                                    ║
║    1. Total requests: [number]                                     ║
║    2. Unique requests per IP (top 3 IPs by activity)               ║
║    3. Pages accessed (top 3 by frequency)                          ║
║    4. HTTP codes (distribution: 200, 404, 500)                     ║
║    5. Total bytes transferred                                      ║
║                                                                    ║
║  ─────────────────────────────────────────────────────────────────  ║
║  BONUS (+5p): Create a script that generates the entire report     ║
║                                                                    ║
╚════════════════════════════════════════════════════════════════════╝
```

💡 Individual solutions:
```bash
# 1. Total requests
wc -l < access.log

# 2. Top 3 IPs
cut -d' ' -f1 access.log | sort | uniq -c | sort -rn | head -3

# 3. Top 3 pages
awk '{print $7}' access.log | sort | uniq -c | sort -rn | head -3

# 4. HTTP code distribution
awk '{print $9}' access.log | sort | uniq -c | sort -rn

# 5. Total bytes
awk '{sum += $10} END {print sum}' access.log
```

💡 Bonus script:
```bash
#!/bin/bash
# log_report.sh - Complete log analysis

LOG="access.log"

echo "═══════════════════════════════════════════════════"
echo "📊 LOG ANALYSIS REPORT: $LOG"
echo "═══════════════════════════════════════════════════"
echo ""
echo "1. Total requests: $(wc -l < "$LOG")"
echo ""
echo "2. Top 3 IPs:"
cut -d' ' -f1 "$LOG" | sort | uniq -c | sort -rn | head -3 | awk '{print "   " $2 ": " $1 " requests"}'
echo ""
echo "3. Top 3 pages:"
awk '{print $7}' "$LOG" | sort | uniq -c | sort -rn | head -3 | awk '{print "   " $2 ": " $1 " accesses"}'
echo ""
echo "4. HTTP codes:"
awk '{print $9}' "$LOG" | sort | uniq -c | sort -rn | awk '{print "   HTTP " $2 ": " $1}'
echo ""
echo "5. Total bytes: $(awk '{sum += $10} END {print sum}' "$LOG")"
echo ""
echo "═══════════════════════════════════════════════════"
```

---

## LOOP SPRINTS

### SPRINT B1: Batch Rename
Time: 10 min | Mode: Individual | Points: 20

```
╔════════════════════════════════════════════════════════════════════╗
║  🏃 SPRINT B1: BATCH RENAME                                        ║
╠════════════════════════════════════════════════════════════════════╣
║                                                                    ║
║  OBJECTIVE: Write a script that:                                   ║
║                                                                    ║
║  1. Creates 5 files: file1.txt, file2.txt, ..., file5.txt          ║
║  2. In each file puts "Content of fileN"                           ║
║  3. Renames all to: document_1.txt, document_2.txt, ...            ║
║  4. Displays the list BEFORE and AFTER                             ║
║                                                                    ║
║  ─────────────────────────────────────────────────────────────────  ║
║  EXPECTED OUTPUT:                                                  ║
║                                                                    ║
║    === BEFORE ===                                                  ║
║    file1.txt  file2.txt  file3.txt  file4.txt  file5.txt           ║
║                                                                    ║
║    === AFTER ===                                                   ║
║    document_1.txt  document_2.txt  document_3.txt  ...             ║
║                                                                    ║
║  ─────────────────────────────────────────────────────────────────  ║
║  VERIFICATION: cat document_3.txt → "Content of file3"             ║
║                                                                    ║
╚════════════════════════════════════════════════════════════════════╝
```

💡 Solution:
```bash
#!/bin/bash
# batch_rename.sh

# Cleanup
rm -f file*.txt document_*.txt

# 1. Create files
for i in {1..5}; do
    echo "Content of file$i" > "file$i.txt"
done

# 2. Display before
echo "=== BEFORE ==="
ls file*.txt 2>/dev/null || echo "(no files)"
echo ""

# 3. Rename
for file in file*.txt; do
    # Extract number
    num=${file//[^0-9]/}
    mv "$file" "document_$num.txt"
done

# 4. Display after
echo "=== AFTER ==="
ls document_*.txt 2>/dev/null || echo "(no files)"

echo ""
echo "Verification document_3.txt:"
cat document_3.txt
```

---

### SPRINT B2: Directory Stats
Time: 10 min | Mode: Pairs | Points: 20

```
╔════════════════════════════════════════════════════════════════════╗
║  🏃 SPRINT B2: DIRECTORY STATS                                     ║
╠════════════════════════════════════════════════════════════════════╣
║                                                                    ║
║  OBJECTIVE: Write a script "dir_stats.sh" that receives a          ║
║            directory as argument and displays statistics           ║
║                                                                    ║
║  REQUIREMENTS:                                                     ║
║                                                                    ║
║    1. Check if the argument is a valid directory                   ║
║    2. For each subdirectory in the first level:                    ║
║       - Display the name                                           ║
║       - Number of files (not directories)                          ║
║       - Total size                                                 ║
║    3. At the end: global total                                     ║
║                                                                    ║
║  ─────────────────────────────────────────────────────────────────  ║
║  USAGE: ./dir_stats.sh /etc                                        ║
║                                                                    ║
║  EXAMPLE OUTPUT:                                                   ║
║                                                                    ║
║    📁 Statistics for: /etc                                         ║
║    ─────────────────────────────────────────                       ║
║    apt/           : 12 files, 45KB                                 ║
║    default/       : 8 files, 12KB                                  ║
║    ...                                                             ║
║    ─────────────────────────────────────────                       ║
║    TOTAL: 156 files, 2.3MB                                         ║
║                                                                    ║
╚════════════════════════════════════════════════════════════════════╝
```

💡 Solution:
```bash
#!/bin/bash
# dir_stats.sh - Directory statistics

DIR="${1:-.}"

# Verification
[[ ! -d "$DIR" ]] && { echo "✗ '$DIR' is not a valid directory"; exit 1; }

echo "📁 Statistics for: $DIR"
echo "─────────────────────────────────────────"

total_files=0
total_size=0

for subdir in "$DIR"/*/; do
    [[ ! -d "$subdir" ]] && continue
    
    name=$(basename "$subdir")
    files=$(find "$subdir" -maxdepth 1 -type f | wc -l)
    size=$(du -sh "$subdir" 2>/dev/null | cut -f1)
    
    printf "%-20s: %3d files, %s\n" "$name/" "$files" "$size"
    
    ((total_files += files))
done

echo "─────────────────────────────────────────"
total_size=$(du -sh "$DIR" 2>/dev/null | cut -f1)
echo "TOTAL: $total_files files in subdirectories, $total_size total"
```

---

### SPRINT B3: CSV Processor
Time: 15 min | Mode: Pairs | Points: 30

```
╔════════════════════════════════════════════════════════════════════╗
║  🏃 SPRINT B3: CSV PROCESSOR                                       ║
╠════════════════════════════════════════════════════════════════════╣
║                                                                    ║
║  OBJECTIVE: Process a CSV with student data                        ║
║                                                                    ║
║  SETUP - create students.csv:                                      ║
║                                                                    ║
║    cat > students.csv << 'EOF'                                     ║
║    name,group,grade1,grade2,grade3                                 ║
║    Popescu Ion,A1,8,9,7                                            ║
║    Ionescu Maria,A2,10,9,10                                        ║
║    Georgescu Ana,A1,6,7,8                                          ║
║    Vasilescu Dan,A2,9,8,9                                          ║
║    Marinescu Elena,A1,7,8,7                                        ║
║    EOF                                                             ║
║                                                                    ║
║  REQUIREMENTS for script "process_csv.sh":                         ║
║                                                                    ║
║    1. Read the CSV (skip header)                                   ║
║    2. For each student calculate the average                       ║
║    3. Display: name, group, average, status (Pass>=5/Fail)         ║
║    4. At the end: average by groups and overall average            ║
║                                                                    ║
║  ─────────────────────────────────────────────────────────────────  ║
║  EXPECTED OUTPUT:                                                  ║
║                                                                    ║
║    📊 STUDENT REPORT                                               ║
║    ─────────────────────────────────────────                       ║
║    Popescu Ion      | A1 | Average: 8.00 | ✓ Pass                  ║
║    Ionescu Maria    | A2 | Average: 9.67 | ✓ Pass                  ║
║    ...                                                             ║
║    ─────────────────────────────────────────                       ║
║    Group A1 average: 7.33                                          ║
║    Group A2 average: 9.17                                          ║
║    Overall average: 8.07                                           ║
║                                                                    ║
╚════════════════════════════════════════════════════════════════════╝
```

💡 Solution:
```bash
#!/bin/bash
# process_csv.sh - Student CSV processor

CSV="${1:-students.csv}"

[[ ! -f "$CSV" ]] && { echo "✗ File '$CSV' doesn't exist"; exit 1; }

echo "📊 STUDENT REPORT"
echo "═══════════════════════════════════════════════════════"

declare -A group_sum group_count
total_sum=0
total_count=0

# Skip header, process
tail -n +2 "$CSV" | while IFS=',' read -r name group n1 n2 n3; do
    # Calculate average (using bc for precision)
    average=$(echo "scale=2; ($n1 + $n2 + $n3) / 3" | bc)
    
    # Status
    status="✓ Pass"
    [[ $(echo "$average < 5" | bc) -eq 1 ]] && status="✗ Fail"
    
    printf "%-18s | %s | Average: %5.2f | %s\n" "$name" "$group" "$average" "$status"
done

echo "═══════════════════════════════════════════════════════"

# Group statistics (with awk for simplicity)
echo ""
echo "📈 GROUP STATISTICS:"
awk -F',' 'NR>1 {
    average = ($3 + $4 + $5) / 3
    group[$2] += average
    count[$2]++
    total += average
    n++
}
END {
    for (g in group) {
        printf "   Group %s average: %.2f\n", g, group[g]/count[g]
    }
    printf "\n   Overall average: %.2f\n", total/n
}' "$CSV"
```

---

## INTEGRATED SPRINTS

### SPRINT I1: System Report
Time: 15 min | Mode: Pairs | Points: 35

```
╔════════════════════════════════════════════════════════════════════╗
║  🏃 SPRINT I1: SYSTEM REPORT                                       ║
╠════════════════════════════════════════════════════════════════════╣
║                                                                    ║
║  OBJECTIVE: Create a complete script "system_report.sh"            ║
║                                                                    ║
║  REQUIREMENTS:                                                     ║
║                                                                    ║
║    1. Header with date, time, hostname                             ║
║    2. CPU section: model, cores, load average                      ║
║    3. Memory section: total, used, free, %                         ║
║    4. Disk section: top 3 partitions by usage                      ║
║    5. Processes section: top 5 by memory                           ║
║    6. Network section: active IPs, connections                     ║
║    7. Save to report_YYYYMMDD_HHMMSS.txt                           ║
║    8. Display confirmation message with file path                  ║
║                                                                    ║
║  ─────────────────────────────────────────────────────────────────  ║
║  BONUS (+5p): Add --html flag for HTML output                      ║
║  BONUS (+5p): Add comparison with previous report                  ║
║                                                                    ║
╚════════════════════════════════════════════════════════════════════╝
```

💡 Solution (short version):
```bash
#!/bin/bash
# system_report.sh - Complete system report

REPORT="report_$(date '+%Y%m%d_%H%M%S').txt"

{
    echo "════════════════════════════════════════════════════════════"
    echo "                    SYSTEM REPORT                           "
    echo "════════════════════════════════════════════════════════════"
    echo "Generated: $(date '+%Y-%m-%d %H:%M:%S')"
    echo "Hostname:  $(hostname)"
    echo ""
    
    echo "━━━ CPU ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    grep "model name" /proc/cpuinfo | head -1 | cut -d: -f2
    echo "Cores: $(nproc)"
    echo "Load:  $(cat /proc/loadavg | cut -d' ' -f1-3)"
    echo ""
    
    echo "━━━ MEMORY ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    free -h | grep -E "Mem:|Swap:"
    echo ""
    
    echo "━━━ DISK (top 3) ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    df -h | head -1
    df -h | tail -n +2 | sort -k5 -rn | head -3
    echo ""
    
    echo "━━━ TOP 5 PROCESSES (MEM) ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    ps aux --sort=-%mem | head -6
    echo ""
    
    echo "━━━ NETWORK ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "IPs:"
    ip -4 addr show | grep inet | awk '{print "  " $2}'
    echo "Active connections: $(ss -tuln | wc -l)"
    echo ""
    
    echo "════════════════════════════════════════════════════════════"
} | tee "$REPORT"

echo ""
echo "✓ Report saved to: $REPORT"
```

---

### SPRINT I2: Rotating Backup
Time: 15 min | Mode: Pairs | Points: 40

```
╔════════════════════════════════════════════════════════════════════╗
║  🏃 SPRINT I2: ROTATING BACKUP                                     ║
╠════════════════════════════════════════════════════════════════════╣
║                                                                    ║
║  OBJECTIVE: Script "backup_rotate.sh" with automatic rotation      ║
║                                                                    ║
║  REQUIREMENTS:                                                     ║
║                                                                    ║
║    1. Receives: source_directory, backup_directory, max_backups    ║
║    2. Creates backup with timestamp: backup_YYYYMMDD_HHMMSS.tar.gz ║
║    3. If more than max_backups exist, delete the old ones          ║
║    4. Logging to backup.log (append)                               ║
║    5. Exit codes: 0=success, 1=argument error, 2=backup error      ║
║                                                                    ║
║  ─────────────────────────────────────────────────────────────────  ║
║  USAGE:                                                            ║
║    ./backup_rotate.sh /home/user/data /backup 5                    ║
║                                                                    ║
║  VERIFICATION:                                                     ║
║    • Run 7 times → only 5 backups remain                           ║
║    • backup.log contains all operations                            ║
║                                                                    ║
╚════════════════════════════════════════════════════════════════════╝
```

---

## SPRINT USAGE MATRIX

| Sprint | Main Concept | Duration | Level | Optimal Moment |
|--------|--------------|----------|-------|----------------|
| O1 | && and \|\| | 5 min | ⭐ | After live coding operators |
| O2 | if, pgrep, & | 10 min | ⭐⭐ | After background |
| O3 | build pipeline | 12 min | ⭐⭐⭐ | Final operator exercise |
| R1 | Redirection 2>&1 | 10 min | ⭐⭐ | After live coding redirect |
| R2 | Here document | 10 min | ⭐⭐ | After << explained |
| R3 | tee, while read | 12 min | ⭐⭐⭐ | Final redirect exercise |
| F1 | cut, sort, head | 5 min | ⭐ | After live coding filters |
| F2 | tr, uniq -c | 10 min | ⭐⭐ | After frequency demo |
| F3 | awk, pipeline | 15 min | ⭐⭐⭐ | Final filter exercise |
| B1 | for, mv | 10 min | ⭐⭐ | After live coding for |
| B2 | for, find, du | 10 min | ⭐⭐ | After directory iteration |
| B3 | while IFS read | 15 min | ⭐⭐⭐ | After CSV reading |
| I1 | All semester | 15 min | ⭐⭐⭐ | Seminar end |
| I2 | Advanced | 15 min | ⭐⭐⭐⭐ | Homework/Bonus |

---

## PROGRESS TRACKING

```
╔════════════════════════════════════════════════════════════════════╗
║  SPRINT TRACKING - Seminar [DATE]                                  ║
╠════════════════════════════════════════════════════════════════════╣
║  Student: ___________________ Group: ______                        ║
╠════════════════════════════════════════════════════════════════════╣
║  Sprint    │ Completed │ Real Time │ Points │ Observations         ║
║  ──────────┼───────────┼───────────┼────────┼────────────────────  ║
║  O1        │ □ Yes □ No│ ___ min   │ __/10  │                      ║
║  O2        │ □ Yes □ No│ ___ min   │ __/20  │                      ║
║  R1        │ □ Yes □ No│ ___ min   │ __/20  │                      ║
║  F1        │ □ Yes □ No│ ___ min   │ __/10  │                      ║
║  F2        │ □ Yes □ No│ ___ min   │ __/20  │                      ║
║  B1        │ □ Yes □ No│ ___ min   │ __/20  │                      ║
║  I1        │ □ Yes □ No│ ___ min   │ __/35  │                      ║
║  ──────────┼───────────┼───────────┼────────┼────────────────────  ║
║  TOTAL     │           │           │ __/135 │                      ║
╚════════════════════════════════════════════════════════════════════╝
```

---

*Document generated for Seminar 3-4 OS | ASE Bucharest - CSIE*  
*Timed exercises for active learning and consolidation*
