#!/bin/bash
#
# Library:     library.sh
# Description: Reusable functions for Bash scripts
# Author:      ASE Bucharest - CSIE
# Version:     1.0.0
#
# Usage:       source library.sh
#              or
#              . library.sh
#
# Note:        This file should NOT be executed directly!
#

# Check that it's not run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "ERROR: This file must be loaded with 'source', not executed directly." >&2
    echo "Usage: source ${BASH_SOURCE[0]}" >&2
    exit 1
fi

# ============================================================
# COMMON CONSTANTS
# ============================================================
readonly LIB_VERSION="1.0.0"

# ============================================================
# COLOURS (for terminals)
# ============================================================
if [[ -t 1 ]]; then
    readonly _RED='\033[0;31m'
    readonly _GREEN='\033[0;32m'
    readonly _YELLOW='\033[0;33m'
    readonly _BLUE='\033[0;34m'
    readonly _BOLD='\033[1m'
    readonly _NC='\033[0m'
else
    readonly _RED=''
    readonly _GREEN=''
    readonly _YELLOW=''
    readonly _BLUE=''
    readonly _BOLD=''
    readonly _NC=''
fi

# ============================================================
# OUTPUT FUNCTIONS
# ============================================================

# Display informational message
lib_info() {
    echo -e "${_GREEN}[INFO]${_NC} $*"
}

# Display warning
lib_warn() {
    echo -e "${_YELLOW}[WARN]${_NC} $*" >&2
}

# Display error
lib_error() {
    echo -e "${_RED}[ERROR]${_NC} $*" >&2
}

# Terminate with error
lib_die() {
    lib_error "$@"
    exit 1
}

# Display debug message (only if DEBUG=1)
lib_debug() {
    [[ "${DEBUG:-0}" == "1" ]] && echo -e "${_BLUE}[DEBUG]${_NC} $*" >&2
}

# Display bold message
lib_bold() {
    echo -e "${_BOLD}$*${_NC}"
}

# ============================================================
# VERIFICATION FUNCTIONS
# ============================================================

# Check if a command exists
lib_require_command() {
    local cmd="$1"
    local msg="${2:-Command '$cmd' is not installed}"
    command -v "$cmd" >/dev/null 2>&1 || lib_die "$msg"
}

# Check if a file exists and is readable
lib_require_file() {
    local file="$1"
    local msg="${2:-File does not exist or cannot be read: $file}"
    [[ -f "$file" && -r "$file" ]] || lib_die "$msg"
}

# Check if a directory exists and is writable
lib_require_dir() {
    local dir="$1"
    local msg="${2:-Directory does not exist or cannot be written to: $dir}"
    [[ -d "$dir" && -w "$dir" ]] || lib_die "$msg"
}

# Check if running as root
lib_require_root() {
    [[ $EUID -eq 0 ]] || lib_die "This script requires root privileges"
}

# Check that we are NOT running as root
lib_forbid_root() {
    [[ $EUID -ne 0 ]] || lib_die "This script should NOT be run as root"
}

# ============================================================
# STRING FUNCTIONS
# ============================================================

