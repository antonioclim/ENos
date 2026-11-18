# Detailed Test Specifications - EASY Projects (E01-E05)

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


## E01: File System Auditor

### Proposed Detailed Tests (local predicate schema)

```yaml
# Retained historical inline notes; the Phase 5 status above governs evidence/policy.
# Create test structure
# Duplicate files
# Old files
# === STRUCTURAL (10 points) ===
# === STATIC ANALYSIS (10 points) ===
# === CORE FUNCTIONAL (40 points) ===
# === OPTIONAL FUNCTIONAL (20 points) ===
# === ERROR HANDLING (10 points) ===
# === CODE QUALITY (10 points) ===
# WHAT CANNOT BE EVALUATED AUTOMATICALLY
e01_file_system_auditor:
  metadata:
    project_id: E01
    name: File System Auditor
    difficulty: EASY
    estimated_test_time: 5m
    total_points: 100
    auto_evaluable_percent: 95
    historical_declared_total_points: 100
    test_count: 26
    policy_status: proposal_not_adopted
    evidence_status: unmeasured_planning_estimate
    fixture_lifecycle: fresh project copy and inherited setup per case; unconditional owned cleanup
  setup:
    commands:
    - |
      mkdir -p "${FIXTURE_ROOT}"/e01_test/{documents,images,code,empty}
      dd if=/dev/zero of="${FIXTURE_ROOT}"/e01_test/documents/large.pdf bs=1M count=50
      dd if=/dev/zero of="${FIXTURE_ROOT}"/e01_test/images/photo.jpg bs=1K count=500
      echo "small file" > "${FIXTURE_ROOT}"/e01_test/code/script.sh
      touch "${FIXTURE_ROOT}"/e01_test/documents/{a,b,c}.txt
      touch "${FIXTURE_ROOT}"/e01_test/images/{1,2,3}.png
      chmod 777 "${FIXTURE_ROOT}"/e01_test/code/script.sh
      touch "${FIXTURE_ROOT}"/e01_test/documents/secret.txt
      chmod 000 "${FIXTURE_ROOT}"/e01_test/documents/secret.txt
      ln -s "${FIXTURE_ROOT}"/e01_test/documents/large.pdf "${FIXTURE_ROOT}"/e01_test/link_to_large
      # Duplicate files
      echo "duplicate content" > "${FIXTURE_ROOT}"/e01_test/documents/dup1.txt
      echo "duplicate content" > "${FIXTURE_ROOT}"/e01_test/images/dup2.txt
      # Old files
      touch -d "2020-01-01" "${FIXTURE_ROOT}"/e01_test/documents/old.txt
  tests:
    structural:
    - id: struct_01
      name: Main script exists
      command: test -f src/fsaudit.sh || test -f fsaudit.sh
      points: 3
      category: structural
      expect:
        exit_code:
          op: eq
          value: 0
    - id: struct_02
      name: README.md exists
      command: python3 "$EVALUATION_REFERENCE" inspect readme --root .
      points: 2
      category: structural
      expect:
        exit_code:
          op: eq
          value: 0
    - id: struct_03
      name: Script executable
      command: test -x src/fsaudit.sh || test -x fsaudit.sh
      points: 2
      category: structural
      expect:
        exit_code:
          op: eq
          value: 0
    - id: struct_04
      name: Correct shebang
      command: python3 "$EVALUATION_REFERENCE" inspect shebang --root .
      points: 3
      category: structural
      expect:
        exit_code:
          op: eq
          value: 0
      reference_operation: true
    static:
    - id: static_01
      name: ShellCheck without errors
      command: python3 "$EVALUATION_REFERENCE" inspect shellcheck --root .
      points: 5
      category: static_analysis
      expect:
        exit_code:
          op: eq
          value: 0
      historical_partial_credit:
        warnings_allowed: 5
        deduction_per_warning: 0.5
      requires_tools:
      - shellcheck
      reference_operation: true
    - id: static_02
      name: No syntax errors
      command: python3 "$EVALUATION_REFERENCE" inspect syntax --root .
      points: 3
      category: static_analysis
      expect:
        exit_code:
          op: eq
          value: 0
      reference_operation: true
    - id: static_03
      name: Uses set -e or set -euo pipefail
      command: grep -E 'set -[euo]' src/fsaudit.sh 2>/dev/null || grep -E 'set -[euo]' fsaudit.sh
      points: 2
      category: static_analysis
      expect:
        pending: Presence of set flags is not evidence of correct error handling; select an explicit behaviour rubric before awarding these proposed points.
    functional_core:
    - id: func_01
      name: Running without arguments displays help/usage
      command: ./fsaudit.sh 2>&1
      expect:
        all:
        - exit_code:
            op: ne
            value: 0
        - text:
            stream: combined
            op: regex
            value: (?i)usage|help
      points: 3
      category: functional_core
      historical_category: functional
    - id: func_02
      name: Flag --help works
      command: ./fsaudit.sh --help
      expect:
        all:
        - exit_code:
            op: eq
            value: 0
        - text:
            stream: combined
            op: regex
            value: (?i)usage|help
      points: 2
      category: functional_core
      historical_category: functional
    - id: func_03
      name: Directory analysis - finds files
      command: ./fsaudit.sh "${FIXTURE_ROOT}"/e01_test
      expect:
        all:
        - exit_code:
            op: eq
            value: 0
        - all:
          - text:
              stream: stdout
              op: contains
              value: documents
          - text:
              stream: stdout
              op: contains
              value: images
      points: 5
      category: functional_core
      historical_category: functional
    - id: func_04
      name: Large file reporting
      command: ./fsaudit.sh "${FIXTURE_ROOT}"/e01_test --large 10M 2>/dev/null
      expect:
        all:
        - all:
          - text:
              stream: stdout
              op: contains
              value: large.pdf
          - text:
              stream: stdout
              op: contains
              value: '50'
        - not:
            text:
              stream: stdout
              op: contains
              value: script.sh
      points: 5
      category: functional_core
      historical_category: functional
      historical_cli_alternative: ./fsaudit.sh /tmp/e01_test -l 10M
      contract_status: proposed CLI only; canonical interface decision remains open
    - id: func_05
      name: Top directories by size
      command: ./fsaudit.sh "${FIXTURE_ROOT}"/e01_test --top 5 2>/dev/null
      expect:
        all:
        - text:
            stream: stdout
            op: contains
            value: documents
        - text:
            stream: stdout
            op: regex
            value: '[0-9]+\s*(MB|KB|GB|M|K|G)'
      points: 5
      category: functional_core
      historical_category: functional
      historical_cli_alternative: ./fsaudit.sh /tmp/e01_test
      contract_status: proposed CLI only; canonical interface decision remains open
    - id: func_06
      name: Statistics by extension
      command: ./fsaudit.sh "${FIXTURE_ROOT}"/e01_test --stats 2>/dev/null
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
              value: .png
          - text:
              stream: stdout
              op: contains
              value: .pdf
        - text:
            stream: stdout
            op: regex
            value: \.(txt|pdf|png).*[0-9]+
      points: 5
      category: functional_core
      historical_category: functional
      historical_cli_alternative: ./fsaudit.sh /tmp/e01_test -s
      contract_status: proposed CLI only; canonical interface decision remains open
    - id: func_07
      name: Permission audit - detects 777
      command: ./fsaudit.sh "${FIXTURE_ROOT}"/e01_test --permissions 2>/dev/null
      expect:
        all:
        - text:
            stream: stdout
            op: contains
            value: '777'
        - text:
            stream: stdout
            op: contains
            value: world
        - text:
            stream: stdout
            op: contains
            value: writable
        - text:
            stream: stdout
            op: contains
            value: script.sh
      points: 5
      category: functional_core
      historical_category: functional
      historical_cli_alternative: ./fsaudit.sh /tmp/e01_test -p
      contract_status: proposed CLI only; canonical interface decision remains open
    - id: func_08
      name: Implicit recursion
      command: ./fsaudit.sh "${FIXTURE_ROOT}"/e01_test 2>&1 | grep -c 'documents\|images\|code'
      expect:
        output_number:
          op: ge
          value: 3
      points: 5
      category: functional_core
      historical_category: functional
    - id: func_09
      name: Non-existent directory - correct error
      command: ./fsaudit.sh ${FIXTURE_ROOT}/missing-directory 2>&1
      expect:
        all:
        - exit_code:
            op: ne
            value: 0
        - any:
          - text:
              stream: combined
              op: contains
              value: error
          - text:
              stream: combined
              op: contains
              value: Error
          - text:
              stream: combined
              op: contains
              value: not found
          - text:
              stream: combined
              op: contains
              value: does not exist
      points: 5
      category: functional_core
      historical_category: functional
    functional_optional:
    - id: opt_01
      name: CSV Export
      command: ./fsaudit.sh "${FIXTURE_ROOT}"/e01_test --format csv -o "${FIXTURE_ROOT}"/out.csv
      expect:
        all:
        - exit_code:
            op: eq
            value: 0
        - csv_valid:
            path: ${FIXTURE_ROOT}/out.csv
            min_rows: 2
            min_columns: 2
      points: 5
      category: functional_optional
      historical_category: optional
    - id: opt_02
      name: JSON Export
      command: ./fsaudit.sh "${FIXTURE_ROOT}"/e01_test --format json -o "${FIXTURE_ROOT}"/out.json
      expect:
        all:
        - path:
            kind: file
            path: ${FIXTURE_ROOT}/out.json
        - json_valid:
            path: ${FIXTURE_ROOT}/out.json
      points: 5
      category: functional_optional
      historical_category: optional
    - id: opt_03
      name: Duplicate detection (optional)
      command: ./fsaudit.sh "${FIXTURE_ROOT}"/e01_test --duplicates 2>/dev/null
      expect:
        all:
        - text:
            stream: stdout
            op: contains
            value: dup1.txt
        - text:
            stream: stdout
            op: contains
            value: dup2.txt
      points: 5
      category: functional_optional
      may_not_exist: true
      historical_category: optional
      historical_cli_alternative: ./fsaudit.sh /tmp/e01_test -d 2>/dev/null
      contract_status: proposed CLI only; canonical interface decision remains open
    - id: opt_04
      name: Old files (optional)
      command: ./fsaudit.sh "${FIXTURE_ROOT}"/e01_test --older-than 365 2>/dev/null
      expect:
        text:
          stream: stdout
          op: contains
          value: old.txt
      points: 5
      category: functional_optional
      may_not_exist: true
      historical_category: optional
    error_handling:
    - id: err_01
      name: Invalid argument
      command: ./fsaudit.sh --invalid-flag-xyz 2>&1
      expect:
        exit_code:
          op: ne
          value: 0
      points: 3
      category: error_handling
    - id: err_02
      name: Directory without permissions
      setup: mkdir -p "${FIXTURE_ROOT}"/noaccess && chmod 000 "${FIXTURE_ROOT}"/noaccess
      command: ./fsaudit.sh "${FIXTURE_ROOT}"/noaccess 2>&1
      expect:
        all:
        - exit_code:
            op: ne
            value: 0
        - any:
          - text:
              stream: combined
              op: contains
              value: permission
          - text:
              stream: combined
              op: contains
              value: denied
          - text:
              stream: combined
              op: contains
              value: access
      cleanup: chmod 755 "${FIXTURE_ROOT}"/noaccess; rm -rf "${FIXTURE_ROOT}"/noaccess
      points: 4
      category: error_handling
      requires_non_root: true
    - id: err_03
      name: File instead of directory
      command: ./fsaudit.sh "${FIXTURE_ROOT}"/e01_test/documents/large.pdf 2>&1
      expect:
        all:
        - exit_code:
            op: ne
            value: 0
        - any:
          - text:
              stream: combined
              op: contains
              value: directory
          - text:
              stream: combined
              op: contains
              value: not a directory
      points: 3
      category: error_handling
    code_quality:
    - id: qual_01
      name: Heuristic function-count proxy (not a proof of modularity)
      command: python3 "$EVALUATION_REFERENCE" count functions --root . --candidate src/fsaudit.sh --candidate fsaudit.sh
      expect:
        output_number:
          op: ge
          value: 3
      points: 5
      category: code_quality
      reference_operation: true
    - id: qual_02
      name: Comment-line proxy (not a proof of usefulness)
      command: python3 "$EVALUATION_REFERENCE" count comments --root . --candidate src/fsaudit.sh --candidate fsaudit.sh
      expect:
        output_number:
          op: ge
          value: 5
      points: 3
      category: code_quality
      reference_operation: true
    - id: qual_03
      name: Does not use undeclared variables dangerously
      command: python3 "$EVALUATION_REFERENCE" count sc2154 --root . --candidate src/fsaudit.sh --candidate fsaudit.sh
      expect:
        all:
        - output_number:
            op: ge
            value: 0
        - output_number:
            op: le
            value: 2
      points: 2
      category: code_quality
      requires_tools:
      - shellcheck
      reference_operation: true
      notes: Counts SC2154 records from one selected script using ShellCheck JSON; the original proposed 0–2 bound is retained, not adopted as an institutional policy or absence-of-danger proof.
  manual_evaluation_required:
  - criterion: Output clarity
    reason: Subjective - depends on visual preferences
    workaround: We only verify that output contains necessary information
    impact: 5% of score
  - criterion: README documentation quality
    reason: Requires semantic understanding of content
    workaround: We only verify minimum length
    impact: 2% of score
  - criterion: Code elegance
    reason: Subjective
    workaround: We use objective metrics (functions, comments)
    impact: 3% of score
```

