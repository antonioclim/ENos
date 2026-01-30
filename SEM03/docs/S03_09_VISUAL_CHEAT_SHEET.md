# VISUAL CHEAT SHEET: Utilities, Scripts, Permissions, Cron
## Seminar 03 | Operating Systems | UES Bucharest - CSIE

> **Quick reference** - Print this document (2-3 pages) for instant access to all commands

---

# MODULE 1: FIND AND XARGS

## 1.1 General find Syntax

```
┌─────────────────────────────────────────────────────────────────────┐
│                    FIND COMMAND STRUCTURE                           │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│   find [PATH] [EXPRESSIONS] [ACTIONS]                              │
│         │         │           │                                     │
│         │         │           └── What you do with results          │
│         │         └── Filter criteria (tests)                       │
│         └── Where you search (default: current directory)           │
│                                                                     │
│   COMPLETE EXAMPLE:                                                 │
│   find /var/log -type f -name "*.log" -size +10M -exec ls -lh {} \; │
│        └─PATH──┘ └─────────EXPRESSIONS────────────┘ └────ACTION────┘ │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

## 1.2 find Tests - By Name

*(`find` combined with `-exec` is extremely useful. Once you master it, you can't do without it.)*


```
┌────────────────────────────────────────────────────────────────────┐
│ TEST           │ DESCRIPTION                  │ EXAMPLE            │
├────────────────┼──────────────────────────────┼────────────────────┤
│ -name PATTERN  │ Exact match (case sensitive) │ -name "*.txt"      │
│ -iname PATTERN │ Case insensitive             │ -iname "*.TXT"     │
│ -path PATTERN  │ Match complete path          │ -path "*src/*.c"   │
│ -regex PATTERN │ Regex on complete path       │ -regex ".*\\.log$" │
└────────────────────────────────────────────────────────────────────┘

⚠️  Trap: Use QUOTES for patterns!
    CORRECT:  find . -name "*.txt"
    WRONG:    find . -name *.txt  ← shell expands before find!
```

## 1.3 find Tests - By Type

```
┌─────────────────────────────────────────────────────────────────┐
│                     -type CHARACTER                             │
├──────┬──────────────────────────────────────────────────────────┤
│  f   │ Regular file                    find . -type f           │
│  d   │ Directory                       find . -type d           │
│  l   │ Symbolic link                   find . -type l           │
│  b   │ Block device (hard disk)        find /dev -type b        │
│  c   │ Character device (terminal)     find /dev -type c        │
│  p   │ Named pipe (FIFO)               find /tmp -type p        │
│  s   │ Socket                          find /var -type s        │
└──────┴──────────────────────────────────────────────────────────┘
```

## 1.4 find Tests - By Size

```
┌───────────────────────────────────────────────────────────────────┐
│                    -size [+/-]N[SUFFIX]                           │
├───────────────────────────────────────────────────────────────────┤
│                                                                   │
│ SUFFIXES:   c = bytes      k = KB      M = MB      G = GB        │
│                                                                   │
│ PREFIXES:   +N = larger than N                                   │
│             -N = smaller than N                                  │
│              N = exactly N                                       │
│                                                                   │
├───────────────────────────────────────────────────────────────────┤
│ EXAMPLES:                                                         │
│   -size +100M     │ Larger than 100 MB                           │
│   -size -1k       │ Smaller than 1 KB                            │
│   -size 0         │ Empty files                                  │
│   -size +1G       │ Larger than 1 GB (careful with HDD!)         │
└───────────────────────────────────────────────────────────────────┘
```

## 1.5 find Tests - By Time

```
┌───────────────────────────────────────────────────────────────────┐
│                    TIME-BASED TESTS                               │
├────────────┬──────────────────────────────────────────────────────┤
│            │                    UNIT                              │
│ ATTRIBUTE  ├────────────────────┬─────────────────────────────────┤
│            │   DAYS (-time)     │   MINUTES (-min)               │
├────────────┼────────────────────┼─────────────────────────────────┤
│ Modification │ -mtime           │ -mmin                           │
│ Access       │ -atime           │ -amin                           │
│ Change*      │ -ctime           │ -cmin                           │
└────────────┴────────────────────┴─────────────────────────────────┘
* ctime = change time (metadata, not content)

