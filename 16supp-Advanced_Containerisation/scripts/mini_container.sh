<!-- RO: TRADUS ȘI VERIFICAT -->
#!/usr/bin/env bash
#
# mini_container.sh - Minimal container using only Linux primitives
# Operating Systems | ASE Bucharest - CSIE | 2025-2026
#
# Illustrated concepts:
# - Linux namespaces (PID, MNT, UTS, IPC, NET)
# - pivot_root for changing the root filesystem
# - Mounting special filesystems (/proc, /sys)
# - The fundamental mechanism of containerisation
#
# WARNING: This script requires root privileges and modifies
# the filesystem. Run only on test systems!
#
# Usage:
#   sudo ./mini_container.sh prepare    # Prepare rootfs
#   sudo ./mini_container.sh run        # Launch the container
#   sudo ./mini_container.sh shell      # Interactive shell in container
#   sudo ./mini_container.sh clean      # Clean up resources
#

set -euo pipefail

# Configuration
CONTAINER_NAME="mini-container"
ROOTFS_BASE="/var/lib/mini-containers"
ROOTFS="${ROOTFS_BASE}/${CONTAINER_NAME}"
HOSTNAME="mini-container"

# Colours
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'
BOLD='\033[1m'

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

log_step() {
    echo -e "${CYAN}[STEP]${NC} $1"
}

check_root() {
    if [[ $EUID -ne 0 ]]; then
        log_err "This script requires root privileges"
        echo "Run: sudo $0 $*"
        exit 1
    fi
}

