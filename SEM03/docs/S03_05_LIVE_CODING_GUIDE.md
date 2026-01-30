# Live Coding Guide - Seminar 03
## Operating Systems | Interactive Programming Sessions

**Purpose**: Detailed script for all live coding sessions in the seminar
Method: Announce → Predict → Execute → Explain
**Principle**: "Never type code the audience doesn't understand"

---

## DOCUMENT STRUCTURE

| Session | Subject | Duration | Location in seminar |
|---------|---------|----------|---------------------|
| LC-01 | find from simple to complex | 15 min | First part [0:10-0:25] |
| LC-02 | xargs and advanced patterns | 8 min | First part [0:25-0:33] |
| LC-03 | Parameters and getopts | 12 min | Break or First part |
| LC-04 | Permissions step by step | 12 min | Second part [0:05-0:17] |
| LC-05 | Demo cron and automation | 5 min | Second part [0:40-0:45] |

---

## COMMON PREPARATION

### Working Directory Setup

```bash
#!/bin/bash
# Run before the seminar!

# Create structure
mkdir -p ~/live_demo/{project,temp,backup,logs,src,config}
cd ~/live_demo

# Populate with test files
touch project/{main.c,utils.c,config.h,README.md}
touch project/{app.py,test_app.py,requirements.txt}
touch temp/{cache_001.tmp,cache_002.tmp,old_backup.bak}
touch logs/{app.log,error.log,debug.log,access.log}
touch src/{module1.sh,module2.sh,helpers.bash}
touch config/{prod.conf,dev.conf,test.conf}

# Files with spaces (for demonstrations)
touch "project/my document.txt"
touch "project/special file (backup).txt"

# Files of different sizes
dd if=/dev/zero of=logs/large.log bs=1M count=5 2>/dev/null
dd if=/dev/zero of=temp/huge.tmp bs=1M count=10 2>/dev/null

# Files with different timestamps
touch -d "2 days ago" temp/recent.tmp
touch -d "15 days ago" temp/old.tmp
touch -d "60 days ago" temp/ancient.tmp

# Executable and non-executable scripts
echo '#!/bin/bash' > src/runnable.sh

*Personal note: Bash has ugly syntax, I admit. But it runs everywhere, and that matters enormously in practice.*

echo 'echo "Hello"' >> src/runnable.sh
chmod +x src/runnable.sh

*(Permissions seem complicated at first, but the rule is simple: think about who needs what access.)*


echo '#!/bin/bash' > src/not_exec.sh
echo 'echo "World"' >> src/not_exec.sh
# Intentionally without chmod +x

echo "✅ Setup complete!"
ls -laR ~/live_demo
```

### Pre-Session Checks

```bash
# Verify everything is ok
[ -d ~/live_demo ] && echo "✅ Directory exists"
[ -f ~/live_demo/project/main.c ] && echo "✅ Test files exist"
[ -f ~/live_demo/logs/large.log ] && echo "✅ Large files exist"
which find xargs locate && echo "✅ Commands available"
```

---

## LC-01: FIND FROM SIMPLE TO COMPLEX (15 min)

### Session Objectives

At the end, students will be able to:
- Understand the structure of the `find` command
- Combine search criteria
- Identify the difference between tests and actions


### Instructor Mental Preparation
> "Find is the most powerful search tool in Unix. I will demonstrate
> progressively, from simple to complex. At each step, I will ask 
> the audience what they think the command will do BEFORE running it."

---

### SEGMENT 1: Basic find structure (3 minutes)

#### [ANNOUNCE]
```
📢 "We will start with the basic structure of the find command.
    Find has three components: WHERE we search, WHAT we search for, WHAT WE DO."
```

#### [CODE + PREDICTION]
```bash
cd ~/live_demo

# PREDICTION: "What do you think this command will display?"
find .
# [pause for answers]
```

#### [EXECUTION]
```bash
find .
# Output: lists EVERYTHING recursively
```

#### [EXPLANATION]
```
📖 "Find without criteria displays EVERYTHING from the starting point.
    It is equivalent to 'ls -R' but in complete path format.
    Notice: it displays both directories and files."
```

#### [CODE + PREDICTION]
```bash
# PREDICTION: "But what if I specify a directory?"
find ./project
```

