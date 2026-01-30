#!/bin/bash
#
#  S03_03_demo_getopts.sh
# Demonstration: Parsing arguments and options in Bash scripts
#
#
# DESCRIPTION:
#   Demonstration script for positional parameters, $@, $*, shift,
#   getopts and long options parsing.
#
# USAGE:
#   ./S03_03_demo_getopts.sh [options]
#
# OPTIONS:
#   -h, --help      Display this help
#   -i, --interactive   Interactive mode
#   -s, --section NUM   Run only one section (1-7)
#   -d, --demo NAME     Run a specific demo
#
# AUTHOR: SO Seminar Kit - Bucharest UES
# VERSION: 1.0
#

set -e

# ═══════════════════════════════════════════════════════════════════════════════
# CONFIGURATION
# ═══════════════════════════════════════════════════════════════════════════════

DEMO_DIR="$HOME/getopts_demo_lab"
INTERACTIVE=false
RUN_SECTION=""
SPECIFIC_DEMO=""

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

# ═══════════════════════════════════════════════════════════════════════════════
# UTILITY FUNCTIONS
# ═══════════════════════════════════════════════════════════════════════════════

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

print_code_block() {
    local title="$1"
    echo ""
    echo -e "${GREEN}┌─ 📝 $title ─────────────────────────────────────────────────────┐${NC}"
}

print_code_end() {
    echo -e "${GREEN}└────────────────────────────────────────────────────────────────────┘${NC}"
}

print_warning() {
    local text="$1"
    echo -e "\n${RED}⚠️  Pitfall:${NC} ${YELLOW}$text${NC}"
}

print_tip() {
    local text="$1"
    echo -e "\n${GREEN}💚 TIP:${NC} $text"
}

print_prediction() {
    local question="$1"
    echo ""
    echo -e "${BLUE}┌─ 🤔 PREDICTION ────────────────────────────────────────────────────┐${NC}"
    echo -e "${BLUE}│${NC} $question"
    echo -e "${BLUE}└────────────────────────────────────────────────────────────────────┘${NC}"
}

run_script_demo() {
    local script_content="$1"
    local script_args="$2"
    local description="$3"
    
    # Create temporary script
    local tmp_script="$DEMO_DIR/tmp_demo_$$.sh"
    echo "$script_content" > "$tmp_script"
    chmod +x "$tmp_script"
    
    echo -e "${GREEN}▶${NC} ${BOLD}./script.sh $script_args${NC}"
    [[ -n "$description" ]] && echo -e "  ${GRAY}↳ $description${NC}"
    echo -e "${DIM}─────────── OUTPUT ───────────${NC}"
    bash "$tmp_script" $script_args 2>&1 || true
    echo -e "${DIM}──────────────────────────────${NC}"
    
    rm -f "$tmp_script"
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
 📋 getopts and Argument Parsing Demo - Usage
═══════════════════════════════════════════════════════════════════════════════

SYNTAX:
  ./S03_03_demo_getopts.sh [options]

OPTIONS:
  -h, --help          Display this help
  -i, --interactive   Interactive mode with pauses between sections
  -s, --section NUM   Run only the specified section (1-7)
  -d, --demo NAME     Run a specific demo

SECTIONS:
  1 - Positional parameters ($1, $2, etc.)
  2 - $@ vs $* - the crucial difference
  3 - shift and iterative processing
  4 - Default values and expansions
  5 - getopts for short options
  6 - Long options (--option)
  7 - Complete professional script

EXAMPLES:
  ./S03_03_demo_getopts.sh -i              # Full interactive demo
  ./S03_03_demo_getopts.sh -s 5            # Only getopts section
  ./S03_03_demo_getopts.sh -d professional # Professional script demo

═══════════════════════════════════════════════════════════════════════════════
EOF
}

setup_demo() {
    mkdir -p "$DEMO_DIR"
    echo "Line 1" > "$DEMO_DIR/test_file.txt"
    echo "Line 2" >> "$DEMO_DIR/test_file.txt"
    echo "Line 3" >> "$DEMO_DIR/test_file.txt"
}

# ═══════════════════════════════════════════════════════════════════════════════
# SECTION 1: POSITIONAL PARAMETERS
# ═══════════════════════════════════════════════════════════════════════════════

