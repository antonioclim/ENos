#!/bin/bash
#
# S03_05_demo_cron.sh - Cron and Automation Demonstration
#
# Operating Systems | ASE Bucharest - CSIE | Seminar 3
#
# DESCRIPTION:
#   Interactive script for demonstrating cron concepts:
#   - The crontab format (the 5 fields)
#   - Special characters (*, /, -, ,)
#   - Special strings (@reboot, @daily, etc.)
#   - Crontab management (crontab -e/-l/-r)
#   - Execution environment and PATH
#   - Logging and debugging
#   - Best practices and lock files
#   - The at command for one-time tasks
#
# USAGE:
#   ./S03_05_demo_cron.sh              # Complete interactive mode
#   ./S03_05_demo_cron.sh -s NUM       # Specific section (1-8)
#   ./S03_05_demo_cron.sh -i           # Interactive mode with pauses
#   ./S03_05_demo_cron.sh --generator  # Tool: cron expression generator
#   ./S03_05_demo_cron.sh --validator  # Tool: expression validator/explainer
#   ./S03_05_demo_cron.sh --monitor    # Tool: live cron jobs monitor
#   ./S03_05_demo_cron.sh -c           # Cleanup demo environment
#
# AUTHOR: OS Team | VERSION: 1.0 | DATE: 2025
#

set -e

#
# COLOUR CONFIGURATION AND GLOBAL VARIABLES
#

# Colours
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
GRAY='\033[0;90m'
BOLD='\033[1m'
DIM='\033[2m'
RESET='\033[0m'

# Colours for importance levels
INFO="${CYAN}"
SUCCESS="${GREEN}"
WARNING="${YELLOW}"
DANGER="${RED}"
CONCEPT="${MAGENTA}"
CODE="${WHITE}"

# Directories and files
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
CRON_VALIDATOR="$SCRIPT_DIR/../python/S03_cron_expression.py"
DEMO_DIR="$HOME/cron_demo_lab"
LOG_DIR="$DEMO_DIR/logs"
SCRIPTS_DIR="$DEMO_DIR/scripts"
BACKUP_DIR="$DEMO_DIR/backups"
LOCK_DIR="$DEMO_DIR/locks"

# Interactive mode
INTERACTIVE=false

# Section number for specific run
SECTION_NUM=0

#
# DISPLAY UTILITY FUNCTIONS
#

print_header() {
    local title="$1"
    echo ""
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════════════════════╗${RESET}"
    printf "${CYAN}║${RESET} ${BOLD}${WHITE}%-76s${RESET} ${CYAN}║${RESET}\n" "$title"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════════════════════╝${RESET}"
    echo ""
}

print_subheader() {
    local title="$1"
    echo ""
    echo -e "${YELLOW}┌──────────────────────────────────────────────────────────────────────────────┐${RESET}"
    printf "${YELLOW}│${RESET} ${BOLD}%-76s${RESET} ${YELLOW}│${RESET}\n" "$title"
    echo -e "${YELLOW}└──────────────────────────────────────────────────────────────────────────────┘${RESET}"
    echo ""
}

print_concept() {
    local concept="$1"
    echo -e "${CONCEPT}💡 CONCEPT: ${concept}${RESET}"
}

print_warning() {
    local msg="$1"
    echo -e "${WARNING}⚠️  Pitfall: ${msg}${RESET}"
}

print_danger() {
    local msg="$1"
    echo -e "${DANGER}☠️  DANGER: ${msg}${RESET}"
}

print_tip() {
    local tip="$1"
    echo -e "${GREEN}💡 TIP: ${tip}${RESET}"
}

print_command() {
    local cmd="$1"
    echo -e "${GRAY}┌─────────────────────────────────────────────────────────────────────────────┐${RESET}"
    echo -e "${GRAY}│${RESET} ${GREEN}\$${RESET} ${CODE}${cmd}${RESET}"
    echo -e "${GRAY}└─────────────────────────────────────────────────────────────────────────────┘${RESET}"
}

print_output() {
    echo -e "${DIM}$1${RESET}"
}

print_box() {
    local content="$1"
    local width=76
    echo -e "${BLUE}┌$(printf '─%.0s' $(seq 1 $width))┐${RESET}"
    while IFS= read -r line; do
        printf "${BLUE}│${RESET} %-74s ${BLUE}│${RESET}\n" "$line"
    done <<< "$content"
    echo -e "${BLUE}└$(printf '─%.0s' $(seq 1 $width))┘${RESET}"
}

run_demo() {
    local description="$1"
    local command="$2"
    
    echo ""
    echo -e "${GRAY}# ${description}${RESET}"
    print_command "$command"
    echo -e "${DIM}Output:${RESET}"
    eval "$command" 2>&1 | head -30 || true
    echo ""
}

pause_interactive() {
    if $INTERACTIVE; then
        echo ""
        echo -e "${CYAN}[Press ENTER to continue or 'q' to exit...]${RESET}"
        read -r response
        if [[ "$response" == "q" ]]; then
            echo "Demo interrupted."
            exit 0
        fi
    fi
}

ask_prediction() {
    local question="$1"
    echo ""
    echo -e "${YELLOW}🤔 PREDICTION: ${question}${RESET}"
    if $INTERACTIVE; then
        echo -e "${DIM}(Think about it before continuing...)${RESET}"
        read -r -p "Your answer: " answer
    fi
    echo ""
}

#
# SETUP AND CLEANUP FUNCTIONS
#

setup_demo_environment() {
    print_subheader "🔧 SETUP DEMONSTRATION ENVIRONMENT"
    
    echo "Creating directory structure for cron demo..."
    
    # Create directory structure
    mkdir -p "$DEMO_DIR"
    mkdir -p "$LOG_DIR"
    mkdir -p "$SCRIPTS_DIR"
    mkdir -p "$BACKUP_DIR"
    mkdir -p "$LOCK_DIR"
    
    echo -e "${GREEN}✓${RESET} Directories created in $DEMO_DIR"
    
    # Create demonstration scripts
    
    # Simple logging script
    cat > "$SCRIPTS_DIR/simple_logger.sh" << 'SCRIPT_EOF'
#!/bin/bash
# Simple logger script for cron demo
LOG_FILE="$HOME/cron_demo_lab/logs/simple.log"
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Script executed successfully" >> "$LOG_FILE"
SCRIPT_EOF
    chmod +x "$SCRIPTS_DIR/simple_logger.sh"
    
    # Script with environment variables
    cat > "$SCRIPTS_DIR/env_test.sh" << 'SCRIPT_EOF'
#!/bin/bash
# Test for environment variables in cron
LOG_FILE="$HOME/cron_demo_lab/logs/env_test.log"
{
    echo "=== $(date) ==="
    echo "PATH: $PATH"
    echo "HOME: $HOME"
    echo "USER: $USER"
    echo "SHELL: $SHELL"
    echo "PWD: $PWD"
    echo "LANG: $LANG"
    echo ""
} >> "$LOG_FILE"
SCRIPT_EOF
    chmod +x "$SCRIPTS_DIR/env_test.sh"
    
    # Backup script with timestamp
    cat > "$SCRIPTS_DIR/backup_demo.sh" << 'SCRIPT_EOF'
#!/bin/bash
# Demo backup script with complete logging
set -e

BACKUP_DIR="$HOME/cron_demo_lab/backups"
LOG_FILE="$HOME/cron_demo_lab/logs/backup.log"
TIMESTAMP=$(date '+%Y%m%d_%H%M%S')

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

log "START: Backup process initiated"

# Simulate backup
mkdir -p "$BACKUP_DIR/backup_$TIMESTAMP"
echo "Backup data for $TIMESTAMP" > "$BACKUP_DIR/backup_$TIMESTAMP/data.txt"

log "SUCCESS: Backup completed - backup_$TIMESTAMP"
log "END: Process finalised"
SCRIPT_EOF
    chmod +x "$SCRIPTS_DIR/backup_demo.sh"
    
    # Script with lock file to prevent simultaneous executions
    cat > "$SCRIPTS_DIR/locked_task.sh" << 'SCRIPT_EOF'
#!/bin/bash
# Demo script with lock file to prevent simultaneous executions
LOCK_FILE="$HOME/cron_demo_lab/locks/task.lock"
LOG_FILE="$HOME/cron_demo_lab/logs/locked_task.log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# Check and create lock
if [ -f "$LOCK_FILE" ]; then
    PID=$(cat "$LOCK_FILE")
    if ps -p "$PID" > /dev/null 2>&1; then
        log "SKIP: Another instance running (PID: $PID)"
        exit 0
    else
        log "WARN: Stale lock file found, removing"
        rm -f "$LOCK_FILE"
    fi
fi

# Create lock file
echo $$ > "$LOCK_FILE"
trap "rm -f '$LOCK_FILE'" EXIT

log "START: Task initiated (PID: $$)"

# Simulate long task
sleep 5

log "END: Task completed"
SCRIPT_EOF
    chmod +x "$SCRIPTS_DIR/locked_task.sh"
    
    # Script with flock for more solid locking
    cat > "$SCRIPTS_DIR/flock_task.sh" << 'SCRIPT_EOF'
#!/bin/bash
# Demo script with flock for atomic locking
LOCK_FILE="$HOME/cron_demo_lab/locks/flock.lock"
LOG_FILE="$HOME/cron_demo_lab/logs/flock_task.log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# Try to acquire lock (non-blocking)
exec 200>"$LOCK_FILE"
if ! flock -n 200; then
    log "SKIP: Could not acquire lock"
    exit 0
fi

log "START: Task with flock initiated (PID: $$)"

# Simulate work
sleep 3
echo "Work done at $(date)" >> "$HOME/cron_demo_lab/logs/flock_output.log"

log "END: Task completed"
SCRIPT_EOF
    chmod +x "$SCRIPTS_DIR/flock_task.sh"
    
    # Script for cleaning up old files
    cat > "$SCRIPTS_DIR/cleanup_old.sh" << 'SCRIPT_EOF'
#!/bin/bash
# Demo cleanup for old files
BACKUP_DIR="$HOME/cron_demo_lab/backups"
LOG_FILE="$HOME/cron_demo_lab/logs/cleanup.log"
DAYS_OLD=7

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

log "START: Cleanup files older than $DAYS_OLD days"

count=0
while IFS= read -r -d '' file; do
    log "DELETE: $file"
    rm -rf "$file"
    count=$((count + 1)) || true
done < <(find "$BACKUP_DIR" -maxdepth 1 -type d -name "backup_*" -mtime +$DAYS_OLD -print0 2>/dev/null)

log "END: $count directories deleted"
SCRIPT_EOF
    chmod +x "$SCRIPTS_DIR/cleanup_old.sh"
    
    # Notification script (simulation)
    cat > "$SCRIPTS_DIR/notify.sh" << 'SCRIPT_EOF'
#!/bin/bash
# Demo notification script
MESSAGE="${1:-Cron notification}"
LOG_FILE="$HOME/cron_demo_lab/logs/notifications.log"

echo "[$(date '+%Y-%m-%d %H:%M:%S')] NOTIFY: $MESSAGE" >> "$LOG_FILE"

# In reality, this would be:
# - send email: mail -s "Subject" user@domain.com
# - send slack: curl -X POST -H 'Content-type: application/json' --data '{"text":"'$MESSAGE'"}' URL
# - desktop notification: notify-send "$MESSAGE"
SCRIPT_EOF
    chmod +x "$SCRIPTS_DIR/notify.sh"
    
    # Initialise log files
    touch "$LOG_DIR/simple.log"
    touch "$LOG_DIR/env_test.log"
    touch "$LOG_DIR/backup.log"
    touch "$LOG_DIR/locked_task.log"
    touch "$LOG_DIR/flock_task.log"
    touch "$LOG_DIR/cleanup.log"
    touch "$LOG_DIR/notifications.log"
    
    echo -e "${GREEN}✓${RESET} Demo scripts created in $SCRIPTS_DIR"
    
    # List structure
    echo ""
    echo "Structure created:"
    tree "$DEMO_DIR" 2>/dev/null || find "$DEMO_DIR" -type f | head -20
    
    echo ""
    echo -e "${SUCCESS}✅ Demo environment ready!${RESET}"
}

