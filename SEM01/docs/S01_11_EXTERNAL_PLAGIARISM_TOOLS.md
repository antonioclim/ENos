# External Plagiarism Detection Tools

> **For cohorts >50 students** | Supplements internal detector  
> **Version:** 1.0 | **Date:** January 2025

---

## Overview

The internal plagiarism detector (`S01_05_plagiarism_detector.py`) works well for quick checks and small cohorts. For larger groups or when you need structural comparison across semesters, use MOSS or JPlag.

| Tool | Best For | Requires | Turnaround |
|------|----------|----------|------------|
| Internal detector | Quick checks, <50 students | Python | Immediate |
| MOSS | Large cohorts, cross-semester | Internet, Perl | Minutes |
| JPlag | Offline analysis, detailed reports | Java | Immediate |

---

## 1. MOSS (Measure of Software Similarity)

MOSS is a free service from Stanford that's been the standard for academic plagiarism detection since 1994.

### 1.1 Registration (One-time)

1. Send an email to `moss@moss.stanford.edu`
2. **Subject line:** `registeruser`
3. **Body:** Just the word `registeruser` (nothing else)
4. Wait 24-48 hours
5. You'll receive a Perl script with your personal user ID embedded

Save the script as `moss.pl` in your working directory.

### 1.2 Basic Usage

```bash
# Submit all .sh files from student directories
perl moss.pl -l bash -d submissions/*/*.sh

# With base files (template code to ignore)
perl moss.pl -l bash -b template.sh -d submissions/*/*.sh

# Cross-semester comparison
perl moss.pl -l bash -d semester1/*/*.sh semester2/*/*.sh
```

### 1.3 Useful Options

| Option | Purpose | Example |
|--------|---------|---------|
| `-l bash` | Language (bash, python, c, java, etc.) | Required |
| `-d` | Compare by directory (group files by student) | Recommended |
| `-b file` | Base file (ignore matches to this template) | For starters |
| `-m N` | Max times a passage can appear before ignored | `-m 10` |
| `-n N` | Number of matches to show | `-n 250` |

### 1.4 Interpreting Results

MOSS returns a URL with results. The report shows:

| Similarity | Typical Meaning | Action |
|------------|-----------------|--------|
| <30% | Normal variation, common idioms | None |
| 30-50% | Some shared code, possibly collaboration | Review manually |
| 50-70% | Substantial overlap | Likely collaboration, interview both |
| 70-90% | Very high similarity | Probable plagiarism, investigate |
| >90% | Near-identical | Almost certainly copied |

**Important:** MOSS results expire after 14 days. Download or screenshot immediately!

### 1.5 Makefile Integration

```bash
# Already added to Makefile - usage:
make moss-check MOSS_USERID=123456789 SUBMISSIONS=./submissions/
```

---

## 2. JPlag

JPlag is an open-source alternative that runs locally — useful when you can't send code to external servers.

### 2.1 Installation

```bash
# Download latest release
wget https://github.com/jplag/JPlag/releases/download/v5.0.0/jplag-5.0.0-jar-with-dependencies.jar -O jplag.jar

# Verify installation
java -jar jplag.jar --version
```

Requires Java 17 or later.

### 2.2 Basic Usage

```bash
# Basic comparison
java -jar jplag.jar -l bash submissions/

# With minimum similarity threshold
java -jar jplag.jar -l bash -m 50 submissions/

# Specify output directory
java -jar jplag.jar -l bash -r results/ submissions/
```

### 2.3 Useful Options

| Option | Purpose | Example |
|--------|---------|---------|
| `-l bash` | Language | Required for shell scripts |
| `-m N` | Minimum similarity % to report | `-m 40` |
| `-r dir` | Results directory | `-r jplag_results/` |
| `-bc dir` | Base code directory (template to ignore) | `-bc template/` |
| `-n N` | Max comparisons to store | `-n 500` |

### 2.4 Viewing Results

JPlag generates an HTML report:

```bash
# Open results (Linux)
xdg-open jplag_results/index.html

# Open results (macOS)
open jplag_results/index.html

# Open results (WSL)
explorer.exe jplag_results/index.html
```

The report includes:
- Cluster visualisation showing groups of similar submissions
- Pairwise comparison with side-by-side diff
- Distribution histogram

### 2.5 Makefile Integration

```bash
# Already added to Makefile - usage:
make jplag-check SUBMISSIONS=./submissions/
```

---

## 3. Recommended Workflow

Here's the complete anti-plagiarism pipeline for a typical seminar:

```
┌─────────────────────────────────────────────────────────────────┐
│                     SUBMISSIONS RECEIVED                         │
│              (deadline passed, archive collected)                │
└─────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────┐
│  STAGE 1: Autograder                                            │
│  ─────────────────────                                          │
│  • Run: python3 S01_01_autograder.py submissions/StudentX/      │
│  • Generates: score + oral questions                            │
│  • Time: ~30 seconds per student                                │
└─────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────┐
│  STAGE 2: Internal Plagiarism Detector                          │
│  ─────────────────────────────────────                          │
│  • Run: make plagiarism-check SUBMISSIONS=./submissions/        │
│  • Catches: exact copies, reordering, AI patterns               │
│  • Time: ~2 minutes for 50 students                             │
└─────────────────────────────────────────────────────────────────┘
                                │
                     Cohort size > 50?
                      │           │
                     YES          NO
                      │           │
                      ▼           │
┌─────────────────────────────────┐          │
│  STAGE 2b: MOSS or JPlag        │          │
│  ───────────────────────        │          │
│  • For structural similarity    │          │
│  • Cross-semester comparison    │          │
│  • Time: 5-10 minutes           │          │
└─────────────────────────────────┘          │
                      │                       │
                      ▼                       ▼
┌─────────────────────────────────────────────────────────────────┐
│  STAGE 3: Flag Review                                           │
│  ────────────────────                                           │
│  • Review all pairs >70% similarity                             │
│  • Check for legitimate collaboration (pair programming)        │
│  • Prepare specific questions for oral verification             │
└─────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────┐
│  STAGE 4: Oral Verification                                     │
│  ──────────────────────────                                     │
│  • Use: S01_04_ORAL_VERIFICATION_LOG.md                         │
│  • All students (random 2 questions)                            │
│  • Flagged students (targeted questions about suspicious code)  │
│  • Time: 3-5 minutes per student                                │
└─────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────┐
│  STAGE 5: Final Decision                                        │
│  ───────────────────────                                        │
│  • Clear: Grade normally                                        │
│  • Suspicious: Request resubmission or zero                     │
│  • Confirmed plagiarism: Academic integrity process             │
└─────────────────────────────────────────────────────────────────┘
```

---

## 4. Tips for Effective Detection

### Before the Assignment

1. **Use the assignment generator** — randomised variants make direct copying harder
2. **Announce detection** — deterrence works (students know you check)
3. **Keep previous semesters' submissions** — for cross-semester comparison

### During Grading

1. **Run internal detector first** — it's fast and catches obvious cases
2. **Use MOSS for structural similarity** — catches "paraphrased" code
3. **Trust your instincts** — if code seems inconsistent with a student's level, investigate

### Common False Positives

These often trigger high similarity but aren't plagiarism:

- **Template code** — use base file option to exclude
- **Common idioms** — `set -euo pipefail`, standard loops
- **Pair programming partners** — verify they're registered as a pair
- **Online tutorials** — similar to MOSS's base corpus

### Documentation

Always keep:
- [ ] Plagiarism detector reports (JSON export)
- [ ] MOSS URLs (screenshot before they expire!)
- [ ] JPlag HTML reports
- [ ] Oral verification logs
- [ ] Any email correspondence

---

## 5. Comparison of Detection Methods

| Method | Exact Copies | Reordering | Variable Renaming | Structural Changes | AI-Generated |
|--------|--------------|------------|-------------------|-------------------|--------------|
| Internal (hash) | ✓✓✓ | ✗ | ✗ | ✗ | ✗ |
| Internal (sorted) | ✓✓✓ | ✓✓✓ | ✗ | ✗ | ✗ |
| Internal (AI patterns) | ✗ | ✗ | ✗ | ✗ | ✓✓ |
| MOSS | ✓✓✓ | ✓✓ | ✓✓ | ✓ | ✗ |
| JPlag | ✓✓✓ | ✓✓ | ✓✓ | ✓✓ | ✗ |
| Oral verification | ✓ | ✓ | ✓ | ✓ | ✓✓✓ |

**Legend:** ✓✓✓ = Excellent, ✓✓ = Good, ✓ = Partial, ✗ = Not detected

---

## 6. Troubleshooting

### MOSS Issues

| Problem | Solution |
|---------|----------|
| "Connection refused" | Stanford servers may be down — try later |
| "Invalid user ID" | Re-register, IDs occasionally expire |
| No results URL | Check that files were actually uploaded |
| Results page empty | May have submitted incompatible file types |

### JPlag Issues

| Problem | Solution |
|---------|----------|
| "Unsupported class file" | Update Java to version 17+ |
| "No submissions found" | Check directory structure — needs subdirectories |
| OutOfMemoryError | Add `-Xmx4g` before `-jar` |
| Report won't open | Try different browser, check JavaScript enabled |

---

*External plagiarism tools guide | Version 1.0 | January 2025*  
*Operating Systems | ASE Bucharest - CSIE*
