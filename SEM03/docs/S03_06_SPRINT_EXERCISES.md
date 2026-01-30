# Sprint Exercises - Seminar 03
## Operating Systems | Timed Exercises with Pair Programming

Method: Pair Programming with switch at half-time
**Structure**: Setup → Requirements → Hints → Verification → Solution
**Note**: Students work in pairs, alternating Driver/Navigator roles

---

## GENERAL RULES

### Pair Programming Protocol

```
╔═══════════════════════════════════════════════════════════════╗
║  🎮 DRIVER (types)            🧭 NAVIGATOR (guides)          ║
║  - Writes code               - Reads the requirement          ║
║  - Executes commands         - Checks syntax                  ║
║  - Doesn't plan alone        - Suggests approaches            ║
║                                                               ║
║  ⏱️ SWITCH at half-time!                                      ║
╚═══════════════════════════════════════════════════════════════╝
```

### Difficulty Levels

| Emoji | Level | Description |
|-------|-------|-------------|
| 🟢 | Easy | Direct application |
| 🟡 | Medium | Combining concepts |
| 🔴 | Hard | Synthesis and creativity |
| ⭐ | Bonus | Advanced challenge |

---

## SECTION 1: FIND SPRINTS

### SPRINT F1: File Hunter
**Duration**: 10 minutes (Switch at minute 5)

#### Setup (1 minute)
```bash
# Copy and execute:
mkdir -p ~/sprint_f1/{src,docs,tests,logs,backup,temp}
touch ~/sprint_f1/src/{main,utils,config}.{c,h,py}
touch ~/sprint_f1/docs/{README.md,manual.txt,api.html,guide.pdf}
touch ~/sprint_f1/tests/test_{unit,integration,e2e}_{1..3}.py
touch ~/sprint_f1/logs/app_{debug,info,error}.log
dd if=/dev/zero of=~/sprint_f1/backup/archive.tar bs=1M count=3 2>/dev/null
touch -d "10 days ago" ~/sprint_f1/temp/old_cache.tmp
touch -d "40 days ago" ~/sprint_f1/temp/ancient_cache.tmp
touch ~/sprint_f1/temp/recent_cache.tmp
cd ~/sprint_f1
echo "✅ Setup complete! Current directory: $(pwd)"
```

#### Requirements

```
═══════════════════════════════════════════════════════════════
🎯 SPRINT F1 OBJECTIVES

1. 🟢 Find all .py files from the current directory (recursive)
   [Verification: you should find 12 files]

2. 🟢 Find all files with extension .c OR .h
   [Verification: you should find 6 files]

3. 🟡 Find files larger than 1MB
   [Verification: you should find 1 file]

4. 🟡 Find files modified in the last 7 days, 
   EXCLUDING the logs/ directory
   [Verification: count the results]

5. 🔴 Find all .tmp files older than 30 days
   and display them with size in format: "SIZE PATH"
   [Verification: you should find 1 file]

BONUS ⭐: Find all files, sorted by size
         descending, first 5.

═══════════════════════════════════════════════════════════════
```

#### Hints (if you get stuck)

<details>
<summary>Hint 1</summary>
Pattern for OR: find . \( -name "*.c" -o -name "*.h" \)
</details>

<details>
<summary>Hint 2</summary>
Directory exclusion: ! -path "./logs/*"
</details>

<details>
<summary>Hint 3</summary>
Printf for format: -printf '%s %p\n'
</details>

#### Verification and Solutions

```bash
# SOLUTIONS:

# 1. .py files
find . -name "*.py" -type f
# Output: 12 files

# 2. .c OR .h files
find . -type f \( -name "*.c" -o -name "*.h" \)
# Output: 6 files

# 3. Files > 1MB
find . -type f -size +1M
# Output: ./backup/archive.tar

# 4. Modified in 7 days, without logs/
find . -type f -mtime -7 ! -path "./logs/*"
# Output: variable

# 5. .tmp > 30 days with size
find . -name "*.tmp" -type f -mtime +30 -printf '%s %p\n'
# Output: 0 ./temp/ancient_cache.tmp

# BONUS: Top 5 by size
find . -type f -printf '%s %p\n' | sort -rn | head -5
```

---

### SPRINT F2: Cleanup Master
**Duration**: 12 minutes (Switch at minute 6)

