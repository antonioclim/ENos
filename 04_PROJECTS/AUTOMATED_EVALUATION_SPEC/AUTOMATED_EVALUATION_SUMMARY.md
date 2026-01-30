# EXECUTIVE SUMMARY: Automatic Evaluation System for OS Projects

## Synthesis Document | Final Version

---

## 1. Automatic Evaluation Capacity - Synthesis

### 1.1 Global Percentages

| Level | Projects | Auto Evaluable | Requires Manual | Evaluation Time |
|-------|----------|----------------|-----------------|-----------------|
| **EASY** | E01-E05 | **90-95%** | 5-10% | 3-5 min |
| **MEDIUM** | M01-M15 | **80-90%** | 10-20% | 8-12 min |
| **ADVANCED** | A01-A03 | **75-85%** | 15-25% | 12-15 min |

### 1.2 Breakdown per Test Category

```
╔═══════════════════════════════════════════════════════════════════════════╗
║                    EVALUABILITY BY CATEGORY                               ║
╠═══════════════════════════════════════════════════════════════════════════╣
║                                                                           ║
║  FULLY AUTOMATIC (100%):                                                  ║
║  ├── ✓ File structure (exists src/, README.md, etc.)                     ║
║  ├── ✓ Syntax (bash -n, ShellCheck)                                      ║
║  ├── ✓ Exit codes                                                         ║
║  ├── ✓ Output contains expected strings                                   ║
║  ├── ✓ Files created/modified correctly                                   ║
║  ├── ✓ Timeouts respected                                                 ║
║  ├── ✓ C compilation (for ADVANCED)                                       ║
║  └── ✓ Memory leaks (Valgrind)                                            ║
║                                                                           ║
║  PARTIALLY AUTOMATIC (50-80%):                                            ║
║  ├── ◐ Code quality (metrics, not semantics)                              ║
║  ├── ◐ Error handling (common cases, not all)                             ║
║  ├── ◐ Logging (presence and format, not usefulness)                      ║
║  ├── ◐ Configuration (parsing, not complete validation)                   ║
║  └── ◐ Performance (relative, not absolute)                               ║
║                                                                           ║
║  MANUAL REQUIRED (0-30%):                                                 ║
║  ├── ✗ Documentation quality (content, not length)                        ║
║  ├── ✗ UX / Output clarity                                                ║
║  ├── ✗ Code elegance / Style                                              ║
║  ├── ✗ Solution creativity                                                ║
║  ├── ✗ Rare/unexpected edge cases                                         ║
║  └── ✗ Integration with real external systems                             ║
║                                                                           ║
╚═══════════════════════════════════════════════════════════════════════════╝
```

---

## 2. Complete List: Criteria NOT EVALUABLE Automatically

### 2.1 General Categories

| Category | Specific Criteria | Reason | Partial Solution |
|----------|-------------------|--------|------------------|
| **Documentation** | Clarity, completeness, usefulness | Requires semantic understanding | Verify minimum length |
| **UX/Output** | Readability, formatting, colours | Subjective, preferences | Verify ANSI codes present |
| **Code Quality** | Elegance, style, naming | Subjective | Metrics (LOC/function, comments) |
| **Creativity** | Innovative solutions, extras | Cannot be quantified | Manual bonus |
| **Robustness** | Rare edge cases | Impossible to anticipate all | Tests for common cases |
| **Integrations** | External services, APIs | Requires infrastructure | Mocks |
| **Security** | Subtle vulnerabilities | Requires expert audit | Basic checks |

### 2.2 Per Project - Detailed List

#### EASY Projects
```
E01 - File System Auditor
  ✗ Report clarity (5%)
  ✗ README quality (2%)
  ✗ Code elegance (3%)

E02 - Log Analyzer  
  ✗ Human-readable formatting (5%)
  ✗ Support for non-standard formats (5%)

E03 - Bulk File Organizer
  ✗ Conflict strategy (3%)
  ✗ Organisation intuitiveness (2%)

E04 - System Health Reporter
  ✗ Output readability (10%)
  ✗ Information relevance (5%)

E05 - Config File Manager
  ✗ Backup storage organisation (5%)
```

