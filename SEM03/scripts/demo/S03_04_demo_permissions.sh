#!/bin/bash
#
#  S03_04_demo_permissions.sh
# Interactive Demonstration: Unix Permissions System
#
#
# DESCRIPTION:
#   Demonstration script for Unix permissions: chmod (octal and symbolic),
#   chown, chgrp, umask, and special permissions (SUID, SGID, Sticky).
#   Includes ASCII visualisations and interactive exercises.
#
# USAGE:
#   ./S03_04_demo_permissions.sh [options]
#
# OPTIONS:
#   -h, --help          Display this help
#   -i, --interactive   Interactive mode with pauses
#   -s, --section NUM   Run only a section (1-8)
#   -c, --cleanup       Delete demo directories
#   -t, --tool NAME     Run a specific tool (calculator, visualizer, audit)
#
#  Pitfall:
#   - All exercises are done in ~/permissions_demo (sandbox)
#   - DO NOT use chmod 777 as an acceptable solution!
#   - SUID/SGID demonstrations are conceptual only
#
# AUTHOR: Seminar Kit OS - ASE Bucharest
# VERSION: 1.0
#

set -e

#
# CONFIGURATION
#

DEMO_DIR="$HOME/permissions_demo"
INTERACTIVE=false
RUN_SECTION=""
TOOL_NAME=""

# Colours
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
GRAY='\033[0;90m'
NC='\033[0m'
BOLD='\033[1m'
DIM='\033[2m'
BG_RED='\033[41m'
BG_GREEN='\033[42m'
BG_YELLOW='\033[43m'

#
# UTILITY FUNCTIONS
#

print_header() {
    local title="$1"
    local width=70
    echo ""
    echo -e "${CYAN}╔$(printf '═%.0s' $(seq 1 $((width-2))))╗${NC}"
    printf "${CYAN}║${NC} ${BOLD}${WHITE}%-$((width-4))s${NC} ${CYAN}║${NC}\n" "$title"
    echo -e "${CYAN}╚$(printf '═%.0s' $(seq 1 $((width-2))))╝${NC}"
    echo ""
}

print_subheader() {
    local title="$1"
    echo ""
    echo -e "${YELLOW}┌──────────────────────────────────────────────────────────────────┐${NC}"
    echo -e "${YELLOW}│${NC} ${BOLD}$title${NC}"
    echo -e "${YELLOW}└──────────────────────────────────────────────────────────────────┘${NC}"
}

print_concept() {
    local concept="$1"
    echo -e "\n${MAGENTA}💡 CONCEPT:${NC} ${WHITE}$concept${NC}\n"
}

print_warning() {
    local text="$1"
    echo -e "\n${RED}⚠️  Pitfall:${NC} ${YELLOW}$text${NC}"
}

print_danger() {
    local text="$1"
    echo -e "\n${BG_RED}${WHITE} ☠️  DANGER ${NC} ${RED}$text${NC}"
}

print_tip() {
    local text="$1"
    echo -e "\n${GREEN}💚 TIP:${NC} $text"
}

print_command() {
    local cmd="$1"
    echo -e "${GREEN}▶${NC} ${BOLD}${WHITE}$cmd${NC}"
}

run_demo() {
    local cmd="$1"
    local description="$2"
    
    print_command "$cmd"
    [[ -n "$description" ]] && echo -e "  ${GRAY}↳ $description${NC}"
    echo -e "${DIM}─────────── OUTPUT ───────────${NC}"
    eval "$cmd" 2>&1 || true
    echo -e "${DIM}──────────────────────────────${NC}"
}

pause_interactive() {
    if [[ "$INTERACTIVE" == true ]]; then
        echo ""
        echo -e "${CYAN}⏸  Press ENTER to continue...${NC}"
        read -r
    fi
}

show_usage() {
    cat << 'EOF'
═══════════════════════════════════════════════════════════════════════════════
 🔐 Unix Permissions Demo - Usage
═══════════════════════════════════════════════════════════════════════════════

SYNTAX:
  ./S03_04_demo_permissions.sh [options]

OPTIONS:
  -h, --help          Display this help
  -i, --interactive   Interactive mode with pauses between sections
  -s, --section NUM   Run only the specified section (1-8)
  -c, --cleanup       Delete demo directories
  -t, --tool NAME     Run a specific tool

SECTIONS:
  1 - Permissions fundamentals (rwx)
  2 - Visualisation and interpretation
  3 - chmod octal
  4 - chmod symbolic
  5 - umask
  6 - Special permissions (SUID, SGID, Sticky)
  7 - chown and chgrp
  8 - Best practices and security audit

TOOLS:
  calculator  - Permissions calculator octal ↔ symbolic
  visualizer  - Graphical permissions visualisation
  audit       - Directory security audit

EXAMPLES:
  ./S03_04_demo_permissions.sh -i              # Complete interactive demo
  ./S03_04_demo_permissions.sh -s 3            # Only chmod octal
  ./S03_04_demo_permissions.sh -t calculator   # Permissions calculator

═══════════════════════════════════════════════════════════════════════════════
EOF
}

#
# SETUP
#

