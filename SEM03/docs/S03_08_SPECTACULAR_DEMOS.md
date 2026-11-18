# Spectacular Demos - Seminar 03
## Operating Systems | Visual Demonstrations for Engagement

**Purpose**: Capturing attention and demonstrating the power of concepts
When: Hook at the beginning, transitions between sections, "wow" moment
**Principle**: "Show, don't tell" - visual > verbal

---

## DEMO LIST

| Demo | Moment | Duration | Impact |
|------|--------|----------|--------|
| D1: File System Explorer | Seminar Hook | 2 min | 🔥🔥🔥 |
| D2: Permission Visualizer | After permissions theory | 3 min | 🔥🔥 |
| D3: Live Cron Monitor | Cron section | 2 min | 🔥🔥 |
| D4: Disk Space Analyser | Anytime | 2 min | 🔥🔥🔥 |
| D5: Security Audit Live | Seminar end | 3 min | 🔥🔥🔥 |
| D6: Process Tree Visualizer | Optional | 2 min | 🔥 |

---

## D1: FILE SYSTEM EXPLORER (Hook Demo)

### Purpose
Demonstrates the power of `find` in a spectacular one-liner that analyses the system.

### The Script

```bash
#!/bin/bash
# S03_01_hook_demo.sh - File System Explorer
# Discover hidden secrets in the file system!

clear

# Colours
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'
BOLD='\033[1m'

# Title animation
echo -e "${CYAN}"
cat << "EOF"
    ╔═══════════════════════════════════════════════════════════╗
    ║     🔍 FILE SYSTEM EXPLORER - Powered by FIND 🔍         ║

╚═══════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"
sleep 1

# Typing animation function
type_text() {
    local text="$1"
    local delay="${2:-0.02}"
    for ((i=0; i<${#text}; i++)); do
        echo -n "${text:$i:1}"
        sleep $delay
    done
    echo ""
}

# Demo 1: Quick statistics
echo -e "\n${BOLD}${YELLOW}▸ Analyzing your file system...${NC}\n"
sleep 0.5

echo -e "${PURPLE}📊 Quick Statistics:${NC}"
echo -n "   Total files:      "
find /usr -type f 2>/dev/null | wc -l | xargs printf "%'d\n"
echo -n "   Total directories: "
find /usr -type d 2>/dev/null | wc -l | xargs printf "%'d\n"
echo -n "   Symbolic links:    "
find /usr -type l 2>/dev/null | wc -l | xargs printf "%'d\n"
sleep 1

# Demo 2: Top 10 largest files
echo -e "\n${PURPLE}📦 Top 10 Largest Files in /usr:${NC}"
echo -e "${CYAN}───────────────────────────────────────────────────${NC}"
find /usr -type f -printf '%s %p\n' 2>/dev/null | \
    sort -rn | head -10 | \
    while read size path; do
        size_mb=$(echo "scale=2; $size/1048576" | bc)
        bar_len=$(echo "$size_mb / 5" | bc)
        bar=$(printf '█%.0s' $(seq 1 $bar_len 2>/dev/null) 2>/dev/null || echo "█")
        printf "   ${GREEN}%8.2f MB${NC} │ ${YELLOW}%-20s${NC} │ %s\n" \
            "$size_mb" "$bar" "$(basename "$path")"
        sleep 0.1
    done

# Demo 3: Recent files
echo -e "\n${PURPLE}🕐 Files Modified in Last Hour:${NC}"
recent_count=$(find /var/log -type f -mmin -60 2>/dev/null | wc -l)
echo -e "   Found ${GREEN}$recent_count${NC} recently modified files"
find /var/log -type f -mmin -60 -printf '   %TH:%TM  %p\n' 2>/dev/null | head -5
sleep 1

# Demo 4: Extension distribution
echo -e "\n${PURPLE}📁 File Type Distribution:${NC}"
echo -e "${CYAN}───────────────────────────────────────────────────${NC}"
find /usr/share -type f -name "*.*" 2>/dev/null | \
    sed 's/.*\.//' | sort | uniq -c | sort -rn | head -8 | \
    while read count ext; do
        bar_len=$((count / 100))
        [ $bar_len -gt 30 ] && bar_len=30
        bar=$(printf '▓%.0s' $(seq 1 $bar_len))
        printf "   ${GREEN}%-6s${NC} │ %5d │ ${BLUE}%s${NC}\n" ".$ext" "$count" "$bar"


        sleep 0.05
    done

# Final
echo -e "\n${CYAN}"
cat << "EOF"
    ╔═══════════════════════════════════════════════════════════╗
    ║  ✨ All of this with just ONE command: find              ║
    ║     Let's explore find in depth today.               ║
    ╚═══════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"
```