VALUE INTERPRETATION:
┌─────────────────────────────────────────────────────────────────┐
│  -mtime 0   │ Modified in the last 24 hours                     │
│  -mtime 1   │ Modified between 24-48 hours ago                  │
│  -mtime +7  │ Modified more than 7 days ago                     │
│  -mtime -7  │ Modified in the last 7 days                       │
└─────────────────────────────────────────────────────────────────┘

OTHER TEMPORAL TESTS:
  -newer FILE    │ Newer than FILE
  -newermt DATE  │ Newer than specified date
```

## 1.6 find Tests - By Permissions and Owner

```
┌───────────────────────────────────────────────────────────────────┐
│                  PERMISSION AND OWNERSHIP TESTS                   │
├───────────────────────────────────────────────────────────────────┤
│ -perm MODE    │ Permissions EXACTLY mode                         │
│ -perm -MODE   │ All bits in mode are set                         │
│ -perm /MODE   │ At least ONE bit in mode is set                  │
├───────────────────────────────────────────────────────────────────┤
│ -user NAME    │ Owner is NAME (or UID)                           │
│ -group NAME   │ Group is NAME (or GID)                           │
│ -nouser       │ Files without valid owner                        │
│ -nogroup      │ Files without valid group                        │
└───────────────────────────────────────────────────────────────────┘

PERMISSION EXAMPLES:
  find . -perm 644        # Exactly rw-r--r--
  find . -perm -u+x       # Owner has execute
  find . -perm /o+w       # Others have write (DANGEROUS!)
  find . -perm -4000      # SUID set
  find . -perm -2000      # SGID set
```

## 1.7 find Logical Operators

```
┌───────────────────────────────────────────────────────────────────┐
│                    LOGICAL OPERATORS                              │
├───────────────────────────────────────────────────────────────────┤
│                                                                   │
│   AND:  implicit (or -a)     find . -type f -name "*.c"          │
│                                                                   │
│   OR:   -o                   find . -name "*.c" -o -name "*.h"   │
│                                                                   │
│   NOT:  ! or -not            find . ! -name "*.txt"              │
│                                                                   │
│   GROUPING: \( ... \)        find . \( -name "*.c" -o \          │
│                                        -name "*.h" \) -mtime -7  │
│                                                                   │
└───────────────────────────────────────────────────────────────────┘

⚠️  Spaces mandatory around \( and \)
⚠️  Backslash to escape in shell
```

## 1.8 find Actions

```
┌───────────────────────────────────────────────────────────────────┐
│                        ACTIONS                                    │
├───────────────────────────────────────────────────────────────────┤
│ -print         │ Display path (default)                          │
│ -print0        │ Display with null terminator (for xargs -0)     │
│ -ls            │ ls -l format                                    │
│ -printf FORMAT │ Custom format                                   │
│ -delete        │ Delete (⚠️ CAUTION!)                            │
│ -exec CMD {} \;│ Execute CMD for each file                       │
│ -exec CMD {} + │ Execute CMD with all files (batch)              │
│ -ok CMD {} \;  │ Like -exec but asks for confirmation            │
└───────────────────────────────────────────────────────────────────┘

-printf SPECIFIERS:
  %p - complete path       %f - filename
  %s - size (bytes)        %M - permissions (rwx)
  %u - owner name          %g - group name
  %T+ - modification time  %m - permissions (octal)
  \n - newline             \t - tab

EXAMPLE:
  find . -type f -printf '%M %u %s %p\n'
```

## 1.9 xargs - Syntax and Options

```
┌───────────────────────────────────────────────────────────────────┐
│                         XARGS                                     │
├───────────────────────────────────────────────────────────────────┤
│                                                                   │
│   cmd | xargs [OPTIONS] COMMAND                                  │
│                                                                   │
│   Input (stdin) → xargs → Arguments for COMMAND                  │
│                                                                   │
├───────────────────────────────────────────────────────────────────┤
│ OPTION         │ EFFECT                                          │
├────────────────┼─────────────────────────────────────────────────┤
│ -0             │ Null-delimited input (with find -print0)        │
│ -n NUM         │ Maximum NUM arguments per execution             │
│ -I{}           │ Placeholder for substitution                    │
│ -P NUM         │ Run NUM processes in parallel                   │
│ -t             │ Verbose - display executed command              │
│ -p             │ Interactive - ask for confirmation              │
│ -L NUM         │ Maximum NUM lines per execution                 │
└───────────────────────────────────────────────────────────────────┘

