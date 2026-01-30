#!/bin/bash
#═══════════════════════════════════════════════════════════════════════════════
# S02_02_interactive_quiz.sh - Interactive Bash Quiz for Seminar 02
#═══════════════════════════════════════════════════════════════════════════════
#
# DESCRIPTION:
#   Command-line quiz for rapid comprehension verification.
#   Bash alternative to quiz_runner.py for environments without Python
#   or for students who prefer practising in the terminal.
#
# USAGE:
#   ./S02_02_interactive_quiz.sh              # Full quiz (all questions)
#   ./S02_02_interactive_quiz.sh --quick      # Only 5 random questions
#   ./S02_02_interactive_quiz.sh --topic ops  # Only operators
#   ./S02_02_interactive_quiz.sh --topic redir # Only redirection
#   ./S02_02_interactive_quiz.sh --topic pipes # Only filters and pipes
#   ./S02_02_interactive_quiz.sh --topic loops # Only loops
#   ./S02_02_interactive_quiz.sh --help       # This message
#
# AUTHOR: OS Pedagogical Kit | ASE Bucharest - CSIE
# VERSION: 1.0 | January 2025
#═══════════════════════════════════════════════════════════════════════════════

set -euo pipefail

# ─────────────────────────────────────────────────────────────────────────────
# COLOUR AND SYMBOL CONFIGURATION
# ─────────────────────────────────────────────────────────────────────────────

if [[ -t 1 ]]; then
    RED='\033[1;31m'
    GREEN='\033[1;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[1;34m'
    CYAN='\033[1;36m'
    BOLD='\033[1m'
    DIM='\033[2m'
    RESET='\033[0m'
    CHECK="✓"
    CROSS="✗"
else
    RED='' GREEN='' YELLOW='' BLUE='' CYAN='' BOLD='' DIM='' RESET=''
    CHECK="[OK]" CROSS="[X]"
fi

# ─────────────────────────────────────────────────────────────────────────────
# GLOBAL VARIABLES
# ─────────────────────────────────────────────────────────────────────────────

SCORE=0
TOTAL=0
declare -a WRONG_ANSWERS=()
TOPIC_FILTER=""
QUICK_MODE=false

# ─────────────────────────────────────────────────────────────────────────────
# UTILITY FUNCTIONS
# ─────────────────────────────────────────────────────────────────────────────

print_header() {
    clear
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════════╗${RESET}"
    echo -e "${CYAN}║${RESET}  ${BOLD}Interactive Quiz - Seminar 02: Operators, Pipes, Loops${RESET}        ${CYAN}║${RESET}"
    echo -e "${CYAN}║${RESET}  ${DIM}Operating Systems | ASE Bucharest - CSIE${RESET}                      ${CYAN}║${RESET}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════════╝${RESET}"
    echo
}

print_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo
    echo "Options:"
    echo "  --quick        Only 5 random questions"
    echo "  --topic TOPIC  Filter by subject (ops, redir, pipes, loops)"
    echo "  --help, -h     Display this message"
    echo
    echo "Examples:"
    echo "  $0                 # Full quiz"
    echo "  $0 --quick         # Quick quiz"
    echo "  $0 --topic pipes   # Only pipe questions"
}

# Generic function to pose a question
ask_question() {
    local topic="$1"
    local question="$2"
    local -n options_ref=$3
    local correct="$4"
    local explanation="$5"
    
    # Apply topic filter if set
    if [[ -n "$TOPIC_FILTER" && "$topic" != "$TOPIC_FILTER" ]]; then
        return 0
    fi
    
    ((TOTAL++))
    
    clear
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════════╗${RESET}"
    echo -e "${CYAN}║${RESET}  Question ${BOLD}$TOTAL${RESET} | Topic: ${YELLOW}$topic${RESET}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════════╝${RESET}"
    echo
    echo -e "$question"
    echo
    
    for i in "${!options_ref[@]}"; do
        echo -e "  ${BOLD}$((i+1)))${RESET} ${options_ref[$i]}"
    done
    
    echo
    local answer
    read -rp "Your answer (1-${#options_ref[@]}): " answer
    
    if [[ "$answer" == "$correct" ]]; then
        echo -e "\n${GREEN}${CHECK} CORRECT!${RESET}"
        ((SCORE++))
    else
        echo -e "\n${RED}${CROSS} INCORRECT!${RESET} The correct answer was: ${BOLD}$correct${RESET}"
        WRONG_ANSWERS+=("Q$TOTAL: ${topic} - Answer: $correct")
    fi
    
    echo -e "\n${DIM}Explanation: $explanation${RESET}"
    echo
    read -rp "Press Enter to continue..."
}

