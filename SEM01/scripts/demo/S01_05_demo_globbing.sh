#!/bin/bash
#
set -euo pipefail
# DEMO GLOBBING - Wildcards and Pattern Matching
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

# Create temporary directory for demo
DEMO_DIR=$(mktemp -d)
cd "$DEMO_DIR"

# Cleanup function
cleanup() {
    cd ~
    rm -rf "$DEMO_DIR"
}
trap cleanup EXIT

clear

echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║${NC}            ${WHITE}${BOLD}DEMONSTRATION: GLOBBING (WILDCARDS)${NC}                              ${CYAN}║${NC}"
echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════════════════════╝${NC}"
echo ""

#
# Create test files
#

echo -e "${YELLOW}► Creating test files...${NC}"
touch file{1..10}.txt
touch doc{A..E}.pdf
touch image{01..05}.jpg
touch script{1..3}.sh
touch .hidden_file
touch "Document with spaces.txt"
echo ""

echo -e "${GREEN}Files created:${NC}"
ls -la
echo ""

read -p "Press Enter to continue..."
clear

#
# Pattern: * (asterisk)
#

echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║${NC}  ${BOLD}PATTERN: * (asterisk)${NC} - Matches ZERO or MORE characters                     ${CYAN}║${NC}"
echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════════════════════╝${NC}"
echo ""

echo -e "${YELLOW}Command:${NC} ls *.txt"
echo -e "${GREEN}Result:${NC}"
ls *.txt
echo ""

echo -e "${YELLOW}Command:${NC} ls file*"
echo -e "${GREEN}Result:${NC}"
ls file*
echo ""

echo -e "${YELLOW}Command:${NC} ls *"
echo -e "${GREEN}Result:${NC}"
ls *
echo ""

echo -e "${RED}⚠️  Pitfall: * does NOT include hidden files (.hidden_file)!${NC}"
echo -e "${BLUE}To see hidden files, use: ls .*${NC}"
echo ""

read -p "Press Enter to continue..."
clear

#
# Pattern: ? (question mark)
#

echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║${NC}  ${BOLD}PATTERN: ? (question mark)${NC} - Matches EXACTLY ONE character                   ${CYAN}║${NC}"
echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════════════════════╝${NC}"
echo ""

echo -e "${YELLOW}Command:${NC} ls file?.txt"
echo -e "${GREEN}Result:${NC}"
ls file?.txt 2>/dev/null || echo "(no results)"
echo ""
echo -e "${BLUE}Explanation:${NC} Matches file1.txt - file9.txt, but ${RED}NOT${NC} file10.txt"
echo -e "            (10 has TWO characters, ? matches only one)"
echo ""

echo -e "${YELLOW}Command:${NC} ls image??.jpg"
echo -e "${GREEN}Result:${NC}"
ls image??.jpg
echo ""
echo -e "${BLUE}Explanation:${NC} ?? matches exactly 2 characters (01, 02, 03...)"
echo ""

read -p "Press Enter to continue..."
clear

#
# Pattern: [...] (bracket expression)
#

echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║${NC}  ${BOLD}PATTERN: [...] (brackets)${NC} - Matches ONE character from set                   ${CYAN}║${NC}"
echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════════════════════╝${NC}"
echo ""

echo -e "${YELLOW}Command:${NC} ls file[135].txt"
echo -e "${GREEN}Result:${NC}"
ls file[135].txt
echo ""
echo -e "${BLUE}Explanation:${NC} Matches file1.txt, file3.txt, file5.txt"
echo ""

echo -e "${YELLOW}Command:${NC} ls file[1-5].txt"
echo -e "${GREEN}Result:${NC}"
ls file[1-5].txt
echo ""
echo -e "${BLUE}Explanation:${NC} Range - matches file1.txt through file5.txt"
echo ""

echo -e "${YELLOW}Command:${NC} ls doc[A-C].pdf"
echo -e "${GREEN}Result:${NC}"
ls doc[A-C].pdf
echo ""
echo -e "${BLUE}Explanation:${NC} Alphabetic range - matches docA.pdf, docB.pdf, docC.pdf"
echo ""

read -p "Press Enter to continue..."
clear

#
# Brace Expansion {...}
#

echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║${NC}  ${BOLD}BRACE EXPANSION: {...}${NC} - Generates lists (NOT globbing!)                     ${CYAN}║${NC}"
echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════════════════════╝${NC}"
echo ""

echo -e "${MAGENTA}Remember: Brace expansion is different from globbing!${NC}"
echo -e "Brace expansion generates text BEFORE checking which files exist."
echo ""

echo -e "${YELLOW}Command:${NC} echo {A,B,C}"
echo -e "${GREEN}Result:${NC} $(echo {A,B,C})"
echo ""

