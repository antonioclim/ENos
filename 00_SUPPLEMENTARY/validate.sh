#!/bin/bash
# validate_000supplementary.sh
# Validation script for 000SUPPLEMENTARY folder
# Run from within the 000SUPPLEMENTARY directory

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║         000SUPPLEMENTARY Validation Script v1.0                ║"
echo "║                    ASE Bucharest — CSIE                        ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

ERRORS=0
WARNINGS=0

# Check README.md
echo "Checking documentation..."
if [ -f "README.md" ]; then
    echo "  ✓ README.md exists"
else
    echo "  ✗ README.md MISSING"
    ((ERRORS++))
fi

if [ -f "QUICK_REFERENCE_CARD.md" ]; then
    echo "  ✓ QUICK_REFERENCE_CARD.md exists"
else
    echo "  ⚠ QUICK_REFERENCE_CARD.md missing (optional)"
    ((WARNINGS++))
fi

if [ -f ".gitignore" ]; then
    echo "  ✓ .gitignore exists"
else
    echo "  ⚠ .gitignore missing (recommended)"
    ((WARNINGS++))
fi

# Check folder names (English)
echo ""
echo "Checking folder structure..."
if [ -d "diagrams_png" ]; then
    echo "  ✓ diagrams_png folder (English naming)"
else
    echo "  ✗ diagrams_png folder missing"
    ((ERRORS++))
fi

if [ -d "diagrams_common" ]; then
    echo "  ✓ diagrams_common folder (English naming)"
else
    echo "  ✗ diagrams_common folder missing"
    ((ERRORS++))
fi

# Check no __pycache__
if [ -d "__pycache__" ]; then
    echo "  ✗ __pycache__ should be removed"
    ((ERRORS++))
else
    echo "  ✓ No __pycache__ directory"
fi

# Check Romanian filenames in diagrams
echo ""
echo "Checking diagram filenames..."
if [ -d "diagrams_png" ]; then
    RO_FILES=$(ls diagrams_png/ 2>/dev/null | grep -cE "algoritmi|conditiile|diagrama|evolutia|mecanismul|modele|producator|sectiunea|securitate|spatiu|straturile|structura|tlb_acces|arhitecturi|categorii|comparatie")
    if [ "$RO_FILES" -eq 0 ]; then
        echo "  ✓ All PNG filenames in English"
    else
        echo "  ✗ $RO_FILES Romanian PNG filenames remain"
        ((ERRORS++))
    fi
    
    PNG_COUNT=$(ls diagrams_png/*.png 2>/dev/null | wc -l)
    echo "  ℹ Total PNG files: $PNG_COUNT"
fi

# Check Python syntax
echo ""
echo "Checking code quality..."
python3 -m py_compile generate_diagrams.py 2>/dev/null
if [ $? -eq 0 ]; then
    echo "  ✓ Python syntax OK"
else
    echo "  ✗ Python syntax errors"
    ((ERRORS++))
fi

# Check for type hints in Python
if grep -q "def.*) -> " generate_diagrams.py 2>/dev/null; then
    echo "  ✓ Type hints present"
else
    echo "  ⚠ Type hints missing"
    ((WARNINGS++))
fi

# Check for Oxford comma
echo ""
echo "Checking language quality..."
OXFORD=$(grep -c ", and " Exam_Exercises_Part*.md 2>/dev/null || echo 0)
if [ "$OXFORD" -eq 0 ]; then
    echo "  ✓ No Oxford comma detected"
else
    echo "  ⚠ $OXFORD potential Oxford comma instances"
    ((WARNINGS++))
fi

# Check for AI patterns
AI_PATTERNS=$(grep -ciE "It is important to note|Let's explore|This ensures|Furthermore|Moreover|Additionally" Exam_Exercises_Part*.md 2>/dev/null | awk -F: '{sum+=$2} END {print sum+0}')
if [ "$AI_PATTERNS" -eq 0 ]; then
    echo "  ✓ No AI fingerprint patterns detected"
else
    echo "  ⚠ $AI_PATTERNS AI-like phrases detected"
    ((WARNINGS++))
fi

# Check British spelling
BRITISH=$(grep -c "isation\|ise\b" Exam_Exercises_Part*.md 2>/dev/null | awk -F: '{sum+=$2} END {print sum+0}')
AMERICAN=$(grep -cE "ization|ize\b" Exam_Exercises_Part*.md 2>/dev/null | awk -F: '{sum+=$2} END {print sum+0}')
echo "  ℹ British spellings: $BRITISH, American spellings: $AMERICAN"

# Check content volume
echo ""
echo "Checking content..."
TOTAL_LINES=$(wc -l Exam_Exercises_Part*.md 2>/dev/null | tail -1 | awk '{print $1}')
echo "  ℹ Total exercise content: $TOTAL_LINES lines"

TOTAL_WORDS=$(wc -w Exam_Exercises_Part*.md 2>/dev/null | tail -1 | awk '{print $1}')
echo "  ℹ Total word count: $TOTAL_WORDS words"

# Summary
echo ""
echo "════════════════════════════════════════════════════════════════"
echo "VALIDATION SUMMARY"
echo "════════════════════════════════════════════════════════════════"
echo "  Errors:   $ERRORS"
echo "  Warnings: $WARNINGS"
echo ""

if [ $ERRORS -eq 0 ]; then
    if [ $WARNINGS -eq 0 ]; then
        echo "✓ ALL CHECKS PASSED — Ready for 10/10!"
    else
        echo "✓ No critical errors — $WARNINGS minor warnings"
    fi
    exit 0
else
    echo "✗ $ERRORS ERRORS found — Fix before deployment"
    exit 1
fi
