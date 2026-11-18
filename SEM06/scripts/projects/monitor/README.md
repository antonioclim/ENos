# System Monitor

A modular Bash teaching application for CPU, memory, disk, swap and load observations. It supports text, JSON and CSV, configurable thresholds, a foreground continuous loop and optional email/Slack transports. A successful fixture test does not establish production readiness or successful external notification delivery.

## Architecture and dependencies

`monitor.sh` loads separate `lib/core.sh` (logging/locks), `lib/config.sh` (literal settings and CLI) and `lib/utils.sh` (metrics). `bin/sysmonitor` invokes the project through Bash; copy the complete directory if installing it, not the wrapper alone. Bash 4.4+, Python 3.10+, GNU/Linux `/proc`, awk, df, ps and flock are needed. Curl/mail are optional only when their transport is configured.

## Run an owned local sample

From the repository root:

```bash
#!/usr/bin/env bash
set -euo pipefail
work=
trap '[[ -z ${work:-} ]] || rm -rf -- "$work"' EXIT
work=$(mktemp -d)
if LOG_DIR="$work/log" RUN_DIR="$work/run" \
   bash SEM06/scripts/projects/monitor/monitor.sh --config /dev/null \
       --log-file "$work/monitor.log" --output json > "$work/sample.json"; then
    status=0
else
    status=$?
fi
python3 -m json.tool "$work/sample.json"
printf 'Monitor exit status: %s\n' "$status"
[[ $status == 0 || $status == 2 ]] # 2 means alerts/unknown probes, not a healthy success
```

`--help` and `--version` are read-only. No `--all`, `--cpu`, `--format=json`, `--continuous` or `--interval=60` interface exists. Use separate option/value arguments.

## CLI

| Purpose | Supported options |
|---|---|
| Configuration | `-c FILE`, `--config FILE` |
| Thresholds | `--cpu-threshold N`, `--mem-threshold N`, `--disk-threshold N` |
| Loop | `-d`, `--daemon`, `-i N`, `--interval N` |
| Output | `-o text`, `-o json`, `-o csv` |
| Diagnostics | `-l FILE`, `--log-file FILE`, `--log-level LEVEL`, `-v`, `--verbose` |
| Exclusions | `--exclude-mount PATH` (repeatable) |
| Notification | `-e ADDRESS`, `--email ADDRESS`; webhook via literal configuration |
| Dry run | `-n`, `--dry-run`: read metrics, suppress notifications and file/lock writes |

Continuous mode remains in the foreground; a service manager supervises that PID. Interval waits and the first alert do not abort the loop accidentally. INT/TERM exits use normal trap cleanup; SIGKILL cannot clean resources. A stable flock file provides exclusion; do not delete it merely because it exists.

## Configuration contract

Defaults < configuration file < explicitly exported supported environment settings < CLI. An explicit `--config` must be readable; otherwise the project-relative `etc/monitor.conf` is used when present. Values are literal KEY=VALUE data with shell-style quoting only, no expansion or execution. For example:

```ini
THRESHOLD_CPU=80
THRESHOLD_MEM=90
THRESHOLD_DISK=85
THRESHOLD_SWAP=50
THRESHOLD_LOAD_MULT=2
MONITOR_INTERVAL=60
OUTPUT_FORMAT=json
LOG_LEVEL=INFO
NOTIFY_EMAIL=""
NOTIFY_SLACK_WEBHOOK=""
DISK_EXCLUDE_MOUNTS=("/mnt/owned backup")
```

Other supported settings are LOG_FILE, LOG_MAX_SIZE, LOG_ROTATE_COUNT, LOG_USE_COLORS, NOTIFY_ON_RECOVERY, DRY_RUN, VERBOSE, DAEMON_MODE, LOCK_FILE, LOG_DIR and RUN_DIR. Paths and recipient values must be explicitly reviewed for a real host. Show-config/debug output redacts configured notification secrets. `set -x` is not enabled by verbose mode.

## Metric semantics

- CPU sums user through steal and samples twice; guest fields are not added again. Idle+iowait is the chosen non-busy convention. Linux iowait accounting is imperfect and can decrease. Invalid, non-positive or reset deltas fail rather than become zero.
- Memory percentage uses `(MemTotal-MemAvailable)/MemTotal`; detailed values are MiB. SwapTotal=0 is a valid zero-use case; missing swap fields are unavailable.
- Disk percentage follows checked `LC_ALL=C df -P`. The human list percent-escapes `%` and `|` in mount labels. It does not claim a reversible encoding of every possible procps/df filename representation.
- Load average is not a CPU percentage. Process counts use `ps -e`; process `comm` is the last field so spaces do not shift numeric columns. Observations race with process lifecycle changes.
- JSON uses an encoder and a single cached sample. Missing metric values are null/unavailable; check errors remain visible and do not produce OK.

Exit 0 means no alert in the observed checks, 1 a configuration/environment failure, 2 alerts or failed probes with health unknown and 3 a fatal setup failure. Inspect stderr and the structured status; no sample proves future health.

## Integration and tests

Use [the reviewed unit templates](../../../resources/README.md) for systemd/cron planning. Provisioning users, copying units, enabling timers and sending real notifications are separate host actions. This repository check does none of those operations.

```bash
bash SEM06/scripts/projects/monitor/tests/test_monitor.sh
PYTEST_DISABLE_PLUGIN_AUTOLOAD=1 python3 -m pytest SEM06/tests/test_runtime_semantics.py SEM06/tests/test_teaching_examples.py -q
```

The Bash harness runs all its tests; it has no supported core-only filter or `-v` contract. Native fixture results and a live host sample are distinct from a running systemd service, network endpoint or browser acceptance.

## Licence

Educational material - ASE Bucharest, CSIE - Operating Systems
