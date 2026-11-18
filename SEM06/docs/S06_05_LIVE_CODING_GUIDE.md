# Live Coding Guide — CAPSTONE SEM06

> **Operating Systems** | ASE Bucharest - CSIE  
> Seminar 6: Integrated Projects (Monitor, Backup, Deployer)  
> Instructor Guide

---

> **Execution and evidence contract:** Bash 4.4+ on GNU/Linux. Run repository-relative commands from the repository root. Examples use disposable, explicitly owned paths. Expected failures must be captured in `if` statements when `set -e` is enabled. See [TEACHING_CONTRACT.md](TEACHING_CONTRACT.md) for evidence limits and author decisions.

## Live Coding Principles (Brown & Wilson)

1. **Type in real time** — don't copy/paste large blocks
2. **Make mistakes intentionally** — show debugging
3. **Ask for predictions** — "What will this command display?"
4. **Verbalise** — explain what you're thinking whilst writing
5. **Pause for questions** — after each logical block

---

## Demo 1: System Monitor (20 min)

### Objective
Build step by step a CPU monitor that reads from `/proc/stat`.

### Setup

```bash
# From the repository root; keep this shell for the following Monitor cells.
SEM06_DIR=$(realpath -- SEM06)
source "$SEM06_DIR/scripts/examples/monitor_examples.sh"
# Enlarge the terminal font before projection.
```

### Step 1: Reading /proc/stat (5 min)

**Say:** "All CPU information comes from the pseudo-file /proc/stat. Let's see what it contains."

```bash
# Question: What do you think we find in /proc/stat?
head -n 5 /proc/stat
```

**Expected output:**
```
cpu  1234567 12345 234567 8901234 12345 0 1234 0 0 0
cpu0 309891 3086 58641 2225308 3086 0 308 0 0 0
...
```

**Explain:** "The first line is the total. The numbers are: user, nice, system, idle, iowait..."

### Step 2: Extraction with awk (5 min)

```bash
# Question: How do we extract only the first line?
grep "^cpu " /proc/stat

# Now we extract the values
grep "^cpu " /proc/stat | awk '{print $2, $3, $4, $5}'
```

**Intentional mistake:**
```bash
# Oops, I forgot that awk uses spaces as separator
grep "^cpu " /proc/stat | awk -F: '{print $2}'
# Doesn't work! Why?
```

### Step 3: Calculating percentage (5 min)

```bash
# Implementation is visible in scripts/examples/monitor_examples.sh.
# It reads twice, sleeps, validates both totals and rejects a non-positive delta.
if cpu_usage=$(get_cpu_usage 0.2); then
    printf 'CPU usage over the sample interval: %s%%
' "$cpu_usage"
else
    printf 'CPU sample unavailable
' >&2
fi
```

### Step 4: Reusable function (5 min)

```bash
cpu_totals() {
    awk 'NR==1 { if ($1!="cpu" || NF<9) exit 1;
        total=0; for(i=2;i<=9;i++){if($i !~ /^[0-9]+$/) exit 1; total+=$i}
        printf "%.0f %.0f\n",total,$5+$6; ok=1 } END {if(!ok) exit 1}'
}

get_cpu_usage() {
    local first second values1 values2 total1 idle1 total2 idle2 elapsed idle_elapsed
    [[ -r /proc/stat ]] || { log_error "CPU counters are unavailable"; return 1; }
    first=$(grep '^cpu ' /proc/stat) || return 1
    sleep "${CPU_SAMPLE_INTERVAL:-0.5}" || return 1
    second=$(grep '^cpu ' /proc/stat) || return 1
    # Sum user..steal only; guest/guest_nice are already in user/nice.
    # This model treats idle+iowait as non-busy time; invalid intervals are unavailable.
    values1=$(cpu_totals <<< "$first") || return 1
    values2=$(cpu_totals <<< "$second") || return 1
    IFS=' ' read -r total1 idle1 <<< "$values1"
    IFS=' ' read -r total2 idle2 <<< "$values2"
    elapsed=$((total2-total1)); idle_elapsed=$((idle2-idle1))
    (( elapsed > 0 && idle_elapsed >= 0 && idle_elapsed <= elapsed )) || {
        log_error "CPU counters did not yield a valid interval"; return 1;
    }
    printf '%s\n' "$((100 * (elapsed-idle_elapsed) / elapsed))"
}


if usage=$(get_cpu_usage 0.2); then printf 'CPU: %s%%\n' "$usage"; fi
```

