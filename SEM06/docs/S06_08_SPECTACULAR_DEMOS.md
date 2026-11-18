# Spectacular Demos — CAPSTONE SEM06

> **Operating Systems** | ASE Bucharest - CSIE  
> Seminar 6: Integrated Projects (Monitor, Backup, Deployer)

---

> **Execution and evidence contract:** Bash 4.4+ on GNU/Linux. Run repository-relative commands from the repository root. Examples use disposable, explicitly owned paths. Expected failures must be captured in `if` statements when `set -e` is enabled. See [TEACHING_CONTRACT.md](TEACHING_CONTRACT.md) for evidence limits and author decisions.

## Purpose of Demos

Spectacular demos serve to:
- **Capture attention** — visual or conceptual "wow" effect
- **Demonstrate relevance** — "look what you can do in industry"
- **Motivate learning** — "I want to know how this works"
- **Anchor concepts** — emotional association with material

---

## Demo 1: Real-Time System Dashboard 🖥️

### Wow Factor
A live dashboard showing system state in real time, sampled at bounded intervals, directly in terminal.

### Demo Script

Run from the repository root. Each CPU observation spans 0.2 seconds; the pause separates samples.

```bash
#!/usr/bin/env bash
set -euo pipefail
SEM06_DIR=$(realpath -- SEM06)
source "$SEM06_DIR/scripts/examples/monitor_examples.sh"
trap 'exit 130' INT
trap 'exit 143' TERM
# Five samples keep this demonstration bounded; increase deliberately for projection.
for ((sample=1; sample<=5; sample++)); do
    printf '\nSYSTEM DASHBOARD — sample %s at %s\n' "$sample" "$(date -u +%H:%M:%S)"
    for metric in cpu memory disk; do
        case $metric in
            cpu) if value=$(get_cpu_usage 0.2); then :; else value=; fi ;;
            memory) if value=$(get_memory_usage); then :; else value=; fi ;;
            disk) if value=$(get_disk_usage /); then :; else value=; fi ;;
        esac
        if [[ -n $value ]]; then
            printf '%-6s %s %s%%\n' "$metric" "$(draw_bar "$value" 40)" "$value"
        else
            printf '%-6s unavailable\n' "$metric"
        fi
    done
    ((sample == 5)) || sleep 1
done
```

### Key Moment
"The helpers combine /proc counters and df. CPU is an interval estimate, memory uses MemAvailable and disk follows df percentage semantics. Unavailable evidence stays unavailable."

### Variants
- Add network traffic with `/proc/net/dev`
- Add alerting when CPU > 80%
- Export in Prometheus format

---

## Demo 2: Backup Time Machine ⏰

### Wow Factor
Demonstration of restoring one of three explicitly captured states; uncaptured past states cannot be recovered.

### Disposable demonstration

From the repository root, the complete maintained function below creates and removes only its own workspace. It does not inspect or modify the user's existing data.

```bash
SEM06_DIR=$(realpath -- SEM06)
EXAMPLE_DIR="$SEM06_DIR/scripts/examples"
snapshot_demo() (
    set -euo pipefail
    local work= SNAPSHOT_RESULT= first_snapshot= previous= stage= id=0
    trap '[[ -z ${work:-} ]] || rm -rf -- "$work"' EXIT
    work=$(mktemp -d) || exit 1
    mkdir -- "$work/source" "$work/snapshots"
    local -a history=()
    snapshot() {
        local target
        id=$((id+1)); target="$work/snapshots/version_$id"
        stage=$(mktemp -d "$work/snapshots/.partial.XXXXXX") || return 1
        cp -a -- "$work/source/." "$stage/" || return 1
        mv -- "$stage" "$target" || return 1
        history+=("version_$id"); SNAPSHOT_RESULT="version_$id"
        printf 'Full-copy snapshot: %s\n' "$SNAPSHOT_RESULT"
    }
    restore_snapshot() {
        local version=$1 old
        [[ $version =~ ^version_[1-9][0-9]*$ && -d $work/snapshots/$version ]] || return 2
        stage=$(mktemp -d "$work/.restore.XXXXXX") || return 1
        cp -a -- "$work/snapshots/$version/." "$stage/" || return 1
        old="$work/source.previous"
        [[ ! -e $old ]] || return 1
        mv -- "$work/source" "$old" || return 1
        if ! mv -- "$stage" "$work/source"; then mv -- "$old" "$work/source"; return 1; fi
        rm -rf -- "$old" || return 1
    }
    printf 'Version 1\n' > "$work/source/document.txt"
    snapshot; first_snapshot=$SNAPSHOT_RESULT
    printf 'Version 2\n' > "$work/source/document.txt"
    snapshot
    printf 'Version 3\n' > "$work/source/document.txt"
    snapshot
    printf 'Available: %s\n' "${history[@]}"
    restore_snapshot "$first_snapshot"
    [[ $(cat -- "$work/source/document.txt") == 'Version 1' ]]
    printf 'Restored: %s\n' "$(cat -- "$work/source/document.txt")"
)
snapshot_demo
```