#### Setup (1 minute)
```bash
mkdir -p ~/sprint_f2/{project,cache,logs,temp}

# Code files
touch ~/sprint_f2/project/{app,lib,main}.{js,ts,jsx}
echo "console.log('test');" > ~/sprint_f2/project/app.js

# Cache files
touch ~/sprint_f2/cache/{session,data,auth}_{001..010}.cache
touch -d "8 days ago" ~/sprint_f2/cache/old_{1..5}.cache

# Log files of different sizes
for i in 1 2 3; do
    dd if=/dev/zero of=~/sprint_f2/logs/app_$i.log bs=1K count=$((i*100)) 2>/dev/null
done
dd if=/dev/zero of=~/sprint_f2/logs/giant.log bs=1M count=15 2>/dev/null

# Temporary files
touch ~/sprint_f2/temp/{tmp,temp,scratch}_{1..5}.{tmp,bak,swp}
touch -d "20 days ago" ~/sprint_f2/temp/old_backup.bak

# Files with spaces (challenge!)
touch "~/sprint_f2/project/my component.jsx"
touch "~/sprint_f2/logs/error report.log"

cd ~/sprint_f2
echo "✅ Setup complete!"
```

#### Requirements

```
═══════════════════════════════════════════════════════════════
🎯 SPRINT F2 OBJECTIVES

1. 🟢 List all .cache files older than 7 days
   DO NOT DELETE THEM YET!

2. 🟡 Find log files larger than 500KB and display 
   size in MB: "X.XX MB: /path/to/file"

3. 🟡 Using xargs, count lines in all .js files
   (beware of files with spaces!)

4. 🔴 Create a command that would DELETE all .tmp, 
   .bak and .swp files older than 14 days.
   BUT run it first with -print for verification!

5. 🔴 Find empty directories and display them.

BONUS ⭐: Archive all .log files into a tar.gz
         using find and xargs.

═══════════════════════════════════════════════════════════════
```

#### Hints

<details>
<summary>Hint for #2</summary>
Use -printf with calculation: awk or bc for conversion
Or: -printf '%k KB %p\n' for KB directly
</details>

<details>
<summary>Hint for #3</summary>
-print0 | xargs -0 for spaces
</details>

<details>
<summary>Hint for #5</summary>
find . -type d -empty
</details>

#### Solutions

```bash
# SOLUTIONS:

# 1. Cache > 7 days
find ./cache -name "*.cache" -type f -mtime +7

# 2. Logs > 500KB with size in MB
find ./logs -name "*.log" -type f -size +500k \
    -printf '%s %p\n' | \
    awk '{printf "%.2f MB: %s\n", $1/1048576, $2}'

# 3. Lines in .js (with spaces)
find . -name "*.js" -type f -print0 | xargs -0 wc -l

# 4. Simulated deletion (print only)
find . -type f \( -name "*.tmp" -o -name "*.bak" -o -name "*.swp" \) \
    -mtime +14 -print
# For real deletion: change -print to -delete

# 5. Empty directories
find . -type d -empty

# BONUS: Archive logs
find . -name "*.log" -type f -print0 | \
    xargs -0 tar czvf logs_archive.tar.gz
```

---

## SECTION 2: SCRIPT SPRINTS

### SPRINT S1: Argument Parser
**Duration**: 15 minutes (Switch at minute 7-8)

#### Setup
```bash
mkdir -p ~/sprint_s1
cd ~/sprint_s1
echo "✅ Directory created: $(pwd)"
```

#### Requirements

```
═══════════════════════════════════════════════════════════════
🎯 SPRINT S1 OBJECTIVES

Create a script "processor.sh" that:

1. 🟢 Accepts options:
   -h          : Display help and exit
   -v          : Verbose mode (default: false)
   -o FILE     : Output file (default: output.txt)
   -n NUMBER   : Number of iterations (default: 1)

2. 🟡 After options, accepts one or more files as arguments

3. 🟡 Validations:
   - If no files received, error and help
   - If -n is not a positive number, error
   - If input file doesn't exist, warning
- Verify result before continuing

4. 🔴 Logic (simplified):
   - Display "Processing: [filename]" for each file
   - If verbose: also display "Output: [output_file]"
   - At the end: "Done! Processed N files in M iterations"

TESTS TO RUN:
./processor.sh -h
./processor.sh                     # Error: no files
./processor.sh -v -o result.txt -n 3 file1.txt file2.txt
./processor.sh file1.txt file2.txt

═══════════════════════════════════════════════════════════════
```

