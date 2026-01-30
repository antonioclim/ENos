# ═══════════════════════════════════════════════════════════════════════════════
# Makefile - Seminar 02: Operators, Redirection, Filters, Loops
# ═══════════════════════════════════════════════════════════════════════════════
#
# Operating Systems | ASE Bucharest - CSIE
# Orchestration: quiz, tests, linting, validation
#
# USAGE:
#   make help     - Display this message
#   make quiz     - Run formative quiz interactively
#   make test     - Run all automated tests
#   make lint     - Check code quality (shellcheck + python)
#   make validate - Verify complete package structure
#   make clean    - Remove generated files
#   make all      - Run lint + test
#
# ═══════════════════════════════════════════════════════════════════════════════

.PHONY: help quiz test lint lint-bash lint-python validate clean all check-deps

# Colours for output
CYAN := \033[1;36m
GREEN := \033[1;32m
YELLOW := \033[1;33m
RED := \033[1;31m
RESET := \033[0m

# Directories
SCRIPTS_BASH := scripts/bash
SCRIPTS_DEMO := scripts/demo
SCRIPTS_PYTHON := scripts/python
FORMATIVE := formative
DOCS := docs
TESTS := tests

# ═══════════════════════════════════════════════════════════════════════════════
# TARGET: help (default)
# ═══════════════════════════════════════════════════════════════════════════════

help:
	@echo ""
	@echo "$(CYAN)═══════════════════════════════════════════════════════════════════$(RESET)"
	@echo "$(CYAN)  Makefile - Seminar 02 OS                                         $(RESET)"
	@echo "$(CYAN)═══════════════════════════════════════════════════════════════════$(RESET)"
	@echo ""
	@echo "$(GREEN)Available targets:$(RESET)"
	@echo ""
	@echo "  $(YELLOW)make quiz$(RESET)        - Run formative quiz interactively"
	@echo "  $(YELLOW)make test$(RESET)        - Run all automated tests"
	@echo "  $(YELLOW)make lint$(RESET)        - Check code quality"
	@echo "  $(YELLOW)make lint-bash$(RESET)   - Check only Bash scripts"
	@echo "  $(YELLOW)make lint-python$(RESET) - Check only Python scripts"
	@echo "  $(YELLOW)make validate$(RESET)    - Verify package structure"
	@echo "  $(YELLOW)make clean$(RESET)       - Remove generated files"
	@echo "  $(YELLOW)make all$(RESET)         - Run lint + test"
	@echo "  $(YELLOW)make check-deps$(RESET)  - Verify installed dependencies"
	@echo ""
	@echo "$(GREEN)Examples:$(RESET)"
	@echo "  make quiz              # Start interactive quiz"
	@echo "  make lint && make test # Check and test"
	@echo ""

# ═══════════════════════════════════════════════════════════════════════════════
# TARGET: quiz - Run formative quiz
# ═══════════════════════════════════════════════════════════════════════════════

quiz:
	@echo "$(CYAN)═══ Starting Formative Quiz ═══$(RESET)"
	@if [ -f "$(FORMATIVE)/quiz_runner.py" ] && [ -f "$(FORMATIVE)/quiz.yaml" ]; then \
		python3 $(FORMATIVE)/quiz_runner.py $(FORMATIVE)/quiz.yaml; \
	else \
		echo "$(RED)Error: Quiz files not found.$(RESET)"; \
		echo "Check: $(FORMATIVE)/quiz_runner.py and $(FORMATIVE)/quiz.yaml"; \
		exit 1; \
	fi

quiz-shuffle:
	@echo "$(CYAN)═══ Quiz with Shuffled Questions ═══$(RESET)"
	@python3 $(FORMATIVE)/quiz_runner.py --shuffle $(FORMATIVE)/quiz.yaml

quiz-short:
	@echo "$(CYAN)═══ Short Quiz (10 questions) ═══$(RESET)"
	@python3 $(FORMATIVE)/quiz_runner.py --limit 10 --shuffle $(FORMATIVE)/quiz.yaml

# ═══════════════════════════════════════════════════════════════════════════════
# TARGET: test - Run tests
# ═══════════════════════════════════════════════════════════════════════════════

test:
	@echo "$(CYAN)═══ Running Tests ═══$(RESET)"
	@if [ -f "$(TESTS)/run_all_tests.sh" ]; then \
		bash $(TESTS)/run_all_tests.sh; \
	else \
		echo "$(YELLOW)Warning: $(TESTS)/run_all_tests.sh not found.$(RESET)"; \
		echo "Running basic syntax checks..."; \
		for script in $(SCRIPTS_BASH)/*.sh $(SCRIPTS_DEMO)/*.sh; do \
			echo "Checking: $$script"; \
			bash -n "$$script" || exit 1; \
		done; \
		echo "$(GREEN)All scripts have valid syntax.$(RESET)"; \
	fi

test-validator:
	@echo "$(CYAN)═══ Test Assignment Validator ═══$(RESET)"
	@if [ -f "$(SCRIPTS_BASH)/S02_03_validator.sh" ]; then \
		bash $(SCRIPTS_BASH)/S02_03_validator.sh --help; \
	fi

test-unit:
	@echo "$(CYAN)═══ Running Unit Tests ═══$(RESET)"
	@if [ -f "$(TESTS)/test_autograder.py" ]; then \
		python3 -m pytest $(TESTS)/test_autograder.py -v || python3 $(TESTS)/test_autograder.py; \
	else \
		echo "$(YELLOW)No unit tests found.$(RESET)"; \
	fi

# ═══════════════════════════════════════════════════════════════════════════════
# TARGET: lint - Code quality checks
# ═══════════════════════════════════════════════════════════════════════════════

lint: lint-bash lint-python
	@echo "$(GREEN)═══ Linting Complete ═══$(RESET)"

lint-bash:
	@echo "$(CYAN)═══ Bash Linting (shellcheck) ═══$(RESET)"
	@if command -v shellcheck > /dev/null 2>&1; then \
		echo "Checking $(SCRIPTS_BASH)/*.sh ..."; \
		shellcheck --severity=warning $(SCRIPTS_BASH)/*.sh 2>/dev/null || true; \
		echo "Checking $(SCRIPTS_DEMO)/*.sh ..."; \
		shellcheck --severity=warning $(SCRIPTS_DEMO)/*.sh 2>/dev/null || true; \
		echo "$(GREEN)Bash linting complete.$(RESET)"; \
	else \
		echo "$(YELLOW)Warning: shellcheck not installed.$(RESET)"; \
		echo "Install with: sudo apt install shellcheck"; \
		echo "Running basic syntax check..."; \
		for script in $(SCRIPTS_BASH)/*.sh $(SCRIPTS_DEMO)/*.sh; do \
			bash -n "$$script" 2>/dev/null || echo "$(RED)Error in: $$script$(RESET)"; \
		done; \
	fi

lint-python:
	@echo "$(CYAN)═══ Python Linting ═══$(RESET)"
	@echo "Checking Python syntax..."
	@for pyfile in $(SCRIPTS_PYTHON)/*.py $(FORMATIVE)/*.py; do \
		if [ -f "$$pyfile" ]; then \
			python3 -m py_compile "$$pyfile" 2>/dev/null && \
				echo "  $(GREEN)✓$(RESET) $$pyfile" || \
				echo "  $(RED)✗$(RESET) $$pyfile"; \
		fi; \
	done
	@if command -v ruff > /dev/null 2>&1; then \
		echo "Running ruff..."; \
		ruff check $(SCRIPTS_PYTHON)/ $(FORMATIVE)/ 2>/dev/null || true; \
	elif command -v flake8 > /dev/null 2>&1; then \
		echo "Running flake8..."; \
		flake8 --max-line-length=100 $(SCRIPTS_PYTHON)/ $(FORMATIVE)/ 2>/dev/null || true; \
	else \
		echo "$(YELLOW)Note: ruff/flake8 not installed (optional).$(RESET)"; \
	fi
	@echo "$(GREEN)Python linting complete.$(RESET)"

# ═══════════════════════════════════════════════════════════════════════════════
# TARGET: validate - Package structure validation
# ═══════════════════════════════════════════════════════════════════════════════

validate:
	@echo "$(CYAN)═══ Package Structure Validation ═══$(RESET)"
	@echo ""
	@echo "$(YELLOW)Required files:$(RESET)"
	@MISSING=0; \
	for f in \
		"README.md" \
		"$(DOCS)/S02_00_PEDAGOGICAL_ANALYSIS_PLAN.md" \
		"$(DOCS)/S02_01_INSTRUCTOR_GUIDE.md" \
		"$(DOCS)/S02_02_MAIN_MATERIAL.md" \
		"$(DOCS)/S02_03_PEER_INSTRUCTION.md" \
		"$(DOCS)/S02_04_PARSONS_PROBLEMS.md" \
		"$(DOCS)/S02_05_LIVE_CODING_GUIDE.md" \
		"$(DOCS)/S02_06_SPRINT_EXERCISES.md" \
		"$(DOCS)/S02_07_LLM_AWARE_EXERCISES.md" \
		"$(DOCS)/S02_08_SPECTACULAR_DEMOS.md" \
		"$(DOCS)/S02_09_VISUAL_CHEAT_SHEET.md" \
		"$(DOCS)/S02_10_SELF_ASSESSMENT_REFLECTION.md" \
		"$(DOCS)/lo_traceability.md" \
		"$(SCRIPTS_BASH)/S02_01_setup_seminar.sh" \
		"$(SCRIPTS_BASH)/S02_02_interactive_quiz.sh" \
		"$(SCRIPTS_BASH)/S02_03_validator.sh" \
		"$(SCRIPTS_PYTHON)/S02_01_autograder.py" \
		"$(SCRIPTS_PYTHON)/S02_02_quiz_generator.py" \
		"$(SCRIPTS_PYTHON)/S02_03_report_generator.py" \
	; do \
		if [ -f "$$f" ]; then \
			echo "  $(GREEN)✓$(RESET) $$f"; \
		else \
			echo "  $(RED)✗$(RESET) $$f (MISSING)"; \
			MISSING=$$((MISSING + 1)); \
		fi; \
	done; \
	echo ""; \
	echo "$(YELLOW)CI/CD files (optional but recommended):$(RESET)"; \
	for f in \
		"$(FORMATIVE)/quiz.yaml" \
		"$(FORMATIVE)/quiz_lms.json" \
		"$(FORMATIVE)/quiz_runner.py" \
		"Makefile" \
		"requirements.txt" \
		"ci/github_actions.yml" \
		"ci/linting.toml" \
	; do \
		if [ -f "$$f" ]; then \
			echo "  $(GREEN)✓$(RESET) $$f"; \
		else \
			echo "  $(YELLOW)○$(RESET) $$f (optional)"; \
		fi; \
	done; \
	echo ""; \
	if [ $$MISSING -eq 0 ]; then \
		echo "$(GREEN)═══ Structure Valid ═══$(RESET)"; \
	else \
		echo "$(RED)═══ $$MISSING file(s) missing ═══$(RESET)"; \
		exit 1; \
	fi

# ═══════════════════════════════════════════════════════════════════════════════
# TARGET: check-deps - Dependency verification
# ═══════════════════════════════════════════════════════════════════════════════

check-deps:
	@echo "$(CYAN)═══ Dependency Check ═══$(RESET)"
	@echo ""
	@echo "$(YELLOW)Required:$(RESET)"
	@command -v bash > /dev/null && echo "  $(GREEN)✓$(RESET) bash" || echo "  $(RED)✗$(RESET) bash"
	@command -v python3 > /dev/null && echo "  $(GREEN)✓$(RESET) python3" || echo "  $(RED)✗$(RESET) python3"
	@echo ""
	@echo "$(YELLOW)Recommended:$(RESET)"
	@command -v shellcheck > /dev/null && echo "  $(GREEN)✓$(RESET) shellcheck" || echo "  $(YELLOW)○$(RESET) shellcheck (sudo apt install shellcheck)"
	@command -v ruff > /dev/null && echo "  $(GREEN)✓$(RESET) ruff" || echo "  $(YELLOW)○$(RESET) ruff (pip install ruff)"
	@command -v pytest > /dev/null && echo "  $(GREEN)✓$(RESET) pytest" || echo "  $(YELLOW)○$(RESET) pytest (pip install pytest)"
	@echo ""
	@echo "$(YELLOW)Python modules:$(RESET)"
	@python3 -c "import yaml" 2>/dev/null && echo "  $(GREEN)✓$(RESET) pyyaml" || echo "  $(YELLOW)○$(RESET) pyyaml (pip install pyyaml)"
	@python3 -c "import pytest" 2>/dev/null && echo "  $(GREEN)✓$(RESET) pytest" || echo "  $(YELLOW)○$(RESET) pytest (pip install pytest)"
	@echo ""

# ═══════════════════════════════════════════════════════════════════════════════
# TARGET: clean - Remove generated files
# ═══════════════════════════════════════════════════════════════════════════════

clean:
	@echo "$(CYAN)═══ Cleaning ═══$(RESET)"
	@echo "Removing temporary files..."
	@rm -rf __pycache__ */__pycache__ */*/__pycache__
	@rm -f *.pyc */*.pyc */*/*.pyc
	@rm -f *.log *.tmp
	@rm -f quiz_results_*.json
	@rm -rf .pytest_cache */.pytest_cache
	@rm -rf .coverage htmlcov
	@echo "$(GREEN)Cleanup complete.$(RESET)"

# ═══════════════════════════════════════════════════════════════════════════════
# TARGET: all - Run everything
# ═══════════════════════════════════════════════════════════════════════════════

all: lint test
	@echo "$(GREEN)═══ All Checks Complete ═══$(RESET)"

# ═══════════════════════════════════════════════════════════════════════════════
# END
# ═══════════════════════════════════════════════════════════════════════════════
