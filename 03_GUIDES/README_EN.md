# Homework Recording System with Asciinema

## Operating Systems 2023-2027 - Revolvix/github.com

**Version:** 1.1.1 | **Date:** January 2025

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
| `check_my_submission.sh` | 🆕 **Verify your submission** before sending | Distributed to students |
| `STUDENT_GUIDE_EN.html` | 📖 **Interactive HTML guide** for students | Distributed to students |
| `STUDENT_GUIDE_EN.md` | 📖 Markdown guide for students | Distributed to students |
| `FAQ_EN.md` | ❓ Frequently asked questions | Distributed to students |
| `CHANGELOG_EN.md` | 📜 Version history | Reference |
| `examples/` | 📁 Sample recordings for preview | Reference |

---

## 🎬 Video Tutorial

*Coming soon: A 3-minute walkthrough showing the complete recording process.*

For now, the ASCII flowchart in [STUDENT_GUIDE_EN.md](STUDENT_GUIDE_EN.md) provides a visual overview. You can also preview a sample recording:

```bash
# Preview the sample recording (requires asciinema)
asciinema play examples/sample_submission_demo.cast
```

---

## ✅ Verification Before Submission

Before sending your homework, verify it locally with our checker script:

```bash
chmod +x check_my_submission.sh
./check_my_submission.sh 1029_SMITH_John_HW03b.cast
```

This checks:
- ✓ File exists and has correct extension
- ✓ File size is reasonable (not truncated)
- ✓ Cryptographic signature is present
- ✓ Filename follows the correct format
- ✓ Content is valid asciinema format

---

## Sample Recording

Want to see what a completed recording looks like? Check `examples/sample_submission_demo.cast`:

```bash
# Preview in terminal (requires asciinema installed)
asciinema play examples/sample_submission_demo.cast

# Or view the raw file structure
head -20 examples/sample_submission_demo.cast
```

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

## 🆕 What's New in Version 1.1.1

- ✅ **Full strict mode** in Bash (`set -euo pipefail` with `IFS`)
- ✅ **Array-based package installation** (safer, no word splitting)
- ✅ **New verification script** (`check_my_submission.sh`)
- ✅ **Sample recording** in `examples/` folder
- ✅ **Improved documentation** with practice run guide
- ✅ **Enhanced troubleshooting** with real instructor anecdotes

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
1. Run `./check_my_submission.sh` to diagnose problems
2. Consult [FAQ_EN.md](FAQ_EN.md) and [STUDENT_GUIDE_EN.md](STUDENT_GUIDE_EN.md)
3. Contact your lab instructor
4. Verify you have the latest version of the scripts

---

*By Revolvix for OPERATING SYSTEMS class | restricted licence 2017-2030*
