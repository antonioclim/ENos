# MEDIUM Projects (M01-M15)

> **Difficulty:** ⭐⭐⭐ | **Time:** 25-35 hours | **Bonus:** Kubernetes +10%

---

## Overview

Medium projects are recommended for students with moderate Bash experience. They require multiple components, comprehensive error handling, and often involve system-level interactions.

> 💡 **Instructor's note:** This is where most students should aim. The MEDIUM projects teach you patterns you will use throughout your career: monitoring, backup, deployment, security scanning. Choose one that solves a problem you actually have — the motivation will carry you through the debugging sessions.

---

## Project List

| ID | Name | Core Skill | Est. Lines |
|----|------|------------|------------|
| M01 | Incremental Backup System | `tar`, compression, scheduling | 400-600 |
| M02 | Process Lifecycle Monitor | `/proc`, signals, monitoring | 500-700 |
| M03 | Service Health Watchdog | `systemd`, health checks | 350-500 |
| M04 | Network Security Scanner | `netcat`, network basics | 400-550 |
| M05 | Deployment Pipeline | `git` hooks, automation | 450-600 |
| M06 | Resource Usage Historian | `sar`, time-series data | 400-500 |
| M07 | Security Audit Framework | permissions, CVE basics | 500-650 |
| M08 | Disk Storage Manager | LVM concepts, quotas | 450-600 |
| M09 | Scheduled Tasks Manager | `cron`, `at`, systemd timers | 400-550 |
| M10 | Process Tree Analyzer | `ps`, `pstree`, `/proc` | 400-500 |
| M11 | Memory Forensics Tool | `/proc/meminfo`, smaps | 450-550 |
| M12 | File Integrity Monitor | checksums, `inotify` | 450-600 |
| M13 | Log Aggregator | `journalctl`, parsing | 400-550 |
| M14 | Environment Config Manager | dotfiles, templating | 500-650 |
| M15 | Parallel Execution Engine | `xargs`, GNU parallel | 450-600 |

---

## Kubernetes Bonus (+10%)

All MEDIUM projects can earn an additional 10% by adding Kubernetes deployment.

**Requirements:**
- Functional deployment in minikube or similar
- YAML files: Deployment, Service, ConfigMap
- Documentation of K8s setup

See `../KUBERNETES_INTRO.md` for detailed requirements.

> ⚠️ **Fair warning:** The K8s bonus takes 10+ hours to learn if you have never used containers. Only pursue this if you have time to spare.

---

## What You Will Learn

Completing a MEDIUM project will teach you:

- Complex argument parsing and configuration
- Process management and signals
- File system monitoring techniques
- Network programming basics
- Logging and debugging at scale

---

## Getting Started

1. Read your chosen project specification thoroughly
2. Use `../templates/project_structure.sh` to scaffold
3. Plan your modules before coding
4. Write tests alongside your implementation

---

## Common Pitfalls

1. **Scope creep** — Implement requirements first, then add features
2. **Ignoring `/proc`** — It is your friend for process/memory info
3. **Blocking operations** — Use timeouts and background jobs
4. **No logging** — Add logs early; debugging without them is painful

---

*MEDIUM Projects — OS Kit | January 2025*
