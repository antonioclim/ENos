<!-- RO: TRADUS ȘI VERIFICAT -->
#!/usr/bin/env python3
"""
Demo (Week 3): `fork()` / PID / PPID / `wait()`.

Run:
  ./fork_demo.py

Recommendation:
  Also run under `strace`:
    ../SO_Saptamana_02/scripts/trace_cmd.sh -e fork,clone,execve,wait4 -- ./fork_demo.py
"""

from __future__ import annotations

import os
import time

def main() -> int:
    print(f"[PARENT] PID={os.getpid()} PPID={os.getppid()}")
    pid = os.fork()

    if pid == 0:
        # child
        print(f"[CHILD]  PID={os.getpid()} PPID={os.getppid()} (will sleep 1s and exit)")
        time.sleep(1.0)
        os._exit(0)

    # parent continues
    print(f"[PARENT] fork() returned child PID={pid}")
    print("[PARENT] Waiting for child termination (waitpid)...")
    finished_pid, status = os.waitpid(pid, 0)
    exit_code = os.waitstatus_to_exitcode(status)
    print(f"[PARENT] child PID={finished_pid} terminated with exit_code={exit_code}")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