setup_demo_environment() {
    print_subheader "Setup demonstration environment"
    
    echo -e "${CYAN}Creating structure in $DEMO_DIR...${NC}\n"
    
    # Create directories
    mkdir -p "$DEMO_DIR"/{public,private,scripts,shared,fix_me,audit_test}
    
    # Public files
    echo "Public document" > "$DEMO_DIR/public/readme.txt"
    echo "Another public file" > "$DEMO_DIR/public/info.txt"
    chmod 644 "$DEMO_DIR/public/"*
    
    # Private files
    echo "Secret API key: xyz123" > "$DEMO_DIR/private/secrets.txt"
    echo "Password: hunter2" > "$DEMO_DIR/private/credentials.txt"
    chmod 600 "$DEMO_DIR/private/"*
    
    # Scripts
    cat > "$DEMO_DIR/scripts/backup.sh" << 'SCRIPT'
#!/bin/bash
echo "Running backup..."
SCRIPT
    
    cat > "$DEMO_DIR/scripts/deploy.sh" << 'SCRIPT'
#!/bin/bash
echo "Deploying application..."
SCRIPT
    
    chmod 755 "$DEMO_DIR/scripts/"*.sh
    
    # Shared directory (for SGID demo)
    chmod 770 "$DEMO_DIR/shared"
    
    # Files with wrong permissions (for exercises)
    echo "Config file" > "$DEMO_DIR/fix_me/config.cfg"
    chmod 777 "$DEMO_DIR/fix_me/config.cfg"  # Too permissive!
    
    echo "Database backup" > "$DEMO_DIR/fix_me/backup.sql"
    chmod 666 "$DEMO_DIR/fix_me/backup.sql"  # Too permissive!
    
    cat > "$DEMO_DIR/fix_me/run.sh" << 'SCRIPT'
#!/bin/bash
echo "Running..."
SCRIPT
    chmod 644 "$DEMO_DIR/fix_me/run.sh"  # Not executable!
    
    # Files for audit
    touch "$DEMO_DIR/audit_test/normal.txt"
    chmod 644 "$DEMO_DIR/audit_test/normal.txt"
    
    touch "$DEMO_DIR/audit_test/world_writable.txt"
    chmod 666 "$DEMO_DIR/audit_test/world_writable.txt"
    
    echo -e "${GREEN}✓ Setup complete!${NC}"
}

cleanup_demo() {
    print_header "🧹 Cleanup"
    
    if [[ -d "$DEMO_DIR" ]]; then
        echo -e "${YELLOW}Deleting demo directory: $DEMO_DIR${NC}"
        rm -rf "$DEMO_DIR"
        echo -e "${GREEN}✓ Cleanup complete!${NC}"
    else
        echo -e "${GRAY}Demo directory does not exist.${NC}"
    fi
}

#
# SECTION 1: PERMISSIONS FUNDAMENTALS
#

section_1_fundamentals() {
    print_header "📚 SECTION 1: Permissions Fundamentals"
    
    print_concept "Each file has 3 sets of permissions: Owner, Group, Others"
    
    print_subheader "1.1 Permissions structure"
    
    cat << 'DIAGRAM'
╔═══════════════════════════════════════════════════════════════════════════════╗
║                    ls -l OUTPUT STRUCTURE                                     ║
╠═══════════════════════════════════════════════════════════════════════════════╣
║                                                                               ║
║      -rwxr-xr--  1  user  group  1234  Jan 15 10:30  file.txt                 ║
║      │└┬┘└┬┘└┬┘                                                               ║
║      │ │  │  └── Others (everyone else): r-- (read only)                      ║
║      │ │  └───── Group: r-x (read + execute)                                  ║
║      │ └──────── Owner (proprietor): rwx (all)                                ║
║      └────────── Type: - (file), d (directory), l (link)                      ║
║                                                                               ║
╠═══════════════════════════════════════════════════════════════════════════════╣
║ BIT MEANINGS:                                                                 ║
║                                                                               ║
║   r (read)    = Can read contents                                             ║
║   w (write)   = Can modify contents                                           ║
║   x (execute) = Can execute (file) or access (directory)                      ║
║   - (absent)  = Permission is not granted                                     ║
║                                                                               ║
╚═══════════════════════════════════════════════════════════════════════════════╝
DIAGRAM
    
    print_subheader "1.2 ⚠️ CRITICAL DIFFERENCE: File vs Directory Permissions"
    
    cat << 'DIFF'
╔═══════════════════════════════════════════════════════════════════════════════╗
║               ON FILE                        ON DIRECTORY                     ║
╠═══════════════════════════════════════════════════════════════════════════════╣
║                                                                               ║
║  r (read)    = read contents             r = list contents (ls)               ║
║                                                                               ║
║  w (write)   = modify contents           w = create/delete files inside       ║
║                                                                               ║
║  x (execute) = run as programme          x = can access (cd) the directory    ║
║                                              and files within it              ║
║                                                                               ║
╠═══════════════════════════════════════════════════════════════════════════════╣
║ ⚠️  x on DIRECTORY does not mean "execute the directory"!                     ║
║     It means you can ENTER and ACCESS the contents.                           ║
║                                                                               ║
║ ⚠️  To DELETE a file, you need w on the DIRECTORY,                            ║
║     not on the file! (w on file = modify contents)                            ║
║                                                                               ║
╚═══════════════════════════════════════════════════════════════════════════════╝
DIFF
    
    print_warning "Most common confusion: x on directory ≠ execution!"
    
    pause_interactive
}

#
# SECTION 2: VISUALISATION
#

section_2_visualization() {
    print_header "📚 SECTION 2: Visualisation and Interpretation"
    
    setup_demo_environment
    cd "$DEMO_DIR"
    
    print_subheader "2.1 Visualisation with ls -l"
    
    run_demo "ls -la" "Complete listing with permissions"
    
    print_subheader "2.2 Interpreting examples"
    
    echo ""
    echo "  ${WHITE}Let's analyse a few lines:${NC}"
    echo ""
    
    run_demo "ls -l scripts/backup.sh" ""
    echo ""
    echo "  -rwxr-xr-x"
    echo "  │└┬┘└┬┘└┬┘"
    echo "  │ │  │  └── others: r-x (read + execute)"
    echo "  │ │  └───── group:  r-x (read + execute)"
    echo "  │ └──────── owner:  rwx (all permissions)"
    echo "  └────────── regular file"
    echo ""
    echo "  → Anyone can run the script, but only the owner can modify it"
    
    run_demo "ls -l private/secrets.txt" ""
    echo ""
    echo "  -rw-------"
    echo "  │└┬┘└┬┘└┬┘"
    echo "  │ │  │  └── others: --- (nothing)"
    echo "  │ │  └───── group:  --- (nothing)"
    echo "  │ └──────── owner:  rw- (read + write)"
    echo "  └────────── regular file"
    echo ""
    echo "  → Only the owner can view/modify. Very private!"
    
    print_subheader "2.3 Visualisation with stat"
    
    run_demo "stat scripts/backup.sh" "Detailed information including octal permissions"
    
    print_tip "stat shows permissions in octal format too (Access: 0755)"
    
    pause_interactive
}

