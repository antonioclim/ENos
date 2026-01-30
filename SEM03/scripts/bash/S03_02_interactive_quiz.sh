#!/bin/bash
#
# S03_02_quiz_interactiv.sh - Interactive Quiz Seminar 3
# Operating Systems | Bucharest UES - CSIE
#
#
# DESCRIPTION:
#   Interactive quiz with 25+ questions about:
#   - find and xargs
#   - Script parameters and getopts
#   - Unix permissions
#   - Cron and automation
#
# USAGE:
#   ./S03_02_quiz_interactiv.sh [-h] [-n NUM] [-c CATEGORY] [-r]
#
# OPTIONS:
#   -h              Display help
#   -n NUM          Number of questions (default: 10)
#   -c CATEGORY     Category: find, script, perm, cron, all (default: all)
#   -r              Random order
#   -p              Practice mode (displays explanations)
#
# AUTHOR: OS Team UES
# VERSION: 1.0
#

# Colours
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'
BOLD='\033[1m'

# Default configurations
NUM_QUESTIONS=10
CATEGORY="all"
RANDOM_ORDER=false
PRACTICE_MODE=false

# Statistics
CORRECT=0
WRONG=0
TOTAL=0

#
# UTILITY FUNCTIONS
#

usage() {
    cat << EOF
${BOLD}Interactive Quiz - Seminar 3 OS${NC}

${BOLD}USAGE:${NC}
    $0 [-h] [-n NUM] [-c CATEGORY] [-r] [-p]

${BOLD}OPTIONS:${NC}
    -h              Display this help
    -n NUM          Number of questions (default: 10, max: 25)
    -c CATEGORY     Category:
                      find   - Questions about find and xargs
                      script - Questions about parameters and getopts
                      perm   - Questions about permissions
                      cron   - Questions about cron
                      all    - All categories (default)
    -r              Random order of questions
    -p              Practice mode (displays explanations after each answer)

${BOLD}EXAMPLES:${NC}
    $0                     # 10 questions from all categories
    $0 -n 5 -c find        # 5 questions only about find
    $0 -r -p               # Practice mode with random order
    $0 -c perm -n 8        # 8 questions about permissions

EOF
    exit 0
}

clear_screen() {
    printf '\033[2J\033[H'
}

print_header() {
    echo -e "\n${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}$1${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}\n"
}

print_question() {
    local num=$1
    local total=$2
    local category=$3
    local question=$4
    
    echo -e "${BLUE}┌─────────────────────────────────────────────────────────────────┐${NC}"
    echo -e "${BLUE}│${NC} ${BOLD}Question $num/$total${NC} ${MAGENTA}[$category]${NC}"
    echo -e "${BLUE}├─────────────────────────────────────────────────────────────────┤${NC}"
    echo -e "${BLUE}│${NC}"
    # Word wrap for question
    echo "$question" | fold -s -w 65 | while read -r line; do
        printf "${BLUE}│${NC} %s\n" "$line"
    done
    echo -e "${BLUE}│${NC}"
    echo -e "${BLUE}└─────────────────────────────────────────────────────────────────┘${NC}"
}

print_options() {
    local -n opts=$1
    echo ""
    for i in "${!opts[@]}"; do
        local letter=$(echo "$i" | tr '0123' 'ABCD')
        echo -e "  ${YELLOW}$letter)${NC} ${opts[$i]}"
    done
    echo ""
}

get_answer() {
    local valid_answers="$1"
    local answer
    
    while true; do
        echo -n -e "${CYAN}Your answer [${valid_answers}]: ${NC}"
        read -r answer
        answer=$(echo "$answer" | tr '[:lower:]' '[:upper:]')
        
        if [[ "$valid_answers" == *"$answer"* ]] && [ -n "$answer" ]; then
            echo "$answer"
            return
        else
            echo -e "${RED}Invalid answer. Choose from: $valid_answers${NC}"
        fi
    done
}