cleanup_demo() {
    print_subheader "🧹 CLEANUP DEMONSTRATION ENVIRONMENT"
    
    if [ -d "$DEMO_DIR" ]; then
        echo "Deleting $DEMO_DIR..."
        rm -rf "$DEMO_DIR"
        echo -e "${GREEN}✓${RESET} Demo directory deleted"
    else
        echo "Demo directory does not exist."
    fi
    
    # Display current crontab (for verification)
    echo ""
    echo "Current crontab (for manual verification):"
    crontab -l 2>/dev/null || echo "  (empty)"
    
    echo ""
    print_warning "Crontab was NOT modified by cleanup."
    echo "  To delete crontab entries, use: crontab -e"
    echo ""
}

#
# SECTION 1: INTRODUCTION TO CRON
#

section_1_introduction() {
    print_header "SECTION 1: INTRODUCTION TO CRON"
    
    print_concept "What is cron?"
    
    cat << 'EOF'

┌─────────────────────────────────────────────────────────────────────────────┐
│                         🕐 WHAT IS CRON?                                    │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  cron = "χρόνος" (chronos) = time in Greek                                  │
│                                                                             │
│  • Daemon (background service) that executes scheduled commands             │
│  • Runs continuously in the background                                      │
│  • Checks every minute whether something needs to be executed               │
│  • Available on all Unix/Linux systems                                      │
│                                                                             │
├─────────────────────────────────────────────────────────────────────────────┤
│  COMPONENTS:                                                                │
│                                                                             │
│  ┌──────────────┐      ┌──────────────┐      ┌──────────────┐              │
│  │  crond       │ ───► │  crontab     │ ───► │  commands    │              │
│  │  (daemon)    │      │  (table)     │      │  executed    │              │
│  └──────────────┘      └──────────────┘      └──────────────┘              │
│                                                                             │
│  crond   = the process running in the background                            │
│  crontab = the table with scheduled jobs                                    │
│  jobs    = the commands/scripts that are executed                           │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘

EOF

    pause_interactive
    
    print_subheader "Verifying cron service"
    
    run_demo "Check if cron service is running" \
        "systemctl status cron 2>/dev/null | head -5 || service cron status 2>/dev/null | head -3 || echo 'Check manually with: ps aux | grep cron'"
    
    run_demo "Cron process in system" \
        "ps aux | grep -E '[c]ron' | head -5"
    
    pause_interactive
    
    print_subheader "Important cron locations"
    
    cat << 'EOF'

┌─────────────────────────────────────────────────────────────────────────────┐
│                    📂 CRON LOCATIONS IN SYSTEM                              │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  CONFIGURATION FILES:                                                       │
│  ├── /etc/crontab           ← System crontab (requires user specified)     │
│  ├── /var/spool/cron/       ← Per-user crontabs                            │
│  │   └── crontabs/USER                                                      │
│  └── /etc/cron.d/           ← Additional system crontabs                   │
│                                                                             │
│  PREDEFINED DIRECTORIES (drop-in):                                          │
│  ├── /etc/cron.hourly/      ← Scripts run every hour                       │
│  ├── /etc/cron.daily/       ← Scripts run daily                            │
│  ├── /etc/cron.weekly/      ← Scripts run weekly                           │
│  └── /etc/cron.monthly/     ← Scripts run monthly                          │
│                                                                             │
│  LOGS:                                                                      │
│  ├── /var/log/syslog        ← General log (includes cron)                  │
│  └── /var/log/cron.log      ← Dedicated cron log (if configured)           │
│                                                                             │
├─────────────────────────────────────────────────────────────────────────────┤
│  💡 TIP: Scripts in cron.daily/ etc. are run by anacron                    │
│         (which catches up on missed jobs when system was off)              │
└─────────────────────────────────────────────────────────────────────────────┘

EOF

    run_demo "Contents of /etc/crontab (system crontab)" \
        "cat /etc/crontab 2>/dev/null | head -20 || echo 'File may be missing or require sudo'"
    
    run_demo "What scripts are in cron.daily?" \
        "ls -la /etc/cron.daily/ 2>/dev/null | head -10"
    
    pause_interactive
    
    print_subheader "Difference: user crontab vs /etc/crontab"
    
    cat << 'EOF'

┌─────────────────────────────────────────────────────────────────────────────┐
│          USER CRONTAB vs SYSTEM CRONTAB                                     │
├──────────────────────────────────┬──────────────────────────────────────────┤
│  crontab -e (USER)               │  /etc/crontab (SYSTEM)                   │
├──────────────────────────────────┼──────────────────────────────────────────┤
│  • Per user                      │  • For the entire system                 │
│  • Managed with crontab command  │  • Edited directly with sudo             │
│  • Does NOT specify user         │  • MUST specify user                     │
│  • Stored in /var/spool/cron     │  • In /etc/crontab or /etc/cron.d/       │
│                                  │                                          │
│  FORMAT (6 fields):              │  FORMAT (7 fields):                      │
│  min hour dom mon dow command    │  min hour dom mon dow USER command       │
│                                  │                    ^^^^                  │
│  * * * * * /path/to/script       │  * * * * * root /path/to/script          │
│                                  │                                          │
├──────────────────────────────────┴──────────────────────────────────────────┤
│  ⚠️  Pitfall: In /etc/crontab you must specify the USER!                    │
│                                                                             │
│  # WRONG in /etc/crontab (missing user):                                    │
│  0 3 * * * /root/backup.sh                                                  │
│                                                                             │
│  # CORRECT in /etc/crontab:                                                 │
│  0 3 * * * root /root/backup.sh                                             │
└─────────────────────────────────────────────────────────────────────────────┘

EOF

    pause_interactive
    
    print_subheader "Why cron? Use cases"
    
    cat << 'EOF'

┌─────────────────────────────────────────────────────────────────────────────┐
│                   🎯 CRON USE CASES                                         │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  📦 BACKUP AND ARCHIVING                                                    │
│     • Daily database backups                                                │
│     • File synchronisation with rsync                                       │
│     • Log archiving and rotation                                            │
│                                                                             │
│  🧹 SYSTEM MAINTENANCE                                                      │
│     • Cleanup temporary files                                               │
│     • Update databases (updatedb for locate)                                │
│     • Security checks                                                       │
│     • Log rotation and compression                                          │
│                                                                             │
│  📊 REPORTS AND MONITORING                                                  │
│     • Generate daily/weekly reports                                         │
│     • Monitor disk space                                                    │
│     • Health checks for services                                            │
│     • Alerting when something is wrong                                      │
│                                                                             │
│  📧 COMMUNICATION                                                           │
│     • Sending scheduled emails                                              │
│     • Periodic notifications                                                │
│     • Data synchronisation with external APIs                               │
│                                                                             │
│  🔄 SYNCHRONISATION                                                         │
│     • Pull data from remote servers                                         │
│     • Update RSS/news feeds                                                 │
│     • Synchronise with cloud storage                                        │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘

EOF

    echo -e "${SUCCESS}✅ Section 1 complete!${RESET}"
    pause_interactive
}

#
# SECTION 2: CRONTAB FORMAT (THE 5 FIELDS)
#

