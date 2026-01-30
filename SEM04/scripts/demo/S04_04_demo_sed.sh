#!/bin/bash
#===============================================================================
#          FILE: S04_04_demo_sed.sh
#   DESCRIPTION: Interactive demo for the sed command
#===============================================================================

set -euo pipefail

readonly DATA_DIR="$HOME/demo_sem4/data"
readonly BLUE='\033[0;34m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly RED='\033[0;31m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m'

cd "$DATA_DIR"

run_demo() {
    echo -e "${BLUE}$ $1${NC}"
    sleep 0.3
    eval "$1" 2>/dev/null || echo "(error)"
    echo ""
}

pause() { read -rp "Press Enter to continue..."; }

clear
echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║                    DEMO: SED                                 ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""

echo -e "${YELLOW}═══ 1. Basic substitution ═══${NC}"
echo ""
echo -e "${GREEN}Without /g (first occurrence only):${NC}"
run_demo "echo 'cat cat cat' | sed 's/cat/dog/'"

echo -e "${GREEN}With /g (all occurrences):${NC}"
run_demo "echo 'cat cat cat' | sed 's/cat/dog/g'"

echo -e "${RED}Remember: sed by default does NOT modify the file!${NC}"
run_demo "sed 's/localhost/127.0.0.1/' config.txt | head -3"
run_demo "grep localhost config.txt | head -1"
echo -e "${YELLOW}→ The file is unchanged, output goes to stdout${NC}"
pause

echo ""
echo -e "${YELLOW}═══ 2. In-place editing (CAUTION!) ═══${NC}"
echo ""
echo -e "${GREEN}With backup (-i.bak):${NC}"
run_demo "cp config.txt config_test.txt"
run_demo "sed -i.bak 's/localhost/127.0.0.1/' config_test.txt"
run_demo "ls config_test.*"
run_demo "rm -f config_test.txt config_test.txt.bak"
pause

echo ""
echo -e "${YELLOW}═══ 3. Deletion and pattern matching ═══${NC}"
echo ""
echo -e "${GREEN}Delete comments (/^#/d):${NC}"
run_demo "sed '/^#/d' config.txt | head -5"

echo -e "${GREEN}Delete empty lines (/^\$/d):${NC}"
run_demo "sed '/^$/d' config.txt | head -10"

echo -e "${GREEN}Combined:${NC}"
run_demo "sed '/^#/d; /^\$/d' config.txt | head -5"
pause

echo ""
echo -e "${YELLOW}═══ 4. Backreferences ═══${NC}"
echo ""
echo -e "${GREEN}& = the entire match:${NC}"
run_demo "echo 'port=8080' | sed 's/[0-9][0-9]*/[&]/'"

echo -e "${GREEN}\\1, \\2 = captured groups:${NC}"
run_demo "echo 'John Smith' | sed 's/\\([A-Za-z]*\\) \\([A-Za-z]*\\)/\\2, \\1/'"
pause

echo ""
echo -e "${GREEN}✓ Sed demo complete!${NC}"
