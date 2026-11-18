# Sprint Exercises — CAPSTONE SEM06

> **Operating Systems** | ASE Bucharest - CSIE  
> Seminar 6: Integrated Projects (Monitor, Backup, Deployer)

---

> **Technical and assessment status:** starter TODOs remain exercises and must not be mistaken for completed implementations. Verify only owned fixtures. Local point values and schedules are author proposals; see [TEACHING_CONTRACT.md](TEACHING_CONTRACT.md).

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
# Check the exact OWNED_DIR printed by this run, never a shared /tmp glob.
```

### Starter Template

```bash
#!/bin/bash
set -euo pipefail

# Initialise before registering cleanup; allocate only after installing EXIT.
TEMP_DIR=
# TODO: Define cleanup, register EXIT and INT/TERM exit handlers, then call mktemp -d

# TODO: Define cleanup function


# TODO: Set trap


printf 'OWNED_DIR=%s\n' "$TEMP_DIR"
echo "Press Ctrl+C or wait 5 seconds..."
sleep 5
echo "Normal termination"
```

### Verification

Use the exact-path child fixture in the instructor guide. It waits for the child's `OWNED_DIR=...` readiness record, checks that path exists, sends TERM to the owned child, waits for exit 143 and checks that the same path has disappeared. Background SIGINT can be inherited as ignored; globbing `/tmp/sprint_*` proves neither ownership nor cleanup. SIGKILL and host loss cannot run traps.

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
Treat the file as literal data. Use `while IFS= read -r line || [[ -n $line ]]`, trim surrounding whitespace, skip comments/empty lines and validate the allowed keys. A comment-only file is a valid empty result, not an error from `grep` returning 1. Never `source` or `eval` an untrusted configuration.

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
`pgrep -x` matches a whole process-name regular expression, not a literal string. Escape regular-expression metacharacters for a literal-name contract. Status 1 means no match; status 2 or higher is an error. Process observations can race with process exit.

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
Capture `LC_ALL=C df -P -- "$MOUNT_POINT"` and check its status first. Validate the extracted percentage and the 0–100 threshold before numeric comparison. Use the maintained `get_disk_usage` helper; missing data is unavailable, never a healthy 0%.

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
./sprint7.sh http://fixture.invalid/health # use the local mock; no network
# Output: OK: fixture response was 200

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
Capture `curl --silent --show-error --connect-timeout 2 --max-time 5 --output /dev/null --write-out "%{http_code}" -- "$URL"` in `if`. Transport failure is distinct from a non-200 HTTP status. Test 200, 404, timeout and malformed status with `scripts/examples/mock_curl.py`; do not send requests to public endpoints as a test default.

---

## Sprint 8: Rotate Files (10 min)

### Objective
Implement file rotation (keep the last N).

### Requirement

```bash
# Fixture has ten INDEPENDENT archives with strictly increasing mtimes. Names alone do not establish age.
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
Use a NUL-delimited, checked enumeration of regular files and a deterministic mtime/name sort, or Python Path/stat sorting. Do not parse `ls` output. Test empty directories, KEEP=0, equal mtimes, spaces/newlines and failed unlink. This exercise rotates independent files; incremental Backup requires ancestor-aware graph retention.

---

## Sprint 9: Cron Configuration (10 min)

### Objective
Configure automated backup using cron and understand the scheduling syntax.

### Context

Historical author anecdote (date and evidence not supplied): a daily backup was reportedly scheduled every minute and filled a disk in three hours. Treat this as a scenario for checking a schedule, not a verified empirical result.

### Task

1. Create a backup script:
   ```bash
   #!/bin/bash
   # Save in an owned exercise directory; configure paths explicitly.
   set -euo pipefail
   
   : "${DEMO_ROOT:?Set an absolute owned exercise directory}"
   LOG="$DEMO_ROOT/backup.log"
   BACKUP_DIR="$DEMO_ROOT/backups"
   SOURCE="$DEMO_ROOT/source"
   [[ -d $BACKUP_DIR && -d $SOURCE ]] || exit 1
   
   echo "[$(date -Iseconds)] Starting backup" >> "$LOG"
   
   # Create timestamped backup
   stage=$(mktemp "$BACKUP_DIR/.partial.XXXXXX")
   trap 'rm -f -- "$stage"' EXIT
   tar -czf "$stage" -C "$SOURCE" . 2>> "$LOG"
   mv -- "$stage" "${stage/.partial./backup_}.tar.gz"
   
   echo "[$(date -Iseconds)] Backup complete" >> "$LOG"
   ```

