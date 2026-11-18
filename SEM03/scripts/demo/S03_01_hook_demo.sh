#!/bin/bash
#
#  HOOK DEMO: File System Explorer & Power of Find
#
# Operating Systems | Bucharest UES - CSIE
# Seminar 3: Spectacular demonstration to capture attention
#
# PURPOSE: Show the power of find command and Unix utilities in a visual
#          and engaging way to "hook" students from the beginning
#
# USAGE:
#   ./S03_01_hook_demo.sh           # Full demo
#   ./S03_01_hook_demo.sh -q        # Quick demo (30 seconds)
#   ./S03_01_hook_demo.sh -s        # Silent (no pauses)
#   ./S03_01_hook_demo.sh -d DIR    # Analyse specific directory
#
# REQUIREMENTS: find, du, wc, bc, file (standard on Ubuntu)
#

set -euo pipefail

# ═══════════════════════════════════════════════════════════════════════════════
# CONFIGURATION AND COLOURS
# ═══════════════════════════════════════════════════════════════════════════════

# ANSI colours
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly MAGENTA='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly WHITE='\033[1;37m'
readonly BOLD='\033[1m'
readonly DIM='\033[2m'
readonly NC='\033[0m'

# Emoji for visualisation
readonly EMOJI_FOLDER="📁"
readonly EMOJI_FILE="📄"
readonly EMOJI_CODE="💻"
readonly EMOJI_IMAGE="🖼️"
readonly EMOJI_MUSIC="🎵"
readonly EMOJI_VIDEO="🎬"
readonly EMOJI_ARCHIVE="📦"
readonly EMOJI_SEARCH="🔍"
readonly EMOJI_ROCKET="🚀"
readonly EMOJI_CHECK="✅"
readonly EMOJI_WARN="⚠️"
readonly EMOJI_LOCK="🔒"
readonly EMOJI_TIME="⏱️"
readonly EMOJI_STATS="📊"

# Configuration
DEMO_DIR="/usr"
QUICK_MODE=false
SILENT_MODE=false
PAUSE_TIME=2

# ═══════════════════════════════════════════════════════════════════════════════
# UTILITY FUNCTIONS
# ═══════════════════════════════════════════════════════════════════════════════

print_banner() {
    clear
    echo -e "${CYAN}"
    cat << 'EOF'
    ╔═══════════════════════════════════════════════════════════════════════╗
    ║                                                                       ║
    ║   🔍 FILE SYSTEM EXPLORER - The Power of find                        ║
    ║                                                                       ║
    ║   Operating Systems | Bucharest UES - CSIE                           ║
    ║                                                                       ║
    ╚═══════════════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

print_section() {
    local title="$1"
    local emoji="${2:-📌}"
    
    echo ""
    echo -e "${YELLOW}╔══════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}║ ${emoji} ${BOLD}${title}${NC}${YELLOW}$(printf '%*s' $((58 - ${#title})) '')║${NC}"
    echo -e "${YELLOW}╚══════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

pause_for_effect() {
    if [[ "$SILENT_MODE" == "false" ]]; then
        sleep "$PAUSE_TIME"
    fi
}

typing_effect() {
    local text="$1"
    local delay="${2:-0.03}"
    
    if [[ "$SILENT_MODE" == "true" ]]; then
        echo -e "$text"
        return
    fi
    
    for (( i=0; i<${#text}; i++ )); do
        echo -n "${text:$i:1}"
        sleep "$delay"
    done
    echo ""
}

show_command() {
    local cmd="$1"
    echo -e "${DIM}┌─────────────────────────────────────────────────────────────────┐${NC}"
    echo -e "${GREEN}│ \$ ${WHITE}${cmd}${NC}"
    echo -e "${DIM}└─────────────────────────────────────────────────────────────────┘${NC}"
    pause_for_effect
}

format_size() {
    local bytes=$1
    if (( bytes >= 1073741824 )); then
        echo "$(echo "scale=2; $bytes/1073741824" | bc) GB"
    elif (( bytes >= 1048576 )); then
        echo "$(echo "scale=2; $bytes/1048576" | bc) MB"
    elif (( bytes >= 1024 )); then
        echo "$(echo "scale=2; $bytes/1024" | bc) KB"
    else
        echo "$bytes B"
    fi
}

progress_bar() {
    local current=$1
    local total=$2
    local width=50
    local percent=$((current * 100 / total))
    local filled=$((current * width / total))
    local empty=$((width - filled))
    
    printf "\r${CYAN}["
    printf "%${filled}s" '' | tr ' ' '█'
    printf "%${empty}s" '' | tr ' ' '░'
    printf "] ${percent}%%${NC}"
}

# ═══════════════════════════════════════════════════════════════════════════════
# DEMO 1: SPECTACULAR SEARCH
# ═══════════════════════════════════════════════════════════════════════════════

demo_spectacular_search() {
    print_section "SPECTACULAR SEARCH" "🔍"
    
    typing_effect "${WHITE}Imagine you need to find the 10 largest files in the system...${NC}"
    echo ""
    typing_effect "${DIM}With ls? Impossible. With GUI? Minutes of clicking.${NC}"
    typing_effect "${BOLD}${GREEN}With find? A SINGLE command!${NC}"
    echo ""
    
    show_command "find /usr -type f -printf '%s %p\\n' 2>/dev/null | sort -rn | head -10"
    
    echo -e "${MAGENTA}${EMOJI_ROCKET} Executing...${NC}"
    echo ""
    
    # Execute and format nicely
    echo -e "${WHITE}┌────────────────────────────────────────────────────────────────────┐${NC}"
    echo -e "${WHITE}│  ${BOLD}RANK    SIZE                FILE${NC}                                  ${WHITE}│${NC}"
    echo -e "${WHITE}├────────────────────────────────────────────────────────────────────┤${NC}"
    
    local rank=1
    while read -r size path; do
        local formatted_size=$(format_size "$size")
        printf "${WHITE}│  ${CYAN}#%-3d${NC}   ${YELLOW}%12s${NC}    ${GREEN}%-40s${NC} ${WHITE}│${NC}\n" \
            "$rank" "$formatted_size" "${path:0:40}"
        rank=$((rank + 1))
    done < <(find /usr -type f -printf '%s %p\n' 2>/dev/null | sort -rn | head -10)
    
    echo -e "${WHITE}└────────────────────────────────────────────────────────────────────┘${NC}"
    echo ""
    
    typing_effect "${GREEN}${EMOJI_CHECK} All in a single command! That's the power of find!${NC}"
    pause_for_effect
}

# ═══════════════════════════════════════════════════════════════════════════════
# DEMO 2: REAL-TIME SYSTEM STATISTICS
# ═══════════════════════════════════════════════════════════════════════════════

demo_system_stats() {
    print_section "REAL-TIME SYSTEM STATISTICS" "📊"
    
    typing_effect "${WHITE}How many files are in ${DEMO_DIR}? What types? How much space?${NC}"
    echo ""
    
    # Prepare counters
    local total_files=0
    local total_dirs=0
    local total_links=0
    local total_size=0
    
    # Count with animation
    echo -e "${CYAN}${EMOJI_SEARCH} Scanning in progress...${NC}"
    echo ""
    
    # Count files
    show_command "find ${DEMO_DIR} -type f 2>/dev/null | wc -l"
    total_files=$(find "${DEMO_DIR}" -type f 2>/dev/null | wc -l)
    echo -e "${GREEN}   ${EMOJI_FILE} Files: ${BOLD}${total_files}${NC}"
    
    # Count directories
    show_command "find ${DEMO_DIR} -type d 2>/dev/null | wc -l"
    total_dirs=$(find "${DEMO_DIR}" -type d 2>/dev/null | wc -l)
    echo -e "${BLUE}   ${EMOJI_FOLDER} Directories: ${BOLD}${total_dirs}${NC}"
    
    # Count symlinks
    show_command "find ${DEMO_DIR} -type l 2>/dev/null | wc -l"
    total_links=$(find "${DEMO_DIR}" -type l 2>/dev/null | wc -l)
    echo -e "${MAGENTA}   🔗 Symbolic links: ${BOLD}${total_links}${NC}"
    
    # Total size
    show_command "du -sb ${DEMO_DIR} 2>/dev/null"
    total_size=$(du -sb "${DEMO_DIR}" 2>/dev/null | cut -f1 || echo "0")
    echo -e "${YELLOW}   💾 Total size: ${BOLD}$(format_size ${total_size})${NC}"
    
    echo ""
    
    # ASCII graph for distribution
    echo -e "${WHITE}┌─────────────────────────────────────────────────────────────────┐${NC}"
    echo -e "${WHITE}│                    ${BOLD}TYPE DISTRIBUTION${NC}                            ${WHITE}│${NC}"
    echo -e "${WHITE}├─────────────────────────────────────────────────────────────────┤${NC}"
    
    local total=$((total_files + total_dirs + total_links))
    if (( total > 0 )); then
        local file_pct=$((total_files * 50 / total))
        local dir_pct=$((total_dirs * 50 / total))
        local link_pct=$((total_links * 50 / total))
        
        printf "${WHITE}│ ${NC}${EMOJI_FILE} Files      ${GREEN}"
        printf "%${file_pct}s" '' | tr ' ' '█'
        printf "${NC} %d%%\n" $((total_files * 100 / total))
        
        printf "${WHITE}│ ${NC}${EMOJI_FOLDER} Directories ${BLUE}"
        printf "%${dir_pct}s" '' | tr ' ' '█'
        printf "${NC} %d%%\n" $((total_dirs * 100 / total))
        
        printf "${WHITE}│ ${NC}🔗 Links      ${MAGENTA}"
        printf "%${link_pct}s" '' | tr ' ' '█'
        printf "${NC} %d%%\n" $((total_links * 100 / total))
    fi
    
    echo -e "${WHITE}└─────────────────────────────────────────────────────────────────┘${NC}"
    pause_for_effect
}

# ═══════════════════════════════════════════════════════════════════════════════
# DEMO 3: FILE TYPE DETECTION
# ═══════════════════════════════════════════════════════════════════════════════

demo_file_types() {
    print_section "AUTOMATIC FILE TYPE DETECTION" "🎨"
    
    typing_effect "${WHITE}find can locate any file type by extension or content!${NC}"
    echo ""
    
    # Create temporary directory for demo
    local demo_temp="/tmp/hook_demo_$$"
    mkdir -p "$demo_temp"
    
    # Simulate project structure
    mkdir -p "$demo_temp"/{src,docs,images,data}
    touch "$demo_temp"/src/{main.c,utils.c,config.h,Makefile}
    touch "$demo_temp"/docs/{README.md,manual.txt,api.html}
    touch "$demo_temp"/images/{logo.png,banner.jpg,icon.svg}
    touch "$demo_temp"/data/{config.json,users.csv,log.xml}
    
    echo -e "${DIM}We created a demonstrative project structure...${NC}"
    echo ""
    
    # Demonstrate search by extension
    declare -A file_types=(
        ["*.c"]="${EMOJI_CODE} C Code"
        ["*.h"]="${EMOJI_CODE} C Header"
        ["*.md"]="${EMOJI_FILE} Markdown"
        ["*.html"]="🌐 HTML"
        ["*.png"]="${EMOJI_IMAGE} PNG"
        ["*.jpg"]="${EMOJI_IMAGE} JPEG"
        ["*.json"]="📋 JSON"
        ["*.csv"]="📊 CSV"
    )
    
    echo -e "${WHITE}┌────────────────────────────────────────────────────────────────────┐${NC}"
    echo -e "${WHITE}│  ${BOLD}TYPE              FOUND     FIND COMMAND${NC}                          ${WHITE}│${NC}"
    echo -e "${WHITE}├────────────────────────────────────────────────────────────────────┤${NC}"
    
    for pattern in "${!file_types[@]}"; do
        local count=$(find "$demo_temp" -name "$pattern" 2>/dev/null | wc -l)
        local desc="${file_types[$pattern]}"
        printf "${WHITE}│  ${NC}%-17s ${CYAN}%3d${NC}       ${DIM}find . -name \"%-8s\"${NC}   ${WHITE}│${NC}\n" \
            "$desc" "$count" "$pattern"
    done
    
    echo -e "${WHITE}└────────────────────────────────────────────────────────────────────┘${NC}"
    
    # Cleanup
    rm -rf "$demo_temp"
    
    pause_for_effect
}

# ═══════════════════════════════════════════════════════════════════════════════
# DEMO 4: THE POWER OF COMBINING WITH XARGS
# ═══════════════════════════════════════════════════════════════════════════════

demo_find_xargs_power() {
    print_section "find + xargs = SUPERPOWERS!" "⚡"
    
    typing_effect "${WHITE}find locates, xargs processes. Together they're invincible!${NC}"
    echo ""
    
    # Demo 1: Count lines in all C files from /usr/include
    echo -e "${CYAN}${EMOJI_SEARCH} How many lines of C code are in /usr/include?${NC}"
    show_command "find /usr/include -name '*.h' -type f 2>/dev/null | head -100 | xargs wc -l | tail -1"
    
    local line_count=$(find /usr/include -name '*.h' -type f 2>/dev/null | head -100 | xargs wc -l 2>/dev/null | tail -1 | awk '{print $1}')
    echo -e "${GREEN}${EMOJI_CHECK} Total: ${BOLD}${line_count}${NC} ${GREEN}lines (in the first 100 headers)${NC}"
    echo ""
    
    # Demo 2: Find recently modified files
    echo -e "${CYAN}${EMOJI_TIME} Files modified in the last 24 hours in /var/log:${NC}"
    show_command "find /var/log -type f -mtime -1 -name '*.log' 2>/dev/null | head -5"
    
    echo -e "${WHITE}Results:${NC}"
    find /var/log -type f -mtime -1 -name '*.log' 2>/dev/null | head -5 | while read -r f; do
        echo -e "   ${GREEN}→${NC} $f"
    done
    echo ""
    
    # Demo 3: Showcase batch processing
    echo -e "${CYAN}⚡ The difference between \\; and + in -exec:${NC}"
    echo ""
    echo -e "${DIM}With \\; (one execution per file - SLOW):${NC}"
    echo -e "${YELLOW}find . -name '*.txt' -exec echo {} \\;${NC}"
    echo -e "${DIM}    → echo file1.txt${NC}"
    echo -e "${DIM}    → echo file2.txt${NC}"
    echo -e "${DIM}    → echo file3.txt${NC}"
    echo ""
    echo -e "${DIM}With + (batch - FAST):${NC}"
    echo -e "${GREEN}find . -name '*.txt' -exec echo {} +${NC}"
    echo -e "${DIM}    → echo file1.txt file2.txt file3.txt${NC}"
    echo ""
    
    typing_effect "${GREEN}${EMOJI_ROCKET} Batch processing can be 10-100x faster!${NC}"
    pause_for_effect
}

# ═══════════════════════════════════════════════════════════════════════════════
# DEMO 5: RAPID SECURITY SCAN
# ═══════════════════════════════════════════════════════════════════════════════

demo_security_scan() {
    print_section "MINI SECURITY AUDIT" "🛡️"
    
    typing_effect "${WHITE}find can identify security issues in an instant!${NC}"
    echo ""
    
    # Search for SUID files
    echo -e "${CYAN}${EMOJI_LOCK} SUID files in the system (run with root permissions):${NC}"
    show_command "find /usr/bin -perm -4000 -type f 2>/dev/null | head -5"
    
    find /usr/bin -perm -4000 -type f 2>/dev/null | head -5 | while read -r f; do
        local perms=$(ls -l "$f" 2>/dev/null | awk '{print $1}')
        echo -e "   ${YELLOW}${EMOJI_WARN}${NC} $perms ${RED}$f${NC}"
    done
    echo ""
    
    # Search for world-writable files
    echo -e "${CYAN}${EMOJI_WARN} World-writable directories (sticky bit):${NC}"
    show_command "find /tmp /var/tmp -type d -perm -1000 2>/dev/null | head -3"
    
    find /tmp /var/tmp -type d -perm -1000 2>/dev/null 2>/dev/null | head -3 | while read -r d; do
        local perms=$(ls -ld "$d" 2>/dev/null | awk '{print $1}')
        echo -e "   ${GREEN}${EMOJI_CHECK}${NC} $perms ${BLUE}$d${NC} (sticky bit protects)"
    done
    echo ""
    
    typing_effect "${WHITE}These find commands are essential for any system administrator!${NC}"
    pause_for_effect
}

# ═══════════════════════════════════════════════════════════════════════════════
# FINAL DEMO: TEASER FOR SEMINAR
# ═══════════════════════════════════════════════════════════════════════════════

demo_teaser() {
    print_section "WHAT WE'LL LEARN TODAY" "🎯"
    
    echo -e "${WHITE}In this seminar, you will master:${NC}"
    echo ""
    
    local topics=(
        "${EMOJI_SEARCH}|find|Complex searches with multiple criteria"
        "⚡|xargs|Efficient batch processing"
        "${EMOJI_CODE}|Parameters|Professional scripts with arguments"
        "🔧|getopts|Option parsing like a pro"
        "${EMOJI_LOCK}|Permissions|chmod, chown, umask - total control"
        "👥|SUID/SGID|Special permissions for advanced access"
        "${EMOJI_TIME}|cron|Automation - the system works for you"
    )
    
    echo -e "${WHITE}┌────────────────────────────────────────────────────────────────────┐${NC}"
    
    for topic in "${topics[@]}"; do
        IFS='|' read -r emoji name desc <<< "$topic"
        printf "${WHITE}│  ${NC}%s  ${CYAN}%-12s${NC} ${DIM}%-45s${NC} ${WHITE}│${NC}\n" \
            "$emoji" "$name" "$desc"
        sleep 0.3
    done
    
    echo -e "${WHITE}└────────────────────────────────────────────────────────────────────┘${NC}"
    echo ""
    
    echo -e "${GREEN}${BOLD}"
    cat << 'EOF'
    ╔═══════════════════════════════════════════════════════════════════╗
    ║                                                                   ║
    ║   🚀 Get ready to become POWER USERS!                            ║
    ║                                                                   ║
    ║   After this seminar, Unix commands will obey you!               ║
    ║                                                                   ║
    ╚═══════════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

# ═══════════════════════════════════════════════════════════════════════════════
# MAIN - ARGUMENT PARSING AND EXECUTION
# ═══════════════════════════════════════════════════════════════════════════════

usage() {
    cat << EOF
${BOLD}USAGE:${NC}
    $(basename "$0") [OPTIONS] [DIRECTORY]

${BOLD}OPTIONS:${NC}
    -q, --quick     Quick demo (skip pauses)
    -s, --silent    Silent mode (no animations)
    -d, --dir DIR   Analyse specific directory (default: /usr)
    -h, --help      Display this help

${BOLD}EXAMPLES:${NC}
    $(basename "$0")              # Full demo in /usr
    $(basename "$0") -q           # Quick demo
    $(basename "$0") -d /home     # Analyse /home

${BOLD}DESCRIPTION:${NC}
    Demonstrative script to capture students' attention.
    Shows the power of find command and Unix utilities.
EOF
}

main() {
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -q|--quick)
                QUICK_MODE=true
                PAUSE_TIME=0.5
                shift
                ;;
            -s|--silent)
                SILENT_MODE=true
                shift
                ;;
            -d|--dir)
                DEMO_DIR="${2:-/usr}"
                shift 2
                ;;
            -h|--help)
                usage
                exit 0
                ;;
            *)
                if [[ -d "$1" ]]; then
                    DEMO_DIR="$1"
                fi
                shift
                ;;
        esac
    done
    
    # Check that the directory exists
    if [[ ! -d "$DEMO_DIR" ]]; then
        echo -e "${RED}Error: Directory '$DEMO_DIR' does not exist!${NC}" >&2
        exit 1
    fi
    
    # Run the demos
    print_banner
    sleep 1
    
    demo_spectacular_search
    demo_system_stats
    demo_file_types
    demo_find_xargs_power
    
    if [[ "$QUICK_MODE" == "false" ]]; then
        demo_security_scan
    fi
    
    demo_teaser
    
    echo ""
    echo -e "${DIM}Demo generated for Operating Systems | Bucharest UES - CSIE${NC}"
    echo -e "${DIM}Seminar 3: Advanced Utilities, Scripts, Permissions, Automation${NC}"
}

# Run main with all arguments
main "$@"