ESSENTIAL PATTERN (SPACES IN NAMES):
  find . -name "*.txt" -print0 | xargs -0 rm

PARALLELISM:
  find . -name "*.jpg" -print0 | xargs -0 -P4 -I{} convert {} {}.png
```

## 1.10 locate vs find

```
┌───────────────────────────────────────────────────────────────────┐
│                    LOCATE vs FIND                                 │
├─────────────────────┬─────────────────────────────────────────────┤
│      LOCATE         │              FIND                           │
├─────────────────────┼─────────────────────────────────────────────┤
│ Searches database   │ Searches live in filesystem                │
│ Very fast           │ Slower (traverses directories)             │
│ Can be outdated     │ Always current                             │
│ Only by name        │ Multiple criteria (size, time etc.)        │
│ Requires updatedb   │ No setup required                          │
└─────────────────────┴─────────────────────────────────────────────┘

locate COMMANDS:
  locate PATTERN      # Search pattern
  locate -i PATTERN   # Case insensitive
  locate -c PATTERN   # Count only
  sudo updatedb       # Update database
```

---

# MODULE 2: SCRIPT PARAMETERS

## 2.1 Special Variables

```
┌───────────────────────────────────────────────────────────────────┐
│                  BASH SPECIAL VARIABLES                           │
├────────┬──────────────────────────────────────────────────────────┤
│  $0    │ Script name                                             │
│  $1-$9 │ Arguments 1-9                                           │
│ ${10}+ │ Arguments 10+ (with braces!)                            │
│  $#    │ Number of arguments                                     │
│  $@    │ All arguments (as array)                                │
│  $*    │ All arguments (as string)                               │
│  $?    │ Exit status of last command                             │
│  $$    │ PID of current process                                  │
│  $!    │ PID of last background process                          │
└────────┴──────────────────────────────────────────────────────────┘

⚠️  CRITICAL DIFFERENCE "$@" vs "$*":

┌───────────────────────────────────────────────────────────────────┐
│ Run: ./script.sh "arg one" "arg two"                             │
├───────────────────────────────────────────────────────────────────┤
│ "$@" → "arg one" "arg two"    (2 separate arguments)             │
│ "$*" → "arg one arg two"      (1 concatenated string)            │
└───────────────────────────────────────────────────────────────────┘
RULE: Always use "$@" in loops!
```

## 2.2 shift - Iterative Processing

```
┌───────────────────────────────────────────────────────────────────┐
│                        SHIFT                                      │
├───────────────────────────────────────────────────────────────────┤
│                                                                   │
│   shift      # Remove $1, $2 becomes $1, etc.                    │
│   shift N    # Remove first N arguments                          │
│                                                                   │
│   BEFORE:    $1="a"  $2="b"  $3="c"   $#=3                       │
│   shift                                                          │
│   AFTER:     $1="b"  $2="c"           $#=2                       │
│                                                                   │
└───────────────────────────────────────────────────────────────────┘

