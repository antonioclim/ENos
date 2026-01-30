#!/bin/bash
#
# S05_02_create_homework.sh - Assignment Template Generator
# 
# Operating Systems | ASE Bucharest - CSIE
# Seminar 5: Advanced Bash Scripting
#
# This script creates the basic structure for your assignment.
# Run it once, then complete the created files.
#
# Usage: ./S05_02_create_homework.sh "YourName" "Group"
#

set -euo pipefail
IFS=$'\n\t'

# Verify arguments
if [[ $# -lt 2 ]]; then
    echo "Usage: $0 \"Your Name\" \"Group\""
    echo "Example: $0 \"Popescu Ion\" \"1234\""
    exit 1
fi

STUDENT_NAME="$1"
GROUP="$2"
DATE_CREATED=$(date +%Y-%m-%d)
HOMEWORK_DIR="$HOME/homework_S05_${STUDENT_NAME// /_}"

echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║     CREATING ASSIGNMENT STRUCTURE - Advanced Bash Scripting   ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""
echo "Student: $STUDENT_NAME"
echo "Group:   $GROUP"
echo "Date:    $DATE_CREATED"
echo ""

# Check if directory already exists
if [[ -d "$HOMEWORK_DIR" ]]; then
    echo "⚠️  Directory $HOMEWORK_DIR already exists!"
    read -p "Do you want to delete it and create a new one? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -rf "$HOMEWORK_DIR"
    else
        echo "Operation cancelled."
        exit 1
    fi
fi

# Create structure
echo "📁 Creating directory structure..."
mkdir -p "$HOMEWORK_DIR"/{test_files,screenshots}

# Create README.md
echo "📝 Creating README.md..."
cat > "$HOMEWORK_DIR/README.md" << EOF
# Assignment Seminar 05: Advanced Bash Scripting

**Author:** $STUDENT_NAME  
**Group:** $GROUP  
**Date:** $DATE_CREATED

---

##  Project Structure

\`\`\`
homework_S05_${STUDENT_NAME// /_}/
├── README.md              # This file
├── log_analyzer.sh        # Requirement 1 - Log analysis
├── config_manager.sh      # Requirement 2 - Configuration manager
├── refactored_script.sh   # Requirement 3 - Refactored script
├── test_files/
│   ├── sample.log         # Test log file
│   └── app.conf           # Test config file
└── screenshots/           # Output screenshots
\`\`\`

---

##  How to Run

### Log Analyser
\`\`\`bash
./log_analyzer.sh test_files/sample.log
./log_analyzer.sh -l ERROR test_files/sample.log
./log_analyzer.sh --top 3 -v test_files/sample.log
\`\`\`

### Config Manager
\`\`\`bash
./config_manager.sh list
./config_manager.sh get HOST
./config_manager.sh set DEBUG true
./config_manager.sh validate
\`\`\`

### Refactored Script
\`\`\`bash
./refactored_script.sh file1.txt file2.txt
\`\`\`

---

##  Pre-Submission Checklist

- [ ] \`shellcheck log_analyzer.sh\` - no errors
- [ ] \`shellcheck config_manager.sh\` - no errors
- [ ] \`shellcheck refactored_script.sh\` - no errors
- [ ] All scripts have \`set -euo pipefail\`
- [ ] All functions use \`local\`
- [ ] Associative arrays declared with \`declare -A\`
- [ ] Argument validation implemented
- [ ] Trap EXIT for cleanup

---

##  Notes and Observations

[Add any difficulties encountered or observations here]

---

##  AI Tools (if applicable)

[If you used ChatGPT/Claude/Copilot, mention which parts here]

---

*Assignment for the Operating Systems course | ASE Bucharest - CSIE*
EOF

# Create log_analyzer.sh (template)
echo "📝 Creating log_analyzer.sh (template)..."
cat > "$HOMEWORK_DIR/log_analyzer.sh" << 'SCRIPT'
#!/bin/bash
#
# log_analyzer.sh - Log file analyser
# Author: [COMPLETE]
# Date: [COMPLETE]
#
# Usage: ./log_analyzer.sh [options] <log_file>
#

set -euo pipefail
IFS=$'\n\t'

#
# GLOBAL VARIABLES
#
readonly SCRIPT_NAME="${0##*/}"
readonly VERSION="1.0.0"

# Options
VERBOSE=false
LEVEL_FILTER=""
OUTPUT_FILE=""
TOP_N=5

# Arrays for statistics
declare -A LEVEL_COUNT
declare -A MESSAGE_COUNT

#
# FUNCTIONS
#

usage() {
    cat << EOF
Usage: $SCRIPT_NAME [options] <log_file>

Analyses log files and generates statistics.

Options:
  -h, --help          Display this message
  -v, --verbose       Verbose mode
  -l, --level LEVEL   Filter by level (INFO, WARN, ERROR, DEBUG)
  -o, --output FILE   Save output to file
  --top N             Display top N messages (default: $TOP_N)
  --version           Display version

Example:
  $SCRIPT_NAME access.log
  $SCRIPT_NAME -l ERROR --top 10 server.log
EOF
}

log_verbose() {
    # TODO: Implement verbose logging
    # Hint: if $VERBOSE; then echo "[VERBOSE] $*" >&2; fi
    :
}

parse_line() {
    # TODO: Parse a log line
    # Format: [TIMESTAMP] [LEVEL] Message
    local line="$1"
    echo "TODO: Implement parse_line"
}

count_levels() {
    # TODO: Count entries by level
    echo "TODO: Implement count_levels"
}

get_top_messages() {
    # TODO: Return the top N most frequent messages
    local n="${1:-$TOP_N}"
    echo "TODO: Implement get_top_messages"
}

print_report() {
    # TODO: Display the final report
    local log_file="$1"
    echo "═══════════════════════════════════════════"
    echo "Log Analysis Report: $log_file"
    echo "═══════════════════════════════════════════"
    echo ""
    echo "TODO: Complete the report"
}

cleanup() {
    log_verbose "Cleanup..."
}

#
# MAIN
#

main() {
    trap cleanup EXIT
    
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help) usage; exit 0 ;;
            -v|--verbose) VERBOSE=true; shift ;;
            -l|--level) LEVEL_FILTER="$2"; shift 2 ;;
            -o|--output) OUTPUT_FILE="$2"; shift 2 ;;
            --top) TOP_N="$2"; shift 2 ;;
            --version) echo "$SCRIPT_NAME version $VERSION"; exit 0 ;;
            -*) echo "Unknown option: $1" >&2; usage; exit 1 ;;
            *) break ;;
        esac
    done
    
    if [[ $# -lt 1 ]]; then
        echo "Error: Log file missing" >&2
        usage
        exit 1
    fi
    
    local log_file="$1"
    
    if [[ ! -f "$log_file" ]]; then
        echo "Error: File '$log_file' does not exist" >&2
        exit 1
    fi
    
    log_verbose "Analysing: $log_file"
    print_report "$log_file"
}

main "$@"
SCRIPT
chmod +x "$HOMEWORK_DIR/log_analyzer.sh"

# Create config_manager.sh (template)
echo "📝 Creating config_manager.sh (template)..."
cat > "$HOMEWORK_DIR/config_manager.sh" << 'SCRIPT'
#!/bin/bash
#
# config_manager.sh - Manager for configuration files
# Author: [COMPLETE]
# Date: [COMPLETE]
#
# Usage: ./config_manager.sh <command> [args]
#

set -euo pipefail
IFS=$'\n\t'

readonly SCRIPT_NAME="${0##*/}"
readonly CONFIG_FILE="${CONFIG_FILE:-./app.conf}"

declare -A CONFIG
readonly REQUIRED_KEYS=("HOST" "PORT")

usage() {
    cat << EOF
Usage: $SCRIPT_NAME <command> [args]

Manages key=value configuration files.

Commands:
  get <key>        Get the value of a key
  set <key> <val>  Set a value
  delete <key>     Delete a key
  list             List all keys
  validate         Validate configuration
  export           Export as environment variables

Example:
  $SCRIPT_NAME list
  $SCRIPT_NAME get HOST
  $SCRIPT_NAME set PORT 9090
EOF
}

load_config() {
    # TODO: Load the configuration file into the CONFIG array
    if [[ ! -f "$CONFIG_FILE" ]]; then
        return 1
    fi
    echo "TODO: Implement load_config"
}

save_config() { echo "TODO: Implement save_config"; }
get_value() { local key="$1"; echo "TODO: Implement get_value for '$key'"; }
set_value() { local key="$1" value="$2"; echo "TODO: Implement set_value"; }
delete_key() { local key="$1"; echo "TODO: Implement delete_key"; }
list_config() { echo "TODO: Implement list_config"; }
validate_config() { echo "TODO: Implement validate_config"; }
export_config() { echo "TODO: Implement export_config"; }

main() {
    if [[ $# -lt 1 ]]; then usage; exit 1; fi
    
    local command="$1"
    shift
    load_config || true
    
    case "$command" in
        get) [[ $# -lt 1 ]] && { echo "Error: key missing" >&2; exit 1; }; get_value "$1" ;;
        set) [[ $# -lt 2 ]] && { echo "Error: key/value missing" >&2; exit 1; }; set_value "$1" "$2"; save_config ;;
        delete) [[ $# -lt 1 ]] && { echo "Error: key missing" >&2; exit 1; }; delete_key "$1"; save_config ;;
        list) list_config ;;
        validate) validate_config ;;
        export) export_config ;;
        -h|--help) usage ;;
        *) echo "Unknown command: $command" >&2; usage; exit 1 ;;
    esac
}

main "$@"
SCRIPT
chmod +x "$HOMEWORK_DIR/config_manager.sh"

# Create refactored_script.sh (template)
echo "📝 Creating refactored_script.sh (template)..."
cat > "$HOMEWORK_DIR/refactored_script.sh" << 'SCRIPT'
#!/bin/bash
#
# refactored_script.sh - Refactored script
# Author: [COMPLETE]
# Date: [COMPLETE]
#
# Original: broken_script.sh (with issues)
# Usage: ./refactored_script.sh [options] <files...>
#

# TODO: Add set -euo pipefail and IFS=$'\n\t'

readonly SCRIPT_NAME="${0##*/}"

# TODO: Declare the associative array correctly
# declare -A config

usage() {
    cat << EOF
Usage: $SCRIPT_NAME [options] <files...>
Options:
  -h, --help    Display this message
  -v, --verbose Verbose mode
EOF
}

cleanup() { :; }

process_files() {
    # TODO: Refactor - use local, avoid UUOC, quote arrays
    echo "TODO: Implement refactored process_files"
}

main() {
    # TODO: Add trap cleanup EXIT
    local -a files=()
    
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help) usage; exit 0 ;;
            -v|--verbose) shift ;;
            -*) echo "Unknown option: $1" >&2; exit 1 ;;
            *) [[ -f "$1" ]] && files+=("$1") || echo "Warning: '$1' is not a valid file" >&2; shift ;;
        esac
    done
    
    if [[ ${#files[@]} -eq 0 ]]; then
        echo "Error: No files specified" >&2
        usage
        exit 1
    fi
    
    process_files "${files[@]}"
    echo "Processed ${#files[@]} files"
}

main "$@"
SCRIPT
chmod +x "$HOMEWORK_DIR/refactored_script.sh"

# Create test files
echo "📝 Creating test files..."
cat > "$HOMEWORK_DIR/test_files/sample.log" << 'EOF'
[2025-01-15 10:00:00] [INFO] Application started
[2025-01-15 10:00:05] [DEBUG] Loading config from /etc/app.conf
[2025-01-15 10:00:10] [WARN] Config file not found, using defaults
[2025-01-15 10:00:15] [INFO] Server listening on port 8080
[2025-01-15 10:00:20] [ERROR] Connection refused to database
[2025-01-15 10:00:25] [INFO] Retry connection (attempt 1/3)
[2025-01-15 10:00:30] [INFO] Database connected
[2025-01-15 10:00:35] [INFO] Application started
[2025-01-15 10:01:00] [DEBUG] Processing request from 192.168.1.1
[2025-01-15 10:01:05] [INFO] Request completed in 45ms
[2025-01-15 10:01:10] [WARN] High memory usage: 85%
[2025-01-15 10:01:15] [ERROR] Out of memory
EOF

cat > "$HOMEWORK_DIR/test_files/app.conf" << 'EOF'
# Application Configuration
HOST=localhost
PORT=8080
DEBUG=true
DB_HOST=db.example.com
DB_PORT=5432
DB_NAME=development
LOG_LEVEL=DEBUG
LOG_FILE=/var/log/app.log
EOF

# Final display
echo ""
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║              STRUCTURE CREATED SUCCESSFULLY!                  ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""
echo "Directory: $HOMEWORK_DIR"
echo ""
echo "Next steps:"
echo "  1. cd $HOMEWORK_DIR"
echo "  2. Complete the scripts (search for TODOs)"
echo "  3. Verify with: shellcheck *.sh"
echo "  4. Create archive: zip -r homework_S05_${STUDENT_NAME// /_}.zip ."
echo ""
echo "Done!"
