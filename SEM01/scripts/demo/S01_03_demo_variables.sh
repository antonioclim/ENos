#!/bin/bash
#
# DEMO: Variables in Bash
# Operating Systems | ASE Bucharest - CSIE
#
# Purpose: Demonstrate local vs exported variables, quoting, and scope
# Usage: ./S01_03_demo_variables.sh
#

set -euo pipefail

# Colours for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'
BOLD='\033[1m'

echo -e "${CYAN}+===================================================================+${NC}"
echo -e "${CYAN}|${NC}              ${BOLD}DEMO: Variables in Bash${NC}                          ${CYAN}|${NC}"
echo -e "${CYAN}+===================================================================+${NC}"
echo ""

# -----------------------------------------------------------------------------
# SECTION 1: Local Variables
# -----------------------------------------------------------------------------

echo -e "${YELLOW}>>> SECTION 1: Local Variables${NC}"
echo ""

# Correct assignment (no spaces!)
MY_NAME="Student"
MY_NUMBER=42
MY_PATH="/home/user/documents"

echo "Creating local variables:"
echo "  MY_NAME=\"Student\""
echo "  MY_NUMBER=42"
echo "  MY_PATH=\"/home/user/documents\""
echo ""

echo "Accessing variables with \$:"
echo "  \$MY_NAME  -> $MY_NAME"
echo "  \$MY_NUMBER -> $MY_NUMBER"
echo "  \$MY_PATH  -> $MY_PATH"
echo ""

# COMMON MISTAKE demonstration
echo -e "${RED}COMMON MISTAKE: Spaces around =${NC}"
echo "  If you write: MY_VAR = \"value\""
echo "  Bash interprets it as: command 'MY_VAR' with arguments '=' and 'value'"
echo "  This causes: 'MY_VAR: command not found'"
echo ""

read -p "Press Enter to continue..."
echo ""

# -----------------------------------------------------------------------------
# SECTION 2: Environment Variables
# -----------------------------------------------------------------------------

echo -e "${YELLOW}>>> SECTION 2: Environment Variables${NC}"
echo ""

echo "Standard environment variables:"
echo "  \$USER     -> $USER"
echo "  \$HOME     -> $HOME"
echo "  \$SHELL    -> $SHELL"
echo "  \$PWD      -> $PWD"
echo ""

echo "PATH variable (truncated):"
echo "  \$PATH -> ${PATH:0:60}..."
echo ""

read -p "Press Enter to continue..."
echo ""

# -----------------------------------------------------------------------------
# SECTION 3: Local vs Exported Variables
# -----------------------------------------------------------------------------

echo -e "${YELLOW}>>> SECTION 3: Local vs Exported Variables${NC}"
echo ""

# Local variable
LOCAL_VAR="I am local"

# Exported variable
export EXPORTED_VAR="I am exported"

echo "Created two variables:"
echo "  LOCAL_VAR=\"I am local\"     (not exported)"
echo "  export EXPORTED_VAR=\"I am exported\""
echo ""

echo "Testing in current shell:"
echo "  \$LOCAL_VAR    -> $LOCAL_VAR"
echo "  \$EXPORTED_VAR -> $EXPORTED_VAR"
echo ""

echo -e "${BLUE}Now testing in a SUBSHELL (bash -c):${NC}"
echo ""

echo "  Subshell sees LOCAL_VAR as:"
bash -c 'echo "    -> \"$LOCAL_VAR\" (empty - not visible!)"'

echo "  Subshell sees EXPORTED_VAR as:"
bash -c 'echo "    -> \"$EXPORTED_VAR\""'
echo ""

echo -e "${GREEN}Lesson: Use 'export' when child processes need the variable.${NC}"
echo ""

read -p "Press Enter to continue..."
echo ""

# -----------------------------------------------------------------------------
# SECTION 4: Quoting Differences
# -----------------------------------------------------------------------------

echo -e "${YELLOW}>>> SECTION 4: Quoting Differences${NC}"
echo ""

TEST_VAR="World"

echo "TEST_VAR=\"World\""
echo ""

echo "Different quoting styles:"
echo ""

echo "  No quotes:      echo Hello \$TEST_VAR"
echo "  Result:         Hello $TEST_VAR"
echo ""

echo "  Double quotes:  echo \"Hello \$TEST_VAR\""
echo "  Result:         Hello $TEST_VAR"
echo ""

echo "  Single quotes:  echo 'Hello \$TEST_VAR'"
echo "  Result:         Hello \$TEST_VAR"
echo ""

echo -e "${GREEN}Key difference:${NC}"
echo "  - Double quotes (\"\") allow variable expansion"
echo "  - Single quotes ('') preserve everything literally"
echo ""

read -p "Press Enter to continue..."
echo ""

# -----------------------------------------------------------------------------
# SECTION 5: Special Variables
# -----------------------------------------------------------------------------

echo -e "${YELLOW}>>> SECTION 5: Special Variables${NC}"
echo ""

echo "Script information:"
echo "  \$0 (script name)     -> $0"
echo "  \$\$ (process ID)      -> $$"
echo "  \$? (last exit code)  -> $?"
echo ""

echo "Demonstrating \$? with commands:"
echo ""

echo "  Running: ls /tmp > /dev/null"
ls /tmp > /dev/null
echo "  Exit code \$? -> $?"
echo ""

echo "  Running: ls /nonexistent 2>/dev/null"
ls /nonexistent 2>/dev/null || true
echo "  Exit code \$? -> $?"
echo ""

echo -e "${GREEN}Remember: Exit code 0 = success, non-zero = error${NC}"
echo ""

# -----------------------------------------------------------------------------
# SUMMARY
# -----------------------------------------------------------------------------

echo -e "${CYAN}+===================================================================+${NC}"
echo -e "${CYAN}|${NC}                     ${BOLD}SUMMARY${NC}                                    ${CYAN}|${NC}"
echo -e "${CYAN}+===================================================================+${NC}"
echo ""
echo "Key points from this demo:"
echo ""
echo "  1. No spaces around = in assignments"
echo "  2. Use \$ to read variable value"
echo "  3. export makes variables visible to child processes"
echo "  4. Double quotes allow expansion, single quotes do not"
echo "  5. \$? contains the exit code of the last command"
echo ""