COMMON PATTERN:
┌────────────────────────────────────────┐
│ while [ $# -gt 0 ]; do                 │
│     echo "Processing: $1"              │
│     shift                              │
│ done                                   │
└────────────────────────────────────────┘
```

## 2.3 Expansions with Default

```
┌───────────────────────────────────────────────────────────────────┐
│              PARAMETER EXPANSIONS                                 │
├────────────────────┬──────────────────────────────────────────────┤
│ ${VAR:-default}    │ Use default if VAR is empty/unset           │
│ ${VAR:=default}    │ Set VAR to default if empty/unset           │
│ ${VAR:+alternate}  │ Use alternate if VAR is NOT empty           │
│ ${VAR:?error msg}  │ Error if VAR is empty                       │
├────────────────────┼──────────────────────────────────────────────┤
│ ${#VAR}            │ Length of VAR value                         │
│ ${VAR%pattern}     │ Remove shortest suffix                      │
│ ${VAR%%pattern}    │ Remove longest suffix                       │
│ ${VAR#pattern}     │ Remove shortest prefix                      │
│ ${VAR##pattern}    │ Remove longest prefix                       │
└───────────────────────────────────────────────────────────────────┘

EXAMPLES:
  OUTPUT=${1:-"output.txt"}    # Default output.txt
  : ${DEBUG:=false}            # Set DEBUG to false if missing
  FILE="${path##*/}"           # Extract filename from path
  DIR="${path%/*}"             # Extract directory from path
```

## 2.4 getopts - Option Parsing

```
┌───────────────────────────────────────────────────────────────────┐
│                        GETOPTS                                    │
├───────────────────────────────────────────────────────────────────┤
│                                                                   │
│   while getopts "OPTSTRING" opt; do                              │
│       case $opt in                                                │
│           x) ... ;;                                               │
│       esac                                                        │
│   done                                                            │
│   shift $((OPTIND - 1))   # Move to non-option arguments         │
│                                                                   │
├───────────────────────────────────────────────────────────────────┤
│ OPTSTRING SYNTAX:                                                 │
│   "abc"    → -a, -b, -c without arguments                        │
│   "a:bc"   → -a requires argument, -b -c don't                   │
│   ":abc"   → Silent mode (: at beginning)                        │
└───────────────────────────────────────────────────────────────────┘

SPECIAL VARIABLES:
  $opt     - current option
  $OPTARG  - option argument (when option has :)
  $OPTIND  - index of next argument to process

COMPLETE EXAMPLE:
┌─────────────────────────────────────────────────────────────────┐
│ #!/bin/bash                                                     │
│ verbose=false                                                   │
│ output=""                                                       │
│                                                                 │
│ while getopts ":hvo:n:" opt; do                                │
│     case $opt in                                                │
│         h) usage; exit 0 ;;                                     │
│         v) verbose=true ;;                                      │
│         o) output="$OPTARG" ;;                                  │
│         n) count="$OPTARG" ;;                                   │
│         :) echo "Option -$OPTARG requires argument" ;;          │
│         \?) echo "Invalid option: -$OPTARG" ;;                  │
│     esac                                                        │
│ done                                                            │
│ shift $((OPTIND - 1))                                          │
│ # Now $@ contains non-option arguments                          │
└─────────────────────────────────────────────────────────────────┘
```

## 2.5 Long Options - Manual Pattern

```
┌───────────────────────────────────────────────────────────────────┐
│                  LONG OPTIONS (MANUAL)                            │
├───────────────────────────────────────────────────────────────────┤
│ while [ $# -gt 0 ]; do                                           │
│     case "$1" in                                                 │
│         -h|--help)                                               │
│             usage; exit 0 ;;                                     │
│         -v|--verbose)                                            │
│             verbose=true; shift ;;                               │
│         -o|--output)                                             │
│             output="$2"; shift 2 ;;                              │
│         --output=*)                                              │
│             output="${1#*=}"; shift ;;                           │
│         --)                                                      │
│             shift; break ;;                                      │
│         -*)                                                      │
│             echo "Unknown option: $1"; exit 1 ;;                 │
│         *)                                                       │
│             break ;;                                             │
│     esac                                                         │
│ done                                                             │
└───────────────────────────────────────────────────────────────────┘
```

---

# MODULE 3: UNIX PERMISSIONS

## 3.1 Permission Structure

```
┌───────────────────────────────────────────────────────────────────┐
│                    PERMISSION STRUCTURE                           │
├───────────────────────────────────────────────────────────────────┤
│                                                                   │
│   -rwxr-xr--  1  user  group  1234  Jan 15 10:00  filename       │
│   │└┬┘└┬┘└┬┘     │     │                                         │
│   │ │  │  │      │     └── Owner group                           │
│   │ │  │  │      └── Owner (proprietor)                          │
│   │ │  │  └── Others (o) - everyone else                         │
│   │ │  └── Group (g) - the group                                 │
│   │ └── User/Owner (u) - the owner                               │
│   └── File type (- file, d directory, l link)                    │
│                                                                   │
├───────────────────────────────────────────────────────────────────┤
│                    BIT MEANINGS                                   │
├─────────┬──────────────────────┬──────────────────────────────────┤
│  BIT    │    ON FILE           │    ON DIRECTORY                  │
├─────────┼──────────────────────┼──────────────────────────────────┤
│  r (4)  │ Read content         │ List content (ls)                │
│  w (2)  │ Modify content       │ Create/delete files              │
│  x (1)  │ Execute              │ Access (cd) into directory       │
└─────────┴──────────────────────┴──────────────────────────────────┘