> 💡 *I've had students who learned Bash in two weeks starting from zero — it's possible, with consistent practice.*


### Expected Output

```
╔═══════════════════════════════════════════════════════════╗
║     🔍 FILE SYSTEM EXPLORER - Powered by FIND 🔍         ║
╚═══════════════════════════════════════════════════════════╝

▸ Analyzing your file system...

📊 Quick Statistics:
   Total files:      123,456
   Total directories: 12,345
   Symbolic links:    1,234

📦 Top 10 Largest Files in /usr:
───────────────────────────────────────────────────────────
   125.30 MB │ █████████████████████ │ libLLVM-14.so.1
    89.42 MB │ ███████████████       │ chromium
    ...

🕐 Files Modified in Last Hour:
   Found 23 recently modified files
   14:32  /var/log/syslog
   ...

📁 File Type Distribution:
───────────────────────────────────────────────────────────
   .gz    │  2345 │ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
   .png   │  1234 │ ▓▓▓▓▓▓▓▓
   ...
```

---

## D2: PERMISSION VISUALIZER

### Purpose
Intuitive permission visualisation for quick understanding.

### The Script

```bash
#!/bin/bash
# S03_04_demo_permissions.sh - Permission Visualizer

clear

# Colours
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'
BOLD='\033[1m'
DIM='\033[2m'

echo -e "${BLUE}"
cat << "EOF"
    ╔═══════════════════════════════════════════════════════════╗
    ║        🔐 PERMISSION VISUALIZER 🔐                        ║
    ╚═══════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

# Permission visualisation function
visualize_perm() {
    local file="$1"
    local perms=$(stat -c %A "$file" 2>/dev/null)
    local octal=$(stat -c %a "$file" 2>/dev/null)
    local owner=$(stat -c %U "$file" 2>/dev/null)
    local group=$(stat -c %G "$file" 2>/dev/null)
    
    echo -e "\n${BOLD}📄 File: ${YELLOW}$file${NC}"
    echo -e "   ${DIM}Owner: $owner | Group: $group${NC}"
    echo ""
    
    # Graphical visualisation
    echo -e "   ┌─────────┬─────────┬─────────┬─────────┐"
    echo -e "   │  TYPE   │  OWNER  │  GROUP  │ OTHERS  │"
    echo -e "   ├─────────┼─────────┼─────────┼─────────┤"
    
    # Parse permissions
    type_char="${perms:0:1}"
    owner_perms="${perms:1:3}"
    group_perms="${perms:4:3}"
    other_perms="${perms:7:3}"
    
    # Type icon
    case $type_char in
        d) type_icon="📁 DIR" ;;
        l) type_icon="🔗 LNK" ;;
        -) type_icon="📄 FILE" ;;
        *) type_icon="❓ $type_char" ;;
    esac
    
    # Colour function for permissions
    color_perm() {
        local p="$1"
        local result=""
        for ((i=0; i<3; i++)); do
            char="${p:$i:1}"
            case $char in
                r) result+="${GREEN}R${NC}" ;;
                w) result+="${YELLOW}W${NC}" ;;
                x) result+="${RED}X${NC}" ;;
                s) result+="${RED}S${NC}" ;;
                S) result+="${DIM}S${NC}" ;;
                t) result+="${BLUE}T${NC}" ;;
                T) result+="${DIM}T${NC}" ;;
                -) result+="${DIM}-${NC}" ;;
            esac
        done
        echo -e "$result"
    }
    
    printf "   │ %-7s │   %b   │   %b   │   %b   │\n" \
        "$type_icon" \
        "$(color_perm "$owner_perms")" \
        "$(color_perm "$group_perms")" \
        "$(color_perm "$other_perms")"
    
    echo -e "   └─────────┴─────────┴─────────┴─────────┘"
    echo -e "   ${DIM}Octal: ${NC}${BOLD}$octal${NC} ${DIM}| String: $perms${NC}"
    
    # Explain octal
    ordinary=${octal: -3}
    owner_oct=$((8#${ordinary:0:1}))
    group_oct=$((8#${ordinary:1:1}))
    other_oct=$((8#${ordinary:2:1}))
    
    echo -e "\n   ${DIM}Octal breakdown:${NC}"
    printf "   Owner: %d = " $owner_oct
    [ $((owner_oct & 4)) -ne 0 ] && echo -n "r(4)" || echo -n "-(0)"
    [ $((owner_oct & 2)) -ne 0 ] && echo -n "+w(2)" || echo -n "+-(0)"
    [ $((owner_oct & 1)) -ne 0 ] && echo -n "+x(1)" || echo -n "+-(0)"
    echo ""
}

# Demo with different files
echo -e "${CYAN}Demo: Different permission patterns${NC}"

# Create test files
PERM_DEMO_DIR=$(mktemp -d "${TMPDIR:-/tmp}/enos-perm.XXXXXX") || exit 1
trap 'rm -rf -- "$PERM_DEMO_DIR"' EXIT
touch "$PERM_DEMO_DIR"/normal.txt
chmod 644 "$PERM_DEMO_DIR"/normal.txt

touch "$PERM_DEMO_DIR"/script.sh
chmod 755 "$PERM_DEMO_DIR"/script.sh

touch "$PERM_DEMO_DIR"/private.key
chmod 600 "$PERM_DEMO_DIR"/private.key

mkdir "$PERM_DEMO_DIR"/shared
chmod 2775 "$PERM_DEMO_DIR"/shared

# Visualise
for file in "$PERM_DEMO_DIR"/*; do
    visualize_perm "$file"
    sleep 0.5
done

# Comparison with important system files
echo -e "\n${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}System files comparison:${NC}"

for sysfile in /etc/passwd /etc/shadow /usr/bin/passwd /tmp; do
    [ -e "$sysfile" ] && visualize_perm "$sysfile"
    sleep 0.3
done

# Cleanup
rm -rf "$PERM_DEMO_DIR"

echo -e "\n${GREEN}✨ Notice the patterns:${NC}"
echo "   • Config files: 644 (owner writes, everyone reads)"
echo "   • Private keys: 600 (only owner accesses)"
echo "   • Scripts: 755 (everyone executes)"
echo "   • /etc/shadow: 640 (passwords protected!)"
echo "   • /usr/bin/passwd: has SUID bit (runs as root)"
```

