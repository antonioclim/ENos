#!/bin/bash

# 1. Capture arguments
NUMBER=$1
PRECISION=$2

# Check if arguments are provided
if [[ -z "$NUMBER" || -z "$PRECISION" ]]; then
    echo "Usage: $0 <number> <decimal_places>"
    echo "Example: $0 15 2"
    exit 1
fi

# 2. Prepare the scale
# To achieve P decimal places of precision using only integers,
# we scale the number by 10^(P*2).
# For example, for 2 decimals, we multiply by 10,000 (10^4).
SCALE_FACTOR=$(( 10**PRECISION ))
TARGET=$(( NUMBER * SCALE_FACTOR * SCALE_FACTOR ))

# 3. Implement Heron's Algorithm (Babylonian Method)
# Initial guess: the scaled number itself
x=$TARGET
prev_x=0

# Self-calibration loop
# Because we are working with integers, the value will eventually 
# settle or oscillate between two adjacent integers.
while [ "$x" != "$prev_x" ] && [ "$x" != "$((prev_x + 1))" ] && [ "$x" != "$((prev_x - 1))" ]; do
    prev_x=$x
    # Heron's Formula: x = (x + Target/x) / 2
    x=$(( (x + TARGET / x) / 2 ))
done

# 4. Format the result to place the decimal point correctly
INTEGER_PART=$(( x / SCALE_FACTOR ))
FRACTIONAL_PART=$(( x % SCALE_FACTOR ))

# Output the result
# %0*d ensures leading zeros are kept (e.g., 3.07 instead of 3.7)
printf "Result: %d.%0*d\n" "$INTEGER_PART" "$PRECISION" "$FRACTIONAL_PART"
