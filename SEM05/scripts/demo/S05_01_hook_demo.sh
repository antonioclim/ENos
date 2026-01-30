#!/bin/bash
#
# Script:      S05_01_hook_demo.sh
# Description: Demo HOOK: Fragile vs Robust script
# Purpose:     Dramatic demonstration for the beginning of the seminar
#
# Warning:     This script is DEMONSTRATIVE - do not run the
#              "fragile" parts on production systems!
#

# ============================================================
# SETUP
# ============================================================
set -euo pipefail
IFS=$'\n\t'

readonly DEMO_DIR="/tmp/hook_demo_$$"
readonly FRAGILE_DIR="$DEMO_DIR/fragile"
readonly ROBUST_DIR="$DEMO_DIR/robust"

# Colours
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

# ============================================================
# HELPERS
# ============================================================
banner() {
    echo ""
    echo -e "${BOLD}${BLUE}════════════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}${BLUE}  $1${NC}"
    echo -e "${BOLD}${BLUE}════════════════════════════════════════════════════════════${NC}"
    echo ""
}

pause() {
    echo ""
    read -p "Press Enter to continue..."
    echo ""
}

cleanup() {
    rm -rf "$DEMO_DIR" 2>/dev/null || true
}
trap cleanup EXIT

# ============================================================
# SETUP DEMO
# ============================================================
setup_demo() {
    banner "SETUP: Creating the test environment"
    
    mkdir -p "$FRAGILE_DIR" "$ROBUST_DIR"
    
    # Create "important" files
    echo "Important data - financial report" > "$FRAGILE_DIR/report.txt"
    echo "Important data - client list" > "$FRAGILE_DIR/clients.txt"
    echo "Backup - do not delete!" > "$FRAGILE_DIR/backup.txt"
    
    echo "Important data - financial report" > "$ROBUST_DIR/report.txt"
    echo "Important data - client list" > "$ROBUST_DIR/clients.txt"
    echo "Backup - do not delete!" > "$ROBUST_DIR/backup.txt"
    
    echo -e "${GREEN}Files created in the test directories:${NC}"
    echo ""
    echo "FRAGILE_DIR: $FRAGILE_DIR"
    ls -la "$FRAGILE_DIR"
    echo ""
    echo "ROBUST_DIR: $ROBUST_DIR"
    ls -la "$ROBUST_DIR"
}

# ============================================================
# DEMO 1: FRAGILE SCRIPT
# ============================================================
demo_fragile() {
    banner "DEMO 1: THE FRAGILE SCRIPT 💀"
    
    echo -e "${YELLOW}This is a FRAGILE script (DO NOT do this in production!):${NC}"
    echo ""
    cat << 'SCRIPT'
#!/bin/bash
# FRAGILE script - NEGATIVE EXAMPLE!

target_dir="$1"

cd "$target_dir"        # What if the directory doesn't exist?
rm -rf *                 # DISASTER if cd failed!
process_files           # What if the function doesn't exist?
echo "Done!"
SCRIPT
    
    pause
    
    echo -e "${RED}What happens when we run with a NON-EXISTENT directory?${NC}"
    echo ""
    
    # Save the current directory
    local orig_dir="$PWD"
    
    # Create a temporary script for demonstration
    local temp_script=$(mktemp)
    cat > "$temp_script" << 'ENDSCRIPT'
#!/bin/bash
# Trying to enter a non-existent directory
cd /tmp/non_existent_directory_12345
echo "cd returned: $?"
echo "Current directory is: $PWD"
ENDSCRIPT
    chmod +x "$temp_script"
    
    echo -e "${YELLOW}Executing:${NC}"
    echo "  cd /tmp/non_existent_directory_12345"
    echo ""
    
    # Run in a subshell for safety
    (
        cd /tmp/non_existent_directory_12345 2>&1 || true
        echo -e "${RED}The cd command FAILED, but the script CONTINUES!${NC}"
        echo "Current directory remains: $PWD"
    )
    
    rm -f "$temp_script"
    
    echo ""
    echo -e "${RED}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║  DANGER: If 'rm -rf *' followed, it would have deleted        ║${NC}"
    echo -e "${RED}║          EVERYTHING in the CURRENT directory (could be / or  ║${NC}"
    echo -e "${RED}║          \$HOME!)                                              ║${NC}"
    echo -e "${RED}╚═══════════════════════════════════════════════════════════════╝${NC}"
}

