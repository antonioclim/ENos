# M06: Resource Usage Historian

> **Level:** MEDIUM | **Estimated time:** 25-35 hours | **K8s Bonus:** +10%

---

## Description

System for collecting, storing and historical analysis of resource usage (CPU, RAM, disk, network). Includes terminal visualisation with ASCII graphs, anomaly detection and trend prediction for capacity planning.

---

## Learning Objectives

- System metrics collection (`/proc`, `vmstat`, `iostat`)
- Time-series data storage (SQLite or structured text)
- Data visualisation in terminal (ASCII graphs)
- Basic statistical analysis (mean, std dev, trend)
- Alerting based on thresholds and anomalies

---

## Functional Requirements

### Mandatory (for passing grade)

1. **Metrics collection**
   - CPU: per-core usage, load average
   - Memory: used, free, cached, swap
   - Disk: per-partition usage, I/O wait
   - Network: bytes in/out per interface

2. **Data storage**
   - Format: SQLite or CSV with timestamp
   - Rotation: configurable retention (7/30/90 days)
   - Compression for old data

3. **Terminal visualisation**
   - ASCII graphs for each metric
   - Selectable period (hour/day/week/month)
   - Comparison between periods

4. **Reports**
   - Daily/weekly/monthly summaries
   - CSV export for external analysis
   - Top consumers (processes)

5. **Daemon mode**
   - Collection at configurable interval
   - Start/stop/status
   - Minimal overhead

### Optional (for full marks)

6. **Trend analysis** - Future usage prediction
7. **Anomaly detection** - Alert on unusual values
8. **Process tracking** - Per-process usage history
9. **Alerting** - Email/webhook at threshold
10. **Web dashboard** - Simple HTTP server with graphs

---

## CLI Interface

```bash
./historian.sh <command> [options]

Commands:
  start                 Start collection (daemon)
  stop                  Stop the daemon
  status                Daemon status and latest values
  collect               One-shot collection
  show <metric>         Display graph for metric
  report [period]       Generate report (hour|day|week|month)
  export <file>         Export data to CSV
  query <sql>           Direct query on database
  cleanup               Delete old data

Available metrics:
  cpu                   CPU usage (total and per core)
  memory                Memory usage
  disk                  Disk usage and I/O
  network               Network traffic
  load                  Load average
  all                   All metrics

Options:
  -p, --period PERIOD   Period: 1h|6h|24h|7d|30d (default: 24h)
  -i, --interval SEC    Collection interval (default: 60)
  -f, --format FMT      Output format: ascii|json|csv
  -w, --width N         Graph width (default: 80)
  --no-color            No colours
  --threshold PCT       Alert above this percentage

Examples:
  ./historian.sh start -i 30
  ./historian.sh show cpu -p 7d
  ./historian.sh show memory --width 120
  ./historian.sh report week -f csv > report.csv
  ./historian.sh query "SELECT * FROM metrics WHERE cpu > 90"
```

---

## Output Examples

### Real-time Dashboard

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                    RESOURCE USAGE HISTORIAN                                  ║
║                    Host: server01 | Uptime: 45d 12h                         ║
╚══════════════════════════════════════════════════════════════════════════════╝

┌─ CPU Usage (last 24h) ───────────────────────────────────────────────────────┐
│ 100%│                              ▄▄                                        │
│  80%│                    ▄▄       ████                                       │
│  60%│        ▄▄         ████     ██████    ▄▄                               │
│  40%│       ████   ▄▄  ██████   ████████  ████                              │
│  20%│▄▄▄▄▄▄██████▄████▄████████▄██████████████▄▄▄▄▄▄▄▄▄▄▄▄                  │
│   0%└────────────────────────────────────────────────────────────────────────│
│     00:00    04:00    08:00    12:00    16:00    20:00    now                │
│     Min: 12%  Max: 87%  Avg: 34%  Current: 23%                              │
└──────────────────────────────────────────────────────────────────────────────┘

┌─ Memory Usage (last 24h) ────────────────────────────────────────────────────┐
│ 16G │████████████████████████████████████████████████████████████████       │
│ 12G │████████████████████████████████████████████████████████▓▓▓▓▓▓▓▓       │
│  8G │██████████████████████████████████████▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓░░░░░░░░░       │
│  4G │████████████████▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓░░░░░░░░░░░░░░░░░░░░░░░░░       │
│  0G └────────────────────────────────────────────────────────────────────────│
│     ████ Used (8.2G)  ▓▓▓▓ Cached (4.1G)  ░░░░ Free (3.7G)                  │
└──────────────────────────────────────────────────────────────────────────────┘

