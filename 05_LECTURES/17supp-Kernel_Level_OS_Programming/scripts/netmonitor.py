#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
netmonitor.py - Network connection monitoring with BCC/eBPF

Description:
    A network connection monitoring script for TCP/UDP using
    eBPF technology. Displays new connections, closed connections,
    retransmissions and aggregated statistics in real time.

Features:
    • TCP outbound connection monitoring (connect)
    • TCP inbound connection monitoring (accept)
    • TCP retransmission detection
    • Aggregated statistics per process
    • Optional JSON export

Usage:
    sudo python3 netmonitor.py              # Monitor all processes
    sudo python3 netmonitor.py -p 1234      # Filter by PID
    sudo python3 netmonitor.py -d 60        # Run for 60 seconds
    sudo python3 netmonitor.py --json       # Export JSON statistics at the end

Requirements:
    • Python 3.6+
    • BCC (apt install bpfcc-tools python3-bcc)
    • Linux kernel 4.9+ (recommended 5.x+)
    • Root privileges

Author: OS Course - ASE Bucharest CSIE
Version: 1.0
"""

from __future__ import print_function
from bcc import BPF
from time import sleep, strftime
from socket import inet_ntop, AF_INET, AF_INET6
from struct import pack
import argparse
import signal
import sys
import json
from collections import defaultdict

# ═══════════════════════════════════════════════════════════════════════════
# eBPF PROGRAM (RESTRICTED C)
# ═══════════════════════════════════════════════════════════════════════════

bpf_program = """
#include <uapi/linux/ptrace.h>
#include <net/sock.h>
#include <bcc/proto.h>
#include <linux/tcp.h>

// Structure for events sent to user space
struct event_t {
    u64 ts_ns;          // Timestamp nanoseconds
    u32 pid;            // Process ID
    u32 tid;            // Thread ID
    u32 uid;            // User ID
    u32 saddr;          // Source address (IPv4)
    u32 daddr;          // Destination address (IPv4)
    u16 sport;          // Source port
    u16 dport;          // Destination port
    u8 event_type;      // 1=connect, 2=accept, 3=close, 4=retrans
    char comm[16];      // Process name
};

// Event types
#define EVENT_CONNECT   1
#define EVENT_ACCEPT    2
#define EVENT_CLOSE     3
#define EVENT_RETRANS   4

// Buffer for events to user space
BPF_PERF_OUTPUT(events);

// Map for tracking sockets in progress of connecting
BPF_HASH(currsock, u32, struct sock *);

// Map for per-process statistics
BPF_HASH(connect_count, u32, u64);
BPF_HASH(accept_count, u32, u64);
BPF_HASH(bytes_sent, u32, u64);
BPF_HASH(bytes_recv, u32, u64);

// ════════════════════════════════════════════════════════════════════════
// TCP CONNECT TRACING
// ════════════════════════════════════════════════════════════════════════

// Entry into tcp_v4_connect
int trace_connect_entry(struct pt_regs *ctx, struct sock *sk) {
    u32 tid = bpf_get_current_pid_tgid();
    
    // PID filter (replaced at runtime)
    FILTER_PID
    
    // Save socket for lookup at return
    currsock.update(&tid, &sk);
    return 0;
}

// Exit from tcp_v4_connect
int trace_connect_return(struct pt_regs *ctx) {
    int ret = PT_REGS_RC(ctx);
    u64 pid_tgid = bpf_get_current_pid_tgid();
    u32 tid = (u32)pid_tgid;
    u32 pid = pid_tgid >> 32;
    
    // Lookup saved socket
    struct sock **skpp = currsock.lookup(&tid);
    if (!skpp) return 0;
    
    // Ignore if connect failed (other than EINPROGRESS)
    if (ret != 0 && ret != -EINPROGRESS) {
        currsock.delete(&tid);
        return 0;
    }
    
    struct sock *sk = *skpp;
    currsock.delete(&tid);
    
    // Extract connection information
    u16 sport = 0;
    u16 dport = sk->__sk_common.skc_dport;
    u32 saddr = sk->__sk_common.skc_rcv_saddr;
    u32 daddr = sk->__sk_common.skc_daddr;
    
    dport = ntohs(dport);
    
    // Create event
    struct event_t event = {};
    event.ts_ns = bpf_ktime_get_ns();
    event.pid = pid;
    event.tid = tid;
    event.uid = bpf_get_current_uid_gid() & 0xFFFFFFFF;
    event.saddr = saddr;
    event.daddr = daddr;
    event.sport = sport;
    event.dport = dport;
    event.event_type = EVENT_CONNECT;
    bpf_get_current_comm(&event.comm, sizeof(event.comm));
    
    // Submit event
    events.perf_submit(ctx, &event, sizeof(event));
    
    // Update statistics
    u64 *count = connect_count.lookup(&pid);
    if (count) {
        (*count)++;
    } else {
        u64 init = 1;
        connect_count.update(&pid, &init);
    }
    
    return 0;
}

