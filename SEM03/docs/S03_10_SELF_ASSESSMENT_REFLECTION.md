# SELF-ASSESSMENT AND REFLECTION: Seminar 03
## Operating Systems | Bucharest UES - CSIE

> Purpose: Assess your level of understanding and identify areas that require additional practice

---

# TABLE OF CONTENTS

1. [Competency Checklist per Module](#-competency-checklist)
2. [Self-Assessment Questions](#-self-assessment-questions)
3. [Reflection Exercises](#-reflection-exercises)
4. [Individual Study Plan](#-individual-study-plan)
5. [Learning Journal](#-learning-journal)

---

# COMPETENCY CHECKLIST

## MODULE 1: find and xargs

### BASIC Level (I must be able to)
| # | Competency | Can I? | Examples |
|---|------------|:------:|----------|
| 1.1 | Search files by name | ☐ | `find . -name "*.txt"` |
| 1.2 | Search files by type (f/d/l) | ☐ | `find . -type f` |
| 1.3 | Search files by size | ☐ | `find . -size +10M` |
| 1.4 | Search recently modified files | ☐ | `find . -mtime -7` |
| 1.5 | Execute a command for each result | ☐ | `find . -exec ls -l {} \;` |

### INTERMEDIATE Level (I should be able to)
| # | Competency | Can I? | Examples |
|---|------------|:------:|----------|
| 1.6 | Combine criteria with AND | ☐ | `find . -type f -name "*.log"` |
| 1.7 | Combine criteria with OR | ☐ | `find . \( -name "*.c" -o -name "*.h" \)` |
| 1.8 | Use -exec with + for efficiency | ☐ | `find . -name "*.txt" -exec cat {} +` |
| 1.9 | Use xargs for batch processing | ☐ | `find . -name "*.txt" \| xargs wc -l` |
| 1.10 | Handle files with spaces in names | ☐ | `find . -print0 \| xargs -0` |

### ADVANCED Level (Bonus)
| # | Competency | Can I? | Examples |
|---|------------|:------:|----------|
| 1.11 | Use -printf for custom output | ☐ | `find . -printf '%M %u %p\n'` |
| 1.12 | Parallelise with xargs -P | ☐ | `find . \| xargs -P4 -I{} process {}` |
| 1.13 | Search by specific permissions | ☐ | `find . -perm -u+x` |
| 1.14 | Understand the difference find vs locate | ☐ | Live search vs database |

Module 1 Score: ___/14 competencies

---

## MODULE 2: Script Parameters and getopts

### BASIC Level (I must be able to)
| # | Competency | Can I? | Examples |
|---|------------|:------:|----------|
| 2.1 | Access arguments $1, $2, ... | ☐ | `echo "First: $1"` |
| 2.2 | Check argument count with $# | ☐ | `if [ $# -lt 2 ]; then` |
| 2.3 | Iterate through arguments with "$@" | ☐ | `for arg in "$@"; do` |
| 2.4 | Use shift for processing | ☐ | `while [ $# -gt 0 ]; do shift` |
| 2.5 | Set default values | ☐ | `OUTPUT=${1:-"default.txt"}` |

### INTERMEDIATE Level (I should be able to)
| # | Competency | Can I? | Examples |
|---|------------|:------:|----------|
| 2.6 | Understand the difference "$@" vs "$*" | ☐ | Arrays vs single string |
| 2.7 | Use getopts for short options | ☐ | `while getopts "hvo:" opt` |
| 2.8 | Handle OPTARG for values | ☐ | `o) output="$OPTARG" ;;` |
| 2.9 | Use shift with OPTIND | ☐ | `shift $((OPTIND-1))` |
| 2.10 | Write clear usage() functions | ☐ | Formatted help message |

### ADVANCED Level (Bonus)
| # | Competency | Can I? | Examples |
|---|------------|:------:|----------|
| 2.11 | Parse long options manually | ☐ | `case "$1" in --verbose)` |
| 2.12 | Combine short and long options | ☐ | `-v` and `--verbose` |
| 2.13 | Validate argument types | ☐ | Check if it's a number |
| 2.14 | Handle `--` for end of options | ☐ | `--) shift; break ;;` |

Module 2 Score: ___/14 competencies

---

## MODULE 3: Unix Permissions

### BASIC Level (I must be able to)
| # | Competency | Can I? | Examples |
|---|------------|:------:|----------|
| 3.1 | Read and interpret rwxr-xr-- | ☐ | Owner: rwx, Group: r-x, Others: r-- |
| 3.2 | Calculate octal permissions | ☐ | rwxr-xr-- = 754 |
| 3.3 | Use chmod with octal | ☐ | `chmod 644 file.txt` |
| 3.4 | Use chmod with symbolic | ☐ | `chmod u+x script.sh` |
| 3.5 | Understand the difference x on file vs directory | ☐ | Execute vs Access |

### INTERMEDIATE Level (I should be able to)
| # | Competency | Can I? | Examples |
|---|------------|:------:|----------|
| 3.6 | Calculate umask and its effect | ☐ | umask 022 → files 644 |
| 3.7 | Change owner with chown | ☐ | `chown user:group file` |
| 3.8 | Apply permissions recursively correctly | ☐ | `chmod -R u+rwX,go-w dir/` |
| 3.9 | Understand why we need w on dir for delete | ☐ | Directory entry control |
| 3.10 | Identify files with dangerous permissions | ☐ | 777, world-writable |

### ADVANCED Level (Bonus)
| # | Competency | Can I? | Examples |
|---|------------|:------:|----------|
| 3.11 | Understand and configure SUID | ☐ | `chmod u+s`, 4755 |
| 3.12 | Understand and configure SGID on directories | ☐ | `chmod g+s dir/` |
| 3.13 | Understand and configure Sticky Bit | ☐ | `chmod +t /shared` |
| 3.14 | Can configure a secure shared directory | ☐ | SGID + correct permissions |

Module 3 Score: ___/14 competencies

---

## MODULE 4: Cron and Automation

### BASIC Level (I must be able to)
| # | Competency | Can I? | Examples |
|---|------------|:------:|----------|
| 4.1 | Understand the format of the 5 fields | ☐ | min hour dom month dow |
| 4.2 | Write simple cron expressions | ☐ | `0 3 * * *` = daily 3 AM |
| 4.3 | Edit crontab with `crontab -e` | ☐ | Opens the editor |
| 4.4 | List crontab with `crontab -l` | ☐ | Displays jobs |
| 4.5 | Use absolute paths in cron | ☐ | `/home/user/script.sh` |

### INTERMEDIATE Level (I should be able to)
| # | Competency | Can I? | Examples |
|---|------------|:------:|----------|
| 4.6 | Use */N for intervals | ☐ | `*/15 * * * *` = every 15 min |
| 4.7 | Use ranges and lists | ☐ | `0 9-17 * * 1-5` |
| 4.8 | Redirect output to log | ☐ | `>> log.txt 2>&1` |
| 4.9 | Understand the limited cron environment | ☐ | PATH, different variables |
| 4.10 | Use special strings | ☐ | `@daily`, `@reboot` |

### ADVANCED Level (Bonus)
| # | Competency | Can I? | Examples |
|---|------------|:------:|----------|
| 4.11 | Prevent simultaneous executions with flock | ☐ | `flock -n /tmp/lock` |
| 4.12 | Configure notifications for errors | ☐ | MAILTO or mail in script |
| 4.13 | Use `at` for one-time jobs | ☐ | `at now + 2 hours` |
| 4.14 | Debug cron jobs effectively | ☐ | Logs, manual test |

Module 4 Score: ___/14 competencies

---

# SELF-ASSESSMENT QUESTIONS

## Section A: find and xargs

A1. Write the find command that finds all `.log` files larger than 100MB modified in the last week:

```bash
# Your answer:

```

<details>
<summary>💡 Check answer</summary>

```bash
find /var/log -type f -name "*.log" -size +100M -mtime -7
```
</details>

---

A2. Why might this command fail for files with spaces in their names?
```bash
find . -name "*.txt" | xargs rm
```

```
# Your explanation:

```

<details>
<summary>💡 Check answer</summary>

xargs splits input by spaces. A file "my document.txt" will be interpreted as two arguments: "my" and "document.txt", both non-existent.

Solution: `find . -name "*.txt" -print0 | xargs -0 rm`
</details>

---

A3. What is the difference between `-exec {} \;` and `-exec {} +`?

```
# Your answer:

```

<details>
<summary>💡 Check answer</summary>

- `\;` - Executes the command once for EACH file found (slow, many processes)
- `+` - Executes the command ONCE with all files as arguments (fast, one process)

Example: for 1000 files, `\;` creates 1000 processes, `+` creates 1.
</details>

---

## Section B: Script Parameters

B1. What does this script display when run with `./script.sh "hello world" test`?
```bash
#!/bin/bash
echo "Arguments: $#"
for arg in $@; do
    echo "- $arg"
done
```

```
# Your answer:

```

<details>
<summary>💡 Check answer</summary>

```
Arguments: 2

Three things count here: hello, world and test.

```

The problem: `$@` without quotes causes word splitting!
Correct: `for arg in "$@"` would display `- hello world` and `- test`
</details>

---

B2. Complete getopts for the options: -h (help), -v (verbose), -o FILE (output):

```bash
#!/bin/bash
while getopts "____" opt; do
    case $opt in
        # complete
    esac
done
```

<details>
<summary>💡 Check answer</summary>

```bash
while getopts ":hvo:" opt; do
    case $opt in
        h) usage; exit 0 ;;
        v) verbose=true ;;
        o) output="$OPTARG" ;;
        :) echo "Option -$OPTARG requires an argument"; exit 1 ;;
        \?) echo "Invalid option: -$OPTARG"; exit 1 ;;
    esac
done
shift $((OPTIND - 1))
```
</details>

---

B3. What does `${filename%.*}` do if `filename="document.backup.tar.gz"`?

```
# Your answer:

```

<details>
<summary>💡 Check answer</summary>

Result: `document.backup.tar`

`%.*` deletes the SHORTEST suffix that matches `.*` (i.e. `.gz`).

To obtain just `document`, you would use `%%.*` (the LONGEST suffix).
</details>

---

## Section C: Permissions

C1. Calculate the octal permissions for: `rwxr-x---`

```
# Your calculation:

```

<details>
<summary>💡 Check answer</summary>

```
Owner:  rwx = 4+2+1 = 7
Group:  r-x = 4+0+1 = 5
Others: --- = 0+0+0 = 0

Answer: 750
```
</details>

---

C2. With umask 027, what permissions will a newly created file have?

```
# Your calculation:

```

<details>
<summary>💡 Check answer</summary>

```
Default files: 666 (rw-rw-rw-)
umask:         027
─────────────────────
Result:        640 (rw-r-----)

666 - 027 = 640
```

Verification: `666` in binary is `110 110 110`, `027` is `000 010 111`
After applying umask: `110 100 000` = `640`
</details>

---

C3. Why does SUID on a bash script not work like on a binary?

```
# Your explanation:

```

<details>
<summary>💡 Check answer</summary>

For **security** reasons, Linux ignores SUID on interpreted scripts.

The reason: Race condition - between checking SUID and executing the script, an attacker could change the content.

Solution: Create a binary wrapper with SUID that executes the script, or use `sudo` with granular permissions.
</details>

---

C4. Explain what this sequence does and why it is important for shared directories:
```bash
chmod 2770 /shared
chgrp developers /shared
```

```
# Your explanation:

```

<details>
<summary>💡 Check answer</summary>

- `2` = SGID (Set Group ID)
- `770` = rwxrwx--- (owner and group have full access, others nothing)
- `chgrp developers` = the group becomes "developers"

The effect of SGID on directory: All files created in `/shared` will automatically have the group "developers", not the primary group of the user who creates them.

Without SGID, each user would create files with their own group, and other members would not have access.
</details>

---

## Section D: Cron

D1. Write the cron expression for: "Every 15 minutes, between 9 AM and 5 PM, Monday to Friday"

```
# Your answer:

```

<details>
<summary>💡 Check answer</summary>

```
*/15 9-17 * * 1-5
```

- `*/15` = every 15 minutes (0, 15, 30, 45)
- `9-17` = hours 9:00 - 17:00
- `* *` = any day and any month
- `1-5` = Monday (1) to Friday (5)
</details>

---

D2. Why might this cron job fail?
```
0 3 * * * backup.sh >> /var/log/backup.log
```

```
# Problems identified:

```

<details>
<summary>💡 Check answer</summary>

1. Relative path for `backup.sh` - cron does not know where it is
2. **PATH** - cron has minimal PATH, commands in the script may fail
3. Does not capture stderr - errors are lost
4. Permissions - /var/log may not be writable for the user

Correct version:
```
PATH=/usr/local/bin:/usr/bin:/bin
0 3 * * * /home/user/scripts/backup.sh >> /var/log/backup.log 2>&1
```
</details>

---

D3. How do you prevent a cron job from executing multiple times simultaneously if it runs too long?

```
# Your solution:

```

<details>
<summary>💡 Check answer</summary>

Use **flock** for lock file:

```
0 * * * * flock -n /tmp/myjob.lock /path/to/script.sh
```


The main aspects: `-n` = non-blocking (fails immediately if the lock is occupied), `/tmp/myjob.lock` = the lock file and if the previous job is still running, the new job will not start.


Alternatively in script:
```bash
LOCKFILE="/tmp/myscript.lock"
exec 200>$LOCKFILE
flock -n 200 || { echo "Already running"; exit 1; }
# rest of script...
```
</details>

---

# REFLECTION EXERCISES

## Reflection 1: "Aha!" Moments

Describe a concept from this seminar that initially seemed confusing but now makes sense:

```
The concept:

What helped me understand:

How I would explain it to someone else:

```

---

## Reflection 2: Connections

How do the concepts from this seminar connect to previous ones (redirection, pipes, loops)?

```
Connection 1: find + xargs connects to pipes because...

Connection 2: Permissions connect to the user concept because...

Connection 3: Cron connects to scripting because...

```

---

## Reflection 3: Practical Applications

Think of 3 real situations (at work, personal project) where you would use:

```
1. find + xargs:

2. Script with getopts:

3. Cron job:

```

---

## Reflection 4: Mistakes to Avoid

What are the most dangerous mistakes you could make with today's concepts?

```
1. With find:

2. With permissions:

3. With cron:

```

---

## Reflection 5: Remaining Questions

What questions do you still have after this seminar?

```
1.

2.

3.
```

---

# INDIVIDUAL STUDY PLAN

## Week 1: Fundamentals

| Day | Focus | Activity | Time |
|-----|-------|----------|------|
| Mon | find basics | Practise -name, -type, -size | 30 min |
| Tue | advanced find | Practise -exec, operators | 30 min |
| Wed | xargs | 10 find \| xargs commands | 30 min |
| Thu | Parameters | Write 3 scripts with $@ | 45 min |
| Fri | getopts | Modify the scripts with options | 45 min |
| Sat | Permissions | chmod octal/symbolic exercises | 30 min |
| Sun | Recap | Redo the difficult exercises | 30 min |

## Week 2: Consolidation

| Day | Focus | Activity | Time |
|-----|-------|----------|------|
| Mon | Special permissions | Configure shared directory | 30 min |
| Tue | umask | Test various umask | 20 min |
| Wed | Cron basics | 5 cron expressions | 30 min |
| Thu | Advanced cron | Cron job with logging | 45 min |
| Fri | Integration | Complex script with everything | 60 min |
| Sat | LLM Practice | Evaluate generated code | 30 min |
| Sun | Assignment | Complete assignment | 90 min |

---

# LEARNING JOURNAL

## Today's Session

Date: ________________

What I learnt:
```

```

What was difficult:
```

```

What I will practise tomorrow:
```

```

Understanding rating (1-5): ___

---

## Cumulative Progress

| Module | Before | After Seminar | After Practice |
|--------|:------:|:-------------:|:--------------:|
| find/xargs | ☐☐☐☐☐ | ☐☐☐☐☐ | ☐☐☐☐☐ |
| Parameters | ☐☐☐☐☐ | ☐☐☐☐☐ | ☐☐☐☐☐ |
| Permissions | ☐☐☐☐☐ | ☐☐☐☐☐ | ☐☐☐☐☐ |
| Cron | ☐☐☐☐☐ | ☐☐☐☐☐ | ☐☐☐☐☐ |

*(Tick boxes to mark the level: 1=beginner, 5=expert)*

---

# PERSONAL SMART OBJECTIVES

Complete for each module:

## Module 1: find/xargs
Specific: I want to be able to...
```

```
Measurable: I will know I have succeeded when...
```

```
Achievable: The steps to get there...
```

```
Relevant: It is important because...
```

```
Time-bound: Deadline: _______________

---

## Module 2: Script Parameters
Specific: I want to be able to...
```

```
Deadline: _______________

---

## Module 3: Permissions
Specific: I want to be able to...
```

```
Deadline: _______________

---

## Module 4: Cron
Specific: I want to be able to...
```

```
Deadline: _______________

---

# FINAL CHECKLIST

Before considering the seminar complete, verify:

- [ ] I have understood the difference between find and locate
- [ ] I can write complex find commands with multiple criteria
- [ ] I know when to use xargs and how to handle spaces
- [ ] I understand "$@" vs "$*" and use quotes correctly
- [ ] I can write a script with getopts that validates arguments
- [ ] I quickly calculate permissions octal ↔ symbolic
- [ ] I understand x on directory vs file
- [ ] I know what umask does and how to set it
- [ ] I understand SUID, SGID, Sticky and when to use them
- [ ] I can write cron expressions for any schedule
- [ ] I know best practices for cron jobs (PATH, logging and lock)
- [ ] I have completed the seminar assignment
- [ ] I have clearly formulated questions for the next session

---

# 🧠 POST-SEMINAR REFLECTION

> These questions are optional but recommended. Research shows that metacognition 
> (thinking about your own thinking) significantly improves learning retention.

## Journal Prompts (choose at least 2)

### 1. The Counter-Intuitive Command
Which find option or command seemed counter-intuitive when you first saw it?
Write it down here and explain to yourself WHY it actually makes sense:

```
Command: _________________________________

Initial confusion: _________________________________

Why it makes sense: _________________________________
```

### 2. The chmod 777 Confession
Be honest - have you ever used `chmod 777` just to "make it work"?  
(No shame, we have all done it.)

What did you learn today that will change how you approach this next time?

```
My chmod 777 moment: _________________________________

What I will do instead: _________________________________
```

### 3. The Explanation Challenge
If you had to explain the difference between `$@` and `$*` to a colleague who 
has never used bash, what analogy would you use?

```
My analogy: _________________________________
```

### 4. The "Why Did They Not Tell Me?" Moment
What is one thing you discovered today that you wish you had known earlier?
Something that would have saved you hours of frustration in the past?

```
The thing: _________________________________

How it would have helped: _________________________________
```

### 5. The Honest Assessment
On a scale of 1-10, how confident are you that you could:

| Task | Confidence (1-10) |
|------|-------------------|
| Debug a failing find command | ___ |
| Write a script that parses -v -o filename | ___ |
| Set up permissions for a shared project | ___ |
| Create a cron job that actually works | ___ |

For any score below 7: what specific practice do you need?

```
Practice plan: _________________________________
```

---

## Connection Questions

### Link to Other Courses

How does what you learnt today connect to:

1. **Computer Networks** (if taken):
   How might find + permissions be relevant to network security?
   ```
   
   ```

2. **Databases** (if taken):
   How might cron be useful for database maintenance?
   ```
   
   ```

3. **Software Engineering** (if taken):
   How might getopts patterns apply to CLI tool design?
   ```
   
   ```

### Real-World Application

Think of a repetitive task you do on your computer. Could any of today's 
tools automate it?

```
Task: _________________________________

Possible automation: _________________________________

Commands I would use: _________________________________
```

---

## Questions for Next Session

Write down at least 2 questions you still have:

1. _______________________________________________________________

2. _______________________________________________________________

3. (optional) _______________________________________________________________

---

*Document generated for Seminar 03 OS | Bucharest UES - CSIE*  
*Reflection section added: January 2025*
