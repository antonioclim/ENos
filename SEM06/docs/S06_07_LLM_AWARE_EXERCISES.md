# LLM-Aware Exercises — CAPSTONE SEM06

> **Operating Systems** | ASE Bucharest - CSIE  
> Seminar 6: Integrated Projects (Monitor, Backup, Deployer)

---

## LLM-Aware Philosophy

These exercises combine prediction, local execution, explanation and reproducible evidence. An AI system with authorised tools can execute commands and document debugging; hostnames, PIDs, timestamps, screenshots and stylistic features are not proof of authorship. Machine observations are time-dependent and can be fabricated or copied. Assess the technical reasoning against an explicitly approved rubric.

**Author decision remains open:** the historical real-machine collection and mandatory signature proposal below requires a choice of minimisation, retention, recipients, redaction and assessment consequences. The technical corrections do not approve that collection policy. Use the supplied synthetic fixtures to practise parsers without exposing real identifiers. See [TEACHING_CONTRACT.md](TEACHING_CONTRACT.md).

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

   b) How is a NUL-delimited environment parsed without dumping secrets? Inspect an explicit synthetic fixture (no user environment is collected):
   ```bash
   fixture=$(mktemp)
   trap 'rm -f -- "$fixture"' EXIT
   printf 'DEMO_TASK=capstone\0LANG=C.UTF-8\0TOKEN=do-not-display\0TERM=xterm\0' > "$fixture"
   python3 SEM06/scripts/examples/evidence_examples.py environment "$fixture"
   ```
   The allowlist is DEMO_TASK, LANG, TERM, SHELL and TZ, at most five records. Splitting after `head -5` is wrong because `/proc/PID/environ` uses NUL separators. Do not submit real command lines, environment values, descriptor targets or working paths before the collection/redaction policy is approved.

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

### What this evidence can establish
- Answers depend on YOUR system
- A PID identifies a process only within a namespace and time interval; it can be reused
- Environment variables are session-specific

