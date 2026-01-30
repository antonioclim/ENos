# Operating Systems - Week 13: Security in Operating Systems

> **by Revolvix** | ASE Bucharest - CSIE | Year I, Semester 2 | 2025-2026

---

## Week Objectives

After completing this week's materials, you will be able to:

1. **Differentiate** between authentication, authorisation and audit (the AAA triad)
2. Explain the Unix permissions system and **configure** permissions correctly
3. **Use** Access Control Lists (ACL) for advanced scenarios
4. Compare access control models: DAC, MAC, RBAC
5. **Apply** fundamental security principles in system administration
6. **Identify** common vulnerabilities and protection measures

---

## Applied Context (didactic scenario): How was the SolarWinds attack possible?

In December 2020, it was discovered that hackers (attributed to Russian intelligence services) compromised the build process of SolarWinds Orion - an IT management software used by thousands of organisations, including American government agencies. The "legitimate" update, digitally signed, installed backdoors on approximately 18,000 systems.

What OS security lessons can we extract?

1. **Principle of least privilege** - Build processes had too many permissions
2. **Chain of trust integrity** - Code signing is not sufficient if the attacker controls the build
3. **Defence in depth** - A single point of failure compromised thousands of systems
4. **Auditing** - The breach remained undetected for months

> 💡 **Think about it**: What would have happened if the build server ran with minimal permissions and every modification was automatically audited?

---

## Course Content (13/14)

### 1. The AAA Triad: The Foundation of Security

#### Formal Definition

> System security is based on three fundamental pillars: **Authentication** (who are you?), **Authorisation** (what can you do?) and **Audit** (what did you do?). Together, they form the **AAA triad**.

#### The Three Pillars in Detail

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              AAA TRIAD                                       │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │                     1. AUTHENTICATION                                │    │
│  │                     "WHO ARE YOU?"                                   │    │
│  ├─────────────────────────────────────────────────────────────────────┤    │
│  │                                                                      │    │
│  │  Authentication factors:                                            │    │
│  │                                                                      │    │
│  │  ┌───────────────────────────────────────────────────────────────┐  │    │
│  │  │ Something you KNOW    │ Password, PIN, secret answer          │  │    │
│  │  │ Something you HAVE    │ Smart card, token, phone (2FA)        │  │    │
│  │  │ Something you ARE     │ Fingerprint, iris, voice (biometric)  │  │    │
│  │  │ Somewhere you ARE     │ GPS location, IP address              │  │    │
│  │  └───────────────────────────────────────────────────────────────┘  │    │
│  │                                                                      │    │
│  │  Linux:                                                              │    │
│  │  - /etc/passwd: User information (public)                           │    │
│  │  - /etc/shadow: Password hashes (root only)                         │    │
│  │  - SSH keys: Passwordless authentication                            │    │
│  │  - PAM: Pluggable Authentication Modules                            │    │
│  │                                                                      │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │                     2. AUTHORISATION                                 │    │
│  │                     "WHAT CAN YOU DO?"                               │    │
│  ├─────────────────────────────────────────────────────────────────────┤    │
│  │                                                                      │    │
│  │  After authentication, the system verifies WHAT you are allowed     │    │
│  │  to do:                                                              │    │
│  │                                                                      │    │
│  │  - File permissions (rwx)                                           │    │
│  │  - Access Control Lists (ACL)                                       │    │
│  │  - Capabilities (granular permissions)                              │    │
│  │  - Namespace isolation (containers)                                 │    │
│  │  - SELinux/AppArmor policies (MAC)                                  │    │
│  │                                                                      │    │
│  │  Key question: "Is user X authorised to do Y on Z?"                 │    │
│  │                                                                      │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │                        3. AUDIT                                      │    │
│  │                     "WHAT DID YOU DO?"                               │    │
│  ├─────────────────────────────────────────────────────────────────────┤    │
│  │                                                                      │    │
│  │  Recording actions for:                                             │    │
│  │  - Breach detection                                                 │    │
│  │  - Forensic investigations                                          │    │
│  │  - Compliance                                                       │    │
│  │  - Security improvement                                             │    │
│  │                                                                      │    │
│  │  Linux logs:                                                         │    │
│  │  - /var/log/auth.log: Authentications (login, sudo, ssh)           │    │
│  │  - /var/log/syslog: System events                                   │    │
│  │  - /var/log/audit/audit.log: Linux Audit Framework                 │    │
│  │  - journalctl: Systemd journal                                      │    │
│  │                                                                      │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

