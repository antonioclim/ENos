# Automatic Evaluation System Specifications - OS Projects

## Document Version 1.0 | January 2025

---

## Contents

1. [General Architecture](#1-general-architecture)
2. [Evaluation Components](#2-evaluation-components)
3. [Automated Tests per Category](#3-automated-tests-per-category)
4. [Detailed Specifications per Project](#4-detailed-specifications-per-project)
5. [Criteria NOT EVALUABLE Automatically](#5-criteria-not-evaluable-automatically)
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
    - name: "has_readme"
      check: "test -f README.md"
      points: 1
      
    - name: "has_main_script"
      check: "find src -name '*.sh' -type f | head -1"
      points: 2
      
    - name: "has_makefile"
      check: "test -f Makefile"
      points: 1
      
    - name: "proper_structure"
      check: "test -d src && test -d tests"
      points: 2

  static_analysis:
    - name: "shellcheck_clean"
      check: "shellcheck -S error src/**/*.sh"
      points: 5
      partial: true  # Partial points for warnings
      
    - name: "no_syntax_errors"
      check: "bash -n src/**/*.sh"
      points: 3
      
    - name: "shebang_present"
      check: "head -1 src/*.sh | grep -q '^#!/bin/bash'"
      points: 1
      
    - name: "set_options"
      check: "grep -l 'set -.*e' src/*.sh"
      points: 2

  basic_execution:
    - name: "runs_without_args"
      check: "./script.sh"
      expect: "exit_code != 0 AND shows_help"
      points: 2
      
    - name: "help_flag"
      check: "./script.sh --help"
      expect: "exit_code == 0 AND output_contains('usage')"
      points: 2
      
    - name: "version_flag"
      check: "./script.sh --version"
      expect: "exit_code == 0"
      points: 1
```

---

## 3. Automated Tests per Category

### 3.1 EASY Projects (E01-E05)

#### E01: File System Auditor

```yaml
e01_tests:
  functional:
    - name: "basic_scan"
      setup: "mkdir -p /tmp/test/{a,b,c}; dd if=/dev/zero of=/tmp/test/a/big bs=1M count=10"
      check: "./fsaudit.sh /tmp/test"
      expect:
        - "output_contains('/tmp/test/a/big')"
        - "output_contains('10')"  # MB
      points: 5
      
    - name: "extension_stats"
      setup: "touch /tmp/test/{a.txt,b.txt,c.log,d.log,e.log}"
      check: "./fsaudit.sh /tmp/test --stats"
      expect:
        - "output_contains('.txt') AND output_contains('2')"
        - "output_contains('.log') AND output_contains('3')"
      points: 5
      
    - name: "permission_audit"
      setup: "chmod 777 /tmp/test/a/big"
      check: "./fsaudit.sh /tmp/test --permissions"
      expect: "output_contains('777') OR output_contains('world-writable')"
      points: 5
      
    - name: "csv_export"
      check: "./fsaudit.sh /tmp/test --format csv -o /tmp/out.csv"
      expect:
        - "exit_code == 0"
        - "file_exists('/tmp/out.csv')"
        - "file_is_valid_csv('/tmp/out.csv')"
      points: 3
      
    - name: "json_export"
      check: "./fsaudit.sh /tmp/test --format json -o /tmp/out.json"
      expect:
        - "file_is_valid_json('/tmp/out.json')"
      points: 3

  error_handling:
    - name: "nonexistent_dir"
      check: "./fsaudit.sh /nonexistent"
      expect: "exit_code != 0 AND stderr_contains('error')"
      points: 2
      
    - name: "no_read_permission"
      setup: "mkdir /tmp/noaccess; chmod 000 /tmp/noaccess"
      check: "./fsaudit.sh /tmp/noaccess"
      expect: "exit_code != 0 OR stderr_contains('permission')"
      points: 2
```

#### E02: Log Analyzer

```yaml
e02_tests:
  functional:
    - name: "parse_syslog"
      setup: |
        cat > /tmp/test.log << 'EOF'
        Jan 20 10:15:30 host sshd[1234]: Failed password for root
        Jan 20 10:15:31 host sshd[1234]: Accepted password for user
        Jan 20 10:15:32 host kernel: Out of memory
        EOF
      check: "./loganalyzer.sh /tmp/test.log"
      expect:
        - "output_contains('sshd') OR output_contains('kernel')"
      points: 5
      
    - name: "filter_by_level"
      setup: |
        cat > /tmp/test.log << 'EOF'
        Jan 20 10:00:00 host app: [ERROR] Database connection failed
        Jan 20 10:00:01 host app: [INFO] Starting service
        Jan 20 10:00:02 host app: [WARN] High memory usage
        Jan 20 10:00:03 host app: [ERROR] Timeout
        EOF
      check: "./loganalyzer.sh /tmp/test.log --level ERROR"
      expect:
        - "output_contains('Database') AND output_contains('Timeout')"
        - "NOT output_contains('Starting')"
      points: 5
      
    - name: "time_filter"
      check: "./loganalyzer.sh /tmp/test.log --since '10:00:01' --until '10:00:02'"
      expect:
        - "output_contains('INFO') OR output_contains('WARN')"
        - "NOT output_contains('ERROR')"
      points: 5
      
    - name: "statistics"
      check: "./loganalyzer.sh /tmp/test.log --stats"
      expect:
        - "output_matches_regex('ERROR.*2')"
        - "output_matches_regex('INFO.*1')"
      points: 5
```

#### E03: Bulk File Organizer

```yaml
e03_tests:
  functional:
    - name: "organize_by_extension"
      setup: |
        mkdir -p /tmp/source
        touch /tmp/source/{a,b}.txt /tmp/source/{c,d}.jpg /tmp/source/{e}.pdf
      check: "./organizer.sh /tmp/source /tmp/dest --by extension"
      expect:
        - "dir_exists('/tmp/dest/txt')"
        - "file_count('/tmp/dest/txt') == 2"
        - "dir_exists('/tmp/dest/jpg')"
      points: 5
      
    - name: "organize_by_date"
      setup: |
        touch -d "2024-01-15" /tmp/source/old.txt
        touch -d "2025-01-20" /tmp/source/new.txt
      check: "./organizer.sh /tmp/source /tmp/dest --by date"
      expect:
        - "dir_exists('/tmp/dest/2024') OR dir_exists('/tmp/dest/2024-01')"
        - "dir_exists('/tmp/dest/2025') OR dir_exists('/tmp/dest/2025-01')"
      points: 5
      
    - name: "dry_run"
      check: "./organizer.sh /tmp/source /tmp/dest --by extension --dry-run"
      expect:
        - "output_contains('would move') OR output_contains('DRY')"
        - "file_exists('/tmp/source/a.txt')"  # File not actually moved
      points: 5
      
    - name: "undo"
      setup: "./organizer.sh /tmp/source /tmp/dest --by extension"
      check: "./organizer.sh --undo"
      expect:
        - "file_exists('/tmp/source/a.txt')"
        - "NOT dir_exists('/tmp/dest/txt') OR dir_empty('/tmp/dest/txt')"
      points: 5
      
    - name: "conflict_handling"
      setup: |
        echo "v1" > /tmp/source/test.txt
        mkdir -p /tmp/dest/txt
        echo "v2" > /tmp/dest/txt/test.txt
      check: "./organizer.sh /tmp/source /tmp/dest --by extension"
      expect:
        - "exit_code == 0"
        - "file_exists('/tmp/dest/txt/test.txt') OR file_exists('/tmp/dest/txt/test_1.txt')"
      points: 5
```

#### E04: System Health Reporter

```yaml
e04_tests:
  functional:
    - name: "cpu_report"
      check: "./health.sh --cpu"
      expect:
        - "output_matches_regex('[0-9]+\\.?[0-9]*%')"
      points: 3
      
    - name: "memory_report"
      check: "./health.sh --memory"
      expect:
        - "output_contains('MB') OR output_contains('GB')"
        - "output_matches_regex('[0-9]+')"
      points: 3
      
    - name: "disk_report"
      check: "./health.sh --disk"
      expect:
        - "output_contains('/') OR output_contains('root')"
        - "output_matches_regex('[0-9]+%')"
      points: 3
      
    - name: "full_report"
      check: "./health.sh --all"
      expect:
        - "output_contains('CPU') OR output_contains('cpu')"
        - "output_contains('Memory') OR output_contains('RAM')"
        - "output_contains('Disk')"
      points: 5
      
    - name: "alert_colors"
      check: "./health.sh --all"
      expect:
        - "output_contains_ansi_codes()"
      points: 3
```

#### E05: Config File Manager

```yaml
e05_tests:
  functional:
    - name: "backup_config"
      setup: "echo 'test=123' > /tmp/test.conf"
      check: "./configmgr.sh backup /tmp/test.conf"
      expect:
        - "exit_code == 0"
        - "backup_file_exists('/tmp/test.conf')"
      points: 5
      
    - name: "list_versions"
      setup: |
        ./configmgr.sh backup /tmp/test.conf
        echo 'test=456' > /tmp/test.conf
        ./configmgr.sh backup /tmp/test.conf
      check: "./configmgr.sh list /tmp/test.conf"
      expect:
        - "output_line_count() >= 2"
      points: 3
      
    - name: "restore_version"
      check: "./configmgr.sh restore /tmp/test.conf --version 1"
      expect:
        - "file_contains('/tmp/test.conf', 'test=123')"
      points: 5
      
    - name: "diff_versions"
      check: "./configmgr.sh diff /tmp/test.conf --v1 1 --v2 2"
      expect:
        - "output_contains('123') AND output_contains('456')"
        - "output_contains('-') OR output_contains('+')"
      points: 5
```

### 3.2 MEDIUM Projects (M01-M15)

#### M01: Incremental Backup System

```yaml
m01_tests:
  functional:
    - name: "full_backup"
      setup: |
        mkdir -p /tmp/source/{a,b}
        echo "file1" > /tmp/source/a/f1.txt
        echo "file2" > /tmp/source/b/f2.txt
      check: "./backup.sh full -s /tmp/source -d /tmp/backup -n test"
      expect:
        - "exit_code == 0"
        - "backup_archive_exists('/tmp/backup')"
        - "archive_contains('a/f1.txt')"
      points: 10
      timeout: 60
      
    - name: "incremental_backup"
      setup: |
        # After full backup
        echo "modified" > /tmp/source/a/f1.txt
        echo "new" > /tmp/source/new.txt
      check: "./backup.sh incremental -s /tmp/source -d /tmp/backup -n test"
      expect:
        - "exit_code == 0"
        - "incremental_archive_smaller_than_full()"
        - "archive_contains('new.txt')"
      points: 15
      
    - name: "compression_gzip"
      check: "./backup.sh full -s /tmp/source -d /tmp/backup --compress gzip"
      expect:
        - "file_exists_with_extension('.tar.gz')"
      points: 3
      
    - name: "compression_xz"
      check: "./backup.sh full -s /tmp/source -d /tmp/backup --compress xz"
      expect:
        - "file_exists_with_extension('.tar.xz')"
      points: 3
      
    - name: "restore_full"
      check: "./backup.sh restore BACKUP_ID -o /tmp/restored"
      expect:
        - "files_identical('/tmp/source', '/tmp/restored')"
      points: 10
      
    - name: "restore_selective"
      check: "./backup.sh restore BACKUP_ID -f a/f1.txt -o /tmp/restored"
      expect:
        - "file_exists('/tmp/restored/a/f1.txt')"
        - "NOT file_exists('/tmp/restored/b/f2.txt')"
      points: 5
      
    - name: "rotation"
      setup: "create_multiple_backups(10)"
      check: "./backup.sh prune --keep-daily 3"
      expect:
        - "backup_count() <= 3"
      points: 10
      
    - name: "integrity_verify"
      check: "./backup.sh verify BACKUP_ID"
      expect:
        - "exit_code == 0"
        - "output_contains('verified') OR output_contains('OK')"
      points: 5
      
    - name: "schedule_cron"
      check: "./backup.sh schedule on --cron '0 3 * * *'"
      expect:
        - "crontab_contains('backup')"
      points: 5

  error_handling:
    - name: "source_not_exists"
      check: "./backup.sh full -s /nonexistent -d /tmp/backup"
      expect: "exit_code != 0"
      points: 2
      
    - name: "corrupted_archive"
      setup: "truncate -s 100 /tmp/backup/archive.tar.gz"
      check: "./backup.sh verify BACKUP_ID"
      expect: "exit_code != 0 AND output_contains('corrupt')"
      points: 3
```

#### M02: Process Lifecycle Monitor

```yaml
m02_tests:
  functional:
    - name: "monitor_by_pid"
      setup: "sleep 300 &; PID=$!"
      check: "./procmon.sh status $PID"
      expect:
        - "output_contains('sleep')"
        - "output_contains('CPU') OR output_contains('%')"
      points: 5
      cleanup: "kill $PID"
      
    - name: "monitor_by_name"
      setup: "sleep 300 &"
      check: "./procmon.sh status sleep"
      expect:
        - "output_contains('sleep')"
      points: 5
      
    - name: "process_tree"
      setup: "bash -c 'sleep 300 &' &"
      check: "./procmon.sh tree $$"
      expect:
        - "output_contains('bash')"
        - "output_contains('sleep')"
        - "output_contains('├') OR output_contains('└')"
      points: 10
      
    - name: "resource_tracking"
      setup: |
        # Process that consumes memory
        python3 -c 'x=[0]*10000000; import time; time.sleep(60)' &
        PID=$!
      check: "./procmon.sh status $PID"
      expect:
        - "output_matches_regex('[0-9]+ MB') OR output_matches_regex('[0-9]+MB')"
        - "memory_value() > 10"  # Should show >10MB
      points: 10
      
    - name: "event_detection_exit"
      setup: |
        (sleep 2; exit 0) &
        PID=$!
      check: "./procmon.sh watch $PID --duration 5"
      expect:
        - "output_contains('exit') OR output_contains('terminated')"
      points: 10
      timeout: 10
      
    - name: "cpu_alert"
      setup: |
        # CPU-intensive process
        yes > /dev/null &
        PID=$!
      check: "./procmon.sh watch $PID --cpu-alert 50 --duration 3"
      expect:
        - "output_contains('alert') OR output_contains('threshold')"
      points: 5
      cleanup: "kill $PID"
```

#### M03: Service Health Watchdog

```yaml
m03_tests:
  # Note: Requires mock services or Docker
  functional:
    - name: "check_running_service"
      # Assume ssh/cron runs in container
      check: "./watchdog.sh status cron"
      expect:
        - "output_contains('running') OR output_contains('active')"
      points: 5
      
    - name: "check_stopped_service"
      setup: "systemctl stop cron 2>/dev/null || service cron stop"
      check: "./watchdog.sh status cron"
      expect:
        - "output_contains('stopped') OR output_contains('inactive')"
      points: 5
      cleanup: "systemctl start cron 2>/dev/null || service cron start"
      
    - name: "check_tcp_port"
      setup: "nc -l 8888 &"
      check: "./watchdog.sh check-port 8888"
      expect:
        - "exit_code == 0"
        - "output_contains('open') OR output_contains('OK')"
      points: 5
      
    - name: "daemon_mode"
      check: "./watchdog.sh daemon start"
      expect:
        - "pid_file_exists()"
        - "process_running('watchdog')"
      points: 10
      cleanup: "./watchdog.sh daemon stop"
      
    - name: "config_file_parsing"
      setup: |
        cat > /tmp/watchdog.yaml << 'EOF'
        services:
          - name: test
            type: process
            check: "pgrep bash"
        EOF
      check: "./watchdog.sh -c /tmp/watchdog.yaml status"
      expect:
        - "exit_code == 0"
      points: 5
```

#### M04: Network Security Scanner

```yaml
m04_tests:
  functional:
    - name: "ping_sweep"
      check: "./netscan.sh discover 127.0.0.1/32"
      expect:
        - "output_contains('127.0.0.1')"
        - "output_contains('up') OR output_contains('alive')"
      points: 5
      
    - name: "port_scan_single"
      setup: "nc -l 9999 &"
      check: "./netscan.sh scan 127.0.0.1 -p 9999"
      expect:
        - "output_contains('9999')"
        - "output_contains('open')"
      points: 5
      
    - name: "port_scan_range"
      setup: "nc -l 8001 & nc -l 8002 &"
      check: "./netscan.sh scan 127.0.0.1 -p 8000-8010"
      expect:
        - "output_contains('8001') AND output_contains('8002')"
        - "output_contains('open')"
      points: 10
      
    - name: "parallel_scan"
      check: "./netscan.sh scan 127.0.0.1 -p 1-1000 -j 10"
      expect:
        - "execution_time() < 30"  # Parallel = fast
      points: 5
      timeout: 60
      
    - name: "json_output"
      check: "./netscan.sh scan 127.0.0.1 -p 22,80 --format json"
      expect:
        - "output_is_valid_json()"
        - "json_has_key('host') OR json_has_key('ports')"
      points: 5
      
    - name: "html_report"
      check: "./netscan.sh scan 127.0.0.1 -p 1-100 --format html -o /tmp/report.html"
      expect:
        - "file_exists('/tmp/report.html')"
        - "file_contains_html_tags('/tmp/report.html')"
      points: 5
```

#### M05: Deployment Pipeline

```yaml
m05_tests:
  functional:
    - name: "detect_node_project"
      setup: |
        mkdir -p /tmp/project
        echo '{"name":"test","scripts":{"build":"echo built"}}' > /tmp/project/package.json
      check: "./deploy.sh build /tmp/project"
      expect:
        - "output_contains('node') OR output_contains('npm')"
      points: 5
      
    - name: "detect_python_project"
      setup: |
        mkdir -p /tmp/project
        echo 'flask==2.0' > /tmp/project/requirements.txt
      check: "./deploy.sh build /tmp/project"
      expect:
        - "output_contains('python') OR output_contains('pip')"
      points: 5
      
    - name: "deploy_atomic"
      setup: "mkdir -p /tmp/deploy/releases"
      check: "./deploy.sh deploy /tmp/project -e dev"
      expect:
        - "symlink_exists('/tmp/deploy/current')"
        - "symlink_target_contains('releases')"
      points: 10
      
    - name: "rollback"
      setup: |
        ./deploy.sh deploy /tmp/project -e dev
        ./deploy.sh deploy /tmp/project -e dev  # Second release
      check: "./deploy.sh rollback -e dev"
      expect:
        - "exit_code == 0"
        - "symlink_changed('/tmp/deploy/current')"
      points: 10
      
    - name: "health_check"
      setup: |
        # Create mock app with health endpoint
        cat > /tmp/project/app.sh << 'EOF'
        #!/bin/bash
        while true; do echo -e "HTTP/1.1 200 OK\n\nOK" | nc -l 8080 -q 1; done
        EOF
        chmod +x /tmp/project/app.sh
      check: "./deploy.sh deploy /tmp/project -e dev --health-check http://localhost:8080"
      expect:
        - "output_contains('healthy') OR output_contains('OK')"
      points: 10
```

#### M06-M15 (Similar Pattern)

```yaml
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
    - name: "compile_c_library"
      check: "make -C src/c"
      expect:
        - "file_exists('build/libjobqueue.so')"
      points: 10
      
    - name: "compile_cli_tool"
      check: "make"
      expect:
        - "file_exists('bin/jobctl')"
      points: 5
      
  functional:
    - name: "init_queue"
      check: "./bin/jobctl init"
      expect:
        - "shm_exists('/dev/shm/jobscheduler')"
      points: 5
      
    - name: "submit_job"
      check: "./bin/jobctl submit 'echo test'"
      expect:
        - "output_matches_regex('Job.*#[0-9]+')"
      points: 5
      
    - name: "priority_ordering"
      setup: |
        ./bin/jobctl submit -p 10 'sleep 1'
        ./bin/jobctl submit -p 1 'echo high'
      check: "./bin/jobctl list"
      expect:
        - "high_priority_first()"
      points: 10
      
    - name: "shared_memory_integrity"
      check: "run_concurrent_submits(100)"
      expect:
        - "no_corruption()"
        - "job_count() == 100"
      points: 15
      
  memory:
    - name: "no_memory_leaks"
      check: "valgrind --leak-check=full ./bin/jobctl submit 'test'"
      expect:
        - "output_contains('no leaks')"
      points: 10

a02_shell_extension:
  build:
    - name: "compile_library"
      check: "make"
      expect:
        - "file_exists('build/libshellext.so')"
      points: 10
      
  functional:
    - name: "syntax_highlighting"
      check: |
        echo 'if [ -f test ]; then echo "found"; fi' | ./highlight
      expect:
        - "output_contains_ansi('if')"  # Keyword coloured
        - "output_contains_ansi('echo')" # Builtin coloured
      points: 15
      
    - name: "completion_trie"
      setup: "load_commands_into_trie()"
      check: "./complete 'gre'"
      expect:
        - "output_contains('grep')"
      points: 15
      
    - name: "lexer_correctness"
      check: "./tokenize 'echo $VAR | grep \"test\"'"
      expect:
        - "tokens_include('BUILTIN', 'VARIABLE', 'OPERATOR', 'STRING')"
      points: 10

a03_file_sync:
  build:
    - name: "compile"
      check: "make"
      expect:
        - "file_exists('build/libsyncutil.so')"
        - "file_exists('bin/synctool')"
      points: 10
      
  functional:
    - name: "hash_file"
      setup: "dd if=/dev/urandom of=/tmp/test bs=1M count=10"
      check: "./bin/synctool hash /tmp/test"
      expect:
        - "output_matches_regex('[a-f0-9]{64}')"  # SHA256
      points: 5
      
    - name: "generate_signature"
      check: "./bin/synctool signature /tmp/test"
      expect:
        - "file_exists('/tmp/test.sig')"
      points: 10
      
    - name: "delta_generation"
      setup: |
        cp /tmp/test /tmp/test_modified
        echo "change" >> /tmp/test_modified
      check: "./bin/synctool delta /tmp/test /tmp/test_modified"
      expect:
        - "delta_size() < file_size('/tmp/test_modified')"
      points: 15
      
    - name: "delta_application"
      check: "./bin/synctool apply /tmp/test /tmp/delta -o /tmp/result"
      expect:
        - "files_identical('/tmp/test_modified', '/tmp/result')"
      points: 15
```

---

## 4. Detailed Specifications per Project

### 4.1 Complete Testing Matrix

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

## 5. Criteria NOT EVALUABLE Automatically

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
FULLY AUTOMATIC (100%):
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
- Manual = Human evaluation for:
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

### 6.2 Docker Sandbox

```dockerfile
FROM ubuntu:24.04

RUN apt-get update && apt-get install -y \
    bash \
    coreutils \
    findutils \
    grep \
    sed \
    awk \
    shellcheck \
    sqlite3 \
    inotify-tools \
    netcat-openbsd \
    curl \
    jq \
    gcc \
    make \
    valgrind \
    python3 \
    && rm -rf /var/lib/apt/lists/*

# Resource limits
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

### 6.3 Test Runner Core

```bash
#!/bin/bash
# test_runner.sh

run_test() {
    local test_name="$1"
    local test_command="$2"
    local expected="$3"
    local timeout="${4:-60}"
    local points="${5:-1}"
    
    local start_time result exit_code output
    start_time=$(date +%s.%N)
    
    # Execute in sandbox with timeout
    output=$(timeout "$timeout" bash -c "$test_command" 2>&1)
    exit_code=$?
    
    local end_time duration
    end_time=$(date +%s.%N)
    duration=$(echo "$end_time - $start_time" | bc)
    
    # Evaluate expected
    local passed=false
    if evaluate_expectation "$output" "$exit_code" "$expected"; then
        passed=true
    fi
    
    # Output result
    cat << EOF
{
  "test": "$test_name",
  "passed": $passed,
  "exit_code": $exit_code,
  "duration": $duration,
  "points": $([ "$passed" = "true" ] && echo "$points" || echo "0"),
  "max_points": $points,
  "output_preview": "$(echo "$output" | head -5 | jq -Rs .)"
}
EOF
}

evaluate_expectation() {
    local output="$1"
    local exit_code="$2"
    local expectation="$3"
    
    # Parse expectation (simplified)
    case "$expectation" in
        "exit_code == 0")
            [ "$exit_code" -eq 0 ]
            ;;
        "exit_code != 0")
            [ "$exit_code" -ne 0 ]
            ;;
        output_contains*)
            local pattern="${expectation#*\'}"
            pattern="${pattern%\'*}"
            echo "$output" | grep -q "$pattern"
            ;;
        file_exists*)
            local file="${expectation#*\'}"
            file="${file%\'*}"
            [ -f "$file" ]
            ;;
        *)
            # Complex evaluation with eval
            eval "$expectation"
            ;;
    esac
}
```

### 6.4 Scoring Engine

```python
#!/usr/bin/env python3
# scoring.py

import yaml
import json
from typing import Dict, List

def calculate_score(test_results: List[Dict], project_config: Dict) -> Dict:
    """Calculates the final score for a project."""
    
    total_points = 0
    max_points = 0
    category_scores = {}
    
    for result in test_results:
        category = result.get('category', 'general')
        points = result['points']
        max_pts = result['max_points']
        
        total_points += points
        max_points += max_pts
        
        if category not in category_scores:
            category_scores[category] = {'earned': 0, 'max': 0}
        category_scores[category]['earned'] += points
        category_scores[category]['max'] += max_pts
    
    # Apply weights from config
    weighted_score = 0
    for category, weight in project_config.get('weights', {}).items():
        if category in category_scores:
            cat = category_scores[category]
            if cat['max'] > 0:
                weighted_score += (cat['earned'] / cat['max']) * weight
    
    return {
        'total_points': total_points,
        'max_points': max_points,
        'percentage': (total_points / max_points * 100) if max_points > 0 else 0,
        'weighted_score': weighted_score,
        'category_breakdown': category_scores,
        'grade': calculate_grade(weighted_score)
    }

def calculate_grade(score: float) -> str:
    """Converts score to grade."""
    if score >= 90: return 'A (10)'
    if score >= 80: return 'B (9)'
    if score >= 70: return 'C (8)'
    if score >= 60: return 'D (7)'
    if score >= 50: return 'E (6)'
    if score >= 40: return 'F (5)'
    return 'F (4)'
```

---

## 7. Scoring and Reporting

### 7.1 Scoring Model

```yaml
scoring_model:
  # Points per category
  structural: 10%
  static_analysis: 10%
  functional_core: 40%
  functional_optional: 15%
  error_handling: 10%
  performance: 5%
  documentation: 5%
  code_quality: 5%
  
  # Penalties
  penalties:
    shellcheck_errors: -5% per error (max -20%)
    timeout_exceeded: -50% for that test
    crash: -100% for that test
    hardcoded_paths: -2% per occurrence
    
  # Bonuses
  bonuses:
    all_tests_pass: +5%
    exceptional_error_handling: +5%
    kubernetes_extension: +10%
```

### 7.2 Report Format

```json
{
  "evaluation_id": "eval_20250128_123456",
  "student_id": "student123",
  "project": "M01_Incremental_Backup_System",
  "timestamp": "2025-01-28T12:34:56Z",
  
  "summary": {
    "total_score": 85.5,
    "grade": "B (9)",
    "tests_passed": 18,
    "tests_failed": 2,
    "tests_total": 20
  },
  
  "categories": {
    "structural": {"score": 100, "max": 100, "details": ["..."]},
    "functional": {"score": 82, "max": 100, "details": ["..."]},
    "error_handling": {"score": 75, "max": 100, "details": ["..."]}
  },
  
  "failed_tests": [
    {
      "name": "restore_selective",
      "reason": "File not found in restored location",
      "expected": "file_exists('/tmp/restored/a/f1.txt')",
      "actual": "File does not exist"
    }
  ],
  
  "recommendations": [
    "Implement selective restore from archives",
    "Add validation for restore path"
  ],
  
  "execution_time": "8m 34s",
  "shellcheck_warnings": 3,
  "code_metrics": {
    "total_loc": 456,
    "functions": 23,
    "comment_ratio": 0.12
  }
}
```

### 7.3 Results Dashboard

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                    AUTOMATIC EVALUATION RESULT                               ║
║                    M01: Incremental Backup System                            ║
╚══════════════════════════════════════════════════════════════════════════════╝

TOTAL SCORE: 85.5 / 100  [████████████████████░░░░] 

DETAILS PER CATEGORY
═══════════════════════════════════════════════════════════════════════════════
  Structural      [██████████] 100%   (10/10 pts)
  Static Analysis [████████░░]  80%   (8/10 pts)
  Functional Core [████████░░]  82%   (33/40 pts)
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

FINAL GRADE: 9 (B)
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
