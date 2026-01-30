# COMPLETE INSTALLATION GUIDE FOR BEGINNERS
## Ubuntu Server 24.04 LTS in VirtualBox (Virtual Machine)

> *Personal note: Many prefer `zsh`, but I stick with Bash because it is the standard on servers. Consistency beats comfort.*

### Bucharest University of Economic Studies - CSIE
### Operating Systems - Academic Year 2024-2025

---

# READ BEFORE YOU BEGIN

**WHEN SHOULD YOU USE THIS GUIDE?**

This guide is an alternative to WSL2. Use it if:
- You have Mac (macOS) or Linux instead of Windows
- You cannot install WSL2 on Windows (old version, restrictions)
- You prefer a complete virtual machine

**WHAT WILL YOU HAVE AT THE END?**

A complete Ubuntu Linux server running in a window on your computer.

**HOW LONG DOES IT TAKE?**

Approximately 60-90 minutes. Use the time checkpoints below to track progress.

---

# ⏱️ TIME CHECKPOINTS

Use these to track your progress. Taking longer than expected is normal for first-timers.

| Checkpoint | Section | Expected time | Your time |
|------------|---------|---------------|-----------|
| 🚀 Start | — | 0 min | ⬜ |
| ✓ VirtualBox + Extension Pack installed | Section 6 | 20 min | ⬜ |
| ✓ VM created with correct settings | Section 8 | 30 min | ⬜ |
| ✓ Ubuntu installed, account created | Section 9 | 50 min | ⬜ |
| ✓ Hostname configured | Section 10 | 55 min | ⬜ |
| ✓ All software installed | Section 11 | 70 min | ⬜ |
| ✓ SSH working, can connect remotely | Section 13/15 | 80 min | ⬜ |
| 🎉 Verification passed | Section 17 | 90 min | ⬜ |

---

# LEARNING OUTCOMES (What you will be able to do after this guide)

At the end of this guide, you will be able to:

- [ ] **LO1:** Install VirtualBox + Extension Pack on Windows, macOS or Linux
- [ ] **LO2:** Create a virtual machine with the correct parameters (4GB RAM, 2 CPU, 25GB disk, Bridge network)
- [ ] **LO3:** Install Ubuntu Server 24.04 and configure user (surname) and hostname (`INITIAL_GROUP_SERIES`)
- [ ] **LO4:** Connect via SSH to the VM and transfer files with PuTTY/WinSCP (Windows) or ssh/scp (macOS/Linux)
- [ ] **LO5:** Manage the VM headless (start/stop from command line with `VBoxManage`)
- [ ] **LO6:** Enable virtualisation in BIOS when disabled and resolve Bridge network issues

---

# HOW TO READ THIS GUIDE

## Types of commands

### PowerShell Commands (Windows)

```powershell
# POWERSHELL (Windows) - Blue background
# This is a command for Windows PowerShell
Get-Process
```

### macOS Terminal Commands

```bash
# TERMINAL (macOS) - Grey/black background
# This is a command for Mac
ls -la
```

### Linux Terminal Commands (on your computer, not in VM)

```bash
# LINUX TERMINAL (host) - Black background
# This is a command for your main Linux system
sudo apt install virtualbox
```

### Commands in Ubuntu VM (virtual machine)

```bash
# UBUNTU VM - Black background
# This is a command for Ubuntu inside VirtualBox
sudo apt update
```

## How to copy and paste

1. Select the command with the mouse
2. Copy with `Ctrl+C` (Windows/Linux) or `Cmd+C` (Mac)
3. Paste:
   - Windows PowerShell: `Ctrl+V` or right-click
   - macOS Terminal: `Cmd+V`
   - Linux Terminal: `Ctrl+Shift+V`
   - In VirtualBox (Ubuntu): Right-click or `Ctrl+Shift+V`

---

# TABLE OF CONTENTS

