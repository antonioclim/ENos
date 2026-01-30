#!/bin/bash
#
# S05_04_demo_robust.sh - Demonstration of set -euo pipefail
# 
# Operating Systems | ASE Bucharest - CSIE
# Seminar 5: Advanced Bash Scripting
#
# PURPOSE: Demonstrates the behaviour of set -euo pipefail and
#          cases WHERE IT DOES NOT WORK (critical misconception 75%).
#
# USAGE:
#   ./S05_04_demo_robust.sh           # All demos
#   ./S05_04_demo_robust.sh errexit   # Only set -e
#   ./S05_04_demo_robust.sh nounset   # Only set -u
#   ./S05_04_demo_robust.sh pipefail  # Only pipefail
#   ./S05_04_demo_robust.sh limits    # Limitations of set -e
#

# We do NOT activate set -euo pipefail here to demonstrate the behaviour!

# ============================================================
# CONSTANTS AND COLOURS
# ============================================================
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly BOLD='\033[1m'
readonly DIM='\033[2m'
readonly NC='\033[0m'

# ============================================================
# HELPER FUNCTIONS
# ============================================================

header() {
    echo ""
    echo -e "${BOLD}${BLUE}════════════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}${BLUE}  $1${NC}"
    echo -e "${BOLD}${BLUE}════════════════════════════════════════════════════════════${NC}"
    echo ""
}

subheader() {
    echo ""
    echo -e "${CYAN}▶ $1${NC}"
    echo -e "${CYAN}────────────────────────────────────────${NC}"
}

code() {
    echo -e "${YELLOW}${DIM}$1${NC}"
}

run_in_subshell() {
    echo -e "${BOLD}Running in subshell:${NC}"
    echo -e "${YELLOW}$1${NC}"
    echo -e "${DIM}---output---${NC}"
    bash -c "$1" 2>&1 || true
    echo -e "${DIM}---end output---${NC}"
}

good() {
    echo -e "${GREEN}✓ $1${NC}"
}

bad() {
    echo -e "${RED}✗ $1${NC}"
}

info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

critical() {
    echo -e "${RED}${BOLD}⚠⚠⚠ $1 ⚠⚠⚠${NC}"
}

pause() {
    echo ""
    read -r -p "Press Enter to continue..." </dev/tty 2>/dev/null || true
    echo ""
}

# ============================================================
# DEMO 1: SET -E (ERREXIT)
# ============================================================

demo_errexit() {
    header "SET -E (ERREXIT) - Exit on First Error"
    
    subheader "Behaviour WITHOUT set -e"
    
    code '#!/bin/bash
# Without set -e
echo "Start"
false         # Command that fails (exit code 1)
echo "This DOES EXECUTE (script continues)"
true
echo "End"'
    
    echo ""
    run_in_subshell '
echo "Start"
false
echo "This DOES EXECUTE"
true
echo "End"
'
    warning "Script continued after error!"
    
    pause
    
    subheader "Behaviour WITH set -e"
    
    code '#!/bin/bash
set -e        # Enable errexit
echo "Start"
false         # Script STOPS here
echo "This does NOT execute"'
    
    echo ""
    run_in_subshell '
set -e
echo "Start"
false
echo "This does NOT execute"
'
    good "Script stopped on error!"
    
    pause
    
    subheader "Practical Example: Fragile vs Robust Script"
    
    echo "FRAGILE (without set -e):"
    code '#!/bin/bash
cd /nonexistent/directory
rm -rf *      # DANGER: runs in current directory!'
    
    echo ""
    warning "If cd fails, rm runs in current directory!"
    
    echo ""
    echo "ROBUST (with set -e):"
    code '#!/bin/bash
set -e
cd /nonexistent/directory  # Script stops here
rm -rf *                   # Does NOT execute'
    
    good "With set -e, script stops before rm!"
}

# ============================================================
# DEMO 2: SET -U (NOUNSET)
# ============================================================

