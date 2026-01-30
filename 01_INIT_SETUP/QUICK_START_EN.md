# Quick Start — 5 Minute Verification

> Use this checklist to verify your installation is complete.  
> If any check fails, return to the full guide for that step.

---

## Before SEM01, verify everything works

### Step 1: Can you start Ubuntu?

**WSL2 users (Windows):**
- Open Start menu → type "Ubuntu" → click to open
- A terminal window should appear with your username

**VirtualBox users:**
- Open VirtualBox → select your VM → click Start
- Connect via SSH: `ssh yourname@VM_IP_ADDRESS`

✅ **Pass:** You see a command prompt like `popescu@AP_1001_A:~$`

---

### Step 2: Run quick checks

Copy and paste these commands in Ubuntu:

```bash
# Check Ubuntu version (should show 24.04)
lsb_release -d

# Check your hostname (should be INITIAL_GROUP_SERIES format)
hostname

# Check your username (should be your surname)
whoami

# Check internet connectivity
ping -c 2 google.com
```

✅ **Pass:** All commands work and show correct values

---

### Step 3: Run the full verification script

```bash
bash ~/verify_installation.sh
```

Or download it first if you do not have it:

```bash
# If verify_installation.sh is not in your home directory
curl -O https://raw.githubusercontent.com/YOUR_REPO/verify_installation.sh
bash verify_installation.sh
```

✅ **Pass:** All items show `[OK]` in green

---

### Step 4: Test SSH connection (from Windows/host)

**Windows users:**
1. Open PuTTY
2. Enter your Ubuntu IP address (find it with `hostname -I` in Ubuntu)
3. Click Open
4. Login with your credentials

**macOS/Linux users:**
```bash
ssh yourname@IP_ADDRESS
```

✅ **Pass:** You can connect remotely to your Ubuntu

---

## Quick Reference Card

| What | Command | Expected result |
|------|---------|-----------------|
| Ubuntu version | `lsb_release -d` | Ubuntu 24.04.x LTS |
| Hostname | `hostname` | AP_1001_A (your format) |
| Username | `whoami` | popescu (your surname) |
| IP address | `hostname -I` | 172.x.x.x or 192.168.x.x |
| Start SSH | `sudo systemctl start ssh` | No output = success |
| Check SSH | `sudo systemctl status ssh` | "active (running)" |

---

## All checks passed?

🎉 **You are ready for SEM01!**

Bring your laptop charged. We start coding from minute one.

---

## Something failed?

| Problem | Solution |
|---------|----------|
| Ubuntu won't start | Check virtualisation in BIOS |
| Wrong hostname | Re-run hostname configuration (Section 6) |
| SSH not working | Run `sudo systemctl start ssh` |
| No internet | Check network adapter settings |
| Forgot password | See "I forgot the password" in troubleshooting |

For detailed help, return to the full guide:
- WSL2: `GUIDE_WSL2_Ubuntu2404_EN.md`
- VirtualBox: `GUIDE_VirtualBox_Ubuntu2404_EN.md`

---

*Version 2.1 | January 2025 | ASE Bucharest - CSIE*
