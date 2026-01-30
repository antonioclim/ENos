# Makefile for SEM01 - Shell Fundamentals
# Operating Systems | ASE Bucharest - CSIE
# Version: 2.1

.PHONY: help setup test test-coverage lint quiz clean validate ai-check generate-homework plagiarism-check moss-check jplag-check

# Directories
HOMEWORK_DIR := homework
TESTS_DIR := tests
SCRIPTS_DIR := scripts
FORMATIVE_DIR := formative
DOCS_DIR := docs

# Colours for output
GREEN := \033[0;32m
YELLOW := \033[1;33m
CYAN := \033[0;36m
RED := \033[0;31m
NC := \033[0m

# Coverage threshold
COVERAGE_THRESHOLD := 75

help:
	@echo ""
	@echo "$(CYAN)+===================================================================+$(NC)"
	@echo "$(CYAN)|$(NC)              SEM01 - Shell Fundamentals Makefile                 $(CYAN)|$(NC)"
	@echo "$(CYAN)+===================================================================+$(NC)"
	@echo ""
	@echo "Available targets:"
	@echo ""
	@echo "  $(GREEN)setup$(NC)              Install Python dependencies"
	@echo "  $(GREEN)test$(NC)               Run all tests (pytest + bash syntax)"
	@echo "  $(GREEN)test-coverage$(NC)      Run tests with coverage threshold ($(COVERAGE_THRESHOLD)%)"
	@echo "  $(GREEN)lint$(NC)               Check code quality (shellcheck + ruff)"
	@echo "  $(GREEN)quiz$(NC)               Run the interactive formative quiz"
	@echo "  $(GREEN)validate$(NC)           Validate seminar structure"
	@echo "  $(GREEN)ai-check$(NC)           Scan documentation for AI patterns"
	@echo "  $(GREEN)plagiarism-check$(NC)   Run internal plagiarism detector"
	@echo "  $(GREEN)moss-check$(NC)         Submit to MOSS (requires MOSS_USERID)"
	@echo "  $(GREEN)jplag-check$(NC)        Run JPlag analysis (requires Java)"
	@echo "  $(GREEN)generate-homework$(NC)  Generate a personalised homework variant"
	@echo "  $(GREEN)clean$(NC)              Remove temporary files"
	@echo ""
	@echo "Examples:"
	@echo "  make test"
	@echo "  make test-coverage"
	@echo "  make lint"
	@echo "  make plagiarism-check SUBMISSIONS=./submissions/"
	@echo "  make generate-homework STUDENT=PopescuIon"
	@echo ""

setup:
	@echo ">>> Installing dependencies..."
	pip install -r requirements.txt --break-system-packages 2>/dev/null || pip install -r requirements.txt
	@echo "$(GREEN)[OK] Dependencies installed$(NC)"

test:
	@echo ">>> Running pytest..."
	@pytest $(TESTS_DIR)/ -v --tb=short --color=yes; \
		PYTEST_EXIT=$$?; \
		if [ $$PYTEST_EXIT -ne 0 ] && [ $$PYTEST_EXIT -ne 5 ]; then \
			echo "$(RED)[FAIL] pytest returned errors$(NC)"; \
		fi
	@echo ""
	@echo ">>> Checking Bash syntax..."
	@ERRORS=0; \
	for script in $(SCRIPTS_DIR)/bash/*.sh $(SCRIPTS_DIR)/demo/*.sh; do \
		if [ -f "$$script" ]; then \
			if bash -n "$$script" 2>/dev/null; then \
				echo "$(GREEN)[OK]$(NC) $$script"; \
			else \
				echo "$(RED)[FAIL]$(NC) $$script"; \
				ERRORS=$$((ERRORS+1)); \
			fi \
		fi \
	done; \
	if [ $$ERRORS -gt 0 ]; then \
		echo "$(RED)>>> $$ERRORS script(s) have syntax errors$(NC)"; \
		exit 1; \
	fi
	@echo "$(GREEN)[OK] All tests passed$(NC)"

test-coverage:
	@echo ">>> Running pytest with coverage threshold ($(COVERAGE_THRESHOLD)%)..."
	@pytest $(TESTS_DIR)/ -v --tb=short \
		--cov=$(FORMATIVE_DIR) \
		--cov=$(SCRIPTS_DIR)/python \
		--cov-report=term-missing \
		--cov-fail-under=$(COVERAGE_THRESHOLD)

lint:
	@echo ">>> Running shellcheck..."
	@if command -v shellcheck >/dev/null 2>&1; then \
		shellcheck --severity=warning $(SCRIPTS_DIR)/bash/*.sh $(SCRIPTS_DIR)/demo/*.sh; \
		SC_EXIT=$$?; \
		if [ $$SC_EXIT -ne 0 ]; then \
			echo "$(YELLOW)[WARN] shellcheck found issues (exit $$SC_EXIT)$(NC)"; \
		else \
			echo "$(GREEN)[OK] shellcheck passed$(NC)"; \
		fi \
	else \
		echo "$(YELLOW)[SKIP] shellcheck not installed$(NC)"; \
	fi
	@echo ""
	@echo ">>> Running ruff on Python code..."
	@if command -v ruff >/dev/null 2>&1; then \
		ruff check $(FORMATIVE_DIR)/ $(SCRIPTS_DIR)/python/ --ignore E501 --exit-zero; \
		echo "$(GREEN)[OK] ruff check complete$(NC)"; \
	else \
		echo "$(YELLOW)[SKIP] ruff not installed$(NC)"; \
	fi

quiz:
	@echo ">>> Starting interactive quiz..."
	@python3 $(FORMATIVE_DIR)/quiz_runner.py

validate:
	@echo ">>> Validating seminar structure..."
	@echo ""
	@echo "Checking mandatory directories..."
	@for dir in ci docs formative homework presentations resources scripts tests; do \
		if [ -d "$$dir" ]; then \
			echo "$(GREEN)[OK]$(NC) $$dir/"; \
		else \
			echo "$(YELLOW)[MISSING]$(NC) $$dir/"; \
		fi \
	done
	@echo ""
	@echo "Checking for non-standard folder names..."
	@for dir in prezentari resurse teme teste assignments tests_runner unit_tests; do \
		if [ -d "$$dir" ]; then \
			echo "$(YELLOW)[WARN]$(NC) Non-standard folder: $$dir/"; \
		fi \
	done
	@echo ""
	@echo "Checking mandatory docs (00-11)..."
	@for i in 00 01 02 03 04 05 06 07 08 09 10 11; do \
		count=$$(ls $(DOCS_DIR)/S01_$${i}_*.md 2>/dev/null | wc -l); \
		if [ "$$count" -eq 0 ]; then \
			echo "$(YELLOW)[MISSING]$(NC) docs/S01_$${i}_*.md"; \
		else \
			echo "$(GREEN)[OK]$(NC) docs/S01_$${i}_*.md"; \
		fi \
	done
	@echo ""
	@echo "$(GREEN)[OK] Validation complete$(NC)"

ai-check:
	@echo ">>> Scanning documentation for AI patterns..."
	@python3 $(SCRIPTS_DIR)/python/S01_06_ai_fingerprint_scanner.py $(DOCS_DIR)/; \
		AI_EXIT=$$?; \
		if [ $$AI_EXIT -ne 0 ]; then \
			echo "$(YELLOW)[WARN] AI patterns detected - review recommended$(NC)"; \
		fi

plagiarism-check:
ifndef SUBMISSIONS
	@echo "Usage: make plagiarism-check SUBMISSIONS=path/to/submissions/"
	@echo ""
	@echo "Example: make plagiarism-check SUBMISSIONS=./submissions/"
else
	@echo ">>> Running internal plagiarism detector..."
	@python3 $(SCRIPTS_DIR)/python/S01_05_plagiarism_detector.py $(SUBMISSIONS) --threshold 0.85
endif

moss-check:
ifndef MOSS_USERID
	@echo "Usage: make moss-check MOSS_USERID=your_id SUBMISSIONS=path/"
	@echo ""
	@echo "To get a MOSS user ID:"
	@echo "  1. Send email to moss@moss.stanford.edu"
	@echo "  2. Subject and body: registeruser"
	@echo "  3. You'll receive a Perl script with your ID"
else ifndef SUBMISSIONS
	@echo "Usage: make moss-check MOSS_USERID=your_id SUBMISSIONS=path/"
else
	@echo ">>> Submitting to MOSS..."
	@if [ -f moss.pl ]; then \
		perl moss.pl -l bash -u $(MOSS_USERID) -d $(SUBMISSIONS)/*/*.sh; \
	else \
		echo "$(RED)[ERROR] moss.pl not found - download from registration email$(NC)"; \
	fi
endif

jplag-check:
ifndef SUBMISSIONS
	@echo "Usage: make jplag-check SUBMISSIONS=path/"
	@echo ""
	@echo "Requires: java and jplag.jar in current directory"
	@echo "Download: https://github.com/jplag/JPlag/releases"
else
	@echo ">>> Running JPlag..."
	@if [ -f jplag.jar ] || [ -f jplag-*.jar ]; then \
		JPLAG_JAR=$$(ls jplag*.jar 2>/dev/null | head -1); \
		java -jar $$JPLAG_JAR -l bash -r jplag_results/ $(SUBMISSIONS)/; \
		echo "$(GREEN)[OK] Results in jplag_results/index.html$(NC)"; \
	else \
		echo "$(RED)[ERROR] jplag.jar not found$(NC)"; \
		echo "Download from: https://github.com/jplag/JPlag/releases"; \
	fi
endif

generate-homework:
ifndef STUDENT
	@echo "Usage: make generate-homework STUDENT=StudentName"
	@echo ""
	@echo "Example: make generate-homework STUDENT=PopescuIon"
else
	@echo ">>> Generating homework variant for $(STUDENT)..."
	@python3 $(SCRIPTS_DIR)/python/S01_04_assignment_generator.py $(STUDENT) --output $(HOMEWORK_DIR)/generated/
	@echo "$(GREEN)[OK] Homework generated$(NC)"
endif

clean:
	@echo ">>> Cleaning temporary files..."
	@find . -type f -name "*.pyc" -delete
	@find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
	@find . -type f -name ".DS_Store" -delete
	@find . -type f -name "*.log" -delete
	@find . -type d -name "glob_test_temp" -exec rm -rf {} + 2>/dev/null || true
	@find . -type d -name "jplag_results" -exec rm -rf {} + 2>/dev/null || true
	@find . -type f -name "plagiarism_report_*.txt" -delete
	@find . -type f -name "plagiarism_report_*.json" -delete
	@echo "$(GREEN)[OK] Cleaned$(NC)"
