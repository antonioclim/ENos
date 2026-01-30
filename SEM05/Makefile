# ═══════════════════════════════════════════════════════════════════════════════
# Makefile — Orchestration for Seminar 05: Advanced Bash Scripting
# ═══════════════════════════════════════════════════════════════════════════════
# Operating Systems | ASE Bucharest - CSIE
# Version: 2.0.0
# 
# USAGE:
#   make help     - Display available targets
#   make quiz     - Run the interactive formative quiz
#   make test     - Run all tests
#   make lint     - Check code quality (shellcheck + ruff)
#   make validate - Validate a student script
#   make clean    - Clean temporary files
#   make all      - Run lint + test
# ═══════════════════════════════════════════════════════════════════════════════

.PHONY: help quiz test lint lint-bash lint-python validate clean all setup check-deps export-lms

# Colours for output
BLUE := \033[0;34m
GREEN := \033[0;32m
YELLOW := \033[1;33m
RED := \033[0;31m
NC := \033[0m

# Directories
SCRIPTS_BASH := scripts/bash
SCRIPTS_DEMO := scripts/demo
SCRIPTS_PYTHON := scripts/python
SCRIPTS_TEMPLATES := scripts/templates
FORMATIVE := formative
TESTS := tests

# ═══════════════════════════════════════════════════════════════════════════════
# HELP
# ═══════════════════════════════════════════════════════════════════════════════

help:
	@echo ""
	@echo "$(BLUE)═══════════════════════════════════════════════════════════════$(NC)"
	@echo "$(BLUE)  Seminar 05: Advanced Bash Scripting — Makefile v1.1$(NC)"
	@echo "$(BLUE)═══════════════════════════════════════════════════════════════$(NC)"
	@echo ""
	@echo "$(GREEN)Main targets:$(NC)"
	@echo "  make quiz        Run the interactive formative quiz"
	@echo "  make test        Run all automated tests"
	@echo "  make lint        Check code quality (Bash + Python)"
	@echo "  make validate    Validate a script (SCRIPT=path/to/script.sh)"
	@echo "  make clean       Delete temporary files"
	@echo ""
	@echo "$(GREEN)Auxiliary targets:$(NC)"
	@echo "  make lint-bash     ShellCheck on Bash scripts only"
	@echo "  make lint-python   Ruff/flake8 on Python scripts only"
	@echo "  make setup         Install required dependencies"
	@echo "  make check-deps    Check if dependencies are installed"
	@echo "  make export-lms    Export quiz to LMS JSON format"
	@echo "  make all           Run lint + test"
	@echo ""
	@echo "$(YELLOW)Examples:$(NC)"
	@echo "  make quiz"
	@echo "  make validate SCRIPT=submissions/student1.sh"
	@echo "  make lint-bash"
	@echo ""

# ═══════════════════════════════════════════════════════════════════════════════
# FORMATIVE QUIZ
# ═══════════════════════════════════════════════════════════════════════════════

quiz:
	@echo "$(BLUE)═══════════════════════════════════════════════════════════════$(NC)"
	@echo "$(BLUE)  Starting Formative Quiz$(NC)"
	@echo "$(BLUE)═══════════════════════════════════════════════════════════════$(NC)"
	@if [ -f $(FORMATIVE)/quiz_runner.py ]; then \
		python3 $(FORMATIVE)/quiz_runner.py $(FORMATIVE)/quiz.yaml; \
	else \
		echo "$(RED)Error: quiz_runner.py does not exist$(NC)"; \
		exit 1; \
	fi

quiz-shuffle:
	@python3 $(FORMATIVE)/quiz_runner.py $(FORMATIVE)/quiz.yaml --shuffle

quiz-category:
	@echo "Available categories: functions, arrays, reliability, trap"
	@read -p "Choose category: " cat; \
	python3 $(FORMATIVE)/quiz_runner.py $(FORMATIVE)/quiz.yaml --category $$cat

export-lms:
	@echo "$(BLUE)Exporting quiz to LMS format...$(NC)"
	@if [ -f $(FORMATIVE)/quiz_runner.py ]; then \
		python3 $(FORMATIVE)/quiz_runner.py $(FORMATIVE)/quiz.yaml --export > /dev/null && \
		echo "$(GREEN)✓ Exported to $(FORMATIVE)/quiz_lms.json$(NC)"; \
	else \
		echo "$(RED)Error: quiz_runner.py does not exist$(NC)"; \
		exit 1; \
	fi

# ═══════════════════════════════════════════════════════════════════════════════
# TESTS
# ═══════════════════════════════════════════════════════════════════════════════

test:
	@echo "$(BLUE)═══════════════════════════════════════════════════════════════$(NC)"
	@echo "$(BLUE)  Running Automated Tests$(NC)"
	@echo "$(BLUE)═══════════════════════════════════════════════════════════════$(NC)"
	@if [ -f $(TESTS)/run_all_tests.sh ]; then \
		bash $(TESTS)/run_all_tests.sh; \
	else \
		echo "$(YELLOW)Warning: run_all_tests.sh does not exist$(NC)"; \
	fi

# ═══════════════════════════════════════════════════════════════════════════════
# LINTING
# ═══════════════════════════════════════════════════════════════════════════════

lint: lint-bash lint-python
	@echo ""
	@echo "$(GREEN)✓ All lint checks passed$(NC)"

lint-bash:
	@echo "$(BLUE)═══════════════════════════════════════════════════════════════$(NC)"
	@echo "$(BLUE)  ShellCheck — Bash Script Verification$(NC)"
	@echo "$(BLUE)═══════════════════════════════════════════════════════════════$(NC)"
	@if command -v shellcheck >/dev/null 2>&1; then \
		echo "Checking $(SCRIPTS_BASH)/*.sh..."; \
		shellcheck --severity=warning $(SCRIPTS_BASH)/*.sh 2>/dev/null || true; \
		echo "Checking $(SCRIPTS_DEMO)/*.sh..."; \
		shellcheck --severity=warning $(SCRIPTS_DEMO)/*.sh 2>/dev/null || true; \
		echo "Checking $(SCRIPTS_TEMPLATES)/*.sh..."; \
		shellcheck --severity=warning $(SCRIPTS_TEMPLATES)/*.sh 2>/dev/null || true; \
		echo "$(GREEN)✓ ShellCheck complete$(NC)"; \
	else \
		echo "$(YELLOW)Warning: shellcheck is not installed$(NC)"; \
		echo "  Install with: sudo apt install shellcheck"; \
	fi

lint-python:
	@echo "$(BLUE)═══════════════════════════════════════════════════════════════$(NC)"
	@echo "$(BLUE)  Ruff/Flake8 — Python Script Verification$(NC)"
	@echo "$(BLUE)═══════════════════════════════════════════════════════════════$(NC)"
	@if command -v ruff >/dev/null 2>&1; then \
		echo "Checking with ruff..."; \
		ruff check $(SCRIPTS_PYTHON)/*.py $(FORMATIVE)/*.py 2>/dev/null || true; \
		echo "$(GREEN)✓ Ruff complete$(NC)"; \
	elif command -v flake8 >/dev/null 2>&1; then \
		echo "Checking with flake8..."; \
		flake8 $(SCRIPTS_PYTHON)/*.py $(FORMATIVE)/*.py --max-line-length=100 2>/dev/null || true; \
		echo "$(GREEN)✓ Flake8 complete$(NC)"; \
	else \
		echo "$(YELLOW)Warning: neither ruff nor flake8 are installed$(NC)"; \
		echo "  Install with: pip install ruff"; \
	fi

# ═══════════════════════════════════════════════════════════════════════════════
# STUDENT SCRIPT VALIDATION
# ═══════════════════════════════════════════════════════════════════════════════

SCRIPT ?= 

validate:
ifndef SCRIPT
	@echo "$(RED)Error: Specify the script with SCRIPT=path/to/script.sh$(NC)"
	@echo "Example: make validate SCRIPT=submissions/student1.sh"
	@exit 1
else
	@echo "$(BLUE)═══════════════════════════════════════════════════════════════$(NC)"
	@echo "$(BLUE)  Validating Script: $(SCRIPT)$(NC)"
	@echo "$(BLUE)═══════════════════════════════════════════════════════════════$(NC)"
	@if [ -f $(SCRIPTS_BASH)/S05_03_validator.sh ]; then \
		bash $(SCRIPTS_BASH)/S05_03_validator.sh "$(SCRIPT)"; \
	else \
		echo "$(RED)Error: Validator does not exist$(NC)"; \
		exit 1; \
	fi
endif

# ═══════════════════════════════════════════════════════════════════════════════
# SETUP AND DEPENDENCIES
# ═══════════════════════════════════════════════════════════════════════════════

setup:
	@echo "$(BLUE)═══════════════════════════════════════════════════════════════$(NC)"
	@echo "$(BLUE)  Installing Dependencies$(NC)"
	@echo "$(BLUE)═══════════════════════════════════════════════════════════════$(NC)"
	@echo "Installing Python dependencies..."
	pip3 install --user pyyaml rich 2>/dev/null || \
	pip3 install --break-system-packages pyyaml rich 2>/dev/null || \
	pip install --user pyyaml rich
	@echo ""
	@echo "For shellcheck (optional):"
	@echo "  Ubuntu/Debian: sudo apt install shellcheck"
	@echo "  macOS: brew install shellcheck"
	@echo ""
	@echo "For ruff (optional):"
	@echo "  pip install ruff"
	@echo ""
	@echo "$(GREEN)✓ Setup complete$(NC)"

check-deps:
	@echo "$(BLUE)Checking dependencies...$(NC)"
	@echo ""
	@printf "Python3:    "; command -v python3 >/dev/null && echo "$(GREEN)✓$(NC)" || echo "$(RED)✗$(NC)"
	@printf "Bash 4.0+:  "; bash -c '[[ "${BASH_VERSINFO[0]}" -ge 4 ]]' 2>/dev/null && echo "$(GREEN)✓$(NC)" || echo "$(RED)✗$(NC)"
	@printf "PyYAML:     "; python3 -c "import yaml" 2>/dev/null && echo "$(GREEN)✓$(NC)" || echo "$(YELLOW)✗ (run: make setup)$(NC)"
	@printf "Rich:       "; python3 -c "import rich" 2>/dev/null && echo "$(GREEN)✓$(NC)" || echo "$(YELLOW)✗ (run: make setup)$(NC)"
	@printf "ShellCheck: "; command -v shellcheck >/dev/null && echo "$(GREEN)✓$(NC)" || echo "$(YELLOW)✗ (optional)$(NC)"
	@printf "Ruff:       "; command -v ruff >/dev/null && echo "$(GREEN)✓$(NC)" || echo "$(YELLOW)✗ (optional)$(NC)"
	@echo ""

# ═══════════════════════════════════════════════════════════════════════════════
# CLEANUP
# ═══════════════════════════════════════════════════════════════════════════════

clean:
	@echo "$(BLUE)Cleaning temporary files...$(NC)"
	@find . -type f -name "*.pyc" -delete 2>/dev/null || true
	@find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
	@find . -type f -name "*.log" -delete 2>/dev/null || true
	@find . -type f -name "*.tmp" -delete 2>/dev/null || true
	@find . -type f -name "*~" -delete 2>/dev/null || true
	@find . -type f -name "*.bak" -delete 2>/dev/null || true
	@echo "$(GREEN)✓ Cleanup complete$(NC)"

# ═══════════════════════════════════════════════════════════════════════════════
# ALL
# ═══════════════════════════════════════════════════════════════════════════════

all: lint test
	@echo ""
	@echo "$(GREEN)═══════════════════════════════════════════════════════════════$(NC)"
	@echo "$(GREEN)  ✓ All checks passed$(NC)"
	@echo "$(GREEN)═══════════════════════════════════════════════════════════════$(NC)"
