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

```text
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
    python3 "${TAIL_HELPER:?Path to 04_PROJECTS/reference/tail_reference.py}" "$@"
}

# Same implementation owns every child and serialises complete JSON records.
tail_parallel() { tail_multiple_files "${SOURCES[@]}"; }
```

The [collector reference](../reference/tail_reference.py) attaches source identity
before collection, preserves physical line bytes and uses one JSON serialisation
point. It starts with zero backlog and reaps every owned child on exit. Rotation,
copy-truncation and initial attachment can lose or repeat observations; this is
not an exactly-once ingestion protocol. Multiline messages require a declared
application framing rule; binary line content is base64-labelled.

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
        
        # Classic month/day records have no native priority, year or timezone.
        # Supply the archive year and timezone explicitly; rollover is not inferred.
        python3 - "$timestamp" "${SYSLOG_YEAR:?Archive year required}" "${SYSLOG_TIMEZONE:?Timezone required}" "$host" "$service" "$pid" "$message" <<'PYSYSLOG'
import datetime as dt,json,sys
from zoneinfo import ZoneInfo
stamp=dt.datetime.strptime(sys.argv[2]+' '+sys.argv[1],'%Y %b %d %H:%M:%S').replace(tzinfo=ZoneInfo(sys.argv[3]))
print(json.dumps({'timestamp':stamp.astimezone(dt.timezone.utc).isoformat(),'host':sys.argv[4],'service':sys.argv[5],'pid':sys.argv[6],
 'level':'UNKNOWN','priority':None,'message':sys.argv[7],'source_format':'classic_syslog','assumed_year':sys.argv[2],'assumed_timezone':sys.argv[3]}))
PYSYSLOG
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
    
    set -o pipefail
    journalctl "${unit_args[@]}" --since "$since" -o json --no-pager |
        python3 -c '
import datetime as dt,json,sys
levels={"0":"CRIT","1":"CRIT","2":"CRIT","3":"ERROR","4":"WARN","5":"INFO","6":"INFO","7":"DEBUG"}
for line in sys.stdin:
    row=json.loads(line); micros=int(row["__REALTIME_TIMESTAMP"])
    stamp=dt.datetime.fromtimestamp(micros/1e6,dt.timezone.utc).isoformat()
    print(json.dumps({"timestamp":stamp,"host":row.get("_HOSTNAME"),"service":row.get("SYSLOG_IDENTIFIER",row.get("_SYSTEMD_UNIT")),
      "level":levels.get(str(row.get("PRIORITY")),"UNKNOWN"),"priority":row.get("PRIORITY"),"message":row.get("MESSAGE"),"source_format":"journald"}))
'
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

# Sliding event window; notification throttling is independent.
declare -A ALERT_TIMES=() ALERT_LAST_SENT=()
check_rate_alert() {
    local name="$1" threshold="$2" window="$3" now="${4:-$(date +%s)}"
    [[ $threshold =~ ^[0-9]+$ && $window =~ ^[1-9][0-9]*$ && $now =~ ^[0-9]+$ ]] || return 2
    local -a times=() kept=()
    local item
    IFS=' ' read -r -a times <<< "${ALERT_TIMES[$name]:-}"
    for item in "${times[@]}"; do
        ((item <= now)) || { echo "Event clock moved backwards" >&2; return 2; }
        ((item > now-window)) && kept+=("$item")
    done
    kept+=("$now")
    local IFS=' '
    ALERT_TIMES[$name]="${kept[*]}"
    # Requirement says > N, not >= N. Default delivery cooldown is one window.
    if (( ${#kept[@]} > threshold && now-${ALERT_LAST_SENT[$name]:-0} >= window )); then
        trigger_alert "rate_$name" "" "Rate exceeded: ${#kept[@]} in ${window}s" || return 1
        ALERT_LAST_SENT[$name]=$now
    fi
    return 0
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
