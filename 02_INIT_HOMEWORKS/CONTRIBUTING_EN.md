# 🤝 Contribution Guide

> **v6 candidate correction:** Follow the [current recording contract](../03_GUIDES/RECORDING_CONTRACT.md). Practice requires `--offline`; online configuration and the replacement verification protocol remain unresolved. Historical version labels below identify the source edition, not a new release.

## For Instructors Who Wish to Adapt the System

This document explains how to customise the homework recording system for your own course.

---

## Required Modifications for Adaptation

### 1. Generating RSA Keys

This historical encryption-key example does not adopt a signing or key-custody policy; those decisions remain open:

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

The following historical adaptation sketch shows which fields an authorised service owner would need to specify. It is not the active ENos service configuration. The current client still requires an explicit `--port`; changing a source default does not confirm a service or authorise a connection:

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
SCP_PORT="22"  # illustrative value; invocation still requires --port
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

## Historical Raw-Metadata Decoder

The following historical raw-metadata decoder is a teaching example for the 03 footer only. It does not verify recording content, authorship or the 02/SEM07 formats:

```bash
#!/bin/bash
# decoder.sh — decode one legacy 03 metadata token; no authenticity claim
# Usage: bash decoder.sh homework.cast

set -euo pipefail

if [[ $# -ne 1 ]]; then echo "Usage: bash decoder.sh recording.cast" >&2; exit 2; fi
PRIVATE_KEY="homework_private.pem"
CAST_FILE="$1"

# Extract only the legacy 03 raw-token shape, excluding SIG/META and arbitrary text.
TOKEN=$(sed -n 's/^## \([A-Za-z0-9+/=][A-Za-z0-9+/=]*\)$/\1/p' "$CAST_FILE" | tail -n 1)

if [[ -z "$TOKEN" ]]; then
    echo "❌ No supported legacy 03 token found; manual review required."
    exit 1
fi

# Decode and decrypt
if ! DECRYPTED=$(printf '%s' "$TOKEN" | base64 -d | openssl pkeyutl -decrypt -inkey "$PRIVATE_KEY" -pkeyopt rsa_padding_mode:pkcs1); then
    echo "Legacy token could not be decoded; no authenticity conclusion." >&2
    exit 1
fi

echo "Legacy metadata decrypted; content and identity remain UNVERIFIED."
echo "📋 Decrypted metadata labels:"
echo "$DECRYPTED"

# Parse components
IFS=' ' read -r STUDENT GROUP SIZE DATE TIME RECORDED_USER RECORDED_PATH <<< "$DECRYPTED"

echo ""
echo "   Student: $STUDENT"
echo "   Group: $GROUP"
echo "   Size: $SIZE bytes"
echo "   Date: $DATE $TIME"
echo "   User label: $RECORDED_USER"

# Observe current file size; this does not authenticate the recorded bytes
ACTUAL_SIZE=$(stat -c%s -- "$CAST_FILE")
# The current file includes the footer; the encrypted size label predates it.
echo ""
echo "   Actual size: $ACTUAL_SIZE bytes"
```

---

## Local Testing

### Without real upload (dry-run)

Use the supported offline option without editing the source:

```bash
bash record_homework_EN.sh --offline
# Or, in the documented virtual environment:
python record_homework_tui_EN.py --offline
```

Neither path generates a legacy token or attempts a connection/upload. The local regressions use disposable files and transport fixtures; they do not establish live service interoperability.

### Historical local SFTP integration sketch (not executed)

An isolated integration test requires a chosen image version/digest, disposable test credentials and directories, a verified host key and a client configured for that fixture. The historical container example is retained in bounded form below; it is not a recommendation to deploy an institutional service. Set the two required variables deliberately before executing it:

```bash
: "${TEST_SFTP_IMAGE:?Set an explicitly selected atmoz/sftp image tag or digest}"
: "${TEST_SFTP_PASSWORD:?Set a unique disposable test password}"
mkdir -p -- "$PWD/test_uploads"
docker run -d \
    --name enos-sftp-test \
    -p 127.0.0.1:2222:22 \
    -v "$PWD/test_uploads:/home/stud/HOMEWORKS" \
    "$TEST_SFTP_IMAGE" "stud:${TEST_SFTP_PASSWORD}:::HOMEWORKS"
```

Use an isolated test client copy with the fixture hostname/account/path and `--port 2222`, after checking its host key. Preserve the canonical ENos configuration. Container startup, bind-mount ownership, SSH interoperability and cleanup are separate integration checks; none was inferred from the local control-flow fixtures.

---

## Project Structure

```
02_INIT_HOMEWORKS/
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

## Maintaining the interactive student HTML

This folder's `STUDENT_GUIDE_EN.html` is an independently maintained interactive edition with navigation, persistence and copying controls. A generic Markdown export would discard those controls. Apply the same content correction to the Markdown and interactive edition, then check their actual controls and current source hashes. The static export in `../03_GUIDES/` has its own `build_student_guide.py` and canonical Markdown.

---

## Reporting Issues

For bugs or suggestions:
- Create an Issue in the repository
- Or contact the OS team at the address in the syllabus

---

## Licence

The historical text describes proprietary course use. It conflicts with the former MIT package declaration; the canonical grant remains an [author decision](../AUTHOR_DECISIONS.md). This candidate does not resolve that conflict.

Modifications for personal use are permitted. Public redistribution requires approval.

---

*Operating Systems 2023-2027 - ASE Bucharest*