---

## D3: LIVE CRON MONITOR

### Purpose
Demonstrates cron in action with real-time visual feedback.

### The Script

```bash
#!/bin/bash
# S03_05_demo_cron.sh - Live Cron Monitor
set -euo pipefail
# Running this example installs a temporary user crontab entry only with --install.
if [[ ${1:-} != --install || $# -ne 1 ]]; then
    echo "Usage: $0 --install (explicitly installs a temporary user cron job)"
    exit 2
fi
DEMO_CRON=$(mktemp -d "${TMPDIR:-/tmp}/enos-cron.XXXXXX") || exit 1
[[ $DEMO_CRON =~ ^/[A-Za-z0-9_./-]+$ ]] || { echo 'Unsupported cron path' >&2; exit 2; }
CRON_TAG="ENOS_DEMO_${DEMO_CRON##*/}"
installed=false
cleanup() {
    [[ -z ${TAIL_PID:-} ]] || kill "$TAIL_PID" 2>/dev/null || true
    if $installed; then
        if ! crontab -l > "$DEMO_CRON/current.crontab"; then
            echo "Cannot read crontab for cleanup; retained $DEMO_CRON for recovery." >&2
            return 1
        fi
        awk -v tag="# $CRON_TAG" '! (length($0) >= length(tag) && substr($0, length($0)-length(tag)+1) == tag)' \
            "$DEMO_CRON/current.crontab" > "$DEMO_CRON/after.crontab" || return 1
        crontab "$DEMO_CRON/after.crontab" || return 1
        installed=false
    fi
    rm -rf -- "$DEMO_CRON"
}
trap cleanup EXIT

clear

# Colours
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'
BOLD='\033[1m'

echo -e "${CYAN}"
cat << "EOF"
    ╔═══════════════════════════════════════════════════════════╗
    ║           ⏰ LIVE CRON MONITOR ⏰                          ║
    ╚═══════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

# Create a test job
TEST_LOG="$DEMO_CRON/cron.log"
TEST_SCRIPT="$DEMO_CRON/cron.sh"

cat > "$TEST_SCRIPT" << 'SCRIPT'
#!/bin/bash
LOG_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
echo "$(date '+%H:%M:%S') - ⚡ CRON JOB EXECUTED!" >> "$LOG_DIR/cron.log"
SCRIPT
chmod +x "$TEST_SCRIPT"

# Install temporary job
# Require a readable existing user crontab (which may be empty). Do not confuse
# a read/permission failure with an absent table and replace it with one demo job.
if ! crontab -l > "$DEMO_CRON/before.crontab"; then
    echo 'This demonstration requires a readable existing user crontab in a disposable lab account.' >&2
    exit 1
fi
{ cat "$DEMO_CRON/before.crontab"; printf '* * * * * "%s" # %s\n' "$TEST_SCRIPT" "$CRON_TAG"; } > "$DEMO_CRON/install.crontab"
crontab "$DEMO_CRON/install.crontab" || exit 1
installed=true

echo -e "${YELLOW}📋 Current crontab:${NC}"
crontab -l | tail -3
echo ""

echo -e "${GREEN}▸ Created test job that runs every minute${NC}"
echo -e "${GREEN}▸ Watching for execution...${NC}"
echo ""

# Show countdown until next minute
show_countdown() {
    local now=$(date +%S)
    local remaining=$((60 - 10#$now))
    
    echo -e "${CYAN}Next cron tick in:${NC}"
    while [ $remaining -gt 0 ]; do
        printf "\r   ${BOLD}%02d${NC} seconds " $remaining
        
        # Progress bar
        filled=$((60 - remaining))
        bar=""
        for ((i=0; i<60; i+=2)); do
            if [ $i -lt $filled ]; then
                bar+="█"
            else
                bar+="░"
            fi
        done
        echo -ne "[${GREEN}$bar${NC}]"
        
        sleep 1
        remaining=$((remaining - 1))
    done
    echo -e "\n\n${GREEN}⚡ TICK!${NC}"
}

# Log monitoring
monitor_log() {
    echo -e "\n${YELLOW}📊 Log output:${NC}"
    echo "─────────────────────────────────────"
    tail -f "$TEST_LOG" 2>/dev/null &
    TAIL_PID=$!
}

# Run demo
touch "$TEST_LOG"
monitor_log
show_countdown

# Wait for output to appear
sleep 2

# Cleanup
cleanup || exit 1
trap - EXIT

echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✨ Demo complete! Test job removed.${NC}"
echo ""
echo "Key takeaways:"
echo "  • Cron runs jobs at the START of each minute"
echo "  • Always use absolute paths in cron jobs"
echo "  • Log your cron job output for debugging"
```