#### [EXECUTION + EXPLANATION]
```bash
find ./project
# Output: only what is in project/

📖 "The first argument is the starting point. 
    It can be: . (current), / (root), ~ (home), or any path."
```

---

### SEGMENT 2: Basic tests - name and type (4 minutes)

#### [ANNOUNCE]
```
📢 "Now we add search CRITERIA. The most common: -name and -type."
```

#### [CODE + PREDICTION]
```bash
# PREDICTION: "What will this command find?"
find . -name "*.c"
# [pause]
```

#### [EXECUTION]
```bash
find . -name "*.c"
# Output: ./project/main.c, ./project/utils.c
```

#### [EXPLANATION]
```
📖 "-name uses patterns (glob).
    Remember: Quotes are MANDATORY for *.c
    Without quotes, the shell expands BEFORE find!"
```

#### [DELIBERATE ERROR DEMONSTRATION]
```bash
# DELIBERATE ERROR - without quotes
touch test.c  # create a .c in current directory
find . -name *.c
# May give errors or unexpected results!

# CORRECT:
find . -name "*.c"
rm test.c  # cleanup
```

#### [CODE + PREDICTION]
```bash
# PREDICTION: "What does -type d do?"
find . -type d
```

#### [EXECUTION + EXPLANATION]
```bash
find . -type d
# Output: only directories

📖 "Common types:
    -type f = files
    -type d = directories
    -type l = symbolic links"
```

#### [COMBINED CODE]
```bash
# PREDICTION: "The combination?"
find . -type f -name "*.log"
# Output: only .log files
```

---

### SEGMENT 3: Advanced tests - size and time (4 minutes)

#### [ANNOUNCE]
```
📢 "Find can also search by size or timestamp. 
    This is where it becomes truly powerful for administration."

> 💡 Many students initially underestimate the importance of permissions. Then they encounter their first 'Permission denied' and everything becomes clear.

```

#### [CODE + PREDICTION]
```bash
# PREDICTION: "What does +1M mean?"
find . -type f -size +1M
```

#### [EXECUTION + EXPLANATION]
```bash
find . -type f -size +1M
# Output: logs/large.log, temp/huge.tmp (those created with dd)

📖 "Syntax for size:
    +N = larger than N
    -N = smaller than N
    N  = exactly N
    
    Suffixes: c=bytes, k=KB, M=MB, G=GB"
```

#### [CODE + PREDICTION]
```bash
# PREDICTION: "What does -mtime -7 mean?"
find . -type f -mtime -7
```

#### [EXECUTION + EXPLANATION]
```bash
find . -type f -mtime -7
# Output: files modified in the last 7 days

📖 "Time in find:
    -mtime = modification time (content)
    -atime = access time (read)
    -ctime = change time (metadata)
    
    -N = less than N days
    +N = more than N days
    N  = exactly N days"
```

#### [DEMO CODE]
```bash
# Files modified in the last 30 minutes
find . -type f -mmin -30

# Files OLDER than 10 days
find . -type f -mtime +10
```

---

### SEGMENT 4: Logical operators (4 minutes)

#### [ANNOUNCE]
```
📢 "Until now, criteria combine with implicit AND.
    But we can also do OR or NOT."
```

#### [CODE + PREDICTION]
```bash
# PREDICTION: "This finds what?"
find . -type f -name "*.c" -size +0
# [implicit AND between all]
```

#### [EXECUTION + EXPLANATION]
```bash
📖 "When you put multiple tests, find combines them with AND.
    The file must satisfy ALL conditions."

> 💡 Over the years, I have found that practical examples beat theory every time.

```

#### [CODE + PREDICTION - OR]
```bash
# PREDICTION: "How do I find .c OR .py?"
find . -type f \( -name "*.c" -o -name "*.py" \)
```

#### [EXECUTION + EXPLANATION]
```bash
find . -type f \( -name "*.c" -o -name "*.py" \)
# Output: all .c and .py

📖 "For OR:
    -o = OR
    \( \) = grouping (escaped for shell)
    WITHOUT grouping, precedence is confusing!"
```

#### [ERROR DEMONSTRATION]
```bash
# ERROR: without grouping
find . -type f -name "*.c" -o -name "*.py"
# WRONG result! OR applies only between names,
# but -type f applies only to the first -name

# CORRECT:
find . -type f \( -name "*.c" -o -name "*.py" \)
```

