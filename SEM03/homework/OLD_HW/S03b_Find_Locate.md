# S03_TC01 - Find and Locate

> **Evidence limit:** local recordings, logs and hashes can support review of a submitted session; they do not prove authorship, uninterrupted capture or the absence of edited/omitted activity. Privacy, retention and assessment consequences remain subject to the approved course policy.

> **Operating Systems** | Bucharest UES - CSIE  
> Laboratory material - Seminar 3 (SPLIT from TC2e - Redistributed)

---

> 🚨 **BEFORE STARTING THE ASSIGNMENT**
>
> 1. Download and configure the `002HWinit` package (see STUDENT_GUIDE_EN.md)
> 2. Open a terminal and navigate to `~/HOMEWORKS`
> 3. Start recording with:
>    ```bash
>    python3 record_homework_tui_RO.py
>    ```
>    or the Bash version:
>    ```bash
>    ./record_homework_RO.sh
>    ```
> 4. Complete the required data (name, group, assignment no.)
> 5. **ONLY THEN** start solving the requirements below

---

## Objectives

At the end of this laboratory, the student will be able to:
- Use the `find` command for complex file searches
- Use `locate` for quick searches in the database
- Understand the differences between find and locate
- Combine search criteria efficiently

---


## 2. The locate Command

### 2.1 Basic Usage

```bash
# Quick search in database
locate filename
locate "*.pdf"

# Case-insensitive
locate -i README

# Limit results
locate -n 10 "*.log"

# Count matches
locate -c "*.txt"
```

### 2.2 Updating the Database

```bash
# Manual update (requires root)
sudo updatedb

# Check when it was last updated
stat /var/lib/mlocate/mlocate.db
```

### 2.3 Comparison locate vs find

| Aspect | locate | find |
|--------|--------|------|
| Speed | Very fast | Slower |
| Update | Requires updatedb | Real-time |
| Criteria | Name only | Many criteria |
| Actions | Display only | Multiple actions |
| Resources | Uses indexed database | Traverses filesystem |

---

## 3. Complementary Utilities

### 3.1 which and whereis

```bash
which python            # executable path
which -a python         # all versions in PATH

whereis ls              # binaries, sources, manuals
whereis -b python       # binaries only
```

### 3.2 type and file

```bash
type cd                 # shell builtin
type ls                 # /usr/bin/ls
type ll                 # alias

file document.pdf       # PDF document
file script.sh          # shell script
file /bin/ls            # ELF executable
```

---

## 4. Practical Exercises

### Exercise 1: Searches with find
```bash
# .log files larger than 10MB
find /var/log -type f -name "*.log" -size +10M

# Files modified in the last 24h
find ~ -type f -mtime 0

# Preview owned temporary files at least eight complete days old
find ./owned_temp -type f -name "*.tmp" -mtime +7 -print
# Apply only after inspecting this disposable fixture: use -delete instead of -print.
```

### Exercise 2: Find and process
```bash
# All scripts without execute permission
find . -name "*.sh" ! -perm /111

# Empty directories for cleanup
find . -type d -empty -print

# Equal-size candidate groups (not proof of duplicate content).
# GNU sort/uniq -z preserve filename bytes, including spaces and newlines.
find . -type f -printf '%020s %p\0' | LC_ALL=C sort -z |
    uniq -z -D -w 20
# %020s is find's zero-padded byte-size field, not a filename prefix.
# Compare content separately before calling candidates duplicates or deleting anything.
```

---

## Find Cheat Sheet

```bash
# NAME SEARCH
find . -name "*.txt"      # exact
find . -iname "*.txt"     # case-insensitive
find . -path "*dir*"      # in full path

# TYPE SEARCH
find . -type f            # files
find . -type d            # directories
find . -type l            # symlinks

# SIZE SEARCH
find . -size +10M         # > 10MB
find . -size -1024c       # 0–1023 bytes; -size -1k matches only empty files
find . -empty             # empty

# TIME SEARCH
find . -mtime -7          # last 7 days
find . -mmin -60          # last hour
find . -newer file        # newer than file

# ACTIONS
find . -exec cmd {} \;    # execute per file
find . -exec cmd {} +     # execute batch
find . -delete            # delete
find . -print0            # output null-delimited
```

---

## 📤 Completion and Submission

After you have completed all requirements:

1. **Stop recording** by typing:
   ```bash
   STOP_tema
   ```
   or press `Ctrl+D`

2. **Wait** - the script will:
   - Finalise the legacy recorder metadata envelope (not a content signature)
   - Automatically upload the file to the server

3. **Check the final message**:
   - ✅ `UPLOAD SUCCESSFUL!` - the assignment was submitted
   - ❌ If upload fails, the `.cast` file is saved locally - send it manually later with the displayed command

> Keep the original `.cast` as evidence. The distributed recorder envelopes do not
> bind event content and do not authenticate the student. Local preflight exit 0
> establishes format only (`UNVERIFIED` authentication, `UNCONFIRMED` readiness).
> The separate SEM07 `# SIGNATURE:` contract binds a content digest only when it
> verifies with an explicitly supplied key; identity and institutional acceptance
> still require an approved protocol. See the [current recording contract](../../../03_GUIDES/RECORDING_CONTRACT.md)
> and [verification contract](../../../SEM07/homework_evaluation/VERIFICATION_AND_GRADING_CONTRACT.md).

---

*By Revolvix for OPERATING SYSTEMS class | restricted licence 2017-2030*
