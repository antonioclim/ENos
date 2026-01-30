# Demo Scripts — Lesson 15 Supplementary: Network Connection

> Operating Systems | ASE Bucharest - CSIE | 2025-2026  
> by Revolvix

---

## Script Contents

| Script | Language | Purpose | Complexity |
|--------|----------|---------|------------|
| `echo_server.py` | Python | Simple TCP server with echo | Medium |
| `echo_client.py` | Python | TCP client for server testing | Medium |
| `network_diag.sh` | Bash | Network diagnostics (IP, routes, ports) | Simple |
| `firewall_basic.sh` | Bash | Basic iptables rules configuration | Advanced |

---

## Quick Start

### Echo Server/Client

```bash
# Terminal 1: Start server (listens on port 9999)
python3 echo_server.py --port 9999

# Terminal 2: Connect client
python3 echo_client.py --host localhost --port 9999

# Server with verbose logging
python3 echo_server.py --port 9999 --verbose

# Client with custom timeout
python3 echo_client.py --host 192.168.1.100 --port 9999 --timeout 10
```

### Network Diagnostics

```bash
# Full report
./network_diag.sh

# Verbose mode with extended details
./network_diag.sh -v

# Connectivity check only
./network_diag.sh --connectivity-only
```

### Firewall (requires sudo)

```bash
# List current rules
sudo ./firewall_basic.sh --list

# Allow traffic on port 80
sudo ./firewall_basic.sh --allow-port 80

# Block specific IP
sudo ./firewall_basic.sh --block-ip 10.0.0.100

# Reset to default configuration
sudo ./firewall_basic.sh --reset
```

---

## Connection to Course Concepts

### Socket API (echo_server.py & echo_client.py)

The scripts demonstrate the complete TCP communication cycle:

```
Server:                          Client:
socket() → creates socket        socket() → creates socket
   ↓                                ↓
bind() → associates IP:port         │
   ↓                                │
listen() → marks as passive         │
   ↓                                ↓
accept() ←─────────────────────── connect()
   ↓                                ↓
recv() ←───────────────────────── send()
   ↓                                ↓
send() ────────────────────────→ recv()
   ↓                                ↓
close()                           close()
```

### Client-Server Model

- **Server**: Listens passively, accepts multiple connections (optionally with threading)
- **Client**: Initiates connection, sends requests, receives responses
- **Protocol**: TCP guarantees ordered and reliable delivery

### Network Diagnostics (network_diag.sh)

Utilities demonstrated:
- `ip addr` / `ifconfig` — Interface configuration
- `ip route` / `route` — Routing table
- `ss` / `netstat` — Active connections and open ports
- `ping` — ICMP connectivity testing
- `dig` / `nslookup` — DNS resolution

### Network Security (firewall_basic.sh)

iptables concepts:
- **Chains**: INPUT, OUTPUT, FORWARD
- **Targets**: ACCEPT, DROP, REJECT
- **Matching**: port, protocol, source/destination IP

---

## Example Output

### echo_server.py

```
$ python3 echo_server.py --port 9999
[SERVER] Started on 0.0.0.0:9999
[SERVER] Waiting for connections...
[CONN] Client connected: 127.0.0.1:54321
[RECV] "Hello, server!"
[SEND] Echo: "Hello, server!"
[CONN] Client disconnected: 127.0.0.1:54321
```

### network_diag.sh

```
$ ./network_diag.sh
═══════════════════════════════════════════════════════════════
                    NETWORK DIAGNOSTIC REPORT
═══════════════════════════════════════════════════════════════

[1/5] Network interfaces:
  eth0: 192.168.1.50/24 (UP)
  lo: 127.0.0.1/8 (UP)

[2/5] Default gateway:
  192.168.1.1 via eth0

[3/5] DNS servers:
  8.8.8.8, 8.8.4.4

[4/5] Listening ports:
  tcp 0.0.0.0:22 (sshd)
  tcp 0.0.0.0:80 (nginx)

[5/5] Connectivity test:
  google.com: OK (23ms)
  8.8.8.8: OK (15ms)

═══════════════════════════════════════════════════════════════
```

---

## System Requirements

- Python 3.8+ (for echo_server.py and echo_client.py)
- Ubuntu 24.04 (WSL2 or native)
- Packages: `iproute2`, `dnsutils`, `iputils-ping`
- For firewall: root/sudo privileges, `iptables` package

### Installing dependencies

```bash
sudo apt update
sudo apt install iproute2 dnsutils iputils-ping iptables
```

---

## Troubleshooting

| Problem | Cause | Solution |
|---------|-------|----------|
| "Address already in use" | Port is occupied | `ss -tlnp \| grep <port>` and stop the process |
| "Connection refused" | Server not running | Start the server first |
| "Permission denied" (firewall) | No root access | Run with `sudo` |
| "Network unreachable" | Routing problem | Check `ip route` |

---

## Teaching Notes

1. **Local testing**: Use `localhost` or `127.0.0.1` for initial tests
2. **Ports**: Avoid ports < 1024 (require root); use 8000-65535
3. **Firewall**: Save rules before modifications (`iptables-save`)
4. **Debugging**: Use `tcpdump` or Wireshark for traffic analysis

---

*Materials developed by Revolvix for ASE Bucharest - CSIE*  
*Operating Systems | Year I, Semester 2 | 2025-2026*
