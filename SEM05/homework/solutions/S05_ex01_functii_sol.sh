#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════════
# S05_ex01_functii_sol.sh — Solution Exercise 1: Functions with Local Variables
# ═══════════════════════════════════════════════════════════════════════════════
# Operating Systems | ASE Bucharest - CSIE
# Seminar 05: Advanced Bash Scripting
#
# REQUIREMENT:
#   Create functions that demonstrate correct use of local variables
#   and returning values via echo.
#
# USAGE:
#   ./S05_ex01_functii_sol.sh
#
# KEY POINTS:
#   - Using the 'local' keyword for variables in functions
#   - Returning values via echo (not return)
#   - Capturing results with $()
# ═══════════════════════════════════════════════════════════════════════════════

set -euo pipefail

# ─────────────────────────────────────────────────────────────────────────────
# Function: count_words
# Description: Counts words in a string
# Arguments: $1 - string to analyse
# Returns: Number of words (via echo)
# ─────────────────────────────────────────────────────────────────────────────
count_words() {
    local text="$1"
    local count
    
    # Use wc -w for counting
    count=$(echo "$text" | wc -w)
    
    # Return via echo (NOT return!)
    echo "$count"
}

# ─────────────────────────────────────────────────────────────────────────────
# Function: calculate_sum
# Description: Calculates the sum of N numbers
# Arguments: $@ - list of numbers
# Returns: Sum (via echo)
# ─────────────────────────────────────────────────────────────────────────────
calculate_sum() {
    local sum=0
    local number
    
    for number in "$@"; do
        # Verify it's a valid number
        if [[ "$number" =~ ^-?[0-9]+$ ]]; then
            sum=$((sum + number))
        fi
    done
    
    echo "$sum"
}

# ─────────────────────────────────────────────────────────────────────────────
# Function: validate_email
# Description: Checks if a string is a valid email (simple)
# Arguments: $1 - string to verify
# Returns: 0 (valid) or 1 (invalid) via exit code
# ─────────────────────────────────────────────────────────────────────────────
validate_email() {
    local email="$1"
    local pattern='^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    
    if [[ "$email" =~ $pattern ]]; then
        return 0  # Valid
    else
        return 1  # Invalid
    fi
}

# ─────────────────────────────────────────────────────────────────────────────
# Function: find_maximum
# Description: Finds the maximum value from a list of numbers
# Arguments: $@ - list of numbers
# Returns: Maximum (via echo)
# ─────────────────────────────────────────────────────────────────────────────
find_maximum() {
    local max
    local number
    
    # Initialise with first argument
    max="${1:-}"
    
    if [[ -z "$max" ]]; then
        echo ""
        return 1
    fi
    
    for number in "$@"; do
        if [[ "$number" =~ ^-?[0-9]+$ ]] && (( number > max )); then
            max="$number"
        fi
    done
    
    echo "$max"
}

# ─────────────────────────────────────────────────────────────────────────────
# Function: transform_uppercase
# Description: Converts string to uppercase
# Arguments: $1 - string to transform
# Returns: String in uppercase (via echo)
# ─────────────────────────────────────────────────────────────────────────────
transform_uppercase() {
    local text="$1"
    local result
    
    # Bash 4.0+ feature
    result="${text^^}"
    
    echo "$result"
}

# ═══════════════════════════════════════════════════════════════════════════════
# TESTS / DEMONSTRATIONS
# ═══════════════════════════════════════════════════════════════════════════════

main() {
    echo "═══════════════════════════════════════════════════════════════"
    echo "  Demonstration: Functions with Local Variables"
    echo "═══════════════════════════════════════════════════════════════"
    echo ""
    
    # Test count_words
    echo "1. count_words:"
    local result
    result=$(count_words "This is a test sentence")
    echo "   Input: 'This is a test sentence'"
    echo "   Result: $result words"
    echo ""
    
    # Test calculate_sum
    echo "2. calculate_sum:"
    result=$(calculate_sum 10 20 30 40)
    echo "   Input: 10 20 30 40"
    echo "   Result: $result"
    echo ""
    
    # Test validate_email
    echo "3. validate_email:"
    local email1="test@example.com"
    local email2="invalid-email"
    
    if validate_email "$email1"; then
        echo "   '$email1' → VALID"
    else
        echo "   '$email1' → INVALID"
    fi
    
    if validate_email "$email2"; then
        echo "   '$email2' → VALID"
    else
        echo "   '$email2' → INVALID"
    fi
    echo ""
    
    # Test find_maximum
    echo "4. find_maximum:"
    result=$(find_maximum 5 23 7 42 15 8)
    echo "   Input: 5 23 7 42 15 8"
    echo "   Maximum: $result"
    echo ""
    
    # Test transform_uppercase
    echo "5. transform_uppercase:"
    result=$(transform_uppercase "hello world")
    echo "   Input: 'hello world'"
    echo "   Result: '$result'"
    echo ""
    
    echo "═══════════════════════════════════════════════════════════════"
    echo "  All tests passed!"
    echo "═══════════════════════════════════════════════════════════════"
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
