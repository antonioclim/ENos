#!/bin/bash
#
# check_links.sh — Verify documentation links across ENos Educational Kit
#
# Operating Systems | ASE Bucharest — CSIE
# Author: ing. dr. Antonio Clim
# Version: 1.0 | January 2025
#
# Purpose: Validate internal and external links in documentation files
# Usage:
#   ./check_links.sh              # Check internal links only (fast)
#   ./check_links.sh --external   # Check all links including external (slow)
#   ./check_links.sh --help       # Show usage information
#
# Exit codes:
#   0 - All checked links are valid
#   1 - Broken links detected
#   2 - Missing dependencies
#

set -euo pipefail

# ═══════════════════════════════════════════════════════════════════════════════
# CONFIGURATION
# ═══════════════════════════════════════════════════════════════════════════════

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

# Default settings
CHECK_EXTERNAL=false
VERBOSE=false
OUTPUT_FORMAT="console"  # console, json, markdown

# File extensions to check
EXTENSIONS=("md" "rst" "txt")

# Directories to skip
SKIP_DIRS=("OLD_HW" "solutions" ".git" "node_modules" "__pycache__" "venv")

# Patterns to exclude from external checks
EXCLUDE_PATTERNS=(
    "localhost"
    "127.0.0.1"
    "example.com"
    "example.org"
    "placeholder"
    "your-domain"
)

# ═══════════════════════════════════════════════════════════════════════════════
# COLOUR DEFINITIONS
# ═══════════════════════════════════════════════════════════════════════════════

if [[ -t 1 ]]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    CYAN='\033[0;36m'
    BOLD='\033[1m'
    NC='\033[0m'
else
    RED=''
    GREEN=''
    YELLOW=''
    BLUE=''
    CYAN=''
    BOLD=''
    NC=''
fi

# ═══════════════════════════════════════════════════════════════════════════════
# LOGGING FUNCTIONS
# ═══════════════════════════════════════════════════════════════════════════════

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_debug() {
    if [[ "$VERBOSE" == true ]]; then
        echo -e "${CYAN}[DEBUG]${NC} $1"
    fi
}

log_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

log_failure() {
    echo -e "${RED}[✗]${NC} $1"
}

# ═══════════════════════════════════════════════════════════════════════════════
# USAGE
# ═══════════════════════════════════════════════════════════════════════════════

show_usage() {
    cat << EOF
${BOLD}check_links.sh${NC} — Documentation Link Validator

${BOLD}USAGE:${NC}
    ./check_links.sh [OPTIONS]

${BOLD}OPTIONS:${NC}
    --external, -e    Also check external URLs (slower)
    --verbose, -v     Show detailed output
    --json            Output results as JSON
    --markdown        Output results as Markdown
    --help, -h        Show this help message

${BOLD}EXAMPLES:${NC}
    # Quick internal link check
    ./check_links.sh

    # Full check including external URLs
    ./check_links.sh --external

    # Verbose output with JSON format
    ./check_links.sh --verbose --json

${BOLD}REQUIREMENTS:${NC}
    For best results, install lychee:
        cargo install lychee
    or:
        brew install lychee

    Fallback uses grep + curl (slower, less accurate).

${BOLD}EXIT CODES:${NC}
    0 - All links valid
    1 - Broken links found
    2 - Missing dependencies

EOF
}

# ═══════════════════════════════════════════════════════════════════════════════
# DEPENDENCY CHECKS
# ═══════════════════════════════════════════════════════════════════════════════

check_lychee() {
    if command -v lychee &>/dev/null; then
        return 0
    else
        return 1
    fi
}

