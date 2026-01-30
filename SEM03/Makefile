# ═══════════════════════════════════════════════════════════════════════════════
# Makefile — Seminar 03: System Administration
# Operating Systems | Bucharest UES - CSIE
# ═══════════════════════════════════════════════════════════════════════════════
# Usage: make [target]
# Main targets: setup, quiz, test, lint, clean, all
# Issues: Open an issue in GitHub
# ═══════════════════════════════════════════════════════════════════════════════

.PHONY: help setup quiz quiz-json test lint lint-bash lint-python clean all check-deps validate

# Variables
SHELL := /bin/bash
PYTHON := python3
SHELLCHECK := shellcheck
RUFF := ruff

# Directories (ENos naming convention)
SCRIPTS_BASH := scripts/bash
SCRIPTS_DEMO := scripts/demo
SCRIPTS_PYTHON := scripts/python
FORMATIVE := formative
TESTS := tests
HOMEWORK := homework
PRESENTATIONS := presentations

# ═══════════════════════════════════════════════════════════════════════════════
# MAIN TARGET: help
# ═══════════════════════════════════════════════════════════════════════════════

help:
	@echo "═══════════════════════════════════════════════════════════════════════════════"
	@echo "  Makefile — Seminar 03: System Administration"
	@echo "═══════════════════════════════════════════════════════════════════════════════"
	@echo ""
	@echo "Available targets:"
	@echo ""
	@echo "  setup       - Prepare the working environment for seminar"
	@echo "  quiz        - Run the interactive formative quiz (YAML)"
	@echo "  quiz-json   - Validate and display the quiz in JSON format"
	@echo "  test        - Run all automated tests"
	@echo "  lint        - Check code quality (Bash + Python)"
	@echo "  lint-bash   - Check only Bash scripts with shellcheck"
	@echo "  lint-python - Check only Python scripts with ruff"
	@echo "  validate    - Validate complete seminar structure"
	@echo "  clean       - Delete temporary files and cache"
	@echo "  all         - Run: lint → test → validate"
	@echo "  check-deps  - Check installed dependencies"
	@echo ""
	@echo "Examples:"
	@echo "  make setup      # Prepare environment before seminar"
	@echo "  make lint test  # Check code and run tests"
	@echo "  make all        # Complete verification"
	@echo ""

# ═══════════════════════════════════════════════════════════════════════════════
# SETUP
# ═══════════════════════════════════════════════════════════════════════════════

setup:
	@echo "═══ Setup Seminar 03 ═══"
	@if [ -f "$(SCRIPTS_BASH)/S03_01_setup_seminar.sh" ]; then \
		bash "$(SCRIPTS_BASH)/S03_01_setup_seminar.sh"; \
	else \
		echo "Warning: Setup script does not exist"; \
	fi
	@echo "Setup complete!"

# ═══════════════════════════════════════════════════════════════════════════════
# QUIZ
# ═══════════════════════════════════════════════════════════════════════════════

quiz:
	@echo "═══ Formative Quiz ═══"
	@if [ -f "$(SCRIPTS_BASH)/S03_02_interactive_quiz.sh" ]; then \
		bash "$(SCRIPTS_BASH)/S03_02_interactive_quiz.sh"; \
	elif [ -f "$(SCRIPTS_PYTHON)/S03_02_quiz_generator.py" ] && [ -f "$(FORMATIVE)/quiz.yaml" ]; then \
		$(PYTHON) "$(SCRIPTS_PYTHON)/S03_02_quiz_generator.py" "$(FORMATIVE)/quiz.yaml"; \
	else \
		echo "Error: Quiz script not found"; \
		exit 1; \
	fi

quiz-json:
	@echo "═══ Quiz JSON Validation ═══"
	@if [ -f "$(FORMATIVE)/quiz_lms.json" ]; then \
		$(PYTHON) -m json.tool "$(FORMATIVE)/quiz_lms.json" > /dev/null && \
		echo "✓ Quiz JSON valid" && \
		$(PYTHON) -c "import json; q=json.load(open('$(FORMATIVE)/quiz_lms.json')); print(f'  Questions: {len(q[\"questions\"])}')" ; \
	else \
		echo "Error: $(FORMATIVE)/quiz_lms.json does not exist"; \
		exit 1; \
	fi

# ═══════════════════════════════════════════════════════════════════════════════
# TESTS
# ═══════════════════════════════════════════════════════════════════════════════

test:
	@echo "═══ Running Tests ═══"
	@if [ -f "$(TESTS)/run_all_tests.sh" ]; then \
		bash "$(TESTS)/run_all_tests.sh"; \
	else \
		echo "Warning: $(TESTS)/run_all_tests.sh does not exist"; \
		echo "Running basic tests..."; \
		$(MAKE) test-basic; \
	fi

