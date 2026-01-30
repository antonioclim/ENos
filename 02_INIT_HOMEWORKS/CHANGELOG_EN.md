# 📜 CHANGELOG

All notable changes to this project are documented here.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

---

## [1.1.0] - 2025-01-27

### Added

#### Documentation
- **FAQ section** with 20+ frequently asked questions organised by category
- **ASCII flowchart diagram** of the recording process
- **Extended troubleshooting section** with 20 problem scenarios and solutions
- **Expected output** after each command in the guide
- **Encouraging language** for beginners ("Don't panic!", "You're on the right track!")
- "Tips for Success" section
- "You Did It!" section with acquired competencies
- Versioning in documentation

#### Code Quality - Bash Script
- **Complete strict mode**: `set -euo pipefail` + `IFS=$'\n\t'`
- Detailed comments for strict mode
- Variables declared `readonly` for constants
- **Array-based package installation** instead of string concatenation
- `read -r` for safe input reading
- Local variables in functions (`local`)
- Improved quoting for all variables
- Explicit exit code handling in upload (temporary errexit disable)
- Updated version in header (1.1.0)

#### Code Quality - Python Script
- **Complete type hints** for all functions (parameters and return types)
- Import `from __future__ import annotations` for forward references
- Type variables (`TypeVar`) for generic functions
- Improved docstrings with Args, Returns, Raises, Examples sections
- Constants with explicit type annotations
- Updated version in banner and docstring (1.1.0)
- Changelog in module docstring

### Changed

- Improved error messages (more descriptive)
- Reorganised sections in STUDENT_GUIDE_EN.md for logical flow
- Updated instructions for Ubuntu 24.04 LTS
- Refactored input validation using arrays in Bash
- Standardised formatting throughout all code

### Fixed

- Variable quoting in Bash for edge cases with spaces
- Handling for `externally-managed-environment` on Python 3.12+
- Potential word splitting issues in Bash

---

## [1.0.0] - 2025-01-21

### Added

#### Core Features
- Python TUI script with Matrix theme (visual effects, animations)
- Alternative Bash script for recording
- Student guide in Markdown and HTML
- Auto-installation of dependencies (pip, rich, questionary, asciinema, openssl, sshpass)
- RSA cryptographic signature for authenticity
- Automatic upload with retry logic (max 3 attempts)
- Local configuration saving for pre-filled data
- Input validation for all fields

#### User Interface
- Matrix effects (digital rain, glitch text, typing effect)
- Animated spinners and progress bars
- Interactive menus with arrow key navigation
- Consistent colours and styles (green Matrix theme)
- Clear success/error/warning messages

#### Documentation
- README_EN.md with basic instructions
- STUDENT_GUIDE_EN.md with detailed steps
- STUDENT_GUIDE_EN.html (interactive version)

---

## Planned Versions

### [1.2.0] - TBD

- [ ] macOS support (brew instead of apt)
- [ ] Recording preview option before upload
- [ ] Integration with asciinema.org for playback
- [ ] Complete offline mode (no internet dependency for basic features)
- [ ] Romanian translation of the guide

### [1.3.0] - TBD

- [ ] Unit tests for validation functions
- [ ] Integration tests for complete workflow
- [ ] CI/CD pipeline for automated verification
- [ ] Makefile for common operations

---

## Versioning Conventions

This project uses [Semantic Versioning](https://semver.org/):

- **MAJOR** (X.0.0): Incompatible API/interface changes
- **MINOR** (0.X.0): New features, backward-compatible
- **PATCH** (0.0.X): Bug fixes, backward-compatible

---

*Maintained by: Operating Systems 2023-2027 - ASE Bucharest*
