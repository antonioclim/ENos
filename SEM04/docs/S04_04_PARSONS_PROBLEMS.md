# Parsons Problems: Text Processing
## Code Reordering Exercises - Regex, GREP, SED, AWK

> Operating Systems | Bucharest University of Economic Studies - CSIE  
> Seminar 4 | Parsons Problems  
> Total problems: 16 core + 1 bonus | Estimated time: 3-5 min per problem

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
Extract the ten most frequent IPv4-shaped tokens from `access.log`, sorted by frequency (descending). This shape does not validate octet ranges.

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
Remove comments (lines starting with #) and empty lines from `config.txt`.

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
Use a fresh owned `hosts.txt` and verify `hosts.txt.bak` does not exist; a rerun can overwrite that backup.

E (`-i` without extension) is dangerous - it modifies the file WITHOUT backup!

---

## PP-S3: Name Inversion

### Objective
Transform "FirstName LastName" into "LastName, FirstName" in `names.txt`. Each fixture line must contain exactly two nonempty ASCII-letter words separated by one space. These variants are equivalent only on that declared subset.

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

Use simple CSV with one header, no quoted commas/newlines and numeric salary
fields. Assemble each selected fragment **literally with one ASCII space**;
quotation marks span fragments where shown. Do not silently remove or add quotes.
Alternative orders with identical semantics are acceptable when the required
objective and output are preserved.

## PP-A1: Salary Sum

### Objective
Calculate the sum of salaries from `employees.csv` (column 4), ignoring the header.

### Scrambled Lines

```
A) END { print "Total:", sum+0 }'
B) awk -F','
C) 'NR > 1 { sum += $4 }
D) employees.csv
E) 'NR > 1 { sum = $4 } END { print "Total:", sum+0 }'  # DISTRACTOR (overwrites)
```

### Solution
Correct order: B → C → A → D

```bash
awk -F',' 'NR > 1 { sum += $4 } END { print "Total:", sum+0 }' employees.csv
```

### Explanation
1. B - awk with comma separator
2. C - For lines > 1 (skip header), add column 4
3. A - At the end, display the sum
4. D - The CSV file

### Note
E overwrites the accumulator, so it prints the last salary rather than the sum.
Adding a textual Salary header numerically would contribute zero, which alone
would not explain an incorrect sum; explicit header handling is still clearer.

---

## PP-A2: Department Report

### Objective
Display the number of employees per department from the CSV.

### Scrambled Lines

```
A) awk -F','
B) 'NR > 1 { count[$3]++ }
C) END { for (dept in count) print dept, count[dept] }'
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
B) 'BEGIN { printf "%-15s %10s\n", "Name", "Salary" }
C) NR > 1 { printf "%-15s $%9d\n", $2, $4 }'
D) employees.csv
E) 'BEGIN { printf "%-15s %10s\n", "Name", "Salary"; printf "%-15s %10s\n", "----", "------" }
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
B) '$3 == "IT" { sum += $4; count++ }
C) END { if (count) print "IT Average:", sum/count; else print "IT Average: undefined (0 records)" }'
D) employees.csv
E) 'NR > 1 && $3 == "IT" { sum += $4; count++ }
```

### Solution
Correct order: A → E → C → D (recommended) or A → B → C → D

```bash
# Recommended (with explicit skip header)
awk -F',' 'NR > 1 && $3 == "IT" { sum += $4; count++ } END { if (count) print "IT Average:", sum/count; else print "IT Average: undefined (0 records)" }' employees.csv

# Also works without NR>1 if header is not "IT"
awk -F',' '$3 == "IT" { sum += $4; count++ } END { if (count) print "IT Average:", sum/count; else print "IT Average: undefined (0 records)" }' employees.csv
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
A) awk '$9 ~ /^[45][0-9][0-9]$/ {print $9}' access.log
B) | sort
C) | uniq -c
D) | sort -rn
E) | head -5
F) | awk '{print $2}'  # DISTRACTOR (loses the count)
```

### Solution
Correct order: A → B → C → D → E

```bash
awk '$9 ~ /^[45][0-9][0-9]$/ {print $9}' access.log | sort | uniq -c | sort -rn | head -5
```

### Explanation
1. A - Extract status field 9 from the declared combined-log fixture; no quote is included
2. B - Sort (required for uniq)
3. C - Count occurrences
4. D - Sort descending by number
5. E - Take the first 5

---

## PP-C2: Complete Log Processing

### Objective
From access.log, display a report with the IP and total bytes transferred (column 10), only for successful requests (200).

### Scrambled Lines

```text
A) awk '
B) $9 == 200 && $10 ~ /^[0-9]+$/ { bytes[$1] += $10 }
C) END { for (ip in bytes) printf "%-20s %d bytes\n", ip, bytes[ip] }'
D) access.log
E) | sort -k2,2nr -k1,1
F) | sort -t'b' -k2 -rn  # DISTRACTOR: selects an unrelated delimiter
```

### Solution
Join A → B → C → D → E with spaces. The quoted request must have three
whitespace-separated fields, giving status in field 9 and byte count in field 10.
This is the supplied teaching log format; arbitrary combined logs need a parser.

```bash
awk '$9 == 200 && $10 ~ /^[0-9]+$/ { bytes[$1] += $10 }
     END { for (ip in bytes) printf "%-20s %d bytes\n", ip, bytes[ip] }' access.log |
    sort -k2,2nr -k1,1
```

An unrelated field containing 200 must not select an unsuccessful request. Records
with `-` or another nonnumeric byte count are excluded from this byte sum.

---

## PP-C3: Config Transformation

### Objective
From flat `config.txt`, generate **Bash-safe** export statements. Keep values
literal, split only at the first equals sign and normalise only the key. The
reference serializer rejects invalid keys and collisions such as `a.b`/`a_b`.
It does not evaluate values or claim compatibility with every dotenv parser.

### Scrambled Fragments

```text
A) bash
B) "$SEM04_DIR/scripts/bash/S04_config_to_env.sh"
C) --exports
D) config.txt
```

### Solution
A → B → C → D. Set `SEM04_DIR` to the checked-out seminar directory before the
exercise. Inspect the serializer to explain its `read -r`, `${line%%=*}`,
`${line#*=}`, key-only replacement and Bash `printf %q` steps.

```bash
bash "$SEM04_DIR/scripts/bash/S04_config_to_env.sh" --exports config.txt
```

### Result for the supplied two records

```bash
export SERVER_HOST=localhost
export SERVER_PORT=8080
```

Unquoted simple values are valid Bash words. Values needing quotes/escapes are
serialised by `%q`; dotted IPs, embedded `=` and shell-looking text are preserved
as data. Global `s/\./_/g` would corrupt values and `export server.host=...` would
not be a valid variable assignment. The parser treats section headings as labels,
so keys remain global and duplicate names are rejected. It emits nothing until
all input records have passed validation.

---

## PP-C4: Data Cleanup Script

### Objective
Process a CSV: remove header, sort by column 3, format the output.

### Scrambled Lines

```
A) tail -n +2 data.csv
B) | sort -t',' -k3,3
C) | awk -F',' '{ printf "%-10s | %-10s | %s\n", $1, $2, $3 }'
D) sed '1d' data.csv  # ALTERNATIVE for skip header
E) | head -20  # OPTIONAL limit
```

### Solution
Variant 1: A → B → C (optionally → E)
Variant 2: D → B → C

```bash
# With tail
tail -n +2 data.csv | sort -t',' -k3,3 | awk -F',' '{ printf "%-10s | %-10s | %s\n", $1, $2, $3 }'

# With sed
sed '1d' data.csv | sort -t',' -k3,3 | awk -F',' '{ printf "%-10s | %-10s | %s\n", $1, $2, $3 }'
```

### Explanation
1. A or D - Skip header (`tail -n +2` = from line 2, `sed '1d'` = delete line 1)
2. B - Sort CSV by column 3
3. C - Format with awk

---

# BONUS SECTION: ADVANCED PROBLEMS

## PP-X1: Complex One-Liner

### Objective
Within an owned log fixture directory, report the number of ERROR lines in each
regular .log file modified less than one completed day ago. Preserve filename
boundaries and pass names as arguments, never as shell program text.

### Scrambled blocks

```text
A) find "$LOG_DIR" -type f -name '*.log' -mtime -1 -print0
B) | xargs -0 -r sh -c '
C) for file do
D) count=$(grep -c ERROR "$file"); rc=$?
E) case $rc in 0|1) printf "%s: %s\n" "$file" "$count" ;; *) exit "$rc" ;; esac
F) done' sh
```

### Solution: A → B → C → D → E → F

```bash
set -o pipefail
LOG_DIR=${1:?Supply the owned log fixture directory}
find "$LOG_DIR" -type f -name '*.log' -mtime -1 -print0 |
    xargs -0 -r sh -c '
        for file do
            count=$(grep -c ERROR "$file"); rc=$?
            case $rc in
                0|1) printf "%s: %s\n" "$file" "$count" ;;
                *) exit "$rc" ;;
            esac
        done
    ' sh
```

The record delimiter is NUL. A filename containing a newline is handled correctly
as an argument, although its display spans lines; use an explicitly escaped output
format if machine parsing of the report is required.

---

## Parsons Problems Statistics

### Retained Difficulty Allocation for the 16 Core Problems

This allocation is a teaching estimate; the separate PP-X1 bonus is not included.

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
