# Sprint Exercises: Text Processing
## Timed Challenges - Regex, GREP, SED, AWK

> *Laboratory observation: I have seen students who solve exercises faster when they read their command aloud before pressing Enter. It sounds strange, but it helps catch syntax errors.*

> Operating Systems | Bucharest University of Economic Studies - CSIE  
> Seminar 4 | Timed Sprints  
> Format: Pair Programming | Time per sprint: 10-15 min

---

## Sprint Instructions

### Working Format

```
┌─────────────────────────────────────────────────────────────────────────┐
│  🏃 SPRINT RULES                                                        │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  1. PAIRS - Work in pairs (pair programming)                           │
│                                                                         │
│  2. ROTATION - Switch roles at halftime                                │
│     • Driver = types                                                    │
│     • Navigator = guides and verifies                                   │
│                                                                         │
│  3. TIME - Strictly respect the time limit                             │
│                                                                         │
│  4. PROGRESSIVE - Exercises are in order of difficulty                 │
│                                                                         │
│  5. BONUS - Attempt bonus exercises only if you have finished the rest │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

### Initial Setup

```bash
# Make sure you are in the correct directory
cd ~/demo_sem4/data

# Check available files
ls -la

# If missing, run the setup
# ./scripts/bash/S04_01_setup_seminar.sh
```

---

# SPRINT G1: GREP BASICS (10 min)

## Context
You have received an `access.log` file with web server logs. You need to extract information for the security report.

## Exercises

### G1.1 (2 min)
**Find all requests with error code 404 (Not Found)**

```bash
# Write your command here:

# Expected output: complete lines with " 404 "
```

<details>
<summary>💡 Hint</summary>
The HTTP code pattern is " 404 " (with spaces for exactness)
</details>

<details>
<summary>✅ Solution</summary>

```bash
grep ' 404 ' access.log
```
</details>

> ✅ **Checkpoint:** You should see several lines containing " 404 " — typically 3-10 lines depending on the generated data.

---

### G1.2 (2 min)
Count how many requests were made with the POST method

```bash
# Write your command here:

# Expected output: a number
```

<details>
<summary>💡 Hint</summary>
Use grep -c for counting
</details>

<details>
<summary>✅ Solution</summary>

```bash
grep -c '"POST' access.log
# or
grep -c 'POST' access.log
```
</details>

> ✅ **Checkpoint:** You should see a number (e.g., 150-300). If you see 0, check that access.log exists in your current directory.

---

### G1.3 (3 min)
Find all requests to /admin (possible attack)

```bash
# Write your command here:

# Expected output: lines with /admin in URL
```

<details>
<summary>💡 Hint</summary>
Simple pattern: '/admin'
</details>

<details>
<summary>✅ Solution</summary>

```bash
grep '/admin' access.log
```
</details>

---

### G1.4 (3 min)
Extract ONLY the unique IPs from the log (no duplicates)

```bash
# Write your command here:

# Expected output: list of IPs, one per line, no duplicates
```

<details>
<summary>💡 Hint</summary>
Combine: grep -oE for IP, then sort -u for unique
</details>

<details>
<summary>✅ Solution</summary>

```bash
grep -oE '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' access.log | sort -u

# or more precise:
grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' access.log | sort -u
```
</details>

> ✅ **Checkpoint:** You should see 10-15 unique IPs. Each line contains only an IP address (e.g., 192.168.1.100).

---

### G1.5 BONUS
Find the IP with the most requests and count them

```bash
# Write your command here:

# Expected output: "X IP_ADDRESS" (number and IP)
```

<details>
<summary>✅ Solution</summary>

```bash
grep -oE '^[0-9.]+' access.log | sort | uniq -c | sort -rn | head -1
```
</details>

---

# SPRINT G2: GREP ADVANCED (10 min)

## Context
We continue the security analysis. Now we need to investigate more deeply.

## Exercises

### G2.1 (2 min)
Find failed requests (codes 4xx OR 5xx)

```bash
# Write your command here:

