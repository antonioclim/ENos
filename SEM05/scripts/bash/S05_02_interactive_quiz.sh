#!/bin/bash
#
# S05_02_interactive_quiz.sh - Interactive Quiz for Seminar
# 
# Operating Systems | ASE Bucharest - CSIE
# Seminar 5: Advanced Bash Scripting
#
# PURPOSE: Interactive quiz with MCQ questions for knowledge verification.
#          Can be run during the seminar or for self-assessment.
#
# USAGE:
#   ./S05_02_interactive_quiz.sh              # Full quiz
#   ./S05_02_interactive_quiz.sh --topic functions  # Functions only
#   ./S05_02_interactive_quiz.sh --quick      # Short version (5 questions)
#

set -euo pipefail
IFS=$'\n\t'

# ============================================================
# CONSTANTS AND COLOURS
# ============================================================
readonly SCRIPT_NAME=$(basename "$0")
readonly VERSION="1.0.0"

readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly BOLD='\033[1m'
readonly DIM='\033[2m'
readonly NC='\033[0m'

# ============================================================
# STATE
# ============================================================
SCORE=0
TOTAL=0
ANSWERS=()

# ============================================================
# HELPER FUNCTIONS
# ============================================================

clear_screen() {
    printf '\033[2J\033[H'
}

