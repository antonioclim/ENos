# ═══════════════════════════════════════════════════════════════════════════════
# Makefile — SEM06 CAPSTONE Build Orchestration
# ═══════════════════════════════════════════════════════════════════════════════
# Operating Systems | ASE Bucharest - CSIE
# Usage: make [target]
# ═══════════════════════════════════════════════════════════════════════════════

.PHONY: help quiz test lint clean install check all

# Colours for output
CYAN := \033[36m
GREEN := \033[32m
YELLOW := \033[33m
RED := \033[31m
RESET := \033[0m

# Directories
SCRIPTS_DIR := scripts
PROJECTS_DIR := $(SCRIPTS_DIR)/projects
FORMATIVE_DIR := formative
TESTS_DIR := tests

help:
	@echo ""
	@echo "$(CYAN)═══════════════════════════════════════════════════════════════$(RESET)"
	@echo "$(CYAN)  SEM06 CAPSTONE — Build System$(RESET)"
	@echo "$(CYAN)═══════════════════════════════════════════════════════════════$(RESET)"
	@echo ""
	@echo "$(GREEN)Available targets:$(RESET)"
	@echo "  $(YELLOW)make quiz$(RESET)      — Run the interactive formative quiz"
	@echo "  $(YELLOW)make quiz-practice$(RESET) — Quiz in practice mode"
	@echo "  $(YELLOW)make test$(RESET)      — Run all tests"
	@echo "  $(YELLOW)make lint$(RESET)      — Verify code quality"
	@echo "  $(YELLOW)make check$(RESET)     — Verify dependencies"
	@echo "  $(YELLOW)make clean$(RESET)     — Clean generated files"
	@echo "  $(YELLOW)make all$(RESET)       — lint + test + quiz-test"
	@echo ""

quiz:
	@python3 $(FORMATIVE_DIR)/quiz_runner.py $(FORMATIVE_DIR)/quiz.yaml

quiz-practice:
	@python3 $(FORMATIVE_DIR)/quiz_runner.py $(FORMATIVE_DIR)/quiz.yaml --practice

quiz-test:
	@python3 $(FORMATIVE_DIR)/quiz_runner.py --test

test:
	@bash $(TESTS_DIR)/run_all_tests.sh

lint:
	@echo "$(CYAN)Verifying code quality...$(RESET)"
	@if command -v shellcheck >/dev/null 2>&1; then \
		shellcheck -S warning $(SCRIPTS_DIR)/*.sh 2>/dev/null || true; \
	else \
		echo "$(YELLOW)shellcheck is not installed$(RESET)"; \
	fi

check:
	@echo "$(CYAN)Verifying dependencies...$(RESET)"
	@for cmd in bash python3 tar curl; do \
		command -v $$cmd >/dev/null && echo "$(GREEN)✓$(RESET) $$cmd" || echo "$(RED)✗$(RESET) $$cmd"; \
	done
	@python3 -c "import yaml" 2>/dev/null && echo "$(GREEN)✓$(RESET) pyyaml" || echo "$(YELLOW)○$(RESET) pyyaml (pip install pyyaml)"

clean:
	@rm -f *.log *.tmp results_*.json
	@rm -rf __pycache__
	@echo "$(GREEN)Cleanup completed.$(RESET)"

all: lint test quiz-test
	@echo "$(GREEN)All verifications passed!$(RESET)"