---

## E02: Log Analyzer

```yaml
# Retained historical inline notes; the Phase 5 status above governs evidence/policy.
# Create standard syslog
# Create log with explicit levels
# Empty log for edge case
# Large log for performance
e02_log_analyzer:
  metadata:
    project_id: E02
    name: Log Analyzer
    difficulty: EASY
    estimated_test_time: 5m
    total_points: 73
    auto_evaluable_percent: 90
    historical_declared_total_points: 100
    test_count: 17
    policy_status: proposal_not_adopted
    evidence_status: unmeasured_planning_estimate
    fixture_lifecycle: fresh project copy and inherited setup per case; unconditional owned cleanup
  setup:
    commands:
    - |
      # Create standard syslog
      cat > "${FIXTURE_ROOT}"/e02_syslog.log << 'EOF'
      Jan 20 10:15:30 server sshd[1234]: Failed password for root from 192.168.1.100
      Jan 20 10:15:31 server sshd[1234]: Accepted password for admin from 192.168.1.50
      Jan 20 10:16:00 server kernel: Out of memory: Kill process 5678
      Jan 20 10:16:30 server cron[999]: (root) CMD (/usr/local/bin/backup.sh)
      Jan 20 10:17:00 server sshd[1235]: Failed password for invalid user test
      Jan 20 10:18:00 server nginx[2000]: 192.168.1.1 - - "GET /index.html" 200
      Jan 20 10:19:00 server nginx[2000]: 192.168.1.1 - - "GET /admin" 403
      Jan 20 10:20:00 server systemd[1]: Started Daily apt upgrade
      EOF

      # Create log with explicit levels
      cat > "${FIXTURE_ROOT}"/e02_levels.log << 'EOF'
      2025-01-20 10:00:00 [ERROR] Database connection failed
      2025-01-20 10:00:01 [INFO] Retrying connection...
      2025-01-20 10:00:02 [WARN] Connection slow
      2025-01-20 10:00:03 [ERROR] Connection timeout
      2025-01-20 10:00:04 [INFO] Fallback to secondary
      2025-01-20 10:00:05 [DEBUG] Query: SELECT * FROM users
      2025-01-20 10:00:06 [INFO] Service started successfully
      2025-01-20 10:00:07 [ERROR] Disk space low
      EOF

      # Empty log for edge case
      touch "${FIXTURE_ROOT}"/e02_empty.log

      # Large log for performance
      for i in $(seq 1 10000); do
        echo "Jan 20 10:00:$((i % 60)) server app[$i]: Log entry $i" >> "${FIXTURE_ROOT}"/e02_large.log
      done
  tests:
    structural:
    - id: struct_01
      name: Main script exists
      command: test -f src/loganalyzer.sh || test -f loganalyzer.sh
      points: 3
      category: structural
      expect:
        exit_code:
          op: eq
          value: 0
    - id: struct_02
      name: README present
      command: test -f README.md
      points: 2
      category: structural
      expect:
        exit_code:
          op: eq
          value: 0
    static:
    - id: static_01
      name: ShellCheck clean
      command: python3 "$EVALUATION_REFERENCE" inspect shellcheck --root .
      points: 5
      category: static_analysis
      expect:
        exit_code:
          op: eq
          value: 0
      requires_tools:
      - shellcheck
      reference_operation: true
    functional_core:
    - id: func_01
      name: Syslog parsing - extracts fields
      command: ./loganalyzer.sh "${FIXTURE_ROOT}"/e02_syslog.log
      expect:
        all:
        - text:
            stream: stdout
            op: contains
            value: sshd
        - text:
            stream: stdout
            op: contains
            value: kernel
        - text:
            stream: stdout
            op: contains
            value: nginx
      points: 5
      category: functional_core
    - id: func_02
      name: Filter by process/service
      command: ./loganalyzer.sh "${FIXTURE_ROOT}"/e02_syslog.log --service sshd 2>/dev/null
      expect:
        all:
        - all:
          - text:
              stream: stdout
              op: contains
              value: sshd
          - text:
              stream: stdout
              op: contains
              value: Failed
          - text:
              stream: stdout
              op: contains
              value: Accepted
        - all:
          - not:
              text:
                stream: stdout
                op: contains
                value: nginx
          - not:
              text:
                stream: stdout
                op: contains
                value: kernel
      points: 5
      category: functional_core
      historical_cli_alternative: ./loganalyzer.sh /tmp/e02_syslog.log -s sshd
      contract_status: proposed CLI only; canonical interface decision remains open
    - id: func_03
      name: Filter by level (ERROR)
      command: ./loganalyzer.sh "${FIXTURE_ROOT}"/e02_levels.log --level ERROR 2>/dev/null
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
              value: timeout
          - text:
              stream: stdout
              op: contains
              value: Disk
        - all:
          - not:
              text:
                stream: stdout
                op: contains
                value: INFO
          - not:
              text:
                stream: stdout
                op: contains
                value: DEBUG
          - not:
              text:
                stream: stdout
                op: contains
                value: started
      points: 5
      category: functional_core
      historical_cli_alternative: ./loganalyzer.sh /tmp/e02_levels.log -l ERROR
      contract_status: proposed CLI only; canonical interface decision remains open
    - id: func_04
      name: Level statistics
      command: ./loganalyzer.sh "${FIXTURE_ROOT}"/e02_levels.log --stats
      expect:
        all:
        - text:
            stream: stdout
            op: regex
            value: ERROR.*3|3.*ERROR
        - text:
            stream: stdout
            op: regex
            value: INFO.*3|3.*INFO
      points: 5
      category: functional_core
    - id: func_05
      name: Temporal filter --since
      command: ./loganalyzer.sh "${FIXTURE_ROOT}"/e02_syslog.log --since '10:17:00' 2>/dev/null
      expect:
        all:
        - all:
          - text:
              stream: stdout
              op: contains
              value: nginx
          - text:
              stream: stdout
              op: contains
              value: systemd
        - all:
          - not:
              text:
                stream: stdout
                op: contains
                value: kernel
          - not:
              text:
                stream: stdout
                op: contains
                value: cron
      points: 5
      category: functional_core
    - id: func_06
      name: Pattern search/grep
      command: ./loganalyzer.sh "${FIXTURE_ROOT}"/e02_syslog.log --grep 'Failed' 2>/dev/null
      expect:
        all:
        - text:
            stream: stdout
            op: contains
            value: Failed password
        - lines:
            stream: stdout
            op: eq
            value: 2
      points: 5
      category: functional_core
      historical_cli_alternative: ./loganalyzer.sh /tmp/e02_syslog.log -g 'Failed'
      contract_status: proposed CLI only; canonical interface decision remains open
    - id: func_07
      name: Count per source
      command: ./loganalyzer.sh "${FIXTURE_ROOT}"/e02_syslog.log --count-by service 2>/dev/null
      expect:
        all:
        - all:
          - text:
              stream: stdout
              op: contains
              value: sshd
          - text:
              stream: stdout
              op: contains
              value: nginx
        - text:
            stream: stdout
            op: regex
            value: '[0-9]+'
      points: 5
      category: functional_core
      historical_cli_alternative: ./loganalyzer.sh /tmp/e02_syslog.log --stats
      contract_status: proposed CLI only; canonical interface decision remains open
    - id: func_08
      name: Formatted output
      command: ./loganalyzer.sh "${FIXTURE_ROOT}"/e02_syslog.log | head -5
      expect:
        pending: Human-readable formatting needs a declared output schema and human review; a non-raw-looking string is not a valid automatic oracle.
      points: 5
      category: functional_core
    functional_optional:
    - id: opt_01
      name: JSON Export
      command: ./loganalyzer.sh "${FIXTURE_ROOT}"/e02_levels.log --format json
      expect:
        json_valid:
          stream: stdout
      points: 5
      may_not_exist: true
      category: functional_optional
    - id: opt_02
      name: Top N entries
      command: ./loganalyzer.sh "${FIXTURE_ROOT}"/e02_large.log --top 10 2>/dev/null
      expect:
        lines:
          stream: stdout
          op: le
          value: 15
      points: 5
      category: functional_optional
      historical_cli_alternative: ./loganalyzer.sh /tmp/e02_large.log -n 10
      contract_status: proposed CLI only; canonical interface decision remains open
    error_handling:
    - id: err_01
      name: Non-existent file
      command: ./loganalyzer.sh ${FIXTURE_ROOT}/missing.log 2>&1
      expect:
        exit_code:
          op: ne
          value: 0
      points: 3
      category: error_handling
    - id: err_02
      name: Empty file
      command: ./loganalyzer.sh "${FIXTURE_ROOT}"/e02_empty.log 2>&1
      expect:
        all:
        - exit_code:
            op: eq
            value: 0
        - any:
          - text:
              stream: stdout
              op: contains
              value: empty
          - text:
              stream: stdout
              op: contains
              value: no entries
          - text:
              stream: stdout
              op: contains
              value: '0'
      points: 3
      category: error_handling
    - id: err_03
      name: Invalid level
      command: ./loganalyzer.sh "${FIXTURE_ROOT}"/e02_levels.log --level INVALID_LEVEL 2>&1
      expect:
        exit_code:
          op: ne
          value: 0
      points: 2
      category: error_handling
    performance:
    - id: perf_01
      name: Processing 10k lines < 5 seconds
      command: ./loganalyzer.sh "${FIXTURE_ROOT}"/e02_large.log --stats 2>&1
      expect:
        duration:
          op: le
          value: 5
      points: 5
      category: performance
  manual_evaluation_required:
  - criterion: Human-readable output formatting
    reason: Subjective what 'readable' means
    impact: 5%
  - criterion: Support for non-standard log formats
    reason: Too many possible variations
    impact: 5%
```