# Expected output: lines with codes 400-599
```

<details>
<summary>💡 Hint</summary>
ERE pattern: " [45][0-9]{2} " with grep -E
</details>

<details>
<summary>✅ Solution</summary>

```bash
grep -E '" [45][0-9]{2} ' access.log
```
</details>

---

### G2.2 (2 min)
**Display lines with errors plus 2 lines of context (before and after)**

```bash
# Write your command here:

# Expected output: errors with context
```

<details>
<summary>💡 Hint</summary>
Use -C for context
</details>

<details>
<summary>✅ Solution</summary>

```bash
grep -C 2 ' 500 ' access.log
# or for all errors:
grep -E -C 2 '" [45][0-9]{2} ' access.log
```
</details>

---

### G2.3 (3 min)
From employees.csv, find IT department employees with salary > 5500
(Note: This requires grep + awk combination or another approach)

```bash
# Write your command here:

# Expected output: IT employees with high salary
```

<details>
<summary>💡 Hint</summary>
grep for IT, then awk to filter salary, or directly awk
</details>

<details>
<summary>✅ Solution</summary>

```bash
# Variant with awk (more precise):
awk -F',' '$3 == "IT" && $4 > 5500' employees.csv

# Variant with grep + awk:
grep ',IT,' employees.csv | awk -F',' '$4 > 5500'
```
</details>

---

### G2.4 (3 min)
Extract all valid emails from emails.txt

```bash
# Write your command here:

# Expected output: only valid emails, one per line
```

<details>
<summary>💡 Hint</summary>
Email pattern: `[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}`
</details>

<details>
<summary>✅ Solution</summary>

```bash
grep -oE '[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}' emails.txt
```
</details>

---

### G2.5 BONUS
Create a report: for each HTTP code (200, 403, etc.), display the number of occurrences

```bash
# Write your command here:

# Expected output:
# N 200
# M 403
# ...
```

<details>
<summary>✅ Solution</summary>

```bash
grep -oE '" [0-9]{3} ' access.log | grep -oE '[0-9]{3}' | sort | uniq -c | sort -rn
```
</details>

---

# SPRINT S1: SED TRANSFORMATIONS (10 min)

## Context
You have received a configuration file that needs to be updated for production deployment.

## Exercises

### S1.1 (2 min)
Replace all occurrences of "localhost" with "192.168.1.100" in config.txt
(Display the result, do not modify the file)

```bash
# Write your command here:

# Expected output: config with new IP
```

<details>
<summary>✅ Solution</summary>

```bash
sed 's/localhost/192.168.1.100/g' config.txt
```
</details>

> ✅ **Checkpoint:** Lines like `server.host=localhost` should now show `server.host=192.168.1.100`. Count should be 2-3 replacements.

---

### S1.2 (2 min)
Delete all comments (lines starting with #) from config.txt

```bash
# Write your command here:

# Expected output: config without comments
```

<details>
<summary>✅ Solution</summary>

```bash
sed '/^#/d' config.txt
```
</details>

---

### S1.3 (2 min)
Delete comments AND empty lines

```bash
# Write your command here:

# Expected output: clean config
```

<details>
<summary>✅ Solution</summary>

```bash
sed '/^#/d; /^$/d' config.txt
# or
sed -E '/^(#|$)/d' config.txt
```
</details>

> ✅ **Checkpoint:** Output should be ~20 lines of pure key=value pairs with no blank lines and no comments.

---

### S1.4 (2 min)
Change the format from "key=value" to "key = value" (add spaces around =)

```bash
# Write your command here:

# Expected output: key = value
```

<details>
<summary>💡 Hint</summary>
s/=/ = / but only on lines that ARE NOT comments
</details>

<details>
<summary>✅ Solution</summary>

```bash
sed '/^#/!s/=/ = /' config.txt
```
</details>

---

### S1.5 (2 min)
Put all values in quotes: key=value → key="value"

```bash
# Write your command here:

# Expected output: key="value"
```

<details>
<summary>💡 Hint</summary>
Use backreference: `s/=\(.*\)/="\1"/`
</details>

<details>
<summary>✅ Solution</summary>

```bash
sed 's/=\(.*\)/="\1"/' config.txt
# or with ERE:
sed -E 's/=(.*)/="\1"/' config.txt
```
</details>

---

### S1.6 BONUS
Create a script to generate export statements for bash:
`key=value` → `export KEY="value"`

```bash
# Write your command here:

