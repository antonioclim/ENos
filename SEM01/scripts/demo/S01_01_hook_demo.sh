#!/bin/bash
#
# HOOK DEMO - Seminar 1: Shell Bash
# Operating Systems | ASE Bucharest - CSIE
# 
# Purpose: Capture attention at seminar start with visual effects
# Duration: ~3 minutes
# Dependencies: figlet, lolcat, cmatrix, cowsay (optional)
#

set -euo pipefail

# ANSI Colours
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Function for dramatic pause
dramatic_pause() {
    sleep "${1:-1}"
}

# Function for centred text
center_text() {
    local text="$1"
    local width=$(tput cols)
    local padding=$(( (width - ${#text}) / 2 ))
    printf "%*s%s\n" $padding "" "$text"
}

# Function for ASCII banner (fallback if figlet missing)
ascii_banner() {
    echo ""
    echo -e "${CYAN}"
    echo "    ____    _    ____  _   _ "
    echo "   | __ )  / \\  / ___|| | | |"
    echo "   |  _ \\ / _ \\ \\___ \\| |_| |"
    echo "   | |_) / ___ \\ ___) |  _  |"
    echo "   |____/_/   \\_\\____/|_| |_|"
    echo ""
    echo -e "${NC}"
}

# Function for Matrix effect (fallback)
matrix_effect() {
    local duration=${1:-3}
    local chars="ｱｲｳｴｵｶｷｸｹｺｻｼｽｾｿﾀﾁﾂﾃﾄﾅﾆﾇﾈﾉﾊﾋﾌﾍﾎﾏﾐﾑﾒﾓﾔﾕﾖﾗﾘﾙﾚﾛﾜﾝ0123456789"
    local width=$(tput cols)
    local end_time=$((SECONDS + duration))
    
    echo -e "${GREEN}"
    while [ $SECONDS -lt $end_time ]; do
        for ((i=0; i<width; i++)); do
            if [ $((RANDOM % 3)) -eq 0 ]; then
                printf "%s" "${chars:RANDOM%${#chars}:1}"
            else
                printf " "
            fi
        done
        echo ""
        sleep 0.05
    done
    echo -e "${NC}"
}

# Function for cowsay fallback
tux_says() {
    local message="$1"
    echo ""
    echo -e "${YELLOW}"
    echo "  $message"
    echo "         \\"
    echo "          \\"
    echo "           .--."
    echo "          |o_o |"
    echo "          |:_/ |"
    echo "         //   \\ \\"
    echo "        (|     | )"
    echo "       /'\\_   _/\`\\"
    echo "       \\___)=(___/"
    echo -e "${NC}"
}

# Function for heartbeat one-liner
heartbeat_demo() {
    echo -e "\n${CYAN}═══ HEARTBEAT SYSTEM MONITOR ═══${NC}\n"
    for i in {1..5}; do
        local load=$(cat /proc/loadavg 2>/dev/null | cut -d' ' -f1 || echo "N/A")
        local mem=$(free -m 2>/dev/null | awk '/Mem:/ {printf "%.1f%%", $3/$2*100}' || echo "N/A")
        local disk=$(df -h / 2>/dev/null | awk 'NR==2 {print $5}' || echo "N/A")
        
        printf "\r${GREEN}♥${NC} [%s] Load: ${YELLOW}%s${NC} | Mem: ${CYAN}%s${NC} | Disk: ${MAGENTA}%s${NC}  " \
               "$(date +%H:%M:%S)" "$load" "$mem" "$disk"
        sleep 1
    done
    echo ""
}

#
# MAIN DEMO SEQUENCE
#

clear

echo -e "\n${WHITE}${BOLD}>>> Welcome to Operating Systems! <<<${NC}\n"
dramatic_pause 1

# Main banner
echo -e "${BOLD}Before any theory, lets see what the shell can do...${NC}\n"
dramatic_pause 1

# Try figlet + lolcat, fallback to ASCII
if command -v figlet &>/dev/null && command -v lolcat &>/dev/null; then
    figlet -f slant "BASH" | lolcat
elif command -v figlet &>/dev/null; then
    figlet -f slant "BASH"
else
    ascii_banner
fi

dramatic_pause 2

# Matrix effect
echo -e "\n${BOLD}This is the terminal. Its not just for hackers in films...${NC}\n"
dramatic_pause 1

if command -v cmatrix &>/dev/null; then
    echo -e "${YELLOW}[Press Ctrl+C to stop]${NC}"
    timeout 3 cmatrix -b -C green 2>/dev/null || true
else
    echo -e "${YELLOW}[Matrix effect simulation]${NC}"
    matrix_effect 2
fi

dramatic_pause 1

# Cowsay
echo -e "\n${BOLD}And yes, we can do this too...${NC}\n"

if command -v cowsay &>/dev/null && command -v lolcat &>/dev/null; then
    cowsay -f tux "Welcome to OS!" | lolcat
elif command -v cowsay &>/dev/null; then
    cowsay -f tux "Welcome to OS!"
else
    tux_says "Welcome to OS!"
fi

dramatic_pause 2

# Quick system info
echo -e "\n${CYAN}═══ CURRENT SYSTEM ═══${NC}"
echo -e "  ${YELLOW}OS:${NC}     $(uname -s) $(uname -r)"
echo -e "  ${YELLOW}User:${NC}   $USER"
echo -e "  ${YELLOW}Shell:${NC}  $SHELL"
echo -e "  ${YELLOW}Home:${NC}   $HOME"
echo -e "  ${YELLOW}PWD:${NC}    $PWD"

dramatic_pause 2

# Heartbeat demo
heartbeat_demo

# Closing
echo -e "\n${WHITE}${BOLD}"
center_text "╔════════════════════════════════════════════════════════════╗"
center_text "║   In the next 2 hours, you will learn to control          ║"
center_text "║   this powerful environment. Lets begin!                        ║"
center_text "╚════════════════════════════════════════════════════════════╝"
echo -e "${NC}\n"

# Check available tools
echo -e "${CYAN}[INFO] Available tools for demo:${NC}"
for tool in figlet lolcat cmatrix cowsay tree ncdu pv dialog; do
    if command -v $tool &>/dev/null; then
        echo -e "  ${GREEN}✓${NC} $tool"
    else
        echo -e "  ${RED}✗${NC} $tool (optional)"
    fi
done
echo ""
