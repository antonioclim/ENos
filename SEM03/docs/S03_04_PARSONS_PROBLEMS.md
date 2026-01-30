# Parsons Problems - Seminar 03
## Operating Systems | Command Reordering and Construction

Purpose: Reordering exercises for syntax consolidation and command structure comprehension
Estimated duration: 3-5 minutes per problem
Method: Scrambled lines + 1-2 distractors (unnecessary or incorrect lines)

---

## USAGE GUIDE

### What are Parsons Problems?
Parsons Problems are exercises where students receive scrambled lines of code and must reorder them to obtain a correct solution. This method:

- Reduces cognitive load (no writing from scratch)
- Focuses attention on STRUCTURE and SYNTAX
- Includes distractors for critical thinking


### Notation Conventions

```
═══════════════════════════════════════════════════════════════
🧩 PARSONS PROBLEM #N: [Title]

📝 REQUIREMENT:
[Description of the problem to solve]

📦 SCRAMBLED LINES:
─────────────────────────────────────────────────────────────────
   [line 1]
   [line 2]
   [line 3]
   [DISTRACTOR - line that should NOT be used]           ← ❌
─────────────────────────────────────────────────────────────────

⏱️ Estimated time: X minutes

═══════════════════════════════════════════════════════════════
```

---

## SECTION 1: PARSONS PROBLEMS FOR FIND AND XARGS

### PP-F01: Complex Find with Multiple Criteria

```
═══════════════════════════════════════════════════════════════
🧩 PARSONS PROBLEM #F01: Advanced Search

📝 REQUIREMENT:
Find all .log files larger than 100KB, modified within the 
last 7 days, in the /var/log directory (recursive, maximum 3 levels).
Display them with full path.

📦 SCRAMBLED LINES:
─────────────────────────────────────────────────────────────────
   -maxdepth 3
   -type f
   -name "*.log"
   find /var/log
   -size +100k
   -mtime -7
   -print
   -mindepth 1                                              ← ❌
   -newer /etc/passwd                                       ← ❌
─────────────────────────────────────────────────────────────────

⏱️ Estimated time: 3 minutes

═══════════════════════════════════════════════════════════════
```

✅ SOLUTION:
```bash
find /var/log -maxdepth 3 -type f -name "*.log" -size +100k -mtime -7 -print
```

📖 EXPLANATION:
1. `find /var/log` - start search in /var/log
2. `-maxdepth 3` - limit depth to 3 levels
3. `-type f` - files only (not directories)
4. `-name "*.log"` - name pattern
5. `-size +100k` - larger than 100KB
6. `-mtime -7` - modified within last 7 days
7. `-print` - display results

❌ DISTRACTORS:
- `-mindepth 1` - not required to exclude current level
- `-newer /etc/passwd` - incorrectly modifies temporal criterion

---

### PP-F02: Find with OR and Grouping

```
═══════════════════════════════════════════════════════════════
🧩 PARSONS PROBLEM #F02: Search with Alternative

📝 REQUIREMENT:
Find all .sh OR .py files from the current directory,
but EXCLUDE those from the "build" subdirectory.

📦 SCRAMBLED LINES:
─────────────────────────────────────────────────────────────────
   -type f
   find .
   \( -name "*.sh" -o -name "*.py" \)
   ! -path "./build/*"
   -name "*.sh" -or -name "*.py"                            ← ❌
   -not -type d                                              ← ❌
─────────────────────────────────────────────────────────────────

⏱️ Estimated time: 4 minutes

═══════════════════════════════════════════════════════════════
```

✅ SOLUTION:
```bash
find . -type f \( -name "*.sh" -o -name "*.py" \) ! -path "./build/*"
```

📖 EXPLANATION:
1. `find .` - search from current directory
2. `-type f` - files only
3. `\( -name "*.sh" -o -name "*.py" \)` - grouping for correct OR
4. `! -path "./build/*"` - exclude build directory

