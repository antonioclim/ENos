#!/bin/bash
#===============================================================================
#
#          FILE: S04_02_interactive_quiz.sh
#
#         USAGE: ./S04_02_interactive_quiz.sh [--category CATEGORY] [--count N]
#
#   DESCRIPTION: Interactive quiz for knowledge verification
#                about grep, sed, awk and regular expressions
#
#       OPTIONS: --category  regex|grep|sed|awk|all (default: all)
#                --count     Number of questions (default: 10)
#                --help      Display help
#
#        AUTHOR: Assistant Lecturer - OS Seminar
#       VERSION: 1.1
#
#===============================================================================

set -euo pipefail

#-------------------------------------------------------------------------------
# CONFIGURATION
#-------------------------------------------------------------------------------

# Colours
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly BOLD='\033[1m'
readonly NC='\033[0m'

# Quiz variables
CATEGORY="all"
QUESTION_COUNT=10
SCORE=0
TOTAL=0

#-------------------------------------------------------------------------------
# QUESTION DATABASE
#-------------------------------------------------------------------------------

# Format: question|optionA|optionB|optionC|optionD|correct_letter|explanation

declare -a REGEX_QUESTIONS=(
    "What does the '.' pattern match in regex?|Literal period|Any single character|Zero or more|Start of line|B|The period (.) matches any single character."
    "What does '^' do outside brackets []?|Negation|Any character|Start of line|End of line|C|^ outside [] is an anchor for start of line."
    "What does '^' do inside [] at the beginning?|Start of line|Negation set|Any character|End of line|B|[^abc] means 'anything EXCEPT a, b or c'."
    "What is the difference between * and + in ERE?|No difference|* = 0+, + = 1+|* = 1+, + = 0+|* = exact 1|B|* allows zero repetitions, + requires at least one."
    "What pattern finds empty lines?|^$|.*|.+|^.|A|^ immediately followed by $ = line without content."
    "What does [[:alpha:]] do?|Uppercase only|Lowercase only|Any letter|Any character|C|POSIX class alpha = all letters."
    "What does the regex 'colou?r' match?|color|colour|color or colour|Error|C|? makes 'u' optional: zero or one."
    "The pattern [0-9]* can match...|At least one digit|Zero or more digits|Exactly one digit|No characters|B|* allows zero repetitions!"
)

declare -a GREP_QUESTIONS=(
    "What does the -i option do in grep?|Inverts|Case insensitive|Include lines|Ignore file|B|-i ignores case differences."
    "What does the -v option do in grep?|Verbose|Inverts matches|Version|Validate|B|-v shows lines that do NOT match."
    "What does the -c option do in grep?|Colours|Count lines|Confirms|Cleaning|B|-c returns the count of matching lines."
    "What does the -o option do in grep?|Output file|Only the match|Omit errors|Order|B|-o displays ONLY the matching portion."
    "grep -E is equivalent to...|egrep|fgrep|pgrep|zgrep|A|-E enables Extended Regular Expressions."
    "What does grep -r do?|Reverse|Recursive|Regex|Replace|B|-r searches recursively in directories."
    "What does grep -l do?|Line numbers|Only file names|Last match|Long output|B|-l displays only the names of files with matches."
    "grep -c counts...|Characters|Words|Lines|All occurrences|C|-c counts LINES, not individual occurrences!"
)

declare -a SED_QUESTIONS=(
    "The basic syntax for substitution in sed is...|s/old/new/|r/old/new/|c/old/new/|x/old/new/|A|s = substitute."
    "What does the /g flag do in sed s///g?|Global (all)|Get|Grep|Generate|A|/g replaces ALL occurrences per line."
    "sed by default writes to...|File|stdout|stderr|/dev/null|B|sed writes to stdout, does NOT modify the file!"
    "What does sed -i do?|Input|Inverse|In-place|Ignore|C|-i edits the file directly (DANGEROUS without backup!)."
    "What does & do in sed replacement?|And logic|Entire match|Append|Anchor|B|& represents everything that was matched."
    "What does the d command do in sed?|Duplicate|Delete line|Display|Divide|B|d deletes matching lines."
    "Which substitution uses # as its delimiter in GNU sed?|s/old/new/|s:old:new:|s#old#new#|s;old;new;|C|The keyed command uses # after s and around both operands."
    "sed '/^#/d' does...|Delete all lines|Delete comments|Delete empty lines|Delete first line|B|Deletes lines that START with #."
)