show_result() {
    local is_correct=$1
    local correct_answer=$2
    local explanation=$3
    
    echo ""
    if [ "$is_correct" = true ]; then
        echo -e "${GREEN}✓ CORRECT!${NC}"
        ((CORRECT++))
    else
        echo -e "${RED}✗ WRONG!${NC} The correct answer was: ${YELLOW}$correct_answer${NC}"
        ((WRONG++))
    fi
    
    if [ "$PRACTICE_MODE" = true ] && [ -n "$explanation" ]; then
        echo ""
        echo -e "${CYAN}📝 Explanation:${NC}"
        echo "$explanation" | fold -s -w 65 | while read -r line; do
            echo "   $line"
        done
    fi
    
    echo ""
    echo -e "${BLUE}─────────────────────────────────────────────────────────────────${NC}"
    read -p "Press Enter to continue..."
}

#
# QUESTIONS DATABASE - FIND
#

declare -a QUESTIONS_FIND
declare -a OPTIONS_FIND
declare -a ANSWERS_FIND
declare -a EXPLANATIONS_FIND

# Q1
QUESTIONS_FIND+=("What does the -type f option do in the find command?")
OPTIONS_FIND+=("A:Searches for files starting with 'f'|B:Searches only for regular files|C:Searches in full format|D:Filters the results")
ANSWERS_FIND+=("B")
EXPLANATIONS_FIND+=("-type f searches only for regular files, excluding directories (-type d), symbolic links (-type l), etc.")

# Q2
QUESTIONS_FIND+=("What is the main difference between find and locate?")
OPTIONS_FIND+=("A:find is faster|B:locate searches live in filesystem|C:locate uses a pre-indexed database|D:There is no difference")
ANSWERS_FIND+=("C")
EXPLANATIONS_FIND+=("locate searches a pre-indexed database (fast but may be outdated), whilst find scans the filesystem in real-time (slower but always current).")

# Q3
QUESTIONS_FIND+=("What does -mtime -7 mean in find?")
OPTIONS_FIND+=("A:Files modified exactly 7 days ago|B:Files modified in the last 7 days|C:Files older than 7 days|D:Files modified at 7 o'clock")
ANSWERS_FIND+=("B")
EXPLANATIONS_FIND+=("-mtime -7 means 'modification time less than 7 days', i.e. modified in the last 7 days. +7 would mean older than 7 days.")

# Q4
QUESTIONS_FIND+=("What is the difference between -exec {} \\; and -exec {} +?")
OPTIONS_FIND+=("A:There is no difference|B:\\; is for Windows, + for Linux|C:\\; executes once per file, + executes in batch|D:\\; is faster")
ANSWERS_FIND+=("C")
EXPLANATIONS_FIND+=("\\; executes the command separately for each file found (slower). + collects all files and passes them as arguments in a single execution (more efficient).")

# Q5
QUESTIONS_FIND+=("Why is it important to use quotes in find -name \"*.txt\"?")
OPTIONS_FIND+=("A:For code style|B:To prevent shell glob expansion|C:For case sensitivity|D:It is not important")
ANSWERS_FIND+=("B")
EXPLANATIONS_FIND+=("Without quotes, the shell would expand *.txt BEFORE find, transforming it into the list of files in the current directory that match.")

# Q6
QUESTIONS_FIND+=("What problem does the combination find -print0 | xargs -0 solve?")
OPTIONS_FIND+=("A:Files with spaces in names|B:Very large files|C:Missing permissions|D:Hidden files")
ANSWERS_FIND+=("A")
EXPLANATIONS_FIND+=("-print0 uses null character as separator, and xargs -0 interprets it correctly. This solves the problem of files with spaces or special characters in names.")

# Q7
QUESTIONS_FIND+=("What does the command: find . -size +10M -size -100M do?")
OPTIONS_FIND+=("A:Files of exactly 10MB or 100MB|B:Files between 10MB and 100MB|C:Files smaller than 10MB or larger than 100MB|D:Syntax error")
ANSWERS_FIND+=("B")
EXPLANATIONS_FIND+=("Conditions in find are implicitly AND. +10M means larger than 10MB, -100M means smaller than 100MB, combined = range.")