// ════════════════════════════════════════════════════════════════════════
// TCP ACCEPT TRACING
// ════════════════════════════════════════════════════════════════════════

int trace_accept_return(struct pt_regs *ctx) {
    struct sock *sk = (struct sock *)PT_REGS_RC(ctx);
    if (!sk) return 0;
    
    u64 pid_tgid = bpf_get_current_pid_tgid();
    u32 pid = pid_tgid >> 32;
    
    // PID filter
    FILTER_PID
    
    // Extract information
    u16 sport = sk->__sk_common.skc_num;
    u16 dport = sk->__sk_common.skc_dport;
    u32 saddr = sk->__sk_common.skc_rcv_saddr;
    u32 daddr = sk->__sk_common.skc_daddr;
    
    dport = ntohs(dport);
    
    // Create event
    struct event_t event = {};
    event.ts_ns = bpf_ktime_get_ns();
    event.pid = pid;
    event.tid = (u32)pid_tgid;
    event.uid = bpf_get_current_uid_gid() & 0xFFFFFFFF;
    event.saddr = saddr;
    event.daddr = daddr;
    event.sport = sport;
    event.dport = dport;
    event.event_type = EVENT_ACCEPT;
    bpf_get_current_comm(&event.comm, sizeof(event.comm));
    
    events.perf_submit(ctx, &event, sizeof(event));
    
    // Update statistics
    u64 *count = accept_count.lookup(&pid);
    if (count) {
        (*count)++;
    } else {
        u64 init = 1;
        accept_count.update(&pid, &init);
    }
    
    return 0;
}

// ════════════════════════════════════════════════════════════════════════
// TCP RETRANSMIT TRACING
// ════════════════════════════════════════════════════════════════════════

TRACEPOINT_PROBE(tcp, tcp_retransmit_skb) {
    u64 pid_tgid = bpf_get_current_pid_tgid();
    u32 pid = pid_tgid >> 32;
    
    // PID filter
    FILTER_PID
    
    // Extract from tracepoint arguments
    // args->saddr, args->daddr, etc. available in modern tracepoints
    struct sock *sk = (struct sock *)args->skaddr;
    
    struct event_t event = {};
    event.ts_ns = bpf_ktime_get_ns();
    event.pid = pid;
    event.event_type = EVENT_RETRANS;
    event.sport = args->sport;
    event.dport = args->dport;
    event.saddr = args->saddr;
    event.daddr = args->daddr;
    bpf_get_current_comm(&event.comm, sizeof(event.comm));
    
    events.perf_submit(args, &event, sizeof(event));
    
    return 0;
}

// ════════════════════════════════════════════════════════════════════════
// TCP CLOSE TRACING
// ════════════════════════════════════════════════════════════════════════