demo_nounset() {
    header "SET -U (NOUNSET) - Error for Undefined Variables"
    
    subheader "Behaviour WITHOUT set -u"
    
    code '#!/bin/bash
# Without set -u
echo "User: $USER"           # OK - system variable
echo "Missing: $UNDEFINED"   # Empty, but no error
echo "Script continues"'
    
    echo ""
    run_in_subshell '
echo "User: $USER"
echo "Missing: $UNDEFINED"
echo "Script continues"
'
    warning "Undefined variable is treated as empty string!"
    
    pause
    
    subheader "Behaviour WITH set -u"
    
    code '#!/bin/bash
set -u
echo "User: $USER"
echo "Missing: $UNDEFINED"   # ERROR!
echo "Does not execute"'
    
    echo ""
    run_in_subshell '
set -u
echo "User: $USER"
echo "Missing: $UNDEFINED"
echo "Does not execute"
'
    good "Script detected undefined variable!"
    
    pause
    
    subheader "How to use optional variables with set -u"
    
    code '# Method 1: Default value
echo "${OPTIONAL:-default_value}"

# Method 2: Empty string as default
echo "${OPTIONAL:-}"

# Method 3: Explicit check
if [[ -n "${OPTIONAL:-}" ]]; then
    echo "OPTIONAL is set: $OPTIONAL"
fi'
    
    echo ""
    echo "Demonstration:"
    run_in_subshell '
set -u
echo "Default: ${UNDEFINED:-default_value}"
echo "Empty: \"${UNDEFINED:-}\""
if [[ -n "${UNDEFINED:-}" ]]; then
    echo "Set"
else
    echo "Unset or empty"
fi
echo "Script continues normally!"
'
}

# ============================================================
# DEMO 3: SET -O PIPEFAIL
# ============================================================

demo_pipefail() {
    header "SET -O PIPEFAIL - Error Propagation in Pipeline"
    
    subheader "Behaviour WITHOUT pipefail"
    
    code '#!/bin/bash
# Pipeline: false (exit 1) | true (exit 0)
false | true
echo "Exit code: $?"'
    
    echo ""
    run_in_subshell '
false | true
echo "Exit code: $?"
'
    warning "Exit code is 0 (from true) - error from false is IGNORED!"
    
    pause
    
    subheader "Behaviour WITH pipefail"
    
    code '#!/bin/bash
set -o pipefail
false | true
echo "Exit code: $?"'
    
    echo ""
    run_in_subshell '
set -o pipefail
false | true
echo "Exit code: $?"
'
    good "Exit code is 1 (from false) - error is PROPAGATED!"
    
    pause
    
    subheader "Practical Example: Pipe with Grep"
    
    echo "WITHOUT pipefail:"
    code 'cat nonexistent_file.txt | grep "pattern"
echo "Status: $?"'
    
    run_in_subshell '
cat nonexistent_file.txt 2>/dev/null | grep "pattern" 2>/dev/null
echo "Status: $?"
'
    warning "Status 1 is from grep (no match), not from cat!"
    
    echo ""
    echo "WITH pipefail + PIPESTATUS:"
    code 'set -o pipefail
cat nonexistent_file.txt | grep "pattern"
echo "Pipeline status: $?"
echo "Individual: ${PIPESTATUS[@]}"'
    
    run_in_subshell '
set -o pipefail
cat nonexistent_file.txt 2>&1 | grep "pattern" 2>/dev/null
echo "Pipeline status: $?"
'
}

# ============================================================
# DEMO 4: LIMITATIONS OF SET -E
# ============================================================

