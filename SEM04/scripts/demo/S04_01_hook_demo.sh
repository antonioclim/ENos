#!/bin/bash
#===============================================================================
#
#          FILE: S04_01_hook_demo.sh
#
#         USAGE: ./S04_01_hook_demo.sh
#
#   DESCRIPTION: Spectacular demo for the seminar opening hook
#                Analyses an access.log and generates a security report
#                in real time, demonstrating the power of text processing
#
#        AUTHOR: Assistant Lecturer - OS Seminar
#       VERSION: 1.1
#
#===============================================================================

set -euo pipefail

readonly DATA_DIR="$HOME/demo_sem4/data"

# Colours
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly BOLD='\033[1m'
readonly NC='\033[0m'

# Function for typing effect
type_text() {
    local text="$1"
    local delay="${2:-0.03}"
    for ((i=0; i<${#text}; i++)); do
        echo -n "${text:$i:1}"
        sleep "$delay"
    done
    echo ""
}

# Function for dramatic pause
pause() {
    local msg="${1:-Press Enter to continue...}"
    echo ""
    read -rp "$msg"
}

# Verify data exists
if [[ ! -f "$DATA_DIR/access.log" ]]; then
    echo -e "${RED}[ERROR] Run first: ./S04_01_setup_seminar.sh${NC}"
    exit 1
fi

cd "$DATA_DIR"

clear

echo ""
echo -e "${CYAN}╔══════════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║${NC}                                                                          ${CYAN}║${NC}"
echo -e "${CYAN}║${NC}     ${BOLD}🚨 THE SCENARIO: SECURITY INCIDENT 🚨${NC}                              ${CYAN}║${NC}"
echo -e "${CYAN}║${NC}                                                                          ${CYAN}║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════════════════════════════════╝${NC}"
echo ""

type_text "Your boss walks into your office at 9 AM on a Monday morning..." 0.05
sleep 1
echo ""
type_text "  \"The website was attacked last night.\"" 0.05
type_text "  \"I need a report in 5 minutes:\"" 0.05
type_text "    - Who carried out the attack?" 0.05
type_text "    - Where did they come from?" 0.05
type_text "    - What did they try to access?" 0.05
echo ""

pause

echo ""
echo -e "${YELLOW}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}STEP 1: Check the log file size${NC}"
echo -e "${YELLOW}═══════════════════════════════════════════════════════════════${NC}"
echo ""

echo -e "${BLUE}$ wc -l access.log${NC}"
sleep 0.5
wc -l access.log
echo ""
echo -e "${GREEN}→ Over 2000 lines of logs! Manual analysis would take hours...${NC}"

pause

echo ""
echo -e "${YELLOW}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}STEP 2: Top 5 suspicious IPs${NC}"
echo -e "${YELLOW}═══════════════════════════════════════════════════════════════${NC}"
echo ""

echo -e "${BLUE}$ awk '{print \$1}' access.log | sort | uniq -c | sort -rn | head -5${NC}"
sleep 0.5
awk '{print $1}' access.log | sort | uniq -c | sort -rn | head -5
echo ""
echo -e "${GREEN}→ The IPs with the most requests - potential attackers!${NC}"

pause

echo ""
echo -e "${YELLOW}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}STEP 3: What did they try to access?${NC}"
echo -e "${YELLOW}═══════════════════════════════════════════════════════════════${NC}"
echo ""

echo -e "${BLUE}$ grep -E '(admin|config|\.env|wp-)' access.log | awk '{print \$7}' | sort | uniq -c | sort -rn${NC}"
sleep 0.5
grep -E '(admin|config|\.env|wp-)' access.log | awk '{print $7}' | sort | uniq -c | sort -rn | head -10
echo ""
echo -e "${RED}→ Vulnerability scanning! Searching for admin panels and sensitive files!${NC}"

pause

echo ""
echo -e "${YELLOW}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}STEP 4: How many failed requests?${NC}"
echo -e "${YELLOW}═══════════════════════════════════════════════════════════════${NC}"
echo ""

echo -e "${BLUE}$ grep -cE '\" [45][0-9]{2} ' access.log${NC}"
sleep 0.5
grep -cE '" [45][0-9]{2} ' access.log || echo "0"
echo ""
echo -e "${GREEN}→ Number of requests with 4xx and 5xx errors${NC}"

pause

echo ""
echo -e "${YELLOW}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}FINAL REPORT - GENERATED IN 30 SECONDS!${NC}"
echo -e "${YELLOW}═══════════════════════════════════════════════════════════════${NC}"
echo ""

echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║           📊 SECURITY INCIDENT REPORT 📊                     ║${NC}"
echo -e "${CYAN}╠══════════════════════════════════════════════════════════════╣${NC}"
echo -e "${CYAN}║${NC}"

echo -e "${CYAN}║${NC} ${BOLD}🔍 Top 5 Source IPs:${NC}"
awk '{print $1}' access.log | sort | uniq -c | sort -rn | head -5 | while read count ip; do
    printf "${CYAN}║${NC}    %-20s %6d requests\n" "$ip" "$count"
done

echo -e "${CYAN}║${NC}"
echo -e "${CYAN}║${NC} ${BOLD}🚨 Suspicious Requests:${NC}"
susp_count=$(grep -cE '(admin|config|\.env|wp-|phpmyadmin)' access.log || echo "0")
echo -e "${CYAN}║${NC}    Total: ${RED}$susp_count${NC} potential attack attempts"

echo -e "${CYAN}║${NC}"
echo -e "${CYAN}║${NC} ${BOLD}❌ Failed Requests (4xx/5xx):${NC}"
fail_count=$(grep -cE '" [45][0-9]{2} ' access.log || echo "0")
echo -e "${CYAN}║${NC}    Total: ${YELLOW}$fail_count${NC} failed requests"

echo -e "${CYAN}║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"

echo ""
echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║${NC}                                                              ${GREEN}║${NC}"
echo -e "${GREEN}║${NC}  ${BOLD}This is the power of text processing in Linux!${NC}            ${GREEN}║${NC}"
echo -e "${GREEN}║${NC}                                                              ${GREEN}║${NC}"
echo -e "${GREEN}║${NC}  Today you will learn to do exactly this with:              ${GREEN}║${NC}"
echo -e "${GREEN}║${NC}    • grep - pattern searching                               ${GREEN}║${NC}"
echo -e "${GREEN}║${NC}    • sed  - text transformation                             ${GREEN}║${NC}"
echo -e "${GREEN}║${NC}    • awk  - structured data processing                      ${GREEN}║${NC}"
echo -e "${GREEN}║${NC}                                                              ${GREEN}║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""