#### Practical Verification: Audit in Action

```bash
# View authentication attempts
sudo cat /var/log/auth.log | tail -20

# Or with journalctl
journalctl -u sshd --since "1 hour ago"

# Who is logged in now?
who
w

# Last logins
last | head -20

# Failed login attempts
sudo lastb | head -10
```

---

### 2. The Unix Permissions System

#### Formal Definition

> In Unix/Linux, each file and directory has associated **permissions** that control who can **read**, **write** or **execute**. Permissions apply to three categories: **owner**, **group** and **others**.

#### Anatomy of Permissions

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                     ANATOMY OF ls -l OUTPUT                                  │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  $ ls -l /home/user/script.sh                                               │
│                                                                              │
│  -rwxr-xr-x  1  user  developers  2048  Jan 15 10:30  script.sh             │
│  │└┬┘└┬┘└┬┘  │   │       │        │          │            │                 │
│  │ │  │  │   │   │       │        │          │            └── File name     │
│  │ │  │  │   │   │       │        │          └── Modification date          │
│  │ │  │  │   │   │       │        └── Size (bytes)                          │
│  │ │  │  │   │   │       └── Owner group                                    │
│  │ │  │  │   │   └── Owner user                                             │
│  │ │  │  │   └── Number of hard links                                       │
│  │ │  │  │                                                                   │
│  │ │  │  └── OTHERS: r-x = read (4) + execute (1) = 5                       │
│  │ │  └── GROUP: r-x = read (4) + execute (1) = 5                           │
│  │ └── OWNER: rwx = read (4) + write (2) + execute (1) = 7                  │
│  │                                                                           │
│  └── TYPE: - regular, d directory, l symlink, b/c device                    │
│                                                                              │
│  Permissions in octal: 755                                                   │
│                                                                              │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│                         PERMISSIONS TABLE                                    │
│                                                                              │
│  ┌────────────┬────────┬───────────────────────────────────────────────┐    │
│  │ Permission │ Value  │ For FILE               │ For DIRECTORY        │    │
│  ├────────────┼────────┼────────────────────────┼──────────────────────┤    │
│  │     r      │    4   │ Read contents          │ List contents        │    │
│  │     w      │    2   │ Modify contents        │ Create/delete files  │    │
│  │     x      │    1   │ Execute as program     │ Access (cd into)     │    │
│  │     -      │    0   │ No permission          │ No permission        │    │
│  └────────────┴────────┴────────────────────────┴──────────────────────┘    │
│                                                                              │
│  Common examples:                                                            │
│  644 (rw-r--r--): Text file, everyone reads, owner writes                   │
│  755 (rwxr-xr-x): Executable script, everyone runs, owner modifies          │
│  700 (rwx------): Private, only owner has access                            │
│  666 (rw-rw-rw-): Everyone writes (DANGEROUS!)                              │
│  777 (rwxrwxrwx): Full access (VERY DANGEROUS!)                             │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