section_2_crontab_format() {
    print_header "SECTION 2: CRONTAB FORMAT - THE 5 FIELDS"
    
    print_concept "Structure of a crontab entry"
    
    cat << 'EOF'

┌─────────────────────────────────────────────────────────────────────────────┐
│                     📋 CRONTAB FORMAT                                       │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌───────────────── minute (0 - 59)                                         │
│  │ ┌─────────────── hour (0 - 23)                                           │
│  │ │ ┌───────────── day of month (1 - 31)                                   │
│  │ │ │ ┌─────────── month (1 - 12 or jan-dec)                               │
│  │ │ │ │ ┌───────── day of week (0 - 7, 0 and 7 = Sunday)                   │
│  │ │ │ │ │                                                                   │
│  │ │ │ │ │                                                                   │
│  * * * * *  command_to_execute                                               │
│                                                                             │
├─────────────────────────────────────────────────────────────────────────────┤
│  FIELD        │  VALUES        │  DESCRIPTION                               │
│──────────────┼────────────────┼─────────────────────────────────────────────│
│  Minute       │  0-59          │  At which minute to execute                 │
│  Hour         │  0-23          │  At which hour (24h format)                 │
│  Day of month │  1-31          │  On which day of the month                  │
│  Month        │  1-12          │  In which month (or jan, feb, mar...)       │
│  Day of week  │  0-7           │  On which day of the week (0,7=Sun)         │
└─────────────────────────────────────────────────────────────────────────────┘

EOF

    pause_interactive
    
    print_subheader "Visual diagram of fields"
    
    cat << 'EOF'

        ┌─────────────────────────────────────────────────────────────────────┐
        │                    ANATOMY OF A CRON ENTRY                          │
        ├─────────────────────────────────────────────────────────────────────┤
        │                                                                     │
        │         30    8    15    6    1    /home/user/backup.sh             │
        │          │    │     │    │    │              │                      │
        │          │    │     │    │    │              └── Command/Script     │
        │          │    │     │    │    │                                     │
        │          │    │     │    │    └────── Day of week: 1 = Monday       │
        │          │    │     │    │                                          │
        │          │    │     │    └─────────── Month: 6 = June               │
        │          │    │     │                                               │
        │          │    │     └──────────────── Day of month: 15              │
        │          │    │                                                     │
        │          │    └────────────────────── Hour: 8 (8:00 AM)             │
        │          │                                                          │
        │          └─────────────────────────── Minute: 30                    │
        │                                                                     │
        │   🗓️ Executes: June 15 OR any Monday in June, at 8:30 AM            │
        │                                                                     │
        └─────────────────────────────────────────────────────────────────────┘

   ⚠️  Note: When both "day of month" AND "day of week" are specified,
             the job executes when EITHER condition is met (OR)!

EOF

    pause_interactive
    
    print_subheader "Basic examples"
    
    cat << 'EOF'

┌─────────────────────────────────────────────────────────────────────────────┐
│                      🕐 CRON SCHEDULE EXAMPLES                              │
├────────────────────────┬────────────────────────────────────────────────────┤
│  EXPRESSION            │  MEANING                                           │
├────────────────────────┼────────────────────────────────────────────────────┤
│  0 * * * *             │  At minute 0 of every hour (XX:00)                 │
│  30 8 * * *            │  Daily at 8:30 AM                                  │
│  0 0 * * *             │  Daily at midnight (00:00)                         │
│  0 12 * * *            │  Daily at noon (12:00)                             │
│  0 0 1 * *             │  On the first day of every month, at 00:00         │
│  0 0 * * 0             │  Every Sunday at 00:00                             │
│  0 0 * * 1             │  Every Monday at 00:00                             │
│  0 0 1 1 *             │  On 1st January at 00:00 (New Year!)               │
│  30 4 1,15 * *         │  On 1st and 15th of the month, at 4:30 AM          │
│  0 9-17 * * 1-5        │  Every hour, 9-17, Monday-Friday                   │
└────────────────────────┴────────────────────────────────────────────────────┘

EOF

    pause_interactive
    
    ask_prediction "What does: 0 0 * * * mean?"
    
    echo -e "${GREEN}Answer:${RESET} Daily at midnight (00:00)"
    echo "  - Minute: 0"
    echo "  - Hour: 0"  
    echo "  - Day of month: any (*)"
    echo "  - Month: any (*)"
    echo "  - Day of week: any (*)"
    
    pause_interactive
    
    ask_prediction "What does: 30 4 1,15 * * mean?"
    
    echo -e "${GREEN}Answer:${RESET} On 1st and 15th of every month, at 4:30 AM"
    echo "  - Minute: 30"
    echo "  - Hour: 4"
    echo "  - Day of month: 1 AND 15 (comma list)"
    echo "  - Month: any (*)"
    echo "  - Day of week: any (*)"
    
    pause_interactive
    
    print_subheader "Days of the week - watch the conventions!"
    
    cat << 'EOF'

┌─────────────────────────────────────────────────────────────────────────────┐
│                   📅 DAYS OF THE WEEK                                       │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│   NUMBER    │  DAY                 │  NOTE                                  │
│  ──────────┼────────────────────┼────────────────────────────────────────── │
│     0      │  Sunday              │  ← Both 0 and 7 = Sunday                │
│     1      │  Monday              │                                         │
│     2      │  Tuesday             │                                         │
│     3      │  Wednesday           │                                         │
│     4      │  Thursday            │                                         │
│     5      │  Friday              │                                         │
│     6      │  Saturday            │                                         │
│     7      │  Sunday              │  ← Both 0 and 7 = Sunday                │
│                                                                             │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│   ALTERNATIVE: You can use names (first 3 letters, case insensitive):       │
│                                                                             │
│   sun, mon, tue, wed, thu, fri, sat                                         │
│                                                                             │
│   EXAMPLES:                                                                 │
│   0 0 * * sun      = Sunday at midnight                                     │
│   0 9 * * mon-fri  = Monday-Friday at 9:00                                  │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘

EOF

    pause_interactive
    
    print_subheader "Months of the year"
    
    cat << 'EOF'

┌─────────────────────────────────────────────────────────────────────────────┐
│                      📆 MONTHS OF THE YEAR                                  │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│   NUMBER │ MONTH       │ ABBREVIATION   NUMBER │ MONTH       │ ABBREVIATION│
│   ──────┼─────────────┼──────────       ───────┼─────────────┼───────────  │
│      1  │ January     │ jan                 7  │ July        │ jul         │
│      2  │ February    │ feb                 8  │ August      │ aug         │
│      3  │ March       │ mar                 9  │ September   │ sep         │
│      4  │ April       │ apr                10  │ October     │ oct         │
│      5  │ May         │ may                11  │ November    │ nov         │
│      6  │ June        │ jun                12  │ December    │ dec         │
│                                                                             │
│   EXAMPLES:                                                                 │
│   0 0 1 jan *     = 1st January at 00:00                                    │
│   0 0 1 1,4,7,10 *  = First day of each quarter                               │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘

EOF

    echo -e "${SUCCESS}✅ Section 2 complete!${RESET}"
    pause_interactive
}

#
# SECTION 3: SPECIAL CHARACTERS
#

