# Operating Systems - Week 14 (Supplementary): Network Connection

> **by Revolvix** | ASE Bucharest - CSIE | Year I, Semester 2 | 2025-2026  
> **Syllabus compliance**: Week 14 — "Network connection. Linux commands"

---

## Weekly Objectives

1. **Identify** the role of the operating system in managing network communications
2. **Explain** the TCP/IP stack architecture from the kernel perspective
3. **Configure** network interfaces and routing tables using Linux utilities
4. **Use** diagnostic tools for traffic analysis and connectivity troubleshooting
5. **Implement** a basic client-server model using the BSD socket API
6. **Apply** packet filtering rules through the netfilter subsystem

---

## Applied Context: Why Is Networking the OS's Responsibility?

When an application invokes an HTTP request, the data path traverses multiple software layers, and the operating system mediates each critical transition. The Linux kernel manages physical and virtual interfaces, maintains routing tables, implements transport protocols (TCP/UDP), administers socket buffers and enforces security policies through netfilter. Without this infrastructure, applications would need to reimplement the entire protocol stack — a situation analogous to the absence of a filesystem, when each program would manage disk blocks directly.

The contemporary context amplifies this responsibility: Docker containers share the host's network stack through namespaces, Kubernetes orchestrates thousands of virtual endpoints, and eBPF allows injecting custom logic directly into the packet processing path. Understanding networking fundamentals at the kernel level thus constitutes an obligatory prerequisite for cloud-native architectures.

---

## Lesson Content (14 Supplementary / 14)

### 1. Network Stack Architecture in Linux

The operating system implements the TCP/IP model through a layered architecture, with each level exposing well-defined interfaces to the adjacent level.

```
┌─────────────────────────────────────────────────────────────────────────┐
│                           USER SPACE                                    │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐    │
│  │   Browser   │  │   curl      │  │    ssh      │  │ Application │    │
│  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘    │
│         │                │                │                │           │
│         └────────────────┼────────────────┼────────────────┘           │
│                          │                │                            │
│ ═══════════════════════════ SYSTEM CALLS ═════════════════════════════ │
│          socket(), bind(), listen(), accept(), connect(),              │
│          send(), recv(), sendto(), recvfrom(), close()                 │
├─────────────────────────────────────────────────────────────────────────┤
│                          KERNEL SPACE                                   │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │                    SOCKET LAYER (BSD API)                        │   │
│  │        struct socket, struct sock, protocol families            │   │
│  └──────────────────────────────┬──────────────────────────────────┘   │
│                                 │                                       │
│  ┌─────────────────────────────┴──────────────────────────────────┐   │
│  │               TRANSPORT LAYER (L4)                              │   │
│  │  ┌───────────────────┐    ┌───────────────────┐                │   │
│  │  │        TCP        │    │        UDP        │                │   │
│  │  │ • Flow control    │    │ • Connectionless  │                │   │
│  │  │ • Retransmission  │    │ • Minimal overhead│                │   │
│  │  │ • Ordering        │    │ • Multicast       │                │   │
│  │  └─────────┬─────────┘    └─────────┬─────────┘                │   │
│  └────────────┼──────────────────────────┼────────────────────────┘   │
│               └──────────────┬───────────┘                             │
│  ┌───────────────────────────┴─────────────────────────────────────┐   │
│  │                   NETWORK LAYER (L3)                             │   │
│  │  ┌─────────────────────────────────────────────────────────┐    │   │
│  │  │                      IPv4 / IPv6                         │    │   │
│  │  │  • Routing (FIB - Forwarding Information Base)          │    │   │
│  │  │  • Fragmentation/Reassembly                             │    │   │
│  │  │  • ICMP (diagnostics)                                    │    │   │
│  │  │  • ARP/NDP (L2 address resolution)                      │    │   │
│  │  └─────────────────────────────────────────────────────────┘    │   │
│  │                                                                  │   │
│  │  ┌─────────────────────────────────────────────────────────┐    │   │
│  │  │                     NETFILTER                            │    │   │
│  │  │  hooks: PREROUTING, INPUT, FORWARD, OUTPUT, POSTROUTING │    │   │
│  │  │  modules: iptables, nftables, conntrack                 │    │   │
│  │  └─────────────────────────────────────────────────────────┘    │   │
│  └─────────────────────────────────┬───────────────────────────────┘   │
│  ┌─────────────────────────────────┴───────────────────────────────┐   │
│  │               DATA LINK LAYER (L2)                               │   │
│  │  • Device drivers (e1000, virtio-net, veth)                     │   │
│  │  • Traffic control (tc - qdisc, class, filter)                  │   │
│  │  • Bridging, bonding, VLAN                                       │   │
│  └─────────────────────────────────┬───────────────────────────────┘   │
│                                    │                                    │
├────────────────────────────────────┼────────────────────────────────────┤
│                         HARDWARE / NIC                                  │
│  ┌─────────────────────────────────┴───────────────────────────────┐   │
│  │  Ring buffers, DMA, IRQ coalescing, RSS (Receive Side Scaling)  │   │
│  └─────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────┘
```