#### Starter Template

```bash
#!/bin/bash

# Default values
verbose=false
output_file="output.txt"
iterations=1

# Usage function
usage() {
    echo "Usage: $0 [-h] [-v] [-o file] [-n num] files..."
    echo "  -h        Show help"
    echo "  -v        Verbose mode"
    echo "  -o FILE   Output file (default: output.txt)"
    echo "  -n NUM    Iterations (default: 1)"
    exit 0
}

# TODO: Option parsing with getopts

# TODO: Validation and processing
```

#### Complete Solution

```bash
#!/bin/bash

# Default values
verbose=false
output_file="output.txt"
iterations=1

# Usage function
usage() {
    echo "Usage: $0 [-h] [-v] [-o file] [-n num] files..."
    echo "  -h        Show help"
    echo "  -v        Verbose mode"
    echo "  -o FILE   Output file (default: output.txt)"
    echo "  -n NUM    Iterations (default: 1)"
    exit 0
}

# Option parsing
while getopts "hvo:n:" opt; do
    case $opt in
        h) usage ;;
        v) verbose=true ;;
        o) output_file="$OPTARG" ;;
        n) iterations="$OPTARG" ;;
        ?) echo "Invalid option"; exit 1 ;;
    esac
done
shift $((OPTIND - 1))

# Validation: at least one file
if [ $# -eq 0 ]; then
    echo "Error: No file specified!" >&2
    usage
fi

# Validation: iterations is positive number
if ! [[ "$iterations" =~ ^[0-9]+$ ]] || [ "$iterations" -lt 1 ]; then
    echo "Error: -n must be a positive number!" >&2
    exit 1
fi

# Processing
file_count=0
for file in "$@"; do
    if [ ! -f "$file" ]; then
        echo "Warning: '$file' doesn't exist, skip..." >&2
        continue
    fi
    
    echo "Processing: $file"
    
    if [ "$verbose" = true ]; then
        echo "  Output: $output_file"
        echo "  Iterations: $iterations"
    fi
    
    ((file_count++))
done

echo "Done! Processed $file_count files in $iterations iterations"
```

---

### SPRINT S2: File Analyzer
**Duration**: 15 minutes (Switch at minute 7-8)

#### Setup
```bash
mkdir -p ~/sprint_s2/data
cd ~/sprint_s2

# Create test files
echo -e "line1\nline2\nline3" > data/small.txt
for i in {1..100}; do echo "Line $i of medium file"; done > data/medium.txt
for i in {1..1000}; do echo "Line $i of large file"; done > data/large.txt
echo "✅ Setup complete!"
```

#### Requirements

```
═══════════════════════════════════════════════════════════════
🎯 SPRINT S2 OBJECTIVES

Create a script "analyse.sh" that:

1. 🟢 Accepts options:
   -h / --help     : Help
   -l / --lines    : Count lines
   -w / --words    : Count words
   -c / --chars    : Count characters
   -a / --all      : All statistics (default)

2. 🟡 Processes multiple files
   - Display statistics per file
   - At the end, display TOTAL

3. 🔴 Supports long options (--help, --lines, etc.)
   Hint: while loop with case for manual getopt

4. 🔴 Nicely formatted output:
   FILE          LINES    WORDS    CHARS
   small.txt         3       3       18
   medium.txt      100     500     2000
   TOTAL           103     503     2018

═══════════════════════════════════════════════════════════════
```

#### Partial Solution (with long options)