┌─ Disk I/O (last 24h) ────────────────────────────────────────────────────────┐
│ Read:  ▁▂▃▄▅▆▇█▇▆▅▄▃▂▁▁▂▃▄▅▆▇████▇▆▅▄▃▂▁▁▂▃▄▅▆▇█▇▆▅▄▃▂▁▁▂▃▄▅▆▇█            │
│ Write: ▁▁▂▃▄▅▆▇█▇▆▅▄▃▂▁▁▁▂▃▄▅▆████████▇▆▅▄▃▂▁▁▂▃▄▅▆▇█▇▆▅▄▃▂▁▁▂▃            │
│ Peak read: 450 MB/s at 14:30  |  Peak write: 320 MB/s at 15:45              │
└──────────────────────────────────────────────────────────────────────────────┘

┌─ Network Traffic (last 24h) ─────────────────────────────────────────────────┐
│ eth0 IN:  ▂▃▄▅▆▇████▇▆▅▄▃▂▂▃▄▅▆▇████▇▆▅▄▃▂▂▃▄▅▆▇████▇▆▅▄▃▂                  │
│ eth0 OUT: ▁▂▃▄▅▆▇██▇▆▅▄▃▂▁▁▂▃▄▅▆▇██▇▆▅▄▃▂▁▁▂▃▄▅▆▇██▇▆▅▄▃▂▁                  │
│ Total: IN 45.2 GB  OUT 12.8 GB                                              │
└──────────────────────────────────────────────────────────────────────────────┘

Last update: 2025-01-20 15:30:45 | Collecting every 60s | Data: 892 MB
```

### Weekly Report

```
═══════════════════════════════════════════════════════════════════════════════
                         WEEKLY RESOURCE REPORT
                         2025-01-13 to 2025-01-20
═══════════════════════════════════════════════════════════════════════════════

CPU USAGE
─────────────────────────────────────────────────────────────────────────────
        Mon     Tue     Wed     Thu     Fri     Sat     Sun     Avg
Avg:    34%     42%     38%     67%     45%     22%     18%     38%
Max:    78%     89%     72%     95%     82%     45%     34%     95%
Min:    12%     15%     14%     23%     18%      8%      6%      6%

⚠️  Thursday 14:00-16:00: Sustained high CPU (>90%) - investigate batch jobs

MEMORY USAGE
─────────────────────────────────────────────────────────────────────────────
Average: 52% (8.3 GB / 16 GB)
Peak:    78% at Thu 15:30 (12.5 GB)
Swap:    0 MB used (healthy)

DISK USAGE
─────────────────────────────────────────────────────────────────────────────
/         45% used (89 GB / 200 GB)  +2.3 GB this week
/home     67% used (134 GB / 200 GB) +8.1 GB this week
/var/log  23% used (4.6 GB / 20 GB)  +1.2 GB this week

⚠️  /home growing 8 GB/week - will be full in ~8 weeks

NETWORK
─────────────────────────────────────────────────────────────────────────────
Total IN:   312 GB
Total OUT:  89 GB
Peak rate:  890 Mbps (Fri 10:30)

TOP PROCESSES (by average CPU)
─────────────────────────────────────────────────────────────────────────────
1. postgres       23% CPU,  2.1 GB RAM
2. nginx          12% CPU,  450 MB RAM
3. node (myapp)    8% CPU,  890 MB RAM
4. redis           3% CPU,  1.2 GB RAM

═══════════════════════════════════════════════════════════════════════════════
```

---

## Database Schema (SQLite)

```sql
-- Main metrics table
CREATE TABLE metrics (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    cpu_percent REAL,
    cpu_user REAL,
    cpu_system REAL,
    cpu_iowait REAL,
    load_1m REAL,
    load_5m REAL,
    load_15m REAL,
    mem_total INTEGER,
    mem_used INTEGER,
    mem_free INTEGER,
    mem_cached INTEGER,
    swap_used INTEGER,
    disk_read_bytes INTEGER,
    disk_write_bytes INTEGER,
    net_rx_bytes INTEGER,
    net_tx_bytes INTEGER
);

-- Index for fast queries
CREATE INDEX idx_metrics_timestamp ON metrics(timestamp);

-- Table for generated alerts
CREATE TABLE alerts (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    metric TEXT,
    value REAL,
    threshold REAL,
    message TEXT
);
```

---

## Project Structure

```
M06_Resource_Usage_Historian/
├── README.md
├── Makefile
├── src/
│   ├── historian.sh             # Main script
│   └── lib/
│       ├── collect.sh           # Metrics collection
│       ├── storage.sh           # DB interaction
│       ├── graph.sh             # ASCII graphs
│       ├── report.sh            # Report generation
│       ├── alert.sh             # Alerting system
│       └── daemon.sh            # Daemon functions
├── etc/
│   ├── historian.conf
│   └── thresholds.conf
├── sql/
│   ├── schema.sql
│   └── queries/
│       ├── daily_summary.sql
│       └── weekly_report.sql
├── tests/
│   ├── test_collect.sh
│   ├── test_graph.sh
│   └── sample_data.sql
└── docs/
    ├── INSTALL.md
    └── METRICS.md
