# Spectacular Demos - Seminar 1-2
## Integrating BASH_MAGIC_COLLECTION for Visual Impact

**Purpose**: Capture students' attention through memorable visual demonstrations  
**Principle**: "Wow factor" + didactic explanation = deep understanding

> I first used figlet in 2019 when I wanted to grab attention from a group that was checking their phones. It worked — they asked me to teach them how to do it. Since then, every seminar starts with a "magic" moment.

---

## PREPARATION - TOOLS INSTALLATION

Run **BEFORE** the seminar on the presentation machine:

```bash

*Personal note: I prefer Bash scripts for simple automation and Python when the logic becomes complex. It's a matter of pragmatism.*

# Essential packages for demos
sudo apt update && sudo apt install -y \
    figlet toilet cmatrix sl cowsay fortune lolcat \
    htop btop tree ncdu pv dialog whiptail \
    strace ltrace bc jq

# Verification
for cmd in figlet lolcat cmatrix cowsay fortune tree pv dialog; do
    which $cmd >/dev/null && echo "✅ $cmd" || echo "❌ $cmd - MISSING!"
done
```

---

## DEMO 1:

> **Note**: These demos are tested on real students, not just IT colleagues who "already know everything". The "wow" effect is guaranteed if you present them with enthusiasm. Pro tip: rehearse 2-3 times before the seminar, timing matters! Opening Hook
**Moment**: First 3 minutes of the seminar  
**Purpose**: Capture attention, establish interactive tone

> 💡 A student once asked me why we can't just use the graphical interface for everything — the answer is that the terminal is 10 times faster for repetitive operations.


### Complete Script:

```bash

*(Bash has ugly syntax, I admit. But it runs everywhere and that matters enormously in practice.)*

#!/bin/bash
# hook_opening.sh - Run at the beginning of the seminar

clear
sleep 1

# Dramatic banner
figlet -f slant "BASH" | lolcat -a -d 5
sleep 2

# Matrix effect (short)
timeout 3 cmatrix -b -C green
clear

# Friendly message
cowsay -f tux "Welcome to Operating Systems!" | lolcat
echo ""
echo "In the next 100 minutes, you will discover the magic of the terminal..."
echo ""

# Teaser - show a complex command
echo "By the end, you will understand commands like this:"
echo ""
echo -e "\e[33m  find /var/log -name '*.log' -mtime -7 | xargs wc -l | sort -n | tail -5\e[0m"
echo ""
read -p "Press Enter to begin the adventure... "
```

### Minimal Version (without installations):

```bash
clear
echo "
╔═══════════════════════════════════════════════════════════════╗
║                                                               ║
║    ██████╗  █████╗ ███████╗██╗  ██╗                          ║
║    ██╔══██╗██╔══██╗██╔════╝██║  ██║                          ║
║    ██████╔╝███████║███████╗███████║                          ║
║    ██╔══██╗██╔══██║╚════██║██╔══██║                          ║
║    ██████╔╝██║  ██║███████║██║  ██║                          ║
║    ╚═════╝ ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝                          ║
║                                                               ║
║           Operating Systems - Seminar 1                       ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝
"
sleep 2
```

---

## DEMO 2: Visualising the File Hierarchy
**Moment**: After theoretical explanation of FHS  
**Purpose**: Transform the abstract into concrete

### Spectacular tree demo:

```bash
# Prepare demo structure
mkdir -p ~/demo_fhs/{bin,etc,home/{alice,bob},var/{log,cache},tmp}
touch ~/demo_fhs/etc/{passwd,hosts,bashrc}
touch ~/demo_fhs/home/alice/{.bashrc,document.txt}
touch ~/demo_fhs/var/log/{syslog,auth.log}

# Coloured visualisation
echo "🌳 FILE SYSTEM STRUCTURE"
echo "═══════════════════════════════════"
tree -C ~/demo_fhs | lolcat

# Cleanup
rm -rf ~/demo_fhs
```

### Interactive ncdu demo:

```bash
# Visual disk space exploration
echo "📊 INTERACTIVE DISK SPACE EXPLORATION"
echo "═══════════════════════════════════════════"
echo "Use arrows for navigation, 'q' to exit"
sleep 2
ncdu /var --exclude-kernfs 2>/dev/null
```