---

## E03: Bulk File Organizer

```yaml
# Retained historical inline notes; the Phase 5 status above governs evidence/policy.
# Files by extension
# Files with different dates
# Files with different sizes
# Conflict test
# Either renames (doc1_1.txt), skips, or asks
e03_bulk_file_organizer:
  metadata:
    project_id: E03
    name: Bulk File Organizer
    difficulty: EASY
    estimated_test_time: 5m
    total_points: 70
    auto_evaluable_percent: 95
    historical_declared_total_points: 100
    test_count: 8
    policy_status: proposal_not_adopted
    evidence_status: unmeasured_planning_estimate
    fixture_lifecycle: fresh project copy and inherited setup per case; unconditional owned cleanup
  setup:
    commands:
    - |
      mkdir -p "${FIXTURE_ROOT}"/e03_source
      # Files by extension
      touch "${FIXTURE_ROOT}"/e03_source/{doc1,doc2,doc3}.txt
      touch "${FIXTURE_ROOT}"/e03_source/{photo1,photo2}.jpg
      touch "${FIXTURE_ROOT}"/e03_source/{video1}.mp4
      touch "${FIXTURE_ROOT}"/e03_source/{script1,script2}.sh
      touch "${FIXTURE_ROOT}"/e03_source/noextension

      # Files with different dates
      touch -d "2023-01-15" "${FIXTURE_ROOT}"/e03_source/old_2023.txt
      touch -d "2024-06-20" "${FIXTURE_ROOT}"/e03_source/mid_2024.txt
      touch -d "2025-01-10" "${FIXTURE_ROOT}"/e03_source/new_2025.txt

      # Files with different sizes
      dd if=/dev/zero of="${FIXTURE_ROOT}"/e03_source/small.bin bs=1K count=10 2>/dev/null
      dd if=/dev/zero of="${FIXTURE_ROOT}"/e03_source/medium.bin bs=1M count=5 2>/dev/null
      dd if=/dev/zero of="${FIXTURE_ROOT}"/e03_source/large.bin bs=1M count=50 2>/dev/null

      # Conflict test
      echo "version1" > "${FIXTURE_ROOT}"/e03_source/conflict.txt
      mkdir -p "${FIXTURE_ROOT}"/e03_dest/txt
      echo "version2" > "${FIXTURE_ROOT}"/e03_dest/txt/conflict.txt
  tests:
    functional_core:
    - id: func_01
      name: Organise by extension
      setup: rm -rf "${FIXTURE_ROOT}"/e03_dest; mkdir "${FIXTURE_ROOT}"/e03_dest
      command: ./organizer.sh "${FIXTURE_ROOT}"/e03_source "${FIXTURE_ROOT}"/e03_dest --by extension
      expect:
        all:
        - all:
          - path:
              kind: directory
              path: ${FIXTURE_ROOT}/e03_dest/txt
          - path:
              kind: directory
              path: ${FIXTURE_ROOT}/e03_dest/jpg
          - path:
              kind: directory
              path: ${FIXTURE_ROOT}/e03_dest/mp4
        - path:
            kind: file
            path: ${FIXTURE_ROOT}/e03_dest/txt/doc1.txt
        - file_count:
            path: ${FIXTURE_ROOT}/e03_dest/txt
            op: eq
            value: 7
        - file_count:
            path: ${FIXTURE_ROOT}/e03_dest/jpg
            op: eq
            value: 2
      points: 10
      category: functional_core
    - id: func_02
      name: Organise by date (year)
      setup: rm -rf -- "${FIXTURE_ROOT}"/e03_dest; mkdir -p -- "${FIXTURE_ROOT}"/e03_dest
      command: ./organizer.sh "${FIXTURE_ROOT}"/e03_source "${FIXTURE_ROOT}"/e03_dest --by date
      expect:
        glob:
          pattern: ${FIXTURE_ROOT}/e03_dest/202[345]
          kind: directory
      points: 10
      category: functional_core
    - id: func_03
      name: Organise by size
      setup: rm -rf "${FIXTURE_ROOT}"/e03_dest; mkdir "${FIXTURE_ROOT}"/e03_dest
      command: ./organizer.sh "${FIXTURE_ROOT}"/e03_source "${FIXTURE_ROOT}"/e03_dest --by size
      expect:
        pending: 'Choose the project directory/category naming contract before applying this alternative pattern: ${FIXTURE_ROOT}/e03_dest/(small|medium|large|<1MB|1-10MB|>10MB)'
      points: 10
      category: functional_core
    - id: func_04
      name: Dry-run does not move files
      setup: rm -rf "${FIXTURE_ROOT}"/e03_dest
      command: ./organizer.sh "${FIXTURE_ROOT}"/e03_source "${FIXTURE_ROOT}"/e03_dest --by extension --dry-run
      expect:
        all:
        - path:
            kind: file
            path: ${FIXTURE_ROOT}/e03_source/doc1.txt
        - not:
            path:
              kind: directory
              path: ${FIXTURE_ROOT}/e03_dest/txt
        - any:
          - text:
              stream: stdout
              op: contains
              value: would
          - text:
              stream: stdout
              op: contains
              value: dry
          - text:
              stream: stdout
              op: contains
              value: DRY
      points: 10
      category: functional_core
    - id: func_05
      name: Undo/Rollback works
      setup: |
        rm -rf "${FIXTURE_ROOT}"/e03_dest; mkdir "${FIXTURE_ROOT}"/e03_dest
        ./organizer.sh "${FIXTURE_ROOT}"/e03_source "${FIXTURE_ROOT}"/e03_dest --by extension
      command: ./organizer.sh --undo
      expect:
        path:
          kind: file
          path: ${FIXTURE_ROOT}/e03_source/doc1.txt
      points: 10
      category: functional_core
    - id: func_06
      name: Conflict handling (rename/skip)
      setup: |
        rm -rf "${FIXTURE_ROOT}"/e03_dest; mkdir -p "${FIXTURE_ROOT}"/e03_dest/txt
        echo "existing" > "${FIXTURE_ROOT}"/e03_dest/txt/doc1.txt
      command: ./organizer.sh "${FIXTURE_ROOT}"/e03_source "${FIXTURE_ROOT}"/e03_dest --by extension 2>&1
      expect:
        all:
        - exit_code:
            op: eq
            value: 0
        - any:
          - path:
              kind: file
              path: ${FIXTURE_ROOT}/e03_dest/txt/doc1_1.txt
          - all:
            - text:
                stream: stdout
                op: contains
                value: skip
            - text:
                stream: stdout
                op: contains
                value: conflict
            - text:
                stream: stdout
                op: contains
                value: exists
      points: 10
      category: functional_core
    error_handling:
    - id: err_01
      name: Non-existent source
      command: ./organizer.sh ${FIXTURE_ROOT}/missing "${FIXTURE_ROOT}"/dest --by extension 2>&1
      expect:
        exit_code:
          op: ne
          value: 0
      points: 5
      category: error_handling
    - id: err_02
      name: Invalid criterion
      command: ./organizer.sh "${FIXTURE_ROOT}"/e03_source "${FIXTURE_ROOT}"/dest --by invalid_criterion 2>&1
      expect:
        exit_code:
          op: ne
          value: 0
      points: 5
      category: error_handling
  manual_evaluation_required:
  - criterion: Naming logic for conflicts
    reason: Multiple valid strategies (numeric suffix, timestamp, etc.)
    impact: 3%
```

