#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════════
# run_moss.sh - MOSS Plagiarism Detection Runner
# ═══════════════════════════════════════════════════════════════════════════════
# Operating Systems | ASE Bucharest - CSIE
#
# Purpose: Automate MOSS plagiarism detection for seminar submissions
# Usage:   ./run_moss.sh <SEMINAR> [LANGUAGE] [EXTENSION]
#
# Examples:
#   ./run_moss.sh SEM03              # Bash scripts
#   ./run_moss.sh SEM05 python py    # Python scripts
#   ./run_moss.sh SEM04 bash sh      # Bash scripts explicitly
# ═══════════════════════════════════════════════════════════════════════════════

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MOSS_SCRIPT="${SCRIPT_DIR}/moss.pl"

# Colours
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Functions
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
    echo -e "${RED}[ERROR]${NC} $*" >&2
}

usage() {
    cat << EOF
Usage: $(basename "$0") <SEMINAR> [LANGUAGE] [EXTENSION]

Arguments:
    SEMINAR     Seminar directory (e.g., SEM03, SEM05)
    LANGUAGE    MOSS language (default: bash)
                Options: bash, python, java, c, cpp, perl
    EXTENSION   File extension without dot (default: sh)

Examples:
    $(basename "$0") SEM03                  # Bash scripts (.sh)
    $(basename "$0") SEM05 python py        # Python scripts (.py)
    $(basename "$0") SEM04 bash sh          # Bash scripts (.sh)

Prerequisites:
    - MOSS script (moss.pl) must be present in this directory
    - Request access at: moss@moss.stanford.edu
EOF
    exit 1
}

# Parse arguments
SEMINAR="${1:-}"
LANGUAGE="${2:-bash}"
EXTENSION="${3:-sh}"

if [[ -z "$SEMINAR" ]]; then
    log_error "Seminar not specified"
    usage
fi

# Validate MOSS script
if [[ ! -f "$MOSS_SCRIPT" ]]; then
    log_error "MOSS script not found: $MOSS_SCRIPT"
    echo ""
    echo "To obtain MOSS access:"
    echo "  1. Send email to moss@moss.stanford.edu"
    echo "  2. Subject: New MOSS Account Request"
    echo "  3. Include: name, institution, purpose"
    echo "  4. Save received script as: $MOSS_SCRIPT"
    echo "  5. Run: chmod +x $MOSS_SCRIPT"
    exit 1
fi

# Find submission directory
KIT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SUBMISSIONS_DIR="$KIT_ROOT/$SEMINAR/submissions"

if [[ ! -d "$SUBMISSIONS_DIR" ]]; then
    # Try alternative structure
    SUBMISSIONS_DIR="$KIT_ROOT/$SEMINAR/homework/submissions"
fi

if [[ ! -d "$SUBMISSIONS_DIR" ]]; then
    log_error "Submissions directory not found for $SEMINAR"
    log_info "Expected: $KIT_ROOT/$SEMINAR/submissions/"
    log_info "Or: $KIT_ROOT/$SEMINAR/homework/submissions/"
    exit 1
fi

# Find base/starter code
STARTER_DIR=""
for candidate in "$KIT_ROOT/$SEMINAR/homework/starter" \
                 "$KIT_ROOT/$SEMINAR/starter" \
                 "$KIT_ROOT/$SEMINAR/homework/solutions"; do
    if [[ -d "$candidate" ]]; then
        STARTER_DIR="$candidate"
        break
    fi
done

echo "═══════════════════════════════════════════════════════════════"
echo "  MOSS PLAGIARISM DETECTION"
echo "═══════════════════════════════════════════════════════════════"
echo ""
log_info "Seminar:     $SEMINAR"
log_info "Language:    $LANGUAGE"
log_info "Extension:   .$EXTENSION"
log_info "Submissions: $SUBMISSIONS_DIR"
if [[ -n "$STARTER_DIR" ]]; then
    log_info "Starter:     $STARTER_DIR (will be excluded)"
fi
echo ""

# Find all submissions
SUBMISSIONS=$(find "$SUBMISSIONS_DIR" -type f -name "*.$EXTENSION" 2>/dev/null)

if [[ -z "$SUBMISSIONS" ]]; then
    log_error "No .$EXTENSION files found in $SUBMISSIONS_DIR"
    exit 1
fi

SUBMISSION_COUNT=$(echo "$SUBMISSIONS" | wc -l)
log_info "Found $SUBMISSION_COUNT submission files"
echo ""

# Build MOSS command
MOSS_CMD=("$MOSS_SCRIPT" "-l" "$LANGUAGE" "-d")

# Add base files if available
if [[ -n "$STARTER_DIR" ]]; then
    BASE_FILES=$(find "$STARTER_DIR" -type f -name "*.$EXTENSION" 2>/dev/null || true)
    if [[ -n "$BASE_FILES" ]]; then
        while IFS= read -r base_file; do
            MOSS_CMD+=("-b" "$base_file")
        done <<< "$BASE_FILES"
        log_info "Excluding $(echo "$BASE_FILES" | wc -l) base file(s)"
    fi
fi

# Add submission files
while IFS= read -r submission; do
    MOSS_CMD+=("$submission")
done <<< "$SUBMISSIONS"

# Run MOSS
log_info "Running MOSS..."
echo ""

if "${MOSS_CMD[@]}"; then
    echo ""
    log_success "MOSS analysis complete"
    echo ""
    echo "═══════════════════════════════════════════════════════════════"
    echo "  Check the URL provided above for results"
    echo "  Note: MOSS URLs typically expire after 14 days"
    echo "═══════════════════════════════════════════════════════════════"
else
    log_error "MOSS analysis failed"
    exit 1
fi