---

## DEMO 3: The Power of Pipes (Progress Bar)
**Moment**: When introducing the pipe concept  
**Purpose**: Visualise data flow

### Demo with pv:

```bash
# Demo 1: Data generation with progress bar
echo "📊 VISUALISING DATA FLOW THROUGH PIPE"
echo "═══════════════════════════════════════════"
echo ""
echo "Watch as 10MB of data flows through the system..."
sleep 1
pv -petra /dev/urandom | head -c 10M > /dev/null

# Demo 2: Copy with visualisation
echo ""
echo "Now let's see a file copy..."
dd if=/dev/zero bs=1M count=50 2>/dev/null | pv -s 50M > /tmp/test_file
rm /tmp/test_file
```

### Spectacular countdown:

```bash
# Countdown for transitions between sections
echo "⏱️ VISUAL COUNTDOWN"
for i in {5..1}; do
    clear
    figlet -c "$i" | lolcat
    sleep 1
done
clear
figlet -c "GO!" | lolcat -a -d 3
sleep 1
clear
```

---

## DEMO 4: Variables in Action
**Moment**: When introducing variables  
**Purpose**: Make the abstract tangible

### Interactive demo with dialog:

```bash
#!/bin/bash
# var_demo_interactive.sh

# Collect data from user
NAME=$(dialog --stdout --inputbox "What is your name?" 8 40)
AGE=$(dialog --stdout --inputbox "How old are you?" 8 40)
LANG=$(dialog --stdout --menu "Preferred language:" 12 40 4 \
    1 "Python" \
    2 "JavaScript" \
    3 "C/C++" \
    4 "Bash")

clear

# Display with style
echo "╔════════════════════════════════════════╗"
echo "║        YOUR VARIABLES                  ║"
echo "╠════════════════════════════════════════╣"
echo "║  NAME = $NAME"
echo "║  AGE  = $AGE"
echo "║  LANG = $LANG"
echo "╚════════════════════════════════════════╝"

# Demonstrate usage
echo ""
echo "Now we use them:"
echo "  Hello, $NAME! You are $AGE years old and you like the $LANG language."
```

### Export vs local demo:

```bash
echo "🔬 EXPERIMENT: LOCAL vs EXPORTED VARIABLES"
echo "═══════════════════════════════════════════════"
echo ""

# Visual setup
echo "Setting two variables:"
echo -e "  \e[33mLOCAL=\"I am local\"\e[0m"
echo -e "  \e[32mexport EXPORTED=\"I am exported\"\e[0m"
LOCAL="I am local"
export EXPORTED="I am exported"

echo ""
echo "In the CURRENT shell:"
echo -e "  LOCAL = \e[33m$LOCAL\e[0m"
echo -e "  EXPORTED = \e[32m$EXPORTED\e[0m"

echo ""
echo "In a SUBSHELL (bash -c):"
bash -c 'echo -e "  LOCAL = \e[31m$LOCAL\e[0m (empty!)"'
bash -c 'echo -e "  EXPORTED = \e[32m$EXPORTED\e[0m (works!)"'

echo ""
echo "💡 CONCLUSION: export makes the variable visible in subprocesses!"
```

---

## DEMO 5: Quoting Visualised
**Moment**: When explaining the difference between ' and "  
**Purpose**: Eliminate common confusion

```bash
echo "🔤 THE DIFFERENCE BETWEEN QUOTES"
echo "══════════════════════════════"
echo ""

NAME="Student"
echo "Variable: NAME=\"$NAME\""
echo ""

echo "┌─────────────────────────────────────────────────┐"
echo "│ COMMAND                    │ OUTPUT            │"
echo "├─────────────────────────────────────────────────┤"
echo -n "│ echo '\$NAME'              │ "
echo -e "\e[33m$(echo '$NAME')\e[0m              │"
echo -n "│ echo \"\$NAME\"              │ "
echo -e "\e[32m$(echo "$NAME")\e[0m            │"
echo -n "│ echo \$NAME                │ "
echo -e "\e[32m$(echo $NAME)\e[0m            │"
echo "└─────────────────────────────────────────────────┘"
echo ""
echo "💡 Single quotes = LITERAL, Double quotes = EXPANDS"
```