#### 1.1. Packet Reception Path

When an Ethernet frame arrives at the network interface, the processing sequence follows this path:

1. **NIC → DMA**: The network controller transfers the frame to main memory via DMA (Direct Memory Access), populating a descriptor in the receive ring buffer.

2. **Interrupt → NAPI**: The kernel receives the hardware interrupt, but instead of processing each packet individually (prohibitive overhead at gigabit rates), it activates NAPI (New API) which switches to polling mode.

3. **L2 Layer**: The driver decodes the Ethernet header, verifies the destination MAC address and determines the encapsulated protocol (IPv4: 0x0800, IPv6: 0x86DD, ARP: 0x0806).

4. **L3 Layer**: The IP subsystem validates the header, consults the routing table and decides: is the packet destined locally (INPUT) or does it require forwarding (FORWARD)?

5. **Netfilter hooks**: At each decision point, netfilter hooks allow inspection and modification (NAT, filtering, marking).

6. **L4 Layer**: TCP or UDP demultiplexes based on destination port, identifying the associated socket.

7. **Socket buffer**: Data is copied to the socket's receive queue, and the application is notified (via select/poll/epoll or read unblocking).

---

### 2. Network Interface Configuration

Linux exposes network configuration through two mechanisms: traditional utilities (ifconfig, route, netstat) and the modern iproute2 suite (ip, ss). The official recommendation favours iproute2 due to its extended functionality and consistent syntax.

#### 2.1. The `ip` Command — Universal Tool

```bash
# Display interfaces and addresses
ip addr show                      # or: ip a
ip link show                      # link state only

# Enable/disable interface
ip link set eth0 up
ip link set eth0 down

# Configure IPv4 address
ip addr add 192.168.1.100/24 dev eth0
ip addr del 192.168.1.100/24 dev eth0

# Configure IPv6 address
ip -6 addr add 2001:db8::1/64 dev eth0

# Configure MTU (Maximum Transmission Unit)
ip link set eth0 mtu 9000         # Jumbo frames

# Display detailed statistics
ip -s link show eth0
```

#### 2.2. Routing Tables

The routing table determines the path packets follow to reach their destination. The kernel maintains the FIB (Forwarding Information Base) structure optimised for fast lookups.

```bash
# Display routing table
ip route show                     # or: ip r

# Typical structure:
# default via 192.168.1.1 dev eth0 proto dhcp metric 100
# 192.168.1.0/24 dev eth0 proto kernel scope link src 192.168.1.100
# 172.17.0.0/16 dev docker0 proto kernel scope link src 172.17.0.1

# Add static route
ip route add 10.0.0.0/8 via 192.168.1.254

# Add route for a specific host
ip route add 8.8.8.8/32 via 192.168.1.1

# Delete route
ip route del 10.0.0.0/8

# Display route for a specific destination
ip route get 8.8.8.8
```

**Essential concepts:**
- **Default gateway**: Route used when no other rule matches
- **Metric**: Route priority; lower values indicate higher preference
- **Scope**: link (directly connected destination), global (accessible via routing)
- **Proto**: Source of routing information (kernel, static, dhcp, bgp)

---

### 3. Name Resolution and DNS

