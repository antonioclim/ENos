#!/bin/bash
#
# Script:      simple_script.sh
# Description: Minimalist template for simple scripts
# Author:      ing. dr. Antonio Clim (ASE Bucharest - CSIE)
# Version:     1.0.0
#

# ============================================================
# SAFETY OPTIONS - Mandatory for ANY script
# ============================================================
set -euo pipefail

# ============================================================
# VARIABLES
# ============================================================
readonly SCRIPT_NAME=$(basename "$0")

# ============================================================
# HELPERS
# ============================================================
usage() {
    echo "Usage: $SCRIPT_NAME <argument>"
    echo "Brief description of what the script does."
    exit 1
}

die() {
    echo "ERROR: $*" >&2
    exit 1
}

# ============================================================
# VALIDATION
# ============================================================
[[ $# -ge 1 ]] || usage
[[ -f "$1" ]] || die "File does not exist: $1"

# ============================================================
# MAIN
# ============================================================
INPUT="$1"

echo "Processing: $INPUT"

# Your logic here...

echo "Done."
