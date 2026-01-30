# M04: Network Security Scanner

> **Level:** MEDIUM | **Estimated time:** 25-35 hours | **K8s Bonus:** +10%

---

## Description

Security scanner for local networks: active host detection, port scanning, service identification, known vulnerabilities and report generation. Useful for periodic infrastructure auditing.

---

## Learning Objectives

- Network concepts: IP, TCP/UDP, ICMP
- Port scanning and service detection
- Parallel processing in Bash (jobs, xargs)
- Parsing `nmap` output and other tools
- Structured report generation (HTML, JSON)

---

## Functional Requirements

### Mandatory (for passing grade)

1. **Host discovery**
   - Ping sweep on subnet (ICMP echo)
   - ARP scan for local network
   - Host detection without ICMP (TCP SYN)

2. **Port scanning**
   - Common port scanning (top 100/1000)
   - Specific port range scanning
   - TCP connect scan and SYN scan (with permissions)

3. **Service identification**
   - Banner grabbing for open ports
   - Service version detection
   - OS fingerprinting (basic)

4. **Reporting**
   - Formatted text output
   - JSON export for processing
   - HTML export for visualisation

5. **Configuration and profiles**
   - Predefined profiles (quick, normal, thorough)
   - Custom port configuration
   - Exclude list for hosts/ports

### Optional (for full marks)

6. **Vulnerability checking** - CVE check for detected versions
7. **Scan comparison** - Diff between two scans (change detection)
8. **Scheduled scanning** - Cron integration with alerting
9. **Rate limiting** - Avoid detection/blocking
10. **TLS/SSL check** - Certificate and configuration verification

---

## CLI Interface

```bash
./netscan.sh <command> [options] <target>

Commands:
  discover              Discover hosts in subnet
  scan                  Port scan on target
  service               Service identification
  full                  Full scan (discover + scan + service)
  compare               Compare two reports
  report                Generate report from saved data

Target:
  192.168.1.0/24        CIDR subnet
  192.168.1.1           Individual host
  192.168.1.1-50        Host range
  hosts.txt             File with host list

Options:
  -p, --ports PORTS     Ports to scan (e.g.: 22,80,443 or 1-1024)
  -P, --profile PROF    Profile: quick|normal|thorough|stealth
  -o, --output FILE     Output file (extension determines format)
  -f, --format FMT      Format: text|json|html|csv
  -t, --timeout SEC     Timeout per port (default: 2)
  -T, --threads N       Number of parallel threads (default: 10)
  -v, --verbose         Detailed output
  --no-ping             Don't check with ping first
  --tcp-only            TCP only, no UDP
  --rate-limit N        Max N packets/second

Examples:
  ./netscan.sh discover 192.168.1.0/24
  ./netscan.sh scan -p 22,80,443 192.168.1.1
  ./netscan.sh full -P thorough -o report.html 10.0.0.0/24
  ./netscan.sh compare scan1.json scan2.json
```

---

## Output Examples

### Discover Output

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                    NETWORK DISCOVERY REPORT                                  ║
║                    Target: 192.168.1.0/24                                   ║
║                    Date: 2025-01-20 15:30:00                                ║
╚══════════════════════════════════════════════════════════════════════════════╝

Scanning 256 hosts...
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 100%

┌─────────────────────────────────────────────────────────────────────────────┐
│ DISCOVERED HOSTS: 12                                                        │
├─────────────────┬───────────────────┬──────────────┬───────────────────────┤
│ IP Address      │ MAC Address       │ Hostname     │ Response Time         │
├─────────────────┼───────────────────┼──────────────┼───────────────────────┤
│ 192.168.1.1     │ aa:bb:cc:dd:ee:01 │ router.local │ 1ms                   │
│ 192.168.1.10    │ aa:bb:cc:dd:ee:10 │ server01     │ 2ms                   │
│ 192.168.1.11    │ aa:bb:cc:dd:ee:11 │ server02     │ 1ms                   │
│ 192.168.1.20    │ aa:bb:cc:dd:ee:20 │ desktop-ion  │ 3ms                   │
│ 192.168.1.21    │ aa:bb:cc:dd:ee:21 │ laptop-maria │ 5ms                   │
│ ...             │ ...               │ ...          │ ...                   │
└─────────────────┴───────────────────┴──────────────┴───────────────────────┘

Summary:
  Total scanned:    256
  Hosts up:         12 (4.7%)
  Hosts down:       244
  Scan duration:    8.3 seconds
