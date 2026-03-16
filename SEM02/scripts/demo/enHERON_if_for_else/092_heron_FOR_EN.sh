#!/bin/bash
# =============================================================================
# heron_FOR.sh
# Heron's Method (Babylonian) for computing the square root
# Control structure used: FOR
#
# Algorithm:
#   1. Start with the initial estimate:    x = N / 2
#   2. Refine exactly 10 times with:       x = ( x + N/x ) / 2
#   3. After 10 steps,                     x ≈ sqrt(N)
#
# Why FOR here?
#   FOR repeats a block of code a FIXED NUMBER OF TIMES, known in advance.
#   Heron's formula is identical at every step — we write it once in the loop.
#   Difference from IF: no need to copy-paste the same line N times.
#   Difference from WHILE: we do not check for convergence — we run exactly
#   10 steps.
# =============================================================================


# -----------------------------------------------------------------------------
# SECTION 1: READING INPUT
# -----------------------------------------------------------------------------

# read -p "message" variable
#   -p = prompt text displayed before input
read -p "Enter a positive integer: " N


# -----------------------------------------------------------------------------
# SECTION 2: INPUT VALIDATION
#
# Same logic as in heron_IF.sh — validation with if/elif.
# Kept separate from FOR for clarity: validation is still an IF,
# FOR comes afterwards, for the actual computation.
# -----------------------------------------------------------------------------

# -z = test for Zero length (empty field?)
if [ -z "$N" ]; then
    echo "Error: no input provided."
    exit 1
fi

# =~ ^[0-9]+$  = regex: digits only, from start to end
# !  = negates the condition (we want to catch INVALID input)
if ! [[ "$N" =~ ^[0-9]+$ ]]; then
    echo "Error: '${N}' is not a positive integer."
    exit 1
fi

# Special case: 0 (avoid division by zero in the formula)
if [ "$N" -eq 0 ]; then
    echo "sqrt(0) = 0"
    exit 0
fi


# -----------------------------------------------------------------------------
# SECTION 3: INITIAL ESTIMATE
# -----------------------------------------------------------------------------

# bc = Basic Calculator for decimal arithmetic
# scale=8 = 8 decimal places (more precise than in heron_IF.sh)
# Increasing scale lets us observe convergence more clearly in the output
x=$(echo "scale=8; $N / 2" | bc)

echo "--------------------------------------"
echo "Number: N = $N"
echo "Start:  x = $x   (initial estimate = N/2)"
echo "--------------------------------------"


# -----------------------------------------------------------------------------
# SECTION 4: FOR LOOP — 10 Heron iterations
#
# General structure of FOR in Bash:
#
#   Variant 1 — explicit list:
#     for var in val1 val2 val3 ... valN; do
#         commands
#     done
#
#   Variant 2 — range with braces (brace expansion):
#     for var in {1..10}; do
#         commands
#     done
#
#   Variant 3 — seq (more flexible, accepts variables):
#     for var in $(seq 1 $MAX); do
#         commands
#     done
#
#   Variant 4 — C-style (familiar from C/Java):
#     for (( var=1; var<=10; var++ )); do
#         commands
#     done
#
# Here we use variant 2 (range) — the most visually clear.
# -----------------------------------------------------------------------------

for step in {1..10}; do

    # Heron's formula: x_new = ( x_old + N / x_old ) / 2
    # Written ONCE — this is the power of the loop compared to IF
    x=$(echo "scale=8; ($x + $N / $x) / 2" | bc)

    # $step = counter variable — takes the values 1, 2, 3, ..., 10
    echo "Step $step: x = $x"

done    # <-- closes the for block (equivalent to fi for if)

echo "--------------------------------------"
echo "sqrt($N) ≈ $x   (after 10 iterations)"
echo "--------------------------------------"


# -----------------------------------------------------------------------------
# SECTION 5: REMARK ON EFFICIENCY
#
# Run with N=9 and observe the output:
#   sqrt(9) = 3 exactly.
#   From step 4 onward, the value no longer changes.
#   Yet FOR continues until step 10 — performing 6 unnecessary steps.
#
# Conclusion: FOR cannot detect convergence and stop on its own.
#   => If we want dynamic stopping, we need WHILE + break.
#      (see heron_WHILE.sh)
# -----------------------------------------------------------------------------

# FOR variants you can try on the server:
#
# With an explicit list (identical to {1..10}):
#   for step in 1 2 3 4 5 6 7 8 9 10; do
#
# With seq and a variable for the number of steps:
#   MAX=10
#   for step in $(seq 1 $MAX); do
#
# C-style (for those familiar with C/Java):
#   for (( step=1; step<=10; step++ )); do