#### MEDIUM Projects
```
M01 - Incremental Backup
  ✗ Incremental algorithm efficiency (5%)
  ✗ Robustness to interruptions (3%)
  ✗ Logging quality (2%)

M02 - Process Monitor
  ✗ Dashboard UI quality (10%)
  ✗ Measurement accuracy (5%)

M03 - Service Watchdog
  ✗ Real email/Slack alerting (5%)
  ✗ Intelligent escalation (3%)

M04 - Network Scanner
  ✗ Accurate service identification (5%)
  ✗ Vulnerability correlation (5%)

M05 - Deployment Pipeline
  ✗ Real CI/CD integration (5%)
  ✗ Complete blue-green (5%)

M06 - Resource Historian
  ✗ Visualisation quality (8%)
  ✗ Prediction accuracy (5%)

M07 - Security Audit
  ✗ Recommendation relevance (10%)
  ✗ False positive rate (5%)

M08 - Disk Manager
  ✗ Delete operation safety (5%)
  ✗ Space prediction (5%)

M09 - Task Scheduler
  ✗ Complex cron validation (3%)
  ✗ Real systemd integration (5%)

M10 - Process Tree
  ✗ Anomaly detection in real context (5%)

M11 - Memory Forensics
  ✗ Real leak detection (10%)
  ✗ Differentiating leak vs normal (5%)

M12 - File Integrity
  ✗ False positive rate (5%)
  ✗ Performance at scale (5%)

M13 - Log Aggregator
  ✗ Custom format parsing (5%)
  ✗ Intelligent correlations (5%)

M14 - Config Manager
  ✗ Encryption security (8%)
  ✗ Business logic validation (5%)

M15 - Parallel Engine
  ✗ Race conditions (5%)
  ✗ Synchronisation correctness (5%)
```

#### ADVANCED Projects
```
A01 - Job Scheduler
  ✗ Fair-share scheduling correctness (10%)
  ✗ C code quality (5%)
  ✗ Crash robustness (5%)

A02 - Shell Extension
  ✗ Real terminal UX (15%)
  ✗ Colour/theme aesthetics (5%)
  ✗ Perceptible performance (5%)

A03 - File Sync
  ✗ rsync algorithm efficiency (10%)
  ✗ Real network protocol (5%)
  ✗ Conflict strategy (5%)
```

---

## 3. Recommended Architecture

### 3.1 System Components

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         AUTOMATIC OS EVALUATOR                              │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌───────────────┐     ┌───────────────┐     ┌───────────────┐             │
│  │   FRONTEND    │     │   BACKEND     │     │   WORKERS     │             │
│  │               │     │               │     │               │             │
│  │ • Upload ZIP  │────▶│ • Queue Jobs  │────▶│ • Docker      │             │
│  │ • View Report │◀────│ • Store       │◀────│   Sandbox     │             │
│  │ • Feedback    │     │   Results     │     │ • Run Tests   │             │
│  └───────────────┘     └───────────────┘     └───────────────┘             │
│         │                     │                     │                       │
│         │              ┌──────┴──────┐              │                       │
│         │              │  DATABASE   │              │                       │
│         │              │ • Students  │              │                       │
│         │              │ • Results   │              │                       │
│         │              │ • Metrics   │              │                       │
│         │              └─────────────┘              │                       │
│         │                                           │                       │
│  ┌──────┴───────────────────────────────────────────┴──────┐               │
│  │                    TEST DEFINITIONS                      │               │
│  │  • YAML configs per project                             │               │
│  │  • Expected outputs                                     │               │
│  │  • Scoring rules                                        │               │
│  └─────────────────────────────────────────────────────────┘               │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 3.2 Evaluation Flow

```
1. SUBMISSION (Student)
   │
   ├── Upload ZIP via web interface
   ├── Format validation (< 50MB, correct structure)
   └── Assign to queue
   
2. INTAKE (Worker)
   │
   ├── Extract in isolated container
   ├── Automatic project detection (from README or filename pattern)
   ├── Minimal structure validation
   └── Load corresponding test suite
   
3. STATIC ANALYSIS (2-3 min)
   │
   ├── ShellCheck (all .sh files)
   ├── bash -n (syntax check)
   ├── Code metrics (LOC, functions, comments)
   └── Directory structure
   
4. RUNTIME TESTS (5-15 min)
   │
   ├── Build (for ADVANCED)
   ├── Unit tests (isolated functionalities)
   ├── Integration tests (complete flow)
   ├── Error handling tests
   └── Performance tests (with timeout)
   
5. SCORING (1 min)
   │
   ├── Aggregate results
   ├── Apply weights per category
   ├── Calculate penalties/bonuses
   └── Generate final score
   
6. REPORT (instant)
   │
   ├── Generate detailed report (JSON + HTML)
   ├── Problem highlighting
   ├── Improvement suggestions
   └── Comparison with class average (optional)
```

### 3.3 Docker Sandbox Specification

