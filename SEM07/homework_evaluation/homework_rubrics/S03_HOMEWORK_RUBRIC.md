# S03 Homework Rubric

> **Operating Systems** | ASE Bucharest - CSIE  
> Seminar 03: File Management and Automation

---

## Assignment Overview

| ID | Topic | Duration | Difficulty |
|----|-------|----------|------------|
| S03b | Find and Locate | 45 min | ⭐⭐ |
| S03c | Xargs Advanced | 40 min | ⭐⭐⭐ |
| S03d | Script Parameters | 45 min | ⭐⭐ |
| S03e | Getopts CLI | 50 min | ⭐⭐⭐ |
| S03f | Unix Permissions | 45 min | ⭐⭐ |
| S03g | CRON Automation | 40 min | ⭐⭐ |

---

## S03b - Find and Locate (10 points)

| Criterion | Points | Requirements |
|-----------|--------|--------------|
| Basic find | 2.5 | -name, -type, -size |
| Time predicates | 2.0 | -mtime, -atime, -newer |
| Actions | 2.0 | -exec, -delete, -print |
| Logical operators | 2.0 | -o, -a, ! |
| Locate usage | 1.5 | locate, updatedb |

---

## S03c - Xargs Advanced (10 points)

| Criterion | Points | Requirements |
|-----------|--------|--------------|
| Basic xargs | 2.5 | Pipe to xargs |
| Placeholder -I | 2.5 | Custom substitution |
| Parallel -P | 2.0 | Multi-process execution |
| Null delimiter | 1.5 | -0 with find -print0 |
| Error handling | 1.5 | -r, exit codes |

---

## S03d - Script Parameters (10 points)

| Criterion | Points | Requirements |
|-----------|--------|--------------|
| Positional params | 2.5 | $1, $2, ... $9 |
| Special params | 2.5 | $#, $@, $*, $0 |
| Shift command | 2.0 | Parameter shifting |
| Default values | 2.0 | ${1:-default} |
| Validation | 1.0 | Check argument count |

---

## S03e - Getopts CLI (10 points)

| Criterion | Points | Requirements |
|-----------|--------|--------------|
| Basic getopts | 3.0 | while getopts pattern |
| Option arguments | 2.5 | Options with : |
| OPTIND handling | 2.0 | Shift after parsing |
| Error handling | 1.5 | Unknown options |
| Help message | 1.0 | -h implementation |

---

## S03f - Unix Permissions (10 points)

| Criterion | Points | Requirements |
|-----------|--------|--------------|
| chmod numeric | 2.5 | 755, 644, etc. |
| chmod symbolic | 2.5 | u+x, g-w, o=r |
| Ownership | 2.0 | chown, chgrp |
| Special bits | 2.0 | setuid, setgid, sticky |
| umask | 1.0 | Default permissions |

---

## S03g - CRON Automation (10 points)

| Criterion | Points | Requirements |
|-----------|--------|--------------|
| Crontab syntax | 3.0 | Correct time fields |
| crontab commands | 2.0 | -l, -e, -r |
| Special strings | 2.0 | @daily, @hourly, etc. |
| Output handling | 2.0 | Redirect, mail |
| Practical job | 1.0 | Create useful cron job |

---

*By Revolvix for OPERATING SYSTEMS class | restricted licence 2017-2030*
