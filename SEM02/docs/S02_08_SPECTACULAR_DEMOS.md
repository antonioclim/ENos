# Spectacular Demos - Seminar 3-4
## Operating Systems | Operators, Redirection, Filters, Loops

**Version**: 1.0 | **Purpose**: Wow-factor for engagement and concept memorisation  
**Inspired by**: BASH_MAGIC_COLLECTION.md

---

## DEPENDENCIES AND INSTALLATION

### Quick Installation (all tools)

```bash
# Run BEFORE the seminar to prepare demos
sudo apt update && sudo apt install -y \
    figlet toilet lolcat cowsay fortune \
    pv dialog whiptail \
    htop tree ncdu \
    bc jq
```

### Availability Check

```bash

*Personal note: Many prefer `zsh`, but I stick with Bash because it's the standard on servers. Consistency beats comfort.*

# Check script (can be run in setup_seminar.sh)
check_tool() {
    if command -v "$1" &>/dev/null; then
        echo -e "✓ $1 \033[32mavailable\033[0m"
    else
        echo -e "✗ $1 \033[31mmissing\033[0m (sudo apt install $1)"
    fi
}

echo "═══ DEMO TOOLS CHECK ═══"
for tool in figlet toilet lolcat cowsay pv dialog htop tree bc; do
    check_tool "$tool"
done
```

### Fallback for Missing Tools

All demos include fallback for situations when tools are not installed. The code checks availability and provides text-based alternatives.

---

## DEMOS FOR OPENING (HOOK)

### DEMO H1: Pipeline Power Showcase
**Moment**: First 3 minutes | **Wow Factor**: ⭐⭐⭐⭐⭐

```bash
#!/bin/bash
# demo_h1_pipeline_power.sh - Spectacular hook with pipeline power

clear
echo -e "\n\033[1;36m"
if command -v figlet &>/dev/null; then
    figlet -c "PIPES" | lolcat 2>/dev/null || figlet -c "PIPES"

> 💡 Experience shows that debugging is 80% reading carefully and 20% writing new code.

else
    echo "╔═══════════════════════════════════════════╗"
    echo "║           P I P E L I N E S               ║"
    echo "╚═══════════════════════════════════════════╝"
fi
echo -e "\033[0m"

sleep 1

echo -e "\033[1;33m>>> Finding the 5 largest files in /usr...\033[0m\n"
sleep 0.5

# Spectacular pipeline with formatted output
find /usr -type f -printf '%s %p\n' 2>/dev/null | \
    sort -rn | \
    head -5 | \
    while read size path; do
        # Formatting with colours and animation
        size_mb=$(echo "scale=2; $size / 1048576" | bc)
        printf "\033[1;32m%8.2f MB\033[0m → \033[1;37m%s\033[0m\n" "$size_mb" "$path"
        sleep 0.3
    done

echo ""
echo -e "\033[1;35m✨ All in a SINGLE command with PIPES! ✨\033[0m"
echo ""
echo -e "\033[1;36mCommand: find | sort | head | while read\033[0m"
sleep 2
```

### DEMO H2: Epic Countdown
**Moment**: Alternative to H1 | **Wow Factor**: ⭐⭐⭐⭐⭐

```bash

*(Bash has ugly syntax, I admit. But it runs everywhere, and that matters enormously in practice.)*

#!/bin/bash
# demo_h2_countdown.sh - Spectacular visual countdown

countdown() {
    local n=${1:-5}
    for i in $(seq $n -1 1); do
        clear
        if command -v figlet &>/dev/null; then
            figlet -f big -c "$i" | lolcat 2>/dev/null || figlet -f big -c "$i"
        else
            echo -e "\n\n\n"
            echo "         ╔═══════╗"
            echo "         ║   $i   ║"
            echo "         ╚═══════╝"
        fi
        sleep 1
    done
    
    clear
    if command -v figlet &>/dev/null; then
        figlet -c "BASH!" | lolcat 2>/dev/null || figlet -c "BASH!"
        echo ""
        figlet -f small -c "Let's code!" | lolcat 2>/dev/null || figlet -f small -c "Let's code!"
    else
        echo -e "\n\n"
        echo "╔═══════════════════════════════════════╗"
        echo "║         B A S H   M A G I C           ║"
        echo "║           Let's code!                 ║"
        echo "╚═══════════════════════════════════════╝"
    fi
    echo ""
}

countdown 5
```

