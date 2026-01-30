#!/bin/bash
#
#  S02_03_demo_redirectare.sh - Spectacular I/O Redirection Demo
#
# DESCRIPTION:
#   Visual demonstrations for I/O redirection concepts:
#   - File descriptors (stdin=0, stdout=1, stderr=2)
#   - Output redirection (>, >>)
#   - stderr redirection (2>, 2>>)
#   - Stream combining (2>&1, &>)
#   - Here documents (<<) and here strings (<<<)
#   - /dev/null and output suppression
#   - tee for stream duplication
#
# USAGE:
#   ./S02_03_demo_redirectare.sh [demo_number]
#   ./S02_03_demo_redirectare.sh          # Run all demos
#   ./S02_03_demo_redirectare.sh 3        # Run only demo #3
#   ./S02_03_demo_redirectare.sh menu     # Display interactive menu
#
# DEPENDENCIES:
#   - Required: bash 4.0+, coreutils
#   - Optional: figlet, lolcat, pv, dialog (for visual effects)
#
# AUTHOR: OS Pedagogical Kit | ASE Bucharest - CSIE
# VERSION: 1.0 | January 2025
#

set -euo pipefail

#
# COLOUR AND SYMBOL CONFIGURATION
#
if [[ -t 1 ]]; then
    RED='\033[1;31m'
    GREEN='\033[1;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[1;34m'
    MAGENTA='\033[1;35m'
    CYAN='\033[1;36m'
    WHITE='\033[1;37m'
    DIM='\033[2m'
    BOLD='\033[1m'
    RESET='\033[0m'
    
    # Symbols
    CHECK="✓"
    CROSS="✗"
    ARROW="→"
    PIPE_SYM="│"
    BULLET="•"
    STAR="★"
else
    RED='' GREEN='' YELLOW='' BLUE='' MAGENTA='' CYAN='' WHITE=''
    DIM='' BOLD='' RESET=''
    CHECK="[OK]" CROSS="[X]" ARROW="->" PIPE_SYM="|" BULLET="*" STAR="*"
fi

#
# WORKING DIRECTORIES
#
DEMO_DIR="${TMPDIR:-/tmp}/demo_redirect_$$"
mkdir -p "$DEMO_DIR"
cd "$DEMO_DIR"

# Cleanup on exit
cleanup() {
    cd /
    rm -rf "$DEMO_DIR" 2>/dev/null || true
}
trap cleanup EXIT

#
# HELPER FUNCTIONS
#
print_header() {
    local title="$1"
    local width=70
    
    echo ""
    echo -e "${CYAN}╔$(printf '═%.0s' $(seq 1 $((width-2))))╗${RESET}"
    printf "${CYAN}║${RESET} ${BOLD}${WHITE}%-$((width-4))s${RESET} ${CYAN}║${RESET}\n" "$title"
    echo -e "${CYAN}╚$(printf '═%.0s' $(seq 1 $((width-2))))╝${RESET}"
    echo ""
}

print_subheader() {
    echo -e "\n${YELLOW}━━━ $1 ━━━${RESET}\n"
}

print_code() {
    echo -e "${DIM}┌─────────────────────────────────────────────────────────────────┐${RESET}"
    echo -e "${GREEN}  $1${RESET}"
    echo -e "${DIM}└─────────────────────────────────────────────────────────────────┘${RESET}"
}

print_output() {
    echo -e "${BLUE}  Output: ${WHITE}$1${RESET}"
}

print_explanation() {
    echo -e "${MAGENTA}  ${BULLET} $1${RESET}"
}

wait_for_user() {
    echo ""
    echo -e "${DIM}Press ENTER to continue...${RESET}"
    read -r
}

