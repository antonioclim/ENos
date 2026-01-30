# External Plagiarism Detection Integration

> **Purpose:** Guide for using external plagiarism detection tools with the ENos kit  
> **Audience:** Instructors and teaching assistants  
> **Last Updated:** January 2025

This guide explains how to integrate external plagiarism detection tools (MOSS and JPlag) with the ENos educational kit for comprehensive academic integrity verification.

---

## Overview

| Tool | Type | Languages | Access | Best For |
|------|------|-----------|--------|----------|
| **MOSS** | Online service | Bash, Python, C, Java, etc. | Free (academic) | Quick checks, large classes |
| **JPlag** | Self-hosted | Java, Python, C, Bash, text | Open source | Privacy-sensitive, offline use |

Both tools complement the internal similarity checker (`S01_05_plagiarism_detector.py`) by providing more sophisticated analysis algorithms.

---

## MOSS (Measure of Software Similarity)

### What is MOSS?

MOSS is a free plagiarism detection service developed at Stanford University. It compares submitted code files and identifies similar passages, providing a web-based report with highlighted matches.

**Key features:**

- Supports 25+ programming languages
- Excludes base/starter code from comparison
- Handles large submission sets efficiently
- Provides percentage similarity scores
- Free for academic use

### Obtaining MOSS Access

1. **Request an account:**
   ```
   To: moss@moss.stanford.edu
   Subject: New MOSS Account Request
   
   Dear MOSS Team,
   
   I am requesting a MOSS account for plagiarism detection.
   
   Name: [Your name]
   Institution: [Your university]
   Email: [Your institutional email]
   Purpose: Academic integrity for Operating Systems course
   
   Thank you.
   ```

2. **Receive the MOSS script** (typically within 24-48 hours)

3. **Save the script** as `moss.pl` in `SEM07/external_tools/`

4. **Make it executable:**
   ```bash
   chmod +x moss.pl
   ```

### Using MOSS with ENos

**Basic usage — single seminar:**
```bash
# Compare all Bash submissions from SEM03
./moss.pl -l bash -d SEM03/submissions/*/*.sh

# Compare Python submissions from SEM05
./moss.pl -l python -d SEM05/submissions/*/*.py
```

**Excluding starter code:**
```bash
# Use -b flag to specify base files (excluded from comparison)
./moss.pl -l bash \
    -b SEM03/homework/starter/*.sh \
    -d SEM03/submissions/*/*.sh
```

**Multiple file types:**
```bash
# Compare both .sh and .bash files
./moss.pl -l bash \
    -d SEM03/submissions/*/*.sh \
    -d SEM03/submissions/*/*.bash
```

**Setting match threshold:**
```bash
# -m sets minimum match length (default: varies by language)
./moss.pl -l bash -m 10 -d SEM03/submissions/*/*.sh
```

### Interpreting MOSS Results

MOSS provides a URL to a web-based report. Each pair of submissions shows:

| Similarity % | Interpretation | Recommended Action |
|--------------|----------------|-------------------|
| 0-25% | Normal | No action needed |
| 25-50% | Possible collaboration | Review manually, check timestamps |
| 50-75% | Likely copying | Oral verification required |
| >75% | Almost certain plagiarism | Formal academic integrity process |

**Important considerations:**

- High similarity in boilerplate code is expected
- Check the highlighted sections, not just percentages
- Consider submission timestamps
- Multiple high matches may indicate a "source" submission

---

## JPlag

### What is JPlag?

JPlag is an open-source plagiarism detection tool that can be self-hosted, making it suitable for situations where data privacy is a concern.

**Key features:**

- No external data transmission
- Detailed local HTML reports
- Token-based comparison (language-aware)
- Cluster visualisation
- Customisable thresholds

### Installation

**Option 1: Docker (recommended)**
```bash
# Pull the official image
docker pull jplag/jplag:latest

# Verify installation
docker run jplag/jplag --version
```

**Option 2: JAR file**
```bash
# Download latest release
wget https://github.com/jplag/JPlag/releases/latest/download/jplag.jar

# Verify
java -jar jplag.jar --version
```

**Option 3: Build from source**
```bash
git clone https://github.com/jplag/JPlag.git
cd JPlag
mvn clean package -DskipTests
```

### Using JPlag with ENos

**Docker usage:**
```bash
# Basic comparison
docker run -v $(pwd)/SEM03/submissions:/submissions \
    jplag/jplag \
    -l bash \
    /submissions

# With output directory
docker run \
    -v $(pwd)/SEM03/submissions:/submissions \
    -v $(pwd)/SEM03/jplag_results:/results \
    jplag/jplag \
    -l bash \
    -r /results \
    /submissions
```

**JAR usage:**
```bash
# Basic comparison
java -jar jplag.jar \
    -l bash \
    -r SEM03/jplag_results/ \
    SEM03/submissions/

# With base code exclusion
java -jar jplag.jar \
    -l bash \
    -bc SEM03/homework/starter/ \
    -r SEM03/jplag_results/ \
    SEM03/submissions/
```

**Useful options:**

| Option | Description |
|--------|-------------|
| `-l <lang>` | Language (bash, python, java, c, text) |
| `-r <dir>` | Results directory |
| `-bc <dir>` | Base code directory (excluded) |
| `-t <num>` | Minimum match length |
| `-m <pct>` | Similarity threshold for report |

### JPlag Output

Results are generated as an HTML report:

```
jplag_results/
├── index.html          # Main report with overview
├── overview.json       # Machine-readable summary
└── submissions/        # Individual comparison pages
```

Open `index.html` in a browser to view:
- Similarity matrix
- Submission clusters
- Detailed pair comparisons with highlighted matches

---

## Integration with ENos Autograder

### Recommended Workflow

```
1. Collect submissions
   └── run_autograder.py → grades.json

2. Run internal similarity check
   └── S01_05_plagiarism_detector.py → similarity_report.json

3. Run AI fingerprint scan
   └── S01_06_ai_fingerprint_scanner.py → ai_fingerprint_report.json

4. Run external plagiarism detection
   ├── MOSS (online) → similarity report URL
   └── JPlag (local) → HTML report

5. Cross-reference results
   └── Flag submissions with >50% similarity OR AI score <7

6. Oral verification for flagged submissions
   └── Use SEM07/project_evaluation/oral_defence_questions_EN.md

7. Final decision and documentation
   └── Record in evaluation log
```

### Best Practices

1. **Run detection early** — Before grading, not after complaints
2. **Use multiple tools** — MOSS + JPlag + internal checker
3. **Document everything** — Keep logs of all checks and decisions
4. **Oral verification** — Always verify flagged submissions in person
5. **Fair process** — Apply same rules consistently to everyone
6. **Consider context** — Some similarity is expected in assignments
7. **Preserve evidence** — Save reports before URLs expire

### Common Issues and Solutions

| Issue | Solution |
|-------|----------|
| MOSS URL expired | Save reports immediately; they expire in 14 days |
| JPlag memory error | Increase Java heap: `java -Xmx4g -jar jplag.jar` |
| False positives | Check base code exclusion; review manually |
| Language not detected | Specify language explicitly with `-l` flag |
| Submission structure varies | Standardise with `run_plagiarism_check.sh` |

---

## References

- **MOSS:** https://theory.stanford.edu/~aiken/moss/
- **JPlag:** https://github.com/jplag/JPlag
- **JPlag Documentation:** https://jplag.github.io/JPlag/
- **Academic Integrity:** Consult your institution's policy

---

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | Jan 2025 | Initial version for FAZA 5 |
