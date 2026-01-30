# Changelog - SEM02 Operators, Redirection, Filters, Loops

All notable changes to this seminar are documented in this file.
Format based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [2.0.0] - 2025-01-30

### Added
- **AI penalty system** in autograder: graduated penalties (5-10%) for excessive AI indicators
- **Exercise L6: Fingerprint Detective** - teaches students to recognise AI-generated code patterns
- **AI Usage Policy** section in README with clear guidelines
- "Things That Go Wrong" section in Instructor Guide with common pitfalls
- Personal teaching anecdotes in pedagogical documentation (reduces AI fingerprint)
- `ai_penalty_applied` field in grading reports

### Changed
- **BREAKING**: Autograder now expects English filenames:
  - `ex1_operatori.sh` → `ex1_operators.sh`
  - `ex2_redirectare.sh` → `ex2_redirection.sh`
  - `ex3_filtre.sh` → `ex3_filters.sh`
  - `ex4_bucle.sh` → `ex4_loops.sh`
  - `ex5_integrat.sh` → `ex5_integrated.sh`
- `S02_01_ASSIGNMENT.md` → `S02_01_HOMEWORK.md` (naming standardisation)
- Loops timing increased from 15 to 20 minutes in session plan
- Filters timing reduced from 20 to 15 minutes (compensating adjustment)
- Autograder version bumped to 2.0 with cleaner code structure
- LLM Competency Matrix now includes L6 and "Recognising AI fingerprints"

### Fixed
- **CRITICAL**: Mismatch between autograder (Romanian filenames) and validator (English filenames)
- Romanian remnants in `S02_02_create_homework.sh` header
- Inconsistent references to old filename conventions

### Removed
- Informational-only AI detection (now has actual impact on scores)

## [1.2.0] - 2025-01-29

### Added
- `S02_00_PEDAGOGICAL_ANALYSIS_PLAN.md` - previously missing document now complete
- `S02_01_INSTRUCTOR_GUIDE.md` - detailed practical teaching guide
- `S02_02_interactive_quiz.sh` - Bash alternative to Python quiz runner
- Part 6 in assignment: comprehension verification exercise (anti-AI)
- AI content indicator detection in autograder (informational, non-penalising)
- Additional unit tests for edge cases and AI detection

### Changed
- Standardised file naming: Romanian → English
  - `MATERIAL_PRINCIPAL` → `MAIN_MATERIAL`
  - `prezentare.html` → `presentation.html`
  - `creeaza_tema.sh` → `create_homework.sh`
  - `demo_redirectare/filtre/bucle` → `demo_redirection/filters/loops`
- Consolidated `assignments/` into `homework/` (removed duplication)
- Updated cross-references in `lo_traceability.md`
- Improved autograder with AI detection section
- Updated evaluation rubric to include Part 6

### Fixed
- Broken references between documents
- Makefile paths after restructuring
- Naming convention inconsistencies

## [1.1.0] - 2025-01-15

### Added
- New Parsons Problems (PP-13 through PP-17) for common Bash traps
- LLM-aware exercises with complete grading rubrics
- Extended traceability matrix for all Learning Outcomes
- Visual cheat sheet with SVG diagrams

### Changed
- Expanded formative quiz from 20 to 25 questions
- Rebalanced Bloom distribution for introductory level
- Restructured demonstrations with automatic cleanup

## [1.0.0] - 2025-01-08

### Added
- Initial seminar structure following ENos template
- Main material with 5 thematic sections
- YAML formative quiz with 20 questions
- Demonstration scripts for each concept
- Python autograder for assignment evaluation
- CI/CD configuration (GitHub Actions, linting)

---

## Conventions

- **Added** for new features
- **Changed** for changes in existing functionality
- **Deprecated** for features to be removed in future
- **Removed** for removed features
- **Fixed** for any bug fixes
- **Security** for vulnerabilities

---

*Maintained by ing. dr. Antonio Clim | ASE Bucharest - CSIE*
