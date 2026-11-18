# E02: Log Analyzer

> **Level:** EASY | **Estimated time:** 15-20 hours | **Components:** Bash only

---

## Description

> 💡 **Instructor's note:** This project teaches you text processing — the bread and butter of system administration. The skills you learn here (grep, sed, awk) are the same ones senior engineers use daily. I have seen students land internships specifically because they could demonstrate log analysis skills from this project.

Develop a tool for analysing log files. The script will parse, filter and generate statistics from various log formats (syslog, Apache, nginx, custom applications).

---

## Learning Objectives

- Text processing with `grep`, `sed`, `awk`
- Advanced regular expressions
- Aggregation and statistics
- Structured format parsing

---

## Functional Requirements

### Mandatory (for passing grade)

1. **Standard format parsing**

Three things matter here: syslog (`/var/log/syslog`), apache/nginx access logs and auth logs (`/var/log/auth.log`).


2. **Filtering**
   - By level (ERROR, WARN, INFO, DEBUG)
   - By time interval
   - By pattern/keyword
   - By source/service

3. **Statistics**
   - Count per severity level
   - Top 10 frequent messages
   - Distribution by hours/days
   - Errors per service

4. Output
   - Formatted text report
   - CSV export for further analysis

### Optional (for full marks)

5. **Anomaly detection** - error spikes
6. **Alerting** - notification at threshold
7. **Tail mode** - real-time monitoring
8. **Multiple file aggregation**

---

## Interface

```text
./log_analyzer.sh [OPTIONS] <log_file|log_dir>

Options:
  -h, --help              Display help
  -l, --level LEVEL       Filter by level (ERROR|WARN|INFO|DEBUG)
  -s, --start DATETIME    Start timestamp (YYYY-MM-DD HH:MM)
  -e, --end DATETIME      End timestamp
  -p, --pattern REGEX     Filter by pattern
  -f, --format FORMAT     Log format: auto|syslog|apache|nginx|custom
  -o, --output FILE       Save report
  --top N                 Top N frequent messages (default: 10)
  --stats-only            Statistics only, no details
  -t, --tail              Continuous monitoring mode

Examples:
  ./log_analyzer.sh /var/log/syslog
  ./log_analyzer.sh -l ERROR --start "2025-01-20 00:00" /var/log/
  ./log_analyzer.sh -p "failed|error" -f apache access.log
  ./log_analyzer.sh -t --level ERROR /var/log/syslog
```

---

## Output Example

These are synthetic illustrations, not measured runs or acceptance evidence.

```
╔══════════════════════════════════════════════════════════════════╗
║                    LOG ANALYSIS REPORT                           ║
║  File: /var/log/syslog                                          ║
║  Period: 2025-01-20 00:00 - 2025-01-20 23:59                   ║
╚══════════════════════════════════════════════════════════════════╝

📊 SEVERITY DISTRIBUTION
──────────────────────────────────────────────────────────────────
Level      Count     Percentage    Visual
─────────────────────────────────────────────────────────────────
ERROR      234       2.3%          ██
WARN       1,456     14.5%         ██████████████
INFO       7,890     78.7%         ██████████████████████████████████████████████████████
DEBUG      450       4.5%          ████

Total entries: 10,030

⏰ HOURLY DISTRIBUTION
──────────────────────────────────────────────────────────────────
00:00 ████████████ 456
01:00 ████████ 312
02:00 ██████ 234
...
14:00 ████████████████████████ 892  <- Peak hour
15:00 ██████████████████████ 823
...

🔴 TOP 10 ERROR MESSAGES
──────────────────────────────────────────────────────────────────
Count  Message
───────────────────────────────────────
  45   Connection refused to database server
  34   Failed to authenticate user
  23   Disk space warning on /var
  ...

🔧 ERRORS BY SERVICE
──────────────────────────────────────────────────────────────────
Service          Errors    Percentage
───────────────────────────────────────
mysql            89        38.0%
nginx            45        19.2%
cron             34        14.5%
systemd          28        12.0%
other            38        16.3%

⚠️  ANOMALIES DETECTED
──────────────────────────────────────────────────────────────────
[!] Error spike at 14:23 - 47 errors in 5 minutes (normal: 2-5)
[!] Service 'mysql' has 3x normal error rate

══════════════════════════════════════════════════════════════════
Analysis completed in 3.2 seconds
══════════════════════════════════════════════════════════════════
```

---

## Recommended Structure

```
E02_Log_Analyzer/
├── README.md
├── Makefile
├── src/
│   ├── log_analyzer.sh
│   └── lib/
│       ├── parsers/
│       │   ├── syslog.sh
│       │   ├── apache.sh
│       │   └── nginx.sh
│       ├── filters.sh
│       ├── stats.sh
│       └── report.sh
├── etc/
│   └── patterns.conf         # Regex patterns for formats
├── tests/
│   ├── sample_logs/
│   │   ├── sample_syslog.log
│   │   └── sample_apache.log
│   └── test_*.sh
└── docs/
    └── USAGE.md
```

---

## Implementation Hints

### Syslog parsing

```bash
# Limited classic syslog grammar: Jan 20 14:30:45 hostname service[pid]: message
# Diagnostic TSV only; escape fields for stored interchange. Year/timezone must be supplied.
# This parser does not claim RFC5424 or native severity where the input lacks it.
parse_syslog() {
    awk '{
        timestamp = $1" "$2" "$3
        host = $4
        service = $5
        sub(/\[.*/, "", service); sub(/:$/, "", service)
        message = $0
        # Remove exactly the five header tokens, not an earlier matching word.
        for (i=0; i<5; i++) sub(/^[[:space:]]*[^[:space:]]+[[:space:]]*/, "", message)
        print timestamp"\t"host"\t"service"\t"message
    }' "$1"
}
```

### Time filtering

```bash
# Timestamp conversion for comparison
date_to_epoch() {
    date -d "$1" +%s 2>/dev/null
}
```

### Level counting

```bash
# For a declared explicit severity token per line (not inferred from message substrings).
awk '
BEGIN {levels[1]="ERROR"; levels[2]="WARN"; levels[3]="INFO"; levels[4]="DEBUG"}
{ for(i=1;i<=NF;i++) if($i ~ /^(ERROR|WARN|INFO|DEBUG)$/) {count[$i]++; break} }
END {for(i=1;i<=4;i++) printf "%s %d\n", levels[i], count[levels[i]]+0}
' "$logfile"
```

---

## ⚠️ Common Pitfalls

> Based on previous years' submissions, these are the mistakes students make most often:

### 1. Parsing with Fixed Column Positions
**Problem:** Assuming syslog always has the timestamp in columns 1-3. Some systems use different formats.
**Solution:** Use flexible regex matching, not fixed positions.

### 2. Not Handling Large Files
**Problem:** Loading entire log file into memory crashes on production logs (500MB+).
**Solution:** Process line by line with `while read` or use `awk` streaming.

### 3. Ignoring Timezones
**Problem:** Timestamps match incorrectly when filtering by time.
**Solution:** Normalise all timestamps to UTC before comparison.

### 4. Hardcoded Log Paths
**Problem:** Using `/var/log/syslog` directly instead of as parameter.
**Solution:** Always accept the log path as an argument.

---

## Specific Evaluation Criteria

| Criterion | Weight |
|-----------|--------|
| Correct format parsing | 20% |
| Functional filtering | 15% |
| Correct statistics | 15% |
| Formatted output | 10% |
| Extra features | 10% |
| Code quality | 15% |
| Tests | 10% |
| Documentation | 5% |

---

*EASY Project | Operating Systems | ASE-CSIE*
