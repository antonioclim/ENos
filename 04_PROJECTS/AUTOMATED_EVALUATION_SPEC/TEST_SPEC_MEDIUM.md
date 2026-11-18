# Detailed Test Specifications - MEDIUM Projects (M01-M15)

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


## General Note

MEDIUM projects have higher complexity and require:
- Sandbox with more utilities installed
- Longer execution time (timeout 60-120s per test)
- More complex setup (mock services, simulated network)
- Integration tests in addition to unit tests

---

## M01: Incremental Backup System

```yaml
# Retained historical inline notes; the Phase 5 status above governs evidence/policy.
# Test structure
# Files for exclusion
# === FULL BACKUP (20 points) ===
# === INCREMENTAL BACKUP (20 points) ===
# === COMPRESSION (10 points) ===
# === RESTORE (15 points) ===
# === ROTATION (15 points) ===
# === INTEGRITY VERIFICATION (5 points) ===
# === SCHEDULING (5 points) ===
# === ERROR HANDLING (5 points) ===
m01_incremental_backup:
  metadata:
    project_id: M01
    total_points: 95
    auto_evaluable_percent: 90
    estimated_test_time: 12m
    required_tools:
    - tar
    - gzip
    - bzip2
    - xz
    - sha256sum
    - cron
    historical_declared_total_points: 100
    test_count: 17
    policy_status: proposal_not_adopted
    evidence_status: unmeasured_planning_estimate
    fixture_lifecycle: fresh project copy and inherited setup per case; unconditional owned cleanup
  setup:
    commands:
    - |
      # Test structure
      mkdir -p "${FIXTURE_ROOT}"/m01_source/{docs,images,code}
      echo "document 1" > "${FIXTURE_ROOT}"/m01_source/docs/file1.txt
      echo "document 2" > "${FIXTURE_ROOT}"/m01_source/docs/file2.txt
      dd if=/dev/urandom of="${FIXTURE_ROOT}"/m01_source/images/photo.jpg bs=1K count=100 2>/dev/null
      echo '#!/bin/bash\necho hello' > "${FIXTURE_ROOT}"/m01_source/code/script.sh
      mkdir -p "${FIXTURE_ROOT}"/m01_backup

      # Files for exclusion
      touch "${FIXTURE_ROOT}"/m01_source/docs/temp.tmp
      mkdir -p "${FIXTURE_ROOT}"/m01_source/.cache
      echo "cache" > "${FIXTURE_ROOT}"/m01_source/.cache/data
  tests:
    backup_full:
    - id: full_01
      name: Full backup creates archive
      command: ./backup.sh full -s "${FIXTURE_ROOT}"/m01_source -d "${FIXTURE_ROOT}"/m01_backup -n test
      expect:
        all:
        - all:
          - exit_code:
              op: eq
              value: 0
          - glob:
              pattern: ${FIXTURE_ROOT}/m01_backup/*full*.tar*
              kind: file
        - pending: M01 canonical CLI, archive-ID/manifest/root and retention-selection contract is not adopted; an adapter must define the exact producer receipt and dependency-preserving expected state.
      points: 8
      timeout: 60
      category: backup_full
    - id: full_02
      name: Archive contains all files
      command: tar -tzf "${FIXTURE_ROOT}"/m01_backup/*full*.tar.gz 2>/dev/null | wc -l
      expect:
        all:
        - output_number:
            op: ge
            value: 4
        - pending: M01 canonical CLI, archive-ID/manifest/root and retention-selection contract is not adopted; an adapter must define the exact producer receipt and dependency-preserving expected state.
      points: 6
      category: backup_full
    - id: full_03
      name: Checksum generated
      command: test -f "${FIXTURE_ROOT}"/m01_backup/*full*.sha256 && echo exists
      expect:
        all:
        - text:
            stream: stdout
            op: contains
            value: exists
        - pending: M01 canonical CLI, archive-ID/manifest/root and retention-selection contract is not adopted; an adapter must define the exact producer receipt and dependency-preserving expected state.
      points: 6
      category: backup_full
    backup_incremental:
    - id: incr_01
      name: Detects modified files
      setup: |
        ./backup.sh full -s "${FIXTURE_ROOT}"/m01_source -d "${FIXTURE_ROOT}"/m01_backup -n test
        sleep 1
        echo "modified" >> "${FIXTURE_ROOT}"/m01_source/docs/file1.txt
        touch "${FIXTURE_ROOT}"/m01_source/docs/new_file.txt
      command: ./backup.sh incremental -s "${FIXTURE_ROOT}"/m01_source -d "${FIXTURE_ROOT}"/m01_backup -n test
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
                value: 2 files
            - text:
                stream: stdout
                op: contains
                value: modified
            - text:
                stream: stdout
                op: contains
                value: new_file
        - pending: M01 canonical CLI, archive-ID/manifest/root and retention-selection contract is not adopted; an adapter must define the exact producer receipt and dependency-preserving expected state.
      points: 10
      category: backup_incremental
    - id: incr_02
      name: Incremental archive smaller than full
      command: |
        full_size=$(stat -c%s "${FIXTURE_ROOT}"/m01_backup/*full*.tar.* 2>/dev/null | head -1)
        incr_size=$(stat -c%s "${FIXTURE_ROOT}"/m01_backup/*incr*.tar.* 2>/dev/null | head -1)
        [ "$incr_size" -lt "$full_size" ] && echo "smaller"
      expect:
        all:
        - text:
            stream: stdout
            op: contains
            value: smaller
        - pending: M01 canonical CLI, archive-ID/manifest/root and retention-selection contract is not adopted; an adapter must define the exact producer receipt and dependency-preserving expected state.
      points: 10
      category: backup_incremental
      notes: A size comparison is fixture-specific and cannot replace exact reconstructed-content/deletion checks.
    compression:
    - id: comp_01
      name: Gzip compression
      command: ./backup.sh full -s "${FIXTURE_ROOT}"/m01_source -d "${FIXTURE_ROOT}"/m01_backup --compress gzip -n gzip_test
      expect:
        all:
        - glob:
            pattern: '*.tar.gz'
            kind: file
        - pending: M01 canonical CLI, archive-ID/manifest/root and retention-selection contract is not adopted; an adapter must define the exact producer receipt and dependency-preserving expected state.
      points: 3
      category: compression
    - id: comp_02
      name: Bzip2 compression
      command: ./backup.sh full -s "${FIXTURE_ROOT}"/m01_source -d "${FIXTURE_ROOT}"/m01_backup --compress bzip2 -n bz2_test
      expect:
        all:
        - glob:
            pattern: '*.tar.bz2'
            kind: file
        - pending: M01 canonical CLI, archive-ID/manifest/root and retention-selection contract is not adopted; an adapter must define the exact producer receipt and dependency-preserving expected state.
      points: 3
      category: compression
    - id: comp_03
      name: Xz compression
      command: ./backup.sh full -s "${FIXTURE_ROOT}"/m01_source -d "${FIXTURE_ROOT}"/m01_backup --compress xz -n xz_test
      expect:
        all:
        - glob:
            pattern: '*.tar.xz'
            kind: file
        - pending: M01 canonical CLI, archive-ID/manifest/root and retention-selection contract is not adopted; an adapter must define the exact producer receipt and dependency-preserving expected state.
      points: 4
      category: compression
    restore:
    - id: rest_01
      name: Complete restore
      command: |
        ./backup.sh restore "${BACKUP_ID:?fixture adapter must export the exact returned ID}" -o "${FIXTURE_ROOT}"/m01_restored
      expect:
        all:
        - all:
          - exit_code:
              op: eq
              value: 0
          - path:
              kind: directory
              path: ${FIXTURE_ROOT}/m01_restored
          - path:
              kind: file
              path: ${FIXTURE_ROOT}/m01_restored/docs/file1.txt
        - pending: M01 canonical CLI, archive-ID/manifest/root and retention-selection contract is not adopted; an adapter must define the exact producer receipt and dependency-preserving expected state.
      points: 8
      category: restore
    - id: rest_02
      name: Selective restore
      command: ./backup.sh restore "${BACKUP_ID:?fixture adapter must export the exact returned ID}" -f docs/file1.txt -o "${FIXTURE_ROOT}"/m01_selective
      expect:
        all:
        - all:
          - path:
              kind: file
              path: ${FIXTURE_ROOT}/m01_selective/docs/file1.txt
          - not:
              path:
                kind: file
                path: ${FIXTURE_ROOT}/m01_selective/images/photo.jpg
        - pending: M01 canonical CLI, archive-ID/manifest/root and retention-selection contract is not adopted; an adapter must define the exact producer receipt and dependency-preserving expected state.
      points: 7
      category: restore
    rotation:
    - id: rot_01
      name: Keeps N backups
      setup: |
        for i in $(seq 1 10); do
          ./backup.sh full -s "${FIXTURE_ROOT}"/m01_source -d "${FIXTURE_ROOT}"/m01_backup -n "rot_$i"
          sleep 1
        done
      command: ./backup.sh prune --keep-daily 3
      expect:
        all:
        - pending: 'Exact project/platform contract required for backup_count_max: 3'
        - pending: M01 canonical CLI, archive-ID/manifest/root and retention-selection contract is not adopted; an adapter must define the exact producer receipt and dependency-preserving expected state.
      points: 8
      category: rotation
      notes: Retain selected restore points plus every required ancestor; three daily points do not imply at most three archive directories.
    - id: rot_02
      name: Rotation keeps the newest
      command: ls -t "${FIXTURE_ROOT}"/m01_backup/*full* | head -3
      expect:
        all:
        - all:
          - text:
              stream: stdout
              op: contains
              value: rot_10
          - text:
              stream: stdout
              op: contains
              value: rot_9
          - text:
              stream: stdout
              op: contains
              value: rot_8
        - pending: M01 canonical CLI, archive-ID/manifest/root and retention-selection contract is not adopted; an adapter must define the exact producer receipt and dependency-preserving expected state.
      points: 7
      category: rotation
      notes: Retain selected restore points plus every required ancestor; three daily points do not imply at most three archive directories.
    integrity:
    - id: int_01
      name: Verify correct for valid archive
      command: ./backup.sh verify "${BACKUP_ID:?fixture adapter must export the exact returned ID}"
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
                value: OK
            - text:
                stream: stdout
                op: contains
                value: valid
            - text:
                stream: stdout
                op: contains
                value: verified
        - pending: M01 canonical CLI, archive-ID/manifest/root and retention-selection contract is not adopted; an adapter must define the exact producer receipt and dependency-preserving expected state.
      points: 3
      category: integrity
    - id: int_02
      name: Verify detects corruption
      setup: truncate -s 100 "${FIXTURE_ROOT}"/m01_backup/corrupt.tar.gz
      command: ./backup.sh verify "${FIXTURE_ROOT}"/m01_backup/corrupt.tar.gz 2>&1
      expect:
        all:
        - all:
          - exit_code:
              op: ne
              value: 0
          - any:
            - text:
                stream: stdout
                op: contains
                value: corrupt
            - text:
                stream: stdout
                op: contains
                value: invalid
            - text:
                stream: stdout
                op: contains
                value: failed
        - pending: M01 canonical CLI, archive-ID/manifest/root and retention-selection contract is not adopted; an adapter must define the exact producer receipt and dependency-preserving expected state.
      points: 2
      category: integrity
    scheduling:
    - id: sched_01
      name: Cron job generation
      command: ./backup.sh schedule on --cron '0 3 * * *' 2>&1; crontab -l
      expect:
        all:
        - all:
          - text:
              stream: stdout
              op: contains
              value: backup
          - text:
              stream: stdout
              op: contains
              value: 0 3
        - pending: M01 canonical CLI, archive-ID/manifest/root and retention-selection contract is not adopted; an adapter must define the exact producer receipt and dependency-preserving expected state.
      points: 5
      category: scheduling
      requires_platform: isolated disposable service/network/scheduler environment with an owned adapter; not supported by the local reference
    errors:
    - id: err_01
      name: Non-existent source
      command: ./backup.sh full -s ${FIXTURE_ROOT}/missing -d "${FIXTURE_ROOT}"/backup 2>&1
      expect:
        all:
        - exit_code:
            op: ne
            value: 0
        - pending: M01 canonical CLI, archive-ID/manifest/root and retention-selection contract is not adopted; an adapter must define the exact producer receipt and dependency-preserving expected state.
      points: 3
      category: errors
    - id: err_02
      name: Destination without permissions
      setup: mkdir -p "${FIXTURE_ROOT}"/noaccess && chmod 000 "${FIXTURE_ROOT}"/noaccess
      command: ./backup.sh full -s "${FIXTURE_ROOT}"/m01_source -d "${FIXTURE_ROOT}"/noaccess 2>&1
      expect:
        all:
        - exit_code:
            op: ne
            value: 0
        - pending: M01 canonical CLI, archive-ID/manifest/root and retention-selection contract is not adopted; an adapter must define the exact producer receipt and dependency-preserving expected state.
      points: 2
      category: errors
      requires_non_root: true
  manual_evaluation_required:
  - criterion: Efficiency of incremental algorithm
    reason: Requires manual analysis of strategy (timestamp vs checksum)
    impact: 5%
  - criterion: Robustness to interruptions
    reason: Bounded fault injection is automatable; production recovery needs additional evidence
    impact: 3%
  - criterion: Logging quality
    reason: Subjective what level of detail is optimal
    impact: 2%
```