int trace_tcp_close(struct pt_regs *ctx, struct sock *sk) {
    u64 pid_tgid = bpf_get_current_pid_tgid();
    u32 pid = pid_tgid >> 32;
    
    // PID filter
    FILTER_PID
    
    // Verify valid socket
    u8 state = sk->__sk_common.skc_state;
    if (state == TCP_TIME_WAIT) return 0;
    
    // Extract information
    u16 sport = sk->__sk_common.skc_num;
    u16 dport = sk->__sk_common.skc_dport;
    u32 saddr = sk->__sk_common.skc_rcv_saddr;
    u32 daddr = sk->__sk_common.skc_daddr;
    
    dport = ntohs(dport);
    
    struct event_t event = {};
    event.ts_ns = bpf_ktime_get_ns();
    event.pid = pid;
    event.event_type = EVENT_CLOSE;
    event.saddr = saddr;
    event.daddr = daddr;
    event.sport = sport;
    event.dport = dport;
    bpf_get_current_comm(&event.comm, sizeof(event.comm));
    
    events.perf_submit(ctx, &event, sizeof(event));
    
    return 0;
}
"""

# ═══════════════════════════════════════════════════════════════════════════
# HELPER FUNCTIONS
# ═══════════════════════════════════════════════════════════════════════════

def ip_to_str(addr):
    """Convert IP address from numeric format to string."""
    return inet_ntop(AF_INET, pack("I", addr))

def event_type_str(event_type):
    """Return the event type name."""
    types = {
        1: "CONNECT",
        2: "ACCEPT",
        3: "CLOSE",
        4: "RETRANS"
    }
    return types.get(event_type, "UNKNOWN")

def event_type_color(event_type):
    """Return the ANSI colour code for the event type."""
    colors = {
        1: "\033[92m",   # Green - CONNECT
        2: "\033[94m",   # Blue - ACCEPT
        3: "\033[93m",   # Yellow - CLOSE
        4: "\033[91m"    # Red - RETRANS
    }
    return colors.get(event_type, "\033[0m")

# ═══════════════════════════════════════════════════════════════════════════
# MAIN MONITORING CLASS
# ═══════════════════════════════════════════════════════════════════════════

class NetworkMonitor:
    """
    Class for monitoring network traffic using eBPF.
    """
    
    def __init__(self, pid=None, json_output=False):
        """
        Initialise the monitor.
        
        Args:
            pid: Optional, the PID of the process to monitor
            json_output: If True, export JSON statistics at the end
        """
        self.pid = pid
        self.json_output = json_output
        self.running = True
        self.events = []
        self.stats = defaultdict(lambda: defaultdict(int))
        
        # Prepare BPF program
        program = bpf_program
        if pid:
            program = program.replace("FILTER_PID", 
                f"if (pid != {pid}) return 0;")
        else:
            program = program.replace("FILTER_PID", "")
        
        # Compile and load
        print("[*] Compiling eBPF program...")
        self.bpf = BPF(text=program)
        
        # Attach to probes
        print("[*] Attaching probes...")
        self.bpf.attach_kprobe(event="tcp_v4_connect", 
                               fn_name="trace_connect_entry")
        self.bpf.attach_kretprobe(event="tcp_v4_connect", 
                                  fn_name="trace_connect_return")
        self.bpf.attach_kretprobe(event="inet_csk_accept", 
                                  fn_name="trace_accept_return")
        self.bpf.attach_kprobe(event="tcp_close", 
                               fn_name="trace_tcp_close")
        
        print("[*] Monitoring active. Press Ctrl+C to stop.\n")
    
    def print_event(self, cpu, data, size):
        """Callback for processing events."""
        event = self.bpf["events"].event(data)
        
        timestamp = strftime("%H:%M:%S")
        event_type = event_type_str(event.event_type)
        color = event_type_color(event.event_type)
        reset = "\033[0m"
        
        comm = event.comm.decode('utf-8', 'replace')
        saddr = ip_to_str(event.saddr)
        daddr = ip_to_str(event.daddr)
        
        # Formatted output
        print(f"{timestamp} {color}{event_type:8s}{reset} "
              f"{comm:16s} {event.pid:<7d} "
              f"{saddr}:{event.sport} -> {daddr}:{event.dport}")
        
        # Save for statistics
        self.stats[comm]["connects"] += 1 if event.event_type == 1 else 0
        self.stats[comm]["accepts"] += 1 if event.event_type == 2 else 0
        self.stats[comm]["closes"] += 1 if event.event_type == 3 else 0
        self.stats[comm]["retrans"] += 1 if event.event_type == 4 else 0
        
        if self.json_output:
            self.events.append({
                "timestamp": timestamp,
                "type": event_type,
                "process": comm,
                "pid": event.pid,
                "src": f"{saddr}:{event.sport}",
                "dst": f"{daddr}:{event.dport}"
            })
    
    def run(self, duration=None):
        """
        Run the monitoring.
        
        Args:
            duration: Optional, duration in seconds (None = infinite)
        """
        # Header
        print(f"{'TIME':8s} {'TYPE':8s} {'PROCESS':16s} {'PID':7s} "
              f"{'CONNECTION':40s}")
        print("─" * 80)
        
        # Open perf buffer
        self.bpf["events"].open_perf_buffer(self.print_event)
        
        elapsed = 0
        try:
            while self.running:
                self.bpf.perf_buffer_poll(timeout=1000)  # 1 second
                elapsed += 1
                if duration and elapsed >= duration:
                    break
        except KeyboardInterrupt:
            pass
        
        self.print_summary()
    
    def print_summary(self):
        """Display the final summary."""
        print("\n")
        print("═" * 80)
        print(" " * 30 + "FINAL SUMMARY")
        print("═" * 80)
        
        # Statistics table
        print(f"\n{'PROCESS':<20s} {'CONNECT':>10s} {'ACCEPT':>10s} "
              f"{'CLOSE':>10s} {'RETRANS':>10s}")
        print("─" * 60)
        
        for proc, data in sorted(self.stats.items(), 
                                 key=lambda x: sum(x[1].values()), 
                                 reverse=True):
            print(f"{proc:<20s} {data['connects']:>10d} {data['accepts']:>10d} "
                  f"{data['closes']:>10d} {data['retrans']:>10d}")
        
        # Totals
        total_conn = sum(d["connects"] for d in self.stats.values())
        total_acc = sum(d["accepts"] for d in self.stats.values())
        total_close = sum(d["closes"] for d in self.stats.values())
        total_retr = sum(d["retrans"] for d in self.stats.values())
        
        print("─" * 60)
        print(f"{'TOTAL':<20s} {total_conn:>10d} {total_acc:>10d} "
              f"{total_close:>10d} {total_retr:>10d}")
        
        # Export JSON if requested
        if self.json_output:
            output = {
                "summary": dict(self.stats),
                "events": self.events
            }
            filename = f"netmonitor_{strftime('%Y%m%d_%H%M%S')}.json"
            with open(filename, 'w') as f:
                json.dump(output, f, indent=2)
            print(f"\n[*] Statistics exported to: {filename}")
        
        print("\n" + "═" * 80)
        print("Monitoring completed.")
    
    def stop(self):
        """Stop the monitoring."""
        self.running = False


# ═══════════════════════════════════════════════════════════════════════════
# MAIN
# ═══════════════════════════════════════════════════════════════════════════

def main():
    """Main entry point."""
    
    # Command line arguments
    parser = argparse.ArgumentParser(
        description="Network connection monitoring with eBPF/BCC",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  sudo python3 netmonitor.py                 # All processes
  sudo python3 netmonitor.py -p $(pgrep nginx)  # Only nginx
  sudo python3 netmonitor.py -d 60 --json    # 60 seconds, JSON export
        """
    )
    parser.add_argument("-p", "--pid", type=int, default=None,
                        help="Filter by process PID")
    parser.add_argument("-d", "--duration", type=int, default=None,
                        help="Monitoring duration in seconds")
    parser.add_argument("--json", action="store_true",
                        help="Export statistics in JSON format")
    
    args = parser.parse_args()
    
    # Banner
    print("""
╔══════════════════════════════════════════════════════════════════════════════╗
║          NETWORK MONITOR - Network monitoring with eBPF/BCC                  ║
║                                                                              ║
║   Traces TCP connections: connect, accept, close, retransmit                 ║
║   Requirements: root, BCC installed, kernel 4.9+                             ║
╚══════════════════════════════════════════════════════════════════════════════╝
    """)
    
    # Root check
    import os
    if os.geteuid() != 0:
        print("[!] ERROR: This script requires root privileges.")
        print("    Run with: sudo python3 netmonitor.py")
        sys.exit(1)
    
    # Display configuration
    if args.pid:
        print(f"[*] Active filter for PID: {args.pid}")
    if args.duration:
        print(f"[*] Monitoring duration: {args.duration} seconds")
    
    # Create and run monitor
    monitor = NetworkMonitor(pid=args.pid, json_output=args.json)
    
    # Handler for SIGINT
    def signal_handler(sig, frame):
        monitor.stop()
    
    signal.signal(signal.SIGINT, signal_handler)
    signal.signal(signal.SIGTERM, signal_handler)
    
    # Run
    monitor.run(duration=args.duration)


if __name__ == "__main__":
    main()