# Expected output:
# export SERVER_HOST="localhost"
# export SERVER_PORT="8080"
# ...
```

<details>
<summary>✅ Solution</summary>

```bash
sed '/^#/d; /^$/d' config.txt | \
sed 's/\([a-z.]*\)=\(.*\)/export \U\1\E="\2"/' | \
sed 's/\./_/g'
```
Note: This solution is complex and requires GNU sed for \U (uppercase).
</details>

---

# SPRINT A1: AWK BASICS (10 min)

## Context
You have received a CSV with employee data. You need to extract reports for HR.

## File: employees.csv
```csv
ID,Name,Department,Salary
101,John Smith,IT,5500
102,Maria Garcia,HR,4800
...
```

## Exercises

### A1.1 (2 min)
Display only the employee names (column 2)

```bash
# Write your command here:

# Expected output: list of names
```

<details>
<summary>✅ Solution</summary>

```bash
awk -F',' '{ print $2 }' employees.csv
# or skip header:
awk -F',' 'NR > 1 { print $2 }' employees.csv
```
</details>

---

### A1.2 (2 min)
Display name and salary, separated by tab

```bash
# Write your command here:

# Expected output:
# Name Salary
# John Smith 5500
# ...
```

<details>
<summary>✅ Solution</summary>

```bash
awk -F',' '{ print $2 "\t" $4 }' employees.csv
# or with OFS:
awk -F',' 'BEGIN{OFS="\t"} { print $2, $4 }' employees.csv
```
</details>

---

### A1.3 (2 min)
Display only employees from the "IT" department

```bash
# Write your command here:

# Expected output: only rows with IT
```

<details>
<summary>✅ Solution</summary>

```bash
awk -F',' '$3 == "IT"' employees.csv
```
</details>

---

### A1.4 (2 min)
Calculate and display the total sum of salaries

```bash
# Write your command here:

# Expected output: Total: XXXXX
```

<details>
<summary>✅ Solution</summary>

```bash
awk -F',' 'NR > 1 { sum += $4 } END { print "Total:", sum }' employees.csv
```
</details>

---

### A1.5 (2 min)
Calculate the average salary

```bash
# Write your command here:

# Expected output: Average: XXXX.XX
```

<details>
<summary>✅ Solution</summary>

```bash
awk -F',' 'NR > 1 { sum += $4; count++ } END { print "Average:", sum/count }' employees.csv
```
</details>

---

### A1.6 BONUS
Find the employee with the highest salary and display their name and salary

```bash
# Write your command here:

# Expected output: Name: XXXXX, Salary: XXXXX
```

<details>
<summary>✅ Solution</summary>

```bash
awk -F',' 'NR > 1 && $4 > max { max = $4; name = $2 } END { print "Name:", name, "Salary:", max }' employees.csv
```
</details>

---

# SPRINT A2: AWK ADVANCED (10 min)

## Context
HR wants aggregate reports by departments.

## Exercises

### A2.1 (3 min)
Count how many employees are in each department

```bash
# Write your command here:

# Expected output:
# IT 4
# HR 2
# ...
```

<details>
<summary>✅ Solution</summary>

```bash
awk -F',' 'NR > 1 { count[$3]++ } END { for (d in count) print d, count[d] }' employees.csv
```
</details>

---

### A2.2 (3 min)
Calculate total salary per department

```bash
# Write your command here:

# Expected output:
# IT: $XXXXX
# HR: $XXXXX
# ...
```

<details>
<summary>✅ Solution</summary>

```bash
awk -F',' 'NR > 1 { sum[$3] += $4 } END { for (d in sum) printf "%s: $%d\n", d, sum[d] }' employees.csv
```
</details>

---

### A2.3 (4 min)
Create a formatted report with header:
```
Department      Count    Total Salary
-----------     -----    ------------
IT                 4         $XXXXX
HR                 2         $XXXXX
```

```bash
# Write your command here:

```

<details>
<summary>✅ Solution</summary>

```bash
awk -F',' '
BEGIN { printf "%-15s %5s %15s\n", "Department", "Count", "Total Salary" }
NR > 1 { count[$3]++; sum[$3] += $4 }
END { 
    for (d in count) 
        printf "%-15s %5d %15s\n", d, count[d], "$"sum[d]
}' employees.csv
```
</details>

---

### A2.4 BONUS
Display only departments with average salary > 5000

```bash
# Write your command here:

# Expected output: departments with high average
```

<details>
<summary>✅ Solution</summary>

```bash
awk -F',' '
NR > 1 { count[$3]++; sum[$3] += $4 }
END { 
    for (d in count) 
        if (sum[d]/count[d] > 5000) 
            printf "%s: avg=$%.2f\n", d, sum[d]/count[d]
}' employees.csv
```
</details>

---

# SPRINT COMBO: PIPELINE MASTER (15 min)

## Context
Final challenge! Combine everything you have learnt.

## Exercises

### C1 (5 min)
From access.log, create a report with top 5 IPs and their request count, nicely formatted:

```
=== TOP 5 IP ADDRESSES ===
1. 192.168.1.100    45 requests
2. 10.0.0.50        32 requests
...
```

```bash
# Write your command here:

```

<details>
<summary>✅ Solution</summary>

```bash
echo "=== TOP 5 IP ADDRESSES ===" && \
grep -oE '^[0-9.]+' access.log | sort | uniq -c | sort -rn | head -5 | \
awk '{ printf "%d. %-20s %d requests\n", NR, $2, $1 }'
```
</details>

---

### C2 (5 min)
Process config.txt to generate a valid .env file:
- Remove comments
- Remove empty lines
- Transform into format: UPPER_CASE_KEY="value"

```bash
# Write your command here:

# Expected output:
# SERVER_HOST="localhost"
# SERVER_PORT="8080"
# ...
```

<details>
<summary>✅ Solution</summary>

```bash
grep -v '^#' config.txt | grep -v '^$' | \
sed 's/\./_/g' | \
awk -F'=' '{ print toupper($1) "=\"" $2 "\"" }'
```
</details>

---

### C3 (5 min)
Complete analysis of employees.csv:
1. Display total employees
2. Department with most employees
3. Employee with highest salary
4. Global average salary

```bash
# Write your command here:

# Expected output: structured report
```

<details>
<summary>✅ Solution</summary>

```bash
awk -F',' '
NR > 1 {
    total++
    sum += $4
    dept[$3]++
    if ($4 > maxSal) { maxSal = $4; maxName = $2 }
}
END {
    print "=== EMPLOYEE REPORT ==="
    print "Total employees:", total
    print "Average salary: $" sum/total
    print "Highest paid:", maxName, "($" maxSal ")"
    
    maxDept = ""; maxCount = 0
    for (d in dept) if (dept[d] > maxCount) { maxCount = dept[d]; maxDept = d }
    print "Largest department:", maxDept, "(" maxCount " employees)"
}' employees.csv
```
</details>

---

## Grading Guide

| Sprint | Total Points | Time | Pass (60%) |
|--------|--------------|------|------------|
| G1 | 10 | 10 min | 6 |
| G2 | 12 | 10 min | 7 |
| S1 | 12 | 10 min | 7 |
| A1 | 10 | 10 min | 6 |
| A2 | 10 | 10 min | 6 |
| COMBO | 15 | 15 min | 9 |

### Points per Exercise
- ⭐ = 1 point
- ⭐⭐ = 2 points
- ⭐⭐⭐ = 3 points
- ⭐⭐⭐⭐ = 4 points
- BONUS = extra points (do not count towards passing)

---

## Post-Sprint Self-Assessment

After each sprint, mark:

```
□ I completed all basic exercises (⭐, ⭐⭐)
□ I completed intermediate exercises (⭐⭐⭐)
□ I attempted/completed BONUS
□ I worked well in a pair
□ I understood the solutions I did not find myself
```

---

*Sprint Exercises for Operating Systems Seminar 4 | ASE Bucharest - CSIE*
