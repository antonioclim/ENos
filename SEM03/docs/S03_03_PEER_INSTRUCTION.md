# Peer Instruction - Seminar 03
## Operating Systems | Bucharest UES - CSIE

> 18 questions (PI-10 explicitly permits two answers) for Peer Instruction activities  
> Format: Question → Individual vote → Pair discussion → Final vote → Explanation

---

## Peer Instruction Protocol

### Standard Voting Procedure

For each question in this document, follow this protocol:

1. **Display question** (30 seconds for reading)
2. **Individual vote** — Students vote A/B/C/D silently (no discussion)
3. **Record distribution** — Note percentages on board: A:__% B:__% C:__% D:__%
4. **Decision point:**
   - If **>70% correct**: Brief explanation, move on
   - If **30-70% correct**: Peer discussion (2-3 min), then re-vote
   - If **<30% correct**: Mini-lecture needed before re-vote
5. **Reveal answer** with explanation (2 min)

### Optimal Conditions

- **Target first-vote accuracy:** 40-60% (maximises learning from discussion)
- **Discussion groups:** 2-3 students with different initial answers
- **Re-vote observation:** Record any change; a 20–30% improvement is a historical teaching expectation, not a verified outcome of this package

### Question Notation

Each question includes:
- **Bloom level:** Cognitive level being assessed
- **Misconception target:** Which common error this question tests
- **Distractor analysis:** Why wrong answers are tempting

---

## Contents

