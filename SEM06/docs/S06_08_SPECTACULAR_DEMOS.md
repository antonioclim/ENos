# Spectacular Demos — CAPSTONE SEM06

> **Operating Systems** | ASE Bucharest - CSIE  
> Seminar 6: Integrated Projects (Monitor, Backup, Deployer)

---

## Purpose of Demos

Spectacular demos serve to:
- **Capture attention** — visual or conceptual "wow" effect
- **Demonstrate relevance** — "look what you can do in industry"
- **Motivate learning** — "I want to know how this works"
- **Anchor concepts** — emotional association with material

---

## Demo 1: Real-Time System Dashboard 🖥️

### Wow Factor
A live dashboard showing system state in real time, updated every second, directly in terminal.

### Preparation

```bash
cd ~/sem06/demo
```

### Demo Script

```bash
#!/bin/bash
# dashboard_live.sh - Real-time system dashboard

while true; do
    clear
    
    # Header with effect
    echo -e "\033[1;36m"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║           SYSTEM DASHBOARD - $(date '+%H:%M:%S')                    ║"
    echo "║           Host: $(hostname)                                   "
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "\033[0m"
    
    # CPU Bar
    cpu=$(grep "^cpu " /proc/stat | awk '{u=$2+$4; t=$2+$4+$5; if(NR==1){u1=u;t1=t}else{print int((u-u1)*100/(t-t1))}}')
    cpu=${cpu:-$(top -bn1 | grep "Cpu(s)" | awk '{print int($2)}')}
    bar=$(printf "%-${cpu}s" | tr ' ' '█')
    empty=$(printf "%-$((100-cpu))s" | tr ' ' '░')
    echo -e "CPU:  [\033[32m${bar}\033[0m${empty}] ${cpu}%"
    
    # Memory Bar
    mem=$(free | awk '/Mem:/ {print int($3/$2*100)}')
    bar=$(printf "%-${mem}s" | tr ' ' '█')
    empty=$(printf "%-$((100-mem))s" | tr ' ' '░')
    echo -e "MEM:  [\033[33m${bar}\033[0m${empty}] ${mem}%"
    
    # Disk Bar
    disk=$(df / | awk 'NR==2 {print int($3/$2*100)}')
    bar=$(printf "%-${disk}s" | tr ' ' '█')
    empty=$(printf "%-$((100-disk))s" | tr ' ' '░')
    echo -e "DISK: [\033[34m${bar}\033[0m${empty}] ${disk}%"
    
    echo ""
    echo -e "\033[1mTop Processes:\033[0m"
    ps aux --sort=-%cpu | head -6 | tail -5 | awk '{printf "  %-10s %5s%% CPU  %5s%% MEM  %s\n", $1, $3, $4, $11}'
    
    echo ""
    echo -e "\033[90mPress Ctrl+C to exit\033[0m"
    
    sleep 1
done
```

### Key Moment
"Everything comes from /proc - text files you can read. It's not magic, it's Unix."

### Variants
- Add network traffic with `/proc/net/dev`
- Add alerting when CPU > 80%
- Export in Prometheus format

---

## Demo 2: Backup Time Machine ⏰

### Wow Factor
Demonstration of "time travel" - restore to any point in the past.

### Preparation

```bash
mkdir -p ~/demo_backup/{source,snapshots}
cd ~/demo_backup
echo "Version 1 - Original" > source/document.txt
```

### Demo Script

