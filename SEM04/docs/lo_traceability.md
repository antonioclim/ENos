# Learning Outcomes Traceability Matrix
## Seminar 04: Text Processing — Regex, GREP, SED, AWK

> Operating Systems | ASE Bucharest - CSIE  
> Pedagogical traceability document  
> Version: 1.1 | January 2025

---

## 1. Learning Outcomes (LO)

| ID | Learning Outcome | Bloom Level | Verification |
|----|------------------|-------------|--------------|
| **LO1** | Write functional BRE and ERE regular expressions | APPLY | Quiz R1, U1, U2, A1, AN1 |
| **LO2** | Use grep with main options for text search | APPLY | Quiz R2, U3, A1, A4, Sprint G1 |
| **LO3** | Transform text with sed (substitution, deletion, insertion) | APPLY | Quiz R3, U4, A2, A5, E2, Sprint S1 |
| **LO4** | Process structured data with awk (fields, calculations) | APPLY | Quiz U5, A3, E2, Sprint A1 |
| **LO5** | Combine tools in efficient pipelines | ANALYSE | Quiz A4, AN1, AN2, E1, Parsons PP-C1-5 |

---

## 2. LO × Activities Matrix

```
                        │ Main     │ Peer    │ Live   │ Sprint │ Parsons │ Quiz │ Assign│
                        │ Material │ Instr.  │ Coding │        │         │      │       │
────────────────────────┼──────────┼─────────┼────────┼────────┼─────────┼──────┼───────┤
LO1: Regex BRE/ERE      │    ✓     │  PI-R1-6│   LC1  │   —    │  PP-C1  │ R1,U1│  Ex1  │
LO2: grep options       │    ✓     │  PI-G1-6│   LC2  │  G1-G4 │  PP-C2  │ R2,A1│  Ex1  │
LO3: sed transformations│    ✓     │  PI-S1-6│   LC3  │  S1-S4 │  PP-C3  │R3,A2,E2 Ex2  │
LO4: awk processing     │    ✓     │  PI-A1-6│   LC4  │  A1-A2 │  PP-C4  │U5,A3,E2 Ex3  │
LO5: Pipelines          │    ✓     │    —    │   LC5  │ Bonus  │  PP-C5  │A4,AN,E1 Ex4  │
────────────────────────┴──────────┴─────────┴────────┴────────┴─────────┴──────┴───────┘

Legend:
  ✓ = fully covered
  PI-X = Peer Instruction questions
  LC = Live Coding session
  PP-C = Parsons Problem Combo
```

---

## 3. Bloom Distribution in Quiz

| Level | Target | Actual | Questions |
|-------|--------|--------|-----------|
| REMEMBER | 15-20% | 16% | R1, R2, R3 |
| UNDERSTAND | 25-30% | 26% | U1, U2, U3, U4, U5 |
| APPLY | 30-35% | 26% | A1, A2, A3, A4, A5 |
| ANALYSE | 10-15% | 11% | AN1, AN2 |
| EVALUATE | 3-5% | 11% | E1, E2 |
| CREATE | 3-5% | 0% | — |

**Note:** EVALUATE is now covered in quiz (E1, E2). CREATE is covered in Assignments and Projects.

---

## 4. Misconceptions → Questions Mapping

| Misconception | ID | Question that tests it |
|---------------|----|------------------------|
| M1.1: Confusion `*` glob vs regex | U1, A1 | "In BRE, is * literal?" |
| M1.2: Confusion `^` anchor vs negation | U2 | "What does ^[^#] match?" |
| M2.1: Confusion `-v` verbose vs invert | R2 | "What does -v do in grep?" |
| M2.2: `uniq` without `sort` | A4 | "Why is sort needed before?" |
| M3.1: sed replaces all implicitly | U4 | "Without /g, how many does it replace?" |
| M3.2: Substitution vs deletion | A2 | "s/^$// vs /^$/d" |
| M4.1: Field indexing from 0 | U5 | "$1 or $0 for the first?" |
| M4.2: sum=$3 vs sum+=$3 | A3 | "Which adds correctly?" |
| M5.1: Regex too restrictive | E2 | "Email pattern misses cases" |
| M5.2: sort|uniq vs awk single-pass | E1 | "Which is more efficient for large files?" |

---

## 5. Parsons Problems — Pipeline Combinations

These problems test **LO5: Combining tools in pipelines** and include Bash-specific distractors.

---

### PP-C1: Extraction and Counting of Unique IPs