section_3_special_characters() {
    print_header "SECTION 3: SPECIAL CHARACTERS IN CRON"
    
    print_concept "Asterisk (*) - wildcard for any value"
    
    cat << 'EOF'

┌─────────────────────────────────────────────────────────────────────────────┐
│                       ✱ ASTERISK (*)                                        │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│   * = "any possible value in this field"                                    │
│                                                                             │
│   EXAMPLES:                                                                 │
│                                                                             │
│   * * * * *  cmd       = Every minute                                       │
│               │                                                             │
│               └── All fields are *, so ANY moment                           │
│                                                                             │
│   0 * * * *  cmd       = At minute 0 of every hour                          │
│                 │                                                           │
│                 └── Hour can be any (0-23)                                  │
│                                                                             │
│   0 0 * * *  cmd       = Daily at midnight                                  │
│                   │                                                         │
│                   └── Any day of month, any month, any day of week          │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘

EOF

    pause_interactive
    
    print_concept "Slash (/) - interval/step"
    
    cat << 'EOF'

┌─────────────────────────────────────────────────────────────────────────────┐
│                        / SLASH (STEP/INTERVAL)                              │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│   */N = "every N units"                                                     │
│                                                                             │
│   EXAMPLES:                                                                 │
│                                                                             │
│   */5 * * * *  cmd     = Every 5 minutes                                    │
│     │                                                                       │
│     └── Minute: 0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55               │
│                                                                             │
│   0 */2 * * *  cmd     = Every 2 hours (at minute 0)                        │
│       │                                                                     │
│       └── Hour: 0, 2, 4, 6, 8, 10, 12, 14, 16, 18, 20, 22                   │
│                                                                             │
│   0 0 */3 * *  cmd     = Days 1,4,7,… each month (step resets), at midnight                          │
│         │                                                                   │
│         └── Day: 1, 4, 7, 10, 13, 16, 19, 22, 25, 28, 31                    │
│                                                                             │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│   ⚠️  Pitfall: */5 does NOT mean "5 minutes AFTER last execution"!          │
│                                                                             │
│   */5 = minutes that are MULTIPLES of 5 (0, 5, 10, 15...)                   │
│                                                                             │
│   If server starts at 12:07, first */5 job will run at 12:10,              │
│   NOT at 12:12 (7+5)!                                                       │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘

EOF

    pause_interactive
    
    ask_prediction "What does: */15 * * * * do? At which minutes does it execute?"
    
    echo -e "${GREEN}Answer:${RESET} Every 15 minutes"
    echo "  Minutes: 0, 15, 30, 45 of every hour"
    echo "  → 4 executions per hour, 96 executions per day"
    
    pause_interactive
    
    print_concept "Comma (,) - list of values"
    
    cat << 'EOF'

┌─────────────────────────────────────────────────────────────────────────────┐
│                       , COMMA (LIST)                                        │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│   val1,val2,val3 = "execute for any of the specified values"                │
│                                                                             │
│   EXAMPLES:                                                                 │
│                                                                             │
│   0 8,12,18 * * *  cmd    = At 8:00, 12:00 and 18:00 daily                  │
│       │                                                                     │
│       └── 3 specific hours in a list                                        │
│                                                                             │
│   0 0 1,15 * *  cmd       = On 1st and 15th of the month                    │
│         │                                                                   │
│         └── 2 specific days                                                 │
│                                                                             │
│   0 0 * * 1,3,5  cmd      = Monday, Wednesday, Friday                       │
│             │                                                               │
│             └── 3 days of the week                                          │
│                                                                             │
│   0 9 1 1,4,7,10 *  cmd   = On 1st of months Jan, Apr, Jul, Oct             │
│             │               (start of each quarter, assuming                │
│             │               day of month = implicitly first or other)       │
│             └── 4 specific months                                           │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘

EOF

    pause_interactive
    
    print_concept "Hyphen (-) - continuous range"
    
    cat << 'EOF'

┌─────────────────────────────────────────────────────────────────────────────┐
│                       - HYPHEN (INTERVAL/RANGE)                             │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│   start-end = "all values from start to end (inclusive)"                    │
│                                                                             │
│   EXAMPLES:                                                                 │
│                                                                             │
│   0 9-17 * * *  cmd       = Every hour between 9:00 and 17:00               │
│       │                                                                     │
│       └── Hours: 9, 10, 11, 12, 13, 14, 15, 16, 17 (9 hours)               │
│                                                                             │
│   0 0 * * 1-5  cmd        = Monday to Friday (working days)                 │
│           │                                                                 │
│           └── Days: 1, 2, 3, 4, 5 (Mon-Fri)                                 │
│                                                                             │
│   */10 8-18 * * 1-5  cmd  = Every 10 min, 8-18, Mon-Fri                     │
│     │    │       │         (working hours!)                                 │
│     │    │       └── Only on working days                                   │
│     │    └── Only during working hours                                      │
│     └── At 10 minute intervals                                              │
│                                                                             │
│   0 0 1-7 * 1  cmd        = Days 1–7 OR every Monday                       │
│         │   │              (not a first-Monday expression)                     │
│         │   └── All Mondays (OR)                                                 │
│         └── All days 1–7 (OR)                                               │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘

EOF

    pause_interactive
    
    print_subheader "Operator combinations"
    
    cat << 'EOF'

┌─────────────────────────────────────────────────────────────────────────────┐
│                    🔀 COMPLEX COMBINATIONS                                  │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│   You can combine operators for more complex expressions:                   │
│                                                                             │
│   0,30 9-17 * * 1-5         = At minutes 0 and 30, hours 9-17, Mon-Fri      │
│   │     │       │                                                           │
│   │     │       └── Day range (1-5)                                         │
│   │     └── Hour range (9-17)                                               │
│   └── Minute list (0,30)                                                    │
│                                                                             │
│   0 */4 1,15 * *            = Every 4 hours, on 1st and 15th of month       │
│       │  │                                                                  │
│       │  └── Day list                                                       │
│       └── Hour step (0,4,8,12,16,20)                                        │
│                                                                             │
│   0-30/10 9 * * *           = At 9:00, 9:10, 9:20, 9:30                     │
│     │    │                     (step of 10 in range 0-30)                   │
│     └────┴── Range with step                                                │
│                                                                             │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│   ⚠️  SUBTLETY: Restricted DOM and DOW use OR (leading wildcard uses AND).        │
│                                                                             │
│   0 0 15 * 5            = On 15th of month OR on Fridays                    │
│         │   │                                                               │
│         │   └── Any Friday                                                  │
│         └── Any 15th                                                        │
│                                                                             │
│   This means it executes MUCH more often than you might think!             │
│   (4 or 5 Fridays plus the 15th if it is not already a Friday) │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘

EOF

    print_warning "Restricted DOM + restricted DOW use OR; a leading * field uses AND."
    
    echo ""
    echo "If you want ONLY the days when a specific date falls on a specific day,"
    echo "you need to use a script with conditional logic. First Monday example:"
    printf '%s\n' '0 0 * * 1 [ "$(date +\%d)" -le 7 ] && /path/to/job.sh'
    echo "The escaped percent is required in a crontab command; this example is not installed."
    
    pause_interactive
    
    print_subheader "Operator summary table"
    
    cat << 'EOF'

┌───────────┬─────────────────────────────────────────────────────────────────┐
│ OPERATOR  │ DESCRIPTION AND EXAMPLES                                        │
├───────────┼─────────────────────────────────────────────────────────────────┤
│    *      │ Any value                                                       │
│           │ * * * * *  = every minute                                       │
├───────────┼─────────────────────────────────────────────────────────────────┤
│    /      │ Step/Interval                                                   │
│           │ */5 = every 5 (0,5,10,15...)                                    │
│           │ 10-30/5 = in range 10-30, every 5 (10,15,20,25,30)              │
├───────────┼─────────────────────────────────────────────────────────────────┤
│    ,      │ List of values                                                  │
│           │ 1,15,30 = values 1, 15 and 30                                   │
├───────────┼─────────────────────────────────────────────────────────────────┤
│    -      │ Continuous range                                                │
│           │ 9-17 = from 9 to 17 inclusive                                   │
│           │ mon-fri = from Monday to Friday                                 │
├───────────┼─────────────────────────────────────────────────────────────────┤
│  L,W,#    │ ⚠️  Pitfall: These belong to other dialects (e.g. Quartz), not           │
│           │ the Debian/Vixie subset used here (nor POSIX).                           │
│           │ Check if your cron supports them.                               │
└───────────┴─────────────────────────────────────────────────────────────────┘

EOF

    echo -e "${SUCCESS}✅ Section 3 complete!${RESET}"
    pause_interactive
}

#
# SECTION 4: SPECIAL STRINGS
#

