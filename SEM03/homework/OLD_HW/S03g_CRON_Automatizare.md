# S03_TC06 - CRON - Automation and Task Scheduling

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
- Understand the cron system for task scheduling
- Configure cron jobs for users and system
- Use at for one-time tasks
- Implement professional automations

---


## 2. Crontab Format

### 2.1 Crontab Line Structure

```
┌───────────── minute (0-59)
│ ┌───────────── hour (0-23)
│ │ ┌───────────── day of month (1-31)
│ │ │ ┌───────────── month (1-12 or jan-dec)
│ │ │ │ ┌───────────── day of week (0-7, 0 and 7 = Sunday)
│ │ │ │ │
│ │ │ │ │
* * * * * command_to_execute
```

### 2.2 Special Values

| Symbol | Meaning | Example |
|--------|---------|---------|
| `*` | Any value | `* * * * *` (every minute) |
| `,` | List of values | `1,15,30` (min 1, 15, 30) |
| `-` | Range | `1-5` (Monday-Friday) |
| `/` | Step/increment | `*/5` (every 5) |

### 2.3 Special Strings

```bash
@reboot     # At system startup
@yearly     # 0 0 1 1 * (1st January)
@annually   # Equivalent to @yearly
@monthly    # 0 0 1 * * (first day of month)
@weekly     # 0 0 * * 0 (Sunday at midnight)
@daily      # 0 0 * * * (at midnight)
@midnight   # Equivalent to @daily
@hourly     # 0 * * * * (every hour, minute 0)
```

---

## 3. Practical Crontab Examples

### 3.1 Basic Examples

```bash
# Every minute
* * * * * /path/to/script.sh

# Every 5 minutes
*/5 * * * * /path/to/script.sh

# Every hour (minute 0)
0 * * * * /path/to/script.sh

# Daily at 3:00 AM
0 3 * * * /path/to/backup.sh

# Daily at 6:00 AM and 6:00 PM
0 6,18 * * * /path/to/report.sh

# Monday-Friday at 9:00 AM
0 9 * * 1-5 /path/to/workday.sh

# First day of every month
0 0 1 * * /path/to/monthly.sh

# Every Sunday at 2:30 AM
30 2 * * 0 /path/to/weekly.sh
```

### 3.2 Advanced Examples

```bash
# Every 15 minutes during working hours
*/15 9-17 * * 1-5 /path/to/check.sh

# On days 1 and 15 of the month
0 0 1,15 * * /path/to/biweekly.sh

# Every 2 hours
0 */2 * * * /path/to/every2hours.sh

# First Sunday of month (combination)
0 0 1-7 * 0 /path/to/first_sunday.sh
```

---

## 4. Crontab Management

### 4.1 crontab Commands

```bash
# Edit current user's crontab
crontab -e

# List current jobs
crontab -l

# Delete all jobs (caution!)
crontab -r

# Edit another user's crontab (root)
sudo crontab -u username -e

# List for another user
sudo crontab -u username -l
```

### 4.2 Crontab Locations

```bash
# User crontabs
/var/spool/cron/crontabs/username

# System crontab (includes user field)
/etc/crontab

# Directories for periodic scripts
/etc/cron.d/           # Extra crontabs
/etc/cron.hourly/      # Hourly scripts
/etc/cron.daily/       # Daily scripts
/etc/cron.weekly/      # Weekly scripts
/etc/cron.monthly/     # Monthly scripts
```

### 4.3 /etc/crontab Format

```bash
# /etc/crontab includes USER field
SHELL=/bin/bash
PATH=/sbin:/bin:/usr/sbin:/usr/bin
MAILTO=Issues: Open an issue in GitHub

# min hour day month dow user command
0 3 * * * root /usr/local/bin/backup.sh
*/5 * * * * www-data /var/www/cron.php
```

---

## 5. Best Practices

### 5.1 Environment Configuration

```bash
# In crontab, set environment variables
SHELL=/bin/bash
PATH=/usr/local/bin:/usr/bin:/bin
HOME=/home/user
MAILTO=user@example.com

# Jobs with full environment
* * * * * /bin/bash -l -c '/path/to/script.sh'
```

### 5.2 Logging and Debugging

