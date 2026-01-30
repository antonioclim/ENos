#!/bin/bash
#===============================================================================
# NAME:        submission_packager.sh
# DESCRIPTION: Packages the project for submission
# AUTHOR:      OS Kit - ASE CSIE
# VERSION:     1.0.0
#===============================================================================

set -euo pipefail

usage() {
    cat << EOF
Usage: $(basename "$0") <project_dir> <student_name> <project_id>

Packages the project for submission, excluding unnecessary files.

Arguments:
  project_dir   Project directory
  student_name  Student name (no spaces, e.g. PopescuIon)
  project_id    Project ID (e.g. E01, M05, A02)

Examples:
  $(basename "$0") ./my_project PopescuIon E01
  $(basename "$0") ~/project NameSurname M05

Output:
  NameSurname_ProjectID_YYYYMMDD.tar.gz
EOF
}

[[ $# -lt 3 ]] && { usage; exit 1; }

PROJECT_DIR="$1"
STUDENT_NAME="$2"
PROJECT_ID="$3"

[[ ! -d "$PROJECT_DIR" ]] && { echo "Error: '$PROJECT_DIR' does not exist"; exit 1; }

DATE=$(date +%Y%m%d)
ARCHIVE_NAME="${STUDENT_NAME}_${PROJECT_ID}_${DATE}.tar.gz"

echo "╔══════════════════════════════════════════════╗"
echo "║     SUBMISSION PACKAGER - OS ASE CSIE        ║"
echo "╚══════════════════════════════════════════════╝"
echo ""
echo "Project:  $PROJECT_DIR"
echo "Student:  $STUDENT_NAME"
echo "ID:       $PROJECT_ID"
echo "Output:   $ARCHIVE_NAME"
echo ""

# Create archive excluding unnecessary files
echo "Packaging..."
tar --exclude='__pycache__' \
    --exclude='*.pyc' \
    --exclude='.git' \
    --exclude='node_modules' \
    --exclude='.DS_Store' \
    --exclude='*.swp' \
    --exclude='*.tmp' \
    --exclude='.vscode' \
    --exclude='.idea' \
    -czvf "$ARCHIVE_NAME" \
    -C "$(dirname "$PROJECT_DIR")" \
    "$(basename "$PROJECT_DIR")"

# Check size
SIZE=$(du -h "$ARCHIVE_NAME" | cut -f1)
echo ""
echo "════════════════════════════════════════"
echo "✓ Archive created: $ARCHIVE_NAME ($SIZE)"
echo "════════════════════════════════════════"

# Check contents
echo ""
echo "Archive contents:"
tar -tzvf "$ARCHIVE_NAME" | head -20
echo "... ($(tar -tzf "$ARCHIVE_NAME" | wc -l) files total)"
