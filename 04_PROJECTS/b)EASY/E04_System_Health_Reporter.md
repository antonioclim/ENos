# E04: System Health Reporter

> **Level:** EASY | **Estimated time:** 15-20 hours | **Components:** Bash only

---

## Description

Develop a tool that generates comprehensive reports about system health status: CPU, memory, disk, network, processes and services.

---

## Learning Objectives

- Using system tools (`top`, `free`, `df`, `ps`, `netstat`)
- Parsing `/proc` and `/sys`
- HTML/text report generation
- Thresholds and alerting

---

## Functional Requirements

### Mandatory (for passing grade)

1. **CPU monitoring** - load average, per-core usage, top processes
2. **Memory monitoring** - RAM, swap, cache/buffers
3. **Disk monitoring** - space per partition, I/O stats
4. **Network monitoring** - interfaces, traffic, connections
5. Processes - count, top consumers, zombie processes
6. **Services** - critical services status (configurable)
7. Output - formatted text + optional HTML

### Optional (for full marks)

8. **Alerting** - problem highlighting (red/yellow/green)
9. **History** - comparison with previous runs
10. **Export** - JSON for integration with other tools
11. **Watch mode** - periodic refresh in terminal

---

## Interface

```bash
./health_reporter.sh [OPTIONS]

Options:
  -h, --help              Display help
  -o, --output FILE       Save report
  -f, --format FORMAT     Format: text|html|json
  -s, --services LIST     List of services to check
  -w, --watch SECONDS     Continuous refresh mode
  --cpu-threshold N       CPU alert threshold (default: 80%)
  --mem-threshold N       Memory alert threshold (default: 90%)
  --disk-threshold N      Disk alert threshold (default: 85%)

Examples:
  ./health_reporter.sh
  ./health_reporter.sh -f html -o report.html
  ./health_reporter.sh -w 5 --cpu-threshold 70
  ./health_reporter.sh -s "nginx,mysql,ssh"
```

---

## Output Example

```
╔══════════════════════════════════════════════════════════════════╗
║              SYSTEM HEALTH REPORT                                ║
║  Hostname: webserver01    Date: 2025-01-20 14:30:00             ║
║  Uptime: 45 days, 3:24    Kernel: 5.15.0-generic                ║
╚══════════════════════════════════════════════════════════════════╝

🖥️  CPU STATUS [🟢 OK]
──────────────────────────────────────────────────────────────────
Load Average:    0.45, 0.52, 0.48 (4 cores)
Usage:           12.3% user, 3.2% system, 84.5% idle

Top CPU Consumers:
  PID     USER      CPU%    COMMAND
  1234    www-data  5.2%    /usr/sbin/nginx
  5678    mysql     3.1%    /usr/sbin/mysqld

💾 MEMORY STATUS [🟡 WARNING - 78% used]
──────────────────────────────────────────────────────────────────
RAM:    12.4 GB / 16 GB (78%)  ████████████████░░░░
Swap:   0.2 GB / 4 GB (5%)     █░░░░░░░░░░░░░░░░░░░
Cache:  3.2 GB

💿 DISK STATUS [🟢 OK]
──────────────────────────────────────────────────────────────────
Filesystem      Size    Used    Avail   Use%    Mounted on
/dev/sda1       100G    45G     55G     45%     /
/dev/sdb1       500G    234G    266G    47%     /data

🌐 NETWORK STATUS [🟢 OK]
──────────────────────────────────────────────────────────────────
Interface   IP              RX          TX          Status
eth0        192.168.1.10    1.2 GB      890 MB      UP
lo          127.0.0.1       45 MB       45 MB       UP

Active connections: 234 (ESTABLISHED: 45, TIME_WAIT: 189)

⚙️  SERVICES STATUS
──────────────────────────────────────────────────────────────────
Service      Status      PID       Memory    CPU
nginx        🟢 running  1234      45 MB     2.1%
mysql        🟢 running  5678      512 MB    5.3%
ssh          🟢 running  890       12 MB     0.1%
redis        🔴 stopped  -         -         -

📊 OVERALL HEALTH: 🟡 WARNING
──────────────────────────────────────────────────────────────────
[!] Memory usage above 75% - consider optimisation
[!] Service 'redis' is not running
```

---

## Recommended Structure

```
E04_System_Health_Reporter/
├── src/
│   ├── health_reporter.sh
│   └── lib/
│       ├── cpu.sh
│       ├── memory.sh
│       ├── disk.sh
│       ├── network.sh
│       ├── services.sh
│       └── report.sh
├── etc/
│   ├── services.conf       # services to monitor
│   └── thresholds.conf     # alert thresholds
├── templates/
│   └── report.html         # HTML template
└── tests/
```

---

## Evaluation Criteria

| Criterion | Weight |
|-----------|--------|
| CPU monitoring | 15% |
| Memory monitoring | 15% |
| Disk monitoring | 10% |
| Network monitoring | 10% |
| Services status | 10% |
| Alerting with colours | 10% |
| Code quality | 15% |
| Tests | 10% |
| Documentation | 5% |

---

*EASY Project | Operating Systems | ASE-CSIE*
