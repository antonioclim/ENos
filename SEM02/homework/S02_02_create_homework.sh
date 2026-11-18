#!/bin/bash
# 
#  S02_02_create_homework.sh - Homework Template Generator Seminar 2
# 
#
# DESCRIPTION:
#     Creates directory structure and template files for the
#     Seminar 2 homework. Includes templates for all exercises and
#     a self-check script.
#
# USAGE:
#     ./S02_02_create_homework.sh "Popescu Ion" 1051
#     ./S02_02_create_homework.sh --interactive
#
# AUTHOR: Assistant for ASE Bucharest - CSIE
# VERSION: 1.0
# DATE: January 2025
# 

set -e

# 
# SECTION 1: CONFIGURATION AND COLOURS
# 

# ANSI Colours
if [[ -t 1 ]]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    MAGENTA='\033[0;35m'
    CYAN='\033[0;36m'
    WHITE='\033[1;37m'
    NC='\033[0m' # No Colour
    BOLD='\033[1m'
else
    RED='' GREEN='' YELLOW='' BLUE='' MAGENTA='' CYAN='' WHITE='' NC='' BOLD=''
fi

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SEMINAR_NUM="02"
TEMA_PREFIX="HW_SEM${SEMINAR_NUM}"

# 
# SECTION 2: UTILITY FUNCTIONS
# 

print_banner() {
    echo -e "${CYAN}"
    echo "╔═══════════════════════════════════════════════════════════════════════════════╗"
    echo "║                                                                               ║"
    echo "║   📝  HOMEWORK TEMPLATE GENERATOR - Seminar 2                               ║"
    echo "║       Operators | Redirection | Filters | Loops                               ║"
    echo "║                                                                               ║"
    echo "║       ASE Bucharest - CSIE | Operating Systems                                ║"
    echo "║                                                                               ║"
    echo "╚═══════════════════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

print_usage() {
    echo -e "${BOLD}Usage:${NC}"
    echo "  $0 \"Student Name\" group"
    echo "  $0 --interactive"
    echo ""
    echo -e "${BOLD}Examples:${NC}"
    echo "  $0 \"Popescu Ion\" 1051"
    echo "  $0 \"Maria Ionescu\" 1052"
    echo ""
    echo -e "${BOLD}Options:${NC}"
    echo "  -i, --interactive    Interactive mode (prompts for data)"
    echo "  -h, --help           Display this message"
    echo "  -o, --output DIR     Output directory (default: current directory)"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1" >&2
}

# Clean name to be valid as directory
sanitize_name() {
    local name="$1"
    # Replace non-alphanumeric characters with `_`
    # Keep Romanian letters transformed to ASCII
    echo "$name" | \
        sed 's/ă/a/g; s/â/a/g; s/î/i/g; s/ș/s/g; s/ț/t/g' | \
        sed 's/Ă/A/g; s/Â/A/g; s/Î/I/g; s/Ș/S/g; s/Ț/T/g' | \
        tr '[:upper:]' '[:lower:]' | \
        tr ' ' '_' | \
        tr -cd '[:alnum:]_-'
}

# 
# SECTION 3: ARGUMENT PARSING
# 

INTERACTIVE=false
OUTPUT_DIR="."
STUDENT_NAME=""
STUDENT_GROUP=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -i|--interactive)
            INTERACTIVE=true
            shift
            ;;
        -h|--help)
            print_banner
            print_usage
            exit 0
            ;;
        -o|--output)
            OUTPUT_DIR="$2"
            shift 2
            ;;
        -*)
            print_error "Unknown option: $1"
            print_usage
            exit 1
            ;;
        *)
            if [[ -z "$STUDENT_NAME" ]]; then
                STUDENT_NAME="$1"
            elif [[ -z "$STUDENT_GROUP" ]]; then
                STUDENT_GROUP="$1"
            else
                print_error "Too many arguments!"
                print_usage
                exit 1
            fi
            shift
            ;;
    esac
done

# 
# SECTION 4: DATA COLLECTION
# 

print_banner

if [[ "$INTERACTIVE" == true ]] || [[ -z "$STUDENT_NAME" ]] || [[ -z "$STUDENT_GROUP" ]]; then
    echo -e "${BOLD}📋 Enter your details:${NC}"
    echo ""
    
    if [[ -z "$STUDENT_NAME" ]]; then
        read -p "Full name: " STUDENT_NAME
    fi
    
    if [[ -z "$STUDENT_GROUP" ]]; then
        read -p "Group (e.g., 1051): " STUDENT_GROUP
    fi
    
    echo ""
fi

# Validation
if [[ -z "$STUDENT_NAME" ]]; then
    print_error "Student name is required!"
    exit 1