The operating system abstracts name resolution through the standard C library (glibc or musl), which consults the configuration in `/etc/nsswitch.conf` to determine the source order.

```bash
# Manual resolution
host google.com
dig google.com
nslookup google.com

# Specific query for MX records
dig google.com MX

# Query with specific DNS server
dig @8.8.8.8 google.com

# Check local DNS configuration
cat /etc/resolv.conf

# Local DNS cache (systemd-resolved)
resolvectl status
resolvectl query google.com
```

**Critical configuration files:**

| File | Purpose |
|------|---------|
| `/etc/resolv.conf` | DNS servers used |
| `/etc/hosts` | Static name ↔ IP mappings |
| `/etc/nsswitch.conf` | Resolution source order |
| `/etc/hostname` | Local host name |

---

### 4. Diagnostic Tools

Troubleshooting network problems requires specialised tools for each layer of the TCP/IP model.

#### 4.1. Connectivity Check (L3)

```bash
# ICMP echo test
ping -c 4 8.8.8.8                 # IPv4
ping6 -c 4 2001:4860:4860::8888   # IPv6

# Advanced options
ping -i 0.2 -c 100 192.168.1.1   # 200ms interval, 100 packets
ping -s 1400 -M do 192.168.1.1   # MTU check (do not fragment)
```

#### 4.2. Route Tracing (L3)

```bash
# Identify intermediate hops
traceroute 8.8.8.8
traceroute -I 8.8.8.8             # Use ICMP instead of UDP
traceroute -T -p 443 google.com  # TCP on port 443

# Modern variant (faster)
mtr -r -c 10 8.8.8.8
```

#### 4.3. Socket and Connection Investigation (L4)

The `ss` command (socket statistics) replaces `netstat` with superior performance.

```bash
# All TCP connections
ss -t -a

# Listening sockets
ss -l -t -n                       # -n avoids DNS resolution

# Established TCP connections
ss -t state established

# Display associated process
ss -t -p                          # requires root privileges

# Summary statistics
ss -s

# Filter by port
ss -t '( dport = :443 or sport = :443 )'

# Filter by address
ss -t dst 8.8.8.8
```

**Critical output columns:**
- **State**: ESTABLISHED, LISTEN, TIME-WAIT, CLOSE-WAIT, SYN-SENT
- **Recv-Q**: Bytes in receive queue (not buffered by application)
- **Send-Q**: Bytes in transmit queue (unacknowledged)
- **Local Address:Port**: Local endpoint
- **Peer Address:Port**: Remote endpoint

#### 4.4. Traffic Capture and Analysis

```bash
# Capture on specific interface
tcpdump -i eth0

# Filter by port
tcpdump -i eth0 port 80

# Filter by host
tcpdump -i eth0 host 192.168.1.100

# Save to file for later analysis
tcpdump -i eth0 -w capture.pcap

# Display ASCII content
tcpdump -i eth0 -A port 80

# Complex expressions
tcpdump -i eth0 'tcp port 80 and (((ip[2:2] - ((ip[0]&0xf)<<2)) - ((tcp[12]&0xf0)>>2)) != 0)'
```

#### 4.5. Arbitrary Connectivity Testing with Netcat

Netcat (nc) functions as a "Swiss army knife" for networking, allowing ad-hoc TCP/UDP connections.

```bash
# TCP client
nc -v google.com 80
GET / HTTP/1.1
Host: google.com

# Simple TCP server (listens on port)
nc -l -p 8080

# File transfer
# On receiver: nc -l -p 9999 > received_file
# On sender: nc receiver 9999 < file_to_send

# Port scanning (basic)
nc -z -v 192.168.1.1 20-25

# UDP connection
nc -u -v 8.8.8.8 53
```

---

### 5. BSD Socket Model

The BSD socket API, standardised through POSIX, provides the programmatic interface for network communications. It abstracts protocol details, exposing intuitive operations: create socket, bind address, connect, transmit, receive.

#### 5.1. Socket Anatomy