check_commands() {
    local missing=()
    for cmd in unshare mount chroot; do
        if ! command -v "$cmd" &> /dev/null; then
            missing+=("$cmd")
        fi
    done
    
    if [[ ${#missing[@]} -gt 0 ]]; then
        log_err "Missing commands: ${missing[*]}"
        exit 1
    fi
}

#######################################
# Root Filesystem Preparation
#######################################

prepare_rootfs() {
    log_info "Preparing root filesystem for container..."
    
    # Create directory structure
    log_step "Creating directory structure..."
    mkdir -p "${ROOTFS}"/{bin,sbin,lib,lib64,usr/bin,usr/lib,usr/lib64}
    mkdir -p "${ROOTFS}"/{proc,sys,dev,tmp,root,etc,var/run}
    mkdir -p "${ROOTFS}"/dev/{pts,shm}
    
    # Copy essential binaries
    log_step "Copying essential binaries..."
    local binaries=(
        /bin/bash
        /bin/sh
        /bin/ls
        /bin/cat
        /bin/echo
        /bin/pwd
        /bin/ps
        /bin/mount
        /bin/umount
        /bin/hostname
        /usr/bin/id
        /usr/bin/whoami
        /usr/bin/env
        /usr/bin/clear
        /usr/bin/tty
    )
    
    for bin in "${binaries[@]}"; do
        if [[ -f "$bin" ]]; then
            cp "$bin" "${ROOTFS}${bin}" 2>/dev/null || true
        fi
    done
    
    # Copy required shared libraries
    log_step "Copying shared libraries..."
    for bin in "${binaries[@]}"; do
        if [[ -f "$bin" ]]; then
            # Extract dependencies with ldd
            ldd "$bin" 2>/dev/null | grep -oE '/[^ ]+' | while read -r lib; do
                if [[ -f "$lib" ]]; then
                    local libdir
                    libdir=$(dirname "${ROOTFS}${lib}")
                    mkdir -p "$libdir"
                    cp "$lib" "${ROOTFS}${lib}" 2>/dev/null || true
                fi
            done
        fi
    done
    
    # Copy dynamic loader explicitly (required for execution)
    for loader in /lib64/ld-linux-x86-64.so.* /lib/ld-linux.so.*; do
        if [[ -f "$loader" ]]; then
            cp "$loader" "${ROOTFS}${loader}" 2>/dev/null || true
        fi
    done
    
    # Create minimal configuration files
    log_step "Creating minimal configuration..."
    
    # /etc/passwd
    cat > "${ROOTFS}/etc/passwd" << 'EOF'
root:x:0:0:root:/root:/bin/bash
nobody:x:65534:65534:nobody:/nonexistent:/usr/sbin/nologin
EOF

    # /etc/group
    cat > "${ROOTFS}/etc/group" << 'EOF'
root:x:0:
nogroup:x:65534:
EOF

    # /etc/hosts
    cat > "${ROOTFS}/etc/hosts" << EOF
127.0.0.1   localhost
127.0.0.1   ${HOSTNAME}
EOF

    # /etc/hostname
    echo "${HOSTNAME}" > "${ROOTFS}/etc/hostname"
    
    # /etc/resolv.conf (copy from host for DNS)
    cp /etc/resolv.conf "${ROOTFS}/etc/resolv.conf" 2>/dev/null || true
    
    # Container initialisation script
    cat > "${ROOTFS}/init.sh" << 'EOF'
#!/bin/bash
# Container initialisation script

# Mount special filesystems
mount -t proc proc /proc 2>/dev/null || true
mount -t sysfs sysfs /sys 2>/dev/null || true
mount -t devpts devpts /dev/pts 2>/dev/null || true
mount -t tmpfs tmpfs /tmp 2>/dev/null || true

# Set hostname
hostname mini-container 2>/dev/null || true

# Display information
echo "════════════════════════════════════════════════════════"
echo "  MINI CONTAINER - Linux Isolation Demonstration"
echo "════════════════════════════════════════════════════════"
echo ""
echo "  Hostname: $(hostname)"
echo "  Current PID: $$"
echo "  User: $(whoami)"
echo ""
echo "  Quick checks:"
echo "  • ps aux    - list processes (only those in container)"
echo "  • ls /      - isolated root filesystem"
echo "  • cat /proc/1/cgroup - check cgroups"
echo ""
echo "  Type 'exit' to leave the container."
echo "════════════════════════════════════════════════════════"
echo ""

# Launch interactive shell
exec /bin/bash
EOF
    chmod +x "${ROOTFS}/init.sh"
    
    log_ok "Root filesystem prepared in: ${ROOTFS}"
    log_info "Size: $(du -sh "${ROOTFS}" | cut -f1)"
}

#######################################
# Launch Container
#######################################

run_container() {
    if [[ ! -d "${ROOTFS}" ]]; then
        log_err "Root filesystem does not exist. Run first: $0 prepare"
        exit 1
    fi
    
    log_info "Launching container with isolated namespaces..."
    
    echo -e "\n${BOLD}Created namespaces:${NC}"
    echo "  • PID   - isolated process tree"
    echo "  • MNT   - isolated mount points"
    echo "  • UTS   - isolated hostname"
    echo "  • IPC   - isolated IPC"
    echo "  • NET   - (disabled for simplicity)"
    echo ""
    
    # unshare creates new namespaces and launches the process
    # --pid: new PID namespace (PID 1 in container)
    # --mount: new mount namespace
    # --uts: UTS namespace (hostname)
    # --ipc: IPC namespace
    # --fork: required for PID namespace
    # --mount-proc: mounts /proc automatically
    
    unshare \
        --pid \
        --mount \
        --uts \
        --ipc \
        --fork \
        --mount-proc="${ROOTFS}/proc" \
        chroot "${ROOTFS}" /init.sh
    
    log_info "Container stopped."
}

#######################################
# Launch with pivot_root (more advanced)
#######################################

run_container_advanced() {
    if [[ ! -d "${ROOTFS}" ]]; then
        log_err "Root filesystem does not exist. Run first: $0 prepare"
        exit 1
    fi
    
    log_info "Launching container with pivot_root (advanced method)..."
    
    unshare \
        --pid \
        --mount \
        --uts \
        --ipc \
        --fork \
        -- /bin/bash -c "
            # Create bind mount for rootfs
            mount --bind ${ROOTFS} ${ROOTFS}
            
            # Enter the rootfs directory
            cd ${ROOTFS}
            
            # Create directory for old root
            mkdir -p old_root
            
            # pivot_root changes the root filesystem
            # The new root becomes the current directory
            # The old root is moved to old_root
            pivot_root . old_root
            
            # Mount special filesystems
            mount -t proc proc /proc
            mount -t sysfs sysfs /sys
            mount -t devpts devpts /dev/pts
            
            # Unmount the old root
            umount -l /old_root 2>/dev/null || true
            rmdir /old_root 2>/dev/null || true
            
            # Set hostname
            hostname ${HOSTNAME}
            
            # Launch shell
            exec /bin/bash
        "
}

#######################################
# Cleanup
#######################################

cleanup() {
    log_info "Cleaning up container resources..."
    
    # Unmount any remaining mount points
    for mp in "${ROOTFS}"/proc "${ROOTFS}"/sys "${ROOTFS}"/dev/pts "${ROOTFS}"/tmp; do
        umount "$mp" 2>/dev/null || true
    done
    
    # Delete rootfs
    if [[ -d "${ROOTFS}" ]]; then
        rm -rf "${ROOTFS}"
        log_ok "Root filesystem deleted"
    fi
    
    # Delete base directory if empty
    rmdir "${ROOTFS_BASE}" 2>/dev/null || true
    
    log_ok "Cleanup complete"
}

#######################################
# Display Information
#######################################

show_info() {
    echo -e "${BOLD}════════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}  MINI CONTAINER - Educational Script${NC}"
    echo -e "${BOLD}════════════════════════════════════════════════════════${NC}"
    echo ""
    echo "This script demonstrates the fundamental mechanisms of"
    echo "Linux containerisation: namespaces, chroot/pivot_root"
    echo "and process isolation."
    echo ""
    echo -e "${CYAN}Demonstrated concepts:${NC}"
    echo "  • PID namespace - isolated processes (PID 1 in container)"
    echo "  • Mount namespace - isolated filesystem"
    echo "  • UTS namespace - separate hostname"
    echo "  • IPC namespace - isolated semaphores/queues"
    echo ""
    echo -e "${CYAN}What is MISSING compared to Docker:${NC}"
    echo "  • Network namespace (for simplicity)"
    echo "  • User namespace (we run as root)"
    echo "  • cgroups (resource limits)"
    echo "  • Seccomp (syscall filtering)"
    echo "  • Image layers (overlay filesystem)"
    echo ""
    echo -e "${CYAN}Rootfs location:${NC} ${ROOTFS}"
    echo ""
}

#######################################
# Help
#######################################

show_help() {
    cat << EOF
${BOLD}mini_container.sh${NC} - Minimal container for demonstrations

${BOLD}USAGE:${NC}
    sudo $0 <command>

${BOLD}COMMANDS:${NC}
    prepare     Prepare the container root filesystem
    run         Launch the container (simple method with chroot)
    advanced    Launch with pivot_root (advanced method)
    shell       Alias for run
    info        Display information about the script
    clean       Clean up resources (delete rootfs)
    help        Display this message

${BOLD}EXAMPLES:${NC}
    # Complete workflow
    sudo $0 prepare    # Preparation (once)
    sudo $0 run        # Launch container
    sudo $0 clean      # Cleanup

${BOLD}INSIDE THE CONTAINER:${NC}
    ps aux             # You will see only container processes
    hostname           # Isolated hostname
    cat /etc/hosts     # Separate hosts file
    ls /proc           # /proc from the container's perspective
    exit               # Exit the container

${BOLD}NOTES:${NC}
    • The script requires root privileges
    • Run only on test systems
    • Network is NOT isolated (for simplicity)

EOF
}

#######################################
# Main
#######################################

main() {
    check_root
    check_commands
    
    local cmd="${1:-help}"
    
    case "$cmd" in
        prepare)
            prepare_rootfs
            ;;
        run|shell)
            run_container
            ;;
        advanced)
            run_container_advanced
            ;;
        info)
            show_info
            ;;
        clean)
            cleanup
            ;;
        help|-h|--help)
            show_help
            ;;
        *)
            log_err "Unknown command: $cmd"
            show_help
            exit 1
            ;;
    esac
}

main "$@"
