# Differentiation Tiers — Seminar 03
## Adapting to Different Student Levels

> **Version:** 1.0 | **Date:** January 2025  
> **Purpose:** Scaffolding for struggling students, challenges for fast finishers  
> **Principle:** Same learning objectives, different paths

---

## The Three-Tier System

Not everyone arrives at the same level. After four semesters of watching students either panic or get bored, I formalised this into three tiers. The trick is identifying which students need which tier *without* making anyone feel singled out.

| Tier | Who | Signs to Watch For | Time Budget |
|------|-----|--------------------|----|
| **Foundation** | Struggling with basics | Hasn't finished Sprint by halfway; asks "what does -type mean?"; blank screen after 5 min | +20% time |
| **Core** | Average progression | Finishes Sprint on time with minor errors; asks clarifying questions | Standard |
| **Extension** | Fast finishers | Done in half the time; starts helping neighbours; looks bored | Challenge problems |

**Important:** Never announce tiers publicly. I say things like "If you finished early, grab a challenge problem from the board" or "If you're stuck, use the simplified worksheet on page 2."

---

## Foundation Tier: Scaffolded Support

### F1. The find Command Builder (Visual Worksheet)

For students who freeze at the blank terminal. Hand this out silently to anyone staring at their screen after 5 minutes.

```
┌─────────────────────────────────────────────────────────────────────┐
│                    BUILD YOUR FIND COMMAND                          │
│                                                                     │
│  find  [WHERE?]  [WHAT TYPE?]  [WHAT NAME?]  [THEN DO?]            │
│         │            │              │             │                 │
│         ▼            ▼              ▼             ▼                 │
│    ┌─────────┐  ┌─────────┐   ┌──────────┐  ┌──────────┐           │
│    │  /home  │  │ -type f │   │-name "x" │  │   -ls    │           │
│    │    .    │  │ -type d │   │-name "y" │  │ -delete  │           │
│    │  /tmp   │  │         │   │          │  │ -exec    │           │
│    └─────────┘  └─────────┘   └──────────┘  └──────────┘           │
│                                                                     │
│  Your command:  find _______ _________ ___________ ___________      │
└─────────────────────────────────────────────────────────────────────┘

EXAMPLE: "Find all .log files in /var"
  → find /var -type f -name "*.log"
       │       │           │
       │       │           └── ends with .log
       │       └── only files, not directories  
       └── start looking in /var
```

### F2. Permission Calculator (Checkbox Method)

For the student who can't remember what 7-5-5 means. Much slower than mental math, but it *works*.

```
┌───────────────────────────────────────────────────────────────────┐
│               PERMISSION CALCULATOR                                │
│                                                                    │
│  Check what the OWNER can do:          Check what OTHERS can do:   │
│    □ Read    (4)                         □ Read    (4)             │
│    □ Write   (2)                         □ Write   (2)             │
│    □ Execute (1)                         □ Execute (1)             │
│    ─────────────                         ─────────────             │
│    Total: ___                            Total: ___                │
│                                                                    │
│  Check what the GROUP can do:                                      │
│    □ Read    (4)                                                   │
│    □ Write   (2)                         Final chmod: ___ ___ ___  │
│    □ Execute (1)                                      owner grp oth│
│    ─────────────                                                   │
│    Total: ___                                                      │
└───────────────────────────────────────────────────────────────────┘

EXAMPLE: Owner can read+write+execute, group can read+execute, others nothing
  Owner: 4+2+1 = 7
  Group: 4+0+1 = 5  
  Other: 0+0+0 = 0
  
  → chmod 750 myfile.sh
```

### F3. getopts Template (Fill-in-the-Blanks)

Instead of staring at empty editor, they fill in the blanks:

```bash
#!/bin/bash
# TEMPLATE: Fill in the blanks marked with ___

# Default values
VERBOSE=false
OUTPUT_FILE=""

# Show help
usage() {
    echo "Usage: $0 [-h] [-v] [-o FILE]"
    echo "  -h       Show this help"
    echo "  -v       Enable verbose mode"
    echo "  -o FILE  Write output to FILE"
    exit 0
}

# Parse options - FILL IN THE BLANKS
while getopts "_____" opt; do    # ← What letters? (hint: h, v, o with argument)
    case $opt in
        h) usage ;;
        v) _________=true ;;      # ← Which variable becomes true?
        o) OUTPUT_FILE="______" ;;  # ← How do you get the argument?
        ?) echo "Unknown option"; exit 1 ;;
    esac
done

# Shift past the options
shift $((______ - 1))            # ← Which variable tracks position?

# Now $@ contains only the remaining arguments
echo "Verbose: $VERBOSE"
echo "Output: $OUTPUT_FILE"
echo "Remaining args: $@"
```

**Answer key** (for instructor):
- `"hvo:"` (h and v are flags, o takes argument hence the colon)
- `VERBOSE`
- `$OPTARG`
- `OPTIND`

---

## Core Tier: Standard Exercises

These are the main Sprint exercises. Most students should complete them with time to spare.

