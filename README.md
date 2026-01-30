# ROso — Operating Systems: Complete Educational Kit

```
┌─────────────────────────────────────────────────────────────────────────────────────────┐
│  🐧 LINUX    Ubuntu 24.04+    │  📋 BASH 5.0+   │  🐍 PYTHON 3.12+  │  📦 GIT 2.40+    │
├─────────────────────────────────────────────────────────────────────────────────────────┤
│  LICENCE         RESTRICTIVE    │  UNITS              14      │  EST. HOURS         60+   │
│  VERSION              5.3.1     │  SEMINARS            7      │  PROJECTS           23    │
│  STATUS              ACTIVE     │  PNG DIAGRAMS       27      │  SCRIPTS          180+    │
└─────────────────────────────────────────────────────────────────────────────────────────┘
```

**by ing. dr. Antonio Clim** | Bucharest University of Economic Studies — CSIE  
Year I, Semester 2 | 2017-2030

---

## What's New in v5.3

This release focuses on quality-of-life improvements for both students and instructors:

- **Print stylesheets** for HTML presentations — all slides can now be printed cleanly for offline study or handouts
- **Link checking** integrated into the CI pipeline — automated validation catches broken documentation links before they reach students
- **Expanded test suite** for shared utilities — the lib/ modules now have over 80% test coverage
- **lib/ documentation** with usage examples — proper documentation for the Python utilities that power autograders and randomisation

---

## Quick Navigation

