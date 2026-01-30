# Homework Recording System with Asciinema

## Operating Systems 2023-2027 - Revolvix/github.com

**Version:** 1.1.0 | **Date:** January 2025

---

## 📚 Documentation

| Document | Description |
|----------|-------------|
| [STUDENT_GUIDE_EN.md](STUDENT_GUIDE_EN.md) | 📖 **Complete guide** for students (READ FIRST!) |
| [FAQ_EN.md](FAQ_EN.md) | ❓ Frequently asked questions and quick answers |
| [CHANGELOG_EN.md](CHANGELOG_EN.md) | 📜 Change history |

---

## Package Contents

| File | Description | Target |
|------|-------------|--------|
| `record_homework_tui_EN.py` | 🆕 **Python TUI (Matrix style)** - recommended! | Distributed to students |
| `record_homework_EN.sh` | Bash script for students (alternative) | Distributed to students |
| `STUDENT_GUIDE_EN.html` | 📖 **Interactive HTML guide** for students | Distributed to students |
| `STUDENT_GUIDE_EN.md` | 📖 Markdown guide for students | Distributed to students |
| `FAQ_EN.md` | ❓ Frequently asked questions | Distributed to students |
| `CHANGELOG_EN.md` | 📜 Version history | Reference |

---

## Python TUI Version (RECOMMENDED)

The new Matrix-style Python version includes:
- 🎨 **Beautiful Matrix theme** (green digital rain effect)
- ✨ **Animated spinners and progress bars**
- 🖥️ **Interactive menus** with arrow key navigation
- 🔄 **Auto-installation** of all dependencies
- 🎬 **Typing effects and visual transitions**

### Download Python TUI version:

**Google Drive Link:** https://drive.google.com/file/d/1YLqNamLCdz6OzF6hlcPr1hr738DIaSYz/view?usp=drive_link

### Running:

```bash
# Make it executable
chmod +x record_homework_tui_EN.py

# Run
./record_homework_tui_EN.py
# or
python3 record_homework_tui_EN.py
```

The script automatically installs: `rich`, `questionary` (Python) + `asciinema`, `openssl`, `sshpass` (system)

---

## For Students

### Download (Bash version - alternative)

**Google Drive Link:** https://drive.google.com/file/d/1dLXPEtGjLo4f9G0Uojd-YXzY7c3ku1Ez/view?usp=drive_link

### Installation

```bash
# Make it executable
chmod +x record_homework_EN.sh
```

### Usage

```bash
./record_homework_EN.sh
```

The script will:
1. ✅ Automatically install required packages (asciinema, openssl, sshpass)
2. 📝 Request your details (surname, first name, group, specialisation, homework number)
3. 🎬 Start terminal recording
4. 🛑 Stop when you type `STOP_homework`
5. 🔐 Generate a cryptographic signature
6. 📤 Automatically upload to server

### Requested Data Format

| Field | Format | Example |
|-------|--------|---------|
| Surname | Letters, hyphen (becomes UPPERCASE) | `SMITH-JONES` |
| First name | Letters, hyphen (becomes Title Case) | `John-Paul` |
| Group | Exactly 4 digits | `1029` |
| Specialisation | 1=eninfo, 2=grupeid, 3=roinfo | `1` |
| Homework number | 01-07 + letter | `03b` |

### Generated File Name

Format: `[Group]_[SURNAME]_[FirstName]_HW[Number].cast`

Example: `1029_SMITH_John_HW03b.cast`

---

## 🆕 What's New in Version 1.1.0

- ✅ **Complete strict mode** in Bash (`set -euo pipefail`)
- ✅ **Type hints** throughout all Python code
- ✅ **Extended FAQ** with 40+ frequently asked questions
- ✅ **Troubleshooting** with 20+ problem scenarios
- ✅ **Expected output** after each command in the guide
- ✅ **Process diagram** for recording workflow
- ✅ **Improved documentation** with encouraging language

See [CHANGELOG_EN.md](CHANGELOG_EN.md) for the complete list of changes.

---

## For Instructors

> **Note:** Verification scripts (`verify_homework.sh`) and RSA keys 
> (`homework_private.pem`, `homework_public.pem`) are distributed separately through the secure channel.

### System Requirements

- Ubuntu 22.04+ or WSL2 with Ubuntu
- Python 3.8+
- Packages: asciinema, openssl, sshpass (installed automatically)

### Server Configuration

The destination server must have:
- SSH on port 1001
- Directories: `/home/HOMEWORKS/{eninfo,grupeid,roinfo}/`
- User: `stud-id` with password `stud`

---

## Support

For issues:
1. Consult [FAQ_EN.md](FAQ_EN.md) and [STUDENT_GUIDE_EN.md](STUDENT_GUIDE_EN.md)
2. Contact your lab instructor
3. Verify you have the latest version of the scripts

---

*By Revolvix for OPERATING SYSTEMS class | restricted licence 2017-2030*
