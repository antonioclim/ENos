# Detailed Test Specifications - MEDIUM Projects (M01-M15)

## General Note

MEDIUM projects have higher complexity and require:
- Sandbox with more utilities installed
- Longer execution time (timeout 60-120s per test)
- More complex setup (mock services, simulated network)
- Integration tests in addition to unit tests

---

## M01: Incremental Backup System

```yaml
m01_incremental_backup:
  metadata:
    project_id: M01
    total_points: 100
    auto_evaluable_percent: 90
    estimated_test_time: 12m
    required_tools: [tar, gzip, bzip2, xz, sha256sum, cron]

  setup:
    commands:
      - |
        # Test structure
        mkdir -p /tmp/m01_source/{docs,images,code}
        echo "document 1" > /tmp/m01_source/docs/file1.txt
        echo "document 2" > /tmp/m01_source/docs/file2.txt
        dd if=/dev/urandom of=/tmp/m01_source/images/photo.jpg bs=1K count=100 2>/dev/null
        echo '#!/bin/bash\necho hello' > /tmp/m01_source/code/script.sh
        mkdir -p /tmp/m01_backup
        
        # Files for exclusion
        touch /tmp/m01_source/docs/temp.tmp
        mkdir -p /tmp/m01_source/.cache
        echo "cache" > /tmp/m01_source/.cache/data

  tests:
    # === FULL BACKUP (20 points) ===
    backup_full:
      - id: full_01
        name: "Full backup creates archive"
        command: "./backup.sh full -s /tmp/m01_source -d /tmp/m01_backup -n test"
        expect:
          exit_code: 0
          file_exists_pattern: "/tmp/m01_backup/*full*.tar*"
        points: 8
        timeout: 60
        
      - id: full_02
        name: "Archive contains all files"
        command: "tar -tzf /tmp/m01_backup/*full*.tar.gz 2>/dev/null | wc -l"
        expect:
          output_matches_regex: "[4-9]|[1-9][0-9]+"
        points: 6
        
      - id: full_03
        name: "Checksum generated"
        command: "test -f /tmp/m01_backup/*full*.sha256 && echo exists"
        expect:
          output_contains: "exists"
        points: 6

    # === INCREMENTAL BACKUP (20 points) ===
    backup_incremental:
      - id: incr_01
        name: "Detects modified files"
        setup: |
          ./backup.sh full -s /tmp/m01_source -d /tmp/m01_backup -n test
          sleep 1
          echo "modified" >> /tmp/m01_source/docs/file1.txt
          touch /tmp/m01_source/docs/new_file.txt
        command: "./backup.sh incremental -s /tmp/m01_source -d /tmp/m01_backup -n test"
        expect:
          exit_code: 0
          output_contains_one_of: ["2 files", "modified", "new_file"]
        points: 10
        
      - id: incr_02
        name: "Incremental archive smaller than full"
        command: |
          full_size=$(stat -c%s /tmp/m01_backup/*full*.tar.* 2>/dev/null | head -1)
          incr_size=$(stat -c%s /tmp/m01_backup/*incr*.tar.* 2>/dev/null | head -1)
          [ "$incr_size" -lt "$full_size" ] && echo "smaller"
        expect:
          output_contains: "smaller"
        points: 10

    # === COMPRESSION (10 points) ===
    compression:
      - id: comp_01
        name: "Gzip compression"
        command: "./backup.sh full -s /tmp/m01_source -d /tmp/m01_backup --compress gzip -n gzip_test"
        expect:
          file_exists_pattern: "*.tar.gz"
        points: 3
        
      - id: comp_02
        name: "Bzip2 compression"
        command: "./backup.sh full -s /tmp/m01_source -d /tmp/m01_backup --compress bzip2 -n bz2_test"
        expect:
          file_exists_pattern: "*.tar.bz2"
        points: 3
        
      - id: comp_03
        name: "Xz compression"
        command: "./backup.sh full -s /tmp/m01_source -d /tmp/m01_backup --compress xz -n xz_test"
        expect:
          file_exists_pattern: "*.tar.xz"
        points: 4

    # === RESTORE (15 points) ===
    restore:
      - id: rest_01
        name: "Complete restore"
        command: |
          ./backup.sh restore $(ls /tmp/m01_backup/*full* | head -1 | xargs basename | cut -d. -f1) -o /tmp/m01_restored
        expect:
          exit_code: 0
          dir_exists: "/tmp/m01_restored"
          file_exists: "/tmp/m01_restored/docs/file1.txt"
        points: 8
        
      - id: rest_02
        name: "Selective restore"
        command: "./backup.sh restore BACKUP_ID -f docs/file1.txt -o /tmp/m01_selective"
        expect:
          file_exists: "/tmp/m01_selective/docs/file1.txt"
          file_not_exists: "/tmp/m01_selective/images/photo.jpg"
        points: 7

    # === ROTATION (15 points) ===
    rotation:
      - id: rot_01
        name: "Keeps N backups"
        setup: |
          for i in $(seq 1 10); do
            ./backup.sh full -s /tmp/m01_source -d /tmp/m01_backup -n "rot_$i"
            sleep 1
          done
        command: "./backup.sh prune --keep-daily 3"
        expect:
          backup_count_max: 3
        points: 8
        
      - id: rot_02
        name: "Rotation keeps the newest"
        command: "ls -t /tmp/m01_backup/*full* | head -3"
        expect:
          output_contains: ["rot_10", "rot_9", "rot_8"]
        points: 7

    # === INTEGRITY VERIFICATION (5 points) ===
    integrity:
      - id: int_01
        name: "Verify correct for valid archive"
        command: "./backup.sh verify $(ls /tmp/m01_backup/*full* | head -1)"
        expect:
          exit_code: 0
          output_contains_one_of: ["OK", "valid", "verified"]
        points: 3
        
      - id: int_02
        name: "Verify detects corruption"
        setup: "truncate -s 100 /tmp/m01_backup/corrupt.tar.gz"
        command: "./backup.sh verify /tmp/m01_backup/corrupt.tar.gz 2>&1"
        expect:
          exit_code: "!= 0"
          output_contains_one_of: ["corrupt", "invalid", "failed"]
        points: 2

    # === SCHEDULING (5 points) ===
    scheduling:
      - id: sched_01
        name: "Cron job generation"
        command: "./backup.sh schedule on --cron '0 3 * * *' 2>&1; crontab -l"
        expect:
          output_contains: ["backup", "0 3"]
        points: 5

    # === ERROR HANDLING (5 points) ===
    errors:
      - id: err_01
        name: "Non-existent source"
        command: "./backup.sh full -s /nonexistent -d /tmp/backup 2>&1"
        expect:
          exit_code: "!= 0"
        points: 3
        
      - id: err_02
        name: "Destination without permissions"
        setup: "mkdir -p /tmp/noaccess && chmod 000 /tmp/noaccess"
        command: "./backup.sh full -s /tmp/m01_source -d /tmp/noaccess 2>&1"
        expect:
          exit_code: "!= 0"
        points: 2

  manual_evaluation_required:
    - criterion: "Efficiency of incremental algorithm"
      reason: "Requires manual analysis of strategy (timestamp vs checksum)"
      impact: "5%"
      
    - criterion: "Robustness to interruptions"
      reason: "Difficult to test automatically (kill during backup)"
      impact: "3%"
      
    - criterion: "Logging quality"
      reason: "Subjective what level of detail is optimal"
      impact: "2%"
```