1. [find and xargs Questions (PI-01 to PI-05)](#find-and-xargs-questions)
2. [Script Parameters Questions (PI-06 to PI-09)](#script-parameters-questions)
3. [Permissions Questions (PI-10 to PI-14)](#permissions-questions)
4. [Cron Questions (PI-15 to PI-18)](#cron-questions)
5. [Usage Guide](#usage-guide)

---

## FIND AND XARGS QUESTIONS

### PI-01: find vs locate

```
╔══════════════════════════════════════════════════════════════════╗
║  🗳️ PI-01: find vs locate                                        ║
╠══════════════════════════════════════════════════════════════════╣
║                                                                  ║
║  Assume this path was absent from the current locate database and no update occurs.
You just created a file: touch ~/project/config.txt             ║
║  Immediately after, you run: locate config.txt                   ║
║                                                                  ║
║  What happens?                                                   ║
║                                                                  ║
║  A) Finds the file instantly                                     ║
║  B) Does not find the file (database outdated)                   ║
║  C) Error - locate doesn't search in home                        ║
║  D) Finds all config.txt files in the system,                    ║
║     including the new one                                        ║
║                                                                  ║
╚══════════════════════════════════════════════════════════════════╝
```

Correct answer: B

Explanation:
`locate` uses a pre-indexed database (`/var/lib/mlocate/mlocate.db`) that is updated periodically (usually at night via cron). Recently created files don't appear until the next update with `sudo updatedb`.

Demonstration:
```bash
touch ~/test_locate_$(date +%s).txt
locate test_locate    # Doesn't find
sudo updatedb
locate test_locate    # Now finds
```

When to use which:
- `locate` - fast searches when you don't care about recent files
- `find` - real-time searches, complex criteria

---

### PI-02: find with multiple conditions

```
╔══════════════════════════════════════════════════════════════════╗
║  🗳️ PI-02: find with multiple conditions                         ║
╠══════════════════════════════════════════════════════════════════╣
║                                                                  ║
║  What does this command return?                                  ║
║                                                                  ║
║  find . -type f -name "*.txt" -o -name "*.md"                   ║
║                                                                  ║
║  A) All .txt files and all .md files                            ║
║  B) All .txt files and all .md FILES                            ║
║  C) All .txt files and ANY (file or directory) .md              ║
║  D) Syntax error                                                 ║
║                                                                  ║
╚══════════════════════════════════════════════════════════════════╝
```

Correct answer: C

Explanation:
Operator precedence in find: AND has higher precedence than OR.

Interpretation:
```
(-type f AND -name "*.txt") OR (-name "*.md")
```

So it returns:
- Files ending in .txt
- ANY (file or directory) ending in .md

Correct solution:
```bash
find . -type f \( -name "*.txt" -o -name "*.md" \)
```

---

### PI-03: find -exec \; vs +

```
╔══════════════════════════════════════════════════════════════════╗
║  🗳️ PI-03: -exec \; vs +                                         ║
╠══════════════════════════════════════════════════════════════════╣
║                                                                  ║
║  You have 100 short-path .txt files whose combined arguments fit one batch.
How many `cat` processes does each     ║
║  start?                                                          ║
║                                                                  ║
║  find . -name "*.txt" -exec cat {} \;                            ║
║  find . -name "*.txt" -exec cat {} +                             ║
║                                                                  ║
║  A) First: 100 processes, Second: 100 processes                  ║
║  B) First: 100 processes, Second: 1 process                      ║
║  C) First: 1 process, Second: 100 processes                      ║
║  D) Both: 1 process                                              ║
║                                                                  ║
╚══════════════════════════════════════════════════════════════════╝
```

Correct answer: B

Explanation:
- `\;` executes the command for EACH file found (100 × `cat file.txt`)
- `+` groups files into bounded batches (one batch under the stated assumption)

Performance:
- `\;` - slow, many forks
- `+` - fewer invocations here; no universal speed ranking is implied

When to use which:
- `\;` - when command must receive exactly one argument
- `+` - for argument batching (similar to xargs); it also preserves filename boundaries

---

### PI-04: xargs with spaces

```
╔══════════════════════════════════════════════════════════════════╗
║  🗳️ PI-04: xargs with spaces in names                            ║
╠══════════════════════════════════════════════════════════════════╣
║                                                                  ║
║  In a fresh owned directory, the only file is "important document.txt".                       ║
║  You run: find . -name "*.txt" | xargs rm                        ║
║                                                                  ║
║  What happens?                                                   ║
║                                                                  ║
║  A) The file is deleted correctly                                ║
║  B) Error: "important", "document.txt" do not exist              ║
║  C) Deletes all files in the directory                           ║
║  D) xargs ignores files with spaces                              ║
║                                                                  ║
╚══════════════════════════════════════════════════════════════════╝
```

Correct answer: B

Explanation:
xargs by default splits on spaces and newlines. "important document.txt" becomes two arguments:
- "./important"
- "document.txt"

```bash
rm important        # Error: doesn't exist
rm document.txt     # Error: doesn't exist
```

Solution:
```bash
find . -type f -name "*.txt" -print0 | xargs -0 -r rm --
```
- `-print0` - separates with NULL (not newline)
- `-0` - xargs reads with NULL delimiter

---

### PI-05: find -delete vs -exec rm

```
╔══════════════════════════════════════════════════════════════════╗
║  🗳️ PI-05: -delete vs -exec rm                                   ║
╠══════════════════════════════════════════════════════════════════╣
║                                                                  ║
║  Which command requests per-file confirmation before deletion?                            ║
║                                                                  ║
║  A) find . -name "*.tmp" -delete                                 ║
║  B) find . -name "*.tmp" -exec rm {} \;                          ║
║  C) find . -name "*.tmp" -exec rm -i {} \;                       ║
║  D) All are equally safe                                         ║
║                                                                  ║
╚══════════════════════════════════════════════════════════════════╝
```

Correct answer: C

Explanation:
- A) `-delete` - immediate deletion, no confirmation
- B) `-exec rm {}` - immediate deletion, no confirmation
- C) `-exec rm -i {}` - asks for confirmation for EACH file ✓

Best practice:
```bash
# Step 1: See what it will delete
find . -name "*.tmp" -print

# Step 2: If OK, delete
find . -name "*.tmp" -delete
# or with confirmation
find . -name "*.tmp" -exec rm -i {} \;
```

---

## SCRIPT PARAMETERS QUESTIONS

### PI-06: $@ vs $*

```
╔══════════════════════════════════════════════════════════════════╗
║  🗳️ PI-06: $@ vs $*                                              ║
╠══════════════════════════════════════════════════════════════════╣
║                                                                  ║
║  Script:                                                         ║
║  #!/bin/bash                                                     ║
║  for arg in "$@"; do echo "[$arg]"; done                         ║
║  echo "---"                                                      ║
║  for arg in "$*"; do echo "[$arg]"; done                         ║
║                                                                  ║
║  Run: ./script.sh "hello world" test                             ║
║                                                                  ║
║  What does it display?                                           ║
║                                                                  ║
║  A) [hello world] [test] --- [hello world test]                  ║
║  B) [hello] [world] [test] --- [hello] [world] [test]            ║
║  C) [hello world] [test] --- [hello world] [test]                ║
║  D) [hello world test] --- [hello world] [test]                  ║
║                                                                  ║
╚══════════════════════════════════════════════════════════════════╝
```

Correct answer: A

Explanation:
- `"$@"` - each argument is a separate element → iterates correctly
- `"$*"` - all arguments in a single string → one element

Output:
```
[hello world]
[test]
---
[hello world test]
```

Golden rule: Use `"$@"` for iteration!

---

### PI-07: ${10} vs $10

```
╔══════════════════════════════════════════════════════════════════╗
║  🗳️ PI-07: ${10} vs $10                                          ║
╠══════════════════════════════════════════════════════════════════╣
║                                                                  ║
║  Script with arguments: ./script.sh a b c d e f g h i j k        ║
║                                       1 2 3 4 5 6 7 8 9 10 11    ║
║                                                                  ║
║  echo $10                                                        ║
║                                                                  ║
║  What does it display?                                           ║
║                                                                  ║
║  A) j                                                            ║
║  B) a0                                                           ║
║  C) $10 (literal)                                                ║
║  D) Error                                                        ║
║                                                                  ║
╚══════════════════════════════════════════════════════════════════╝
```

Correct answer: B

Explanation:
`$10` is interpreted as `$1` followed by the character `0`.
- `$1` = "a"
- `$1` + "0" = "a0"

Correct:
```bash
echo ${10}    # j
echo ${11}    # k
```

---

### PI-08: shift

```
╔══════════════════════════════════════════════════════════════════╗
║  🗳️ PI-08: What does shift do?                                   ║
╠══════════════════════════════════════════════════════════════════╣
║                                                                  ║
║  #!/bin/bash                                                     ║
║  echo "Before: $1 $2 $3 ($#)"                                    ║
║  shift 2                                                         ║
║  echo "After: $1 $2 $3 ($#)"                                     ║
║                                                                  ║
║  Run: ./script.sh A B C D E                                      ║
║                                                                  ║
║  What does the "After" line display?                             ║
║                                                                  ║
║  A) After: C D E (3)                                             ║
║  B) After: A B C (5)                                             ║
║  C) After: C D  (3)                                              ║
║  D) Error - shift cannot take an argument                        ║
║                                                                  ║
╚══════════════════════════════════════════════════════════════════╝
```

Correct answer: A

Explanation:
`shift 2` removes the first 2 arguments and moves the rest:
- Before: A B C D E (5 arguments)
- After shift 2: C D E (3 arguments)
  - $1 = C (former $3)
  - $2 = D (former $4)
  - $3 = E (former $5)

---

### PI-09: getopts optstring

```
╔══════════════════════════════════════════════════════════════════╗
║  🗳️ PI-09: getopts optstring                                     ║
╠══════════════════════════════════════════════════════════════════╣
║                                                                  ║
║  while getopts "ab:c" opt; do                                    ║
║      echo "$opt - $OPTARG"                                       ║
║  done                                                            ║
║                                                                  ║
║  Run: ./script.sh -a -b value -c                                 ║
║                                                                  ║
║  What does "b:" mean in optstring?                               ║
║                                                                  ║
║  A) Option -b is optional                                        ║
║  B) Option -b requires a mandatory argument                      ║
║  C) Option -b can have an optional argument                      ║
║  D) Option -b is a long option (--b)                             ║
║                                                                  ║
╚══════════════════════════════════════════════════════════════════╝
```

Correct answer: B

Explanation:
In optstring:
- `a` - option -a without argument
- `b:` - option -b WITH mandatory argument
- `c` - option -c without argument

If you run `./script.sh -b` (without argument), getopts returns an error.

---

## PERMISSIONS QUESTIONS

### PI-10: x on directory

```
╔══════════════════════════════════════════════════════════════════╗
║  🗳️ PI-10: What does x on directory mean?                        ║
╠══════════════════════════════════════════════════════════════════╣
║                                                                  ║
║  chmod 700 mydir/                                                ║
║  chmod 600 mydir/                                                ║
║                                                                  ║
║  As the unprivileged owner, select TWO operations that fail.                     ║
║                                                                  ║
║  A) ls mydir/ (list contents)                                    ║
║  B) cd mydir/ (access directory)                                 ║
║  C) cat mydir/file.txt (read file)                              ║
║  D) All of the above                                             ║
║                                                                  ║
╚══════════════════════════════════════════════════════════════════╝
```

Correct answers: B and C (multiple-answer item). Assume readable target files, searchable ancestors, no ACL/security-module exception and plain name listing without extra stat requests.

Explanation:
On directory:
- r (4) = can list contents (ls)
- w (2), together with directory x = can create/delete entries subject to further restrictions
- x (1) = can access the directory (cd) and files within

With 600 (rw-):
- ✓ ls mydir/ - works (has r)
- ✗ cd mydir/ - does NOT work (missing x)
- ✗ cat mydir/file.txt - does NOT work (requires x to access)

---

### PI-11: chmod octal

```
╔══════════════════════════════════════════════════════════════════╗
║  🗳️ PI-11: Calculating chmod octal                               ║
╠══════════════════════════════════════════════════════════════════╣
║                                                                  ║
║  You want a script to have:                                      ║
║  - Owner: read, write, execute                                   ║
║  - Group: read, execute                                          ║
║  - Others: execute only                                          ║
║                                                                  ║
║  What chmod do you use?                                          ║
║                                                                  ║
║  A) chmod 751                                                    ║
║  B) chmod 754                                                    ║
║  C) chmod 715                                                    ║
║  D) chmod 741                                                    ║
║                                                                  ║
╚══════════════════════════════════════════════════════════════════╝
```

Correct answer: A

Calculation:
```
Owner: rwx = 4+2+1 = 7
Group: r-x = 4+0+1 = 5
Others: --x = 0+0+1 = 1

Result: 751
```

---

### PI-12: umask

```
╔══════════════════════════════════════════════════════════════════╗
║  🗳️ PI-12: How does umask work?                                  ║
╠══════════════════════════════════════════════════════════════════╣
║                                                                  ║
║  umask 027                                                       ║
║  touch newfile.txt                                               ║
║                                                                  ║
║  Assume the file does not already exist, creation requests 0666 and no default ACL applies.
What permissions will newfile.txt have?                         ║
║                                                                  ║
║  A) 027 (----w-rwx)                                              ║
║  B) 640 (rw-r-----)                                              ║
║  C) 750 (rwxr-x---)                                              ║
║  D) 027 is not a valid umask                                     ║
║                                                                  ║
╚══════════════════════════════════════════════════════════════════╝
```

Correct answer: B

Explanation:
umask REMOVES bits from default permissions:
- Default files: 666 (rw-rw-rw-)
- umask: 027
- Result: 0666 & ~0027 = 0640 (rw-r-----)

Detailed calculation:
```
Requested: 0666 = rw-rw-rw-
Remove bits present in 0027 = ----w-rwx
Result:    0640 = rw-r-----
Bitwise removal, not arithmetic subtraction.
```

---

### PI-13: SUID

```
╔══════════════════════════════════════════════════════════════════╗
║  🗳️ PI-13: What does SUID mean?                                  ║
╠══════════════════════════════════════════════════════════════════╣
║                                                                  ║
║  ls -l /usr/bin/passwd                                           ║
║  -rwsr-xr-x 1 root root ... /usr/bin/passwd                      ║
║                                                                  ║
║  What does 's' in the owner execute position mean?               ║
║                                                                  ║
║  A) The file is a symlink                                        ║
║  B) The file runs with owner's (root) permissions                ║
║  C) The file is sticky (cannot be deleted)                       ║
║  D) The file is shared between users                             ║
║                                                                  ║
╚══════════════════════════════════════════════════════════════════╝
```

Correct answer: B

Explanation:
SUID (Set User ID) makes the process run with the file owner's permissions, not those of the user executing it.

Why does /usr/bin/passwd have SUID?
- passwd needs to modify /etc/shadow
- /etc/shadow is owned by root and not writable by normal users
- With SUID, when you run passwd, the process has root's permissions

---

### PI-14: Sticky Bit

```
╔══════════════════════════════════════════════════════════════════╗
║  🗳️ PI-14: Sticky Bit on /tmp                                    ║
╠══════════════════════════════════════════════════════════════════╣
║                                                                  ║
║  ls -ld /tmp                                                     ║
║  drwxrwxrwt 15 root root ... /tmp                                ║
║                                                                  ║
║  User "alice" creates /tmp/alice_file.txt                        ║
║  User "bob" tries: rm /tmp/alice_file.txt                        ║
║                                                                  ║
║  What happens?                                                   ║
║                                                                  ║
║  A) File is deleted (bob has w on /tmp)                          ║
║  B) Permission denied (sticky bit protects)                      ║
║  C) Bob is asked if he wants to delete                           ║
║  D) File becomes owned by bob                                    ║
║                                                                  ║
╚══════════════════════════════════════════════════════════════════╝
```

Correct answer: B

Explanation:
Sticky bit ('t' in others execute) on directory:
- Everyone can create files (has w)
- File owner, directory owner or appropriate privilege may remove entries; Bob is assumed to have neither ownership nor that privilege

Without sticky bit, bob could delete anything in /tmp (because he has write on directory).

---

## CRON QUESTIONS

### PI-15: Crontab syntax

```
╔══════════════════════════════════════════════════════════════════╗
║  🗳️ PI-15: Crontab interpretation                                ║
╠══════════════════════════════════════════════════════════════════╣
║                                                                  ║
║  */15 9-17 * * 1-5 /path/to/script.sh                           ║
║                                                                  ║
║  When does this job run?                                         ║
║                                                                  ║
║  A) Every 15 minutes, 24/7                                       ║
║  B) Every 15 minutes, from 09:00 through 17:45, Monday-Friday          ║
║  C) At hour 15, between 9 and 17, days 1-5 of month              ║
║  D) 15 times per hour, on working days                           ║
║                                                                  ║
╚══════════════════════════════════════════════════════════════════╝
```

Correct answer: B

Explanation:
```
*/15    = every 15 minutes (0, 15, 30, 45)
9-17    = hours 9:00-17:59
*       = any day of month
*       = any month
1-5     = Monday-Friday
```

Result: 09:00, 09:15, …, 17:00, 17:15, 17:30 and 17:45 on Monday–Friday.

---

### PI-16: */5 vs 5

```
╔══════════════════════════════════════════════════════════════════╗
║  🗳️ PI-16: Difference */5 vs 5                                   ║
╠══════════════════════════════════════════════════════════════════╣
║                                                                  ║
║  "minute" field in crontab:                                      ║
║  A) */5 * * * *                                                  ║
║  B) 5 * * * *                                                    ║
║                                                                  ║
║  What's the difference?                                          ║
║                                                                  ║
║  A) They are identical                                           ║
║  B) A: every 5 min; B: minute 5 of each hour                    ║
║  C) A: minute 5; B: every 5 minutes                              ║
║  D) A: 5 times per hour; B: once per hour                        ║
║                                                                  ║
╚══════════════════════════════════════════════════════════════════╝
```

Correct answer: B

Explanation:
- `*/5` = every 5 minutes (0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55)
- `5` = only at minute 5 of each hour (14:05, 15:05, 16:05...)

---

### PI-17: Cron environment

```
╔══════════════════════════════════════════════════════════════════╗
║  🗳️ PI-17: Why doesn't my cron job work?                         ║
╠══════════════════════════════════════════════════════════════════╣
║                                                                  ║
║  In terminal: ./backup.sh works perfectly                        ║
║  In crontab:  * * * * * ./backup.sh - does nothing               ║
║                                                                  ║
║  What is the most likely cause?                                  ║
║                                                                  ║
║  A) Cron cannot run bash scripts                                 ║
║  B) Missing execute permission                                   ║
║  C) Relative path resolves in /home/user rather than /home/user/scripts          ║
║  D) Cron only runs in the morning                                ║
║                                                                  ║
╚══════════════════════════════════════════════════════════════════╝
```

Correct answer: C

Explanation:
Cron runs with a minimal environment:
- Limited PATH
- HOME normally comes from the user account on Debian/Ubuntu cron
- The job has a working directory, but it is not the directory of your interactive session

Solution:
```cron
# Use absolute paths
* * * * * /home/user/scripts/backup.sh

# Or set PATH in crontab
PATH=/usr/local/bin:/usr/bin:/bin
* * * * * backup.sh
```

---

### PI-18: @reboot

```
╔══════════════════════════════════════════════════════════════════╗
║  🗳️ PI-18: @reboot in crontab                                    ║
╠══════════════════════════════════════════════════════════════════╣
║                                                                  ║
║  @reboot /home/user/start_service.sh                             ║
║                                                                  ║
║  When does this job run?                                         ║
║                                                                  ║
║  A) At every restart of the cron service                         ║
║  B) At system startup (boot)                                     ║
║  C) Every minute                                                 ║
║  D) When the user logs in                                        ║
║                                                                  ║
╚══════════════════════════════════════════════════════════════════╝
```

Correct answer: B

Explanation:
`@reboot` is a special string meaning "at system startup".

Other special strings:
- @yearly, @annually - 1 January
- @monthly - first day of month
- @weekly - Sunday
- @daily, @midnight - midnight
- @hourly - every hour

---

## USAGE GUIDE

### Peer Instruction Protocol

1. [1-2 min] Display the question
2. [1 min] Individual vote (raised hands / app)
3. [2 min] If no consensus (>80%), pair discussion
4. [1 min] Final vote
5. [2 min] Explanation and demonstration

### Interpreting Results

| Correct | Action |
|---------|--------|
| >80% | Short explanation, continue |
| 40-80% | Pair discussion, re-vote |
| <40% | Stop, explain concept from scratch |

### Tips for Instructor

1. Don't reveal the answer before voting
2. Encourage argumentation in pairs
3. Use live demonstrations after explanation
4. Ask "Who changed their answer after discussion?"

---

*Material created for Seminar 3 OS | Bucharest UES - CSIE*