Counters cover user through steal. Guest values must not be added twice. Idle + iowait is the chosen non-busy convention, not an assertion that iowait precisely measures device delay. Invalid or reset counters produce unavailable evidence.

### Checkpoint

- Did everyone understand how we read from /proc?
- Questions about awk or read?

---

## Demo 2: Backup System (25 min)

### Objective
Build an incremental backup system with checksum verification.

### Step 1: Owned directory structure (3 min)

Run these stages in one Bash script, so its EXIT trap owns the workspace lifecycle.

```bash
#!/usr/bin/env bash
set -euo pipefail
SEM06_DIR=$(realpath -- SEM06)
work=
trap '[[ -z ${work:-} ]] || rm -rf -- "$work"' EXIT
work=$(mktemp -d)
mkdir -- "$work/source" "$work/backups" "$work/restored"
printf 'Important document v1\n' > "$work/source/document.txt"
printf 'Delete in the increment\n' > "$work/source/obsolete.txt"
printf 'Rename in the increment\n' > "$work/source/old-name.txt"
BACKUP_PROGRAM="$SEM06_DIR/scripts/projects/backup/backup.sh"
source "$SEM06_DIR/scripts/examples/backup_examples.sh"
```

### Step 2: Full base with GNU tar (5 min)

```bash
create_full_backup "$work/source" "$work/backups"
base=$(cat -- "$work/backups/.latest")
tar -tzf "$work/backups/$base"
```

The wrapper uses literal configuration, a lock inside the destination and no email. The first `--incremental --type full` archive is the root of a chain, not an independent point-in-time filesystem snapshot of concurrently changing data.

### Step 3: Checksum verification and controlled failure (5 min)

```bash
verify_archive "$work/backups/$base" sha256
# Corrupt a COPY, so the valid chain remains available for the next stage.
cp -- "$work/backups/$base" "$work/corrupt.tar.gz"
cp -- "$work/backups/$base.sha256" "$work/corrupt.tar.gz.sha256"
printf 'corrupt' >> "$work/corrupt.tar.gz"
if verify_checksum "$work/corrupt.tar.gz" sha256; then
    printf 'Unexpected verification success\n' >&2; exit 1
else
    printf 'Expected checksum mismatch recorded\n'
fi
```

A digest checks bytes against an expected value. It is not a signature and does not authenticate the publisher of the archive or sidecar.

### Step 4: Incremental backup with changes, deletion and rename (7 min)

```bash
printf 'Important document v2\n' > "$work/source/document.txt"
printf 'New file\n' > "$work/source/new.txt"
rm -- "$work/source/obsolete.txt"
mv -- "$work/source/old-name.txt" "$work/source/new-name.txt"
create_incremental_backup "$work/source" "$work/backups"
latest=$(cat -- "$work/backups/.latest")
```

GNU tar's listed-incremental metadata captures deletion and rename effects. The staged snapshot advances only after the new archive and chain metadata succeed. `find -newer | xargs tar` cannot implement this contract: it omits deletions, can split archive creation over multiple commands and mishandles the empty-change case.

### Step 5: Restore the complete chain and compare (5 min)

```bash
restore_incremental_chain "$work/backups/$latest" "$work/restored"
# Absolute source names are stored without the leading slash.
diff -r -- "$work/source" "$work/restored/${work#/}/source"
[[ ! -e "$work/restored/${work#/}/source/obsolete.txt" ]]
[[ ! -e "$work/restored/${work#/}/source/old-name.txt" ]]
printf 'Create/modify/delete/rename recovery matches the owned fixture\n'
```

Use an empty restore destination. A missing parent, cycle, invalid archive or failed checksum prevents extraction. Retention must retain every ancestor of a retained checkpoint; counting `*.tar*` files includes sidecars and breaks chains.

---

