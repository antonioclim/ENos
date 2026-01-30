#!/bin/bash
#
# Script:      S05_02_demo_functions.sh
# Description: Interactive demo for Bash functions
# Purpose:     Demonstrate functions, local, return values
#

set -euo pipefail
IFS=$'\n\t'

# Cleanup function for trap
cleanup() {
    rm -f /tmp/demo_func_*.tmp 2>/dev/null || true
}
trap cleanup EXIT

# Colours
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

banner() {
    echo ""
    echo -e "${BOLD}${BLUE}════════════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}${BLUE}  $1${NC}"
    echo -e "${BOLD}${BLUE}════════════════════════════════════════════════════════════${NC}"
    echo ""
}

pause() {
    echo ""
    read -p "Press Enter to continue..."
    echo ""
}

# ============================================================
# DEMO 1: DEFINITION AND CALL
# ============================================================
demo_basics() {
    banner "DEMO 1: FUNCTION DEFINITION AND CALL"
    
    echo -e "${YELLOW}Syntax 1: With 'function' keyword${NC}"
    echo ""
    
    function greet_v1() {
        echo "Hello from function keyword syntax!"
    }
    
    echo "Definition:"
    echo '  function greet_v1() {'
    echo '      echo "Hello from function keyword syntax!"'
    echo '  }'
    echo ""
    echo "Call: greet_v1"
    echo -e "Result: ${GREEN}"
    greet_v1
    echo -e "${NC}"
    
    pause
    
    echo -e "${YELLOW}Syntax 2: POSIX (preferred)${NC}"
    echo ""
    
    greet_v2() {
        echo "Hello from POSIX syntax!"
    }
    
    echo "Definition:"
    echo '  greet_v2() {'
    echo '      echo "Hello from POSIX syntax!"'
    echo '  }'
    echo ""
    echo "Call: greet_v2"
    echo -e "Result: ${GREEN}"
    greet_v2
    echo -e "${NC}"
    
    pause
    
    echo -e "${YELLOW}With arguments:${NC}"
    echo ""
    
    greet_name() {
        echo "Hello, $1! You are $2 years old."
    }
    
    echo "Definition:"
    echo '  greet_name() {'
    echo '      echo "Hello, $1! You are $2 years old."'
    echo '  }'
    echo ""
    echo 'Call: greet_name "Alice" "25"'
    echo -e "Result: ${GREEN}"
    greet_name "Alice" "25"
    echo -e "${NC}"
    
    echo ""
    echo -e "${RED}WHAT HAPPENS WITHOUT ARGUMENTS?${NC}"
    echo 'Call: greet_name'
    echo -e "Result: ${YELLOW}"
    greet_name || true
    echo -e "${NC}"
    echo -e "${RED}→ Missing arguments become empty strings!${NC}"
}

# ============================================================
# DEMO 2: LOCAL vs GLOBAL VARIABLES (CRITICAL!)
# ============================================================
demo_scope() {
    banner "DEMO 2: LOCAL vs GLOBAL VARIABLES ⚠️"
    
    echo -e "${RED}Trap: This is the most common mistake!${NC}"
    echo ""
    
    # Reset variables for demo
    GLOBAL_VAR="initial value"
    unset CREATED_BY_FUNCTION 2>/dev/null || true
    
    echo -e "${YELLOW}Initial situation:${NC}"
    echo "  GLOBAL_VAR = '$GLOBAL_VAR'"
    echo "  CREATED_BY_FUNCTION = (does not exist)"
    echo ""
    
    pause
    
    # BAD function (without local)
    bad_function() {
        GLOBAL_VAR="modified by bad_function"     # Modifies global!
        CREATED_BY_FUNCTION="created inside"       # Creates new global!
    }
    
    echo -e "${RED}BAD function (without local):${NC}"
    echo '  bad_function() {'
    echo '      GLOBAL_VAR="modified by bad_function"'
    echo '      CREATED_BY_FUNCTION="created inside"'
    echo '  }'
    echo ""
    echo "Calling bad_function..."
    bad_function
    echo ""
    echo -e "${RED}After call:${NC}"
    echo "  GLOBAL_VAR = '$GLOBAL_VAR'"
    echo "  CREATED_BY_FUNCTION = '$CREATED_BY_FUNCTION'"
    echo ""
    echo -e "${RED}→ Global variable was MODIFIED!${NC}"
    echo -e "${RED}→ A new global variable was CREATED!${NC}"
    
    pause
    
    # Reset
    GLOBAL_VAR="initial value"
    
    # GOOD function (with local)
    good_function() {
        local GLOBAL_VAR="local shadow"           # Shadowing - doesn't affect global
        local truly_local="exists only here"       # Purely local variable
        echo "  Inside: GLOBAL_VAR = '$GLOBAL_VAR'"
        echo "  Inside: truly_local = '$truly_local'"
    }
    
    echo -e "${GREEN}GOOD function (with local):${NC}"
    echo '  good_function() {'
    echo '      local GLOBAL_VAR="local shadow"'
    echo '      local truly_local="exists only here"'
    echo '      echo "Inside: GLOBAL_VAR = $GLOBAL_VAR"'
    echo '  }'
    echo ""
    echo "GLOBAL_VAR before: '$GLOBAL_VAR'"
    echo ""
    echo "Calling good_function..."
    good_function
    echo ""
    echo -e "${GREEN}After call:${NC}"
    echo "  GLOBAL_VAR = '$GLOBAL_VAR'"
    echo -e "  truly_local = '${truly_local:-}' (does not exist outside!)"
    echo ""
    echo -e "${GREEN}→ Global variable was NOT affected!${NC}"
    echo -e "${GREEN}→ truly_local disappeared after exiting function!${NC}"
    
    pause
    
    echo -e "${BOLD}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}║  GOLDEN RULE: ALWAYS use 'local' in functions!                 ║${NC}"
    echo -e "${BOLD}╚════════════════════════════════════════════════════════════════╝${NC}"
}

