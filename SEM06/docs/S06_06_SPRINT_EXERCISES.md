# Sprint Exercises — CAPSTONE SEM06

> **Operating Systems** | ASE Bucharest - CSIE  
> Seminar 6: Integrated Projects (Monitor, Backup, Deployer)

---

## About Sprint Exercises

Short exercises (5-10 minutes) for rapid practice. Each exercise:
- Has a clear and measurable objective
- Can be verified immediately
- Builds on CAPSTONE concepts

**How to use:**
- Individually or in pairs
- At seminar start (warmup)
- As a break between longer sections
- As homework

---

## Pair Programming Protocol

Sprint exercises work exceptionally well with pair programming. Follow this protocol:

### Roles

| Role | Responsibilities |
|------|------------------|
| **Driver** | Types code, focuses on syntax correctness, verbalises thought process |
| **Navigator** | Reviews logic in real-time, spots errors early, thinks ahead, checks documentation |

### Rotation Schedule

| Time (min) | Activity | Driver | Navigator |
|------------|----------|--------|-----------|
| 0-5 | Sprint exercise (first half) | Student A | Student B |
| 5-10 | Sprint exercise (second half) | Student B | Student A |

**Switch trigger:** After completing each sprint exercise OR every 5-7 minutes, whichever comes first.

### Communication Guidelines

**Driver says:**
- "I'm going to create a trap handler here..."
- "Let me check if this variable is quoted..."
- "I think we need set -euo pipefail at the top"

**Navigator says:**
- "Wait, you missed the quotes around that variable"
- "What happens if the file doesn't exist?"
- "The exit code should be 1 for failure, not 0"

### Benefits for CAPSTONE

| Skill | How Pair Programming Helps |
|-------|---------------------------|
| Error handling | Navigator catches missing edge cases |
| Code style | Both learn from different approaches |
| Debugging | Two perspectives find bugs faster |
| Confidence | Reduces anxiety on complex tasks |

---

## Sprint 1: Trap Cleanup (5 min)

### Objective
Write a script that creates a temporary directory and deletes it automatically on termination.

### Requirement

```bash
# When you run the script:
./sprint1.sh
# Creates /tmp/sprint_XXXXX
# On exit (normal or Ctrl+C), directory disappears

# Verification:
ls /tmp/sprint_*  # Doesn't exist
```

### Starter Template

```bash
#!/bin/bash
set -euo pipefail

# TODO: Create temporary directory
TEMP_DIR=

# TODO: Define cleanup function


# TODO: Set trap


echo "Temporary directory: $TEMP_DIR"
echo "Press Ctrl+C or wait 5 seconds..."
sleep 5
echo "Normal termination"
```

### Verification

```bash
# Run the script
./sprint1.sh &
PID=$!
sleep 2
# Check directory exists
ls /tmp/sprint_* 2>/dev/null && echo "OK: Dir exists"
# Send SIGINT
kill -INT $PID
sleep 1
# Check directory disappeared
ls /tmp/sprint_* 2>/dev/null || echo "OK: Cleaned up"
```

---

## Sprint 2: Config Reading (7 min)

### Objective
Load variables from a configuration file.

### Config File (sprint2.conf)

```ini
# Backup configuration
BACKUP_DIR=/var/backups
MAX_BACKUPS=5
COMPRESSION=gzip
# Ignored comment
DEBUG=true
```

### Requirement

```bash
./sprint2.sh sprint2.conf
# Output:
# BACKUP_DIR=/var/backups
# MAX_BACKUPS=5
# COMPRESSION=gzip
# DEBUG=true
```

### Starter Template

```bash
#!/bin/bash
set -euo pipefail

CONFIG_FILE="${1:-config.conf}"

# TODO: Check file exists


# TODO: Read and display variables (ignore comments and empty lines)

```

### Hint
Use `grep -v "^#\|^$"` to filter comments and empty lines.

---

## Sprint 3: Logging Function (5 min)

### Objective
Implement a logging function with levels.

### Requirement

```bash
LOG_LEVEL=INFO

log DEBUG "Debug message"      # Not displayed
log INFO "Info message"        # [2024-01-15 10:30:00] [INFO] Info message
log WARN "Warning message"     # [2024-01-15 10:30:00] [WARN] Warning message
log ERROR "Error message"      # [2024-01-15 10:30:00] [ERROR] Error message
```

### Starter Template

