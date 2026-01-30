# Parsons Problems: Text Processing
## Code Reordering Exercises - Regex, GREP, SED, AWK

> Operating Systems | Bucharest University of Economic Studies - CSIE  
> Seminar 4 | Parsons Problems  
> Total problems: 16 | Estimated time: 3-5 min per problem

---

## What are Parsons Problems?

Parsons Problems are exercises in which students receive scrambled lines of code and must reorder them to form a correct solution. This technique:

- Reduces cognitive load (no writing from scratch)
- Focuses on understanding structure and logic
- Rapidly identifies gaps in comprehension
- Is faster than complete code writing

### Format

Each problem contains:
- Objective: What the code must accomplish
- Scrambled lines: Code in incorrect order (sometimes with distractors)
- Solution: Correct order (for instructor)
- Explanation: Why this order

---

# SECTION 1: GREP (PP-G1 - PP-G4)

## PP-G1: Extract Unique IPs

### Objective
Extract all unique IPs from `access.log`, sorted by frequency (descending).

### Scrambled Lines

```
A) | head -10
B) grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' access.log
C) | sort -rn
D) | sort
E) | uniq -c
```

### Solution
Correct order: B → D → E → C → A

```bash
grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' access.log | sort | uniq -c | sort -rn | head -10
```

### Explanation
1. B - Extract IPs with grep -o (match only)
2. D - Sort alphabetically (required for uniq)
3. E - Count consecutive occurrences (hence the need for sort beforehand)
4. C - Sort numerically descending by count
5. A - Take the first 10 results

### Distractors
- Placing `uniq -c` before `sort` does not work correctly
- `head` must be at the end, not at the beginning

---

## PP-G2: Source Code Search

### Objective
Find all Python functions (lines with `def `) in `.py` files from the current directory and subdirectories, displaying line numbers.

### Scrambled Lines

```
A) --include='*.py'
B) grep
C) 'def '
D) -rn
E) .
```

### Solution
Correct order: B → D → A → C → E

```bash
grep -rn --include='*.py' 'def ' .
```

### Explanation
1. B - The grep command
2. D - `-r` for recursive, `-n` for line numbers
3. A - `--include` limits to .py files
4. C - The pattern to search for
5. E - The starting directory (current)

### Note
The order of options in grep may vary, but the pattern must precede the file/directory.

---

## PP-G3: Error Log Filtering

### Objective
From `application.log`, display lines with ERROR but WITHOUT those containing "DEBUG" or comments.

### Scrambled Lines

```
A) grep -v '^#' application.log
B) | grep -v 'DEBUG'
C) | grep -i 'ERROR'
D) grep 'ERROR' application.log | grep -v 'DEBUG'  # DISTRACTOR
```

### Solution
Correct order: A → C → B

```bash
grep -v '^#' application.log | grep -i 'ERROR' | grep -v 'DEBUG'
```