**Objective:** Extract unique IPs from access.log, sorted by frequency.

**Scrambled lines:**
```
A) | head -10
B) grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' access.log
C) | sort -rn
D) | sort
E) | uniq -c
```

**Distractors (lines with common Bash errors):**
```
X1) grep -oE '[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}' access.log
    # ERROR: unescaped . matches ANY character

X2) | uniq -c | sort
    # ERROR: uniq BEFORE sort does not work correctly

X3) grep -o '([0-9]{1,3}\.){3}[0-9]{1,3}' access.log
    # ERROR: missing -E, parentheses are literal in BRE
```

**Correct solution:** B → D → E → C → A
```bash
grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' access.log | sort | uniq -c | sort -rn | head -10
```

**Explanation:**
1. B: Extract IPs with ERE regex (-E for {})
2. D: Sort alphabetically (REQUIRED before uniq)
3. E: Count consecutive occurrences
4. C: Sort numerically descending
5. A: Display top 10

---

### PP-C2: Log Filtering with Multiple Exclusions

**Objective:** Find errors in server.log, excluding debug lines and comments.

**Scrambled lines:**
```
A) grep -i 'error' server.log
B) | grep -v '^#'
C) | grep -v 'DEBUG'
D) | wc -l
```

**Distractors:**
```
X1) grep -i error server.log
    # ERROR: 'error' without quotes may be misinterpreted with special characters

X2) | grep -v ^#
    # ERROR: ^ without quotes may be interpreted by the shell

X3) grep -i 'error' | grep -v '^#' server.log
    # ERROR: file specified at second grep, not the first
```

**Correct solution:** A → B → C → D
```bash
grep -i 'error' server.log | grep -v '^#' | grep -v 'DEBUG' | wc -l
```