show_results() {
    clear
    print_header
    
    if [[ $TOTAL -eq 0 ]]; then
        echo -e "${YELLOW}No questions matched your filter.${RESET}"
        return
    fi
    
    local percent=$((SCORE * 100 / TOTAL))
    
    echo -e "${BOLD}═══ FINAL RESULT ═══${RESET}\n"
    echo -e "Score: ${BOLD}$SCORE / $TOTAL${RESET} ($percent%)\n"
    
    # Progress bar
    local bar_filled=$((percent / 5))
    local bar_empty=$((20 - bar_filled))
    echo -n "["
    for ((i=0; i<bar_filled; i++)); do echo -ne "${GREEN}█${RESET}"; done
    for ((i=0; i<bar_empty; i++)); do echo -n "░"; done
    echo "]"
    echo
    
    if ((percent >= 80)); then
        echo -e "${GREEN}Excellent! You have understood the material well.${RESET}"
    elif ((percent >= 60)); then
        echo -e "${YELLOW}Good, but review the sections where you made errors.${RESET}"
    else
        echo -e "${RED}I recommend re-reading the material and redoing the exercises.${RESET}"
    fi
    
    if ((${#WRONG_ANSWERS[@]} > 0)); then
        echo -e "\n${BOLD}Questions to review:${RESET}"
        for wrong in "${WRONG_ANSWERS[@]}"; do
            echo -e "  • $wrong"
        done
    fi
    
    echo
}

# ─────────────────────────────────────────────────────────────────────────────
# QUIZ QUESTIONS
# ─────────────────────────────────────────────────────────────────────────────

run_quiz() {
    print_header
    
    echo "You will receive a series of questions about operators, redirection and pipes."
    echo "For each question, enter the number of the correct answer."
    echo
    read -rp "Press Enter to begin..."
    
    # ─── OPERATORS ───
    
    local q1_opts=(";" "&&" "||" "&")
    ask_question "ops" \
        "Which operator executes the second command ONLY if the first succeeds?" \
        q1_opts 2 \
        "&& (logical AND) checks for exit code 0 before continuing."
    
    local q2_opts=(
        "Executes the command twice"
        "Launches the command in background"
        "Connects stdout to stdin of another command"
        "Redirects stderr to stdout"
    )
    ask_question "ops" \
        "What does the & operator do when placed at the end of a command?" \
        q2_opts 2 \
        "The & operator at end of command sends it to background, freeing the terminal."
    
    local q3_opts=(
        "\"Created\""
        "\"Error\""
        "\"Created\" and \"Error\""
        "Nothing (command fails silently)"
    )
    ask_question "ops" \
        "mkdir test && echo \"Created\" || echo \"Error\"\n\nIf directory 'test' ALREADY EXISTS, what is displayed?" \
        q3_opts 2 \
        "mkdir fails when directory exists (exit ≠ 0), so && is skipped and || executes."
    
    # ─── REDIRECTION ───
    
    local q4_opts=(">" ">>" "2>" "2>>")
    ask_question "redir" \
        "Which operator do you use to APPEND text to an existing file?" \
        q4_opts 2 \
        ">> appends, whilst > overwrites the file."
    
    local q5_opts=(
        "Exit code of ls (non-zero)"
        "Exit code of wc (0, success)"
        "Sum of exit codes"
        "Syntax error"
    )
    ask_question "redir" \
        "ls /nonexistent | wc -l; echo \"\$?\"\n\nWhat does \$? display?" \
        q5_opts 2 \
        "\$? returns ONLY the exit code of the LAST command in the pipeline. Use \${PIPESTATUS[@]} for all."
    
    local q6_opts=(
        "cat << EOF"
        "cat < EOF"
        "cat > EOF"
        "cat | EOF"
    )
    ask_question "redir" \
        "Which syntax creates a here document?" \
        q6_opts 1 \
        "<< begins a here document that reads until the delimiter (EOF)."
    
    local q7_opts=(
        "> all.txt 2>&1 (correct order)"
        "2>&1 > all.txt (reversed order)"
        "Both work identically"
        "Neither works"
    )
    ask_question "redir" \
        "To redirect BOTH stdout AND stderr to the same file, which is correct?\n\nls /home /nonexistent ___" \
        q7_opts 1 \
        "Order matters! First redirect stdout, then duplicate stderr to where stdout now points."
    
    # ─── PIPES AND FILTERS ───
    
    local q8_opts=(
        "uniq file.txt"
        "sort file.txt | uniq"
        "uniq -u file.txt"
        "cat file.txt | uniq -c"
    )
    ask_question "pipes" \
        "To remove ALL duplicate lines from a file (not just consecutive), which is correct?" \
        q8_opts 2 \
        "uniq only removes CONSECUTIVE duplicates. You must sort first!"
    
    local q9_opts=(
        "tr 'hello' 'HELLO'"
        "tr 'h' 'H' | tr 'e' 'E' | ..."
        "tr 'a-z' 'A-Z'"
        "tr [:lower:] [:upper:]"
    )
    ask_question "pipes" \
        "To convert all lowercase letters to uppercase using tr, which is correct?" \
        q9_opts 3 \
        "tr works with character SETS, not strings. 'a-z' 'A-Z' maps each letter."
    
    local q10_opts=(
        "cut -d',' -f2 data.csv"
        "cut -f2 data.csv"
        "cut -c2 data.csv"
        "cut -d' ' -f2 data.csv"
    )
    ask_question "pipes" \
        "To extract the second column from a CSV file (comma-separated), which is correct?" \
        q10_opts 1 \
        "You must specify delimiter with -d','. Default delimiter is TAB, not comma."
    
    # ─── LOOPS ───
    
    local q11_opts=(
        "Works correctly, prints 1 to 5"
        "Syntax error"
        "Prints literal string {1..\$n}"
        "Infinite loop"
    )
    ask_question "loops" \
        "n=5; for i in {1..\$n}; do echo \$i; done\n\nWhat happens?" \
        q11_opts 3 \
        "Brace expansion occurs BEFORE variable expansion. Use \$(seq 1 \$n) or C-style for loop."
    
    local q12_opts=(
        "x=2, y=2"
        "x=2, y=1"
        "x=1, y=2"
        "x=1, y=1"
    )
    ask_question "loops" \
        "x=1; { x=2; }; y=1; ( y=2 ); echo \"\$x \$y\"\n\nWhat are the final values?" \
        q12_opts 2 \
        "{ } runs in current shell (x changes). ( ) creates subshell (y remains 1 in parent)."
    
    local q13_opts=(
        "0 (empty or previous value)"
        "The correct count"
        "Error: count not defined"
        "Infinite loop"
    )
    ask_question "loops" \
        "count=0\ncat file.txt | while read line; do ((count++)); done\necho \$count\n\nWhat does count display?" \
        q13_opts 1 \
        "Pipe creates SUBSHELL. Variables modified inside do not persist. Use redirect: while read line; do ...; done < file.txt"
    
    # ─── RESULTS ───
    
    show_results
}

# ─────────────────────────────────────────────────────────────────────────────
# MAIN
# ─────────────────────────────────────────────────────────────────────────────

main() {
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --help|-h)
                print_usage
                exit 0
                ;;
            --quick)
                QUICK_MODE=true
                shift
                ;;
            --topic)
                if [[ -n "${2:-}" ]]; then
                    TOPIC_FILTER="$2"
                    shift 2
                else
                    echo "Error: --topic requires an argument (ops, redir, pipes, loops)"
                    exit 1
                fi
                ;;
            *)
                echo "Unknown option: $1"
                print_usage
                exit 1
                ;;
        esac
    done
    
    run_quiz
}

main "$@"