---

## M02: Process Lifecycle Monitor

```yaml
m02_process_lifecycle_monitor:
  metadata:
    project_id: M02
    total_points: 80
    auto_evaluable_percent: 85
    estimated_test_time: 10m
    required_tools:
    - ps
    - top
    - /proc filesystem
    historical_declared_total_points: 100
    test_count: 8
    policy_status: proposal_not_adopted
    evidence_status: unmeasured_planning_estimate
    fixture_lifecycle: fresh project copy and inherited setup per case; unconditional owned cleanup
  tests:
    process_monitoring:
    - id: mon_01
      name: Monitoring by PID
      setup: |-
        sleep 300 & echo $!
        export SETUP_PID=$!
        export PID=${PID:-$SETUP_PID}
      command: ./procmon.sh status ${SETUP_PID:?owned setup process required}
      expect:
        all:
        - text:
            stream: stdout
            op: contains
            value: sleep
        - text:
            stream: stdout
            op: contains
            value: '300'
      points: 10
      cleanup: if [[ -n ${SETUP_PID:-} ]]; then kill "$SETUP_PID" 2>/dev/null || true; wait "$SETUP_PID" 2>/dev/null || true; fi
      category: process_monitoring
    - id: mon_02
      name: Monitoring by name
      setup: |-
        sleep 300 &
        export SETUP_PID=$!
        export PID=${PID:-$SETUP_PID}
      command: ./procmon.sh status sleep
      expect:
        all:
        - text:
            stream: stdout
            op: contains
            value: sleep
        - text:
            stream: stdout
            op: regex
            value: PID.*[0-9]+
      points: 10
      category: process_monitoring
      cleanup: if [[ -n ${SETUP_PID:-} ]]; then kill "$SETUP_PID" 2>/dev/null || true; wait "$SETUP_PID" 2>/dev/null || true; fi
    - id: mon_03
      name: Monitoring by pattern
      setup: |-
        bash -c 'exec -a my_custom_process sleep 300' &
        export SETUP_PID=$!
        export PID=${PID:-$SETUP_PID}
      command: ./procmon.sh status 'my_custom'
      expect:
        text:
          stream: stdout
          op: contains
          value: my_custom
      points: 5
      category: process_monitoring
      cleanup: if [[ -n ${SETUP_PID:-} ]]; then kill "$SETUP_PID" 2>/dev/null || true; wait "$SETUP_PID" 2>/dev/null || true; fi
    resource_tracking:
    - id: res_01
      name: Display CPU usage
      setup: |-
        yes > /dev/null & PID=$!
        export SETUP_PID=$!
        export PID=${PID:-$SETUP_PID}
      command: ./procmon.sh status $PID
      expect:
        text:
          stream: stdout
          op: regex
          value: '[0-9]+\.?[0-9]*\s*%'
      points: 10
      cleanup: if [[ -n ${SETUP_PID:-} ]]; then kill "$SETUP_PID" 2>/dev/null || true; wait "$SETUP_PID" 2>/dev/null || true; fi
      category: resource_tracking
    - id: res_02
      name: Display memory
      setup: |-
        python3 -c 'x=[0]*1000000; import time; time.sleep(60)' &
        export SETUP_PID=$!
        export PID=${PID:-$SETUP_PID}
      command: ./procmon.sh status "${SETUP_PID:?owned setup process required}"
      expect:
        text:
          stream: stdout
          op: regex
          value: '[0-9]+\s*(MB|KB|M|K)'
      points: 10
      category: resource_tracking
      cleanup: if [[ -n ${SETUP_PID:-} ]]; then kill "$SETUP_PID" 2>/dev/null || true; wait "$SETUP_PID" 2>/dev/null || true; fi
    process_tree:
    - id: tree_01
      name: Display tree
      setup: |-
        bash -c 'sleep 300 & child=$!; trap '"'"'kill "$child" 2>/dev/null; wait "$child" 2>/dev/null'"'"' EXIT; wait "$child"' &
        export SETUP_PID=$!
      command: ./procmon.sh tree "${SETUP_PID:?owned setup process required}"
      expect:
        all:
        - all:
          - text:
              stream: stdout
              op: contains
              value: bash
          - text:
              stream: stdout
              op: contains
              value: sleep
        - text:
            stream: stdout
            op: regex
            value: '[├└│]'
      points: 15
      category: process_tree
      cleanup: if [[ -n ${SETUP_PID:-} ]]; then kill "$SETUP_PID" 2>/dev/null || true; wait "$SETUP_PID" 2>/dev/null || true; fi
    event_detection:
    - id: evt_01
      name: Detect process exit
      setup: |-
        (sleep 2; exit 0) &
        export SETUP_PID=$!
        export PID=${PID:-$SETUP_PID}
      command: ./procmon.sh watch "${SETUP_PID:?owned setup process required}" --duration 1 2>&1
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
        - text:
            stream: stdout
            op: contains
            value: stopped
      points: 10
      timeout: 75
      category: event_detection
      notes: The assignment duration option is in minutes. This proposed one-minute check has a 75-second outer bound; it is not a five-second test.
      cleanup: if [[ -n ${SETUP_PID:-} ]]; then kill "$SETUP_PID" 2>/dev/null || true; wait "$SETUP_PID" 2>/dev/null || true; fi
    - id: evt_02
      name: CPU threshold alerting
      setup: |-
        yes > /dev/null &
        export SETUP_PID=$!
        export PID=${PID:-$SETUP_PID}
      command: ./procmon.sh watch "${SETUP_PID:?owned setup process required}" --cpu-alert 50 --duration 1 2>&1
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
        - text:
            stream: stdout
            op: contains
            value: exceeded
      points: 10
      cleanup: if [[ -n ${SETUP_PID:-} ]]; then kill "$SETUP_PID" 2>/dev/null || true; wait "$SETUP_PID" 2>/dev/null || true; fi
      category: event_detection
      timeout: 75
      notes: The assignment duration option is in minutes. This proposed one-minute check has a 75-second outer bound; it is not a five-second test.
  manual_evaluation_required:
  - criterion: Accuracy of CPU measurements
    reason: Varies depending on system load
    impact: 5%
  - criterion: Dashboard quality
    reason: Subjective UX
    impact: 10%
```

