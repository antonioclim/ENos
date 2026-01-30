# S06_01 - CAPSTONE Assignment: Integrated Projects

> **Operating Systems** | ASE Bucharest - CSIE  
> **Seminar 6** | Level: CAPSTONE  
> **Estimated time**: 40-60 hours total  
> **Submission**: GitHub/GitLab Repository + Demonstration

---

## Table of Contents

1. [Assignment 1: Monitor - Feature Extension](#assignment-1-monitor)
2. [Assignment 2: Backup - Complete System](#assignment-2-backup)
3. [Assignment 3: Deployer - CI/CD Pipeline](#assignment-3-deployer)
4. [Assignment 4: Integrated Project](#assignment-4-integrated-project)
5. [Evaluation Criteria](#evaluation-criteria)
6. [Anti-Plagiarism Verification](#anti-plagiarism-verification)

---

## Assignment 1: Monitor - Feature Extension {#assignment-1-monitor}

### Objective
Extend the Monitor project with new advanced monitoring features.

### Mandatory Requirements (60%)

#### 1.1 Network Monitoring (20%)
Implement network traffic monitoring.

```bash
# Function should return:
# - Bytes received/transmitted per interface
# - Dropped packets
# - Network errors

get_network_stats() {
    local interface="${1:-eth0}"
    
    # TODO: Read from /proc/net/dev or /sys/class/net/
    # TODO: Calculate rate (bytes/sec) between two readings
    # TODO: Return in structured format
}

# Expected output:
# interface:eth0
# rx_bytes:1234567890
# tx_bytes:987654321
# rx_packets:12345
# tx_packets:9876
# rx_errors:0
# tx_errors:0
# rx_rate_mbps:45.2
# tx_rate_mbps:12.8
```

**Hints:**
- `/proc/net/dev` contains statistics per interface
- For rates, take two readings at 1 second interval
- Convert bytes to Mbps: `(bytes_diff * 8) / 1000000`

#### 1.2 Service Monitoring (20%)
Implement systemd service monitoring.

```bash
check_service_status() {
    local service="$1"
    
    # TODO: Check if service is running
    # TODO: Get memory/CPU usage of service
    # TODO: Check uptime
    
    # Return: running|stopped|failed + metrics
}

monitor_services() {
    local services=("$@")
    
    # TODO: Iterate through service list
    # TODO: Generate status report
}

# Example usage:
# monitor_services nginx mysql redis
```

**Hints:**
- `systemctl is-active servicename`
- `systemctl show servicename --property=MainPID,MemoryCurrent`
- Handle case when service doesn't exist

#### 1.3 Terminal Dashboard (20%)
Create a live terminal dashboard using ANSI escape codes.

```bash
render_dashboard() {
    # Clear screen and position cursor
    clear
    tput cup 0 0
    
    # TODO: Display header with hostname and timestamp
    # TODO: CPU section with progress bar
    # TODO: Memory section with graph
    # TODO: Disk usage section
    # TODO: Top 5 processes
    # TODO: Monitored services status
    
    # Refresh every 2 seconds
}

# Example progress bar:
# CPU: [████████████░░░░░░░░] 62%
```

**Hints:**
- ANSI codes: `\033[32m` for green, `\033[0m` for reset
- `printf` for precise formatting
- `tput` for terminal manipulation

### Optional Requirements (40% bonus)

#### 1.4 Prometheus Export (15%)
Implement HTTP endpoint for metrics in Prometheus format.

```bash
start_prometheus_exporter() {
    local port="${1:-9100}"
    
    # TODO: Simple HTTP server with netcat
    # TODO: /metrics endpoint with Prometheus format
}

# Prometheus format:
# # HELP node_cpu_usage CPU usage percentage
# # TYPE node_cpu_usage gauge
# node_cpu_usage{core="0"} 23.5
# node_cpu_usage{core="1"} 45.2
```

#### 1.5 Historical Data & Graphs (15%)
Store metrics and generate ASCII graphs.

```bash
# Storage in SQLite or CSV
store_metric() {
    local metric="$1"
    local value="$2"
    local timestamp=$(date +%s)
    
    # TODO: Append to history file
}

# ASCII graph for last N values
draw_ascii_graph() {
    local metric="$1"
    local points="${2:-60}"  # last 60 minutes
    
    # TODO: Read data from history
    # TODO: Normalise to terminal height
    # TODO: Draw graph
}
```

#### 1.6 Email/Slack Alerting (10%)
Implement notifications via email or Slack.

---

## Assignment 2: Backup - Complete System {#assignment-2-backup}

### Objective
Extend the backup system with enterprise features.

### Mandatory Requirements (60%)

#### 2.1 Encrypted Backup (20%)
Add GPG encryption support.

```bash
create_encrypted_backup() {
    local source="$1"
    local dest="$2"
    local gpg_recipient="$3"
    
    # TODO: Create archive
    # TODO: Encrypt with GPG
    # TODO: Digital signature (optional)
    # TODO: Verify integrity post-encryption
}

restore_encrypted_backup() {
    local archive="$1"
    local dest="$2"
    
    # TODO: Verify signature
    # TODO: Decrypt
    # TODO: Extract
    # TODO: Verify file integrity
}
```

**Hints:**
- `gpg --encrypt --recipient user@email.com`
- `gpg --decrypt`
- Test with locally generated GPG keys

#### 2.2 Remote Backup SSH/SFTP (20%)
Implement backup to remote server.

```bash
backup_to_remote() {
    local source="$1"
    local remote_host="$2"
    local remote_path="$3"
    
    # TODO: Verify SSH connectivity
    # TODO: Transfer with rsync or scp
    # TODO: Verify complete transfer
    # TODO: Retry on network errors
}

# rsync variant (recommended)
rsync_backup() {
    rsync -avz --progress \
        --exclude-from="$EXCLUDE_FILE" \
        --partial \
        --bwlimit="${BANDWIDTH_LIMIT:-0}" \
        "$source" "${remote_host}:${remote_path}"
}
```

**Hints:**
- Configure SSH keys for passwordless authentication
- `rsync --partial` for resuming interrupted transfers
- `--bwlimit` for bandwidth limiting (KB/s)

#### 2.3 Advanced Rotation (20%)
Implement configurable retention policy.

```bash
# Config: retention.conf
# daily=7
# weekly=4
# monthly=12
# yearly=2

apply_retention_policy() {
    local backup_dir="$1"
    local config_file="$2"
    
    # TODO: Parse configuration
    # TODO: Identify backups for deletion
    # TODO: Keep backups according to policy
    # TODO: Logging and freed space reporting
}

# Should keep:
# - Last 7 daily
# - One backup from each of last 4 weeks
# - One backup from each of last 12 months
# - One backup from last 2 years
```

### Optional Requirements (40% bonus)

#### 2.4 Deduplication (15%)
Implement block-level deduplication.

#### 2.5 Database Backup (15%)
Add MySQL/PostgreSQL backup support.

#### 2.6 HTML Report (10%)
Generate HTML report with backup statistics.

---

## Assignment 3: Deployer - CI/CD Pipeline {#assignment-3-deployer}

### Objective
Build a complete deployment pipeline.

### Mandatory Requirements (60%)

#### 3.1 Docker Deployment (20%)
Implement deployment for Docker containers.

```bash
deploy_docker_app() {
    local image="$1"
    local container_name="$2"
    local port="${3:-8080}"
    
    # TODO: Pull new image
    # TODO: Stop existing container (graceful)
    # TODO: Backup container data (volumes)
    # TODO: Start new container
    # TODO: Health check
    # TODO: Cleanup old images
}
```

**Hints:**
- `docker pull`, `docker stop`, `docker run`
- `--stop-timeout` for graceful shutdown
- Health check: `docker inspect --format='{{.State.Health.Status}}'`

#### 3.2 Multi-Environment Pipeline (20%)
Implement deployment to staging then production.

```bash
deploy_pipeline() {
    local app="$1"
    local version="$2"
    
    # 1. Build & Test
    log_info "Building $app v$version..."
    run_build "$app" "$version" || return 1
    run_unit_tests "$app" || return 1
    
    # 2. Deploy to Staging
    log_info "Deploying to STAGING..."
    ENVIRONMENT="staging" deploy_to_environment "$app" "$version"
    
    # 3. Integration Tests
    run_integration_tests "$app" "staging" || {
        rollback_environment "staging" "$app"
        return 1
    }
    
    # 4. Approval Gate
    if [[ "$REQUIRE_APPROVAL" == "true" ]]; then
        request_approval "Deploy $app v$version to production?"
    fi
    
    # 5. Deploy to Production (canary)
    log_info "Deploying to PRODUCTION..."
    ENVIRONMENT="production" deploy_canary "$app" "$version"
}
```

#### 3.3 Monitoring Integration (20%)
Integrate deployment with monitoring system.

### Optional Requirements (40% bonus)

#### 3.4 GitOps Integration (15%)
Implement deployment triggered by Git.

#### 3.5 Kubernetes Deployment (15%)
Add Kubernetes deployment support.

#### 3.6 Secrets Management (10%)
Implement secure secrets management.

---

## Assignment 4: Integrated Project {#assignment-4-integrated-project}

### Objective
Integrate all three projects into a coherent system.

### Requirements (100%)

#### 4.1 Unified CLI (30%)
Create a unified interface for all projects.

```bash
#!/bin/bash
# capstone.sh - Unified CLI

case "$1" in
    monitor)
        shift
        ./monitor/monitor.sh "$@"
        ;;
    backup)
        shift
        ./backup/backup.sh "$@"
        ;;
    deploy)
        shift
        ./deployer/deployer.sh "$@"
        ;;
    status)
        show_system_status
        ;;
    *)
        show_help
        ;;
esac
```

#### 4.2 Automated Workflows (30%)
Implement automated workflows combining all projects.

#### 4.3 Web Dashboard (20%)
Create a simple web dashboard for status visualisation.

#### 4.4 Documentation & Tests (20%)
- Complete README with installation and usage instructions
- Minimum 10 unit tests for each project
- Usage examples for each feature
- Consult `man` or `--help` if in doubt

---

## Evaluation Criteria {#evaluation-criteria}

### General Scoring

| Criterion | Weight | Description |
|-----------|--------|-------------|
| Functionality | 40% | Code works according to requirements |
| Code Quality | 25% | Clean code, modularisation, comments |
| Error Handling | 15% | Error management, edge cases |
| Testing | 10% | Unit and integration tests |
| Documentation | 10% | README, help, comments |

### Penalties

| Penalty | Points | Reason |
|---------|--------|--------|
| Unformatted code | -5 | Missing indentation, inconsistent style |
| No input validation | -10 | Script crashes on invalid input |
| No error handling | -10 | Unhandled errors |
| No comments | -5 | Hard to understand code |
| Plagiarism | -100 | Copying without attribution |

### Bonuses

| Bonus | Points | Condition |
|-------|--------|-----------|
| Extra features | +10 | Features beyond requirements |
| Excellent docs | +5 | Exemplary documentation |
| CI/CD Pipeline | +10 | Working GitHub Actions |
| Tests >80% coverage | +10 | High test coverage |

---

## Anti-Plagiarism Verification {#anti-plagiarism-verification}

### Mandatory Live Demonstration (20% of final grade)

Each student must demonstrate their project LIVE during the seminar session. I've seen too many "perfect" submissions that students couldn't explain. Don't be that person.

#### 1. Code Walkthrough (5 minutes)

You'll explain your design decisions to the instructor:
- Why did you structure it this way?
- What alternatives did you consider?
- Where did you struggle most?

#### 2. Live Modification (5 minutes)

The instructor will request ONE of these changes, and you'll implement it on the spot with screen sharing:
- Add a new threshold (e.g., swap > 80%)
- Change output format (text → JSON)
- Add a new metric (network bytes/sec)
- Modify rotation policy

You have 5 minutes. Partial solutions count.

#### 3. Debug Challenge (5 minutes)

The instructor introduces a bug into your code. You must:
- Identify the bug using `set -x` or `strace`
- Explain what went wrong
- Fix it

### Verification Signals

What we look for to distinguish authentic work:

| Signal | Authentic Work | Suspicious |
|--------|----------------|------------|
| Variable names | Match your coding style | Generic: `data`, `result`, `temp` |
| Comments | Sparse, personal notes | Overly explanatory, tutorial-style |
| Error messages | Custom, sometimes rough | Polished, professional |
| Git history | Many small commits | Few large commits |
| Response to questions | Immediate, natural | Hesitant, vague |
| Code navigation | Knows where everything is | Searches own code |

### Signature Script Requirement

Your submission MUST include a `signature.sh` that generates unique system fingerprints. See Exercise 8 in LLM-Aware Exercises for details.

Run it three times at 1-minute intervals and include output in your submission. This proves YOU ran the code on YOUR machine.

---

## Deadlines

- **Assignment 1 (Monitor)**: Week 12
- **Assignment 2 (Backup)**: Week 13
- **Assignment 3 (Deployer)**: Week 14
- **Assignment 4 (Integrated)**: Exam Session

## Submission

1. GitHub/GitLab repository
2. README with instructions
3. Working installation script
4. signature.txt with three consecutive outputs
5. Video demonstration (2-3 minutes) - optional for bonus

---

## Tips

1. **Start early** - These assignments require time for testing
2. **Test incrementally** - Don't leave testing until the end
3. **Use Git** - Frequent commits, clear messages
4. **Read the documentation** - `man bash`, `man rsync`, etc.
5. **Ask for help** - Consultations, forum, colleagues
6. **Write code YOU understand** - You'll need to explain it live

---

*Material for Operating Systems course | ASE Bucharest - CSIE*
