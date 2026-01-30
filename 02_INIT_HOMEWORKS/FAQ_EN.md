# ❓ FAQ - Frequently Asked Questions

## Homework Recording System - Operating Systems 2023-2027

---

## 📋 Contents

1. [General](#general)
2. [Installation and Setup](#installation-and-setup)
3. [Running and Usage](#running-and-usage)
4. [Recording](#recording)
5. [Upload and Network](#upload-and-network)
6. [Cryptographic Signature](#cryptographic-signature)
7. [Specific Errors](#specific-errors)

---

## General

### Q: Why must I use my own terminal and not the sop.ase.ro server?

**A:** The asciinema recording captures ALL terminal activity. On the server, your activity would mix with other students' and the resulting file would be unusable. Additionally, the cryptographic signature is based on the LOCAL user.

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
| Dependencies | Python 3.8+, rich, questionary | Bash only |
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
pip3 install --user rich questionary

# System
sudo apt install asciinema openssl sshpass
```

---

### Q: What do I do if I have Ubuntu 24.04 and pip refuses to install?

**A:** Ubuntu 24.04 uses PEP 668 (externally-managed-environment). Solutions:

```bash
# Option 1: --break-system-packages (recommended for this script)
pip3 install --user --break-system-packages rich questionary

# Option 2: pipx (for CLI applications)
pipx install rich questionary

# Option 3: venv (for projects)
python3 -m venv ~/.venvs/homework
source ~/.venvs/homework/bin/activate
pip install rich questionary
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
2. Or use the Bash version: `./record_homework_EN.sh`

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

**A:** The sop.ase.ro server uses port 1001 for SCP/SSH for security reasons. Some corporate/university networks block port 22.

---

### Q: The upload always fails. What do I do?

**A:** Check in order:
1. **Internet:** `ping google.com`
2. **Port open:** `nc -zv sop.ase.ro 1001`
3. **VPN:** Disconnect temporarily
4. **Firewall:** Try from mobile hotspot

If nothing works, send manually later with the displayed command.

---

### Q: Can I send the file manually?

**A:** Yes:
```bash
scp -P 1001 FILENAME.cast stud-id@sop.ase.ro:/home/HOMEWORKS/SPECIALISATION/
```
Replace FILENAME and SPECIALISATION with your values.

---

### Q: The server is down. When will it be available?

**A:** Contact the instructor. In the meantime, the file is saved locally and you can send it later.

---

## Cryptographic Signature

### Q: What data is included in the signature?

**A:** The signed string contains:
- Surname + First name
- Group
- File size (bytes)
- Date and time
- System username
- Absolute file path

---

### Q: Can I verify the signature?

**A:** Not directly - only the instructor has the private key. You can verify that it exists:
```bash
tail -3 FILENAME.cast
# You should see "## " followed by Base64
```

---

### Q: What happens if I modify the .cast file?

**A:** The signature becomes invalid and the homework will be rejected. The file size is part of the signature, so any modification is detected.

---

### Q: Can I use another student's signature?

**A:** No. The signature includes your system username and file path. Any inconsistency is detected.

---

## Specific Errors

### Q: "ModuleNotFoundError: No module named 'rich'"

**A:**
```bash
pip3 install --user rich
# Or
python3 -m pip install rich
```

---

### Q: "bash: ./record_homework_tui_EN.py: Permission denied"

**A:**
```bash
chmod +x record_homework_tui_EN.py
# Or run with:
python3 record_homework_tui_EN.py
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