---

## M03-M15: Common Template

For brevity, I present the common pattern and specifics of each project:

```yaml
# Retained historical inline notes; the Phase 5 status above governs evidence/policy.
# MEDIUM Template
# Specifics per project:
medium_project_template:
  test_categories:
    structural: 10%
    static_analysis: 10%
    functional_core: 40%
    functional_optional: 15%
    error_handling: 10%
    performance: 5%
    code_quality: 5%
    documentation: 5%
  common_tests:
  - help_flag
  - version_flag
  - no_args_usage
  - shellcheck_clean
  - exit_codes_correct
  - handles_invalid_input
m03_service_health_watchdog:
  key_tests:
  - check_systemd_service_status
  - check_tcp_port_open
  - daemon_mode_pidfile
  - alert_on_service_down
  - auto_restart_with_cooldown
  docker_requirements:
  - systemd or mock services
  - TCP ports for verification
  hard_to_automate:
  - Email/Slack alert quality (requires SMTP mock)
  - Behaviour under real load
m04_network_security_scanner:
  key_tests:
  - ping_sweep_localhost
  - port_scan_tcp_connect
  - port_range_parsing
  - parallel_scan_performance
  - json_html_report_generation
  - banner_grabbing
  docker_requirements:
  - Network isolation
  - Open ports for testing
  hard_to_automate:
  - Accuracy of service identification
  - Correlation with real vulnerabilities
  security_note: Runs only on 127.0.0.1 in sandbox
m05_deployment_pipeline:
  key_tests:
  - detect_project_type_node
  - detect_project_type_python
  - atomic_deploy_symlink
  - rollback_to_previous
  - health_check_post_deploy
  docker_requirements:
  - Node.js, Python installed
  - releases/ structure
  hard_to_automate:
  - Integration with real CI/CD
  - Complete blue-green deployment
m06_resource_usage_historian:
  key_tests:
  - collect_cpu_metrics
  - collect_memory_metrics
  - store_in_sqlite
  - generate_ascii_graph
  - generate_report
  docker_requirements:
  - SQLite
  - ASCII graphs (or pattern verification)
  hard_to_automate:
  - Accuracy of trend prediction
  - Quality of visualisations
m07_security_audit_framework:
  key_tests:
  - audit_empty_passwords
  - audit_uid_zero_users
  - audit_world_writable_files
  - audit_suid_files
  - audit_ssh_config
  - report_severity_levels
  docker_requirements:
  - Test files with known security issues
  hard_to_automate:
  - Relevance of recommendations
  - False positives in real context
m08_disk_storage_manager:
  key_tests:
  - analyze_disk_usage
  - find_large_files
  - cleanup_temp_files
  - cleanup_old_logs
  - detect_duplicates
  - threshold_alerts
  docker_requirements:
  - Test files of various sizes
  hard_to_automate:
  - Safety of delete operations
  - Space prediction (requires historical data)
m09_scheduled_tasks_manager:
  key_tests:
  - add_cron_task
  - add_systemd_timer
  - list_tasks_all_sources
  - remove_task
  - execution_history
  docker_requirements:
  - cron daemon
  - systemd (or mock)
  hard_to_automate:
  - Validation of complex cron expressions
  - Integration with real systemd
m10_process_tree_analyzer:
  key_tests:
  - build_process_tree
  - detect_zombie_processes
  - detect_orphan_processes
  - aggregate_by_user
  - export_dot_format
  docker_requirements:
  - /proc filesystem
  - Graphviz for DOT validation
  hard_to_automate:
  - Accuracy of anomaly detection in real context
m11_memory_forensics_tool:
  key_tests:
  - parse_meminfo
  - analyze_process_memory
  - parse_memory_maps
  - detect_memory_leak_pattern
  - snapshot_compare
  docker_requirements:
  - /proc/meminfo, /proc/[pid]/maps
  - Process with simulated memory leak
  hard_to_automate:
  - Accuracy of real leak detection
  - Differentiating leak vs legitimate usage
m12_file_integrity_monitor:
  key_tests:
  - create_baseline
  - detect_modified_file
  - detect_new_file
  - detect_deleted_file
  - inotify_watch_mode
  - alert_on_change
  docker_requirements:
  - inotify-tools
  - sha256sum
  hard_to_automate:
  - Performance with many files
  - False positives (legitimately modified files)
m13_log_aggregator:
  key_tests:
  - tail_multiple_files
  - parse_syslog_format
  - parse_json_logs
  - filter_by_level
  - alert_on_pattern
  - rate_limit_alerts
  docker_requirements:
  - journalctl (or mock)
  - Multiple log files
  hard_to_automate:
  - Parsing non-standard log formats
  - Quality of correlations
m14_environment_config_manager:
  key_tests:
  - load_environment_with_inheritance
  - template_variable_substitution
  - encrypt_secret
  - decrypt_secret
  - diff_environments
  - validate_required_vars
  docker_requirements:
  - OpenSSL
  hard_to_automate:
  - Security of encryption implementation
  - Business logic validation in config
m15_parallel_execution_engine:
  key_tests:
  - parallel_execution_workers
  - respect_concurrency_limit
  - timeout_per_job
  - progress_bar_display
  - retry_failed_jobs
  - ordered_output
  docker_requirements:
  - Multiple CPU cores (or simulation)
  hard_to_automate:
  - Correctness of synchronisation
  - Race conditions
```