#
# QUESTIONS DATABASE - SCRIPT
#

declare -a QUESTIONS_SCRIPT
declare -a OPTIONS_SCRIPT
declare -a ANSWERS_SCRIPT
declare -a EXPLANATIONS_SCRIPT

# Q1
QUESTIONS_SCRIPT+=("What is the difference between \"\$@\" and \"\$*\" in a script?")
OPTIONS_SCRIPT+=("A:There is no difference|B:\$@ keeps arguments separate, \$* concatenates them|C:\$@ is for numbers, \$* for text|D:\$* is deprecated")
ANSWERS_SCRIPT+=("B")
EXPLANATIONS_SCRIPT+=("With quotes: \"\$@\" treats each argument separately (ideal for loops), \"\$*\" concatenates all arguments into a single string.")

# Q2
QUESTIONS_SCRIPT+=("What does \$# display in a bash script?")
OPTIONS_SCRIPT+=("A:Number of arguments|B:Last argument|C:Process PID|D:Exit status")
ANSWERS_SCRIPT+=("A")
EXPLANATIONS_SCRIPT+=("\$# returns the number of positional arguments passed to the script, not including \$0 (the script name).")

# Q3
QUESTIONS_SCRIPT+=("What does the shift command do in a script?")
OPTIONS_SCRIPT+=("A:Moves the cursor|B:Removes the first argument and shifts the rest up|C:Sorts the arguments|D:Changes upper/lower case")
ANSWERS_SCRIPT+=("B")
EXPLANATIONS_SCRIPT+=("shift removes \$1, then \$2 becomes \$1, \$3 becomes \$2, etc. and decrements \$#. shift N removes the first N arguments.")

# Q4
QUESTIONS_SCRIPT+=("In getopts \"a:b:c\", what does the ':' character signify?")
OPTIONS_SCRIPT+=("A:The option is mandatory|B:The option requires an argument|C:The option is deprecated|D:Separator between options")
ANSWERS_SCRIPT+=("B")
EXPLANATIONS_SCRIPT+=("A colon after a letter (e.g.: a:) indicates that option -a requires an argument (stored in OPTARG). 'c' without : does not require an argument.")

# Q5
QUESTIONS_SCRIPT+=("What does the OPTARG variable contain in getopts?")
OPTIONS_SCRIPT+=("A:Number of options|B:The current option's argument|C:All arguments|D:The current error")
ANSWERS_SCRIPT+=("B")
EXPLANATIONS_SCRIPT+=("OPTARG contains the value of the argument for the current option that requires an argument (those marked with : in optstring).")

# Q6
QUESTIONS_SCRIPT+=("What does \${VAR:-default} do?")
OPTIONS_SCRIPT+=("A:Sets VAR to 'default'|B:Returns 'default' if VAR is empty, without modifying VAR|C:Deletes VAR|D:Compares VAR with 'default'")
ANSWERS_SCRIPT+=("B")
EXPLANATIONS_SCRIPT+=("\${VAR:-default} returns the value of VAR if set and non-empty, otherwise returns 'default', without modifying VAR. \${VAR:=default} would set VAR.")

# Q7
QUESTIONS_SCRIPT+=("Why is shift \$((OPTIND-1)) important after getopts?")
OPTIONS_SCRIPT+=("A:To reset getopts|B:To remove processed options and keep non-option arguments|C:For performance|D:It's optional")
ANSWERS_SCRIPT+=("B")
EXPLANATIONS_SCRIPT+=("OPTIND contains the index of the next argument to process. After getopts, shift \$((OPTIND-1)) removes all options, leaving only positional arguments.")

#
# QUESTIONS DATABASE - PERMISSIONS
#

declare -a QUESTIONS_PERM
declare -a OPTIONS_PERM
declare -a ANSWERS_PERM
declare -a EXPLANATIONS_PERM