```bash
# Output redirection
0 3 * * * /path/to/script.sh >> /var/log/myscript.log 2>&1

# With timestamp
0 3 * * * /path/to/script.sh 2>&1 | while read line; do echo "$(date): $line"; done >> /var/log/myscript.log

# Errors only
0 3 * * * /path/to/script.sh >> /var/log/myscript.log 2>> /var/log/myscript.err

# Suppress output completely
0 3 * * * /path/to/script.sh > /dev/null 2>&1
```

### 5.3 Locking (Prevent Multiple Executions)

```bash
#!/bin/bash
# Script with lock file

LOCKFILE="/tmp/myscript.lock"

# Check and create lock
if [ -f "$LOCKFILE" ]; then
    echo "Script already running"
    exit 1
fi

# Create lock
echo $$ > "$LOCKFILE"

# Cleanup on exit
trap "rm -f $LOCKFILE" EXIT

# Main logic
# ...
```

### 5.4 Absolute Paths

```bash
# WRONG - paths relative to current directory (`cwd`)
0 3 * * * backup.sh

# CORRECT - absolute paths
0 3 * * * /usr/local/bin/backup.sh

# Or set PATH in crontab
PATH=/usr/local/bin:/usr/bin:/bin
0 3 * * * backup.sh
```

---

## 6. The at Command - One-Time Tasks

### 6.1 at Syntax

```bash
# Execute command at specified time
at 15:30
at> /path/to/script.sh
at> <Ctrl+D>

# Time formats
at now + 1 hour
at now + 30 minutes
at midnight
at noon
at teatime         # 4:00 PM
at tomorrow
at 10:00 AM Dec 25
at 2:30 PM next week
```

### 6.2 at Management

```bash
# List scheduled jobs
atq
at -l

# View contents of a job
at -c job_number

# Delete a job
atrm job_number
at -d job_number
```

### 6.3 batch - Execute when system is idle

```bash
# Execute when load average drops below 1.5
batch
at> /path/to/heavy_script.sh
at> <Ctrl+D>
```

---

## 7. Practical Exercises

### Exercise 1: Daily Backup
```bash
# Edit crontab
crontab -e

# Add daily backup at 2:00 AM
0 2 * * * /home/user/scripts/backup.sh >> /var/log/backup.log 2>&1
```

### Exercise 2: Monitoring
```bash
# Check disk space every hour
0 * * * * df -h | mail -s "Disk Report" Issues: Open an issue in GitHub
```

### Exercise 3: Log Cleanup
```bash
# Delete old logs weekly
0 0 * * 0 find /var/log -name "*.log" -mtime +30 -delete
```

### Exercise 4: at for one-time task
```bash
# Schedule server restart tomorrow at 3 AM
echo "sudo systemctl restart nginx" | at 3:00 AM tomorrow
```

---

## 8. Verification Questions

1. **What does `*/15 * * * *` mean?**
   > Every 15 minutes (0, 15, 30, 45).

2. **How do you schedule a job for the first day of the month at midnight?**
   > `0 0 1 * *`

3. **Why isn't my cron job working?**
   > Check: absolute paths, environment variables, permissions, logs (/var/log/syslog).

4. **Difference between crontab -e and /etc/crontab?**
   > crontab -e is per user; /etc/crontab is system-wide and includes the user field.

5. **How do you prevent simultaneous executions of the same job?**
   > Use a lock file or flock.

---

## Cheat Sheet

```bash
# CRONTAB FORMAT
# min hour day month dow command
* * * * *           # every minute
*/5 * * * *         # every 5 min
0 * * * *           # every hour
0 3 * * *           # daily 3 AM
0 3 * * 0           # Sunday 3 AM
0 0 1 * *           # first day month
0 9 * * 1-5         # Mon-Fri 9 AM

# COMMANDS
crontab -e          # edit
crontab -l          # list
crontab -r          # delete all

# SPECIAL STRINGS
@reboot             # at boot
@daily              # daily
@weekly             # weekly
@monthly            # monthly
@hourly             # hourly

# AT
at 15:30            # at 15:30
at now + 1 hour     # in one hour
atq                 # list
atrm N              # delete job N

# BEST PRACTICES
/path/to/script.sh >> /var/log/out.log 2>&1
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