---

## Summary M01-M15: What Requires Additional or Human Evidence

| Project | Criterion | Impact | Technical Reason |
|---------|-----------|--------|------------------|
| **M01** | Efficiency of incremental algorithm | 5% | Requires strategy analysis |
| **M01** | Robustness to interruptions | 3% | Controlled owned fault/recovery fixtures are feasible; scope must be stated |
| **M02** | Dashboard quality | 10% | Subjective UX |
| **M02** | Measurement accuracy | 5% | Varies with load |
| **M03** | Email/Slack alerting | 5% | Requires external services |
| **M04** | Service identification | 5% | Fingerprint databases |
| **M05** | Real CI/CD integration | 5% | External infrastructure |
| **M06** | Visualisation quality | 8% | Subjective aesthetics |
| **M06** | Trend prediction | 5% | Requires historical data |
| **M07** | Recommendation relevance | 10% | Context-dependent |
| **M08** | Delete safety | 5% | Use disposable owned fixtures; operational acceptance remains separate |
| **M09** | Real systemd integration | 5% | Requires complete system |
| **M10** | Real anomaly detection | 5% | Production system context |
| **M11** | Real leak detection | 10% | Requires real applications |
| **M12** | False positives | 5% | Depends on workflow |
| **M13** | Custom format parsing | 5% | Infinite variations |
| **M14** | Encryption security | 8% | Requires security audit |
| **M15** | Race conditions | 5% | Non-deterministic |

**Total not automatically evaluable for MEDIUM: ~10-20% per project**