section_1_positional() {
    print_header "📚 SECTION 1: Positional Parameters"
    
    setup_demo
    cd "$DEMO_DIR"
    
    print_concept "Special variables for arguments in Bash"
    
    print_subheader "1.1 Basic variables"
    
    echo ""
    cat << 'TABLE'
╔═══════════╦═══════════════════════════════════════════════════════════════════╗
║ Variable  ║ Meaning                                                           ║
╠═══════════╬═══════════════════════════════════════════════════════════════════╣
║    $0     ║ Script name                                                       ║
║    $1     ║ First argument                                                    ║
║    $2     ║ Second argument                                                   ║
║   ...     ║ ... and so on up to $9                                            ║
║  ${10}    ║ 10th argument (requires braces!)                                  ║
║    $#     ║ Total number of arguments                                         ║
║    $@     ║ All arguments (as separate list)                                  ║
║    $*     ║ All arguments (as single string)                                  ║
║    $?     ║ Exit code of last command                                         ║
║    $$     ║ PID of current shell                                              ║
║    $!     ║ PID of last background process                                    ║
╚═══════════╩═══════════════════════════════════════════════════════════════════╝
TABLE
    
    print_subheader "1.2 Demonstration $0, $1, $2, $#"
    
    local demo_script='#!/bin/bash
echo "Script name (\$0): $0"
echo "First argument (\$1): $1"
echo "Second argument (\$2): $2"
echo "Number of arguments (\$#): $#"'
    
    print_code_block "Demonstration script"
    echo "$demo_script"
    print_code_end
    
    print_prediction "What will the script display when we run: ./script.sh hello world extra ?"
    pause_interactive
    
    run_script_demo "$demo_script" "hello world extra" ""
    
    # ${10} vs $10
    print_subheader "1.3 ⚠️ Pitfall: \${10} vs \$10"
    
    print_warning "\$10 is NOT the 10th argument!"
    
    echo ""
    echo "  \$10  = \$1 followed by character '0' (i.e.: 'hello' + '0' = 'hello0')"
    echo "  \${10} = 10th argument (correct!)"
    
    local demo_10='#!/bin/bash
echo "Wrong - \$10: $10"
echo "Correct - \${10}: ${10}"'
    
    print_code_block "Demonstration \${10}"
    echo "$demo_10"
    print_code_end
    
    run_script_demo "$demo_10" "a b c d e f g h i TEN eleven" ""
    
    print_tip "Always use braces for arguments >= 10: \${10}, \${11}, etc."
    
    pause_interactive
}

# ═══════════════════════════════════════════════════════════════════════════════
# SECTION 2: $@ VS $*
# ═══════════════════════════════════════════════════════════════════════════════

section_2_at_vs_star() {
    print_header "📚 SECTION 2: \$@ vs \$* - The Crucial Difference"
    
    cd "$DEMO_DIR"
    
    print_concept "Different behaviour of \$@ and \$* in different contexts"
    
    print_subheader "2.1 Without quotes - Identical"
    
    echo ""
    echo "  ${WHITE}Without quotes, \$@ and \$* behave identically:${NC}"
    echo "  Both expand to the list of arguments separated."
    
    local demo_unquoted='#!/bin/bash
echo "=== Without quotes ==="
echo "With \$@:"
for arg in $@; do echo "  [$arg]"; done
echo "With \$*:"
for arg in $*; do echo "  [$arg]"; done'
    
    run_script_demo "$demo_unquoted" "hello world" ""
    
    print_subheader "2.2 With quotes - DIFFERENT!"
    
    print_warning "With quotes, behaviour differs completely!"
    
    echo ""
    cat << 'DIFF'
╔═══════════════════════════════════════════════════════════════════════════════╗
║                    THE CRUCIAL DIFFERENCE                                     ║
╠═══════════════════════════════════════════════════════════════════════════════╣
║                                                                               ║
║  "$@" = Each argument keeps its identity                                      ║
║         "arg1" "arg2" "arg3"  → 3 separate elements                           ║
║                                                                               ║
║  "$*" = All arguments concatenated into a single string                       ║
║         "arg1 arg2 arg3"      → 1 element                                     ║
║                                                                               ║
╚═══════════════════════════════════════════════════════════════════════════════╝
DIFF
    
    local demo_quoted='#!/bin/bash
echo "=== With quotes ==="
echo ""
echo "With \"\$@\" (separate):"
for arg in "$@"; do echo "  [$arg]"; done

echo ""
echo "With \"\$*\" (concatenated):"
for arg in "$*"; do echo "  [$arg]"; done'
    
    print_code_block "Demonstration with quotes"
    echo "$demo_quoted"
    print_code_end
    
    print_prediction "How many lines will each for display when we run: ./script.sh \"hello world\" test ?"
    pause_interactive
    
    run_script_demo "$demo_quoted" '"hello world" test' ""
    
    # When it matters
    print_subheader "2.3 Why does it matter? - Arguments with spaces"
    
    echo ""
    echo "  ${WHITE}Scenario: Script that processes files${NC}"
    echo ""
    echo "  User runs: ./process.sh 'my file.txt' 'other file.txt'"
    
    local demo_files_wrong='#!/bin/bash
echo "WRONG - with \$@:"
for f in $@; do
    echo "  Processing: [$f]"
done'
    
    local demo_files_right='#!/bin/bash
echo "CORRECT - with \"\$@\":"
for f in "$@"; do
    echo "  Processing: [$f]"
done'
    
    print_code_block "WRONG processing"
    echo "$demo_files_wrong"
    print_code_end
    
    run_script_demo "$demo_files_wrong" '"my file.txt" "other file.txt"' ""
    
    print_code_block "CORRECT processing"
    echo "$demo_files_right"
    print_code_end
    
    run_script_demo "$demo_files_right" '"my file.txt" "other file.txt"' ""
    
    print_tip "Golden rule: ALWAYS use \"\$@\" with quotes to iterate through arguments!"
    
    pause_interactive
}

