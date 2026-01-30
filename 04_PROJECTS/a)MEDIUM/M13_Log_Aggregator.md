# M13: Log Aggregator

> **Level:** MEDIUM | **Estimated time:** 25-35 hours | **K8s Bonus:** +10%

---

## Description

Centralised log aggregation, parsing and analysis system from multiple sources: local files, syslog, journald and applications. Includes advanced filtering, pattern-based alerting and dashboard for visualisation.

---

## Learning Objectives

- Log formats (syslog, JSON, Apache, nginx)
- Log parsing and normalisation
- Streaming and real-time processing
- Pattern matching and alerting
- Efficient indexing and searching

---

## Functional Requirements

### Mandatory (for passing grade)

1. **Log collection**
   - From files (tail -f style)
   - From journald (journalctl)
   - From syslog (socket or file)
   - Multiple sources simultaneously

2. **Parsing and normalisation**
   - Auto-detect format (syslog, JSON, Apache, nginx)
   - Field extraction (timestamp, level, source, message)
   - Timestamp normalisation to common format

3. **Filtering and searching**
   - By level (ERROR, WARN, INFO, DEBUG)
   - By source/service
   - By time interval
   - Regex on message

4. **Alerting**
   - Configurable patterns (e.g.: "error", "failed")
   - Rate alerts (>N errors in M minutes)
   - Notifications (desktop, email)

5. **Visualisation**
   - Terminal dashboard with statistics
   - Live tail with highlighting
   - Error histogram over time

### Optional (for full marks)

6. **Indexed storage** - SQLite for fast searching
7. **Statistics aggregation** - Count per level/source/hour
8. **Correlation** - Correlate events between services
9. **Export** - Elastic-compatible JSON, CSV
10. **Web interface** - Simple HTTP for visualisation

---

## CLI Interface

```bash
./logagg.sh <command> [options]

Commands:
  collect               Start collection (daemon)
  tail [source]         Live tail with formatting
  search <query>        Search in logs
  stats [period]        Display statistics
  dashboard             Interactive dashboard
  alert                 Manage alerting rules
  export                Export logs

Options:
  -s, --source SOURCE   Source: file:/path|journald|syslog (repeatable)
  -l, --level LEVEL     Minimum level: debug|info|warn|error
  -S, --service SVC     Filter by service
  -f, --follow          Follow mode (like tail -f)
  -n, --lines N         Last N lines
  -t, --time RANGE      Interval: "1h"|"today"|"2025-01-20"
  -g, --grep PATTERN    Regex filtering
  -o, --output FILE     Save output
  --format FMT          Output format: text|json|csv
  --no-color            No colours

Examples:
  ./logagg.sh collect -s file:/var/log/syslog -s journald
  ./logagg.sh tail --level error --follow
  ./logagg.sh search "connection refused" -t "1h"
  ./logagg.sh stats today --service nginx
  ./logagg.sh alert add --pattern "OOM" --action email
```

---

## Output Examples

### Dashboard

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                    LOG AGGREGATOR DASHBOARD                                  ║
║                    Sources: 5 | Events/min: 234                             ║
╚══════════════════════════════════════════════════════════════════════════════╝

LAST HOUR OVERVIEW
═══════════════════════════════════════════════════════════════════════════════

Events by Level:
  ERROR   ████████░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░  156 (2.3%)
  WARN    ████████████████░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░  423 (6.2%)
  INFO    ████████████████████████████████████████████████░░  5,892 (86.5%)
  DEBUG   ████░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░  342 (5.0%)

Events Timeline (last hour):
  300│        ▄▄    ▄▄▄▄
  200│  ▄▄   ████  ██████   ▄▄
  100│▄████▄██████████████▄████▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄
     └────────────────────────────────────────────────────────
      16:00  16:15  16:30  16:45  17:00  17:15  17:30  17:45

TOP SOURCES (by events)
───────────────────────────────────────────────────────────────────────────────
  nginx           2,345 events    12 errors    ████████████████████
  postgresql      1,234 events     3 errors    ██████████████
  myapp             892 events    45 errors    █████████
  sshd              456 events     2 errors    █████
  systemd           234 events     0 errors    ███

RECENT ERRORS
───────────────────────────────────────────────────────────────────────────────
  17:45:23  myapp      Connection refused to redis:6379
  17:44:56  myapp      Timeout waiting for database response
  17:42:12  nginx      upstream timed out (110: Connection timed out)
  17:40:05  postgres   could not open file "base/16384/1234": No such file

ACTIVE ALERTS
───────────────────────────────────────────────────────────────────────────────
  ⚠️  High error rate: myapp (45 errors in last hour, threshold: 20)
  🔴 Pattern match: "OOM" detected in journald at 17:30