#### [CODE + PREDICTION - NOT]
```bash
# PREDICTION: "How do I EXCLUDE .tmp?"
find . -type f ! -name "*.tmp"
```

#### [EXECUTION + EXPLANATION]
```bash
find . -type f ! -name "*.tmp"
# Output: all files EXCEPT .tmp

📖 "NOT:
    ! = negation
    -not = alternative (more explicit)
    Placement: BEFORE the negated test"
```

---

## LC-02: XARGS AND ADVANCED PATTERNS (8 min)

### Session Objectives

Three things matter here: students understand why xargs exists, students can use xargs with find safely, and students recognise the problem of spaces in names.


---

### SEGMENT 1: Why xargs? (2 minutes)

#### [ANNOUNCE]
```
📢 "Xargs solves a fundamental problem: how do we pass
    the output of one command to another as ARGUMENTS."
```

#### [CODE + PREDICTION]
```bash
# PREDICTION: "The difference between these?"
find . -name "*.log" -exec wc -l {} \;
find . -name "*.log" | xargs wc -l
```

#### [EXECUTION]
```bash
find . -name "*.log" -exec wc -l {} \;
# Output: wc runs separately for EACH file
# 10 ./logs/app.log
# 5 ./logs/error.log
# ...

find . -name "*.log" | xargs wc -l
# Output: wc runs ONCE with all files
# 10 ./logs/app.log
# 5 ./logs/error.log
# 15 total
```

#### [EXPLANATION]
```
📖 "Differences:
    -exec {} \; = runs command for EACH file (slow)
    | xargs     = collects and runs ONCE (fast)
    
    For 1000 files:
    -exec {} \; = 1000 processes
    | xargs     = 1-10 processes"
```

---

### SEGMENT 2: The spaces problem (3 minutes)

#### [ANNOUNCE]
```
📢 "But xargs has a critical vulnerability. 
    I demonstrate the ERROR everyone makes."
```

#### [ERROR DEMONSTRATION]
```bash
# We have files with spaces:
ls -la project/

# ERROR: simple xargs
find . -name "*.txt" | xargs ls -l
# ERROR! "my" and "document.txt" are treated separately!
```

#### [EXPLANATION]
```
📖 "Xargs implicitly splits input on:

The main aspects: spaces, tabs and newlines.

```

#### [THE SOLUTION]
```bash
# THE SOLUTION: -print0 and -0
find . -name "*.txt" -print0 | xargs -0 ls -l
# CORRECT! Null byte as separator
```

#### [EXPLANATION]
```
📖 "-print0 = find sends names separated with \0 (null)
    -0      = xargs reads null-delimited input
    
    GOLDEN RULE: Always -print0 | xargs -0"
```

---

### SEGMENT 3: Advanced xargs (3 minutes)

#### [CODE + PREDICTION]
```bash
# PREDICTION: "What does -I{} do?"
find . -name "*.c" | xargs -I{} echo "Processing: {}"
```

#### [EXECUTION + EXPLANATION]
```bash
find . -name "*.c" | xargs -I{} echo "Processing: {}"
# Output:
# Processing: ./project/main.c
# Processing: ./project/utils.c

📖 "-I{} replaces {} with the input.
    Useful when the command needs argument in the middle:
    xargs -I{} cp {} backup/
    xargs -I{} mv {} {}.bak"
```

#### [CODE + PREDICTION]
```bash
# PREDICTION: "What does -n 2 do?"
echo "a b c d e f" | xargs -n 2 echo
```

#### [EXECUTION + EXPLANATION]
```bash
echo "a b c d e f" | xargs -n 2 echo
# Output:
# a b
# c d
# e f

📖 "-n N = process maximum N arguments per command
    Useful for commands with argument limits."
```

#### [DEMO CODE - Parallel]
```bash
# Parallel processing (BONUS)
find . -name "*.log" -print0 | xargs -0 -P 4 gzip
# -P 4 = 4 processes in parallel
```

---

## LC-03: PARAMETERS AND GETOPTS (12 min)

### Session Objectives

At the end, students will be able to:
- Understand `$1`, `$@`, `$#`, `shift`
- Write scripts with `getopts`
- Differentiate `$@` from `$*`


---

### SEGMENT 1: Positional parameters (3 minutes)

#### [CREATE SCRIPT]
```bash
# Create a test script
nano ~/live_demo/params.sh
```

