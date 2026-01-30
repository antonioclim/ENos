#!/usr/bin/env bash
#
# firewall_basic.sh - Basic firewall configuration with iptables
# Operating Systems | ASE Bucharest - CSIE | 2025-2026
#
# Concepts illustrated:
# - Netfilter chain structure (INPUT, OUTPUT, FORWARD)
# - Default policies and explicit rules
# - Connection tracking (conntrack)
# - Rule ordering and best practices
#
# WARNING: This script modifies firewall configuration!
# Only run if you understand the implications.
#
# Usage:
#   sudo ./firewall_basic.sh apply    # Apply rules
#   sudo ./firewall_basic.sh show     # Display current rules
#   sudo ./firewall_basic.sh reset    # Reset to permissive policies
#   sudo ./firewall_basic.sh save     # Save configuration
#

set -euo pipefail

# Colours
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'
BOLD='\033[1m'

# Configuration
IPTABLES=$(command -v iptables || true)
IP6TABLES=$(command -v ip6tables || true)
SSH_PORT=22
HTTP_PORT=80
HTTPS_PORT=443

# Trusted networks (customise!)
TRUSTED_NETS="192.168.0.0/16 10.0.0.0/8 172.16.0.0/12"

#######################################
# Utility functions
#######################################

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_ok() {
    echo -e "${GREEN}[OK]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_err() {
    echo -e "${RED}[ERR]${NC} $1"
}

check_root() {
    if [[ $EUID -ne 0 ]]; then
        log_err "This script requires root privileges"
        echo "Run: sudo $0 $*"
        exit 1
    fi
}

check_iptables() {
    if [[ -z "$IPTABLES" ]]; then
        log_err "iptables is not installed"
        exit 1
    fi
}

#######################################
# Firewall functions
#######################################

flush_rules() {
    log_info "Flushing existing rules..."
    
    # Set permissive policies temporarily
    $IPTABLES -P INPUT ACCEPT
    $IPTABLES -P FORWARD ACCEPT
    $IPTABLES -P OUTPUT ACCEPT
    
    # Flush all chains
    $IPTABLES -F
    $IPTABLES -X
    $IPTABLES -t nat -F
    $IPTABLES -t nat -X
    $IPTABLES -t mangle -F
    $IPTABLES -t mangle -X
    
    # IPv6 (if available)
    if [[ -n "$IP6TABLES" ]]; then
        $IP6TABLES -P INPUT ACCEPT
        $IP6TABLES -P FORWARD ACCEPT
        $IP6TABLES -P OUTPUT ACCEPT
        $IP6TABLES -F
        $IP6TABLES -X
    fi
    
    log_ok "Rules flushed"
}