---

This user-crontab example is not run by repository tests. Cleanup selects only the
unique marker created by this invocation; it preserves unrelated lines of every length.
A read failure aborts installation or cleanup rather than replacing the current table.
An existing readable user crontab and a simple absolute temporary path are preconditions.
Reading and replacing a crontab is not an
atomic concurrent-edit protocol: use a disposable lab account without simultaneous
crontab edits, and do not treat this as a production scheduler-management design.

## D4: DISK SPACE ANALYZER

### Purpose
ncdu-like visualisation using only standard commands.

### The Script

```bash
#!/bin/bash
# S03_disk_analyser.sh - Disk Space Analyser

clear

# Colours
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'
BOLD='\033[1m'

TARGET="${1:-$HOME}"

echo -e "${CYAN}"
cat << "EOF"
    ╔═══════════════════════════════════════════════════════════╗
    ║          💾 DISK SPACE ANALYZER 💾                        ║
    ╚═══════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

echo -e "${YELLOW}Analyzing: $TARGET${NC}"
echo ""

# Total size
total_size=$(du -sh "$TARGET" 2>/dev/null | cut -f1)
echo -e "${BOLD}Total size: ${GREEN}$total_size${NC}"
echo ""

# Top directories by size
echo -e "${CYAN}📁 Top 10 Directories by Size:${NC}"
echo "─────────────────────────────────────────────────────────"

# Get max size for scaling
max_size=$(du -s "$TARGET"/* 2>/dev/null | sort -rn | head -1 | cut -f1)
[ -z "$max_size" ] || [ "$max_size" -eq 0 ] && max_size=1

du -sh "$TARGET"/* 2>/dev/null | sort -rh | head -10 | while read size path; do
    name=$(basename "$path")
    
    # Get numeric size for bar
    num_size=$(du -s "$path" 2>/dev/null | cut -f1)
    [ -z "$num_size" ] && num_size=0
    
    # Calculate bar length (max 30 chars)
    bar_len=$((num_size * 30 / max_size))
    [ $bar_len -gt 30 ] && bar_len=30
    [ $bar_len -lt 1 ] && bar_len=1
    
    # Colour based on size
    if [ $bar_len -gt 20 ]; then
        color=$RED
    elif [ $bar_len -gt 10 ]; then
        color=$YELLOW
    else
        color=$GREEN
    fi
    
    # Create bar
    bar=$(printf '█%.0s' $(seq 1 $bar_len))
    empty=$(printf '░%.0s' $(seq 1 $((30 - bar_len))) 2>/dev/null)
    
    # Type indicator
    if [ -d "$path" ]; then
        icon="📁"
    else
        icon="📄"
    fi
    
    printf "%s ${BOLD}%8s${NC} │${color}%s${NC}%s│ %s\n" \
        "$icon" "$size" "$bar" "$empty" "$name"
done

echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# File type breakdown
echo -e "\n${CYAN}📊 Space by File Type:${NC}"
echo "─────────────────────────────────────────────────────────"

# Temporary file for statistics
tmpfile=$(mktemp)

find "$TARGET" -type f -printf '%s %f\n' 2>/dev/null | \
    awk -F. '{if (NF>1) print $NF}' | \
    sort | uniq -c | sort -rn | head -8 > "$tmpfile"

while read count ext; do
    # Calculate approximate size
    total_bytes=$(find "$TARGET" -type f -name "*.$ext" -printf '%s\n' 2>/dev/null | \
        awk '{sum+=$1} END {print sum}')
    [ -z "$total_bytes" ] && total_bytes=0
    
    # Convert to human readable
    if [ $total_bytes -gt 1073741824 ]; then
        human=$(echo "scale=1; $total_bytes/1073741824" | bc)G
    elif [ $total_bytes -gt 1048576 ]; then
        human=$(echo "scale=1; $total_bytes/1048576" | bc)M
    elif [ $total_bytes -gt 1024 ]; then
        human=$(echo "scale=1; $total_bytes/1024" | bc)K
    else
        human="${total_bytes}B"
    fi
    
    printf "   ${GREEN}%-8s${NC} │ %6d files │ %8s\n" ".$ext" "$count" "$human"
done < "$tmpfile"

rm -f "$tmpfile"

echo ""
echo -e "${GREEN}💡 Tip: Run with path argument to analyse different directory${NC}"
echo "   Example: $0 /var/log"
```

