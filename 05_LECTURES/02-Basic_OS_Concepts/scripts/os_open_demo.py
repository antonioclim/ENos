/* FIȘIER TRADUS ȘI VERIFICAT ÎN LIMBA ROMÂNĂ */

#!/usr/bin/env python3
"""
Demo: file I/O via POSIX APIs exposed in Python (os.open / os.read / os.write).

Didactic objective (Week 2):
- to observe the difference between a "function call" in user-space and a "system call" in the kernel;
- to correlate `openat`, `read`, `write`, `close` from strace with operations in the programme.

Recommended usage:
  ./os_open_demo.py -i /etc/hosts -o /tmp/hosts_copy.txt
  ./trace_cmd.sh -e openat,read,write,close -- ./os_open_demo.py -i /etc/hosts -o /tmp/hosts_copy.txt
"""

from __future__ import annotations

import argparse
import os
from pathlib import Path


def parse_args() -> argparse.Namespace:
    p = argparse.ArgumentParser(description="Copy file using os.open/os.read/os.write.")
    p.add_argument("-i", "--input", type=Path, required=True, help="Input file path")
    p.add_argument("-o", "--output", type=Path, required=True, help="Output file path")
    p.add_argument("--buf", type=int, default=4096, help="Buffer size (bytes)")
    return p.parse_args()


def copy_file(src: Path, dst: Path, buf_size: int) -> None:
    """Copy a file using low-level POSIX I/O operations.
    
    This function demonstrates direct system call usage through Python's os module.
    Each os.open/read/write/close maps directly to the corresponding syscall.
    """
    fd_in = os.open(src, os.O_RDONLY)
    try:
        fd_out = os.open(dst, os.O_WRONLY | os.O_CREAT | os.O_TRUNC, 0o644)
        try:
            while True:
                chunk = os.read(fd_in, buf_size)
                if not chunk:
                    break
                os.write(fd_out, chunk)
        finally:
            os.close(fd_out)
    finally:
        os.close(fd_in)


def main() -> int:
    args = parse_args()
    copy_file(args.input, args.output, args.buf)
    print(f"OK: copied {args.input} -> {args.output}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