#
# SECTION 3: CHMOD OCTAL
#

section_3_chmod_octal() {
    print_header "📚 SECTION 3: chmod - Octal Mode"
    
    cd "$DEMO_DIR"
    
    print_concept "chmod NNN - sets permissions using octal numbers"
    
    print_subheader "3.1 Octal calculation"
    
    cat << 'CALC'
╔═══════════════════════════════════════════════════════════════════════════════╗
║                      OCTAL PERMISSIONS CALCULATION                            ║
╠═══════════════════════════════════════════════════════════════════════════════╣
║                                                                               ║
║   Each permission has a value:                                                ║
║                                                                               ║
║       r (read)    = 4                                                         ║
║       w (write)   = 2                                                         ║
║       x (execute) = 1                                                         ║
║       - (none)    = 0                                                         ║
║                                                                               ║
║   Add the values for each category:                                           ║
║                                                                               ║
║       rwx = 4+2+1 = 7                                                         ║
║       rw- = 4+2+0 = 6                                                         ║
║       r-x = 4+0+1 = 5                                                         ║
║       r-- = 4+0+0 = 4                                                         ║
║       --- = 0+0+0 = 0                                                         ║
║                                                                               ║
╠═══════════════════════════════════════════════════════════════════════════════╣
║   EXAMPLES:                                                                   ║
║                                                                               ║
║   755 = rwxr-xr-x  (owner: all, group: read+exec, others: read+exec)          ║
║   644 = rw-r--r--  (owner: read+write, rest: read only)                       ║
║   600 = rw-------  (only owner can read/write)                                ║
║   700 = rwx------  (only owner, all permissions)                              ║
║   750 = rwxr-x---  (owner: all, group: read+exec, others: nothing)            ║
║                                                                               ║
╚═══════════════════════════════════════════════════════════════════════════════╝
CALC
    
    print_subheader "3.2 Practical demonstration"
    
    # Create test file
    touch "$DEMO_DIR/test_perm.txt"
    echo "Test content" > "$DEMO_DIR/test_perm.txt"
    
    echo -e "\n${WHITE}Initial file:${NC}"
    run_demo "ls -l test_perm.txt" ""
    
    echo -e "\n${WHITE}chmod 644 (rw-r--r--):${NC}"
    run_demo "chmod 644 test_perm.txt && ls -l test_perm.txt" "Normal file, readable by all"
    
    echo -e "\n${WHITE}chmod 600 (rw-------):${NC}"
    run_demo "chmod 600 test_perm.txt && ls -l test_perm.txt" "Private file"
    
    echo -e "\n${WHITE}chmod 755 (rwxr-xr-x):${NC}"
    run_demo "chmod 755 test_perm.txt && ls -l test_perm.txt" "Executable by all"
    
    # Reference table
    print_subheader "3.3 Reference table"
    
    cat << 'TABLE'
╔════════╦════════════╦════════════════════════════════════════════════════════╗
║ Octal  ║ Symbolic   ║ Typical usage                                          ║
╠════════╬════════════╬════════════════════════════════════════════════════════╣
║  755   ║ rwxr-xr-x  ║ Directories, executable scripts                        ║
║  644   ║ rw-r--r--  ║ Text files, documents                                  ║
║  600   ║ rw-------  ║ Private files, SSH keys                                ║
║  700   ║ rwx------  ║ Private directories                                    ║
║  750   ║ rwxr-x---  ║ Directories shared with group                          ║
║  640   ║ rw-r-----  ║ Files shared with group                                ║
║  444   ║ r--r--r--  ║ Read-only files for everyone                           ║
║  400   ║ r--------  ║ Highly sensitive files (private keys)                  ║
╠════════╬════════════╬════════════════════════════════════════════════════════╣
║  777   ║ rwxrwxrwx  ║ ⚠️ NEVER! Security vulnerability!                      ║
║  666   ║ rw-rw-rw-  ║ ⚠️ Very rarely justified!                              ║
╚════════╩════════════╩════════════════════════════════════════════════════════╝
TABLE
    
    print_danger "chmod 777 is not a solution! Always find the MINIMUM necessary permissions."
    
    pause_interactive
}

#
# SECTION 4: CHMOD SYMBOLIC
#