apply_basic_rules() {
    log_info "Applying basic rule set..."
    
    echo ""
    echo -e "${BOLD}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}  APPLYING FIREWALL RULES${NC}"
    echo -e "${BOLD}═══════════════════════════════════════════════════════════${NC}"
    echo ""
    
    # ═══════════════════════════════════════════════════════════════════════════
    # STEP 1: Default policies
    # ═══════════════════════════════════════════════════════════════════════════
    log_info "Setting default policies (DROP for INPUT/FORWARD, ACCEPT for OUTPUT)"
    
    # INPUT: default DROP - everything not explicitly allowed is blocked
    $IPTABLES -P INPUT DROP
    
    # FORWARD: default DROP - we are not a router (normally)
    $IPTABLES -P FORWARD DROP
    
    # OUTPUT: default ACCEPT - allow locally generated traffic
    # Note: in high-security environments, OUTPUT would also be DROP
    $IPTABLES -P OUTPUT ACCEPT
    
    log_ok "Policies set"
    
    # ═══════════════════════════════════════════════════════════════════════════
    # STEP 2: Loopback traffic
    # ═══════════════════════════════════════════════════════════════════════════
    log_info "Allowing loopback traffic (127.0.0.1)"
    
    # The lo interface is essential for local communication
    $IPTABLES -A INPUT -i lo -j ACCEPT
    $IPTABLES -A OUTPUT -o lo -j ACCEPT
    
    log_ok "Loopback allowed"
    
    # ═══════════════════════════════════════════════════════════════════════════
    # STEP 3: Connection tracking (connection state)
    # ═══════════════════════════════════════════════════════════════════════════
    log_info "Allowing established and related connections (stateful firewall)"
    
    # ESTABLISHED: packets part of an already established connection
    # RELATED: related packets (e.g., ICMP error for a TCP connection)
    $IPTABLES -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
    
    log_ok "Connection tracking configured"
    
    # ═══════════════════════════════════════════════════════════════════════════
    # STEP 4: Basic anti-spoofing protection
    # ═══════════════════════════════════════════════════════════════════════════
    log_info "Applying anti-spoofing protection"
    
    # Block packets with INVALID state
    $IPTABLES -A INPUT -m conntrack --ctstate INVALID -j DROP
    
    # Block NULL packets (no TCP flags set)
    $IPTABLES -A INPUT -p tcp --tcp-flags ALL NONE -j DROP
    
    # Block XMAS scan (all flags set)
    $IPTABLES -A INPUT -p tcp --tcp-flags ALL ALL -j DROP
    
    log_ok "Anti-spoofing protection applied"
    
    # ═══════════════════════════════════════════════════════════════════════════
    # STEP 5: ICMP (ping)
    # ═══════════════════════════════════════════════════════════════════════════
    log_info "Allowing limited ICMP (ping)"
    
    # Allow echo-request (ping) with rate limiting
    # Prevents flood attacks
    $IPTABLES -A INPUT -p icmp --icmp-type echo-request -m limit --limit 1/s --limit-burst 4 -j ACCEPT
    
    # Allow other necessary ICMP types
    $IPTABLES -A INPUT -p icmp --icmp-type destination-unreachable -j ACCEPT
    $IPTABLES -A INPUT -p icmp --icmp-type time-exceeded -j ACCEPT
    
    log_ok "ICMP configured"
    
    # ═══════════════════════════════════════════════════════════════════════════
    # STEP 6: SSH (only from trusted networks)
    # ═══════════════════════════════════════════════════════════════════════════
    log_info "Allowing SSH (port ${SSH_PORT}) from trusted networks"
    
    for net in $TRUSTED_NETS; do
        $IPTABLES -A INPUT -p tcp --dport ${SSH_PORT} -s "$net" -m conntrack --ctstate NEW -j ACCEPT
    done
    
    log_ok "SSH allowed from: ${TRUSTED_NETS}"
    
    # ═══════════════════════════════════════════════════════════════════════════
    # STEP 7: Web services (optional - commented by default)
    # ═══════════════════════════════════════════════════════════════════════════
    # Uncomment if running a web server
    
    # log_info "Allowing HTTP/HTTPS"
    # $IPTABLES -A INPUT -p tcp --dport ${HTTP_PORT} -m conntrack --ctstate NEW -j ACCEPT
    # $IPTABLES -A INPUT -p tcp --dport ${HTTPS_PORT} -m conntrack --ctstate NEW -j ACCEPT
    # log_ok "HTTP/HTTPS allowed"
    
    # ═══════════════════════════════════════════════════════════════════════════
    # STEP 8: Logging for blocked packets
    # ═══════════════════════════════════════════════════════════════════════════
    log_info "Configuring logging for blocked packets"
    
    # Create a dedicated chain for logging
    $IPTABLES -N LOG_DROP 2>/dev/null || $IPTABLES -F LOG_DROP
    $IPTABLES -A LOG_DROP -m limit --limit 5/min --limit-burst 10 -j LOG --log-prefix "IPT_DROP: " --log-level 4
    $IPTABLES -A LOG_DROP -j DROP
    
    # Redirect unwanted packets to the logging chain
    $IPTABLES -A INPUT -j LOG_DROP
    
    log_ok "Logging configured (check /var/log/kern.log or dmesg)"
    
    # ═══════════════════════════════════════════════════════════════════════════
    # IPv6 (similar rules)
    # ═══════════════════════════════════════════════════════════════════════════
    if [[ -n "$IP6TABLES" ]]; then
        log_info "Applying IPv6 rules..."
        
        $IP6TABLES -P INPUT DROP
        $IP6TABLES -P FORWARD DROP
        $IP6TABLES -P OUTPUT ACCEPT
        
        $IP6TABLES -A INPUT -i lo -j ACCEPT
        $IP6TABLES -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
        $IP6TABLES -A INPUT -m conntrack --ctstate INVALID -j DROP
        
        # ICMPv6 is more important than ICMP for IPv6
        $IP6TABLES -A INPUT -p ipv6-icmp -j ACCEPT
        
        log_ok "IPv6 rules applied"
    fi
    
    echo ""
    echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}  FIREWALL CONFIGURED SUCCESSFULLY${NC}"
    echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
    echo ""
}

