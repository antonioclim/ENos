# S05_01 — Homework: Advanced Bash Scripting

> **Author decision pending:** The assessment rules below are retained proposals. They conflict across the brief, rubric and oral guide, so no combined final-grade formula, penalty order, remote-proctoring rule or integrity inference is enacted. See [the exact alternatives, consequences and recommendation](../docs/TEACHING_CONTRACT.md). Technical exercises remain usable. Removed historical success rates and classroom claims are retained in [the provenance record](../../DECISION_PROVENANCE.json).


> **Operating Systems** | ASE Bucharest — CSIE  
> **Seminar 5:** Advanced Bash Scripting  
> **Submission deadline:** Check Moodle for exact date  
> **Weight:** 10% of final course grade

---

## ⚠️ Academic Integrity Declaration (MANDATORY)

Include this **at the top of EVERY script** you submit:

```bash
# ═══════════════════════════════════════════════════════════════
# ACADEMIC INTEGRITY DECLARATION
# ═══════════════════════════════════════════════════════════════
# I, [YOUR FULL NAME], declare that:
# 1. This code is my own work
# 2. I have not copied from colleagues or online sources
# 3. Any AI assistance used is documented below:
#    - Tool used: [None / ChatGPT / Claude / Copilot / Other]
#    - Prompts used: [Describe or "None"]
#    - What I modified and why: [Explain or "N/A"]
# 4. I can explain every line of this code verbally
#
# Student ID: [YOUR ID]
# Date: [SUBMISSION DATE]
# ═══════════════════════════════════════════════════════════════
```

**Missing declaration = automatic 10% penalty**

---

## 🎤 Oral Defence Requirement (20% of grade)

You **must** attend a scheduled oral defence session where you will:

1. **Explain your code** — walk through a function of the instructor's choosing
2. **Modify your code live** — implement a small change on the spot
3. **Discuss edge cases** — explain what happens in unusual scenarios

*This portion cannot be delegated to AI. See `S05_04_ORAL_DEFENCE_GUIDE.md` for full details.*

> 💡 **Pro tip from past students:** Practice explaining your code out loud before the viva. If you can't explain it to your rubber duck, you can't explain it to me.

---

## 📁 Submission Structure

Your submission must follow this exact structure:

```
homework_S05_YourName/
├── README.md                 # Overview and self-assessment
├── log_analyzer.sh           # Requirement 1 (40%)
├── config_manager.sh         # Requirement 2 (30%)
├── refactored_script.sh      # Requirement 3 (30%)
├── test_files/
│   ├── sample.log            # Your test log file
│   ├── large.log             # (Optional) Large file for stress testing
│   └── app.conf              # Your test config file
└── screenshots/
    ├── log_analyzer_output.png
    ├── config_manager_output.png
    └── shellcheck_clean.png  # Captured lint result for the tested revision
```

**Archive as:** `homework_S05_YourName_GroupNumber.zip`

---

## Requirements

### R1: Log Analyser (40%)

**Script:** `log_analyzer.sh`

Create a log file analyser that processes files in this format:
```
[2025-01-15 10:00:00] [INFO] Application started
[2025-01-15 10:00:05] [ERROR] Connection failed
```

#### Mandatory Features

| Feature | Points | Description |
|---------|--------|-------------|
| Argument parsing | 8 | `-h`, `-v`, `-l LEVEL`, `-o FILE`, `--top N` |
| Log line parsing | 8 | Extract timestamp, level, message using regex |
| Level statistics | 8 | Count entries per level (INFO, WARN, ERROR, DEBUG) |
| Top messages | 8 | Show N most frequent messages |
| Report generation | 8 | Formatted output with totals and percentages |

#### Expected Output Example

```
═══════════════════════════════════════════════════════════════
                    LOG ANALYSIS REPORT
═══════════════════════════════════════════════════════════════

File:        server.log
Total lines: 12

Level Distribution:
  INFO:   6 (50.0%)  ████████████████████
  WARN:   2 (16.7%)  ██████
  ERROR:  2 (16.7%)  ██████
  DEBUG:  2 (16.7%)  ██████

Top 3 Messages:
  1. "Application started" (2 occurrences)
  2. "Connection refused" (2 occurrences)
  3. "Config loaded" (1 occurrence)
═══════════════════════════════════════════════════════════════
```

#### Technical Requirements

