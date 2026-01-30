# COMPLETE INSTALLATION GUIDE FOR BEGINNERS
## Ubuntu Server 24.04 LTS in VirtualBox (Virtual Machine)
### Bucharest University of Economic Studies - CSIE
### Operating Systems - Academic Year 2024-2025

---

# READ BEFORE YOU BEGIN

WHEN SHOULD YOU USE THIS GUIDE?

This guide is an alternative to WSL2. Use it if:
- You have Mac (macOS) or Linux instead of Windows
- You cannot install WSL2 on Windows (old version, restrictions)
- You prefer a complete virtual machine

WHAT WILL YOU HAVE AT THE END?

A complete Ubuntu Linux server running in a window on your computer.

HOW LONG DOES IT TAKE?

Approximately 60-90 minutes.

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

*Personal note: Many prefer `zsh`, but I stick with Bash because it is the standard on servers. Consistency beats comfort.*

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

PART 1: PREPARATION
1. [Check system requirements](#1-check-system-requirements)
2. [Download everything you need](#2-download-everything-you-need)

PART 2: VIRTUALBOX INSTALLATION
3. [Installation on Windows](#3-virtualbox-installation-on-windows)
4. [Installation on macOS](#4-virtualbox-installation-on-macos)
5. [Installation on Linux](#5-virtualbox-installation-on-linux)
6. [Extension Pack Installation (everyone)](#6-extension-pack-installation)

PART 3: VIRTUAL MACHINE CREATION
7. [Create the virtual machine](#7-create-the-virtual-machine)
8. [Configure Bridge network](#8-configure-bridge-network)

PART 4: UBUNTU INSTALLATION
9. [Install Ubuntu Server](#9-install-ubuntu-server)
10. [Post-installation configuration](#10-post-installation-configuration)
11. [Install required software](#11-install-required-software)

PART 5: REMOTE ACCESS
12. [Configure SSH](#12-configure-ssh)
13. [Connect with PuTTY (Windows)](#13-connect-with-putty-windows)
14. [Connect with WinSCP (Windows)](#14-connect-with-winscp-windows)
15. [Connect from macOS or Linux](#15-connect-from-macos-or-linux)

PART 6: FINALISATION
16. [Create working folders](#16-create-working-folders)
17. [Verify the installation](#17-verify-the-installation)
18. [Common problems and solutions](#18-common-problems-and-solutions)
19. [How to use AI assistants](#19-how-to-use-ai-assistants)

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

Step 1: Press `Ctrl + Shift + Esc` to open Task Manager

Step 2: Click on the Performance tab

Step 3: Click on CPU on the left

Step 4: Look in the bottom right for: "Virtualization: Enabled"

If it says "Disabled", you need to enable virtualisation in BIOS (see the Common problems section).

### On macOS

Step 1: Open Terminal (Finder → Applications → Utilities → Terminal)

*(`find` combined with `-exec` is extremely useful. Once you master it, you cannot do without it.)*


Step 2: Type this command and press Enter:

```bash
sysctl -a | grep machdep.cpu.features | grep VMX
```

If text containing "VMX" appears, virtualisation is enabled. Modern Macs have virtualisation enabled by default.

Step 3: Check the processor type:

```bash
uname -m
```

- If `x86_64` appears = you have a Mac with Intel processor
- If `arm64` appears = you have a Mac with Apple Silicon processor (M1/M2/M3/M4)

**WARNING for Mac with Apple Silicon:** VirtualBox works but with limited performance. A better alternative is UTM (https://mac.getutm.app/).

### On Linux

Step 1: Open the terminal

Step 2: Run:

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

Step 1: Open the browser and go to: https://www.virtualbox.org/wiki/Downloads

Step 2: Download the version for your system:

| Your system | What to download |
|-------------|------------------|
| Windows | Click on "Windows hosts" |
| macOS with Intel | Click on "macOS / Intel hosts" |
| macOS with Apple Silicon | Click on "macOS / Arm64 hosts" |
| Linux | Click on "Linux distributions" and choose your distribution |

Step 3: Save the file in the folder created earlier

## Download Extension Pack

Step 1: On the same page, at the "VirtualBox Extension Pack" section

Step 2: Click on "All supported platforms"

Step 3: Save the file (named something like `Oracle_VM_VirtualBox_Extension_Pack-7.x.x.vbox-extpack`)

Note: The Extension Pack version MUST be the same as the VirtualBox version!

## Download Ubuntu Server

Step 1: Go to: https://ubuntu.com/download/server

Step 2: Click on "Download Ubuntu Server 24.04 LTS"

Step 3: Save the ISO file (approximately 2.5 GB, may take 10-30 minutes)

## What you should have now

In your folder you should have 3 files:
1. The VirtualBox installer (`.exe` for Windows, `.dmg` for Mac)
2. Extension Pack (`.vbox-extpack`)
3. Ubuntu Server ISO (`ubuntu-24.04-live-server-amd64.iso`)

---

# PART 2: VIRTUALBOX INSTALLATION

---

# 3. VirtualBox Installation on Windows

Skip this step if you have macOS or Linux!

## Run the installer

Step 1: Go to the folder `C:\VirtualBox_Kits`

Step 2: Double-click on the VirtualBox file (e.g.: `VirtualBox-7.x.x-xxxxx-Win.exe`)

Step 3: If "User Account Control" appears asking "Do you want to allow this app to make changes?", click Yes

## Go through the installation wizard

Screen 1 - Welcome:
- Click Next

Screen 2 - Custom Setup:
- Leave everything ticked (all components)
- Click Next

**Screen 3 - Warning: Network Interfaces:**
- A message appears that the network will be temporarily disconnected
- Click Yes

Screen 4 - Missing Dependencies (if it appears):
- Click Yes to install missing dependencies

Screen 5 - Ready to Install:
- Click Install

Screen 6 - Driver installation:
- Windows may ask 2-3 times if you want to install drivers from Oracle
- Click Install each time

Screen 7 - Finish:
- Leave "Start Oracle VM VirtualBox after installation" ticked
- Click Finish

## Verify the installation

VirtualBox should open automatically. If not, search for "VirtualBox" in Start and open it.

---

# 4. VirtualBox Installation on macOS

Skip this step if you have Windows or Linux!

## Preparation - Allow applications from Oracle

macOS blocks applications from "unknown" developers by default. You need to allow Oracle:

Step 1: Open System Preferences (or System Settings on macOS Ventura and newer)

Step 2: Click on Security & Privacy (or Privacy & Security)

Step 3: Remember this window - you will return here

## Install VirtualBox

Step 1: Go to the folder `~/VirtualBox_Kits` (in Finder)

Step 2: Double-click on the `.dmg` file (e.g.: `VirtualBox-7.x.x-xxxxx-macOSIntel.dmg`)

Step 3: A window opens with a `.pkg` package. Double-click on it.

Step 4: In the installation wizard:
- Click Continue at each step
- Click Install
- Enter your Mac password
- Click Install Software

Step 5: If the message "System Extension Blocked" appears:
- Open System Preferences → Security & Privacy
- At the bottom you see a message about "Oracle America, Inc."
- Click on the lock in the bottom left and enter the password
- Click Allow

Step 6: RESTART the Mac! (mandatory)

## After restart

Step 1: Open VirtualBox from Applications

Step 2: If it asks for additional permissions, go to System Preferences → Security & Privacy and allow them

---

# 5. VirtualBox Installation on Linux

Skip this step if you have Windows or macOS!

## On Ubuntu or Linux Mint or Debian

Open the terminal and run these commands one by one:

Command 1 - Download the signing key:

```bash
wget -O- https://www.virtualbox.org/download/oracle_vbox_2016.asc | sudo gpg --dearmor --yes --output /usr/share/keyrings/oracle-virtualbox-2016.gpg
```

When it asks for a password, type your account password and press Enter.

Command 2 - Add the VirtualBox repository:

```bash
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/oracle-virtualbox-2016.gpg] https://download.virtualbox.org/virtualbox/debian $(lsb_release -cs) contrib" | sudo tee /etc/apt/sources.list.d/virtualbox.list
```

Command 3 - Update the package list:

```bash
sudo apt update
```

Command 4 - Install VirtualBox:

```bash
sudo apt install -y virtualbox-7.0
```

Command 5 - Add your user to the vboxusers group:

```bash
sudo usermod -aG vboxusers $USER
```

Note: You need to log out and log back in (or restart) for the group to take effect!

## On Fedora

```bash
sudo dnf install -y VirtualBox
```

```bash
sudo usermod -aG vboxusers $USER
```

Log out and log back in.

## On Arch Linux or Manjaro

```bash
sudo pacman -S virtualbox virtualbox-host-modules-arch
```

```bash
sudo modprobe vboxdrv vboxnetadp vboxnetflt
```

```bash
sudo usermod -aG vboxusers $USER
```

Log out and log back in.

## Verify the installation

After logging back in, open VirtualBox from the applications menu.

---

# 6. Extension Pack Installation

This step is for everyone: Windows, macOS and Linux!

Extension Pack adds important functionality (USB 3.0, remote access, etc.).

## Installation from VirtualBox

Step 1: Open VirtualBox

Step 2: From the menu, click on File → Tools → Extension Pack Manager

(On older versions: File → Preferences → Extensions)

Step 3: Click on the "+" icon (Install) or "Install"

Step 4: Navigate to the downloads folder and select the Extension Pack file (`Oracle_VM_VirtualBox_Extension_Pack-7.x.x.vbox-extpack`)

Step 5: The licence appears. Scroll to the bottom and click I Agree

Step 6: If it asks for a password (on Mac/Linux), enter it

Step 7: You should see the Extension Pack in the list

---

# PART 3: VIRTUAL MACHINE CREATION

---

# 7. Create the virtual machine

## Start the wizard

Step 1: In VirtualBox, click on the New button (or from menu: Machine → New)

## Configure - Step 1: Name and operating system

Name: `Ubuntu-Server-2404-SO`

Folder: leave default or choose a folder with space

ISO Image: Click on the dropdown arrow and select Other...
- Navigate to the downloads folder
- Select the file `ubuntu-24.04-live-server-amd64.iso`

Type: `Linux`

Version: `Ubuntu (64-bit)`

Note: Tick "Skip Unattended Installation" - we want to install manually!

Click Next

## Configure - Step 2: Hardware

Base Memory: Drag the slider or type `4096` MB (i.e. 4 GB)
- If you only have 8 GB RAM total, you can set 2048 MB (2 GB)

Processors: `2`
- If you have a weak processor, leave 1

Tick "Enable EFI" (optional but recommended)

Click Next

## Configure - Step 3: Hard Disk

Select "Create a Virtual Hard Disk Now"

Disk Size: `25 GB` (minimum) or `50 GB` (if you have space)

DO NOT tick "Pre-allocate Full Size" - leave it unticked

Click Next

## Configure - Step 4: Summary

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

## Configuration

Step 1: In VirtualBox, select the machine `Ubuntu-Server-2404-SO` (click on it)

Step 2: Click on Settings (or right-click → Settings)

Step 3: In the menu on the left, click on Network

Step 4: In the Adapter 1 tab:


Specifically: Enable Network Adapter: must be ticked ✓. Attached to: select "Bridged Adapter" from the dropdown. And Name: select your computer's network interface:.


### How do you know which interface to select?

On Windows:
- If you are connected via cable: choose something with "Ethernet" in the name
- If you are on Wi-Fi: choose something with "Wi-Fi" or "Wireless" in the name

On macOS:
- Wi-Fi on MacBook: usually `en0`
- Ethernet (if you have it): usually `en1`

On Linux:
- Ethernet: `eth0`, `enp3s0`, or similar
- Wi-Fi: `wlan0`, `wlp2s0`, or similar

If you are not sure, try the first option. You can change it later.

Step 5: Click OK to save

---

# PART 4: UBUNTU INSTALLATION

---

# 9. Install Ubuntu Server

## Start the virtual machine

Step 1: Select `Ubuntu-Server-2404-SO` in VirtualBox

Step 2: Click on Start (the green button with arrow)

A new window opens and boot from ISO begins.

## Boot screen

When the menu appears, select:

Try or Install Ubuntu Server

Press Enter

Wait 1-2 minutes for the installer to load.

## Installation - Step 1: Language

Use the up/down arrows to select. Select:

English

Press Enter

## Installation - Step 2: Keyboard

Layout: English (US) or Romanian
Variant: English (US) or Romanian (Standard)

Recommendation: Leave English (US) for compatibility.

Navigate with Tab to [ Done ] and press Enter

## Installation - Step 3: Installation type

Select:

(X) Ubuntu Server

Navigate to [ Done ] and press Enter

## Installation - Step 4: Network

You should see something like:

```
enp0s3  eth  DHCPv4  192.168.1.xxx/24
```

This means it received an IP automatically. Good!

If you see `---` instead of IP, the network is not working. Check the Bridge settings at step 8.

Navigate to [ Done ] and press Enter

## Installation - Step 5: Proxy

Leave empty (do not type anything).

Navigate to [ Done ] and press Enter

## Installation - Step 6: Mirror

Leave default (or change to a mirror from Romania if you want, but it is not necessary).

Navigate to [ Done ] and press Enter

## Installation - Step 7: Disk

Select:

(X) Use an entire disk

UNTICK (should not have X): "Set up this disk as an LVM group"

Navigate to [ Done ] and press Enter

## Installation - Step 8: Disk confirmation

You see a summary of partitions. Verify that everything looks OK.

Navigate to [ Done ] and press Enter

## Installation - Step 9: Destructive confirmation

A warning message appears that data will be erased.

Navigate to [ Continue ] and press Enter

## Installation - Step 10: User profile

Here you fill in your information. Use Tab to navigate between fields.

Your name: Your first name and surname (e.g.: `Ion Popescu`)

Your server's name: Hostname in format INITIAL_GROUP_SERIES

Examples:
- Ana Popescu, group 1001, series A → `AP_1001_A`
- Ion Marin Ionescu, group 2034, series B → `IMI_2034_B`

Pick a username: Your surname, lowercase, without diacritics

Examples:

Three things matter here: popescu → `popescu`, ștefănescu → `stefanescu` and bălan → `balan`.


Choose a password: `stud`

Confirm your password: `stud`

Navigate to [ Done ] and press Enter

## Installation - Step 11: Ubuntu Pro

Select:

( ) Skip for now

Navigate to [ Continue ] and press Enter

## Installation - Step 12: SSH Server

**VERY IMPORTANT!**

Tick:

[X] Install OpenSSH server

This allows you to connect remotely.

At "Import SSH identity" select ( ) No

Navigate to [ Done ] and press Enter

## Installation - Step 13: Featured Snaps

DO NOT select anything! Leave everything unticked.

Navigate to [ Done ] and press Enter

## The actual installation

Now the system is installing. You will see a progress bar.

Duration: 5-15 minutes

When it finishes, you see the message "Install complete!"

## Finalisation and reboot

Navigate to [ Reboot Now ] and press Enter

If you see a message "Please remove the installation medium", just press Enter.

## Remove the ISO (if necessary)

If after reboot the system tries to boot from ISO again:

Step 1: Close the VM window

Step 2: If it asks, select "Power off the machine" and click OK

Step 3: In VirtualBox, select the machine → Settings → Storage

Step 4: Under "Controller: IDE" or "Controller: SATA", click on the ISO file

Step 5: On the right, at "Optical Drive", click on the disc icon and select "Remove Disk from Virtual Drive"

Step 6: Click OK

Step 7: Start the virtual machine again

## First login

When you see:

```
Ubuntu 24.04 LTS AP_1001_A tty1

AP_1001_A login:
```

Type: your username (e.g.: `popescu`) and press Enter

Password: type `stud` and press Enter

Note: When you type the password, you do not see anything on screen - this is normal!

🎉 Congratulations! You have installed Ubuntu Server!

---

# 10. Post-installation configuration

## Update the system

First command to run after installation:

```bash
sudo apt update && sudo apt -y upgrade
```

When it asks for password, type `stud` and press Enter.

Wait for it to finish (2-10 minutes).

## Check the hostname

```bash
hostname
```

You should see your hostname (e.g.: `AP_1001_A`).

## Configure the timezone

```bash
sudo timedatectl set-timezone Europe/Bucharest
```

Verify:

```bash
date
```

You should see the date and time from Romania.

## Find out the IP address

```bash
hostname -I
```

NOTE DOWN this IP address! (e.g.: `192.168.1.105`)

You will use it to connect with PuTTY or SSH.

---

# 11. Install required software

## Install all required packages

Copy and run this command (it is long, but copy it all):

```bash
sudo apt update && sudo apt install -y build-essential git curl wget nano vim tree htop net-tools man-db manpages-posix software-properties-common gawk sed grep coreutils findutils diffutils moreutils procps sysstat iotop nmon lsof strace dstat tar gzip bzip2 xz-utils zstd zip unzip p7zip-full iproute2 iputils-ping dnsutils netcat-openbsd traceroute nmap tcpdump iftop nethogs gcc g++ make cmake gdb valgrind python3 python3-pip python3-venv shellcheck jq bc expect figlet toilet cowsay tree ncdu pv dialog tmux screen
```

Wait for it to finish (5-15 minutes).

## Install Python libraries

```bash
pip3 install --break-system-packages rich tabulate psutil
```

---

# PART 5: REMOTE ACCESS

---

# 12. Configure SSH

## Check that SSH is running

```bash
sudo systemctl status ssh
```

You should see "Active: active (running)".

Press `q` to exit this screen.

## If SSH is not running

```bash
sudo systemctl start ssh
```

```bash
sudo systemctl enable ssh
```

## Note down the IP address

```bash
hostname -I
```

Write down this address somewhere (e.g.: `192.168.1.105`).

---

# 13. Connect with PuTTY (Windows)

Skip this step if you have macOS or Linux!

## Download and install PuTTY

Step 1: Go to: https://www.chiark.greenend.org.uk/~sgtatham/putty/latest.html

Step 2: At "MSI (Windows Installer)", download 64-bit x86

Step 3: Run the downloaded file and install (Next, Next, Install, Finish)

## Open PuTTY

From Start, search for "PuTTY" and open it.

## Configure the connection

In the "PuTTY Configuration" window:

Host Name (or IP address): type the IP address of the VM (e.g.: `192.168.1.105`)

Port: `22`

Connection type: `SSH` (should already be selected)

## Configure colours (black background, white text)

Step 1: In the menu on the left, click on Window → Colours

Step 2: In the list "Select a colour to adjust":
- Select "Default Background"
- Click Modify...
- Set Red: `0`, Green: `0`, Blue: `0`
- Click OK

Step 3: Select "Default Foreground"
- Click Modify...
- Set Red: `255`, Green: `255`, Blue: `255`
- Click OK

## Configure the font

Step 1: In the menu on the left, click on Window → Appearance

Step 2: At "Font settings", click Change...

Step 3: Select:
- Font: `Consolas`
- Size: `12`
- Click OK

## Configure auto-login

Step 1: In the menu on the left, click on Connection → Data

Step 2: At "Auto-login username", type your username (e.g.: `popescu`)

## Save the session

Step 1: In the menu on the left, click on Session (first one)

Step 2: At "Saved Sessions", type: `Ubuntu-VM-SO`

Step 3: Click Save

## Connect

Step 1: Make sure the Ubuntu VM is running in VirtualBox

Step 2: In PuTTY, select the session `Ubuntu-VM-SO`

Step 3: Click Open

Step 4: At first connection, a security warning appears. Click Accept or Yes.

Step 5: If it asks for password, type `stud` and press Enter

Now you have a PuTTY window connected to Ubuntu!

---

# 14. Connect with WinSCP (Windows)

Skip this step if you have macOS or Linux!

## Download and install WinSCP

Step 1: Go to: https://winscp.net/eng/download.php

Step 2: Click on the green button "Download WinSCP"

Step 3: Install (Typical installation, Next, Next, Install, Finish)

## Configure WinSCP

Step 1: Open WinSCP

Step 2: In the "Login" window:
- File protocol: `SFTP`
- Host name: the IP address of the VM (e.g.: `192.168.1.105`)
- Port number: `22`
- User name: your name (e.g.: `popescu`)
- Password: `stud`

Step 3: Click Save
- Site name: `Ubuntu-VM-SO-Files`
- Tick "Save password" if you want
- Click OK
- Document what you did for future reference

## Connect

Step 1: Select the saved site

Step 2: Click Login

Step 3: At first connection, click Yes at the security warning

Now you see two panels:
- Left: Files from Windows
- Right: Files from Ubuntu

To transfer files, drag with the mouse from one side to the other.

---

# 15. Connect from macOS or Linux

Skip this step if you have Windows!

## SSH connection from Terminal

Step 1: Open Terminal:
- macOS: Finder → Applications → Utilities → Terminal
- Linux: Search for "Terminal" in applications

Step 2: Type the command (replace with your IP address and username):

```bash
ssh popescu@192.168.1.105
```

Step 3: At first connection, it asks if you want to continue. Type `yes` and press Enter.

Step 4: Type the password `stud` and press Enter

## Save configuration (optional)

So you do not have to type the IP address every time:

Step 1: Open or create the configuration file:

```bash
nano ~/.ssh/config
```

Step 2: Add (replace with your data):

```
Host ubuntu-vm
    HostName 192.168.1.105
    User popescu
    Port 22
```

Step 3: Save: press `Ctrl+O`, then `Enter`, then `Ctrl+X`

Step 4: Now you can connect simply with:

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
- `put file.txt` - send file
- `get file.txt` - receive file
- `ls` - list files
- `exit` - exit

### Graphical applications

- macOS: Cyberduck (free) - https://cyberduck.io/
- Linux: FileZilla - `sudo apt install filezilla`

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

Run this command to verify that everything is OK:

```bash
echo "" && echo "========================================" && echo "   INSTALLATION VERIFICATION - OS ASE" && echo "   Ubuntu Server in VirtualBox" && echo "========================================" && echo "" && echo ">>> System information:" && echo "Hostname: $(hostname)" && echo "User: $(whoami)" && echo "Ubuntu: $(lsb_release -d 2>/dev/null | cut -f2)" && echo "Kernel: $(uname -r)" && echo "" && echo ">>> Network:" && echo "IP: $(hostname -I | awk '{print $1}')" && ping -c 1 google.com > /dev/null 2>&1 && echo "Internet: OK" || echo "Internet: NO CONNECTION" && echo "" && echo ">>> Essential commands:" && for cmd in bash git nano vim gcc python3 ssh tree htop awk sed grep find tar gzip nmap; do command -v $cmd > /dev/null 2>&1 && echo "  [OK] $cmd" || echo "  [MISSING] $cmd"; done && echo "" && echo ">>> SSH:" && systemctl is-active ssh > /dev/null 2>&1 && echo "  SSH server: ACTIVE" || echo "  SSH server: INACTIVE" && echo "" && echo ">>> Folders:" && for dir in Books HomeworksOLD Projects ScriptsSTUD test TXT; do [ -d ~/$dir ] && echo "  [OK] ~/$dir" || echo "  [MISSING] ~/$dir"; done && echo "" && echo "========================================" && echo "   VERIFICATION COMPLETE!" && echo "   Connect with: ssh $(whoami)@$(hostname -I | awk '{print $1}')" && echo "========================================"
```

---

# 18. Common problems and solutions

## VirtualBox does not start - virtualisation error

Message: "VT-x is not available" or "AMD-V is disabled"

Solution: You need to enable virtualisation in BIOS:
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
- Document what you did for future reference

## I forgot the password

Stop the VM. In VirtualBox, start the VM in recovery mode:

1. At boot, hold Shift for the GRUB menu
2. Select "Advanced options for Ubuntu"
3. Select an entry with "(recovery mode)"
4. Select "root - Drop to root shell"
5. Type: `passwd yourname` (replace with your username)
6. Type the new password twice
7. Type: `reboot`

---

# 19. How to use AI assistants

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
- [ ] Hostname = INITIAL_GROUP_SERIES (e.g.: AP_1001_A)
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

- [ ] ✅ I ran the verification script successfully (all with [OK])
- [ ] ✅ I connected via SSH from PuTTY/Terminal without help
- [ ] ✅ I transferred a test file with WinSCP/scp (from host to VM)
- [ ] ✅ I know what to do if the VM does not receive IP (Bridge network)
- [ ] ✅ I can start/stop the VM headless from the command line

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

**If you have all ticked:** You are ready for SEM01! 🎉

**If you are missing some:** Revisit the relevant section or ask at the seminar.

---

Document for:
Bucharest University of Economic Studies - CSIE
Operating Systems - 2024-2025

Version: 2.1 - Guide for beginners (with Learning Outcomes)
Last updated: January 2025

---

*For problems, consult the "Common problems" section or ask an AI assistant.*