#### Special Permissions: setuid, setgid, sticky bit

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        SPECIAL PERMISSIONS                                   │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  1. SETUID (Set User ID) - for executables                                  │
│  ───────────────────────────────────────────────                             │
│                                                                              │
│  When an executable has setuid, it runs with the OWNER's permissions,       │
│  not those of the user who launches it.                                     │
│                                                                              │
│  $ ls -l /usr/bin/passwd                                                    │
│  -rwsr-xr-x 1 root root 68208 ... /usr/bin/passwd                           │
│     ^                                                                        │
│     └── 's' instead of 'x' = setuid active                                  │
│                                                                              │
│  Why? The `passwd` command must modify /etc/shadow (owned by root),         │
│  but is run by normal users.                                                │
│                                                                              │
│  ⚠️  MAJOR RISK: If the setuid program has a vulnerability,                 │
│      the attacker can obtain root privileges!                               │
│                                                                              │
│  ════════════════════════════════════════════════════════════════════════   │
│                                                                              │
│  2. SETGID (Set Group ID)                                                    │
│  ───────────────────────────                                                 │
│                                                                              │
│  For executables: Runs with the owner GROUP's permissions.                  │
│  For directories: New files inherit the directory's group.                  │
│                                                                              │
│  $ ls -l /usr/bin/write                                                     │
│  -rwxr-sr-x 1 root tty 19024 ... /usr/bin/write                             │
│         ^                                                                    │
│         └── 's' in group = setgid active                                    │
│                                                                              │
│  Useful for collaborative directories:                                      │
│  $ chmod g+s /shared/project/                                               │
│  All files created in /shared/project/ will have the "project" group       │
│                                                                              │
│  ════════════════════════════════════════════════════════════════════════   │
│                                                                              │
│  3. STICKY BIT - for directories                                            │
│  ─────────────────────────────────────                                       │
│                                                                              │
│  In a directory with sticky bit, users can delete ONLY                      │
│  files they own, even if they have write permission.                        │
│                                                                              │
│  $ ls -ld /tmp                                                              │
│  drwxrwxrwt 15 root root 4096 ... /tmp                                      │
│          ^                                                                   │
│          └── 't' = sticky bit active                                        │
│                                                                              │
│  Without sticky bit on /tmp, anyone could delete others' files!             │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

#### Commands for Permissions

```bash
# Change permissions (chmod)
chmod 755 script.sh           # Numeric
chmod u+x script.sh           # Symbolic: add execute for user
chmod g-w file.txt            # Symbolic: remove write for group
chmod o=r file.txt            # Symbolic: set others to read only
chmod a+r file.txt            # Symbolic: add read for all

# Special permissions
chmod u+s program             # setuid
chmod g+s directory           # setgid for directory
chmod +t /shared              # sticky bit

chmod 4755 program            # setuid + 755 (4xxx)
chmod 2755 directory          # setgid + 755 (2xxx)
chmod 1777 /tmp               # sticky + 777 (1xxx)

# Change owner/group (chown, chgrp)
sudo chown alice file.txt           # Change owner
sudo chown alice:developers file.txt # Change owner and group
sudo chgrp developers file.txt      # Change group only

# Default permissions (umask)
umask                         # Display current umask
umask 022                     # Set: new files = 644, directories = 755
umask 077                     # Restrictive: only owner has access
```

#### Umask: Controlling Default Permissions

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              UMASK                                           │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  Umask = "mask" that is subtracted from maximum permissions                 │
│                                                                              │
│  Maximum permissions:                                                        │
│  - Files: 666 (rw-rw-rw-)  - no execute by default                          │
│  - Directories: 777 (rwxrwxrwx)                                              │
│                                                                              │
│  Calculation: Final permission = Max - Umask                                 │
│                                                                              │
│  ┌──────────────────────────────────────────────────────────────────────┐   │
│  │ Umask │ New file   │ New directory │ Description                     │   │
│  ├───────┼────────────┼───────────────┼─────────────────────────────────┤   │
│  │  022  │    644     │     755       │ Standard (group/others: no write)│  │
│  │  027  │    640     │     750       │ More restrictive for others     │   │
│  │  077  │    600     │     700       │ Private (owner only)            │   │
│  │  002  │    664     │     775       │ Collaborative (group can write) │   │
│  │  000  │    666     │     777       │ Permissive (INSECURE!)          │   │
│  └──────────────────────────────────────────────────────────────────────┘   │
│                                                                              │
│  Example with umask 022:                                                     │
│  - File: 666 - 022 = 644 (rw-r--r--)                                        │
│  - Directory: 777 - 022 = 755 (rwxr-xr-x)                                   │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

### 3. Access Control Lists (ACL): Beyond rwx

#### Formal Definition

> **ACL (Access Control List)** extends the traditional Unix permissions model, allowing the definition of permissions for **multiple users and groups** on the same file, not just owner/group/others.

