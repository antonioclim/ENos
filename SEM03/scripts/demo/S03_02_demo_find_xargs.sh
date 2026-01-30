#!/bin/bash
#
#  S03_02_demo_find_xargs.sh
# Incremental demonstration: find and xargs
#
#
# DESCRIPTION:
#   Demonstration script for find and xargs commands.
#   Presents concepts incrementally, from simple to complex.
#   Includes interactive exercises and predictions for students.
#
# USAGE:
#   ./S03_02_demo_find_xargs.sh [options]
#
# OPTIONS:
#   -h, --help      Display this help
#   -i, --interactive   Interactive mode with pauses
#   -s, --section NUM   Run only one section (1-8)
#   -a, --all           Run all sections without pause
#   -c, --cleanup       Delete demo directories
#
# AUTHOR: SO Seminar Kit - Bucharest UES
# VERSION: 1.0
#

set -e  # Exit on error

# ═══════════════════════════════════════════════════════════════════════════════
# CONFIGURATION
# ═══════════════════════════════════════════════════════════════════════════════

DEMO_DIR="$HOME/find_demo_lab"
INTERACTIVE=false
RUN_SECTION=""
RUN_ALL=false

# Colours
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
GRAY='\033[0;90m'
NC='\033[0m' # No Color
BOLD='\033[1m'
DIM='\033[2m'

# ═══════════════════════════════════════════════════════════════════════════════
# UTILITY FUNCTIONS
# ═══════════════════════════════════════════════════════════════════════════════

print_header() {
    local title="$1"
    local width=70
    echo ""
    echo -e "${CYAN}╔$(printf '═%.0s' $(seq 1 $((width-2))))╗${NC}"
    printf "${CYAN}║${NC} ${BOLD}${WHITE}%-$((width-4))s${NC} ${CYAN}║${NC}\n" "$title"
    echo -e "${CYAN}╚$(printf '═%.0s' $(seq 1 $((width-2))))╝${NC}"
    echo ""
}

print_subheader() {
    local title="$1"
    echo ""
    echo -e "${YELLOW}┌──────────────────────────────────────────────────────────────────┐${NC}"
    echo -e "${YELLOW}│${NC} ${BOLD}$title${NC}"
    echo -e "${YELLOW}└──────────────────────────────────────────────────────────────────┘${NC}"
}

print_concept() {
    local concept="$1"
    echo -e "\n${MAGENTA}💡 CONCEPT:${NC} ${WHITE}$concept${NC}\n"
}

print_command() {
    local cmd="$1"
    echo -e "${GREEN}▶${NC} ${BOLD}${WHITE}$cmd${NC}"
}

print_explanation() {
    local text="$1"
    echo -e "  ${GRAY}↳ $text${NC}"
}

print_prediction() {
    local question="$1"
    echo ""
    echo -e "${BLUE}┌─ 🤔 PREDICTION ────────────────────────────────────────────────────┐${NC}"
    echo -e "${BLUE}│${NC} $question"
    echo -e "${BLUE}└────────────────────────────────────────────────────────────────────┘${NC}"
}

print_warning() {
    local text="$1"
    echo -e "\n${RED}⚠️  Pitfall:${NC} ${YELLOW}$text${NC}"
}

print_tip() {
    local text="$1"
    echo -e "\n${GREEN}💚 TIP:${NC} $text"
}

run_demo() {
    local cmd="$1"
    local description="$2"
    
    print_command "$cmd"
    [[ -n "$description" ]] && print_explanation "$description"
    echo -e "${DIM}─────────── OUTPUT ───────────${NC}"
    eval "$cmd" 2>&1 || true
    echo -e "${DIM}──────────────────────────────${NC}"
}

pause_interactive() {
    if [[ "$INTERACTIVE" == true ]]; then
        echo ""
        echo -e "${CYAN}⏸  Press ENTER to continue...${NC}"
        read -r
    fi
}

