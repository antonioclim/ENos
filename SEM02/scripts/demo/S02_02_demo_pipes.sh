#!/bin/bash
#
#  S02_02_demo_pipes.sh
#  Interactive demonstration for building pipelines
#  Operating Systems | ASE Bucharest - CSIE
#   Duration: 8-10 minutes
#  Dependencies: bash 4.0+, optional: figlet, lolcat, pv
#

set -o pipefail

#
# COLOUR AND STYLE CONFIGURATION
#
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly MAGENTA='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly WHITE='\033[1;37m'
readonly BOLD='\033[1m'
readonly DIM='\033[2m'
readonly RESET='\033[0m'

readonly CHECKMARK="${GREEN}✓${RESET}"
readonly CROSS="${RED}✗${RESET}"
readonly ARROW="${CYAN}→${RESET}"
readonly PIPE_SYMBOL="${YELLOW}│${RESET}"

#
# UTILITY FUNCTIONS
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
    echo -e "\n${YELLOW}▶ $1${RESET}\n"
}

print_command() {
    echo -e "${DIM}$ ${RESET}${GREEN}$1${RESET}"
}

print_explanation() {
    echo -e "${DIM}   ℹ️  $1${RESET}"
}

print_step() {
    echo -e "${MAGENTA}[Step $1]${RESET} $2"
}

wait_for_user() {
    echo ""
    echo -e "${DIM}Press ${BOLD}ENTER${RESET}${DIM} to continue...${RESET}"
    read -r
}

run_with_highlight() {
    local cmd="$1"
    local desc="$2"
    
    echo -e "${CYAN}┌─ Command ─────────────────────────────────────────────────────┐${RESET}"
    echo -e "${CYAN}│${RESET} ${GREEN}$cmd${RESET}"
    echo -e "${CYAN}└───────────────────────────────────────────────────────────────┘${RESET}"
    if [[ -n "$desc" ]]; then
        print_explanation "$desc"
    fi
    echo -e "${YELLOW}Output:${RESET}"
    eval "$cmd" 2>&1 | sed 's/^/  /'
    echo ""
}

show_pipeline_diagram() {
    local components=("$@")
    local diagram=""
    
    echo -e "${CYAN}┌─ Visual Pipeline ─────────────────────────────────────────────┐${RESET}"
    
    local first=true
    for comp in "${components[@]}"; do
        if [[ "$first" == "true" ]]; then
            diagram="[$comp]"
            first=false
        else
            diagram="$diagram ──▶ [$comp]"
        fi
    done
    
    echo -e "${CYAN}│${RESET} ${WHITE}$diagram${RESET}"
    echo -e "${CYAN}│${RESET}"
    echo -e "${CYAN}│${RESET} ${DIM}Data: stdin ══▶ processing ══▶ stdout${RESET}"
    echo -e "${CYAN}└───────────────────────────────────────────────────────────────┘${RESET}"
}

#
# DEPENDENCY CHECK
#