# ═══════════════════════════════════════════════════════════════════════════════
# SECTION 3: SHIFT
# ═══════════════════════════════════════════════════════════════════════════════

section_3_shift() {
    print_header "📚 SECTION 3: shift - Iterative Processing"
    
    cd "$DEMO_DIR"
    
    print_concept "shift removes the first argument and shifts the rest up"
    
    print_subheader "3.1 How shift works"
    
    echo ""
    cat << 'DIAGRAM'
╔═══════════════════════════════════════════════════════════════════════════════╗
║  Before shift:       $1=A    $2=B    $3=C    $4=D    $#=4                      ║
║                       ↓                                                       ║
║  After shift:        $1=B    $2=C    $3=D            $#=3                      ║
║                       ↓                                                       ║
║  After shift 2:      $1=D                            $#=1                      ║
╚═══════════════════════════════════════════════════════════════════════════════╝
DIAGRAM
    
    local demo_shift='#!/bin/bash
echo "Initial: \$1=$1, \$2=$2, \$3=$3, \$#=$#"
shift
echo "After shift: \$1=$1, \$2=$2, \$3=$3, \$#=$#"
shift
echo "After another shift: \$1=$1, \$2=$2, \$3=$3, \$#=$#"'
    
    print_code_block "Demonstration shift"
    echo "$demo_shift"
    print_code_end
    
    run_script_demo "$demo_shift" "A B C D E" ""
    
    # shift N
    print_subheader "3.2 shift N - Remove N arguments"
    
    local demo_shift_n='#!/bin/bash
echo "Initial: \$@= $@, \$#=$#"
shift 3
echo "After shift 3: \$@= $@, \$#=$#"'
    
    run_script_demo "$demo_shift_n" "uno dos tres cuatro cinco" ""
    
    # Processing pattern
    print_subheader "3.3 Pattern: Iterative processing with while + shift"
    
    local demo_while_shift='#!/bin/bash
echo "Processing arguments:"
counter=1
while [[ $# -gt 0 ]]; do
    echo "  Argument $counter: $1"
    shift
    ((counter++))
done
echo "Done! No more arguments."'
    
    print_code_block "Pattern while + shift"
    echo "$demo_while_shift"
    print_code_end
    
    run_script_demo "$demo_while_shift" "alpha beta gamma delta" ""
    
    # Pattern with options
    print_subheader "3.4 Pattern: Manual options parsing"
    
    local demo_manual_opts='#!/bin/bash
verbose=false
output=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        -v|--verbose)
            verbose=true
            shift
            ;;
        -o|--output)
            output="$2"
            shift 2
            ;;
        -*)
            echo "Unknown option: $1"
            exit 1
            ;;
        *)
            # Non-option argument
            echo "Argument: $1"
            shift
            ;;
    esac
done

echo ""
echo "Result: verbose=$verbose, output=$output"'
    
    print_code_block "Manual parsing with while/case/shift"
    echo "$demo_manual_opts"
    print_code_end
    
    run_script_demo "$demo_manual_opts" "-v --output results.txt file1.txt file2.txt" ""
    
    print_tip "shift 2 is essential for options that have a value (like -o FILE)"
    
    pause_interactive
}

# ═══════════════════════════════════════════════════════════════════════════════
# SECTION 4: DEFAULT VALUES AND EXPANSIONS
# ═══════════════════════════════════════════════════════════════════════════════

