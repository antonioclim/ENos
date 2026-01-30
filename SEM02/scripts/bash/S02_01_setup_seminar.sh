#!/bin/bash
#
# S02_01_setup_seminar.sh - Setup and Environment Verification for Seminar 3-4
#
#
# DESCRIPTION:
#   This script verifies and prepares the environment for the OS seminar.
#   It checks versions, installs optional dependencies, creates working
#   directories and generates test files.
#
# USAGE:
#   chmod +x S02_01_setup_seminar.sh
#   ./S02_01_setup_seminar.sh [options]
#
# OPTIONS:
#   --check-only    Only verify, do not install anything
#   --install       Install missing dependencies (requires sudo)
#   --wsl           Mode for Windows Subsystem for Linux
#   --help          Display this message
#
# AUTHOR: OS Course Materials ASE-CSIE
# VERSION: 1.0
#

set -euo pipefail

#
# CONFIGURATION
#

# Colours
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[1;36m'
NC='\033[0m'
BOLD='\033[1m'

# Directories
WORK_DIR="${HOME}/seminar_so"
DEMO_DIR="${WORK_DIR}/demo"
TEST_DIR="${WORK_DIR}/test_files"

# Required dependencies
REQUIRED_CMDS=(bash sort uniq cut head tail tr wc cat echo)

# Optional dependencies (for spectacular demos)
OPTIONAL_CMDS=(figlet lolcat cowsay fortune pv dialog tree ncdu htop bc jq)

# Minimum versions
MIN_BASH_VERSION="4.0"
MIN_PYTHON_VERSION="3.8"

#
# HELPER FUNCTIONS
#

print_header() {
    echo -e "\n${CYAN}═══════════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}   $1${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════════${NC}\n"
}

print_section() {
    echo -e "\n${YELLOW}▸ $1${NC}\n"
}

ok() {
    echo -e "  ${GREEN}✓${NC} $1"
}

warn() {
    echo -e "  ${YELLOW}⚠${NC} $1"
}

fail() {
    echo -e "  ${RED}✗${NC} $1"
}

info() {
    echo -e "  ${BLUE}ℹ${NC} $1"
}

cmd_exists() {
    command -v "$1" &>/dev/null
}

version_ge() {
    # Compare versions: version_ge "4.4" "4.0" returns 0 (true)
    printf '%s\n%s' "$2" "$1" | sort -V -C
}

#
# VERSION VERIFICATION
#

check_bash_version() {
    print_section "Checking Bash Version"
    
    local bash_version="${BASH_VERSION%%(*}"
    bash_version="${bash_version%.*}"
    
    if version_ge "$bash_version" "$MIN_BASH_VERSION"; then
        ok "Bash $BASH_VERSION (minimum: $MIN_BASH_VERSION)"
        return 0
    else
        fail "Bash $BASH_VERSION - version too old (minimum: $MIN_BASH_VERSION)"
        return 1
    fi
}

check_python_version() {
    print_section "Checking Python"
    
    if ! cmd_exists python3; then
        warn "Python3 is not installed (optional for autograder)"
        return 0
    fi
    
    local py_version
    py_version=$(python3 -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")')
    
    if version_ge "$py_version" "$MIN_PYTHON_VERSION"; then
        ok "Python $py_version (minimum: $MIN_PYTHON_VERSION)"
    else
        warn "Python $py_version - recommended $MIN_PYTHON_VERSION+"
    fi
}

check_os() {
    print_section "Checking Operating System"
    
    if [[ -f /etc/os-release ]]; then
        source /etc/os-release
        ok "$NAME $VERSION_ID"
        
        if [[ "$ID" == "ubuntu" ]]; then
            local major_version="${VERSION_ID%%.*}"
            if [[ "$major_version" -lt 22 ]]; then
                warn "Recommended Ubuntu 22.04+ (you have $VERSION_ID)"
            fi
        fi
    else
        warn "Cannot determine operating system"
    fi
    
    # Detect WSL
    if grep -qi microsoft /proc/version 2>/dev/null; then
        info "Running in WSL (Windows Subsystem for Linux)"
        WSL_MODE=1
    else
        WSL_MODE=0
    fi
}

#
# DEPENDENCY VERIFICATION
#

check_required_commands() {
    print_section "Checking Required Commands"
    
    local missing=()
    
    for cmd in "${REQUIRED_CMDS[@]}"; do
        if cmd_exists "$cmd"; then
            ok "$cmd"
        else
            fail "$cmd - MISSING!"
            missing+=("$cmd")
        fi
    done
    
    if [[ ${#missing[@]} -gt 0 ]]; then
        fail "Missing required commands: ${missing[*]}"
        return 1
    fi
    
    return 0
}

check_optional_commands() {
    print_section "Checking Optional Commands (for demos)"
    
    local missing=()
    
    for cmd in "${OPTIONAL_CMDS[@]}"; do
        if cmd_exists "$cmd"; then
            ok "$cmd"
        else
            warn "$cmd - missing (optional)"
            missing+=("$cmd")
        fi
    done
    
    if [[ ${#missing[@]} -gt 0 ]]; then
        echo ""
        info "To install optional commands:"
        echo -e "     ${GREEN}sudo apt install ${missing[*]}${NC}"
    fi
}

#
# CREATE DIRECTORY STRUCTURE
#

create_directories() {
    print_section "Creating Working Directories"
    
    local dirs=("$WORK_DIR" "$DEMO_DIR" "$TEST_DIR")
    
    for dir in "${dirs[@]}"; do
        if [[ -d "$dir" ]]; then
            ok "$dir (exists)"
        else
            mkdir -p "$dir"
            ok "$dir (created)"
        fi
    done
}

#
# GENERATE TEST FILES
#

create_test_files() {
    print_section "Generating Test Files"
    
    # File for sort/uniq tests
    cat > "${TEST_DIR}/colors.txt" << 'EOF'
red
green
blue
red
yellow
green
red
orange
blue
green
EOF
    ok "colors.txt (for sort/uniq)"
    
    # CSV file for cut/awk tests
    cat > "${TEST_DIR}/students.csv" << 'EOF'
name,age,grade,group
Popescu Ion,21,9,1234
Ionescu Maria,22,10,1234
Georgescu Ana,20,8,1235
Vasilescu Dan,23,7,1235
Marinescu Elena,21,9,1234
Dumitrescu Alex,22,8,1236
EOF
    ok "students.csv (for cut/paste)"
    
    # File for head/tail tests
    seq 1 100 > "${TEST_DIR}/numbers.txt"
    ok "numbers.txt (for head/tail)"
    
    # File with text for wc/tr
    cat > "${TEST_DIR}/text.txt" << 'EOF'
This is a test sentence.
It has multiple lines.
And special characters: !@#$%
    And lines with indentation.

And an empty line above.
EOF
    ok "text.txt (for wc/tr)"
    
    # Simulated log file for exercises
    cat > "${TEST_DIR}/access.log" << 'EOF'
192.168.1.1 - - [01/Jan/2025:10:00:00] "GET /index.html HTTP/1.1" 200 1234
192.168.1.2 - - [01/Jan/2025:10:00:01] "GET /about.html HTTP/1.1" 200 2345
192.168.1.1 - - [01/Jan/2025:10:00:02] "GET /contact.html HTTP/1.1" 404 567
10.0.0.5 - - [01/Jan/2025:10:00:03] "POST /login HTTP/1.1" 200 890
192.168.1.3 - - [01/Jan/2025:10:00:04] "GET /admin HTTP/1.1" 403 432
192.168.1.1 - - [01/Jan/2025:10:00:05] "GET /style.css HTTP/1.1" 200 5678
10.0.0.5 - - [01/Jan/2025:10:00:06] "GET /dashboard HTTP/1.1" 200 3456
192.168.1.2 - - [01/Jan/2025:10:00:07] "GET /api/data HTTP/1.1" 500 123
192.168.1.4 - - [01/Jan/2025:10:00:08] "GET /index.html HTTP/1.1" 200 1234
192.168.1.1 - - [01/Jan/2025:10:00:09] "GET /images/logo.png HTTP/1.1" 200 9876
EOF
    ok "access.log (for pipeline exercises)"
    
    # Test script for loop exercises
    cat > "${TEST_DIR}/test_script.sh" << 'EOF'
#!/bin/bash
# Test script for exercises

echo "Argument received: $1"
sleep 1
echo "Processing complete"
exit 0
EOF
    chmod +x "${TEST_DIR}/test_script.sh"
    ok "test_script.sh (for loop exercises)"
    
    echo ""
    info "Files created in: $TEST_DIR"
}

#
# INSTALL DEPENDENCIES
#

install_dependencies() {
    print_section "Installing Optional Dependencies"
    
    if [[ $EUID -ne 0 ]] && ! sudo -n true 2>/dev/null; then
        warn "Requires sudo for installation. Run with sudo or --check-only"
        return 1
    fi
    
    info "Updating package lists..."
    sudo apt update -qq
    
    local to_install=()
    for cmd in "${OPTIONAL_CMDS[@]}"; do
        if ! cmd_exists "$cmd"; then
            # Map command -> package (some differ)
            case "$cmd" in
                lolcat) to_install+=("lolcat") ;;
                ncdu)   to_install+=("ncdu") ;;
                *)      to_install+=("$cmd") ;;
            esac
        fi
    done
    
    if [[ ${#to_install[@]} -gt 0 ]]; then
        info "Installing: ${to_install[*]}"
        sudo apt install -y "${to_install[@]}"
        ok "Installation complete"
    else
        ok "All dependencies are already installed"
    fi
}

#
# DISPLAY SUMMARY
#

show_summary() {
    print_header "SETUP SUMMARY"
    
    echo -e "${GREEN}✓ Environment is ready for the seminar!${NC}"
    echo ""
    echo -e "Working directory: ${CYAN}$WORK_DIR${NC}"
    echo -e "Test files:        ${CYAN}$TEST_DIR${NC}"
    echo ""
    echo -e "Useful commands:"
    echo -e "  ${GREEN}cd $WORK_DIR${NC}      # go to working directory"
    echo -e "  ${GREEN}ls $TEST_DIR${NC}      # see test files"
    echo ""
    
    if [[ -d "$(dirname "$0")/../demo" ]]; then
        echo -e "Available demos:"
        echo -e "  ${GREEN}./scripts/demo/S02_01_hook_demo.sh${NC}"
        echo ""
    fi
}

#
# HELP
#

show_help() {
    cat << EOF
${BOLD}S02_01_setup_seminar.sh${NC} - OS Seminar Environment Setup

${YELLOW}USAGE:${NC}
    ./S02_01_setup_seminar.sh [options]

${YELLOW}OPTIONS:${NC}
    --check-only    Only verify, do not install or create files
    --install       Install missing dependencies (requires sudo)
    --wsl           Mode for Windows Subsystem for Linux
    --help, -h      Display this message

${YELLOW}EXAMPLES:${NC}
    ./S02_01_setup_seminar.sh                  # Standard setup
    ./S02_01_setup_seminar.sh --check-only     # Verification only
    sudo ./S02_01_setup_seminar.sh --install   # With package installation

${YELLOW}WORKING DIRECTORY:${NC}
    $WORK_DIR

EOF
}

#
# MAIN
#

main() {
    local check_only=0
    local do_install=0
    local wsl_mode=0
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --check-only)
                check_only=1
                shift
                ;;
            --install)
                do_install=1
                shift
                ;;
            --wsl)
                wsl_mode=1
                shift
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            *)
                echo "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    print_header "SETUP SEMINAR 3-4: Operating Systems"
    
    # Required checks
    check_os
    check_bash_version || exit 1
    check_required_commands || exit 1
    
    # Optional checks
    check_python_version
    check_optional_commands
    
    # Actions (if not check-only)
    if [[ $check_only -eq 0 ]]; then
        create_directories
        create_test_files
        
        if [[ $do_install -eq 1 ]]; then
            install_dependencies
        fi
        
        show_summary
    else
        print_header "VERIFICATION COMPLETE"
        echo -e "${GREEN}✓ All checks passed!${NC}"
    fi
}

# Run
main "$@"