❌ DISTRACTORS:
- `-name "*.sh" -or -name "*.py"` - without grouping, precedence is wrong
- `-not -type d` - redundant when you already have `-type f`

---

### PP-F03: Find with Exec and Confirmation

```
═══════════════════════════════════════════════════════════════
🧩 PARSONS PROBLEM #F03: Safe Deletion

📝 REQUIREMENT:
Find temporary files (*.tmp) older than 30 days
in /tmp and delete them WITH CONFIRMATION for each.

📦 SCRAMBLED LINES:
─────────────────────────────────────────────────────────────────
   -mtime +30
   find /tmp
   -name "*.tmp"
   -type f
   -ok rm {} \;
   -exec rm -rf {} +                                         ← ❌
   -delete                                                   ← ❌
─────────────────────────────────────────────────────────────────

⏱️ Estimated time: 3 minutes

═══════════════════════════════════════════════════════════════
```

✅ SOLUTION:
```bash
find /tmp -type f -name "*.tmp" -mtime +30 -ok rm {} \;
```

📖 EXPLANATION:
1. `find /tmp` - search in /tmp
2. `-type f` - files only
3. `-name "*.tmp"` - temporary files
4. `-mtime +30` - older than 30 days
5. `-ok rm {} \;` - delete with confirmation ("-ok" requests confirmation)

❌ DISTRACTORS:
- `-exec rm -rf {} +` - without confirmation, dangerous!
- `-delete` - deletes directly without confirmation

---

### PP-F04: Find with Xargs and Batch Processing

```
═══════════════════════════════════════════════════════════════
🧩 PARSONS PROBLEM #F04: Efficient Processing

📝 REQUIREMENT:
Find all .c files from src/, correctly handling 
files with spaces in names, and display line count.

📦 SCRAMBLED LINES:
─────────────────────────────────────────────────────────────────
   xargs -0 wc -l
   find src/ -type f -name "*.c"
   -print0
   |
   xargs wc -l                                               ← ❌
   -exec wc -l {} \;                                         ← ❌
─────────────────────────────────────────────────────────────────

⏱️ Estimated time: 3 minutes

═══════════════════════════════════════════════════════════════
```

✅ SOLUTION:
```bash
find src/ -type f -name "*.c" -print0 | xargs -0 wc -l
```

📖 EXPLANATION:
1. `find src/ -type f -name "*.c"` - find .c files
2. `-print0` - output separated by null (handles spaces)
3. `|` - pipe to xargs
4. `xargs -0 wc -l` - read null-delimited input, execute wc

❌ DISTRACTORS:
- `xargs wc -l` - without -0, problems with spaces
- `-exec wc -l {} \;` - runs wc separately for each file (inefficient)

---

### PP-F05: Find with Multiple Actions

```
═══════════════════════════════════════════════════════════════
🧩 PARSONS PROBLEM #F05: Complete Report

📝 REQUIREMENT:
Find .conf files from /etc (first level only) and 
display for each: permissions, size, path.
Format: drwxr-xr-x 1234 /etc/file.conf

📦 SCRAMBLED LINES:
─────────────────────────────────────────────────────────────────
   find /etc
   -maxdepth 1
   -name "*.conf"
   -type f
   -printf '%M %s %p\n'
   -ls                                                       ← ❌
   | awk '{print $1,$5,$NF}'                                 ← ❌
─────────────────────────────────────────────────────────────────

⏱️ Estimated time: 4 minutes

═══════════════════════════════════════════════════════════════
```

✅ SOLUTION:
```bash
find /etc -maxdepth 1 -type f -name "*.conf" -printf '%M %s %p\n'
```

📖 EXPLANATION:
1. `find /etc` - search in /etc
2. `-maxdepth 1` - first level only
3. `-type f` - files only
4. `-name "*.conf"` - name pattern
5. `-printf '%M %s %p\n'` - custom format: Mode, Size, Path