show_usage() {
    cat << 'EOF'
═══════════════════════════════════════════════════════════════════════════════
 📁 find and xargs Demo - Usage
═══════════════════════════════════════════════════════════════════════════════

SYNTAX:
  ./S03_02_demo_find_xargs.sh [options]

OPTIONS:
  -h, --help          Display this help
  -i, --interactive   Interactive mode with pauses between sections
  -s, --section NUM   Run only the specified section (1-8)
  -a, --all           Run all sections without pauses
  -c, --cleanup       Delete created demo directories

SECTIONS:
  1 - Introduction and setup
  2 - find: search by name
  3 - find: search by type and size
  4 - find: search by time
  5 - find: logical operators
  6 - find: actions (-exec, -delete)
  7 - xargs: batch processing
  8 - Advanced find + xargs combinations

EXAMPLES:
  ./S03_02_demo_find_xargs.sh -i              # Full interactive demo
  ./S03_02_demo_find_xargs.sh -s 3            # Only section 3
  ./S03_02_demo_find_xargs.sh -a              # Everything without pauses

═══════════════════════════════════════════════════════════════════════════════
EOF
}

# ═══════════════════════════════════════════════════════════════════════════════
# SETUP ENVIRONMENT
# ═══════════════════════════════════════════════════════════════════════════════

setup_demo_environment() {
    print_header "📁 SETUP: Creating Demo Environment"
    
    echo -e "${CYAN}Creating directory structure for demonstration...${NC}\n"
    
    # Create structure
    mkdir -p "$DEMO_DIR"/{project/{src,include,docs,tests,build},logs,data,backup,temp}
    
    # C code files
    cat > "$DEMO_DIR/project/src/main.c" << 'CCODE'
#include <stdio.h>
int main() {
    printf("Hello, World!\n");
    return 0;
}
CCODE
    
    cat > "$DEMO_DIR/project/src/utils.c" << 'CCODE'
#include "utils.h"
void helper_function() {
    // Implementation
}
CCODE
    
    cat > "$DEMO_DIR/project/src/config.c" << 'CCODE'
#include "config.h"
// Configuration handling
CCODE
    
    # Header files
    echo '/* Main header */' > "$DEMO_DIR/project/include/main.h"
    echo '/* Utils header */' > "$DEMO_DIR/project/include/utils.h"
    echo '/* Config header */' > "$DEMO_DIR/project/include/config.h"
    
    # Documentation files
    echo "# Project README" > "$DEMO_DIR/project/docs/README.md"
    echo "API Documentation" > "$DEMO_DIR/project/docs/api.txt"
    echo "<html><body>Manual</body></html>" > "$DEMO_DIR/project/docs/manual.html"
    
    # Python test files
    for i in 1 2 3 4 5; do
        cat > "$DEMO_DIR/project/tests/test_$i.py" << PYCODE
#!/usr/bin/env python3
# Test file $i
import unittest

class Test$i(unittest.TestCase):
    def test_basic(self):
        self.assertTrue(True)

if __name__ == '__main__':
    unittest.main()
PYCODE
    done
    
    # Build files (binaries and objects)
    dd if=/dev/zero of="$DEMO_DIR/project/build/program.o" bs=1K count=50 2>/dev/null
    dd if=/dev/zero of="$DEMO_DIR/project/build/main.exe" bs=1K count=200 2>/dev/null
    
    # Log files with different timestamps
    for i in {1..10}; do
        echo "Log entry $i - $(date -d "-$i days" '+%Y-%m-%d %H:%M:%S')" > "$DEMO_DIR/logs/app_$i.log"
        touch -d "-$i days" "$DEMO_DIR/logs/app_$i.log"
    done
    
    # Large files for -size demonstration
    dd if=/dev/zero of="$DEMO_DIR/data/small.dat" bs=1K count=10 2>/dev/null
    dd if=/dev/zero of="$DEMO_DIR/data/medium.dat" bs=1K count=500 2>/dev/null
    dd if=/dev/zero of="$DEMO_DIR/data/large.dat" bs=1M count=2 2>/dev/null
    dd if=/dev/zero of="$DEMO_DIR/data/huge.dat" bs=1M count=5 2>/dev/null
    
    # Files with spaces in names (for xargs demonstration)
    touch "$DEMO_DIR/data/file with spaces.txt"
    touch "$DEMO_DIR/data/another file.txt"
    touch "$DEMO_DIR/data/my document.txt"
    
    # Backup files
    cp "$DEMO_DIR/project/src/main.c" "$DEMO_DIR/backup/main.c.bak"
    cp "$DEMO_DIR/project/src/utils.c" "$DEMO_DIR/backup/utils.c.old"
    touch "$DEMO_DIR/backup/config~"
    
    # Temporary files
    touch "$DEMO_DIR/temp/temp_001.tmp"
    touch "$DEMO_DIR/temp/cache_abc.tmp"
    touch "$DEMO_DIR/temp/.hidden_temp"
    
    # Symbolic link
    ln -sf "$DEMO_DIR/project/src/main.c" "$DEMO_DIR/project/main_link.c"
    
    # Display structure
    echo -e "${GREEN}✓ Structure created:${NC}"
    echo ""
    tree "$DEMO_DIR" 2>/dev/null || find "$DEMO_DIR" -type d | head -20
    
    echo ""
    echo -e "${GREEN}✓ Setup complete!${NC}"
    echo -e "${GRAY}Location: $DEMO_DIR${NC}"
}