⚠️  x on directory ≠ execute! It means ACCESS!
⚠️  To delete a file, you need w on DIRECTORY, not on file!
```

## 3.2 chmod - Octal Mode

```
┌───────────────────────────────────────────────────────────────────┐
│                    CHMOD OCTAL                                    │
├───────────────────────────────────────────────────────────────────┤
│                                                                   │
│   chmod ABC file                                                 │
│         │││                                                       │
│         ││└── Others (o)                                         │
│         │└── Group (g)                                           │
│         └── User/Owner (u)                                       │
│                                                                   │
│   CALCULATION:  r = 4    w = 2    x = 1                          │
│                                                                   │
│   rwx = 4+2+1 = 7    rw- = 4+2 = 6    r-x = 4+1 = 5             │
│   r-- = 4            -wx = 3          --x = 1                    │
│                                                                   │
├───────────────────────────────────────────────────────────────────┤
│                 COMMON PERMISSIONS                                │
├────────┬─────────────┬────────────────────────────────────────────┤
│  755   │ rwxr-xr-x   │ Executable scripts, directories           │
│  644   │ rw-r--r--   │ Text files, configurations                │
│  600   │ rw-------   │ Private files (SSH keys)                  │
│  700   │ rwx------   │ Private directories                       │
│  750   │ rwxr-x---   │ Scripts for group                         │
│  640   │ rw-r-----   │ Group-readable files                      │
│  444   │ r--r--r--   │ Read-only for all                         │
│  777   │ rwxrwxrwx   │ ⚠️ NEVER! VULNERABILITY!                   │
└────────┴─────────────┴────────────────────────────────────────────┘
```

## 3.3 chmod - Symbolic Mode

```
┌───────────────────────────────────────────────────────────────────┐
│                    CHMOD SYMBOLIC                                 │
├───────────────────────────────────────────────────────────────────┤
│                                                                   │
│   chmod [WHO][OPERATOR][WHAT] file                               │
│                                                                   │
│   WHO:      u = owner    g = group    o = others    a = all      │
│   OPERATOR: + = add      - = remove   = = set exactly            │
│   WHAT:     r = read     w = write    x = execute                │
│                          X = execute only if directory            │
│                                                                   │
├───────────────────────────────────────────────────────────────────┤
│ EXAMPLES:                                                         │
│   chmod u+x script.sh        # Add execute for owner             │
│   chmod go-w file.txt        # Remove write for group+others     │
│   chmod a+r file.txt         # Add read for all                  │
│   chmod u=rwx,g=rx,o=r file  # Set explicitly: 754               │
│   chmod -R u+rwX,go-w dir/   # Recursive, X only for directories │
└───────────────────────────────────────────────────────────────────┘
```

## 3.4 umask - Default Permissions

```
┌───────────────────────────────────────────────────────────────────┐
│                         UMASK                                     │
├───────────────────────────────────────────────────────────────────┤
│                                                                   │
│   umask SPECIFIES WHAT IS REMOVED, NOT WHAT IS SET!              │
│                                                                   │
│   System default values:                                         │
│   - Files: 666 (rw-rw-rw-)                                       │
│   - Directories: 777 (rwxrwxrwx)                                 │
│                                                                   │
│   Final permissions = Default - umask                            │
│                                                                   │
├───────────────────────────────────────────────────────────────────┤
│ EXAMPLES:                                                         │
│                                                                   │
│   umask 022:                                                      │
│   - Files:       666 - 022 = 644 (rw-r--r--)                     │
│   - Directories: 777 - 022 = 755 (rwxr-xr-x)                     │
│                                                                   │
│   umask 077:                                                      │
│   - Files:       666 - 077 = 600 (rw-------)                     │
│   - Directories: 777 - 077 = 700 (rwx------)                     │
│                                                                   │
│   umask 027:                                                      │
│   - Files:       666 - 027 = 640 (rw-r-----)                     │
│   - Directories: 777 - 027 = 750 (rwxr-x---)                     │
│                                                                   │
└───────────────────────────────────────────────────────────────────┘