# ============================================================
# DEMO 2: ROBUST SCRIPT
# ============================================================
demo_robust() {
    banner "DEMO 2: THE ROBUST SCRIPT ✅"
    
    echo -e "${GREEN}This is a ROBUST script:${NC}"
    echo ""
    cat << 'SCRIPT'
#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

target_dir="${1:?Error: target directory required}"

# Check BEFORE acting
[[ -d "$target_dir" ]] || { echo "Error: Not a directory: $target_dir" >&2; exit 1; }

cd "$target_dir" || { echo "Error: Cannot cd to $target_dir" >&2; exit 1; }

# ./* instead of * - prevents disaster if $PWD is something else
rm -rf ./*

echo "Cleanup completed in: $target_dir"
SCRIPT
    
    pause
    
    echo -e "${GREEN}What happens with the robust script?${NC}"
    echo ""
    
    # Demonstrate robust behaviour
    echo "1. Trying without argument:"
    echo -e "${YELLOW}   \${1:?Error: target directory required}${NC}"
    echo ""
    (
        set +e
        dir="${1:?Error: target directory required}" 2>&1 || true
    ) 2>&1 | head -1
    echo -e "${GREEN}   → Script stops immediately with a clear error${NC}"
    
    echo ""
    echo "2. Trying with non-existent directory:"
    echo -e "${YELLOW}   [[ -d \"\$target_dir\" ]] || { echo \"Error\"; exit 1; }${NC}"
    echo ""
    (
        set -e
        target_dir="/tmp/non_existent_xyz_123"
        if [[ -d "$target_dir" ]]; then
            echo "Directory exists"
        else
            echo -e "${GREEN}   → The check detected that the directory doesn't exist${NC}"
            echo -e "${GREEN}   → Script stops BEFORE rm${NC}"
        fi
    )
    
    echo ""
    echo "3. Using ./* instead of *:"
    echo -e "${YELLOW}   rm -rf ./*${NC}"
    echo -e "${GREEN}   → Even if cd somehow failed, ./* cannot affect /${NC}"
}

# ============================================================
# DEMO 3: SIDE-BY-SIDE COMPARISON
# ============================================================
demo_comparison() {
    banner "DEMO 3: SIDE-BY-SIDE COMPARISON"
    
    cat << 'EOF'
┌─────────────────────────────────────┬─────────────────────────────────────┐
│         ❌ FRAGILE SCRIPT           │         ✅ ROBUST SCRIPT             │
├─────────────────────────────────────┼─────────────────────────────────────┤
│ #!/bin/bash                         │ #!/bin/bash                         │
│                                     │ set -euo pipefail                   │
│                                     │                                     │
│ cd "$1"                             │ dir="${1:?Error: dir required}"     │
│                                     │ [[ -d "$dir" ]] || exit 1           │
│                                     │ cd "$dir" || exit 1                 │
│                                     │                                     │
│ rm -rf *                            │ rm -rf ./*                          │
│                                     │                                     │
│ process $file                       │ process "$file"                     │
│                                     │                                     │
│ echo "Done"                         │ echo "Done: $dir cleaned"           │
├─────────────────────────────────────┼─────────────────────────────────────┤
│ • Ignores errors                    │ • Stops on errors                   │
│ • Variables without quotes          │ • Variables with quotes             │
│ • rm -rf * dangerous                │ • rm -rf ./* safe                   │
│ • Vague messages                    │ • Clear messages                    │
│ • Can destroy the system!           │ • Fail-safe                         │
└─────────────────────────────────────┴─────────────────────────────────────┘
EOF
    
    pause
    
    echo -e "${BOLD}QUESTION FOR THE CLASS:${NC}"
    echo ""
    echo "It's 3 o'clock in the morning. You need to run a cleanup script"
    echo "on the production server that contains client data."
    echo ""
    echo -e "${YELLOW}Which script do you run?${NC}"
    echo ""
    echo "  A) The fragile script - it's shorter and probably works"
    echo "  B) The robust script - takes longer to write but is safe"
    echo ""
}

# ============================================================
# DEMO 4: LIVE - set -euo pipefail in action
# ============================================================
demo_set_options() {
    banner "DEMO 4: set -euo pipefail IN ACTION"
    
    echo -e "${BOLD}What each option does:${NC}"
    echo ""
    
    echo -e "${YELLOW}1. set -e (errexit)${NC}"
    echo "   Script stops when a command returns non-zero"
    echo ""
    echo "   Without set -e:"
    (
        false
        echo "   Script continues after 'false' ← DANGEROUS!"
    )
    echo ""
    echo "   With set -e:"
    (
        set +e  # disable for demo in subshell
        set -e
        false || echo "   Script would have stopped here (demo in subshell)"
    )
    
    pause
    
    echo -e "${YELLOW}2. set -u (nounset)${NC}"
    echo "   Error on undefined variables"
    echo ""
    echo "   Without set -u:"
    (
        set +u
        echo "   UNDEFINED=[$UNDEFINED_VAR] ← Empty string, no error!"
    )
    echo ""
    echo "   With set -u:"
    echo "   bash: UNDEFINED_VAR: unbound variable"
    echo "   → Script stops!"
    
    pause
    
    echo -e "${YELLOW}3. set -o pipefail${NC}"
    echo "   Pipe returns error from any command, not just the last"
    echo ""
    echo "   Without pipefail:"
    (
        set +o pipefail
        false | true
        echo "   Exit code: $? ← 0 (from 'true'), error from 'false' is hidden!"
    )
    echo ""
    echo "   With pipefail:"
    (
        set -o pipefail
        false | true || echo "   Exit code: 1 ← Error from 'false' is detected!"
    )
}

# ============================================================
# MAIN
# ============================================================
main() {
    banner "🎬 HOOK: FRAGILE vs ROBUST SCRIPT"
    
    echo -e "${BOLD}This demo shows why robust scripts matter.${NC}"
    echo "You will see the difference between amateur and professional code."
    echo ""
    echo "Warning: The 'fragile' examples are for demonstration only!"
    echo "         DO NOT run fragile code on real systems."
    
    pause
    
    setup_demo
    pause
    
    demo_fragile
    pause
    
    demo_robust
    pause
    
    demo_comparison
    pause
    
    demo_set_options
    
    banner "CONCLUSIONS"
    
    cat << 'EOF'
╔══════════════════════════════════════════════════════════════════════════╗
║                                                                          ║
║  🎯 KEY LESSONS:                                                         ║
║                                                                          ║
║  1. ALWAYS start with: set -euo pipefail                                 ║
║                                                                          ║
║  2. CHECK before acting:                                                 ║
║     • Does the directory exist?                                          ║
║     • Is the file readable?                                              ║
║     • Do I have permissions?                                             ║
║                                                                          ║
║  3. USE quotes for variables: "$var" not $var                            ║
║                                                                          ║
║  4. CLEAR ERROR MESSAGES when something goes wrong                       ║
║                                                                          ║
║  5. FAIL EARLY - it's better to stop early than to continue              ║
║     and cause greater damage                                             ║
║                                                                          ║
╚══════════════════════════════════════════════════════════════════════════╝
EOF
    
    echo ""
    echo -e "${GREEN}Demo complete! The professional template applies all these principles.${NC}"
    echo ""
}

# Run only if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
