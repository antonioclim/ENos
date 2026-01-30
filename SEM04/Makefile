# ═══════════════════════════════════════════════════════════════════════════════
# Makefile — Seminar 04: Text Processing
# ═══════════════════════════════════════════════════════════════════════════════
# Operating Systems | ASE Bucharest — CSIE
# Author: ing. dr. Antonio Clim
# Version: 1.2 — Standardised EN paths
# ═══════════════════════════════════════════════════════════════════════════════

.PHONY: help setup quiz test lint clean demo all check-deps generate-data verify

# Variables
SHELL := /bin/bash
PYTHON := python3
SHELLCHECK := shellcheck
SEMINAR := 04

# Directories (UPDATED: EN naming)
SCRIPTS_BASH := scripts/bash
SCRIPTS_DEMO := scripts/demo
SCRIPTS_PYTHON := scripts/python
FORMATIVE := formative
TESTS := tests
HOMEWORK_SOL := homework/solutions
RESOURCES := resources

# Colours for output
GREEN := \033[0;32m
YELLOW := \033[0;33m
RED := \033[0;31m
CYAN := \033[0;36m
NC := \033[0m

# ═══════════════════════════════════════════════════════════════════════════════
# MAIN TARGETS
# ═══════════════════════════════════════════════════════════════════════════════

help: ## Display this help message
	@echo ""
	@echo "╔════════════════════════════════════════════════════════════════════╗"
	@echo "║  Makefile — Seminar $(SEMINAR): Text Processing                        ║"
	@echo "║  Version 1.2 — Standardised EN paths                               ║"
	@echo "╠════════════════════════════════════════════════════════════════════╣"
	@echo "║  Available targets:                                                ║"
	@echo "╚════════════════════════════════════════════════════════════════════╝"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-18s$(NC) %s\n", $$1, $$2}'
	@echo ""

all: check-deps lint test ## Run lint and complete tests
	@echo -e "$(GREEN)✓ All checks passed$(NC)"

# ═══════════════════════════════════════════════════════════════════════════════
# SETUP AND DEPENDENCIES
# ═══════════════════════════════════════════════════════════════════════════════

check-deps: ## Check required dependencies
	@echo "Checking dependencies..."
	@command -v $(PYTHON) >/dev/null 2>&1 || { echo -e "$(RED)✗ Python3 missing$(NC)"; exit 1; }
	@command -v $(SHELLCHECK) >/dev/null 2>&1 || echo -e "$(YELLOW)⚠ shellcheck missing (optional)$(NC)"
	@$(PYTHON) -c "import yaml" 2>/dev/null || echo -e "$(YELLOW)⚠ pyyaml missing: pip install pyyaml$(NC)"
	@echo -e "$(GREEN)✓ Dependency check complete$(NC)"

setup: ## Configure the working environment for seminar
	@echo "Configuring seminar environment..."
	@bash $(SCRIPTS_BASH)/S$(SEMINAR)_01_setup_seminar.sh
	@echo -e "$(GREEN)✓ Setup complete$(NC)"

install-deps: ## Install Python dependencies
	@echo "Installing Python dependencies..."
	@$(PYTHON) -m pip install -r requirements.txt --break-system-packages 2>/dev/null || \
		$(PYTHON) -m pip install -r requirements.txt
	@echo -e "$(GREEN)✓ Dependencies installed$(NC)"

# ═══════════════════════════════════════════════════════════════════════════════
# ANTI-PLAGIARISM: PERSONALISED DATA GENERATION
# ═══════════════════════════════════════════════════════════════════════════════

generate-data: ## Generate personalised test data (usage: make generate-data ID=123456)
ifndef ID
	@echo -e "$(RED)Error: Student ID required$(NC)"
	@echo "Usage: make generate-data ID=<matricol>"
	@echo "Example: make generate-data ID=123456"
	@exit 1
endif
	@echo -e "$(CYAN)Generating personalised data for student $(ID)...$(NC)"
	@$(PYTHON) $(SCRIPTS_PYTHON)/S$(SEMINAR)_04_personalized_data_generator.py $(ID)
	@echo -e "$(GREEN)✓ Data generated in student_$(ID)/$(NC)"

verify-checksum: ## Verify student submission checksum (usage: make verify-checksum ID=123456 SUM=abc123)
ifndef ID
	@echo -e "$(RED)Error: Student ID required$(NC)"
	@exit 1
endif
ifndef SUM
	@echo -e "$(RED)Error: Checksum required$(NC)"
	@exit 1
endif
	@$(PYTHON) $(SCRIPTS_PYTHON)/S$(SEMINAR)_04_personalized_data_generator.py --verify $(ID) $(SUM)

# ═══════════════════════════════════════════════════════════════════════════════
# QUIZ AND ASSESSMENT
# ═══════════════════════════════════════════════════════════════════════════════

quiz: ## Run the interactive formative quiz
	@echo "Launching formative quiz..."
	@$(PYTHON) $(FORMATIVE)/quiz_runner.py $(FORMATIVE)/quiz.yaml

quiz-shuffle: ## Run the quiz with shuffled questions
	@$(PYTHON) $(FORMATIVE)/quiz_runner.py $(FORMATIVE)/quiz.yaml --shuffle

quiz-category: ## Run quiz for a Bloom category (e.g.: make quiz-category CAT=understand)
	@$(PYTHON) $(FORMATIVE)/quiz_runner.py $(FORMATIVE)/quiz.yaml --category $(CAT)

quiz-test: ## Verify quiz integrity (self-test)
	@echo "Checking quiz integrity..."
	@$(PYTHON) $(FORMATIVE)/quiz_runner.py --self-test
	@echo -e "$(GREEN)✓ Quiz valid$(NC)"

# ═══════════════════════════════════════════════════════════════════════════════
# TESTS
# ═══════════════════════════════════════════════════════════════════════════════

test: ## Run all automated tests
	@echo "Running automated tests..."
	@bash $(TESTS)/run_all_tests.sh
	@echo -e "$(GREEN)✓ All tests passed$(NC)"

test-regex: ## Run only regex tests
	@bash $(TESTS)/test_01_regex_basics.sh

test-grep: ## Run only grep tests
	@bash $(TESTS)/test_02_grep_mastery.sh

test-sed: ## Run only sed tests
	@bash $(TESTS)/test_03_sed_transforms.sh

test-awk: ## Run only awk tests
	@bash $(TESTS)/test_04_awk_analysis.sh

# ═══════════════════════════════════════════════════════════════════════════════
# LINTING AND CODE QUALITY
# ═══════════════════════════════════════════════════════════════════════════════

lint: lint-bash lint-python ## Run all linting checks
	@echo -e "$(GREEN)✓ Linting complete$(NC)"

lint-bash: ## Check Bash scripts with shellcheck
	@echo "Checking Bash scripts..."
	@if command -v $(SHELLCHECK) >/dev/null 2>&1; then \
		$(SHELLCHECK) --severity=warning $(SCRIPTS_BASH)/*.sh $(SCRIPTS_DEMO)/*.sh $(HOMEWORK_SOL)/*.sh 2>/dev/null || true; \
		echo -e "$(GREEN)✓ Bash lint complete$(NC)"; \
	else \
		echo -e "$(YELLOW)⚠ shellcheck not installed, manual check required:$(NC)"; \
		echo "  sudo apt install shellcheck"; \
	fi

lint-python: ## Check Python scripts with ruff/flake8
	@echo "Checking Python scripts..."
	@if command -v ruff >/dev/null 2>&1; then \
		ruff check $(SCRIPTS_PYTHON)/*.py $(FORMATIVE)/*.py 2>/dev/null || true; \
	elif command -v flake8 >/dev/null 2>&1; then \
		flake8 $(SCRIPTS_PYTHON)/*.py $(FORMATIVE)/*.py --max-line-length=100 2>/dev/null || true; \
	else \
		echo -e "$(YELLOW)⚠ ruff/flake8 not installed$(NC)"; \
		$(PYTHON) -m py_compile $(SCRIPTS_PYTHON)/*.py $(FORMATIVE)/*.py && \
		echo -e "$(GREEN)✓ Python syntax valid$(NC)"; \
	fi

lint-yaml: ## Check YAML files
	@echo "Checking YAML files..."
	@$(PYTHON) -c "import yaml; yaml.safe_load(open('$(FORMATIVE)/quiz.yaml'))" && \
		echo -e "$(GREEN)✓ quiz.yaml valid$(NC)"

# ═══════════════════════════════════════════════════════════════════════════════
# DEMOS
# ═══════════════════════════════════════════════════════════════════════════════

demo: ## Launch the interactive demos menu
	@echo "Available demos:"
	@echo "  1. make demo-regex"
	@echo "  2. make demo-grep"
	@echo "  3. make demo-sed"
	@echo "  4. make demo-awk"
	@echo "  5. make demo-hook"

demo-hook: ## Run hook demo (attention capture)
	@bash $(SCRIPTS_DEMO)/S$(SEMINAR)_01_hook_demo.sh

demo-regex: ## Run regular expressions demo
	@bash $(SCRIPTS_DEMO)/S$(SEMINAR)_02_demo_regex.sh

demo-grep: ## Run grep demo
	@bash $(SCRIPTS_DEMO)/S$(SEMINAR)_03_demo_grep.sh

demo-sed: ## Run sed demo
	@bash $(SCRIPTS_DEMO)/S$(SEMINAR)_04_demo_sed.sh

demo-awk: ## Run awk demo
	@bash $(SCRIPTS_DEMO)/S$(SEMINAR)_05_demo_awk.sh

# ═══════════════════════════════════════════════════════════════════════════════
# CLEANUP
# ═══════════════════════════════════════════════════════════════════════════════

clean: ## Delete temporary and generated files
	@echo "Cleaning temporary files..."
	@rm -f *.log *.tmp *.bak *~
	@rm -rf __pycache__ .pytest_cache .ruff_cache
	@rm -f $(SCRIPTS_PYTHON)/__pycache__/*.pyc 2>/dev/null || true
	@rm -f $(FORMATIVE)/__pycache__/*.pyc 2>/dev/null || true
	@echo -e "$(GREEN)✓ Cleanup complete$(NC)"

clean-all: clean ## Complete cleanup including generated data
	@rm -rf ~/demo_sem4 student_* instructor_answers 2>/dev/null || true
	@echo -e "$(GREEN)✓ Complete cleanup (including demo and student data)$(NC)"

# ═══════════════════════════════════════════════════════════════════════════════
# UTILITIES
# ═══════════════════════════════════════════════════════════════════════════════

validate: ## Validate the complete seminar structure
	@echo "Validating seminar structure..."
	@bash $(SCRIPTS_BASH)/S$(SEMINAR)_03_validator.sh || true
	@echo -e "$(GREEN)✓ Validation complete$(NC)"

stats: ## Display statistics about materials
	@echo ""
	@echo "═══════════════════════════════════════════════════════════════"
	@echo "  SEMINAR $(SEMINAR) STATISTICS"
	@echo "═══════════════════════════════════════════════════════════════"
	@echo ""
	@echo "Markdown files:"
	@find . -name "*.md" | wc -l
	@echo ""
	@echo "Bash scripts:"
	@find . -name "*.sh" | wc -l
	@echo ""
	@echo "Python scripts:"
	@find . -name "*.py" | wc -l
	@echo ""
	@echo "Total lines of code:"
	@find . \( -name "*.sh" -o -name "*.py" -o -name "*.md" \) -exec cat {} + | wc -l
	@echo ""

structure: ## Display folder structure
	@echo ""
	@echo "SEM04 Structure (EN standardised):"
	@echo "─────────────────────────────────"
	@find . -type d -not -path '*/\.*' -not -path './__pycache__*' | sort | head -20
	@echo ""

# ═══════════════════════════════════════════════════════════════════════════════
# END
# ═══════════════════════════════════════════════════════════════════════════════

# ─────────────────────────────────────────────────────────────────────────────
# PLAGIARISM DETECTION
# ─────────────────────────────────────────────────────────────────────────────

.PHONY: check-plagiarism
check-plagiarism: ## Check submissions for similarity
	@echo "Running similarity analysis..."
	@python3 scripts/python/S04_05_similarity_checker.py ./submissions/