### Explanation
1. A - Remove comments (lines starting with #)
2. C - Filter for ERROR (case-insensitive)
3. B - Exclude lines with DEBUG

### Accepted Alternative
```bash
grep -i 'ERROR' application.log | grep -v 'DEBUG' | grep -v '^#'
```

### Note for Instructor
D is a partially correct distractor - it works but does not remove comments.

---

## PP-G4: Context for Errors

### Objective
Find lines with "Exception" in the log and display 2 lines before and 3 after for context.

### Scrambled Lines

```
A) -A 3
B) -B 2
C) grep
D) 'Exception'
E) error.log
F) -C 5  # DISTRACTOR
```

### Solution
Correct order: C → B → A → D → E

```bash
grep -B 2 -A 3 'Exception' error.log
```

### Explanation
1. C - The grep command
2. B - 2 lines Before
3. A - 3 lines After
4. D - The pattern
5. E - The file

### Note
F is a distractor - `-C 5` would give 5 lines before AND after, not 2+3.

---

# SECTION 2: SED (PP-S1 - PP-S4)

## PP-S1: Config Cleanup

### Objective
Remove comments (lines with #) and empty lines from `config.txt`.

### Scrambled Lines

```
A) sed '/^#/d'
B) config.txt
C) | sed '/^$/d'
D) sed '/^#/d; /^$/d' config.txt  # ALTERNATIVE
```

### Solution
Correct order: A → B → C or D alone

```bash
# Variant with pipe
sed '/^#/d' config.txt | sed '/^$/d'

# Compact variant (D)
sed '/^#/d; /^$/d' config.txt
```

### Explanation
1. A - Delete lines starting with #
2. B - From the config.txt file
3. C - Pipe to another sed that deletes empty lines

### Note
D demonstrates that sed can receive multiple commands separated by `;`

---

## PP-S2: Replacement with Backup

### Objective
Replace "localhost" with "127.0.0.1" in `hosts.txt`, keeping a backup of the original.

### Scrambled Lines

```
A) sed
B) -i.bak
C) 's/localhost/127.0.0.1/g'
D) hosts.txt
E) -i  # DISTRACTOR (no backup!)
```

### Solution
Correct order: A → B → C → D

```bash
sed -i.bak 's/localhost/127.0.0.1/g' hosts.txt
```

### Explanation
1. A - The sed command
2. B - Edit in-place WITH backup (.bak)
3. C - The substitution with g flag (global)
4. D - The target file

### Warning
E (`-i` without extension) is dangerous - it modifies the file WITHOUT backup!

---

## PP-S3: Name Inversion

### Objective
Transform "FirstName LastName" into "LastName, FirstName" in `names.txt`.

### Scrambled Lines

```
A) sed
B) 's/\([A-Za-z]*\) \([A-Za-z]*\)/\2, \1/'
C) names.txt
D) 's/\(.*\) \(.*\)/\2, \1/'  # Simpler ALTERNATIVE
E) -E 's/([A-Za-z]+) ([A-Za-z]+)/\2, \1/'  # ERE ALTERNATIVE
```

### Solution
Correct variants: A → B → C or A → D → C or A → E → C

```bash
# BRE with character classes
sed 's/\([A-Za-z]*\) \([A-Za-z]*\)/\2, \1/' names.txt

# Simplified BRE
sed 's/\(.*\) \(.*\)/\2, \1/' names.txt

# ERE
sed -E 's/([A-Za-z]+) ([A-Za-z]+)/\2, \1/' names.txt
```

### Explanation

Specifically: `\(...\)` or `(...)` captures groups. `\1` and `\2` refer to groups in capture order. And we invert: `\2, \1` = second, comma, first. Clear.


---

## PP-S4: Add Prefix

### Objective
Add the prefix "LOG: " at the beginning of each line in `messages.txt`.

### Scrambled Lines

```
A) sed
B) 's/^/LOG: /'
C) messages.txt
D) 's/$/: LOG/'  # DISTRACTOR (at end, not beginning)
E) 's/.*/LOG: &/'  # ALTERNATIVE with &
```

### Solution
Correct order: A → B → C or A → E → C

```bash
# With ^ anchor
sed 's/^/LOG: /' messages.txt

# With & (the entire match)
sed 's/.*/LOG: &/' messages.txt
```

### Explanation
- `^` = beginning of line
- We replace "nothing" at the beginning with "LOG: "
- `&` in variant E = the entire line (.*), placed after "LOG: "

---

# SECTION 3: AWK (PP-A1 - PP-A4)

## PP-A1: Salary Sum

### Objective
Calculate the sum of salaries from `employees.csv` (column 4), ignoring the header.

### Scrambled Lines

```
A) END { print "Total:", sum }
B) awk -F','
C) 'NR > 1 { sum += $4 }'
D) employees.csv
E) '{ sum += $4 } END { print sum }'  # DISTRACTOR (includes header)
```

### Solution
Correct order: B → C → A → D

```bash
awk -F',' 'NR > 1 { sum += $4 } END { print "Total:", sum }' employees.csv
```

### Explanation
1. B - awk with comma separator
2. C - For lines > 1 (skip header), add column 4
3. A - At the end, display the sum
4. D - The CSV file

### Note
E is a distractor because it does not exclude the header (NR > 1).

---

## PP-A2: Department Report

### Objective
Display the number of employees per department from the CSV.

### Scrambled Lines

```
A) awk -F','
B) 'NR > 1 { count[$3]++ }'
C) 'END { for (dept in count) print dept, count[dept] }'
D) employees.csv
E) | sort  # OPTIONAL for ordering
```

### Solution
Correct order: A → B → C → D (optionally → E)

```bash
awk -F',' 'NR > 1 { count[$3]++ } END { for (dept in count) print dept, count[dept] }' employees.csv
# Optional: | sort
```

### Explanation
1. A - awk with CSV separator
2. B - Count per department ($3) with associative array
3. C - At the end, iterate the array and display
4. D - The source file
5. E - Optional, sort the output

---

## PP-A3: Table Formatting

### Objective
Display employees (name and salary) in a formatted table with printf.

### Scrambled Lines

```
A) awk -F','
B) 'BEGIN { printf "%-15s %10s\n", "Name", "Salary" }'
C) 'NR > 1 { printf "%-15s $%9d\n", $2, $4 }'
D) employees.csv
E) 'BEGIN { printf "%-15s %10s\n", "Name", "Salary"; printf "%-15s %10s\n", "----", "------" }'  # WITH SEPARATOR LINE
```

### Solution
Correct order: A → B → C → D or A → E → C → D

```bash
# Simple version
awk -F',' 'BEGIN { printf "%-15s %10s\n", "Name", "Salary" } NR > 1 { printf "%-15s $%9d\n", $2, $4 }' employees.csv

# With separator
awk -F',' 'BEGIN { printf "%-15s %10s\n", "Name", "Salary"; printf "%-15s %10s\n", "----", "------" } NR > 1 { printf "%-15s $%9d\n", $2, $4 }' employees.csv
```

### Explanation

Three things matter here: BEGIN runs only once, perfect for header, `%-15s` = string 15 characters, left-aligned and `$%9d` = $ followed by number 9 characters.


---

## PP-A4: Filtering and Calculation

### Objective
Calculate the average salary only for the IT department.

### Scrambled Lines

```
A) awk -F','
B) '$3 == "IT" { sum += $4; count++ }'
C) 'END { print "IT Average:", sum/count }'
D) employees.csv
E) 'NR > 1 && $3 == "IT" { sum += $4; count++ }'  # WITH SKIP HEADER
```

### Solution
Correct order: A → E → C → D (recommended) or A → B → C → D

```bash
# Recommended (with explicit skip header)
awk -F',' 'NR > 1 && $3 == "IT" { sum += $4; count++ } END { print "IT Average:", sum/count }' employees.csv

# Also works without NR>1 if header is not "IT"
awk -F',' '$3 == "IT" { sum += $4; count++ } END { print "IT Average:", sum/count }' employees.csv
```

### Explanation
- We filter by department ($3 == "IT")
- We add salaries and count
- At the end, we calculate the average
- Use `man` or `--help` when in doubt

---

# SECTION 4: COMBINED PIPELINES (PP-C1 - PP-C4)

## PP-C1: Top HTTP Errors

### Objective
From access.log, find the top 5 HTTP error codes (4xx and 5xx) with their frequency.

### Scrambled Lines

```
A) grep -oE '" [45][0-9]{2} ' access.log
B) | sort
C) | uniq -c
D) | sort -rn
E) | head -5
F) | awk '{print $2}'  # DISTRACTOR (loses the count)
```

### Solution
Correct order: A → B → C → D → E

```bash
grep -oE '" [45][0-9]{2} ' access.log | sort | uniq -c | sort -rn | head -5
```

### Explanation
1. A - Extract 4xx and 5xx codes
2. B - Sort (required for uniq)
3. C - Count occurrences
4. D - Sort descending by number
5. E - Take the first 5

---

## PP-C2: Complete Log Processing

### Objective
From access.log, display a report with the IP and total bytes transferred (column 10), only for successful requests (200).

### Scrambled Lines

```
A) grep ' 200 ' access.log
B) | awk '{ bytes[$1] += $10 }'
C) 'END { for (ip in bytes) printf "%-20s %d bytes\n", ip, bytes[ip] }'
D) | sort -t'b' -k2 -rn  # DISTRACTOR (incorrect sorting)
```

### Solution
Correct order: A → B concatenated with C

```bash
grep ' 200 ' access.log | awk '{ bytes[$1] += $10 } END { for (ip in bytes) printf "%-20s %d bytes\n", ip, bytes[ip] }'
```

### Explanation
1. A - Filter only 200 requests
2. B+C - awk aggregates bytes per IP and displays

### Note
D is a distractor with incorrect sort syntax.

---

## PP-C3: Config Transformation

### Objective
From config.txt (key=value format), generate export statements for bash.

### Scrambled Lines

```
A) grep -v '^#' config.txt
B) | grep -v '^$'
C) | sed 's/^/export /'
D) | sed 's/=\(.*\)/="\1"/'
E) grep -vE '^(#|$)' config.txt  # Compact ALTERNATIVE
```

### Solution
Variant 1: A → B → C → D
Variant 2: E → C → D

```bash
# Variant with multiple pipes
grep -v '^#' config.txt | grep -v '^$' | sed 's/^/export /' | sed 's/=\(.*\)/="\1"/'

# Compact variant
grep -vE '^(#|$)' config.txt | sed 's/^/export /; s/=\(.*\)/="\1"/'
```

### Result
```
export server.host="localhost"
export server.port="8080"
```

---

## PP-C4: Data Cleanup Script

### Objective
Process a CSV: remove header, sort by column 3, format the output.

### Scrambled Lines

```
A) tail -n +2 data.csv
B) | sort -t',' -k3
C) | awk -F',' '{ printf "%-10s | %-10s | %s\n", $1, $2, $3 }'
D) sed '1d' data.csv  # ALTERNATIVE for skip header
E) | head -20  # OPTIONAL limit
```

### Solution
Variant 1: A → B → C (optionally → E)
Variant 2: D → B → C

```bash
# With tail
tail -n +2 data.csv | sort -t',' -k3 | awk -F',' '{ printf "%-10s | %-10s | %s\n", $1, $2, $3 }'

# With sed
sed '1d' data.csv | sort -t',' -k3 | awk -F',' '{ printf "%-10s | %-10s | %s\n", $1, $2, $3 }'
```

### Explanation
1. A or D - Skip header (`tail -n +2` = from line 2, `sed '1d'` = delete line 1)
2. B - Sort CSV by column 3
3. C - Format with awk

---

# BONUS SECTION: ADVANCED PROBLEMS

## PP-X1: Complex One-Liner

### Objective
Find all .log files modified in the last 24h, search for "ERROR" in them and display a summary per file.

### Scrambled Lines

```
A) find /var/log -name '*.log' -mtime -1
B) -exec grep -l 'ERROR' {} \;
C) | xargs -I{} sh -c 'echo "=== {} ===" && grep -c ERROR {}'
D) 2>/dev/null
E) | while read f; do echo "$f: $(grep -c ERROR "$f")"; done  # ALTERNATIVE
```

### Solution
Variant 1: A → B → C → D
Variant 2: A → D → E

```bash
# With xargs
find /var/log -name '*.log' -mtime -1 -exec grep -l 'ERROR' {} \; | xargs -I{} sh -c 'echo "=== {} ===" && grep -c ERROR {}' 2>/dev/null

# With while
find /var/log -name '*.log' -mtime -1 2>/dev/null | while read f; do echo "$f: $(grep -c ERROR "$f" 2>/dev/null)"; done
```

---

## Parsons Problems Statistics

### Distribution by Difficulty

| Level | Count | Percentage |
|-------|-------|------------|
| ⭐⭐ | 6 | 37.5% |
| ⭐⭐⭐ | 7 | 43.75% |
| ⭐⭐⭐⭐ | 2 | 12.5% |
| ⭐⭐⭐⭐⭐ | 1 | 6.25% |

### Concepts Covered

| Concept | Problems |
|---------|----------|
| grep basics | PP-G1, PP-G2 |
| grep advanced | PP-G3, PP-G4 |
| sed substitution | PP-S1, PP-S2 |
| sed backreferences | PP-S3 |
| awk fields | PP-A1 |
| awk arrays | PP-A2, PP-A3 |
| awk filtering | PP-A4 |
| Pipeline composition | PP-C1 - PP-C4 |
| Complex integration | PP-X1 |

---

*Parsons Problems for Operating Systems Seminar 4 | ASE Bucharest - CSIE*
