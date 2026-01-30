#!/bin/bash
#===============================================================================
#
#          FILE:  check_my_submission.sh
#
#         USAGE:  ./check_my_submission.sh <homework.cast>
#
#   DESCRIPTION:  Verify your homework submission before sending
#                 Checks: file existence, extension, size, signature, format
#
#        AUTHOR:  Operating Systems 2023-2027 - Revolvix/github.com
#       VERSION:  1.0.0
#       CREATED:  2025
#
#===============================================================================

set -euo pipefail

# Colours
readonly GREEN='\033[0;32m'
readonly RED='\033[0;31m'
readonly YELLOW='\033[1;33m'
readonly CYAN='\033[0;36m'
readonly BOLD='\033[1m'
readonly NC='\033[0m'

# Counters
ERRORS=0
WARNINGS=0

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
    ((ERRORS++)) || true
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
    ((WARNINGS++)) || true
}

print_info() {
    echo -e "${CYAN}ℹ${NC} $1"
}

# Check arguments
if [[ $# -ne 1 ]]; then
    echo -e "${RED}Usage: $0 <homework.cast>${NC}"
    echo ""
    echo "Example:"
    echo "  $0 1029_SMITH_John_HW03b.cast"
    exit 1
fi

CAST_FILE="$1"

echo ""
echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║              🔍 HOMEWORK SUBMISSION CHECKER                       ║${NC}"
echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Check 1: File exists
echo -e "${BOLD}Checking file...${NC}"
if [[ -f "$CAST_FILE" ]]; then
    print_success "File exists: $CAST_FILE"
else
    print_error "File not found: $CAST_FILE"
    echo ""
    echo -e "${RED}Cannot continue without the file. Please check the path.${NC}"
    exit 1
fi

# Check 2: File extension
if [[ "$CAST_FILE" == *.cast ]]; then
    print_success "Correct file extension (.cast)"
else
    print_error "Wrong file extension (should be .cast)"
fi

# Check 3: File size (should be > 1KB, typically > 5KB for real recordings)
# Use portable stat command
if [[ "$(uname)" == "Darwin" ]]; then
    SIZE=$(stat -f%z "$CAST_FILE" 2>/dev/null || echo "0")
else
    SIZE=$(stat -c%s "$CAST_FILE" 2>/dev/null || echo "0")
fi

if [[ $SIZE -gt 5120 ]]; then
    print_success "File size OK: $SIZE bytes ($(( SIZE / 1024 )) KB)"
elif [[ $SIZE -gt 1024 ]]; then
    print_warning "File size is small ($SIZE bytes) - recording may be very short"
else
    print_error "File too small ($SIZE bytes) - recording appears incomplete or corrupted"
fi

# Check 4: Signature present
echo ""
echo -e "${BOLD}Checking signature...${NC}"
if tail -5 "$CAST_FILE" 2>/dev/null | grep -q "^## "; then
    print_success "Cryptographic signature present"
    
    # Extract and show partial signature for verification
    SIG_LINE=$(tail -5 "$CAST_FILE" | grep "^## " | tail -1)
    SIG_PREVIEW="${SIG_LINE:0:50}..."
    print_info "Signature preview: $SIG_PREVIEW"
else
    print_error "Cryptographic signature MISSING - file may be corrupted or incomplete"
    echo ""
    echo -e "${YELLOW}   Did you stop the recording properly with STOP_homework or Ctrl+D?${NC}"
    echo -e "${YELLOW}   The signature is added AFTER the recording stops.${NC}"
fi

# Check 5: Valid JSON header (asciinema format)
echo ""
echo -e "${BOLD}Checking format...${NC}"
FIRST_LINE=$(head -1 "$CAST_FILE" 2>/dev/null || echo "")
if echo "$FIRST_LINE" | grep -q '"version"'; then
    print_success "Valid asciinema format detected"
    
    # Try to extract version
    if echo "$FIRST_LINE" | grep -q '"version": 2'; then
        print_info "Asciinema format version: 2 (current)"
    fi
else
    print_warning "Could not verify asciinema format - file may be corrupted"
fi

# Check 6: Filename format
echo ""
echo -e "${BOLD}Checking filename format...${NC}"
BASENAME=$(basename "$CAST_FILE")

# Expected format: GROUP_SURNAME_FirstName_HWxxl.cast
# GROUP: 4 digits
# SURNAME: uppercase letters and hyphen
# FirstName: Title case letters and hyphen  
# HW: literal
# xx: 01-07
# l: lowercase letter
if [[ "$BASENAME" =~ ^[0-9]{4}_[A-Z][A-Z-]*_[A-Z][a-zA-Z-]*_HW0[1-7][a-z]\.cast$ ]]; then
    print_success "Filename format correct: $BASENAME"
    
    # Parse components
    IFS='_' read -r F_GROUP F_SURNAME F_FIRSTNAME F_HW <<< "${BASENAME%.cast}"
    print_info "  Group: $F_GROUP"
    print_info "  Surname: $F_SURNAME"
    print_info "  First name: $F_FIRSTNAME"
    print_info "  Homework: $F_HW"
else
    print_warning "Filename may not follow standard format: $BASENAME"
    echo -e "     ${YELLOW}Expected: GROUP_SURNAME_FirstName_HWxxl.cast${NC}"
    echo -e "     ${YELLOW}Example:  1029_SMITH_John_HW03b.cast${NC}"
fi

# Check 7: File is not empty and has content
echo ""
echo -e "${BOLD}Checking content...${NC}"
LINE_COUNT=$(wc -l < "$CAST_FILE" 2>/dev/null || echo "0")
if [[ $LINE_COUNT -gt 10 ]]; then
    print_success "File has content: $LINE_COUNT lines"
else
    print_warning "File has very few lines ($LINE_COUNT) - recording may be too short"
fi

# Summary
echo ""
echo "═══════════════════════════════════════════════════════════════════"
echo ""

if [[ $ERRORS -eq 0 ]] && [[ $WARNINGS -eq 0 ]]; then
    echo -e "${GREEN}╔═══════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║         ✅ ALL CHECKS PASSED - READY TO SUBMIT!                   ║${NC}"
    echo -e "${GREEN}╚═══════════════════════════════════════════════════════════════════╝${NC}"
    exit 0
elif [[ $ERRORS -eq 0 ]]; then
    echo -e "${YELLOW}╔═══════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}║     ⚠ $WARNINGS WARNING(S) - Review before submitting               ║${NC}"
    echo -e "${YELLOW}╚═══════════════════════════════════════════════════════════════════╝${NC}"
    exit 0
else
    echo -e "${RED}╔═══════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║     ❌ $ERRORS ERROR(S) FOUND - Please fix before sending            ║${NC}"
    echo -e "${RED}╚═══════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${YELLOW}Common fixes:${NC}"
    echo "  • Missing signature: Re-record and stop properly with STOP_homework"
    echo "  • File too small: Recording stopped too early, re-record"
    echo "  • Wrong format: Ensure you used the official recording script"
    exit 1
fi