❌ DISTRACTORS:
- `-ls` - predefined format, not customisable
- `| awk '{print $1,$5,$NF}'` - unnecessary complication when we have -printf

---

## SECTION 2: PARSONS PROBLEMS FOR PARAMETERS AND GETOPTS

### PP-S01: Script with Argument Validation

```
═══════════════════════════════════════════════════════════════
🧩 PARSONS PROBLEM #S01: Argument Count Verification

📝 REQUIREMENT:
Write a script fragment that verifies whether it received 
exactly 2 arguments. If not, display error message and exit.

📦 SCRAMBLED LINES:
─────────────────────────────────────────────────────────────────
   #!/bin/bash
   if [ $# -ne 2 ]; then
       echo "Error: 2 arguments required"
       exit 1
   fi
   echo "OK: $1 and $2"
   if [ $# != 2 ]; then                                      ← ❌
   if [ $@ -ne 2 ]; then                                     ← ❌
─────────────────────────────────────────────────────────────────

⏱️ Estimated time: 3 minutes

═══════════════════════════════════════════════════════════════
```

✅ SOLUTION:
```bash
#!/bin/bash
if [ $# -ne 2 ]; then
    echo "Error: 2 arguments required"
    exit 1
fi
echo "OK: $1 and $2"
```

📖 EXPLANATION:
1. `#!/bin/bash` - mandatory shebang
2. `if [ $# -ne 2 ]; then` - $# = number of arguments
3. `-ne` = not equal (numeric)
4. `exit 1` - terminate with error code
5. `fi` - close if
6. `echo "OK: $1 and $2"` - use arguments

❌ DISTRACTORS:
- `if [ $# != 2 ]; then` - works, but != is for string
- `if [ $@ -ne 2 ]; then` - $@ is the argument list, not count

---

### PP-S02: Processing with Shift

```
═══════════════════════════════════════════════════════════════
🧩 PARSONS PROBLEM #S02: Process All Arguments

📝 REQUIREMENT:
Write a script that processes all arguments using 
shift, displaying each on separate line with ordinal number.

📦 SCRAMBLED LINES:
─────────────────────────────────────────────────────────────────
   #!/bin/bash
   count=1
   while [ $# -gt 0 ]; do
       echo "$count: $1"
       count=$((count + 1))
       shift
   done
   shift $#                                                  ← ❌
   for arg in $@; do                                         ← ❌
─────────────────────────────────────────────────────────────────

⏱️ Estimated time: 4 minutes

═══════════════════════════════════════════════════════════════
```

✅ SOLUTION:
```bash
#!/bin/bash
count=1
while [ $# -gt 0 ]; do
    echo "$count: $1"
    count=$((count + 1))
    shift
done
```

📖 EXPLANATION:
1. `count=1` - initialise counter
2. `while [ $# -gt 0 ]; do` - while arguments remain
3. `echo "$count: $1"` - display counter and first argument
4. `count=$((count + 1))` - increment
5. `shift` - remove first argument, $2 becomes $1
6. `done` - end of loop

❌ DISTRACTORS:
- `shift $#` - would delete all arguments at once
- `for arg in $@; do` - would work, but not the requested pattern with shift

---

### PP-S03: Script with Complete Getopts

```
═══════════════════════════════════════════════════════════════
🧩 PARSONS PROBLEM #S03: Professional Option Parsing

📝 REQUIREMENT:
Write the skeleton of a script that accepts:
-h (help), -v (verbose), -o FILE (output file)

📦 SCRAMBLED LINES:
─────────────────────────────────────────────────────────────────
   #!/bin/bash
   verbose=false
   output_file=""
   while getopts "hvo:" opt; do
       case $opt in
           h) echo "Usage: $0 [-h] [-v] [-o file]"; exit 0 ;;
           v) verbose=true ;;
           o) output_file="$OPTARG" ;;
           ?) exit 1 ;;
       esac
   done
   shift $((OPTIND - 1))
   getopts "hvo" opt                                         ← ❌
   shift $(OPTIND)                                           ← ❌
─────────────────────────────────────────────────────────────────

⏱️ Estimated time: 5 minutes

═══════════════════════════════════════════════════════════════
```