2. Draft a cron entry for 02:30 daily; do not install it during this exercise. Fill in the blanks and expand the absolute paths for the intended host:
   ```cron
   MAILTO=""
   # Interpreter, script and owned workspace paths must be explicit.
   ___  ___  *  *  *  DEMO_ROOT=/absolute/owned/demo /bin/bash /absolute/owned/daily_backup.sh
   ```

3. Optional read-only checks on a host whose cron service is available:
   ```bash
   systemctl status cron
   crontab -l
   ```

### Expected Answer
```
30 2 * * * DEMO_ROOT=/absolute/owned/demo /bin/bash /absolute/owned/daily_backup.sh
```

Times use the cron host timezone unless the selected implementation explicitly supports a configured timezone. Daylight-saving transitions can skip or repeat local times. A valid expression does not prove daemon execution, permissions or successful backup.

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
#!/usr/bin/env bash
set -euo pipefail
TEMP_DIR=
cleanup() { [[ -z ${TEMP_DIR:-} ]] || rm -rf -- "$TEMP_DIR"; }
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM
TEMP_DIR=$(mktemp -d)
printf 'OWNED_DIR=%s\n' "$TEMP_DIR"
sleep 5
```

### Sprint 2

```bash
#!/usr/bin/env bash
set -euo pipefail
CONFIG_FILE=${1:?Usage: script config_file}
[[ -r $CONFIG_FILE && -f $CONFIG_FILE ]] || { printf 'Unreadable configuration\n' >&2; exit 1; }
while IFS= read -r line || [[ -n $line ]]; do
    line=${line#"${line%%[![:space:]]*}"}
    line=${line%"${line##*[![:space:]]}"}
    [[ -z $line || $line == \#* ]] && continue
    if [[ $line =~ ^(BACKUP_DIR|MAX_BACKUPS|COMPRESSION|DEBUG)=([^[:cntrl:]]*)$ ]]; then
        printf '%s=%s\n' "${BASH_REMATCH[1]}" "${BASH_REMATCH[2]}"
    else
        printf 'Invalid literal setting: %s\n' "$line" >&2; exit 2
    fi
done < "$CONFIG_FILE"
```

### Sprint 3

```bash
log() {
    [[ $# == 2 ]] || return 2
    local level=$1 message=$2
    [[ ${LEVELS[$level]+yes} && ${LEVELS[${LOG_LEVEL:-}]+yes} ]] || return 2
    ((${LEVELS[$level]} >= ${LEVELS[$LOG_LEVEL]})) || return 0
    printf '[%s] [%s] %s\n' "$(date -u +%FT%TZ)" "$level" "$message" >&2
}
```

### Sprint 4

```bash
#!/usr/bin/env bash
set -euo pipefail
[[ $# == 1 && -n $1 ]] || { printf 'Usage: script literal_process_name\n' >&2; exit 2; }
pattern=$(printf '%s' "$1" | sed 's/[][\.^$*+?(){}|]/\\&/g')
if pids=$(pgrep -x -- "$pattern"); then
    printf 'Process %s running; PIDs: %s\n' "$1" "${pids//$'\n'/, }"
else
    status=$?
    if ((status == 1)); then printf 'Process %s not running\n' "$1"; exit 1; fi
    printf 'Process query failed (%s)\n' "$status" >&2; exit 2
fi
```

### Sprint 5

```bash
#!/usr/bin/env bash
set -euo pipefail
[[ $# == 2 && $2 =~ ^[0-9]{1,3}$ ]] || exit 2
threshold=$((10#$2)); ((threshold <= 100)) || exit 2
SEM06_DIR=$(realpath -- SEM06)
source "$SEM06_DIR/scripts/examples/monitor_examples.sh"
if usage=$(get_disk_usage "$1"); then :; else printf 'Disk sample unavailable\n' >&2; exit 2; fi
if ((usage >= threshold)); then
    printf 'ALERT: %s at %s%% (threshold: %s%%)\n' "$1" "$usage" "$threshold"; exit 1
fi
printf 'OK: %s at %s%%\n' "$1" "$usage"
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