#### Why Do We Need ACL?

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    LIMITATIONS OF TRADITIONAL PERMISSIONS                    │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  SCENARIO:                                                                   │
│  File: project.doc                                                          │
│  - Alice (owner) can read and write                                         │
│  - The "developers" group can read                                          │
│  - Bob (not in developers) needs to read                                    │
│  - Carol (from developers) needs to write                                   │
│                                                                              │
│  With traditional permissions: IMPOSSIBLE!                                  │
│  - You cannot give individual permissions to Bob                            │
│  - You cannot give different permissions to members of the same group       │
│                                                                              │
│  Poor solutions:                                                             │
│  1. Add Bob to developers → gets access to ALL group files                  │
│  2. Make the file world-readable → everyone reads                           │
│  3. Create new group for each combination → group explosion                 │
│                                                                              │
│  Good solution: ACL                                                          │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

#### Using ACL

```bash
# Check ACL support (ext4 has it by default)
mount | grep acl

# View ACL
getfacl project.doc

# Output:
# # file: project.doc
# # owner: alice
# # group: developers
# user::rw-
# user:bob:r--           ← Bob can read
# user:carol:rw-         ← Carol can read and write
# group::r--
# group:managers:r--     ← The managers group can read
# mask::rw-              ← Maximum effective permission
# other::---

# Set ACL for specific user
setfacl -m u:bob:r project.doc        # Bob: read
setfacl -m u:carol:rw project.doc     # Carol: read+write

# Set ACL for group
setfacl -m g:managers:r project.doc

# Default ACL for directories (applies to new files)
setfacl -d -m g:developers:rwx /shared/project/

# Delete ACL
setfacl -x u:bob project.doc          # Delete ACL for Bob
setfacl -b project.doc                # Delete ALL ACLs

# Copy ACL from another file
getfacl source.doc | setfacl --set-file=- target.doc
```

#### The "+" Indicator in ls -l

```bash
$ ls -l
-rw-rw-r--+ 1 alice developers 1024 Jan 15 project.doc
          ^
          └── '+' indicates the presence of ACLs!

# Without '+' = only traditional permissions
# With '+' = has ACLs set
```

---

### 4. Access Control Models: DAC, MAC, RBAC

#### Conceptual Comparison

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                      ACCESS CONTROL MODELS                                   │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  1. DAC - Discretionary Access Control                                       │
│  ──────────────────────────────────────────                                  │
│                                                                              │
│  WHO DECIDES: The resource owner                                            │
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │              Alice (owner)                                           │    │
│  │                  │                                                   │    │
│  │      "I decide who has access to my files"                          │    │
│  │                  │                                                   │    │
│  │          ┌───────┴───────┐                                          │    │
│  │          ▼               ▼                                          │    │
│  │     [file.txt]      [private.doc]                                   │    │
│  │     chmod 644       chmod 600                                       │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                                                              │
│  Example: Traditional Unix permissions                                      │
│  ✅ Flexible, easy to understand                                            │
│  ❌ User can make mistakes (chmod 777)                                      │
│  ❌ Does not prevent data exfiltration                                      │
│                                                                              │
│  ════════════════════════════════════════════════════════════════════════   │
│                                                                              │
│  2. MAC - Mandatory Access Control                                           │
│  ──────────────────────────────────────                                      │
│                                                                              │
│  WHO DECIDES: System administrator / central policy                         │
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │         SYSTEM POLICY (defined by admin)                             │    │
│  │                     │                                                │    │
│  │     "Users CANNOT change the rules"                                 │    │
│  │                     │                                                │    │
│  │         ┌───────────┴───────────┐                                   │    │
│  │         ▼                       ▼                                   │    │
│  │   [CONFIDENTIAL]          [PUBLIC]                                  │    │
│  │   Only clearance=secret   Anyone reads                              │    │
│  │   Owner CANNOT                                                      │    │
│  │   change classification!                                            │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                                                              │
│  Example: SELinux, AppArmor                                                 │
│  ✅ Prevents user mistakes                                                  │
│  ✅ Applies system-level policies                                           │
│  ❌ Complex to configure                                                    │
│  ❌ Can block legitimate applications                                       │
│                                                                              │
│  ════════════════════════════════════════════════════════════════════════   │
│                                                                              │
│  3. RBAC - Role-Based Access Control                                         │
│  ────────────────────────────────────────                                    │
│                                                                              │
│  WHO DECIDES: Roles associated with the user                                │
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │                      ROLES                                           │    │
│  │         ┌──────────────────────────────────────┐                    │    │
│  │         │                                      │                    │    │
│  │    [developer]  [dba]   [auditor]  [admin]    │                    │    │
│  │         │        │         │          │       │                    │    │
│  │         ▼        ▼         ▼          ▼       │                    │    │
│  │      code.git  database  logs     everything  │                    │    │
│  │                                               │                    │    │
│  │    Alice has the "developer" role → access to code                 │    │
│  │    Bob has "developer" + "dba" roles → access to code + db         │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                                                              │
│  Example: sudo, Kubernetes RBAC, AWS IAM                                    │
│  ✅ Scalable (add roles, not individual permissions)                        │
│  ✅ Easy to audit ("who has role X?")                                       │
│  ❌ Requires careful role planning                                          │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

