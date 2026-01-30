#!/bin/bash
# Test 04: AWK Data Analysis
# Score: 10 points (2 points per exercise)
set -euo pipefail

SCORE=0
TOTAL=10
DATA_DIR="../resources/sample_data"

echo "=== TEST 04: AWK DATA ANALYSIS ==="
echo ""

# Ex 1: Total number of active employees
echo -n "Ex 1 - Active employees: "
EXPECTED=13
RESULT=$(awk -F',' 'NR>1 && $7=="active" {count++} END {print count}' "$DATA_DIR/employees.csv" 2>/dev/null || echo 0)
if [[ "$RESULT" == "$EXPECTED" ]]; then
    echo "✅ CORRECT ($RESULT)"
    ((SCORE+=2))
else
    echo "❌ Wrong (got: $RESULT, expected: $EXPECTED)"
fi

# Ex 2: Sum of Engineering salaries
echo -n "Ex 2 - Total Engineering salaries: "
EXPECTED=490000
RESULT=$(awk -F',' 'NR>1 && $4=="Engineering" {sum+=$5} END {print sum}' "$DATA_DIR/employees.csv" 2>/dev/null || echo 0)
if [[ "$RESULT" == "$EXPECTED" ]]; then
    echo "✅ CORRECT (\$$RESULT)"
    ((SCORE+=2))
else
    echo "❌ Wrong (got: $RESULT, expected: $EXPECTED)"
fi

# Ex 3: Average salary
echo -n "Ex 3 - Average salary: "
EXPECTED=70600
RESULT=$(awk -F',' 'NR>1 {sum+=$5; count++} END {printf "%.0f", sum/count}' "$DATA_DIR/employees.csv" 2>/dev/null || echo 0)
if [[ "$RESULT" == "$EXPECTED" ]]; then
    echo "✅ CORRECT (\$$RESULT)"
    ((SCORE+=2))
else
    echo "❌ Wrong (got: $RESULT, expected: $EXPECTED)"
fi

# Ex 4: Total Laptop sales
echo -n "Ex 4 - Laptop revenue: "
EXPECTED=22800
RESULT=$(awk -F',' 'NR>1 && $2=="Laptop" {sum+=$3*$4} END {printf "%.0f", sum}' "$DATA_DIR/sales.csv" 2>/dev/null || echo 0)
if [[ "$RESULT" == "$EXPECTED" ]]; then
    echo "✅ CORRECT (\$$RESULT)"
    ((SCORE+=2))
else
    echo "❌ Wrong (got: $RESULT, expected: $EXPECTED)"
fi

# Ex 5: Department with most employees
echo -n "Ex 5 - Largest department: "
EXPECTED="Engineering"
RESULT=$(awk -F',' 'NR>1 {count[$4]++} END {max=0; for(d in count) if(count[d]>max) {max=count[d]; dept=d} print dept}' "$DATA_DIR/employees.csv" 2>/dev/null || echo "")
if [[ "$RESULT" == "$EXPECTED" ]]; then
    echo "✅ CORRECT ($RESULT)"
    ((SCORE+=2))
else
    echo "❌ Wrong (got: $RESULT, expected: $EXPECTED)"
fi

echo ""
echo "=== FINAL SCORE: $SCORE / $TOTAL ==="