```

### Live Tail

```
╔══════════════════════════════════════════════════════════════════════════════╗
║  LIVE LOG TAIL | Filter: level>=WARN | Sources: all                         ║
╚══════════════════════════════════════════════════════════════════════════════╝

17:45:23.456 [ERROR] myapp     Connection refused to redis:6379
                               Retry attempt 3/5, backing off 2s
17:45:25.789 [WARN]  nginx     upstream server temporarily disabled
17:45:26.123 [ERROR] myapp     Connection refused to redis:6379
                               Retry attempt 4/5, backing off 4s
17:45:28.456 [WARN]  postgres  checkpoints are occurring too frequently
17:45:30.789 [INFO]  myapp     Connection to redis restored
17:45:31.012 [WARN]  nginx     upstream server restored
17:46:00.000 [ERROR] sshd      Failed password for invalid user admin
                               from 192.168.1.100 port 54321

───────────────────────────────────────────────────────────────────────────────
Events: 1,234 | Errors: 23 | Filtered: 892 | Press 'q' to quit, '/' to search
```

### Search Results

```
╔══════════════════════════════════════════════════════════════════════════════╗
║  SEARCH: "connection refused" | Time: last 1 hour | Results: 23             ║
╚══════════════════════════════════════════════════════════════════════════════╝

Results grouped by source:

myapp (18 matches)
───────────────────────────────────────────────────────────────────────────────
  17:45:26 Connection refused to redis:6379
  17:45:23 Connection refused to redis:6379
  17:44:56 Connection refused to postgres:5432
  ... (15 more)

nginx (3 matches)
───────────────────────────────────────────────────────────────────────────────
  17:42:12 connect() failed (111: Connection refused) to upstream
  17:40:05 connect() failed (111: Connection refused) to upstream
  17:38:22 connect() failed (111: Connection refused) to upstream

postgresql (2 matches)
───────────────────────────────────────────────────────────────────────────────
  17:35:00 connection refused from 10.0.0.5
  17:30:00 connection refused from 10.0.0.5

Export: ./logagg.sh export --query "connection refused" -t 1h -o results.json
```

---

## Configuration

```yaml
# /etc/logagg/config.yaml
general:
  data_dir: /var/lib/logagg
  log_file: /var/log/logagg.log
  retention_days: 30

sources:
  - name: syslog
    type: file
    path: /var/log/syslog
    format: syslog
    
  - name: nginx-access
    type: file
    path: /var/log/nginx/access.log
    format: nginx_combined
    
  - name: nginx-error
    type: file
    path: /var/log/nginx/error.log
    format: nginx_error
    
  - name: journald
    type: journald
    units: [myapp, postgresql, redis]
    
  - name: app-json
    type: file
    path: /var/log/myapp/app.json
    format: json

parsers:
  syslog:
    pattern: '^(\w{3}\s+\d+\s+\d+:\d+:\d+)\s+(\S+)\s+(\S+?)(?:\[(\d+)\])?:\s+(.*)$'
    fields: [timestamp, host, service, pid, message]
    
  nginx_combined:
    pattern: '^(\S+)\s+\S+\s+(\S+)\s+\[([^\]]+)\]\s+"([^"]+)"\s+(\d+)\s+(\d+)'
    fields: [ip, user, timestamp, request, status, bytes]

alerts:
  - name: high_error_rate
    condition: "count(level=error) > 20 per 1h"
    action: [email, desktop]
    
  - name: oom_detected
    pattern: "OOM|Out of memory"
    action: [email, slack]
    severity: critical
```

---

## Project Structure

```
M13_Log_Aggregator/
├── README.md
├── Makefile
├── src/
│   ├── logagg.sh                # Main script
│   └── lib/
│       ├── collector.sh         # Collection from sources
│       ├── parser.sh            # Parsing and normalisation
│       ├── filter.sh            # Filtering and searching
│       ├── alert.sh             # Alerting system
│       ├── dashboard.sh         # Terminal UI
│       ├── storage.sh           # SQLite storage
│       └── export.sh            # Data export
├── etc/
│   ├── config.yaml
│   └── parsers/
│       ├── syslog.conf
│       ├── nginx.conf
│       └── json.conf
├── tests/
│   ├── test_parser.sh
│   ├── test_filter.sh
│   └── sample_logs/
└── docs/
    ├── INSTALL.md
    ├── PARSERS.md
    └── ALERTS.md
```

---

## Implementation Hints

### Tail multiple files

```bash
tail_multiple_files() {
    local files=("$@")
    
    # Using tail with --follow=name for rotation
    tail -F "${files[@]}" 2>/dev/null | while read -r line; do
        # Determine source from prefix added by tail
        local source file
        if [[ "$line" =~ ^==\>\ (.+)\ \<== ]]; then
            file="${BASH_REMATCH[1]}"
            continue
        fi
        
        process_log_line "$file" "$line"
    done
}

