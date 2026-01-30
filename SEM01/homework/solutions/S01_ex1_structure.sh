#!/bin/bash
#
# Solution Exercise 1: Creating Directory Structure
# Seminar 01 - Shell Fundamentals
# Operating Systems | ASE Bucharest - CSIE
#
# Requirement: Create the directory structure for a project
# with README.md and AUTHOR.txt files
#

# Defensive coding - stop execution at first error
set -euo pipefail

# Configuration - target directory
TARGET_DIR="${1:-os_project}"

# Create directory structure using brace expansion
# -p creates parents if they don't exist
mkdir -p "${TARGET_DIR}"/{src,docs,tests}

# Create README.md in the main directory
cat > "${TARGET_DIR}/README.md" << 'EOF'
# Operating Systems Project

## Description
This directory contains the standard structure for laboratory projects.

## Structure
```
project/
├── src/      # Source code
├── docs/     # Documentation
└── tests/    # Tests
```

## Author
Complete with your name in AUTHOR.txt
EOF

# Create AUTHOR.txt with current date
cat > "${TARGET_DIR}/AUTHOR.txt" << EOF
Name: [Complete]
Group: [Complete]
Date: $(date +%Y-%m-%d)
EOF

# Verify and display structure
echo "Structure created in: ${TARGET_DIR}"
echo ""

# Display structure (use tree if available, otherwise find)
if command -v tree &>/dev/null; then
    tree "${TARGET_DIR}"
else
    find "${TARGET_DIR}" -type f -o -type d | sort
fi

echo ""
echo "Verification complete."