demo_limits() {
    header "⚠️ LIMITATIONS OF SET -E - When It Does NOT Work!"
    
    critical "This is MISCONCEPTION #1 (75% frequency)!"
    echo ""
    info "Many believe set -e stops script on ANY error."
    info "WRONG! There are multiple cases where errors are IGNORED."
    
    pause
    
    subheader "CASE 1: Commands in IF/WHILE/UNTIL"
    
    code 'set -e
if false; then        # false returns 1, but script does NOT stop
    echo "Does not reach"
fi
echo "Script continues!"'
    
    run_in_subshell '
set -e
if false; then
    echo "Does not reach here"
fi
echo "Script continues after if!"
'
    bad "set -e does NOT work in if conditions!"
    
    pause
    
    subheader "CASE 2: Commands followed by || or &&"
    
    code 'set -e
false || true         # Does not stop - || "rescues" error
echo "Continues"
false && true         # Does not stop - && is "condition"
echo "Continues"'
    
    run_in_subshell '
set -e
false || true
echo "After || : continues"
false && true
echo "After && : continues"
'
    bad "set -e does NOT work with || or &&!"
    
    pause
    
    subheader "CASE 3: Functions in Test Context"
    
    code 'set -e
check() {
    false             # Should it stop?
    echo "In function"
}
if check; then        # Does NOT stop - it'\''s in test context
    echo "true"
fi
echo "Script continues"'
    
    run_in_subshell '
set -e
check() {
    false
    echo "In function - executes!"
}
if check; then
    echo "Check returned true"
else
    echo "Check returned false"
fi
echo "Script continues after function in if!"
'
    bad "set -e does NOT work for functions called in if!"
    
    pause
    
    subheader "CASE 4: Negation with !"
    
    code 'set -e
! false               # Negation inverts exit code
echo "Continues"
! true                # Returns 1, but with ! does not stop
echo "Continues"'
    
    run_in_subshell '
set -e
! false
echo "After \"! false\": continues"
! true
echo "After \"! true\": continues (even though exit code is 1!)"
'
    bad "Negation ! disables set -e!"
    
    pause
    
    subheader "CASE 5: Command Substitution (partial)"
    
    code 'set -e
x=$(false)            # STOPS script
echo "Does not reach here"'
    
    echo "But:"
    code 'set -e
echo "Output: $(false)"  # In some versions does NOT stop!
echo "May continue"'
    
    run_in_subshell '
set -e
echo "Test 1: before"
x=$(false)
echo "Test 1: does not reach"
'
    
    echo ""
    warning "Behaviour varies between Bash versions!"
    
    pause
    
    subheader "SUMMARY: When set -e Does NOT Work"
    
    echo -e "${BOLD}set -e IGNORES errors in:${NC}"
    echo ""
    echo "  1. Commands in if/while/until/elif"
    echo "  2. Left side of && or ||"
    echo "  3. Any command negated with !"
    echo "  4. Functions called in test context"
    echo "  5. Commands in pipes (without pipefail)"
    echo "  6. Subshells (without shopt inherit_errexit)"
    echo ""
    
    warning "SOLUTION: EXPLICIT checking of important errors!"
    
    code '# Recommended pattern:
result=$(critical_command) || {
    echo "Command failed!" >&2
    exit 1
}

# Or:
if ! critical_command; then
    echo "Command failed!" >&2
    exit 1
fi'
}

# ============================================================
# DEMO 5: COMPLETE COMBINATION
# ============================================================

demo_combined() {
    header "COMPLETE COMBINATION: set -euo pipefail"
    
    subheader "Recommended Shebang"
    
    code '#!/bin/bash
set -euo pipefail
IFS=$'\''\n\t'\'''
    
    echo ""
    echo "What each does:"
    echo "  -e (errexit)   : Exit on first error (with limitations!)"
    echo "  -u (nounset)   : Error for undefined variables"
    echo "  -o pipefail    : Propagate errors in pipes"
    echo "  IFS            : Safe separator (avoids word splitting)"
    
    pause
    
    subheader "Complete Demonstrative Script"
    
    code '#!/bin/bash
set -euo pipefail
IFS=$'\''\n\t'\''

# Variables with defaults (for set -u)
INPUT="${1:-}"
DEBUG="${DEBUG:-false}"

# Explicit checking (do not rely only on set -e)
[ -n "$INPUT" ] || { echo "Usage: $0 <file>"; exit 1; }
[ -f "$INPUT" ] || { echo "File not found: $INPUT"; exit 1; }

# Safe pipe (with pipefail)
result=$(cat "$INPUT" | grep "pattern" | wc -l)
echo "Found $result matches"

# Cleanup
trap '\''echo "Cleanup..."; rm -f /tmp/temp_$$'\'' EXIT'
    
    pause
    
    subheader "Temporary Disable (when necessary)"
    
    echo "For commands that can legitimately fail:"
    code '# Method 1: || true
command_that_might_fail || true

# Method 2: set +e temporarily
set +e
command_that_might_fail
status=$?
set -e
if [ $status -ne 0 ]; then
    echo "Command failed with $status"
fi

# Method 3: || with handling
command_that_might_fail || {
    echo "Warning: command failed, continuing..."
}'
}