section_4_defaults() {
    print_header "📚 SECTION 4: Default Values and Expansions"
    
    cd "$DEMO_DIR"
    
    print_concept "Expansions for default values, errors and string manipulation"
    
    print_subheader "4.1 Default values"
    
    echo ""
    cat << 'TABLE'
╔═══════════════════╦═══════════════════════════════════════════════════════════╗
║ Syntax            ║ Meaning                                                   ║
╠═══════════════════╬═══════════════════════════════════════════════════════════╣
║ ${VAR:-default}   ║ If VAR is unset/empty, use "default"                      ║
║ ${VAR:=default}   ║ If VAR is unset/empty, set VAR="default"                  ║
║ ${VAR:+alt}       ║ If VAR is set, use "alt"                                  ║
║ ${VAR:?error}     ║ If VAR is unset/empty, display error and exit             ║
╚═══════════════════╩═══════════════════════════════════════════════════════════╝
TABLE
    
    local demo_defaults='#!/bin/bash
# ${VAR:-default} - use default without modifying VAR
name="${1:-Anonymous}"
echo "Hello, $name!"

# ${VAR:=default} - set VAR if empty
: ${CONFIG_FILE:=/etc/default.conf}
echo "Config: $CONFIG_FILE"

# ${VAR:+alt} - replace only if set
debug_flag="${DEBUG:+--debug}"
echo "Debug flag: [$debug_flag]"'
    
    print_code_block "Demonstration default values"
    echo "$demo_defaults"
    print_code_end
    
    echo -e "\n${WHITE}Without arguments:${NC}"
    run_script_demo "$demo_defaults" "" ""
    
    echo -e "\n${WHITE}With argument:${NC}"
    run_script_demo "$demo_defaults" "Maria" ""
    
    # :? for errors
    print_subheader "4.2 Required validation with :?"
    
    local demo_required='#!/bin/bash
# Fail fast if variable is missing
input_file="${1:?Error: Input file is missing!}"
echo "Processing: $input_file"'
    
    print_code_block "Validation with :?"
    echo "$demo_required"
    print_code_end
    
    echo -e "\n${WHITE}Without argument (error):${NC}"
    run_script_demo "$demo_required" "" ""
    
    echo -e "\n${WHITE}With argument (OK):${NC}"
    run_script_demo "$demo_required" "data.txt" ""
    
    # String manipulation
    print_subheader "4.3 String manipulation"
    
    echo ""
    cat << 'TABLE'
╔═══════════════════════╦═══════════════════════════════════════════════════════╗
║ Syntax                ║ Meaning                                               ║
╠═══════════════════════╬═══════════════════════════════════════════════════════╣
║ ${#VAR}               ║ String length                                         ║
║ ${VAR%pattern}        ║ Remove shortest matching suffix                       ║
║ ${VAR%%pattern}       ║ Remove longest matching suffix                        ║
║ ${VAR#pattern}        ║ Remove shortest matching prefix                       ║
║ ${VAR##pattern}       ║ Remove longest matching prefix                        ║
║ ${VAR/pattern/repl}   ║ Replace first occurrence                              ║
║ ${VAR//pattern/repl}  ║ Replace all occurrences                               ║
╚═══════════════════════╩═══════════════════════════════════════════════════════╝
TABLE
    
    local demo_strings='#!/bin/bash
filepath="/home/user/documents/report.tar.gz"
echo "Full path: $filepath"
echo ""
echo "Length: ${#filepath}"
echo "Filename (##*/): ${filepath##*/}"
echo "Directory (%/*): ${filepath%/*}"
echo "Without extension (%.*): ${filepath%.*}"
echo "Without all extensions (%%.*): ${filepath%%.*}"
echo "Extension (#*.): ${filepath#*.}"
echo "First extension (##*.): ${filepath##*.}"'
    
    print_code_block "Path manipulation"
    echo "$demo_strings"
    print_code_end
    
    run_script_demo "$demo_strings" "" ""
    
    print_tip "Use basename and dirname for portability, but expansions are faster"
    
    pause_interactive
}

# ═══════════════════════════════════════════════════════════════════════════════
# SECTION 5: GETOPTS
# ═══════════════════════════════════════════════════════════════════════════════

section_5_getopts() {
    print_header "📚 SECTION 5: getopts - Short Options"
    
    cd "$DEMO_DIR"
    
    print_concept "getopts - standard POSIX parsing for single-letter options"
    
    print_subheader "5.1 Basic syntax"
    
    echo ""
    cat << 'SYNTAX'
╔═══════════════════════════════════════════════════════════════════════════════╗
║                                                                               ║
║   while getopts "OPTSTRING" opt; do                                           ║
║       case "$opt" in                                                          ║
║           a) ... ;;                                                           ║
║           b) ... ;;    # OPTARG contains the value                            ║
║           ?) ... ;;    # Invalid option                                       ║
║       esac                                                                    ║
║   done                                                                        ║
║   shift $((OPTIND - 1))    # Remove processed options                         ║
║                                                                               ║
╠═══════════════════════════════════════════════════════════════════════════════╣
║ OPTSTRING:                                                                    ║
║   a     = simple option (-a)                                                  ║
║   b:    = option with required value (-b VALUE)                               ║
║   :     = at beginning: silent mode for errors                                ║
║                                                                               ║
║ Special variables:                                                            ║
║   OPTARG = value of current option                                            ║
║   OPTIND = index of next argument to process                                  ║
║                                                                               ║
╚═══════════════════════════════════════════════════════════════════════════════╝
SYNTAX
    
    print_subheader "5.2 Simple example"
    
    local demo_simple='#!/bin/bash
verbose=false
count=1

while getopts "vc:" opt; do
    case "$opt" in
        v) verbose=true ;;
        c) count="$OPTARG" ;;
        ?) echo "Invalid option"; exit 1 ;;
    esac