### DEMO H3: System Heartbeat
**Moment**: Simple alternative | **Wow Factor**: ⭐⭐⭐⭐

```bash
#!/bin/bash
# demo_h3_heartbeat.sh - Real-time system pulse

echo -e "\033[1;36m>>> SYSTEM PULSE (Ctrl+C to stop)\033[0m\n"

trap "echo -e '\n\033[1;32m✓ Demo finished\033[0m'; exit" INT

count=0
while [[ $count -lt 10 ]]; do
    load=$(cat /proc/loadavg | cut -d' ' -f1)
    mem=$(free -h | awk '/^Mem/{print $3"/"$2}')
    procs=$(ps aux 2>/dev/null | wc -l)
    disk=$(df -h / | awk 'NR==2{print $5}')
    
    printf "\r\033[K💓 Load: \033[1;33m%-5s\033[0m | Mem: \033[1;32m%-12s\033[0m | Procs: \033[1;35m%-4d\033[0m | Disk: \033[1;31m%s\033[0m" \
        "$load" "$mem" "$procs" "$disk"
    
    sleep 1
    ((count++))
done
echo -e "\n\n\033[1;36m>>> This is the power of LOOPS and PIPELINES!\033[0m"
```

---

## CONTROL OPERATOR DEMOS

### DEMO C1: Visualising && and ||
**Concept**: Exit codes and conditional execution

```bash
#!/bin/bash
# demo_c1_conditionals.sh - Visualising && and || operators

demo_section() {
    echo ""
    echo -e "\033[1;33m═══ $1 ═══\033[0m"
    echo ""
}

demo_section "THE && OPERATOR (AND)"
echo "Command: mkdir test_dir && echo 'Created successfully!'"
echo ""
echo -n "Executing first time: "
sleep 1
mkdir test_dir 2>/dev/null && echo -e "\033[1;32m✓ Created successfully!\033[0m" || echo -e "\033[1;31m✗ Error\033[0m"

sleep 1
echo -n "Executing second time: "
sleep 1
mkdir test_dir 2>/dev/null && echo -e "\033[1;32m✓ Created successfully!\033[0m" || echo -e "\033[1;31m✗ Directory already exists!\033[0m"

rm -rf test_dir

demo_section "THE || OPERATOR (OR)"
echo "Command: cat /nonexistent || echo 'File does not exist'"
echo ""
echo -n "Executing: "
sleep 1
cat /nonexistent 2>/dev/null || echo -e "\033[1;33m⚠ File does not exist - displayed fallback message\033[0m"

demo_section "COMBINING && ||"
echo "Pattern: cmd && echo 'OK' || echo 'FAIL'"
echo ""
echo -n "Test with successful command (ls /): "
sleep 1
ls / >/dev/null && echo -e "\033[1;32m✓ OK\033[0m" || echo -e "\033[1;31m✗ FAIL\033[0m"

echo -n "Test with failed command (ls /xxx): "
sleep 1
ls /xxx 2>/dev/null && echo -e "\033[1;32m✓ OK\033[0m" || echo -e "\033[1;31m✗ FAIL\033[0m"

echo ""
echo -e "\033[1;36m>>> Notice how && and || control the execution FLOW!\033[0m"
```

### DEMO C2: Background Jobs Live
**Concept**: & and job control

```bash
#!/bin/bash
# demo_c2_background.sh - Background process demonstration

echo -e "\033[1;36m═══ DEMO: BACKGROUND JOBS ═══\033[0m\n"

echo "Starting 3 background processes with different durations..."
echo ""

# Start processes
(sleep 3; echo -e "\n\033[1;32m[Job 1] ✓ Finished after 3s\033[0m") &
echo "Job 1 started (3 seconds): PID=$!"

(sleep 2; echo -e "\n\033[1;33m[Job 2] ✓ Finished after 2s\033[0m") &
echo "Job 2 started (2 seconds): PID=$!"

(sleep 1; echo -e "\n\033[1;35m[Job 3] ✓ Finished after 1s\033[0m") &
echo "Job 3 started (1 second): PID=$!"

echo ""
echo -e "\033[1;36mActive jobs:\033[0m"
jobs -l

echo ""
echo "Waiting for all processes to finish..."
wait

echo ""
echo -e "\033[1;32m═══ ALL PROCESSES HAVE FINISHED ═══\033[0m"
echo ""
echo -e "\033[1;36m>>> The & operator starts processes in BACKGROUND!\033[0m"
echo -e "\033[1;36m>>> wait waits for all to finish\033[0m"
```