fi

if [[ -z "$STUDENT_GROUP" ]]; then
    print_error "Group is required!"
    exit 1
fi

# Generate directory name
SAFE_NAME=$(sanitize_name "$STUDENT_NAME")
DIR_NAME="${TEMA_PREFIX}_${SAFE_NAME}_${STUDENT_GROUP}"
TARGET_DIR="${OUTPUT_DIR}/${DIR_NAME}"

# Check existence
if [[ -d "$TARGET_DIR" ]]; then
    print_warning "Directory $TARGET_DIR already exists!"
    read -p "Overwrite? (y/n): " confirm
    if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
        print_info "Operation cancelled."
        exit 0
    fi
    rm -rf "$TARGET_DIR"
fi

# 
# SECTION 5: CREATE STRUCTURE
# 

echo -e "${BOLD}🔨 Creating homework structure...${NC}"
echo ""

# Create directories
mkdir -p "$TARGET_DIR"/{exercises,tests,output}
print_success "Created: $TARGET_DIR/"

# 
# SECTION 6: GENERATE TEMPLATE FILES
# 

# --- README.md ---
cat > "$TARGET_DIR/README.md" << EOF
#  Homework Seminar 2: Operators, Redirection, Filters, Loops

**Student:** ${STUDENT_NAME}  
**Group:** ${STUDENT_GROUP}  
**Generated:** $(date '+%Y-%m-%d %H:%M')

##  Homework Structure

