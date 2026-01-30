#!/bin/bash
#===============================================================================
# verify_homework_EN.sh - Homework Signature Verification Script
#===============================================================================
# Operating Systems | ASE Bucharest - CSIE
# Verifies cryptographic signatures on .cast homework submissions
#===============================================================================

set -euo pipefail

#-------------------------------------------------------------------------------
# Configuration
#-------------------------------------------------------------------------------
SCRIPT_NAME=$(basename "$0")
VERSION="1.0.0"

# Colours for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Colour

# Public key for verification (replace with actual key)
PUBLIC_KEY_PATH="${PUBLIC_KEY_PATH:-/etc/os-course/public_key.pem}"

# Output directory
OUTPUT_DIR="${OUTPUT_DIR:-./verification_results}"

#-------------------------------------------------------------------------------
# Functions
#-------------------------------------------------------------------------------

print_banner() {
    echo -e "${BLUE}"
    echo "╔═══════════════════════════════════════════════════════════════════╗"
    echo "║           HOMEWORK SIGNATURE VERIFICATION TOOL                    ║"
    echo "║                Operating Systems - ASE CSIE                       ║"
    echo "╚═══════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

usage() {
    cat << EOF
Usage: ${SCRIPT_NAME} [OPTIONS] <submissions_directory>

Verifies cryptographic signatures on homework .cast files.

OPTIONS:
    -h, --help          Show this help message
    -v, --version       Show version
    -o, --output DIR    Output directory for results (default: ./verification_results)
    -k, --key FILE      Public key file for verification
    -q, --quiet         Suppress progress output
    -r, --report        Generate detailed report
    --seminar SEM       Filter by seminar (e.g., SEM01, SEM02)
    --student NAME      Filter by student name/ID

EXAMPLES:
    ${SCRIPT_NAME} /path/to/submissions/
    ${SCRIPT_NAME} -r --seminar SEM02 /submissions/
    ${SCRIPT_NAME} -o ./results -k ./public.pem /submissions/

EOF
    exit 0
}

version() {
    echo "${SCRIPT_NAME} version ${VERSION}"
    exit 0
}

log_info() {
    [[ "${QUIET:-false}" == "true" ]] && return
    echo -e "${BLUE}[INFO]${NC} $*"
}

log_success() {
    echo -e "${GREEN}[✓]${NC} $*"
}

log_warning() {
    echo -e "${YELLOW}[⚠]${NC} $*"
}

log_error() {
    echo -e "${RED}[✗]${NC} $*" >&2
}

#-------------------------------------------------------------------------------
# Signature Verification
#-------------------------------------------------------------------------------

extract_signature() {
    local cast_file="$1"
    
    # Extract signature from last line of .cast file
    # Format: # SIGNATURE: <base64_signature>
    local sig_line
    sig_line=$(tail -1 "$cast_file" | grep -E '^# SIGNATURE:' || echo "")
    
    if [[ -z "$sig_line" ]]; then
        echo ""
        return 1
    fi
    
    echo "$sig_line" | sed 's/^# SIGNATURE: //'
}

extract_content_hash() {
    local cast_file="$1"
    
    # Hash all content except the signature line
    head -n -1 "$cast_file" | sha256sum | cut -d' ' -f1
}

verify_signature() {
    local cast_file="$1"
    local public_key="$2"
    
    # Extract signature
    local signature
    signature=$(extract_signature "$cast_file")
    
    if [[ -z "$signature" ]]; then
        echo "NO_SIGNATURE"
        return 1
    fi
    
    # Extract content hash
    local content_hash
    content_hash=$(extract_content_hash "$cast_file")
    
    # Verify using openssl (if public key exists)
    if [[ -f "$public_key" ]]; then
        # Decode signature and verify
        echo "$signature" | base64 -d > /tmp/sig.bin 2>/dev/null
        echo "$content_hash" | openssl dgst -sha256 -verify "$public_key" \
            -signature /tmp/sig.bin > /dev/null 2>&1
        
        if [[ $? -eq 0 ]]; then
            echo "VALID"
            return 0
        else
            echo "INVALID"
            return 1
        fi
    else
        # Fallback: check signature format only
        if [[ ${#signature} -ge 64 ]]; then
            echo "FORMAT_OK"
            return 0
        else
            echo "INVALID_FORMAT"
            return 1
        fi
    fi
}

#-------------------------------------------------------------------------------
# Metadata Extraction
#-------------------------------------------------------------------------------

extract_metadata() {
    local cast_file="$1"
    
    # Extract header JSON from .cast file
    local header
    header=$(head -1 "$cast_file")
    
    # Parse metadata fields
    local student_name student_group seminar timestamp
    
    student_name=$(echo "$header" | grep -oP '"student_name"\s*:\s*"\K[^"]+' || echo "UNKNOWN")
    student_group=$(echo "$header" | grep -oP '"student_group"\s*:\s*"\K[^"]+' || echo "UNKNOWN")
    seminar=$(echo "$header" | grep -oP '"seminar"\s*:\s*"\K[^"]+' || echo "UNKNOWN")
    timestamp=$(echo "$header" | grep -oP '"timestamp"\s*:\s*\K[0-9.]+' || echo "0")
    
    echo "${student_name}|${student_group}|${seminar}|${timestamp}"
}

#-------------------------------------------------------------------------------
# Main Processing
#-------------------------------------------------------------------------------

process_submissions() {
    local submissions_dir="$1"
    
    # Create output directory
    mkdir -p "$OUTPUT_DIR"
    
    # Initialise counters
    local total=0 valid=0 invalid=0 no_sig=0
    
    # Results file
    local results_file="${OUTPUT_DIR}/verification_results.csv"
    echo "File,Student,Group,Seminar,Timestamp,Signature_Status" > "$results_file"
    
    # Find all .cast files
    while IFS= read -r -d '' cast_file; do
        ((total++))
        
        local filename
        filename=$(basename "$cast_file")
        
        log_info "Processing: $filename"
        
        # Extract metadata
        local metadata
        metadata=$(extract_metadata "$cast_file")
        IFS='|' read -r student_name student_group seminar timestamp <<< "$metadata"
        
        # Apply filters
        if [[ -n "${FILTER_SEMINAR:-}" && "$seminar" != "$FILTER_SEMINAR" ]]; then
            continue
        fi
        
        if [[ -n "${FILTER_STUDENT:-}" && "$student_name" != *"$FILTER_STUDENT"* ]]; then
            continue
        fi
        
        # Verify signature
        local sig_status
        sig_status=$(verify_signature "$cast_file" "$PUBLIC_KEY_PATH")
        
        case "$sig_status" in
            VALID|FORMAT_OK)
                ((valid++))
                log_success "$filename - Signature valid"
                ;;
            NO_SIGNATURE)
                ((no_sig++))
                log_warning "$filename - No signature found"
                ;;
            *)
                ((invalid++))
                log_error "$filename - Invalid signature"
                ;;
        esac
        
        # Write to CSV
        echo "\"$filename\",\"$student_name\",\"$student_group\",\"$seminar\",\"$timestamp\",\"$sig_status\"" >> "$results_file"
        
    done < <(find "$submissions_dir" -name "*.cast" -type f -print0)
    
    # Summary
    echo ""
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}                    VERIFICATION SUMMARY                           ${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "  Total files processed:  ${total}"
    echo -e "  ${GREEN}Valid signatures:${NC}        ${valid}"
    echo -e "  ${YELLOW}Missing signatures:${NC}      ${no_sig}"
    echo -e "  ${RED}Invalid signatures:${NC}      ${invalid}"
    echo ""
    echo -e "  Results saved to: ${results_file}"
    echo ""
    
    # Generate detailed report if requested
    if [[ "${GENERATE_REPORT:-false}" == "true" ]]; then
        generate_report "$results_file"
    fi
}

generate_report() {
    local results_file="$1"
    local report_file="${OUTPUT_DIR}/verification_report.md"
    
    cat > "$report_file" << EOF
# Homework Verification Report

**Generated:** $(date '+%Y-%m-%d %H:%M:%S')
**Source:** ${SUBMISSIONS_DIR}

## Summary

| Metric | Count |
|--------|-------|
| Total Files | $(tail -n +2 "$results_file" | wc -l) |
| Valid | $(grep -c "VALID\|FORMAT_OK" "$results_file" || echo 0) |
| Invalid | $(grep -c "INVALID" "$results_file" || echo 0) |
| Missing Signature | $(grep -c "NO_SIGNATURE" "$results_file" || echo 0) |

## Detailed Results

$(cat "$results_file" | column -t -s',')

---
*Generated by verify_homework_EN.sh v${VERSION}*
EOF
    
    log_info "Report generated: $report_file"
}

#-------------------------------------------------------------------------------
# Argument Parsing
#-------------------------------------------------------------------------------

QUIET=false
GENERATE_REPORT=false
FILTER_SEMINAR=""
FILTER_STUDENT=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            usage
            ;;
        -v|--version)
            version
            ;;
        -o|--output)
            OUTPUT_DIR="$2"
            shift 2
            ;;
        -k|--key)
            PUBLIC_KEY_PATH="$2"
            shift 2
            ;;
        -q|--quiet)
            QUIET=true
            shift
            ;;
        -r|--report)
            GENERATE_REPORT=true
            shift
            ;;
        --seminar)
            FILTER_SEMINAR="$2"
            shift 2
            ;;
        --student)
            FILTER_STUDENT="$2"
            shift 2
            ;;
        -*)
            log_error "Unknown option: $1"
            exit 1
            ;;
        *)
            SUBMISSIONS_DIR="$1"
            shift
            ;;
    esac
done

#-------------------------------------------------------------------------------
# Main
#-------------------------------------------------------------------------------

main() {
    print_banner
    
    # Validate input
    if [[ -z "${SUBMISSIONS_DIR:-}" ]]; then
        log_error "No submissions directory specified"
        echo ""
        usage
    fi
    
    if [[ ! -d "$SUBMISSIONS_DIR" ]]; then
        log_error "Directory not found: $SUBMISSIONS_DIR"
        exit 1
    fi
    
    log_info "Submissions directory: $SUBMISSIONS_DIR"
    log_info "Output directory: $OUTPUT_DIR"
    
    if [[ -f "$PUBLIC_KEY_PATH" ]]; then
        log_info "Using public key: $PUBLIC_KEY_PATH"
    else
        log_warning "Public key not found - using format validation only"
    fi
    
    echo ""
    
    process_submissions "$SUBMISSIONS_DIR"
}

main "$@"