```bash
#!/bin/bash
# time_machine.sh - Snapshot-based backup with time travel

SNAPSHOTS_DIR="snapshots"
SOURCE="source"

snapshot() {
    local ts=$(date +%Y%m%d_%H%M%S)
    local snap_dir="$SNAPSHOTS_DIR/$ts"
    
    echo "📸 Creating snapshot: $ts"
    cp -r "$SOURCE" "$snap_dir"
    echo "$ts" >> "$SNAPSHOTS_DIR/history.log"
    echo "✓ Snapshot created"
}

list_snapshots() {
    echo "📜 Available snapshots:"
    ls -1 "$SNAPSHOTS_DIR" | grep -v history.log | while read snap; do
        echo "  → $snap"
    done
}

restore() {
    local target="$1"
    if [[ -d "$SNAPSHOTS_DIR/$target" ]]; then
        echo "⏰ Travelling back to: $target"
        rm -rf "$SOURCE"
        cp -r "$SNAPSHOTS_DIR/$target" "$SOURCE"
        echo "✓ Restored to $target"
    else
        echo "❌ Snapshot not found: $target"
    fi
}

# Demo flow
echo "=== BACKUP TIME MACHINE ==="
echo ""

# Create initial snapshot
snapshot
sleep 2

# Modify file
echo "Version 2 - Modified" > source/document.txt
echo "📝 File modified: $(cat source/document.txt)"
snapshot
sleep 2

# Modify again
echo "Version 3 - Oops, wrong changes!" > source/document.txt
echo "📝 File modified: $(cat source/document.txt)"
snapshot

# Show history
echo ""
list_snapshots

# Restore to first version
echo ""
first_snap=$(ls -1 "$SNAPSHOTS_DIR" | grep -v history.log | head -1)
restore "$first_snap"
echo "📄 Current content: $(cat source/document.txt)"
```

### Key Moment
"This is the principle behind git, Time Machine (macOS) and ZFS snapshots. Incremental backup in action."

---

## Demo 3: Zero-Downtime Deployment 🚀

### Wow Factor
We change the version of an "application" live, without a single second of downtime.

### Preparation

```bash
mkdir -p ~/demo_deploy/{releases,shared}
cd ~/demo_deploy

# Create "versions"
mkdir releases/v1.0.0
echo "<h1>App v1.0.0</h1>" > releases/v1.0.0/index.html

mkdir releases/v2.0.0  
echo "<h1>App v2.0.0 - NEW!</h1>" > releases/v2.0.0/index.html

# Initial link
ln -s releases/v1.0.0 current
```

### Demo Script

```bash
#!/bin/bash
# zero_downtime_deploy.sh

RELEASES="releases"
CURRENT="current"

show_status() {
    local version=$(readlink "$CURRENT" | xargs basename)
    echo "🌐 Current version: $version"
    echo "📄 Content: $(cat $CURRENT/index.html)"
}

deploy() {
    local new_version="$1"
    
    echo "🚀 Deploying $new_version..."
    echo ""
    
    # Show current state
    echo "BEFORE:"
    show_status
    echo ""
    
    # Atomic switch!
    echo "⚡ Switching (atomic operation)..."
    ln -sfn "$RELEASES/$new_version" "$CURRENT"
    
    # Show new state
    echo ""
    echo "AFTER:"
    show_status
}

rollback() {
    local versions=($(ls -1 "$RELEASES" | sort -V))
    local current=$(readlink "$CURRENT" | xargs basename)
    
    for ((i=0; i<${#versions[@]}; i++)); do
        if [[ "${versions[$i]}" == "$current" && $i -gt 0 ]]; then
            local prev="${versions[$((i-1))]}"
            echo "⏪ Rolling back to $prev..."
            ln -sfn "$RELEASES/$prev" "$CURRENT"
            echo "✓ Rollback complete"
            return 0
        fi
    done
    echo "❌ No previous version available"
}

# Demo
echo "=== ZERO-DOWNTIME DEPLOYMENT ==="
echo ""

show_status
echo ""
echo "Press ENTER to deploy v2.0.0..."
read

deploy "v2.0.0"

echo ""
echo "Press ENTER to rollback..."
read

rollback
show_status
```

### Key Moment
"`ln -sfn` is atomic - there is no moment when `current` doesn't point to a valid version. That's the secret of zero-downtime deployment."

---

## Demo 4: Process Tree Visualiser 🌳

### Wow Factor
Real-time visualisation of process tree, showing parent-child relationships.

