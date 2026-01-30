#!/bin/bash
#
#  S02_05_demo_bucle.sh - Spectacular Bash Loops Demo
#
# DESCRIPTION:
#   Visual demonstrations for Bash loops:
#   - for (list, brace expansion, glob, C-style)
#   - while (condition, read, infinite loops)
#   - until (inverse of while)
#   - break and continue (control flow)
#   - COMMON PITFALLS:
#     * {1..$N} with variables (DOES NOT work!)
#     * The subshell problem with pipe | while read
#
# USAGE:
#   ./S02_05_demo_bucle.sh [demo_number]
#   ./S02_05_demo_bucle.sh          # Run all demos
#   ./S02_05_demo_bucle.sh menu     # Display interactive menu
#
# DEPENDENCIES:
#   - Required: bash 4.0+
#   - Optional: figlet, lolcat, pv (for visual effects)
#
# AUTHOR: OS Pedagogical Kit | ASE Bucharest - CSIE
# VERSION: 1.0 | January 2025
#

set -euo pipefail

#
# COLOUR AND SYMBOL CONFIGURATION
#
if [[ -t 1 ]]; then
    RED='\033[1;31m'
    GREEN='\033[1;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[1;34m'
    MAGENTA='\033[1;35m'
    CYAN='\033[1;36m'
    WHITE='\033[1;37m'
    DIM='\033[2m'
    BOLD='\033[1m'
    RESET='\033[0m'
    BG_RED='\033[41m'
    BG_GREEN='\033[42m'
    BG_YELLOW='\033[43m'
    
    CHECK="✓"
    CROSS="✗"
    ARROW="→"
    BULLET="•"
    STAR="★"
    WARNING="⚠️"
    LOOP="🔄"
else
    RED='' GREEN='' YELLOW='' BLUE='' MAGENTA='' CYAN='' WHITE=''
    DIM='' BOLD='' RESET='' BG_RED='' BG_GREEN='' BG_YELLOW=''
    CHECK="[OK]" CROSS="[X]" ARROW="->" BULLET="*" STAR="*" WARNING="[!]" LOOP="[O]"
fi

#
# WORKING DIRECTORIES
#
DEMO_DIR="${TMPDIR:-/tmp}/demo_loops_$$"
mkdir -p "$DEMO_DIR"
cd "$DEMO_DIR"

cleanup() {
    cd /
    rm -rf "$DEMO_DIR" 2>/dev/null || true
}
trap cleanup EXIT

#
# HELPER FUNCTIONS
#
print_header() {
    local title="$1"
    local width=70
    
    echo ""
    echo -e "${CYAN}╔$(printf '═%.0s' $(seq 1 $((width-2))))╗${RESET}"
    printf "${CYAN}║${RESET} ${BOLD}${WHITE}%-$((width-4))s${RESET} ${CYAN}║${RESET}\n" "$title"
    echo -e "${CYAN}╚$(printf '═%.0s' $(seq 1 $((width-2))))╝${RESET}"
    echo ""
}

print_subheader() {
    echo -e "\n${YELLOW}━━━ $1 ━━━${RESET}\n"
}

print_code() {
    echo -e "${DIM}┌─────────────────────────────────────────────────────────────────┐${RESET}"
    echo -e "${GREEN}  $1${RESET}"
    echo -e "${DIM}└─────────────────────────────────────────────────────────────────┘${RESET}"
}

print_multiline_code() {
    echo -e "${DIM}┌─────────────────────────────────────────────────────────────────┐${RESET}"
    while IFS= read -r line; do
        echo -e "${GREEN}  $line${RESET}"
    done
    echo -e "${DIM}└─────────────────────────────────────────────────────────────────┘${RESET}"
}

print_warning() {
    echo -e "\n${BG_RED}${WHITE} ${WARNING} COMMON PITFALL ${RESET} ${RED}$1${RESET}\n"
}

print_tip() {
    echo -e "${GREEN}💡 TIP: $1${RESET}"
}

print_explanation() {
    echo -e "${MAGENTA}  ${BULLET} $1${RESET}"
}

wait_for_user() {
    echo ""
    echo -e "${DIM}Press ENTER to continue...${RESET}"
    read -r
}

