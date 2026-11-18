# Instructor Guide: Seminar 03
## Operating Systems | Utilities, Scripts, Permissions, Automation

> Bucharest University of Economic Studies - CSIE  
> Timing: 100 contact minutes + 10-minute break = 110 elapsed. A 100-minute total slot needs a separately chosen reduced route.  
> Seminar type: Language as Vehicle (Bash for system administration)  
> Level: Intermediate (assumes SEM01–02 completed)

---

## Contents

1. [Session Objectives](#session-objectives)
2. [Special Warnings](#special-warnings)
3. [Preparation Before Seminar](#preparation-before-seminar)
4. [First Part Timeline](#detailed-timeline---first-part-50-min)
5. [Break](#break-10-minutes)
6. [Second Part Timeline](#detailed-timeline---second-part-50-min)
7. [Common Troubleshooting](#common-troubleshooting)
8. [Required Materials](#required-materials)
9. [Post-Seminar Notes](#post-seminar-notes)

---

## SESSION OBJECTIVES

At the end of the seminar, students will be able to:

1. Build complex searches with `find` using multiple criteria and logical operators
2. Process files in bulk using `xargs` correctly (including with spaces in names)
3. Write professional scripts that accept arguments and options with `getopts`
4. Understand and manage the Unix permissions system (octal and symbolic)
5. Configure special permissions correctly (SUID, SGID, Sticky Bit)
6. Schedule tasks with `cron` following best practices
7. Critically evaluate LLM-generated commands for correctness and security

---

## SPECIAL WARNINGS

### Security (CRITICAL for this seminar)

> Trap: This seminar involves working with permissions and automation. Mistakes can have serious consequences!

| Risk | Prevention | What to say |
|------|------------|-------------|
| `chmod 777` | NEVER demonstrate as a solution | "777 = anyone can do anything - unacceptable in production" |
| `find -exec rm` | Test with `-print` first | "We run with -print first to see what it finds" |
| `crontab -r` | Warn that it deletes EVERYTHING | "⚠️ crontab -r = remove ALL, not just one!" |
| SUID on scripts | Explain that it doesn't work | "SUID is ignored for scripts - security measure" |
| `/` in find | Limit to specific directories | "We don't search in /, but in dedicated directories" |

### Timing

| Subject | Allocated Time | Note |
|---------|----------------|------|
| find & xargs | 25 min | Can be extended if students have difficulties |
| Script parameters | 15 min | The template helps |
| Permissions | 20 min | Requires more time - multiple concepts |
| Cron | 10 min | Demo + homework |

### Teaching Tips

1. Deliberate errors: Include errors in live coding - students learn from debugging
2. Predictions: Ask "What do you think it will display?" before execution
3. Pair programming: Sprints are done in pairs with switch at halfway
4. Visualisation: Use ASCII diagrams for permissions

---

## PREPARATION BEFORE SEMINAR

### 1-2 Days Before

```bash
# Check availability of materials
ls -la ~/seminarii/SEM03/

# Test all demo scripts
cd ~/seminarii/SEM03/scripts/demo/
for script in *.sh; do
    echo "=== Testing $script ==="
    bash -n "$script" && echo "✓ Syntax OK"
done

# Verify you have rights for demonstrations
sudo -v  # only for preparation, not for seminar
```

### 30 Minutes Before

```bash
# Setup screen and terminal
# - Enlarged font: Ctrl+Shift+Plus (2-3 times)
# - Dark background for visibility
# - Projector resolution verified

# Open tabs in terminal:
# Tab 1: Create one fresh owned working directory for this session
DEMO_DIR=$(mktemp -d "${TMPDIR:-/tmp}/enos-s03-instructor.XXXXXX") || exit 1
export DEMO_DIR
cd -- "$DEMO_DIR" && clear

# Tab 2: Demo scripts
cd ~/seminarii/SEM03/scripts/demo/

# Tab 3: Documentation (for quick reference)
less ~/seminarii/SEM03/docs/S03_02_MAIN_MATERIAL.md
```

### 15 Minutes Before - Technical Checks

```bash
# 1. Create sandbox for permissions exercises
mkdir -p "$DEMO_DIR"/permissions_lab
mkdir -p "$DEMO_DIR"/find_lab
cd "$DEMO_DIR"

# 2. Create test files
touch test_{1..10}.txt
mkdir -p dir_{1..3}
echo '#!/bin/bash' > script_test.sh
echo 'echo "Hello"' >> script_test.sh

# 3. Verify that cron is working
systemctl status cron --no-pager | head -5
# You should see: Active: active (running)

# 4. Check locate database (optional)
locate --version 2>/dev/null || echo "locate is not installed"
# If installed and you want a fresh demo:
# sudo updatedb

# 5. Basic find test
find /etc -maxdepth 1 -type f 2>/dev/null | head -5

# 6. Check current permissions
ls -la "$DEMO_DIR"/
```

### Room-Specific Setup Notes

These room/cohort observations are retained author notes, not current measured
conditions. No timestamped facilities verification or cohort dataset accompanies
them. Check the actual teaching room before relying on those details.

**Lab 2031 (Calea Dorobanților building):**
- Projector has ~2 second lag after switching windows — pause before typing
- Morning sessions: first row monitors face windows, students squint after 10:00
- Power strips on the left wall (rows 3-4) cut out randomly — seat struggling students elsewhere
- AC remote is in the top drawer of the instructor desk (usually set too cold)

**Lab 1107 (Main building, Piața Romană):**
- Better projector, but no AC — summer sessions are brutal, keep water visible
- PCs are newer but still have 8GB RAM — Docker demos may lag
- Whiteboard markers are always dry — bring your own

**Lab 2016 (Dorobanți, ground floor):**
- Best room for this seminar — all PCs identical, reliable power
- But: echo problem, speak slower than usual
- Bonus: coffee machine around the corner works 70% of the time

### Presentation Screen Setup

```
┌────────────────────────────────────────────────────────────┐
│  Tab 1: Main Terminal                                       │
│  - Font: 18-20pt                                            │
│  - Short prompt: PS1='$ '                                   │
│  - Visible history: set -o history                          │
├────────────────────────────────────────────────────────────┤
│  Tab 2: Browser with HTML presentation                      │
│  - presentations/S03_01_presentation.html                   │
├────────────────────────────────────────────────────────────┤
│  Tab 3: Editor with cheat sheet (for yourself)             │
│  - docs/S03_09_VISUAL_CHEAT_SHEET.md                       │
└────────────────────────────────────────────────────────────┘
```

---

## MID-SESSION CHECKPOINTS

These quick checks help you gauge whether to speed up or slow down. I learned the hard way that "any questions?" gets silence even when half the room is lost.

### Checkpoint 1: After find section (~25 min mark)

**Quick Poll** (90 seconds):
> "Thumbs up if you could write a find command with 3 criteria right now, without notes."

| Result | Interpretation | Action |
|--------|----------------|--------|
| >70% up | They're ready | Move to xargs quickly |
| 50-70% up | Normal | One more example, then proceed |
| <50% up | Trouble | Add 5 min review, use simpler example |

**Backup mini-exercise** (if needed):
```bash
# "Everyone type this and predict what it finds BEFORE pressing Enter"
find /etc -type f -name "*.conf" -size +1k 2>/dev/null | head -5
```

### Checkpoint 2: After getopts (~55 min mark)

**Pair Check** (3 minutes):
1. Students swap laptops with neighbour
2. Run partner's script with `-h` flag
3. Must see usage message
4. If not → debug together for 2 minutes

This catches the "it works on my machine" students who haven't actually tested the help option.

### Checkpoint 3: Before cron section (~75 min mark)

**Exit Ticket Preview** (2 minutes):
Hand out sticky notes. Everyone writes:
> "The cron expression for 'every Sunday at 3 AM' is: ___________"

Collect silently, sort into correct/incorrect piles while they take a breath. Adjust cron explanation depth based on ratio.

**Correct answer:** `0 3 * * 0` (or `0 3 * * 7`)

Common wrong answers I see every semester:
- `3 0 * * 0` — hour/minute reversed (explain field order again)
- `0 3 * * SUN` is valid on the selected Debian/Ubuntu cron target; do not mark it wrong
- `* 3 * * 0` — runs every minute of 3 AM hour

---

## DETAILED TIMELINE - FIRST PART (50 min)

### [0:00-0:05] HOOK: Power of Find

Purpose: Capture attention by demonstrating the power of `find` in a spectacular one-liner.

Script to run:
```bash
#!/bin/bash
# S03_01_hook_demo.sh - run directly or copy the commands

echo "🔍 Search: The 10 largest files in /usr..."
echo "═══════════════════════════════════════════════════"

find /usr -type f -printf '%s %p\n' 2>/dev/null | \
    sort -rn | head -10 | \
    while read size path; do
        # Convert to MB
        size_mb=$(echo "scale=2; $size/1048576" | bc)
        printf "📦 %8.2f MB  %s\n" "$size_mb" "$path"
    done

echo ""
echo "✨ All in a single find + sort + head command!"
echo "Today we learn to build such commands step by step."
```

Instructor notes:
- Show that find is much more powerful than ls
- Emphasise: "We will learn each part of this command"
- If it takes too long (system is slow), stop with Ctrl+C and continue

Transition: "But first, let's see if you already know the difference between find and locate..."

---

### [0:05-0:10] PEER INSTRUCTION Q1: find vs locate

Display on screen or read:

```
╔══════════════════════════════════════════════════════════════════╗
║  🗳️ PEER INSTRUCTION #1                                          ║
╠══════════════════════════════════════════════════════════════════╣
║                                                                  ║
║  Assume the new path was absent from the current database and no update intervenes.
You just created a file: touch ~/project/config.txt             ║
║  Immediately after, you run: locate config.txt                   ║
║                                                                  ║
║  What happens?                                                   ║
║                                                                  ║
║  A) Finds the file instantly                                     ║
║  B) Does not find the file (database outdated)                   ║
║  C) Error - locate doesn't search in home                        ║
║  D) Finds all config.txt files in the system,                    ║
║     including the new one                                        ║
║                                                                  ║
╚══════════════════════════════════════════════════════════════════╝
```

PI Protocol:
1. [1 min] Students vote individually (raised hands or app)
2. [2 min] Discussion in pairs if no consensus
3. [1 min] Final vote
4. [1 min] Explanation with demonstration

Correct answer: B

Demonstration:
```bash
# Create new file
LOCATE_FILE=$(mktemp "$HOME/enos-s03-locate.XXXXXX")
printf 'Created %s\n' "$LOCATE_FILE"

# Try locate
locate -- "${LOCATE_FILE##*/}"
# Output: (nothing or old files)

# Update the database
sudo updatedb

# If the configured database indexes this location, it can now find it.
locate -- "${LOCATE_FILE##*/}"
# Otherwise inspect the configured database/pruning rules; absence is not a find defect.

# Cleanup
rm -f -- "$LOCATE_FILE"
```

Explanation: "locate uses a pre-indexed database that is updated periodically (usually at night). find searches in real time but is slower for large searches."

---

### [0:10-0:25] LIVE CODING: find and xargs (15 min)

STRUCTURE for each segment: Announcement → Prediction → Execution → Explanation

#### Segment 1: Basic find (4 min)

```bash
cd "$DEMO_DIR"

# Quick setup
mkdir -p src docs tests
touch src/{main,utils,config}.{c,h}
touch docs/{README.md,manual.txt,api.html}
touch tests/test_{1..5}.py

# COMMAND 1: Search by name
echo "📌 PREDICTION: What will this command find?"
# Wait 3 seconds
find . -name "*.txt"

# EXPLANATION: Searches recursively for files with .txt extension
```

```bash
# COMMAND 2: Search by type
echo "📌 PREDICTION: And this one?"
find . -type d

# EXPLANATION: -type d = directories, -type f = files
```

```bash
# COMMAND 3: Limit depth
echo "📌 PREDICTION: What does -maxdepth do?"
find . -maxdepth 1 -name "*.txt"

# EXPLANATION: maxdepth 1 = only in current directory, no recursion
```

#### Segment 2: find with multiple conditions (5 min)

```bash
# Implicit AND
echo "📌 Two conditions = implicit AND"
find . -type f -name "*.txt"

# Explicit OR
echo "📌 For OR we use -o with parentheses"
find . -type f \( -name "*.txt" -o -name "*.md" \)
# Trap: Spaces around parentheses!

# NOT
echo "📌 Negation with !"
find . -type f ! -name "*.txt"
```

**Deliberate error for learning:**
```bash
# WRONG (without parentheses)
find . -type f -name "*.txt" -o -name "*.md"
# Finds *.txt files OR any *.md (including directories!)

# CORRECT
find . -type f \( -name "*.txt" -o -name "*.md" \)
```

#### Segment 3: find with actions (4 min)

```bash
# -exec with \; (per file)
echo "📌 -exec executes the command for EACH file"
find . -name "*.txt" -exec echo "Found: {}" \;

# PREDICTION: "What does \; do?"
# ANSWER: Marks the end of the -exec command, executes separately for each
```

```bash
# -exec with + (batch)
echo "📌 With + sends files in size-bounded batches"
find . -name "*.txt" -exec echo {} +

# Difference: \; = one process per path; + = one or more bounded batches
```

#### Segment 4: xargs (5 min)

```bash
# Why xargs?
echo "📌 xargs transforms stdin into arguments"
find . -name "*.txt" | xargs wc -l

# DELIBERATE ERROR: files with spaces
touch "file with spaces.txt"
find . -name "*.txt" | xargs rm
# ERROR! "file" and "with" and "spaces.txt" treated separately
```

```bash
# SOLUTION: -print0 and -0
echo "📌 Solution for spaces: null delimiter"
find . -name "*.txt" -print0 | xargs -0 ls -la

# Alternative: xargs -I for placeholder
find . -name "*.txt" | xargs -I{} echo "Processing: {}"
```

Cleanup:
```bash
rm -f "file with spaces.txt"
```

---

### [0:25-0:30] PARSONS PROBLEM #1: Build the find command

Display on screen:

```
╔══════════════════════════════════════════════════════════════════╗
║  🧩 PARSONS PROBLEM: Build the find command                      ║
╠══════════════════════════════════════════════════════════════════╣
║                                                                  ║
║  REQUIREMENT: Find all .log files larger than 1MB                ║
║  modified in the last 7 days and delete them (with confirmation) ║
║                                                                  ║
║  SHUFFLED LINES (put them in order):                            ║
║  ─────────────────────────────────────────────────────────────   ║
║     -type f                                                      ║
║     -mtime -7                                                    ║
║     find /var/log                                                ║

║     -name "*.log"                                                ║
║     -exec rm -i {} \;                                            ║
║     -size +1M                                                    ║
║     -maxdepth 3         ← DISTRACTOR (useful but not required)  ║
║  ─────────────────────────────────────────────────────────────   ║
║                                                                  ║
║  Time: 3 minutes | Work in pairs                                ║
╚══════════════════════════════════════════════════════════════════╝
```

Correct solution:
```bash
find /var/log -type f -name "*.log" -size +1M -mtime -7 -exec rm -i {} \;
```

Acceptable solution (different order of criteria):
```bash
find /var/log -name "*.log" -type f -mtime -7 -size +1M -exec rm -i {} \;
```

Discussion: "The order of criteria doesn't matter for the result, but put the most selective ones first for performance"

---

### [0:30-0:45] SPRINT #1: Find Master (15 min)

Display instructions:

```
╔══════════════════════════════════════════════════════════════════╗
║  🏃 SPRINT #1: Find Master (15 min)                              ║
╠══════════════════════════════════════════════════════════════════╣
║                                                                  ║
║  PAIR PROGRAMMING! Switch at minute 7!                           ║
║                                                                  ║
║  SETUP (run first):                                              ║
║  mkdir -p "$DEMO_DIR/find_lab"/{src,docs,tests,build}                      ║
║  touch "$DEMO_DIR/find_lab"/src/{main,utils,config}.{c,h}                  ║
║  touch "$DEMO_DIR/find_lab"/docs/{README.md,manual.txt,api.html}           ║
║  touch "$DEMO_DIR/find_lab"/tests/test_{1..5}.py                           ║
║  dd if=/dev/zero of="$DEMO_DIR/find_lab"/build/big.bin bs=1M count=5       ║
║                                                                  ║
║  TASKS:                                                          ║
║  1. Find all .c files                                            ║
║  2. Find all files larger than 1MB                               ║
║  3. Find all files modified in the last hour                     ║
║  4. Find all files and display their permissions                 ║
║  5. BONUS: Archive all .py files into a tar                      ║
║                                                                  ║
║  VERIFICATION: Show output for each task                         ║
╚══════════════════════════════════════════════════════════════════╝
```

Solutions (for instructor):
```bash
# 1
find "$DEMO_DIR/find_lab" -name "*.c"

# 2
find "$DEMO_DIR/find_lab" -size +1M

# 3
find "$DEMO_DIR/find_lab" -mmin -60

# 4
find "$DEMO_DIR/find_lab" -type f -exec ls -l {} \;
# or
find "$DEMO_DIR/find_lab" -type f -printf "%m %p\n"

# 5 BONUS
find "$DEMO_DIR/find_lab" -type f -name "*.py" -print0 |
    tar --null -T - -cvf "$DEMO_DIR/tests.tar"
# One tar creation reads the entire NUL list; batching tar -c would lose earlier members.
```

Circulate through the class and help pairs having difficulties.

---

### [0:45-0:50] PEER INSTRUCTION Q2: $@ vs $*

```
╔══════════════════════════════════════════════════════════════════╗
║  🗳️ PEER INSTRUCTION #2                                          ║
╠══════════════════════════════════════════════════════════════════╣
║                                                                  ║
║  Given the script:                                               ║
║  #!/bin/bash                                                     ║
║  for arg in "$@"; do echo "[$arg]"; done                         ║
║  echo "---"                                                      ║
║  for arg in "$*"; do echo "[$arg]"; done                         ║
║                                                                  ║
║  Run: ./script.sh "hello world" test                             ║
║                                                                  ║
║  What does it display?                                           ║
║                                                                  ║
║  A) [hello world] [test] --- [hello world test]                  ║
║  B) [hello] [world] [test] --- [hello] [world] [test]            ║
║  C) [hello world] [test] --- [hello world] [test]                ║
║  D) [hello world test] --- [hello world] [test]                  ║
║                                                                  ║
╚══════════════════════════════════════════════════════════════════╝
```

Correct answer: A

Live demonstration:
```bash
cat << 'EOF' > "$DEMO_DIR/test_args.sh"
#!/bin/bash
echo '=== With $@ ==='
for arg in "$@"; do echo "[$arg]"; done
echo "---"
echo '=== With $* ==='
for arg in "$*"; do echo "[$arg]"; done
EOF

chmod +x "$DEMO_DIR/test_args.sh"
"$DEMO_DIR/test_args.sh" "hello world" test
```

Explanation: "$@" preserves argument separation, "$*" joins them into a single string with spaces.

---

## BREAK 10 MINUTES

On screen during break - display cron cheat sheet:

```
╔══════════════════════════════════════════════════════════════════╗
║  ⏰ CRON CHEAT SHEET - Preview for Part 2                        ║
╠══════════════════════════════════════════════════════════════════╣
║                                                                  ║
║  ┌───────────── minute (0-59)                                    ║
║  │ ┌───────────── hour (0-23)                                    ║
║  │ │ ┌───────────── day of month (1-31)                          ║
║  │ │ │ ┌───────────── month (1-12)                               ║
║  │ │ │ │ ┌───────────── day of week (0-7, 0,7=Sun)               ║
║  │ │ │ │ │                                                       ║
║  * * * * * command                                               ║
║                                                                  ║
║  EXAMPLES:                                                       ║
║  */5 * * * *     = every 5 minutes                              ║
║  0 3 * * *       = daily at 3:00 AM                             ║
║  0 9 * * 1-5     = Mon-Fri at 9:00 AM                           ║
║  0 0 1 * *       = first day of month at midnight               ║
║                                                                  ║
╚══════════════════════════════════════════════════════════════════╝
```

---

## DETAILED TIMELINE - SECOND PART (50 min)

### [0:00-0:05] REACTIVATION: Quick Permissions Quiz

Quick questions (raised hands):

```
📌 QUESTION 1:
What does permission "x" on a DIRECTORY mean?
   a) I can execute files in it
   b) I can access (cd) the directory  ← CORRECT
   c) I can list files

📌 QUESTION 2:
What does umask 077 do?
   a) New files will have permissions 077
   b) New files will have 600 (rw-------)  ← CORRECT
   c) New files will have 777

📌 QUESTION 3:
Who can delete a file?
   a) One with w permission on the file
   b) One with write AND search on the directory, subject to sticky/ACL restrictions  ← CORRECT
   c) Only the file owner
```

After each question, briefly explain if there are confusions.

---

### [0:05-0:20] LIVE CODING: Permissions (15 min)

#### Segment 1: Visualisation and octal chmod (5 min)

```bash
cd "$DEMO_DIR"/permissions_lab

# Create test files
touch public.txt private.txt
echo '#!/bin/bash' > script.sh
echo 'echo "Hello from script"' >> script.sh

# Visualisation
ls -la

# PREDICTION: "What permissions does a newly created file have?"
# Default: 644 (rw-r--r--) with umask 022
```

```bash
# octal chmod - visual explanation
echo "📌 chmod OCTAL: 3 digits for owner-group-others"
echo "   r=4, w=2, x=1"
echo "   rwx = 4+2+1 = 7"
echo "   rw- = 4+2+0 = 6"
echo "   r-x = 4+0+1 = 5"

chmod 755 script.sh    # rwxr-xr-x
ls -l script.sh

chmod 600 private.txt  # rw-------
ls -l private.txt
```

```bash
# PREDICTION: "Can I run ./script.sh now?"
./script.sh
# Yes! Has x for owner

# But what happens without x?
chmod 644 script.sh
./script.sh
# Permission denied!

chmod 755 script.sh  # restore
```

#### Segment 2: Symbolic chmod (4 min)

```bash
# symbolic chmod - more descriptive
echo "📌 chmod SYMBOLIC: u/g/o/a and +/-/="

touch test_symbolic.txt
ls -l test_symbolic.txt  # rw-r--r--

chmod u+x test_symbolic.txt   # +execute for owner
ls -l test_symbolic.txt       # rwxr--r--

chmod g-r test_symbolic.txt   # -read for group
ls -l test_symbolic.txt       # rwx---r--

chmod o=--- test_symbolic.txt # others = nothing
ls -l test_symbolic.txt       # rwx------

chmod a+r test_symbolic.txt   # all +read
ls -l test_symbolic.txt       # rwxr--r--
```

#### Segment 3: umask (4 min)

```bash
# Check current umask
umask
# Probably 022

# PREDICTION: "With umask 022, what permissions will a new file have?"
touch test_umask.txt
ls -l test_umask.txt
# 644 (0666 & ~0022 = 0644, no default ACL)

# Change umask for private files
umask 077
touch very_private.txt
ls -l very_private.txt
# 600 (0666 & ~0077 = 0600, no default ACL)

# Restore
umask 022
```

#### Segment 4: Special permissions (3 min)

```bash
# SGID on directory - very useful for shared projects
mkdir shared_project
chmod g+s shared_project
ls -ld shared_project
# drwxr-sr-x - notice the 's'

# EXPLANATION: New files in this directory will inherit the group
```

```bash
# Sticky bit - as in /tmp
ls -ld /tmp
# drwxrwxrwt - notice the 't'

# EXPLANATION: Sticky adds an ownership condition: file owner, directory owner
# or suitable privilege may remove entries; normal write/search checks still apply.
```

#### Segment 5: DELIBERATE ERROR (2 min)

```bash
# WHAT SHOULD NEVER BE DONE:
# chmod -R 777 / # DISASTER!

# CORRECT: Differentiate files from directories
echo "📌 Correct pattern for recursive chmod:"
# find ~/demo -type f -exec chmod 644 {} \;
# find ~/demo -type d -exec chmod 755 {} \;

# X also affects regular files already executable by any class; different contract
# chmod -R u=rwX,g=rX,o=rX ~/demo
```

---

### [0:20-0:25] PEER INSTRUCTION Q3: SUID

```
╔══════════════════════════════════════════════════════════════════╗
║  🗳️ PEER INSTRUCTION #3                                          ║
╠══════════════════════════════════════════════════════════════════╣
║                                                                  ║
║  The file /usr/bin/passwd has permissions: -rwsr-xr-x            ║
║                                                                  ║
║  What does 's' in the owner execute position mean?               ║
║                                                                  ║
║  A) The file is a symlink                                        ║
║  B) The file runs with owner's (root) permissions  ← CORRECT     ║
║  C) The file is sticky (cannot be deleted)                       ║
║  D) The file is shared between users                             ║
║                                                                  ║
╚══════════════════════════════════════════════════════════════════╝
```

Demonstration:
```bash
ls -l /usr/bin/passwd
# -rwsr-xr-x 1 root root ... /usr/bin/passwd

# When you run passwd, the process temporarily has root permissions
# Thus it can modify /etc/shadow (which is owned by root)

ls -l /etc/shadow
# -rw-r----- 1 root shadow ...
```

---

### [0:25-0:40] SPRINT #2: Professional Script (15 min)

```
╔══════════════════════════════════════════════════════════════════╗
║  🏃 SPRINT #2: Script with Options (15 min)                      ║
╠══════════════════════════════════════════════════════════════════╣
║                                                                  ║
║  PAIR PROGRAMMING! Switch at minute 7!                           ║
║                                                                  ║
║  REQUIREMENT: Create a script "fileinfo.sh" that:                ║
║                                                                  ║
║  1. Accepts the options:                                         ║
║     -h / --help     : Display help                              ║
║     -v / --verbose  : Detailed mode                             ║
║     -s / --size     : Also display size                         ║
║                                                                  ║
║  2. Accepts one or more files as arguments                       ║
║                                                                  ║
║  3. For each file, displays:                                     ║
║     - Name                                                       ║
║     - Type (file/directory/link)                                ║
║     - Permissions                                                ║
║     - (with -s) Size                                             ║
║                                                                  ║
║  USAGE EXAMPLE:                                                  ║
║  ./fileinfo.sh -v -s file1.txt file2.txt                        ║
║                                                                  ║
║  TEMPLATE on screen 2 (or in docs/S03_05_LIVE_CODING.md)         ║
║                                                                  ║
╚══════════════════════════════════════════════════════════════════╝
```

Template to provide:
```bash
#!/bin/bash
# fileinfo.sh - displays information about files

VERBOSE=false
SHOW_SIZE=false

usage() {
    echo "Usage: $0 [-h] [-v] [-s] file..."
    echo "  -h, --help     Display this help"
    echo "  -v, --verbose  Detailed mode"
    echo "  -s, --size     Display size"
    exit 1
}

# TODO: Implement option parsing with getopts or while/case
# TODO: Process remaining files

# Check: at least one file
if [ $# -eq 0 ]; then
    usage
fi

for file in "$@"; do
    # TODO: Display information
    echo "Processing: $file"
done
```

Complete solution (for instructor):
```bash
#!/bin/bash
VERBOSE=false
SHOW_SIZE=false

usage() {
    cat << EOF
Usage: $(basename "$0") [options] file...

Options:
  -h, --help     Display this help
  -v, --verbose  Detailed mode
  -s, --size     Display size
EOF
    exit 1
}

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help) usage ;;
        -v|--verbose) VERBOSE=true; shift ;;
        -s|--size) SHOW_SIZE=true; shift ;;
        --) shift; break ;;
        -*) echo "Unknown option: $1"; exit 1 ;;
        *) break ;;
    esac
done

[ $# -eq 0 ] && usage

for file in "$@"; do
    [[ -e $file || -L $file ]] || { echo "Does not exist: $file" >&2; exit 1; }
    
    type="file"
    [ -d "$file" ] && type="directory"
    [ -L "$file" ] && type="symlink"
    
    perm=$(stat -c "%A" "$file")
    
    output="$file: $type, $perm"
    $SHOW_SIZE && output+=", $(stat -c %s "$file") bytes"
    
    echo "$output"
    if "$VERBOSE"; then ls -ld -- "$file" || exit 1; fi
done
exit 0
```

---

### [0:40-0:48] LLM + CRON DEMO (8 min)

```
╔══════════════════════════════════════════════════════════════════╗
║  🤖 DEMO: Cron + LLM Evaluation (8 min)                          ║
╠══════════════════════════════════════════════════════════════════╣
║                                                                  ║
║  1. [2 min] INSTRUCTOR demonstrates a simple cron job            ║
║                                                                  ║
║  2. [3 min] STUDENTS: Ask an LLM to generate a cron job          ║
║     for "daily backup at 3 AM with logging"                      ║
║                                                                  ║
║  3. [3 min] EVALUATE the LLM response:                          ║
║     - Is it syntactically correct?                               ║
║     - Does it include logging?                                   ║
║     - Does it have absolute paths?                               ║
║     - Does it handle errors?                                     ║
║                                                                  ║
╚══════════════════════════════════════════════════════════════════╝
```

Instructor demonstration:

Use the local logger/candidate procedure in the [Live Coding Guide](S03_05_LIVE_CODING_GUIDE.md#segment-2-prepare-a-job-and-inspect-the-result-2-minutes).
A scheduled run is a separate authorised activity in a disposable account; the D3
model requires explicit installation and unique-marker cleanup. A normal lesson
run does not install a job or assume authority to change a scheduler.

Checklist for LLM evaluation:
- [ ] Correct cron syntax (5 fields)
- [ ] Absolute paths for script and log
- [ ] Output redirection: `>> log 2>&1`
- [ ] PATH variables set or complete paths
- [ ] (Bonus) Lock file to prevent simultaneous executions

---

### [0:48-0:50] REFLECTION

```
╔══════════════════════════════════════════════════════════════════╗
║  🧠 REFLECTION (2 minutes)                                       ║
╠══════════════════════════════════════════════════════════════════╣
║                                                                  ║
║  Answer on paper or mentally:                                    ║
║                                                                  ║
║  1. What concept from today will you use IMMEDIATELY             ║
║     in your projects?                                            ║
║                                                                  ║
║  2. What seems the most DANGEROUS from what we learnt today?     ║
║     (and why it's important to be careful)                       ║
║                                                                  ║
║  3. ONE thing you want to practise at home:                      ║
║     _______________________________________________              ║
║                                                                  ║
║  📝 ASSIGNMENT: Complete ../homework/S03_01_HOMEWORK.md by next seminar    ║
║                                                                  ║
╚══════════════════════════════════════════════════════════════════╝
```

---

## COMMON TROUBLESHOOTING

| Problem | Symptom | Quick Solution |
|---------|---------|----------------|
| Permission denied on script | `bash: ./script.sh: Permission denied` | `chmod +x script.sh` |
| find: permission denied | Incomplete traversal | Restrict the owned root and retain errors; suppressing stderr does not make coverage complete |
| getopts doesn't parse --help | Ignores long options | getopts is only for short options, use `case` |
| Cron job doesn't run | Nothing in log | Check absolute paths, PATH, permissions, `systemctl status cron` |
| umask doesn't persist | Reverts after logout | Add to `~/.bashrc` |
| SUID doesn't work | Script doesn't run as root | SUID is ignored for interpreted scripts |
| xargs: argument too long | Error with many files | Use `xargs -n 100` |
| locate doesn't find new files | Recently created file absent | Run `sudo updatedb` |

---

## REQUIRED MATERIALS

- [ ] Laptop with Ubuntu 24.04 or WSL
- [ ] Working projector
- [ ] Demo scripts prepared in `scripts/demo/`
- [ ] HTML presentation in `prezentari/`
- [ ] Printed cheat sheet (optional, for reference)

---

## POST-SEMINAR NOTES

After each seminar, note:

1. What worked well?
   - ...

2. What should be adjusted for next time?
   - ...

3. Frequent questions from students:
   - ...

4. Concepts that required additional explanations:
   - ...

5. Actual vs planned timing:
   - Hook: ___ min (plan: 5)
   - Live Coding 1: ___ min (plan: 15)
   - Sprint 1: ___ min (plan: 15)
   - Live Coding 2: ___ min (plan: 15)
   - Sprint 2: ___ min (plan: 15)

---

## 📝 MY NOTES FROM THE CLASSROOM (from real experience)

### Minute 15-20: Watch the Group Energy
This is usually when attention drops. I have two strategies that work:
1. **Quick "pop quiz"**: "Who can tell me what -type f does?" — pick someone directly
2. **Abrupt switch to live demo** if I see heads in phones

### When the Inevitable "but on Mac?" Question Comes Up
- **Short answer**: "Install GNU coreutils with brew"
- **Long answer**: We do not give it. macOS is out of scope and we lose precious time
- **If they insist**: "We test on Ubuntu and that is the reference environment for this course"

### My Mistake from 2023
I forgot to demonstrate that `locate` does not find new files. A student remained 
convinced it was a bug in Ubuntu and sent me an email about it. Since then I ALWAYS 
do the demo in strict order:
1. `touch newfile.txt`
2. `locate newfile.txt` (does not find it - "aha!" moment)
3. "Why?" → explain database → `sudo updatedb` → now it finds it

### Frequently Asked Questions and Prepared Answers

> **"Why does SUID not work on my bash script?"**

Short answer: Security. Linux ignores SUID on interpreted scripts.
Technical reason: Between exec() and interpretation an attacker could modify the script.
Quick demo: Show that `/usr/bin/passwd` has SUID and is a BINARY not a script.

> **"Can I put spaces in crontab?"**

Yes but not where you think. Fields are separated by whitespace but the COMMAND 
can have spaces. Demonstrate:
```
* * * * * echo "works with spaces" >> /tmp/test.log
```

> **"Is chmod 777 not simpler?"**

[Dramatic pause] "Let us see what happens if you do that on a web server..."
→ Quick demo with world-writable directory → "see why not?"

### What I Have Learnt About Timing

| Activity | Initial Plan | Reality | Adjustment |
|----------|--------------|---------|------------|
| Hook find | 5 min | 5-7 min | OK but prepare Ctrl+C |
| PI find vs locate | 5 min | 7-8 min | Discussions take longer |
| Live coding find | 15 min | 18-20 min | Reduce to essentials if running late |
| Sprint #1 | 15 min | 12-15 min | Some finish quickly, others... |
| Permissions | 20 min | 25 min | Most unpredictable |
| Cron + LLM | 10 min | 8-10 min | Works well |

**Conclusion**: Plan 90 min of content for a 100 min slot. The rest is buffer.

### Signs That I Need to Change Pace

🚨 **Speed up if:**
- Everyone answers the PI correctly (they are more prepared than I thought)
- They finish the sprint in 5 minutes (exercises are too easy)
- Nobody asks questions (either they understand perfectly or they are completely lost)

🛑 **Slow down if:**
- More than 30% answer the PI incorrectly
- Confused expressions during live coding
- Same errors from multiple students in the sprint

### Specific Setup for Dorobanti Lab

- PCs have Ubuntu 24.04 since autumn 2024 (finally!)
- Portainer works on 9000 but sometimes you need to refresh
- Cron service does NOT start automatically — check with `systemctl status cron`
- If `locate` does not work: `sudo apt install mlocate && sudo updatedb`

### Backup Plan If Everything Goes Wrong

If you lose a lot of time at the beginning cut directly:
1. Skip PI #2 ($@ vs $*)
2. Reduce sprint #1 to 8 minutes
3. Cron becomes "homework preview" (2 minute demo, rest at home)
4. Reflection becomes "one sentence each" verbal

---

## 📚 QUICK REFERENCES FOR MYSELF

### Commands I Always Forget

```bash
# How to display permissions in octal
stat -c "%a %n" file

# How to check what a cron job does WITHOUT running it
crontab -l  # Read only; do not invoke an editing entry point to inspect a table

# How to find files modified in the last hour
find . -mmin -60 -type f

# Escape for parentheses in find
find . \( -name "*.txt" -o -name "*.md" \)
#      ^-- space after backslash-parenthesis!
```

### Magic Numbers for Permissions

| Octal | Symbolic | Description |
|-------|----------|-------------|
| 755 | rwxr-xr-x | Executable script |
| 644 | rw-r--r-- | Normal text file |
| 700 | rwx------ | Private script |
| 600 | rw------- | SSH key, private config |
| 777 | rwxrwxrwx | **NEVER IN PRODUCTION** |

### Crontab Field Order (always slips my mind)

```
MIN  HOUR  DOM  MON  DOW  COMMAND
 │    │     │    │    │
 │    │     │    │    └─ 0-7 (0,7=Sunday)
 │    │     │    └────── 1-12
 │    │     └─────────── 1-31
 │    └───────────────── 0-23
 └────────────────────── 0-59
```

---

*Guide created for Seminar 3 OS | Bucharest UES - CSIE*  
*Maintained by ing. dr. Antonio Clim*  
*Updated: January 2025 (v1.3 — added checkpoints, room notes, presentation path fix)*


## Retained Author Notes

*(`find` combined with `-exec` is extremely useful. Once you master it, you can't do without it.)*