cleanup_demo() {
    print_header "🧹 Cleanup"
    
    if [[ -d "$DEMO_DIR" ]]; then
        echo -e "${YELLOW}Deleting demo directory: $DEMO_DIR${NC}"
        rm -rf "$DEMO_DIR"
        echo -e "${GREEN}✓ Cleanup complete!${NC}"
    else
        echo -e "${GRAY}Demo directory does not exist.${NC}"
    fi
}

# ═══════════════════════════════════════════════════════════════════════════════
# SECTION 1: INTRODUCTION
# ═══════════════════════════════════════════════════════════════════════════════

section_1_intro() {
    print_header "📚 SECTION 1: Introduction to find"
    
    print_concept "find - the recursive file system search command"
    
    echo -e "${WHITE}GENERAL SYNTAX:${NC}"
    echo ""
    echo -e "  ${CYAN}find [PATH] [EXPRESSIONS] [ACTIONS]${NC}"
    echo ""
    echo "  PATH        = where to search (. = current, / = root, ~ = home)"
    echo "  EXPRESSIONS = filter criteria (-name, -type, -size, etc.)"
    echo "  ACTIONS     = what to do with results (-print, -exec, -delete)"
    
    echo ""
    echo -e "${WHITE}WHY find instead of ls?${NC}"
    echo ""
    echo "  • find searches RECURSIVELY (in all subdirectories)"
    echo "  • find can filter by ANY attribute"
    echo "  • find can EXECUTE commands on results"
    echo "  • find can combine conditions with boolean logic"
    
    print_subheader "Setup working environment"
    
    setup_demo_environment
    
    pause_interactive
}

# ═══════════════════════════════════════════════════════════════════════════════
# SECTION 2: SEARCH BY NAME
# ═══════════════════════════════════════════════════════════════════════════════

section_2_name() {
    print_header "📚 SECTION 2: Search by Name"
    
    cd "$DEMO_DIR"
    
    print_concept "-name and -iname: search by file name"
    
    # Demo 1: simple -name
    print_subheader "2.1 Exact search with -name"
    
    print_prediction "What will find: find . -name 'main.c' ?"
    pause_interactive
    
    run_demo "find . -name 'main.c'" "Search for files with the exact name 'main.c'"
    
    # Demo 2: Wildcards
    print_subheader "2.2 Wildcards (globbing patterns)"
    
    print_warning "Patterns must be in quotes!"
    echo ""
    echo "  ✓ find . -name '*.c'     (correct)"
    echo "  ✗ find . -name *.c       (shell expands before find!)"
    
    print_prediction "What will find: find . -name '*.c' ?"
    pause_interactive
    
    run_demo "find . -name '*.c'" "All files with .c extension"
    
    # Demo 3: -iname (case insensitive)
    print_subheader "2.3 Case-insensitive search with -iname"
    
    # Create a file with capitals for demo
    touch "$DEMO_DIR/project/docs/README.TXT"
    
    run_demo "find . -name '*.txt'" "Case sensitive - doesn't find README.TXT"
    run_demo "find . -iname '*.txt'" "Case INsensitive - finds README.TXT too"
    
    # Demo 4: Search in path
    print_subheader "2.4 Search in full path with -path"
    
    run_demo "find . -path '*/src/*'" "Files that have 'src' in path"
    run_demo "find . -path '*test*'" "Anything containing 'test' in path"
    
    print_tip "Difference: -name searches only the FILE NAME, -path the FULL PATH"
    
    pause_interactive
}