---

## M02: Process Lifecycle Monitor

```yaml
m02_process_lifecycle_monitor:
  metadata:
    project_id: M02
    total_points: 100
    auto_evaluable_percent: 85
    estimated_test_time: 10m
    required_tools: [ps, top, /proc filesystem]

  tests:
    process_monitoring:
      - id: mon_01
        name: "Monitoring by PID"
        setup: "sleep 300 & echo $!"
        command: "./procmon.sh status $SETUP_PID"
        expect:
          output_contains: ["sleep", "300"]
        points: 10
        cleanup: "kill $SETUP_PID 2>/dev/null"
        
      - id: mon_02
        name: "Monitoring by name"
        setup: "sleep 300 &"
        command: "./procmon.sh status sleep"
        expect:
          output_contains: "sleep"
          output_matches_regex: "PID.*[0-9]+"
        points: 10
        
      - id: mon_03
        name: "Monitoring by pattern"
        setup: "bash -c 'exec -a my_custom_process sleep 300' &"
        command: "./procmon.sh status 'my_custom'"
        expect:
          output_contains: "my_custom"
        points: 5

    resource_tracking:
      - id: res_01
        name: "Display CPU usage"
        setup: "yes > /dev/null & PID=$!"
        command: "./procmon.sh status $PID"
        expect:
          output_matches_regex: "[0-9]+\\.?[0-9]*\\s*%"
        points: 10
        cleanup: "kill $PID"
        
      - id: res_02
        name: "Display memory"
        setup: "python3 -c 'x=[0]*1000000; import time; time.sleep(60)' &"
        command: "./procmon.sh status $!"
        expect:
          output_matches_regex: "[0-9]+\\s*(MB|KB|M|K)"
        points: 10

    process_tree:
      - id: tree_01
        name: "Display tree"
        setup: "bash -c 'sleep 300 &' &"
        command: "./procmon.sh tree $$"
        expect:
          output_contains: ["bash", "sleep"]
          output_matches_regex: "[├└│]"
        points: 15

    event_detection:
      - id: evt_01
        name: "Detect process exit"
        setup: "(sleep 2; exit 0) &"
        command: "./procmon.sh watch $! --duration 5 2>&1"
        expect:
          output_contains_one_of: ["exit", "terminated", "stopped"]
        points: 10
        timeout: 10
        
      - id: evt_02
        name: "CPU threshold alerting"
        setup: "yes > /dev/null &"
        command: "./procmon.sh watch $! --cpu-alert 50 --duration 3 2>&1"
        expect:
          output_contains_one_of: ["alert", "threshold", "exceeded"]
        points: 10
        cleanup: "kill $!"

  manual_evaluation_required:
    - criterion: "Accuracy of CPU measurements"
      reason: "Varies depending on system load"
      impact: "5%"
      
    - criterion: "Dashboard quality"
      reason: "Subjective UX"
      impact: "10%"
```