```

### Full Scan Output

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                    FULL SECURITY SCAN REPORT                                 ║
║                    Target: 192.168.1.10                                     ║
╚══════════════════════════════════════════════════════════════════════════════╝

HOST: 192.168.1.10 (server01.local)
═══════════════════════════════════════════════════════════════════════════════

OS Detection: Linux 5.x (Ubuntu)
MAC: aa:bb:cc:dd:ee:10 (Dell Inc.)

┌─────────────────────────────────────────────────────────────────────────────┐
│ OPEN PORTS                                                                  │
├───────┬──────────┬─────────────────────────────────────────────────────────┤
│ Port  │ Protocol │ Service                                                 │
├───────┼──────────┼─────────────────────────────────────────────────────────┤
│ 22    │ tcp      │ OpenSSH 8.9p1 Ubuntu                                    │
│ 80    │ tcp      │ nginx/1.24.0                                            │
│ 443   │ tcp      │ nginx/1.24.0 (TLS 1.3)                                  │
│ 3306  │ tcp      │ MySQL 8.0.35                                            │
│ 5432  │ tcp      │ PostgreSQL 15.4                                         │
│ 6379  │ tcp      │ Redis 7.2.3                                             │
│ 8080  │ tcp      │ Apache Tomcat 10.1.x                                    │
└───────┴──────────┴─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│ ⚠️  SECURITY FINDINGS                                                       │
├─────────────────────────────────────────────────────────────────────────────┤
│ [MEDIUM] Port 6379 (Redis) - No authentication detected                    │
│ [LOW]    Port 22 (SSH) - Password authentication enabled                   │
│ [INFO]   Port 3306 (MySQL) - Accessible from network                       │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│ TLS/SSL CHECK (port 443)                                                   │
├─────────────────────────────────────────────────────────────────────────────┤
│ Certificate: CN=server01.example.com                                        │
│ Issuer: Let's Encrypt                                                       │
│ Valid until: 2025-04-20 (90 days)                                          │
│ Protocols: TLSv1.2, TLSv1.3 ✓                                              │
│ Cipher suites: Modern (AEAD) ✓                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### JSON Output

```json
{
  "scan_info": {
    "target": "192.168.1.10",
    "timestamp": "2025-01-20T15:30:00Z",
    "profile": "thorough",
    "duration_seconds": 45.2
  },
  "host": {
    "ip": "192.168.1.10",
    "mac": "aa:bb:cc:dd:ee:10",
    "hostname": "server01.local",
    "os_guess": "Linux 5.x",
    "status": "up"
  },
  "ports": [
    {
      "port": 22,
      "protocol": "tcp",
      "state": "open",
      "service": "ssh",
      "version": "OpenSSH 8.9p1"
    },
    {
      "port": 80,
      "protocol": "tcp",
      "state": "open",
      "service": "http",
      "version": "nginx/1.24.0"
    }
  ],
  "findings": [
    {
      "severity": "medium",
      "port": 6379,
      "title": "Redis without authentication",
      "description": "Redis server accepts connections without password"
    }
  ]
}
```

---

## Project Structure

```
M04_Network_Security_Scanner/
├── README.md
├── Makefile
├── src/
│   ├── netscan.sh               # Main script
│   └── lib/
│       ├── discover.sh          # Host discovery
│       ├── portscan.sh          # Port scanning
│       ├── services.sh          # Service identification
│       ├── checks.sh            # Security checks
│       ├── report.sh            # Report generation
│       └── utils.sh             # Utility functions
├── etc/
│   ├── ports.conf               # Predefined ports per profile
│   ├── services.conf            # Service signatures
│   └── profiles/
│       ├── quick.conf
│       ├── normal.conf
│       └── thorough.conf
├── templates/
│   └── report.html              # HTML report template
├── tests/
│   ├── test_discover.sh
│   ├── test_portscan.sh
│   └── test_network/            # Mock network for tests
├── docs/
│   ├── INSTALL.md
│   ├── PROFILES.md
│   └── LEGAL.md                 # Legal warnings
└── examples/
    └── sample_reports/
```

---

## Implementation Hints

### Parallel ping sweep

```bash
ping_sweep() {
    local subnet="$1"  # e.g.: 192.168.1
    local max_parallel="${2:-20}"
    
    for i in {1..254}; do
        echo "$subnet.$i"
    done | xargs -P "$max_parallel" -I {} sh -c '
        ping -c 1 -W 1 {} >/dev/null 2>&1 && echo "{} up"
    '
}

