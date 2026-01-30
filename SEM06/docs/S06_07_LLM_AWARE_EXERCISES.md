# LLM-Aware Exercises — CAPSTONE SEM06

> **Operating Systems** | ASE Bucharest - CSIE  
> Seminar 6: Integrated Projects (Monitor, Backup, Deployer)

---

## LLM-Aware Philosophy

In the era of ChatGPT/Claude/Copilot, traditional exercises can be solved instantly by AI. LLM-aware exercises are designed to:

1. **Require access to real system** — AI cannot run commands on your computer
2. **Involve machine-specific output** — hostname, PID, unique timestamps
3. **Require real-time debugging** — analysing a running process
4. **Request decisions based on local context** — what services are running NOW
5. **Combine code with understanding** — not just "write code", but "explain why"

---

## Exercise 1: Forensics on /proc (25 min)

### Context
A "suspect" process is running on the system. You need to investigate it using `/proc`.

### Task

1. Find the PID of the `bash` process running the current script:
   ```bash
   echo "My PID: $$"
   ```

2. Investigate `/proc/$$`:
   ```bash
   ls /proc/$$/
   ```

3. Answer questions (with real output):

   a) What is the complete command used to launch the process?
   ```bash
   cat /proc/$$/cmdline | tr '\0' ' '
   # Your answer: _______________
   ```

   b) What environment variables does it have? (first 5)
   ```bash
   head -5 /proc/$$/environ | tr '\0' '\n'
   # Your answer: _______________
   ```

   c) What file descriptors are open?
   ```bash
   ls -la /proc/$$/fd/
   # Your answer: _______________
   ```

   d) What is the current working directory?
   ```bash
   readlink /proc/$$/cwd
   # Your answer: _______________
   ```

### Why AI Cannot Solve This
- Answers depend on YOUR system
- PID is unique for each run
- Environment variables are session-specific

### Evaluation
- 2p per correct answer with real output
- -1p if output appears fabricated

---

## Exercise 2: Trace System Calls (20 min)

### Context
You want to understand what a script does "under the hood".

### Task

1. Create a simple script:
   ```bash
   #!/bin/bash
   echo "Start"
   sleep 1
   cat /etc/hostname
   echo "End"
   ```

2. Run with strace and capture output:
   ```bash
   strace -f -o trace.log ./script.sh
   ```

3. Analyse trace.log and answer:

   a) How many `write()` calls were made? List the first 3:
   ```bash
   grep "^write" trace.log | head -3
   # Your answer: _______________
   ```

   b) What system call opens /etc/hostname?
   ```bash
   grep "hostname" trace.log
   # Your answer: _______________
   ```

   c) What syscall implements `sleep 1`?
   ```bash
   grep -E "nanosleep|clock_nanosleep" trace.log
   # Your answer: _______________
   ```

### Why AI Cannot Solve This
- strace output is kernel/version specific
- Memory addresses and file descriptors are unique
- Timestamps are real

### Evaluation
- Must attach trace.log (or relevant fragments)
- Fabricated output = 0p

---

## Exercise 3: Performance Detective (30 min)

### Context
Your system is "slow". Investigate with the tools you've learned.

### Task

1. Capture current system state:
   ```bash
   # CPU
   grep "^cpu " /proc/stat
   
   # Memory
   grep -E "^(MemTotal|MemFree|MemAvailable|Buffers|Cached)" /proc/meminfo
   
   # Load average
   cat /proc/loadavg
   
   # Top 5 processes by CPU
   ps aux --sort=-%cpu | head -6
   ```

2. Run a simple "stress test":
   ```bash
   # Create temporary load
   dd if=/dev/zero of=/dev/null bs=1M count=1000 &
   STRESS_PID=$!
   sleep 5
   ```

3. Capture state again and compare:
   ```bash
   # CPU after stress
   grep "^cpu " /proc/stat
   
   # Load average after stress
   cat /proc/loadavg
   ```

4. Stop the stress:
   ```bash
   kill $STRESS_PID 2>/dev/null
   ```

5. Answer:
   - Which value in /proc/stat changed the most? Why?
   - What happened to load average?
   - Identify the dd process in ps output. What is the %CPU?

### Why AI Cannot Solve This
- Values are specific to your hardware
- Capture moment affects results
- Load average depends on number of cores

---

## Exercise 4: Debug Live (20 min)

