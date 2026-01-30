#!/bin/bash
#
# S03_02_creeaza_tema.sh - Assignment Variant Generator Seminar 3
# Operating Systems | Bucharest UES - CSIE
#
# Generates personalised assignment variants for each student
# Prevents copying through unique scenarios and requirements
#
# Author: OS Team
# Version: 1.0
# Date: January 2025
#

set -o nounset
set -o errexit

# 
# CONSTANTS AND CONFIGURATION
# 

readonly VERSION="1.0"
readonly SCRIPT_NAME=$(basename "$0")
readonly OUTPUT_DIR="${OUTPUT_DIR:-./homework_variants}"
readonly TEMPLATE_DIR="${TEMPLATE_DIR:-./templates}"

# Colours for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[0;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

# Arrays for variant generation
declare -a EXTENSIONS=("txt" "log" "md" "c" "py" "sh" "cfg" "conf" "json" "xml" "html" "css" "js")
declare -a DIRECTORIES=("src" "docs" "tests" "build" "config" "data" "logs" "backup" "temp" "cache" "lib" "include" "bin" "scripts")
declare -a SIZE_UNITS=("k" "M" "G")
declare -a TIME_PERIODS=("7" "14" "30" "60" "90")
declare -a CRON_HOURS=("1" "2" "3" "4" "5" "6" "23" "0")
declare -a CRON_MINUTES=("0" "15" "30" "45")
declare -a PERMISSIONS_SCENARIOS=("web_server" "shared_project" "private_data" "public_docs" "development" "production")
declare -a SCRIPT_MODES=("count" "search" "transform" "analyse" "validate" "convert")

# 
# HELPER FUNCTIONS
# 

log_info() {
    echo -e "${BLUE}[INFO]${NC} $*"
}

log_success() {
    echo -e "${GREEN}[OK]${NC} $*"
}

log_warning() {
    echo -e "${YELLOW}[WARN]${NC} $*" >&2
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $*" >&2
}

usage() {
    cat << EOF
${BLUE}═══════════════════════════════════════════════════════════════════${NC}
       Assignment Variant Generator - Seminar 3 Operating Systems
${BLUE}═══════════════════════════════════════════════════════════════════${NC}

${GREEN}USAGE:${NC}
    $SCRIPT_NAME [OPTIONS] <students_file>

${GREEN}DESCRIPTION:${NC}
    Generates personalised assignment variants for each student
    from the provided list. Each variant has unique scenarios and requirements.

${GREEN}OPTIONS:${NC}
    -h, --help          Display this message
    -o, --output DIR    Output directory (default: ./homework_variants)
    -s, --seed NUM      Seed for randomisation (for reproducibility)
    -v, --verbose       Verbose mode
    -p, --preview       Preview without generating files
    -z, --zip           Create individual archives for each student
    -a, --all-in-one    Generate a single PDF with all variants

${GREEN}STUDENTS FILE FORMAT:${NC}
    Each line: SURNAME_FIRSTNAME,GROUP,EMAIL
    Example:
        Popescu_Ion,1234,ion.popescu@student.ase.ro
        Ionescu_Maria,1235,maria.ionescu@student.ase.ro

${GREEN}EXAMPLES:${NC}
    $SCRIPT_NAME students.csv
    $SCRIPT_NAME -o ./generated_assignments -z students.csv
    $SCRIPT_NAME -s 42 -v students.csv

${GREEN}OUTPUT:${NC}
    For each student the following is generated:
    - tema_sem03_SURNAME_FIRSTNAME/
      ├── README.md           (personalised instructions)
      ├── CERINTE.md          (unique requirements)
      ├── setup_tema.sh       (setup script)
      └── structura_test/     (test structure for find)

VERSION: $VERSION
EOF
}

# Generate random number within an interval
random_range() {
    local min=$1
    local max=$2
    echo $((RANDOM % (max - min + 1) + min))
}