# ═══════════════════════════════════════════════════════════════════════════════
# SECTION 3: SEARCH BY TYPE AND SIZE
# ═══════════════════════════════════════════════════════════════════════════════

section_3_type_size() {
    print_header "📚 SECTION 3: Search by Type and Size"
    
    cd "$DEMO_DIR"
    
    print_concept "-type: filter by file type"
    
    print_subheader "3.1 File types"
    
    echo ""
    echo "  ${WHITE}Available types:${NC}"
    echo "  -type f  = regular file"
    echo "  -type d  = directory"
    echo "  -type l  = symbolic link"
    echo "  -type b  = block device"
    echo "  -type c  = character device"
    echo "  -type p  = named pipe (FIFO)"
    echo "  -type s  = socket"
    
    print_prediction "How many directories are in the demo structure?"
    pause_interactive
    
    run_demo "find . -type d" "All directories"
    run_demo "find . -type d | wc -l" "Count directories"
    
    run_demo "find . -type f -name '*.c'" "Combine: regular files with .c extension"
    
    run_demo "find . -type l" "Symbolic links"
    
    # Size
    print_subheader "3.2 Search by size with -size"
    
    echo ""
    echo "  ${WHITE}Size suffixes:${NC}"
    echo "  c  = bytes"
    echo "  k  = kilobytes"
    echo "  M  = megabytes"
    echo "  G  = gigabytes"
    echo ""
    echo "  ${WHITE}Modifiers:${NC}"
    echo "  +N  = larger than N"
    echo "  -N  = smaller than N"
    echo "  N   = exactly N"
    
    print_prediction "What will find: find . -size +1M ?"
    pause_interactive
    
    run_demo "find . -type f -size +1M" "Files larger than 1MB"
    
    run_demo "find . -type f -size +100k -size -1M" "Between 100KB and 1MB"
    
    # Display with size
    run_demo "find . -type f -size +100k -exec ls -lh {} \\;" "With displayed sizes"
    
    print_tip "Use -ls instead of -exec ls for more compact format"
    
    run_demo "find . -type f -size +1M -ls" "Compact format with -ls"
    
    pause_interactive
}

# ═══════════════════════════════════════════════════════════════════════════════
# SECTION 4: SEARCH BY TIME
# ═══════════════════════════════════════════════════════════════════════════════

section_4_time() {
    print_header "📚 SECTION 4: Search by Time"
    
    cd "$DEMO_DIR"
    
    print_concept "Time options: -mtime, -atime, -ctime, -mmin, -amin, -cmin"
    
    print_subheader "4.1 Unix file times"
    
    echo ""
    echo "  ${WHITE}Three times for each file:${NC}"
    echo ""
    echo "  mtime (modification) = when CONTENT was modified"
    echo "  atime (access)       = when ACCESSED (read)"
    echo "  ctime (change)       = when METADATA was modified (permissions, owner)"
    
    echo ""
    echo "  ${WHITE}Units:${NC}"
    echo "  -mtime N  = N days ago"
    echo "  -mmin N   = N minutes ago"
    
    echo ""
    echo "  ${WHITE}Modifiers:${NC}"
    echo "  +N  = older than N"
    echo "  -N  = newer than N"
    echo "  N   = exactly N"
    
    print_subheader "4.2 Practical examples"
    
    print_prediction "What does -mtime -7 mean? (files modified in the last 7 days)"
    pause_interactive
    
    run_demo "find ./logs -type f -mtime -7" "Modified in the last 7 days"
    
    run_demo "find ./logs -type f -mtime +3" "Older than 3 days"
    
    run_demo "find ./logs -type f -mtime 5" "Exactly 5 days ago"
    
    # Minutes
    print_subheader "4.3 Precision in minutes"
    
    # Create a recent file for demo
    touch "$DEMO_DIR/temp/just_created.txt"
    
    run_demo "find . -type f -mmin -5" "Modified in the last 5 minutes"
    
    # Comparison with another file
    print_subheader "4.4 Comparison with -newer"
    
    run_demo "find . -type f -newer ./project/src/main.c" "Newer than main.c"
    
    print_warning "Be careful with -atime: can be affected by backups and antivirus!"
    
    print_tip "For cleanup scripts, test first with -print, then with -delete"
    
    pause_interactive
}

