#!/bin/bash
#===============================================================================
#          FILE: S04_05_demo_awk.sh
#   DESCRIPTION: Interactive demo for the awk command
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
echo -e "${CYAN}║                    DEMO: AWK                                 ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""

echo -e "${YELLOW}═══ 1. Fields and variables ═══${NC}"
echo ""
echo -e "${GREEN}\$0 = entire line:${NC}"
run_demo "echo 'John Smith 30' | awk '{print \$0}'"

echo -e "${GREEN}\$1, \$2, \$3 = fields:${NC}"
run_demo "echo 'John Smith 30' | awk '{print \$1}'"
run_demo "echo 'John Smith 30' | awk '{print \$3}'"

echo -e "${GREEN}\$NF = the last field:${NC}"
run_demo "echo 'John Smith 30 IT' | awk '{print \$NF}'"
pause

echo ""
echo -e "${YELLOW}═══ 2. CSV with -F ═══${NC}"
echo ""
run_demo "head -3 employees.csv"
echo ""
echo -e "${GREEN}Extract the Name column (-F','):${NC}"
run_demo "awk -F',' '{print \$2}' employees.csv | head -5"

echo -e "${GREEN}Skip header (NR > 1):${NC}"
run_demo "awk -F',' 'NR > 1 {print \$2}' employees.csv | head -5"
pause

echo ""
echo -e "${YELLOW}═══ 3. Print with and without comma ═══${NC}"
echo ""
echo -e "${RED}WITHOUT comma = concatenation:${NC}"
run_demo "echo 'a b' | awk '{print \$1 \$2}'"

echo -e "${GREEN}WITH comma = space (OFS):${NC}"
run_demo "echo 'a b' | awk '{print \$1, \$2}'"
echo -e "${YELLOW}→ This is a very common mistake!${NC}"
pause

echo ""
echo -e "${YELLOW}═══ 4. Filtering and calculations ═══${NC}"
echo ""
echo -e "${GREEN}Filter on condition:${NC}"
run_demo "awk -F',' '\$3 == \"IT\"' employees.csv"

echo -e "${GREEN}Sum of salaries:${NC}"
run_demo "awk -F',' 'NR > 1 {sum += \$4} END {print \"Total:\", sum}' employees.csv"

echo -e "${GREEN}Average:${NC}"
run_demo "awk -F',' 'NR > 1 {sum += \$4; count++} END {print \"Average:\", sum/count}' employees.csv"
pause

echo ""
echo -e "${YELLOW}═══ 5. Associative arrays ═══${NC}"
echo ""
echo -e "${GREEN}Count per department:${NC}"
run_demo "awk -F',' 'NR > 1 {count[\$3]++} END {for (d in count) print d, count[d]}' employees.csv"

echo -e "${GREEN}Sum per department:${NC}"
run_demo "awk -F',' 'NR > 1 {sum[\$3] += \$4} END {for (d in sum) print d, sum[d]}' employees.csv"
pause

echo ""
echo -e "${GREEN}✓ AWK demo complete!${NC}"