# ============================================================
# DEMO 6: INTERACTIVE QUIZ
# ============================================================

demo_quiz() {
    header "QUIZ: set -euo pipefail - Test Your Knowledge!"
    
    local score=0
    local total=5
    
    # Q1
    echo -e "${BOLD}Q1: With 'set -e', does the script stop if 'false' is in an if?${NC}"
    echo "    a) Yes"
    echo "    b) No"
    read -r -p "Answer (a/b): " ans </dev/tty
    if [[ "$ans" == "b" ]]; then
        good "Correct! set -e does not work in test context (if/while)."
        ((score++))
    else
        bad "Wrong. set -e ignores errors in if/while/until."
    fi
    echo ""
    
    # Q2
    echo -e "${BOLD}Q2: 'false | true' returns what exit code WITHOUT pipefail?${NC}"
    echo "    a) 0"
    echo "    b) 1"
    echo "    c) Depends"
    read -r -p "Answer (a/b/c): " ans </dev/tty
    if [[ "$ans" == "a" ]]; then
        good "Correct! Without pipefail, returns exit code of last command (true=0)."
        ((score++))
    else
        bad "Wrong. Without pipefail, pipeline returns status of last command."
    fi
    echo ""
    
    # Q3
    echo -e "${BOLD}Q3: With 'set -u', how do you access an optional variable?${NC}"
    echo "    a) \$VAR"
    echo "    b) \${VAR:-default}"
    echo "    c) You cannot"
    read -r -p "Answer (a/b/c): " ans </dev/tty
    if [[ "$ans" == "b" ]]; then
        good "Correct! \${VAR:-default} provides default value and avoids error."
        ((score++))
    else
        bad "Wrong. \${VAR:-default} returns default if VAR is undefined."
    fi
    echo ""
    
    # Q4
    echo -e "${BOLD}Q4: Does 'false || true' stop script with set -e?${NC}"
    echo "    a) Yes"
    echo "    b) No"
    read -r -p "Answer (a/b): " ans </dev/tty
    if [[ "$ans" == "b" ]]; then
        good "Correct! || \"rescues\" the error - set -e does not apply."
        ((score++))
    else
        bad "Wrong. Commands followed by || or && do not trigger set -e."
    fi
    echo ""
    
    # Q5
    echo -e "${BOLD}Q5: What does IFS=\$'\\n\\t' do?${NC}"
    echo "    a) Sets newline and tab as separators (avoids spaces)"
    echo "    b) Enables debugging"
    echo "    c) Sets UTF-8 encoding"
    read -r -p "Answer (a/b/c): " ans </dev/tty
    if [[ "$ans" == "a" ]]; then
        good "Correct! Removes space from IFS for safer word splitting."
        ((score++))
    else
        bad "Wrong. IFS controls how Bash separates words."
    fi
    echo ""
    
    # Result
    header "QUIZ RESULT"
    echo -e "Score: ${BOLD}$score / $total${NC}"
    
    if [ "$score" -eq "$total" ]; then
        good "Excellent! You perfectly understand set -euo pipefail!"
    elif [ "$score" -ge 3 ]; then
        info "Good! Review the special cases."
    else
        warning "Re-read the material about set -e limitations!"
    fi
}

# ============================================================
# MAIN
# ============================================================

main() {
    case "${1:-all}" in
        errexit|-e)
            demo_errexit
            ;;
        nounset|-u)
            demo_nounset
            ;;
        pipefail)
            demo_pipefail
            ;;
        limits)
            demo_limits
            ;;
        combined)
            demo_combined
            ;;
        quiz)
            demo_quiz
            ;;
        all)
            demo_errexit
            pause
            demo_nounset
            pause
            demo_pipefail
            pause
            demo_limits
            pause
            demo_combined
            pause
            demo_quiz
            ;;
        *)
            echo "Usage: $0 [errexit|nounset|pipefail|limits|combined|quiz|all]"
            exit 1
            ;;
    esac
    
    echo ""
    echo -e "${BOLD}${GREEN}═══ Demo set -euo pipefail Complete! ═══${NC}"
}

main "$@"
