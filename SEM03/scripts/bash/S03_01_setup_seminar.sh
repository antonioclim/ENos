#!/bin/bash
#
# S03_01_setup_seminar.sh - Setup for Seminar 03 OS
# Operating Systems | Bucharest UES - CSIE
#
#
# DESCRIPTION:
#   Prepares the environment for Seminar 3 exercises:
#   - Verifies dependencies (find, xargs, locate, cron)
#   - Creates directory structure for exercises
#   - Generates test files with various permissions and sizes
#   - Configures sandbox for permission exercises
#
# USAGE:
#   ./S03_01_setup_seminar.sh [-h] [-v] [-c] [-d DIR]
#
# OPTIONS:
#   -h          Display this help
#   -v          Verbose mode
#   -c          Clean previous setup before installation
#   -d DIR      Base directory (default: ~/sem5-6_lab)
#
# AUTHOR: OS Team UES
# VERSION: 1.0
#

set -e  # Exit on error

# Colours for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Colour
BOLD='\033[1m'

# Default configurations
BASE_DIR="${HOME}/sem5-6_lab"
VERBOSE=false
CLEANUP=false

#
# UTILITY FUNCTIONS
#

print_header() {
    echo -e "\n${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}$1${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}\n"
}

print_step() {
    echo -e "${BLUE}▶${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_info() {
    if [ "$VERBOSE" = true ]; then
        echo -e "${CYAN}ℹ${NC} $1"
    fi
}

usage() {
    cat << EOF
${BOLD}USAGE:${NC}
    $0 [-h] [-v] [-c] [-d DIR]

${BOLD}OPTIONS:${NC}
    -h          Display this help
    -v          Verbose mode
    -c          Clean previous setup before installation
    -d DIR      Base directory (default: ~/sem5-6_lab)

${BOLD}EXAMPLES:${NC}
    $0                    # Standard setup
    $0 -v                 # Setup with detailed output
    $0 -c -d ~/mylab      # Clean and install in ~/mylab

${BOLD}STRUCTURE CREATED:${NC}
    ~/sem5-6_lab/
    ├── find_exercises/      # find and xargs exercises
    ├── script_exercises/    # Parameters and getopts exercises
    ├── permission_lab/      # Permissions exercises (sandbox)
    ├── cron_exercises/      # Cron exercises
    └── integration/         # Integrated exercises

EOF
}

#
# DEPENDENCY VERIFICATION
#

check_dependencies() {
    print_header "🔍 DEPENDENCY VERIFICATION"
    
    local missing=0
    local commands=("find" "xargs" "locate" "chmod" "chown" "crontab" "at" "bc" "file")
    
    for cmd in "${commands[@]}"; do
        if command -v "$cmd" &> /dev/null; then
            print_success "$cmd - installed ($(command -v "$cmd"))"
        else
            print_error "$cmd - MISSING!"
            missing=$((missing + 1))
        fi
    done
    
    echo ""
    
    # Verify cron service
    print_step "Verifying cron service..."
    if systemctl is-active --quiet cron 2>/dev/null || \
       systemctl is-active --quiet crond 2>/dev/null || \
       pgrep -x cron > /dev/null 2>&1; then
        print_success "Cron service is running"
    else
        print_warning "Cron service does not appear to be running (cron exercises may not function)"
    fi
    
    # Verify locate database
    print_step "Verifying locate database..."
    if [ -f /var/lib/mlocate/mlocate.db ] || [ -f /var/lib/plocate/plocate.db ]; then
        print_success "Locate database exists"
        print_info "Last updated: $(stat -c '%y' /var/lib/mlocate/mlocate.db 2>/dev/null || stat -c '%y' /var/lib/plocate/plocate.db 2>/dev/null | cut -d'.' -f1)"
    else
        print_warning "Locate database does not exist or is outdated"
        print_info "Run 'sudo updatedb' to update"
    fi
    
    echo ""
    
    if [ $missing -gt 0 ]; then
        print_error "Missing $missing dependencies! Install them before continuing."
        echo -e "\nFor Ubuntu/Debian:"
        echo "  sudo apt update && sudo apt install findutils mlocate cron at bc file"
        return 1
    fi
    
    print_success "All dependencies are present!"
    return 0
}

#
# CLEAN PREVIOUS SETUP
#