---

## E04: System Health Reporter

```yaml
e04_system_health_reporter:
  metadata:
    project_id: E04
    name: System Health Reporter
    difficulty: EASY
    estimated_test_time: 3m
    total_points: 55
    auto_evaluable_percent: 85
    historical_declared_total_points: 100
    test_count: 7
    policy_status: proposal_not_adopted
    evidence_status: unmeasured_planning_estimate
    fixture_lifecycle: fresh project copy and inherited setup per case; unconditional owned cleanup
  tests:
    functional_core:
    - id: func_01
      name: CPU report
      command: ./health.sh --cpu
      expect:
        text:
          stream: stdout
          op: regex
          value: '[0-9]+\.?[0-9]*\s*%'
      points: 10
      category: functional_core
    - id: func_02
      name: Memory report
      command: ./health.sh --memory
      expect:
        all:
        - text:
            stream: stdout
            op: regex
            value: '[0-9]+\s*(MB|GB|KB)'
        - any:
          - text:
              stream: stdout
              op: contains
              value: used
          - text:
              stream: stdout
              op: contains
              value: free
          - text:
              stream: stdout
              op: contains
              value: total
          - text:
              stream: stdout
              op: contains
              value: available
      points: 10
      category: functional_core
    - id: func_03
      name: Disk report
      command: ./health.sh --disk
      expect:
        all:
        - text:
            stream: stdout
            op: contains
            value: /
        - text:
            stream: stdout
            op: regex
            value: '[0-9]+%'
      points: 10
      category: functional_core
    - id: func_04
      name: Complete report
      command: ./health.sh --all 2>/dev/null
      expect:
        all:
        - text:
            stream: stdout
            op: contains
            value: CPU
        - text:
            stream: stdout
            op: contains
            value: Memory
        - text:
            stream: stdout
            op: contains
            value: Disk
      points: 10
      category: functional_core
      historical_cli_alternative: ./health.sh
      contract_status: proposed CLI only; canonical interface decision remains open
    - id: func_05
      name: ANSI colours for alerts
      command: ./health.sh --all
      expect:
        ansi: true
      points: 5
      category: functional_core
    - id: func_06
      name: Network monitoring
      command: ./health.sh --network 2>/dev/null
      expect:
        text:
          stream: stdout
          op: regex
          value: (eth|lo|enp|wlan|inet|RX|TX)
      points: 5
      may_not_exist: true
      category: functional_core
    - id: func_07
      name: Service status
      command: ./health.sh --services 2>/dev/null
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
        - text:
            stream: stdout
            op: contains
            value: stopped
      points: 5
      may_not_exist: true
      category: functional_core
  manual_evaluation_required:
  - criterion: Output readability
    reason: Formatting and visual organisation are subjective
    impact: 10%
  - criterion: Relevance of displayed information
    reason: Depends on usage context
    impact: 5%
```