section_4_special_strings() {
    print_header "SECTION 4: SPECIAL STRINGS IN CRON"
    
    print_concept "Predefined shortcuts for common schedules"
    
    cat << 'EOF'

┌─────────────────────────────────────────────────────────────────────────────┐
│                    📌 CRON SPECIAL STRINGS                                  │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  Instead of writing the 5 fields, you can use these shortcuts:              │
│                                                                             │
│  ┌─────────────┬──────────────────┬───────────────────────────────────────┐ │
│  │  STRING     │  EQUIVALENT      │  DESCRIPTION                          │ │
│  ├─────────────┼──────────────────┼───────────────────────────────────────┤ │
│  │  @reboot    │  (at startup)    │  Once, at system boot                 │ │
│  │  @yearly    │  0 0 1 1 *       │  Annually, 1st January at 00:00       │ │
│  │  @annually  │  0 0 1 1 *       │  Synonym for @yearly                  │ │
│  │  @monthly   │  0 0 1 * *       │  Monthly, first day at 00:00          │ │
│  │  @weekly    │  0 0 * * 0       │  Weekly, Sunday at 00:00              │ │
│  │  @daily     │  0 0 * * *       │  Daily at midnight                    │ │
│  │  @midnight  │  0 0 * * *       │  Synonym for @daily                   │ │
│  │  @hourly    │  0 * * * *       │  Every hour, at minute 0              │ │
│  └─────────────┴──────────────────┴───────────────────────────────────────┘ │
│                                                                             │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  USAGE EXAMPLES:                                                            │
│                                                                             │
│  @reboot /home/user/start_service.sh                                        │
│  @daily /home/user/backup.sh                                                │
│  @hourly /home/user/check_health.sh                                         │
│  @weekly /home/user/send_report.sh                                          │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘

EOF

    pause_interactive
    
    print_subheader "@reboot - execution at system startup"
    
    cat << 'EOF'

┌─────────────────────────────────────────────────────────────────────────────┐
│                      🔄 @reboot - SPECIAL                                   │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  @reboot is UNIQUE among special strings:                                   │
│                                                                             │
│  • It is NOT a periodic schedule                                            │
│  • Executes ONCE after cron service starts                                  │
│  • Perfect for starting services/daemons                                    │
│                                                                             │
│  USE CASES:                                                                 │
│                                                                             │
│  @reboot /home/user/start_server.sh                                         │
│     └── Start a server at boot                                              │
│                                                                             │
│  @reboot sleep 60 && /home/user/monitor.sh                                  │
│     └── Wait 60 seconds after boot, then start                              │
│         (to let system stabilise)                                           │
│                                                                             │
│  @reboot screen -dmS myapp /home/user/myapp.sh                              │
│     └── Start application in a screen session                               │
│                                                                             │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ⚠️  Pitfall: @reboot executes when cron starts, NOT when OS starts.       │
│              Restart behaviour depends on daemon/distribution; test locally.                   │
│                                                                             │
│  💡 TIP: For persistent services, consider systemd instead of @reboot      │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘

EOF

    pause_interactive
    
    print_subheader "Comparison: strings vs equivalent expressions"
    
    echo ""
    echo "Which variant do you prefer?"
    echo ""
    
    cat << 'EOF'
  ┌───────────────────────────────────────────────────────────────────────────┐
  │  STRING VARIANT:               │  EXPRESSION VARIANT:                     │
  ├───────────────────────────────────────────────────────────────────────────┤
  │  @daily /path/to/backup.sh     │  0 0 * * * /path/to/backup.sh            │
  │  @hourly /path/to/check.sh     │  0 * * * * /path/to/check.sh             │
  │  @weekly /path/to/report.sh    │  0 0 * * 0 /path/to/report.sh            │
  └───────────────────────────────────────────────────────────────────────────┘
  
  PRO strings:
    ✓ More readable
    ✓ Less prone to mistakes
    ✓ Self-documenting
  
  CONTRA strings:
    ✗ Less flexible (you can't say @daily at 3 AM)
    ✗ Some cron implementations don't support them
    ✗ Expression preference depends on the task, not experience

EOF

    print_tip "Recommendation: use strings for simple cases, expressions for fine control"
    
    echo -e "${SUCCESS}✅ Section 4 complete!${RESET}"
    pause_interactive
}

#
# SECTION 5: CRONTAB MANAGEMENT
#

section_5_crontab_management() {
    print_header "SECTION 5: CRONTAB MANAGEMENT"
    
    print_concept "The crontab commands"
    
    cat << 'EOF'

┌─────────────────────────────────────────────────────────────────────────────┐
│                    📝 CRONTAB COMMANDS                                      │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  crontab -e        Edit current crontab (opens editor)                      │
│  crontab -l        List (display) current crontab                           │
│  crontab -r        Remove (delete) ENTIRE crontab                           │
│  crontab -i        Ask confirmation before -r                               │
│  crontab file      Replace crontab with file contents                       │
│  crontab -u USER   Operate on another user's crontab (requires root)        │
│                                                                             │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ☠️  EXTREME DANGER: crontab -r                                             │
│                                                                             │
│  crontab -r deletes ALL entries, without confirmation!                      │
│                                                                             │
│  The keys 'e' and 'r' are ADJACENT on the keyboard!                         │
│  crontab -e  vs  crontab -r   ← An expensive mistake!                       │
│                                                                             │
│  💡 SOLUTION: Use alias in ~/.bashrc:                                       │
│     alias crontab='crontab -i'                                              │
│     (asks for confirmation for -r)                                          │
│                                                                             │
│  💡 BACKUP: Before modifications:                                           │
│     crontab -l > ~/crontab_backup_$(date +%Y%m%d).txt                       │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘

EOF

    pause_interactive
    
    print_subheader "Demonstration: crontab -l"
    
    run_demo "Display current crontab" \
        "crontab -l 2>/dev/null || echo '(crontab empty or does not exist)'"
    
    pause_interactive
    
    print_subheader "Demonstration: crontab -e (conceptual)"
    
    echo ""
    echo "When you run 'crontab -e', the following happens:"
    echo ""
    
    cat << 'EOF'
  1. Current crontab is copied to a temporary file
  2. Editor opens (determined by $EDITOR or $VISUAL)
  3. You edit and save the file
  4. Upon closing editor, cron validates syntax
  5. If valid, new crontab is installed
  6. If invalid, you get error and option to re-edit

EOF

    print_warning "Default editor may be vi/vim. For nano, run:"
    echo ""
    echo "  export EDITOR=nano"
    echo "  crontab -e"
    echo ""
    echo "Or add to ~/.bashrc for permanent:"
    echo "  echo 'export EDITOR=nano' >> ~/.bashrc"
    
    pause_interactive
    
    print_subheader "Demonstration: loading crontab from file"
    
    # Create example crontab file
    cat > "$DEMO_DIR/example_crontab.txt" << 'CRON_EOF'
# Example crontab - do not install this file!
# Format: min hour dom mon dow command

# Logging every 5 minutes (DISABLED - # at start)
# */5 * * * * /home/user/scripts/logger.sh

# Daily backup at 3 AM
# 0 3 * * * /home/user/scripts/backup.sh >> /home/user/logs/backup.log 2>&1

# Cleanup old files, Sunday at midnight
# 0 0 * * 0 /home/user/scripts/cleanup.sh

# Health check every hour during the day
# 0 9-18 * * 1-5 /home/user/scripts/health_check.sh

# Notification at system startup
# @reboot /home/user/scripts/notify_boot.sh
CRON_EOF
    
    run_demo "Display example crontab file" \
        "cat $DEMO_DIR/example_crontab.txt"
    
    echo ""
    print_warning "To install a crontab file, use:"
    echo ""
    echo "  crontab /path/to/crontab_file.txt"
    echo ""
    echo "  ⚠️  Pitfall: This REPLACES the existing crontab!"
    echo ""
    echo "  To ADD to existing:"
    echo "  (crontab -l; cat new_entries.txt) | crontab -"
    
    pause_interactive
    
    print_subheader "Best practice: crontab versioning"
    
    cat << 'EOF'

┌─────────────────────────────────────────────────────────────────────────────┐
│              💾 CRONTAB VERSIONING AND BACKUP                               │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  1. BACKUP BEFORE MODIFICATION:                                             │
│     crontab -l > ~/crontab_backup_$(date +%Y%m%d_%H%M%S).txt                │
│                                                                             │
│  2. KEEP CRONTAB IN GIT:                                                    │
│     mkdir ~/crontab-repo && cd ~/crontab-repo                               │
│     git init                                                                │
│     crontab -l > crontab.txt                                                │
│     git add crontab.txt && git commit -m "Initial crontab"                  │
│                                                                             │
│  3. SYNC SCRIPT (run periodically):                                         │
│     #!/bin/bash                                                             │
│     cd ~/crontab-repo                                                       │
│     crontab -l > crontab.txt                                                │
│     if ! git diff --quiet; then                                             │
│         git add crontab.txt                                                 │
│         git commit -m "Crontab update $(date +%Y-%m-%d)"                    │
│     fi                                                                      │
│                                                                             │
│  4. RESTORE FROM BACKUP:                                                    │
│     crontab ~/crontab_backup_20250115.txt                                   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘

EOF

    echo -e "${SUCCESS}✅ Section 5 complete!${RESET}"
    pause_interactive
}

#
# SECTION 6: EXECUTION ENVIRONMENT AND PATH
#

section_6_environment() {
    print_header "SECTION 6: CRON EXECUTION ENVIRONMENT"
    
    print_danger "CAUSE #1 OF FAILED JOBS: EXECUTION ENVIRONMENT"
    
    cat << 'EOF'

┌─────────────────────────────────────────────────────────────────────────────┐
│            ⚠️  CRON DOES NOT HAVE YOUR SHELL ENVIRONMENT!                   │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  When cron executes a job, it does NOT load:                                │
│  • ~/.bashrc                                                                │
│  • ~/.bash_profile                                                          │
│  • ~/.profile                                                               │
│  • Environment variables from your session                                  │
│                                                                             │
│  CONSEQUENCES:                                                              │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────────┐│
│  │  INTERACTIVE SHELL:               │  CRON ENVIRONMENT:                  ││
│  ├─────────────────────────────────────────────────────────────────────────┤│
│  │  PATH=/usr/local/bin:/usr/bin:    │  PATH=/usr/bin:/bin                 ││
│  │       /bin:/home/user/bin:...     │  (much shorter!)                    ││
│  │                                   │                                      ││
│  │  HOME=/home/user                  │  HOME=/home/user (usually)          ││
│  │                                   │                                      ││
│  │  LANG=en_US.UTF-8                 │  LANG=(may be missing!)             ││
│  │                                   │                                      ││
│  │  USER=user                        │  USER=(may be missing!)             ││
│  │                                   │                                      ││
│  │  DISPLAY=:0                       │  DISPLAY=(missing - no GUI!)        ││
│  └─────────────────────────────────────────────────────────────────────────┘│
│                                                                             │
│  💀 COMMON SYMPTOM: "Script works from terminal but not from cron"          │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘

EOF

    pause_interactive
    
    print_subheader "Demonstration: environment difference"
    
    echo "Current shell environment vs cron environment:"
    echo ""
    
    run_demo "PATH in current shell" \
        "echo \$PATH | tr ':' '\n' | head -5"
    
    echo ""
    echo "Typical PATH in cron: /usr/bin:/bin"
    echo ""
    
    # Demonstrate with our test script
    if [ -f "$SCRIPTS_DIR/env_test.sh" ]; then
        run_demo "Run environment test script (from shell)" \
            "$SCRIPTS_DIR/env_test.sh && tail -10 $LOG_DIR/env_test.log"
    fi
    
    pause_interactive
    
    print_subheader "Solutions for environment problems"
    
    cat << 'EOF'

┌─────────────────────────────────────────────────────────────────────────────┐
│                    🔧 SOLUTIONS FOR PATH AND ENVIRONMENT                    │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  SOLUTION 1: Use ABSOLUTE PATHS for all commands                            │
│  ───────────────────────────────────────────────────────────────────────── │
│                                                                             │
│  # WRONG:                                                                   │
│  * * * * * python3 /home/user/script.py                                     │
│                                                                             │
│  # CORRECT:                                                                 │
│  * * * * * /usr/bin/python3 /home/user/script.py                            │
│                                                                             │
│  💡 Find path with: which python3                                           │
│                                                                             │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  SOLUTION 2: Define PATH in crontab                                         │
│  ───────────────────────────────────────────────────────────────────────── │
│                                                                             │
│  # At the beginning of crontab:                                             │
│  PATH=/usr/local/bin:/usr/bin:/bin:/home/user/bin                           │
│  SHELL=/bin/bash                                                            │
│  HOME=/home/user                                                            │
│                                                                             │
│  # Then normal jobs:                                                        │
│  * * * * * myscript.sh                                                      │
│                                                                             │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  SOLUTION 3: Load an explicit job environment file                                         │
│  ───────────────────────────────────────────────────────────────────────── │
│                                                                             │
│  #!/bin/bash                                                                │
│  source /home/user/job.env  # explicit non-interactive settings                                 │
│  # ... rest of script                                                       │
│                                                                             │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  SOLUTION 4: Wrapper that sets environment                                  │
│  ───────────────────────────────────────────────────────────────────────── │
│                                                                             │
│  # In crontab:                                                              │
│  * * * * * /bin/bash -l -c '/home/user/script.sh'                           │
│                  │  │                                                       │
│                  │  └── -c = execute command                                │
│                  └── -l = login shell (loads profile)                       │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘

EOF

    pause_interactive
    
    print_subheader "Other important variables in crontab"
    
    cat << 'EOF'

┌─────────────────────────────────────────────────────────────────────────────┐
│                VARIABLES THAT CAN BE SET IN CRONTAB                         │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  # Common variables to set at the beginning of crontab:                     │
│                                                                             │
│  SHELL=/bin/bash                    # Shell used (default: /bin/sh)         │
│  PATH=/usr/local/bin:/usr/bin:/bin  # Command search paths                  │
│  MAILTO=user@example.com            # Where to send output                  │
│  MAILTO=""                          # Disable email                         │
│  HOME=/home/user                    # Home directory                        │
│  LANG=en_US.UTF-8                   # Locale for characters                 │
│                                                                             │
│  # Jobs after variable definitions:                                         │
│  0 * * * * /path/to/script.sh                                               │
│                                                                             │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  💡 MAILTO: Cron sends output via email!                                    │
│                                                                             │
│  • If job produces output (stdout or stderr), cron sends it                 │
│    to the address in MAILTO                                                 │
│  • To disable: MAILTO="" or redirect: cmd > /dev/null 2>&1                       │
│  • Requires configured mail transport; delivery is not guaranteed                        │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘

EOF

    echo -e "${SUCCESS}✅ Section 6 complete!${RESET}"
    pause_interactive
}

#
# SECTION 7: LOGGING AND DEBUGGING
#

section_7_logging_debugging() {
    print_header "SECTION 7: LOGGING AND DEBUGGING CRON"
    
    print_concept "Why logging is ESSENTIAL for cron"
    
    cat << 'EOF'

┌─────────────────────────────────────────────────────────────────────────────┐
│                    📋 LOGGING IN CRON JOBS                                  │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  PROBLEM: Cron jobs run in background, without terminal!                    │
│                                                                             │
│  • You don't see output                                                     │
│  • You don't see errors                                                     │
│  • You don't know if it ran or not                                          │
│  • You don't know WHY it failed                                             │
│                                                                             │
│  SOLUTION: Explicit logging for ANY cron job                                │
│                                                                             │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  BASIC PATTERN: Output redirection                                          │
│                                                                             │
│  * * * * * /path/script.sh >> /path/to/logfile.log 2>&1                     │
│                             │                    │                          │
│                             │                    └── stderr → stdout        │
│                             └── append stdout to log                        │
│                                                                             │
│  BREAKDOWN:                                                                 │
│  ┌─────────────────────────────────────────────────────────────────────────┐│
│  │  >>         = append (add at end, don't overwrite)                      ││
│  │  2>&1       = redirect stderr (2) to stdout (1)                         ││
│  │  2>&1       = MUST be AFTER >>                                          ││
│  └─────────────────────────────────────────────────────────────────────────┘│
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘

EOF

    pause_interactive
    
    print_subheader "Logging patterns"
    
    cat << 'EOF'

┌─────────────────────────────────────────────────────────────────────────────┐
│                    📝 LOGGING PATTERNS                                      │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  1. SIMPLE LOGGING (just append):                                           │
│     * * * * * /script.sh >> /var/log/script.log 2>&1                        │
│                                                                             │
│  2. LOGGING WITH TIMESTAMP (in crontab):                                    │
│     * * * * * /script.sh >> /var/log/script_$(date +\%Y\%m\%d).log 2>&1     │
│                                             ↑                               │
│                                             └── % must be escaped with \    │
│                                                                             │
│  3. LOGGING IN SCRIPT (RECOMMENDED):                                        │
│     #!/bin/bash                                                             │
│     LOG="/var/log/myapp/script.log"                                         │
│     log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$LOG"; }           │
│                                                                             │
│     log "START: Script initiated"                                           │
│     # ... code ...                                                          │
│     log "END: Script completed successfully"                                │
│                                                                             │
│  4. PROFESSIONAL LOGGING (with levels):                                     │
│     log_info()  { echo "[$(date '+%F %T')] [INFO] $*" >> "$LOG"; }          │
│     log_warn()  { echo "[$(date '+%F %T')] [WARN] $*" >> "$LOG"; }          │
│     log_error() { echo "[$(date '+%F %T')] [ERROR] $*" >> "$LOG"; }         │
│                                                                             │
│  5. SYSLOG LOGGING (for centralised integration):                           │
│     * * * * * /script.sh 2>&1 | logger -t myscript                          │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘

EOF

    pause_interactive
    
    # Demonstration with logging script
    if [ -f "$SCRIPTS_DIR/simple_logger.sh" ]; then
        run_demo "Run logging script" \
            "$SCRIPTS_DIR/simple_logger.sh && cat $LOG_DIR/simple.log"
    fi
    
    pause_interactive
    
    print_subheader "Debugging cron jobs"
    
    cat << 'EOF'

┌─────────────────────────────────────────────────────────────────────────────┐
│                    🔍 DEBUGGING CRON JOBS                                   │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  STEP 1: Verify cron is running                                             │
│  ─────────────────────────────────────────────────────────────────────────  │
│  systemctl status cron                                                      │
│  ps aux | grep cron                                                         │
│                                                                             │
│  STEP 2: Check system logs                                                  │
│  ─────────────────────────────────────────────────────────────────────────  │
│  grep CRON /var/log/syslog | tail -20                                       │
│  journalctl -u cron --since "1 hour ago"                                    │
│                                                                             │
│  STEP 3: Test script manually                                               │
│  ─────────────────────────────────────────────────────────────────────────  │
│  # Simulate cron environment:                                               │
│  env -i HOME=$HOME /bin/bash -c '/path/to/script.sh'                        │
│     │                                                                       │
│     └── env -i = reduced test; not a complete cron simulation                              │
│                                                                             │
│  STEP 4: Add debugging to script                                            │
│  ─────────────────────────────────────────────────────────────────────────  │
│  #!/bin/bash                                                                │
│  exec >> /tmp/debug_$$.log 2>&1  # Redirect EVERYTHING                      │
│  set -x                          # Show each command                        │
│  echo "PATH: $PATH"                                                         │
│  echo "PWD: $PWD"                                                           │
│  echo "USER: $USER"                                                         │
│  # ... rest of script                                                       │
│                                                                             │
│  STEP 5: Test with rapid timing                                             │
│  ─────────────────────────────────────────────────────────────────────────  │
│  # Set job to run every minute for testing:                                 │
│  * * * * * /path/to/script.sh >> /tmp/cron_test.log 2>&1                    │
│  # Then verify: tail -f /tmp/cron_test.log                                  │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘

EOF

    pause_interactive
    
    print_subheader "Checking execution in syslog"
    
    run_demo "Check recent cron executions in syslog" \
        "grep -i cron /var/log/syslog 2>/dev/null | tail -10 || echo 'Check with: journalctl -u cron'"
    
    pause_interactive
    
    print_subheader "Template script with complete logging"
    
    cat << 'TEMPLATE_EOF'

┌─────────────────────────────────────────────────────────────────────────────┐
│              📄 TEMPLATE: Script for Cron with Logging                      │
├─────────────────────────────────────────────────────────────────────────────┘

#!/bin/bash
#
# Script for cron job with complete logging and error handling
#

#  CONFIGURATION 
SCRIPT_NAME=$(basename "$0")
LOG_DIR="$HOME/logs"
LOG_FILE="$LOG_DIR/${SCRIPT_NAME%.*}.log"
LOCK_FILE="/tmp/${SCRIPT_NAME%.*}.lock"

# Ensure log directory exists
mkdir -p "$LOG_DIR"

#  LOGGING FUNCTIONS 
log() {
    local level="$1"; shift
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$level] $*" >> "$LOG_FILE"
}

log_info()  { log "INFO" "$@"; }
log_warn()  { log "WARN" "$@"; }
log_error() { log "ERROR" "$@"; }

#  LOCK FILE (prevent simultaneous executions) 
if [ -f "$LOCK_FILE" ]; then
    pid=$(cat "$LOCK_FILE")
    if ps -p "$pid" > /dev/null 2>&1; then
        log_warn "Another instance running (PID: $pid). Exit."
        exit 0
    fi
fi
echo $$ > "$LOCK_FILE"
trap "rm -f '$LOCK_FILE'" EXIT

#  MAIN LOGIC 
log_info "═══ START: $SCRIPT_NAME ═══"

# Code here...
# ...

if [ $? -eq 0 ]; then
    log_info "Task completed successfully"
else
    log_error "Task failed!"
    exit 1
fi

log_info "═══ END: $SCRIPT_NAME ═══"
log_info ""

TEMPLATE_EOF

    echo -e "${SUCCESS}✅ Section 7 complete!${RESET}"
    pause_interactive
}

#
# SECTION 8: AT COMMAND AND BEST PRACTICES
#

section_8_at_and_best_practices() {
    print_header "SECTION 8: THE AT COMMAND AND BEST PRACTICES"
    
    print_concept "at - one-time tasks (not periodic)"
    
    cat << 'EOF'

┌─────────────────────────────────────────────────────────────────────────────┐
│                    ⏰ THE at COMMAND - ONE-TIME TASKS                       │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  cron = PERIODIC tasks (repeat)                                             │
│  at   = ONE-TIME tasks (single execution)                                   │
│                                                                             │
│  BASIC SYNTAX:                                                              │
│                                                                             │
│  at TIME                          # Enter commands interactively            │
│  at TIME < script.sh              # Execute file contents                   │
│  echo "cmd" | at TIME             # Execute a command                       │
│  at -f script.sh TIME             # Execute the script                      │
│                                                                             │
│  TIME FORMATS:                                                              │
│                                                                             │
│  at now + 5 minutes               # In 5 minutes                            │
│  at now + 1 hour                  # In one hour                             │
│  at now + 2 days                  # In 2 days                               │
│  at 17:00                         # At 17:00 today (or tomorrow if past)    │
│  at 17:00 tomorrow                # Tomorrow at 17:00                       │
│  at 9:00 AM Dec 25                # 25th December at 9:00                   │
│  at midnight                      # At midnight                             │
│  at noon                          # At noon                                 │
│  at teatime                       # At 16:00 (4 PM)                         │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘

EOF
    
    pause_interactive
    
    print_subheader "at job management commands"
    
    cat << 'EOF'

┌─────────────────────────────────────────────────────────────────────────────┐
│                    📋 at JOB MANAGEMENT                                     │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  atq             List pending at jobs                                       │
│  at -l           Synonym for atq                                            │
│  atrm JOB_ID     Delete a job by ID                                         │
│  at -c JOB_ID    Display job contents                                       │
│                                                                             │
│  EXAMPLE WORKFLOW:                                                          │
│                                                                             │
│  $ echo "echo 'Reminder!' >> /tmp/reminder.txt" | at now + 30 minutes       │
│  job 42 at Sat Jan 18 15:30:00 2025                                         │
│                                                                             │
│  $ atq                                                                      │
│  42      Sat Jan 18 15:30:00 2025 a user                                    │
│                                                                             │
│  $ atrm 42    # Cancel the job                                              │
│                                                                             │
│  $ atq                                                                      │
│  (empty - job was deleted)                                                  │
│                                                                             │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  💡 batch - executes when system is idle                                    │
│                                                                             │
│  batch < script.sh                                                          │
│                                                                             │
│  Executes when load average drops below 1.5 (or other configured value)    │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘

EOF

    pause_interactive
    
    # Check if atd is running
    run_demo "Verify atd service" \
        "systemctl status atd 2>/dev/null | head -3 || service atd status 2>/dev/null | head -3 || echo 'atd may not be installed'"
    
    run_demo "List current at jobs" \
        "atq 2>/dev/null || echo 'at not available or no jobs'"
    
    pause_interactive
    
    print_subheader "BEST PRACTICES FOR CRON"
    
    cat << 'EOF'

┌─────────────────────────────────────────────────────────────────────────────┐
│                    ✅ CRON BEST PRACTICES                                   │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  1. USE ABSOLUTE PATHS                                                      │
│     ────────────────────────────────────────────────────────────────────── │
│     ✗ WRONG:   * * * * * backup.sh                                          │
│     ✓ CORRECT: * * * * * /home/user/scripts/backup.sh                       │
│                                                                             │
│  2. REDIRECT OUTPUT                                                         │
│     ────────────────────────────────────────────────────────────────────── │
│     ✗ WRONG:   0 3 * * * /path/script.sh                                    │
│     ✓ CORRECT: 0 3 * * * /path/script.sh >> /var/log/script.log 2>&1        │
│                                                                             │
│  3. TEST FIRST WITH ECHO                                                    │
│     ────────────────────────────────────────────────────────────────────── │
│     # First:                                                                │
│     0 3 * * * echo "Would delete old files" >> /tmp/test.log                │
│     # After verification:                                                   │
│     0 3 * * * /home/user/owned_cleanup.sh                                   │
│                                                                             │
│  4. PREVENT SIMULTANEOUS EXECUTIONS (LOCK FILES)                            │
│     ────────────────────────────────────────────────────────────────────── │
│     # In script or with flock:                                              │
│     * * * * * flock -n /tmp/myjob.lock /path/script.sh                      │
│                                                                             │
│  5. HANDLE ERRORS                                                           │
│     ────────────────────────────────────────────────────────────────────── │
│     # In script: set -e (exit on first error)                               │
│     # or: cmd || log_error "cmd failed"                                     │
│                                                                             │
│  6. BACKUP CRONTAB                                                          │
│     ────────────────────────────────────────────────────────────────────── │
│     crontab -l > ~/crontab_backup.txt                                       │
│                                                                             │
│  7. COMMENT YOUR JOBS                                                       │
│     ────────────────────────────────────────────────────────────────────── │
│     # Daily backup at 3 AM - last modified: 2025-01-15                      │
│     0 3 * * * /home/user/backup.sh                                          │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘

EOF

    pause_interactive
    
    print_subheader "Lock files and flock"
    
    cat << 'EOF'

┌─────────────────────────────────────────────────────────────────────────────┐
│                    🔒 PREVENTING SIMULTANEOUS EXECUTIONS                    │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  PROBLEM: If a cron job takes longer than the interval,                     │
│           multiple instances can run simultaneously!                        │
│                                                                             │
│  Example: Job runs every minute, but takes 3 minutes                        │
│           → 3 simultaneous instances!                                       │
│                                                                             │
│  SOLUTION 1: flock (recommended)                                            │
│  ─────────────────────────────────────────────────────────────────────────  │
│  * * * * * flock -n /tmp/myjob.lock -c '/path/to/script.sh'                 │
│                 │                                                           │
│                 └── -n = non-blocking (skip if locked)                      │
│                                                                             │
│  OR in script:                                                              │
│  #!/bin/bash                                                                │
│  exec 200>/tmp/myjob.lock                                                   │
│  flock -n 200 || exit 1                                                     │
│  # ... code ...                                                             │
│                                                                             │
│  WRONG EXAMPLE: check-then-write PID file is race-prone                                   │
│  ─────────────────────────────────────────────────────────────────────────  │
│  LOCK="/tmp/myjob.lock"                                                     │
│  if [ -f "$LOCK" ]; then                                                    │
│      PID=$(cat "$LOCK")                                                     │
│      if ps -p "$PID" > /dev/null 2>&1; then                                 │
│          echo "Already running (PID: $PID)"                                 │
│          exit 0                                                             │
│      fi                                                                     │
│  fi                                                                         │
│  echo $$ > "$LOCK"                                                          │
│  trap "rm -f '$LOCK'" EXIT                                                  │
│  # ... code ...                                                             │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘

EOF

    pause_interactive
    
    print_subheader "Anti-patterns to avoid"
    
    cat << 'EOF'

┌─────────────────────────────────────────────────────────────────────────────┐
│                    ❌ ANTI-PATTERNS TO AVOID                                │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ☠️  DIRECT EDITING OF /var/spool/cron/crontabs/                            │
│      → Use crontab -e, never direct editing                                 │
│                                                                             │
│  ☠️  CRON JOBS THAT REQUIRE INTERACTION                                     │
│      → No terminal! You can't read input.                                   │
│                                                                             │
│  ☠️  COMMANDS WITH MASSIVE OUTPUT WITHOUT REDIRECTION                       │
│      → Fills mailbox or syslog                                              │
│                                                                             │
│  ☠️  RUNNING AS ROOT WHEN NOT NECESSARY                                     │
│      → Principle of least privilege                                         │
│                                                                             │
│  ☠️  NOT TESTING SCRIPT BEFOREHAND                                          │
│      → Manual test: ./script.sh                                             │
│      → Test with empty env: env -i HOME=$HOME bash -c './script.sh'         │
│                                                                             │
│  ☠️  ASSUMPTIONS ABOUT CURRENT DIRECTORY                                    │
│      → Debian cron normally starts in HOME; do not assume all daemons                        │
│      → Use explicit cd or absolute paths                                    │
│                                                                             │
│  ☠️  FORGETTING ABOUT % IN CRONTAB                                          │
│      → % is a special character in crontab (newline)!                       │
│      → Must be escaped: \%                                                  │
│      → date +%Y%m%d → date +\%Y\%m\%d                                       │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘

EOF

    echo -e "${SUCCESS}✅ Section 8 complete!${RESET}"
    pause_interactive
}

#
# TOOL: CRON EXPRESSION GENERATOR
#

tool_generator() {
    print_header "🔧 TOOL: CRON EXPRESSION GENERATOR"
    
    cat << 'EOF'
┌─────────────────────────────────────────────────────────────────────────────┐
│              INTERACTIVE CRON EXPRESSION GENERATOR                          │
├─────────────────────────────────────────────────────────────────────────────┤
│  Answer questions to generate the desired cron expression.                  │
│  Enter 'q' to exit.                                                         │
└─────────────────────────────────────────────────────────────────────────────┘

EOF

    while true; do
        echo ""
        echo -e "${CYAN}═══ NEW CRON JOB ═══${RESET}"
        echo ""
        
        # Frequency
        echo "What frequency do you want?"
        echo "  1) Every X minutes"
        echo "  2) Every X hours"
        echo "  3) Daily at a specific time"
        echo "  4) Weekly (certain days)"
        echo "  5) Monthly (certain days of the month)"
        echo "  6) Custom (enter manually)"
        echo "  q) Exit"
        echo ""
        read -r -p "Choose (1-6 or q): " freq_choice || return 0
        
        case "$freq_choice" in
            q|Q)
                echo "Goodbye!"
                return 0
                ;;
            1)
                read -r -p "How many minutes? (1-59): " mins
                if [[ "$mins" =~ ^[0-9]+$ ]] && [ "$mins" -ge 1 ] && [ "$mins" -le 59 ]; then
                    cron_expr="*/$mins * * * *"
                else
                    echo -e "${RED}Invalid value!${RESET}"
                    continue
                fi
                ;;
            2)
                read -r -p "How many hours? (1-23): " hours
                read -r -p "At which minute of the hour? (0-59, default 0): " minute
                minute=${minute:-0}
                if [[ "$hours" =~ ^[0-9]+$ ]] && [ "$hours" -ge 1 ] && [ "$hours" -le 23 ]; then
                    cron_expr="$minute */$hours * * *"
                else
                    echo -e "${RED}Invalid value!${RESET}"
                    continue
                fi
                ;;
            3)
                read -r -p "At what hour? (0-23): " hour
                read -r -p "At what minute? (0-59, default 0): " minute
                minute=${minute:-0}
                if [[ "$hour" =~ ^[0-9]+$ ]] && [ "$hour" -ge 0 ] && [ "$hour" -le 23 ]; then
                    cron_expr="$minute $hour * * *"
                else
                    echo -e "${RED}Invalid value!${RESET}"
                    continue
                fi
                ;;
            4)
                read -r -p "At what hour? (0-23): " hour
                read -r -p "At what minute? (0-59, default 0): " minute
                minute=${minute:-0}
                echo "Which days of the week? (0=Sun, 1=Mon, ..., 6=Sat)"
                echo "  Examples: 1-5 (Mon-Fri), 0,6 (weekend), 1,3,5 (Mon,Wed,Fri)"
                read -r -p "Days: " dow
                cron_expr="$minute $hour * * $dow"
                ;;
            5)
                read -r -p "At what hour? (0-23): " hour
                read -r -p "At what minute? (0-59, default 0): " minute
                minute=${minute:-0}
                echo "Which days of the month? (1-31)"
                echo "  Examples: 1 (first day), 1,15 (1st and 15th), 1-7 (first 7 days)"
                read -r -p "Days: " dom
                cron_expr="$minute $hour $dom * *"
                ;;
            6)
                echo "Enter the cron expression (5 space-separated fields):"
                read -r -p "Expression: " cron_expr
                ;;
            *)
                echo -e "${RED}Invalid option!${RESET}"
                continue
                ;;
        esac
        
        # Validate all bounds/grammar, including assembled fields, before display.
        if ! python3 -B "$CRON_VALIDATOR" "$cron_expr"; then
            continue
        fi

        # Display result
        echo ""
        echo -e "${GREEN}════════════════════════════════════════════════════════════════════════════${RESET}"
        echo -e "${GREEN}  GENERATED CRON EXPRESSION:${RESET}"
        echo ""
        echo -e "    ${BOLD}${WHITE}$cron_expr${RESET}"
        echo ""
        
        # Explanation
        explain_cron_expression "$cron_expr"
        
        echo ""
        echo -e "${GREEN}════════════════════════════════════════════════════════════════════════════${RESET}"
        
        # Usage example
        echo ""
        echo "Usage example in crontab:"
        echo ""
        echo -e "  ${DIM}# Job description${RESET}"
        echo -e "  ${WHITE}$cron_expr /path/to/your/script.sh >> /path/to/log.log 2>&1${RESET}"
        echo ""
        
        read -r -p "Generate another expression? (y/n): " again
        if [[ "$again" != "y" && "$again" != "Y" ]]; then
            break
        fi
    done
}

