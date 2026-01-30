#!/bin/bash
#
# add_print_styles.sh — Inject print stylesheets into HTML presentations
#
# Operating Systems | ASE Bucharest — CSIE
# Author: ing. dr. Antonio Clim
# Version: 1.0 | January 2025
#
# Purpose: Add @media print CSS rules to all HTML presentations for offline handouts
# Usage: ./add_print_styles.sh [--dry-run]
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

# Colours
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

DRY_RUN=false

# Parse arguments
if [[ "${1:-}" == "--dry-run" ]]; then
    DRY_RUN=true
    echo -e "${YELLOW}[DRY RUN] No files will be modified${NC}"
fi

# The print styles to inject (minified for inline injection)
read -r -d '' PRINT_STYLES << 'EOFCSS' || true
/* === PRINT STYLES — ENos Kit v1.0 === */
@media print {
    * { -webkit-print-color-adjust: exact !important; print-color-adjust: exact !important; }
    html, body { background: white !important; color: black !important; font-size: 11pt !important; line-height: 1.4 !important; overflow: visible !important; height: auto !important; width: 100% !important; margin: 0 !important; padding: 0 !important; }
    .presentation, .slides, .reveal, .reveal .slides { height: auto !important; width: 100% !important; position: static !important; overflow: visible !important; transform: none !important; }
    .slide, section, .reveal section { display: block !important; position: static !important; visibility: visible !important; opacity: 1 !important; transform: none !important; page-break-after: always !important; page-break-inside: avoid !important; width: 100% !important; min-height: 200mm !important; padding: 15mm 12mm !important; margin: 0 0 5mm 0 !important; background: white !important; border: 1px solid #ccc !important; box-shadow: none !important; }
    .slide:last-child, section:last-child { page-break-after: auto !important; }
    .slide:not(.active), section.future, section.past { display: block !important; }
    h1, h2, h3, h4, h5, h6 { color: black !important; background: none !important; -webkit-background-clip: initial !important; background-clip: initial !important; -webkit-text-fill-color: black !important; text-shadow: none !important; page-break-after: avoid !important; }
    h1 { font-size: 18pt !important; } h2 { font-size: 14pt !important; } h3 { font-size: 12pt !important; }
    p, li, td, th { color: black !important; font-size: 10pt !important; }
    pre, code, .code-block, .hljs, [class*="language-"] { background: #f5f5f5 !important; color: black !important; border: 1px solid #ddd !important; font-family: 'Courier New', Courier, monospace !important; font-size: 9pt !important; white-space: pre-wrap !important; word-wrap: break-word !important; page-break-inside: avoid !important; }
    pre { padding: 8pt !important; margin: 6pt 0 !important; max-height: none !important; overflow: visible !important; }
    .hljs-keyword, .hljs-string, .hljs-number, .hljs-comment, .hljs-built_in, .hljs-function, .hljs-variable, .token { color: black !important; }
    table { border-collapse: collapse !important; width: 100% !important; font-size: 9pt !important; page-break-inside: avoid !important; }
    th, td { border: 1px solid #333 !important; padding: 4pt 6pt !important; }
    th { background: #e0e0e0 !important; font-weight: bold !important; }
    a { color: black !important; text-decoration: underline !important; }
    a[href^="http"]:after, a[href^="https"]:after { content: " (" attr(href) ")" !important; font-size: 8pt !important; color: #666 !important; }
    a[href^="#"]:after, a[href^="./"]:after, a[href^="../"]:after { content: "" !important; }
    img, svg { max-width: 100% !important; height: auto !important; page-break-inside: avoid !important; }
    video, audio, iframe { display: none !important; }
    .nav-controls, .controls, .progress, .progress-bar, .slide-number, .slide-menu-button, .playback, .navigate-left, .navigate-right, button, .copy-btn, .keyboard-hint, .notes, .speaker-notes, aside.notes { display: none !important; }
    .fragment { opacity: 1 !important; visibility: visible !important; }
    @page { size: A4 portrait; margin: 12mm 10mm 15mm 10mm; }
}
EOFCSS

# Statistics
UPDATED=0
SKIPPED=0
TOTAL=0

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "  Adding Print Styles to HTML Presentations"
echo "═══════════════════════════════════════════════════════════════"
echo ""

# Find all HTML presentations
while IFS= read -r -d '' file; do
    TOTAL=$((TOTAL + 1))
    filename=$(basename "$file")
    relpath="${file#$REPO_ROOT/}"
    
    # Check if already has print styles
    if grep -q "@media print" "$file" 2>/dev/null; then
        echo -e "${YELLOW}[SKIP]${NC} Already has print styles: $relpath"
        SKIPPED=$((SKIPPED + 1))
        continue
    fi
    
    if [[ "$DRY_RUN" == true ]]; then
        echo -e "${GREEN}[WOULD UPDATE]${NC} $relpath"
        UPDATED=$((UPDATED + 1))
    else
        # Insert print styles before closing </style> tag
        # Use a temp file for safety
        temp_file=$(mktemp)
        
        # Find the last </style> tag and insert before it
        if grep -q "</style>" "$file"; then
            # Insert the print styles before the last </style>
            awk -v styles="$PRINT_STYLES" '
                /<\/style>/ && !done {
                    print styles
                    done = 1
                }
                { print }
            ' "$file" > "$temp_file"
            
            mv "$temp_file" "$file"
            echo -e "${GREEN}[UPDATED]${NC} $relpath"
            UPDATED=$((UPDATED + 1))
        else
            echo -e "${RED}[ERROR]${NC} No </style> tag found: $relpath"
            rm -f "$temp_file"
        fi
    fi
done < <(find "$REPO_ROOT" -path "*/presentations/*.html" -type f -print0 2>/dev/null)

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "  Summary"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "  Total files found:  $TOTAL"
echo "  Updated:            $UPDATED"
echo "  Skipped (existing): $SKIPPED"
echo ""

if [[ "$DRY_RUN" == true ]]; then
    echo -e "${YELLOW}This was a dry run. Run without --dry-run to apply changes.${NC}"
fi
