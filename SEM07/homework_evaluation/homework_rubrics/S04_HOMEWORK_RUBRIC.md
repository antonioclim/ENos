# S04 Homework Rubric

> **Operating Systems** | ASE Bucharest - CSIE  
> Seminar 04: Text Processing and Regular Expressions

---

## Assignment Overview

| ID | Topic | Duration | Difficulty |
|----|-------|----------|------------|
| S04b | Regular Expressions | 50 min | ⭐⭐⭐ |
| S04c | GREP Family | 45 min | ⭐⭐ |
| S04d | SED Stream Editor | 50 min | ⭐⭐⭐ |
| S04e | AWK Processing | 55 min | ⭐⭐⭐ |
| S04f | Text Editors | 40 min | ⭐⭐ |

---

## S04b - Regular Expressions (10 points)

| Criterion | Points | Requirements |
|-----------|--------|--------------|
| Basic patterns | 2.5 | ., *, +, ?, ^ , $ |
| Character classes | 2.0 | [...], [^...], \d, \w |
| Quantifiers | 2.0 | {n}, {n,}, {n,m} |
| Groups/alternation | 2.0 | (...), \| |
| Practical matching | 1.5 | Email, IP, date patterns |

### Expected Patterns
```bash
# Email (simplified)
[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}

# IP address
[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}

# Date YYYY-MM-DD
[0-9]{4}-[0-9]{2}-[0-9]{2}
```

---

## S04c - GREP Family (10 points)

| Criterion | Points | Requirements |
|-----------|--------|--------------|
| Basic grep | 2.0 | Pattern matching |
| grep options | 2.5 | -i, -v, -c, -n, -l, -r |
| Extended grep | 2.0 | grep -E or egrep |
| Fixed strings | 1.5 | grep -F or fgrep |
| Context options | 2.0 | -A, -B, -C |

### Expected Commands
```bash
grep -rn "error" /var/log/
grep -E "warn|error|fatal" log.txt
grep -c "pattern" file.txt
grep -v "^#" config.conf | grep -v "^$"
```

---

## S04d - SED Stream Editor (10 points)

| Criterion | Points | Requirements |
|-----------|--------|--------------|
| Substitution | 3.0 | s/old/new/g, flags |
| Addresses | 2.0 | Line numbers, patterns |
| Delete/insert | 2.0 | d, i, a commands |
| In-place edit | 1.5 | -i option |
| Multiple commands | 1.5 | -e or ; or script file |

### Expected Commands
```bash
sed 's/old/new/g' file.txt
sed -n '10,20p' file.txt
sed '/pattern/d' file.txt
sed -i.bak 's/foo/bar/g' file.txt
sed '/^#/d; /^$/d' config.conf
```

---

## S04e - AWK Processing (10 points)

| Criterion | Points | Requirements |
|-----------|--------|--------------|
| Fields and records | 2.5 | $1, $2, NF, NR |
| Patterns and actions | 2.0 | /pattern/ { action } |
| Built-in variables | 2.0 | FS, OFS, RS, ORS |
| Control structures | 2.0 | if, for, while |
| Functions | 1.5 | length, substr, split |

### Expected Commands
```bash
awk '{print $1, $3}' file.txt
awk -F: '{print $1}' /etc/passwd
awk 'NR > 1 {sum += $2} END {print sum}' data.txt
awk '/error/ {count++} END {print count}' log.txt
```

---

## S04f - Text Editors (10 points)

| Criterion | Points | Requirements |
|-----------|--------|--------------|
| Nano basics | 2.0 | Open, edit, save, exit |
| Vim modes | 3.0 | Normal, insert, command |
| Vim navigation | 2.5 | h,j,k,l, w,b,e, gg,G |
| Vim editing | 2.5 | i,a,o,d,y,p,:w,:q |

### Expected Vim Commands
```vim
:wq             " Save and quit
:q!             " Quit without saving
dd              " Delete line
yy              " Yank (copy) line
p               " Paste
/pattern        " Search
:%s/old/new/g   " Replace all
```

---

*By Revolvix for OPERATING SYSTEMS class | restricted licence 2017-2030*