### C1. Find Master (15 minutes)

1. Find all `.sh` files modified in the last 7 days
2. Find files larger than 1MB that are NOT in `/proc` or `/sys`
3. Find empty directories and list them
4. Combine: find `.log` files over 100KB, older than 30 days, and show their sizes

### C2. Script Professional (15 minutes)

Create a script `filecount.sh` that:
- Accepts `-d DIRECTORY` to specify where to count
- Accepts `-t TYPE` to filter by extension (e.g., `-t txt`)
- Accepts `-v` for verbose output
- Shows count of matching files

### C3. Permission Audit (10 minutes)

1. Find all world-writable files in your home directory
2. Find all files with SUID bit set in `/usr/bin`
3. Create a directory where group members can add files but not delete others' files

---

## Extension Tier: Challenge Problems

For students who finish early. These go beyond the curriculum but reinforce the concepts.

### E1. ACL Deep Dive (Advanced)

Regular Unix permissions are limited. What if you need to give access to *specific* users?

```bash
# Install ACL tools (if not present)
sudo apt install acl

# Task: Create a file that:
# - You can read/write
# - User 'alice' can only read
# - Group 'developers' can read/write
# - Everyone else: no access

# Hint: 
# setfacl -m u:alice:r-- myfile.txt
# getfacl myfile.txt
```

**Challenge questions:**
1. What happens to ACLs when you `cp` a file? When you `mv` it?
2. How do default ACLs on directories affect new files?
3. Why does `ls -l` show a `+` after permissions when ACLs are set?

### E2. Real-Time File Monitor

Use `inotifywait` to watch a directory and react to changes:

```bash
# Install inotify-tools
sudo apt install inotify-tools

# Task: Write a script that:
# 1. Watches ~/Downloads for new files
# 2. When a .pdf appears, moves it to ~/Documents/PDFs/
# 3. When a .jpg appears, moves it to ~/Pictures/
# 4. Logs all actions with timestamps

# Starter:
inotifywait -m -e create ~/Downloads |
while read path action file; do
    echo "Detected: $file"
    # Your logic here
done
```

### E3. Cron Job Generator (Interactive)

Build an interactive script that helps users create cron entries:

```bash
# The script should:
# 1. Ask "How often?" (every minute, hourly, daily, weekly, monthly, custom)
# 2. For custom: ask for specific times
# 3. Ask for the command to run
# 4. Generate the cron line
# 5. Optionally add it to crontab directly

# Example interaction:
# > How often? [1] Every minute [2] Hourly [3] Daily [4] Weekly [5] Custom
# > 3
# > At what time? (HH:MM, 24h format)
# > 03:30
# > Command to run:
# > /home/user/backup.sh
# 
# Generated: 30 3 * * * /home/user/backup.sh
# Add to crontab? [y/N]
```

### E4. Incremental Backup with Timestamps

Move beyond simple `tar` to incremental backups:

```bash
# Task: Create backup_incremental.sh that:
# 1. On first run, creates full backup: backup_FULL_20250130.tar.gz
# 2. On subsequent runs, backs up only files changed since last backup
# 3. Uses find -newer to detect changes
# 4. Maintains a "last_backup" timestamp file
# 5. Rotates old backups (keep only last 5)

# Hints:
# - touch -d "2025-01-30 10:00" last_backup_marker
# - find /data -newer last_backup_marker -type f
# - tar --files-from=changed_files.txt
```

---

## How to Identify Tiers Without Embarrassment

During sprints, I walk around silently. Here's my mental checklist:

**Foundation signals** (offer worksheet quietly):
- Empty terminal after 5 minutes
- Repeatedly typing same wrong command  
- Looking at neighbour's screen with confusion
- Hand raised but too shy to ask

**Extension signals** (drop challenge card on desk):
- Leaning back, arms crossed, done expression
- Helping neighbour extensively
- Adding extra features not requested
- Asking "what else can I try?"

**What I say:**
- Foundation: "Here's a reference sheet some students find helpful" (not "because you're struggling")
- Extension: "If you're done, there's an extra challenge on the board — optional but fun"

---

## Timing Adjustments

| Scenario | Foundation | Core | Extension |
|----------|------------|------|-----------|
| Sprint 1 (find) | 18 min + worksheet | 15 min | 10 min + E1 or E2 |
| Sprint 2 (script) | 18 min + template | 15 min | 10 min + E3 |
| Permissions | 12 min + calculator | 10 min | 8 min + ACL |
| Cron | 10 min (demo only, HW) | 8 min | 5 min + E4 |

---

## Materials Checklist

Print before seminar:
- [ ] 10× Foundation worksheets (F1, F2, F3) — don't print too many, feels patronising
- [ ] 5× Extension challenge cards (E1-E4) — laminated, reusable
- [ ] Sticky notes for Checkpoint 3

---

*Differentiation framework for Seminar 3 | Operating Systems*  
*Bucharest UES — CSIE*  
*Created: January 2025 (v1.0)*