---

## D5: SECURITY AUDIT LIVE

### Purpose
Real-time security audit demonstration.

### The Script

```bash
#!/bin/bash
# S03_security_audit_demo.sh - Live Security Audit

clear

# Colours
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m'
BOLD='\033[1m'

echo -e "${RED}"
cat << "EOF"
    ╔═══════════════════════════════════════════════════════════╗
    ║         🛡️  SECURITY AUDIT IN PROGRESS 🛡️                 ║
    ╚═══════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

# Scanner animation
scanner_animation() {
    local text="$1"
    echo -ne "${CYAN}[    ] $text${NC}\r"
    sleep 0.2
    for frame in "▰   " " ▰  " "  ▰ " "   ▰" "  ▰ " " ▰  "; do
        echo -ne "${CYAN}[$frame] $text${NC}\r"
        sleep 0.1
    done
}

report_finding() {
    local severity="$1"
    local message="$2"
    local color
    
    case $severity in
        HIGH) color=$RED; icon="🔴" ;;
        MEDIUM) color=$YELLOW; icon="🟡" ;;
        LOW) color=$GREEN; icon="🟢" ;;
        OK) color=$GREEN; icon="✅" ;;
    esac
    
    echo -e "${color}$icon [$severity]${NC} $message"
}

# Check 1: World-writable files
scanner_animation "Scanning for world-writable files..."
count=$(find /tmp /var/tmp -type f -perm -002 2>/dev/null | wc -l)
echo -e "${GREEN}[DONE]${NC} Scanning for world-writable files..."
if [ $count -gt 0 ]; then
    report_finding "MEDIUM" "Found $count world-writable files in /tmp"
else
    report_finding "OK" "No world-writable files found"
fi

# Check 2: SUID binaries
scanner_animation "Checking SUID binaries..."
suid_count=$(find /usr -type f -perm -4000 2>/dev/null | wc -l)
echo -e "${GREEN}[DONE]${NC} Checking SUID binaries..."
report_finding "LOW" "Found $suid_count SUID binaries (normal for system)"

# Check 3: Password file permissions
scanner_animation "Verifying /etc/passwd permissions..."
echo -e "${GREEN}[DONE]${NC} Verifying /etc/passwd permissions..."
passwd_perm=$(stat -c %a /etc/passwd 2>/dev/null)
if [ "$passwd_perm" = "644" ]; then
    report_finding "OK" "/etc/passwd has correct permissions (644)"
else
    report_finding "HIGH" "/etc/passwd has wrong permissions: $passwd_perm"
fi

# Check 4: Shadow file
scanner_animation "Verifying /etc/shadow permissions..."
echo -e "${GREEN}[DONE]${NC} Verifying /etc/shadow permissions..."
if [ -r /etc/shadow ]; then
    report_finding "HIGH" "/etc/shadow is readable by current user!"
else
    report_finding "OK" "/etc/shadow is properly protected"
fi

# Check 5: SSH config
scanner_animation "Checking SSH configuration..."
echo -e "${GREEN}[DONE]${NC} Checking SSH configuration..."
if [ -f ~/.ssh/id_rsa ]; then
    key_perm=$(stat -c %a ~/.ssh/id_rsa 2>/dev/null)
    if [ "$key_perm" = "600" ]; then
        report_finding "OK" "SSH private key has correct permissions"
    else
        report_finding "HIGH" "SSH private key has wrong permissions: $key_perm"
    fi
else
    report_finding "OK" "No SSH private key found (or not accessible)"
fi

# Check 6: Cron jobs
scanner_animation "Auditing cron jobs..."
echo -e "${GREEN}[DONE]${NC} Auditing cron jobs..."
cron_count=$(crontab -l 2>/dev/null | grep -v "^#" | grep -v "^$" | wc -l)
report_finding "LOW" "User has $cron_count active cron jobs"

# Summary
echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}AUDIT SUMMARY:${NC}"
echo ""
echo "   Checks performed: 6"
echo "   Using tools: find, stat, crontab"
echo ""
echo -e "${GREEN}💡 This is what system administrators do regularly!${NC}"
echo -e "   Permissions are the FIRST LINE OF DEFENSE."
```

---

## DEMO USAGE

### When to Use Each Demo

| Moment in Seminar | Recommended Demo |
|-------------------|------------------|
| Opening | D1: File System Explorer |
| After find theory | D4: Disk Space Analyser |
| After permissions theory | D2: Permission Visualizer |
| After cron theory | D3: Live Cron Monitor |
| Closing | D5: Security Audit |

### Quick Setup

```bash
# Download all demos
cd ~/live_demo
for demo in hook find_xargs getopts permissions cron; do
    chmod +x S03_*_demo_*.sh
done

# Quick test
./S03_01_hook_demo.sh
```

---

*Document generated for UES Bucharest - CSIE | Operating Systems | Seminar 3*


## Retained Author Notes

*(`find` combined with `-exec` is extremely useful. Once you master it, you can't do without it.)*