# Q1
QUESTIONS_PERM+=("What does the 'x' permission mean on a DIRECTORY?")
OPTIONS_PERM+=("A:You can execute files in it|B:You can list contents|C:You can access (cd) into the directory|D:You can delete the directory")
ANSWERS_PERM+=("C")
EXPLANATIONS_PERM+=("On a directory, x (execute) means you can ACCESS (cd into) the directory. r allows listing, w allows creating/deleting files. x on directory ≠ execution!")

# Q2
QUESTIONS_PERM+=("Calculate the octal permissions for rwxr-x---")
OPTIONS_PERM+=("A:754|B:750|C:740|D:755")
ANSWERS_PERM+=("B")
EXPLANATIONS_PERM+=("rwx = 4+2+1 = 7, r-x = 4+0+1 = 5, --- = 0. Result: 750")

# Q3
QUESTIONS_PERM+=("With umask 027, what permissions will new files have?")
OPTIONS_PERM+=("A:777|B:750|C:640|D:660")
ANSWERS_PERM+=("C")
EXPLANATIONS_PERM+=("Default for files is 666. umask 027 removes 0 from owner, 2 from group, 7 from others. 666 - 027 = 640 (rw-r-----).")

# Q4
QUESTIONS_PERM+=("What does the SUID (Set User ID) bit do on an executable file?")
OPTIONS_PERM+=("A:The file becomes read-only|B:The file runs with the owner's permissions|C:The file can be deleted by anyone|D:The file is hidden")
ANSWERS_PERM+=("B")
EXPLANATIONS_PERM+=("SUID makes the executable run with the owner's permissions, not those of the person executing it. Example: /usr/bin/passwd runs as root.")

# Q5
QUESTIONS_PERM+=("Why is chmod 777 considered dangerous?")
OPTIONS_PERM+=("A:It consumes a lot of space|B:It gives total access to everyone, compromising security|C:It deletes the file|D:It is slow")
ANSWERS_PERM+=("B")
EXPLANATIONS_PERM+=("777 (rwxrwxrwx) allows anyone to read, write, and execute the file. On a server, this is a major security vulnerability.")

# Q6
QUESTIONS_PERM+=("What does SGID (Set Group ID) do on a DIRECTORY?")
OPTIONS_PERM+=("A:The directory becomes read-only|B:New files inherit the directory's group|C:No one can enter the directory|D:The directory deletes itself automatically")
ANSWERS_PERM+=("B")
EXPLANATIONS_PERM+=("SGID on a directory makes all files created in it inherit the directory's group, not the user's primary group. Ideal for shared directories.")

# Q7
QUESTIONS_PERM+=("Sticky bit on /tmp causes:")
OPTIONS_PERM+=("A:Files to persist after reboot|B:Only the owner can delete their own files|C:Files to be compressed|D:The directory to be hidden")
ANSWERS_PERM+=("B")
EXPLANATIONS_PERM+=("Sticky bit on a directory (t in the others x position) allows only the file's owner (or root) to delete it, even if the directory is world-writable.")

# Q8
QUESTIONS_PERM+=("To delete a file, you need permission on:")
OPTIONS_PERM+=("A:File (w)|B:Parent directory (w)|C:Both|D:Neither if you are the owner")
ANSWERS_PERM+=("B")
EXPLANATIONS_PERM+=("Deleting a file modifies the directory entry, not the file itself. You need w on the parent directory; the file's permissions do not matter for deletion.")

#
# QUESTIONS DATABASE - CRON
#

declare -a QUESTIONS_CRON
declare -a OPTIONS_CRON
declare -a ANSWERS_CRON
declare -a EXPLANATIONS_CRON

# Q1
QUESTIONS_CRON+=("What is the order of the 5 fields in crontab?")
OPTIONS_CRON+=("A:hour min day month dow|B:min hour day month dow|C:min hour month day dow|D:day month year hour min")
ANSWERS_CRON+=("B")
EXPLANATIONS_CRON+=("The order is: minute (0-59), hour (0-23), day of month (1-31), month (1-12), day of week (0-7). Mnemonic: Min Hour Day Month Weekday.")