# Select random element from an array
random_element() {
    local -n arr=$1
    echo "${arr[RANDOM % ${#arr[@]}]}"
}

# Generate unique hash from name
generate_student_hash() {
    local name=$1
    echo "$name" | md5sum | cut -c1-8
}

# 
# SCENARIO GENERATORS
# 

# Generate scenarios for find
generate_find_scenarios() {
    local hash=$1
    local num_tasks=$2
    
    local scenarios=()
    
    # Task types
    local task_types=(
        "name_search"
        "type_filter"
        "size_filter"
        "time_filter"
        "permission_filter"
        "combined_search"
        "exec_action"
        "xargs_batch"
        "delete_safe"
        "archive_find"
    )
    
    for i in $(seq 1 $num_tasks); do
        local task_type=${task_types[$((i-1))]}
        local ext1=$(random_element EXTENSIONS)
        local ext2=$(random_element EXTENSIONS)
        local dir=$(random_element DIRECTORIES)
        local size=$(random_range 1 100)
        local size_unit=$(random_element SIZE_UNITS)
        local days=$(random_element TIME_PERIODS)
        
        case $task_type in
            "name_search")
                scenarios+=("Find all .$ext1 files in the $dir/ directory")
                ;;
            "type_filter")
                scenarios+=("Find all empty directories in the project")
                ;;
            "size_filter")
                scenarios+=("Find files larger than ${size}${size_unit}")
                ;;
            "time_filter")
                scenarios+=("Find files modified in the last $days days")
                ;;
            "permission_filter")
                local perm=$(random_range 600 777)
                scenarios+=("Find files with permissions exactly $perm")
                ;;
            "combined_search")
                scenarios+=("Find .$ext1 OR .$ext2 files larger than ${size}k")
                ;;
            "exec_action")
                scenarios+=("Find .$ext1 files and display the size of each")
                ;;
            "xargs_batch")
                scenarios+=("Use xargs to count lines in all .$ext1 files")
                ;;
            "delete_safe")
                scenarios+=("Delete .tmp files older than $days days (with confirmation)")
                ;;
            "archive_find")
                scenarios+=("Archive all .$ext1 files from $dir/ into a tar.gz")
                ;;
        esac
    done
    
    printf '%s\n' "${scenarios[@]}"
}

# Generate specifications for script
generate_script_spec() {
    local hash=$1
    
    local mode=$(random_element SCRIPT_MODES)
    local options=()
    local required_options=("-h" "-v")
    local optional_options=("-o FILE" "-q" "-r" "-n NUM" "-p PATTERN" "-f FORMAT" "-e EXT")
    
    # Add random options
    local num_opts=$(random_range 3 5)
    for i in $(seq 1 $num_opts); do
        local opt=${optional_options[$((RANDOM % ${#optional_options[@]}))]}
        [[ ! " ${options[*]} " =~ " ${opt} " ]] && options+=("$opt")
    done
    
    cat << EOF
SCRIPT SPECIFICATIONS fileprocessor.sh:

MAIN MODE: $mode

MANDATORY OPTIONS:
$(printf '  %s\n' "${required_options[@]}")
$(printf '  %s\n' "${options[@]}")

FUNCTIONALITY:
EOF
    
    case $mode in
        "count")
            echo "  - Count lines, words and characters in files"
            echo "  - Support multiple file processing"
            echo "  - Display totals at the end"
            ;;
        "search")
            echo "  - Search for a pattern (regex) in files"
            echo "  - Display the line and line number"
            echo "  - Support case-insensitive search"
            ;;
        "transform")
            echo "  - Transform text (uppercase/lowercase/capitalise)"
            echo "  - Can save to file or stdout"
            echo "  - Support in-place processing with backup"
            ;;
        "analyse")
            echo "  - Analyse file structure"
            echo "  - Report: encoding, line endings, longest line"
            echo "  - Detect content type"
            ;;
        "validate")
            echo "  - Validate format (JSON, XML, CSV)"
            echo "  - Report syntax errors"
            echo "  - Offer correction suggestions"
            ;;
        "convert")
            echo "  - Convert between formats (csv<->json, tabs<->spaces)"
            echo "  - Preserve data structure"
            echo "  - Support different encodings"
            ;;
    esac
}

