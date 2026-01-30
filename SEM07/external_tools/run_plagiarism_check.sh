#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════════
# run_plagiarism_check.sh - Combined Plagiarism Detection Pipeline
# ═══════════════════════════════════════════════════════════════════════════════
# Operating Systems | ASE Bucharest - CSIE
#
# Purpose: Run all plagiarism detection tools and generate combined report
# Usage:   ./run_plagiarism_check.sh <SEMINAR>
#
# Pipeline:
#   1. Internal similarity checker (Python-based)
#   2. AI fingerprint scanner
#   3. Generate combined report with flagged submissions
# ═══════════════════════════════════════════════════════════════════════════════

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KIT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Colours
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# Thresholds
SIMILARITY_THRESHOLD=50      # Flag if similarity > 50%
AI_SCORE_THRESHOLD=7         # Flag if AI score < 7

# Functions
log_header() {
    echo ""
    echo -e "${BOLD}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}  $*${NC}"
    echo -e "${BOLD}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
}

log_step() {
    echo -e "${CYAN}[$1/3]${NC} $2"
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
    echo -e "${RED}[ERROR]${NC} $*" >&2
}

usage() {
    cat << EOF
Usage: $(basename "$0") <SEMINAR>

Arguments:
    SEMINAR     Seminar to check (e.g., SEM03, SEM05)

Examples:
    $(basename "$0") SEM03
    $(basename "$0") SEM05

This script runs:
    1. Internal similarity checker
    2. AI fingerprint scanner  
    3. Generates combined report

Output files:
    <SEMINAR>/similarity_report.json
    <SEMINAR>/ai_fingerprint_report.json
    <SEMINAR>/plagiarism_summary.txt
EOF
    exit 1
}

# Parse arguments
SEMINAR="${1:-}"

if [[ -z "$SEMINAR" ]]; then
    log_error "Seminar not specified"
    usage
fi

# Validate seminar directory
SEMINAR_DIR="$KIT_ROOT/$SEMINAR"
if [[ ! -d "$SEMINAR_DIR" ]]; then
    log_error "Seminar directory not found: $SEMINAR_DIR"
    exit 1
fi

# Find submissions
SUBMISSIONS_DIR=""
for candidate in "$SEMINAR_DIR/submissions" "$SEMINAR_DIR/homework/submissions"; do
    if [[ -d "$candidate" ]]; then
        SUBMISSIONS_DIR="$candidate"
        break
    fi
done

log_header "PLAGIARISM CHECK PIPELINE"
log_info "Seminar:     $SEMINAR"
log_info "Kit root:    $KIT_ROOT"
log_info "Submissions: ${SUBMISSIONS_DIR:-'(checking docs only)'}"
echo ""

# Output files
SIMILARITY_REPORT="$SEMINAR_DIR/similarity_report.json"
AI_REPORT="$SEMINAR_DIR/ai_fingerprint_report.json"
SUMMARY_REPORT="$SEMINAR_DIR/plagiarism_summary.txt"

# ─────────────────────────────────────────────────────────────────────────────
# Step 1: Internal Similarity Checker
# ─────────────────────────────────────────────────────────────────────────────
log_step 1 "Running internal similarity checker..."

SIMILARITY_SCRIPT="$KIT_ROOT/SEM01/scripts/python/S01_05_plagiarism_detector.py"

if [[ -f "$SIMILARITY_SCRIPT" ]] && [[ -n "$SUBMISSIONS_DIR" ]] && [[ -d "$SUBMISSIONS_DIR" ]]; then
    if python3 "$SIMILARITY_SCRIPT" \
        --submissions "$SUBMISSIONS_DIR" \
        --output "$SIMILARITY_REPORT" 2>/dev/null; then
        log_success "Similarity report saved to: $SIMILARITY_REPORT"
    else
        log_warning "Similarity checker returned non-zero exit code"
        echo '{"results": [], "error": "checker failed"}' > "$SIMILARITY_REPORT"
    fi
else
    log_warning "Similarity checker skipped (no submissions directory or script missing)"
    echo '{"results": [], "note": "no submissions to check"}' > "$SIMILARITY_REPORT"
fi

# ─────────────────────────────────────────────────────────────────────────────
# Step 2: AI Fingerprint Scanner
# ─────────────────────────────────────────────────────────────────────────────
log_step 2 "Running AI fingerprint scanner..."

AI_SCRIPT="$KIT_ROOT/SEM01/scripts/python/S01_06_ai_fingerprint_scanner.py"