---

## REDIRECTION DEMOS

### DEMO R1: File Descriptors Visual
**Concept**: stdin, stdout, stderr

```bash
#!/bin/bash
# demo_r1_descriptors.sh - File descriptors visualisation

clear
echo -e "\033[1;36m"
cat << 'ASCII'
╔══════════════════════════════════════════════════════════════╗
║               FILE DESCRIPTORS - VISUALISATION               ║
╠══════════════════════════════════════════════════════════════╣
║                                                              ║
║     ┌─────────────┐                   ┌─────────────┐        ║
║     │   STDIN     │ ──────fd 0────▶   │             │        ║
║     │   (input)   │                   │   PROCESS   │        ║
║     └─────────────┘                   │             │        ║
║                                       │  (command)  │        ║
║                      ◀────fd 1─────── │             │        ║
║     ┌─────────────┐                   │             │        ║
║     │   STDOUT    │                   └─────────────┘        ║
║     │   (output)  │                          │               ║
║     └─────────────┘                          │               ║
║                      ◀────fd 2───────────────┘               ║
║     ┌─────────────┐                                          ║
║     │   STDERR    │                                          ║
║     │   (errors)  │                                          ║
║     └─────────────┘                                          ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝
ASCII
echo -e "\033[0m"
sleep 2

echo -e "\033[1;33m>>> Live demonstration...\033[0m\n"

echo "Command: ls /home /nonexistent_directory"
echo ""
sleep 1

echo -e "\033[1;32m[STDOUT - fd 1]:\033[0m"
ls /home 2>/dev/null
echo ""

echo -e "\033[1;31m[STDERR - fd 2]:\033[0m"
ls /nonexistent_directory 2>&1 >/dev/null
echo ""

echo -e "\033[1;36m>>> Observe: STDOUT and STDERR are SEPARATE channels!\033[0m"
```

---

## FILTER DEMOS

### DEMO F1: The uniq Trap
**Concept**: uniq requires sort!

```bash
#!/bin/bash
# demo_f1_uniq_trap.sh - The famous uniq trap

echo -e "\033[1;36m═══ DEMO: THE uniq TRAP ═══\033[0m\n"

# Create test data
cat > /tmp/colours.txt << 'EOF'
red
green
red
blue
green
red
yellow
blue
EOF

echo -e "\033[1;33mOriginal data:\033[0m"
cat -n /tmp/colours.txt
echo ""

sleep 1

echo -e "\033[1;31m>>> WRONG: uniq WITHOUT sort\033[0m"
echo "Command: cat colours.txt | uniq"
echo "Result:"
cat /tmp/colours.txt | uniq | while read line; do
    echo -e "  \033[1;31m$line\033[0m"
done
echo ""
echo -e "\033[1;31m⚠ NOTICE: 'red' and 'green' appear multiple times!\033[0m"
echo -e "\033[1;31m  uniq only removes CONSECUTIVE duplicates!\033[0m"

sleep 2

echo ""
echo -e "\033[1;32m>>> CORRECT: sort | uniq\033[0m"
echo "Command: cat colours.txt | sort | uniq"
echo "Result:"
cat /tmp/colours.txt | sort | uniq | while read line; do
    echo -e "  \033[1;32m$line\033[0m"
done

sleep 1

echo ""
echo -e "\033[1;36m>>> BONUS: sort | uniq -c for frequencies\033[0m"
echo "Result:"
cat /tmp/colours.txt | sort | uniq -c | sort -rn | while read count colour; do
    printf "  \033[1;35m%2d×\033[0m %s\n" "$count" "$colour"
done

rm -f /tmp/colours.txt

echo ""
echo -e "\033[1;33m═══════════════════════════════════════════════════════\033[0m"
echo -e "\033[1;33m  REMEMBER: uniq needs SORT to work properly!          \033[0m"
echo -e "\033[1;33m═══════════════════════════════════════════════════════\033[0m"
```

### DEMO F2: Incremental Pipeline
**Concept**: Step by step construction