section_4_chmod_symbolic() {
    print_header "📚 SECTION 4: chmod - Symbolic Mode"
    
    cd "$DEMO_DIR"
    
    print_concept "chmod [who][op][perm] - relative permission modification"
    
    print_subheader "4.1 Symbolic syntax"
    
    cat << 'SYNTAX'
╔═══════════════════════════════════════════════════════════════════════════════╗
║                          CHMOD SYMBOLIC SYNTAX                                ║
╠═══════════════════════════════════════════════════════════════════════════════╣
║                                                                               ║
║   chmod [WHO][OPERATOR][PERMISSION] file                                      ║
║                                                                               ║
║   WHO:                                                                        ║
║     u = user (owner)                                                          ║
║     g = group                                                                 ║
║     o = others                                                                ║
║     a = all (u+g+o)                                                           ║
║                                                                               ║
║   OPERATOR:                                                                   ║
║     + = add permission                                                        ║
║     - = remove permission                                                     ║
║     = = set exactly (removes the rest)                                        ║
║                                                                               ║
║   PERMISSION:                                                                 ║
║     r = read                                                                  ║
║     w = write                                                                 ║
║     x = execute                                                               ║
║     X = execute only if directory or already executable                       ║
║                                                                               ║
╚═══════════════════════════════════════════════════════════════════════════════╝
SYNTAX
    
    print_subheader "4.2 Demonstration"
    
    # Reset file
    chmod 644 "$DEMO_DIR/test_perm.txt"
    
    echo -e "\n${WHITE}Initial file (644):${NC}"
    run_demo "ls -l test_perm.txt" ""
    
    echo -e "\n${WHITE}u+x (add execute for owner):${NC}"
    run_demo "chmod u+x test_perm.txt && ls -l test_perm.txt" ""
    
    echo -e "\n${WHITE}g+w (add write for group):${NC}"
    run_demo "chmod g+w test_perm.txt && ls -l test_perm.txt" ""
    
    echo -e "\n${WHITE}o-r (remove read for others):${NC}"
    run_demo "chmod o-r test_perm.txt && ls -l test_perm.txt" ""
    
    echo -e "\n${WHITE}a=r (set only read for all):${NC}"
    run_demo "chmod a=r test_perm.txt && ls -l test_perm.txt" ""
    
    echo -e "\n${WHITE}u=rwx,g=rx,o= (complete setting):${NC}"
    run_demo "chmod u=rwx,g=rx,o= test_perm.txt && ls -l test_perm.txt" ""
    
    # Recursive chmod
    print_subheader "4.3 Recursive chmod and special X"
    
    echo ""
    echo "  ${WHITE}The problem with recursive chmod:${NC}"
    echo ""
    echo "  chmod -R 755 directory/"
    echo "  → Also sets FILES as executable (not what you want!)"
    echo ""
    echo "  ${WHITE}The solution: X (execute only for directories)${NC}"
    echo ""
    echo "  chmod -R u=rwX,g=rX,o=rX directory/"
    echo "  → X = execute only if directory or already executable"
    
    mkdir -p "$DEMO_DIR/recursive_test"/{subdir1,subdir2}
    touch "$DEMO_DIR/recursive_test/file1.txt"
    touch "$DEMO_DIR/recursive_test/subdir1/file2.txt"
    
    run_demo "find recursive_test -exec ls -ld {} \\;" "Before"
    
    run_demo "chmod -R u=rwX,g=rX,o=rX recursive_test" ""
    
    run_demo "find recursive_test -exec ls -ld {} \\;" "After: directories have x, files do not"
    
    print_tip "Use X for safe recursion!"
    
    pause_interactive
}

#
# SECTION 5: UMASK
#

section_5_umask() {
    print_header "📚 SECTION 5: umask - Default Permissions"
    
    cd "$DEMO_DIR"
    
    print_concept "umask REMOVES permissions from default, it does NOT set them!"
    
    print_warning "Most common confusion: umask does NOT set permissions, it REMOVES them!"
    
    print_subheader "5.1 How umask works"
    
    cat << 'UMASK'
╔═══════════════════════════════════════════════════════════════════════════════╗
║                           HOW UMASK WORKS                                     ║
╠═══════════════════════════════════════════════════════════════════════════════╣
║                                                                               ║
║   DEFAULT permissions:                                                        ║
║     Files:       666 (rw-rw-rw-)  - no execute by default                     ║
║     Directories: 777 (rwxrwxrwx) - with execute (access)                      ║
║                                                                               ║
║   umask REMOVES bits from default:                                            ║
║                                                                               ║
║     Final permissions = Default - umask                                       ║
║                                                                               ║
║   EXAMPLE with umask 022:                                                     ║
║     File:      666 - 022 = 644 (rw-r--r--)                                    ║
║     Directory: 777 - 022 = 755 (rwxr-xr-x)                                    ║
║                                                                               ║
║   EXAMPLE with umask 077:                                                     ║
║     File:      666 - 077 = 600 (rw-------)                                    ║
║     Directory: 777 - 077 = 700 (rwx------)                                    ║
║                                                                               ║
╠═══════════════════════════════════════════════════════════════════════════════╣
║   umask 022  → Removes w for group and others (standard)                      ║
║   umask 077  → Removes all for group and others (private)                     ║
║   umask 002  → Removes w only for others (group collaboration)                ║
║   umask 000  → Removes nothing (insecure!)                                    ║
╚═══════════════════════════════════════════════════════════════════════════════╝
UMASK
    
    print_subheader "5.2 Demonstration"
    
    echo -e "\n${WHITE}Current umask:${NC}"
    run_demo "umask" ""
    
    # Save original umask
    original_umask=$(umask)
    
    echo -e "\n${WHITE}With umask 022 (standard):${NC}"
    umask 022
    run_demo "touch umask_test_022.txt && ls -l umask_test_022.txt" "644 (666-022)"
    run_demo "mkdir umask_dir_022 && ls -ld umask_dir_022" "755 (777-022)"
    
    echo -e "\n${WHITE}With umask 077 (private):${NC}"
    umask 077
    run_demo "touch umask_test_077.txt && ls -l umask_test_077.txt" "600 (666-077)"
    run_demo "mkdir umask_dir_077 && ls -ld umask_dir_077" "700 (777-077)"
    
    echo -e "\n${WHITE}With umask 002 (collaborative group):${NC}"
    umask 002
    run_demo "touch umask_test_002.txt && ls -l umask_test_002.txt" "664 (666-002)"
    run_demo "mkdir umask_dir_002 && ls -ld umask_dir_002" "775 (777-002)"
    
    # Restore
    umask $original_umask
    
    print_subheader "5.3 umask in practice"
    
    echo ""
    echo "  ${WHITE}Where to set umask:${NC}"
    echo ""
    echo "  ~/.bashrc      - for interactive sessions"
    echo "  ~/.profile     - for login sessions"
    echo "  /etc/profile   - for all users"
    echo ""
    echo "  ${WHITE}Verification:${NC}"
    echo "  umask          - displays current value"
    echo "  umask -S       - displays in symbolic format"
    
    run_demo "umask -S" "Symbolic format"
    
    print_tip "umask 077 for sensitive data, umask 022 for general use"
    
    pause_interactive
}

#
# SECTION 6: SPECIAL PERMISSIONS
#