print_header() {
    echo -e "${BOLD}${BLUE}"
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║          Quiz: Advanced Bash Scripting                      ║"
    echo "║          ASE Bucharest - CSIE                               ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

print_progress() {
    local current=$1
    local total=$2
    local pct=$((current * 100 / total))
    local filled=$((pct / 5))
    local empty=$((20 - filled))
    
    printf "${CYAN}Progress: [${NC}"
    printf "${GREEN}%${filled}s${NC}" | tr ' ' '█'
    printf "${DIM}%${empty}s${NC}" | tr ' ' '░'
    printf "${CYAN}] %d/%d${NC}\n" "$current" "$total"
}

ask_question() {
    local question="$1"
    local option_a="$2"
    local option_b="$3"
    local option_c="$4"
    local option_d="$5"
    local correct="$6"
    local explanation="$7"
    
    ((TOTAL++))
    
    echo ""
    echo -e "${BOLD}Question $TOTAL:${NC}"
    echo ""
    echo -e "$question"
    echo ""
    echo -e "  ${CYAN}A)${NC} $option_a"
    echo -e "  ${CYAN}B)${NC} $option_b"
    echo -e "  ${CYAN}C)${NC} $option_c"
    echo -e "  ${CYAN}D)${NC} $option_d"
    echo ""
    
    local answer=""
    while [[ ! "$answer" =~ ^[AaBbCcDd]$ ]]; do
        read -r -p "Your answer (A/B/C/D): " answer
    done
    
    answer=$(echo "$answer" | tr '[:lower:]' '[:upper:]')
    ANSWERS+=("$answer")
    
    echo ""
    if [[ "$answer" == "$correct" ]]; then
        ((SCORE++))
        echo -e "${GREEN}✓ CORRECT!${NC}"
    else
        echo -e "${RED}✗ WRONG! The correct answer was: $correct${NC}"
    fi
    
    echo ""
    echo -e "${DIM}Explanation: $explanation${NC}"
    echo ""
    
    read -r -p "Press Enter to continue..." </dev/tty
}

# ============================================================
# QUESTIONS: FUNCTIONS
# ============================================================

quiz_functions() {
    ask_question \
'```bash
count=10
increment() {
    count=$((count + 1))
}
increment
echo $count
```
What does this script display?' \
        '10 (the variable in the function is local)' \
        '11 (the variable is modified globally)' \
        'Error: variable is not defined' \
        '1 (count is reset)' \
        'B' \
        'Variables in Bash are GLOBAL by default! Without "local", the function modifies the variable in the outer scope.'

    ask_question \
'```bash
get_sum() {
    local a=$1 b=$2
    return $((a + b))
}
get_sum 100 200
echo $?
```
What does this script display?' \
        '300' \
        '44 (300 mod 256)' \
        '0' \
        'Error' \
        'B' \
        'return can only return values 0-255 (exit codes). 300 mod 256 = 44. For larger values, use echo + $().'

    ask_question \
'What does the "local" keyword do in Bash?' \
        'Declares a constant that cannot be modified' \
        'Makes the variable visible only in the current function' \
        'Exports the variable to the environment' \
        'Makes the variable read-only' \
        'B' \
        'local creates a variable with scope limited to the function where it is declared. Without local, variables are GLOBAL.'

    ask_question \
'What is the RECOMMENDED method to "return" a string from a function?' \
        'return "string"' \
        'RESULT="string" (global variable)' \
        'echo "string" and capture with $()' \
        'export "string"' \
        'C' \
        'Recommended pattern: result=$(func); the function does echo, and the caller captures with $().'
}

# ============================================================
# QUESTIONS: ARRAYS
# ============================================================

quiz_arrays() {
    ask_question \
'```bash
arr=("alpha" "beta" "gamma")
echo ${arr[1]}
```
What does it display?' \
        'alpha' \
        'beta' \
        'gamma' \
        'Error' \
        'B' \
        'Arrays in Bash start from INDEX 0! arr[0]=alpha, arr[1]=beta, arr[2]=gamma.'

    ask_question \
'```bash
files=("my file.txt" "doc.pdf")
for f in ${files[@]}; do echo "[$f]"; done
```
How many lines are displayed?' \
        '2' \
        '3' \
        '4' \
        'Depends on the shell' \
        'B' \
        'Without quotes, word splitting applies! "my file.txt" becomes 2 elements. Correct: "${files[@]}"'

    ask_question \
'What is MANDATORY for associative arrays in Bash?' \
        'Nothing special' \
        'declare -a' \
        'declare -A' \
        'export -A' \
        'C' \
        'Without declare -A, Bash treats it as an indexed array! Text keys become 0 (undefined variable).'

    ask_question \
'```bash
arr=("a" "b" "c")
unset arr[1]
echo ${!arr[@]}
```
What does it display?' \
        '0 1 2' \
        '0 2' \
        '0 1' \
        'a c' \
        'B' \
        'unset does NOT reindex! Creates a "sparse array" with a gap. ${!arr[@]} shows existing indices.'
}

# ============================================================
# QUESTIONS: ROBUSTNESS
# ============================================================

quiz_robust() {
    ask_question \
'What does "set -e" do in Bash?' \
        'Activates extended globbing' \
        'The script stops at the first error' \
        'Exports all variables' \
        'Activates debug mode' \
        'B' \
        'set -e (errexit) makes the script stop when a command returns non-zero. BUT it has limitations!'

    ask_question \
'```bash
set -e
if false; then echo "yes"; fi
echo "continued"
```
What happens?' \
        'The script stops at false' \
        'Displays "yes" and "continued"' \
        'Displays only "continued"' \
        'Syntax error' \
        'C' \
        'set -e does NOT work in test context (if/while/until)! false in if does not stop the script.'

    ask_question \
'```bash
false | true
echo $?
```
What does it display WITHOUT pipefail?' \
        '0' \
        '1' \
        'Both' \
        'Nothing' \
        'A' \
        'Without pipefail, pipeline returns the exit code of the LAST command. true = 0.'

    ask_question \
'When does a trap EXIT execute?' \
        'Only on exit 0 (success)' \
        'Only on errors' \
        'ALWAYS on script exit' \
        'Only on Ctrl+C' \
        'C' \
        'trap EXIT always executes: on normal completion, on errors, or on signals. Ideal for cleanup!'
}

# ============================================================
# QUESTIONS: MIXED
# ============================================================

quiz_mixed() {
    ask_question \
'Which combination is recommended at the beginning of robust scripts?' \
        'set -e' \
        'set -eu' \
        'set -euo pipefail' \
        'set -xv' \
        'C' \
        'set -e (exit on error), -u (error on undefined), -o pipefail (propagate pipe errors). The holy trinity!'

    ask_question \
'```bash
DEBUG=true
[[ "$DEBUG" == "true" ]] && set -x
```
What does this pattern do?' \
        'Sets an environment variable' \
        'Activates debug/trace mode if DEBUG=true' \
        'Defines a debug function' \
        'Exports DEBUG to subshells' \
        'B' \
        'Common pattern: activate set -x (trace) conditionally based on the DEBUG variable from the environment.'

    ask_question \
'What is the search order when you type a command in Bash?' \
        'builtin → alias → function → external' \
        'alias → function → builtin → external' \
        'external → builtin → function → alias' \
        'function → alias → builtin → external' \
        'B' \
        'Order: alias → function → builtin → external ($PATH). Functions have priority over external commands!'

    ask_question \
'How do you "bypass" a function to call the original external command?' \
        'external ls' \
        'command ls' \
        'builtin ls' \
        '/ls' \
        'B' \
        'command cmd skips functions and aliases. builtin is only for built-ins. /bin/ls works but requires the path.'
}

# ============================================================
# PRINT RESULTS
# ============================================================

print_results() {
    clear_screen
    print_header
    
    local pct=$((SCORE * 100 / TOTAL))
    
    echo ""
    echo -e "${BOLD}═══════════════════ RESULTS ═══════════════════${NC}"
    echo ""
    echo -e "Score: ${BOLD}$SCORE / $TOTAL${NC} ($pct%)"
    echo ""
    
    # Progress bar
    local filled=$((pct / 5))
    local empty=$((20 - filled))
    printf "["
    if [[ $pct -ge 70 ]]; then
        printf "${GREEN}%${filled}s${NC}" | tr ' ' '█'
    elif [[ $pct -ge 50 ]]; then
        printf "${YELLOW}%${filled}s${NC}" | tr ' ' '█'
    else
        printf "${RED}%${filled}s${NC}" | tr ' ' '█'
    fi
    printf "${DIM}%${empty}s${NC}" | tr ' ' '░'
    printf "]\n"
    echo ""
    
    # Grade
    if [[ $pct -ge 90 ]]; then
        echo -e "${GREEN}${BOLD}EXCELLENT!${NC} You've mastered Advanced Bash! 🎉"
    elif [[ $pct -ge 70 ]]; then
        echo -e "${GREEN}GOOD!${NC} Solid understanding, but there's room for improvement."
    elif [[ $pct -ge 50 ]]; then
        echo -e "${YELLOW}SUFFICIENT${NC} - Review the concepts where you made mistakes."
    else
        echo -e "${RED}NEEDS STUDY${NC} - Reread the material and try again."
    fi
    
    echo ""
    echo -e "${BOLD}Your answers:${NC} ${ANSWERS[*]}"
    echo ""
    
    echo -e "${DIM}Tips for improvement:${NC}"
    if [[ $pct -lt 100 ]]; then
        echo "  • Reread S05_02_MATERIAL_PRINCIPAL.md"
        echo "  • Run the demo scripts from scripts/demo/"
        echo "  • Practise with the exercises from exercises/"
    fi
    echo ""
}

# ============================================================
# USAGE
# ============================================================

usage() {
    cat << EOF
${BOLD}$SCRIPT_NAME v$VERSION${NC}

Interactive quiz for verifying Advanced Bash knowledge.

${BOLD}USAGE:${NC}
    $SCRIPT_NAME [options]

${BOLD}OPTIONS:${NC}
    -h, --help          Display this message
    -t, --topic TOPIC   Only one topic (functions|arrays|robust)
    -q, --quick         Short version (one question per topic)
    -a, --all           All questions (default)

${BOLD}EXAMPLES:${NC}
    $SCRIPT_NAME                    # Full quiz
    $SCRIPT_NAME --topic functions  # Functions only
    $SCRIPT_NAME --quick            # Short version

EOF
}

# ============================================================
# MAIN
# ============================================================

main() {
    local topic="all"
    local quick=false
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                usage
                exit 0
                ;;
            -t|--topic)
                topic="$2"
                shift 2
                ;;
            -q|--quick)
                quick=true
                shift
                ;;
            -a|--all)
                topic="all"
                shift
                ;;
            *)
                echo "Unknown option: $1" >&2
                exit 1
                ;;
        esac
    done
    
    clear_screen
    print_header
    
    echo "Welcome to the Advanced Bash quiz!"
    echo ""
    echo "You will receive questions with 4 answer options."
    echo "Type the corresponding letter (A/B/C/D) and press Enter."
    echo ""
    read -r -p "Press Enter to start..." </dev/tty
    
    case "$topic" in
        functions)
            quiz_functions
            ;;
        arrays)
            quiz_arrays
            ;;
        robust)
            quiz_robust
            ;;
        mixed)
            quiz_mixed
            ;;
        all)
            if [[ "$quick" == "true" ]]; then
                # One question per topic
                TOTAL=0
                ask_question \
'What does "local" do in Bash functions?' \
                    'Exports the variable' \
                    'Makes the variable visible only in the function' \
                    'Declares a constant' \
                    'Nothing special' \
                    'B' \
                    'local limits the scope of the variable to the current function.'
                
                ask_question \
'declare -A is MANDATORY for:' \
                    'Indexed arrays' \
                    'Integer variables' \
                    'Associative arrays' \
                    'Functions' \
                    'C' \
                    'Without declare -A, hashes do not work correctly!'
                
                ask_question \
'set -e does NOT stop the script in:' \
                    'Simple commands' \
                    'if conditions' \
                    'Loops' \
                    'Functions' \
                    'B' \
                    'set -e ignores errors in test context (if/while/until).'
            else
                quiz_functions
                quiz_arrays
                quiz_robust
                quiz_mixed
            fi
            ;;
        *)
            echo "Unknown topic: $topic" >&2
            echo "Options: functions, arrays, robust, mixed, all" >&2
            exit 1
            ;;
    esac
    
    print_results
}

main "$@"