COMMANDS:
  umask           # Display current umask
  umask -S        # Display in symbolic format
  umask 077       # Set umask
  
PERSISTENCE: Add to ~/.bashrc for permanence
```

## 3.5 Special Permissions

```
┌───────────────────────────────────────────────────────────────────┐
│                  SPECIAL PERMISSIONS                              │
├───────────────────────────────────────────────────────────────────┤
│                                                                   │
│   SUID (Set User ID)     - 4xxx - chmod u+s or chmod 4755        │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │ On file: Executes with OWNER's permissions, not user's     │ │
│   │ Example: /usr/bin/passwd (-rwsr-xr-x) runs as root         │ │
│   │ ⚠️ Does NOT work on bash scripts (security)                │ │
│   │ Display: 's' in owner's x position                         │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                   │
│   SGID (Set Group ID)    - 2xxx - chmod g+s or chmod 2755        │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │ On file: Executes with GROUP's permissions                 │ │
│   │ On directory: New files inherit directory's GROUP          │ │
│   │ Useful for shared directories between teams                │ │
│   │ Display: 's' in group's x position                         │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                   │
│   Sticky Bit             - 1xxx - chmod +t or chmod 1755         │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │ On directory: Only file's owner can delete it              │ │
│   │ Example: /tmp (drwxrwxrwt) - all can write, only owner     │ │
│   │          of own file can delete                            │ │
│   │ Display: 't' in others' x position                         │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                   │
├───────────────────────────────────────────────────────────────────┤
│ CHMOD WITH SPECIALS:                                              │
│   chmod 4755 file  # SUID + rwxr-xr-x                            │
│   chmod 2755 dir   # SGID + rwxr-xr-x                            │
│   chmod 1755 dir   # Sticky + rwxr-xr-x                          │
│   chmod 3770 dir   # SGID + Sticky + rwxrwx---                   │
└───────────────────────────────────────────────────────────────────┘
```

## 3.6 chown and chgrp

```
┌───────────────────────────────────────────────────────────────────┐
│                    CHOWN AND CHGRP                                │
├───────────────────────────────────────────────────────────────────┤
│                                                                   │
│   chown [OPTIONS] OWNER[:GROUP] FILE                             │
│                                                                   │
│   EXAMPLES:                                                       │
│   chown user file              # Change owner only               │
│   chown user:group file        # Change owner and group          │
│   chown :group file            # Change group only               │
│   chown -R user:group dir/     # Recursive                       │
│                                                                   │
│   chgrp [OPTIONS] GROUP FILE                                     │
│   chgrp developers file        # Change group                    │
│   chgrp -R developers dir/     # Recursive                       │
│                                                                   │
└───────────────────────────────────────────────────────────────────┘

⚠️  chown usually requires sudo (only root can change owner)
⚠️  chgrp can be used without sudo if you're a member of the group
```

---

# MODULE 4: CRON AND AUTOMATION

## 4.1 Crontab Format

```
┌───────────────────────────────────────────────────────────────────┐
│                    CRONTAB FORMAT                                 │
├───────────────────────────────────────────────────────────────────┤
│                                                                   │
│  ┌────────── minute (0-59)                                       │
│  │ ┌──────── hour (0-23)                                         │
│  │ │ ┌────── day of month (1-31)                                 │
│  │ │ │ ┌──── month (1-12)                                        │
│  │ │ │ │ ┌── day of week (0-7, 0 and 7 = Sunday)                 │
│  │ │ │ │ │                                                        │
│  * * * * *  command                                              │
│                                                                   │
├───────────────────────────────────────────────────────────────────┤
│ SPECIAL CHARACTERS:                                               │
│                                                                   │
│   *      │ Any value                                             │
│   ,      │ List of values          (1,3,5)                       │
│   -      │ Range                   (1-5)                         │
│   /      │ Step                    (*/5 = every 5)               │
│                                                                   │
└───────────────────────────────────────────────────────────────────┘

