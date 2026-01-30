# Changelog - SEM01

All notable changes to this seminar will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

---

## [2.1.0] - 2025-01-30

### Added
- **New documentation**
  - `S01_11_EXTERNAL_PLAGIARISM_TOOLS.md` — Complete MOSS and JPlag integration guide
  - `homework/S01_04_ORAL_VERIFICATION_LOG.md` — Printable verification form with question bank

- **Enhanced plagiarism detection**
  - AI code pattern detection in `S01_05_plagiarism_detector.py`
  - 11 AI-specific patterns (explanatory comments, step narration, etc.)
  - AI likelihood score (0.0–1.0) for each submission
  - Combined report: similarity + AI indicators

- **Makefile targets**
  - `make test-coverage` — pytest with 75% threshold
  - `make plagiarism-check SUBMISSIONS=./` — internal detector
  - `make moss-check MOSS_USERID=... SUBMISSIONS=./` — MOSS submission
  - `make jplag-check SUBMISSIONS=./` — JPlag analysis

- **CI/CD improvements**
  - Coverage threshold enforcement (75%)
  - S01_11 document validation in structure check
  - Oral verification log validation

- **Pedagogical enhancements**
  - Detailed pair programming protocol in Instructor Guide
  - Driver/Navigator responsibilities table
  - Common problems and solutions
  - Enhanced extension challenges in Sprint Exercises (★★★☆☆ difficulty ratings)

### Changed
- **Makefile** — Replaced `|| true` with proper error handling
- **CI pipeline** — Version bumped to 2.1, added coverage threshold
- **Headers** — Standardised "Bucharest UES" → "ASE Bucharest" throughout
- **lo_traceability.md** — Added document index and external tools column

### Fixed
- Makefile lint target now properly reports shellcheck/ruff status
- README structure reflects actual folder layout

---

## [2.0.0] - 2025-01-29

### Added
- **Anti-plagiarism measures**
  - Assignment generator (`S01_04_assignment_generator.py`) for randomised variants per student
  - Plagiarism detector (`S01_05_plagiarism_detector.py`) for similarity detection
  - AI fingerprint scanner (`S01_06_ai_fingerprint_scanner.py`) for documentation review
  - Mandatory oral verification (10% of grade) in evaluation rubric

- **Bloom taxonomy completion**
  - Added Evaluate level question (Q13) to quiz
  - Added Create level question (Q14) to quiz
  - Updated LO traceability to cover all six levels

- **Metacognition support**
  - Learning journal template in self-assessment document
  - Differentiation section for advanced students
  - Peer discussion prompts

- **New documentation**
  - CONTRIBUTING.md with style guidelines
  - Updated README with new features

### Changed
- **Folder structure standardisation**
  - Renamed `assignments/` to `homework/`
  - Renamed `tests_runner/` and `unit_tests/` to `tests/`
  - All folder names now English only

- **File naming standardisation**
  - Renamed `S01_02_quiz_interactiv.sh` to `S01_02_interactive_quiz.sh`
  - Renamed `S01_03_demo_variabile.sh` to `S01_03_demo_variables.sh`
  - Renamed `S01_00_PEDAGOGICAL_ANALYSIS_AND_PLAN.md` to `S01_00_PEDAGOGICAL_ANALYSIS_PLAN.md`

- **Language standardisation**
  - All documentation converted to British English
  - Removed Oxford comma throughout
  - Script output messages in English

- **Evaluation rubric**
  - Added oral verification section (10% of grade)
  - Added red flags for plagiarism detection
  - Reduced other sections proportionally

- **Quiz improvements**
  - Extended from 12 to 14 questions
  - Added security evaluation question
  - Added alias creation question
  - Updated Bloom distribution to include all levels

### Fixed
- Incomplete GlobbingTest class in autograder
- Missing shutil import in autograder
- Inconsistent naming in documentation headers

### Removed
- Romanian language content from all files except OLD_HW legacy folder
- Duplicate test directories

---

## [1.0.0] - 2025-01-15

### Added
- Initial release of standardised SEM01 materials
- Complete set of 11 documentation files
- Formative quiz with 12 questions
- Autograder with multiple test types
- Validator script for quick verification
- CI/CD configuration for GitHub Actions
- ShellCheck configuration

---

*Maintained by ing. dr. Antonio Clim, ASE-CSIE Bucharest*