#### SELinux vs AppArmor (MAC in Linux)

| Aspect | SELinux | AppArmor |
|--------|---------|----------|
| **Complexity** | Very complex | Simpler |
| **Policies** | Label-based | Path-based |
| **Distributions** | RHEL, CentOS, Fedora | Ubuntu, Debian, SUSE |
| **Granularity** | Very fine | Medium |
| **Learning curve** | Steep | Moderate |

```bash
# Check SELinux state
getenforce
# Enforcing / Permissive / Disabled

# Check AppArmor
sudo aa-status

# Temporary SELinux switch
sudo setenforce 0   # Permissive (logs but does not block)
sudo setenforce 1   # Enforcing (blocks)
```

---

### 5. Fundamental Security Principles

#### The Four Essential Principles

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    SECURITY PRINCIPLES                                       │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  1. LEAST PRIVILEGE                                                          │
│  ──────────────────────────────────────                                      │
│                                                                              │
│  "Give each process/user ONLY the permissions necessary                     │
│   to accomplish their task, nothing more."                                  │
│                                                                              │
│  ❌ Wrong:                                                                   │
│     - Web server runs as root                                               │
│     - Backup script has write permission everywhere                         │
│     - All employees have admin access                                       │
│                                                                              │
│  ✅ Correct:                                                                 │
│     - Web server runs as www-data, access only to /var/www                  │
│     - Backup: read on sources, write only on destination                    │
│     - Employees have access only to what they need                          │
│                                                                              │
│  ════════════════════════════════════════════════════════════════════════   │
│                                                                              │
│  2. DEFENCE IN DEPTH                                                         │
│  ──────────────────────────────────────────────                              │
│                                                                              │
│  "Do not rely on a single layer of security.                                │
│   If one fails, others must compensate."                                    │
│                                                                              │
│  Defence layers:                                                             │
│                                                                              │
│       ┌─────────────────────────────────────────┐                           │
│       │           PERIMETER FIREWALL            │ Layer 1                   │
│       │  ┌───────────────────────────────────┐  │                           │
│       │  │        INTERNAL FIREWALL          │  │ Layer 2                   │
│       │  │  ┌─────────────────────────────┐  │  │                           │
│       │  │  │     FILE PERMISSIONS        │  │  │ Layer 3                   │
│       │  │  │  ┌───────────────────────┐  │  │  │                           │
│       │  │  │  │   DATA ENCRYPTION     │  │  │  │ Layer 4                   │
│       │  │  │  │  ┌─────────────────┐  │  │  │  │                           │
│       │  │  │  │  │   APPLICATION   │  │  │  │  │ Centre                    │
│       │  │  │  │  └─────────────────┘  │  │  │  │                           │
│       │  │  │  └───────────────────────┘  │  │  │                           │
│       │  │  └─────────────────────────────┘  │  │                           │
│       │  └───────────────────────────────────┘  │                           │
│       └─────────────────────────────────────────┘                           │
│                                                                              │
│  ════════════════════════════════════════════════════════════════════════   │
│                                                                              │
│  3. FAIL SECURE                                                              │
│  ─────────────────────────────────────────                                   │
│                                                                              │
│  "On error, the system must block access, not allow it."                    │
│                                                                              │
│  ❌ Fail OPEN (dangerous):                                                   │
│     if (auth_check() == ERROR) { allow_access(); }                          │
│                                                                              │
│  ✅ Fail SECURE:                                                             │
│     if (auth_check() != SUCCESS) { deny_access(); }                         │
│                                                                              │
│  ════════════════════════════════════════════════════════════════════════   │
│                                                                              │
│  4. SEPARATION OF DUTIES                                                     │
│  ────────────────────────────────────────────────────────────                │
│                                                                              │
│  "No single person should be able to do everything."                        │
│                                                                              │
│  Examples:                                                                   │
│  - Developer CANNOT approve their own code to production                    │
│  - DBA CANNOT see encrypted data (does not have the key)                    │
│  - Network admin DOES NOT have access to servers                            │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