section_6_special() {
    print_header "📚 SECTION 6: Special Permissions"
    
    cd "$DEMO_DIR"
    
    print_concept "SUID, SGID, Sticky Bit - advanced permissions for special cases"
    
    print_subheader "6.1 SUID (Set User ID) - 4xxx"
    
    cat << 'SUID'
╔═══════════════════════════════════════════════════════════════════════════════╗
║                          SUID - SET USER ID                                   ║
╠═══════════════════════════════════════════════════════════════════════════════╣
║                                                                               ║
║   When set on an EXECUTABLE:                                                  ║
║   → The programme runs with the OWNER's permissions, not the executor's       ║
║                                                                               ║
║   Classic example: /usr/bin/passwd                                            ║
║   -rwsr-xr-x 1 root root ... /usr/bin/passwd                                  ║
║      ^                                                                        ║
║      └── 's' instead of 'x' = SUID active                                     ║
║                                                                               ║
║   A normal user can run passwd, but the programme runs as ROOT                ║
║   to be able to modify /etc/shadow                                            ║
║                                                                               ║
║   ⚠️ SUID on bash scripts does NOT work! (security measure)                   ║
║   ⚠️ SUID is a security risk - use with extreme caution!                      ║
║                                                                               ║
║   Setting: chmod 4755 file  or  chmod u+s file                                ║
║                                                                               ║
╚═══════════════════════════════════════════════════════════════════════════════╝
SUID
    
    echo -e "\n${WHITE}Examples from system:${NC}"
    run_demo "ls -l /usr/bin/passwd 2>/dev/null || ls -l /bin/passwd 2>/dev/null" "SUID on passwd"
    
    print_subheader "6.2 SGID (Set Group ID) - 2xxx"
    
    cat << 'SGID'
╔═══════════════════════════════════════════════════════════════════════════════╗
║                          SGID - SET GROUP ID                                  ║
╠═══════════════════════════════════════════════════════════════════════════════╣
║                                                                               ║
║   On EXECUTABLE: runs with the group's permissions                            ║
║                                                                               ║
║   On DIRECTORY (more useful!):                                                ║
║   → New files created inside INHERIT the directory's group                    ║
║   → Perfect for shared directories!                                           ║
║                                                                               ║
║   Visualisation: 's' in the group execute position                            ║
║   drwxrwsr-x  2 user team ... shared/                                         ║
║         ^                                                                     ║
║         └── SGID active                                                       ║
║                                                                               ║
║   Setting: chmod 2775 dir  or  chmod g+s dir                                  ║
║                                                                               ║
╚═══════════════════════════════════════════════════════════════════════════════╝
SGID
    
    echo -e "\n${WHITE}SGID demonstration on directory:${NC}"
    
    mkdir -p "$DEMO_DIR/sgid_demo"
    chmod 2775 "$DEMO_DIR/sgid_demo"
    
    run_demo "ls -ld sgid_demo" "Notice the 's' in group execute position"
    
    print_subheader "6.3 Sticky Bit - 1xxx"
    
    cat << 'STICKY'
╔═══════════════════════════════════════════════════════════════════════════════╗
║                          STICKY BIT                                           ║
╠═══════════════════════════════════════════════════════════════════════════════╣
║                                                                               ║
║   On DIRECTORY:                                                               ║
║   → Only the OWNER of a file can delete/rename it                             ║
║   → Even if the directory is writable by everyone!                            ║
║                                                                               ║
║   Classic example: /tmp                                                       ║
║   drwxrwxrwt  15 root root ... /tmp                                           ║
║            ^                                                                  ║
║            └── 't' = Sticky bit active                                        ║
║                                                                               ║
║   Without sticky: anyone can delete any file from /tmp                        ║
║   With sticky: you can only delete YOUR OWN files                             ║
║                                                                               ║
║   Setting: chmod 1777 dir  or  chmod +t dir                                   ║
║                                                                               ║
╚═══════════════════════════════════════════════════════════════════════════════╝
STICKY
    
    run_demo "ls -ld /tmp" "Notice the 't' at the end"
    
    print_subheader "6.4 Summary table"
    
    cat << 'SPECIAL'
╔════════════════╦═══════╦══════════════════════════════════════════════════════╗
║ Permission     ║ Octal ║ Effect                                               ║
╠════════════════╬═══════╬══════════════════════════════════════════════════════╣
║ SUID           ║ 4xxx  ║ Executable runs as owner                             ║
║ SGID on file   ║ 2xxx  ║ Executable runs as group                             ║
║ SGID on dir    ║ 2xxx  ║ New files inherit the directory's group              ║
║ Sticky         ║ 1xxx  ║ Only owner can delete files in directory             ║
╠════════════════╬═══════╬══════════════════════════════════════════════════════╣
║ SUID + SGID    ║ 6xxx  ║ Both (rare)                                          ║
║ SUID + Sticky  ║ 5xxx  ║ Both (rare)                                          ║
║ SGID + Sticky  ║ 3xxx  ║ Both (protected shared folder)                       ║
║ All three      ║ 7xxx  ║ All three (very rare)                                ║
╚════════════════╩═══════╩══════════════════════════════════════════════════════╝
SPECIAL
    
    print_warning "SUID/SGID on executables are potential vulnerabilities! Audit them regularly."
    
    pause_interactive
}

#
# SECTION 7: CHOWN AND CHGRP
#

section_7_ownership() {
    print_header "📚 SECTION 7: chown and chgrp"
    
    cd "$DEMO_DIR"
    
    print_concept "Changing file owner and group"
    
    print_subheader "7.1 chown syntax"
    
    cat << 'CHOWN'
╔═══════════════════════════════════════════════════════════════════════════════╗
║                              CHOWN SYNTAX                                     ║
╠═══════════════════════════════════════════════════════════════════════════════╣
║                                                                               ║
║   chown USER file              # Change only owner                            ║
║   chown USER:GROUP file        # Change owner and group                       ║
║   chown :GROUP file            # Change only group                            ║
║   chown USER: file             # Change owner, group becomes primary group    ║
║                                                                               ║
║   Options:                                                                    ║
║     -R        Recursive                                                       ║
║     -v        Verbose                                                         ║
║     --from=   Change only if current owner/group matches                      ║
║                                                                               ║
║   ⚠️ Usually requires sudo (only root can change owner)                       ║
║                                                                               ║
╚═══════════════════════════════════════════════════════════════════════════════╝
CHOWN
    
    echo ""
    echo "  ${WHITE}Examples (require sudo):${NC}"
    echo ""
    print_command "sudo chown john file.txt"
    echo "  → Owner becomes john"
    echo ""
    print_command "sudo chown john:developers file.txt"
    echo "  → Owner becomes john, group becomes developers"
    echo ""
    print_command "sudo chown -R www-data:www-data /var/www"
    echo "  → Changes recursively for web server"
    
    print_subheader "7.2 chgrp - Change group"
    
    echo ""
    echo "  ${WHITE}Syntax:${NC}"
    echo ""
    print_command "chgrp GROUP file"
    echo ""
    echo "  ${WHITE}Note:${NC} You can change the group to a group you belong to,"
    echo "  without sudo (if you are the file's owner)."
    
    run_demo "groups" "Your groups"
    
    print_tip "Use chown user:group to set both in a single command"
    
    pause_interactive
}