### Context
You have a script with bugs. Find them WITHOUT correcting before analysis.

### Buggy Script

```bash
#!/bin/bash
# save as: buggy.sh

LOG_FILE = "/tmp/debug.log"

process_file() {
    local file=$1
    if [ -f $file ]; then
        cat $file | wc -l
    fi
}

main() {
    for f in *.txt
        process_file $f
    done
}

main
```

### Task

1. Save the script and try to run it
2. Document EACH error in order of appearance:
   ```
   Error 1: Line X, message: "..."
   Cause: ___
   
   Error 2: ...
   ```

3. Correct errors one by one, running after each correction
4. Document the solution for each

### Why AI Cannot Solve This
- Exact error messages depend on Bash version
- Order of error discovery is important
- AI can correct instantly, but CANNOT document the debugging process

### Evaluation
- Debugging process documented step by step: 10p
- Only corrected code without process: 3p

---

## Exercise 5: Monitor Your Machine (35 min)

### Context
Create a personalised monitor for YOUR COMPUTER.

### Requirements

1. Script must display:
   - Real hostname
   - Uptime in human-readable format
   - CPU usage (calculated, not from top)
   - Top 3 processes by memory (with real names from your system)
   - Free space on / (real percentage)

2. Output must include exact timestamp of execution

3. Run script 3 times at 1 minute intervals and save output

### Template

```bash
#!/bin/bash
# monitor_my_machine.sh

echo "=== SYSTEM MONITOR ==="
echo "Time: $(date '+%Y-%m-%d %H:%M:%S')"
echo "Host: $(hostname)"
echo ""

# TODO: Implement the rest
# Each value must be REAL from your system
```

### Deliverable
- Complete script
- 3 consecutive outputs (proving it runs on real system)

### Why AI Cannot Solve This
- Hostname is unique
- Top 3 processes vary over time
- Timestamps must be consecutive at ~1 minute apart

---

## Exercise 6: Explain This Code (15 min)

### Context
You receive this script and must explain what it does WITHOUT running it.

```bash
#!/bin/bash
set -euo pipefail

readonly LOCK="/var/run/$(basename "$0").lock"

cleanup() { rm -f "$LOCK"; }
trap cleanup EXIT

exec 200>"$LOCK"
flock -n 200 || { echo "Already running"; exit 1; }
echo $$ >&200

while :; do
    find /tmp -type f -mmin +60 -delete 2>/dev/null
    sleep 3600
done
```

### Task

1. Explain each section in your own words:
   - What does `exec 200>"$LOCK"` do?
   - What is `flock -n 200` and why is it necessary?
   - What does `echo $$ >&200` do?
   - What does the while loop clean and how often?

2. Answer:
   - What happens if you run the script twice simultaneously?
   - Why is the trap important here?
   - What is the potential security problem?

### Why AI Cannot Solve This (Well)
- AI can explain generically, but cannot demonstrate understanding
- We're looking for YOUR explanation, not a copied one
- Questions are open-ended and evaluate reasoning

---

## Exercise 7: Reverse Engineering (25 min)

### Context
You only have the output of a script. Recreate the script.

### Captured Output

```
$ ./mystery.sh /var/log
=== Directory Analysis: /var/log ===
Total files: 47
Total size: 12M
Largest file: /var/log/syslog (2.1M)
Oldest file: /var/log/bootstrap.log (45 days)
File types:
  - .log: 23 files
  - .gz: 15 files
  - (no ext): 9 files
```

### Task

1. Write a script that produces SIMILAR output for /var/log (or another directory on your system)

2. Script must:
   - Accept a directory as argument
   - Calculate the displayed statistics
   - Format output identically

3. Run on your system and attach real output

### Why AI Cannot Solve This
- Final output must be from your system
- Numbers will be different
- AI cannot verify if code produces expected output

---

## Exercise 8: Signature Script (MANDATORY - 15 min)

### Purpose
Generate a unique "fingerprint" of your system that proves YOU ran the code. This exercise is **mandatory** for the CAPSTONE submission.

### Task

Create `signature.sh` that outputs system-specific identifiers:

```bash
#!/bin/bash
# signature.sh - Generate unique system fingerprint
# MANDATORY for CAPSTONE submission

set -euo pipefail

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║              STUDENT SYSTEM SIGNATURE                        ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""
echo "=== EXECUTION CONTEXT ==="
echo "Generated: $(date -Iseconds)"
echo "Hostname: $(hostname)"
echo "Username: $(whoami)"
echo "Kernel: $(uname -r)"
echo "Uptime: $(uptime -p)"
echo "Shell PID: $$"
echo "Parent PID: $PPID"
echo "Working dir: $(pwd)"
echo ""
echo "=== UNIQUE IDENTIFIERS ==="
echo "Machine ID: $(cat /etc/machine-id 2>/dev/null || echo 'N/A')"
echo "Boot ID: $(cat /proc/sys/kernel/random/boot_id 2>/dev/null || echo 'N/A')"
echo "CPU model: $(grep -m1 'model name' /proc/cpuinfo 2>/dev/null | cut -d: -f2 | xargs || echo 'N/A')"
echo "MAC (first): $(ip link 2>/dev/null | grep -m1 'link/ether' | awk '{print $2}' || echo 'N/A')"
echo ""
echo "=== SYSTEM STATE ==="
echo "Load average: $(cat /proc/loadavg)"
echo "Memory free: $(grep MemFree /proc/meminfo | awk '{print $2, $3}')"
echo "Disk usage /: $(df -h / | awk 'NR==2 {print $5}')"
echo ""
echo "=== PROCESS TREE ==="
pstree -p $$ 2>/dev/null | head -5 || ps -f $$
echo ""
echo "=== CHECKSUM ==="
# Create a hash of the above for verification
echo "Signature hash: $(hostname; date +%s; cat /etc/machine-id 2>/dev/null) | sha256sum | cut -c1-16"
```

### Submission Requirements

1. Run script and save output:
   ```bash
   ./signature.sh > signature_run1.txt
   sleep 60
   ./signature.sh > signature_run2.txt
   sleep 60
   ./signature.sh > signature_run3.txt
   cat signature_run*.txt > signature.txt
   ```

2. Include `signature.txt` in your CAPSTONE submission
3. Output MUST be from YOUR computer
4. Timestamps must be within 24h of submission deadline
5. Timestamps must be ~1 minute apart (proving real execution)

### Why This Works Against AI-Generated Submissions

| Element | Why It's Hard to Fake |
|---------|----------------------|
| Machine ID | Unique per OS installation, persistent |
| Boot ID | Changes each reboot, proves recent execution |
| Process tree | Shows YOUR terminal emulator |
| MAC address | Unique to your network card |
| Load average | Varies constantly |
| Memory free | Different every second |
| Consecutive timestamps | Must be ~1 min apart |

**Combined:** These elements are virtually impossible to fabricate convincingly.

### Verification Process

During the live demonstration, the instructor may ask you to:
1. Run `signature.sh` again on the spot
2. Compare output with your submitted `signature.txt`
3. Explain why certain values changed (or didn't)

---

## Evaluation Matrix

| Exercise | Time | Points | What It Demonstrates |
|----------|------|--------|----------------------|
| 1. Forensics /proc | 25 min | 10p | Understanding /proc |
| 2. Trace syscalls | 20 min | 10p | Low-level debugging |
| 3. Performance | 30 min | 15p | Real monitoring |
| 4. Debug live | 20 min | 10p | Debugging process |
| 5. Custom monitor | 35 min | 20p | Concept integration |
| 6. Explain code | 15 min | 15p | Deep understanding |
| 7. Reverse eng. | 25 min | 20p | Synthesis |
| **8. Signature** | **15 min** | **MANDATORY** | **Authenticity proof** |

---

## How to Detect AI Solutions

Indicators that solution is AI-generated:

1. **Generic output** — hostname "ubuntu-server", PID 1234
2. **Round timestamps** — exactly :00:00
3. **Too perfect** — zero typos, impeccable structure
4. **"Convenient" values** — CPU exactly 25%, memory exactly 50%
5. **Process missing** — only final result, no intermediate steps
6. **Signature mismatch** — submitted signature.txt doesn't match live demo

### What to Ask Students For

- Terminal screenshots (hard to fabricate)
- Attached .log files (with real timestamps)
- Explanations in their own words
- Live demonstrations in seminar
- **signature.txt with 3 consecutive runs**

---

*Document generated for SEM06 CAPSTONE — Operating Systems*  
*ASE Bucharest - CSIE | 2024-2025*
