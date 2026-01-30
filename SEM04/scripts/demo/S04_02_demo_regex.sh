#!/bin/bash
#===============================================================================
#          FILE: S04_02_demo_regex.sh
#   DESCRIPTION: Interactive demo for regular expressions
#===============================================================================

set -euo pipefail

readonly DATA_DIR="$HOME/demo_sem4/data"
readonly BLUE='\033[0;34m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly RED='\033[0;31m'
readonly CYAN='\033[0;36m'
readonly BOLD='\033[1m'
readonly NC='\033[0m'

cd "$DATA_DIR"

run_demo() {
    echo -e "${BLUE}$ $1${NC}"
    sleep 0.3
    eval "$1"
    echo ""
}

pause() {
    read -rp "Press Enter to continue..."
}

clear
echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║              DEMO: REGULAR EXPRESSIONS (REGEX)               ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Demo 1: Dot
echo -e "${YELLOW}═══ 1. The . (dot) metacharacter ═══${NC}"
echo ""
echo -e "${GREEN}Creating a test file:${NC}"
run_demo "echo -e 'abc\nac\naXc\na1c\nabbc' > test_dot.txt"
run_demo "cat test_dot.txt"
echo ""
echo -e "${GREEN}Pattern 'a.c' (dot = any single character):${NC}"
run_demo "grep 'a.c' test_dot.txt"
echo -e "${YELLOW}→ 'ac' does not appear because . requires EXACTLY one character!${NC}"
pause

# Demo 2: Anchors
echo ""
echo -e "${YELLOW}═══ 2. Anchors: ^ and $ ═══${NC}"
echo ""
run_demo "echo -e 'Start here\nNot Start\nStarting' > test_anchor.txt"
run_demo "cat test_anchor.txt"
echo ""
echo -e "${GREEN}Pattern '^Start' (start of line):${NC}"
run_demo "grep '^Start' test_anchor.txt"
pause

# Demo 3: BRE vs ERE
echo ""
echo -e "${YELLOW}═══ 3. BRE vs ERE - THE CRITICAL DIFFERENCE ═══${NC}"
echo ""
run_demo "echo -e 'ac\nabc\nabbc\nabbbc' > test_quant.txt"
echo ""
echo -e "${RED}WRONG - grep in BRE:${NC}"
run_demo "grep 'ab+c' test_quant.txt || echo '(nothing found!)'"
echo ""
echo -e "${GREEN}CORRECT - grep -E in ERE:${NC}"
run_demo "grep -E 'ab+c' test_quant.txt"
echo ""
echo -e "${YELLOW}→ In BRE, + is a LITERAL character! Use -E for quantifiers.${NC}"
pause

# Demo 4: Character classes
echo ""
echo -e "${YELLOW}═══ 4. Character classes ═══${NC}"
echo ""
echo -e "${GREEN}[0-9] = digits:${NC}"
run_demo "echo -e 'abc123\ntest\n456' | grep '[0-9]'"
echo ""
echo -e "${GREEN}[^0-9] = NOT digits (one character):${NC}"
run_demo "echo -e 'abc123\n456' | grep '[^0-9]'"
echo -e "${YELLOW}→ Careful! This finds lines with AT LEAST one non-digit, not lines WITHOUT digits!${NC}"
echo ""
echo -e "${GREEN}Lines WITHOUT any digits (grep -v):${NC}"
run_demo "echo -e 'abc123\ntest\n456' | grep -v '[0-9]'"
pause

# Cleanup
rm -f test_dot.txt test_anchor.txt test_quant.txt 2>/dev/null

echo ""
echo -e "${GREEN}✓ Regex demo complete!${NC}"
