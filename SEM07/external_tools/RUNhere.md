# 📁 External Tools — Plagiarism Detection

> **Location:** `SEM07/external_tools/`  
> **Purpose:** Integration with external plagiarism detection services  
> **Audience:** Instructors only

## Contents

| Script | Service | Purpose |
|--------|---------|---------|
| `run_moss.sh` | Stanford MOSS | Code similarity detection |
| `run_plagiarism_check.sh` | Combined pipeline | Orchestrates all checks |

---

## MOSS Integration

### Prerequisites

1. **Register for MOSS:**
   - Visit: http://theory.stanford.edu/~aiken/moss/
   - Request a user ID via email
   - Save your ID: `echo "YOUR_ID" > ~/.moss_userid`

2. **Install MOSS client:**
   ```bash
   # Usually bundled, or download from MOSS website
   chmod +x moss.pl
   ```

### Usage

```bash
./run_moss.sh <submissions_dir> [options]

Options:
  -l LANG       Language: bash, python, c, java, etc.
  -d            Directory mode (one submission per folder)
  -b FILE       Base file (template code to ignore)
  -m N          Maximum matches to show (default: 250)
  -n N          Maximum files in a match (default: 2)
```

### Examples

```bash
# Check Bash scripts
./run_moss.sh submissions/ -l bash

# With base file (ignore template code)
./run_moss.sh submissions/ -l bash -b template.sh

# Multiple languages
./run_moss.sh submissions/ -l bash -l python
```

### Output

MOSS returns a URL to view results:
```
Results available at: http://moss.stanford.edu/results/XXXXX
```

---

## Combined Plagiarism Check

### Usage

```bash
./run_plagiarism_check.sh <submissions_dir> [options]

Options:
  --threshold N     Similarity threshold (0.0-1.0, default: 0.7)
  --report FILE     Output report file
  --format FMT      Report format: html, csv, json
  --include-moss    Include MOSS analysis
  --local-only      Skip external services
```

### What It Checks

| Check | Method | Detects |
|-------|--------|---------|
| Exact matches | Hash comparison | Copy-paste plagiarism |
| Near matches | Diff analysis | Minor modifications |
| Structural similarity | AST comparison | Refactored code |
| MOSS analysis | External service | Sophisticated plagiarism |

### Example Workflow

```bash
# Quick local check
./run_plagiarism_check.sh submissions/ --local-only --threshold 0.8

# Full analysis with report
./run_plagiarism_check.sh submissions/ --include-moss --report plagiarism_report.html

# CSV for spreadsheet analysis
./run_plagiarism_check.sh submissions/ --format csv --report results.csv
```

---

## Output Interpretation

### Similarity Scores

| Score | Interpretation | Action |
|-------|----------------|--------|
| < 30% | Normal | No action needed |
| 30-50% | Elevated | Review manually |
| 50-70% | High | Likely collaboration |
| > 70% | Very high | Probable plagiarism |

### Report Format

```
═══════════════════════════════════════════════════════════════
 PLAGIARISM ANALYSIS REPORT
═══════════════════════════════════════════════════════════════

Submissions analysed: 45
Pairs checked: 990
Flagged pairs: 12

HIGH SIMILARITY (>70%):
  student_A ↔ student_B: 85% (MOSS: 82%)
  student_C ↔ student_D: 78% (MOSS: 75%)

ELEVATED (50-70%):
  student_E ↔ student_F: 62% (MOSS: 58%)
  ...

Full MOSS report: http://moss.stanford.edu/results/XXXXX
═══════════════════════════════════════════════════════════════
```

---

## Best Practices

### Before Running

- Remove template/starter code from analysis
- Exclude common library imports
- Set appropriate threshold for assignment type

### Interpreting Results

- **Always review manually** — false positives are common
- Consider assignment constraints (limited solutions possible)
- Check submission timestamps
- Interview suspected students

### Documentation

Keep records for academic integrity proceedings:
- Screenshot of MOSS results
- Local analysis report
- Student submission timestamps
- Interview notes

---

*See also: [`MOSS_JPLAG_GUIDE.md`](MOSS_JPLAG_GUIDE.md) for detailed documentation*  
*See also: [`../homework_evaluation/`](../homework_evaluation/) for grading*

*Last updated: January 2026*