#
# SECTION 8: BEST PRACTICES AND AUDIT
#

section_8_security() {
    print_header "📚 SECTION 8: Best Practices and Security Audit"
    
    cd "$DEMO_DIR"
    
    print_concept "Security through correct permissions"
    
    print_subheader "8.1 Basic principles"
    
    cat << 'PRINCIPLES'
╔═══════════════════════════════════════════════════════════════════════════════╗
║                    PERMISSIONS SECURITY PRINCIPLES                            ║
╠═══════════════════════════════════════════════════════════════════════════════╣
║                                                                               ║
║   1. LEAST PRIVILEGE                                                          ║
║      Grant the MINIMUM permissions necessary for operation.                   ║
║      Better to add permissions than remove them after an incident.            ║
║                                                                               ║
║   2. NO chmod 777!                                                            ║
║      If you need 777, reconsider the architecture.                            ║
║      Ask yourself: "Who exactly needs access?"                                ║
║                                                                               ║
║   3. GROUPS FOR COLLABORATION                                                 ║
║      Use groups for shared access, not world-writable.                        ║
║      Create specific groups for projects.                                     ║
║                                                                               ║
║   4. REGULAR AUDIT                                                            ║
║      Periodically check SUID/SGID and world-writable files.                   ║
║      Log permission changes in production.                                    ║
║                                                                               ║
║   5. SEPARATION OF RESPONSIBILITIES                                           ║
║      Data and configurations: 600 or 640                                      ║
║      Scripts: 750 or 755 (but no write for group/others)                      ║
║      Shared directories: 2775 (SGID)                                          ║
║                                                                               ║
╚═══════════════════════════════════════════════════════════════════════════════╝
PRINCIPLES
    
    print_subheader "8.2 Audit: Find security problems"
    
    echo -e "\n${WHITE}Find world-writable files:${NC}"
    run_demo "find . -type f -perm -o=w -ls 2>/dev/null" "Everyone can write!"
    
    echo -e "\n${WHITE}Find world-writable directories (without sticky):${NC}"
    run_demo "find . -type d -perm -o=w ! -perm -1000 -ls 2>/dev/null" "Risk: anyone can delete anything"
    
    echo -e "\n${WHITE}Find SUID files:${NC}"
    run_demo "find /usr/bin -type f -perm -4000 -ls 2>/dev/null | head -5" "Runs as owner"
    
    echo -e "\n${WHITE}Find SGID files:${NC}"
    run_demo "find /usr/bin -type f -perm -2000 -ls 2>/dev/null | head -5" "Runs as group"
    
    print_subheader "8.3 Exercise: Fix fix_me/"
    
    echo -e "\n${WHITE}Problematic permissions in fix_me/:${NC}"
    run_demo "ls -la fix_me/" ""
    
    echo ""
    echo "  ${WHITE}Problems identified:${NC}"
    echo "  • config.cfg: 777 - far too permissive for config!"
    echo "  • backup.sql: 666 - sensitive data world-writable!"
    echo "  • run.sh: 644 - script not executable!"
    echo ""
    echo "  ${WHITE}Solutions:${NC}"
    
    print_command "chmod 640 fix_me/config.cfg   # Only owner and group"
    print_command "chmod 600 fix_me/backup.sql   # Only owner"
    print_command "chmod 750 fix_me/run.sh       # Executable for owner and group"
    
    # Actually fix them
    chmod 640 "$DEMO_DIR/fix_me/config.cfg"
    chmod 600 "$DEMO_DIR/fix_me/backup.sql"
    chmod 750 "$DEMO_DIR/fix_me/run.sh"
    
    echo -e "\n${WHITE}After correction:${NC}"
    run_demo "ls -la fix_me/" ""
    
    print_tip "Create an audit script and run it periodically in production!"
    
    pause_interactive
}

#
# TOOL: PERMISSIONS CALCULATOR
#