```bash
#!/bin/bash
# demo_f2_pipeline_build.sh - Incremental pipeline construction

echo -e "\033[1;36m═══ DEMO: STEP BY STEP PIPELINE CONSTRUCTION ═══\033[0m\n"

echo "OBJECTIVE: Top 5 users by number of processes"
echo ""
sleep 1

echo -e "\033[1;33m[Step 1] ps aux - all processes:\033[0m"
ps aux | head -3
echo "..."
sleep 1

echo ""
echo -e "\033[1;33m[Step 2] | awk '{print \$1}' - extract only username:\033[0m"
ps aux | awk '{print $1}' | head -5
sleep 1

echo ""
echo -e "\033[1;33m[Step 3] | sort - alphabetical sorting:\033[0m"
ps aux | awk '{print $1}' | sort | head -5
sleep 1

echo ""
echo -e "\033[1;33m[Step 4] | uniq -c - count occurrences:\033[0m"
ps aux | awk '{print $1}' | sort | uniq -c | head -5
sleep 1

echo ""
echo -e "\033[1;33m[Step 5] | sort -rn - descending sort:\033[0m"
ps aux | awk '{print $1}' | sort | uniq -c | sort -rn | head -5
sleep 1

echo ""
echo -e "\033[1;33m[Step 6] | head -5 - only first 5:\033[0m"
ps aux | awk '{print $1}' | sort | uniq -c | sort -rn | head -5

echo ""
echo -e "\033[1;32m═══════════════════════════════════════════════════════\033[0m"
echo -e "\033[1;32mFINAL PIPELINE:\033[0m"
echo -e "\033[1;36mps aux | awk '{print \$1}' | sort | uniq -c | sort -rn | head -5\033[0m"
echo -e "\033[1;32m═══════════════════════════════════════════════════════\033[0m"
```

---

## LOOP DEMOS

### DEMO B1: The Brace Expansion Trap
**Concept**: {1..$N} doesn't work with variables!

```bash
#!/bin/bash
# demo_b1_brace_trap.sh - Brace expansion trap with variables

echo -e "\033[1;36m═══ DEMO: THE BRACE EXPANSION TRAP ═══\033[0m\n"

echo -e "\033[1;32m>>> WORKS: Brace expansion with literal values\033[0m"
echo 'Command: for i in {1..5}; do echo $i; done'
echo "Result:"
for i in {1..5}; do echo -n "$i "; done
echo ""
echo ""

sleep 2

echo -e "\033[1;31m>>> DOESN'T WORK: Brace expansion with variables\033[0m"
echo 'N=5'
echo 'Command: for i in {1..$N}; do echo $i; done'
echo "Result:"
N=5
for i in {1..$N}; do echo -n "$i "; done
echo ""
echo -e "\033[1;31m⚠ It displayed LITERALLY '{1..5}' because brace expansion\033[0m"
echo -e "\033[1;31m  happens BEFORE variable substitution!\033[0m"
echo ""

sleep 2

echo -e "\033[1;32m>>> SOLUTION 1: Use seq\033[0m"
echo 'Command: for i in $(seq 1 $N); do echo $i; done'
echo "Result:"
for i in $(seq 1 $N); do echo -n "$i "; done
echo ""
echo ""

sleep 1

echo -e "\033[1;32m>>> SOLUTION 2: Use C-style for\033[0m"
echo 'Command: for ((i=1; i<=N; i++)); do echo $i; done'
echo "Result:"
for ((i=1; i<=N; i++)); do echo -n "$i "; done
echo ""

echo ""
echo -e "\033[1;33m═══════════════════════════════════════════════════════\033[0m"
echo -e "\033[1;33m  REMEMBER: {1..\$N} → seq or for ((...))\033[0m"
echo -e "\033[1;33m═══════════════════════════════════════════════════════\033[0m"
```

### DEMO B2: The Subshell Problem with Pipe
**Concept**: Variables don't persist in pipe

```bash
#!/bin/bash
# demo_b2_subshell_trap.sh - Subshell problem with pipe

echo -e "\033[1;36m═══ DEMO: THE SUBSHELL PROBLEM WITH PIPE ═══\033[0m\n"

# Create test file
echo -e "line1\nline2\nline3" > /tmp/test_lines.txt

echo -e "\033[1;31m>>> THE PROBLEM: Variable does NOT update\033[0m"
echo ""

count=0
echo "BEFORE: count=$count"
echo ""
echo 'Command: cat file | while read line; do ((count++)); done'
cat /tmp/test_lines.txt | while read line; do
    ((count++))
    echo "  In loop: count=$count (line: $line)"
done
echo ""
echo "AFTER: count=$count"
echo ""
echo -e "\033[1;31m⚠ count is still 0! The while loop ran in a SUBSHELL!\033[0m"

sleep 2

echo ""
echo -e "\033[1;32m>>> THE SOLUTION: Redirect instead of pipe\033[0m"
echo ""

count=0
echo "BEFORE: count=$count"
echo ""
echo 'Command: while read line; do ((count++)); done < file'
while read line; do
    ((count++))
    echo "  In loop: count=$count (line: $line)"
done < /tmp/test_lines.txt
echo ""
echo "AFTER: count=$count"
echo ""
echo -e "\033[1;32m✓ count is 3! Redirect does NOT create subshell!\033[0m"

rm -f /tmp/test_lines.txt

echo ""
echo -e "\033[1;33m═══════════════════════════════════════════════════════\033[0m"
echo -e "\033[1;33m  REMEMBER: Use 'done < file' NOT 'cat file |'         \033[0m"
echo -e "\033[1;33m═══════════════════════════════════════════════════════\033[0m"
```

