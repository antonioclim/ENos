#!/bin/bash
#
#  S02_04_demo_filtre.sh - Spectacular Text Filters Demo
#
# DESCRIPTION:
#   Visual demonstrations for Unix text processing filters:
#   - sort (sorting on various criteria)
#   - uniq (removing CONSECUTIVE duplicates - common pitfall!)
#   - cut (extracting columns/characters)
#   - paste (merging files)
#   - tr (translate/delete/squeeze characters)
#   - wc (counting lines/words/characters)
#   - head/tail (first/last lines)
#   - Complex pipelines
#
# USAGE:
#   ./S02_04_demo_filtre.sh [demo_number]
#   ./S02_04_demo_filtre.sh          # Run all demos
#   ./S02_04_demo_filtre.sh menu     # Display interactive menu
#
# DEPENDENCIES:
#   - Required: bash 4.0+, coreutils
#   - Optional: figlet, lolcat, cowsay (for visual effects)
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
    
    CHECK="✓"
    CROSS="✗"
    ARROW="→"
    PIPE_SYM="│"
    BULLET="•"
    STAR="★"
    WARNING="⚠️"
else
    RED='' GREEN='' YELLOW='' BLUE='' MAGENTA='' CYAN='' WHITE=''
    DIM='' BOLD='' RESET='' BG_RED='' BG_GREEN=''
    CHECK="[OK]" CROSS="[X]" ARROW="->" PIPE_SYM="|" BULLET="*" STAR="*" WARNING="[!]"
fi

#
# WORKING DIRECTORIES
#
DEMO_DIR="${TMPDIR:-/tmp}/demo_filters_$$"
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