check_dependencies() {
    local missing=()
    
    for cmd in ps awk sort head cut grep; do
        if ! command -v "$cmd" &>/dev/null; then
            missing+=("$cmd")
        fi
    done
    
    if [[ ${#missing[@]} -gt 0 ]]; then
        echo -e "${RED}Error: Missing commands: ${missing[*]}${RESET}"
        exit 1
    fi
    
    # Optional tools
    if command -v figlet &>/dev/null; then
        HAS_FIGLET=true
    else
        HAS_FIGLET=false
    fi
    
    if command -v lolcat &>/dev/null; then
        HAS_LOLCAT=true
    else
        HAS_LOLCAT=false
    fi
    
    if command -v pv &>/dev/null; then
        HAS_PV=true
    else
        HAS_PV=false
    fi
}

#
# DEMO 1: PIPELINE INTRODUCTION
#

demo_intro() {
    print_header "🔄 DEMO: INTRODUCTION TO PIPELINES"
    
    echo -e "${WHITE}What is a pipeline?${RESET}"
    echo ""
    echo "  A pipeline connects the stdout of one command to the stdin of another."
    echo "  The | (pipe) symbol makes this connection."
    echo ""
    
    cat << 'DIAGRAM'
    ┌──────────┐     PIPE     ┌──────────┐
    │ Command  │──────────────│ Command  │
    │    1     │   stdout→    │    2     │   → final stdout
    │          │   stdin      │          │
    └──────────┘              └──────────┘
         ↑
      stdin
DIAGRAM
    
    wait_for_user
    
    print_subheader "Simple example: count files"
    
    echo -e "${YELLOW}Without pipe (2 separate commands):${RESET}"
    run_with_highlight "ls /etc" "List files"
    echo -e "${DIM}...and then manually count? No!${RESET}"
    
    wait_for_user
    
    echo -e "${YELLOW}With pipe (a single compound command):${RESET}"
    run_with_highlight "ls /etc | wc -l" "stdout from ls becomes stdin for wc"
    
    show_pipeline_diagram "ls /etc" "wc -l"
}

#
# DEMO 2: INCREMENTAL BUILDING
#

demo_incremental() {
    print_header "📈 DEMO: INCREMENTAL PIPELINE BUILDING"
    
    echo -e "${WHITE}The golden rule: build the pipeline step by step!${RESET}"
    echo -e "${DIM}Verify the output at each step before adding another.${RESET}"
    echo ""
    
    wait_for_user
    
    print_subheader "Objective: Top 5 users with the most processes"
    
    print_step "1" "Start with raw data"
    run_with_highlight "ps aux | head -5" "We see the structure - column 1 is username"
    
    wait_for_user
    
    print_step "2" "Extract only usernames"
    show_pipeline_diagram "ps aux" "awk '{print \$1}'"
    run_with_highlight "ps aux | awk '{print \$1}' | head -10" "Only column 1"
    
    wait_for_user
    
    print_step "3" "Sort to prepare for uniq"
    echo -e "${RED}⚠️  Pitfall: uniq only works on SORTED data!${RESET}"
    show_pipeline_diagram "ps aux" "awk" "sort"
    run_with_highlight "ps aux | awk '{print \$1}' | sort | head -10" "Now they are sorted"
    
    wait_for_user
    
    print_step "4" "Count duplicates with uniq -c"
    show_pipeline_diagram "ps aux" "awk" "sort" "uniq -c"
    run_with_highlight "ps aux | awk '{print \$1}' | sort | uniq -c | head -10" "Frequency of each user"
    
    wait_for_user
    
    print_step "5" "Sort numerically in descending order"
    show_pipeline_diagram "ps aux" "awk" "sort" "uniq -c" "sort -rn"
    run_with_highlight "ps aux | awk '{print \$1}' | sort | uniq -c | sort -rn | head -5" "Top 5 users"
    
    wait_for_user
    
    print_step "6" "The complete final pipeline"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "${WHITE}ps aux | awk '{print \$1}' | sort | uniq -c | sort -rn | head -5${RESET}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
}

#
# DEMO 3: PIPESTATUS AND EXIT CODES
#

demo_pipestatus() {
    print_header "🎯 DEMO: EXIT CODES IN PIPELINES"
    
    echo -e "${WHITE}Question: What is the exit code of a pipeline?${RESET}"
    echo ""
    echo "  By default: the exit code of the LAST command in the pipeline"
    echo "  With pipefail: the first non-zero exit code"
    echo ""
    
    wait_for_user
    
    print_subheader "Example: command that fails in the middle"
    
    echo -e "${YELLOW}Pipeline with error at the start:${RESET}"
    run_with_highlight "ls /nonexistent 2>/dev/null | wc -l; echo \"Exit code: \$?\"" \
        "ls fails, but wc succeeds, so exit=0"
    
    wait_for_user
    
    print_subheader "PIPESTATUS: capture all exit codes"
    
    echo -e "${WHITE}PIPESTATUS is an array with the exit code of each command:${RESET}"
    echo ""
    
    print_command 'ls /nonexistent 2>/dev/null | wc -l'
    ls /nonexistent 2>/dev/null | wc -l
    echo ""
    
    # Re-run to get PIPESTATUS
    ls /nonexistent 2>/dev/null | wc -l
    echo -e "${CYAN}PIPESTATUS: (${PIPESTATUS[0]} ${PIPESTATUS[1]})${RESET}"
    print_explanation "First command (ls) failed (code 2), second (wc) succeeded (code 0)"
    
    wait_for_user
    
    print_subheader "set -o pipefail"
    
    echo -e "${WHITE}With pipefail, the pipeline returns the first error:${RESET}"
    echo ""
    
    print_command "set -o pipefail"
    print_command "ls /nonexistent 2>/dev/null | wc -l"
    print_command 'echo "Exit code: $?"'
    
    (
        set -o pipefail
        ls /nonexistent 2>/dev/null | wc -l
        echo "Exit code: $?"
    ) || true
    
    print_explanation "Now the exit code is non-zero because ls failed"
    
    wait_for_user
}

#
# DEMO 4: TEE COMMAND
#

demo_tee() {
    print_header "🔀 DEMO: THE TEE COMMAND - STREAM DUPLICATION"
    
    echo -e "${WHITE}tee = T-shaped junction${RESET}"
    echo ""
    
    cat << 'DIAGRAM'
                     ┌──────────────▶ file
    stdin ──▶ tee ──┤
                     └──────────────▶ stdout
DIAGRAM
    
    echo ""
    print_explanation "tee writes to file AND passes through to stdout"
    
    wait_for_user
    
    print_subheader "Basic usage"
    
    print_command "echo 'Hello World' | tee greeting.txt"
    echo "Hello World" | tee greeting.txt
    echo ""
    echo -e "${DIM}File content:${RESET}"
    cat greeting.txt
    
    wait_for_user
    
    print_subheader "Use Case: save intermediate results"
    
    print_command "ps aux | tee all_processes.txt | grep bash | wc -l"
    
    count=$(ps aux | tee all_processes.txt | grep bash | wc -l)
    echo -e "${CYAN}Bash processes: $count${RESET}"
    echo -e "${DIM}all_processes.txt contains $(wc -l < all_processes.txt) lines${RESET}"
    
    rm -f all_processes.txt greeting.txt
    
    wait_for_user
}

#
# DEMO 5: LOG ANALYSIS
#

demo_log_analysis() {
    print_header "📊 DEMO: PRACTICAL LOG ANALYSIS"
    
    # Create simulated log file
    local tmplog=$(mktemp)
    cat > "$tmplog" << 'EOF'
192.168.1.100 - - [15/Jan/2025:10:00:01] "GET /index.html HTTP/1.1" 200 1234
192.168.1.101 - - [15/Jan/2025:10:00:02] "POST /api/login HTTP/1.1" 401 89
192.168.1.100 - - [15/Jan/2025:10:00:03] "GET /api/users HTTP/1.1" 200 5678
192.168.1.102 - - [15/Jan/2025:10:00:04] "DELETE /api/user/5 HTTP/1.1" 403 123
192.168.1.100 - - [15/Jan/2025:10:00:05] "GET /images/logo.png HTTP/1.1" 200 45678
192.168.1.102 - - [15/Jan/2025:10:00:06] "GET /index.html HTTP/1.1" 200 1234
10.0.0.50 - - [15/Jan/2025:10:00:07] "GET /dashboard HTTP/1.1" 403 123
192.168.1.100 - - [15/Jan/2025:10:00:08] "GET /api/users HTTP/1.1" 200 5678
192.168.1.101 - - [15/Jan/2025:10:00:09] "GET /index.html HTTP/1.1" 200 1234
192.168.1.103 - - [15/Jan/2025:10:00:10] "GET /index.html HTTP/1.1" 404 234
EOF
    
    echo -e "${WHITE}Analysing an Apache log file:${RESET}"
    echo ""
    run_with_highlight "head -3 $tmplog" "Log structure"
    
    wait_for_user
    
    print_subheader "Analysis 1: Top IPs by request count"
    
    echo -e "${YELLOW}Building incrementally:${RESET}"
    
    print_step "1" "Extract the IPs (first column)"
    run_with_highlight "cat $tmplog | awk '{print \$1}'" ""
    
    wait_for_user
    
    print_step "2" "Sort + uniq -c + sort -rn"
    run_with_highlight "cat $tmplog | awk '{print \$1}' | sort | uniq -c | sort -rn" \
        "Top IPs"
    
    wait_for_user
    
    print_subheader "Analysis 2: Only errors (status 4xx and 5xx)"
    
    run_with_highlight "cat $tmplog | awk '\$9 >= 400 {print \$1, \$9, \$7}'" \
        "IPs with errors, status code and URL"
    
    wait_for_user
    
    print_subheader "Analysis 3: Status code statistics"
    
    run_with_highlight "cat $tmplog | awk '{print \$9}' | sort | uniq -c | sort -rn" \
        "Status code distribution"
    
    wait_for_user
    
    print_subheader "Complete pipeline: Security report"
    
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "${WHITE}cat log | grep 'POST\\|DELETE' | awk '{print \$1}' | sort | uniq -c | sort -rn${RESET}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    
    cat "$tmplog" | grep -E 'POST|DELETE' | awk '{print $1}' | sort | uniq -c | sort -rn
    
    # Cleanup
    rm -f "$tmplog"
}

#
# DEMO 6: SPECTACULAR PIPELINE (if tools available)
#

demo_spectacular() {
    print_header "🎭 DEMO: SPECTACULAR PIPELINE"
    
    if [[ "$HAS_FIGLET" == "true" ]]; then
        echo "PIPE" | figlet -c
        
        if [[ "$HAS_LOLCAT" == "true" ]]; then
            echo "POWER!" | figlet | lolcat
        else
            echo "POWER!" | figlet
        fi
    else
        echo ""
        echo -e "${CYAN}╔════════════════════════════════════╗${RESET}"
        echo -e "${CYAN}║${RESET}     ${BOLD}${WHITE}P I P E   P O W E R !${RESET}       ${CYAN}║${RESET}"
        echo -e "${CYAN}╚════════════════════════════════════╝${RESET}"
    fi
    
    wait_for_user
    
    print_subheader "System statistics generation pipeline"
    
    echo -e "${YELLOW}One-liner for system report:${RESET}\n"
    
    {
        echo "═══════════════════════════════════════════════════════"
        echo " SYSTEM REPORT - $(date '+%Y-%m-%d %H:%M:%S')"
        echo "═══════════════════════════════════════════════════════"
        echo ""
        echo "📊 Processes per user:"
        ps aux | awk '{print $1}' | sort | uniq -c | sort -rn | head -3 | \
            awk '{printf "   %-15s %d processes\n", $2, $1}'
        echo ""
        echo "💾 Disk usage:"
        df -h / | tail -1 | awk '{printf "   Root: %s used of %s (%s)\n", $3, $2, $5}'
        echo ""
        echo "🔄 Load average:"
        cat /proc/loadavg | awk '{printf "   1min: %s | 5min: %s | 15min: %s\n", $1, $2, $3}'
        echo ""
        echo "═══════════════════════════════════════════════════════"
    } | if [[ "$HAS_LOLCAT" == "true" ]]; then lolcat; else cat; fi
}

#
# DEMO 7: COMMON MISTAKES
#

demo_mistakes() {
    print_header "⚠️  DEMO: COMMON PIPELINE MISTAKES"
    
    print_subheader "Mistake #1: Useless use of cat (UUOC)"
    
    echo -e "${RED}❌ Wrong:${RESET}"
    print_command "cat file.txt | grep pattern"
    echo ""
    
    echo -e "${GREEN}✓ Correct:${RESET}"
    print_command "grep pattern file.txt"
    echo ""
    echo -e "${DIM}   'Useless Use of Cat' - grep can read directly from file${RESET}"
    
    wait_for_user
    
    print_subheader "Mistake #2: uniq without sort"
    
    echo -e "${RED}❌ Wrong - duplicates not removed:${RESET}"
    echo -e "a\nb\na\nb" | uniq
    echo ""
    
    echo -e "${GREEN}✓ Correct - with sort before:${RESET}"
    echo -e "a\nb\na\nb" | sort | uniq
    echo ""
    echo -e "${DIM}   uniq only removes CONSECUTIVE duplicates!${RESET}"
    
    wait_for_user
    
    print_subheader "Mistake #3: Variable loss in subshell"
    
    echo -e "${RED}❌ Variable is lost:${RESET}"
    count=0
    echo -e "a\nb\nc" | while read line; do
        ((count++))
    done
    echo "   count = $count (expected 3!)"
    echo ""
    
    echo -e "${GREEN}✓ Solution: process substitution${RESET}"
    count=0
    while read line; do
        ((count++))
    done < <(echo -e "a\nb\nc")
    echo "   count = $count (correct!)"
    echo ""
    echo -e "${DIM}   while in a pipe runs in a subshell!${RESET}"
}

#
# MAIN MENU
#

show_menu() {
    echo ""
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════╗${RESET}"
    echo -e "${CYAN}║${RESET}  ${BOLD}${WHITE}🔄 PIPELINE DEMO - MAIN MENU${RESET}                             ${CYAN}║${RESET}"
    echo -e "${CYAN}╠═══════════════════════════════════════════════════════════════╣${RESET}"
    echo -e "${CYAN}║${RESET}  ${GREEN}1)${RESET} Introduction to pipelines                               ${CYAN}║${RESET}"
    echo -e "${CYAN}║${RESET}  ${GREEN}2)${RESET} Incremental building                                    ${CYAN}║${RESET}"
    echo -e "${CYAN}║${RESET}  ${GREEN}3)${RESET} Exit codes and PIPESTATUS                               ${CYAN}║${RESET}"
    echo -e "${CYAN}║${RESET}  ${GREEN}4)${RESET} The tee command - stream duplication                    ${CYAN}║${RESET}"
    echo -e "${CYAN}║${RESET}  ${GREEN}5)${RESET} Advanced log analysis                                   ${CYAN}║${RESET}"
    echo -e "${CYAN}║${RESET}  ${GREEN}6)${RESET} Spectacular pipeline                                    ${CYAN}║${RESET}"
    echo -e "${CYAN}║${RESET}  ${GREEN}7)${RESET} Common mistakes                                         ${CYAN}║${RESET}"
    echo -e "${CYAN}║${RESET}  ${GREEN}A)${RESET} Run ALL demos                                           ${CYAN}║${RESET}"
    echo -e "${CYAN}║${RESET}  ${RED}Q)${RESET} Exit                                                    ${CYAN}║${RESET}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════╝${RESET}"
    echo ""
}

run_all_demos() {
    demo_intro
    demo_incremental
    demo_pipestatus
    demo_tee
    demo_log_analysis
    demo_spectacular
    demo_mistakes
    
    print_header "🎉 ALL DEMOS COMPLETE!"
    echo -e "${GREEN}Now you know how to:${RESET}"
    echo "  ${CHECKMARK} Build pipelines incrementally"
    echo "  ${CHECKMARK} Use tee for debugging"
    echo "  ${CHECKMARK} Manage exit codes with PIPESTATUS"
    echo "  ${CHECKMARK} Analyse complex log files"
    echo "  ${CHECKMARK} Avoid common mistakes"
}

main() {
    check_dependencies
    
    # If argument provided, run that demo directly
    case "${1:-}" in
        1) demo_intro ;;
        2) demo_incremental ;;
        3) demo_pipestatus ;;
        4) demo_tee ;;
        5) demo_log_analysis ;;
        6) demo_spectacular ;;
        7) demo_mistakes ;;
        all|a|A) run_all_demos ;;
        -h|--help)
            echo "Usage: $0 [1-7|all]"
            echo "  No argument: interactive menu"
            echo "  1-7: run specific demo"
            echo "  all: run all demos"
            exit 0
            ;;
        "")
            # Interactive menu
            while true; do
                clear
                show_menu
                echo -n "Select option: "
                read -r choice
                
                case "$choice" in
                    1) demo_intro ;;
                    2) demo_incremental ;;
                    3) demo_pipestatus ;;
                    4) demo_tee ;;
                    5) demo_log_analysis ;;
                    6) demo_spectacular ;;
                    7) demo_mistakes ;;
                    [aA]) run_all_demos ;;
                    [qQ]) 
                        echo -e "\n${GREEN}Goodbye!${RESET}\n"
                        exit 0 
                        ;;
                    *)
                        echo -e "${RED}Invalid option!${RESET}"
                        sleep 1
                        ;;
                esac
                
                wait_for_user
            done
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use -h for help"
            exit 1
            ;;
    esac
}

# Start script
main "$@"
