# Parsons Problems — CAPSTONE SEM06

> **Operating Systems** | ASE Bucharest - CSIE  
> Seminar 6: Integrated Projects (Monitor, Backup, Deployer)

---

## What Are Parsons Problems?

Students get scrambled code lines. Job: put them in order. Sounds simple—until you see the distractors.

**Why this works:**
- No syntax memorisation pressure
- Focus shifts to *logic* and *structure*
- Distractors expose common mistakes (you'll recognise yours)
- Faster than blank-page coding, deeper than multiple choice

> **Lab note:** Watch students struggle with PP-01's trap syntax. The distractor `trap cleanup() EXIT` catches about 40% of them. That parenthesis looks so natural to Python/JS developers.

### How to Solve These

1. Read the requirement
2. Identify the correct lines (some are traps!)
3. Arrange them properly
4. Double-check the order matters

---

## PP-01: Trap Handler for Cleanup

### The Task

Write a script that creates a temporary file, uses it, then deletes it automatically on exit—even if someone hits Ctrl+C.

### Scrambled Lines

```
A)  rm -f "$TEMP_FILE"
B)  TEMP_FILE=$(mktemp)
C)  trap cleanup EXIT INT
D)  #!/bin/bash
E)  cleanup() {
F)  echo "Processed data: $(cat "$TEMP_FILE")"
G)  echo "test data" > "$TEMP_FILE"
H)  }
```

### Distractors — These Look Right But Aren't

```
X1) trap 'cleanup' ON_EXIT          # ON_EXIT is made up. Use EXIT.
X2) TEMP_FILE = $(mktemp)           # Spaces kill assignments
X3) trap cleanup() EXIT             # No parentheses after function name
X4) rm "$TEMP_FILE" -f              # Works, but non-standard argument order
```

### Solution

```bash
#!/bin/bash

cleanup() {
    rm -f "$TEMP_FILE"
}

trap cleanup EXIT INT

TEMP_FILE=$(mktemp)
echo "test data" > "$TEMP_FILE"
echo "Processed data: $(cat "$TEMP_FILE")"
```

**Order:** D → E → A → H → C → B → G → F

**What this tests:**
- Function must exist before trap references it
- Trap syntax: no parentheses, signal names at end
- No spaces in assignments

---

## PP-02: Incremental Backup with find -newer

### The Task

Create a script that backs up only files modified since the last backup. Classic incremental pattern.

### Scrambled Lines

```
A)  find "$SOURCE" -newer "$TIMESTAMP_FILE" -type f -print0 | \
B)  tar czf "$BACKUP_FILE" -T -
C)  touch "$TIMESTAMP_FILE"
D)  #!/bin/bash
E)  TIMESTAMP_FILE="/var/backup/.last_backup"
F)  SOURCE="/home/user/documents"
G)  BACKUP_FILE="/var/backup/incremental_$(date +%Y%m%d).tar.gz"
H)  xargs -0 tar czf "$BACKUP_FILE"
```

### Distractors

```
X1) find "$SOURCE" --newer "$TIMESTAMP_FILE"   # Double dash doesn't exist
X2) find $SOURCE -newer $TIMESTAMP_FILE        # Missing quotes = broken on spaces
X3) tar czf $BACKUP_FILE < $(find ...)         # That's not how tar takes input
X4) BACKUP_FILE = "..."                        # The space curse strikes again
```

### Solution

```bash
#!/bin/bash

TIMESTAMP_FILE="/var/backup/.last_backup"
SOURCE="/home/user/documents"
BACKUP_FILE="/var/backup/incremental_$(date +%Y%m%d).tar.gz"

find "$SOURCE" -newer "$TIMESTAMP_FILE" -type f -print0 | \
    xargs -0 tar czf "$BACKUP_FILE"

touch "$TIMESTAMP_FILE"
```

**Order:** D → E → F → G → A → H → C

**What this tests:**
- `-newer` syntax (single dash)
- The `-print0 | xargs -0` pattern for filenames with spaces
- Timestamp update happens *after* successful backup

> **Common pitfall:** Students forget to `touch` the timestamp file initially. First run: "No files found!" Of course not—nothing is newer than a file that doesn't exist.

---

## PP-03: Health Check with Retry

### The Task

Write a function that pings a web server, retrying with exponential backoff if it fails.

### Scrambled Lines

```
A)  ((retry++))
B)  return 1
C)  check_health() {
D)  if curl -sf "$URL" > /dev/null; then
E)  local retry=0
F)  while [[ $retry -lt $MAX_RETRIES ]]; do
G)  sleep $((2 ** retry))
H)  return 0
I)  fi
J)  done
K)  }
L)  local MAX_RETRIES=3
M)  local URL="http://localhost:8080/health"
```

### Distractors

```
X1) if curl -sf $URL; then              # Unquoted URL will break on special chars
X2) while [ $retry < $MAX_RETRIES ]     # < is redirect in [ ], use -lt
X3) retry = $((retry + 1))              # Spaces. Again.
X4) sleep 2 * retry                     # Shell doesn't do math like that
```

### Solution

```bash
check_health() {
    local MAX_RETRIES=3
    local URL="http://localhost:8080/health"
    local retry=0
    
    while [[ $retry -lt $MAX_RETRIES ]]; do
        if curl -sf "$URL" > /dev/null; then
            return 0
        fi
        ((retry++))
        sleep $((2 ** retry))
    done
    return 1
}
```

**Order:** C → L → M → E → F → D → H → I → A → G → J → B → K

**What this tests:**
- `[[ ]]` with `-lt` for numeric comparison
- Exponential backoff: `$((2 ** retry))` gives 2, 4, 8...
- `local` variables inside functions

---

## PP-04: Source Libraries in Order

### The Task

Write the library loading section. Core library must load first—other modules depend on it.

### Scrambled Lines

```
A)  source "$LIB_DIR/utils.sh"
B)  source "$LIB_DIR/core.sh"
C)  for lib in "$LIB_DIR"/*.sh; do
D)  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
E)  LIB_DIR="$SCRIPT_DIR/lib"
F)  done
G)  #!/bin/bash
H)  source "$lib"
I)  source "$LIB_DIR/config.sh"
```

### Distractors

```
X1) SCRIPT_DIR=$(dirname $0)            # $0 doesn't resolve symlinks
X2) source $LIB_DIR/core.sh             # Unquoted path
X3) . "$LIB_DIR"/core.sh                # Quotes in weird place
X4) for lib in $LIB_DIR/*.sh; do        # Glob might work, but risky
```

### Solution

```bash
#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$SCRIPT_DIR/lib"

# Order matters: core first, then config, then utils
source "$LIB_DIR/core.sh"
source "$LIB_DIR/config.sh"
source "$LIB_DIR/utils.sh"
```

**Order:** G → D → E → B → I → A

**What this tests:**
- `BASH_SOURCE[0]` vs `$0` (symlink resolution)
- Explicit load order beats glob when dependencies exist
- Quoting paths with source

> **Lab note:** The `cd "$(dirname ...)" && pwd` dance looks ugly but handles edge cases. Shorter versions break with symlinks or spaces in paths.

---

## PP-05: Logging Function

### The Task

Build a logging function with timestamp and severity level.

### Scrambled Lines

```
A)  local level="$1"
B)  local message="$2"
C)  log() {
D)  local timestamp
E)  timestamp=$(date '+%Y-%m-%d %H:%M:%S')
F)  echo "[$timestamp] [$level] $message"
G)  }
H)  echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
```

### Distractors

```
X1) local level = "$1"                  # Spaces in local assignment too
X2) timestamp=`date '+%Y-%m-%d %H:%M:%S'`  # Works but deprecated
X3) echo [$timestamp] [$level] $message # Brackets get glob-expanded
X4) log() (                             # Parentheses create subshell
```

### Solution

```bash
log() {
    local level="$1"
    local message="$2"
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $message"
}

# Usage
log "INFO" "Script started"
log "ERROR" "Connection failed"
```

**Order:** C → A → B → D → E → F → G

**What this tests:**
- Positional parameters `$1`, `$2`
- `local` for function-scoped variables
- `$()` over backticks

---

## PP-06: Array and Iteration

### The Task

Loop through an array of servers and check each one.

### Scrambled Lines

```
A)  for server in "${SERVERS[@]}"; do
B)  done
C)  SERVERS=("web01" "web02" "db01")
D)  check_server "$server"
E)  echo "Checking: $server"
F)  #!/bin/bash
```

### Distractors

```
X1) for server in $SERVERS; do          # Gets only first element
X2) for server in ${SERVERS[@]}; do     # Without quotes, spaces break it
X3) SERVERS = ("web01" "web02")         # Assignment space curse
X4) for server in SERVERS[@]; do        # Missing $ and braces
```

### Solution

```bash
#!/bin/bash

SERVERS=("web01" "web02" "db01")

for server in "${SERVERS[@]}"; do
    echo "Checking: $server"
    check_server "$server"
done
```

**Order:** F → C → A → E → D → B

**What this tests:**
- Array declaration syntax
- The `"${ARRAY[@]}"` pattern (quotes matter!)
- Word splitting avoidance

---

## Summary: What Each Problem Tests

| Problem | Core Concept | Common Trap |
|---------|--------------|-------------|
| PP-01 | trap, cleanup | Parentheses in trap syntax |
| PP-02 | find -newer, xargs -0 | Double-dash flags |
| PP-03 | while loops, backoff | `<` vs `-lt` in conditions |
| PP-04 | source, BASH_SOURCE | $0 symlink problems |
| PP-05 | functions, local | Backticks vs $() |
| PP-06 | arrays, iteration | Unquoted array expansion |

---

## Using These in Class

1. **Solo work (5-7 min):** Students solve on paper
2. **Pair check (3 min):** Compare with neighbour
3. **Class discussion (5 min):** Why are distractors wrong?
4. **Live demo (5 min):** Run the solution, break it, fix it

### Tools

- **js-parsons:** http://js-parsons.github.io/
- **Runestone Interactive:** https://runestone.academy/
- **Old school:** Paper and whiteboard work fine

---

## References

- Parsons, D., & Haden, P. (2006). *Parson's programming puzzles*
- Ericson, B. J. (2017). *Parsons Problems for Learning*
- Brown & Wilson (2018). *Ten Quick Tips for Teaching Programming*

---

*Parsons Problems for SEM06 CAPSTONE — Operating Systems*  
*ASE Bucharest - CSIE | 2024-2025*