declare -a AWK_QUESTIONS=(
    "What does \$0 contain in awk?|First field|Program name|Entire line|Last field|C|\$0 is the ENTIRE line (record)."
    "What does \$NF contain in awk?|Number of fields|Last field|Newline|First field|B|\$NF = the field with number NF (last one)."
    "How do you set the separator to comma?|-s ','|-F','|-d ','|--sep=','|B|-F specifies Field Separator."
    "awk '{print \$1, \$2}' - the comma...|Is optional|Adds space (OFS)|Concatenates|Causes error|B|Comma inserts OFS (default: space)."
    "awk '{print \$1 \$2}' (without comma)...|Adds space|Concatenates directly|Causes error|Ignores \$2|B|Without comma = direct concatenation."
    "NR in awk represents...|Real number|Number of Records|Next Row|Null Reference|B|NR = current line number (global)."
    "BEGIN { } executes...|On each line|Before processing|After processing|Never|B|BEGIN runs ONCE, before input."
    "What does NR > 1 do in awk?|Count lines|Skips header|Checks numbers|Nothing|B|NR > 1 excludes the first line (header)."
)

#-------------------------------------------------------------------------------
# FUNCTIONS
#-------------------------------------------------------------------------------

show_help() {
    cat << 'EOF'
╔══════════════════════════════════════════════════════════════════════════╗
║                    INTERACTIVE QUIZ - TEXT PROCESSING                    ║
╚══════════════════════════════════════════════════════════════════════════╝

USAGE:
    ./S04_02_interactive_quiz.sh [OPTIONS]

OPTIONS:
    --category CATEGORY   Choose category: regex, grep, sed, awk or all
    --count N             Number of questions (default: 10)
    --help                Display this message

EXAMPLES:
    ./S04_02_interactive_quiz.sh                    # Full quiz, 10 questions
    ./S04_02_interactive_quiz.sh --category grep    # Only grep
    ./S04_02_interactive_quiz.sh --count 5          # Only 5 questions

EOF
}