cleanup_previous() {
    if [ -d "$BASE_DIR" ]; then
        print_header "🧹 CLEANING PREVIOUS SETUP"
        print_warning "Directory $BASE_DIR already exists"
        
        echo -n "Do you want to delete it? [y/N] "
        read -r response
        
        if [[ "$response" =~ ^[Yy]$ ]]; then
            print_step "Deleting $BASE_DIR..."
            rm -rf "$BASE_DIR"
            print_success "Directory deleted"
        else
            print_error "Cancelled by user"
            exit 1
        fi
    fi
}

#
# CREATE DIRECTORY STRUCTURE
#

create_directory_structure() {
    print_header "📁 CREATING DIRECTORY STRUCTURE"
    
    local dirs=(
        "$BASE_DIR"
        "$BASE_DIR/find_exercises"
        "$BASE_DIR/find_exercises/project"
        "$BASE_DIR/find_exercises/project/src"
        "$BASE_DIR/find_exercises/project/include"
        "$BASE_DIR/find_exercises/project/docs"
        "$BASE_DIR/find_exercises/project/tests"
        "$BASE_DIR/find_exercises/project/build"
        "$BASE_DIR/find_exercises/logs"
        "$BASE_DIR/find_exercises/backups"
        "$BASE_DIR/find_exercises/temp"
        "$BASE_DIR/find_exercises/data"
        "$BASE_DIR/script_exercises"
        "$BASE_DIR/script_exercises/input"
        "$BASE_DIR/script_exercises/output"
        "$BASE_DIR/permission_lab"
        "$BASE_DIR/permission_lab/public"
        "$BASE_DIR/permission_lab/private"
        "$BASE_DIR/permission_lab/shared"
        "$BASE_DIR/permission_lab/scripts"
        "$BASE_DIR/permission_lab/config"
        "$BASE_DIR/cron_exercises"
        "$BASE_DIR/cron_exercises/scripts"
        "$BASE_DIR/cron_exercises/logs"
        "$BASE_DIR/cron_exercises/output"
        "$BASE_DIR/integration"
    )
    
    for dir in "${dirs[@]}"; do
        mkdir -p "$dir"
        print_info "Created: $dir"
    done
    
    print_success "Directory structure created (${#dirs[@]} directories)"
}

#
# CREATE FILES FOR FIND EXERCISES
#

create_find_exercises_files() {
    print_header "📄 CREATING FILES FOR FIND EXERCISES"
    
    local find_dir="$BASE_DIR/find_exercises"
    
    # C source files
    print_step "Creating source files..."
    for name in main utils config parser network database; do
        echo "// $name.c - Source file" > "$find_dir/project/src/$name.c"
        echo "// $name.h - Header file" > "$find_dir/project/include/$name.h"
    done
    
    # Python files for tests
    for i in {1..5}; do
        cat > "$find_dir/project/tests/test_$i.py" << 'PYEOF'
#!/usr/bin/env python3
"""Test file for exercises"""
import unittest

class TestExample(unittest.TestCase):
    def test_placeholder(self):
        self.assertTrue(True)

if __name__ == '__main__':
    unittest.main()
PYEOF
    done
    
    # Documentation
    print_step "Creating documentation files..."
    echo "# README" > "$find_dir/project/docs/README.md"
    echo "API Documentation" > "$find_dir/project/docs/api.txt"
    echo "<html><body>Manual</body></html>" > "$find_dir/project/docs/manual.html"
    echo "Change Log" > "$find_dir/project/docs/CHANGELOG.md"
    
    # Log files with different dates
    print_step "Creating log files..."
    for i in {1..10}; do
        log_file="$find_dir/logs/app_$i.log"
        echo "Log entry $i - $(date)" > "$log_file"
        # Modify timestamp to simulate old files
        if [ $i -le 3 ]; then
            touch -d "$i days ago" "$log_file"
        elif [ $i -le 6 ]; then
            touch -d "$((i * 7)) days ago" "$log_file"
        else
            touch -d "$((i * 30)) days ago" "$log_file"
        fi
    done
    
    # Files with different sizes
    print_step "Creating files with different sizes..."
    dd if=/dev/zero of="$find_dir/data/small.bin" bs=1K count=10 2>/dev/null
    dd if=/dev/zero of="$find_dir/data/medium.bin" bs=1M count=1 2>/dev/null
    dd if=/dev/zero of="$find_dir/data/large.bin" bs=1M count=5 2>/dev/null
    
    # Files with spaces in names (for xargs exercises)
    print_step "Creating files with spaces in names..."
    echo "Content 1" > "$find_dir/data/my document.txt"
    echo "Content 2" > "$find_dir/data/file with spaces.txt"
    echo "Content 3" > "$find_dir/data/another file here.txt"
    
    # Backup files
    print_step "Creating backup files..."
    for ext in bak old backup "~"; do
        echo "Backup content" > "$find_dir/backups/config.$ext"
    done
    
    # Temporary files
    print_step "Creating temporary files..."
    for ext in tmp temp swp; do
        echo "Temp content" > "$find_dir/temp/file.$ext"
    done
    touch "$find_dir/temp/.hidden_temp"
    
    # Empty files
    touch "$find_dir/data/empty1.txt"
    touch "$find_dir/data/empty2.dat"
    
    # Symbolic link
    ln -sf "$find_dir/project/src/main.c" "$find_dir/project/main_link.c"
    
    # Count created files
    local file_count
    file_count=$(find "$find_dir" -type f | wc -l)
    print_success "Created $file_count files for find exercises"
}

