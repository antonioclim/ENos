# User Guide - Homework Recording

This recording workflow requires **asciinema CLI 2.x**, which writes asciicast v2. The recorder checks `asciinema --version` before starting. CLI 3.x writes an incompatible v3 format and is rejected with an explanation; the scripts do not install or downgrade packages. See the [official v2](https://docs.asciinema.org/manual/asciicast/v2/) and [v3](https://docs.asciinema.org/manual/asciicast/v3/) specifications. Version detection has local regression coverage; native terminal recording remains a separate acceptance check.

## Adopted local practice profile

Use `--offline` for the supported ENos practice workflow:

```bash
python record_homework_tui_EN.py --offline
# Bash alternative:
bash record_homework_EN.sh --offline
```

Keep the local recording and check its structure using the [recording contract](../03_GUIDES/RECORDING_CONTRACT.md). Offline mode makes no SSH/SCP connection, upload or legacy-token operation. Institutional submission is deferred until the service owner confirms the complete contract and the workflow passes native acceptance. Historical version labels below identify the source edition.

## Operating Systems 2023-2027

**Version:** 1.1.0 | **Last updated:** January 2025

---

## 🎯 Before You Begin

**Don't panic!** This process looks complicated at first glance, but:
- The script records the session and reports the outcome; install dependencies and choose the mode explicitly
- If `STOP_homework` is mistyped, correct the command or press Ctrl+D to close the recorded shell.
- Local practice can be repeated after preserving the existing file; institutional resubmission rules remain pending

Start with the offline practice session and check the resulting recording before considering an online submission.

---

## 🔄 Recording Process Diagram

1. Check prerequisites; report missing commands without installing them.
2. Enter and validate student data. Save TUI preferences locally.
3. Start the terminal recording and execute the homework commands.
4. Stop the recorded shell with `STOP_homework` or Ctrl+D.
5. Save self-declared identity fields in the asciicast header.
6. In `--offline` mode, retain the local file and stop without networking.
7. In online mode with a confirmed port, attempt the existing legacy metadata token; retain the file on failure.
8. Attempt upload up to three times. Report transfer success or failure separately from institutional acceptance.

---

## Initial Configuration (one time only)

### Step 1: Open the terminal

On Ubuntu/WSL, open a terminal.


> 🚨 **WARNING!** Use YOUR OWN terminal, installed and configured as your instructor has directed!
>
> DO NOT connect to sop.ase.ro!
>
> ⚠️ Errors caused by not following this instruction are your responsibility, the original eligibility rule requires author confirmation; the tools do not decide eligibility automatically.

---

### Step 2: Create the homework directory

```bash
mkdir -p ~/HOMEWORKS
```

**You should see:** Nothing (the `mkdir -p` command is silent on success). This is normal!

Verify it was created:

```bash
ls -la ~/HOMEWORKS
```

**You should see something similar to:**
```
total 8
drwxr-xr-x  2 stud stud 4096 Jan 27 10:00 .
drwxr-xr-x 15 stud stud 4096 Jan 27 09:55 ..
```

📝 **Note:** The directory is empty for now (only `.` and `..`). This is perfectly normal!

Observation: `~` represents your home directory (`/home/{username}/`).

---

### Step 3: Download the script

**Current source:** use the recorder supplied with this checkout.

**Historical Option A: Google Drive distribution (not verified as this candidate)**

1. Open the link in your browser:
   - Python TUI (recommended): https://drive.google.com/file/d/1YLqNamLCdz6OzF6hlcPr1hr738DIaSYz/view?usp=drive_link
   - Bash (alternative): https://drive.google.com/file/d/1dLXPEtGjLo4f9G0Uojd-YXzY7c3ku1Ez/view?usp=drive_link

2. Click on Download (or the ⬇️ icon)

3. Save the file to your Windows computer

---

**Historical Option B: old download example, retained for provenance; use the current checkout**

```bash
cd ~/HOMEWORKS
wget -O record_homework_tui_EN.py "https://drive.google.com/uc?export=download&id=1YLqNamLCdz6OzF6hlcPr1hr738DIaSYz"
```

**You should see:**
```
--2025-01-27 10:05:32--  https://drive.google.com/uc?...
Resolving drive.google.com (drive.google.com)... 142.250.185.78
Connecting to drive.google.com (drive.google.com)|142.250.185.78|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 34644 (34K) [application/octet-stream]
Saving to: 'record_homework_tui_EN.py'

record_homework_tui_EN.py   100%[===================>]  33.83K  --.-KB/s    in 0.02s

2025-01-27 10:05:33 (1.65 MB/s) - 'record_homework_tui_EN.py' saved [34644/34644]
```

⚠️ **If you see "ERROR 403: Forbidden":** The link may be restricted. Download manually from the browser.

> 💡 This method downloads the file directly into the HOMEWORKS folder, without intermediate steps!

---

**Option C: Copy the script to Ubuntu using WinSCP**

1. Open WinSCP and connect to your Ubuntu/WSL system
2. Navigate to `/home/{username}/HOMEWORKS/`
3. Copy the downloaded file (`record_homework_tui_EN.py`) to this directory

---

**Option D: Copy directly in WSL (if using WSL)**

```bash
cp /mnt/c/Users/{WindowsName}/Downloads/record_homework_tui_EN.py ~/HOMEWORKS/
```

**You should see:** Nothing (silent success).

⚠️ Replace `{WindowsName}` with your Windows username!

**Verify it worked:**
```bash
ls -l ~/HOMEWORKS/
```

**You should see the file listed.**

---

### Step 4: Make the script executable

```bash
cd ~/HOMEWORKS
chmod +x record_homework_tui_EN.py
```

**You should see:** Nothing (silent success).

Verify that the permissions have changed:

```bash
ls -l record_homework_tui_EN.py
```

**You should see `x` in the permissions:**
```
-rwxr-xr-x 1 stud stud 34644 Jan 27 10:05 record_homework_tui_EN.py
 ^^^
 These 'x' mean "executable"
```

❌ **If you see `-rw-r--r--`** (without `x`): The chmod command did not work. 
Check that you are in the correct directory with `pwd` — it should show `~/HOMEWORKS` or `/home/{username}/HOMEWORKS`.

---

### Step 5: Verify the final structure

```bash
ls -la ~/HOMEWORKS/
```

**You should see:**
```
drwxr-xr-x  2 {username} {username} 4096 Jan 21 10:00 .
drwxr-xr-x 15 {username} {username} 4096 Jan 21 09:55 ..
-rwxr-xr-x  1 {username} {username} 38000 Jan 21 10:00 record_homework_tui_EN.py
```

✅ **If you see something similar, you are ready!**

---

## Quick Start (every time)

### Step 1: Enter the HOMEWORKS directory

```bash
cd ~/HOMEWORKS
```

**You should see:** Nothing (silent success). The prompt may change the displayed directory.

---

### Step 2: Run the script

```bash
python record_homework_tui_EN.py --offline
```

**You should see:** The "Matrix rain" effect followed by the programme banner.

---

### Step 3: Follow the on-screen instructions

---

## First Use: Explicit Dependency Setup

Install system packages explicitly in the lab environment, then create one Python virtual environment:

```bash
python3 -m venv ~/.venvs/enos-recorder
source ~/.venvs/enos-recorder/bin/activate
python -m pip install rich questionary
```

Run with `python record_homework_tui_EN.py --offline` while that environment is active. The recorder only checks dependencies; it does not modify the OS or install into system Python.

---

## Entering Data

### Surname
- Format: Letters and hyphen only (no spaces)
- Valid examples: `Smith`, `Jones-Williams`
- Converted to: UPPERCASE (`SMITH`)
- Test with simple data before complex cases

### First name
- Format: Letters and hyphen only (no spaces)
- Valid examples: `John`, `Mary-Anne`
- Converted to: Title Case (`John`)
- Use `man` or `--help` when in doubt

### Group
- Format: Exactly 4 digits
- Valid examples: `1029`, `1035`, `1234`

### Specialisation
- Use the up/down arrow keys to navigate
- Press **ENTER** to select
- Options:
  - Economic Informatics (English)
  - ID Group

### Homework number
- Format: 01-07 followed by a letter
- Valid examples: `01a`, `03b`, `07c`

---

## Pre-filled Data

After the first use, your data will be saved automatically:
- Surname
- First name
- Group

On the next run, these fields will be **pre-filled**. You can:
- Press **ENTER** to keep the previous value
- Type something else to replace it

The homework number is not pre-filled (it is different each time).

---

## Recording

### When recording starts:

```
╔═══════════════════════════════════════════════════════════════════╗
║                     🔴 RECORDING IN PROGRESS                      ║
╠═══════════════════════════════════════════════════════════════════╣
║                                                                   ║
║   To STOP and SAVE the recording, type: STOP_homework             ║
║                                                                   ║
║   or press Ctrl+D                                                 ║
║                                                                   ║
╚═══════════════════════════════════════════════════════════════════╝
```

### What to do:

1. Execute the commands required for your homework
2. Clearly show what you are doing and why
3. When you have finished, type:

```bash
STOP_homework
```

or press `Ctrl+D`

### Tips for a good recording:

- ✅ Type clearly - don't rush, and also ✅ Comment what you are doing (optional but helps)
- ✅ Check the results of commands before stopping
- ❌ DO NOT delete mistakes - they show you are learning from them
- ❌ DO NOT use clear/cls excessively

---

## Upload

After stopping the recording:

1. Save the local recording and self-declared header metadata.
2. In offline mode, stop with no connection or token generation.
3. In online mode with a confirmed port, generate the legacy token and attempt transfer up to three times. Keep the recording on failure.

### If the upload succeeds:

```
╔═══════════════════════════════════════════════════════════════════╗
║                     ✅ UPLOAD SUCCESSFUL!                         ║
╚═══════════════════════════════════════════════════════════════════╝
```

### If the upload fails:

The file is saved locally and you will see a message with the command for manual submission:

```
╔═════════════════════════════════════════════════════════════════════════╗
║                          Submission Failed                              ║
╠═════════════════════════════════════════════════════════════════════════╣
║                                                                         ║
║   ❌ COULD NOT SEND HOMEWORK!                                           ║
║                                                                         ║
║   The file has been saved locally.                                      ║
║                                                                         ║
║   ╔═══════════════════════════════════════════════════════════════╗     ║
║   ║                                                               ║     ║
║   ║   📁  1029_SMITH_John_HW03b.cast                              ║     ║
║   ║                                                               ║     ║
║   ╚═══════════════════════════════════════════════════════════════╝     ║
║                                                                         ║
║   Try later (when you restore connection) using:                        ║
║                                                                         ║
║   scp -P "$ENOS_CONFIRMED_PORT" 1029_SMITH_John_HW03b.cast stud-id@sop.ase.ro:/home...    ║
║                                                                         ║
║   ⚠️  DO NOT modify the .cast file before submission!                   ║
║                                                                         ║
╚═════════════════════════════════════════════════════════════════════════╝
```

Remember:
- ⚠️ Preserve the original `.cast` as evidence; the legacy token does not detect every modification.
- 📋 The screen above is an illustration with a truncated destination. Use only the actual file, account and destination confirmed for your submission, the confirmed port and `-o StrictHostKeyChecking=yes`; retain the local recording if verification or transfer fails
- 🔄 You can repeat local practice after preserving the previous recording; this does not establish an institutional resubmission right

---

## Generated File

### Location:

The `.cast` file is saved in the current directory (i.e. `~/HOMEWORKS/` if you followed the configuration steps).

```
/home/{username}/HOMEWORKS/1029_SMITH_John_HW03b.cast
```

### File name:

```
[GROUP]_[SURNAME]_[FirstName]_HW[Number].cast
```

Example: `1029_SMITH_John_HW03b.cast`

### Contents:

- The complete recording of the terminal session
- The legacy metadata token in online mode (authenticity remains unverified)

---

## ❓ Frequently Asked Questions (FAQ)

### General

**Q: Why must I use my own terminal and not the sop.ase.ro server?**

A: Asciicast v2 records its associated pseudoterminal stream and timing. Ordinary text recording does not capture unrelated sessions or ambient audio. Use your own configured lab environment so that commands and files belong to the intended exercise; the metadata labels do not authenticate the user.

---

**Q: Can I use a different terminal than the default (Windows Terminal, iTerm2)?**

A: Yes, any terminal that supports ANSI sequences will work. Recommendations:
- Windows: Windows Terminal (pre-installed on Windows 11)
- macOS: iTerm2 or Terminal.app
- Linux: GNOME Terminal, Konsole, Alacritty

---

**Q: What happens if I accidentally closed the terminal during recording?**

A: The recording stops automatically and the partial file is saved. You can:
1. Check if the .cast file exists: `ls -la ~/HOMEWORKS/*.cast`
2. If it is too short, delete it and start again: `rm ~/HOMEWORKS/...cast`
3. Run the script again

---

**Q: Can I edit the .cast file after recording?**

A: The existing public-key-encrypted metadata token is not a digital signature and does not bind the recording content. It cannot establish authorship, non-repudiation or detect every edit. Preserve the original recording; the institutional verification and resubmission contract remains pending author decision.

---

**Q: How can I verify that the signature is valid?**

A: The current format is public-key encryption of metadata, not a digital signature. A syntax check cannot authenticate it; the replacement protocol remains an author decision. You may inspect the footer:
```bash
tail -5 ~/HOMEWORKS/GROUP_SURNAME_FirstName_HWxx.cast
# The last line should start with "## " followed by Base64
```

---

## 🔧 Common Problems (Troubleshooting)

### Installation Problems

#### 1. "Permission denied" during installation

```bash
# Make sure you are in the HOMEWORKS directory
cd ~/HOMEWORKS


python record_homework_tui_EN.py --offline
```

**You should see:** Dependency checks followed by the interface, if all prerequisites are available.

---

#### 2. "E: Unable to locate package asciinema"

The apt repositories are not updated. Run:

```bash
sudo apt update
sudo apt install asciinema
```

**You should see:** The updated package list, then the asciinema installation.

If it still does not work, add the official PPA:
```bash
sudo apt-add-repository ppa:zanchey/asciinema
sudo apt update
sudo apt install asciinema
```

---

#### 3. pip install fails with "externally-managed-environment"

On Ubuntu 23.04+ and Debian 12+, the system protects Python packages.
Use a dedicated virtual environment:

```bash
python3 -m venv ~/.venvs/enos-recorder
source ~/.venvs/enos-recorder/bin/activate
python -m pip install rich questionary
```

---

#### 4. "sudo: apt: command not found"

**Cause:** You are not on a Debian/Ubuntu distribution.

**Solution:** If you are using Fedora/RHEL:
```bash
sudo dnf install asciinema openssl sshpass
```

For Arch:
```bash
sudo pacman -S asciinema openssl sshpass
```

---

#### 5. "python3: command not found"

**Cause:** Python is not installed or is not in PATH.

**Solution:**
```bash
sudo apt install python3 python3-venv
python3 --version
```

---

#### 6. WSL: "chmod: cannot access 'record_homework_tui_EN.py': No such file"

**Cause:** The file is not in the current directory.

**Solution:**
```bash
# Check where you are:
pwd
# You should see: /home/YOURNAME/HOMEWORKS

# If not, navigate:
cd ~/HOMEWORKS

# Check the contents:
ls -la
```

---

### Running Problems

#### 7. "rich" or "questionary" import error after installation

**Cause:** pip installed in user site-packages, but Python cannot find it.

**Solution:**
```bash
python3 -m venv ~/.venvs/enos-recorder
source ~/.venvs/enos-recorder/bin/activate
python -m pip install rich questionary
python -c "import rich, questionary; print('OK')"
```

---

#### 8. The "Matrix rain" screen is broken (strange characters)

**Cause:** The terminal does not support Japanese Unicode characters.

**Solution:** Set the terminal font to one that supports Unicode:
- Windows Terminal: "Cascadia Code" or "Consolas"
- VS Code terminal: "Fira Code" or "JetBrains Mono"

Alternatively, use the Bash version (without Matrix effects):
```bash
bash record_homework_EN.sh --offline
```

---

#### 9. Colours do not appear (everything is black/white)

**Cause:** The terminal does not support 256 colours or ANSI is disabled.

**Solution:**
```bash
# Check colour support:
echo $TERM
# You should see: xterm-256color

# If you see something else (e.g.: "dumb"):
export TERM=xterm-256color
# Add to ~/.bashrc for permanence
```

---

### Recording Problems

#### 10. Recording does not stop when I type STOP_homework

**Cause:** `STOP_homework` is an alias defined in the recording session.

Possible causes:
1. You typed in a different terminal (it must be THE ONE where the recording is running)
2. You wrote `stop_homework` (case-sensitive!)
3. You have extra spaces

**Alternative solution:** Press `Ctrl+D` (end of file)

---

#### 11. The .cast file is empty or very small (under 1KB)

**Cause:** The recording stopped prematurely.

Causes:
1. You pressed Ctrl+C instead of Ctrl+D
2. The shell crashed
3. Error during asciinema initialisation

**Solution:** Check with:
```bash
cat ~/HOMEWORKS/GROUP_SURNAME_FirstName_HWxx.cast | head -20
# You should see valid JSON
```

---

#### 12. I made a mistake with a command and want to redo it

**Solution:** DO NOT stop the recording! Mistakes are OK and show the learning process. Simply:
1. Press up arrow to edit the previous command
2. Or type the correct command

⚠️ **DO NOT use `clear`** — it clears the current display but leaves earlier recording events intact; keep the demonstration easy to follow.

---

#### 13. I want to pause during the recording

**Info:** Asciinema also records idle time.

**Solution:** You can pause, but:
- During playback a long pause will be visible
- The instructor can speed up playback, so it is not a problem
- If the pause is VERY long (hours), it is better to stop and restart

---

### Network / Upload Problems

#### 14. "Connection refused" during upload

**Possible causes:**
- You are not connected to the internet
- The server is temporarily unavailable
- You are on a restricted network

**Solution:** The file is saved locally. Try later or contact the instructor.

---

#### 15. "Connection timed out"

**Configuration pending:** Historical copies use 1001 and 1002. Confirm the port through the service owner; neither number is established as the current service configuration.

Possible causes:
1. The confirmed service port is unreachable on the approved network route
2. Active VPN that does not route correctly
3. Server temporarily unavailable

**Solution:**
```bash
# Only when a service-owner-authorised connectivity check is appropriate:
: "${ENOS_CONFIRMED_PORT:?Set the SSH port confirmed by the service owner}"
nc -zv sop.ase.ro "$ENOS_CONFIRMED_PORT"

# Use the approved network route; do not disable protective controls to bypass a restriction.
```

---

#### 16. "Host key verification failed"

**Meaning:** The client cannot match the server key to a trusted entry, or the presented key differs from the stored entry. The current clients use `StrictHostKeyChecking=yes`; a first connection or changed key can therefore stop the transfer.

1. Retain the local recording and stop the online attempt.
2. Confirm the exact host, port and host-key fingerprint with the service owner through a trusted channel, independent of the failing connection.
3. Add or replace only the specifically verified `known_hosts` entry using the service owner's procedure. Do not disable host-key checking or delete entries merely to suppress the warning.
4. Retry only after the entry and destination have been verified. Use `--offline` for further local practice while this remains unresolved.

---

#### 17. "Permission denied" during upload (but connection works)

**Cause:** The destination directory does not exist or you do not have permissions.

**Solution:** This is a server problem. Contact the instructor with:
- Selected specialisation: [eninfo/grupeid]
- The exact error message
- The confirmed host, port, account and destination, with passwords, private keys and other credentials omitted. A remote diagnostic command requires the service owner's instructions; the historical shared password and fixed-port command are not a current diagnostic procedure

---

### Other Problems

#### 18. The script does not start at all

```bash
# Check the Python version
python3 --version
# Must be Python 3.8 or newer

# Check that the script exists and is executable
ls -l ~/HOMEWORKS/record_homework_tui_EN.py
```

---

#### 19. I entered the wrong data

Run the script again and enter the correct data. Keep the previous file as evidence and move it aside deliberately before reusing the same name.

---

#### 20. The recording includes the script prompt too (not just my commands)

**Note:** This is all intentional! The instructor sees the complete context. Asciinema captures the recorded pseudoterminal stream during the session. Prompts can aid interpretation but do not prove authenticity.

---

## About the Legacy Metadata Token

Online mode retains public-key encryption of metadata. The following intended properties are **not** established:

- **Authenticity:** self-declared labels do not prove who created the file
- **Integrity:** the legacy payload is not bound to the event content
- **Non-repudiation:** no supported proof is established by this token
- Always check the result before continuing

**This legacy format does not prove authenticity or prevent forgery.**

---

## ✨ Tips for Success

1. **Read the ENTIRE guide** before your first attempt (15 minutes)
2. **Prepare your commands** in another document before recording
3. **Test commands** individually before the final recording
4. **Do a "trial run"** with a fictitious homework if you are unsure

---

## 🏆 You Did It!

If you have reached this point and successfully submitted your homework — **congratulations**! 

You have just used:
- 🐧 **Shell scripting** in Linux
- 🔐 **Asymmetric cryptography** (RSA)
- 🌐 **Secure file transfer** (SCP)
- 📹 **Terminal recording** (asciinema)

These are real skills used daily by system administrators and DevOps engineers. **You are on the right track!**

---

## Support

For technical problems:
- Contact your lab instructor
- Check if you have the latest version of the script
- Consult the FAQ and Troubleshooting sections above

---

*Operating Systems 2023-2027 - ASE Bucharest*
*Documentation version: 1.1.0*
