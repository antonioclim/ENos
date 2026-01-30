#!/usr/bin/env bash
#
# network_diag.sh - Comprehensive network diagnostic script
# Operating Systems | ASE Bucharest - CSIE | 2025-2026
#
# Concepts illustrated:
# - Using diagnostic utilities (ip, ss, ping, dig)
# - Systematic verification of network layers
# - Information gathering for troubleshooting
#
# Usage:
#   ./network_diag.sh                    # Full diagnostic
#   ./network_diag.sh --target google.com # With specific target
#   ./network_diag.sh --quick            # Essential checks only
#

set -euo pipefail

# Colours for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Colour
BOLD='\033[1m'

# Configuration
DEFAULT_TARGET="8.8.8.8"
DNS_TARGET="google.com"
PING_COUNT=4
TIMEOUT=5

# Global variables
TARGET="${DEFAULT_TARGET}"
QUICK_MODE=false
VERBOSE=false

#######################################
# Utility functions
#######################################

print_header() {
    echo -e "\n${BOLD}${BLUE}════════════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}${BLUE}  $1${NC}"
    echo -e "${BOLD}${BLUE}════════════════════════════════════════════════════════════${NC}\n"
}

print_section() {
    echo -e "\n${CYAN}── $1 ──${NC}\n"
}

print_ok() {
    echo -e "  ${GREEN}✓${NC} $1"
}

print_warn() {
    echo -e "  ${YELLOW}⚠${NC} $1"
}

print_err() {
    echo -e "  ${RED}✗${NC} $1"
}

print_info() {
    echo -e "  ${BLUE}ℹ${NC} $1"
}

command_exists() {
    command -v "$1" &> /dev/null
}

run_with_timeout() {
    timeout "${TIMEOUT}" "$@" 2>/dev/null
}

#######################################
# System checks
#######################################

check_system_info() {
    print_section "System Information"
    
    echo "  Hostname:     $(hostname)"
    echo "  Kernel:       $(uname -r)"
    echo "  Distribution: $(cat /etc/os-release 2>/dev/null | grep "^PRETTY_NAME" | cut -d= -f2 | tr -d '"' || echo "N/A")"
    echo "  Date/Time:    $(date '+%Y-%m-%d %H:%M:%S %Z')"
    echo "  Uptime:       $(uptime -p 2>/dev/null || uptime | awk -F'up ' '{print $2}' | awk -F',' '{print $1}')"
}

check_interfaces() {
    print_section "Network Interfaces"
    
    if command_exists ip; then
        # List interfaces with status
        echo "  Active interfaces:"
        ip -br link show | while read -r iface state rest; do
            if [[ "$state" == "UP" ]]; then
                echo -e "    ${GREEN}●${NC} ${iface}: ${state}"
            else
                echo -e "    ${RED}●${NC} ${iface}: ${state}"
            fi
        done
        
        echo ""
        echo "  IP addresses:"
        ip -br addr show | grep -v "^lo" | while read -r iface state addrs; do
            if [[ -n "$addrs" ]]; then
                echo "    ${iface}: ${addrs}"
            fi
        done
    else
        print_warn "Command 'ip' is not available"
        ifconfig 2>/dev/null || print_err "No network configuration command available"
    fi
}

check_routes() {
    print_section "Routing Table"
    
    if command_exists ip; then
        echo "  Main routes:"
        ip route show | head -10 | while read -r line; do
            echo "    $line"
        done
        
        # Check default gateway
        default_gw=$(ip route show default 2>/dev/null | awk '{print $3}' | head -1)
        if [[ -n "$default_gw" ]]; then
            print_ok "Default gateway: ${default_gw}"
        else
            print_err "No default gateway configured"
        fi
    else
        route -n 2>/dev/null || netstat -rn 2>/dev/null || print_err "Cannot display routing table"
    fi
}

check_dns() {
    print_section "DNS Configuration"
    
    echo "  Configured DNS servers:"
    if [[ -f /etc/resolv.conf ]]; then
        grep "^nameserver" /etc/resolv.conf | while read -r _ server; do
            echo "    - ${server}"
        done
    else
        print_warn "/etc/resolv.conf does not exist"
    fi
    
    # DNS resolution test
    echo ""
    echo "  DNS resolution test (${DNS_TARGET}):"
    if command_exists dig; then
        resolved_ip=$(dig +short "${DNS_TARGET}" A 2>/dev/null | head -1)
        if [[ -n "$resolved_ip" ]]; then
            print_ok "Resolved: ${DNS_TARGET} → ${resolved_ip}"
        else
            print_err "DNS resolution failed"
        fi
    elif command_exists host; then
        if host "${DNS_TARGET}" &>/dev/null; then
            print_ok "DNS resolution working"
        else
            print_err "DNS resolution failed"
        fi
    elif command_exists nslookup; then
        if nslookup "${DNS_TARGET}" &>/dev/null; then
            print_ok "DNS resolution working"
        else
            print_err "DNS resolution failed"
        fi
    else
        print_warn "No DNS utility available (dig/host/nslookup)"
    fi
}

