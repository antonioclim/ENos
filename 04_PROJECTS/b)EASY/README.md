# EASY Projects (E01-E05)

> **Difficulty:** ⭐⭐ | **Time:** 15-20 hours | **Components:** Bash only

---

## Overview

Easy projects are designed for students with basic Bash knowledge. They focus on fundamental commands and simple scripting patterns.

> 💡 **Instructor's note:** If this is your first serious Bash project, start here. These are not "easy" in the sense of being trivial — they are "easy" in the sense that the concepts are foundational. Master these patterns and the MEDIUM projects will feel approachable.

---

## Project List

| ID | Name | Core Commands | Recommended For |
|----|------|---------------|-----------------|
| E01 | File System Auditor | `find`, `du`, `stat` | First-timers |
| E02 | Log Analyzer | `grep`, `awk`, `sed` | Text processing practice |
| E03 | Bulk File Organiser | `mv`, `mkdir`, `find` | File management |
| E04 | System Health Reporter | `top`, `df`, `free` | Monitoring basics |
| E05 | Config File Manager | `cp`, `diff`, `sed` | Configuration workflows |

---

## What You Will Learn

Completing any EASY project will teach you:

- Command-line argument parsing with `getopts`
- File and directory operations
- Basic text processing pipelines
- Exit codes and error handling
- Writing maintainable shell scripts

---

## Getting Started

1. Read your chosen project specification (E0X_*.md)
2. Use `../templates/project_structure.sh` to scaffold your project
3. Follow `../TECHNICAL_GUIDE.md` for best practices
4. Run `../helpers/project_validator.sh` before submission

---

## Common Pitfalls

Based on previous years' submissions:

1. **Using `ls` in scripts** — Use `find` instead; it handles spaces correctly
2. **Forgetting quotes** — Always quote your variables: `"$var"` not `$var`
3. **Hardcoded paths** — Use `$HOME` and relative paths
4. **Missing error handling** — Add `set -euo pipefail` at the top

---

## Time Management

| Week | Milestone |
|------|-----------|
| 1 | Project structure created, CLI arguments working |
| 2 | Core functionality implemented |
| 3 | Edge cases handled, tests written |
| 4 | Documentation complete, final polish |

---

*EASY Projects — OS Kit | January 2025*