#### [CODE]
```bash
#!/bin/bash
echo "Script: $0"
echo "First argument: $1"
echo "Second argument: $2"
echo "Total number: $#"
echo "All arguments: $@"
```

#### [EXECUTION]
```bash
chmod +x ~/live_demo/params.sh
./params.sh hello world test
# Output:
# Script: ./params.sh
# First argument: hello
# Second argument: world
# Total number: 3
# All arguments: hello world test
```

#### [EXPLANATION]
```
📖 "Special variables:
    $0 = script name
    $1-$9 = arguments 1-9
    ${10}, ${11}... = arguments >= 10 (WITH BRACES!)
    $# = number of arguments
    $@ = all arguments"
```

---

### SEGMENT 2: $@ vs $* - the critical difference (4 minutes)

#### [ANNOUNCE]
```
📢 "This is one of the most common mistakes.
    $@ and $* seem identical, but they are NOT!"
```

#### [CREATE SCRIPT]
```bash
nano ~/live_demo/at_vs_star.sh
```

#### [CODE]
```bash
#!/bin/bash
echo "=== With \"\$@\" ==="
for arg in "$@"; do
    echo "Argument: [$arg]"
done

echo ""
echo "=== With \"\$*\" ==="
for arg in "$*"; do
    echo "Argument: [$arg]"
done
```

#### [EXECUTION]
```bash
chmod +x ~/live_demo/at_vs_star.sh
./at_vs_star.sh "hello world" test "one two"
```

#### [EXPECTED OUTPUT]
```
=== With "$@" ===
Argument: [hello world]
Argument: [test]
Argument: [one two]

=== With "$*" ===
Argument: [hello world test one two]
```

#### [EXPLANATION]
```
📖 "THE CRITICAL DIFFERENCE:
    \"$@\" = preserves each argument separately
    \"$*\" = combines everything into a single string
    
    RULE: ALWAYS use \"$@\" for iteration!"
```

---

### SEGMENT 3: shift (2 minutes)

#### [CREATE SCRIPT]
```bash
nano ~/live_demo/shift_demo.sh
```

#### [CODE]
```bash
#!/bin/bash
echo "Initial: $@"

while [ $# -gt 0 ]; do
    echo "Processing: $1"
    shift
    echo "  Remaining: $@"
done
```

#### [EXECUTION]
```bash
chmod +x ~/live_demo/shift_demo.sh
./shift_demo.sh a b c d
```

#### [EXPLANATION]
```
📖 "shift removes the first argument.
    $2 becomes $1, $3 becomes $2, etc.
    $# decrements.
    
    Common pattern for sequential processing."
```

---

### SEGMENT 4: getopts (3 minutes)

#### [CREATE SCRIPT]
```bash
nano ~/live_demo/getopts_demo.sh
```

#### [CODE]
```bash
#!/bin/bash

# Default values
verbose=false
output_file=""
count=1

# Option parsing
while getopts "hvo:n:" opt; do
    case $opt in
        h)
            echo "Usage: $0 [-h] [-v] [-o file] [-n count] args..."
            exit 0
            ;;
        v)
            verbose=true
            ;;
        o)
            output_file="$OPTARG"
            ;;
        n)
            count="$OPTARG"
            ;;
        ?)
            echo "Invalid option: -$OPTARG"
            exit 1
            ;;
    esac
done

# Remove processed options
shift $((OPTIND - 1))

# Display what we received
echo "verbose: $verbose"
echo "output: $output_file"
echo "count: $count"
echo "remaining arguments: $@"
```

#### [EXECUTION]
```bash
chmod +x ~/live_demo/getopts_demo.sh

# Test without options
./getopts_demo.sh arg1 arg2

# Test with options
./getopts_demo.sh -v -o test.txt -n 5 arg1 arg2

# Test with help
./getopts_demo.sh -h
```

#### [EXPLANATION]
```
📖 "Anatomy of getopts:
    \"hvo:n:\" = optstring
    h, v    = options without argument
    o:, n:  = options WITH argument (: after letter)
    
    OPTARG = argument of current option
    OPTIND = index of next argument to process
    
    shift $((OPTIND - 1)) = remove processed options"
```

---

## LC-04: PERMISSIONS STEP BY STEP (12 min)

### Session Objectives