---

## E05: Config File Manager

```yaml
# Retained historical inline notes; the Phase 5 status above governs evidence/policy.
# Test config
# Server configuration
e05_config_file_manager:
  metadata:
    project_id: E05
    name: Config File Manager
    difficulty: EASY
    estimated_test_time: 4m
    total_points: 60
    auto_evaluable_percent: 90
    historical_declared_total_points: 100
    test_count: 7
    policy_status: proposal_not_adopted
    evidence_status: unmeasured_planning_estimate
    fixture_lifecycle: fresh project copy and inherited setup per case; unconditional owned cleanup
  setup:
    commands:
    - |
      # Test config
      cat > "${FIXTURE_ROOT}"/e05_test.conf << 'EOF'
      # Server configuration
      server_name=localhost
      port=8080
      debug=true
      max_connections=100
      EOF
  tests:
    functional_core:
    - id: func_01
      name: Backup config
      command: ./configmgr.sh backup "${FIXTURE_ROOT}"/e05_test.conf
      expect:
        all:
        - exit_code:
            op: eq
            value: 0
        - pending: 'Exact project/platform contract required for backup_created_pattern: "${FIXTURE_ROOT}/e05_test.conf.*backup|~/.configmgr/"'
      points: 10
      category: functional_core
      requires_platform: owned configuration/version storage adapter; the prototype must not write a host HOME directory
    - id: func_02
      name: List versions
      setup: |
        ./configmgr.sh backup "${FIXTURE_ROOT}"/e05_test.conf
        echo "port=9090" >> "${FIXTURE_ROOT}"/e05_test.conf
        ./configmgr.sh backup "${FIXTURE_ROOT}"/e05_test.conf
      command: ./configmgr.sh list "${FIXTURE_ROOT}"/e05_test.conf
      expect:
        all:
        - lines:
            stream: stdout
            op: ge
            value: 2
        - text:
            stream: stdout
            op: regex
            value: (v|version|#)?[0-9]+
      points: 10
      category: functional_core
      requires_platform: owned configuration/version storage adapter; the prototype must not write a host HOME directory
    - id: func_03
      name: Restore version
      command: ./configmgr.sh restore "${FIXTURE_ROOT}"/e05_test.conf --version 1
      expect:
        all:
        - file_text:
            path: ${FIXTURE_ROOT}/e05_test.conf
            op: contains
            value: port=8080
        - not:
            file_text:
              path: ${FIXTURE_ROOT}/e05_test.conf
              op: contains
              value: port=9090
      points: 10
      category: functional_core
      requires_platform: owned configuration/version storage adapter; the prototype must not write a host HOME directory
      setup: |-
        ./configmgr.sh backup "${FIXTURE_ROOT}"/e05_test.conf
        printf "port=9090\n" >> "${FIXTURE_ROOT}"/e05_test.conf
        ./configmgr.sh backup "${FIXTURE_ROOT}"/e05_test.conf
    - id: func_04
      name: Diff between versions
      command: ./configmgr.sh diff "${FIXTURE_ROOT}"/e05_test.conf
      expect:
        all:
        - all:
          - text:
              stream: stdout
              op: contains
              value: '8080'
          - text:
              stream: stdout
              op: contains
              value: '9090'
        - any:
          - text:
              stream: stdout
              op: contains
              value: '-'
          - text:
              stream: stdout
              op: contains
              value: +
          - text:
              stream: stdout
              op: contains
              value: <
          - text:
              stream: stdout
              op: contains
              value: '>'
          - text:
              stream: stdout
              op: contains
              value: changed
      points: 10
      category: functional_core
      requires_platform: owned configuration/version storage adapter; the prototype must not write a host HOME directory
      setup: |-
        ./configmgr.sh backup "${FIXTURE_ROOT}"/e05_test.conf
        printf "port=9090\n" >> "${FIXTURE_ROOT}"/e05_test.conf
        ./configmgr.sh backup "${FIXTURE_ROOT}"/e05_test.conf
    - id: func_05
      name: Diff with specific version
      command: ./configmgr.sh diff "${FIXTURE_ROOT}"/e05_test.conf --v1 1 --v2 2 2>/dev/null
      expect:
        text:
          stream: stdout
          op: contains
          value: port
      points: 10
      category: functional_core
      historical_cli_alternative: ./configmgr.sh diff /tmp/e05_test.conf 1 2
      contract_status: proposed CLI only; canonical interface decision remains open
      requires_platform: owned configuration/version storage adapter; the prototype must not write a host HOME directory
      setup: |-
        ./configmgr.sh backup "${FIXTURE_ROOT}"/e05_test.conf
        printf "port=9090\n" >> "${FIXTURE_ROOT}"/e05_test.conf
        ./configmgr.sh backup "${FIXTURE_ROOT}"/e05_test.conf
    error_handling:
    - id: err_01
      name: Non-existent config
      command: ./configmgr.sh backup ${FIXTURE_ROOT}/missing.conf 2>&1
      expect:
        exit_code:
          op: ne
          value: 0
      points: 5
      category: error_handling
      requires_platform: owned configuration/version storage adapter; the prototype must not write a host HOME directory
    - id: err_02
      name: Non-existent version
      command: ./configmgr.sh restore "${FIXTURE_ROOT}"/e05_test.conf --version 999 2>&1
      expect:
        exit_code:
          op: ne
          value: 0
      points: 5
      category: error_handling
      requires_platform: owned configuration/version storage adapter; the prototype must not write a host HOME directory
```

---

## Summary E01-E05: What Requires Additional or Human Evidence

| Project | Non-evaluable Criterion | Impact | Reason |
|---------|-------------------------|--------|--------|
| **E01** | Output clarity | 5% | Subjective |
| **E01** | README quality | 2% | Requires semantic understanding |
| **E02** | Human-readable output format | 5% | Personal preferences |
| **E02** | Support for non-standard log formats | 5% | Too many variations |
| **E03** | Conflict strategy | 3% | Multiple valid approaches |
| **E04** | Output readability | 10% | Subjective |
| **E04** | Information relevance | 5% | Context-dependent |
| **E05** | Backup storage organisation | 5% | Multiple valid options |

**Total not automatically evaluable for EASY: ~5-15% per project**