# Generate permission scenarios
generate_permission_scenarios() {
    local hash=$1
    local scenario=$(random_element PERMISSIONS_SCENARIOS)
    
    case $scenario in
        "web_server")
            cat << 'EOF'
SCENARIO: Web Server

You have a web_root/ directory with the structure:
- public/     (HTML, CSS, JS files accessible to all)
- private/    (configurations, sensitive data)
- uploads/    (files uploaded by users)
- logs/       (application logs)

REQUIREMENTS:
1. public/* : readable by all, writable only by owner
2. private/* : accessible only by owner (600/700)
3. uploads/ : writable by web server (group www-data)
4. logs/ : writable only by owner, readable by group

PROBLEMS TO DETECT:
- World-writable files in public/
- Incorrect permissions on private/
- SUID/SGID files (potential risk)
EOF
            ;;
        "shared_project")
            cat << 'EOF'
SCENARIO: Shared Project

A team project with the structure:
- code/       (source code)
- docs/       (documentation)
- releases/   (compiled versions)
- .git/       (Git repository)

REQUIREMENTS:
1. code/* : group read/write (664/775)
2. releases/* : group read, owner write (644/755)
3. .git/ : preserved as-is
4. Executables in code/scripts/ : must have +x

PROBLEMS TO DETECT:
- Files without group permissions
- Scripts without execute permission
- Hidden files with 777
EOF
            ;;
        "private_data")
            cat << 'EOF'
SCENARIO: Private Data

Personal directory with sensitive data:
- documents/  (personal documents)
- financial/  (financial data)
- medical/    (medical information)
- backup/     (automatic backups)

REQUIREMENTS:
1. ALL files: 600 (owner only)
2. ALL directories: 700
3. NO file should be world-readable
4. NO directory should have 777

PROBLEMS TO DETECT:
- Any file with world-readable permissions
- Directories with group/world access
- Any SUID/SGID (should not exist here)
EOF
            ;;
        "public_docs")
            cat << 'EOF'
SCENARIO: Public Documentation

Documentation server:
- html/       (static HTML)
- downloads/  (downloadable files)
- api/        (API documentation)
- admin/      (administration panel)

REQUIREMENTS:
1. html/*, api/* : world readable (644/755)
2. downloads/* : world readable, no execute
3. admin/* : access only for admin group
4. No world-writable file allowed

PROBLEMS TO DETECT:
- Files without read for others in html/
- Executable files in downloads/
- Incorrect permissions on admin/
EOF
            ;;
        "development")
            cat << 'EOF'
SCENARIO: Development Environment

Developer home with:
- projects/   (active projects)
- tools/      (custom scripts and tools)
- .config/    (application configurations)
- .ssh/       (SSH keys)

REQUIREMENTS:
1. projects/* : flexible (644-755)
2. tools/* : executable for owner (700/755)
3. .config/* : owner only (600/700)
4. .ssh/* : STRICT 600 for keys, 644 for .pub

PROBLEMS TO DETECT:
- .ssh/ with wrong permissions (CRITICAL)
- Config files readable by others
- Scripts without +x in tools/
EOF
            ;;
        "production")
            cat << 'EOF'
SCENARIO: Production Server

Production application:
- app/        (application code)
- config/     (configurations with secrets)
- data/       (application data)
- logs/       (production logs)

REQUIREMENTS:
1. app/* : readable by app user, owner write
2. config/* : STRICT 600, only deployment user
3. data/* : writable by app, not world
4. logs/* : writable by app, rotatable

PROBLEMS TO DETECT:
- config/ with incorrect permissions (CRITICAL)
- World-writable files (CRITICAL)
- SUID/SGID on scripts (CRITICAL)
- 777 on any file (CRITICAL)
EOF
            ;;
    esac
}

# Generate cron requirements
generate_cron_requirements() {
    local hash=$1
    
    local hour1=$(random_element CRON_HOURS)
    local hour2=$(random_element CRON_HOURS)
    local min1=$(random_element CRON_MINUTES)
    local days=$(random_element TIME_PERIODS)
    
    cat << EOF
Create 5 functional cron jobs:

1. **Daily Backup** (3%)
   - When: Every day at ${hour1}:${min1}
   - What: Run backup.sh with logging
   - Log: /var/log/backup.log

2. **Temp Cleanup** (3%)
   - When: Every 6 hours
   - What: Delete .tmp files older than ${days} days from /tmp
   - SAFE: Use find with -mtime, NOT rm -rf

3. **Disk Monitor** (3%)
   - When: Every 30 minutes
   - What: Check disk space, alert if > 90%
   - Log: Warning to /var/log/disk_monitor.log

4. **Weekly Sync** (3%)
   - When: Every Sunday at ${hour2}:00
   - What: rsync ~/docs to /backup/docs
   - Options: archive, verbose, delete

5. **Monthly Rotation** (3%)
   - When: 1st of month at midnight
   - What: Compress and archive logs from /var/log/myapp/
   - Format: logs_YYYY_MM.tar.gz
EOF
}

# 
# VARIANT GENERATION
# 

generate_variant() {
    local name=$1
    local grupa=$2
    local email=$3
    local output_dir=$4
    
    local hash=$(generate_student_hash "$name")
    local student_dir="$output_dir/tema_sem03_$name"
    
    # Seed based on student hash for reproducibility
    RANDOM=$(echo "$hash" | tr -d 'a-f' | cut -c1-5)
    
    log_info "Generating: $name (group: $grupa) [hash: $hash]"
    
    # Create directory structure
    mkdir -p "$student_dir"/{structura_test,parte1_find,parte2_script,parte3_permissions,parte4_cron,parte5_integration}
    
    # Generate README.md
    cat > "$student_dir/README.md" << EOF
# Seminar 3 Assignment - $name

**Group**: $grupa  
**Email**: $email  
**Variant code**: $hash

## Instructions

1. Read \`CERINTE.md\` carefully for your unique requirements
2. Run \`./setup_tema.sh\` to create the test structure
3. Work in the corresponding directories for each part
4. Test everything before submission
5. Create the archive: \`tar -czvf tema_sem03_$name.tar.gz tema_sem03_$name/\`

## Important

- All scripts must be executable (\`chmod +x\`)
- All scripts must have shebang \`#!/bin/bash\`
- Test on Ubuntu 24.04 / WSL2
- Use \`shellcheck\` to verify syntax

## Support

- If you have questions, mention the variant code: **$hash**
- Check forum for common questions
EOF

    # Generate CERINTE.md with unique requirements
    cat > "$student_dir/CERINTE.md" << EOF
# Unique Requirements - Variant $hash

Student: **$name** | Group: **$grupa**

---

## Part 1: Find Master (20%)

Create \`comenzi_find.sh\` with 10 commands for your scenarios:

$(generate_find_scenarios "$hash" 10 | nl -w2 -s'. ')

### Requirements for each command:
- Must be functional and tested
- Include explanatory comments
- Use appropriate options (-print0 where necessary)
- Handle filenames with spaces

---

## Part 2: Professional Script (30%)

$(generate_script_spec "$hash")

### Script requirements:
- getopts for short options
- Support for long options (manual)
- Complete usage() function
- Input validation
- Correct exit codes (0/1/2)

---

## Part 3: Permission Manager (25%)

$(generate_permission_scenarios "$hash")

### Requirements for permaudit.sh:
- Automatic problem detection
- Report with severities (CRITICAL/WARNING/INFO)
- Correction option with confirmation
- Coloured output in terminal

---

## Part 4: Cron Jobs (15%)

$(generate_cron_requirements "$hash")

### Requirements:
- File \`cron_entries.txt\` with all crontab lines
- Functional \`backup.sh\` script with lock file
- All commands with absolute paths
- Logging correctly configured

---

## Part 5: Integration Challenge (10%)

Create \`sysadmin_toolkit.sh\` - interactive menu that integrates:
1. Find functions from Part 1
2. File processing from Part 2
3. Permission audit from Part 3
4. Cron helper from Part 4

---

##  Final Checklist

- [ ] All scripts are executable
- [ ] ShellCheck reports no errors
- [ ] I have tested on the structure from \`structura_test/\`
- [ ] README.md completed with observations
- [ ] Archive: \`tema_sem03_${name}.tar.gz\`

---

**Variant code: $hash** - Use it if you have questions about requirements.
EOF

    # Generate setup_tema.sh
    cat > "$student_dir/setup_tema.sh" << 'SETUP_EOF'
#!/bin/bash
#
# setup_tema.sh - Environment preparation for Sem 03 assignment
#

set -e

echo "🔧 Preparing environment for assignment..."

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEST_DIR="$SCRIPT_DIR/structura_test"

# Check that we are in the correct directory
if [[ ! -f "$SCRIPT_DIR/CERINTE.md" ]]; then
    echo "❌ Error: Run from the assignment directory!"
    exit 1
fi

# Create test structure
echo "📁 Creating test structure..."

mkdir -p "$TEST_DIR"/{src/{core,utils,deprecated},docs/{api,guides,images},build/{debug,release},tests/{unit,integration,data},config,logs,temp,backup}

# Create various files
echo "📄 Creating test files..."

# Source files
for f in main utils config helper; do
    echo "// $f.c - Source file" > "$TEST_DIR/src/core/$f.c"
    echo "// $f.h - Header file" > "$TEST_DIR/src/core/$f.h"
done

# Python files
for f in test_main test_utils test_integration; do
    echo "# $f.py - Test file" > "$TEST_DIR/tests/unit/$f.py"
done

# Documentation
echo "# README" > "$TEST_DIR/docs/README.md"
echo "# API Documentation" > "$TEST_DIR/docs/api/reference.md"
echo "User Guide" > "$TEST_DIR/docs/guides/guide.txt"

# Large files (for size tests)
dd if=/dev/zero of="$TEST_DIR/backup/large_backup.tar.gz" bs=1M count=5 2>/dev/null
dd if=/dev/zero of="$TEST_DIR/build/debug/core_dump.bin" bs=1M count=2 2>/dev/null

# Temporary files
touch "$TEST_DIR/temp/session.tmp"
touch "$TEST_DIR/temp/cache.tmp"
touch "$TEST_DIR/logs/app.log"
touch "$TEST_DIR/logs/error.log"

# Set different timestamps for time tests
touch -d "60 days ago" "$TEST_DIR/src/deprecated/old_code.c"
touch -d "30 days ago" "$TEST_DIR/backup/old_backup.tar"
touch -d "7 days ago" "$TEST_DIR/logs/weekly.log"
touch -d "1 day ago" "$TEST_DIR/logs/daily.log"

# Files with spaces in names (for xargs tests)
touch "$TEST_DIR/docs/my document.txt"
touch "$TEST_DIR/docs/file with spaces.md"

# Set various permissions for tests
chmod 777 "$TEST_DIR/temp/insecure.txt" 2>/dev/null || touch "$TEST_DIR/temp/insecure.txt"
chmod 600 "$TEST_DIR/config/secrets.cfg" 2>/dev/null || touch "$TEST_DIR/config/secrets.cfg"
chmod 755 "$TEST_DIR/src/core/main.c"

# Create empty directory for -empty tests
mkdir -p "$TEST_DIR/empty_dir"

echo ""
echo "✅ Setup complete!"
echo ""
echo "📊 Structure created:"
find "$TEST_DIR" -maxdepth 2 | head -30
echo "   ... and more"
echo ""
echo "🚀 You can now test find commands in: $TEST_DIR"
SETUP_EOF

    chmod +x "$student_dir/setup_tema.sh"
    
    log_success "Variant generated: $student_dir"
}

# 
# STUDENT LIST PROCESSING
# 

process_students_file() {
    local file=$1
    local output_dir=$2
    local preview=${3:-0}
    local create_zip=${4:-0}
    
    if [[ ! -f "$file" ]]; then
        log_error "File does not exist: $file"
        exit 1
    fi
    
    # Create output directory
    mkdir -p "$output_dir"
    
    local count=0
    local errors=0
    
    while IFS=',' read -r name grupa email || [[ -n "$name" ]]; do
        # Skip empty lines or comments
        [[ -z "$name" || "$name" =~ ^# ]] && continue
        
        # Clean whitespace
        name=$(echo "$name" | tr -d '[:space:]')
        grupa=$(echo "$grupa" | tr -d '[:space:]')
        email=$(echo "$email" | tr -d '[:space:]')
        
        # Validation
        if [[ -z "$name" || -z "$grupa" ]]; then
            log_warning "Invalid line ignored: $name,$grupa,$email"
            ((errors++))
            continue
        fi
        
        if [[ $preview -eq 1 ]]; then
            echo "  📋 $name (group: $grupa) - hash: $(generate_student_hash "$name")"
        else
            generate_variant "$name" "$grupa" "${email:-N/A}" "$output_dir"
            
            if [[ $create_zip -eq 1 ]]; then
                local student_dir="$output_dir/tema_sem03_$name"
                (cd "$output_dir" && zip -rq "tema_sem03_$name.zip" "tema_sem03_$name")
                log_info "  Archive created: tema_sem03_$name.zip"
            fi
        fi
        
        ((count++))
    done < "$file"
    
    echo ""
    log_success "Processed: $count students"
    [[ $errors -gt 0 ]] && log_warning "Errors: $errors"
}

# 
# MAIN
# 

main() {
    local output_dir="$OUTPUT_DIR"
    local seed=""
    local verbose=0
    local preview=0
    local create_zip=0
    local input_file=""
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                usage
                exit 0
                ;;
            -o|--output)
                output_dir="$2"
                shift 2
                ;;
            -s|--seed)
                seed="$2"
                shift 2
                ;;
            -v|--verbose)
                verbose=1
                shift
                ;;
            -p|--preview)
                preview=1
                shift
                ;;
            -z|--zip)
                create_zip=1
                shift
                ;;
            -*)
                log_error "Unknown option: $1"
                usage
                exit 1
                ;;
            *)
                input_file="$1"
                shift
                ;;
        esac
    done
    
    # Check input
    if [[ -z "$input_file" ]]; then
        log_error "Missing students file!"
        echo ""
        usage
        exit 1
    fi
    
    # Set seed if specified
    if [[ -n "$seed" ]]; then
        RANDOM=$seed
        log_info "Seed set: $seed"
    fi
    
    echo ""
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════════${NC}"
    echo -e "     ${GREEN}Assignment Variant Generator - Seminar 3 OS${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════════${NC}"
    echo ""
    
    if [[ $preview -eq 1 ]]; then
        log_info "PREVIEW MODE - files will not be generated"
        echo ""
    fi
    
    log_info "Input file: $input_file"
    log_info "Output directory: $output_dir"
    echo ""
    
    process_students_file "$input_file" "$output_dir" "$preview" "$create_zip"
    
    echo ""
    if [[ $preview -eq 0 ]]; then
        log_success "Variants generated in: $output_dir"
        echo ""
        echo "📊 Contents:"
        ls -la "$output_dir" | head -20
    fi
}

main "$@"