animate_iteration() {
    local text="$1"
    local color="${2:-$GREEN}"
    echo -e "  ${color}${LOOP} Iteration: ${WHITE}$text${RESET}"
    sleep 0.3
}

fancy_title() {
    local text="$1"
    
    if command -v figlet &>/dev/null; then
        if command -v lolcat &>/dev/null; then
            figlet -f small "$text" 2>/dev/null | lolcat -f 2>/dev/null || echo "=== $text ==="
        else
            echo -e "${CYAN}"
            figlet -f small "$text" 2>/dev/null || echo "=== $text ==="
            echo -e "${RESET}"
        fi
    else
        echo ""
        echo -e "${CYAN}╭────────────────────────────────────────╮${RESET}"
        echo -e "${CYAN}│${RESET}  ${BOLD}${WHITE}$text${RESET}  ${CYAN}│${RESET}"
        echo -e "${CYAN}╰────────────────────────────────────────╯${RESET}"
    fi
}

#
# DEMO 1: FOR - ITERATING OVER LISTS
#
demo_for_list() {
    print_header "🔄 DEMO 1: FOR - ITERATING OVER LISTS"
    
    print_subheader "Basic syntax"
    
    cat << 'SYNTAX'
    for variable in list_of_values; do
        # commands
    done
SYNTAX
    
    echo ""
    
    print_subheader "Example 1: Explicit list"
    
    print_multiline_code << 'CODE'
for colour in red green blue; do
    echo "Colour: $colour"
done
CODE
    
    echo -e "${BLUE}Execution:${RESET}"
    for colour in red green blue; do
        animate_iteration "$colour"
    done
    
    wait_for_user
    
    print_subheader "Example 2: List from variable"
    
    print_multiline_code << 'CODE'
FRUITS="apple pear plum"
for fruit in $FRUITS; do
    echo "Fruit: $fruit"
done
CODE
    
    echo -e "${BLUE}Execution:${RESET}"
    FRUITS="apple pear plum"
    for fruit in $FRUITS; do
        animate_iteration "$fruit"
    done
    
    wait_for_user
    
    print_subheader "Example 3: Command output"
    
    print_multiline_code << 'CODE'
for user in $(cut -d: -f1 /etc/passwd | head -3); do
    echo "User: $user"
done
CODE
    
    echo -e "${BLUE}Execution:${RESET}"
    for user in $(cut -d: -f1 /etc/passwd | head -3); do
        animate_iteration "$user"
    done
    
    wait_for_user
}

#
# DEMO 2: FOR - BRACE EXPANSION
#
demo_for_brace() {
    print_header "🔢 DEMO 2: FOR - BRACE EXPANSION {..}"
    
    print_subheader "Numbers with {start..end}"
    
    print_multiline_code << 'CODE'
for i in {1..5}; do
    echo "Number: $i"
done
CODE
    
    echo -e "${BLUE}Execution:${RESET}"
    for i in {1..5}; do
        animate_iteration "$i"
    done
    
    wait_for_user
    
    print_subheader "With step: {start..end..step}"
    
    print_multiline_code << 'CODE'
for i in {0..10..2}; do
    echo "Even: $i"
done
CODE
    
    echo -e "${BLUE}Execution (even numbers):${RESET}"
    for i in {0..10..2}; do
        animate_iteration "$i"
    done
    
    wait_for_user
    
    print_subheader "Descending"
    
    print_multiline_code << 'CODE'
for i in {5..1}; do
    echo "Countdown: $i"
done
echo "LAUNCH! 🚀"
CODE
    
    echo -e "${BLUE}Execution:${RESET}"
    for i in {5..1}; do
        animate_iteration "$i" "$YELLOW"
        sleep 0.2
    done
    echo -e "  ${GREEN}${STAR} LAUNCH! 🚀${RESET}"
    
    wait_for_user
    
    print_subheader "Letters"
    
    print_multiline_code << 'CODE'
for letter in {a..e}; do
    echo "Letter: $letter"
done
CODE
    
    echo -e "${BLUE}Execution:${RESET}"
    for letter in {a..e}; do
        animate_iteration "$letter"
    done
    
    wait_for_user
    
    # THE PITFALL!
    print_warning "{1..\$N} DOES NOT WORK with variables!"
    
    print_multiline_code << 'CODE'
N=5
for i in {1..$N}; do    # WRONG!
    echo "$i"
done
CODE
    
    echo -e "${RED}Result (incorrect):${RESET}"
    N=5
    for i in {1..$N}; do
        echo "  $i   ← Not expanded!"
    done
    
    wait_for_user
    
    echo -e "${GREEN}Solution 1: seq${RESET}"
    print_code "for i in \$(seq 1 \$N); do"
    for i in $(seq 1 $N); do
        animate_iteration "$i"
    done
    
    wait_for_user
    
    echo -e "${GREEN}Solution 2: C-style for${RESET}"
    print_code "for ((i=1; i<=N; i++)); do"
    for ((i=1; i<=N; i++)); do
        animate_iteration "$i"
    done
    
    wait_for_user
}

