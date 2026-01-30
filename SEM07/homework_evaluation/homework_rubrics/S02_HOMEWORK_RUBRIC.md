# S02 Homework Rubric

> **Operating Systems** | ASE Bucharest - CSIE  
> Seminar 02: Control Flow and Text Processing

---

## Assignment Overview

| ID | Topic | Duration | Difficulty |
|----|-------|----------|------------|
| S02b | Control Operators | 40 min | ⭐⭐ |
| S02c | I/O Redirection | 45 min | ⭐⭐ |
| S02d | Pipes and Tee | 40 min | ⭐⭐ |
| S02e | Text Filters | 50 min | ⭐⭐⭐ |
| S02f | Scripting Loops | 45 min | ⭐⭐⭐ |

---

## S02b - Control Operators (10 points)

### Tasks
1. Demonstrate `;` sequential execution
2. Use `&&` for conditional success
3. Use `||` for conditional failure
4. Combine operators for complex logic
5. Use `&` for background execution

### Grading Criteria

| Criterion | Points | Requirements |
|-----------|--------|--------------|
| Semicolon | 2.0 | Correct sequential execution |
| AND operator | 2.0 | && with success dependency |
| OR operator | 2.0 | \|\| with failure fallback |
| Combinations | 2.0 | && and \|\| together |
| Background | 2.0 | & with jobs management |

### Expected Commands
```bash
echo "Start" ; ls ; echo "Done"
mkdir test && cd test && touch file.txt
[ -f config ] || echo "Config missing"
ping -c1 server && echo "OK" || echo "FAIL"
sleep 10 & jobs
```

### Common Deductions
- `-1.0`: Confusing && and || behavior
- `-0.5`: Not handling exit codes correctly
- `-0.5`: Forgetting spaces in test brackets

---

## S02c - I/O Redirection (10 points)

### Tasks
1. Redirect stdout with `>` and `>>`
2. Redirect stderr with `2>` and `2>>`
3. Combine stdout and stderr
4. Use input redirection `<`
5. Use here documents `<<` and here strings `<<<`

### Grading Criteria

| Criterion | Points | Requirements |
|-----------|--------|--------------|
| stdout redirect | 2.0 | > and >> correctly |
| stderr redirect | 2.0 | 2> and 2>&1 |
| Combined | 2.0 | &> and separate files |
| Input redirect | 2.0 | < and << and <<< |
| Practical use | 2.0 | Solve real problems |

### Expected Commands
```bash
ls > files.txt
ls >> files.txt
ls /nonexistent 2> errors.txt
command &> all.txt
wc -l < file.txt
cat << EOF
content
EOF
tr 'a-z' 'A-Z' <<< "hello"
```

---

## S02d - Pipes and Tee (10 points)

### Tasks
1. Create basic pipelines
2. Use `tee` for output splitting
3. Understand PIPESTATUS
4. Use process substitution
5. Apply `set -o pipefail`

### Grading Criteria

| Criterion | Points | Requirements |
|-----------|--------|--------------|
| Basic pipes | 2.5 | Multi-stage pipelines |
| Tee command | 2.0 | Save and display |
| PIPESTATUS | 2.0 | Check all exit codes |
| Process sub | 2.0 | <() and >() |
| Error handling | 1.5 | pipefail usage |

### Expected Commands
```bash
cat data | sort | uniq -c | sort -rn | head -10
ls -la | tee listing.txt | wc -l
echo "${PIPESTATUS[@]}"
diff <(ls dir1) <(ls dir2)
set -o pipefail
```

---

## S02e - Text Filters (10 points)

### Tasks
1. Sort with various options
2. Find unique lines with uniq
3. Extract columns with cut
4. Transform characters with tr
5. Count with wc
6. Use head, tail, tee effectively

### Grading Criteria

| Criterion | Points | Requirements |
|-----------|--------|--------------|
| sort | 2.0 | -n, -r, -k, -t options |
| uniq | 1.5 | -c, -d, -u options |
| cut | 1.5 | -d, -f, -c options |
| tr | 2.0 | Replace, delete, squeeze |
| wc/head/tail | 1.5 | Appropriate usage |
| Pipeline combo | 1.5 | Combine filters effectively |

### Expected Pipeline
```bash
# Top 10 IPs from log file
cat access.log | cut -d' ' -f1 | sort | uniq -c | sort -rn | head -10
```

### Common Deductions
- `-1.0`: Not sorting before uniq
- `-0.5`: Wrong delimiter in cut
- `-0.5`: Useless use of cat

---

## S02f - Scripting Loops (10 points)

### Tasks
1. Use `for` loops with lists
2. Use `for` with brace expansion
3. Use C-style `for` loops
4. Use `while` and `until` loops
5. Control flow with `break` and `continue`
6. Read files line by line

### Grading Criteria

| Criterion | Points | Requirements |
|-----------|--------|--------------|
| For loops | 2.5 | List and brace forms |
| C-style for | 1.5 | (( )) syntax |
| While/until | 2.0 | Condition loops |
| Break/continue | 2.0 | Flow control |
| File reading | 2.0 | while read pattern |

### Expected Commands
```bash
for i in {1..10}; do echo $i; done

for file in *.txt; do
    echo "Processing $file"
done

for ((i=0; i<5; i++)); do
    echo $i
done

while IFS= read -r line; do
    echo "Line: $line"
done < file.txt

count=0
while [ $count -lt 10 ]; do
    ((count++))
    [ $count -eq 5 ] && continue
    echo $count
done
```

### Common Deductions
- `-1.0`: Pipe to while (subshell issue)
- `-0.5`: Not using IFS= for reading
- `-0.5`: Forgetting -r in read

---

## Bonus Opportunities

| Bonus | Points | Description |
|-------|--------|-------------|
| Complex pipeline | +0.5 | 5+ stages with proper logic |
| Error handling | +0.5 | Comprehensive pipefail + PIPESTATUS |
| Creative solution | +0.5 | Elegant approach to problems |

**Maximum total: 10.0 points**

---

*By Revolvix for OPERATING SYSTEMS class | restricted licence 2017-2030*