# ============================================================
# DEMO 3: RETURN VALUES
# ============================================================
demo_return() {
    banner "DEMO 3: RETURN VALUES"
    
    echo -e "${YELLOW}METHOD 1: echo to return string/value${NC}"
    echo ""
    
    get_sum() {
        local a=$1 b=$2
        echo $((a + b))
    }
    
    echo "Function:"
    echo '  get_sum() {'
    echo '      local a=$1 b=$2'
    echo '      echo $((a + b))'
    echo '  }'
    echo ""
    echo 'Call: result=$(get_sum 5 3)'
    result=$(get_sum 5 3)
    echo -e "Result: ${GREEN}$result${NC}"
    
    pause
    
    echo -e "${YELLOW}METHOD 2: return for exit code (only 0-255!)${NC}"
    echo ""
    
    is_even() {
        local n=$1
        (( n % 2 == 0 ))
    }
    
    echo "Function:"
    echo '  is_even() {'
    echo '      local n=$1'
    echo '      (( n % 2 == 0 ))  # Returns 0 (true) or 1 (false)'
    echo '  }'
    echo ""
    echo 'Usage in if:'
    if is_even 4; then
        echo -e "  ${GREEN}4 is even${NC}"
    fi
    if ! is_even 7; then
        echo -e "  ${GREEN}7 is odd${NC}"
    fi
    
    pause
    
    echo -e "${RED}COMMON ERROR: return with large number${NC}"
    echo ""
    
    get_big_number() {
        return 1000
    }
    
    echo "Function:"
    echo '  get_big_number() {'
    echo '      return 1000'
    echo '  }'
    echo ""
    get_big_number || true
    echo "Exit code: $?"
    echo ""
    echo -e "${RED}1000 % 256 = 232 ← return truncates to 0-255!${NC}"
    echo -e "${RED}For large values, use echo + command substitution${NC}"
    
    pause
    
    echo -e "${YELLOW}METHOD 3: Nameref (Bash 4.3+)${NC}"
    echo ""
    
    calculate() {
        local -n result_ref=$1
        local a=$2 b=$3
        result_ref=$((a * b))
    }
    
    echo "Function:"
    echo '  calculate() {'
    echo '      local -n result_ref=$1  # Nameref!'
    echo '      local a=$2 b=$3'
    echo '      result_ref=$((a * b))'
    echo '  }'
    echo ""
    
    declare my_result
    calculate my_result 6 7
    echo "Call: calculate my_result 6 7"
    echo -e "my_result = ${GREEN}$my_result${NC}"
    
    pause
    
    echo -e "${BOLD}RETURN METHODS SUMMARY:${NC}"
    echo ""
    echo "┌────────────────────┬──────────────────────────────────────────────┐"
    echo "│ Method             │ When to use                                  │"
    echo "├────────────────────┼──────────────────────────────────────────────┤"
    echo "│ echo + \$()         │ For strings and numbers                      │"
    echo "│ return             │ Only for exit codes (0-255)                  │"
    echo "│ global variable    │ Avoid - pollutes namespace                   │"
    echo "│ nameref            │ Multiple return values (Bash 4.3+)           │"
    echo "└────────────────────┴──────────────────────────────────────────────┘"
}