print_warning() {
    echo -e "\n${BG_RED}${WHITE} ${WARNING} WARNING ${RESET} ${RED}$1${RESET}\n"
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

side_by_side() {
    local left_title="$1"
    local right_title="$2"
    local left_content="$3"
    local right_content="$4"
    
    echo -e "${YELLOW}$left_title${RESET}              ${YELLOW}$right_title${RESET}"
    echo "─────────────────────    ─────────────────────"
    paste <(echo "$left_content") <(echo "$right_content") | column -t -s $'\t' 2>/dev/null || {
        echo "$left_content"
        echo "---"
        echo "$right_content"
    }
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
# TEST DATA
#
create_test_files() {
    # File with numbers
    cat > numbers.txt << 'EOF'
42
7
100
23
7
85
42
100
7
EOF
    
    # File with colours (with non-consecutive duplicates)
    cat > colours.txt << 'EOF'
red
green
red
blue
green
red
yellow
EOF
    
    # CSV file
    cat > students.csv << 'EOF'
John,Smith,8.5,Computer Science
Mary,Johnson,9.2,Mathematics
Andrew,Williams,7.8,Computer Science
Helen,Brown,9.5,Physics
Michael,Davis,8.0,Mathematics
Anna,Miller,9.8,Computer Science
EOF
    
    # Simulated log
    cat > access.log << 'EOF'
192.168.1.10 - - [01/Jan/2025:10:15:32] "GET /index.html HTTP/1.1" 200 1234
192.168.1.20 - - [01/Jan/2025:10:15:35] "GET /api/users HTTP/1.1" 200 5678
192.168.1.10 - - [01/Jan/2025:10:16:01] "POST /api/login HTTP/1.1" 401 89
192.168.1.30 - - [01/Jan/2025:10:16:15] "GET /images/logo.png HTTP/1.1" 200 45678
192.168.1.10 - - [01/Jan/2025:10:17:22] "GET /api/users HTTP/1.1" 200 5678
192.168.1.20 - - [01/Jan/2025:10:17:45] "GET /index.html HTTP/1.1" 200 1234
192.168.1.40 - - [01/Jan/2025:10:18:30] "GET /api/products HTTP/1.1" 500 123
EOF
    
    # Text for tr
    cat > text.txt << 'EOF'
Hello World! This is a TEST.
Bash scripting is    AWESOME!
Multiple    spaces   here.
EOF
}

#
# DEMO 1: SORT - SORTING
#
demo_sort() {
    print_header "📊 DEMO 1: SORT - SORTING"
    create_test_files
    
    print_subheader "Alphabetical sorting (default)"
    
    echo -e "${BLUE}File colours.txt:${RESET}"
    cat colours.txt | sed 's/^/  /'
    echo ""
    
    print_code "sort colours.txt"
    echo -e "${BLUE}Result:${RESET}"
    sort colours.txt | sed 's/^/  /'
    
    wait_for_user
    
    print_subheader "Numeric sorting (-n)"
    
    echo -e "${BLUE}File numbers.txt:${RESET}"
    cat numbers.txt | head -5 | sed 's/^/  /'
    echo ""
    
    echo -e "${RED}WRONG - alphabetical sort:${RESET}"
    print_code "sort numbers.txt"
    sort numbers.txt | head -5 | sed 's/^/  /'
    print_explanation "100 appears before 23 (compares '1' with '2' alphabetically!)"
    
    echo ""
    echo -e "${GREEN}CORRECT - numeric sort:${RESET}"
    print_code "sort -n numbers.txt"
    sort -n numbers.txt | head -5 | sed 's/^/  /'
    
    wait_for_user
    
    print_subheader "Important options"
    
    echo -e "${CYAN}sort -r${RESET} = reverse (descending)"
    print_code "sort -rn numbers.txt | head -3"
    sort -rn numbers.txt | head -3 | sed 's/^/  /'
    
    echo ""
    echo -e "${CYAN}sort -u${RESET} = unique (remove duplicates)"
    print_code "sort -u numbers.txt"
    sort -u numbers.txt | sed 's/^/  /'
    
    wait_for_user
    
    print_subheader "Sorting on columns (-k)"
    
    echo -e "${BLUE}File students.csv:${RESET}"
    cat students.csv | sed 's/^/  /'
    echo ""
    
    echo -e "${CYAN}Sort by column 3 (grade), numeric, descending:${RESET}"
    print_code "sort -t',' -k3 -rn students.csv"
    sort -t',' -k3 -rn students.csv | sed 's/^/  /'
    
    print_explanation "-t',' = comma delimiter"
    print_explanation "-k3   = column 3"
    print_explanation "-rn   = reverse numeric"
    
    wait_for_user
}

#
# DEMO 2: UNIQ - THE DUPLICATE PITFALL
#
demo_uniq() {
    print_header "🔍 DEMO 2: UNIQ - THE DUPLICATE PITFALL"
    create_test_files
    
    print_warning "UNIQ ONLY REMOVES CONSECUTIVE DUPLICATES!"
    
    print_subheader "Demonstrating the pitfall"
    
    echo -e "${BLUE}File colours.txt:${RESET}"
    nl colours.txt | sed 's/^/  /'
    echo ""
    
    echo -e "${RED}WRONG - uniq without sort:${RESET}"
    print_code "uniq colours.txt"
    uniq colours.txt | sed 's/^/  /'
    print_explanation "Duplicates remain! 'red' appears 3 times, 'green' 2 times"
    
    wait_for_user
    
    echo -e "${GREEN}CORRECT - sort then uniq:${RESET}"
    print_code "sort colours.txt | uniq"
    sort colours.txt | uniq | sed 's/^/  /'
    
    print_tip "Always sort BEFORE uniq!"
    
    wait_for_user
    
    print_subheader "uniq -c (count occurrences)"
    
    print_code "sort colours.txt | uniq -c"
    sort colours.txt | uniq -c | sed 's/^/  /'
    
    print_explanation "The number shows how many times each value appeared"
    
    wait_for_user
    
    print_subheader "uniq -d (only duplicates)"
    
    print_code "sort colours.txt | uniq -d"
    sort colours.txt | uniq -d | sed 's/^/  /'
    
    print_explanation "-d shows ONLY values that appear more than once"
    
    wait_for_user
}

#
# DEMO 3: CUT - COLUMN EXTRACTION
#
demo_cut() {
    print_header "✂️ DEMO 3: CUT - COLUMN EXTRACTION"
    create_test_files
    
    print_subheader "Extract by delimiter and field (-d, -f)"
    
    echo -e "${BLUE}students.csv:${RESET}"
    cat students.csv | sed 's/^/  /'
    echo ""
    
    echo -e "${CYAN}Extract only first names (column 1):${RESET}"
    print_code "cut -d',' -f1 students.csv"
    cut -d',' -f1 students.csv | sed 's/^/  /'
    
    wait_for_user
    
    echo -e "${CYAN}Extract first and last name (columns 1-2):${RESET}"
    print_code "cut -d',' -f1,2 students.csv"
    cut -d',' -f1,2 students.csv | sed 's/^/  /'
    
    wait_for_user
    
    echo -e "${CYAN}Extract from column 2 to end:${RESET}"
    print_code "cut -d',' -f2- students.csv"
    cut -d',' -f2- students.csv | sed 's/^/  /'
    
    wait_for_user
    
    print_subheader "Extract by characters (-c)"
    
    echo -e "${WHITE}Extract first 4 characters:${RESET}"
    print_code "cut -c1-4 students.csv"
    cut -c1-4 students.csv | sed 's/^/  /'
    
    wait_for_user
}

#
# DEMO 4: PASTE - FILE MERGING
#
demo_paste() {
    print_header "📋 DEMO 4: PASTE - FILE MERGING"
    create_test_files
    
    # Create test files
    echo -e "A\nB\nC" > letters.txt
    echo -e "1\n2\n3" > digits.txt
    
    print_subheader "Merge files side by side"
    
    echo -e "${BLUE}letters.txt:${RESET}  ${BLUE}digits.txt:${RESET}"
    paste <(cat letters.txt) <(cat digits.txt) | column -t
    echo ""
    
    print_code "paste letters.txt digits.txt"
    paste letters.txt digits.txt | sed 's/^/  /'
    
    wait_for_user
    
    print_subheader "Custom delimiter (-d)"
    
    print_code "paste -d':' letters.txt digits.txt"
    paste -d':' letters.txt digits.txt | sed 's/^/  /'
    
    wait_for_user
    
    print_subheader "Serialise (-s)"
    
    echo -e "${WHITE}Converts columns to lines:${RESET}"
    print_code "paste -s letters.txt"
    paste -s letters.txt | sed 's/^/  /'
    
    wait_for_user
}

#
# DEMO 5: TR - CHARACTER TRANSLATION
#
demo_tr() {
    print_header "🔤 DEMO 5: TR - CHARACTER TRANSLATION"
    create_test_files
    
    print_subheader "Basic translation"
    
    echo -e "${BLUE}text.txt:${RESET}"
    cat text.txt | sed 's/^/  /'
    echo ""
    
    echo -e "${CYAN}Convert lowercase to uppercase:${RESET}"
    print_code "tr 'a-z' 'A-Z' < text.txt"
    tr 'a-z' 'A-Z' < text.txt | sed 's/^/  /'
    
    wait_for_user
    
    print_subheader "Delete characters (-d)"
    
    print_code "tr -d 'aeiou' <<< 'Hello World'"
    echo -n "  Result: "
    tr -d 'aeiou' <<< 'Hello World'
    
    print_explanation "-d deletes specified characters"
    
    wait_for_user
    
    print_subheader "Squeeze repetitions (-s)"
    
    echo -e "${CYAN}Reduce multiple spaces to one:${RESET}"
    print_code "tr -s ' ' < text.txt"
    tr -s ' ' < text.txt | sed 's/^/  /'
    
    print_explanation "-s 'squeezes' repeated characters into one"
    
    wait_for_user
    
    print_subheader "Complement (-c)"
    
    echo -e "${CYAN}Delete everything EXCEPT letters:${RESET}"
    print_code "tr -cd 'a-zA-Z\\n' <<< 'Hello 123 World!'"
    echo -n "  Result: "
    tr -cd 'a-zA-Z\n' <<< 'Hello 123 World!'
    
    print_explanation "-c = complement (invert selection)"
    
    wait_for_user
}

#
# DEMO 6: WC - WORD COUNT
#
demo_wc() {
    print_header "📏 DEMO 6: WC - WORD COUNT"
    create_test_files
    
    print_subheader "Count lines, words, bytes"
    
    echo -e "${BLUE}text.txt:${RESET}"
    cat text.txt | sed 's/^/  /'
    echo ""
    
    print_code "wc text.txt"
    wc text.txt | sed 's/^/  /'
    
    print_explanation "Format: lines  words  bytes  filename"
    
    wait_for_user
    
    print_subheader "Individual options"
    
    echo -e "${CYAN}-l = lines only:${RESET}"
    print_code "wc -l text.txt"
    wc -l text.txt | sed 's/^/  /'
    
    echo ""
    echo -e "${CYAN}-w = words only:${RESET}"
    print_code "wc -w text.txt"
    wc -w text.txt | sed 's/^/  /'
    
    echo ""
    echo -e "${CYAN}-c = bytes only:${RESET}"
    print_code "wc -c text.txt"
    wc -c text.txt | sed 's/^/  /'
    
    wait_for_user
    
    print_subheader "Useful in pipelines"
    
    print_code "ls /etc | wc -l"
    echo -n "  Files in /etc: "
    ls /etc | wc -l
    
    wait_for_user
}

#
# DEMO 7: HEAD & TAIL
#
demo_head_tail() {
    print_header "📄 DEMO 7: HEAD & TAIL"
    create_test_files
    
    # Create a larger file
    seq 1 20 > bigfile.txt
    
    print_subheader "head - first N lines"
    
    echo -e "${BLUE}bigfile.txt (1-20):${RESET}"
    echo ""
    
    print_code "head -5 bigfile.txt"
    head -5 bigfile.txt | sed 's/^/  /'
    
    print_explanation "Default is 10 lines"
    
    wait_for_user
    
    print_subheader "tail - last N lines"
    
    print_code "tail -5 bigfile.txt"
    tail -5 bigfile.txt | sed 's/^/  /'
    
    wait_for_user
    
    print_subheader "tail -f (follow)"
    
    echo -e "${YELLOW}tail -f monitors a file in real time (e.g. logs)${RESET}"
    echo ""
    
    print_code "tail -f /var/log/syslog    # System log monitoring"
    
    echo -e "${DIM}Brief demonstration:${RESET}"
    
    # Simulated log
    (
        for i in 1 2 3; do
            echo "[$(date '+%H:%M:%S')] Event $i" >> demo.log
            sleep 0.5
        done
    ) &
    
    timeout 2 tail -f demo.log 2>/dev/null | head -3 | sed 's/^/  /' || true
    wait 2>/dev/null
    
    print_tip "Use Ctrl+C to stop tail -f"
    
    wait_for_user
}

#
# DEMO 8: COMPLEX PIPELINES
#
demo_pipelines() {
    print_header "🔗 DEMO 8: COMPLEX PIPELINES"
    create_test_files
    
    print_subheader "Example 1: Top IPs from access log"
    
    echo -e "${BLUE}access.log:${RESET}"
    cat access.log | sed 's/^/  /'
    echo ""
    
    print_code "cut -d' ' -f1 access.log | sort | uniq -c | sort -rn"
    
    echo -e "${CYAN}Step by step:${RESET}"
    echo -e "  ${DIM}cut -d' ' -f1${RESET}  → extract IPs"
    echo -e "  ${DIM}sort${RESET}           → group identical IPs"
    echo -e "  ${DIM}uniq -c${RESET}        → count occurrences"
    echo -e "  ${DIM}sort -rn${RESET}       → sort descending"
    echo ""
    
    echo -e "${BLUE}Result:${RESET}"
    cut -d' ' -f1 access.log | sort | uniq -c | sort -rn | sed 's/^/  /'
    
    wait_for_user
    
    print_subheader "Example 2: Status codes from log"
    
    print_code "awk '{print \$9}' access.log | sort | uniq -c | sort -rn"
    echo -e "${BLUE}Result (HTTP code frequency):${RESET}"
    awk '{print $9}' access.log | sort | uniq -c | sort -rn | sed 's/^/  /'
    
    wait_for_user
    
    print_subheader "Example 3: Complete process analysis"
    
    print_code "ps aux | awk 'NR>1 {print \$1}' | sort | uniq -c | sort -rn | head -5"
    echo -e "${BLUE}Top 5 users by process count:${RESET}"
    ps aux | awk 'NR>1 {print $1}' | sort | uniq -c | sort -rn | head -5 | sed 's/^/  /'
    
    wait_for_user
    
    print_subheader "Example 4: Word frequency in text"
    
    echo "The quick brown fox jumps over the lazy dog. The dog sleeps." > sample.txt
    
    print_code "tr ' ' '\\n' < sample.txt | tr -d '.' | tr 'A-Z' 'a-z' | sort | uniq -c | sort -rn"
    
    echo -e "${CYAN}Pipeline:${RESET}"
    echo "  tr ' ' '\\n'    → words on separate lines"
    echo "  tr -d '.'       → remove punctuation"
    echo "  tr 'A-Z' 'a-z'  → lowercase"
    echo "  sort | uniq -c  → count"
    echo "  sort -rn        → order"
    echo ""
    
    echo -e "${BLUE}Result:${RESET}"
    tr ' ' '\n' < sample.txt | tr -d '.' | tr 'A-Z' 'a-z' | sort | uniq -c | sort -rn | sed 's/^/  /'
    
    wait_for_user
    
    print_subheader "Mental diagram for pipelines"
    
    cat << 'DIAGRAM'
    
    ┌────────────────────────────────────────────────────────────────┐
    │  UNIVERSAL PATTERN for frequency analysis:                      │
    │                                                                │
    │  [extract data] | sort | uniq -c | sort -rn | head            │
    │       ↓            ↓        ↓          ↓         ↓            │
    │    what we       group    count      order     limit          │
    │    need          same              descending   top N         │
    └────────────────────────────────────────────────────────────────┘

DIAGRAM
    
    wait_for_user
}

#
# DEMO 9: INTEGRATED EXERCISE
#
demo_integrated() {
    print_header "🎯 DEMO 9: INTEGRATED EXERCISE"
    create_test_files
    
    print_subheader "Scenario: Automated student report"
    
    echo -e "${WHITE}From students.csv, we generate a report:${RESET}"
    echo "  1. Students ordered by grade (descending)"
    echo "  2. Average grade"
    echo "  3. Number of students per department"
    echo ""
    
    echo -e "${BLUE}students.csv:${RESET}"
    cat students.csv | sed 's/^/  /'
    
    wait_for_user
    
    print_subheader "1. Top students by grade"
    
    print_code "sort -t',' -k3 -rn students.csv | head -3"
    echo -e "${BLUE}Top 3 students:${RESET}"
    sort -t',' -k3 -rn students.csv | head -3 | \
        awk -F',' '{printf "  %s %s - %.1f (%s)\n", $1, $2, $3, $4}'
    
    wait_for_user
    
    print_subheader "2. Average grade"
    
    print_code "cut -d',' -f3 students.csv | awk '{s+=\$1} END {printf \"Average: %.2f\\n\", s/NR}'"
    cut -d',' -f3 students.csv | awk '{s+=$1} END {printf "  Average: %.2f\n", s/NR}'
    
    wait_for_user
    
    print_subheader "3. Students per department"
    
    print_code "cut -d',' -f4 students.csv | sort | uniq -c | sort -rn"
    echo -e "${BLUE}Distribution:${RESET}"
    cut -d',' -f4 students.csv | sort | uniq -c | sort -rn | sed 's/^/  /'
    
    wait_for_user
    
    print_subheader "Complete report script"
    
    cat > report.sh << 'SCRIPT'
#!/bin/bash
# Automated student report

FILE="students.csv"

echo "=== STUDENT REPORT ==="
echo "Date: $(date '+%Y-%m-%d %H:%M')"
echo ""

echo "--- TOP 3 STUDENTS ---"
sort -t',' -k3 -rn "$FILE" | head -3 | \
    awk -F',' '{printf "%s %s: %.1f\n", $1, $2, $3}'
echo ""

echo "--- STATISTICS ---"
cut -d',' -f3 "$FILE" | awk '{s+=$1} END {printf "Average: %.2f\n", s/NR}'
echo "Total students: $(wc -l < "$FILE")"
echo ""

echo "--- DEPARTMENT DISTRIBUTION ---"
cut -d',' -f4 "$FILE" | sort | uniq -c | sort -rn
SCRIPT
    chmod +x report.sh
    
    echo -e "${CYAN}Contents of report.sh:${RESET}"
    cat report.sh | sed 's/^/  /'
    
    echo ""
    echo -e "${YELLOW}Execution:${RESET}"
    ./report.sh | sed 's/^/  /'
    
    wait_for_user
}

#
# MAIN MENU
#
show_menu() {
    clear
    fancy_title "FILTERS"
    
    echo ""
    echo -e "${WHITE}Select a demo to run:${RESET}"
    echo ""
    echo -e "  ${CYAN}1${RESET})  sort - Sorting"
    echo -e "  ${CYAN}2${RESET})  ${WARNING} uniq - The duplicate pitfall"
    echo -e "  ${CYAN}3${RESET})  cut - Column extraction"
    echo -e "  ${CYAN}4${RESET})  paste - File merging"
    echo -e "  ${CYAN}5${RESET})  ${WARNING} tr - Character translation"
    echo -e "  ${CYAN}6${RESET})  wc - Word count"
    echo -e "  ${CYAN}7${RESET})  head & tail"
    echo -e "  ${CYAN}8${RESET})  ${STAR} Complex pipelines"
    echo -e "  ${CYAN}9${RESET})  ${STAR} Integrated exercise"
    echo ""
    echo -e "  ${CYAN}a${RESET})  Run ALL demos"
    echo -e "  ${CYAN}q${RESET})  Exit"
    echo ""
    echo -n "Your choice: "
}

run_all_demos() {
    demo_sort
    demo_uniq
    demo_cut
    demo_paste
    demo_tr
    demo_wc
    demo_head_tail
    demo_pipelines
    demo_integrated
    
    print_header "🎉 ALL DEMOS COMPLETED!"
    
    echo -e "${GREEN}Congratulations! You have covered all text filters.${RESET}"
    echo ""
    echo -e "${WHITE}Summary:${RESET}"
    echo "  ${BULLET} sort: -n (numeric), -r (reverse), -k (column), -t (delimiter)"
    echo "  ${BULLET} uniq: ONLY consecutive! Use sort | uniq"
    echo "  ${BULLET} cut: -d (delimiter), -f (field), -c (characters)"
    echo "  ${BULLET} paste: merging, -d (delimiter), -s (serialise)"
    echo "  ${BULLET} tr: characters, -d (delete), -s (squeeze), -c (complement)"
    echo "  ${BULLET} wc: -l (lines), -w (words), -c (bytes)"
    echo "  ${BULLET} head/tail: -n, tail -f (monitoring)"
    echo ""
    echo -e "${CYAN}Universal pattern:${RESET}"
    echo "  [extract] | sort | uniq -c | sort -rn | head"
    echo ""
}

#
# MAIN
#
main() {
    case "${1:-menu}" in
        1) demo_sort ;;
        2) demo_uniq ;;
        3) demo_cut ;;
        4) demo_paste ;;
        5) demo_tr ;;
        6) demo_wc ;;
        7) demo_head_tail ;;
        8) demo_pipelines ;;
        9) demo_integrated ;;
        all|a) run_all_demos ;;
        menu|"")
            while true; do
                show_menu
                read -r choice
                case "$choice" in
                    1) demo_sort ;;
                    2) demo_uniq ;;
                    3) demo_cut ;;
                    4) demo_paste ;;
                    5) demo_tr ;;
                    6) demo_wc ;;
                    7) demo_head_tail ;;
                    8) demo_pipelines ;;
                    9) demo_integrated ;;
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
            echo "Usage: $0 [1-9|all|menu]"
            exit 1
            ;;
    esac
}

main "$@"