# Q2
QUESTIONS_CRON+=("What does the cron expression: */15 * * * * mean?")
OPTIONS_CRON+=("A:At minute 15 of every hour|B:Every 15 minutes|C:At 15 o'clock|D:15 times per day")
ANSWERS_CRON+=("B")
EXPLANATIONS_CRON+=("*/15 in the minute field means 'every 15 minutes' - it will run at 0, 15, 30, 45 of every hour.")

# Q3
QUESTIONS_CRON+=("Why might a cron job fail that works manually?")
OPTIONS_CRON+=("A:Cron has a different environment (limited PATH)|B:Cron only runs at night|C:Cron requires sudo|D:Cron doesn't support bash")
ANSWERS_CRON+=("A")
EXPLANATIONS_CRON+=("Cron runs with a minimal environment, without the full PATH. Solutions: use absolute paths, set PATH in crontab, or use the script with full path.")

# Q4
QUESTIONS_CRON+=("What does >> /var/log/cron.log 2>&1 do in a cron job?")
OPTIONS_CRON+=("A:Deletes the log|B:Redirects stdout and stderr to file (append)|C:Sends email|D:Stops the job")
ANSWERS_CRON+=("B")
EXPLANATIONS_CRON+=(">> appends to file (doesn't overwrite), 2>&1 redirects stderr (2) to stdout (1), so both end up in the log file.")

# Q5
QUESTIONS_CRON+=("What does crontab -r do?")
OPTIONS_CRON+=("A:Reloads crontab|B:Resets to default|C:DELETES entire crontab without confirmation|D:Restarts cron")
ANSWERS_CRON+=("C")
EXPLANATIONS_CRON+=("Pitfall: crontab -r deletes the ENTIRE crontab without confirmation! Confusion with -e (edit) can be catastrophic. Backup: crontab -l > backup.cron")

# Q6
QUESTIONS_CRON+=("What does @reboot mean in crontab?")
OPTIONS_CRON+=("A:Restarts the system|B:Runs at every system restart|C:Runs once per day|D:It is invalid")
ANSWERS_CRON+=("B")
EXPLANATIONS_CRON+=("@reboot is a special string that makes the job run once, at system startup. Useful for initialisation scripts.")

# Q7
QUESTIONS_CRON+=("How do you prevent simultaneous executions of a long cron job?")
OPTIONS_CRON+=("A:It cannot be done|B:Using flock for lock file|C:Setting nice|D:Using sleep")
ANSWERS_CRON+=("B")
EXPLANATIONS_CRON+=("flock -n /tmp/myjob.lock command ensures only one instance runs. -n = non-blocking (fails if lock is held). Alternatively: implement lock file manually in script.")

#
# MAIN QUIZ FUNCTION
#