```
┌─────────────────────────────────────────────────────────────────┐
│                      SOCKET DESCRIPTOR                          │
│                                                                 │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐         │
│  │   Family    │    │    Type     │    │  Protocol   │         │
│  │  AF_INET    │    │ SOCK_STREAM │    │  IPPROTO_TCP│         │
│  │  AF_INET6   │    │ SOCK_DGRAM  │    │  IPPROTO_UDP│         │
│  │  AF_UNIX    │    │ SOCK_RAW    │    │      0      │         │
│  └─────────────┘    └─────────────┘    └─────────────┘         │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │                   ADDRESS STRUCTURES                     │   │
│  │                                                          │   │
│  │  struct sockaddr_in {                                    │   │
│  │      sa_family_t    sin_family;   // AF_INET             │   │
│  │      in_port_t      sin_port;     // Port (network order)│   │
│  │      struct in_addr sin_addr;     // IPv4 address        │   │
│  │  };                                                      │   │
│  │                                                          │   │
│  │  struct sockaddr_in6 {                                   │   │
│  │      sa_family_t     sin6_family; // AF_INET6            │   │
│  │      in_port_t       sin6_port;   // Port                │   │
│  │      uint32_t        sin6_flowinfo;                      │   │
│  │      struct in6_addr sin6_addr;   // IPv6 address        │   │
│  │      uint32_t        sin6_scope_id;                      │   │
│  │  };                                                      │   │
│  └─────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

#### 5.2. TCP Operations Flow

```
        SERVER                              CLIENT
           │                                   │
    socket()                            socket()
           │                                   │
      bind()                                   │
           │                                   │
    listen()                                   │
           │                                   │
           │◄──────── TCP 3-way ──────────connect()
           │          handshake                │
    accept()                                   │
           │                                   │
           │◄─────────────────────────────write()
      read()                                   │
           │                                   │
     write()─────────────────────────────►     │
           │                                  read()
           │                                   │
     close()◄──────── TCP 4-way ──────────close()
           │          termination              │
```

#### 5.3. Example: Echo Server in Python

```python
#!/usr/bin/env python3
"""
TCP echo server - demonstrates the BSD socket model.
Receives messages from clients and returns them identically.
"""

import socket
import sys

def echo_server(host: str = '0.0.0.0', port: int = 9000) -> None:
    """
    TCP server implementation with sequential connection handling.
    
    Args:
        host: Listening address (0.0.0.0 = all interfaces)
        port: Listening port
    """
    # Create TCP socket (SOCK_STREAM)
    # AF_INET specifies the IPv4 address family
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as server_socket:
        # SO_REUSEADDR allows immediate port reuse after closing
        # Avoids "Address already in use" error during development
        server_socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        
        # Bind socket to address and port
        server_socket.bind((host, port))
        
        # Enable listening mode; backlog=5 specifies the queue length
        # for connections awaiting accept()
        server_socket.listen(5)
        
        print(f"[INFO] Server active on {host}:{port}")
        print(f"[INFO] Press Ctrl+C to stop")
        
        while True:
            try:
                # accept() blocks until a connection arrives
                # Returns a new socket for communication and the client address
                client_socket, client_addr = server_socket.accept()
                
                with client_socket:
                    print(f"[CONN] Connection from {client_addr[0]}:{client_addr[1]}")
                    
                    while True:
                        # Receive data; buffer size = 4096 bytes
                        data = client_socket.recv(4096)
                        
                        if not data:
                            # Connection closed by client
                            print(f"[DISC] {client_addr[0]}:{client_addr[1]} disconnected")
                            break
                        
                        # Decode and display
                        message = data.decode('utf-8', errors='replace')
                        print(f"[RECV] {client_addr[0]}: {message.strip()}")
                        
                        # Echo: retransmit received data
                        client_socket.sendall(data)
                        print(f"[SEND] Echo sent")
                        
            except KeyboardInterrupt:
                print("\n[INFO] Server stopped by user")
                sys.exit(0)

if __name__ == '__main__':
    echo_server()
```

#### 5.4. Example: Client in Python

```python
#!/usr/bin/env python3
"""
TCP client for testing the echo server.
"""

import socket