At the end, students will be able to:
- Read and interpret permissions
- Use `chmod` in both modes (numeric and symbolic)
- Understand `umask` and special permissions


---

### SEGMENT 1: Reading permissions (2 minutes)

#### [ANNOUNCE]
```
📢 "Before we change permissions, we must read them correctly."
```

#### [CODE + PREDICTION]
```bash
ls -l project/
# PREDICTION: "What does each character mean?"
```

#### [EXPLANATION WITH DIAGRAM]
```
📖 "Anatomy: -rwxr-xr--
    
    Position 0:    -  = file (d=directory, l=link)
    Positions 1-3: rwx = owner: read, write, execute
    Positions 4-6: r-x = group: read, -, execute
    Positions 7-9: r-- = others: read, -, -
    
    - (dash) = permission is NOT granted"
```

#### [DEMO CODE]
```bash
ls -ld project/   # Directory
ls -l project/main.c  # File
ls -l /usr/bin/passwd  # File with SUID
```

---

### SEGMENT 2: octal chmod (3 minutes)

#### [ANNOUNCE]
```
📢 "Octal mode is the fastest. 
    Three digits: owner, group, others."
```

#### [EXPLANATION]
```
📖 "Octal calculation:
    r = 4
    w = 2
    x = 1
    
    Examples:
    7 = r+w+x = 4+2+1
    6 = r+w   = 4+2
    5 = r+x   = 4+1
    4 = r     = 4
    0 = nothing"
```

#### [CODE + PREDICTION]
```bash
# PREDICTION: "What permissions does 755 set?"
chmod 755 project/main.c
ls -l project/main.c
```

#### [EXECUTION + VERIFICATION]
```bash
chmod 755 project/main.c
ls -l project/main.c
# -rwxr-xr-x = owner: all, group: r+x, others: r+x
```

#### [QUICK EXERCISE]
```bash
# "What does 644 set?"
chmod 644 project/config.h
ls -l project/config.h
# -rw-r--r-- = owner: r+w, group: r, others: r

# "What does 600 set?"
touch project/secret.txt
chmod 600 project/secret.txt
ls -l project/secret.txt
# -rw------- = only owner can read and write
```

---

### SEGMENT 3: symbolic chmod (3 minutes)

#### [ANNOUNCE]
```
📢 "Symbolic mode is more explicit and safer for partial modifications."
```

#### [EXPLANATION]
```
📖 "Symbolic syntax:
    WHO: u (user/owner), g (group), o (others), a (all)
    OP:  + (add), - (remove), = (set exactly)
    WHAT: r, w, x"
```

#### [CODE + PREDICTION]
```bash
# PREDICTION: "What does u+x do?"
chmod u+x project/README.md
ls -l project/README.md
```

#### [DEMO CODE]
```bash
# Add execute for owner
chmod u+x project/README.md

# Remove write for group and others
chmod go-w project/README.md

# Set exactly for group
chmod g=rx project/README.md

# Everything at once
chmod u=rwx,g=rx,o=r project/README.md
```

#### [SPECIAL CODE - X]
```bash
# PREDICTION: "What does X (capital) do?"
chmod -R a+X project/
```

#### [EXPLANATION]
```
📖 "X (capital) = execute ONLY for:
    - Directories (always)
    - Files that ALREADY HAVE execute
    
    Perfect for: chmod -R u=rwX,g=rX,o=rX directory/"
```

---

### SEGMENT 4: umask (2 minutes)

#### [ANNOUNCE]
```
📢 "Umask controls the DEFAULT permissions for new files.
    Trap: umask REMOVES bits, it doesn't set them!"
```

#### [CODE + PREDICTION]
```bash
# What is the current umask?
umask
# Probably 022

# PREDICTION: "What permissions will a new file have?"
touch test_umask.txt
ls -l test_umask.txt
```

#### [EXPLANATION]
```
📖 "The calculation:
    Default file:  666 (rw-rw-rw-)
    umask:        -022
    Result:        644 (rw-r--r--)
    
    Default directory: 777 (rwxrwxrwx)
    umask:            -022
    Result:            755 (rwxr-xr-x)"
```

#### [DEMO CODE]
```bash
# Change umask
umask 077

# Create file and directory
touch private.txt
mkdir private_dir

ls -l private.txt      # -rw-------
ls -ld private_dir     # drwx------

# Restore
umask 022
```

