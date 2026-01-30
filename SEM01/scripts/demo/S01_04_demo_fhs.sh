#!/bin/bash
#
set -euo pipefail
# DEMO FHS EXPLORER - Interactive filesystem exploration
# Operating Systems | ASE Bucharest - CSIE
#

# Colours
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
MAGENTA='\033[0;35m'
NC='\033[0m'
BOLD='\033[1m'
DIM='\033[2m'

clear

echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║${NC}           ${WHITE}${BOLD}FILESYSTEM HIERARCHY STANDARD (FHS) EXPLORER${NC}                      ${CYAN}║${NC}"
echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════════════════════╝${NC}"
echo ""

#
# FHS Diagram
#

echo -e "${WHITE}${BOLD}Hierarchical Structure of the Linux Filesystem:${NC}"
echo ""

echo -e "${YELLOW}/${NC} ${DIM}(root - everything starts here)${NC}"
echo -e "├── ${GREEN}bin/${NC}      ${DIM}→ Essential binaries (ls, cp, mv, cat...)${NC}"
echo -e "├── ${GREEN}sbin/${NC}     ${DIM}→ System binaries (for root: fdisk, mount...)${NC}"
echo -e "├── ${CYAN}etc/${NC}      ${DIM}→ ${BOLD}E${NC}${DIM}ditable ${BOLD}T${NC}${DIM}ext ${BOLD}C${NC}${DIM}onfig (system configuration)${NC}"
echo -e "│   ├── passwd     ${DIM}→ User information${NC}"
echo -e "│   ├── shadow     ${DIM}→ Encrypted passwords (root only)${NC}"
echo -e "│   ├── hosts      ${DIM}→ Local DNS mappings${NC}"
echo -e "│   └── bash.bashrc ${DIM}→ Global Bash configuration${NC}"
echo -e "├── ${MAGENTA}home/${NC}     ${DIM}→ User directories${NC}"
echo -e "│   └── ${YELLOW}$USER/${NC}  ${DIM}→ Your HOME (~)${NC}"
echo -e "│       ├── Desktop/"
echo -e "│       ├── Documents/"
echo -e "│       ├── Downloads/"
echo -e "│       └── ${GREEN}.bashrc${NC}  ${DIM}→ Your personal configuration${NC}"
echo -e "├── ${RED}tmp/${NC}      ${DIM}→ Temporary files (DELETED on reboot!)${NC}"
echo -e "├── ${BLUE}var/${NC}      ${DIM}→ Variable data${NC}"
echo -e "│   ├── log/       ${DIM}→ System logs${NC}"
echo -e "│   ├── cache/     ${DIM}→ Application cache${NC}"
echo -e "│   └── www/       ${DIM}→ Web server files${NC}"
echo -e "├── ${GREEN}usr/${NC}      ${DIM}→ Unix System Resources${NC}"
echo -e "│   ├── bin/       ${DIM}→ User programmes${NC}"
echo -e "│   ├── lib/       ${DIM}→ Libraries${NC}"
echo -e "│   └── share/     ${DIM}→ Shared data${NC}"
echo -e "├── ${YELLOW}opt/${NC}      ${DIM}→ Optional software (third-party applications)${NC}"
echo -e "├── ${MAGENTA}dev/${NC}      ${DIM}→ Hardware devices (as files!)${NC}"
echo -e "│   ├── null       ${DIM}→ \"Black hole\" - swallows everything${NC}"
echo -e "│   ├── zero       ${DIM}→ Infinite source of zeroes${NC}"
echo -e "│   └── sda        ${DIM}→ First hard disk${NC}"
echo -e "├── ${CYAN}proc/${NC}     ${DIM}→ Processes (virtual filesystem)${NC}"
echo -e "│   ├── cpuinfo    ${DIM}→ CPU information${NC}"
echo -e "│   └── meminfo    ${DIM}→ Memory information${NC}"
echo -e "└── ${BLUE}root/${NC}     ${DIM}→ Home of the root user${NC}"
echo ""

#
# Mnemonics
#

echo -e "${WHITE}═══════════════════════════════════════════════════════════════════════════════${NC}"
echo -e "${WHITE}${BOLD}MNEMONICS for memorisation:${NC}"
echo ""

echo -e "${CYAN}/etc${NC}  = ${BOLD}E${NC}ditable ${BOLD}T${NC}ext ${BOLD}C${NC}onfiguration"
echo -e "${CYAN}/var${NC}  = ${BOLD}VAR${NC}iable data (changes frequently)"
echo -e "${CYAN}/tmp${NC}  = ${BOLD}T${NC}e${BOLD}MP${NC}orary (temporary - disappears!)"
echo -e "${CYAN}/opt${NC}  = ${BOLD}OPT${NC}ional software"
echo -e "${CYAN}/usr${NC}  = ${BOLD}U${NC}nix ${BOLD}S${NC}ystem ${BOLD}R${NC}esources (NOT \"user\"!)"
echo -e "${CYAN}/bin${NC}  = ${BOLD}BIN${NC}aries (executables)"
echo -e "${CYAN}/lib${NC}  = ${BOLD}LIB${NC}raries"
echo -e "${CYAN}/dev${NC}  = ${BOLD}DEV${NC}ices"
echo -e "${CYAN}/proc${NC} = ${BOLD}PROC${NC}esses (virtual)"
echo ""