def echo_client(host: str = '127.0.0.1', port: int = 9000) -> None:
    """Connect to server and send interactive messages."""
    
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as sock:
        try:
            sock.connect((host, port))
            print(f"[INFO] Connected to {host}:{port}")
            
            while True:
                message = input("Message (quit to exit): ")
                
                if message.lower() == 'quit':
                    break
                
                sock.sendall(message.encode('utf-8'))
                response = sock.recv(4096)
                print(f"[ECHO] {response.decode('utf-8')}")
                
        except ConnectionRefusedError:
            print(f"[ERR] Could not connect to {host}:{port}")
        except KeyboardInterrupt:
            print("\n[INFO] Client stopped")

if __name__ == '__main__':
    echo_client()
```

---

### 6. Packet Filtering with Netfilter

Netfilter constitutes the Linux kernel framework for packet inspection and manipulation. It provides hooks in the processing path, allowing modules (iptables, nftables, conntrack) to intercept traffic.

#### 6.1. Hook Architecture

```
                                    EXTERNAL NETWORK
                                          │
                                          ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                            PREROUTING                                    │
│                   (destination NAT, mangle)                              │
└─────────────────────────────────┬───────────────────────────────────────┘
                                  │
                    ┌─────────────┴─────────────┐
                    │      ROUTING DECISION     │
                    │   Packet destined for me? │
                    └─────────────┬─────────────┘
                                  │
              ┌───────────────────┼───────────────────┐
              │ YES               │                   │ NO
              ▼                   │                   ▼
┌─────────────────────┐          │          ┌─────────────────────┐
│       INPUT         │          │          │      FORWARD        │
│  (ingress filtering)│          │          │ (transit filtering) │
└──────────┬──────────┘          │          └──────────┬──────────┘
           │                     │                     │
           ▼                     │                     │
┌─────────────────────┐          │                     │
│  LOCAL PROCESSES    │          │                     │
│  (applications)     │          │                     │
└──────────┬──────────┘          │                     │
           │                     │                     │
           ▼                     │                     │
┌─────────────────────┐          │                     │
│      OUTPUT         │          │                     │
│ (egress filtering   │          │                     │
│  for locally        │          │                     │
│  generated traffic) │          │                     │
└──────────┬──────────┘          │                     │
           │                     │                     │
           └─────────────────────┴─────────────────────┘
                                  │
                                  ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                           POSTROUTING                                    │
│                    (source NAT, masquerade)                              │
└─────────────────────────────────┬───────────────────────────────────────┘
                                  │
                                  ▼
                            EXTERNAL NETWORK
```

#### 6.2. Fundamental iptables Commands

```bash
# Display rules with line numbers
iptables -L -n -v --line-numbers

# Default policy (DROP all packets not explicitly accepted)
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

# Allow loopback interface traffic
iptables -A INPUT -i lo -j ACCEPT

# Allow already established connections
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# Allow SSH (port 22) only from specific subnet
iptables -A INPUT -p tcp --dport 22 -s 192.168.1.0/24 -j ACCEPT

# Allow HTTP/HTTPS
iptables -A INPUT -p tcp --dport 80 -j ACCEPT
iptables -A INPUT -p tcp --dport 443 -j ACCEPT

# Block specific address
iptables -A INPUT -s 10.20.30.40 -j DROP

# Logging for blocked packets (for debugging)
iptables -A INPUT -j LOG --log-prefix "IPT_DROP: " --log-level 4
iptables -A INPUT -j DROP

# Delete rule by number
iptables -D INPUT 3

# Flush all rules
iptables -F

# Save rules (Debian/Ubuntu)
iptables-save > /etc/iptables/rules.v4

# Restore rules
iptables-restore < /etc/iptables/rules.v4
```

#### 6.3. Migration to nftables

nftables represents the modern successor to iptables, offering unified syntax and improved performance.

```bash
# List rule sets
nft list ruleset

# Create table and chain
nft add table inet filter
nft add chain inet filter input { type filter hook input priority 0 \; policy drop \; }

# Add rules
nft add rule inet filter input ct state established,related accept
nft add rule inet filter input tcp dport 22 accept
nft add rule inet filter input tcp dport { 80, 443 } accept

# Display formatted
nft list chain inet filter input
```

---

### 7. Network Namespaces — Network Isolation

Network namespaces allow creating isolated network stacks, each with its own interfaces, routing tables and firewall rules. This mechanism underlies containerisation.

```bash
# Create namespace
ip netns add ns_test