done

shift $((OPTIND - 1))

echo "verbose: $verbose"
echo "count: $count"
echo "Remaining arguments: $@"'
    
    print_code_block "simple getopts"
    echo "$demo_simple"
    print_code_end
    
    run_script_demo "$demo_simple" "-v -c 5 file1.txt file2.txt" ""
    
    run_script_demo "$demo_simple" "-c 10 data.txt" ""
    
    # Combined options
    print_subheader "5.3 Combined options"
    
    echo ""
    echo "  ${WHITE}getopts accepts combined options:${NC}"
    echo "  -a -b -c  is equivalent to  -abc"
    
    run_script_demo "$demo_simple" "-vc 3 test.txt" "Combined options"
    
    # Errors
    print_subheader "5.4 Error handling"
    
    echo ""
    echo "  ${WHITE}Two modes of error handling:${NC}"
    echo ""
    echo "  1. Default mode (no : at beginning)"
    echo "     - getopts displays error"
    echo "     - opt becomes '?'"
    echo ""
    echo "  2. Silent mode (: at beginning)"
    echo "     - Doesn't display error"
    echo "     - opt becomes ':' for missing argument"
    echo "     - opt becomes '?' for unknown option"
    echo "     - OPTARG contains the problematic option"
    
    local demo_silent='#!/bin/bash
while getopts ":vf:" opt; do
    case "$opt" in
        v) echo "Verbose enabled" ;;
        f) echo "File: $OPTARG" ;;
        :) echo "Error: -$OPTARG requires argument"; exit 1 ;;
        ?) echo "Error: unknown option -$OPTARG"; exit 1 ;;
    esac
done'
    
    print_code_block "Silent mode with custom messages"
    echo "$demo_silent"
    print_code_end
    
    run_script_demo "$demo_silent" "-f" "Missing argument for -f"
    
    run_script_demo "$demo_silent" "-x" "Unknown option"
    
    print_subheader "5.5 Importance of shift \$((OPTIND - 1))"
    
    print_warning "Without shift, non-option arguments are not accessible correctly!"
    
    local demo_noshift='#!/bin/bash
while getopts "v" opt; do
    case "$opt" in
        v) echo "Verbose" ;;
    esac
done
# WITHOUT shift!
echo "First argument: $1"
echo "All arguments: $@"'
    
    local demo_withshift='#!/bin/bash
while getopts "v" opt; do
    case "$opt" in
        v) echo "Verbose" ;;
    esac
done
shift $((OPTIND - 1))
echo "First argument: $1"
echo "All arguments: $@"'
    
    echo -e "\n${RED}WRONG - without shift:${NC}"
    run_script_demo "$demo_noshift" "-v file.txt data.txt" ""
    
    echo -e "\n${GREEN}CORRECT - with shift:${NC}"
    run_script_demo "$demo_withshift" "-v file.txt data.txt" ""
    
    print_tip "OPTIND indicates the position of the next unprocessed argument. shift removes the options."
    
    pause_interactive
}

# ═══════════════════════════════════════════════════════════════════════════════
# SECTION 6: LONG OPTIONS
# ═══════════════════════════════════════════════════════════════════════════════

section_6_long_options() {
    print_header "📚 SECTION 6: Long Options (--option)"
    
    cd "$DEMO_DIR"
    
    print_concept "getopts does NOT support long options - manual parsing needed"
    
    print_warning "getopts is only for short options! For --verbose, --output you need manual code."
    
    print_subheader "6.1 Manual pattern for long options"
    
    local demo_long='#!/bin/bash
verbose=false
output=""
input_files=()

while [[ $# -gt 0 ]]; do
    case "$1" in
        -v|--verbose)
            verbose=true
            shift
            ;;
        -o|--output)
            output="$2"
            shift 2
            ;;
        -h|--help)
            echo "Usage: script.sh [-v|--verbose] [-o|--output FILE] files..."
            exit 0
            ;;
        --)
            shift
            break  # Rest are arguments, not options
            ;;
        -*)
            echo "Unknown option: $1" >&2
            exit 1
            ;;
        *)
            input_files+=("$1")
            shift
            ;;
    esac