#
# CREATE FILES FOR SCRIPT EXERCISES
#

create_script_exercises_files() {
    print_header "📜 CREATING FILES FOR SCRIPT EXERCISES"
    
    local script_dir="$BASE_DIR/script_exercises"
    
    # Input files for processing
    print_step "Creating input files..."
    for i in {1..5}; do
        cat > "$script_dir/input/data_$i.txt" << EOF
Line 1 of file $i
Line 2 of file $i
Line 3 of file $i
Special chars: <>&"'
Numbers: 123 456 789
EOF
    done
    
    # Script template for modification
    print_step "Creating script templates..."
    cat > "$script_dir/template_basic.sh" << 'SHEOF'
#!/bin/bash
# Template: Basic script with arguments
# TODO: Complete this script

# Verify argument count
if [ $# -lt 1 ]; then
    echo "Usage: $0 <argument>"
    exit 1
fi

# Process argument
echo "Argument received: $1"

# TODO: Add your logic here
SHEOF
    
    cat > "$script_dir/template_getopts.sh" << 'SHEOF'
#!/bin/bash
# Template: Script with getopts
# TODO: Complete option parsing

usage() {
    echo "Usage: $0 [-h] [-v] [-o FILE] <args>"
    echo "  -h        Display this help"
    echo "  -v        Verbose mode"
    echo "  -o FILE   Output file"
}

verbose=false
output=""

# TODO: Complete while getopts
while getopts ":hvo:" opt; do
    case $opt in
        h) usage; exit 0 ;;
        v) verbose=true ;;
        o) output="$OPTARG" ;;
        \?) echo "Invalid option: -$OPTARG"; exit 1 ;;
        :) echo "Option -$OPTARG requires argument"; exit 1 ;;
    esac
done
shift $((OPTIND - 1))