# Determine what to scan
SCAN_TARGET="$SEMINAR_DIR/docs"
if [[ -n "$SUBMISSIONS_DIR" ]] && [[ -d "$SUBMISSIONS_DIR" ]]; then
    SCAN_TARGET="$SUBMISSIONS_DIR"
fi

if [[ -f "$AI_SCRIPT" ]] && [[ -d "$SCAN_TARGET" ]]; then
    # Run scanner (it may exit non-zero if issues found, that's OK)
    python3 "$AI_SCRIPT" "$SCAN_TARGET" --output "$AI_REPORT" 2>/dev/null || true
    log_success "AI fingerprint report saved to: $AI_REPORT"
else
    log_warning "AI scanner skipped (script or target directory missing)"
    echo '{"summary": {"authenticity_score": 10}, "results": {}}' > "$AI_REPORT"
fi

# ─────────────────────────────────────────────────────────────────────────────
# Step 3: Generate Combined Report
# ─────────────────────────────────────────────────────────────────────────────
log_step 3 "Generating combined report..."

python3 << EOF
import json
import sys
from datetime import datetime

# Load reports
try:
    with open("$SIMILARITY_REPORT") as f:
        similarity = json.load(f)
except Exception as e:
    similarity = {"results": [], "error": str(e)}

try:
    with open("$AI_REPORT") as f:
        fingerprint = json.load(f)
except Exception as e:
    fingerprint = {"summary": {"authenticity_score": 10}, "results": {}}

# Collect flagged submissions
flagged = []

# Check similarity results
for submission in similarity.get('results', []):
    max_sim = submission.get('max_similarity', 0)
    if max_sim > $SIMILARITY_THRESHOLD:
        flagged.append({
            'student': submission.get('student', 'unknown'),
            'reason': 'High code similarity',
            'score': f"{max_sim:.1f}%",
            'severity': 'HIGH' if max_sim > 75 else 'MEDIUM'
        })

# Check AI fingerprint results
ai_score = fingerprint.get('summary', {}).get('authenticity_score', 10)
if ai_score < $AI_SCORE_THRESHOLD:
    for filepath, issues in fingerprint.get('results', {}).items():
        high_risk = len(issues.get('high_risk', []))
        if high_risk > 0:
            flagged.append({
                'student': filepath.split('/')[-2] if '/' in filepath else filepath,
                'reason': 'AI-generated content detected',
                'score': f"{ai_score:.1f}/10",
                'severity': 'HIGH' if high_risk > 5 else 'MEDIUM'
            })

# Generate summary
summary = f"""
═══════════════════════════════════════════════════════════════
  PLAGIARISM CHECK SUMMARY — {datetime.now().strftime('%Y-%m-%d %H:%M')}
═══════════════════════════════════════════════════════════════

Seminar: $SEMINAR
Similarity threshold: >{$SIMILARITY_THRESHOLD}%
AI score threshold: <{$AI_SCORE_THRESHOLD}/10

───────────────────────────────────────────────────────────────
  FLAGGED SUBMISSIONS ({len(flagged)})
───────────────────────────────────────────────────────────────
"""

if flagged:
    for item in sorted(flagged, key=lambda x: x['severity'], reverse=True):
        sev_marker = "🔴" if item['severity'] == 'HIGH' else "🟡"
        summary += f"\n  {sev_marker} {item['student']}"
        summary += f"\n     Reason: {item['reason']}"
        summary += f"\n     Score:  {item['score']}"
        summary += f"\n     Action: {'Oral verification required' if item['severity'] == 'HIGH' else 'Manual review recommended'}"
        summary += "\n"
else:
    summary += "\n  ✅ No submissions flagged\n"

summary += """
───────────────────────────────────────────────────────────────
  NEXT STEPS
───────────────────────────────────────────────────────────────

For flagged submissions:
  1. Review the detailed reports
  2. Check submission timestamps
  3. Conduct oral verification
  4. Document findings

Reports:
  - Similarity: $SIMILARITY_REPORT
  - AI Fingerprint: $AI_REPORT

═══════════════════════════════════════════════════════════════
"""

# Save summary
with open("$SUMMARY_REPORT", 'w') as f:
    f.write(summary)

# Print summary
print(summary)
EOF

log_success "Summary report saved to: $SUMMARY_REPORT"

log_header "PIPELINE COMPLETE"

echo "Generated reports:"
echo "  - $SIMILARITY_REPORT"
echo "  - $AI_REPORT"  
echo "  - $SUMMARY_REPORT"
echo ""
echo "For external tools (MOSS/JPlag), see:"
echo "  $SCRIPT_DIR/MOSS_JPLAG_GUIDE.md"