```

---

## Implementation Hints

### CPU metrics collection

```bash
get_cpu_usage() {
    # Method 1: from /proc/stat
    local cpu_line
    cpu_line=$(head -1 /proc/stat)
    
    read -r _ user nice system idle iowait irq softirq <<< "$cpu_line"
    
    local total=$((user + nice + system + idle + iowait + irq + softirq))
    local used=$((total - idle - iowait))
    
    echo "scale=2; $used * 100 / $total" | bc
    
    # Method 2: top one-shot
    # top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8}'
}

get_load_average() {
    cat /proc/loadavg | awk '{print $1, $2, $3}'
}
```

### Memory metrics collection

```bash
get_memory_stats() {
    local meminfo="/proc/meminfo"
    
    local total=$(awk '/MemTotal/ {print $2}' "$meminfo")
    local free=$(awk '/MemFree/ {print $2}' "$meminfo")
    local buffers=$(awk '/Buffers/ {print $2}' "$meminfo")
    local cached=$(awk '/^Cached/ {print $2}' "$meminfo")
    local swap_total=$(awk '/SwapTotal/ {print $2}' "$meminfo")
    local swap_free=$(awk '/SwapFree/ {print $2}' "$meminfo")
    
    local used=$((total - free - buffers - cached))
    local swap_used=$((swap_total - swap_free))
    
    echo "$total $used $free $cached $swap_used"
}
```

### Simple ASCII graph

```bash
draw_ascii_graph() {
    local -a values=("$@")
    local max_height=10
    local width=${#values[@]}
    
    # Find max for scaling
    local max=0
    for v in "${values[@]}"; do
        ((v > max)) && max=$v
    done
    
    # Draw from top to bottom
    for ((row = max_height; row >= 1; row--)); do
        local threshold=$((max * row / max_height))
        printf "%3d%% │" "$((row * 100 / max_height))"
        
        for v in "${values[@]}"; do
            if ((v >= threshold)); then
                printf "█"
            else
                printf " "
            fi
        done
        echo
    done
    
    # X axis
    printf "     └"
    printf '─%.0s' $(seq 1 "$width")
    echo
}
```

### SQLite storage

```bash
init_database() {
    local db="$1"
    sqlite3 "$db" << 'SQL'
CREATE TABLE IF NOT EXISTS metrics (
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    cpu_percent REAL,
    mem_used_kb INTEGER,
    disk_read_kb INTEGER,
    disk_write_kb INTEGER,
    net_rx_kb INTEGER,
    net_tx_kb INTEGER
);
CREATE INDEX IF NOT EXISTS idx_ts ON metrics(timestamp);
SQL
}

store_metrics() {
    local db="$1"
    local cpu="$2" mem="$3" disk_r="$4" disk_w="$5" net_rx="$6" net_tx="$7"
    
    sqlite3 "$db" "INSERT INTO metrics (cpu_percent, mem_used_kb, disk_read_kb, disk_write_kb, net_rx_kb, net_tx_kb) VALUES ($cpu, $mem, $disk_r, $disk_w, $net_rx, $net_tx);"
}

query_metrics() {
    local db="$1"
    local period="$2"  # e.g.: "-24 hours"
    
    sqlite3 -separator ',' "$db" \
        "SELECT strftime('%H:%M', timestamp), cpu_percent, mem_used_kb 
         FROM metrics 
         WHERE timestamp > datetime('now', '$period')
         ORDER BY timestamp;"
}
```

---

## Specific Evaluation Criteria

| Criterion | Weight | Description |
|-----------|--------|-------------|
| Metrics collection | 20% | CPU, RAM, disk, network - correct data |
| Data storage | 15% | SQLite/CSV, rotation, integrity |
| ASCII graphs | 20% | Clear visualisation, correct scaling |
| Reports | 15% | Daily/weekly, CSV export |
| Daemon mode | 10% | Start/stop, configurable interval |
| Extra features | 10% | Trend, anomaly detection |
| Code quality + tests | 5% | ShellCheck, unit tests |
| Documentation | 5% | README, metrics doc |

---

## Resources

- `/proc` filesystem documentation
- `man vmstat`, `man iostat`, `man sar`
- SQLite documentation
- Seminar 3-4 - Processes, text processing

---

*MEDIUM Project | Operating Systems | ASE-CSIE*