#
# Live Exploration
#

echo -e "${WHITE}═══════════════════════════════════════════════════════════════════════════════${NC}"
echo -e "${WHITE}${BOLD}LIVE EXPLORATION of your system:${NC}"
echo ""

echo -e "${YELLOW}► Contents of / (root):${NC}"
ls -1 / | head -15 | while read dir; do
    echo -e "  ${GREEN}$dir${NC}"
done
echo -e "  ${DIM}...${NC}"
echo ""

echo -e "${YELLOW}► Some files from /etc:${NC}"
ls /etc/*.conf 2>/dev/null | head -5 | while read f; do
    echo -e "  ${CYAN}$(basename "$f")${NC}"
done
echo ""

echo -e "${YELLOW}► Your HOME ($HOME):${NC}"
ls -la "$HOME" | head -8
echo ""

echo -e "${YELLOW}► System information from /proc:${NC}"
echo -e "  CPU: $(grep 'model name' /proc/cpuinfo 2>/dev/null | head -1 | cut -d: -f2 | xargs || echo 'N/A')"
echo -e "  RAM: $(grep 'MemTotal' /proc/meminfo 2>/dev/null | awk '{printf "%.1f GB", $2/1024/1024}' || echo 'N/A')"
echo -e "  Kernel: $(cat /proc/version 2>/dev/null | cut -d' ' -f3 || echo 'N/A')"
echo ""

#
# Windows vs Linux Comparison
#

echo -e "${WHITE}═══════════════════════════════════════════════════════════════════════════════${NC}"
echo -e "${WHITE}${BOLD}COMPARISON: Windows vs Linux${NC}"
echo ""

echo -e "${CYAN}┌────────────────────────────┬────────────────────────────────────────────────┐${NC}"
echo -e "${CYAN}│${NC}        ${BOLD}WINDOWS${NC}             ${CYAN}│${NC}                    ${BOLD}LINUX${NC}                      ${CYAN}│${NC}"
echo -e "${CYAN}├────────────────────────────┼────────────────────────────────────────────────┤${NC}"
echo -e "${CYAN}│${NC} C:\\                        ${CYAN}│${NC} /                                              ${CYAN}│${NC}"
echo -e "${CYAN}│${NC} C:\\Users\\Name             ${CYAN}│${NC} /home/name or ~                                ${CYAN}│${NC}"
echo -e "${CYAN}│${NC} C:\\Program Files          ${CYAN}│${NC} /usr/bin, /opt                                 ${CYAN}│${NC}"
echo -e "${CYAN}│${NC} C:\\Windows\\System32       ${CYAN}│${NC} /bin, /sbin                                    ${CYAN}│${NC}"
echo -e "${CYAN}│${NC} C:\\Windows\\Temp           ${CYAN}│${NC} /tmp                                           ${CYAN}│${NC}"
echo -e "${CYAN}│${NC} Registry                  ${CYAN}│${NC} /etc (text files!)                             ${CYAN}│${NC}"
echo -e "${CYAN}│${NC} Drive letters (C:, D:)    ${CYAN}│${NC} Mount points (/mnt, /media)                    ${CYAN}│${NC}"
echo -e "${CYAN}│${NC} \\ (backslash)             ${CYAN}│${NC} / (forward slash)                              ${CYAN}│${NC}"
echo -e "${CYAN}│${NC} Case insensitive          ${CYAN}│${NC} ${RED}CASE SENSITIVE!${NC}                              ${CYAN}│${NC}"
echo -e "${CYAN}└────────────────────────────┴────────────────────────────────────────────────┘${NC}"
echo ""

echo -e "${RED}⚠️  Pitfall: Linux distinguishes between File.txt and file.txt!${NC}"
echo ""

#
# Important Rules
#

echo -e "${GREEN}╔═══════════════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║${NC}                         ${BOLD}IMPORTANT RULES${NC}                                        ${GREEN}║${NC}"
echo -e "${GREEN}╠═══════════════════════════════════════════════════════════════════════════════╣${NC}"
echo -e "${GREEN}║${NC}  1. Everything is a file in Linux (even devices!)                           ${GREEN}║${NC}"
echo -e "${GREEN}║${NC}  2. /tmp is deleted on reboot - DO NOT store important data there           ${GREEN}║${NC}"
echo -e "${GREEN}║${NC}  3. ~ is a shortcut for \$HOME                                               ${GREEN}║${NC}"
echo -e "${GREEN}║${NC}  4. Files starting with . are hidden (e.g.: .bashrc)                        ${GREEN}║${NC}"
echo -e "${GREEN}║${NC}  5. Path separator is / (NOT \\)                                             ${GREEN}║${NC}"
echo -e "${GREEN}║${NC}  6. There are no \"drive letters\" - everything is under /                    ${GREEN}║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════════════════════════════════════════════╝${NC}"
echo ""
