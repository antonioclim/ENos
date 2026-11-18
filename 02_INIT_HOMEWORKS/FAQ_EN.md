# ❓ FAQ - Frequently Asked Questions

> **v6 candidate correction:** Follow the [current recording contract](../03_GUIDES/RECORDING_CONTRACT.md). Practice requires `--offline`; online configuration and the replacement verification protocol remain unresolved. Historical version labels below identify the source edition, not a new release.

## Homework Recording System - Operating Systems 2023-2027

---

## 📋 Contents

1. [General](#general)
2. [Installation and Setup](#installation-and-setup)
3. [Running and Usage](#running-and-usage)
4. [Recording](#recording)
5. [Upload and Network](#upload-and-network)
6. [Legacy Metadata Token](#legacy-metadata-token)
7. [Specific Errors](#specific-errors)

---

## General

### Q: Why must I use my own terminal and not the sop.ase.ro server?

**A:** Asciicast v2 records its associated pseudoterminal stream and timing. Ordinary text recording does not capture unrelated sessions or ambient audio. Use your own configured lab environment so that commands and files belong to the intended exercise; the metadata labels do not authenticate the user.

---

### Q: Can I use a different terminal than the default one?

**A:** Yes, any terminal that supports ANSI sequences will work:
- **Windows:** Windows Terminal (recommended), PowerShell, CMD with Windows Terminal
- **macOS:** iTerm2, Terminal.app
- **Linux:** GNOME Terminal, Konsole, Alacritty, Terminator

---

### Q: What is the difference between the Python TUI and Bash versions?

**A:** 

| Aspect | Python TUI | Bash |
|--------|------------|------|
| Interface | Graphical (Matrix theme) | Plain text |
| Dependencies | Python 3.8+, rich, questionary | Bash, Python 3 and asciinema; online mode also needs OpenSSL/SSH tools |
| Animations | Yes (rain, spinners) | No |
| Menus | Interactive (arrow keys) | Text input |
| Recommendation | For most users | Backup/minimal systems |

---

### Q: How long does the complete process take?

**A:** 
- **First time:** 3-5 minutes (installing dependencies) + your solving time
- **Subsequently:** ~30 seconds setup + your solving time + ~30 seconds upload

---

## Installation and Setup

### Q: What Python version do I need?

**A:** Python 3.8 or newer. Check with:
```bash
python3 --version
```

---

### Q: How do I check if all dependencies are installed?

**A:**
```bash
# Python packages
python3 -c "import rich; import questionary; print('OK')"

# System packages
which asciinema openssl sshpass
```

---

### Q: Can I install the dependencies manually?

**A:** Yes:
```bash
# Python
python3 -m venv ~/.venvs/enos-recorder
source ~/.venvs/enos-recorder/bin/activate
python -m pip install rich questionary

# System
sudo apt install asciinema openssl sshpass
```

---

### Q: What do I do if I have Ubuntu 24.04 and pip refuses to install?

**A:** Ubuntu 24.04 uses PEP 668 (externally-managed-environment). Solutions:

```bash
python3 -m venv ~/.venvs/enos-recorder
source ~/.venvs/enos-recorder/bin/activate
python -m pip install rich questionary
```

---

### Q: Does it work on macOS?

**A:** Partially. You need to install manually with Homebrew:
```bash
brew install asciinema openssl
# sshpass is not in official Homebrew, use:
brew install hudochenkov/sshpass/sshpass
```

---

## Running and Usage

### Q: Why does the Matrix effect look strange?

**A:** The terminal does not support Katakana characters. Solutions:
1. Use a font with complete Unicode support (Cascadia Code, Fira Code)
2. Or use the Bash version: `bash record_homework_EN.sh --offline`

---

### Q: How do I change the saved data (name, group)?

**A:** Two options:
1. Delete the config: `rm ~/.homework_recorder_config.json`
2. Or simply overwrite when prompted for the data

---

### Q: Can I run the script from a directory other than HOMEWORKS?

**A:** Yes, but the .cast file will be saved in the current directory. We recommend staying in `~/HOMEWORKS/` for organisation.

---

### Q: What do the validation errors mean?

**A:**

| Error | Cause | Solution |
|-------|-------|----------|
| "Use only letters and hyphen" | Spaces or special characters in name | Remove spaces: `John Paul` → `John-Paul` |
| "Group must have exactly 4 digits" | Too many/few digits | Check the group number |
| "Format: 01-07 followed by a letter" | Invalid homework number | E.g.: `01a`, `03b`, `07c` |

---

## Recording

### Q: What happens if I accidentally close the terminal?

**A:** The recording stops and the partial file is saved. Check:
```bash
ls -la ~/HOMEWORKS/*.cast
```
If it is too short, delete it and start again.

---

### Q: STOP_homework is not working!

**A:** Check:
1. You are in the CORRECT terminal (the one with the recording)
2. You typed exactly `STOP_homework` (case-sensitive!)
3. You have no extra spaces

**Alternative:** Press `Ctrl+D`

---

### Q: Can I pause during the recording?

**A:** Yes, but asciinema also records the time. The instructor can speed up playback, so it is not a problem. For very long pauses (hours), it is better to stop and restart.

---

### Q: Are mistakes visible in the recording?

**A:** Yes, and that is OK! Mistakes show the learning process. Do NOT use `clear` to hide them.

---

### Q: How long can the recording be?

**A:** Technically unlimited, but:
- Recommendation: 5-30 minutes
- Very large files (>100MB) may be difficult to upload
- The instructor will not watch hours of recording

---

## Upload and Network

### Q: Why does it use port 1001 and not 22?

**A:** The historical copies disagree on 1001/1002; no current service configuration or reason for the port choice is verified. Obtain the confirmed port from the instructor.

---

### Q: The upload always fails. What do I do?

**A:** Check in order:
1. **Internet:** `ping google.com`
2. **Port open:** `nc -zv sop.ase.ro "$ENOS_CONFIRMED_PORT"`
3. **VPN:** Check the approved network route with your administrator
4. **Firewall:** Request a rule for the confirmed host/port where required

If nothing works, send manually later with the displayed command.

---

### Q: Can I send the file manually?

**A:** Yes:
```bash
scp -P "$ENOS_CONFIRMED_PORT" FILENAME.cast stud-id@sop.ase.ro:/home/HOMEWORKS/SPECIALISATION/
```
Replace FILENAME and SPECIALISATION with your values.

---

### Q: The server is down. When will it be available?

**A:** Contact the instructor. In the meantime, the file is saved locally and you can send it later.

---

## Legacy Metadata Token

### Q: What data is included in the signature?

**A:** The legacy encrypted metadata contains:
- Surname + First name
- Group
- File size (bytes)
- Date and time
- System username
- Absolute file path

---

### Q: Can I verify the signature?

**A:** These scripts encrypt metadata with a public key; decryption with the matching private key is not digital-signature verification. You can inspect the footer syntax, which establishes no authenticity:
```bash
tail -3 FILENAME.cast
# The 02 format has separate "## SIG:" and "## META:" lines; neither proves authenticity.
```

---

### Q: What happens if I modify the .cast file?

**A:** The existing public-key-encrypted metadata token is not a digital signature and does not bind the recording content. It cannot establish authorship, non-repudiation or detect every edit. Preserve the original recording; the institutional verification and resubmission contract remains pending author decision.

---

### Q: Can I use another student's signature?

**A:** The metadata labels do not authenticate their author, and the token is not bound to the recording content. Preserve original evidence; the verification contract remains unresolved.

---

## Specific Errors

### Q: "ModuleNotFoundError: No module named 'rich'"

**A:**
```bash
python3 -m venv ~/.venvs/enos-recorder
source ~/.venvs/enos-recorder/bin/activate
python -m pip install rich questionary
# Use the same activated interpreter for both installation and execution.
```

---

### Q: "bash: ./record_homework_tui_EN.py: Permission denied"

**A:**
```bash
chmod +x record_homework_tui_EN.py
# Or run with:
python record_homework_tui_EN.py --offline
```

---

### Q: "asciinema: command not found"

**A:**
```bash
sudo apt update
sudo apt install asciinema
```

---

### Q: "sshpass: command not found"

**A:**
```bash
sudo apt install sshpass
```

---

### Q: "openssl: error: ... unable to load Public Key"

**A:** The public key in the script is corrupted. Re-download the script from the official source.

---

### Q: "Error: No such file or directory" during upload

**A:** The destination directory does not exist on the server. Contact the instructor for verification.

---

## Did not find your answer?

1. Check the Troubleshooting section in STUDENT_GUIDE_EN.md
2. Contact your lab instructor
3. Describe the problem exactly: what you did, what you saw, what you expected to see

---

*Operating Systems 2023-2027 - ASE Bucharest*
*Last updated: January 2025*
