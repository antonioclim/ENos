# 🤝 Contribution Guide

## For Instructors Who Wish to Adapt the System

This document explains how to customise the homework recording system for your own course.

---

## Required Modifications for Adaptation

### 1. Generating RSA Keys

Each course should have its own key pair for signatures:

```bash
# Generate private key (keep SECRET!)
openssl genrsa -out homework_private.pem 2048

# Extract public key (goes into scripts)
openssl rsa -in homework_private.pem -pubout -out homework_public.pem

# Verify keys
openssl rsa -in homework_private.pem -check
```

**IMPORTANT:**
- `homework_private.pem` — NEVER in public repository!
- `homework_public.pem` — Included in scripts (safe)

---

### 2. Server Configuration

Modify the constants in both scripts:

**Python (record_homework_tui_EN.py):**
```python
SCP_SERVER: str = "server.university.ac.uk"
SCP_PORT: str = "22"  # or another port
SCP_PASSWORD: str = "course_password"  # or use SSH keys
SCP_BASE_PATH: str = "/path/to/homeworks"
```

**Bash (record_homework_EN.sh):**
```bash
readonly SCP_SERVER="server.university.ac.uk"
readonly SCP_PORT="22"
readonly SCP_PASSWORD="course_password"
readonly SCP_BASE_PATH="/path/to/homeworks"
```

---

### 3. Specialisations/Sections

Modify the specialisations dictionary for your course structure:

**Python:**
```python
SPECIALIZATIONS: Dict[str, Tuple[str, str]] = {
    "1": ("group_A", "Group A - Monday"),
    "2": ("group_B", "Group B - Tuesday"),
    "3": ("group_C", "Group C - Wednesday"),
}
```

**Bash:**
```bash
# In the collect_student_data() function, modify:
echo "   1) group_A  - Group A - Monday"
echo "   2) group_B  - Group B - Tuesday"
echo "   3) group_C  - Group C - Wednesday"
```

---

### 4. File Name Formatting

If you want a different format for the file name:

**Python:**
```python
def generate_filename(data: Dict[str, str]) -> str:
    # Original format: GROUP_SURNAME_FirstName_HWxx.cast
    # Customised: YYYYMMDD_GROUP_SURNAME_homework.cast
    date_str = datetime.now().strftime("%Y%m%d")
    return f"{date_str}_{data['group']}_{data['surname']}_homework{data['homework']}.cast"
```

---

### 5. Public Key in Scripts

Replace the `PUBLIC_KEY` variable with the contents of `homework_public.pem`:

```python
PUBLIC_KEY: str = """-----BEGIN PUBLIC KEY-----
YOUR_KEY_CONTENTS_HERE
-----END PUBLIC KEY-----"""
```

---

## Signature Verification Script

For verifying submitted homework, create a `verify_homework.sh` script:

```bash
#!/bin/bash
# verify_homework.sh - Verify homework signature
# Usage: ./verify_homework.sh homework.cast

set -euo pipefail

PRIVATE_KEY="homework_private.pem"
CAST_FILE="$1"

# Extract signature (last line starting with ##)
SIGNATURE=$(grep "^## " "$CAST_FILE" | tail -1 | cut -d' ' -f2)

if [[ -z "$SIGNATURE" ]]; then
    echo "❌ Missing signature in file!"
    exit 1
fi

# Decode and decrypt
DECRYPTED=$(echo "$SIGNATURE" | base64 -d | openssl pkeyutl -decrypt -inkey "$PRIVATE_KEY")

echo "✅ Valid signature!"
echo "📋 Signed data:"
echo "$DECRYPTED"

# Parse components
IFS=' ' read -r STUDENT GROUP SIZE DATE TIME USER PATH <<< "$DECRYPTED"

echo ""
echo "   Student: $STUDENT"
echo "   Group: $GROUP"
echo "   Size: $SIZE bytes"
echo "   Date: $DATE $TIME"
echo "   User: $USER"

# Verify file size
ACTUAL_SIZE=$(stat -c%s "$CAST_FILE")
# Note: size includes the added signature, so it will be slightly larger
echo ""
echo "   Actual size: $ACTUAL_SIZE bytes"
```

---

## Local Testing

### Without real upload (dry-run)

Comment out the upload section for testing:

```python
# In main():
# upload_success = upload_homework(filepath, data)
upload_success = False  # Simulate failure for local testing
```

### With local SFTP server (Docker)

```bash
# Start an SFTP container for testing
docker run -d \
    --name sftp-test \
    -p 2222:22 \
    -v $(pwd)/test_uploads:/home/stud/HOMEWORKS \
    atmoz/sftp stud:stud:::HOMEWORKS

# Temporarily modify port in script to 2222
# and server to localhost
```

---

## Project Structure

```
02_INIT_TEME_EN/
├── README_EN.md              # Main documentation
├── STUDENT_GUIDE_EN.md       # Detailed student guide
├── STUDENT_GUIDE_EN.html     # HTML version (generated)
├── FAQ_EN.md                 # Frequently asked questions
├── CHANGELOG_EN.md           # Version history
├── CONTRIBUTING_EN.md        # This file
├── record_homework_tui_EN.py # Main Python script
└── record_homework_EN.sh     # Alternative Bash script
```

---

## Generating HTML from Markdown

If you modify `STUDENT_GUIDE_EN.md`, regenerate the HTML:

```bash
# With pandoc
pandoc STUDENT_GUIDE_EN.md -o STUDENT_GUIDE_EN.html --standalone --toc

# With grip (GitHub style preview)
pip install grip
grip STUDENT_GUIDE_EN.md --export STUDENT_GUIDE_EN.html
```

---

## Reporting Issues

For bugs or suggestions:
- Create an Issue in the repository
- Or contact the OS team at the address in the syllabus

---

## Licence

The code is proprietary and intended exclusively for use within the Operating Systems course at ASE Bucharest.

Modifications for personal use are permitted. Public redistribution requires approval.

---

*Operating Systems 2023-2027 - ASE Bucharest*
