# System Monitor

**Complete system resource monitoring application in Bash**

## Description

System Monitor is a professional application for monitoring system resources: CPU, memory, disk, swap and load average. It supports configurable alerting, email and Slack notifications, daemon mode for continuous monitoring and multiple output formats.

## Architecture

```
monitor/
├── monitor.sh          # Main script (entry point)
├── bin/
│   └── sysmonitor      # Wrapper for installation
├── lib/
│   ├── core.sh         # Fundamental functions (logging, error handling)
│   ├── utils.sh        # System metrics collection functions
│   └── config.sh       # Configuration management
├── etc/
│   └── monitor.conf    # Default configuration
├── var/
│   ├── log/            # Log files
│   └── run/            # PID files (for daemon mode)
└── tests/
    └── test_monitor.sh # Test suite
```

## Installation

```bash
# Clone/copy the project
cd /path/to/monitor

# Set execution permissions
chmod +x monitor.sh bin/sysmonitor tests/test_monitor.sh

# Optional: create symlink for global access
sudo ln -sf "$(pwd)/monitor.sh" /usr/local/bin/sysmonitor
```

## Usage

### Single-Shot Check

```bash
# Quick check (immediate exit)
./monitor.sh

# With JSON output
./monitor.sh -o json

# Verbose mode
./monitor.sh -v
```

### Daemon Mode

```bash
# Start continuous monitoring
./monitor.sh -d

# With custom interval (30 seconds)
./monitor.sh -d -i 30

# With email notifications
./monitor.sh -d -e admin@example.com
```

### Custom Thresholds

```bash
# Set specific thresholds
./monitor.sh --cpu-threshold 90 --mem-threshold 95 --disk-threshold 80

# Or via environment variables
THRESHOLD_CPU=90 THRESHOLD_MEM=95 ./monitor.sh
```

### Output Formats

```bash
# Text (default)
./monitor.sh -o text

# JSON (for automated parsing)
./monitor.sh -o json

# CSV (for logging/graphs)
./monitor.sh -o csv
```

## Configuration

### Configuration File

Edit `etc/monitor.conf`:

```bash
# Alert thresholds (percentages)
THRESHOLD_CPU=80
THRESHOLD_MEM=90
THRESHOLD_DISK=85
THRESHOLD_SWAP=50

# Monitoring interval (seconds)
MONITOR_INTERVAL=60

# Notifications
NOTIFY_EMAIL=admin@example.com
NOTIFY_ON_RECOVERY=true

# Logging
LOG_LEVEL=INFO
LOG_FILE=/var/log/sysmonitor.log
```

### Environment Variables

All settings can be overridden via environment variables:

```bash
export THRESHOLD_CPU=95
export NOTIFY_EMAIL=alerts@company.com
export LOG_LEVEL=DEBUG
./monitor.sh
```

### Command Line Options

```
Usage: monitor.sh [options]

Options:
    -c, --config FILE       Configuration file
    --cpu-threshold N       CPU alert threshold (default: 80%)
    --mem-threshold N       Memory alert threshold (default: 90%)
    --disk-threshold N      Disk alert threshold (default: 85%)
    -i, --interval N        Monitoring interval in seconds (default: 60)
    -l, --log-file FILE     Log file
    --log-level LEVEL       Logging level: DEBUG, INFO, WARN, ERROR
    -e, --email ADDRESS     Email address for notifications
    -d, --daemon            Run in daemon mode
    -n, --dry-run           Display only, don't send notifications
    -v, --verbose           Detailed output (enables DEBUG)
    -o, --output FORMAT     Output format: text, json, csv
    --exclude-mount PATH    Exclude mount point from monitoring
    -h, --help              Display this message
    --version               Display version
```

## System Integration

### Systemd Service

Create `/etc/systemd/system/sysmonitor.service`:

```ini
[Unit]
Description=System Monitor Service
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/sysmonitor -d
Restart=always
RestartSec=60
User=root

[Install]
WantedBy=multi-user.target
```

Activation:

```bash
sudo systemctl daemon-reload
sudo systemctl enable sysmonitor
sudo systemctl start sysmonitor
```

### Cron Job

For periodic monitoring without daemon:

```bash
# Edit crontab
crontab -e

# Add: check every 5 minutes
*/5 * * * * /usr/local/bin/sysmonitor >> /var/log/sysmonitor.log 2>&1
```

## Testing

```bash
# Run all tests
./tests/test_monitor.sh

# Only tests for core.sh
./tests/test_monitor.sh core

# Verbose
./tests/test_monitor.sh -v
```

## Exit Codes

| Code | Meaning |
|------|---------|
| 0    | Success, all resources OK |
| 1    | Configuration error |
| 2    | At least one active alert |
| 3    | Fatal error |

## Code Structure

### core.sh
- Logging functions (`log`, `log_info`, `log_error`, etc.)
- Error handling (`die`, `check_error`)
- Validation (`require_cmd`, `require_file`, `is_integer`)
- Lock files (`acquire_lock`, `release_lock`)

### utils.sh
- CPU metrics (`get_cpu_usage`, `get_cpu_cores`, `get_load_average`)
- Memory metrics (`get_memory_usage`, `get_swap_usage`)
- Disk metrics (`get_disk_usage`, `get_all_disk_info`)
- Process information (`get_process_count`, `get_top_cpu_processes`)
- System information (`get_hostname`, `get_uptime_seconds`)

### config.sh
- Configuration loading from file
- Command line argument parsing
- Configuration validation
- Help and version

## Licence

Educational material - ASE Bucharest, CSIE - Operating Systems
