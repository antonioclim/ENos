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

The inherited classroom percentage above is an unverified observation, not a demonstrated effect estimate. Valid alternatives are distinguished from semantically wrong distractors below.

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
B)  TEMP_FILE=$(mktemp) || exit 1
C)  trap cleanup EXIT; trap 'exit 130' INT; trap 'exit 143' TERM
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
X4) rm "$TEMP_FILE" -f              # Valid GNU alternative for this filename; not a semantic error
```

### Solution

```bash
#!/bin/bash

cleanup() {
    rm -f "$TEMP_FILE"
}

trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

TEMP_FILE=$(mktemp) || exit 1
echo "test data" > "$TEMP_FILE"
echo "Processed data: $(cat "$TEMP_FILE")"
```

**Order:** D → E → A → H → C → B → G → F

**What this tests:**
- A trap stores shell code when registered; the function must exist when the trap executes. Other dependency-respecting orders are valid
- Trap syntax: no parentheses, signal names at end
- No spaces in assignments

---

## PP-02: Incremental File Selection with find -newer

### The Task

Arrange the chunks to create **one** archive containing files modified since a committed checkpoint. The first run includes all regular files. This change-only exercise does not record deletion/rename history and is not a replacement for the GNU incremental chain in P03. The source must be quiescent during this bounded exercise; a live filesystem snapshot requires a separate mechanism.

`SOURCE`, `BACKUP_FILE` and `TIMESTAMP_FILE` are caller-provided paths inside an owned fixture. The archive and checkpoint directories already exist, are outside SOURCE and the archive name must not exist.

### Scrambled Chunks

```text
A) if [[ -f $TIMESTAMP_FILE ]]; then filter=(-newer "$TIMESTAMP_FILE"); fi
B) (cd -- "$SOURCE" && find . -type f "${filter[@]}" -print0) > "$work/files" || exit 1
C) mv -- "$stage" "$BACKUP_FILE" || exit 1
D) #!/usr/bin/env bash
E) work=$(mktemp -d) || exit 1; trap 'rm -rf -- "$work"; rm -f -- "${stage:-}" "${watermark:-}"' EXIT
F) declare -a filter=(); [[ ! -e $BACKUP_FILE && ! -L $BACKUP_FILE ]] || exit 1
G) stage=$(mktemp "${BACKUP_FILE}.part.XXXXXX") || exit 1; watermark=$(mktemp "${TIMESTAMP_FILE}.new.XXXXXX") || exit 1
H) tar -C "$SOURCE" --null --verbatim-files-from -T "$work/files" -czf "$stage" || exit 1
I) mv -- "$watermark" "$TIMESTAMP_FILE" || exit 1
```

### Solution

```bash
#!/usr/bin/env bash
# Inputs are owned fixture paths supplied by the caller.
: "${SOURCE:?}" "${BACKUP_FILE:?}" "${TIMESTAMP_FILE:?}"
[[ -d $SOURCE && ! -e $BACKUP_FILE && ! -L $BACKUP_FILE ]] || exit 1
work=$(mktemp -d) || exit 1
stage=''; watermark=''
trap 'rm -rf -- "$work"; rm -f -- "${stage:-}" "${watermark:-}"' EXIT
stage=$(mktemp "${BACKUP_FILE}.part.XXXXXX") || exit 1
watermark=$(mktemp "${TIMESTAMP_FILE}.new.XXXXXX") || exit 1
declare -a filter=()
if [[ -f $TIMESTAMP_FILE ]]; then filter=(-newer "$TIMESTAMP_FILE"); fi
(cd -- "$SOURCE" && find . -type f "${filter[@]}" -print0) > "$work/files" || exit 1
tar -C "$SOURCE" --null --verbatim-files-from -T "$work/files" -czf "$stage" || exit 1
tar -tzf "$stage" >/dev/null || exit 1
mv -- "$stage" "$BACKUP_FILE" || exit 1
mv -- "$watermark" "$TIMESTAMP_FILE" || exit 1
```

**Order:** D → F → E → G → A → B → H → C → I. The full solution adds explicit required-input and archive verification checks.

**What this tests:** NUL-delimited filenames (including spaces/newlines), one tar invocation, a start watermark committed only after success and failure propagation. A missing checkpoint means a full initial file selection. A no-change run produces a valid empty archive. Strictly equal timestamp boundaries require the stated quiescent source/clock-resolution assumption; this is not a live-snapshot consistency proof.

### Distractors and Valid Alternatives

```text
X1) find "$SOURCE" --newer "$TIMESTAMP_FILE"   # Not the specified GNU find primary
X2) find $SOURCE -newer $TIMESTAMP_FILE        # Unquoted expansion splits/globs
X3) find ... -print0 | xargs -0 tar czf "$BACKUP_FILE" # WRONG: separate batches can overwrite one archive
X4) BACKUP_FILE = "..."                       # Executes a command, not an assignment
```

---

## PP-03: Health Check with Retry

### The Task

Write a function that pings a web server, retrying with exponential backoff if it fails.

### Scrambled Lines

```
A)  retry=$((retry + 1))
B)  return 1
C)  check_health() {
D)  if curl --connect-timeout 1 --max-time 2 -sf "$URL" > /dev/null; then
E)  local retry=0
F)  while [[ $retry -lt $MAX_RETRIES ]]; do
G)  if ((retry < MAX_RETRIES)); then sleep "$((2 ** retry))"; fi
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
        if curl --connect-timeout 1 --max-time 2 -sf "$URL" > /dev/null; then
            return 0
        fi
        retry=$((retry + 1))
        if ((retry < MAX_RETRIES)); then sleep "$((2 ** retry))"; fi
    done
    return 1
}
```

**Order:** C → L → M → E → F → D → H → I → A → G → J → B → K

**What this tests:**
- `[[ ]]` with `-lt` for numeric comparison
- Exponential backoff: `$((2 ** retry))` gives delays of 2 and 4 seconds before the remaining attempts; no delay follows the final failure
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
X3) . "$LIB_DIR"/core.sh                # Valid equivalent to source; accept this alternative
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
- `BASH_SOURCE[0]` identifies the sourced file; it does not itself resolve the final symlink
- Explicit load order beats glob when dependencies exist
- Quoting paths with source

> **Lab note:** The quoted `BASH_SOURCE` pattern handles spaces and sourcing. This exercise assumes direct paths: arbitrary symlink launchers require explicit final-symlink resolution (as in the bundled runtime) before locating `lib`.

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
X2) timestamp=`date '+%Y-%m-%d %H:%M:%S'`  # Valid Bash syntax; $() is preferred for readable nesting
X3) echo [$timestamp] [$level] $message # Brackets get glob-expanded
X4) log() ( ... )                      # Valid alternative function body; state changes stay in its subshell
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
| PP-02 | find -newer, one NUL-aware tar invocation | Overwriting batches; premature watermark |
| PP-03 | while loops, backoff | `<` vs `-lt` in conditions |
| PP-04 | source, BASH_SOURCE | Source path versus final-symlink resolution |
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
- Ericson, B. J. (2017). *Parsons Problems for Learning* — inherited incomplete reference. The intended work requires author identification; no title, co-author or DOI is substituted automatically.
- Brown & Wilson (2018). *Ten Quick Tips for Teaching Programming*

---

*Parsons Problems for SEM06 CAPSTONE — Operating Systems*  
*ASE Bucharest - CSIE | 2024-2025*
