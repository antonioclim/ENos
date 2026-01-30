#!/usr/bin/env python3
"""
cgroup_monitor.py - Real-time cgroups v2 monitor
Operating Systems | ASE Bucharest - CSIE | 2025-2026

Illustrated concepts:
- cgroups v2 hierarchy structure
- Reading resource metrics (CPU, memory, I/O, PIDs)
- Real-time consumption visualisation

Usage:
    python3 cgroup_monitor.py                    # Monitor all groups
    python3 cgroup_monitor.py <cgroup_path>      # Monitor a specific group
    python3 cgroup_monitor.py --docker <id>      # Monitor a Docker container
"""

import os
import sys
import time
import argparse
from pathlib import Path
from typing import Dict, Optional, NamedTuple
from dataclasses import dataclass

# Base path for cgroups v2
CGROUP_BASE = Path("/sys/fs/cgroup")


@dataclass
class CgroupStats:
    """Structure for cgroup statistics."""
    path: str
    cpu_usage_usec: int = 0
    cpu_user_usec: int = 0
    cpu_system_usec: int = 0
    memory_current: int = 0
    memory_max: int = 0
    memory_swap: int = 0
    pids_current: int = 0
    pids_max: int = 0
    io_read_bytes: int = 0
    io_write_bytes: int = 0


class CgroupMonitor:
    """Monitor for cgroups v2."""
    
    def __init__(self, cgroup_path: Path):
        """
        Initialise the monitor.
        
        Args:
            cgroup_path: Path to the cgroup directory to monitor
        """
        self.cgroup_path = cgroup_path
        self.prev_cpu_usage = 0
        self.prev_time = time.time()
        
        # Check existence
        if not self.cgroup_path.exists():
            raise FileNotFoundError(f"Cgroup does not exist: {cgroup_path}")
        
        # Check for cgroups v2
        if not (CGROUP_BASE / "cgroup.controllers").exists():
            raise RuntimeError("The system is not using cgroups v2 (unified hierarchy)")
    
    def read_file(self, filename: str) -> str:
        """Read the contents of a file from the cgroup."""
        filepath = self.cgroup_path / filename
        try:
            return filepath.read_text().strip()
        except (FileNotFoundError, PermissionError):
            return ""
    
    def read_int(self, filename: str, default: int = 0) -> int:
        """Read an integer from a file."""
        content = self.read_file(filename)
        if not content or content == "max":
            return default
        try:
            return int(content)
        except ValueError:
            return default
    
    def parse_stat_file(self, filename: str) -> Dict[str, int]:
        """Parse a statistics file (key value format)."""
        result = {}
        content = self.read_file(filename)
        for line in content.split('\n'):
            if line:
                parts = line.split()
                if len(parts) >= 2:
                    try:
                        result[parts[0]] = int(parts[1])
                    except ValueError:
                        pass
        return result
    
    def get_stats(self) -> CgroupStats:
        """Collect all cgroup statistics."""
        stats = CgroupStats(path=str(self.cgroup_path))
        
        # CPU statistics
        cpu_stat = self.parse_stat_file("cpu.stat")
        stats.cpu_usage_usec = cpu_stat.get("usage_usec", 0)
        stats.cpu_user_usec = cpu_stat.get("user_usec", 0)
        stats.cpu_system_usec = cpu_stat.get("system_usec", 0)
        
        # Memory
        stats.memory_current = self.read_int("memory.current")
        stats.memory_max = self.read_int("memory.max", default=-1)
        stats.memory_swap = self.read_int("memory.swap.current")
        
        # PIDs
        stats.pids_current = self.read_int("pids.current")
        stats.pids_max = self.read_int("pids.max", default=-1)
        
        # I/O (aggregated from io.stat)
        io_stat = self.read_file("io.stat")
        for line in io_stat.split('\n'):
            if line:
                # Format: "8:0 rbytes=X wbytes=Y ..."
                parts = line.split()
                for part in parts:
                    if part.startswith("rbytes="):
                        stats.io_read_bytes += int(part.split('=')[1])
                    elif part.startswith("wbytes="):
                        stats.io_write_bytes += int(part.split('=')[1])
        
        return stats
    
    def get_cpu_percent(self, stats: CgroupStats) -> float:
        """Calculate CPU usage percentage."""
        current_time = time.time()
        time_delta = current_time - self.prev_time
        
        if time_delta > 0 and self.prev_cpu_usage > 0:
            cpu_delta = stats.cpu_usage_usec - self.prev_cpu_usage
            # Convert from microseconds to percentage
            cpu_percent = (cpu_delta / (time_delta * 1_000_000)) * 100
        else:
            cpu_percent = 0.0
        
        self.prev_cpu_usage = stats.cpu_usage_usec
        self.prev_time = current_time
        
        return min(cpu_percent, 100.0 * os.cpu_count())


def format_bytes(bytes_value: int) -> str:
    """Format bytes into human-readable units."""
    if bytes_value < 0:
        return "unlimited"
    
    for unit in ['B', 'KB', 'MB', 'GB', 'TB']:
        if bytes_value < 1024:
            return f"{bytes_value:.1f} {unit}"
        bytes_value /= 1024
    return f"{bytes_value:.1f} PB"


def format_percent(value: float, max_value: int) -> str:
    """Format value as a percentage of maximum."""
    if max_value <= 0:
        return "N/A"
    percent = (value / max_value) * 100
    return f"{percent:.1f}%"