# ═══════════════════════════════════════════════════════════════════════════════
# SECTION 5: LOGICAL OPERATORS
# ═══════════════════════════════════════════════════════════════════════════════

section_5_logic() {
    print_header "📚 SECTION 5: Logical Operators"
    
    cd "$DEMO_DIR"
    
    print_concept "Combining conditions: AND, OR, NOT"
    
    print_subheader "5.1 Implicit AND"
    
    echo ""
    echo "  ${WHITE}When you put multiple expressions, find combines them with implicit AND:${NC}"
    echo ""
    echo "  find . -type f -name '*.c'  =  find . -type f AND -name '*.c'"
    
    run_demo "find . -type f -name '*.c'" "Regular files AND with .c extension"
    
    # OR
    print_subheader "5.2 Explicit OR with -o"
    
    print_prediction "How do you find .c OR .h files?"
    pause_interactive
    
    run_demo "find . -type f \\( -name '*.c' -o -name '*.h' \\)" "Files .c OR .h"
    
    print_warning "Parentheses must be escaped: \\( and \\)"
    
    # NOT
    print_subheader "5.3 NOT with !"
    
    run_demo "find . -type f ! -name '*.c'" "Files that are NOT .c"
    
    run_demo "find . -type f ! -path '*/build/*'" "Exclude the build directory"
    
    # Complex combinations
    print_subheader "5.4 Complex combinations"
    
    echo ""
    echo "  ${WHITE}Find: large files that are NOT in build and are .c or .py${NC}"
    
    run_demo "find . -type f -size +10k ! -path '*/build/*' \\( -name '*.c' -o -name '*.py' \\)" \
             "Complex expression with AND, OR, NOT"
    
    print_tip "Build expressions incrementally and test at each step!"
    
    pause_interactive
}

# ═══════════════════════════════════════════════════════════════════════════════
# SECTION 6: ACTIONS
# ═══════════════════════════════════════════════════════════════════════════════

section_6_actions() {
    print_header "📚 SECTION 6: Actions"
    
    cd "$DEMO_DIR"
    
    print_concept "What to do with results: -print, -exec, -delete"
    
    print_subheader "6.1 Print variants"
    
    echo ""
    echo "  ${WHITE}Display options:${NC}"
    echo "  -print     = standard output (implicit)"
    echo "  -print0    = separate with NULL (for xargs -0)"
    echo "  -printf    = custom format"
    echo "  -ls        = format similar to ls -l"
    
    run_demo "find ./project/src -name '*.c' -ls" "ls format for .c files"
    
    run_demo "find ./project/src -name '*.c' -printf '%s bytes: %p\\n'" "Custom format"
    
    # -exec
    print_subheader "6.2 Execution with -exec"
    
    echo ""
    echo "  ${WHITE}-exec syntax:${NC}"
    echo ""
    echo "  -exec command {} \\;   = execute for EACH file"
    echo "  -exec command {} +    = execute once with ALL files"
    
    print_prediction "What's the difference between \\; and + ?"
    pause_interactive
    
    echo ""
    echo "  With \\;  :  wc -l file1.c; wc -l file2.c; wc -l file3.c"
    echo "  With +   :  wc -l file1.c file2.c file3.c"
    echo ""
    echo "  + is much more EFFICIENT (single process)!"
    
    run_demo "find ./project/src -name '*.c' -exec wc -l {} \\;" "With \\; (separate)"
    run_demo "find ./project/src -name '*.c' -exec wc -l {} +" "With + (batch)"
    
    # -ok for confirmation
    print_subheader "6.3 Confirmation with -ok"
    
    echo ""
    echo "  ${WHITE}-ok is like -exec, but asks for confirmation for each:${NC}"
    echo ""
    echo "  (We don't actually run it because it would need interactive input)"
    echo ""
    print_command "find . -name '*.tmp' -ok rm {} \\;"
    print_explanation "Will ask: < rm ... ./temp/temp_001.tmp > ?"
    
    # -delete
    print_subheader "6.4 Deletion with -delete"
    
    print_warning "-delete DELETES WITHOUT CONFIRMATION! Test first with -print!"
    
    echo ""
    echo "  ${WHITE}SAFE deletion pattern:${NC}"
    echo ""
    echo "  1. Test:    find . -name '*.tmp' -print"
    echo "  2. Verify output carefully"
    echo "  3. Delete:  find . -name '*.tmp' -delete"
    
    # Safe demo: create and delete temporary files
    touch "$DEMO_DIR/temp/deleteme_{1..3}.test"
    
    run_demo "find ./temp -name '*.test' -print" "STEP 1: Verify what will be deleted"
    
    echo ""
    echo -e "${YELLOW}Now we can safely delete:${NC}"
    run_demo "find ./temp -name '*.test' -delete" "STEP 2: Delete"
    run_demo "find ./temp -name '*.test' -print" "VERIFICATION: No longer exists"
    
    print_tip "-delete implies -depth (processes files before directories)"
    
    pause_interactive
}

