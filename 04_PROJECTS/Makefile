# =============================================================================
# Makefile - Semester Project Orchestration OS
# Operating Systems | ASE-CSIE | 2024-2025
# =============================================================================

.PHONY: all help validate validate-easy validate-medium validate-advanced \
        validate-structure check-links stats clean build-docs test

# Variables (directories have prefix for sorting)
EASY_DIR := b)EASY
MEDIUM_DIR := a)MEDIUM
ADVANCED_DIR := c)ADVANCED
FORMATIVE_DIR := formative

EASY_PROJECTS := $(wildcard $(EASY_DIR)/*.md)
MEDIUM_PROJECTS := $(wildcard $(MEDIUM_DIR)/*.md)
ADVANCED_PROJECTS := $(wildcard $(ADVANCED_DIR)/*.md)
ALL_PROJECTS := $(EASY_PROJECTS) $(MEDIUM_PROJECTS) $(ADVANCED_PROJECTS)

# Colours for output
GREEN := \033[0;32m
YELLOW := \033[0;33m
RED := \033[0;31m
BLUE := \033[0;34m
NC := \033[0m

# =============================================================================
# Main target
# =============================================================================

all: validate stats
	@echo ""
	@echo "$(GREEN)✓ All validations passed!$(NC)"

help:
	@echo "╔════════════════════════════════════════════════════════════════════════╗"
	@echo "║          Makefile - Semester Projects OS                               ║"
	@echo "╚════════════════════════════════════════════════════════════════════════╝"
	@echo ""
	@echo "$(BLUE)Usage:$(NC) make <target>"
	@echo ""
	@echo "$(YELLOW)Available targets:$(NC)"
	@echo "  all                 Run all validations"
	@echo "  validate            Validate all projects"
	@echo "  validate-easy       Validate only EASY projects"
	@echo "  validate-medium     Validate only MEDIUM projects"
	@echo "  validate-advanced   Validate only ADVANCED projects"
	@echo "  validate-structure  Verify file structure"
	@echo "  check-links         Verify links in documents"
	@echo "  stats               Display statistics"
	@echo "  build-docs          Generate HTML documentation (if pandoc exists)"
	@echo "  test                Run tests on scripts"
	@echo "  clean               Clean generated files"
	@echo ""
	@echo "$(YELLOW)Examples:$(NC)"
	@echo "  make validate"
	@echo "  make stats"
	@echo "  make validate-medium"

# =============================================================================
# Validation
# =============================================================================

validate: validate-structure validate-easy validate-medium validate-advanced
	@echo ""
	@echo "$(GREEN)✓ All project validations completed$(NC)"

validate-structure:
	@echo "$(BLUE)═══ Directory structure validation ═══$(NC)"
	@test -d $(EASY_DIR) || (echo "$(RED)✗ Missing $(EASY_DIR)/$(NC)" && exit 1)
	@test -d $(MEDIUM_DIR) || (echo "$(RED)✗ Missing $(MEDIUM_DIR)/$(NC)" && exit 1)
	@test -d $(ADVANCED_DIR) || (echo "$(RED)✗ Missing $(ADVANCED_DIR)/$(NC)" && exit 1)
	@test -d $(FORMATIVE_DIR) || (echo "$(RED)✗ Missing $(FORMATIVE_DIR)/$(NC)" && exit 1)
	@echo "$(GREEN)✓ Directory structure OK$(NC)"

validate-easy:
	@echo ""
	@echo "$(BLUE)═══ EASY projects validation ═══$(NC)"
	@for file in $(EASY_PROJECTS); do \
		$(MAKE) -s _validate-project PROJECT="$$file" LEVEL="EASY" MIN_LINES=100; \
	done

validate-medium:
	@echo ""
	@echo "$(BLUE)═══ MEDIUM projects validation ═══$(NC)"
	@for file in $(MEDIUM_PROJECTS); do \
		$(MAKE) -s _validate-project PROJECT="$$file" LEVEL="MEDIUM" MIN_LINES=200; \
	done

validate-advanced:
	@echo ""
	@echo "$(BLUE)═══ ADVANCED projects validation ═══$(NC)"
	@for file in $(ADVANCED_PROJECTS); do \
		$(MAKE) -s _validate-project PROJECT="$$file" LEVEL="ADVANCED" MIN_LINES=150; \
	done

# Internal target for individual validation
_validate-project:
	@name=$$(basename "$(PROJECT)"); \
	lines=$$(wc -l < "$(PROJECT)"); \
	has_cli=false; \
	has_example=false; \
	has_hints=false; \
	has_criteria=false; \
	has_structure=false; \
	errors=0; \
	\
	if grep -q "## Interfață CLI\|## CLI\|Interfață\|## Interface" "$(PROJECT)" 2>/dev/null; then has_cli=true; fi; \
	if grep -q "## Exemple Output\|## Exemple\|## Example" "$(PROJECT)" 2>/dev/null; then has_example=true; fi; \
	if grep -q "## Hints\|## Implementation\|## Implementare" "$(PROJECT)" 2>/dev/null; then has_hints=true; fi; \
	if grep -q "## Criterii\|## Evaluare\|Evaluation\|## Criteria" "$(PROJECT)" 2>/dev/null; then has_criteria=true; fi; \
	if grep -q "## Structură\|## Structure\|Proiect/" "$(PROJECT)" 2>/dev/null; then has_structure=true; fi; \
	\
	echo -n "  $$name: "; \
	\
	if [ $$lines -lt $(MIN_LINES) ]; then \
		echo -n "$(RED)[$$lines lines < $(MIN_LINES)]$(NC) "; \
		errors=$$((errors + 1)); \
	else \
		echo -n "$(GREEN)[$$lines lines]$(NC) "; \
	fi; \
	\
	if [ "$$has_cli" = "false" ]; then \
		echo -n "$(RED)[no CLI]$(NC) "; \
		errors=$$((errors + 1)); \
	fi; \
	if [ "$$has_example" = "false" ]; then \
		echo -n "$(YELLOW)[no examples]$(NC) "; \
	fi; \
	if [ "$$has_hints" = "false" ]; then \
		echo -n "$(YELLOW)[no hints]$(NC) "; \
	fi; \
	if [ "$$has_criteria" = "false" ]; then \
		echo -n "$(RED)[no criteria]$(NC) "; \
		errors=$$((errors + 1)); \
	fi; \
	\
	if [ $$errors -eq 0 ]; then \
		echo "$(GREEN)✓$(NC)"; \
	else \
		echo "$(RED)✗$(NC)"; \
	fi

# =============================================================================
# Link verification
# =============================================================================

check-links:
	@echo "$(BLUE)═══ Document link verification ═══$(NC)"
	@broken=0; \
	for file in $(ALL_PROJECTS); do \
		links=$$(grep -oE '\[.*?\]\(([^)]+)\)' "$$file" 2>/dev/null | grep -oE '\(([^)]+)\)' | tr -d '()'); \
		for link in $$links; do \
			case "$$link" in \
				http*|https*) \
					;; \
				/*|./*) \
					if [ ! -e "$$link" ]; then \
						echo "$(RED)✗ Broken link in $$file: $$link$(NC)"; \
						broken=$$((broken + 1)); \
					fi ;; \
			esac; \
		done; \
	done; \
	if [ $$broken -eq 0 ]; then \
		echo "$(GREEN)✓ All local links OK$(NC)"; \
	else \
		echo "$(RED)Found $$broken broken links$(NC)"; \
	fi

# =============================================================================
# Statistics
# =============================================================================

stats:
	@echo ""
	@echo "$(BLUE)═══════════════════════════════════════════════════════════════════════$(NC)"
	@echo "$(BLUE)                         PROJECT STATISTICS                            $(NC)"
	@echo "$(BLUE)═══════════════════════════════════════════════════════════════════════$(NC)"
	@echo ""
	@echo "$(YELLOW)Number of projects:$(NC)"
	@echo "  EASY:     $$(ls -1 $(EASY_DIR)/*.md 2>/dev/null | wc -l) projects"
	@echo "  MEDIUM:   $$(ls -1 $(MEDIUM_DIR)/*.md 2>/dev/null | wc -l) projects"
	@echo "  ADVANCED: $$(ls -1 $(ADVANCED_DIR)/*.md 2>/dev/null | wc -l) projects"
	@echo "  TOTAL:    $$(echo $(ALL_PROJECTS) | wc -w) projects"
	@echo ""
	@echo "$(YELLOW)Sizes (lines):$(NC)"
	@echo "  EASY avg:     $$(cat $(EASY_DIR)/*.md 2>/dev/null | wc -l) total / $$(ls -1 $(EASY_DIR)/*.md 2>/dev/null | wc -l) = $$(expr $$(cat $(EASY_DIR)/*.md 2>/dev/null | wc -l) / $$(ls -1 $(EASY_DIR)/*.md 2>/dev/null | wc -l) 2>/dev/null || echo 0) lines/project"
	@echo "  MEDIUM avg:   $$(cat $(MEDIUM_DIR)/*.md 2>/dev/null | wc -l) total / $$(ls -1 $(MEDIUM_DIR)/*.md 2>/dev/null | wc -l) = $$(expr $$(cat $(MEDIUM_DIR)/*.md 2>/dev/null | wc -l) / $$(ls -1 $(MEDIUM_DIR)/*.md 2>/dev/null | wc -l) 2>/dev/null || echo 0) lines/project"
	@echo "  ADVANCED avg: $$(cat $(ADVANCED_DIR)/*.md 2>/dev/null | wc -l) total / $$(ls -1 $(ADVANCED_DIR)/*.md 2>/dev/null | wc -l) = $$(expr $$(cat $(ADVANCED_DIR)/*.md 2>/dev/null | wc -l) / $$(ls -1 $(ADVANCED_DIR)/*.md 2>/dev/null | wc -l) 2>/dev/null || echo 0) lines/project"
	@echo ""
	@echo "$(YELLOW)Top 5 largest projects:$(NC)"
	@wc -l $(ALL_PROJECTS) 2>/dev/null | sort -rn | head -6 | tail -5 | \
		while read lines file; do \
			echo "  $$lines lines - $$(basename $$file)"; \
		done
	@echo ""
	@echo "$(YELLOW)Formative materials:$(NC)"
	@echo "  Quiz files: $$(ls -1 $(FORMATIVE_DIR)/*.yaml 2>/dev/null | wc -l)"
	@echo ""

# =============================================================================
# Documentation generation
# =============================================================================

build-docs:
	@echo "$(BLUE)═══ HTML documentation generation ═══$(NC)"
	@if ! command -v pandoc &>/dev/null; then \
		echo "$(YELLOW)pandoc not found - skipping HTML generation$(NC)"; \
		echo "Install with: apt install pandoc"; \
		exit 0; \
	fi; \
	mkdir -p docs/html; \
	for file in $(ALL_PROJECTS); do \
		name=$$(basename "$$file" .md); \
		echo "  Converting $$name.md -> $$name.html"; \
		pandoc "$$file" -o "docs/html/$$name.html" \
			--standalone \
			--metadata title="$$name" \
			--toc \
			--highlight-style=tango 2>/dev/null || true; \
	done; \
	echo "$(GREEN)✓ HTML docs generated in docs/html/$(NC)"

# =============================================================================
# Tests
# =============================================================================

test:
	@echo "$(BLUE)═══ Running tests ═══$(NC)"
	@echo "$(YELLOW)Note: Tests require project implementations$(NC)"
	@found=0; \
	for dir in $(EASY_DIR) $(MEDIUM_DIR) $(ADVANCED_DIR); do \
		for proj in $$dir/*/; do \
			if [ -d "$$proj/tests" ]; then \
				echo "  Testing: $$proj"; \
				if [ -f "$$proj/Makefile" ]; then \
					(cd "$$proj" && make test 2>/dev/null) || true; \
				fi; \
				found=$$((found + 1)); \
			fi; \
		done; \
	done; \
	if [ $$found -eq 0 ]; then \
		echo "$(YELLOW)No test directories found$(NC)"; \
	fi

# =============================================================================
# Cleanup
# =============================================================================

clean:
	@echo "$(BLUE)═══ Cleaning generated files ═══$(NC)"
	rm -rf docs/html
	rm -f *.log
	rm -f .validate-*
	@echo "$(GREEN)✓ Cleaned$(NC)"

# =============================================================================
# Development
# =============================================================================

# Check a single project
check-%:
	@file=$$(find . -name "$*.md" -type f | head -1); \
	if [ -z "$$file" ]; then \
		echo "$(RED)Project $* not found$(NC)"; \
		exit 1; \
	fi; \
	echo "$(BLUE)Checking: $$file$(NC)"; \
	wc -l "$$file"; \
	echo ""; \
	echo "$(YELLOW)Sections found:$(NC)"; \
	grep -E "^##" "$$file" | head -20

# List all projects
list:
	@echo "$(BLUE)═══ Available Projects ═══$(NC)"
	@echo ""
	@echo "$(YELLOW)EASY:$(NC)"
	@for f in $(EASY_PROJECTS); do echo "  - $$(basename $$f .md)"; done
	@echo ""
	@echo "$(YELLOW)MEDIUM:$(NC)"
	@for f in $(MEDIUM_PROJECTS); do echo "  - $$(basename $$f .md)"; done
	@echo ""
	@echo "$(YELLOW)ADVANCED:$(NC)"
	@for f in $(ADVANCED_PROJECTS); do echo "  - $$(basename $$f .md)"; done