def print_header():
    """Display the table header."""
    print("\033[2J\033[H", end="")  # Clear screen
    print("=" * 80)
    print(" CGROUP MONITOR - Real-time resource monitoring")
    print("=" * 80)
    print()


def print_stats(stats: CgroupStats, cpu_percent: float):
    """Display formatted statistics."""
    print(f"\033[4;0H", end="")  # Position cursor
    
    print(f" Cgroup: {stats.path}")
    print("-" * 80)
    print()
    
    # CPU
    print(" CPU:")
    print(f"   Current usage:      {cpu_percent:6.1f}%")
    print(f"   User time:          {stats.cpu_user_usec / 1_000_000:,.2f}s")
    print(f"   System time:        {stats.cpu_system_usec / 1_000_000:,.2f}s")
    print(f"   Total time:         {stats.cpu_usage_usec / 1_000_000:,.2f}s")
    print()
    
    # Memory
    print(" MEMORY:")
    mem_usage = format_bytes(stats.memory_current)
    mem_limit = format_bytes(stats.memory_max)
    mem_percent = format_percent(stats.memory_current, stats.memory_max) if stats.memory_max > 0 else "N/A"
    print(f"   Current usage:      {mem_usage:>12} ({mem_percent})")
    print(f"   Limit:              {mem_limit:>12}")
    print(f"   Swap:               {format_bytes(stats.memory_swap):>12}")
    print()
    
    # PIDs
    print(" PROCESSES:")
    pids_limit = str(stats.pids_max) if stats.pids_max > 0 else "unlimited"
    print(f"   Active processes:   {stats.pids_current:>12}")
    print(f"   Limit:              {pids_limit:>12}")
    print()
    
    # I/O
    print(" I/O:")
    print(f"   Bytes read:         {format_bytes(stats.io_read_bytes):>12}")
    print(f"   Bytes written:      {format_bytes(stats.io_write_bytes):>12}")
    print()
    
    print("-" * 80)
    print(" Press Ctrl+C to stop")


def find_docker_cgroup(container_id: str) -> Path:
    """Find the cgroup for a Docker container."""
    # Docker uses different structures depending on configuration
    patterns = [
        # systemd driver (default in recent versions)
        CGROUP_BASE / "system.slice" / f"docker-{container_id}.scope",
        # cgroupfs driver
        CGROUP_BASE / "docker" / container_id,
        # Variants with short ID
        CGROUP_BASE / "system.slice" / f"docker-{container_id[:12]}.scope",
    ]
    
    for pattern in patterns:
        if pattern.exists():
            return pattern
    
    # Recursive search for partial ID
    for path in CGROUP_BASE.rglob(f"*{container_id[:12]}*"):
        if path.is_dir():
            return path
    
    raise FileNotFoundError(f"Cgroup not found for container: {container_id}")


def list_cgroups():
    """List all active cgroups."""
    print("Available cgroups:")
    print("-" * 60)
    
    for cgroup_dir in sorted(CGROUP_BASE.rglob("*")):
        if cgroup_dir.is_dir():
            # Check if it has processes
            procs_file = cgroup_dir / "cgroup.procs"
            if procs_file.exists():
                try:
                    procs = procs_file.read_text().strip()
                    if procs:
                        relative_path = cgroup_dir.relative_to(CGROUP_BASE)
                        num_procs = len(procs.split('\n'))
                        print(f"  {relative_path} ({num_procs} processes)")
                except PermissionError:
                    pass


def main():
    """Main entry point."""
    parser = argparse.ArgumentParser(
        description="Real-time cgroups v2 monitor",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s                           # Monitor root cgroup
  %(prog)s /sys/fs/cgroup/user.slice # Monitor users
  %(prog)s --docker abc123           # Monitor Docker container
  %(prog)s --list                    # List available cgroups
        """
    )
    
    parser.add_argument(
        "cgroup_path",
        nargs="?",
        default=str(CGROUP_BASE),
        help="Path to the cgroup to monitor"
    )
    
    parser.add_argument(
        "--docker", "-d",
        metavar="CONTAINER_ID",
        help="ID of the Docker container to monitor"
    )
    
    parser.add_argument(
        "--list", "-l",
        action="store_true",
        help="List available cgroups"
    )
    
    parser.add_argument(
        "--interval", "-i",
        type=float,
        default=1.0,
        help="Update interval in seconds (default: 1.0)"
    )
    
    args = parser.parse_args()
    
    # List cgroups
    if args.list:
        list_cgroups()
        return
    
    # Determine cgroup path
    if args.docker:
        try:
            cgroup_path = find_docker_cgroup(args.docker)
            print(f"Container found: {cgroup_path}")
        except FileNotFoundError as e:
            print(f"Error: {e}", file=sys.stderr)
            sys.exit(1)
    else:
        cgroup_path = Path(args.cgroup_path)
    
    # Create monitor
    try:
        monitor = CgroupMonitor(cgroup_path)
    except (FileNotFoundError, RuntimeError) as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)
    
    # Monitoring loop
    try:
        print_header()
        
        while True:
            stats = monitor.get_stats()
            cpu_percent = monitor.get_cpu_percent(stats)
            print_stats(stats, cpu_percent)
            time.sleep(args.interval)
            
    except KeyboardInterrupt:
        print("\n\nMonitor stopped.")
    except PermissionError:
        print("\nError: Insufficient permissions. Try running with sudo.", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