### 6. Vulnerabilities and Common Attacks

#### Types of OS-Level Attacks

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                      COMMON VULNERABILITIES                                  │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  1. PRIVILEGE ESCALATION                                                     │
│  ────────────────────────────────────────────────                            │
│                                                                              │
│  The attacker gains access as an unprivileged user,                         │
│  then exploits a vulnerability to become root.                              │
│                                                                              │
│  Common vectors:                                                             │
│  - Vulnerable setuid executables                                            │
│  - Kernel exploits                                                          │
│  - sudo misconfigurations                                                   │
│  - Weak root passwords                                                      │
│                                                                              │
│  Search for setuid files:                                                    │
│  $ find / -perm -4000 -type f 2>/dev/null                                   │
│                                                                              │
│  ════════════════════════════════════════════════════════════════════════   │
│                                                                              │
│  2. PATH INJECTION                                                           │
│  ───────────────────                                                         │
│                                                                              │
│  The attacker manipulates $PATH to run a malicious program                  │
│  instead of a legitimate one.                                               │
│                                                                              │
│  ❌ Vulnerable:                                                              │
│  PATH="." && ./script_calls_ls.sh                                           │
│  # If attacker created a malicious ./ls, that will run!                     │
│                                                                              │
│  ✅ Safe:                                                                    │
│  - Do not include "." in PATH                                               │
│  - In scripts, use absolute paths: /bin/ls                                  │
│                                                                              │
│  ════════════════════════════════════════════════════════════════════════   │
│                                                                              │
│  3. SYMLINK ATTACKS                                                          │
│  ───────────────────                                                         │
│                                                                              │
│  The attacker creates a symlink in /tmp pointing to a critical file,        │
│  and a privileged script accidentally writes to it.                         │
│                                                                              │
│  Example:                                                                    │
│  $ ln -s /etc/passwd /tmp/output.txt                                        │
│  # Root script writes to /tmp/output.txt → overwrites /etc/passwd!          │
│                                                                              │
│  Protection: sticky bit on /tmp, O_NOFOLLOW flag                            │
│                                                                              │
│  ════════════════════════════════════════════════════════════════════════   │
│                                                                              │
│  4. TIME-OF-CHECK TO TIME-OF-USE (TOCTOU)                                    │
│  ──────────────────────────────────────────────                              │
│                                                                              │
│  Race condition between access verification and use.                        │
│                                                                              │
│  ❌ Vulnerable:                                                              │
│  if (access("/tmp/file", R_OK) == 0) {                                      │
│      // ← Between access() and open(), attacker changes /tmp/file!          │
│      fd = open("/tmp/file", O_RDONLY);                                      │
│  }                                                                           │
│                                                                              │
│  ✅ Safe: Verification at kernel level, not user space                      │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

#### Security Audit: What to Check