done

# Add arguments after -- as well
input_files+=("$@")

echo "verbose: $verbose"
echo "output: $output"
echo "files: ${input_files[*]}"'
    
    print_code_block "Parsing long options"
    echo "$demo_long"
    print_code_end
    
    run_script_demo "$demo_long" "--verbose --output results.txt file1.txt file2.txt" ""
    
    run_script_demo "$demo_long" "-v -o out.txt data.csv" "Short options work the same"
    
    # Options with =
    print_subheader "6.2 Options with = (--output=file)"
    
    local demo_equal='#!/bin/bash
verbose=false
output=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        -v|--verbose)
            verbose=true
            shift
            ;;
        -o|--output)
            output="$2"
            shift 2
            ;;
        --output=*)
            output="${1#*=}"  # Extract value after =
            shift
            ;;
        *)
            break
            ;;
    esac
done

echo "output: $output"
echo "remaining: $@"'
    
    print_code_block "Support for --option=value"
    echo "$demo_equal"
    print_code_end
    
    run_script_demo "$demo_equal" "--output=results.txt file.txt" ""
    
    # -- to stop parsing
    print_subheader "6.3 -- to stop options parsing"
    
    echo ""
    echo "  ${WHITE}Convention: -- separates options from arguments${NC}"
    echo ""
    echo "  Useful when arguments start with - :"
    echo "  ./script.sh --output log.txt -- -strange-filename.txt"
    
    local demo_dashdash='#!/bin/bash
while [[ $# -gt 0 ]]; do
    case "$1" in
        -o) output="$2"; shift 2 ;;
        --) shift; break ;;  # Stop parsing
        -*) echo "Option: $1"; shift ;;
        *) break ;;
    esac
done

echo "Remaining arguments:"
for arg in "$@"; do
    echo "  [$arg]"
done'
    
    run_script_demo "$demo_dashdash" "-o out.txt -- -weird-file.txt --not-option.txt" ""
    
    print_tip "Always support -- for robustness!"
    
    pause_interactive
}

# ═══════════════════════════════════════════════════════════════════════════════
# SECTION 7: COMPLETE PROFESSIONAL SCRIPT
# ═══════════════════════════════════════════════════════════════════════════════