# ============================================================
# DEMO 4: DEFENSIVE ARGUMENTS
# ============================================================
demo_defensive() {
    banner "DEMO 4: DEFENSIVE ARGUMENTS"
    
    echo -e "${YELLOW}Checking mandatory arguments:${NC}"
    echo ""
    
    unsafe_greet() {
        echo "Hello, $1!"
    }
    
    safe_greet() {
        local name="${1:?Error: name argument required}"
        echo "Hello, $name!"
    }
    
    echo "UNSAFE function:"
    echo '  unsafe_greet() {'
    echo '      echo "Hello, $1!"'
    echo '  }'
    echo ""
    echo "Call without argument:"
    echo -e "  Result: ${YELLOW}$(unsafe_greet)${NC}"
    echo -e "  ${RED}→ Empty string, no error!${NC}"
    
    echo ""
    echo "SAFE function:"
    echo '  safe_greet() {'
    echo '      local name="${1:?Error: name argument required}"'
    echo '      echo "Hello, $name!"'
    echo '  }'
    echo ""
    echo "Call without argument:"
    (safe_greet 2>&1) || true
    echo -e "  ${GREEN}→ Clear error!${NC}"
    
    pause
    
    echo -e "${YELLOW}Default values for optional arguments:${NC}"
    echo ""
    
    greet_with_default() {
        local name="${1:-World}"
        local greeting="${2:-Hello}"
        echo "$greeting, $name!"
    }
    
    echo "Function:"
    echo '  greet_with_default() {'
    echo '      local name="${1:-World}"'
    echo '      local greeting="${2:-Hello}"'
    echo '      echo "$greeting, $name!"'
    echo '  }'
    echo ""
    echo "greet_with_default"
    echo -e "  → ${GREEN}$(greet_with_default)${NC}"
    echo ""
    echo 'greet_with_default "Alice"'
    echo -e "  → ${GREEN}$(greet_with_default "Alice")${NC}"
    echo ""
    echo 'greet_with_default "Alice" "Salut"'
    echo -e "  → ${GREEN}$(greet_with_default "Alice" "Salut")${NC}"
    
    pause
    
    echo -e "${BOLD}COMMON PATTERNS:${NC}"
    echo ""
    echo '${var:-default}    # Use default if var is unset or empty'
    echo '${var:=default}    # Set var to default if unset or empty'
    echo '${var:?error}      # Error if var is unset or empty'
    echo '${var:+value}      # Use value if var IS set'
}

# ============================================================
# DEMO 5: RECURSIVE FUNCTIONS
# ============================================================
demo_recursive() {
    banner "DEMO 5: RECURSIVE FUNCTIONS"
    
    echo -e "${YELLOW}Classic example: Factorial${NC}"
    echo ""
    
    factorial() {
        local n=$1
        if (( n <= 1 )); then
            echo 1
        else
            local prev
            prev=$(factorial $((n - 1)))
            echo $((n * prev))
        fi
    }
    
    echo "Function:"
    echo '  factorial() {'
    echo '      local n=$1'
    echo '      if (( n <= 1 )); then'
    echo '          echo 1'
    echo '      else'
    echo '          local prev=$(factorial $((n - 1)))'
    echo '          echo $((n * prev))'
    echo '      fi'
    echo '  }'
    echo ""
    
    for i in 1 3 5 7; do
        echo "factorial($i) = $(factorial $i)"
    done
    
    pause
    
    echo -e "${RED}⚠️ Trap: Recursion in Bash is SLOW!${NC}"
    echo ""
    echo "Each recursive call creates a subshell."
    echo "For intensive calculations, use loops or another language."
    echo ""
    echo "Timing example:"
    echo -n "  factorial(10) = "
    time_start=$(date +%s.%N)
    result=$(factorial 10)
    time_end=$(date +%s.%N)
    echo "$result (time: $(echo "$time_end - $time_start" | bc)s)"
}

# ============================================================
# MAIN
# ============================================================
main() {
    banner "BASH FUNCTIONS DEMO"
    
    echo "This demo covers:"
    echo "  1. Definition and call"
    echo "  2. Local vs global variables (CRITICAL!)"
    echo "  3. Return values"
    echo "  4. Defensive arguments"
    echo "  5. Recursive functions"
    
    pause
    
    demo_basics
    pause
    
    demo_scope
    pause
    
    demo_return
    pause
    
    demo_defensive
    pause
    
    demo_recursive
    
    banner "SUMMARY"
    
    cat << 'EOF'
╔══════════════════════════════════════════════════════════════════════════╗
║  KEY FUNCTION LESSONS:                                                   ║
║                                                                          ║
║  ✓ Use POSIX syntax: func() { ... }                                     ║
║  ✓ ALWAYS use 'local' for variables in functions                        ║
║  ✓ Return strings with echo, exit codes with return                     ║
║  ✓ Check arguments: ${1:?Error message}                                 ║
║  ✓ Provide defaults: ${1:-default_value}                                ║
║  ✓ Avoid recursion for intensive operations                             ║
║                                                                          ║
╚══════════════════════════════════════════════════════════════════════════╝
EOF
    
    echo ""
    echo -e "${GREEN}Demo complete!${NC}"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
