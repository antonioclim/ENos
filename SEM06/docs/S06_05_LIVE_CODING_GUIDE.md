# Live Coding Guide — CAPSTONE SEM06

> **Operating Systems** | ASE Bucharest - CSIE  
> Seminar 6: Integrated Projects (Monitor, Backup, Deployer)  
> Instructor Guide

---

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
# Terminal must be visible to entire class
cd ~/sem06/monitor_demo
# Large font size, good contrast
```

### Step 1: Reading /proc/stat (5 min)

**Say:** "All CPU information comes from the pseudo-file /proc/stat. Let's see what it contains."

```bash
# Question: What do you think we find in /proc/stat?
cat /proc/stat | head -5
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
# First reading
read -r cpu user nice system idle rest < <(grep "^cpu " /proc/stat)
total1=$((user + nice + system + idle))
idle1=$idle

# Wait one second
sleep 1

# Second reading
read -r cpu user nice system idle rest < <(grep "^cpu " /proc/stat)
total2=$((user + nice + system + idle))
idle2=$idle

# Calculate difference
total_diff=$((total2 - total1))
idle_diff=$((idle2 - idle1))

# CPU usage = 100 - idle%
cpu_usage=$((100 * (total_diff - idle_diff) / total_diff))
echo "CPU Usage: ${cpu_usage}%"
```

### Step 4: Reusable function (5 min)

```bash
get_cpu_usage() {
    local cpu user nice system idle rest
    local total1 idle1 total2 idle2
    
    read -r cpu user nice system idle rest < <(grep "^cpu " /proc/stat)
    total1=$((user + nice + system + idle))
    idle1=$idle
    
    sleep 1
    
    read -r cpu user nice system idle rest < <(grep "^cpu " /proc/stat)
    total2=$((user + nice + system + idle))
    idle2=$idle
    
    echo $((100 * (total2 - total1 - idle2 + idle1) / (total2 - total1)))
}

# Test
echo "CPU: $(get_cpu_usage)%"
```

### Checkpoint

- Did everyone understand how we read from /proc?
- Questions about awk or read?

---

## Demo 2: Backup System (25 min)

### Objective
Build an incremental backup system with checksum verification.

### Step 1: Directory structure (3 min)

```bash
mkdir -p ~/backup_demo/{source,backups}
cd ~/backup_demo

# Create test files
echo "Important document v1" > source/doc1.txt
echo "Application configuration" > source/config.ini
mkdir source/logs
echo "Log entry 1" > source/logs/app.log
```

### Step 2: Full backup with tar (5 min)

**Question:** "What options do we use for tar? c-create, z-gzip, v-verbose, f-file"

```bash
BACKUP_NAME="backup_$(date +%Y%m%d_%H%M%S).tar.gz"
tar czvf "backups/$BACKUP_NAME" source/

# Verify
ls -lh backups/
tar tzvf "backups/$BACKUP_NAME"
```

### Step 3: Checksum for integrity (5 min)

```bash
# Generate checksum
cd backups
sha256sum "$BACKUP_NAME" > "$BACKUP_NAME.sha256"
cat "$BACKUP_NAME.sha256"

# Verify
sha256sum -c "$BACKUP_NAME.sha256"
# OK!

# Simulate corruption
echo "corrupt" >> "$BACKUP_NAME"
sha256sum -c "$BACKUP_NAME.sha256"
# FAILED!
```

### Step 4: Incremental backup (7 min)

```bash
cd ~/backup_demo

# Create timestamp marker
touch backups/.last_backup

# Modify a file
sleep 2
echo "Important document v2" > source/doc1.txt
echo "New file" > source/new_file.txt

# Find modified files
find source -newer backups/.last_backup -type f

# Incremental backup
INCR_BACKUP="incremental_$(date +%Y%m%d_%H%M%S).tar.gz"
find source -newer backups/.last_backup -type f -print0 | \
    xargs -0 tar czvf "backups/$INCR_BACKUP"

# Update marker
touch backups/.last_backup
```

### Step 5: Complete function (5 min)

```bash
do_backup() {
    local type="${1:-full}"
    local source_dir="$2"
    local backup_dir="$3"
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local backup_file
    
    if [[ "$type" == "full" ]]; then
        backup_file="$backup_dir/full_${timestamp}.tar.gz"
        tar czf "$backup_file" "$source_dir"
    else
        backup_file="$backup_dir/incr_${timestamp}.tar.gz"
        find "$source_dir" -newer "$backup_dir/.last_backup" -type f -print0 | \
            xargs -0 tar czf "$backup_file" 2>/dev/null || true
    fi
    
    sha256sum "$backup_file" > "$backup_file.sha256"
    touch "$backup_dir/.last_backup"
    
    echo "$backup_file"
}

# Test
do_backup full source backups
do_backup incremental source backups
```

---

## Demo 3: Deployer with Rollback (20 min)

### Objective
Demonstrate deployment with symlink and instant rollback.

### Step 1: Releases structure (5 min)

```bash
mkdir -p ~/deploy_demo/{releases,shared}
cd ~/deploy_demo

# Simulate versions
mkdir releases/v1.0.0
echo "App v1.0.0" > releases/v1.0.0/index.html
echo "Config shared" > shared/config.ini

mkdir releases/v1.1.0
echo "App v1.1.0 - NEW!" > releases/v1.1.0/index.html

# Current symlink
ln -s releases/v1.0.0 current
ls -la current
cat current/index.html
```

### Step 2: Deploy with ln -sf (5 min)

**Question:** "Why ln -sf and not rm + ln?"

```bash
# Demonstrate the problem with rm + ln
# (DON'T RUN IN PRODUCTION!)
rm current
# At this moment - DOWNTIME!
ln -s releases/v1.1.0 current

# Correct method - atomic
ln -sf releases/v1.1.0 current
# Zero downtime!

cat current/index.html
```

### Step 3: Health check (5 min)

```bash
check_health() {
    local url="${1:-http://localhost:8080/health}"
    local retries=3
    local wait=2
    
    for ((i=1; i<=retries; i++)); do
        if curl -sf "$url" > /dev/null 2>&1; then
            echo "Health check passed"
            return 0
        fi
        echo "Attempt $i failed, waiting ${wait}s..."
        sleep $wait
    done
    
    echo "Health check failed after $retries attempts"
    return 1
}

# Simulate (without real server)
# check_health http://localhost:8080/health
```

### Step 4: Rollback (5 min)

```bash
rollback() {
    local current_version=$(readlink current | xargs basename)
    local releases=($(ls -1 releases | sort -V))
    
    # Find previous version
    for ((i=0; i<${#releases[@]}; i++)); do
        if [[ "${releases[$i]}" == "$current_version" ]]; then
            if [[ $i -gt 0 ]]; then
                local prev="${releases[$((i-1))]}"
                ln -sf "releases/$prev" current
                echo "Rolled back to $prev"
                return 0
            fi
        fi
    done
    
    echo "No previous version to rollback to"
    return 1
}

# Test
readlink current
rollback
readlink current
```

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

Complete demo scripts are in:
- `scripts/demo_monitor.sh`
- `scripts/demo_backup.sh`
- `scripts/demo_deployer.sh`

Run with `--help` for options or `--step` for step-by-step mode.

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