---

### SEGMENT 5: Special permissions (2 minutes)

#### [ANNOUNCE]
```
📢 "There are three special bits: SUID, SGID, Sticky.
    These are placed in front of the three digits."
```

#### [EXPLANATION + DEMO]
```bash
# SUID (4) - run as owner
ls -l /usr/bin/passwd
# -rwsr-xr-x (s in owner-execute position)

# SGID (2) on directory - group inheritance
mkdir shared_project
chmod g+s shared_project
ls -ld shared_project
# drwxr-sr-x (s in group-execute position)

# Sticky (1) - only owner deletes
ls -ld /tmp
# drwxrwxrwt (t in others-execute position)
```

#### [DEMO CODE]
```bash
# Combined setting: SGID + Sticky
mkdir team_dir
chmod 3770 team_dir
# 3 = SGID(2) + Sticky(1)
# 770 = owner and group: rwx, others: nothing
ls -ld team_dir
# drwxrws--T (s for SGID, T for sticky but without x)
```

---

## LC-05: DEMO CRON AND AUTOMATION (5 min)

### Session Objectives

The main aspects: students understand crontab format, students can create simple jobs and students know best practices.


---

### SEGMENT 1: The crontab format (2 minutes)

#### [ANNOUNCE]
```
📢 "Cron uses 5 time fields. 
    I will demonstrate a live job."
```

#### [EXPLANATION]
```
📖 "The format:
    * * * * * command
    │ │ │ │ │
    │ │ │ │ └── day of week (0-7, 0 and 7 = Sunday)
    │ │ │ └──── month (1-12)
    │ │ └────── day of month (1-31)
    │ └──────── hour (0-23)
    └────────── minute (0-59)"
```

#### [DEMO CODE]
```bash
# Display current crontab
crontab -l

# Expression examples:
echo "0 3 * * *     # 3:00 AM daily"
echo "*/15 * * * *  # every 15 minutes"
echo "0 9-17 * * 1-5 # every hour, 9-17, Monday-Friday"
echo "0 0 1 * *     # first day of month, midnight"
```

---

### SEGMENT 2: Live job creation (2 minutes)

#### [DEMO CODE]
```bash
# Create a simple script
cat > ~/test_cron.sh << 'EOF'
#!/bin/bash
echo "$(date): Cron test" >> /tmp/cron_test.log
EOF
chmod +x ~/test_cron.sh

# Add to crontab (runs every minute)
(crontab -l 2>/dev/null; echo "* * * * * $HOME/test_cron.sh") | crontab -

# Verify
crontab -l
```

#### [MONITORING]
```bash
# Wait a minute and verify
tail -f /tmp/cron_test.log
# [wait for output to appear]
```

---

### SEGMENT 3: Cleanup and best practices (1 minute)

#### [DEMO CODE]
```bash
# Remove the test job
crontab -l | grep -v "test_cron.sh" | crontab -
crontab -l

# OR to empty completely (CAUTION!)
# crontab -r # DELETES EVERYTHING!
```

#### [TIPS]
```
📖 "Cron best practices:
    1. Use ABSOLUTE paths
    2. Set PATH in crontab
    3. Redirect output: >> log 2>&1
    4. Test the script BEFORE putting it in cron
    5. Use flock to prevent overlaps"
```

---

## LIVE CODING SUMMARY

### Deliberate Errors Included

| Session | Error | Lesson |
|---------|-------|--------|
| LC-01 | find -name *.c without quotes | Shell expansion |
| LC-01 | OR without grouping | Operator precedence |
| LC-02 | xargs without -0 | Spaces in filenames |
| LC-03 | $* instead of $@ | Arguments with spaces |
| LC-04 | chmod 777 | Security |
| LC-05 | Cron without absolute path | Cron environment |

### Quick Cheat Sheet

```bash
# find
find PATH -type f -name "*.ext" -size +1M -mtime -7 -exec CMD {} \;

# safe xargs
find . -print0 | xargs -0 CMD

# getopts
while getopts "hvo:" opt; do case $opt in ...; esac; done
shift $((OPTIND - 1))

# chmod
chmod 755 file    # octal
chmod u+x file    # symbolic

# cron
* * * * * /path/to/script >> /path/to/log 2>&1
```

---

*Document generated for UES Bucharest - CSIE | Operating Systems | Seminar 3*