run_quiz() {
    local -a selected_questions
    local -a selected_options
    local -a selected_answers
    local -a selected_explanations
    local -a selected_categories
    
    # Collect questions from selected categories
    case "$CATEGORY" in
        find)
            for i in "${!QUESTIONS_FIND[@]}"; do
                selected_questions+=("${QUESTIONS_FIND[$i]}")
                selected_options+=("${OPTIONS_FIND[$i]}")
                selected_answers+=("${ANSWERS_FIND[$i]}")
                selected_explanations+=("${EXPLANATIONS_FIND[$i]}")
                selected_categories+=("FIND")
            done
            ;;
        script)
            for i in "${!QUESTIONS_SCRIPT[@]}"; do
                selected_questions+=("${QUESTIONS_SCRIPT[$i]}")
                selected_options+=("${OPTIONS_SCRIPT[$i]}")
                selected_answers+=("${ANSWERS_SCRIPT[$i]}")
                selected_explanations+=("${EXPLANATIONS_SCRIPT[$i]}")
                selected_categories+=("SCRIPT")
            done
            ;;
        perm)
            for i in "${!QUESTIONS_PERM[@]}"; do
                selected_questions+=("${QUESTIONS_PERM[$i]}")
                selected_options+=("${OPTIONS_PERM[$i]}")
                selected_answers+=("${ANSWERS_PERM[$i]}")
                selected_explanations+=("${EXPLANATIONS_PERM[$i]}")
                selected_categories+=("PERMISSIONS")
            done
            ;;
        cron)
            for i in "${!QUESTIONS_CRON[@]}"; do
                selected_questions+=("${QUESTIONS_CRON[$i]}")
                selected_options+=("${OPTIONS_CRON[$i]}")
                selected_answers+=("${ANSWERS_CRON[$i]}")
                selected_explanations+=("${EXPLANATIONS_CRON[$i]}")
                selected_categories+=("CRON")
            done
            ;;
        all|*)
            for i in "${!QUESTIONS_FIND[@]}"; do
                selected_questions+=("${QUESTIONS_FIND[$i]}")
                selected_options+=("${OPTIONS_FIND[$i]}")
                selected_answers+=("${ANSWERS_FIND[$i]}")
                selected_explanations+=("${EXPLANATIONS_FIND[$i]}")
                selected_categories+=("FIND")
            done
            for i in "${!QUESTIONS_SCRIPT[@]}"; do
                selected_questions+=("${QUESTIONS_SCRIPT[$i]}")
                selected_options+=("${OPTIONS_SCRIPT[$i]}")
                selected_answers+=("${ANSWERS_SCRIPT[$i]}")
                selected_explanations+=("${EXPLANATIONS_SCRIPT[$i]}")
                selected_categories+=("SCRIPT")
            done
            for i in "${!QUESTIONS_PERM[@]}"; do
                selected_questions+=("${QUESTIONS_PERM[$i]}")
                selected_options+=("${OPTIONS_PERM[$i]}")
                selected_answers+=("${ANSWERS_PERM[$i]}")
                selected_explanations+=("${EXPLANATIONS_PERM[$i]}")
                selected_categories+=("PERMISSIONS")
            done
            for i in "${!QUESTIONS_CRON[@]}"; do
                selected_questions+=("${QUESTIONS_CRON[$i]}")
                selected_options+=("${OPTIONS_CRON[$i]}")
                selected_answers+=("${ANSWERS_CRON[$i]}")
                selected_explanations+=("${EXPLANATIONS_CRON[$i]}")
                selected_categories+=("CRON")
            done
            ;;
    esac
    
    local total_available=${#selected_questions[@]}
    
    if [ $total_available -eq 0 ]; then
        echo -e "${RED}Error: No questions exist for the selected category.${NC}"
        exit 1
    fi
    
    # Adjust number of questions if necessary
    if [ $NUM_QUESTIONS -gt $total_available ]; then
        NUM_QUESTIONS=$total_available
    fi
    
    # Create array of indices
    local -a indices
    for i in $(seq 0 $((total_available - 1))); do
        indices+=($i)
    done
    
    # Shuffle if random
    if [ "$RANDOM_ORDER" = true ]; then
        for ((i = total_available - 1; i > 0; i--)); do
            j=$((RANDOM % (i + 1)))
            tmp=${indices[$i]}
            indices[$i]=${indices[$j]}
            indices[$j]=$tmp
        done
    fi
    
    # Display header
    clear_screen
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC}       ${BOLD}🎓 INTERACTIVE QUIZ - SEMINAR 5-6${NC}                       ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}       Operating Systems | Bucharest UES                       ${CYAN}║${NC}"
    echo -e "${CYAN}╠═══════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${CYAN}║${NC}  Questions: $NUM_QUESTIONS    Category: $CATEGORY"
    [ "$PRACTICE_MODE" = true ] && echo -e "${CYAN}║${NC}  Mode: PRACTICE (with explanations)"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    read -p "Press Enter to begin..."
    
    # Run the quiz
    for ((q = 0; q < NUM_QUESTIONS; q++)); do
        clear_screen
        
        local idx=${indices[$q]}
        local question="${selected_questions[$idx]}"
        local options_str="${selected_options[$idx]}"
        local correct="${selected_answers[$idx]}"
        local explanation="${selected_explanations[$idx]}"
        local category="${selected_categories[$idx]}"
        
        # Parse options
        local -a opts
        IFS='|' read -ra opt_array <<< "$options_str"
        for opt in "${opt_array[@]}"; do
            opts+=("${opt#*:}")
        done
        
        # Display question
        print_question $((q + 1)) $NUM_QUESTIONS "$category" "$question"
        print_options opts
        
        # Get answer
        local user_answer
        user_answer=$(get_answer "ABCD")
        
        # Check answer
        ((TOTAL++))
        if [ "$user_answer" = "$correct" ]; then
            show_result true "$correct" "$explanation"
        else
            show_result false "$correct" "$explanation"
        fi
        
        unset opts
    done
    
    # Display final results
    show_final_results
}