# List namespaces
ip netns list

# Execute command in namespace
ip netns exec ns_test ip addr show

# Create veth pair (virtual ethernet)
ip link add veth0 type veth peer name veth1

# Move one end to namespace
ip link set veth1 netns ns_test

# Configure in default namespace
ip addr add 192.168.100.1/24 dev veth0
ip link set veth0 up

# Configure in isolated namespace
ip netns exec ns_test ip addr add 192.168.100.2/24 dev veth1
ip netns exec ns_test ip link set veth1 up
ip netns exec ns_test ip link set lo up

# Test connectivity
ping -c 2 192.168.100.2
ip netns exec ns_test ping -c 2 192.168.100.1

# Delete namespace
ip netns delete ns_test
```

---

## Laboratory/Seminar — Practical Exercises

### Exercise 1: Complete Diagnostics

Investigate connectivity to an external server using the tools presented:

```bash
# 1. Verify DNS resolution
dig google.com +short

# 2. Test ICMP connectivity
ping -c 4 google.com

# 3. Trace route
traceroute -I google.com

# 4. Check active connections
ss -t state established

# 5. Capture DNS traffic
sudo tcpdump -i any port 53 -c 10
```

### Exercise 2: Server and Client

1. Run the echo server from the `scripts/` directory
2. In another terminal, connect with the client or with netcat
3. Observe the created sockets: `ss -t -p | grep 9000`

### Exercise 3: Basic Firewall Configuration

Implement a minimal set of iptables rules that allow only:
- Loopback traffic
- SSH connections from the local network
- Responses to locally initiated connections
- Logging and blocking of everything else

---

## Visual Recap

```
┌─────────────────────────────────────────────────────────────────────────┐
│                    NETWORKING IN OPERATING SYSTEMS                       │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  CONFIGURATION            DIAGNOSTICS            PROGRAMMING            │
│  ─────────────            ───────────            ───────────            │
│  ip addr/link             ping/traceroute         socket()              │
│  ip route                 ss/netstat              bind()/listen()       │
│  /etc/resolv.conf        tcpdump                 accept()/connect()    │
│  /etc/hosts              dig/host                send()/recv()         │
│                                                                         │
│  FILTERING                ISOLATION                                     │
│  ─────────                ─────────                                     │
│  iptables/nftables        ip netns (namespaces)                        │
│  netfilter hooks          veth pairs                                    │
│  conntrack                foundation for containers                     │
│                                                                         │
├─────────────────────────────────────────────────────────────────────────┤
│  Recommended reading:                                                   │
│  • OSTEP, Chapter "Distributed Systems" (introduction)                 │
│  • Tanenbaum, "Computer Networks", Chapters 1-5                        │
│  • Stevens, "Unix Network Programming", Volume 1                        │
│  • Linux man pages: ip(8), ss(8), iptables(8), socket(7)               │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## Command Summary

| Category | Command | Purpose |
|----------|---------|---------|
| Interfaces | `ip addr show` | List IP addresses |
| | `ip link set eth0 up/down` | Enable/disable |
| Routing | `ip route show` | Display routing table |
| | `ip route add` | Add static route |
| DNS | `dig`, `host`, `nslookup` | Name resolution |
| Diagnostics | `ping`, `traceroute`, `mtr` | Connectivity test |
| | `ss -t`, `ss -l` | Socket state |
| | `tcpdump -i eth0` | Traffic capture |
| | `nc -v host port` | Ad-hoc connection |
| Firewall | `iptables -L` | List rules |
| | `nft list ruleset` | nftables rules |
| Namespaces | `ip netns add/exec/del` | Network isolation |

---

## Included Scripts

| File | Language | Description |
|------|----------|-------------|
| `scripts/echo_server.py` | Python | Demonstrative TCP echo server |
| `scripts/echo_client.py` | Python | TCP client for testing |
| `scripts/network_diag.sh` | Bash | Complete diagnostic script |
| `scripts/firewall_basic.sh` | Bash | iptables configuration template |


---

## Self-Assessment

### Review Questions

