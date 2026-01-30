#!/bin/bash
#
set -euo pipefail
# DEMO QUOTING - Visual demonstration of Single vs Double Quotes
# Operating Systems | ASE Bucharest - CSIE
#

# Colours
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'
BOLD='\033[1m'

clear

echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║${NC}             ${WHITE}${BOLD}DEMONSTRATION: SINGLE vs DOUBLE QUOTES${NC}                           ${CYAN}║${NC}"
echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Set the test variable
NAME="Student"
YEAR=$(date +%Y)

echo -e "${YELLOW}Variables set:${NC}"
echo -e "  NAME=\"$NAME\""
echo -e "  YEAR=\$(date +%Y) → \"$YEAR\""
echo ""

echo -e "${WHITE}═══════════════════════════════════════════════════════════════════════════════${NC}"
echo ""

# Demonstration 1: Single Quotes
echo -e "${CYAN}┌─────────────────────────────────────────────────────────────────────────────┐${NC}"
echo -e "${CYAN}│${NC} ${BOLD}SINGLE QUOTES${NC} - Everything is LITERAL (nothing is interpreted)             ${CYAN}│${NC}"
echo -e "${CYAN}└─────────────────────────────────────────────────────────────────────────────┘${NC}"
echo ""
echo -e "${YELLOW}Command:${NC}  echo 'Hello \$NAME in year \$YEAR'"
echo -e "${GREEN}Output:${NC}   $(echo 'Hello $NAME in year $YEAR')"
echo ""
echo -e "${BLUE}Explanation:${NC} The characters \$NAME and \$YEAR are displayed ${RED}literally${NC},"
echo -e "            they are not replaced with the variable values."
echo ""

# Demonstration 2: Double Quotes
echo -e "${CYAN}┌─────────────────────────────────────────────────────────────────────────────┐${NC}"
echo -e "${CYAN}│${NC} ${BOLD}DOUBLE QUOTES${NC} - Variables and commands ARE interpreted                     ${CYAN}│${NC}"
echo -e "${CYAN}└─────────────────────────────────────────────────────────────────────────────┘${NC}"
echo ""
echo -e "${YELLOW}Command:${NC}  echo \"Hello \$NAME in year \$YEAR\""
echo -e "${GREEN}Output:${NC}   $(echo "Hello $NAME in year $YEAR")"
echo ""
echo -e "${BLUE}Explanation:${NC} \$NAME becomes ${GREEN}\"$NAME\"${NC} and \$YEAR becomes ${GREEN}\"$YEAR\"${NC}."
echo ""

# Demonstration 3: Without Quotes
echo -e "${CYAN}┌─────────────────────────────────────────────────────────────────────────────┐${NC}"
echo -e "${CYAN}│${NC} ${BOLD}WITHOUT QUOTES${NC} - Interpretation + Word Splitting                           ${CYAN}│${NC}"
echo -e "${CYAN}└─────────────────────────────────────────────────────────────────────────────┘${NC}"
echo ""
echo -e "${YELLOW}Command:${NC}  echo Hello    \$NAME    in    year    \$YEAR"
echo -e "${GREEN}Output:${NC}   $(echo Hello    $NAME    in    year    $YEAR)"
echo ""
echo -e "${BLUE}Explanation:${NC} Variables are interpreted, but ${RED}multiple spaces${NC}"
echo -e "            are compressed into a single space (word splitting)."
echo ""

# Demonstration 4: Problem with spaces in filenames
echo -e "${WHITE}═══════════════════════════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${CYAN}┌─────────────────────────────────────────────────────────────────────────────┐${NC}"
echo -e "${CYAN}│${NC} ${BOLD}PRACTICAL PROBLEM:${NC} Files with spaces in names                              ${CYAN}│${NC}"
echo -e "${CYAN}└─────────────────────────────────────────────────────────────────────────────┘${NC}"
echo ""

FILE="Important Document.txt"
echo -e "${YELLOW}Variable:${NC} FILE=\"Important Document.txt\""
echo ""

echo -e "${RED}❌ WRONG:${NC}"
echo -e "   Command: cat \$FILE"
echo -e "   Bash sees: cat Important Document.txt"
echo -e "   Result: ${RED}Error - looks for 2 separate files!${NC}"
echo ""

echo -e "${GREEN}✓ CORRECT:${NC}"
echo -e "   Command: cat \"\$FILE\""
echo -e "   Bash sees: cat \"Important Document.txt\""
echo -e "   Result: ${GREEN}Works correctly!${NC}"
echo ""

# Summary table
echo -e "${WHITE}═══════════════════════════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${CYAN}┌─────────────────┬───────────────────────────────────────────────────────────┐${NC}"
echo -e "${CYAN}│${NC}     ${BOLD}TYPE${NC}        ${CYAN}│${NC}                    ${BOLD}BEHAVIOUR${NC}                           ${CYAN}│${NC}"
echo -e "${CYAN}├─────────────────┼───────────────────────────────────────────────────────────┤${NC}"
echo -e "${CYAN}│${NC} ${YELLOW}'single'${NC}        ${CYAN}│${NC} Everything literal - \$VAR remains \"\$VAR\"                 ${CYAN}│${NC}"
echo -e "${CYAN}├─────────────────┼───────────────────────────────────────────────────────────┤${NC}"
echo -e "${CYAN}│${NC} ${GREEN}\"double\"${NC}        ${CYAN}│${NC} \$VAR → value, \$(cmd) → command output                    ${CYAN}│${NC}"
echo -e "${CYAN}├─────────────────┼───────────────────────────────────────────────────────────┤${NC}"
echo -e "${CYAN}│${NC} ${RED}no quotes${NC}       ${CYAN}│${NC} Like double + word splitting (spaces compressed)          ${CYAN}│${NC}"
echo -e "${CYAN}└─────────────────┴───────────────────────────────────────────────────────────┘${NC}"
echo ""

# Golden rule
echo -e "${YELLOW}╔═══════════════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${YELLOW}║${NC}  ${BOLD}GOLDEN RULE:${NC} Always use \"\$VARIABLE\" with double quotes!                       ${YELLOW}║${NC}"
echo -e "${YELLOW}╚═══════════════════════════════════════════════════════════════════════════════╝${NC}"
echo ""
