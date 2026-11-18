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

pass() { echo -e "${GREEN}✓ PASS:${NC} $1"; PASS=$((PASS+1)); }
fail() { echo -e "${RED}✗ FAIL:${NC} $1"; FAIL=$((FAIL+1)); }
warn() { echo -e "${YELLOW}⚠ WARN:${NC} $1"; WARN=$((WARN+1)); }

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
    local plan script
    plan=$(mktemp) || return 1
    if ! find "$1" -name '*.sh' -type f -print0 > "$plan"; then
        rm -f -- "$plan"; fail "Cannot enumerate scripts"; return 0
    fi
    scripts=$(wc -c < "$plan")
    
    if [[ $scripts -eq 0 ]]; then
        fail "No Bash sources found"
        rm -f -- "$plan"
        return 0
    fi
    
    if ! command -v shellcheck >/dev/null 2>&1; then warn 'ShellCheck NOT_RUN (not installed)'; fi
    while IFS= read -r -d '' script; do
        local name
        name=$(basename "$script")
        
        # Check shebang
        local first_line
        IFS= read -r first_line < "$script" || true
        if [[ $first_line =~ ^\#\!(/bin/bash|/usr/bin/bash|/usr/bin/env[[:space:]]+bash)$ ]]; then
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
                fail "$name: ShellCheck reported issues"
            fi
        fi
    done < "$plan"
    rm -f -- "$plan"
    return 0
}

check_readme() {
    echo ""
    echo "═══ README.md Validation ═══"
    
    local readme="$1/README.md"
    [[ -f "$readme" ]] || return 0
    
    local lines
    lines=$(wc -l < "$readme")
    
    if [[ $lines -gt 50 ]]; then
        pass "README length heuristic ($lines lines; content quality not established)"
    elif [[ $lines -gt 20 ]]; then
        warn "README is short ($lines lines)"
    else
        warn "README is short ($lines lines); inspect whether required content is present"
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
    
    local script first_line found=0
    [[ -d "$1/src" ]] || return 0
    while IFS= read -r -d '' script; do
        found=$((found+1))
        if [[ -x "$script" ]]; then pass "Executable: $script"
        else warn "Not executable: $script (invoke with bash or explicitly set the intended entry-point mode)"; fi
    done < <(find "$1/src" -maxdepth 1 -name '*.sh' -type f -print0)
    if ((found==0)); then warn 'No src/*.sh entry point; check the project-specific layout'; fi
    return 0
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
        echo -e "${GREEN}Structural checks completed without failures; functional/assessment acceptance is not established.${NC}"
        return 0
    else
        echo -e "${RED}Project has issues that need to be resolved.${NC}"
        return 1
    fi
}

# Main
[[ ${1:-} != --help && ${1:-} != -h ]] || { usage; exit 0; }
[[ $# -eq 1 ]] || { usage >&2; exit 2; }
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