#
# TOOL: CRON EXPRESSION VALIDATOR/EXPLAINER
#

explain_cron_expression() {
    python3 -B "$CRON_VALIDATOR" "$1"
}

tool_validator() {
    print_header "🔧 TOOL: CRON EXPRESSION VALIDATOR/EXPLAINER"
    
    cat << 'EOF'
┌─────────────────────────────────────────────────────────────────────────────┐
│            CRON EXPRESSION VALIDATOR AND EXPLAINER                          │
├─────────────────────────────────────────────────────────────────────────────┤
│  Enter five schedule fields or one macro; commands are not accepted.         │
│  Enter 'q' to exit.                                                         │
└─────────────────────────────────────────────────────────────────────────────┘

EOF

    while true; do
        echo ""
        read -r -p "Cron expression (or 'q' to exit): " input || return 0
        
        if [[ "$input" == "q" || "$input" == "Q" ]]; then
            echo "Goodbye!"
            return 0
        fi
        
        if ! explain_cron_expression "$input"; then
            continue
        fi

        # Calculate next executions (simplified)
        echo ""
        echo -e "  ${MAGENTA}💡 TIP: For exact calculation of next executions,${RESET}"
        echo -e "         ${MAGENTA}use: https://crontab.guru/${RESET}"
        
        echo ""
    done
}

