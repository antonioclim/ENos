#!/bin/bash
#
# VALIDATOR - Quick assignment verification Seminar 1
# Operating Systems | ASE Bucharest - CSIE
#
# Usage: ./S01_03_validator.sh <assignment_directory>
#

set -euo pipefail

# Colours
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'
BOLD='\033[1m'

# Counters
PASS=0
FAIL=0
WARN=0

# Functions
log_pass() { echo -e "${GREEN}[PASS]${NC} $1"; ((PASS++)); }
log_fail() { echo -e "${RED}[FAIL]${NC} $1"; ((FAIL++)); }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; ((WARN++)); }
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }

# Header
show_header() {
    echo ""
    echo -e "${CYAN}+===================================================================+${NC}"
    echo -e "${CYAN}|${NC}         ${BOLD}ASSIGNMENT VALIDATOR - Seminar 1 Bash Shell${NC}          ${CYAN}|${NC}"
    echo -e "${CYAN}+===================================================================+${NC}"
    echo ""
}

# Check argument
if [ $# -lt 1 ]; then
    show_header
    echo "Usage: $0 <assignment_directory>"
    echo ""
    echo "Example: $0 ~/homework_seminar1"
    exit 1
fi

HOMEWORK_DIR="$1"

# Check if directory exists
if [ ! -d "$HOMEWORK_DIR" ]; then
    echo -e "${RED}Error: Directory '$HOMEWORK_DIR' does not exist!${NC}"
    exit 1
fi

show_header
log_info "Verifying directory: $HOMEWORK_DIR"
log_info "Timestamp: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""

#
# TEST 1: Directory Structure
#

echo -e "${BOLD}=== TEST 1: Directory Structure ===${NC}"

# Required directories
REQUIRED_DIRS=("project" "project/src" "project/docs" "project/tests")

for dir in "${REQUIRED_DIRS[@]}"; do
    if [ -d "$HOMEWORK_DIR/$dir" ]; then
        log_pass "Directory present: $dir/"
    else
        log_fail "Directory missing: $dir/"
    fi
done

echo ""

#
# TEST 2: Required Files
#

echo -e "${BOLD}=== TEST 2: Required Files ===${NC}"

REQUIRED_FILES=(
    "AUTHOR.txt"
    "project/docs/README.md"
    "project/src/main.sh"
    "project/src/variables.sh"
    "project/src/system_info.sh"
    "project/tests/test_globbing.sh"
)

for file in "${REQUIRED_FILES[@]}"; do
    if [ -f "$HOMEWORK_DIR/$file" ]; then
        log_pass "File present: $file"
    else
        log_fail "File missing: $file"
    fi
done

# .bashrc can be with or without dot
if [ -f "$HOMEWORK_DIR/.bashrc" ] || [ -f "$HOMEWORK_DIR/bashrc" ]; then
    log_pass "File present: .bashrc (or bashrc)"
else
    log_fail "File missing: .bashrc"
fi

echo ""

#
# TEST 3: Bash Script Syntax
#

echo -e "${BOLD}=== TEST 3: Bash Script Syntax ===${NC}"

SCRIPTS=(
    "project/src/main.sh"
    "project/src/variables.sh"
    "project/src/system_info.sh"
    "project/tests/test_globbing.sh"
)

for script in "${SCRIPTS[@]}"; do
    if [ -f "$HOMEWORK_DIR/$script" ]; then
        if bash -n "$HOMEWORK_DIR/$script" 2>/dev/null; then
            log_pass "Syntax correct: $script"
        else
            log_fail "Syntax errors: $script"
            bash -n "$HOMEWORK_DIR/$script" 2>&1 | head -3 | while read -r line; do
                echo "        $line"
            done
        fi
    fi
done

echo ""

#
# TEST 4: Shebang and Permissions
#

echo -e "${BOLD}=== TEST 4: Shebang and Permissions ===${NC}"

for script in "${SCRIPTS[@]}"; do
    if [ -f "$HOMEWORK_DIR/$script" ]; then
        # Check shebang
        first_line=$(head -1 "$HOMEWORK_DIR/$script")
        if [[ "$first_line" == "#!/bin/bash"* ]] || [[ "$first_line" == "#!/usr/bin/env bash"* ]]; then
            log_pass "Shebang correct: $script"
        else
            log_warn "Shebang missing or incorrect: $script (found: $first_line)"
        fi
        
        # Check executable permissions
        if [ -x "$HOMEWORK_DIR/$script" ]; then
            log_pass "Executable: $script"
        else
            log_warn "Not executable: $script (run: chmod +x $script)"
        fi
    fi
done

echo ""

#
# TEST 5: .bashrc Content
#

echo -e "${BOLD}=== TEST 5: .bashrc Content ===${NC}"

BASHRC=""
if [ -f "$HOMEWORK_DIR/.bashrc" ]; then
    BASHRC="$HOMEWORK_DIR/.bashrc"
elif [ -f "$HOMEWORK_DIR/bashrc" ]; then
    BASHRC="$HOMEWORK_DIR/bashrc"
fi

if [ -n "$BASHRC" ]; then
    # Check required aliases
    if grep -q "alias ll=" "$BASHRC" 2>/dev/null; then
        log_pass "Alias 'll' present"
    else
        log_fail "Alias 'll' missing"
    fi
    
    if grep -q "alias cls=" "$BASHRC" 2>/dev/null; then
        log_pass "Alias 'cls' present"
    else
        log_fail "Alias 'cls' missing"
    fi
    
    # Check mkcd function
    if grep -qE "(mkcd\(\)|function mkcd)" "$BASHRC" 2>/dev/null; then
        log_pass "Function 'mkcd' present"
    else
        log_fail "Function 'mkcd' missing"
    fi
    
    # Check PATH modification
    if grep -q "export PATH" "$BASHRC" 2>/dev/null; then
        log_pass "PATH modification present"
    else
        log_warn "PATH modification was not detected"
    fi
fi

echo ""

#
# TEST 6: Script Content Verification
#

echo -e "${BOLD}=== TEST 6: Script Content Verification ===${NC}"

# variables.sh - must contain demonstrations
if [ -f "$HOMEWORK_DIR/project/src/variables.sh" ]; then
    if grep -q '\$USER\|\$HOME\|\$SHELL\|\$PATH' "$HOMEWORK_DIR/project/src/variables.sh"; then
        log_pass "variables.sh: Contains environment variables"
    else
        log_warn "variables.sh: No environment variables detected"
    fi
    
    if grep -q "export" "$HOMEWORK_DIR/project/src/variables.sh"; then
        log_pass "variables.sh: Demonstrates export"
    else
        log_warn "variables.sh: Does not demonstrate export"
    fi
fi

# system_info.sh - must display information
if [ -f "$HOMEWORK_DIR/project/src/system_info.sh" ]; then
    if grep -qE "(uname|date|whoami|\\\$USER|\\\$HOME)" "$HOMEWORK_DIR/project/src/system_info.sh"; then
        log_pass "system_info.sh: Contains system commands"
    else
        log_warn "system_info.sh: No system commands detected"
    fi
fi

# test_globbing.sh - must demonstrate wildcards
if [ -f "$HOMEWORK_DIR/project/tests/test_globbing.sh" ]; then
    if grep -qE "(\*\.txt|\?\.[a-z]+|\[.*\])" "$HOMEWORK_DIR/project/tests/test_globbing.sh"; then
        log_pass "test_globbing.sh: Contains globbing patterns"
    else
        log_warn "test_globbing.sh: No globbing patterns detected"
    fi
fi

echo ""

#
# TEST 7: Script Execution (optional, with sandboxing)
#

echo -e "${BOLD}=== TEST 7: Execution Testing ===${NC}"

for script in "project/src/variables.sh" "project/src/system_info.sh"; do
    if [ -f "$HOMEWORK_DIR/$script" ]; then
        # Run with timeout and capture output
        output=$(timeout 5 bash "$HOMEWORK_DIR/$script" 2>&1) || true
        exit_code=$?
        
        if [ $exit_code -eq 0 ] && [ -n "$output" ]; then
            log_pass "Execution successful: $script"
        elif [ $exit_code -eq 124 ]; then
            log_fail "Execution timeout: $script"
        else
            log_warn "Execution with issues: $script (exit code: $exit_code)"
        fi
    fi
done

echo ""

#
# SUMMARY
#

echo -e "${BOLD}=====================================================================${NC}"
echo -e "${BOLD}                         SUMMARY                                     ${NC}"
echo -e "${BOLD}=====================================================================${NC}"
echo ""

TOTAL=$((PASS + FAIL + WARN))
if [ $TOTAL -eq 0 ]; then
    SCORE=0
else
    SCORE=$((PASS * 100 / TOTAL))
fi

echo -e "  ${GREEN}Passed:${NC}       $PASS"
echo -e "  ${RED}Failed:${NC}       $FAIL"
echo -e "  ${YELLOW}Warnings:${NC}     $WARN"
echo ""

echo -e "  ${BOLD}Estimated score:${NC} ${CYAN}$SCORE%${NC}"
echo ""

if [ $FAIL -eq 0 ]; then
    echo -e "  ${GREEN}${BOLD}[OK] Assignment appears complete!${NC}"
    echo -e "  ${GREEN}  All basic verifications passed.${NC}"
else
    echo -e "  ${YELLOW}${BOLD}[!] Assignment needs improvements${NC}"
    echo -e "  ${YELLOW}  Check the elements marked with ${RED}[FAIL]${NC}"
fi

echo ""
echo -e "${CYAN}---------------------------------------------------------------------${NC}"
echo -e "${BLUE}Note: This is a preliminary automated verification.${NC}"
echo -e "${BLUE}Final evaluation will be done manually by the instructor.${NC}"
echo -e "${BLUE}Oral verification is MANDATORY for final grade.${NC}"
echo ""