COMMON EXAMPLES:
┌────────────────────┬─────────────────────────────────────────────┐
│ 0 * * * *          │ Every hour, at minute 0                    │
│ */15 * * * *       │ Every 15 minutes                           │
│ 0 3 * * *          │ Daily at 3:00 AM                           │
│ 0 0 * * 0          │ Sunday at midnight                         │
│ 0 9-17 * * 1-5     │ Monday-Friday, 9-17, every hour            │
│ 30 4 1,15 * *      │ On 1st and 15th of month, at 4:30 AM       │
│ 0 0 1 1 *          │ 1 January at midnight                      │
│ */5 9-17 * * 1-5   │ Every 5 min, 9-17, Monday-Friday          │
└────────────────────┴─────────────────────────────────────────────┘
```

## 4.2 Cron Special Strings

```
┌───────────────────────────────────────────────────────────────────┐
│                  SPECIAL STRINGS                                  │
├──────────────┬────────────────────────────────────────────────────┤
│ @reboot      │ At system startup                                 │
│ @yearly      │ 0 0 1 1 * (1 Jan, 00:00)                          │
│ @annually    │ (synonym for @yearly)                             │
│ @monthly     │ 0 0 1 * * (first day of month)                    │
│ @weekly      │ 0 0 * * 0 (Sunday, 00:00)                         │
│ @daily       │ 0 0 * * * (daily, 00:00)                          │
│ @midnight    │ (synonym for @daily)                              │
│ @hourly      │ 0 * * * * (every hour)                            │
└──────────────┴────────────────────────────────────────────────────┘
```

## 4.3 crontab Commands

```
┌───────────────────────────────────────────────────────────────────┐
│                  CRONTAB COMMANDS                                 │
├───────────────────────────────────────────────────────────────────┤
│ crontab -e         │ Edit current user's crontab                 │
│ crontab -l         │ List current crontab                        │
│ crontab -r         │ ⚠️ DELETE ALL crontab! (no confirmation)    │
│ crontab -u USER -e │ Edit another user's crontab (root)          │
│ crontab file       │ Install crontab from file                   │
└───────────────────────────────────────────────────────────────────┘

⚠️  crontab -r deletes EVERYTHING without confirmation!
    Use: crontab -l > backup.cron before modifications
```

## 4.4 Cron Best Practices

```
┌───────────────────────────────────────────────────────────────────┐
│                  CRON BEST PRACTICES                              │
├───────────────────────────────────────────────────────────────────┤
│                                                                   │
│ 1. ABSOLUTE PATHS                                                 │
│    ✗ 0 3 * * * backup.sh                                         │
│    ✓ 0 3 * * * /home/user/scripts/backup.sh                      │
│                                                                   │
│ 2. SET PATH                                                       │
│    PATH=/usr/local/bin:/usr/bin:/bin                             │
│    0 3 * * * backup.sh                                           │
│                                                                   │
│ 3. LOGGING                                                        │
│    0 3 * * * /path/script.sh >> /var/log/script.log 2>&1         │
│                                                                   │
│ 4. PREVENT MULTIPLE EXECUTIONS (lock file)                        │
│    0 * * * * flock -n /tmp/script.lock /path/script.sh           │
│                                                                   │
│ 5. TEST BEFORE                                                    │
│    0 3 * * * echo "Test at $(date)" >> /tmp/test.log             │
│                                                                   │
└───────────────────────────────────────────────────────────────────┘
```

## 4.5 The at Command

```
┌───────────────────────────────────────────────────────────────────┐
│                  AT COMMAND (One-time jobs)                       │
├───────────────────────────────────────────────────────────────────┤
│                                                                   │
│   at TIME                   │ Schedule job (interactive)         │
│   at -f script.sh TIME      │ Schedule from file                 │
│   atq                       │ List jobs in queue                 │
│   atrm JOB_ID               │ Delete a job                       │
│   batch                     │ Run when load is low               │
│                                                                   │
├───────────────────────────────────────────────────────────────────┤
│ TIME FORMATS:                                                     │
│   at now + 5 minutes                                             │
│   at now + 2 hours                                               │
│   at 3:00 PM                                                     │
│   at 15:00                                                       │
│   at midnight                                                    │
│   at noon tomorrow                                               │
│   at 3:00 PM January 20                                          │
│   at teatime  (16:00)                                            │
└───────────────────────────────────────────────────────────────────┘

INTERACTIVE EXAMPLE:
  $ at now + 10 minutes
  at> echo "Reminder!" | mail -s "Task" user@example.com
  at> <Ctrl+D>
```

---

*Document generated for UES Bucharest - CSIE | Operating Systems | Seminar 3*