- Must use `declare -A LEVEL_COUNT` for counting
- Must use `declare -A MESSAGE_COUNT` for message frequency
- Functions: `parse_line()`, `count_levels()`, `get_top_messages()`, `print_report()`
- All functions must use `local` for variables
- Must have `set -euo pipefail` and `trap EXIT`

---

### R2: Config Manager (30%)

**Script:** `config_manager.sh`

Create a configuration file manager that handles literal `key=value` data: identifiers match `[A-Za-z_][A-Za-z0-9_]*`; outer spaces around key/`=` are ignored; values are not evaluated as shell code. Document duplicate-key handling, blank values and whether trailing spaces are retained. The generated starter uses `test_files/app.conf`.

#### Commands to Implement

| Command | Usage | Description |
|---------|-------|-------------|
| `get` | `./config_manager.sh get HOST` | Print value of key |
| `set` | `./config_manager.sh set PORT 9090` | Set/update a key |
| `delete` | `./config_manager.sh delete DEBUG` | Remove a key |
| `list` | `./config_manager.sh list` | Show all key=value pairs |
| `validate` | `./config_manager.sh validate` | Check required keys exist |
| `export` | `./config_manager.sh export` | Output as `export KEY=value` |

#### Expected Behaviour

```console
$ ./config_manager.sh list
HOST=localhost
PORT=8080

$ ./config_manager.sh get PORT
8080

$ ./config_manager.sh set PORT 9090
Updated: PORT=9090

$ ./config_manager.sh validate
✓ HOST: localhost
✓ PORT: 9090
✗ DB_HOST: missing (required)
Validation failed: 1 missing key(s)
```

#### Technical Requirements

- Must use `declare -A CONFIG` for storage
- Must ignore comments (`#`) and empty lines
- Must handle `key=value` and `key = value` (spaces around `=`)
- Functions: `load_config()`, `save_config()`, `get_value()`, `set_value()`

---

### R3: Script Refactoring (30%)

**Script:** `refactored_script.sh`

You are given a broken script with **10 intentional problems**. Fix all of them.

#### Problems to Fix

| # | Problem | Hint |
|---|---------|------|
| 1 | Missing strict mode | Add `set -euo pipefail` |
| 2 | `$*` instead of `"$@"` | Preserves arguments with spaces |
| 3 | Unquoted array expansion | `${arr[@]}` → `"${arr[@]}"` |
| 4 | Global variables in functions | Add `local` keyword |
| 5 | Unquoted variable | `$var` → `"$var"` |
| 6 | UUOC (Useless Use of Cat) | `cat file \| cmd` → `cmd < file` |
| 7 | Missing `declare -A` | Required for associative arrays |
| 8 | Missing input validation | Check arguments exist |
| 9 | Missing usage function | Add `--help` support |
| 10 | Missing cleanup trap | Add `trap cleanup EXIT` |

#### Submission Format

For each fix, add a comment explaining:
```text
# FIX #3: Added quotes around array expansion
# BEFORE: for f in ${files[@]}
# AFTER:  for f in "${files[@]}"
# WHY:    Without quotes, elements with spaces are split
for f in "${files[@]}"; do
```

---

## 📋 Pre-Submission Checklist

### Code Quality
- [ ] `shellcheck log_analyzer.sh` — zero errors and warnings
- [ ] `shellcheck config_manager.sh` — zero errors and warnings  
- [ ] `shellcheck refactored_script.sh` — zero errors and warnings
- [ ] All scripts are executable (`chmod +x *.sh`)
- [ ] All scripts have the academic integrity header

### Functionality
- [ ] `./log_analyzer.sh --help` displays usage
- [ ] `./log_analyzer.sh test_files/sample.log` produces output
- [ ] `./config_manager.sh list` works
- [ ] `./config_manager.sh validate` correctly identifies missing keys

### Best Practices
- [ ] Every script starts with `set -euo pipefail`
- [ ] Every function uses `local` for its variables
- [ ] Associative arrays are declared with `declare -A`
- [ ] Arrays are quoted in loops: `"${arr[@]}"`
- [ ] `trap cleanup EXIT` is present

### Documentation
- [ ] README.md explains how to run each script
- [ ] Screenshots illustrate selected runs; include commands, statuses and repeatable test data
- [ ] Refactoring fixes are documented with comments

---

## ❓ Frequently Asked Questions

### General

**Q: Can I use AI tools like ChatGPT?**
> Yes, but you must (1) document exactly what you used, (2) explain what you modified and (3) be able to explain every line in the oral defence. A viva can assess demonstrated understanding; it does not by itself prove authorship or identify AI use.