```bash
#!/bin/bash

LOG_LEVEL="${LOG_LEVEL:-INFO}"

# Levels: DEBUG=0, INFO=1, WARN=2, ERROR=3
declare -A LEVELS=([DEBUG]=0 [INFO]=1 [WARN]=2 [ERROR]=3)

log() {
    local level="$1"
    local message="$2"
    
    # TODO: Check if should be displayed
    
    # TODO: Display with timestamp
    
}

# Test
log DEBUG "Debug message"
log INFO "Info message"
log WARN "Warning message"
log ERROR "Error message"
```

---

## Sprint 4: Process Check (5 min)

### Objective
Check if a process is running by name.

### Requirement

```bash
./sprint4.sh bash
# Output: Process 'bash' is running (PID: 1234, 5678)

./sprint4.sh nonexistent
# Output: Process 'nonexistent' is not running
# Exit code: 1
```

### Starter Template

```bash
#!/bin/bash
set -euo pipefail

PROCESS_NAME="${1:-}"

# TODO: Check argument


# TODO: Find PIDs (exclude own grep process)


# TODO: Display result and return exit code

```

### Hint
`pgrep -x "$PROCESS_NAME"` finds processes exactly by name.

---

## Sprint 5: Disk Usage Alert (7 min)

### Objective
Check disk space and alert if it exceeds a threshold.

### Requirement

```bash
./sprint5.sh /home 80
# If /home uses <80%:
# OK: /home at 45%

# If /home uses >=80%:
# ALERT: /home at 92% (threshold: 80%)
# Exit code: 1
```

### Starter Template

```bash
#!/bin/bash
set -euo pipefail

MOUNT_POINT="${1:-/}"
THRESHOLD="${2:-90}"

# TODO: Get usage percentage with df


# TODO: Compare with threshold and display

```

### Hint
`df -h "$MOUNT_POINT" | awk 'NR==2 {print $5}' | tr -d '%'`

---

## Sprint 6: File Age Check (5 min)

### Objective
Find files older than N days.

### Requirement

```bash
./sprint6.sh /var/log 7
# Output:
# Files older than 7 days in /var/log:
# /var/log/old.log (15 days)
# /var/log/ancient.log (30 days)
# Total: 2 files
```

### Starter Template

```bash
#!/bin/bash
set -euo pipefail

DIRECTORY="${1:-.}"
DAYS="${2:-30}"

# TODO: Argument validation


# TODO: Find files with find -mtime


# TODO: Display formatted results

```

---

## Sprint 7: Simple Health Check (7 min)

### Objective
Check if a URL responds with HTTP 200.

### Requirement

```bash
./sprint7.sh https://google.com
# Output: OK: https://google.com responded with 200

./sprint7.sh https://nonexistent.invalid
# Output: FAIL: https://nonexistent.invalid did not respond
# Exit code: 1
```

### Starter Template

```bash
#!/bin/bash
set -euo pipefail

URL="${1:-}"

# TODO: Check argument


# TODO: Check with curl and analyse response


```

### Hint
`curl -s -o /dev/null -w "%{http_code}" "$URL"` returns the HTTP code.

---

## Sprint 8: Rotate Files (10 min)

### Objective
Implement file rotation (keep the last N).

### Requirement

```bash
# If we have: backup_1.tar backup_2.tar ... backup_10.tar
./sprint8.sh /backups "backup_*.tar" 5
# Keeps: backup_6.tar ... backup_10.tar
# Deletes: backup_1.tar ... backup_5.tar
# Output:
# Keeping 5 newest files
# Deleted: backup_1.tar
# ...
# Deleted: backup_5.tar
```

### Starter Template

```bash
#!/bin/bash
set -euo pipefail

DIRECTORY="${1:-.}"
PATTERN="${2:-*}"
KEEP="${3:-5}"

# TODO: Validation


# TODO: List files sorted by date


# TODO: Delete oldest, keep KEEP

```

### Hint
`ls -t` sorts by time (newest first).

---

## Sprint 9: Cron Configuration (10 min)

### Objective
Configure automated backup using cron and understand the scheduling syntax.

### Context

Last semester, a student set up a "daily" backup but accidentally scheduled it to run every minute. The disk filled up in 3 hours. Don't be that student.

### Task

1. Create a backup script:
   ```bash
   #!/bin/bash
   # /usr/local/bin/daily_backup.sh
   set -euo pipefail
   
   LOG="/var/log/backup.log"
   BACKUP_DIR="/var/backups"
   SOURCE="/home/user/important"
   
   echo "[$(date -Iseconds)] Starting backup" >> "$LOG"
   
   # Create timestamped backup
   TIMESTAMP=$(date +%Y%m%d_%H%M%S)
   tar -czf "${BACKUP_DIR}/backup_${TIMESTAMP}.tar.gz" "$SOURCE" 2>> "$LOG"
   
   echo "[$(date -Iseconds)] Backup complete" >> "$LOG"
   ```