# Or with GNU parallel (more efficient)
ping_sweep_parallel() {
    local subnet="$1"
    seq 1 254 | parallel -j 50 "ping -c 1 -W 1 ${subnet}.{} >/dev/null 2>&1 && echo '${subnet}.{} up'"
}
```

### TCP connect port scan

```bash
scan_port() {
    local host="$1"
    local port="$2"
    local timeout="${3:-2}"
    
    # Bash built-in (fastest)
    timeout "$timeout" bash -c "echo >/dev/tcp/$host/$port" 2>/dev/null
    return $?
}

# Scan port range
scan_ports() {
    local host="$1"
    local start_port="$2"
    local end_port="$3"
    
    for port in $(seq "$start_port" "$end_port"); do
        if scan_port "$host" "$port" 1; then
            echo "$port open"
        fi
    done
}

# Parallel with xargs
scan_ports_parallel() {
    local host="$1"
    local ports="$2"  # e.g.: "22 80 443 8080"
    
    echo "$ports" | tr ' ' '\n' | xargs -P 20 -I {} bash -c "
        timeout 2 bash -c 'echo >/dev/tcp/$host/{}' 2>/dev/null && echo '{} open'
    "
}
```

### Banner grabbing

```bash
grab_banner() {
    local host="$1"
    local port="$2"
    local timeout="${3:-3}"
    
    # HTTP banner
    if [[ "$port" == "80" || "$port" == "8080" ]]; then
        curl -s -I --max-time "$timeout" "http://$host:$port" 2>/dev/null | head -5
        return
    fi
    
    # Generic banner (send newline, read response)
    echo "" | timeout "$timeout" nc -w "$timeout" "$host" "$port" 2>/dev/null | head -1
}

# SSH version
get_ssh_version() {
    local host="$1"
    timeout 3 nc -w 3 "$host" 22 2>/dev/null | head -1
    # Output: SSH-2.0-OpenSSH_8.9p1 Ubuntu-3ubuntu0.4
}
```

### ARP scan (local network)

```bash
arp_scan() {
    local interface="${1:-eth0}"
    
    # Requires root privileges
    if command -v arp-scan &>/dev/null; then
        sudo arp-scan --interface="$interface" --localnet
    else
        # Fallback: read ARP table after ping sweep
        ip neigh show | awk '/REACHABLE|STALE/ {print $1, $5}'
    fi
}
```

### HTML report generation

```bash
generate_html_report() {
    local data_file="$1"
    local output="$2"
    
    cat > "$output" << 'HTML_HEADER'
<!DOCTYPE html>
<html>
<head>
    <title>Network Scan Report</title>
    <style>
        body { font-family: 'Segoe UI', sans-serif; margin: 20px; }
        table { border-collapse: collapse; width: 100%; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background-color: #4CAF50; color: white; }
        .open { color: green; font-weight: bold; }
        .finding-high { background-color: #ffcccc; }
        .finding-medium { background-color: #fff3cd; }
    </style>
</head>
<body>
HTML_HEADER

    # Process data_file and generate content
    # ...
    
    echo "</body></html>" >> "$output"
}
```

---

## Specific Evaluation Criteria

| Criterion | Weight | Description |
|-----------|--------|-------------|
| Host discovery | 15% | Ping sweep, ARP scan |
| Port scanning | 20% | TCP, parallel, range/list |
| Service identification | 15% | Banner grabbing, versions |
| Reporting | 15% | Text + JSON + HTML |
| Profiles and configuration | 10% | Quick/thorough, exclude lists |
| Extra features | 10% | SSL check, vuln check, diff |
| Code quality + tests | 10% | Modular, ShellCheck, tests |
| Documentation | 5% | README, LEGAL warnings |

---

## ⚠️ Legal Warnings

**IMPORTANT:** Network scanning without authorisation is illegal in most jurisdictions.

- Use this tool ONLY on networks you own or have explicit authorisation for
- For testing, use the local network or your own virtual machines
- Always document authorisation before a production scan

---

## Resources

- `man nmap` - Reference for scanning techniques
- `man nc` (netcat) - Swiss army knife for networking
- `man ss` - Socket statistics
- RFC 793 (TCP), RFC 791 (IP) - Basic protocols

---

*MEDIUM Project | Operating Systems | ASE-CSIE*