### Key Moment
"This example makes full copies. It illustrates saved states, not the incremental, deduplicated or copy-on-write algorithms of Git, Time Machine or ZFS. Restore stages a copy and performs two renames with rollback on failure; the entire restore is not one atomic replacement."

---

## Demo 3: Local Release Activation 🚀

### Wow Factor
We change the local path that selects a prepared application release and verify the recorded rollback target.

### Disposable demonstration

From the repository root, the complete maintained function below creates and removes only its own workspace. It does not inspect or modify the user's existing data.

```bash
SEM06_DIR=$(realpath -- SEM06)
EXAMPLE_DIR="$SEM06_DIR/scripts/examples"
release_demo() (
    set -euo pipefail
    local work= version digest previous
    trap '[[ -z ${work:-} ]] || rm -rf -- "$work"' EXIT
    work=$(mktemp -d) || exit 1
    mkdir -- "$work/source" "$work/releases"
    for version in v1 v2; do
        printf 'Application %s\n' "$version" > "$work/source/index.html"
        tar -czf "$work/$version.tar.gz" -C "$work/source" index.html
        digest=$(sha256sum -- "$work/$version.tar.gz"); digest=${digest%% *}
        python3 "$EXAMPLE_DIR/release_reference.py" create "$work/releases" demo "$version" "$work/$version.tar.gz" "$digest" >/dev/null
    done
    python3 "$EXAMPLE_DIR/release_reference.py" activate "$work/releases" demo v1
    printf 'Before: %s\n' "$(readlink -- "$work/releases/demo/current")"
    python3 "$EXAMPLE_DIR/release_reference.py" activate "$work/releases" demo v2
    printf 'After: %s\n' "$(readlink -- "$work/releases/demo/current")"
    previous=$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1]))["previous"])' "$work/releases/demo/transition.json")
    python3 "$EXAMPLE_DIR/release_reference.py" activate "$work/releases" demo "$previous"
    printf 'Rolled back: %s\n' "$(readlink -- "$work/releases/demo/current")"
    cat -- "$work/releases/demo/current/index.html"
)
release_demo
```

### Key Moment
"A staged symlink followed by same-filesystem os.replace atomically changes a directory entry. Service continuity, request draining, database compatibility and capacity remain separate conditions; this file-only fixture measures none of them."

---

## Demo 4: Process Tree Visualiser 🌳

### Wow Factor
Real-time visualisation of process tree, showing parent-child relationships.

### Demo Script

```bash
process_demo() (
    set -euo pipefail
    local -a children=()
    local pid parent command steps=0
    cleanup_children() {
        local child
        for child in "${children[@]}"; do kill -TERM "$child" 2>/dev/null || :; done
        for child in "${children[@]}"; do wait "$child" 2>/dev/null || :; done
    }
    trap cleanup_children EXIT
    trap 'exit 130' INT
    trap 'exit 143' TERM
    for duration in 8 9 10; do sleep "$duration" & children+=("$!"); done
    printf 'Owned children: %s\n' "${children[*]}"
    pid=$BASHPID
    while [[ $pid =~ ^[1-9][0-9]*$ ]] && ((steps < 64)); do
        command=$(ps -p "$pid" -o comm=) || break
        parent=$(ps -p "$pid" -o ppid=) || break
        parent=${parent//[[:space:]]/}
        printf '%s (PID %s; parent %s)\n' "$command" "$pid" "$parent"
        [[ $parent =~ ^[0-9]+$ && $parent != "$pid" ]] || break
        pid=$parent; steps=$((steps+1))
    done
    printf 'Ancestry is a time-dependent observation; disappearing entries are possible.\n'
)
process_demo
```