check_basic_deps() {
    local missing=()
    
    for cmd in grep find curl; do
        if ! command -v "$cmd" &>/dev/null; then
            missing+=("$cmd")
        fi
    done
    
    if [[ ${#missing[@]} -gt 0 ]]; then
        log_error "Missing required commands: ${missing[*]}"
        exit 2
    fi
}

# ═══════════════════════════════════════════════════════════════════════════════
# LINK EXTRACTION
# ═══════════════════════════════════════════════════════════════════════════════

extract_markdown_links() {
    local file="$1"
    
    # Extract [text](url) style links
    grep -oP '\[([^\]]*)\]\(([^)]+)\)' "$file" 2>/dev/null | \
        grep -oP '\(([^)]+)\)' | \
        tr -d '()' | \
        grep -v '^#' || true  # Exclude anchor-only links
    
    # Extract bare URLs
    grep -oP 'https?://[^\s<>\)\]"]+' "$file" 2>/dev/null || true
}

extract_internal_links() {
    local file="$1"
    local file_dir
    file_dir="$(dirname "$file")"
    
    # Get relative links (not starting with http)
    grep -oP '\[([^\]]*)\]\(([^)]+)\)' "$file" 2>/dev/null | \
        grep -oP '\(([^)]+)\)' | \
        tr -d '()' | \
        grep -v '^http' | \
        grep -v '^#' | \
        while read -r link; do
            # Remove anchor part
            link="${link%%#*}"
            if [[ -n "$link" ]]; then
                echo "$file_dir/$link"
            fi
        done || true
}

# ═══════════════════════════════════════════════════════════════════════════════
# LINK CHECKING — LYCHEE
# ═══════════════════════════════════════════════════════════════════════════════

check_with_lychee() {
    local mode="$1"
    local errors=0
    
    log_info "Using lychee for link checking (recommended)"
    
    # Build exclude path arguments
    local exclude_args=()
    for dir in "${SKIP_DIRS[@]}"; do
        exclude_args+=(--exclude-path "$dir")
    done
    
    # Build exclude pattern arguments for external
    local pattern_args=()
    for pattern in "${EXCLUDE_PATTERNS[@]}"; do
        pattern_args+=(--exclude "$pattern")
    done
    
    if [[ "$mode" == "internal" ]]; then
        log_info "Checking internal links only..."
        
        # Find all documentation files
        for sem in SEM01 SEM02 SEM03 SEM04 SEM05 SEM06 SEM07; do
            if [[ -d "$REPO_ROOT/$sem" ]]; then
                log_debug "  Scanning $sem/..."
                if ! lychee --no-progress --offline \
                    --include-fragments \
                    "${exclude_args[@]}" \
                    "$REPO_ROOT/$sem"/**/*.md 2>/dev/null; then
                    errors=$((errors + 1))
                fi
            fi
        done
        
        # Check root-level files
        log_debug "  Scanning root documents..."
        for doc in README.md NAVIGATION.md LICENCE_EN.md CHANGELOG.md; do
            if [[ -f "$REPO_ROOT/$doc" ]]; then
                lychee --no-progress --offline \
                    --include-fragments \
                    "$REPO_ROOT/$doc" 2>/dev/null || errors=$((errors + 1))
            fi
        done
        
        # Check support directories
        for dir in 00_SUPPLEMENTARY 01_INIT_SETUP 02_INIT_HOMEWORKS 03_GUIDES 04_PROJECTS 05_LECTURES; do
            if [[ -d "$REPO_ROOT/$dir" ]]; then
                log_debug "  Scanning $dir/..."
                lychee --no-progress --offline \
                    --include-fragments \
                    "${exclude_args[@]}" \
                    "$REPO_ROOT/$dir"/**/*.md 2>/dev/null || errors=$((errors + 1))
            fi
        done
        
    else
        log_info "Checking all links including external URLs..."
        log_warn "This may take several minutes..."
        
        lychee --no-progress \
            "${exclude_args[@]}" \
            "${pattern_args[@]}" \
            --timeout 30 \
            --max-retries 2 \
            --max-concurrency 8 \
            "$REPO_ROOT"/**/*.md 2>&1 | tee /tmp/external_links.log
        
        local broken
        broken=$(grep -c "✗" /tmp/external_links.log 2>/dev/null || echo "0")
        
        if [[ "$broken" -gt 0 ]]; then
            log_warn "$broken external links may need review"
            log_info "Full report: /tmp/external_links.log"
            errors=$broken
        fi
    fi
    
    return $errors
}

# ═══════════════════════════════════════════════════════════════════════════════
# LINK CHECKING — FALLBACK (grep + test/curl)
# ═══════════════════════════════════════════════════════════════════════════════

check_with_fallback() {
    local mode="$1"
    local errors=0
    local checked=0
    
    log_info "Using fallback link checker (grep + test/curl)"
    log_warn "For better results, install lychee: cargo install lychee"
    
    # Build find exclusions
    local find_excludes=()
    for dir in "${SKIP_DIRS[@]}"; do
        find_excludes+=(-path "*/$dir/*" -prune -o)
    done
    
    # Find all markdown files
    while IFS= read -r -d '' file; do
        log_debug "Checking: $file"
        
        if [[ "$mode" == "internal" ]]; then
            # Check internal/relative links
            while IFS= read -r link; do
                [[ -z "$link" ]] && continue
                
                # Normalise path
                local resolved
                resolved="$(cd "$(dirname "$file")" && realpath -m "$link" 2>/dev/null || echo "")"
                
                if [[ -n "$resolved" && ! -e "$resolved" ]]; then
                    log_failure "Broken link in $file: $link"
                    errors=$((errors + 1))
                else
                    checked=$((checked + 1))
                fi
            done < <(extract_internal_links "$file")
        else
            # Check external URLs
            while IFS= read -r url; do
                [[ -z "$url" ]] && continue
                
                # Skip excluded patterns
                local skip=false
                for pattern in "${EXCLUDE_PATTERNS[@]}"; do
                    if [[ "$url" == *"$pattern"* ]]; then
                        skip=true
                        break
                    fi
                done
                [[ "$skip" == true ]] && continue
                
                # Check URL
                local http_code
                http_code=$(curl -s -o /dev/null -w "%{http_code}" \
                    --max-time 10 \
                    -L "$url" 2>/dev/null || echo "000")
                
                if [[ "$http_code" -ge 400 || "$http_code" == "000" ]]; then
                    log_failure "Broken URL ($http_code): $url in $file"
                    errors=$((errors + 1))
                else
                    checked=$((checked + 1))
                fi
            done < <(extract_markdown_links "$file" | grep '^http')
        fi
    done < <(find "$REPO_ROOT" "${find_excludes[@]}" -name "*.md" -type f -print0)
    
    log_info "Checked $checked links"
    
    return $errors
}

# ═══════════════════════════════════════════════════════════════════════════════
# MAIN
# ═══════════════════════════════════════════════════════════════════════════════

main() {
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --external|-e)
                CHECK_EXTERNAL=true
                shift
                ;;
            --verbose|-v)
                VERBOSE=true
                shift
                ;;
            --json)
                OUTPUT_FORMAT="json"
                shift
                ;;
            --markdown)
                OUTPUT_FORMAT="markdown"
                shift
                ;;
            --help|-h)
                show_usage
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                show_usage
                exit 2
                ;;
        esac
    done
    
    # Check basic dependencies
    check_basic_deps
    
    # Change to repo root
    cd "$REPO_ROOT"
    
    echo ""
    echo -e "${BOLD}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}  ENos Documentation Link Checker${NC}"
    echo -e "${BOLD}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
    
    local mode="internal"
    [[ "$CHECK_EXTERNAL" == true ]] && mode="external"
    
    local result=0
    
    if check_lychee; then
        check_with_lychee "$mode" || result=$?
    else
        check_with_fallback "$mode" || result=$?
    fi
    
    echo ""
    echo -e "${BOLD}═══════════════════════════════════════════════════════════════${NC}"
    
    if [[ $result -eq 0 ]]; then
        log_success "All checked links are valid"
        echo ""
        exit 0
    else
        log_error "$result broken links detected"
        echo ""
        exit 1
    fi
}

# Run main
main "$@"