**Q: What if shellcheck gives warnings I don't understand?**
> Google the SC code (e.g., "SC2086 shellcheck"). The wiki explains every warning. If still stuck, ask in the course forum — but show you tried first.

**Q: How strict is the output format?**
> The exact formatting doesn't need to match the examples pixel-perfect. What matters is that all required information is present and readable.

### Technical

**Q: My regex works in regex101.com but not in Bash?**
> Bash uses POSIX extended regex, not PCRE. Common gotchas: no `\d` (use `[0-9]`), no `+?` (use `+` or `{1,}`), must use `=~` operator.

**Q: How do I iterate over an associative array?**
> ```bash
> for key in "${!CONFIG[@]}"; do
>     echo "$key = ${CONFIG[$key]}"
> done
> ```

**Q: What's the difference between `${arr[@]}` and `${arr[*]}`?**
> With quotes: `"${arr[@]}"` preserves element boundaries, `"${arr[*]}"` joins into one string. Always use `"${arr[@]}"` in `for` loops.

**Q: How do I make `set -e` not exit on grep finding nothing?**
> Distinguish no match (status 1) from an operational error (status >1): `if grep "pattern" file; then :; else status=$?; (( status == 1 )) || exit "$status"; fi`. Do not suppress every error with `|| true`.

### Submission

**Q: Do I need to include the test files?**
> Yes! Include `test_files/` with your sample data. We need to be able to run your scripts.

**Q: What if my partner submitted something similar?**
> Each submission must be individual work. Similar structure is expected (we gave you templates), but the implementation details should differ.

---

## 🚫 Mistakes to check before submission

Use this checklist to review the implementation.

| Mistake | How to Avoid |
|---------|--------------|
| Missing `declare -A` for hash | **Always** declare before using `arr[string_key]` |
| Unquoted `${arr[@]}` in loops | Muscle memory: always type the quotes |
| Global variables in functions | Start every function with `local` declarations |
| No argument validation | First thing in `main()`: check `$#` |
| `cat file \| grep` pattern | Use `grep pattern file` or `grep pattern < file` |
| Missing cleanup trap | Add `trap cleanup EXIT` right after `set -euo` |
| `$*` instead of `"$@"` | Only use `$*` if you specifically want joined string |
| Hardcoded paths | Use variables: `CONFIG_FILE="${1:-default.conf}"` |
| No `--help` option | Every script should have `-h\|--help` |
| Romanian variable names | Keep it professional: English only |

---

## 📊 Grading Breakdown

| Component | Points | Graded On |
|-----------|--------|-----------|
| **Log Analyser** | 40 | Functionality, code quality, best practices |
| **Config Manager** | 30 | Functionality, code quality, best practices |
| **Refactoring** | 30 | All 10 fixes identified and explained |
| | | |
| **Oral Defence** | ×0.2 | Multiplied against total (see below) |

### Oral Defence Multiplier

Your written submission score is multiplied by your oral defence performance:

| Oral Performance | Multiplier | Example |
|------------------|------------|---------|
| Excellent (90-100%) | 1.0 | 85 written × 1.0 = 85 final |
| Good (75-89%) | 0.95 | 85 written × 0.95 = 80.75 final |
| Adequate (60-74%) | 0.85 | 85 written × 0.85 = 72.25 final |
| Poor (40-59%) | 0.70 | 85 written × 0.70 = 59.5 final |
| Fail (<40%) | 0.50 | 85 written × 0.50 = 42.5 final |

### Penalties

| Issue | Penalty |
|-------|---------|
| Missing academic integrity declaration | -10% |
| Missing `set -euo pipefail` | -5% per script |
| Non-local variable in function | -3% per occurrence |
| Shellcheck error (not warning) | -2% per error |
| Late submission | -10% per day (max 3 days) |

---

## 🆘 Getting Help

1. **Course forum** — Ask publicly so others benefit
2. **Office hours** — Check calendar for current schedule
3. **Email** — For private matters only; include `[SO-S05]` in subject

**Do NOT ask:** "My code doesn't work" with no details  
**DO ask:** "Line 47 gives SC2086, I tried quoting but now line 52 breaks. Here's my code: ..."

---

*Instructor: ing. dr. Antonio Clim | ASE Bucharest — CSIE*  
*Last updated: January 2025*
