#!/bin/bash
#
# INTERACTIVE QUIZ - Seminar 1: Shell Fundamentals
# Operating Systems | ASE Bucharest - CSIE
#
# Usage: ./S01_02_interactive_quiz.sh
#

set -euo pipefail

# Colours
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'
BOLD='\033[1m'

# Score tracking
SCORE=0
TOTAL=0

# Functions
ask_question() {
    local question="$1"
    local options="$2"
    local correct="$3"
    local explanation="$4"
    
    ((TOTAL++))
    
    echo ""
    echo -e "${CYAN}Question $TOTAL:${NC}"
    echo -e "${BOLD}$question${NC}"
    echo ""
    echo -e "$options"
    echo ""
    
    read -p "Your answer (A/B/C/D): " -n 1 answer
    echo ""
    
    answer=$(echo "$answer" | tr '[:lower:]' '[:upper:]')
    
    if [ "$answer" == "$correct" ]; then
        echo -e "${GREEN}[CORRECT]${NC} Well done!"
        ((SCORE++))
    else
        echo -e "${RED}[INCORRECT]${NC} The correct answer is: $correct"
    fi
    
    echo -e "${BLUE}Explanation:${NC} $explanation"
    echo ""
    read -p "Press Enter to continue..."
}

# Header
clear
echo -e "${CYAN}+===================================================================+${NC}"
echo -e "${CYAN}|${NC}         ${BOLD}INTERACTIVE QUIZ - Seminar 1: Shell Fundamentals${NC}       ${CYAN}|${NC}"
echo -e "${CYAN}+===================================================================+${NC}"
echo ""
echo "This quiz will test your understanding of shell basics."
echo "Answer each question by typing A, B, C or D."
echo ""
read -p "Press Enter to start..."

# Question 1
ask_question \
    "What does the pwd command display?" \
    "A) List of processes
B) Current user
C) Current working directory
D) User password" \
    "C" \
    "pwd stands for Print Working Directory. It displays the absolute path of your current location."

# Question 2
ask_question \
    "Which directory contains system configuration files?" \
    "A) /home
B) /etc
C) /bin
D) /tmp" \
    "B" \
    "/etc contains global system configuration files like /etc/passwd and /etc/hosts."

# Question 3
ask_question \
    "What is the difference between shell and terminal?" \
    "A) They are synonyms
B) The shell interprets commands, the terminal is the interface
C) The terminal interprets commands, the shell is the window
D) There is no functional difference" \
    "B" \
    "The shell (bash, zsh) is the command interpreter. The terminal is the graphical interface."

# Question 4
ask_question \
    "What type of path is '/home/stud/project'?" \
    "A) Relative path
B) Absolute path
C) Symbolic path
D) Virtual path" \
    "B" \
    "An absolute path starts with / (root) and specifies the complete location."

# Question 5
ask_question \
    "If I set VAR='test' without export, what will echo \$VAR display in a subshell?" \
    "A) test
B) Nothing (empty string)
C) Error
D) \$VAR literally" \
    "B" \
    "Local variables (without export) are not visible in child processes."

# Question 6
ask_question \
    "What command creates nested directories that do not exist?" \
    "A) mkdir /project/src/main/java
B) mkdir -p /project/src/main/java
C) mkdir -r /project/src/main/java
D) mkdir --create /project/src/main/java" \
    "B" \
    "The -p (parents) option creates all necessary parent directories."

# Question 7
ask_question \
    "You just modified ~/.bashrc. What command applies the changes?" \
    "A) restart bash
B) source ~/.bashrc
C) refresh ~/.bashrc
D) reload ~/.bashrc" \
    "B" \
    "source (or .) executes the script in the current shell, applying changes immediately."

# Question 8
ask_question \
    "What files does touch file{1,2,3}.txt create?" \
    "A) file{1,2,3}.txt (a single file)
B) file1.txt, file2.txt, file3.txt
C) file123.txt
D) Syntax error" \
    "B" \
    "Brace expansion {} expands the pattern before execution."

# Question 9
ask_question \
    "NAME='John'; echo 'Hello \$NAME' displays:" \
    "A) Hello John
B) Hello \$NAME
C) Syntax error
D) Hello (empty)" \
    "B" \
    "Single quotes preserve everything literally — variables do NOT expand."

# Question 10
ask_question \
    "What does exit code 0 signify in Linux?" \
    "A) Error
B) Non-existent command
C) Success
D) Insufficient permissions" \
    "C" \
    "Unix convention: 0 = success, non-zero = error. Check with echo \$? after execution."

# Summary
clear
echo -e "${CYAN}+===================================================================+${NC}"
echo -e "${CYAN}|${NC}                     ${BOLD}QUIZ COMPLETE${NC}                              ${CYAN}|${NC}"
echo -e "${CYAN}+===================================================================+${NC}"
echo ""
echo -e "Your score: ${BOLD}$SCORE / $TOTAL${NC}"
echo ""

PERCENTAGE=$((SCORE * 100 / TOTAL))

if [ $PERCENTAGE -ge 90 ]; then
    echo -e "${GREEN}Excellent! You have a solid understanding of shell basics.${NC}"
elif [ $PERCENTAGE -ge 70 ]; then
    echo -e "${YELLOW}Good work! Review the questions you got wrong.${NC}"
elif [ $PERCENTAGE -ge 50 ]; then
    echo -e "${YELLOW}Fair. Consider reviewing the seminar material.${NC}"
else
    echo -e "${RED}You need more practice. Review the seminar material carefully.${NC}"
fi

echo ""
echo "Recommended next steps:"
echo "  1. Review the MAIN_MATERIAL.md document"
echo "  2. Try the SPRINT_EXERCISES.md"
echo "  3. Complete the SELF_ASSESSMENT_REFLECTION.md"
echo ""