```dockerfile
# Dockerfile for evaluation
FROM ubuntu:24.04

# Tools for all projects
RUN apt-get update && apt-get install -y \
    # Bash & Core
    bash coreutils findutils grep sed gawk \
    # Analysis
    shellcheck \
    # Networking (for M04)
    netcat-openbsd nmap iproute2 \
    # Database (for M06, M12)
    sqlite3 \
    # Filesystem monitoring (for M12)
    inotify-tools \
    # Compression (for M01)
    gzip bzip2 xz-utils \
    # JSON processing
    jq \
    # C Development (for ADVANCED)
    gcc make valgrind gdb \
    libreadline-dev libssl-dev \
    # Python (for helper tests)
    python3 python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Security: unprivileged user
RUN useradd -m -s /bin/bash evaluator
USER evaluator
WORKDIR /home/evaluator

# Limits
ENV TIMEOUT_DEFAULT=60
ENV TIMEOUT_MAX=300
ENV MAX_MEMORY="512m"
ENV MAX_PIDS=100
```

---

## 4. Implementation Recommendations

### 4.1 Development Prioritisation

```
PHASE 1 (MVP - 2-3 weeks):
├── Infrastructure: Docker sandbox, job queue
├── Static analysis: ShellCheck, structure
├── Basic functional tests: EASY projects
└── Simple reporting: pass/fail + score

PHASE 2 (Complete - 2-3 weeks):
├── Full test suites: MEDIUM projects
├── Advanced tests: C compilation, Valgrind
├── Detailed reporting: per-category breakdown
└── Basic web interface

PHASE 3 (Polish - 1-2 weeks):
├── Performance optimisation
├── Plagiarism detection (MOSS integration)
├── Statistics & analytics
└── Manual review interface
```

### 4.2 Test Maintenance

```yaml
test_maintenance_guidelines:
  versioning:
    - Each test suite versioned
    - Changelog for modifications
    - Backward compatibility 2 versions
    
  updates:
    trigger_new_tests:
      - Bug in existing test
      - New project requirement
      - Discovered edge case
      
  deprecation:
    - Announcement 2 weeks before
    - Grace period for resubmit
```

### 4.3 Handling Edge Cases

```
COMMON PROBLEMS AND SOLUTIONS:

1. Script has different shebang (#!/usr/bin/env bash)
   → Accept both variants
   
2. Different main file name
   → Automatic detection or fail with clear message
   
3. Uninstalled external dependencies
   → Pre-install in container OR skip test with notification
   
4. Infinite loop in student script
   → Strict timeout per test (60s default)
   
5. Fork bomb
   → PID limit in container (--pids-limit=100)
   
6. Disk fill
   → Quota per container (1GB)
   
7. Network abuse
   → Network isolation (localhost only)
```

---

## 5. Recommended Scoring Model

### 5.1 Formula

```
FINAL_SCORE = (AUTO_SCORE × 0.85) + (MANUAL_SCORE × 0.15)

Where:
AUTO_SCORE = Σ(category_i × weight_i) - penalties + bonuses

Default categories and weights:
├── Structural:        10%
├── Static Analysis:   10%
├── Functional Core:   40%
├── Functional Opt:    15%
├── Error Handling:    10%
├── Performance:        5%
├── Code Quality:       5%
└── Documentation:      5%

Penalties:
├── ShellCheck errors:     -2% per error (max -15%)
├── Timeout exceeded:      -50% for that test
├── Crash/Segfault:        -100% for that test

Bonuses:
├── All tests pass:        +3%
├── Zero warnings:         +2%
├── Kubernetes extension:  +10%
```

### 5.2 Mapping to Grades

```
Score    Grade   Description
─────────────────────────────────────
95-100   10      Exceptional
90-94    9       Very good
80-89    8       Good
70-79    7       Satisfactory
60-69    6       Sufficient
50-59    5       Minimum acceptable
< 50     4       Insufficient
```

---

## 6. Conclusions

### What works well automatically:
- Structure and syntax checks
- Functional tests with defined input/output
- Compilation and linking (C)
- Memory safety (Valgrind)
- Performance (timeouts)

### What requires human evaluation:
- Documentation quality
- UX and output clarity
- Creativity and elegance
- Unexpected edge cases
- Integrations with real systems

### Final recommendation:
**Hybrid model 85% automatic + 15% manual** provides:
- Fast feedback (under 15 minutes)
- Consistency in evaluation
- Scalability for large classes
- Flexibility for subjective aspects

---

*Document generated for the Operating Systems course | ASE-CSIE | 2024-2025*