# Rest of script
echo "Verbose: $verbose"
echo "Output: ${output:-"(unspecified)"}"
echo "Remaining arguments: $@"
SHEOF
    
    chmod +x "$script_dir"/*.sh 2>/dev/null || true
    
    # CSV file for processing
    cat > "$script_dir/input/users.csv" << 'EOF'
id,name,email,department
1,Ion Popescu,ion@example.com,IT
2,Maria Ionescu,maria@example.com,HR
3,Andrei Georgescu,andrei@example.com,IT
4,Elena Dumitrescu,elena@example.com,Finance
5,Mihai Constantinescu,mihai@example.com,IT
EOF
    
    print_success "Files for script exercises created"
}

#
# CREATE PERMISSIONS SANDBOX
#

create_permission_sandbox() {
    print_header "🔐 CREATING PERMISSIONS SANDBOX"
    
    local perm_dir="$BASE_DIR/permission_lab"
    
    print_step "Creating files with various permissions..."
    
    # Public files (644)
    for name in readme.txt info.md public_data.txt; do
        echo "Public content" > "$perm_dir/public/$name"
        chmod 644 "$perm_dir/public/$name"
    done
    
    # Private files (600)
    for name in secret.txt credentials.conf private_key.pem; do
        echo "Private content - DO NOT SHARE" > "$perm_dir/private/$name"
        chmod 600 "$perm_dir/private/$name"
    done
    
    # Scripts (755)
    for name in run.sh deploy.sh backup.sh; do
        cat > "$perm_dir/scripts/$name" << SHEOF
#!/bin/bash
echo "Running $name..."
SHEOF
        chmod 755 "$perm_dir/scripts/$name"
    done
    
    # Config files (640)
    for name in app.conf database.ini settings.yaml; do
        echo "# Configuration file" > "$perm_dir/config/$name"
        chmod 640 "$perm_dir/config/$name"
    done
    
    # Files for exercises - INCORRECT permissions (to be corrected)
    print_step "Creating files with incorrect permissions (for exercises)..."
    
    mkdir -p "$perm_dir/fix_me"
    
    # Script without execute
    echo '#!/bin/bash' > "$perm_dir/fix_me/script_no_exec.sh"
    echo 'echo "Hello"' >> "$perm_dir/fix_me/script_no_exec.sh"
    chmod 644 "$perm_dir/fix_me/script_no_exec.sh"
    
    # Secret file world-readable
    echo "Password: secret123" > "$perm_dir/fix_me/too_open_secret.txt"
    chmod 644 "$perm_dir/fix_me/too_open_secret.txt"
    
    # Directory without execute (cannot be accessed)
    mkdir -p "$perm_dir/fix_me/locked_dir"
    echo "Content" > "$perm_dir/fix_me/locked_dir/file.txt"
    chmod 600 "$perm_dir/fix_me/locked_dir"
    
    # Settings for shared directory (SGID exercise)
    print_step "Configuring shared directory (SGID demonstration)..."
    chmod 770 "$perm_dir/shared"
    
    print_success "Permissions sandbox created"
    
    # Display summary
    echo ""
    print_info "Permissions summary:"
    echo "  public/   - 644 (rw-r--r--) - files readable by all"
    echo "  private/  - 600 (rw-------) - files only for owner"
    echo "  scripts/  - 755 (rwxr-xr-x) - executable scripts"
    echo "  config/   - 640 (rw-r-----) - config readable by group"
    echo "  fix_me/   - various mistakes to correct"
}

#
# CREATE FILES FOR CRON EXERCISES
#

create_cron_exercises_files() {
    print_header "⏰ CREATING FILES FOR CRON EXERCISES"
    
    local cron_dir="$BASE_DIR/cron_exercises"
    
    # Test script for cron
    print_step "Creating scripts for cron..."
    
    cat > "$cron_dir/scripts/test_cron.sh" << 'SHEOF'
#!/bin/bash
# Test script for cron
# Writes timestamp to log

LOG_FILE="${HOME}/sem5-6_lab/cron_exercises/logs/test_cron.log"

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Cron job executed" >> "$LOG_FILE"
SHEOF
    chmod 755 "$cron_dir/scripts/test_cron.sh"
    
    # Demonstration backup script
    cat > "$cron_dir/scripts/backup_demo.sh" << 'SHEOF'
#!/bin/bash
# Demo: Backup script for cron
# Pitfall: This script is for demonstration only!

set -e

# Configurations
BACKUP_DIR="${HOME}/sem5-6_lab/cron_exercises/output"
LOG_FILE="${HOME}/sem5-6_lab/cron_exercises/logs/backup.log"
SOURCE_DIR="${HOME}/sem5-6_lab/find_exercises/project"

# Logging function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# Lock file to prevent simultaneous executions
LOCK_FILE="/tmp/backup_demo.lock"
exec 200>"$LOCK_FILE"
if ! flock -n 200; then
    log "ERROR: Another instance is already running"
    exit 1
fi

log "START: Backup initiated"

# Create backup
BACKUP_NAME="backup_$(date '+%Y%m%d_%H%M%S').tar.gz"
if tar -czf "$BACKUP_DIR/$BACKUP_NAME" -C "$(dirname "$SOURCE_DIR")" "$(basename "$SOURCE_DIR")" 2>/dev/null; then
    log "SUCCESS: Backup created - $BACKUP_NAME"
else
    log "ERROR: Backup failed"
    exit 1
fi

# Clean old backups (keep last 5)
cd "$BACKUP_DIR"
ls -t backup_*.tar.gz 2>/dev/null | tail -n +6 | xargs -r rm -f

log "END: Backup completed"
SHEOF
    chmod 755 "$cron_dir/scripts/backup_demo.sh"
    
    # Monitoring script
    cat > "$cron_dir/scripts/monitor_demo.sh" << 'SHEOF'
#!/bin/bash
# Demo: System monitoring script

LOG_FILE="${HOME}/sem5-6_lab/cron_exercises/logs/monitor.log"

{
    echo "=== System Monitor Report ==="
    echo "Timestamp: $(date)"
    echo ""
    echo "--- Disk Usage ---"
    df -h / | tail -1
    echo ""
    echo "--- Memory Usage ---"
    free -h | head -2
    echo ""
    echo "--- Load Average ---"
    uptime
    echo ""
} >> "$LOG_FILE"
SHEOF
    chmod 755 "$cron_dir/scripts/monitor_demo.sh"
    
    # Template crontab
    cat > "$cron_dir/crontab_template.txt" << 'EOF'
# 
# Template Crontab for exercises
# 
# 
# Format: MIN HOUR DOM MON DOW COMMAND
#
# Fields:
#   MIN   - Minute (0-59)
#   HOUR  - Hour (0-23)
#   DOM   - Day of month (1-31)
#   MON   - Month (1-12)
#   DOW   - Day of week (0-7, 0 and 7 = Sunday)
#
# Special characters:
#   *     - Any value
#   */N   - Every N units
#   N-M   - Range from N to M
#   N,M   - List: N and M
#
# 

