# EXECUTIVE SUMMARY: Automatic Evaluation System for OS Projects

## Status and executable boundary (Phase 5 correction)

These are **author proposals**, not an adopted grading system or a measured
automation result. Original points, percentages, time estimates and competing
grade/penalty proposals are retained as planning history. `total_points` now
equals the sum of the displayed case points; it is not an automatic rescaling to
100. No final grade, bonus, deduction, disclosure or publication policy is selected.

The implemented [local reference](../helpers/evaluation_reference.py) validates
the finite structured predicates printed below and emits JSON once. Unknown
operators, malformed values and duplicate JSON/YAML keys are errors. `all`, `any`
and `not` are explicit; string lists do not have an implicit OR meaning. A `pending`
predicate is a concrete unresolved adapter/author requirement: it reports NOT_RUN,
never PASS, and prevents a purported complete percentage. Existing project CLI
alternatives remain proposed interfaces until the author resolves their contract.

Each explicitly authorised trusted local case uses a fresh owned project copy and
`FIXTURE_ROOT`; inherited setup runs again before every case. Setup and cleanup
share one shell; only explicitly exported variables reach the command child.
Background fixtures must retain their parent, export their PID and be killed and
waited for. The runner also terminates its own process group on timeout. Permission
oracles require a non-root fixture user. No shared `/tmp` paths, host crontab,
services, HOME directory or unrelated IPC objects are part of the local contract.

This helper is **not a sandbox for untrusted submissions**. It supplies a wall-time
and output bound for trusted fixtures, not CPU/RAM/PID/disk/network containment.
`requires_platform` cases are reported NOT_RUN. A production isolation backend,
archive intake, student execution, notifications and institutional acceptance are
not implemented or executed by this repair. Use the regression tests for the
implemented boundary, not the proposal's planning percentages as evidence.

```bash
# Validation does not execute setup or project commands; YAML requires PyYAML.
python3 04_PROJECTS/helpers/evaluation_reference.py validate owned-suite.yaml
# This opt-in is only for a trusted, owned fixture, never an untrusted submission.
python3 04_PROJECTS/helpers/evaluation_reference.py run owned-suite.yaml --run-owned --project owned-fixture
python3 -m unittest discover -s 04_PROJECTS/tests -p test_evaluation_spec.py -v
```

The local reference uses all-or-nothing points per asserted case only to demonstrate
arithmetic. Partial credit and institutional consequences remain explicit author
choices. See [the assessment/evidence contract](../ASSESSMENT_AND_EVIDENCE_CONTRACT.md).


## Synthesis Document | Historical proposal with Phase 5 corrections

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
║  FINITE AUTOMATIC CHECKS (coverage estimate, not proof):                                                  ║
║  ├── ✓ File structure (exists src/, README.md, etc.)                     ║
║  ├── ✓ Syntax (bash -n, ShellCheck)                                      ║
║  ├── ✓ Exit codes                                                         ║
║  ├── ✓ Output contains expected strings                                   ║
║  ├── ✓ Files created/modified correctly                                   ║
║  ├── ✓ Timeouts respected                                                 ║
║  ├── ✓ C compilation (for ADVANCED)                                       ║
║  └── ✓ Observed leaks on exercised paths (Valgrind)                                            ║
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

## 2. Complete List: Criteria Requiring Additional or Human Evidence

### 2.1 General Categories

| Category | Specific Criteria | Reason | Partial Solution |
|----------|-------------------|--------|------------------|
| **Documentation** | Clarity, completeness, usefulness | Requires semantic understanding | Verify minimum length |
| **UX/Output** | Readability, formatting, colours | Subjective, preferences | Verify ANSI codes present |
| **Code Quality** | Elegance, style, naming | Subjective | Metrics (LOC/function, comments) |
| **Creativity** | Innovative solutions, extras | Cannot be quantified | Manual bonus |
| **Robustness** | Rare edge cases | A finite test set cannot establish universal correctness | Tests for common cases |
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

### 3.3 Proposed Docker Image (not an implemented sandbox)

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

# Planning values only; runtime limits require a separate launcher
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
AUTO_SCORE = Σ(category_percentage_i × numeric_weight_i / 100)
MANUAL_SCORE = 100 × sum(three manual marks from 0 to 10) / 30
# Penalties/bonuses below are competing historical proposals, not applied rules.

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

## 6. Proposal implications and remaining acceptance

### What works well automatically:
- Structure and syntax checks
- Functional tests with defined input/output
- Compilation and linking (C)
- Bounded observed memory diagnostics (Valgrind)
- Performance (timeouts)

### What requires human evaluation:
- Documentation quality
- UX and output clarity
- Creativity and elegance
- Unexpected edge cases
- Integrations with real systems

### Final recommendation:
**Historical 85% automatic + 15% manual proposal**, if adopted, is intended to support the following unmeasured benefits:
- Fast feedback (under 15 minutes)
- Consistency in evaluation
- Scalability for large classes
- Flexibility for subjective aspects

---

*Document generated for the Operating Systems course | ASE-CSIE | 2024-2025*


## Open policy comparison and recommendation

The main proposal's grade thresholds (90→10, 80→9, 70→8, 60→7,
50→6, 40→5) conflict with the summary proposal (95→10, 90→9,
80→8, 70→7, 60→6, 50→5). Both are retained as historical alternatives;
neither is applied by the reference. Main-document penalties of −5% per ShellCheck
error capped at −20% also conflict with summary −2% capped at −15%; bonuses differ
between +5/+5 and +3/+2. The author must select one versioned policy, including
rounding, caps, optional work and missing-platform treatment. The recommendation
is one explicit machine-readable policy with boundary fixtures, after author
approval. Until then reports contain observations and raw illustrative arithmetic,
not a final grade. The historical 85/15 proposal is also not adopted implicitly.

Automation percentages, test counts and durations in the planning tables have no
measured denominator in this transfer. They are estimates, not achieved coverage,
validated throughput or proof of universal correctness. Rare faults, races,
recovery and parser edge cases can have bounded automated tests; each needs a
declared oracle and evidence scope. Human judgement and platform acceptance remain
separate. No student notification, external comparison service or publication is
authorised by a proposed architecture diagram.

### Technical references for the implemented boundary

- [Python 3.12 subprocess documentation](https://docs.python.org/3.12/library/subprocess.html): literal argv, separate streams, process creation and POSIX session handling.
- [Docker resource constraints](https://docs.docker.com/engine/containers/resource_constraints/): CPU/memory controls are runtime configuration, not ENV declarations. No Docker containment was exercised by this local repair.

The current runner reports whole-case wall time (setup, command and cleanup), not
a standalone program benchmark. Its sampled output cap can have a small overshoot;
it is not a disk quota. A production backend must separately verify memory, CPU,
PID, filesystem, disk, network and privilege containment with owned negative
controls before any untrusted submission is considered. The Dockerfile remains a
proposed image recipe; the submission entrypoint and isolation launcher are not
implemented by the local helper.
