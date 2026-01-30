# Main Material — CAPSTONE SEM06

> **Operating Systems** | ASE Bucharest - CSIE  
> Seminar 6: Integrated Projects (Monitor, Backup, Deployer)

---

## About This Document

CAPSTONE differs from previous seminars. Instead of a single linear topic, you're building *systems*. This document serves as your navigation hub.

> **Lab note:** Don't read everything before starting. Skim the architecture overview, pick your project, then dive into that specific documentation. You can always circle back.

---

## 1. Project Overview

### 1.1 The Three Projects

| Project | What It Does | Difficulty | Start Here |
|---------|--------------|------------|------------|
| **Monitor** | Real-time system metrics (CPU, memory, disk) with alerting | ⭐⭐⭐ | [Monitor Implementation](projects/S06_P02_Monitor_Implementation.md) |
| **Backup** | Incremental backup with compression, verification, rotation | ⭐⭐⭐ | [Backup Implementation](projects/S06_P03_Backup_Implementation.md) |
| **Deployer** | Automated deployment with rollback and health checks | ⭐⭐⭐⭐ | [Deployer Implementation](projects/S06_P04_Deployer_Implementation.md) |
| **Integrated** | All three working together | ⭐⭐⭐⭐⭐ | Complete individual projects first |

### 1.2 Which Project Should I Choose?

**Choose Monitor if:**
- You want to understand how Linux exposes system information
- You're comfortable with arithmetic in Bash
- You like building dashboards

**Choose Backup if:**
- You care about data integrity
- You want to learn tar, compression, checksums
- You appreciate the "boring but critical" infrastructure

**Choose Deployer if:**
- You're interested in DevOps/CI-CD
- You want the hardest challenge
- You're comfortable with service management concepts

> **Quick win:** If unsure, start with Monitor. It has the fastest feedback loop — you see results immediately.

---

## 2. Shared Architecture

All three projects share a common structure. Learn it once, apply it everywhere.

### 2.1 Directory Layout

```
project/
├── project.sh              # Entry point — this is what you run
├── lib/
│   ├── core.sh             # Logging, error handling, fundamentals
│   ├── config.sh           # Configuration loading and validation
│   └── utils.sh            # Project-specific helper functions
├── etc/
│   └── project.conf        # Configuration file
├── var/
│   ├── log/                # Log output goes here
│   └── run/                # PID files, lock files
└── tests/
    └── test_project.sh     # Your tests
```

### 2.2 Why This Structure?

This mirrors real Unix conventions:
- `/etc` for configuration
- `/var` for runtime data
- `/lib` for shared code

When you deploy to a real server someday, this structure will feel familiar.

**Full architecture details:** [Project Architecture](projects/S06_P01_Project_Architecture.md)

---

## 3. Core Concepts

These apply to *all* projects. Master them before diving into specifics.

### 3.1 Error Handling

Your scripts *will* fail. The question is: do they fail gracefully?

> ⚠️ *Confession: In my early sysadmin days, I once wrote a cleanup script without `set -e` that silently failed halfway through and deleted the wrong directory. Cost me a weekend. The "holy trinity" below is non-negotiable in production scripts.*

```bash
set -euo pipefail  # The holy trinity

cleanup() {
    # Always runs, even on Ctrl+C
    rm -f "$TEMP_FILE"
}
trap cleanup EXIT
```

**Deep dive:** [Error Handling](projects/S06_P06_Error_Handling.md)

### 3.2 Logging

`echo` is not logging. Logging has timestamps, levels and destinations.

```bash
log_info "Starting backup"
log_warn "Disk space below 10%"
log_error "Cannot connect to server"
```

**Deep dive:** [Error Handling](projects/S06_P06_Error_Handling.md) (logging section)

### 3.3 Testing

If you can't test it, you can't trust it.

```bash
test_cpu_usage_returns_number() {
    local result
    result=$(get_cpu_usage)
    [[ "$result" =~ ^[0-9]+$ ]] || fail "Expected number, got: $result"
}
```

**Deep dive:** [Testing Framework](projects/S06_P05_Testing_Framework.md)

---

## 4. Project-Specific Documentation

### 4.1 Introduction and Context

- [Introduction to CAPSTONE](projects/S06_P00_Introduction_CAPSTONE.md) — Why we're doing this, what you'll learn

### 4.2 Architecture

- [Project Architecture](projects/S06_P01_Project_Architecture.md) — Shared patterns, directory structure, execution flow

### 4.3 Implementation Guides

| Document | Covers |
|----------|--------|
| [Monitor Implementation](projects/S06_P02_Monitor_Implementation.md) | /proc parsing, metrics collection, alerting |
| [Backup Implementation](projects/S06_P03_Backup_Implementation.md) | tar, find -newer, checksums, rotation |
| [Deployer Implementation](projects/S06_P04_Deployer_Implementation.md) | Deployment strategies, health checks, rollback |

### 4.4 Cross-Cutting Concerns

| Document | Covers |
|----------|--------|
| [Testing Framework](projects/S06_P05_Testing_Framework.md) | Unit tests, integration tests, test runner |
| [Error Handling](projects/S06_P06_Error_Handling.md) | Exit codes, traps, logging system |
| [Deployment Strategies](projects/S06_P07_Deployment_Strategies.md) | Rolling, blue-green, canary patterns |
| [Cron and Automation](projects/S06_P08_Cron_Automation.md) | Scheduling with cron, systemd timers |

---

## 5. Quick Reference

### 5.1 Cheat Sheet

One-page reference for common patterns: [Bash Cheat Sheet](S06_09_VISUAL_CHEAT_SHEET.md)

### 5.2 Self-Assessment

Check your understanding: [Self-Assessment](S06_10_SELF_ASSESSMENT_REFLECTION.md)

---

## 6. Working Code

The `scripts/projects/` directory contains working implementations:

```
scripts/projects/
├── monitor/
│   ├── monitor.sh
│   ├── lib/
│   └── tests/
├── backup/
│   ├── backup.sh
│   ├── lib/
│   └── tests/
└── deployer/
    ├── deployer.sh
    ├── lib/
    └── tests/
```

> **Warning:** Don't just copy this code for your homework. The point is to *understand* it. The rubric rewards explanation, not just execution.

---

## 7. Suggested Learning Path

### Week 1: Foundation

1. Read [Project Architecture](projects/S06_P01_Project_Architecture.md)
2. Run the existing code, break it, fix it
3. Complete Sprint exercises 1-3
4. Start your chosen project skeleton

### Week 2: Implementation

1. Read your project's implementation guide
2. Implement core functionality
3. Add error handling and logging
4. Write basic tests

### Week 3: Polish (Individual)

1. Complete bonus features
2. Write documentation
3. Prepare presentation demo
4. Test on clean machine

---

## 8. Getting Help

**Stuck?** Try in this order:

1. Re-read the error message. Bash errors are cryptic but informative.
2. Add `set -x` to see what's actually executing.
3. Check ShellCheck: `shellcheck your_script.sh`
4. Search the man pages: `man bash`, `man find`, `man tar`
5. Ask a classmate (pair debugging works)
6. Ask the instructor (with your error message and what you tried)

> **Lab note:** "It doesn't work" is not a question. "I expected X, got Y, here's my code" is a question I can answer.

---

*Main Material Index for SEM06 CAPSTONE — Operating Systems*  
*ASE Bucharest - CSIE | 2024-2025*
