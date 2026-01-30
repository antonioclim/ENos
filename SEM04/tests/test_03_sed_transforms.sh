#!/bin/bash
# Test 03: SED Transformations
# Score: 10 points (2 points per exercise)
set -euo pipefail

SCORE=0
TOTAL=10
DATA_DIR="../resources/sample_data"
TEMP_DIR="/tmp/sed_test_$$"
mkdir -p "$TEMP_DIR"

echo "=== TEST 03: SED TRANSFORMATIONS ==="
echo ""

# Ex 1: Delete comments (lines starting with #)
echo -n "Ex 1 - Delete comments: "
EXPECTED=31
RESULT=$(sed '/^#/d' "$DATA_DIR/config.ini" | grep -c '.' 2>/dev/null || echo 0)
if [[ "$RESULT" == "$EXPECTED" ]]; then
    echo "✅ CORRECT ($RESULT lines remaining)"
    ((SCORE+=2))
else
    echo "❌ Wrong (got: $RESULT, expected: $EXPECTED)"
fi

# Ex 2: Replace 'true' with 'yes'
echo -n "Ex 2 - true -> yes: "
EXPECTED=2
RESULT=$(sed 's/true/yes/g' "$DATA_DIR/config.ini" | grep -c 'yes' 2>/dev/null || echo 0)
if [[ "$RESULT" == "$EXPECTED" ]]; then
    echo "✅ CORRECT ($RESULT replacements)"
    ((SCORE+=2))
else
    echo "❌ Wrong (got: $RESULT, expected: $EXPECTED)"
fi

# Ex 3: Extract only values (after =)
echo -n "Ex 3 - Extract values after =: "
cp "$DATA_DIR/config.ini" "$TEMP_DIR/temp.ini"
EXPECTED=25
RESULT=$(sed -n '/=/s/.*= *//p' "$TEMP_DIR/temp.ini" | wc -l)
if [[ "$RESULT" == "$EXPECTED" ]]; then
    echo "✅ CORRECT ($RESULT values)"
    ((SCORE+=2))
else
    echo "❌ Wrong (got: $RESULT, expected: $EXPECTED)"
fi

# Ex 4: Add prefix "CONFIG_" to sections [xxx]
echo -n "Ex 4 - Prefix for sections: "
EXPECTED=6
RESULT=$(sed 's/\[\([^]]*\)\]/[CONFIG_\1]/' "$DATA_DIR/config.ini" | grep -c 'CONFIG_' 2>/dev/null || echo 0)
if [[ "$RESULT" == "$EXPECTED" ]]; then
    echo "✅ CORRECT ($RESULT sections modified)"
    ((SCORE+=2))
else
    echo "❌ Wrong (got: $RESULT, expected: $EXPECTED)"
fi

# Ex 5: Delete empty lines and comments
echo -n "Ex 5 - Clean config: "
EXPECTED=25
RESULT=$(sed '/^#/d; /^$/d; /^[[:space:]]*$/d' "$DATA_DIR/config.ini" | wc -l)
if [[ "$RESULT" == "$EXPECTED" ]]; then
    echo "✅ CORRECT ($RESULT clean lines)"
    ((SCORE+=2))
else
    echo "❌ Wrong (got: $RESULT, expected: $EXPECTED)"
fi

rm -rf "$TEMP_DIR"

echo ""
echo "=== FINAL SCORE: $SCORE / $TOTAL ==="