---

## M03-M15: Common Template

For brevity, I present the common pattern and specifics of each project:

```yaml
# MEDIUM Template
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
    - "help_flag"
    - "version_flag"
    - "no_args_usage"
    - "shellcheck_clean"
    - "exit_codes_correct"
    - "handles_invalid_input"

# Specifics per project:

m03_service_health_watchdog:
  key_tests:
    - "check_systemd_service_status"
    - "check_tcp_port_open"
    - "daemon_mode_pidfile"
    - "alert_on_service_down"
    - "auto_restart_with_cooldown"
  docker_requirements:
    - "systemd or mock services"
    - "TCP ports for verification"
  hard_to_automate:
    - "Email/Slack alert quality (requires SMTP mock)"
    - "Behaviour under real load"

m04_network_security_scanner:
  key_tests:
    - "ping_sweep_localhost"
    - "port_scan_tcp_connect"
    - "port_range_parsing"
    - "parallel_scan_performance"
    - "json_html_report_generation"
    - "banner_grabbing"
  docker_requirements:
    - "Network isolation"
    - "Open ports for testing"
  hard_to_automate:
    - "Accuracy of service identification"
    - "Correlation with real vulnerabilities"
  security_note: "Runs only on 127.0.0.1 in sandbox"

m05_deployment_pipeline:
  key_tests:
    - "detect_project_type_node"
    - "detect_project_type_python"
    - "atomic_deploy_symlink"
    - "rollback_to_previous"
    - "health_check_post_deploy"
  docker_requirements:
    - "Node.js, Python installed"
    - "releases/ structure"
  hard_to_automate:
    - "Integration with real CI/CD"
    - "Complete blue-green deployment"

m06_resource_usage_historian:
  key_tests:
    - "collect_cpu_metrics"
    - "collect_memory_metrics"
    - "store_in_sqlite"
    - "generate_ascii_graph"
    - "generate_report"
  docker_requirements:
    - "SQLite"
    - "ASCII graphs (or pattern verification)"
  hard_to_automate:
    - "Accuracy of trend prediction"
    - "Quality of visualisations"

m07_security_audit_framework:
  key_tests:
    - "audit_empty_passwords"
    - "audit_uid_zero_users"
    - "audit_world_writable_files"
    - "audit_suid_files"
    - "audit_ssh_config"
    - "report_severity_levels"
  docker_requirements:
    - "Test files with known security issues"
  hard_to_automate:
    - "Relevance of recommendations"
    - "False positives in real context"

m08_disk_storage_manager:
  key_tests:
    - "analyze_disk_usage"
    - "find_large_files"
    - "cleanup_temp_files"
    - "cleanup_old_logs"
    - "detect_duplicates"
    - "threshold_alerts"
  docker_requirements:
    - "Test files of various sizes"
  hard_to_automate:
    - "Safety of delete operations"
    - "Space prediction (requires historical data)"

m09_scheduled_tasks_manager:
  key_tests:
    - "add_cron_task"
    - "add_systemd_timer"
    - "list_tasks_all_sources"
    - "remove_task"
    - "execution_history"
  docker_requirements:
    - "cron daemon"
    - "systemd (or mock)"
  hard_to_automate:
    - "Validation of complex cron expressions"
    - "Integration with real systemd"

m10_process_tree_analyzer:
  key_tests:
    - "build_process_tree"
    - "detect_zombie_processes"
    - "detect_orphan_processes"
    - "aggregate_by_user"
    - "export_dot_format"
  docker_requirements:
    - "/proc filesystem"
    - "Graphviz for DOT validation"
  hard_to_automate:
    - "Accuracy of anomaly detection in real context"

m11_memory_forensics_tool:
  key_tests:
    - "parse_meminfo"
    - "analyze_process_memory"
    - "parse_memory_maps"
    - "detect_memory_leak_pattern"
    - "snapshot_compare"
  docker_requirements:
    - "/proc/meminfo, /proc/[pid]/maps"
    - "Process with simulated memory leak"
  hard_to_automate:
    - "Accuracy of real leak detection"
    - "Differentiating leak vs legitimate usage"

m12_file_integrity_monitor:
  key_tests:
    - "create_baseline"
    - "detect_modified_file"
    - "detect_new_file"
    - "detect_deleted_file"
    - "inotify_watch_mode"
    - "alert_on_change"
  docker_requirements:
    - "inotify-tools"
    - "sha256sum"
  hard_to_automate:
    - "Performance with many files"
    - "False positives (legitimately modified files)"

m13_log_aggregator:
  key_tests:
    - "tail_multiple_files"
    - "parse_syslog_format"
    - "parse_json_logs"
    - "filter_by_level"
    - "alert_on_pattern"
    - "rate_limit_alerts"
  docker_requirements:
    - "journalctl (or mock)"
    - "Multiple log files"
  hard_to_automate:
    - "Parsing non-standard log formats"
    - "Quality of correlations"

m14_environment_config_manager:
  key_tests:
    - "load_environment_with_inheritance"
    - "template_variable_substitution"
    - "encrypt_secret"
    - "decrypt_secret"
    - "diff_environments"
    - "validate_required_vars"
  docker_requirements:
    - "OpenSSL"
  hard_to_automate:
    - "Security of encryption implementation"
    - "Business logic validation in config"

m15_parallel_execution_engine:
  key_tests:
    - "parallel_execution_workers"
    - "respect_concurrency_limit"
    - "timeout_per_job"
    - "progress_bar_display"
    - "retry_failed_jobs"
    - "ordered_output"
  docker_requirements:
    - "Multiple CPU cores (or simulation)"
  hard_to_automate:
    - "Correctness of synchronisation"
    - "Race conditions"
```

