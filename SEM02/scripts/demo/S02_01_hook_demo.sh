#!/bin/bash
#
# S02_01_hook_demo.sh - Spectacular Opening Hook for Seminar 3-4
#
# 
# DESCRIPTION:
#   Spectacular visual demonstration showing the power of pipelines
#   and command chaining in Bash. Used to capture student attention
#   at the start of the seminar.
#
# DEPENDENCIES (optional):
#   - figlet: for large ASCII text
#   - lolcat: for rainbow colours
#   - pv: for progress bar
#   If missing, the script uses simple text fallbacks.
#
# USAGE:
#   chmod +x S02_01_hook_demo.sh
#   ./S02_01_hook_demo.sh
#
# DURATION: ~2-3 minutes
#
# AUTHOR: OS Course Materials ASE-CSIE
# VERSION: 1.0
#

#
# CONFIGURATION
#

# Simple mode (without visual effects) - set SIMPLE_MODE=1 to disable
SIMPLE_MODE=${SIMPLE_MODE:-0}

# ANSI colours
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[1;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Colour
BOLD='\033[1m'

#
# HELPER FUNCTIONS
#

# Check if a command exists
cmd_exists() {
    command -v "$1" &>/dev/null
}

# Print with colour
cprint() {
    local color=$1
    shift
    echo -e "${color}$*${NC}"
}

# Dramatic pause
pause() {
    sleep "${1:-1}"
}

# Banner with figlet or fallback
banner() {
    local text="$1"
    if [[ $SIMPLE_MODE -eq 0 ]] && cmd_exists figlet; then
        if cmd_exists lolcat; then
            figlet -c "$text" | lolcat
        else
            figlet -c "$text"
        fi
    else
        echo ""
        cprint "$CYAN" "════════════════════════════════════════"
        cprint "$WHITE" "         $text"
        cprint "$CYAN" "════════════════════════════════════════"
        echo ""
    fi
}

# Typing effect for demo
type_cmd() {
    local cmd="$1"
    cprint "$GREEN" "$ $cmd"
    pause 0.5
}

#
# PART 1: INTRO
#

intro() {
    clear
    
    banner "BASH PIPES"
    
    pause 1
    
    cprint "$YELLOW" "╔══════════════════════════════════════════════════════════════════╗"
    cprint "$YELLOW" "║  🐧 Seminar 2: Operators, Redirection, Filters, Loops          ║"
    cprint "$YELLOW" "║                                                                  ║"
    cprint "$YELLOW" "║  Today we shall learn to chain commands like a professional!    ║"
    cprint "$YELLOW" "╚══════════════════════════════════════════════════════════════════╝"
    
    pause 2
}

#
# PART 2: PIPELINE POWER DEMO
#

demo_pipeline_power() {
    clear
    
    cprint "$CYAN" ""
    cprint "$CYAN" ">>> DEMO 1: THE POWER OF PIPELINES <<<"
    cprint "$CYAN" ""
    
    pause 1
    
    cprint "$WHITE" "Challenge: Find the 5 largest files in /usr"
    cprint "$WHITE" "           ...in a single command line!"
    
    pause 2
    
    cprint "$YELLOW" ""
    cprint "$YELLOW" "The magic pipeline:"
    cprint "$GREEN" '$ find /usr -type f -printf "%s %p\n" 2>/dev/null | sort -rn | head -5'
    
    pause 2
    
    cprint "$CYAN" ""
    cprint "$CYAN" "Result:"
    cprint "$CYAN" "─────────────────────────────────────────────────────────────────"
    
    # Execute the actual pipeline
    find /usr -type f -printf '%s %p\n' 2>/dev/null | \
        sort -rn | \
        head -5 | \
        while read size path; do
            # Pretty formatting with large numbers
            if [ "$size" -gt 1073741824 ]; then
                human=$(echo "scale=2; $size/1073741824" | bc)
                unit="GB"
            elif [ "$size" -gt 1048576 ]; then
                human=$(echo "scale=2; $size/1048576" | bc)
                unit="MB"
            elif [ "$size" -gt 1024 ]; then
                human=$(echo "scale=2; $size/1024" | bc)
                unit="KB"
            else
                human=$size
                unit="B"
            fi
            printf "${GREEN}%10s ${WHITE}%s${NC} → %s\n" "${human}${unit}" " " "$path"
            sleep 0.3
        done
    
    cprint "$CYAN" "─────────────────────────────────────────────────────────────────"
    
    pause 1
    
    cprint "$MAGENTA" ""
    cprint "$MAGENTA" "✓ 4 commands combined:"
    cprint "$WHITE" "  find    → searches files and displays size"
    cprint "$WHITE" "  sort    → sorts numerically in descending order"
    cprint "$WHITE" "  head    → takes only the first 5"
    cprint "$WHITE" "  while   → formats the output"
    
    pause 3
}

#
# PART 3: CONDITIONAL OPERATORS DEMO
#

demo_conditional() {
    clear
    
    cprint "$CYAN" ""
    cprint "$CYAN" ">>> DEMO 2: CONDITIONAL OPERATORS <<<"
    cprint "$CYAN" ""
    
    pause 1
    
    cprint "$WHITE" "Scenario: We want to create a directory and enter it"
    cprint "$WHITE" "          ...but ONLY if the creation succeeds!"
    
    pause 2
    
    # Cleanup
    rm -rf /tmp/demo_test_dir 2>/dev/null
    
    cprint "$YELLOW" ""
    cprint "$YELLOW" "The WRONG method (with ;):"
    type_cmd 'mkdir /root/no_permissions ; cd /root/no_permissions ; echo "I am in the directory!"'
    
    cprint "$RED" ""
    mkdir /root/no_permissions 2>&1 | head -1
    # cd will fail but echo executes anyway
    cprint "$GREEN" 'I am in the directory!'
    cprint "$RED" "↑ WRONG! Echo executed even though mkdir failed!"
    
    pause 3
    
    cprint "$YELLOW" ""
    cprint "$YELLOW" "The CORRECT method (with &&):"
    type_cmd 'mkdir /tmp/demo_test && cd /tmp/demo_test && echo "I am in the directory!"'
    
    cprint "$GREEN" ""
    if mkdir /tmp/demo_test_dir 2>/dev/null && cd /tmp/demo_test_dir; then
        pwd
        cprint "$GREEN" "✓ Works perfectly!"
    fi
    
    pause 2
    
    cprint "$YELLOW" ""
    cprint "$YELLOW" "With fallback (&&...||):"
    type_cmd 'mkdir /root/test && echo "Created!" || echo "Creation error!"'
    
    cprint "$GREEN" ""
    mkdir /root/test 2>/dev/null && echo "Created!" || cprint "$RED" "Creation error!"
    
    pause 3
    
    # Cleanup
    cd ~
    rm -rf /tmp/demo_test_dir 2>/dev/null
}

#
# PART 4: FILTERS DEMO
#

demo_filters() {
    clear
    
    cprint "$CYAN" ""
    cprint "$CYAN" ">>> DEMO 3: TEXT FILTERS <<<"
    cprint "$CYAN" ""
    
    pause 1
    
    cprint "$WHITE" "Challenge: Analyse processes and find top 5 users"
    cprint "$WHITE" "          by number of running processes."
    
    pause 2
    
    cprint "$YELLOW" ""
    cprint "$YELLOW" "The pipeline:"
    cprint "$GREEN" '$ ps aux | awk "{print \$1}" | sort | uniq -c | sort -rn | head -6'
    
    pause 2
    
    cprint "$CYAN" ""
    cprint "$CYAN" "Building step by step:"
    cprint "$CYAN" "─────────────────────────────────────────────────────────────────"
    
    cprint "$WHITE" "1. ps aux (list all processes):"
    ps aux | head -3
    cprint "$YELLOW" "   ... (many lines)"
    pause 1
    
    cprint "$WHITE" ""
    cprint "$WHITE" "2. awk '{print \$1}' (extract only username):"
    ps aux | awk '{print $1}' | head -5
    pause 1
    
    cprint "$WHITE" ""
    cprint "$WHITE" "3. sort (sort for uniq):"
    cprint "$YELLOW" "   (necessary because uniq only removes CONSECUTIVE duplicates!)"
    pause 1
    
    cprint "$WHITE" ""
    cprint "$WHITE" "4. uniq -c (count occurrences):"
    ps aux | awk '{print $1}' | sort | uniq -c | head -5
    pause 1
    
    cprint "$WHITE" ""
    cprint "$WHITE" "5. sort -rn | head -6 (descending sort, top 6):"
    cprint "$CYAN" "─────────────────────────────────────────────────────────────────"
    ps aux | awk '{print $1}' | sort | uniq -c | sort -rn | head -6
    cprint "$CYAN" "─────────────────────────────────────────────────────────────────"
    
    pause 3
}

#
# PART 5: COUNTDOWN (if we have figlet)
#

demo_countdown() {
    if [[ $SIMPLE_MODE -eq 0 ]] && cmd_exists figlet; then
        clear
        
        cprint "$CYAN" ""
        cprint "$CYAN" ">>> DEMO 4: LOOPS IN ACTION <<<"
        cprint "$CYAN" ""
        
        pause 1
        
        cprint "$WHITE" "Simple code, impressive effect:"
        cprint "$GREEN" 'for i in {5..1}; do clear; figlet $i; sleep 1; done; figlet "GO!"'
        
        pause 2
        
        for i in {5..1}; do
            clear
            if cmd_exists lolcat; then
                figlet -c "$i" | lolcat
            else
                cprint "$CYAN" ""
                figlet -c "$i"
            fi
            sleep 0.7
        done
        
        clear
        if cmd_exists lolcat; then
            figlet -c "GO!" | lolcat
        else
            cprint "$GREEN" ""
            figlet -c "GO!"
        fi
        
        pause 2
    fi
}

#
# PART 6: FINALE
#

finale() {
    clear
    
    banner "READY?"
    
    cprint "$YELLOW" ""
    cprint "$YELLOW" "╔══════════════════════════════════════════════════════════════════╗"
    cprint "$YELLOW" "║                                                                  ║"
    cprint "$YELLOW" "║   Today we shall learn:                                         ║"
    cprint "$YELLOW" "║                                                                  ║"
    cprint "$WHITE"  "║   ✓ Control operators:      ;  &&  ||  &  |                     ║"
    cprint "$WHITE"  "║   ✓ I/O redirection:        >  >>  <  <<  2>&1                  ║"
    cprint "$WHITE"  "║   ✓ Text filters:           sort uniq cut tr wc head tail       ║"
    cprint "$WHITE"  "║   ✓ Loops:                  for while until break continue      ║"
    cprint "$YELLOW" "║                                                                  ║"
    cprint "$YELLOW" "╚══════════════════════════════════════════════════════════════════╝"
    cprint "$YELLOW" ""
    
    pause 2
    
    cprint "$GREEN" ""
    cprint "$GREEN" "Let us begin! 🚀"
    cprint "$GREEN" ""
}

#
# MAIN
#

main() {
    # Check dependencies and warn if missing
    echo "Checking dependencies..."
    for cmd in figlet lolcat pv; do
        if cmd_exists "$cmd"; then
            echo "  ✓ $cmd found"
        else
            echo "  ✗ $cmd missing (optional - fallback will be used)"
        fi
    done
    sleep 1
    
    # Run the demos
    intro
    demo_pipeline_power
    demo_conditional
    demo_filters
    demo_countdown
    finale
}

# Run only if not sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
