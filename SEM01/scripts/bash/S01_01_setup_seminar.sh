#!/bin/bash
#
# SETUP SEMINAR - Laboratory environment preparation
# Operating Systems | ASE Bucharest - CSIE
# 
# Purpose: Prepares the working environment for the seminar
# Usage: ./setup_seminar.sh [--full | --minimal | --clean]
#

set -euo pipefail

# Colours
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Directories
WORK_DIR="$HOME/laborator_so"
SEMINAR_DIR="$WORK_DIR/seminar01"

# Utility functions
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[OK]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Banner
show_banner() {
    echo ""
    echo -e "${BLUE}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}        ${GREEN}SETUP SEMINAR 1-2: Bash Shell${NC}                         ${BLUE}║${NC}"
    echo -e "${BLUE}║${NC}        Operating Systems | ASE Bucharest - CSIE             ${BLUE}║${NC}"
    echo -e "${BLUE}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# Check and install tools (if permissions available)
install_tools() {
    log_info "Checking required tools..."
    
    local tools_to_install=""
    local optional_tools="figlet lolcat cmatrix cowsay tree ncdu pv dialog"
    
    for tool in $optional_tools; do
        if ! command -v $tool &>/dev/null; then
            tools_to_install="$tools_to_install $tool"
        else
            log_success "$tool is installed"
        fi
    done
    
    if [ -n "$tools_to_install" ]; then
        log_warning "Missing tools:$tools_to_install"
        
        if [ "$EUID" -eq 0 ] || command -v sudo &>/dev/null; then
            read -p "Would you like to install them? (y/n): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                log_info "Installing tools..."
                sudo apt-get update -qq
                sudo apt-get install -y $tools_to_install
                log_success "Tools installed!"
            fi
        else
            log_warning "No permissions for installation. Continuing without them."
        fi
    fi
}

# Create directory structure
create_structure() {
    log_info "Creating directory structure..."
    
    # Main directories
    mkdir -p "$SEMINAR_DIR"/{navigare,variabile,config,globbing,exercitii}
    
    # Demo project structure
    mkdir -p "$SEMINAR_DIR/demo_proiect"/{src,docs,tests,build,config}
    
    log_success "Structure created in $SEMINAR_DIR"
}

# Create test files
create_test_files() {
    log_info "Creating test files..."
    
    cd "$SEMINAR_DIR"
    
    # Files for navigation demo
    echo "This is a test file." > navigare/test.txt
    echo "Line 1
Line 2
Line 3
Line 4
Line 5
Line 6
Line 7
Line 8
Line 9
Line 10" > navigare/multe_linii.txt
    
    # Files for variables demo
    cat > variabile/demo_vars.sh << 'SCRIPT'
#!/bin/bash
# Variables demonstration

# Local variable
LOCAL_VAR="This is local"

# Environment variable
export GLOBAL_VAR="This is global"

echo "=== In the current shell ==="
echo "LOCAL_VAR: $LOCAL_VAR"
echo "GLOBAL_VAR: $GLOBAL_VAR"

echo ""
echo "=== In subshell ==="
bash -c 'echo "LOCAL_VAR: $LOCAL_VAR"'
bash -c 'echo "GLOBAL_VAR: $GLOBAL_VAR"'
SCRIPT
    chmod +x variabile/demo_vars.sh
    
    # Files for quoting demo
    cat > variabile/demo_quoting.sh << 'SCRIPT'
#!/bin/bash
# Quoting demonstration

NAME="Student"
DATA=$(date +%Y)

echo "=== Quoting Comparison ==="
echo ""
echo "1. Single quotes (literal):"
echo '   echo '\''Hello $NAME in $DATA'\'''
echo '   Result: Hello $NAME in $DATA'
echo ""
echo "2. Double quotes (expands):"
echo '   echo "Hello $NAME in $DATA"'
echo "   Result: Hello $NAME in $DATA"
echo ""
echo "3. Without quotes (expands + word splitting):"
echo '   echo Hello    $NAME    in    $DATA'
echo -n "   Result: "
echo Hello    $NAME    in    $DATA
SCRIPT
    chmod +x variabile/demo_quoting.sh
    
    # Files for globbing demo
    cd globbing
    touch file{1..10}.txt
    touch doc{A..E}.pdf
    touch image{01..05}.jpg
    touch .hidden_file
    touch "Document with spaces.txt"
    cd ..
    
    # Files for demo project
    echo '#include <stdio.h>

int main() {
    printf("Hello, World!\\n");
    return 0;
}' > demo_proiect/src/main.c
    
    echo '# Demo Project
    
This project demonstrates the structure of a C project.

## Compilation
```bash
gcc -o build/main src/main.c
```

## Execution
```bash
./build/main
```' > demo_proiect/docs/README.md
    
    echo 'CC=gcc
CFLAGS=-Wall -Wextra

all: main

main: src/main.c
	$(CC) $(CFLAGS) -o build/main src/main.c

clean:
	rm -f build/main

.PHONY: all clean' > demo_proiect/Makefile
    
    log_success "Test files created"
}

# Backup .bashrc
backup_bashrc() {
    log_info "Backing up .bashrc..."
    
    if [ -f "$HOME/.bashrc" ]; then
        cp "$HOME/.bashrc" "$HOME/.bashrc.backup.$(date +%Y%m%d_%H%M%S)"
        log_success "Backup saved: ~/.bashrc.backup.*"
    else
        log_warning "~/.bashrc does not exist"
    fi
}

# Create solved exercises file
create_solutions() {
    log_info "Creating exercise solutions..."
    
    cat > "$SEMINAR_DIR/exercitii/solutii.sh" << 'SOLUTIONS'
#!/bin/bash
#
# EXERCISE SOLUTIONS - Seminar 1
# DO NOT DISTRIBUTE TO STUDENTS BEFORE COMPLETION!
#

echo "=== EXERCISE 1: Navigation ==="
echo "# Display the current directory"
echo "pwd"
echo ""
echo "# Go to /etc and list the files"
echo "cd /etc && ls -la"
echo ""
echo "# Return home"
echo "cd ~"
echo ""

echo "=== EXERCISE 2: Create structure ==="
echo "mkdir -p proiect/{src,docs,tests}"
echo "touch proiect/src/main.py"
echo "touch proiect/docs/README.md"
echo "tree proiect"
echo ""

echo "=== EXERCISE 3: Variables ==="
echo "# Local variable"
echo 'NAME="Ion Popescu"'
echo 'echo "Hello, $NAME"'
echo ""
echo "# Environment variable"
echo 'export PROJECT="OS Laboratory"'
echo 'bash -c '\''echo "Project: $PROJECT"'\'''
echo ""

echo "=== EXERCISE 4: Globbing ==="
echo "# List all .txt files"
echo "ls *.txt"
echo ""
echo "# List file1.txt to file5.txt"
echo "ls file[1-5].txt"
echo ""
echo "# List everything EXCEPT .pdf"
echo "ls !(*.pdf)  # requires shopt -s extglob"
echo ""
SOLUTIONS
    chmod +x "$SEMINAR_DIR/exercitii/solutii.sh"
    
    log_success "Solutions created (DO NOT distribute to students!)"
}

# Cleanup
clean_environment() {
    log_info "Cleaning environment..."
    
    if [ -d "$WORK_DIR" ]; then
        read -p "Are you sure you want to delete $WORK_DIR? (y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            rm -rf "$WORK_DIR"
            log_success "Environment cleaned"
        else
            log_warning "Cleanup cancelled"
        fi
    else
        log_warning "Directory $WORK_DIR does not exist"
    fi
}

# Final verification
verify_setup() {
    log_info "Verifying setup..."
    
    echo ""
    echo -e "${BLUE}Structure created:${NC}"
    if command -v tree &>/dev/null; then
        tree -L 3 "$SEMINAR_DIR"
    else
        find "$SEMINAR_DIR" -type d | head -20
    fi
    
    echo ""
    echo -e "${BLUE}Test files:${NC}"
    ls -la "$SEMINAR_DIR/globbing/"
    
    echo ""
    echo -e "${GREEN}Setup complete!${NC}"
    echo -e "Working directory: ${YELLOW}$SEMINAR_DIR${NC}"
    echo ""
}

# Help
show_help() {
    echo "Usage: $0 [OPTION]"
    echo ""
    echo "Options:"
    echo "  --full      Full setup (tools + structure + files)"
    echo "  --minimal   Structure and files only (without tools)"
    echo "  --clean     Delete the laboratory environment"
    echo "  --help      Display this help"
    echo ""
}

#
# MAIN
#

show_banner

case "${1:-}" in
    --full)
        install_tools
        backup_bashrc
        create_structure
        create_test_files
        create_solutions
        verify_setup
        ;;
    --minimal)
        backup_bashrc
        create_structure
        create_test_files
        create_solutions
        verify_setup
        ;;
    --clean)
        clean_environment
        ;;
    --help|-h)
        show_help
        ;;
    *)
        # Default: minimal
        backup_bashrc
        create_structure
        create_test_files
        create_solutions
        verify_setup
        ;;
esac