#
# DEMO 3: FOR - GLOB (FILES)
#
demo_for_glob() {
    print_header "📁 DEMO 3: FOR - GLOB (FILES)"
    
    # Create test files
    mkdir -p test_dir
    touch test_dir/file{1..3}.txt
    touch test_dir/data{1..2}.csv
    
    print_subheader "Iterate over files"
    
    echo -e "${BLUE}Files in test_dir/:${RESET}"
    ls test_dir/ | sed 's/^/  /'
    echo ""
    
    print_multiline_code << 'CODE'
for file in test_dir/*.txt; do
    echo "Processing: $file"
done
CODE
    
    echo -e "${BLUE}Execution:${RESET}"
    for file in test_dir/*.txt; do
        animate_iteration "$file"
    done
    
    wait_for_user
    
    print_subheader "⚠️ Pitfall: no matches"
    
    echo -e "${WHITE}What happens if there are no matches?${RESET}"
    
    print_code "for file in test_dir/*.xyz; do echo \"\$file\"; done"
    for file in test_dir/*.xyz; do
        echo "  $file   ← Literal pattern, not expanded!"
    done
    
    wait_for_user
    
    echo -e "${GREEN}Solution: nullglob${RESET}"
    print_multiline_code << 'CODE'
shopt -s nullglob
for file in test_dir/*.xyz; do
    echo "$file"
done
# (nothing is printed if no matches)
CODE
    
    wait_for_user
}

#
# DEMO 4: FOR - C-STYLE
#
demo_for_cstyle() {
    print_header "💻 DEMO 4: FOR - C-STYLE (( ))"
    
    print_subheader "Syntax similar to C/Java"
    
    print_multiline_code << 'CODE'
for ((i=0; i<5; i++)); do
    echo "Index: $i"
done
CODE
    
    echo -e "${BLUE}Execution:${RESET}"
    for ((i=0; i<5; i++)); do
        animate_iteration "$i"
    done
    
    wait_for_user
    
    print_subheader "With step"
    
    print_multiline_code << 'CODE'
for ((i=0; i<=10; i+=2)); do
    echo "Even: $i"
done
CODE
    
    echo -e "${BLUE}Execution:${RESET}"
    for ((i=0; i<=10; i+=2)); do
        animate_iteration "$i"
    done
    
    wait_for_user
    
    print_subheader "Descending"
    
    print_multiline_code << 'CODE'
for ((i=5; i>=1; i--)); do
    echo "Countdown: $i"
done
CODE
    
    echo -e "${BLUE}Execution:${RESET}"
    for ((i=5; i>=1; i--)); do
        animate_iteration "$i" "$YELLOW"
    done
    
    wait_for_user
    
    print_tip "C-style for is ideal when you need variables in the range!"
}

#
# DEMO 5: WHILE
#
demo_while() {
    print_header "🔁 DEMO 5: WHILE"
    
    print_subheader "Basic syntax"
    
    cat << 'SYNTAX'
    while [ condition ]; do
        # commands
    done
SYNTAX
    
    echo ""
    
    print_subheader "Example: counter"
    
    print_multiline_code << 'CODE'
count=1
while [ $count -le 5 ]; do
    echo "Count: $count"
    ((count++))
done
CODE
    
    echo -e "${BLUE}Execution:${RESET}"
    count=1
    while [ $count -le 5 ]; do
        animate_iteration "$count"
        ((count++))
    done
    
    wait_for_user
    
    print_subheader "while read - reading files line by line"
    
    cat > data.txt << 'EOF'
Line one
Line two
Line three
EOF
    
    echo -e "${BLUE}data.txt:${RESET}"
    cat data.txt | sed 's/^/  /'
    echo ""
    
    print_multiline_code << 'CODE'
while read line; do
    echo "Read: $line"
done < data.txt
CODE
    
    echo -e "${BLUE}Execution:${RESET}"
    while read line; do
        animate_iteration "$line"
    done < data.txt
    
    wait_for_user
    
    print_subheader "while read with IFS (CSV parsing)"
    
    cat > products.csv << 'EOF'
Laptop,2500,10
Monitor,800,25
Keyboard,150,50
EOF
    
    echo -e "${BLUE}products.csv:${RESET}"
    cat products.csv | sed 's/^/  /'
    echo ""
    
    print_multiline_code << 'CODE'
while IFS=',' read -r product price quantity; do
    total=$((price * quantity))
    echo "$product: $total"
done < products.csv
CODE
    
    echo -e "${BLUE}Execution:${RESET}"
    while IFS=',' read -r product price quantity; do
        total=$((price * quantity))
        echo -e "  ${CYAN}$product${RESET}: ${WHITE}$total${RESET}"
    done < products.csv
    
    wait_for_user
}

#
# DEMO 6: SUBSHELL PITFALL
#
demo_subshell_trap() {
    print_header "⚠️ DEMO 6: THE SUBSHELL PITFALL"
    
    print_warning "Variables set inside pipe | while are LOST!"
    
    print_subheader "Demonstration of the problem"
    
    print_multiline_code << 'CODE'
count=0
echo -e "a\nb\nc" | while read line; do
    ((count++))
    echo "Inside: count=$count"
done
echo "Outside: count=$count"   # count = 0!
CODE
    
    echo -e "${BLUE}Execution:${RESET}"
    count=0
    echo -e "a\nb\nc" | while read line; do
        ((count++))
        echo -e "  ${GREEN}Inside: count=$count${RESET}"
    done
    echo -e "  ${RED}Outside: count=$count   ← LOST!${RESET}"
    
    wait_for_user
    
    cat << 'DIAGRAM'
    
    ┌─────────────────────────────────────────────────────────────┐
    │  WHY THIS HAPPENS:                                          │
    │                                                             │
    │  echo | while read ...                                      │
    │         └──────────────┐                                    │
    │                        │                                    │
    │          while runs in SUBSHELL                            │
    │          ↓                                                  │
    │          Variables are LOCAL to the subshell               │
    │          ↓                                                  │
    │          When subshell exits, variables DISAPPEAR          │
    │                                                             │
    └─────────────────────────────────────────────────────────────┘

DIAGRAM
    
    wait_for_user
    
    print_subheader "Solution 1: Process substitution"
    
    print_multiline_code << 'CODE'
count=0
while read line; do
    ((count++))
done < <(echo -e "a\nb\nc")
echo "Outside: count=$count"   # count = 3!
CODE
    
    echo -e "${BLUE}Execution:${RESET}"
    count=0
    while read line; do
        ((count++))
    done < <(echo -e "a\nb\nc")
    echo -e "  ${GREEN}Outside: count=$count   ← CORRECT!${RESET}"
    
    wait_for_user
    
    print_subheader "Solution 2: Here string"
    
    print_multiline_code << 'CODE'
count=0
while read line; do
    ((count++))
done <<< "$(echo -e 'a\nb\nc')"
echo "Outside: count=$count"
CODE
    
    echo -e "${BLUE}Execution:${RESET}"
    count=0
    while read line; do
        ((count++))
    done <<< "$(echo -e 'a\nb\nc')"
    echo -e "  ${GREEN}Outside: count=$count   ← CORRECT!${RESET}"
    
    print_tip "Use < file or < <(command) instead of pipe!"
    
    wait_for_user
}

#
# DEMO 7: UNTIL
#
demo_until() {
    print_header "🔄 DEMO 7: UNTIL"
    
    print_subheader "until = inverse of while"
    
    echo -e "${WHITE}while: runs WHILE condition is TRUE${RESET}"
    echo -e "${WHITE}until: runs UNTIL condition becomes TRUE${RESET}"
    echo ""
    
    print_multiline_code << 'CODE'
count=1
until [ $count -gt 5 ]; do
    echo "Count: $count"
    ((count++))
done
CODE
    
    echo -e "${BLUE}Execution:${RESET}"
    count=1
    until [ $count -gt 5 ]; do
        animate_iteration "$count"
        ((count++))
    done
    
    wait_for_user
    
    print_subheader "Use case: wait for condition"
    
    print_multiline_code << 'CODE'
# Wait until file exists
until [ -f /tmp/signal_file ]; do
    echo "Waiting..."
    sleep 1
done
echo "File appeared!"
CODE
    
    print_explanation "Useful for waiting for events/conditions"
    
    wait_for_user
}

#
# DEMO 8: BREAK AND CONTINUE
#
demo_break_continue() {
    print_header "🎮 DEMO 8: BREAK AND CONTINUE"
    
    print_subheader "break - exit from loop"
    
    print_multiline_code << 'CODE'
for i in {1..10}; do
    if [ $i -eq 5 ]; then
        echo "Stopping at $i"
        break
    fi
    echo "Number: $i"
done
echo "Loop finished"
CODE
    
    echo -e "${BLUE}Execution:${RESET}"
    for i in {1..10}; do
        if [ $i -eq 5 ]; then
            echo -e "  ${RED}Stopping at $i${RESET}"
            break
        fi
        animate_iteration "$i"
    done
    echo -e "  ${GREEN}Loop finished${RESET}"
    
    wait_for_user
    
    print_subheader "continue - skip to next iteration"
    
    print_multiline_code << 'CODE'
for i in {1..5}; do
    if [ $i -eq 3 ]; then
        echo "Skipping $i"
        continue
    fi
    echo "Number: $i"
done
CODE
    
    echo -e "${BLUE}Execution:${RESET}"
    for i in {1..5}; do
        if [ $i -eq 3 ]; then
            echo -e "  ${YELLOW}Skipping $i${RESET}"
            continue
        fi
        animate_iteration "$i"
    done
    
    wait_for_user
    
    print_subheader "break N - exit from nested loops"
    
    print_multiline_code << 'CODE'
for i in {1..3}; do
    for j in {1..3}; do
        if [ $j -eq 2 ]; then
            break 2    # Exit BOTH loops
        fi
        echo "i=$i, j=$j"
    done
done
CODE
    
    echo -e "${BLUE}Execution:${RESET}"
    for i in {1..3}; do
        for j in {1..3}; do
            if [ $j -eq 2 ]; then
                echo -e "  ${RED}break 2 - exiting both loops${RESET}"
                break 2
            fi
            echo -e "  ${CYAN}i=$i, j=$j${RESET}"
        done
    done
    echo -e "  ${GREEN}Finished${RESET}"
    
    wait_for_user
    
    print_subheader "⚠️ break vs exit"
    
    cat << 'COMPARE'
    
    ┌─────────────────────────────────────────────────────────────┐
    │                                                             │
    │  break     →  Exits the LOOP, script continues             │
    │                                                             │
    │  exit      →  Terminates the SCRIPT completely             │
    │                                                             │
    │  exit N    →  Terminates script with exit code N           │
    │                                                             │
    └─────────────────────────────────────────────────────────────┘

COMPARE
    
    wait_for_user
}

#
# DEMO 9: PRACTICAL EXAMPLES
#
demo_practical() {
    print_header "🎯 DEMO 9: PRACTICAL EXAMPLES"
    
    print_subheader "1. Batch rename files"
    
    # Create test files
    mkdir -p batch_test
    touch batch_test/file{1..3}.txt
    
    print_multiline_code << 'CODE'
for file in batch_test/*.txt; do
    base=$(basename "$file" .txt)
    mv "$file" "batch_test/document_$base.txt"
done
CODE
    
    echo -e "${BLUE}Before:${RESET} $(ls batch_test/)"
    for file in batch_test/*.txt; do
        base=$(basename "$file" .txt)
        mv "$file" "batch_test/document_$base.txt"
    done
    echo -e "${GREEN}After:${RESET}    $(ls batch_test/)"
    
    wait_for_user
    
    print_subheader "2. CSV processing with while read"
    
    cat > products.csv << 'EOF'
Laptop,2500,10
Monitor,800,25
Keyboard,150,50
Mouse,75,100
EOF
    
    print_multiline_code << 'CODE'
total=0
while IFS=',' read -r product price quantity; do
    subtotal=$((price * quantity))
    ((total += subtotal))
    printf "%-12s: %d x %d = %d GBP\n" "$product" "$quantity" "$price" "$subtotal"
done < products.csv
echo "─────────────────────────────"
echo "TOTAL: $total GBP"
CODE
    
    echo -e "${BLUE}Execution:${RESET}"
    total=0
    while IFS=',' read -r product price quantity; do
        subtotal=$((price * quantity))
        ((total += subtotal))
        printf "  ${CYAN}%-12s${RESET}: %d x %d = ${WHITE}%d GBP${RESET}\n" "$product" "$quantity" "$price" "$subtotal"
    done < products.csv
    echo "  ─────────────────────────────"
    echo -e "  ${GREEN}TOTAL: $total GBP${RESET}"
    
    wait_for_user
    
    print_subheader "3. Simple animation"
    
    print_multiline_code << 'CODE'
chars="/-\|"
echo -n "Processing: "
for i in {1..20}; do
    printf "\b${chars:i%4:1}"
    sleep 0.1
done
echo -e "\b ✓ Complete!"
CODE
    
    echo -e "${BLUE}Execution:${RESET}"
    chars="/-\|"
    echo -n "  Processing: "
    for i in {1..20}; do
        printf "\b${chars:i%4:1}"
        sleep 0.1
    done
    echo -e "\b ${GREEN}${CHECK} Complete!${RESET}"
    
    wait_for_user
    
    print_subheader "4. Interactive menu with select"
    
    print_multiline_code << 'CODE'
PS3="Your choice: "
select opt in "Option A" "Option B" "Exit"; do
    case $opt in
        "Option A") echo "You chose A" ;;
        "Option B") echo "You chose B" ;;
        "Exit") break ;;
        *) echo "Invalid option" ;;
    esac
done
CODE
    
    echo -e "${DIM}(select automatically creates a numbered menu)${RESET}"
    
    wait_for_user
}

#
# DEMO 10: VISUAL SUMMARY
#
demo_recap() {
    print_header "📚 DEMO 10: SUMMARY"
    
    cat << 'RECAP'
    
    ┌────────────────────────────────────────────────────────────────────┐
    │                    BASH LOOP TYPES                                  │
    ├────────────────────────────────────────────────────────────────────┤
    │                                                                    │
    │  FOR LIST          for x in a b c; do ... done                    │
    │  FOR BRACE         for i in {1..10}; do ... done                  │
    │  FOR GLOB          for f in *.txt; do ... done                    │
    │  FOR C-STYLE       for ((i=0; i<10; i++)); do ... done            │
    │                                                                    │
    │  WHILE             while [ cond ]; do ... done                    │
    │  WHILE READ        while read line; do ... done < file           │
    │                                                                    │
    │  UNTIL             until [ cond ]; do ... done                    │
    │                                                                    │
    ├────────────────────────────────────────────────────────────────────┤
    │                    ⚠️ PITFALLS TO AVOID                           │
    ├────────────────────────────────────────────────────────────────────┤
    │                                                                    │
    │  ✗ {1..$N}          Brace expansion DOES NOT work with variables  │
    │  ✓ $(seq 1 $N)      Solution 1                                    │
    │  ✓ for ((i=1;i<=N;i++))   Solution 2                              │
    │                                                                    │
    │  ✗ cat f | while    Variables are lost (subshell)                │
    │  ✓ while ... < f    Redirection instead of pipe                  │
    │                                                                    │
    │  ✗ for f in $var    Problems with spaces                         │
    │  ✓ for f in "$var"  Quotes for safety                            │
    │                                                                    │
    ├────────────────────────────────────────────────────────────────────┤
    │                    CONTROL FLOW                                    │
    ├────────────────────────────────────────────────────────────────────┤
    │                                                                    │
    │  break              Exit from current loop                        │
    │  break N            Exit from N nested loops                      │
    │  continue           Skip to next iteration                        │
    │  continue N         Skip in Nth outer loop                        │
    │  exit               Terminates the SCRIPT (not the loop!)         │
    │                                                                    │
    └────────────────────────────────────────────────────────────────────┘

RECAP
    
    wait_for_user
}

#
# MAIN MENU
#
show_menu() {
    clear
    fancy_title "LOOPS"
    
    echo ""
    echo -e "${WHITE}Select a demo to run:${RESET}"
    echo ""
    echo -e "  ${CYAN}1${RESET})  for - Iterating over lists"
    echo -e "  ${CYAN}2${RESET})  ${WARNING} for - Brace expansion {..}"
    echo -e "  ${CYAN}3${RESET})  for - Glob (files)"
    echo -e "  ${CYAN}4${RESET})  for - C-style (( ))"
    echo -e "  ${CYAN}5${RESET})  while"
    echo -e "  ${CYAN}6${RESET})  ${WARNING} The subshell pitfall"
    echo -e "  ${CYAN}7${RESET})  until"
    echo -e "  ${CYAN}8${RESET})  break and continue"
    echo -e "  ${CYAN}9${RESET})  ${STAR} Practical examples"
    echo -e "  ${CYAN}10${RESET}) Summary"
    echo ""
    echo -e "  ${CYAN}a${RESET})  Run ALL demos"
    echo -e "  ${CYAN}q${RESET})  Exit"
    echo ""
    echo -n "Your choice: "
}

run_all_demos() {
    demo_for_list
    demo_for_brace
    demo_for_glob
    demo_for_cstyle
    demo_while
    demo_subshell_trap
    demo_until
    demo_break_continue
    demo_practical
    demo_recap
    
    print_header "🎉 ALL DEMOS COMPLETED!"
    
    echo -e "${GREEN}Congratulations! You have covered all loop concepts.${RESET}"
    echo ""
    echo -e "${WHITE}Most important points to remember:${RESET}"
    echo ""
    echo -e "  ${BULLET} ${RED}{1..\$N} DOES NOT work${RESET} - use seq or (( ))"
    echo -e "  ${BULLET} ${RED}cat | while${RESET} loses variables - use < file"
    echo -e "  ${BULLET} Use ${CYAN}\"quotes\"${RESET} around variables"
    echo -e "  ${BULLET} ${CYAN}break${RESET} = exit loop, ${CYAN}exit${RESET} = exit script"
    echo ""
}

#
# MAIN
#
main() {
    case "${1:-menu}" in
        1) demo_for_list ;;
        2) demo_for_brace ;;
        3) demo_for_glob ;;
        4) demo_for_cstyle ;;
        5) demo_while ;;
        6) demo_subshell_trap ;;
        7) demo_until ;;
        8) demo_break_continue ;;
        9) demo_practical ;;
        10) demo_recap ;;
        all|a) run_all_demos ;;
        menu|"")
            while true; do
                show_menu
                read -r choice
                case "$choice" in
                    1) demo_for_list ;;
                    2) demo_for_brace ;;
                    3) demo_for_glob ;;
                    4) demo_for_cstyle ;;
                    5) demo_while ;;
                    6) demo_subshell_trap ;;
                    7) demo_until ;;
                    8) demo_break_continue ;;
                    9) demo_practical ;;
                    10) demo_recap ;;
                    a|A) run_all_demos ;;
                    q|Q) 
                        echo -e "\n${GREEN}Goodbye!${RESET}"
                        exit 0 
                        ;;
                    *) echo -e "${RED}Invalid option${RESET}" ;;
                esac
            done
            ;;
        *)
            echo "Usage: $0 [1-10|all|menu]"
            exit 1
            ;;
    esac
}

main "$@"