**PART 1: PREPARATION**
1. [Check system requirements](#1-check-system-requirements)
2. [Download everything you need](#2-download-everything-you-need)

**PART 2: VIRTUALBOX INSTALLATION**
3. [Installation on Windows](#3-virtualbox-installation-on-windows)
4. [Installation on macOS](#4-virtualbox-installation-on-macos)
5. [Installation on Linux](#5-virtualbox-installation-on-linux)
6. [Extension Pack Installation (everyone)](#6-extension-pack-installation)

**PART 3: VIRTUAL MACHINE CREATION**
7. [Create the virtual machine](#7-create-the-virtual-machine)
8. [Configure Bridge network](#8-configure-bridge-network)

**PART 4: UBUNTU INSTALLATION**
9. [Install Ubuntu Server](#9-install-ubuntu-server)
10. [Post-installation configuration](#10-post-installation-configuration)
11. [Install required software](#11-install-required-software)

**PART 5: REMOTE ACCESS**
12. [Configure SSH](#12-configure-ssh)
13. [Connect with PuTTY (Windows)](#13-connect-with-putty-windows)
14. [Connect with WinSCP (Windows)](#14-connect-with-winscp-windows)
15. [Connect from macOS or Linux](#15-connect-from-macos-or-linux)

**PART 6: FINALISATION**
16. [Create working folders](#16-create-working-folders)
17. [Verify the installation](#17-verify-the-installation)
18. [Common problems and solutions](#18-common-problems-and-solutions)
19. [Common mistakes I see every year](#19-common-mistakes-i-see-every-year)
20. [How to use AI assistants](#20-how-to-use-ai-assistants)

---

# PART 1: PREPARATION

---

# 1. Check system requirements

## What you need

| Component | Minimum required | Recommended |
|-----------|------------------|-------------|
| Total RAM | 8 GB | 16 GB |
| Free space | 30 GB | 50 GB |
| Processor | 64-bit with virtualisation | Intel Core i5+ or AMD Ryzen 5+ |

## Check virtualisation (IMPORTANT!)

Hardware virtualisation must be enabled. Here is how to check on each system:

### On Windows

**Step 1:** Press `Ctrl + Shift + Esc` to open Task Manager

**Step 2:** Click on the Performance tab

**Step 3:** Click on CPU on the left

**Step 4:** Look in the bottom right for: "Virtualization: Enabled"

If it says "Disabled", you need to enable virtualisation in BIOS (see Section 18).

> **True story from 2022:** A student with a brand new gaming laptop could not start any VM. After an hour of debugging, we discovered the manufacturer had disabled virtualisation by default to "improve battery life". One BIOS setting later, everything worked. Always check this first.

### On macOS

**Step 1:** Open Terminal (Finder → Applications → Utilities → Terminal)

**Step 2:** Type this command and press Enter:

```bash
sysctl -a | grep machdep.cpu.features | grep VMX
```

If text containing "VMX" appears, virtualisation is enabled. Modern Macs have virtualisation enabled by default.

**Step 3:** Check the processor type:

```bash
uname -m
```

- If `x86_64` appears = you have a Mac with Intel processor
- If `arm64` appears = you have a Mac with Apple Silicon processor (M1/M2/M3/M4)

**⚠️ WARNING for Mac with Apple Silicon:** VirtualBox works but with limited performance. A better alternative is UTM (https://mac.getutm.app/).

### On Linux

**Step 1:** Open the terminal

**Step 2:** Run:

```bash
egrep -c '(vmx|svm)' /proc/cpuinfo
```

If the result is a number greater than 0, virtualisation is supported.

---

# 2. Download everything you need

## Create a folder for downloads

### On Windows

Open File Explorer and create the folder: `C:\VirtualBox_Kits`

### On macOS or Linux

Open the terminal and run:

```bash
mkdir -p ~/VirtualBox_Kits
```

## Download VirtualBox

**Step 1:** Open the browser and go to: https://www.virtualbox.org/wiki/Downloads

**Step 2:** Download the version for your system:

| Your system | What to download |
|-------------|------------------|
| Windows | Click on "Windows hosts" |
| macOS with Intel | Click on "macOS / Intel hosts" |
| macOS with Apple Silicon | Click on "macOS / Arm64 hosts" |
| Linux | Click on "Linux distributions" and choose your distribution |

**Step 3:** Save the file in the folder created earlier

## Download Extension Pack

**Step 1:** On the same page, at the "VirtualBox Extension Pack" section

**Step 2:** Click on "All supported platforms"

**Step 3:** Save the file (named something like `Oracle_VM_VirtualBox_Extension_Pack-7.x.x.vbox-extpack`)

**Note:** The Extension Pack version MUST be the same as the VirtualBox version!

## Download Ubuntu Server

**Step 1:** Go to: https://ubuntu.com/download/server

**Step 2:** Click on "Download Ubuntu Server 24.04 LTS"

**Step 3:** Save the ISO file (approximately 2.5 GB, may take 10-30 minutes)

## What you should have now

In your folder you should have 3 files:
1. The VirtualBox installer (`.exe` for Windows, `.dmg` for Mac)
2. Extension Pack (`.vbox-extpack`)
3. Ubuntu Server ISO (`ubuntu-24.04-live-server-amd64.iso`)

---

# PART 2: VIRTUALBOX INSTALLATION

---

# 3. VirtualBox Installation on Windows

*Skip this step if you have macOS or Linux!*

## Run the installer

**Step 1:** Go to the folder `C:\VirtualBox_Kits`

**Step 2:** Double-click on the VirtualBox file (e.g.: `VirtualBox-7.x.x-xxxxx-Win.exe`)

**Step 3:** If "User Account Control" appears asking "Do you want to allow this app to make changes?", click Yes

## Go through the installation wizard

**Screen 1 — Welcome:**
- Click Next

**Screen 2 — Custom Setup:**
- Leave everything ticked (all components)
- Click Next

**Screen 3 — Warning: Network Interfaces:**
- A message appears that the network will be temporarily disconnected
- Click Yes

**Screen 4 — Missing Dependencies (if it appears):**
- Click Yes to install missing dependencies

**Screen 5 — Ready to Install:**
- Click Install

**Screen 6 — Driver installation:**
- Windows may ask 2-3 times if you want to install drivers from Oracle
- Click Install each time

**Screen 7 — Finish:**
- Tick "Start Oracle VM VirtualBox after installation"
- Click Finish

VirtualBox should now open automatically.

---

# 4. VirtualBox Installation on macOS

*Skip this step if you have Windows or Linux!*

## Run the installer

**Step 1:** Go to the folder `~/VirtualBox_Kits` (in Finder)

**Step 2:** Double-click on the `.dmg` file

**Step 3:** A window opens with the VirtualBox icon. Double-click on `VirtualBox.pkg`

## Go through the installation

**Step 1:** At the welcome screen, click Continue

**Step 2:** At the installation location, click Install

**Step 3:** macOS will ask for your password. Type it and click "Install Software"

**Step 4:** A security message may appear: "System Extension Blocked"
- Click "Open Security Preferences"
- In the Security window, click "Allow" next to the Oracle message
- You may need to restart the Mac

**Step 5:** Click Close when the installation finishes

## Open VirtualBox

Go to Applications → VirtualBox, or use Spotlight (`Cmd + Space`, type "VirtualBox")

---

# 5. VirtualBox Installation on Linux

*Skip this step if you have Windows or macOS!*

## On Ubuntu/Debian

```bash
sudo apt update
sudo apt install virtualbox virtualbox-ext-pack
```

At the question about the license, use Tab to select "Ok" and press Enter, then select "Yes".

## On Fedora

```bash
sudo dnf install VirtualBox
```

## On Arch Linux

```bash
sudo pacman -S virtualbox virtualbox-host-modules-arch
```

## After installation

Add your user to the vboxusers group:

```bash
sudo usermod -aG vboxusers $USER
```

**Log out and log back in** for the group change to take effect.

---

# 6. Extension Pack Installation

*This step is for EVERYONE, regardless of operating system!*

## Why do you need Extension Pack?

The Extension Pack adds features like USB 2.0/3.0 support, which are useful for the course.

## Installation

**Step 1:** Open VirtualBox (if not already open)

**Step 2:** From the menu: File → Tools → Extension Pack Manager (or Preferences → Extensions on older versions)

**Step 3:** Click on the "Install" button (icon with a + sign)

**Step 4:** Navigate to the downloads folder and select the Extension Pack file (`Oracle_VM_VirtualBox_Extension_Pack-7.x.x.vbox-extpack`)

**Step 5:** A license window appears. Scroll down and click "I Agree"

**Step 6:** If it asks for administrator password, type it

**Done!** The Extension Pack appears in the list as "Oracle VM VirtualBox Extension Pack" with status "Active".

---

# PART 3: VIRTUAL MACHINE CREATION

---

# 7. Create the virtual machine

## Start the wizard

**Step 1:** In VirtualBox, click on the New button (or from menu: Machine → New)

## Configure — Step 1: Name and operating system

- **Name:** `Ubuntu-Server-2404-SO`
- **Folder:** leave default or choose a folder with space
- **ISO Image:** Click on the dropdown arrow and select Other...
  - Navigate to the downloads folder
  - Select the file `ubuntu-24.04-live-server-amd64.iso`
- **Type:** `Linux`
- **Version:** `Ubuntu (64-bit)`

**Note:** Tick "Skip Unattended Installation" — we want to install manually!

Click Next

## Configure — Step 2: Hardware

- **Base Memory:** Drag the slider or type `4096` MB (i.e. 4 GB)
  - If you only have 8 GB RAM total, you can set 2048 MB (2 GB)
- **Processors:** `2`
  - If you have a weak processor, leave 1
- Tick "Enable EFI" (optional but recommended)

Click Next

## Configure — Step 3: Hard Disk

- Select "Create a Virtual Hard Disk Now"
- **Disk Size:** `25 GB` (minimum) or `50 GB` (if you have space)
- **DO NOT tick** "Pre-allocate Full Size" — leave it unticked

Click Next

## Configure — Step 4: Summary

Verify settings:
- Name: Ubuntu-Server-2404-SO
- Memory: 4096 MB
- Processors: 2
- Disk: 25 GB

Click Finish

The virtual machine is created! You can now see it in the list on the left.

---

# 8. Configure Bridge network

## What is Bridge network?

Bridge makes Ubuntu inside VirtualBox appear as a separate computer in your network. It will receive an IP address from your router, like any other device in your home.

> **Lab observation:** About 30% of "SSH doesn't work" issues come from using NAT instead of Bridge. NAT isolates the VM — you can reach the internet, but nothing can reach you. Bridge gives you a real IP on your local network.

## Configuration

**Step 1:** In VirtualBox, select the machine `Ubuntu-Server-2404-SO` (click on it)

**Step 2:** Click on Settings (or right-click → Settings)

**Step 3:** In the menu on the left, click on Network

**Step 4:** In the Adapter 1 tab:
- **Enable Network Adapter:** must be ticked ✓
- **Attached to:** select "Bridged Adapter" from the dropdown
- **Name:** select your computer's network interface

### How do you know which interface to select?

**On Windows:**
- If you are connected via cable: choose something with "Ethernet" in the name
- If you are on Wi-Fi: choose something with "Wi-Fi" or "Wireless" in the name

**On macOS:**
- Wi-Fi on MacBook: usually `en0`
- Ethernet (if you have it): usually `en1`

**On Linux:**
- Ethernet: `eth0`, `enp3s0`, or similar
- Wi-Fi: `wlan0`, `wlp2s0`, or similar

If you are not sure, try the first option. You can change it later.

**Step 5:** Click OK to save

---

# PART 4: UBUNTU INSTALLATION

---

# 9. Install Ubuntu Server

## Start the virtual machine

**Step 1:** Select `Ubuntu-Server-2404-SO` in VirtualBox

**Step 2:** Click on Start (the green button with arrow)

A new window opens and boot from ISO begins.

## Boot screen

When the menu appears, select:

**Try or Install Ubuntu Server**

Press Enter

Wait 1-2 minutes for the installer to load.

## Installation — Step 1: Language

Use the up/down arrows to select. Select:

**English**

Press Enter

## Installation — Step 2: Keyboard

- Layout: English (US) or Romanian
- Variant: English (US) or Romanian (Standard)

**Recommendation:** Leave English (US) for compatibility.

Navigate with Tab to [ Done ] and press Enter

## Installation — Step 3: Installation type

Select:

**(X) Ubuntu Server**

Navigate to [ Done ] and press Enter

## Installation — Step 4: Network

The installer should detect your network automatically. You should see an IP address (e.g.: `192.168.1.105`).

If you see "DHCPv4" with an IP address — you are OK.

If you see "not configured" — check the Bridge network settings (Section 8).

Navigate to [ Done ] and press Enter

## Installation — Step 5: Proxy

Leave empty (unless you know you need a proxy).

Navigate to [ Done ] and press Enter

## Installation — Step 6: Ubuntu archive mirror

Leave the default.

Navigate to [ Done ] and press Enter

## Installation — Step 7: Storage configuration

Select:

**(X) Use an entire disk**

Make sure "Set up this disk as an LVM group" is ticked.

Navigate to [ Done ] and press Enter

A summary appears. Navigate to [ Done ] and press Enter again.

A confirmation message appears: "Confirm destructive action". Navigate to [ Continue ] and press Enter.

## Installation — Step 8: Profile setup

This is where you create your account.

- **Your name:** Your full name (e.g.: `Ion Popescu`)
- **Your server's name:** Your hostname in format `INITIAL_GROUP_SERIES` (e.g.: `IP_1001_A`)
- **Pick a username:** Your surname in lowercase (e.g.: `popescu`)
- **Choose a password:** `stud`
- **Confirm your password:** `stud`

Navigate to [ Done ] and press Enter

## Installation — Step 9: Ubuntu Pro

Select:

**Skip for now**

Navigate to [ Continue ] and press Enter

## Installation — Step 10: SSH Setup

**IMPORTANT:** Tick this option!

**[X] Install OpenSSH server**

Navigate to [ Done ] and press Enter

## Installation — Step 11: Featured Server Snaps

Do not select anything here. We will install what we need manually.

Navigate to [ Done ] and press Enter

## Installation in progress

Now wait for the installation to complete. This may take 5-15 minutes.

When you see "Install complete!" at the top, navigate to [ Reboot Now ] and press Enter.

## After reboot

The VM will restart. You may see a message "Please remove the installation medium". Just press Enter.

Wait for Ubuntu to boot. You will see a login prompt:

```
Ubuntu-Server-2404-SO login:
```

Type your username (e.g.: `popescu`) and press Enter.

Type your password (`stud`) and press Enter.

**Remember:** You will not see the password as you type — this is normal.

If you see a prompt like `popescu@IP_1001_A:~$`, congratulations! Ubuntu is installed.

---

# 10. Post-installation configuration

## Check the hostname

```bash
hostname
```

You should see your hostname (e.g.: `IP_1001_A`). If you see something else or need to change it:

```bash
sudo hostnamectl set-hostname INITIAL_GROUP_SERIES
```

Replace `INITIAL_GROUP_SERIES` with your actual hostname (e.g.: `IP_1001_A`).

## Update the system

```bash
sudo apt update && sudo apt -y upgrade
```

This may take 5-10 minutes. Wait for it to complete.

---

# 11. Install required software

## Install everything you need

Copy and paste this command:

```bash
sudo apt update && sudo apt install -y build-essential git curl wget nano vim tree htop net-tools openssh-server man-db manpages-posix gawk sed grep coreutils findutils diffutils procps sysstat lsof tar gzip bzip2 xz-utils zstd zip unzip p7zip-full iproute2 iputils-ping dnsutils netcat-openbsd traceroute nmap tcpdump gcc g++ make cmake gdb valgrind python3 python3-pip python3-venv shellcheck jq bc figlet cowsay ncdu pv dialog
```

Wait for it to complete (5-15 minutes).

## Install required Python libraries

```bash
pip3 install --break-system-packages rich tabulate psutil
```

---

# PART 5: REMOTE ACCESS

---

# 12. Configure SSH

SSH should already be installed and running (we selected it during installation).

## Check SSH status

```bash
sudo systemctl status ssh
```

You should see "active (running)". Press `q` to exit.

## Enable SSH at boot

```bash
sudo systemctl enable ssh
```

## Find the IP address

```bash
hostname -I
```

**Note this IP address** — you will need it to connect from your main computer.

---

# 13. Connect with PuTTY (Windows)

*Skip this if you use macOS or Linux!*

## Download PuTTY

**Step 1:** Go to: https://www.chiark.greenend.org.uk/~sgtatham/putty/latest.html

**Step 2:** Download the 64-bit MSI installer

**Step 3:** Install it (Next, Next, Install, Finish)

## Configure the connection

**Step 1:** Open PuTTY

**Step 2:** In "Host Name (or IP address)": type the VM IP (e.g.: `192.168.1.105`)

**Step 3:** Port: `22`

**Step 4:** Connection type: SSH

## Configure appearance — Colours

**Step 1:** In the left menu, go to Window → Colours

**Step 2:** Select "Default Background", click Modify:
- Red: 0, Green: 0, Blue: 0
- Click OK

**Step 3:** Select "Default Foreground", click Modify:
- Red: 255, Green: 255, Blue: 255
- Click OK

## Configure the font

**Step 1:** In the left menu, go to Window → Appearance

**Step 2:** Click "Change..." next to Font

**Step 3:** Select:
- Font: Consolas
- Size: 12
- Click OK

## Save and connect

**Step 1:** Go back to Session (top of left menu)

**Step 2:** In "Saved Sessions", type: `Ubuntu-VBox`

**Step 3:** Click Save

**Step 4:** Click Open to connect

**Step 5:** At the security alert, click Accept

**Step 6:** Login with your username and password

---

# 14. Connect with WinSCP (Windows)

*Skip this if you use macOS or Linux!*

## Download WinSCP

**Step 1:** Go to: https://winscp.net/eng/download.php

**Step 2:** Click "Download WinSCP"

**Step 3:** Install it

## Configure and connect

**Step 1:** Open WinSCP

**Step 2:** In the Login window:
- File protocol: SFTP
- Host name: VM IP address
- Port: 22
- User name: your username
- Password: stud

**Step 3:** Click Save, give it a name: `Ubuntu-VBox`

**Step 4:** Click Login

**Step 5:** Accept the security warning

Now you can drag and drop files between your computer and the VM.

---

# 15. Connect from macOS or Linux

## Connect via SSH

Open Terminal and run:

```bash
ssh popescu@192.168.1.105
```

Replace `popescu` with your username and `192.168.1.105` with your VM IP.

At first connection, type `yes` to accept the host key.

Enter your password (`stud`).

## Create an SSH config (optional, saves typing)

**Step 1:** Create/edit the config file:

```bash
nano ~/.ssh/config
```

**Step 2:** Add (replace with your data):

```
Host ubuntu-vm
    HostName 192.168.1.105
    User popescu
    Port 22
```

**Step 3:** Save: press `Ctrl+O`, then `Enter`, then `Ctrl+X`

**Step 4:** Now you can connect simply with:

```bash
ssh ubuntu-vm
```

## File transfer

### With scp command

```bash
scp file.txt popescu@192.168.1.105:/home/popescu/
```

### With sftp command (interactive)

```bash
sftp popescu@192.168.1.105
```

In SFTP mode:
- `put file.txt` — send file
- `get file.txt` — receive file
- `ls` — list files
- `exit` — exit

### Graphical applications

- macOS: Cyberduck (free) — https://cyberduck.io/
- Linux: FileZilla — `sudo apt install filezilla`

---

# PART 6: FINALISATION

---

# 16. Create working folders

In Ubuntu (via SSH or directly in VM), run:

```bash
mkdir -p ~/Books ~/HomeworksOLD ~/Projects ~/ScriptsSTUD ~/test ~/TXT
```

Verify:

```bash
ls -la ~
```

| Folder | Purpose |
|--------|---------|
| `Books` | Books, PDFs |
| `HomeworksOLD` | Old homework |
| `Projects` | Active projects |
| `ScriptsSTUD` | Scripts from seminars |
| `test` | Tests and experiments |
| `TXT` | Text notes |

---

# 17. Verify the installation

## Run the verification script

We have prepared a verification script that checks everything automatically.

**Option 1 — Use the provided script (recommended):**

If you have the `verify_installation.sh` file, copy it to your home directory and run:

```bash
bash ~/verify_installation.sh
```

**Option 2 — Quick one-line check:**

```bash
hostname && whoami && lsb_release -d && hostname -I && echo "---" && ls ~/Books ~/Projects ~/ScriptsSTUD 2>/dev/null && echo "Folders OK"
```

## What you should see

- Your hostname (e.g.: `IP_1001_A`)
- Your username (e.g.: `popescu`)
- Ubuntu 24.04
- An IP address
- "Folders OK"

---

# 18. Common problems and solutions

## VirtualBox does not start — virtualisation error

**Message:** "VT-x is not available" or "AMD-V is disabled"

**Solution:** You need to enable virtualisation in BIOS:
1. Restart the computer
2. Rapidly press the key for BIOS (usually Del, F2, F10 or F12)
3. Look for "Virtualization Technology", "VT-x", "AMD-V" or "SVM"
4. Change from "Disabled" to "Enabled"
5. Save and exit (usually F10)

## Ubuntu does not receive IP (bridge not working)

Check:
1. Are you connected to the internet on the main computer?
2. In VirtualBox Settings → Network, have you selected the correct interface?
3. Try selecting a different network interface

In Ubuntu, try:

```bash
sudo dhclient -v enp0s3
```

## Cannot connect via SSH

Check in Ubuntu:

```bash
sudo systemctl status ssh
```

If it is not running:

```bash
sudo systemctl start ssh
```

Check the IP address:

```bash
hostname -I
```

From the main computer, test:
- Windows: `ping 192.168.1.105` (replace with your IP)
- Mac/Linux: `ping -c 3 192.168.1.105`

## Black screen at boot

- Wait 1-2 minutes (may be slow loading)
- Press Enter (the prompt may not be visible)
- Check Settings → Display → Video Memory: set to 16 MB

## The VM is very slow

- Increase RAM: Settings → System → Base Memory (set 4096 MB if you have enough RAM)
- Increase CPU: Settings → System → Processor (set to 2)
- Close applications on the main computer

## I forgot the password

Stop the VM. In VirtualBox, start the VM in recovery mode:

1. At boot, hold Shift for the GRUB menu
2. Select "Advanced options for Ubuntu"
3. Select an entry with "(recovery mode)"
4. Select "root — Drop to root shell"
5. Type: `passwd yourname` (replace with your username)
6. Type the new password twice
7. Type: `reboot`

---

# 19. Common mistakes I see every year

These are the mistakes I see students make most often. Learn from their experience.

## Mistake 1: Using NAT instead of Bridge network

**Symptom:** You can access the internet from the VM, but cannot SSH into it from your host

**The fix:** Change Adapter 1 from "NAT" to "Bridged Adapter" in VM settings. Then restart the VM.

## Mistake 2: Wrong network interface selected for Bridge

**Symptom:** VM gets no IP address or gets a strange IP like 169.254.x.x

**The fix:** In VM settings → Network → Bridged Adapter → Name, select the interface your host actually uses. If on Wi-Fi, select the Wi-Fi adapter. If on cable, select Ethernet.

## Mistake 3: Forgetting to tick "Install OpenSSH server" during installation

**Symptom:** Cannot connect via SSH

**The fix:** Install it manually:
```bash
sudo apt install openssh-server
sudo systemctl enable ssh
sudo systemctl start ssh
```

## Mistake 4: Wrong hostname format

**Symptom:** Verification fails or instructor cannot identify your submissions

**Wrong formats:**
- ❌ `ion popescu 1001 A` (spaces not allowed)
- ❌ `IonPopescu_1001_A` (full name, not initials)

**Correct format:**
- ✅ `IP_1001_A`

## Mistake 5: VM not running when trying to SSH

**Symptom:** "Connection refused" or "Connection timed out"

**The fix:** Make sure the VM is actually running in VirtualBox. The window should be open, or it should appear in the list as "Running".

---

# 20. How to use AI assistants

## Recommended assistants

- **Claude**: https://claude.ai
- **ChatGPT**: https://chat.openai.com

## Usage rules

✅ **Allowed:**
- Explanations for concepts
- Help with debugging
- Code examples for learning
- Syntax checking

❌ **Not allowed:**
- Copying solutions for homework
- Generating complete projects
- Use during exams

## Examples of good questions (VirtualBox specific)

```
"My Ubuntu VM does not receive IP with Bridge Adapter. How do I diagnose the problem?"

"What is the difference between NAT and Bridge networking in VirtualBox? When do I use each?"

"How can I enlarge the VM disk after I created it with 25GB? Is it possible without reinstallation?"

"VBoxManage gives me an error when I try to start headless. What checks do I perform?"

"How can I make a snapshot before installing something risky on the VM?"

"Why is my VM very slow? I have 16GB RAM but I only gave it 2GB."
```

---

# QUICK COMMANDS

## VM Management (from VirtualBox or terminal)

| What you want | How to do it |
|---------------|--------------|
| Start VM headless | `VBoxManage startvm "Ubuntu-Server-2404-SO" --type headless` |
| Stop VM | `VBoxManage controlvm "Ubuntu-Server-2404-SO" poweroff` |
| VM Status | `VBoxManage showvminfo "Ubuntu-Server-2404-SO" \| grep State` |

## In Ubuntu

| What you want | Command |
|---------------|---------|
| Update system | `sudo apt update && sudo apt -y upgrade` |
| Start SSH | `sudo systemctl start ssh` |
| Check IP | `hostname -I` |
| Disk space | `df -h` |
| Memory | `free -h` |
| Save history | `history > file.txt` |
| Exit | `exit` |

---

# FINAL CHECKLIST

- [ ] VirtualBox installed and working
- [ ] Extension Pack installed
- [ ] VM created (4GB RAM, 2 CPU, 25GB disk)
- [ ] Bridge network configured and working
- [ ] Ubuntu Server 24.04 installed
- [ ] Username = surname (e.g.: popescu)
- [ ] Password = stud
- [ ] Hostname = INITIAL_GROUP_SERIES (e.g.: IP_1001_A)
- [ ] System updated
- [ ] Software packages installed
- [ ] SSH working
- [ ] PuTTY/Terminal configured and tested
- [ ] WinSCP/scp working
- [ ] Folders created
- [ ] Verification showed everything OK

---

# SELF-CHECK: Verify your competencies

Answer honestly to the following questions. If you cannot tick all of them, revisit the relevant section.

## Can you do the following WITHOUT looking at the guide?

- [ ] I ran the verification script successfully (all with [OK])
- [ ] I connected via SSH from PuTTY/Terminal without help
- [ ] I transferred a test file with WinSCP/scp (from host to VM)
- [ ] I know what to do if the VM does not receive IP (Bridge network)
- [ ] I can start/stop the VM headless from the command line

## Quick verification questions

1. **What do you do if VirtualBox gives error "VT-x not available"?**
   → Enable virtualisation from BIOS/UEFI (VT-x, AMD-V or SVM)

2. **How do you check the VM IP from Ubuntu?**
   → `hostname -I`

3. **What command stops the VM from terminal?**
   → `VBoxManage controlvm "Ubuntu-Server-2404-SO" poweroff`

4. **Why would you choose Bridge instead of NAT for network?**
   → Bridge gives its own IP from the network, accessible from outside; NAT isolates the VM

---

# WHAT'S NEXT?

✅ You completed **01_INIT_SETUP**

**Next steps:**
1. Download homework recording tools → see `02_INIT_HOMEWORKS/`
2. Browse the Bash reference → see `03_GUIDES/01_Bash_Scripting_Guide.md`
3. Attend SEM01 with your environment ready

**If something breaks later:**
- Check `03_GUIDES/03_Observability_and_Debugging_Guide.md`
- Or ask an AI assistant (Section 20)

---

**If you have all ticked:** You are ready for SEM01! 🎉

**If you are missing some:** Revisit the relevant section or ask at the seminar.

---

Document for:
Bucharest University of Economic Studies - CSIE
Operating Systems - Academic Year 2024-2025

**Version:** 2.1 | **Last updated:** January 2025

---

*For problems, consult the "Common problems" section or ask an AI assistant before contacting the lecturer.*
