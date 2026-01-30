#!/bin/bash
#===============================================================================
# verify_installation.sh — Installation Verification for OS Course
#===============================================================================
# Usage: bash verify_installation.sh
# 
# This script checks that your Ubuntu environment is correctly configured
# for the Operating Systems course at ASE Bucharest - CSIE.
#
# Version: 2.1 | January 2025
# Author: ing. dr. Antonio Clim
#===============================================================================

set -uo pipefail

#-------------------------------------------------------------------------------
# Colour definitions for output
#-------------------------------------------------------------------------------
readonly GREEN='\033[0;32m'
readonly RED='\033[0;31m'
readonly YELLOW='\033[1;33m'
readonly CYAN='\033[0;36m'
readonly BOLD='\033[1m'
readonly NC='\033[0m'  # No colour

#-------------------------------------------------------------------------------
# Counters for summary
#-------------------------------------------------------------------------------
PASSED=0
FAILED=0
WARNINGS=0

#-------------------------------------------------------------------------------
# Helper functions
#-------------------------------------------------------------------------------
print_ok() {
    echo -e "  ${GREEN}[OK]${NC} $1"
    ((PASSED++))
}

print_fail() {
    echo -e "  ${RED}[FAIL]${NC} $1"
    ((FAILED++))
}

print_warn() {
    echo -e "  ${YELLOW}[WARN]${NC} $1"
    ((WARNINGS++))
}

print_info() {
    echo -e "  ${CYAN}[INFO]${NC} $1"
}

print_header() {
    echo ""
    echo -e "${BOLD}========================================${NC}"
    echo -e "${BOLD}   INSTALLATION VERIFICATION - OS ASE${NC}"
    echo -e "${BOLD}========================================${NC}"
    echo ""
}

print_section() {
    echo ""
    echo -e "${BOLD}>>> $1${NC}"
}

#-------------------------------------------------------------------------------
# Check: System information
#-------------------------------------------------------------------------------
check_system_info() {
    print_section "System Information"
    
    local hostname_val
    hostname_val=$(hostname 2>/dev/null || echo "unknown")
    echo "  Hostname: ${hostname_val}"
    
    # Validate hostname format (INITIALS_GROUP_SERIES)
    if [[ "$hostname_val" =~ ^[A-Z]{2,4}_[0-9]{4}_[A-Z]$ ]]; then
        print_ok "Hostname format is correct"
    else
        print_warn "Hostname format may be incorrect (expected: AP_1001_A)"
    fi
    
    local user_val
    user_val=$(whoami 2>/dev/null || echo "unknown")
    echo "  User: ${user_val}"
    
    local ubuntu_val
    ubuntu_val=$(lsb_release -d 2>/dev/null | cut -f2 || echo "unknown")
    echo "  Ubuntu: ${ubuntu_val}"
    
    # Check Ubuntu version
    if [[ "$ubuntu_val" == *"24.04"* ]]; then
        print_ok "Ubuntu 24.04 LTS detected"
    elif [[ "$ubuntu_val" == *"Ubuntu"* ]]; then
        print_warn "Ubuntu detected but not 24.04 (found: ${ubuntu_val})"
    else
        print_fail "Ubuntu not detected"
    fi
    
    local kernel_val
    kernel_val=$(uname -r 2>/dev/null || echo "unknown")
    echo "  Kernel: ${kernel_val}"
}

#-------------------------------------------------------------------------------
# Check: Network connectivity
#-------------------------------------------------------------------------------
check_network() {
    print_section "Network"
    
    local ip_val
    ip_val=$(hostname -I 2>/dev/null | awk '{print $1}')
    
    if [[ -n "$ip_val" ]]; then
        echo "  IP Address: ${ip_val}"
        print_ok "IP address assigned"
    else
        echo "  IP Address: Not available"
        print_fail "No IP address found"
    fi
    
    # Test internet connectivity
    if ping -c 1 -W 3 google.com > /dev/null 2>&1; then
        print_ok "Internet connectivity"
    elif ping -c 1 -W 3 8.8.8.8 > /dev/null 2>&1; then
        print_warn "Internet works but DNS may have issues"
    else
        print_fail "No internet connection"
    fi
}