test-basic:
	@echo "Checking Bash syntax..."
	@for f in $(SCRIPTS_BASH)/*.sh $(SCRIPTS_DEMO)/*.sh; do \
		if [ -f "$$f" ]; then \
			bash -n "$$f" 2>/dev/null || echo "  Error in: $$f"; \
		fi; \
	done
	@echo "Checking Python syntax..."
	@for f in $(SCRIPTS_PYTHON)/*.py; do \
		if [ -f "$$f" ]; then \
			$(PYTHON) -m py_compile "$$f" 2>/dev/null || echo "  Error in: $$f"; \
		fi; \
	done
	@echo "Checking quiz YAML..."
	@if [ -f "$(FORMATIVE)/quiz.yaml" ]; then \
		$(PYTHON) -c "import yaml; yaml.safe_load(open('$(FORMATIVE)/quiz.yaml'))" && \
		echo "✓ Quiz YAML valid"; \
	fi
	@echo "Basic tests complete!"

# ═══════════════════════════════════════════════════════════════════════════════
# LINTING
# ═══════════════════════════════════════════════════════════════════════════════

lint: lint-bash lint-python
	@echo "═══ Linting complete! ═══"

lint-bash:
	@echo "═══ Bash Verification (shellcheck) ═══"
	@if command -v $(SHELLCHECK) >/dev/null 2>&1; then \
		$(SHELLCHECK) --shell=bash --severity=warning \
			$(SCRIPTS_BASH)/*.sh $(SCRIPTS_DEMO)/*.sh 2>/dev/null || true; \
		echo "✓ Shellcheck verification complete"; \
	else \
		echo "Warning: shellcheck is not installed"; \
		echo "  Install: sudo apt install shellcheck"; \
		echo "Basic syntax verification..."; \
		bash -n $(SCRIPTS_BASH)/*.sh $(SCRIPTS_DEMO)/*.sh && echo "✓ Syntax OK"; \
	fi

lint-python:
	@echo "═══ Python Verification (ruff) ═══"
	@if command -v $(RUFF) >/dev/null 2>&1; then \
		$(RUFF) check $(SCRIPTS_PYTHON)/*.py || true; \
		echo "✓ Ruff verification complete"; \
	else \
		echo "Warning: ruff is not installed"; \
		echo "  Install: pip install ruff"; \
		echo "Basic syntax verification..."; \
		$(PYTHON) -m py_compile $(SCRIPTS_PYTHON)/*.py && echo "✓ Syntax OK"; \
	fi

# ═══════════════════════════════════════════════════════════════════════════════
# STRUCTURE VALIDATION
# ═══════════════════════════════════════════════════════════════════════════════

validate:
	@echo "═══ Seminar Structure Validation ═══"
	@ERRORS=0; \
	echo "Checking mandatory docs/ files..."; \
	for f in S03_00_PEDAGOGICAL_ANALYSIS_PLAN.md S03_01_INSTRUCTOR_GUIDE.md \
		S03_02_MAIN_MATERIAL.md S03_03_PEER_INSTRUCTION.md \
		S03_04_PARSONS_PROBLEMS.md S03_05_LIVE_CODING_GUIDE.md \
		S03_06_SPRINT_EXERCISES.md S03_07_LLM_AWARE_EXERCISES.md \
		S03_08_SPECTACULAR_DEMOS.md S03_09_VISUAL_CHEAT_SHEET.md \
		S03_10_SELF_ASSESSMENT_REFLECTION.md lo_traceability.md; do \
		if [ -f "docs/$$f" ]; then \
			echo "  ✓ docs/$$f"; \
		else \
			echo "  ✗ docs/$$f MISSING"; \
			ERRORS=$$((ERRORS+1)); \
		fi; \
	done; \
	echo "Checking mandatory root files..."; \
	for f in README.md Makefile requirements.txt; do \
		if [ -f "$$f" ]; then \
			echo "  ✓ $$f"; \
		else \
			echo "  ✗ $$f MISSING"; \
			ERRORS=$$((ERRORS+1)); \
		fi; \
	done; \
	echo "Checking directories..."; \
	for d in formative ci scripts/bash scripts/demo scripts/python homework tests; do \
		if [ -d "$$d" ]; then \
			echo "  ✓ $$d/"; \
		else \
			echo "  ✗ $$d/ MISSING"; \
			ERRORS=$$((ERRORS+1)); \
		fi; \
	done; \
	echo "Checking docs/images/ for diagrams..."; \
	if [ -d "docs/images" ] && [ "$$(ls -A docs/images 2>/dev/null)" ]; then \
		echo "  ✓ docs/images/ contains files"; \
	else \
		echo "  ⚠ docs/images/ is empty or missing"; \
	fi; \
	if [ $$ERRORS -eq 0 ]; then \
		echo "═══ Validation complete: 0 errors ═══"; \
	else \
		echo "═══ Validation complete: $$ERRORS errors ═══"; \
		exit 1; \
	fi

# ═══════════════════════════════════════════════════════════════════════════════
# CHECK DEPENDENCIES
# ═══════════════════════════════════════════════════════════════════════════════

check-deps:
	@echo "═══ Checking Dependencies ═══"
	@echo "Python:"
	@$(PYTHON) --version 2>/dev/null || echo "  ✗ Python3 is not installed"
	@echo "Shellcheck:"
	@$(SHELLCHECK) --version 2>/dev/null | head -1 || echo "  ✗ shellcheck is not installed (optional)"
	@echo "Ruff:"
	@$(RUFF) --version 2>/dev/null || echo "  ✗ ruff is not installed (optional)"
	@echo "PyYAML:"
	@$(PYTHON) -c "import yaml; print(f'  PyYAML {yaml.__version__}')" 2>/dev/null || \
		echo "  ✗ PyYAML is not installed (pip install pyyaml)"

# ═══════════════════════════════════════════════════════════════════════════════
# CLEAN
# ═══════════════════════════════════════════════════════════════════════════════

clean:
	@echo "═══ Cleanup ═══"
	@rm -rf __pycache__ */__pycache__ */*/__pycache__
	@rm -f *.pyc */*.pyc */*/*.pyc
	@rm -f *.log */*.log
	@rm -rf .pytest_cache .ruff_cache
	@rm -rf /tmp/sem03_* /tmp/test_sem03_*
	@echo "Cleanup complete!"

# ═══════════════════════════════════════════════════════════════════════════════
# ALL
# ═══════════════════════════════════════════════════════════════════════════════

all: check-deps lint test validate
	@echo ""
	@echo "═══════════════════════════════════════════════════════════════════════════════"
	@echo "  Complete verification finished!"
	@echo "═══════════════════════════════════════════════════════════════════════════════"
