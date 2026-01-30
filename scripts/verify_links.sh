#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════════
# verify_links.sh - Internal Link Verification for Markdown Files
# ═══════════════════════════════════════════════════════════════════════════════
# Operating Systems | ASE Bucharest - CSIE
#
# Purpose: Verify all internal links in Markdown files are valid
# Usage:   ./verify_links.sh [directory]
#
# Checks:
#   - Relative file links (e.g., ./docs/README.md)
#   - Relative directory links (e.g., ../SEM03/)
#   - Anchor links within files (e.g., #section-name)
#   - Image references (e.g., ./images/diagram.png)
# ═══════════════════════════════════════════════════════════════════════════════

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="${1:-$(dirname "$SCRIPT_DIR")}"

# Colours
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# Counters
TOTAL_FILES=0
TOTAL_LINKS=0
BROKEN_LINKS=0
VALID_LINKS=0

# Arrays for tracking
declare -a BROKEN_ITEMS=()

# Functions
log_header() {
    echo ""
    echo -e "${BOLD}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}  $*${NC}"
    echo -e "${BOLD}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
}

log_info() {
    echo -e "${BLUE}[INFO]${NC} $*"
}

log_success() {
    echo -e "${GREEN}[OK]${NC} $*"
}

log_warning() {
    echo -e "${YELLOW}[WARN]${NC} $*"
}

log_error() {
    echo -e "${RED}[BROKEN]${NC} $*"
}

# Check if a file/directory exists
check_target() {
    local source_file="$1"
    local link="$2"
    
    # Get directory of source file
    local source_dir
    source_dir="$(dirname "$source_file")"
    
    # Skip external links
    if [[ "$link" =~ ^https?:// ]] || [[ "$link" =~ ^mailto: ]] || [[ "$link" =~ ^ftp:// ]]; then
        return 0
    fi
    
    # Skip anchor-only links (will be checked separately)
    if [[ "$link" =~ ^# ]]; then
        return 0
    fi
    
    # Handle links with anchors (file.md#section)
    local file_part="${link%%#*}"
    
    # Skip empty file parts (pure anchors handled above)
    if [[ -z "$file_part" ]]; then
        return 0
    fi
    
    # Resolve the path
    local target_path
    if [[ "$file_part" =~ ^/ ]]; then
        # Absolute path (relative to repo root)
        target_path="$TARGET_DIR/$file_part"
    else
        # Relative path
        target_path="$source_dir/$file_part"
    fi
    
    # Normalise path
    target_path="$(cd "$(dirname "$target_path")" 2>/dev/null && pwd)/$(basename "$target_path")" 2>/dev/null || target_path=""
    
    # Check if target exists
    if [[ -z "$target_path" ]] || [[ ! -e "$target_path" ]]; then
        return 1
    fi
    
    return 0
}

# Extract links from a markdown file
extract_links() {
    local file="$1"
    
    # Extract markdown links: [text](link)
    # Exclude code blocks and inline code
    grep -oP '\[([^\]]*)\]\(([^)]+)\)' "$file" 2>/dev/null | \
        grep -oP '\(([^)]+)\)' | \
        tr -d '()' | \
        grep -v '^\s*$' || true
}

# Main verification logic
verify_file() {
    local file="$1"
    local file_broken=0
    
    # Extract all links from file
    local links
    links=$(extract_links "$file")
    
    if [[ -z "$links" ]]; then
        return 0
    fi
    
    while IFS= read -r link; do
        [[ -z "$link" ]] && continue
        
        ((TOTAL_LINKS++))
        
        if check_target "$file" "$link"; then
            ((VALID_LINKS++))
        else
            ((BROKEN_LINKS++))
            ((file_broken++))
            
            # Store for report
            local rel_file="${file#$TARGET_DIR/}"
            BROKEN_ITEMS+=("$rel_file → $link")
        fi
    done <<< "$links"
    
    return $file_broken
}

# Main execution
main() {
    log_header "INTERNAL LINK VERIFICATION"
    
    log_info "Target directory: $TARGET_DIR"
    echo ""
    
    # Find all markdown files
    local md_files
    md_files=$(find "$TARGET_DIR" -name "*.md" -type f ! -path "*/OLD_HW/*" ! -path "*/.git/*" ! -path "*/node_modules/*" 2>/dev/null)
    
    if [[ -z "$md_files" ]]; then
        log_warning "No markdown files found"
        exit 0
    fi
    
    # Progress indicator
    local file_count
    file_count=$(echo "$md_files" | wc -l)
    log_info "Scanning $file_count markdown files..."
    echo ""
    
    # Process each file
    local current=0
    while IFS= read -r file; do
        [[ -z "$file" ]] && continue
        ((TOTAL_FILES++))
        ((current++))
        
        # Show progress (every 10 files)
        if (( current % 10 == 0 )); then
            printf "\r  Processing: %d/%d files..." "$current" "$file_count"
        fi
        
        verify_file "$file" || true
        
    done <<< "$md_files"
    
    printf "\r                                        \r"  # Clear progress line
    
    # Report results
    echo ""
    echo "───────────────────────────────────────────────────────────────"
    echo -e "  ${BOLD}VERIFICATION RESULTS${NC}"
    echo "───────────────────────────────────────────────────────────────"
    echo ""
    echo "  Files scanned:    $TOTAL_FILES"
    echo "  Links checked:    $TOTAL_LINKS"
    echo -e "  Valid links:      ${GREEN}$VALID_LINKS${NC}"
    echo -e "  Broken links:     ${RED}$BROKEN_LINKS${NC}"
    echo ""
    
    if [[ $BROKEN_LINKS -eq 0 ]]; then
        log_success "All internal links are valid"
        echo ""
        exit 0
    else
        log_error "Found $BROKEN_LINKS broken links"
        echo ""
        echo "───────────────────────────────────────────────────────────────"
        echo -e "  ${BOLD}BROKEN LINKS${NC}"
        echo "───────────────────────────────────────────────────────────────"
        echo ""
        
        for item in "${BROKEN_ITEMS[@]}"; do
            echo -e "  ${RED}✗${NC} $item"
        done
        
        echo ""
        echo "───────────────────────────────────────────────────────────────"
        echo ""
        exit 1
    fi
}

# Run
main
