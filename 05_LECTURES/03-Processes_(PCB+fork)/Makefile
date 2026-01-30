# ═══════════════════════════════════════════════════════════════════════════════
# Makefile — Course 03: Processes (PCB + fork)
# Operating Systems | ASE Bucharest - CSIE | 2025-2026
# ═══════════════════════════════════════════════════════════════════════════════

.PHONY: all diagrams quiz test-scripts clean help check

# Configuration
COURSE_NUM := 03
COURSE_NAME := Processes (PCB + fork)
PLANTUML_JAR := /usr/share/plantuml/plantuml.jar

# Colours for output
GREEN := \033[0;32m
YELLOW := \033[0;33m
RED := \033[0;31m
NC := \033[0m

# ─────────────────────────────────────────────────────────────────────────────
# Main target
# ─────────────────────────────────────────────────────────────────────────────
all: check diagrams quiz
	@echo "$(GREEN)✓ Build complete for Course $(COURSE_NUM)$(NC)"

# ─────────────────────────────────────────────────────────────────────────────
# Structure verification
# ─────────────────────────────────────────────────────────────────────────────
check:
	@echo "$(YELLOW)Verifying structure for Course $(COURSE_NUM)...$(NC)"
	@test -f README.md || (echo "$(RED)✗ README.md is missing$(NC)" && exit 1)
	@echo "$(GREEN)✓ README.md exists$(NC)"
	@test -d docs || mkdir -p docs
	@echo "$(GREEN)✓ docs/ directory verified$(NC)"

# ─────────────────────────────────────────────────────────────────────────────
# PlantUML diagram generation
# ─────────────────────────────────────────────────────────────────────────────
diagrams:
	@echo "$(YELLOW)Generating PlantUML diagrams...$(NC)"
	@if [ -d diagrams ] && ls diagrams/*.puml 1> /dev/null 2>&1; then \
		for f in diagrams/*.puml; do \
			echo "  Processing $$f..."; \
			java -jar $(PLANTUML_JAR) -tpng "$$f" 2>/dev/null || \
			plantuml -tpng "$$f" 2>/dev/null || \
			echo "$(YELLOW)  ⚠ PlantUML is not installed$(NC)"; \
		done; \
		echo "$(GREEN)✓ Diagrams processed$(NC)"; \
	else \
		echo "$(YELLOW)  ⚠ No diagrams/*.puml files exist$(NC)"; \
	fi

# ─────────────────────────────────────────────────────────────────────────────
# YAML quiz validation
# ─────────────────────────────────────────────────────────────────────────────
quiz:
	@echo "$(YELLOW)Validating formative assessment YAML...$(NC)"
	@if ls docs/C*_05_FORMATIVE_ASSESSMENT.yaml 1> /dev/null 2>&1; then \
		for f in docs/C*_05_FORMATIVE_ASSESSMENT.yaml; do \
			python3 -c "import yaml; yaml.safe_load(open('$$f'))" && \
			echo "$(GREEN)✓ $$f valid$(NC)"; \
		done; \
	else \
		echo "$(YELLOW)  ⚠ No assessment YAML files exist$(NC)"; \
	fi

# ─────────────────────────────────────────────────────────────────────────────
# Script testing
# ─────────────────────────────────────────────────────────────────────────────
test-scripts:
	@echo "$(YELLOW)Checking script syntax...$(NC)"
	@if [ -d scripts ]; then \
		for f in scripts/*.py 2>/dev/null; do \
			[ -f "$$f" ] && python3 -m py_compile "$$f" && echo "$(GREEN)  ✓ $$f$(NC)"; \
		done; \
		for f in scripts/*.sh 2>/dev/null; do \
			[ -f "$$f" ] && bash -n "$$f" && echo "$(GREEN)  ✓ $$f$(NC)"; \
		done; \
	else \
		echo "$(YELLOW)  ⚠ scripts/ directory does not exist$(NC)"; \
	fi

# ─────────────────────────────────────────────────────────────────────────────
# Cleanup
# ─────────────────────────────────────────────────────────────────────────────
clean:
	@rm -f diagrams/*.png 2>/dev/null || true
	@rm -f scripts/*.pyc 2>/dev/null || true
	@rm -rf scripts/__pycache__ 2>/dev/null || true
	@echo "$(GREEN)✓ Cleanup complete$(NC)"

# ─────────────────────────────────────────────────────────────────────────────
# Help
# ─────────────────────────────────────────────────────────────────────────────
help:
	@echo ""
	@echo "$(GREEN)═══════════════════════════════════════════════════════════════$(NC)"
	@echo "$(GREEN)  Makefile — Course $(COURSE_NUM): $(COURSE_NAME)$(NC)"
	@echo "$(GREEN)═══════════════════════════════════════════════════════════════$(NC)"
	@echo ""
	@echo "Targets: make [all|check|diagrams|quiz|test-scripts|clean|help]"
	@echo ""