```bash
#!/bin/bash

show_lines=false
show_words=false
show_chars=false

usage() {
    echo "Usage: $0 [-h|--help] [-l|--lines] [-w|--words] [-c|--chars] [-a|--all] files..."
    exit 0
}

# Option parsing (long support)
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)  usage ;;
        -l|--lines) show_lines=true; shift ;;
        -w|--words) show_words=true; shift ;;
        -c|--chars) show_chars=true; shift ;;
        -a|--all)   show_lines=true; show_words=true; show_chars=true; shift ;;
        -*)         echo "Unknown option: $1"; exit 1 ;;
        *)          break ;;  # First non-option = start of files
    esac
done

# Default: all
if ! $show_lines && ! $show_words && ! $show_chars; then
    show_lines=true; show_words=true; show_chars=true
fi

# Validation
[ $# -eq 0 ] && { echo "Error: specify files!"; exit 1; }

# Header
printf "%-20s" "FILE"
$show_lines && printf "%10s" "LINES"
$show_words && printf "%10s" "WORDS"
$show_chars && printf "%10s" "CHARS"
echo ""

# Processing
total_lines=0; total_words=0; total_chars=0

for file in "$@"; do
    [ ! -f "$file" ] && continue
    
    lines=$(wc -l < "$file")
    words=$(wc -w < "$file")
    chars=$(wc -c < "$file")
    
    printf "%-20s" "$(basename "$file")"
    $show_lines && printf "%10d" "$lines"
    $show_words && printf "%10d" "$words"
    $show_chars && printf "%10d" "$chars"
    echo ""
    
    ((total_lines += lines))
    ((total_words += words))
    ((total_chars += chars))
done

# Total
echo "--------------------"
printf "%-20s" "TOTAL"
$show_lines && printf "%10d" "$total_lines"
$show_words && printf "%10d" "$total_words"
$show_chars && printf "%10d" "$total_chars"
echo ""
```

---

## SECTION 3: PERMISSION SPRINTS

### SPRINT P1: Permission Fixer
**Duration**: 10 minutes (Switch at minute 5)

#### Setup
```bash
mkdir -p ~/sprint_p1/{public,private,scripts,shared}
cd ~/sprint_p1

# Public - should be readable by all
touch public/{index.html,style.css,logo.png}
chmod 600 public/*  # Intentionally wrong!

# Private - should be owner only
touch private/{passwords.txt,keys.pem,config.ini}
chmod 777 private/*  # Intentionally wrong!

# Scripts - should be executable
echo '#!/bin/bash' > scripts/deploy.sh
echo 'echo "Hello"' >> scripts/deploy.sh
echo '#!/bin/bash' > scripts/backup.sh  
echo 'echo "Backup"' >> scripts/backup.sh
chmod 644 scripts/*  # Intentionally without execute!

# Shared - SGID for team
mkdir -p shared/team_project
touch shared/team_project/{doc1.txt,doc2.txt}
# SGID not configured!

echo "✅ Setup complete! Check permissions with: ls -laR"
```

#### Requirements

```
═══════════════════════════════════════════════════════════════
🎯 SPRINT P1 OBJECTIVES

1. 🟢 Correct public/: 
   - Files must be readable by all (644)
   
2. 🟢 Correct private/:
   - Files must be ONLY for owner (600)
   
3. 🟡 Correct scripts/:
   - .sh scripts must be executable
   - Owner: rwx, Group: rx, Others: rx (755)
   
4. 🔴 Configure shared/team_project/:
   - Directory with SGID (new files inherit group)
   - Permissions: owner and group can write, others nothing
   - Result: drwxrws--- (2770)
   
5. 🔴 Write commands that find files with dangerous
   permissions (777 or world-writable)

FINAL VERIFICATION: ls -laR should show correct permissions

═══════════════════════════════════════════════════════════════
```

#### Solutions

```bash
# 1. Public - readable by all
chmod 644 public/*
# Verification:
ls -l public/

# 2. Private - owner only
chmod 600 private/*
# Verification:
ls -l private/

# 3. Scripts - executable
chmod 755 scripts/*.sh
# Verification:
ls -l scripts/

# 4. Shared with SGID
chmod 2770 shared/team_project/
# OR:
chmod g+s shared/team_project/
chmod 770 shared/team_project/
# Verification:
ls -ld shared/team_project/

# 5. Find dangerous files
# World-writable:
find . -type f -perm -002 -ls
# Or perm 777:
find . -type f -perm 777 -ls
```

---

### SPRINT P2: Shared Directory Setup
**Duration**: 12 minutes (Switch at minute 6)

#### Setup
```bash
mkdir -p ~/sprint_p2
cd ~/sprint_p2

# Simulate a team project
mkdir -p company_project/{src,docs,releases}
touch company_project/src/{main.py,utils.py}
touch company_project/docs/{README.md,API.md}
touch company_project/releases/v1.0.tar.gz

echo "✅ Setup complete!"
```

#### Requirements (Real Scenario)