1. **[REMEMBER]** What is a socket? List the 5 steps for creating a TCP connection (server-side).
2. **[UNDERSTAND]** Explain the difference between TCP and UDP. In what situations would you choose each protocol?
3. **[ANALYSE]** Analyse the client-server model. What happens if the server does not call `accept()` and the connection queue fills up?

### Mini-Challenge (optional)

Modify echo_server.py to handle multiple simultaneous connections using threads or `select()`.

---


---


---

## Recommended Reading

### Required Resources

**Beej's Guide to Network Programming**
- [Sections 1-6](https://beej.us/guide/bgnet/) — Complete socket API guide
- The best practical tutorial for C socket programming

**OSTEP (if available)**
- Chapter 48: Distributed Systems — context for network communication

### Recommended Resources

**Stevens - UNIX Network Programming, Vol. 1**
- Chapter 4: Elementary TCP Sockets (pp. 85-120)
- Chapter 5: TCP Client/Server Example
- The classic reference for network programming

**Linux man pages** (available locally with `man`)
```bash
man 2 socket      # System call for socket creation
man 2 bind        # Associate socket with address
man 2 listen      # Mark socket as passive
man 2 accept      # Accept connection
man 2 connect     # Initiate connection (client)
man 7 tcp         # TCP protocol in Linux
man 7 ip          # IP protocol
man 7 socket      # General socket interface
```

### Video Resources

- **MIT 6.033** - Computer System Engineering (Networking section)
- **Brian "Beej" Hall** - Network Programming Tutorials (YouTube)

### Technical Articles

- [The C10K Problem](http://www.kegel.com/c10k.html) — Why threads per connection do not scale
- [Epoll Tutorial](https://copyconstruct.medium.com/the-method-to-epolls-madness-d9d2d6378642) — Modern I/O multiplexing


---

## Nuances and Special Cases

### What We Did NOT Cover (didactic limitations)

- **io_uring for networking**: Modern alternative to epoll with superior performance.
- **QUIC protocol**: UDP-based transport layer (HTTP/3) that avoids head-of-line blocking.
- **eBPF XDP (eXpress Data Path)**: Kernel bypass packet processing for extreme performance.

### Common Mistakes to Avoid

1. **Blocking I/O with many clients**: Use select/poll/epoll or threads for scalability.
2. **Ignoring partial writes/reads**: `send()` and `recv()` may transfer less than requested.
3. **Hardcoding IPs**: Use DNS and configuration for portability.

### Open Questions

- Will QUIC completely replace TCP for interactive applications?
- How will networking APIs evolve for 100Gbps+ and RDMA?

## Looking Ahead

**Optional Continuation: C16supp — Advanced Containerisation**

If you have understood the socket API and network communication, the natural next step is advanced containerisation. You will see how Docker uses namespaces for network isolation and cgroups for resource limiting.

**Recommended preparation:**
- Install Docker and run your first container: `docker run hello-world`
- Experiment with `docker network ls` and `docker network inspect`

## Visual Summary

```
┌─────────────────────────────────────────────────────────────────┐
│                    WEEK 15: NETWORKING — RECAP                   │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  SOCKET = Endpoint for network communication                   │
│                                                                 │
│  CLIENT-SERVER MODEL                                            │
│  ├── SERVER: socket() → bind() → listen() → accept() → r/w    │
│  └── CLIENT: socket() → connect() → read/write                 │
│                                                                 │
│  TCP vs UDP                                                     │
│  ├── TCP: connection-oriented, reliable, ordered               │
│  └── UDP: connectionless, best-effort, fast                    │
│                                                                 │
│  ADDRESSING                                                     │
│  ├── IP Address: identifies the host in the network            │
│  ├── Port: identifies the application on the host              │
│  └── Socket = (IP, Port, Protocol)                             │
│                                                                 │
│  USEFUL COMMANDS                                                │
│  ├── netstat/ss: active connections                            │
│  ├── ping: connectivity testing                                │
│  └── tcpdump/wireshark: packet capture                         │
│                                                                 │
│  💡 TAKEAWAY: Everything is a socket — web, email, streaming   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

*Materials developed by Revolvix for ASE Bucharest - CSIE*  
*Operating Systems | Year I, Semester 2 | 2025-2026*

---
