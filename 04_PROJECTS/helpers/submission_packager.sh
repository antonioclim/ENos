#!/bin/bash
#===============================================================================
# NAME:        submission_packager.sh
# DESCRIPTION: Packages the project for submission as a compressed archive
# AUTHOR:      OS Kit - ASE CSIE
# VERSION:     1.1.0
#
# USAGE:       ./submission_packager.sh <project_dir> <student_name> <project_id>
#
# EXIT CODES:
#   0 - Archive created successfully
#   1 - Invalid arguments or directory not found
#
# OUTPUT:
#   Creates StudentName_ProjectID_YYYYMMDD.tar.gz in current directory
#
# EXCLUDED FILES:
#   - __pycache__, *.pyc (Python cache)
#   - .git (version control)
#   - node_modules (Node.js dependencies)
#   - .DS_Store, *.swp, *.tmp (editor/OS files)
#   - .vscode, .idea (IDE settings)
#
# EXAMPLES:
#   ./submission_packager.sh ./my_project PopescuIon E01
#   ./submission_packager.sh ~/project NameSurname M05
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

[[ ${1:-} != --help && ${1:-} != -h ]] || { usage; exit 0; }
[[ $# -ne 3 ]] && { usage >&2; exit 2; }

PROJECT_DIR="$1"
STUDENT_NAME="$2"
PROJECT_ID="$3"

[[ ! -d "$PROJECT_DIR" ]] && { echo "Error: '$PROJECT_DIR' does not exist"; exit 1; }

[[ "$STUDENT_NAME" =~ ^[A-Za-z0-9_-]+$ && "$PROJECT_ID" =~ ^(E0[1-5]|M(0[1-9]|1[0-5])|A0[1-3])$ ]] || { echo "Invalid student name or project ID" >&2; exit 1; }
PROJECT_DIR=$(realpath -- "$PROJECT_DIR")
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

# Stage outside the source tree and publish only a complete archive.
[[ ! -e "$ARCHIVE_NAME" ]] || { echo "Output already exists: $ARCHIVE_NAME" >&2; exit 1; }
STAGE=$(mktemp -d "${TMPDIR:-/tmp}/enos-package.XXXXXX")
trap 'rm -rf -- "$STAGE"' EXIT
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
    -czvf "$STAGE/archive.tar.gz" \
    -C "$(dirname "$PROJECT_DIR")" \
    "$(basename "$PROJECT_DIR")"

tar -tzf "$STAGE/archive.tar.gz" > "$STAGE/members.txt"
python3 - "$STAGE/archive.tar.gz" "$ARCHIVE_NAME" <<'PUBLISH'
import os, shutil, sys, tempfile
from pathlib import Path
source, target = map(Path, sys.argv[1:])
fd, temporary = tempfile.mkstemp(prefix='.enos-package-', dir=target.parent)
os.close(fd)
try:
    shutil.copyfile(source, temporary)
    os.link(temporary, target)  # exclusive publication; existing target is preserved
finally:
    os.unlink(temporary)
PUBLISH
# Check size
SIZE=$(du -h "$ARCHIVE_NAME" | cut -f1)
echo ""
echo "════════════════════════════════════════"
echo "✓ Archive created: $ARCHIVE_NAME ($SIZE)"
echo "════════════════════════════════════════"

# Check contents
echo ""
echo "Archive contents:"
sed -n '1,20p' "$STAGE/members.txt"
echo "... ($(wc -l < "$STAGE/members.txt") files total)"