echo -e "${YELLOW}Command:${NC} echo file{1..5}.txt"
echo -e "${GREEN}Result:${NC} $(echo file{1..5}.txt)"
echo ""

echo -e "${YELLOW}Command:${NC} echo {a..z}"
echo -e "${GREEN}Result:${NC} $(echo {a..z})"
echo ""

echo -e "${YELLOW}Command:${NC} mkdir -p proiect/{src,docs,tests}"
echo -e "${GREEN}Result:${NC} Creates 3 directories simultaneously!"
mkdir -p proiect/{src,docs,tests}
ls -d proiect/*/
echo ""

read -p "Press Enter to continue..."
clear

#
# Comparison Table
#

echo -e "${WHITE}${BOLD}COMPARISON TABLE - WILDCARDS${NC}"
echo ""

echo -e "${CYAN}┌──────────┬─────────────────────────────────┬─────────────────────────────────┐${NC}"
echo -e "${CYAN}│${NC} ${BOLD}Pattern${NC}  ${CYAN}│${NC}          ${BOLD}Description${NC}              ${CYAN}│${NC}           ${BOLD}Example${NC}               ${CYAN}│${NC}"
echo -e "${CYAN}├──────────┼─────────────────────────────────┼─────────────────────────────────┤${NC}"
echo -e "${CYAN}│${NC}    ${YELLOW}*${NC}     ${CYAN}│${NC} Zero or more characters        ${CYAN}│${NC} *.txt → all .txt files         ${CYAN}│${NC}"
echo -e "${CYAN}├──────────┼─────────────────────────────────┼─────────────────────────────────┤${NC}"
echo -e "${CYAN}│${NC}    ${YELLOW}?${NC}     ${CYAN}│${NC} Exactly ONE character          ${CYAN}│${NC} file?.txt → file1, NOT file10  ${CYAN}│${NC}"
echo -e "${CYAN}├──────────┼─────────────────────────────────┼─────────────────────────────────┤${NC}"
echo -e "${CYAN}│${NC}  ${YELLOW}[abc]${NC}  ${CYAN}│${NC} One character from set         ${CYAN}│${NC} file[123].txt → file1,2,3      ${CYAN}│${NC}"
echo -e "${CYAN}├──────────┼─────────────────────────────────┼─────────────────────────────────┤${NC}"
echo -e "${CYAN}│${NC}  ${YELLOW}[a-z]${NC}  ${CYAN}│${NC} One character from range       ${CYAN}│${NC} [a-c].txt → a.txt, b.txt, c.txt${CYAN}│${NC}"
echo -e "${CYAN}├──────────┼─────────────────────────────────┼─────────────────────────────────┤${NC}"
echo -e "${CYAN}│${NC}  ${YELLOW}[!ab]${NC}  ${CYAN}│${NC} One character EXCEPT           ${CYAN}│${NC} file[!0-5].txt → file6-9       ${CYAN}│${NC}"
echo -e "${CYAN}├──────────┼─────────────────────────────────┼─────────────────────────────────┤${NC}"
echo -e "${CYAN}│${NC} ${YELLOW}{a,b,c}${NC} ${CYAN}│${NC} Brace expansion (generation)   ${CYAN}│${NC} {a,b}.txt → a.txt b.txt        ${CYAN}│${NC}"
echo -e "${CYAN}└──────────┴─────────────────────────────────┴─────────────────────────────────┘${NC}"
echo ""

#
# Quick Quiz
#

echo -e "${WHITE}═══════════════════════════════════════════════════════════════════════════════${NC}"
echo -e "${WHITE}${BOLD}QUICK QUIZ: What will each pattern match?${NC}"
echo ""

echo -e "${YELLOW}Available files:${NC} file1.txt file2.txt file10.txt docA.pdf docB.pdf .hidden"
echo ""

echo -e "1. ${CYAN}*.pdf${NC}           → ?"
read -p "   Your answer: " ans1
echo -e "   ${GREEN}Correct: docA.pdf docB.pdf${NC}"
echo ""

echo -e "2. ${CYAN}file?.txt${NC}       → ?"
read -p "   Your answer: " ans2
echo -e "   ${GREEN}Correct: file1.txt file2.txt (NOT file10.txt!)${NC}"
echo ""

echo -e "3. ${CYAN}*${NC}               → Does it include .hidden?"
read -p "   Your answer (yes/no): " ans3
echo -e "   ${GREEN}Correct: NO! * does not include hidden files${NC}"
echo ""

echo -e "${GREEN}╔═══════════════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║${NC}  ${BOLD}REMEMBER:${NC} ? = exactly 1 character, * = 0 or more, * does NOT include .files ${GREEN}║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════════════════════════════════════════════╝${NC}"
echo ""