**Explanation:**
1. A: Find lines with "error" (case-insensitive)
2. B: Exclude comments (lines starting with #)
3. C: Exclude debug messages
4. D: Count the result

---

### PP-C3: Date Format Transformation with sed

**Objective:** Convert dates from US format (MM/DD/YYYY) to RO format (DD.MM.YYYY).

**Scrambled lines:**
```
A) sed -E
B) 's/([0-9]{2})\/([0-9]{2})\/([0-9]{4})/\2.\1.\3/g'
C) date.txt
D) > date_ro.txt
```

**Distractors:**
```
X1) sed 's/([0-9]{2})\/([0-9]{2})\/([0-9]{4})/\2.\1.\3/g' date.txt
    # ERROR: BRE requires \( \) for grouping, or use -E

X2) sed -E 's/[0-9]{2}/[0-9]{2}/[0-9]{4}/\2.\1.\3/g' date.txt
    # ERROR: missing capture parentheses ()

X3) sed -E "s/([0-9]{2})\/([0-9]{2})\/([0-9]{4})/$2.$1.$3/g" date.txt
    # ERROR: $1, $2 instead of \1, \2 ($ is for shell, not sed)
```

**Correct solution:** A B C D (on a single line)
```bash
sed -E 's/([0-9]{2})\/([0-9]{2})\/([0-9]{4})/\2.\1.\3/g' date.txt > date_ro.txt
```

**Explanation:**
1. A: sed with Extended regex (-E)
2. B: Pattern with 3 capture groups, reordered in output
3. C: Input file
4. D: Redirection to output file

---

### PP-C4: CSV Report with awk

**Objective:** From employees.csv, calculate the average salary per department.

**Scrambled lines:**
```
A) awk -F,
B) 'NR>1 {dept[$3]+=$4; count[$3]++}
C) END {for (d in dept) printf "%s: %.2f\n", d, dept[d]/count[d]}'
D) employees.csv
E) | sort
```

**Distractors:**
```
X1) awk -F ','
    # ERROR: space between -F and ',' causes problems

X2) 'NR>=1 {dept[$3]+=$4; count[$3]++}
    # ERROR: NR>=1 includes the header (should be NR>1)

X3) END {for (d in dept) print d, dept[d]/count[d]}'
    # ERROR: print without printf does not format decimals

X4) awk -F, '{dept[$3]+=$4; count[$3]++} END {...}' employees.csv
    # ERROR: missing NR>1, processes the header too
```

**Correct solution:** A B C D E
```bash
awk -F, 'NR>1 {dept[$3]+=$4; count[$3]++} END {for (d in dept) printf "%s: %.2f\n", d, dept[d]/count[d]}' employees.csv | sort
```

**Explanation:**
1. A: Set CSV delimiter
2. B: For each line (except header), add salary and count
3. C: At the end, calculate and display the formatted average
4. D: Input file
5. E: Sort the result alphabetically

---

### PP-C5: Validation Script with Functions

**Objective:** Create a script that validates a configuration file.

**Scrambled lines:**
```
A) #!/bin/bash
B) set -euo pipefail
C) CONFIG_FILE="${1:?Usage: $0 <config_file>}"
D) validate_format() {
E)     grep -qE '^[A-Z_]+=' "$1" || return 1
F) }
G) if validate_format "$CONFIG_FILE"; then
H)     echo "Valid format"
I) else
J)     echo "INVALID format" >&2
K)     exit 1
L) fi
```

**Distractors:**
```
X1) CONFIG_FILE=$1
    # ERROR: does not check if the argument exists

X2) CONFIG_FILE = "${1:?...}"
    # ERROR: spaces around = in variable assignment

X3) validate_format() {
        grep -qE "^[A-Z_]+=" $1 || return 1
    }
    # ERROR: $1 without quotes — problems with spaces in filename

X4) if [ validate_format "$CONFIG_FILE" ]; then
    # ERROR: [ ] for test, not for running a command

X5) CONFIG_FILE="${1?"Usage: $0 <config_file>"}"
    # ERROR: :? vs ? — :? also checks for empty string
```

**Correct solution:** A → B → C → D → E → F → G → H → I → J → K → L
```bash
#!/bin/bash
set -euo pipefail
CONFIG_FILE="${1:?Usage: $0 <config_file>}"
validate_format() {
    grep -qE '^[A-Z_]+=' "$1" || return 1
}
if validate_format "$CONFIG_FILE"; then
    echo "Valid format"
else
    echo "INVALID format" >&2
    exit 1
fi
```

**Explanation:**
1. A: Shebang for bash
2. B: Strict mode (stops on errors)
3. C: Check argument with error message
4. D-F: Validation function (quiet grep with regex)
5. G-L: Conditional logic with appropriate messages

---

## 6. LO Coverage Checklist

### LO1: Regex BRE/ERE ✅
- [x] Main Material: Module 1 complete
- [x] Peer Instruction: PI-R1 through PI-R6
- [x] Quiz: R1, U1, U2, A1, AN1
- [x] Parsons: PP-C1 (escape dots), PP-C3 (capture groups)

### LO2: grep options ✅
- [x] Main Material: Module 2 complete
- [x] Peer Instruction: PI-G1 through PI-G6
- [x] Live Coding: LC2
- [x] Sprint: G1-G4
- [x] Quiz: R2, U3, A1, A4
- [x] Parsons: PP-C1, PP-C2

### LO3: sed transformations ✅
- [x] Main Material: Module 3 complete
- [x] Peer Instruction: PI-S1 through PI-S6
- [x] Live Coding: LC3
- [x] Sprint: S1-S4
- [x] Quiz: R3, U4, A2, A5, E2
- [x] Parsons: PP-C3

### LO4: awk processing ✅
- [x] Main Material: Module 4 complete
- [x] Peer Instruction: PI-A1 through PI-A6
- [x] Live Coding: LC4
- [x] Sprint: A1-A2
- [x] Quiz: U5, A3, E2
- [x] Parsons: PP-C4

### LO5: Pipelines ✅
- [x] Main Material: Frequent Combinations
- [x] Live Coding: LC5
- [x] Sprint: Bonus Exercises
- [x] Quiz: A4, AN1, AN2, E1
- [x] Parsons: PP-C1 through PP-C5 (all)

---

## 7. Cross-References

| File | LOs Covered | Predominant Bloom |
|------|-------------|-------------------|
| S04_02_MAIN_MATERIAL.md | LO1-5 | UNDERSTAND |
| S04_03_PEER_INSTRUCTION.md | LO1-4 | UNDERSTAND |
| S04_04_PARSONS_PROBLEMS.md | LO1-5 | APPLY |
| S04_05_LIVE_CODING_GUIDE.md | LO1-5 | APPLY |
| S04_06_SPRINT_EXERCISES.md | LO2-4 | APPLY |
| formative/quiz.yaml | LO1-5 | MIXED (incl. EVALUATE) |
| S04_01_HOMEWORK.md | LO1-5 | APPLY/CREATE |

---

*Document generated for pedagogical traceability — Seminar 04*
*Version 1.1 — Updated with EVALUATE coverage*