tool_calculator() {
    print_header "🧮 Permissions Calculator"
    
    echo ""
    echo "  ${WHITE}Enter octal or symbolic permissions for conversion${NC}"
    echo "  Examples: 755, rw-r--r--, u=rwx,g=rx,o=rx"
    echo "  Type 'q' to exit"
    echo ""
    
    while true; do
        echo -n -e "${CYAN}Permissions> ${NC}"
        read -r input
        
        [[ "$input" == "q" || "$input" == "quit" ]] && break
        [[ -z "$input" ]] && continue
        
        # Check if octal (3-4 digits)
        if [[ "$input" =~ ^[0-7]{3,4}$ ]]; then
            # Octal to symbolic
            local octal="$input"
            [[ ${#octal} -eq 3 ]] && octal="0$octal"
            
            local special="${octal:0:1}"
            local owner="${octal:1:1}"
            local group="${octal:2:1}"
            local others="${octal:3:1}"
            
            octal_to_symbolic() {
                local n=$1
                local r='-' w='-' x='-'
                (( n & 4 )) && r='r'
                (( n & 2 )) && w='w'
                (( n & 1 )) && x='x'
                echo "$r$w$x"
            }
            
            local owner_sym=$(octal_to_symbolic $owner)
            local group_sym=$(octal_to_symbolic $group)
            local others_sym=$(octal_to_symbolic $others)
            
            # Handle special bits
            if (( special & 4 )); then
                [[ "${owner_sym:2:1}" == "x" ]] && owner_sym="${owner_sym:0:2}s" || owner_sym="${owner_sym:0:2}S"
            fi
            if (( special & 2 )); then
                [[ "${group_sym:2:1}" == "x" ]] && group_sym="${group_sym:0:2}s" || group_sym="${group_sym:0:2}S"
            fi
            if (( special & 1 )); then
                [[ "${others_sym:2:1}" == "x" ]] && others_sym="${others_sym:0:2}t" || others_sym="${others_sym:0:2}T"
            fi
            
            echo ""
            echo "  Octal:    $input"
            echo "  Symbolic: ${owner_sym}${group_sym}${others_sym}"
            echo ""
            echo "  Owner:  ${owner_sym} ($(octal_to_symbolic $owner))"
            echo "  Group:  ${group_sym} ($(octal_to_symbolic $group))"
            echo "  Others: ${others_sym} ($(octal_to_symbolic $others))"
            
            [[ "$special" != "0" ]] && echo "  Special bits: $special"
            
        elif [[ "$input" =~ ^[rwx-]{9}$ ]]; then
            # Simple symbolic to octal
            symbolic_to_octal() {
                local sym="$1"
                local n=0
                [[ "${sym:0:1}" == "r" ]] && (( n += 4 ))
                [[ "${sym:1:1}" == "w" ]] && (( n += 2 ))
                [[ "${sym:2:1}" == "x" || "${sym:2:1}" == "s" || "${sym:2:1}" == "t" ]] && (( n += 1 ))
                echo $n
            }
            
            local o=$(symbolic_to_octal "${input:0:3}")
            local g=$(symbolic_to_octal "${input:3:3}")
            local t=$(symbolic_to_octal "${input:6:3}")
            
            local special=0
            [[ "${input:2:1}" =~ [sS] ]] && (( special += 4 ))
            [[ "${input:5:1}" =~ [sS] ]] && (( special += 2 ))
            [[ "${input:8:1}" =~ [tT] ]] && (( special += 1 ))
            
            echo ""
            echo "  Symbolic: $input"
            if [[ $special -eq 0 ]]; then
                echo "  Octal:    ${o}${g}${t}"
            else
                echo "  Octal:    ${special}${o}${g}${t}"
            fi
            
        else
            echo -e "  ${RED}Unrecognised format. Use: 755 or rwxr-xr-x${NC}"
        fi
        
        echo ""
    done
}

#
# TOOL: VISUALIZER
#

tool_visualizer() {
    print_header "👁️ Permissions Visualiser"
    
    echo ""
    echo "  ${WHITE}Enter the path to a file or directory${NC}"
    echo "  Type 'q' to exit"
    echo ""
    
    while true; do
        echo -n -e "${CYAN}Path> ${NC}"
        read -r path
        
        [[ "$path" == "q" || "$path" == "quit" ]] && break
        [[ -z "$path" ]] && continue
        
        if [[ ! -e "$path" ]]; then
            echo -e "  ${RED}Path does not exist: $path${NC}"
            continue
        fi
        
        local perms=$(stat -c '%a' "$path")
        local perms_symbolic=$(stat -c '%A' "$path")
        local owner=$(stat -c '%U' "$path")
        local group=$(stat -c '%G' "$path")
        local type=$(stat -c '%F' "$path")
        
        echo ""
        echo "╔════════════════════════════════════════════════════════════════════╗"
        printf "║ Path: %-58s ║\n" "$path"
        echo "╠════════════════════════════════════════════════════════════════════╣"
        printf "║ Type:        %-52s ║\n" "$type"
        printf "║ Owner:       %-52s ║\n" "$owner"
        printf "║ Group:       %-52s ║\n" "$group"
        printf "║ Permissions: %-4s (%s)                                       ║\n" "$perms" "$perms_symbolic"
        echo "╠════════════════════════════════════════════════════════════════════╣"
        
        # Graphical visualisation
        echo "║                                                                    ║"
        echo "║  Owner     Group     Others                                        ║"
        echo "║  ┌───┐     ┌───┐     ┌───┐                                         ║"
        
        for i in 0 1 2; do
            case $i in
                0) perm="r"; pos=0 ;;
                1) perm="w"; pos=1 ;;
                2) perm="x"; pos=2 ;;
            esac
            
            o_perm="${perms_symbolic:$((pos+1)):1}"
            g_perm="${perms_symbolic:$((pos+4)):1}"
            t_perm="${perms_symbolic:$((pos+7)):1}"
            
            [[ "$o_perm" != "-" ]] && o_color="${GREEN}$o_perm${NC}" || o_color="${RED}-${NC}"
            [[ "$g_perm" != "-" ]] && g_color="${GREEN}$g_perm${NC}" || g_color="${RED}-${NC}"
            [[ "$t_perm" != "-" ]] && t_color="${GREEN}$t_perm${NC}" || t_color="${RED}-${NC}"
            
            echo -e "║  │ $o_color │     │ $g_color │     │ $t_color │                                         ║"
        done
        
        echo "║  └───┘     └───┘     └───┘                                         ║"
        echo "║                                                                    ║"
        echo "╚════════════════════════════════════════════════════════════════════╝"
        echo ""
    done
}

#
# TOOL: AUDIT
#

