#!/bin/bash
# =============================================================================
# heron_WHILE.sh
# Heron's Method (Babylonian) for computing the square root
# Control structure used: WHILE
#
# Algorithm:
#   1. Start with the initial estimate:   x = N / 2
#   2. Refine using:                      x = ( x + N/x ) / 2
#   3. Stop AUTOMATICALLY when the difference between two consecutive
#      iterations falls below a threshold (0.0000001) — mathematical convergence
#
# Why WHILE here?
#   WHILE repeats AS LONG AS a condition holds true.
#   We do not know in advance how many iterations are needed — it depends on N.
#   For N=4 it converges in ~4 steps; for N=1000000 it may take 20+.
#   WHILE detects convergence and stops at precisely the right moment.
#   This is the most algorithmically correct variant of the three.
# =============================================================================


# -----------------------------------------------------------------------------
# SECTION 1: READ INPUT
# -----------------------------------------------------------------------------

read -p "Enter a positive integer: " N


# -----------------------------------------------------------------------------
# SECTION 2: INPUT VALIDATION
# -----------------------------------------------------------------------------

if [ -z "$N" ]; then
    echo "Error: no input provided."
    exit 1
fi

if ! [[ "$N" =~ ^[0-9]+$ ]]; then
    echo "Error: '${N}' is not a positive integer."
    exit 1
fi

if [ "$N" -eq 0 ]; then
    echo "sqrt(0) = 0"
    exit 0
fi


# -----------------------------------------------------------------------------
# SECTION 3: INITIAL ESTIMATE AND COUNTER INITIALISATION
# -----------------------------------------------------------------------------

# Initial estimate: x = N/2
# scale=8 = 8 decimal places for adequate precision
x=$(echo "scale=8; $N / 2" | bc)

# Iteration counter — not required by the algorithm,
# but displayed at the end so we can see how many iterations WHILE performed
# (compare with FOR, which always runs exactly 10)
step=0

echo "--------------------------------------"
echo "Number: N = $N"
echo "Start:  x = $x   (initial estimate = N/2)"
echo "--------------------------------------"


# -----------------------------------------------------------------------------
# SECTION 4: WHILE LOOP until convergence
#
# General structure of WHILE in Bash:
#
#   while [ condition ]; do
#       commands
#   done
#
#   OR with a perpetually true condition + manual break:
#   while true; do
#       commands
#       if [ stopping_condition ]; then
#           break    # exits the loop
#       fi
#   done
#
# We use the "while true + break" variant because:
#   - We must compute x_new BEFORE we can test for convergence
#   - We cannot test something at the start of the loop that has not
#     been calculated yet
#   - Therefore: compute, test, break if appropriate
#
# Caution: "while true" without break = infinite loop!
#   If that happens, press Ctrl+C to stop the script.
# -----------------------------------------------------------------------------

while true; do

    # Compute the new value of x according to Heron's formula
    # Store in x_new so we can compare it with the old x (for the diff)
    x_new=$(echo "scale=8; ($x + $N / $x) / 2" | bc)

    # Increment the step counter
    # $(( expression )) = integer arithmetic in Bash (no bc, no decimals)
    step=$(( step + 1 ))

    echo "Step $step: x = $x_new"

    # Compute the absolute difference between the current and previous iteration
    # When this difference is close to zero, we have converged
    diff=$(echo "scale=8; $x_new - $x" | bc)

    # bc may return a negative number if x_new < x
    # We want the absolute value (the distance, regardless of sign)
    if [ $(echo "$diff < 0" | bc) -eq 1 ]; then
        diff=$(echo "scale=8; -1 * $diff" | bc)
    fi

    # Update x with the new value BEFORE the convergence test
    # (x becomes x_new for the next iteration)
    x=$x_new

    # STOPPING CONDITION — convergence threshold
    # If the difference between two consecutive iterations < 0.0000001,
    # we consider that we have converged with sufficient precision
    #
    # break = exits the while (or for) loop immediately
    # continue = skips to the next iteration (not used here)
    if [ $(echo "$diff < 0.0000001" | bc) -eq 1 ]; then
        break
    fi

done    # <-- closes the while block

echo "--------------------------------------"
echo "Convergence reached in $step iterations."
echo "sqrt($N) ≈ $x"
echo "--------------------------------------"


# -----------------------------------------------------------------------------
# SECTION 5: ITERATION COUNT COMPARISON
#
# Try these values and note how many iterations WHILE performs:
#
#   N=4       → sqrt=2.0       (few iterations, rapid convergence)
#   N=2       → sqrt≈1.414...  (converges in ~4 steps)
#   N=144     → sqrt=12.0      (~7 steps)
#   N=10000   → sqrt=100.0     (~12 steps)
#   N=999983  → sqrt≈999.99... (~18 steps)
#
# FOR would always run 10 iterations, regardless of N.
# WHILE runs exactly as many as needed — no more and no fewer.
#
# Question for students:
#   What happens if you replace "while true" with "while [ $step -lt 3 ]"?
#   For which values of N would that suffice? For which would it not?
# -----------------------------------------------------------------------------
