# ═══════════════════════════════════════════════════════════════════════════════
# Makefile — Course 05: Execution Threads
# Operating Systems | ASE Bucharest - CSIE | 2025-2026
# ═══════════════════════════════════════════════════════════════════════════════

.PHONY: all diagrams quiz test-scripts clean help check

# Configuration
COURSE_NUM := 05
COURSE_NAME := Execution Threads
PLANTUML_JAR ?= /usr/share/plantuml/plantuml.jar

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
	@test -f README.md || (echo "$(RED)✗ README.md missing$(NC)" && exit 1)
	@echo "$(GREEN)✓ README.md exists$(NC)"
	@test -d docs || mkdir -p docs
	@echo "$(GREEN)✓ Directory docs/ verified$(NC)"

# ─────────────────────────────────────────────────────────────────────────────
# PlantUML diagram generation
# ─────────────────────────────────────────────────────────────────────────────
diagrams:
	@status=0; count=0; \
	if [ -f "$(PLANTUML_JAR)" ] && command -v java >/dev/null 2>&1; then renderer=jar; \
	elif command -v plantuml >/dev/null 2>&1; then renderer=command; \
	else echo "ERROR: PlantUML unavailable; no diagrams generated." >&2; exit 2; fi; \
	for f in diagrams/*.puml; do \
		[ -f "$$f" ] || continue; count=$$((count + 1)); \
		if [ "$$renderer" = jar ]; then java -jar "$(PLANTUML_JAR)" -failfast2 -tpng "$$f" || status=1; \
		else plantuml -failfast2 -tpng "$$f" || status=1; fi; \
	done; \
	[ "$$count" -gt 0 ] || { echo "ERROR: no diagram sources" >&2; exit 2; }; \
	[ "$$status" -eq 0 ] && echo "Rendered $$count diagram sources."; exit $$status

# ─────────────────────────────────────────────────────────────────────────────
# YAML quiz validation
# ─────────────────────────────────────────────────────────────────────────────
quiz:
	@status=0; count=0; \
	for f in docs/*05*.yaml; do \
		[ -f "$$f" ] || continue; count=$$((count + 1)); \
		if python3 -c 'import pathlib,sys,yaml; yaml.safe_load(pathlib.Path(sys.argv[1]).read_text(encoding="utf-8"))' "$$f"; then echo "YAML syntax PASS: $$f"; else status=1; fi; \
	done; \
	[ "$$count" -gt 0 ] || { echo "ERROR: no quiz YAML" >&2; exit 2; }; exit $$status

# ─────────────────────────────────────────────────────────────────────────────
# Script testing
# ─────────────────────────────────────────────────────────────────────────────
test-scripts:
	@status=0; \
	for f in scripts/*.py; do \
		[ -f "$$f" ] || continue; \
		if python3 -c 'import ast,pathlib,sys; p=pathlib.Path(sys.argv[1]); ast.parse(p.read_bytes(), filename=str(p))' "$$f"; then echo "PASS: $$f"; else echo "FAIL: $$f" >&2; status=1; fi; \
	done; \
	for f in scripts/*.sh; do \
		[ -f "$$f" ] || continue; \
		if bash -n "$$f"; then echo "PASS: $$f"; else echo "FAIL: $$f" >&2; status=1; fi; \
	done; exit $$status

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
