#!/bin/bash
set -euo pipefail
command -v bc >/dev/null 2>&1 || { echo 'Error: bc is required.' >&2; exit 2; }
calculate() {
    local result
    if ! result=$(printf '%s\n' "$1" | bc 2>&1); then
        echo "Calculator failed: $result" >&2; return 2
    fi
    if [[ ! $result =~ ^-?([0-9]+([.][0-9]*)?|[.][0-9]+)$ ]]; then
        echo "Calculator returned an invalid scalar: $result" >&2; return 2
    fi
    printf '%s\n' "$result"
}

# =============================================================================
# heron_IF.sh
# Heron's Method (Babylonian) for computing the square root
# Control structure used: IF / ELIF / ELSE
#
# The algorithm:
#   1. Start with an initial estimate:  x = N / 2
#   2. Refine repeatedly with:          x = ( x + N/x ) / 2
#   3. After a FIXED number of steps,   x ≈ sqrt(N)
#
# Why IF here?
#   IF chooses BETWEEN branches — it does not repeat anything.
#   We use it for: input validation + classification of the final result.
#   The 5 computation steps are written out explicitly (copy-paste) — on
#   purpose, so you can see why we need loops (FOR/WHILE) in later variants.
# =============================================================================


# -----------------------------------------------------------------------------
# SECTION 1: READING INPUT
# -----------------------------------------------------------------------------

# read -p "message" variable
#   -p  = prompt — displays the text before waiting for input
#   without -p we would need a separate echo beforehand
read -p "Enter a positive integer: " N


# -----------------------------------------------------------------------------
# SECTION 2: INPUT VALIDATION with IF / ELIF / ELSE
#
# General structure:
#   if [ condition1 ]; then
#       ...
#   elif [ condition2 ]; then
#       ...
#   else
#       ...
#   fi
#
# Note: fi = "if" spelt backwards — closes the block (like done for for/while)
# -----------------------------------------------------------------------------

# Test 1: is the field empty?
# -z "$N"  = True if the string $N has Zero length
# The quotes around $N are mandatory — without them, [ -z ] is a one-argument true test rather than a zero-length test
if [ -z "$N" ]; then
    echo "Error: you did not enter anything. Run the script again."
    # exit 1 = terminate the script with an error code
    # exit 0 = success  |  exit 1 (or anything >0) = error
    exit 1

# Test 2: does the input contain ONLY digits?
# [[ "..." =~ pattern ]]  = regex test in bash (double brackets = bash extended)
# ^[0-9]+$  = starts(^) with one or more digits ([0-9]+) and ends($) there
# !  in front means NOT — we negate the result
elif ! [[ "$N" =~ ^[0-9]+$ ]]; then
    echo "Error: '${N}' is not a positive integer."
    # ${N} with braces = recommended when the variable is adjacent to other text
    exit 1

# Test 3: the special case N = 0 (the formula N/x would divide by zero)
# -eq = equal (NUMERICAL comparison). For strings we would use = or ==
# Other numerical comparisons: -ne -lt -le -gt -ge
elif [[ $N =~ ^0+$ ]]; then
    echo "The square root of 0 is 0."
    exit 0

fi    # <-- mandatory: closes the if/elif/else block


# -----------------------------------------------------------------------------
# SECTION 3: INITIAL ESTIMATE
# -----------------------------------------------------------------------------

# Bash does not handle decimal (floating-point) arithmetic natively.
# We use 'bc' = Basic Calculator, an external mathematical interpreter.
#
# echo "expression" | bc
#   scale=6  = number of decimal places (digits after the point)
#   $N/2     = divide N by 2 for the initial estimate
#
# $( ... ) = command substitution — replaces the command with its output
x=$(calculate "scale=6; $N / 2")

echo "--------------------------------------"
echo "Number: N = $N"
echo "Start:  x = $x   (initial estimate = N/2)"
echo "--------------------------------------"


# -----------------------------------------------------------------------------
# SECTION 4: THE 5 HERON STEPS — written EXPLICITLY (without a loop)
#
# Formula: x_new = ( x_old + N / x_old ) / 2
#
# Why does it converge?
#   If x > sqrt(N), then N/x < sqrt(N).
#   Their mean lies BETWEEN the two — closer to sqrt(N).
#   For positive exact arithmetic, e_next = e^2 / (2*x); convergence is quadratic near the root.
#   Decimal truncation limits the observed accuracy.
#
# The drawback of this IF-based approach:
#   If we want 10 steps, we write the same line 10 times.
#   If we want 100 steps — 100 identical lines. Unsustainable.
#   => The proper solution: FOR or WHILE (see the other scripts)
# -----------------------------------------------------------------------------

# Step 1 — first refinement, the error drops dramatically
x=$(calculate "scale=6; ($x + $N / $x) / 2")
echo "Step 1: x = $x"

# Step 2
x=$(calculate "scale=6; ($x + $N / $x) / 2")
echo "Step 2: x = $x"

# Step 3
x=$(calculate "scale=6; ($x + $N / $x) / 2")
echo "Step 3: x = $x"

# Step 4
x=$(calculate "scale=6; ($x + $N / $x) / 2")
echo "Step 4: x = $x"

# Step 5 — usually already convergent for small numbers
x=$(calculate "scale=6; ($x + $N / $x) / 2")
echo "Step 5: x = $x"

echo "--------------------------------------"


# -----------------------------------------------------------------------------
# SECTION 5: EVALUATING THE RESULT with IF / ELIF / ELSE
#
# We compute the absolute error: | x^2 - N |
# If x = sqrt(N) exactly, then x*x - N = 0.
# In practice, with floating point, we get a very small value, not exactly 0.
# -----------------------------------------------------------------------------

# Compute x^2 - N
error=$(calculate "scale=6; $x * $x - $N")

# bc may return a negative value (if x slightly underestimates sqrt(N))
# We want the absolute value — check the sign and negate if necessary
negative=$(calculate "$error < 0")
if ((negative == 1)); then
    error=$(calculate "scale=6; -1 * $error")
fi

# Classify the precision of the result
# $(calculate "expression") returns 1 (true) or 0 (false)
# -eq 1 = we test whether bc answered "true"
excellent=$(calculate "$error < 0.001")
good=$(calculate "$error < 0.01")
if ((excellent == 1)); then
    echo "Result: EXCELLENT — sqrt($N) ≈ $x"
    echo "        Error |x^2 - N| = $error  (< 0.001)"
elif ((good == 1)); then
    echo "Result: GOOD      — sqrt($N) ≈ $x"
    echo "        Error |x^2 - N| = $error  (< 0.01)"
else
    echo "Result: POOR      — sqrt($N) ≈ $x"
    echo "        Error |x^2 - N| = $error  (>= 0.01)"
fi

echo "--------------------------------------"