#
# TOOL: CRON JOBS MONITOR
#

tool_monitor() {
    print_header "🔧 TOOL: LIVE CRON JOBS MONITOR"
    
    cat << 'EOF'
┌─────────────────────────────────────────────────────────────────────────────┐
│              LIVE MONITOR FOR CRON JOBS                                     │
├─────────────────────────────────────────────────────────────────────────────┤
│  Monitor cron executions in real time.                                      │
│  Press Ctrl+C to stop.                                                      │
└─────────────────────────────────────────────────────────────────────────────┘

EOF

    echo "Current crontab:"
    echo -e "${DIM}──────────────────────────────────────────────────────────────────────────────${RESET}"
    crontab -l 2>/dev/null || echo "(empty)"
    echo -e "${DIM}──────────────────────────────────────────────────────────────────────────────${RESET}"
    echo ""
    
    echo "Monitoring cron logs..."
    echo "(Press Ctrl+C to stop)"
    echo ""
    
    # Try different log sources
    if [ -f /var/log/syslog ]; then
        echo -e "${CYAN}Following /var/log/syslog for CRON entries...${RESET}"
        echo ""
        tail -f /var/log/syslog 2>/dev/null | grep --line-buffered -i cron
    elif command -v journalctl &> /dev/null; then
        echo -e "${CYAN}Following journalctl for cron service...${RESET}"
        echo ""
        journalctl -f -u cron
    else
        echo -e "${YELLOW}Cannot find standard cron logs.${RESET}"
        echo "Try manually:"
        echo "  tail -f /var/log/syslog | grep CRON"
        echo "  journalctl -f -u cron"
    fi
}

