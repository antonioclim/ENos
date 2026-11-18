# Automatic Evaluation System Specifications - OS Projects

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


## Document Version 1.0 | January 2025

---

## Contents

1. [General Architecture](#1-general-architecture)
2. [Evaluation Components](#2-evaluation-components)
3. [Automated Tests per Category](#3-automated-tests-per-category)
4. [Detailed Specifications per Project](#4-detailed-specifications-per-project)
5. [Criteria Requiring Additional or Human Evidence](#5-criteria-requiring-additional-or-human-evidence)
6. [Technical Implementation](#6-technical-implementation)
7. [Scoring and Reporting](#7-scoring-and-reporting)

---

## 1. General Architecture

### 1.1 System Diagram

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         AUTOMATIC EVALUATION SYSTEM                         │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐  │
│  │  INTAKE     │───►│  STATIC     │───►│  RUNTIME    │───►│  REPORT     │  │
│  │  MODULE     │    │  ANALYSIS   │    │  TESTS      │    │  GENERATOR  │  │
│  └─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘  │
│        │                  │                  │                  │          │
│        ▼                  ▼                  ▼                  ▼          │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐  │
│  │ Unzip       │    │ ShellCheck  │    │ Docker      │    │ JSON/HTML   │  │
│  │ Validate    │    │ Structure   │    │ Sandbox     │    │ PDF Report  │  │
│  │ Identify    │    │ LOC/Funcs   │    │ Test Runner │    │ Email       │  │
│  └─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘  │
│                                                                             │
├─────────────────────────────────────────────────────────────────────────────┤
│                              SANDBOX ENVIRONMENT                            │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  Docker Container (Ubuntu 24.04)                                     │   │
│  │  - Isolated filesystem                                               │   │
│  │  - Limited network (127.0.0.1 only)                                  │   │
│  │  - Resource limits (CPU, RAM, time)                                  │   │
│  │  - Pre-installed: bash, coreutils, inotify-tools, sqlite3, gcc, etc │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 1.2 Evaluation Workflow

```
1. INTAKE (2 min)
   ├── Extract submission archive
   ├── Identify project (from README or structure)
   ├── Validate minimal structure
   └── Generate evaluation ID

2. STATIC ANALYSIS (3 min)
   ├── ShellCheck on all .sh files
   ├── Verify directory structure
   ├── Count LOC, functions, comments
   ├── Verify presence of mandatory files
   └── Analyse external dependencies

3. RUNTIME TESTS (10-30 min, depends on project)
   ├── Build (if applicable - ADVANCED with C)
   ├── Unit tests (isolated tests per functionality)
   ├── Integration tests (complete flow)
   ├── Edge cases and error handling
   └── Performance (timeout, resource usage)

4. REPORT (1 min)
   ├── Aggregate scores
   ├── Generate detailed report
   └── Notify student (optional)
```

---

## 2. Evaluation Components

### 2.1 Test Categories

| Category | Typical Weight | Automatic Evaluation | Description |
|----------|----------------|----------------------|-------------|
| **Structural** | 5-10% | ✅ 100% | File structure, naming |
| **Static Analysis** | 5-10% | ✅ 100% | ShellCheck, syntax |
| **Functional** | 50-70% | ✅ 80-95% | Functional tests |
| **Error Handling** | 5-10% | ✅ 90% | Edge cases, validations |
| **Performance** | 5-10% | ✅ 100% | Timeout, resources |
| **Documentation** | 5% | ⚠️ 40% | Presence, not quality |
| **Code Quality** | 5-10% | ⚠️ 60% | Modularity, not style |
| **UX/Output** | 5-10% | ❌ 20% | Formatting, clarity |

### 2.2 Common Tests (All Projects)

```yaml
common_tests:
  structural:
  - name: has_readme
    check: test -f README.md
    points: 1
    category: structural
    expect:
      exit_code:
        op: eq
        value: 0
  - name: has_main_script
    check: python3 "$EVALUATION_REFERENCE" inspect has-shell --root .
    points: 2
    category: structural
    expect:
      exit_code:
        op: eq
        value: 0
    reference_operation: true
  - name: has_makefile
    check: test -f Makefile
    points: 1
    category: structural
    expect:
      exit_code:
        op: eq
        value: 0
  - name: proper_structure
    check: test -d src && test -d tests
    points: 2
    category: structural
    expect:
      exit_code:
        op: eq
        value: 0
  static_analysis:
  - name: shellcheck_clean
    check: python3 "$EVALUATION_REFERENCE" inspect shellcheck --root .
    points: 5
    category: static_analysis
    expect:
      exit_code:
        op: eq
        value: 0
    historical_partial: true
    requires_tools:
    - shellcheck
    reference_operation: true
  - name: no_syntax_errors
    check: python3 "$EVALUATION_REFERENCE" inspect syntax --root .
    points: 3
    category: static_analysis
    expect:
      exit_code:
        op: eq
        value: 0
    reference_operation: true
  - name: shebang_present
    check: python3 "$EVALUATION_REFERENCE" inspect shebang --root .
    points: 1
    category: static_analysis
    expect:
      exit_code:
        op: eq
        value: 0
    reference_operation: true
  - name: set_options
    check: grep -l 'set -.*e' src/*.sh
    points: 2
    category: static_analysis
    expect:
      pending: Presence of set flags is not evidence of correct error handling; select an explicit behaviour rubric before awarding these proposed points.
  basic_execution:
  - name: runs_without_args
    check: ./script.sh
    expect:
      all:
      - exit_code:
          op: ne
          value: 0
      - text:
          stream: combined
          op: regex
          value: (?i)usage|help
    points: 2
    category: basic_execution
  - name: help_flag
    check: ./script.sh --help
    expect:
      all:
      - exit_code:
          op: eq
          value: 0
      - text:
          stream: stdout
          op: contains
          value: usage
    points: 2
    category: basic_execution
  - name: version_flag
    check: ./script.sh --version
    expect:
      exit_code:
        op: eq
        value: 0
    points: 1
    category: basic_execution
```

---

## 3. Automated Tests per Category

### 3.1 EASY Projects (E01-E05)

#### E01: File System Auditor

```yaml
e01_tests:
  functional:
  - name: basic_scan
    setup: mkdir -p "${FIXTURE_ROOT}"/test/{a,b,c}; dd if=/dev/zero of="${FIXTURE_ROOT}"/test/a/big bs=1M count=10
    check: ./fsaudit.sh "${FIXTURE_ROOT}"/test
    expect:
      all:
      - text:
          stream: stdout
          op: contains
          value: ${FIXTURE_ROOT}/test/a/big
      - text:
          stream: stdout
          op: contains
          value: '10'
    points: 5
    category: functional
  - name: extension_stats
    setup: touch "${FIXTURE_ROOT}"/test/{a.txt,b.txt,c.log,d.log,e.log}
    check: ./fsaudit.sh "${FIXTURE_ROOT}"/test --stats
    expect:
      all:
      - all:
        - text:
            stream: stdout
            op: contains
            value: .txt
        - text:
            stream: stdout
            op: contains
            value: '2'
      - all:
        - text:
            stream: stdout
            op: contains
            value: .log
        - text:
            stream: stdout
            op: contains
            value: '3'
    points: 5
    category: functional
  - name: permission_audit
    setup: chmod 777 "${FIXTURE_ROOT}"/test/a/big
    check: ./fsaudit.sh "${FIXTURE_ROOT}"/test --permissions
    expect:
      any:
      - text:
          stream: stdout
          op: contains
          value: '777'
      - text:
          stream: stdout
          op: contains
          value: world-writable
    points: 5
    category: functional
  - name: csv_export
    check: ./fsaudit.sh "${FIXTURE_ROOT}"/test --format csv -o "${FIXTURE_ROOT}"/out.csv
    expect:
      all:
      - exit_code:
          op: eq
          value: 0
      - path:
          kind: file
          path: ${FIXTURE_ROOT}/out.csv
      - csv_valid:
          path: ${FIXTURE_ROOT}/out.csv
          min_rows: 1
          min_columns: 2
    points: 3
    category: functional
  - name: json_export
    check: ./fsaudit.sh "${FIXTURE_ROOT}"/test --format json -o "${FIXTURE_ROOT}"/out.json
    expect:
      json_valid:
        path: ${FIXTURE_ROOT}/out.json
    points: 3
    category: functional
  error_handling:
  - name: nonexistent_dir
    check: ./fsaudit.sh ${FIXTURE_ROOT}/missing
    expect:
      all:
      - exit_code:
          op: ne
          value: 0
      - text:
          stream: stderr
          op: contains
          value: error
    points: 2
    category: error_handling
  - name: no_read_permission
    setup: mkdir "${FIXTURE_ROOT}"/noaccess; chmod 000 "${FIXTURE_ROOT}"/noaccess
    check: ./fsaudit.sh "${FIXTURE_ROOT}"/noaccess
    expect:
      any:
      - exit_code:
          op: ne
          value: 0
      - text:
          stream: stderr
          op: contains
          value: permission
    points: 2
    category: error_handling
    requires_non_root: true
  setup:
    commands:
    - |-
      mkdir -p "${FIXTURE_ROOT}"/test/{a,b,c}
      dd if=/dev/zero of="${FIXTURE_ROOT}"/test/a/big bs=1M count=10 status=none
      touch "${FIXTURE_ROOT}"/test/{a.txt,b.txt,c.log,d.log,e.log}
```

#### E02: Log Analyzer

```yaml
e02_tests:
  functional:
  - name: parse_syslog
    setup: |
      cat > "${FIXTURE_ROOT}"/test.log << 'EOF'
      Jan 20 10:15:30 host sshd[1234]: Failed password for root
      Jan 20 10:15:31 host sshd[1234]: Accepted password for user
      Jan 20 10:15:32 host kernel: Out of memory
      EOF
    check: ./loganalyzer.sh "${FIXTURE_ROOT}"/test.log
    expect:
      any:
      - text:
          stream: stdout
          op: contains
          value: sshd
      - text:
          stream: stdout
          op: contains
          value: kernel
    points: 5
    category: functional
  - name: filter_by_level
    setup: |
      cat > "${FIXTURE_ROOT}"/test.log << 'EOF'
      Jan 20 10:00:00 host app: [ERROR] Database connection failed
      Jan 20 10:00:01 host app: [INFO] Starting service
      Jan 20 10:00:02 host app: [WARN] High memory usage
      Jan 20 10:00:03 host app: [ERROR] Timeout
      EOF
    check: ./loganalyzer.sh "${FIXTURE_ROOT}"/test.log --level ERROR
    expect:
      all:
      - all:
        - text:
            stream: stdout
            op: contains
            value: Database
        - text:
            stream: stdout
            op: contains
            value: Timeout
      - not:
          text:
            stream: stdout
            op: contains
            value: Starting
    points: 5
    category: functional
  - name: time_filter
    check: ./loganalyzer.sh "${FIXTURE_ROOT}"/test.log --since '10:00:01' --until '10:00:02'
    expect:
      all:
      - any:
        - text:
            stream: stdout
            op: contains
            value: INFO
        - text:
            stream: stdout
            op: contains
            value: WARN
      - not:
          text:
            stream: stdout
            op: contains
            value: ERROR
    points: 5
    category: functional
  - name: statistics
    check: ./loganalyzer.sh "${FIXTURE_ROOT}"/test.log --stats
    expect:
      all:
      - text:
          stream: stdout
          op: regex
          value: ERROR.*2
      - text:
          stream: stdout
          op: regex
          value: INFO.*1
    points: 5
    category: functional
  setup:
    commands:
    - |-
      cat > "${FIXTURE_ROOT}"/test.log <<'EOF'
      Jan 20 10:00:00 host app: [ERROR] Database connection failed
      Jan 20 10:00:01 host app: [INFO] Starting service
      Jan 20 10:00:02 host app: [WARN] High memory usage
      Jan 20 10:00:03 host app: [ERROR] Timeout
      EOF
```

#### E03: Bulk File Organizer

```yaml
e03_tests:
  functional:
  - name: organize_by_extension
    setup: |
      mkdir -p "${FIXTURE_ROOT}"/source
      touch "${FIXTURE_ROOT}"/source/{a,b}.txt "${FIXTURE_ROOT}"/source/{c,d}.jpg "${FIXTURE_ROOT}"/source/e.pdf
    check: ./organizer.sh "${FIXTURE_ROOT}"/source "${FIXTURE_ROOT}"/dest --by extension
    expect:
      all:
      - path:
          kind: directory
          path: ${FIXTURE_ROOT}/dest/txt
      - file_count:
          path: ${FIXTURE_ROOT}/dest/txt
          op: eq
          value: 2
      - path:
          kind: directory
          path: ${FIXTURE_ROOT}/dest/jpg
    points: 5
    category: functional
  - name: organize_by_date
    setup: |
      touch -d "2024-01-15" "${FIXTURE_ROOT}"/source/old.txt
      touch -d "2025-01-20" "${FIXTURE_ROOT}"/source/new.txt
    check: ./organizer.sh "${FIXTURE_ROOT}"/source "${FIXTURE_ROOT}"/dest --by date
    expect:
      all:
      - any:
        - path:
            kind: directory
            path: ${FIXTURE_ROOT}/dest/2024
        - path:
            kind: directory
            path: ${FIXTURE_ROOT}/dest/2024-01
      - any:
        - path:
            kind: directory
            path: ${FIXTURE_ROOT}/dest/2025
        - path:
            kind: directory
            path: ${FIXTURE_ROOT}/dest/2025-01
    points: 5
    category: functional
  - name: dry_run
    check: ./organizer.sh "${FIXTURE_ROOT}"/source "${FIXTURE_ROOT}"/dest --by extension --dry-run
    expect:
      all:
      - any:
        - text:
            stream: stdout
            op: contains
            value: would move
        - text:
            stream: stdout
            op: contains
            value: DRY
      - path:
          kind: file
          path: ${FIXTURE_ROOT}/source/a.txt
    points: 5
    category: functional
  - name: undo
    setup: ./organizer.sh "${FIXTURE_ROOT}"/source "${FIXTURE_ROOT}"/dest --by extension
    check: ./organizer.sh --undo
    expect:
      all:
      - path:
          kind: file
          path: ${FIXTURE_ROOT}/source/a.txt
      - any:
        - not:
            path:
              kind: directory
              path: ${FIXTURE_ROOT}/dest/txt
        - path:
            kind: empty_directory
            path: ${FIXTURE_ROOT}/dest/txt
    points: 5
    category: functional
  - name: conflict_handling
    setup: |
      echo "v1" > "${FIXTURE_ROOT}"/source/test.txt
      mkdir -p "${FIXTURE_ROOT}"/dest/txt
      echo "v2" > "${FIXTURE_ROOT}"/dest/txt/test.txt
    check: ./organizer.sh "${FIXTURE_ROOT}"/source "${FIXTURE_ROOT}"/dest --by extension
    expect:
      all:
      - exit_code:
          op: eq
          value: 0
      - any:
        - path:
            kind: file
            path: ${FIXTURE_ROOT}/dest/txt/test.txt
        - path:
            kind: file
            path: ${FIXTURE_ROOT}/dest/txt/test_1.txt
    points: 5
    category: functional
  setup:
    commands:
    - |-
      mkdir -p "${FIXTURE_ROOT}"/source "${FIXTURE_ROOT}"/dest
      touch "${FIXTURE_ROOT}"/source/{a,b}.txt "${FIXTURE_ROOT}"/source/{c,d}.jpg "${FIXTURE_ROOT}"/source/e.pdf
```

#### E04: System Health Reporter

```yaml
e04_tests:
  functional:
  - name: cpu_report
    check: ./health.sh --cpu
    expect:
      text:
        stream: stdout
        op: regex
        value: '[0-9]+\.?[0-9]*%'
    points: 3
    category: functional
  - name: memory_report
    check: ./health.sh --memory
    expect:
      all:
      - any:
        - text:
            stream: stdout
            op: contains
            value: MB
        - text:
            stream: stdout
            op: contains
            value: GB
      - text:
          stream: stdout
          op: regex
          value: '[0-9]+'
    points: 3
    category: functional
  - name: disk_report
    check: ./health.sh --disk
    expect:
      all:
      - any:
        - text:
            stream: stdout
            op: contains
            value: /
        - text:
            stream: stdout
            op: contains
            value: root
      - text:
          stream: stdout
          op: regex
          value: '[0-9]+%'
    points: 3
    category: functional
  - name: full_report
    check: ./health.sh --all
    expect:
      all:
      - any:
        - text:
            stream: stdout
            op: contains
            value: CPU
        - text:
            stream: stdout
            op: contains
            value: cpu
      - any:
        - text:
            stream: stdout
            op: contains
            value: Memory
        - text:
            stream: stdout
            op: contains
            value: RAM
      - text:
          stream: stdout
          op: contains
          value: Disk
    points: 5
    category: functional
  - name: alert_colors
    check: ./health.sh --all
    expect:
      ansi: true
    points: 3
    category: functional
```

#### E05: Config File Manager

```yaml
e05_tests:
  functional:
  - name: backup_config
    setup: echo 'test=123' > "${FIXTURE_ROOT}"/test.conf
    check: ./configmgr.sh backup "${FIXTURE_ROOT}"/test.conf
    expect:
      all:
      - exit_code:
          op: eq
          value: 0
      - pending: 'Supply a versioned project/platform adapter and exact oracle for: backup_file_exists(''${FIXTURE_ROOT}/test.conf'')'
    points: 5
    category: functional
    requires_platform: owned configuration/version storage adapter; the prototype must not write a host HOME directory
  - name: list_versions
    setup: |
      ./configmgr.sh backup "${FIXTURE_ROOT}"/test.conf
      echo 'test=456' > "${FIXTURE_ROOT}"/test.conf
      ./configmgr.sh backup "${FIXTURE_ROOT}"/test.conf
    check: ./configmgr.sh list "${FIXTURE_ROOT}"/test.conf
    expect:
      lines:
        stream: stdout
        op: ge
        value: 2
    points: 3
    category: functional
    requires_platform: owned configuration/version storage adapter; the prototype must not write a host HOME directory
  - name: restore_version
    check: ./configmgr.sh restore "${FIXTURE_ROOT}"/test.conf --version 1
    expect:
      file_text:
        path: ${FIXTURE_ROOT}/test.conf
        op: contains
        value: test=123
    points: 5
    category: functional
    requires_platform: owned configuration/version storage adapter; the prototype must not write a host HOME directory
  - name: diff_versions
    check: ./configmgr.sh diff "${FIXTURE_ROOT}"/test.conf --v1 1 --v2 2
    expect:
      all:
      - all:
        - text:
            stream: stdout
            op: contains
            value: '123'
        - text:
            stream: stdout
            op: contains
            value: '456'
      - any:
        - text:
            stream: stdout
            op: contains
            value: '-'
        - text:
            stream: stdout
            op: contains
            value: +
    points: 5
    category: functional
    requires_platform: owned configuration/version storage adapter; the prototype must not write a host HOME directory
  setup:
    commands:
    - printf 'test=123\n' > "${FIXTURE_ROOT}"/test.conf
```

### 3.2 MEDIUM Projects (M01-M15)

#### M01: Incremental Backup System

```yaml
# Retained historical inline notes; the Phase 5 status above governs evidence/policy.
# After full backup
m01_tests:
  functional:
  - name: full_backup
    setup: |
      mkdir -p "${FIXTURE_ROOT}"/source/{a,b}
      echo "file1" > "${FIXTURE_ROOT}"/source/a/f1.txt
      echo "file2" > "${FIXTURE_ROOT}"/source/b/f2.txt
    check: ./backup.sh full -s "${FIXTURE_ROOT}"/source -d "${FIXTURE_ROOT}"/backup -n test
    expect:
      all:
      - all:
        - exit_code:
            op: eq
            value: 0
        - pending: 'Supply a versioned project/platform adapter and exact oracle for: backup_archive_exists(''${FIXTURE_ROOT}/backup'')'
        - pending: 'Supply a versioned project/platform adapter and exact oracle for: archive_contains(''a/f1.txt'')'
      - pending: M01 canonical CLI, archive-ID/manifest/root and retention-selection contract is not adopted; an adapter must define the exact producer receipt and dependency-preserving expected state.
    points: 10
    timeout: 60
    category: functional
  - name: incremental_backup
    setup: |
      # After full backup
      echo "modified" > "${FIXTURE_ROOT}"/source/a/f1.txt
      echo "new" > "${FIXTURE_ROOT}"/source/new.txt
    check: ./backup.sh incremental -s "${FIXTURE_ROOT}"/source -d "${FIXTURE_ROOT}"/backup -n test
    expect:
      all:
      - all:
        - exit_code:
            op: eq
            value: 0
        - pending: 'Supply a versioned project/platform adapter and exact oracle for: incremental_archive_smaller_than_full()'
        - pending: 'Supply a versioned project/platform adapter and exact oracle for: archive_contains(''new.txt'')'
      - pending: M01 canonical CLI, archive-ID/manifest/root and retention-selection contract is not adopted; an adapter must define the exact producer receipt and dependency-preserving expected state.
    points: 15
    category: functional
    notes: A size comparison is fixture-specific and cannot replace exact reconstructed-content/deletion checks.
  - name: compression_gzip
    check: ./backup.sh full -s "${FIXTURE_ROOT}"/source -d "${FIXTURE_ROOT}"/backup --compress gzip
    expect:
      all:
      - glob:
          pattern: ${FIXTURE_ROOT}/**/*.tar.gz
          kind: file
      - pending: M01 canonical CLI, archive-ID/manifest/root and retention-selection contract is not adopted; an adapter must define the exact producer receipt and dependency-preserving expected state.
    points: 3
    category: functional
  - name: compression_xz
    check: ./backup.sh full -s "${FIXTURE_ROOT}"/source -d "${FIXTURE_ROOT}"/backup --compress xz
    expect:
      all:
      - glob:
          pattern: ${FIXTURE_ROOT}/**/*.tar.xz
          kind: file
      - pending: M01 canonical CLI, archive-ID/manifest/root and retention-selection contract is not adopted; an adapter must define the exact producer receipt and dependency-preserving expected state.
    points: 3
    category: functional
  - name: restore_full
    check: ./backup.sh restore "${BACKUP_ID:?fixture adapter must export the exact returned ID}" -o "${FIXTURE_ROOT}"/restored
    expect:
      all:
      - files_equal:
        - ${FIXTURE_ROOT}/source
        - ${FIXTURE_ROOT}/restored
      - pending: M01 canonical CLI, archive-ID/manifest/root and retention-selection contract is not adopted; an adapter must define the exact producer receipt and dependency-preserving expected state.
    points: 10
    category: functional
  - name: restore_selective
    check: ./backup.sh restore "${BACKUP_ID:?fixture adapter must export the exact returned ID}" -f a/f1.txt -o "${FIXTURE_ROOT}"/restored
    expect:
      all:
      - all:
        - path:
            kind: file
            path: ${FIXTURE_ROOT}/restored/a/f1.txt
        - not:
            path:
              kind: file
              path: ${FIXTURE_ROOT}/restored/b/f2.txt
      - pending: M01 canonical CLI, archive-ID/manifest/root and retention-selection contract is not adopted; an adapter must define the exact producer receipt and dependency-preserving expected state.
    points: 5
    category: functional
  - name: rotation
    setup: create_multiple_backups 10
    check: ./backup.sh prune --keep-daily 3
    expect:
      all:
      - pending: 'Define an explicit measured field and versioned adapter for: backup_count() <= 3'
      - pending: M01 canonical CLI, archive-ID/manifest/root and retention-selection contract is not adopted; an adapter must define the exact producer receipt and dependency-preserving expected state.
    points: 10
    category: functional
    notes: Retain selected restore points plus every required ancestor; three daily points do not imply at most three archive directories.
  - name: integrity_verify
    check: ./backup.sh verify BACKUP_ID
    expect:
      all:
      - all:
        - exit_code:
            op: eq
            value: 0
        - any:
          - text:
              stream: stdout
              op: contains
              value: verified
          - text:
              stream: stdout
              op: contains
              value: OK
      - pending: M01 canonical CLI, archive-ID/manifest/root and retention-selection contract is not adopted; an adapter must define the exact producer receipt and dependency-preserving expected state.
    points: 5
    category: functional
  - name: schedule_cron
    check: ./backup.sh schedule on --cron '0 3 * * *'
    expect:
      all:
      - pending: 'Supply a versioned project/platform adapter and exact oracle for: crontab_contains(''backup'')'
      - pending: M01 canonical CLI, archive-ID/manifest/root and retention-selection contract is not adopted; an adapter must define the exact producer receipt and dependency-preserving expected state.
    points: 5
    category: functional
  error_handling:
  - name: source_not_exists
    check: ./backup.sh full -s ${FIXTURE_ROOT}/missing -d "${FIXTURE_ROOT}"/backup
    expect:
      all:
      - exit_code:
          op: ne
          value: 0
      - pending: M01 canonical CLI, archive-ID/manifest/root and retention-selection contract is not adopted; an adapter must define the exact producer receipt and dependency-preserving expected state.
    points: 2
    category: error_handling
  - name: corrupted_archive
    setup: truncate -s 100 "${FIXTURE_ROOT}"/backup/archive.tar.gz
    check: ./backup.sh verify BACKUP_ID
    expect:
      all:
      - all:
        - exit_code:
            op: ne
            value: 0
        - text:
            stream: stdout
            op: contains
            value: corrupt
      - pending: M01 canonical CLI, archive-ID/manifest/root and retention-selection contract is not adopted; an adapter must define the exact producer receipt and dependency-preserving expected state.
    points: 3
    category: error_handling
```

#### M02: Process Lifecycle Monitor

```yaml
# Retained historical inline notes; the Phase 5 status above governs evidence/policy.
# Process that consumes memory
# CPU-intensive process
m02_tests:
  functional:
  - name: monitor_by_pid
    setup: |-
      sleep 300 &
       PID=$!
      export SETUP_PID=$!
      export PID=${PID:-$SETUP_PID}
    check: ./procmon.sh status $PID
    expect:
      all:
      - text:
          stream: stdout
          op: contains
          value: sleep
      - any:
        - text:
            stream: stdout
            op: contains
            value: CPU
        - text:
            stream: stdout
            op: contains
            value: '%'
    points: 5
    cleanup: if [[ -n ${SETUP_PID:-} ]]; then kill "$SETUP_PID" 2>/dev/null || true; wait "$SETUP_PID" 2>/dev/null || true; fi
    category: functional
  - name: monitor_by_name
    setup: |-
      sleep 300 &
      export SETUP_PID=$!
      export PID=${PID:-$SETUP_PID}
    check: ./procmon.sh status sleep
    expect:
      text:
        stream: stdout
        op: contains
        value: sleep
    points: 5
    category: functional
    cleanup: if [[ -n ${SETUP_PID:-} ]]; then kill "$SETUP_PID" 2>/dev/null || true; wait "$SETUP_PID" 2>/dev/null || true; fi
  - name: process_tree
    setup: |-
      bash -c 'sleep 300 & child=$!; trap '"'"'kill "$child" 2>/dev/null; wait "$child" 2>/dev/null'"'"' EXIT; wait "$child"' &
      export SETUP_PID=$!
    check: ./procmon.sh tree "${SETUP_PID:?owned setup process required}"
    expect:
      all:
      - text:
          stream: stdout
          op: contains
          value: bash
      - text:
          stream: stdout
          op: contains
          value: sleep
      - any:
        - text:
            stream: stdout
            op: contains
            value: ├
        - text:
            stream: stdout
            op: contains
            value: └
    points: 10
    category: functional
    cleanup: if [[ -n ${SETUP_PID:-} ]]; then kill "$SETUP_PID" 2>/dev/null || true; wait "$SETUP_PID" 2>/dev/null || true; fi
  - name: resource_tracking
    setup: |-
      # Process that consumes memory
      python3 -c 'x=[0]*10000000; import time; time.sleep(60)' &
      PID=$!

      export SETUP_PID=$!
      export PID=${PID:-$SETUP_PID}
    check: ./procmon.sh status $PID
    expect:
      all:
      - any:
        - text:
            stream: stdout
            op: regex
            value: '[0-9]+ MB'
        - text:
            stream: stdout
            op: regex
            value: '[0-9]+MB'
      - pending: 'Define an explicit measured field and versioned adapter for: memory_value() > 10'
    points: 10
    category: functional
    cleanup: if [[ -n ${SETUP_PID:-} ]]; then kill "$SETUP_PID" 2>/dev/null || true; wait "$SETUP_PID" 2>/dev/null || true; fi
  - name: event_detection_exit
    setup: |-
      (sleep 2; exit 0) &
      PID=$!

      export SETUP_PID=$!
      export PID=${PID:-$SETUP_PID}
    check: ./procmon.sh watch $PID --duration 1
    expect:
      any:
      - text:
          stream: stdout
          op: contains
          value: exit
      - text:
          stream: stdout
          op: contains
          value: terminated
    points: 10
    timeout: 75
    category: functional
    notes: The assignment duration option is in minutes. This proposed one-minute check has a 75-second outer bound; it is not a five-second test.
    cleanup: if [[ -n ${SETUP_PID:-} ]]; then kill "$SETUP_PID" 2>/dev/null || true; wait "$SETUP_PID" 2>/dev/null || true; fi
  - name: cpu_alert
    setup: |-
      # CPU-intensive process
      yes > /dev/null &
      PID=$!

      export SETUP_PID=$!
      export PID=${PID:-$SETUP_PID}
    check: ./procmon.sh watch $PID --cpu-alert 50 --duration 1
    expect:
      any:
      - text:
          stream: stdout
          op: contains
          value: alert
      - text:
          stream: stdout
          op: contains
          value: threshold
    points: 5
    cleanup: if [[ -n ${SETUP_PID:-} ]]; then kill "$SETUP_PID" 2>/dev/null || true; wait "$SETUP_PID" 2>/dev/null || true; fi
    category: functional
    timeout: 75
    notes: The assignment duration option is in minutes. This proposed one-minute check has a 75-second outer bound; it is not a five-second test.
```

#### M03: Service Health Watchdog

```yaml
# Retained historical inline notes; the Phase 5 status above governs evidence/policy.
# Note: Requires mock services or Docker
# Assume ssh/cron runs in container
m03_tests:
  functional:
  - name: check_running_service
    check: ./watchdog.sh status cron
    expect:
      any:
      - text:
          stream: stdout
          op: contains
          value: running
      - text:
          stream: stdout
          op: contains
          value: active
    points: 5
    category: functional
  - name: check_stopped_service
    setup: systemctl stop cron 2>/dev/null || service cron stop
    check: ./watchdog.sh status cron
    expect:
      any:
      - text:
          stream: stdout
          op: contains
          value: stopped
      - text:
          stream: stdout
          op: contains
          value: inactive
    points: 5
    cleanup: systemctl start cron 2>/dev/null || service cron start
    category: functional
    requires_platform: isolated disposable service/network/scheduler environment with an owned adapter; not supported by the local reference
  - name: check_tcp_port
    setup: nc -l 8888 &
    check: ./watchdog.sh check-port 8888
    expect:
      all:
      - exit_code:
          op: eq
          value: 0
      - any:
        - text:
            stream: stdout
            op: contains
            value: open
        - text:
            stream: stdout
            op: contains
            value: OK
    points: 5
    category: functional
    requires_platform: isolated disposable service/network/scheduler environment with an owned adapter; not supported by the local reference
  - name: daemon_mode
    check: ./watchdog.sh daemon start
    expect:
      all:
      - pending: 'Supply a versioned project/platform adapter and exact oracle for: pid_file_exists()'
      - pending: 'Supply a versioned project/platform adapter and exact oracle for: process_running(''watchdog'')'
    points: 10
    cleanup: ./watchdog.sh daemon stop
    category: functional
    requires_platform: isolated disposable service/network/scheduler environment with an owned adapter; not supported by the local reference
  - name: config_file_parsing
    setup: |
      cat > "${FIXTURE_ROOT}"/watchdog.yaml << 'EOF'
      services:
        - name: test
          type: process
          check: "pgrep bash"
      EOF
    check: ./watchdog.sh -c "${FIXTURE_ROOT}"/watchdog.yaml status
    expect:
      exit_code:
        op: eq
        value: 0
    points: 5
    category: functional
```

#### M04: Network Security Scanner

```yaml
m04_tests:
  functional:
  - name: ping_sweep
    check: ./netscan.sh discover 127.0.0.1/32
    expect:
      all:
      - text:
          stream: stdout
          op: contains
          value: 127.0.0.1
      - any:
        - text:
            stream: stdout
            op: contains
            value: up
        - text:
            stream: stdout
            op: contains
            value: alive
    points: 5
    category: functional
    requires_platform: isolated disposable service/network/scheduler environment with an owned adapter; not supported by the local reference
  - name: port_scan_single
    setup: nc -l 9999 &
    check: ./netscan.sh scan 127.0.0.1 -p 9999
    expect:
      all:
      - text:
          stream: stdout
          op: contains
          value: '9999'
      - text:
          stream: stdout
          op: contains
          value: open
    points: 5
    category: functional
    requires_platform: isolated disposable service/network/scheduler environment with an owned adapter; not supported by the local reference
  - name: port_scan_range
    setup: nc -l 8001 & nc -l 8002 &
    check: ./netscan.sh scan 127.0.0.1 -p 8000-8010
    expect:
      all:
      - all:
        - text:
            stream: stdout
            op: contains
            value: '8001'
        - text:
            stream: stdout
            op: contains
            value: '8002'
      - text:
          stream: stdout
          op: contains
          value: open
    points: 10
    category: functional
    requires_platform: isolated disposable service/network/scheduler environment with an owned adapter; not supported by the local reference
  - name: parallel_scan
    check: ./netscan.sh scan 127.0.0.1 -p 1-1000 -j 10
    expect:
      duration:
        op: lt
        value: 30
    points: 5
    timeout: 60
    category: functional
    requires_platform: isolated disposable service/network/scheduler environment with an owned adapter; not supported by the local reference
  - name: json_output
    check: ./netscan.sh scan 127.0.0.1 -p 22,80 --format json
    expect:
      all:
      - json_valid:
          stream: stdout
      - any:
        - json_valid:
            stream: stdout
            required_keys:
            - host
        - json_valid:
            stream: stdout
            required_keys:
            - ports
    points: 5
    category: functional
    requires_platform: isolated disposable service/network/scheduler environment with an owned adapter; not supported by the local reference
  - name: html_report
    check: ./netscan.sh scan 127.0.0.1 -p 1-100 --format html -o "${FIXTURE_ROOT}"/report.html
    expect:
      all:
      - path:
          kind: file
          path: ${FIXTURE_ROOT}/report.html
      - file_text:
          path: ${FIXTURE_ROOT}/report.html
          op: regex
          value: <[A-Za-z][^>]*>
    points: 5
    category: functional
    requires_platform: isolated disposable service/network/scheduler environment with an owned adapter; not supported by the local reference
```

#### M05: Deployment Pipeline

```yaml
# Retained historical inline notes; the Phase 5 status above governs evidence/policy.
# Create mock app with health endpoint
#!/bin/bash
m05_tests:
  functional:
  - name: detect_node_project
    setup: |
      mkdir -p "${FIXTURE_ROOT}"/project
      echo '{"name":"test","scripts":{"build":"echo built"}}' > "${FIXTURE_ROOT}"/project/package.json
    check: ./deploy.sh build "${FIXTURE_ROOT}"/project
    expect:
      any:
      - text:
          stream: stdout
          op: contains
          value: node
      - text:
          stream: stdout
          op: contains
          value: npm
    points: 5
    category: functional
  - name: detect_python_project
    setup: |
      mkdir -p "${FIXTURE_ROOT}"/project
      echo 'flask==2.0' > "${FIXTURE_ROOT}"/project/requirements.txt
    check: ./deploy.sh build "${FIXTURE_ROOT}"/project
    expect:
      any:
      - text:
          stream: stdout
          op: contains
          value: python
      - text:
          stream: stdout
          op: contains
          value: pip
    points: 5
    category: functional
  - name: deploy_atomic
    setup: mkdir -p "${FIXTURE_ROOT}"/deploy/releases
    check: ./deploy.sh deploy "${FIXTURE_ROOT}"/project -e dev
    expect:
      all:
      - path:
          kind: symlink
          path: ${FIXTURE_ROOT}/deploy/current
      - pending: 'Supply a versioned project/platform adapter and exact oracle for: symlink_target_contains(''releases'')'
    points: 10
    category: functional
  - name: rollback
    setup: |
      ./deploy.sh deploy "${FIXTURE_ROOT}"/project -e dev
      ./deploy.sh deploy "${FIXTURE_ROOT}"/project -e dev  # Second release
    check: ./deploy.sh rollback -e dev
    expect:
      all:
      - exit_code:
          op: eq
          value: 0
      - pending: 'Supply a versioned project/platform adapter and exact oracle for: symlink_changed(''${FIXTURE_ROOT}/deploy/current'')'
    points: 10
    category: functional
  - name: health_check
    setup: |
      # Create mock app with health endpoint
      cat > "${FIXTURE_ROOT}"/project/app.sh << 'EOF'
      #!/bin/bash
      while true; do echo -e "HTTP/1.1 200 OK\n\nOK" | nc -l 8080 -q 1; done
      EOF
      chmod +x "${FIXTURE_ROOT}"/project/app.sh
    check: ./deploy.sh deploy "${FIXTURE_ROOT}"/project -e dev --health-check http://localhost:8080
    expect:
      any:
      - text:
          stream: stdout
          op: contains
          value: healthy
      - text:
          stream: stdout
          op: contains
          value: OK
    points: 10
    category: functional
    requires_platform: isolated disposable service/network/scheduler environment with an owned adapter; not supported by the local reference
  setup:
    commands:
    - mkdir -p "${FIXTURE_ROOT}"/project "${FIXTURE_ROOT}"/deploy/releases
```

#### M06-M15 (Similar Pattern)

```yaml
# Retained historical inline notes; the Phase 5 status above governs evidence/policy.
# Template for the rest of MEDIUM projects
# Each follows the same pattern:
# 1. Setup environment
# 2. Test main functionality
# 3. Test secondary functionalities
# 4. Test error handling
# 5. Test output formats
# 6. Performance/timeout tests
m06_resource_historian:
- collect_cpu_metrics
- collect_memory_metrics
- store_in_sqlite
- ascii_graph_generation
- report_generation
m07_security_audit:
- user_audit_empty_passwords
- file_audit_suid
- service_audit_ssh
- report_with_severity
m08_disk_manager:
- space_analysis
- cleanup_temp_files
- duplicate_detection
- threshold_alerts
m09_task_scheduler:
- add_cron_task
- add_systemd_timer
- list_tasks
- execution_logging
m10_process_tree:
- build_tree
- detect_zombies
- aggregate_resources
- export_dot
m11_memory_forensics:
- system_memory_overview
- process_memory_maps
- leak_detection_snapshot
- comparison_report
m12_file_integrity:
- create_baseline
- detect_modifications
- inotify_watch
- generate_report
m13_log_aggregator:
- multi_source_collection
- syslog_parsing
- journald_reading
- pattern_alerting
m14_config_manager:
- environment_inheritance
- template_rendering
- secret_encryption
- environment_diff
m15_parallel_engine:
- parallel_execution
- job_queue_management
- progress_reporting
- error_retry
```

### 3.3 ADVANCED Projects (A01-A03)

```yaml
a01_job_scheduler:
  build:
  - name: compile_c_library
    check: make -C src/c
    expect:
      path:
        kind: file
        path: build/libjobqueue.so
    points: 10
    category: build
  - name: compile_cli_tool
    check: make
    expect:
      path:
        kind: file
        path: bin/jobctl
    points: 5
    category: build
  functional:
  - name: init_queue
    check: ./bin/jobctl init
    expect:
      pending: 'Supply a versioned project/platform adapter and exact oracle for: shm_exists(''/dev/shm/jobscheduler'')'
    points: 5
    category: functional
    requires_platform: owned named POSIX IPC instance and completed versioned A01 CLI; never shared global /dev/shm paths
    setup: |
      export JOBQUEUE_INSTANCE=${FIXTURE_ROOT##*/}
    cleanup: ./bin/jobctl destroy
  - name: submit_job
    check: ./bin/jobctl submit 'echo test'
    expect:
      text:
        stream: stdout
        op: regex
        value: Job.*#[0-9]+
    points: 5
    category: functional
    requires_platform: owned named POSIX IPC instance and completed versioned A01 CLI; never shared global /dev/shm paths
    setup: |
      export JOBQUEUE_INSTANCE=${FIXTURE_ROOT##*/}
      ./bin/jobctl init
    cleanup: ./bin/jobctl destroy
  - name: priority_ordering
    setup: |
      export JOBQUEUE_INSTANCE=${FIXTURE_ROOT##*/}
      ./bin/jobctl init
      ./bin/jobctl submit -p 10 'sleep 1'
      ./bin/jobctl submit -p 1 'echo high'
    check: ./bin/jobctl list
    expect:
      pending: 'Supply a versioned project/platform adapter and exact oracle for: high_priority_first()'
    points: 10
    category: functional
    requires_platform: owned named POSIX IPC instance and completed versioned A01 CLI; never shared global /dev/shm paths
    cleanup: ./bin/jobctl destroy
  - name: shared_memory_integrity
    check: |-
      pids=()
      for i in $(seq 1 100); do ./bin/jobctl submit "concurrent_$i" > "submit_$i.log" 2>&1 & pids+=("$!"); done
      failed=0
      for pid in "${pids[@]}"; do wait "$pid" || failed=1; done
      (( failed == 0 )) || exit 1
      ./bin/jobctl list
    expect:
      all:
      - exit_code:
          op: eq
          value: 0
      - unique_matches:
          pattern: concurrent_[0-9]+\b
          values:
          - concurrent_1
          - concurrent_2
          - concurrent_3
          - concurrent_4
          - concurrent_5
          - concurrent_6
          - concurrent_7
          - concurrent_8
          - concurrent_9
          - concurrent_10
          - concurrent_11
          - concurrent_12
          - concurrent_13
          - concurrent_14
          - concurrent_15
          - concurrent_16
          - concurrent_17
          - concurrent_18
          - concurrent_19
          - concurrent_20
          - concurrent_21
          - concurrent_22
          - concurrent_23
          - concurrent_24
          - concurrent_25
          - concurrent_26
          - concurrent_27
          - concurrent_28
          - concurrent_29
          - concurrent_30
          - concurrent_31
          - concurrent_32
          - concurrent_33
          - concurrent_34
          - concurrent_35
          - concurrent_36
          - concurrent_37
          - concurrent_38
          - concurrent_39
          - concurrent_40
          - concurrent_41
          - concurrent_42
          - concurrent_43
          - concurrent_44
          - concurrent_45
          - concurrent_46
          - concurrent_47
          - concurrent_48
          - concurrent_49
          - concurrent_50
          - concurrent_51
          - concurrent_52
          - concurrent_53
          - concurrent_54
          - concurrent_55
          - concurrent_56
          - concurrent_57
          - concurrent_58
          - concurrent_59
          - concurrent_60
          - concurrent_61
          - concurrent_62
          - concurrent_63
          - concurrent_64
          - concurrent_65
          - concurrent_66
          - concurrent_67
          - concurrent_68
          - concurrent_69
          - concurrent_70
          - concurrent_71
          - concurrent_72
          - concurrent_73
          - concurrent_74
          - concurrent_75
          - concurrent_76
          - concurrent_77
          - concurrent_78
          - concurrent_79
          - concurrent_80
          - concurrent_81
          - concurrent_82
          - concurrent_83
          - concurrent_84
          - concurrent_85
          - concurrent_86
          - concurrent_87
          - concurrent_88
          - concurrent_89
          - concurrent_90
          - concurrent_91
          - concurrent_92
          - concurrent_93
          - concurrent_94
          - concurrent_95
          - concurrent_96
          - concurrent_97
          - concurrent_98
          - concurrent_99
          - concurrent_100
    points: 15
    category: functional
    requires_platform: owned named POSIX IPC instance and completed versioned A01 CLI; never shared global /dev/shm paths
    setup: |
      export JOBQUEUE_INSTANCE=${FIXTURE_ROOT##*/}
      ./bin/jobctl init
    cleanup: ./bin/jobctl destroy
  memory:
  - name: no_memory_leaks
    check: valgrind --error-exitcode=97 --leak-check=full ./bin/jobctl submit 'test'
    expect:
      exit_code:
        op: eq
        value: 0
    points: 10
    category: memory
    requires_platform: owned named POSIX IPC instance and completed versioned A01 CLI; never shared global /dev/shm paths
    setup: |
      export JOBQUEUE_INSTANCE=${FIXTURE_ROOT##*/}
      ./bin/jobctl init
    cleanup: ./bin/jobctl destroy
    notes: A clean bounded Valgrind run is evidence for this execution only; missing tools, ptrace restrictions or lifecycle failures are unavailable, not a pass.
a02_shell_extension:
  build:
  - name: compile_library
    check: make
    expect:
      path:
        kind: file
        path: build/libshellext.so
    points: 10
    category: build
  functional:
  - name: syntax_highlighting
    check: |
      echo 'if [ -f test ]; then echo "found"; fi' | ./highlight
    expect:
      all:
      - ansi:
        - if
      - ansi:
        - echo
    points: 15
    category: functional
  - name: completion_trie
    setup: ./load_commands
    check: ./complete 'gre'
    expect:
      text:
        stream: stdout
        op: contains
        value: grep
    points: 15
    category: functional
  - name: lexer_correctness
    check: ./tokenize 'echo $VAR | grep "test"'
    expect:
      pending: 'Supply a versioned project/platform adapter and exact oracle for: tokens_include(''BUILTIN'', ''VARIABLE'', ''OPERATOR'', ''STRING'')'
    points: 10
    category: functional
a03_file_sync:
  build:
  - name: compile
    check: make
    expect:
      all:
      - path:
          kind: file
          path: build/libsyncutil.so
      - path:
          kind: file
          path: bin/synctool
    points: 10
    category: build
  functional:
  - name: hash_file
    setup: |-
      mkdir -p "${FIXTURE_ROOT}"/a03_test/source
      printf abc > "${FIXTURE_ROOT}"/a03_test/source/known-vector.txt
    check: ./bin/synctool hash "${FIXTURE_ROOT}"/a03_test/source/known-vector.txt
    expect:
      pending: Author must select MD5 (16 bytes/32 hex) or SHA-256 (32 bytes/64 hex) and CLI framing; then compare the exact abc known vector, not only length, repetition or inequality.
    points: 5
    category: functional
    historical_command: ./bin/synctool hash /tmp/test
    notes: 'Known vectors for abc: MD5 900150983cd24fb0d6963f7d28e17f72; SHA-256 ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad.'
  - name: generate_signature
    check: ./bin/synctool signature "${FIXTURE_ROOT}"/test
    expect:
      path:
        kind: file
        path: ${FIXTURE_ROOT}/test.sig
    points: 10
    category: functional
  - name: delta_generation
    setup: |
      cp "${FIXTURE_ROOT}"/test "${FIXTURE_ROOT}"/test_modified
      echo "change" >> "${FIXTURE_ROOT}"/test_modified
    check: ./bin/synctool delta "${FIXTURE_ROOT}"/test "${FIXTURE_ROOT}"/test_modified
    expect:
      pending: 'Supply explicit paths/units for the measured comparison: delta_size() < file_size(''${FIXTURE_ROOT}/test_modified'')'
    points: 15
    category: functional
  - name: delta_application
    check: ./bin/synctool apply "${FIXTURE_ROOT}"/test "${FIXTURE_ROOT}"/delta -o "${FIXTURE_ROOT}"/result
    expect:
      files_equal:
      - ${FIXTURE_ROOT}/test_modified
      - ${FIXTURE_ROOT}/result
    points: 15
    category: functional
  setup:
    commands:
    - |-
      mkdir -p "${FIXTURE_ROOT}"/a03_test/source
      printf abc > "${FIXTURE_ROOT}"/test
      cp "${FIXTURE_ROOT}"/test "${FIXTURE_ROOT}"/test_modified
      printf "change\n" >> "${FIXTURE_ROOT}"/test_modified
```

---

## 4. Detailed Specifications per Project

### 4.1 Historical Planning Matrix (not measured test inventory)

| Project | Total Tests | Auto (%) | Manual (%) | Est. Time |
|---------|-------------|----------|------------|-----------|
| E01 | 15 | 95% | 5% | 5 min |
| E02 | 12 | 90% | 10% | 5 min |
| E03 | 14 | 95% | 5% | 5 min |
| E04 | 10 | 85% | 15% | 3 min |
| E05 | 12 | 90% | 10% | 4 min |
| M01 | 20 | 90% | 10% | 10 min |
| M02 | 18 | 85% | 15% | 8 min |
| M03 | 16 | 80% | 20% | 10 min |
| M04 | 15 | 90% | 10% | 8 min |
| M05 | 18 | 85% | 15% | 12 min |
| M06 | 14 | 90% | 10% | 8 min |
| M07 | 16 | 95% | 5% | 10 min |
| M08 | 15 | 90% | 10% | 8 min |
| M09 | 14 | 85% | 15% | 10 min |
| M10 | 12 | 90% | 10% | 6 min |
| M11 | 14 | 85% | 15% | 8 min |
| M12 | 16 | 90% | 10% | 10 min |
| M13 | 15 | 85% | 15% | 10 min |
| M14 | 14 | 90% | 10% | 8 min |
| M15 | 16 | 90% | 10% | 10 min |
| A01 | 20 | 85% | 15% | 15 min |
| A02 | 18 | 75% | 25% | 12 min |
| A03 | 20 | 85% | 15% | 15 min |

---

## 5. Criteria Requiring Additional or Human Evidence

### 5.1 Complete List

| Criterion | Reason | Alternative Solution |
|-----------|--------|----------------------|
| **Documentation quality** | Requires semantic understanding | Verify only presence and minimum length |
| **Output clarity** | Subjective, depends on preferences | Verify structure, not exact content |
| **Code elegance** | Subjective | ShellCheck + metrics (LOC/function) |
| **Solution creativity** | Cannot be quantified | N/A - human evaluation only |
| **Ease of use (UX)** | Requires human testing | Verify help text present |
| **Useful comments** | Requires context understanding | Verify only comments/code ratio |
| **Descriptive variable names** | Semantic | Pattern matching for snake_case |
| **Overall architecture** | Requires holistic vision | Verify modularity (function count) |
| **Handling rare edge cases** | Cannot all be anticipated | Tests for common cases |
| **Optimal performance** | Depends on hardware | Only relative timeouts |

### 5.2 Automatic Evaluation Percentage per Criterion

```
FINITE AUTOMATIC CHECKS (coverage estimate, not proof):
├── File structure (exists/does not exist)
├── Correct syntax (bash -n, ShellCheck)
├── Correct exit codes
├── Output contains expected patterns
├── Files created correctly
├── Timeout respected
└── CLI commands work

PARTIAL AUTOMATIC (50-80%):
├── Code quality (metrics, not semantics)
├── Error handling (common cases)
├── Logging (presence, not quality)
└── Configuration (parsing, not complete validation)

MANUAL REQUIRED (0-20%):
├── Documentation (quality)
├── UX (clarity)
├── Creativity
└── Rare edge cases
```

### 5.3 Recommendation: Hybrid Model

```
FINAL SCORE = (Auto × 0.85) + (Manual × 0.15)

Where:
- Auto = Score from automated tests (0-100)
- Manual = 100 × sum of the following marks / 30 (normalisation required):
  • Documentation (0-10 points)
  • Overall code quality (0-10 points)  
  • Creativity/Extra features (0-10 points)
```

---

## 6. Technical Implementation

### 6.1 System Structure

```
evaluator/
├── bin/
│   ├── evaluate.sh              # Entry point
│   └── report-generator.py      # Report generation
├── lib/
│   ├── intake.sh                # Submission processing
│   ├── static_analysis.sh       # ShellCheck, structure
│   ├── test_runner.sh           # Test execution
│   └── scoring.sh               # Score calculation
├── tests/
│   ├── common/                  # Common tests
│   ├── easy/                    # E01-E05
│   ├── medium/                  # M01-M15
│   └── advanced/                # A01-A03
├── docker/
│   ├── Dockerfile               # Sandbox image
│   └── docker-compose.yml
├── config/
│   ├── projects.yaml            # Project definitions
│   ├── tests.yaml               # Test configurations
│   └── scoring.yaml             # Score weights
└── reports/
    └── templates/
        ├── report.html.j2
        └── report.json.j2
```

### 6.2 Proposed Docker Image (not an implemented sandbox)

```dockerfile
FROM ubuntu:24.04

RUN apt-get update && apt-get install -y \
    bash \
    coreutils \
    findutils \
    grep \
    sed \
    gawk \
    shellcheck \
    sqlite3 \
    inotify-tools \
    netcat-openbsd \
    curl \
    jq \
    gcc \
    make \
    valgrind \
    python3 python3-yaml gzip bzip2 xz-utils libssl-dev libreadline-dev \
    && rm -rf /var/lib/apt/lists/*

# Planning configuration only; ENV does not enforce any resource limit
ENV TIMEOUT=60
ENV MAX_MEMORY=512M
ENV MAX_DISK=1G

# Unprivileged user
RUN useradd -m -s /bin/bash student
USER student
WORKDIR /home/student

COPY --chown=student:student entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
```

### 6.3 Implemented local runner and finite predicates

The executable implementation is [evaluation_reference.py](../helpers/evaluation_reference.py).
It supplies `validate_predicate`, `evaluate`, `run_case`, `summarise` and an explicit
`hybrid_percentage` arithmetic function. It never evaluates predicate text as a
shell program or Python expression. Command text belongs only to a trusted fixture
and is separate from its predicate data. Reports include `id`, `category`, `status`,
`exit_code`, `duration`, `points`, `max_points`, separate stdout/stderr and a null
`grade`. Missing tools or lifecycle failures are ERROR/NOT_RUN, not a clean result.

```yaml
owned_reference:
  tests:
    functional_core:
      - id: literal_json
        name: Literal output and separate stderr
        argv: [python3, -c, "import sys; print('quoted \"value\"'); print('diagnostic', file=sys.stderr)"]
        expect:
          all:
            - exit_code: {op: eq, value: 0}
            - text: {stream: stdout, op: contains, value: 'quoted "value"'}
            - text: {stream: stderr, op: equals, value: "diagnostic\n"}
        points: 5
        timeout: 2
```

### 6.4 Arithmetic and incomplete evidence

For complete results, raw percentage is `100 * sum(points) / sum(max_points)`.
Explicit category weights must be numeric, cover every category and sum to 100;
otherwise the scorer rejects the configuration. A missing category cannot silently
become zero. A NOT_RUN/ERROR case keeps its planned denominator and makes the final
percentage unavailable. No missing case is silently removed to increase a score.

The historical 85/15 illustration becomes mathematically coherent only after
normalising the three manual marks: `manual_percentage = 100 * sum(marks) / 30`.
Then `illustrative_total = 0.85 * auto_percentage + 0.15 * manual_percentage`.
Maximum input is 100; the earlier unnormalised formula reached only 89.5.
The weights and conversion to a grade remain author decisions. `hybrid_percentage`
requires the weight explicitly and `summarise` returns `grade: null`.

---

## 7. Scoring and Reporting

### 7.1 Scoring Model

```yaml
# Retained historical inline notes; the Phase 5 status above governs evidence/policy.
# Points per category
# Penalties
# Bonuses
scoring_model:
  policy_status: proposal_not_adopted
  weights:
    structural: 10
    static_analysis: 10
    functional_core: 40
    functional_optional: 15
    error_handling: 10
    performance: 5
    documentation: 5
    code_quality: 5
  historical_penalty_proposal:
    shellcheck_errors: -5% per error (max -20%)
    timeout_exceeded: -50% for that test
    crash: -100% for that test
    hardcoded_paths: -2% per occurrence
  historical_bonus_proposal:
    all_tests_pass: +5%
    exceptional_error_handling: +5%
    kubernetes_extension: +10%
  application: No penalties, bonuses or grades are applied by the local reference.
```

### 7.2 Report Format

```json
{
  "schema_version": 1,
  "example_only": true,
  "summary": {
    "earned_known": 81,
    "max_planned": 100,
    "percentage": 81.0,
    "weighted_percentage": null,
    "complete": true,
    "grade": null,
    "policy_status": "proposal_only_no_institutional_grade"
  },
  "categories": {
    "structural": {
      "earned": 10,
      "max": 10
    },
    "static_analysis": {
      "earned": 8,
      "max": 10
    },
    "functional_core": {
      "earned": 33,
      "max": 40
    },
    "functional_optional": {
      "earned": 9,
      "max": 15
    },
    "error_handling": {
      "earned": 7,
      "max": 10
    },
    "performance": {
      "earned": 5,
      "max": 5
    },
    "documentation": {
      "earned": 4,
      "max": 5
    },
    "code_quality": {
      "earned": 5,
      "max": 5
    }
  },
  "provenance": "Illustrative arithmetic only; the earlier 85.5 total did not equal the displayed 81 category points."
}
```

### 7.3 Results Dashboard

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                    AUTOMATIC EVALUATION RESULT                               ║
║                    M01: Incremental Backup System                            ║
╚══════════════════════════════════════════════════════════════════════════════╝

ILLUSTRATIVE RAW TOTAL: 81 / 100  [████████████████████░░░░] 

DETAILS PER CATEGORY
═══════════════════════════════════════════════════════════════════════════════
  Structural      [██████████] 100%   (10/10 pts)
  Static Analysis [████████░░]  80%   (8/10 pts)
  Functional Core [████████░░]  82.5% (33/40 pts)
  Optional        [██████░░░░]  60%   (9/15 pts)
  Error Handling  [███████░░░]  70%   (7/10 pts)
  Performance     [██████████] 100%   (5/5 pts)
  Documentation   [████████░░]  80%   (4/5 pts)
  Code Quality    [██████████] 100%   (5/5 pts)

FAILED TESTS (2)
═══════════════════════════════════════════════════════════════════════════════
  ✗ restore_selective
    Expected: File restored at /tmp/restored/a/f1.txt
    Actual:   File not found
    
  ✗ rotation_monthly
    Expected: Keep exactly 3 monthly backups
    Actual:   Found 5 backups after prune

RECOMMENDATIONS
═══════════════════════════════════════════════════════════════════════════════
  1. Implement selective extraction from tar archives
  2. Verify rotation logic for monthly backups
  3. Reduce ShellCheck warnings (3 found)

FINAL GRADE: PENDING AUTHOR POLICY
```

---

## Appendix: Implementation Checklist

### For Each New Project:

- [ ] Define structural tests (mandatory files)
- [ ] Define static analysis tests
- [ ] Define core functional tests (mandatory)
- [ ] Define optional functional tests
- [ ] Define error handling tests
- [ ] Define performance tests (timeout)
- [ ] Configure scoring weights
- [ ] Create fixtures/test data
- [ ] Test the tests (meta-testing)
- [ ] Document non-evaluable criteria

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
