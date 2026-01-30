#!/bin/bash
#===============================================================================
# NAME:        project_validator.sh
# DESCRIPTION: Validates the structure and quality of an OS project submission
# AUTHOR:      OS Kit - ASE CSIE
# VERSION:     1.1.0
#
# USAGE:       ./project_validator.sh <project_directory>
#
# EXIT CODES:
#   0 - All validations passed
#   1 - One or more validations failed
#
# CHECKS PERFORMED:
#   1. Directory structure (src/, tests/, docs/)
#   2. Mandatory files (README.md, Makefile)
#   3. Bash syntax validation (bash -n)
#   4. ShellCheck analysis (if available)
#   5. Executable permissions on main script
#   6. README.md content quality
#
# DEPENDENCIES:
#   - bash 4.0+
#   - shellcheck (optional, for enhanced linting)
#
# EXAMPLES:
#   ./project_validator.sh ./my_project
#   ./project_validator.sh ~/submissions/PopescuIon_E01
#===============================================================================

set -euo pipefail

# shellcheck disable=SC2034  # Unused variables are intentional (colours)

# Colours for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly NC='\033[0m'

# Counters
PASS=0
FAIL=0
WARN=0

pass() { echo -e "${GREEN}✓ PASS:${NC} $1"; ((PASS++)); }
fail() { echo -e "${RED}✗ FAIL:${NC} $1"; ((FAIL++)); }
warn() { echo -e "${YELLOW}⚠ WARN:${NC} $1"; ((WARN++)); }

usage() {
    cat << EOF
Usage: $(basename "$0") <project_directory>

Validates the structure and quality of an OS project.

Checks performed:
  - Directory structure
  - Presence of mandatory files
  - Bash script syntax
  - ShellCheck (if available)
  - Executable permissions
  - README content

Examples:
  $(basename "$0") ./my_project
  $(basename "$0") ~/student_submission
EOF
}

check_structure() {
    echo "═══ Structure Validation ═══"
    
    [[ -d "$1/src" ]] && pass "Directory src/ exists" || fail "Missing src/"
    [[ -f "$1/README.md" ]] && pass "README.md exists" || fail "Missing README.md"
    [[ -f "$1/Makefile" ]] && pass "Makefile exists" || warn "Missing Makefile (recommended)"
    [[ -d "$1/tests" ]] && pass "Directory tests/ exists" || warn "Missing tests/"
    [[ -d "$1/docs" ]] && pass "Directory docs/ exists" || warn "Missing docs/"
}

check_scripts() {
    echo ""
    echo "═══ Bash Scripts Validation ═══"
    
    local scripts
    scripts=$(find "$1" -name "*.sh" -type f 2>/dev/null)
    
    if [[ -z "$scripts" ]]; then
        warn "No .sh scripts found"
        return
    fi
    
    while IFS= read -r script; do
        local name
        name=$(basename "$script")
        
        # Check shebang
        if head -1 "$script" | grep -q '^#!/.*bash'; then
            pass "$name: correct shebang"
        else
            fail "$name: missing or incorrect shebang"
        fi
        
        # Check syntax
        if bash -n "$script" 2>/dev/null; then
            pass "$name: valid syntax"
        else
            fail "$name: syntax errors"
        fi
        
        # ShellCheck
        if command -v shellcheck &>/dev/null; then
            if shellcheck -x "$script" &>/dev/null; then
                pass "$name: ShellCheck OK"
            else
                warn "$name: ShellCheck warnings"
            fi
        fi
    done <<< "$scripts"
}

check_readme() {
    echo ""
    echo "═══ README.md Validation ═══"
    
    local readme="$1/README.md"
    [[ ! -f "$readme" ]] && return
    
    local lines
    lines=$(wc -l < "$readme")
    
    if [[ $lines -gt 50 ]]; then
        pass "README sufficiently detailed ($lines lines)"
    elif [[ $lines -gt 20 ]]; then
        warn "README is short ($lines lines)"
    else
        fail "README too short ($lines lines)"
    fi
    
    # Check for common sections
    if grep -qi "install" "$readme"; then
        pass "Installation section found"
    else
        warn "Missing installation section — add '## Installation' to README.md"
    fi
    
    if grep -qi "usage" "$readme"; then
        pass "Usage section found"
    else
        warn "Missing usage section — add '## Usage' to README.md"
    fi
    
    if grep -qi "example" "$readme"; then
        pass "Examples present"
    else
        warn "Missing examples — add usage examples to README.md"
    fi
}

check_permissions() {
    echo ""
    echo "═══ Permissions Validation ═══"
    
    local main_script
    main_script=$(find "$1/src" -maxdepth 1 -name "*.sh" -type f 2>/dev/null | head -1)
    
    if [[ -n "$main_script" ]]; then
        if [[ -x "$main_script" ]]; then
            pass "Main script is executable"
        else
            warn "Main script is not executable — run: chmod +x $main_script"
        fi
    fi
}

print_summary() {
    echo ""
    echo "═══════════════════════════════════════"
    echo "VALIDATION SUMMARY"
    echo "═══════════════════════════════════════"
    echo -e "  ${GREEN}Passed:${NC}  $PASS"
    echo -e "  ${RED}Failed:${NC}  $FAIL"
    echo -e "  ${YELLOW}Warnings:${NC} $WARN"
    echo "═══════════════════════════════════════"
    
    if [[ $FAIL -eq 0 ]]; then
        echo -e "${GREEN}Project valid for submission!${NC}"
        return 0
    else
        echo -e "${RED}Project has issues that need to be resolved.${NC}"
        return 1
    fi
}

# Main
[[ $# -lt 1 ]] && { usage; exit 1; }
[[ ! -d "$1" ]] && { echo "Error: '$1' is not a directory"; exit 1; }

PROJECT_DIR="$(cd "$1" && pwd)"

echo "╔══════════════════════════════════════════════╗"
echo "║     PROJECT VALIDATOR - OS ASE CSIE          ║"
echo "╚══════════════════════════════════════════════╝"
echo ""
echo "Validating: $PROJECT_DIR"
echo ""

check_structure "$PROJECT_DIR"
check_scripts "$PROJECT_DIR"
check_readme "$PROJECT_DIR"
check_permissions "$PROJECT_DIR"
print_summary