```
═══════════════════════════════════════════════════════════════
🎯 SCENARIO: Shared Directory Configuration for Team

You are administrator and must configure company_project/
for a development team (group "developers").

SECURITY REQUIREMENTS:

1. 🟡 Main directory company_project/:
   - Owner and group can read/write
   - Others have no access
   - SGID set (new files belong to group)

2. 🟡 Subdirectory src/:
   - Only owner can write
   - Group can read
   - Others have no access

3. 🔴 Subdirectory releases/:
   - All from group can write
   - Sticky bit set (each deletes only what they created)
   - Others can read but not write

4. 🔴 Set umask for current session such that
   new files have 640 (rw-r-----)

5. ⭐ BONUS: Write a script that verifies all 
   permissions are correct

═══════════════════════════════════════════════════════════════
```

#### Solutions

```bash
# 1. Main directory with SGID
chmod 2770 company_project/
# drwxrws---

# 2. src/ - restrictive
chmod 750 company_project/src/
chmod 640 company_project/src/*
# drwxr-x--- and -rw-r-----

# 3. releases/ with Sticky
chmod 1775 company_project/releases/
# drwxrwxr-t
chmod 644 company_project/releases/*

# 4. umask for 640
umask 027
# Verification:
touch company_project/test_umask.txt
ls -l company_project/test_umask.txt
# -rw-r-----

# 5. BONUS: Verification script
cat > verify_perms.sh << 'EOF'
#!/bin/bash
echo "Verifying company_project/ permissions:"

# Check SGID on main directory
if [ -g company_project ]; then
    echo "✅ SGID set on company_project/"
else
    echo "❌ SGID missing!"
fi

# Check Sticky on releases
if [ -k company_project/releases ]; then
    echo "✅ Sticky bit set on releases/"
else
    echo "❌ Sticky bit missing!"
fi

# Check numeric permissions
stat_main=$(stat -c %a company_project)
[ "$stat_main" = "2770" ] && echo "✅ company_project/ = 2770" || echo "❌ company_project/ = $stat_main"

stat_src=$(stat -c %a company_project/src)
[ "$stat_src" = "750" ] && echo "✅ src/ = 750" || echo "❌ src/ = $stat_src"

stat_rel=$(stat -c %a company_project/releases)
[ "$stat_rel" = "1775" ] && echo "✅ releases/ = 1775" || echo "❌ releases/ = $stat_rel"
EOF
chmod +x verify_perms.sh
./verify_perms.sh
```

---

## SECTION 4: CRON SPRINTS

### SPRINT C1: Cron Designer
**Duration**: 10 minutes (Switch at minute 5)

#### Requirements

```
═══════════════════════════════════════════════════════════════
🎯 SPRINT C1 OBJECTIVES

Write crontab expressions for the following scenarios.
DO NOT add them to real crontab, just write them to a file!

1. 🟢 Daily backup at 3:00 AM
   Script: /home/user/backup.sh

2. 🟢 Disk check every hour, only during daytime (8-20)
   Script: /usr/local/bin/check_disk.sh

3. 🟡 Temporary files cleanup every 15 minutes, 
   only Monday-Friday
   Script: /opt/scripts/cleanup.sh

4. 🟡 Weekly report on Sunday at 23:00
   Script: /home/user/weekly_report.sh
   Log: >> /var/log/weekly.log 2>&1

5. 🔴 System monitoring:
   - Every 5 minutes between 9:00-17:00
   - Only on working days
   - In the first and third week of the month (days 1-7, 15-21)
   Script: /opt/monitor.sh

BONUS ⭐: Job that runs only at reboot

═══════════════════════════════════════════════════════════════
```

#### Solutions

```bash
# Create file with solutions
cat > cron_solutions.txt << 'EOF'
# SPRINT C1 SOLUTIONS

# 1. Daily backup 3:00 AM
0 3 * * * /home/user/backup.sh

# 2. Disk check every hour, 8-20
0 8-20 * * * /usr/local/bin/check_disk.sh

# 3. Cleanup every 15 min, Monday-Friday
*/15 * * * 1-5 /opt/scripts/cleanup.sh

# 4. Report Sunday 23:00 with logging
0 23 * * 0 /home/user/weekly_report.sh >> /var/log/weekly.log 2>&1

# 5. Complex monitoring
*/5 9-17 1-7,15-21 * 1-5 /opt/monitor.sh

# BONUS: At reboot
@reboot /home/user/startup_tasks.sh
EOF

cat cron_solutions.txt
```