### Key Moment
"The observed ancestry can change during traversal. Namespace roots and subreapers affect reparenting. This demo tracks, signals and waits only its three direct children; EXIT cleanup cannot run after SIGKILL or host loss."

---

## Demo 5: Signal Catcher 📡

### Wow Factor
Interactive demonstration of Unix signals - send signals and watch them being caught.

### Demo Script

```bash
#!/bin/bash
# signal_catcher.sh - Interactive signal demonstration

echo "=== SIGNAL CATCHER ==="
echo "My PID: $$"
echo ""
echo "Open another terminal and send signals:"
echo "  kill -SIGUSR1 $$"
echo "  kill -SIGUSR2 $$"
echo "  kill -SIGTERM $$"
echo "  kill -SIGINT $$  (or Ctrl+C here)"
echo ""

# Signal handlers
trap 'echo "📨 Caught SIGUSR1 - Custom signal 1!"' SIGUSR1
trap 'echo "📨 Caught SIGUSR2 - Custom signal 2!"' SIGUSR2
trap 'echo "📨 Caught SIGTERM - Termination request (graceful)"; exit 143' SIGTERM
trap 'echo "📨 Caught SIGINT - Interrupt (Ctrl+C)"; exit 130' SIGINT
trap 'echo "📨 Caught SIGHUP - Hangup (terminal closed)"' SIGHUP

echo "Waiting for signals for at most 30 seconds (Ctrl+C to exit)"
echo ""

# Counter to show we're alive
count=0
while ((count < 30)); do
    count=$((count+1))
    echo -ne "\r⏱️  Running for ${count}s... "
    sleep 1
done
```

### Key Moment
"Signals are how processes communicate. Trap catches them and executes custom code. SIGKILL (kill -9) cannot be caught - it's the nuclear option."

---

## Demo 6: File Descriptor Magic 🎩

### Wow Factor
Demonstrates file descriptors and advanced redirection.

### Demo Script

```bash
descriptor_demo() (
    set -euo pipefail
    local work=
    trap 'exec 3>&-; [[ -z ${work:-} ]] || rm -rf -- "$work"' EXIT
    work=$(mktemp -d) || exit 1
    exec 3>"$work/custom_output.txt"
    printf 'Hello from FD 3!\n' >&3
    printf 'FD 3 target: %s\n' "$(readlink -- "/proc/$BASHPID/fd/3")"
    cat -- "$work/custom_output.txt"
    exec 4>&1
    exec 1>"$work/stdout_capture.txt"
    printf 'This goes to the owned file\n'
    exec 1>&4
    exec 4>&-
    printf 'Captured: %s\n' "$(cat -- "$work/stdout_capture.txt")"
    exec 3>&-
)
descriptor_demo
```

### Key Moment
"0=stdin, 1=stdout, 2=stderr, but you can create custom FDs (3-9). Pipes and redirections are just file descriptor manipulations."

---

## Presentation Tips

### Timing

| Demo | Duration | When to Use |
|------|----------|-------------|
| Dashboard | 5 min | Seminar opening |
| Time Machine | 7 min | After Backup section |
| Local Release Activation | 5 min | After Deployer section |
| Process Tree | 5 min | When discussing fork/exec |
| Signal Catcher | 5 min | During trap and signals |
| FD Magic | 7 min | During advanced redirection |

### Do's and Don'ts

**Do:**
- Test beforehand
- Explain whilst typing
- Leave pauses for "wow"
- Connect with theory

**Don't:**
- Don't read from screen
- Don't skip steps
- Don't ignore errors
- Don't rush

---

## Complete Demo Files

Run `bash SEM06/scripts/examples/owned_demos.sh --help` for the four maintained disposable modes. The dashboard uses `monitor_examples.sh`; the bounded signal catcher is shown in full above. There are no `--demo` or `--step` switches. These demonstrations are local teaching fixtures, not native acceptance of a deployed service.

---

*Document generated for SEM06 CAPSTONE — Operating Systems*  
*ASE Bucharest - CSIE | 2024-2025*
