#!/bin/bash
#===============================================================================
# NAME:        project_structure.sh
# DESCRIPTION: Generates the base structure for an OS project
# AUTHOR:      OS Kit - ASE CSIE
# VERSION:     1.0.1
# MODIFIED:    Resolved heredoc delimiters conflict (nested EOF)
#===============================================================================

set -euo pipefail

usage() {
    cat << EOF
Usage: $(basename "$0") <project_name> [project_id]

Generates the standard directory structure for an OS project.

Arguments:
  project_name  Project name (will be the directory name)
  project_id    Optional ID (e.g. E01, M05) - added to README

Examples:
  $(basename "$0") my_project
  $(basename "$0") file_auditor E01

Generated structure:
  project_name/
  ├── README.md
  ├── Makefile
  ├── .gitignore
  ├── src/
  │   ├── main.sh
  │   └── lib/
  │       └── utils.sh
  ├── etc/
  │   └── config.conf
  ├── tests/
  │   └── test_main.sh
  ├── docs/
  │   ├── INSTALL.md
  │   └── USAGE.md
  └── examples/
      └── example_basic.sh
EOF
}

[[ ${1:-} != --help && ${1:-} != -h ]] || { usage; exit 0; }
[[ $# -ge 1 && $# -le 2 ]] || { usage >&2; exit 2; }

PROJECT_NAME="$1"
PROJECT_ID="${2:-}"
[[ $PROJECT_NAME =~ ^[A-Za-z0-9][A-Za-z0-9_-]*$ ]] || { echo 'Project name must be a simple directory name' >&2; exit 2; }
[[ -z $PROJECT_ID || $PROJECT_ID =~ ^(E0[1-5]|M(0[1-9]|1[0-5])|A0[1-3])$ ]] || { echo 'Invalid project ID' >&2; exit 2; }

[[ -e "$PROJECT_NAME" ]] && { echo "Error: '$PROJECT_NAME' already exists"; exit 1; }

echo "Creating project structure: $PROJECT_NAME"
echo ""

# Create directories
mkdir -p "$PROJECT_NAME"/{src/lib,etc,tests,docs,examples}

# README.md
cat > "$PROJECT_NAME/README.md" << EOF
# $PROJECT_NAME ${PROJECT_ID:+($PROJECT_ID)}

> **Operating Systems** | ASE Bucharest - CSIE

## Description

[Short project description]

## Installation

\`\`\`bash
git clone [url]
cd $PROJECT_NAME
make install
\`\`\`

### Dependencies

- Bash 5.0+
- [Other dependencies]

## Usage

\`\`\`bash
bash src/main.sh [options] <arguments>
\`\`\`

### Options

| Option | Description |
|--------|-------------|
| -h, --help | Display help |
| -v, --verbose | Verbose mode |

## Project Structure

\`\`\`
$PROJECT_NAME/
├── src/           # Source code
├── etc/           # Configuration
├── tests/         # Tests
├── docs/          # Documentation
└── examples/      # Examples
\`\`\`

## Testing

\`\`\`bash
make test
\`\`\`

## Documentation

- [INSTALL.md](docs/INSTALL.md) - Installation instructions
- [USAGE.md](docs/USAGE.md) - Usage manual

## Author

[Name Surname] - [Group]

## Licence

[Author decision required: insert the project licence only after approval.]
EOF

# Makefile
template_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
cp -- "$template_dir/Makefile_template" "$PROJECT_NAME/Makefile"

# .gitignore
cat > "$PROJECT_NAME/.gitignore" << 'GITIGNORE_CONTENT'
# Python
__pycache__/
*.pyc
*.pyo

# Editor
.vscode/
.idea/
*.swp
*~

# OS
.DS_Store
Thumbs.db

# Temporary
*.tmp
*.bak
*.log

# Build
/build/
/dist/
GITIGNORE_CONTENT

# src/main.sh - NOTE: using unique delimiter '__MAIN_SH__' 
# to avoid conflict with internal EOF (usage function)
cat > "$PROJECT_NAME/src/main.sh" << '__MAIN_SH__'
#!/bin/bash
#===============================================================================
# NAME:        main.sh
# DESCRIPTION: Main script
# VERSION:     1.0.0
#===============================================================================

set -euo pipefail
IFS=$'\n\t'

readonly SCRIPT_NAME="$(basename "$0")"
readonly SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
readonly VERSION="1.0.0"

# Source libraries
source "${SCRIPT_DIR}/lib/utils.sh"

#---------------------------------------
# Functions
#---------------------------------------

usage() {
    cat << EOF
Usage: ${SCRIPT_NAME} [OPTIONS] <argument>

Short description.

Options:
    -h, --help      Display this message
    -v, --verbose   Verbose mode
    -V, --version   Display version

Examples:
    ${SCRIPT_NAME} input.txt
    ${SCRIPT_NAME} -v input.txt
EOF
}

version() {
    echo "${SCRIPT_NAME} version ${VERSION}"
}

#---------------------------------------
# Argument parsing
#---------------------------------------

VERBOSE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help) usage; exit 0 ;;
        -V|--version) version; exit 0 ;;
        -v|--verbose) VERBOSE=true; shift ;;
        -*) die "Unknown option: $1" ;;
        *) break ;;
    esac
done

#---------------------------------------
# Main
#---------------------------------------

main() {
    log_info "Start ${SCRIPT_NAME}"
    
    # TODO: implement the project behaviour and its semantic tests.
    log_warn "NOT_IMPLEMENTED: this generated scaffold performs no project operation"
    return 3
}

main "$@"
__MAIN_SH__
chmod +x "$PROJECT_NAME/src/main.sh"

# src/lib/utils.sh
cat > "$PROJECT_NAME/src/lib/utils.sh" << 'UTILS_CONTENT'
#!/bin/bash
# Utility functions

# Colours
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly NC='\033[0m'

log_info() {
    printf '%b[INFO]%b %s\n' "$GREEN" "$NC" "$*" >&2
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $*" >&2
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $*" >&2
}

die() {
    log_error "$1"
    exit "${2:-1}"
}
UTILS_CONTENT

# etc/config.conf
cat > "$PROJECT_NAME/etc/config.conf" << 'CONFIG_CONTENT'
# Default configuration
# Edit as needed

# General settings
VERBOSE=false
LOG_LEVEL=INFO

# Specific settings
# OPTION1=value1
# OPTION2=value2
CONFIG_CONTENT

# tests/test_main.sh - unique delimiter because it contains [[ ]]
cat > "$PROJECT_NAME/tests/test_main.sh" << '__TEST_SH__'
#!/bin/bash
# Tests for main.sh

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
MAIN="${SCRIPT_DIR}/../src/main.sh"

TESTS=0
PASSED=0

assert_exit_code() {
    local expected=$1
    shift
    local actual
    if "$@" >/dev/null 2>&1; then actual=0; else actual=$?; fi
    TESTS=$((TESTS+1))
    if [[ $actual -eq $expected ]]; then
        echo "✓ PASS: exit code $expected"
        PASSED=$((PASSED+1))
    else
        echo "✗ FAIL: expected $expected, got $actual"
    fi
}

echo "═══ Tests main.sh ═══"

# Test help
assert_exit_code 0 bash "$MAIN" --help

# Test version
assert_exit_code 0 bash "$MAIN" --version
assert_exit_code 3 bash "$MAIN" input.txt

# Add more tests

echo ""
echo "Result: $PASSED/$TESTS tests passed"
[[ $PASSED -eq $TESTS ]]
__TEST_SH__
chmod +x "$PROJECT_NAME/tests/test_main.sh"

# docs/INSTALL.md
cat > "$PROJECT_NAME/docs/INSTALL.md" << EOF
# Installing $PROJECT_NAME

## System Requirements

- Linux (Ubuntu 24.04 recommended) or WSL2
- Bash 5.0+
- [Other dependencies]

## Installation Steps

1. Clone the repository:
   \`\`\`bash
   git clone [url]
   cd $PROJECT_NAME
   \`\`\`

2. Verify dependencies:
   \`\`\`bash
   bash --version  # >= 5.0
   \`\`\`

3. Install:
   \`\`\`bash
   make install
   \`\`\`

## Verifying Installation

\`\`\`bash
$PROJECT_NAME --version
\`\`\`

## Troubleshooting

### Error: Command not found

Add \`~/.local/bin\` to PATH:
\`\`\`bash
export PATH="\$HOME/.local/bin:\$PATH"
\`\`\`
EOF

# docs/USAGE.md
cat > "$PROJECT_NAME/docs/USAGE.md" << EOF
# Usage Manual - $PROJECT_NAME

## Basic Usage

\`\`\`bash
$PROJECT_NAME [options] <argument>
\`\`\`

## Options

| Option | Description |
|--------|-------------|
| -h, --help | Display help |
| -v, --verbose | Detailed output |

## Examples

### Example 1: Simple usage

\`\`\`bash
$PROJECT_NAME input.txt
\`\`\`

### Example 2: Verbose mode

\`\`\`bash
$PROJECT_NAME -v input.txt
\`\`\`

## Configuration

Edit \`etc/config.conf\` for custom settings.
EOF

# examples/example_basic.sh
cat > "$PROJECT_NAME/examples/example_basic.sh" << EOF
#!/bin/bash
# Basic usage example

SCRIPT_DIR="\$(cd "\$(dirname "\$0")" && pwd)"
MAIN="\${SCRIPT_DIR}/../src/main.sh"

echo "Example of using $PROJECT_NAME"
echo ""

# Run with help
"\$MAIN" --help
EOF
chmod +x "$PROJECT_NAME/examples/example_basic.sh"

# Summary
echo "✓ Structure created successfully!"
echo ""
echo "Generated structure:"
find "$PROJECT_NAME" -type f | sed 's/^/  /'
echo ""
echo "Next steps:"
echo "  1. cd $PROJECT_NAME"
echo "  2. Edit src/main.sh with your project logic"
echo "  3. Add tests in tests/"
echo "  4. Complete README.md"
echo "  5. make test to verify"
