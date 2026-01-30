# Supplementary Resources - Seminar 03
## Operating Systems | Bucharest UES - CSIE

Advanced Utilities • Professional Scripts • Unix Permissions • Automation

---

## Contents

1. [Official Documentation](#1-official-documentation)
2. [Online Tutorials and Guides](#2-online-tutorials-and-guides)
3. [Recommended Books](#3-recommended-books)
4. [Practice Platforms](#4-practice-platforms)
5. [Cheat Sheets and Quick References](#5-cheat-sheets-and-quick-references)
6. [Educational Videos](#6-educational-videos)
7. [Online Tools](#7-online-tools)
8. [Advanced Technical Articles](#8-advanced-technical-articles)
9. [Communities and Forums](#9-communities-and-forums)
10. [Security Resources](#10-security-resources)
11. [Exercises and Challenges](#11-exercises-and-challenges)
12. [Module-Specific Resources](#12-module-specific-resources)

---

## 1. Official Documentation

### 1.1 GNU Coreutils and Findutils

| Resource | URL | Description |
|----------|-----|-------------|
| GNU Find Manual | https://www.gnu.org/software/findutils/manual/html_mono/find.html | Complete official documentation |
| GNU Coreutils | https://www.gnu.org/software/coreutils/manual/ | chmod, chown, stat, etc. |
| Bash Reference Manual | https://www.gnu.org/software/bash/manual/ | Complete Bash reference |
| POSIX Specifications | https://pubs.opengroup.org/onlinepubs/9699919799/ | Portability standard |

### 1.2 Online Man Pages

```bash
# Access locally:
man find
man xargs
man chmod
man crontab

# Specific sections:
man 5 crontab     # Crontab file format
man 8 cron        # Cron daemon
```

| Online Man Page | URL |
|-----------------|-----|
| man7.org | https://man7.org/linux/man-pages/ |
| die.net | https://linux.die.net/man/ |
| Ubuntu Manpage | https://manpages.ubuntu.com/ |

### 1.3 Ubuntu Documentation

- Ubuntu Server Guide: https://ubuntu.com/server/docs
- Ubuntu Security: https://ubuntu.com/security
- Ubuntu Community Help: https://help.ubuntu.com/community/

---

## 2. Online Tutorials and Guides

### 2.1 find and xargs

| Resource | Level | Description |
|----------|-------|-------------|
| [Linux find command tutorial](https://www.computerhope.com/unix/ufind.htm) | Beginner | Introduction with examples |
| [35 Practical Examples of find](https://www.tecmint.com/35-practical-examples-of-linux-find-command/) | Intermediate | Practical examples |
| [GNU findutils Examples](https://www.gnu.org/software/findutils/manual/html_node/find_html/) | Advanced | All options |
| [xargs Tutorial](https://shapeshed.com/unix-xargs/) | Intermediate | Complete xargs guide |
| [Parallel Processing with xargs](https://www.cyberciti.biz/faq/linux-xargs-command-tutorial-examples/) | Advanced | xargs -P |

### 2.2 Script Parameters and getopts

| Resource | Level | Description |
|----------|-------|-------------|
| [Bash Positional Parameters](https://www.gnu.org/software/bash/manual/html_node/Positional-Parameters.html) | Official | GNU documentation |
| [getopts Tutorial](https://wiki.bash-hackers.org/howto/getopts_tutorial) | Intermediate | Complete guide |
| [Shell Scripting Tutorial](https://www.shellscript.sh/) | Beginner | From scratch |
| [Advanced Bash-Scripting Guide](https://tldp.org/LDP/abs/html/) | Advanced | TLDP classic |
| [Pure Bash Bible](https://github.com/dylanaraps/pure-bash-bible) | Advanced | Dependency-free techniques |

### 2.3 Unix Permissions

| Resource | Level | Description |
|----------|-------|-------------|
| [Linux File Permissions Explained](https://www.redhat.com/sysadmin/linux-file-permissions-explained) | Beginner | Red Hat |
| [chmod Calculator](https://chmod-calculator.com/) | Tool | Online calculator |
| [Understanding SUID/SGID](https://www.linuxnix.com/suid-set-suid-linuxunix/) | Intermediate | Special permissions |
| [umask Explained](https://www.cyberciti.biz/tips/understanding-linux-unix-umask-value-usage.html) | Intermediate | Detailed |
| [Linux Security Modules](https://www.kernel.org/doc/html/latest/admin-guide/LSM/index.html) | Advanced | SELinux, AppArmor |

### 2.4 Cron and Automation

| Resource | Level | Description |
|----------|-------|-------------|
| [Crontab Guru](https://crontab.guru/) | Tool | Online editor/validator |
| [Cron Expression Generator](https://www.freeformatter.com/cron-expression-generator-quartz.html) | Tool | Generator |
| [Systemd Timers vs Cron](https://wiki.archlinux.org/title/Systemd/Timers) | Advanced | Modern alternative |
| [Cron Best Practices](https://blog.healthchecks.io/2022/01/cron-job-best-practices/) | Intermediate | Production |

---

## 3. Recommended Books

### 3.1 Free Online

| Title | Author | Format | URL |
|-------|--------|--------|-----|
| The Linux Command Line | William Shotts | PDF/HTML | https://linuxcommand.org/tlcl.php |
| Advanced Bash-Scripting Guide | Mendel Cooper | HTML | https://tldp.org/LDP/abs/html/ |
| Bash Guide for Beginners | Machtelt Garrels | HTML | https://tldp.org/LDP/Bash-Beginners-Guide/html/ |
| GNU/Linux Command-Line Tools Summary | Gareth Anderson | HTML | https://tldp.org/LDP/GNU-Linux-Tools-Summary/html/ |
| Linux Fundamentals | Paul Cobbaut | PDF | https://linux-training.be/linuxfun.pdf |

### 3.2 Reference Books (Purchase)

| Title | Author | Publisher | Level |
|-------|--------|-----------|-------|
| Unix and Linux System Administration Handbook | Nemeth, Snyder, Hein | Pearson | Complete |
| Learning the bash Shell | Newham, Rosenblatt | O'Reilly | Intermediate |
| Mastering Regular Expressions | Jeffrey Friedl | O'Reilly | Advanced |
| How Linux Works | Brian Ward | No Starch | Intermediate |
| Linux Bible | Christopher Negus | Wiley | Complete |

### 3.3 Specific eBooks

| Title | Focus | Availability |
|-------|-------|--------------|
| Bash Cookbook | Practical recipes | O'Reilly Safari |
| Shell Scripting Recipes | Automation | Various |
| Wicked Cool Shell Scripts | Useful scripts | No Starch |

---

## 4. Practice Platforms

### 4.1 Interactive Platforms

| Platform | URL | Features |
|----------|-----|----------|
| OverTheWire: Bandit | https://overthewire.org/wargames/bandit/ | Linux wargames (perfect for permissions!) |
| Exercism: Bash Track | https://exercism.org/tracks/bash | Exercises with mentoring |
| HackerRank: Linux Shell | https://www.hackerrank.com/domains/shell | Categorised challenges |
| LeetCode: Shell | https://leetcode.com/problemset/shell/ | Competitive problems |
| Linux Survival | https://linuxsurvival.com/ | Interactive tutorial |

### 4.2 Online Sandboxes

| Platform | URL | Features |
|----------|-----|----------|
| repl.it | https://replit.com/ | Complete terminal in browser |
| JDoodle | https://www.jdoodle.com/test-bash-shell-script-online | Online Bash compiler |
| OnlineGDB | https://www.onlinegdb.com/online_bash_shell | Online debug |
| Paiza.io | https://paiza.io/en/projects/new?language=bash | Multi-language |

### 4.3 Virtual Laboratories

| Resource | Type | Description |
|----------|------|-------------|
| Katacoda (O'Reilly) | Browser | Interactive scenarios |
| Linux Parcurs | Web | Structured course |
| Webminal | SSH Browser | Real terminal |

---

## 5. Cheat Sheets and Quick References

### 5.1 find Cheat Sheet

```
╔══════════════════════════════════════════════════════════════════╗
║                    FIND QUICK REFERENCE                          ║
╠══════════════════════════════════════════════════════════════════╣
║ SEARCH BY NAME                                                   ║
║   find /path -name "*.txt"        Case sensitive                 ║
║   find /path -iname "*.txt"       Case insensitive               ║
║                                                                  ║
║ SEARCH BY TYPE                                                   ║
║   -type f    Regular file       -type d    Directory            ║
║   -type l    Symbolic link      -type b    Block device         ║
║                                                                  ║
║ SEARCH BY SIZE                                                   ║
║   -size +10M     Larger than 10MB                               ║
║   -size -100k    Smaller than 100KB                             ║
║   -size 50c      Exactly 50 bytes                               ║
║                                                                  ║
║ SEARCH BY TIME (days)                                            ║
║   -mtime -7      Modified in last 7 days                        ║
║   -mtime +30     Modified more than 30 days ago                 ║
║   -mmin -60      Modified in last 60 minutes                    ║
║                                                                  ║
║ LOGICAL OPERATORS                                                ║
║   -and / -a      AND (implicit)                                 ║
║   -or  / -o      OR                                             ║
║   -not / !       NOT                                            ║
║   \( \)          Grouping                                       ║
║                                                                  ║
║ ACTIONS                                                          ║
║   -print         Display (default)                              ║
║   -print0        Null-separated (for xargs -0)                  ║
║   -exec cmd {} \;   Execute for each                            ║
║   -exec cmd {} +    Execute batched                             ║
║   -delete        Delete (⚠️ test first!)                        ║
╚══════════════════════════════════════════════════════════════════╝
```

### 5.2 xargs Cheat Sheet

```
╔══════════════════════════════════════════════════════════════════╗
║                    XARGS QUICK REFERENCE                         ║
╠══════════════════════════════════════════════════════════════════╣
║ BASIC USAGE                                                      ║
║   cmd | xargs               Execute with all args                ║
║   cmd | xargs -n 1          One arg per execution               ║
║   cmd | xargs -I {} cmd {}  Custom placeholder                  ║
║                                                                  ║
║ HANDLING SPECIAL CHARACTERS                                      ║
║   find . -print0 | xargs -0    Null-separated (spaces safe)     ║
║                                                                  ║
║ PARALLEL EXECUTION                                               ║
║   xargs -P 4                Execute 4 processes in parallel      ║
║                                                                  ║
║ COMMON PATTERNS                                                  ║
║   find . -name "*.log" | xargs rm                               ║
║   find . -name "*.txt" -print0 | xargs -0 grep "pattern"        ║
║   cat files.txt | xargs -I {} cp {} backup/                     ║
╚══════════════════════════════════════════════════════════════════╝
```

### 5.3 Permissions Cheat Sheet

```
╔══════════════════════════════════════════════════════════════════╗
║                 PERMISSIONS QUICK REFERENCE                      ║
╠══════════════════════════════════════════════════════════════════╣
║ PERMISSION BITS                                                  ║
║                                                                  ║
║   Symbolic:  r w x   r w x   r w x                              ║
║              │ │ │   │ │ │   │ │ │                              ║
║              └─┴─┴─owner─┴─group─┴─others                        ║
║                                                                  ║
║   Octal:    4 2 1   4 2 1   4 2 1                               ║
║             │ │ │   │ │ │   │ │ │                               ║
║             r w x   r w x   r w x                               ║
║                                                                  ║
║ COMMON PERMISSIONS                                               ║
║   755 rwxr-xr-x   Executables, directories                      ║
║   644 rw-r--r--   Regular files                                 ║
║   600 rw-------   Private files                                 ║
║   700 rwx------   Private directories/scripts                   ║
║   666 rw-rw-rw-   ⚠️ Avoid! Everyone can write                  ║
║   777 rwxrwxrwx   ⚠️ NEVER! Security nightmare                  ║
║                                                                  ║
║ SPECIAL PERMISSIONS                                              ║
║   SUID (4xxx)   Execute as owner       chmod u+s / chmod 4755   ║
║   SGID (2xxx)   Inherit group          chmod g+s / chmod 2755   ║
║   Sticky (1xxx) Only owner deletes     chmod +t  / chmod 1777   ║
║                                                                  ║
║ x ON DIRECTORY = ACCESS (cd), NOT EXECUTE!                       ║
╚══════════════════════════════════════════════════════════════════╝
```

### 5.4 umask Calculator

```
╔══════════════════════════════════════════════════════════════════╗
║                    UMASK CALCULATOR                              ║
╠══════════════════════════════════════════════════════════════════╣
║                                                                  ║
║   Default permissions:                                           ║
║     Files:       666 (rw-rw-rw-)                                ║
║     Directories: 777 (rwxrwxrwx)                                ║
║                                                                  ║
║   umask REMOVES bits from default!                               ║
║                                                                  ║
║   ┌─────────────────────────────────────────────────────────┐   ║
║   │ umask │ Files (666-umask) │ Directories (777-umask)    │   ║
║   ├─────────────────────────────────────────────────────────┤   ║
║   │  000  │  666 (rw-rw-rw-)  │  777 (rwxrwxrwx)          │   ║
║   │  002  │  664 (rw-rw-r--)  │  775 (rwxrwxr-x)          │   ║
║   │  022  │  644 (rw-r--r--)  │  755 (rwxr-xr-x) ← typical │   ║
║   │  027  │  640 (rw-r-----)  │  750 (rwxr-x---)          │   ║
║   │  077  │  600 (rw-------)  │  700 (rwx------) ← secure │   ║
║   └─────────────────────────────────────────────────────────┘   ║
║                                                                  ║
║   Formula: Final = Default - umask (per digit)                   ║
║   ⚠️ umask does NOT ADD bits, only REMOVES!                     ║
╚══════════════════════════════════════════════════════════════════╝
```

### 5.5 Cron Format Reference

```
╔══════════════════════════════════════════════════════════════════╗
║                    CRON FORMAT REFERENCE                         ║
╠══════════════════════════════════════════════════════════════════╣
║                                                                  ║
║   ┌───────────── minute (0-59)                                  ║
║   │ ┌───────────── hour (0-23)                                  ║
║   │ │ ┌───────────── day of month (1-31)                        ║
║   │ │ │ ┌───────────── month (1-12 or JAN-DEC)                  ║
║   │ │ │ │ ┌───────────── day of week (0-7, SUN=0 or 7)          ║
║   │ │ │ │ │                                                     ║
║   * * * * * command                                             ║
║                                                                  ║
║ SPECIAL CHARACTERS                                               ║
║   *       Every value           */n     Every n                 ║
║   n-m     Range n to m          n,m     List n and m            ║
║                                                                  ║
║ COMMON EXAMPLES                                                  ║
║   0 * * * *        Every hour at :00                            ║
║   */15 * * * *     Every 15 minutes                             ║
║   0 3 * * *        Daily at 3:00 AM                             ║
║   0 3 * * 0        Sundays at 3:00 AM                           ║
║   0 0 1 * *        First of each month at midnight              ║
║   30 4 1,15 * *    1st and 15th at 4:30 AM                      ║
║                                                                  ║
║ SHORTCUTS (if supported)                                         ║
║   @reboot          At startup                                   ║
║   @yearly          0 0 1 1 *                                    ║
║   @monthly         0 0 1 * *                                    ║
║   @weekly          0 0 * * 0                                    ║
║   @daily           0 0 * * *                                    ║
║   @hourly          0 * * * *                                    ║
║                                                                  ║
║ ⚠️ DOM + DOW: EITHER matches (OR logic, not AND!)               ║
╚══════════════════════════════════════════════════════════════════╝
```

### 5.6 getopts Reference

```
╔══════════════════════════════════════════════════════════════════╗
║                   GETOPTS QUICK REFERENCE                        ║
╠══════════════════════════════════════════════════════════════════╣
║                                                                  ║
║ BASIC TEMPLATE                                                   ║
║   while getopts "hvf:n:" opt; do                                ║
║       case $opt in                                              ║
║           h) usage; exit 0 ;;                                   ║
║           v) VERBOSE=1 ;;                                       ║
║           f) FILE="$OPTARG" ;;                                  ║
║           n) NUM="$OPTARG" ;;                                   ║
║           ?) usage; exit 1 ;;                                   ║
║       esac                                                      ║
║   done                                                          ║
║   shift $((OPTIND-1))                                           ║
║                                                                  ║
║ OPTSTRING FORMAT                                                 ║
║   "abc"     -a, -b, -c without arguments                        ║
║   "a:b:c"   -a ARG, -b ARG, -c ARG required                     ║
║   "a:bc"    -a ARG required, -b -c optional                     ║
║   ":abc"    Silent errors (leading :)                           ║
║                                                                  ║
║ SPECIAL VARIABLES                                                ║
║   $OPTARG   Value of current option's argument                  ║
║   $OPTIND   Index of next argument to process                   ║
║   $opt      Current option letter                               ║
║                                                                  ║
║ ⚠️ getopts ONLY handles short options (-a, -b)                  ║
║    For --long options, use manual parsing with case             ║
╚══════════════════════════════════════════════════════════════════╝
```

### 5.7 Downloadable Resources

| Resource | Format | URL |
|----------|--------|-----|
| DevHints Bash | Web/PDF | https://devhints.io/bash |
| Linux Command Cheat Sheet | PDF | https://www.linuxtrainingacademy.com/linux-commands-cheat-sheet/ |
| chmod Calculator | Web | https://chmod-calculator.com/ |
| Crontab Guru | Web | https://crontab.guru/ |

---

## 6. Educational Videos

### 6.1 Recommended YouTube Channels

| Channel | Focus | Link |
|---------|-------|------|
| Learn Linux TV | Server administration | https://www.youtube.com/@LearnLinuxTV |
| NetworkChuck | Linux basics, fun style | https://www.youtube.com/@NetworkChuck |
| The Linux Experiment | Desktop Linux | https://www.youtube.com/@TheLinuxExperiment |
| tutoriaLinux | System admin | https://www.youtube.com/@tutoriaLinux |
| DistroTube | Command line power | https://www.youtube.com/@DistroTube |

### 6.2 Specific Playlists

| Subject | Creator | Playlist Link |
|---------|---------|---------------|
| Bash Scripting | Learn Linux TV | Search: "Bash Scripting on Linux" |
| Linux Permissions | tutoriaLinux | Search: "Linux Permissions Explained" |
| Cron Jobs | NetworkChuck | Search: "Cron Jobs Linux" |
| find Command | LinuxHint | Search: "Linux find command tutorial" |

### 6.3 Complete Video Courses

| Platform | Course | Type |
|----------|--------|------|
| Udemy | Linux Shell Scripting | Paid |
| Coursera | Unix and Bash for Beginners | Free audit |
| edX | Introduction to Linux | Free audit |
| LinkedIn Learning | Linux Command Line | Free with trial |
| Pluralsight | Linux Command Line Interface | Subscription |

---

## 7. Online Tools

### 7.1 Validators and Editors

| Tool | URL | Usage |
|------|-----|-------|
| ShellCheck | https://www.shellcheck.net/ | Bash validation and linting |
| ExplainShell | https://explainshell.com/ | Explains commands |
| chmod Calculator | https://chmod-calculator.com/ | Permissions calculator |
| Crontab.guru | https://crontab.guru/ | Visual cron editor |
| Regex101 | https://regex101.com/ | Regular expression testing |

### 7.2 Sandboxes and Testers

| Tool | URL | Features |
|------|-----|----------|
| repl.it Bash | https://replit.com/languages/bash | Complete terminal |
| JSFiddle for terminal | https://www.jdoodle.com/ | Quick testing |
| OnlineGDB | https://www.onlinegdb.com/ | Integrated debug |

### 7.3 Diagrams and Visualisations

| Tool | URL | Usage |
|------|-----|-------|
| ASCIIFlow | https://asciiflow.com/ | ASCII diagrams |
| Mermaid Live | https://mermaid.live/ | Diagrams in Markdown |
| draw.io | https://app.diagrams.net/ | Professional diagrams |

---

## 8. Advanced Technical Articles

### 8.1 find and xargs in Depth

| Article | URL | Focus |
|---------|-----|-------|
| "GNU find Optimization" | GNU Manual | Search optimisation |
| "xargs vs find -exec" | Stack Overflow | Performance |
| "Parallel Processing with find" | Linux Journal | -P and GNU Parallel |

### 8.2 Security and Permissions

| Article | Source | Focus |
|---------|--------|-------|
| "Understanding SUID, SGID, Sticky" | Red Hat | Special permissions |
| "Linux Security Best Practices" | CIS Benchmarks | Hardening |
| "Why SUID root shell scripts are dangerous" | Stack Exchange | Security |
| "umask and File Security" | Cyberciti | Best practices |

### 8.3 Advanced Automation

| Article | Source | Focus |
|---------|--------|-------|
| "Cron Job Monitoring" | healthchecks.io | Monitoring |
| "Systemd Timers vs Cron" | Arch Wiki | Modern alternatives |
| "Avoiding Cron Pitfalls" | Various | Common problems |
| "Lock Files in Shell Scripts" | Linux Journal | Race condition prevention |

---

## 9. Communities and Forums

### 9.1 Q&A and Forums

| Community | URL | Focus |
|-----------|-----|-------|
| Unix & Linux Stack Exchange | https://unix.stackexchange.com/ | Technical Q&A |
| Ask Ubuntu | https://askubuntu.com/ | Ubuntu specific |
| Server Fault | https://serverfault.com/ | Administration |
| Reddit r/linux | https://reddit.com/r/linux | General discussions |
| Reddit r/bash | https://reddit.com/r/bash | Bash scripting |
| Reddit r/linuxadmin | https://reddit.com/r/linuxadmin | Administration |
| LinuxQuestions.org | https://www.linuxquestions.org/ | Classic forum |

### 9.2 Chat and Instant Help

| Platform | Channel | Link |
|----------|---------|------|
| Discord | Linux Hub | https://discord.gg/linux |
| IRC | #bash on Libera.Chat | irc://irc.libera.chat/#bash |
| Telegram | Linux Groups | Various |

### 9.3 Romanian Communities

| Community | Platform | Focus |
|-----------|----------|-------|
| Romanian Linux Users Group | Forum/Facebook | General |
| DevForum.ro | Forum | Development |
| ROSEdu | Various | Open Source Education |

---

## 10. Security Resources

### 10.1 Hardening Guides

| Resource | URL | Description |
|----------|-----|-------------|
| CIS Benchmarks | https://www.cisecurity.org/cis-benchmarks | Industry standard |
| OWASP | https://owasp.org/ | Web/application security |
| NSA/CISA Linux Hardening | DISA STIGs | Governmental |
| Lynis | https://cisofy.com/lynis/ | Audit tool |

### 10.2 Vulnerabilities and CVE

| Resource | URL | Description |
|----------|-----|-------------|
| CVE Details | https://www.cvedetails.com/ | CVE Database |
| NVD | https://nvd.nist.gov/ | NIST Vulnerability DB |
| Ubuntu Security Notices | https://ubuntu.com/security/notices | Ubuntu specific |

### 10.3 Security Practice

| Platform | URL | Type |
|----------|-----|------|
| OverTheWire | https://overthewire.org/ | Wargames |
| HackTheBox | https://www.hackthebox.eu/ | CTF/Pentest |
| TryHackMe | https://tryhackme.com/ | Learning paths |
| PicoCTF | https://picoctf.org/ | CTF for beginners |

---

## 11. Exercises and Challenges

### 11.1 find Challenges

```bash
# 1. Find all SUID files on the system
find / -perm -4000 -type f 2>/dev/null

# 2. Find world-writable files
find / -perm -002 -type f 2>/dev/null

# 3. Find files without valid owner
find / -nouser -o -nogroup 2>/dev/null

# 4. Find files modified in the last 24h
find /home -mtime -1 -type f

# 5. Find and compress logs older than 30 days
find /var/log -name "*.log" -mtime +30 -exec gzip {} \;
```

### 11.2 Permissions Challenges

```bash
# 1. Fix permissions for a web project
find /var/www -type d -exec chmod 755 {} \;
find /var/www -type f -exec chmod 644 {} \;

# 2. Configure shared directory for group
mkdir /shared
chgrp developers /shared
chmod 2775 /shared

# 3. Create "drop box" directory (write-only)
mkdir /dropbox
chmod 733 /dropbox

# 4. Quick security audit
find . -perm -777 -ls 2>/dev/null
```

### 11.3 Cron Challenges

```
# 1. Daily backup at 2:30 AM
30 2 * * * /usr/local/bin/backup.sh >> /var/log/backup.log 2>&1

# 2. Weekly cleanup Sunday at 3 AM
0 3 * * 0 find /tmp -mtime +7 -delete

# 3. Monthly report on first day at 6 AM
0 6 1 * * /usr/local/bin/monthly_report.sh

# 4. Disk check every 6 hours
0 */6 * * * df -h > /var/log/disk_usage.log
```

### 11.4 Mini-Projects

| Project | Difficulty | Concept Tested |
|---------|------------|----------------|
| File organiser (by extension) | Medium | find + scripting |
| Backup rotator | Medium | cron + scripting |
| Permission auditor | Medium | find -perm + report |
| Log analyser | Difficult | find + xargs + awk |
| Directory sync | Difficult | find + rsync |

---

## 12. Module-Specific Resources

### 12.1 Module 1: find and xargs

Must-Read:
- GNU Find Manual (sections 2-6)
- xargs man page (options -0, -I, -P)

Practice:
- OverTheWire Bandit (levels 1-10 use find)
- HackerRank Shell challenges

Tools:
- ShellCheck for validation
- explainshell.com for understanding

### 12.2 Module 2: Parameters and getopts

Must-Read:
- Bash Reference Manual, Section 3.4 (Shell Parameters)
- Advanced Bash Scripting Guide, Chapter 4 (Parameters)

Practice:
- Rewrite 3 existing scripts to use getopts
- Create a complete CLI tool with --help

Tools:
- ShellCheck (checks best practices)
- GNU style guides for CLI

### 12.3 Module 3: Permissions

Must-Read:
- `man chmod`, `man chown`, `man umask`
- Linux File System Hierarchy Standard

Practice:
- OverTheWire Bandit (levels 10-20)
- Configure a LAMP server with correct permissions

Security:
- CIS Benchmark for Ubuntu
- Lynis audit tool

### 12.4 Module 4: Cron

Must-Read:
- `man 5 crontab` (file format)
- `man 8 cron` (daemon)

Practice:
- Create 5 cron jobs for real-world scenarios
- Implement logging and error handling

Tools:
- crontab.guru for construction
- healthchecks.io for monitoring

---

## Additional Resources

### Useful Quick Links

```
╔══════════════════════════════════════════════════════════════════╗
║                    QUICK LINKS                                   ║
╠══════════════════════════════════════════════════════════════════╣
║ chmod calculator     → https://chmod-calculator.com/            ║
║ crontab editor       → https://crontab.guru/                    ║
║ shellcheck           → https://www.shellcheck.net/              ║
║ explainshell         → https://explainshell.com/                ║
║ regex tester         → https://regex101.com/                    ║
║ ASCII diagrams       → https://asciiflow.com/                   ║
║ Bash cheat sheet     → https://devhints.io/bash                 ║
║ Linux man pages      → https://man7.org/linux/man-pages/        ║
╚══════════════════════════════════════════════════════════════════╝
```

### Recommended Reading (Order)

1. Beginner: Linux Command Line (William Shotts) - free
2. Intermediate: Learning the bash Shell (O'Reilly)
3. Advanced: Unix and Linux System Administration Handbook

### Relevant Certifications

| Certification | Organisation | Focus |
|---------------|--------------|-------|
| LPIC-1 | Linux Professional Institute | Linux basics |
| RHCSA | Red Hat | System administration |
| Linux+ | CompTIA | General Linux |
| LFCS | Linux Foundation | System administration |

---

## URL Index

For quick reference, all important URLs:

### Documentation

- https://www.gnu.org/software/findutils/manual/
- https://www.gnu.org/software/bash/manual/
- https://man7.org/linux/man-pages/


### Tools
- https://www.shellcheck.net/
- https://chmod-calculator.com/
- https://crontab.guru/
- https://explainshell.com/

### Practice
- https://overthewire.org/wargames/bandit/
- https://exercism.org/tracks/bash
- https://www.hackerrank.com/domains/shell

### Communities
- https://unix.stackexchange.com/
- https://askubuntu.com/
- https://reddit.com/r/bash

---

Document generated for: Seminar 03 OS, Bucharest UES - CSIE  
Version: 1.0  
Last updated: January 2025

*💡 Suggestion: Save this page in bookmarks for quick access during study!*
