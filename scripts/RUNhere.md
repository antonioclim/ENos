# 📁 Global Scripts — Kit Infrastructure

> **Location:** `/scripts/`  
> **Purpose:** Kit-wide automation for quality assurance and maintenance

## Contents

| Script | Purpose | Usage Context |
|--------|---------|---------------|
| `add_print_styles.sh` | Inject print-friendly CSS into HTML presentations | Build process |
| `check_links.sh` | Comprehensive documentation link validator | CI/CD, pre-release |
| `verify_links.sh` | Alternative link checker (lightweight) | Quick local checks |

## Quick Start

```bash
# Make scripts executable (once)
chmod +x *.sh

# Check all documentation links
./check_links.sh

# Add print styles to all HTML files
./add_print_styles.sh ../05_LECTURES/
```

## Detailed Usage

### add_print_styles.sh

Injects `@media print` CSS rules into HTML presentations for clean offline printing.

```bash
# Process single directory
./add_print_styles.sh ../SEM01/presentations/

# Process entire kit
./add_print_styles.sh ../

# Dry run (preview changes)
./add_print_styles.sh --dry-run ../05_LECTURES/
```

**What it does:**
- Adds page break rules before `<h1>` elements
- Hides navigation elements in print
- Optimises font sizes for paper
- Preserves existing styles

### check_links.sh

Validates all internal and external links in Markdown and HTML documentation.

```bash
# Full check (internal + external)
./check_links.sh

# Internal links only (faster)
./check_links.sh --internal-only

# Specific directory
./check_links.sh ../SEM03/docs/

# Generate report
./check_links.sh --report links_report.txt
```

**Output codes:**
- `[OK]` — Link valid
- `[WARN]` — External link timeout (may still work)
- `[FAIL]` — Broken link

### verify_links.sh

Lightweight alternative for quick local verification.

```bash
# Quick check
./verify_links.sh ../README.md

# Verbose mode
./verify_links.sh -v ../05_LECTURES/
```

## Integration with CI

These scripts are called by GitHub Actions workflows. See individual `SEM*/ci/github_actions.yml` for integration examples.

```yaml
# Example CI step
- name: Check documentation links
  run: ./scripts/check_links.sh --internal-only
```

## Dependencies

- `bash` ≥ 4.0
- `curl` (for external link checks)
- `grep`, `sed`, `awk` (standard Unix tools)

## Troubleshooting

| Issue | Solution |
|-------|----------|
| "Permission denied" | Run `chmod +x *.sh` |
| External links timeout | Use `--internal-only` flag |
| False positives on anchors | Check if target file has matching `id` attribute |

---

*Maintainer: Kit infrastructure team*  
*Last updated: January 2026*