---

## DEMO 6: System Monitor (Advanced Preview)
**Moment**: End of seminar - "what you will be able to do"  
**Purpose**: Motivation for the following weeks

```bash
#!/bin/bash
# sys_monitor_preview.sh

echo "🖥️ PREVIEW: WHAT YOU WILL BE ABLE TO BUILD"
echo "════════════════════════════════════"
echo ""
echo "Press Ctrl+C to stop"
sleep 2

while true; do
    clear
    echo "╔═══════════════════════════════════════════════════════╗"
    echo "║           SYSTEM MONITOR - Live Demo                  ║"
    echo "╠═══════════════════════════════════════════════════════╣"
    
    # CPU
    CPU=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}')
    printf "║ 🔥 CPU:     %-43s ║\n" "$CPU%"
    
    # Memory
    MEM=$(free -h | awk '/^Mem/{print $3 "/" $2}')
    printf "║ 💾 Memory:  %-43s ║\n" "$MEM"
    
    # Disk
    DISK=$(df -h / | awk 'NR==2{print $3 "/" $2 " (" $5 " used)"}')
    printf "║ 💿 Disk:    %-43s ║\n" "$DISK"
    
    # Processes
    PROCS=$(ps aux | wc -l)
    printf "║ ⚙️  Processes: %-43s ║\n" "$PROCS"
    
    # Uptime
    UP=$(uptime -p)
    printf "║ ⏰ Uptime:  %-43s ║\n" "$UP"
    
    echo "╠═══════════════════════════════════════════════════════╣"
    echo "║           $(date '+%Y-%m-%d %H:%M:%S')                          ║"
    echo "╚═══════════════════════════════════════════════════════╝"
    
    sleep 2
done
```

---

## DEMO 7: Visual Heartbeat (One-liner)
**Moment**: When demonstrating while loops  
**Purpose**: Show the power of one-liners

```bash
# Spectacular one-liner
echo "💓 SYSTEM VISUAL HEARTBEAT"
echo "Press Ctrl+C to stop"
sleep 2

while true; do
    printf "\r💓 Load: %s | Mem: %s | Procs: %s | %s   " \
        "$(cut -d' ' -f1 /proc/loadavg)" \
        "$(free -h | awk '/^Mem/{print $3"/"$2}')" \
        "$(ps aux | wc -l)" \
        "$(date +%H:%M:%S)"
    sleep 1
done
```

---

## TIMING GUIDE FOR INSTRUCTOR

| Demo | Duration | Optimal Moment | Fallback |
|------|----------|----------------|----------|
| Opening Hook | 3 min | Absolute start | ASCII Banner |
| Tree FHS | 2 min | After FHS theory | `ls -R /` |
| Progress Bar | 2 min | After pipes | `cat file` |
| Var Interactive | 3 min | After variables | Simple echo |
| Quoting Viz | 2 min | After quotes | Table on whiteboard |
| Sys Monitor | 2 min | Final | htop |
| Heartbeat | 1 min | While demonstration | - |

---

## TROUBLESHOOTING

| Problem | Quick Solution |
|---------|----------------|
| lolcat not installed | `echo "text" \| sed 's/./\x1b[3$(($RANDOM%7))m&/g'` |
| dialog not working | Use `read -p` |
| cmatrix too long | `timeout 3 cmatrix` |
| Terminal too small | Ctrl+Minus for smaller font |
| Colours not showing | `export TERM=xterm-256color` |

---

## BONUS: Fortune + Cowsay for Breaks

```bash
# Run during the 10 minute break
while true; do
    clear
    COW=$(ls /usr/share/cowsay/cows/ | shuf -n1)
    fortune -s | cowsay -f "$COW" | lolcat
    sleep 15
done
```

---

## DEMO RECORDING (for materials)

Use `asciinema` to record demos:

```bash
# Installation
sudo apt install asciinema

# Recording
asciinema rec demo_hook.cast

# Run your demo...

# Stop with Ctrl+D or 'exit'

# Play
asciinema play demo_hook.cast

# Upload (optional)
asciinema upload demo_hook.cast
```

---

*Spectacular Demos | OS Seminar 1-2 | ASE-CSIE*
