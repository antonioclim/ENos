#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════════
# run_all_tests.sh — Runner for all Seminar 03 tests
# Operating Systems | Bucharest UES - CSIE
# ═══════════════════════════════════════════════════════════════════════════════
# Topic: find/xargs, getopts, Permissions, CRON
# Usage: bash teste/run_all_tests.sh
# ═══════════════════════════════════════════════════════════════════════════════

set -euo pipefail

# ─────────────────────────────────────────────────────────────────────────────
# CONFIGURATION
# ─────────────────────────────────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
TESTS_PASSED=0
TESTS_FAILED=0
TESTS_SKIPPED=0

# Colours (disabled if not terminal)
if [[ -t 1 ]]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[0;33m'
    BLUE='\033[0;34m'
    NC='\033[0m'
else
    RED=''
    GREEN=''
    YELLOW=''
    BLUE=''
    NC=''
fi

# ─────────────────────────────────────────────────────────────────────────────
# HELPER FUNCTIONS
# ─────────────────────────────────────────────────────────────────────────────

print_header() {
    echo -e "${BLUE}"
    echo "═══════════════════════════════════════════════════════════════"
    echo "        TESTS SEMINAR 03: System Administration"
    echo "═══════════════════════════════════════════════════════════════"
    echo -e "${NC}"
}

print_section() {
    echo ""
    echo -e "${YELLOW}─── $1 ───${NC}"
}

print_summary() {
    echo ""
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo "                         SUMMARY"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "  ${GREEN}✓ Passed:${NC}  $TESTS_PASSED"
    echo -e "  ${RED}✗ Failed:${NC}  $TESTS_FAILED"
    echo -e "  ${YELLOW}○ Skipped:${NC} $TESTS_SKIPPED"
    echo ""
    
    local total=$((TESTS_PASSED + TESTS_FAILED))
    if [[ $total -gt 0 ]]; then
        local percentage=$((TESTS_PASSED * 100 / total))
        echo "  Score: $percentage% ($TESTS_PASSED/$total)"
    fi
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
}

run_test() {
    local test_name="$1"
    local test_cmd="$2"
    
    printf "  %-45s " "$test_name"
    
    if eval "$test_cmd" >/dev/null 2>&1; then
        echo -e "${GREEN}[PASS]${NC}"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "${RED}[FAIL]${NC}"
        ((TESTS_FAILED++))
        return 1
    fi
}

skip_test() {
    local test_name="$1"
    local reason="$2"
    
    printf "  %-45s " "$test_name"
    echo -e "${YELLOW}[SKIP]${NC} - $reason"
    ((TESTS_SKIPPED++))
}

# ─────────────────────────────────────────────────────────────────────────────
# TESTS: FILE STRUCTURE
# ─────────────────────────────────────────────────────────────────────────────

test_structure() {
    print_section "File Structure"
    
    # Mandatory root files
    run_test "README.md exists" "[[ -f '$PROJECT_ROOT/README.md' ]]"
    run_test "Makefile exists" "[[ -f '$PROJECT_ROOT/Makefile' ]]"
    run_test "requirements.txt exists" "[[ -f '$PROJECT_ROOT/requirements.txt' ]]"
    
    # Mandatory directories
    run_test "docs/ directory exists" "[[ -d '$PROJECT_ROOT/docs' ]]"
    run_test "scripts/bash/ exists" "[[ -d '$PROJECT_ROOT/scripts/bash' ]]"
    run_test "scripts/python/ exists" "[[ -d '$PROJECT_ROOT/scripts/python' ]]"
    run_test "formative/ directory exists" "[[ -d '$PROJECT_ROOT/formative' ]]"
    run_test "ci/ directory exists" "[[ -d '$PROJECT_ROOT/ci' ]]"
    
    # Formative files
    run_test "formative/quiz.yaml exists" "[[ -f '$PROJECT_ROOT/formative/quiz.yaml' ]]"
    run_test "formative/quiz_lms.json exists" "[[ -f '$PROJECT_ROOT/formative/quiz_lms.json' ]]"
}

# ─────────────────────────────────────────────────────────────────────────────
# TESTS: BASH SYNTAX
# ─────────────────────────────────────────────────────────────────────────────

test_bash_syntax() {
    print_section "Bash Syntax"
    
    local bash_files=(
        "scripts/bash/S03_01_setup_seminar.sh"
        "scripts/bash/S03_02_quiz_interactiv.sh"
        "scripts/bash/S03_03_validator.sh"
        "scripts/demo/S03_01_hook_demo.sh"
        "scripts/demo/S03_02_demo_find_xargs.sh"
        "scripts/demo/S03_03_demo_getopts.sh"
        "scripts/demo/S03_04_demo_permissions.sh"
        "scripts/demo/S03_05_demo_cron.sh"
    )
    
    for file in "${bash_files[@]}"; do
        local full_path="$PROJECT_ROOT/$file"
        local name=$(basename "$file")
        
        if [[ -f "$full_path" ]]; then
            run_test "Syntax: $name" "bash -n '$full_path'"
        else
            skip_test "Syntax: $name" "File not found"
        fi
    done
}

# ─────────────────────────────────────────────────────────────────────────────
# TESTS: PYTHON SYNTAX
# ─────────────────────────────────────────────────────────────────────────────

test_python_syntax() {
    print_section "Python Syntax"
    
    local python_files=(
        "scripts/python/S03_01_autograder.py"
        "scripts/python/S03_02_quiz_generator.py"
        "scripts/python/S03_03_report_generator.py"
    )
    
    for file in "${python_files[@]}"; do
        local full_path="$PROJECT_ROOT/$file"
        local name=$(basename "$file")
        
        if [[ -f "$full_path" ]]; then
            run_test "Syntax: $name" "python3 -m py_compile '$full_path'"
        else
            skip_test "Syntax: $name" "File not found"
        fi
    done
}

# ─────────────────────────────────────────────────────────────────────────────
# TESTS: YAML/JSON VALIDATION
# ─────────────────────────────────────────────────────────────────────────────

test_data_files() {
    print_section "Data Validation (YAML/JSON)"
    
    # Quiz YAML
    if [[ -f "$PROJECT_ROOT/formative/quiz.yaml" ]]; then
        run_test "quiz.yaml is valid YAML" \
            "python3 -c \"import yaml; yaml.safe_load(open('$PROJECT_ROOT/formative/quiz.yaml'))\""
        
        run_test "quiz.yaml has questions" \
            "python3 -c \"import yaml; q=yaml.safe_load(open('$PROJECT_ROOT/formative/quiz.yaml')); assert 'questions' in q and len(q['questions']) > 0\""
    else
        skip_test "quiz.yaml validation" "File not found"
    fi
    
    # Quiz JSON
    if [[ -f "$PROJECT_ROOT/formative/quiz_lms.json" ]]; then
        run_test "quiz_lms.json is valid JSON" \
            "python3 -m json.tool '$PROJECT_ROOT/formative/quiz_lms.json' > /dev/null"
        
        run_test "quiz_lms.json has questions" \
            "python3 -c \"import json; q=json.load(open('$PROJECT_ROOT/formative/quiz_lms.json')); assert 'questions' in q and len(q['questions']) > 0\""
    else
        skip_test "quiz_lms.json validation" "File not found"
    fi
}

# ─────────────────────────────────────────────────────────────────────────────
# TESTS: NAMING CONSISTENCY
# ─────────────────────────────────────────────────────────────────────────────

test_naming_consistency() {
    print_section "Naming Consistency"
    
    # Verify absence of incorrect references to "Seminar 3"
    run_test "No 'Seminar 3' references in docs/" \
        "[[ \$(grep -rE 'Seminar 3|sem56|SEM05-06' '$PROJECT_ROOT/docs/' 2>/dev/null | wc -l) -eq 0 ]]"
    
    run_test "No 'Seminar 3' references in README" \
        "[[ \$(grep -E 'Seminar 3|sem56|SEM05-06' '$PROJECT_ROOT/README.md' 2>/dev/null | wc -l) -eq 0 ]]"
    
    # Verify absence of contact emails
    run_test "No contact emails (use GitHub Issues)" \
        "[[ \$(grep -rE 'support@example|admin@example' '$PROJECT_ROOT/docs/' 2>/dev/null | wc -l) -eq 0 ]]"
}

# ─────────────────────────────────────────────────────────────────────────────
# TESTS: CODE QUALITY
# ─────────────────────────────────────────────────────────────────────────────

test_code_quality() {
    print_section "Code Quality"
    
    # Verify shebang in bash scripts
    for f in "$PROJECT_ROOT"/scripts/bash/*.sh "$PROJECT_ROOT"/scripts/demo/*.sh; do
        if [[ -f "$f" ]]; then
            local name=$(basename "$f")
            run_test "Shebang in $name" "head -1 '$f' | grep -q '^#!/bin/bash'"
        fi
    done
    
    # Verify set -euo pipefail in main scripts
    local main_scripts=(
        "scripts/bash/S03_01_setup_seminar.sh"
        "scripts/bash/S03_03_validator.sh"
    )
    
    for script in "${main_scripts[@]}"; do
        local full_path="$PROJECT_ROOT/$script"
        if [[ -f "$full_path" ]]; then
            local name=$(basename "$script")
            run_test "Strict mode in $name" "grep -q 'set -euo pipefail\\|set -e' '$full_path'"
        fi
    done
}

# ─────────────────────────────────────────────────────────────────────────────
# TESTS: AI PATTERNS
# ─────────────────────────────────────────────────────────────────────────────

test_ai_patterns() {
    print_section "AI Patterns Verification"
    
    # Common AI signal words
    local ai_pattern="delve|leverage|comprehensive|seamless|cutting-edge|foster|cultivate|harness|pivotal|paramount"
    
    local ai_count
    ai_count=$(grep -riE "$ai_pattern" "$PROJECT_ROOT/docs/" 2>/dev/null | wc -l || echo "0")
    
    run_test "Low AI word count in docs/ (<5)" "[[ $ai_count -lt 5 ]]"
    
    # Verify absence of "Happy scripting!"
    run_test "No 'Happy scripting!' endings" \
        "[[ \$(grep -ri 'happy scripting\\|scripting fericit' '$PROJECT_ROOT/' 2>/dev/null | wc -l) -eq 0 ]]"
}

# ─────────────────────────────────────────────────────────────────────────────
# MAIN
# ─────────────────────────────────────────────────────────────────────────────

main() {
    print_header
    
    echo "Project root: $PROJECT_ROOT"
    echo "Tests dir: $SCRIPT_DIR"
    
    # Run all test categories
    test_structure
    test_bash_syntax
    test_python_syntax
    test_data_files
    test_naming_consistency
    test_code_quality
    test_ai_patterns
    
    print_summary
    
    # Exit code based on failed tests
    if [[ $TESTS_FAILED -gt 0 ]]; then
        exit 1
    fi
    exit 0
}

main "$@"