# Environment settings (IMPORTANT for cron!)
SHELL=/bin/bash
PATH=/usr/local/bin:/usr/bin:/bin
MAILTO=""

# 
# EXAMPLES (uncomment to activate):
# 

# Simple test - every minute
# * * * * * echo "Test $(date)" >> /tmp/cron_test.log

# Daily backup at 3 AM
# 0 3 * * * /path/to/backup.sh >> /var/log/backup.log 2>&1

# Monitoring every 15 minutes, 9-17, Monday-Friday
# */15 9-17 * * 1-5 /path/to/monitor.sh

# Weekly log cleanup (Sunday at midnight)
# 0 0 * * 0 find /var/log -name "*.log" -mtime +30 -delete

# At system restart
# @reboot /path/to/startup.sh

# 
# EXERCISES - Complete the cron expressions:
# 

# 1. Every hour, at minute 30:
# __ __ * * * echo "Hourly at :30"

# 2. Daily at 6:00 AM:
# __ __ * * * echo "Daily at 6 AM"

# 3. Every Monday at 9:00 AM:
# __ __ * * __ echo "Every Monday"

# 4. On 1st and 15th of month, at 12:00:
# __ __ ____ * * echo "Twice a month"

# 5. Every 5 minutes:
# ____ * * * * echo "Every 5 minutes"

EOF
    
    # Initialise log files
    touch "$cron_dir/logs/test_cron.log"
    touch "$cron_dir/logs/backup.log"
    touch "$cron_dir/logs/monitor.log"
    
    print_success "Files for cron exercises created"
}

#
# CREATE FILES FOR INTEGRATED EXERCISES
#

