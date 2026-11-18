# Homework Recording System with Asciinema

## Adopted scope

The current supported profile is local formative practice. Start either maintained recorder with `--offline`, retain the recording and run the local structural checks. Online examples below are conditional technical reference, not an adopted submission route. Institutional operation requires a separately confirmed service contract and native acceptance; no port or legacy envelope is approved by this local profile.


This recording workflow requires **asciinema CLI 2.x**, which writes asciicast v2. The recorder checks `asciinema --version` before starting. CLI 3.x writes an incompatible v3 format and is rejected with an explanation; the scripts do not install or downgrade packages. See the [official v2](https://docs.asciinema.org/manual/asciicast/v2/) and [v3](https://docs.asciinema.org/manual/asciicast/v3/) specifications. Version detection has local regression coverage; native terminal recording remains a separate acceptance check.

> **v6.0.0 recording scope:** Follow the [current recording contract](RECORDING_CONTRACT.md). Practice requires `--offline`; online configuration and the replacement verification protocol remain unresolved. Historical version labels below identify the source edition, not a new release.

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

For now, the numbered workflow in [STUDENT_GUIDE_EN.md](STUDENT_GUIDE_EN.md) provides a visual overview. You can also preview a sample recording:

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
- Supported header/event structure parses; size alone does not prove completeness
- Footer syntax is reported separately; authentication remains UNVERIFIED
- Filename conventions and self-declared metadata are reported separately from authentication
- Supported v2 header/events parse; exit 0 is a format result, not institutional acceptance

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
- 🔄 **Dependency checks** with explicit installation guidance
- 🎬 **Typing effects and visual transitions**

### Download Python TUI version:

**Historical distribution link (not verified as the corrected candidate):** https://drive.google.com/file/d/1YLqNamLCdz6OzF6hlcPr1hr738DIaSYz/view?usp=drive_link

### Running:

```bash
# Make it executable
chmod +x record_homework_tui_EN.py

# Run
python record_homework_tui_EN.py --offline
# or
python record_homework_tui_EN.py --offline
```

The script checks dependencies. Install system commands explicitly and use the virtual environment in the current contract.

---

## For Students

### Download (Bash version - alternative)

**Historical distribution link (not verified as the corrected candidate):** https://drive.google.com/file/d/1dLXPEtGjLo4f9G0Uojd-YXzY7c3ku1Ez/view?usp=drive_link

### Installation

```bash
# Make it executable
chmod +x record_homework_EN.sh
```

### Usage

```bash
bash record_homework_EN.sh --offline
```

The script will:
1. ✅ Check required commands; report missing packages without installing them
2. 📝 Request your details (surname, first name, group, specialisation, homework number)
3. 🎬 Start terminal recording
4. 🛑 Stop when you type `STOP_homework`
5. 🔐 In online mode, generate the legacy token (not a content signature)
6. 📤 Upload only in online mode with an explicitly confirmed port

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

> **Historical deployment note:** the earlier edition referred to a separate `verify_homework.sh` and RSA keys. Their current deployment, custody and distribution channel are not established by this repository. Use the bundled [verification contract](../SEM07/homework_evaluation/VERIFICATION_AND_GRADING_CONTRACT.md); no key distribution has been performed here.

### System Requirements

- Ubuntu 22.04+ or WSL2 with Ubuntu
- Python 3.8+
- Packages: asciinema, openssl, sshpass (install explicitly before recording)

### Server Configuration

The destination server must have:
- SSH port confirmed by the service owner (historical copies disagree: 1001/1002)
- Directories: `/home/HOMEWORKS/{eninfo,grupeid,roinfo}/`
- User: `stud-id` with password `stud`

---

## Support

For issues:
1. Run `bash check_my_submission.sh path/to/your_recording.cast` to inspect the local format
2. Consult [FAQ_EN.md](FAQ_EN.md) and [STUDENT_GUIDE_EN.md](STUDENT_GUIDE_EN.md)
3. Contact your lab instructor
4. Verify you have the latest version of the scripts

---

*By Revolvix for OPERATING SYSTEMS class | restricted licence 2017-2030*