# ═══════════════════════════════════════════════════════════════════════════════
# SECTION 7: XARGS
# ═══════════════════════════════════════════════════════════════════════════════

section_7_xargs() {
    print_header "📚 SECTION 7: xargs - Batch Processing"
    
    cd "$DEMO_DIR"
    
    print_concept "xargs: builds and executes commands from standard input"
    
    print_subheader "7.1 Why xargs?"
    
    echo ""
    echo "  ${WHITE}The problem with simple pipe:${NC}"
    echo ""
    echo "  find . -name '*.c' | rm    ← DOESN'T WORK!"
    echo "  rm doesn't read from stdin"
    echo ""
    echo "  ${WHITE}The solution: xargs${NC}"
    echo ""
    echo "  find . -name '*.c' | xargs rm    ← WORKS"
    echo "  xargs takes input and builds arguments for rm"
    
    print_subheader "7.2 Basic example"
    
    run_demo "find ./project -name '*.c' | xargs wc -l" "Count lines in all .c files"
    
    # The problem with spaces
    print_subheader "7.3 ⚠️ THE PROBLEM WITH SPACES"
    
    print_warning "xargs by default splits on spaces and newlines!"
    
    echo ""
    echo "  We have files with spaces in names in ./data:"
    run_demo "ls -la ./data/*.txt 2>/dev/null || echo 'see with find'" ""
    run_demo "find ./data -name '*.txt' -type f" ".txt files in data"
    
    print_prediction "What happens with: find ./data -name '*.txt' | xargs echo ?"
    pause_interactive
    
    run_demo "find ./data -name '*.txt' | xargs echo 'Processing:'" \
             "xargs treats 'file with spaces.txt' as 3 arguments!"
    
    # The solution
    print_subheader "7.4 The solution: -print0 and -0"
    
    echo ""
    echo "  ${WHITE}The CORRECT pattern:${NC}"
    echo ""
    echo "  find ... -print0 | xargs -0 command"
    echo ""
    echo "  -print0  = separate with NULL (\\0) instead of newline"
    echo "  xargs -0 = expect NULL as separator"
    
    run_demo "find ./data -name '*.txt' -print0 | xargs -0 echo 'Processing:'" \
             "Now each file is treated correctly!"
    
    # xargs options
    print_subheader "7.5 Useful xargs options"
    
    echo ""
    echo "  ${WHITE}Important options:${NC}"
    echo "  -0       = NULL separator"
    echo "  -n NUM   = maximum NUM arguments per command"
    echo "  -I{}     = replace {} with each argument"
    echo "  -P NUM   = run NUM processes in parallel"
    echo "  -t       = display command before execution"
    echo "  -p       = ask for confirmation"
    
    run_demo "find ./project/src -name '*.c' | xargs -t wc -l" "With -t: displays command"
    
    run_demo "find ./project/src -name '*.c' | xargs -n1 wc -l" "With -n1: one at a time"
    
    # -I for placeholder
    print_subheader "7.6 Placeholder with -I"
    
    run_demo "find ./project/src -name '*.c' | xargs -I{} echo 'File found: {}'" \
             "-I{} allows flexible positioning"
    
    # Parallel
    print_subheader "7.7 Parallel processing with -P"
    
    echo ""
    echo "  ${WHITE}For CPU-intensive tasks:${NC}"
    print_command "find . -name '*.jpg' | xargs -P4 -I{} convert {} -resize 50% small_{}"
    print_explanation "Process 4 images simultaneously"
    
    print_tip "Combine -P with -n for finer control"
    
    pause_interactive
}

