# S03_TC05 - File Permissions and Ownership

> **Operating Systems** | Bucharest UES - CSIE  
> Laboratory material - Seminar 3 (Redistributed)

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
- Understand the Unix permission system
- Modify permissions with chmod (octal and symbolic)
- Manage ownership with chown and chgrp
- Use special permissions (SUID, SGID, Sticky)

---


## 2. Viewing Permissions

```bash
# List with permissions
ls -l file.txt
ls -la                    # include hidden files
ls -ld directory/         # directory permissions (not contents)

# Output interpretation
# -rw-r--r-- = 644
#
# others: r-- = 4 (read only)
# group: r-- = 4 (read only)
# owner: rw- = 6 (read + write)

# Detailed information
stat file.txt
stat -c "%a %U:%G %n" file.txt    # custom format
```

---

## 3. chmod - Modifying Permissions

### 3.1 Octal Mode (Numeric)

```bash
# Format: chmod [options] NNN file
# NNN = 3 octal digits (owner, group, others)

# Common examples
chmod 755 script.sh     # rwxr-xr-x (executable)
chmod 644 document.txt  # rw-r--r-- (document)
chmod 600 secret.txt    # rw------- (private)
chmod 700 private/      # rwx------ (private directory)
chmod 777 public/       # rwxrwxrwx (full access - AVOID!)

# Octal calculation
# r=4, w=2, x=1
# rwx = 4+2+1 = 7
# rw- = 4+2+0 = 6
# r-x = 4+0+1 = 5
# r-- = 4+0+0 = 4
```

### 3.2 Symbolic Mode

```bash
# Format: chmod [ugoa][+-=][rwxXst] file

# Operators
# + add permission
# - remove permission
# = set exactly

# Examples
chmod u+x script.sh         # add execute for owner
chmod g-w file.txt          # remove write for group
chmod o=r file.txt          # set others to read only
chmod a+r file.txt          # add read for all
chmod u=rwx,g=rx,o=r f.txt  # complete setting
chmod go-rwx private.txt    # remove everything for group and others

# Recursive
chmod -R 755 directory/     # apply recursively
chmod -R u+rwX,go+rX dir/   # X = execute only for directories
```

### 3.3 Permissions for Directories

```bash
# Accessible directory
chmod 755 public/           # Everyone can list and access

# Private directory
chmod 700 private/          # Only owner can access

# Shared directory (group)
chmod 775 shared/           # Owner and group can modify

# Read-only directory
chmod 555 readonly/         # Nobody can modify
```

---

## 4. chown and chgrp - Modifying Ownership

### 4.1 chown - Change Owner

```bash
# Format: chown [options] owner[:group] file

# Change owner
sudo chown john file.txt

# Change owner and group
sudo chown john:developers file.txt

# Group only (with :)
sudo chown :developers file.txt

# Recursive
sudo chown -R john:developers project/

# Verbose
sudo chown -v john file.txt

# Reference (copy from another file)
sudo chown --reference=model.txt target.txt
```

### 4.2 chgrp - Change Group

```bash
# Format: chgrp [options] group file

chgrp developers file.txt
chgrp -R developers project/
```

### 4.3 Verifying Groups

```bash
# Current user's groups
groups
groups username

# All groups in system
cat /etc/group

# Add user to group (admin)
sudo usermod -aG developers john
```

---

## 5. umask - Default Permission Mask

### 5.1 How It Works

```bash
# umask defines what permissions are REMOVED from default
# Default files: 666 (rw-rw-rw-)
# Default directories: 777 (rwxrwxrwx)

# Effective permissions calculation:
# Files: 666 - umask
# Directories: 777 - umask

# Example with umask 022:
# Files: 666 - 022 = 644 (rw-r--r--)
# Directories: 777 - 022 = 755 (rwxr-xr-x)

# Example with umask 077:
# Files: 666 - 077 = 600 (rw-------)
# Directories: 777 - 077 = 700 (rwx------)
```

### 5.2 Setting umask

```bash
# Check current umask
umask           # displays in octal
umask -S        # displays symbolic

# Temporary setting
umask 022       # common default
umask 077       # very restrictive
umask 002       # permissive for group

# Permanent setting (in ~/.bashrc)
echo "umask 022" >> ~/.bashrc
```

---

## 6. Special Permissions

### 6.1 SUID (Set User ID) - 4xxx

