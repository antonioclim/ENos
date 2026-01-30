#!/bin/bash
# Test 02: GREP Mastery
# Score: 10 points (2 points per exercise)
set -euo pipefail

SCORE=0
TOTAL=10
DATA_DIR="../resources/sample_data"

echo "=== TEST 02: GREP MASTERY ==="
echo ""

# Ex 1: Count ERRORs in log
echo -n "Ex 1 - Count ERROR: "
EXPECTED=4
RESULT=$(grep -c 'ERROR' "$DATA_DIR/server.log" 2>/dev/null || echo 0)
if [[ "$RESULT" == "$EXPECTED" ]]; then
    echo "✅ CORRECT ($RESULT)"
    ((SCORE+=2))
else
    echo "❌ Wrong (got: $RESULT, expected: $EXPECTED)"
fi

# Ex 2: Find WARNING and ERROR (case insensitive)
echo -n "Ex 2 - WARNING or ERROR: "
EXPECTED=9
RESULT=$(grep -ciE 'warning|error' "$DATA_DIR/server.log" 2>/dev/null || echo 0)
if [[ "$RESULT" == "$EXPECTED" ]]; then
    echo "✅ CORRECT ($RESULT)"
    ((SCORE+=2))
else
    echo "❌ Wrong (got: $RESULT, expected: $EXPECTED)"
fi

# Ex 3: Lines that do NOT contain INFO
echo -n "Ex 3 - Lines without INFO: "
EXPECTED=12
RESULT=$(grep -cv 'INFO' "$DATA_DIR/server.log" 2>/dev/null || echo 0)
if [[ "$RESULT" == "$EXPECTED" ]]; then
    echo "✅ CORRECT ($RESULT)"
    ((SCORE+=2))
else
    echo "❌ Wrong (got: $RESULT, expected: $EXPECTED)"
fi

# Ex 4: Extract only unique IPs
echo -n "Ex 4 - Unique IPs: "
EXPECTED=9
RESULT=$(grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' "$DATA_DIR/server.log" 2>/dev/null | sort -u | wc -l)
if [[ "$RESULT" == "$EXPECTED" ]]; then
    echo "✅ CORRECT ($RESULT)"
    ((SCORE+=2))
else
    echo "❌ Wrong (got: $RESULT, expected: $EXPECTED)"
fi

# Ex 5: Number of logins
echo -n "Ex 5 - Logins: "
EXPECTED=3
RESULT=$(grep -c 'logged in' "$DATA_DIR/server.log" 2>/dev/null || echo 0)
if [[ "$RESULT" == "$EXPECTED" ]]; then
    echo "✅ CORRECT ($RESULT)"
    ((SCORE+=2))
else
    echo "❌ Wrong (got: $RESULT, expected: $EXPECTED)"
fi

echo ""
echo "=== FINAL SCORE: $SCORE / $TOTAL ==="