#
# SUMMARY: CHEAT SHEET
#

print_cheat_sheet() {
    print_header "📋 CRON CHEAT SHEET"
    
    cat << 'EOF'
┌─────────────────────────────────────────────────────────────────────────────┐
│                         CRON CHEAT SHEET                                    │
├─────────────────────────────────────────────────────────────────────────────┤
│  FORMAT:  min(0-59) hour(0-23) dom(1-31) month(1-12) dow(0-7) command       │
│                                                                             │
│  OPERATORS:                                                                 │
│  *         any value                    */5       every 5                   │
│  ,         list (1,3,5)                 -         range (1-5)               │
│                                                                             │
│  SPECIAL STRINGS:                                                           │
│  @reboot   at startup                   @hourly   0 * * * *                 │
│  @daily    0 0 * * *                    @weekly   0 0 * * 0                 │
│  @monthly  0 0 1 * *                    @yearly   0 0 1 1 *                 │
│                                                                             │
│  COMMANDS:                                                                  │
│  crontab -e   edit                      crontab -l   list                   │
│  crontab -r   delete ALL (!)            crontab file install                │
│                                                                             │
│  COMMON EXAMPLES:                                                           │
│  * * * * *        Every minute                                              │
│  0 * * * *        Every hour                                                │
│  0 0 * * *        Daily at midnight                                         │
│  0 3 * * *        Daily at 3:00 AM                                          │
│  */15 * * * *     Every 15 minutes                                          │
│  0 9-17 * * 1-5   Working hours (9-17, Mon-Fri)                             │
│  0 0 1,15 * *     On 1st and 15th of month                                  │
│  0 0 * * 0        Sunday at midnight                                        │
│                                                                             │
│  BEST PRACTICES:                                                            │
│  ✓ Absolute paths            ✓ Redirect output                              │
│  ✓ Lock files (flock)        ✓ Complete logging                             │
│  ✓ Backup crontab            ✓ Test beforehand                              │
│                                                                             │
│  LOGGING PATTERN:                                                           │
│  0 3 * * * /path/script.sh >> /var/log/script.log 2>&1                      │
│                                                                             │
│  LOCK FILE PATTERN:                                                         │
│  * * * * * flock -n /tmp/job.lock -c '/path/script.sh'                      │
└─────────────────────────────────────────────────────────────────────────────┘

EOF
}

#
# MAIN FUNCTION
#

show_usage() {
    cat << EOF
Usage: $0 [OPTIONS]

OPTIONS:
  -h, --help        Display this help
  -i, --interactive Interactive mode with pauses
  -s, --section NUM Run only the specified section (1-8)
  -c, --cleanup     Clean up demo environment
  --generator       Launch cron expression generator
  --validator       Validate schedule syntax (five fields or a macro; no command)
  --monitor         Launch cron jobs monitor
  --cheat-sheet     Display the cheat sheet

SECTIONS:
  1: Introduction to cron
  2: Crontab format (the 5 fields)
  3: Special characters (*, /, -, ,)
  4: Special strings (@reboot, @daily, etc.)
  5: Crontab management (crontab -e/-l/-r)
  6: Execution environment and PATH
  7: Logging and debugging
  8: The at command and best practices

EXAMPLES:
  $0                     # Run entire demo
  $0 -i                  # Interactive mode
  $0 -s 3                # Only section about special characters
  $0 --generator         # Cron expression generator
  $0 --validator         # Cron expression validator
EOF
}

main() {
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                show_usage
                exit 0
                ;;
            -i|--interactive)
                INTERACTIVE=true
                shift
                ;;
            -s|--section)
                SECTION_NUM="$2"
                shift 2
                ;;
            -c|--cleanup)
                cleanup_demo
                exit 0
                ;;
            --generator)
                tool_generator
                exit 0
                ;;
            --validator)
                tool_validator
                exit 0
                ;;
            --monitor)
                tool_monitor
                exit 0
                ;;
            --cheat-sheet)
                print_cheat_sheet
                exit 0
                ;;
            *)
                echo "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done
    
    # Banner
    echo ""
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════════════════════╗${RESET}"
    echo -e "${CYAN}║${RESET}     ${BOLD}⏰ CRON AND AUTOMATION DEMONSTRATION - Seminar 3 OS${RESET}                    ${CYAN}║${RESET}"
    echo -e "${CYAN}║${RESET}     Bucharest University of Economic Studies - CSIE                          ${CYAN}║${RESET}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════════════════════╝${RESET}"
    echo ""
    
    # Setup
    setup_demo_environment
    
    # Run sections
    if [ "$SECTION_NUM" -ne 0 ]; then
        case "$SECTION_NUM" in
            1) section_1_introduction ;;
            2) section_2_crontab_format ;;
            3) section_3_special_characters ;;
            4) section_4_special_strings ;;
            5) section_5_crontab_management ;;
            6) section_6_environment ;;
            7) section_7_logging_debugging ;;
            8) section_8_at_and_best_practices ;;
            *)
                echo "Invalid section: $SECTION_NUM (1-8)"
                exit 1
                ;;
        esac
    else
        # All sections
        section_1_introduction
        section_2_crontab_format
        section_3_special_characters
        section_4_special_strings
        section_5_crontab_management
        section_6_environment
        section_7_logging_debugging
        section_8_at_and_best_practices
    fi
    
    # Cheat sheet at the end
    print_cheat_sheet
    
    echo ""
    echo -e "${SUCCESS}════════════════════════════════════════════════════════════════════════════${RESET}"
    echo -e "${SUCCESS}  ✅ DEMONSTRATION COMPLETE!${RESET}"
    echo ""
    echo "  Available tools:"
    echo "    $0 --generator    Generate cron expressions"
    echo "    $0 --validator    Explain cron expressions"
    echo "    $0 --monitor      Monitor jobs live"
    echo ""
    echo "  Cleanup: $0 -c"
    echo ""
    echo -e "${SUCCESS}════════════════════════════════════════════════════════════════════════════${RESET}"
}

# Run
main "$@"