2. Add cron entry for 02:30 daily. Fill in the blanks:
   ```bash
   # Edit crontab
   crontab -e
   
   # Add this line (what's the correct format?)
   ___  ___  *  *  *  /usr/local/bin/daily_backup.sh
   ```

3. Verify cron is running:
   ```bash
   systemctl status cron
   crontab -l
   ```

### Expected Answer
```
30 2 * * * /usr/local/bin/daily_backup.sh
```

### Cron Format Reference
```
┌───────────── minute (0-59)
│ ┌───────────── hour (0-23)
│ │ ┌───────────── day of month (1-31)
│ │ │ ┌───────────── month (1-12)
│ │ │ │ ┌───────────── day of week (0-6, Sunday=0)
│ │ │ │ │
* * * * * command
```

### Common Patterns
| Expression | Meaning |
|------------|---------|
| `0 * * * *` | Every hour at minute 0 |
| `0 0 * * *` | Daily at midnight |
| `30 2 * * *` | Daily at 02:30 |
| `0 0 * * 0` | Every Sunday at midnight |
| `0 0 1 * *` | First day of each month |
| `*/15 * * * *` | Every 15 minutes |

### Common Mistakes
- Forgetting to make script executable (`chmod +x`)
- Wrong order of minute/hour (most common!)
- Missing full path to script
- Script without proper shebang
- Not handling errors (script fails silently)

### Bonus Challenge
What does this cron expression do?
```
0 */4 * * 1-5 /usr/local/bin/report.sh
```
Answer: _______________

---

## Quick Solutions

### Sprint 1

```bash
#!/bin/bash
set -euo pipefail
TEMP_DIR=$(mktemp -d /tmp/sprint_XXXXX)
cleanup() { rm -rf "$TEMP_DIR"; echo "Cleaned: $TEMP_DIR"; }
trap cleanup EXIT INT TERM
echo "Dir: $TEMP_DIR"; sleep 5
```

### Sprint 2

```bash
#!/bin/bash
set -euo pipefail
CONFIG_FILE="${1:?Usage: $0 config_file}"
[[ -f "$CONFIG_FILE" ]] || { echo "Not found: $CONFIG_FILE"; exit 1; }
grep -v "^#\|^$" "$CONFIG_FILE"
```

### Sprint 3

```bash
log() {
    local level="$1" message="$2"
    [[ ${LEVELS[$level]}  -ge ${LEVELS[$LOG_LEVEL]} ]] || return 0
    printf "[%s] [%s] %s\n" "$(date '+%Y-%m-%d %H:%M:%S')" "$level" "$message"
}
```

### Sprint 4

```bash
#!/bin/bash
set -euo pipefail
[[ -n "${1:-}" ]] || { echo "Usage: $0 process_name"; exit 1; }
PIDS=$(pgrep -x "$1" 2>/dev/null) || { echo "Process '$1' not running"; exit 1; }
echo "Process '$1' running (PID: $(echo $PIDS | tr '\n' ' '))"
```

### Sprint 5

```bash
#!/bin/bash
set -euo pipefail
USAGE=$(df "$1" | awk 'NR==2 {print $5}' | tr -d '%')
if [[ $USAGE -ge $2 ]]; then
    echo "ALERT: $1 at ${USAGE}% (threshold: $2%)"; exit 1
fi
echo "OK: $1 at ${USAGE}%"
```

### Sprint 9

```bash
# Answer: 30 2 * * *
# Bonus: Every 4 hours (0, 4, 8, 12, 16, 20) on weekdays (Mon-Fri)
```

---

## Progress Tracking

| Sprint | Concepts | Completed | Notes |
|--------|----------|-----------|-------|
| 1 | trap, cleanup, mktemp | ☐ | |
| 2 | config parsing, grep | ☐ | |
| 3 | logging, arrays, date | ☐ | |
| 4 | pgrep, process check | ☐ | |
| 5 | df, disk monitoring | ☐ | |
| 6 | find -mtime, file age | ☐ | |
| 7 | curl, health check | ☐ | |
| 8 | file rotation, sort | ☐ | |
| 9 | cron, scheduling | ☐ | |

---

*Document generated for SEM06 CAPSTONE — Operating Systems*  
*ASE Bucharest - CSIE | 2024-2025*