shuffle_array() {
    local -n arr=$1
    local i j temp
    for ((i=${#arr[@]}-1; i>0; i--)); do
        j=$((RANDOM % (i+1)))
        temp="${arr[i]}"
        arr[i]="${arr[j]}"
        arr[j]="$temp"
    done
}

ask_question() {
    local q_data="$1"
    local q_num="$2"
    
    IFS='|' read -r question optA optB optC optD correct explanation <<< "$q_data"
    
    echo ""
    echo -e "${BOLD}${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}Question $q_num:${NC}"
    echo -e "${YELLOW}$question${NC}"
    echo ""
    echo -e "  ${BOLD}A)${NC} $optA"
    echo -e "  ${BOLD}B)${NC} $optB"
    echo -e "  ${BOLD}C)${NC} $optC"
    echo -e "  ${BOLD}D)${NC} $optD"
    echo ""
    
    local answer
    while true; do
        read -rp "Your answer (A/B/C/D): " answer
        answer=$(echo "$answer" | tr '[:lower:]' '[:upper:]')
        if [[ "$answer" =~ ^[ABCD]$ ]]; then
            break
        fi
        echo -e "${RED}Please enter A, B, C or D${NC}"
    done
    
    TOTAL=$((TOTAL + 1))
    
    if [[ "$answer" == "$correct" ]]; then
        echo -e "${GREEN}✓ CORRECT!${NC}"
        SCORE=$((SCORE + 1))
    else
        echo -e "${RED}✗ WRONG! The correct answer was: $correct${NC}"
    fi
    
    echo -e "${BLUE}Explanation: $explanation${NC}"
    
    read -rp "Press Enter to continue..."
}

run_quiz() {
    local -a questions=()
    
    # Select questions based on category
    case "$CATEGORY" in
        regex)
            questions=("${REGEX_QUESTIONS[@]}")
            ;;
        grep)
            questions=("${GREP_QUESTIONS[@]}")
            ;;
        sed)
            questions=("${SED_QUESTIONS[@]}")
            ;;
        awk)
            questions=("${AWK_QUESTIONS[@]}")
            ;;
        all)
            questions=("${REGEX_QUESTIONS[@]}" "${GREP_QUESTIONS[@]}" 
                      "${SED_QUESTIONS[@]}" "${AWK_QUESTIONS[@]}")
            ;;
    esac
    
    # Shuffle questions
    shuffle_array questions
    
    # Limit to requested number
    local actual_count=${#questions[@]}
    if (( QUESTION_COUNT < actual_count )); then
        actual_count=$QUESTION_COUNT
    fi
    
    clear
    echo ""
    echo "╔══════════════════════════════════════════════════════════════════════════╗"
    echo "║                    🎯 QUIZ: TEXT PROCESSING 🎯                           ║"
    echo "╠══════════════════════════════════════════════════════════════════════════╣"
    echo "║  Category:  $(printf "%-10s" "$CATEGORY")                                          ║"
    echo "║  Questions: $(printf "%-10s" "$actual_count")                                          ║"
    echo "╚══════════════════════════════════════════════════════════════════════════╝"
    echo ""
    echo "Press Enter to start..."
    read -r
    
    for ((i=0; i<actual_count; i++)); do
        ask_question "${questions[i]}" "$((i+1))"
    done
    
    show_results
}

show_results() {
    clear
    local percentage=$((SCORE * 100 / TOTAL))
    local grade=""
    local emoji=""
    
    if (( percentage >= 90 )); then
        grade="EXCELLENT"
        emoji="🏆"
    elif (( percentage >= 70 )); then
        grade="GOOD"
        emoji="👍"
    elif (( percentage >= 50 )); then
        grade="ACCEPTABLE"
        emoji="📚"
    else
        grade="NEEDS PRACTICE"
        emoji="💪"
    fi
    
    echo ""
    echo "╔══════════════════════════════════════════════════════════════════════════╗"
    echo "║                         📊 QUIZ RESULTS 📊                               ║"
    echo "╠══════════════════════════════════════════════════════════════════════════╣"
    echo "║                                                                          ║"
    printf "║  Score: %d / %d (%d%%)                                               ║\n" "$SCORE" "$TOTAL" "$percentage"
    echo "║                                                                          ║"
    printf "║  Grade: %s %s                                             ║\n" "$emoji" "$grade"
    echo "║                                                                          ║"
    echo "╠══════════════════════════════════════════════════════════════════════════╣"
    
    if (( percentage >= 70 )); then
        echo "║  ✓ You have a good understanding of the concepts!                      ║"
    else
        echo "║  → Review the material and practise the exercises                      ║"
    fi
    
    echo "╚══════════════════════════════════════════════════════════════════════════╝"
    echo ""
}

#-------------------------------------------------------------------------------
# MAIN
#-------------------------------------------------------------------------------

main() {
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --category)
                CATEGORY="$2"
                shift 2
                ;;
            --count)
                QUESTION_COUNT="$2"
                shift 2
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            *)
                echo "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    # Validate category
    if [[ ! "$CATEGORY" =~ ^(regex|grep|sed|awk|all)$ ]]; then
        echo "Invalid category: $CATEGORY"
        echo "Use: regex, grep, sed, awk or all"
        exit 1
    fi
    
    run_quiz
}

main "$@"