# Trim whitespace from beginning and end of string
lib_trim() {
    local var="$*"
    var="${var#"${var%%[![:space:]]*}"}"
    var="${var%"${var##*[![:space:]]}"}"
    echo "$var"
}

# Convert to lowercase
lib_lowercase() {
    echo "${*,,}"
}

# Convert to uppercase
lib_uppercase() {
    echo "${*^^}"
}

# Check if string is empty or only whitespace
lib_is_empty() {
    local trimmed
    trimmed=$(lib_trim "$1")
    [[ -z "$trimmed" ]]
}

# Check if string is a number
lib_is_number() {
    [[ "$1" =~ ^[0-9]+$ ]]
}

# ============================================================
# ARRAY FUNCTIONS
# ============================================================

# Check if element exists in array
# Usage: lib_in_array "element" "${array[@]}"
lib_in_array() {
    local needle="$1"
    shift
    local item
    for item in "$@"; do
        [[ "$item" == "$needle" ]] && return 0
    done
    return 1
}

# Join array with separator
# Usage: lib_join "," "${array[@]}"
lib_join() {
    local separator="$1"
    shift
    local first="$1"
    shift
    printf '%s' "$first" "${@/#/$separator}"
}

# ============================================================
# FILE FUNCTIONS
# ============================================================

# Create backup of file
lib_backup() {
    local file="$1"
    local backup="${file}.bak.$(date +%Y%m%d_%H%M%S)"
    [[ -f "$file" ]] && cp "$file" "$backup"
    echo "$backup"
}

# Create temporary file and return path
lib_mktemp() {
    local prefix="${1:-tmp}"
    mktemp -t "${prefix}.XXXXXX"
}

# Create temporary directory and return path
lib_mktempdir() {
    local prefix="${1:-tmp}"
    mktemp -d -t "${prefix}.XXXXXX"
}

# ============================================================
# CONFIRMATION FUNCTIONS
# ============================================================

# Request confirmation from user
# Usage: lib_confirm "Are you sure?" && do_something
lib_confirm() {
    local prompt="${1:-Continue?}"
    local default="${2:-n}"
    
    local reply
    if [[ "$default" == "y" ]]; then
        read -r -p "$prompt [Y/n] " reply
        [[ -z "$reply" || "$reply" =~ ^[Yy] ]]
    else
        read -r -p "$prompt [y/N] " reply
        [[ "$reply" =~ ^[Yy] ]]
    fi
}

# Request input from user with default value
lib_prompt() {
    local prompt="$1"
    local default="${2:-}"
    local reply
    
    if [[ -n "$default" ]]; then
        read -r -p "$prompt [$default]: " reply
        echo "${reply:-$default}"
    else
        read -r -p "$prompt: " reply
        echo "$reply"
    fi
}

# ============================================================
# LOGGING FUNCTIONS
# ============================================================

# Initialise logging to file
# Usage: lib_init_log "/path/to/logfile.log"
_LIB_LOG_FILE=""

lib_init_log() {
    _LIB_LOG_FILE="$1"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Log started" >> "$_LIB_LOG_FILE"
}

# Write to log
lib_log() {
    if [[ -n "$_LIB_LOG_FILE" ]]; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$_LIB_LOG_FILE"
    fi
}

# ============================================================
# PROGRESS FUNCTIONS
# ============================================================

# Simple spinner for long operations
# Usage: lib_spinner $pid "Message..."
lib_spinner() {
    local pid=$1
    local msg="${2:-Processing...}"
    local spin='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    local i=0
    
    while kill -0 "$pid" 2>/dev/null; do
        printf "\r%s %s" "${spin:i++%${#spin}:1}" "$msg"
        sleep 0.1
    done
    printf "\r%s\n" "$msg Done!"
}

# Simple progress bar
# Usage: lib_progress 50 100 "Downloading"
lib_progress() {
    local current=$1
    local total=$2
    local msg="${3:-Progress}"
    local width=40
    local percent=$((current * 100 / total))
    local filled=$((current * width / total))
    local empty=$((width - filled))
    
    printf "\r%s: [%s%s] %d%%" "$msg" \
           "$(printf '#%.0s' $(seq 1 $filled))" \
           "$(printf '.%.0s' $(seq 1 $empty))" \
           "$percent"
    
    [[ $current -eq $total ]] && echo
}

# ============================================================
# MISCELLANEOUS FUNCTIONS
# ============================================================

# Get directory of script that loaded the library
lib_script_dir() {
    cd "$(dirname "${BASH_SOURCE[1]}")" && pwd
}

# Check Bash version
lib_require_bash_version() {
    local required="$1"
    local current="${BASH_VERSINFO[0]}.${BASH_VERSINFO[1]}"
    
    if [[ "$(printf '%s\n' "$required" "$current" | sort -V | head -n1)" != "$required" ]]; then
        lib_die "Requires Bash >= $required (you have $current)"
    fi
}

# Display library information
lib_info_version() {
    echo "Library version: $LIB_VERSION"
    echo "Bash version: ${BASH_VERSION}"
}

# ============================================================
# END
# ============================================================
lib_debug "Library loaded: library.sh v$LIB_VERSION"
