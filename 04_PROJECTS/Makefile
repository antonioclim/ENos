# Project catalogue operations. These checks do not grade student implementations.
SHELL := /bin/bash
.SHELLFLAGS := -eu -o pipefail -c
.PHONY: all help validate validate-easy validate-medium validate-advanced validate-structure check-links stats list build-docs test clean
all: validate stats
help:
	@echo 'Targets: validate, validate-easy, validate-medium, validate-advanced, validate-structure, check-links, stats, list, build-docs, test, check-E01, clean'
validate:
	@python3 helpers/project_catalog.py validate
validate-easy:
	@python3 helpers/project_catalog.py validate --level easy
validate-medium:
	@python3 helpers/project_catalog.py validate --level medium
validate-advanced:
	@python3 helpers/project_catalog.py validate --level advanced
validate-structure:
	@python3 helpers/project_catalog.py structure
check-links:
	@python3 ../scripts/link_check.py . --internal-only
stats:
	@python3 helpers/project_catalog.py stats
list:
	@python3 helpers/project_catalog.py list
build-docs:
	@python3 helpers/project_catalog.py build-docs
test:
	@python3 helpers/project_catalog.py test
check-%:
	@python3 helpers/project_catalog.py check --project '$*'
clean:
	@echo 'No evidence, logs, source or student data are removed. Review docs/html before deleting a generated export.'
