# Project Ideas (anchored in the Operating Systems course)

The purpose of the projects is to consolidate practical competencies: **CLI automation**, **resource modelling**, **script robustness**, **observability** and **basic security**.

> Recommendation: team projects (2–3 people), Git repository, minimal documentation (README + running examples + demonstrative output).

## 1. Permission and risk audit in home-directory

**What it does:** scans a directory tree and reports:
- world-writable files;
- directories with risky permissions;
- executable files without coherent owner/permissions (where applicable).

**Links to OS:** Unix permissions, ownership, security, `umask`, `chmod/chown`, the concept of "least privilege".

**Recommended implementation:** Bash for rapid collection (`find`, `stat`), Python for reporting (CSV/JSON + top N).

## 2. Lightweight process monitor (CLI)

**What it does:** periodically displays CPU/memory-consuming processes, with:
- PID, PPID, command;
- RSS evolution;
- optionally: a "snapshot" to file.

**Links to OS:** processes, scheduling, memory, `/proc`, signals (`SIGTERM`, `SIGKILL`).

## 3. Incremental backup with locking and verification

**What it does:** periodically archives a directory, avoiding simultaneous execution:

- Uses `flock`/lockfile
- Logs each execution
- Verifies integrity (hash, `tar -t`)


**Links to OS:** concurrency (race conditions), files, cron/systemd timers, integrity.

## 4. Log analyser (security/operations)

**What it does:** extracts events (logins, failures, restarts) from `journalctl` or log files and produces:
- top IPs / users
- hourly intervals with peak activity
- CSV export for further analysis


**Links to OS:** security, audit, text processing (grep/sed/awk), pipelines.

## 5. Educational "mini shell" (optional, advanced level)

**What it does:** a minimal shell that supports:
- executing simple commands (fork + exec)
- redirections (`>`, `<`, `>>`)
- pipeline (`|`) for 2–3 commands


**Links to OS:** `fork/exec`, pipes, file descriptors, signals, job control (partial).

Edition date: **10 January 2026**