# ═══════════════════════════════════════════════════════════════════════════════
# SECTION 8: ADVANCED COMBINATIONS
# ═══════════════════════════════════════════════════════════════════════════════

section_8_advanced() {
    print_header "📚 SECTION 8: Advanced Combinations"
    
    cd "$DEMO_DIR"
    
    print_concept "Real scenarios and advanced patterns"
    
    print_subheader "8.1 🧹 Cleanup: Delete old backup files"
    
    echo ""
    echo "  ${WHITE}Scenario: Delete .bak files older than 30 days${NC}"
    
    run_demo "find ./backup -name '*.bak' -mtime +30 -type f -print" \
             "Step 1: Verify"
    
    echo ""
    print_command "find ./backup -name '*.bak' -mtime +30 -type f -delete"
    print_explanation "Step 2: Delete (we don't actually run it)"
    
    print_subheader "8.2 📊 Report: Top 10 largest files"
    
    run_demo "find . -type f -printf '%s %p\\n' | sort -rn | head -10" \
             "Sort descending by size"
    
    # With nicer format
    echo ""
    echo "  ${WHITE}Formatted version:${NC}"
    run_demo "find . -type f -printf '%s %p\\n' | sort -rn | head -10 | while read size path; do echo \"\$((\$size/1024)) KB: \$path\"; done" \
             "With conversion to KB"
    
    print_subheader "8.3 🔐 Security: Find files with dangerous permissions"
    
    run_demo "find . -type f -perm -o=w -ls 2>/dev/null" \
             "Files writable by anyone (world-writable)"
    
    echo ""
    echo "  ${WHITE}In the real system, for security audit:${NC}"
    print_command "find /home -type f -perm -4000 -ls 2>/dev/null"
    print_explanation "Find files with SUID (run as owner)"
    
    print_subheader "8.4 📁 Synchronisation: Copy only new files"
    
    echo ""
    echo "  ${WHITE}Copy .c files modified today to a backup directory:${NC}"
    
    mkdir -p "$DEMO_DIR/daily_backup"
    
    run_demo "find ./project -name '*.c' -mtime 0 -exec cp {} ./daily_backup/ \\;" \
             "Copy files modified today"
    
    run_demo "ls -la ./daily_backup/" "Verify backup"
    
    print_subheader "8.5 🔄 Batch processing with feedback"
    
    echo ""
    echo "  ${WHITE}Process files and show progress:${NC}"
    
    run_demo "find ./project -name '*.py' | xargs -I{} sh -c 'echo \"Processing: {}\" && wc -l {} | tail -1'" \
             "Feedback for each file"
    
    print_subheader "8.6 📋 Final pattern: Complete cleanup script"
    
    echo ""
    cat << 'SCRIPT'
╔═══════════════════════════════════════════════════════════════════════════════╗
║ SAFE CLEANUP Pattern:                                                         ║
╠═══════════════════════════════════════════════════════════════════════════════╣
║                                                                               ║
║  #!/bin/bash                                                                  ║
║  # Safe cleanup script                                                        ║
║                                                                               ║
║  TARGET="/var/log"                                                            ║
║  DAYS=30                                                                      ║
║  PATTERN="*.log"                                                              ║
║                                                                               ║
║  # STEP 1: List what will be deleted                                          ║
║  echo "Files that will be deleted:"                                           ║
║  find "$TARGET" -name "$PATTERN" -mtime +$DAYS -type f -print                 ║
║                                                                               ║
║  # STEP 2: Confirm                                                            ║
║  read -p "Continue with deletion? (y/N): " confirm                            ║
║  [[ "$confirm" != "y" ]] && exit 0                                            ║
║                                                                               ║
║  # STEP 3: Delete with logging                                                ║
║  find "$TARGET" -name "$PATTERN" -mtime +$DAYS -type f \                      ║
║       -print -delete >> /var/log/cleanup.log 2>&1                             ║
║                                                                               ║
║  echo "Cleanup complete. See /var/log/cleanup.log"                            ║
║                                                                               ║
╚═══════════════════════════════════════════════════════════════════════════════╝
SCRIPT
    
    print_tip "Always: PRINT → VERIFY → DELETE!"
    
    pause_interactive
}