section_7_professional() {
    print_header "📚 SECTION 7: Complete Professional Script"
    
    cd "$DEMO_DIR"
    
    print_concept "Complete pattern with all best practices"
    
    print_subheader "7.1 Structure of a professional script"
    
    cat << 'STRUCTURE'
╔═══════════════════════════════════════════════════════════════════════════════╗
║  PROFESSIONAL SCRIPT STRUCTURE:                                               ║
╠═══════════════════════════════════════════════════════════════════════════════╣
║  1. Shebang and set options (set -e, set -u)                                  ║
║  2. Header with documentation                                                 ║
║  3. Constants and global variables                                            ║
║  4. usage() function for help                                                 ║
║  5. Utility functions (log, error, cleanup)                                   ║
║  6. Main business logic function                                              ║
║  7. Argument parsing                                                          ║
║  8. Argument validation                                                       ║
║  9. Execution                                                                 ║
╚═══════════════════════════════════════════════════════════════════════════════╝
STRUCTURE
    
    print_subheader "7.2 Complete Example Script"
    
    # Create complete script
    local professional_script='#!/bin/bash
#
# fileprocessor.sh - File processing with complete options
#
#
# USAGE:
#   ./fileprocessor.sh [options] file [files...]
#
# OPTIONS:
#   -h, --help          Display this help
#   -v, --verbose       Verbose mode
#   -o, --output FILE   Output file (default: stdout)
#   -n, --dry-run       Simulate without executing
#   -q, --quiet         Quiet mode
#
# EXAMPLES:
#   ./fileprocessor.sh -v file.txt
#   ./fileprocessor.sh --output=result.txt *.log
#   ./fileprocessor.sh -n --verbose data/*.csv
#
#

set -e          # Exit on error
set -u          # Error on undefined variables
set -o pipefail # Pipe fails if any command fails

#
# CONSTANTS AND DEFAULTS
#

readonly SCRIPT_NAME="${0##*/}"
readonly SCRIPT_VERSION="1.0.0"

# Default values
VERBOSE=false
DRY_RUN=false
QUIET=false
OUTPUT_FILE=""
INPUT_FILES=()

#
# UTILITY FUNCTIONS
#

usage() {
    cat << EOF
Usage: $SCRIPT_NAME [options] file [files...]

Processes the specified files and generates a report.

OPTIONS:
  -h, --help          Display this help and exit
  -V, --version       Display version
  -v, --verbose       Enable verbose output
  -o, --output FILE   Write output to FILE (default: stdout)
  -n, --dry-run       Simulate actions without executing
  -q, --quiet         Suppress all non-error messages

EXAMPLES:
  $SCRIPT_NAME file.txt                    Process a file
  $SCRIPT_NAME -v -o out.txt *.log         Verbose, output to out.txt
  $SCRIPT_NAME --dry-run data/*.csv        Simulate on CSV files

Report bugs: Open an issue on GitHub
EOF
}

version() {
    echo "$SCRIPT_NAME version $SCRIPT_VERSION"
}

log() {
    [[ "$QUIET" == true ]] && return
    echo "[INFO] $*" >&2
}

log_verbose() {
    [[ "$VERBOSE" == true ]] && log "$@"
}

error() {
    echo "[ERROR] $*" >&2
}

die() {
    error "$@"
    exit 1
}

#
# BUSINESS LOGIC
#

process_file() {
    local file="$1"
    
    log_verbose "Processing: $file"
    
    if [[ ! -f "$file" ]]; then
        error "File does not exist: $file"
        return 1
    fi
    
    if [[ "$DRY_RUN" == true ]]; then
        log "[DRY-RUN] Would process: $file"
        return 0
    fi
    
    # Actual processing
    local lines=$(wc -l < "$file")
    local words=$(wc -w < "$file")
    local bytes=$(wc -c < "$file")
    
    echo "$file: $lines lines, $words words, $bytes bytes"
}

main() {
    log_verbose "Starting processing..."
    log_verbose "Files to process: ${#INPUT_FILES[@]}"
    
    local output_cmd="cat"
    [[ -n "$OUTPUT_FILE" ]] && output_cmd="tee $OUTPUT_FILE"
    
    for file in "${INPUT_FILES[@]}"; do
        process_file "$file"
    done | $output_cmd
    
    log_verbose "Processing complete."
}

#
# ARGUMENT PARSING
#

parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                usage
                exit 0
                ;;
            -V|--version)
                version
                exit 0
                ;;
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            -q|--quiet)
                QUIET=true
                shift
                ;;
            -n|--dry-run)
                DRY_RUN=true
                shift
                ;;
            -o|--output)
                [[ -z "${2:-}" ]] && die "Option $1 requires argument"
                OUTPUT_FILE="$2"
                shift 2
                ;;
            --output=*)
                OUTPUT_FILE="${1#*=}"
                shift
                ;;
            --)
                shift
                break
                ;;
            -*)
                die "Unknown option: $1. Use -h for help."
                ;;
            *)
                INPUT_FILES+=("$1")
                shift
                ;;
        esac
    done
    
    # Add remaining arguments after --
    INPUT_FILES+=("$@")
}

#
# VALIDATION
#

validate_arguments() {
    # Check that we have at least one file
    if [[ ${#INPUT_FILES[@]} -eq 0 ]]; then
        error "Missing files to process."
        echo "Usage: $SCRIPT_NAME [options] file [files...]" >&2
        echo "Try '\''$SCRIPT_NAME --help'\'' for more information." >&2
        exit 1
    fi
    
    # Check that verbose and quiet are not both active
    if [[ "$VERBOSE" == true && "$QUIET" == true ]]; then
        die "Options --verbose and --quiet are mutually exclusive."
    fi
}

#
# EXECUTION
#

parse_arguments "$@"
validate_arguments
main'
    
    # Save script
    echo "$professional_script" > "$DEMO_DIR/fileprocessor.sh"
    chmod +x "$DEMO_DIR/fileprocessor.sh"
    
    # Create test files
    echo -e "Line 1\nLine 2\nLine 3" > "$DEMO_DIR/test1.txt"
    echo -e "Hello World" > "$DEMO_DIR/test2.txt"
    
    print_code_block "Complete script (saved in fileprocessor.sh)"
    head -80 "$DEMO_DIR/fileprocessor.sh"
    echo "... [continues] ..."
    print_code_end
    
    print_subheader "7.3 Testing script"
    
    echo -e "\n${WHITE}Test --help:${NC}"
    "$DEMO_DIR/fileprocessor.sh" --help 2>&1 | head -20
    
    echo -e "\n${WHITE}Test without arguments (error):${NC}"
    "$DEMO_DIR/fileprocessor.sh" 2>&1 || true
    
    echo -e "\n${WHITE}Normal test:${NC}"
    "$DEMO_DIR/fileprocessor.sh" "$DEMO_DIR/test1.txt" "$DEMO_DIR/test2.txt"
    
    echo -e "\n${WHITE}Test verbose:${NC}"
    "$DEMO_DIR/fileprocessor.sh" -v "$DEMO_DIR/test1.txt"
    
    echo -e "\n${WHITE}Test dry-run:${NC}"
    "$DEMO_DIR/fileprocessor.sh" --dry-run --verbose "$DEMO_DIR/test1.txt"
    
    print_tip "Copy this pattern for your professional scripts!"
    
    pause_interactive
}

# ═══════════════════════════════════════════════════════════════════════════════
# SUMMARY
# ═══════════════════════════════════════════════════════════════════════════════

show_summary() {
    print_header "📋 SUMMARY: Argument Parsing"
    
    cat << 'SUMMARY'
╔═══════════════════════════════════════════════════════════════════════════════╗
║                           QUICK CHEAT SHEET                                   ║
╠═══════════════════════════════════════════════════════════════════════════════╣
║ POSITIONAL PARAMETERS:                                                        ║
║   $0        = Script name                                                     ║
║   $1-$9     = Arguments (use ${10} for >= 10)                                 ║
║   $#        = Number of arguments                                             ║
║   "$@"      = All arguments (ALWAYS with quotes!)                             ║
║                                                                               ║
║ DEFAULT VALUES:                                                               ║
║   ${VAR:-default}   = Use default if VAR is empty                             ║
║   ${VAR:=default}   = Set VAR to default if empty                             ║
║   ${VAR:?error}     = Error if VAR is empty                                   ║
║                                                                               ║
║ SHIFT:                                                                        ║
║   shift       = Remove $1, shift rest up                                      ║
║   shift N     = Remove first N arguments                                      ║
║                                                                               ║
║ GETOPTS (short options):                                                      ║
║   while getopts ":vf:" opt; do                                                ║
║       case "$opt" in                                                          ║
║           v) verbose=true ;;                                                  ║
║           f) file="$OPTARG" ;;                                                ║
║           :) echo "Missing argument for -$OPTARG" ;;                          ║
║           ?) echo "Unknown option: -$OPTARG" ;;                               ║
║       esac                                                                    ║
║   done                                                                        ║
║   shift $((OPTIND - 1))    # CRUCIAL!                                         ║
║                                                                               ║
║ LONG OPTIONS (manual):                                                        ║
║   while [[ $# -gt 0 ]]; do                                                    ║
║       case "$1" in                                                            ║
║           -v|--verbose) verbose=true; shift ;;                                ║
║           -o|--output)  output="$2"; shift 2 ;;                               ║
║           --output=*)   output="${1#*=}"; shift ;;                            ║
║           --)           shift; break ;;                                       ║
║           -*)           echo "Error"; exit 1 ;;                               ║
║           *)            args+=("$1"); shift ;;                                ║
║       esac                                                                    ║
║   done                                                                        ║
║                                                                               ║
╚═══════════════════════════════════════════════════════════════════════════════╝
SUMMARY
    
    echo ""
    echo -e "${GREEN}✓ Demo complete!${NC}"
    echo ""
}

# ═══════════════════════════════════════════════════════════════════════════════
# MAIN
# ═══════════════════════════════════════════════════════════════════════════════

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
            -d|--demo)
                SPECIFIC_DEMO="$2"
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
    
    if [[ -n "$RUN_SECTION" ]]; then
        case "$RUN_SECTION" in
            1) section_1_positional ;;
            2) section_2_at_vs_star ;;
            3) section_3_shift ;;
            4) section_4_defaults ;;
            5) section_5_getopts ;;
            6) section_6_long_options ;;
            7) section_7_professional ;;
            *)
                echo -e "${RED}Invalid section: $RUN_SECTION${NC}"
                exit 1
                ;;
        esac
    elif [[ -n "$SPECIFIC_DEMO" ]]; then
        case "$SPECIFIC_DEMO" in
            professional|prof) section_7_professional ;;
            getopts) section_5_getopts ;;
            shift) section_3_shift ;;
            *)
                echo -e "${RED}Unknown demo: $SPECIFIC_DEMO${NC}"
                exit 1
                ;;
        esac
    else
        section_1_positional
        section_2_at_vs_star
        section_3_shift
        section_4_defaults
        section_5_getopts
        section_6_long_options
        section_7_professional
    fi
    
    show_summary
}

main "$@"