#-------------------------------------------------------------------------------
# Check: Essential commands
#-------------------------------------------------------------------------------
check_commands() {
    print_section "Essential Commands"
    
    # Core utilities
    local core_commands=(bash git nano vim gcc python3 ssh)
    # Additional tools
    local extra_commands=(tree htop awk sed grep find tar gzip curl wget)
    
    echo "  Core tools:"
    for cmd in "${core_commands[@]}"; do
        if command -v "$cmd" > /dev/null 2>&1; then
            print_ok "$cmd"
        else
            print_fail "$cmd — install with: sudo apt install $cmd"
        fi
    done
    
    echo ""
    echo "  Additional tools:"
    for cmd in "${extra_commands[@]}"; do
        if command -v "$cmd" > /dev/null 2>&1; then
            print_ok "$cmd"
        else
            print_warn "$cmd — optional but recommended"
        fi
    done
}

#-------------------------------------------------------------------------------
# Check: SSH server
#-------------------------------------------------------------------------------
check_ssh() {
    print_section "SSH Server"
    
    # Try systemctl first (systemd), then service (SysV init)
    if systemctl is-active ssh > /dev/null 2>&1; then
        print_ok "SSH server is running (systemd)"
    elif systemctl is-active sshd > /dev/null 2>&1; then
        print_ok "SSH server is running (sshd)"
    elif service ssh status 2>/dev/null | grep -q "running"; then
        print_ok "SSH server is running (service)"
    else
        print_fail "SSH server is NOT running"
        print_info "Start with: sudo systemctl start ssh"
    fi
    
    # Check if SSH is enabled at boot
    if systemctl is-enabled ssh > /dev/null 2>&1; then
        print_ok "SSH enabled at boot"
    else
        print_warn "SSH not enabled at boot — run: sudo systemctl enable ssh"
    fi
}

#-------------------------------------------------------------------------------
# Check: Working folders
#-------------------------------------------------------------------------------
check_folders() {
    print_section "Working Folders"
    
    local folders=(Books HomeworksOLD Projects ScriptsSTUD test TXT)
    local missing_folders=()
    
    for dir in "${folders[@]}"; do
        if [[ -d "$HOME/$dir" ]]; then
            print_ok "~/$dir"
        else
            print_fail "~/$dir — missing"
            missing_folders+=("$dir")
        fi
    done
    
    # Offer to create missing folders
    if [[ ${#missing_folders[@]} -gt 0 ]]; then
        echo ""
        print_info "Create missing folders with:"
        echo "        mkdir -p ~/${missing_folders[*]// / ~/}"
    fi
}

#-------------------------------------------------------------------------------
# Check: Python environment (bonus)
#-------------------------------------------------------------------------------
check_python() {
    print_section "Python Environment"
    
    if command -v python3 > /dev/null 2>&1; then
        local py_version
        py_version=$(python3 --version 2>&1 | awk '{print $2}')
        echo "  Python version: ${py_version}"
        print_ok "Python 3 installed"
        
        # Check pip
        if command -v pip3 > /dev/null 2>&1; then
            print_ok "pip3 available"
        else
            print_warn "pip3 not found — install with: sudo apt install python3-pip"
        fi
    else
        print_fail "Python 3 not installed"
    fi
}

#-------------------------------------------------------------------------------
# Print summary
#-------------------------------------------------------------------------------
print_summary() {
    echo ""
    echo -e "${BOLD}========================================${NC}"
    echo -e "${BOLD}   VERIFICATION SUMMARY${NC}"
    echo -e "${BOLD}========================================${NC}"
    echo ""
    echo -e "  ${GREEN}Passed:${NC}   ${PASSED}"
    echo -e "  ${YELLOW}Warnings:${NC} ${WARNINGS}"
    echo -e "  ${RED}Failed:${NC}   ${FAILED}"
    echo ""
    
    if [[ $FAILED -eq 0 ]]; then
        echo -e "${GREEN}${BOLD}  ✓ All critical checks passed!${NC}"
        echo -e "  ${CYAN}You are ready for SEM01.${NC}"
    else
        echo -e "${RED}${BOLD}  ✗ Some checks failed.${NC}"
        echo -e "  ${YELLOW}Review the failures above and fix them before SEM01.${NC}"
    fi
    
    if [[ $WARNINGS -gt 0 ]]; then
        echo ""
        echo -e "  ${YELLOW}Note: Warnings are recommendations, not blockers.${NC}"
    fi
    
    echo ""
    echo -e "${BOLD}========================================${NC}"
}

#-------------------------------------------------------------------------------
# Main execution
#-------------------------------------------------------------------------------
main() {
    print_header
    check_system_info
    check_network
    check_commands
    check_ssh
    check_folders
    check_python
    print_summary
    
    # Exit with appropriate code
    if [[ $FAILED -gt 0 ]]; then
        exit 1
    else
        exit 0
    fi
}

# Run main function
main "$@"