# ═══════════════════════════════════════════════════════════════════════════════
# FINAL SUMMARY
# ═══════════════════════════════════════════════════════════════════════════════

show_summary() {
    print_header "📋 SUMMARY: find and xargs"
    
    cat << 'SUMMARY'
╔═══════════════════════════════════════════════════════════════════════════════╗
║                           QUICK CHEAT SHEET                                   ║
╠═══════════════════════════════════════════════════════════════════════════════╣
║ SEARCH BY NAME:                                                               ║
║   find . -name "*.txt"              # By name (case-sensitive)                ║
║   find . -iname "*.txt"             # Case-insensitive                        ║
║   find . -path "*test*"             # In full path                            ║
║                                                                               ║
║ SEARCH BY TYPE:                                                               ║
║   find . -type f                    # Files                                   ║
║   find . -type d                    # Directories                             ║
║   find . -type l                    # Symlinks                                ║
║                                                                               ║
║ SEARCH BY SIZE:                                                               ║
║   find . -size +1M                  # Larger than 1MB                         ║
║   find . -size -100k                # Smaller than 100KB                      ║
║                                                                               ║
║ SEARCH BY TIME:                                                               ║
║   find . -mtime -7                  # Modified in the last 7 days             ║
║   find . -mmin -30                  # Modified in the last 30 min             ║
║                                                                               ║
║ LOGICAL OPERATORS:                                                            ║
║   find . -type f -name "*.c"        # Implicit AND                            ║
║   find . \( -name "*.c" -o -name "*.h" \)   # OR                              ║
║   find . ! -name "*.o"              # NOT                                     ║
║                                                                               ║
║ ACTIONS:                                                                      ║
║   find . -name "*.c" -exec wc -l {} \;      # One at a time                   ║
║   find . -name "*.c" -exec wc -l {} +       # All at once (efficient)         ║
║   find . -name "*.tmp" -delete              # Delete (CAUTION!)               ║
║                                                                               ║
║ XARGS:                                                                        ║
║   find . -name "*.c" | xargs wc -l          # Batch processing                ║
║   find . -print0 | xargs -0 cmd             # Handle spaces                   ║
║   find . | xargs -I{} cp {} /backup/        # With placeholder                ║
║   find . | xargs -P4 -n1 process            # Parallel                        ║
║                                                                               ║
╚═══════════════════════════════════════════════════════════════════════════════╝
SUMMARY

    echo ""
    echo -e "${GREEN}✓ Demo complete!${NC}"
    echo ""
    echo -e "For cleanup: ${CYAN}./S03_02_demo_find_xargs.sh -c${NC}"
    echo ""
}

# ═══════════════════════════════════════════════════════════════════════════════
# ARGUMENT PARSING AND MAIN
# ═══════════════════════════════════════════════════════════════════════════════

parse_args() {
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
                RUN_SECTION="$2"
                shift 2
                ;;
            -a|--all)
                RUN_ALL=true
                shift
                ;;
            -c|--cleanup)
                cleanup_demo
                exit 0
                ;;
            *)
                echo -e "${RED}Unknown option: $1${NC}"
                show_usage
                exit 1
                ;;
        esac
    done
}

main() {
    parse_args "$@"
    
    # Check if demo environment exists
    if [[ ! -d "$DEMO_DIR" ]] && [[ "$RUN_SECTION" != "1" ]] && [[ -z "$RUN_SECTION" ]]; then
        echo -e "${YELLOW}Initial setup needed. Running section 1...${NC}"
        section_1_intro
    fi
    
    # Run specific section or all
    if [[ -n "$RUN_SECTION" ]]; then
        case "$RUN_SECTION" in
            1) section_1_intro ;;
            2) section_2_name ;;
            3) section_3_type_size ;;
            4) section_4_time ;;
            5) section_5_logic ;;
            6) section_6_actions ;;
            7) section_7_xargs ;;
            8) section_8_advanced ;;
            *)
                echo -e "${RED}Invalid section: $RUN_SECTION (must be 1-8)${NC}"
                exit 1
                ;;
        esac
    else
        # Run everything
        section_1_intro
        section_2_name
        section_3_type_size
        section_4_time
        section_5_logic
        section_6_actions
        section_7_xargs
        section_8_advanced
    fi
    
    show_summary
}

# Run
main "$@"
