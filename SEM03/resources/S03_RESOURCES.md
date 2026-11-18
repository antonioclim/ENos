# Supplementary Resources - Seminar 03
## Operating Systems | Bucharest UES - CSIE

Advanced Utilities • Professional Scripts • Unix Permissions • Automation

---

The source list is educational guidance, not a live availability or deployment certification. The unavailable historical Healthchecks article has been replaced by a clearly labelled primary alternative. The Linux Experiment channel destination is verified; other platform catalogues and pricing have not been comprehensively rechecked.

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
| [Quartz Cron Expression Generator](https://www.freeformatter.com/cron-expression-generator-quartz.html) | Tool | Quartz dialect; do not paste its fields into a five-field Unix user crontab |
| [Systemd Timers vs Cron](https://wiki.archlinux.org/title/Systemd/Timers) | Advanced | Modern alternative |
| [Healthchecks monitoring documentation](https://healthchecks.io/docs/) | Intermediate | Alternative primary resource for monitoring scheduled jobs; not a recovered copy of the unavailable 2022 article |

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

### 4.3 Historical Virtual-Laboratory Suggestions

The following entries are retained as historical suggestions, with current access and availability unverified. They are not dependencies of this seminar.

| Resource | Type | Description |
|----------|------|-------------|
| Katacoda (O'Reilly) | Browser | Interactive scenarios |
| Linux Parcurs | Web | Structured course |
| Webminal | SSH Browser | Real terminal |

---

## 5. Cheat Sheets and Quick References

### 5.1 find Cheat Sheet

| Predicate/action | Meaning in GNU find |
|---|---|
| `-name '*.txt'` / `-iname '*.txt'` | Case-sensitive / insensitive basename matching; quote the pattern |
| `-type f`, `d`, `l`, `b` | Regular file, directory, symlink, block device |
| `-size +10M` | More than ten rounded-up 1 MiB units: strictly more than 10 MiB |
| `-size -100k` | Fewer than 100 rounded-up 1 KiB units: at most 99 KiB |
| `-size 50c` | Exactly 50 bytes |
| `-mtime -7` | Fewer than seven complete 24-hour periods old |
| `-mtime +30` | More than thirty complete 24-hour periods: at least 31 days old |
| `-mmin -60` | Fewer than sixty complete minutes old |
| `-a`, `-o`, `!`, escaped parentheses | AND (also implicit), OR, NOT and grouping; AND binds more tightly than OR |
| `-print`, `-print0` | Newline / NUL output; `-print` is the usual implicit action |
| `-exec command {} \;`, `-exec command {} +` | One invocation per match / batched arguments |
| `-delete` | Delete matching entries; preview the exact predicate and restrict it to the owned exercise tree first |

### 5.2 xargs Cheat Sheet

`xargs` batches arguments subject to its command-size limit. Default parsing treats whitespace and quotes specially; it is unsuitable for arbitrary filenames. `-n 1` limits arguments per invocation, `-I {}` supplies a replacement token and `-P 4` permits up to four concurrent child commands; actual parallel work also requires multiple batches.

```bash
# Run inside the owned fixture directory created in section 11.
find . -type f -name '*.txt' -print0 | xargs -0 -r grep -- 'pattern'
find . -type f -name '*.log' -print0 | xargs -0 -r printf 'Selected: %s\n'
# After reviewing the selection, delete only those owned fixture files:
find . -type f -name '*.log' -print0 | xargs -0 -r rm --
```

GNU `-r` avoids an invocation for an empty list. For portable per-file actions, consider `find ... -exec ... {} +`. A newline-delimited `files.txt` is only safe when its filename restrictions are explicit; use a NUL list for general filenames. A copy destination must exist before a batched `cp --target-directory=... --` invocation.

### 5.3 Permissions Cheat Sheet

| Bits/mode | Meaning and limit |
|---|---|
| `r=4`, `w=2`, `x=1`, three owner/group/other triples | Access permissions; directory `x` is search/traversal |
| `755` / `644` | Common directory/executable / regular-data modes; choose according to actual access needs |
| `600` / `700` | Owner-only data / directory or executable |
| `666` / `777` | Broad write access; do not use as a generic error fix. Shared-directory requirements may use sticky `1777` with explicit ownership rules |
| SUID (`4xxx`) | Executable-file effective owner semantics, subject to OS/mount restrictions; not a promise that shell scripts gain privileges |
| SGID (`2xxx`) | Executable-file effective group; on a directory, group inheritance subject to filesystem rules |
| Sticky (`1xxx`) | In a writable directory, unlink/rename generally requires ownership of the entry or directory, or suitable privilege; it does not prevent reading/modifying file content |

Parent-directory search permission, ACLs, mount options and process identity also affect access. `chmod u+s`, `chmod g+s` and `chmod +t` set the corresponding special bit; numeric modes `4755`, `2755` and `1777` are examples, not deployment defaults.

### 5.4 umask Calculator

For ordinary creation without a default ACL, use a **bitwise** mask: `actual = requested & (~umask & 0777)`. A request of `0666` for a regular file or `0777` for a directory is common; the caller can request fewer bits. Subtraction is not the rule.

| umask | Requested `0666` | Requested `0777` |
|---|---|---|
| `000` | `666` | `777` |
| `002` | `664` | `775` |
| `022` | `644` | `755` |
| `027` | `640` | `750` |
| `077` | `600` | `700` |
| `111` | `666` | `666` |

The last row is a counterexample to decimal/octal subtraction. A default ACL changes the creation rules; consult [`umask(2)`](https://man7.org/linux/man-pages/man2/umask.2.html) for that case. Existing files are not changed by a later `umask` call.

### 5.5 Cron Format Reference

A Unix **user crontab** has `minute hour day-of-month month day-of-week command`. Typical field ranges are `0–59`, `0–23`, `1–31`, `1–12` and `0–7` (Sunday 0 or 7). System crontabs have an additional username field. Named months/weekdays and shortcuts depend on the implementation.

| Schedule | Meaning |
|---|---|
| `0 * * * *` | Every hour at minute 0 |
| `*/15 * * * *` | Minutes 0, 15, 30 and 45 |
| `0 3 * * *` | Daily at 03:00 |
| `0 3 * * 0` | Sundays at 03:00 |
| `0 0 1 * *` | First of every month at midnight |
| `30 4 1,15 * *` | First and fifteenth at 04:30 |

`*` selects all values, `n-m` a range, `n,m` a list and a step applies **within its field**, not as an elapsed-time interval. In the Debian/Vixie-style rule, when both day-of-month and day-of-week are restricted, matching either is sufficient; this is not an unconditional OR rule for wildcard fields. Time zone and DST handling are implementation-dependent. `%` has special command-field semantics unless escaped.

Where supported: `@reboot` means daemon startup, `@yearly` is `0 0 1 1 *`, `@monthly` is `0 0 1 * *`, `@weekly` is `0 0 * * 0`, `@daily` is `0 0 * * *` and `@hourly` is `0 * * * *`. Consult `man 5 crontab` on the target machine.

### 5.6 getopts Reference

```bash
# Complete parsing example; save as a separate script and run with Bash.
usage() { printf 'Usage: %s [-h] [-v] [-f FILE] [-n NUMBER] [--] ARG...\n' "$0"; }
VERBOSE=0; FILE=''; NUM=''; NUM_GIVEN=0
while getopts ':hvf:n:' opt; do
    case "$opt" in
        h) usage; exit 0 ;;
        v) VERBOSE=1 ;;
        f) FILE=$OPTARG ;;
        n) NUM=$OPTARG; NUM_GIVEN=1 ;;
        :) printf 'Option -%s needs an argument\n' "$OPTARG" >&2; exit 2 ;;
        \?) printf 'Unknown option: -%s\n' "$OPTARG" >&2; exit 2 ;;
    esac
done
shift "$((OPTIND-1))"
if (( NUM_GIVEN )) && [[ ! "$NUM" =~ ^[0-9]+$ ]]; then
    printf 'NUMBER must contain only decimal digits\n' >&2; exit 2
fi
printf 'Parsed %s positional argument(s)\n' "$#"
```

`abc` defines three flags; `a:b:c` makes `-a` and `-b` require arguments, while `-c` is a flag. `a:bc` requires an argument only for `-a`. Options themselves are optional unless application logic requires them; this is different from an optional option argument. A leading `:` enables silent error reporting through `:`/`?` and `OPTARG`. `OPTIND` identifies the next argument; reset it to 1 before a separate parsing pass. Bash `getopts` handles short options; parse long options explicitly if required.

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
| The Linux Experiment | Desktop Linux | https://www.youtube.com/channel/UC5UAwBUum7CPN5buc-_N1Fw |
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
| Healthchecks documentation | https://healthchecks.io/docs/ | Primary alternative for scheduled-job monitoring |
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
| Government hardening publications | Select a named publication and issuing body | NSA/CISA and DISA STIGs are distinct sources; no exact publication is identified here |
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

Use a disposable directory owned by the learner. These exercises do not require changes to `/var/log`, `/var/www`, shared `/tmp` contents or system cron. Review selected paths before each modifying action.

```bash
LAB_ROOT=$(mktemp -d "${TMPDIR:-/tmp}/enos-resource-lab.XXXXXX")
mkdir -p -- "$LAB_ROOT/logs" "$LAB_ROOT/web/assets" "$LAB_ROOT/dropbox"
printf 'demo log\n' > "$LAB_ROOT/logs/old sample.log"
printf 'page\n' > "$LAB_ROOT/web/index.html"
printf 'text\n' > "$LAB_ROOT/web/assets/file with spaces.txt"
# Set only this fixture's modification time, then inspect it.
touch -d '32 days ago' -- "$LAB_ROOT/logs/old sample.log"
find "$LAB_ROOT" -type f -perm -4000 -print
find "$LAB_ROOT" -type f -perm -002 -print
find "$LAB_ROOT" \( -nouser -o -nogroup \) -print
find "$LAB_ROOT" -type f -mtime -1 -print
find "$LAB_ROOT/logs" -type f -name '*.log' -mtime +30 -print
find "$LAB_ROOT/logs" -type f -name '*.log' -mtime +30 -exec gzip -- {} +
printf 'Retained exercise directory: %s\n' "$LAB_ROOT"
```

An empty result is valid: the owned fixture does not fabricate privileged files or orphan owners. Whole-system searches are a separate read-only administrative exercise with an authorised scope and explicit treatment of permission errors.

### 11.2 Permissions Challenges

Continue in the same fixture shell. The group example uses the learner's current group; institutional shared-group policy is a separate choice.

```bash
find "$LAB_ROOT/web" -type d -exec chmod 755 -- {} +
find "$LAB_ROOT/web" -type f -exec chmod 644 -- {} +
mkdir -- "$LAB_ROOT/shared"
chgrp -- "$(id -gn)" "$LAB_ROOT/shared"
chmod 2775 -- "$LAB_ROOT/shared"
chmod 1733 -- "$LAB_ROOT/dropbox"
find "$LAB_ROOT" -perm -777 -ls
```

The historical `chmod 733` "write-only drop box" description was incomplete. Directory write+search permits creating entries and accessing known names; sticky `1733` restricts unlink/rename by other users but does **not** ensure confidentiality or prohibit modifying a writable known file. File ownership/modes, ACLs and a controlled ingestion design determine those properties.

### 11.3 Cron Challenges

These are **templates to inspect**, not installed jobs. Replace `/home/student/enos-cron-lab` with a fixed absolute owned directory, create/review the referenced scripts and logs first, then choose scheduling explicitly. Do not insert an unexpanded shell variable into a crontab expecting it to inherit this interactive shell.

```cron
# Daily reviewed backup script at 02:30
30 2 * * * /home/student/enos-cron-lab/backup.sh >> /home/student/enos-cron-lab/backup.log 2>&1
# Sunday 03:00: list old regular files in the owned cache; no shared-/tmp deletion
0 3 * * 0 /usr/bin/find /home/student/enos-cron-lab/cache -type f -mtime +7 -print
# Monthly reviewed report
0 6 1 * * /home/student/enos-cron-lab/monthly_report.sh
# Every six wall-clock hours, append timestamp-free disk report to an owned log
0 */6 * * * /usr/bin/df -h >> /home/student/enos-cron-lab/disk_usage.log 2>&1
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
Historical collection: January 2025; corrected candidate: 17 November 2026

*💡 Suggestion: Save this page in bookmarks for quick access during study!*