```bash
# 1. Find world-writable files
find / -type f -perm -002 2>/dev/null

# 2. Find directories without sticky bit (world-writable)
find / -type d -perm -002 ! -perm -1000 2>/dev/null

# 3. Find setuid/setgid executables
find / -perm -4000 -o -perm -2000 -type f 2>/dev/null

# 4. Check files without owner
find / -nouser -o -nogroup 2>/dev/null

# 5. Check permissions on sensitive files
ls -la /etc/passwd /etc/shadow /etc/sudoers

# 6. Users with UID 0 (root)
awk -F: '$3 == 0 {print $1}' /etc/passwd

# 7. Check for empty passwords
sudo awk -F: '$2 == "" {print $1}' /etc/shadow
```

---

## Laboratory/Seminar (Session 6/7)

### TC Materials
- TC6a-TC6c: Advanced Scripting, Testing
- TC6d: Security Practices

### Assignment 6: `tema6_security_audit.sh`

Security audit script that:
- Scans world-writable files
- Detects setuid/setgid executables
- Checks permissions on critical files
- Generates HTML or text report
- Options: `-q` quiet, `-o FILE` output, `--fix` (proposes remediation)

---

## Practical Demonstrations

### Demo 1: Privilege Escalation via setuid

```bash
#!/bin/bash
# EDUCATIONAL DEMO - Do not do this on production systems!

# We show why setuid is dangerous on shell scripts
# (Actually, Linux ignores setuid on scripts, but the principle remains)

# Create a simple C program with setuid
cat > /tmp/demo_vuln.c << 'EOF'
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

int main() {
    // This program has setuid root
    // But calls system() with user input - DANGEROUS!
    printf("Checking disk... (running as UID %d)\n", geteuid());
    system("df -h");  // What happens if PATH is manipulated?
    return 0;
}
EOF

echo "In reality, NEVER make setuid programs that call system()!"
```

### Demo 2: ACL in Action

```bash
#!/bin/bash
# Demo: Granular permissions with ACL

DEMO_DIR=$(mktemp -d)
cd "$DEMO_DIR"

# Create file
echo "Sensitive data" > document.txt

# Traditional permissions
chmod 640 document.txt
ls -l document.txt

# Add ACL for specific user
setfacl -m u:nobody:r document.txt
echo "After ACL:"
getfacl document.txt

# Observe '+' in ls -l
ls -l document.txt

cd - && rm -rf "$DEMO_DIR"
```

---

## Recommended Reading

