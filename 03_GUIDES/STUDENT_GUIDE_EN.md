# User Guide - Homework Recording

This recording workflow requires **asciinema CLI 2.x**, which writes asciicast v2. The recorder checks `asciinema --version` before starting. CLI 3.x writes an incompatible v3 format and is rejected with an explanation; the scripts do not install or downgrade packages. See the [official v2](https://docs.asciinema.org/manual/asciicast/v2/) and [v3](https://docs.asciinema.org/manual/asciicast/v3/) specifications. Version detection has local regression coverage; native terminal recording remains a separate acceptance check.

> **v6 candidate correction:** Follow the [current recording contract](RECORDING_CONTRACT.md). Practice requires `--offline`; online configuration and the replacement verification protocol remain unresolved. Historical version labels below identify the source edition, not a new release.

For an authorised online run, first obtain the host, account, port and host-key fingerprint from the service owner through a trusted channel. The supplied clients target `sop.ase.ro`; if the confirmed destination differs, the client configuration must be reconciled before use. Install only the verified host-key entry in `known_hosts`. The clients use `StrictHostKeyChecking=yes`.

After the configuration and use of the existing workflow have been confirmed, use the current client interface:

```bash
read -r -p 'SSH port confirmed by the service owner: ' ENOS_CONFIRMED_PORT
python record_homework_tui_EN.py --port "$ENOS_CONFIRMED_PORT"
```

The Bash alternative is `bash record_homework_EN.sh --port "$ENOS_CONFIRMED_PORT"`. Both clients validate the supplied port; neither historical port is selected by this guide. For local practice, continue to use `--offline`.

## Operating Systems 2023-2027

**Version:** 1.1.1 | **Last updated:** January 2025

---

## 🎯 Before You Begin

**Don't panic!** This process looks complicated at first glance, but:
- The script records the session and reports the outcome; install dependencies and choose the mode explicitly
- A typo in `STOP_homework` can be corrected; Ctrl+D also closes the recorded shell. The historical “most common / 2 seconds” claim is unverified
- Local practice can be repeated after preserving the existing file; institutional resubmission rules remain pending

💪 **85% of students from previous years succeeded on their first attempt.**

> **Provenance pending author review:** The percentage is retained from the source; no denominator, cohort or measurement record is established here.

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

> **Historical anecdote — provenance pending author review.**
> 💡 **From the trenches:** In 2023, a student accidentally typed `STOP-homework` (with hyphen instead of underscore) and spent 20 minutes wondering why the recording wouldn't stop. The solution? Read the screen carefully — it says `STOP_homework` with an **underscore**! Since then, I've made the text larger and added Ctrl+D as a backup. Learn from others' mistakes.

---

## Initial Configuration (one time only)

### Step 1: Open the terminal

On Ubuntu/WSL, open a terminal.

*(Historical author statement, retained for review: WSL2 has completely changed the way I teach — now students can practise Linux without dual boot.)*


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

## 🧪 Optional: Practice Run (Highly Recommended!)

Before recording your real homework, do a test run with fictitious data. This takes 2 minutes and eliminates surprises when it matters.

```bash
cd ~/HOMEWORKS
python record_homework_tui_EN.py --offline
```

Enter test data:
- Surname: `TEST`
- First name: `Student`
- Group: `0000`
- Specialisation: Economic Informatics (English)
- Homework: `01x`

Then:
1. Type a few simple commands (`ls`, `pwd`, `echo "hello"`)
2. Type `STOP_homework` (with **underscore**, not hyphen!)
3. Observe the local file being saved; offline mode skips legacy token generation
4. With `--offline`, no connection or upload is attempted. Group 0000 alone does not disable upload

Delete the test file afterwards:

```bash
rm 0000_TEST_Student_HW01x.cast
```

**Why practice?** The first time you see the recording interface, legacy metadata-token step and upload can feel overwhelming. A 2-minute practice run builds confidence for the real submission.

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
  - Economic Informatics (Romanian)

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

- ✅ Type clearly — rushing leads to typos
- ✅ Optionally, comment what you're doing (helps the instructor follow your logic)
- ✅ Check the results of commands before stopping
- ❌ DO NOT delete mistakes — they show you are learning from them
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

## ✅ Verify Before Sending

Use our verification script to check your submission:

```bash
./check_my_submission.sh 1029_SMITH_John_HW03b.cast
```

This parses the supported header/events and footer syntax. Exit 0 reports valid structure, while authentication remains UNVERIFIED and submission readiness UNCONFIRMED.

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

> **Historical anecdote — capture context and provenance unconfirmed. Standard asciicast does not record audio or unrelated sessions.**
> *A former student once ran the script on the shared server. The resulting 47-minute recording included three other students' work, a coffee break conversation and someone's Spotify playlist playing in the background. Don't be that student.*

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

Or use our verification script:
```bash
./check_my_submission.sh your_homework.cast
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
3. You wrote `STOP-homework` (with hyphen instead of underscore!)
4. You have extra spaces

**Alternative solution:** Press `Ctrl+D` (end of file)

> Honestly, this catches someone every semester. You're not alone.

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
- Selected specialisation: [eninfo/grupeid/roinfo]
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
2. **Do a practice run** with fictitious data (see section above)
3. **Prepare your commands** in another document before recording
4. **Test commands** individually before the final recording
5. **Verify your submission** with `check_my_submission.sh` before manual upload

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

For technical problems, follow this escalation path:

1. **Self-help first:**
   - Run `bash check_my_submission.sh path/to/your_recording.cast` to inspect the local format
   - Check the FAQ section above
   - Check the Troubleshooting section
   - Verify you have the latest version of the script

2. **Peer support:**
   - Ask a colleague who has already submitted successfully
   - Check the course forum/Teams channel (if available)

3. **Instructor contact:**
   - Contact your lab instructor during office hours
   - Email with subject line: `[OS Homework] Brief description of problem`
   - Include: your group, the exact error message, what you tried

**Unconfirmed historical response-time claim (author review required):** Lab instructors typically respond within 24-48 hours during term time. For urgent issues before deadlines, use office hours.

---

*Operating Systems 2023-2027 - ASE Bucharest*
*Documentation version: 1.1.1*