| Looking for... | Go to... |
|----------------|----------|
| Setup guide | [Step 0: Choose Your Installation](#step-0-choose-your-installation-option) |
| Seminar materials | `SEM01/` through `SEM07/` |
| Projects | `04_PROJECTS/` |
| Lecture support | `05_LECTURES/` |
| Quick reference | `NAVIGATION.md` |
| Shared utilities | `lib/README.md` |
| Developer tools | [PART VII: Developer Tools](#part-vii-developer-tools) |
| Troubleshooting | [PART VI: Troubleshooting](#part-vi-troubleshooting) |

---

## What You Will Find Here

This kit contains the materials for the Operating Systems course: 14 course units, 7 seminars with practical exercises and 23 projects at three difficulty levels. Everything is structured so you can work independently or in the laboratory.

Bash seems simple at first glance — short commands, instant output — but when you try to automate something real, you suddenly discover that `$?` does not do what you think, that pipes lose variables and that a misplaced space in `[ $var ]` breaks your entire script. I have been through this with every generation of students, and the kit reflects exactly the problems I have seen in practice.

An observation after several years of teaching: students who take notes of their commands and output as they go reach working solutions much faster. Not because they are cleverer, but because they can return to what worked and compare it with what does not. It is a trivial practice but surprisingly effective.

---

## What You Will Be Able to Do After This Course

By the end, you will have a solid understanding of how an operating system works — not just which buttons to press, but why what happens happens. Specifically:

**Automation and scripting:** You will write Bash scripts that do in 30 seconds what you previously did manually in 30 minutes. Backups, log processing, deployment, reports — things that seem tedious become satisfying when you automate them once and then they work on their own.

**Debugging and diagnostics:** You will know how to use `strace`, `top`, `htop`, `lsof` (or, at least, you will be able to say you have heard of them) to understand why a programme is not doing what it should. Instead of searching blindly, you will be able to trace exactly what is happening at system level.

**System administration:** Permissions, processes, services, cron jobs — the basic vocabulary of any system administrator. Even if you will not work in sysadmin, you will understand what your devops colleagues mean when they talk about "giving chmod 755" or "sending SIGTERM".

**Foundation for specialisations:** The knowledge here is the starting point for several directions (and here I mention just a few):

| Direction | What you use from this course |
|----------|----------------------------|
| DevOps / SRE | Scripting, processes, services, containers |
| Information security | Permissions, processes, system audits |
| Backend development | IPC, threading, virtual memory |
| Embedded / IoT | Processes, scheduling, kernel |
| Cloud engineering | Virtualisation, containers, automation |
| Data engineering | Text processing (grep/sed/awk), pipelines |

You do not need to choose now — the idea is that the fundamentals you build here will help you wherever you end up.

---

## Why the Course Looks the Way It Does

A few principles I had in mind when structuring the materials:

**There is no "programmer gene."** The ability to write code is acquired through deliberate practice, not an innate talent you are born with or not. Patitsas and colleagues demonstrated in 2016 that only 5.8% of grade distributions in computer science courses are bimodal — the rest of the myth "some can, some cannot" is self-fulfilling prophecy.

**Beginners are not slowed-down experts.** They need different approaches, not just more time. That is why the materials include Parsons Problems (code reordering), Peer Instruction (questions with pair discussions) and structured Live Coding. These are techniques validated in recent computing education research!

**Errors are opportunities, not failures.** I have normalised the idea (opportunity) of making mistakes throughout the kit. Every programmer has gone through the same stupid bugs — the misplaced space somewhere in a `[ $var ]`, forgotten quotation marks, off-by-one in for/while loops. When you see that the instructor also makes mistakes whilst correcting/fixing code typed in real time, it somehow becomes easier to accept that you too will make mistakes. (And you no longer feel alone in the dark ... although, sometimes, even GPT seems like a torch!)

**LLMs are tools, not adversaries.** Today's students have access to ChatGPT, Claude, Gemini — there is no point in designing courses that ignore reality. I have included explicitly "LLM-aware" exercises where you must evaluate what the AI generates, not just copy. The aim is understanding, not task completion.

**Attention works in sprints (but short ones!).** Neuroscience research shows that sustained attention for students is realistic in windows of 5-10 minutes, not 50. That is why assignments are structured in micro-milestones with immediate checks. Breaks are not wasted time — incubation helps knowledge consolidation. (Honestly, in my youth I tried incubation without having learnt anything beforehand ... I failed some exams doing that, but at least I failed them well-rested.)

If it sounds strange that an Operating Systems course thinks about neuroscience and pedagogy: this is how any course should look. Traditional teaching — slides read monotonously for two hours, with students in a passive role — has never worked well; we have just collectively accepted that this is normal. It is not normal. It is industrial education: efficient for processing people, inefficient for teaching them anything.

The materials here are the result of years of experimentation, testing and iteration. The methods of Peer Instruction, Productive Failure, Subgoal Labelling (obviously) were not invented by me. They are validated in research at SIGCSE, ICER, ITiCSE (see refs). What I have done is apply them in the concrete context of our course and see what works with students at ASE.

---

# PART I: SETUP AND CONFIGURATION

This section covers everything you need to do before the first seminar. Without a working environment, the rest is useless.

---

## Step 0: Choose Your Installation Option

You have three main options. My recommendation is WSL2 if you are on Windows — it is the simplest and closest to the real Linux experience.

| Option | For whom | Advantages | Disadvantages |
|---------|-------------|----------|-------------|
| **WSL2** | Windows 10/11 | Fast, integrated into Windows, no reboot | Requires updated Windows |
| **VirtualBox** | Any OS | Complete isolation, snapshots | Slower, consumes more resources |
| **Dual boot** | Advanced users | Native performance | Risk during installation, must reboot |

**Quick decision:** If you have a recent Windows 10/11, go with WSL2. If you have an older Windows or want complete isolation, VirtualBox. Dual boot only if you know what you are doing.

---

## Step 1: Installing WSL2 (Recommended Option)

WSL2 has completely changed the way I teach — now students can practise Linux without dual boot or a separate virtual machine.

### 1.1 Check the Requirements

**Windows 10:** You need version 2004 or newer (Build 19041+)  
**Windows 11:** Any version works

Check your version:

```powershell
# POWERSHELL (Windows) - run as normal user
winver
```

A window opens with information. Look for the Build number.

### 1.2 Check Virtualisation

Open Task Manager (`Ctrl+Shift+Esc`), Performance tab, click on CPU. In the bottom right you should see:

```
Virtualization: Enabled
```

If it says "Disabled", you need to enable virtualisation from BIOS. The procedure differs depending on the motherboard manufacturer — search for "[laptop/PC brand] enable virtualization BIOS".

### 1.3 Enable WSL2

Open PowerShell **as Administrator** (right-click on Start → Terminal (Admin) or Windows PowerShell (Admin)):

```powershell
# POWERSHELL (Administrator)
# Enable Windows Subsystem for Linux
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart

# Enable Virtual Machine Platform
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
```

**RESTART your computer.** Seriously, without a restart it will not work.

### 1.4 Install Ubuntu

After restart, open PowerShell as Administrator again:

```powershell
# POWERSHELL (Administrator)
# Download and install the WSL2 kernel update
wsl --update

# Set WSL2 as the default version
wsl --set-default-version 2

# Install Ubuntu 24.04 LTS
wsl --install -d Ubuntu-24.04
```

The download takes 5-15 minutes depending on your internet connection. At the end, a new window with Ubuntu opens automatically.

### 1.5 Create Your Linux Account

Ubuntu asks you to create a user.

**Username:** Your surname, lowercase, without diacritics  
Examples: `popescu`, `ionescu`, `stefanescu`

**Password:** `stud` (for consistency in the lab)

When you type the password, **you see nothing on the screen** — no stars, no dots. This is normal for Linux. Type and press Enter.

### 1.6 Update the System

The first command you run on any freshly installed Linux system:

```bash
# BASH (Ubuntu) - black background
sudo apt update && sudo apt upgrade -y
```

`sudo` = "superuser do" — runs the command with administrator privileges  
`apt` = the package manager from Debian/Ubuntu  
`-y` = automatically answers "yes" to questions

It takes a few minutes. Grab a coffee.

### 1.7 Install the Required Packages

```bash
# BASH (Ubuntu)
# Packages for seminars
sudo apt install -y git vim nano tree htop ncdu shellcheck python3 python3-pip python3-venv build-essential openssh-server curl wget figlet lolcat cowsay fortune pv dialog jq bc

# Verify the installation
echo "Verifying installation..."
for cmd in git vim nano tree htop python3 shellcheck ssh curl wget; do
    command -v "$cmd" >/dev/null && echo "  [OK] $cmd" || echo "  [MISSING] $cmd"
done
```

### 1.8 Configure SSH (for PuTTY and WinSCP)

SSH allows you to connect to Ubuntu from Windows using PuTTY or to transfer files with WinSCP.

```bash
# BASH (Ubuntu)
# Start the SSH service
sudo service ssh start

# Verify it is running
sudo service ssh status

# Find the IP address
hostname -I
```

Note the IP address (probably `172.x.x.x`) — you will use it in PuTTY.

### 1.9 Set the Hostname

For identification in the lab, set a descriptive hostname:

```bash
# BASH (Ubuntu)
# Replace AP_1001_A with your group and position
# Format: [Specialisation]_[Group]_[PC Letter]
# Example: AP_1029_B for Applied Informatics, group 1029, PC B

sudo hostnamectl set-hostname AP_1029_A
```

Close and reopen the terminal to see the change.

---

## Step 2: Recommended Folder Structure

A good folder structure saves you from chaos during the semester. I have seen students with all files in a single folder — they would find `script.sh`, `script2.sh`, `script_final.sh`, `script_final_v2.sh` and no longer knew which was which.

### 2.1 Create the Basic Structure

```bash
# BASH (Ubuntu)
# Create the main structure
mkdir -p ~/so-lab/{cursuri,seminarii,teme,proiecte,experimente,backup}

# Create subdirectories for each seminar
for i in $(seq -w 1 6); do
    mkdir -p ~/so-lab/seminarii/SEM0$i/{exercitii,demo,notite}
done

# Create subdirectories for assignments
for i in $(seq -w 1 7); do
    mkdir -p ~/so-lab/teme/TEMA0$i
done

# Create subdirectories for courses
for i in $(seq -w 1 14); do
    mkdir -p ~/so-lab/cursuri/CURS$i/{notite,scripturi}
done

# Visualise the structure
tree -L 3 ~/so-lab/
```

You should see:

```
/home/yourname/so-lab/
├── backup/
├── cursuri/
│   ├── CURS01/
│   │   ├── notite/
│   │   └── scripturi/
│   ├── CURS02/
│   │   ├── notite/
│   │   └── scripturi/
│   └── ... (up to CURS14)
├── experimente/
├── proiecte/
├── seminarii/
│   ├── SEM01/
│   │   ├── demo/
│   │   ├── exercitii/
│   │   └── notite/
│   ├── SEM02/
│   │   └── ...
│   └── ... (up to SEM06)
└── teme/
    ├── TEMA01/
    ├── TEMA02/
    └── ... (up to TEMA07)
```

### 2.2 Why This Structure

| Folder | What you put there | Why separate |
|--------|--------------|---------------|
| `cursuri/` | Notes and scripts from courses | Theory, separated from practice |
| `seminarii/` | Exercises from the lab | Each seminar is independent |
| `teme/` | Homework assignments | You submit them, do not mix them |
| `proiecte/` | Semester project | Larger code, different structure |
| `experimente/` | Tests, experiments | Place to "break things" |
| `backup/` | Safety copies | Before major modifications |

### 2.3 Create the Directory for Homework Recordings

Assignments are recorded with a special script (more details in the assignments section):

```bash
# BASH (Ubuntu)
mkdir -p ~/HOMEWORKS
```

---

## Step 3: Git Configuration

Git is necessary to clone the kit and for versioning your own scripts. If you have not used Git before, now is the time to learn — it is a skill you will use in any programming job.

### 3.1 Initial Configuration

```bash
# BASH (Ubuntu)
# Set your identity (replace with your details)
git config --global user.name "Popescu Ion"
git config --global user.email "ion.popescu@student.ase.ro"

# Useful settings
git config --global init.defaultBranch main
git config --global core.editor "nano"
git config --global pull.rebase false

# Verify the configuration
git config --list
```

### 3.2 Clone the ROso Kit

```bash
# BASH (Ubuntu)
cd ~/so-lab

# Clone the repository
git clone https://github.com/antonioclim/ROso.git

# Verify the contents
ls -la ROso/
```

If the repository is private or you received the materials another way, copy them manually to `~/so-lab/ROso/`.

### 3.3 Create Repositories for Assignments

Each assignment should have its own repository (or at least its own branch). This helps you:
- Revert to previous versions if you break something
- See what you modified and when
- Demonstrate that you worked progressively (not everything on the last night)

```bash
# BASH (Ubuntu)
# For each assignment, initialise a Git repo
cd ~/so-lab/teme/TEMA01
git init
echo "# Tema 01 - SO" > README.md
git add README.md
git commit -m "Initial commit"

# Create .gitignore
cat > .gitignore << 'EOF'
# Temporary files
*.tmp
*.bak
*~
*.swp

# Outputs
*.log
*.out

# Python cache
__pycache__/
*.pyc

# System files
.DS_Store
Thumbs.db
EOF

git add .gitignore
git commit -m "Add .gitignore"
```

### 3.4 Recommended Git Workflow for Assignments

```bash
# BASH (Ubuntu)
# 1. Before starting work
cd ~/so-lab/teme/TEMA01
git status

# 2. After each important milestone
git add script.sh
git commit -m "Implement backup function"

# 3. At the end
git add .
git commit -m "Assignment complete - all requirements implemented"

# 4. View the history
git log --oneline
```

**Good commit messages:**
- `"Add input validation function"`
- `"Fix bug in processing files with spaces"`
- `"Optimise main loop"`

**Bad commit messages:**
- `"update"`
- `"asdfasdf"`
- `"final final FINAL"`

---

## Step 4: Verify the Installation

Run this verification script to ensure everything is in order:

```bash
# BASH (Ubuntu)
cat << 'EOF' > ~/verify_setup.sh
#!/usr/bin/env bash
# Verification script for the SO kit

echo ""
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║          WORKING ENVIRONMENT VERIFICATION - SO ASE             ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# System information
echo "▶ SYSTEM"
echo "  Hostname: $(hostname)"
echo "  User: $(whoami)"
echo "  Ubuntu: $(lsb_release -ds 2>/dev/null || echo 'N/A')"
echo "  Kernel: $(uname -r)"
echo "  Bash: $(bash --version | head -1 | cut -d' ' -f4)"
echo ""

# Network
echo "▶ NETWORK"
echo "  IP: $(hostname -I 2>/dev/null | awk '{print $1}' || echo 'N/A')"
if ping -c 1 -W 2 google.com >/dev/null 2>&1; then
    echo "  Internet: OK"
else
    echo "  Internet: NO CONNECTION"
fi
echo ""

# Required commands
echo "▶ REQUIRED COMMANDS"
CMDS="bash git nano vim python3 gcc shellcheck ssh tree htop awk sed grep find tar curl wget"
for cmd in $CMDS; do
    if command -v "$cmd" >/dev/null 2>&1; then
        printf "  [OK]      %s\n" "$cmd"
    else
        printf "  [MISSING] %s\n" "$cmd"
    fi
done
echo ""

# Optional commands
echo "▶ OPTIONAL COMMANDS (for demos)"
OPT_CMDS="figlet lolcat cowsay fortune pv dialog jq"
for cmd in $OPT_CMDS; do
    if command -v "$cmd" >/dev/null 2>&1; then
        printf "  [OK]      %s\n" "$cmd"
    else
        printf "  [--]      %s (optional)\n" "$cmd"
    fi
done
echo ""

# Folder structure
echo "▶ FOLDER STRUCTURE"
DIRS="so-lab so-lab/cursuri so-lab/seminarii so-lab/teme so-lab/proiecte HOMEWORKS"
for dir in $DIRS; do
    if [ -d ~/"$dir" ]; then
        printf "  [OK]      ~/%s\n" "$dir"
    else
        printf "  [MISSING] ~/%s\n" "$dir"
    fi
done
echo ""

# Git
echo "▶ GIT"
if git config user.name >/dev/null 2>&1; then
    echo "  User: $(git config user.name)"
    echo "  Email: $(git config user.email)"
else
    echo "  [!] Git is not configured (run git config)"
fi
echo ""

# SSH
echo "▶ SSH"
if systemctl is-active --quiet ssh 2>/dev/null || service ssh status 2>/dev/null | grep -q running; then
    echo "  SSH Server: ACTIVE"
else
    echo "  SSH Server: INACTIVE (run: sudo service ssh start)"
fi
echo ""

echo "════════════════════════════════════════════════════════════════"
echo "Verification complete!"
echo "════════════════════════════════════════════════════════════════"
EOF

chmod +x ~/verify_setup.sh
~/verify_setup.sh
```

---

## Step 5: VirtualBox Installation (Alternative)

If WSL2 does not work or you prefer complete isolation, use VirtualBox.

### 5.1 Download and Install VirtualBox

1. Download from https://www.virtualbox.org/wiki/Downloads
2. Choose "Windows hosts" (or the variant for your OS)
3. Run the installer with default settings

### 5.2 Download Ubuntu 24.04 LTS

1. Download the ISO from https://ubuntu.com/download/desktop
2. Choose "Ubuntu 24.04 LTS"
3. Save the `.iso` file (about 5 GB)

### 5.3 Create the Virtual Machine

1. Open VirtualBox → New
2. Name: `Ubuntu-SO`
3. Type: Linux, Version: Ubuntu (64-bit)
4. Memory: minimum 4096 MB (4 GB), recommended 8192 MB
5. Hard disk: Create a virtual hard disk now
   - VDI, Dynamically allocated
   - Minimum 25 GB, recommended 50 GB

### 5.4 Configure the Machine

Before starting, adjust the settings (Settings):

**System → Processor:**
- Processors: 2-4 (depending on how many cores you have)

**Display → Screen:**
- Video Memory: 128 MB
- Enable 3D Acceleration: ticked (if it works)

**Storage:**
- Controller: IDE → Empty → click on the disc icon → Choose a disk file
- Select the downloaded Ubuntu ISO

### 5.5 Install Ubuntu

1. Start → follow the installation wizard
2. Install Ubuntu → Normal installation
3. Username and password: same as for WSL2

After installation, install Guest Additions for resolution and shared clipboard:

```bash
# BASH (Ubuntu in VirtualBox)
sudo apt update
sudo apt install -y virtualbox-guest-utils virtualbox-guest-x11
sudo reboot
```

### 5.6 Snapshot Before the Lab

VirtualBox has an excellent feature: snapshots. Before each lab, take a snapshot:

1. Machine → Take Snapshot
2. Name: "Before SEM03" (or whichever seminar follows)

If you break something, you can instantly revert to the previous state.

---

# PART II: KIT STRUCTURE

---

## Overview

```
ROso/
├── 001CONDITIIinit/          # ← STEP 1: Installation and configuration
├── 002HWinit/          # ← STEP 2: Guides for students  
├── 003GHID/          # ← STEP 3: Technical guides
│
├── SO_curs/                  # Course materials (theory)
│   └── SO_curs01..14/        #   14 thematic units
│
├── SEM01..06/                # Seminar materials (practice)
│   └── [detailed structure below]
│
├── SEM-PROJ/                 # Semester projects
│   ├── EASY/                 #   5 projects, 15-20 hours
│   ├── MEDIUM/               #   15 projects, 25-35 hours
│   └── ADVANCED/             #   3 projects, 40-50 hours
│
└── 000SUPPL/                 # Supplementary materials
    ├── diagrame_png/         #   Pre-rendered diagrams
    └── Exercitii_Examene_*.md
```

---

## Folder 001CONDITIIinit — Installation

Here you find the detailed installation guides:

| File | Contents |
|--------|----------|
| `GHID_WSL2_Ubuntu2404_INCEPATORI_SO_ASE.md` | Step-by-step guide for WSL2 |
| `GHID_WSL2_Ubuntu2404_INTERACTIV.html` | Interactive version (open in browser) |
| `GHID_VirtualBox_Ubuntu2404_INCEPATORI_SO_ASE.md` | Guide for VirtualBox |
| `GHID_VirtualBox_Ubuntu2404_INTERACTIV.html` | Interactive version |
| `TC0.A_RO-TC laborator 0C_*.pdf` | Lab 0 worksheet (prerequisites) |

If you followed the steps in the previous section, you have already covered most of the content of these guides.

---

## Folder 002HWinit — Guides for Students

Contains instructions for submitting and recording assignments:

| File | Contents |
|--------|----------|
| `GHID_STUDENT_RO.md` | How to use the recording script |
| `record_homework_tui_RO.py` | Python script with text interface for assignments |
| `record_homework_RO.sh` | Bash version (alternative) |

### How Homework Recording Works

Assignments are not submitted as files — terminal sessions are recorded. This means the instructor sees exactly what commands you gave and in what order.

```bash
# BASH (Ubuntu)
# Download the script
cd ~/HOMEWORKS
wget -O record_homework_tui_RO.py "https://drive.google.com/uc?export=download&id=1YLqNamLCdz6OzF6hlcPr1hr738DIaSYz"
chmod +x record_homework_tui_RO.py

# Run
python3 record_homework_tui_RO.py
```

On the first run, the script installs the necessary dependencies (`rich`, `questionary`, `asciinema`). Then it asks you for:
- Name, surname, group
- Assignment number (e.g.: `03a`)

Recording starts. You do the assignment. When you finish, type `STOP_tema` or `Ctrl+D`. The script generates a cryptographically signed `.cast` file and uploads it to the server.

Why recording, not files?
- You cannot copy from colleagues (the signature is unique)
- The thinking process is visible, not just the result
- Mistakes and corrections are visible (and that is ok!)

---

## Folder 003GHID — Technical Guides

Contains guides for scripting and debugging:

| File | Contents |
|--------|----------|
| `00_Cum_se_utilizeaza_kitul.md` | General kit overview |
| `01_Ghid_Scripting_Bash.md` | Best practices for Bash scripts |
| `02_Ghid_Scripting_Python_pentru_SO.md` | Python in OS context |
| `03_Ghid_Observabilitate_si_Debugging.md` | How to understand what the system does |
| `04_Idei_de_proiecte.md` | Inspiration for projects |
| `05_Ghid_PlantUML.md` | How to generate diagrams |

### Extract from the Bash Scripting Guide

The most important rules:

**1. Shebang and strict mode**
```bash
#!/usr/bin/env bash
set -euo pipefail
```

**2. Quotes everywhere**
```bash
# WRONG
for f in *.txt; do
    echo $f        # Bug if the name has spaces
done

# CORRECT
for f in ./*.txt; do
    [[ -e "$f" ]] || continue
    echo "$f"
done
```

**3. Small, testable functions**
```bash
ensure_cmd() {
    command -v "$1" >/dev/null 2>&1 || {
        echo "Error: missing command $1" >&2
        exit 1
    }
}

ensure_cmd git
ensure_cmd python3
```

**4. Automatic cleanup**
```bash
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
```

---

## Structure of a Seminar (SEM01-06)

All seminars have the same organisation:

```
SEM0X/
├── README.md                    # General overview
│
├── docs/                        # Documentation
│   ├── S0X_00_ANALIZA_*.md      #   Pedagogical plan
│   ├── S0X_01_GHID_INSTRUCTOR   #   For the instructor
│   ├── S0X_02_MATERIAL_PRINCIPAL #   Central material
│   ├── S0X_03_PEER_INSTRUCTION  #   MCQ questions
│   ├── S0X_04_PARSONS_PROBLEMS  #   Code reordering
│   ├── S0X_05_LIVE_CODING_*     #   Live coding script
│   ├── S0X_06_EXERCITII_SPRINT  #   Short exercises
│   ├── S0X_07_LLM_AWARE_*       #   Exercises with AI
│   ├── S0X_08_DEMO_*            #   Spectacular demos
│   ├── S0X_09_CHEAT_SHEET_*     #   1-page summary
│   └── S0X_10_AUTOEVALUARE_*    #   Reflection
│
├── scripts/
│   ├── bash/                    #   Setup, quiz, validation
│   ├── demo/                    #   Demonstration scripts
│   └── python/                  #   Autograder, generators
│
├── prezentari/                  #   HTML slides
├── resurse/                     #   Test files
├── teme/                        #   Requirements and rubrics
└── teste/                       #   Automated tests
```

### How to Go Through a Seminar

```bash
# BASH (Ubuntu)
cd ~/so-lab/ROso/SEM02

# 1. Read the general overview
less README.md

# 2. Go through the main material
less docs/S02_02_MATERIAL_PRINCIPAL.md

# 3. Run the demos
chmod +x scripts/demo/*.sh
./scripts/demo/S02_01_hook_demo.sh

# 4. Test your knowledge
./scripts/bash/S02_02_quiz_interactiv.sh

# 5. Do the exercises
less docs/S02_06_EXERCITII_SPRINT.md

# 6. Read the assignment requirements
less teme/S02_01_TEMA.md
```

---

# PART III: DETAILED CONTENT

---

## Courses (SO_curs01-14)

I structured the courses following the classical order from Silberschatz and Tanenbaum, with adjustments based on what works practically.

| Course | Topic | Key Concepts | Hook |
|------|------|----------------|------|
| 01 | Introduction to OS | OS role, kernel architectures, evolution | Why is the computer not just hardware? |
| 02 | System Calls | The syscall mechanism, strace, API vs ABI | What happens when you type `ls`? |
| 03 | Processes | States, fork(), exec(), Copy-on-Write | How does Unix make copies without copying? |
| 04 | Scheduling | FCFS, SJF, RR, MLFQ, CFS | Why do some programmes "skip the queue"? |
| 05 | Threads | Models, pthread, race conditions | Why is doing 2 things simultaneously hard? |
| 06 | Synchronisation | Mutex, semaphores, monitors | How do you prevent chaos when everyone wants the same resource? |
| 07 | IPC | Pipes, sockets, shared memory | How do processes talk to each other? |
| 08 | Deadlock | Coffman conditions, Banker's algorithm | Why does everything sometimes lock up? |
| 09 | Virtual Memory | Address space, paging | How can a process use "more" memory than you have? |
| 10 | Paging | TLB, replacement algorithms | Why does the cache matter so much? |
| 11 | File Systems I | Inode, hard/soft links | What are those numbers from `ls -i`? |
| 12 | File Systems II | Journaling, ext4, RAID | Why do you not lose data when the power goes off? |
| 13 | Security | Permissions, ACL, capabilities | Why can you not delete any file? |
| 14 | Virtualisation | VM vs containers, namespaces | How does Docker run in a shared kernel? |

---

## Seminars (SEM01-06)

### Seminar 1: Shell Basics

We start from zero: navigation, variables, globbing. It seems trivial, but the difference between `$var` and `"$var"` produces bugs even in scripts written by experienced people.

**What you will learn:**
- Navigation (`cd`, `ls`, `pwd`, `tree`)
- Local and environment variables
- Quoting and escape sequences
- File globbing (`*`, `?`, `[abc]`, `{a,b,c}`)
- Configuring `.bashrc`

**Thought challenge:** Why are there so many ways of quoting in Bash (`'...'`, `"..."`, `$'...'`, `$"..."`)?

The short answer: historical compatibility. Thompson's shell from 1971 did not have variables. Bourne Shell from 1979 added variables, and single and double quotes acquired different meanings. Then came the ANSI-C extensions (`$'...'`) in Bash for escape sequences like `\n`. Each addition had to be compatible with existing scripts. The result is chaotic, but it works.

---

### Seminar 2: Pipeline Master

Ken Thompson implemented pipes in a single night in 1973, at Doug McIlroy's insistence. McIlroy wanted programmes to be able to connect "like a garden hose". The idea defined Unix.

**What you will learn:**
- Control operators (`;`, `&&`, `||`, `&`)
- I/O redirection (`>`, `>>`, `<`, `2>`, `&>`)
- Pipes and tee
- Filters (`sort`, `uniq`, `cut`, `paste`, `tr`, `wc`)
- Loops (`for`, `while`, `until`)

**Thought challenge:** Why is `cat file | grep pattern` considered an "anti-pattern" (Useless Use of Cat)?

The command `grep pattern file` does the same thing without the extra process. But it is not always bad — sometimes `cat` makes the code clearer, especially in long pipelines. The practical rule: if speed matters, avoid it; if readability matters, perhaps keep it.

---

### SEM05-06: Find & Permissions

`find` is probably the command with the most options in Unix. The first version had a completely different syntax from what we use today — they changed it because it was too complicated. And it still remained complicated.

**What you will learn:**
- `find` with multiple criteria and actions
- `xargs` for parallel processing
- Permissions: `chmod`, `chown`, `umask`
- Special permissions: SUID, SGID, Sticky bit
- `cron` for automation

**Thought challenge:** Why does Sticky bit exist on `/tmp`?

Without Sticky bit, anyone can delete other people's files from a directory with write permissions for all. Sticky bit (the `t` notation in `drwxrwxrwt`) allows only the file owner to delete it. It was invented for shared directories like `/tmp`. The irony: originally "Sticky" meant the programme stayed in memory after execution (for performance). The meaning changed completely.

---

### SEM07-08: Text Processing

Regular expressions were invented by Stephen Kleene in 1951 to describe formal languages. Ken Thompson brought them to computing in 1968 when he implemented a text editor (the precursor of `ed`). `grep` literally means "**g**lobal **r**egular **e**xpression **p**rint" — a command from `ed`.

**What you will learn:**
- Regular expressions: BRE and ERE
- `grep` for searching
- `sed` for transformations
- `awk` for column processing

**Thought challenge:** Why is `awk` called that?

Aho, Weinberger, Kernighan — the creators' initials. Yes, the same Kernighan from "The C Programming Language". Awk was created in 1977 at Bell Labs, contemporary with the first C manual.

---

### SEM09-10: Advanced Scripting

After you know the basic commands, it is time to combine them into scripts that behave decently even when things go wrong.

**What you will learn:**
- Functions and libraries
- Indexed and associative arrays
- Signal handling with `trap`
- Debugging and profiling
- Best practices

**Thought challenge:** Why are Bash arrays indexed from 0, but `$@` is indexed from 1?

Positional parameters (`$1`, `$2`, etc.) existed before arrays. When they added arrays in Bash 2.0 (1996), they chose indexing from 0 for compatibility with C. But they could not change `$1` to `$0` (which already meant the script name). The result: inconsistency you have to memorise.

---

### SEM11-12: CAPSTONE Projects

Integration. Projects that combine everything: Monitor, Backup, Deployer.

**What you will build:**
- System Monitor with terminal dashboard
- Incremental backup system
- Automatic deployment tool

---

# PART IV: SEMESTER PROJECTS

---

## Choosing the Project

You have 23 projects at three levels. My advice: do not choose the easiest just to finish — choose something that interests you or that would help you in the future.

### Level EASY (5 projects, 15-20 hours)

Bash only, no external dependencies. Good for consolidation.

| Code | Project | Description |
|-----|---------|-----------|
| E01 | File System Auditor | Scans and reports directory structure |
| E02 | Log Analyser | Parses and summarises log files |
| E03 | Bulk File Organiser | Sorts files by extension/date/size |
| E04 | System Health Reporter | Generates reports about system status |
| E05 | Config File Manager | Backup and versioning for configurations |

### Level MEDIUM (15 projects, 25-35 hours)

Bash with optional Kubernetes integration for bonus.

| Code | Project | Description |
|-----|---------|-----------|
| M01 | Incremental Backup | Backups that save only what has changed |
| M02 | Process Monitor | Monitors process lifecycle |
| M03 | Service Watchdog | Automatically restarts failed services |
| M04 | Network Scanner | Detects open ports and services |
| M05 | Deployment Pipeline | Automates application deployment |
| M06 | Resource Historian | Resource usage history |
| M07 | Security Audit | Framework for security audits |
| M08 | Disk Manager | Disk space management |
| M09 | Task Scheduler | Manager for scheduled tasks |
| M10 | Process Tree Analyser | Analyses process hierarchy |
| M11 | Memory Forensics | Tool for memory analysis |
| M12 | File Integrity Monitor | Detects unauthorised modifications |
| M13 | Log Aggregator | Centralises logs from multiple sources |
| M14 | Config Manager | Configuration management for multiple environments |
| M15 | Parallel Executor | Parallel task execution |

### Level ADVANCED (3 projects, 40-50 hours)

Bash + components in C.

| Code | Project | Description |
|-----|---------|-----------|
| A01 | Mini Job Scheduler | Simplified scheduler in cron style |
| A02 | Shell Extension | Extensions for bash |
| A03 | Distributed File Sync | File synchronisation between machines |

---

## Recommended Structure for Projects

```bash
# BASH (Ubuntu)
mkdir -p ~/so-lab/proiecte/M05_Deployment_Pipeline/{src,tests,docs,config}
cd ~/so-lab/proiecte/M05_Deployment_Pipeline

# Initialise git
git init

# Create the structure
cat > README.md << 'EOF'
# M05 - Deployment Pipeline

## Description
[What the project does]

## Requirements
- Bash 5.0+
- Git
- [other dependencies]

## Installation
```bash
chmod +x src/deploy.sh
```

## Usage
```bash
./src/deploy.sh --help
```

## Structure
```
├── src/           # Source code
├── tests/         # Tests
├── docs/          # Documentation
├── config/        # Configuration files
└── README.md
```

## Author
[Your name] - [group]
EOF

# Create .gitignore
cat > .gitignore << 'EOF'
*.log
*.tmp
*.bak
__pycache__/
.env
EOF

git add .
git commit -m "Initial project structure"
```

---

# PART V: CHALLENGES AND OPEN QUESTIONS

---

## Things I Still Have Not Completely Resolved

Teaching operating systems has a few problems for which there are no perfectly satisfactory solutions. I mention them because honesty is more valuable than the illusion that everything is resolved.

### The Problem of Abstraction vs. Detail

Students need to understand how an operating system works, but:
- If we go into too many details, they get lost in complexity
- If we stay at a high level, they do not truly understand what is happening

I have not found the perfect balance. I try to alternate: one session of "big picture", one session of "deep dive" on a specific concept.

### The LLM Problem

Students can generate Bash code with ChatGPT. How do you evaluate whether they understood or just copied?

The current solution: LLM-aware exercises where you must evaluate the generated code, identify bugs, explain what it does. It works partially — some still copy the explanations. It is an arms race we will not completely win. At least, however, we can ask better questions.

### The Problem of Different Working Environments

Some students have new laptops, others have computers from 2015. Some have Windows, others macOS, a few Linux. WSL2 has helped enormously, but strange cases still appear.

The partial solution: detailed guides, verification scripts, VirtualBox as plan B. It is not perfect.

---

## Questions We Do Not Have Complete Answers To

These are legitimate questions from computing education research that researchers are still debating:

**1. How much code must a student write to understand a concept?**

There is no magic number. Some understand from 10 lines, others need 100. Research suggests that "productive struggle" matters more than quantity, but it is hard to quantify.

**2. Does immediate feedback help or harm in the long term?**

Bjork's paradox: delayed feedback can lead to better long-term learning, although it feels harder at the moment. But how delayed? Research does not give a clear answer.

**3. How do you teach debugging?**

It is a different skill from writing code, but it is rarely taught explicitly. I have tried to include deliberate errors in live coding, but I do not know if it is enough.

---

## Critical Thinking Exercises

For each seminar, a few questions to think about:

**Seminar 1:**
- Why did Unix choose to treat everything as a file (including devices)?
- What would have happened if environment variables did not exist?

**Seminar 2:**
- Why was the Unix philosophy "do one thing well" so influential?
- What disadvantages does this approach have?

**SEM05-06:**
- Unix permissions are 50+ years old. What would replace them if we designed from scratch today?
- Why is SUID considered a security risk, but still exists?

**SEM07-08:**
- Why do regular expressions have such cryptic syntax?
- Would it have been better if `grep`, `sed`, `awk` had been a single tool?

**SEM09-10:**
- Why does Bash not have static typing? Would it be better if it did?
- Should shell scripting be replaced with Python for automation?

---

# PART VI: DETAILED TROUBLESHOOTING

---

## Problems with WSL2 Installation

### "WSL 2 requires an update to its kernel component"

```powershell
# POWERSHELL (Administrator)
wsl --update
# Restart after update
```

### "Error: 0x80370102" or "Please enable the Virtual Machine Platform"

Virtualisation is not enabled in BIOS. The procedure:

1. Restart your computer
2. When it starts, quickly press the BIOS key:
   - **Dell:** F2 or F12
   - **HP:** F10 or Esc
   - **Lenovo:** F1 or F2
   - **ASUS:** F2 or Del
   - **Acer:** F2 or Del
3. Look for "Virtualization Technology", "VT-x", "AMD-V" or "SVM"
4. Change from Disabled to Enabled
5. Save (usually F10) and exit

### "Error: 0x80370114" — cannot start the virtual machine

Hyper-V or another virtualisation technology may be in conflict. Check:

```powershell
# POWERSHELL (Administrator)
# Disable Hyper-V if it is enabled and you are not using it
dism.exe /Online /Disable-Feature:Microsoft-Hyper-V

# OR enable it completely for WSL2
dism.exe /Online /Enable-Feature /All /FeatureName:Microsoft-Hyper-V
```

### WSL opens but does not respond

```powershell
# POWERSHELL
# Completely stop WSL
wsl --shutdown

# Check the status
wsl --status

# Restart
wsl
```

---

## Problems in the Terminal

### "Permission denied" when running scripts

```bash
# BASH (Ubuntu)
# Cause 1: The script does not have execution permission
chmod +x script.sh
./script.sh

# Cause 2: The file is on a Windows partition mounted without exec
# Solution: move the file to Linux home
cp /mnt/c/Users/.../script.sh ~/
chmod +x ~/script.sh
~/script.sh

# Cause 3: Wrong or missing shebang
# Check the first line:
head -1 script.sh
# It should be: #!/usr/bin/env bash or #!/bin/bash
```

### Romanian characters displayed incorrectly

```bash
# BASH (Ubuntu)
# Check the current locale
locale

# Set the correct locale
export LANG=ro_RO.UTF-8
export LC_ALL=ro_RO.UTF-8

# If the locale is not installed
sudo locale-gen ro_RO.UTF-8
sudo update-locale LANG=ro_RO.UTF-8

# Permanent - add to ~/.bashrc
echo 'export LANG=ro_RO.UTF-8' >> ~/.bashrc
echo 'export LC_ALL=ro_RO.UTF-8' >> ~/.bashrc
source ~/.bashrc
```

### Variables from `while | read` do not persist

This is a classic trap. When you use a pipe, the right side runs in a subshell, and changes do not propagate back.

```bash
# WRONG - subshell problem
count=0
cat file.txt | while read line; do
    ((count++))
done
echo $count    # Displays 0!

# CORRECT - use redirect instead of pipe
count=0
while read line; do
    ((count++))
done < file.txt
echo $count    # Displays the correct value

# ALTERNATIVE - use process substitution
count=0
while read line; do
    ((count++))
done < <(cat file.txt)
echo $count    # Works
```

### The script works manually but not from cron

Cron runs with a minimal PATH and without your environment variables.

```bash
# BASH (Ubuntu)
# Solution 1: Add PATH in crontab
crontab -e
# Add at the beginning:
# PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# Solution 2: Use absolute paths in the script
# Instead of:
grep pattern file.txt
# Write:
/usr/bin/grep pattern /home/user/file.txt

# Solution 3: Source .bashrc at the beginning
#!/usr/bin/env bash
source ~/.bashrc
# ... rest of the script
```

### Line endings Windows vs Linux (CRLF vs LF)

Files edited in Windows have `\r\n` at the end of lines. Linux expects only `\n`. Symptoms: strange behaviour, error messages with `^M`.

```bash
# BASH (Ubuntu)
# Check the file type
file script.sh
# If it says "with CRLF line terminators" - that is the problem

# Convert with sed
sed -i 's/\r$//' script.sh

# OR with dos2unix
sudo apt install dos2unix
dos2unix script.sh

# Verification
cat -A script.sh | head -5
# OK lines end in $ 
# Lines with CRLF end in ^M$
```

---

## Problems with Git

### "fatal: not a git repository"

```bash
# BASH (Ubuntu)
# You are in the wrong directory
pwd
# Navigate to the directory with the repository
cd ~/so-lab/proiecte/M05_Deployment_Pipeline

# OR initialise a new repo
git init
```

### "error: failed to push some refs"

```bash
# BASH (Ubuntu)
# Someone modified the remote repository
# Pull before push
git pull origin main
# Resolve any conflicts
git push origin main

# OR force the push (CAUTION: overwrites others' changes)
git push -f origin main
```

### How to undo the last commit

```bash
# BASH (Ubuntu)
# Keep the changes, undo only the commit
git reset --soft HEAD~1

# Undo the commit AND the changes (CAUTION: data loss)
git reset --hard HEAD~1
```

---

## Problems with SSH

### "Connection refused" when connecting with PuTTY

1. Verify that Ubuntu is running (the WSL window must be open)
2. Verify that SSH is started:
   ```bash
   # BASH (Ubuntu)
   sudo service ssh status
   # If it is stopped:
   sudo service ssh start
   ```
3. Verify the IP address:
   ```bash
   hostname -I
   # Use the first address displayed
   ```
4. Verify that Windows firewall is not blocking port 22

### "Host key verification failed"

```bash
# BASH (Ubuntu)
# Delete the old key
ssh-keygen -R hostname_or_ip

# Reconnect (it will ask you to accept the new key)
ssh user@hostname
```

---

# PART VII: DEVELOPER TOOLS

This section documents the shared utilities and automation scripts available in the kit. If you are an instructor customising materials or a student debugging the autograder, this is where you will find the relevant documentation.

---

## Shared Utilities (lib/)

The `lib/` directory contains Python modules used across all seminars. These are not student-facing code — they power the autograders, quiz generators, and anti-plagiarism infrastructure.

### logging_utils.py

Provides consistent, coloured logging across all Python scripts. Every autograder and test script uses this module to produce readable output that distinguishes informational messages from warnings and errors.

```python
from logging_utils import setup_logging

logger = setup_logging(__name__)
logger.info("Processing started")
logger.warning("Low disk space")
logger.error("File not found")
```

The colours are intentional: green for success, yellow for warnings, red for errors. When you run 20 test cases, this helps you find problems without reading every line.

### randomisation_utils.py

Generates deterministic, student-specific test parameters for anti-plagiarism. The key insight is that each student gets different test inputs, but those inputs are reproducible — if you run the autograder twice with the same student email and assignment, you get the same parameters.

```python
from randomisation_utils import generate_student_seed, randomise_test_parameters

seed = generate_student_seed("student@ase.ro", "SEM03_HW")
params = randomise_test_parameters(seed)
# Same student + assignment = same parameters (reproducible)
```

This approach makes copying homework useless: two students with the same code will fail each other's tests, because their expected outputs differ.

For complete documentation including all available functions and parameters, see `lib/README.md`.

---

## Automation Scripts (scripts/)

The `scripts/` directory contains maintenance and CI automation. These are designed for instructors managing the kit, not for student use.

### check_links.sh

Validates documentation links across the entire kit. A broken link in a seminar handout is worse than no link at all — it wastes student time.

```bash
# Check internal links only (fast, ~10 seconds)
./scripts/check_links.sh

# Check all links including external URLs (slow, ~2 minutes)
./scripts/check_links.sh --external

# Show help
./scripts/check_links.sh --help
```

The script uses [lychee](https://github.com/lycheeverse/lychee) if installed, falling back to a simpler grep-based check otherwise. For best results:

```bash
cargo install lychee
# or on macOS
brew install lychee
```

### add_print_styles.sh

Injects print stylesheets into HTML presentations for offline handouts. Before this existed, printing slides produced unreadable output with cut-off text and broken layouts.

```bash
# Preview changes (shows what would be modified)
./scripts/add_print_styles.sh --dry-run

# Apply changes
./scripts/add_print_styles.sh
```

After running, presentations can be printed cleanly from any browser (Ctrl+P / Cmd+P). The stylesheet hides navigation elements, adjusts fonts for paper, and ensures code blocks do not overflow.

---

## CI Pipeline

Each seminar includes a GitHub Actions CI configuration (`ci/github_actions.yml`). Version 2.2 of the pipeline includes seven jobs:

| Job | What It Does | Why It Matters |
|-----|--------------|----------------|
| `lint-bash` | ShellCheck on all Bash scripts | Catches common errors like unquoted variables |
| `lint-python` | Ruff on all Python code | Enforces consistent style and catches bugs |
| `validate-yaml` | Quiz and config validation | Ensures quiz files are well-formed |
| `ai-check` | AI fingerprint detection | Flags suspiciously polished submissions |
| `link-check` | Documentation link validation | Prevents broken links from reaching students |
| `test` | pytest with coverage threshold | Verifies autograder correctness |
| `structure-check` | Directory structure validation | Ensures standard kit layout |

The AI fingerprint detection deserves explanation: it looks for patterns common in LLM-generated code (overly verbose comments, certain phrasings, suspiciously complete error handling for a beginner). It is not definitive proof, but it flags submissions for manual review.

Run locally with:

```bash
cd SEM01
make test        # Run tests
make lint        # Run linters
make ai-check    # Check for AI patterns
```

---

## Testing

### Running Tests

The testing infrastructure uses pytest throughout. Tests live in `lib/` for shared utilities and in `SEM*/tests/` for seminar-specific validation.

```bash
# Run all lib tests
cd lib/
pytest -v test_*.py

# Run with coverage report
pytest -v --cov=. --cov-report=term-missing

# Run seminar-specific tests
cd SEM01/tests/
pytest -v
```

### Test Coverage Targets

| Component | Target | Rationale |
|-----------|--------|-----------|
| lib/ | >80% | These modules are used everywhere; bugs propagate |
| Autograders | >75% | Incorrect grading undermines student trust |
| Quiz generators | >70% | Less critical; manual review catches most issues |

The coverage targets are enforced in CI — a pull request that drops coverage below the threshold will not merge.

---

# PART VIII: STORIES AND HISTORICAL CONTEXT

---

## Where the Things We Use Come From

Every command and concept in Unix has a history. Here are a few worth knowing.

### Thompson and Ritchie at Bell Labs (1969-1973)

Unix started as a personal project. Ken Thompson wanted to port a game (Space Travel) to an unused PDP-7. In the process, he created an operating system. Dennis Ritchie joined and created the C language so they could rewrite Unix portably.

The PDP-7 had 18 KB of memory. The entire operating system, with shell and utilities, fit in there. Today, a web favicon takes up more.

In 1983, Thompson and Ritchie received the Turing Award — the most prestigious award in computer science. Ritchie died in October 2011, a week after Steve Jobs. Jobs got the press attention; Ritchie went almost unnoticed. Ironically, Jobs's iPhone runs on a kernel derived from Unix.

### Pipes — One Night's Work (1973)

Doug McIlroy, Thompson's department head, kept insisting that programmes should be able to connect "like a garden hose" — the output of one should be the input of another.

Thompson implemented pipes in a single night. The next day, the team rewrote all utilities to support them. The idea defined Unix and influenced everything that came after.

The `|` notation for pipe comes from the convention used in mathematical logic for "or". It was chosen because it looks like a tube.

### Why Commands Have Strange Names

- `ls` = "list" (shortened to type faster)
- `cd` = "change directory"
- `pwd` = "print working directory"
- `cat` = "concatenate" (originally for concatenating files, now also used to display them)
- `grep` = "**g**lobal **r**egular **e**xpression **p**rint" — a command from the `ed` editor
- `awk` = Aho, Weinberger, Kernighan — the creators' initials
- `sed` = "**s**tream **ed**itor"
- `cron` = Chronos, the Greek god of time

Teletypes from the '70s were slow. The shorter the command name, the faster you could type. That is why `cp` instead of `copy`, `mv` instead of `move`, `rm` instead of `remove`.

### Regular Expressions — From Mathematics to grep

Stephen Kleene invented regular expressions in 1951 for formal language theory. Ken Thompson first implemented them in software in 1968, in a text editor.

When Thompson created `grep` in 1973, he took the implementation from the editor and made it a standalone command. `grep` comes from `ed`, the Unix line editor: the command `g/re/p` meant "**g**lobal search for **r**egular **e**xpression and **p**rint".

### The Creator of Bash

Bash was created by Brian Fox in 1989 for the GNU project. The goal was to replace Bourne Shell (sh) with something compatible but improved. The name is an acronym and a pun: **B**ourne **A**gain **SH**ell.

Fox worked alone on the first version. He left the project in 1994, and Chet Ramey took over maintenance. Ramey still maintains Bash today, after 30 years.

### Why Linux Is Called Linux

Linus Torvalds created the kernel in 1991, as a student at the University of Helsinki. He originally wanted to call it "Freax" (free + freak + x from Unix), but the administrator of the FTP server where he published it did not agree and put it in a folder named "Linux" (Linus + Unix).

Torvalds accepted the name reluctantly. He wrote on the mailing list: "it's too egotistical, I can't name something after myself".

---

## Why Some Things Are the Way They Are

### Why 755 and 644?

Unix permissions are stored as an octal number. Each digit represents permissions for owner, group, others:
- 7 = rwx (read + write + execute) = 4 + 2 + 1
- 5 = r-x (read + execute) = 4 + 0 + 1
- 4 = r-- (read only) = 4 + 0 + 0

755 for directories and scripts (executable by all, modifiable only by owner).
644 for normal files (readable by all, modifiable only by owner).

Could it have been different? Yes. But when you have billions of scripts that set `chmod 755`, you can no longer change.

### Why $HOME and not something else?

Environment variables were invented in Version 7 Unix (1979). The `$VARIABLE` convention comes from Bourne Shell. The `$` sign was chosen because it was not used for anything else in the syntax.

Why uppercase? To distinguish them from local shell variables. The convention is just that — a convention. It is not enforced by the system.

### Why is the shebang `#!`?

The first line `#!/bin/bash` is called the "shebang" (or "hashbang"). When Unix sees an executable file that starts with `#!`, it uses the specified programme as the interpreter.

Why `#!`? `#` was already used for comments in the shell. `!` is the character that meant, in some contexts, "execute". The combination was unused and distinctive.

The term "shebang" comes from slang. Perhaps from "sharp bang" (#!), perhaps from the Irish expression "shebeen" (illegal bar). Nobody knows for sure.

---

# PART IX: REFERENCES AND RESOURCES

---

## Official Documentation

- [GNU Bash Reference Manual](https://www.gnu.org/software/bash/manual/) — The complete reference
- [POSIX Shell Specification](https://pubs.opengroup.org/onlinepubs/9699919799/utilities/V3_chap02.html) — Portable standard
- [Linux man pages](https://man7.org/linux/man-pages/) — Documentation for each command

## Recommended Books

- **"The Linux Command Line"** - William Shotts — Free online, excellent for beginners
- **"Learning the bash Shell"** - O'Reilly — Classic for Bash
- **"Operating Systems: Three Easy Pieces"** - Arpaci-Dusseau — OS theory, available free

## Interactive Tutorials

- [Exercism Bash Track](https://exercism.org/tracks/bash) — Exercises with feedback
- [OverTheWire Bandit](https://overthewire.org/wargames/bandit/) — Wargame for shell
- [ShellCheck](https://www.shellcheck.net/) — Online linter for scripts

## Computing Education Research

- [SIGCSE](https://sigcse.org/) — The main community
- [ACM TOCE](https://dl.acm.org/journal/toce) — Reference journal
- [Computing Education Research Blog](https://computinged.wordpress.com/) — Mark Guzdial's blog

---

# PART X: LICENCE

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                           RESTRICTIVE LICENCE                                ║
║                    Version 4.0.0 · January 2025                              ║
║              © 2025 Antonio Clim. All rights reserved.                       ║
╚══════════════════════════════════════════════════════════════════════════════╝
```

### Permitted Uses

✓ **Personal study** — download and use the materials for individual learning  
✓ **Code execution** — run the examples on your devices  
✓ **Local modification** — adapt the code for personal experiments  
✓ **Personal notes** — create derivative notes for your own use

### Prohibited Uses (without prior written agreement)

✗ **Publication** — uploading or distributing the materials on any platform  
✗ **Teaching** — use in courses, workshops or training sessions  
✗ **Presentation** — teaching or presenting the materials to third parties  
✗ **Redistribution** — redistribution in any form  
✗ **Derivative works** — creating derivative works for public use  
✗ **Commercial use** — commercial exploitation of any kind

### Legal Provisions

**No warranty** — The materials are provided "as is" without any warranty, express or implied, including, but not limited to, the warranties of merchantability, fitness for a particular purpose and non-infringement.

**Limitation of liability** — In no circumstance shall the author be liable for any claim, damages or other liability, whether in an action of contract, tort or otherwise, arising from or in connection with the materials.

**Applicable law** — These terms are governed by the laws of Romania. Disputes shall be subject to the exclusive jurisdiction of the courts of Bucharest.

**Contact for permissions** — For requests regarding educational use, publication or other permissions, contact the author through official academic channels or through the repository issue tracker.

### Attribution Requirements

When citing these materials in academic works (where permitted):

```
Clim, A. (2025). ROso — Educational Kit for Operating Systems (Extended Edition).  
Bucharest University of Economic Studies — CSIE.
```

---

# ANNEXES

---

## Annex A: Standard Lab Credentials

For consistency in the lab, we use these credentials:

**Ubuntu/WSL:**
```
User: stud (or your surname)
Pass: stud
```

**Portainer (Docker management):**
```
URL:  http://localhost:9000
User: stud
Pass: studstudstud
```

---

## Annex B: Emergency Commands

When something does not work and you do not know why:

```bash
# BASH (Ubuntu)
# Check the system version
lsb_release -a
uname -a

# Check disk space
df -h

# Check memory
free -h

# Check processes
top -bn1 | head -20

# Check recent logs
journalctl -xe --no-pager | tail -50

# Restart WSL (from PowerShell)
# wsl --shutdown
# wsl
```

---

## Annex C: Complete .gitignore Template

```gitignore
# =============================================================================
# .gitignore for SO Assignments/Projects
# =============================================================================

# Temporary files
*.tmp
*.temp
*.bak
*.backup
*~
*.swp
*.swo

# Logs and output
*.log
*.out
*.err

# Python
__pycache__/
*.py[cod]
*.pyo
venv/
env/
.env

# Build
*.o
*.a
*.so
*.exe

# IDE
.idea/
.vscode/
*.sublime-*

# OS
.DS_Store
Thumbs.db
Desktop.ini

# Archives (do not commit them)
*.zip
*.tar.gz
*.rar
*.7z

# Generated directories
output/
results/
build/
dist/

# Files with sensitive data
*.key
*.pem
passwords.txt
secrets.*
```

---

## Annex D: Weekly Workflow

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         THE COURSE WEEK                                      │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│    ┌──────────────┐     ┌──────────────┐     ┌──────────────┐              │
│    │ BEFORE THE   │     │ DURING THE   │     │ AFTER THE    │              │
│    │   SEMINAR    │────▶│   SEMINAR    │────▶│   SEMINAR    │              │
│    └──────────────┘     └──────────────┘     └──────────────┘              │
│           │                    │                    │                       │
│           ▼                    ▼                    ▼                       │
│    ┌──────────────┐     ┌──────────────┐     ┌──────────────┐              │
│    │ 1. Read      │     │ 1. Participate│    │ 1. Review    │              │
│    │    README    │     │    actively  │     │    notes     │              │
│    │              │     │              │     │               │              │
│    │ 2. Go through│     │ 2. Note the  │     │ 2. Complete  │              │
│    │    MATERIAL_ │     │    commands  │     │    assignment│              │
│    │    PRINCIPAL │     │              │     │               │              │
│    │              │     │ 3. Ask when  │     │ 3. Run       │              │
│    │ 3. Prepare   │     │    you don't │     │    validator │              │
│    │    environment│    │    understand│     │               │              │
│    └──────────────┘     └──────────────┘     └──────────────┘              │
│                                                                             │
│    Time: 30 min         Time: 100 min        Time: 60-90 min               │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Annex E: Kit Statistics

| Category | Quantity | Details |
|-----------|-----------|---------|
| Theoretical courses | 14 | SO_curs01 to SO_curs14 |
| Supplementary lectures | 4 | Network, Containers, Kernel, NPU |
| Practical seminars | 7 | SEM01 to SEM07 |
| Semester projects | 23 | 5 EASY + 15 MEDIUM + 3 ADVANCED |
| Markdown files | 362 | Documentation, guides, and specifications |
| HTML presentations | 71 | Interactive slides with print support |
| PNG diagrams | 27 | In 00_SUPPLEMENTARY/ |
| SVG diagrams | 26 | Vector graphics throughout |
| Python scripts | 65 | Autograders, tools, tests |
| Bash scripts | 118 | Demos, utilities, validators |
| YAML quiz files | 28 | Structured question banks |
| Test files | 25+ | pytest and shell tests |
| Estimated hours (total) | 60+ | For complete coverage |
| Demonstration scripts | 180+ | Combined Bash and Python |
| Exam exercises | 3 sets | In 00_SUPPLEMENTARY/ |

---

## Annex F: Changelog

### Version 5.3.1 (January 2026)

**New Features:**
- Added print stylesheets to all HTML presentations (`assets/css/print.css`)
- Added link checking to CI pipeline (`scripts/check_links.sh`)
- Expanded test coverage for lib/ utilities to >80%
- Added comprehensive lib/README.md documentation

**Improvements:**
- Updated CI to version 2.2 with link-check job
- Standardised script documentation across all seminars
- Enhanced test templates with better error messages
- Added SEM07 for evaluation and grading procedures

**Files Added:**
- `lib/README.md`
- `lib/test_logging_utils.py`
- `lib/test_randomisation_utils.py`
- `scripts/check_links.sh`
- `scripts/add_print_styles.sh`
- `assets/css/print.css`
- `SEM01/tests/test_ai_fingerprint.py`

### Version 5.3.0 (December 2025)

- Initial FAZA 5-6 release
- Complete restructure with 14 weeks
- AI-aware exercises integrated throughout
- Anti-plagiarism infrastructure with MOSS/JPlag integration

### Version 4.0.0 (September 2025)

- Major reorganisation of folder structure
- Added project difficulty classification (EASY/MEDIUM/ADVANCED)
- Introduced autograder framework
- Standardised seminar format

---

*Kit updated: January 2026*  
*Version: 5.3.1*  
*Tested on: Ubuntu 24.04 LTS, WSL2 with Ubuntu 22.04/24.04*  
*Feedback and errors: through GITHUB issue tracker*

---

**ing. dr. Antonio Clim**  
Assistant Lecturer (fixed-term) | Bucharest University of Economic Studies — CSIE