### OSTEP (Operating Systems: Three Easy Pieces)
- [Ch 53 - Security](https://pages.cs.wisc.edu/~remzi/OSTEP/security-intro.pdf)
- [Ch 54 - Authentication](https://pages.cs.wisc.edu/~remzi/OSTEP/security-authentication.pdf)
- [Ch 55 - Access Control](https://pages.cs.wisc.edu/~remzi/OSTEP/security-access.pdf)

### Tanenbaum - Modern Operating Systems
- Chapter 9: Security (p. 593+)

### Additional Resources
- OWASP Cheat Sheets
- CIS Benchmarks for Linux
- `man 5 sudoers`

---

## New Commands Summary

| Command | Description | Example |
|---------|-------------|---------|
| `chmod` | Change permissions | `chmod 755 file.sh` |
| `chown` | Change owner | `sudo chown user:group file` |
| `umask` | Set default permissions | `umask 077` |
| `getfacl` | View ACL | `getfacl file.txt` |
| `setfacl` | Set ACL | `setfacl -m u:bob:rw file.txt` |
| `last` | Last logins | `last \| head` |
| `lastb` | Failed logins | `sudo lastb` |
| `who` | Logged in users | `who` |
| `getenforce` | SELinux status | `getenforce` |
| `aa-status` | AppArmor status | `sudo aa-status` |

---


---


---

## Nuances and Special Cases

### What We Did NOT Cover (didactic limitations)

- **Seccomp-BPF**: Syscall filtering for sandboxing (Chrome, Docker, systemd).
- **Landlock**: Lightweight sandboxing introduced in Linux 5.13.
- **Secure boot and measured boot**: Chain of trust from UEFI to kernel.

### Common Mistakes to Avoid

1. **Setting 777 permissions**: Never in production; almost always wrong.
2. **Root in containers**: Even containerised, root can escalate via kernel vulnerabilities.
3. **Ignoring audit logs**: Without logging, you cannot investigate incidents.

### Open Questions Remaining

- Can capability-based systems (seL4, Fuchsia) replace traditional DAC/MAC models?
- How will post-quantum cryptography affect operating system security?

## Looking Ahead

**Week 14: Virtualisation + Review** — We conclude the main course with virtualisation: virtual machines vs containers, hypervisors and a review of all concepts studied. After this, supplementary courses (15-18) are available for deeper study.

**Recommended preparation:**
- Install Docker if you have not installed it yet
- Prepare questions for the review session

## Visual Summary

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    WEEK 13: RECAP - SECURITY                                 │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  AAA TRIAD                                                                   │
│  ├── Authentication: Who are you? (passwords, SSH keys, biometrics)         │
│  ├── Authorisation: What can you do? (permissions, ACL, RBAC)               │
│  └── Audit: What did you do? (/var/log/auth.log, journalctl)                │
│                                                                              │
│  UNIX PERMISSIONS                                                            │
│  ├── rwx for owner / group / others                                         │
│  ├── Numeric: 755, 644, 600                                                 │
│  ├── Special: setuid (s), setgid (s), sticky (t)                           │
│  └── umask: controls default permissions                                    │
│                                                                              │
│  ACL (Access Control Lists)                                                  │
│  ├── Granular permissions for multiple users/groups                         │
│  └── getfacl / setfacl                                                      │
│                                                                              │
│  ACCESS CONTROL MODELS                                                       │
│  ├── DAC: Owner decides (traditional Unix)                                  │
│  ├── MAC: System policy decides (SELinux, AppArmor)                         │
│  └── RBAC: Roles decide (sudo, Kubernetes)                                  │
│                                                                              │
│  PRINCIPLES                                                                  │
│  ├── Least Privilege: Only necessary permissions                            │
│  ├── Defence in Depth: Multiple security layers                             │
│  ├── Fail Secure: On error, block                                           │
│  └── Separation of Duties: No one does everything                           │
│                                                                              │
│  VULNERABILITIES                                                             │
│  ├── Privilege Escalation: setuid, kernel exploits                          │
│  ├── PATH Injection: Do not include "." in PATH                             │
│  ├── Symlink Attacks: sticky bit on /tmp                                    │
│  └── TOCTOU: Race conditions                                                │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```


---

## Self-Assessment

### Verification Questions

1. **[REMEMBER]** Define the AAA model (Authentication, Authorisation, Accounting). Give an example for each component.
2. **[UNDERSTAND]** Explain the Unix permissions system (rwx for owner, group, others). What does the 755 permission mean in octal?
3. **[ANALYSE]** Compare ACL (Access Control Lists) with traditional Unix permissions. In what situations are ACLs necessary?

### Mini-Challenge (optional)

Create a file and experiment with `chmod`, `chown`, `setfacl`. Verify the effects with `getfacl` and `ls -l`.

---

*Materials developed by Revolvix for ASE Bucharest - CSIE*  
*Operating Systems | Year I, Semester 2 | 2025-2026*

---

## Scripting in Context (Bash + Python): Permissions Audit

### Included Files

- Bash: `scripts/perm_audit.sh` — Finds world-writable, SUID/SGID, directories without sticky bit.
- Python: `scripts/perm_audit.py` — Permission interpretation via `stat` and controlled reporting.

### Quick Run

```bash
./scripts/perm_audit.sh .
./scripts/perm_audit.py --root .
```

### Connection to This Week's Concepts

- Permissions, SUID/SGID and sticky bit are simple mechanisms but with significant impact.
- Auditing is standard practice: first report, then remediate in a controlled manner.

### Recommended Practice

- first run the scripts on a test directory (not on critical data);
- save the output to a file and attach it to the report/assignment if required;
- note the kernel version (`uname -r`) and Python version (`python3 --version`) when comparing results.

*Materials developed by Revolvix for ASE Bucharest - CSIE*  
*Operating Systems | Year I, Semester 2 | 2025-2026*