tool_audit() {
    local target="${1:-.}"
    
    print_header "🔍 Security Audit: $target"
    
    echo ""
    echo -e "${WHITE}Scanning for security issues...${NC}"
    echo ""
    
    local issues=0
    
    # World-writable files
    echo -e "${YELLOW}► World-writable files:${NC}"
    local ww_files=$(find "$target" -type f -perm -o=w 2>/dev/null)
    if [[ -n "$ww_files" ]]; then
        echo "$ww_files" | while read f; do
            echo -e "  ${RED}⚠${NC} $f"
            ((issues++))
        done
    else
        echo -e "  ${GREEN}✓ None found${NC}"
    fi
    
    echo ""
    
    # World-writable directories without sticky
    echo -e "${YELLOW}► World-writable directories without sticky bit:${NC}"
    local ww_dirs=$(find "$target" -type d -perm -o=w ! -perm -1000 2>/dev/null)
    if [[ -n "$ww_dirs" ]]; then
        echo "$ww_dirs" | while read d; do
            echo -e "  ${RED}⚠${NC} $d"
            ((issues++))
        done
    else
        echo -e "  ${GREEN}✓ None found${NC}"
    fi
    
    echo ""
    
    # SUID files (outside standard locations)
    echo -e "${YELLOW}► SUID files:${NC}"
    local suid_files=$(find "$target" -type f -perm -4000 2>/dev/null | grep -v "^/usr\|^/bin\|^/sbin")
    if [[ -n "$suid_files" ]]; then
        echo "$suid_files" | while read f; do
            echo -e "  ${YELLOW}!${NC} $f (verify if necessary)"
            ((issues++))
        done
    else
        echo -e "  ${GREEN}✓ None in non-standard locations${NC}"
    fi
    
    echo ""
    
    # Files with 777
    echo -e "${YELLOW}► Files with 777 permissions:${NC}"
    local full_perm=$(find "$target" -type f -perm 777 2>/dev/null)
    if [[ -n "$full_perm" ]]; then
        echo "$full_perm" | while read f; do
            echo -e "  ${RED}☠${NC} $f - CRITICAL!"
            ((issues++))
        done
    else
        echo -e "  ${GREEN}✓ None found${NC}"
    fi
    
    echo ""
    echo "════════════════════════════════════════════════════════════════════════"
    
    if [[ $issues -eq 0 ]]; then
        echo -e "${GREEN}✓ Audit complete. No issues identified.${NC}"
    else
        echo -e "${YELLOW}⚠ Audit complete. Potential issues found.${NC}"
    fi
    
    echo ""
}

#
# SUMMARY
#

show_summary() {
    print_header "📋 SUMMARY: Unix Permissions"
    
    cat << 'SUMMARY'
╔═══════════════════════════════════════════════════════════════════════════════╗
║                          QUICK CHEAT SHEET                                    ║
╠═══════════════════════════════════════════════════════════════════════════════╣
║ OCTAL PERMISSIONS:                                                            ║
║   r=4, w=2, x=1    755=rwxr-xr-x   644=rw-r--r--   600=rw-------              ║
║                                                                               ║
║ CHMOD:                                                                        ║
║   chmod 755 file         # Octal                                              ║
║   chmod u+x file         # Add execute for owner                              ║
║   chmod g-w file         # Remove write for group                             ║
║   chmod a=r file         # Set only read for all                              ║
║   chmod -R u=rwX dir/    # Recursive, X=exec only for dirs                    ║
║                                                                               ║
║ UMASK:                                                                        ║
║   umask 022              # Standard: files 644, dirs 755                      ║
║   umask 077              # Private: files 600, dirs 700                       ║
║                                                                               ║
║ OWNERSHIP:                                                                    ║
║   chown user file        # Change owner                                       ║
║   chown user:group file  # Change owner and group                             ║
║   chgrp group file       # Change only group                                  ║
║                                                                               ║
║ SPECIAL PERMISSIONS:                                                          ║
║   chmod 4755 file        # SUID (runs as owner)                               ║
║   chmod 2775 dir         # SGID (group inheritance)                           ║
║   chmod 1777 dir         # Sticky (only owner deletes)                        ║
║                                                                               ║
║ AUDIT:                                                                        ║
║   find . -perm -o=w      # World-writable                                     ║
║   find . -perm -4000     # SUID                                               ║
║   find . -perm 777       # Too permissive!                                    ║
║                                                                               ║
╠═══════════════════════════════════════════════════════════════════════════════╣
║ ⚠️  NEVER chmod 777!  Find the MINIMUM necessary permissions.                 ║
╚═══════════════════════════════════════════════════════════════════════════════╝
SUMMARY
    
    echo ""
    echo -e "${GREEN}✓ Demo complete!${NC}"
    echo ""
    echo -e "Available tools:"
    echo -e "  ${CYAN}./S03_04_demo_permissions.sh -t calculator${NC}  - Permissions calculator"
    echo -e "  ${CYAN}./S03_04_demo_permissions.sh -t visualizer${NC}  - Visualiser"
    echo -e "  ${CYAN}./S03_04_demo_permissions.sh -t audit${NC}       - Security audit"
    echo ""
}

#
# MAIN
#

parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                show_usage
                exit 0
                ;;
            -i|--interactive)
                INTERACTIVE=true
                shift
                ;;
            -s|--section)
                RUN_SECTION="$2"
                shift 2
                ;;
            -c|--cleanup)
                cleanup_demo
                exit 0
                ;;
            -t|--tool)
                TOOL_NAME="$2"
                shift 2
                ;;
            *)
                echo -e "${RED}Unknown option: $1${NC}"
                show_usage
                exit 1
                ;;
        esac
    done
}

main() {
    parse_args "$@"
    
    # Run specific tool
    if [[ -n "$TOOL_NAME" ]]; then
        case "$TOOL_NAME" in
            calculator|calc) tool_calculator ;;
            visualizer|viz) tool_visualizer ;;
            audit) tool_audit "${DEMO_DIR:-.}" ;;
            *)
                echo -e "${RED}Unknown tool: $TOOL_NAME${NC}"
                exit 1
                ;;
        esac
        exit 0
    fi
    
    # Run specific section
    if [[ -n "$RUN_SECTION" ]]; then
        case "$RUN_SECTION" in
            1) section_1_fundamentals ;;
            2) section_2_visualization ;;
            3) section_3_chmod_octal ;;
            4) section_4_chmod_symbolic ;;
            5) section_5_umask ;;
            6) section_6_special ;;
            7) section_7_ownership ;;
            8) section_8_security ;;
            *)
                echo -e "${RED}Invalid section: $RUN_SECTION${NC}"
                exit 1
                ;;
        esac
    else
        # Run all
        section_1_fundamentals
        section_2_visualization
        section_3_chmod_octal
        section_4_chmod_symbolic
        section_5_umask
        section_6_special
        section_7_ownership
        section_8_security
    fi
    
    show_summary
}

main "$@"
