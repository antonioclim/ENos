#!/bin/bash
# Integer Heron approximation, truncated (not rounded) to the requested decimals.
# Requires Bash with signed 64-bit arithmetic. Accepted domain: non-negative
# integer NUMBER, PRECISION 0..9, NUMBER * 10^(2*PRECISION) <= 2^63-1.
set -euo pipefail
if (( $# != 2 )) || [[ ! $1 =~ ^[0-9]+$ || ! $2 =~ ^[0-9]+$ ]]; then
    echo "Usage: $0 <non-negative integer> <decimal places 0..9>" >&2; exit 2
fi
NUMBER=$1 PRECISION=$2
while [[ ${#NUMBER} -gt 1 && $NUMBER == 0* ]]; do NUMBER=${NUMBER:1}; done
while [[ ${#PRECISION} -gt 1 && $PRECISION == 0* ]]; do PRECISION=${PRECISION:1}; done
if [[ ${#NUMBER} -gt 19 || ${#PRECISION} -gt 1 ]] || (( PRECISION > 9 )); then
    echo 'Supported-range error: precision 0..9 and scaled value <= 2^63-1 are required.' >&2; exit 2
fi
MAX_INTEGER=9223372036854775807
if (( MAX_INTEGER <= 0 )) || [[ ${#NUMBER} -eq 19 && $NUMBER > 9223372036854775807 ]]; then
    echo 'Supported-range error: signed 64-bit arithmetic required.' >&2; exit 2
fi
SCALE_FACTOR=$((10**PRECISION))
SCALE_SQUARED=$((SCALE_FACTOR*SCALE_FACTOR))
if (( NUMBER > MAX_INTEGER / SCALE_SQUARED )); then
    echo 'Supported-range error: NUMBER * 10^(2*PRECISION) would overflow.' >&2; exit 2
fi
TARGET=$((NUMBER*SCALE_SQUARED))
x=$TARGET
y=$((TARGET/2+1))
# Descending integer Heron sequence, ending at floor(sqrt(TARGET)).
while (( y < x )); do
    x=$y
    y=$(((x+TARGET/x)/2))
done
if (( PRECISION == 0 )); then
    printf 'Result: %d\n' "$x"
else
    printf 'Result: %d.%0*d\n' "$((x/SCALE_FACTOR))" "$PRECISION" "$((x%SCALE_FACTOR))"
fi
