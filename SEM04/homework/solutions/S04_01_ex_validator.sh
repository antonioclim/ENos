#!/bin/bash
# ============================================================================
# ex1_validator.sh - Model Solution
# Data validation and extraction (email, IP, phone)
# 
# Author: [Instructor]
# Version: 1.0
# ============================================================================
set -euo pipefail

# Colours for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# ============================================================================
# Argument verification
# ============================================================================
if [[ $# -lt 1 ]]; then
    echo -e "${RED}Usage: $0 <file>${NC}"
    echo "Example: $0 contacts.txt"
    exit 1
fi

INPUT_FILE="$1"

if [[ ! -f "$INPUT_FILE" ]]; then
    echo -e "${RED}Error: File '$INPUT_FILE' does not exist!${NC}"
    exit 1
fi

# ============================================================================
# Function: Email Validation
# Pattern accepts: user@domain.tld
# ============================================================================
validate_emails() {
    echo -e "${BLUE}=== EMAIL VALIDATION ===${NC}"
    echo ""
    
    # Pattern for email extraction (permissive)
    local extract_pattern='[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}'
    
    # Strict pattern for validation
    local valid_pattern='^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    
    # Extract all emails
    local all_emails
    all_emails=$(grep -oE "$extract_pattern" "$INPUT_FILE" | sort -u)
    
    local total=0
    local valid_count=0
    local invalid_count=0
    local valid_list=""
    local invalid_list=""
    
    while IFS= read -r email; do
        [[ -z "$email" ]] && continue
        ((total++))
        
        # Additional validation: does not start/end with dot, no consecutive dots
        if [[ "$email" =~ $valid_pattern ]] && \
           [[ ! "$email" =~ ^\\. ]] && \
           [[ ! "$email" =~ \\.@ ]] && \
           [[ ! "$email" =~ \\.\\. ]]; then
            ((valid_count++))
            valid_list+="  - $email"$'\n'
        else
            ((invalid_count++))
            invalid_list+="  - $email"$'\n'
        fi
    done <<< "$all_emails"
    
    echo -e "Total found: ${YELLOW}$total${NC}"
    echo -e "${GREEN}✅ Valid: $valid_count${NC}"
    if [[ -n "$valid_list" ]]; then
        echo -e "$valid_list"
    fi
    
    if [[ $invalid_count -gt 0 ]]; then
        echo -e "${RED}❌ Invalid: $invalid_count${NC}"
        echo -e "$invalid_list"
    fi
    
    echo ""
}

# ============================================================================
# Function: IP Extraction
# Strict validation: each octet 0-255
# ============================================================================
extract_ips() {
    echo -e "${BLUE}=== UNIQUE IP ADDRESSES ===${NC}"
    echo ""
    
    # Permissive pattern for extraction
    local extract_pattern='[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'
    
    # Extract and validate
    grep -oE "$extract_pattern" "$INPUT_FILE" 2>/dev/null | while read -r ip; do
        # Strict validation: each octet between 0-255
        IFS='.' read -ra octets <<< "$ip"
        local valid=true
        for octet in "${octets[@]}"; do
            if [[ $octet -lt 0 || $octet -gt 255 ]]; then
                valid=false
                break
            fi
        done
        if $valid; then
            echo "$ip"
        fi
    done | sort -t. -k1,1n -k2,2n -k3,3n -k4,4n -u
    
    echo ""
}

# ============================================================================
# Function: RO Phone Number Extraction
# Accepted formats: 07XX-XXX-XXX, 07XX.XXX.XXX, 07XX XXX XXX, 07XXXXXXXX
# ============================================================================
extract_phones() {
    echo -e "${BLUE}=== RO PHONE NUMBERS ===${NC}"
    echo ""
    
    # Pattern for Romanian mobile phones
    # Accepts: 07XX-XXX-XXX, 07XX.XXX.XXX, 07XX XXX XXX, 07XXXXXXXX
    # And variants with +40
    local patterns=(
        '\+40[-. ]?7[0-9]{2}[-. ]?[0-9]{3}[-. ]?[0-9]{3}'
        '07[2-9][0-9][-. ]?[0-9]{3}[-. ]?[0-9]{3}'
    )
    
    for pattern in "${patterns[@]}"; do
        grep -oE "$pattern" "$INPUT_FILE" 2>/dev/null
    done | sort -u
    
    echo ""
}

# ============================================================================
# Main
# ============================================================================
echo ""
echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║         DATA VALIDATOR - $INPUT_FILE${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

validate_emails
extract_ips
extract_phones

echo -e "${GREEN}✅ Validation complete!${NC}"