---

## Summary M01-M15: What CANNOT Be Evaluated Automatically

| Project | Criterion | Impact | Technical Reason |
|---------|-----------|--------|------------------|
| **M01** | Efficiency of incremental algorithm | 5% | Requires strategy analysis |
| **M01** | Robustness to interruptions | 3% | Difficult to simulate correctly |
| **M02** | Dashboard quality | 10% | Subjective UX |
| **M02** | Measurement accuracy | 5% | Varies with load |
| **M03** | Email/Slack alerting | 5% | Requires external services |
| **M04** | Service identification | 5% | Fingerprint databases |
| **M05** | Real CI/CD integration | 5% | External infrastructure |
| **M06** | Visualisation quality | 8% | Subjective aesthetics |
| **M06** | Trend prediction | 5% | Requires historical data |
| **M07** | Recommendation relevance | 10% | Context-dependent |
| **M08** | Delete safety | 5% | Cannot test without risk |
| **M09** | Real systemd integration | 5% | Requires complete system |
| **M10** | Real anomaly detection | 5% | Production system context |
| **M11** | Real leak detection | 10% | Requires real applications |
| **M12** | False positives | 5% | Depends on workflow |
| **M13** | Custom format parsing | 5% | Infinite variations |
| **M14** | Encryption security | 8% | Requires security audit |
| **M15** | Race conditions | 5% | Non-deterministic |

**Total not automatically evaluable for MEDIUM: ~10-20% per project**
