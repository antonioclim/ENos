# COMPLETE INSTALLATION GUIDE FOR BEGINNERS
## Ubuntu 24.04 LTS on WSL2 (Windows Subsystem for Linux)

*(WSL2 has completely changed the way I teach — now students can practise Linux without dual boot.)*

### Bucharest University of Economic Studies - CSIE
### Operating Systems - Academic Year 2024-2025

> Lab observation: in practice, most WSL2 problems come from two places: (1) virtualisation features disabled in BIOS/UEFI or in Windows, and (2) a "skipped" reboot after installation. Quickly check with `wsl --status` and `wsl --list --verbose` before reinventing the wheel.
---

# READ BEFORE YOU BEGIN

WHAT IS THIS GUIDE?

This guide will teach you step by step how to install Linux on your Windows computer. You do not need prior knowledge - everything is explained from scratch.

WHAT WILL YOU HAVE AT THE END?

A Linux system (Ubuntu) that runs directly in Windows, which you will use at seminars to learn commands and scripting.

HOW LONG DOES IT TAKE?

Approximately 30-60 minutes, depending on internet speed.

WHAT DO YOU NEED?

- Computer with Windows 10 or Windows 11
- Internet connection
- Minimum 10 GB free disk space
- Consult `man` or `--help` if you have doubts

---

# LEARNING OUTCOMES (What you will be able to do after this guide)

At the end of this guide, you will be able to:

- [ ] **LO1:** Check if your Windows system supports WSL2 (virtualisation active, compatible Windows version)
- [ ] **LO2:** Enable and configure WSL2 from PowerShell as Administrator
- [ ] **LO3:** Install and configure Ubuntu 24.04 LTS with correct user (surname) and hostname in format `INITIAL_GROUP_SERIES`
- [ ] **LO4:** Start/stop the SSH service and connect remotely with PuTTY
- [ ] **LO5:** Transfer files between Windows and Ubuntu using WinSCP or drag & drop
- [ ] **LO6:** Diagnose and solve the 3 most common problems: disabled virtualisation, SSH not starting, forgotten password

---

# TABLE OF CONTENTS