\`\`\`
${DIR_NAME}/
├── README.md              # This file
├── exercises/
│   ├── ex1_operators.sh   # Exercise 1: Control operators
│   ├── ex2_redirection.sh # Exercise 2: I/O redirection
│   ├── ex3_filters.sh     # Exercise 3: Text filters
│   ├── ex4_loops.sh       # Exercise 4: Loops
│   └── ex5_integrated.sh  # Exercise 5: Integrated script
├── tests/
│   └── test_data/         # Test data
├── output/                # Output directory
└── check_homework.sh      # Self-check script
\`\`\`

##  Requirements

Complete each exercise according to the instructions in comments.
Run \`./check_homework.sh\` to verify progress.

##  Submission Checklist

- [ ] All scripts have shebang (\`#!/bin/bash\`)
- [ ] All scripts are executable (\`chmod +x\`)
- [ ] Each exercise works without errors
- [ ] I ran \`./check_homework.sh\` and fixed errors
- [ ] I archived the homework: \`tar -czvf ${DIR_NAME}.tar.gz ${DIR_NAME}/\`

##  Submission

1. Verify homework: \`./check_homework.sh\`
2. Archive: \`tar -czvf ${DIR_NAME}.tar.gz ${DIR_NAME}/\`
3. Upload to the course platform

---
*Auto-generated by S02_02_create_homework.sh*
EOF
print_success "Created: README.md"

# --- Exercise 1: Operators ---
cat > "$TARGET_DIR/exercises/ex1_operators.sh" << 'SCRIPT'
#!/bin/bash
# 
# EXERCISE 1: Control Operators (10%)
# 
#
# OBJECTIVE: Demonstrate understanding of control operators
#
# REQUIREMENTS:
# 1. Use the && operator to execute commands only if the previous succeeds
# 2. Use the || operator for error handling
# 3. Use the | (pipe) operator to connect commands
# 4. Use the & operator to run in background
# 5. Combine operators in a complex command
#
# Pitfall: DO NOT modify section comments (# [TEST-...])
# 

# [TEST-1] Create the "backup" directory if it doesn't exist, then display "OK"
# TIP: Use && to execute echo only if mkdir succeeds
# WRITE YOUR COMMAND BELOW:

# [TEST-2] Try to read a non-existent file and display an error
# TIP: Use || to handle the case when cat fails
# WRITE YOUR COMMAND BELOW:

# [TEST-3] Find your processes and count them
# TIP: Use | to connect ps with wc
# WRITE YOUR COMMAND BELOW:

# [TEST-4] Demonstrate running in background
# TIP: Start a sleep in background and display the PID
# WRITE YOUR COMMAND BELOW:

# [TEST-5] Complex command: check a file, process it and handle errors
# TIP: Combination of &&, ||, and |
# Example: Check if /etc/passwd exists, extract users, and count them
# WRITE YOUR COMMAND BELOW:

echo "Exercise 1 completed!"
SCRIPT
chmod +x "$TARGET_DIR/exercises/ex1_operators.sh"
print_success "Created: exercises/ex1_operators.sh"

# --- Exercise 2: Redirection ---
cat > "$TARGET_DIR/exercises/ex2_redirection.sh" << 'SCRIPT'
#!/bin/bash
# 
# EXERCISE 2: I/O Redirection (12%)
# 
#
# OBJECTIVE: Demonstrate understanding of I/O redirection
#
# REQUIREMENTS:
# 1. Use > to overwrite a file
# 2. Use >> to append to a file
# 3. Use 2> to redirect stderr
# 4. Use 2>&1 to combine stdout and stderr
# 5. Use << (here document) for multi-line input
#
# Pitfall: DO NOT modify section comments (# [TEST-...])
# 

# Working directory
WORK_DIR="../output"
mkdir -p "$WORK_DIR"

# [TEST-1] Create file "test1.txt" with text "First line"
# TIP: Use > to overwrite
# WRITE YOUR COMMAND BELOW:

# [TEST-2] Add "Second line" to the previously created file
# TIP: Use >> for append
# WRITE YOUR COMMAND BELOW:

# [TEST-3] Redirect errors from ls /nonexistent to a file
# TIP: Use 2> for stderr
# WRITE YOUR COMMAND BELOW:

# [TEST-4] Combine stdout and stderr into a single file
# TIP: Use command: ls /home /nonexistent 2>&1 > combined.txt
# or better: ls /home /nonexistent &> combined.txt
# WRITE YOUR COMMAND BELOW:

# [TEST-5] Use a Here Document to create a configuration file
# The file must contain at least 3 lines
# TIP: Use << EOF ... EOF
# WRITE YOUR COMMAND BELOW:

echo "Exercise 2 completed!"
echo "Check files created in $WORK_DIR"
SCRIPT
chmod +x "$TARGET_DIR/exercises/ex2_redirection.sh"
print_success "Created: exercises/ex2_redirection.sh"

# --- Exercise 3: Filters ---
cat > "$TARGET_DIR/exercises/ex3_filters.sh" << 'SCRIPT'
#!/bin/bash
# 
# EXERCISE 3: Text Filters (12%)
# 
#
# OBJECTIVE: Demonstrate use of Unix filters
#
# REQUIREMENTS:
# 1. Use sort for sorting
# 2. Use uniq for removing duplicates (Pitfall: requires sort first!)
# 3. Use cut for extracting columns
# 4. Use tr for character modifications
# 5. Build a complex pipeline with at least 3 filters
#
# Pitfall: DO NOT modify section comments (# [TEST-...])
# 

# Create test file
TEST_FILE="../tests/test_data/colors.txt"
mkdir -p "$(dirname "$TEST_FILE")"

cat > "$TEST_FILE" << 'EOF'
red
green
red
blue
green
red
yellow
blue
EOF

# [TEST-1] Sort colors.txt alphabetically and display result
# WRITE YOUR COMMAND BELOW:

# [TEST-2] Remove duplicates from colors.txt (Pitfall: must be sorted first!)
# TIP: correct pattern is sort | uniq, NOT just uniq
# WRITE YOUR COMMAND BELOW:

# [TEST-3] Extract first column from /etc/passwd (usernames)
# TIP: Use cut with delimiter ':'
# WRITE YOUR COMMAND BELOW:

# [TEST-4] Change all lowercase to uppercase from colors.txt
# TIP: Use tr 'a-z' 'A-Z'
# WRITE YOUR COMMAND BELOW:

# [TEST-5] Complex pipeline: from /etc/passwd, extract usernames,
# sort them, count each (even if unique) and display top 5
# TIP: cut -d':' -f1 | sort | uniq -c | sort -rn | head -5
# WRITE YOUR COMMAND BELOW:

echo "Exercise 3 completed!"
SCRIPT
chmod +x "$TARGET_DIR/exercises/ex3_filters.sh"
print_success "Created: exercises/ex3_filters.sh"

# --- Exercise 4: Loops ---
cat > "$TARGET_DIR/exercises/ex4_loops.sh" << 'SCRIPT'
#!/bin/bash
# 
# EXERCISE 4: Loops (11%)
# 
#
# OBJECTIVE: Demonstrate use of loops in Bash
#
# REQUIREMENTS:
# 1. Use for with a list of values
# 2. Use for with brace expansion ({1..5})
# 3. Use while to read a file
# 4. Demonstrate understanding of break and continue
#
#  PITFALLS TO AVOID:
# - {1..$N} does NOT work with variables! Use $(seq 1 $N) or for ((i=1; i<=N; i++))
# - cat file | while read loses variables! Use while read < file
#
# Pitfall: DO NOT modify section comments (# [TEST-...])
# 

# [TEST-1] For loop with list: display colours red, green, blue
# WRITE YOUR COMMAND BELOW:

# [TEST-2] For loop with brace expansion: display numbers from 1 to 5
# TIP: Use {1..5}
# WRITE YOUR COMMAND BELOW:

# [TEST-3] For loop with variable
# WRONG: for i in {1..$N} - WILL NOT WORK!
# CORRECT: Use $(seq 1 $N) or for ((i=1; i<=N; i++))
N=3
echo "Display numbers from 1 to $N:"
# WRITE YOUR COMMAND BELOW (using CORRECT syntax):

# [TEST-4] While loop to read a file line by line
# WRONG: cat file | while read line - loses variables!
# CORRECT: while read line; do ... done < file
# Read file ../tests/test_data/colors.txt and display each line numbered
# WRITE YOUR COMMAND BELOW:

# [TEST-5] Demonstrate break: exit loop when finding "green"
echo "Search for 'green' and stop:"
# WRITE YOUR COMMAND BELOW:

echo "Exercise 4 completed!"
SCRIPT
chmod +x "$TARGET_DIR/exercises/ex4_loops.sh"
print_success "Created: exercises/ex4_loops.sh"

# --- Exercise 5: Integrated Script ---
cat > "$TARGET_DIR/exercises/ex5_integrated.sh" << 'SCRIPT'
#!/bin/bash
# 
# EXERCISE 5: Integrated Script (15%)
# 
#
# OBJECTIVE: Create a complete script combining all concepts
#
# MANDATORY REQUIREMENTS:
# - Minimum 30 lines of code (excluding empty comments)
# - Minimum 2 defined functions
# - Error handling (argument checking, file existence)
# - Command line argument processing
# - Display help message with -h or --help
# - Use of loops
# - Use of filters (sort, uniq, cut, etc.)
# - I/O redirection (logs, output to files)
#
# SUGGESTED TOPIC:
# Create a "Directory Analyser" that:
# 1. Receives a directory as argument
# 2. Analyses all files in directory
# 3. Generates a report with:
#    - Number of files per extension
#    - Top 5 largest files
#    - Last modification date
# 4. Saves report to a file
#
# 

# WRITE YOUR SCRIPT BELOW:
# (Delete this comment and replace with your code)

echo "TODO: Implement integrated script"
SCRIPT
chmod +x "$TARGET_DIR/exercises/ex5_integrated.sh"
print_success "Created: exercises/ex5_integrated.sh"

# --- Check Script ---
cat > "$TARGET_DIR/check_homework.sh" << 'SCRIPT'
#!/bin/bash
# Structural preflight only: final functional assessment remains instructor-led.
set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
failures=0
for name in ex1_operators.sh ex2_redirection.sh ex3_filters.sh ex4_loops.sh ex5_integrated.sh; do
    file="$SCRIPT_DIR/exercises/$name"
    if [[ ! -f "$file" ]]; then
        echo "FAIL: missing exercises/$name"
        failures=$((failures + 1))
        continue
    fi
    if ! bash -n "$file"; then
        echo "FAIL: Bash syntax in $name"
        failures=$((failures + 1))
    fi
    if grep -Eq 'TODO:|TODO |YOUR CODE|IMPLEMENT HERE' "$file"; then
        echo "INCOMPLETE: starter placeholders remain in $name"
        failures=$((failures + 1))
    fi
    if [[ ! -x "$file" ]]; then
        echo "FAIL: $name is not executable; set its permission deliberately."
        failures=$((failures + 1))
    fi
done
echo "Preflight findings: $failures"
echo "No marks or final grade are assigned by this check. Functional evidence and review are still required."
[[ $failures -eq 0 ]]
SCRIPT
chmod +x "$TARGET_DIR/check_homework.sh"
print_success "Created: check_homework.sh"

# Create test data
mkdir -p "$TARGET_DIR/tests/test_data"
cat > "$TARGET_DIR/tests/test_data/sample.txt" << 'EOF'
Line 1 - test
Line 2 - example
Line 3 - demo
EOF
print_success "Created: tests/test_data/"

# 
# SECTION 7: FINALISATION
# 

echo ""
echo -e "${GREEN}═══════════════════════════════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}  ✅ HOMEWORK TEMPLATE CREATED SUCCESSFULLY!${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "  📁 Location: ${CYAN}${TARGET_DIR}${NC}"
echo ""
echo -e "  ${BOLD}Next steps:${NC}"
echo -e "  1. ${BLUE}cd ${TARGET_DIR}${NC}"
echo -e "  2. Complete each exercise in ${CYAN}exercises/${NC}"
echo -e "  3. Run ${CYAN}./check_homework.sh${NC} for verification"
echo -e "  4. Archive: ${CYAN}tar -czvf ${DIR_NAME}.tar.gz ${DIR_NAME}/${NC}"
echo ""
echo -e "${GREEN}═══════════════════════════════════════════════════════════════════════════════${NC}"