create_integration_files() {
    print_header "🔗 CREATING FILES FOR INTEGRATED EXERCISES"
    
    local int_dir="$BASE_DIR/integration"
    
    # Scenario: web project
    print_step "Creating demonstration web project structure..."
    
    mkdir -p "$int_dir/webproject"/{public,src,config,logs,backup}
    
    # Public web files
    echo "<html><body>Welcome</body></html>" > "$int_dir/webproject/public/index.html"
    echo "body { margin: 0; }" > "$int_dir/webproject/public/style.css"
    echo "console.log('loaded');" > "$int_dir/webproject/public/app.js"
    
    # Source files
    cat > "$int_dir/webproject/src/server.py" << 'EOF'
#!/usr/bin/env python3
"""Simple web server for demonstration"""
from http.server import HTTPServer, SimpleHTTPRequestHandler

if __name__ == '__main__':
    server = HTTPServer(('localhost', 8000), SimpleHTTPRequestHandler)
    print("Server running on http://localhost:8000")
    server.serve_forever()
EOF
    
    # Configurations (with simulated sensitive data)
    cat > "$int_dir/webproject/config/database.conf" << 'EOF'
# Database configuration
# Pitfall: This file contains sensitive data!
DB_HOST=localhost
DB_PORT=5432
DB_NAME=myapp
DB_USER=admin
DB_PASS=secret123
EOF
    
    cat > "$int_dir/webproject/config/app.conf" << 'EOF'
# Application settings
DEBUG=false
LOG_LEVEL=INFO
SECRET_KEY=super_secret_key_here
EOF
    
    # Log files
    for i in {1..3}; do
        echo "[$(date -d "$i days ago")] Application started" > "$int_dir/webproject/logs/app_day$i.log"
        touch -d "$i days ago" "$int_dir/webproject/logs/app_day$i.log"
    done
    
    # Set correct permissions for audit exercise
    chmod 644 "$int_dir/webproject/public"/*
    chmod 600 "$int_dir/webproject/config"/*
    chmod 755 "$int_dir/webproject/src/server.py"
    
    # README for exercise
    cat > "$int_dir/README_INTEGRATION.md" << 'EOF'
# Integrated Exercise: Web Project Administration

## Scenario
You have taken over administration of a web project. You need to:

1. **Permissions audit** - Verify and correct permissions
2. **Cleanup** - Find and archive old logs
3. **Automation** - Create cron job for backup
4. **Professional script** - Write a maintenance script with options

## Requirements

### Part 1: find
- Find all configuration files
- Find files larger than 1KB
- Find files modified in the last day

### Part 2: Permissions
- Verify that config/*.conf has permissions 600
- Verify that src/*.py is executable
- Identify files with overly permissive permissions

### Part 3: Script
- Create `maintain.sh` with options:
  - `-c` for cleanup logs
  - `-b` for backup
  - `-a` for permissions audit
  - `-v` for verbose
  - `-h` for help

### Part 4: Cron
- Configure daily backup at 2 AM
- Configure weekly cleanup

EOF
    
    print_success "Files for integrated exercises created"
}

#
# DISPLAY SUMMARY
#

show_summary() {
    print_header "📊 SETUP SUMMARY"
    
    echo -e "${BOLD}Base directory:${NC} $BASE_DIR"
    echo ""
    
    echo -e "${BOLD}Structure created:${NC}"
    if command -v tree &> /dev/null; then
        tree -L 2 "$BASE_DIR"
    else
        find "$BASE_DIR" -maxdepth 2 -type d | sed 's/[^-][^\/]*\//  |/g' | sed 's/|  /├── /g'
    fi
    
    echo ""
    echo -e "${BOLD}Statistics:${NC}"
    echo "  Directories: $(find "$BASE_DIR" -type d | wc -l)"
    echo "  Files:       $(find "$BASE_DIR" -type f | wc -l)"
    echo "  Size:        $(du -sh "$BASE_DIR" | cut -f1)"
    
    echo ""
    print_success "Setup complete!"
    
    echo ""
    echo -e "${BOLD}Next steps:${NC}"
    echo "  1. cd $BASE_DIR"
    echo "  2. Explore the structure with 'ls -la' and 'find'"
    echo "  3. Start the exercises from the instructor guide"
    echo ""
    echo -e "${YELLOW}⚠️  Pitfall:${NC}"
    echo "  - Permission exercises are done in permission_lab/"
    echo "  - Do NOT use sudo unless explicitly required"
    echo "  - Test dangerous commands (rm, chmod) with echo first"
}

#
# MAIN
#

main() {
    # Parse arguments
    while getopts ":hvcd:" opt; do
        case $opt in
            h) usage; exit 0 ;;
            v) VERBOSE=true ;;
            c) CLEANUP=true ;;
            d) BASE_DIR="$OPTARG" ;;
            \?) print_error "Invalid option: -$OPTARG"; usage; exit 1 ;;
            :) print_error "Option -$OPTARG requires argument"; exit 1 ;;
        esac
    done
    
    echo ""
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC}     ${BOLD}SETUP SEMINAR 5-6: Operating Systems${NC}                    ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}     Bucharest UES - CSIE                                      ${CYAN}║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    
    # Cleanup if requested
    if [ "$CLEANUP" = true ]; then
        cleanup_previous
    fi
    
    # Check if directory already exists
    if [ -d "$BASE_DIR" ] && [ "$CLEANUP" = false ]; then
        print_warning "Directory $BASE_DIR already exists!"
        echo "  Use -c to clean and reinstall"
        echo "  Or specify another directory with -d DIR"
        exit 1
    fi
    
    # Verify dependencies
    if ! check_dependencies; then
        exit 1
    fi
    
    # Create setup
    create_directory_structure
    create_find_exercises_files
    create_script_exercises_files
    create_permission_sandbox
    create_cron_exercises_files
    create_integration_files
    
    # Display summary
    show_summary
}

# Run
main "$@"
