#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════════
# S05_ex02_arrays_sol.sh — Solution Exercise 2: Array Manipulation
# ═══════════════════════════════════════════════════════════════════════════════
# Operating Systems | ASE Bucharest - CSIE
# Seminar 05: Advanced Bash Scripting
#
# REQUIREMENT:
#   Demonstrate operations with indexed and associative arrays.
#
# USAGE:
#   ./S05_ex02_arrays_sol.sh
# ═══════════════════════════════════════════════════════════════════════════════

set -euo pipefail

demo_indexed_arrays() {
    echo "═══════════════════════════════════════════════════════════════"
    echo "  INDEXED ARRAYS"
    echo "═══════════════════════════════════════════════════════════════"
    
    # Declaration and initialisation
    local -a fruits=("apple" "pear" "banana" "orange")
    
    echo "1. Initial array: ${fruits[*]}"
    echo "2. Element [0]: ${fruits[0]}"
    echo "3. Length: ${#fruits[@]}"
    echo "4. Indices: ${!fruits[@]}"
    
    echo "5. Correct iteration:"
    for fruit in "${fruits[@]}"; do
        echo "   - $fruit"
    done
    
    # Append
    fruits+=("kiwi")
    echo "6. After append: ${fruits[*]}"
    
    # Delete (creates sparse array)
    unset 'fruits[1]'
    echo "7. After unset [1] - Indices: ${!fruits[@]} (sparse!)"
}

demo_associative_arrays() {
    echo ""
    echo "═══════════════════════════════════════════════════════════════"
    echo "  ASSOCIATIVE ARRAYS (Hash)"
    echo "═══════════════════════════════════════════════════════════════"
    
    # MANDATORY: declare -A
    declare -A config
    config[host]="localhost"
    config[port]="8080"
    config[debug]="true"
    
    echo "1. Keys: ${!config[*]}"
    echo "2. Values: ${config[*]}"
    echo "3. Access: config[host]=${config[host]}"
    
    echo "4. Key=value iteration:"
    for key in "${!config[@]}"; do
        echo "   $key = ${config[$key]}"
    done
}

demo_files_with_spaces() {
    echo ""
    echo "═══════════════════════════════════════════════════════════════"
    echo "  FILES WITH SPACES (importance of quotes)"
    echo "═══════════════════════════════════════════════════════════════"
    
    local -a files=("document one.txt" "report two.pdf" "data three.csv")
    
    echo "WRONG (without quotes) - would be ${#files[@]} * 2 iterations"
    echo "CORRECT (with quotes):"
    local count=0
    for f in "${files[@]}"; do
        ((count++))
        echo "   $count: '$f'"
    done
    echo "Total correct iterations: $count"
}

main() {
    demo_indexed_arrays
    demo_associative_arrays
    demo_files_with_spaces
    echo ""
    echo "All demonstrations complete!"
}

main "$@"