### Demo Script

```bash
#!/bin/bash
# process_tree.sh - Interactive process tree

show_tree() {
    echo "🌳 Process Tree (your terminal branch):"
    echo ""
    
    # Get current shell's ancestry
    local pid=$$
    local chain=""
    
    while [[ $pid -ne 1 ]]; do
        local cmd=$(ps -p $pid -o comm= 2>/dev/null)
        local ppid=$(ps -p $pid -o ppid= 2>/dev/null | tr -d ' ')
        chain="$cmd ($pid) → $chain"
        pid=$ppid
    done
    
    echo "init (1) → $chain"
    echo ""
    
    # Show children
    echo "🌿 My children:"
    pstree -p $$ 2>/dev/null || ps --ppid $$ -o pid,comm
}

spawn_children() {
    echo "🐣 Spawning child processes..."
    
    # Background processes
    sleep 100 &
    echo "  Child 1: sleep (PID: $!)"
    
    (while true; do sleep 1; done) &
    echo "  Child 2: subshell (PID: $!)"
    
    cat /dev/zero > /dev/null &
    echo "  Child 3: cat (PID: $!)"
    
    echo ""
    show_tree
}

cleanup() {
    echo ""
    echo "🧹 Cleaning up children..."
    pkill -P $$
    echo "✓ All children terminated"
}

trap cleanup EXIT

echo "=== PROCESS TREE VISUALISER ==="
echo ""
show_tree

echo ""
echo "Press ENTER to spawn children..."
read
spawn_children

echo ""
echo "Press ENTER to see updated tree..."
read
show_tree

echo ""
echo "Press ENTER to cleanup and exit..."
read
```

### Key Moment
"Every process has a parent. When the parent dies, children become orphans and are adopted by init/systemd. Trap ensures cleanup."

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
trap 'echo "📨 Caught SIGTERM - Termination request (graceful)"; exit 0' SIGTERM
trap 'echo "📨 Caught SIGINT - Interrupt (Ctrl+C)"; exit 0' SIGINT
trap 'echo "📨 Caught SIGHUP - Hangup (terminal closed)"' SIGHUP

echo "Waiting for signals... (Ctrl+C to exit)"
echo ""

# Counter to show we're alive
count=0
while true; do
    ((count++))
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
#!/bin/bash
# fd_magic.sh - File descriptor demonstration

echo "=== FILE DESCRIPTOR MAGIC ==="
echo ""

# Show current FDs
echo "📂 Current file descriptors:"
ls -la /proc/$$/fd/
echo ""

# Create custom FD
exec 3>custom_output.txt
echo "✨ Created FD 3 pointing to custom_output.txt"
ls -la /proc/$$/fd/3
echo ""

# Write through custom FD
echo "Hello from FD 3!" >&3
echo "📝 Wrote to FD 3"
echo "Content: $(cat custom_output.txt)"
echo ""

# Duplicate FD (backup stdout)
exec 4>&1  # Save stdout to FD 4
echo "✨ Saved stdout to FD 4"

# Redirect stdout to file
exec 1>stdout_capture.txt
echo "This goes to file, not screen"

# Restore stdout
exec 1>&4
exec 4>&-  # Close FD 4
echo "✨ Restored stdout"
echo "Captured: $(cat stdout_capture.txt)"
echo ""

# Cleanup
exec 3>&-
rm -f custom_output.txt stdout_capture.txt
echo "🧹 Cleaned up"
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
| Zero-Downtime | 5 min | After Deployer section |
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

Scripts are in `scripts/`:
- `scripts/demo_monitor.sh` — Complete monitor
- `scripts/demo_backup.sh` — Backup with all functions
- `scripts/demo_deployer.sh` — Deployer with strategies

Run with `--demo` for spectacle mode or `--step` for step-by-step.

---

*Document generated for SEM06 CAPSTONE — Operating Systems*  
*ASE Bucharest - CSIE | 2024-2025*