---

## INTERACTIVE FINAL DEMO

### DEMO I1: System Explorer with Dialog
**Moment**: Spectacular final demo | **Wow Factor**: ⭐⭐⭐⭐⭐

```bash
#!/bin/bash
# demo_i1_sys_explorer.sh - Interactive system explorer

if ! command -v dialog &>/dev/null; then
    echo -e "\033[1;33m⚠ dialog is not installed. Install with: sudo apt install dialog\033[0m"
    exit 1
fi

while true; do
    choice=$(dialog --stdout --title "🔍 SYSTEM EXPLORER" \
        --menu "Select desired information:" 18 60 10 \
        1 "📊 CPU Info" \
        2 "💾 Memory Info" \
        3 "💿 Disk Info" \
        4 "🔄 Active processes (top 10)" \
        5 "🌐 Network connections" \
        6 "👤 Logged in users" \
        7 "📈 Load Average" \
        8 "🕐 System Uptime" \
        9 "❌ Exit")
    
    [[ -z "$choice" ]] && break
    
    case $choice in
        1) dialog --title "📊 CPU Info" --msgbox "$(lscpu | head -15)" 20 70 ;;
        2) dialog --title "💾 Memory" --msgbox "$(free -h)" 12 50 ;;
        3) dialog --title "💿 Disks" --msgbox "$(df -h | head -10)" 15 70 ;;
        4) dialog --title "🔄 Top Processes" --msgbox "$(ps aux --sort=-%mem | head -11)" 18 100 ;;
        5) dialog --title "🌐 Connections" --msgbox "$(ss -tuln | head -15)" 20 80 ;;
        6) dialog --title "👤 Users" --msgbox "$(who)" 12 50 ;;
        7) dialog --title "📈 Load" --msgbox "$(cat /proc/loadavg)" 8 50 ;;
        8) dialog --title "🕐 Uptime" --msgbox "$(uptime -p)" 8 50 ;;
        9) break ;;
    esac
done

clear
echo -e "\033[1;32m✓ System Explorer closed. Goodbye!\033[0m"
```

---

## DEMO INDEX

| Demo | Concept | Duration | Wow Factor | Optimal Moment |
|------|---------|----------|------------|----------------|
| H1 | Pipeline power | 2 min | ⭐⭐⭐⭐⭐ | Seminar opening |
| H2 | Countdown | 1 min | ⭐⭐⭐⭐⭐ | Alternative opening |
| H3 | System heartbeat | 1 min | ⭐⭐⭐⭐ | Quick hook |
| C1 | && and \|\| | 2 min | ⭐⭐⭐ | After operator theory |
| C2 | Background jobs | 2 min | ⭐⭐⭐⭐ | After explaining & |
| R1 | File descriptors | 2 min | ⭐⭐⭐ | Start of redirection |
| R2 | Progress bar pv | 2 min | ⭐⭐⭐⭐⭐ | Redirect wow moment |
| F1 | The uniq trap | 2 min | ⭐⭐⭐⭐ | CRITICAL - after uniq |
| F2 | Pipeline build | 3 min | ⭐⭐⭐⭐ | Incremental demo |
| B1 | Brace trap | 2 min | ⭐⭐⭐⭐ | CRITICAL - after for |
| B2 | Subshell pipe | 2 min | ⭐⭐⭐⭐ | CRITICAL - after while |
| I1 | System explorer | 3 min | ⭐⭐⭐⭐⭐ | Spectacular ending |

---

*Document generated for Seminar 3-4 OS | ASE Bucharest - CSIE*  
*Spectacular demos for engagement and critical concept memorisation*