check_connectivity() {
    print_section "Connectivity Test"
    
    echo "  ICMP test to ${TARGET}:"
    if ping -c "${PING_COUNT}" -W "${TIMEOUT}" "${TARGET}" &>/dev/null; then
        # Extract statistics
        ping_output=$(ping -c "${PING_COUNT}" -W "${TIMEOUT}" "${TARGET}" 2>/dev/null)
        packet_loss=$(echo "$ping_output" | grep -oP '\d+(?=% packet loss)' || echo "N/A")
        avg_rtt=$(echo "$ping_output" | grep -oP 'avg.*?=.*?/([\d.]+)/' | grep -oP '[\d.]+' | head -1 || echo "N/A")
        
        print_ok "Connectivity OK (loss: ${packet_loss}%, average RTT: ${avg_rtt}ms)"
    else
        print_err "ICMP connectivity failed to ${TARGET}"
    fi
    
    # Gateway test
    if [[ -n "${default_gw:-}" ]]; then
        echo ""
        echo "  Gateway test (${default_gw}):"
        if ping -c 2 -W 2 "${default_gw}" &>/dev/null; then
            print_ok "Gateway reachable"
        else
            print_err "Gateway unreachable - check physical connection"
        fi
    fi
}

check_sockets() {
    print_section "Sockets and Connections"
    
    if command_exists ss; then
        # Summary statistics
        echo "  Connection summary:"
        ss -s 2>/dev/null | grep -E "^(TCP|UDP)" | while read -r line; do
            echo "    $line"
        done
        
        echo ""
        echo "  Listening ports (TCP):"
        ss -tlnp 2>/dev/null | tail -n +2 | head -10 | while read -r state recvq sendq local remote process; do
            port=$(echo "$local" | rev | cut -d: -f1 | rev)
            addr=$(echo "$local" | rev | cut -d: -f2- | rev)
            echo "    ${port}/tcp  ${addr}  ${process:-}"
        done
        
        echo ""
        echo "  Established TCP connections:"
        established=$(ss -tn state established 2>/dev/null | tail -n +2 | wc -l)
        print_info "${established} active connections"
        
    elif command_exists netstat; then
        netstat -tlnp 2>/dev/null | head -15
    else
        print_warn "No socket inspection utility available"
    fi
}

check_firewall() {
    print_section "Firewall Status"
    
    # Check iptables
    if command_exists iptables; then
        echo "  iptables:"
        rules_count=$(iptables -L -n 2>/dev/null | grep -c "^" || echo "0")
        if [[ "$rules_count" -gt 6 ]]; then  # Header + default policies
            print_info "Active rules: $((rules_count - 6)) (approximately)"
        else
            print_info "Default policies only (no custom rules)"
        fi
        
        # Display policies
        echo "    Chain policies:"
        for chain in INPUT FORWARD OUTPUT; do
            policy=$(iptables -L "$chain" -n 2>/dev/null | head -1 | grep -oP '\(policy \K\w+' || echo "N/A")
            echo "      ${chain}: ${policy}"
        done
    else
        print_warn "iptables is not available"
    fi
    
    # Check nftables
    if command_exists nft; then
        echo ""
        echo "  nftables:"
        tables=$(nft list tables 2>/dev/null | wc -l)
        if [[ "$tables" -gt 0 ]]; then
            print_info "${tables} tables configured"
        else
            print_info "No nftables tables"
        fi
    fi
    
    # Check ufw (Ubuntu)
    if command_exists ufw; then
        echo ""
        echo "  UFW:"
        ufw status 2>/dev/null | head -1 | while read -r line; do
            print_info "$line"
        done
    fi
}

check_traceroute() {
    print_section "Route Trace to ${TARGET}"
    
    if command_exists traceroute; then
        echo "  (maximum 10 hops)"
        traceroute -m 10 -w 2 "${TARGET}" 2>/dev/null | tail -n +2 | while read -r line; do
            echo "    $line"
        done
    elif command_exists tracepath; then
        tracepath -m 10 "${TARGET}" 2>/dev/null | head -12 | while read -r line; do
            echo "    $line"
        done
    else
        print_warn "No traceroute utility available"
    fi
}

#######################################
# Main function
#######################################

show_help() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS]

Comprehensive network diagnostic script.

Options:
  -t, --target HOST    Target for connectivity tests (default: ${DEFAULT_TARGET})
  -q, --quick          Quick mode (essential checks only)
  -v, --verbose        Verbose output
  -h, --help           Display this message

Examples:
  $(basename "$0")                     # Full diagnostic
  $(basename "$0") -t google.com       # With specific target
  $(basename "$0") --quick             # Quick checks

EOF
}

parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -t|--target)
                TARGET="$2"
                DNS_TARGET="$2"
                shift 2
                ;;
            -q|--quick)
                QUICK_MODE=true
                shift
                ;;
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            -h|--help)
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
}

main() {
    parse_args "$@"
    
    print_header "NETWORK DIAGNOSTIC - $(date '+%Y-%m-%d %H:%M')"
    
    # Essential checks (always executed)
    check_system_info
    check_interfaces
    check_routes
    check_dns
    check_connectivity
    check_sockets
    
    # Extended checks (only in full mode)
    if [[ "$QUICK_MODE" == false ]]; then
        check_firewall
        check_traceroute
    fi
    
    print_header "DIAGNOSTIC COMPLETE"
    
    echo -e "  ${GREEN}Diagnostic finished successfully.${NC}"
    echo "  Report generated at: $(date '+%Y-%m-%d %H:%M:%S')"
    echo ""
}

main "$@"