show_final_results() {
    clear_screen
    
    local percentage=$((CORRECT * 100 / TOTAL))
    local grade
    local grade_color
    
    if [ $percentage -ge 90 ]; then
        grade="EXCELLENT! 🌟"
        grade_color=$GREEN
    elif [ $percentage -ge 70 ]; then
        grade="GOOD! 👍"
        grade_color=$YELLOW
    elif [ $percentage -ge 50 ]; then
        grade="SUFFICIENT 📚"
        grade_color=$YELLOW
    else
        grade="NEEDS STUDY 📖"
        grade_color=$RED
    fi
    
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC}                   ${BOLD}📊 FINAL RESULTS${NC}                           ${CYAN}║${NC}"
    echo -e "${CYAN}╠═══════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}     Total questions:     ${BOLD}$TOTAL${NC}"
    echo -e "${CYAN}║${NC}     Correct answers:     ${GREEN}$CORRECT${NC}"
    echo -e "${CYAN}║${NC}     Wrong answers:       ${RED}$WRONG${NC}"
    echo -e "${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}     Score:               ${BOLD}$percentage%${NC}"
    echo -e "${CYAN}║${NC}     Grade:               ${grade_color}$grade${NC}"
    echo -e "${CYAN}║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    
    echo ""
    
    if [ $percentage -lt 70 ]; then
        echo -e "${YELLOW}💡 Suggestions for improvement:${NC}"
        case "$CATEGORY" in
            find) echo "   - Review the documentation: man find, man xargs" ;;
            script) echo "   - Practise writing scripts with getopts" ;;
            perm) echo "   - Practise calculating octal permissions" ;;
            cron) echo "   - Check crontab.guru for cron expressions" ;;
            *) echo "   - Review the material from Seminar 3" ;;
        esac
    fi
    
    echo ""
    read -p "Press Enter to exit..."
}

#
# MAIN
#

main() {
    # Parse arguments
    while getopts ":hn:c:rp" opt; do
        case $opt in
            h) usage ;;
            n) 
                if [[ "$OPTARG" =~ ^[0-9]+$ ]] && [ "$OPTARG" -ge 1 ] && [ "$OPTARG" -le 30 ]; then
                    NUM_QUESTIONS=$OPTARG
                else
                    echo -e "${RED}Error: -n must be a number between 1 and 30${NC}"
                    exit 1
                fi
                ;;
            c) 
                if [[ "$OPTARG" =~ ^(find|script|perm|cron|all)$ ]]; then
                    CATEGORY=$OPTARG
                else
                    echo -e "${RED}Error: Invalid category. Options: find, script, perm, cron, all${NC}"
                    exit 1
                fi
                ;;
            r) RANDOM_ORDER=true ;;
            p) PRACTICE_MODE=true ;;
            \?) echo -e "${RED}Invalid option: -$OPTARG${NC}"; exit 1 ;;
            :) echo -e "${RED}Option -$OPTARG requires argument${NC}"; exit 1 ;;
        esac
    done
    
    # Run the quiz
    run_quiz
}

main "$@"