✅ SOLUTION:
```bash
#!/bin/bash
verbose=false
output_file=""
while getopts "hvo:" opt; do
    case $opt in
        h) echo "Usage: $0 [-h] [-v] [-o file]"; exit 0 ;;
        v) verbose=true ;;
        o) output_file="$OPTARG" ;;
        ?) exit 1 ;;
    esac
done
shift $((OPTIND - 1))
```

📖 EXPLANATION:
1. Initialise variables for options
2. `while getopts "hvo:" opt` - "o:" means -o takes argument
3. `case $opt in` - processing per option
4. `$OPTARG` - contains the option argument (for -o)
5. `?` - unknown option
6. `shift $((OPTIND - 1))` - remove processed options

❌ DISTRACTORS:
- `getopts "hvo" opt` - missing ":" after o (doesn't accept argument)
- `shift $(OPTIND)` - would delete one too many

---

### PP-S04: Default Values with Expansion

```
═══════════════════════════════════════════════════════════════
🧩 PARSONS PROBLEM #S04: Default Values

📝 REQUIREMENT:
Create variables with default values for: user (from env or "guest"),
output (third argument or "/tmp/output.txt"),
verbose (fourth argument or false).

📦 SCRAMBLED LINES:
─────────────────────────────────────────────────────────────────
   user="${USER:-guest}"
   output="${3:-/tmp/output.txt}"
   verbose="${4:-false}"
   user=${USER:=guest}                                       ← ❌
   output=$3 || "/tmp/output.txt"                            ← ❌
─────────────────────────────────────────────────────────────────

⏱️ Estimated time: 3 minutes

═══════════════════════════════════════════════════════════════
```

✅ SOLUTION:
```bash
user="${USER:-guest}"
output="${3:-/tmp/output.txt}"
verbose="${4:-false}"
```

📖 EXPLANATION:
1. `${VAR:-default}` - returns default if VAR is empty/unset
2. `${USER:-guest}` - takes $USER from env, or "guest"
3. `${3:-/tmp/output.txt}` - takes third argument or default
4. `${4:-false}` - same for fourth

❌ DISTRACTORS:
- `${USER:=guest}` - := ASSIGNS (modifies variable), doesn't just return
- `$3 || "/tmp/output.txt"` - invalid syntax in bash

---

## SECTION 3: PARSONS PROBLEMS FOR PERMISSIONS

### PP-P01: Correct Octal chmod

```
═══════════════════════════════════════════════════════════════
🧩 PARSONS PROBLEM #P01: Script Permission Setting

📝 REQUIREMENT:
Set permissions for a script such that:
- Owner: read, write, execute
- Group: read, execute
- Others: no permission

📦 SCRAMBLED LINES:
─────────────────────────────────────────────────────────────────
   chmod 750 script.sh
   chmod 777 script.sh                                       ← ❌
   chmod 755 script.sh                                       ← ❌
─────────────────────────────────────────────────────────────────

⏱️ Estimated time: 2 minutes

═══════════════════════════════════════════════════════════════
```

✅ SOLUTION:
```bash
chmod 750 script.sh
```

📖 EXPLANATION:
Octal calculation:
- Owner (7): r=4 + w=2 + x=1 = 7
- Group (5): r=4 + x=1 = 5
- Others (0): no permission = 0
- Total: 750

❌ DISTRACTORS:
- `chmod 777 script.sh` - gives permissions to everyone (DANGEROUS!)
- `chmod 755 script.sh` - would give others read+execute too

---

### PP-P02: Symbolic chmod for Security

```
═══════════════════════════════════════════════════════════════
🧩 PARSONS PROBLEM #P02: Directory Security

📝 REQUIREMENT:
Remove write permission for group and others from 
all files in a directory (recursive), but keep 
execute only for directories.

📦 SCRAMBLED LINES:
─────────────────────────────────────────────────────────────────
   chmod -R go-w project/
   find project/ -type f -exec chmod go-w {} +
   find project/ -type d -exec chmod go+X {} +               ← ❌
   chmod -R 644 project/                                     ← ❌
─────────────────────────────────────────────────────────────────

⏱️ Estimated time: 3 minutes

═══════════════════════════════════════════════════════════════
```

✅ SOLUTION:
```bash
chmod -R go-w project/
```

📖 EXPLANATION:
1. `-R` - recursive
2. `go-w` - group and others, minus write
3. This keeps other permissions intact

❌ DISTRACTORS:
- `find project/ -type d -exec chmod go+X {} +` - adds execute, not required
- `chmod -R 644 project/` - overwrites all permissions (problems with directories)

---

### PP-P03: Shared Directory Configuration

```
═══════════════════════════════════════════════════════════════
🧩 PARSONS PROBLEM #P03: Collaborative Directory

📝 REQUIREMENT:
Configure the "shared" directory such that:
1. Anyone from the group can create files
2. New files inherit the directory's group
3. Only the owner can delete their own files

📦 SCRAMBLED LINES:
─────────────────────────────────────────────────────────────────
   chmod g+s shared/
   chmod +t shared/
   chmod 3770 shared/
   chmod 777 shared/                                         ← ❌
   chmod u+s shared/                                         ← ❌
─────────────────────────────────────────────────────────────────

⏱️ Estimated time: 4 minutes

═══════════════════════════════════════════════════════════════
```

✅ SOLUTION (explicit variant):
```bash
chmod g+s shared/
chmod +t shared/
```

OR (octal variant, single command):
```bash
chmod 3770 shared/
```

📖 EXPLANATION:
1. `chmod g+s shared/` - SGID: new files inherit group
2. `chmod +t shared/` - Sticky bit: only owner deletes
3. `chmod 3770` - 3 = SGID(2) + Sticky(1), 770 = rwxrwx---

❌ DISTRACTORS:
- `chmod 777 shared/` - permissions for all, without special bits
- `chmod u+s shared/` - SUID (run as owner), not SGID

---

### PP-P04: umask for Security

```
═══════════════════════════════════════════════════════════════
🧩 PARSONS PROBLEM #P04: Restrictive Umask

📝 REQUIREMENT:
Set umask such that new files have 600 (rw------) 
and directories have 700 (rwx------).

📦 SCRAMBLED LINES:
─────────────────────────────────────────────────────────────────
   umask 077
   umask 077                                                 ← ✅
   umask 0077                                                ← ✅ (equivalent)
   umask 177                                                 ← ❌
   umask 600                                                 ← ❌
─────────────────────────────────────────────────────────────────

⏱️ Estimated time: 3 minutes

═══════════════════════════════════════════════════════════════
```

✅ SOLUTION:
```bash
umask 077
# or
umask 0077
```

📖 EXPLANATION:
umask REMOVES permissions from default (666 for files, 777 for directories):
- Files: 666 - 077 = 600 (rw-------)
- Directories: 777 - 077 = 700 (rwx------)

❌ DISTRACTORS:
- `umask 177` - would result in 500 for directories (r-x------)
- `umask 600` - would result in 066/077, not what we want

---

## SECTION 4: PARSONS PROBLEMS FOR CRON

### PP-C01: Simple Cron Job

```
═══════════════════════════════════════════════════════════════
🧩 PARSONS PROBLEM #C01: Daily Backup

📝 REQUIREMENT:
Create a cron job that runs a backup script 
at 3:00 AM every day.

📦 SCRAMBLED LINES:
─────────────────────────────────────────────────────────────────
   0 3 * * * /home/user/scripts/backup.sh
   3 0 * * * /home/user/scripts/backup.sh                    ← ❌
   * 3 * * * /home/user/scripts/backup.sh                    ← ❌
─────────────────────────────────────────────────────────────────

⏱️ Estimated time: 2 minutes

═══════════════════════════════════════════════════════════════
```

✅ SOLUTION:
```cron
0 3 * * * /home/user/scripts/backup.sh
```

📖 EXPLANATION:
Format: `min hour day month dow command`
- `0` - minute 0
- `3` - hour 3
- `* * *` - any day, any month, any day of week
- Result: runs at 03:00 every day

❌ DISTRACTORS:
- `3 0 * * *` - would run at 00:03 (3 minutes after midnight)
- `* 3 * * *` - would run every minute between 3:00 and 3:59

---

### PP-C02: Cron with Interval

```
═══════════════════════════════════════════════════════════════
🧩 PARSONS PROBLEM #C02: Repeated Monitoring

📝 REQUIREMENT:
Create a cron job that runs every 15 minutes, 
only on working days (Monday-Friday), between 9:00-17:00.

📦 SCRAMBLED LINES:
─────────────────────────────────────────────────────────────────
   */15 9-17 * * 1-5 /usr/local/bin/monitor.sh
   0,15,30,45 9-17 * * 1-5 /usr/local/bin/monitor.sh         ← ✅
   15 9-17 * * 1-5 /usr/local/bin/monitor.sh                 ← ❌
   */15 9-17 * * Mon-Fri /usr/local/bin/monitor.sh           ← ❌
─────────────────────────────────────────────────────────────────

⏱️ Estimated time: 4 minutes

═══════════════════════════════════════════════════════════════
```

✅ SOLUTIONS (equivalent):
```cron
*/15 9-17 * * 1-5 /usr/local/bin/monitor.sh
# OR
0,15,30,45 9-17 * * 1-5 /usr/local/bin/monitor.sh
```

📖 EXPLANATION:
- `*/15` - every 15 minutes (0, 15, 30, 45)
- `9-17` - between hours 9 and 17 (inclusive)
- `* *` - any day of month, any month
- `1-5` - days 1-5 (Monday-Friday)

❌ DISTRACTORS:
- `15 9-17 * * 1-5` - would run only at minute 15 (not every 15 min)
- `Mon-Fri` - not standard numeric format (some crons accept it, others don't)

---

### PP-C03: Cron Job with Logging

```
═══════════════════════════════════════════════════════════════
🧩 PARSONS PROBLEM #C03: Job with Redirection

📝 REQUIREMENT:
Create a cron job that:
- Runs a cleanup script at 2 AM on Sunday
- Saves output (stdout AND stderr) to /var/log/cleanup.log
- Appends to log, does not overwrite

📦 SCRAMBLED LINES:
─────────────────────────────────────────────────────────────────
   0 2 * * 0 /opt/scripts/cleanup.sh >> /var/log/cleanup.log 2>&1
   0 2 * * 7 /opt/scripts/cleanup.sh >> /var/log/cleanup.log 2>&1   ← ✅
   0 2 * * 0 /opt/scripts/cleanup.sh > /var/log/cleanup.log        ← ❌
   0 2 * * sun /opt/scripts/cleanup.sh &>> /var/log/cleanup.log    ← ❌
─────────────────────────────────────────────────────────────────

⏱️ Estimated time: 4 minutes

═══════════════════════════════════════════════════════════════
```

✅ SOLUTIONS (equivalent):
```cron
0 2 * * 0 /opt/scripts/cleanup.sh >> /var/log/cleanup.log 2>&1
# OR
0 2 * * 7 /opt/scripts/cleanup.sh >> /var/log/cleanup.log 2>&1
```

📖 EXPLANATION:
- `0 2` - at 2:00 AM
- `* * 0` or `* * 7` - Sunday (0 and 7 are both Sunday)
- `>>` - append to file
- `2>&1` - redirect stderr to stdout

❌ DISTRACTORS:
- `>` - overwrites file (not append)
- `sun` - not standard numeric format
- `&>>` - works in modern bash, but cron uses /bin/sh

---

### PP-C04: Cron with Environment and Lock

```
═══════════════════════════════════════════════════════════════
🧩 PARSONS PROBLEM #C04: Solid Job

📝 REQUIREMENT:
Build a cron job that runs every hour on the hour,
sets PATH explicitly, and prevents overlapping executions.

📦 SCRAMBLED LINES (order in crontab):
─────────────────────────────────────────────────────────────────
   PATH=/usr/local/bin:/usr/bin:/bin
   SHELL=/bin/bash
   0 * * * * flock -n /tmp/job.lock /home/user/hourly.sh
   0 * * * * /home/user/hourly.sh                            ← ❌
   * * * * * flock -n /tmp/job.lock /home/user/hourly.sh     ← ❌
─────────────────────────────────────────────────────────────────

⏱️ Estimated time: 5 minutes

═══════════════════════════════════════════════════════════════
```

✅ SOLUTION:
```cron
PATH=/usr/local/bin:/usr/bin:/bin
SHELL=/bin/bash
0 * * * * flock -n /tmp/job.lock /home/user/hourly.sh
```

📖 EXPLANATION:
1. `PATH=...` - explicitly sets paths (cron has minimal PATH)
2. `SHELL=/bin/bash` - forces bash instead of sh
3. `0 * * * *` - at minute 0 of every hour
4. `flock -n` - non-blocking lock (if lock exists, doesn't run)

❌ DISTRACTORS:
- Without `flock` - risk of overlapping executions
- `* * * * *` - would run every minute

---

## SECTION 5: INTEGRATED PROBLEMS

### PP-I01: Complete Find → Processing Pipeline

```
═══════════════════════════════════════════════════════════════
🧩 PARSONS PROBLEM #I01: Large Files Report

📝 REQUIREMENT:
Find all files larger than 100MB in /var, 
display them sorted by size (descending),
and save the first 10 to a file report.txt.

📦 SCRAMBLED LINES:
─────────────────────────────────────────────────────────────────
   find /var -type f -size +100M
   -printf '%s %p\n'
   | sort -rn
   | head -10
   > report.txt
   2>/dev/null
   | sort -k1 -rn                                            ← ❌
   -exec ls -la {} \;                                        ← ❌
─────────────────────────────────────────────────────────────────

⏱️ Estimated time: 5 minutes

═══════════════════════════════════════════════════════════════
```

✅ SOLUTION:
```bash
find /var -type f -size +100M -printf '%s %p\n' 2>/dev/null | sort -rn | head -10 > report.txt
```

📖 EXPLANATION:
1. `find /var -type f -size +100M` - find files >100MB
2. `-printf '%s %p\n'` - display: size space path
3. `2>/dev/null` - suppress errors (permission denied)
4. `| sort -rn` - sort numeric descending
5. `| head -10` - first 10
6. `> report.txt` - save to file

❌ DISTRACTORS:
- `| sort -k1 -rn` - -k1 is redundant when first column is already sorted
- `-exec ls -la {} \;` - inconsistent output, cannot be easily sorted

---

### PP-I02: Complete Administration Script

```
═══════════════════════════════════════════════════════════════
🧩 PARSONS PROBLEM #I02: Admin Script

📝 REQUIREMENT:
Write the structure of a script that:
1. Verifies if running as root
2. Accepts -d option for dry-run
3. Cleans .tmp files older than 7 days
4. Logs actions

📦 SCRAMBLED LINES:
─────────────────────────────────────────────────────────────────
   #!/bin/bash
   
   # Root verification
   if [ "$(id -u)" -ne 0 ]; then
       echo "Requires root"; exit 1
   fi
   
   # Option parsing
   dry_run=false
   while getopts "d" opt; do
       case $opt in
           d) dry_run=true ;;
       esac
   done
   
   # Action
   if [ "$dry_run" = true ]; then
       find /tmp -name "*.tmp" -mtime +7 -print
   else
       find /tmp -name "*.tmp" -mtime +7 -delete
   fi | tee -a /var/log/cleanup.log
   
   if [ "$USER" != "root" ]; then                            ← ❌
   find /tmp -name "*.tmp" -mtime -7 -delete                 ← ❌
─────────────────────────────────────────────────────────────────

⏱️ Estimated time: 6 minutes

═══════════════════════════════════════════════════════════════
```

✅ SOLUTION:
```bash
#!/bin/bash

# Root verification
if [ "$(id -u)" -ne 0 ]; then
    echo "Requires root"; exit 1
fi

# Option parsing
dry_run=false
while getopts "d" opt; do
    case $opt in
        d) dry_run=true ;;
    esac
done

# Action
if [ "$dry_run" = true ]; then
    find /tmp -name "*.tmp" -mtime +7 -print
else
    find /tmp -name "*.tmp" -mtime +7 -delete
fi | tee -a /var/log/cleanup.log
```

❌ DISTRACTORS:
- `if [ "$USER" != "root" ]` - $USER variable can be modified
- `-mtime -7` - would delete files NEWER than 7 days (opposite!)

---

## SUMMARY AND TIPS

### Common Mistakes to Avoid

| Category | Mistake | Correct |
|----------|---------|---------|
| find | `-name *.txt` (without quotes) | `-name "*.txt"` |
| find | `-exec rm {} +` (dangerous) | `-ok rm {} \;` (with confirmation) |
| xargs | Without -0 for spaces | `-print0 \| xargs -0` |
| getopts | `"o"` when option needs arg | `"o:"` (with :) |
| shift | `shift $(OPTIND)` | `shift $((OPTIND - 1))` |
| chmod | `chmod 777` as solution | Calculate necessary permissions |
| umask | Confusion with chmod | umask REMOVES, doesn't set |
| cron | `3 0 * * *` for 3 AM | `0 3 * * *` |
| cron | Without absolute paths | Use `PATH=` or complete paths |

### Tips for Solving

1. Read the requirement twice - identify keywords
2. Identify distractors - look for wrong syntax or incomplete alternatives
3. Check order - in compound commands, order matters
4. Test mentally - trace through each step
5. Look for patterns - classic combinations (find+xargs, chmod+chown)

---

## APPENDIX: QUICK SOLUTIONS

| Problem | Solution |
|---------|----------|
| PP-F01 | `find /var/log -maxdepth 3 -type f -name "*.log" -size +100k -mtime -7` |
| PP-F02 | `find . -type f \( -name "*.sh" -o -name "*.py" \) ! -path "./build/*"` |
| PP-F03 | `find /tmp -type f -name "*.tmp" -mtime +30 -ok rm {} \;` |
| PP-F04 | `find src/ -type f -name "*.c" -print0 \| xargs -0 wc -l` |
| PP-F05 | `find /etc -maxdepth 1 -type f -name "*.conf" -printf '%M %s %p\n'` |
| PP-S01 | if + $# -ne 2 + exit 1 |
| PP-S02 | while + $# -gt 0 + shift |
| PP-S03 | getopts "hvo:" + case + OPTIND |
| PP-S04 | ${VAR:-default} pattern |
| PP-P01 | `chmod 750` |
| PP-P02 | `chmod -R go-w` |
| PP-P03 | `chmod 3770` or `g+s` + `+t` |
| PP-P04 | `umask 077` |
| PP-C01 | `0 3 * * *` |
| PP-C02 | `*/15 9-17 * * 1-5` |
| PP-C03 | `0 2 * * 0 ... >> log 2>&1` |
| PP-C04 | PATH + flock + `0 * * * *` |

---

*Document generated for UES Bucharest - CSIE | Operating Systems | Seminar 3*