### Evaluation
- 2p per correct answer with real output
- Historical proposed penalty: −1p for fabrication. Do not infer fabrication from appearance; the evidentiary standard and review process require author approval.

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
   strace -f -ttt -o trace.log bash ./script.sh
   ```

3. Analyse trace.log and answer:

   a) How many `write()` calls were made? List the first 3:
   ```bash
   python3 SEM06/scripts/examples/evidence_examples.py trace trace.log
   # Your answer: _______________
   ```

   The parser counts entered `write(` records with optional PID and timestamp prefixes and lists the first three. Resumed records are not double-counted. It is a bounded teaching parser, not a universal decoder of every strace mode.

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

### What this evidence can establish
- strace output is kernel/version specific
- Addresses and descriptor numbers can recur and do not authenticate a recording
- `-ttt` requests timestamps; they reflect the local clock and are not independently trusted

### Evaluation
- Must attach trace.log (or relevant fragments)
- Historical proposed zero for fabrication is subject to the approved evidentiary and review policy; parser output alone cannot determine fabrication.

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
   ps -eo pid,pcpu,pmem,comm --sort=-pcpu | sed -n '1,6p'
   ```

2. Optional load fixture on a disposable lab host with explicit intent to consume CPU for five seconds (do not run on shared production infrastructure):
   ```bash
   # Create temporary load
   timeout --signal=TERM --kill-after=1 5 dd if=/dev/zero of=/dev/null bs=1M status=none &
   STRESS_PID=$!
   # Observe only this owned bounded process; do not wait five seconds before taking the sample.
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
   if wait "$STRESS_PID"; then status=0; else status=$?; fi
   [[ $status == 0 || $status == 124 ]] || { printf 'Load fixture failed: %s\n' "$status" >&2; exit 1; }
   ```

5. Answer:
   - Which value in /proc/stat changed the most? Why?
   - What happened to load average?
   - Identify the dd process in ps output. What is the %CPU?

### What this evidence can establish
- Values are specific to your hardware
- Capture moment affects results
- Load average depends on number of cores

---

## Exercise 4: Debug Live (20 min)

### Context
You have a script with bugs. Find them WITHOUT correcting before analysis.

### Buggy Script — intentionally WRONG; analyse before correcting

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

### What this evidence can establish
- Exact error messages depend on Bash version
- Order of error discovery is important
- A tool-assisted system can also document the debugging process; retain exact inputs, outputs and the explanation

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
- 3 observations with reproducible commands and stated limits; consecutive text is not proof of execution

### What this evidence can establish
- A hostname is configurable and need not be unique
- Top 3 processes vary over time
- Timestamps must be consecutive at ~1 minute apart

---

## Exercise 6: Explain This Code (15 min)

### Context
You receive this intentionally unsafe script and must explain it WITHOUT running it. The shared `/tmp` deletion is outside a legitimate owned fixture, and unlinking a held lock file can let another process lock a different inode. The corrected runtime keeps a stable lock pathname and deletes only explicitly owned files.

```text
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
   - Why can this unlinking trap break mutual exclusion? How would a stable lock inode fix it?
   - What is the potential security problem?

### What this evidence can establish
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

### What this evidence can establish
- Final output must be from your system
- Numbers will be different
- Executing a check establishes that particular input/output behaviour, whoever operates the tools

---

## Exercise 8: Historical signature proposal — author decision pending (15 min)

### Purpose
The historical draft proposed a mandatory machine fingerprint and claimed it proved execution. That claim is unsupported: hashes of self-reported identifiers provide neither a digital signature nor authorship. The original requested fields and timing are preserved below for the author to accept, minimise or remove explicitly. They are not newly adopted requirements.

### Task

**Historical proposal, non-executable review text:** `signature.sh` would collect the following identifiers. Do not run or submit it under an assumed policy.

```text
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

### Historical submission requirements (pending author decision)

1. Run script and save output:
   ```text
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
5. Timestamps were requested approximately one minute apart; this timing does not prove real execution.

### Limits of the historical authenticity claim

| Element | Evidentiary limitation |
|---------|----------------------|
| Machine ID | Can be copied or reset; reveals a persistent identifier |
| Boot ID | Local reported value; does not prove when submitted text was produced |
| Process tree | Time-dependent and namespace-dependent; can be reproduced or fabricated |
| MAC address | Can be randomised, changed or shared by virtual configurations |
| Load average | Dynamic metric; arbitrary text can claim any value |
| Memory free | Dynamic metric, not identity evidence |
| Consecutive timestamps | Local clock values can be edited |

Combining these fields does not create authentication. The original checksum line also printed a pipeline as text instead of hashing the displayed record. The following separate synthetic exercise hashes exactly the bytes in its fixture:

```bash
record=$(mktemp)
trap 'rm -f -- "$record"' EXIT
printf 'task=capstone-demo\nrun=1\nvalue=synthetic\n' > "$record"
python3 SEM06/scripts/examples/evidence_examples.py fingerprint "$record"
```

The 16 hexadecimal characters are a truncated SHA-256 checksum, not a digital signature, freshness guarantee or authentication token.

### Proposed live discussion

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
| **8. Signature proposal** | **15 min** | **Author decision pending** | **No authenticity proof established** |

---

## How to Detect AI Solutions

Historical heuristic list preserved for critical review. None is a valid detector or basis for a penalty on its own:

1. **Generic output** — hostname "ubuntu-server", PID 1234
2. **Round timestamps** — exactly :00:00
3. **Too perfect** — zero typos, impeccable structure
4. **"Convenient" values** — CPU exactly 25%, memory exactly 50%
5. **Process missing** — only final result, no intermediate steps
6. **Signature mismatch** — submitted signature.txt doesn't match live demo

### What to Ask Students For

- Screenshots as illustrations only; they can be altered and may expose private information
- Attached .log files (with real timestamps)
- Explanations in their own words
- Live demonstrations in seminar
- Machine fingerprint collection only if the author explicitly adopts a minimised, justified policy

---

*Document generated for SEM06 CAPSTONE — Operating Systems*  
*ASE Bucharest - CSIE | 2024-2025*
