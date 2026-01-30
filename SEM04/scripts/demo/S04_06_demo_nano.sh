#!/bin/bash
#===============================================================================
#          FILE: S04_06_demo_nano.sh
#   DESCRIPTION: Demo for the nano editor - displays key commands
#===============================================================================

set -euo pipefail

readonly CYAN='\033[0;36m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BOLD='\033[1m'
readonly NC='\033[0m'

clear
echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║                    DEMO: NANO EDITOR                         ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""

echo -e "${YELLOW}═══ Why Nano? ═══${NC}"
echo ""
echo "• Simple and intuitive"
echo "• All commands are displayed in the footer"
echo "• No need to memorise modes (like vim)"
echo "• Available on almost any Linux system"
echo ""

echo -e "${YELLOW}═══ Essential Commands (^ = CTRL) ═══${NC}"
echo ""
echo -e "${GREEN}Save and Exit:${NC}"
echo "  ^O = Write Out (Save)"
echo "  ^X = Exit"
echo ""
echo -e "${GREEN}Search:${NC}"
echo "  ^W = Where Is (Search)"
echo "  ^Q = Where Was (Search backwards)"
echo ""
echo -e "${GREEN}Editing:${NC}"
echo "  ^K = Cut line"
echo "  ^U = Uncut (Paste)"
echo "  ^6 = Mark set (for selection)"
echo ""
echo -e "${GREEN}Navigation:${NC}"
echo "  ^A = Beginning of line"
echo "  ^E = End of line"
echo "  ^Y = Page Up"
echo "  ^V = Page Down"
echo ""
echo -e "${GREEN}Help:${NC}"
echo "  ^G = Get Help"
echo ""

echo -e "${YELLOW}═══ Typical Workflow ═══${NC}"
echo ""
echo "1. Open: nano filename.txt"
echo "2. Edit the content"
echo "3. Save: ^O → Enter"
echo "4. Exit: ^X"
echo ""

read -rp "Press Enter to open nano with a demo file..."

# Create a demo file
cat > /tmp/nano_demo.txt << 'EOF'
# This is a nano demonstration
# ============================

Try these actions:

1. Navigate with arrow keys
2. Search "demo" with ^W
3. Cut this line with ^K
4. Paste it below with ^U
5. Save with ^O
6. Exit with ^X

# Note: All commands are displayed in the bottom bar!
EOF

nano /tmp/nano_demo.txt

echo ""
echo -e "${GREEN}✓ Nano demo complete!${NC}"
rm -f /tmp/nano_demo.txt