# Alternative: parallel tails
tail_parallel() {
    local pids=()
    
    for source in "${SOURCES[@]}"; do
        tail -F "$source" | while read -r line; do
            echo "$source|$line"
        done &
        pids+=($!)
    done
    
    # Cleanup on exit
    trap 'kill "${pids[@]}" 2>/dev/null' EXIT
    wait
}
```

### Syslog parsing

```bash
parse_syslog() {
    local line="$1"
    
    # Format: Jan 20 17:45:23 hostname service[pid]: message
    local regex='^([A-Z][a-z]{2}[[:space:]]+[0-9]+[[:space:]]+[0-9:]+)[[:space:]]+([^[:space:]]+)[[:space:]]+([^[:space:]\[]+)(\[[0-9]+\])?:[[:space:]]+(.*)'
    
    if [[ "$line" =~ $regex ]]; then
        local timestamp="${BASH_REMATCH[1]}"
        local host="${BASH_REMATCH[2]}"
        local service="${BASH_REMATCH[3]}"
        local pid="${BASH_REMATCH[4]//[\[\]]/}"
        local message="${BASH_REMATCH[5]}"
        
        # Detect level from message
        local level="INFO"
        case "$message" in
            *[Ee]rror*|*ERROR*|*[Ff]ail*) level="ERROR" ;;
            *[Ww]arn*|*WARNING*) level="WARN" ;;
            *[Dd]ebug*|*DEBUG*) level="DEBUG" ;;
        esac
        
        echo "$timestamp|$host|$service|$pid|$level|$message"
    fi
}
```

### Reading from journald

```bash
read_journald() {
    local units=("$@")
    local since="${SINCE:-1h ago}"
    
    local unit_args=()
    for unit in "${units[@]}"; do
        unit_args+=(-u "$unit")
    done
    
    journalctl "${unit_args[@]}" --since "$since" \
        -o json --no-pager | while read -r json_line; do
        
        # Parse JSON
        local timestamp service message priority
        timestamp=$(echo "$json_line" | jq -r '.__REALTIME_TIMESTAMP // empty')
        service=$(echo "$json_line" | jq -r '.SYSLOG_IDENTIFIER // ._SYSTEMD_UNIT // "unknown"')
        message=$(echo "$json_line" | jq -r '.MESSAGE // empty')
        priority=$(echo "$json_line" | jq -r '.PRIORITY // "6"')
        
        # Convert priority to level
        local level
        case "$priority" in
            0|1|2) level="CRIT" ;;
            3)     level="ERROR" ;;
            4)     level="WARN" ;;
            5|6)   level="INFO" ;;
            7)     level="DEBUG" ;;
        esac
        
        echo "$timestamp|localhost|$service||$level|$message"
    done
}
```

### Pattern alerting

```bash
check_alert_patterns() {
    local line="$1"
    local source="$2"
    
    # Load alerting rules
    while IFS='|' read -r name pattern action; do
        if [[ "$line" =~ $pattern ]]; then
            trigger_alert "$name" "$source" "$line" "$action"
        fi
    done < "$ALERTS_FILE"
}

# Rate limiting for alerts
declare -A ALERT_COUNTS
declare -A ALERT_LAST

check_rate_alert() {
    local name="$1"
    local threshold="$2"
    local window="$3"  # seconds
    
    local now
    now=$(date +%s)
    
    # Clean old entries
    local last="${ALERT_LAST[$name]:-0}"
    if ((now - last > window)); then
        ALERT_COUNTS[$name]=0
    fi
    
    ((ALERT_COUNTS[$name]++))
    ALERT_LAST[$name]=$now
    
    if ((ALERT_COUNTS[$name] >= threshold)); then
        trigger_alert "rate_$name" "" "Rate exceeded: ${ALERT_COUNTS[$name]} in ${window}s"
        ALERT_COUNTS[$name]=0
    fi
}
```

---

## Specific Evaluation Criteria

| Criterion | Weight | Description |
|-----------|--------|-------------|
| Multi-source collection | 20% | Files, journald, parallel |
| Parsing & normalisation | 20% | Syslog, JSON, auto-detect |
| Filtering & searching | 15% | Level, time, regex |
| Alerting | 15% | Patterns, rate limits |
| Dashboard | 15% | Stats, timeline, live |
| Storage/Export | 5% | SQLite, JSON export |
| Code quality + tests | 5% | ShellCheck, tests |
| Documentation | 5% | README, parsers doc |

---

## Resources

- `man tail`, `man journalctl`
- Syslog RFC 5424
- Seminar 4 - Text processing, regex

---

*MEDIUM Project | Operating Systems | ASE-CSIE*
