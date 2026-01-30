#!/bin/bash
# Test 01: Regex Basics - BRE vs ERE
# Score: 10 points (2 points per exercise)
set -euo pipefail

SCORE=0
TOTAL=10
DATA_DIR="../resources/sample_data"

echo "=== TEST 01: REGEX BASICS ==="
echo ""

# Ex 1: Find lines starting with # (comments)
echo -n "Ex 1 - Comments (^#): "
EXPECTED=6
RESULT=$(grep -c '^#' "$DATA_DIR/config.ini" 2>/dev/null || echo 0)
if [[ "$RESULT" == "$EXPECTED" ]]; then
    echo "✅ CORRECT ($RESULT)"
    ((SCORE+=2))
else
    echo "❌ Wrong (got: $RESULT, expected: $EXPECTED)"
fi

# Ex 2: Find empty lines
echo -n "Ex 2 - Empty lines (^$): "
EXPECTED=6
RESULT=$(grep -c '^$' "$DATA_DIR/config.ini" 2>/dev/null || echo 0)
if [[ "$RESULT" == "$EXPECTED" ]]; then
    echo "✅ CORRECT ($RESULT)"
    ((SCORE+=2))
else
    echo "❌ Wrong (got: $RESULT, expected: $EXPECTED)"
fi

# Ex 3: Find IP addresses (simple pattern)
echo -n "Ex 3 - IP addresses: "
EXPECTED=6
RESULT=$(grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' "$DATA_DIR/contacts.txt" 2>/dev/null | wc -l)
if [[ "$RESULT" == "$EXPECTED" ]]; then
    echo "✅ CORRECT ($RESULT)"
    ((SCORE+=2))
else
    echo "❌ Wrong (got: $RESULT, expected: $EXPECTED)"
fi

# Ex 4: Find emails
echo -n "Ex 4 - Emails: "
EXPECTED=10
RESULT=$(grep -oE '[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}' "$DATA_DIR/contacts.txt" 2>/dev/null | wc -l)
if [[ "$RESULT" == "$EXPECTED" ]]; then
    echo "✅ CORRECT ($RESULT)"
    ((SCORE+=2))
else
    echo "❌ Wrong (got: $RESULT, expected: $EXPECTED)"
fi

# Ex 5: Find consecutive duplicate words
echo -n "Ex 5 - Duplicate words: "
EXPECTED=1
RESULT=$(grep -oE '\b(\w+)\s+\1\b' "$DATA_DIR/contacts.txt" 2>/dev/null | wc -l)
if [[ "$RESULT" == "$EXPECTED" ]]; then
    echo "✅ CORRECT ($RESULT)"
    ((SCORE+=2))
else
    echo "❌ Wrong (got: $RESULT, expected: $EXPECTED)"
fi

echo ""
echo "=== FINAL SCORE: $SCORE / $TOTAL ==="
