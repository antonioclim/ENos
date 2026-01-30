#!/bin/bash
#
# S05_03_demo_arrays.sh - Demonstration of Indexed and Associative Arrays
# 
# Operating Systems | ASE Bucharest - CSIE
# Seminar 5: Advanced Bash Scripting
#
# PURPOSE: Demonstrates the differences between indexed and associative arrays,
#          as well as common misconceptions (quotes, declare -A, indexing).
#
# USAGE:
#   ./S05_03_demo_arrays.sh           # Run all demos
#   ./S05_03_demo_arrays.sh indexed   # Only indexed arrays
#   ./S05_03_demo_arrays.sh assoc     # Only associative arrays
#   ./S05_03_demo_arrays.sh gotchas   # Only common mistakes
#

set -euo pipefail
IFS=$'\n\t'

# Cleanup function for trap
cleanup() {
    rm -f /tmp/demo_array_*.tmp 2>/dev/null || true
}
trap cleanup EXIT

# ============================================================
# CONSTANTS AND COLOURS
# ============================================================
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly BOLD='\033[1m'
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

code_block() {
    echo -e "${YELLOW}$1${NC}"
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

pause() {
    echo ""
    read -r -p "Press Enter to continue..." </dev/tty 2>/dev/null || true
    echo ""
}

# ============================================================
# DEMO 1: INDEXED ARRAYS - BASICS
# ============================================================

demo_indexed_basic() {
    header "INDEXED ARRAYS - BASIC OPERATIONS"
    
    subheader "Creating an Array"
    
    code_block 'arr=()'
    arr=()
    good "Empty array created: arr=()"
    echo "Length: ${#arr[@]}"
    
    code_block 'fruits=("apple" "banana" "cherry")'
    fruits=("apple" "banana" "cherry")
    good "Array with values: ${fruits[*]}"
    echo "Length: ${#fruits[@]}"
    
    pause
    
    subheader "Accessing Elements"
    
    info "Gotcha: Arrays start at index 0, NOT 1!"
    echo ""
    
    code_block 'echo ${fruits[0]}'
    echo "First element (index 0): ${fruits[0]}"
    
    code_block 'echo ${fruits[1]}'
    echo "Second element (index 1): ${fruits[1]}"
    
    code_block 'echo ${fruits[-1]}'
    echo "Last element (index -1): ${fruits[-1]}"
    
    code_block 'echo ${fruits[@]}'
    echo "All elements: ${fruits[@]}"
    
    code_block 'echo ${#fruits[@]}'
    echo "Number of elements: ${#fruits[@]}"
    
    code_block 'echo ${!fruits[@]}'
    echo "All indices: ${!fruits[@]}"
    
    pause
    
    subheader "Modifying an Array"
    
    code_block 'fruits+=("date")'
    fruits+=("date")
    good "Append: ${fruits[*]}"
    
    code_block 'fruits[1]="BANANA"'
    fruits[1]="BANANA"
    good "Modify index 1: ${fruits[*]}"
    
    code_block 'fruits[10]="extra"'
    fruits[10]="extra"
    warning "Insert at index 10 (sparse array)!"
    echo "Array: ${fruits[*]}"
    echo "Indices: ${!fruits[@]}"
    
    code_block 'unset fruits[10]'
    unset 'fruits[10]'
    good "Deleted index 10: ${fruits[*]}"
}

# ============================================================
# DEMO 2: INDEXED ARRAYS - ITERATION
# ============================================================

demo_indexed_iteration() {
    header "INDEXED ARRAYS - CORRECT ITERATION"
    
    # Array with elements containing spaces - challenge!
    files=("file one.txt" "file two.txt" "my document.pdf")
    
    info "Array with elements containing spaces:"
    echo "files=(\"file one.txt\" \"file two.txt\" \"my document.pdf\")"
    echo ""
    
    subheader "❌ WRONG: Without quotes"
    warning "for f in \${files[@]}; do ..."
    echo ""
    
    code_block '# Incorrect output - breaks apart elements!'
    local count=0
    # shellcheck disable=SC2068
    for f in ${files[@]}; do
        ((count++))
        bad "[$count] -> $f"
    done
    echo ""
    warning "Result: $count iterations instead of 3!"
    
    pause
    
    subheader "✓ CORRECT: With quotes"
    good "for f in \"\${files[@]}\"; do ..."
    echo ""
    
    code_block '# Correct output - preserves elements'
    count=0
    for f in "${files[@]}"; do
        ((count++))
        good "[$count] -> $f"
    done
    echo ""
    good "Result: $count iterations (correct!)"
    
    pause
    
    subheader "Other Iteration Patterns"
    
    fruits=("apple" "banana" "cherry")
    
    echo "1. Through indices:"
    code_block 'for idx in "${!fruits[@]}"; do'
    for idx in "${!fruits[@]}"; do
        echo "   [$idx] = ${fruits[$idx]}"
    done
    
    echo ""
    echo "2. C-style (dense arrays only):"
    code_block 'for ((i=0; i<${#fruits[@]}; i++)); do'
    for ((i=0; i<${#fruits[@]}; i++)); do
        echo "   [$i] = ${fruits[$i]}"
    done
}

# ============================================================
# DEMO 3: ASSOCIATIVE ARRAYS
# ============================================================

demo_associative() {
    header "ASSOCIATIVE ARRAYS (Hash / Dictionary)"
    
    subheader "⚠️ CRITICAL MISCONCEPTION: declare -A is MANDATORY!"
    
    echo ""
    warning "Without declare -A, Bash treats it as an indexed array!"
    echo ""
    
    code_block '# WRONG - without declare -A'
    echo "wrong[host]=\"localhost\""
    echo "wrong[port]=\"8080\""
    
    # Demonstrate the problem (without executing to avoid setting wrong)
    info "What happens:"
    echo "  - Bash interprets 'host' as a variable (undefined = 0)"
    echo "  - wrong[0]=\"localhost\", wrong[0]=\"8080\" (overwrites!)"
    echo "  - Resulting indices: 0 (not host, port)"
    
    pause
    
    subheader "✓ CORRECT: With declare -A"
    
    code_block 'declare -A config'
    declare -A config
    
    code_block 'config[host]="localhost"'
    config[host]="localhost"
    
    code_block 'config[port]="8080"'
    config[port]="8080"
    
    code_block 'config[user]="admin"'
    config[user]="admin"
    
    good "Associative array created correctly!"
    echo ""
    echo "Values: ${config[*]}"
    echo "Keys: ${!config[*]}"
    echo "Count: ${#config[@]}"
    
    pause
    
    subheader "Access and Iteration"
    
    echo "Accessing an element:"
    code_block 'echo ${config[host]}'
    echo "Host: ${config[host]}"
    
    echo ""
    echo "Default value for missing key:"
    code_block 'echo ${config[missing]:-"N/A"}'
    echo "Missing: ${config[missing]:-"N/A"}"
    
    echo ""
    echo "Checking if key exists:"
    code_block '[[ -v config[host] ]] && echo "Exists"'
    [[ -v config[host] ]] && echo "config[host] exists!"
    
    echo ""
    echo "Iterating through keys:"
    code_block 'for key in "${!config[@]}"; do'
    for key in "${!config[@]}"; do
        echo "   $key = ${config[$key]}"
    done
    
    pause
    
    subheader "Practical Example: Word Counting"
    
    code_block 'declare -A word_count'
    declare -A word_count
    
    text="the cat sat on the mat and the cat saw the rat"
    info "Text: $text"
    echo ""
    
    code_block 'for word in $text; do ((word_count[$word]++)); done'
    for word in $text; do
        ((word_count[$word]++))
    done
    
    echo "Result (sorted):"
    for word in "${!word_count[@]}"; do
        printf "   %s: %d\n" "$word" "${word_count[$word]}"
    done | sort -t: -k2 -rn
}

# ============================================================
# DEMO 4: GOTCHAS AND COMMON MISTAKES
# ============================================================

demo_gotchas() {
    header "GOTCHAS - COMMON MISTAKES WITH ARRAYS"
    
    subheader "1. Indexing from 0, not from 1"
    
    arr=("first" "second" "third")
    
    bad "arr[1] = ${arr[1]} (NOT the first element!)"
    good "arr[0] = ${arr[0]} (THIS is the first element)"
    
    pause
    
    subheader "2. Sparse Arrays after unset"
    
    arr=("a" "b" "c" "d" "e")
    echo "Initial array: ${arr[*]}"
    echo "Initial indices: ${!arr[@]}"
    
    code_block 'unset arr[2]'
    unset 'arr[2]'
    
    warning "After unset arr[2]:"
    echo "Array: ${arr[*]}"
    echo "Indices: ${!arr[@]}"
    bad "Indices are NOT re-indexed! Index 2 is missing."
    
    pause
    
    subheader "3. Difference between @ and *"
    
    arr=("one two" "three" "four five")
    
    echo "Array: ${arr[*]}"
    echo ""
    
    echo "With @:"
    code_block 'for i in "${arr[@]}"; do echo "> $i"; done'
    for i in "${arr[@]}"; do
        echo "   > $i"
    done
    
    echo ""
    echo "With * (without quotes - WRONG):"
    code_block 'for i in ${arr[*]}; do echo "> $i"; done'
    # shellcheck disable=SC2068
    for i in ${arr[*]}; do
        echo "   > $i"
    done
    
    warning "With * without quotes, word splitting applies!"
    
    pause
    
    subheader "4. Checking for Empty Array"
    
    empty_arr=()
    
    code_block 'if [ ${#arr[@]} -eq 0 ]; then echo "Empty"; fi'
    if [ ${#empty_arr[@]} -eq 0 ]; then
        good "The array is empty (correct check)"
    fi
    
    # Not like this!
    warning "DO NOT use: if [ -z \"\${arr}\" ] - checks only arr[0]!"
    
    pause
    
    subheader "5. Copying Arrays"
    
    original=("a" "b" "c")
    
    bad "copy=\$original  # WRONG - copies only the first element"
    
    # Demonstrate
    # shellcheck disable=SC2128
    wrong_copy=$original
    echo "wrong_copy contains: '$wrong_copy'"
    
    good "copy=(\"\${original[@]}\")  # CORRECT"
    correct_copy=("${original[@]}")
    echo "correct_copy contains: ${correct_copy[*]}"
}

# ============================================================
# DEMO 5: ADVANCED OPERATIONS
# ============================================================

demo_advanced() {
    header "ADVANCED OPERATIONS WITH ARRAYS"
    
    subheader "Slice (Subsequence)"
    
    arr=("a" "b" "c" "d" "e" "f")
    echo "Array: ${arr[*]}"
    echo ""
    
    code_block 'echo ${arr[@]:1:3}'
    echo "From index 1, 3 elements: ${arr[*]:1:3}"
    
    code_block 'echo ${arr[@]:2}'
    echo "From index 2 to end: ${arr[*]:2}"
    
    code_block 'echo ${arr[@]::3}'
    echo "First 3 elements: ${arr[*]::3}"
    
    pause
    
    subheader "Sorting"
    
    unsorted=("cherry" "apple" "banana" "date")
    echo "Unsorted: ${unsorted[*]}"
    
    code_block 'readarray -t sorted < <(printf "%s\n" "${unsorted[@]}" | sort)'
    readarray -t sorted < <(printf '%s\n' "${unsorted[@]}" | sort)
    good "Sorted: ${sorted[*]}"
    
    nums=(42 7 13 99 1 23)
    echo ""
    echo "Unsorted numbers: ${nums[*]}"
    
    code_block 'readarray -t sorted_nums < <(printf "%s\n" "${nums[@]}" | sort -n)'
    readarray -t sorted_nums < <(printf '%s\n' "${nums[@]}" | sort -n)
    good "Sorted numerically: ${sorted_nums[*]}"
    
    pause
    
    subheader "Filter and Map"
    
    numbers=(1 2 3 4 5 6 7 8 9 10)
    echo "Numbers: ${numbers[*]}"
    
    echo ""
    echo "Filter - only even:"
    even=()
    for n in "${numbers[@]}"; do
        ((n % 2 == 0)) && even+=("$n")
    done
    good "Even: ${even[*]}"
    
    echo ""
    echo "Map - squares:"
    squared=()
    for n in "${numbers[@]}"; do
        squared+=("$((n * n))")
    done
    good "Squares: ${squared[*]}"
    
    pause
    
    subheader "Join and Split"
    
    arr=("one" "two" "three")
    echo "Array: ${arr[*]}"
    
    echo ""
    echo "Join with comma:"
    # shellcheck disable=SC2034
    IFS_OLD=$IFS
    IFS=','
    joined="${arr[*]}"
    IFS=$'\n\t'
    good "Joined: $joined"
    
    echo ""
    echo "Split string into array:"
    csv="apple,banana,cherry"
    IFS=',' read -ra split_arr <<< "$csv"
    good "Split: ${split_arr[*]}"
}

# ============================================================
# DEMO 6: INTERACTIVE QUIZ
# ============================================================

demo_quiz() {
    header "QUIZ: ARRAYS - Test Your Knowledge!"
    
    local score=0
    local total=5
    
    # Q1
    echo -e "${BOLD}Q1: What does \${#arr[@]} return for arr=(a b c)?${NC}"
    echo "    a) 3"
    echo "    b) 1"
    echo "    c) abc"
    read -r -p "Answer (a/b/c): " ans </dev/tty
    if [[ "$ans" == "a" ]]; then
        good "Correct! It returns the number of elements."
        ((score++))
    else
        bad "Wrong. \${#arr[@]} returns the number of elements (3)."
    fi
    echo ""
    
    # Q2
    echo -e "${BOLD}Q2: To create an associative array, what is MANDATORY?${NC}"
    echo "    a) Nothing special"
    echo "    b) declare -a"
    echo "    c) declare -A"
    read -r -p "Answer (a/b/c): " ans </dev/tty
    if [[ "$ans" == "c" ]]; then
        good "Correct! declare -A is mandatory for associative arrays."
        ((score++))
    else
        bad "Wrong. Without declare -A, Bash treats it as an indexed array."
    fi
    echo ""
    
    # Q3
    echo -e "${BOLD}Q3: arr=(\"a b\" \"c\"); for i in \${arr[@]}; - how many iterations?${NC}"
    echo "    a) 2"
    echo "    b) 3"
    echo "    c) Error"
    read -r -p "Answer (a/b/c): " ans </dev/tty
    if [[ "$ans" == "b" ]]; then
        good "Correct! Without quotes, \"a b\" becomes 2 separate elements."
        ((score++))
    else
        bad "Wrong. Without quotes, word splitting separates \"a b\" into \"a\" and \"b\"."
    fi
    echo ""
    
    # Q4
    echo -e "${BOLD}Q4: From what index do arrays start in Bash?${NC}"
    echo "    a) 0"
    echo "    b) 1"
    echo "    c) Depends on declaration"
    read -r -p "Answer (a/b/c): " ans </dev/tty
    if [[ "$ans" == "a" ]]; then
        good "Correct! Arrays start at index 0."
        ((score++))
    else
        bad "Wrong. Arrays in Bash always start from 0."
    fi
    echo ""
    
    # Q5
    echo -e "${BOLD}Q5: After 'unset arr[2]', are indices automatically re-indexed?${NC}"
    echo "    a) Yes"
    echo "    b) No"
    read -r -p "Answer (a/b): " ans </dev/tty
    if [[ "$ans" == "b" ]]; then
        good "Correct! unset creates a sparse array, indices are not re-indexed."
        ((score++))
    else
        bad "Wrong. unset does NOT re-index - the array becomes sparse."
    fi
    echo ""
    
    # Result
    header "QUIZ RESULT"
    echo -e "Score: ${BOLD}$score / $total${NC}"
    
    if [ "$score" -eq "$total" ]; then
        good "Excellent! You have mastered arrays in Bash!"
    elif [ "$score" -ge 3 ]; then
        info "Good! Review the concepts where you made mistakes."
    else
        warning "Requires additional study. Re-read the material!"
    fi
}

# ============================================================
# MAIN
# ============================================================

main() {
    case "${1:-all}" in
        indexed)
            demo_indexed_basic
            demo_indexed_iteration
            ;;
        assoc)
            demo_associative
            ;;
        gotchas)
            demo_gotchas
            ;;
        advanced)
            demo_advanced
            ;;
        quiz)
            demo_quiz
            ;;
        all)
            demo_indexed_basic
            pause
            demo_indexed_iteration
            pause
            demo_associative
            pause
            demo_gotchas
            pause
            demo_advanced
            pause
            demo_quiz
            ;;
        *)
            echo "Usage: $0 [indexed|assoc|gotchas|advanced|quiz|all]"
            exit 1
            ;;
    esac
    
    echo ""
    echo -e "${BOLD}${GREEN}═══ Arrays Demo Completed! ═══${NC}"
}

main "$@"