1. [Check if you can install WSL2](#1-check-if-you-can-install-wsl2)
2. [Enable required features in Windows](#2-enable-required-features-in-windows)
3. [Install Ubuntu](#3-install-ubuntu)
4. [Configure your Linux account](#4-configure-your-linux-account)
5. [Update the system](#5-update-the-system)
6. [Configure the computer name](#6-configure-the-computer-name)
7. [Install required software](#7-install-required-software)
8. [Configure SSH access](#8-configure-ssh-access)
9. [Install and configure PuTTY](#9-install-and-configure-putty)
10. [Install and configure WinSCP](#10-install-and-configure-winscp)
11. [Create working folders](#11-create-working-folders)
12. [Verify the installation](#12-verify-the-installation)
13. [Common problems and solutions](#13-common-problems-and-solutions)
14. [How to use AI assistants](#14-how-to-use-ai-assistants)

---

# HOW TO READ THIS GUIDE

## Types of commands

In this guide you will see two types of commands:

### PowerShell Commands (Windows)

These run in Windows and have a blue background:

```powershell
# POWERSHELL (Windows) - Blue background
# This is a PowerShell command
wsl --version
```

### Bash Commands (Linux/Ubuntu)

These run in Ubuntu and have a black background:

```bash
# BASH (Ubuntu/Linux) - Black background
# This is a Linux command
ls -la
```

## How to copy and paste commands

1. Select the command with the mouse (the text in the grey box)
2. Copy with `Ctrl+C`
3. Paste in terminal:
   - In PowerShell: `Ctrl+V` or right-click
   - In Ubuntu/Bash: `Ctrl+Shift+V` or right-click

Note: Copy EXACTLY the displayed command, without modifying anything (except where it explicitly says to replace something).

---

# 1. Check if you can install WSL2

## What is WSL2?

> Personal recommendation: WSL2 is the solution I recommend to students. I have tested VirtualBox, dual-boot, Docker containers — WSL2 offers the best balance between simplicity and functionality. Plus you do not have to restart the computer 5 times per seminar, which is a big plus.

WSL2 (Windows Subsystem for Linux 2) is a Windows feature that allows you to run Linux directly in Windows, without installing a separate operating system.

## Check Windows version

Step 1: Press the keys `Windows + R` at the same time

Step 2: A small window called "Run" opens. Type in it:
```
winver
```

Step 3: Press `Enter` or click on `OK`

Step 4: A window with Windows information opens. Look for:
- Windows 10: You must have version 2004 or newer (Build 19041 or higher)
- Windows 11: Any version works

If you have an older version, you need to update Windows before going further.

## Check if virtualisation is enabled

Step 1: Press the keys `Ctrl + Shift + Esc` at the same time

Step 2: Task Manager opens. If you see a simple window, click on "More details" in the bottom left.

Step 3: Click on the "Performance" tab

Step 4: Click on "CPU" on the left

Step 5: Look in the bottom right for the text "Virtualization:"
- If it says "Enabled" - you are OK, continue to the next step
- If it says "Disabled" - you need to enable virtualisation in BIOS (see the Common problems section)

---

# 2. Enable required features in Windows

## Open PowerShell as Administrator

VERY IMPORTANT: You must open PowerShell as Administrator, otherwise the commands will not work!

Method 1 (Recommended):
1. Click on the `Start` button (bottom left corner)
2. Type: `powershell`
3. In the results "Windows PowerShell" appears
4. `RIGHT` click on it (not left click!)
5. Select "Run as administrator"
6. A window appears asking "Do you want to allow this app to make changes?" - click "Yes"

Method 2:
1. Press the keys `Windows + X` at the same time
2. From the menu that appears, select "Windows PowerShell (Admin)" or "Terminal (Admin)"
3. Click "Yes" at the question about permissions

How do you know you are Administrator?
- The window title must contain the word "Administrator"
- Example: "Administrator: Windows PowerShell"

## Enable WSL and Virtual Machine Platform

Now you will run a few commands. Copy each command and paste it in PowerShell, then press Enter.

Command 1 - Enable WSL:

```powershell
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
```

Wait for it to finish (may take 1-2 minutes). You will see the message "The operation completed successfully."

Command 2 - Enable Virtual Machine Platform:

```powershell
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
```

Wait for it to finish. Again you will see "The operation completed successfully."

## RESTART THE COMPUTER

MANDATORY: You must restart the computer now!

1. Save any open work
2. Click Start → Power → Restart
3. Wait for it to restart completely

---

# 3. Install Ubuntu

## Open PowerShell as Administrator again

After restart, open PowerShell as Administrator again (see the instructions from the previous step).

## Install the WSL2 kernel update

Command 1 - Download the update:

```powershell
Invoke-WebRequest -Uri https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi -OutFile wsl_update_x64.msi -UseBasicParsing
```

Wait for it to download (may take 1-2 minutes depending on internet).

Command 2 - Install the update:

```powershell
msiexec /i wsl_update_x64.msi /quiet
```

Wait a few seconds.

Command 3 - Set WSL2 as default version:

*Personal note: WSL2 has completely changed the way I teach — now students can practise Linux without dual boot.*


```powershell
wsl --set-default-version 2
```

Command 4 - Update WSL to the latest version:

```powershell
wsl --update
```

## Install Ubuntu 24.04 LTS

Command 5 - Install Ubuntu:

```powershell
wsl --install -d Ubuntu-24.04
```

What happens now:

Main aspects: Windows downloads Ubuntu (approximately 2 GB), may take 5-15 minutes depending on internet speed and at the end, a new window with Ubuntu will open automatically.


---

# 4. Configure your Linux account

## The Ubuntu window

After installation, a black window (Ubuntu terminal) opens automatically. If it did not open, search for "Ubuntu" in Start and open it.

## Create your user

Ubuntu will ask you to create an account. You will see the message:

```
Enter new UNIX username:
```

WHAT TO TYPE: Your surname, lowercase, without diacritics.

Examples:
- If your name is `Popescu Ion` → type: `popescu`
- If your name is `Ionescu Maria` → type: `ionescu`
- If your name is Ștefănescu Dan → type: `stefanescu`
- If your name is Bălan Ana → type: `balan`

Type the name and press Enter.

## Create the password

You will see:
```
New password:
```

WHAT TO TYPE: `stud`

VERY IMPORTANT: When you type the password, YOU WILL NOT SEE ANYTHING ON SCREEN - no stars, no dots, nothing! This is normal for Linux. Type the password and press Enter.

You will see:
```
Retype new password:
```

Type `stud` again and press Enter.

## Done!

If everything went well, you will see a welcome message and a prompt that looks like this:

```
popescu@DESKTOP-XXXXX:~$
```

(Instead of "popescu" will be your surname, and instead of "DESKTOP-XXXXX" will be your computer name)

Congratulations! You have installed Ubuntu! Now you are in Linux and can run commands.

---

# 5. Update the system

## What does this mean?

Just like Windows has Windows Update, Linux has its own update system. You need to update the system to have the latest versions of programs and security patches.

## Run the update

In the Ubuntu window (the black one), copy and paste the following command, then press Enter:

```bash
sudo apt update && sudo apt -y upgrade
```

What happens:
- `sudo` = run the command with administrator rights
- The system will ask for your password (`stud`)
- Again, you will not see the password when you type it - type it and press Enter
- `apt update` = checks what updates are available
- `apt upgrade` = installs the updates
- `-y` = automatically answers "yes" to questions

How long it takes: 2-10 minutes, depending on how many updates there are.

You will see a lot of text on screen - this is normal. Wait until the prompt reappears (the line ending with `$`).

---

# 6. Configure the computer name

## Why is it important?

In the course, each student must have a unique "hostname" (computer name) that identifies you. The format is:

Format: `INITIAL_GROUP_SERIES`

Examples:
- Ana Popescu, group 1001, series A → `AP_1001_A`
- Ion Marin Ionescu, group 2034, series B → `IMI_2034_B`
- Maria Stan, group 1502, series C → `MS_1502_C`

## Find your details

Before going further, note down:
- Your initials: First letter of first name + first letter of surname (or more if you have a compound first name)
- Your group: The group number (e.g.: 1001, 2034)
- Your series: A, B, C, etc.
- Use `man` or `--help` when you have doubts

## Create the configuration file

The following command will create the configuration file. REPLACE `INITIAL_GROUP_SERIES` with your hostname (e.g.: `AP_1001_A`).

Note: In the command below, replace the text `INITIAL_GROUP_SERIES` with YOUR hostname!

```bash
sudo tee /etc/wsl.conf << 'EOF'
[network]
hostname = INITIAL_GROUP_SERIES
generateHosts = false

[boot]
systemd = true
EOF
```

Concrete example for Ana Popescu, group 1001, series A:

```bash
sudo tee /etc/wsl.conf << 'EOF'
[network]
hostname = AP_1001_A
generateHosts = false

[boot]
systemd = true
EOF
```

If it asks for password, type `stud` and press Enter.

## Add the hostname to the hosts file

Again, REPLACE `INITIAL_GROUP_SERIES` with your hostname:

```bash
echo "127.0.0.1    INITIAL_GROUP_SERIES" | sudo tee -a /etc/hosts
```

Concrete example for Ana Popescu, group 1001, series A:

```bash
echo "127.0.0.1    AP_1001_A" | sudo tee -a /etc/hosts
```

## Apply the changes

For the changes to take effect, you need to restart Ubuntu.

Step 1: Close the Ubuntu window (type `exit` and press Enter, or close the window)

Step 2: Open PowerShell (does not need to be Administrator this time) and run:

```powershell
wsl --shutdown
```

Step 3: Open Ubuntu again from Start

## Check the hostname

In Ubuntu, run:

```bash
hostname
```

You should see your hostname (e.g.: `AP_1001_A`). If you see something else, repeat the steps above.

---

# 7. Install required software

## What are these programs?

For seminars and projects, you will need various Linux tools. This command installs all of them at once.

## Install everything you need

Copy and paste this command in Ubuntu:

```bash
sudo apt update && sudo apt install -y build-essential git curl wget nano vim tree htop net-tools openssh-server man-db manpages-posix gawk sed grep coreutils findutils diffutils procps sysstat lsof tar gzip bzip2 xz-utils zstd zip unzip p7zip-full iproute2 iputils-ping dnsutils netcat-openbsd traceroute nmap tcpdump gcc g++ make cmake gdb valgrind python3 python3-pip python3-venv shellcheck jq bc figlet cowsay ncdu pv dialog
```

What happens:
- The system downloads and installs all required programs
- May take 5-15 minutes
- You will see a lot of text on screen - this is normal
- Wait until the prompt `$` reappears

## Install required Python libraries

```bash
pip3 install --break-system-packages rich tabulate psutil
```

---

# 8. Configure SSH access

## What is SSH?

SSH (Secure Shell) is a protocol that allows you to connect to a Linux computer remotely. We will install the SSH server to be able to use PuTTY later.

## Start the SSH service

```bash
sudo service ssh start
```

## Check that it works

```bash
sudo service ssh status
```

You should see something like "Active: active (running)". Press the `q` key to exit this screen.

## Find out the IP address

To connect with PuTTY, you need the IP address of Ubuntu. Run:

```bash
hostname -I
```

You will see an address like `172.XX.XX.XX`. NOTE IT DOWN - you will use it in the next step.

---

# 9. Install and configure PuTTY

## What is PuTTY?

PuTTY is a Windows program that allows you to connect to Linux via SSH. It is like another type of window for working in Ubuntu.

## Download PuTTY

Step 1: Open the browser (Chrome, Firefox, Edge)

Step 2: Go to the address: https://www.chiark.greenend.org.uk/~sgtatham/putty/latest.html

Step 3: At the "MSI (Windows Installer)" section, download the 64-bit x86 version
- The file is named something like `putty-64bit-0.XX-installer.msi`

Step 4: Open the downloaded file and install PuTTY:
- Click Next — and related to this, click Next
- Click Install
- Click Yes if it asks about permissions
- Click Finish

## Open PuTTY

Step 1: Click on Start and type "PuTTY"

Step 2: Open the application "PuTTY"

## Configure the connection

The "PuTTY Configuration" window opens. On the left you see a menu with categories.

In the main screen (Session):
- Host Name (or IP address): type the IP address you noted earlier (e.g.: `172.24.123.45`)
- Port: `22` (should already be there)
- Connection type: select `SSH`

## Configure appearance - Colours (black background, white text)

Step 1: In the menu on the left, click on `Window` (to expand it), then click on `Colours`

Step 2: In the list "Select a colour to adjust", select "Default Background"

Step 3: Click the "Modify..." button

Step 4: In the colour window:
- Red: `0`
- Green: `0`
- Blue: `0`
- Click `OK`

Step 5: Now select "Default Foreground" from the list

Step 6: Click "Modify..."

Step 7: In the colour window:
- Red: `255`
- Green: `255`
- Blue: `255`
- Click `OK`

## Configure the font

Step 1: In the menu on the left, click on `Window`, then on `Appearance`

Step 2: At "Font settings", click on Change...

Step 3: Select:
- Font: `Consolas` or `Lucida Console`
- Style: `Regular`
- Size: `12`
- Click `OK`

## Configure automatic user

Step 1: In the menu on the left, click on `Connection`, then on `Data`

Step 2: At "Auto-login username" type your username (surname in lowercase, e.g.: `popescu`)

## Save the configuration

Step 1: In the menu on the left, click on `Session` (first in the list)

Step 2: At "Saved Sessions" type: `Ubuntu-WSL2`

Step 3: Click on the `Save` button

## Connect!

Step 1: Make sure Ubuntu is running (open the Ubuntu window if it is not open)

Step 2: In PuTTY, select the session `Ubuntu-WSL2` from the list

Step 3: Click on `Open`

Step 4: At first connection, a security message about "host key" appears. Click `Accept` or `Yes`.

Step 5: If it asks for password, type `stud` and press Enter

Done! Now you have a PuTTY window connected to your Ubuntu.

---

# 10. Install and configure WinSCP

## What is WinSCP?

WinSCP is a program that allows you to transfer files between Windows and Linux. It is like an Explorer for Linux files.

## Download WinSCP

Step 1: Go to: https://winscp.net/eng/download.php

Step 2: Click on the green button "Download WinSCP"

Step 3: Open the downloaded file and install:
- Select "Typical installation"
- Click Next, Next, Install
- Click Finish
- Save a backup copy for safety

## Configure the connection

Step 1: Open WinSCP from Start

Step 2: In the "Login" window that appears:
- File protocol: `SFTP` (should already be there)
- Host name: the IP address of Ubuntu (e.g.: `172.24.123.45`)
- Port number: `22`
- User name: your username (e.g.: `popescu`)
- Password: `stud`

Step 3: Click on `Save`

Step 4: Give the session a name: `Ubuntu-WSL2-Files`

Step 5: Tick "Save password" if you do not want to enter the password every time

Step 6: Click `OK`

## Connect and transfer files

Step 1: Make sure Ubuntu is running

Step 2: Select the saved session and click `Login`

Step 3: At first connection, click `Yes` at the security message

Step 4: Now you see two panels:
- Left: Your files from Windows
- Right: Files from Ubuntu

Step 5: To transfer files, simply drag (drag & drop) from left to right or vice versa

---

# 11. Create working folders

## Why do you need a folder structure?

At seminars you will create many files. It is important to organise them in a clear structure.

## Create the folders

In Ubuntu (either in the black window or through PuTTY), run:

```bash
mkdir -p ~/Books ~/HomeworksOLD ~/Projects ~/ScriptsSTUD ~/test ~/TXT
```

## What each folder does

| Folder | What you use it for |
|--------|---------------------|
| `Books` | Books, PDFs, study materials |
| `HomeworksOLD` | Old homework, for reference |
| `Projects` | Semester project and other projects |
| `ScriptsSTUD` | Scripts you make at seminars |
| `test` | Folder for tests and experiments |
| `TXT` | Various text files, notes |

## Check that they were created

```bash
ls -la ~
```

You should see all the folders listed.

---

# 12. Verify the installation

## Run the verification script

Copy and run this command that checks if everything is installed correctly:

```bash
echo "" && echo "========================================" && echo "   INSTALLATION VERIFICATION - OS ASE" && echo "========================================" && echo "" && echo ">>> System information:" && echo "Hostname: $(hostname)" && echo "User: $(whoami)" && echo "Ubuntu: $(lsb_release -d 2>/dev/null | cut -f2)" && echo "Kernel: $(uname -r)" && echo "" && echo ">>> Network:" && echo "IP: $(hostname -I | awk '{print $1}')" && ping -c 1 google.com > /dev/null 2>&1 && echo "Internet: OK" || echo "Internet: NO CONNECTION" && echo "" && echo ">>> Essential commands:" && for cmd in bash git nano vim gcc python3 ssh tree htop awk sed grep find tar gzip; do command -v $cmd > /dev/null 2>&1 && echo "  [OK] $cmd" || echo "  [MISSING] $cmd"; done && echo "" && echo ">>> SSH:" && sudo service ssh status 2>/dev/null | grep -q "running" && echo "  SSH server: ACTIVE" || echo "  SSH server: INACTIVE" && echo "" && echo ">>> Folders:" && for dir in Books HomeworksOLD Projects ScriptsSTUD test TXT; do [ -d ~/$dir ] && echo "  [OK] ~/$dir" || echo "  [MISSING] ~/$dir"; done && echo "" && echo "========================================" && echo "   VERIFICATION COMPLETE!" && echo "========================================"
```

## What you should see

If everything is OK, you should see:
- Your hostname (e.g.: `AP_1001_A`)
- Your username (e.g.: `popescu`)
- Ubuntu 24.04
- The IP
- Internet: OK
- All commands with [OK]
- SSH server: ACTIVE
- All folders with [OK]

If you see something with [MISSING] or NO CONNECTION, check the previous steps.

---

# 13. Common problems and solutions

## Problem: "WSL 2 requires an update to its kernel component"

Solution: Open PowerShell as Administrator and run:

```powershell
wsl --update
```

Then restart the computer.

## Problem: Virtualisation is not enabled

Solution:

1. Restart the computer
2. When it starts, rapidly press the key for BIOS (usually `Del`, `F2`, `F10` or `F12` - depends on manufacturer)
3. Look in the menus for the option "Virtualization Technology", "VT-x", "AMD-V" or "SVM"
4. Enable the option (change from "Disabled" to "Enabled")
5. Save and exit (usually the `F10` key)
6. The computer will restart

## Problem: Cannot paste commands in Ubuntu

Solution: In the Ubuntu window, use right-click to paste, or `Ctrl+Shift+V` (not just `Ctrl+V`).

## Problem: I forgot the password

Solution: Open PowerShell and run:

```powershell
wsl -u root
```

Now you are root (administrator). Change your user's password (replace `yourname` with your username):

```bash
passwd yourname
```

Type the new password twice, then type `exit` to exit.

## Problem: SSH does not start

Solution: Run in Ubuntu:

```bash
sudo apt install --reinstall openssh-server
```

Then:

```bash
sudo service ssh start
```

## Problem: Cannot connect with PuTTY

Check:

1. Is Ubuntu running? (the black window must be open)
2. Is SSH started? Run in Ubuntu: `sudo service ssh status`
3. Is the IP address correct? Run in Ubuntu: `hostname -I`
4. Is Windows Firewall not blocking? Try temporarily disabling the firewall

## Problem: Message "Error: 0x80370102"

Cause: Virtualisation is not enabled in BIOS.

Solution: See above at "Virtualisation is not enabled".

---

# 14. How to use AI assistants

## Recommended assistants

- **Claude**: https://claude.ai
- **ChatGPT**: https://chat.openai.com

## Usage rules

✅ **Allowed:**
- To ask for explanations for concepts you do not understand
- To ask why you get an error and how to solve it
- To ask for code examples to learn
- To check if a command is correct

❌ **Not allowed:**
- To directly copy solutions for homework
- To ask the AI to do your project
- To use AI during exams

## Examples of good questions (WSL2 specific)

```
"I get 'Error: 0x80370102' at wsl --install. What does it mean and how do I check virtualisation?"

"How can I access Windows files in Ubuntu WSL? Where is the C: partition mounted?"

"Why does hostname -I not show me IP in WSL2? Is it different from a virtual machine?"

"How do I make SSH start automatically when I open Ubuntu in WSL?"

"What is the difference between wsl --shutdown and wsl --terminate Ubuntu-24.04?"

"I changed the hostname but I still see the old name. Do I need to do wsl --shutdown?"
```

---

# IMPORTANT COMMANDS SUMMARY

## PowerShell (Windows)

```powershell
wsl --shutdown
```
Stops Ubuntu completely (useful when you want to restart)

```powershell
wsl --status
```
Checks WSL status

```powershell
wsl --list --verbose
```
Shows all installed distributions

## Bash (Ubuntu)

```bash
sudo apt update && sudo apt -y upgrade
```
Updates the system

```bash
sudo service ssh start
```
Starts SSH server

```bash
hostname -I
```
Shows the IP address

```bash
history > file.txt
```
Saves command history to a file

```bash
exit
```
Closes the current session

---

# FINAL CHECKLIST

Before the first seminar, check that you have:

- [ ] Windows 10/11 with virtualisation enabled
- [ ] WSL2 installed and updated
- [ ] Ubuntu 24.04 LTS installed
- [ ] Account created with your surname (e.g.: popescu)
- [ ] Password set (stud)
- [ ] Hostname configured (e.g.: AP_1001_A)
- [ ] System updated (apt update && apt upgrade)
- [ ] Software packages installed
- [ ] SSH working
- [ ] PuTTY installed and configured
- [ ] WinSCP installed and configured
- [ ] Folders created (Books, Projects, etc.)
- [ ] Verification showed everything OK

---

# SELF-CHECK: Verify your competencies

Answer honestly to the following questions. If you cannot tick all of them, revisit the relevant section.

## Can you do the following WITHOUT looking at the guide?

- [ ] ✅ I ran the verification script successfully (all with [OK])
- [ ] ✅ I connected via SSH from PuTTY without help
- [ ] ✅ I transferred a test file with WinSCP (from Windows to Ubuntu)
- [ ] ✅ I know what to do if SSH does not start (the exact command)
- [ ] ✅ I can explain to a colleague what `wsl --shutdown` does vs closing the Ubuntu window

## Quick verification questions

1. **How do you check if virtualisation is enabled in Windows?**
   → Task Manager → Performance → CPU → Virtualization: Enabled

2. **What do you do if you get error 0x80370102?**
   → Enable virtualisation from BIOS/UEFI

3. **Where are Windows files mounted in WSL?**
   → In `/mnt/c/`, `/mnt/d/`, etc.

4. **How do you completely restart WSL?**
   → `wsl --shutdown` from PowerShell

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

*For problems, consult the "Common problems" section or ask an AI assistant before contacting the lecturer.*
