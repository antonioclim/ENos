# Technical Guide - OS Project Development

> **Best Practices and Recommended Patterns**  
> **Operating Systems** | ASE Bucharest - CSIE

---

## Scope

Examples use Bash4.4+ and owned local fixtures. A code block labelled as a pattern needs its declared application functions; TODOs remain exercises. Historical anecdotes and timings below have unverified provenance. Assessment and licensing choices are documented in [the current contract](ASSESSMENT_AND_EVIDENCE_CONTRACT.md).

## Contents

1. [Project Structure](#project-structure)
2. [Code Conventions](#code-conventions)
3. [Recommended Patterns](#recommended-patterns)
4. [Error Handling](#error-handling)
5. [Logging and Debugging](#logging-and-debugging)
6. [Testing](#testing)
7. [Performance](#performance)
8. [Security](#security)
9. [War Stories](#war-stories)

---

## Project Structure

### Recommended Standard Structure

```
project/
├── README.md                 # Main documentation
├── Makefile                  # Build/test/install automation
├── .gitignore                # Files ignored by Git
│
├── src/                      # Source code
│   ├── main.sh               # Main entry point
│   ├── lib/                  # Libraries and modules
│   │   ├── utils.sh          # Utility functions
│   │   ├── config.sh         # Configuration management
│   │   ├── logging.sh        # Logging system
│   │   └── validation.sh     # Input validation
│   └── commands/             # Subcommands (if CLI)
│       ├── cmd_start.sh
│       ├── cmd_stop.sh
│       └── cmd_status.sh
│
├── etc/                      # Configuration files
│   ├── config.conf           # Default configuration
│   └── config.conf.example   # Configuration example
│
├── tests/                    # Automated tests
│   ├── test_utils.sh
│   ├── test_main.sh
│   └── run_all_tests.sh
│
├── docs/                     # Extended documentation
│   ├── INSTALL.md
│   ├── USAGE.md
│   └── ARCHITECTURE.md
│
└── examples/                 # Usage examples
    ├── example_basic.sh
    └── example_advanced.sh
```

### Standard Makefile

```makefile
#===============================================================================
# Makefile Template - OS Project
# ASE Bucharest - CSIE
#===============================================================================

# Configuration
SHELL := /bin/bash
.SHELLFLAGS := -eu -o pipefail -c

# Project variables
NAME := $(shell basename "$(CURDIR)")
VERSION := 1.0.0
INSTALL_DIR ?= $(HOME)/.local/bin
RUNTIME_DIR ?= $(HOME)/.local/share/$(NAME)

# Directories
SRC_DIR := src
LIB_DIR := $(SRC_DIR)/lib
TEST_DIR := tests
DOC_DIR := docs

# Files
MAIN := $(SRC_DIR)/main.sh
SCRIPTS := $(wildcard $(SRC_DIR)/*.sh) $(wildcard $(LIB_DIR)/*.sh)
TESTS := $(wildcard $(TEST_DIR)/test_*.sh)

# Colours (for nice output)
RED := \033[0;31m
GREEN := \033[0;32m
YELLOW := \033[1;33m
NC := \033[0m

#---------------------------------------
# Main targets
#---------------------------------------

.PHONY: all
all: syntax lint test ## Full verification (lint + test)

.PHONY: help
help: ## Display this help message
	@echo "╔══════════════════════════════════════════════╗"
	@echo "║     $(NAME) - Makefile Help                  ║"
	@echo "╚══════════════════════════════════════════════╝"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'
	@echo ""

#---------------------------------------
# Development
#---------------------------------------

.PHONY: lint
lint: ## Check code quality with ShellCheck
	@echo -e "$(YELLOW)═══ ShellCheck ═══$(NC)"
	@if command -v shellcheck &>/dev/null; then \
		plan=$$(mktemp); trap 'rm -f -- "$$plan"' EXIT; find "$(SRC_DIR)" -type f -name '*.sh' -print0 > "$$plan"; mapfile -d '' -t files < "$$plan"; \
        [ $${#files[@]} -gt 0 ] || { echo "NOT_RUN: no Bash sources"; exit 2; }; \
        shellcheck -x "$${files[@]}" && \
		echo -e "$(GREEN)✓ ShellCheck passed$(NC)"; \
	else \
		echo -e "$(YELLOW)⚠ ShellCheck is not installed. Install with: sudo apt install shellcheck$(NC)"; exit 2; \
	fi

.PHONY: syntax
syntax: ## Check Bash syntax
	@echo -e "$(YELLOW)═══ Syntax Check ═══$(NC)"
	@plan=$$(mktemp); trap 'rm -f -- "$$plan"' EXIT; find "$(SRC_DIR)" -type f -name '*.sh' -print0 > "$$plan"; mapfile -d '' -t files < "$$plan"; \
	[ $${#files[@]} -gt 0 ] || { echo "NOT_RUN: no Bash sources"; exit 2; }; \
	failed=0; for script in "$${files[@]}"; do \
		if bash -n "$$script"; then echo "Syntax OK: $$script"; else failed=$$((failed + 1)); fi; \
	done; [ $$failed -eq 0 ]

.PHONY: test
test: ## Run all tests
	@echo -e "$(YELLOW)═══ Running Tests ═══$(NC)"
	@if [ -f "$(TEST_DIR)/run_all.sh" ]; then \
		bash "$(TEST_DIR)/run_all.sh"; \
	else \
		passed=0; failed=0; \
		plan=$$(mktemp); trap 'rm -f -- "$$plan"' EXIT; find "$(TEST_DIR)" -maxdepth 1 -type f -name 'test_*.sh' -print0 | sort -z > "$$plan"; mapfile -d '' -t files < "$$plan"; \
		[ $${#files[@]} -gt 0 ] || { echo "NOT_RUN: no tests"; exit 2; }; \
		for test in "$${files[@]}"; do \
			if bash "$$test"; then \
				passed=$$((passed + 1)); \
			else \
				failed=$$((failed + 1)); \
			fi; \
		done; \
		echo ""; \
		echo "Result: $$passed passed, $$failed failed"; \
		[ $$failed -eq 0 ]; \
	fi

.PHONY: test-verbose
test-verbose: test ## Run the same mandatory tests (test output is retained)

#---------------------------------------
# Installation
#---------------------------------------

.PHONY: install
install: syntax ## Install to ~/.local/bin
	@echo -e "$(YELLOW)═══ Installation ═══$(NC)"
	@mkdir -p "$(INSTALL_DIR)" "$(RUNTIME_DIR)"
	@cp -a "$(SRC_DIR)" "$(RUNTIME_DIR)/"
	@for resource in config etc resources templates; do if [ -d "$$resource" ]; then cp -a "$$resource" "$(RUNTIME_DIR)/"; fi; done
	@printf '%s\n' '#!/bin/bash' 'exec bash "$(RUNTIME_DIR)/$(MAIN)" "$$@"' > "$(INSTALL_DIR)/$(NAME)"
	@chmod +x "$(INSTALL_DIR)/$(NAME)"
	@echo -e "$(GREEN)✓ Installed to $(INSTALL_DIR)/$(NAME)$(NC)"
	@echo ""
	@echo "Make sure $(INSTALL_DIR) is in PATH:"
	@echo "  export PATH=\"$(INSTALL_DIR):\$$PATH\""

.PHONY: uninstall
uninstall: ## Uninstall
	@echo -e "$(YELLOW)═══ Uninstallation ═══$(NC)"
	@rm -f -- "$(INSTALL_DIR)/$(NAME)"
	@echo "Runtime retained at $(RUNTIME_DIR); inspect before removing it."
	@echo -e "$(GREEN)✓ Uninstalled$(NC)"

#---------------------------------------
# Cleanup
#---------------------------------------

.PHONY: clean
clean: ## Delete temporary files
	@echo -e "$(YELLOW)═══ Cleanup ═══$(NC)"
	@echo "No source, logs, backups or fixtures are deleted by this template."
	@echo "Add exact generated build targets to clean when your project defines them."
	@echo -e "$(GREEN)✓ Cleaned$(NC)"

.PHONY: clean-all
clean-all: clean uninstall ## Full cleanup + uninstall

#---------------------------------------
# Packaging
#---------------------------------------

.PHONY: package
package: ## Create archive for submission
	@echo -e "$(YELLOW)═══ Packaging ═══$(NC)"
	@tar --exclude='.git' \
	     --exclude='*.tmp' \
	     --exclude='*.bak' \
	     -czvf "../$(NAME)_$(VERSION).tar.gz" .
	@echo -e "$(GREEN)✓ Created ../$(NAME)_$(VERSION).tar.gz$(NC)"

#---------------------------------------
# Documentation
#---------------------------------------

.PHONY: docs
docs: ## Generate documentation (if applicable)
	@echo -e "$(YELLOW)═══ Documentation ═══$(NC)"
	@echo "Documentation is in $(DOC_DIR)/"
	@test -d "$(DOC_DIR)" || { echo "NOT_RUN: no documentation directory"; exit 2; }; ls -la -- "$(DOC_DIR)/"

#---------------------------------------
# Info
#---------------------------------------

.PHONY: info
info: ## Display project information
	@printf 'Project: %s\nVersion: %s\n' "$(NAME)" "$(VERSION)"
	@plan=$$(mktemp); trap 'rm -f -- "$$plan"' EXIT; find "$(SRC_DIR)" -type f -name '*.sh' -print0 > "$$plan"; mapfile -d '' -t files < "$$plan"; \
	printf 'Scripts: %s\n' "$${#files[@]}"; printf '  %q\n' "$${files[@]}"

.PHONY: loc
loc: ## Count lines of Bash source
	@plan=$$(mktemp); trap 'rm -f -- "$$plan"' EXIT; find "$(SRC_DIR)" -type f -name '*.sh' -print0 > "$$plan"; mapfile -d '' -t files < "$$plan"; \
	[ $${#files[@]} -gt 0 ] || { echo 'NOT_RUN: no sources'; exit 2; }; wc -l -- "$${files[@]}"

#---------------------------------------
# Advanced development
#---------------------------------------

.PHONY: watch
watch: ## Monitor changes and run tests
	@echo "Monitoring changes (Ctrl+C to stop)..."
	@while true; do \
		inotifywait -q -r -e modify "$(SRC_DIR)" "$(TEST_DIR)"; \
		clear; \
		$(MAKE) test || echo "Tests failed; waiting for another change"; \
	done

.PHONY: debug
debug: ## Run main script with debug
	@echo -e "$(YELLOW)═══ Debug Mode ═══$(NC)"
	@bash -x "$(MAIN)" --help
```

---

## Code Conventions

### Standard Script Header

```bash
#!/bin/bash
#===============================================================================
# NAME: script_name.sh
# DESCRIPTION: Short description of what the script does
# AUTHOR: Name Surname
# VERSION: 1.0.0
# DATE: 2025-01-20
# LICENCE: Educational use - ASE CSIE OS
#===============================================================================

set -euo pipefail
IFS=$'\n\t'

# Constants
readonly SCRIPT_NAME="$(basename "$0")"
readonly SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
readonly VERSION="1.0.0"
```

### Naming Conventions

```text
# Local variables: snake_case
local user_name="student"
local file_count=0

# Global variables/constants: UPPER_SNAKE_CASE
readonly CONFIG_DIR="/etc/myapp"
declare -g VERBOSE=false

# Functions: snake_case with descriptive prefix
log_info() { ... }
validate_input() { ... }
process_file() { ... }

# Arrays: plural
declare -a files=()
declare -A config_options=()
```

### Comments

```bash
# Single line comment for short explanations

#---------------------------------------
# Major section - with separator
#---------------------------------------

# Function description:
# Arguments:
# $1 - First argument (mandatory)
# $2 - Second argument (optional, default: "value")
# Returns:
# 0 - success
# 1 - validation error
# Example:
# process_data "input.txt" "output.txt"
process_data() {
    local input="$1"
    local output="${2:-default.txt}"
    # ... implementation
}
```

---

## Recommended Patterns

### 1. Pattern: Library Sourcing

```bash
#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Source libraries
source "${SCRIPT_DIR}/lib/utils.sh"
source "${SCRIPT_DIR}/lib/logging.sh"
source "${SCRIPT_DIR}/lib/config.sh"

# Verify that functions exist
type log_info &>/dev/null || { echo "Error: logging.sh invalid"; exit 1; }
```

### 2. Pattern: Explicit Short and Long Options

```bash
# Explicit long/short parser; getopts alone does not implement --long options.
source /path/to/ENos/04_PROJECTS/helpers/teaching_patterns.sh
usage() { printf 'Usage: demo [-v|--verbose] [-c|--config FILE] [-o|--output DIR] [--] ARG...\n'; }
if parse_args "$@"; then
    printf 'Positional argument: %s\n' "${ARGS[@]}"
else
    status=$?
    [[ $status == 10 ]] && exit 0  # help requested
    exit "$status"
fi
```

### 3. Pattern: Cleanup on Exit

```bash
TEMP_DIR=''
cleanup() {
    local status=$?
    trap - EXIT
    if [[ -n $TEMP_DIR ]]; then rm -rf -- "$TEMP_DIR"; fi
    exit "$status"
}
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM
TEMP_DIR=$(mktemp -d) || exit 1
# Work only in this owned directory. SIGKILL cannot run traps.
```

### 4. Pattern: Lock File (Single Instance)

```bash
source /path/to/ENos/04_PROJECTS/helpers/teaching_patterns.sh
# Parent directory must be private/trusted and already exist.
LOCK_FILE=/path/to/owned/runtime/demo.lock
if ! acquire_lock; then printf 'Another instance or an unavailable lock\n' >&2; exit 1; fi
trap release_lock EXIT
# Work while LOCK_FD is held. No rejected instance unlinks another's lock.
```

### 5. Pattern: Configuration from File

```bash
source /path/to/ENos/04_PROJECTS/helpers/teaching_patterns.sh
load_config /path/to/config.conf || exit "$?"
printf '%s\n' "${CONFIG_MESSAGE:-default}"
# Grammar: uppercase KEY=value; blank/full-line comments; optional matching
# outer quotes. Preserve interior whitespace and =; no interpolation, escapes,
# inline comments or command execution. Duplicate/invalid keys are errors.
```

---

## Error Handling

### Handling Strategies

```bash
# Do not rely on errexit inside functions used as if/&&/|| conditions.
# Test each operation whose failure must stop later actions.
checked_copy() {
    cp -- "$1" "$2" || return "$?"
    printf 'Copy completed: %s\n' "$2"
}
if checked_copy "$source_file" "$destination_file"; then
    printf 'Continue after confirmed success\n'
else
    status=$?
    printf 'Copy failed with status %s\n' "$status" >&2
    exit "$status"
fi
```

### Descriptive Error Messages

```bash
die() {
    local message="$1"
    local code="${2:-1}"
    
    echo "ERROR [${SCRIPT_NAME}]: ${message}" >&2
    echo "  Line: ${BASH_LINENO[0]}" >&2
    echo "  Function: ${FUNCNAME[1]:-main}" >&2
    
    exit "$code"
}

# Usage:
[[ -f "$file" ]] || die "File does not exist: $file" 2
```

---

## Logging and Debugging

### Complete Logging System

```bash
source /path/to/ENos/04_PROJECTS/helpers/teaching_patterns.sh
LOG_LEVEL=INFO
log DEBUG 'Suppressed normally; still returns0'
log INFO 'Displayed on stderr'
# Unknown/empty levels return2. Do not place raw data in a printf format string.
```

### Debugging with set -x

```bash
# Selective activation for sections
debug_section() {
    set -x
    # Debugged code
    problematic_function
    set +x
}

# Or with environment variable
if [[ "${DEBUG:-false}" == "true" ]]; then
    set -x
fi
```

---

## Testing

### Simple Test Framework

```bash
#!/usr/bin/env bash
set -euo pipefail
source /path/to/ENos/04_PROJECTS/helpers/teaching_patterns.sh
# Expected failed assertions are guarded so the full report can finish.
assert_equals 'hello' 'hello' 'matching text' || true
assert_true 'one equals one' test 1 -eq 1 || true
print_summary
# assert_true receives an argument vector; it never evals condition text.
```

> 💡 *Personal note: Bash has ugly syntax, I admit. But it runs everywhere and that matters enormously in practice.*

---

## Performance

### Common Optimisations

```bash
# Slow: Subshell for each iteration
for file in *.txt; do
    count=$(wc -l < "$file")
    echo "$file: $count"
done

# Fast: Single command
wc -l *.txt

# Slow: Useless cat
cat file.txt | grep pattern

# Fast: Direct
grep pattern file.txt

# Slow: Loop for reading
while read line; do
    process "$line"
done < file.txt

# Fast (if possible): Block processing
awk '{process}' file.txt
```

> 💡 *`grep` is probably the command I use most often. Simple, fast, efficient.*

### Parallel Processing

```bash
# With xargs
find . -type f -name "*.log" -print0 | xargs -0 -r -P 4 -I {} process_log "{}"

# With GNU Parallel (if available)
parallel process_log ::: *.log

# With background jobs
pids=()
for file in *.txt; do
    [[ -f $file ]] || continue
    process_file "$file" &
    pids+=("$!")
done
failed=0
for pid in "${pids[@]}"; do wait "$pid" || failed=1; done
((failed == 0))  # Aggregate every owned child; bare wait loses individual errors.
```

---

## Security

### Input Validation

```bash
validate_path() {
    # Require an explicit root chosen by the caller. Resolve current symlinks.
    (( $# == 2 )) || { printf 'Usage: validate_path PATH ROOT\n' >&2; return 2; }
    python3 - "$1" "$2" <<'PY_PATH'
import pathlib, sys
value, root_text = sys.argv[1:]
if any(ord(c) < 32 or ord(c) == 127 for c in value + root_text):
    raise SystemExit("Control characters are outside this example's path grammar")
try:
    root = pathlib.Path(root_text).resolve(strict=True)
    if not root.is_dir(): raise ValueError("ROOT must be an existing directory")
    candidate = pathlib.Path(value)
    if not candidate.is_absolute(): candidate = root / candidate
    candidate = candidate.resolve(strict=False)
    candidate.relative_to(root)
except (OSError, ValueError, RuntimeError) as error:
    raise SystemExit(str(error))
print(candidate)
PY_PATH
}

validate_integer() {
    # Decimal values use Python integers, avoiding Bash octal and overflow rules.
    (( $# >= 1 && $# <= 3 )) || return 2
    python3 - "$1" "${2-}" "${3-}" <<'PY_INTEGER'
import re, sys
value, lower, upper = sys.argv[1:]
if any(text and not re.fullmatch(r"-?[0-9]+", text) for text in (value, lower, upper)) or not value:
    raise SystemExit(2)
try:
    value = int(value, 10)
    lower = int(lower, 10) if lower else None
    upper = int(upper, 10) if upper else None
except ValueError:
    raise SystemExit(2)
if lower is not None and upper is not None and lower > upper: raise SystemExit(2)
if lower is not None and value < lower: raise SystemExit(1)
if upper is not None and value > upper: raise SystemExit(1)
PY_INTEGER
}
```

`validate_path PATH ROOT` permits names such as `report..txt` and paths that
normalise inside the explicit root. It rejects resolved paths outside that root.
The check is a snapshot: concurrent symlink changes can still race a later open.
For adversarial writable trees, use descriptor-relative operations with an
appropriate no-follow policy. Integer validation returns 0 for an accepted
value, 1 outside the supplied range and 2 for malformed arguments. Neither
helper authorises a privileged operation.

### Injection Avoidance

```text
# Deliberately unsafe counterexamples and application-specific sketch:
eval "ls $user_input"

# Safe: Correct quoting
ls "$user_input"

# Dangerous: Command from input
$user_command

# Safe: Command whitelist
case "$user_command" in
    start|stop|status) execute_$user_command ;;
    *) die "Unknown command" ;;
esac
```

---

## War Stories

> Learning from others' mistakes is cheaper than making your own.

The following incidents are retained as historical author anecdotes; no underlying records were supplied to verify their dates, counts or causal claims.

### The Infinite Loop (2023)

A student's backup script ran `find / -name "*.sh"` without excluding `/proc`. The script ran for 3 hours and eventually crashed the VM.

**Lesson:** Always exclude virtual filesystems:
```bash
find / \( -path /proc -o -path /sys -o -path /dev \) -prune -o -type f -name '*.sh' -print
```

### The Permissions Disaster (2022)

Someone ran `chmod -R 777 /` instead of `chmod -R 777 ./`. They had to reinstall Ubuntu.

**Lesson:** ALWAYS test destructive commands with `echo` first:
```text
# Historical counterexample, not an execution recommendation:
# Preview what would happen
echo chmod -R 777 ./target

# Broad mode777 is not repaired merely by previewing it.
# Define the minimum required permission and exact owned path before any change.
```

### The Git Catastrophe (2024)

A student committed their `.env` file with the server password to a public repository. The password was harvested within hours.

**Lesson:** Always have a proper `.gitignore` BEFORE your first commit:
```bash
# First thing in any project
echo -e ".env\n*.secret\n*.key" > .gitignore
git add .gitignore
git commit -m "Add gitignore"
```

### The Fork Bomb (2021)

A student accidentally created a fork bomb while testing process management:
```text
:(){ :|:& };:  # DO NOT RUN THIS
```
The lab server crashed and affected 30 other students.

**Lesson:** Test process-heavy code in isolated containers or VMs, never on shared systems.

### The Midnight Submission (Every Semester)

At 23:58, two minutes before deadline, the upload system was overloaded. Three students failed to submit on time.

**Lesson:** Submit at least 2 hours before the deadline. You can always resubmit.

---

## Additional Resources

- **ShellCheck Wiki:** https://github.com/koalaman/shellcheck/wiki
- **Bash Pitfalls:** https://mywiki.wooledge.org/BashPitfalls
- **Google Shell Style Guide:** https://google.github.io/styleguide/shellguide.html
- **Advanced Bash Scripting Guide:** https://tldp.org/LDP/abs/html/

---

*Technical Guide - OS Projects | January 2025*

## Primary technical references

- [GNU Bash: set](https://www.gnu.org/software/bash/manual/html_node/The-Set-Builtin.html), including conditional errexit exceptions.
- [GNU findutils: directories and pruning](https://www.gnu.org/software/findutils/manual/html_node/find_html/Directories.html).
- [util-linux flock](https://man7.org/linux/man-pages/man1/flock.1.html), advisory descriptor locking.