---

### SPRINT C2: Automation Script
**Duration**: 15 minutes (Switch at minute 7-8)

#### Requirements

```
═══════════════════════════════════════════════════════════════
🎯 SPRINT C2 OBJECTIVES

Create a complete "daily_maintenance.sh" script for cron:

REQUIRED FEATURES:

1. 🟢 Set PATH explicitly at the beginning
   PATH=/usr/local/bin:/usr/bin:/bin

2. 🟡 Logging:
   - All messages to /var/log/maintenance.log
   - Include timestamp with each message
   - Function: log_message() { ... }

3. 🟡 Lock file to prevent multiple executions:
   - Lock: /tmp/daily_maintenance.lock
   - If lock exists, exit with message

4. 🔴 Tasks (all with logging):
   a) Delete .tmp files older than 7 days from /tmp
   b) Compress .log files older than 30 days
   c) Check disk space (warning if > 80%)

5. 🔴 Cleanup at the end:
   - Remove lock file
   - Log execution duration

BONUS ⭐: Add trap for cleanup on errors/interrupt

═══════════════════════════════════════════════════════════════
```

#### Complete Solution

```bash
#!/bin/bash
# daily_maintenance.sh - Maintenance script for cron

# 1. Explicit PATH
PATH=/usr/local/bin:/usr/bin:/bin
export PATH

# Configuration
LOG_FILE="/var/log/maintenance.log"
LOCK_FILE="/tmp/daily_maintenance.lock"
START_TIME=$(date +%s)

# 2. Logging function
log_message() {
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] $1" >> "$LOG_FILE"
}

# 5. BONUS: Trap for cleanup
cleanup() {
    rm -f "$LOCK_FILE"
    local end_time
    end_time=$(date +%s)
    local duration=$((end_time - START_TIME))
    log_message "Script terminated. Duration: ${duration}s"
}
trap cleanup EXIT

# 3. Lock file
if [ -f "$LOCK_FILE" ]; then
    log_message "ERROR: Script already running (lock exists)"
    exit 1
fi
touch "$LOCK_FILE"

log_message "=== START Daily Maintenance ==="

# 4a. Delete old .tmp files
log_message "Task: Cleanup /tmp..."
deleted_count=$(find /tmp -name "*.tmp" -type f -mtime +7 -delete -print 2>/dev/null | wc -l)
log_message "  Deleted $deleted_count .tmp files"

# 4b. Compress old logs
log_message "Task: Compressing old logs..."
compressed_count=0
while IFS= read -r -d '' logfile; do
    gzip "$logfile" 2>/dev/null && ((compressed_count++))
done < <(find /var/log -name "*.log" -type f -mtime +30 -print0 2>/dev/null)
log_message "  Compressed $compressed_count log files"

# 4c. Disk space check
log_message "Task: Checking disk space..."
while read -r line; do
    usage=$(echo "$line" | awk '{print $5}' | tr -d '%')
    mount=$(echo "$line" | awk '{print $6}')
    
    if [ "$usage" -gt 80 ]; then
        log_message "  ⚠️ WARNING: $mount using $usage%"
    else
        log_message "  ✓ $mount: $usage%"
    fi
done < <(df -h | grep -E '^/dev' | awk '{print $5" "$6}')

log_message "=== END Daily Maintenance ==="

# Cleanup is done automatically via trap
```

---

## FINAL VERIFICATION

### Instructor Checklist

| Sprint | Completed | Notes |
|--------|-----------|-------|
| F1: File Hunter | ☐ | |
| F2: Cleanup Master | ☐ | |
| S1: Argument Parser | ☐ | |
| S2: File Analyzer | ☐ | |
| P1: Permission Fixer | ☐ | |
| P2: Shared Directory | ☐ | |
| C1: Cron Designer | ☐ | |
| C2: Automation Script | ☐ | |

### Post-Sprint Cleanup

```bash
# Cleanup all sprint directories
rm -rf ~/sprint_f1 ~/sprint_f2 ~/sprint_s1 ~/sprint_s2
rm -rf ~/sprint_p1 ~/sprint_p2
rm -f ~/test_cron.sh /tmp/cron_test.log

echo "✅ Cleanup complete!"
```

---

*Document generated for UES Bucharest - CSIE | Operating Systems | Seminar 3*
