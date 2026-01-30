# Observability and Debugging Guide (Linux, introductory level)

An operating system is, by its nature, "invisible" until you instrument it. In the laboratory, the objective is not just "to make it work", but to be able to explain why it works or why it does not work.

## 1. Basic tools (without special privileges)

### Processes and load
- `ps`, `top` / `htop`
- `uptime`
- `time` (measurement per command)

### Memory
- `free -h`
- `vmstat 1`
- `/proc/meminfo`

### Disk and files
- `df -h`, `du -sh`
- `ls -l`, `stat`
- `lsof` (what files are open and by whom)

### Network (when relevant)
- `ss -tulpn` (sockets)
- `ip a`, `ip r`

## 2. `strace`: observing system calls

`strace` is very useful for:
- seeing what files a program attempts to open;
- understanding why you receive `Permission denied`, `No such file or directory`;
- discussing the difference between *API* (libc functions) and *system calls*.

Example:
```bash
strace -f -o trace.txt ls -l /tmp
```

## 3. Logs: `journalctl` and `dmesg`

- `journalctl` (systemd journal) — events for services and system
- `dmesg` — kernel messages (drivers, I/O errors, OOM killer etc.)

Examples:
```bash
journalctl -b -p warning
dmesg --level=err,warn | tail -n 50
```

## 4. Debugging in Bash

- run with `bash -x script.sh ...`
- check values with `printf '%q\n' "$var"` (useful for whitespace)
- use `trap` for cleanup and to display context on errors

## 5. Debugging in Python (in OS context)

- display minimal and reproducible information: PID, time, resources;
- for exceptions, keep the traceback (do not "swallow" errors).

Edition date: **10 January 2026**