## Demo 3: Deployer with Rollback (20 min)

### Objective
Demonstrate immutable local releases, atomic replacement of a symlink and rollback to the recorded previous activation.

### Step 1: Releases and validated package (5 min)

```bash
SEM06_DIR=$(realpath -- SEM06)
source "$SEM06_DIR/scripts/examples/owned_demos.sh"
```

Read `release_demo` and `release_reference.py`. The demo creates two small regular-file tar archives in an owned temporary directory, computes their expected SHA-256 values, validates members and publishes immutable release IDs. Unsafe paths, links/devices, duplicate members, digest mismatches and reused IDs fail before activation.

### Step 2: Activate a prepared release (5 min)

```bash
release_demo
```

Expected transitions are `Before: v1`, `After: v2`, `Rolled back: v1`, then the original application text. The helper stages a new symlink on the same filesystem and uses `os.replace`; `ln -sf`/`ln -sfn` alone does not establish this transaction. Filesystem name replacement does not prove service availability, database compatibility, in-flight request continuity or zero downtime.

### Step 3: Bounded health check (5 min)

```bash
check_health() {
    [[ $# == 1 && $1 == http*://* ]] || return 2
    local url=$1 attempt
    for ((attempt=1; attempt<=3; attempt++)); do
        if curl --fail --silent --show-error --connect-timeout 2 --max-time 5 \
                --output /dev/null -- "$url"; then
            printf 'Health check passed\n'; return 0
        fi
        ((attempt == 3)) || sleep 2 || return 1
    done
    printf 'Health check failed after 3 attempts\n' >&2
    return 1
}
# Define only. Exercise with the supplied mock; real endpoints need explicit intent.
```

The HTTP status is only one health signal. The retry loop stops after three attempts, propagates failure and never sleeps after its last failure.

### Step 4: Rollback according to activation history (5 min)

The helper's `transition.json` records `previous` and `target` under the release lock. Rollback activates that explicit previous ID. Sorting version names or modification times cannot reconstruct deployment history. An interrupted activation still requires reconciliation of the recorded transition with the actual `current` link; this is not a distributed crash-recovery protocol.

Inspect the exact maintained implementation and rerun the fixture after changing one package digest. The changed package must fail without activating a new version.

---

## Live Coding Tips

### Before Seminar

- [ ] Test all commands
- [ ] Prepare necessary files
- [ ] Verify display (font, contrast)
- [ ] Have backup if something fails

### During Session

- [ ] Talk whilst typing
- [ ] Stop for questions
- [ ] Let students predict output
- [ ] When you make mistakes, turn into learning moment

### Common Errors to Demonstrate

1. **Spaces in assignment:** `VAR = value` → error
2. **Missing quotes:** `$VAR` with spaces → word splitting
3. **Exit code ignored:** command fails but script continues
4. **File doesn't exist:** wrong path, permissions

### Recovery Phrases

- "Hmm, it doesn't work as I expected. Let's investigate..."
- "This is a common mistake. Who knows why?"
- "Let's check with `echo` what value the variable has"
- "Good example of real-time debugging!"

---

## Prepared Demo Files

- `SEM06/scripts/examples/monitor_examples.sh`: sourceable validated metric functions.
- `SEM06/scripts/examples/backup_examples.sh`: chain, checksum and compression functions.
- `SEM06/scripts/examples/owned_demos.sh`: `snapshot`, `release`, `processes`, `descriptors` modes; `--help` lists them.
- `SEM06/scripts/examples/mock_curl.py`: explicit local HTTP fixture.

These are the actual supplied interfaces. There is no `--step`, `--demo` or `scripts/demo_monitor.sh` interface.

---

## Recommended Timing

| Demo | Duration | Key Points |
|------|----------|------------|
| Monitor | 20 min | /proc/stat, awk, functions |
| Backup | 25 min | tar, checksum, incremental |
| Deployer | 20 min | atomic symlink, health check |
| Buffer | 15 min | Questions, debugging |
| **Total** | 80 min | From a 100 min seminar |

---

*Document generated for SEM06 CAPSTONE — Operating Systems*  
*ASE Bucharest - CSIE | 2024-2025*
