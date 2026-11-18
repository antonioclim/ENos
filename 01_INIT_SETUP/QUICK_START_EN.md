# Quick Start — 5 Minute Verification

> **Phase 5 source correction:** Keep the academic identifier (for example `AP_1001_A`) in your student records. The machine hostname is a separate DNS-compatible label: map that example to `ap-1001-a` by lowercasing and replacing underscores with hyphens. This is a technical mapping, not an authentication or grading rule. Usernames must also satisfy the installer: start with a lower-case letter, use a suitable unique local username and keep the full student identity separately.

Use a unique local password that you can retain securely. Never configure the shared historical example password `stud` on a network-accessible guest. Bridged mode exposes the guest to the surrounding network: use only an authorised lab network and scope SSH access to the intended host. A first SSH connection requires checking the guest fingerprint through the VM console.

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

✅ **Pass:** You see a command prompt like `popescu@ap-1001-a:~$`

---

### Step 2: Run quick checks

Copy and paste these commands in Ubuntu:

```bash
# Check Ubuntu version (should show 24.04)
lsb_release -d

# Check your hostname (should be initials-group-series format)
hostname

# Check your username (should be your surname)
whoami

# Check internet connectivity
ping -c 2 google.com  # optional ICMP diagnostic; failure alone does not prove no internet
```

✅ **Pass:** All commands work and show correct values

---

### Step 3: Run the full verification script

```bash
bash 01_INIT_SETUP/verify_installation.sh  # run from the repository root
```

The verifier is included in this checkout. If you deliberately need the historical v5.5.0 copy, the pinned source is:

```bash
# If verify_installation.sh is not in your home directory
curl --fail --location --output verify_installation-v5.5.0.sh https://raw.githubusercontent.com/antonioclim/ENos/d8fdd0507fe26e6bc1438a692da14afc2112464c/01_INIT_SETUP/verify_installation.sh
bash verify_installation-v5.5.0.sh  # historical diagnostic, not this corrected candidate
```

✅ **Pass:** The summary reports its checks and limits. Optional warnings do not establish missing capabilities, and local checks are not full host acceptance.

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
| Hostname | `hostname` | ap-1001-a (your format) |
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