show_rules() {
    echo -e "${BOLD}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}  CURRENT IPTABLES RULES${NC}"
    echo -e "${BOLD}═══════════════════════════════════════════════════════════${NC}"
    echo ""
    
    echo -e "${BLUE}─── Filter Table ───${NC}"
    $IPTABLES -L -n -v --line-numbers
    
    echo ""
    echo -e "${BLUE}─── NAT Table ───${NC}"
    $IPTABLES -t nat -L -n -v --line-numbers
    
    if [[ -n "$IP6TABLES" ]]; then
        echo ""
        echo -e "${BLUE}─── IPv6 Filter Table ───${NC}"
        $IP6TABLES -L -n -v --line-numbers
    fi
}

reset_rules() {
    log_warn "Resetting to permissive policies (ACCEPT all)"
    
    flush_rules
    
    echo ""
    log_ok "Firewall reset - all traffic is allowed"
    log_warn "The system is now without firewall protection!"
}

save_rules() {
    log_info "Saving rules..."
    
    SAVE_FILE="/etc/iptables/rules.v4"
    SAVE_FILE_V6="/etc/iptables/rules.v6"
    
    # Create directory if it does not exist
    mkdir -p /etc/iptables
    
    # Save
    iptables-save > "$SAVE_FILE"
    log_ok "IPv4 rules saved to: ${SAVE_FILE}"
    
    if [[ -n "$IP6TABLES" ]]; then
        ip6tables-save > "$SAVE_FILE_V6"
        log_ok "IPv6 rules saved to: ${SAVE_FILE_V6}"
    fi
    
    echo ""
    log_info "For automatic restoration at boot, install iptables-persistent:"
    echo "    sudo apt install iptables-persistent"
    echo "    sudo netfilter-persistent save"
}

show_help() {
    cat << EOF
${BOLD}firewall_basic.sh${NC} - Basic firewall configuration script

${BOLD}USAGE:${NC}
    sudo $0 <command>

${BOLD}COMMANDS:${NC}
    apply    Apply the basic rule set
    show     Display current rules
    reset    Reset to permissive policies (ACCEPT all)
    save     Save configuration for persistence

${BOLD}EXAMPLES:${NC}
    sudo $0 apply    # Apply firewall
    sudo $0 show     # Check rules
    sudo $0 reset    # Disable firewall

${BOLD}WARNING:${NC}
    - This script modifies the system security configuration
    - Test on a non-production system first
    - Ensure you have alternative access (console) in case of lockout

${BOLD}CUSTOMISATION:${NC}
    Edit variables in the script:
    - SSH_PORT: SSH port (default: 22)
    - TRUSTED_NETS: networks allowed for SSH

EOF
}

#######################################
# Main
#######################################

main() {
    if [[ $# -lt 1 ]]; then
        show_help
        exit 1
    fi
    
    # Handle help before checking iptables
    case "$1" in
        -h|--help|help)
            show_help
            exit 0
            ;;
    esac
    
    check_iptables
    
    case "$1" in
        apply)
            check_root
            flush_rules
            apply_basic_rules
            ;;
        show)
            show_rules
            ;;
        reset)
            check_root
            reset_rules
            ;;
        save)
            check_root
            save_rules
            ;;
        *)
            log_err "Unknown command: $1"
            show_help
            exit 1
            ;;
    esac
}

main "$@"