```bash
# File executes with owner's permissions
# Displayed as 's' instead of 'x' for owner

chmod u+s program           # set SUID
chmod 4755 program          # octal

# Example: passwd
ls -l /usr/bin/passwd
# -rwsr-xr-x 1 root root ... /usr/bin/passwd
# Anyone can change password (requires access to /etc/shadow)

# Check SUID files
find / -perm -4000 2>/dev/null
```

### 6.2 SGID (Set Group ID) - 2xxx

```bash
# On files: executes with group's permissions
# On directories: new files inherit directory's group

chmod g+s directory/        # set SGID
chmod 2775 shared/          # octal

# Example: shared project directory
mkdir /projects/team1
chgrp developers /projects/team1
chmod 2775 /projects/team1
# All new files will belong to "developers" group
```

### 6.3 Sticky Bit - 1xxx

```bash
# On directories: only owner can delete their own files
# Displayed as 't' instead of 'x' for others

chmod +t /tmp               # set sticky
chmod 1777 /tmp             # octal

# Example: /tmp
ls -ld /tmp
# drwxrwxrwt 15 root root ... /tmp
# 't' indicates sticky bit

# Check sticky bit
find / -perm -1000 2>/dev/null
```

### 6.4 Special Permissions Summary

| Bit | Octal | On File | On Directory |
|-----|-------|---------|--------------|
| SUID | 4000 | Execute as owner | - |
| SGID | 2000 | Execute as group | Group inheritance |
| Sticky | 1000 | - | Only owner deletes |

```bash
# Octal examples
chmod 4755 file     # SUID + rwxr-xr-x
chmod 2775 dir      # SGID + rwxrwxr-x
chmod 1777 dir      # Sticky + rwxrwxrwx
chmod 6755 file     # SUID + SGID + rwxr-xr-x
```

---

## 7. Practical Exercises

### Exercise 1: Basic Permissions
```bash
# Create test files
touch public.txt private.txt script.sh

# Set permissions
chmod 644 public.txt      # rw-r--r--
chmod 600 private.txt     # rw-------
chmod 755 script.sh       # rwxr-xr-x

# Verify
ls -l
```

### Exercise 2: Shared Directory
```bash
# Create directory for team
sudo mkdir /shared
sudo chgrp developers /shared
sudo chmod 2775 /shared

# Test
touch /shared/test.txt
ls -l /shared/
```

### Exercise 3: umask
```bash
# Save current umask
OLD_UMASK=$(umask)

# Test different values
umask 077
touch restrictive.txt
ls -l restrictive.txt

umask 022
touch normal.txt
ls -l normal.txt

# Restore
umask $OLD_UMASK
```

---

## 8. Verification Questions

1. **What does permission 755 mean for a directory?**
   > Owner: rwx (full), Group: r-x (list+enter), Others: r-x (list+enter)

2. **Why is x permission needed on a directory?**
   > To be able to access (cd) the directory and files within it.

3. **What does SGID do on a directory?**
   > New files automatically inherit the directory's group.

4. **What is Sticky Bit used for on /tmp?**
   > Prevents deletion of others' files, even though directory is world-writable.

5. **What permissions will a new file have with umask 027?**
   > 666 - 027 = 640 (rw-r-----)

---

## Cheat Sheet

```bash
# CHMOD OCTAL
chmod 755 file      # rwxr-xr-x
chmod 644 file      # rw-r--r--
chmod 600 file      # rw-------
chmod 700 dir       # rwx------

# CHMOD SYMBOLIC
chmod u+x file      # +execute owner
chmod g-w file      # -write group
chmod o=r file      # others=read
chmod a+r file      # +read all
chmod -R 755 dir/   # recursive

# OWNERSHIP
chown user file
chown user:group file
chown -R user:group dir/
chgrp group file

# UMASK
umask               # display
umask 022           # set
umask -S            # symbolic

# SPECIAL
chmod u+s file      # SUID (4xxx)
chmod g+s dir       # SGID (2xxx)
chmod +t dir        # Sticky (1xxx)

# FIND BY PERMISSIONS
find . -perm 644
find . -perm -4000  # SUID files
find . -perm /u+x   # owner executable
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
   - Generate the cryptographic signature
   - Automatically upload the file to the server

3. **Check the final message**:
   - ✅ `UPLOAD SUCCESSFUL!` - the assignment was submitted
   - ❌ If upload fails, the `.cast` file is saved locally - send it manually later with the displayed command

> ⚠️ **DO NOT modify the `.cast` file** after generation - the signature becomes invalid!

---

*By Revolvix for OPERATING SYSTEMS class | restricted licence 2017-2030*