type_effect() {
    local text="$1"
    local delay="${2:-0.03}"
    
    for ((i=0; i<${#text}; i++)); do
        printf "%s" "${text:$i:1}"
        sleep "$delay"
    done
    echo ""
}

fancy_title() {
    local text="$1"
    
    if command -v figlet &>/dev/null; then
        if command -v lolcat &>/dev/null; then
            figlet -f small "$text" 2>/dev/null | lolcat -f 2>/dev/null || echo "=== $text ==="
        else
            echo -e "${CYAN}"
            figlet -f small "$text" 2>/dev/null || echo "=== $text ==="
            echo -e "${RESET}"
        fi
    else
        echo ""
        echo -e "${CYAN}╭────────────────────────────────────────╮${RESET}"
        echo -e "${CYAN}│${RESET}  ${BOLD}${WHITE}$text${RESET}  ${CYAN}│${RESET}"
        echo -e "${CYAN}╰────────────────────────────────────────╯${RESET}"
    fi
}

#
# DEMO 1: FILE DESCRIPTORS - FUNDAMENTALS
#
demo_file_descriptors() {
    print_header "📁 DEMO 1: FILE DESCRIPTORS - FUNDAMENTALS"
    
    echo -e "${WHITE}In Unix/Linux, every process has 3 standard I/O channels:${RESET}"
    echo ""
    
    # ASCII diagram
    cat << 'DIAGRAM'
    ┌─────────────────────────────────────────────────────────────┐
    │                     BASH PROCESS                             │
    │                                                             │
    │  ┌──────────┐                          ┌──────────┐        │
    │  │ Keyboard │ ──▶ [FD 0: stdin]  ──▶   │          │        │
    │  └──────────┘                          │          │        │
    │                                        │  Script  │        │
    │  ┌──────────┐                          │    /     │        │
    │  │ Terminal │ ◀── [FD 1: stdout] ◀──   │ Process  │        │
    │  │ (screen) │                          │          │        │
    │  └──────────┘                          │          │        │
    │                                        │          │        │
    │  ┌──────────┐                          │          │        │
    │  │ Terminal │ ◀── [FD 2: stderr] ◀──   │          │        │
    │  │ (errors) │                          └──────────┘        │
    │  └──────────┘                                              │
    └─────────────────────────────────────────────────────────────┘
DIAGRAM

    echo ""
    print_subheader "Practical demonstration"
    
    # Create a test script
    cat > test_fd.sh << 'EOF'
#!/bin/bash
echo "This is stdout (FD 1)"
echo "This is a simulated error" >&2
echo "Back to stdout"
ls /nonexistent_directory 2>&1 | head -1
EOF
    chmod +x test_fd.sh
    
    print_code "echo 'message' >&2   # Send to stderr (FD 2)"
    echo ""
    
    echo -e "${WHITE}Let us see what a script that writes to both channels produces:${RESET}"
    echo ""
    
    print_code "./test_fd.sh"
    echo -e "${BLUE}Combined output:${RESET}"
    ./test_fd.sh 2>&1 || true
    
    wait_for_user
    
    # Check descriptors
    print_subheader "Checking Active File Descriptors"
    
    print_code "ls -la /proc/\$\$/fd"
    echo -e "${BLUE}File descriptors of the current shell:${RESET}"
    ls -la /proc/$$/fd 2>/dev/null | head -6 || echo "(not available)"
    
    print_explanation "FD 0 ${ARROW} /dev/pts/X = stdin (terminal input)"
    print_explanation "FD 1 ${ARROW} /dev/pts/X = stdout (terminal output)"  
    print_explanation "FD 2 ${ARROW} /dev/pts/X = stderr (terminal errors)"
    print_explanation "FD 255 ${ARROW} used internally by bash"
    
    wait_for_user
}

#
# DEMO 2: OUTPUT REDIRECTION (>, >>)
#
demo_output_redirect() {
    print_header "📤 DEMO 2: OUTPUT REDIRECTION (>, >>)"
    
    print_subheader "The > operator (overwrite)"
    
    print_code "echo 'First line' > file.txt"
    echo "First line" > file.txt
    echo -e "${BLUE}Contents of file.txt:${RESET}"
    cat file.txt
    
    echo ""
    print_code "echo 'Second line' > file.txt"
    echo "Second line" > file.txt
    echo -e "${BLUE}Contents of file.txt (after overwrite):${RESET}"
    cat file.txt
    
    print_explanation "Note: The first line DISAPPEARED! > overwrites all content"
    
    wait_for_user
    
    print_subheader "The >> operator (append)"
    
    echo "Line 1" > file.txt
    print_code "echo 'Line 1' > file.txt    # Initial creation"
    print_code "echo 'Line 2' >> file.txt   # Append"
    print_code "echo 'Line 3' >> file.txt   # Append"
    
    echo "Line 2" >> file.txt
    echo "Line 3" >> file.txt
    
    echo -e "${BLUE}Contents of file.txt:${RESET}"
    cat file.txt
    
    print_explanation ">> APPENDS to the end of the file, does not overwrite"
    
    wait_for_user
    
    # Visual demonstration with animation
    print_subheader "Animated Visualisation: > vs >>"
    
    rm -f demo.txt 2>/dev/null
    
    echo -e "${WHITE}Simulation: 3 writes with >${RESET}"
    for i in 1 2 3; do
        echo "Write $i" > demo.txt
        echo -e "  ${YELLOW}echo 'Write $i' > demo.txt${RESET}"
        echo -e "  ${CYAN}Content: $(cat demo.txt)${RESET}"
        sleep 0.5
    done
    
    echo ""
    rm -f demo.txt
    
    echo -e "${WHITE}Simulation: 3 writes with >>${RESET}"
    for i in 1 2 3; do
        echo "Write $i" >> demo.txt
        echo -e "  ${YELLOW}echo 'Write $i' >> demo.txt${RESET}"
        echo -e "  ${CYAN}Content: $(cat demo.txt | tr '\n' ' ')${RESET}"
        sleep 0.5
    done
    
    wait_for_user
}

#
# DEMO 3: STDERR REDIRECTION (2>, 2>>)
#
demo_stderr_redirect() {
    print_header "⚠️ DEMO 3: STDERR REDIRECTION (2>, 2>>)"
    
    print_subheader "stdout vs stderr"
    
    echo -e "${WHITE}A command that produces both output types:${RESET}"
    print_code "ls /etc/passwd /nonexistent"
    
    echo -e "${BLUE}Normal execution (both streams to terminal):${RESET}"
    ls /etc/passwd /nonexistent 2>&1 || true
    
    wait_for_user
    
    print_subheader "Redirect only stderr"
    
    print_code "ls /etc/passwd /nonexistent 2> errors.txt"
    ls /etc/passwd /nonexistent 2> errors.txt || true
    
    echo ""
    echo -e "${BLUE}Screen (stdout):${RESET} $(ls /etc/passwd 2>/dev/null)"
    echo -e "${RED}errors.txt (stderr):${RESET}"
    cat errors.txt | sed 's/^/  /'
    
    wait_for_user
    
    print_subheader "Separate redirection"
    
    print_code "ls /etc/passwd /nonexistent > output.txt 2> errors.txt"
    ls /etc/passwd /nonexistent > output.txt 2> errors.txt || true
    
    echo -e "${GREEN}output.txt:${RESET}"
    cat output.txt | sed 's/^/  /'
    echo -e "${RED}errors.txt:${RESET}"
    cat errors.txt | sed 's/^/  /'
    
    wait_for_user
}

#
# DEMO 4: STREAM COMBINING (2>&1, &>)
#
demo_stream_combine() {
    print_header "🔀 DEMO 4: STREAM COMBINING (2>&1, &>)"
    
    print_subheader "2>&1 - Redirect stderr to stdout"
    
    cat << 'DIAGRAM'
    Before:  stdout ─────▶ terminal
             stderr ─────▶ terminal (separate)
    
    After:   stdout ─────▶ file
             stderr ──┘
                 ↓
          2>&1 means "FD 2 goes where FD 1 goes"
DIAGRAM
    
    echo ""
    
    print_code "ls /etc/passwd /nonexistent > all.txt 2>&1"
    ls /etc/passwd /nonexistent > all.txt 2>&1 || true
    
    echo -e "${BLUE}all.txt (stdout + stderr):${RESET}"
    cat all.txt | sed 's/^/  /'
    
    wait_for_user
    
    print_subheader "&> - Modern shortcut"
    
    echo -e "${WHITE}The following are equivalent:${RESET}"
    echo ""
    print_code "command > file 2>&1    # Classic method"
    print_code "command &> file        # Modern shortcut"
    
    print_explanation "&> redirects BOTH stdout AND stderr to file"
    
    wait_for_user
    
    print_subheader "⚠️ Order matters!"
    
    echo -e "${RED}WRONG ORDER:${RESET}"
    print_code "command 2>&1 > file"
    echo "  stderr → terminal, stdout → file"
    echo ""
    
    echo -e "${GREEN}CORRECT ORDER:${RESET}"
    print_code "command > file 2>&1"
    echo "  stdout → file, stderr → same file"
    
    wait_for_user
}

#
# DEMO 5: INPUT REDIRECTION (<)
#
demo_input_redirect() {
    print_header "📥 DEMO 5: INPUT REDIRECTION (<)"
    
    # Create test file
    cat > numbers.txt << 'EOF'
42
17
99
8
EOF
    
    print_subheader "Read from file instead of keyboard"
    
    echo -e "${WHITE}numbers.txt contains:${RESET}"
    cat numbers.txt | sed 's/^/  /'
    echo ""
    
    print_code "sort -n < numbers.txt"
    echo -e "${BLUE}Result (sorted):${RESET}"
    sort -n < numbers.txt | sed 's/^/  /'
    
    wait_for_user
    
    print_subheader "Combining input and output"
    
    print_code "sort -n < numbers.txt > sorted.txt"
    sort -n < numbers.txt > sorted.txt
    
    echo -e "${BLUE}sorted.txt:${RESET}"
    cat sorted.txt | sed 's/^/  /'
    
    wait_for_user
}

#
# DEMO 6: HERE DOCUMENTS (<<)
#
demo_here_documents() {
    print_header "📄 DEMO 6: HERE DOCUMENTS (<<)"
    
    print_subheader "Inline multi-line input"
    
    cat << 'SYNTAX'
    command << DELIMITER
    line 1
    line 2
    ...
    DELIMITER
SYNTAX
    
    echo ""
    
    print_code "cat << EOF"
    echo -e "${WHITE}Example:${RESET}"
    
    cat << EOF
    This is a here document.
    It can span multiple lines.
    Variables work: HOME=$HOME
EOF
    
    wait_for_user
    
    print_subheader "Disable variable expansion with quotes"
    
    echo -e "${YELLOW}With << 'EOF' (quoted delimiter):${RESET}"
    cat << 'EOF'
    Variables are NOT expanded: HOME=$HOME
    Special characters: $() `` \n
EOF
    
    wait_for_user
    
    print_subheader "Practical use: script generation"
    
    print_code "cat > script.sh << 'SCRIPT'"
    
    cat > generated.sh << 'SCRIPT'
#!/bin/bash
echo "This script was generated with here document"
echo "Date: $(date)"
echo "User: $USER"
SCRIPT
    
    echo -e "${BLUE}Generated script:${RESET}"
    cat generated.sh | sed 's/^/  /'
    
    wait_for_user
}

#
# DEMO 7: HERE STRINGS (<<<)
#
demo_here_strings() {
    print_header "💬 DEMO 7: HERE STRINGS (<<<)"
    
    print_subheader "Single-line inline input"
    
    echo -e "${WHITE}Syntax: command <<< \"string\"${RESET}"
    echo ""
    
    print_code "wc -w <<< 'Count the words in this string'"
    wc -w <<< "Count the words in this string"
    
    wait_for_user
    
    print_subheader "Compare: echo | command vs <<<"
    
    echo -e "${YELLOW}Traditional (with pipe):${RESET}"
    print_code "echo 'hello' | tr 'a-z' 'A-Z'"
    echo "hello" | tr 'a-z' 'A-Z'
    
    echo ""
    echo -e "${GREEN}Modern (with <<<):${RESET}"
    print_code "tr 'a-z' 'A-Z' <<< 'hello'"
    tr 'a-z' 'A-Z' <<< "hello"
    
    print_explanation "<<< is more efficient (no subshell for echo)"
    
    wait_for_user
    
    print_subheader "With variables"
    
    message="Convert this text"
    print_code "tr 'a-z' 'A-Z' <<< \"\$message\""
    tr 'a-z' 'A-Z' <<< "$message"
    
    wait_for_user
}

#
# DEMO 8: /dev/null - THE BLACK HOLE
#
demo_dev_null() {
    print_header "🕳️ DEMO 8: /dev/null - THE BLACK HOLE"
    
    cat << 'DIAGRAM'
    
              /dev/null
           ┌─────────────┐
           │   ░░░░░░░   │
    ──────▶│   ░░░░░░░   │  → Nothing comes out!
           │   ░░░░░░░   │
           └─────────────┘
        
    • Always empty when read
    • Discards anything written
    • Perfect for "silent mode"

DIAGRAM
    
    wait_for_user
    
    print_subheader "Suppress error messages"
    
    echo -e "${YELLOW}Without suppression:${RESET}"
    print_code "ls /nonexistent"
    ls /nonexistent 2>&1 || true
    
    echo ""
    echo -e "${GREEN}With error suppression:${RESET}"
    print_code "ls /nonexistent 2>/dev/null"
    ls /nonexistent 2>/dev/null
    echo "(nothing displayed)"
    
    wait_for_user
    
    print_subheader "Suppress all output"
    
    print_code "command &>/dev/null"
    print_explanation "Useful for: checking if command succeeds without output"
    
    echo ""
    echo -e "${WHITE}Example: does the user exist?${RESET}"
    print_code "if id nobody &>/dev/null; then echo 'User exists'; fi"
    if id nobody &>/dev/null; then echo "User exists"; fi
    
    wait_for_user
    
    print_subheader "Read from /dev/null"
    
    print_code "wc -l < /dev/null"
    echo -n "Result: "
    wc -l < /dev/null
    
    print_explanation "/dev/null is always empty when read"
    
    wait_for_user
}

#
# DEMO 9: TEE - STREAM DUPLICATION
#
demo_tee() {
    print_header "🔀 DEMO 9: TEE - STREAM DUPLICATION"
    
    cat << 'DIAGRAM'
    
                        ┌──────────▶ file
    stdin ──▶ tee ──────┤
                        └──────────▶ stdout
    
    tee = "T-shaped junction"

DIAGRAM
    
    wait_for_user
    
    print_subheader "Basic usage"
    
    print_code "echo 'Hello World' | tee backup.txt"
    echo "Hello World" | tee backup.txt
    echo ""
    echo -e "${BLUE}backup.txt:${RESET}"
    cat backup.txt | sed 's/^/  /'
    
    print_explanation "The output appears ON SCREEN and is saved to file simultaneously"
    
    wait_for_user
    
    print_subheader "Use Case: Debugging Pipelines"
    
    print_code 'ps aux | tee debug1.txt | grep "bash" | tee debug2.txt | wc -l'
    
    count=$(ps aux | tee debug1.txt | grep "bash" | tee debug2.txt | wc -l)
    echo -e "${BLUE}Final result: $count lines with 'bash'${RESET}"
    
    echo ""
    echo -e "${DIM}debug1.txt: $(wc -l < debug1.txt) lines (all processes)${RESET}"
    echo -e "${DIM}debug2.txt: $(wc -l < debug2.txt) lines (only bash)${RESET}"
    
    print_explanation "tee allows 'intercepting' data at each step"
    
    wait_for_user
    
    print_subheader "The -a option (append)"
    
    print_code "echo 'Line 1' | tee log.txt"
    print_code "echo 'Line 2' | tee -a log.txt"
    
    echo "Line 1" | tee log.txt > /dev/null
    echo "Line 2" | tee -a log.txt > /dev/null
    
    echo -e "${BLUE}log.txt:${RESET}"
    cat log.txt | sed 's/^/  /'
    
    print_explanation "-a = append, preserves existing content"
    
    wait_for_user
    
    print_subheader "tee with multiple files"
    
    print_code "echo 'Message' | tee file1.txt file2.txt file3.txt"
    echo "Common message" | tee f1.txt f2.txt f3.txt > /dev/null
    
    echo -e "${BLUE}All files contain the same text:${RESET}"
    echo "  f1.txt: $(cat f1.txt)"
    echo "  f2.txt: $(cat f2.txt)"
    echo "  f3.txt: $(cat f3.txt)"
    
    wait_for_user
}

#
# DEMO 10: INTEGRATED EXAMPLE
#
demo_integrated() {
    print_header "🎯 DEMO 10: INTEGRATED EXAMPLE - LOGGING SYSTEM"
    
    print_subheader "Scenario: Processing system with complete logging"
    
    echo -e "${WHITE}We shall create a script that:${RESET}"
    echo "  1. Processes data from multiple sources"
    echo "  2. Logs stdout and stderr separately"
    echo "  3. Maintains a combined log for audit"
    echo "  4. Displays progress in real time"
    echo ""
    
    # Create script
    cat > processor.sh << 'SCRIPT'
#!/bin/bash
# Processing system with logging

LOG_DIR="./logs"
mkdir -p "$LOG_DIR"

{
    echo "=== Processing started: $(date) ==="
    
    echo "[INFO] System verification..."
    uname -a
    
    echo "[INFO] Searching configuration files..."
    find /etc -maxdepth 1 -name "*.conf" 2>&1 | head -5
    
    echo "[INFO] Attempting restricted access..."
    cat /etc/shadow 2>&1 || true
    
    echo "[INFO] Disk statistics..."
    df -h / 2>/dev/null | tail -1
    
    echo "=== Processing finished: $(date) ==="
    
} 2>&1 | tee "$LOG_DIR/combined.log" | \
  grep -E "^\[INFO\]" | tee "$LOG_DIR/info.log"
SCRIPT
    chmod +x processor.sh
    
    print_code "# The processor.sh script"
    echo -e "${DIM}$(head -15 processor.sh)${RESET}"
    echo -e "${DIM}...${RESET}"
    
    wait_for_user
    
    print_subheader "Execution and results"
    
    echo -e "${YELLOW}Running processor.sh:${RESET}"
    echo ""
    ./processor.sh || true
    
    echo ""
    echo -e "${BLUE}Log files created:${RESET}"
    ls -la logs/
    
    wait_for_user
    
    print_subheader "Examining logs"
    
    echo -e "${GREEN}info.log (only INFO messages):${RESET}"
    cat logs/info.log | head -5 | sed 's/^/  /'
    
    echo ""
    echo -e "${YELLOW}combined.log (all output):${RESET}"
    head -10 logs/combined.log | sed 's/^/  /'
    echo -e "  ${DIM}... ($(wc -l < logs/combined.log) lines total)${RESET}"
    
    wait_for_user
}

#
# BONUS DEMO: PROGRESS BAR WITH PV
#
demo_progress_bar() {
    print_header "⏳ BONUS DEMO: PROGRESS BAR WITH PV"
    
    if ! command -v pv &>/dev/null; then
        echo -e "${YELLOW}pv is not installed. Install with: sudo apt install pv${RESET}"
        echo ""
        echo -e "${DIM}Simulated demonstration:${RESET}"
        
        # Simulate progress bar
        echo -n "Processing: ["
        for i in $(seq 1 50); do
            echo -n "#"
            sleep 0.05
        done
        echo "] 100%"
        
        return
    fi
    
    print_subheader "pv = Pipe Viewer - visual progress for I/O operations"
    
    print_code "pv -s 10M /dev/urandom | head -c 10M > /tmp/test_file"
    echo -e "${BLUE}Generating 10MB of random data:${RESET}"
    pv -s 10M /dev/urandom 2>&1 | head -c 10M > /tmp/test_file_demo
    rm -f /tmp/test_file_demo
    
    wait_for_user
    
    print_subheader "Use Case: Monitoring file copy"
    
    # Create a test file
    dd if=/dev/urandom of=large_file.bin bs=1M count=5 2>/dev/null
    
    print_code "pv large_file.bin > copy.bin"
    pv large_file.bin > copy.bin 2>&1
    
    rm -f large_file.bin copy.bin
    
    wait_for_user
}

#
# MAIN MENU
#
show_menu() {
    clear
    fancy_title "I/O REDIRECT"
    
    echo ""
    echo -e "${WHITE}Select a demo to run:${RESET}"
    echo ""
    echo -e "  ${CYAN}1${RESET})  File Descriptors - Fundamentals"
    echo -e "  ${CYAN}2${RESET})  Output Redirection (>, >>)"
    echo -e "  ${CYAN}3${RESET})  stderr Redirection (2>, 2>>)"
    echo -e "  ${CYAN}4${RESET})  Stream Combining (2>&1, &>)"
    echo -e "  ${CYAN}5${RESET})  Input Redirection (<)"
    echo -e "  ${CYAN}6${RESET})  Here Documents (<<)"
    echo -e "  ${CYAN}7${RESET})  Here Strings (<<<)"
    echo -e "  ${CYAN}8${RESET})  /dev/null - The Black Hole"
    echo -e "  ${CYAN}9${RESET})  tee - Stream Duplication"
    echo -e "  ${CYAN}10${RESET}) Integrated Example"
    echo -e "  ${CYAN}11${RESET}) ${STAR} Progress Bar with pv"
    echo ""
    echo -e "  ${CYAN}a${RESET})  Run ALL demos"
    echo -e "  ${CYAN}q${RESET})  Exit"
    echo ""
    echo -n "Your choice: "
}

run_all_demos() {
    demo_file_descriptors
    demo_output_redirect
    demo_stderr_redirect
    demo_stream_combine
    demo_input_redirect
    demo_here_documents
    demo_here_strings
    demo_dev_null
    demo_tee
    demo_integrated
    demo_progress_bar
    
    print_header "🎉 ALL DEMOS COMPLETED!"
    echo -e "${GREEN}Congratulations! You have covered all I/O redirection concepts.${RESET}"
    echo ""
    echo -e "${WHITE}Summary:${RESET}"
    echo "  ${BULLET} File Descriptors: 0=stdin, 1=stdout, 2=stderr"
    echo "  ${BULLET} Output: > (overwrite), >> (append)"
    echo "  ${BULLET} Stderr: 2>, 2>>, 2>&1, &>"
    echo "  ${BULLET} Input: <, <<, <<<"
    echo "  ${BULLET} Suppression: /dev/null"
    echo "  ${BULLET} Duplication: tee, tee -a"
    echo ""
}

#
# MAIN
#
main() {
    case "${1:-menu}" in
        1) demo_file_descriptors ;;
        2) demo_output_redirect ;;
        3) demo_stderr_redirect ;;
        4) demo_stream_combine ;;
        5) demo_input_redirect ;;
        6) demo_here_documents ;;
        7) demo_here_strings ;;
        8) demo_dev_null ;;
        9) demo_tee ;;
        10) demo_integrated ;;
        11) demo_progress_bar ;;
        all|a) run_all_demos ;;
        menu|"")
            while true; do
                show_menu
                read -r choice
                case "$choice" in
                    1) demo_file_descriptors ;;
                    2) demo_output_redirect ;;
                    3) demo_stderr_redirect ;;
                    4) demo_stream_combine ;;
                    5) demo_input_redirect ;;
                    6) demo_here_documents ;;
                    7) demo_here_strings ;;
                    8) demo_dev_null ;;
                    9) demo_tee ;;
                    10) demo_integrated ;;
                    11) demo_progress_bar ;;
                    a|A) run_all_demos ;;
                    q|Q) 
                        echo -e "\n${GREEN}Goodbye!${RESET}"
                        exit 0 
                        ;;
                    *) echo -e "${RED}Invalid option${RESET}" ;;
                esac
            done
            ;;
        *)
            echo "Usage: $0 [1-11|all|menu]"
            exit 1
            ;;
    esac
}

main "$@"
